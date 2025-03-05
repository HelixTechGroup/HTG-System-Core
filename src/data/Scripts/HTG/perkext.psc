ScriptName HTG:PerkExt Extends Perk
{ Extended Perk Script }

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
    Return SystemUtilities.Logger ; #DEBUG_LINE_NO:11
  EndFunction
EndProperty
Bool Property IsInitialized hidden
  Bool Function Get()
    Return _isInitialized ; #DEBUG_LINE_NO:17
  EndFunction
EndProperty
Bool Property IsInitialRun hidden
  Bool Function Get()
    Return _isInitialRun ; #DEBUG_LINE_NO:23
  EndFunction
EndProperty

;-- Functions ---------------------------------------

Event HTG:QuestExt.OnInitialRun(htg:questext akSender, Var[] akArgs)
  ; Empty function
EndEvent

Event HTG:QuestExt.OnMain(htg:questext akSender, Var[] akArgs)
  ; Empty function
EndEvent

Function _InitialRun()
  ; Empty function
EndFunction

Event OnInit()
  _isInitialRun = !_isInitialized ; #DEBUG_LINE_NO:46
  _timerIds = new htg:structs:systemtimerids ; #DEBUG_LINE_NO:47
  Self.StartTimer(_timerInterval, _timerIds.InitializeId) ; #DEBUG_LINE_NO:48
EndEvent

Event OnEntryRun(Int auiEntryID, ObjectReference akTarget, Actor akOwner)
  Self.WaitForInitialized() ; #DEBUG_LINE_NO:52
EndEvent

Event OnTimer(Int aiTimerID)
  Int I = 0 ; #DEBUG_LINE_NO:56
  Int count = 0 ; #DEBUG_LINE_NO:57
  If aiTimerID == _timerIds.InitializeId ; #DEBUG_LINE_NO:59
    If !_isInitialRun && _initializeTimerStarted ; #DEBUG_LINE_NO:60
      htg:systemlogger.LogObjectGlobal(Self as ScriptObject, "InitializeTimer - Is Not Initial Run or Timer is already running. No need to proceed.") ; #DEBUG_LINE_NO:61
      Return  ; #DEBUG_LINE_NO:62
    ElseIf _initializeTimerStarted
      Self.StartTimer(_timerInterval, _timerIds.InitializeId) ; #DEBUG_LINE_NO:64
      Return  ; #DEBUG_LINE_NO:65
    EndIf
    Float itimerInterval = _timerInterval ; #DEBUG_LINE_NO:68
    Int timerId = -1 ; #DEBUG_LINE_NO:69
    Guard _initializeTimerGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:71
      _initializeTimerStarted = True ; #DEBUG_LINE_NO:72
      If !Self.Initialize() && _currentTimerCycle < _maxTimerCycle ; #DEBUG_LINE_NO:73
        _currentTimerCycle += 1 ; #DEBUG_LINE_NO:74
        timerId = _timerIds.InitializeId ; #DEBUG_LINE_NO:75
      ElseIf !_isInitialized && _currentTimerCycle == _maxTimerCycle ; #DEBUG_LINE_NO:76
        htg:systemlogger.LogErrorGlobal(Self as ScriptObject, "HTG:SystemUtililities could not be Initialized") ; #DEBUG_LINE_NO:77
      Else
        Self.Logger.Log("InitializeTimer - Is Initialized. Starting ReadyTimer", 0) ; #DEBUG_LINE_NO:79
        timerId = SystemUtilities.Timers.SystemTimerIds.InitialRunId ; #DEBUG_LINE_NO:80
      EndIf
      _initializeTimerStarted = False ; #DEBUG_LINE_NO:82
    EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
    If timerId > -1 ; #DEBUG_LINE_NO:85
      Self.StartTimer(itimerInterval, timerId) ; #DEBUG_LINE_NO:86
    EndIf
  ElseIf aiTimerID == _timerIds.InitialRunId ; #DEBUG_LINE_NO:88
    If !_isInitialRun || _readyTimerStarted ; #DEBUG_LINE_NO:89
      Self.Logger.Log("ReadyTimer - Is Not Initial Run or Timer is already running. No need to proceed.", 0) ; #DEBUG_LINE_NO:90
      Return  ; #DEBUG_LINE_NO:91
    EndIf
    Guard _readyTimerGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:94
      _readyTimerStarted = True ; #DEBUG_LINE_NO:95
      Self._InitialRun() ; #DEBUG_LINE_NO:97
      _isInitialRun = False ; #DEBUG_LINE_NO:98
      _readyTimerStarted = False ; #DEBUG_LINE_NO:99
    EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
    Self.Logger.Log("ReadyTimer - Completed Initial Run.", 0) ; #DEBUG_LINE_NO:102
    Self.StartTimer(_timerInterval, _timerIds.MainId) ; #DEBUG_LINE_NO:103
  ElseIf aiTimerID == _timerIds.MainId ; #DEBUG_LINE_NO:104
    If _isInitialRun || _mainTimerStarted ; #DEBUG_LINE_NO:105
      Self.Logger.Log("MainTimer - Is Initial Run or Timer is already running. No need to proceed.", 0) ; #DEBUG_LINE_NO:106
      Return  ; #DEBUG_LINE_NO:107
    EndIf
    Bool restartTimer = False ; #DEBUG_LINE_NO:110
    Guard _mainTimerGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:111
      _mainTimerStarted = True ; #DEBUG_LINE_NO:112
      restartTimer = Self._Main() ; #DEBUG_LINE_NO:114
      _mainTimerStarted = False ; #DEBUG_LINE_NO:115
    EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
    If restartTimer ; #DEBUG_LINE_NO:118
      Self.StartTimer(_timerInterval, _timerIds.MainId) ; #DEBUG_LINE_NO:119
    EndIf
  EndIf
EndEvent

Bool Function Initialize()
  If !_isInitialized ; #DEBUG_LINE_NO:131
    _isInitialized = Self._SetSystemUtilities() ; #DEBUG_LINE_NO:132
  EndIf
  Return _isInitialized ; #DEBUG_LINE_NO:135
EndFunction

Function WaitForInitialized()
  If _isInitialized ; #DEBUG_LINE_NO:139
    Return  ; #DEBUG_LINE_NO:140
  EndIf
  Int currentCycle = 0 ; #DEBUG_LINE_NO:143
  Int maxCycle = 600 ; #DEBUG_LINE_NO:144
  Bool maxCycleHit = False ; #DEBUG_LINE_NO:145
  While !maxCycleHit && !_isInitialized ; #DEBUG_LINE_NO:148
    Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:149
    If currentCycle < maxCycle ; #DEBUG_LINE_NO:151
      currentCycle += 1 ; #DEBUG_LINE_NO:152
    Else
      maxCycleHit = True ; #DEBUG_LINE_NO:154
    EndIf
  EndWhile
EndFunction

Bool Function _SetSystemUtilities()
  SystemUtilities.WaitForInitialized() ; #DEBUG_LINE_NO:160
  Return True ; #DEBUG_LINE_NO:161
EndFunction

Bool Function _Main()
  Return False ; #DEBUG_LINE_NO:168
EndFunction
