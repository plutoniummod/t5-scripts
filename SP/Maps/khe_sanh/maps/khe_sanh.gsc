//////////////////////////////////////////////////////////
//
// khe_sanh.gsc
//
//////////////////////////////////////////////////////////

#include maps\_utility;
#include common_scripts\utility;
#include maps\khe_sanh_util;
#include maps\_rusher;
#include maps\_vehicle;

main()
{

	// Keep this first for CreateFX
	maps\khe_sanh_fx::main();

	// set the global specular scale for this level to off 1-1
 	SetSavedDvar( "r_testScale","1" );
	   
	precache_items();

	//-- Starts
	add_start( "e1_intro", ::jumpto_e1_intro, &"JUMPTO_E1_INTRO");
	add_start( "e2_trenchbattle", ::jumpto_e2_trenchbattle, &"JUMPTO_E2_TRENCHBATTLE" );
	add_start( "e3_trenchdefense", ::jumpto_e3_trenchdefense, &"JUMPTO_E3_TRENCHDEFENSE" );
	add_start( "e3b_law_battle", ::jumpto_e3b_law_battle, &"JUMPTO_E3B_LAW_BATTLE" );
	add_start( "e4_hillbattle", ::jumpto_e4_hillbattle, &"JUMPTO_E4_HILLBATTLE" );
	add_start( "e4b_uphillbattle", ::jumpto_e4b_uphillbattle, &"JUMPTO_E4_UPHILLBATTLE" );
	add_start( "e4c_woods_jam", ::jumpto_e4c_woods_jam, &"JUMPTO_E4C_WOODS_JAM" );
	add_start( "e5_siegeofkhesahn", ::jumpto_e5_siegeofkhesahn, &"JUMPTO_E5_SIEGEOFKHESAHN" );
	add_start( "e5b_towbattle", ::jumpto_e5b_towbattle, &"JUMPTO_E5B_TOWBATTLE" );
	//add_start( "e6_siegeofkhesahn", ::jumpto_e6_siegeofkhesahn, &"JUMPTO_E6_SIEGEOFKHESAHN" );

	default_start( ::jumpto_e1_intro );

	//detail drone
	// These are called everytime a drone is spawned in to set up the character.
	level.drone_spawnFunction["allies"] = character\c_usa_jungmar_assault::main; 
	//level.drone_spawnFunction["axis"] = character\c_vtn_nva1::main;
	
	//cheaper drone
	//level.drone_spawnFunction["axis"] = character\c_vtn_nva1_drone::main;
	level.drone_spawnFunction_passNode = true; //-- makes _drone pass the first struct of the drone path into the spawn function
	level.drone_spawnFunction["axis"] = maps\khe_sanh_util::axis_drone_spawn;
	character\c_vtn_nva1_drone::precache();

	//level.drone_spawnFunction["allies"] = character\c_usa_jungmar_drone::main;
	//character\c_usa_jungmar_drone::precache();

	setup_drones();

	//init tow
	maps\_tvguidedmissile::init();

	// Main Init
	maps\_load::main();

	// Drones Init
	maps\_drones::init();	

	init_flags();

	// AI rushers
	maps\_rusher::init_rusher();

	// Khe Sahn other inits
	maps\createart\khe_sanh_art::main();
	level thread maps\khe_sanh_amb::main();
	maps\khe_sanh_anim::main();
	
	/#
	setdvar( "debug_character_count", "on" );
	#/

//	level thread debug_ai();
}

