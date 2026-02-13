Scriptname HTG:QuestExt extends HTG:QuestBase
import HTG
import HTG:Structs
import HTG:Collections
import HTG:SystemLogger
import HTG:UtilityExt

SystemUtilities Property Utilities Hidden
    SystemUtilities Function Get()
        return _systemUtilities
    EndFunction
EndProperty

HTG:SystemLogger Property Logger Hidden
    HTG:SystemLogger Function Get()
        return _systemUtilities.Logger
    EndFunction
EndProperty

; Bool Property IsInitialized Hidden
;     Bool Function Get()
;         return _isInitialized
;     EndFunction
; EndProperty

; Bool Property IsInitialRun Hidden
;     Bool Function Get()
;         return _isInitialRun
;     EndFunction
; EndProperty

Int Property SystemUtilitiesId = -1 Hidden Auto

; Guard _initializeTimerGuard ProtectsFunctionLogic
; Guard _initializeGuard ProtectsFunctionLogic
; Guard _readyTimerGuard ProtectsFunctionLogic
; Guard _mainTimerGuard ProtectsFunctionLogic
; SystemTimerIds _timerIds
SystemUtilities _systemUtilities
; Bool _isInitialized
; Bool _isInitialRun
; Bool _initializeTimerStarted
; Bool _readyTimerStarted
; Bool _mainTimerStarted
; Float _timerInterval = 0.01
; Int _maxTimerCycle = 100
; Int _currentInitializeTimerCycle = 0
Dictionary _aliasRegistry
Alias[] _deferredAddAlias
Int[] _deferredAddIndex

; CustomEvent OnInitialRun
; CustomEvent OnMain

Event OnInit()
    Parent.OnInit()

    _deferredAddAlias = new Alias[0]
    _deferredAddIndex = new Int[0]

    ; RegisterForCustomEvent(Self, "OnInitialRun")
    ; RegisterForCustomEvent(Self, "OnMain")

    ; _isInitialRun = !_isInitialized
    ; _timerIds = new SystemTimerIds
EndEvent

; Event OnQuestInit()
;     StartTimer(_timerInterval, _timerIds.InitializeId)

;     WaitForInitialized()
; EndEvent

Event OnQuestStarted()
    Parent.OnQuestStarted()

    WaitForInitialized()
    ; StartTimer(_timerInterval, _timerIds.MainId)

    If _systemUtilities.IsDebugging && !IsNone(Logger)
        Debug.Notification( Logger.MainLogName + ":" + Logger.SubLogName + " has been started.")
    EndIf
EndEvent

; Event OnQuestShutdown()
;     ; UnregisterForAllEvents()
;     _UnregisterEvents()
; EndEvent

; Event OnReset()
;     _currentInitializeTimerCycle = 0
;     _isInitialized = False
;     _isInitialRun = True
;     _initializeTimerStarted = False
;     _mainTimerStarted = False
;     _readyTimerStarted = False
; EndEvent

; Event OnStageSet(int auiStageID, int auiItemID)
;     WaitForInitialized()
; EndEvent

; Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
;     WaitForInitialized()
; EndEvent

; Event OnTimer(Int aiTimerID)
;     Int i = 0
;     Int count = 0

;     If aiTimerID == _timerIds.InitializeId
;         If !_isInitialRun && _initializeTimerStarted
;             LogObjectGlobal(Self, "InitializeTimer - Is Not Initial Run or Timer is already running. No need to proceed.")
;             return
;         ElseIf _initializeTimerStarted
;             StartTimer(_timerInterval, _timerIds.InitializeId)
;             return
;         EndIf

;         Float itimerInterval = _timerInterval
;         Int timerId = -1

