Scriptname HTG:ReferenceAliasInventoryTracker Extends HTG:ReferenceAliasExt
import HTG
import HTG:UtilityExt

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

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer, int aiTransferReason)
    OnItemAdded(akBaseItem, aiItemCount, akItemReference, akSourceContainer, aiTransferReason)
EndEvent

Event ObjectReference.OnItemRemoved(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer, int aiTransferReason)
    OnItemRemoved(akBaseItem, aiItemCount, akItemReference, akSourceContainer, aiTransferReason)
EndEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer, int aiTransferReason)
    WaitForInitialized()

    If DisableTracking \
        || (!IsNone(ExcludedItems) && ExcludedItems.Find(akBaseItem) > -1); _addHandled
        return
    EndIf

    TryLockGuard _addedGuard
        _addHandled = True  
        _HandleItemAdded(akBaseItem)

        Var[] kArgs = new Var[0]
        kArgs.Add(akBaseItem)
        SendCustomEvent("OnAliasItemAdded", kArgs)
        _addHandled = False
    EndTryLockGuard
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer, int aiTransferReason)
    WaitForInitialized()

    If DisableTracking \
        || (!IsNone(ExcludedItems) && ExcludedItems.Find(akBaseItem) > -1); _removeHandled
        return
    EndIf

    TryLockGuard _removedGuard
        _removeHandled = True
        _HandleItemRemoved(akBaseItem)

        Var[] kArgs = new Var[0]
        kArgs.Add(akBaseItem)
        SendCustomEvent("OnAliasItemRemoved", kArgs)
        _removeHandled = False
    EndTryLockGuard
EndEvent

Event OnItemEquipped(Form akBaseObject, ObjectReference akReference)
    WaitForInitialized()        

    If DisableTracking \
        || (!IsNone(ExcludedItems) && ExcludedItems.Find(akBaseObject) > -1); If _equipHandled
        return
    EndIf

    TryLockGuard _equipGuard
        _equipHandled = True
        _HandleItemEquipped(akBaseObject)

        Var[] kArgs = new Var[0]
        kArgs.Add(akBaseObject)
        SendCustomEvent("OnAliasItemEquipped", kArgs)
        _equipHandled = False
    EndTryLockGuard
EndEvent

Event OnItemUnequipped(Form akBaseObject, ObjectReference akReference)
    WaitForInitialized()

    If DisableTracking \
        || (!IsNone(ExcludedItems) && ExcludedItems.Find(akBaseObject) > -1); _unequipHandled
        return
    EndIf

    TryLockGuard _unequipGuard
        _unequipHandled = true
        _HandleItemUnequipped(akBaseObject)

        Var[] kArgs = new Var[0]
        kArgs.Add(akBaseObject)
        SendCustomEvent("OnAliasItemUnequipped", kArgs)    
        _unequipHandled = False
    EndTryLockGuard
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    OnItemEquipped(akBaseObject, akReference)
EndEvent

Event Actor.OnItemUnequipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    OnItemUnequipped(akBaseObject, akReference)
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

Function _HandleItemEquipped(Form akBaseObject)
    
EndFunction

Function _HandleItemUnequipped(Form akItem)
    
EndFunction

Function _HandleItemAdded(Form akItem)

EndFunction

Function _HandleItemRemoved(Form akItem)
    
EndFunction

Bool Function _RegisterEvents()
    If !IsFilled()
        return False
    EndIf
    
    Actor kActor = GetActorReference()
    AddInventoryEventFilter(None)
    RegisterForRemoteEvent(GetReference(), "OnItemAdded")
    RegisterForRemoteEvent(GetReference(), "OnItemRemoved")
    RegisterForRemoteEvent(kActor, "OnItemEquipped")
    RegisterForRemoteEvent(kActor, "OnItemEquipped")
    WaitExt(0.15)

    return True
EndFunction