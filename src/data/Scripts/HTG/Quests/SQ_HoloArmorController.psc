Scriptname HTG:Quests:SQ_HoloArmorController extends HTG:QuestExt
{HoloArmor System Controller}
import HTG:Structs
import HTG:Collections
import HTG:UtilityExt

ArmorSet Property HoloArmor Mandatory Const Auto

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
PlayerHoloArmorTracker Property PlayerTracker Auto Const

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

ObjectMod Function GetArmorMod(Armor akArmor)
    WaitForInitialized()

    ObjectMod res
    Int i
    HTG:ArmorUtility kArmorUtil = Utilities.Armors
    Keyword kType = kArmorUtil.GetArmorType(akArmor)
    If kType == kArmorUtil.Backpack
        ; i = KnownBackpacks.Find(akArmor)
        ; If i > -1
        res = ArmorBackpackMappings.GetMod(akArmor)
        ; EndIf
    ElseIf kType == kArmorUtil.Helmet
        ; i = KnownHelmets.Find(akArmor)
        ; If i > -1
        res = ArmorHelmetMappings.GetMod(akArmor)
        ; EndIf
    ElseIf kType == kArmorUtil.Spacesuit
        ; i = KnownSpacesuits.Find(akArmor)
        ; If i > -1
        res = ArmorSpacesuitMappings.GetMod(akArmor)
        ; EndIf
    EndIf

    return res
EndFunction

Bool Function EquipArmorToPlayer()
    WaitForInitialized()

    TryLockGuard _playerTrackerGuard
        ; PlayerHoloArmorTracker kTracker = GetAlias(2) as PlayerHoloArmorTracker
        return PlayerTracker.EquipHoloArmor()
    EndTryLockGuard
EndFunction

Bool Function UnequipArmorToPlayer()
    WaitForInitialized()

    TryLockGuard _playerTrackerGuard
        ; PlayerHoloArmorTracker kTracker = GetAlias(2) as PlayerHoloArmorTracker
        return PlayerTracker.UnequipHoloArmor()
    EndTryLockGuard
EndFunction

Bool Function ChangePlayerArmorAppearance(Armor akArmor)
    WaitForInitialized()

    TryLockGuard _playerTrackerGuard
        ; PlayerHoloArmorTracker kTracker = GetAlias(2) as PlayerHoloArmorTracker
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
    ; EndTryLockGuard
    
    return ((!IsNone(ArmorBackpackMappings) && ArmorBackpackMappings.IsInitialized) \
                && (!IsNone(ArmorHelmetMappings) && ArmorHelmetMappings.IsInitialized) \
                && (!IsNone(ArmorSpacesuitMappings) && ArmorSpacesuitMappings.IsInitialized)) \
            && _UpdateArmorMappings()
EndFunction

Bool Function _UpdateArmorMappings()
    _backpackModCount = ArmorBackpackMappings.AddMappings(ArmorBackpackMappingDefaults).Length
    _helmetModCount = ArmorHelmetMappings.AddMappings(ArmorHelmetMappingDefaults).Length
    _spacesuitModCount = ArmorSpacesuitMappings.AddMappings(ArmorSpacesuitMappingDefaults).Length

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