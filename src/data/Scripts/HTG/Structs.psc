Scriptname HTG:Structs
import HTG:Collections

Struct LogSeverity
    Int Info = 0 Hidden
    Int Warning = 1 Hidden
    Int Error = 2 Hidden
EndStruct

Struct SystemTimerDefaults
    Float Interval = 0.01 Hidden
    Int MaxCycles = 100 Hidden
EndStruct 

Struct SystemWaitDefaults
    Float Time = 0.1 Hidden
    Int MaxCycles = 10 Hidden
EndStruct

Struct SystemTimerIds
    Int InitializeId = 1000 Hidden
    Int InitialRunId = 1001 Hidden
    Int MainId = 2000 Hidden
    Int TutorialId = 3000 Hidden
    Int MessageId = 4000 Hidden
EndStruct

Struct SystemStageIds
    Int TutorialId = 3000 Hidden
    Int MessageId = 4000 Hidden
    Int UnitySaveDataId = 5000 Hidden
    Int UnityLoadDataId = 5001 Hidden
EndStruct

Struct SystemMenuIds
    String Barter = "BarterMenu" Hidden
    String ObjectContainer = "ContainerMenu" Hidden
    String Chargen = "ChargenMenu" Hidden
    String Crew = "ShipCrewMenu" Hidden
    String Data = "DataMenu" Hidden
    String Favorites = "FavoritesMenu" Hidden
    String GalaxyMap = "GalaxyStarMapMenu" Hidden
    String Inventory = "InventoryMenu" Hidden
    String Mission = "BSMissionMenu" Hidden
    String Loading = "LoadingMenu" Hidden
    String Looks = "LooksMenu" Hidden
    String Main = "MainMenu" Hidden
    String Monocle = "MonocleMenu" Hidden
    String Pause = "PauseMenu" Hidden
    String Research = "ResearchMenu" Hidden
    String Security = "SecurityMenu" Hidden
    String Sit = "SitWaitMenu" Hidden
    String Skills = "SkillsMenu"Hidden
    String Sleep = "SleepWaitMenu" Hidden
    String Spaceship = "SpaceshipInfoMenu" Hidden
    String SpaceshipBuilder = "SpaceshipEditorMenu" Hidden
    String Status = "StatusMenu" Hidden
    String OutpostBuilder = "IndustrialCraftingMenu" Hidden
EndStruct

Struct LeveledItemInjectionSet
    LeveledItem BasicList
    LeveledItem CalibratedList
    LeveledItem AdvancedList
    LeveledItem SuperiorList
    LeveledItem RareList
    LeveledItem EpicList
    LeveledItem LengendaryList
EndStruct

Struct ArmorSet
    Armor Helmet
    Armor Backpack
    Armor Spacesuit
EndStruct

Struct ClothingSet
    Armor Hat
    Armor NeuroAmp
    Armor Clothes
EndStruct

Struct LeveledArmorSet
    LeveledItem Helmet
    LeveledItem Backpack
    LeveledItem Spacesuit
EndStruct

Struct QuestCheckInfo
    String QuestName
    Quest QuestObject
    int Stage
    Form RewardItem
    bool CompletionCheck
    bool UnityCheck
    int UnityCheckTimes
EndStruct

Struct KeyValuePair
    Form KeyForm
    Form ValueForm
EndStruct

Struct VersionInfomation
    Int Major
    Int Minor
    Int Revision
    Int Patch = 115222
EndStruct

Struct HoloArmorMap
    Armor ArmorPiece
    ObjectMod ArmorMod
EndStruct

Struct HoloArmorSet
    Keyword ArmorType
    Armor Helmet
    Armor Backpack
    Armor Spacesuit
EndStruct

Struct SystemTypeEntry
    Int FormId
    String FormName
    String EditorId
    String Script
    String ModName
EndStruct

Struct SystemTypeCacheEntry
    Int FormId
    String FormName
    String EditorId
    String Script
    Int ModuleIndex Hidden
EndStruct

Struct SystemTypeScriptEntry
    Int Id
    String Name
EndStruct

; Struct SystemTypeId
;     Int Form = 0
;     Int 
; EndStruct

Struct SystemFeature
    String Name
    GlobalVariable FeatureGlobal
    GameplayOption FeatureOption
    Quest FeatureController
    SystemDependencyEntryList Dependencies
EndStruct

Struct SystemFeatureEntry
    Int Id
    String Name
    String FeatureGlobal
    String FeatureOption
    String FeatureController
EndStruct

Struct SystemFeatureRequest
    String Name
    Form Sender
EndStruct

Struct SystemMessageEntry
    String EditorId
    Message Entry
    Bool IsHelpMessage
    Bool IsMessageBox
    Float Duration = 30.0
	Float Interval = 30.0
	Int MaxTimes = 1
	Int Priority = 0
    Bool AlwaysShow
	Float DelayTime = 0.0
    String Context = ""
    String EventName = ""
	Int TimesShown Hidden
EndStruct

Struct SystemMessageAliasEntry
    Int MessageEntryIndex
    ReferenceAlias Entry
EndStruct

Struct EquipmentMap
    ObjectReference OwnerRef
    Form Equipment
    Keyword EquipmentType
    Bool IsRegistered Hidden
EndStruct