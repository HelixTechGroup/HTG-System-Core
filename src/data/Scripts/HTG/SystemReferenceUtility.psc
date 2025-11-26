Scriptname HTG:SystemReferenceUtility extends ScriptObject Hidden
import HTG
import HTG:SystemLogger

Bool Function MoveReference(ObjectReference akRef, ObjectReference akMoveToRef) Global
    Cell kCell = akRef.GetParentCell()
    Cell kMoveToCell = akMoveToRef.GetParentCell()
    LogGlobal("Utilities current cell" + kMoveToCell)
    LogGlobal("Mods current cell" + kCell)

    If kCell != kMoveToCell
        akRef.MoveTo(akMoveToRef)
        kCell = akRef.GetParentCell()
        LogGlobal("Mods new cell" + kCell)
    EndIf

    If kCell != kMoveToCell
        return False
    EndIf

    return True
EndFunction