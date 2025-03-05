ScriptName HTG:QuestExt Extends Quest

;-- Variables ---------------------------------------
Int _currentTimerCycle = 0
Bool _initializeTimerStarted
Bool _isInitialRun
Bool _isInitialized
Bool _mainTimerStarted
Int _maxTimerCycle = 50
Bool _readyTimerStarted
htg:structs:systemtimerids _timerIds
Float _timerInterval = 0.01

;-- Guards ------------------------------------------
;*** WARNING: Guard declaration syntax is EXPERIMENTAL, subject to change
Guard _initializeTimerGuard
Guard _mainTimerGuard
Guard _readyTimerGuard

;-- Properties --------------------------------------
htg:systemutilities Property SystemUtilities Auto Const mandatory
htg:systemlogger Property Logger hidden
  htg:systemlogger Function Get()
    Return SystemUtilities.Logger ; #DEBUG_LINE_NO:10
  EndFunction
EndProperty
Bool Property IsInitialized hidden
  Bool Function Get()
    Return _isInitialized ; #DEBUG_LINE_NO:16
  EndFunction
EndProperty
Bool Property IsInitialRun hidden
  Bool Function Get()
    Return _isInitialRun ; #DEBUG_LINE_NO:22
  EndFunction
EndProperty

;-- Functions ---------------------------------------

Event HTG:QuestExt.OnInitialRun(HTG:QuestExt akSender, Var[] akArgs)
  ; Empty function
EndEvent

Event HTG:QuestExt.OnMain(HTG:QuestExt akSender, Var[] akArgs)
  ; Empty function
EndEvent

Function _InitialRun()
  ; Empty function
EndFunction

Event OnInit()
  Self.RegisterForCustomEvent(Self as ScriptObject, "htg:questext_OnInitialRun") ; #DEBUG_LINE_NO:43
  Self.RegisterForCustomEvent(Self as ScriptObject, "htg:questext_OnMain") ; #DEBUG_LINE_NO:44
  _isInitialRun = !_isInitialized ; #DEBUG_LINE_NO:45
  _timerIds = new htg:structs:systemtimerids ; #DEBUG_LINE_NO:46
  Self.StartTimer(_timerInterval, _timerIds.InitializeId) ; #DEBUG_LINE_NO:47
EndEvent

Event OnQuestInit()
  Self.WaitForInitialized() ; #DEBUG_LINE_NO:51
EndEvent

Event OnQuestStarted()
  Self.WaitForInitialized() ; #DEBUG_LINE_NO:55
  Self.StartTimer(_timerInterval, _timerIds.MainId) ; #DEBUG_LINE_NO:56
EndEvent