;         TryLockGuard _initializeTimerGuard, _initializeGuard
;             _initializeTimerStarted = True
;             If !Initialize() &&  _currentInitializeTimerCycle < _maxTimerCycle            
;                 _currentInitializeTimerCycle += 1
;                 timerId = _timerIds.InitializeId
;             ElseIf !_isInitialized && _currentInitializeTimerCycle == _maxTimerCycle
;                 LogWarnGlobal(Self, "HTG:SystemUtililities could not be Initialized")
;                 _currentInitializeTimerCycle = 0
;             Else
;                 Logger.Log("InitializeTimer - Is Initialized. Starting ReadyTimer")
;                 timerId = _systemUtilities.Timers.SystemIds.InitialRunId
;             EndIf
;             _initializeTimerStarted = False
;         EndTryLockGuard

;         If timerid > -1
;             StartTimer(itimerInterval, timerId)
;         EndIf
;     ElseIf aiTimerID == _timerIds.InitialRunId
;         If !_isInitialized || !_isInitialRun || _readyTimerStarted 
;             LogObjectGlobal(Self, "ReadyTimer - Is Not Initial Run or Timer is already running. No need to proceed.")
;             return
;         EndIf

;         TryLockGuard _readyTimerGuard
;             _readyTimerStarted = True
;             SendCustomEvent("OnInitialRun")
;             _InitialRun()
;             _isInitialRun = False
;             _readyTimerStarted = False
;         EndTryLockGuard

;         Logger.Log("ReadyTimer - Completed Initial Run.")
;     ElseIf aiTimerID == _timerIds.MainId
;         If _isInitialRun || _mainTimerStarted
;             Logger.Log("MainTimer - Is Initial Run or Timer is already running. No need to proceed.")
;             return
;         EndIf

;         Bool restartTimer
;         TryLockGuard _mainTimerGuard
;             _mainTimerStarted = True
;             SendCustomEvent("OnMain")
;             restartTimer = _Main()
;             _mainTimerStarted = False
;         EndTryLockGuard

;         If restartTimer
;             StartTimer(_timerInterval, _timerIds.MainId)
;         EndIf
;     EndIf
; EndEvent

; Event OnTimerGameTime(int aiTimerID)
;     WaitForInitialized()
; EndEvent

; Event OnGameplayOptionChanged(GameplayOption[] aChangedOptions)
;     WaitForInitialized()
; EndEvent

; Event HTG:QuestExt.OnInitialRun(HTG:QuestExt akSender, Var[] akArgs)
; EndEvent

; Event HTG:QuestExt.OnMain(HTG:QuestExt akSender, Var[] akArgs)
; EndEvent

; Bool Function Initialize()
;     If _isInitialized
;         return true
;     EndIf

;     TryLockGuard _initializeGuard
;         If _SetSystemAliases()
;             _isInitialized = _RegisterEvents() \
;                             && _CreateCollections() \
;                             && _Init()
;         EndIf
;     Else
;         return False ; StartTimer(0.1, _timerIds.InitializeId)
;     EndTryLockGuard

;     return _isInitialized \
;             && (!IsNone(_systemUtilities) \
;                 && _systemUtilities.IsInitialized)
; EndFunction

; Bool Function WaitForInitialized()
;     If _isInitialized
;         return True
;     EndIf
    
;     Int currentCycle = 0
;     Int maxCycle = 150
;     Bool maxCycleHit

;     ; StartTimer(_timerInterval, _initializeTimerId)
;     While !maxCycleHit
;         WaitExt(0.1)
;         If !Initialize() && currentCycle < maxCycle
;             currentCycle += 1
;         Else
;             maxCycleHit = True
;         EndIf
;     EndWhile

;     return _isInitialized
; EndFunction

