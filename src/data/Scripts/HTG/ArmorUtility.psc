Scriptname HTG:ArmorUtility extends ScriptObject Hidden

Keyword Property Hat Auto Const Mandatory
Keyword Property Clothes Auto Const Mandatory
Keyword Property Helmet Auto Const Mandatory
Keyword Property Backpack Auto Const Mandatory
Keyword Property Spacesuit Auto Const Mandatory

FormList Property ArmorTypes Auto Const Mandatory

Int Property HeadSlot = 0x00000001 AutoReadOnly
Int Property HairSlot = 0x00000002 AutoReadOnly; Hair 2
Int Property BodySlot = 0x00000004 AutoReadOnly; BODY 4
Int Property HandSlot = 0x00000008 AutoReadOnly; Hands 8
Int Property ForearmSlot = 0x00000010 AutoReadOnly; Forearms 16
Int Property AmuletSlot = 0x00000020 AutoReadOnly; Amulet 32
Int Property RingSlot = 0x00000040 AutoReadOnly; Ring 64
Int Property FeetSlot = 0x00000080 AutoReadOnly; Feet 
Int Property CalvesSlot = 0x00000100 AutoReadOnly; Calves
Int Property ShieldSlot = 0x00000200 AutoReadOnly; SHIELD;

Int Property ClothesSLot = 0x00000003 AutoReadOnly; HairSlot + HeadSlot; Clothing
Int Property SSBackpackSlot = 0x00000025 AutoReadOnly; HeadSlot + BodySlot + AmuletSlot AutoReadOnly; Spacesuit Backpack
Int Property SSBodySlot = 0x00000026 AutoReadOnly; BodySlot + HairSlot + AmuletSlot AutoReadOnly; Spacesuit
Int Property SSHeadSlot = 0x00000024 AutoReadOnly; BodySlot + AmuletSlot AutoReadOnly; Spacesuit Helmet

; Struct ArmorSlots
;     Int HeadSlot = 0x00000001 
;     Int HairSlot = 0x00000002 ; Hair 2
;     Int BodySlot = 0x00000004 ; BODY 4
;     Int HandSlot = 0x00000008 ; Hands 8
;     Int ForearmSlot = 0x00000010 ; Forearms 16
;     Int AmuletSlot = 0x00000020 ; Amulet 32
;     Int RingSlot = 0x00000040 ; Ring 64
;     Int FeetSlot = 0x00000080 ; Feet 
;     Int CalvesSlot = 0x00000100 ; Calves
;     Int ShieldSlot = 0x00000200 ; SHIELD;

;     Int Clothes = 0x00000003 ; HairSlot + HeadSlot; Clothing
;     Int SSBackpack = 0x00000025 ; HeadSlot + BodySlot + AmuletSlot ; Spacesuit Backpack
;     Int SSBody = 0x00000026 ; BodySlot + HairSlot + AmuletSlot ; Spacesuit
;     Int SSHead = 0x00000024 ; BodySlot + AmuletSlot ; Spacesuit Helmet
; EndStruct

Keyword Function GetArmorType(Form akFrom)
    Bool isWearable
    Keyword resKeyword = None
    Int i = 0
    Int count = ArmorTypes.GetSize()

    While i < count && !isWearable
        Keyword kw = ArmorTypes.GetAt(i) as Keyword
        isWearable = akFrom.HasKeyword(kw)
        If (isWearable)
            resKeyword = kw
        EndIf
        i += 1
    EndWhile

    return resKeyword
EndFunction

Function UnequipAllArmor(Actor akActor)
    ; ArmorSlots itemSlots = new ArmorSlots
    akActor.UnequipItemSlot(HeadSlot) ; Hat
    akActor.UnequipItemSlot(ClothesSlot) ; Clothes
    akActor.UnequipItemSlot(SSHeadSlot) ; Helmet
    akActor.UnequipItemSlot(SSBackpackSlot) ; Backpack
    akActor.UnequipItemSlot(SSBodySlot) ; Spacesuit                    
EndFunction

Function UnequipAllArmorExcept(Actor akActor, Keyword[] exceptTypes)
    If exceptTypes.Find(Hat) > -1
        akActor.UnequipItemSlot(HeadSlot) ; Hat
    EndIf 

    If exceptTypes.Find(Clothes) > -1
        akActor.UnequipItemSlot(ClothesSlot) ; Clothes
    EndIf 

    If exceptTypes.Find(Helmet) > -1
        akActor.UnequipItemSlot(SSHeadSlot) ; Helmet
    EndIf 

    If exceptTypes.Find(Backpack) > -1
        akActor.UnequipItemSlot(SSBackpackSlot) ; Backpack
    EndIf 

    If exceptTypes.Find(Spacesuit) > -1
        akActor.UnequipItemSlot(SSBodySlot) ; Spacesuit                    
    EndIf
EndFunction

Function UnequipArmorType(Actor akActor, Keyword akArmorType)
    If akArmorType == Hat
        akActor.UnequipItemSlot(HeadSlot) ; Hat
    ElseIf akArmorType == Clothes
        akActor.UnequipItemSlot(ClothesSlot) ; Clothes
    ElseIf akArmorType == Helmet
        akActor.UnequipItemSlot(SSHeadSlot) ; Helmet
    ElseIf akArmorType == Backpack
        akActor.UnequipItemSlot(SSBackpackSlot) ; Backpack
    ElseIf akArmorType == Spacesuit
        akActor.UnequipItemSlot(SSBodySlot) ; Spacesuit                    
    EndIf
EndFunction

; Function Slots() Global
    ; int HeadSlot = 0x00000001; HEAD 1
    ; int HairSlot = 0x00000002; Hair 2
    ; int BodySlot = 0x00000004; BODY 4
    ; int HandSlot = 0x00000008; Hands 8
    ; int ForearmSlot = 0x00000010; Forearms 16
    ; int AmuletSlot = 0x00000020 ; Amulet 32
    ; int RingSlot = 0x00000040 ; Ring 64
    ; int FeetSlot = 0x00000080 ; Feet 
    ; int CalvesSlot = 0x00000100 ; Calves
    ; int ShieldSlot = 0x00000200 ; SHIELD
    
    ; int Property kSlotMask30 = 0x00000001 AutoReadOnly ; HEAD
    ; int Property kSlotMask31 = 0x00000002 AutoReadOnly ; Hair
    ; int Property kSlotMask32 = 0x00000004 AutoReadOnly ; BODY
    ; int Property kSlotMask33 = 0x00000008 AutoReadOnly ; Hands
    ; int Property kSlotMask34 = 0x00000010 AutoReadOnly ; Forearms
    ; int Property kSlotMask35 = 0x00000020 AutoReadOnly ; Amulet
    ; int Property kSlotMask36 = 0x00000040 AutoReadOnly ; Ring
    ; int Property kSlotMask37 = 0x00000080 AutoReadOnly ; Feet
    ; int Property kSlotMask38 = 0x00000100 AutoReadOnly ; Calves
    ; int Property kSlotMask39 = 0x00000200 AutoReadOnly ; SHIELD
    ; int Property kSlotMask40 = 0x00000400 AutoReadOnly ; TAIL
    ; int Property kSlotMask41 = 0x00000800 AutoReadOnly ; LongHair
    ; int Property kSlotMask42 = 0x00001000 AutoReadOnly ; Circlet
    ; int Property kSlotMask43 = 0x00002000 AutoReadOnly ; Ears
; EndFunction
