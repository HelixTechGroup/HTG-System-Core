Scriptname HTG:Collections:EquipmentMapList extends HTG:Collections:List
import HTG
import HTG:Structs
import HTG:SystemLogger
import HTG:SystemFormUtility
import HTG:SystemIntUtility
import HTG:Collections

Event OnInit()
    Parent.OnInit()
    ArrayType = "EquipmentMap"
EndEvent

EquipmentMapList Function EquipmentMapList(SystemModuleInformation akMod, Int aiSize = 0) Global
    Int iFormId = 0x000008E3
    EquipmentMapList res =  HTG:Collections:List._CreateList(akMod, iFormId, aiSize = aiSize) as EquipmentMapList
    LogObjectGlobal(res, "HTG:Crew:Collections:EquipmentMapList.EquipmentMapList(" + aiSize  + "): " + res)
    return res
EndFunction

EquipmentMap Function GetAt(Int index)
    return GetVarAt(index) as EquipmentMap
EndFunction

Bool Function IsNone(Var akItem)
    If Parent.IsNone(akItem) && akItem is EquipmentMap
        EquipmentMap map = akItem as EquipmentMap
        return map == None || map.OwnerRef == None || map.Equipment == None
    EndIf

    return False
EndFunction

Bool Function TestType(Var akItem)
    If akItem as EquipmentMap
        return True
    EndIf
EndFunction

Bool Function CompareItems(Var akArrayItem, Var akItem)
    If akArrayItem is EquipmentMap && akItem is EquipmentMap
        EquipmentMap kArrayItemMap = akArrayItem as EquipmentMap
        EquipmentMap kItemMap = akItem as EquipmentMap

        return  kArrayItemMap.OwnerRef == kItemMap.OwnerRef \
                && kArrayItemMap.Equipment == kItemMap.Equipment
    EndIf
EndFunction

EquipmentMap[] Function GetActorEquipmentMap(Actor akActor)
    Int i = 0
    EquipmentMap[] resArray = new EquipmentMap[0]
    Var[] kArray = _Array
    Int iCount = Count

    While i < iCount             
        If !IsNone(kArray[i])
            EquipmentMap map = kArray[i] as EquipmentMap
            If map.OwnerRef == akActor as ObjectReference
                resArray.Add(map)
            EndIf
        EndIf

        i += 1
    EndWhile

    ; FormArrayClean(resArray)
    return resArray
EndFunction

Form[] Function GetActorEquipment(Actor akActor)
    Int i = 0
    Form[] resArray = new Form[0]
    Var[] kArray = _Array
    Int iCount = Count
    While i < iCount             
        If !IsNone(kArray[i])
            EquipmentMap map = kArray[i] as EquipmentMap
            If map.OwnerRef == akActor as ObjectReference
                resArray.Add(map.Equipment)
            EndIf
        EndIf

        i += 1
    EndWhile

    FormArrayClean(resArray)
    return resArray
EndFunction

Form Function GetActorEquipmentType(Actor akActor, Keyword akArmorType)
    Int i = FindActorEquipmentType(akActor, akArmorType)
    Var[] kArray = _Array
    If i > -1
        return (kArray[i] as EquipmentMap).Equipment
    EndIf

    return None
EndFunction

EquipmentMap Function GetActorEquipmentTypeMap(Actor akActor, Keyword akArmorType)
    Int i = FindActorEquipmentType(akActor, akArmorType)
    Var[] kArray = _Array
    If i > -1
        return kArray[i] as EquipmentMap
    EndIf

    return None
EndFunction

Int[] Function FindActorEquipment(Actor akActor)
    Int i = 0
    Int[] resArray = new Int[0]
    Var[] kArray = _Array
    Int iCount = Count

    While i < iCount
        If !IsNone(kArray[i])
            EquipmentMap map = kArray[i] as EquipmentMap
            If map.OwnerRef == akActor as ObjectReference
                resArray.Add(i, 1)
            EndIf
        EndIf

        i += 1
    EndWhile

    IntArrayClean(resArray)
    return resArray
EndFunction

Int Function FindActorEquipmentType(Actor akActor, Keyword akArmorType)
    Int i = 0
    Int[] kActorEquipment = FindActorEquipment(akActor)
    Var[] kArray = _Array
    Int iCount = Count

    While i < kActorEquipment.Length
        If kActorEquipment[i] > -1 \
            && !IsNone(kArray[kActorEquipment[i]])
            EquipmentMap map = kArray[kActorEquipment[i]] as EquipmentMap
            If map.Equipment.HasKeyword(akArmorType)
                return i
            EndIf
        EndIf

        i += 1
    EndWhile

    return -1
