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

// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{	
	Objective_Add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_FIND_DRAGOVICH" );
	level thread objectives(0);
	
	// spawn underwater Hudson
	level.heroes[ "weaver" ] Delete();
	level.heroes[ "hudson" ] Delete();
	maps\underwaterbase::setup_hero( "ai_enterbase_hudson", "Hudson", "hudson" );
	level.heroes[ "hudson" ] set_actor_start("ss_upshaft_hudson_start", "r");

	player_to_struct( "upshaft_start" );
	
	// misc setup necessary to make the skipto work goes here

	maps\createart\underwaterbase_art::set_underwater_base_fog();
	
	player = get_player();

	// close bulkhead
// 	door_blocker = GetEnt("bulkhead_door_big_flood","targetname");
// 	door_blocker rotateyaw( -90, 1.0 );
// 	door_blocker waittill( "rotatedone" );	
// 	door_blocker disconnectpaths();
			
	// player can now drown in water
	level.disable_drowning = false;	
	player clientnotify("_enable_drowning");
	
	maps\underwaterbase_util::set_water_height( "water_volume_moonpool_height" );

	//disable the triggers that used to move Hudson in the bigflood event
  	trigger_off( "allies_go_to_r13", "targetname" );		
    trigger_off( "close_bulkhead_on_player", "targetname" ); 	
    trigger_off( "objective_to_vent", "targetname" ); 	
  	
	level thread maps\underwaterbase::base_impacts( "medium" );

	run();
}

run()
{
	upshaft_init();
	
	up_the_vertical_shaft();

	cleanup();
	maps\underwaterbase_broadcastcenter::run();
}

upshaft_init()
{
	blocker = getent("vertical_shaft_hatch", "targetname");
	blocker NotSolid();
}


// gets run through at start of level
init_flags()
{
	flag_init( "dry_room_reached" );
	flag_init( "hudson_climbed_ladder" );

	maps\underwaterbase_broadcastcenter::init_flags();
}

cleanup()
{
	player = get_player();
	
	// turn off drowning
	player clientnotify("_disable_drowning");	
	level.disable_drowning = true;	
	
}

objectives( starting_obj_num )
{
	level.curr_obj_num = starting_obj_num;
	
	Objective_Position( level.curr_obj_num, struct_origin("in_dry_room_objective") );
 	flag_wait( "dry_room_reached" );

	maps\underwaterbase_broadcastcenter::objectives( level.curr_obj_num );
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

up_the_vertical_shaft()
{
	level.heroes[ "hudson" ] thread hudson_climb_up();

	trigger_wait( "trig_top_of_ladder" );

	flag_set( "dry_room_reached" );	

	level.heroes[ "hudson" ] thread hudson_catch_up();

	level notify( "exp_chamber3_5" );		// activate exploder hall before broadcast
	clientnotify( "upfxsn" );

	level close_hatch();
}


//
//	Get Hudson up the ladder
hudson_climb_up()
{
	trigger_wait( "trig_player_on_ladder" );

	// semi-hack.  Catch up if Hudson isn't near the ladder
	node = GetNode( "n_ladder_catchup", "targetname" );
	if ( self.origin[2] < (node.origin[2] + 16) &&	// not on the ladder
		 self.origin[0] < (node.origin[0] + 32) &&	// not in the vicinity of the ladder
		 self.origin[1] < (node.origin[1] + 16) )
	{
		self forceTeleport(node.origin, node.angles);
	}

	node = GetNode( "n_top_of_ladder", "targetname" );
	self force_goal( node, 16, true, undefined, true );
	self waittill( "goal" );

	flag_set( "hudson_climbed_ladder" );
}


//
//
hudson_catch_up()
{
	trigger_wait( "trig_hudson_catchup" );

	if ( !flag( "hudson_climbed_ladder" ) )
	{
		// TEMP:  teleport hudson into dry room
		teleport_node = GetNode( "n_top_of_ladder", "targetname" );
		self forceTeleport(teleport_node.origin);

		self notify("killanimscript");
//		self StopAnimScripted();

		flag_set( "hudson_climbed_ladder" );
	}
}


//
//	Close hatch when both are up.
close_hatch()
{
	flag_wait( "hudson_climbed_ladder" );

	player = get_players()[0];

	trig = GetEnt( "trig_top_of_ladder", "targetname" );
	while ( player.origin[2] < -5352 || player IsTouching( trig ) )
	{
		wait( 0.05 );
	}

	// close vertical shaft
	blocker = GetEnt("vertical_shaft_hatch", "targetname");
	blocker Solid();

	// Hatch door model
	hatch = GetEnt( "hatch_door", "targetname" );
	hatch RotatePitch( -90, 1.0, 0.9 );
}

//
//	Nag until player climbs up.
ladder_nag()
{
}