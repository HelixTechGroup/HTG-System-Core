Scriptname HTG:Quests:ModuleTracker extends RefCollectionAlias
{Reference Collection that holds information about loaded Mod(ule)s}
import HTG
import HTG:UtilityExt
import HTG:SystemLogger
import HTG:SystemReferenceUtility

FormList Property ModuleRegistry Mandatory Const Auto
Keyword Property SystemModuleInformationKeyword Mandatory Const Auto
ObjectReference Property ModuleSpawnPoint Mandatory Const Auto

Bool Property IsInitialized Hidden
    Bool Function Get()
        return _isInitialized
    EndFunction
EndProperty

Guard _initializeTimerGuard ProtectsFunctionLogic
Guard _initializeGuard ProtectsFunctionLogic
Bool _isInitialized
Bool _initializeTimerStarted
Int _initializeTimerId = 1
Float _timerInitInternal = 0.333
Int _maxInitTimerCycle = 600
Int _currentTimerCycle = 0
Guard _refreshTimerGuard ProtectsFunctionLogic
Int _refreshTimerId = 10
Bool _refreshTimerStarted
Float _timerRefreshInterval = 0.333
Int _maxRefreshTimerCycle = 150
Int _currentRefreshTimerCycle = 0
; Int _previousCount = -1
Form[] _cache

Event OnAliasStarted()
    StartTimer(_timerInitInternal, _initializeTimerId)
EndEvent

Event OnAliasChanged(ObjectReference akObject, bool abRemove)
    WaitForInitialized()

    If !abRemove
        SystemModuleInformation kMod = akObject as SystemModuleInformation
        LogGlobal("Detected Loaded Module: " + kMod + \
                    "\n\tName: " + kMod.Name + \
                    "\n\tDescription: " + kMod.Description + \
                    "\n\tIsCoreIntegrated: " + kMod.IsCoreIntegrated + \
                    "\n\tVersion: " + kMod.Version)

        _MoveModule(kMod)

        If ModuleRegistry.Find(kMod) < 0
            ModuleRegistry.AddForm(kMod)
        EndIf

        ; If _cache.Find(kMod) < 0
        ;     _cache.Add(kMod)
        ; EndIf

        ; _previousCount += 1
    Else
        SystemModuleInformation kMod = akObject as SystemModuleInformation
        If ModuleRegistry.Find(kMod) > -1
            ModuleRegistry.RemoveAddedForm(kMod)
        EndIf

        ; _previousCount -= 1
    EndIf
EndEvent

Event OnTimer(int aiTimerID)
    If aiTimerID == _initializeTimerId
        If _isInitialized || _initializeTimerStarted
            LogObjectGlobal(Self, "InitializeTimer - Timer is already running. No need to proceed.")
            return
        EndIf

        Bool bRestartTimer
        TryLockGuard _initializeTimerGuard, _initializeGuard
            If !Initialize() &&  _currentTimerCycle < _maxInitTimerCycle    
                WaitExt(0.15)        
                _currentTimerCycle += 1
                bRestartTimer = True
            ElseIf _currentTimerCycle == _maxInitTimerCycle \
                    && ModuleRegistry.GetSize() > GetCount()
                LogErrorGlobal(Self, "HTG:Quests:ModuleTracker could not be Initialized")
            EndIf
        EndTryLockGuard
        
        If bRestartTimer
            StartTimer(_timerInitInternal, _initializeTimerId)
        EndIf
    ElseIf aiTimerID == _refreshTimerId
        TryLockGuard _refreshTimerGuard
            _refreshTimerStarted = True
            _Refresh()
            If _currentRefreshTimerCycle < _maxRefreshTimerCycle            
                _currentRefreshTimerCycle += 1
            ElseIf _currentRefreshTimerCycle == _maxRefreshTimerCycle
                LogGlobal("Finished Refresh of Loaded Modules.")
                return
            EndIf
            _refreshTimerStarted = False
        EndTryLockGuard

        StartTimer(_timerRefreshInterval, _refreshTimerId)
    EndIf
EndEvent

Bool Function Initialize()
    If _isInitialized
        return True
    EndIf

    TryLockGuard _initializeGuard
        _isInitialized = _InitializeObject()
    Else
        StartTimer(0.1, _initializeTimerId)
        ; WaitExt(0.25)
    EndTryLockGuard

    return _isInitialized
EndFunction

Bool Function WaitForInitialized()
    If IsInitialized
        return True
    EndIf
    
    Int currentCycle = 0
    Int maxCycle = 150
    Bool maxCycleHit

    ; StartTimer(_timerInterval, _initializeTimerId)

    While !maxCycleHit \
            && (!IsInitialized)
        WaitExt(0.01)

        If currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile

    return IsInitialized
EndFunction

Bool Function _InitializeObject()
    If !_CreateCollections()
        return false
    EndIf

    If !_refreshTimerStarted
        StartTimer(_timerRefreshInterval, _refreshTimerId)
    EndIf

    If GetCount() >= ModuleRegistry.GetSize() ;_currentRefreshTimerCycle == _maxRefreshTimerCycle
        ; _Refresh()
        LogGlobal("Finished Refresh of Loaded Modules.")
        LogGlobal("ModuleRegistry Count: " + ModuleRegistry.GetSize() + \
                    "\n\tModuleTracker Count: " + GetCount())
        return True
    Else
        LogGlobal("ModuleRegistry Count: " + ModuleRegistry.GetSize() + \
                    "\n\tModuleTracker Count: " + GetCount())
    EndIf
    return False
EndFunction

Function _Refresh()
    ObjectReference kUtilRef = ModuleSpawnPoint
    ObjectReference[] kModules 

    SystemUtilitiesObject kSysObject = kUtilRef as SystemUtilitiesObject
    kModules = kSysObject.GetRefsLinkedToMe()
    
    Int i
    While i < kModules.Length ; ModuleRegistry.GetSize()
        SystemModuleInformation kMod = kModules[i] as SystemModuleInformation ; ModuleRegistry.GetAt(i)
        LogObjectGlobal(kMod, "Is ModInfo: " + !IsNone(kMod))
        If !IsNone(kMod) \
            && Find(kMod) < 0
            AddRef(kMod)
            ; _MoveModule(kMod)
        EndIf
        i += 1
    EndWhile

    LogRefCollectionAliasGlobal(Self, "Loaded Modules: ")
EndFunction

Function _MoveModule(SystemModuleInformation akMod)
    ObjectReference kUtilRef = ModuleSpawnPoint
    MoveReference(akMod, kUtilRef)
EndFunction

Bool Function _CreateCollections()
    If _cache == None
        _cache = new Form[0]
    EndIf

    return True
EndFunction