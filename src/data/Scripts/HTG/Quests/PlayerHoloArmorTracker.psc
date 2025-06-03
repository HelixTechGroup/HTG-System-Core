Scriptname HTG:Quests:PlayerHoloArmorTracker extends HTG:ReferenceAliasExt
{HoloArmor tracker for the player}
import HTG
import HTG:Structs
import HTG:UtilityExt
import HTG:FormUtility

ObjectReference _backpackReference
ObjectReference _helmetReference
ObjectReference _spacesuitReference
ArmorSet _currentArmorSet

Event OnAliasInit()
    Parent.OnAliasInit()

    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    AddInventoryEventFilter(kController.HoloArmor.Backpack)
    AddInventoryEventFilter(kController.HoloArmor.Spacesuit)
    AddInventoryEventFilter(kController.HoloArmor.Helmet)
    _currentArmorSet = new ArmorSet
EndEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer, int aiTransferReason)
    
EndEvent

Bool Function EquipHoloArmor()
    ; WaitForInitialized()
    Actor kActor = GetActorReference()
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ArmorUtility kArmorUtil = SystemUtilities.Armors

    _backpackReference = CreateReference(kActor, kController.HoloArmor.Backpack)
    kActor.AddItem(_backpackReference, abSilent = True)
    kActor.EquipItem(kController.HoloArmor.Backpack, abSilent = True)

    _helmetReference = CreateReference(kActor, kController.HoloArmor.Helmet)
    kActor.AddItem(_helmetReference, abSilent = True)
    kActor.EquipItem(kController.HoloArmor.Helmet, abSilent = True)

    _spacesuitReference = CreateReference(kActor, kController.HoloArmor.Spacesuit)
    kActor.AddItem(_spacesuitReference, abSilent = True)
    kActor.EquipItem(kController.HoloArmor.Spacesuit, abSilent = True)

     return _backpackReference && _helmetReference && _spacesuitReference
    ; return kArmorUtil.EquipArmorSet(GetActorReference(), kController.HoloArmor)
EndFunction

Bool Function UnequipHoloArmor()
    ; WaitForInitialized()
    Actor kActor = GetActorReference()
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ArmorUtility kArmorUtil = SystemUtilities.Armors

    return kArmorUtil.UnequipArmorSet(GetActorReference(), kController.HoloArmor)
EndFunction

Bool Function ChangeArmorSetAppearance(ArmorSet akArmorSet)
    ; WaitForInitialized()
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ArmorUtility kArmorUtil = SystemUtilities.Armors
    ArmorSet kHoloArmor = kController.HoloArmor
    ObjectMod kMod

    ;TODO: optimize this loop
    ;Backpack
    kMod = kController.GetArmorMod(akArmorSet.Backpack)
    If !IsNone(kMod) && _backpackReference.AttachMod(kMod)
    ; && kArmorUtil.AddModToArmor(GetActorReference(), kHoloArmor.Backpack, kMod)
        _currentArmorSet.Backpack = akArmorSet.Backpack

        ;Helmet
        kMod = kController.GetArmorMod(akArmorSet.Helmet)
        If !IsNone(kMod) && _helmetReference.AttachMod(kMod)
        ; && kArmorUtil.AddModToArmor(GetActorReference(), kHoloArmor.Helmet, kMod)

            _currentArmorSet.Helmet = akArmorSet.Helmet

            ;Spacesuit
            kMod = kController.GetArmorMod(akArmorSet.Spacesuit)
            If !IsNone(kMod) && _spacesuitReference.AttachMod(kMod)
            ; && kArmorUtil.AddModToArmor(GetActorReference(), kHoloArmor.Spacesuit, kMod)
                _currentArmorSet.Spacesuit = akArmorSet.Spacesuit
                return True
            EndIf
        EndIf
    EndIf

    ; ClearArmorSetAppearance(akArmorSet)
    return False
EndFunction

