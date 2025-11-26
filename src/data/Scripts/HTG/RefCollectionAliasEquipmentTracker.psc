Scriptname HTG:RefCollectionAliasEquipmentTracker extends HTG:RefCollectionAliasInventoryTracker
{Script attached to ActiveFollowers refcollection alias.
Manages Equipment tracking for Inventory previews}
import HTG
import HTG:Structs
import HTG:Collections
import HTG:SystemFormUtility
import HTG:UtilityExt
import Utility

ReferenceAlias Property MessageTextHolder Mandatory Const Auto  
Message Property DetectedEquipmentMessage Mandatory Const Auto
Message Property DetectedBackpackMessage Mandatory Const Auto
ReferenceAlias Property EquipmentTextHolder Mandatory Const Auto
EquipmentMapList Property CurrentEquipment Auto Hidden
Race Property IncludeRace Auto Const
Bool Property CachingEnabled = True Auto    

Guard _trackedReferenceGuard ProtectsFunctionLogic
Guard _trackedReferenceEquipmentGuard ProtectsFunctionLogic
Guard _messageALiasGuard ProtectsFunctionLogic

EquipmentMapList _detectedEquipment     

Int _maxCheckTimerCycle = 10
Int _currentCheckTimerCycle = 0
Int _trackedIndex = 0
Dictionary _equipmentCheckCount
Dictionary _equipmentFoundCount
Bool _checkStarted

Event OnAliasChanged(ObjectReference akObject, bool abRemove)
    Actor kActor = akObject as Actor
    If !IsNone(kActor) \
        && !IsNone(IncludeRace) \
        && kActor.GetRace() != IncludeRace
        RemoveRef(akObject)
        return
    EndIf

    Parent.OnAliasChanged(akObject, abRemove)
EndEvent

Form[] Function GetFollowerEquipment(ObjectReference akFollower)
    WaitForInitialized()

    If !InitializedReferences.Contains(akFollower)
        Logger.Log("Reference is not Initialized: " + akFollower)
        return new Form[0]
    EndIf 

    ; Form[] kEquipment = CurrentEquipment.GetActorEquipment(akFollower as Actor)
    ; If kEquipment.Length <= 0
    ;     _RegisterFollowerArmor()
    ; EndIf

    return CurrentEquipment.GetActorEquipment(akFollower as Actor)
EndFunction

Bool Function UpdateFollowersEquipment(ObjectReference akFollower = None)

EndFunction

ArmorSet Function GetFollowerArmorSet(Actor akActor)
    ArmorSet kResult = new ArmorSet
    EquipmentMap[] kMap = CurrentEquipment.GetActorEquipmentMap(akActor)
    Int i 
    While i < kMap.Length
        EquipmentMap kEquipment = kMap[i]
        HTG:SystemArmorUtility kArmorUtil = Utilities.Armors
        If kEquipment.EquipmentType == kArmorUtil.Backpack
            kResult.Backpack = kEquipment.Equipment as Armor
        ElseIf kEquipment.EquipmentType == kArmorUtil.Helmet
            kResult.Helmet = kEquipment.Equipment as Armor
        ElseIf kEquipment.EquipmentType == kArmorUtil.Spacesuit
            kResult.Spacesuit = kEquipment.Equipment as Armor
        EndIf

        i += 1
    EndWhile

    return kResult
EndFunction

Bool Function _CreateCollections()
    TryLockGuard _trackedReferenceEquipmentGuard
        If IsNone(_detectedEquipment)
            _detectedEquipment = HTG:Collections:EquipmentMapList.EquipmentMapList(Utilities.ModInfo)
            ; Logger.Log("Created _detectedEquipment:\n" + _detectedEquipment.ToString())
        Else
            _detectedEquipment.Clear()
            Logger.Log("Cleared _detectedEquipment:\n" + _detectedEquipment.ToString())
        EndIf

        If IsNone(_equipmentCheckCount)
            _equipmentCheckCount = HTG:Collections:Dictionary.Dictionary(Utilities.ModInfo)
        Else
            _equipmentCheckCount.Clear()
            Logger.Log("Cleared _equipmentCheckCount:\n" + _equipmentCheckCount.ToString())
        EndIf

        If IsNone(_equipmentFoundCount)
            _equipmentFoundCount = HTG:Collections:Dictionary.Dictionary(Utilities.ModInfo)
        Else
            _equipmentFoundCount.Clear()
            Logger.Log("Cleared equipmentFoundCount:\n" + _equipmentFoundCount.ToString())
        EndIf

        If IsNone(CurrentEquipment)
            CurrentEquipment = HTG:Collections:EquipmentMapList.EquipmentMapList(Utilities.ModInfo)
            ; Logger.Log("Creating CurrentEquipment:\n" + CurrentEquipment.ToString())
        Else
            CurrentEquipment.Clear()
        EndIf
    EndTryLockGuard

    return Parent._CreateCollections() \
            && (!IsNone(_detectedEquipment) && _detectedEquipment.IsInitialized) \
            && (!IsNone(CurrentEquipment) && CurrentEquipment.IsInitialized) 
