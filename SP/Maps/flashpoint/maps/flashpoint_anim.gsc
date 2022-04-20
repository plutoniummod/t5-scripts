////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL SCRIPTS
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include maps\_utility;
#include maps\_anim;
#include common_scripts\utility; 
#include maps\flashpoint_util;

////////////////////////////////////////////////////////////////////////////////////////////
// MAIN FUNCTION
////////////////////////////////////////////////////////////////////////////////////////////
main()
{
	ai_anims();
	player_anims();
	flashpoint_anims();
	prop_anims();
	setup_vo();
}


#using_animtree ("generic_human");
ai_anims()
{
	//-- ANIMS
	
	level.scr_anim["ai_flashpoint_jump_down_330"]		= %ai_flashpoint_jump_down_330;
	
	//-- Woods
	level.scr_anim["woods"]["run_fast"]					= %ai_barnes_run_f_v2;
	level.scr_anim["woods"]["before_binoc_wait_idle"][0] = %ch_flash_ev01_woods_wait_idle;
	level.scr_anim["woods"]["binocular_give"]			= %ch_flash_ev01_woodswalktogivebinocular;
	maps\_anim::addNotetrack_attach( "woods", "binoc_attach", "viewmodel_binoculars", "TAG_WEAPON_LEFT", "binocular_give" );
	level.scr_anim["woods"]["binocular_give_loop"][0]	= %ch_flash_ev01_woodsgivesbinoculars_loop;
	level.scr_anim["woods"]["binocular_handoff"] = %ch_flash_ev01_woodsgivesbinoculars;
	level.scr_anim["woods"]["binocular_end"]			= %ch_flash_b01_barnes;
	
	/* 
	//NEW BINOCULARS ANIMS FOR WOODS
	//depot/projects/cod/t5/xanim_export/scripted/flashpoint/ch_flash_ev01_woods_wait_idle.XANIM_EXPORT#2 edit
	//depot/projects/cod/t5/xanim_export/scripted/flashpoint/ch_flash_ev01_woods_walk_to_wait.XANIM_EXPORT#2 edit
	*/
	
	

	//-- Dump Guards
	//level.scr_anim["dump_guard"]["standA"][0]			= %ch_flash_b01_standingguardA;
	//level.scr_anim["dump_guard"]["standB"][0]			= %ch_flash_b01_standingguardB;
	//level.scr_anim["dump_guard"]["death"][0]			= %ai_death_collapse_in_place;
	//level.scr_anim["dump_guard"]["dead"][0]				= %ch_khe_E1C_deadsoldiers_guy01;
	
	//-- Squad
	level.scr_anim["brooks"]["run_fast"]				= %ai_barnes_run_f_v2;
	level.scr_anim["bowman"]["run_fast"]				= %ai_barnes_run_f_v2;
	level.scr_anim["weaver"]["run_fast"]				= %ai_barnes_run_f_v2;
	
	//-- Tire Changing meetup anims
	level.scr_anim["brooks"]["tirechange_brooks"]		= %ch_flash_ev03_tire_change_brooks;
	level.scr_anim["bowman"]["tirechange_bowman"]		= %ch_flash_ev03_tire_change_bowman;
	addNotetrack_customFunction( "bowman", "start_woods_anim", maps\flashpoint_e3::woods_tirechange, "tirechange_bowman" );
	
	level.scr_anim["rus1_tire"]["tirechange_spetz1"]	= %ch_flash_ev03_tire_change_spetz1;
	level.scr_anim["rus2_tire"]["tirechange_spetz2"]	= %ch_flash_ev03_tire_change_spetz2;
	level.scr_anim["woods"]["tirechange_woods"]			= %ch_flash_ev03_tire_change_woods;
	
	
	//Intro A: Woods takes cover. Note: Snake animation is not included in this check-in
	level.scr_anim["woods"]["intro_a"]					= %ch_flash_ev01_intro_a_woods;
	
	//Intro B: Woods kills the soldier
// 	level.scr_anim["guard"]["intro_b"]					= %ch_flash_ev01_intro_b_russian;
// 	level.scr_anim["woods"]["intro_b"]					= %ch_flash_ev01_intro_b_woods;
	
	//First stop in the fuselage of Flashpoint
	level.scr_anim["woods"]["aboutotlaunch_wait"][0]	= %ch_flash_ev01_aboutlaunch_idle_woods;
	level.scr_anim["woods"]["aboutotlaunch"]			= %ch_flash_ev01_aboutotlaunch_woods;
	maps\_anim::addNotetrack_customFunction( "woods", "block_off", maps\flashpoint_e1::remove_blocker, "aboutotlaunch" );
	
	//Weaver eye stab
	level.scr_anim["krav"]["eye_stab_krav"]					= %ch_flash_ev01_poi_weaver_stab_krav;
	level.scr_anim["weaver"]["eye_stab_weaver"]				= %ch_flash_ev01_poi_weaver_stab_weaver;
	maps\_anim::addNotetrack_customFunction( "weaver", "sndnt#vox_fla1_s01_032A_weav_f_m", maps\flashpoint_fx::weaver_eye_blood, "eye_stab_weaver" );
	maps\_anim::addNotetrack_attach( "krav", "attach_radio", "t5_weapon_radio_world", "TAG_WEAPON_LEFT", "eye_stab_krav" );
	maps\_anim::addNotetrack_detach( "krav", "detach_radio", "t5_weapon_radio_world", "TAG_WEAPON_LEFT", "eye_stab_krav" );
	//maps\_anim::addNotetrack_attach( "krav", "attach_karambit", "t5_knife_karambit", "TAG_WEAPON_RIGHT", "eye_stab_krav" );
	maps\_anim::addNotetrack_attach( "krav", "attach_karambit", "t5_knife_karambit_world", "TAG_WEAPON_RIGHT", "eye_stab_krav" );
	
	//Hide at pipe
	level.scr_anim["woods"]["hide_at_pipe_idle"][0]		= %casual_crouch_idle;
	level.scr_anim["woods"]["hide_at_pipe_idle_single"]		= %casual_crouch_idle;
	level.scr_anim["woods"]["hide_at_pipe"]				= %ch_flash_ev02_down_behind_pipe_idle_to_walk_woods;
	
	//Vault over pipe
	level.scr_anim["woods"]["vault_over_pipe"]			= %ch_flash_ev02_vault_over_pipe_woods;

	//Karambit sequence: Includes the dragging body animation
	level.scr_anim["woods"]["karambit_intro_woods"]		= %ch_flash_ev03_karambit_into_cover_woods;	
	level.scr_anim["woods"]["karambit_wait_woods"][0]	= %ch_flash_ev03_karambit_into_cover_idle_woods;	
	level.scr_anim["woods"]["karambit_attack_woods"]	= %ch_flash_ev03_karambit_attack_woods;
	maps\_anim::addNotetrack_customFunction( "woods", "start_run", ::notify_start_run, "karambit_attack_woods" );
	
	level.scr_anim["woods"]["karambit_idle_woods"][0]		= %ch_flash_ev03_karambit_idle_woods;	
	level.scr_anim["woods"]["karambit_drag_woods"]			= %ch_flash_ev03_karambit_drag_body_woods;
	level.scr_anim["woods"]["karambit_drag_wait_woods"][0]	= %ch_flash_ev03_karambit_wait_idle_woods;
	maps\_anim::addNotetrack_customFunction( "woods", "tarp", ::notify_tarp, "karambit_drag_woods" );
		
	level.scr_anim["guard1"]["karambit_intro_guard1"]		= %ch_flash_ev03_karambit_patrolwalk_soldier1;
	level.scr_anim["guard1"]["karambit_wait_guard1"][0]		= %ch_flash_ev03_karambit_idle_soldier1;
	level.scr_anim["guard1"]["karambit_attack_guard1"]		= %ch_flash_ev03_karambit_attack_soldier1;
	level.scr_anim["guard1"]["karambit_dead_guard1"][0]		= %ch_flash_ev03_karambit_dead_idle_soldier1;
	level.scr_anim["guard1"]["karambit_drag_guard1"]		= %ch_flash_ev03_karambit_dragged_soldier1;
	
	level.scr_anim["guard2"]["karambit_intro_guard2"]		= %ch_flash_ev03_karambit_patrolwalk_soldier2;
	level.scr_anim["guard2"]["karambit_wait_guard2"][0]		= %ch_flash_ev03_karambit_idle_soldier2;
	level.scr_anim["guard2"]["karambit_attack_guard2"]			= %ch_flash_ev03_karambit_attack_soldier2;
	level.scr_anim["guard2"]["karambit_attack_wait_guard2"][0]	= %ch_flash_ev03_karambit_aim_idle_soldier2;
	level.scr_anim["guard2"]["karambit_dead_guard2"][0]		= %ch_flash_ev03_karambit_dead_idle_soldier2;

	level.scr_anim["guard2"]["carry_idle_guard2"][0]		= %ai_hide_body_idle;
	level.scr_anim["guard2"]["carry_walk_guard2"][0]		= %ai_hide_body_walk;
	level.scr_anim["guard2"]["carry_drop_guard2"]			= %ai_hide_body_drop;
	
	//In disguise
	level.scr_anim["woods"]["in_disguise"]				= %ch_flash_ev03_inspect_sewers_woods;
	addNotetrack_customFunction( "woods", "start soldier anim", ::notify_start_soldier_anim , "in_disguise");
	
	level.scr_sound["mason"]["fucking_better"] = "vox_fla1_s03_700A_maso_m"; //Well fucking better. We've gotta save Weaver.

    level.scr_sound["mason"]["on_it"] = "vox_fla1_s05_099A_maso"; //On it.

    level.scr_sound["mason"]["bowman_brooks"] = "vox_fla1_s06_900A_maso"; //I see Brooks and Bowman down there.


    level.scr_sound["mason"]["weaver_breach"] = "vox_fla1_s06_707A_maso_m"; //Weaver!


    level.scr_sound["bowman"]["xray_comein"] = "vox_fla1_s06_105A_bowm_f"; //X-ray come in, over.
    level.scr_sound["woods"]["go_ahead_bowman"] = "vox_fla1_s06_106A_wood_f"; //Go ahead, Bowman.
	level.scr_sound["bowman"]["weaver_visual"] = "vox_fla1_s06_107A_bowm_f"; //We just got a visual on Weaver... He's been taken to a bunker South of the Comms building.

	//Whats that noise sequence 
	level.scr_anim["guard3"]["whats_that_noise_g3"]		= %ch_flash_ev03_whats_that_noise_spetz1;
	level.scr_anim["guard4"]["whats_that_noise_g4"]		= %ch_flash_ev03_whats_that_noise_spetz2;
	level.scr_anim["woods"]["whats_that_noise_woods"]	= %ch_flash_ev03_whats_that_noise_woods;
	
	//No Russian walk
	level.scr_anim[ "generic" ][ "no_russian" ]			= %ch_flash_ev04_walkingrail_loop_soldier1;

	//Make it quick
	level.scr_anim["woods"]["make_it_quick_a"]			= %ch_flash_ev06_make_it_quick_woods; //-- tell the player to come over
	//level.scr_anim["woods"]["make_it_quick_b"][0]		= %ch_flash_ev06_make_it_quick_idle_woods;  //-- don't need
	//level.scr_anim["woods"]["make_it_quick_c"]		= %ch_flash_ev06_make_it_quick_handoff; //-- don't need
	level.scr_anim["woods"]["make_it_quick_d"][0]		= %ch_flash_ev06_make_it_quick_handoff_idle_woods; //-- idle with the crossbow out
	level.scr_anim["woods"]["make_it_quick_e"]			= %ch_flash_ev06_make_it_quick_secure_line_woods; //-- woods handing off the crossbow
	addNotetrack_customFunction( "woods", "lock_player", ::notify_player_lock_crossbow_pos, "make_it_quick_a");
	
	//Comms building
	level.scr_anim["sniper"]["l_idle"][0]				= %ch_flash_ev06_sniper_l_idle;
	level.scr_anim["sniper"]["l_in"]					= %ch_flash_ev06_sniper_l_in;
	level.scr_anim["sniper"]["l_out"]					= %ch_flash_ev06_sniper_l_out;
	level.scr_anim["sniper"]["r_idle"][0]				= %ch_flash_ev06_sniper_r_idle;
	level.scr_anim["sniper"]["r_in"]					= %ch_flash_ev06_sniper_r_in;
	level.scr_anim["sniper"]["r_out"]					= %ch_flash_ev06_sniper_r_out;
	
	//Bunker scientists
	level.scr_anim["scientist"]["cower"][0]				= %ai_civ_gen_cower_stand_idle;
	
	//Base activity
	//All of the anims except for the spetz3 group are attached to the node near the two trucks around viewpos (-100 -494 300)			"8b"
	//The spetz3 anim group is attached to the node at the staircase around viewpos (-1187 20 412)										"9"
	level.scr_anim["soldier"]["base_spetz_crate"][0]	= %ch_flash_ev03_base_activity_spetz_crate;
	level.scr_anim["soldier"]["base_spetz_truck1a"][0]	= %ch_flash_ev03_base_activity_spetz_truck1a;
	level.scr_anim["soldier"]["base_spetz_truck1b"][0]	= %ch_flash_ev03_base_activity_spetz_truck1b;
	level.scr_anim["soldier"]["base_spetz1a"][0]		= %ch_flash_ev03_base_activity_spetz1a;
	level.scr_anim["soldier"]["base_spetz1b"][0]		= %ch_flash_ev03_base_activity_spetz1b;
	
	level.scr_anim["soldier"]["base_spetz2a"][0]		= %ch_flash_ev03_base_activity_spetz2a;
	level.scr_anim["soldier"]["base_spetz2b"][0]		= %ch_flash_ev03_base_activity_spetz2b;
	
	level.scr_anim["soldier"]["base_spetz3a"][0]		= %ch_flash_ev03_base_activity_spetz3a;
	level.scr_anim["soldier"]["base_spetz3b"][0]		= %ch_flash_ev03_base_activity_spetz3b;
	level.scr_anim["soldier"]["base_spetz3c"][0]		= %ch_flash_ev03_base_activity_spetz3c;
	
	level.scr_anim["soldier"]["base_spetzalert1a"][0]	= %ch_flash_ev03_base_activity_spetzalert1a;
	level.scr_anim["soldier"]["base_spetzalert1b"][0]	= %ch_flash_ev03_base_activity_spetzalert1b;
	
	level.scr_anim["soldier"]["base_spetz_alert1"][0]	= %ch_flash_ev03_base_activity_spetz_alertidle1;
	level.scr_anim["soldier"]["base_spetz_idle1"][0]	= %ch_flash_ev03_base_activity_spetz_idle1;

	level.scr_anim["soldier"]["base_spetz_idle2"][0]	= %ch_flash_ev03_base_activity_spetz_idle2;
	level.scr_anim["soldier"]["base_spetz_idle3"][0]	= %ch_flash_ev03_base_activity_spetz_idle3;
	level.scr_anim["soldier"][ "patrol_walk" ]			= %patrol_bored_patrolwalk;
	
	//AI at base start gate
	level.scr_anim["soldier"]["base_start_a"]			= %ch_flash_ev04_guardswalking_guard01;
	level.scr_anim["soldier"]["base_start_idle_a"][0]	= %ch_flash_ev04_guardswalking_guard01_idle;
	level.scr_anim["soldier"]["base_start_b"]			= %ch_flash_ev04_guardswalking_guard02;
	level.scr_anim["soldier"]["base_start_idle_b"][0]	= %ch_flash_ev04_guardswalking_guard02_idle;
	level.scr_anim["soldier"]["base_start_c"]			= %ch_flash_ev04_guardswalking_guard03;
	level.scr_anim["soldier"]["base_start_idle_c"][0]	= %ch_flash_ev04_guardswalking_guard03_idle;


	//Play it cool
	//spetz2 ends on Run Gun Down pose for AI run, spetz1 disappears out of sight
	//node anims are attached to is the one around viewpos (704 -660 309) at the bend in the road										"8"
	//level.scr_anim["woods"]["play_it_cool"]			= %ch_flash_ev04_play_it_cool_woods;
	//level.scr_anim["bowman"]["play_it_cool"]			= %ch_flash_ev04_play_it_cool_bowman;
	level.scr_anim["soldier1"]["play_it_cool"]			= %ch_flash_ev04_play_it_cool_spetz1;
	level.scr_anim["soldier2"]["play_it_cool"]			= %ch_flash_ev04_play_it_cool_spetz2;
	maps\_anim::addNotetrack_customFunction( "soldier1", "Sndnt#vox_fla1_s04_087A_sgu2", ::notify_playitcool_dialog, "play_it_cool" );
	maps\_anim::addNotetrack_customFunction( "soldier2", "Sndnt#vox_fla1_s04_087A_sgu2", ::notify_playitcool_dialog, "play_it_cool" );

 	//Three become one
 	level.scr_anim["brooks"]["reduced_to_one_brooks_idle"][0]	= %ch_flash_b04_reduced2one_friend1_idle;
 	level.scr_anim["brooks"]["reduced_to_one_brooks"]			= %ch_flash_b04_reduced2one_friend1; 
 	//On friend 1’s notetrack there is a note called “start_guards”.  More on that in a moment.
 	maps\_anim::addNotetrack_customFunction( "brooks", "guard_start", ::notify_start_guards, "reduced_to_one_brooks" );
 	//Okay, this has a notetrack called “group_gone” on friend1.  That should do ya.
 	maps\_anim::addNotetrack_customFunction( "brooks", "sndnt#vox_fla1_s04_095A_bowm", ::notify_group_gone, "reduced_to_one_brooks" );
 	
 	level.scr_anim["bowman"]["reduced_to_one_bowman_idle"][0]	= %ch_flash_b04_reduced2one_friend2_idle;
 	level.scr_anim["bowman"]["reduced_to_one_bowman"]			= %ch_flash_b04_reduced2one_friend2;
 	
 	level.scr_anim["guard1"]["reduced_to_one_start_guard1"][0]	= %ch_flash_b04_reduced2one_guard1_idle;
 	level.scr_anim["guard1"]["reduced_to_one_guard1"]			= %ch_flash_b04_reduced2one_guard1_action;
 	level.scr_anim["guard1"]["reduced_to_one_end_guard1"][0]	= %ch_flash_b04_reduced2one_guard1_deadloop;
 	
 	level.scr_anim["guard2"]["reduced_to_one_start_guard2"][0]	= %ch_flash_b04_reduced2one_guard2_idle;
 	level.scr_anim["guard2"]["reduced_to_one_guard2"]			= %ch_flash_b04_reduced2one_guard2_action;
 	level.scr_anim["guard2"]["reduced_to_one_end_guard2"][0]	= %ch_flash_b04_reduced2one_guard2_deadloop;
 	
 	
 	level.scr_anim["woods"]["reduced_to_one_idle"]				= %ch_flash_ev04_reduced_to_one_woods_idle;
 	level.scr_anim["woods"]["reduced_to_one_doorkick_trans"]	= %ch_flash_ev04_comm_link_woods_trans_in;
 	level.scr_anim["woods"]["reduced_to_one_doorkick"]			= %ch_flash_ev04_comm_link_woods;
 	


 	level.scr_anim["limo_driver"]["burning_driver"]				= %ch_flash_ev16_limo_burning_guy_driver;
 	level.scr_anim["limo_passenger"]["burning_passenger"]		= %ch_flash_ev16_limo_burning_guy_passenger;

	// Burning guys
	level.scr_anim["napalm_victim_1"]["burning_fate"] = %ai_flame_death_a;
	level.scr_anim["napalm_victim_2"]["burning_fate"] = %ai_flame_death_b;
	level.scr_anim["napalm_victim_3"]["burning_fate"] = %ai_flame_death_c;
	level.scr_anim["napalm_victim_4"]["burning_fate"] = %ai_flame_death_d;
	
	
	
	//diorama01
	level.scr_anim["mason"]["diorama01"] = %ch_flash_diorama01_mason;
	level.scr_anim["vc"]["diorama01"] = %ch_flash_diorama01_vc;
	level.scr_anim["weaver"]["diorama01"] = %ch_flash_diorama01_weaver;
	level.scr_anim["woods"]["diorama01"] = %ch_flash_diorama01_woods;

	//diorama02
	level.scr_anim["woods"]["diorama02"] = %ch_flash_diorama02_woods;

	
	//diorama06
	level.scr_anim["guard_1"]["diorama06"] = %ch_flash_diorama06_guard01;
	level.scr_anim["guard_2"]["diorama06"] = %ch_flash_diorama06_guard02;
	level.scr_anim["guard_3"]["diorama06"] = %ch_flash_diorama06_guard03;
	level.scr_anim["guard_4"]["diorama06"] = %ch_flash_diorama06_guard04;
	level.scr_anim["krav_slide"]["diorama06"] = %ch_flash_diorama06_krav;
	level.scr_anim["krav_guard_1"]["diorama06"] = %ch_flash_diorama06_kravguard01;
	level.scr_anim["krav_guard_2"]["diorama06"] = %ch_flash_diorama06_kravguard02;
	level.scr_anim["krav_guard_3"]["diorama06"] = %ch_flash_diorama06_kravguard03;

	
    level.scr_sound["bowman"]["pinned"] = "vox_fla1_s06_376A_bowm_f_m"; //Enemy moving in from the North - We're pinned down!

 	//Woods comms building
//  	level.scr_anim["woods"]["action_a_flr1"]	= %ch_flash_ev05_woods_keyboard_action_a_floor_01;
//  	level.scr_anim["woods"]["action_a_flr2"]	= %ch_flash_ev05_woods_keyboard_action_a_floor_02;
//  	level.scr_anim["woods"]["action_a_flr3"]	= %ch_flash_ev05_woods_keyboard_action_a_floor_03;
//  	
//  	level.scr_anim["woods"]["action_b_flr1"]	= %ch_flash_ev05_woods_keyboard_action_b_floor_01;
//  	level.scr_anim["woods"]["action_b_flr2"]	= %ch_flash_ev05_woods_keyboard_action_b_floor_02;
//  	level.scr_anim["woods"]["action_b_flr3"]	= %ch_flash_ev05_woods_keyboard_action_b_floor_03;
//  	
//  	level.scr_anim["woods"]["idle_flr1"][0]		= %ch_flash_ev05_woods_keyboard_idle_floor_01;
//  	level.scr_anim["woods"]["idle_flr2"][0]		= %ch_flash_ev05_woods_keyboard_idle_floor_02;
//  	level.scr_anim["woods"]["idle_flr3"][0]		= %ch_flash_ev05_woods_keyboard_idle_floor_03;
 	
 	
/*
FRAME 198 "sndnt#vox_fla1_s05_096A_wood_m"
FRAME 230 "sndnt#vox_fla1_s05_097A_wood_m"
FRAME 311 "sndnt#vox_fla1_s05_098A_wood_m"
*/
 	
 	//I included a note on the notetrack called “door_kick” which is when his foot connects with the door.  You can start busting it open from there.
 	maps\_anim::addNotetrack_customFunction( "woods", "door_bash", ::notify_door_kick, "reduced_to_one_doorkick" );
 	
 	
//Comms building STEALTH

//Floor 1
 	
 	// anim node = "comm_3"
  	level.scr_anim["comms_flr1_orange"]["runs_up_stairs"]	= %ai_comms_floor1_orange_idle;//ch_flash_b05_guard_runs_away;
 // new anim to use-> 	ai_comms_floor1_orange_idle
  	
 	// anim node = "comm_2"
 	level.scr_anim["comms_flr1_blue"]["idle"][0]			= %ai_comms_floor1_blue_idle;				//Pushing buttons – loop
	level.scr_anim["comms_flr1_blue"]["to_door"]			= %ai_comms_floor1_blue_idle_2_inspect;		//To doorway
	level.scr_anim["comms_flr1_blue"]["door_idle"][0]		= %ai_comms_floor1_blue_inspect_idle;		//Idling, looking towards doorway – loop, in case dialogue is long
	level.scr_anim["comms_flr1_blue"]["from_door"]			= %ai_comms_floor1_blue_inspect_2_idle;		//Back to idle position from doorway check

	// anim node = "comm_1"
	level.scr_anim["comms_flr1_green"]["idle"][0]			= %ai_comms_floor1_green_idle;				//Idle in chair
	level.scr_anim["comms_flr1_green"]["alert"]				= %ai_comms_floor1_green_idle_2_alert;		//Alerted to player
	
	// anim node = "comm_1"
	level.scr_anim["comms_flr1_new"]["idle"][0]				= %ai_comms_floor1_tapemachine_idle;				//Idle in chair
	level.scr_anim["comms_flr1_new"]["alert"]				= %ai_comms_floor1_tapemachine_idle_2_alert;		//Alerted to player
	



//Floor 2
 
// 	//BLUE GUY
// 	level.scr_anim["comms_flr2_blue"]["ack"]				= %ai_comms_floor2_blue_acknowledge;		//guy nods at player, can use prop_comms_floor2_blue_idle_chair for the chair
// 	level.scr_anim["comms_flr2_blue"]["idle"][0]			= %ai_comms_floor2_blue_idle;
// 
// 	level.scr_anim["comms_flr2_blue"]["alert"]				= %ai_comms_floor2_blue_idle_2_alert;		//Alerted by player:
// 
// 	level.scr_anim["comms_flr2_blue"]["left_in"]			= %ai_comms_floor2_blue_turn_2_left;		//Turn left, left idle, back to facing front;
// 	level.scr_anim["comms_flr2_blue"]["left_idle"][0]		= %ai_comms_floor2_blue_left_idle;
// 	level.scr_anim["comms_flr2_blue"]["left_out"]			= %ai_comms_floor2_blue_left_2_front;
// 
// 	level.scr_anim["comms_flr2_blue"]["right_in"]			= %ai_comms_floor2_blue_turn_2_right;		//Turn right, right idle, back to facing front;
// 	level.scr_anim["comms_flr2_blue"]["right_idle"][0]		= %ai_comms_floor2_blue_right_idle;
// 	level.scr_anim["comms_flr2_blue"]["right_out"]			= %ai_comms_floor2_blue_right_2_front;
// 
// 	level.scr_anim["comms_flr2_blue"]["back_in"]			= %ai_comms_floor2_blue_turn_2_back;		//Turn to back, back idle, back to facing front;
// 	level.scr_anim["comms_flr2_blue"]["back_idle"][0]		= %ai_comms_floor2_blue_back_idle;
// 	level.scr_anim["comms_flr2_blue"]["back_out"]			= %ai_comms_floor2_blue_back_2_front;
// 
// 	//GREEN GUY
// 	level.scr_anim["comms_flr2_green"]["idle"][0]			= %ai_comms_floor2_green_idle;				//(notetrack “dialog” for using intercom)
// 	level.scr_anim["comms_flr2_green"]["alert"]				= %ai_comms_floor2_green_idle_2_alert;		//Idle to alert:
// 
// 	//ORANGE GUY
// 	level.scr_anim["comms_flr2_orange"]["idle"][0]			= %ai_comms_floor2_orange_idle;
// 	level.scr_anim["comms_flr2_orange"]["alert"]			= %ai_comms_floor2_orange_idle_2_alert;		//Idle to alert:
// 
// 	//PURPLE GUY
// 	level.scr_anim["comms_flr2_purple"]["idle"][0]			= %ai_comms_floor2_purple_idle;
// 	level.scr_anim["comms_flr2_purple"]["alert"]			= %ai_comms_floor2_purple_idle_2_alert;		//Idle to alert:

//Floor 3	
// 
// 	//GREEN GUY
// 	level.scr_anim["comms_flr3_green"]["idle"][0]			= %ai_comms_floor3_green_idle;
// 	level.scr_anim["comms_flr3_green"]["alert"]				= %ai_comms_floor3_green_idle_2_alert;		//Idle to alert:
// 
// 	//ORANGE GUY
// 	level.scr_anim["comms_flr3_orange"]["idle"][0]			= %ai_comms_floor3_orange_idle;
// 	level.scr_anim["comms_flr3_orange"]["alert"]			= %ai_comms_floor3_orange_idle_2_alert;		//Idle to alert:
// 
// 	//BLUE GUY
// 	level.scr_anim["comms_flr3_blue"]["intro"][0]			= %ai_comms_floor3_blue_idle_intro_loop;	//Intro idle (loopable) + traversal down to landing
// 	level.scr_anim["comms_flr3_blue"]["walkdown"]			= %ai_comms_floor3_blue_walk_downstairs;
// 	level.scr_anim["comms_flr3_blue"]["melee_wnd"]			= %ai_comms_floor3_blue_custom_melee_window;
// 	level.scr_anim["comms_flr3_blue"]["walkup"]				= %ai_comms_floor3_blue_walk_upstairs;		//Traversal back up, new loopable idle at top of stairs
// 	level.scr_anim["comms_flr3_blue"]["outloop"][0]			= %ai_comms_floor3_blue_idle_outtro_loop;

	
//Roof	

// 	//GREEN GUY
//  	level.scr_anim["comms_flr4_green"]["idle"][0]			= %ai_comms_floor4_green_idle;
// 
// 	//ORANGE GUY
 	level.scr_anim["comms_flr4_orange"]["idle"][0]			= %ai_comms_floor4_orange_idle;
 	level.scr_anim["comms_flr4_orange"]["alert"]			= %ai_comms_floor4_orange_idle_2_alert;		//Idle to alert:
// 
// 	//BLUE GUY
// 	level.scr_anim["comms_flr4_blue"]["turncorner"]			= %ai_comms_floor4_blue_idle_turncorner;
// 	level.scr_anim["comms_flr4_blue"]["alert"]				= %ai_comms_floor4_blue_idle_2_alert;		//Idle to alert:

//Roof
//blue "comm_12"
//orange "comm_11"
//green "comm_13"




//Comms building STEALTH
 	
 	
	//Weaver building pre-rescue
	level.scr_anim["guard1"]["wnd_idle"][0]				= %ch_flash_ev06_stunnedguard_guardbywindow_idle;
	level.scr_anim["guard1"]["looptoidle"]				= %ch_flash_ev06_stunnedguard_guardbywindow_looptoidle;
	level.scr_anim["guard1"]["pacingloop"][0]			= %ch_flash_ev06_stunnedguard_guardbywindow_pacingloop;
	level.scr_anim["guard1"]["reaction"]				= %ch_flash_ev06_stunnedguard_guardbywindow_reaction;
	
	//Woods on comms building roof
	level.scr_anim["woods"]["ladderidle"][0]			= %ch_flash_ev06_woodsladderattack_woods_idle;
	level.scr_anim["woods"]["ladderkick"]				= %ch_flash_ev06_woodsladderattack_woods;
	level.scr_anim["enemy"]["ladderkick"]				= %ch_flash_ev06_woodsladderattack_enemy;
	
	//Weaver rescue

	level.scr_anim["guard2"]["weaver_breach_wait2"][0]	= %ch_flash_ev06_weaverrescue_guard_idle;
	level.scr_anim["guard2"]["weaver_breach2"]			= %ch_flash_ev06_weaverrescue_guard_act;	

	level.scr_anim["weaver"]["weaver_breach_wait"][0]	= %ch_flash_ev06_weaverrescue_weaver_idle;
	level.scr_anim["weaver"]["weaver_breach"]			= %ch_flash_ev06_weaverrescue_weaver_act;	
	
	level.scr_anim["guard1"]["weaver_breach_wait1"][0]	= %ch_flash_ev06_stunnedguard_guardbywindow;
	level.scr_anim["guard1"]["weaver_breach1"]			= %ch_flash_ev06_stunnedguard_guardbywindow;

	
/*
ch_flash_ev06_weaverrescue_guard_act
ch_flash_ev06_weaverrescue_guard_idle
ch_flash_ev06_weaverrescue_weaver_act
ch_flash_ev06_weaverrescue_weaver_idle
*/
	
	//Rescue section
	level.scr_anim["bowman"]["weaver_rescue_bowman"]	= %ch_flash_ev06_stilltime_bowman;
	level.scr_anim["woods"]["weaver_rescue_woods"]		= %ch_flash_ev06_stilltime_woods;
	level.scr_anim["weaver"]["weaver_rescue"]			= %ch_flash_ev06_stilltime_weaver;
	level.scr_anim["brooks"]["weaver_rescue_brooks"]	= %ch_flash_ev06_stilltime_brooks;
	maps\_anim::addNotetrack_customFunction( "brooks", "door_open", ::notify_weaver_rescue_door_open, "weaver_rescue_brooks" );
	maps\_anim::addNotetrack_customFunction( "brooks", "start_woodsbowman", ::notify_weaver_rescue_start_woodsbowman, "weaver_rescue_brooks" );
	maps\_anim::addNotetrack_customFunction( "brooks", "door_bash", ::notify_weaver_rescue_door_bash, "weaver_rescue_brooks" );
	maps\_anim::addNotetrack_customFunction( "woods", "door_shut", ::notify_weaver_rescue_door_close, "weaver_rescue_woods" );
	//maps\_anim::addNotetrack_customFunction( "weaver", "studio_cut", ::notify_weaver_rescue_door_close, "weaver_rescue_woods" );


	//Over ledge vault
	level.scr_anim["bowman"]["vault_wall_bowman"]	= %ch_flash_ev06_squad_vault_wall_bowman;
	level.scr_anim["woods"]["vault_wall_woods"]		= %ch_flash_ev06_squad_vault_wall_woods;
	level.scr_anim["weaver"]["vault_wall_weaver"]	= %ch_flash_ev06_squad_vault_wall_weaver;
	level.scr_anim["brooks"]["vault_wall_brooks"]	= %ch_flash_ev06_squad_vault_wall_brooks;
			
	//Scientists up the stairs
	level.scr_anim["scientist"]["up_the_stairs1"]		= %ch_flash_ev07_workers_upthestairs_wkr1;
	level.scr_anim["scientist"]["up_the_stairs2"]		= %ch_flash_ev07_workers_upthestairs_wkr2;
	level.scr_anim["scientist"]["up_the_stairs3"]		= %ch_flash_ev07_workers_upthestairs_wkr3;
	level.scr_anim["scientist"]["up_the_stairs4"]		= %ch_flash_ev07_workers_upthestairs_wkr4;
	level.scr_anim["scientist"]["up_the_stairs5"]		= %ch_flash_ev07_workers_upthestairs_wkr5;
	
	//No matter what happens - pre explosion
	level.scr_anim["weaver"]["c4_start"]				= %ch_flash_b08_nomatterwhat_weaver_speech;
	level.scr_anim["weaver"]["c4_wait"][0]				= %ch_flash_b08_nomatterwhat_weaver_waitloop;
	level.scr_anim["woods"]["c4_start"]					= %ch_flash_b08_nomatterwhat_woods_speech;
	level.scr_anim["woods"]["c4_wait"][0]				= %ch_flash_b08_nomatterwhat_woods_waitloop;
	
	//level.scr_anim["bowman"]["c4_wait"][0]				= %ch_flash_b08_nomatterwhat_brooks_guardloop;
	//level.scr_anim["brooks"]["c4_wait"][0]				= %ch_flash_b08_nomatterwhat_bowman_stairguard;
	level.scr_anim["bowman"]["c4_wait"][0]				= %ch_flash_b08_nomatterwhat_bowman_waitloop;
	level.scr_anim["brooks"]["c4_wait"][0]				= %ch_flash_b08_nomatterwhat_brooks_waitloop;

	//C4 Bunker scientists
	level.scr_anim["scientist1"]["c4_cower"][0]			= %ch_flash_b08_c4bunker_scientist1_cowerloop;
	level.scr_anim["scientist1"]["c4_react"]			= %ch_flash_b08_c4bunker_scientist1_explodereact;
	level.scr_anim["scientist1"]["c4_start"][0]			= %ch_flash_b08_c4bunker_scientist1_startloop;
	level.scr_anim["scientist2"]["c4_cower"][0]			= %ch_flash_b08_c4bunker_scientist2_cowerloop;
	level.scr_anim["scientist2"]["c4_react"]			= %ch_flash_b08_c4bunker_scientist2_explodereact;
	level.scr_anim["scientist2"]["c4_start"][0]			= %ch_flash_b08_c4bunker_scientist2_startloop;
	level.scr_anim["scientist3"]["c4_cower"][0]			= %ch_flash_b08_c4bunker_scientist3_cowerloop;
	level.scr_anim["scientist3"]["c4_react"]			= %ch_flash_b08_c4bunker_scientist3_explodereact;
	level.scr_anim["scientist3"]["c4_start"][0]			= %ch_flash_b08_c4bunker_scientist3_startloop;
	level.scr_anim["scientist4"]["c4_cower"][0]			= %ch_flash_b08_c4bunker_scientist4_cowerloop;
	level.scr_anim["scientist4"]["c4_react"]			= %ch_flash_b08_c4bunker_scientist4_explodereact;
	level.scr_anim["scientist4"]["c4_start"][0]			= %ch_flash_b08_c4bunker_scientist4_startloop;
	
/*
WEAVER           1.  Planb_weaver_startidle  (loops)
                 2.  planb_weaver_computer_work  (notetrack prompt on Woods)
                 3.  planb_weaver_endidle  (loops)

WOODS            1.  Woods_waitloop (from previous)
                 2.  planb_woods
                 3.  planb_launcher_wait_idle  (loops)

BOWMAN           1.  planb_bowman_guardloop  (after ai run)
                 2.  planb_bowman_guard2give
                 3.  planb_bowman_giveidle  (loop)
                 4.  planb_bowman_endguard  (loop)(after player has launcher)

BROOKS           1.  Brooks_guardloop  (from previous)
*/

	//Plan B
	//level.scr_anim["weaver"]["planb_start"][0]		= %ch_flash_b08_planb_weaver_startidle;				//plays at first node in building
	//level.scr_anim["weaver"]["planb_computer"]		= %ch_flash_b08_planb_weaver_computer_work;
	//level.scr_anim["weaver"]["planb_wait"][0]			= %ch_flash_b08_planb_weaver_endidle;
	
	level.scr_anim["weaver"]["planb_enterc4"]			= %ch_flash_ev08_weaverc4room_enter;
	maps\_anim::addNotetrack_customFunction( "weaver", "entered_c4", ::weaver_entered_c4, "planb_enterc4" );
	maps\_anim::addNotetrack_customFunction( "weaver", "plan_b", ::weaver_plan_b, "planb_enterc4" );

	//level.scr_anim["weaver"]["planb_exitc4"]			= %ch_flash_ev08_weaverc4room_terminal;

	level.scr_anim["woods"]["planb"]					= %ch_flash_b08_planb_woods;					
	level.scr_anim["woods"]["planb_wait"][0]			= %ch_flash_b08_planb_woods_launcher_wait_idle;

	//level.scr_anim["bowman"]["planb1"][0]				= %ch_flash_b08_planb_bowman_guardloop;	
	//level.scr_anim["bowman"]["planb2"]				= %ch_flash_b08_planb_bowman_guard2give;
	//level.scr_anim["bowman"]["planb3"][0]				= %ch_flash_b08_planb_bowman_giveidle;
	//level.scr_anim["bowman"]["planb4"]				= %ch_flash_b08_planb_bowman_move2endguard;
	//level.scr_anim["bowman"]["planb5"][0]				= %ch_flash_b08_planb_bowman_endguard_idle;

	//Watching rocket explode
	//level.scr_anim["woods"]["rocket_explode"]			= %ch_flash_b08_holyshit_woods_talkexit;
	//level.scr_anim["woods"]["rocket_explode_wait"][0]	= %ch_flash_b08_holyshit_woods_waitloop;
	
	//Slide under rocket piece
	level.scr_anim["woods"]["slidebeneath"]				= %ch_flash_ev08_slidebeneath_woods;
	level.scr_anim["bowman"]["slidebeneath"]			= %ch_flash_ev08_slidebeneath_bowman;
	level.scr_anim["brooks"]["slidebeneath"]			= %ch_flash_ev08_slidebeneath_woods;
	level.scr_anim["weaver"]["slidebeneath"]			= %ch_flash_ev08_slidebeneath_weaver;
	
	level.scr_anim["woods"]["jumpoverfire"]				= %ch_flash_ev08_jump_across;
	level.scr_anim["bowman"]["jumpoverfire"]			= %ch_flash_ev08_jump_across;
	level.scr_anim["brooks"]["jumpoverfire"]			= %ch_flash_ev08_jump_across;
	level.scr_anim["weaver"]["jumpoverfire"]			= %ch_flash_ev08_jump_across;
	
	
	//Animation cinematics workers on fire
	level.scr_anim["worker"]["onfire1"]					= %ch_flash_ev08_workersonfire_guy01;
	level.scr_anim["worker"]["onfire2"]					= %ch_flash_ev08_workersonfire_guy02;
	level.scr_anim["worker"]["onfire3"]					= %ch_flash_ev08_workersonfire_guy03;
	level.scr_anim["worker"]["onfire4"]					= %ch_flash_ev08_workersonfire_guy04;
	
	//No Sympathy
	//level.scr_anim["weaver"]["nosympathy"]				= %ch_flash_ev08_nosympathy_weaver;
	//level.scr_anim["woods"]["nosympathy"]				= %ch_flash_ev08_nosympathy_woods;
	
	//Steam reactions
	level.scr_anim["weaver"]["steamreactions"]			= %ch_flash_ev08_steamreactions_weaver;
	level.scr_anim["woods"]["steamreactions"]			= %ch_flash_ev08_steamreactions_woods;
	
	//Spetz custom combat anims
	level.scr_anim["spetz"]["onehanded"]				= %ch_flash_ev09_onehandedfire_spetznatz;
	maps\_anim::addNotetrack_customFunction( "spetz", "flip_table", ::flip_table_check, "onehanded" );
	
	//New vomit
	level.scr_anim["weaver"]["new_vomit"]				= %ch_flash_ev10_weavervomit_edit_weaver;
	maps\_anim::addNotetrack_customFunction( "weaver", "puke", maps\flashpoint_fx::weaver_vomit, "new_vomit" );

	//Gas start room
	level.scr_anim["weaver"]["gastrap_A"]				= %ch_flash_ev10_gastrap_weaver_A;
	level.scr_anim["weaver"]["gastrap_B"]				= %ch_flash_ev10_gastrap_weaver_B;
	level.scr_anim["weaver"]["gastrap_idle_A"][0]		= %ch_flash_ev10_gastrap_weaver_idle_A;
	level.scr_anim["weaver"]["gastrap_idle_B"][0]		= %ch_flash_ev10_gastrap_weaver_idle_B;
	level.scr_anim["weaver"]["gastrap_mantle"]			= %ch_flash_ev10_gastrap_weaver_mantlewindow;
	level.scr_anim["woods"]["gastrap_A_woods"]			= %ch_flash_ev10_gastrap_woods_A;
	level.scr_anim["woods"]["gastrap_B_woods"]			= %ch_flash_ev10_gastrap_woods_B;
	level.scr_anim["woods"]["gastrap_idle_A_woods"][0]	= %ch_flash_ev10_gastrap_woods_idle_A;
	level.scr_anim["woods"]["gastrap_idle_B_woods"][0]	= %ch_flash_ev10_gastrap_woods_idle_B;
	level.scr_anim["woods"]["gastrap_mantle_woods"]		= %ch_flash_ev10_gastrap_woods_mantlewindow;
	
	//Weaver vomit
	level.scr_anim["weaver"]["vomit"]					= %ch_flash_ev10_weavervomit_weaver;
	level.scr_anim["woods"]["vomit_woods"]				= %ch_flash_ev10_weavervomit_woods;
	
	//Scientists
// 	level.scr_anim["scientist"]["to_cower"]				= %ch_flash_ev11_scientistone;
// 	level.scr_anim["scientist"]["cowering"][0]			= %ch_flash_ev11_coweringscientist;
// 	level.scr_anim["spetz"]["barrel1"]					= %ch_flash_ev11_kickingbarrels_01;
// 	level.scr_anim["spetz"]["barrel2"]					= %ch_flash_ev11_kickingbarrels_02;
// 	level.scr_anim["scientist"]["backingup"]			= %ch_flash_ev11_scientist_two_backingup;
// 	level.scr_anim["scientist"]["panic"][0]				= %ch_flash_ev11_scientist_two_panicloop;
// 	level.scr_anim["scientist"]["suicide"]				= %ch_flash_ev11_scientist_two_suicide;
// 	level.scr_anim["scientist"]["escort"]				= %ch_flash_ev11_scientistescort_scientist;
// 	level.scr_anim["scientist"]["escortdeath"]			= %ch_flash_ev11_scientistescort_scientist_death;
// 	level.scr_anim["scientist"]["escortidle"][0]		= %ch_flash_ev11_scientistescort_scientist_idle;
// 	level.scr_anim["spetz"]["escort_spetz"]				= %ch_flash_ev11_scientistescort_spetznatz;
// 	
// 	//Rack of tapes
// 	level.scr_anim["spetz"]["racktapes"]				= %ch_flaspoint_e11_rack_of_tapes;
// 	maps\_anim::addNotetrack_customFunction( "spetz", "rack_fall", ::notify_rack_fall, "racktapes" );
// 	
// 	//Head Scientist	
// 	level.scr_anim["head"]["rungather"]					= %ch_flash_ev12_headscientist_runandgather;				//TODO
// 	level.scr_anim["head"]["run_b"]						= %ch_flash_ev12_headscientist_run_b;						//TODO	
// 	level.scr_anim["head"]["gather_loop"][0]			= %ch_flash_ev12_headscientist_gather_loop;					//TODO
// 	level.scr_anim["head"]["execute"]					= %ch_flash_ev12_scientistexecution_execute;				//TODO
// 	level.scr_anim["head"]["opendoor"]					= %ch_flash_ev12_scientistexecution_opendoor;				//TODO
// 	level.scr_anim["head"]["pleasedont"][0]				= %ch_flash_ev12_scientistexecution_pleasedontshoot_loop;	//TODO
// 	level.scr_anim["head"]["struggle"][0]				= %ch_flash_ev12_scientistexecution_struggledoor_loop;		//TODO
// 	level.scr_anim["head"]["turnaround"]				= %ch_flash_ev12_scientistexecution_struggleturnaround;		//TODO

	//BTR board
	level.scr_anim["woods"]["boardbtr"]					= %ch_flash_ev13_boardingbtr_woods;							//TODO
	level.scr_anim["weaver"]["boardbtr"]				= %ch_flash_ev13_boardingbtr_weaver;						//TODO
	level.scr_anim["bowman"]["boardbtr"]				= %ch_flash_ev13_boardingbtr_bowman;						//TODO
	level.scr_anim["brooks"]["boardbtr"]				= %ch_flash_ev13_boardingbtr_brooks;						//TODO

			
// OLD BELOW THIS LINE PJL
	

	//-- Casual Walk Anims
 	level.scr_anim[ "woods" ][ "casual_walk" ]				= %ch_flash_casual_walk_bowman;
 	level.scr_anim[ "bowman" ][ "casual_walk" ]				= %ch_flash_casual_walk_woods;
 	level.scr_anim[ "brooks" ][ "casual_walk" ]				= %ch_flash_casual_walk_woods;
 	
 	
 	//	level.scr_anim[ "generic" ][ "patrol_walk" ]			= %patrol_bored_patrolwalk;
// 	level.scr_anim[ "generic" ][ "patrol_walk_twitch" ]		= %patrol_bored_patrolwalk_twitch;
// 	level.scr_anim[ "generic" ][ "patrol_stop" ]			= %patrol_bored_walk_2_bored;
// 	level.scr_anim[ "generic" ][ "patrol_start" ]			= %patrol_bored_2_walk;
// 	level.scr_anim[ "generic" ][ "patrol_turn180" ]			= %patrol_bored_2_walk_180turn;
	level.scr_anim[ "generic" ]["run_fast"]					= %ai_barnes_run_f_v2;
	
// 	// After 
// 	level.scr_anim["barnes"]["radio"] = %ch_flash_b02_weaver_listens_to_radio_barnes;
// 	level.scr_anim["brooks"]["radio"] = %ch_flash_b02_weaver_listens_to_radio_guy01;
// 	level.scr_anim["hudson"]["radio"] = %ch_flash_b02_weaver_listens_to_radio_guy02;
// 	//level.scr_anim["barnes"]["radio"] = %ch_flash_b02_weaver_listens_to_radio_player;
// 	level.scr_anim["kristina"]["radio"] = %ch_flash_b02_weaver_listens_to_radio_weaver;
// 	
// 		
// 	//-- TEMP - BEAT 1 Civ working on AC unit in the compound
// 	//level.scr_anim["ac_worker"]["crouch_idle"][0] = %ch_flashpoint_b1_flattire_idle_guy_1;
// 		
// 	//-- BEAT 1 Barnes advances
// 	//level.scr_anim["barnes"]["dropdown1"] = %ch_flash_b01_advancetoroad_barnes;
// 	//level.scr_anim["barnes"]["pipetodrop"] = %ch_flash_b01_pipetodrop_barnes;
// 	//level.scr_anim["barnes"]["droptoroad"] = %ch_flash_b01_droptoroad_barnes;
// 	//level.scr_anim["barnes"]["crossfirstroad"] = %ch_flash_b01_crossfirstroad_barnes;
// 	//level.scr_anim["barnes"]["roadtodrop"] = %ch_flash_b01_roadtodrop_barnes;
// 	//level.scr_anim["barnes"]["droptocover"] = %ch_flash_b01_droptocover_barnes;
// 	//level.scr_anim["barnes"]["climboverpipe"] = %ch_flash_b01_climboverpipe_barnes;
// 	
// 	level.scr_anim["barnes"]["start_1"] = %ch_flash_b01_barnes;
// 	level.scr_anim["barnes"]["start_2"] = %ch_flash_b01_barnes2;
// 	level.scr_anim["barnes"]["start_3"] = %ch_flash_b01_barnes3;
// 	level.scr_anim["barnes"]["start_3_loop"][0] = %ch_flash_b01_barnes3coverloop;
// 	level.scr_anim["barnes"]["start_4"] = %ch_flash_b01_barnes4;
// 		
// 	//-- BEAT 1 Squad crosses road
// 	//level.scr_anim["barnes_road"]["roadcross1"] = %ch_flash_b01_squadcrossingroad_barnes;
// 	//level.scr_anim["lewis_road"]["roadcross1"] = %ch_flash_b01_squadcrossingroad_guy01;
// 	//level.scr_anim["hudson_road"]["roadcross1"] = %ch_flash_b01_squadcrossingroad_guy02;
// 		
// 	//-- BEAT 1 Squad crosses road to Kristina
// 	//level.scr_anim["barnes_road_kristina1"]["roadcross_barnesA"] = %ch_flash_b01_squadcrossingroadagain_barnesA;
// 	//level.scr_anim["barnes_road_kristina2"]["roadcross_barnesB"] = %ch_flash_b01_squadcrossingroadagain_barnesB;
// 	//level.scr_anim["lewis_road_kristina"]["roadcross_lewis"] = %ch_flash_b01_squadcrossingroadagain_guy01;
// 	//level.scr_anim["hudson_road_kristina"]["roadcross_hudson"] = %ch_flash_b01_squadcrossingroadagain_guy02;
// 	
// 	//-- BEAT 1 Civilian Stuff
// 	level.scr_anim["civ_1"]["lookover_rail"][0] = %ch_flash_b01_civilianlookingoverrail;
// 
// 	level.scr_anim["civ_2"]["talkA"][0] = %ch_flash_b01_civiliansstandconversationA;
// 	level.scr_anim["civ_3"]["talkB"][0] = %ch_flash_b01_civiliansstandconversationB;
// 
// 	level.scr_anim["civ_4"]["table1"][0] = %ch_flash_b01_civiliansstandingovertable_civ1;
// 	level.scr_anim["civ_5"]["table2"][0] = %ch_flash_b01_civiliansstandingovertable_civ2;
// 	level.scr_anim["civ_6"]["table3"][0] = %ch_flash_b01_civiliansstandingovertable_civ3;
// 	
// 	level.scr_anim["civ_7"]["crouch_work"][0] = %ch_flash_b01_civiliancrouchedworking;
// 	level.scr_anim["civ_8"]["point_up"][0] = %ch_flash_b01_civilianpointingup;
// 	//level.scr_anim["civ_9"]["tie_shoe"][0] = %ch_flash_b01_civilianwalk2tieshoe;
// 	level.scr_anim["civ_10"]["clip_board"][0] = %ch_flash_b01_civilianwithclipboard;
// 	
// 	//-- BEAT 1 Guard Stuff
// 	level.scr_anim["guard_1"]["standA"][0] = %ch_flash_b01_standingguardA;
// 	level.scr_anim["guard_2"]["standB"][0] = %ch_flash_b01_standingguardB;
// 		
// 	//-- BEAT 1 Death anim for sniper at top of flame trench
// 	//level.scr_anim["fall_forward"]["death_facedown"] = %run_death_facedown;
// 	//level.scr_anim["generic"]["death_drop"] = %death_stand_dropinplace;
// 	
// 	level.scr_ani m["generic"]["doorbash_death"] = %death_run_stumble;
// 	level.scr_anim["generic"]["windowfall_death"] = %death_explosion_back13;
// 	level.scr_anim["generic"]["stairs_death"] = %death_run_onfront;
}


