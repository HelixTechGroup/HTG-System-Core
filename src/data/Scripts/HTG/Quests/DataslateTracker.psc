Scriptname HTG:Quests:DataslateTracker extends HTG:ReferenceAliasExt
{Regenesys - System Controller Player Reference Alias that tracks the current dataslate item reference}
import HTG
import HTG:UtilityExt

ReferenceAlias Property PlayerRef Mandatory Const Auto
Potion Property Dataslate Auto Const Mandatory
GlobalVariable Property FirstActivation Mandatory Auto
Message Property DataslateAdded Mandatory Const Auto

Bool _isPlayerInitialized

Event OnAliasStarted()
    Parent.OnAliasStarted()

    If FirstActivation.GetValueInt() == 1
        GetOwningQuest().SetStage(5)
        GetOwningQuest().SetObjectiveActive(5, True)
        ; GetOwningQuest().SetObjectiveDisplayed(5)
        ; FirstActivation.SetValue(0)
    EndIf

    Actor kActor = PlayerRef.GetActorReference()
    If !IsFilled()
        kActor.AddAliasedItemSingle(Dataslate, Self, abSilent = False)
    Else
        DataslateAdded.Show()
    EndIf
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    WaitForInitialized()

    If akBaseObject == Dataslate
        If FirstActivation.GetValueInt() == 1
            GetOwningQuest().SetStage(5)
        EndIf

        Actor kActor = akSender ; PlayerRef.GetActorReference()
        ObjectReference kLastRef = GetRef()
        Logger.Log("OnItemAdded Current Dataslate Reference: " + kLastRef)
        kActor.RemoveItem(akBaseObject)
        ; RemoveFromRef(kLastRef)        
        ObjectReference kNewRef = kActor.AddAliasedItemSingle(Dataslate, Self)
        ; RefillDependentAliases()
        Logger.Log("OnItemAdded Updated Dataslate Reference: " + kNewRef)
        Logger.Log("OnItemAdded Dataslate Reference: " +  GetRef())
    EndIf
EndEvent

Event Actor.OnItemUnequipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    WaitForInitialized()
    ; If akBaseObject == Dataslate
    ;     ObjectReference kLastRef = GetRef()
    ;     Logger.Log("OnItemAdded Current Dataslate Reference: " + kLastRef)
    ;     ; Game.GetPlayer().RemoveItem(akBaseObject)
    ;     ; RemoveFromRef(kLastRef)        
    ;     ObjectReference kNewRef = Game.GetPlayer().AddAliasedItemSingle(Dataslate, Self)
    ;     RefillDependentAliases()
    ;     Logger.Log("OnItemAdded Updated Dataslate Reference: " + kNewRef)
    ; EndIf
EndEvent

Event ObjectReference.OnItemRemoved(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer, int aiTransferReason)    
    If akBaseItem == Dataslate \
        && FirstActivation.GetValueInt() == 1
        GetOwningQuest().SetObjectiveCompleted(5)
        FirstActivation.SetValue(0)
    EndIf
EndEvent

; Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer, int aiTransferReason)
;     Logger.Log("akBaseItem: " + akBaseItem)
;     If akBaseItem == Dataslate
;         ObjectReference kLastRef = GetRef()
;         Logger.Log("OnItemAdded Current Dataslate Reference: " + kLastRef)

;         ForceRefTo(akItemReference)
;         Logger.Log("OnItemAdded Updated Dataslate Reference.")
;     Endif
; EndEvent

Bool Function _RegisterEvents()
    Actor kActor = Game.GetPlayer()
    ObjectReference kRef = kActor as ObjectReference
    If !IsNone(PlayerRef)
        kRef = PlayerRef.GetReference()
        kActor = PlayerRef.GetActorReference()
    EndIf

    AddInventoryEventFilter(Dataslate)
    RegisterForRemoteEvent(kActor, "OnItemEquipped")
    RegisterForRemoteEvent(kActor, "OnItemUnequipped")
    RegisterForRemoteEvent(kRef, "OnItemRemoved")

    return True
EndFunction

Bool Function _UnregisterEvents()
    Actor kActor = Game.GetPlayer()
    ObjectReference kRef = kActor as ObjectReference
    If !IsNone(PlayerRef)
        kRef = PlayerRef.GetReference()
        kActor = PlayerRef.GetActorReference()
    EndIf

    UnregisterForRemoteEvent(kActor, "OnItemEquipped")
    UnregisterForRemoteEvent(kActor, "OnItemUnequipped")
    UnregisterForRemoteEvent(kRef, "OnItemRemoved")
    RemoveInventoryEventFilter(Dataslate)

    return True
EndFunction