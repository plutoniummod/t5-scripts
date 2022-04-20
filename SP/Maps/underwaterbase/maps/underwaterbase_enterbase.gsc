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

//
// gets run through at start of level
init_flags()
{
	flag_init( "squad_enter_moonpool" );
	flag_init( "moonpool_open_door" );
	flag_init( "lower_bridge" );
	flag_init( "intruder_alert" );
	flag_init( "subpen_door_open" );

	maps\underwaterbase_bigflood::init_flags();
}


//
//
objectives( starting_obj_num )
{
	level.curr_obj_num = starting_obj_num;

	Objective_Add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_FIND_DRAGOVICH" );
	Objective_Position( level.curr_obj_num, struct_origin("clear_second_baddies_in_moon_pool_room_objective") );
	Objective_Set3D( level.curr_obj_num, true );
	
	maps\underwaterbase_bigflood::objectives( level.curr_obj_num );
}


//
// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	level thread objectives(0);

	// Environment
  	maps\createart\underwaterbase_art::set_underwater_base_fog();		
	maps\underwaterbase_util::setup_umbilical_water();
	maps\underwaterbase_util::set_water_height( "water_volume_moonpool_height" );

	// Player
	// turn off drowning
	player = get_players()[0];
	player clientnotify("_disable_drowning");	
	level.disable_drowning = true;	
	wait( 1.0 );
	thread maps\underwaterbase_util::divemask_equip();
	wait( 1.0 );	// give time for swimming to initialize

	player_to_struct( "enterbase_start" );

	// Hack for falling death at the start
	player EnableInvulnerability();
	thread run();
	wait( 2.0 );

	player DisableInvulnerability();
}


//
//	
run()
{
	level notify( "moon_pool_wires_start" );	// wires shake

	level notify( "exp_enter_base" );		// activate exploder
	clientnotify( "upfxsn" );

	// Init subs
	level thread sub_move( "sm_sub",  "fxanim_uwb_sub_rise_anim", "moonpool_open_door", "sub_rise_start" );
	level thread sub_move( "sm_sub2", "fxanim_uwb_sub_drop_anim", "exp_torp1",			"sub_drop_start" );

	// Deactivate monster clip
	clip = GetEnt( "clip_sub", "targetname" );
	clip trigger_off();
	clip ConnectPaths();

	// move player to a convenient spot where he's not facing his team
	level thread exit_moonpool();
	level thread swimming_monitor();

	level thread sub_pens();
	trigger_wait( "trig_bigflood_stairs" );

	thread maps\underwaterbase_bigflood::run();

	cleanup();
}


// Player gets out and then Hudson opens the door to the next area
exit_moonpool()
{
	trigger_wait( "trig_e5_enter_base" );
	
	clientnotify( "trans2" );

	flag_set( "moon_pool_room_entered" );	

	maps\createart\underwaterbase_art::set_underwater_base_fog();
	level thread setup_friendlies();
	level thread moonpool_move_player();
	level waittill("moonpool_climbout_done");	

	// Move to your start spots
	for ( i=0; i<level.allies.size; i++ )
	{
		node = GetNode( level.allies[i].target, "targetname" );
		level.allies[i] SetGoalNode( node );
	}

	maps\underwaterbase_anim::enter_subpen();

	flag_set( "intruder_alert" );
	clientnotify( "almu1" );
}


//
//	Friendly inits
setup_friendlies()
{
	flag_wait( "squad_enter_moonpool" );  	// don't let the player see any AI's popping
	wait( 0.05 );	// let the squad do some cleanup

	// Remove all previous AI
	array_delete( GetAIArray( "allies", "axis" ) );

	// Init dive allies (so we keep the same names)
	level.allies = simple_spawn( "ai_enterbase_allies" );
	maps\underwaterbase::setup_hero( "ai_enterbase_hudson", "Hudson", "hudson" );

	ai = GetAIArray( "allies" );
	for ( i=0; i<ai.size; i++ )
	{
		if ( ai[i] != level.heroes[ "hudson" ] )
		{
			ai[i].health = 500;
		}
		ai[i].script_accuracy = 10;
		ai[i].ignoresuppression = 1;
		ai[i] enable_cqbwalk();
		ai[i] disable_ai_color();	// enabled in enter_subpen_door_open
		ai[i] thread wait_for_alert();
	}
}


