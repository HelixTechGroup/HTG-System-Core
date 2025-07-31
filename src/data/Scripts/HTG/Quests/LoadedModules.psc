Scriptname HTG:Quests:LoadedModules extends HTG:RefCollectionAliasExt
{Reference Collection that holds information about loaded Mod(ule)s}
import HTG
import HTG:UtilityExt

FormList Property ModuleRegistry Mandatory Const Auto
Keyword Property SystemModuleInformationKeyword Mandatory Const Auto

Guard _refreshTimerGuard ProtectsFunctionLogic
Int _refreshTimerId = 10
Bool _refreshTimerStarted
Float _timerInterval = 0.01
Int _maxTimerCycle = 50
Int _currentRefreshTimerCycle = 0

Event OnAliasStarted()
    Parent.OnAliasStarted()

    StartTimer(0.333, _refreshTimerId)
EndEvent

Event OnAliasChanged(ObjectReference akObject, bool abRemove)
    Parent.OnAliasChanged(akObject, abRemove)

    If !abRemove
        SystemModuleInformation kMod = akObject as SystemModuleInformation
        Logger.Log("Detected Loaded Module: " + kMod + \
                    "\n\tName: " + kMod.Name + \
                    "\n\tDescription: " + kMod.Description + \
                    "\n\tIsCoreIntegrated: " + kMod.IsCoreIntegrated + \
                    "\n\tVersion: " + kMod.Version)
    EndIf
EndEvent

Event OnTimer(int aiTimerID)
    Parent.OnTimer(aiTimerID)

    If aiTimerID == _refreshTimerId
        TryLockGuard _refreshTimerGuard
            _refreshTimerStarted = True
            _Refresh()
            If _currentRefreshTimerCycle < _maxTimerCycle            
                _currentRefreshTimerCycle += 1
            ElseIf _currentRefreshTimerCycle == _maxTimerCycle
                Logger.Log("Finished Refresh of Loaded Modules.")
                return
            EndIf
            _refreshTimerStarted = False
        EndTryLockGuard

        StartTimer(0.1, _refreshTimerId)
    EndIf
EndEvent

Function _Refresh()
    ObjectReference[] kModules = Game.GetPlayer().FindAllReferencesWithKeyword(SystemModuleInformationKeyword, 500)
    Int i
    While i < kModules.Length ; ModuleRegistry.GetSize()
        SystemModuleInformation kMod = kModules[i] as SystemModuleInformation ; ModuleRegistry.GetAt(i)
        Logger.LogObject(kMod, "Is ModInfo: " + IsNone(kMod))
        If !IsNone(kMod) && !Contains(kMod)
            AddRef(kMod)
            ObjectReference kUitilRef = Utilities.GetReference()
            Cell kCell = kMod.GetParentCell()
            Logger.Log("Utilities current cell" + kUitilRef.GetParentCell())
            Logger.Log("Mods current cell" + kCell)
            kMod.MoveTo(kUitilRef)
            kCell = kMod.GetParentCell()
            Logger.Log("Mods new cell" + kCell)
        EndIf
        i += 1
    EndWhile

    Logger.LogRefCollectionAlias(Self, "Loaded Modules: ")
EndFunction