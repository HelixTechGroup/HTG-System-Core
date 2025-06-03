Scriptname HTG:Quests:DataslateTracker extends HTG:ReferenceAliasExt
{Regenesys - System Controller Player Reference Alias that tracks the current dataslate item reference}
import HTG

; ObjectReference Property PlayerRef Mandatory Const Auto
Potion Property Dataslate Auto Const Mandatory
GlobalVariable Property FirstActivation Mandatory Auto

Bool _isPlayerInitialized

Event OnAliasInit()
    WaitForInitialized()

    Game.GetPlayer().AddAliasedItemSingle(Dataslate, Self, abSilent = False)
    ; RefillDependentAliases()
    ; Debug.Notification("Dataslate Configurator has been added.")
    RegisterForRemoteEvent(Game.GetPlayer(), "OnItemEquipped")
    RegisterForRemoteEvent(Game.GetPlayer(), "OnItemUnequipped")
EndEvent

Event OnAliasShutdown()
    UnregisterForRemoteEvent(Game.GetPlayer(), "OnItemEquipped")
    UnregisterForRemoteEvent(Game.GetPlayer(), "OnItemUnequipped")
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    If akBaseObject == Dataslate
        If FirstActivation.GetValueInt() == 1
            GetOwningQuest().SetObjectiveCompleted(5)
            FirstActivation.SetValue(0)
        EndIf

        ObjectReference kLastRef = GetRef()
        Logger.Log("OnItemAdded Current Dataslate Reference: " + kLastRef)
        Game.GetPlayer().RemoveItem(akBaseObject)
        ; RemoveFromRef(kLastRef)        
        ObjectReference kNewRef = Game.GetPlayer().AddAliasedItemSingle(Dataslate, Self)
        ; RefillDependentAliases()
        Logger.Log("OnItemAdded Updated Dataslate Reference: " + kNewRef)
        Logger.Log("OnItemAdded Dataslate Reference: " +  GetRef())
    EndIf
EndEvent

Event Actor.OnItemUnequipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
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

; Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer, int aiTransferReason)
;     Logger.Log("akBaseItem: " + akBaseItem)
;     If akBaseItem == Dataslate
;         ObjectReference kLastRef = GetRef()
;         Logger.Log("OnItemAdded Current Dataslate Reference: " + kLastRef)

;         ForceRefTo(akItemReference)
;         Logger.Log("OnItemAdded Updated Dataslate Reference.")
;     Endif
; EndEvent