//
//
moonpool_move_player() // self is level
{
	// grab player control
	player = get_players()[0];
   	player_linker = spawn( "script_model", player.origin );
   	player_linker setmodel( "tag_origin" );
   	player_linker.angles = player.angles; 	
   	
//    	player SetLowReady(true);	   		
    player playerlinktoabsolute( player_linker, "tag_origin" );
    
	player_linker linked_move( "player_moonpool_exit_start_1", 1.5 );
	
	// 
	level notify( "divemask_unequip" );
	//SOUND - Shawn J
	level thread dive_mask_off();

	player_linker linked_move( "player_moonpool_exit_start_2", 0.1 );
	
	flag_set( "squad_enter_moonpool" );  	

	player_linker linked_move( "player_moonpool_exit_start_3", 0.1 );
	player_linker linked_move( "player_moonpool_exit_start_4", 0.1 );
	player_linker linked_move( "player_moonpool_exit_start_5", 0.1 );
	player_linker linked_move( "player_moonpool_exit_start_6", 0.1 );
	player_linker linked_move( "player_moonpool_exit_start_7", 0.1 );
	player_linker linked_move( "player_moonpool_exit_start_8", 0.1 );
	player_linker linked_move( "player_moonpool_exit_start_9", 0.1 );

	player Unlink();        	 	 	
	player_linker Delete();
	level notify("moonpool_climbout_done");	

	// save game
	autosave_by_name( "underwaterbase_enterbase" );	
}
//
linked_move( targetname, time )
{
	destination = getstruct( targetname, "targetname" );    	
	self moveto( destination.origin, time );
	self rotateto( destination.angles, time );
	wait( time );
}

//
//	Sub pen battle
sub_pens()
{
	flag_wait("moonpool_open_door");

	level thread bridge_rotate( "sbm_bridge_1r", -90, 20.0, "moonpool_open_door" );
	level thread bridge_rotate( "sbm_bridge_1l",  90, 20.0, "moonpool_open_door" );
	level thread bridge_rotate( "sbm_bridge_2r",  90, 10.0, "lower_bridge" );
	level thread bridge_rotate( "sbm_bridge_2l", -90, 10.0, "lower_bridge" );

	// Subs sm_sub sm_sub2
	level notify( "sub_rise_start" );
	wait(4.05);	// spawn guys before the door opens

	// Spawn initial guys
	ai = simple_spawn( "ai_e5_sub_pen_start", ::wait_for_alert );
	ai thread subpen_dialog();
	subpen_wait();


	// Spawn next set of guys and open the big doors
	ai = simple_spawn( "ai_e5_sub_pen2", ::enable_cqbsprint );
	ai[0].animname = "spetsnaz";
	ai[0] anim_single( ai[0], "intruder_alert" );

	level thread open_sliding_doors();
	flag_set( "lower_bridge" );

	level thread subpen_blast();

	// wait for the bridge to lower and then let AI path on it
	wait( 10.0 );	

	clip = GetEnt( "clip_bridge", "targetname" );
	clip trigger_off();
	clip ConnectPaths();
}


//
//	Multiple condition wait.  This should not be threaded.
subpen_wait( )
{
//	Don't let players force their way through and create too many AI
// 	trig = GetEnt( "trig_e5_door_open", "targetname" );
// 	trig endon( "trigger" );

	waittill_ai_group_ai_count( "sub_pen", 3 );
}


//
//	Play some loops and wait for action to kick off
wait_for_alert()
{
	self endon( "death" );

//	self.ignoreall = 1;	All of this alert crap isn't necessary any more...should remove it if I have time
	enable_cqbwalk();
	waittill_any_ents( self, "damage", self, "death", level, "intruder_alert", level, "squad_enter_moonpool" );
	flag_set("intruder_alert");

	self.ignoreall = 0;
	wait( 5 );
	enable_cqbsprint();
}