Bool Function ChangeArmorPieceAppearance(Armor akArmor)
    ; WaitForInitialized()
    Actor kActor = GetActorReference()
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ArmorUtility kArmorUtil = SystemUtilities.Armors
    ArmorSet kHoloArmor = kController.HoloArmor
    ObjectMod kMod = kController.GetArmorMod(akArmor)
    Keyword kType = kArmorUtil.GetArmorType(akArmor)
    Armor kArmorPiece = kArmorUtil.GetArmorPiece(kHoloArmor, kType)
    ObjectReference kArmorReference

    ; If kArmorUtil.AddModToArmor(GetActorReference(), kArmorPiece, kMod)
        If kType == kArmorUtil.Backpack
            ; kActor.RemoveItem(_backpackReference, abSilent = False)
            ; _backpackReference = CreateReference(kActor, kController.HoloArmor.Backpack)
            kArmorReference = _backpackReference
            _currentArmorSet.Backpack = akArmor
        ElseIf kType == kArmorUtil.Helmet
            ; kActor.RemoveItem(_helmetReference, abSilent = False)
            ; _helmetReference = CreateReference(kActor, kController.HoloArmor.Helmet)
            kArmorReference = _helmetReference
            _currentArmorSet.Helmet = akArmor
        ElseIf  kType == kArmorUtil.Spacesuit
            ; kActor.RemoveItem(_spacesuitReference, abSilent = False)
            ; _spacesuitReference = CreateReference(kActor, kController.HoloArmor.Spacesuit, True)
            kArmorReference = _spacesuitReference
            _currentArmorSet.Spacesuit = akArmor
        EndIf

        If kArmorReference
            Form kItem = kArmorReference.GetBaseObject()
            ; ; kActor.UnequipItem(kItem, abSilent = False)
            ; kActor.RemoveItem(kItem, abSilent = False, akOtherContainer = kController.TempContainer)

            ; kActor.AddItem(kController.CreditsObject, 1, False)
            ; kActor.RemoveItem(kController.CreditsObject, 1, False)
            ; kArmorReference.Enable()
            Bool res = kArmorReference.AttachMod(kMod)
            ; kActor.AddItem(kController.CreditsObject, 1, False)
            ; kActor.RemoveItem(kController.CreditsObject, 1, False)
            ; kController.TempContainer.RemoveItem(kItem, abSilent = False, akOtherContainer = kActor)
            ; kActor.AddItem(kArmorReference, abSilent = False)
            ; kActor.AddItem(kController.CreditsObject, 1, False)
            ; kActor.RemoveItem(kController.CreditsObject, 1, False)
            ; kActor.EquipItem(kArmorReference.GetBaseObject(), abSilent = False)
            kActor.AddItem(kController.CreditsObject, 1, False)
            kActor.RemoveItem(kController.CreditsObject, 1, False)
            InputEnableLayer iel = InputEnableLayer.Create()
            iel.DisablePlayerControls()
            iel.EnablePlayerControls()
            kActor.OpenInventory(True)

            return res
        EndIf

        Logger.Log("Unable to change HoloArmor appearance.")
        return False
    ; EndIf

    ; ClearArmorPieceAppearance(akArmor)
    ; return False
EndFunction

Bool Function ClearArmorPieceAppearance(Armor akArmor)
    WaitForInitialized()
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ArmorUtility kArmorUtil = SystemUtilities.Armors
    ArmorSet kHoloArmor = kController.HoloArmor
    ObjectMod kMod = kController.GetArmorMod(akArmor)
    Keyword kType = kArmorUtil.GetArmorType(akArmor)
    Armor kArmorPiece = kArmorUtil.GetArmorPiece(kHoloArmor, kType)
    
    If kMod && kArmorPiece
        GetReference().RemoveModFromInventoryItem(kArmorPiece, kMod)
        return True
    EndIf

    return  False
EndFunction

Bool Function ClearArmorSetAppearance(ArmorSet akArmorSet)
    WaitForInitialized()
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ArmorUtility kArmorUtil = SystemUtilities.Armors
    ArmorSet kHoloArmor = kController.HoloArmor
    ObjectMod kMod

    ;TODO: optimize this loop
    ;Backpack
    kMod = kController.GetArmorMod(akArmorSet.Backpack)
    If !IsNone(kMod) && kArmorUtil.AddModToArmor(GetActorReference(), kHoloArmor.Backpack, kMod)
        _currentArmorSet.Backpack = None

        ;Helmet
        kMod = kController.GetArmorMod(akArmorSet.Helmet)
        If !IsNone(kMod) && kArmorUtil.AddModToArmor(GetActorReference(), kHoloArmor.Helmet, kMod)
            _currentArmorSet.Helmet = None

            ;Spacesuit
            kMod = kController.GetArmorMod(akArmorSet.Spacesuit)
            If !IsNone(kMod) && kArmorUtil.AddModToArmor(GetActorReference(), kHoloArmor.Spacesuit, kMod)
                _currentArmorSet.Spacesuit = None
                return True
            EndIf
        EndIf
    EndIf

    return  False
EndFunction

Function RefreshArmor()
    Actor kActor = GetActorReference()
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ArmorUtility kArmorUtil = SystemUtilities.Armors
    ArmorSet kHoloArmor = kController.HoloArmor

    kActor.UnequipItem(kHoloArmor.Backpack)

EndFunction