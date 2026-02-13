Scriptname HTG:Quests:ModuleTracker extends RefCollectionAlias
{Reference Collection that holds information about loaded Mod(ule)s}
import HTG
import HTG:UtilityExt
import HTG:SystemLogger
import HTG:SystemReferenceUtility
import HTG:SystemFormUtility

FormList Property ModuleRegistry Mandatory Const Auto
Keyword Property SystemModuleInformationKeyword Mandatory Const Auto
Keyword Property LoadedSystemModuleInformationKeyword Mandatory Const Auto
ObjectReference Property ModuleSpawnPoint Mandatory Const Auto
FormList property InstalledContent Mandatory Const Auto

ModuleInformation Property PrimaryModule Mandatory Const Auto
RefCollectionAlias Property Dependencies Mandatory Const Auto
RefCollectionAlias Property Messages Mandatory Const Auto

; RefCollectionAlias Property ExternalModuleTracker Mandatory Const Auto

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

Event OnAliasInit()
    StartTimer(_timerInitInternal, _initializeTimerId)
EndEvent

Event OnAliasChanged(ObjectReference akObject, bool abRemove)
    _WaitForInitialized()

    If !abRemove
        SystemModuleInformation kMod = akObject as SystemModuleInformation
        LogGlobal("Detected Loaded Module: " + kMod + \
                    "\n\tName: " + kMod.Name + \
                    "\n\tDescription: " + kMod.Description + \
                    "\n\tIsCoreIntegrated: " + kMod.IsCoreIntegrated + \
                    "\n\tVersion: " + kMod.Version)

        _MoveModule(kMod)

        String sFormList
        Int i = 0
        Int kCCount = GetCount()
        Int kMRCount = ModuleRegistry.GetSize()
        While i < ModuleRegistry.GetSize()
            Form kForm = ModuleRegistry.GetAt(i)
            sFormList = "\n\t" + kForm + ": " +  Utility.IntToHex(kForm.GetFormID())
            i += 1
        EndWhile

        LogObjectGlobal(ModuleRegistry, "PRE ADD: ModuleRegistry: " + ModuleRegistry.GetSize() + \
                                        sFormList)

        If ModuleRegistry.HasForm(kMod)
            ModuleRegistry.AddForm(kMod)
        EndIf

        sFormList = ""
        i = 0
        kCCount = GetCount()
        kMRCount = ModuleRegistry.GetSize()
        While i < ModuleRegistry.GetSize()
            Form kForm = ModuleRegistry.GetAt(i)
            sFormList = "\n\t" + kForm + ": " +  Utility.IntToHex(kForm.GetFormID())
            i += 1
        EndWhile
        
        LogObjectGlobal(ModuleRegistry, "POST ADD: ModuleRegistry: " + ModuleRegistry.GetSize() + \
                                        sFormList)

        If !IsNone(kMod.InstalledMessage) \
            && InstalledContent.Find(kMod.InstalledMessage) < 0
            InstalledContent.AddForm(kMod.InstalledMessage)
        EndIf

        Dependencies.AddRef(akObject)
        Messages.AddRef(akObject)

        ; ObjectReference[] kLinkedModules = ExternalModuleTracker.GetArray() ; Game.GetPlayer().GetRefsLinkedToMe(SystemModuleInformationKeyword)
        ; LogObjectGlobal(kMod, "Modules Linked to Player:" + kLinkedModules)

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

    RefillDependentAliases()
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
        Else
            bRestartTimer = True
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
        ; StartTimer(0.1, _initializeTimerId)
        ; WaitExt(0.25)
        return False
    EndTryLockGuard

    return _isInitialized
EndFunction

Bool Function WaitForInitialized()
    If IsInitialized
        return True
    EndIf

    While GetCount() < ModuleRegistry.GetSize()
        WaitExt(1.5)
        If GetCount() >= ModuleRegistry.GetSize() ;_currentRefreshTimerCycle == _maxRefreshTimerCycle
            ; _Refresh()
            LogGlobal("Finished Refresh of Loaded Modules.")
            LogGlobal("ModuleRegistry Count: " + ModuleRegistry.GetSize() + \
                        "\n\tModuleTracker Count: " + GetCount())
        Else
            LogGlobal("ModuleRegistry Count: " + ModuleRegistry.GetSize() + \
                        "\n\tModuleTracker Count: " + GetCount())
        EndIf
    EndWhile

    ; If GetCount() >= ModuleRegistry.GetSize() ;_currentRefreshTimerCycle == _maxRefreshTimerCycle
    ;     ; _Refresh()
    ;     LogGlobal("Finished Refresh of Loaded Modules.")
    ;     LogGlobal("ModuleRegistry Count: " + ModuleRegistry.GetSize() + \
    ;                 "\n\tModuleTracker Count: " + GetCount())

    ;     ; return True
    ; Else
    ;     LogGlobal("ModuleRegistry Count: " + ModuleRegistry.GetSize() + \
    ;                 "\n\tModuleTracker Count: " + GetCount())
    ; EndIf

    return _WaitForInitialized()
EndFunction

