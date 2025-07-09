Scriptname HTG:Quests:PlayerHoloArmorTracker extends HTG:ReferenceAliasInventoryTracker
{HoloArmor tracker for the player}
import HTG
import HTG:Structs
import HTG:UtilityExt
import HTG:FormUtility
import HTG:FloatUtility

PlayerEquipmentTracker Property PlayerTracker Mandatory Const Auto
ActorValue Property IsHoloArmorEquipped Mandatory Const Auto
ActorValue Property ForceHideSpacesuit Mandatory Const Auto

ObjectReference Property HoloArmorBackpack Hidden
    ObjectReference Function Get()
        return _backpackReference
    EndFunction
EndProperty

ObjectReference Property HoloArmorHelmet Hidden
    ObjectReference Function Get()
        return _helmetReference
    EndFunction
EndProperty

ObjectReference Property HoloArmorSpacesuit Hidden
    ObjectReference Function Get()
        return _spacesuitReference
    EndFunction
EndProperty

Guard _suitGuard ProtectsFunctionLogic
Guard _equipGuard ProtectsFunctionLogic
Guard _unequipGuard ProtectsFunctionLogic
Guard _addedGuard ProtectsFunctionLogic
Guard _removedGuard ProtectsFunctionLogic
Guard _hideTimerGuard ProtectsFunctionLogic
Guard _showTimerGuard ProtectsFunctionLogic
ObjectReference _backpackReference
ObjectReference _helmetReference
ObjectReference _spacesuitReference
ArmorSet _currentArmorSet
Bool _isInMenu
Bool _equipHandled
Bool _unequipHandled
Bool _addHandled
Bool _removeHandled
Bool _isArmorEquipped
Int _hideTimerId = 10
Int _showTimerId = 11
Armor _armorToHide
Armor _armorToShow

Event OnAliasInit()
    Parent.OnAliasInit()

    _currentArmorSet = new ArmorSet

    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ; RemoveInventoryEventFilter(None)
    ; AddInventoryEventFilter(kController.HoloArmor.Backpack)
    ; AddInventoryEventFilter(kController.HoloArmor.Spacesuit)
    ; AddInventoryEventFilter(kController.HoloArmor.Helmet)

    RegisterForMenuOpenCloseEvent("ContainerMenu")
EndEvent

Event OnAliasReset()
    Parent.OnAliasReset()

    If IsInitialized
        SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
        ArmorSet kHoloArmor = kController.HoloArmor

        _DestroyArmorReference(kHoloArmor.Backpack, _backpackReference)
        _DestroyArmorReference(kHoloArmor.Helmet, _helmetReference)
        _DestroyArmorReference(kHoloArmor.Spacesuit, _spacesuitReference)

        ; RemoveInventoryEventFilter(kController.HoloArmor.Backpack)
        ; RemoveInventoryEventFilter(kController.HoloArmor.Spacesuit)
        ; RemoveInventoryEventFilter(kController.HoloArmor.Helmet)

        UnregisterForMenuOpenCloseEvent("ContainerMenu")
    EndIf
EndEvent

Event OnTimer(int aiTimerID)
    Parent.OnTimer(aiTimerID)

    If aiTimerID == _hideTimerId
        TryLockGuard _hideTimerGuard
            ArmorUtility kArmorUtil = SystemUtilities.Armors
            If !IsNone(_armorToHide)
                PlayerTracker.DisableTracking = True
                DisableTracking = True
                kArmorUtil.HideArmorPiece(GetActorReference(), _armorToHide)
                _armorToHide = None
                PlayerTracker.DisableTracking = False
                DisableTracking = False
            EndIf
        EndTryLockGuard
    ElseIf aiTimerID == _showTimerId
        TryLockGuard _showTimerGuard
            ArmorUtility kArmorUtil = SystemUtilities.Armors
            If !IsNone(_armorToHide)
                PlayerTracker.DisableTracking = True
                DisableTracking = True
                kArmorUtil.ShowArmorPiece(GetActorReference(), _armorToShow)
                _armorToShow = None
                PlayerTracker.DisableTracking = False
                DisableTracking = False
            EndIf
        EndTryLockGuard
    EndIf
EndEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    WaitForInitialized()

    Logger.Log("Menu Event for " + asMenuName)
    If asMenuName == "ContainerMenu"
        If abOpening
            _isInMenu = True
        Else
            _isInMenu = True
        EndIf
    EndIf
EndEvent

Bool Function EquipHoloArmor(ArmorSet akArmorSet = None)
    WaitForInitialized()

    Actor kActor = GetActorReference()

    If FloatToBool(kActor.GetValue(IsHoloArmorEquipped))
        Logger.Log("HoloArmor is equipped.")
        return True
    EndIf

    TryLockGuard _suitGuard
        PlayerTracker.DisableTracking = True

        _isArmorEquipped = True
        Bool bSilent = True ; !SystemUtilities.IsDebugging
        SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
        ArmorSet kHoloArmor = kController.HoloArmor
        ArmorUtility kArmorUtil = SystemUtilities.Armors

        ; ArmorSet kPlayerArmorSet = PlayerTracker.GetActorArmorSet()
        ; If kPlayerArmorSet
        ;     kArmorUtil.HideArmorSet(kActor, kPlayerArmorSet)
        ; EndIf

        ObjectReference kBackpack = _GetHoloArmorPiece(kArmorUtil.Backpack)
        ObjectReference kHelmet = _GetHoloArmorPiece(kArmorUtil.Helmet)
        ObjectReference kSpacesuit = _GetHoloArmorPiece(kArmorUtil.Spacesuit)

        If IsNone(kBackpack) \
            || IsNone(kHelmet) \
            || IsNone(kSpacesuit)
                Logger.ErrorEx("Could not equip HolorArmor to Player.")
                _DestroyArmorReference(kHoloArmor.Backpack, _backpackReference)
                _DestroyArmorReference(kHoloArmor.Helmet, _helmetReference)
                _DestroyArmorReference(kHoloArmor.Spacesuit, _spacesuitReference)

                return False
        EndIf

        If akArmorSet != None
            ObjectMod kMod
            If !IsNone(akArmorSet.Backpack)
                kMod = kController.GetArmorMod(akArmorSet.Backpack)
                If !IsNone(kMod)
                    kBackpack.AttachMod(kMod)
                EndIf
            EndIf

            If !IsNone(akArmorSet.Helmet)
                kMod = kController.GetArmorMod(akArmorSet.Helmet)
                If !IsNone(kMod)
                    kHelmet.AttachMod(kMod)
                EndIf
            EndIf

            If !IsNone(akArmorSet.Spacesuit)
                kMod = kController.GetArmorMod(akArmorSet.Spacesuit)
                If !IsNone(kMod)
                    kSpacesuit.AttachMod(kMod)
                EndIf
            EndIf
        EndIf

        kActor.EquipItem(kBackpack.GetBaseObject(), abSilent = bSilent)
        kActor.EquipItem(kHelmet.GetBaseObject(), abSilent = bSilent)
        kActor.EquipItem(kSpacesuit.GetBaseObject(), abSilent = bSilent)
        kActor.SetValue(IsHoloArmorEquipped, 1.0)
        ; kActor.SetValue(ForceHideSpacesuit, 0.0)
        
        PlayerTracker.DisableTracking = False
        return True
    EndTryLockGuard

    ; return kArmorUtil.EquipArmorSet(GetActorReference(), kController.HoloArmor)
EndFunction

