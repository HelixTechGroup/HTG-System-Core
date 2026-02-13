Scriptname HTG:Quests:SQ_MessageController extends HTG:QuestExt
import HTG:UtilityExt
import HTG:Structs

SystemMessageEntry[] Property LocalSystemMessageRegistery Const Auto

SystemMessageEntry[] Property SystemMessageRegistery Hidden
    SystemMessageEntry[] Function Get()
        return _messageTracker.SystemMessageRegistery
    EndFunction
EndProperty

MessageTracker Property Messages Hidden
    HTG:Quests:MessageTracker Function Get()
        return _messageTracker
    EndFunction
EndProperty

Int Property MessageTrackerId Auto Hidden

MessageTracker _messageTracker

Function RegisterMessage(String EditorId, \
                            Message akMessage, \
                            Bool abIsHelpMessage = False, \
                            Bool abIsMessageBox = False, \
                            String asEventName = "", \
                            Float afDuration = 30.0, \
                            Float afInterval = 30.0, \
                            Int aiMaxTimes = 1, \
                            Int aiPriority = 0, \
                            String asContext = "", \
                            ReferenceAlias[] akTextHolderAliases = None)
    _messageTracker.RegisterMessage(EditorId, \
                                    akMessage, \
                                    abIsHelpMessage, \
                                    abIsMessageBox, \
                                    asEventName, \
                                    afDuration, \
                                    afInterval, \
                                    aiMaxTimes, \
                                    aiPriority, \
                                    asContext, \
                                    akTextHolderAliases)
EndFunction

Function UnregisterMessage(String asEditorId = "", \
                            Message akMessage = None)
    _messageTracker.UnregisterMessage(asEditorId, akMessage)
EndFunction

Int Function Show(String asEditorId, \
                    Float[] afArgs = None, \
                    ObjectReference[] akTextHolderRefs = None)
    return _messageTracker.Show(asEditorId, \
                                afArgs, \
                                akTextHolderRefs)           
EndFunction

Bool Function _Init()
    Int i = 0
    SystemMessageEntry[] kLocal = LocalSystemMessageRegistery

    While i < kLocal.Length
        SystemMessageEntry kEntry = kLocal[i]
        If SystemMessageRegistery.Find(kEntry) < 0
            SystemMessageRegistery.Add(kEntry)
        EndIf
    EndWhile

    return True
EndFunction

Function _CheckAliasType(Alias akAlias, Int aiIndex)
    Parent._CheckAliasType(akAlias, aiIndex)

    If akAlias is MessageTracker
        MessageTrackerId = aiIndex

        If IsNone(_messageTracker)
            _messageTracker = akAlias as MessageTracker
        EndIf
    EndIf
EndFunction

Bool Function _SetSystemAliases()
    Parent._SetSystemAliases()

    If !IsNone(_messageTracker)
        return _messageTracker.IsInitialized
    EndIf

    MessageTrackerId = _CheckAliasRegistry("HTG:Quests:MessageTracker")

    If MessageTrackerId > -1
        _messageTracker = GetAlias(MessageTrackerId) as MessageTracker
    Else 
        _messageTracker = GetAliasType("HTG:Quests:MessageTracker") as MessageTracker
    EndIf

    return !IsNone(_messageTracker) && _messageTracker.IsInitialized
EndFunction