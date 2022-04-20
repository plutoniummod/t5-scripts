#include maps\_utility;
#include common_scripts\utility;
#include maps\_utility_code;
#include maps\_anim;
#include maps\fullahead_drones;
#include maps\fullahead_util;
#include maps\_music;

main()
{
	init_voice();
	shared_generic_human();
	player_fullahead();
	objects_fullahead();
	object_animation();
	init_snowcat_animation();

	maps\_anim::init();
}
#using_animtree("animated_props");
object_animation()
{
	level.scr_anim[ "player_cam" ][ "narr_3" ] = %o_full_interstitial_03_camera;
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#using_animtree ("generic_human");
shared_generic_human()
{
	level.scr_anim[ "generic" ][ "run_fast"	]			= %combat_run_fast_3;
	level.scr_anim[ "generic" ][ "patrol_walk" ]		= %patrol_bored_patrolwalk;
	level.scr_anim[ "generic" ][ "smoke" ][0]			= %ch_flash_b01_guardssmoking_guy1;
	level.scr_anim[ "generic" ][ "idle_stand" ][0]		= %casual_stand_v2_idle;
	level.scr_anim[ "generic" ][ "casual_walk" ]		= %ch_pentagon_npc_casual_walk;
	level.scr_anim[ "generic" ][ "shoot_stand" ]		= %stand_shoot_run_forward;

// 	level.scr_anim[ "generic" ][ "crawl1" 		]		= %ch_berlin2_crawl1;
// 	level.scr_anim[ "generic" ][ "crawl1_die" 	]		= %ch_berlin2_crawl1_die;
// 	level.scr_anim[ "generic" ][ "crawl1_loop" 	]		= %ch_berlin2_crawl1_loop;
// 	level.scr_anim[ "generic" ][ "crawl1_shot" 	]		= %ch_berlin2_crawl1_shot;
// 
// 	level.scr_anim[ "generic" ][ "crawl2" 		]		= %ch_berlin2_crawl2;
// 	level.scr_anim[ "generic" ][ "crawl2_die" 	]		= %ch_berlin2_crawl2_die;
// 	level.scr_anim[ "generic" ][ "crawl2_loop" 	]		= %ch_berlin2_crawl2_loop;
// 	level.scr_anim[ "generic" ][ "crawl2_shot" 	]		= %ch_berlin2_crawl2_shot;
// 
// 	level.scr_anim[ "generic" ][ "crawl3" 		]		= %ch_berlin2_crawl3;
// 	level.scr_anim[ "generic" ][ "crawl3_die" 	]		= %ch_berlin2_crawl3_die;
// 	level.scr_anim[ "generic" ][ "crawl3_loop" 	]		= %ch_berlin2_crawl3_loop;
// 	level.scr_anim[ "generic" ][ "crawl3_shot" 	]		= %ch_berlin2_crawl3_shot;
// 
// 	level.scr_anim[ "generic" ][ "wounded_a" 	]		= %ch_makinraid_wounded_a;
// 	level.scr_anim[ "generic" ][ "wounded_b" 	]		= %ch_makinraid_wounded_b;
// 	level.scr_anim[ "generic" ][ "wounded_c" 	]		= %ch_makinraid_wounded_c;

	level.scr_anim[ "generic" ][ "crate_carry" 	][0]	= %ch_full_b01_crate_carry;
	addNotetrack_customFunction("generic", "attach_crate", ::notetrack_attach_crate, "crate_carry");
	addNotetrack_customFunction("generic", "detach_crate", ::notetrack_detach_crate, "crate_carry");
	
	level.scr_anim[ "generic" ][ "surrender1" 	]		= %ch_full_b03_surrender01;
	level.scr_anim[ "generic" ][ "surrender2" 	]		= %ch_full_b03_surrender02;
	level.scr_anim[ "generic" ][ "surrender3" 	]		= %ch_full_b03_surrender03;
	level.scr_anim[ "generic" ][ "surrender4" 	]		= %ch_full_b03_surrender04;
	level.scr_anim[ "generic" ][ "surrender5" 	]		= %ch_full_b03_surrender05;
	level.scr_anim[ "generic" ][ "surrender1_loop" ][0]	= %ch_full_b03_surrender_loop01;
	level.scr_anim[ "generic" ][ "surrender2_loop" ][0]	= %ch_full_b03_surrender_loop02;
	level.scr_anim[ "generic" ][ "surrender3_loop" ][0]	= %ch_full_b03_surrender_loop03;
	level.scr_anim[ "generic" ][ "surrender4_loop" ][0]	= %ch_full_b03_surrender_loop04;
	level.scr_anim[ "generic" ][ "surrender5_loop" ][0]	= %ch_full_b03_surrender_loop05;

// 	level.scr_anim[ "generic" ][ "pleading1" 	]		= %ch_full_b03_pleading01;
// 	level.scr_anim[ "generic" ][ "pleading2" 	]		= %ch_full_b03_pleading02;
// 	level.scr_anim[ "generic" ][ "pleading3" 	]		= %ch_full_b03_pleading03;
// 	level.scr_anim[ "generic" ][ "pleading1_loop" ][0]	= %ch_full_b03_pleading_loop01;
// 	level.scr_anim[ "generic" ][ "pleading2_loop" ][0]	= %ch_full_b03_pleading_loop02;
// 	level.scr_anim[ "generic" ][ "pleading3_loop" ][0]	= %ch_full_b03_pleading_loop03;

	level.scr_anim[ "generic" ][ "fence_climb" 	]		= %ch_full_b03_fencescale01;

	level.scr_anim[ "generic" ][ "snow_climb1" 	]		= %ch_full_b03_snowbank_climb_01;
	level.scr_anim[ "generic" ][ "snow_climb2" 	]		= %ch_full_b03_snowbank_climb_02;

	level.scr_anim[ "generic" ][ "vista1" 		]		= %ch_full_b01_vistascan_01;
	level.scr_anim[ "generic" ][ "vista2" 		]		= %ch_full_b01_vistascan_02;

// 	level.scr_anim[ "generic" ][ "rope_slide" ][0]		= %ai_climb_rope_idle;

// 	level.scr_anim[ "generic" ][ "fight1_russian"]		= %ch_berlin1_e3vignette3_russian;
// 	level.scr_anim[ "generic" ][ "fight1_german"]		= %ch_berlin1_e3vignette3_german;
// 
// 	level.scr_anim[ "generic" ][ "fight2_russian"]		= %ch_berlin1_e3vignette4_russian;
// 	level.scr_anim[ "generic" ][ "fight2_german"]		= %ch_berlin1_e3vignette4_german;

	level.scr_anim[ "generic" ][ "hand2hand_1_loop_russian"][0] = %ch_full_b03_hand_to_hand_01_loop_russian;
	level.scr_anim[ "generic" ][ "hand2hand_1_loop_german"][0]  = %ch_full_b03_hand_to_hand_01_loop_german;
	level.scr_anim[ "generic" ][ "hand2hand_1_russian"]         = %ch_full_b03_hand_to_hand_01_russian;
	level.scr_anim[ "generic" ][ "hand2hand_1_german"]          = %ch_full_b03_hand_to_hand_01_german;
	level.scr_anim[ "generic" ][ "hand2hand_1_end_russian"]     = %ch_full_b03_hand_to_hand_01_end_russian;

	level.scr_anim[ "generic" ][ "hand2hand_2_loop_russian"][0] = %ch_full_b03_hand_to_hand_02_loop_russian;
	level.scr_anim[ "generic" ][ "hand2hand_2_loop_german"][0]  = %ch_full_b03_hand_to_hand_02_loop_german;
	level.scr_anim[ "generic" ][ "hand2hand_2_russian"]         = %ch_full_b03_hand_to_hand_02_russian;
	level.scr_anim[ "generic" ][ "hand2hand_2_german"]          = %ch_full_b03_hand_to_hand_02_german;
	level.scr_anim[ "generic" ][ "hand2hand_2_end_russian"]     = %ch_full_b03_hand_to_hand_02_end_russian;

	level.scr_anim[ "generic" ][ "hand2hand_3_loop_russian"][0] = %ch_full_b03_hand_to_hand_03_loop_russian;
	level.scr_anim[ "generic" ][ "hand2hand_3_loop_german"][0]  = %ch_full_b03_hand_to_hand_03_loop_german;
	level.scr_anim[ "generic" ][ "hand2hand_3_russian"]         = %ch_full_b03_hand_to_hand_03_russian;
	level.scr_anim[ "generic" ][ "hand2hand_3_german"]          = %ch_full_b03_hand_to_hand_03_german;
	level.scr_anim[ "generic" ][ "hand2hand_3_end_russian"]     = %ch_full_b03_hand_to_hand_03_end_russian;

	level.scr_anim[ "generic" ][ "hand2hand_4_loop_russian"][0] = %ch_full_b03_hand_to_hand_04_loop_russian;
	level.scr_anim[ "generic" ][ "hand2hand_4_loop_german"][0]  = %ch_full_b03_hand_to_hand_04_loop_german;
	level.scr_anim[ "generic" ][ "hand2hand_4_russian"]         = %ch_full_b03_hand_to_hand_04_russian;
	level.scr_anim[ "generic" ][ "hand2hand_4_german"]          = %ch_full_b03_hand_to_hand_04_german;
	level.scr_anim[ "generic" ][ "hand2hand_4_end_russian"]     = %ch_full_b03_hand_to_hand_04_end_russian;

	level.scr_anim[ "generic" ][ "hand2hand_5_loop_russian"][0] = %ch_full_b03_hand_to_hand_05_loop_russian;
	level.scr_anim[ "generic" ][ "hand2hand_5_loop_german"][0]  = %ch_full_b03_hand_to_hand_05_loop_german;
	level.scr_anim[ "generic" ][ "hand2hand_5_russian"]         = %ch_full_b03_hand_to_hand_05_russian;
	level.scr_anim[ "generic" ][ "hand2hand_5_german"]          = %ch_full_b03_hand_to_hand_05_german;
	level.scr_anim[ "generic" ][ "hand2hand_5_end_russian"]     = %ch_full_b03_hand_to_hand_05_end_russian;
	
	// dead frozen guys in ship
	level.scr_anim[ "generic" ][ "frozen1"]		= %ch_full_b05_death_poses_01;
	level.scr_anim[ "generic" ][ "frozen2"]		= %ch_full_b05_death_poses_02;
	level.scr_anim[ "generic" ][ "frozen3"]		= %ch_full_b05_death_poses_03;
	level.scr_anim[ "generic" ][ "frozen4"]		= %ch_full_b05_death_poses_04;
	level.scr_anim[ "generic" ][ "frozen5"]		= %ch_full_b05_death_poses_05;
	level.scr_anim[ "generic" ][ "frozen6"]		= %ch_full_b05_death_poses_06;
	
	// snowcat anims
	level.scr_anim[ "generic" ][ "snowcat_guy2_getin"]		= %crew_truck_guy2_climbin;
	level.scr_anim[ "generic" ][ "snowcat_guy3_getin"]		= %crew_truck_guy3_climbin;
	level.scr_anim[ "generic" ][ "snowcat_guy4_getin"]		= %crew_truck_guy4_climbin;
	level.scr_anim[ "generic" ][ "snowcat_guy6_getin"]		= %crew_truck_guy6_climbin;
	level.scr_anim[ "generic" ][ "snowcat_guy7_getin"]		= %crew_truck_guy7_climbin;
	level.scr_anim[ "generic" ][ "snowcat_guy8_getin"]		= %crew_truck_guy8_climbin;
	level.scr_anim[ "generic" ][ "snowcat_guy2_sit_idle"][0]	= %crew_truck_guy2_sit_idle;
	level.scr_anim[ "generic" ][ "snowcat_guy3_sit_idle"][0]	= %crew_truck_guy3_sit_idle;
	level.scr_anim[ "generic" ][ "snowcat_guy4_sit_idle"][0]	= %crew_truck_guy4_sit_idle;
	level.scr_anim[ "generic" ][ "snowcat_guy6_sit_idle"][0]	= %crew_truck_guy6_sit_idle;
	level.scr_anim[ "generic" ][ "snowcat_guy7_sit_idle"][0]	= %crew_truck_guy7_sit_idle;
	level.scr_anim[ "generic" ][ "snowcat_guy8_sit_idle"][0]	= %crew_truck_guy8_sit_idle;
 	level.scr_anim[ "generic" ][ "snowcat_driver_idle"][0]		= %crew_snowcat_driver_idle;
	level.scr_anim[ "generic" ][ "blink_1"][0]	= %f_idle_casual_v1;
	level.scr_anim[ "generic" ][ "blink_2"][0]	= %f_idle_alert_v3;
	level.scr_anim[ "generic" ][ "blink_3"][0]	= %f_idle_alert_v1;
	level.scr_anim[ "generic" ][ "idle_loop"]	= %ch_flash_b01_guardssmoking_guy1;


	//unarmed walk for drag and kraven
	level.scr_anim[ "kravchenko" ][ "brisk_walk" ] 			= %ch_full_b01_unarmed_walk;
	level.scr_anim[ "dragovich" ][ "brisk_walk" ] 			= %ch_full_b01_unarmed_walk;

	
	// reznov cutscene idle anim, tempish
	level.scr_anim[ "generic" ][ "bench_sit" ][0]		= %civilian_sitting_talking_A_1;
	
	// guys at the start of shipfirefight picking up a gun
	level.scr_anim[ "generic" ][ "weapon_pickup1" ]		= %ai_prisoner_weapon_pick_up_09;
	addNotetrack_customFunction("generic", "weapon_pickup", ::firefight_friendly_weapon_pickup1, "weapon_pickup1");
	level.scr_anim[ "generic" ][ "weapon_pickup2" ]		= %ai_prisoner_weapon_pick_up_03;
	addNotetrack_customFunction("generic", "weapon_pickup", ::firefight_friendly_weapon_pickup2, "weapon_pickup2");


	// generic traversals
	level.scr_anim[ "generic" ][ "jump_across_72" ]		= %ai_jump_across_72;
	//level.scr_anim[ "generic" ][ "climb_railing" ]		= %windowclimb;

	// custom retreat anims
	level.scr_anim[ "generic" ][ "retreating_guy01" ] = %ch_full_b03_germans_retreating_guy01;
	level.scr_anim[ "generic" ][ "retreating_guy02" ] = %ch_full_b03_germans_retreating_guy02;
	
	addNotetrack_customFunction("generic", "kill_me", ::notetrack_blood_fx, "retreating_guy01");
	addNotetrack_customFunction("generic", "kill_me", ::notetrack_blood_fx, "retreating_guy02");

	// custom execution anims
	level.scr_anim[ "generic" ][ "germans_wounded_germ" ] = %ch_full_b03_germans_wounded_germ;
	level.scr_anim[ "generic" ][ "germans_wounded_russ" ] = %ch_full_b03_germans_wounded_russ;

	// animations for dudes burning to death
	level.scr_anim["generic"]["fire_death_0"]  = %exposed_death_neckgrab;
	level.scr_anim["generic"]["fire_death_1"]  = %wounded_bellycrawl_forward;
	level.scr_anim["generic"]["flame_death_run"]     = %ai_flame_death_run;
	level.scr_anim["generic"]["flame_death_run_die"] = %ai_flame_death_run_die;
	
	level.scr_anim["generic"]["onfire_a_1"] = %ch_full_b03_onfire_a_guy01;
	level.scr_anim["generic"]["onfire_a_2"] = %ch_full_b03_onfire_a_guy02;
	level.scr_anim["generic"]["onfire_a_3"] = %ch_full_b03_onfire_a_guy03;
	level.scr_anim["generic"]["onfire_b_1"] = %ch_full_b03_onfire_b_guy01;

	// retreating germans dying in snow drifts
	level.scr_anim["generic"]["snow_drift_death_1_guy1"] = %ch_full_b03_snow_drift_death_1_guy1;
	level.scr_anim["generic"]["snow_drift_death_1_guy2"] = %ch_full_b03_snow_drift_death_1_guy2;
	level.scr_anim["generic"]["snow_drift_death_2_guy1"] = %ch_full_b03_snow_drift_death_2_guy1;
	level.scr_anim["generic"]["snow_drift_death_2_guy2"] = %ch_full_b03_snow_drift_death_2_guy2;
	level.scr_anim["generic"]["snow_drift_death_3_guy1"] = %ch_full_b03_snow_drift_death_3_guy1;
	level.scr_anim["generic"]["snow_drift_death_3_guy2"] = %ch_full_b03_snow_drift_death_3_guy2;
	level.scr_anim["generic"]["snow_drift_death_3_guy3"] = %ch_full_b03_snow_drift_death_3_guy3;

	addNotetrack_customFunction("generic", "blood_fx", ::notetrack_blood_fx, "snow_drift_death_1_guy1");
	addNotetrack_customFunction("generic", "blood_fx", ::notetrack_blood_fx, "snow_drift_death_1_guy2");
	addNotetrack_customFunction("generic", "blood_fx", ::notetrack_blood_fx, "snow_drift_death_2_guy1");
	addNotetrack_customFunction("generic", "blood_fx", ::notetrack_blood_fx, "snow_drift_death_2_guy2");
	addNotetrack_customFunction("generic", "blood_fx", ::notetrack_blood_fx, "snow_drift_death_3_guy1");
	addNotetrack_customFunction("generic", "blood_fx", ::notetrack_blood_fx, "snow_drift_death_3_guy2");
	addNotetrack_customFunction("generic", "blood_fx", ::notetrack_blood_fx, "snow_drift_death_3_guy3");

	// patrenko kicking down doors in the base
	level.scr_anim["generic"]["kick_door_hangar"] = %ch_scripted_tests_b0_coveralign;
	addNotetrack_customFunction("generic", "doorkick", ::kick_door_hangar, "kick_door_hangar");


	level.scr_anim[ "generic" ][ "push_ship_door" ] = %ch_scripted_tests_b0_coveralign;

	// custom animations for the execution sequence
	level.scr_anim[ "russ" ][ "execution" ]			= %ch_full_b04_germanExecution_russ;
	level.scr_anim[ "krav" ][ "execution" ]			= %ch_full_b04_germanExecution_krav;
	addNotetrack_customFunction( "krav", "attach_knife", ::execution_attach_knife, "execution");
	addNotetrack_customFunction( "krav", "gunshot", ::execution_gunshot, "execution");


	
	level.scr_anim[ "ger1" ][ "execution" ]			= %ch_full_b04_germanExecution_ger1;
	addNotetrack_customFunction( "ger1", "blood_fx", ::execution_blood_fx1, "execution");
	level.scr_anim[ "ger2" ][ "execution" ]	 		= %ch_full_b04_germanExecution_ger2;
	addNotetrack_customFunction( "ger2", "blood_fx", ::execution_blood_fx2, "execution");
	level.scr_anim[ "ger3" ][ "execution" ]	 		= %ch_full_b04_germanExecution_ger3;
	addNotetrack_customFunction( "ger3", "blood_fx", ::execution_blood_fx3, "execution");
	level.scr_anim[ "ger4" ][ "execution" ]	 		= %ch_full_b04_germanExecution_ger4;
	addNotetrack_customFunction( "ger4", "blood_fx", ::execution_blood_fx4, "execution");
	level.scr_anim[ "ger5" ][ "execution" ]	 		= %ch_full_b04_germanExecution_ger5;
	addNotetrack_customFunction( "ger5", "blood_fx", ::execution_blood_fx5, "execution");
	level.scr_anim[ "ger6" ][ "execution" ]	 		= %ch_full_b04_germanExecution_ger6;
	addNotetrack_customFunction( "ger6", "blood_fx", ::execution_blood_fx6, "execution");
	addNotetrack_customFunction( "ger6", "throat_slice", ::execution_throat, "execution");



	level.scr_anim[ "russ" ][ "executionidle" ][0]		= %ch_full_b04_germanExecution_idle_russ;
	level.scr_anim[ "krav" ][ "executionidle" ][0]		= %ch_full_b04_germanExecution_idle_krav;
	level.scr_anim[ "ger1" ][ "executionidle" ][0]		= %ch_full_b04_germanExecution_idle_ger1;
	level.scr_anim[ "ger2" ][ "executionidle" ][0]	 	= %ch_full_b04_germanExecution_idle_ger2;
	level.scr_anim[ "ger3" ][ "executionidle" ][0]	 	= %ch_full_b04_germanExecution_idle_ger3;
	level.scr_anim[ "ger4" ][ "executionidle" ][0]	 	= %ch_full_b04_germanExecution_idle_ger4;
	level.scr_anim[ "ger5" ][ "executionidle" ][0]	 	= %ch_full_b04_germanExecution_idle_ger5;
	level.scr_anim[ "ger6" ][ "executionidle" ][0]	 	= %ch_full_b04_germanExecution_idle_ger6;
		
	// Dragovich-Steiner conversation
	level.scr_anim[ "dragovich" ][ "we_must_hurry" ] 	= %ch_full_b04_we_must_hurry_drag;
	level.scr_anim[ "generic" ][ "we_must_hurry_russ1" ]= %ch_full_b04_we_must_hurry_russ1;
	level.scr_anim[ "generic" ][ "we_must_hurry_russ2" ]= %ch_full_b04_we_must_hurry_russ2;
	level.scr_anim[ "steiner" ][ "we_must_hurry" ] 		= %ch_full_b04_we_must_hurry_stei;

	level.scr_anim[ "dragovich" ][ "we_must_hurry_idle" ][0]		= %ch_full_b04_we_must_hurry_idle_drag;
	level.scr_anim[ "kravchenko" ][ "we_must_hurry_idle" ][0]		= %ch_full_b04_we_must_hurry_idle_stei;
	level.scr_anim[ "generic" ][ "we_must_hurry_russ1_idle" ][0]	= %ch_full_b04_we_must_hurry_idle_russ1;
	level.scr_anim[ "generic" ][ "we_must_hurry_russ2_idle" ][0]	= %ch_full_b04_we_must_hurry_idle_russ2;
	level.scr_anim[ "steiner" ][ "we_must_hurry_idle" ][0] 			= %ch_full_b04_we_must_hurry_idle_stei;
	
	//animations for the clutter/barricade room
	level.scr_anim[ "generic" ][ "push_debris_guy01" ]					= %ch_full_b05_push_debris_open_guy01;
	level.scr_anim[ "generic" ][ "push_debris_guy02" ]					= %ch_full_b05_push_debris_open_guy02;
	level.scr_anim[ "generic" ][ "walk_through_hall_guy01" ]			= %ch_full_b05_walk_through_hall_guy01;
	level.scr_anim[ "generic" ][ "walk_through_hall_guy02" ]			= %ch_full_b05_walk_through_hall_guy02;
	level.scr_anim[ "generic" ][ "walk_through_hall_loop_guy01" ][0]	= %ch_full_b05_walk_through_hall_loop_guy01;
	level.scr_anim[ "generic" ][ "walk_through_hall_loop_guy02" ][0]	= %ch_full_b05_walk_through_hall_loop_guy02;
	
	//kicking the equipment down the stairs
	level.scr_anim[ "generic" ][ "kicking_equipment" ]			= %ch_full_b05_kicking_equipment;
	addNotetrack_customFunction( "generic", "detach_boiler", ::detach_boiler, "kicking_equipment");

		
	// Dock Worker Anims
	level.scr_anim[ "generic" ][ "dock_workers_e_1" ][0]		= %ch_rebirth_b01_dock_workers_e_1;
	level.scr_anim[ "generic" ][ "dock_workers_e_2" ][0]		= %ch_rebirth_b01_dock_workers_e_2;

	level.scr_anim[ "generic" ][ "dock_workers_f_1" ][0]		= %ch_rebirth_b01_dock_workers_f_1;
	level.scr_anim[ "generic" ][ "dock_workers_f_2" ][0]		= %ch_rebirth_b01_dock_workers_f_2;

// 	level.scr_anim[ "generic" ][ "dock_workers_h_1" ][0]		= %ch_rebirth_b01_dock_workers_h_1;
// 	level.scr_anim[ "generic" ][ "dock_workers_h_2" ][0]		= %ch_rebirth_b01_dock_workers_h_2;

	level.scr_anim[ "generic" ][ "dock_workers_radio" ][0]		= %ch_flash_b01_guardssmoking_guy1;

	level.scr_anim[ "generic" ][ "unloading_sleds_01" ]			= %ch_full_b04_unloading_sleds_01;
	level.scr_anim[ "generic" ][ "unloading_sleds_01_in" ]		= %ch_full_b04_unloading_sleds_loopin_01;
	level.scr_anim[ "generic" ][ "unloading_sleds_01_out" ]		= %ch_full_b04_unloading_sleds_loopout_01;
	level.scr_anim[ "generic" ][ "unloading_sleds_02" ]			= %ch_full_b04_unloading_sleds_02;
	level.scr_anim[ "generic" ][ "unloading_sleds_02_in" ]		= %ch_full_b04_unloading_sleds_loopin_02;
	level.scr_anim[ "generic" ][ "unloading_sleds_02_out" ]		= %ch_full_b04_unloading_sleds_loopout_02;
	level.scr_anim[ "generic" ][ "unloading_sleds_03" ]			= %ch_full_b04_unloading_sleds_03;
	level.scr_anim[ "generic" ][ "unloading_sleds_03_in" ]		= %ch_full_b04_unloading_sleds_loopin_03;
	level.scr_anim[ "generic" ][ "unloading_sleds_03_out" ]		= %ch_full_b04_unloading_sleds_loopout_03;
	level.scr_anim[ "generic" ][ "unloading_snowcat1" ][0]		= %ch_full_b04_unloadtruck_loop_guy01;
	level.scr_anim[ "generic" ][ "unloading_snowcat2" ][0]		= %ch_full_b04_unloadtruck_loop_guy02;
	level.scr_anim[ "generic" ][ "wave_to_snowcats" ][0]		= %ch_full_b01_wave_to_snowcats;
	
	addNotetrack_customFunction("generic", "attach_crate", ::snowcat_attach_crate, "unloading_snowcat1");
	addNotetrack_customFunction("generic", "detach_crate", ::snowcat_detach_crate, "unloading_snowcat1");

	addNotetrack_customFunction("generic", "attach_crate", ::snowcat_attach_crate, "unloading_snowcat2");
	addNotetrack_customFunction("generic", "detach_crate", ::snowcat_detach_crate, "unloading_snowcat2");

	// Background Anims
	level.scr_anim[ "generic" ][ "dogsled_beckon" ][0]			= %ch_fullahead_dogsled_beckon;
	level.scr_anim[ "generic" ][ "activity_spetz_crate" ][0]	= %ch_flash_ev03_base_activity_spetz_crate;
	level.scr_anim[ "generic" ][ "workingguard_loop" ][0]		= %ch_wmd_b05_workingguard_loop;
	level.scr_anim[ "generic" ][ "triage_med1" ][0]				= %ch_quag_b02_triage_med1;
	level.scr_anim[ "generic" ][ "triage_med2" ][0]				= %ch_quag_b02_triage_med2;
	level.scr_anim[ "generic" ][ "triage_med3" ][0]				= %ch_quag_b02_triage_med3;
	level.scr_anim[ "generic" ][ "triage_med4" ][0]				= %ch_quag_b02_triage_med4;
	level.scr_anim[ "generic" ][ "lower_supplies_ground" ][0]	= %ch_full_b01_lower_supplies_ground;
	level.scr_anim[ "generic" ][ "lower_supplies_ship" ][0]		= %ch_full_b01_lower_supplies_ship;
	level.scr_anim[ "generic" ][ "civilianwithclipboard" ][0]	= %ch_flash_b01_guardssmoking_guy1;
	level.scr_anim[ "generic" ][ "rail_prisoner5_loop" ][0]		= %ch_vor_b01_rail_prisoner5_loop;
	level.scr_anim[ "generic" ][ "rail_prisoner6_loop" ][0]		= %ch_vor_b01_rail_prisoner6_loop;
	level.scr_anim[ "generic" ][ "mortar_spotters_b" ][0]		= %ch_hue_b02_mortar_spotters_b;
	
	level.scr_anim[ "generic" ][ "falling_ice" ][0]		= %ch_full_b04_falling_ice_guy01;
	
	level.scr_anim[ "generic" ][ "brit_rail_climb1" ]		= %ch_full_b07_climb_ship_guy01;
	level.scr_anim[ "generic" ][ "brit_rail_climb2" ]		= %ch_full_b07_climb_ship_guy02;
	level.scr_anim[ "generic" ][ "brit_rail_climb3" ]		= %ch_full_b07_climb_ship_guy03;
	level.scr_anim[ "generic" ][ "brit_bridge_climb1" ]		= %ch_full_b07_climb_bridge_guy01;
	level.scr_anim[ "generic" ][ "brit_bridge_climb2" ]		= %ch_full_b07_climb_bridge_guy02;
	
	level.scr_anim[ "dragovich" ][ "heroberlin_talk" ][0] = %ch_full_b01_hero_of_berlin_talkloop_drag;
	level.scr_anim[ "kravchenko" ][ "heroberlin_talk" ][0] = %ch_full_b01_hero_of_berlin_talkloop_krav;
	
	level.scr_anim[ "dragovich" ]	[ "heroberlin" ] 	= %ch_full_b01_hero_of_berlin_drag;
	level.scr_anim[ "kravchenko" ]	[ "heroberlin" ] 	= %ch_full_b01_hero_of_berlin_krav;
	level.scr_anim[ "petrenko" ]	[ "heroberlin" ]	= %ch_full_b01_hero_of_berlin_patr;
	level.scr_anim[ "guy1" ]		[ "heroberlin" ]	= %ch_full_b01_hero_of_berlin_crowd1;
	level.scr_anim[ "guy2" ]		[ "heroberlin" ]	= %ch_full_b01_hero_of_berlin_crowd2;
	level.scr_anim[ "guy3" ]		[ "heroberlin" ]	= %ch_full_b01_hero_of_berlin_crowd3;
	level.scr_anim[ "guy4" ]		[ "heroberlin" ]	= %ch_full_b01_hero_of_berlin_crowd4;
	
	level.scr_anim[ "generic" ]	[ "snowcat_idle" ]	= %ch_full_b01_patrenko_snowcat_idle_patr;
	level.scr_anim[ "petrenko" ]	[ "snowcat_talk" ]	= %ch_full_b01_patrenko_snowcat_patr;
	
	level.scr_anim[ "kravchenko" ][ "find_steiner" ]  = %ch_full_b02_find_steiner_krav;
	level.scr_anim[ "dragovich" ][ "find_steiner" ]   = %ch_full_b02_find_steiner_drag;
	level.scr_anim[ "petrenko" ][ "find_steiner" ]    = %ch_full_b02_find_steiner_patr;
	
	level.scr_anim[ "kravchenko" ][ "find_steiner_idle" ][0]  = %ch_full_b02_find_steiner_idle_krav;
	level.scr_anim[ "dragovich" ][ "find_steiner_idle" ][0]   = %ch_full_b02_find_steiner_idle_drag;



	level.scr_anim[ "steiner" ][ "steinercin_idle" ] = %ch_full_b03_found_steiner_idle;
	level.scr_anim[ "steiner" ][ "steinercin" ] = %ch_full_b03_found_steiner;

	addNotetrack_customFunction("steiner", "Puff_cig", ::puff_the_magic_dragon, "steinercin");
	addNotetrack_customFunction("steiner", "exhale_smoke", ::exhale_smoke, "steinercin");
	addNotetrack_customFunction("steiner", "Cig_flick", ::flick_the_Cig, "steinercin");
	addNotetrack_customFunction("steiner", "cig_spark", ::flick_the_Cig, "steinercin");


	level.scr_anim[ "soldier1" ][ "steinercin" ] = %ch_full_b03_found_steiner_deadsoldier01;
	level.scr_anim[ "soldier2" ][ "steinercin" ] = %ch_full_b03_found_steiner_deadsoldier02;
	level.scr_anim[ "soldier3" ][ "steinercin" ] = %ch_full_b03_found_steiner_deadsoldier03;
	level.scr_anim[ "soldier4" ][ "steinercin" ] = %ch_full_b03_found_steiner_walking_dead_soldier;
	
	level.scr_anim[ "nevski" ][ "itstime_anim" ] = %ch_full_b01_its_time_nevski;
	level.scr_anim[ "petrenko" ][ "itstime_anim" ] = %ch_full_b01_its_time_petrenko;
	
	// betrayal anims start here
	level.scr_anim[ "dragovich" ][ "bet_s1" ] 	= %ch_full_b06_betrayal_shot1_drag;
	level.scr_anim[ "guy1" ][ "bet_s1" ] 		= %ch_full_b06_betrayal_shot1_guy01;
	level.scr_anim[ "guy2" ][ "bet_s1" ] 		= %ch_full_b06_betrayal_shot1_guy02;
	level.scr_anim[ "kravchenko" ][ "bet_s1" ] 	= %ch_full_b06_betrayal_shot1_krav;
	level.scr_anim[ "petrenko" ][ "bet_s1" ] 	= %ch_full_b06_betrayal_shot1_patr;
	level.scr_anim[ "reznov" ][ "bet_s1" ] 		= %ch_full_b06_betrayal_shot1_rezn;
	level.scr_anim[ "steiner" ][ "bet_s1" ] 	= %ch_full_b06_betrayal_shot1_stei;
	
	level.scr_anim[ "dragovich" ][ "bet_s2" ] 	= %ch_full_b06_betrayal_shot2_drag;
	level.scr_anim[ "guy1" ][ "bet_s2" ] 		= %ch_full_b06_betrayal_shot2_guy01;
	level.scr_anim[ "kravchenko" ][ "bet_s2" ] 	= %ch_full_b06_betrayal_shot2_krav;
	level.scr_anim[ "petrenko" ][ "bet_s2" ] 	= %ch_full_b06_betrayal_shot2_patr;
	level.scr_anim[ "reznov" ][ "bet_s2" ] 		= %ch_full_b06_betrayal_shot2_rezn;
	level.scr_anim[ "steiner" ][ "bet_s2" ] 	= %ch_full_b06_betrayal_shot2_stei;
	
	level.scr_anim[ "dragovich" ][ "bet_s3" ] 	= %ch_full_b06_betrayal_shot3_drag;
	level.scr_anim[ "guy1" ][ "bet_s3" ] 		= %ch_full_b06_betrayal_shot3_guy01;
	level.scr_anim[ "guy2" ][ "bet_s3" ] 		= %ch_full_b06_betrayal_shot3_guy02;
	level.scr_anim[ "kravchenko" ][ "bet_s3" ] 	= %ch_full_b06_betrayal_shot3_krav;
	level.scr_anim[ "petrenko" ][ "bet_s3" ] 	= %ch_full_b06_betrayal_shot3_patr;
	level.scr_anim[ "reznov" ][ "bet_s3" ] 		= %ch_full_b06_betrayal_shot3_rezn;
	
	level.scr_anim[ "guy1" ][ "bet_s4" ] 		= %ch_full_b06_betrayal_shot4_guy01;
	level.scr_anim[ "guy2" ][ "bet_s4" ] 		= %ch_full_b06_betrayal_shot4_guy02;
	level.scr_anim[ "guy3" ][ "bet_s4" ] 		= %ch_full_b06_betrayal_shot4_guy03;
	level.scr_anim[ "guy4" ][ "bet_s4" ] 		= %ch_full_b06_betrayal_shot4_guy04;
	level.scr_anim[ "petrenko" ][ "bet_s4" ] 	= %ch_full_b06_betrayal_shot4_patr;
	level.scr_anim[ "reznov" ][ "bet_s4" ] 		= %ch_full_b06_betrayal_shot4_rezn;
	
	level.scr_anim[ "guy1" ][ "bet_s5" ] 		= %ch_full_b06_betrayal_shot5_guy01;
	level.scr_anim[ "guy2" ][ "bet_s5" ] 		= %ch_full_b06_betrayal_shot5_guy02;
	level.scr_anim[ "guy3" ][ "bet_s5" ] 		= %ch_full_b06_betrayal_shot5_guy03;
	level.scr_anim[ "petrenko" ][ "bet_s5" ] 	= %ch_full_b06_betrayal_shot5_patr;
	level.scr_anim[ "reznov" ][ "bet_s5" ] 		= %ch_full_b06_betrayal_shot5_rezn;
	
	level.scr_anim[ "dragovich" ][ "bet_s6" ] 	= %ch_full_b06_betrayal_shot6_drag;
	level.scr_anim[ "kravchenko" ][ "bet_s6" ] 	= %ch_full_b06_betrayal_shot6_krav;
	level.scr_anim[ "steiner" ][ "bet_s6" ] 	= %ch_full_b06_betrayal_shot6_stei;

	level.scr_anim[ "petrenko" ][ "bet_s7" ] 	= %ch_full_b06_nova6_death_patr;
	level.scr_anim[ "belov" ][ "bet_s7" ] 		= %ch_full_b06_nova6_death_belo; // these three are full-length
	level.scr_anim[ "vikharev" ][ "bet_s7" ] 	= %ch_full_b06_nova6_death_vikh;
	
	addNotetrack_customFunction("petrenko", "vomit_floor", ::vomit_floor, "bet_s7");
	addNotetrack_customFunction("petrenko", "vomit_glass", ::vomit_glass, "bet_s7");

			
	level.scr_anim[ "guy1" ][ "bet_s7" ] 		= %ch_full_b06_nova6_death_sld1;
	level.scr_anim[ "guy2" ][ "bet_s7" ] 		= %ch_full_b06_nova6_death_sld2; // these five end at varying times
	level.scr_anim[ "guy3" ][ "bet_s7" ] 		= %ch_full_b06_nova6_death_sld3;
	level.scr_anim[ "tvelin" ][ "bet_s7" ] 		= %ch_full_b06_nova6_death_tvel;
	level.scr_anim[ "nevski" ][ "bet_s7" ] 		= %ch_full_b06_nova6_death_nevs;
				
	level.scr_anim[ "brit1" ][ "bet_s8" ] 		= %ch_full_b06_betrayal_shot7_brit1;
	level.scr_anim[ "brit2" ][ "bet_s8" ] 		= %ch_full_b06_betrayal_shot7_brit2;
	level.scr_anim[ "brit3" ][ "bet_s8" ] 		= %ch_full_b06_betrayal_shot7_brit3;

	// betrayal anims end here
	
	// post betrayal cinematic
	level.scr_anim[ "kravchenko" ][ "dragovich_leaves" ] 	= %ch_full_b07_dragovich_leaves_krav;
	level.scr_anim[ "dragovich" ][ "dragovich_leaves" ]   	= %ch_full_b07_dragovich_leaves_drag;
	level.scr_anim[ "dragovich" ][ "idle_stand" ][0]		= %casual_stand_v2_idle;
	level.scr_anim[ "kravchenko" ][ "idle_stand" ][0]		= %casual_stand_v2_idle;
	level.scr_anim[ "steiner" ][ "dragovich_leaves" ] 		= %ch_full_b07_dragovich_leaves_stei;
	level.scr_anim[ "steiner" ][ "idle_stand" ][0]			= %casual_stand_v2_idle;
	level.scr_anim[ "guy_1" ][ "dragovich_leaves" ] 		= %ch_full_b07_dragovich_leaves_guy01;
	level.scr_anim[ "guy_2" ][ "dragovich_leaves" ] 		= %ch_full_b07_dragovich_leaves_guy02;
	addNotetrack_customFunction("dragovich", "redshirt_vo", ::dragovich_leaves_redshirt_vo, "dragovich_leaves");
	addNotetrack_customFunction("dragovich", "earthquake", ::dragovich_leaves_earthquake, "dragovich_leaves");
	addNotetrack_customFunction("guy_1", "grenade", ::dragovich_leaves_grenade, "dragovich_leaves");
	
	level.scr_anim[ "Nevski" ][ "worried" ]					= %ch_full_b07_dragovich_leaves_nevs;
	level.scr_anim[ "Tvelin" ][ "worried" ]					= %ch_full_b07_dragovich_leaves_tvel;
	
	
	
	level.scr_anim[ "petrenko" ][ "ship_point" ] 			= %ch_full_b04_point_the_way;
	level.scr_anim[ "generic" ][ "ship_point_walk" ] 		= %ch_full_b04_point_the_way_walkloop;
	level.scr_anim[ "steiner" ][ "ship_point_walk" ] 		= %ch_full_b04_point_the_way_walkloop;
	
	level.scr_anim[ "dragovich" ][ "ship_point_walk" ] 		= %ch_full_b04_point_the_way_walkloop;
	level.scr_anim[ "kravchenko" ][ "ship_point_walk" ] 		= %ch_full_b04_point_the_way_walkloop;		
	
	// zipline animations
	level.scr_anim[ "nevski" ][ "use_zipline" ] 			= %ch_full_b07_nevski_use_rope_nevs;
	level.scr_anim[ "nevski" ][ "hits_ground" ] 			= %ch_full_b07_nevski_hits_hard_nevs;
	level.scr_anim[ "nevski" ][ "explosion_react" ]		= %ch_full_b07_nevski_explosion_react_nevs;
	level.scr_anim[ "nevski" ][ "end_run" ]						= %ai_prisoner_run_upright;

	level.scr_anim[ "petrenko" ][ "open_first_door" ]				= %ch_full_b05_petrenko_open_door;
	level.scr_anim[ "petrenko" ][ "open_first_door_approach" ]		= %ch_full_b05_petrenko_open_door_in;
	level.scr_anim[ "petrenko" ][ "open_first_door_wait_loop" ][0]		= %ch_full_b05_petrenko_open_door_loop_in;	
	
	
	// reznov narration
	level.scr_anim[ "generic" ][ "narr_1" ] 		= %ch_full_interstitial_01_reznov;
	level.scr_anim[ "generic" ][ "narr_2" ] 		= %ch_full_interstitial_02_reznov;
	level.scr_anim[ "generic" ][ "narr_3" ] 		= %ch_full_interstitial_03_reznov;
	level.scr_anim[ "generic" ][ "narr_4" ] 		= %ch_full_interstitial_04_reznov;

	addNotetrack_customFunction("generic", "start_fade_out", ::snow_fade_notify, "narr_1");
	addNotetrack_customFunction("generic", "start_fade_out", ::snow_fade_notify, "narr_2");
	addNotetrack_customFunction("generic", "start_fade_out", ::snow_fade_notify, "narr_3");
	addNotetrack_customFunction("generic", "start_fade_out", ::snow_fade_notify, "narr_4");

	
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

init_voice()
{
	// overtop loading screen
    level.scr_sound["Mason"]["anime"] = "vox_ful1_s01_001A_maso"; //NARRATION Relay message to CIA station chief at CCN...
    level.scr_sound["Mason"]["anime"] = "vox_ful1_s01_002A_maso"; //NARRATION Enemy base in Laos neutralized. Heavy casualties sustained...
    level.scr_sound["Mason"]["anime"] = "vox_ful1_s01_003A_maso"; //NARRATION Frank Woods, Joseph Bowman and the entire SOG team KIA.
    level.scr_sound["Mason"]["anime"] = "vox_ful1_s01_004A_maso"; //NARRATION Returning to Da Nang for debriefing.
    level.scr_sound["Mason"]["anime"] = "vox_ful1_s01_005A_maso"; //NARRATION Message ends.

    // overtop loading screen and initial fade to white
    level.scr_sound["Reznov"]["intro1"] = "vox_ful1_s01_006A_rezn"; //NARRATION Mason... listen to me...
    level.scr_sound["Reznov"]["intro2"] = "vox_ful1_s01_007A_rezn"; //NARRATION The sickening sense of loss... The bitter taste of defeat...
    level.scr_sound["Reznov"]["intro3"] = "vox_ful1_s01_008A_rezn"; //NARRATION I know it all too well... We are brothers Mason... We are the same.
    level.scr_sound["Reznov"]["intro4"] = "vox_ful1_s01_009A_rezn"; //NARRATION Dragovich. Steiner. Kravchenko. All must die.
    level.scr_sound["Reznov"]["intro5"] = "vox_ful1_s01_010A_rezn"; //NARRATION They have taken from you as they have taken from me...
    level.scr_sound["Mason"]["intro6"] = "vox_ful1_s01_011A_maso";  //NARRATION Then tell me, Reznov... Why is killing these men so important to you?
    level.scr_sound["Reznov"]["intro7"] = "vox_ful1_s01_012A_rezn"; //NARRATION When the war was over, our leaders began to gnaw on Germany's rotten carcass like a pack of rabid wolves - fighting over every scrap as though it were the last piece of meat they would ever see.
    level.scr_sound["Reznov"]["intro8"] = "vox_ful1_s01_013A_rezn"; //NARRATION The war was over - But the fighting continued....
    
    // white room intro starts here
    level.scr_sound["Reznov"]["intro9"] = "vox_ful1_s01_014A_rezn"; //NARRATION When the 3rd Shock Army became part of the Soviet Occupation Forces in Germany, it was clear that the end of the war did not herald our return to Russia...
    level.scr_sound["Reznov"]["intro10"] = "vox_ful1_s01_015A_rezn"; //NARRATION No... Our leaders had other plans...

    // lines at the start of the dogsled area, while doing the lookaround animations
    level.scr_sound["Soldier"]["loaded"] = "vox_ful1_s02_016A_sol1_f";   	//Everything is loaded. They are waiting.
    level.scr_sound["Petrenko"]["itistime"] = "vox_ful1_s02_017A_dimi_m"; 	//Viktor... It is time.
    level.scr_sound["Reznov"]["lastremnants"] = "vox_ful1_s01_018A_rezn_m"; 	//Yes, Dimitri... Time to hunt down the last remnants of the fascist Reich.
    											 
    level.scr_sound["Petrenko"]["grabthegear"] = "vox_ful1_s02_019A_dimi_m"; 	//Nevski... Grab the gear... We are moving out.

    // narration while the player heads down the hill to the sleds
    level.scr_sound["Reznov"]["bitter1"] = "vox_ful1_s01_020A_rezn"; //NARRATION My men and I had fought through the most bitter of winters on the Eastern front... We were no strangers to the cold?
    level.scr_sound["Reznov"]["bitter2"] = "vox_ful1_s02_020B_rezn"; //NARRATION The men and I had fought through the most bitter of winters on the Eastern front - We were no strangers to the cold?
    level.scr_sound["Reznov"]["bloodchills"] = "vox_ful1_s01_021A_rezn"; //NARRATION But even now, the blood in my veins chills when I think back to the events of that day...
    level.scr_sound["Reznov"]["farfar"] = "vox_ful1_s01_022A_rezn"; //NARRATION Far, far from home...

    // Player and Petrenko going down the hill
    level.scr_sound["Petrenko"]["whathere"] = "vox_ful1_s02_023A_dimi"; //What is here that is so important?
    level.scr_sound["Reznov"]["makename"] = "vox_ful1_s01_024A_rezn"; //General Dragovich wishes to make a name for himself. He believes this outpost houses something of great value to the motherland.
    
	// Brief IGC before getting going on the dogsleds
    level.scr_sound["Kravchenko"]["heroberlin"] = "vox_ful1_s02_025A_krav_m"; //Ahh... The hero of Berlin graces us with your presence!... Have you not tired of battle, Reznov?
    level.scr_sound["Reznov"]["russiaenemies"] = "vox_ful1_s01_026A_rezn_m"; //As long as Mother Russia has enemies, I will answer her call...    											  
    level.scr_sound["Dragovich"]["petty"] = "vox_ful1_s02_027A_drag_m"; //Put your petty rivalry aside, Kravchenko, Captain Reznov will do as he is told.
    level.scr_sound["Dragovich"]["onegerman"] = "vox_ful1_s02_028A_drag_m"; //We are here for one German and one German only... Doctor Freidrick Steiner.  This man has offered his cooperation to our cause...
    level.scr_sound["Dragovich"]["notharmed"] = "vox_ful1_s02_029A_drag_m"; //He is not to be harmed...  Disobey this order... and you will be shot!

    // discussion between Reznov and Patrenko while on the dogsleds
    level.scr_sound["Petrenko"]["stalingrad"] = "vox_ful1_s02_030A_dimi_m"; //What happened in Stalingrad, between you and Dragovich?
    level.scr_sound["Reznov"]["germanocc"] = "vox_ful1_s01_031A_rezn_m"; //When the German occupation began, he and his lap dog Kravchenko left my men and I hopelessly outnumbered...
    level.scr_sound["Reznov"]["promises"] = "vox_ful1_s01_032A_rezn_m"; //Promises of reinforcements were made.  Made... But not kept.
    level.scr_sound["Reznov"]["opportunists"] = "vox_ful1_s01_033A_rezn_m"; //Dragovich and Kravchenko are opportunists... Manipulators...
    level.scr_sound["Reznov"]["nottrusted"] = "vox_ful1_s01_034A_rezn_m"; //They are not to be trusted, Dimitri.

    // narration during the fade to white after the dogsleds, before the base
    level.scr_sound["Reznov"]["narrbase1"] = "vox_ful1_s01_035A_rezn"; //NARRATION Dimitri Petrenko was one of the bravest men I have ever known.
    level.scr_sound["Reznov"]["narrbase2"] = "vox_ful1_s01_036A_rezn"; //NARRATION He fought by my side from the Siege of Stalingrad to the fall of Berlin...
    level.scr_sound["Reznov"]["narrbase3"] = "vox_ful1_s02_037A_rezn"; //NARRATION The wounds he sustained ensuring our victory should have earned him a Hero's welcome in Russia...
    level.scr_sound["Reznov"]["narrbase4"] = "vox_ful1_s01_038A_rezn"; //NARRATION But Stalin had little need for heroes.
    
    // lines at the very start of the base by the dogsleds
    level.scr_sound["Dragovich"]["getsteiner"] = "vox_ful1_s03_039A_drag_m"; //The German must not be harmed - We need Steiner alive... Now move - both of you!
    level.scr_sound["Petrenko"]["letsgo"] = "vox_ful1_s03_040A_dimi_m"; //Let's go.

    // VO lines the first time you see surrendering guys
    level.scr_sound["Soldier"]["surrender"] = "vox_ful1_s03_041A_rrd8"; //They are trying to surrender!
    level.scr_sound["Reznov"]["theyhavetried"] = "vox_ful1_s01_042A_rezn"; //They have tried before...
    level.scr_sound["Reznov"]["donotlet"] = "vox_ful1_s03_043A_rezn"; //Do not let them.

    // lines for the patrenko building
    level.scr_sound["Petrenko"]["checkbuilding"] = "vox_ful1_s03_044A_dimi"; //Check the launch control building!
    level.scr_sound["Petrenko"]["nothere"] = "vox_ful1_s03_045A_dimi"; //He is not here...
    level.scr_sound["Reznov"]["nearship"] = "vox_ful1_s01_046A_rezn"; //He must be nearer the ship.

    // locating steiner at end of base
    level.scr_sound["Steiner"]["dontpoint"] = "vox_ful1_s03_047A_stei_m"; //Do not point that weapon at me, Russian dog...
    level.scr_sound["Steiner"]["takeme"] = "vox_ful1_s03_048A_stei_m"; //You will take me to Dragovich.

    // narration during the fade to white, after the base
    level.scr_sound["Reznov"]["narsteiner1"] = "vox_ful1_s01_049A_rezn"; //NARRATION As I looked into the German's eyes I saw all the evil of the Fascist Reich still burning strong...
    level.scr_sound["Reznov"]["narsteiner2"] = "vox_ful1_s01_050A_rezn"; //NARRATION At that moment, every fibre of my being yearned to put an end to his wretched life...
    level.scr_sound["Reznov"]["narsteiner3"] = "vox_ful1_s01_051A_rezn"; //NARRATION But I was a soldier then... I still believed in orders...
    
    // dragovich/steiner talking outside ship
    level.scr_sound["Steiner"]["musthurry"] = "vox_ful1_s03_052A_stei_m"; //We must hurry... There are Germans who would sooner see it destroyed than captured...
    level.scr_sound["Dragovich"]["assuredme"] = "vox_ful1_s03_053A_drag_m"; //You assured me that there would be no problems...
    level.scr_sound["Steiner"]["cannotcontrol"] = "vox_ful1_s03_054A_stei_m"; //I cannot control the actions of the SS, General Dragovich...  They are sworn to fight for the Reich till their last breath...
    level.scr_sound["Dragovich"]["futile"] = "vox_ful1_s03_055A_drag_m"; //Noble... but futile.
    level.scr_sound["Dragovich"]["finishup"] = "vox_ful1_s03_056A_drag_m"; //Kravchenko, finish up here.
    level.scr_sound["Dragovich"]["bringmen"] = "vox_ful1_s03_057A_drag_m"; //Reznov...bring your men.
    level.scr_sound["Reznov"]["movingout"] = "vox_ful1_s01_058A_rezn"; //Petrenko, Nevski, Belov, Vikharev... We are moving out!
    level.scr_sound["Dragovich"]["leadway"] = "vox_ful1_s03_059A_drag"; //Reznov, you and your men will lead the way.
    level.scr_sound["Reznov"]["yessir"] = "vox_ful1_s01_060A_rezn"; //Yes, Sir.

    // overtop the fade to white before the ship?
    level.scr_sound["Reznov"]["narship1"] = "vox_ful1_s03_061A_rezn"; //NARRATION By allying with Steiner, Dragovich had made a deal with the Devil - casting aside all the suffering we had endured at the hands of the Fascists.
    level.scr_sound["Reznov"]["narship2"] = "vox_ful1_s03_061B_rezn"; //NARRATION Dragovich and his men made a deal with the Devil - casting aside all the suffering we had endured at the hands of the Fascists.
    level.scr_sound["Reznov"]["narship3"] = "vox_ful1_s03_062A_rezn"; //NARRATION Everything that Russia had fought for was betrayed - the moment they chose to collaborate with those rats.
    level.scr_sound["Reznov"]["narship4"] = "vox_ful1_s03_062B_rezn"; //NARRATION Everything that Russia had fought for was betrayed - the moment they chose to lay with dogs.

    // opening the first door in the ship
    level.scr_sound["Petrenko"]["lightsteady"] = "vox_ful1_s04_063A_dimi"; //Keep the light steady, Viktor...

    // hallways up to the traversal room
    level.scr_sound["Dragovich"]["tellmemore"] = "vox_ful1_s04_064A_drag"; //Tell me more about your association with the Giftiger Sturm project, Steiner.
    level.scr_sound["Steiner"]["fuhrer"] = "vox_ful1_s04_065A_stei"; //In '43, the Fuhrer realized the allies could not be held back for much longer.
    level.scr_sound["Steiner"]["unconventional"] = "vox_ful1_s04_066A_stei"; //We began to look for more 'unconventional' solutions.
    level.scr_sound["Steiner"]["throughout"] = "vox_ful1_s04_067A_stei"; //Throughout the war, my own research was focussed on chemical weapons... It was meticulous and frustrating work...
    level.scr_sound["Steiner"]["whatwefinally"] = "vox_ful1_s04_068A_stei"; //However, what we finally developed was a weapon more effective than we had ever dared to imagine... The weapon now housed within this vessel.
    level.scr_sound["Dragovich"]["nova6"] = "vox_ful1_s04_069A_drag"; //Nova 6.

    // The room with the bodies and flags
    level.scr_sound["Petrenko"]["fordays"] = "vox_ful1_s04_070A_dimi"; //He's been dead for days... Before we attacked.
    level.scr_sound["Petrenko"]["why?"] = "vox_ful1_s04_071A_dimi"; //Why?
    level.scr_sound["Reznov"]["tothesemen"] = "vox_ful1_s04_072A_rezn"; //What happened to these men?
    level.scr_sound["Steiner"]["casualties"] = "vox_ful1_s04_073A_stei"; //Casualties of War...
    level.scr_sound["Petrenko"]["feelright"] = "vox_ful1_s04_074A_dimi"; //Something doesn't feel right.
    level.scr_sound["Dragovich"]["focused"] = "vox_ful1_s04_075A_drag"; //Keep your men focused, Reznov...
    level.scr_sound["Dragovich"]["wishanything"] = "vox_ful1_s04_076A_drag"; //We would not wish anything to happen to 'The Hero of Berlin'...

    // traversal room
    level.scr_sound["Petrenko"]["aroundcatwalks"] = "vox_ful1_s04_077A_dimi"; //I'll try to find a way around these catwalks.
    level.scr_sound["Petrenko"]["getthatlight"] = "vox_ful1_s04_078A_dimi"; //Reznov - get that light up here.

    // while traversing
    level.scr_sound["Petrenko"]["fremind1"] = "vox_ful1_s04_079A_dimi"; //Can't see anything...
    level.scr_sound["Petrenko"]["fremind2"] = "vox_ful1_s04_080A_dimi"; //Get some light on it.
    level.scr_sound["Petrenko"]["fremind3"] = "vox_ful1_s04_081A_dimi"; //Stay with me.
    level.scr_sound["Petrenko"]["fremind4"] = "vox_ful1_s04_086A_dimi"; //Over here, I need light.

    level.scr_sound["Petrenko"]["topthepipe"] = "vox_ful1_s04_082A_dimi"; //On top of the pipe.
    level.scr_sound["Petrenko"]["onthecatwalk"] = "vox_ful1_s04_083A_dimi"; //Get some light on the catwalk.
    level.scr_sound["Petrenko"]["lightinfront"] = "vox_ful1_s04_085A_dimi"; //Keep the light in front of me.
    level.scr_sound["Petrenko"]["anime"] = "vox_ful1_s04_084A_dimi"; //Keep that light on it.


    // before cargo door
    level.scr_sound["Dragovich"]["ch1"] = "vox_ful1_s04_087A_drag"; //However effective your Nova 6 chemical may be, you still had to find a way to unleash it...
    level.scr_sound["Steiner"]["ch2"] = "vox_ful1_s04_088A_stei"; //Long range V2 rockets... to be launched from this outpost.
    level.scr_sound["Steiner"]["ch3"] = "vox_ful1_s04_089A_stei"; //The targets were command and control centers. Washington DC was our first target... Then Moscow...
    level.scr_sound["Dragovich"]["ch4"] = "vox_ful1_s04_090A_drag"; //Mmmm... Ambitious and commendable, Herr Steiner...
    level.scr_sound["Steiner"]["ch5"] = "vox_ful1_s04_091A_stei"; //But we were too late. The British were upon us, and their bombers crippled this ship.
    level.scr_sound["Steiner"]["ch6"] = "vox_ful1_s04_092A_stei"; //Locked in the ice... We tried to salvage what could, but it was too late...

    // before black door
    level.scr_sound["Steiner"]["ch7"] = "vox_ful1_s04_093A_stei"; //Before we could initiate our first strike we heard the news -
    level.scr_sound["Steiner"]["ch8"] = "vox_ful1_s04_094A_stei"; //Germany had surrendered, and a Russian flag flew over Berlin.
    level.scr_sound["Steiner"]["ch9"] = "vox_ful1_s05_095A_stei"; //The SS had orders to destroy the ship if we were attacked.
    level.scr_sound["Kravchenko"]["ch10"] = "vox_ful1_s05_096A_krav"; //Clearly, they failed...
    level.scr_sound["Kravchenko"]["ch11"] = "vox_ful1_s05_097A_krav"; //The explosives were never activated.
    level.scr_sound["Steiner"]["ch12"] = "vox_ful1_s05_098A_stei"; //This is it...
    level.scr_sound["Dragovich"]["ch13"] = "vox_ful1_s05_099A_drag"; //Reznov - open the door.

    // overtop the big cutscene in the ship
    level.scr_sound["Reznov"]["bet1"] = "vox_ful1_s05_100A_rezn"; //We had found what we were looking for... Nova 6.  The German weapon of mass destruction now belonged to Mother Russia.
    level.scr_sound["Reznov"]["bet2"] = "vox_ful1_s05_101A_rezn"; //Or so it seemed.  Our victory was to be short lived.
    level.scr_sound["Reznov"]["bet3"] = "vox_ful1_s05_102A_rezn"; //Dragovich wanted to see the effects of the poison first hand.
    level.scr_sound["Reznov"]["bet4"] = "vox_ful1_s05_103A_rezn"; //It was also an opportunity to remove a thorn in his side.
    level.scr_sound["Reznov"]["bet5"] = "vox_ful1_s05_104A_rezn"; //I had long known of their distrust.
    level.scr_sound["Reznov"]["bet6"] = "vox_ful1_s05_105A_rezn"; //What kind of men they were.
    level.scr_sound["Reznov"]["bet7"] = "vox_ful1_s05_106A_rezn"; //It was a betrayal I should have forseen.
    level.scr_sound["Reznov"]["bet8"] = "vox_ful1_s05_107A_rezn"; //Dimitri Petrenko was a hero...
    level.scr_sound["Reznov"]["bet9"] = "vox_ful1_s05_108A_rezn"; //He deserved a hero's death.
    level.scr_sound["Reznov"]["bet10"] = "vox_ful1_s05_109A_rezn"; //Instead of giving his life for the glory of the motherland, he died for nothing... like an animal.
    level.scr_sound["Reznov"]["bet11"] = "vox_ful1_s05_110A_rezn"; //He should have died in Berlin...
    
    // as we're fading up, while the animation plays
    level.scr_sound["Reznov"]["watcheddie"] = "vox_ful1_s05_111A_rezn"; //As I watched my closest friend die, it soon became clear that we were not the only ones seeking the German weapons... The western allies circled like vultures...
    level.scr_sound["Reznov"]["ofcourse"] = 	"vox_ful1_s05_111C_rezn"; //Of course, Dragovich, Kravchenko and Steiner scattered like rats - leaving me to contend with the British.

		level.scr_sound["Soldier"]["ourpositions"] = "vox_ful1_s06_112A_rrd8_f"; //British commandos are assaulting our positions!
    level.scr_sound["Dragovich"]["backtoship!"] = "vox_ful1_s06_113A_drag"; //We need to get Steiner back to our ship!
    level.scr_sound["Dragovich"]["killthem!"] = "vox_ful1_s06_114A_drag"; //Kill them!

    // in the little room before the door gets knocked off its hinges
    level.scr_sound["Reznov"]["ourwayout"] = "vox_ful1_s06_115A_rezn"; //Go! - Fight our way out!
    
    // when you first see guys fastrope in the cargo bay
    level.scr_sound["Nevski"]["morebritish"] = "vox_ful1_s06_116A_nevs"; //More British!

    // heading out to the cargo bay, when the explosive objective is objectified
    level.scr_sound["Reznov"]["iwillarm"] = "vox_ful1_s06_117A_rezn"; //I will arm the explosives...
    level.scr_sound["Reznov"]["depths"] = "vox_ful1_s06_118A_rezn"; //We will plunge this vessel into the depths of hell!

    // right after the explosives are armed, after this the shootme spot should be objectified
    level.scr_sound["Reznov"]["move!"] = "vox_ful1_s06_119A_rezn"; //Move! We have to get off the ship!
    level.scr_sound["Nevski"]["doorsealed!"] = "vox_ful1_s06_120A_nevs"; //The door sealed!
    level.scr_sound["Nevski"]["gantries"] = "vox_ful1_s06_121A_nevs"; //Shoot the support beams! We can bring down those gantries!

    // when the catwalk falls in the cargo bay
    level.scr_sound["Reznov"]["yes!"] = "vox_ful1_s06_122A_rezn"; //Yes!
    level.scr_sound["Reznov"]["friendsgo"] = "vox_ful1_s06_123A_rezn"; //Go, my friends, GO!

    // Play these during the tear area
    level.scr_sound["Reznov"]["keepmoving"] = "vox_ful1_s06_124A_rezn"; //Keep moving!
    level.scr_sound["Reznov"]["notourwar"] = "vox_ful1_s06_125A_rezn"; //This is not our War!
    level.scr_sound["Nevski"]["whoarewe"] = "vox_ful1_s06_126A_nevs"; //Then who are we to fight?!!
    level.scr_sound["Reznov"]["EVERYONE!!!"] = "vox_ful1_s06_127A_rezn"; //EVERYONE!!!
    level.scr_sound["Reznov"]["standalone"] = "vox_ful1_s06_128A_rezn"; //We stand alone!

    // ???
    level.scr_sound["Nevski"]["anime"] = "vox_ful1_s06_129A_nevs"; //The battle is tearing the ship apart!!!

    // objectifying the zipline
    level.scr_sound["Nevski"]["usetherope"] = "vox_ful1_s06_130A_nevs"; //Reznov! We can use the rope!

    // when the player approaches the zipline
    level.scr_sound["Nevski"]["ropehurry"] = "vox_ful1_s06_131A_nevs"; //Down the rope! Hurry!
    level.scr_sound["Nevski"]["gogo"] = "vox_ful1_s06_132A_nevs"; //Go, Reznov!  Go!!!

    // as the player runs into the snow, fades to white
    level.scr_sound["Reznov"]["out1"] = "vox_ful1_s06_133A_rezn"; //NARRATION I escaped the ship, but I could not run forever... Eventually I was captured, and sent to Vorkuta...
    level.scr_sound["Reznov"]["out2"] = "vox_ful1_s06_134A_rezn"; //NARRATION Mason, listen to me...
    level.scr_sound["Reznov"]["out3"] = "vox_ful1_s06_134B_rezn"; //NARRATION We are running out of time, my friend...
    level.scr_sound["Reznov"]["out4"] = "vox_ful1_s06_136A_rezn"; //NARRATION Can you trust your leaders to destroy this weapon?... Or do you think they will use it?
    level.scr_sound["Reznov"]["out5"] = "vox_ful1_s06_136B_rezn"; //NARRATION Can you trust them to destroy it?Or do you think they will use it?
    level.scr_sound["Reznov"]["out6"] = "vox_ful1_s06_136C_rezn"; //NARRATION Tell me - What do you think your leaders will do with such a weapon?
    level.scr_sound["Reznov"]["out7"] = "vox_ful1_s06_137A_rezn"; //NARRATION The flag may be different, but the methods are the same.
    level.scr_sound["Reznov"]["out8"] = "vox_ful1_s06_138A_rezn"; //NARRATION They will use you, as they used me...
    level.scr_sound["Reznov"]["out9"] = "vox_ful1_s06_139A_rezn"; //NARRATION You must decide... Decide what you think is worth fighting for...
    level.scr_sound["Reznov"]["out10"] = "vox_ful1_s06_140A_rezn"; //NARRATION Dragovich... Kravchenko... Steiner...
    level.scr_sound["Reznov"]["out11"] = "vox_ful1_s06_141A_rezn"; //NARRATION These... 'men'... must die.
    
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~ NEW STUFF BELOW THIS LINE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    // base area stuff
    
    // right after Dragovich tells you to clear the base, go!
    level.scr_sound["Petrenko"]["itisgoodtofight"] = "vox_ful1_s03_300A_dimi"; //It is good to fight by your side once more.
    level.scr_sound["Reznov"]["yesmyfriend"] = "vox_ful1_s03_301A_rezn"; //Yes, my friend... One final victory.
    level.scr_sound["Reznov"]["searcheverycorner"] = "vox_ful1_s03_302A_rezn"; //Search every corner of this camp!  Only Steiner is to be spared.
    
    level.scr_sound["Reznov"]["reznovcheer"] = "vox_ful1_s03_328A_rezn"; //URA!!!
    level.scr_sound["Crowd"]["crowdcheer"] = "vox_ful1_s03_329A_crow"; //URA!!!
    
    // after the pass-through building and the 'they surrender' conversation
    level.scr_sound["Petrenko"]["notgivingup"] = "vox_ful1_s03_303A_dimi"; //They are not giving up without a fight!
    level.scr_sound["Reznov"]["menwithnothing"] = "vox_ful1_s03_304A_rezn"; //Men with nothing to lose make for a dangerous enemy, Dimitri.
    level.scr_sound["Reznov"]["becareful"] = "vox_ful1_s03_305A_rezn"; //Be careful, there may be more of them.
    level.scr_sound["Reznov"]["pushonmyfriends"] = "vox_ful1_s03_306A_rezn"; //Push on my friends, clear the next area.
    level.scr_sound["Reznov"]["crushall"] = "vox_ful1_s03_307A_rezn"; //Crush all who stand in our way!
    
    // additional lines for the launch control building
    level.scr_sound["Reznov"]["clearthebuilding"] = "vox_ful1_s03_308A_rezn"; //Clear the building.  Leave no stone unturned!
    level.scr_sound["Petrenko"]["checkupstairs"] = "vox_ful1_s03_309A_dimi"; //Check upstairs.
    
    level.scr_sound["Petrenko"]["weneedtobreak"] = "vox_ful1_s03_310A_dimi"; //Reznov! We need to break this barricade!
    level.scr_sound["Petrenko"]["grabthesmokegrenades1"] = "vox_ful1_s03_311A_dimi"; //Grab the Smoke grenades... Use them to mark the target for our mortar teams.
    level.scr_sound["Petrenko"]["grabthesmokegrenades2"] = "vox_ful1_s03_312A_dimi"; //Reznov - Grab the smoke Grenades!
    level.scr_sound["Petrenko"]["grabthesmokegrenades3"] = "vox_ful1_s03_313A_dimi"; //We need the smoke grenades, Reznov!
    level.scr_sound["Petrenko"]["throwoneatbarricade"] = "vox_ful1_s03_314A_dimi"; //Throw one at the base of the barricade!
    level.scr_sound["Petrenko"]["markthebarricade"] = "vox_ful1_s03_315A_dimi"; //Mark the barricade for the mortars!
    level.scr_sound["Petrenko"]["closertothebarricade"] = "vox_ful1_s03_316A_dimi"; //Closer to the barricade, Viktor!
    level.scr_sound["Petrenko"]["areyoudrunk"] = "vox_ful1_s03_317A_dimi"; //Are you drunk, Viktor? Throw it at the barricade!
    level.scr_sound["Petrenko"]["illmarkitmyself"] = "vox_ful1_s03_318A_dimi"; //I'll mark it myself, Reznov. Stand back!
    level.scr_sound["Petrenko"]["spotterswillneversee"] = "vox_ful1_s03_319A_dimi"; //The spotters will never see that smoke!
    level.scr_sound["Petrenko"]["throwitoutside"] = "vox_ful1_s03_320A_dimi"; //Throw it outside!
    level.scr_sound["Petrenko"]["outside"] = "vox_ful1_s03_321A_dimi"; //Outside, Reznov!
    level.scr_sound["Russian Soldier"]["wehavetarget"] = "vox_ful1_s03_322A_rrd9_f"; //We have your target.
    level.scr_sound["Russian Soldier"]["standby"] = "vox_ful1_s03_323A_rrd9_f"; //Stand by for mortars.
    level.scr_sound["Russian Soldier"]["firing1"] = "vox_ful1_s03_324A_rrd9_f"; //Firing mortars.
    level.scr_sound["Russian Soldier"]["firing2"] = "vox_ful1_s03_325A_rrd9_f"; //Firing - Stand by.
    level.scr_sound["Russian Soldier"]["firing3"] = "vox_ful1_s03_326A_rrd9_f"; //Mortars inbound.
    level.scr_sound["Russian Soldier"]["noclearshot"] = "vox_ful1_s03_327A_rrd9_f"; //We don't have a clear shot!
    
    // ???
    level.scr_sound["Reznov"]["spreadout"] = "vox_ful1_s03_330A_rezn"; //Spread out - Search every building!
    level.scr_sound["Reznov"]["findsteiner"] = "vox_ful1_s03_331A_rezn"; //Find Steiner!!
    level.scr_sound["Reznov"]["thiswaydimitri"] = "vox_ful1_s03_332A_rezn"; //This way, Dimitri!
    level.scr_sound["Reznov"]["diefascistrats"] = "vox_ful1_s03_333A_rezn"; //Die! You fascist rats!!
    
    // Smoke grenade cajoling
    level.scr_sound["Petrenko"]["usesmokegrenades1"] = "vox_ful1_s03_334A_dimi"; //Reznov - if  you have any more smoke grenades - Use them now!
    level.scr_sound["Petrenko"]["usesmokegrenades2"] = "vox_ful1_s03_335A_dimi"; //Use your smoke grenades!
    level.scr_sound["Petrenko"]["usesmokegrenades3"] = "vox_ful1_s03_336A_dimi"; //Use your smoke to mark targets for our mortars!
    
    // in the hangar and post-hangar building, where it's quiet
    level.scr_sound["Petrenko"]["wemustbegettingclose"] = "vox_ful1_s03_337A_dimi"; //We must getting close to Steiner.
    level.scr_sound["Petrenko"]["afterthismission"] = "vox_ful1_s03_338A_dimi"; //After this mission... do you think we will go home?
    level.scr_sound["Reznov"]["ihopeso"] = "vox_ful1_s03_339A_rezn"; //I hope so, Dimitri... I hope so.
    level.scr_sound["Petrenko"]["therearefewleft"] = "vox_ful1_s03_340A_dimi"; //There are few of them left... Still no sign of Steiner.
    level.scr_sound["Reznov"]["hewillbewhere"] = "vox_ful1_s03_341A_rezn"; //He will be where all cowards reside... As far from the battlefield as possible.
    
    level.scr_sound["Reznov"]["thiswayupthestairs"] = "vox_ful1_s03_342A_rezn"; //This way, up the stairs.
    level.scr_sound["Reznov"]["ready"] = "vox_ful1_s03_343A_rezn"; //Ready?
    level.scr_sound["Reznov"]["friedrichsteiner"] = "vox_ful1_s03_344A_rezn"; //Friedrich Steiner...
    
    level.scr_sound["German Soldier"]["pleasedontkillme"] = "vox_ful1_s99_721A_ger1"; //(Translated) Please, don't kill me!
    level.scr_sound["German Soldier"]["igiveup"] = "vox_ful1_s99_722A_ger1"; //(Translated) I give up!
    
    
    
    // shiparrival area stuff
    level.scr_sound["Petrenko"]["oldfriends"] = "vox_ful1_s03_345A_dimi"; //Dragovich and Steiner are talking like old friends... I do not like this, Reznov.
    level.scr_sound["Reznov"]["oldfriends"] = "vox_ful1_s03_345B_rezn"; //Nor I, Dimitri... Be on your guard.
    
    // When you get to the former traversal room, probably
    
	level.scr_sound["Reznov"]["shh"] = "vox_ful1_s04_346A_rezn"; //Shhh... Be on your guard.
  	level.scr_sound["Reznov"]["placereeks"] = "vox_ful1_s04_347A_rezn"; //This place reeks of despair.
   	level.scr_sound["Petrenko"]["whathappened"] = "vox_ful1_s04_348A_dimi"; //What do you think happened here, Reznov?
   	level.scr_sound["Reznov"]["betternotknow"] = "vox_ful1_s04_349A_rezn"; //Perhaps it is better we do not know...    

   	level.scr_sound["Reznov"]["anime"] = "vox_ful1_s04_350A_rezn"; //Keep moving.
    level.scr_sound["Reznov"]["anime"] = "vox_ful1_s04_351A_rezn"; //Watch where you step.
    
    level.scr_sound["Petrenko"]["anime"] = "vox_ful1_s04_352A_dimi"; //The shadows seem to move...
    level.scr_sound["Reznov"]["anime"] = "vox_ful1_s04_353A_rezn"; //It is only natural to fear what you cannot see... Your mind will play tricks.
    
    // misc reminders
    level.scr_sound["Petrenko"]["anime"] = "vox_ful1_s04_354A_dimi"; //Reznov - over here!
    level.scr_sound["Petrenko"]["anime"] = "vox_ful1_s04_355A_dimi"; //This way, Reznov.
    level.scr_sound["Petrenko"]["anime"] = "vox_ful1_s04_356A_dimi"; //Where are you going, Reznov?
    level.scr_sound["Petrenko"]["anime"] = "vox_ful1_s04_357A_dimi"; //Stay close, Viktor.
    
    
    
    // shipfirefight stuff
    
    level.scr_sound["Nevski"]["armnag1"] = "vox_ful1_s06_358A_nevs"; //We can’t hold forever!  Arm the explosives, Reznov.
    level.scr_sound["Nevski"]["armnag2"] = "vox_ful1_s06_359A_nevs"; //Hurry! - Get the explosives armed.
    level.scr_sound["Nevski"]["armnag3"] = "vox_ful1_s06_360A_nevs"; //Reznov! The explosives need to be armed!
    
    // just in case the player missed it
    level.scr_sound["Reznov"]["anime"] = "vox_ful1_s06_361A_rezn"; //I have armed the explosives!
    
    level.scr_sound["Nevski"]["gantrynag1"] = "vox_ful1_s06_373A_nevs"; //Reznov! Shoot the beams!
    level.scr_sound["Nevski"]["gantrynag2"] = "vox_ful1_s06_374A_nevs"; //Hurry! Bring down those gantries!
    level.scr_sound["Nevski"]["gantrynag3"] = "vox_ful1_s06_375A_nevs"; //Shoot the beams, Reznov! It’s our only way out!
    
    // window cajoling
    level.scr_sound["Nevski"]["windownag1"] = "vox_ful1_s06_376A_nevs"; //We've got to get down to the deck!
    level.scr_sound["Nevski"]["windownag2"] = "vox_ful1_s06_377A_nevs"; //Reznov, we can climb out that window!
    level.scr_sound["Nevski"]["windownag3"] = "vox_ful1_s06_378A_nevs"; //Hurry, out the window!
    
    // lots of time reminders
    level.scr_sound["Reznov"]["anime"] = "vox_ful1_s06_362A_rezn"; //We do not have time to waste!
    
    level.scr_sound["Nevski"]["4min"] = "vox_ful1_s06_363A_nevs"; //Four minutes, Reznov!
    level.scr_sound["Reznov"]["3min30"] = "vox_ful1_s06_364A_rezn"; //We have less than four minutes!
    level.scr_sound["Nevski"]["1min30"] = "vox_ful1_s06_365A_nevs"; //Keep moving, time is running out! // repurposed to make up for the missing 1:30 line
    level.scr_sound["Reznov"]["3min"] = "vox_ful1_s06_366A_rezn"; //In three minutes this ship will be engulfed in flames.
    level.scr_sound["Nevski"]["2min30"] = "vox_ful1_s06_367A_nevs"; //We have to get off the ship!
    level.scr_sound["Reznov"]["2min"] = "vox_ful1_s06_368A_rezn"; //Hurry - We only have two minutes left!
    level.scr_sound["Reznov"]["1min"] = "vox_ful1_s06_369A_rezn"; //In one minute - Fire will consume this vessel - MOVE!!
    level.scr_sound["Reznov"]["30"] = "vox_ful1_s06_370A_rezn"; //Thirty seconds!
    level.scr_sound["Reznov"]["10"] = "vox_ful1_s06_372A_rezn"; //We’re not going to make it!
    
    // ???
    level.scr_sound["Reznov"]["anime"] = "vox_ful1_s06_371A_rezn"; //Ten seconds, Reznov!
    
    
    
}

#using_animtree ("vehicles");
init_snowcat_animation()
{
	level.scr_anim["snowcat"]["idle"][0] = %v_full_b01_snowcat_idle;
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#using_animtree( "player" );
player_fullahead()
{
	level.scr_animtree[ "playerbody" ] = #animtree;
	level.scr_model[ "playerbody" ] = level.player_interactive_model;
	level.scr_anim[ "playerbody" ][ "heroberlin" ] = %ch_full_b01_hero_of_berlin_player;
	level.scr_anim[ "playerbody" ][ "snowcat_idle" ][0] = %ch_full_b01_patrenko_snowcat_idle_player;
	level.scr_anim[ "playerbody" ][ "snowcat_talk" ] = %ch_full_b01_patrenko_snowcat_player;
	level.scr_anim[ "playerbody" ][ "find_steiner" ] = %ch_full_b02_find_steiner_player;
	level.scr_anim[ "playerbody" ][ "itstime" ] = %int_full_b01_its_time;

	
	
	// betrayal cinematic
	level.scr_anim[ "playerbody" ][ "bet_s1" ] = %ch_full_b06_betrayal_shot1_player;
	level.scr_anim[ "playerbody" ][ "bet_s2" ] = %ch_full_b06_betrayal_shot2_player;
	level.scr_anim[ "playerbody" ][ "bet_tank" ] = %ch_full_b06_betrayal_tankshot_player;
	level.scr_anim[ "playerbody" ][ "bet_s3" ] = %ch_full_b06_betrayal_shot3_player;
	level.scr_anim[ "playerbody" ][ "bet_s4" ] = %ch_full_b06_betrayal_shot4_player;
	level.scr_anim[ "playerbody" ][ "bet_s5" ] = %ch_full_b06_betrayal_shot5_player;
	level.scr_anim[ "playerbody" ][ "bet_s6" ] = %ch_full_b06_betrayal_shot6_player;
	level.scr_anim[ "playerbody" ][ "bet_s7" ] = %ch_full_b06_nova6_death_player;
	level.scr_anim[ "playerbody" ][ "bet_s8" ] = %ch_full_b06_betrayal_shot7_player;
	level.scr_anim[ "playerbody" ][ "narr_1" ] = % o_full_interstitial_01_camera;
	level.scr_anim[ "playerbody" ][ "narr_2" ] = % o_full_interstitial_02_camera;
	level.scr_anim[ "playerbody" ][ "narr_3" ] = % o_full_interstitial_03_camera;
	level.scr_anim[ "playerbody" ][ "narr_4" ] = % o_full_interstitial_04_camera;

	//fov
	maps\_anim::addNotetrack_fov( "playerbody", "fov_40", "bet_s1" );
	maps\_anim::addNotetrack_fov( "playerbody", "fov_40", "bet_s2" );
	maps\_anim::addNotetrack_fov( "playerbody", "fov_40", "bet_s3" );
	maps\_anim::addNotetrack_fov( "playerbody", "fov_40", "bet_s5" );
	maps\_anim::addNotetrack_fov( "playerbody", "fov_40", "bet_s8" );
	maps\_anim::addNotetrack_fov( "playerbody", "fov_45", "bet_tank" );
	maps\_anim::addNotetrack_fov( "playerbody", "fov_51", "bet_s4" );
	maps\_anim::addNotetrack_fov( "playerbody", "fov_25", "bet_s6" );
	maps\_anim::addNotetrack_fov( "playerbody", "fov_reset", "bet_s6" );
	maps\_anim::addNotetrack_fov( "playerbody", "fov_reset", "bet_s8" );

	// zipline
	level.scr_anim[ "playerbody" ][ "use_zipline" ] 			= %ch_full_b07_zip_line_player;
	level.scr_anim[ "playerbody" ][ "hits_ground" ] 			= %ch_full_b07_nevski_hits_hard_player;	
	
	// found steiner
	
	
	level.scr_animtree[ "playerhands" ] = #animtree;
	level.scr_model[ "playerhands" ] = level.player_interactive_hands;
	level.scr_anim[ "playerhands" ][ "steinercin" ] = %int_full_b03_found_steiner;
	// arming explosives, opening door
	level.scr_anim[ "playerhands" ][ "door_open" ] 		= %int_full_b04_player_door_open_player;
	addNotetrack_customFunction("playerhands", "enable_player", ::notetrack_enable_player, "door_open");
	level.scr_anim[ "playerhands" ][ "explosives" ] 		= %int_full_b07_reznov_arm_explosives;
}

#using_animtree( "fullahead" );
objects_fullahead()
{
	level.scr_anim[ "object" ][ "door_open" ] 		= %o_full_b04_player_door_open_door;
	level.scr_anim[ "object" ][ "explosives" ] 		= %o_full_b07_reznov_arm_explosives;
	level.scr_anim[ "object" ][ "petrenko_door_open" ] = %o_full_b05_petrenko_open_door;
	level.scr_anim[ "object" ][ "door_close" ] 		= %o_full_b06_nova6_death_door;

}


snow_fade_notify(guy)
{
	level notify("start_fade_out");
}

// ~~~~~
// ~~~~~ Cinematic stuff ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~
puff_the_magic_dragon(guy)
{
	PlayFXOnTag(level._effect["cig_drag"], level.cigarette, "tag_cigarglow");
}
exhale_smoke(guy)
{
	PlayFXOnTag(level._effect["cig_exhale"], guy, "j_head");
}
flick_the_Cig(guy)
{
	PlayFXOnTag(level._effect["cig_flick"], level.cigarette, "tag_cigarglow");
}

vomit_floor( guy )
{
	if( is_mature() )
	{	
		PlayFXOnTag(level._effect["vomit_floor"], level.cin_petrenko, "j_head");
	}
}

vomit_glass( guy )
{
	if( is_mature() )
	{	
		exploder( 398 );
	}
}

snowcat_attach_crate( guy )
{
	tag_origin = guy getTagOrigin( "tag_inhand" );
	tag_angles = guy getTagAngles( "tag_inhand" );
		
	if( !isdefined(guy.crate) )
	{		
		crate = spawn( "script_model", tag_origin );
		crate setModel( "anim_jun_ammo_box" );
		crate.angles = tag_angles;
	
		crate linkto( guy, "tag_inhand" );
		guy.crate = crate;
	}
	level thread snowcat_static_crate( tag_origin, tag_angles );
}

//create a crate in truck
snowcat_static_crate( tag_origin, tag_angles )
{
	if( level.crate_spawned == false ) 
	{
		static_crate = spawn( "script_model", tag_origin );
		static_crate setModel( "anim_jun_ammo_box" );
		static_crate.angles = tag_angles;
		level.crate_spawned = true;
	}
}

snowcat_detach_crate( guy )
{
	if( isdefined(guy.crate) )
	{
		guy.crate unlink();
		crate = guy.crate;

	
		//wait(0.5);
		crate delete();
	}
}

notetrack_attach_crate( guy )
{
	tag_origin = guy getTagOrigin( "tag_inhand" );
	tag_angles = guy getTagAngles( "tag_inhand" );
	
	crate = spawn( "script_model", tag_origin );
	crate setModel( "p_glo_crate_wood_01" );
	crate.angles = tag_angles;
	
	crate linkto( guy, "tag_inhand" );
	guy.crate = crate;
}

notetrack_detach_crate( guy )
{
	if( isdefined(guy.crate) )
	{
		guy.crate unlink();
		crate = guy.crate;

	
		wait(0.5);
		crate delete();
	}
}

notetrack_blood_fx( guy )
{
	fxTag = "j_neck";
	PlayFxOnTag( level._effect["bloodspurt"], guy, fxTag );
}

shiparrival_execution()
{
	point = getstruct( "shiparrival_execution_point", "targetname" );
	krav_destnode = getnode( "shiparrival_krav_dest", "targetname" );
	other_destnode = getnode( "shiparrival_otherguy_dest", "targetname" );
	assert( isdefined(point) );
	assert( isdefined(krav_destnode) );
	assert( isdefined(other_destnode) );

	array = [];

	array[0] = level.kravchenko;
	array[0].animname = "krav";

	otherguy = simple_spawn_single( "p2shiparrival_otherguy_spawner" );
	array[1] = otherguy;
	array[1].animname = "russ";

	array[2] = fa_drone_spawn( point, "axis_nogear" );
//	array[2] HidePart("tag_weapon");
	array[2] notify( "stop_death_thread" );
	array[2].animname = "ger1";

	array[3] = fa_drone_spawn( point, "axis_nogear" );
//	array[3] HidePart("tag_weapon");
	array[3] notify( "stop_death_thread" );
	array[3].animname = "ger2";

	array[4] = fa_drone_spawn( point, "axis_nogear" );
//	array[4] HidePart("tag_weapon");
	array[4] notify( "stop_death_thread" );
	array[4].animname = "ger3";

	array[5] = fa_drone_spawn( point, "axis_nogear" );
//	array[5] HidePart("tag_weapon");
	array[5] notify( "stop_death_thread" );
	array[5].animname = "ger4";

	array[6] = fa_drone_spawn( point, "axis_nogear" );
//	array[6] HidePart("tag_weapon");
	array[6] notify( "stop_death_thread" );
	array[6].animname = "ger5";

	array[7] = fa_drone_spawn( point, "axis_nogear" );
//	array[7] HidePart("tag_weapon");
	array[7] notify( "stop_death_thread" );
	array[7].animname = "ger6";	
		
//	level.kravchenko.forceSideArm = true;
//	level.kravchenko gun_switchto( "tokarevtt30_sp", "right" );
	weaponmodel = GetWeaponModel( "tokarevtt30_sp" );
	level.kravchenko Attach( weaponmodel, "tag_weapon_left" );


	wait(0.1);

	point thread anim_loop_aligned( array, "executionidle" );

//	trigger_wait( "shiparrival_execution_trigger" );
	flag_wait( "P2SHIPARRIVAL_OUTSIDE_CONVERSATION_DONE" );
	flag_set( "P2SHIPARRIVAL_EXECUTION_STARTED" );
	
	// fx to hide pop
//	player = get_players()[0];
//	
//	spot = Spawn("script_model", player.origin + (32,0,0) );
//	spot SetModel("tag_origin");
//	spot LinkTo( player );
//	PlayFXOnTag( level._effect["fx_smk_fire_xlg_black"], spot, "tag_origin" );
//	wait(0.2);

	point anim_single_aligned( array, "execution" );
	
//	point waittill( "execution" ); // -- this was pre-quaternion hack-around

//	level.kravchenko waittillmatch( "single anim", "end" ); // the following 3 lines are quick hack to get around quaternion singularity conditions
//	level.kravchenko StopAnimScripted();
//	level.kravchenko ClearAnim(%root, 0.0);	
	
	flag_set( "P2SHIPARRIVAL_EXECUTION_FINISHED" );
	level.kravchenko setgoalnode( krav_destnode );
	level.kravchenko.goalradius = 192;
	level.kravchenko.animname = "generic";
	level.kravchenko.forceSideArm = false;


	otherguy setgoalnode( other_destnode );
	otherguy.animname = "generic";
	otherguy.goalradius = 64;
	otherguy set_run_anim( "ship_point_walk" );
	
//	otherguy waittill( "goal" );
//	otherguy allowedstances( "crouch" ); - no more crouchy


	// a thread in shiparrival picks him up here, and he follows the player through the ship

}


kick_door_hangar( guy )
{
	door = getent( "p2nazibase_hangar_door", "targetname" );
	colortrig = getent( "patrenko_hangar_kick_color", "targetname" );

	fa_start_drone_path( "surrender_drone_1", "axis" );

	door rotateto( (0,90,0), 0.25 );
	door connectpaths();

	colortrig useby( get_player() );
}

detach_boiler( guy )
{
	object = getent( "stairwell_object", "targetname" );
	object unlink();
	flag_set( "P2SHIPARRIVAL_BOILER_AT_REST" );
		
	// this needs to be solid again
	boiler_clip = getent( "boiler_clip", "targetname" );
	boiler_clip solid();
	boiler_clip disconnectpaths();
}

execution_attach_knife( guy )
{
	weaponmodel = GetWeaponModel( "tokarevtt30_sp" );
	level.kravchenko Detach( weaponmodel, "tag_weapon_left" );
	
	knifemodel = GetWeaponModel( "knife_sp" );
	level.kravchenko Attach( knifemodel, "tag_inhand" );
	
	//flag_wait( "P2SHIPARRIVAL_EXECUTION_FINISHED" );
	flag_wait( "P2SHIPARRIVAL_REZNOV_MOVING_OUT" ); //flag was setting too soon so use this -jc
	wait 2.5;	//no notetrack so have to time it -jc
	
	level.kravchenko Detach( knifemodel, "tag_inhand" );	
}

execution_gunshot( guy )
{
	//muzzleflash
	PlayFXOnTag( level._effect["muzzle_flash"], level.kravchenko, "tag_weapon_left" );

}

execution_drop_knife( guy )
{
	knifemodel = GetWeaponModel( "knife_sp" );
	level.kravchenko Detach( knifemodel, "tag_inhand" );	
}

// There are six versions of this function in anticipation of getting individual fx for each guy, especially the guy whose throat is cut.
execution_blood_fx1( guy )
{
	if( is_mature() )
	{
		PlayFXOnTag( level._effect["bloodspurt"], guy, "tag_eye" );
	}
}

execution_blood_fx2( guy )
{
	if( is_mature() )
	{
		PlayFXOnTag( level._effect["bloodspurt"], guy, "tag_eye" );
	}
}

execution_blood_fx3( guy )
{
	if( is_mature() )
	{
		PlayFXOnTag( level._effect["bloodspurt"], guy, "tag_eye" );
	}
}

execution_blood_fx4( guy )
{
	if( is_mature() )
	{
		PlayFXOnTag( level._effect["bloodspurt"], guy, "tag_eye" );
	}
}

execution_blood_fx5( guy )
{
	if( is_mature() )
	{
		PlayFXOnTag( level._effect["bloodspurt"], guy, "tag_eye" );
	}
}

execution_blood_fx6( guy )
{
	if( is_mature() )
	{
		PlayFXOnTag( level._effect["bloodspurt"], guy, "tag_eye" );
	}
}

execution_throat( guy )
{
	if( is_mature() )
	{
		PlayFXOnTag( level._effect["throat_slice"], guy, "j_neck" );
	}
}


#using_animtree ("player");
play_player_anim( anim_node, animation, animname, looping, disable_look_around, unlink_on_finish, hands_callback, lerp_time, lerp_tag )
{
	level endon( "force_enable_player" );
	
	fa_print( "play_player_anim: animation=" + animation + "  animname=" + animname );
	
	player = get_players()[0];
	player DisableWeapons();

	if( !isdefined(level.current_hands_ent) ) // spawn a new hands model, if necessary
	{
		level.current_hands_ent = spawn_anim_model( animname );
	}
	else
	{
		level notify( "starting_new_hands_anim" );
	}
	//RecordEnt( level.current_hands_ent );
		
	level.current_hands_ent.animname = animname;

	level.current_hands_ent.origin = anim_node.origin;
	level.current_hands_ent.angles = anim_node.angles;

	level.current_hands_ent Hide();
	
	anim_node anim_first_frame( level.current_hands_ent, animation, undefined, animname );
	
	if( isdefined(hands_callback) )
	{
		level.current_hands_ent [[ hands_callback ]]();
	}
	//moves player to camera tag
	if( !isdefined(lerp_time) )
	{
		lerp_time = 0.05;
	}
	
	if( IsDefined( lerp_tag ) && lerp_time > 0 )
	{
		player lerp_player_view_to_position( level.current_hands_ent GetTagOrigin( lerp_tag ), level.current_hands_ent GetTagAngles( lerp_tag ), lerp_time );
	}
	else if( lerp_time > 0 )
	{	
		player lerp_player_view_to_position( level.current_hands_ent GetTagOrigin( "tag_player" ), level.current_hands_ent GetTagAngles( "tag_player" ), lerp_time );
	}
	
	if( isdefined(disable_look_around) && disable_look_around == true )
	{
		player PlayerLinkToAbsolute( level.current_hands_ent, "tag_player" );
	}
	else
	{
		if( isdefined(level.overwrite_anim_playerview) )
		{
			player PlayerLinkToDelta( level.current_hands_ent, "tag_player", 1, level.overwrite_anim_playerview_right, level.overwrite_anim_playerview_left, level.overwrite_anim_playerview_up, level.overwrite_anim_playerview_down );
		}
		else
		{
			player PlayerLinkTo( level.current_hands_ent, "tag_player", 0.95, 35, 35, 20, 20 );
		}
	}

	level endon( "starting_new_hands_anim" ); // allows this thread to stomp over any existing hands anim threads

	level.current_hands_ent Show();

	if( isdefined(looping) && looping == true )
	{
		anim_node anim_loop_aligned( level.current_hands_ent, animation, undefined, animation+"_end", animname );
	}
	else
	{
		anim_node anim_single_aligned( level.current_hands_ent, animation, undefined, animname );
	}

	if( !isDefined( unlink_on_finish ) )
	{
		player Unlink();
		level.current_hands_ent Delete();
	}
	
	// reset playerview so that we have to set it everytime we need to
	if( isDefined(level.overwrite_anim_playerview) )
	{
		level.overwrite_anim_playerview = undefined;	
	}
	
	player notify( animation );
	player EnableWeapons();
}

// special case where we play one animation right after another and we keep the player body where it is for a smooth transition
play_player_snowcat_anims()	// self = player vehicle
{
	level endon( "force_enable_player" );
	level endon( "starting_new_hands_anim" ); // allows this thread to stomp over any existing hands anim threads
	
	player = get_players()[0];
	player DisableClientLinkTo();
	player DisableWeapons();
	player StartCameraTween( 1 );
	assertex(!isdefined(level.current_hands_ent), "Player body already exists when it shouldn't.");
	
	level.current_hands_ent = spawn_anim_model( "playerbody", (0, 0, 0));
	level.current_hands_ent hide();
	level.current_hands_ent.animname = "playerbody";
	level.current_hands_ent.origin = self.origin;
	level.current_hands_ent.angles = self.angles;
	level.current_hands_ent linkto( self, "tag_guy4" );
	//self anim_first_frame( level.current_hands_ent, "heroberlin", undefined, "playerbody" );	
	//player PlayerLinkToAbsolute( level.current_hands_ent, "tag_player");
	player PlayerLinkToDelta( level.current_hands_ent, "tag_player", 1, 35, 35, 35, 35 );
	level.current_hands_ent thread show_hand();
	self anim_single_aligned( level.current_hands_ent, "heroberlin", undefined, "playerbody" );
	self snowcat_player_idle();
	self anim_single_aligned( level.current_hands_ent, "snowcat_talk", undefined);
	
	//level.snowcat_player_vehicle thread play_player_anim( player, "snowcat_talk", "playerbody", false, false );  // player talks on snowcat	
}

snowcat_player_idle()
{

	level.player_talking = true;
	while(level.player_talking)
	{
		self anim_single_aligned( level.current_hands_ent, "snowcat_idle", "tag_origin");
	}
}


show_hand()
{
	wait(0.5);
	self show();
}

play_player_intro_anim()	// self = player vehicle
{
	level endon( "force_enable_player" );
	level endon( "starting_new_hands_anim" ); // allows this thread to stomp over any existing hands anim threads

	player = get_players()[0];
	player DisableClientLinkTo();
	//player DisableWeapons();
	assertex(!isdefined(level.current_hands_ent), "Player body already exists when it shouldn't.");

	level.current_hands_ent = spawn_anim_model( "playerbody" );	
	level.current_hands_ent.animname = "playerbody";
	level.current_hands_ent.origin = self.origin;
	level.current_hands_ent.angles = self.angles;

	self anim_first_frame( level.current_hands_ent, "itstime", undefined, "playerbody" );	
	player PlayerLinkToAbsolute( level.current_hands_ent, "tag_player");
	self thread anim_single_aligned( level.current_hands_ent, "itstime", undefined, "playerbody" );
	self waittill( "itstime_anim" );
	level.current_hands_ent delete();
	player unlink();
	player EnableWeapons();

}


notetrack_enable_player( GARBAGE )
{
	level notify( "force_enable_player" );
	
	player = get_player();
	
	player Unlink();
	level.current_hands_ent Delete();

	player EnableWeapons();
}

hide_and_show( delay )
{
	self hide();
	wait(delay);
	self show();
}

// #using_animtree("player");
// player_anim( sequence ) // self should be the object we're animating relative to (a script_struct or the like)
// {
// 	if( IsDefined(level.player_tag) )
// 	{
// 		level.player_tag delete();
// 	}
//
// 	p = get_player();
//
// 	level.player_tag = spawn_anim_model( "player" );
// 	level.player_tag.origin = self.origin;
// 	level.player_tag.angles = self.angles;
// 	level.player_tag UseAnimTree(#animtree);
// 	level.player_tag.animname = "player";
// 	level.player_tag thread hide_and_show(0.35);
//
// 	p playerlinktodelta( level.player_tag, "tag_origin", 1, 15, 0, 15, 0 );
// 	//p playerlinktoAbsolute( level.player_hands, "tag_player" );
// 	self anim_single_aligned( level.player_tag, sequence );
// 	p unlink();
// 	level.player_tag delete();
// }


firefight_friendly_weapon_pickup1( guy )
{
	fakegun = getent( "firefight_weapon_pickup1_weapon", "targetname" );
	fakegun delete();
	
	guy gun_switchto( "ppsh_sp", "right" );
	
	guy maps\_prisoners::unmake_prisoner();
	guy setgoalnode_tn( "dummy1_node" );
}

firefight_friendly_weapon_pickup2( guy )
{
	fakegun = getent( "firefight_weapon_pickup2_weapon", "targetname" );
	fakegun delete();
	
	guy gun_switchto( "stg44_sp", "right" );
	
	guy maps\_prisoners::unmake_prisoner();
	guy setgoalnode_tn( "dummy2_node" );
}

dragovich_leaves_grenade( guy )
{
	explosionpoint = getstruct( "shipfirefight_escape_explosion", "targetname" );
	door = getent( "ship_doorescape", "targetname" );
	secondhit = getstruct( "shiparrival_hinge_secondhit_doorescape", "targetname" );
	weaponblock = getent( "shipfirefight_escape_weaponblock", "targetname" );
	
	assert( isdefined(weaponblock) );
	assert( isdefined(explosionpoint) );
	assert( isdefined(door) );
	assert( isdefined(secondhit) );

	// door explosion	
	fakerpg( "shipfirefight_fakefire", "shipfirefight_escape_explosion" );  // cooler than just an explosion!!!
	wait(1); // give the rocket a bit to arrive
	earthquake( 0.7, 1.25, door.origin, 1024 );
	playsoundatposition ("exp_mortar_dirt", explosionpoint.origin);
	p = get_players()[0];
	p PlayRumbleOnEntity( "damage_heavy");
	door moveto( secondhit.origin, 0.4, 0.0, 0.2 );
	door rotateto( secondhit.angles, 0.4, 0.0, 0.2 );
	weaponblock delete();

	autosave_by_name( "fullahead" );
	
	flag_set( "P2SHIPFIREFIGHT_DOOR_IS_OPEN" );
	
//     level.scr_sound["Reznov"]["ourwayout"] = "vox_ful1_s06_115A_rezn"; //Go! - Fight our way out!
	p anim_single( p, "ourwayout", "Reznov" );
	
	//TUEY Set music state to ESCAPE
	setmusicstate ("ESCAPE");
	
}

dragovich_leaves_earthquake( guy )
{
	player = get_player();
	earthquake( 0.4, 0.75, player.origin, 768 );
	playsoundatposition ("exp_mortar_dirt", (12976, -16303, 495.6));
	player PlayRumbleOnEntity( "damage_heavy");
}

dragovich_leaves_redshirt_vo( guy )
{
//    level.scr_sound["Soldier"]["ourpositions"] = "vox_ful1_s06_112A_rrd8_f"; //British commandos are assaulting our positions!
	//level.guy1 anim_single( level.guy1, "ourpositions", "Soldier" );
}

// Player arms explosives with appropriate anims
#using_animtree( "fullahead" );
player_arm_explosives( explosives )
{
	// don't forget to check the targetname below, too!
	struct = getstruct( "explosives_anim_struct1", "targetname" );
	explosives useAnimTree( #animtree ); // I have no idea what this means, but it's necessary
	explosives.animname = "object";
	level thread player_arm_explosives_monitor();
	struct thread anim_single_aligned( explosives, "explosives" );
	struct play_player_anim( struct, "explosives", "playerhands", false, true );
}

player_arm_explosives_monitor()
{
	level endon( "P2SHIPFIREFIGHT_ARMED" );

	p = get_players()[0];
	p waittill( "death");
	level.current_hands_ent StopAnimScripted();
	level.current_hands_ent Hide();

	
}


#using_animtree( "fullahead" );
explosives_in_place()
{
	// don't forget to check the targetname above, too!
	struct = getstruct( "explosives_anim_struct1", "targetname" );
	explosives = spawn( "script_model", struct.origin );
	
	explosives.targetname = "cargobay_explosives_objective";
	explosives setmodel("anim_ger_dynamite_timer");
	explosives.angles = (0, 0, 0); // zero out the angles
	
	explosives useAnimTree( #animtree ); // I have no idea what this means, but it's necessary
	explosives.animname = "object";
	
	struct thread anim_first_frame( explosives, "explosives" );	

}

// Player opens door with appropriate anims
#using_animtree( "fullahead" );
player_open_door( doornum )
{
	p = get_player();

	door = getent( "ship_door" + doornum, "targetname" ); // naming convention of all the ship doors
	door setmodel( "anim_rus_shipdoor_pi" );
	door useAnimTree( #animtree ); // I have no idea what this means, but it's necessary
	door.animname = "object";
	
	door thread anim_single_aligned( door, "door_open" );
	door play_player_anim( door, "door_open", "playerhands", false, true, undefined, undefined, 0.0 );
	
	level notify( "player_door_opened" );
}

ai_open_door( doornum )
{
	door = getent( "ship_door" + doornum, "targetname" ); // naming convention of all the ship doors
	door setmodel( "anim_rus_shipdoor_pi" );
	door useAnimTree( #animtree ); // I have no idea what this means, but it's necessary
	door.animname = "object";
	
	door thread anim_single_aligned( door, "door_open" );
}