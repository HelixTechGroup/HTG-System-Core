Scriptname HTG:QuestExt extends Quest
import HTG
import HTG:Structs
import HTG:SystemLogger
import HTG:UtilityExt

HTG:SystemUtilities Property SystemUtilities Hidden
    HTG:SystemUtilities Function Get()
        return _systemUtilities
    EndFunction
EndProperty

HTG:SystemLogger Property Logger Hidden
    HTG:SystemLogger Function Get()
        return _systemUtilities.Logger
    EndFunction
EndProperty

Bool Property IsInitialized Hidden
    Bool Function Get()
        return _isInitialized
    EndFunction
EndProperty

Bool Property IsInitialRun Hidden
    Bool Function Get()
        return _isInitialRun
    EndFunction
EndProperty

Int Property UtilitiesAliasId Auto Hidden

Guard _initializeTimerGuard ProtectsFunctionLogic
Guard _readyTimerGuard ProtectsFunctionLogic
Guard _mainTimerGuard ProtectsFunctionLogic
SystemTimerIds _timerIds
HTG:SystemUtilities _systemUtilities
Bool _isInitialized
Bool _isInitialRun
Bool _initializeTimerStarted
Bool _readyTimerStarted
Bool _mainTimerStarted
Float _timerInterval = 0.01
Int _maxTimerCycle = 100
Int _currentInitializeTimerCycle = 0

CustomEvent OnInitialRun
CustomEvent OnMain

Event OnInit()
    RegisterForCustomEvent(Self, "OnInitialRun")
    RegisterForCustomEvent(Self, "OnMain")

    _isInitialRun = !_isInitialized
    _timerIds = new SystemTimerIds
EndEvent

Event OnQuestInit()
    StartTimer(_timerInterval, _timerIds.InitializeId)

    WaitForInitialized()
EndEvent

Event OnQuestStarted()
    WaitForInitialized()
    StartTimer(_timerInterval, _timerIds.MainId)

    If _systemUtilities.DebugGlobal.GetValueInt() == 8
        Debug.Notification( Logger.MainLogName + ":" + Logger.SubLogName + " has been started.")
    EndIf
EndEvent

Event OnQuestShutdown()
    UnregisterForAllEvents()
EndEvent

Event OnReset()
    _currentInitializeTimerCycle = 0
    _isInitialized = False
    _isInitialRun = True
    _initializeTimerStarted = False
    _mainTimerStarted = False
    _readyTimerStarted = False
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    WaitForInitialized()
EndEvent

Event OnTimer(Int aiTimerID)
    Int i = 0
    Int count = 0

    If aiTimerID == _timerIds.InitializeId
        If !_isInitialRun && _initializeTimerStarted
            LogObjectGlobal(Self, "InitializeTimer - Is Not Initial Run or Timer is already running. No need to proceed.")
            return
        ElseIf _initializeTimerStarted
            StartTimer(_timerInterval, _timerIds.InitializeId)
            return
        EndIf

        Float itimerInterval = _timerInterval
        Int timerId = -1

        TryLockGuard _initializeTimerGuard
            _initializeTimerStarted = True
            If !Initialize() &&  _currentInitializeTimerCycle < _maxTimerCycle            
                _currentInitializeTimerCycle += 1
                timerId = _timerIds.InitializeId
            ElseIf !_isInitialized && _currentInitializeTimerCycle == _maxTimerCycle
                LogErrorGlobal(Self, "HTG:SystemUtililities could not be Initialized")
            Else
                Logger.Log("InitializeTimer - Is Initialized. Starting ReadyTimer")
                timerId = _systemUtilities.Timers.SystemTimerIds.InitialRunId
            EndIf
            _initializeTimerStarted = False
        EndTryLockGuard

        If timerid > -1
            StartTimer(itimerInterval, timerId)
        EndIf
    ElseIf aiTimerID == _timerIds.InitialRunId
        If !_isInitialized || !_isInitialRun || _readyTimerStarted 
            LogObjectGlobal(Self, "ReadyTimer - Is Not Initial Run or Timer is already running. No need to proceed.")
            return
        EndIf

        TryLockGuard _readyTimerGuard
            _readyTimerStarted = True
            SendCustomEvent("OnInitialRun")
            _InitialRun()
            _isInitialRun = False
            _readyTimerStarted = False
        EndTryLockGuard

        Logger.Log("ReadyTimer - Completed Initial Run.")
    ElseIf aiTimerID == _timerIds.MainId
        If _isInitialRun || _mainTimerStarted
            Logger.Log("MainTimer - Is Initial Run or Timer is already running. No need to proceed.")
            return
        EndIf

        Bool restartTimer
        TryLockGuard _mainTimerGuard
            _mainTimerStarted = True
            SendCustomEvent("OnMain")
            restartTimer = _Main()
            _mainTimerStarted = False
        EndTryLockGuard

        If restartTimer
            StartTimer(_timerInterval, _timerIds.MainId)
        EndIf
    EndIf
EndEvent

Event OnGameplayOptionChanged(GameplayOption[] aChangedOptions)
    WaitForInitialized()
EndEvent

Event HTG:QuestExt.OnInitialRun(HTG:QuestExt akSender, Var[] akArgs)
EndEvent

Event HTG:QuestExt.OnMain(HTG:QuestExt akSender, Var[] akArgs)
EndEvent

Bool Function Initialize()
    If !_isInitialized
        _isInitialized = _SetSystemUtilities() \
                        && _RegisterEvents() \
                        && _Init()
    EndIf

    return _isInitialized
EndFunction

Bool Function WaitForInitialized()
    If _isInitialized
        return True
    EndIf
    
    Int currentCycle = 0
    Int maxCycle = 600
    Bool maxCycleHit

    ; StartTimer(_timerInterval, _initializeTimerId)
    While !maxCycleHit && !_isInitialized
        WaitExt(0.1)

        If currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile

    return _isInitialized
EndFunction

Bool Function _SetSystemUtilities()
    Int kMaxIndex = 100
    Int i = 0
    HTG:SystemUtilities kUtils

    If IsNone(_systemUtilities)
        If UtilitiesAliasId < 0
            kUtils = GetAlias(UtilitiesAliasId) as HTG:SystemUtilities
            If !IsNone(kUtils)
                _systemUtilities = kUtils
            EndIf
        EndIf

        If IsNone(_systemUtilities)
            While i <= kMaxIndex
                kUtils = GetAlias(i) as HTG:SystemUtilities
                If IsNone(kUtils)
                    i += 1
                Else
                    _systemUtilities = kUtils
                    UtilitiesAliasId = i     
                    i = kMaxIndex + 1
                EndIf
            EndWhile
        EndIf
    EndIf

    If !IsNone(_systemUtilities)
        return _systemUtilities.WaitForInitialized()
    EndIf

    Game.Error("Could not find SystemUtilities Alias.")
    return False
EndFunction

Bool Function _RegisterEvents()
    return True
EndFunction

Bool Function _Init()
    return True
EndFunction

Function _InitialRun()
EndFunction

Bool Function _Main()
    return False
EndFunction