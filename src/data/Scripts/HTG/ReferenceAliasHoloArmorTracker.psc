Scriptname HTG:ReferenceAliasHoloArmorTracker extends HTG:ReferenceAliasInventoryTracker
{HoloArmor tracker for the player}
import HTG
import HTG:UtilityExt
import HTG:SystemFormUtility
import HTG:SystemFloatUtility
import HTG:Structs
import HTG:Quests

ReferenceAlias Property EquipmentTracker Mandatory Const Auto
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
ReferenceAliasEquipmentTracker _equipmentTracker

Event OnAliasInit()
    Parent.OnAliasInit()

    _currentArmorSet = new ArmorSet

    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ; RemoveInventoryEventFilter(None)
    ; AddInventoryEventFilter(kController.HoloArmor.Backpack)
    ; AddInventoryEventFilter(kController.HoloArmor.Spacesuit)
    ; AddInventoryEventFilter(kController.HoloArmor.Helmet)

    RegisterForMenuOpenCloseEvent(Utilities.Menus.ObjectContainer)
    RegisterForMenuOpenCloseEvent(Utilities.Menus.Inventory)
EndEvent

Event OnAliasStarted()
    Parent.OnAliasStarted()

    ; EquipmentTrackerForceRefTo(GetReference())
EndEvent

Event OnAliasReset()
    Parent.OnAliasReset()

    If IsInitialized
        SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
        ArmorSet kHoloArmor = kController.GetCurrentArmorSet()
        ; If kHoloArmor == None
        ;     kHoloArmor.Backpack = kController.DefaultHoloArmorSes[0].Backpack
        ;     kHoloArmor.Helmet = kController.DefaultHoloArmorSets[0].Helmet
        ;     kHoloArmor.Spacesuit = kController.DefaultHoloArmorSets[0].Spacesuit
        ; EndIf

        _DestroyArmorReference(kHoloArmor.Backpack, _backpackReference)
        _DestroyArmorReference(kHoloArmor.Helmet, _helmetReference)
        _DestroyArmorReference(kHoloArmor.Spacesuit, _spacesuitReference)

        ; RemoveInventoryEventFilter(kController.HoloArmor.Backpack)
        ; RemoveInventoryEventFilter(kController.HoloArmor.Spacesuit)
        ; RemoveInventoryEventFilter(kController.HoloArmor.Helmet)

        UnregisterForMenuOpenCloseEvent(Utilities.Menus.ObjectContainer)
        UnregisterForMenuOpenCloseEvent(Utilities.Menus.Inventory)
    EndIf
EndEvent

Event OnTimer(int aiTimerID)
    Parent.OnTimer(aiTimerID)

    If aiTimerID == _hideTimerId
        TryLockGuard _hideTimerGuard
            SystemArmorUtility kArmorUtil = Utilities.Armors
            If !IsNone(_armorToHide)
                _equipmentTracker.DisableTracking = True
                DisableTracking = True
                ; kArmorUtil.HideArmorPiece(GetActorReference(), _armorToHide)
                _armorToHide = None
                _equipmentTracker.DisableTracking = False
                DisableTracking = False
            EndIf
        EndTryLockGuard
    ElseIf aiTimerID == _showTimerId
        TryLockGuard _showTimerGuard
            SystemArmorUtility kArmorUtil = Utilities.Armors
            If !IsNone(_armorToHide)
                _equipmentTracker.DisableTracking = True
                DisableTracking = True
                ; kArmorUtil.ShowArmorPiece(GetActorReference(), _armorToShow)
                _armorToShow = None
                _equipmentTracker.DisableTracking = False
                DisableTracking = False
            EndIf
        EndTryLockGuard
    EndIf
EndEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    WaitForInitialized()

    Logger.Log("Menu Event for " + asMenuName)
    If asMenuName == Utilities.Menus.ObjectContainer \
        || asMenuName == Utilities.Menus.Inventory
        If abOpening
            _isInMenu = True
        Else
            _isInMenu = False
        EndIf
    EndIf
EndEvent

