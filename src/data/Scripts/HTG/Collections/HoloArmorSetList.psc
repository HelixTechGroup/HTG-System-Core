Scriptname HTG:Collections:HoloArmorSetList extends HTG:Collections:List
import HTG
import HTG:Structs
import HTG:SystemLogger
import HTG:SystemFormUtility
import HTG:SystemIntUtility
import HTG:Collections

Event OnInit()
    Parent.OnInit()
    ArrayType = "HoloArmorSet"
EndEvent

HoloArmorSetList Function HoloArmorSetList(SystemModuleInformation akMod, Int aiSize = 0) Global
    Int iFormId = 0x0000082B
    HoloArmorSetList res =  HTG:Collections:List._CreateList(akMod, iFormId, aiSize = aiSize) as HoloArmorSetList
    LogObjectGlobal(res, "HTG:Crew:Collections:HoloArmorSetList.HoloArmorSetList(" + aiSize  + "): " + res)
    return res
EndFunction

; HoloArmorSetList Function HoloArmorSetListIntegrated(SystemModuleInformation akMod, Int aiSize = 0) Global 
;     If HTG:UtilityExt.IsNone(akMod)
;         return None
;     EndIf

;     If !akMod.IsCoreIntegrated
;         return HoloArmorSetList(aiSize)
;     EndIf

;     HoloArmorSetList res
;     res = HTG:Collections:List._CreatedRegisteredList(akMod, "HTG:Collections:HoloArmorSetList", aiSize) as HoloArmorSetList
;     LogObjectGlobal(res, "HTG:Collections:HoloArmorSetList.HoloArmorSetList(" + aiSize  + "): " + res)
;     return res
; EndFunction

HoloArmorSet Function GetAt(Int index)
    return GetVarAt(index) as HoloArmorSet
EndFunction

Keyword[] Function GetArmorTypes()
    Keyword[] kRes = new Keyword[0]
    Int i = 0
    While i < Count
        HoloArmorSet kSet = GetAt(i) as HoloArmorSet
        kRes.Add(kSet.ArmorType)

        i += 1
    EndWhile

    return kRes
EndFunction

ArmorSet Function GetArmorSet(Keyword akArmorType)
    ArmorSet kRes = new ArmorSet
    Int iIndex = FindArmorSet(akArmorType)
    If iIndex > -1
        HoloArmorSet kSet = GetAt(iIndex)
        kRes.Backpack = kSet.Backpack
        kRes.Helmet = kSet.Helmet
        kRes.Spacesuit = kSet.Spacesuit
    EndIf 

    return kRes
EndFunction

Bool Function IsNone(Var akItem)
    If Parent.IsNone(akItem) && akItem is HoloArmorSet
        HoloArmorSet kSet = akItem as HoloArmorSet
        return kSet == None || kSet.ArmorType == None
    EndIf

    return False
EndFunction

Bool Function TestType(Var akItem)
    If akItem as HoloArmorSet
        return True
    EndIf
EndFunction

Bool Function CompareItems(Var akArrayItem, Var akItem)
    If akArrayItem is HoloArmorSet && akItem is HoloArmorSet
        HoloArmorSet kArraySet = akArrayItem as HoloArmorSet 
        HoloArmorSet kSet = akItem as HoloArmorSet
        return  kArraySet.ArmorType == kSet.ArmorType \
                && kArraySet.Backpack == kSet.Backpack \
                && kArraySet.Helmet == kSet.Helmet \                
                && kArraySet.Spacesuit == kSet.Spacesuit
    EndIf
EndFunction

Int Function FindArmorSet(Keyword akArmorType)
    Int i = 0
    While i < Count
        HoloArmorSet kSet = GetAt(i) as HoloArmorSet
        If kSet.ArmorType == akArmorType
            return i
        EndIf

        i += 1
    EndWhile

    return -1
EndFunction

Int Function AddArmorSets(HoloArmorSet[] akSets)
    Int i = 0
    Int res = Count
    While i < akSets.Length
        HoloArmorSet kSet = akSets[i] as HoloArmorSet
        Int index = Find(kSet)
        If index < 0
            index = AddArmorSet(kSet)
        EndIf

        If index > -1
            res += 1
        EndIf
        i += 1
    EndWhile
    
    return res
EndFunction

Int Function AddArmorSet(HoloArmorSet akArmorSet)
    ArmorSet kSet = new ArmorSet
    kSet.Backpack = akArmorSet.Backpack
    kSet.Helmet = akArmorSet.Helmet
    kSet.Spacesuit = akArmorSet.Spacesuit

    return AddArmorType(akArmorSet.ArmorType, kSet)
EndFunction

Int Function AddArmorType(Keyword akArmorType, ArmorSet akArmorSet)
    Int index = UpdateArmorType(akArmorType, akArmorSet)
    If index < 0
        HoloArmorSet kSet = new HoloArmorSet
        kSet.ArmorType = akArmorType
        kSet.Backpack = akArmorSet.Backpack
        kSet.Helmet = akArmorSet.Helmet
        kSet.Spacesuit = akArmorSet.Spacesuit
        index = Add(kSet)
    EndIf

    return index
EndFunction

Int Function UpdateArmorType(Keyword akArmorType, ArmorSet akArmorSet)
    Int found = FindArmorSet(akArmorType)
    If found > -1 && !IsNone(_Array[found])
        HoloArmorSet kSet = _Array[found] as HoloArmorSet
        kSet.ArmorType = akArmorType
        kSet.Backpack = akArmorSet.Backpack
        kSet.Helmet = akArmorSet.Helmet
        kSet.Spacesuit = akArmorSet.Spacesuit
    EndIf

    return found
EndFunction

Int Function _FindStruct(String asVarName, Var akElement)
    HoloArmorSet[] kArray = new HoloArmorSet[0]
    Int i
    Int res = -1
    While i < Count
        HoloArmorSet kMember = GetAt(i)
        kArray.Add(kMember)
        i += 1
    EndWhile

    If asVarName == "ArmorType"
        res = kArray.FindStruct("ArmorType", akElement as Keyword)
    ElseIf asVarName == "Backpack"
        res = kArray.FindStruct("Backpack", akElement as Armor)
    ElseIf asVarName == "Helmet"
        res = kArray.FindStruct("Helmet", akElement as Armor)
    ElseIf asVarName == "Spacesuit"
        res = kArray.FindStruct("Spacesuit", akElement as Armor)
    EndIf

    kArray = None
    return res
EndFunction