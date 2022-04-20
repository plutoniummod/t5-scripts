/*
//-- Level: Underwater Base
//-- Level Designer: Gavin Goslin
//-- Scripter: Alfeche/Vento
*/
#include maps\_utility;
#include common_scripts\utility; 
#include maps\_anim;
#include maps\_utility_code;
#include maps\underwaterbase_util;
#include maps\_audio;
#include maps\_music;

// gets run through at start of level
init_flags()
{
	flag_init( "flood_swimming" );
	
	maps\underwaterbase_upshaft::init_flags();
}

objectives( starting_obj_num )
{
	level.curr_obj_num = starting_obj_num;
	
// 	Objective_Add( level.curr_obj_num, "active", "Get to the Broadcast Center" );
	Objective_Position( level.curr_obj_num, struct_origin("broadcast_center_1_objective") );
	Objective_Set3D( level.curr_obj_num, true );
	trigger_wait( "trig_bigflood_stairs" );
	
	Objective_Position( level.curr_obj_num, struct_origin("broadcast_center_2_objective") );
	trigger_wait( "trig_start_flood" );
	
	Objective_Set3D( level.curr_obj_num, false );
	flag_wait( "flood_swimming" );
	
	Objective_Set3D( level.curr_obj_num, true );
	Objective_Position( level.curr_obj_num, struct_origin("broadcast_center_3_objective") );	
	trigger_wait( "trig_flood_exit" );
	
	Objective_Position( level.curr_obj_num, struct_origin("broadcast_center_3b_objective") );	
	trigger_wait( "trig_corridor2_5" );

	Objective_Position( level.curr_obj_num, struct_origin("broadcast_center_4_objective") );	
	trigger_wait( "trig_upshaft" );

//	level.curr_obj_num++;
	maps\underwaterbase_upshaft::objectives( level.curr_obj_num );
}


// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	Objective_Add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_FIND_DRAGOVICH" );
	level thread objectives(0);
	
	// open the sliding door and the hatch
	thread maps\underwaterbase_util::door_open( "subpen_exit_door", 170, 0.05 );
	thread maps\underwaterbase_util::door_open( "subpen_west_door", 170, 0.05 );
	thread maps\underwaterbase_util::door_open( "subpen_east_door", 170, 0.05 );
	thread maps\underwaterbase_enterbase::open_sliding_doors( 0.05 );

	// spawn underwater Hudson
	level.heroes[ "weaver" ] Delete();
	level.heroes[ "hudson" ] Delete();
	maps\underwaterbase::setup_hero( "ai_enterbase_hudson", "Hudson", "hudson" );
	level.heroes[ "hudson" ] set_actor_start("ss_bigflood_hudson_start", "r" );

	//
	player_to_struct( "bigflood_start" );
	
	maps\createart\underwaterbase_art::set_underwater_base_fog();
	
  	// set water volume to moonpool height
	maps\underwaterbase_util::set_water_height( "water_volume_moonpool_height" );
	
	level thread maps\underwaterbase::base_impacts( "occassional" );
	level thread maps\underwaterbase_enterbase::swimming_monitor();

	// misc setup necessary to make the skipto work goes here
	run();
}

run()
{
	OnSaveRestored_Callback( ::save_restore_gravity );
	// save game
	autosave_by_name( "underwaterbase_after_subs" );	
	wait( 0.05 );

	corridor_fighting();
	flood_event();
	corridor2_fighting();
	cleanup();

	maps\underwaterbase_upshaft::run();
}


//
//	Between sub pens and flood room
corridor_fighting()
{
//	trigger_wait( "trig_bigflood_stairs" );

	// guy running downstairs
	simple_spawn( "bigflood_enemy1", ::indoor_rusher);
	trigger_wait( "trig_bigflood_stairs2" );

	// 2 guys coming to the top of stairs
	simple_spawn( "bigflood_enemy2", ::indoor_forcegoal );

	// Warp Hudson if he's too far
	player = get_players()[0];
	if ( Distance( level.heroes[ "hudson" ].origin, player.origin ) > 300 )
	{
		level.heroes[ "hudson" ] set_actor_start("ss_bigflood_hudson_start", "r" );
	}

	trigger_wait( "trig_bigflood_corridor" );

	// Corridor guys
	simple_spawn( "bigflood_enemy3", ::indoor_forcegoal );
}


