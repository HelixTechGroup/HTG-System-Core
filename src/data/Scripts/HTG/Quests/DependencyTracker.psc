Scriptname HTG:Quests:DependencyTracker extends RefCollectionAlias
import HTG
import HTG:Structs
import HTG:Collections
import HTG:UtilityExt
import HTG:SystemLogger

; SystemDependencyEntry[] Property RegisteredTypes
;     HTG:SystemDependencyEntry[] Function Get()
;         return _entries.
;     EndFunction
; EndProperty

ModuleInformation Property ModInfoAlias Mandatory Const Auto

ModuleTracker Property Modules Hidden
    HTG:Quests:ModuleTracker Function Get()
        If IsFilled()
            return (Self as RefCollectionAlias) as ModuleTracker
        EndIf

        return None
    EndFunction    
EndProperty

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
Float _timerInternal = 0.05
Int _maxTimerCycle = 600
Int _currentTimerCycle = 0
SystemDependencyEntryList _entries
SystemTypeCacheEntry[] _cache

CustomEvent OnResolve
CustomEvent OnRegister

Event OnInit()
    RegisterForCustomEvent(Self, "OnResolve")
    RegisterForCustomEvent(Self, "OnRegister")

    StartTimer(_timerInternal, _initializeTimerId)
EndEvent

Event OnAliasChanged(ObjectReference akObject, bool abRemove)
    WaitForInitialized()
    ; Parent.OnAliasChanged(akObject, abRemove)

    If !abRemove
        SystemModuleInformation kMod = akObject as SystemModuleInformation
        LogObjectGlobal(Self, "Detected Loaded Module: " + kMod + \
                    "\n\tName: " + kMod.Name + \
                    "\n\tDescription: " + kMod.Description + \
                    "\n\tIsCoreIntegrated: " + kMod.IsCoreIntegrated + \
                    "\n\tVersion: " + kMod.Version)

        If kMod.LocalSystemTypeRegistry != None \
            || kMod.LocalSystemTypeRegistry.Length > 0
            Int i = 0
            SystemTypeEntry[] kTypes = kMod.LocalSystemTypeRegistry
            LogObjectGlobal(Self, "Registering " + kTypes.Length + " SystemTypes")
            While i < kTypes.Length
                SystemTypeEntry kEntry = kTypes[i]
                LogObjectGlobal(Self, "Registering System Type: " + kEntry + \
                    "\n\tName: " + kEntry.Name + \
                    "\n\tFormId: " + kEntry.FormId + \
                    "\n\tModName: " + kEntry.ModName + \
                    "\n\tScript: " + kEntry.Script)
                RegisterEntry(kEntry)
                i += 1
            EndWhile

            LogRefCollectionAliasGlobal(Self, "DependencyTracker Found Modules:")
        EndIf
    EndIf
EndEvent

Event OnTimer(Int aiTimerID)
    If aiTimerID == _initializeTimerId
        If _isInitialized || _initializeTimerStarted
            LogObjectGlobal(Self, "InitializeTimer - Timer is already running. No need to proceed.")
            return
        EndIf

        Bool bRestartTimer
        TryLockGuard _initializeTimerGuard, _initializeGuard
            If !Initialize() && _currentTimerCycle < _maxTimerCycle    
                WaitExt(0.15)        
                _currentTimerCycle += 1
                bRestartTimer = True
            ElseIf _currentTimerCycle == _maxTimerCycle
                LogErrorGlobal(Self, "HTG:Quests:DependencyTracker could not be Initialized")
            EndIf
        EndTryLockGuard
        
        If bRestartTimer
            StartTimer(_timerInternal, _initializeTimerId)
        EndIf
    EndIf
EndEvent

Event HTG:Quests:DependencyTracker.OnRegister(HTG:Quests:DependencyTracker akSender, Var[] akArgs)
    WaitForInitialized()
EndEvent

Event HTG:Quests:DependencyTracker.OnResolve(HTG:Quests:DependencyTracker akSender, Var[] akArgs)
    WaitForInitialized()
EndEvent

Bool Function Initialize()
    If _isInitialized
        return True
    EndIf

    TryLockGuard _initializeGuard
        _isInitialized = _InitializeObject()
    Else
        StartTimer(0.1, _initializeTimerId)
        WaitExt(0.333)
    EndTryLockGuard

    return _isInitialized
EndFunction

Bool Function WaitForInitialized()
    If IsInitialized
        return True
    EndIf
    
    Int currentCycle = 0
    Int maxCycle = 600
    Bool maxCycleHit

    ; StartTimer(_timerInterval, _initializeTimerId)

    While !maxCycleHit \
            && ((!IsNone(Modules) && !Modules.IsInitialized) \
                || !IsInitialized)
        WaitExt(0.05)

        If currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile

    return IsInitialized
