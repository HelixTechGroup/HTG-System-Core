Scriptname HTG:RefCollectionAliasInventoryTracker extends HTG:RefCollectionAliasExt
import HTG
import HTG:UtilityExt
import HTG:Quests
import HTG:Collections

ObjectReferenceList Property InitializedReferences Auto Hidden
Message Property InitializedReferenceMessage Mandatory Const Auto
Message Property InitializingReferenceMessage Mandatory Const Auto
ReferenceAlias Property InitializedTextHolder Mandatory Const Auto  

Bool Property DisableTracking Auto Hidden

Bool Property IsTrackingDisabled Hidden
    Bool Function Get()
        return DisableTracking    
    EndFunction
EndProperty

Bool Property IsTrackingInitialized Hidden
    Bool Function Get()
        return _isTrackingInitialized
    EndFunction
EndProperty

FormList Property ExcludedItems Const Auto

Guard _equipGuard ProtectsFunctionLogic
Guard _unequipGuard ProtectsFunctionLogic
Guard _addedGuard ProtectsFunctionLogic
Guard _removedGuard ProtectsFunctionLogic
Guard _registerTimerGuard ProtectsFunctionLogic
Guard _unregisterTimerGuard ProtectsFunctionLogic
Bool _equipHandled
Bool _unequipHandled
Bool _addHandled
Bool _removeHandled
Bool _isTrackingInitialized
Bool _initializationStarted
Bool _registrationStarted
Bool _registerTimerStarted
Bool _unregistrationStarted
Bool _unregisterTimerStarted
Int _registerTimerId = 1
Int _unregisterTimerId = 2
Int _registeredCount
ObjectReferenceList _registeringReferences   
ObjectReferenceList _initializingReferences   
ObjectReferenceList _unregisteringReferences   

CustomEvent OnAliasItemAdded
CustomEvent OnAliasItemRemoved
CustomEvent OnAliasItemEquipped
CustomEvent OnAliasItemUnequipped
CustomEvent OnAliasRegistered
CustomEvent OnAliasUnregistered
CustomEvent OnAliasInitialized

Event OnAliasChanged(ObjectReference akObject, bool abRemove)
    Parent.OnAliasChanged(akObject, abRemove)

    Logger.Log("OnAliasChanged:Reference: " + akObject)

    If !abRemove
        Logger.Log("OnAliasChanged:Registering: " + akObject)
        _registeringReferences.Add(akObject)
        StartTimer(Utilities.Timers.Defaults.Interval, _registerTimerId)
    Else
        Logger.Log("OnAliasChanged:Unregistering: " + akObject)
        _unregisteringReferences.Add(akObject)
        StartTimer(Utilities.Timers.Defaults.Interval, _unregisterTimerId)
    EndIf

    Logger.LogRefCollectionAlias(Self, Self as RefCollectionAlias)
EndEvent

Event OnTimer(int aiTimerID)
    Parent.OnTimer(aiTimerID)

    If aiTimerID == _registerTimerId
        If !IsInitialized || _registerTimerStarted || _registrationStarted
            Logger.Log("RegisterReferencesTimer - Is Not Initialized, Initial Run or Timer is already running. Not ready to proceed.")

            Float iTimerInterval = Utilities.Timers.Defaults.Interval + 0.9
            StartTimer(iTimerInterval, _registerTimerId)
            return
        EndIf

        Bool startMain
        TryLockGuard _registerTimerGuard
            _registerTimerStarted = True
            startMain = _RegisterReferences()
            _registerTimerStarted = False
        EndTryLockGuard

        If startMain
            Logger.Log("RegisterReferenceTimer - Starting MainTimer.")
            StartTimer(Utilities.Timers.Defaults.Interval, Utilities.Timers.SystemIds.MainId)
        ElseIf _registeringReferences.Count > 0
            StartTimer(Utilities.Timers.Defaults.Interval, _registerTimerId)
        EndIf
    ElseIf aiTimerID == _unregisterTimerId
        If !IsInitialized || _unregisterTimerStarted || _unregistrationStarted
            Logger.Log("UnregisterReferencesTimer - Is Not Initialized, Initial Run or Timer is already running. Not ready to proceed.")

            Float iTimerInterval = Utilities.Timers.Defaults.Interval + 0.9
            StartTimer(iTimerInterval, _unregisterTimerId)
            return
        EndIf

        TryLockGuard _unregisterTimerGuard
            _unregisterTimerStarted = True
            _UnregisterReferences()
            _unregisterTimerStarted = False
        EndTryLockGuard

        If _unregisteringReferences.Count > 0
            StartTimer(Utilities.Timers.Defaults.Interval, _unregisterTimerId)
        EndIf
    EndIf