#using_animtree("player");
player_anims()
{
	level.scr_animtree[ "player_hands" ] 	= #animtree;				//-- Set the animtree
	//level.scr_model[ "player_hands" ] = "viewhands_player_blackkit"; 		//-- The player model used for the hands
	level.scr_model[ "player_hands" ] = level.player_interactive_hands;//"viewmodel_usa_blackops_urban_player";
	
	//Binoculars
	level.scr_anim["player_hands"]["binocular"]						= %int_flash_b01_binoculars;
	maps\_anim::addNotetrack_customFunction( "player_hands", "binoc_change", ::notify_binoc_change, "binocular" );
	maps\_anim::addNotetrack_customFunction( "player_hands", "start_weaverstab", ::notify_weaverstab, "binocular");
	
	level.scr_anim["player_hands"]["bomb_plant"] 					= %int_flashpoint_c4_plant;
	addNotetrack_customFunction( "player_hands", "detach", maps\flashpoint_e8::plant_bomb_detach, "bomb_plant" ); 
		

	level.scr_anim["player_hands"]["enter_morgue"] 						= %ch_int_b02_plyr_enter_morgue_player;


	//Gas start room
	//level.scr_anim["player_hands"]["gastrap"]						= %ch_flash_ev10_gastrap_player;
}


