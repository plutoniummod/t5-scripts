/*
//-- Level: Full Ahead
//-- Level Designer: Christian Easterly
//-- Scripter: Jeremy Statz
*/

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\fullahead_util;
#include maps\_anim;
#include maps\_ai_rappel;
#include maps\fullahead_drones;
#include maps\fullahead_anim;

// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	// would've been dealt with during the cinematic
	ship_door_setup( "gas" );
	ship_door_setup( "escape" );
	ship_door_setup( "stein" );
	
	// would've happened way back in shipcargo
	ship_door_setup( "cargo" );
	
	add_global_spawn_function( "axis", ::spawnfunc_ikpriority ); // happens in shiparrival
	add_global_spawn_function( "allies", ::spawnfunc_ikpriority );
	
	level ship_door_setup( "black" );
	level thread ship_door_open( "black" );
	
	maps\fullahead_p2_nazibase::cleanup();
	
	default_fog();
	
	// would've happened in shipcargo
	explosives_in_place();
	
	// would've happened in shiparrival
	setup_visionset_triggers();
	
	p = getplayers()[0]; // weapons would be gone already if progression was natural
	p fa_take_weapons();
	
	p fa_show_hud( false ); // these happen in shipcinema
	p freezecontrols( true );
	
	//fa_visionset_bright();
	fa_visionset_shipstart();
	
	// would've gone away when we used it earlier
	trig = getent( "p2shipcargo_outro", "targetname" );
	trig delete();
	
	objective_add( 0, "done", &"FULLAHEAD_OBJ_NAZIBASE_STEINER" );
	objective_add( 1, "done", &"FULLAHEAD_OBJ_SECURE_WEAPON" );
	level thread objectives(2);
	
	exploder(  397 ); // would've been turned on during shipcinema
	
	// SOUND - Shawn J
	//iprintlnbold ("explo?");
		
	fade_out( 0.25, "black" );
	//missing rocket
	//level thread catwalk_setup_thread()
	
	run();
}

// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto_bridge()
{	
	// would've been opened during the cinematic
	ship_door_setup( "black" );
	level thread ship_door_open( "black" );
	
	maps\fullahead_p2_nazibase::cleanup();
	
	// would've happened in shiparrival
	setup_visionset_triggers();
	
	p = getplayers()[0]; // weapons would be gone already if progression was natural	
	fa_visionset_bright();
	
	// would've gone away when we used it earlier
	trig = getent( "p2shipcargo_outro", "targetname" );
	trig delete();
	
	objective_add( 0, "done", &"FULLAHEAD_OBJ_NAZIBASE_STEINER" );
	objective_add( 1, "done", &"FULLAHEAD_OBJ_SECURE_WEAPON" );
	level thread objectives(2);
	
	flag_set( "P2SHIPFIREFIGHT_EXPLOSIVES_DIALOGUE_COMPLETE" );
	flag_set( "P2SHIPFIREFIGHT_ARMED" );
	flag_set( "P2SHIPFIREFIGHT_ROCKET_DIALOGUE_COMPLETE" );
	flag_set( "P2SHIPFIREFIGHT_ROCKETFELL" );
	flag_set( "P2SHIPFIREFIGHT_CARGO_DONE" );
	flag_set( "P2SHIPFIREFIGHT_AT_TEAR" );
	
	wait(0.05);
	
	trig = getent( "p2shipfirefight_turned_tear_corner", "targetname" );
	trig notify( "trigger" );
	wait(0.05);
	
//	trig = getent( "p2shipfirefight_flicker_room_entrance", "targetname" );
//	trig notify( "trigger" );
//	wait(0.05);
	
	trig = getent( "p2shipfirefight_post_flicker_room", "targetname" );
	trig notify( "trigger" );
	wait(0.05);
	
	CreateThreatBiasGroup( "friendlies" );
	CreateThreatBiasGroup( "enemies" );
	
	player_to_struct( "bridgeskip_playerstart" );
	
	shipfirefight_spawn_friends();

	// switches the player and his team's team setting based on the current situation
	get_player() thread shipfirefight_teamhandler();
	
	friendlies = get_firefight_friendlies_noplayer();
	for( i=0; i<friendlies.size; i++ )
	{
		struct = getstruct( "bridgeskip_friendly" + i, "targetname" );
		friendlies[i] forceteleport( struct.origin, struct.angles );
	}

	level.skipto_bridge = true;
	
	run();
}

run()
{
	init_event();

	if( !isdefined(level.skipto_bridge) ) // normal flow
	{
		p = get_player();
		
		wait(2);
		
		level thread fade_in( 2, "black" );
	
		//need this here b/c anim messes with setup
		struct = getstruct( "p2shipfirefight_playerstart", "targetname" );
		p SetPlayerAngles( struct.angles );		
	
		p fa_show_hud( true ); // these happen in shipcinema
		p freezecontrols( false );
		p setstance( "stand" );
		p thread gradiate_move_speed( 1.0 );	//return player speed to normal since we're about to have combat could be slower
		p AllowSprint( true );

		p thread anim_single( p, "ofcourse", "Reznov" ); 

		shipfirefight_uptobridge();
	}
	else
	{ 
		level thread fade_in( 2, "black" ); // only if we're using the bridge skipto
	}
	
	level thread shipfirefight_bridgetoend();
	
	flag_wait( "P2SHIPFIREFIGHT_EXIT" );

	cleanup();
	maps\fullahead_p2_shipmast::run();
}

init_event()
{
	fa_print( "init p2 shipfirefight\n" );
	
	//for performance
	get_player() SetClientDvar( "sm_sunSampleSizeNear", 0.5 );
	
	level thread ship_door_open( "stein" );
	
	level.firefight_countdown_duration = 180;
	level.firefight_countdown_achievement_time_remaining = 135;

	CreateThreatBiasGroup( "friendlies" );
	CreateThreatBiasGroup( "enemies" );
	
	SetThreatBias( "enemies", "friendlies", 3500 );
	
	SetDvar( "friendlyfire_enabled", "0" );
	level.friendlyFireDisabled = 1;
	
	level thread setup_team_follow_triggers();
	
	setup_railclimb_spawnfuncs();
	
	// would've been cut on in event five.
	door = getent( "shipcargo_welding_door", "targetname" );
	if( isdefined(door) )
	{
		door delete();
	}
	
	p = get_player();

	if( !isdefined(level.skipto_bridge) )
	{
		// relocate player to correct position, post-cinema
		player_to_struct( "p2shipfirefight_playerstart" );
	}
	
	enable_trigger_with_targetname( "ship_kill_trigger" );
	enable_trigger_with_targetname( "cargobay_explosives_trigger" );
	enable_trigger_with_targetname( "p2shipfirefight_cargo_spawn_stopper" );
	//enable_trigger_with_targetname( "p2shipfirefight_cargo_catwalk_collapse" );
	//enable_triggers_with_targetname( "p2shipfirefight_misc_triggers" );
	
	wait(0.1);
	
	exploder( 395 ); // full speed effects for the betrayal room
	

	// Give the player their melee weapon
	//p giveweapon( "knife_sp" );
	//p giveweapon( "frag_grenade_russian_sp" );
	//p giveweapon( "tokarevtt30_sp" );
	//p givemaxammo( "tokarevtt30_sp" );
	//p switchtoweapon( "tokarevtt30_sp" );


	door = getent( "ship_doorcargo", "targetname" );
	door delete();
	
	enable_trigger_with_targetname( "cargobay_entrance_blocker" );
	blocker = getent( "cargobay_entrance_blocker", "targetname" );
	blocker disconnectpaths();
	
	enable_triggers_with_targetname( "cargo_blocker_geo" );
	enable_trigger_with_targetname( "cargo_blocker_clip" );
	blocker = getent( "cargo_blocker_clip", "targetname" );
	blocker disconnectpaths();
	
	level.drone_weaponlist_axis = [];
	level.drone_weaponlist_axis[0] = "sten_sp";
	level.drone_spawnFunction["axis"] = character\c_brt_fullahead_drone::main;
	
	// setup guys
	level.steiner = simple_spawn_single( "p2shiparrival_steiner_spawner" );
	level.steiner.name = "Steiner";
	level.steiner.targetname = "Steiner";
	level.steiner.animname = "steiner";
	level.steiner.goalradius = 32;
	level.steiner.ignoreall = true;
	level.steiner.noDodgeMove = true;

	level.dragovich = simple_spawn_single( "p2shiparrival_dragovich_spawner" );
	level.dragovich.name = "Dragovich";
	level.dragovich.targetname = "Dragovich";
	level.dragovich.animname = "dragovich";
	level.dragovich.goalradius = 32;
	level.dragovich.ignoreall = true;
	level.dragovich.noDodgeMove = true;

	level.kravchenko = simple_spawn_single( "p2shiparrival_kravchenko_spawner" );
	level.kravchenko.name = "Kravchenko";
	level.kravchenko.targetname = "Kravchenko";
	level.kravchenko.animname = "kravchenko";
	level.kravchenko.goalradius = 32;
	level.kravchenko.ignoreall = true;
	level.kravchenko.noDodgeMove = true;
	
	shipfirefight_spawn_friends();			// guys stuck in the same room with player
	
	add_global_spawn_function( "axis", ::spawnfunc_no_name );
	add_global_spawn_function( "allies", ::spawnfunc_no_name );
	
	add_global_spawn_function( "axis", ::spawnfunc_setthreatbiasgroup );
	add_global_spawn_function( "allies", ::spawnfunc_setthreatbiasgroup );
	
	shipfirefight_cargo_spawn_guards();		// dragovich friends that guard the door
	
	level.dragovich_group_exit_count = 0;	// count the number of dragovich's group has exited
	level.dragovich_group_min_exited = 2;	// min number of the group to exit before continuing
	
	struct = getstruct( "firefight_dead_patrenko", "targetname" );
	level.cin_petrenko = fa_drone_spawn( struct, "patrenko" );
	level.cin_petrenko startragdoll();
	
	struct = getstruct( "firefight_dead_guy1", "targetname" );
	level.cin_guy1 = fa_drone_spawn( struct, "allieshigh" );
	level.cin_guy1 startragdoll();
	
	struct = getstruct( "firefight_dead_guy2", "targetname" );
	level.cin_guy2 = fa_drone_spawn( struct, "allieshigh" );
	level.cin_guy2 startragdoll();
}