EndEvent

Event OnItemAdded(ObjectReference akSenderRef, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer, int aiTransferReason)
    WaitForInitialized()

    If DisableTracking \
        || (!IsNone(ExcludedItems) && ExcludedItems.Find(akBaseItem) > -1); If _equipHandled
        return
    EndIf

    Actor kActor = akSenderRef as Actor
    Logger.Log("OnItemEquipped:Actor:" + kActor)
    Logger.Log("OnItemEquipped:Form:" + akBaseItem)
    Logger.Log("OnItemEquipped:Reference:" + akItemReference)



    TryLockGuard _addedGuard
        _addHandled = True
        _HandleItemAdded(kActor, akBaseItem)

        Var[] kArgs = new Var[0]
        kArgs.Add(kActor)
        kArgs.Add(akBaseItem)
        SendCustomEvent("OnAliasItemAdded", kArgs)
        _addHandled = False
    EndTryLockGuard
EndEvent

Event OnItemRemoved(ObjectReference akSenderRef, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer, int aiTransferReason)
    WaitForInitialized()

    If DisableTracking \
        || (!IsNone(ExcludedItems) && ExcludedItems.Find(akBaseItem) > -1) ; If _equipHandled
        return
    EndIf

    Actor kActor = akSenderRef as Actor
    If IsNone(kActor)
        return
    EndIf

    Logger.Log("OnItemEquipped:Actor:" + kActor)
    Logger.Log("OnItemEquipped:Form:" + akBaseItem)
    Logger.Log("OnItemEquipped:Reference:" + akItemReference)

    TryLockGuard _removedGuard
        _removeHandled = True
        _HandleItemRemoved(kActor, akBaseItem)

        Var[] kArgs = new Var[0]
        kArgs.Add(kActor)
        kArgs.Add(akBaseItem)
        SendCustomEvent("OnAliasItemRemoved", kArgs)
        _removeHandled = False
    EndTryLockGuard
EndEvent

Event OnItemEquipped(ObjectReference akSenderRef, Form akBaseObject, ObjectReference akReference)
    WaitForInitialized()

    If DisableTracking \
        || (!IsNone(ExcludedItems) && ExcludedItems.Find(akBaseObject) > -1) ; If _equipHandled
        return
    EndIf

    Actor kActor = akSenderRef as Actor
    If IsNone(kActor)
        return
    EndIf

    Logger.Log("OnItemEquipped:Actor:" + kActor)
    Logger.Log("OnItemEquipped:Form:" + akBaseObject)
    Logger.Log("OnItemEquipped:Reference:" + akReference)

    TryLockGuard _equipGuard
        _equipHandled = True
        _HandleItemEquipped(kActor, akBaseObject)

        Var[] kArgs = new Var[0]
        kArgs.Add(kActor)
        kArgs.Add(akBaseObject)
        SendCustomEvent("OnAliasItemEquipped", kArgs)
        _equipHandled = False
    EndTryLockGuard
EndEvent