/***************************************************************/
// Init Flags
/***************************************************************/
init_flags()
{
	//Objective flags start
	//event 1
	flag_init("obj_get_hudson_to_safety");
	flag_init("obj_get_hudson_to_safety_complete");
	
	//event 2
	flag_init("obj_trenches_with_woods");
	flag_init("obj_trenches_with_woods_complete");
	flag_init("all_tanks_spawned");
	
	//event 3
	flag_init("picked_up_law");
	flag_init("obj_cover_woods");
	flag_init("obj_cover_woods_complete");
	flag_init("obj_hold_the_line");
	flag_init("obj_hold_the_line_complete");

	flag_init("obj_defeat_the_tanks");
	flag_init("obj_defeat_the_tanks_complete");
	flag_init("obj_rally_bunker");
	flag_init("obj_rally_bunker_complete");

	//event 4
	flag_init("start_downhill_breadcrumb");
	flag_init("obj_breakthrough");
	flag_init("obj_breakthrough_complete");
	flag_init("obj_rally_at_hill");
	flag_init("obj_rally_at_hill_complete");
	flag_init("obj_retake_the_hill");
	flag_init("obj_retake_the_hill_rally");
	flag_init("obj_retake_the_hill_complete");
	flag_init("hilltop_window_start");

	//Objective flags end

	//event 5
	flag_init("obj_repel_infantry");
	flag_init("obj_repel_infantry_complete");
	flag_init("player_on_jeep");
	flag_init("obj_get_in_jeep");
	flag_init("obj_tow_jeep_phase_2");
	flag_init("phase_2_spawn");
	flag_init("obj_tow_jeep_phase_3");
	flag_init("phase_3_spawn");
	flag_init("obj_tow_jeep_phase_end");
	flag_init("end_scene");

	//sky metal
	flag_init("e1_pause_sky_metal");

	level.e3b_jumpto = false;
	level.e4c_woods_jam = false;
	level.e5_jumpto = false;
	level.e5b_jumpto = false;

	//scriptmover client flag
	//= 0 is used by sound for heli crash in event 3
	level.SCRIPTMOVER_CHARRING = 1;
	level.ACTOR_CHARRING = 2;	

	//level.PITCH_DOWN = 3;
	//level.PITCH_UP = 4;


	//dont let fts drop until event 4b
	level.rw_ft_allowed = false;

	//drones will not ragdoll
	level.no_drone_ragdoll = true;

	//tank values
	level.DEFAULT_TANK_HEALTH = 256;
}

