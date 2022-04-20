/*
//-- Level: Full Ahead
//-- Level Designer: Christian Easterly
//-- Scripter: Jeremy Statz
*/


#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\_anim; // Be sure to include this for _anim calls.
#include maps\fullahead_util;


// ~~~ The start of everything ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
main()
{
	init_precache();
	init_flags();
	init_starts();
	
	level.swimmingFeature = false;
	level.noAutoStartLevelSave = true;
	
	maps\fullahead_fx::main();
	maps\_load::main();
	maps\_drones::init();
	
	maps\fullahead_amb::main();
	maps\fullahead_anim::main();
	
	maps\_door_breach::door_breach_init();
	maps\_names::add_override_name_func("american", ::override_russian_names);
	
	level._override_shader = "black";
	
	
}

map_start_setup()
{
	level thread init_global();
	
	// make sure every player is in
	wait_for_first_player();
	get_player() setclientdvar( "cg_objectiveIndicatorFarFadeDist", "999999999" );
	flag_wait( "all_players_connected" );
	
	get_player() dds_set_player_character_name("reznov");
	
	level thread create_fake_reznov();

	// disable revive -- this was in the old level script, not sure it's needed
	level disable_ai_revive();
	
	get_player().name = "Reznov";
	
	level thread maps\fullahead_p2_dogsled::run_skipto();
}

// ~~~ Precache any special items/weapons/etc ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#using_animtree( "generic_human" );
init_precache()
{
	fa_print( "init_precache running" );
	
	level.flashlightWeapon = "fullahead_flashlight_pistol_sp";
	precacheitem( level.flashlightWeapon );
	precacheitem( "tokarevtt30_sp" );
	precacheitem( "m8_orange_smoke_sp" );
	precacheitem( "rpg_sp" );
	
	precachemodel( "p_rus_v2_pi" );
	precacheModel( "t5_veh_snowcat_troops" );
	precacheModel( "p_glo_crate_wood_01" );
	precacheModel( "anim_jun_ammo_box" );
	
	precacheModel( "tag_origin" );
	
	// steiner cinematic
	precachemodel( "p_glo_cigarette" );
	precachemodel( "p_ger_steiner_chair" );
	
	// falling ice block
	precachemodel( "anim_ger_ship_ice_block01" );
	
	// cargo bay objectives
	precachemodel( "p_ger_v2_gantry_pole_obj" );
	precachemodel( "anim_ger_dynamite_timer" );
	precachemodel( "anim_ger_dynamite_timer_obj" );
	
	// ship doors
	precachemodel( "p_rus_shipdoor_pi" );
	precachemodel( "anim_rus_shipdoor_pi" );

	// snowcat engine rumble
	precacherumble( "damage_light" );

	maps\_mortarteam::main();

	character\c_ger_infantry::precache();
	character\c_ger_infantry_nogear::precache();	
	character\c_rus_fullahead_drones::precache();
	character\c_brt_fullahead_drone::precache();
	maps\_rusher::init_rusher();
	
	maps\_prisoners::init_prisoners();
	
	character\c_rus_reznov_fullahead::precache();
	level.reznov_spawnFunction = character\c_rus_reznov_fullahead::main;
	
	character\c_rus_reznov_prisoner::precache();
	level.reznovTalky_spawnFunction = character\c_rus_reznov_prisoner::main;
	
	character\c_rus_dragovich_young::precache();
	level.dragovich_spawnFunction = character\c_rus_dragovich_young::main;
	
	character\c_ger_steiner_fullahead::precache();
	level.steiner_spawnFunction = character\c_ger_steiner_fullahead::main;
	
	//changed so patrenko can be gassed, assuming only used for betrayal -jc
	character\c_rus_fullahead_patrenko_gas::precache();
	level.patrenko_spawnFunction = character\c_rus_fullahead_patrenko_gas::main;
			
	character\c_rus_fullahead_soldier1_gas  ::precache();
	level.gasguy_spawnFunction = character\c_rus_fullahead_soldier1_gas::main;
			
	character\c_rus_kravchenko_young::precache();
	level.kravchenko_spawnFunction = character\c_rus_kravchenko_young::main;
	
	character\c_rus_fullahead_soldier::precache();
	level.allieshigh_spawnFunction = character\c_rus_fullahead_soldier::main;
	
	character\c_rus_fullahead_officer1::precache();
	level.alliesofficer_spawnFunction = character\c_rus_fullahead_officer1::main;
	
	character\c_ger_officer_frozen::precache();
	level.officerFrozen_spawnFunction = character\c_ger_officer_frozen::main;
	
	character\c_ger_infantry_frozen::precache();
	level.infantryFrozen_spawnFunction = character\c_ger_infantry_frozen::main;
	
	// added entry to use proper hanging German model PI - DMM
	character\c_ger_infantry_hung::precache();
	level.infantryHung_spawnFunction = character\c_ger_infantry_hung::main;
	
	character\c_brt_fullahead_soldier::precache();
	level.britishHigh_spawnFunction = character\c_brt_fullahead_soldier::main;

	level.droneidleanims = [];
	level.droneidleanims[0] = %casual_stand_idle;
//  	level.droneidleanims[1] = %casual_crouch_idle;
	
	level.drone_weaponlist_axis = [];
	level.drone_weaponlist_axis[0] = "mp40_sp";
	level.drone_weaponlist_allies = [];
	level.drone_weaponlist_allies[0] = "mosin_sp";
	level.drone_spawnFunction["axis"] = character\c_ger_infantry::main;
	level.drone_spawnFunction["axis_nogear"] = character\c_ger_infantry_nogear::main;	
	level.drone_spawnFunction["allies"] = character\c_rus_fullahead_drones::main;
	
	maps\_patrol::patrol_init();
}

