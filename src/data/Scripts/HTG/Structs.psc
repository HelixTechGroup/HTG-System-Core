ScriptName HTG:Structs Extends ScriptObject

;-- Structs -----------------------------------------
Struct ArmorSet
  Armor Helmet
  Armor Spacesuit
  Armor Backpack
EndStruct

Struct LeveledArmorSet
  LeveledItem Helmet
  LeveledItem Spacesuit
  LeveledItem Backpack
EndStruct

Struct LeveledItemInjectionSet
  LeveledItem LengendaryList
  LeveledItem EpicList
  LeveledItem BasicList
  LeveledItem RareList
  LeveledItem SuperiorList
  LeveledItem AdvancedList
  LeveledItem CalibratedList
EndStruct

Struct QuestCheckInfo
  Int UnityCheckTimes
  Quest QuestObject
  Bool UnityCheck
  Bool CompletionCheck
  Form RewardItem
  Int Stage
EndStruct

Struct SystemTimerIds
  Int InitializeId = 1000
  Int MainId = 2000
  Int InitialRunId = 1001
EndStruct

Struct TimerDefaults
  Float Interval = 0.01
  Int MaxCycles = 100
EndStruct

Struct WaitDefaults
  Float Time = 0.100000001
  Int MaxCycles = 10
EndStruct