notify_weaver_rescue_door_open(guy)
{
	level notify("notify_weaver_rescue_door_open");	
}

notify_weaver_rescue_door_close(guy)
{
	level notify("notify_weaver_rescue_door_close");	
}

notify_weaver_rescue_start_woodsbowman(guy)
{
	level notify("notify_weaver_rescue_start_woodsbowman");	
}

notify_weaver_rescue_door_bash(guy)
{
	level notify("notify_weaver_rescue_door_bash");	
}


notify_player_lock_crossbow_pos(guy)
{
	//level notify("mason_said_to_get_over_here");	
}

notify_start_soldier_anim(guy)
{
	level notify("start_soldier_anim");	
	
	player = get_players()[0];
	player DisableOffhandWeapons();
}

notify_binoc_change(guy)
{
	level notify("binoc_change");
}

notify_weaverstab(guy)
{
	level notify("start_weaverstab");
}

notify_start_guards(guy)
{
	level notify("start_guards");
}

notify_group_gone(guy)
{
	wait( 3.0 );
	level notify("group_gone");
}

notify_door_kick(guy)
{
	level notify("start_door_kick");
}

notify_rack_fall(guy)
{
	level notify("reel_rack_start");
}

flip_table_check(guy)
{
	level notify("flip_table_start");
}

