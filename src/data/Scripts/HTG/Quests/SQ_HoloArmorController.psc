Scriptname HTG:Quests:SQ_HoloArmorController extends HTG:QuestExt
{HoloArmor System Controller}
import HTG
import HTG:Structs
import HTG:Collections
import HTG:UtilityExt

HoloArmorSet[] Property DefaultHoloArmorSets Mandatory Const Auto
HoloArmorSetList Property HoloArmorSets Auto Hidden

Keyword Property CurrentHoloArmorType Hidden
    Keyword Function Get()
        return _currentArmorType
    EndFunction
EndProperty

FormList Property BackpackMods Mandatory Const Auto
FormList Property HelmetMods Mandatory Const Auto
FormList Property SpacesuitMods Mandatory Const Auto

FormList Property KnownBackpacks Mandatory Const Auto
FormList Property KnownHelmets Mandatory Const Auto
FormList Property KnownSpacesuits Mandatory Const Auto

HoloArmorMap[] Property ArmorBackpackMappingDefaults Mandatory Const Auto
HoloArmorMap[] Property ArmorHelmetMappingDefaults Mandatory Const Auto
HoloArmorMap[] Property ArmorSpacesuitMappingDefaults Mandatory Const Auto
HoloArmorMapList Property ArmorBackpackMappings Auto Hidden
HoloArmorMapList Property ArmorHelmetMappings Auto Hidden
HoloArmorMapList Property ArmorSpacesuitMappings Auto Hidden
ReferenceAliasHoloArmorTracker Property PlayerTracker Mandatory Auto Const

Guard _ArmorMappingsGuard ProtectsFunctionLogic
Guard _playerTrackerGuard ProtectsFunctionLogic
Int _refreshTimerId = 1
Bool _refreshTimerStarted
Int _knownBackpackCount
Int _knownHelmetCount
Int _knownSpacesuitCount
Int _backpackModCount
Int _helmetModCount
Int _spacesuitModCount
Int _armorSetCount
Keyword _currentArmorType

; Event OnTimer(int aiTimerID)
;     Parent.OnTimer(aiTimerID)

;     If aiTimerID == _refreshTimerId
;         If !_refreshTimerStarted
;             ; WaitForInitialized()
;             TryLockGuard _ArmorBackpackMappingsGuard
;                 _refreshTimerStarted = True
;                 _UpdateArmorBackpackMappings()
;                 _refreshTimerStarted = False
;             EndTryLockGuard
;         EndIf  

;         StartTimer(1, _refreshTimerId)
;     EndIf
; EndEvent

; Function _InitialRun()
;     StartTimer(0.1, _refreshTimerId)    
; EndFunction

Event ObjectReference.OnEquipped(ObjectReference akSender, Actor akActor)
    Keyword[] kTypes = HoloArmorSets.GetArmorTypes()
    Int i = 0
    While i < kTypes.Length
        Keyword kType = kTypes[i]
        If akSender.HasKeyword(kType)
            _currentArmorType = kType
        EndIf
        i += 1
    EndWhile
EndEvent

ObjectMod[] Function GetAllArmorMods(Armor akArmor)
    WaitForInitialized()

    ObjectMod[] res = new ObjectMod[0]
    Int i = 0
    HTG:SystemArmorUtility kArmorUtil = Utilities.Armors

    Keyword[] kTypes = kArmorUtil.GetAllArmorTypes(akArmor)
    While i < kTypes.Length
        Keyword kType = kTypes[i]
        If kType == kArmorUtil.Backpack
            res.Add(ArmorBackpackMappings.GetMod(akArmor))
        ElseIf kType == kArmorUtil.Helmet
            res.Add(ArmorHelmetMappings.GetMod(akArmor))
        ElseIf kType == kArmorUtil.Spacesuit
            res.Add(ArmorSpacesuitMappings.GetMod(akArmor))
        EndIf
        i += 1
    EndWhile

    return res
EndFunction