Bool Function UnequipHoloArmor()
    WaitForInitialized()

    Actor kActor = GetActorReference()

    If !FloatToBool(kActor.GetValue(IsHoloArmorEquipped))
        Logger.Log("HoloArmor is not equipped.")
        return True
    EndIf

    TryLockGuard _suitGuard
        PlayerTracker.DisableTracking = True

        Bool bSilent = True ; !SystemUtilities.IsDebugging
        SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
        ArmorUtility kArmorUtil = SystemUtilities.Armors
        
        ; ArmorSet kPlayerArmorSet = PlayerTracker.GetActorArmorSet()
        ; If kPlayerArmorSet
        ;     kArmorUtil.ShowArmorSet(kActor, kPlayerArmorSet)
        ; EndIf

        kActor.UnequipItem(_backpackReference.GetBaseObject(), bSilent)
        kActor.RemoveItem(_backpackReference, 1, bSilent) ; , SystemUtilities.TempContainer)

        kActor.UnequipItem(_helmetReference.GetBaseObject(), bSilent)
        kActor.RemoveItem(_helmetReference, 1, bSilent) ; , SystemUtilities.TempContainer)

        kActor.UnequipItem(_spacesuitReference.GetBaseObject(), bSilent)
        kActor.RemoveItem(_spacesuitReference, 1, bSilent) ; , SystemUtilities.TempContainer)
        _isArmorEquipped = False
        kActor.SetValue(IsHoloArmorEquipped, 0.0)
        ; kActor.SetValue(ForceHideSpacesuit, 1.0)

        Bool kResult 
        If IsNone(_backpackReference) || \
                IsNone(_helmetReference) || \
                IsNone(_spacesuitReference)
                kResult = True
        EndIf

        PlayerTracker.DisableTracking = False
        ; Logger.ErrorEx("Could not equip HolorArmor to Player.")
        return kResult
    EndTryLockGuard
EndFunction

Function CopyArmorAppearance(Actor akSourceToCopyFrom)
    Actor kActor = GetActorReference()
    Bool bSilent = !SystemUtilities.IsDebugging
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ArmorUtility kArmorUtil = SystemUtilities.Armors
    ; ObjectMod kMod = kController.GetArmorMod(akArmor)
    ; Keyword kType = kArmorUtil.GetArmorType(akArmor)
    ; ObjectReference kArmorReference = _GetHoloArmorPiece(kType)

    ; RegisterForRemoteEvent(SystemUtilities.TempContainer, "OnItemAdded")
    ; akSourceToCopyFrom.RemoveAllItemsEx(SystemUtilities.TempContainer, True, abSilent = bSilent)
EndFunction

Bool Function ChangeArmorPieceAppearance(Armor akArmor, Bool abIsInMenu = False)
    WaitForInitialized()

    TryLockGuard _suitGuard
        Actor kActor = GetActorReference()
        Bool bSilent = True ; !SystemUtilities.IsDebugging
        SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
        ArmorUtility kArmorUtil = SystemUtilities.Armors
        ObjectMod kMod = kController.GetArmorMod(akArmor)
        Keyword kType = kArmorUtil.GetArmorType(akArmor)
        ObjectReference kArmorReference = _GetHoloArmorPiece(kType)
        Armor kCurrentPiece = kArmorUtil.GetArmorPiece(_currentArmorSet, kType)

        If akArmor != kCurrentPiece \
            && !IsNone(kArmorReference)
            Form kItem = kArmorReference.GetBaseObject()

            If (_isInMenu || abIsInMenu) && kActor.GetItemCount(kItem) > 0
                ; DisableTracking = True
                kActor.UnequipItem(kItem, bSilent)
                ; kActor.RemoveItem(kItem, abSilent = !SystemUtilities.IsDebugging, akOtherContainer = kController.TempContainer)
                kArmorReference.Drop(bSilent)
                ; kArmorReference.Disable()
                ; DisableTracking = False
            EndIf

            Bool res = kArmorReference.AttachMod(kMod)
            WaitExt(0.25)
            ; kController.TempContainer.RemoveItem(kItem, abSilent = bSilent, akOtherContainer = kActor)

            If _isInMenu || abIsInMenu
                ; DisableTracking = True
                kActor.AddItem(kArmorReference, abSilent = bSilent)
                ; kArmorReference.Enable()

                ; HTG:UtilityExt.RefreshInventoryItem(kActor, kArmorReference)
                kActor.EquipItem(kItem, abSilent = bSilent)

                kActor.AddItem(Game.GetCredits(), 1, abSilent = bSilent)
                kActor.RemoveItem(Game.GetCredits(), 1, abSilent = bSilent)
                ; DisableTracking = False
            EndIf

            If kType == kArmorUtil.Backpack
                _currentArmorSet.Backpack = akArmor
            ElseIf kType == kArmorUtil.Helmet
                _currentArmorSet.Helmet = akArmor
            ElseIf  kType == kArmorUtil.Spacesuit          
                _currentArmorSet.Spacesuit = akArmor
            EndIf

            return res
        EndIf

        Logger.Log("Unable to change HoloArmor appearance.")
        return False
    EndTryLockGuard
    
