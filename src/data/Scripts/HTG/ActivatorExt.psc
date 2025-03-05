ScriptName HTG:ActivatorExt Extends Activator

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

Event HTG:ActivatorExt.OnInitialRun(HTG:ActivatorExt akSender, Var[] akArgs)
  ; Empty function
EndEvent

Event HTG:ActivatorExt.OnMain(HTG:ActivatorExt akSender, Var[] akArgs)
  ; Empty function
EndEvent

Function _InitialRun()
  ; Empty function
EndFunction

Event OnInit()
  Self.RegisterForCustomEvent(Self as ScriptObject, "htg:activatorext_OnInitialRun") ; #DEBUG_LINE_NO:43
  Self.RegisterForCustomEvent(Self as ScriptObject, "htg:activatorext_OnMain") ; #DEBUG_LINE_NO:44
  _isInitialRun = !_isInitialized ; #DEBUG_LINE_NO:45
  _timerIds = new htg:structs:systemtimerids ; #DEBUG_LINE_NO:46
  Self.StartTimer(_timerInterval, _timerIds.InitializeId) ; #DEBUG_LINE_NO:47
EndEvent

Event OnTimer(Int aiTimerID)
  Int I = 0 ; #DEBUG_LINE_NO:51
  Int count = 0 ; #DEBUG_LINE_NO:52
  If aiTimerID == _timerIds.InitializeId ; #DEBUG_LINE_NO:54
    If !_isInitialRun || _initializeTimerStarted ; #DEBUG_LINE_NO:55
      htg:systemlogger.LogObjectGlobal(Self as ScriptObject, "InitializeTimer - Is Not Initial Run or Timer is already running. No need to proceed.") ; #DEBUG_LINE_NO:56
      Return  ; #DEBUG_LINE_NO:57
    EndIf
    Float itimerInterval = _timerInterval ; #DEBUG_LINE_NO:60
    Int timerId = -1 ; #DEBUG_LINE_NO:61
    Guard _initializeTimerGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:63
      _initializeTimerStarted = True ; #DEBUG_LINE_NO:64
      If !Self.Initialize() && _currentTimerCycle < _maxTimerCycle ; #DEBUG_LINE_NO:65
        _currentTimerCycle += 1 ; #DEBUG_LINE_NO:66
        timerId = _timerIds.InitializeId ; #DEBUG_LINE_NO:67
      ElseIf !_isInitialized && _currentTimerCycle == _maxTimerCycle ; #DEBUG_LINE_NO:68
        htg:systemlogger.LogErrorGlobal(Self as ScriptObject, "HTG:SystemUtililities could not be Initialized") ; #DEBUG_LINE_NO:69
      Else
        Self.Logger.Log("InitializeTimer - Is Initialized. Starting ReadyTimer", 0) ; #DEBUG_LINE_NO:71
        timerId = SystemUtilities.Timers.SystemTimerIds.InitialRunId ; #DEBUG_LINE_NO:72
      EndIf
      _initializeTimerStarted = False ; #DEBUG_LINE_NO:74
    EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
    If timerId > -1 ; #DEBUG_LINE_NO:77
      Self.StartTimer(itimerInterval, timerId) ; #DEBUG_LINE_NO:78
    EndIf
  ElseIf aiTimerID == _timerIds.InitialRunId ; #DEBUG_LINE_NO:80
    If !_isInitialRun || _readyTimerStarted ; #DEBUG_LINE_NO:81
      Self.Logger.Log("ReadyTimer - Is Not Initial Run or Timer is already running. No need to proceed.", 0) ; #DEBUG_LINE_NO:82
      Return  ; #DEBUG_LINE_NO:83
    EndIf
    Guard _readyTimerGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:86
      _readyTimerStarted = True ; #DEBUG_LINE_NO:87
      Self.SendCustomEvent("htg:activatorext_OnInitialRun", None) ; #DEBUG_LINE_NO:88
      Self._InitialRun() ; #DEBUG_LINE_NO:89
      _isInitialRun = False ; #DEBUG_LINE_NO:90
      _readyTimerStarted = False ; #DEBUG_LINE_NO:91
    EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
    Self.Logger.Log("ReadyTimer - Completed Initial Run.", 0) ; #DEBUG_LINE_NO:94
    Self.StartTimer(_timerInterval, _timerIds.MainId) ; #DEBUG_LINE_NO:95
  ElseIf aiTimerID == _timerIds.MainId ; #DEBUG_LINE_NO:96
    If _isInitialRun || _mainTimerStarted ; #DEBUG_LINE_NO:97
      Self.Logger.Log("MainTimer - Is Initial Run or Timer is already running. No need to proceed.", 0) ; #DEBUG_LINE_NO:98
      Return  ; #DEBUG_LINE_NO:99
    EndIf
    Bool restartTimer = False ; #DEBUG_LINE_NO:102
    Guard _mainTimerGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:103
      _mainTimerStarted = True ; #DEBUG_LINE_NO:104
      Self.SendCustomEvent("htg:activatorext_OnMain", None) ; #DEBUG_LINE_NO:105
      restartTimer = Self._Main() ; #DEBUG_LINE_NO:106
      _mainTimerStarted = False ; #DEBUG_LINE_NO:107
    EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
    If restartTimer ; #DEBUG_LINE_NO:110
      Self.StartTimer(_timerInterval, _timerIds.MainId) ; #DEBUG_LINE_NO:111
    EndIf
  EndIf
EndEvent

Bool Function Initialize()
  If !_isInitialized ; #DEBUG_LINE_NO:123
    _isInitialized = Self._SetSystemUtilities() ; #DEBUG_LINE_NO:124
  EndIf
  Return _isInitialized ; #DEBUG_LINE_NO:127
EndFunction

Function WaitForInitialized()
  If _isInitialized ; #DEBUG_LINE_NO:131
    Return  ; #DEBUG_LINE_NO:132
  EndIf
  Int currentCycle = 0 ; #DEBUG_LINE_NO:135
  Int maxCycle = 600 ; #DEBUG_LINE_NO:136
  Bool maxCycleHit = False ; #DEBUG_LINE_NO:137
  While !maxCycleHit && !_isInitialized ; #DEBUG_LINE_NO:140
    Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:141
    If currentCycle < maxCycle ; #DEBUG_LINE_NO:143
      currentCycle += 1 ; #DEBUG_LINE_NO:144
    Else
      maxCycleHit = True ; #DEBUG_LINE_NO:146
    EndIf
  EndWhile
EndFunction

Bool Function _SetSystemUtilities()
  SystemUtilities.WaitForInitialized() ; #DEBUG_LINE_NO:152
  Return True ; #DEBUG_LINE_NO:153
EndFunction

Bool Function _Main()
  Return False ; #DEBUG_LINE_NO:160
EndFunction