EndFunction

Bool Function _RegisterReference(ObjectReference akObject)
    Bool bResult
    Int iCheckCount = 0
    Int iFoundCount = 0
    Actor kActor = akObject  as Actor

    If !IsNone(kActor)
        Form[] kEquipment = CurrentEquipment.GetActorEquipment(kActor)
        Int aI = 0
        Int iCount = kEquipment.Length
        Bool bHatFound
        Bool bClothesFound
        Bool bHelmetFound
        Bool bBackpackFound
        Bool bSpacesuitFound
        SystemArmorUtility kArmorUtil = Utilities.Armors
        While aI < iCount
            Bool bFound
            Form kArmor = kEquipment[aI]
            Keyword kArmorType = kArmorUtil.GetArmorType(kArmor)
            If !kActor.IsEquipped(kArmor)
                Logger.Log("RegisterFollowerTimer - New Equipment found of type:" + kArmorType)
                If kArmorType == kArmorUtil.Hat
                    bHatFound = True
                    Logger.Log("RegisterFollowerTimer - Registering Hat.")
                    If kActor.WornHasKeyword(kArmorUtil.Hat)
                        kActor.UnequipItemSlot(kArmorUtil.HeadSlot) ; Hat 
                        iCheckCount += 1
                    ElseIf kActor.GetItemCount(kArmor) > 0
                        bFound = True
                    EndIf      
                ElseIf kArmorType == kArmorUtil.Clothes
                    bClothesFound = True
                    Logger.Log("RegisterFollowerTimer - Registering Clothes.")
                    If kActor.WornHasKeyword(kArmorUtil.Clothes)
                        kActor.UnequipItemSlot(kArmorUtil.ClothesSlot) ; Clothes
                        iCheckCount += 1
                    ElseIf kActor.GetItemCount(kArmor) > 0
                        bFound = True
                    EndIf      
                ElseIf kArmorType == kArmorUtil.Helmet
                    bHelmetFound = True
                    Logger.Log("RegisterFollowerTimer - Registering Helmet.")
                    If kActor.WornHasKeyword(kArmorUtil.Helmet)
                        kActor.UnequipItemSlot(kArmorUtil.SSHeadSlot) ; Helmet  
                        iCheckCount += 1
                    ElseIf kActor.GetItemCount(kArmor) > 0
                        bFound = True
                    EndIf      
                ElseIf kArmorType == kArmorUtil.Backpack
                    bBackpackFound = True
                    Logger.Log("RegisterFollowerTimer - Registering Backpack.")
                    If kActor.WornHasKeyword(kArmorUtil.Backpack)
                        kActor.UnequipItemSlot(kArmorUtil.SSBackpackSlot) ; Backpack  
                        iCheckCount += 1  
                    ElseIf kActor.GetItemCount(kArmor) > 0
                        bFound = True
                    EndIf                    
                ElseIf kArmorType == kArmorUtil.Spacesuit
                    bSpacesuitFound = True
                    Logger.Log("RegisterFollowerTimer - Registering Spacesuit.")
                    If kActor.WornHasKeyword(kArmorUtil.Spacesuit)
                        kActor.UnequipItemSlot(kArmorUtil.SSBodySlot) ; Spacesuit 
                        iCheckCount += 1
                    ElseIf kActor.GetItemCount(kArmor) > 0
                        bFound = True
                    EndIf                                           
                EndIf

                If bFound
                    _ShowDetectionNotification(kActor, kArmor, akObject)
                    kActor.EquipItem(kArmor, abSilent = True)
                    iFoundCount += 1
                    iCheckCount += 1
                Else
                    TryLockGuard _trackedReferenceEquipmentGuard
                        CurrentEquipment.RemoveActorEquipment(kActor, kArmor)
                    EndTryLockGuard
                EndIf

                Wait(1.5)
            Else
                _ShowDetectionNotification(kActor, kArmor, akObject)
                Logger.Log("RegisterFollowerTimer - Existing Equipment found:" + kArmor + " Type:" + kArmorType)
                iFoundCount += 1
            EndIf   

            aI += 1
        EndWhile
        
        ; If !bHatFound && \
        ;     kActor.WornHasKeyword(kArmorUtil.Hat)
        ;     Logger.Log("RegisterFollowerTimer - Registering Hat.")
        ;     kActor.UnequipItemSlot(kArmorUtil.HeadSlot) ; Hat
        ;     iCheckCount += 1
        ; EndIf

        ; If !bClothesFound && \
        ;     kActor.WornHasKeyword(kArmorUtil.Clothes)
        ;     Logger.Log("RegisterFollowerTimer - Registering Clothes.")
        ;     kActor.UnequipItemSlot(kArmorUtil.ClothesSlot) ; Clothes
        ;     iCheckCount += 1
        ; EndIf

        If !bHelmetFound \
            && kActor.WornHasKeyword(kArmorUtil.Helmet)          
            Logger.Log("RegisterFollowerTimer - Registering Helmet.")      
            kActor.UnequipItemSlot(kArmorUtil.SSHeadSlot) ; Helmet
            iCheckCount += 1
            Wait(1.5)
        EndIf

        If !bBackpackFound \
            && kActor.WornHasKeyword(kArmorUtil.Backpack)
            Logger.Log("RegisterFollowerTimer - Registering Backpack.")
            kActor.UnequipItemSlot(kArmorUtil.SSBackpackSlot) ; Backpack
            iCheckCount += 1
            Wait(1.5)
        EndIf

        If !bSpacesuitFound \
            && kActor.WornHasKeyword(kArmorUtil.Spacesuit)
            Logger.Log("RegisterFollowerTimer - Registering Spacesuit.")
            kActor.UnequipItemSlot(kArmorUtil.SSBodySlot) ; Spacesuit 
            iCheckCount += 1     
            Wait(1.5)              
        EndIf
        
        TryLockGuard _trackedReferenceEquipmentGuard
            If iFoundCount > 0
                _equipmentFoundCount.Update(kActor, iFoundCount)
            EndIf

            If iCheckCount > 0
                Logger.Log("RegisterFollowerTimer - Adding uninitialized follower: " + kActor)
                ; ekActor.SetValue(EquipmentCheckCount, iCheckCount)
                _equipmentCheckCount.Add(kActor, iCheckCount)
            EndIf 
        EndTryLockGuard
    EndIf

    return iCheckCount >= 0 \
            || iFoundCount > 0
