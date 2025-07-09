Scriptname HTG:Quests:SQ_UnityEventController extends HTG:QuestExt
{Unity Event Controller}
import HTG
import HTG:Collections
import HTG:UtilityExt

ActorValue Property PlayerUnityTimesEntered Mandatory Const Auto
Mq305Script Property EndGameQuest Mandatory Const Auto
MQ401QuestScript Property BeginUnityQuest Mandatory Const Auto 
;Contains Quests that are Universe Variants
FormList Property UnityVariantQuests Mandatory Const Auto
;Contains Quests that save or alter game data pre unity
FormList Property UnityDataQuests Mandatory Const Auto

; GameplayOption Property UnityCharGenEnabled Auto Const Mandatory

Int _enterUnityStageId = 2000
Int _unityFaceGenCompleteStageId = 120
Int _unityGetDataStageId = 5000
Int _unitySetDataStageId = 5001
FormListExt _completeVariantList

Event OnQuestStarted()
    Parent.OnQuestStarted()
    
    RegisterForRemoteEvent(EndGameQuest, "OnStageSet")
    RegisterForRemoteEvent(BeginUnityQuest, "OnQuestInit")
EndEvent

Event OnQuestShutdown()
    UnregisterForRemoteEvent(EndGameQuest, "OnStageSet")
    UnregisterForRemoteEvent(BeginUnityQuest, "OnQuestInit")
EndEvent

Event Quest.OnQuestInit(Quest akSender)
    WaitForInitialized()

    Int i = 0
    If akSender == BeginUnityQuest
        While i < UnityDataQuests.GetSize()
            Quest kDataQuest = UnityDataQuests.GetAt(i) as Quest
            kDataQuest.SetStage(_unitySetDataStageId)
            i += 1
        EndWhile 

        _completeVariantList.AddArray(BeginUnityQuest.MQ401VariantsArray as Var[])
        _completeVariantList.AddArray(UnityVariantQuests.GetArray() as Var[])
        
        ;roll for a random variant of MQ401
        ;only do this if the player has been through the Unity twice
        Int iVariantPercentChance = BeginUnityQuest.MQ401_VariantChance.GetValueInt()
        Int iVariantChanceRoll = Utility.RandomInt(0, 100)
        If (Game.GetPlayer().GetValue(PlayerUnityTimesEntered) >= 2) && (iVariantChanceRoll <= iVariantPercentChance)
            Int iTotalVariants = _completeVariantList.Count - 1 ;MQ401VariantsArray.Length - 1 ;subtract 1 since array values start at 0
            Int iVariantNumberRoll = BeginUnityQuest.MQ401_ForceVariant.GetValueInt()
            If iVariantNumberRoll == -1 ;if we're not forcing a variant, then roll for a random one
                iVariantNumberRoll = Utility.RandomInt(0, iTotalVariants)
            EndIf
            BeginUnityQuest.MQ401_VariantCurrent.SetValueInt(iVariantNumberRoll) ; for dialogue conditions across quests        

            Quest kVariant = _completeVariantList.GetAt(iVariantNumberRoll) as Quest
            kVariant.Start() ;start the variant quest
        Else
            BeginUnityQuest.NormalStart()
        EndIf

        Bool kStartCharGen = True
        If Game.IsPluginInstalled("HTG-Regenesys-Unity")
            kStartCharGen = Game.GetGameSettingBool("RegenesysUnityRegenesysUnity_EnableCharGen")
        EndIf

        If kStartCharGen
            ; Start CharGen; the fragment calls CheckChargenMenu()
            BeginUnityQuest.SetStage(BeginUnityQuest.FaceGenStage)
        Else
            BeginUnityQuest.SetStage(_unityFaceGenCompleteStageId)
        EndIf
    EndIf
EndEvent

Event Quest.OnStageSet(Quest akSender, int auiStageID, int auiItemID)  
    WaitForInitialized()

    Int i = 0
    If akSender == EndGameQuest && auiStageID == _enterUnityStageId && auiItemID == 0
        While i < UnityDataQuests.GetSize()
            Quest kDataQuest = UnityDataQuests.GetAt(i) as Quest
            kDataQuest.SetStage(_unityGetDataStageId)
            i += 1
        EndWhile 

        EndGameQuest.EnterUnity()
    EndIf
EndEvent

Bool Function _Init()
    If IsNone(_completeVariantList)
        _completeVariantList = HTG:Collections:FormListExt.FormListExtIntegrated(SystemUtilities.ModInfo)
    EndIf

    return _completeVariantList.IsInitialized
EndFunction