EndFunction

Bool Function ClearArmorPieceAppearance(Armor akArmor, Bool abIsMenuOpen = False)
    WaitForInitialized()

    TryLockGuard _suitGuard
        Actor kActor = GetActorReference()
        Bool bSilent = !SystemUtilities.IsDebugging
        SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
        ArmorUtility kArmorUtil = SystemUtilities.Armors
        ObjectMod kMod = kController.GetArmorMod(akArmor)
        Keyword kType = kArmorUtil.GetArmorType(akArmor)
        ObjectReference kArmorReference = _GetHoloArmorPiece(kType)

        If !IsNone(kArmorReference)
            Form kItem = kArmorReference.GetBaseObject()

            If abIsMenuOpen && kActor.GetItemCount(kArmorReference) > 0
                kActor.UnequipItem(kItem, bSilent)
                kArmorReference.Drop(bSilent)
            EndIf

            kArmorReference.RemoveMod(kMod)

            If abIsMenuOpen
                kActor.AddItem(kArmorReference, abSilent = bSilent)
                kActor.EquipItem(kArmorReference.GetBaseObject(), abSilent = bSilent)
                kActor.AddItem(Game.GetCredits(), 1, abSilent = bSilent)
                kActor.RemoveItem(Game.GetCredits(), 1, abSilent = bSilent)
            EndIf

            If kType == kArmorUtil.Backpack
                _currentArmorSet.Backpack = None
            ElseIf kType == kArmorUtil.Helmet
                _currentArmorSet.Helmet = None
            ElseIf  kType == kArmorUtil.Spacesuit          
                _currentArmorSet.Spacesuit = None
            EndIf

            return True
        EndIf

        Logger.Log("Unable to clear HoloArmor appearance.")
        return False
    EndTryLockGuard
EndFunction

; Bool Function ChangeArmorSetAppearance(ArmorSet akArmorSet)
;     WaitForInitialized()
;     SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
;     ArmorUtility kArmorUtil = SystemUtilities.Armors
;     ArmorSet kHoloArmor = kController.HoloArmor
;     ObjectMod kMod

;     ;TODO: optimize this loop
;     ;Backpack
;     kMod = kController.GetArmorMod(akArmorSet.Backpack)
;     If !IsNone(kMod) && _backpackReference.AttachMod(kMod)
;     ; && kArmorUtil.AddModToArmor(GetActorReference(), kHoloArmor.Backpack, kMod)
;         _currentArmorSet.Backpack = akArmorSet.Backpack

;         ;Helmet
;         kMod = kController.GetArmorMod(akArmorSet.Helmet)
;         If !IsNone(kMod) && _helmetReference.AttachMod(kMod)
;         ; && kArmorUtil.AddModToArmor(GetActorReference(), kHoloArmor.Helmet, kMod)

;             _currentArmorSet.Helmet = akArmorSet.Helmet

;             ;Spacesuit
;             kMod = kController.GetArmorMod(akArmorSet.Spacesuit)
;             If !IsNone(kMod) && _spacesuitReference.AttachMod(kMod)
;             ; && kArmorUtil.AddModToArmor(GetActorReference(), kHoloArmor.Spacesuit, kMod)
;                 _currentArmorSet.Spacesuit = akArmorSet.Spacesuit
;                 return True
;             EndIf
;         EndIf
;     EndIf

;     ; ClearArmorSetAppearance(akArmorSet)
;     return False
; EndFunction

; Bool Function ClearArmorSetAppearance(ArmorSet akArmorSet)
;     WaitForInitialized()
;     SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
;     ArmorUtility kArmorUtil = SystemUtilities.Armors
;     ArmorSet kHoloArmor = kController.HoloArmor
;     ObjectMod kMod

;     ;TODO: optimize this loop
;     ;Backpack
;     kMod = kController.GetArmorMod(akArmorSet.Backpack)
;     If !IsNone(kMod) && kArmorUtil.AddModToArmor(GetActorReference(), kHoloArmor.Backpack, kMod)
;         _currentArmorSet.Backpack = None

