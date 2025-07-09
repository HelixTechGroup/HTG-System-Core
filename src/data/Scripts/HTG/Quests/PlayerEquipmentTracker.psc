Scriptname HTG:Quests:PlayerEquipmentTracker extends HTG:ReferenceAliasInventoryTracker
{Script attached to Player reference alias.
Manages Equipment tracking for the Player}
import HTG
import HTG:Structs
import HTG:FormUtility
import HTG:UtilityExt
import HTG:Collections
import HTG:SystemLogger

FormListExt Property CurrentEquipment Auto Hidden

Guard _trackedPlayerArmorGuard ProtectsFunctionLogic
Guard _setupTimerGuard ProtectsFunctionLogic
Int _maxEquipTimerCycle = 30
Int _currentEquipTimerCycle
Bool _isPlayerInitialized
FormListExt _detectedEquipment
Int _detectedEquipmentCount
Int _foundEquipmentCount
Bool _setupComplete
Int _setupTimerId = 1002
Int _maxSetupTimerCycle = 150
Int _currentSetupTimerCycle
Bool _setupTimerStarted
Bool _registrationStarted
Bool _checkStarted

Event OnAliasStarted()
    Parent.OnAliasStarted()

    If IsFilled()
        StartTimer(SystemUtilities.Timers.TimerDefaults.Interval, _setupTimerId)
    EndIf
EndEvent

Event OnAliasChanged(ObjectReference akObject, bool abRemove)
    Parent.OnAliasChanged(akObject, abRemove)
    
    If abRemove 
        StartTimer(SystemUtilities.Timers.TimerDefaults.Interval, _setupTimerId)
    EndIf
EndEvent

Event OnAliasReset()
    Parent.OnAliasReset()

    _currentEquipTimerCycle = 0
    _currentSetupTimerCycle = 0
    _detectedEquipmentCount = 0
    _foundEquipmentCount = 0
    _isPlayerInitialized = False
    _setupComplete = False
EndEvent

Event OnTimer(int aiTimerID)
    Parent.OnTimer(aiTimerID)

    if aiTimerID == _setupTimerId
        If _setupComplete
            return
        EndIf

        Float itimerInterval = 0.1
        Int timerId = -1

        TryLockGuard _setupTimerGuard, _trackedPlayerArmorGuard
            _setupTimerStarted = True
            If !_SetupActor() &&  _currentSetupTimerCycle < _maxSetupTimerCycle            
                _currentSetupTimerCycle += 1
                timerId = _setupTimerId
            ElseIf !_setupComplete && _currentSetupTimerCycle == _maxSetupTimerCycle
                Logger.ErrorEx("HTG:SystemUtililities could not be Initialized")
                return
            Else
                Logger.Log("InitializeTimer - Is Initialized. Starting ReadyTimer")
                timerId = SystemUtilities.Timers.SystemTimerIds.MainId
            EndIf
            _setupTimerStarted = False
        EndTryLockGuard

        If timerid > -1
            StartTimer(itimerInterval, timerId)
        EndIf
    EndIf
EndEvent

ArmorSet Function GetActorArmorSet()
    WaitForInitialized()
    
    ArmorSet kResult = new ArmorSet
    Var[] kEquipment = CurrentEquipment.GetArray()
    Int i 
    While i < kEquipment.Length
        Armor kArmor = kEquipment[i] as Armor
        If !IsNone(kArmor)
            HTG:ArmorUtility kArmorUtil = SystemUtilities.Armors
            Keyword kType = kArmorUtil.GetArmorType(kArmor)
            If kType == kArmorUtil.Backpack
                kResult.Backpack = kArmor
            ElseIf kType == kArmorUtil.Helmet
                kResult.Helmet = kArmor
            ElseIf kType == kArmorUtil.Spacesuit
                kResult.Spacesuit = kArmor
            EndIf
        EndIf

        i += 1
    EndWhile

    return kResult
EndFunction

Bool Function _Init()
    return Parent._Init() \
            && _CreateLists()
EndFunction

Bool Function _Main()
    return _CheckActorEquipment()
EndFunction

Bool Function _CreateLists()
    TryLockGuard _trackedPlayerArmorGuard
        If IsNone(CurrentEquipment) ; || CurrentEquipment == None
            CurrentEquipment = HTG:Collections:FormListExt.FormListExtIntegrated(SystemUtilities.ModInfo)
            Logger.Log("Creating FollowersCurrentEquipment:\n" + CurrentEquipment.ToString())
        EndIf

        If IsNone(_detectedEquipment)
            _detectedEquipment = HTG:Collections:FormListExt.FormListExtIntegrated(SystemUtilities.ModInfo)
            Logger.Log("Created _detectedEquipment:\n" + _detectedEquipment.ToString())
        Else
            _detectedEquipment.Clear()
            Logger.Log("Cleared _detectedEquipment:\n" + _detectedEquipment.ToString())
        EndIf
    EndTryLockGuard

    ; TryLockGuard _trackedFollowersLastArmorGuard
    ; If !TrackedFollowersLastEquipment || TrackedFollowersLastEquipment == None        
    ;     TrackedFollowersLastEquipment = HTG:Followers:Collections:FollowerEquipmentList.FollowerEquipmentList()
    ;     Logger.Log("Creating TrackedFollowersLastEquipment:\n" + TrackedFollowersLastEquipment.ToString())
    ; EndIf
    ; EndTryLockGuard

    return CurrentEquipment.IsInitialized && _detectedEquipment.IsInitialized