Event OnItemUnequipped(ObjectReference akSenderRef, Form akBaseObject, ObjectReference akReference)
    WaitForInitialized()

    If DisableTracking \
        || (!IsNone(ExcludedItems) && ExcludedItems.Find(akBaseObject) > -1); _unequipHandled
        return
    EndIf

    Actor kActor = akSenderRef as Actor
    Logger.Log("OnItemUnequipped:Actor: " + kActor)
    Logger.Log("OnItemUnequipped:Form: " + akBaseObject)
    Logger.Log("OnItemUnequipped:Reference: " + akReference)

    TryLockGuard _unequipGuard
        _unequipHandled = True
        _HandleItemUnequipped(kActor, akBaseObject)

        Var[] kArgs = new Var[0]
        kArgs.Add(kActor)
        kArgs.Add(akBaseObject)
        SendCustomEvent("OnAliasItemUnequipped", kArgs)    
        _unequipHandled = False
    EndTryLockGuard
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    OnItemEquipped(akSender, akBaseObject, akReference)
EndEvent

Event Actor.OnItemUnequipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    OnItemUnequipped(akSender, akBaseObject, akReference)
EndEvent

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer, int aiTransferReason)
    OnItemAdded(akSender, akBaseItem, aiItemCount, akItemReference, akSourceContainer, aiTransferReason)
EndEvent

Event ObjectReference.OnItemRemoved(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer, int aiTransferReason)
    OnItemRemoved(akSender, akBaseItem, aiItemCount, akItemReference, akSourceContainer, aiTransferReason)
EndEvent

Event HTG:ReferenceAliasInventoryTracker.OnAliasItemEquipped(HTG:ReferenceAliasInventoryTracker akSender, Var[] akArgs)
    WaitForInitialized()
EndEvent

Event HTG:ReferenceAliasInventoryTracker.OnAliasItemUnequipped(HTG:ReferenceAliasInventoryTracker akSender, Var[] akArgs)
    WaitForInitialized()
EndEvent

Event HTG:ReferenceAliasInventoryTracker.OnAliasItemAdded(HTG:ReferenceAliasInventoryTracker akSender, Var[] akArgs)
    WaitForInitialized()
EndEvent

Event HTG:ReferenceAliasInventoryTracker.OnAliasItemRemoved(HTG:ReferenceAliasInventoryTracker akSender, Var[] akArgs)
    WaitForInitialized()
EndEvent

Event HTG:RefCollectionAliasInventoryTracker.OnAliasRegistered(HTG:RefCollectionAliasInventoryTracker akSender, var[] akArgs)
    WaitForInitialized()
EndEvent

Event HTG:RefCollectionAliasInventoryTracker.OnAliasUnregistered(HTG:RefCollectionAliasInventoryTracker akSender, var[] akArgs)
    WaitForInitialized()
EndEvent

Event HTG:RefCollectionAliasInventoryTracker.OnAliasInitialized(HTG:RefCollectionAliasInventoryTracker akSender, var[] akArgs)
    WaitForInitialized()
EndEvent

Bool Function WaitForTrackingStart()
    WaitForInitialized()

    If _isTrackingInitialized
        return True
    EndIf
    
    Int currentCycle = 0
    Int maxCycle = 600
    Bool maxCycleHit

    ; StartTimer(_timerInterval, _initializeTimerId)
    While !maxCycleHit && !_isTrackingInitialized
        WaitExt(0.5)

        If currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile

    return _isTrackingInitialized
EndFunction

Bool Function IsReferenceRegistering(ObjectReference akObject)
    return _registeringReferences.Contains(akObject)
EndFunction

Bool Function IsReferenceUnregistering(ObjectReference akObject)
    return _unregisteringReferences.Contains(akObject)
EndFunction

Bool Function IsReferenceInitializing(ObjectReference akObject)
    return _initializingReferences.Contains(akObject)
EndFunction

Bool Function RegisterReference(ObjectReference akObject)
    If Find(akObject) < 0
        AddRef(akObject)
        return True
    EndIf

    _registeringReferences.Add(akObject)
    StartTimer(Utilities.Timers.Defaults.Interval, _registerTimerId)
    
    return IsReferenceRegistering(akObject)
