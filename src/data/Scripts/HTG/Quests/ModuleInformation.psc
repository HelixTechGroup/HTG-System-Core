Scriptname HTG:Quests:ModuleInformation Extends HTG:ReferenceAliasExt
import HTG
import HTG:Structs
import HTG:UtilityExt
import HTG:FormUtility
import HTG:SystemLogger

Form Property ModInfoForm Const Auto

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

Event OnAliasInit()
    SystemModuleInformation kMod
    If !IsFilled() 
        If !IsNone(ModInfoForm)
            kMod = CreateReference(Game.GetPlayer(), ModInfoForm, akAlias = Self) as SystemModuleInformation
        Else
            LogObjectGlobal(Self, "Unable to get SystemModuleInformation.")
        EndIf
    Else
        kMod = GetReference() as SystemModuleInformation
        ; ObjectReference[] refs = Utilities.GetReference().FindAllReferencesOfType(kMod, 5000)
        ; LogObjectGlobal(Self, "Utilties Refs: " + refs)
    EndIf

    If !IsNone(kMod)
        LogObjectGlobal(Self, "Loading Module: " + kMod + \
                    "\n\tName: " + kMod.Name + \
                    "\n\tDescription: " + kMod.Description + \
                    "\n\tIsCoreIntegrated: " + kMod.IsCoreIntegrated + \
                    "\n\tVersion: " + kMod.Version)
    EndIf

    Parent.OnAliasInit()
EndEvent

Bool Function WaitForInitialized()
    If IsInitialized
        return True
    EndIf
    
    Int currentCycle = 0
    Int maxCycle = 150
    Bool maxCycleHit

    ; StartTimer(_timerInterval, _initializeTimerId)

    While !maxCycleHit \
            && (!IsInitialized)
        WaitExt(0.01)

        If currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile

    return IsInitialized
EndFunction