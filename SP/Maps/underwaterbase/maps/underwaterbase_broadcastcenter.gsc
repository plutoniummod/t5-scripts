/*
//-- Level: Underwater Base
//-- Level Designer: Gavin Goslin
//-- Scripter: Alfeche/Vento
*/
#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\underwaterbase_util;
#include maps\_anim;


// gets run through at start of level
init_flags()
{
	flag_init( "broadcast_center_located" );	
	flag_init( "player_reached_dragovich" );

	maps\underwaterbase_deactivatecode::init_flags();
}


//
//	Objectives for this section
objectives( starting_obj_num )
{
	level.curr_obj_num = starting_obj_num;

 	Objective_Position( level.curr_obj_num, struct_origin("locate_broadcast_center_objective_0") );
	trigger_wait( "trig_top_of_ladder" );

	Objective_Position( level.curr_obj_num, struct_origin("locate_broadcast_center_objective_1") );
	trigger_wait( "trig_enter_broadcast" );

	Objective_Position( level.curr_obj_num, struct_origin("locate_broadcast_center_objective_2") );
	trigger_wait( "trig_broadcast_upper" );

	Objective_Set3D( level.curr_obj_num, false );
	level thread maps\underwaterbase_deactivatecode::objectives( level.curr_obj_num );
}


//
// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	level.heroes[ "weaver" ] Delete();

	player = get_players()[0];
	player SetWaterDrops( 100 );

	Objective_Add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_FIND_DRAGOVICH" );
	Objective_Set3D( level.curr_obj_num, true );
	level thread objectives(0);

	// spawn underwater Hudson
	level.heroes[ "hudson" ] set_actor_start("ss_broadcastcenter_hudson_start", "r" );
		
	player_to_struct( "broadcastcenter_start" );
	
	maps\createart\underwaterbase_art::set_underwater_base_fog();
	VisionSetNaked( "UWB_Corridor_02", 0.05 );

	// Hatch door model
	hatch = GetEnt( "hatch_door", "targetname" );
	hatch RotatePitch( -90, 0.05 );

	level thread maps\underwaterbase::base_impacts( "medium" );

	level notify( "exp_chamber3" );		// top of ladder
	wait( 0.05 );
	level notify( "exp_chamber3_5" );	// top of ladder
	wait( 0.05 );
	level notify( "exp_control" );		// top of ladder

	// misc setup necessary to make the skipto work goes here
	run();
}


//
run()
{
	init_broadcastcenter();
	
	// save game
	autosave_by_name( "underwaterbase" );
	wait( 0.05 );

	broadcast_center();
	
	cleanup();
	maps\underwaterbase_deactivatecode::run();
}


//
//	Any setup for this event
init_broadcastcenter()
{
	maps\underwaterbase_util::set_water_height( "water_volume_broadcast_height", true );
	temp_water = GetEnt( "water_broadcast_corridor", "targetname" );
	
  	SetWaterBrush( temp_water );

	// increase cull radius so we can see the water
	player = get_players()[0];
	player SetClientDvar("cg_aggressiveCullRadius", 2000);

	// Push objects into physics
	phys_structs = GetStructArray( "ss_corridor3_phys", "targetname" );
	for ( i=0; i<phys_structs.size; i++ )
	{
		PhysicsJolt( phys_structs[i].origin, 150, 150, (0, 0, 0.01) );
	}
}


//
//
cleanup()
{
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

broadcast_center()
{
// 	teleport_node = GetNode( "teleport_node", "targetname" );
// 	level.heroes[ "hudson" ].goalradius = 32;
// 	level.heroes[ "hudson" ] SetGoalNode( teleport_node );
	
	trigger_wait( "trig_corridor_3_5" );

	level thread broadcast_destruction();

	ai = simple_spawn( "ai_corridor_3_5", ::indoor_forcegoal );
	level notify( "exp_control" );			// activate exploder broadcast room
	clientnotify( "upfxsn" );

	trigger_wait( "trig_enter_broadcast" );

	// Turn off for framerate...
	SetSavedDvar( "phys_buoyancy", 1 );
	SetSavedDvar( "phys_ragdoll_buoyancy", 1 );

	ai = simple_spawn( "ai_broadcast_room_1", ::indoor_forcegoal );
	ai = simple_spawn( "ai_broadcast_room_1_rush", ::indoor_rusher );
	ai = simple_spawn( "ai_broadcast_engineer" );
	ai thread maps\underwaterbase_anim::frantic_engineers();
	
	flag_set( "broadcast_center_located" );
	
	trigger_wait( "trig_broadcast_mid" );

	ai = simple_spawn( "ai_broadcast_room_2", ::indoor_forcegoal );
	level thread broadcast_dialog();

	trigger_wait( "trig_broadcast_upper" );

	// save game
	autosave_by_name( "underwaterbase_broadcast_mid" );
	wait( 0.05 );

	ai = simple_spawn( "ai_broadcast_room_3", ::indoor_forcegoal );

}


//
//	Destruction - cause damage when the player is near during a base impact
broadcast_destruction()
{
	level endon( "player_reached_dragovich" );

	player = get_players()[0];
	dest = GetStructArray( "ss_broadcast_destroyer", "targetname" );
	while (1)
	{
		level waittill( "base_impact" );

		for ( i=0; i<dest.size; i++ )
		{
			if ( !IsDefined( dest[i].detonated ) )
			{
				dist_2dsq = Distance2DSquared( dest[i].origin, player.origin );
				height_diff = dest[i].origin[2] - player.origin[2];

				radius = 300;
				if ( IsDefined( dest[i].radius ) )
				{
					radius = dest[i].radius;
				}

				// 250000 = 500 squared
				if ( ( dist_2dsq < 250000 ) &&	
					 ( Abs( height_diff  ) < 150 ) )
				{
					dest[i].detonated = 1;
					PhysicsExplosionSphere( dest[i].origin, radius, radius, 0.5, 1000, 1000 );
				}
			}
		}
	}
}


//
//	
broadcast_dialog()
{
	trigger_wait( "trig_broadcast_upper" );

	level.heroes["hudson"] anim_single( level.heroes["hudson"], "stop_broadcast" );
}