Bool Function _InitializeObject()
    If !_CreateCollections()
        return false
    EndIf

    If !_refreshTimerStarted
        StartTimer(_timerRefreshInterval, _refreshTimerId)
    EndIf

    ; If IsNone(Dependencies) ; \
    ;     && Dependencies.IsInitialized
    ;     Dependencies.RegisterTracker(Self)
    ; Else
    ;     return False
    ; EndIf

    ; If IsNone(Messages) ; \
    ;     && Messages.IsInitialized
    ;     Messages.RegisterTracker(Self)
    ; Else
    ;     return False
    ; EndIf

    return True
EndFunction

Function _Refresh()
    ; LogRefCollectionAliasGlobal(ExternalModuleTracker, "ExternalModuleTracker:")

    ObjectReference kUtilRef = ModuleSpawnPoint
    ; ObjectReference[] kLinkedModules = ExternalModuleTracker.GetArray() ; Game.GetPlayer().GetRefsLinkedToMe(SystemModuleInformationKeyword)
    ; Int i = 0
    ; While i < kLinkedModules.Length
    ;     SystemModuleInformation kMod = kLinkedModules[i] as SystemModuleInformation ; ModuleRegistry.GetAt(i)
    ;     LogObjectGlobal(kMod, "Is ModInfo: " + !IsNone(kMod))
    ;     If !IsNone(kMod) \
    ;         && Find(kMod) < 0
    ;         ; kMod.SetLinkedRef(ModuleSpawnPoint, LoadedSystemModuleInformationKeyword)
    ;         ; _CopyModule(kMod)
    ;         AddRef(kMod)
    ;     EndIf
    ;     i += 1
    ; EndWhile

    SystemUtilitiesObject kSysObject = kUtilRef as SystemUtilitiesObject
    ObjectReference[] kModules = kSysObject.GetRefsLinkedToMe()
    _AddReferences(kModules)

    ; i = 0
    ; While i < kModules.Length ; ModuleRegistry.GetSize()
    ;     SystemModuleInformation kMod = kModules[i] as SystemModuleInformation ; ModuleRegistry.GetAt(i)
    ;     LogObjectGlobal(kMod, "Is ModInfo: " + !IsNone(kMod))
    ;     If !IsNone(kMod) \
    ;         && Find(kMod) < 0
    ;         AddRef(kMod)
    ;         ; _MoveModule(kMod)
    ;     EndIf
    ;     i += 1
    ; EndWhile

    ObjectReference[] kPlayerModules = Game.GetPlayer().GetRefsLinkedToMe()
    _AddReferences(kPlayerModules)

    If _currentRefreshTimerCycle == _maxRefreshTimerCycle
        SystemModuleInformation kPrimaryMod = PrimaryModule.GetReference() as SystemModuleInformation
        ; ObjectReference[] kLinkedSysModules = Game.GetPlayer().GetRefsLinkedToMe(SystemModuleInformationKeyword)
        ; kPlayerModules.Find(kPrimaryMod)
        If kPrimaryMod.IsCoreIntegrated
            kPrimaryMod.SetLinkedRef(None, SystemModuleInformationKeyword)
        EndIf
        ; While i < kLinkedModules.Length
        ;     SystemModuleInformation kMod = kLinkedModules[i] as SystemModuleInformation ; ModuleRegistry.GetAt(i)
        ;     LogObjectGlobal(kMod, "Is ModInfo: " + !IsNone(kMod))
        ;     If !IsNone(kMod) \
        ;         && kMod == kPrimaryMod
        ;         LogObjectGlobal(Self, "k")
        ;         ; kMod.Disable()
        ;         ; kMod.Delete()
        ;         ; kMod.SetLinkedRef(None, SystemModuleInformationKeyword)
        ;     EndIf
        ;     i += 1
        ; EndWhile
    EndIf

    LogRefCollectionAliasGlobal(Self, "Loaded Modules: ")
EndFunction

Bool Function _MoveModule(SystemModuleInformation akMod)
    ObjectReference kUtilRef = ModuleSpawnPoint
    return MoveReference(akMod, kUtilRef)
EndFunction

SystemModuleInformation Function _CopyModule(SystemModuleInformation akMod)
    ObjectReference kUtilRef = ModuleSpawnPoint
    SystemModuleInformation kCloneMod = CreateReference(kUtilRef, akMod, akAlias = Self) as SystemModuleInformation
    return kCloneMod
EndFunction

Bool Function _CreateCollections()
    If _cache == None
        _cache = new Form[0]
    EndIf

    return True
EndFunction

Function _AddReferences(ObjectReference[] akReferences)
    Int i = 0
    While i < akReferences.Length ; ModuleRegistry.GetSize()
        SystemModuleInformation kMod = akReferences[i] as SystemModuleInformation ; ModuleRegistry.GetAt(i)
        LogObjectGlobal(kMod, "Is ModInfo: " + !IsNone(kMod))
        If !IsNone(kMod) \
            && Find(kMod) < 0
            AddRef(kMod)

            If kMod.GetRefsLinkedToMe().Find(kMod) > -1
                kMod.SetLinkedRef(Game.GetPlayer(), SystemModuleInformationKeyword)
            EndIf

            ; _MoveModule(kMod)
        EndIf
        i += 1
    EndWhile
EndFunction

Bool Function _WaitForInitialized()
    Int currentCycle = 0
    Int maxCycle = 600
    Bool maxCycleHit

    ; StartTimer(_timerInterval, _initializeTimerId)

    While !maxCycleHit
        WaitExt(0.75)
        If !Initialize() \ 
            && currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile

    return IsInitialized
EndFunction