Alias Function GetAliasType(String asAliasType)
    Int kMaxIndex = 100
    Int i = 0
    Alias kResult
    
    If asAliasType == "None"
        return None
    EndIf

    ; If IsNone(_aliasRegistry) && !IsNone(_systemUtilities)
    ;     _aliasRegistry = HTG:Collections:Dictionary.Dictionary(_systemUtilities.ModInfo)
    ; EndIf

    While i <= kMaxIndex
        kResult = GetAlias(i)
        LogObjectGlobal(Self, "Checking Alias: " + kResult)
        If !IsNone(kResult)
            kResult = kResult.CastAs(asAliasType) as Alias
        EndIf

        If !IsNone(kResult)
            _CheckAliasType(kResult, i)

            If IsNone(_aliasRegistry) 
                ; SystemUtilities kUtils 
                ; If !IsNone(_systemUtilities)
                ;     kUtils = _systemUtilities
                ; ElseIf kResult is SystemUtilities
                ;     kUtils = kResult as SystemUtilities
                ; EndIf

                ; If !IsNone(kUtils)
                ;     _aliasRegistry = HTG:Collections:Dictionary.Dictionary(kUtils.ModInfo)
                ; EndIf

                _deferredAddAlias.Add(kResult)
                _deferredAddIndex.Add(i)
            Else
                _aliasRegistry.Add(asAliasType, i)
            EndIf

            i = kMaxIndex + 1
        EndIf

        i += 1
    EndWhile

    return kResult
EndFunction

Bool Function _PreInit()
    return _SetSystemAliases()
EndFunction

Bool Function _SetSystemAliases() ; RequiresGuard(_initializeGuard) 
    ; If !_deferredAddAlias || !_deferredAddIndex
    ;     return False
    ; EndIf

    If IsNone(_systemUtilities)
        SystemUtilitiesId = _CheckAliasRegistry("HTG:SystemUtilities")

        If SystemUtilitiesId > -1
            _systemUtilities = GetAlias(SystemUtilitiesId) as SystemUtilities
        Else 
            _systemUtilities = GetAliasType("HTG:SystemUtilities") as SystemUtilities
        EndIf
    EndIf

    return !IsNone(_systemUtilities) && _systemUtilities.WaitForInitialized()
EndFunction

Function _CheckAliasType(Alias akAlias, Int aiIndex)
    If akAlias is SystemUtilities
        SystemUtilitiesId = aiIndex

        If IsNone(_systemUtilities)
            _systemUtilities = akAlias as SystemUtilities
        EndIf
    EndIf
EndFunction

Int Function _CheckAliasRegistry(String asAliasType)
    If (!IsNone(_aliasRegistry) \
            && _aliasRegistry.IsInitialized) \
        && _aliasRegistry.Contains(asAliasType)
        LogObjectGlobal(Self, "Found Alias in registry: " + asAliasType)           
        return _aliasRegistry.GetKeyValue(asAliasType) as Int
    EndIf

    return -1
EndFunction

; Bool Function _RegisterEvents()
;     return True
; EndFunction

; Bool Function _UnregisterEvents()
;     UnregisterForAllEvents()
;     return True
; EndFunction

Bool Function _CreateCollections()
    If IsNone(_aliasRegistry) && !IsNone(_systemUtilities)
        _aliasRegistry = HTG:Collections:Dictionary.Dictionary(_systemUtilities.ModInfo)
    EndIf

    return (!IsNone(_aliasRegistry) && _aliasRegistry.IsInitialized)
EndFunction

; Bool Function _Init()
;     return True
; EndFunction

; Function _InitialRun()
; EndFunction

Bool Function _Main()
    If IsNone(_aliasRegistry)
        return True
    EndIf

    Int i = 0
    Alias[] kAliases = _deferredAddAlias
    Int[] kIndices = _deferredAddIndex
    While i < kAliases.Length
        _aliasRegistry.Add(kAliases[i], kIndices[i])
        LogObjectGlobal(Self, "Deferred Add: " + kAliases[i] + \
                    "\n\tIndex: " + kIndices[i])           
        i += 1
    EndWhile

    i = 0
    While i < kAliases.Length
        _deferredAddAlias.Remove(i)
        _deferredAddIndex.Remove(i)

        i += 1
    EndWhile

    return True
EndFunction