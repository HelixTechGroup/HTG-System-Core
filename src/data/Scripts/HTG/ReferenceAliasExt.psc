Scriptname HTG:ReferenceAliasExt extends ReferenceAlias
import HTG
import HTG:Structs
import HTG:SystemLogger
import HTG:UtilityExt

HTG:SystemUtilities Property SystemUtilities Hidden
    HTG:SystemUtilities Function Get()
        return _systemUtilities
    EndFunction
EndProperty ; Hidden

HTG:SystemLogger Property Logger Hidden
    HTG:SystemLogger Function Get()
        return SystemUtilities.Logger
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

Guard _initializeTimerGuard ProtectsFunctionLogic
Guard _readyTimerGuard ProtectsFunctionLogic
Guard _mainTimerGuard ProtectsFunctionLogic
HTG:SystemUtilities _systemUtilities
SystemTimerIds _timerIds
Bool _isInitialized
Bool _isInitialRun
Bool _initializeTimerStarted
Bool _readyTimerStarted
Bool _mainTimerStarted
Float _timerInterval = 0.01
Int _maxTimerCycle = 1000
Int _currentInitializeTimerCycle = 0

CustomEvent OnInitialRun
CustomEvent OnMain

Event OnInit()
    RegisterForCustomEvent(Self, "OnInitialRun")
    RegisterForCustomEvent(Self, "OnMain")
    _isInitialRun = !_isInitialized
    _timerIds = new SystemTimerIds
EndEvent

Event OnAliasInit()
    StartTimer(_timerInterval, _timerIds.InitializeId)
    WaitForInitialized()
EndEvent

Event OnAliasChanged(ObjectReference akObject, bool abRemove)
    WaitForInitialized()
EndEvent

Event OnAliasStarted()
    WaitForInitialized()
    StartTimer(_timerInterval, _timerIds.InitialRunId)
EndEvent

Event OnTimer(Int aiTimerID)
    Int i = 0
    Int count = 0

    If aiTimerID == _timerIds.InitializeId
        If _isInitialized || !_isInitialRun || _initializeTimerStarted
            LogObjectGlobal(Self, "InitializeTimer - Is Not Initial Run or Timer is already running. No need to proceed.")
            return
        EndIf

        Float itimerInterval = _timerInterval
        Int timerId = -1

        LockGuard _initializeTimerGuard
            _initializeTimerStarted = True
            If !Initialize() && _currentInitializeTimerCycle < _maxTimerCycle            
                _currentInitializeTimerCycle += 1
                timerId = _timerIds.InitializeId
            ElseIf !_isInitialized && _currentInitializeTimerCycle == _maxTimerCycle
                LogErrorGlobal(Self, "HTG:SystemUtililities could not be Initialized")
                return
            ; Else
            ;     Logger.Log("InitializeTimer - Is Initialized. Starting ReadyTimer")
            ;     timerId = SystemUtilities.Timers.SystemTimerIds.InitialRunId
            EndIf
            _initializeTimerStarted = False
        EndLockGuard

        If timerid > -1
            StartTimer(itimerInterval, timerId)
        EndIf
    ElseIf aiTimerID == _timerIds.InitialRunId
        If !_isInitialized || !_isInitialRun || _readyTimerStarted 
            Logger.Log("ReadyTimer - Is Not Initial Run or Timer is already running. No need to proceed.")
            return
        EndIf

        LockGuard _readyTimerGuard
            _readyTimerStarted = True
            SendCustomEvent("OnInitialRun")
            _InitialRun()
            _isInitialRun = False
            _readyTimerStarted = False
        EndLockGuard

        Logger.Log("ReadyTimer - Completed Initial Run.")
        StartTimer(_timerInterval, _timerIds.MainId)
    ElseIf aiTimerID == _timerIds.MainId
        If !_isInitialized || _isInitialRun || _mainTimerStarted
            Logger.Log("MainTimer - Is Initial Run or Timer is already running. No need to proceed.")
            return
        EndIf

        Int kMaxStarWait = SystemUtilities.Timers.WaitDefaults.MaxCycles
        Bool kShouldWait = GetOwningQuest().IsStarting() || !GetOwningQuest().IsRunning()
        While (kShouldWait)
            Utility.WaitMenuPause(SystemUtilities.Timers.WaitDefaults.Time)
            If i <= kMaxStarWait
                i += 1
                kShouldWait = GetOwningQuest().IsStarting() || !GetOwningQuest().IsRunning()
            Else
                kShouldWait = False
            EndIf
        EndWhile

        Bool restartTimer
        LockGuard _mainTimerGuard
            _mainTimerStarted = True
            SendCustomEvent("OnMain")
            restartTimer = _Main()
            _mainTimerStarted = False
        EndLockGuard

        If restartTimer
            StartTimer(_timerInterval, _timerIds.MainId)
        EndIf
    EndIf
EndEvent

Event HTG:ReferenceAliasExt.OnInitialRun(HTG:ReferenceAliasExt akSender, Var[] akArgs)
EndEvent

Event HTG:ReferenceAliasExt.OnMain(HTG:ReferenceAliasExt akSender, Var[] akArgs)
EndEvent

Bool Function Initialize()
    If !_isInitialized
        _isInitialized = _SetSystemUtilities() && _Init()
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
        If !_initializeTimerStarted
            StartTimer(_timerInterval, _timerIds.InitializeId)
        EndIf
        Utility.WaitMenuPause(0.1)

        If currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile

    return _isInitialized
EndFunction

Bool Function _SetSystemUtilities()
    If IsNone(_systemUtilities)
        QuestExt kQuest = (GetOwningQuest() as QuestExt)
        If !IsNone(kQuest) 
            _systemUtilities = kQuest.SystemUtilities
        Else
            Game.Error("Could not set System Utilities on References Alias: " + Self)
            return False
        EndIf
    Else
        return _systemUtilities.IsInitialized
    EndIf

    return False
EndFunction

Bool Function _Init()
    return true
EndFunction

Function _InitialRun()
EndFunction

Bool Function _Main()
    return False
EndFunction