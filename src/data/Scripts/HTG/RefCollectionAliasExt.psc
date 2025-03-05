ScriptName HTG:RefCollectionAliasExt Extends RefCollectionAlias

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

Event HTG:RefCollectionAliasExt.OnInitialRun(HTG:RefCollectionAliasExt akSender, Var[] akArgs)
  ; Empty function
EndEvent

Event HTG:RefCollectionAliasExt.OnMain(HTG:RefCollectionAliasExt akSender, Var[] akArgs)
  ; Empty function
EndEvent

Function _InitialRun()
  ; Empty function
EndFunction

Event OnInit()
  Self.RegisterForCustomEvent(Self as ScriptObject, "htg:refcollectionaliasext_OnInitialRun") ; #DEBUG_LINE_NO:43
  Self.RegisterForCustomEvent(Self as ScriptObject, "htg:refcollectionaliasext_OnMain") ; #DEBUG_LINE_NO:44
  _isInitialRun = !_isInitialized ; #DEBUG_LINE_NO:45
  _timerIds = new htg:structs:systemtimerids ; #DEBUG_LINE_NO:46
  Self.StartTimer(_timerInterval, _timerIds.InitializeId) ; #DEBUG_LINE_NO:47
EndEvent

Event OnAliasInit()
  Self.WaitForInitialized() ; #DEBUG_LINE_NO:51
EndEvent

Event OnAliasChanged(ObjectReference akObject, Bool abRemove)
  Self.WaitForInitialized() ; #DEBUG_LINE_NO:55
EndEvent

Event OnAliasStarted()
  Self.StartTimer(_timerInterval, _timerIds.InitialRunId) ; #DEBUG_LINE_NO:59
EndEvent

Event OnTimer(Int aiTimerID)
  Int I = 0 ; #DEBUG_LINE_NO:63
  Int count = 0 ; #DEBUG_LINE_NO:64
  If aiTimerID == _timerIds.InitializeId ; #DEBUG_LINE_NO:66
    If _isInitialized || !_isInitialRun || _initializeTimerStarted ; #DEBUG_LINE_NO:67
      htg:systemlogger.LogObjectGlobal(Self as ScriptObject, "InitializeTimer - Is Not Initial Run or Timer is already running. No need to proceed.") ; #DEBUG_LINE_NO:68
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
        Return  ; #DEBUG_LINE_NO:82
      EndIf
      _initializeTimerStarted = False ; #DEBUG_LINE_NO:87
    EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
    If timerId > -1 ; #DEBUG_LINE_NO:90
      Self.StartTimer(itimerInterval, timerId) ; #DEBUG_LINE_NO:91
    EndIf
  ElseIf aiTimerID == _timerIds.InitialRunId ; #DEBUG_LINE_NO:93
    If !_isInitialized || !_isInitialRun || _readyTimerStarted ; #DEBUG_LINE_NO:94
      Self.Logger.Log("ReadyTimer - Is Not Initial Run or Timer is already running. No need to proceed.", 0) ; #DEBUG_LINE_NO:95
      Return  ; #DEBUG_LINE_NO:96
    EndIf
    Guard _readyTimerGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:99
      _readyTimerStarted = True ; #DEBUG_LINE_NO:100
      Self.SendCustomEvent("htg:refcollectionaliasext_OnInitialRun", None) ; #DEBUG_LINE_NO:101
      Self._InitialRun() ; #DEBUG_LINE_NO:102
      _isInitialRun = False ; #DEBUG_LINE_NO:103
      _readyTimerStarted = False ; #DEBUG_LINE_NO:104
    EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
    Self.Logger.Log("ReadyTimer - Completed Initial Run.", 0) ; #DEBUG_LINE_NO:107
    Self.StartTimer(_timerInterval, _timerIds.MainId) ; #DEBUG_LINE_NO:108
  ElseIf aiTimerID == _timerIds.MainId ; #DEBUG_LINE_NO:109
    If !_isInitialized || _isInitialRun || _mainTimerStarted ; #DEBUG_LINE_NO:110
      Self.Logger.Log("MainTimer - Is Initial Run or Timer is already running. No need to proceed.", 0) ; #DEBUG_LINE_NO:111
      Return  ; #DEBUG_LINE_NO:112
    EndIf
    Int kMaxStarWait = SystemUtilities.Timers.WaitDefaults.MaxCycles ; #DEBUG_LINE_NO:115
    Bool kShouldWait = Self.GetOwningQuest().IsStarting() || Self.GetOwningQuest().IsRunning() ; #DEBUG_LINE_NO:116
    While kShouldWait
      Utility.WaitMenuPause(SystemUtilities.Timers.WaitDefaults.Time) ; #DEBUG_LINE_NO:118
      If I <= kMaxStarWait ; #DEBUG_LINE_NO:119
        I += 1 ; #DEBUG_LINE_NO:120
        kShouldWait = Self.GetOwningQuest().IsStarting() || Self.GetOwningQuest().IsRunning() ; #DEBUG_LINE_NO:121
      Else
        kShouldWait = False ; #DEBUG_LINE_NO:123
      EndIf
    EndWhile
    Bool restartTimer = False ; #DEBUG_LINE_NO:127
    Guard _mainTimerGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:128
      _mainTimerStarted = True ; #DEBUG_LINE_NO:129
      Self.SendCustomEvent("htg:refcollectionaliasext_OnMain", None) ; #DEBUG_LINE_NO:130
      restartTimer = Self._Main() ; #DEBUG_LINE_NO:131
      _mainTimerStarted = False ; #DEBUG_LINE_NO:132
    EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
    If restartTimer ; #DEBUG_LINE_NO:135
      Self.StartTimer(_timerInterval, _timerIds.MainId) ; #DEBUG_LINE_NO:136
    EndIf
  EndIf
EndEvent

Bool Function Initialize()
  If !_isInitialized ; #DEBUG_LINE_NO:148
    _isInitialized = Self._SetSystemUtilities() ; #DEBUG_LINE_NO:149
  EndIf
  Return _isInitialized ; #DEBUG_LINE_NO:152
EndFunction

Function WaitForInitialized()
  If _isInitialized ; #DEBUG_LINE_NO:156
    Return  ; #DEBUG_LINE_NO:157
  EndIf
  Int currentCycle = 0 ; #DEBUG_LINE_NO:160
  Int maxCycle = 600 ; #DEBUG_LINE_NO:161
  Bool maxCycleHit = False ; #DEBUG_LINE_NO:162
  While !maxCycleHit && !_isInitialized ; #DEBUG_LINE_NO:165
    Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:166
    If currentCycle < maxCycle ; #DEBUG_LINE_NO:168
      currentCycle += 1 ; #DEBUG_LINE_NO:169
    Else
      maxCycleHit = True ; #DEBUG_LINE_NO:171
    EndIf
  EndWhile
EndFunction

Bool Function _SetSystemUtilities()
  SystemUtilities.WaitForInitialized() ; #DEBUG_LINE_NO:177
  Return True ; #DEBUG_LINE_NO:178
EndFunction

Bool Function _Main()
  Return False ; #DEBUG_LINE_NO:185
EndFunction