// ~~~ Creates the valid start point shortcuts ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
init_starts()
{
	default_start( ::map_start_setup, true );	
	add_start( "dogsled", maps\fullahead_p2_dogsled::run_skipto, &"FULLAHEAD_SKIPTO_E1_SNOWCAT" ); 
	add_start( "nazibase", maps\fullahead_p2_nazibase::run_skipto, &"FULLAHEAD_SKIPTO_NAZIBASE" );
	add_start( "nazibase_hangar", maps\fullahead_p2_nazibase::run_skipto_hangar, &"FULLAHEAD_SKIPTO_NAZIBASE_HANGAR" );
	add_start( "nazibase_end", maps\fullahead_p2_nazibase::run_skipto_end, &"FULLAHEAD_SKIPTO_NAZIBASE_END" );
	add_start( "shiparrival", maps\fullahead_p2_shiparrival::run_skipto, &"FULLAHEAD_SKIPTO_SHIPARRIVAL" );
	add_start( "shipcargo", maps\fullahead_p2_shipcargo::run_skipto, &"FULLAHEAD_SKIPTO_SHIPCARGO" ); 
	add_start( "shipcinema", maps\fullahead_p2_shipcinema::run_skipto, &"FULLAHEAD_SKIPTO_SHIPCINEMA" );
	add_start( "shipfirefight", maps\fullahead_p2_shipfirefight::run_skipto, &"FULLAHEAD_SKIPTO_SHIPFIREFIGHT" );
	add_start( "shipfirefight_bridge", maps\fullahead_p2_shipfirefight::run_skipto_bridge, &"FULLAHEAD_SKIPTO_SHIPFIREFIGHT_BRIDGE" );
	add_start( "shipmast", maps\fullahead_p2_shipmast::run_skipto, &"FULLAHEAD_SKIPTO_SHIPMAST" );
	add_start( "wrapup", maps\fullahead_p2_wrapup::run_skipto, &"FULLAHEAD_SKIPTO_WRAPUP" );
}

// ~~~ Sets up level flags ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
init_flags()
{
	flag_init( "reznov_cutscene_startfade" );
	flag_init( "reznov_cutscene_snow_to_fade" );
	flag_init( "reznov_cutscene_done" );
	level.ACTOR_CHARRING = 2;
	maps\fullahead_p2_dogsled::init_flags();
}

init_global()
{
	disable_trigger_with_targetname( "ship_kill_trigger" );
	disable_trigger_with_targetname( "cargobay_explosives_trigger" );
//	disable_trigger_with_targetname( "p2shipcargo_door_use" ); PI - DMM this trigger is deprecated and was deleted
	disable_trigger_with_targetname( "p2shipfirefight_cargo_spawn_stopper" );
	//disable_triggers_with_targetname( "p2shipfirefight_misc_triggers" );
	disable_trigger_with_targetname( "v2_gantry_collapse_kill_trigger" );  // PI - DMM - addition of kill trigger for players standing under falling V2 and catwalk
	disable_triggers_with_targetname( "p2shipfirefight_team_post_catwalk" );
	
	disable_trigger_with_targetname( "cargobay_entrance_blocker" );
	blocker = getent( "cargobay_entrance_blocker", "targetname" );
	blocker connectpaths();
	
	disable_triggers_with_targetname( "cargo_blocker_geo" );
	disable_trigger_with_targetname( "cargo_blocker_clip" );
	blocker = getent( "cargo_blocker_clip", "targetname" );
	blocker connectpaths();

	v2blocker = getent( "shipcargo_rocketclip", "targetname" ); // PI - DMM addition for fallen V2 and gantry clip blocker
	v2blocker connectpaths();
	v2blocker NotSolid();

	// hide building destroyed geometry
	building01_roof_destroyed = GetEnt("building01_roofdestroyed", "targetname");
	building01_roof_destroyed Hide();

	maps\fullahead_p2_shipfirefight::catwalk_setup_thread();
}

override_russian_names()
{
	if(!IsDefined(level._names))
	{
		level._names = [];
		level._names_index = 0;

		level._names[level._names.size] = "Avtamonov";
		level._names[level._names.size] = "Yakubov";
		level._names[level._names.size] = "Zubarev";
		level._names[level._names.size] = "Sidorenko";
		level._names[level._names.size] = "Repin";
		level._names[level._names.size] = "Melnikov";
		level._names[level._names.size] = "Krasilnikov";
		level._names[level._names.size] = "Maximov";
		level._names[level._names.size] = "Datsyuk";
		level._names[level._names.size] = "Bulenkov";
		level._names[level._names.size] = "Gerasimov";
	}

	name = level._names[level._names_index];
	level._names_index = (level._names_index + 1) % level._names.size;

	return name;
}
create_fake_reznov()
{
	level.streamHintEnt = createStreamerHint((-1160, -1152, -152), 1.0 );
	rez_struct = getstruct( "whiteroom_reznov_struct", "targetname" );
	reznov = maps\fullahead_drones::fa_drone_spawn( rez_struct, "reznovtalky" );
	level.reznov_drone = reznov;
	
}