ObjectMod Function GetArmorMod(Armor akArmor)
    WaitForInitialized()

    ObjectMod res
    Int i = 0
    HTG:SystemArmorUtility kArmorUtil = Utilities.Armors

    Keyword kType = kArmorUtil.GetArmorType(akArmor)
    If kType == kArmorUtil.Backpack
        res = ArmorBackpackMappings.GetMod(akArmor)
    ElseIf kType == kArmorUtil.Helmet
        res = ArmorHelmetMappings.GetMod(akArmor)
    ElseIf kType == kArmorUtil.Spacesuit
        res = ArmorSpacesuitMappings.GetMod(akArmor)
    EndIf
    i += 1

    return res
EndFunction

ArmorSet Function GetCurrentArmorSet()
    WaitForInitialized()

    ArmorSet kRes = HoloArmorSets.GetArmorSet(_currentArmorType)
    If kRes == None
        kRes = new ArmorSet
        kRes.Backpack = DefaultHoloArmorSets[0].Backpack
        kRes.Helmet = DefaultHoloArmorSets[0].Helmet
        kRes.Spacesuit = DefaultHoloArmorSets[0].Spacesuit
    EndIf

    return kRes
EndFunction

ArmorSet Function GetHoloArmorFromMod(ObjectMod akMod)
    WaitForInitialized()
    
    Int i = 0
    Bool bFound
    HoloArmorSet kSet
    ArmorSet kRes = new ArmorSet

    While i < HoloArmorSets.Count && !bFound
        kSet = HoloArmorSets.GetAt(i)
        bFound = akMod.HasKeyword(kSet.ArmorType)
        i += 1
    EndWhile 

    If bFound
        kRes.Backpack = kSet.Backpack
        kRes.Helmet = kSet.Helmet
        kRes.Spacesuit = kSet.Spacesuit
    EndIf

    return kRes
EndFunction

Bool Function EquipArmorToPlayer()
    WaitForInitialized()

    TryLockGuard _playerTrackerGuard
        ; ReferenceAliasHoloArmorTracker kTracker = GetAlias(2) as ReferenceAliasHoloArmorTracker
        return PlayerTracker.EquipHoloArmor()
    EndTryLockGuard
EndFunction

Bool Function UnequipArmorToPlayer()
    WaitForInitialized()

    TryLockGuard _playerTrackerGuard
        ; ReferenceAliasHoloArmorTracker kTracker = GetAlias(2) as ReferenceAliasHoloArmorTracker
        return PlayerTracker.UnequipHoloArmor()
    EndTryLockGuard
EndFunction

Bool Function ChangePlayerArmorAppearance(Armor akArmor)
    WaitForInitialized()

    TryLockGuard _playerTrackerGuard
        ; ReferenceAliasHoloArmorTracker kTracker = GetAlias(2) as ReferenceAliasHoloArmorTracker
        return PlayerTracker.ChangeArmorPieceAppearance(akArmor)
    EndTryLockGuard
EndFunction

Bool Function _CreateCollections()
    ; TryLockGuard _ArmorMappingsGuard
        If IsNone(ArmorBackpackMappings)
            ArmorBackpackMappings = HTG:Collections:HoloArmorMapList.HoloArmorMapList(Utilities.ModInfo)
            ; ArmorBackpackMappings.AddArray(DefaultArmorBackpackMappings)
        EndIf
        
        If IsNone(ArmorHelmetMappings)
            ArmorHelmetMappings = HTG:Collections:HoloArmorMapList.HoloArmorMapList(Utilities.ModInfo)
            ; ArmorHelmetMappings.AddArray(DefaultArmorHelmetMappings)
        EndIf

        If IsNone(ArmorSpacesuitMappings)
            ArmorSpacesuitMappings = HTG:Collections:HoloArmorMapList.HoloArmorMapList(Utilities.ModInfo)
            ; ArmorSpacesuitMappings.AddArray(DefaultArmorSpacesuitMappings)
        EndIf

        If IsNone(HoloArmorSets)
            HoloArmorSets = HTG:Collections:HoloArmorSetList.HoloArmorSetList(Utilities.ModInfo)
        EndIf
    ; EndTryLockGuard
    
    return ((!IsNone(ArmorBackpackMappings) && ArmorBackpackMappings.IsInitialized) \
                && (!IsNone(ArmorHelmetMappings) && ArmorHelmetMappings.IsInitialized) \
                && (!IsNone(ArmorSpacesuitMappings) && ArmorSpacesuitMappings.IsInitialized) \
                && (!IsNone(HoloArmorSets) && HoloArmorSets.IsInitialized)) \
            && _UpdateArmorMappings() && _UpdateArmorSets()
