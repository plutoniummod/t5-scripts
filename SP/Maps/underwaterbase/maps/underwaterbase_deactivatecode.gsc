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
#include maps\_music;

// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{	
	player = get_players()[0];
	player SetWaterDrops( 100 );

	Objective_Add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_FIND_DRAGOVICH" );
	level thread objectives(0);

	player_to_struct( "deactivatecode_start" );

	// close vertical shaft
	blocker = getent("vertical_shaft_hatch", "targetname");
	blocker Solid();

	maps\createart\underwaterbase_art::set_underwater_base_fog();
	VisionSetNaked( "UWB_BroadcastCenter", 0.05 );

	// spawn underwater Hudson
	level.heroes[ "weaver" ] Delete();
	level.heroes[ "hudson" ] Delete();
	maps\underwaterbase::setup_hero( "ai_enterbase_hudson", "Hudson", "hudson" );
	level.heroes[ "hudson" ] set_actor_start("ss_deactivatecode_hudson_start", "r" );

	//open the broadcast center door
// 	broadcastcenter_door = GetEnt("broadcastcenter_door", "targetname");
// 	broadcastcenter_door rotateyaw(-115, 1);
// 	broadcastcenter_door waittill( "rotatedone" );
// 	broadcastcenter_door connectpaths();

	maps\underwaterbase_util::set_water_height( "water_volume_broadcast_height", true );

	level thread maps\underwaterbase::base_impacts( "medium" );

	level notify( "exp_chamber3" );		// top of ladder
	wait( 0.05 );
	level notify( "exp_chamber3_5" );	// top of ladder
	wait( 0.05 );
	level notify( "exp_control" );		// top of ladder

	// misc setup necessary to make the skipto work goes here
	run();
}

// gets run through at start of level
init_flags()
{
	flag_init( "dragovich_fight_start" );
	flag_init( "dragovich_fight_wait_for_input" );
	flag_init( "dragovich_fight_pull_down" );
	flag_init( "dragovich_fight_choking" );
	flag_init( "dragovich_fight_halfway_done" );
	flag_init( "dragovich_fight_end" );	
	flag_init( "dragovich_focus" );
	
	maps\underwaterbase_escape::init_flags();
}


//
objectives( starting_obj_num )
{
	level.curr_obj_num = starting_obj_num;

	// New sub objective
	level.curr_obj_num++;
	Objective_Add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_STOP_TRANSMISSION" );
	Objective_Position( level.curr_obj_num, struct_origin("kill_dragovich_objective") );
	Objective_Set3D( level.curr_obj_num, true );
	flag_wait( "dragovich_fight_start" );
	Objective_State( level.curr_obj_num, "done" );
	Objective_Delete( level.curr_obj_num  );
	level.curr_obj_num--;
	
	Objective_State( level.curr_obj_num, "done" );
	level.curr_obj_num++;
	flag_wait( "dragovich_fight_end" );
	maps\underwaterbase_escape::objectives( level.curr_obj_num );
}

//
cleanup()
{
}


//
//
run()
{
	thread dragovich_fight();

	flag_wait ("dragovich_fight_halfway_done");
//	wait( 1.0 ); // just a small wait so Hudson doesn't insta-sprint for the exit after the player drops Hudson	
	
	cleanup();
	maps\underwaterbase_escape::run();
}


//
//	When the player arrives at the console, do some stuff and then get knocked over
dragovich_fight()
{
	trigger_wait( "kill_dragovich_sequence_trigger" );
	
	//TUEY set music to NUMBERS
	setmusicstate ("NUMBERS");
	clientnotify( "num_nix" );	
	
	// save game
	autosave_by_name( "underwaterbase" );
	wait( 0.05 );

	//corpse removal - don't let anyone get in the way of the final scene.
	inside_pos = getstruct("water_volume_escape_height","targetname");
	corpses = EntSearch(level.CONTENTS_CORPSE, inside_pos.origin, 150);
	for(i = 0; i < corpses.size; i++)
	{
		if(IsDefined(corpses[i]))
		{
			corpses[i] Delete();
		}
	}

	flag_set( "dragovich_fight_start" );	
	level thread maps\underwaterbase::set_base_impact_state( "wait" );
	maps\underwaterbase_anim::end_fight();
}