/***************************************************************/
// Precache Items 
/***************************************************************/
precache_items()
{
	PreCacheRumble("damage_heavy");

	//e3 overlay
	//PreCacheShader("e3_slate");

	// Shell Shocks
	PreCacheShellShock( "default" );	
	PreCacheShellShock( "quagmire_window_break" );
	PreCacheShellShock( "tankblast" );
	PreCacheShellShock ("khe_sanh_woods");
	PreCacheShellShock ("explosion");

	// Weapons
	//commented out m16 items are precahced in _loadout.gsc
	//PreCacheItem( "m16_sp" );
	PreCacheItem( "m16_acog_sp" );
	PreCacheItem( "m16_extclip_sp" );
	PreCacheItem( "m16_dualclip_sp" );
	PreCacheItem( "m16_gl_sp" );
	PrecacheItem( "gl_m16_sp" );
	//PreCacheItem( "m16_mk_sp" );
	//PreCacheItem( "mk_m16_sp" );
	PreCacheItem( "m16_acog_mk_sp" );

	PreCacheItem( "m14_sp" );
	PreCacheItem( "m14_acog_sp" );
	PreCacheItem( "m14_extclip_sp" );
	PreCacheItem( "m14_gl_sp" );
	PreCacheItem( "gl_m14_sp" );

	PreCacheItem( "ak47_sp" );
	PreCacheItem( "ak47_acog_sp" );
	PreCacheItem( "ak47_extclip_sp" );
	PreCacheItem( "ak47_dualclip_sp" );
	PreCacheItem( "ak47_gl_sp" );
	PreCacheItem( "gl_ak47_sp" );
	PreCacheItem( "ak47_ft_sp" );
	PreCacheItem( "ft_ak47_sp" );
	PreCacheItem( "ak47_lowpoly_sp" );

	PreCacheItem( "rpk_sp" );
	PreCacheItem( "rpk_acog_sp" );
	PreCacheItem( "rpk_extclip_sp" );
	PreCacheItem( "m60_sp" );
	//PreCacheItem( "m60_acog_sp" );
	PreCacheItem( "m60_extclip_sp" );
	PreCacheItem( "m60_grip_sp" );
	PreCacheItem( "m60_bipod_stand" );
	
	//PreCacheItem( "ithaca_sp" );
	PrecacheItem( "ithaca_grip_sp" );
	PrecacheItem( "python_sp" );

	PreCacheItem( "frag_grenade_sp" );

	PreCacheItem( "china_lake_sp" );
	PreCacheItem( "rpg_player_sp" );
	PrecacheItem( "m220_tow_emplaced_khesanh_sp" );
	PrecacheItem( "m72_law_magic_bullet_sp" );
	
	PreCacheItem( "creek_satchel_charge_sp" );

	PreCacheItem("knife_sp");

	//hueys stuff
	PreCacheModel("t5_veh_helo_huey_usmc");
	PreCacheModel("t5_veh_helo_huey_att_interior");
	PrecacheModel("t5_veh_helo_huey_att_decal_usmc_gunship");
	PrecacheModel("t5_veh_helo_huey_att_decal_usmc_hvyhog");
	PreCacheModel("t5_veh_helo_huey_att_decal_usmc_std");
	PreCacheModel("t5_veh_helo_huey_att_decal_medivac");
	PrecacheModel("t5_veh_helo_huey_att_usmc_m60");
	PreCacheModel("t5_veh_helo_huey_att_rockets_usmc");
	
	//c130
	PreCacheModel("t5_veh_air_c130");
	PreCacheModel("t5_veh_air_c130_damaged_parts");
	
	//ladder
	PrecacheModel("p_rus_ladder_metal_256");

	PrecacheModel("t5_veh_jeep");
	//PrecacheModel("p_glo_barrel_objective");
	PrecacheModel("t5_knife_sog");
	PrecacheModel("t5_weapon_law_world_obj");

	PrecacheModel("anim_jun_bodybag");
	PrecacheModel("fxanim_khesanh_deadbody_tarp_mod");

	//phantom camo
	PreCacheModel("t5_veh_jet_f4_gearup_lowres_marines");

	//apc attachements
	//PrecacheModel("t5_veh_m113");
	PrecacheModel("t5_veh_m113_warchicken_turret_decals");
	PrecacheModel("t5_veh_m113_warchicken_decals");
	PrecacheModel("t5_veh_m113_sandbags");
	PrecacheModel("t5_veh_m113_outcasts_decals");

	// anim props
	PrecacheModel("anim_jun_stretcher");
	PrecacheModel("p_glo_shovel01");
	PrecacheModel("p_jun_khe_sahn_hatch");

	//chinalke world model
	PrecacheModel("t5_weapon_ex41_world");
	PrecacheModel("t5_weapon_M16A1_world");

	//woods detonator
	PrecacheModel("weapon_c4_detonator");

	//planks
	PrecacheModel("p_jun_wood_plank_large01");
	PrecacheModel("p_jun_wood_plank_small01");
	
	//crate
	PrecacheModel("p_glo_crate01");

	//woods bandana
	//PrecacheModel("c_usa_jungmar_barnes_bandana");
	//PrecacheModel("c_usa_jungmar_barnes_ks_nobdana");

	//m60
	PrecacheModel("t5_weapon_m60e3_MG");	

	//fake gib
	PrecacheModel("c_vtn_nva1_body_g_torso");
	PrecacheModel("c_vtn_nva3_head");
	PrecacheModel("c_vtn_nva3_gear");
	PrecacheModel("c_vtn_nva2_body_g_legsoff"); // //c_vtn_nva2_body_g_lowclean

	character\c_usa_jungmar_driver::precache();
	character\c_usa_jungmar_barechest::precache();
	character\c_usa_jungmar_chaplain::precache();
	character\c_usa_jungmar_wounded_torso::precache();
	character\c_usa_jungmar_wounded_knee::precache();
	character\c_usa_jungmar_headblown::precache();
	character\c_vtn_nva1_char::precache();
	character\c_usa_jungmar_bowman_nobackpack::precache();
}

/***************************************************************/
// jumpto_e1_intro
/***************************************************************/
jumpto_e1_intro()
{
	wait_for_first_player();

	level.player = Get_Players()[0];
	start_teleport_players( "player_e1_jumpto" );

	//create hero allies
	create_hero_squad();

	//start objective thread
	level thread khe_sanh_objectives();

	create_level_threat_groups();

	// call the main for e1
	maps\khe_sanh_event1::main();
}