// Move the bridge pieces
//	Targetname is the name of the bridge piece
//	Rotation is the amount you want the bridge to rotate FROM
//		It will teleport the bridge position to the rotation amount and then rotate back to its normal state.
bridge_rotate( targetname, rotation, time, start_msg )
{
	bridge = GetEnt( targetname, "targetname" );
	if ( IsDefined( bridge.target ) )
	{
		parts = GetEntArray( bridge.target, "targetname" );
		for ( i=0; i<parts.size; i++ )
		{
			parts[i] LinkTo( bridge );
		}
	}

	bridge RotatePitch( rotation, 0.05 );
	wait( 0.1 );
	flag_wait( start_msg );

	bridge RotatePitch( -1 * rotation, time );
}


// Move the bridge pieces
//	Targetname is the name of the bridge piece
//	z_move is the height you want the bridge to move FROM
//		It will teleport the sub position to the z_move amount and then move back to its original state.
sub_move( subname, fxanimname, start_msg, fxanim_msg )
{
	sub = GetEnt( subname, "targetname" );
	if ( IsDefined( sub.target ) )
	{
		parts = GetEntArray( sub.target, "targetname" );
		for ( i=0; i<parts.size; i++ )
		{
			parts[i] LinkTo( sub );
		}
	}
	fxanim = GetEnt( fxanimname , "targetname" );
	org = fxanim GetTagOrigin( "sub_attach_jnt" );
	sub.origin = org;
	sub LinkTo( fxanim, "sub_attach_jnt" );

	if ( IsDefined( start_msg ) )
	{
		level waittill( start_msg );
	}

	level notify( fxanim_msg );
}


//
//	Open large doors in the sub pen
open_sliding_doors( time )
{
	if ( !IsDefined(time) )
	{
		time = 5.0;
	}

	// begin the giant sliding door
	moonpool_door_left	= GetEnt( "moonpool_door_left", "targetname" );
	moonpool_clip_left	= GetEnt( moonpool_door_left.target, "targetname" );
	moonpool_clip_left LinkTo( moonpool_door_left );

	moonpool_door_right	= GetEnt( "moonpool_door_right", "targetname" );
	moonpool_clip_right	= GetEnt( moonpool_door_right.target, "targetname" );
	moonpool_clip_right LinkTo( moonpool_door_right );

    playsoundatposition( "evt_subdoor_start", moonpool_door_left.origin );
    playsoundatposition( "evt_subdoor_start", moonpool_door_right.origin );
    moonpool_door_right PlayLoopSound( "evt_subdoor_loop" );
    moonpool_door_left PlayLoopSound( "evt_subdoor_loop" );
    
	moonpool_door_left  MoveX( -159, time );
	moonpool_door_right MoveX(  159, time );
	wait( time );

    moonpool_door_right StopLoopSound();
    moonpool_door_left StopLoopSound();
    playsoundatposition( "evt_subdoor_end", moonpool_door_left.origin );
    playsoundatposition( "evt_subdoor_end", moonpool_door_right.origin );
    
	moonpool_clip_left	ConnectPaths();	
	moonpool_clip_right	ConnectPaths();

	// grab a convenient entity for our intruder announcement
	clip = GetEnt( "clip_sub", "targetname" );
	clip.animname = "spetsnaz";
	clip anim_single( clip, "intruder_alert" );
}


//
//	Guys run along the catwalks to open the side bulkhead doors
catwalk_door_group( ai_name, door_name )
{
	ai = simple_spawn( ai_name, maps\underwaterbase_util::indoor_forcegoal );

	maps\underwaterbase_util::door_open( door_name, -120, 0.5 );
}


