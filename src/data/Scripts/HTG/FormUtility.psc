Scriptname HTG:FormUtility extends ScriptObject Hidden

Bool Function FormArraySort(Form[] akArray, Int aiStartingIndex = 0) Global
    If akArray.Length == 0
        return True
    EndIf

    Bool bFirstNoneFound = False
    Int iFirstNonePos = aiStartingIndex
    While aiStartingIndex < akArray.Length - 1
        If IsFormNone(akArray[aiStartingIndex])
            If bFirstNoneFound == False
                bFirstNoneFound = True
                iFirstNonePos = aiStartingIndex
                aiStartingIndex += 1
            Else
                aiStartingIndex += 1
            EndIf
        Else
            If bFirstNoneFound == True
                If !IsFormNone(akArray[aiStartingIndex])
                    akArray[iFirstNonePos] = akArray[aiStartingIndex]
                    akArray[aiStartingIndex] = None
    
                    FormArraySort(akArray, iFirstNonePos + 1)
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

Function FormArrayClean(Form[] akArray) Global
    If akArray.Length == 0
        return
    EndIf

    Int i = 0
    Int count = akArray.Length - 1

    While i < count
        If IsFormNone(akArray[i])
            akArray.Remove(i)
        EndIf
    EndWhile

    FormArraySort(akArray)
EndFunction

Bool Function IsFormNone(Form akForm) Global
    return akForm == none
EndFunction