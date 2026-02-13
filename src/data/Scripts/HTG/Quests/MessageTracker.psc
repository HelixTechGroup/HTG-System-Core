Scriptname HTG:Quests:MessageTracker extends RefCollectionAlias
import HTG
import HTG:Structs
import HTG:Collections
import HTG:UtilityExt
import HTG:SystemLogger

SystemMessageEntry[] Property SystemMessageRegistery
    SystemMessageEntry[] Function Get()
        return _entries
    EndFunction
EndProperty

SystemMessageEntry Property CurrentMessage
    SystemMessageEntry Function Get()
        return _currentMessage
    EndFunction
EndProperty

Bool Property IsInitialized Hidden
    Bool Function Get()
        return _isInitialized
    EndFunction
EndProperty

; ModuleInformation Property ModInfoAlias Mandatory Const Auto
ModuleTracker Property Modules Mandatory Const Auto

Guard _initializeTimerGuard ProtectsFunctionLogic
Guard _initializeGuard ProtectsFunctionLogic
Guard _mainTimerGuard ProtectsFunctionLogic
Bool _isInitialized
Bool _initializeTimerStarted
Bool _mainTimerStarted
Float _timerInterval = 0.05
Int _maxTimerCycle = 600
Int _currentTimerCycle = 0
SystemMessageEntry _currentMessage
SystemTimerIds _timerIds
SystemMessageEntry[] _entries
SystemMessageAliasEntry[] _entryReferences
SystemMessageQueueEntry[] _queue
Int _queueTimerId = 2000
Int _queueTimerIdMax = 999
Int[] _queueTimerIds
; ModuleTracker _tracker

CustomEvent OnMain
CustomEvent OnUnregister
CustomEvent OnRegister
CustomEvent OnShow

Event OnInit()
    RegisterForCustomEvent(Self, "OnMain")
    RegisterForCustomEvent(Self, "OnUnregister")
    RegisterForCustomEvent(Self, "OnRegister")
    RegisterForCustomEvent(Self, "OnShow")

    RegisterForRemoteEvent(Modules, "OnAliasChanged")

    _timerIds = new SystemTimerIds
    StartTimer(_timerInterval, _timerIds.InitializeId)
EndEvent

Event OnAliasChanged(ObjectReference akObject, bool abRemove)
    _WaitForInitialized()
    ; Parent.OnAliasChanged(akObject, abRemove)

    If !abRemove
        SystemModuleInformation kMod = akObject as SystemModuleInformation
        LogObjectGlobal(Self, "Detected Loaded Module: " + kMod + \
                    "\n\tName: " + kMod.Name + \
                    "\n\tDescription: " + kMod.Description + \
                    "\n\tIsCoreIntegrated: " + kMod.IsCoreIntegrated + \
                    "\n\tVersion: " + kMod.Version)

        If kMod.LocalSystemMessageRegistery != None \
            || kMod.LocalSystemMessageRegistery.Length > 0
            Int i = 0
            SystemMessageEntry[] kTypes = kMod.LocalSystemMessageRegistery
            LogObjectGlobal(Self, "Registering " + kTypes.Length + " SystemTypes")
            While i < kTypes.Length
                SystemMessageEntry kEntry = kTypes[i]
                SystemMessageAliasEntry[] kAliases = None
                LogObjectGlobal(Self, "Registering System Message: " + kEntry + \
                                        "\n\tName: " + kEntry.EditorId + \
                                        "\n\tMessage: " + kEntry.Entry + \
                                        "\n\tAlwaysShow: " + kEntry.AlwaysShow + \
                                        "\n\tPriority: " + kEntry.Priority + \
                                        "\n\tDelayTime: " + kEntry.DelayTime + \
                                        "\n\tDuration: " + kEntry.Duration + \
                                        "\n\tInterval: " + kEntry.Interval + \
                                        "\n\tMaxTimes: " + kEntry.MaxTimes)
                If kMod.LocalSystemMessageAliasRegistry != None \
                    && kMod.LocalSystemMessageAliasRegistry.Length > 0
                    kAliases = kMod.LocalSystemMessageAliasRegistry.GetAllMatchingStructs("MessageEntryIndex", i)
                EndIf

                RegisterEntry(kEntry, kAliases)
                i += 1
            EndWhile

            LogRefCollectionAliasGlobal(Self, "MessageTracker Found Modules:")
        EndIf
    EndIf
