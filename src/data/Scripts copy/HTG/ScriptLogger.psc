Scriptname HTG:ScriptLogger extends ScriptObject
import HTG:Collections

Group LogNames
    String Property MainLogName Mandatory Const Auto
    String Property SubLogName Mandatory Const Auto
EndGroup

;************************************************************************************
;****************************	   CUSTOM TRACE LOG	    *****************************
;************************************************************************************
bool Function Trace(ScriptObject CallingObject, string asTextToPrint, int aiSeverity = 0, bool bShowNormalTrace = false, bool bShowWarning = false, bool bPrefixTraceWithLogNames = true) DebugOnly
    If MainLogName == "" || SubLogName == ""
        return False
    EndIf
    bool returnVal = Debug.TraceLog(CallingObject, asTextToPrint, MainLogName, SubLogName,  aiSeverity, bShowNormalTrace, bShowWarning, bPrefixTraceWithLogNames)
    
    return returnVal
endFunction

bool Function Warn(ScriptObject CallingObject, string asTextToPrint, int aiSeverity = 2, bool bShowNormalTrace = false, bool bShowWarning = true, bool bPrefixTraceWithLogNames = true) BetaOnly
    bool returnVal = Debug.TraceLog(CallingObject, asTextToPrint, MainLogName, SubLogName,  aiSeverity, bShowNormalTrace, bShowWarning, bPrefixTraceWithLogNames)

    return returnVal
EndFunction

bool Function Error(ScriptObject CallingObject, string asMessage, bool bShowNormalTrace = false, bool bPrefixTraceWithLogNames = true) BetaOnly
    bool returnVal = Trace(CallingObject, asMessage, 2, bShowNormalTrace, False, bPrefixTraceWithLogNames)
    Game.Error(asMessage)

    return returnVal
EndFunction

Bool Function TraceFunction() Global
    Debug.TraceFunction()
EndFunction

Bool Function TraceRefCollectionAliasEntries(ScriptObject CallingObject, RefCollectionAlias akAlias, String asString = "Tracing RefCollection ALias...") DebugOnly
    String sAlias
    Int i = 0
    ObjectReference[] array = akAlias.GetArray()
    Int count = array.Length
    Trace(CallingObject, asString)
    Trace(CallingObject, "array.Length: " + count)
    
    While i < count
        sAlias += "akAlias[" + i + "]: " + array[i] as Form + " "
        i += 1
    EndWhile

    return Trace(CallingObject, sAlias)
EndFunction

Bool Function TraceListCollection(ScriptObject CallingObject, List akList, String asMessage = "Tracing HTG:Collection:List...") DebugOnly
    asMessage + "\n" + akList.ToString()
EndFunction