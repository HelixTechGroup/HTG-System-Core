ScriptName HTG:Dataslate:DataslateTerminalActivator Extends ActiveMagicEffect

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
ReferenceAlias Property DataslateTerminal Auto mandatory

;-- Functions ---------------------------------------

Event OnEffectFinish(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
  ; Empty function
EndEvent

Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
  DataslateTerminal.GetReference().Activate(akCaster as ObjectReference, True) ; #DEBUG_LINE_NO:6
  inputenablelayer iel = inputenablelayer.Create() ; #DEBUG_LINE_NO:7
  iel.DisablePlayerControls(True, True, False, False, False, True, True, False, True, True, False) ; #DEBUG_LINE_NO:8
  iel.EnablePlayerControls(True, True, True, True, True, True, True, True, True, True, True) ; #DEBUG_LINE_NO:9
EndEvent