//
//	A torpedo hits the base, causing water to gush out and slam the player into the wall.
flood_event()
{
	trigger_wait( "trig_bigflood_room" );

	// Flood room guys
	flood_room_guys = simple_spawn( "ai_floodroom", ::indoor_forcegoal );
	trigger_wait( "trig_start_flood" );

	player = get_players()[0];

	// Room tilt
	if ( !IsDefined( level.seaent ) )
	{
	    level.seaent= spawn( "script_origin", player.origin );
	}
    player PlayerSetGroundReferenceEnt( level.seaent );

	// This controls how longs things stay floating
	level.old_maxfloattime = GetDvarInt( "phys_maxFloatTime" );
	SetSavedDvar( "phys_maxFloatTime", 80000 );

	level thread maps\underwaterbase::set_base_impact_state( "wait", 0 );	// pause shakes

	player FreezeControls( true );
	player EnableInvulnerability();
	player DisableWeapons();
	player hide_swimming_arms();

	level.seaent RotateTo( (0, 0, 30), 0.5, 0.0, 0.2 );	// rotate view

	// 2nd local torpedo strike - start water burst
	Earthquake( 0.7, 0.7, player.origin, 500 );
	player PlayRumbleOnEntity( "artillery_rumble" );
	playsoundatposition( "evt_chamber2_explo", (0,0,0) );
	clientnotify( "light_torp02" );
	clientnotify( "exsnpu" );
	playsoundatposition( "evt_uwb_explosion", (0,0,0) );
	playsoundatposition( "evt_bigflood_water_incoming", (0,0,0) );
	
	//TUEY set music to MUS_STINGER_EXPLOSION
	setmusicstate ("MUS_STINGER_EXPLOSION");

	level notify( "door_burst_start" );	// door burst open
	Exploder( 604 );		// Explosion

	// Kill all near flood room explosion
	spot = GetStruct( "water_volume_start_flood_height", "targetname" );
	for ( i=0; i<flood_room_guys.size; i++ )
	{
		if ( IsAlive(flood_room_guys[i]) && Distance2D( flood_room_guys[i].origin, spot.origin ) < 300 )
		{
			flood_room_guys[i] DoDamage( flood_room_guys[i].health, flood_room_guys[i].origin );
		}
	}
	wait( 0.5 );

	Exploder( 606 );	// Flood water
    clientnotify( "upfxsn" );
	level.seaent RotateTo( (0, 0, 0), 1.0, 0.45 );	// return camera to normal
	wait( 1.0 );
    
	// Close flood door
	thread maps\underwaterbase_util::door_open( "flood_hall_door", 165, 0.05 );

	player PlayRumbleOnEntity( "artillery_rumble" );
	level maps\underwaterbase_anim::big_flood();

	linker = Spawn( "script_origin", player.origin );

	player PlayerLinkTo( linker );
	player FreezeControls( false );

	level notify( "exp_flood" );		// activate exploder flood 
	wait_network_frame();
	level notify( "exp_chamber2" );		// activate exploder 2nd hallway

	array_delete( GetEntArray( "flood_rail_clip", "targetname" ) );
	player show_swimming_arms();

	// wait for Hudson to point before regaining movement
	wait( 5.0 );

	flag_set( "flood_swimming" );
	player Unlink();
	player DisableInvulnerability();
// 	player EnableWeapons();
   	player SetLowReady(false);
	player SetClientDvar( "player_waterSpeedScale", 1.0 );

	// Play Hudson line when we get out
	trigger_wait( "trig_flood_exit" );

	level thread hudson_flood_dialog();

	// Restore dvars
	SetSavedDvar( "phys_maxFloatTime", level.old_maxfloattime );
	SetPhysicsGravityDir( (0,0,-800) );
//	player SetClientDvar( "phys_gravity", level.old_gravity );

    player PlayerSetGroundReferenceEnt( undefined );

	// Push objects into physics
	phys_structs = GetStructArray( "ss_corridor2_phys", "targetname" );
	for ( i=0; i<phys_structs.size; i++ )
	{
		PhysicsJolt( phys_structs[i].origin, 150, 150, (0, 0, 0.1) );
	}

	// save game
	autosave_by_name( "underwaterbase_enterbase" );	
	wait( 0.05 );
}