;         ;Helmet
;         kMod = kController.GetArmorMod(akArmorSet.Helmet)
;         If !IsNone(kMod) && kArmorUtil.AddModToArmor(GetActorReference(), kHoloArmor.Helmet, kMod)
;             _currentArmorSet.Helmet = None

;             ;Spacesuit
;             kMod = kController.GetArmorMod(akArmorSet.Spacesuit)
;             If !IsNone(kMod) && kArmorUtil.AddModToArmor(GetActorReference(), kHoloArmor.Spacesuit, kMod)
;                 _currentArmorSet.Spacesuit = None
;                 return True
;             EndIf
;         EndIf
;     EndIf

;     return  False
; EndFunction

Bool Function _Init()
    return Parent._Init() \
            && (!IsNone(PlayerTracker) && PlayerTracker.WaitForInitialized())
EndFunction

ObjectReference Function _GetHoloArmorPiece(Keyword akArmorType)
    Actor kActor = GetActorReference()
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ArmorUtility kArmorUtil = SystemUtilities.Armors
    ArmorSet kHoloArmor = kController.HoloArmor
    Armor kArmorPiece = kArmorUtil.GetArmorPiece(kHoloArmor, akArmorType)

    If akArmorType == kArmorUtil.Backpack
        _backpackReference = _RefreshArmorReference(kArmorPiece, _backpackReference)
        return _backpackReference
    ElseIf akArmorType == kArmorUtil.Helmet
        _helmetReference = _RefreshArmorReference(kArmorPiece, _helmetReference)
        return _helmetReference
    ElseIf  akArmorType == kArmorUtil.Spacesuit          
        _spacesuitReference = _RefreshArmorReference(kArmorPiece, _spacesuitReference)
        return _spacesuitReference
    EndIf

    return None
EndFunction

ObjectReference Function _RefreshArmorReference(Armor akArmorPiece, ObjectReference akArmorReference)
    Actor kActor = GetActorReference()
    Bool bSilent = True ; !SystemUtilities.IsDebugging
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ; ObjectReference kTempContanier = SystemUtilities.TempContainer
    Int kCount
    Bool bAddPiece

    If IsNone(akArmorReference)
        kCount = kActor.GetItemCount(akArmorPiece)
        If kCount > 0
            kActor.RemoveItem(akArmorPiece, kCount, bSilent)
        EndIf

        akArmorReference = CreateReference(kActor, akArmorPiece)
        If IsNone(akArmorReference)
            Logger.ErrorEx("Could not refresh HolorArmor piece " + akArmorPiece)
        Else
            bAddPiece = True
        EndIf
    Else
        Form kItem = akArmorReference.GetBaseObject()
        If akArmorReference.GetContainer() != kActor
            bAddPiece = True
        EndIf
    EndIf

    If bAddPiece
        ; kCount = kTempContanier.GetItemCount(akArmorReference)
        ; If kCount > 0
        ;     kTempContanier.RemoveItem(akArmorReference, 1, bSilent, kActor)
        ; Else
            kActor.AddItem(akArmorReference, abSilent = bSilent)
        ; EndIf
    EndIf

    return akArmorReference
EndFunction

Function _DestroyArmorReference(Armor akArmorPiece, ObjectReference akArmorReference)
    Actor kActor = GetActorReference()
    Bool bSilent = !SystemUtilities.IsDebugging
    ArmorUtility kArmorUtil = SystemUtilities.Armors
    ; ObjectReference kTempContainer = SystemUtilities.TempContainer
    
    ; Int kCount = kTempContainer.GetItemCount(akArmorPiece)
    ; If kCount > 0
    ;     kTempContainer.RemoveItem(akArmorPiece, kCount, bSilent)
    ; EndIf

    Int kCount = kActor.GetItemCount(akArmorPiece)
    If kCount > 0
        kActor.RemoveItem(akArmorPiece, kCount, bSilent)
    EndIf

    akArmorReference = None
EndFunction