Bool Function EquipHoloArmor(ArmorSet akArmorSet = None)
    WaitForInitialized()

    Actor kActor = GetActorReference()

    If FloatToBool(kActor.GetValue(IsHoloArmorEquipped))
        ; Debug.Notification("HoloArmor is already Equipped.")
        Logger.Log("HoloArmor is equipped.")
        return True
    EndIf

    TryLockGuard _suitGuard
        _equipmentTracker.DisableTracking = True

        _isArmorEquipped = True
        Bool bSilent = True ; !Utilities.IsDebugging
        SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
        ArmorSet kHoloArmor = kController.GetCurrentArmorSet()
        SystemArmorUtility kArmorUtil = Utilities.Armors

        ; ArmorSet kPlayerArmorSet = EquipmentTrackerGetActorArmorSet()
        ; If kPlayerArmorSet
        ;     kArmorUtil.HideArmorSet(kActor, kPlayerArmorSet)
        ; EndIf

        ObjectReference kBackpack = _GetHoloArmorPiece(kArmorUtil.Backpack)
        ObjectReference kHelmet = _GetHoloArmorPiece(kArmorUtil.Helmet)
        ObjectReference kSpacesuit = _GetHoloArmorPiece(kArmorUtil.Spacesuit)

        If IsNone(kBackpack) \
            || IsNone(kHelmet) \
            || IsNone(kSpacesuit)
            ; Debug.Notification("HoloArmor could not be Equipped.")
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

                kActor.EquipItem(kBackpack.GetBaseObject(), abSilent = bSilent)
            EndIf

            If !IsNone(akArmorSet.Helmet)
                kMod = kController.GetArmorMod(akArmorSet.Helmet)
                If !IsNone(kMod)
                    kHelmet.AttachMod(kMod)
                EndIf

                kActor.EquipItem(kHelmet.GetBaseObject(), abSilent = bSilent)
            EndIf

            If !IsNone(akArmorSet.Spacesuit)
                ObjectMod[] kMods = kController.GetAllArmorMods(akArmorSet.Spacesuit)
                Int i = 0
                While i < kMods.Length
                    kMod = kMods[i]
                    If kMod.HasKeyword(kArmorUtil.BackpackMod) \
                            || kMod.HasKeyword(kArmorUtil.Backpack)
                        kBackpack.AttachMod(kMod)
                    ElseIf kMod.HasKeyword(kArmorUtil.HelmetMod) \
                            || kMod.HasKeyword(kArmorUtil.Helmet)
                        kHelmet.AttachMod(kMod)
                    ElseIf kMod.HasKeyword(kArmorUtil.SpacesuitMod) \
                            || kMod.HasKeyword(kArmorUtil.Spacesuit)
                        kSpacesuit.AttachMod(kMod)
                    EndIf
                    i += 1
                EndWhile

                kActor.EquipItem(kSpacesuit.GetBaseObject(), abSilent = bSilent)
            EndIf
        Else
            kActor.EquipItem(kBackpack.GetBaseObject(), abSilent = bSilent)
            kActor.EquipItem(kHelmet.GetBaseObject(), abSilent = bSilent)
            kActor.EquipItem(kSpacesuit.GetBaseObject(), abSilent = bSilent)
        EndIf

        kActor.SetValue(IsHoloArmorEquipped, 1.0)
        ; kActor.SetValue(ForceHideSpacesuit, 1.0)
        ; Debug.Notification("HoloArmor has been Equipped.")

        _equipmentTracker.DisableTracking = False
        return True
    EndTryLockGuard

    ; return kArmorUtil.EquipArmorSet(GetActorReference(), kController.HoloArmor)
EndFunction

