ScriptName HTG:SystemLogger Extends ReferenceAlias hidden

;-- Structs -----------------------------------------
Struct LogSeverity
  Int info = 0
  Int warning = 1
  Int error = 2
EndStruct


;-- Variables ---------------------------------------
Quest _quest

;-- Properties --------------------------------------
Group LogNames
  String Property MainLogName Auto Const mandatory
  String Property SubLogName Auto Const mandatory
EndGroup

htg:systemlogger:logseverity Property Severity hidden
  htg:systemlogger:logseverity Function Get()
    Return new htg:systemlogger:logseverity ; #DEBUG_LINE_NO:10
  EndFunction
EndProperty

;-- Functions ---------------------------------------

Event OnAliasInit()
  _quest = Self.GetOwningQuest() ; #DEBUG_LINE_NO:23
EndEvent

Bool Function Trace(ScriptObject akCallingObject, String MainLogName, String subLogame, String asMessage, Int aiSeverity, Bool bShowNormalTrace, Bool bShowWarning, Bool bPrefixTraceWithLogNames) Global
  Return Debug.TraceLog(akCallingObject, asMessage, MainLogName, subLogame, aiSeverity, bShowNormalTrace, bShowWarning, bPrefixTraceWithLogNames, True) ; #DEBUG_LINE_NO:27
EndFunction

Bool Function Warn(ScriptObject akCallingObject, String MainLogName, String subLogame, String asMessage, Bool bShowNormalTrace, Bool bPrefixTraceWithLogNames) Global
  Return HTG:SystemLogger.Trace(akCallingObject, MainLogName, subLogame, asMessage, 2, bShowNormalTrace, True, bPrefixTraceWithLogNames) ; #DEBUG_LINE_NO:31
EndFunction

Bool Function error(ScriptObject akCallingObject, String MainLogName, String subLogame, String asMessage, Bool bShowNormalTrace, Bool bPrefixTraceWithLogNames) Global
  Bool returnVal = HTG:SystemLogger.Trace(akCallingObject, MainLogName, subLogame, asMessage, 2, bShowNormalTrace, True, bPrefixTraceWithLogNames) ; #DEBUG_LINE_NO:35
  Game.error(asMessage) ; #DEBUG_LINE_NO:36
  Return returnVal ; #DEBUG_LINE_NO:38
EndFunction

Bool Function TraceRefCollectionAlias(RefCollectionAlias akAlias, String MainLogName, String subLogame, String asMessage) Global
  String sAlias = "" ; #DEBUG_LINE_NO:42
  Int I = 0 ; #DEBUG_LINE_NO:43
  ObjectReference[] array = akAlias.GetArray() ; #DEBUG_LINE_NO:44
  Int count = array.Length ; #DEBUG_LINE_NO:45
  HTG:SystemLogger.Trace(akAlias as ScriptObject, MainLogName, subLogame, asMessage, 0, False, False, True) ; #DEBUG_LINE_NO:46
  HTG:SystemLogger.Trace(akAlias as ScriptObject, MainLogName, subLogame, "array.Length: " + count as String, 0, False, False, True) ; #DEBUG_LINE_NO:47
  While I < count ; #DEBUG_LINE_NO:48
    sAlias += (("\takAlias[" + I as String) + "]: " + (array[I] as Form) as String) + "\n" ; #DEBUG_LINE_NO:49
    I += 1 ; #DEBUG_LINE_NO:50
  EndWhile
  Return HTG:SystemLogger.Trace(akAlias as ScriptObject, MainLogName, subLogame, sAlias, 0, False, False, True) ; #DEBUG_LINE_NO:53
EndFunction

Function LogGlobal(String asMessage) Global
  ObjectReference player = Game.GetPlayer() as ObjectReference ; #DEBUG_LINE_NO:57
  HTG:SystemLogger.Trace(player as ScriptObject, "Regenesys", "System", asMessage, 0, False, False, True) ; #DEBUG_LINE_NO:58
EndFunction

Function LogObjectGlobal(ScriptObject akCallingObject, String asMessage) Global
  HTG:SystemLogger.Trace(akCallingObject, "Regenesys", "System", asMessage, 0, False, False, True) ; #DEBUG_LINE_NO:62
EndFunction

Function LogRefCollectionAliasGlobal(RefCollectionAlias akAlias, String asMessage) Global
  HTG:SystemLogger.TraceRefCollectionAlias(akAlias, "Regenesys", "System", asMessage) ; #DEBUG_LINE_NO:66
EndFunction

Function LogWarnGlobal(ScriptObject akCallingObject, String asMessage) Global
  HTG:SystemLogger.Warn(akCallingObject, "Regenesys", "System", asMessage, False, True) ; #DEBUG_LINE_NO:70
EndFunction

Function LogErrorGlobal(ScriptObject akCallingObject, String asMessage) Global
  HTG:SystemLogger.error(akCallingObject, "Regenesys", "System", asMessage, False, True) ; #DEBUG_LINE_NO:74
EndFunction

Function Log(String asMessage, Int aiSeverity)
  If aiSeverity == 0 ; #DEBUG_LINE_NO:78
    HTG:SystemLogger.Trace(_quest as ScriptObject, MainLogName, SubLogName, asMessage, 0, False, False, True) ; #DEBUG_LINE_NO:79
  ElseIf aiSeverity == 1 ; #DEBUG_LINE_NO:80
    HTG:SystemLogger.Warn(_quest as ScriptObject, MainLogName, SubLogName, asMessage, False, True) ; #DEBUG_LINE_NO:81
  ElseIf aiSeverity == 2 ; #DEBUG_LINE_NO:82
    HTG:SystemLogger.error(_quest as ScriptObject, MainLogName, SubLogName, asMessage, False, True) ; #DEBUG_LINE_NO:83
  EndIf
EndFunction

Function LogObject(ScriptObject akCallingObject, String asMessage)
  HTG:SystemLogger.Trace(akCallingObject, MainLogName, SubLogName, asMessage, 0, False, False, True) ; #DEBUG_LINE_NO:88
EndFunction

Function LogRefCollectionAlias(RefCollectionAlias akAlias, String asMessage)
  HTG:SystemLogger.TraceRefCollectionAlias(akAlias, MainLogName, SubLogName, asMessage) ; #DEBUG_LINE_NO:92
EndFunction