Function _HandleItemAdded(Form akItem)
    If !_isArmorEquipped
        return
    EndIf

    PlayerTracker.DisableTracking = True

    Actor kActor = PlayerTracker.GetActorReference()
    ArmorUtility kArmorUtil = SystemUtilities.Armors
    Keyword kType = kArmorUtil.GetArmorType(akItem)

    If !IsNone(kType)
        ArmorSet kArmorSet = PlayerTracker.GetActorArmorSet()
        Armor kArmor = kArmorUtil.GetArmorPiece(kArmorSet, kType)
        If !IsNone(kArmor) ; && _armorToHide != kArmor
            ; DisableTracking = True
            ; _armorToHide = kArmor
            ; StartTimer(0.1, _hideTimerId)
            ; kArmorUtil.HideArmorPiece(kActor, kArmor)
            ; DisableTracking = False
        EndIf
    EndIf

    PlayerTracker.DisableTracking = False
EndFunction

Function _HandleItemRemoved(Form akItem)
    If !_isArmorEquipped
        return
    EndIf

    PlayerTracker.DisableTracking = True
    ; DisableTracking = True
    
    Actor kActor = PlayerTracker.GetActorReference()
    ArmorUtility kArmorUtil = SystemUtilities.Armors
    Keyword kType = kArmorUtil.GetArmorType(akItem)

    If !IsNone(kType)
        ArmorSet kArmorSet = PlayerTracker.GetActorArmorSet()
        Armor kArmor = kArmorUtil.GetArmorPiece(kArmorSet, kType)
        If !IsNone(kArmor) ; && _armorToShow != kArmor
            ; DisableTracking = True
            ; _armorToShow = kArmor
            ; StartTimer(0.1, _showTimerId)
            ; kArmorUtil.ShowArmorPiece(kActor, kArmor)
            ; DisableTracking = False
        EndIf
    EndIf
    ; DisableTracking = False
    PlayerTracker.DisableTracking = False
EndFunction

Function _HandleItemEquipped(Form akItem)
    If !_isArmorEquipped
        return
    EndIf

    PlayerTracker.DisableTracking = True
    ; DisableTracking = True
    
    Actor kActor = PlayerTracker.GetActorReference()
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ArmorUtility kArmorUtil = SystemUtilities.Armors
    Keyword kType = kArmorUtil.GetArmorType(akItem)
    ArmorSet kHoloArmor = kController.HoloArmor
    Armor kHoloArmorPiece = kArmorUtil.GetArmorPiece(kHoloArmor, kType)

    If !IsNone(kType) && akItem == kHoloArmorPiece
        ArmorSet kArmorSet = PlayerTracker.GetActorArmorSet()
        Armor kArmor = kArmorUtil.GetArmorPiece(kArmorSet, kType)
        If !IsNone(kArmor) ; && _armorToShow != kArmor
            ; kActor.UnequipItem(kArmor, abSilent = True)
            ; WaitExt(0.333)
            ; kActor.EquipItem(kArmor, abSilent = True)
            ; WaitExt(0.333)
            ; DisableTracking = True
            ; _armorToShow = kArmor
            ; StartTimer(0.1, _showTimerId)
            ; kArmorUtil.ShowArmorPiece(kActor, kArmor)
            ; DisableTracking = False
        EndIf
    EndIf
    ; DisableTracking = False
    PlayerTracker.DisableTracking = False
EndFunction

Function _HandleItemUnequipped(Form akItem)
    If !_isArmorEquipped
        return
    EndIf

    PlayerTracker.DisableTracking = True
    ; DisableTracking = True
    
    Actor kActor = PlayerTracker.GetActorReference()
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ArmorUtility kArmorUtil = SystemUtilities.Armors
    Keyword kType = kArmorUtil.GetArmorType(akItem)
    ArmorSet kHoloArmor = kController.HoloArmor
    Armor kHoloArmorPiece = kArmorUtil.GetArmorPiece(kHoloArmor, kType)

    If !IsNone(kType) && akItem == kHoloArmorPiece
        ArmorSet kArmorSet = PlayerTracker.GetActorArmorSet()
        Armor kArmor = kArmorUtil.GetArmorPiece(kArmorSet, kType)
        If !IsNone(kArmor) ; && _armorToShow != kArmo
            ; DisableTracking = True
            ; _armorToShow = kArmor
            ; StartTimer(0.1, _showTimerId)
            ; kArmorUtil.ShowArmorPiece(kActor, kArmor)
            ; DisableTracking = False
        EndIf
    EndIf
    ; DisableTracking = False
    PlayerTracker.DisableTracking = False
EndFunction