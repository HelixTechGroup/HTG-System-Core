Scriptname HTG:SystemUtilities extends ReferenceAlias Hidden
import HTG
import HTG:Collections
import HTG:SystemLogger
import HTG:Structs
import HTG:UtilityExt
import HTG:Quests

HTG:SystemLogger Property Logger Hidden
    HTG:SystemLogger Function Get()
        return _logger
    EndFunction
EndProperty

TimerUtility Property Timers Hidden
    TimerUtility Function Get()
        If IsFilled()
            return (GetReference() as SystemUtilitiesObject).Timers
        EndIf

        return None
    EndFunction
EndProperty

IntUtility Property Integers Hidden
    IntUtility Function Get()
        If IsFilled()
            return (GetReference() as SystemUtilitiesObject).Integers
        EndIf

        return None
    EndFunction
EndProperty

FormUtility Property Forms Hidden
    FormUtility Function Get()
        If IsFilled()
            return (GetReference() as SystemUtilitiesObject).Forms
        EndIf

        return None
    EndFunction
EndProperty

ArmorUtility Property Armors Hidden
    ArmorUtility Function Get()
        If IsFilled()
            return (GetReference() as SystemUtilitiesObject).Armors
        EndIf

        return None
    EndFunction
EndProperty

; GlobalVariable Property DebugGlobal Mandatory Const Auto

; Form Property ModInfoForm Const Auto

Int Property ModInfoAliasId Auto Hidden

SystemModuleInformation Property ModInfo Hidden
    SystemModuleInformation Function Get()
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
        return IsFilled() && (GetReference() as SystemUtilitiesObject).IsInitialized
    EndFunction
EndProperty

Bool Property IsDebugging Hidden
    Bool Function Get()
        return IsFilled() && (GetReference() as SystemUtilitiesObject).IsDebugging   
    EndFunction
EndProperty

SystemModuleInformation _modInfo
; SystemTimerIds _timerIds
HTG:SystemLogger _logger
; Utilities _utilities
; TimerUtility _timerUtility
; IntUtility _intUtility
; FormUtility _formUtility
; ArmorUtility _armorUtility
Guard _initializeTimerGuard ProtectsFunctionLogic
Guard _utilitiesGuard ProtectsFunctionLogic
Bool _isInitialized
Bool _initializeTimerStarted
Int _initializeTimerId = 1
Float _timerInternal = 0.05
Int _maxTimerCycle = 600
Int _currentTimerCycle = 0

Event OnAliasInit()
    (GetReference() as SystemUtilitiesObject).WaitForInitialized()
    _SetSystemUtilities()    
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

    ; TODO: Change self to GetReference() and attach scripts to _systemUtilitiesObject
    ; TryLockGuard _utilitiesGuard
        ScriptObject so = Self as ScriptObject 
        LogObjectGlobal(Self, "HTG:SystemUtilities:" + Self + "\n\t As ScriptObject:" + so)

        _isInitialized = _SetSystemUtilities()
    ; EndTryLockGuard

    return _CheckSystemUtilites()
EndFunction

Bool Function _SetSystemUtilities()
    Bool res = True
    TryLockGuard _utilitiesGuard
        If IsFilled()
            res = (GetReference() as SystemUtilitiesObject).WaitForInitialized()
        EndIf

        If IsNone(_logger)
            HTG:SystemLogger kLogger = (Self as ReferenceAlias) as HTG:SystemLogger
            If IsNone(kLogger)
                ; kLogger = (GetReference() as SystemUtilitiesObject).Logger
                ; If IsNone(kLogger)
                    LogErrorGlobal(Self, "Unable to get System Logger.")
                ; EndIf
            EndIf
            _logger = kLogger
        EndIf

        If IsNone(_modInfo)
            SystemModuleInformation kMod
            If ModInfoAliasId < 0
                HTG:Quests:ModuleInformation kAlias = GetOwningQuest().GetAlias(ModInfoAliasId) as HTG:Quests:ModuleInformation
                If !IsNone(kAlias) 
                    If kAlias.IsFilled()
                        kMod = kAlias.GetReference() as HTG:SystemModuleInformation
                        If !IsNone(kMod)
                            _modInfo = kMod
                        EndIf
                    ; Else
                    ;     kAlias.RefillAlias()
                    EndIf
                EndIf
            EndIf

            If IsNone(_modInfo)
                Int i
                Int kMaxIndex = 100
                While i <= kMaxIndex
                    ReferenceAlias kRefAlias = GetOwningQuest().GetAlias(i) as ReferenceAlias
                    If !IsNone(kRefAlias) \
                        && kRefAlias is HTG:Quests:ModuleInformation
                        ModInfoAliasId = i     
                        i = kMaxIndex + 1

                        HTG:Quests:ModuleInformation kAlias = kRefAlias as HTG:Quests:ModuleInformation
                        If kAlias.IsFilled()
                            kMod = kAlias.GetReference() as SystemModuleInformation
                            If !IsNone(kMod)
                                _modInfo = kMod                            
                            EndIf
                        EndIf
                    Else
                        i += 1
                    EndIf
                EndWhile

                ; If IsNone(_modInfo) ; && ModInfoForm != None
                ;     ; _modInfo = HTG:FormUtility.CreateReference(Game.GetPlayer(), ModInfoForm) as SystemModuleInformation
                ;     _modInfo = (GetReference() as SystemUtilitiesObject).ModInfo
                ; EndIf
            EndIf
        EndIf
    EndTryLockGuard

    return !IsNone(_logger) \
            && !IsNone(_modInfo) \
            && (IsFilled() && (GetReference() as SystemUtilitiesObject).IsInitialized)
EndFunction

Bool Function _CheckSystemUtilites()
    Bool res
    If IsNone(_logger)
        LogWarnGlobal(Self, "Logger is None.")
    ElseIf IsNone(_modInfo)        
        LogWarnGlobal(Self, "ModuleInformation is None.")
    Else
        res = True
    EndIf

    return !IsNone(_logger) \
            && !IsNone(_modInfo) \
            && (IsFilled() && (GetReference() as SystemUtilitiesObject).IsInitialized)
EndFunction

Bool Function WaitForInitialized()
    If _isInitialized
        return True
    EndIf
    
    If (!IsFilled() \
        || !(GetReference() as SystemUtilitiesObject).WaitForInitialized())
        return False
    EndIf

    Int currentCycle = 0
    Int maxCycle = 150
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