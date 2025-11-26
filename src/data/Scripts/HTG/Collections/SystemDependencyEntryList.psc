Scriptname HTG:Collections:SystemDependencyEntryList extends HTG:Collections:List
import HTG:SystemLogger
import HTG
import HTG:Structs
import HTG:SystemFormUtility

Event OnInit()
    ArrayType = "SystemDependencyEntry"
EndEvent

SystemDependencyEntryList Function SystemDependencyEntryList(SystemModuleInformation akMod, Int aiSize = 0) Global
    Int iFormId = 0x000008E6
    SystemDependencyEntryList res =  HTG:Collections:List._CreateList(akMod, iFormId, aiSize = aiSize) as SystemDependencyEntryList
    LogObjectGlobal(res, "HTG:Collections:SystemDependencyEntryList.SystemDependencyEntryList(" + aiSize  + "): " + res)
    return res
EndFunction

; SystemDependencyEntryList Function DependencyEntryListIntegrated(SystemModuleInformation akMod, Int aiSize = 0) Global 
;     If HTG:UtilityExt.IsNone(akMod)
;         return None
;     EndIf

;     If !akMod.IsCoreIntegrated
;         return SystemDependencyEntryList(aiSize)
;     EndIf

;     SystemDependencyEntryList res
;     res = HTG:Collections:List._CreatedRegisteredList(akMod, "HTG:Collections:SystemDependencyEntryList", aiSize) as SystemDependencyEntryList
;     LogObjectGlobal(res, "HTG:Collections:SystemDependencyEntry.SystemDependencyEntry(" + aiSize  + "): " + res)
;     return res
; EndFunction

SystemDependencyEntry Function GetAt(Int index)
    return GetVarAt(index) as SystemDependencyEntry
EndFunction

Bool Function IsNone(Var akItem)
    If akItem is SystemDependencyEntry
        SystemDependencyEntry ref = akItem as SystemDependencyEntry
        return ref == None
    EndIf

    return False
EndFunction

Bool Function TestType(Var akItem)
    If akItem as SystemDependencyEntry
        return True
    EndIf
EndFunction

Bool Function CompareItems(Var akArrayItem, Var akItem)
    If akArrayItem is HTG:SystemDependencyEntry && akItem is SystemDependencyEntry
        return (akArrayItem as SystemDependencyEntry).Id == (akItem as SystemDependencyEntry).Id
    EndIf
EndFunction

Int Function AddEntry(SystemTypeEntry akEntry, Bool abCreateReference = False)
    SystemDependencyEntry kResult = HTG:SystemDependencyEntry.SystemDependencyEntry(Self, akEntry, abCreateReference)
    LogGlobal("Refs Linked to Collection: " + GetRefsLinkedToMe().Length)

    return Add(kResult)
EndFunction

SystemDependencyEntry Function GetFormIdEntry(Int aiId)
    Int akIndex = FindStruct("Id", aiId)
    If akIndex > -1
        return GetAt(akIndex)
    EndIf

    return None
EndFunction

SystemDependencyEntry Function GetFormNameEntry(String asName)
    Int akIndex = FindStruct("FormName", asName)
    If akIndex > -1
        return GetAt(akIndex)
    EndIf

    return None
EndFunction

SystemDependencyEntry Function GetNameEntry(String asName)
    Int akIndex = FindStruct("Name", asName)
    If akIndex > -1
        return GetAt(akIndex)
    EndIf

    return None
EndFunction

SystemDependencyEntry Function GetFormEntry(Form akForm)
    Int akIndex = FindFormEntry(akForm)
    If akIndex > -1
        return GetAt(akIndex)
    EndIf

    return None
EndFunction

SystemDependencyEntry Function GetScriptNameEntry(String asScriptName)
    Int akIndex = FindScriptNameEntry(asScriptName)
    If akIndex > -1
        return GetAt(akIndex)
    EndIf

    return None
EndFunction

Int Function FindFormIdEntry(Int aiId)
    return FindStruct("Id", aiId)
EndFunction

Int Function FindFormNameEntry(String asName)
    return FindStruct("Name", asName)
EndFunction

Int Function FindFormEntry(Form akForm)
    return FindStruct("Type", akForm)
EndFunction

Int Function FindScriptNameEntry(String asScriptName)
    Int i = 0
    While i < Count
        SystemDependencyEntry kEntry = GetAt(i)     
        If kEntry.SystemType.Script == asScriptName
            return i
        EndIf

        i += 1
    EndWhile

    return -1
EndFunction

Bool Function ContainsFormId(Int aiId)
    return FindStruct("Id", aiId) > -1
EndFunction

Bool Function ContainsEntryName(String asName)
    return FindStruct("Name", asName) > -1
EndFunction

Bool Function ContainsFormName(String asFormName)
    return FindStruct("FormName", asFormName) > -1
EndFunction

Bool Function ContainsForm(Form akForm)
    return FindStruct("Type", akForm) > -1
EndFunction

Bool Function ContainsScriptName(String asScriptName)
    return FindScriptNameEntry(asScriptName) > -1
EndFunction

Int Function _FindStruct(String asVarName, Var akElement)
    SystemTypeEntry[] kArray = new SystemTypeEntry[0]
    Int i
    Int res = -1
    While i < Count
        SystemDependencyEntry kMember = GetAt(i)
        kArray.Add(kMember.SystemType)
        i += 1
    EndWhile

    If asVarName == "FormId" ||  asVarName == "Id"
        res = kArray.FindStruct("FormId", akElement as Int)
    ElseIf asVarName == "FormName"
        res = kArray.FindStruct("FormName", akElement as String)
    ElseIf asVarName == "EditorId"
        res = kArray.FindStruct("EditorId", akElement as String)
    ElseIf asVarName == "Script" ||  asVarName == "ScriptName"
        res = kArray.FindStruct("Script", akElement as String)
    EndIf

    kArray = None
    return res
EndFunction