notify_playitcool_dialog(guy)
{
	level notify("playitcool_dialog");
} 

notify_tarp(guy)
{
	level notify( "hide_body_tarp_start" );
}

notify_start_run(guy)
{
	level notify( "start_run_karambit" );
}

notify_gastrap_door_kick(guy)
{
	level notify( "gastrap_door_kick" );
}

notify_gastrap_mask_off(guy)
{
	level notify( "gastrap_mask_off" );
}

notify_window_break(guy)
{
	level notify( "break_breach_window" );
}

notify_raise_gun(guy)
{
	level notify( "raise_gun" );
}

//entered_c4- Set as soon as Weaver enters the building, i.e steps through the hole in the wall
weaver_entered_c4(guy)
{
	level notify( "weaver_entered_c4" );
}

//plan_b – Set right after he finishes at the terminal (before he leaves the c4 building)
weaver_plan_b(guy)
{
	level notify( "weaver_plan_b" );
}	


#using_animtree("flashpoint");
flashpoint_anims()
{
	//Setup marine full body
	level.scr_model["player_body"] = level.player_interactive_model;
	
	level.scr_animtree[ "player_body" ] 	= #animtree;
	
	//level.scr_anim["player_body"]["trench_walk"][0] =  %ch_khe_E1C_c130crash_carryhudson_walk;
	//level.scr_anim["player_body"]["trench_idle"][0] =  %ch_khe_E1C_c130crash_carryhudson_idle;
//	level.scr_anim["player_body"]["carry_pickup"] = %int_hide_body_pickup;
	level.scr_anim["player_body"]["carry_walk"][0] =  %int_hide_body_walk;
	level.scr_anim["player_body"]["carry_idle"][0] =  %int_hide_body_idle;
	level.scr_anim["player_body"]["carry_drop"] =  %int_hide_body_drop;
	
	//Intro A: Woods takes cover. Note: Snake animation is not included in this check-in
	level.scr_anim["player_body"]["intro_a_player"]						= %ch_flash_ev01_intro_a_player;
	
	//Intro B: Woods kills the soldier
	//level.scr_anim["player_body"]["intro_b"]						= %ch_flash_ev01_intro_b_player;
	
	//Binoculars
	level.scr_anim["player_body"]["take_binocular"]					= %int_flash_ev01_getbinoculars;
	
	//Vault over pipe
	level.scr_anim["player_body"]["vault_over_pipe"]				= %ch_flash_ev02_vault_over_pipe_player;
	
	
	//Gas start room + vomit
	level.scr_anim["player_body"]["gastrap"]						= %ch_flash_ev10_gastrap_player;
	addNotetrack_customFunction( "player_body", "door_kick", ::notify_gastrap_door_kick, "gastrap" );
	addNotetrack_customFunction( "player_body", "mask_off", ::notify_gastrap_mask_off, "gastrap" );

	level.scr_anim["player_body"]["vomit_player"]					= %ch_flash_ev10_weavervomit_player;
	
	
	//Karambit sequence: Includes the dragging body animation
// 
// 	level.scr_anim["player_body"]["karambit_drag_into"]				= %ch_flash_ev03_karambit_firemanscarry_into_player;
// 	level.scr_anim["player_body"]["karambit_drag_loop"][0]			= %ch_flash_ev03_karambit_firemanscarry_loop_player;
// 	level.scr_anim["player_body"]["karambit_drag_drop"]				= %ch_flash_ev03_karambit_firemanscarry_drop_player;
//
	
	//In disguise
	level.scr_anim["player_body"]["in_disguise"]					= %ch_flash_ev03_tie_boots_player;
	
	//Make it quick
	level.scr_anim["player_body"]["make_it_quick_player"]				= %ch_flash_ev06_take_crossbow_player;

	//player zipline
	level.scr_anim["player_body"]["zipline_hookup"]					= %int_flash_ev06_clip_zipline;
	level.scr_anim["player_body"]["player_zipline_2hands"][0]		= %int_flash_ev06_twohands_zipline;
	level.scr_anim["player_body"]["player_zipline_1hand"][0]		= %int_flash_ev06_onehand_zipline;
	level.scr_anim["player_body"]["player_zipline_crashwindow"]	= %int_flash_ev06_crashwindow_zipline;
	addNotetrack_customFunction( "player_body", "breachwindow", ::notify_window_break, "player_zipline_crashwindow" );
	addNotetrack_customFunction( "player_body", "raisegun", ::notify_raise_gun, "player_zipline_crashwindow" );
	
	
	//dioramas
	level.scr_anim["player_body"]["diorama01"]					= %ch_flash_diorama01_cameraman; //glass room
	addNotetrack_customFunction( "player_body", "pre_cut", ::slide_one_pre_cut_effect, "diorama01" );
	addNotetrack_customFunction( "player_body", "flash_in", ::slide_one_flash_in_effect, "diorama01" );
	//addNotetrack_customFunction( "player_body", "flash_out", ::slide_one_flash_out_effect, "diorama01" );
//	addNotetrack_customFunction( "player_body", "pre_cut", ::slide_one_pre_cut_effect, "diorama01" );
//	addNotetrack_customFunction( "player_body", "flash_in", ::slide_one_flash_in_effect, "diorama01" );
//	addNotetrack_customFunction( "player_body", "flash_out", ::slide_one_flash_out_effect, "diorama01" );


	level.scr_anim["player_body"]["diorama02"]					= %ch_flash_diorama02_cameraman; //btr hijack
	addNotetrack_customFunction( "player_body", "pre_cut", ::pre_cut_effect, "diorama02" );
	addNotetrack_customFunction( "player_body", "flash_in", ::flash_in_effect, "diorama02" );
	addNotetrack_customFunction( "player_body", "flash_out", ::flash_out_effect, "diorama02" );
	addNotetrack_customFunction( "player_body", "pre_cut", ::pre_cut_effect, "diorama02" );
	addNotetrack_customFunction( "player_body", "flash_in", ::flash_in_effect, "diorama02" );
	addNotetrack_customFunction( "player_body", "flash_out", ::flash_out_effect, "diorama02" );

	level.scr_anim["player_body"]["diorama03"]					= %ch_flash_diorama03_cameraman; //btr firing at limo
	addNotetrack_customFunction( "player_body", "pre_cut", ::pre_cut_effect, "diorama03" );
	addNotetrack_customFunction( "player_body", "flash_in", ::flash_in_effect, "diorama03" );
	addNotetrack_customFunction( "player_body", "zoom_fov", ::zoom_fov_effect, "diorama03" );
	addNotetrack_customFunction( "player_body", "flash_out", ::flash_out_effect, "diorama03" );


	level.scr_anim["player_body"]["diorama04"]					= %ch_flash_diorama04_cameraman; //limo on fire
	addNotetrack_customFunction( "player_body", "pre_cut", ::pre_cut_effect, "diorama04" );
	addNotetrack_customFunction( "player_body", "flash_in", ::flash_in_effect, "diorama04" );
	addNotetrack_customFunction( "player_body", "flash_out", ::flash_out_effect, "diorama04" );
	addNotetrack_customFunction( "player_body", "pre_cut", ::pre_cut_effect, "diorama04" );
	addNotetrack_customFunction( "player_body", "flash_in", ::flash_in_effect, "diorama04" );
	addNotetrack_customFunction( "player_body", "flash_out", ::flash_out_effect, "diorama04" );

	//this slide has been CUT
	level.scr_anim["player_body"]["diorama05"]					= %ch_flash_diorama05_cameraman;


	level.scr_anim["player_body"]["diorama06"]					= %ch_flash_diorama06_cameraman; //kravchenko on helipad
	addNotetrack_customFunction( "player_body", "pre_cut", ::pre_cut_effect, "diorama06" );
	addNotetrack_customFunction( "player_body", "cut", ::cut_effect, "diorama06" );


}


