Scriptname HTG:SystemMessageQueueEntry extends ObjectReference
import HTG
import HTG:Structs
import HTG:UtilityExt
import HTG:SystemLogger
import HTG:SystemFormUtility

Int Property TimerId Auto
ObjectReference[] Property TextHolderReferences Auto
ReferenceAlias[] Property TextHolderAliases Auto
Float[] Property MessageArguments Auto

SystemMessageEntry Property MessageEntry
    HTG:Structs:SystemMessageEntry Function Get()
        return _entry
    EndFunction
EndProperty

SystemMessageEntry _entry

SystemMessageQueueEntry Function SystemMessageQueueEntry(ObjectReference akSpawnPoint, \
                                            Int aiTimerId, \ 
                                            SystemMessageEntry akEntry, \                                                                                   
                                            Float[] afArgs = None, \
                                            ReferenceAlias[] akTextHolderAlias = None, \
                                            ObjectReference[] akTextHolder = None) Global
    Int kEntryFormId = 0x0000090B
    Form kForm = CreateForm(kEntryFormId)

    SystemMessageQueueEntry kResult = HTG:SystemFormUtility.CreateReference(akSpawnPoint, kForm) as SystemMessageQueueEntry
    If IsNone(kResult)
        LogErrorGlobal(akSpawnPoint, "Could not create HTG:SystemMessageQueueEntry")
        return None
    EndIf
    
    kResult.TimerId = aiTimerId
    kResult.RegisterEntry(akEntry, afArgs, akTextHolder, akTextHolderAlias)

    return kResult
EndFunction

SystemMessageEntry Function RegisterEntry(SystemMessageEntry akEntry, \                                            
                                            Float[] afArgs = None, \
                                            ObjectReference[] akTextHolder = None, \
                                            ReferenceAlias[] akTextHolderAlias = None)
    _entry = akEntry
    TextHolderAliases = akTextHolderAlias
    TextHolderReferences = akTextHolder

    return _entry
EndFunction

SystemMessageEntry Function RegisterMessage(String asEditorId, \
                                Message akMessage, \
                                Int aiDuration, \		
                                Int aiInterval,	\							
                                Int aiMaxTimes,	\							
                                Int aiPriority, \
                                Float[] afArgs = None, \
                                ObjectReference[] akTextHolder = None, \
                                ReferenceAlias[] akTextHolderAlias = None)
    _entry = new SystemMessageEntry

    TextHolderAliases = akTextHolderAlias
    TextHolderReferences = akTextHolder

    return _entry
EndFunction

Int Function Show()
    _entry.TimesShown += 1
    return ShowMessage(_entry.Entry, \                
                        _entry.IsHelpMessage, \
                        _entry.IsMessageBox, \
                        _entry.EventName, \
                        _entry.Duration, \
                        _entry.Interval, \
                        _entry.MaxTimes, \
                        _entry.Priority, \
                        _entry.Context, \
                        MessageArguments, \
                        TextHolderAliases, \
                        TextHolderReferences)
EndFunction