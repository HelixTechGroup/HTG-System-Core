Scriptname HTG:IntUtility extends ScriptObject Hidden

Bool Function IArraySort(Int[] akArray, Int aiStartingIndex = 0) Global
    If akArray.Length == 0
        return True
    EndIf

    Bool bFirstNoneFound = False
    Int iFirstNonePos = aiStartingIndex
    While aiStartingIndex < akArray.Length - 1
        If IsIntNone(akArray[aiStartingIndex])
            If bFirstNoneFound == False
                bFirstNoneFound = True
                iFirstNonePos = aiStartingIndex
                aiStartingIndex += 1
            Else
                aiStartingIndex += 1
            EndIf
        Else
            If bFirstNoneFound == True
                If !IsIntNone(akArray[aiStartingIndex])
                    akArray[iFirstNonePos] = akArray[aiStartingIndex]
                    akArray[aiStartingIndex] = 0
    
                    IArraySort(akArray, iFirstNonePos + 1)
                    return True
                Else
                    aiStartingIndex += 1
                EndIf
            Else
                aiStartingIndex += 1
            EndIf
        EndIf
    EndWhile

    return False
EndFunction

Function IArrayClean(Int[] akArray) Global
    If akArray.Length == 0
        return
    EndIf

    Int i = 0
    Int count = akArray.Length - 1

    While i < count
        If IsIntNone(akArray[i])
            akArray.Remove(i)
        EndIf
    EndWhile

    IArraySort(akArray)
EndFunction

Bool Function IsIntNone(Int aiInt) Global
    return aiInt == 0
EndFunction