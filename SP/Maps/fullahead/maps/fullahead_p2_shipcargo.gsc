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
#include maps\_music;

// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	// relocate player to correct position
	player_to_struct( "p2shipcargo_playerstart" );
	
	add_global_spawn_function( "axis", ::spawnfunc_ikpriority ); // happens in shiparrival
	add_global_spawn_function( "allies", ::spawnfunc_ikpriority );
	
	default_fog();
	
	get_player() fa_take_weapons();
	player_flashlight_pistol();
	get_player() giveweapon( "knife_sp" );
	get_player() giveweapon( "frag_grenade_russian_sp" );
	get_player() giveweapon( "mp40_sp" );

	maps\fullahead_p2_nazibase::cleanup();
	maps\fullahead_p2_shiparrival::spawn_ship_squad();
	level.shipsquad[2] stop_magic_bullet_shield();
	level.shipsquad[3] stop_magic_bullet_shield();
	//teleport_ship_squad( "door7" ); PI - DMM - commented out since the old teleport nodes out in empty space were removed.
	
	/#
	level.kravchenko thread krav_sanity_check();
	#/

	// would've happened in shiparrival
	setup_visionset_triggers();

	ship_door_setup( "cargo" );
	ship_door_setup( "black" );

	fa_visionset_bright();

	wait(0.1);

	objective_add( 0, "done", &"FULLAHEAD_OBJ_NAZIBASE_STEINER" );
	objective_add( 1, "active", &"FULLAHEAD_OBJ_SECURE_WEAPON" );
	
	flag_set( "P2SHIPCARGO_BREADCRUMB1" );
	flag_set( "P2SHIPARRIVAL_EXECUTION_FINISHED" );
	
	level thread objectives(1);
	level thread run();	
}

run()
{
	init_event();
//	level thread pre_4thattack_squad();		// guys across bridge
//	
//	trigger_wait( "p2shiparrival_crossramp_reached" );
//	level thread shiparrival_squad_to_nodes( "door8" ); // just outside the cargo bay
//	level thread shiparrival_vip_to_nodes( "door8" );
//	
//	trigger_wait( "p2shiparrival_door8_reached" );
//	simple_spawn( "pre_4thattack_second_squad_enemy" );	// at bottom of stairs
//	level thread shiparrival_squad_to_nodes( "door8combat" );
//	
//	guys = simple_spawn( "4thattack_enemy" );
//	for( i=0; i<guys.size; i++ )
//	{
//		guys[i] disable_long_death();
//		guys[i].goalradius = 24;
//	}
//	
//	remaining = guys.size;
//	while( remaining > 0 ) // wait for everybody to die
//	{
//		wait(1);
//		remaining = 0;
//		for( i=0; i<guys.size; i++ )
//		{
//			if( isalive(guys[i]) )
//				remaining++;
//		}
//	}
	//warp from first door -jc
	
	level thread shiparrival_squad_to_nodes( "door9" );
	
	level thread shiparrival_vip_to_nodes( "door9" );
	
	level thread shipcargo_objects();
	
	

	//level.shipsquad[0] waittill( "goal" ); // this is petrenko
	//flag_set( "P2SHIPCARGO_OBJECTIVE_TO_CARGO_DOOR" );
	
//	enable_trigger_with_targetname( "p2shipcargo_door_use" ); 
//	trig = getent( "p2shipcargo_door_use", "targetname" );
//	trig trigger_use_button( &"FULLAHEAD_USE_OPEN" );
//
//	trig delete();
	
	currentweapon = get_player() GetCurrentWeapon();
	level.default_light = "off";
	
	//fade out to hide warp
	fade_out( 0.1 );
	
	// relocate player to correct position
	player_to_struct( "shipcargo_door_objective" );
	
	//fade in
	wait 0.1;
	level thread fade_in( 0.3 );

	level thread player_open_door( "cargo" );
	
	//TUEY Set Music State to BOAT_ARRIVE
	level thread maps\_audio::switch_music_wait("BOAT_WALK", 3);
	//SOUND - Shawn J
	playsoundatposition("evt_hatch_door",(0,0,0));	
	
	wait(3);
	teleport_ship_squad( "door9" );
	level.default_light = "on";
	
	if( isdefined( currentweapon ) && currentweapon == level.flashlightWeapon )
	{
		player_flashlight_enable( true );
	}

	level waittill("player_door_opened" );
	
	flag_set( "P2SHIPCARGO_DOOR_OPENED" );

	level thread shiparrival_squad_to_nodes( "blackdoor" );
	wait(2);//stagger -jc
	level thread shiparrival_vip_to_nodes( "blackdoor" );
	
	get_player() setlowready( true );
	player_flashlight_enable( false );
	
	level thread shipcargo_steiner_drago_conversation();
	
	flag_wait( "P2SHIPCARGO_CINEMA_TRIGGERED" );
	level thread fade_out( 9, "black" );
	level.default_light = "off";
	player_open_door( "black" );
	
	//TUEY set music state to BLACK
	setmusicstate ("BLACK");
	
	get_player() thread gradiate_move_speed( 1.0 );	//return player speed to normal since we're about to have combat could be slower

	wait(5);
	cleanup();
	maps\fullahead_p2_shipcinema::run();
}