/***************************************************************/
// jumpto_e2_trenchbattle
/***************************************************************/
jumpto_e2_trenchbattle()
{
	wait_for_first_player();

//	jumpto_objective = 3;
	
	//set previous objectives
	flag_set("obj_get_hudson_to_safety");
	flag_set("obj_get_hudson_to_safety_complete");

	level.player = Get_Players()[0];

	// vision settings and sun direction
	maps\createart\khe_sanh_art::event2_bunker_vision_settings();
	level.player  SetClientDvar( "r_lightTweakSunDirection", (-28, 205.317, 0));  

	//create hero allies
	create_hero_squad();

	// teleport squad
	start_teleport_players( "player_e2_jumpto" );
	start_teleport("player_e2_jumpto", "hero_squad");

	//start objective thread
	level thread khe_sanh_objectives();

	//delete these on jumpto 
	chinooks = GetEntArray("e2_jumpto_delete_chinooks", "script_noteworthy");
	
	if(chinooks.size > 0)
	{
		array_delete(chinooks);
	}

	create_level_threat_groups();

	//set sun sample to level default. higher at start for helicopters intro
	maps\createart\khe_sanh_art::set_level_sun_default();

	//turn on ambient effects First bunker to first M113
	exploder(20);

	//turn on ambient effects First M113 to e3_e4 bunker
	exploder(30);

	// call the main for e2
	maps\khe_sanh_event2::main();
}

/***************************************************************/
// jumpto_e3_trenchdefense
/***************************************************************/
jumpto_e3_trenchdefense()
{
	wait_for_first_player();

	//jumpto_objective = 4;

	//set prvious objectives
	flag_set("obj_get_hudson_to_safety");
	flag_set("obj_get_hudson_to_safety_complete");
	flag_set("obj_trenches_with_woods");
	flag_set("obj_trenches_with_woods_complete");

	level.player = Get_Players()[0];

	// vision settings and sun direction
	maps\createart\khe_sanh_art::event3c_vision_settings();
	level.player SetClientDvar( "r_lightTweakSunDirection", (-28, 205.317, 0));  

	//create hero allies
	create_hero_squad();

	// teleport squad
	start_teleport_players( "player_e3_jumpto" );
	start_teleport("player_e3_jumpto", "hero_squad");

	//start objective thread
	level thread khe_sanh_objectives();

	level.event3_jumpto = true;

	//delete these on jumpto 
	chinooks = GetEntArray("e2_jumpto_delete_chinooks", "script_noteworthy");

	if(chinooks.size > 0)
	{
		array_delete(chinooks);
	}

	//triggers drones on defend section
	//level.drone_trigger_defend = GetEnt("e3_trig_drone_axis_1", "script_noteworthy");
	//level.drone_trigger_defend activate_trigger();

	//drones at APC
	level.drone_trigger_apc = GetEnt("e2_trig_drone_axis_0b", "script_noteworthy");
	level.drone_trigger_apc activate_trigger();

	//triggers drones on defend section in back background
	//level.drone_trigger_defend_b = GetEnt("e3_trig_drone_axis_2", "script_noteworthy");
	//level.drone_trigger_defend_b activate_trigger();

	maps\khe_sanh_event2::event1_cleanup();

	battlechatter_on("allies");
	battlechatter_on("axis");

	level.e3b_jumpto = false;

	create_level_threat_groups();

	//set sun sample to level default. higher at start for helicopters intro
	maps\createart\khe_sanh_art::set_level_sun_default();

	//turn on ambient effects First M113 to e3_e4 bunker
	exploder(30);

	// call the main for e3
	maps\khe_sanh_event3::main();
}

