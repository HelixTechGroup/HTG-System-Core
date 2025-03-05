ScriptName HTG:Collections:FormListExt Extends HTG:Collections:List

;-- Functions ---------------------------------------

Event OnInit()
  ArrayType = "Form" ; #DEBUG_LINE_NO:5
EndEvent

HTG:Collections:FormListExt Function FormListExt(Int aiSize) Global
  Int aFormId = 2062 ; #DEBUG_LINE_NO:9
  Form aForm = HTG:Collections:List._CreateForm(aFormId, "HTG-Regenesys-Core") ; #DEBUG_LINE_NO:10
  HTG:Collections:FormListExt res = HTG:Collections:List._CreateReference(aForm, aiSize) as HTG:Collections:FormListExt ; #DEBUG_LINE_NO:11
  htg:systemlogger.LogObjectGlobal(res as ScriptObject, ("HTG:Collections:FormListExt.FormListExt(" + aiSize as String) + "): " + res as String) ; #DEBUG_LINE_NO:12
  res.Enable(False) ; #DEBUG_LINE_NO:13
  res.Initialize(aiSize) ; #DEBUG_LINE_NO:14
  Return res ; #DEBUG_LINE_NO:15
EndFunction

Form Function GetAt(Int index)
  Return Self._Array[index] as Form ; #DEBUG_LINE_NO:19
EndFunction

Bool Function IsNone(Var akItem)
  If akItem is Form ; #DEBUG_LINE_NO:23
    Form ref = akItem as Form ; #DEBUG_LINE_NO:24
    Return ref == None ; #DEBUG_LINE_NO:25
  EndIf
  Return False ; #DEBUG_LINE_NO:28
EndFunction

Bool Function TestType(Var akItem)
  If akItem as Form ; #DEBUG_LINE_NO:32
    Return True ; #DEBUG_LINE_NO:33
  EndIf
EndFunction

Bool Function CompareItems(Var akArrayItem, Var akItem)
  If akArrayItem is Form && akItem is Form ; #DEBUG_LINE_NO:38
    Return akArrayItem as Form == akItem as Form ; #DEBUG_LINE_NO:39
  EndIf
EndFunction
