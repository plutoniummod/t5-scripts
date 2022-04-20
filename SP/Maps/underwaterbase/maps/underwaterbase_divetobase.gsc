/*
//-- Level: Underwater Base
//-- Level Designer: Gavin Goslin
//-- Scripter: Alfeche/Vento
*/
#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\_anim;
#include maps\underwaterbase_util;
#include maps\_music;

#using_animtree ("generic_human");

//
// gets run through at start of level
init_flags()
{	
	flag_init( "player_dive_done" );
	flag_init( "moon_pool_room_entered" );
	
	maps\underwaterbase_enterbase::init_flags();
}


//
//
objectives( starting_obj_num )
{
	level.curr_obj_num = starting_obj_num;
	
	flag_wait( "player_dive_done" );

	Objective_Add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_ENTER_BASE" );
	Objective_Position( level.curr_obj_num, struct_origin("get_to_base_objective") );
	Objective_Set3D( level.curr_obj_num, true );
	flag_wait( "moon_pool_room_entered" );
	Objective_State( level.curr_obj_num, "done" );
	
	level.curr_obj_num++;
	maps\underwaterbase_enterbase::objectives( level.curr_obj_num );
}


//
// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	thread maps\underwaterbase_util::fade_out( 0.05, "black" );
	level.heroes[ "weaver" ] Delete();

	level thread objectives(0);
	wait( 2.0 );	// give time for swimming to initialize

	// Put on divemask
	thread maps\underwaterbase_util::divemask_equip();
	player_to_struct( "divetobase_start" );

	// misc setup necessary to make the skipto work goes here
	run();
}


//
//	Main proc
run()
{
	init_divetobase();

	//TUEY set music to DIVE
	setmusicstate ("DIVE");
	
	wait( 0.05 );

	level thread launch_buoys();
	level thread moon_pool();

	// Dive!
	sync_node = GetStruct( "sync_dive_base_landing_spot", "targetname" );

	level thread player_dive( sync_node );
	for ( i=0; i<level.allies.size; i++ )
	{
		level.allies[i] thread dive_traverse( sync_node, "moonpool_entrance_"+i );
	}
	level.heroes[ "hudson" ] thread dive_traverse( sync_node, "moonpool_entrance_3" );
	level thread descent_dialog();
	level thread descent_nag();
	trigger_wait( "enter_moonpool_trigger" );

	cleanup();
	maps\underwaterbase_enterbase::run();
}


//
//	Initialization for this section
init_divetobase()
{
	player = get_players()[0];

	// This clears out all previous exploders and activates the dive section
	level notify( "exp_divetobase" );		// activate exploder dive

	// Remove all previous AI
	array_delete( GetAIArray( "allies", "axis" ) );

	// Init dive allies (so we keep the same names)
	level.allies = simple_spawn( "ai_dive_allies" );
	maps\underwaterbase::setup_hero( "ai_dive_hudson", "Hudson", "hudson" );

	// Set the underwater vision set
	player clientnotify( "uwb_vs" );

	// turn off drowning
	level.disable_drowning = true;
	player clientnotify("_disable_drowning");

	level.default_pitch_down = GetDvarInt("player_view_pitch_down");
  	player setclientdvar("player_view_pitch_down", "89");
}


//
//	Handle player movement along rail
player_dive( sync_node )
{
	player = get_players()[0];
	
	start_point = GetStruct( "divetobase_start", "targetname" );
	player SetPlayerAngles( start_point.angles );

	player thread lookatbase();
	player thread maps\underwaterbase_anim::dive_anim_player( sync_node );
	wait( 0.5 );	// wait must be at least 0.3 before setting the fog and vision

	// NOTE: This needs to be called AFTER the player is in the water,
	//	otherwise the default swimming vision set is used.
	level thread maps\createart\underwaterbase_art::set_dive_fog_and_vision();

    clientnotify( "trans1e" );
    
	maps\underwaterbase_util::fade_in( 3, "black" );
	player SetClientDvar( "compass", "1" );	// enable crosshairs HUD (disabled in rendezvous_with_weaver)

	flag_wait( "player_dive_done" );

	player SetClientDvar( "player_waterSpeedScale", 1.40 );
}


