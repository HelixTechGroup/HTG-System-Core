Scriptname HTG:FormUtility extends ScriptObject Hidden
import HTG:SystemLogger

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
        i += 1
    EndWhile

    FormArraySort(akArray)
EndFunction

Bool Function IsFormNone(Form akForm) Global
    return akForm == None || !akForm
EndFunction

Form Function CreateForm(Int aiFormId, String modName = "HTG-System-Core") Global
    Form kForm = Game.GetFormFromFile(aiFormId, modName + ".esp")
    
    If kForm == None
        kForm = Game.GetFormFromFile(aiFormId, modName + ".esm") 
    EndIf

    If kForm != None
        LogObjectGlobal(kForm, "HTG:FormUtility.CreateForm(" + aiFormId + ")")
        return kForm
    EndIf

    LogObjectGlobal(kForm, "HTG:FormUtility.CreateForm: Unable to create Form: " + aiFormId)
    return None
EndFunction

ObjectReference Function CreateReference(ObjectReference akSpawnPoint, Form akForm, Bool abPersist = False, Alias akAlias = None) Global
    If akForm && akSpawnPoint
        ObjectReference ref = akSpawnPoint.PlaceAtMe(akForm, abInitiallyDisabled = True, abForcePersist = abPersist, abDeleteWhenAble = !abPersist, akAliasToFill = akAlias)
        If ref
            ; If !ref.HasOwner()
            ;     ref.SetActorRefOwner(akActor)
            ; EndIf

            LogObjectGlobal(ref, "HTG:FormUtility.CreateReference(" + akForm + ")")
            return ref
        EndIf
    EndIf

    LogErrorGlobal(akSpawnPoint, "HTG:FormUtility.CreateReference: Unable to create Form: " + akForm)
    return None
EndFunction

ObjectReference Function CreateReferenceFromExisting(Actor akActor, Form akForm, Alias akAlias = None) Global
    If akForm && akActor
        ObjectReference ref = akActor.MakeAliasedRefFromInventory(akForm, akAlias)
        If ref != None 
            If !ref.HasOwner()
                ref.SetActorRefOwner(akActor)
            EndIf

            LogObjectGlobal(ref, "HTG:FormUtility.CreateReferenceFromExisting(" + akForm + ")")
            return ref
        EndIf        
    EndIf

    LogErrorGlobal(akActor, "HTG:FormUtility.CreateReferenceFromExisting: Unable to create Form: " + akForm)
    return None
EndFunction