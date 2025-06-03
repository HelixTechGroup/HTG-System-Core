Scriptname HTG:Dataslate:DataslateTerminalActivator extends ActiveMagicEffect

ReferenceAlias Property DataslateTerminal Auto Mandatory

Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, float afMagnitude, float afDuration)
    Parent.OnEffectStart(akTarget, akCaster, akBaseEffect, afMagnitude, afDuration)
    
    DataslateTerminal.GetReference().Activate(akCaster, True)
    InputEnableLayer iel = InputEnableLayer.Create()
    iel.DisablePlayerControls()
    iel.EnablePlayerControls()
EndEvent

Event OnEffectFinish(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, float afMagnitude, float afDuration)
EndEvent