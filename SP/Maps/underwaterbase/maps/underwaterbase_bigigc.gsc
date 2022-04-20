/*
//-- Level: Underwater Base
//-- Level Designer: Gavin Goslin
//-- Scripter: Alfeche/Vento
*/

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\underwaterbase_util;

// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	Objective_Add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_HELP_WEAVER" );
	level thread objectives(0);
	
	// HACK! Turn off water
	flag_set("turn_off_outside_ship_water");
	level thread maps\underwaterbase_rendezvous::turn_off_water();
	setup_umbilical_water();

	flag_set( "deck_cleanup" );

	maps\createart\underwaterbase_art::set_ship_interior_fog_and_vision();

	player_to_struct( "ss_bigigc_player_start" );

	level.heroes[ "weaver" ] delete();	// delete the one from the start of the level.
	level.heroes[ "hudson" ] set_actor_start( "ss_e3_hudson_start" );
	
	// turn on battle chatter
	battlechatter_on("allies");
	battlechatter_on("axis");

	// misc setup necessary to make the skipto work goes here
	run();
}


//
run()
{
	init();

	thread umbilical_cord();
	thread water_fx();

	room_spawning();

	rendezvous_with_weaver();

	cleanup();
	maps\underwaterbase_divetobase::run();
}


//
//
init()
{
	if(isdefined(level.huey))
	{
		level.huey notify("end_player_heli");
		wait(1);
		if( IsDefined( level.huey.turret_ai_array ) )
		{
			level.huey maps\_vehicle_turret_ai::disable_turret(0);
			level.huey maps\_vehicle_turret_ai::disable_turret(1);
		}
	}

	// Cleanup previous allies
	ai = GetAIArray( "allies" );
	for ( i=0; i<ai.size; i++ )
	{
		if ( ai[i] != level.heroes[ "hudson" ] )
		{
			ai[i] Delete();
		}
	}

	// Allies
	level.heroes[ "hudson" ] set_force_color( "r" );
	level.heroes[ "hudson" ].script_accuracy = 5;

	level.heroes[ "weaver" ] = simple_spawn_single("ai_rendezvous_weaver");
	level.heroes[ "weaver" ].animname = "weaver";
	level.heroes[ "weaver" ].name = "Weaver";
	level.heroes[ "weaver" ] make_hero();
	level.heroes[ "weaver" ] enable_cqbsprint();

	// spawn Weaver's buddies
	level.allies = simple_spawn( "ai_rendezvous_ally" );
	for ( i=0; i<level.allies.size; i++ )
	{
		level.allies[i] make_hero();
		level.allies[i].animname = "ally"+i;
		level.allies[i] enable_cqbwalk();
		level.allies[i] disable_ai_color(); 
	}

	// Fix for restart bug
	OnSaveRestored_Callback( maps\underwaterbase_util::setup_umbilical_water );
}


// gets run through at start of level
init_flags()
{
	flag_init( "numbers_scene_prep" );
	flag_init( "allies_out" );			// set after giving the allies time to vacate the room
	flag_init( "numbers_scene_start" );
	flag_init( "numbers_scene_done" );
	maps\underwaterbase_divetobase::init_flags();
}


//
//
cleanup()
{
	// Kill all AI, we'll respawn new ones 
	ai = GetAIArray( "axis", "allies" );
	for ( i=0; i<ai.size; i++ )
	{
		ai[i] Delete();
	}

	// Delete all destructibles in the ship
	destro = GetEntArray( "destructible", "targetname" );
	for (i=0; i<destro.size; i++)
	{
		if ( destro[i].origin[0] < 15000 && destro[i].origin[1] > -10000 )
		{
			destro[i] Delete();
		}
	}

	// Delete the umbilical cord because it had NoCull set on it
	wires1 = GetEnt( "umbilical_room_wires_1", "targetname" );
	wires2 = GetEnt( "umbilical_room_wires_2", "targetname" );
	wires1 Delete();
	wires2 Delete();
}


//
//
objectives( starting_obj_num )
{
	level.curr_obj_num = starting_obj_num;

	// Kill them all

	// Now add a breadcrumb, but also look out for the player killing all enemies.
	pos = GetStruct( "obj_umbilical1", "targetname" );
	Objective_String( level.curr_obj_num, &"UNDERWATERBASE_OBJ_HELP_WEAVER" );
	Objective_Position( level.curr_obj_num, pos.origin );
	Objective_Set3D( level.curr_obj_num, true, "default" );
	trig = Spawn( "trigger_radius", pos.origin, 0, 200, 60 );	// flags, radius, height
	waittill_any_ents( trig, "trigger", level, "numbers_scene_prep" );

	trig Delete();

	// Secondary position
	pos = GetStruct( "obj_umbilical_igc", "targetname" );
 	Objective_Position( level.curr_obj_num, pos.origin );
	if ( !flag( "numbers_scene_prep" ) )
	{
	 	Objective_Set3D( level.curr_obj_num, true, "green", &"UNDERWATERBASE_OBJ_ASSIST" );
	}
	flag_wait( "numbers_scene_prep" );

	Objective_String( level.curr_obj_num, &"UNDERWATERBASE_OBJ_RENDEZVOUS" );
 	Objective_Set3D( level.curr_obj_num, true, "default" );
	flag_wait( "numbers_scene_start" );

  	Objective_State( level.curr_obj_num, "done" );
	flag_wait( "numbers_scene_done" );

	maps\underwaterbase_divetobase::objectives( level.curr_obj_num );
}