#using_animtree("animated_props");
prop_anims()
{
// 	level.scr_animtree[ "door" ] 	= #animtree;
// 	level.scr_model["door"] = "tag_origin_animate";
// 	level.scr_anim["door"]["kristina_fight"] = %ch_flash_b01_kristinafight_door;
// 	
// 	level.scr_animtree[ "table" ] 	= #animtree;
// 	level.scr_anim["table"]["kristina_fight"] = %ch_flash_b01_kristinafight_table;
// 	
	level.scr_animtree[ "door" ] 	= #animtree;
	level.scr_model["door"] = "tag_origin_animate";
	//level.scr_anim["door"]["comms_end"][0] = %o_flash_b05_comm_breach_door_endloop;
	level.scr_anim["door"]["comms_open"] = %o_flash_ev04_comm_link_door;
	level.scr_anim["door"]["comms_close"] = %o_flash_ev04_comm_link_door_close;
	
	
		/*
xanim,o_flash_ev06_stilltime_door1			"weaver_door_1"
xanim,o_flash_ev06_stilltime_door2			"weaver_door"
*/
//depot/projects/cod/t5/xanim_export/scripted/flashpoint/o_flash_ev06_stilltime_door1_close.XANIM_EXPORT#1 add
//depot/projects/cod/t5/xanim_export/scripted/flashpoint/o_flash_ev06_stilltime_door1_open.XANIM_EXPORT#1 add

	
	//Weaver rescue doors
	level.scr_animtree[ "weaver_door_in" ] 		= #animtree;
	level.scr_model["weaver_door_in"]			= "tag_origin_animate";
	level.scr_anim["weaver_door_in"]["open"]	= %o_flash_ev06_stilltime_door1_open;
	level.scr_anim["weaver_door_in"]["close"]	= %o_flash_ev06_stilltime_door1_close;
	
	level.scr_animtree[ "weaver_door_out" ] 	= #animtree;
	level.scr_model["weaver_door_out"]			= "tag_origin_animate";
	level.scr_anim["weaver_door_out"]["open"]	= %o_flash_ev06_stilltime_door2;
	
	
	// anim node = "comm_1"
	level.scr_animtree[ "floor1_green_chair" ] 	= #animtree;
	level.scr_model["floor1_green_chair"] = "tag_origin_animate";
	level.scr_anim["floor1_green_chair"]["idle"][0] = %prop_comms_floor1_green_idle_chair;			//Idle in chair
	level.scr_anim["floor1_green_chair"]["alert"] = %prop_comms_floor1_green_idle_2_alert_chair;	//Alerted to player	
	
	// anim node = "comm_1"
	level.scr_animtree[ "floor2_green_chair" ] 	= #animtree;
	level.scr_model["floor2_green_chair"] = "tag_origin_animate";
	level.scr_anim["floor2_green_chair"]["idle"][0] = %prop_comms_floor2_green_idle_chair;			//Idle in chair
	level.scr_anim["floor2_green_chair"]["alert"] = %prop_comms_floor2_green_idle_2_alert_chair;	//Alerted to player	
	
	// anim node = "comm_1"
	level.scr_animtree[ "floor2_blue_chair" ] 	= #animtree;
	level.scr_model["floor2_blue_chair"] = "tag_origin_animate";
	level.scr_anim["floor2_blue_chair"]["ack"]				= %prop_comms_floor2_blue_idle_chair;				//guy nods at player, can use prop_comms_floor2_blue_idle_chair for the chair
	level.scr_anim["floor2_blue_chair"]["idle"][0]			= %prop_comms_floor2_blue_idle_chair;
	level.scr_anim["floor2_blue_chair"]["alert"]			= %prop_comms_floor2_blue_idle_2_alert_chair;		//Alerted by player:
	level.scr_anim["floor2_blue_chair"]["left_in"]			= %prop_comms_floor2_blue_turn_2_left_chair;		//Turn left, left idle, back to facing front;
	level.scr_anim["floor2_blue_chair"]["left_idle"][0]		= %prop_comms_floor2_blue_left_idle_chair;
	level.scr_anim["floor2_blue_chair"]["left_out"]			= %prop_comms_floor2_blue_left_2_front_chair;
	level.scr_anim["floor2_blue_chair"]["right_in"]			= %prop_comms_floor2_blue_turn_2_right_chair;		//Turn right, right idle, back to facing front;
	level.scr_anim["floor2_blue_chair"]["right_idle"][0]	= %prop_comms_floor2_blue_right_idle_chair;
	level.scr_anim["floor2_blue_chair"]["right_out"]		= %prop_comms_floor2_blue_right_2_front_chair;
	level.scr_anim["floor2_blue_chair"]["back_in"]			= %prop_comms_floor2_blue_turn_2_back_chair;		//Turn to back, back idle, back to facing front;
	level.scr_anim["floor2_blue_chair"]["back_idle"][0]		= %prop_comms_floor2_blue_back_idle_chair;
	level.scr_anim["floor2_blue_chair"]["back_out"]			= %prop_comms_floor2_blue_back_2_front_chair;
	

	// anim node = "comm_1"
	level.scr_animtree[ "floor3_orange_chair" ] 	= #animtree;
	level.scr_model["floor3_orange_chair"] = "tag_origin_animate";
	level.scr_anim["floor3_orange_chair"]["idle"][0] = %prop_comms_floor3_orange_idle_chair;		//Idle in chair
	level.scr_anim["floor3_orange_chair"]["alert"] = %prop_comms_floor3_orange_idle_2_alert_chair;	//Alerted to player	
	
	// anim node = "comm_1"
	level.scr_animtree[ "floor3_green_chair" ] 	= #animtree;
	level.scr_model["floor3_green_chair"] = "tag_origin_animate";
	level.scr_anim["floor3_green_chair"]["idle"][0] = %prop_comms_floor3_green_idle_chair;				//Idle in chair
	level.scr_anim["floor3_green_chair"]["alert"] = %prop_comms_floor3_green_idle_2_alert_chair;		//Alerted to player	
	level.scr_anim["floor3_green_chair"]["melee"] = %prop_contextual_melee_comms_floor3_green_chair;	//Melee
	
	//Gas room doors
	level.scr_animtree[ "gasdoorleft" ] 	= #animtree;
	level.scr_model["gasdoorleft"]			= "tag_origin_animate";
	level.scr_anim["gasdoorleft"]["open"]	= %o_flash_ev10_gastrap_door_left;
	level.scr_animtree[ "gasdoorright" ] 	= #animtree;
	level.scr_model["gasdoorright"]			= "tag_origin_animate";
	level.scr_anim["gasdoorright"]["open"]	= %o_flash_ev10_gastrap_door_right;
	
	level.scr_animtree[ "vomitdoorleft" ] 	= #animtree;
	level.scr_model["vomitdoorleft"]		= "tag_origin_animate";
	level.scr_anim["vomitdoorleft"]["open"] = %o_flash_ev10_weavervomit_door_left;
	level.scr_animtree[ "vomitdoorright" ] 	= #animtree;
	level.scr_model["vomitdoorright"]		= "tag_origin_animate";
	level.scr_anim["vomitdoorright"]["open"] = %o_flash_ev10_weavervomit_door_right;

// 
// 	level.scr_animtree[ "table_to_flip" ] 	= #animtree;
// 	level.scr_model["table_to_flip"] = "tag_origin_animate";
// 	level.scr_anim["table_to_flip"]["flip"] = %o_flash_ev09_one_handed_fire_table;
	
 	//Gas mask
 	level.scr_animtree["playergasmask"] 				= #animtree;
 	level.scr_model["playergasmask"]					= "tag_origin_animate";
 	level.scr_anim["playergasmask"]["gastrap"]			= %o_flash_ev10_gastrap_playermask;
 	level.scr_anim["playergasmask"]["vomit_player"]		= %o_flash_ev10_weavervomit_playermask;

 	level.scr_animtree["weavergasmask"] 				= #animtree;
 	level.scr_model["weavergasmask"]					= "tag_origin_animate";
 	level.scr_anim["weavergasmask"]["gastrap_A"]		= %o_flash_ev10_gastrap_weavermask_A;
//  	level.scr_anim["weavergasmask"]["gastrap_B"]		= %o_flash_ev10_gastrap_weavermask_B;
//  	level.scr_anim["weavergasmask"]["gastrap_idle_A"][0]= %o_flash_ev10_gastrap_weavermask_idle_A;
//  	level.scr_anim["weavergasmask"]["gastrap_idle_B"][0]= %o_flash_ev10_gastrap_weavermask_idle_B;
//  	level.scr_anim["weavergasmask"]["gastrap_mantle"]	= %o_flash_ev10_gastrap_weavermask_mantlewindow;
 	level.scr_anim["weavergasmask"]["vomit"]			= %o_flash_ev10_weavervomit_weavermask;
 	
 	level.scr_animtree["woodsgasmask"] 							= #animtree;
 	level.scr_model["woodsgasmask"]								= "tag_origin_animate";
 	level.scr_anim["woodsgasmask"]["gastrap_A_woods"]			= %o_flash_ev10_gastrap_woodsmask_A;
//  	level.scr_anim["woodsgasmask"]["gastrap_B_woods"]			= %o_flash_ev10_gastrap_woodsmask_B;
//  	level.scr_anim["woodsgasmask"]["gastrap_idle_A_woods"][0]	= %o_flash_ev10_gastrap_woodsmask_idle_A;
//  	level.scr_anim["woodsgasmask"]["gastrap_idle_B_woods"][0]	= %o_flash_ev10_gastrap_woodsmask_idle_B;
//  	level.scr_anim["woodsgasmask"]["gastrap_mantle_woods"]		= %o_flash_ev10_gastrap_woodsmask_mantlewindow;
 	level.scr_anim["woodsgasmask"]["vomit_woods"]				= %o_flash_ev10_weavervomit_woodsmask;

 	level.scr_animtree["limo"] 				= #animtree;
 	level.scr_anim["limo"]["end_crash"][0]				= %fxanim_flash_car_crash_anim;


// 	level.scr_animtree["gas_start_door_l"] 	        	 = #animtree;
// 	level.scr_animtree["gas_start_door_r"] 	        	 = #animtree;
// 	
// 	level.scr_anim["gas_start_door_l"]["e2_dooropen"]							 = %o_int_b02_open_double_doors_door_left;
// 	level.scr_anim["gas_start_door_r"]["e2_dooropen"] 						 = %o_int_b02_open_double_doors_door_right;
// 	level.scr_anim["gas_start_door_l"]["morgue_dooropen"]						 = %o_int_b02_plyr_enter_morgue_door_left;
// 	level.scr_anim["gas_start_door_r"]["morgue_dooropen"] 					 = %o_int_b02_plyr_enter_morgue_door_right;

}


