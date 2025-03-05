ScriptName HTG:ArmorUtility Extends ScriptObject hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Keyword Property Hat Auto Const mandatory
Keyword Property Clothes Auto Const mandatory
Keyword Property Helmet Auto Const mandatory
Keyword Property Backpack Auto Const mandatory
Keyword Property Spacesuit Auto Const mandatory
FormList Property ArmorTypes Auto Const mandatory
Int Property HeadSlot = 1 AutoReadOnly
Int Property HairSlot = 2 AutoReadOnly
Int Property BodySlot = 4 AutoReadOnly
Int Property HandSlot = 8 AutoReadOnly
Int Property ForearmSlot = 16 AutoReadOnly
Int Property AmuletSlot = 32 AutoReadOnly
Int Property RingSlot = 64 AutoReadOnly
Int Property FeetSlot = 128 AutoReadOnly
Int Property CalvesSlot = 256 AutoReadOnly
Int Property ShieldSlot = 512 AutoReadOnly
Int Property ClothesSLot = 3 AutoReadOnly
Int Property SSBackpackSlot = 37 AutoReadOnly
Int Property SSBodySlot = 38 AutoReadOnly
Int Property SSHeadSlot = 36 AutoReadOnly

;-- Functions ---------------------------------------

Keyword Function GetArmorType(Form akFrom)
  Bool isWearable = False ; #DEBUG_LINE_NO:46
  Keyword resKeyword = None ; #DEBUG_LINE_NO:47
  Int I = 0 ; #DEBUG_LINE_NO:48
  Int count = ArmorTypes.GetSize() ; #DEBUG_LINE_NO:49
  While I < count && !isWearable ; #DEBUG_LINE_NO:51
    Keyword kw = ArmorTypes.GetAt(I) as Keyword ; #DEBUG_LINE_NO:52
    isWearable = akFrom.HasKeyword(kw) ; #DEBUG_LINE_NO:53
    If isWearable ; #DEBUG_LINE_NO:54
      resKeyword = kw ; #DEBUG_LINE_NO:55
    EndIf
    I += 1 ; #DEBUG_LINE_NO:57
  EndWhile
  Return resKeyword ; #DEBUG_LINE_NO:60
EndFunction

Function UnequipAllArmor(Actor akActor)
  akActor.UnequipItemSlot(Self.HeadSlot) ; #DEBUG_LINE_NO:65
  akActor.UnequipItemSlot(Self.ClothesSLot) ; #DEBUG_LINE_NO:66
  akActor.UnequipItemSlot(Self.SSHeadSlot) ; #DEBUG_LINE_NO:67
  akActor.UnequipItemSlot(Self.SSBackpackSlot) ; #DEBUG_LINE_NO:68
  akActor.UnequipItemSlot(Self.SSBodySlot) ; #DEBUG_LINE_NO:69
EndFunction

Function UnequipAllArmorExcept(Actor akActor, Keyword[] exceptTypes)
  If exceptTypes.find(Hat, 0) > -1 ; #DEBUG_LINE_NO:73
    akActor.UnequipItemSlot(Self.HeadSlot) ; #DEBUG_LINE_NO:74
  EndIf
  If exceptTypes.find(Clothes, 0) > -1 ; #DEBUG_LINE_NO:77
    akActor.UnequipItemSlot(Self.ClothesSLot) ; #DEBUG_LINE_NO:78
  EndIf
  If exceptTypes.find(Helmet, 0) > -1 ; #DEBUG_LINE_NO:81
    akActor.UnequipItemSlot(Self.SSHeadSlot) ; #DEBUG_LINE_NO:82
  EndIf
  If exceptTypes.find(Backpack, 0) > -1 ; #DEBUG_LINE_NO:85
    akActor.UnequipItemSlot(Self.SSBackpackSlot) ; #DEBUG_LINE_NO:86
  EndIf
  If exceptTypes.find(Spacesuit, 0) > -1 ; #DEBUG_LINE_NO:89
    akActor.UnequipItemSlot(Self.SSBodySlot) ; #DEBUG_LINE_NO:90
  EndIf
EndFunction

Function UnequipArmorType(Actor akActor, Keyword akArmorType)
  If akArmorType == Hat ; #DEBUG_LINE_NO:95
    akActor.UnequipItemSlot(Self.HeadSlot) ; #DEBUG_LINE_NO:96
  ElseIf akArmorType == Clothes ; #DEBUG_LINE_NO:97
    akActor.UnequipItemSlot(Self.ClothesSLot) ; #DEBUG_LINE_NO:98
  ElseIf akArmorType == Helmet ; #DEBUG_LINE_NO:99
    akActor.UnequipItemSlot(Self.SSHeadSlot) ; #DEBUG_LINE_NO:100
  ElseIf akArmorType == Backpack ; #DEBUG_LINE_NO:101
    akActor.UnequipItemSlot(Self.SSBackpackSlot) ; #DEBUG_LINE_NO:102
  ElseIf akArmorType == Spacesuit ; #DEBUG_LINE_NO:103
    akActor.UnequipItemSlot(Self.SSBodySlot) ; #DEBUG_LINE_NO:104
  EndIf
EndFunction
