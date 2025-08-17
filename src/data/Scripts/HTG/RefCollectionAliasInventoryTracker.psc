Scriptname HTG:RefCollectionAliasInventoryTracker extends HTG:RefCollectionAliasExt
import HTG
import HTG:UtilityExt
import HTG:Quests

Bool Property DisableTracking Auto Hidden

Bool Property IsTrackingDisabled Hidden
    Bool Function Get()
        return DisableTracking    
    EndFunction
EndProperty

FormList Property ExcludedItems Const Auto

Guard _equipGuard ProtectsFunctionLogic
Guard _unequipGuard ProtectsFunctionLogic
Guard _addedGuard ProtectsFunctionLogic
Guard _removedGuard ProtectsFunctionLogic
Bool _equipHandled
Bool _unequipHandled
Bool _addHandled
Bool _removeHandled

CustomEvent OnAliasItemAdded
CustomEvent OnAliasItemRemoved
CustomEvent OnAliasItemEquipped
CustomEvent OnAliasItemUnequipped

Event OnAliasChanged(ObjectReference akObject, bool abRemove)
    Parent.OnAliasChanged(akObject, abRemove)
    
    Actor kActor = akObject as Actor
    Logger.Log("OnAliasChanged:Actor: " + kActor)

    If !abRemove
        Logger.Log("OnAliasChanged:Registering: " + kActor)
        _RegisterItemEvents(akObject)
    Else
        Logger.Log("OnAliasChanged:Unregistering: " + kActor)
        _UnregisterItemEvents(akObject)
    EndIf

    Logger.LogRefCollectionAlias(Self, Self as RefCollectionAlias)
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
        || (!IsNone(ExcludedItems) && ExcludedItems.Find(akBaseObject) > -1); If _equipHandled
        return
    EndIf

    Actor kActor = akSenderRef as Actor
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

Function _HandleItemEquipped(Actor akActor, Form akBaseObject)
    
EndFunction

Function _HandleItemUnequipped(Actor akActor, Form akItem)
    
EndFunction

Function _HandleItemAdded(Actor akActor, Form akItem)

EndFunction

Function _HandleItemRemoved(Actor akActor, Form akItem)
    
EndFunction

Function _RegisterItemEvents(ObjectReference akObject)
    Actor kActor = akObject as Actor
    AddInventoryEventFilter(None)
    RegisterForRemoteEvent(kActor,  "OnItemEquipped")
    RegisterForRemoteEvent(kActor, "OnItemUnequipped")
    RegisterForRemoteEvent(akObject, "OnItemAdded")
    RegisterForRemoteEvent(akObject, "OnItemRemoved")
EndFunction

Function _UnregisterItemEvents(ObjectReference akObject)
    Actor kActor = akObject as Actor
    RemoveInventoryEventFilter(None)
    UnregisterForRemoteEvent(kActor, "OnItemEquipped")
    UnregisterForRemoteEvent(kActor, "OnItemUnequipped")
    UnregisterForRemoteEvent(akObject, "OnItemAdded")
    UnregisterForRemoteEvent(akObject, "OnItemRemoved")
EndFunction