//
// Makes friendlies traverse along a connected series of structs
dive_traverse( sync_node, start_name )
{
	// Spawn a script_model so we can stop the bubble FX later on by deleting the script_model
	linker = Spawn( "script_model", self GetTagOrigin( "J_SpineUpper" ) );
	linker SetModel( "tag_origin" );
	linker LinkTo( self, "J_SpineUpper" );
	PlayFxOnTag( level._effect["bubbles"], linker, "tag_origin" );
	self maps\underwaterbase_anim::dive_anim_ai( sync_node );
	linker Delete();
}


//
//	Send buoys up as we descend
launch_buoys()
{
	sea_level_struct = GetStruct( "ss_surface_height", "targetname" );
	sea_level = sea_level_struct.origin[2];

	buoys = GetEntArray( "dive_buoy", "targetname" );
	for ( i=0; i<buoys.size; i++ )
	{
		delay = 0;
		if ( !IsDefined( buoys[i].script_int ) )
		{
			continue;
		}

		// Yeah the order is crazy, but they came in at different times
		// and it's a pain to renumber them with the correct timing
		switch( buoys[i].script_int )
		{
		case 0:		// Close to end spot - rises after player is able to swim
			delay = 32;
			break;
		case 1:		// SE
			delay = 0;
			break;
		case 2:		// ENE
			delay = 12;
			break;
		case 3:		// NE (W of 12)
			delay = 18;
			break;
		case 4:		// W	Passes right in front of player
			delay = 0;
			break;
		case 5:		// SW
			delay = 10;
			break;
		case 6:		// S	Near the pool entrance
			delay = 45;
			break;
		case 7:		// NW
			delay = 10;
			break;
		case 8:		// SW (N of 5)
			delay = 26;
			break;
		case 9:		// SW (N of 8)
			delay = 0;
			break;
		case 10:	// N
			delay = 0;
			break;
		case 11:	// N (E of 10)
			delay = 16;
			break;
		case 12:	// NE (E of 3, N of 2)
			delay = 6;
			break;
		case 13:	// E (S of 2)
			delay = 0;
			break;
		default:
			break;
		}

		buoys[i] thread launch_buoy( delay, sea_level );
	}
}


//
//	Cause buoy to rise up to the surface at the appropriate time
//	self is a buoy
launch_buoy( delay, sea_level )
{
	prep_time = 0;
	if ( delay > 1 )
	{
		prep_time = 1;
	}

	wait( delay - prep_time );

	playsoundatposition( "evt_buoy_launch", self.origin );
	self PlayLoopSound( "evt_buoy_looper" );
	PlayFXOnTag( level._effect["buoy_lights"], self, "tag_origin" );
	wait( prep_time);

	speed = 150;	// units per second
	distance = sea_level - self.origin[2];
	time = distance / speed;
	self MoveZ( sea_level - self.origin[2], time );

	// Add a little rotation
	sign = 1;
	if ( RandomInt(100)<50)
	{
		sign = -1;
	}
	self RotateYaw( sign*RandomFloatRange(360, 720), 30 );

	wait( time );

	self Delete();
}


//
//	
lookatbase()	// self = player
{
	level endon( "player_dive_done" );

	base_target = GetStruct( "dive_look_spot", "targetname" );
	level.time_since_last_movement = 1;	

	engaged_auto_move = false;
	while(1)
	{
		if( self no_stick_movement() )
		{
			lookatbase_camera_movement( base_target );
			engaged_auto_move = true;
		}
		else if ( engaged_auto_move )
		{
			return;
		}
		
		wait(0.05);
	}
}