Bool Function UnequipHoloArmor()
    WaitForInitialized()

    Actor kActor = GetActorReference()

    If !FloatToBool(kActor.GetValue(IsHoloArmorEquipped))
        ; Debug.Notification("HoloArmor is not Equipped.")
        Logger.Log("HoloArmor is not equipped.")
        return True
    EndIf

    TryLockGuard _suitGuard
        _equipmentTracker.DisableTracking = True

        Bool bSilent = True ; !Utilities.IsDebugging
        SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
        SystemArmorUtility kArmorUtil = Utilities.Armors
        
        ; ArmorSet kPlayerArmorSet = EquipmentTrackerGetActorArmorSet()
        ; If kPlayerArmorSet
        ;     kArmorUtil.ShowArmorSet(kActor, kPlayerArmorSet)
        ; EndIf

        kActor.UnequipItem(_backpackReference.GetBaseObject(), abSilent = bSilent)
        kActor.RemoveItem(_backpackReference, 1, abSilent = bSilent) ; , Utilities.TempContainer)

        kActor.UnequipItem(_helmetReference.GetBaseObject(), abSilent = bSilent)
        kActor.RemoveItem(_helmetReference, 1, abSilent = bSilent) ; , Utilities.TempContainer)

        kActor.UnequipItem(_spacesuitReference.GetBaseObject(), abSilent = bSilent)
        kActor.RemoveItem(_spacesuitReference, 1, abSilent = bSilent) ; , Utilities.TempContainer)
        _isArmorEquipped = False
        kActor.SetValue(IsHoloArmorEquipped, 0.0)
        ; kActor.SetValue(ForceHideSpacesuit, 0.0)

        Bool kResult 
        If IsNone(_backpackReference) \
            || IsNone(_helmetReference) \
            || IsNone(_spacesuitReference)
            ; Debug.Notification("HoloArmor has been Unequipped.")
            kResult = True
        EndIf

        _equipmentTracker.DisableTracking = False
        ; Logger.ErrorEx("Could not equip HolorArmor to Player.")
        return kResult
    EndTryLockGuard
EndFunction

Function CopyArmorAppearance(Actor akSourceToCopyFrom)
    Actor kActor = GetActorReference()
    Bool bSilent = !Utilities.IsDebugging
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    SystemArmorUtility kArmorUtil = Utilities.Armors
    ; ObjectMod kMod = kController.GetArmorMod(akArmor)
    ; Keyword kType = kArmorUtil.GetArmorType(akArmor)
    ; ObjectReference kArmorReference = _GetHoloArmorPiece(kType)

    ; RegisterForRemoteEvent(Utilities.TempContainer, "OnItemAdded")
    ; akSourceToCopyFrom.RemoveAllItemsEx(Utilities.TempContainer, True, abSilent = bSilent)
EndFunction

Bool Function ChangeArmorPieceAppearance(Armor akArmor, Bool abIsInMenu = False)
    WaitForInitialized()
    Bool bResult = True

    TryLockGuard _suitGuard
        Actor kActor = GetActorReference()
        Bool bSilent = True ; !Utilities.IsDebugging
        SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
        SystemArmorUtility kArmorUtil = Utilities.Armors

        ObjectMod[] kMods = kController.GetAllArmorMods(akArmor)
        Int i = 0
        While i < kMods.Length 
            ObjectMod kMod = kMods[i]
            Keyword kType ; kArmorUtil.GetAllArmorTypes(akArmor)

            If kMod.HasKeyword(kArmorUtil.Backpack)
                kType = kArmorUtil.Backpack
            ElseIf kMod.HasKeyword(kArmorUtil.Helmet)
                kType = kArmorUtil.Helmet
            ElseIf kMod.HasKeyword(kArmorUtil.Spacesuit)
                kType = kArmorUtil.Spacesuit
            Else
                kType = kArmorUtil.GetArmorType(akArmor)
            EndIf

            ObjectReference kArmorReference = _GetHoloArmorPiece(kType, kMod)
            Armor kCurrentPiece = kArmorUtil.GetArmorPiece(_currentArmorSet, kType)

            ; If akArmor != kCurrentPiece \
            If !IsNone(kArmorReference)
                If IsNone(kMod)
                    kActor.UnequipItem(kArmorReference, abSilent = bSilent)
                    return True
                EndIf

                Form kItem = kArmorReference.GetBaseObject()

                If (_isInMenu || abIsInMenu) && kActor.GetItemCount(kItem) > 0
                    ; DisableTracking = True
                    If _equipmentTracker.CurrentEquipment.Contains(kItem)
                        kActor.UnequipItem(kItem, abSilent = bSilent)
                    EndIf 

                    ; kActor.RemoveItem(kItem, abSilent = !Utilities.IsDebugging, akOtherContainer = kController.TempContainer)
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

                If res
                    ; Debug.Notification
                    Logger.Log("Changed HoloArmor appearance.")
                Else
                    bResult = False
                    ; Debug.Notification("Unable to change HoloArmor appearance.")
                    Logger.Log("Unable to change HoloArmor appearance.")
                EndIf
            EndIf
            i += 1
        EndWhile
    EndTryLockGuard
    
    return bResult
