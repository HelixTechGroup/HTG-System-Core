ScriptName HTG:UtilityExt Extends Utility hidden

;-- Functions ---------------------------------------

Bool Function AddLeveledItemToActor(Actor akActor, LeveledItem akItem, Int count, Bool clearAllExisting, Bool autoEquip, Alias akAlias) Global
  Int c = akActor.GetItemCount(akItem as Form) ; #DEBUG_LINE_NO:4
  Bool equip = False ; #DEBUG_LINE_NO:5
  If c > 0 && clearAllExisting ; #DEBUG_LINE_NO:13
    If equip ; #DEBUG_LINE_NO:14
      akActor.UnequipItem(akItem as Form, False, True) ; #DEBUG_LINE_NO:15
      Utility.Wait(0.333000004) ; #DEBUG_LINE_NO:16
    EndIf
    akActor.RemoveItem(akItem as Form, c, True, None) ; #DEBUG_LINE_NO:19
    Utility.Wait(0.5) ; #DEBUG_LINE_NO:20
  EndIf
  If akAlias ; #DEBUG_LINE_NO:23
    akActor.AddAliasedItem(akItem as Form, akAlias, count, True) ; #DEBUG_LINE_NO:24
  Else
    akActor.AddItem(akItem as Form, count, True) ; #DEBUG_LINE_NO:26
  EndIf
  Utility.Wait(0.666000009) ; #DEBUG_LINE_NO:30
  Int nc = akActor.GetItemCount(akItem as Form) ; #DEBUG_LINE_NO:31
  If nc > 0 ; #DEBUG_LINE_NO:32
    If autoEquip && equip ; #DEBUG_LINE_NO:33
      akActor.EquipItem(akItem as Form, False, True) ; #DEBUG_LINE_NO:34
    EndIf
  EndIf
  Return nc > 0 ; #DEBUG_LINE_NO:39
EndFunction

Bool Function AddItemToActor(Actor actr, Form item, Int count, Bool clearAllExisting, Bool autoEquip, Alias akAlias) Global
  Int c = actr.GetItemCount(item) ; #DEBUG_LINE_NO:43
  Bool equip = False ; #DEBUG_LINE_NO:44
  Armor ta = item as Armor ; #DEBUG_LINE_NO:45
  Weapon w = item as Weapon ; #DEBUG_LINE_NO:46
  If ta as Bool || w as Bool ; #DEBUG_LINE_NO:48
    equip = True ; #DEBUG_LINE_NO:49
  EndIf
  If c > 0 && clearAllExisting ; #DEBUG_LINE_NO:52
    If equip ; #DEBUG_LINE_NO:53
      actr.UnequipItem(item, False, True) ; #DEBUG_LINE_NO:54
      Utility.Wait(0.333000004) ; #DEBUG_LINE_NO:55
    EndIf
    actr.RemoveItem(item, c, True, None) ; #DEBUG_LINE_NO:58
    Utility.Wait(0.5) ; #DEBUG_LINE_NO:59
  EndIf
  If akAlias ; #DEBUG_LINE_NO:62
    actr.AddAliasedItem(item, akAlias, count, True) ; #DEBUG_LINE_NO:63
  Else
    actr.AddItem(item, count, True) ; #DEBUG_LINE_NO:65
  EndIf
  Utility.Wait(0.666000009) ; #DEBUG_LINE_NO:68
  Int nc = actr.GetItemCount(item) ; #DEBUG_LINE_NO:69
  If nc > 0 ; #DEBUG_LINE_NO:70
    If autoEquip && equip ; #DEBUG_LINE_NO:71
      actr.EquipItem(item, False, True) ; #DEBUG_LINE_NO:72
    EndIf
  EndIf
  Return nc > 0 ; #DEBUG_LINE_NO:77
EndFunction

Bool Function EquipItemToActor(Actor actr, Form item) Global
  Int c = actr.GetItemCount(item) ; #DEBUG_LINE_NO:87
  Bool equip = False ; #DEBUG_LINE_NO:88
  Armor ta = item as Armor ; #DEBUG_LINE_NO:89
  Weapon w = item as Weapon ; #DEBUG_LINE_NO:90
  If ta as Bool || w as Bool ; #DEBUG_LINE_NO:92
    equip = True ; #DEBUG_LINE_NO:93
  EndIf
  If c > 0 ; #DEBUG_LINE_NO:96
    If equip ; #DEBUG_LINE_NO:97
      actr.EquipItem(item, False, True) ; #DEBUG_LINE_NO:98
      Utility.Wait(0.666000009) ; #DEBUG_LINE_NO:99
      Return actr.IsEquipped(item) ; #DEBUG_LINE_NO:100
    EndIf
  EndIf
EndFunction

ObjectReference[] Function GetOwnedObjects(RefCollectionAlias collectionAlias, Actor actorOwner) Global
  Int I = 0 ; #DEBUG_LINE_NO:106
  Int count = collectionAlias.GetCount() ; #DEBUG_LINE_NO:108
  ObjectReference[] res = new ObjectReference[count] ; #DEBUG_LINE_NO:109
  Int resI = 0 ; #DEBUG_LINE_NO:110
  While I < count ; #DEBUG_LINE_NO:111
    If actorOwner.IsOwner(collectionAlias.GetAt(I)) ; #DEBUG_LINE_NO:112
      res[resI] = collectionAlias.GetAt(I) ; #DEBUG_LINE_NO:114
      resI += 1 ; #DEBUG_LINE_NO:115
    EndIf
    I += 1 ; #DEBUG_LINE_NO:117
  EndWhile
  Return res ; #DEBUG_LINE_NO:123
EndFunction

ObjectReference Function CreateObjectRef(Actor akActor, Form akBaseObject, Alias akAlias) Global
  ObjectReference itemRef = akActor.PlaceAtMe(akBaseObject, 1, False, True, True, None, akAlias, True) ; #DEBUG_LINE_NO:159
  If itemRef != None ; #DEBUG_LINE_NO:160
    itemRef.SetActorRefOwner(akActor, False) ; #DEBUG_LINE_NO:161
  EndIf
  Return itemRef ; #DEBUG_LINE_NO:164
EndFunction

ObjectReference Function CreateObjectRefFromExisting(Actor akActor, Form akBaseObject, Alias akAlias) Global
  ObjectReference itemRef = akActor.MakeAliasedRefFromInventory(akBaseObject, akAlias) ; #DEBUG_LINE_NO:168
  If itemRef != None ; #DEBUG_LINE_NO:169
    itemRef.SetActorRefOwner(akActor, False) ; #DEBUG_LINE_NO:170
  EndIf
  Return itemRef ; #DEBUG_LINE_NO:173
EndFunction

Function WaitForCombatEnd() Global
  While Game.GetPlayer().GetCombatState() == 1 ; #DEBUG_LINE_NO:177
    Utility.Wait(3.0) ; #DEBUG_LINE_NO:178
  EndWhile
EndFunction
