Scriptname HTG:Collections:FormListExt extends HTG:Collections:List
import HTG:SystemLogger

Event OnInit()
    ArrayType = "Form"
EndEvent

FormListExt Function FormListExt(Int aiSize = 4) Global
    Int iFormId = 0x0000080E
    FormListExt res =  HTG:Collections:List._CreateList(iFormId, aiSize = aiSize) as FormListExt
    LogObjectGlobal(res, "HTG:Collections:FormListExt.FormListExt(" + aiSize  + "): " + res)
    return res
EndFunction

Form Function GetAt(Int index)
    return _Array[index] as Form
EndFunction

Bool Function IsNone(Var akItem)
    If akItem && akItem is Form
        Form ref = akItem as Form
        return ref == None
    EndIf

    return False
EndFunction

Bool Function TestType(Var akItem)
    If akItem as Form
        return True
    EndIf
EndFunction

Bool Function CompareItems(Var akArrayItem, Var akItem)
    If akArrayItem is Form && akItem is Form
        return akArrayItem as Form == akItem as Form
    EndIf
EndFunction