setup_vo()
{
//slide 1,2,3
    //level.scr_sound["mason"]["slide_1"] = "vox_fla1_s01_807A_maso"; //We searched the whole base. We couldn't find the bastard anywhere.
    //level.scr_sound["mason"]["slide_3"] = "vox_fla1_s01_807C_maso"; //But then we ran into Dragovich's limo. I had him.

//slide 4
	//level.scr_sound["woods"]["slide_4a"] 	= "vox_fla1_s09_317A_wood"; //Satisfied, Mason?
	//level.scr_sound["mason"]["slide_4b"] 	= "vox_fla1_s09_318A_maso"; //Not yet... Not until I see the body.

//slide 5
	level.scr_sound["woods"]["slide_5"] 	= "vox_fla1_s09_319A_wood"; //We ain't got time... Gotta go, Mason.


	level.scr_sound["woods"]["losetheb"] = "vox_fla1_s01_805A_wood"; //We've been made, lose the balaclavas.
	
	
	level.scr_sound["woods"]["spotted"] = "vox_fla1_s02_358A_wood"; //The chopper's on you!
	level.scr_sound["woods"]["spotted2"] = "vox_fla1_s02_359A_wood"; //It's got you in its sights!!!
	

	//SLIDE VO 
    level.scr_sound["woods"]["get_outta_here"] = "vox_fla1_s09_255A_wood"; //Okay. Time we got the hell out of here.

    level.scr_sound["mason"]["not_yet"] = "vox_fla1_s09_270A_maso"; //Not yet...

    level.scr_sound["mason"]["after_drago"] = "vox_fla1_s09_271A_maso"; //We're going after Dragovich.

	//Interrogator
    level.scr_sound["interrogator"]["losing_him"] = "vox_fla1_s01_811A_inte"; //We're losing him again.

	//Interrogator
    level.scr_sound["interrogator"]["stay_with_me"] = "vox_fla1_s01_812A_inte"; //Stay with me Mason.

    level.scr_sound["mason"]["krav_escaped"] = "vox_fla1_s01_808A_maso"; //Kravchenko escpaed before we could get to him.

	//Interrogator
    level.scr_sound["interrogator"]["you_were_getting_close"] = "vox_fla1_s01_813A_inte"; //You were getting close. Dragovich was there, wasn't he?

    level.scr_sound["mason"]["searched_base"] = "vox_fla1_s01_807A_maso"; //We searched the whole base. We couldn't find the bastard anywhere.

	//Interrogator
    level.scr_sound["interrogator"]["waste_of_time"] = "vox_fla1_s01_814A_inte"; //This is a waste of time. He's delusional.

    level.scr_sound["mason"]["slide_2"] = "vox_fla1_s01_807B_maso"; //We stole a BTR and we were getting the fuck out.

    level.scr_sound["mason"]["ran_into_limo"] = "vox_fla1_s01_807C_maso"; //But then we ran into Dragovich's limo. I had him.

    level.scr_sound["woods"]["satisfied_mason"] = "vox_fla1_s09_317A_wood"; //Satisfied, Mason?

    level.scr_sound["mason"]["no_no_no"] = "vox_fla1_s09_318A_maso"; //NO! No, not yet... Not until I see the body.

	//Interrogator
    level.scr_sound["interrogator"]["confirm_drago_kill"] = "vox_fla1_s01_815A_inte"; //Dragovich. Did. You. Confirm. The kill.

	level.scr_sound["woods"]["charcoal_briquette"] 	= "vox_fla1_s09_320A_wood"; //Trust me... That rat bastard's a fucking charcoal briquette.


	//TODO
	//level.scr_sound["Weaver"]["anime"] = "vox_fla1_s07_141A_weav"; //We have less than a minute to get to the auxiliary bunker.
	//level.scr_sound["Weaver"]["anime"] = "vox_fla1_s07_143A_weav_m"; //We're almost out of time!
	//level.scr_sound["Woods"]["anime"] = "vox_fla1_s07_147A_wood"; //Move it!
	//level.scr_sound["Base Loudspeaker"]["anime"] = "vox_fla1_s07_140A_ruld_f"; //(Translated) All personnel. This is your two minute warning for launch. All personnel must clear the launch pad immediately.
	//level.scr_sound["Soviet Scientist"]["anime"] = "vox_fla1_s07_129A_svsc"; //(Translated) We're approved for launch. Clear the launch pad Sergeant.
	//level.scr_sound["Soviet Soldier"]["anime"] = "vox_fla1_s07_130A_sov3"; //(Translated) Petrov, Mikhail! I want this area in 3 minutes. Go!


//crossbow event
// level.scr_sound["Woods"]["anime"] = "vox_fla1_s08_161B_wood_m"; //Holy shit! Carnage, I love it!


//STeam
  //  level.scr_sound["Woods"]["anime"] = "vox_fla1_s09_222A_wood"; //They are tryin' to rush us!!!
  //  level.scr_sound["Woods"]["anime"] = "vox_fla1_s09_223A_wood"; //Open fire!!!
 
	level.scr_sound["woods"]["toolate"] = "vox_fla1_s11_007A_wood"; //We're too late the Rocket is launching
	level.scr_sound["woods"]["chopperdown"] = "You got him!"; //when helicopters pilot gets shot
	level.scr_sound["woods"]["bloody"] = "vox_fla1_s03_326A_wood";//"Come on lets go, stop messing around!";
//	level.scr_sound["woods"]["highroad"] = "Mason stay with me! Brooks, Bowman go and clear out the scientists below";
	level.scr_sound["woods"]["rambo"] = "Rambo would be proud - nice shooting!";
	
	
	level.scr_sound["woods"]["stay1"] = "vox_fla1_s03_321A_wood"; //Where the Hell are you goin'?
    level.scr_sound["woods"]["stay2"] = "vox_fla1_s03_322A_wood"; //Mason! Stay with me!
    level.scr_sound["woods"]["stay3"] = "vox_fla1_s03_323A_wood"; //Get back here, Mason
    
    
	//TRUCK
	level.scr_sound["woods"]["truck1"] = "dds_woo_thrt_lm_truck_02"; // Hostiles near that truck!
	level.scr_sound["woods"]["truck2"] = "dds_woo_thrt_lm_truck_01"; // That truck! Watch the truck!
	level.scr_sound["woods"]["truck3"] = "dds_woo_thrt_lm_truck_02"; // Hostiles near that truck!
	level.scr_sound["woods"]["mgtruck1"] = "dds_woo_thrt_lm_mg_00"; // Check that MG!
	level.scr_sound["woods"]["mgtruck2"] = "dds_woo_thrt_lm_mg_01"; // I got one by the MG!	
	level.scr_sound["woods"]["mgtruck3"] = "dds_woo_thrt_lm_mg_02"; // Contacts by the MG!
	
	//COmms door lines
	level.scr_sound["comms_flr1_blue"]["intruders"] = "vox_fla1_s05_102A_sov1"; //(Translated) Intruders!!!
	level.scr_sound["woods"]["damn_made"] = "vox_fla1_s06_377A_wood_m"; //Shit!... We've been made! 
	    
//	level.scr_sound["Woods"]["anime"] = "vox_fla1_s11_005A_wood"; //Shit, we've been found out.
//    level.scr_sound["Woods"]["anime"] = "vox_fla1_s11_005A_wood_s"; //Damn, we've been found out.
//    level.scr_sound["Woods"]["anime"] = "vox_fla1_s06_377A_wood_m"; //Shit!... We've been made!
//    level.scr_sound["Woods"]["anime"] = "vox_fla1_s06_377A_wood_s_m"; //Damn!... We've been made!
	
//       level.scr_sound["Soviet Soldier"]["anime"] = "vox_fla1_s05_102A_sov1"; //(Translated) Intruders!!!



	
	//Roof top extra lines
	level.scr_sound["woods"]["peekaboo_snipers1"] = "vox_fla1_s06_375A_wood_f"; //Snipers!!!
	level.scr_sound["bowman"]["peekaboo_snipers2"] = "vox_fla1_s04_091A_bowm_f"; //Snipers!!!


	//Base snipers
	level.scr_sound["woods"]["snipers"] = "vox_fla1_s09_288A_wood"; //Snipers!!!
	
	//Intro
	level.scr_sound["woods"]["pick_it_up"] = "vox_fla1_s01_008A_wood_m"; //Let's go. Pick it up.
	
	//Pipe
	level.scr_sound["woods"]["over_here"] = "vox_fla1_s09_263A_wood"; //Mason! Over here!
	level.scr_sound["woods"]["head_down"] = "vox_fla1_s02_040A_wood_m"; //We got a chopper coming. Get your head down.
    level.scr_sound["woods"]["follow_me"] = "vox_fla1_s02_041A_wood_m"; //Follow me and keep moving.
    level.scr_sound["woods"]["back_to_cover"] = "vox_fla1_s02_337A_wood"; //Get back to cover. They'll see you!
    level.scr_sound["woods"]["back_over_here"] = "vox_fla1_s02_338A_wood"; //Get your ass back over here!
    level.scr_sound["woods"]["giveup_pos"] = "vox_fla1_s02_339A_wood"; //You're giving away our position!
    level.scr_sound["woods"]["heli_inbound"] = "vox_fla1_s02_340A_wood"; //Chopper's inbound - move it!
    level.scr_sound["woods"]["pick_it_up_2"] = "vox_fla1_s02_042A_wood"; //We're good. Pick it up.
    level.scr_sound["woods"]["hold_ok"] = "vox_fla1_s02_043A_wood"; //Hold.... Okay....
    
    //Over the pipe - used to be FPC
    level.scr_sound["woods"]["need_uniforms"] = "vox_fla1_s02_049A_wood_m"; //We need those uniforms.
    level.scr_sound["woods"]["on_the_ground"] = "vox_fla1_s02_050A_wood_m"; //I'll take the one on the ground. You get the other.
    level.scr_sound["mason"]["got_it"] = "vox_fla1_s02_051A_maso"; //Got it.
    
    //Karambit
    level.scr_sound["guard1"]["line1"] = "vox_fla1_s02_044A_sgu1"; //(Translated) A work of great Soviet ingenuity.
    level.scr_sound["guard2"]["line2"] = "vox_fla1_s02_045A_sgu2"; //(Translated) Made from Russian suffering.
    level.scr_sound["guard1"]["line3"] = "vox_fla1_s02_046A_sgu1"; //(Translated) Such courage to say that when Dragovich isn't here.
    level.scr_sound["guard2"]["line4"] = "vox_fla1_s02_047A_sgu2"; //(Translated) I'd say it in front of him.
    level.scr_sound["guard1"]["line5"] = "vox_fla1_s02_048A_sgu1"; //(Translated) Of course you would. But look at it! Tell me we cannot achieve great things.
    level.scr_sound["woods"]["outofsight"] = "vox_fla1_s02_054A_wood"; //Let's get them out of sight.
    
    //Squad meetup
    level.scr_sound["woods"]["holdit"] = "vox_fla1_s09_215A_wood_m"; //Hold it...
    level.scr_sound["woods"]["upahead"] = "vox_fla1_s03_079A_wood"; //Bowman should be right up ahead.
    level.scr_sound["bowman"]["hostiles"] = "vox_fla1_s03_080A_bowm_f"; //X-ray this is Whiskey. Hostiles in sight. Taking them out.
	level.scr_sound["woods"]["hustle"] = "vox_fla1_s03_081A_wood"; //Hustle up.
    
    //Base walkthough
    level.scr_sound["woods"]["letsmove"] = "vox_fla1_s03_085A_wood_m"; //Alright... Let's move.
    level.scr_sound["woods"]["becool"] = "vox_fla1_s04_086A_wood_m"; //Be cool.... Don't draw attention.
    level.scr_sound["bowman"]["found_bodies"] = "vox_fla1_s04_088A_bowm_m"; //We may not have the luxury - I think they may have found the bodies.
    level.scr_sound["bowman"]["found_bodies2"] = "vox_fla1_s04_329A_bowm"; //I think they may have found the bodies.
    level.scr_sound["woods"]["dowhattheydo"] = "vox_fla1_s04_089A_wood_m"; //We're good. Just do what they do.
    level.scr_sound["mason"]["commsupahead"] = "vox_fla1_s04_090A_maso"; //Comms building up ahead.
    level.scr_sound["bowman"]["snipersonroof"] = "vox_fla1_s04_091A_bowm"; //Snipers taking positions on the roof.
    level.scr_sound["bowman"]["menoutfront"] = "vox_fla1_s04_092A_bowm"; //Couple of men out front.
	
	//Comms building
	level.scr_sound["woods"]["youready"] = "vox_fla1_s05_096A_wood_m"; //You ready?
    level.scr_sound["woods"]["uptop"] = "vox_fla1_s05_097A_wood_m"; //I'll take out the comm link. You get up top and deal with the snipers!
    level.scr_sound["woods"]["eachfloor"] = "vox_fla1_s05_097B_wood_m"; //Clear each floor before you move up... I'll shut down the comm link.
    level.scr_sound["woods"]["knife"] = "vox_fla1_s05_097C_wood_m"; //Use your knife... We don't want to draw attention.
    level.scr_sound["woods"]["commsgo"] = "vox_fla1_s05_098A_wood_m"; //GO!
    
    level.scr_sound["comms_flr1_blue"]["outside"] = "vox_fla1_s05_362A_sgu3"; //(Translated) What is all the noise outside?
    level.scr_sound["mason"]["comms_clear"] = "vox_fla1_s05_363A_maso"; //Clear.
    level.scr_sound["mason"]["movingup"] = "vox_fla1_s05_364A_maso"; //Moving up.
    
    
	level.scr_sound["mason"]["runner"] = "vox_fla1_s05_100A_maso"; //We got a runner!
    level.scr_sound["woods"]["afterhim"] = "vox_fla1_s05_101A_wood"; //Get after him!
  //  level.scr_sound["comms_flr1_blue"]["intruders"] = "vox_fla1_s05_102A_sov1"; //(Translated) Intruders!!!
    level.scr_sound["woods"]["outtheway"] = "vox_fla1_s04_093A_wood"; //Okay... Bowman. Brooks. Get them out of the way.
    
    //Snipers on roof
    level.scr_sound["woods"]["takeoutsnipers"] = "vox_fla1_s06_375A_wood_f"; //Take out those snipers.
    
  //Right before and after Zipline
 // level.scr_sound["bowman"]["xray_zip"] = "vox_fla1_s06_105A_bowm_f"; //X-ray come in, over.
 // level.scr_sound["woods"]["go_ahead_whisky_zip"] = "vox_fla1_s06_106A_wood_f"; //Go ahead, Whiskey.
 // level.scr_sound["bowman"]["visual_on_weaver"] = "vox_fla1_s06_107A_bowm_f"; //We just got a visual on Weaver... He's been taken to a bunker just south of the Comms building.
 
  //level.scr_sound["woods"]["make_it_quick_vo"] = "vox_fla1_s06_113A_wood"; //Make it quick, Mason.
  level.scr_sound["woods"]["go_go_go"] = "vox_fla1_s06_115A_wood"; //Go! GO!
  
  
	//Explosive crossbow event + zipline
    level.scr_sound["woods"]["commsdown"] = "vox_fla1_s06_104A_wood_f"; //Comm links down.
    level.scr_sound["bowman"]["xray"] = "vox_fla1_s06_105A_bowm_f"; //X-ray come in, over.
    level.scr_sound["woods"]["goahead"] = "vox_fla1_s06_106A_wood_f"; //Go ahead, Whiskey.
    //level.scr_sound["bowman"]["bunkersouth"] = "vox_fla1_s06_107A_bowm_f"; //We just got a visual on Weaver... He's been taken to a bunker South of the Comms building.
    level.scr_sound["woods"]["copythat"] = "vox_fla1_s06_108A_wood_m"; //Copy that. We're on our way.
    level.scr_sound["woods"]["breachbuilding"] = "vox_fla1_s06_331A_wood"; //Copy that. Mason gonna breach the building.
    level.scr_sound["woods"]["overhere"] = "vox_fla1_s06_109A_wood_m"; //Mason -  get over here.
    level.scr_sound["woods"]["gunfire"] = "vox_fla1_s06_110A_wood_m"; //Gunfire's drawin' attention.
    level.scr_sound["woods"]["assholes"] = "vox_fla1_s06_111A_wood_m"; //Those assholes are on the way back!
    level.scr_sound["woods"]["secureline"] = "vox_fla1_s06_112A_wood_m"; //I'll secure the line. You take the shot.
    level.scr_sound["woods"]["makeitquick"] = "vox_fla1_s06_113A_wood"; //Make it quick, Mason.
    level.scr_sound["woods"]["buytime"] = "vox_fla1_s06_114A_wood"; //I'll buy us some time.
    //level.scr_sound["woods"]["gogo"] = "vox_fla1_s06_115A_wood"; //Go! GO!
    level.scr_sound["woods"]["behindya"] = "vox_fla1_s06_116A_wood"; //I'm right behind ya!
    
	level.scr_sound["woods"]["company"] = "vox_fla1_s10_001A_wood"; //	We got Company!
	level.scr_sound["woods"]["explosivetips"] = "vox_fla1_s10_002A_wood"; //	Switch to explosive tips!
	level.scr_sound["woods"]["pinned_veh"] = "vox_fla1_s10_003A_wood"; //	They're pinned down, take out those vehicles!
	level.scr_sound["woods"]["niceshot"] = "vox_fla1_s10_004A_wood"; //	Nice shot Mason! They didn’t teach you that in basic!

    
	//Rocket launch (russian announcer)
	level.scr_sound["ruld"]["2min"] = "vox_fla1_s02_055A_ruld_f"; //(Translated) Mark: T-minus 2 minutes and counting. Still going well. Propellants stable onboard the vehicle.
	level.scr_sound["ruld"]["1min36"] = "vox_fla1_s02_056A_ruld_f"; //(Translated) 1 minute  36 seconds and counting; still going well.
	level.scr_sound["ruld"]["90sec"] = "vox_fla1_s02_057A_ruld_f"; //(Translated) 90 seconds away from lift-off. All still going well. We'll go on internal power with the vehicle at the 50 second mark in the count.
	level.scr_sound["ruld"]["70sec"] = "vox_fla1_s02_058A_ruld_f"; //(Translated) Still going well - third stage is now completely pressurized. Coming up shortly on the 1 minute mark  we're now 70 seconds and counting.
	level.scr_sound["ruld"]["65sec"] = "vox_fla1_s02_059A_ruld_f"; //(Translated) Second stage tanks are pressurized;  countdown continues.
	level.scr_sound["ruld"]["60sec"] = "vox_fla1_s02_060A_ruld_f"; //(Translated) Mark: T-minus 60 seconds and counting. The Cosmonauts are Go. Launch vehicle and spacecraft components all Go... Countdown proceeds.
	level.scr_sound["ruld"]["50sec"] = "vox_fla1_s02_061A_ruld_f"; //(Translated) Now 50 seconds; we have the power transfer. The vehicle now on the battery power on the vehicle and all is still going well.  Crew making final checks now.
	level.scr_sound["ruld"]["40sec"] = "vox_fla1_s02_062A_ruld_f"; //(Translated) Passing the 40 second mark...  Aligning the guidance system.
	level.scr_sound["ruld"]["30sec"] = "vox_fla1_s02_063A_ruld_f"; //(Translated) 30 seconds and counting. The guidance system will go internal at the 17 second mark.
	level.scr_sound["ruld"]["25sec"] = "vox_fla1_s02_064A_ruld_f"; //(Translated) Now 25 seconds. We have complete clearance to launch.
	level.scr_sound["ruld"]["20sec"] = "vox_fla1_s02_065A_ruld_f"; //(Translated) We are Go. 20.
	level.scr_sound["ruld"]["15sec"] = "vox_fla1_s02_066A_ruld_f"; //(Translated) 15 seconds  guidance internal  13  12  11  10  9  8  ignition sequence start.
	level.scr_sound["ruld"]["5sec"] = "vox_fla1_s02_067A_ruld_f"; //(Translated) Engines On. 5  4... 3…
	level.scr_sound["ruld"]["2sec"] = "vox_fla1_s02_068A_ruld_f"; //(Translated) ...2  1  all engines running.   Launch commit.
	level.scr_sound["ruld"]["liftoff"] = "vox_fla1_s02_069A_ruld_f"; //(Translated) Lift-off. We have lift-off.
	
	//Over wall
	level.scr_sound["woods"]["overwall"] = "vox_fla1_s07_127A_wood"; //Here - over the wall.
    level.scr_sound["woods"]["100yards"] = "vox_fla1_s07_128A_wood"; //Targets, 100 yards, stay low!
    level.scr_sound["woods"]["asc_group"] = "vox_fla1_s07_334A_wood"; //There's the Ascension group scientists!
    level.scr_sound["woods"]["cardnazi"] = "vox_fla1_s07_335A_wood"; //Every one of them - a card carrying Nazi.
    level.scr_sound["mason"]["killthem"] = "vox_fla1_s07_336A_maso"; //Kill them where they stand.
    
    level.scr_sound["woods"]["afterthem"] = "vox_fla1_s07_382A_wood"; //Bowman! After them!
    level.scr_sound["weaver"]["grabass"] = "vox_fla1_s09_388A_weav"; //Grab your ass, we got a fight on our hands!
    level.scr_sound["woods"]["masononme"] = "vox_fla1_s07_383A_wood"; //Mason - on me!
    level.scr_sound["mason"]["killthem2"] = "vox_fla1_s07_336A_maso"; //Kill them in their tracks..
    
    
	//Under launchpad helicopter
	level.scr_sound["bowman"]["inbound"] = "vox_fla1_s07_142A_bowm_m"; //Shit! Chopper inbound!
    level.scr_sound["woods"]["pinned"] = "vox_fla1_s07_144A_wood"; //He's got us pinned!
    level.scr_sound["woods"]["nail_pilot"] = "vox_fla1_s07_145A_wood"; //Mason! Nail that pilot!
    level.scr_sound["woods"]["kill_pilot"] = "vox_fla1_s07_341A_wood"; //That chopper is hammering us. Kill the pilot!
    level.scr_sound["woods"]["shoot_pilot"] = "vox_fla1_s07_342A_wood"; //Shoot that goddam chopper pilot, Mason!
    
    
	//Random Russian radio
	level.scr_sound["generic_russian"]["convo1_0"] = "vox_fla1_s99_180A_rus1_f"; //(Translated) The Generals are on site - All Security Patrols report, over.
	level.scr_sound["generic_russian"]["convo1_1"] = "vox_fla1_s99_181A_rus2_f"; //(Translated) Copy that.
	level.scr_sound["generic_russian"]["convo1_2"] = "vox_fla1_s99_182A_rus3_f"; //(Translated) We're getting reports of power outage across sectors 11 through 16, over.
	level.scr_sound["generic_russian"]["convo2_0"] = "vox_fla1_s99_183A_rus1_f"; //(Translated) We're having some communication issues. Surface to base line is down - over.
	level.scr_sound["generic_russian"]["convo2_1"] = "vox_fla1_s99_184A_rus3_f"; //(Translated) Copy that.
	level.scr_sound["generic_russian"]["convo2_2"] = "vox_fla1_s99_185A_rus1_f"; //(Translated) We'll send some engineers to the substation, over and out.
	level.scr_sound["generic_russian"]["convo0_0"] = "vox_fla1_s99_186A_rus1_f"; //(Translated) Sweep complete. Nothing to report, over.
	level.scr_sound["generic_russian"]["convo0_1"] = "vox_fla1_s99_187A_rus1_f"; //(Translated) All clear. Continuing with sweep.
	level.scr_sound["generic_russian"]["convo0_2"] = "vox_fla1_s99_188A_rus2_f"; //(Translated) Sector 14 - clear.
	level.scr_sound["generic_russian"]["convo0_3"] = "vox_fla1_s99_189A_rus3_f"; //(Translated) Same here, over.
	level.scr_sound["generic_russian"]["convo0_4"] = "vox_fla1_s99_190A_rus1_f"; //(Translated) Keep on it. Over and out.
  
  
	//c4 building + rocket takedown
	//level.scr_sound["ruld"]["1min"] = "vox_fla1_s07_146A_ruld_f"; //(Translated) All personnel. One minute until to launch. Fire doors closing. Blast shutters closing.
   
    level.scr_sound["woods"]["moveit"] = "vox_fla1_s07_147A_wood"; //Move it!
    level.scr_sound["weaver"]["destroyrocket"] = "vox_fla1_s08_148A_weav_m"; //We have to destroy the rocket - no matter what!
    level.scr_sound["woods"]["holeinwall"] = "vox_fla1_s08_149A_wood_m"; //Mason, put a hole in that fuckin' wall!
    level.scr_sound["mason"]["ready"] = "vox_fla1_s08_150A_maso"; //Ready.
    level.scr_sound["woods"]["killall"] = "vox_fla1_s08_151A_wood"; //Kill 'em all!
    level.scr_sound["woods"]["move"] = "vox_fla1_s08_152A_wood_m"; //Move.
    level.scr_sound["woods"]["comeon"] = "vox_fla1_s08_153A_wood_m"; //Come on... Come on!
    level.scr_sound["weaver"]["toolate2"] = "vox_fla1_s08_154A_weav_m"; //It's too late! I can't stop it!
    level.scr_sound["woods"]["setitup"] = "vox_fla1_s08_155A_wood_m"; //Plan B, Bowman - Set it up!
    level.scr_sound["bowman"]["thisdoit"] = "vox_fla1_s08_156A_bowm_m"; //This'll do it!
    level.scr_sound["woods"]["fucken_a"] = "vox_fla1_s08_157A_wood_m"; //Fucken - A!
    level.scr_sound["mason"]["prototype"] = "vox_fla1_s08_158A_maso"; //Hell of a way to test a prototype!
    level.scr_sound["weaver"]["blowit"] = "vox_fla1_s08_159A_weav"; //Blow it, Mason! NOW!
    level.scr_sound["woods"]["fireit"] = "vox_fla1_s08_160A_wood_m"; //Fire It!
    level.scr_sound["woods"]["holyshit"] = "vox_fla1_s08_161A_wood_m"; //Holy shit!
    level.scr_sound["woods"]["stayinopen"] = "vox_fla1_s08_192A_wood"; //Dammit... Can't stay in the open.
    level.scr_sound["woods"]["gettotunnel"] = "vox_fla1_s08_162A_wood_m"; //Get to the tunnels!
    level.scr_sound["weaver"]["thisway"] = "vox_fla1_s08_193A_weav"; //This way...
    level.scr_sound["brooks"]["poorbast"] = "vox_fla1_s08_194A_broo"; //Poor bastards...
    level.scr_sound["woods"]["nazibast"] = "vox_fla1_s08_195A_wood_m"; //They're Nazi bastards... They don't deserve sympathy.
    level.scr_sound["woods"]["huntemdown"] = "vox_fla1_s08_196A_wood_m"; //We're here to hunt 'em down.
    level.scr_sound["weaver"]["tryingtoesc"] = "vox_fla1_s08_197A_weav_m"; //The rest of the Ascension group will be trying to escape the facility...
    level.scr_sound["woods"]["flankround"] = "vox_fla1_s08_198A_wood_m"; //Bowman, Brooks. You flank round to the North tunnel. No one sneaks out that back door!
    level.scr_sound["woods"]["withme"] = "vox_fla1_s08_200A_wood_m"; //Mason and Weaver, you're on me.
    
    
	//Gas rooms
    level.scr_sound["woods"]["holdit"] = "vox_fla1_s09_215A_wood_m"; //Hold it...
    level.scr_sound["weaver"]["teargas"] = "vox_fla1_s09_216A_weav_m"; //Tear gas!!!
    level.scr_sound["woods"]["maskon"] = "vox_fla1_s09_217A_wood_m"; //Get you mask on! Go, go, go!
    
    level.scr_sound["woods"]["moreofem"] = "vox_fla1_s09_210A_wood"; //More of 'em!
    level.scr_sound["woods"]["dammit"] = "vox_fla1_s09_211A_wood"; //Dammit!!!
    level.scr_sound["woods"]["diesob"] = "vox_fla1_s09_212A_wood"; //Die you son of a bitch!
   
	level.scr_sound["woods"]["seeshit"] = "vox_fla1_s09_218A_wood"; //Can't see shit... Bastards think they got the advantage... Let's prove 'em wrong.
    level.scr_sound["woods"]["shotgun"] = "vox_fla1_s09_220A_wood"; //Mason - Pull out your shotgun...
    level.scr_sound["woods"]["rushus"] = "vox_fla1_s09_222A_wood"; //They are tryin' to rush us!!!
    level.scr_sound["woods"]["openup"] = "vox_fla1_s09_223A_wood"; //Open up!!!
    level.scr_sound["woods"]["move"] = "vox_fla1_s09_224A_wood"; //Move!

	/////////////
	//
	//	BTR
	//
	////////////
	
	//-- Encouragement
	level.scr_sound["btr"]["drive"] = "vox_fla1_s09_268A_wood"; //Drive!!!
  level.scr_sound["btr"]["haul_ass"] = "vox_fla1_s09_393A_wood"; //Haul ass!!!
  
  //-- something in front
  level.scr_sound["btr"]["12_o_clock"] = "vox_fla1_s09_276A_wood"; //12 o'clock!

	//-- look to a side
  level.scr_sound["btr"]["eyes_left"] = "vox_fla1_s09_280A_bowm"; //Eyes left!
  level.scr_sound["btr"]["eyes_right"] = "vox_fla1_s09_282A_bowm"; //Eyes right!!
  
  //-- drive to a side
  level.scr_sound["btr"]["left_side"] = "vox_fla1_s09_281A_weav"; //Left side!
  level.scr_sound["btr"]["left_side_mason"] = "vox_fla1_s09_272A_wood"; //Left side, Mason!
  level.scr_sound["btr"]["right_side"] = "vox_fla1_s09_274A_wood"; //Right side!
  level.scr_sound["btr"]["right_side_mason"] = "vox_fla1_s09_283A_bowm"; //Right side, Mason!
  
  //-- something in front
  level.scr_sound["btr"]["up_ahead"] = "vox_fla1_s09_284A_weav"; //Up ahead!
  level.scr_sound["btr"]["in_front"] = "vox_fla1_s09_285A_bowm"; //In front!
  
  //-- run people over
  level.scr_sound["btr"]["run_right_over"] = "vox_fla1_s09_292A_wood"; //Run right over 'em!
  level.scr_sound["btr"]["ram_the_bastards_woods"] = "vox_fla1_s09_293A_wood"; //Ram the bastards!
  level.scr_sound["btr"]["run_over_them"] = "vox_fla1_s09_296A_wood"; //Run over 'em!
  level.scr_sound["btr"]["ram_the_bastards_weaver"] = "vox_fla1_s09_297A_weav"; //Ram the bastards!
  
  //-- Taking Damage
  level.scr_sound["btr"]["dammit"] = "vox_fla1_s09_298A_wood"; //Dammit!
  level.scr_sound["btr"]["taking_damage"] = "vox_fla1_s09_299A_wood"; //Taking damage!
  level.scr_sound["btr"]["btr_hit"] = "vox_fla1_s09_300A_bowm"; //We're hit!
  level.scr_sound["btr"]["btr_almost_dead"] = "vox_fla1_s09_301A_weav"; //We can't take much more of this!
  
  //-- Sighted Dragovich or Go faster
  level.scr_sound["btr"]["faster_mason"] = "vox_fla1_s09_302A_bowm"; //Faster, Mason! Faster!
  level.scr_sound["btr"]["there_he_is"] = "vox_fla1_s09_303A_maso"; //There he is! Dragovich!
      
  //-- Encouragement / Losing him
  level.scr_sound["btr"]["stay_on_him"] = "vox_fla1_s09_309A_bowm"; //Stay on him!
  level.scr_sound["btr"]["out_of_your_sight"] = "vox_fla1_s09_310A_wood"; //Don't let him out of your sight!
  //level.scr_sound["btr"]["losing_him"] = "vox_fla1_s09_311A_bowm"; //We're losing 'em!
  
  level.scr_sound["btr"]["get_us_out_of_here"] = "vox_fla1_s09_269A_bowm"; //Get us out of here, Mason!
  //level.scr_sound["btr"]["not_yet"] = "vox_fla1_s09_270A_maso"; //Not yet...
  //level.scr_sound["btr"]["after_dragovich"] = "vox_fla1_s09_271A_maso"; //We're going after Dragovich.
  
  //-- Ram Dragovich Instructions
  level.scr_sound["btr"]["ram_him"] = "vox_fla1_s09_312A_bowm"; //Ram him!
  level.scr_sound["btr"]["off_the_road"] = "vox_fla1_s09_314A_weav"; //Force him off the road!
  level.scr_sound["btr"]["hit_him_again"] = "vox_fla1_s09_313A_wood"; //Hit him again!
    
  //-- Ending
//   level.scr_sound["btr"]["you_sure"] 				= "vox_fla1_s09_304A_wood"; //You sure it's him?
//   level.scr_sound["btr"]["i_know"] 					= "vox_fla1_s09_305A_maso_d"; //I KNOW it is...
//   level.scr_sound["btr"]["never_forget_face"] 		= "vox_fla1_s09_306A_maso"; //I'll never forget that bastard's face.
//   level.scr_sound["btr"]["gott_kill"] 				= "vox_fla1_s09_307A_maso"; //I've got to kill him.
//   level.scr_sound["btr"]["limo_taking_damage"] 		= "vox_fla1_s09_315A_bowm"; //He's taking damage!
//   level.scr_sound["btr"]["no_get_out"] 				= "vox_fla1_s09_316A_wood"; //No one's getting out.
//   level.scr_sound["btr"]["satisfied"] 				= "vox_fla1_s09_317A_wood"; //Satisfied, Mason?
//   level.scr_sound["btr"]["see_the_body"] 			= "vox_fla1_s09_318A_maso"; //Not yet... Not until I see the body.
//   level.scr_sound["btr"]["no_time"] 				= "vox_fla1_s09_319A_wood"; //We ain't got time... Gotta go, Mason.
//   level.scr_sound["btr"]["rat_briquette"] 			= "vox_fla1_s09_320A_wood"; //Trust me... That rat bastard's a fucking charcoal briquette.


  level.scr_sound["btr"]["wake_up_mason"] = "vox_cub1_s02_062A_wood"; //Wake the fuck up, mason!



    level.scr_sound["left_guard"]["security"] = "vox_fla1_s05_374A_sgu3"; //(Translated) * Security! Sound the alarm!


	/* OLD
	//narration
	//level.scr_sound["carter"]["narration1"] = "VOX_FLA1_001A_CART";
	//level.scr_sound["carter"]["narration2"] = "VOX_FLA1_002A_CART";
	//level.scr_sound["carter"]["narration3"] = "VOX_FLA1_003A_CART";
	//level.scr_sound["carter"]["narration4"] = "VOX_FLA1_004A_CART";
	
	//binocular - rendezvous point
	level.scr_sound["barnes"]["rendezvous"] = "VOX_FLA1_005C_BARN";
	//level.scr_sound["barnes"]["rendezvous"] = "VOX_FLA1_049A_BARN";
	level.scr_sound["carter"]["got_it"] = "VOX_FLA1_006B_CART";
	level.scr_sound["barnes"]["fcking_cia"] = "VOX_FLA1_006D_BARN";
	
	//binocular - patrols
	level.scr_sound["carter"]["light_patrols"] = "VOX_FLA1_007C_CART";
	level.scr_sound["barnes"]["copy_that"] = "VOX_FLA1_008B_BARN";
	level.scr_sound["barnes"]["broad_space"] = "VOX_FLA1_008C_BARN";
	level.scr_sound["carter"]["bring_back"] = "VOX_FLA1_009A_CART";
	
	//binocular - general's convoy
	level.scr_sound["bowman"]["convoy"] = "VOX_FLA1_010A_HUDS";
	level.scr_sound["barnes"]["eyes_on"] = "VOX_FLA1_011A_BARN";
	level.scr_sound["barnes"]["vips"] = "VOX_FLA1_012B_BARN";
	level.scr_sound["barnes"]["target_presence"] = "VOX_FLA1_013C_BARN";
	
	// start trek
	level.scr_sound["barnes"]["comm_link"] = "VOX_FLA1_014B_BARN";
	level.scr_sound["bowman"]["copy_moving"] = "VOX_FLA1_015A_HUDS";
	level.scr_sound["barnes"]["on_me"] = "VOX_FLA1_016A_BARN";
	
	// patrols
	level.scr_sound["barnes"]["put_down"] = "VOX_FLA1_017A_BARN";
	level.scr_sound["barnes"]["stay_close"] = "VOX_FLA1_018A_BARN";
	level.scr_sound["carter"]["behind_you"] = "VOX_FLA1_019A_CART";
	level.scr_sound["barnes"]["move_up"] = "VOX_FLA1_022A_BARN";
	level.scr_sound["barnes"]["mine"] = "VOX_FLA1_023A_BARN";
	
	// tirechange
	level.scr_sound["barnes"]["russian_engineering"] = "VOX_FLA1_024A_BARN";
	level.scr_sound["barnes"]["rogue_vehicle"] = "VOX_FLA1_025A_BARN";
	level.scr_sound["barnes"]["holy"] = "VOX_FLA1_050A_BARN";
	level.scr_sound["bowman"]["comm_down"] = "VOX_FLA1_050B_HUDS";
	level.scr_sound["barnes"]["rp_south"] = "VOX_FLA1_026B_BARN";
	level.scr_sound["barnes"]["move"] = "VOX_FLA1_027A_BARN";
	*/
}


