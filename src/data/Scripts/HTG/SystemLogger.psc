Scriptname HTG:SystemLogger extends ReferenceAlias Hidden

Group LogNames
    String Property MainLogName Mandatory Const Auto
    String Property SubLogName Mandatory Const Auto
EndGroup

LogSeverity Property Severity Hidden
    LogSeverity Function Get()
        return new LogSeverity
    EndFunction
EndProperty

Struct LogSeverity
    Int Info = 0
    Int Warning = 1
    Int Error = 2
EndStruct

Quest _quest

Event OnAliasInit()
    _quest = GetOwningQuest()
EndEvent

bool Function Trace(ScriptObject akCallingObject, String mainLogName, String subLogame, String asMessage, Int aiSeverity = 0, Bool bShowNormalTrace = False, Bool bShowWarning = False, Bool bPrefixTraceWithLogNames = True) Global DebugOnly
    return Debug.TraceLog(akCallingObject, asMessage, mainLogName, subLogame,  aiSeverity, bShowNormalTrace, bShowWarning, bPrefixTraceWithLogNames)
endFunction

bool Function Warn(ScriptObject akCallingObject, String mainLogName, String subLogame, string asMessage, bool bShowNormalTrace = false, bool bPrefixTraceWithLogNames = true) Global BetaOnly
    return Trace(akCallingObject, mainLogName, subLogame, asMessage, 2, bShowNormalTrace, True, bPrefixTraceWithLogNames)
EndFunction

bool Function Error(ScriptObject akCallingObject, String mainLogName, String subLogame, string asMessage, bool bShowNormalTrace = false, bool bPrefixTraceWithLogNames = true) Global BetaOnly
    bool returnVal = Trace(akCallingObject, mainLogName, subLogame, asMessage, 2, bShowNormalTrace, True, bPrefixTraceWithLogNames)
    Game.Error(asMessage)

    return returnVal
EndFunction

Function TraceFunction()
    Debug.TraceFunction()
EndFunction

Bool Function TraceRefCollectionAlias(RefCollectionAlias akAlias, String mainLogName,  String subLogame, String asMessage) Global
    String sAlias
    Int i = 0
    ObjectReference[] array = akAlias.GetArray()
    Int count = array.Length
    Trace(akAlias, mainLogName, subLogame, asMessage)
    Trace(akAlias, mainLogName, subLogame, "array.Length: " + count)
    While i < count
        sAlias += "\takAlias[" + i + "]: " + array[i] as Form + "\n"
        i += 1
    EndWhile

    return Trace(akAlias, mainLogName, subLogame, sAlias)
EndFunction

Function LogGlobal(String asMessage) Global
    ObjectReference player = Game.GetPlayer()
    Trace(player, "Regenesys", "System", asMessage)
EndFunction

Function LogObjectGlobal(ScriptObject akCallingObject, String asMessage) Global
    Trace(akCallingObject, "Regenesys", "System", asMessage)
EndFunction

Function LogRefCollectionAliasGlobal(RefCollectionAlias akAlias, String asMessage) Global
    TraceRefCollectionAlias(akAlias, "Regenesys", "System", asMessage)
EndFunction

Function LogWarnGlobal(ScriptObject akCallingObject, String asMessage) Global
    Warn(akCallingObject, "Regenesys", "System", asMessage)
EndFunction
    
Function LogErrorGlobal(ScriptObject akCallingObject, String asMessage) Global
    Error(akCallingObject, "Regenesys", "System", asMessage)
EndFunction

Function Log(String asMessage, Int aiSeverity = 0)
    If aiSeverity == 0
        Trace(_quest, MainLogName, SubLogName, asMessage)
    ElseIf aiSeverity == 1
        Warn(_quest, MainLogName, SubLogName,asMessage)
    ElseIf aiSeverity == 2
        Error(_quest, MainLogName, SubLogName,asMessage)
    EndIf
EndFunction

Function LogObject(ScriptObject akCallingObject, String asMessage)
    Trace(akCallingObject, MainLogName, SubLogName, asMessage)
EndFunction

Function LogRefCollectionAlias(RefCollectionAlias akAlias, String asMessage)
    TraceRefCollectionAlias(akAlias, MainLogName, SubLogName, asMessage)
EndFunction