//
//	First torpedo hit
subpen_blast()
{
	trigger_wait( "trig_subpen_blast" );

 	level thread catwalk_door_group( "ai_e5_sub_pen2_nw_door", "subpen_west_door" );
 	level thread catwalk_door_group( "ai_e5_sub_pen2_ne_door", "subpen_east_door" );
	level thread exit_wave();

	player = get_players()[0];
	Earthquake( 0.75, 1, player.origin, 500 );
	player PlayRumbleOnEntity( "artillery_rumble" );
	playsoundatposition( "evt_uwb_explosion", (0,0,0) );
	clientnotify( "exsnp" );
	// Change lighting
	clientnotify( "light_torp01" );	// lighting change
	level notify( "exp_torp1" );	// activate exploder torpedo 1
	clientnotify( "upfxsn" );

	// Sub crashes - This will be an FX anim
	wait( 5.0 );

	Earthquake( 0.5, 2.0, player.origin, 500 );
	player PlayRumbleOnEntity( "artillery_rumble" );
	playsoundatposition( "evt_uwb_explosion", (0,0,0) );
	clientnotify( "exsnp" );

	// Damage anything touching the sub crash area
	damage_area = GetEnt( "vol_sub_damage", "targetname" );
	damage_area thread sub_damage();

	// Activate monster clip
	clip = GetEnt( "clip_sub", "targetname" );
	clip trigger_on();
	clip DisconnectPaths();

	wait( 1.0 );	// Let the crash sink in

	clip trigger_off();	// move it out of the way so noone runs into an invisible wall
	level thread torpedo_dialog();

	level thread maps\underwaterbase::base_impacts( "occasional" );
}


//
//	Kills anyone touching the volume
sub_damage()
{
	player = get_players()[0];
	if ( player IsTouching( self ) )
	{
		player DisableInvulnerability();	// just in case!
		player DoDamage( player.health + 1000, player.origin, self );
	}

	ai = GetAIArray( "axis", "allies" );
	for ( i=0; i<ai.size; i++ )
	{
		if ( ai[i] IsTouching( self ) && ai[i] != level.heroes[ "hudson" ] )
		{
			ai[i] DoDamage( ai[i].health, ai[i].origin, self );
		}
	}
}


//
//	Here comes the brute squad
exit_wave()
{
	// wait until we clear x guys or we move up to the spawn trigger
	level thread wait_condition1();
	level thread wait_condition2();
	level waittill( "end_wait_condition" );

	player = get_players()[0];
	ai = simple_spawn( "ai_subpen_heavies" );
	for ( i=0; i<ai.size; i++ )
	{
		if ( i == 0 )
		{
			ai[i] maps\_rusher::rush();
		}
		else
		{
			ai[i] SetGoalEntity( player );
		}
	}

	level notify( "exp_chamber1" );		// activate exploder 1st hallway
	clientnotify( "upfxsn" );

	// Slam door open
	maps\underwaterbase_util::door_open( "subpen_exit_door", 170, 1.0 );

}
wait_condition1()
{
	level endon( "end_wait_condition" );
	waittill_ai_group_ai_count( "sub_pen", 4 );

	level notify( "end_wait_condition" );
}
wait_condition2()
{
	level endon( "end_wait_condition" );
	trigger_wait( "trig_subpen_exit" );

	level notify( "end_wait_condition" );
}


//
//
cleanup()
{
}


//
//	Random VO for spets
//	
subpen_dialog()
{
	lines[0] = "sub_position";
	lines[1] = "check_seals";
	lines[2] = "prep_fuel";

	self[0].animname = "spetsnaz";
	self[0] anim_single( self[0], lines[ RandomInt(lines.size) ] );
}


//
//
torpedo_dialog()
{
	player = get_players()[0];

	level.heroes["hudson"] anim_single( level.heroes["hudson"], "begun_attack" );
	level.heroes["hudson"] anim_single( level.heroes["hudson"], "weaver_what" );
	level.heroes["hudson"] anim_single( level.heroes["hudson"], "dammit" );
	player anim_single( player, "too_late" );
}


//
//	Disables weapons if you're swimming
swimming_monitor()
{
	player = get_players()[0];
	while (1)
	{
		player waittill("underwater");

		player DisableWeapons();

		player waittill( "surface" );

		player EnableWeapons();
	}
}

dive_mask_off()
{
	realwait(.70);
	playsoundatposition("fly_dive_mask_off", (0,0,0));

}