EndEvent

Event OnTimer(int aiTimerID)
    If aiTimerID == _timerIds.InitializeId
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
        Else
            bRestartTimer = True
        EndTryLockGuard

        If bRestartTimer
            StartTimer(_timerInterval, _timerIds.InitializeId)
        Else
            StartTimer(_timerInterval, _timerIds.MainId)
        EndIf
    ElseIf aiTimerID == _timerIds.MainId
        If _mainTimerStarted
            LogObjectGlobal(Self, "MainTimer - Is Initial Run or Timer is already running. No need to proceed.")
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
    ElseIf aiTimerID >= _queueTimerId
        SystemMessageQueueEntry kEntry ; = _queue.FindStruct("_entry", aiTimerID)
        Int iMessageId = 0 ; aiTimerID - _queueTimerId
        ; If iMessageId >= _queue.Length \
        ;     || _queue[iMessageId] == None
        ;     LogWarnGlobal(Self, "Message does not exist.")
        ;     return
        ; EndIf

        Int i = 0
        While i < _queue.Length
            If _queue[i].TimerId == aiTimerID
                kEntry = _queue[i]
                iMessageId = i
                i = _queue.Length
            EndIf
            i += 1
        EndWhile

        _currentMessage = kEntry.MessageEntry
        _ShowMessage(kEntry)

        Int tIndex = _queueTimerIds.Find(aiTimerID)
        _queueTimerIds.Remove(tIndex)
        If tIndex > -1
            _queue.Remove(iMessageId)
        EndIf

        kEntry.Delete()
    EndIf
EndEvent

Event HTG:Quests:MessageTracker.OnMain(HTG:Quests:MessageTracker akSender, Var[] akArgs)
    WaitForInitialized()
EndEvent

Event HTG:Quests:MessageTracker.OnUnregister(HTG:Quests:MessageTracker akSender, Var[] akArgs)
    WaitForInitialized()
EndEvent

Event HTG:Quests:MessageTracker.OnRegister(HTG:Quests:MessageTracker akSender, Var[] akArgs)
    WaitForInitialized()
EndEvent

Event HTG:Quests:MessageTracker.OnShow(HTG:Quests:MessageTracker akSender, Var[] akArgs)
    WaitForInitialized()
EndEvent

Event RefCollectionAlias.OnAliasChanged(RefCollectionAlias akSender, ObjectReference akObject, bool abRemove)
    If akSender == Modules
        AddRef(akObject)
    EndIf
EndEvent

Bool Function Initialize()
    If _isInitialized
        return True
    EndIf

    TryLockGuard _initializeGuard
        _isInitialized = _InitializeObject()
    Else
        ; return False ; StartTimer(0.1, _timerIds.InitializeId)
        ; WaitExt(0.333)
        return False
    EndTryLockGuard

    return _isInitialized
EndFunction

Bool Function WaitForInitialized()
    If IsInitialized && Modules.IsInitialized
        return True
    EndIf

    While GetCount() < Modules.ModuleRegistry.GetSize()
        WaitExt(0.1)
        ; RefillAlias()
        If GetCount() >= Modules.ModuleRegistry.GetSize() ;_currentRefreshTimerCycle == _maxRefreshTimerCycle
            ; _Refresh()
            LogGlobal("Finished Refresh of Loaded Modules.")
            LogGlobal("ModuleRegistry Count: " + Modules.ModuleRegistry.GetSize() + \
                        "\n\tMessageTracker Count: " + GetCount())
        Else
            LogGlobal("ModuleRegistry Count: " + Modules.ModuleRegistry.GetSize() + \
                        "\n\tMessageTracker Count: " + GetCount())
        EndIf
    EndWhile
    
    return _WaitForInitialized() \
            && Modules.WaitForInitialized()