EndFunction

Bool Function UnregisterReference(ObjectReference akObject)
    If Find(akObject) < 0
        return False
    EndIf

    RemoveRef(akObject)
EndFunction

Bool Function _CreateCollections()
    If IsNone(_registeringReferences)
        _registeringReferences = HTG:Collections:ObjectReferenceList.ObjectReferenceList(Utilities.ModInfo)
    Else
        _registeringReferences.Clear()
    EndIf    

    If IsNone(_unregisteringReferences)
        _unregisteringReferences = HTG:Collections:ObjectReferenceList.ObjectReferenceList(Utilities.ModInfo)
    Else
        _unregisteringReferences.Clear()
    EndIf    

    If IsNone(_initializingReferences)
        _initializingReferences = HTG:Collections:ObjectReferenceList.ObjectReferenceList(Utilities.ModInfo)
    Else
        _initializingReferences.Clear()
    EndIf  

    If IsNone(InitializedReferences)
        InitializedReferences = HTG:Collections:ObjectReferenceList.ObjectReferenceList(Utilities.ModInfo)
    Else
        InitializedReferences.Clear()
    EndIf

    return (!IsNone(_registeringReferences) && _registeringReferences.IsInitialized) \
            && (!IsNone(_unregisteringReferences) && _unregisteringReferences.IsInitialized) \
            && (!IsNone(_initializingReferences) && _initializingReferences.IsInitialized) \
            && (!IsNone(InitializedReferences) && InitializedReferences.IsInitialized)
EndFunction

Bool Function _Main()
    return _InitializeReferences()
EndFunction

Function _HandleItemEquipped(Actor akActor, Form akBaseObject)
    
EndFunction

Function _HandleItemUnequipped(Actor akActor, Form akItem)
    
EndFunction

Function _HandleItemAdded(Actor akActor, Form akItem)

EndFunction

Function _HandleItemRemoved(Actor akActor, Form akItem)
    
EndFunction

Bool Function _RegisterReferences()
    If !IsInitialized || _registrationStarted
        return False
    EndIf
    
    WaitForCombatEnd()

    _registrationStarted = True
    Bool bResult
    Int fI = 0
    Int fCount = _registeringReferences.Count ; GetCount()
    ; Var[] kReferences = _registeringReferences.GetArray()
    Logger.Log("RegisterReferenceTimer - Found Tracked references.")
    While fI < fCount
        ObjectReference kObject = _registeringReferences.GetVarAt(fI) as ObjectReference ; kReferences[fI] as ObjectReference
        Logger.Log("RegisterTimer - Checking reference: " + kObject)
        If !IsNone(kObject)
            Logger.Log("RegisterTimer - Adding reference: " + kObject)
            If _RegisterReference(kObject)
                Var[] kArgs = new Var[0]
                kArgs.Add(kObject)
                SendCustomEvent("OnAliasRegistered", kArgs)

                _registeredCount += 1
                _RegisterItemEvents(kObject)
                _registeringReferences.Remove(kObject)
                _initializingReferences.Add(kObject)
                Logger.Log("RegisterTimer - Registered reference: " + kObject)
            EndIf
        EndIf
        fI += 1
    EndWhile

    _registrationStarted = False
    return True
EndFunction

Bool Function _RegisterReference(ObjectReference akObject)
    return True
EndFunction

