Scriptname HTG:SystemUtilities extends ReferenceAlias Hidden
import HTG
import HTG:Collections
import HTG:SystemLogger
import HTG:Structs
import HTG:UtilityExt

; Struct Utilities
;     IntUtility Integers
;     FormUtility Forms
;     ArmorUtility Armors
; EndStruct

Guard _loggerGuard ProtectsFunctionLogic

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

GlobalVariable Property DebugGlobal Mandatory Const Auto

Form Property ModInfoForm Mandatory Const Auto

ModInformation Property ModInfo Hidden
    HTG:ModInformation Function Get()
        return _modInfo
    EndFunction
EndProperty

; ObjectReference Property TempContainer Mandatory Const Auto

; Utilities Property Utilities Hidden 
;     Utilities Function Get()
;         return _utilities
;     EndFunction
; EndProperty

Bool Property IsInitialized Hidden
    Bool Function Get()
        return _isInitialized
    EndFunction
EndProperty

Bool Property IsDebugging Hidden
    Bool Function Get()
        return DebugGlobal.GetValueInt() == 8    
    EndFunction
EndProperty

ModInformation _modInfo
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
Float _timerInternal = 0.05
Int _maxTimerCycle = 600
Int _currentTimerCycle = 0

Event OnAliasInit()
    StartTimer(_timerInternal, _initializeTimerId)
EndEvent

Event OnTimer(Int aiTimerID)
    If aiTimerID == _initializeTimerId
        If _isInitialized || _initializeTimerStarted
            LogObjectGlobal(Self, "InitializeTimer - Timer is already running. No need to proceed.")
            return
        EndIf

        Bool bRestartTimer
        TryLockGuard _initializeTimerGuard, _utilitiesGuard
            If !Initialize() &&  _currentTimerCycle < _maxTimerCycle    
                WaitExt(0.1)        
                _currentTimerCycle += 1
                bRestartTimer = True
            ElseIf _currentTimerCycle == _maxTimerCycle
                LogErrorGlobal(Self, "HTG:SystemUtililities could not be Initialized")
            EndIf
        EndTryLockGuard
        
        If bRestartTimer
            StartTimer(_timerInternal, _initializeTimerId)
        EndIf
    EndIf
EndEvent

Bool Function Initialize()
    If _isInitialized
        return True
    EndIf

    ; TryLockGuard _utilitiesGuard
        ScriptObject so = Self as ScriptObject 
        LogObjectGlobal(Self, "HTG:SystemUtilities:" + Self + "\n\t As ScriptObject:" + so)

        _isInitialized = _SetSystemUtilities(so)
    ; EndTryLockGuard

    return _CheckSystemUtilites()
EndFunction

Bool Function _SetSystemUtilities(ScriptObject akScriptObject)
    If akScriptObject == None
        LogErrorGlobal(Self, "The object attached to  this Script is not a ScriptObject:" + Self)
        return False
    EndIf

    Bool res = True
    ; If _utilities == None
    ;     _utilities = new Utilities
    ; EndIf
    ; LogObjectGlobal(Self, "Utilities:" + _utilities)

    TryLockGuard _utilitiesGuard
        If IsNone(_logger)
            _logger = akScriptObject as HTG:SystemLogger
        EndIf

        If IsNone(_timerUtility)
            _timerUtility = akScriptObject as TimerUtility
            LogObjectGlobal(Self, "Timer:" + _timerUtility)
        EndIf

        If IsNone(_intUtility)
            _intUtility = akScriptObject as IntUtility
            LogObjectGlobal(Self, "Integers:" + _intUtility)
        EndIf

        If IsNone(_formUtility)
            _formUtility = akScriptObject as FormUtility
            LogObjectGlobal(Self, "Utilities.Forms:" + _formUtility)
        EndIf

        If IsNone(_armorUtility)
            _armorUtility = akScriptObject as ArmorUtility
            LogObjectGlobal(Self, "Utilities.Armors:" + _armorUtility)
        EndIf

        If IsNone(_modInfo) && ModInfoForm != None
            _modInfo = HTG:FormUtility.CreateReference(Game.GetPlayer(), ModInfoForm) as ModInformation
        EndIf
    EndTryLockGuard

    return !IsNone(_logger) && \
            !IsNone(_timerUtility) && \
            !IsNone(_intUtility) && \
            !IsNone(_formUtility) && \
            !IsNone(_armorUtility)
EndFunction

Bool Function _CheckSystemUtilites()
    Bool res
    ; If _utilities == None
    ;     LogErrorGlobal(Self, "Utilities is None.")
    ;     return False
    ; EndIf

    If IsNone(_logger)
        LogWarnGlobal(Self, "Logger is None.")
    ElseIf IsNone(_timerUtility)
        LogWarnGlobal(Self, "Timers is None.")
    ElseIf IsNone(_intUtility)
        LogWarnGlobal(Self, "Integers is None.")
    ElseIf IsNone(_formUtility)        
        LogWarnGlobal(Self, "Forms is None.")
    ElseIf IsNone(_armorUtility)        
        LogWarnGlobal(Self, "Armors is None.")
    Else
        res = True
    EndIf

    return !IsNone(_logger) && \
            !IsNone(_timerUtility) && \
            !IsNone(_intUtility) && \
            !IsNone(_formUtility) && \
            !IsNone(_armorUtility)
EndFunction

Bool Function WaitForInitialized()
    If _isInitialized
        return True
    EndIf
    
    Int currentCycle = 0
    Int maxCycle = 600
    Bool maxCycleHit
    While !maxCycleHit && !_isInitialized
        WaitExt(0.1)

        If currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile

    If !_isInitialized && !_initializeTimerStarted
        StartTimer(_timerInternal, _initializeTimerId)
    EndIf
    
    return _isInitialized
EndFunction