EndFunction

Bool Function _InitializeReference(ObjectReference akObject)
    Parent._InitializeReference(akObject)

    Bool kFollowerFinished = True
    TryLockGuard _trackedReferenceGuard
        Actor kActor = akObject as Actor
        If !IsNone(kActor) 
            Int i = 0
            Int count = 0
            Bool equipped = False
            Int iCheckCount = 0 ; kActor.GetValueInt(EquipmentCheckCount)
            Int iFoundCount = 0
            ; If kActor != None

            EquipmentMap[] armr = _detectedEquipment.GetActorEquipmentMap(kActor) ; CurrentEquipment.GetActorEquipmentMap(kActor)
            Logger.Log("CurrentEquipment.GetActorEquipment(" + kActor + "):" + armr)

            count = armr.Length

            If _equipmentCheckCount.Contains(kActor)
                iCheckCount = _equipmentCheckCount.GetKeyValue(kActor) as Int ; kActor.GetValueInt(EquipmentCheckCount)
            EndIf

            If _equipmentFoundCount.Contains(kActor)
                iFoundCount = _equipmentFoundCount.GetKeyValue(kActor) as Int
            EndIf

            ; Debug.Notification("Found " + count + " equipment for " + kActor.GetFormID())
            If iFoundCount < iCheckCount
                kFollowerFinished = False
            EndIf

            While i < count
                EquipmentMap kMap = armr[i]
                If !kMap.IsRegistered ; && _detectedEquipment.Contains(kMap)
                    If kActor.IsEquipped(kMap.Equipment)
                        Debug.Notification("Init Found " + kMap.Equipment + " for " + kMap.OwnerRef)
                        _detectedEquipment.Remove(kMap)
                        kMap.IsRegistered = True
                        _RegisterActorEquipmentMap(kMap)
                        iFoundCount += 1
                    Else
                        kActor.EquipItem(kMap.Equipment)
                        kFollowerFinished = False
                    EndIf
                EndIf

                Logger.Log("kActor.IsEquipped(" + kMap.Equipment + "): " + kFollowerFinished)
                ; Debug.Notification(armr[i]. + " is equipped to actor: " + kActor.GetFormEditorID() + ":" + kFollowerFinished)
                i +=  1
            EndWhile
            ;  EndTryLockGuard
            ; EndIf

            Debug.Notification("Found " + iFoundCount + "/" + iCheckCount + " equipment for " + kActor)
            Logger.Log("Found " + iFoundCount + "/" + iCheckCount + " equipment for " + kActor as String)
            If iCheckCount == 0 \
                || (iFoundCount > 0 \
                    && iFoundCount >= iCheckCount)
                 kFollowerFinished = True
            ElseIf _currentCheckTimerCycle >= _maxCheckTimerCycle \
                && (iFoundCount == 0 \
                || iFoundCount < iCheckCount)
                kFollowerFinished = False
            EndIf

            ; kActor.SetValue(EquipmentCheckCount, iCheckCount)
            
            If kFollowerFinished
                _equipmentCheckCount.Remove(kActor)
                _equipmentFoundCount.Remove(kActor)
 
                Form[] currentEquip = CurrentEquipment.GetActorEquipment(kActor)
                ; Form[] lastEquip = TrackedFollowersLastEquipment.GetActorEquipment(kActor)
                Logger.Log("currentEquip:" + currentEquip)
                ; Logger.Log("lastEquip:" + lastEquip)
            EndIf

            armr = CurrentEquipment.GetActorEquipmentMap(kActor)
            Logger.Log("CurrentEquipment.GetActorEquipment(" + kActor + "):" + armr)
        EndIf
    Else
       kFollowerFinished = False
    EndTryLockGuard

    return kFollowerFinished