EndFunction

Bool Function RegisterForm(String asName, \                        
                        String asModName, \
                        Int aiId = -1, \
                        String akScriptNames = "", \
                        Form akForm = None, \
                        Bool abCreateReference = False)
    SystemTypeEntry kEntry = new SystemTypeEntry
    kEntry.FormId = aiId
    kEntry.Name = asName
    kEntry.Script = akScriptNames
    kEntry.ModName = asModName

    Var[] kArgs = new Var[0]
    kArgs.Add(kEntry)
    SendCustomEvent("OnRegister", kArgs)

    return RegisterEntry(kEntry)
EndFunction

Bool Function RegisterEntry(SystemTypeEntry akEntry)
    return _entries.AddEntry(akEntry) > -1
EndFunction

Form Function ResolveForm(Int aiId = -1, \
                        String asName = "", \
                        String asScriptName = "")
    WaitForInitialized()

    SystemDependencyEntry kEntry = _ResolveEntry(aiId, asName, asScriptName)
    Var[] kArgs = new Var[0]
    kArgs.Add(kEntry)
    SendCustomEvent("OnResolve", kArgs)

    return kEntry.Type
EndFunction

Form Function ResolveReference(Int aiId = -1, \
                        String asName = "", \
                        String asScriptName = "")
    WaitForInitialized()

    SystemDependencyEntry kEntry = _ResolveEntry(aiId, asName, asScriptName)

    If IsNone(kEntry)
        LogWarnGlobal(Self, "Unable to locate SystemTypeEntry for the following:" + \
                                "\n\tFormID:" + aiId + \ 
                                "\n\tFormName: " + asName)
        return None
    EndIf
    
    return kEntry.Reference
EndFunction

Bool Function ContainsForm(Int aiId = -1, \
                            String asName = "", \
                            String asScriptName = "")
    WaitForInitialized()

    Bool kResult
    If aiId > -1 \
        && (_cache.FindStruct("FormId", aiId) \
            || _entries.ContainsFormId(aiId))
        kResult = True
    ElseIf asName != "" \
            && (_cache.FindStruct("Name", asName) \
                || _entries.ContainsFormName(asName))
        kResult = True
    ElseIf asScriptName != "" \
            && _entries.ContainsScriptName(asScriptName)
        kResult = True
    EndIf

    return kResult
EndFunction

Bool Function ContainsEntry(SystemDependencyEntry akEntry)
    WaitForInitialized()
    
    return _entries.Contains(akEntry)
EndFunction

Bool Function _InitializeObject()
    return _CreateCollections() \   
            && (!IsNone(Modules) && Modules.WaitForInitialized())
EndFunction

Bool Function _CreateCollections()
    If !IsNone(ModInfoAlias) && !ModInfoAlias.IsFilled()
        return False
    EndIf

    If _entries == None
        SystemModuleInformation kMod = ModInfoAlias.GetReference() as SystemModuleInformation
        _entries = HTG:Collections:SystemDependencyEntryList.SystemDependencyEntryList(kMod)
    EndIf

    If _cache == None
        _cache = new SystemTypeCacheEntry[0]
    EndIf

    return (!IsNone(_entries) && _entries.IsInitialized)

EndFunction

SystemDependencyEntry Function _ResolveEntry(Int aiId = -1, \
                            String asName = "", \
                            String asScriptName = "")
    ; If this impacts performance switch to checking the index directly and getting the entry.
    SystemDependencyEntry kEntry
    If aiId > -1 \
        && (_cache.FindStruct("FormId", aiId) \
            || _entries.ContainsFormId(aiId))
        kEntry = _entries.GetFormIdEntry(aiId)
    ElseIf asName != "" \
            && (_cache.FindStruct("Name", asName) \
                || _entries.ContainsFormName(asName))
        kEntry = _entries.GetFormNameEntry(asName)
    ElseIf asScriptName != "" \
            && (_cache.FindStruct("Script", asName) \
                || _entries.ContainsFormName(asScriptName))
        kEntry = _entries.GetScriptNameEntry(asScriptName)
    EndIf

    If !IsNone(kEntry) \
        && _cache.FindStruct("FormId", kEntry.Id) < 0
        SystemTypeCacheEntry kCache = new SystemTypeCacheEntry
        kCache.FormId = kEntry.Id
        kCache.Name = kEntry.Name
        kCache.Script = kEntry.SystemType.Script
        kCache.ModuleIndex = _entries.Find(kEntry)
        kCache.Reference = kEntry.Reference

        _cache.Add(kCache)
    EndIf

    return kEntry
EndFunction