EndFunction

Function RegisterMessage(String EditorId, \
                            Message akMessage, \
                            Bool abIsHelpMessage = False, \
                            Bool abIsMessageBox = False, \
                            String asEventName = "", \
                            Float afDuration = 30.0, \
                            Float afInterval = 30.0, \
                            Int aiMaxTimes = 1, \
                            Int aiPriority = 0, \
                            String asContext = "", \
                            ReferenceAlias[] akTextHolderAliases = None)
    SystemMessageEntry kEntry = new SystemMessageEntry
    kEntry.Entry = akMessage
    kEntry.IsHelpMessage = abIsHelpMessage
    kEntry.IsMessageBox = abIsMessageBox
    kEntry.EventName = asEventName
    kEntry.Duration = afDuration
    kEntry.Interval = afInterval
    kEntry.MaxTimes = aiMaxTimes
    kEntry.Priority = aiPriority
    kEntry.Context = asContext

    Var[] kArgs = new Var[0]
    kArgs.Add(kEntry)
    SendCustomEvent("OnRegister", kArgs)

    _entries.Add(kEntry)
    Int entryId = _entries.Find(kEntry)

    If akTextHolderAliases != None
        Int i = 0
        ; SystemMessageAliasEntry[] kAliases = new SystemMessageAliasEntry[]

        While i < akTextHolderAliases.Length
            ReferenceAlias kAlias = akTextHolderAliases[i]        
            SystemMessageAliasEntry kAliasEntry = new SystemMessageAliasEntry

            kAliasEntry.MessageEntryIndex = entryId
            kAliasEntry.Entry = kAlias
            _entryReferences.Add(kAliasEntry)
        EndWhile        
    EndIf

EndFunction

Function RegisterEntry(SystemMessageEntry akEntry, \
                        SystemMessageAliasEntry[] akTextHolderAliases = None)
    Var[] kArgs = new Var[0]
    kArgs.Add(akEntry)
    SendCustomEvent("OnRegister", kArgs)

    Int iIndex = _entries.Find(akEntry)                        
    If iIndex < 0
        _entries.Add(akEntry)
        iIndex = _entries.Find(akEntry)
        Int i = 0
        If akTextHolderAliases != None
            While i < akTextHolderAliases.Length
                SystemMessageAliasEntry kAliasEntry = akTextHolderAliases[i]
                kAliasEntry.MessageEntryIndex = iIndex
                _entryReferences.Add(kAliasEntry)

                i += 1
            EndWhile
        EndIf
    Else
        LogWarnGlobal(Self, "Message with the following name is already registered: " + akEntry.EditorId)
    EndIf
EndFunction

Function UnregisterMessage(String asEditorId = "", \
                            Message akMessage = None)
    Int iIndex = -1
    If asEditorId != ""
        iIndex = _entries.FindStruct("EditorId", asEditorId)                        
    EndIf

    If !IsNone(akMessage) && iIndex < 0
        iIndex = _entries.FindStruct("Entry", akMessage)
    EndIf

    If iIndex > -1
        Var[] kArgs = new Var[0]
        kArgs.Add(_entries[iIndex])
        SendCustomEvent("OnRegister", kArgs)

        _entries.Remove(iIndex)

        SystemMessageAliasEntry[] kRefEntries = _entryReferences.GetAllMatchingStructs("MessageEntryIndex", iIndex)
        If kRefEntries.Length == 0
            return
        EndIf

        Int i = 0
        While i < kRefEntries.Length
            SystemMessageAliasEntry kAlias = kRefEntries[i]
            Int rIndex = -1
            rIndex = _entryReferences.Find(kAlias)
            If rIndex > -1
                _entryReferences.Remove(rIndex)
            EndIf

            i += 1
        EndWhile
    EndIf
