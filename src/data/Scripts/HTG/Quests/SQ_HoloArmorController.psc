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

; KeyValuePair[] Property DefaultArmorMappings Mandatory Const Auto
FormDictionary Property ArmorMappings Auto Hidden
PlayerHoloArmorTracker Property PlayerTracker Auto Const

Guard _armorMappingsGuard ProtectsFunctionLogic
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
;             TryLockGuard _armorMappingsGuard
;                 _refreshTimerStarted = True
;                 _UpdateArmorMappings()
;                 _refreshTimerStarted = False
;             EndTryLockGuard
;         EndIf  

;         StartTimer(1, _refreshTimerId)
;     EndIf
; EndEvent

; Bool Function _Init()
;     ; TryLockGuard _armorMappingsGuard
;         return _CreateCollections()
;     ; EndTryLockGuard
; EndFunction

; Function _InitialRun()
;     StartTimer(0.1, _refreshTimerId)    
; EndFunction

Bool Function _CreateCollections()
    If IsNone(ArmorMappings)
        ArmorMappings = HTG:Collections:FormDictionary.FormDictionaryIntegrated(SystemUtilities.ModInfo)
        ; ArmorMappings.AddArray(DefaultArmorMappings)

        If IsNone(ArmorMappings)
            Logger.ErrorEx("Unable to create collection: " + ArmorMappings)
            return False
        EndIf
    EndIf
    
    If !ArmorMappings.IsInitialized || !_UpdateArmorMappings()
        return False
    EndIf

    return True
EndFunction

ObjectMod Function GetArmorMod(Armor akArmor)
    WaitForInitialized()

    ObjectMod res
    Int i
    HTG:ArmorUtility kArmorUtil = SystemUtilities.Armors
    Keyword kType = kArmorUtil.GetArmorType(akArmor)
    If kType == kArmorUtil.Backpack
        i = KnownBackpacks.Find(akArmor)
        If i > -1
            res = BackpackMods.GetAt(i) as ObjectMod
        EndIf
    ElseIf kType == kArmorUtil.Helmet
        i = KnownHelmets.Find(akArmor)
        If i > -1
            res = HelmetMods.GetAt(i) as ObjectMod
        EndIf
    ElseIf kType == kArmorUtil.Spacesuit
        i = KnownSpacesuits.Find(akArmor)
        If i > -1
            res = SpacesuitMods.GetAt(i) as ObjectMod
        EndIf
    EndIf

    return res
    ;return ArmorMappings.GetKeyValue(akArmor) as ObjectMod
EndFunction

Bool Function _UpdateArmorMappings()
    Int i = 0
    Bool kBackpackChanged
    Bool kHelmetChanged
    Bool kSpacesuitChanged

    If _knownBackpackCount != KnownBackpacks.GetSize()
        _knownBackpackCount = KnownBackpacks.GetSize()

        kBackpackChanged = True
    EndIf

    If _backpackModCount != BackpackMods.GetSize()
        _backpackModCount = BackpackMods.GetSize()

        kBackpackChanged = True
    EndIf

    If _knownHelmetCount != KnownHelmets.GetSize()
        _knownHelmetCount = KnownHelmets.GetSize()

        kHelmetChanged = True
    EndIf

    If _helmetModCount != HelmetMods.GetSize()
        _helmetModCount = HelmetMods.GetSize()

        kHelmetChanged = True
    EndIf

    If _knownSpacesuitCount != KnownSpacesuits.GetSize()
        _knownSpacesuitCount = KnownSpacesuits.GetSize()

        kSpacesuitChanged = True
    EndIf

    If _spacesuitModCount != SpacesuitMods.GetSize()
        _spacesuitModCount = SpacesuitMods.GetSize()

        kSpacesuitChanged = True
    EndIf

    ; _CreateCollections()

    If kBackpackChanged
        While i <= (_knownBackpackCount - 1)
            ArmorMappings.Add(KnownBackpacks.GetAt(i), BackpackMods.GetAt(i))
            i += 1
        EndWhile
    EndIf

    If kHelmetChanged
        i = 0
        While i <= (_knownHelmetCount - 1)
            ArmorMappings.Add(KnownHelmets.GetAt(i), HelmetMods.GetAt(i))
            i += 1
        EndWhile
    EndIf

    If kSpacesuitChanged
        i = 0
        While i <= (_knownSpacesuitCount - 1)
            ArmorMappings.Add(KnownSpacesuits.GetAt(i), SpacesuitMods.GetAt(i))
            i += 1
        EndWhile
    EndIf

    If kBackpackChanged || kHelmetChanged || kSpacesuitChanged
        Logger.Log("Updated ArmorMappings:\n" + ArmorMappings.ToString())
    EndIf

    return kBackpackChanged || kHelmetChanged || kSpacesuitChanged
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