// ending_doors_playeranim()
// {
// 	hide_viewmodel();
// 	
// 	align_struct = getstruct("double_door_align_struct", "targetname");
// 	align_struct thread tunnel_double_doors();
// //	if (!IsDefined(level.player_hands))
// //	{
// //		level.player_hands = Spawn_anim_model( "player_hands" );
// //	}
// 		
// 	level.player_hands = Spawn( "script_model", level.player.origin );
// 	level.player_hands SetModel( "viewmodel_usa_blackops_urban_player_fullbody" );
// 	level.player_hands UseAnimTree(level.scr_animtree[ "player_hands" ]);			//-- Set the animtree
// 	level.player_hands.animname = "player_hands";
// 	
// 	align_struct anim_first_frame(level.player_hands, "enter_morgue");
// 	level.player_hands Hide();
// 	get_players()[0] startcameratween(0.1);
// 	get_players()[0] PlayerLinkToAbsolute(level.player_hands);
// 	
// 	time = GetAnimLength(level.scr_anim["player_hands"]["enter_morgue"]);
// 	align_struct thread anim_single_aligned(level.player_hands, "enter_morgue");
// 	wait 0.2;
// 	level.player_hands Show();
// 	
// 	wait time - 0.2;
// 	get_players()[0] Unlink();
// 	level.player_hands Delete();
// 	
// 	show_viewmodel();
// 	
// //	flag_set("through_morgue_doors");
// 
// 	flag_set( "player_door_anim_done" );
// 
// }

