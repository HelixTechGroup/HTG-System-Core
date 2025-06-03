Scriptname HTG:Quests:SQ_DataslateController extends HTG:QuestExt
{Configuration Management Dataslate System Controller}
import HTG
import HTG:SystemLogger

ReferenceAlias Property DataslateTerminal Auto Const Mandatory
GlobalVariable Property DataslateAssistant_FirstActivation Auto Mandatory
DataslateTracker Property DataslateTracker Auto Mandatory


Event OnQuestStarted()
    Parent.OnQuestStarted()

    ; If DataslateTerminal != None
    ;     ObjectReference termRef = DataslateTerminal.GetReference()
    ;     Logger.Log("DataslateTerminal: " + DataslateTerminal)
    ;     Logger.Log("DataslateTerminal.GetReference(): " + termRef)
    ;     Logger.Log("Regenesys_AssistantDataslate: " + DataslateTracker.RegenesysAssistantDataslate)
    ;     ;ObjectReference ref = Game.GetPlayer().DropObject(Regenesys_AssistantDataslate, 1)
    ;     ;Logger.Log("DropObject(Regenesys_AssistantDataslate, 1): " + ref)
    ;     ;Regenesys_AssistantDataslateRef.ForceRefTo(ref)

    ;     ; termRef.Activate(Game.GetPlayer(), True)
    ;     ; Game.GetPlayer().AddItem(RegenesysAssistantDataslate)
    ;     ;Game.GetPlayer().AddItem(ref, 1, True)
    ; EndIf

    Logger.Log("Regenesys Controller Started.")
EndEvent

Event OnQuestShutdown()    
    If DataslateTerminal
        ObjectReference ref = DataslateTerminal.GetReference()
        LogObjectGlobal(Self, "DataslateTerminal: " + DataslateTerminal)
        LogObjectGlobal(Self, "DataslateTerminal.GetReference(): " + ref)
        ; Game.GetPlayer().RemoveItem(Regenesys_AssistantDataslate, 1)
    EndIf
    LogObjectGlobal(Self, "Regenesys Controller Shutdown.")
EndEvent