EndFunction

Function UnregisterEntry(SystemMessageEntry akEntry)
    Int iIndex = _entries.Find(akEntry)                      
    If iIndex > -1
        Var[] kArgs = new Var[0]
        kArgs.Add(_entries[iIndex])
        SendCustomEvent("OnRegister", kArgs)

        _entries.Remove(iIndex)

        SystemMessageAliasEntry[] kRefEntries = _entryReferences.GetAllMatchingStructs("MessageEntryIndex", iIndex)
        If kRefEntries.Length == 0
            return
        EndIf

        Int i = 0
        While i < kRefEntries.Length
            SystemMessageAliasEntry kAlias = kRefEntries[i]
            Int rIndex = -1
            rIndex = _entryReferences.Find(kAlias)
            If rIndex > -1
                _entryReferences.Remove(rIndex)
            EndIf

            i += 1
        EndWhile
    EndIf
EndFunction

Int Function Show(String asEditorId, \
                    Float[] afArgs = None, \
                    ObjectReference[] akTextHolderRefs = None)
    WaitForInitialized()
    
    Int iResult = -1
    Int iIndex = _entries.FindStruct("EditorId", asEditorId)
    If iIndex < 0
        LogWarnGlobal(Self, "Could not locate a message named: " + asEditorId)
        return iResult
    EndIf

    SystemMessageEntry kEntry = _entries[iIndex]
    ReferenceAlias[] kTextHolderAliases = _GetMessageAliases(iIndex)

    If !kEntry.AlwaysShow && kEntry.TimesShown > 0
        LogWarnGlobal(Self, "Message has been shown the Maximum allowed amount." + \
                                "\n\tEditorId: " + kEntry.EditorId + \
                                "\n\tMessage: " + kEntry.Entry + \
                                "\n\tAlwaysShow: " + kEntry.AlwaysShow + \
                                "\n\tPriority: " + kEntry.Priority + \
                                "\n\tDelayTime: " + kEntry.DelayTime + \
                                "\n\tDuration: " + kEntry.Duration + \
                                "\n\tInterval: " + kEntry.Interval + \
                                "\n\tMaxTimes: " + kEntry.MaxTimes)
    EndIf

    Int iTimerId = _queueTimerId + iIndex 
    int iTimerIdLimit = _queueTimerId + _queueTimerIdMax
    While _queueTimerIds.Find(iTimerId) > -1
        _queueTimerIds.Add(iTimerId)
        iTimerId += 1
        If iTimerId >= iTimerIdLimit
            iTimerId = _queueTimerId
        EndIf
    EndWhile

    SystemMessageQueueEntry kQueueEntry = _CreateQueueEntry(iTimerId, \
                                                            kEntry, \
                                                            afArgs, \
                                                            kTextHolderAliases, \
                                                            akTextHolderRefs)

    If kEntry.IsMessageBox        
        iResult = _ShowMessage(kQueueEntry)
        kQueueEntry.Delete()
    Else
        _queueTimerIds.Add(iTimerId)
        _queue.Add(kQueueEntry)     
        StartTimer(kEntry.DelayTime, kQueueEntry.TimerId)

        iResult = 0
    EndIf

    return iResult
EndFunction

Bool Function _Main()
    ; Int i = 0
    ; SystemMessageQueueEntry[] kQueue = _queue
    ; While i < kQueue.Length
    ;     SystemMessageQueueEntry kEntry = _queue[i]

    ;     _ShowMessage(kEntry)

    ;     _queue.Remove(i)
    ;     kEntry.Delete()
    ;     i += 1
    ; EndWhile

    If GetCount() < Modules.ModuleRegistry.GetSize()
        Int i = 0
        While i < Modules.GetArray().Length
            AddRef(Modules.GetAt(i))
            i += 1
        EndWhile

        ; RefillAlias()
        return True
    EndIf

    return False
