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
#include maps\fullahead_anim;

// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	player_to_struct( "p2shipmast_playerstart" ); // put player in roughly correct position
	
	add_global_spawn_function( "axis", ::spawnfunc_ikpriority ); // happens in shiparrival
	add_global_spawn_function( "allies", ::spawnfunc_ikpriority );
	
	maps\fullahead_p2_nazibase::cleanup();
	
	default_fog();
	
	player = get_player();
	player thread maps\fullahead_p2_shipfirefight::shipfirefight_teamhandler();
	
	trig = getent( "deck_sas_start_trigger", "targetname" );
	trig useby(player);
	trig = getent( "deck_russ_start_trigger", "targetname" );
	trig useby(player);
	
	
	friend = simple_spawn_single( "p2shipfirefight_ally" );
	friend.script_noteworthy = "p2firefight_player_friendly"; // used for the team switching stuff
	friend thread magic_bullet_shield();
	friend.name = "Nevski";
	friend.animname = "nevski";
	level.nevski = friend;
	
	nodes = getnodearray( "p164", "script_noteworthy" );
	level.nevski forceteleport( nodes[0].origin );
	level.nevski setgoalnode( nodes[0] );
	level.nevski.goalradius = 32;
	
	// would've happened in shiparrival
	setup_visionset_triggers();
	
	fa_visionset_bright();
	
	objective_add( 0, "done", &"FULLAHEAD_OBJ_NAZIBASE_STEINER" );
	objective_add( 1, "done", &"FULLAHEAD_OBJ_SECURE_WEAPON" );
	objective_add( 2, "active", &"FULLAHEAD_OBJ_ESCAPE_SHIP_DETONATE" );
	level thread objectives(2);
	
	wait(0.1); // give the managers time to populate for the skipto's sake
	
	run();
}

run()
{
	init_event();

	// disable the big kill trigger
	killtrigger = getent( "ship_kill_trigger", "targetname" );
	killtrigger trigger_off();
	
	// stop extraneous spawning for now
	spawn_manager_disable( "p2shipfirefight_deck_russ_south" );
	spawn_manager_disable( "p2shipfirefight_deck_sas_south" );
	
	// spawn these guys guys so at least SOMEBODY is around
	// simple_spawn( "p2shipmast_spawner" );

	// we want drama, not real danger -- make the enemies terrible shots!
	shipmast_reduce_enemy_accuracy();
	
	level thread nevski_dialogue();
	
	// the player should be getting onto the mast here... free motion stops at the end of firefight
	level thread shipmast_zipline();
	
	flag_wait( "P2SHIPMAST_EXIT" );	
	cleanup();
	maps\fullahead_p2_wrapup::run();
}

init_event()
{
	fa_print( "init p2 shipmast\n" );

	autosave_by_name( "fullahead" );
}

// gets run through at start of level
init_flags()
{
	flag_init( "P2SHIPMAST_CABLE_SLIDING" );
	flag_init( "P2SHIPMAST_EXIT" );
	maps\fullahead_p2_wrapup::init_flags();
}

cleanup()
{
	fa_print( "cleanup p2 shipmast\n" );
}

objectives( curr_obj_num )
{
	objective_position( curr_obj_num, ent_origin( "p2shipmast_geton" ) );
	objective_set3d( curr_obj_num, true );
	flag_wait( "P2SHIPMAST_EXIT" );

	maps\fullahead_p2_wrapup::objectives( curr_obj_num );
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

nevski_dialogue()
{
//     level.scr_sound["Nevski"]["ropehurry"] = "vox_ful1_s06_131A_nevs"; //Down the rope! Hurry!

	level.nevski anim_single( level.nevski, "ropehurry", "Nevski" );
}

shipmast_zipline()
{
	trig = getent( "p2shipmast_geton", "targetname" );
	//trig trigger_use_button( &"FULLAHEAD_USE_ZIPLINE" );
	trig waittill( "trigger" );
	
	flag_set( "P2SHIPMAST_CABLE_SLIDING" );
	
	// take the player's weapons away...
	player = get_player();
	player TakeAllWeapons();
	
	// player zipline animation
	struct = getstruct( "zipline_anim_struct", "targetname" );
	assert( isdefined(struct) );
	
	struct play_player_anim( struct, "use_zipline", "playerbody", undefined, true, undefined, undefined, 0.2, "tag_camera" );

	// once player lands, teleport to other area
	level thread teleport_player_other_area();
	
	wait(0.2);
	player shellshock( "default", 1.5 );
	
	// teleport nevski to new area behind player
	new_area_struct = getstruct( "new_area_zipline_anim_struct", "targetname" );
	level.nevski.animname = "nevski";
	level.nevski forceteleport( new_area_struct.origin, new_area_struct.angles );
	wait( 0.1 );	//fix for nevski not always being there? -jc
	new_area_struct thread anim_single_aligned( level.nevski, "hits_ground" );
	
	flag_set( "P2SHIPMAST_EXIT"	);
}

teleport_player_other_area()
{
	player = get_player();	
	new_area_struct = getstruct( "new_area_zipline_anim_struct", "targetname" );	
	
	player setorigin( new_area_struct.origin );
	new_area_struct thread play_player_anim( new_area_struct, "hits_ground", "playerbody" );
}

shipmast_reduce_enemy_accuracy()
{
	ai = getaiarray( "axis", "allies" );
	if( isDefined(ai) )
	{
		for( i=0; i<ai.size; i++ )
		{
			ai[i].script_accuracy = 0.2; // make guys pretty inaccurate
		}
	}
}
