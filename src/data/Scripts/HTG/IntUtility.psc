ScriptName HTG:IntUtility Extends ScriptObject hidden

;-- Functions ---------------------------------------

Bool Function IntToBool(Int akValue) Global
  If akValue > 0 ; #DEBUG_LINE_NO:4
    Return True ; #DEBUG_LINE_NO:5
  EndIf
  Return False ; #DEBUG_LINE_NO:8
EndFunction

Bool Function IntArraySort(Int[] akArray, Int aiStartingIndex) Global
  If akArray.Length == 0 ; #DEBUG_LINE_NO:12
    Return True ; #DEBUG_LINE_NO:13
  EndIf
  Bool bFirstNoneFound = False ; #DEBUG_LINE_NO:16
  Int iFirstNonePos = aiStartingIndex ; #DEBUG_LINE_NO:17
  While aiStartingIndex < akArray.Length - 1 ; #DEBUG_LINE_NO:18
    If HTG:IntUtility.IsIntNone(akArray[aiStartingIndex]) ; #DEBUG_LINE_NO:19
      If bFirstNoneFound == False ; #DEBUG_LINE_NO:20
        bFirstNoneFound = True ; #DEBUG_LINE_NO:21
        iFirstNonePos = aiStartingIndex ; #DEBUG_LINE_NO:22
        aiStartingIndex += 1 ; #DEBUG_LINE_NO:23
      Else
        aiStartingIndex += 1 ; #DEBUG_LINE_NO:25
      EndIf
    ElseIf bFirstNoneFound == True ; #DEBUG_LINE_NO:28
      If !HTG:IntUtility.IsIntNone(akArray[aiStartingIndex]) ; #DEBUG_LINE_NO:29
        akArray[iFirstNonePos] = akArray[aiStartingIndex] ; #DEBUG_LINE_NO:30
        akArray[aiStartingIndex] = 0 ; #DEBUG_LINE_NO:31
        HTG:IntUtility.IntArraySort(akArray, iFirstNonePos + 1) ; #DEBUG_LINE_NO:33
        Return True ; #DEBUG_LINE_NO:34
      Else
        aiStartingIndex += 1 ; #DEBUG_LINE_NO:36
      EndIf
    Else
      aiStartingIndex += 1 ; #DEBUG_LINE_NO:39
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:44
EndFunction

Function IntArrayClean(Int[] akArray) Global
  If akArray.Length == 0 ; #DEBUG_LINE_NO:48
    Return  ; #DEBUG_LINE_NO:49
  EndIf
  Int I = 0 ; #DEBUG_LINE_NO:52
  Int count = akArray.Length - 1 ; #DEBUG_LINE_NO:53
  While I < count ; #DEBUG_LINE_NO:55
    If HTG:IntUtility.IsIntNone(akArray[I]) ; #DEBUG_LINE_NO:56
      akArray.remove(I, 1) ; #DEBUG_LINE_NO:57
    EndIf
  EndWhile
  HTG:IntUtility.IntArraySort(akArray, 0) ; #DEBUG_LINE_NO:61
EndFunction

Bool Function IsIntNone(Int aiInt) Global
  Return aiInt == 0 ; #DEBUG_LINE_NO:65
EndFunction