EndFunction

Int Function _ShowMessage(SystemMessageQueueEntry kEntry)    
    LogObjectGlobal(Self, "Processing System Messages." + \
                            "\n\tEditorId: " + kEntry.MessageEntry.EditorId + \
                            "\n\tMessage: " + kEntry.MessageEntry.Entry + \
                            "\n\tAlwaysShow: " + kEntry.MessageEntry.AlwaysShow + \
                            "\n\tPriority: " + kEntry.MessageEntry.Priority + \
                            "\n\tDelayTime: " + kEntry.MessageEntry.DelayTime + \
                            "\n\tDuration: " + kEntry.MessageEntry.Duration + \
                            "\n\tInterval: " + kEntry.MessageEntry.Interval + \
                            "\n\tMaxTimes: " + kEntry.MessageEntry.MaxTimes)
    Var[] kArgs = new Var[0]
    kArgs.Add(kEntry.MessageEntry)
    SendCustomEvent("OnShow", kArgs)

    return kEntry.Show()
EndFunction

Bool Function _InitializeObject()
    return _CreateCollections()
EndFunction

Bool Function _CreateCollections()
    ; If IsNone(ModuleTracker) || !IsNone(ModuleTracker.PrimaryModule)
    ;     return False
    ; EndIf

    If _entries == None
        _entries = new SystemMessageEntry[0]
    EndIf

    If _entryReferences == None
        ; SystemModuleInformation kMod = ModInfoAlias.GetReference() as SystemModuleInformation
        ; _entryReferences = HTG:Collections:Dictionary.Dictionary(kMod)
        _entryReferences = new SystemMessageAliasEntry[0]
    EndIf

    If _queueTimerIds == None
        _queueTimerIds = new Int[0]
    EndIf

    return True
    
    ; return (_entries != None && _entries.Length >= 0) \
    ;         && (_entryReferences != None && _entryReferences.Length >= 0) ; (!IsNone(_entryReferences) && _entryReferences.IsInitialized)
EndFunction

SystemMessageQueueEntry Function _CreateQueueEntry(Int aiTimerId, \
                                    SystemMessageEntry akEntry, \                                            
                                    Float[] afArgs = None, \
                                    ReferenceAlias[] akTextHolderAlias = None, \
                                    ObjectReference[] akTextHolder = None)
    SystemMessageQueueEntry kQueueEntry = HTG:SystemMessageQueueEntry.SystemMessageQueueEntry(Modules.PrimaryModule.GetReference(), \ 
                                                                                                aiTimerId, \
                                                                                                akEntry, \
                                                                                                afArgs, \
                                                                                                akTextHolderAlias, \
                                                                                                akTextHolder)
    return kQueueEntry                                                                                        
EndFunction

ReferenceAlias[] Function _GetMessageAliases(Int aiEntry)
    SystemMessageAliasEntry[] kRefEntries = _entryReferences.GetAllMatchingStructs("MessageEntryIndex", aiEntry)
    If kRefEntries.Length == 0
        return None
    EndIf

    ReferenceAlias[] kReferences = new ReferenceAlias[kRefEntries.Length]
    Int i = 0
    While i < kRefEntries.Length
        kReferences[i] = kRefEntries[i].Entry
        i += 1
    EndWhile

    return kReferences
EndFunction

Bool Function _WaitForInitialized()
    Int currentCycle = 0
    Int maxCycle = 600
    Bool maxCycleHit

    ; StartTimer(_timerInterval, _initializeTimerId)

    While !maxCycleHit
        WaitExt(0.1)
        If !Initialize() \ 
            && currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile

    return IsInitialized
EndFunction