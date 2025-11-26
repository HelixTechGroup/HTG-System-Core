Scriptname HTG:Structs

Struct LogSeverity
    Int Info = 0
    Int Warning = 1
    Int Error = 2
EndStruct

Struct SystemTimerDefaults
    Float Interval = 0.01
    Int MaxCycles = 100
EndStruct 

Struct SystemWaitDefaults
    Float Time = 0.1
    Int MaxCycles = 10
EndStruct

Struct SystemTimerIds
    Int InitializeId = 1000
    Int InitialRunId = 1001
    Int MainId = 2000
EndStruct

Struct SystemStageIds
    Int TutorialId = 3000
    Int UnitySaveDataId = 5000
    Int UnityLoadDataId = 5001
EndStruct

Struct SystemMenuIds
    String Barter = "BarterMenu"
    String ObjectContainer = "ContainerMenu"
    String Chargen = "ChargenMenu"
    String Crew = "ShipCrewMenu"
    String Data = "DataMenu"
    String Favorites = "FavoritesMenu"
    String GalaxyMap = "GalaxyStarMapMenu"
    String Inventory = "InventoryMenu"    
    String Mission = "BSMissionMenu"
    String Loading = "LoadingMenu"
    String Looks = "LooksMenu"
    String Main = "MainMenu"
    String Monocle = "MonocleMenu"
    String Pause = "PauseMenu"
    String Research = "ResearchMenu"
    String Security = "SecurityMenu"
    String Sit = "SitWaitMenu"
    String Skills = "SkillsMenu"
    String Sleep = "SleepWaitMenu"
    String Spaceship = "SpaceshipInfoMenu"
    String SpaceshipBuilder = "SpaceshipEditorMenu"
    String Status = "StatusMenu"
    String OutpostBuilder = "IndustrialCraftingMenu"
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
    String Name
    String Script
    String ModName
EndStruct

Struct SystemTypeCacheEntry
    Int FormId
    String Name
    String Script
    Int ModuleIndex
    ObjectReference Reference
EndStruct

Struct SystemTypeScriptEntry
    Int FormId
    String Name
EndStruct

Struct SystemFeature
    String Name
    Bool IsEnabled
    GlobalVariable FeatureGlobal
    GameplayOption FeatureOption
    Quest FeatureController
EndStruct

Struct SystemFeatureRequest
    String Name
    Form Sender
EndStruct

Struct EquipmentMap
    ObjectReference OwnerRef
    Form Equipment
    Keyword EquipmentType
    Bool IsRegistered
EndStruct