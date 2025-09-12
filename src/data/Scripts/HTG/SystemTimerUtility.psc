Scriptname HTG:SystemTimerUtility extends ScriptObject Hidden
import HTG:Structs

SystemTimerIds Property SystemIds Hidden
    SystemTimerIds Function Get()
        return new SystemTimerIds
    EndFunction
EndProperty

SystemTimerDefaults Property Defaults Hidden
    SystemTimerDefaults Function Get()
        return new SystemTimerDefaults
    EndFunction
EndProperty

SystemWaitDefaults Property WaitDefaults Hidden
    SystemWaitDefaults Function Get()
        return new SystemWaitDefaults
    EndFunction
EndProperty