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
            WaitExt(0.333)
        EndIf

        akActor.RemoveItem(akItem, c, abSilent = true)
        WaitExt(0.50)
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


    WaitExt(0.666)
    int nc = akActor.GetItemCount(akItem)
    If nc > 0
        If autoEquip && equip
            akActor.EquipItem(akItem, abSilent = true)
        EndIf
    EndIf
    ;WaitExt(0.25)

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
            WaitExt(0.333)
        EndIf

        actr.RemoveItem(item, c, abSilent = true)
        WaitExt(0.50)
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

    ; WaitExt(0.666)
    int nc = actr.GetItemCount(item)
    If nc > 0
        If autoEquip && equip
            actr.EquipItem(item, abSilent = true)
        EndIf
    EndIf
    ;WaitExt(0.25)

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
            WaitExt(0.333)
        EndIf

        ; If akAlias
        ;     If akAlias is ReferenceAlias
        ;         (akAlias as ReferenceAlias).GetReference() as
        ;     ElseIf akAlias is RefCollectionAlias
        ;         (akAlias as RefCollectionAlias).RemoveRef(akRemoveRef)
        ;     EndIf
        ; EndIf
        akActor.RemoveItem(akItem, c, abSilent = true)
        WaitExt(0.50)
        return True
    EndIf

    return False
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
            WaitExt(0.666)
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

Bool Function IsNone(ScriptObject akObject) Global
    return !akObject || akObject == None || !akObject.IsBoundGameObjectAvailable()
EndFunction

Function WaitForCombatEnd() Global
    While Game.GetPlayer().GetCombatState() == 1
        WaitExt(3.0)
    EndWhile
EndFunction

Function RefreshInventoryItem(ObjectReference akContainer, ObjectReference akItem) Global
    If akContainer.GetItemCount(akItem) > 0
        akItem.Drop(True)
        akContainer.AddItem(akItem)
        akContainer.AddItem(Game.GetCredits(), 1, True)
        akContainer.RemoveItem(Game.GetCredits(), 1, True)
    EndIf
EndFunction

Function WaitExt(Float afInterval) Global
    ; Int i
    ; afInterval *= 10.0
    ; Int iIterations = Math.Ceiling(afInterval) * 100
    Float fTime = Utility.GetCurrentRealTime()
    Bool bKeepRunning = True
    Float fDiff

    While fDiff < afInterval
        Float fNewTime = Utility.GetCurrentRealTime()
        fDiff = fNewTime - fTime
    EndWhile
EndFunction

Function ShowMessage(Message akMessage, \
                    ObjectReference[] akTextHolder = None, \
                    ReferenceAlias[] akTextHolderAlias = None, \
                    Bool abShowAsHelpMessage = false, \
                    Float afArg1 = 0.0, \
                    Float afArg2 = 0.0, \
                    Float afArg3 = 0.0, \
                    Float afArg4 = 0.0, \
                    Float afArg5 = 0.0, \
                    Float afArg6 = 0.0, \
                    Float afArg7 = 0.0, \
                    Float afArg8 = 0.0, \
                     Float afArg9 = 0.0) Global
    Int i = 0
    Bool bUseAlias = (akTextHolder != None && akTextHolder.Length > 0) \
                    && (akTextHolderAlias != None && akTextHolderAlias.Length > 0)
    If bUseAlias
        While i > akTextHolderAlias.Length
            ReferenceAlias kAlias = akTextHolderAlias[i]
            ObjectReference kReference = akTextHolder[i]
            kAlias.ForceRefTo(kReference)
        EndWhile
    EndIf

    If abShowAsHelpMessage
        float HelpMessageDuration = 3.0
        float HelpMessageInterval = 3.0
        int HelpMessageMaxTimes = 1
        string HelpMessageContext = ""
        int HelpMessagePriority = 0
        akMessage.ShowAsHelpMessage(none, \
                                    HelpMessageDuration, \
                                    HelpMessageInterval, \
                                    HelpMessageMaxTimes, \
                                    HelpMessageContext, \
                                    HelpMessagePriority)
    Else 
        akMessage.Show(afArg1, afArg2, afArg3, afArg4, afArg5, afArg6, afArg7, afArg8, afArg9)
    EndIf

    If bUseAlias
        i = 0
        While i > akTextHolderAlias.Length
            ReferenceAlias kAlias = akTextHolderAlias[i]          
            kAlias.Clear()
        EndWhile
    EndIf
EndFunction