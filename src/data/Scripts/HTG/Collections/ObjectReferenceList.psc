Scriptname HTG:Collections:ObjectReferenceList extends HTG:Collections:List
import HTG:SystemLogger

Event OnInit()
    ArrayType = "ObjectReference"
EndEvent

ObjectReferenceList Function ObjectReferenceList(Int aiSize = 4) Global
    Int aFormId = 0x00000825
    ; String aModName = "HTG-System-Core"
    Form aForm = HTG:Collections:List._CreateForm(aFormId) ; , aModName)
    ObjectReferenceList res = HTG:Collections:List._CreateReference(aForm, aiSize) as ObjectReferenceList
    LogObjectGlobal(res, "HTG:Collections:ObjectReferenceList.ObjectReferenceList(" + aiSize  + "): " + res)
    res.Enable(False)
    res.Initialize(aiSize)
    return res
EndFunction

ObjectReference Function GetAt(Int index)
    return _Array[index] as ObjectReference
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
