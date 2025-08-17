Scriptname HTG:Quests:SQ_DataslateController extends HTG:QuestExt
{Configuration Management Dataslate System Controller}
import HTG
import HTG:SystemLogger
import HTG:UtilityExt
import HTG:FloatUtility

ReferenceAlias Property DataslateTerminal Auto Const Mandatory
GlobalVariable Property FirstActivation Auto Mandatory
GlobalVariable Property ShowTutorial Mandatory Const Auto
DataslateTracker Property DataslateTracker Auto Mandatory
Message Property DataslateLocation Mandatory Const Auto

Int _tutorialDataslateStageId = 5

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
EndEvent

Event OnQuestShutdown()    
    If DataslateTerminal
        ObjectReference ref = DataslateTerminal.GetReference()
        LogObjectGlobal(Self, "DataslateTerminal: " + DataslateTerminal)
        LogObjectGlobal(Self, "DataslateTerminal.GetReference(): " + ref)
        ; Game.GetPlayer().RemoveItem(Regenesys_AssistantDataslate, 1)
    EndIf
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    Parent.OnStageSet(auiStageID, auiItemID)

    If auiStageID == _tutorialDataslateStageId && FloatToBool(ShowTutorial.GetValue())
        Message.ClearHelpMessages()
        DataslateLocation.ShowAsHelpMessage("", 30.0, 30.0, 1)
        ; ShowMessage(DataslateLocation, asContext = DataslateTracker, abShowAsHelpMessage = True)
    EndIf
EndEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    Parent.OnMenuOpenCloseEvent(asMenuName, abOpening)

    If asMenuName == Utilities.Menus.Data
    ElseIf asMenuName == Utilities.Menus.Inventory
    EndIf
EndEvent