EndFunction

Bool Function ClearArmorPieceAppearance(Armor akArmor, Bool abIsMenuOpen = False)
    WaitForInitialized()

    TryLockGuard _suitGuard
        Actor kActor = GetActorReference()
        Bool bSilent = True ; !Utilities.IsDebugging
        SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
        SystemArmorUtility kArmorUtil = Utilities.Armors
        ObjectMod kMod = kController.GetArmorMod(akArmor)
        Keyword kType = kArmorUtil.GetArmorType(akArmor)
        ObjectReference kArmorReference = _GetHoloArmorPiece(kType)

        If !IsNone(kArmorReference)
            Form kItem = kArmorReference.GetBaseObject()

            If abIsMenuOpen && kActor.GetItemCount(kArmorReference) > 0
                If _equipmentTracker.CurrentEquipment.Contains(kItem)
                    kActor.UnequipItem(kItem, abSilent = bSilent)
                EndIf 

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
;     SystemArmorUtility kArmorUtil = Utilities.Armors
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
;     SystemArmorUtility kArmorUtil = Utilities.Armors
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
    _equipmentTracker = EquipmentTracker as ReferenceAliasEquipmentTracker
    return Parent._Init() \
            && (!IsNone(_equipmentTracker) && _equipmentTracker.IsInitialized)
EndFunction

ObjectReference Function _GetHoloArmorPiece(Keyword akArmorType, ObjectMod akMod = None)
    Actor kActor = GetActorReference()
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    SystemArmorUtility kArmorUtil = Utilities.Armors
    ArmorSet kHoloArmor = kController.GetCurrentArmorSet()
    If !IsNone(akMod)
        kHoloArmor = kController.GetHoloArmorFromMod(akMod)
    EndIf

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
    Bool bSilent = True ; !Utilities.IsDebugging
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    ; ObjectReference kTempContanier = Utilities.TempContainer
    Int kCount
    Bool bAddPiece

    If IsNone(akArmorReference) \
        || akArmorReference.GetBaseObject() != akArmorPiece
        Form kOldArmorPiece
        If !IsNone(akArmorReference)
            kOldArmorPiece = akArmorReference.GetBaseObject()
            kCount = kActor.GetItemCount(kOldArmorPiece)
            If kCount > 0
                kActor.RemoveItem(kOldArmorPiece, kCount, bSilent)
            EndIf
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
    Bool bSilent = True ; !Utilities.IsDebugging
    SystemArmorUtility kArmorUtil = Utilities.Armors
    ; ObjectReference kTempContainer = Utilities.TempContainer
    
    ; Int kCount = kTempContainer.GetItemCount(akArmorPiece)
    ; If kCount > 0
    ;     kTempContainer.RemoveItem(akArmorPiece, kCount, bSilent)
    ; EndIf

    Int kCount = kActor.GetItemCount(akArmorPiece)
    If kCount > 0
        If kActor.IsEquipped(akArmorPiece)
            kActor.UnequipItem(akArmorPiece, bSilent)
        EndIf
        
        kActor.RemoveItem(akArmorPiece, kCount, bSilent)
    EndIf

    akArmorReference = None
EndFunction

Function _HandleItemAdded(Form akItem)
    If !_isArmorEquipped
        return
    EndIf

    _equipmentTracker.DisableTracking = True

    Actor kActor = _equipmentTracker.GetActorReference()
    SystemArmorUtility kArmorUtil = Utilities.Armors
    Keyword kType = kArmorUtil.GetArmorType(akItem)

    If !IsNone(kType)
        ArmorSet kArmorSet = _equipmentTracker.GetActorArmorSet()
        Armor kArmor = kArmorUtil.GetArmorPiece(kArmorSet, kType)
        ; If !IsNone(kArmor) ; && _armorToHide != kArmor
        ;     DisableTracking = True
        ;     ; _armorToHide = kArmor
        ;     ; StartTimer(0.1, _hideTimerId)
        ;     kArmorUtil.HideArmorPiece(kActor, kArmor)
        ;     DisableTracking = False
        ; EndIf
    EndIf

    _equipmentTracker.DisableTracking = False