jumpto_e3b_law_battle()
{
	wait_for_first_player();

	//jumpto_objective = 4;

	//set prvious objectives
	flag_set("obj_get_hudson_to_safety");
	flag_set("obj_get_hudson_to_safety_complete");
	flag_set("obj_trenches_with_woods");
	flag_set("obj_trenches_with_woods_complete");

	level.player = Get_Players()[0];

	// vision settings and sun direction
	maps\createart\khe_sanh_art::event3c_vision_settings();
	level.player SetClientDvar( "r_lightTweakSunDirection", (-28, 205.317, 0));  

	//create hero allies
	create_hero_squad();

	// teleport squad
	start_teleport_players( "player_e3_jumpto" );
	start_teleport("player_e3_jumpto", "hero_squad");

	//start objective thread
	level thread khe_sanh_objectives();

	level.event3_jumpto = true;

	//delete these on jumpto 
	chinooks = GetEntArray("e2_jumpto_delete_chinooks", "script_noteworthy");

	if(chinooks.size > 0)
	{
		array_delete(chinooks);
	}

	//triggers drones on defend section
	//level.drone_trigger_defend = GetEnt("e3_trig_drone_axis_1", "script_noteworthy");
	//level.drone_trigger_defend activate_trigger();

	//drones at APC
	level.drone_trigger_apc = GetEnt("e2_trig_drone_axis_0b", "script_noteworthy");
	level.drone_trigger_apc activate_trigger();

	//triggers drones on defend section in back background
	//level.drone_trigger_defend_b = GetEnt("e3_trig_drone_axis_2", "script_noteworthy");
	//level.drone_trigger_defend_b activate_trigger();

	maps\khe_sanh_event2::event1_cleanup();

	battlechatter_on("allies");
	battlechatter_on("axis");

	level.e3b_jumpto = true;

	create_level_threat_groups();

	//set sun sample to level default. higher at start for helicopters intro
	maps\createart\khe_sanh_art::set_level_sun_default();


	//turn on ambient effects First M113 to e3_e4 bunker
	exploder(30);

	// call the main for e3
	maps\khe_sanh_event3::main();
}

/***************************************************************/
// jumpto_e4_hillbattle
/***************************************************************/
jumpto_e4_hillbattle()
{
	wait_for_first_player();
	
//	jumpto_objective = 10;
	
	//set prvious objectives
	flag_set("obj_get_hudson_to_safety");
	flag_set("obj_get_hudson_to_safety_complete");
	flag_set("obj_trenches_with_woods");
	flag_set("obj_trenches_with_woods_complete");
	flag_set("obj_cover_woods");
	flag_set("obj_cover_woods_complete");
	flag_set("obj_hold_the_line");
	flag_set("obj_hold_the_line_complete");

	flag_set("obj_defeat_the_tanks");
	flag_set("all_tanks_spawned");
	flag_set("obj_defeat_the_tanks_complete");
	flag_set("obj_rally_bunker");
	flag_set("obj_rally_bunker_complete");

	level.player = Get_Players()[0];

	// vision settings and sun direction
	maps\createart\khe_sanh_art::event4_vision_settings();
	level.player SetClientDvar( "r_lightTweakSunDirection", (-28, 205.317, 0)); 

	// create heros
	create_hero_squad();

	// teleport squad
	start_teleport_players( "player_e4_jumpto" );	 
	start_teleport("player_e4_jumpto", "hero_squad");

	//start objective thread
	level thread khe_sanh_objectives();

	//delete these on jumpto 
	chinooks = GetEntArray("e2_jumpto_delete_chinooks", "script_noteworthy");

	if(chinooks.size > 0)
	{
		array_delete(chinooks);
	}

	//cleans up all spawners and triggers
	maps\khe_sanh_event2::event1_cleanup();

	//cleans up all spawners and triggers
	maps\khe_sanh_event3::event2_cleanup();

	//cleans up all spawners and triggers
	maps\khe_sanh_event3::event3_cleanup();

	battlechatter_on("allies");
	battlechatter_on("axis");

	level.e4c_woods_jam = false;

	create_level_threat_groups();

	//set sun sample to level default. higher at start for helicopters intro
	maps\createart\khe_sanh_art::set_level_sun_default();

	//turn on ambient effects Downhill areas
	exploder(40);

	// call the main for e4
	maps\khe_sanh_event4::main();
}

