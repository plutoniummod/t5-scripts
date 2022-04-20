/*
//-- Level: Underwater Base
//-- Level Designer: Gavin Goslin
//-- Scripter: Alfeche/Vento
*/

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\underwaterbase_util;
#include maps\_music;

//
// gets run through at start of level
init_flags()
{
	flag_init( "reached_escape_corridor" );	

	maps\underwaterbase_thesurface::init_flags();
}


//
//
objectives( starting_obj_num )
{
	level.curr_obj_num = starting_obj_num;
	
	flag_wait( "dragovich_fight_end" );	

	Objective_Add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_ESCAPE" );
	Objective_Position( level.curr_obj_num, level.heroes[ "hudson" ] );
	Objective_Set3D( level.curr_obj_num, true, "default", &"UNDERWATERBASE_OBJ_FOLLOW" );

	flag_wait( "reached_escape_corridor" );
	Objective_State( level.curr_obj_num, "done" );
	level.curr_obj_num++;

	maps\underwaterbase_thesurface::objectives( level.curr_obj_num );
}


// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	player = get_players()[0];
	player DisableWeapons();
	player SetWaterDrops( 100 );

	level thread objectives(0);
	
	player_to_struct( "escape_start" );

	// spawn underwater Hudson
	level.heroes[ "weaver" ] Delete();

	maps\createart\underwaterbase_art::set_underwater_base_fog();

  	// fill water
	maps\underwaterbase_util::set_water_height( "water_volume_escape_height", true );

	flag_set( "dragovich_fight_end" );	

	VisionSetNaked( "UWB_Escape", 2.0 );

	level notify( "exp_control" );		// broadcast
	wait( 0.05 );

	level notify( "exp_escape" );	// escape hall

	// misc setup necessary to make the skipto work goes here
	run();
}


//
//
run()
{
	init();
	
	head_down_escape_corridor();
	
	cleanup();
	maps\underwaterbase_thesurface::run();
}


//
//
init()
{
   	// open up escape route
	blocker = GetEnt("escape_exit_door", "targetname");
	blocker RotateYaw(-115, 0.05);
	blocker waittill( "rotatedone" );	
	blocker ConnectPaths();
	
	player = get_players()[0];
	// Reuse this baby
	if ( !IsDefined( level.seaent ) )
	{
	    level.seaent = spawn( "script_origin", player.origin );
	}
    player PlayerSetGroundReferenceEnt( level.seaent );
}


//
//
cleanup()
{
	level notify( "stop_base_impacts" );

    p = get_players()[0];
    p PlayerSetGroundReferenceEnt( undefined );
    setPhysicsGravityDir( ( 0, 0, -800 ) );
	p SetClientDvar("cg_aggressiveCullRadius", 500);	// return to aggressive cull radius

	// Delete all destructibles not in the surface sequence
	destro = GetEntArray( "destructible", "targetname" );
	for (i=0; i<destro.size; i++)
	{
		if ( destro[i].origin[1] > 15000 )
		{
			destro[i] Delete();
		}
	}

	// turn off the water plane
	maps\underwaterbase_util::set_water_height( "water_volume_broadcast_height", false );
}


//
//
head_down_escape_corridor()
{
	// save game
	autosave_by_name( "underwaterbase_escape" );
	wait( 0.05 );

	player = get_players()[0];
	player SetMoveSpeedScale( 0.55 );
	player AllowJump( false );
	player AllowSprint( false );
  	player DisableWeapons();

	// Spawn escape Hudson
	level.heroes[ "hudson" ] Delete();	
	maps\underwaterbase::setup_hero( "ai_escape_hudson", "Hudson", "hudson" );
	level.heroes[ "hudson" ] maps\underwaterbase_util::set_actor_start( "ss_escape_hudson_start" );
	
	fade_time = 2.0;
	level maps\underwaterbase_anim::escape( fade_time );

	trig = GetEnt( "escape_corridor_reached", "targetname" );
	if ( !player IsTouching( trig ) )
	{
		// kill player for not following Hudson
		PlayFX( level._effect["fx_uwb_explosion_console"], player.origin );
		earthquake( 2.0, 1, player.origin,  500 );
		player DisableInvulnerability();
		player PlayRumbleOnEntity( "artillery_rumble" );
		player DoDamage( 10000, player.origin, trig );
		playsoundatposition( "evt_chamber1_explo", (0,0,0) );
		playsoundatposition( "evt_uwb_explosion", (0,0,0) );
	}

	// Hudson escape
	goalnode = GetNode( "hudson_escape_node1", "targetname" );
	level.heroes[ "hudson" ] SetGoalNode( goalnode );

	maps\underwaterbase_util::fade_out( fade_time, "white" );
	player SetWaterDrops( 0 );

	flag_set( "reached_escape_corridor" );
	level notify("stop_random_earthquakes");
	player SetMoveSpeedScale( 1.0 );

	//TUEY set music to SWIM_OUT
	setmusicstate ("SWIM_OUT");

	wait(2);	// dramatic pause
}


//#################################################################################
//	NOTE: This functionality is now encompassed in underwaterbase::base_impacts
//#################################################################################
// random_earthquakes()
// {
// 	level endon("stop_random_earthquakes");	
// 	player = get_players()[0];
// 	
// 	while(1)
// 	{
// 		earthquake(RandomFloat(1.0), RandomIntRange(1,3), player.origin, 500);
// 		playsoundatposition( "evt_uwb_explosion", (0,0,0) );
// 	    clientnotify( "exsnp" );
// 		player PlayRumbleOnEntity( "damage_heavy" );	
// 		wait(RandomIntRange(5,10));
// 	}
// }


//
//	"Star Trek" rockin the base
//	self = ground reference entity
rock_the_base()
{
	level endon( "reached_escape_corridor" );

	self thread base_gravity();

	wait( 5 );

	// Earthquake
	player = get_players()[0];
	Earthquake( 1.0, 1.0, player.origin, 500 );
	playsoundatposition( "evt_uwb_explosion", (0,0,0) );
	clientnotify( "exsnp" );
	player PlayRumbleOnEntity( "artillery_rumble" );

	self RotateTo( (10, 0, 30), 0.5, 0.0, 0.2 );
    self waittill( "rotatedone" );
	wait( 0.5 );

    self RotateTo( (0, 0, 0), 1.5, 0.45, 0.25 );
    self waittill( "rotatedone" );

	level notify( "hallway1_start" );	// Pipe FX anim
	wait( 0.5 );
	level notify( "hallway2_start" );	// Pipe FX anim
	wait( 2.5 );

	// Earthquake
	Earthquake( 1.0, 1.0, player.origin, 500 );
	playsoundatposition( "evt_uwb_explosion", (0,0,0) );
	clientnotify( "exsnp" );
	player PlayRumbleOnEntity( "artillery_rumble" );

	self RotateTo( (15, 0, -30), 0.5, 0.0, 0.2 );
    self waittill( "rotatedone" );
	wait( 0.5 );

    self RotateTo( (0, 0, 0), 1.5, 0.45, 0.15 );
    self waittill( "rotatedone" );
}


//	"Star Trek" rockin the base
//	self = ground reference entity
base_gravity()
{
	level endon( "reached_escape_corridor" );
		
	while(1)
	{
		wait .05;
		vec1 = vector_multiply( anglestoup( self.angles ), -800 );
		// magnify the x and y components
		vec2 = vector_multiply( ( vec1[0], vec1[1], 0 ), 10 );
		vec = vec1 + vec2;
		setPhysicsGravityDir( vec );
	}
}