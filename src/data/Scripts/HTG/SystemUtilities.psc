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

SystemStageIds Property Stages Hidden
    SystemStageIds Function Get()
        If IsFilled()
            return (GetReference() as SystemUtilitiesObject).Stages
        EndIf

        return None
    EndFunction
EndProperty

SystemMenuIds Property Menus Hidden
    SystemMenuIds Function Get()
        If IsFilled()
            return (GetReference() as SystemUtilitiesObject).Menus
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

; Int Property ModInfoAliasId Auto Hidden

HTG:Quests:ModuleInformation Property ModInfoAlias Mandatory Const Auto

HTG:SystemModuleInformation Property ModInfo Hidden
    HTG:SystemModuleInformation Function Get()
        If ModInfoAlias.IsFilled()
            return ModInfoAlias.GetReference() as HTG:SystemModuleInformation
        Else
            return _modInfo
        EndIf
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
        return IsFilled() && (GetReference() as SystemUtilitiesObject).IsDebugging   
    EndFunction
EndProperty

SystemModuleInformation _modInfo
SystemTimerIds _timerIds
HTG:SystemLogger _logger
; Utilities _utilities
; TimerUtility _timerUtility
; IntUtility _intUtility
; FormUtility _formUtility
; ArmorUtility _armorUtility
Guard _initializeTimerGuard ProtectsFunctionLogic
Guard _initializeGuard ProtectsFunctionLogic
; Guard _utilitiesGuard ProtectsFunctionLogic
Bool _isInitialized
Bool _initializeTimerStarted
Int _initializeTimerId = 1
Float _timerInternal = 0.05
Int _maxTimerCycle = 600
Int _currentTimerCycle = 0

Event OnInit()
    StartTimer(_timerInternal, _initializeTimerId)
EndEvent

Event OnTimer(Int aiTimerID)
    If aiTimerID == _initializeTimerId
        If _isInitialized || _initializeTimerStarted
            LogObjectGlobal(Self, "InitializeTimer - Timer is already running. No need to proceed.")
            return
        EndIf

        Bool bRestartTimer
        TryLockGuard _initializeTimerGuard, _initializeGuard
            If !Initialize() &&  _currentTimerCycle < _maxTimerCycle    
                WaitExt(0.15)        
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
    TryLockGuard _initializeGuard
        ;ScriptObject so = Self as ScriptObject 
        ;LogObjectGlobal(Self, "HTG:SystemUtilities:" + Self + "\n\t As ScriptObject:" + so)

        _isInitialized = _SetSystemUtilities()
    Else
        StartTimer(0.1, _initializeTimerId)
        ; WaitExt(0.25)
    EndTryLockGuard

    return _CheckSystemUtilites()
EndFunction

Bool Function _SetSystemUtilities()
    If !IsFilled()
        return False
    EndIf

    Bool res = True
    SystemUtilitiesObject kUtils        
    kUtils = GetReference() as SystemUtilitiesObject
    kUtils.WaitForInitialized()

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

    ; If IsNone(_modInfo)
    ;     SystemModuleInformation kMod
    ;     If ModInfoAliasId < 0
    ;         HTG:Quests:ModuleInformation kAlias = GetOwningQuest().GetAlias(ModInfoAliasId) as HTG:Quests:ModuleInformation
    ;         If !IsNone(kAlias) 
    ;             If kAlias.IsFilled()
    ;                 kMod = kAlias.GetReference() as HTG:SystemModuleInformation
    ;                 If !IsNone(kMod)
    ;                     _modInfo = kMod
    ;                 EndIf
    ;             ; Else
    ;             ;     kAlias.RefillAlias()
    ;             EndIf
    ;         EndIf
    ;     EndIf

    ;     If IsNone(_modInfo)
    ;         Int i
    ;         Int kMaxIndex = 100
    ;         While i <= kMaxIndex
    ;             ReferenceAlias kRefAlias = GetOwningQuest().GetAlias(i) as ReferenceAlias
    ;             If !IsNone(kRefAlias) \
    ;                 && kRefAlias is HTG:Quests:ModuleInformation
    ;                 ModInfoAliasId = i     
    ;                 i = kMaxIndex + 1

    ;                 HTG:Quests:ModuleInformation kAlias = kRefAlias as HTG:Quests:ModuleInformation
    ;                 If kAlias.IsFilled()
    ;                     kMod = kAlias.GetReference() as SystemModuleInformation
    ;                     If !IsNone(kMod)
    ;                         _modInfo = kMod                            
    ;                     EndIf
    ;                 EndIf
    ;             Else
    ;                 i += 1
    ;             EndIf
    ;         EndWhile
    ;     EndIf
    ; EndIf

    If IsNone(_modInfo)
        If !IsNone(ModInfoAlias) && !IsNone(ModInfoAlias.ModInfoForm)
                _modInfo = HTG:FormUtility.CreateReference(GetReference(), ModInfoAlias.ModInfoForm) as SystemModuleInformation
                ModInfoAlias.ForceRefTo(_modInfo)
            ; EndIf
        Else
            _modInfo = ModInfoAlias.GetReference() as SystemModuleInformation
        EndIf

        If !IsNone(_modInfo)
            Cell kCell = _modInfo.GetParentCell()
            Logger.Log("Utilities current cell" + kUtils.GetParentCell())
            Logger.Log("Mods current cell" + kCell)

            ; _modInfo.MoveTo(kUtils)
        EndIf
    EndIf

    return !IsNone(_logger) \
            && !IsNone(_modInfo) \
            && kUtils.IsInitialized
EndFunction

Bool Function _CheckSystemUtilites()
    If !IsFilled()
        return False
    EndIf

    Bool res = True
    SystemUtilitiesObject kUtils
    ; TryLockGuard _utilitiesGuard         
    kUtils = GetReference() as SystemUtilitiesObject
    If IsNone(_logger)
        LogWarnGlobal(Self, "Logger is None.")
    ElseIf IsNone(_modInfo)        
        LogWarnGlobal(Self, "ModuleInformation is None.")
    ElseIf !kUtils.IsInitialized
        LogWarnGlobal(Self, "SystemUtilityObject is not initialized.")
    EndIf
    ; EndTryLockGuard

    return !IsNone(_logger) \
            && !IsNone(_modInfo) \
            && (IsFilled() && kUtils.IsInitialized)
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
    ; TryLockGuard _initializeTimerGuard, _utilitiesGuard
    While !maxCycleHit
        WaitExt(0.1)
        If !Initialize() && currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile
    ; EndTryLockGuard

    If !_isInitialized && !_initializeTimerStarted
        StartTimer(_timerInternal, _initializeTimerId)
    EndIf
    
    return _isInitialized
EndFunction