//
//
lookatbase_camera_movement( base_target )
{
	// get the current angle
	player = get_players()[0];
	current_angles = player GetPlayerAngles();
//	iprintlnbold(current_angles[0] + ", " + current_angles[1] + ", " + current_angles[2]);
	current_vector = AnglesToForward( current_angles );

	target_vector = VectorNormalize(base_target.origin - player.origin);

	angle_limit = 0.5;												// How fast we're going to move per frame
	dot = VectorDot( current_vector, target_vector );				// dot product between two vectors gives you the angle between them
	angle = 0.0;													// how much you have to rotate to look at the target.  Default to no change
	if ( dot < 0.99999 )
	{
		angle = acos( dot );		// This is the angle between the two vectors.
	}

	new_vector = target_vector;										// This is where we're going to end up looking, defaults to "already looking at it"
	if ( angle > angle_limit )
	{
		ratio = angle_limit / angle;
		new_vector = VectorLerp( current_vector, target_vector, ratio );
	}

	player SetPlayerAngles( VectorToAngles(new_vector) );
}


//
//	Returns true if the controller hasn't been touched in a while
no_stick_movement()
{
	result = true;
	
	control_vec = self GetNormalizedCameraMovement();
	if( abs(control_vec[0]) > 0.25 )
	{
		result = false;
		level.time_since_last_movement = 0;
	}
	
	if( abs(control_vec[1]) > 0.25 )
	{
		result = false;
		level.time_since_last_movement = 0;
	}
	
	if( result && level.time_since_last_movement == 0 )
	{
		level.time_since_last_movement = GetTime();
	}
	
	if( GetTime() - level.time_since_last_movement < 2000 )	// 2 seconds
	{
		result = false;	
	}
	
	return result;
}


//
//	Handles moving the water when about to exit the moonpool.
//	We move the water in case he doesn't get out right away.
moon_pool()
{
	level endon("moon_pool_room_entered");

	// This trigger is on the moonpool water
	trigger = getent( "enter_moonpool_trigger", "targetname" );

	// Adjust the water level as needed
	while (1)
	{
		trigger waittill( "trigger", player );
		
  		// set water volume to moonpool level
		maps\underwaterbase_util::set_water_height( "water_volume_moonpool_height", false );

		// Wait until the player leaves the trigger
		while ( player IsTouching( trigger ) )
		{
			wait( 0.05 );
		}

  		// set water volume to default (high) level
		maps\underwaterbase_util::set_water_height( "water_volume_default_height" );
	}
}


//
//
cleanup()
{
	// removing diving friendlies
	friendlies = GetEntArray("divetobase_friendly", "script_noteworthy");
	for( i=0; i<friendlies.size; i++ )
	{
		if(IsDefined(friendlies[i]) && IsAlive(friendlies[i]))
		{
			friendlies[i] Delete();
		}
	}

	// player can now drown in water
	level.disable_drowning = false;
	player = get_players()[0];
	player clientnotify("_enable_drowning");
	player setclientdvar("player_view_pitch_down", level.default_pitch_down);	
}


//
//	Conversation between Hudson and Mason
descent_dialog()
{
	wait( 5.0 );	// wait a couple of seconds before starting dialog

	player = get_players()[0];
	player anim_single( player, "see_buoys" );
	level.heroes["hudson"] anim_single( level.heroes["hudson"], "transmit_surface" );
	level.heroes["hudson"] anim_single( level.heroes["hudson"], "structure_below" );
	player anim_single( player, "supply_station" );
	player anim_single( player, "dragovichs_plan" );
}


//
//	In case the player takes too long to get out
descent_nag()
{
	level.heroes[ "hudson" ] waittill( "diver_waiting" );
	wait( 10 );

	if ( !flag( "moon_pool_room_entered" ) )
	{
		lines[0] = "this_way";
		lines[1] = "mason_over_here";
		lines[2] = "hurry_mason";
		lines[3] = "come_on_mason_hurry";
		level thread nag_dialog( level.heroes[ "hudson" ], lines, 15, "moon_pool_room_entered" );
	}
}