/***************************************************************/
// jumpto_e4b_uphillbattle
/***************************************************************/
jumpto_e4b_uphillbattle()
{
	wait_for_first_player();

//	jumpto_objective = 12;

	//set prvious objectives
	flag_set("obj_get_hudson_to_safety");
	flag_set("obj_get_hudson_to_safety_complete");
	flag_set("obj_trenches_with_woods");
	flag_set("obj_trenches_with_woods_complete");
	flag_set("obj_cover_woods");
	flag_set("obj_cover_woods_complete");
	flag_set("obj_hold_the_line");
	flag_set("obj_hold_the_line_complete");

	flag_set("obj_defeat_the_tanks");
	flag_set("all_tanks_spawned");
	flag_set("obj_defeat_the_tanks_complete");
	flag_set("obj_rally_bunker");
	flag_set("obj_rally_bunker_complete");
	flag_set("obj_breakthrough");
	flag_set("start_downhill_breadcrumb");
	flag_set("trig_e4_breadcrumb");
	flag_set("obj_breakthrough_complete");
	flag_set("obj_rally_at_hill");

	level.player = Get_Players()[0];

	// vision settings and sun direction
	maps\createart\khe_sanh_art::event4b_vision_settings();
	level.player SetClientDvar( "r_lightTweakSunDirection", (-28, 205.317, 0)); 

	// create heros
	create_hero_squad();

	// teleport squad
	start_teleport_players( "player_e4b_jumpto" );
	start_teleport("player_e4b_jumpto", "hero_squad");

	//start objective thread
	level thread khe_sanh_objectives();

	//delete these on jumpto 
	chinooks = GetEntArray("e2_jumpto_delete_chinooks", "script_noteworthy");

	if(chinooks.size > 0)
	{
		array_delete(chinooks);
	}

	//activate drone trigs
	level.drone_e4_hill_trans = GetEnt("e4_trig_drone_hill_trans", "script_noteworthy");
	level.drone_e4_hill_trans activate_trigger();

	//cleans up all spawners and triggers
	maps\khe_sanh_event2::event1_cleanup();

	//cleans up all spawners and triggers
	maps\khe_sanh_event3::event2_cleanup();

	//cleans up all spawners and triggers
	maps\khe_sanh_event3::event3_cleanup();

	battlechatter_on("allies");
	battlechatter_on("axis");	

	level.e4c_woods_jam = false;

	create_level_threat_groups();

	//set sun sample to level default. higher at start for helicopters intro
	maps\createart\khe_sanh_art::set_level_sun_default();

	//turn on ambient effects Uphill areas to entrance of destroyed bunker
	exploder(41);

	//turn on ambient effects Tunnel entrance to destroyed bunker to tunnel exit
	exploder(42);

	// call the main for e4
	maps\khe_sanh_event4b::main();
}

jumpto_e4c_woods_jam()
{
	wait_for_first_player();

	//	jumpto_objective = 12;

	//set prvious objectives
	flag_set("obj_get_hudson_to_safety");
	flag_set("obj_get_hudson_to_safety_complete");
	flag_set("obj_trenches_with_woods");
	flag_set("obj_trenches_with_woods_complete");
	flag_set("obj_cover_woods");
	flag_set("obj_cover_woods_complete");
	flag_set("obj_hold_the_line");
	flag_set("obj_hold_the_line_complete");

	flag_set("obj_defeat_the_tanks");
	flag_set("all_tanks_spawned");
	flag_set("obj_defeat_the_tanks_complete");
	flag_set("obj_rally_bunker");
	flag_set("obj_rally_bunker_complete");
	flag_set("obj_breakthrough");
	flag_set("start_downhill_breadcrumb");
	flag_set("trig_e4_breadcrumb");
	flag_set("obj_breakthrough_complete");

	flag_set("obj_rally_at_hill");
	flag_set("obj_rally_at_hill_complete");
	flag_set("obj_retake_the_hill");
	flag_set("obj_retake_the_hill_rally");

	level.player = Get_Players()[0];

	// vision settings and sun direction
	maps\createart\khe_sanh_art::event4b_vision_settings();
	level.player SetClientDvar( "r_lightTweakSunDirection", (-28, 205.317, 0)); 

	// create heros
	create_hero_squad();

	// teleport squad
	start_teleport_players( "player_e4c_jumpto" );
	start_teleport("player_e4b_jumpto", "hero_squad");

	//start objective thread
	level thread khe_sanh_objectives();

	//delete these on jumpto 
	chinooks = GetEntArray("e2_jumpto_delete_chinooks", "script_noteworthy");

	if(chinooks.size > 0)
	{
		array_delete(chinooks);
	}

	//activate drone trigs
	level.drone_e4_hill_trans = GetEnt("e4_trig_drone_hill_trans", "script_noteworthy");
	level.drone_e4_hill_trans activate_trigger();

	//cleans up all spawners and triggers
	maps\khe_sanh_event2::event1_cleanup();

	//cleans up all spawners and triggers
	maps\khe_sanh_event3::event2_cleanup();

	//cleans up all spawners and triggers
	maps\khe_sanh_event3::event3_cleanup();

	battlechatter_on("allies");
	battlechatter_on("axis");	

	level.e4c_woods_jam = true;

	create_level_threat_groups();

	//set sun sample to level default. higher at start for helicopters intro
	maps\createart\khe_sanh_art::set_level_sun_default();

	//turn on ambient effects Uphill areas to entrance of destroyed bunker
	exploder(41);

	//turn on ambient effects Tunnel entrance to destroyed bunker to tunnel exit
	exploder(42);

	// call the main for e4
	maps\khe_sanh_event4b::main();

}

