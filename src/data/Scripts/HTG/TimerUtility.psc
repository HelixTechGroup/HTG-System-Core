ScriptName HTG:TimerUtility Extends ScriptObject hidden

;-- Properties --------------------------------------
htg:structs:systemtimerids Property SystemTimerIds hidden
  htg:structs:systemtimerids Function Get()
    Return new htg:structs:systemtimerids ; #DEBUG_LINE_NO:6
  EndFunction
EndProperty
htg:structs:timerdefaults Property TimerDefaults hidden
  htg:structs:timerdefaults Function Get()
    Return new htg:structs:timerdefaults ; #DEBUG_LINE_NO:12
  EndFunction
EndProperty
htg:structs:waitdefaults Property WaitDefaults hidden
  htg:structs:waitdefaults Function Get()
    Return new htg:structs:waitdefaults ; #DEBUG_LINE_NO:18
  EndFunction
EndProperty