Event OnTimer(Int aiTimerID)
  Int I = 0 ; #DEBUG_LINE_NO:60
  Int count = 0 ; #DEBUG_LINE_NO:61
  If aiTimerID == _timerIds.InitializeId ; #DEBUG_LINE_NO:63
    If !_isInitialRun && _initializeTimerStarted ; #DEBUG_LINE_NO:64
      htg:systemlogger.LogObjectGlobal(Self as ScriptObject, "InitializeTimer - Is Not Initial Run or Timer is already running. No need to proceed.") ; #DEBUG_LINE_NO:65
      Return  ; #DEBUG_LINE_NO:66
    ElseIf _initializeTimerStarted
      Self.StartTimer(_timerInterval, _timerIds.InitializeId) ; #DEBUG_LINE_NO:68
      Return  ; #DEBUG_LINE_NO:69
    EndIf
    Float itimerInterval = _timerInterval ; #DEBUG_LINE_NO:72
    Int timerId = -1 ; #DEBUG_LINE_NO:73
    Guard _initializeTimerGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:75
      _initializeTimerStarted = True ; #DEBUG_LINE_NO:76
      If !Self.Initialize() && _currentTimerCycle < _maxTimerCycle ; #DEBUG_LINE_NO:77
        _currentTimerCycle += 1 ; #DEBUG_LINE_NO:78
        timerId = _timerIds.InitializeId ; #DEBUG_LINE_NO:79
      ElseIf !_isInitialized && _currentTimerCycle == _maxTimerCycle ; #DEBUG_LINE_NO:80
        htg:systemlogger.LogErrorGlobal(Self as ScriptObject, "HTG:SystemUtililities could not be Initialized") ; #DEBUG_LINE_NO:81
      Else
        Self.Logger.Log("InitializeTimer - Is Initialized. Starting ReadyTimer", 0) ; #DEBUG_LINE_NO:83
        timerId = SystemUtilities.Timers.SystemTimerIds.InitialRunId ; #DEBUG_LINE_NO:84
      EndIf
      _initializeTimerStarted = False ; #DEBUG_LINE_NO:86
    EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
    If timerId > -1 ; #DEBUG_LINE_NO:89
      Self.StartTimer(itimerInterval, timerId) ; #DEBUG_LINE_NO:90
    EndIf
  ElseIf aiTimerID == _timerIds.InitialRunId ; #DEBUG_LINE_NO:92
    If !_isInitialRun || _readyTimerStarted ; #DEBUG_LINE_NO:93
      Self.Logger.Log("ReadyTimer - Is Not Initial Run or Timer is already running. No need to proceed.", 0) ; #DEBUG_LINE_NO:94
      Return  ; #DEBUG_LINE_NO:95
    EndIf
    Guard _readyTimerGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:98
      _readyTimerStarted = True ; #DEBUG_LINE_NO:99
      Self.SendCustomEvent("htg:questext_OnInitialRun", None) ; #DEBUG_LINE_NO:100
      Self._InitialRun() ; #DEBUG_LINE_NO:101
      _isInitialRun = False ; #DEBUG_LINE_NO:102
      _readyTimerStarted = False ; #DEBUG_LINE_NO:103
    EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
    Self.Logger.Log("ReadyTimer - Completed Initial Run.", 0) ; #DEBUG_LINE_NO:106
  ElseIf aiTimerID == _timerIds.MainId ; #DEBUG_LINE_NO:107
    If _isInitialRun || _mainTimerStarted ; #DEBUG_LINE_NO:108
      Self.Logger.Log("MainTimer - Is Initial Run or Timer is already running. No need to proceed.", 0) ; #DEBUG_LINE_NO:109
      Return  ; #DEBUG_LINE_NO:110
    EndIf
    Bool restartTimer = False ; #DEBUG_LINE_NO:113
    Guard _mainTimerGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:114
      _mainTimerStarted = True ; #DEBUG_LINE_NO:115
      Self.SendCustomEvent("htg:questext_OnMain", None) ; #DEBUG_LINE_NO:116
      restartTimer = Self._Main() ; #DEBUG_LINE_NO:117
      _mainTimerStarted = False ; #DEBUG_LINE_NO:118
    EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
    If restartTimer ; #DEBUG_LINE_NO:121
      Self.StartTimer(_timerInterval, _timerIds.MainId) ; #DEBUG_LINE_NO:122
    EndIf
  EndIf
EndEvent

Bool Function Initialize()
  If !_isInitialized ; #DEBUG_LINE_NO:134
    _isInitialized = Self._SetSystemUtilities() ; #DEBUG_LINE_NO:135
  EndIf
  Return _isInitialized ; #DEBUG_LINE_NO:138
EndFunction

Function WaitForInitialized()
  If _isInitialized ; #DEBUG_LINE_NO:142
    Return  ; #DEBUG_LINE_NO:143
  EndIf
  Int currentCycle = 0 ; #DEBUG_LINE_NO:146
  Int maxCycle = 600 ; #DEBUG_LINE_NO:147
  Bool maxCycleHit = False ; #DEBUG_LINE_NO:148
  While !maxCycleHit && !_isInitialized ; #DEBUG_LINE_NO:151
    Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:152
    If currentCycle < maxCycle ; #DEBUG_LINE_NO:154
      currentCycle += 1 ; #DEBUG_LINE_NO:155
    Else
      maxCycleHit = True ; #DEBUG_LINE_NO:157
    EndIf
  EndWhile
EndFunction

Bool Function _SetSystemUtilities()
  SystemUtilities.WaitForInitialized() ; #DEBUG_LINE_NO:163
  Return True ; #DEBUG_LINE_NO:164
EndFunction

Bool Function _Main()
  Return False ; #DEBUG_LINE_NO:171
EndFunction