/*
{
	hide_viewmodel();
	
	align_struct = getstruct("morgue_doors_vin_spot", "targetname");
	align_struct thread e3_morgue_doors_objectanim();
	if (!IsDefined(level.player_hands))
	{
		level.player_hands = Spawn_anim_model( "player" );
	}


	level.player_hands.animname = "player";
	
	align_struct anim_first_frame(level.player_hands, "enter_morgue");
	level.player_hands Hide();
	get_players()[0] startcameratween(0.1);
	get_players()[0] PlayerLinkToAbsolute(level.player_hands);
	
	time = GetAnimLength(level.scr_anim["player"]["enter_morgue"]);
	align_struct thread anim_single_aligned(level.player_hands, "enter_morgue");
	wait 0.2;
	level.player_hands Show();
	
	wait time - 0.2;
	get_players()[0] Unlink();
	level.player_hands Delete();
	
	show_viewmodel();
	
	flag_set("through_morgue_doors");
}

*/

show_viewmodel(time)
{
	if (IsDefined(time))
	{
		wait time;
	}
	get_players()[0] ShowViewModel();
	get_players()[0] EnableWeapons();
}

hide_viewmodel(time)
{
	if (IsDefined(time))
	{
		wait time;
	}
	get_players()[0] HideViewModel();
	get_players()[0] DisableWeapons();
}

#using_animtree("animated_props");
//tunnel_double_doors()
//{
//	//level waittill ("open_morgue_doors");
//	gas_start_door_l = GetEnt("gas_start_door_r", "targetname");
//	gas_start_door_r = GetEnt("gas_start_door_l", "targetname");
//	
//	gas_start_door_l.animname = "gas_start_door_l";
//	gas_start_door_l UseAnimTree( #animtree );
//	gas_start_door_r.animname = "gas_start_door_r";
//	gas_start_door_r UseAnimTree( #animtree );
//	
//	gas_start_door_l._org = gas_start_door_l.origin;
//	gas_start_door_l._ang = gas_start_door_l.angles;
//	
//	gas_start_door_r._org = gas_start_door_r.origin;
//	gas_start_door_r._ang = gas_start_door_r.angles;
//	
//	//self thread origin_animate_jnt_aligned(door_l, "morgue_dooropen");
//	//self thread origin_animate_jnt_aligned(door_r, "morgue_dooropen");
//	
//	self thread anim_single_aligned(gas_start_door_l, "morgue_dooropen");
//	self anim_single_aligned(gas_start_door_r, "morgue_dooropen");
//
//	wait 10;
//	
//	gas_start_door_l Delete();
//	gas_start_door_r Delete();
//	
////	doors = GetEntArray("morgue_entrance_door_doubles", "targetname");
////	doors[0] Show();
////	doors[1] Show();
//}

//slide 1
slide_one_pre_cut_effect( guy )
{
	level flashback_movie_play( 1.0 );
}

slide_one_flash_in_effect( guy )
{
	thread play_bink_for_time("flashpoint_number_flash_1", 0, RandomFloatRange(0.15,0.35), 0, 1);
}

slide_one_flash_out_effect( guy )
{
	level flashback_movie_play( 1.0 );
}
//slide 1

pre_cut_effect( guy )
{
	thread play_bink_for_time("flashpoint_number_flash_1", 0, RandomFloatRange(0.15,0.35), 0, 1);
}

cut_effect( guy )
{
	level flashback_movie_play( 1.0 );
}

flash_in_effect( guy )
{
	thread play_bink_for_time("flashpoint_number_flash_1", 0, RandomFloatRange(0.15,0.35), 0, 1);
}

flash_out_effect( guy )
{
	level flashback_movie_play( 1.0 );
}

zoom_fov_effect( guy )
{
	thread play_bink_for_time("flashpoint_number_flash_1", 0, RandomFloatRange(0.15,0.35), 0, 1);

}

////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////
