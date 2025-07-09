Scriptname HTG:Collections:ObjectReferenceList extends HTG:Collections:List
import HTG:SystemLogger
import HTG

Event OnInit()
    ArrayType = "ObjectReference"
EndEvent

ObjectReferenceList Function ObjectReferenceList(Int aiSize = 0) Global
    Int iFormId = 0x00000825
    ObjectReferenceList res =  HTG:Collections:List._CreateList(iFormId, aiSize = aiSize) as ObjectReferenceList
    LogObjectGlobal(res, "HTG:Collections:ObjectReferenceList.ObjectReferenceList(" + aiSize  + "): " + res)
    return res
EndFunction

ObjectReferenceList Function ObjectReferenceListIntegrated(ModInformation akMod, Int aiSize = 0) Global 
    If !akMod.IsCoreIntegrated
        return ObjectReferenceList(aiSize)
    EndIf

    ObjectReferenceList res
    res = HTG:Collections:List._CreatedRegisteredList(akMod, "HTG:Collections:ObjectReferenceList", aiSize) as ObjectReferenceList
    LogObjectGlobal(res, "HTG:Collections:ObjectReference.ObjectReference(" + aiSize  + "): " + res)
    return res
EndFunction

ObjectReference Function GetAt(Int index)
    return GetVarAt(index) as ObjectReference
EndFunction

Bool Function IsNone(Var akItem)
    If akItem is ObjectReference
        ObjectReference ref = akItem as ObjectReference
        return ref == None
    EndIf

    return False
EndFunction

Bool Function TestType(Var akItem)
    If akItem as ObjectReference
        return True
    EndIf
EndFunction

Bool Function CompareItems(Var akArrayItem, Var akItem)
    If akArrayItem is ObjectReference && akItem is ObjectReference
        return akArrayItem as ObjectReference == akItem as ObjectReference
    EndIf
EndFunction