/***************************************************************/
// jumpto_e5_airfieldbattle
/***************************************************************/
jumpto_e5_siegeofkhesahn()
{
	wait_for_first_player();

	//set prvious objectives
	flag_set("obj_get_hudson_to_safety");
	flag_set("obj_get_hudson_to_safety_complete");
	flag_set("obj_trenches_with_woods");
	flag_set("obj_trenches_with_woods_complete");
	flag_set("obj_cover_woods");
	flag_set("obj_cover_woods_complete");
	flag_set("obj_hold_the_line");
	flag_set("obj_hold_the_line_complete");
	flag_set("obj_defeat_the_tanks");
	flag_set("all_tanks_spawned");
	flag_set("obj_defeat_the_tanks_complete");
	flag_set("obj_rally_bunker");
	flag_set("obj_rally_bunker_complete");
	flag_set("obj_breakthrough");
	flag_set("start_downhill_breadcrumb");
	flag_set("trig_e4_breadcrumb");
	flag_set("obj_breakthrough_complete");
	flag_set("obj_rally_at_hill");
	flag_set("obj_rally_at_hill_complete");
	flag_set("obj_retake_the_hill");
	flag_set("obj_retake_the_hill_rally");
	flag_set("hilltop_window_start");
	flag_set("obj_retake_the_hill_complete");

	level.player = Get_Players()[0];

	// vision settings and sun direction
	maps\createart\khe_sanh_art::event5_vision_settings();
	level.player SetClientDvar( "r_lightTweakSunDirection", (-28, 205.317, 0)); 

	// create heros
	create_hero_squad();

	// teleport squad
	start_teleport_players( "player_e5_jumpto" );
	start_teleport("player_e5_jumpto", "hero_squad");

	level.e5_jumpto = true;

	//start objective thread
	level thread khe_sanh_objectives();

	//delete these on jumpto 
	chinooks = GetEntArray("e2_jumpto_delete_chinooks", "script_noteworthy");

	if(chinooks.size > 0)
	{
		array_delete(chinooks);
	}

	//cleans up all spawners and triggers
	maps\khe_sanh_event2::event1_cleanup();

	//cleans up all spawners and triggers
	maps\khe_sanh_event3::event2_cleanup();

	//cleans up all spawners and triggers
	maps\khe_sanh_event3::event3_cleanup();

	maps\khe_sanh_event5::event4_cleanup();

	battlechatter_on("allies");
	battlechatter_on("axis");	

	create_level_threat_groups();

	//set sun sample to level default. higher at start for helicopters intro
	maps\createart\khe_sanh_art::set_level_sun_default();

	//turn on ambient effects Tunnel entrance to destroyed bunker to tunnel exit
	exploder(42);

	// call the main for e5
	maps\khe_sanh_event5::main();
}