EndFunction

Function _HandleItemRemoved(Form akItem)
    If !_isArmorEquipped
        return
    EndIf

    _equipmentTracker.DisableTracking = True
    ; DisableTracking = True
    
    Actor kActor = _equipmentTracker.GetActorReference()
    SystemArmorUtility kArmorUtil = Utilities.Armors
    Keyword kType = kArmorUtil.GetArmorType(akItem)

    If !IsNone(kType)
        ArmorSet kArmorSet = _equipmentTracker.GetActorArmorSet()
        Armor kArmor = kArmorUtil.GetArmorPiece(kArmorSet, kType)
        If !IsNone(kArmor) ; && _armorToShow != kArmor
        ;     DisableTracking = True
        ;     ; _armorToShow = kArmor
        ;     ; StartTimer(0.1, _showTimerId)
        ;     kArmorUtil.ShowArmorPiece(kActor, kArmor)
        ;     DisableTracking = False
        EndIf
    EndIf
    ; DisableTracking = False
    _equipmentTracker.DisableTracking = False
EndFunction

Function _HandleItemEquipped(Form akItem)
    If !_isArmorEquipped
        return
    EndIf

    _equipmentTracker.DisableTracking = True
    ; DisableTracking = True
    
    Actor kActor = _equipmentTracker.GetActorReference()
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    SystemArmorUtility kArmorUtil = Utilities.Armors
    ArmorSet kHoloArmor = kController.GetCurrentArmorSet()
    Keyword kType = kArmorUtil.GetArmorType(akItem)
    Armor kHoloArmorPiece = kArmorUtil.GetArmorPiece(kHoloArmor, kType)

    If !IsNone(kType) && akItem == kHoloArmorPiece
        ArmorSet kArmorSet = _equipmentTracker.GetActorArmorSet()
        Armor kArmor = kArmorUtil.GetArmorPiece(kArmorSet, kType)
        If !IsNone(kArmor) && _armorToHide != kArmor
            ; kActor.UnequipItem(kArmor, abSilent = True)
            ; WaitExt(0.333)
            ; kActor.EquipItem(kArmor, abSilent = True)
            ; WaitExt(0.333)
            ; DisableTracking = True
            _armorToHide = kArmor
            StartTimer(0.1, _hideTimerId)
            ; kArmorUtil.HideArmorPiece(kActor, kArmor)
            ; DisableTracking = False
        EndIf
    EndIf
    ; DisableTracking = False
    _equipmentTracker.DisableTracking = False
EndFunction

Function _HandleItemUnequipped(Form akItem)
    If !_isArmorEquipped
        return
    EndIf

    _equipmentTracker.DisableTracking = True
    ; DisableTracking = True
    
    Actor kActor = _equipmentTracker.GetActorReference()
    SQ_HoloArmorController kController = GetOwningQuest() as SQ_HoloArmorController
    SystemArmorUtility kArmorUtil = Utilities.Armors
    ArmorSet kHoloArmor = kController.GetCurrentArmorSet()

    Keyword kType = kArmorUtil.GetArmorType(akItem)
    Armor kHoloArmorPiece = kArmorUtil.GetArmorPiece(kHoloArmor, kType)

    If !IsNone(kType) && akItem == kHoloArmorPiece
        ArmorSet kArmorSet = _equipmentTracker.GetActorArmorSet()
        Armor kArmor = kArmorUtil.GetArmorPiece(kArmorSet, kType)
        If !IsNone(kArmor) && _armorToShow != kArmor    
            ; DisableTracking = True
            _armorToShow = kArmor
            StartTimer(0.1, _showTimerId)
            ; kArmorUtil.ShowArmorPiece(kActor, kArmor)
            ; DisableTracking = False
        EndIf
    EndIf
    ; DisableTracking = False
    _equipmentTracker.DisableTracking = False
EndFunction