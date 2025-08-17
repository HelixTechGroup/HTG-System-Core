Scriptname HTG:RefCollectionAliasExt extends RefCollectionAlias
{Extended RefCollectionAlias}
import HTG
import HTG:UtilityExt
import HTG:Structs
import HTG:SystemLogger
import HTG:Quests

SystemUtilities Property Utilities Hidden
    SystemUtilities Function Get()
        return _systemUtilities
    EndFunction
EndProperty ; Hidden

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
Guard _initializeGuard ProtectsFunctionLogic
Guard _readyTimerGuard ProtectsFunctionLogic
Guard _mainTimerGuard ProtectsFunctionLogic
SystemTimerIds _timerIds
SystemUtilities _systemUtilities
Bool _isInitialized
Bool _isInitialRun
Bool _initializeTimerStarted
Bool _readyTimerStarted
Bool _mainTimerStarted
Float _timerInterval = 0.1
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

Event OnAliasShutdown()
    _UnregisterEvents()
    ; UnregisterForAllEvents()
EndEvent

Event OnAliasReset()
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
        If _isInitialized || !_isInitialRun || _initializeTimerStarted
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
                return
            ; Else
            ;     Logger.Log("InitializeTimer - Is Initialized. Starting ReadyTimer")
            ;     timerId = Utilities.Timers.SystemTimerIds.InitialRunId
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
        If !_isInitialized || _isInitialRun || _mainTimerStarted
            LogObjectGlobal(Self, "MainTimer - Is Initial Run or Timer is already running. No need to proceed.")
            return
        EndIf

        Int kMaxStarWait = Utilities.Timers.WaitDefaults.MaxCycles
        Bool kShouldWait = GetOwningQuest().IsStarting() || !GetOwningQuest().IsRunning()
        While (kShouldWait)
            WaitExt(Utilities.Timers.WaitDefaults.Time)
            If i <= kMaxStarWait
                i += 1
                kShouldWait = GetOwningQuest().IsStarting() || !GetOwningQuest().IsRunning()
            Else
                kShouldWait = False
            EndIf
        EndWhile

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

Event HTG:RefCollectionAliasExt.OnInitialRun(HTG:RefCollectionAliasExt akSender, Var[] akArgs)
EndEvent

Event HTG:RefCollectionAliasExt.OnMain(HTG:RefCollectionAliasExt akSender, Var[] akArgs)
EndEvent

Bool Function Initialize()
    If _isInitialized
        return true
    EndIf

    TryLockGuard _initializeGuard
        If _SetSystemUtilities()
            _isInitialized = _RegisterEvents() \
                            && _CreateCollections() \
                            && _Init()
        EndIf
    Else
        StartTimer(0.1, _timerIds.InitializeId)
        ; WaitExt(0.25)
    EndTryLockGuard

    return _isInitialized \
            && (!IsNone(_systemUtilities) \
                && _systemUtilities.IsInitialized)
EndFunction

Bool Function Contains(ObjectReference akRef)
    If Find(akRef) > -1
        return True
    EndIf

    return False
EndFunction

Bool Function WaitForInitialized()
    If _isInitialized
        return True
    EndIf
    
    Int currentCycle = 0
    Int maxCycle = 300
    Bool maxCycleHit

    ; StartTimer(_timerInterval, _initializeTimerId)
    QuestExt kQuest = (GetOwningQuest() as QuestExt)

    While !maxCycleHit ; \
                ; || (!IsNone(kQuest) \
                ; || !kQuest.Utilities.WaitForInitialized()))
        ; Bool kUtilitInit
        ; If !IsNone(kQuest)  && !IsNone(kQuest.Utilities)
        ;     kUtilitInit = kQuest.Utilities.WaitForInitialized()
        ; EndIf

        ; If !_initializeTimerStarted && kUtilitInit
        ;     ; StartTimer(_timerInterval, _timerIds.InitializeId)
        ;     Initialize()
        ; EndIf
        WaitExt(0.25)

        If !Initialize() && currentCycle < maxCycle
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
            ; kQuest.WaitForInitialized() 
            _systemUtilities = kQuest.Utilities
        Else
            LogErrorGlobal(GetOwningQuest(), "Could not set System Utilities on References Alias: " + Self)
            return False
        EndIf
    EndIf

    If !IsNone(_systemUtilities) 
        return _systemUtilities.IsInitialized
    EndIf

    return False
EndFunction

Bool Function _RegisterEvents()
    return True
EndFunction

Bool Function _UnregisterEvents()
    return True
EndFunction

Bool Function _CreateCollections()
    return True
EndFunction

Bool Function _Init()
    return true
EndFunction

Function _InitialRun()
EndFunction

Bool Function _Main()
    return False
EndFunction