#include "config/battle.h"
#include "constants/battle.h"
#include "constants/battle_script_commands.h"
#include "constants/battle_anim.h"
#include "constants/battle_string_ids.h"
#include "constants/moves.h"
#include "constants/songs.h"
#include "constants/game_stat.h"
	.include "asm/macros.inc"
	.include "asm/macros/battle_script.inc"
	.include "constants/constants.inc"

	.section script_data, "aw", %progbits

	.align 2
gBattlescriptsForUsingItem::
	.4byte BattleScript_ItemRestoreHP                @ EFFECT_ITEM_RESTORE_HP
	.4byte BattleScript_ItemCureStatus               @ EFFECT_ITEM_CURE_STATUS
	.4byte BattleScript_ItemHealAndCureStatus        @ EFFECT_ITEM_HEAL_AND_CURE_STATUS
	.4byte BattleScript_ItemIncreaseStat             @ EFFECT_ITEM_INCREASE_STAT
	.4byte BattleScript_ItemSetMist                  @ EFFECT_ITEM_SET_MIST
	.4byte BattleScript_ItemSetFocusEnergy           @ EFFECT_ITEM_SET_FOCUS_ENERGY
	.4byte BattleScript_RunByUsingItem               @ EFFECT_ITEM_ESCAPE
	.4byte BattleScript_ItemRestoreHP                @ EFFECT_ITEM_REVIVE
	.4byte BattleScript_ItemRestorePP                @ EFFECT_ITEM_RESTORE_PP
	.4byte BattleScript_ItemIncreaseAllStats         @ EFFECT_ITEM_INCREASE_ALL_STATS

	.align 2

BattleScript_ItemEnd:
	end

BattleScript_UseItemMessage:
	printstring STRINGID_EMPTYSTRING3
	pause B_WAIT_TIME_MED
	playse SE_USE_ITEM
	getbattlerside BS_ATTACKER
	copybyte cMULTISTRING_CHOOSER, gBattleCommunication
	printfromtable gTrainerUsedItemStringIds
	waitmessage B_WAIT_TIME_LONG
	return

BattleScript_ItemRestoreHPRet:
	bichalfword gMoveResultFlags, MOVE_RESULT_NO_EFFECT
	orword gHitMarker, HITMARKER_IGNORE_SUBSTITUTE
	healthbarupdate BS_SCRIPTING
	datahpupdate BS_SCRIPTING
	printstring STRINGID_ITEMRESTOREDSPECIESHEALTH
	waitmessage B_WAIT_TIME_LONG
	return

BattleScript_ItemRestoreHP::
	call BattleScript_UseItemMessage
	itemrestorehp BattleScript_ItemRestoreHPEnd
	call BattleScript_ItemRestoreHPRet
BattleScript_ItemRestoreHPEnd:
	end

BattleScript_ItemRestoreHP_Party::
	jumpifbyte CMP_EQUAL, gBattleCommunication, TRUE, BattleScript_ItemRestoreHP_SendOutRevivedBattler
	bichalfword gMoveResultFlags, MOVE_RESULT_NO_EFFECT
	printstring STRINGID_ITEMRESTOREDSPECIESHEALTH
	waitmessage B_WAIT_TIME_LONG
	end

BattleScript_ItemRestoreHP_SendOutRevivedBattler:
	switchinanim BS_SCRIPTING, FALSE
	waitstate
	switchineffects BS_SCRIPTING
	end

BattleScript_ItemCureStatus::
	call BattleScript_UseItemMessage
BattleScript_ItemCureStatusAfterItemMsg:
	itemcurestatus BattleScript_ItemCureStatusEnd
	updatestatusicon BS_SCRIPTING
	printstring STRINGID_ITEMCUREDSPECIESSTATUS
	waitmessage B_WAIT_TIME_LONG
BattleScript_ItemCureStatusEnd:
	end

BattleScript_ItemHealAndCureStatus::
	call BattleScript_UseItemMessage
	itemrestorehp BattleScript_ItemCureStatusAfterItemMsg
	call BattleScript_ItemRestoreHPRet
	goto BattleScript_ItemCureStatusAfterItemMsg

BattleScript_ItemIncreaseStat::
	call BattleScript_UseItemMessage
	itemincreasestat
	statbuffchange MOVE_EFFECT_AFFECTS_USER | STAT_CHANGE_NOT_PROTECT_AFFECTED | STAT_CHANGE_ALLOW_PTR, BattleScript_ItemEnd
	setgraphicalstatchangevalues
	playanimation BS_ATTACKER, B_ANIM_STATS_CHANGE, sB_ANIM_ARG1
	printfromtable gStatUpStringIds
	waitmessage B_WAIT_TIME_LONG
	end

BattleScript_ItemSetMist::
	call BattleScript_UseItemMessage
	setmist
	playmoveanimation BS_ATTACKER, MOVE_MIST
	waitanimation
	printfromtable gMistUsedStringIds
	waitmessage B_WAIT_TIME_LONG
	end

BattleScript_ItemSetFocusEnergy::
	call BattleScript_UseItemMessage
	jumpifstatus2 BS_ATTACKER, STATUS2_FOCUS_ENERGY_ANY, BattleScript_ButItFailed
	setfocusenergy
	playmoveanimation BS_ATTACKER, MOVE_FOCUS_ENERGY
	waitanimation
	copybyte sBATTLER, gBattlerAttacker
	printstring STRINGID_PKMNUSEDXTOGETPUMPED
	waitmessage B_WAIT_TIME_LONG
	end

BattleScript_ItemRestorePP::
	call BattleScript_UseItemMessage
	itemrestorepp
	printstring STRINGID_ITEMRESTOREDSPECIESPP
	waitmessage B_WAIT_TIME_LONG
	end

BattleScript_ItemIncreaseAllStats::
	call BattleScript_UseItemMessage
	call BattleScript_AllStatsUp
	end

BattleScript_TrainerBallBlock::
	waitmessage B_WAIT_TIME_LONG
	printstring STRINGID_TRAINERBLOCKEDBALL
	waitmessage B_WAIT_TIME_LONG
	printstring STRINGID_DONTBEATHIEF
	waitmessage B_WAIT_TIME_LONG
	finishaction

BattleScript_RunByUsingItem::
	playse SE_FLEE
	setbyte gBattleOutcome, B_OUTCOME_RAN
	finishturn

BattleScript_TrainerASlideMsgRet::
	handletrainerslidemsg BS_SCRIPTING, 0
	trainerslidein B_POSITION_OPPONENT_LEFT
	handletrainerslidemsg BS_SCRIPTING, 1
	waitstate
	trainerslideout B_POSITION_OPPONENT_LEFT
	waitstate
	handletrainerslidemsg BS_SCRIPTING, 2
	return

BattleScript_TrainerASlideMsgEnd2::
	call BattleScript_TrainerASlideMsgRet
	end2

BattleScript_TrainerBSlideMsgRet::
	handletrainerslidemsg BS_SCRIPTING, 0
	trainerslidein B_POSITION_OPPONENT_RIGHT
	handletrainerslidemsg BS_SCRIPTING, 1
	waitstate
	trainerslideout B_POSITION_OPPONENT_RIGHT
	waitstate
	handletrainerslidemsg BS_SCRIPTING, 2
	return

BattleScript_TrainerBSlideMsgEnd2::
	call BattleScript_TrainerBSlideMsgRet
	end2
