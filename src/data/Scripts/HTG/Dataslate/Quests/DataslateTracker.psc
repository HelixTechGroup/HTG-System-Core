ScriptName HTG:Dataslate:Quests:DataslateTracker Extends HTG:ReferenceAliasExt
{ Regenesys - System Controller Player Reference Alias that tracks the current potion item reference }

;-- Variables ---------------------------------------
Bool _isPlayerInitialized

;-- Properties --------------------------------------
Potion Property Dataslate Auto Const mandatory
GlobalVariable Property FirstActivation Auto mandatory

;-- Functions ---------------------------------------

Event Actor.OnItemUnequipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
  ; Empty function
EndEvent

Event OnAliasInit()
  Self.WaitForInitialized() ; #DEBUG_LINE_NO:12
  Game.GetPlayer().AddAliasedItemSingle(Dataslate as Form, Self as Alias, False) ; #DEBUG_LINE_NO:14
  Self.RegisterForRemoteEvent(Game.GetPlayer() as ScriptObject, "OnItemEquipped") ; #DEBUG_LINE_NO:17
  Self.RegisterForRemoteEvent(Game.GetPlayer() as ScriptObject, "OnItemUnequipped") ; #DEBUG_LINE_NO:18
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
  If akBaseObject == Dataslate as Form ; #DEBUG_LINE_NO:22
    If FirstActivation.GetValueInt() == 1 ; #DEBUG_LINE_NO:23
      Self.GetOwningQuest().SetObjectiveCompleted(5, True) ; #DEBUG_LINE_NO:24
      FirstActivation.SetValue(0 as Float) ; #DEBUG_LINE_NO:25
    EndIf
    ObjectReference kLastRef = Self.GetRef() ; #DEBUG_LINE_NO:28
    Self.Logger.Log("OnItemAdded Current Dataslate Reference: " + kLastRef as String, 0) ; #DEBUG_LINE_NO:29
    Game.GetPlayer().RemoveItem(akBaseObject, 1, False, None) ; #DEBUG_LINE_NO:30
    ObjectReference kNewRef = Game.GetPlayer().AddAliasedItemSingle(Dataslate as Form, Self as Alias, True) ; #DEBUG_LINE_NO:32
    Self.Logger.Log("OnItemAdded Updated Dataslate Reference: " + kNewRef as String, 0) ; #DEBUG_LINE_NO:34
    Self.Logger.Log("OnItemAdded Dataslate Reference: " + Self.GetRef() as String, 0) ; #DEBUG_LINE_NO:35
  EndIf
EndEvent
