Scriptname HTG:FloatUtility extends ScriptObject Hidden

Bool Function FloatToBool(Float akValue) Global
    If akValue > 0.0
        return True
    EndIf

    return False
EndFunction

Bool Function FloatArraySort(Float[] akArray, Int aiStartingIndex = 0) Global
    If akArray.Length == 0.0
        return True
    EndIf

    Bool bFirstOneFound = False
    Int iFirstNonePos = aiStartingIndex
    While aiStartingIndex < akArray.Length - 1.0
        If IsFloatNone(akArray[aiStartingIndex])
            If bFirstOneFound == False
                bFirstOneFound = True
                iFirstNonePos = aiStartingIndex
                aiStartingIndex += 1
            Else
                aiStartingIndex += 1
            EndIf
        Else
            If bFirstOneFound == True
                If !IsFloatNone(akArray[aiStartingIndex])
                    akArray[iFirstNonePos] = akArray[aiStartingIndex]
                    akArray[aiStartingIndex] = 0
    
                    FloatArraySort(akArray, iFirstNonePos + 1)
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

Function FloatArrayClean(Float[] akArray) Global
    If akArray.Length == 0
        return
    EndIf

    Int i = 0
    Int count = akArray.Length - 1

    While i < count
        If IsFloatNone(akArray[i])
            akArray.Remove(i)
        EndIf
    EndWhile

    FloatArraySort(akArray)
EndFunction

Bool Function IsFloatNone(Float aiFloat) Global
    return aiFloat == 0.0
EndFunction