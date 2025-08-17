Scriptname HTG:Structs

Struct LogSeverity
    Int Info = 0
    Int Warning = 1
    Int Error = 2
EndStruct

Struct TimerDefaults
    Float Interval = 0.01
    Int MaxCycles = 100
EndStruct 

Struct WaitDefaults
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
    String Data = "DataMenu"
    String Status = "StatusMenu"
    String Inventory = "InventoryMenu"
    String GalaxyMap = "GalaxyStarMapMenu"
    String Spaceship = "SpaceshipInfoMenu"
    String Crew = "ShipCrewMenu"
    String Skills = "SkillsMenu"
    String Term = "TerminalMenu"
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

Struct SystemTypeEntry
    Int FormId
    String Name
    String FullyQualifiedName
EndStruct