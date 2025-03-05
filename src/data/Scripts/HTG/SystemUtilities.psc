ScriptName HTG:SystemUtilities Extends ReferenceAlias hidden

;-- Variables ---------------------------------------
htg:armorutility _armorUtility
Int _currentTimerCycle = 0
htg:formutility _formUtility
Int _initializeTimerId = 1
Bool _initializeTimerStarted
htg:intutility _intUtility
Bool _isInitialized
htg:systemlogger _logger
Int _maxTimerCycle = 50
htg:structs:systemtimerids _timerIds
Float _timerInternal = 0.01
htg:timerutility _timerUtility

;-- Guards ------------------------------------------
;*** WARNING: Guard declaration syntax is EXPERIMENTAL, subject to change
Guard _initializeTimerGuard
Guard _utilitiesGuard

;-- Properties --------------------------------------
htg:systemlogger Property Logger hidden
  htg:systemlogger Function Get()
    Return _logger ; #DEBUG_LINE_NO:15
  EndFunction
EndProperty
htg:timerutility Property Timers hidden
  htg:timerutility Function Get()
    Return _timerUtility ; #DEBUG_LINE_NO:21
  EndFunction
EndProperty
htg:intutility Property Integers hidden
  htg:intutility Function Get()
    Return _intUtility ; #DEBUG_LINE_NO:27
  EndFunction
EndProperty
htg:formutility Property Forms hidden
  htg:formutility Function Get()
    Return _formUtility ; #DEBUG_LINE_NO:33
  EndFunction
EndProperty
htg:armorutility Property Armors hidden
  htg:armorutility Function Get()
    Return _armorUtility ; #DEBUG_LINE_NO:39
  EndFunction
EndProperty
Bool Property IsInitialized hidden
  Bool Function Get()
    Return _logger != None && _timerUtility != None && _intUtility != None && _formUtility != None && _armorUtility != None ; #DEBUG_LINE_NO:51,52,53,54,55
  EndFunction
EndProperty

;-- Functions ---------------------------------------

Event OnInit()
  Self.StartTimer(_timerInternal, _initializeTimerId) ; #DEBUG_LINE_NO:76
EndEvent

Bool Function Initialize()
  If Self.IsInitialized ; #DEBUG_LINE_NO:80
    Return True ; #DEBUG_LINE_NO:81
  EndIf
  ScriptObject so = Self as ScriptObject ; #DEBUG_LINE_NO:85
  htg:systemlogger.LogObjectGlobal(Self as ScriptObject, ("HTG:SystemUtilities:" + Self as String) + "\n\t As ScriptObject:" + so as String) ; #DEBUG_LINE_NO:86
  Self._SetSystemUtilities(so) ; #DEBUG_LINE_NO:88
  Return Self._CheckSystemUtilites() ; #DEBUG_LINE_NO:91
EndFunction

Function _SetSystemUtilities(ScriptObject akScriptObject)
  If akScriptObject == None ; #DEBUG_LINE_NO:95
    htg:systemlogger.LogErrorGlobal(Self as ScriptObject, "The object attached to  this Script is not a ScriptObject:" + Self as String) ; #DEBUG_LINE_NO:96
    Return  ; #DEBUG_LINE_NO:97
  EndIf
  If _logger == None ; #DEBUG_LINE_NO:105
    _logger = akScriptObject as htg:systemlogger ; #DEBUG_LINE_NO:106
  EndIf
  If _timerUtility == None ; #DEBUG_LINE_NO:109
    _timerUtility = akScriptObject as htg:timerutility ; #DEBUG_LINE_NO:110
    htg:systemlogger.LogObjectGlobal(Self as ScriptObject, "Timer:" + _timerUtility as String) ; #DEBUG_LINE_NO:111
  EndIf
  If _intUtility == None ; #DEBUG_LINE_NO:114
    _intUtility = akScriptObject as htg:intutility ; #DEBUG_LINE_NO:115
    htg:systemlogger.LogObjectGlobal(Self as ScriptObject, "Integers:" + _intUtility as String) ; #DEBUG_LINE_NO:116
  EndIf
  If _formUtility == None ; #DEBUG_LINE_NO:119
    _formUtility = akScriptObject as htg:formutility ; #DEBUG_LINE_NO:120
    htg:systemlogger.LogObjectGlobal(Self as ScriptObject, "Utilities.Forms:" + _formUtility as String) ; #DEBUG_LINE_NO:121
  EndIf
  If _armorUtility == None ; #DEBUG_LINE_NO:124
    _armorUtility = akScriptObject as htg:armorutility ; #DEBUG_LINE_NO:125
    htg:systemlogger.LogObjectGlobal(Self as ScriptObject, "Utilities.Armors:" + _armorUtility as String) ; #DEBUG_LINE_NO:126
  EndIf