shipcargo_objects()
{
	//hide stuff that's in the way -jc
	gen = GetEnt( "cargohold_entry_gen_model", "targetname" );
	gen Hide();
	gen_clip = GetEntArray( "cargohold_entry_gen_clip", "targetname" );
	for( i = 0; i < gen_clip.size; i++ )
	{
		gen_clip[i] ConnectPaths();
		gen_clip[i] MoveZ( -1024, 0.1 );		
	}
	
	crate = GetEnt( "cargohold_entry_crate_model", "targetname" );
	crate Hide();
	crate_clip = GetEntArray( "cargohold_entry_crate_clip", "targetname" );
	for( i = 0; i < crate_clip.size; i++ )
	{
		crate_clip[i] ConnectPaths();
		crate_clip[i] MoveZ( -1024, 0.1 );	
	}
	
	flag_wait( "P2SHIPCARGO_CINEMA_TRIGGERED" );
	
	//return stuff for later -jc
	gen Show();
	for( i = 0; i < gen_clip.size; i++ )
	{
		gen_clip[i] MoveZ( 1024, 0.1 );		
	}
	crate Show();
	for( i = 0; i < crate_clip.size; i++ )
	{
		crate_clip[i] MoveZ( 1024, 0.1 );		
	}
	//crate_clip waittill( "movedone" );
	wait 1;
	
	for( i = 0; i < gen_clip.size; i++ )
	{
		gen_clip[i] DisconnectPaths();
	}
	for( i = 0; i < crate_clip.size; i++ )
	{
		crate_clip[i] DisconnectPaths();
	}
}


init_event()
{
	fa_print( "init p2 shipcargo\n" );
	
	//for performance
	get_player() SetClientDvar( "sm_sunSampleSizeNear", 0.5 );

	level.shipcargo_outro_trigger_objective_position = ent_origin( "p2shipcargo_outro" );
	disable_trigger_with_targetname( "p2shipcargo_outro" );
	
	level.pre_4th_attack_death_count = 0;
	level.pre_4th_attack_death_max = 1;
	
	explosives_in_place();
	
	autosave_by_name( "fullahead" );
}

// gets run through at start of level
init_flags()
{
	flag_init( "P2SHIPCARGO_BREADCRUMB1" );
	flag_init( "P2SHIPCARGO_OBJECTIVE_TO_CARGO_DOOR" );
	flag_init( "P2SHIPCARGO_DOOR_OPENED" );
	flag_init( "P2SHIPCARGO_CINEMA_TRIGGER_ENABLED" );
	flag_init( "P2SHIPCARGO_CINEMA_TRIGGERED" );
	maps\fullahead_p2_shipcinema::init_flags();
}

