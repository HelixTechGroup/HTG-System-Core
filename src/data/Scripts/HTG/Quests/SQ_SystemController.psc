Scriptname HTG:Quests:SQ_SystemController extends HTG:QuestExt
import HTG
import HTG:Structs
import HTG:Quests
import HTG:UtilityExt

Group Aliases
ModuleTracker Property Modules Mandatory Const Auto
EndGroup

Group Controllers
SQ_DataslateController Property Dataslate Mandatory Const Auto

SQ_PlayerController Property Player Mandatory Const Auto

SQ_HoloArmorController Property HoloArmor Mandatory Const Auto
EndGroup

Event OnQuestStarted()
    Parent.OnQuestStarted()

    DependencyTracker k = Utilities.Dependencies
    k.WaitForInitialized()
    ; ObjectReference kRef = k.ResolveReference(2102)
    Form kForm = k.ResolveForm(2102)
    If !IsNone(kForm)
        If kForm.GetFormID() == Player.GetFormID()            
            Logger.Log("Found Player Controller: " + Utility.IntToHex(kForm.GetFormID()) + \ 
                        "\n\t" + kForm)
        EndIf
    Else
        Logger.WarnEx("Could not find Player Controller")
    EndIf

    kForm = k.ResolveForm(2102)
    If !IsNone(kForm)
        If kForm.GetFormID() == Player.GetFormID()            
            Logger.Log("Found Player Controller: " + Utility.IntToHex(kForm.GetFormID()) + \ 
                        "\n\t" + kForm)
        EndIf
    Else
        Logger.WarnEx("Could not find Player Controller")
    EndIf
EndEvent