jumpto_e5b_towbattle()
{
	wait_for_first_player();

	//set prvious objectives
	flag_set("obj_get_hudson_to_safety");
	flag_set("obj_get_hudson_to_safety_complete");
	flag_set("obj_trenches_with_woods");
	flag_set("obj_trenches_with_woods_complete");
	flag_set("obj_cover_woods");
	flag_set("obj_cover_woods_complete");
	flag_set("obj_hold_the_line");
	flag_set("obj_hold_the_line_complete");

	flag_set("obj_defeat_the_tanks");
	flag_set("all_tanks_spawned");
	flag_set("obj_defeat_the_tanks_complete");
	flag_set("obj_rally_bunker");
	flag_set("obj_rally_bunker_complete");

	flag_set("obj_breakthrough");
	flag_set("start_downhill_breadcrumb");
	flag_set("trig_e4_breadcrumb");
	flag_set("obj_breakthrough_complete");

	flag_set("obj_rally_at_hill");
	flag_set("obj_rally_at_hill_complete");
	flag_set("obj_retake_the_hill");
	flag_set("obj_retake_the_hill_rally");
	flag_set("hilltop_window_start");
	flag_set("obj_retake_the_hill_complete");

	level.player = Get_Players()[0];

	// vision settings and sun direction
	maps\createart\khe_sanh_art::event5_vision_settings();
	level.player SetClientDvar( "r_lightTweakSunDirection", (-28, 205.317, 0)); 

	// create heros
	create_hero_squad();

	// teleport squad
	start_teleport_players( "player_e5_jumpto" );
	start_teleport("player_e5_jumpto", "hero_squad");

	level.e5b_jumpto = true;

	//start objective thread
	level thread khe_sanh_objectives();

	//delete these on jumpto 
	chinooks = GetEntArray("e2_jumpto_delete_chinooks", "script_noteworthy");

	if(chinooks.size > 0)
	{
		array_delete(chinooks);
	}

	//cleans up all spawners and triggers
	maps\khe_sanh_event2::event1_cleanup();

	//cleans up all spawners and triggers
	maps\khe_sanh_event3::event2_cleanup();

	//cleans up all spawners and triggers
	maps\khe_sanh_event3::event3_cleanup();

	maps\khe_sanh_event5::event4_cleanup();

	battlechatter_on("allies");
	battlechatter_on("axis");	

	create_level_threat_groups();

	//set sun sample to level default. higher at start for helicopters intro
	maps\createart\khe_sanh_art::set_level_sun_default();

	//turn on ambient effects Tunnel entrance to destroyed bunker to tunnel exit
	exploder(42);

	// call the main for e5
	maps\khe_sanh_event5::main();
}

/***************************************************************/
// jumpto_e6_siegeofkhesahn
/***************************************************************/

create_hero_squad()
{
	if(!IsDefined(level.squad))
	{
		level.squad = [];
		// Woods setup
		level.squad["woods"] = simple_spawn_single("woods");
		level.squad["woods"].name = "Woods";
		level.squad["woods"].animname = "woods";
//		level.squad["woods"].ignoreall = true;
		level.squad["woods"].ignoresuppression = true;
		level.squad["woods"] make_hero();
		level.squad["woods"] disable_pain();

		// Hudson setup
		level.squad["hudson"] = simple_spawn_single("hudson");
		level.squad["hudson"].name = "Hudson";
		level.squad["hudson"].animname = "hudson";
//		level.squad["hudson"].ignoreall = true;
		level.squad["hudson"].ignoresuppression = true;
		level.squad["hudson"] make_hero();
		level.squad["hudson"] disable_pain();
	}
}

setup_drones()
{
	level.max_drones = [];
	level.max_drones["axis"] = 100; 
	level.max_drones["allies"] = 100;
}

create_level_threat_groups()
{
	CreateThreatBiasGroup("player");

	//event 2
	CreateThreatBiasGroup( "shoot_player" );
	CreateThreatBiasGroup( "shoot_redshirt" );
	CreateThreatBiasGroup("ally_squad");

	//event 4
	CreateThreatBiasGroup( "e4_anti_player" );
	CreateThreatBiasGroup( "e4_anti_allies" );
	CreateThreatBiasGroup("e4_player_allies");

	//event 4b
	CreateThreatBiasGroup( "anti_player" );
	CreateThreatBiasGroup( "anti_allies" );
	CreateThreatBiasGroup("player_allies");

	//event 5
	CreateThreatBiasGroup( "e5_anti_player" );
	CreateThreatBiasGroup( "e5_anti_allies" );
	CreateThreatBiasGroup( "e5_player_allies" );

}