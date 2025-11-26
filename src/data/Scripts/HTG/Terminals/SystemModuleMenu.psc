Scriptname HTG:Terminals:SystemModuleMenu extends HTG:Terminals:DataslateTerminalMenu
import HTG
import HTG:Quests
import HTG:UtilityExt

ModuleTracker Property Modules Mandatory Const Auto
GlobalVariable Property ShowModInfo Mandatory Const Auto
Message Property EmptyMessage Mandatory Const Auto

String _luckToken = "LucAttr"
Int _exitItemId = 1000
Int _maxItemId = 100

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    Parent.OnTerminalMenuEnter(akTerminalBase, akTerminalRef)

    Int i = 0
    Form[] kData = new Form[0]
    Form[] kListData = new Form[0]

    While i < Modules.GetCount()
        ; String label = "MName" + i
        Form kMod = Modules.GetAt(i)
        kData.Add(kMod)
        kListData.Add(kMod)
        i += 1
    EndWhile

    If kListData.Length <= 15
        Int kI = kListData.Length
        While kI <= 15
            kListData.Add(EmptyMessage)
            kI += 1
        EndWhile
    EndIf

    i = 0
    Int kBIndex = 1
    While i < kData.Length 
        akTerminalBase.AddDynamicBodyTextItem(akTerminalRef, i, kBIndex, kListData)
        akTerminalBase.AddDynamicMenuItem(akTerminalRef, i, kBIndex, kData)

        i += 1
        kBIndex += 1
    EndWhile
EndEvent

Event OnTerminalMenuItemRun(int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    Parent.OnTerminalMenuItemRun(auiMenuItemID, akTerminalBase, akTerminalRef)

    If (auiMenuItemID > 0 && auiMenuItemID <= _maxItemId)
        Int kI = auiMenuItemID - 1
        Modules.WaitForInitialized()
        SystemModuleInformation kMod = Modules.GetAt(kI) as SystemModuleInformation
        If IsNone(kMod)
            Logger.WarnEx("Could not find Loaded Modules")
            return
        EndIf

        Logger.Log("Displaying Loaded Module: " + kMod + \
                    "\n\tName: " + kMod.Name + \
                    "\n\tDescription: " + kMod.Description + \
                    "\n\tIsCoreIntegrated: " + kMod.IsCoreIntegrated + \
                    "\n\tVersion: " + kMod.Version)
        akTerminalRef.AddTextReplacementData("MName", kMod.GetBaseObject())
        akTerminalRef.AddTextReplacementValue("MMajVer", kMod.Version.Major)
        akTerminalRef.AddTextReplacementValue("MMinVer", kMod.Version.Minor)
        akTerminalRef.AddTextReplacementValue("MRevVer", kMod.Version.Revision)
        akTerminalRef.AddTextReplacementValue("MPatchVer", kMod.Version.Patch)
        ShowModInfo.SetValueInt(1)
    ElseIf (auiMenuItemID == _exitItemId) 
        ShowModInfo.SetValueInt(0)
        akTerminalRef.ClearDynamicTerminalMenuItems()       
        return
    Else
        ShowModInfo.SetValueInt(0)
    EndIf
EndEvent