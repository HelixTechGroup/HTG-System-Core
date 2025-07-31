Scriptname HTG:ActivatorExt extends ObjectReference
{Extended Activator}
import HTG
import HTG:Structs
import HTG:SystemLogger
import HTG:UtilityExt
import HTG:Quests

SystemUtilities Property Utilities Auto Const Mandatory

HTG:SystemLogger Property Logger Hidden
    HTG:SystemLogger Function Get()
        return Utilities.Logger
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
SystemTimerIds _timerIds
Bool _isInitialized
Bool _isInitialRun
Bool _initializeTimerStarted
Bool _readyTimerStarted
Bool _mainTimerStarted
Float _timerInterval = 0.01
Int _maxTimerCycle = 50
Int _currentInitializeTimerCycle = 0

CustomEvent OnInitialRun
CustomEvent OnMain

Event OnInit()
    RegisterForCustomEvent(Self, "OnInitialRun")
    RegisterForCustomEvent(Self, "OnMain")
    _isInitialRun = !_isInitialized
    _timerIds = new SystemTimerIds
    StartTimer(_timerInterval, _timerIds.InitializeId)
EndEvent

Event OnActivate(ObjectReference akActionRef)
    WaitForInitialized()
EndEvent

Event OnReset()
    _currentInitializeTimerCycle = 0
    _isInitialized = False
    _isInitialRun = True
    _initializeTimerStarted = False
    _mainTimerStarted = False
    _readyTimerStarted = False
EndEvent

Event OnTimer(Int aiTimerID)
    Int i = 0
    Int count = 0

    If aiTimerID == _timerIds.InitializeId
        If !_isInitialRun || _initializeTimerStarted
            LogObjectGlobal(Self, "InitializeTimer - Is Not Initial Run or Timer is already running. No need to proceed.")
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
            timerId = Utilities.Timers.SystemTimerIds.InitialRunId
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
        StartTimer(_timerInterval, _timerIds.MainId)
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

Event HTG:ActivatorExt.OnInitialRun(HTG:ActivatorExt akSender, Var[] akArgs)
EndEvent

Event HTG:ActivatorExt.OnMain(HTG:ActivatorExt akSender, Var[] akArgs)
EndEvent

Bool Function Initialize()
    If !_isInitialized
        If _SetSystemUtilities()
            _isInitialized = _RegisterEvents() \
                            && _CreateCollections() \
                            && _Init()
        EndIf
    EndIf

    return _isInitialized
EndFunction

Bool Function WaitForInitialized()
    If _isInitialized
        return True
    EndIf
    
    Int currentCycle = 0
    Int maxCycle = 150
    Bool maxCycleHit

    ; StartTimer(_timerInterval, _initializeTimerId)
    While !maxCycleHit && !_isInitialized \
            && (IsNone(Utilities) || !Utilities.IsInitialized)
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
    return Utilities.WaitForInitialized()
EndFunction

Bool Function _RegisterEvents()
    return True
EndFunction

Bool Function _CreateCollections()
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