Bool Function _UnregisterReferences()
    If !IsInitialized || _unregistrationStarted
        return False
    EndIf
    
    WaitForCombatEnd()

    _unregistrationStarted = True
    Bool bResult
    Int fI = 0
    Int fCount = _unregisteringReferences.Count ; GetCount()
    ; Var[] kReferences = _unregisteringReferences.GetArray()
    Logger.Log("UnregisterTimer - Found Tracked reference.")
    While fI < fCount
        ObjectReference kObject = _unregisteringReferences.GetVarAt(fI) as ObjectReference ; References[fI] as ObjectReference
        Logger.Log("UnregisterTimer - Checking reference: " + kObject)
        If !IsNone(kObject)
            Logger.Log("UnregisterTimer - Removing reference: " + kObject)
            If _UnregisterReference(kObject)
                Var[] kArgs = new Var[0]
                kArgs.Add(kObject)
                SendCustomEvent("OnAliasUnregistered", kArgs)

                _registeredCount -= 1
                _UnregisterItemEvents(kObject)
                InitializedReferences.Remove(kObject)
                _unregisteringReferences.Remove(kObject)
                _registeringReferences.Remove(kObject)
                _initializingReferences.Remove(kObject)
            EndIf
        EndIf
        fI += 1
    EndWhile

    _unregistrationStarted = False
    return True
EndFunction

Bool Function _UnregisterReference(ObjectReference akObject)
    return True
EndFunction

Function _RegisterItemEvents(ObjectReference akObject)
    Actor kActor = akObject as Actor
    AddInventoryEventFilter(None)

    If !IsNone(kActor)
        RegisterForRemoteEvent(kActor,  "OnItemEquipped")
        RegisterForRemoteEvent(kActor, "OnItemUnequipped")
    EndIf

    RegisterForRemoteEvent(akObject, "OnItemAdded")
    RegisterForRemoteEvent(akObject, "OnItemRemoved")
EndFunction

Function _UnregisterItemEvents(ObjectReference akObject)
    Actor kActor = akObject as Actor
    RemoveInventoryEventFilter(None)

    If !IsNone(kActor)
        UnregisterForRemoteEvent(kActor, "OnItemEquipped")
        UnregisterForRemoteEvent(kActor, "OnItemUnequipped")
    EndIf

    UnregisterForRemoteEvent(akObject, "OnItemAdded")
    UnregisterForRemoteEvent(akObject, "OnItemRemoved")
EndFunction

Bool Function _InitializeReferences()
    If !IsInitialized || _registrationStarted || _initializationStarted
        return True
    EndIf

    _initializationStarted = True
    Int fI = 0
    Int fCount = _initializingReferences.Count ; GetCount()
    Var[] kReferences = _initializingReferences.GetArray()
    Logger.Log("RegisterReferenceTimer - Found Tracked references.")
    Message.ClearHelpMessages()
    InitializingReferenceMessage.ShowAsHelpMessage("followerInit", 30.0, 30.0, fCount)

    While fI < fCount
        ObjectReference kObject = kReferences[fI] as ObjectReference  ; kReferences[fI] as ObjectReference
        InitializedTextHolder.ForceRefTo(kObject)
        Logger.Log("RegisterTimer - Checking reference: " + kObject)

        If !IsNone(kObject) && !InitializedReferences.Contains(kObject)
            Logger.Log("RegisterTimer - Adding reference: " + kObject)
            If _InitializeReference(kObject)
                Var[] kArgs = new Var[0]
                kArgs.Add(kObject)
                SendCustomEvent("OnAliasInitialized", kArgs)

                _initializingReferences.Remove(kObject)
                InitializedReferences.Add(kObject)
                InitializedTextHolder.ForceRefTo(kObject)
                ;ShowMessage(InitializedReferenceMessage)
                InitializedReferenceMessage.Show()
                InitializedTextHolder.Clear()
            EndIf
        Else
            _initializingReferences.Remove(kObject)
        EndIf
        fI += 1
    EndWhile

    If InitializedReferences.Count >= GetCount()
        _isTrackingInitialized = True
        InitializedTextHolder.Clear()
        InitializingReferenceMessage.UnshowAsHelpMessage()
        Message.ResetHelpMessage("followerInit")
    EndIf

    _initializationStarted = False
    
    If _initializingReferences.Count > 0
        return True
    Else
        Message.ClearHelpMessages()
        ; Message.ResetHelpMessage(asEvent)
    EndIf

    return False
EndFunction

Bool Function _InitializeReference(ObjectReference akObject)
    return True
EndFunction