//
//	Initiated by a notetrack of the player hitting the wall
//	The player hits his head on the wall, black out and start flooding everything
start_flood( player_body )
{
	player = get_players()[0];
	player PlayRumbleOnEntity( "artillery_rumble" );
	maps\underwaterbase_util::fade_out( 0.2, "black" );

	// Set the underwater vision set
	player clientnotify( "uwb_vs" );

	// This controls buoyancy
	// turn on buoyancy here
	SetPhysicsGravityDir( (0,0,50) );
	SetSavedDvar( "phys_buoyancy", 1 );
	SetSavedDvar( "phys_ragdoll_buoyancy", 1 );

// 	level.old_gravity = GetDvarInt( "phys_gravity" );
//  	player SetClientDvar( "phys_gravity", -100 );
//  	player SetClientDvar( "phys_gravity_dir", (0,0,-1) );


	// spawn extra bodies
	simple_spawn( "ai_floodroom_bodies", ::indoor_forcegoal );

	// 
	// Kill all AI again
	ai = GetAIArray( "axis", "allies" );
	for ( i=0; i<ai.size; i++ )
	{
		if ( ai[i] != level.heroes[ "hudson" ] )
		{
			ai[i] DoDamage( ai[i].health, ai[i].origin );
		}
	}
	wait( 0.5 );	// make sure they're dead

	player PlayRumbleLoopOnEntity( "damage_light" );

	// Make things float if they're at rest
	flood_pulsers = GetStructArray( "ss_flood_pulsers", "targetname" );
	for ( i=0; i<flood_pulsers.size; i++ )
	{
//		PhysicsExplosionSphere( flood_pulsers[i].origin, flood_pulsers[i].radius, flood_pulsers[i].radius, RandomFloatRange( 0.1, 1.6 ), 0, 0 );
		PhysicsJolt( flood_pulsers[i].origin, flood_pulsers[i].radius, flood_pulsers[i].radius, (0,0,RandomFloatRange(0.15, 0.25)) );
//		PhysicsExplosionSphere( flood_pulsers[i].origin, flood_pulsers[i].radius, flood_pulsers[i].radius, RandomFloatRange( 0.01, 0.04 ), 0, 0 );
//		wait( 0.05 );
	}
	wait( 0.7 );	// pause to let anim wonkiness to go away

  	// set water volume to moonpool height
	maps\underwaterbase_util::set_water_height( "water_volume_flood_height", true );

	wait( 1 );
	player StopRumble( "damage_light" );

	player ShellShock( "default", 7.0 ); 
	thread maps\underwaterbase_anim::big_flood_hudson();
	thread maps\underwaterbase_util::fade_in( 3.0, "black" );

	level thread maps\underwaterbase::set_base_impact_state( "medium" );

	// Bob the water 
	while ( !flag( "dry_room_reached" ) )
	{
		time = RandomFloatRange( 0.4, 2.0 );
	 	level.water_volume MoveZ( 4, time);
		wait( time );

		time = RandomFloatRange( 0.4, 2.0 );
	 	level.water_volume MoveZ( -4, time);
		wait( time );
	}
}


//
//	Corridor after the flood
corridor2_fighting()
{
	trigger_wait( "trig_corridor2" );

	player = get_players()[0];
	player SetWaterDrops( 100 );

	ai = simple_spawn( "ai_corridor2", ::indoor_rusher );

	// corridor 2.5  (because the next corridor has 3_5)
	trigger_wait( "trig_corridor2_5" );

	ai = simple_spawn( "ai_corridor2_5", ::indoor_forcegoal );

	trigger_wait( "trig_upshaft" );

	level notify( "exp_chamber3" );		// activate exploder hallway 3
	wait( 0.05 );						// give time between activations

	level notify( "exp_ladder" );		// activate exploder ladder shaft
	clientnotify( "upfxsn" );

	level.heroes["hudson"] anim_single( level.heroes["hudson"], "up_ladder" );
}


//
//
cleanup()
{
	OnSaveRestored_CallbackRemove( ::save_restore_gravity );
}


//
//	Wait until both player and hudson are out
hudson_flood_dialog()
{
	level.heroes["hudson"] ent_flag_wait( "flood_swim_done" );

	level.heroes["hudson"] anim_single( level.heroes["hudson"], "find_dragovich" );
}


//
//	Callback for gravity on save restore
save_restore_gravity()
{
	SetPhysicsGravityDir( (0,0,-800) );
}