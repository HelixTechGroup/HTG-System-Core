Scriptname HTG:Structs

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

Struct LeveledArmorSet
    LeveledItem Helmet
    LeveledItem Backpack
    LeveledItem Spacesuit
EndStruct

Struct QuestCheckInfo
    Quest QuestObject
    int Stage
    Form RewardItem
    bool CompletionCheck
    bool UnityCheck
    int UnityCheckTimes
EndStruct