// gets run through at start of level
init_flags()
{
	flag_init( "P2SHIPFIREFIGHT_EXPLOSIVES_DIALOGUE_COMPLETE" );
	flag_init( "P2SHIPFIREFIGHT_DRAGOVICH_GROUP_GONE" );
	flag_init( "P2SHIPFIREFIGHT_COMBAT_START" );
	flag_init( "P2SHIPFIREFIGHT_DOOR_IS_OPEN" );
	flag_init( "P2SHIPFIREFIGHT_ARMING" );
	flag_init( "P2SHIPFIREFIGHT_ARMED" );
	flag_init( "P2SHIPFIREFIGHT_ROCKET_DIALOGUE_COMPLETE" );
	flag_init( "P2SHIPFIREFIGHT_ROCKETFELL" );
	flag_init( "P2SHIPFIREFIGHT_CARGO_DONE" );
	flag_init( "P2SHIPFIREFIGHT_AT_TEAR" );
	flag_init( "P2SHIPFIREFIGHT_AT_FLICKER_ROOM" );
	flag_init( "P2SHIPFIREFIGHT_AT_BRIDGE" );
	flag_init( "P2SHIPFIREFIGHT_ON_DECK" );
	flag_init( "P2SHIPFIREFIGHT_EXIT" );
	maps\fullahead_p2_shipmast::init_flags();
}

cleanup()
{
	fa_print( "cleanup p2 shipfirefight\n" );
	
	SetDvar( "friendlyfire_enabled", "1" );
	level.friendlyFireDisabled = 0;
	
	fa_print( "Destroying countdown timer!" );
	level.countdown_elem Destroy();
	
	fa_print( "Removing on_save_restored callback!" );
	OnSaveRestored_CallbackRemove(::on_save_restored);

}