EndFunction

Bool Function _CheckSystemUtilites()
  Bool res = False ; #DEBUG_LINE_NO:131
  If _logger == None ; #DEBUG_LINE_NO:137
    htg:systemlogger.LogWarnGlobal(Self as ScriptObject, "Logger is None.") ; #DEBUG_LINE_NO:138
  ElseIf _timerUtility == None ; #DEBUG_LINE_NO:139
    htg:systemlogger.LogWarnGlobal(Self as ScriptObject, "Timers is None.") ; #DEBUG_LINE_NO:140
  ElseIf _intUtility == None ; #DEBUG_LINE_NO:141
    htg:systemlogger.LogWarnGlobal(Self as ScriptObject, "Integers is None.") ; #DEBUG_LINE_NO:142
  ElseIf _formUtility == None ; #DEBUG_LINE_NO:143
    htg:systemlogger.LogWarnGlobal(Self as ScriptObject, "Forms is None.") ; #DEBUG_LINE_NO:144
  ElseIf _armorUtility == None ; #DEBUG_LINE_NO:145
    htg:systemlogger.LogWarnGlobal(Self as ScriptObject, "Armors is None.") ; #DEBUG_LINE_NO:146
  Else
    res = True ; #DEBUG_LINE_NO:148
  EndIf
  Return Self.IsInitialized ; #DEBUG_LINE_NO:151
EndFunction

Event OnTimer(Int aiTimerID)
  If aiTimerID == _initializeTimerId ; #DEBUG_LINE_NO:155
    If !Self.Initialize() && _currentTimerCycle < _maxTimerCycle ; #DEBUG_LINE_NO:156
      _currentTimerCycle += 1 ; #DEBUG_LINE_NO:157
      Self.StartTimer(_timerInternal, _initializeTimerId) ; #DEBUG_LINE_NO:158
    ElseIf _currentTimerCycle == _maxTimerCycle ; #DEBUG_LINE_NO:159
      htg:systemlogger.LogErrorGlobal(Self as ScriptObject, "HTG:SystemUtililities could not be Initialized") ; #DEBUG_LINE_NO:160
    EndIf
  EndIf
EndEvent

Function WaitForInitialized()
  If Self.IsInitialized ; #DEBUG_LINE_NO:166
    Return  ; #DEBUG_LINE_NO:167
  EndIf
  Int currentCycle = 0 ; #DEBUG_LINE_NO:170
  Int maxCycle = 600 ; #DEBUG_LINE_NO:171
  Bool maxCycleHit = False ; #DEBUG_LINE_NO:172
  While !maxCycleHit && !Self.IsInitialized ; #DEBUG_LINE_NO:173
    Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:174
    If currentCycle < maxCycle ; #DEBUG_LINE_NO:176
      currentCycle += 1 ; #DEBUG_LINE_NO:177
    Else
      maxCycleHit = True ; #DEBUG_LINE_NO:179
    EndIf
  EndWhile
EndFunction