cleanup()
{
	fa_print( "cleanup p2 shipcargo\n" );
	get_player() setlowready(false);
	
	if( isDefined(level.shipsquad) ) // might not in some skipto situations
	{
		for( i=0; i<level.shipsquad.size; i++ )
		{
			if( isDefined(level.shipsquad[i]) )
				level.shipsquad[i] delete();
		}
	}
	
	if( isDefined(level.steiner) )
		level.steiner delete();
	if( isDefined(level.dragovich) )
		level.dragovich delete();
	if( isDefined(level.kravchenko) )
		level.kravchenko delete();
		
	drones = getentarray( "shiparrival_outside_drone", "script_noteworthy" ); // just in case
	for( i=0; i<drones.size; i++ )
	{
		if( isdefined(drones[i]) )
			drones[i] delete();	
	}
}

objectives( main_obj_num )
{
//	objective_position( main_obj_num, ent_origin("shipcargo_breadcrumb1") );
//	objective_set3d( main_obj_num, true );
//
//	flag_wait( "P2SHIPCARGO_BREADCRUMB1" );
//	objective_add( main_obj_num, "active", &"FULLAHEAD_OBJ_SHIPCARGO_CUTDOOR" );
//	objective_position( main_obj_num, ent_origin("shipcargo_door_objective") );
//	objective_set3d( main_obj_num, true );
//	
//	flag_wait( "P2SHIPCARGO_OBJECTIVE_TO_CARGO_DOOR" );
//	objective_position( main_obj_num, ent_origin("shipcargo_door_objective") );
//	objective_set3d( main_obj_num, true ); // , "default", &"FULLAHEAD_MARKER_OPEN"
	
	flag_wait( "P2SHIPCARGO_DOOR_OPENED" );
	objective_set3d( main_obj_num, false );
	
	flag_wait( "P2SHIPCARGO_CINEMA_TRIGGER_ENABLED" );
	objective_position( main_obj_num, level.shipcargo_outro_trigger_objective_position );
	objective_set3d( main_obj_num, true ); // , "default", &"FULLAHEAD_MARKER_OPEN"
	
	flag_wait( "P2SHIPCARGO_CINEMA_TRIGGERED" );
	objective_state( main_obj_num, "done" );

	maps\fullahead_p2_shipcinema::objectives( main_obj_num + 1 );
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

krav_sanity_check()
{
	level endon( "P2SHIPCARGO_CINEMA_TRIGGERED" );
	
	while(true)
	{
		if( self.origin[2] < 0 )
		{
			fa_print( "Kravchenko fell through world!  Position: " + self.origin );
		}
		
		wait(0.5);
	}
}

pre_4thattack_squad()
{	
	// send in backup ambush
	//array_thread( getentarray( "pre_4thattack_enemy_spawner", "script_noteworthy" ), ::add_spawn_function,::pre_4thattack_enemy_spawner_death_counter );
	//simple_spawn( "pre_4thattack_enemy" );	
		
	level waittill( "pre_4thattack_enemy_death_count_reached" );
	send_to_retreat_node( "pre_4thattack_enemy_spawner", "script_noteworthy", "p2shiparrival_door8_02");
}

pre_4thattack_enemy_spawner_death_counter()
{
	level endon( "pre_4thattack_enemy_death_count_reached" );	
	
	// backup should have target their nodes
	node = GetNode( self.target, "targetname" );
	self thread force_goal( node, 128 );
	
	self waittill("death");
	level.pre_4th_attack_death_count++;
	if( level.pre_4th_attack_death_count >= level.pre_4th_attack_death_max )	
	{
		level notify( "pre_4thattack_enemy_death_count_reached" );	
	}		
}

shipcargo_steiner_drago_conversation()
{
//     level.scr_sound["Dragovich"]["ch1"] = "vox_ful1_s04_087A_drag"; //However effective your Nova 6 chemical may be, you still had to find a way to unleash it...
//     level.scr_sound["Steiner"]["ch2"] = "vox_ful1_s04_088A_stei"; //Long range V2 rockets... to be launched from this outpost.
//     level.scr_sound["Steiner"]["ch3"] = "vox_ful1_s04_089A_stei"; //The targets were command and control centers. Washington DC was our first target... Then Moscow...
//     level.scr_sound["Dragovich"]["ch4"] = "vox_ful1_s04_090A_drag"; //Mmmm... Ambitious and commendable, Herr Steiner...
//     level.scr_sound["Steiner"]["ch5"] = "vox_ful1_s04_091A_stei"; //But we were too late. The British were upon us, and their bombers crippled this ship.
//     level.scr_sound["Steiner"]["ch6"] = "vox_ful1_s04_092A_stei"; //Locked in the ice... We tried to salvage what could, but it was too late...

	
//     level.scr_sound["Steiner"]["ch7"] = "vox_ful1_s04_093A_stei"; //Before we could initiate our first strike we heard the news -
//     level.scr_sound["Steiner"]["ch8"] = "vox_ful1_s04_094A_stei"; //Germany had surrendered, and a Russian flag flew over Berlin.
//     level.scr_sound["Steiner"]["ch9"] = "vox_ful1_s05_095A_stei"; //The SS had orders to destroy the ship if we were attacked.
//     level.scr_sound["Kravchenko"]["ch10"] = "vox_ful1_s05_096A_krav"; //Clearly, they failed...
//     level.scr_sound["Kravchenko"]["ch11"] = "vox_ful1_s05_097A_krav"; //The explosives were never activated.
//     level.scr_sound["Steiner"]["ch12"] = "vox_ful1_s05_098A_stei"; //This is it...
//     level.scr_sound["Dragovich"]["ch13"] = "vox_ful1_s05_099A_drag"; //Reznov - open the door.
	
	
	level endon( "P2SHIPCARGO_CINEMA_TRIGGERED" );
	
	//level.kravchenko setgoalnode_tn( "cargobay_krav_intermediate" ); // should be "cargobay_krav_intermediate", but an all-day convert means it's this temporarily
	//level.kravchenko.goalradius = 64;
	
	level.dragovich anim_single( level.dragovich, "ch1", "Dragovich" );
	level.steiner anim_single( level.steiner, "ch2", "Steiner" );
	level.steiner anim_single( level.steiner, "ch3", "Steiner" );
	level.dragovich anim_single( level.dragovich, "ch4", "Dragovich" );
	level.steiner anim_single( level.steiner, "ch5", "Steiner" );
	level.steiner anim_single( level.steiner, "ch6", "Steiner" );
	
	wait(1);
	//level.steiner anim_single( level.steiner, "ch7", "Steiner" );
	level.steiner anim_single( level.steiner, "ch8", "Steiner" );
	level.steiner anim_single( level.steiner, "ch9", "Steiner" );

// send krav right to node
//	level.kravchenko setgoalnode_tn( "cargobay_bomb_lookat" );
//	level.kravchenko.goalradius = 32;
//	level.kravchenko waittill( "goal" );
//	level.kravchenko allowedstances( "crouch" );

	//wait(1);
	level.kravchenko anim_single( level.kravchenko, "ch10", "Kravchenko" );
	level.kravchenko anim_single( level.kravchenko, "ch11", "Kravchenko" );
	
	wait(1);	
	level.steiner anim_single( level.steiner, "ch12", "Steiner" );
	level.dragovich anim_single( level.dragovich, "ch13", "Dragovich" );
	
	level.steiner notify( "stop_breath" );
	level.dragovich notify( "stop_breath" );
	get_player() notify("stop_breath");

	level thread shipcargo_outrocinema();

}


//self is level
shipcargo_outrocinema()
{
	enable_trigger_with_targetname( "p2shipcargo_outro" );
	flag_set( "P2SHIPCARGO_CINEMA_TRIGGER_ENABLED" );
	
	trigger = getent( "p2shipcargo_outro", "targetname" );
	trigger trigger_use_button( &"FULLAHEAD_USE_OPEN" );
	trigger delete();
	
	//SOUND - Shawn J
	playsoundatposition("evt_hatch_door",(0,0,0));	
	
	flag_set( "P2SHIPCARGO_CINEMA_TRIGGERED" );
}