EndFunction

Bool Function _SetupActor()
    If _setupComplete
        return True
    EndIf

    If !IsFilled()
        return False
    EndIf

    ; Int i = 0
    ; Int count = CurrentEquipment.Count

    ; If count < 0
    ;     While i < count 
    ;         Form kArmor = CurrentEquipment.GetAt(i)
    ;         Keyword kArmorType = SystemUtilities.Armors.GetArmorType(kArmor)
    ;         If !kActor.IsEquipped(kArmor)
    ;             Logger.Log("CurrentEquipment Equipment not found: " + kArmor)                
    ;             SystemUtilities.Armors.UnequipArmorType(kActor, kArmorType)
    ;         EndIf

    ;         i += 1
    ;     EndWhile

    ;     _setupComplete = True
    ; Else
        Logger.Log("CurrentEquipment Equipment empty: Removing all equipment.")                
        _setupComplete = _RegisterActorEquipment()

        If _setupComplete
            _CheckActorEquipment()
        EndIf
    ; EndIf
    
    return _setupComplete
EndFunction

Bool Function _RegisterActorEquipment()
    Int fI = 0
    Bool bHatFound
    Bool bClothesFound
    Bool bHelmetFound
    Bool bBackpackFound
    Bool bSpacesuitFound
    Int iCheckCount
    ArmorUtility kArmorUtil = SystemUtilities.Armors
    Logger.Log("RegisterFollowerTimer - Found Tracked followers.")
    Actor kActor = GetActorReference()

    Logger.Log("RegisterFollowerTimer - Checking follower: " + kActor)
    If !_isPlayerInitialized
        Logger.Log("RegisterFollowerTimer - Adding follower: " + kActor)
        Var[] kEquipment = CurrentEquipment.GetArray()
        Int aI = 0
        Int iCount = kEquipment.Length

        While aI < iCount
            Armor kArmor = kEquipment[aI] as Armor
            If !IsNone(kArmor)
                Keyword kArmorType = kArmorUtil.GetArmorType(kArmor)
                If !kActor.IsEquipped(kArmor)
                    Logger.Log("RegisterFollowerTimer - New Equipment found of type:" + kArmorType)
                    If kArmorType == kArmorUtil.Hat
                        bHatFound = True
                        Logger.Log("RegisterFollowerTimer - Registering Hat.")
                        kActor.UnequipItemSlot(kArmorUtil.HeadSlot) ; Hat
                    ElseIf kArmorType == kArmorUtil.Clothes
                        bClothesFound = True
                        Logger.Log("RegisterFollowerTimer - Registering Clothes.")
                        kActor.UnequipItemSlot(kArmorUtil.ClothesSlot) ; Clothes
                    ElseIf kArmorType == kArmorUtil.Helmet
                        bHelmetFound = True
                        Logger.Log("RegisterFollowerTimer - Registering Helmet.")
                        kActor.UnequipItemSlot(kArmorUtil.SSHeadSlot) ; Helmet        
                    ElseIf kArmorType == kArmorUtil.Backpack
                        bBackpackFound = True
                        Logger.Log("RegisterFollowerTimer - Registering Backpack.")
                        kActor.UnequipItemSlot(kArmorUtil.SSBackpackSlot) ; Backpack                            
                    ElseIf kArmorType == kArmorUtil.Spacesuit
                        bSpacesuitFound = True
                        Logger.Log("RegisterFollowerTimer - Registering Spacesuit.")
                        kActor.UnequipItemSlot(kArmorUtil.SSBodySlot) ; Spacesuit                    
                    EndIf
                    WaitExt(0.333)
                Else
                    Logger.Log("RegisterFollowerTimer - Existing Equipment found:" + kArmor + " Type:" + kArmorType)
                EndIf 
            EndIf

            aI += 1
        EndWhile

        If !bHatFound && \
            kActor.WornHasKeyword(kArmorUtil.Hat)
            Logger.Log("RegisterFollowerTimer - Registering Hat.")
            kActor.UnequipItemSlot(kArmorUtil.HeadSlot) ; Hat
            WaitExt(0.333)
            iCheckCount += 1
        EndIf

        If !bClothesFound && \
            kActor.WornHasKeyword(kArmorUtil.Clothes)
            Logger.Log("RegisterFollowerTimer - Registering Clothes.")
            kActor.UnequipItemSlot(kArmorUtil.ClothesSlot) ; Clothes
            WaitExt(0.333)
            iCheckCount += 1
        EndIf

        If !bHelmetFound && \
            kActor.WornHasKeyword(kArmorUtil.Helmet)          
            Logger.Log("RegisterFollowerTimer - Registering Helmet.")      
            kActor.UnequipItemSlot(kArmorUtil.SSHeadSlot) ; Helmet
            WaitExt(0.333)
            iCheckCount += 1
        EndIf

        If !bBackpackFound && \
            kActor.WornHasKeyword(kArmorUtil.Backpack)
            Logger.Log("RegisterFollowerTimer - Registering Backpack.")
            kActor.UnequipItemSlot(kArmorUtil.SSBackpackSlot) ; Backpack
            WaitExt(0.333)
            iCheckCount += 1
        EndIf

        If !bSpacesuitFound && \
            kActor.WornHasKeyword(kArmorUtil.Spacesuit)
            Logger.Log("RegisterFollowerTimer - Registering Spacesuit.")
            kActor.UnequipItemSlot(kArmorUtil.SSBodySlot) ; Spacesuit 
            WaitExt(0.333)
            iCheckCount += 1                   
        EndIf

        _detectedEquipmentCount = iCheckCount
        return _detectedEquipmentCount > 0
    EndIf

    return False                                                                                                                                        
