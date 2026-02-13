Scriptname HTG:Quests:SQ_DependencyController extends HTG:QuestExt
import HTG:UtilityExt

DependencyTracker Property Dependencies Hidden
    HTG:Quests:DependencyTracker Function Get()
        return _dependencyTracker
    EndFunction
EndProperty

Int Property DependencyTrackerId Auto Hidden

DependencyTracker _dependencyTracker

Function _CheckAliasType(Alias akAlias, Int aiIndex)
    Parent._CheckAliasType(akAlias, aiIndex)

    If akAlias is MessageTracker
        DependencyTrackerId = aiIndex

        If IsNone(_dependencyTracker)
            _dependencyTracker = akAlias as DependencyTracker
        EndIf
    EndIf
EndFunction

Bool Function _SetSystemAliases()
    Parent._SetSystemAliases()

    If !IsNone(_dependencyTracker)
        return _dependencyTracker.IsInitialized
    EndIf

    DependencyTrackerId = _CheckAliasRegistry("HTG:Quests:DependencyTracker")

    If DependencyTrackerId > -1
        _dependencyTracker = GetAlias(DependencyTrackerId) as DependencyTracker
    Else 
        _dependencyTracker = GetAliasType("HTG:Quests:DependencyTracker") as DependencyTracker
    EndIf

    return !IsNone(_dependencyTracker) && _dependencyTracker.IsInitialized
EndFunction