EndFunction

Bool Function _UnregisterReference(ObjectReference akObject)
    Actor kActor = akObject as Actor

    TryLockGuard _trackedReferenceGuard
        _detectedEquipment.RemoveActor(kActor)
        _equipmentCheckCount.Remove(kActor)
        _equipmentFoundCount.Remove(kActor)

        If !CachingEnabled
            CurrentEquipment.RemoveActor(kActor)
        EndIf
    EndTryLockGuard

    return !_detectedEquipment.ContainsActor(kActor) \
            && !_equipmentCheckCount.Contains(kActor) \
            && !_equipmentFoundCount.Contains(kActor)
            ; CurrentEquipment.RemoveActor(kActor).Length > 0
EndFunction

Function _HandleItemEquipped(Actor akActor, Form akBaseObject)
    ; TryLockGuard _trackedReferenceEquipmentGuard
        Keyword kArmorType = Utilities.Armors.GetArmorType(akBaseObject)
        Logger.Log("OnItemEquipped:GetArmorType:" + kArmorType)

        If kArmorType
            If InitializedReferences.Contains(akActor)
                Logger.Log("AddFollowerArmor(" + akActor + ", " + akBaseObject + ", " + kArmorType + ")")
                _RegisterActorEquipment(akActor, akBaseObject, kArmorType, True)
            ; ElseIf _detectedEquipment.ContainsActorEquipment(akActor, akBaseObject)
            ;     EquipmentMap kMap = _detectedEquipment.GetActorEquipmentTypeMap(akActor, kArmorType)
            ;     If kMap != None && !kMap.IsRegistered
            ;         Debug.Notification("Event Found " + akBaseObject + " for " + akActor)
            ;         kMap.IsRegistered = True
            ;         Int iFoundCount = 0
            ;         If _equipmentFoundCount.Contains(akActor)
            ;             iFoundCount = _equipmentFoundCount.GetKeyValue(akActor) as Int
            ;         EndIf

            ;         iFoundCount += 1
            ;         _equipmentFoundCount.Update(akActor, iFoundCount)
            ;         _RegisterActorEquipmentMap(kMap)
            ;     EndIf

            ;     If kMap.IsRegistered
            ;         _detectedEquipment.Remove(kMap)
            ;     EndIf
            ; Else
            ;     Logger.Log("")s
            ;     kActor.UnequipItem(akBaseObject, abSilent = False)
            EndIf
        EndIf
    ; EndTryLockGuard
EndFunction

