ScriptName HTG:FormUtility Extends ScriptObject hidden

;-- Functions ---------------------------------------

Bool Function FormArraySort(Form[] akArray, Int aiStartingIndex) Global
  If akArray.Length == 0 ; #DEBUG_LINE_NO:4
    Return True ; #DEBUG_LINE_NO:5
  EndIf
  Bool bFirstNoneFound = False ; #DEBUG_LINE_NO:8
  Int iFirstNonePos = aiStartingIndex ; #DEBUG_LINE_NO:9
  While aiStartingIndex < akArray.Length - 1 ; #DEBUG_LINE_NO:10
    If HTG:FormUtility.IsFormNone(akArray[aiStartingIndex]) ; #DEBUG_LINE_NO:11
      If bFirstNoneFound == False ; #DEBUG_LINE_NO:12
        bFirstNoneFound = True ; #DEBUG_LINE_NO:13
        iFirstNonePos = aiStartingIndex ; #DEBUG_LINE_NO:14
        aiStartingIndex += 1 ; #DEBUG_LINE_NO:15
      Else
        aiStartingIndex += 1 ; #DEBUG_LINE_NO:17
      EndIf
    ElseIf bFirstNoneFound == True ; #DEBUG_LINE_NO:20
      If !HTG:FormUtility.IsFormNone(akArray[aiStartingIndex]) ; #DEBUG_LINE_NO:21
        akArray[iFirstNonePos] = akArray[aiStartingIndex] ; #DEBUG_LINE_NO:22
        akArray[aiStartingIndex] = None ; #DEBUG_LINE_NO:23
        HTG:FormUtility.FormArraySort(akArray, iFirstNonePos + 1) ; #DEBUG_LINE_NO:25
        Return True ; #DEBUG_LINE_NO:26
      Else
        aiStartingIndex += 1 ; #DEBUG_LINE_NO:28
      EndIf
    Else
      aiStartingIndex += 1 ; #DEBUG_LINE_NO:31
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:36
EndFunction

Function FormArrayClean(Form[] akArray) Global
  If akArray.Length == 0 ; #DEBUG_LINE_NO:40
    Return  ; #DEBUG_LINE_NO:41
  EndIf
  Int I = 0 ; #DEBUG_LINE_NO:44
  Int count = akArray.Length - 1 ; #DEBUG_LINE_NO:45
  While I < count ; #DEBUG_LINE_NO:47
    If HTG:FormUtility.IsFormNone(akArray[I]) ; #DEBUG_LINE_NO:48
      akArray.remove(I, 1) ; #DEBUG_LINE_NO:49
    EndIf
  EndWhile
  HTG:FormUtility.FormArraySort(akArray, 0) ; #DEBUG_LINE_NO:53
EndFunction

Bool Function IsFormNone(Form akForm) Global
  Return akForm == None ; #DEBUG_LINE_NO:57
EndFunction
