Scriptname HTG:TimerUtility extends ScriptObject Hidden
import HTG:Structs

SystemTimerIds Property SystemTimerIds Hidden
    SystemTimerIds Function Get()
        return new SystemTimerIds
    EndFunction
EndProperty

TimerDefaults Property TimerDefaults Hidden
    TimerDefaults Function Get()
        return new TimerDefaults
    EndFunction
EndProperty

WaitDefaults Property WaitDefaults Hidden
    WaitDefaults Function Get()
        return new WaitDefaults
    EndFunction
EndProperty