Function _HandleItemUnequipped(Actor akActor, Form akBaseObject)
    TryLockGuard _trackedReferenceEquipmentGuard
        Bool bEquip
        Bool firstAdd
        Keyword kArmorType = Utilities.Armors.GetArmorType(akBaseObject)
        Logger.Log("OnItemUnequipped:GetArmorType: " + kArmorType)

        If !IsNone(kArmorType)
            ; Int rIndex = 0
            Int index = Find(akActor)
            ; _AddFollowerLastArmor(kActor, akBaseObject, kArmorType)

            If !InitializedReferences.Contains(akActor)
                Logger.Log("First Time Add:kActor:" + akActor)
                Logger.Log("First Time Add:index:" + index)
                Logger.Log("Follower Not Initialized, Re-equipping armor:" + akActor)
                
                If !_detectedEquipment.ContainsActorEquipmentType(akActor, kArmorType) \
                    && !CurrentEquipment.ContainsActorEquipmentType(akActor, kArmorType)
                    _ShowDetectionNotification(akActor, akBaseObject)
                    _detectedEquipment.AddActorEquipmentType(akActor, akBaseObject, kArmorType)

                    ; Int iFoundCount = 0
                    ; If _equipmentFoundCount.Contains(akActor)
                    ;     iFoundCount = _equipmentFoundCount.GetKeyValue(akActor) as Int
                    ; EndIf

                    ; iFoundCount += 1
                    ; _equipmentFoundCount.Update(akActor, iFoundCount)
                    ; _AddFollowerArmor(akActor, akBaseObject, kArmorType)
                EndIf
                
                ; akActor.EquipItem(akBaseObject, abSilent = True)

                ; _CheckFollowerArmor()
                ; Debug.Notification("Re-equipping " + kArmorType.GetFormEditorID() + " to " + kActor.GetFormEditorID())
            ; Else
            ;     TryLockGuard _trackedReferenceEquipmentGuard 
            ;         CurrentEquipment.RemoveActorEquipmentType(akActor, kArmorType)
            ;         Logger.Log("CurrentEquipment:" + CurrentEquipment.ToString())
            ;     EndTryLockGuard
            ;     ; Debug.Notification("Removed " + kArmorType.GetFormEditorID() + " from " + kActor.GetFormEditorID())
            EndIf
        EndIf
    EndTryLockGuard    
EndFunction

Int Function _RegisterActorEquipment(Actor akActor, Form akBaseObject, Keyword akArmorType = None, Bool abIsRegistered = False)
    If IsNone(akArmorType)
        akArmorType = Utilities.Armors.GetArmorType(akBaseObject)
    EndIf

    Logger.Log("AddFollowerArmor(" + akActor + ", " + akBaseObject + ", " + akArmorType + ")")
    EquipmentMap kMap = new EquipmentMap
    kMap.OwnerRef = akActor
    kMap.Equipment = akBaseObject
    kMap.EquipmentType = akArmorType
    kMap.IsRegistered = abIsRegistered

    return _RegisterActorEquipmentMap(kMap)
EndFunction

Int Function _RegisterActorEquipmentMap(EquipmentMap akMap)
    Int i = -1
    TryLockGuard _trackedReferenceEquipmentGuard
        ; Logger.Log("AddFollowerArmor(" + akActor + ", " + akBaseObject + ", " + akArmorType + ")")
        i = CurrentEquipment.Add(akMap)
        Logger.Log("Registered EquipmentMap: " + akMap)
    EndTryLockGuard

    return i
EndFunction

Function _UpdateEquipmentCounts(Actor akActor, Int aiFound = -1, Int aiCheck = -1)
    
EndFunction

Function _ShowDetectionNotification(Actor akActor, Form akEquipment, ObjectReference akEquipmentRef = None)

    TryLockGuard _messageAliasGuard
        ObjectReference kEquipRef = akEquipmentRef
        If IsNone(akEquipmentRef)
            kEquipRef = CreateReference(akActor, akEquipment)
            kEquipRef.Enable()
        EndIf
    
        MessageTextHolder.ForceRefTo(akActor)
        EquipmentTextHolder.ForceRefTo(kEquipRef)

        Keyword kArmorType = Utilities.Armors.GetArmorType(akEquipment)
        If kArmorType == Utilities.Armors.Backpack
            DetectedBackpackMessage.Show()
        Else
            DetectedEquipmentMessage.Show()
        EndIf

        If IsNone(akEquipmentRef)
            kEquipRef.Delete()
        EndIf

        MessageTextHolder.Clear()
        EquipmentTextHolder.Clear()
    Else   
        return 
        ; TODO - queue and display messages on a timer
    EndTryLockGuard
EndFunction