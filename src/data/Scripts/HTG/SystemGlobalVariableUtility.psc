Scriptname HTG:SystemGlobalVariableUtility extends ScriptObject Hidden

Bool Function GlobalToBool(GlobalVariable akValue) Global
    If akValue.GetValue() > 0.0
        return True
    EndIf

    return False
EndFunction