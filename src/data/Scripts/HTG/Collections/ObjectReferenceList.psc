ScriptName HTG:Collections:ObjectReferenceList Extends HTG:Collections:List

;-- Functions ---------------------------------------

Event OnInit()
  ArrayType = "ObjectReference" ; #DEBUG_LINE_NO:5
EndEvent

HTG:Collections:ObjectReferenceList Function ObjectReferenceList(Int aiSize) Global
  Int aFormId = 2085 ; #DEBUG_LINE_NO:9
  String aModName = "HTG-Regenesys-Core" ; #DEBUG_LINE_NO:10
  Form aForm = HTG:Collections:List._CreateForm(aFormId, aModName) ; #DEBUG_LINE_NO:11
  HTG:Collections:ObjectReferenceList res = HTG:Collections:List._CreateReference(aForm, aiSize) as HTG:Collections:ObjectReferenceList ; #DEBUG_LINE_NO:12
  htg:systemlogger.LogObjectGlobal(res as ScriptObject, ("HTG:Collections:ObjectReferenceList.ObjectReferenceList(" + aiSize as String) + "): " + res as String) ; #DEBUG_LINE_NO:13
  res.Enable(False) ; #DEBUG_LINE_NO:14
  res.Initialize(aiSize) ; #DEBUG_LINE_NO:15
  Return res ; #DEBUG_LINE_NO:16
EndFunction

ObjectReference Function GetAt(Int index)
  Return Self._Array[index] as ObjectReference ; #DEBUG_LINE_NO:20
EndFunction

Bool Function IsNone(Var akItem)
  If akItem is ObjectReference ; #DEBUG_LINE_NO:24
    ObjectReference ref = akItem as ObjectReference ; #DEBUG_LINE_NO:25
    Return ref == None ; #DEBUG_LINE_NO:26
  EndIf
  Return False ; #DEBUG_LINE_NO:29
EndFunction

Bool Function TestType(Var akItem)
  If akItem as ObjectReference ; #DEBUG_LINE_NO:33
    Return True ; #DEBUG_LINE_NO:34
  EndIf
EndFunction

Bool Function CompareItems(Var akArrayItem, Var akItem)
  If akArrayItem is ObjectReference && akItem is ObjectReference ; #DEBUG_LINE_NO:39
    Return akArrayItem as ObjectReference == akItem as ObjectReference ; #DEBUG_LINE_NO:40
  EndIf
EndFunction
