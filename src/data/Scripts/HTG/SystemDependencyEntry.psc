Scriptname HTG:SystemDependencyEntry extends ObjectReference
import HTG
import HTG:Structs
import HTG:SystemFormUtility
import HTG:UtilityExt
import HTG:SystemLogger

Int Property Id Hidden
    Int Function Get()
        return _entry.FormId
    EndFunction
EndProperty

String Property Name Hidden
    String Function Get()
        return _entry.FormName
    EndFunction
EndProperty

String Property EditorId Hidden
    String Function Get()
        return _entry.EditorId
    EndFunction
EndProperty

Form Property Type Hidden
    Form Function Get()
        return _type
    EndFunction
EndProperty

ObjectReference Property Reference Hidden
    ObjectReference Function Get()
        If CanCreateReference(_type) \
            && IsNone(_reference)
            _reference = CreateReference()
        EndIf

        return _reference
    EndFunction
EndProperty

SystemTypeEntry Property SystemType Hidden
    HTG:Structs:SystemTypeEntry Function Get()
        return _entry
    EndFunction
EndProperty

SystemTypeEntry _entry
Form _type
ObjectReference _reference
Bool _canCreateReference

SystemDependencyEntry Function SystemDependencyEntry(ObjectReference akSpawnPoint, \
                                            SystemTypeEntry akEntry, \                                            
                                            Bool abCreateReference = False) Global
    Int kEntryFormId = 0x000008F9
    Form kForm = CreateForm(kEntryFormId)

    SystemDependencyEntry kResult = HTG:SystemFormUtility.CreateReference(akSpawnPoint, kForm) as SystemDependencyEntry
    If IsNone(kResult)
        LogErrorGlobal(akSpawnPoint, "Could not create HTG:SystemDependencyEntry")
        return None
    EndIf
    
    kResult.RegisterEntry(akEntry, abCreateReference)

    return kResult
EndFunction

ObjectReference Function RegisterEntry(SystemTypeEntry akEntry, \
                                            Bool abCreateReference = False)
    _entry = akEntry
    _type = CreateForm(_entry.FormId, _entry.ModName)
    _canCreateReference = CanCreateReference(_type)

    If _canCreateReference && abCreateReference
        _reference = CreateReference()
    EndIf

    return _reference
EndFunction

ObjectReference Function RegisterForm(Int aiFormId, \
                                        String asModName, \
                                        String asFormName, \
                                        Form akForm = None, \
                                        Bool abCreateReference = False)
    _entry = new SystemTypeEntry
    _entry.FormId = aiFormId
    _entry.ModName = asModName
  
    _reference = RegisterEntry(_entry)

    return _reference
EndFunction

ObjectReference Function SetReference(ObjectReference akRef, \
                                        Bool abOverrideExistsing = False)
    If !_canCreateReference \
        || (!abOverrideExistsing && !IsNone(_reference))
        return _reference
    EndIf

    _reference = akRef
    return _reference
EndFunction

ObjectReference Function CreateReference(Bool abOverrideExistsing = False)
    If !_canCreateReference \
        || (!abOverrideExistsing && !IsNone(_reference))
        return _reference
    EndIf

    _reference = HTG:SystemFormUtility.CreateReference(Self, _type)
    return _reference
EndFunction