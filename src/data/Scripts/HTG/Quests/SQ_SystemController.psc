Scriptname HTG:Quests:SQ_SystemController extends Quest
import HTG
import HTG:Structs
import HTG:Quests
import HTG:UtilityExt
import HTG:SystemLogger
import Utility

Group Aliases
ModuleTracker Property Modules Mandatory Const Auto
DependencyTracker Property Dependencies Mandatory Const Auto    
MessageTracker Property Messages Mandatory Const Auto
EndGroup

Group Controllers
SQ_DataslateController Property Dataslate Mandatory Const Auto
SQ_PlayerController Property Player Mandatory Const Auto
SQ_HoloArmorController Property HoloArmor Mandatory Const Auto
SQ_UnityEventController Property UnityEvent Mandatory Const Auto
EndGroup

Event OnQuestStarted()
    Debug.Notification("Hours Passed: " + Game.GetRealHoursPassed())
    LogObjectGlobal(Self, "Hours Passed: " + Game.GetRealHoursPassed())
    ModuleTracker kMods = Modules
    kMods.WaitForInitialized()

    DependencyTracker k = Dependencies
    k.WaitForInitialized()
    ; ObjectReference kRef = k.ResolveReference(2102)
    Form kForm = k.ResolveForm(2102)
    If !IsNone(kForm)
        If kForm.GetFormID() == Player.GetFormID()            
            LogObjectGlobal(Self, "Found Player Controller: " + Utility.IntToHex(kForm.GetFormID()) + \ 
                                    "\n\t" + kForm)
            Debug.Notification("Found Player Controller: " + Utility.IntToHex(kForm.GetFormID()))
        EndIf
    Else
        LogWarnGlobal(Self, "Could not find Player Controller")
        Debug.Notification("Could not find Player Controller")
    EndIf

    ; Wait(0.5)

    kForm = k.ResolveForm(asEditorId = "SQ_PlayerController")
    If !IsNone(kForm)
        If kForm.GetFormID() == Player.GetFormID()            
            LogObjectGlobal(Self, "Found Player Controller: " + Utility.IntToHex(kForm.GetFormID()) + \ 
                                    "\n\t" + kForm)
            Debug.Notification("Found Player Controller: " + Utility.IntToHex(kForm.GetFormID()))
        EndIf
    Else
        LogWarnGlobal(Self, "Could not find Player Controller")
        Debug.Notification("Could not find Player Controller")
    EndIf

    ; WaitExt(1)

    ; MessageTracker kMessages = Messages
    ; kMessages.WaitForInitialized()

    ; String sMessage = "ModInfoMessageBox"
    ; Int iResult = kMessages.Show(sMessage)
    ; LogObjectGlobal(Self, "Message: " + sMessage + \
    ;                         " Result: " + iResult)
    ; Debug.Notification("Message: " + sMessage + \
    ;                         " Result: " + iResult)
EndEvent