//
//	Handles movement of the umbilical cable pieces
umbilical_cord()
{
	level endon( "wires_slack_start" );

	wires[ 0 ] = GetEnt( "umbilical_room_wires_1", "targetname" );
	wires[ 1 ] = GetEnt( "umbilical_room_wires_2", "targetname" );
	wires[ 0 ] SetForceNoCull();
	wires[ 1 ] SetForceNoCull();

	segment_height = 719;
	segment_time = 15;
	top_origin = wires[0].origin + (0,0,segment_height );

	wires[0] MoveZ( -1*segment_height, segment_time );
	curr_wire = 0;

	// Make the pipes loop their movement
	while (1)
	{
		// Go to the next pipe
		curr_wire++;
		if ( curr_wire >= wires.size )
		{
			curr_wire = 0;
		}

		wires[ curr_wire ] Hide();
		wires[ curr_wire ].origin = top_origin;
		wires[ curr_wire ] MoveZ( -2*segment_height, segment_time*2 );
		wait( 0.05 );
		wires[ curr_wire ] Show();	// 
		wait( segment_time - 0.05 );
	}
}


spawn_script_model_fx( fx, origin, angles )
{
	model = Spawn( "script_model", origin );
	model SetModel( "tag_origin" );
	model.angles = angles;
	PlayFXOnTag( level._effect[ fx ], model, "tag_origin" );

	return model;
}


//
//	Some late water fx for Dale
water_fx()
{
	left_pipe1	= spawn_script_model_fx( "fx_ship_pipe_gush_sm",		(896.559, -202.213, -505),	(40, 90, 0) );
	left_pipe2	= spawn_script_model_fx( "fx_ship_pipe_gush_splash", (895.73, -173.636, -596),		(270, 0, -90) );
	right_pipe1 = spawn_script_model_fx( "fx_ship_pipe_gush_sm",	(895.572, 204.865, -505.282),	(42, 274, 2) );
	right_pipe2 = spawn_script_model_fx( "fx_ship_pipe_gush_splash", (895.929, 174.811, -596),		(270, 0, 90) );
//	churn		= spawn_script_model_fx( "fx_umbilical_water_churn", (928.93, 7.05617, -595),		(270, 0, 0) );
	flag_wait( "numbers_scene_done" );
	wait( 5 );	// enough time for fade out.

	left_pipe1	Delete();
	left_pipe2	Delete();
	right_pipe1 Delete();
	right_pipe2 Delete();
//	churn		Delete();
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
room_spawning()
{
	trigger_wait( "trig_umbilical_start" );

	spawn_manager_enable( "sm_umbilical" );	// spawn manager for the SE room spawner
	simple_spawn( "ai_umbilical_start", ::enable_cqbsprint );

	trig_high	= GetEnt( "trig_umbilical_high", "targetname" );
	trig_low	= GetEnt( "trig_umbilical_low", "targetname" );
	trig_high	thread set_hudson_color( "red" );
	trig_low	thread set_hudson_color( "cyan" );
	waittill_any_ents( trig_high, "trigger", trig_low, "trigger" );

	simple_spawn( "ai_umbilical_high", ::enable_cqbsprint );
	simple_spawn( "ai_umbilical_low", ::enable_cqbsprint );

	trig_high	= GetEnt( "trig_umbilical_high2", "targetname" );
	trig_low	= GetEnt( "trig_umbilical_low2", "targetname" );
	trig_high	thread split_spawn( "ai_umbilical_mid_high" );
	trig_low	thread split_spawn( "ai_umbilical_mid_low" );
	waittill_any_ents( trig_high, "trigger", trig_low, "trigger" );

	trigger_wait( "trig_umbilical_mid" );

	simple_spawn( "ai_umbilical_mid", ::enable_cqbsprint );
	waittill_ai_group_ai_count( "umbilical_room", 6 );

	thread allies_move_up();

	waittill_ai_group_ai_count( "umbilical_room", 0 );
	spawn_manager_disable( "sm_umbilical" );	// spawn manager for the SE room spawner

	// make sure everyone's dead
	ai = GetAIArray( "axis" );
	for ( i=0; i<ai.size; i++ )
	{
		ai[i] DoDamage( ai[i].health, ai[i].origin );
	}
}


//
//	Make initially Hudson choose a path opposite of the player
set_hudson_color( color )
{
	level endon( "hudson_path_chosen" );

	self waittill( "trigger" );

	level.heroes[ "hudson" ] set_force_color( color );
	level notify( "hudson_path_chosen" );
}


//
//	Split up spawning for high and low path
split_spawn( spawner_name )
{
	level endon( "split_spawned" );

	self waittill( "trigger" );

	simple_spawn( spawner_name );
	level notify( "split_spawned" );
}


// Get the allies out of the box
allies_move_up()
{
	for ( i=0; i<level.allies.size; i++ )
	{
 		wait_node = GetNode( "n_numbers_end_" + (i+1), "targetname" );
		if ( IsDefined( wait_node ) )
		{
			level.allies[i] SetGoalNode( wait_node );
			level.allies[i].script_accuracy = 10;
// 			level.allies[i] waittill( "goal" );
		}
		wait( 1.0 );
	}
	wait( 1.0 );
	flag_set( "allies_out" );
}


//
//	Setup the meeting
rendezvous_with_weaver()
{
	player = get_players()[0];
   	player SetLowReady(true);	   		

	// numbers scene
	thread maps\underwaterbase_anim::rendezvous();
	flag_wait( "numbers_scene_done" );

    clientnotify( "trans1" );

	maps\underwaterbase_util::fade_out( 3, "black" );

	// add sounds of putting on mask and dive gear and splash
	wait(3);

	player SetClientDvar( "compass", "0" );	// disable crosshairs HUD
	thread maps\underwaterbase_util::divemask_equip();
   	player SetLowReady(false);

	// save game
	autosave_by_name( "underwaterbase" );
	
	wait(2);
}