objectives( curr_obj_num )
{
	// if you're doing a skipto, the delay gives the triggers a chance to enable,
	// so the objective marker is in the right place for the explosives trigger
	wait( 0.05 );
	
	main_obj_num = curr_obj_num;
	curr_obj_num++;
	
	flag_wait( "P2SHIPFIREFIGHT_DOOR_IS_OPEN" );
	
	//
	objective_add( main_obj_num, "active", &"FULLAHEAD_OBJ_ESCAPE_SHIP" );
	//
	//flag_wait( "P2SHIPFIREFIGHT_EXPLOSIVES_DIALOGUE_COMPLETE" );
	objective_add( curr_obj_num, "active", &"FULLAHEAD_OBJ_ARM_EXPLOSIVES" );
	objective_position( curr_obj_num, ent_origin("explosives_objective_struct") );
	objective_set3d( curr_obj_num, true ); // , "default", &"FULLAHEAD_MARKER_EXPLOSIVES"
	flag_wait( "P2SHIPFIREFIGHT_ARMED" );
	
	//
	objective_add( main_obj_num, "active", &"FULLAHEAD_OBJ_ESCAPE_SHIP_DETONATE" );
	//
	objective_delete( curr_obj_num ); // so we don't have the arm objective sitting there for the next few seconds

	flag_wait( "P2SHIPFIREFIGHT_ROCKET_DIALOGUE_COMPLETE" );
	objective_add( curr_obj_num, "active", &"FULLAHEAD_OBJ_SHOOTROCKET" );
	objective_position( curr_obj_num, ent_origin("cargobay_rocket_shootme") );
	objective_set3d( curr_obj_num, true );
	flag_wait( "P2SHIPFIREFIGHT_ROCKETFELL" );
	objective_delete( curr_obj_num );
	
	objective_position( main_obj_num, ent_origin("p2shipfirefight_catwalk_objective_trigger") );
	objective_set3d( main_obj_num, true );
	trigger_wait( "p2shipfirefight_catwalk_objective_trigger" );

	// JMA - adding objective here
	objective_position( main_obj_num, ent_origin("second_floor_rocketroom_door") );
	objective_set3d( main_obj_num, true );
	trigger_wait( "firefight_teamtrigger:p118", "script_noteworthy" );
	
	objective_position( main_obj_num, ent_origin("p2shipfirefight_cargo_done") );
	objective_set3d( main_obj_num, true );
	flag_wait( "P2SHIPFIREFIGHT_CARGO_DONE" );
	
	obj_star = GetStruct("p2shipfirefight_crossfire_room_entrance_objective", "targetname");
	objective_position( main_obj_num, obj_star.origin );
	objective_set3d( main_obj_num, true );
	trigger_wait( "p2shipfirefight_turned_tear_corner" );
		
	obj_star = GetStruct("p2shipfirefight_starboard_objective", "targetname");
	objective_position( main_obj_num, obj_star.origin );
	objective_set3d( main_obj_num, true );
	
	//shortcircuit -jc
	//add a mrkr on new path -jc
	
//	// JMA - adding objective here
//	obj_star = GetStruct("p2shipfirefight_crossfire_room", "targetname");
//	objective_position( main_obj_num, obj_star.origin );
//	objective_set3d( main_obj_num, true );
//	trigger_wait( "p2shipfirefight_crossfire_room_objective_trigger" );	
//	
//	objective_position( main_obj_num, ent_origin("p2shipfirefight_flicker_room_entrance") );
//	objective_set3d( main_obj_num, true );
//	trigger_wait( "p2shipfirefight_flicker_room_entrance" );
//	
//	// JMA - adding objective here
//	obj_star = GetStruct("p2shipfirefight_flicker_room_exit_objective", "targetname");
//	objective_position( main_obj_num, obj_star.origin );
//	objective_set3d( main_obj_num, true );
//	trigger_wait( "p2shipfirefight_flicker_room_exit_objective_trigger" );		
//	
//	objective_position( main_obj_num, ent_origin("p2shipfirefight_post_flicker_room") );
//	objective_set3d( main_obj_num, true );
//	trigger_wait( "p2shipfirefight_post_flicker_room" );
//	
//	// JMA - adding objective here
//	obj_star = GetStruct("p2shipfirefight_bridge_entrance_objective", "targetname");
//	objective_position( main_obj_num, obj_star.origin );
//	objective_set3d( main_obj_num, true );
//	trigger_wait( "p2shipfirefight_bridge_entrance_objective_trigger", "script_noteworthy" );			
//	
//	objective_position( main_obj_num, ent_origin("p2shipfirefight_at_bridge") );
//	objective_set3d( main_obj_num, true );
//	flag_wait( "P2SHIPFIREFIGHT_AT_BRIDGE" );
//	
//	objective_position( main_obj_num, ent_origin("ship_bridge_window_objective") );
//	objective_set3d( main_obj_num, true );
	flag_wait( "P2SHIPFIREFIGHT_ON_DECK" );

	objective_position( main_obj_num, ent_origin("p2shipmast_geton") );
	objective_set3d( main_obj_num, true ); // , "default", &"FULLAHEAD_MARKER_CABLE"
	flag_wait( "P2SHIPFIREFIGHT_EXIT" );

	maps\fullahead_p2_shipmast::objectives( main_obj_num );
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

dragovich_leaves_sequence()
{
	align_struct = getstruct( "dragovich_leaves_anim_origin", "targetname" );
	align_struct thread anim_single_aligned( level.dragovich, "dragovich_leaves", undefined, "dragovich" );
	align_struct thread anim_single_aligned( level.steiner, "dragovich_leaves", undefined, "steiner" );
	align_struct thread anim_single_aligned( level.kravchenko, "dragovich_leaves", undefined, "kravchenko" );
	
	// these guys go to the door and get blown up
	align_struct thread anim_single_aligned( level.guy1, "dragovich_leaves", undefined, "guy_1" );
	align_struct thread anim_single_aligned( level.guy2, "dragovich_leaves", undefined, "guy_2" );
	
	// buddies in the room with you
	align_struct thread anim_single_aligned( level.nevski, "worried", undefined, "Nevski" );
	align_struct thread anim_single_aligned( level.tvelin, "worried", undefined, "Tvelin" );
	
	align_struct waittill( "dragovich_leaves" );
		
	level.steiner thread dragovich_leaves_exit_room( "1" );
	level.dragovich thread dragovich_leaves_exit_room( "2" );
	level.kravchenko thread dragovich_leaves_exit_room( "3" );	
	
	wait 1;
	
	level.guy1 thread anim_single( level.guy1, "ourpositions", "Soldier" );

	wait 1;	//give VIPS time to get out/delete -jc
	
	flag_set( "P2SHIPFIREFIGHT_COMBAT_START" );

}

dragovich_leaves_exit_room( node_num )	// self = ai exiting room
{
	node1 = GetNode( "dragleaves_intermediate" + node_num, "targetname" );
	node2 = GetNode( "dragleaves_n" + node_num, "targetname" );
	
	//self force_goal( node1, 96 ); //get guys out quicker - jc
	self force_goal( node2, 192 );

	level.dragovich_group_exit_count++;
	if(level.dragovich_group_exit_count > level.dragovich_group_min_exited)
	{
		flag_set( "P2SHIPFIREFIGHT_DRAGOVICH_GROUP_GONE" );
	}
	
	self delete();
}


shipfirefight_uptobridge()
{	
	level thread catwalk_collapse_thread();

	wait(0.1);
	
	battlechatter_on();
	
	// switches the player and his team's team setting based on the current situation
	get_player() thread shipfirefight_teamhandler();

	level thread shipfirefight_friendly_escape();	
	level thread shipfirefight_sas_arrival();
	level thread cargobay_fastrope_guys();
	level thread explosives_objective();
	level thread cargobay_exit_hallway_spawn();
	level thread cargobay_reinforcement_spawn();
	level thread cargobay_explosion_trigger_thread();
	
	trigger_wait( "p2shipfirefight_cargo_done", "targetname" );
	cargobay_cleanup();
	level thread notourwar_conversation();
	flag_set( "P2SHIPFIREFIGHT_CARGO_DONE" );
	autosave_by_name( "fullahead" );
	
	level thread shipfirefight_cargo_to_bridge();
}

shipfirefight_cargo_to_bridge()
{
	
	
	level thread tear_fastrope_guys();
	level thread spawn_tear_guys();
	
	level.firefight_friendlies[1] stop_magic_bullet_shield();
	
	trigger_wait( "p2shipfirefight_turned_tear_corner" );
//	flag_set( "P2SHIPFIREFIGHT_AT_TEAR" );
	cleanup_exit_hallway_guys();
//	
//	level thread spawn_manager_enable( "p2shipfirefight_wave2_sas_sm01blue" );
//	trig = getent( "flicker_room_rusher", "script_noteworthy" );
//	trig thread banzai_thread();
//	
//	trigger_wait( "p2shipfirefight_flicker_room_entrance" );
//	flag_set( "P2SHIPFIREFIGHT_AT_FLICKER_ROOM" );
//	autosave_by_name( "fullahead" );
	
	//shortcircuit -jc
	//level thread shipfirefight_spawn_office_guys();
	//wait 1;
	//trigger_use( "p2shipfirefight_at_bridge", "targetname" );	//so script continues
	
	//fight at bow -jc
	//trigger_wait( "shipfirefight_exitbridge", "targetname" );
	wait 3;
	player = get_players()[0];
	trig = getent( "deck_sas_start_trigger", "targetname" );
	trig useby(player);
	trig = getent( "deck_russ_start_trigger", "targetname" );
	trig useby(player);
	
}

init_melee_fight( fight_index, ref_node, num_loops, index_num )
{
	guy = simple_spawn_single( "bow_fight_russ_spawner" );
	if( !isdefined(guy) ) // in case we ran out of population
		return;
		
	level.melee_russ[index_num] = guy;
	level.melee_ger[index_num] = fa_drone_spawn( ref_node, "britishhigh" );
	level.melee_ger[index_num].health = 10;
	level.melee_russ[index_num] thread maps\fullahead_p2_nazibase::do_melee_fight( ref_node, fight_index, num_loops, index_num );
	level.melee_ger[index_num] thread maps\fullahead_p2_nazibase::do_melee_fight( ref_node, fight_index, num_loops, index_num );
}

shipfirefight_bridgetoend()
{
	//use a new trigger on new path - jc
	//trigger_wait( "p2shipfirefight_at_bridge", "targetname" );
	trigger_wait( "p2shipfirefight_turned_tear_corner" );
	
	get_player()SetClientDvar( "sm_sunSampleSizeNear", 1.9 );

	//change to a trigger closer
	wait 2; //temp
	
	SetThreatBias( "enemies", "friendlies", 99999 ); // turn up the heat
	
	// start bridge drones
	level thread start_bow_railclimb_drones();
	level thread fakefire_thread( "bow_fakefire_start_0", "bow_fakefire_target_0", "stop_fake_fire" );
	level thread fakefire_thread( "bow_fakefire_start_1", "bow_fakefire_target_1", "stop_fake_fire" );
	level thread fakefire_thread( "bow_fakefire_start_2", "bow_fakefire_target_2", "stop_fake_fire" );
	level thread disable_drones_thread();
	
	flag_set( "P2SHIPFIREFIGHT_AT_BRIDGE" );
	autosave_by_name( "fullahead" );
	//level thread spawn_bridge_climbers();
	//level thread window_reminder_thread();
	
	trigger_wait( "shipfirefight_exitbridge", "targetname" );
	
	//cleanup old fighting guys first
	ai = getentarray( "bow_fight_russ_spawner_ai", "targetname" );
	for( i=0; i<ai.size; i++ )
	{
		ai[i] die();
		wait(0.05);
	}

	wait(0.05);// pause so we don't delete next bow guys

	// start the melee guys on the bow
	melee_points = getstructarray( "bow_fight_point", "targetname" );
	for( i=0; i<melee_points.size; i++ )
	{
		init_melee_fight( 3, melee_points[i], 99999, i );
	}
	
	level thread deck_cable_dialogue();
	level thread spawn_bow_climbers();
	level thread cleanup_bridge_ai();	//	cleanup guys in cracked area

	level notify("stop_looping_drones");
	level notify("stop_fake_fire");	//added b/c trigger that turned off in old path -jc

	trigger_wait( "p2shipmast_geton", "targetname" );
	try_countdown_achievement();
	
	flag_set( "P2SHIPFIREFIGHT_EXIT" );
	
	battlechatter_off();
}

spawn_tear_guys()
{
	//simple_spawn( "p2shipfirefight_wave2_sas" );	//remove some guys - jc
	
	wait(0.1);
	
	spawners = getentarray( "p2shipfirefight_wave2_russ", "targetname" );
	for( i=0; i<spawners.size; i++ )
	{
		fa_print( "Spawning wave01 russ " + i );
		spawners[i] stalingradspawn();
	}
	
	wait(0.1);

	simple_spawn( "p2shipfirefight_wave2_sas_edgeguard" );
	
		
	//level thread spawn_manager_enable( "p2shipfirefight_wave2_sas_sm01" );
	
	wait(0.1);
	
	simple_spawn_single( "p2shipfirefight_wave2_sas_catwalk" );
	
	// start the melee guys in the tear
	melee_points = getstructarray( "tear_fight_point", "targetname" );
	for( i=0; i<melee_points.size; i++ )
	{
		init_melee_fight( 3, melee_points[i], 99999, i );
	}
}

window_reminder_thread()
{
	level endon( "P2SHIPFIREFIGHT_ON_DECK" );
	
//     level.scr_sound["Nevski"]["windownag1"] = "vox_ful1_s06_376A_nevs"; //We've got to get down to the deck!
//     level.scr_sound["Nevski"]["windownag2"] = "vox_ful1_s06_377A_nevs"; //Reznov, we can climb out that window!
//     level.scr_sound["Nevski"]["windownag3"] = "vox_ful1_s06_378A_nevs"; //Hurry, out the window!

	i = 1;
	while( true )
	{
		if( i > 3 )
		{
			i = 1;
		}
			
		wait(10);
		fa_print( "windownag" + i );
		level.nevski thread anim_single( level.nevski, "windownag" + i, "Nevski" );
		
		//i++;
	}
}

//shipfirefight_spawn_office_guys()
//{
//	trigger_wait( "p2shipfirefight_post_flicker_room" );
//	simple_spawn( "p2shipfirefight_office_guys" );	
//	
//	level thread yellowdolphin_jumper_thread();
//}

//yellowdolphin_jumper_thread()
//{
//	trigger_Wait( "yellowdolphin_jumper_trigger" );
//	guy = simple_spawn_single( "yellowdolphin_jumper" );
//	if( isdefined(guy) )
//	{
//		node = getnode( "yellowdolphin_jumper_dest", "targetname" );
//		guy force_goal( node, 32 );
//	}
//}

disable_drones_thread()
{
	trigger_wait( "p2shipmast_disable_drones_trigger", "targetname" );
	level notify("stop_looping_drones");
	level notify("stop_fake_fire");	
}

start_bow_railclimb_drones()
{
	level thread bow_railclimb_drones( "drone_railclimb_0", "axis" );
	level thread bow_railclimb_drones( "drone_railclimb_1", "axis" );
	level thread bow_railclimb_drones( "drone_railclimb_2", "axis" );
}

bow_railclimb_drones( tn, team )
{
	level endon("stop_looping_drones");
	
	while(1)
	{
		fa_start_drone_path( tn, team );
		wait(RandomInt(90));
	}	
}

cleanup_bridge_ai()
{
	wait(1);
	
	ai = getentarray( "firefight_bridge_russian_ai", "targetname" );
	for( i=0; i<ai.size; i++ )
	{
		ai[i] die();
		wait(0.05);
	}
	
	ai = getentarray( "bridge_railclimb_spawner_ai", "targetname" );
	for( i=0; i<ai.size; i++ )
	{
		ai[i] die();
		wait(0.05);
	}
	ai = getentarray( "p2shipfirefight_wave2_sas_edgeguard_ai", "targetname" );
	for( i=0; i<ai.size; i++ )
	{
		ai[i] die();
		wait(0.05);
	}
	ai = getentarray( "p2shipfirefight_wave2_russ_ai", "targetname" );
	for( i=0; i<ai.size; i++ )
	{
		ai[i] die();
		wait(0.05);
	}
	ai = getentarray( "p2shipfirefight_wave2_sas_catwalk_ai", "targetname" );
	for( i=0; i<ai.size; i++ )
	{
		ai[i] die();
		wait(0.05);
	}
	ai = getentarray( "tear_fastrope_spawner_1_ai", "targetname" );
	for( i=0; i<ai.size; i++ )
	{
		ai[i] die();
		wait(0.05);
	}
		
}

shipfirefight_postcargo_drones()
{
	trig1 = getent( "firefight_postcargo_east_drones1", "target" );
	trig1 notify( "trigger" );
	
	wait(0.2);

	trig2 = getent( "firefight_postcargo_east_drones2", "target" );
	trig2 notify( "trigger" );
	
	level waittill("stop_looping_drones");
	
	trig1 notify( "stop_drone_loop" ); 
	trig2 notify( "stop_drone_loop" ); 
}

cargobay_reinforcement_spawn()
{
	trigger_wait("cargobay_reinforce");
	simple_spawn( "cargobay_spawner_downstairs" );
}

cargobay_exit_hallway_spawn()
{
	trigger_wait("cargobay_escape_hallway");
	simple_spawn( "escape_hallway_guys" );
	level thread shipfirefight_postcargo_drones();
}

cleanup_exit_hallway_guys()
{
	guys = getentarray( "escape_hallway_guys_ai", "targetname" );
	
	if( isdefined(guys) )
	{
		for( i=0; i<guys.size; i++ )
		{
			if( isalive(guys[i]) )
			{
				guys[i] die();	
			}
		}	
	}
}

deck_cable_dialogue()
{
	wait(1);
	
	battlechatter_off();
	level.nevski anim_single( level.nevski, "usetherope", "Nevski" );
	battlechatter_on();
	
	flag_set( "P2SHIPFIREFIGHT_ON_DECK" );
}

//spawn_bridge_climbers()
//{
//	start = getstruct( "bridge_magic_bullet", "targetname" );
//	end = getstruct( start.target, "targetname" );
//	
////	r1 = simple_spawn_single( "firefight_bridge_russian_1" );
////	r2 = simple_spawn_single( "firefight_bridge_russian_2" );
//
//	
//	b1 = simple_spawn_single( "bridge_railclimb_spawner" );
//
//	wait(0.25);
//	MagicBullet( "mosin_sp", start.origin, end.origin + (0,0,32) );
//	wait(0.25);
//	MagicBullet( "mosin_sp", start.origin, end.origin + (32,0,32) ); // break the glass, heh
//	wait(0.2);
//	MagicBullet( "mosin_sp", start.origin, end.origin + (0,0,-32) );
//	wait(0.3);
//	MagicBullet( "mosin_sp", start.origin, end.origin + (-32,32,32) );
//	wait(0.15);
//	MagicBullet( "mosin_sp", start.origin, end.origin  + (64,0,0));
//	wait(0.25);
//	
//	b2 = simple_spawn_single( "bridge_railclimb_spawner" );
//	
//// 	if( isdefined(b1) && isdefined(r1) )
//// 	{
//// 		b1 setEntityTarget( r1 );
//// 		r1 setEntityTarget( b1 );
//// 	}
//// 	
//// 	if( isdefined(b2) && isdefined(r2) )
//// 	{
//// 		b2 setEntityTarget( r2 );
//// 		r2 setEntityTarget( b2 );
//// 	}
//}

//last guys 
spawn_bow_climbers()
{
	trigger_wait( "deck_railclimb_p_trigger" );	//trig is on steps
	
	simple_spawn_single( "deck_sas_railclimb_p_spawner" );
	wait( 0.5 );
	simple_spawn_single( "deck_sas_railclimb_p_spawner" );
	wait( 0.5 );
	simple_spawn_single( "deck_sas_railclimb_p_spawner" );
	wait( 1 );
	simple_spawn_single( "deck_sas_railclimb_p_spawner" );
	
}

cargobay_cleanup()
{
	ents = getentarray( "cargobay_ai", "script_noteworthy" );
	for( i=0; i<ents.size; i++ )
	{
		ents[i] delete();	
	}	
}

explosives_objective()
{
	level endon( "P2SHIPFIREFIGHT_EXIT" );
	
	flag_wait( "P2SHIPFIREFIGHT_EXPLOSIVES_DIALOGUE_COMPLETE" );
	
	level thread arm_explosives_reminder_thread();
	
	explosives = getent( "cargobay_explosives_objective", "targetname" );
	explosives setmodel( "anim_ger_dynamite_timer_obj" );

	trig = getent( "cargobay_explosives_trigger", "targetname" );
	trig trigger_use_button( &"FULLAHEAD_USE_EXPLOSIVES" );
	
	flag_set( "P2SHIPFIREFIGHT_ARMING" );
	
	// SOUND - Shawn J
	playsoundatposition("evt_arm_explos",(0,0,0));	
	
	explosives setmodel( "anim_ger_dynamite_timer" );
	player_arm_explosives( explosives );
	
	// SOUND - Shawn J
	//iprintlnbold ("armed");
		
	flag_set( "P2SHIPFIREFIGHT_ARMED" );

	start_countdown_timer( level.firefight_countdown_duration );
	fa_print( "Adding on_save_restored callback!" );
	//OnSaveRestored_Callback(::on_save_restored);
}

arm_explosives_reminder_thread()
{
	level endon( "P2SHIPFIREFIGHT_ARMING" );
	
//     level.scr_sound["Nevski"]["armnag1"] = "vox_ful1_s06_358A_nevs"; //We can’t hold forever!  Arm the explosives, Reznov.
//     level.scr_sound["Nevski"]["armnag2"] = "vox_ful1_s06_359A_nevs"; //Hurry! - Get the explosives armed.
//     level.scr_sound["Nevski"]["armnag3"] = "vox_ful1_s06_360A_nevs"; //Reznov! The explosives need to be armed!

	wait(30); // there's a fight going on, give the player time

	i = 1;
	while( true )
	{
		if( i > 3 )
		{
			i = 1;
		}
		
		fa_print( "armnag" + i );
		level.nevski thread anim_single( level.nevski, "armnag" + i, "Nevski" );
		i++;
		wait(15);
		
	}
}

countdown_reminder_thread( starting_seconds_remaining )
{
	level endon( "reload_timer_reset" );
	level endon( "P2SHIPFIREFIGHT_EXIT" );
	
	starting_seconds_remaining = int(starting_seconds_remaining); // ensure our modulous doesn't break
	
//     level.scr_sound["Nevski"]["4min"] = "vox_ful1_s06_363A_nevs"; //Four minutes, Reznov!
//     level.scr_sound["Reznov"]["3min30"] = "vox_ful1_s06_364A_rezn"; //We have less than four minutes!
//     level.scr_sound["Nevski"]["1min30"] = "vox_ful1_s06_365A_nevs"; //Keep moving, time is running out!
//     level.scr_sound["Reznov"]["3min"] = "vox_ful1_s06_366A_rezn"; //In three minutes this ship will be engulfed in flames.
//     level.scr_sound["Nevski"]["2min30"] = "vox_ful1_s06_367A_nevs"; //We have to get off the ship!
//     level.scr_sound["Reznov"]["2min"] = "vox_ful1_s06_368A_rezn"; //Hurry - We only have two minutes left!
//     level.scr_sound["Reznov"]["1min"] = "vox_ful1_s06_369A_rezn"; //In one minute - Fire will consume this vessel - MOVE!!
//     level.scr_sound["Reznov"]["30"] = "vox_ful1_s06_370A_rezn"; //Thirty seconds!
//     level.scr_sound["Reznov"]["10"] = "vox_ful1_s06_372A_rezn"; //We’re not going to make it!

	minute = 60.0;
	seconds_remaining = starting_seconds_remaining;
	
	fa_print( "countdown_reminder_thread starting with " + seconds_remaining + " seconds" );
	
	// if we're greater than four minutes thirty, wait until we're at that point
	if( seconds_remaining > 4*minute + 30 )
	{
		wait_time = seconds_remaining - (4*minute + 30);
		fa_print( "countdown_reminder_thread waiting  " + wait_time + " seconds" );
		wait( wait_time );
		seconds_remaining = 4*minute + 30;
	}
	else // otherwise, we need to get to a thirty second interval
	{
		remainder = seconds_remaining%30;
		fa_print( "countdown_reminder_thread waiting for remainder of " + remainder + " seconds" );
		wait(remainder);
		seconds_remaining = seconds_remaining - remainder;
	}
	
	fa_print( "countdown_reminder_thread beginning iteration at " + seconds_remaining + " seconds" );
	
	// okay, if we got here we're either at 4:30 or a thirty second interval beneath that
	while( seconds_remaining > 0 )
	{
		wait(30);
		seconds_remaining -= 30;
		battlechatter_off();
		
		fa_print( "countdown_reminder_thread playing reminder..." );
		
		if( seconds_remaining > 3*minute + 45 )
		{
			fa_print( "4:00" );
			level.nevski thread anim_single( level.nevski, "4min", "Nevski" );
		}
		else if( seconds_remaining > 3*minute + 15 )
		{
			fa_print( "3:30" );
			get_player() thread anim_single( get_player(), "3min30", "Reznov" );
		}
		else if( seconds_remaining > 2*minute + 45 )
		{
			fa_print( "3:00" );
			get_player() thread anim_single( get_player(), "3min", "Reznov" );
		}
		else if( seconds_remaining > 2*minute + 15 )
		{
			fa_print( "2:30" );
			level.nevski thread anim_single( level.nevski, "2min30", "Nevski" );
		}
		else if( seconds_remaining > 1*minute + 45 )
		{
			fa_print( "2:00" );
			get_player() thread anim_single( get_player(), "2min", "Reznov" );
		}
		else if( seconds_remaining > 1*minute + 15 )
		{
			fa_print( "1:30" );
			// this one's generic, and there's not a specific line for 1:30
			level.nevski thread anim_single( level.nevski, "1min30", "Nevski" );
		}
		else if( seconds_remaining > 45 )
		{
			fa_print( "1:00" );
			get_player() thread anim_single( get_player(), "1min", "Reznov" );
		}
		else if( seconds_remaining > 15 )
		{
			fa_print( "0:30" );
			
			get_player() thread anim_single( get_player(), "30", "Reznov" );
			wait(20);
			
			fa_print( "0:10" );
			get_player() thread anim_single( get_player(), "10", "Reznov" );
		}
		
		battlechatter_on();
	}

	
}

explode_when_out( duration )
{
	level endon( "reload_timer_reset" );
	level endon( "P2SHIPFIREFIGHT_EXIT" );
	
	wait( duration );
	
//	guys = getaiarray( "axis", "allies" );
//	for( i=0; i<guys.size; i++ )
//	{
//		guys[i] stop_magic_bullet_shield();
//		playfx( level._effect["explosion_1"], guys[i].origin );
//		guys[i] die();
//		wait(0.05);
//	}
	
	p = get_player();
	playfx( level._effect["explosion_1"], p.origin );
	p suicide();
	
	MissionFailedWrapper( &"FULLAHEAD_SHIP_FAIL");
}

flash_normally()
{
	level endon( "P2SHIPFIREFIGHT_EXIT" );
	level endon( "stop_normal_countdown_flashing" );

	while( 1 )
	{
		self.color = ( 1.0, 0.0, 0.0 );  
		self.fontScale = 2.0;
		wait( 0.5 );
		self.color = ( 1.0, 1.0, 1.0 );  
		self.fontScale = 2.0;
		wait( 0.5 );
	}
}

flash_when_low( duration )
{
	level endon( "reload_timer_reset" );
	level endon( "P2SHIPFIREFIGHT_EXIT" );
	
	wait( duration - 20 );
	level notify( "stop_normal_countdown_flashing" );
	
	while( 1 )
	{
		self.color = ( 1.0, 0.0, 0.0 );  
		self.fontScale = 2.5;
		wait( 0.25 );
		self.color = ( 1.0, 1.0, 1.0 );  
		self.fontScale = 2.0;
		wait( 0.25 );
	}
}

start_countdown_timer( duration ) // stolen from flashpoint
{
	level.firefight_countdown_achievement_valid = true;
	
	elem = undefined;
	
	if( isdefined(level.countdown_elem) ) // could exist already after a restart-from-save
	{
		elem = level.countdown_elem;
	}
	else
	{
		elem = NewHudElem();
	}
		
	elem.hidewheninmenu = true;
	elem.horzAlign = "center";
	elem.vertAlign = "top";
	elem.alignX = "center";
	elem.alignY = "middle";
	elem.x = 0;
	elem.y = 20;
	elem.foreground = true;
	elem.font = "default";
	elem.fontScale = 2.0;
	elem.color = ( 1.0, 1.0, 1.0 );        
	elem.alpha = 1.0;
	elem SetTimer( duration );
	
	level.countdown_elem = elem;
	
	elem thread flash_when_low( duration );
	elem thread flash_normally();
	level thread explode_when_out( duration );
	
	level thread countdown_reminder_thread( duration  );
	
	// I like long variable names
	level thread countdown_invalidate_achievement( duration, level.firefight_countdown_achievement_time_remaining );
}

countdown_invalidate_achievement( total_duration, time_remaining )
{
	adjusted_duration = total_duration - time_remaining;
	
	if( adjusted_duration > 0 )
	{
		wait(adjusted_duration);
	}
	
	level.firefight_countdown_achievement_valid = false;
}

try_countdown_achievement()
{
	if( level.firefight_countdown_achievement_valid == true && level.gameSkill == 3 ) // veteran
	{
		get_player() giveachievement_wrapper( "SP_LVL_FULLAHEAD_2MIN" );
	}
}

cargobay_fastrope_guys()
{
	//self waittill_spawn_manager_ai_remaining( "p2shipfirefight_cargo_sas_sm", 3 );
	trigger_wait( "p2shipfirefight_cargo_fastrope_1" );
	
	level thread spawn_fastrope_guy( "cargobay_fastrope_spawner_1", "cargobay_fastrope_1", "fastrope_1" );
	level thread spawn_fastrope_guy( "cargobay_fastrope_spawner_1", "cargobay_fastrope_2", "fastrope_2", true );
	wait(0.25);
	level thread spawn_fastrope_guy( "cargobay_fastrope_spawner_1", "cargobay_fastrope_3", "fastrope_3" );
	level thread spawn_fastrope_guy( "cargobay_fastrope_spawner_1", "cargobay_fastrope_4", "fastrope_4" );
	
	//     level.scr_sound["Nevski"]["morebritish"] = "vox_ful1_s06_116A_nevs"; //More British!
	battlechatter_off();
	level.nevski anim_single( level.nevski, "morebritish", "Nevski" );
	battlechatter_on();
}

tear_fastrope_guys()
{
	//self waittill_spawn_manager_ai_remaining( "p2shipfirefight_cargo_sas_sm", 3 );
	trigger_wait( "p2shipfirefight_turned_tear_corner" );
	
	level thread spawn_fastrope_guy( "tear_fastrope_spawner_1", "tear_fastrope_1", undefined );
	
	wait(0.75);
	level thread spawn_fastrope_guy( "tear_fastrope_spawner_1", "tear_fastrope_2", undefined );
	
	wait(0.25);
	level thread spawn_fastrope_guy( "tear_fastrope_spawner_1", "tear_fastrope_3", undefined );

}

cargobay_explosion_trigger_thread()
{
	structs = getstructarray( "shipfirefight_blocker_explosion", "targetname" );
	trig = getent( "shipfirefight_explosion_trigger", "script_noteworthy" );
	
	assert(isdefined(structs));
	assert(isdefined(trig));
	
	trig waittill( "trigger" );
	
	exploder( 401 );
	
	// SOUND - Shawn J
	//iprintlnbold ("cargo_explos");
	playsoundatposition("evt_cargo_explo",(13453, -15411, 340));	
	
}

notourwar_conversation()
{
//     level.scr_sound["Reznov"]["keepmoving"] = "vox_ful1_s06_124A_rezn"; //Keep moving!
//     level.scr_sound["Reznov"]["notourwar"] = "vox_ful1_s06_125A_rezn"; //This is not our War!
//     level.scr_sound["Nevski"]["whoarewe"] = "vox_ful1_s06_126A_nevs"; //Then who are we to fight?!!
//     level.scr_sound["Reznov"]["EVERYONE!!!"] = "vox_ful1_s06_127A_rezn"; //EVERYONE!!!
//     level.scr_sound["Reznov"]["standalone"] = "vox_ful1_s06_128A_rezn"; //We stand alone!
	p = get_player();

	battlechatter_off();
	level.nevski headtracking_start( p );
	
	p anim_single( p, "keepmoving", "Reznov" );
	p anim_single( p, "notourwar", "Reznov" );
	level.nevski anim_single( level.nevski, "whoarewe", "Nevski" );
	p anim_single( p, "EVERYONE!!!", "Reznov" );
	p anim_single( p, "standalone", "Reznov" );
	
	level.nevski headtracking_stop();
	battlechatter_on();
	
	level thread window_reminder_thread();	//moved here lines don't interrupt -jc
}

// self should be an enemy AI
shipfirefight_opposite_of_player()
{
	self endon( "death" );
	
	while( true )
	{
		p = get_player();
		self.team = get_other_team( p.team );
		wait(2);
	}
}

shipfirefight_sas_arrival()
{
	door = getent( "p2shipfirefight_uppercargodoor", "targetname" );
	door delete();

	flag_wait( "P2SHIPFIREFIGHT_COMBAT_START" );
	
//	wait(2);	
//	array_thread( GetEntArray("p2shipfirefight_sas_cargo_lower", "targetname"), ::add_spawn_function, maps\fullahead_util::ai_naviage_thru_hallway );

	spawners = getentarray( "p2shipfirefight_sas_cargo_lower", "targetname" );
	for( i=0; i<spawners.size; i++ )
	{
		spawners[i] stalingradspawn();
		wait(0.25);
	}
	
	guy = simple_spawn_single( "p2shipfirefight_sas_cargo_upper1" );
	if( isdefined(guy) )
	{
		guy setgoalnode_tn( "cargo_upper1_target" );
		guy.goalradius = 32;
	}
	
	
	guy = simple_spawn_single( "p2shipfirefight_sas_cargo_upper2" );
	if( isdefined(guy) )
	{
		guy setgoalnode_tn( "cargo_upper2_target" );
		guy.goalradius = 32;
	}
	
	trig = getent( "p2shipfirefight_cargo_coloraxis", "targetname" );
	trig useby( get_player() );
	
	trig = getent( "p2shipfirefight_cargo_colorallies", "targetname" );
	trig useby( get_player() );
}

shipfirefight_cargo_spawn_guards()
{
	level.guy1 = simple_spawn_single( "p2shipfirefight_guard_dummy1" );
	level.guy1.animname = "guy_1";
	level.guy1.goalradius = 16;
	
	level.guy2 = simple_spawn_single( "p2shipfirefight_guard_dummy2" );
	level.guy2.animname = "guy_2";
	level.guy2.goalradius = 16;

	simple_spawn( "p2shipfirefight_guard_general" );	
}

shipfirefight_friendly_escape()
{
	level thread dragovich_leaves_sequence();
	
	// close the door that Dragovich and friends escaped through
	//level thread ship_door_close( "stein" );
	
	flag_wait("P2SHIPFIREFIGHT_DRAGOVICH_GROUP_GONE");
	
	level thread ship_door_close( "stein" );
	level thread escape_fakefire();
	
	// NOTE:  Door explosion and other scripting are handled in the fullahead_anim.gsc using notetracks from animations
		
	//flag_wait( "P2SHIPFIREFIGHT_PLAYER_LEFT_GAS_ROOM" );
	trigger_wait( "firefight_player_left_gas_room" );

	//give player weapons -jc
	p = get_players()[0];
	p giveweapon( "frag_grenade_russian_sp" );
	p giveweapon( "knife_sp" );
	p giveweapon( "ppsh_sp" );
	//p GiveMaxAmmo( "ppsh_sp" );
	p switchtoweapon( "ppsh_sp" );
	
	//wait till player leaves then turn off -jc
	stop_exploder( 397 ); // gas
	
	trigger_wait( "explosives_dialog_trigger" );

//     level.scr_sound["Reznov"]["iwillarm"] = "vox_ful1_s06_117A_rezn"; //I will arm the explosives...
//     level.scr_sound["Reznov"]["depths"] = "vox_ful1_s06_118A_rezn"; //We will plunge this vessel into the depths of hell!
	battlechatter_off();
	p anim_single( p, "iwillarm", "Reznov" );
	p anim_single( p, "depths", "Reznov" );
	battlechatter_on();
	flag_set( "P2SHIPFIREFIGHT_EXPLOSIVES_DIALOGUE_COMPLETE" );
}

escape_fakefire()
{
	level thread fakefire_thread( "shipfirefight_fakefire", "shipfirefight_escape_explosion", "stop_fake_fire" );
	wait(4);
	level notify( "stop_fake_fire" );
}

// Self should be friendly AI
steal_weapon( node_targetname )
{
	struct = getstruct( node_targetname, "targetname" );
	assert( isdefined(struct) );
	
	self gun_remove();
	self headtracking_start( get_player() );
	
	flag_wait( "P2SHIPFIREFIGHT_DOOR_IS_OPEN" );
	self.nododgemove = true;
	self set_ignoreall(true);
	self headtracking_stop();
	
	scene = struct.script_noteworthy;
	struct anim_reach( self, scene, "generic" ); // breaks out when they get there
	struct anim_single_aligned( self, scene, undefined, "generic" ); // pick up the gun

	// they get their gun during the animation
	self set_ignoreall(false);
	self.nododgemove = false;
}

shipfirefight_spawn_friends()
{
	level.firefight_friendlies = [];
	
	friend = simple_spawn_single( "p2shipfirefight_ally" );
	friend.script_noteworthy = "p2firefight_player_friendly"; // used for the team switching stuff
	friend thread magic_bullet_shield();
	friend.name = "Nevski";
	friend.ikpriority = 5;
	
	level.nevski = friend;
	level.firefight_friendlies[0] = friend;
	level.firefight_friendlies[0] thread steal_weapon( "firefight_weapon_pickup1" );
	level.nevski maps\_prisoners::make_prisoner();
	
	friend = simple_spawn_single( "p2shipfirefight_ally2" );
	friend.script_noteworthy = "p2firefight_player_friendly";
	friend thread magic_bullet_shield();
	friend.name = "Tvelin";
	friend.ikpriority = 5;

	level.tvelin = friend;
	level.firefight_friendlies[1] = friend;
	level.firefight_friendlies[1] thread steal_weapon( "firefight_weapon_pickup2" );
	level.tvelin maps\_prisoners::make_prisoner();
	
	friendlies = get_firefight_friendlies();
	for( i=0; i<friendlies.size; i++ )
	{
		friendlies[i] setThreatBiasGroup( "friendlies" );
	}
}

spawnfunc_no_name()
{
	wait(0.1);
	self.name = " ";
	self setlookattext( " ", &"FULLAHEAD_SINGLE_SPACE" );
}

spawnfunc_setthreatbiasgroup()
{
	self setThreatBiasGroup( "enemies" );
}


// ~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~

setup_railclimb_spawnfuncs()
{
	spawns = getentarray( "deck_sas_railclimb_o", "script_noteworthy" );
	for( i=0; i<spawns.size; i++ )
	{
		spawns[i] add_spawn_function( ::spawnfunc_railclimb, "deck_railclimb_o_", 4 );
	}
	
	spawns = getentarray( "deck_sas_railclimb_b", "script_noteworthy" );
	for( i=0; i<spawns.size; i++ )
	{
		spawns[i] add_spawn_function( ::spawnfunc_railclimb, "deck_railclimb_b_", 3 );
	}
	
	spawns = getentarray( "bridge_sas_railclimb", "script_noteworthy" );
	for( i=0; i<spawns.size; i++ )
	{
		spawns[i] add_spawn_function( ::spawnfunc_railclimb, "bridge_railclimb_", 2 );
	}
	
	spawns = getentarray( "deck_sas_railclimb_p", "script_noteworthy" );
	for( i=0; i<spawns.size; i++ )
	{
		spawns[i] add_spawn_function( ::spawnfunc_railclimb, "deck_railclimb_p_", 3 );
	}
}

spawn_railclimb_guy( spawn_targetname, start_struct_targetname, goto_node_targetname )
{
	guy = simple_spawn_single( spawn_targetname );
	if( isdefined(guy) )
		guy do_railclimb( start_struct_targetname, goto_node_targetname );
}

// self should be a freshly-spawned guy
spawnfunc_railclimb( targetname_starter, num_spots, tracking_var )
{
	if( !isdefined(level.railclimb_num) )
	{
		level.railclimb_num = [];
	}
	
	if( !isdefined(level.railclimb_num[targetname_starter]) )
	{
		level.railclimb_num[targetname_starter] = 1;
	}
		
	tn = targetname_starter + level.railclimb_num[targetname_starter];
	
	level.railclimb_num[targetname_starter]++;
	if( level.railclimb_num[targetname_starter] > num_spots ) // cycle through however many are in this set
		level.railclimb_num[targetname_starter] = 1;

	self do_railclimb( tn, undefined );
}

do_railclimb( start_struct_targetname, goto_node_targetname )
{
	align_struct = getstruct( start_struct_targetname, "targetname" );
	assert( isdefined(align_struct) );
	
	goto_node = undefined;
	
	if( isdefined(goto_node_targetname) )
	{
		goto_node = getnode( goto_node_targetname, "targetname" );
		assert( isdefined(goto_node) );
	}
	
	anim_string = "brit_rail_climb1";
	if( isdefined(align_struct.script_noteworthy) )
	{
		anim_string = align_struct.script_noteworthy;
	}
	
	self set_ignoreall( true );
		
	align_struct anim_single_aligned( self, anim_string, undefined, "generic" );
	
	self set_ignoreall( false );

// 	self set_ignoreall( true );
// 	self.org = spawn( "script_model", self.origin );
// 	self.org setmodel( "tag_origin" );
// 	self linkto( self.org );
// 	
// 	self.org.origin = start_struct.origin;
// 
// 	zangle = start_struct.angles[1]; // keep things level
// 	self.org.angles = (0,zangle,0);
// 
// 	self.org moveto( dest_struct.origin, 0.9 );
// 	self.org waittill( "movedone" );
// 	self unlink( false );

}

// ~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~

catwalk_setup_thread()
{
	catwalk = getent( "shipfirefight_cargo_catwalk", "targetname" ); // NOTE: this is now the collision brushes/patches for the FX anim model catwalk
	startpos = getstruct( "cargobay_catwalk_start", "targetname" );
	endpos = getstruct( "cargobay_catwalk_dest", "targetname" );  // if you change this, there's another one in catwalk_collapse
	
	assert( isdefined(catwalk) );
	assert( isdefined(startpos) );
	assert( isdefined(endpos) );
	
	catwalk moveto( startpos.origin, 0.1 );
	catwalk rotateto( startpos.angles, 0.1 );
	
	// below here is the rocket, doing the same basic thing
	
	start = getstruct( "cargobay_rocketfall_start", "targetname" );
	dest = getstruct( "cargobay_rocketfall_dest", "targetname" );
	
	assert( isdefined(start) );
	assert( isdefined(dest) );
	
	model = spawn( "script_model", start.origin );
	model.angles = start.angles;
	model setmodel( "p_rus_v2_pi" );
	level.cargobay_rocket = model;
}

catwalk_collapse_thread()
{
	catwalk = getent( "shipfirefight_cargo_catwalk", "targetname" ); // NOTE: this is now the collision brushes/patches for the FX anim model catwalk
	cat_dest = getstruct( "cargobay_catwalk_dest", "targetname" ); // if you change this, there's another one in catwalk_setup
	
	rocket = level.cargobay_rocket;
	rocket_start = getstruct( "cargobay_rocketfall_start", "targetname" );
	rocket_dest = getstruct( "cargobay_rocketfall_dest", "targetname" );
	
	chain = getent( "cargobay_rocket_shootme", "targetname" );
	chain Hide();
	p = get_player();
	p thread cold_breath("plyr");	//start breath again

	flag_wait( "P2SHIPFIREFIGHT_ARMED" );
	
	//wait(2);
	
//     level.scr_sound["Reznov"]["move!"] = "vox_ful1_s06_119A_rezn"; //Move! We have to get off the ship!
//     level.scr_sound["Nevski"]["doorsealed!"] = "vox_ful1_s06_120A_nevs"; //The door sealed!
//     level.scr_sound["Nevski"]["gantries"] = "vox_ful1_s06_121A_nevs"; //Shoot the support beams! We can bring down those gantries!
	
	level.nevski headtracking_start( p );
	battlechatter_off();
	p anim_single( p, "move!", "Reznov" );
	level.nevski anim_single( level.nevski, "doorsealed!", "Nevski" );
	level.nevski anim_single( level.nevski, "gantries", "Nevski" );
	battlechatter_on();
	
	level.nevski headtracking_stop();
	
	flag_set( "P2SHIPFIREFIGHT_ROCKET_DIALOGUE_COMPLETE" );
	
	chain setmodel( "p_ger_v2_gantry_pole_obj" );
	chain Show();
	trigger = getent( "cargobay_rocket_shootme_trigger", "targetname" );
	level thread gantry_reminder_thread();

	while(1)
	{
		trigger waittill("trigger", who );
		if( who == p )
		{
			break;
		}
		wait 0.1;
	
	}
	flag_set( "P2SHIPFIREFIGHT_ROCKETFELL" );
	enable_triggers_with_targetname( "p2shipfirefight_team_post_catwalk" );
	chain delete();
	trigger delete();
	
	level notify ("rocket_fall_start");

	//playfx( level._effect["explosion_1"], rocket_start.origin );
	
	// SOUND - Shawn J
	rocket playsound ("evt_rocket_fall");
//	rocket linked to animation	
//	rocket moveto( rocket_dest.origin, 1.0, 0.5 );
//	rocket rotateto( rocket_dest.angles, 1.0, 0.5 );
	
	wait( 0.5 );

	// SOUND - Shawn J
	catwalk playsound ("evt_catwalk_fall");
		
	catwalk moveto( cat_dest.origin, 1.0, 0.5 );
	catwalk rotateto( cat_dest.angles, 1.0, 0.5 );
	
	// PI - DMM - addition of kill trigger and v2 fallen collision logic for players standing under falling V2 and catwalk
	wait( 0.7 ); // NOTE: was .9
	exploder(410);

	// turn on kill trigger in case player is standing under the falling rocket or catwalk
	enable_trigger_with_targetname( "v2_gantry_collapse_kill_trigger" );
	
	wait( 0.1 );
	// make the clip blockers solid for the V2 rocket in the fallen position and rotated gantry pieces
	v2blocker = getent("shipcargo_rocketclip", "targetname");
	v2blocker Solid();
	
	wait( 0.1 );
	getent("v2_gantry_collapse_kill_trigger", "targetname") Delete(); // delete the kill trigger for the falling V2 and gantry, no longer needed
	
// 	structs = getstructarray( "catwalk_plume", "targetname" );
// 	for( i=0; i<structs.size; i++ )
// 	{
// 		playfx( level._effect["fx_snow_debris_plume_md"], structs[i].origin );
// 		wait( 0.05);
// 	}
	
//     level.scr_sound["Reznov"]["yes!"] = "vox_ful1_s06_122A_rezn"; //Yes!
//     level.scr_sound["Reznov"]["friendsgo"] = "vox_ful1_s06_123A_rezn"; //Go, my friends, GO!
	battlechatter_off();
	p anim_single( p, "yes!", "Reznov" );
	trigger_use( "p2shipfirefight_team_post_catwalk" );	//move squad -jc
	p anim_single( p, "friendsgo", "Reznov" );
	battlechatter_on();
	autosave_by_name( "fullahead" );

}

gantry_reminder_thread()
{
	level endon( "P2SHIPFIREFIGHT_ROCKETFELL" );
	
//     level.scr_sound["Nevski"]["gantrynag1"] = "vox_ful1_s06_373A_nevs"; //Reznov! Shoot the beams!
//     level.scr_sound["Nevski"]["gantrynag2"] = "vox_ful1_s06_374A_nevs"; //Hurry! Bring down those gantries!
//     level.scr_sound["Nevski"]["gantrynag3"] = "vox_ful1_s06_375A_nevs"; //Shoot the beams, Reznov! It’s our only way out!

	wait(5); // give the player a bit of extra time for the first nag...

	i = 1;
	while( true )
	{
		if( i > 3 )
		{
			i = 1;
		}
			
		wait(10);
		fa_print( "gantrynag" + i );
		level.nevski thread anim_single( level.nevski, "gantrynag" + i, "Nevski" );
		
		i++;
	}
}

// ~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~

spawn_fastrope_guy( spawn_targetname, start_struct_targetname, goto_node_targetname, is_rusher )
{
	struct = getstruct( start_struct_targetname, "targetname" );
	assert( isdefined(struct) );
	assert( isdefined(struct.target) );
	

 	goto_node = undefined;
 	
 	if( isdefined(goto_node_targetname) )
 	{
 		goto_node = getnode( goto_node_targetname, "targetname" );
 		assert( isdefined(goto_node) );
 	}
	
	//floor_struct = getstruct( struct.target, "targetname" );
	//assert( isdefined(floor_struct) );
	
	//drop_dist = struct.origin[2] - floor_struct.origin[2];
	
	guy = simple_spawn_single( spawn_targetname );
	if( !isdefined(guy) )
		return;

	guy set_ignoreall( true );
	guy playsound( "evt_brit_rappel" );
	guy start_ai_rappel( 3.0, start_struct_targetname, true, false );
	guy set_ignoreall( false );
	
	if( isdefined(goto_node) )
	{
		guy setgoalnode( goto_node );
	}
	
	if( isdefined(is_rusher) )
	{
	 	guy thread maps\_rusher::rush();
	
	}
}

// slides the AI down the rope, unlinks him, sends him to a cover node
// self should be the AI
fastrope_down( goto_node, drop_dist )
{	
	self endon( "death" );
	self gun_remove();

	ropeid = CreateRope( self.org.origin, (0,0,0), drop_dist * 0.95, self.org );
	//self SetAnim( level.scr_anim["generic"]["rope_slide"][0] );
	self.org thread anim_generic_loop( self, "rope_slide", "stop_slide_anim" );
	//self AnimScripted( "anim_finished", self.origin , self.angles, level.scr_anim["generic"]["rope_slide"][0] );

	
	
	self.org MoveZ( (0 - drop_dist), 2.5, .5, 1 );
	//newangles = ( 0, self.org.angles[1]-180.0, 0 ); // rotate to forwards
	//.org rotateto( newangles, 2, .5, .5 );
	self.org waittill( "movedone" );
	
	RopeRemoveAnchor( ropeid, 1 ); // detach the end of the rope
	self Unlink();
	self.org Delete();
	self.org notify( "stop_slide_anim" );
	self gun_recall();
	//self StopAnimScripted( 0.2 );
	
	if( IsDefined( goto_node ) )
	{
		self SetGoalNode( goto_node );
	}
	
	self set_ignoreall( false );
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


// includes the player
get_firefight_friendlies()
{
	friendlies = getentarray( "p2firefight_player_friendly", "script_noteworthy" );
	if( !isDefined( friendlies ) )
	{
		friendlies = [];
	}
	friendlies[friendlies.size] = get_player();
	
	return friendlies;
}

// does not includes the player
get_firefight_friendlies_noplayer()
{
	friendlies = getentarray( "p2firefight_player_friendly", "script_noteworthy" );
	if( !isDefined( friendlies ) )
	{
		friendlies = [];
	}

	return friendlies;
}

// switches the player and his team's team setting based on the current situation
// this attempts to simulate them being enemies of both sides
// self should be player
shipfirefight_teamhandler()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	last_node_update_position = (0,0,0);
	
	while( true )
	{
		friendlies = get_firefight_friendlies();
		
		allies_pop_adjust = 0;
		if( self.team == "allies" )
			allies_pop_adjust = friendlies.size-1;
			
		axis_pop_adjust = 0;
		if( self.team == "axis" )
			axis_pop_adjust = friendlies.size-1;
		
		// figure out who's the closest, weighted by the population
		allies = GetAiArray( "allies" ); 
		axis = GetAiArray( "axis" ); 
		
		closest_ally = get_closest_exclude( self.origin, allies, friendlies );
		closest_axis = get_closest_exclude( self.origin, axis, friendlies );
		
		closest_ent = undefined;
		
		if( isdefined(closest_ally) && isdefined(closest_axis) )
		{
			closest_ally_dist = distancesquared( self.origin, closest_ally.origin );
			closest_ally_weighted = closest_ally_dist / ( 2 + allies.size - allies_pop_adjust );
			
			closest_axis_dist = distancesquared( self.origin, closest_axis.origin );
			closest_axis_weighted = closest_axis_dist / ( 2 + axis.size - axis_pop_adjust );
			
			//fa_print( "ALLY: " + closest_ally_dist + "   WEIGHTED: " + closest_ally_weighted );
			//fa_print( "AXIS: " + closest_axis_dist + "   WEIGHTED: " + closest_axis_weighted );
			
			
			if( closest_ally_weighted < closest_axis_weighted )
				closest_ent = closest_ally;
			else
				closest_ent = closest_axis;
		}
		else if( isdefined(closest_ally) )
		{
			closest_ent = closest_ally;
		}
		else if( isdefined(closest_axis) )
		{
			closest_ent = closest_axis;
		}
		
		// all the above mess used to just be this... we'll see if it's actually better, but it's weighted by population now at least
		//closest_ent = get_closest_ai_exclude( self.origin, undefined, friendlies ); // friendlies are excluded

		if( isDefined(closest_ent) )
		{ // set the player and allies to the opposite of that team
			newteam = get_other_team( closest_ent.team );
			//fa_print( "shipfirefight_teamhandler: Team is " + newteam );	
			for( i=0; i<friendlies.size; i++ )
			{
				friendlies[i].team = newteam;
			}
		}

		wait(0.5);
	}
}

setup_team_follow_triggers()
{
	triggers = [];
	triggers = array_combine( triggers,  GetEntArray( "trigger_multiple", "classname" ) );
	triggers = array_combine( triggers,  GetEntArray( "trigger_radius", "classname" ) );
	triggers = array_combine( triggers,  GetEntArray( "trigger_once", "classname" ) );
	
	for( i=0; i<triggers.size; i++ )
	{
		t = triggers[i];
		
		if( isdefined(t.script_noteworthy) && issubstr(t.script_noteworthy,"firefight_teamtrigger:")  )
		{
			pair = strtok(t.script_noteworthy,":");
			assert( pair.size > 1 );
			
			t thread team_follow_trigger_thread( pair[1] );
		}
	}
}

// self should be a trigger
team_follow_trigger_thread( key )
{
	nodes = getnodearray( key, "script_noteworthy" );
	assertex( isdefined(nodes), "Missing nodes for key: " + key );
	assertex( nodes.size >= 2, "Not enough nodes for key: " + key );

	while(true)
	{
		self waittill( "trigger" );
		
		if( isdefined(level.last_firefight_teamtrigger) && level.last_firefight_teamtrigger == self )
		{
			// do nothing if this is the same trigger as last time
		}
		else
		{
			// otherwise, send our guys to their nodes
			
			friendlies = get_firefight_friendlies_noplayer();
			for( i=0; i<friendlies.size && i<nodes.size; i++ )
			{
				if( isdefined(friendlies[i]) && isalive(friendlies[i]) )
				{
					friendlies[i] setgoalnode(nodes[i]);
				}
			}
			
			fa_print( "Sending friendlies to nodes: " + key );
			level.last_firefight_teamtrigger = self;
		}
		
		if( isdefined(self.script_parameters) && self.script_parameters == "repeat" )
		{
			wait(1);
		}
		else
		{
			return; // we're done if we're not set to repeating
		}
	}
	
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~ Handles reloads during countdown ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

on_save_restored()
{
	if( flag("P2SHIPFIREFIGHT_AT_BRIDGE") )
	{
		fa_print( "on_save_restored resetting timer for bridge" );
		
		level notify( "reload_timer_reset" );
		
		duration = level.firefight_countdown_duration * 0.3;
		start_countdown_timer( duration );
	}
	else if( flag("P2SHIPFIREFIGHT_AT_FLICKER_ROOM") )
	{
		fa_print( "on_save_restored resetting timer for after tear fight" );
		
		level notify( "reload_timer_reset" );
		
		duration = level.firefight_countdown_duration * 0.5;
		start_countdown_timer( duration );
	}
	else if( flag("P2SHIPFIREFIGHT_CARGO_DONE") )
	{
		fa_print( "on_save_restored resetting timer for after cargo bay" );
		
		level notify( "reload_timer_reset" );
		
		duration = level.firefight_countdown_duration * 0.8;
		start_countdown_timer( duration );
	}
}
