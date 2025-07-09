Scriptname HTG:Collections:FormListExt extends HTG:Collections:List
import HTG:SystemLogger
import HTG

Event OnInit()
    ArrayType = "Form"
EndEvent

FormListExt Function FormListExt(Int aiSize = 0) Global
    Int iFormId = 0x0000080E
    FormListExt res =  HTG:Collections:List._CreateList(iFormId, aiSize = aiSize) as FormListExt
    LogObjectGlobal(res, "HTG:Collections:FormListExt.FormListExt(" + aiSize  + "): " + res)
    return res
EndFunction

FormListExt Function FormListExtIntegrated(ModInformation akMod, Int aiSize = 0) Global 
    If !akMod.IsCoreIntegrated
        return FormListExt(aiSize)
    EndIf

    FormListExt res
    res = HTG:Collections:List._CreatedRegisteredList(akMod, "HTG:Collections:FormListExt", aiSize) as FormListExt
    LogObjectGlobal(res, "HTG:Collections:FormListExt.FormListExt(" + aiSize  + "): " + res)
    return res
EndFunction

Form Function GetAt(Int index)
    return GetVarAt(index) as Form
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