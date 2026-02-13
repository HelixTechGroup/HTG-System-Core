Scriptname HTG:Quests:ModuleInformation Extends ReferenceAlias
import HTG
import HTG:Structs
import HTG:UtilityExt
import HTG:SystemFormUtility
import HTG:SystemLogger
import HTG:SystemReferenceUtility

Form Property ModInfoForm Const Auto
ObjectReference Property ModuleSpawnPoint Const Auto

String Property Name Hidden
    String Function Get()
        return (GetReference() as SystemModuleInformation).Name
    EndFunction
EndProperty

String Property Description Hidden
    String Function Get()
        return (GetReference() as SystemModuleInformation).Description
    EndFunction
EndProperty

VersionInfomation Property Version Hidden
    VersionInfomation Function Get()
        return (GetReference() as SystemModuleInformation).Version
    EndFunction
EndProperty

Bool Property IsCoreIntegrated Hidden
    Bool Function Get()
        return (GetReference() as SystemModuleInformation).IsCoreIntegrated
    EndFunction
EndProperty

String Property FileName Hidden
    String Function Get()
        return (GetReference() as SystemModuleInformation).FileName
    EndFunction
EndProperty

FormList Property CollectionRegistry Hidden
    FormList Function Get()
        return (GetReference() as SystemModuleInformation).CollectionRegistry
    EndFunction
EndProperty

FormList Property ModuleRegistry Hidden
    FormList Function Get()
        return (GetReference() as SystemModuleInformation).ModuleRegistry
    EndFunction
EndProperty

FormList Property SystemRegistry Hidden
    FormList Function Get()
        return (GetReference() as SystemModuleInformation).SystemRegistry
    EndFunction
EndProperty

FormList Property LocalSystemRegistry Hidden
    FormList Function Get()
        return (GetReference() as SystemModuleInformation).LocalSystemRegistry
    EndFunction
EndProperty

Bool Property IsInitialized Hidden
    Bool Function Get()
        return _isInitialized
    EndFunction
EndProperty

Guard _initializeTimerGuard ProtectsFunctionLogic
Guard _initializeGuard ProtectsFunctionLogic
Bool _isInitialized
Bool _initializeTimerStarted
Int _initializeTimerId = 1
Float _timerInternal = 0.05
Int _maxTimerCycle = 600
Int _currentTimerCycle = 0

Guard _moduleGuard ProtectsFunctionLogic

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
            If !Initialize() \
                && _currentTimerCycle < _maxTimerCycle    
                WaitExt(0.01)        
                _currentTimerCycle += 1
                bRestartTimer = True
            ElseIf _currentTimerCycle == _maxTimerCycle
                _currentTimerCycle = 0
                ; bRestartTimer = True
            EndIf
        Else
            ; LogWarnGlobal(Self, "HTG:ModuleInformation could not be Initialized due to Guarding issue.")
            bRestartTimer = True
        EndTryLockGuard

        If bRestartTimer && !_isInitialized
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

        _isInitialized = _CreateModule()
    Else
        ; StartTimer(0.333, _initializeTimerId)
        ; WaitExt(0.25)
        return False
    EndTryLockGuard

    return IsFilled()
EndFunction

Bool Function WaitForInitialized()
    If IsInitialized
        return True
    EndIf
    
    Int currentCycle = 0
    Int maxCycle = 150
    Bool maxCycleHit

    ; StartTimer(_timerInterval, _initializeTimerId)

    While !maxCycleHit
        WaitExt(0.5)
        If !Initialize() && currentCycle <= maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile

    return IsInitialized
EndFunction

Bool Function _CreateModule()
    SystemModuleInformation kMod
    If !IsFilled()
        If !IsNone(ModInfoForm) 
            ObjectReference kSpawnPoint = ModuleSpawnPoint
            If IsNone(kSpawnPoint)
                QuestExt kQuest = GetOwningQuest() as QuestExt
                If !IsNone(kQuest) && !IsNone(kQuest.Utilities)
                    kSpawnPoint = kQuest.Utilities.GetReference()
                Else 
                    Quest kQuest2 = GetOwningQuest()
                    LogWarnGlobal(Self, "Owning Quest does not extend HTG:QuestExt: " + kQuest2)
                EndIf
            EndIf

            If IsNone(kSpawnPoint)
                LogWarnGlobal(Self, "Cound not find Module Spawnpoint")
                return False
            EndIf

            kMod = CreateReference(kSpawnPoint, ModInfoForm, akAlias = Self) as SystemModuleInformation
            ForceRefTo(kMod)
        Else
            ; LogObjectGlobal(Self, "Unable to get SystemModuleInformation.")
            return False
        EndIf
    Else
        kMod = GetReference() as SystemModuleInformation
        ; ObjectReference[] refs = ModuleSpawnPoint.FindAllReferencesOfType(kMod, 5000)
        ; LogObjectGlobal(Self, "Utilties Refs: " + refs)
    EndIf

    If !IsNone(kMod) 
        If !IsNone(ModuleSpawnPoint)
            ObjectReference kUitilRef = ModuleSpawnPoint
            Cell kCell = kMod.GetParentCell()
            LogObjectGlobal(Self, "Utilities current cell: " + kUitilRef.GetParentCell() + \
                        "\n\tMods current cell: " + kCell)
            MoveReference(kMod, kUitilRef)
        EndIf

        Cell kCell = kMod.GetParentCell()
        LogObjectGlobal(Self, "Mods current cell: " + kCell)
        LogObjectGlobal(Self, "Loading Module: " + kMod + \
                    "\n\tName: " + kMod.Name + \
                    "\n\tDescription: " + kMod.Description + \
                    "\n\tIsCoreIntegrated: " + kMod.IsCoreIntegrated + \
                    "\n\tVersion: " + kMod.Version)

        If kMod.IsCoreIntegrated
            kMod.SetLinkedRef(Game.GetPlayer())
        EndIf
    EndIf

    return IsFilled()
EndFunction