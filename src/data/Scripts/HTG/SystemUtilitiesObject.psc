Scriptname HTG:SystemUtilitiesObject extends ObjectReference Hidden
import HTG
import HTG:Collections
import HTG:SystemLogger
import HTG:Structs
import HTG:UtilityExt
import HTG:Quests
import Utility

; Struct Utilities
;     SystemIntUtility Integers
;     SystemFormUtility Forms
;     SystemArmorUtility Armors
; EndStruct

; HTG:SystemLogger Property Logger Hidden
;     HTG:SystemLogger Function Get()
;         return _logger
;     EndFunction
; EndProperty

SystemTimerUtility Property Timers Hidden
    SystemTimerUtility Function Get()
        return _timerUtility
    EndFunction
EndProperty

SystemStageIds Property Stages Hidden
    SystemStageIds Function Get()
        return _stageIds
    EndFunction
EndProperty

SystemMenuIds Property Menus Hidden
    SystemMenuIds Function Get()
        return _menuIds
    EndFunction
EndProperty

SystemIntUtility Property Integers Hidden
    SystemIntUtility Function Get()
        return _intUtility
    EndFunction
EndProperty

SystemFormUtility Property Forms Hidden
    SystemFormUtility Function Get()
        return _formUtility
    EndFunction
EndProperty

SystemArmorUtility Property Armors Hidden
    SystemArmorUtility Function Get()
        return _armorUtility
    EndFunction
EndProperty

GlobalVariable Property DebugGlobal Mandatory Const Auto
Cell Property SystemData Mandatory Const Auto
Quest Property MQ101 Mandatory Const Auto
Quest Property City_NA_Aquilus01 Mandatory Const Auto
ActorValue Property PlayerUnityTimesEntered Mandatory Const Auto
SQ_SystemController Property SystemController Mandatory Const Auto
ActorValue Property HoursPlayedPreUnity Mandatory Const Auto    
; ModuleTracker Property Modules Mandatory Const Auto
; DependencyTracker Property Dependencies Mandatory Const Auto
; ObjectReference Property TempContainer Mandatory Const Auto

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

; Is a new game or player has just started a ng+ playthrough
Bool Property IsNewGame Hidden
    Bool Function Get()
        return _isNewGame
    EndFunction
EndProperty

; Player has entered Unity at least once.
Bool Property IsNewGamePlus Hidden
    Bool Function Get()
        return _isNewGamePlus
    EndFunction
EndProperty

Guard _loggerGuard ProtectsFunctionLogic
Guard _initializeTimerGuard ProtectsFunctionLogic
Guard _initializeGuard ProtectsFunctionLogic
; Guard _utilitiesGuard ProtectsFunctionLogic
; SystemModuleInformation _modInfo
SystemTimerIds _timerIds
SystemStageIds _stageIds
SystemMenuIds _menuIds
; HTG:SystemLogger _logger
; Utilities _utilities
SystemTimerUtility _timerUtility
SystemIntUtility _intUtility
SystemFormUtility _formUtility
SystemArmorUtility _armorUtility
Bool _isInitialized
Bool _initializeTimerStarted
Int _initializeTimerId = 1
Float _timerInternal = 0.05
Int _maxTimerCycle = 600
Int _currentTimerCycle = 0
Bool _isNewGame
Bool _isNewGamePlus
Float _realMin = 0.016

Event OnInit()
    ; _timerIds = new SystemTimerIds
    ; _stageIds = new SystemStageIds
    ; _menuIds = new SystemMenuIds
    ; _isNewGame = True
    _DetectNewGame()
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
        Else
            bRestartTimer = True
        EndTryLockGuard

        If bRestartTimer
            StartTimer(_timerInternal, _initializeTimerId)
        EndIf
    EndIf
EndEvent

Event Quest.OnStageSet(Quest akSender, int auiStageID, int auiItemID)
    If akSender == MQ101 && auiStageID == 2000
        _isNewGamePlus = True
        _isNewGame = True
    EndIf
EndEvent

Bool Function Initialize()
    If _isInitialized
        return True
    EndIf

    TryLockGuard _initializeGuard
        ScriptObject so = Self as ScriptObject
        LogObjectGlobal(Self, "HTG:SystemUtilities:" + Self + "\n\t As ScriptObject:" + so)
        If _SetSystemUtilities(so)
            _isInitialized = _RegisterEvents() \
                            && _CreateCollections()
        EndIf
    Else
        return False ; StartTimer(0.1, _timerIds.InitializeId)
    EndTryLockGuard

    return _isInitialized && _CheckSystemUtilites()
EndFunction

Bool Function WaitForInitialized()
    If _isInitialized
        return True
    EndIf

    Int currentCycle = 0
    Int maxCycle = 600
    Bool maxCycleHit
    While !Initialize() || maxCycleHit
        WaitExt(0.1)
        ; !Initialize() &&
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

