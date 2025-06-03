Scriptname HTG:UtilityExt extends Utility Hidden

Bool Function AddLeveledItemToActor(Actor akActor, LeveledItem akItem, int count = 1, bool clearAllExisting = false, bool autoEquip = false, Alias akAlias = None) Global
    Int c = akActor.GetItemCount(akItem)
    Bool equip = False
    ;Armor ta = akItem as Armor
    ;Weapon w = item as Weapon

    ; If ta || w
    ;     equip = True
    ; EndIf

    If c > 0 && clearAllExisting
        If equip
            akActor.UnequipItem(akItem, abSilent = true)
            Utility.WaitMenuPause(0.333)
        EndIf

        akActor.RemoveItem(akItem, c, abSilent = true)
        Utility.WaitMenuPause(0.50)
    ElseIf c > 0
        If autoEquip && equip
            akActor.EquipItem(akItem, abSilent = true)
        EndIf

        return True
    EndIf

    If akAlias
        akActor.AddAliasedItem(akItem, akAlias, count, abSilent = true)
    Else
        akActor.AddItem(akItem, count, abSilent = true)
    EndIf


    Utility.Wait(0.666)
    int nc = akActor.GetItemCount(akItem)
    If nc > 0
        If autoEquip && equip
            akActor.EquipItem(akItem, abSilent = true)
        EndIf
    EndIf
    ;Utility.Wait(0.25)

    return (nc > 0)
EndFunction

Bool Function AddItemToActor(Actor actr, Form item, int count = 1, bool clearAllExisting = false, bool autoEquip = false, Alias akAlias = None, Keyword[] akKeywords = None) Global
    Int c = actr.GetItemCount(item)
    Bool equip = False
    Armor ta = item as Armor
    Weapon w = item as Weapon

    If ta || w
        equip = True
    EndIf

    If c > 0 && clearAllExisting
        If equip
            actr.UnequipItem(item, abSilent = true)
            Utility.Wait(0.333)
        EndIf

        actr.RemoveItem(item, c, abSilent = true)
        Utility.WaitMenuPause(0.50)
    ElseIf c > 0
        If autoEquip && equip
            actr.EquipItem(item, abSilent = true)
        EndIf

        return True
    EndIf

    If akAlias
        ; actr.AddAliasedItem(item, akAlias, count, abSilent = true)
        ObjectReference ref = actr.AddAliasedItemWithKeywordsSingle(item, akAlias, True, akKeywords)
        If akKeywords
            HTG:SystemLogger.LogObjectGlobal(item, "Has Keyword: " + akKeywords[0] + ": " + ref.HasKeyword(akKeywords[0]))
        EndIf
    Else
        actr.AddItem(item, count, abSilent = true)
    EndIf

    ; Utility.WaitMenuPause(0.666)
    int nc = actr.GetItemCount(item)
    If nc > 0
        If autoEquip && equip
            actr.EquipItem(item, abSilent = true)
        EndIf
    EndIf
    ;Utility.Wait(0.25)

    return (nc > 0)
    ; If npc.GetItemCount(item) > 0
    ;     ;logger.Trace(Self, "Added item to actor.")
    ;     return True
    ; EndIf
    ;     ;logger.Trace(Self, "Faled to add item to actor.")
    ; return False
EndFunction

Bool Function RemoveItemFromActor(Actor akActor, Form akItem, Alias akAlias = None) Global
    Int c = akActor.GetItemCount(akItem)
    Bool unequip 
    Armor ta = akItem as Armor
    Weapon w = akItem as Weapon

    If ta || w
        unequip = True
    EndIf

    If c > 0
        If unequip
            akActor.UnequipItem(akItem, abSilent = true)
            Utility.Wait(0.333)
        EndIf

        ; If akAlias
        ;     If akAlias is ReferenceAlias
        ;         (akAlias as ReferenceAlias).GetReference() as
        ;     ElseIf akAlias is RefCollectionAlias
        ;         (akAlias as RefCollectionAlias).RemoveRef(akRemoveRef)
        ;     EndIf
        ; EndIf
        akActor.RemoveItem(akItem, c, abSilent = true)
        Utility.Wait(0.50)
    EndIf
EndFunction

Bool Function EquipItemToActor(Actor actr, Form item) Global
    int c = actr.GetItemCount(item)
    Bool equip = False
    Armor ta = item as Armor
    Weapon w = item as Weapon

    If ta || w
        equip = True
    EndIf

    If c > 0
        If equip
            actr.EquipItem(item, abSilent = true)
            Utility.Wait(0.666)
            return actr.IsEquipped(item)
        EndIf
    EndIf
EndFunction

ObjectReference[] function GetOwnedObjects(RefCollectionAlias collectionAlias, Actor actorOwner) Global
	int i = 0
	; int ownerIndex = -1
	int count = collectionAlias.GetCount()
    ObjectReference[] res = new ObjectReference[count]
    int resI = 0
	while i < count ; && ownerIndex == -1
		if actorOwner.IsOwner(collectionAlias.GetAt(i))
			; ownerIndex = i
            res[resI] = collectionAlias.GetAt(i)
            resI += 1
		endif
		i += 1
	endWhile
	; if ownerIndex > -1
	; 	res[resI] = collectionAlias.GetAt(ownerIndex)
    ;     resI += 1
	; endif
    return res
EndFunction

; Keyword Function WearableCheck(Form akFrom) Global
;     Bool isWearable
;     Keyword resKeyword = None
;     Int i = 0
;     Int count = ArmorTypes.GetSize()

;     While i < count && !isWearable
;         Keyword kw = ArmorTypes.GetAt(i) as Keyword
;         isWearable = akFrom.HasKeyword(kw)
;         If (isWearable)
;             resKeyword = kw
;         EndIf
;         i += 1
;     EndWhile

;     return resKeyword
; EndFunction

; ObjectReference Function GetActorArmor(RefCollectionAlias collectionAlias, Actor actr, Keyword armorType) Global
;     ObjectReference[] aArmr = GetOwnedObjects(collectionAlias, actr)
;     int i = 0
;     int count = aArmr.Length
;     While i < count
;         If aArmr[i].HasKeyword(armorType)
;             return aArmr[i]
;         EndIf
;         i += 1
;     EndWhile

;     return None
; EndFunction

; Function ShowTextReplacedMessage(Actor MessageTextReplaceActor, Message MessageToShow, bool ShowAsHelpMessage = false, ObjectReference MessageTextReplaceRef = None, float afArg1 = 0.0, float afArg2 = 0.0)
;     if MessageTextReplaceActor != None
;         Alias_MessageTextReplaceActor.ForceRefTo(MessageTextReplaceActor)
;         Alias_MessageTextReplaceRef.ForceRefTo(MessageTextReplaceRef)

;         if ShowAsHelpMessage
;             float HelpMessageDuration = 3.0
;             float HelpMessageInterval = 3.0
;             int HelpMessageMaxTimes = 1
;             string HelpMessageContext = ""
;             int HelpMessagePriority = 0
;             MessageToShow.ShowAsHelpMessage(none, HelpMessageDuration, HelpMessageInterval, HelpMessageMaxTimes, HelpMessageContext, HelpMessagePriority)
;         else 
;             MessageToShow.Show(afArg1, afArg2)
;         endif
;         Alias_MessageTextReplaceActor.Clear()
; 	endif

; EndFunction

Bool Function IsNone(ScriptObject akObject) Global
    return !akObject || akObject == None
EndFunction

Function WaitForCombatEnd() Global
    While Game.GetPlayer().GetCombatState() == 1
        Utility.Wait(3.0)
    EndWhile
EndFunction