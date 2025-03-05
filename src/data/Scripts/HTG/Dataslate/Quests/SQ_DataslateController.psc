ScriptName HTG:Dataslate:Quests:SQ_DataslateController Extends HTG:QuestExt
{ Configuration Management Dataslate System Controller }

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
ReferenceAlias Property DataslateTerminal Auto Const mandatory
GlobalVariable Property DataslateAssistant_FirstActivation Auto mandatory
htg:dataslate:quests:dataslatetracker Property DataslateTracker Auto mandatory

;-- Functions ---------------------------------------

Event OnQuestStarted()
  Parent.OnQuestStarted() ; #DEBUG_LINE_NO:12
  Self.Logger.Log("Regenesys Controller Started.", 0) ; #DEBUG_LINE_NO:28
EndEvent

Event OnQuestShutdown()
  If DataslateTerminal ; #DEBUG_LINE_NO:32
    ObjectReference ref = DataslateTerminal.GetReference() ; #DEBUG_LINE_NO:33
    htg:systemlogger.LogObjectGlobal(Self as ScriptObject, "DataslateTerminal: " + DataslateTerminal as String) ; #DEBUG_LINE_NO:34
    htg:systemlogger.LogObjectGlobal(Self as ScriptObject, "DataslateTerminal.GetReference(): " + ref as String) ; #DEBUG_LINE_NO:35
  EndIf
  htg:systemlogger.LogObjectGlobal(Self as ScriptObject, "Regenesys Controller Shutdown.") ; #DEBUG_LINE_NO:38
EndEvent
