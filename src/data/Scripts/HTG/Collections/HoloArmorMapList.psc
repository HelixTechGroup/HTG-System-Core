Scriptname HTG:Collections:HoloArmorMapList extends HTG:Collections:List
import HTG
import HTG:Structs
import HTG:SystemLogger
import HTG:FormUtility
import HTG:IntUtility
import HTG:Collections

Event OnInit()
    Parent.OnInit()
    ArrayType = "HoloArmorMap"
EndEvent

HoloArmorMapList Function HoloArmorMapList(Int aiSize = 0) Global
    Int iFormId = 0x00000802
    HoloArmorMapList res =  HTG:Collections:List._CreateList(iFormId, aiSize = aiSize) as HoloArmorMapList
    LogObjectGlobal(res, "HTG:Crew:Collections:HoloArmorMapList.HoloArmorMapList(" + aiSize  + "): " + res)
    return res
EndFunction

HoloArmorMapList Function HoloArmorMapListIntegrated(SystemModuleInformation akMod, Int aiSize = 0) Global 
    If HTG:UtilityExt.IsNone(akMod)
        return None
    EndIf

    If !akMod.IsCoreIntegrated
        return HoloArmorMapList(aiSize)
    EndIf

    HoloArmorMapList res
    res = HTG:Collections:List._CreatedRegisteredList(akMod, "HTG:Collections:HoloArmorMapList", aiSize) as HoloArmorMapList
    LogObjectGlobal(res, "HTG:Collections:HoloArmorMapList.HoloArmorMapList(" + aiSize  + "): " + res)
    return res
EndFunction

HoloArmorMap Function GetAt(Int index)
    return GetVarAt(index) as HoloArmorMap
EndFunction

Bool Function IsNone(Var akItem)
    If Parent.IsNone(akItem) && akItem is HoloArmorMap
        HoloArmorMap map = akItem as HoloArmorMap
        return map == None || map.ArmorPiece == None || map.ArmorMod == None
    EndIf

    return False
EndFunction

Bool Function TestType(Var akItem)
    If akItem as HoloArmorMap
        return True
    EndIf
EndFunction

Bool Function CompareItems(Var akArrayItem, Var akItem)
    If akArrayItem is HoloArmorMap && akItem is HoloArmorMap
        HoloArmorMap kArrayMap = akArrayItem as HoloArmorMap 
        HoloArmorMap kMap = akItem as HoloArmorMap
        return  kArrayMap.ArmorPiece == kMap.ArmorPiece \
                && kArrayMap.ArmorMod == kMap.ArmorMod
    EndIf
EndFunction

Int Function FindArmorPiece(Armor akArmorPiece)
    Int i = 0
    While i < Count
        HoloArmorMap kMap = GetAt(i) as HoloArmorMap
        If kMap.ArmorPiece == akArmorPiece
            return i
        EndIf

        i += 1
    EndWhile

    return -1
EndFunction

Int Function FindArmorMod(ObjectMod akArmorMod)
    Int i = 0
    While i < Count
        HoloArmorMap kMap = GetAt(i) as HoloArmorMap
        If kMap.ArmorMod == akArmorMod
            return i
        EndIf

        i += 1
    EndWhile
    
    return -1
EndFunction

ObjectMod Function GetMod(Armor akArmorPiece)
    Int i = FindArmorPiece(akArmorPiece)
    If i > -1
        HoloArmorMap kMap = GetAt(i) as HoloArmorMap
        return kMap.ArmorMod
    EndIf

    return None
EndFunction

Armor Function GetArmor(ObjectMod akArmorMod)
    Int i = FindArmorMod(akArmorMod)
    If i > -1
        HoloArmorMap kMap = GetAt(i) as HoloArmorMap
        return kMap.ArmorPiece
    EndIf
    
    return None
EndFunction

Int[] Function AddMappings(HoloArmorMap[] akMappings)
    Int i = 0
    Int[] res = new Int[0]
    While i < akMappings.Length
        HoloArmorMap kMap = akMappings[i] as HoloArmorMap
        Int index = Find(kMap)
        If index < 0
            index = AddMap(kMap)
        EndIf

        If index > -1
            res.Add(index)
        EndIf
        i += 1
    EndWhile
    
    return res
EndFunction

Int Function AddMap(HoloArmorMap akArmorMap)
    return AddMod(akArmorMap.ArmorMod, akArmorMap.ArmorPiece)
EndFunction

Int Function AddMod(ObjectMod akArmorMod, Armor akArmorPiece)
    Int index = UpdateEquipment(akArmorMod, akArmorPiece)
    If index < 0
        HoloArmorMap map = new HoloArmorMap
        map.ArmorMod = akArmorMod
        map.ArmorPiece = akArmorPiece
        index = Add(map)
    EndIf

    return index
EndFunction

Int Function UpdateEquipment(ObjectMod akArmorMod, Armor akArmorPiece)
    Int found = FindArmorPiece(akArmorPiece)
    If found > -1 && !IsNone(_Array[found])
        HoloArmorMap map = _Array[found] as HoloArmorMap
        map.ArmorMod = akArmorMod
    EndIf

    return found
EndFunction