EndFunction

Bool Function _UpdateArmorMappings()
    _backpackModCount = ArmorBackpackMappings.AddMappings(ArmorBackpackMappingDefaults)
    _helmetModCount = ArmorHelmetMappings.AddMappings(ArmorHelmetMappingDefaults)
    _spacesuitModCount = ArmorSpacesuitMappings.AddMappings(ArmorSpacesuitMappingDefaults)

    ; Int i = 0
    ; Bool kBackpackChanged
    ; Bool kHelmetChanged
    ; Bool kSpacesuitChanged

    ; If _knownBackpackCount != KnownBackpacks.GetSize()
    ;     _knownBackpackCount = KnownBackpacks.GetSize()

    ;     kBackpackChanged = True
    ; EndIf

    ; If _backpackModCount != BackpackMods.GetSize()
    ;     _backpackModCount = BackpackMods.GetSize()

    ;     kBackpackChanged = True
    ; EndIf

    ; If _knownHelmetCount != KnownHelmets.GetSize()
    ;     _knownHelmetCount = KnownHelmets.GetSize()

    ;     kHelmetChanged = True
    ; EndIf

    ; If _helmetModCount != HelmetMods.GetSize()
    ;     _helmetModCount = HelmetMods.GetSize()

    ;     kHelmetChanged = True
    ; EndIf

    ; If _knownSpacesuitCount != KnownSpacesuits.GetSize()
    ;     _knownSpacesuitCount = KnownSpacesuits.GetSize()

    ;     kSpacesuitChanged = True
    ; EndIf

    ; If _spacesuitModCount != SpacesuitMods.GetSize()
    ;     _spacesuitModCount = SpacesuitMods.GetSize()

    ;     kSpacesuitChanged = True
    ; EndIf

    ; ; _CreateCollections()

    ; If kBackpackChanged
    ;     While i <= (_knownBackpackCount - 1)
    ;         ArmorBackpackMappings.AddMod(akArmorMod, akArmorPiece)(KnownBackpacks.GetAt(i), BackpackMods.GetAt(i))
    ;         i += 1
    ;     EndWhile
    ; EndIf

    ; If kHelmetChanged
    ;     i = 0
    ;     While i <= (_knownHelmetCount - 1)
    ;         ArmorBackpackMappings.Add(KnownHelmets.GetAt(i), HelmetMods.GetAt(i))
    ;         i += 1
    ;     EndWhile
    ; EndIf

    ; If kSpacesuitChanged
    ;     i = 0
    ;     While i <= (_knownSpacesuitCount - 1)
    ;         ArmorBackpackMappings.Add(KnownSpacesuits.GetAt(i), SpacesuitMods.GetAt(i))
    ;         i += 1
    ;     EndWhile
    ; EndIf

    ; If kBackpackChanged || kHelmetChanged || kSpacesuitChanged
    ;     Logger.Log("Updated ArmorBackpackMappings:\n" + ArmorBackpackMappings.ToString())
    ; EndIf

    ; return kBackpackChanged || kHelmetChanged || kSpacesuitChanged
    return _backpackModCount && _helmetModCount && _spacesuitModCount
EndFunction

Bool Function _UpdateArmorSets()
    _armorSetCount = HoloArmorSets.AddArmorSets(DefaultHoloArmorSets)

    return _armorSetCount
EndFunction

Bool Function _Init()
    If IsNone(_currentArmorType)
        _currentArmorType = DefaultHoloArmorSets[0].ArmorType
    EndIf

    return Parent._Init() \
            && !IsNone(_currentArmorType)
EndFunction