EndFunction

Bool Function _CheckActorEquipment()
    If !_setupComplete || _registrationStarted || _checkStarted
        return True
    ElseIf _isPlayerInitialized
        return False
    EndIf

    _checkStarted = True
    Bool finished = True
    
    TryLockGuard _trackedPlayerArmorGuard
        Int i = 0
        Int count = _detectedEquipment.Count ; CurrentEquipment.Count - 1
        Actor kActor = GetActorReference()

        If _foundEquipmentCount < _detectedEquipmentCount
            finished = False
        EndIf

        If count > 0
            While i < count
                Form kArmor = _detectedEquipment.GetAt(i) ; CurrentEquipment.GetAt(i)
                If !IsNone(kArmor)
                    If !kActor.IsEquipped(kArmor)    
                        Logger.Log("CurrentEquipment Equipment not found: " + kArmor)                
                        kActor.EquipItem(kArmor)
                        WaitExt(0.333)
                        finished = False
                    Else
                        If !CurrentEquipment.Contains(kArmor)
                            CurrentEquipment.Add(kArmor)
                        EndIf

                        If _detectedEquipment.Contains(kArmor)
                            _detectedEquipment.Remove(kArmor)
                            _foundEquipmentCount += 1
                        EndIf
                    EndIf
                EndIf
                i += 1
            EndWhile

            Logger.Log("Found " + _foundEquipmentCount + "\\" + _detectedEquipmentCount + " equipment for " + kActor)
        EndIf

        If finished ; && (_foundEquipmentCount >= _detectedEquipmentCount)
            If SystemUtilities.IsDebugging
                Debug.Notification("Player Equipment Tracker has been Initialized.")
            EndIf
            Logger.Log("Player Equipment Tracker has been Initialized.")
            _isPlayerInitialized = True
        ElseIf _currentEquipTimerCycle < _maxEquipTimerCycle
            _currentEquipTimerCycle += 1
        ElseIf _currentEquipTimerCycle == _maxEquipTimerCycle
            If _foundEquipmentCount < _detectedEquipmentCount
                _RegisterActorEquipment()
                _currentEquipTimerCycle = 0
            EndIf
        EndIf
    EndTryLockGuard

    Logger.Log("Finshed checking player equipment: " + finished)
    _checkStarted = False
    return True ; !finished
EndFunction

Function _HandleItemEquipped(Form akBaseObject)
    Logger.Log("OnItemEquipped: " + akBaseObject)
    If SystemUtilities.Armors.GetArmorType(akBaseObject) \
        && !CurrentEquipment.Contains(akBaseObject)
        Logger.Log("CurrentEquipment.AddForm: " + akBaseObject)
        CurrentEquipment.Add(akBaseObject)

        If _detectedEquipment.Find(akBaseObject) > -1
            _detectedEquipment.Remove(akBaseObject)
            _foundEquipmentCount += 1
            _CheckActorEquipment()
        EndIf
    EndIf
EndFunction

Function _HandleItemUnequipped(Form akItem)
    Logger.Log("OnItemUnequipped: " + akItem)
    If SystemUtilities.Armors.GetArmorType(akItem)
        If _isPlayerInitialized \
            && CurrentEquipment.Contains(akItem)                
            Logger.Log("CurrentEquipment.RemoveAddedForm: " + akItem)
            CurrentEquipment.Remove(akItem)  
        Else
            If _detectedEquipment.Find(akItem) < 0
                ; WaitExt(0.333)
                GetActorReference().EquipItem(akItem, abSilent = True)
                _detectedEquipment.Add(akItem)
            EndIf
        EndIf
    EndIf
EndFunction