EndFunction

Form[] Function RemoveActor(Actor akActor)
    Int i = 0
    Int[] kActorEquipment = FindActorEquipment(akActor)
    Form[] kResult = new Form[0]
    Var[] kArray = _Array
    Int iCount = Count
    EquipmentMap[] kMaps = new EquipmentMap[0]

    While i < kActorEquipment.Length
        If kActorEquipment[i] > -1 \
            && !IsNone(kArray[kActorEquipment[i]])
            EquipmentMap map = kArray[kActorEquipment[i]] as EquipmentMap
            kResult.Add(map.Equipment)
            kMaps.Add(map)
        EndIf

        i += 1
    EndWhile
    
    _RemoveMappings(kMaps)

    return kResult
EndFunction

Form Function RemoveActorEquipment(Actor akActor, Form akArmor)
    Var[] kArray = _Array
    Int[] kFound = FindActorEquipment(akActor)
    Int kI = 0
    While kI < kFound.Length
        Int kEquipmentIndex = kFound[kI]

        If IsNone(kArray[kEquipmentIndex])
            EquipmentMap map = kArray[kEquipmentIndex] as EquipmentMap
            If map.Equipment == akArmor
                Remove(map)
                return map.Equipment
            EndIf
            ; array.Remove(kFound)
            ; array[kFound].OwnerRef = None
            ; array[kFound].Equipment = None
        EndIf

        kI += 1
    EndWhile

    return None
EndFunction

Form Function RemoveActorEquipmentType(Actor akActor, Keyword akArmorType)
        Var[] kArray = _Array
        Int found = FindActorEquipmentType(akActor, akArmorType)
        If found > -1 && !IsNone(_Array[found])
            EquipmentMap map = kArray[found] as EquipmentMap
            Remove(map)
            return map.Equipment
            ; array.Remove(found)
            ; array[found].OwnerRef = None
            ; array[found].Equipment = None
        EndIf

        return None
EndFunction

Int Function AddActorEquipmentType(Actor akActor, Form akArmor, Keyword akArmorType, Bool abIsRegistered = False)
    Int index = UpdateActorEquipmentType(akActor, akArmor, akArmorType)
    If index < 0
        EquipmentMap map = new EquipmentMap
        map.OwnerRef = akActor as ObjectReference
        map.Equipment = akArmor
        map.EquipmentType = akArmorType
        map.IsRegistered = abIsRegistered
        index = Add(map)
    EndIf

    return index
EndFunction

Int Function UpdateActorEquipmentType(Actor akActor, Form akArmor, Keyword akArmorType)
    Int found = FindActorEquipmentType(akActor, akArmorType)
    Var[] kArray = _Array
    If found > -1 && !IsNone(kArray[found])
        EquipmentMap map = kArray[found] as EquipmentMap
        map.Equipment = akArmor
    EndIf

    return found
EndFunction

Bool Function ContainsActorEquipmentType(Actor akActor, Keyword akArmorType)
    return FindActorEquipmentType(akActor, akArmorType) > -1
EndFunction

Bool Function ContainsActor(Actor akActor)
    return FindActorEquipment(akActor).Length > 0
EndFunction

Bool Function ContainsActorEquipment(Actor akActor, Form akArmor)
    return GetActorEquipment(akActor).Find(akArmor) > -1
EndFunction

Int Function _FindStruct(String asVarName, Var akElement)
    EquipmentMap[] kArray = new EquipmentMap[0]
    Int i
    Int res = -1
    While i < Count
        EquipmentMap kMember = GetAt(i)
        kArray.Add(kMember)
        i += 1
    EndWhile

    If asVarName == "OwnerRef"
        res = kArray.FindStruct("OwnerRef", akElement as ObjectReference)
    ElseIf asVarName == "Equipment"
        res = kArray.FindStruct("Equipment", akElement as Form)
    ElseIf asVarName == "EquipmentType"
        res = kArray.FindStruct("EquipmentType", akElement as Keyword)
    ElseIf asVarName == "IsRegistered"
        res = kArray.FindStruct("IsRegistered", akElement as Bool)
    EndIf

    kArray = None
    return res
EndFunction

Int[] Function _RemoveMappings(EquipmentMap[] akMappings)
    Int i = 0
    Int iCount = Count
    Int[] resArray = new Int[0]

    While i < akMappings.Length
        EquipmentMap kMap = akMappings[i]
        Int iIdx = Remove(kMap)
        If iIdx > -1
            resArray.Add(iIdx)
        EndIf

        i += 1
    EndWhile
EndFunction