Bool Function _SetSystemUtilities(ScriptObject akScriptObject) RequiresGuard(_initializeGuard)
    If akScriptObject == None
        LogErrorGlobal(Self, "The object attached to  this Script is not a ScriptObject:" + Self)
        return False
    EndIf

    Bool res = True

    ; TryLockGuard _utilitiesGuard
        ; If IsNone(_logger)
        ;     _logger = akScriptObject as HTG:SystemLogger
        ; EndIf

        If IsNone(_timerUtility)
            _timerUtility = akScriptObject as SystemTimerUtility
            LogObjectGlobal(Self, "Timer:" + _timerUtility)
        EndIf

        If IsNone(_intUtility)
            _intUtility = akScriptObject as SystemIntUtility
            LogObjectGlobal(Self, "Integers:" + _intUtility)
        EndIf

        If IsNone(_formUtility)
            _formUtility = akScriptObject as SystemFormUtility
            LogObjectGlobal(Self, "Utilities.Forms:" + _formUtility)
        EndIf

        If IsNone(_armorUtility)
            _armorUtility = akScriptObject as SystemArmorUtility
            LogObjectGlobal(Self, "Utilities.Armors:" + _armorUtility)
        EndIf

        If _stageIds == None
            _stageIds = new SystemStageIds
            LogObjectGlobal(Self, "Utilities.Stages:" + _stageIds)
        EndIf

        If _menuIds == None
            _menuIds = new SystemMenuIds
            LogObjectGlobal(Self, "Utilities.Menus:" + _menuIds)
        EndIf

        If !IsNone(SystemController) \
            && !IsNone(SystemController.Modules) \
            && !SystemController.Modules.IsInitialized
            SystemController.Modules.WaitForInitialized()
        EndIf

        If !IsNone(SystemController) \
            && !IsNone(SystemController.Dependencies) \
            && !SystemController.Dependencies.IsInitialized
            SystemController.Dependencies.WaitForInitialized()
        EndIf

        If !IsNone(SystemController) \
            && !IsNone(SystemController.Messages) \
            && !SystemController.Messages.IsInitialized
            SystemController.Messages.WaitForInitialized()
        EndIf
        ; If IsNone(_modInfo) && ModInfoForm != None
        ;         _modInfo = HTG:SystemFormUtility.CreateReference(Self, ModInfoForm) as SystemModuleInformation
        ; EndIf
    ; EndTryLockGuard

    ; !IsNone(_logger) \

    return !IsNone(_timerUtility) \
            && !IsNone(_intUtility) \
            && !IsNone(_formUtility) \
            && !IsNone(_armorUtility)
EndFunction

Bool Function _CheckSystemUtilites()
    Bool res = true

    ; If _utilities == None
    ;     LogErrorGlobal(Self, "Utilities is None.")
    ;     return False
    ; EndIf

    ; If IsNone(_logger)
    ;     LogWarnGlobal(Self, "Logger is None.")
    ; EndIf

    If IsNone(_timerUtility)
        res = False
        LogWarnGlobal(Self, "Timers is None.")
    EndIf

    ; If _stageIds == None
    ;     LogWarnGlobal(Self, "Stages is None.")
    ; EndIf

    ; If _menuIds == None
    ;     LogWarnGlobal(Self, "Menus is None.")
    ; EndIf

    If IsNone(_intUtility)
        res = False
        LogWarnGlobal(Self, "Integers is None.")
    EndIf

    If IsNone(_formUtility)
        res = False
        LogWarnGlobal(Self, "Forms is None.")
    EndIf

    If IsNone(_armorUtility)
        res = False
        LogWarnGlobal(Self, "Armors is None.")
    EndIf

    If !IsNone(SystemController.Modules) && !SystemController.Modules.IsInitialized
        res = False
        LogWarnGlobal(Self, "Modules is None.")
    EndIf

    If !IsNone(SystemController.Dependencies) && !SystemController.Dependencies.IsInitialized
        res = False
        LogWarnGlobal(Self, "Dependencies is None.")
    EndIf

    If !IsNone(SystemController.Messages) && !SystemController.Messages.IsInitialized
        res = False
        LogWarnGlobal(Self, "Messages is None.")
    EndIf

    ; !IsNone(_logger) \
    ; return !IsNone(_timerUtility) \
    ;         && !IsNone(_intUtility) \
    ;         && !IsNone(_formUtility) \
    ;         && !IsNone(_armorUtility)

    return res
EndFunction

Bool Function _DetectNewGame()
    _isNewGame = False
    _isNewGamePlus = False
    Float kUnityRealHours = Game.GetPlayer().GetValue(HoursPlayedPreUnity) + _realMin
    Float kRealHours = Game.GetRealHoursPassed()
    If Game.GetPlayer().GetValue(PlayerUnityTimesEntered) > 0
        ; If City_NA_Aquilus01.IsCompleted()
        ;     _isNewGame = False
        ; EndIf
        _isNewGamePlus = True
    EndIf

    If kRealHours <= kUnityRealHours
        _isNewGame = true
    EndIf

    ; If (MQ101.GetStage() > 0) \
    ;         && !IsDebugging
    ;     _isNewGame = False
    ; ElseIf IsDebugging
        ;need to find a sane way to handle debugging.
    ; EndIf

    ; Wait(1.0)
    LogObjectGlobal(Self, "Is New Game: " + _isNewGame  + \
                        "\n\tIs NG+: " + _isNewGamePlus + \
                        "\n\tReal Hours" + kRealHours + \
                        "\n\tUnity Real Hours: " + kUnityRealHours)
    return _isNewGame
EndFunction

Bool Function _RegisterEvents()
    ; RegisterForCustomEvent(MQ101, "OnStageSet")
    return True
EndFunction

Bool Function _UnregisterEvents()
    ; UnregisterForCustomEvent(MQ101, "OnStageSet")
    return True
EndFunction

Bool Function _CreateCollections()
    return True
EndFunction