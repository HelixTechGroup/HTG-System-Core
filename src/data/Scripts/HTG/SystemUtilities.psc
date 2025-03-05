Scriptname HTG:SystemUtilities extends ReferenceAlias Hidden
import HTG
import HTG:Collections
import HTG:SystemLogger
import HTG:Structs

; Struct Utilities
;     IntUtility Integers
;     FormUtility Forms
;     ArmorUtility Armors
; EndStruct

HTG:SystemLogger Property Logger Hidden
    HTG:SystemLogger Function Get()
        return _logger
    EndFunction
EndProperty

TimerUtility Property Timers Hidden
    TimerUtility Function Get()
        return _timerUtility
    EndFunction
EndProperty

IntUtility Property Integers Hidden
    IntUtility Function Get()
        return _intUtility
    EndFunction
EndProperty

FormUtility Property Forms Hidden
    FormUtility Function Get()
        return _formUtility
    EndFunction
EndProperty

ArmorUtility Property Armors Hidden
    ArmorUtility Function Get()
        return _armorUtility
    EndFunction
EndProperty

; Utilities Property Utilities Hidden 
;     Utilities Function Get()
;         return _utilities
;     EndFunction
; EndProperty

Bool Property IsInitialized Hidden
    Bool Function Get()
        return _logger != None \ 
        && _timerUtility  != None \
        && _intUtility != None \
        && _formUtility != None \
        && _armorUtility != None
    EndFunction
EndProperty

SystemTimerIds _timerIds
HTG:SystemLogger _logger
; Utilities _utilities
TimerUtility _timerUtility
IntUtility _intUtility
FormUtility _formUtility
ArmorUtility _armorUtility
Guard _initializeTimerGuard ProtectsFunctionLogic
Guard _utilitiesGuard ProtectsFunctionLogic
Bool _isInitialized
Bool _initializeTimerStarted
Int _initializeTimerId = 1
Float _timerInternal = 0.01
Int _maxTimerCycle = 50
Int _currentTimerCycle = 0

Event OnInit()
    StartTimer(_timerInternal, _initializeTimerId)
EndEvent

Bool Function Initialize()
    If IsInitialized
        return True
    EndIf

    ; TryLockGuard _utilitiesGuard
    ScriptObject so = Self as ScriptObject 
    LogObjectGlobal(Self, "HTG:SystemUtilities:" + Self + "\n\t As ScriptObject:" + so)

    _SetSystemUtilities(so)
    ; EndTryLockGuard

    return _CheckSystemUtilites()
EndFunction

Function _SetSystemUtilities(ScriptObject akScriptObject)
    If akScriptObject == None
        LogErrorGlobal(Self, "The object attached to  this Script is not a ScriptObject:" + Self)
        return
    EndIf

    ; If _utilities == None
    ;     _utilities = new Utilities
    ; EndIf
    ; LogObjectGlobal(Self, "Utilities:" + _utilities)

    IF _logger == None
        _logger = akScriptObject as HTG:SystemLogger
    EndIf

    If _timerUtility == None
        _timerUtility = akScriptObject as TimerUtility
        LogObjectGlobal(Self, "Timer:" + _timerUtility)
    EndIf

    If _intUtility == None
        _intUtility = akScriptObject as IntUtility
        LogObjectGlobal(Self, "Integers:" + _intUtility)
    EndIf

    If _formUtility == None
        _formUtility = akScriptObject as FormUtility
        LogObjectGlobal(Self, "Utilities.Forms:" + _formUtility)
    EndIf

    If _armorUtility == None
        _armorUtility = akScriptObject as ArmorUtility
        LogObjectGlobal(Self, "Utilities.Armors:" + _armorUtility)
    EndIf
EndFunction

Bool Function _CheckSystemUtilites()
    Bool res
    ; If _utilities == None
    ;     LogErrorGlobal(Self, "Utilities is None.")
    ;     return False
    ; EndIf

    If _logger == None
        LogWarnGlobal(Self, "Logger is None.")
    ElseIf _timerUtility == None
        LogWarnGlobal(Self, "Timers is None.")
    ElseIf _intUtility == None
        LogWarnGlobal(Self, "Integers is None.")
    ElseIf _formUtility == None        
        LogWarnGlobal(Self, "Forms is None.")
    ElseIf _armorUtility == None        
        LogWarnGlobal(Self, "Armors is None.")
    Else
        res = True
    EndIf

    return IsInitialized
EndFunction

Event OnTimer(Int aiTimerID)
    If aiTimerID == _initializeTimerId
        If !Initialize() &&  _currentTimerCycle < _maxTimerCycle            
            _currentTimerCycle += 1
            StartTimer(_timerInternal, _initializeTimerId)
        ElseIf _currentTimerCycle == _maxTimerCycle
            LogErrorGlobal(Self, "HTG:SystemUtililities could not be Initialized")
        EndIf
    EndIf
EndEvent

Function WaitForInitialized()
    If IsInitialized
        return
    EndIf
    
    Int currentCycle = 0
    Int maxCycle = 600
    Bool maxCycleHit
    While !maxCycleHit && !IsInitialized
        Utility.Wait(0.1)

        If currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile
EndFunction