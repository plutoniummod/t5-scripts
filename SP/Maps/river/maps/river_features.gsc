
/*===========================================================================
RIVER FEATURES
 functions that control general features or events in the River Level
===========================================================================*/

#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;


//*****************************************************************************
// Boat Control Messages
//*****************************************************************************

print_boat_controls()
{
	level.woods endon( "death" );
	level.bowman endon( "death" );


	//*****************************************************************
	//*** Setup
	//*****************************************************************

	message_delay = 7;
	message_delay_quick = 2.0;		// 4

	delay_between_messages = 6;

	level thread check_player_boat_buttons();

	wait( 0.1 );


	//*****************************************************************
	//*** Use LSTICK and RSTICK to control the boat
	//*****************************************************************

	level thread reznov_boat_start_vo();

	wait( 5 );
	
	screen_message_create( &"PLATFORM_BOAT_INSTRUCTION_1", &"PLATFORM_CONTROLS_RSTICK" );
	wait( message_delay );
	screen_message_delete();


	//*****************************************************************
	// *** Misc VO about an enemy camp ahead
	//*****************************************************************

	level.player maps\river_util::wait_to_reach_struct( "vo_rtrig_machine_gun", 1100, (-26272, -58744, 0) );

	// Do nothing because if the player rushes here the intro anim will still be saying stuff
	
	//level.woods thread maps\river_vo::playVO_proper( "enemy_contact_dead_ahead", 4.2 );	// 4.2
	//level.woods thread maps\river_vo::playVO_proper( "remember_what_i_said", 5 );			// 5


	//*****************************************************************
	// *** Tell the player about the Enemy Camp ahead
	//*****************************************************************

	level.player maps\river_util::wait_to_reach_struct( "vo_ltrig_missiles", 1100, (-26272, -58744, 0) );

	//num_missiles_fired = level.woods.num_missiles_fired + level.bowman.num_missiles_fired;

	level.woods thread maps\river_vo::playVO_proper( "heads_up_enemy_camp_ahead", 3.75 );	// 1.5
	//level.woods thread maps\river_vo::playVO_proper( "remember_what_i_said", 3.5 );			// 5

	wait( 9 );


	//**********************************************************************
	// *** Tell the player RTRIG to fire the machine gun
	// *** Leave the message on screen until the player has fires the weapon
	//**********************************************************************

	start_time = GetTime();

	screen_message_create(&"RIVER_CONTROLS_RTRIG");
	level.reznov thread maps\river_vo::playVO_proper( "mason_fire_your", 0.5 );
	
	weapon_used = 0;
	while( 1 )
	{
		// Has the player fired the machine gun?
		if( level.player isWeaponOverheating(1) )
		{
			weapon_used = 1;
		}
		
		// Have we waited the minumum message time?
		if( weapon_used )
		{
			time = GetTime();
			dt = ( time - start_time ) / 1000;
			if( dt >= message_delay_quick )
			{
				break;
			}
		}

		// Turn off after Boss Fight
		if( flag( "boss_boat_killed" ) == true )
		{
			screen_message_delete();
			return;
		}

		wait( 0.01 );
	}
	
	screen_message_delete();

	// Reset the reminder
	level.player_has_used_primary_fire = 0;


	//*****************************************************************
	// *** Tell the player LTRIG to fire Missiles
	//*****************************************************************

	wait( delay_between_messages );

	screen_message_create( &"RIVER_CONTROLS_FIRE_MISSILES" );
	level.bowman thread maps\river_vo::playVO_proper( "we_have_4_shots", 0.2 );

	missiles_fired_at_start = level.woods.num_missiles_fired + level.bowman.num_missiles_fired;

	start_time = GetTime();

	weapon_used = 0;
	while( 1 )
	{
		num_missiles = level.woods.num_missiles_fired + level.bowman.num_missiles_fired;

		// Has the player fired the machine gun?
		if( num_missiles > missiles_fired_at_start )
		{
			weapon_used = 1;
		}
		
		// Have we waited the minumum message time?
		if( weapon_used )
		{
			time = GetTime();
			dt = ( time - start_time ) / 1000;
			if( dt >= message_delay_quick )
			{
				break;
			}
		}

		// Turn off after Boss Fight
		if( flag( "boss_boat_killed" ) == true )
		{
			screen_message_delete();
			return;
		}

		wait( 0.01 );
	}
	
	screen_message_delete();
	
	// Reset the reminder
	level.reminder_num_missiles_fired = level.woods.num_missiles_fired + level.bowman.num_missiles_fired;
	

	//**************************************************
	// *** WAIT UNTIL WE REACH THE ADS SCRIPT SCRUCT ***
	//**************************************************

	wait( delay_between_messages );

	//level.mason thread maps\river_vo::playVO_proper( "tower_up_ahead", 0.5 );

	screen_message_create( &"RIVER_CONTROLS_ADS" );
	
	start_time = GetTime();

	level.player_has_used_ads = 0;
	

	//**********************************************************************
	// If ADS is Active we need 1 click to turn it off
	// If ADS is NOT Active we need 2 clicks, 1 to turn on and 1 to turn off
	//**********************************************************************
	
	if( isdefined(level.ads_active) && (level.ads_active==1) )
	{
		num_ads_uses = 1;
	}
	else
	{
		num_ads_uses = 0;
	}
	
	
	//*************************************************
	//*************************************************
	
	while( 1 )
	{
		// The player has to use the ADS button twice to remoce the message
		if( level.player_has_used_ads )
		{
			num_ads_uses++;
			level.player_has_used_ads = 0;
		}
		// Have we waited the minumum message time?
		if( num_ads_uses > 1 )
		{
			time = GetTime();
			dt = ( time - start_time ) / 1000;
			if( dt >= message_delay_quick )
			{
				break;
			}
		}
		
		// Turn off after Boss Fight
		if( flag( "boss_boat_killed" ) == true )
		{
			screen_message_delete();
			return;		
		}

		wait( 0.01 );
	}

	screen_message_delete();

	// Reset the reminder
	level.player_has_used_ads = 0;
	

	//****************************************************************************
	// Check after 1 minute to see if the user has worked out how to fire missiles
	//****************************************************************************

	boat_controls_reminder_prompts();
}


//*****************************************************************************
//*****************************************************************************

reznov_boat_start_vo()
{
	level waittill( "intro_animation_finished" );

//	IPrintLnBold("STATING VEHICLE");

//	level.mason thread maps\river_vo::playVO_proper( "what_about_reznov", 0 );
//	level.woods thread maps\river_vo::playVO_proper( "what_did_you_say", 1.7 );
//	level.reznov thread maps\river_vo::playVO_proper( "ill_watch_for_snipers", 3.2 );
}


//*****************************************************************************
// Messages and VO to remind the player to use primary boat features:-
// - RTRIG for primary weapon
// - LTRIG to fire missiles
// - ADS button
//*****************************************************************************

boat_controls_reminder_prompts()
{
	level endon( "boss_boat_destroyed" );


	//***************
	// init the hints
	//***************

	hints = [];
	for( i=0; i<3; i++ )
	{
		hints[i] = spawnstruct();
		hints[i].active = 1;
		hints[i].time = 0;
		hints[i].num_displayed = 0;
	}
	
		
	/**********************************************/
	/* Wait for a bit before giving the reminders */
	/**********************************************/
	
	wait( 90 );		// 50
//wait( 20 );	
//IPrintLnBold("HINT CHECKS");
	
	message_delay = 5;
	max_display_reminders = 1;
	
	num_active = 1;
	while( num_active )
	{
		// If we are past the boss boat, no more reminders
		if( flag("boss_boat_killed") == true )
		{
			return;
		}
		
		// Which ever hint has the greatest time delta, use that hint
		time = GetTime();
	
		index = -1;
		current_time = 0;

		
		//*******************************************
		// Check if any of the hints are still needed
		//*******************************************

		// HINT 0: Has Primary Fire been Used?
		if( hints[0].active == 1 )
		{
			if(	level.player_has_used_primary_fire )
			{
				hints[0].active = 0;
			}
			else
			{
				dt = time - hints[0].time;
				if( dt > current_time )
				{
					current_time = dt;
					index = 0;
				}
			}
		}

		// HINT 1: Has Woods or Bowman fired?
		if( hints[1].active == 1 )
		{
			num_missiles_fired = level.woods.num_missiles_fired + level.bowman.num_missiles_fired;
			if( num_missiles_fired > level.reminder_num_missiles_fired )
			{
				hints[1].active = 0;
			}
			else
			{
				dt = time - hints[1].time;
				if( dt > current_time )
				{
					current_time = dt;
					index = 1;
				}
			}
		}

		// HINT 2: Has the player been using the ADS button?
		if( hints[2].active == 1 )
		{
			if(	level.player_has_used_ads )
			{
				hints[2].active = 0;
			}
			else
			{
				dt = time - hints[2].time;
				if( dt > current_time )
				{
					current_time = dt;
					index = 2;
				}
			}
		}
		

		//****************************
		// We have a candidate message
		//****************************

		if( index >= 0 )
		{
			hints[index].time = time;
			hints[index].num_displayed++;
		}

	
		//*************************
		// *** DISPLAY THE HINT ***
		//*************************
		
		switch( index )
		{
			// Primary Fire hint
			case 0:
				screen_message_create( &"RIVER_CONTROLS_RTRIG" );
			break;

		
			// Woods missile hint
			case 1:
				screen_message_create( &"RIVER_CONTROLS_FIRE_MISSILES" );
				rval = randomint( 4 );
				if( rval == 0 )
				{
					level.woods thread maps\river_vo::playVO_proper( "mason_call_out_targets", 0.15 );
				}
				else if( rval == 1)
				{
					level.woods thread maps\river_vo::playVO_proper( "tell_me_where_to_fire", 0.15 );
				}
				else if ( rval == 2 )
				{
					level.woods thread maps\river_vo::playVO_proper( "im_waiting_for_your_signal", 0.15 );
				}
				else
				{
					level.woods thread maps\river_vo::playVO_proper( "reloaded_and_ready", 0.15 );
				}
			break;
			
			// ADS hint
			case 2:
				screen_message_create( &"RIVER_CONTROLS_ADS" );
			break;

		}
		
		wait( message_delay );
		screen_message_delete();


		//*************************************
		// Are there any hints left to display?
		//*************************************

		num_active = 0;
		for( i=0; i<hints.size; i++ )
		{
			if( hints[i].active )
			{
				if( hints[i].num_displayed >= max_display_reminders )
				{
					hints[i].active = 0;
				}
				else
				{
					num_active++;
				}
			}
		}
		
		// Wait for a while before we send another reminder
		wait( 30 );
//wait( 4 );
	}

	//IPrintLnBold("HINTS FINISHED");
}


//*****************************************************************************
// self = level
//*****************************************************************************

check_player_boat_buttons()
{
	level.player_has_used_primary_fire = 0;

	num_overheats = 0;

	while( 1 )
	{
		// Check for primary fire button
		if( !level.player_has_used_primary_fire )
		{
			overheat_val = ( level.player isWeaponOverheating(1) );
			if( overheat_val )
			{
				num_overheats++;
				if( num_overheats > 8 )
				{
					level.player_has_used_primary_fire = 1;
				}
			}
		}
		
		wait( 0.1 );
		
		// Are we done checking buttons?
		if( flag("boss_boat_started") == true )
		{
			break;
		}
	}
}


//*****************************************************************************
// SCRIPT_DELETE: Kills a drone on a node and falls into ragdoll
// SCRIPT_DEATH: Kills a drone and deletes, more efficeint, skips ragdoll
//*****************************************************************************

init_drones()
{
	// detail drone
	// These are called everytime a drone is spawned in to set up the character.
	level.drone_spawnFunction["allies"] = ::allied_drone_spawn_wrapper; 
	//level.drone_spawnFunction["axis"] = character\c_vtn_nva1::main;
	
	// cheaper drone
	//level.drone_spawnFunction["axis"] = character\c_vtn_nva1_drone::main;
	level.drone_spawnFunction_passNode = true; //-- makes _drone pass the first struct of the drone path into the spawn function
	level.drone_spawnFunction["axis"] = ::axis_drone_spawn;
	
	// precache drone models
	character\c_vtn_vc2_drone::precache();
	character\c_usa_jungmar_drone::precache();

	//level.drone_spawnFunction["allies"] = character\c_usa_jungmar_drone::main;
	//character\c_usa_jungmar_drone::precache();

	setup_drones();

	// Drones Init
	maps\_drones::init();	
}


//*****************************************************************************
//*****************************************************************************

allied_drone_spawn_wrapper( node )
{
	self character\c_usa_jungmar_drone::main();
}


//*****************************************************************************
//*****************************************************************************

setup_drones()
{
	level.max_drones = [];
	level.max_drones["axis"] = 100; 
	level.max_drones["allies"] = 100;
}


//*****************************************************************************
//-- Glocke: added to help "robustify" the drone spawn system to control levels of detail
//*****************************************************************************

axis_drone_spawn( start_struct )
{
	//The start_struct that gets passed in is the starting struct for that particular drone path
	
	if( IsDefined(start_struct.script_string) && start_struct.script_string == "high_detail") //-- whatever condition you want, i'd suggest putting a script_string or something on the first struct
	{
		self character\c_vtn_vc2::main();
		self.burn_drone = true;
	}
	else if( IsDefined(start_struct.script_string) && start_struct.script_string == "high_detail_swap")
	{
		self character\c_vtn_vc2::main();
		self.burn_drone = true;
		self.can_swap = true;
	}
	else
	{
		self character\c_vtn_vc2_drone::main();
		self.burn_drone = false;
		self.can_swap = false;
	}
}


//*****************************************************************************
// Setup a bunch of threads that show the background movement of the:-
//	- Drones
//	- Vehicles
//	- Missile launchers
//*****************************************************************************

start_boat_drive_background_drones()
{
	level.intro_drive_finished = 0;

	// The moving vehicles
	level thread intro_vehicles_start_moving();

	// The drone waves
	level thread maps\river_features::start_intro1_drones();
	level thread maps\river_features::start_intro2_drones();
	level thread maps\river_features::start_intro3_drones();
	level thread maps\river_features::start_intro4_drones();
	
	level thread maps\river_features::start_intro5_drones();

	// The mortars that attack the drones and vehicles

	//level thread intro_enemy_mortar_attacks();
}



//*****************************************************************************
//*****************************************************************************

intro_vehicles_spawn()
{
	// Create Intro Vehicles
	maps\_vehicle::scripted_spawn( 9001 );
	
	maps\_vehicle::scripted_spawn( 9002 );
	
	maps\_vehicle::scripted_spawn( 9003 );

	maps\_vehicle::scripted_spawn( 9004 );
	
	maps\_vehicle::scripted_spawn( 9005 );

	maps\_vehicle::scripted_spawn( 9006 );
	
	wait( 0.1 );
	
	for( i=0; i<6; i++ )
	{
		name = "start_convoy_truck_" + (i+1);
		veh = GetEnt( name, "targetname");
		playfxOnTag( level._effect["truck_headlight"], veh, "tag_headlight_left" );
		playfxOnTag( level._effect["truck_headlight"], veh, "tag_headlight_right" );
		
		veh.health = 999999;
		veh thread maps\river_util::friendly_fire_checker();
	}
}


//*****************************************************************************
// VEHICLES: Driving along a spling in the opening boat drive
//
// Vehicle Spawner use:-
//	- script_vehiclespawngroup <group num>
//	- target <1st node>
//	- script_vehiclestartmove <group num>		** may not need this if the start node is targetted**
//	- vehicletype <defined the vehicle>
//
//*****************************************************************************

intro_vehicles_start_moving()
{
	//maps\_vehicle::create_vehicle_from_spawngroup_and_gopath( 9001 );
	vehicle_ent = GetEnt( "start_convoy_truck_1", "targetname");
	vehicle_ent thread maps\_vehicle::gopath();
	vehicle_ent thread vehicle_drive_and_die_at_path_end();
	
	//maps\_vehicle::create_vehicle_from_spawngroup_and_gopath( 9002 );
	vehicle_ent = GetEnt( "start_convoy_truck_2", "targetname");
	vehicle_ent thread maps\_vehicle::gopath();
	vehicle_ent thread vehicle_drive_and_die_at_path_end();
	
	//maps\_vehicle::create_vehicle_from_spawngroup_and_gopath( 9003 );
	vehicle_ent = GetEnt( "start_convoy_truck_3", "targetname");
	vehicle_ent thread maps\_vehicle::gopath();
	vehicle_ent thread vehicle_drive_and_die_at_path_end();
	
	//maps\_vehicle::create_vehicle_from_spawngroup_and_gopath( 9004 );
	vehicle_ent = GetEnt( "start_convoy_truck_4", "targetname");
	vehicle_ent thread maps\_vehicle::gopath();
	vehicle_ent thread vehicle_drive_and_die_at_path_end();
	
	//maps\_vehicle::create_vehicle_from_spawngroup_and_gopath( 9005 );
	vehicle_ent = GetEnt( "start_convoy_truck_5", "targetname");
	vehicle_ent thread maps\_vehicle::gopath();
	vehicle_ent thread vehicle_drive_and_die_at_path_end();
	
	//maps\_vehicle::create_vehicle_from_spawngroup_and_gopath( 9006 );
	vehicle_ent = GetEnt( "start_convoy_truck_6", "targetname");
	vehicle_ent thread maps\_vehicle::gopath();
	vehicle_ent thread vehicle_drive_and_die_at_path_end();
}


//*****************************************************************************
// self = vehicle
//*****************************************************************************

vehicle_drive_and_die_at_path_end()
{
	self waittill("reached_end_node");
	self Delete();
}


//*****************************************************************************
// Mortar_warning_intro( guns )
//*****************************************************************************

intro_enemy_mortar_attacks()
{
	wait( 14 );

	while( !level.intro_drive_finished )
	{
		start_pos = (-12036, -57582, 878 );
		
		end_pos = [];
		end_pos[ end_pos.size ] = ( -21383, -57432, 280 );
		end_pos[ end_pos.size ] = ( -22228, -57586, 144 );
		end_pos[ end_pos.size ] = ( -24011, -57307, 0 );
		end_pos[ end_pos.size ] = ( -25593, -57166, 0 );

		index = randomint( end_pos.size );
		
		height = randomfloatrange( 2.2, 2.6 );
		
		level thread maps\river_drive::fire_river_missile( start_pos, end_pos[index], 1.5, height, 42, 0 );

		wait_min = 3;
		wait_max = 6;
		
		wait( randomintrange( wait_min, wait_max) );
	}
}


//*****************************************************************************
// get_drone_spawn_trigger( <script_string> )
//		<script_string> - SCRIPT_STRING - Used to define individual drone triggers within axis or allies
//
// NOTES: TARGETNAME is either "drone_axis" or "drone_allies"
//*****************************************************************************

get_drone_spawn_trigger( string_name )
{
	AssertEx( IsDefined(string_name), "script_string not defined" );

	drone_trigger = undefined;
	
	// Search for the drone trigger TARGETNAME as "drone_axis" or "drone_allies"
	for( i=0; i<2; i++ )
	{
		if( !i )
		{
			drone_trigger_array = GetEntArray( "drone_axis", "targetname" );
		}
		else
		{
			drone_trigger_array = GetEntArray( "drone_allies", "targetname" );
		}
		
		if( isdefined( drone_trigger_array ) )
		{
			// Looking for script string because drone kvps need targetname and noteworthy for parameter settings
			for( j=0; j<drone_trigger_array.size; j++ )
			{
				if( drone_trigger_array[j].script_string == string_name )
				{
					drone_trigger = drone_trigger_array[j];
					break;
				}
			}
		}
	}

	AssertEx( isdefined( drone_trigger ), "Can't find drone trigger" );

	return( drone_trigger );
}


//*****************************************************************************
// intro1_drones()
//*****************************************************************************

start_intro1_drones()
{
	drones = maps\river_features::get_drone_spawn_trigger( "drone_trigger_intro1_guys" );
	drones activate_trigger();

	drones_active = 1;

	test_struct = getstruct( "drones1_end_struct", "targetname" );
	struct_forward = AnglesToForward( test_struct.angles );

	while( !level.intro_drive_finished )
	{
		//************************************************************************
		// If the drones are active, when we past the test_struct, switch them off
		//************************************************************************
		
		if( drones_active )
		{
			//IPrintLnBold("DRONES 1 - Active");
		
			forward = vectornormalize( test_struct.origin - level.player.origin );
			dot = vectordot( forward, struct_forward );
			if( dot < 0.0 )
			{
				drones_active = 0;
				drones Delete();
			}
		}
	
		//************************************************************************
		// We may want to switch the drones back on if the player drives backwards
		//************************************************************************
		else
		{
			//IPrintLnBold("DRONES 1 - Not Active");
			break;
		}

		//wait( 0.25 );
		
		wait( 1.5 );
	}


	//********************************************************
	// Exiting, of the droens are active, kill off the spawner
	//********************************************************

	if( drones_active )
	{
		drones Delete();
		drones_active = 0;
	}
	
	//IPrintLnBold("DRONES 1 - Thats It");
}


//*****************************************************************************
// intro2_drones()
//*****************************************************************************

start_intro2_drones()
{
	drones = maps\river_features::get_drone_spawn_trigger( "drone_trigger_intro2_guys" );
	drones activate_trigger();

	while( !level.intro_drive_finished )
	{
		wait( 0.3 );
	}
		
	drones Delete();
}


//*****************************************************************************
// intro2_drones()
//*****************************************************************************

start_intro3_drones()
{
	drones = maps\river_features::get_drone_spawn_trigger( "drone_trigger_intro3_guys" );
	drones activate_trigger();

	while( !level.intro_drive_finished )
	{
		wait( 0.3 );
	}
	
	drones Delete();
}


//*****************************************************************************
// intro4_drones()
//*****************************************************************************

start_intro4_drones()
{
	drones = maps\river_features::get_drone_spawn_trigger( "drone_trigger_intro4_guys" );
	drones activate_trigger();

	// Wait for the boats to reach the initial engagement, then kill off these drones
	trigger = GetEnt( "initial_island_engagement_starts", "targetname" );
	trigger waittill( "trigger" );

	wait( 5 );

	drones Delete();
	
	level.intro_drive_finished = 1;
}


//*****************************************************************************
// intro5_drones()
//*****************************************************************************

start_intro5_drones()
{
	drones_active = 0;
	drones = undefined;

	test_struct = getstruct( "drones1_end_struct", "targetname" );
	struct_forward = AnglesToForward( test_struct.angles );

	while( !level.intro_drive_finished )
	{
		forward = vectornormalize( test_struct.origin - level.player.origin );
		dot = vectordot( forward, struct_forward );
	
		if( drones_active )
		{
			//IPrintLnBold("DRONES 5 - Active");
			if( dot > 0.0 )
			{
				drones Delete();
				drones_active = 0;
				break;
			}
		}
		else
		{
			//IPrintLnBold("DRONES 5 - Not Active");
			if( dot < 0.0 )
			{
				drones = maps\river_features::get_drone_spawn_trigger( "drone_trigger_intro5_guys" );
				drones activate_trigger();
				drones_active = 1;
			}
		}
		
		wait( 0.25 );
	}

	if( drones_active )
	{
		drones Delete();
		drones_active = 0;
	}
	
	//IPrintLnBold("DRONES 5 - Thats It");
}


//*****************************************************************************
// first_island_drones()
//*****************************************************************************

first_island_drones()
{
	// Wait for the boats to reach the initial engagement
	trigger = GetEnt( "initial_island_engagement_starts", "targetname" );
	trigger waittill( "trigger" );

	level.river_drones_trigger = maps\river_features::get_drone_spawn_trigger( "drone_trigger_1st_island" );
	level.river_drones_trigger activate_trigger();
	
	// Once the missile launch objective starts, kill off these drones
	flag_wait( "missile_launcher_engagement_started" );

	level.river_drones_trigger Delete();
}


//*****************************************************************************
// missile_attack_drones_group1()
//*****************************************************************************

missile_attack_drones_group1()
{
	level.missile_drones_group1 = maps\river_features::get_drone_spawn_trigger( "drone_trigger_missile_guys1" );
	level.missile_drones_group1 activate_trigger();
	
	// Wait unril all three missile threats have been destroyed
	level waittill( "river_mortar_objective_complete" );	

	level.missile_drones_group1 Delete();
}


//*****************************************************************************
// missile_attack_drones_group2()
//*****************************************************************************

missile_attack_drones_group2()
{
	level.missile_drones_group2 = maps\river_features::get_drone_spawn_trigger( "drone_trigger_missile_guys2" );
	level.missile_drones_group2 activate_trigger();
	
	// Wait unril all three missile threats have been destroyed
	level waittill( "river_mortar_objective_complete" );	

	level.missile_drones_group2 Delete();
}


//*****************************************************************************
// bridge_destroyed_by_helicopters_drones_start()
//*****************************************************************************

bridge_destroyed_by_helicopters_drones_start()
{
	drones = maps\river_features::get_drone_spawn_trigger( "drone_trigger_helicopters_blowup_bridge" );
	drones activate_trigger();

	// Wait for a bit
	wait( 25 );
	
	drones Delete();
}


//*****************************************************************************
// aa_gun_destroys_friendly_drones_start()
//*****************************************************************************

aa_gun_destroys_friendly_drones_start()
{
	// Wait to start the drones
	wait( 10 );

	drones = maps\river_features::get_drone_spawn_trigger( "drone_trigger_aa_gun_guys" );
	drones activate_trigger();

	wait( 50 );

	drones Delete();
}


//*****************************************************************************
// 
//*****************************************************************************

run_to_bridge_drones_drones_start()
{
	drones = maps\river_features::get_drone_spawn_trigger( "drone_trigger_run_to_bridge_guys" );
	drones activate_trigger();

	wait( 25 );		// 20

	drones Delete();
}


//*****************************************************************************
// Drones running accross the bridge
//*****************************************************************************

bridge_drones_start()
{
	drones = maps\river_features::get_drone_spawn_trigger( "drone_trigger_bridge_guys" );

	// Wait for the player to get in range to activate the drones running over the bridge
	player = get_players()[0];
	while( 1 )
	{
		dist = Distance( player.origin, drones.origin );
		
		if( dist < 14000 )
		{
			break;
		}
		wait( 1.1 );
	}

	// Checks for player damaging the bridge
	level thread bridge_damage_trigger();

	// Activate drone trigger
	drones activate_trigger();

	// Drones run for X seconds (unless bridge is blownup)
	drone_total_time = 45;
	start_time = GetTime();
	while( 1 )
	{
		time = GetTime();
		dt = (time - start_time) / 1000;
		if( dt > drone_total_time )
		{
			break;
		}

		// Has the bridge been blown up?
		if( isdefined(level.woodbridge_destroyed) )
		{
			if( level.woodbridge_destroyed )
			{
				break;
			}
		}
		
		wait( 0.15 );
	}
	
	// Has the bridge been blown up?
	if( level.woodbridge_destroyed )
	{
		level notify( "woodbridge_explosion_start" );
	}
	
	drones Delete();
}


//*****************************************************************************
//*****************************************************************************

bridge_damage_trigger()
{
	bridge_trigger = GetEnt( "drone_bridge_damage_trigger", "targetname" ); 
	bridge_trigger.bridge_health = 700;	// 2000
	
	// Player boat is also allowed to attack bridge
	boat_attacker = GetEnt( "player_controlled_boat", "targetname" ); 
	woods_attacker = GetEnt( "woods_ai", "targetname" );
	
	// We have to use a fake sciprt_brushmodel, so the damage trigger will work
	bridge_fake_collision_box = GetEnt( "drone_bridge_fake_collision", "targetname" ); 
		
	while( 1 )
	{
		bridge_trigger waittill( "damage", amount, attacker, direction, point, dmg_type, modelName, tagName );
		//bridge_trigger waittill( "trigger", attacker );

		// Don't let the players machine gun damage the bridge
		if( isdefined(dmg_type) && (dmg_type == "MOD_RIFLE_BULLET") )
		{
			amount = 0;
		}
			
		// Is it the players gun damaging the bridge?
		if( isplayer( attacker ) 
			|| ( isdefined( attacker.targetname ) 
			&& ( ( attacker.targetname == "woods_ai" ) || ( attacker.targetname == "bowman_ai" ) ) ) )
		{
			// Hack, its to stop the bow gunner from damaging the trigger
			// We cound use modelname - todo
			if( amount > 20 )
			{	
				bridge_trigger.bridge_health -= amount;
			}
		}
		// Is it the players "special" missile attacking the boat?
		else if( isdefined(boat_attacker) && ( (boat_attacker == attacker) || ( woods_attacker == attacker ) ) )
		{
			bridge_trigger.bridge_health -= amount;
			level thread maps\river_util::PlayFxTimed( level._effect["quad50_temp_death_effect"], point, 1.5 );
			//PlayFX( level._effect[ "quad50_temp_death_effect" ], point, AnglesToForward( bridge_trigger.angles ) );
			playSoundAtPosition( "shell_explode_default", point );
		}
			
		// Has the bridge been destroyed
		if( bridge_trigger.bridge_health <= 0 )
		{
			break;
		}
	}

	level notify("woodbridge_explosion_start");
	
	wait( 0.1 );
	
	level.reznov thread maps\river_vo::playVO_proper( "watch_them_burn", 0.3 );
	
	bridge_fake_collision_box delete();
	bridge_trigger delete();
}


//*****************************************************************************
//*****************************************************************************

aa_gun2_friendly_drones_start()
{
	wait( 20 );

	drones = maps\river_features::get_drone_spawn_trigger( "drone_trigger_aa_gun2_friendly_guys" );
	drones activate_trigger();

	wait( 50 );

	drones Delete();
}


//*****************************************************************************
//*****************************************************************************

sanpan_fallback_drones_start()
{
	drones = maps\river_features::get_drone_spawn_trigger( "drone_trigger_sanpan_fallback_guys" );
	drones activate_trigger();

	// use this trigger to stop the drones
	start_trigger = GetEnt("s_curve_bend_2_trigger", "targetname");
	start_trigger waittill("trigger");

	wait( 3 );

	drones Delete();
}


//*****************************************************************************
// Deletes Trees and associated threads with specified "script_int" on the tree entity
//
// Used to clean up trees as we move through the level
//*****************************************************************************

cleanup_destructable_trees( tree_group_index )
{
	tree_array = GetEntArray( "fxanim_tree", "targetname" );
	
	if( isdefined( tree_array ) )
	{
		for( i=0; i<tree_array.size; i++ )
		{
			tree = tree_array[i];
			if( isdefined( tree.script_int ) )
			{
				if( tree.script_int == tree_group_index )
				{
					tree thread maps\river_fx::fx_treedelete();
				}
			}
		}
	}
}


//*****************************************************************************
//*****************************************************************************

boss_boat_fight()
{
	//**********************************************
	// Spawn in the boss boat
	//**********************************************
		
	maps\_vehicle::scripted_spawn( 9200 );
	
	
	//**********************************************
	// Wait for the player to get in range to attack
	//**********************************************

	player = get_players()[0];
	
	//engagmement_distance = 12000;		// 12000
	
	boss_boat_1 = GetEnt( "boss_boat_1", "targetname" );

	level.boss_boat = boss_boat_1;

	boss_boat_1.max_health = 4200;		// 8000
	boss_boat_1.health = boss_boat_1.max_health;

	boss_boat_1.vehicleavoidance = 1;
		
	// Attach a search light
	boss_boat_1.search_light = maps\river_drive::add_mortar_light( boss_boat_1, "tag_flash_gunner1" );


	// Use this node to start the Boss Boat and check for the player running away
	
	boss_boat_1.enter_arena_struct = getstruct( "boss_boat_arena_start", "targetname" );
	boss_boat_1.exit_arena_struct = getstruct( "boss_boat_arena_exit", "targetname" );


	//***************************************************
	// Wait for the player to trigger the boss boat fight
	//***************************************************

	while( 1 )
	{
		dir_to_boat = boss_boat_1.origin - level.player.origin;
		dir_to_boat = VectorNormalize( dir_to_boat );
		dir_to_node = boss_boat_1.enter_arena_struct.origin - level.player.origin;
		dir_to_node = VectorNormalize( dir_to_node );
		
		dot = vectordot( dir_to_boat, dir_to_node );
		
		if( dot < 0 )
		{
			// Turn off the water sim for the boss boat fight
			// Temp fix until the big waves are fixed
			// 1st fix attempt was an improvement but we have still seen very big waves!!!
			//SetDvar( "r_watersim_enabled", 0 );
				
			//iprintlnbold( "STARTING BOSS BOAT FIGHT" );
			boss_boat_1 thread boss_boat_ai();
			boss_boat_1 thread boss_boat_check_damage();

			boss_boat_1 thread boss_boat_fire_update();
			
			// Boss Boat Begins VO
			level.woods thread maps\river_vo::playVO_proper( "something_bigs_on_its_way", 0 );	// 4
			level.woods thread maps\river_vo::playVO_proper( "nva_pt_boat", 3.5 );				// 7.5
			level.bowman thread maps\river_vo::playVO_proper( "dont_sit_still_for", 7.5 );		// 11.5
			
			// Checks to stop the player exigint the boss boat arena by the enterance or exit routes
			boss_boat_1 thread stop_player_running_away_from_boss_boat( boss_boat_1.enter_arena_struct );
			boss_boat_1 thread stop_player_running_away_from_boss_boat( boss_boat_1.exit_arena_struct );
			
			// Player taking too much damage vo thread
			boss_boat_1 thread check_player_health_vo();
						
			wait( 3 );
			flag_set( "boss_boat_started" );
			
			break;
		}
		else
		{
			//iprintlnbold( "BOSS BOAT DOT: " + dot );
		}
		
		wait( 0.2 );
	}
}


//*****************************************************************************
// self = boss boat
//*****************************************************************************

check_player_health_vo()
{
	self endon( "death" );
	level.boat endon( "death" );
	
	player_max_health = level._player_boat_health;

	vo_last_time = -1000;
	vo_repeat_delay = 30;
	vo_repeat_delay_inc = 10;
	
	while( 1 )
	{
		time = GetTime();
		dt = ( time - vo_last_time ) / 1000;
		
		// Has it been a while since we gave a vo health warning?	
		if( dt > vo_repeat_delay )
		{
			// Get the players health as a fraction
			health_frac = level.boat.boat_health / player_max_health;
			
			if( health_frac < 0.62 )
			{
				level.reznov thread maps\river_vo::playVO_proper( "use_those_buildings", 0.2 );
				vo_last_time = time;
				vo_repeat_delay += vo_repeat_delay_inc;
			}
		}
	
		wait( 0.05 );
	}
}


//*****************************************************************************
// self = boss boat
//*****************************************************************************

stop_player_running_away_from_boss_boat( exit_node )
{
	self endon( "death" );

	wait( 2 );

	player_arena_mode = "arena good";
	
	time_outside_arena_start = 0;
	last_outside_warning_time = 0;
	
	vo_warning_delay = 6;					// 10
	vo_index = 0;

	outside_arena_fail_time = 15;			// (25) If outside the arena this amount of time, fail the mission


	//*****************************
	// While the boss boat is alive
	//*****************************

	while( self.health > 0 )
	{
		time = GetTime();
	
		//************************************************
		// First, check if the player is inside the arena?
		//************************************************

		dir_to_node = exit_node.origin - level.player.origin;
		dir_to_node = VectorNormalize( dir_to_node );
		
		forward = AnglesToForward( exit_node.angles );
		
		dot = vectordot( dir_to_node, forward );
		
		// If > 0, the player has exited the arena
		if( dot > 0 )
		{
			in_arena = 0;
		}
		else
		{
			in_arena = 1;
		}

		
		//**********************************
		// If the player is inside the arena
		//**********************************
		
		if( player_arena_mode == "arena good" )
		{
			if( !in_arena )
			{
				time_outside_arena_start = time;
				//IPrintLnBold( "PLAYER HAS EXITED THE ARENA" );
				player_arena_mode = "arena bad";
			}
		}

		//***********************************
		// If the player is outside the arena
		//***********************************
		
		else
		{
			if( in_arena )
			{
				//IPrintLnBold( "PLAYER ENTERS THE ARENA" );
				player_arena_mode = "arena good";
			}
			else
			{
				dt = ( time- time_outside_arena_start ) / 1000;
				
				/************************************************************************/
				/* If the playey has spend too long outside the arena, fail the mission */
				/************************************************************************/
				
				if( dt > outside_arena_fail_time )
				{
					//SetDvar( "ui_deadquote", &"RIVER_BOSS_BOAT_COWARD" ); // use your own string
					wait( 4 );
					maps\_utility::missionFailedWrapper( &"RIVER_BOSS_BOAT_COWARD" );
					return;
				}
				
						
				/************************************************/
				/* Play a VO warning to get back into the arena */
				/************************************************/

				dt = ( time - last_outside_warning_time ) / 1000;

				if( dt > vo_warning_delay )
				{
					if( vo_index == 0)
					{
						level.woods thread maps\river_vo::playVO_proper( "mason_we_cant_leave_this_area", 0.5 );
					}
					else
					{
						level.woods thread maps\river_vo::playVO_proper( "turn_back_mason_we_have_to", 0.5 );
					}
					vo_index++;
					if( vo_index >= 2 )
					{
						vo_index = 0;
					}
					
					last_outside_warning_time = time;
				}
			}
		}

		// If the boss boats health is 0, no need to check anymore
		if( self.health <= 0 )
		{
			return;
		}
		
		wait( 0.1 );
	}
}


//*****************************************************************************
// self = boat
//
// POSSIBLE BEHAVIOURS:
// - Slow when in a direct line of attack with the player
// - If player looking at boat and boat looking away, maybe do a quick turn and run
// - Reacting to being shot
//
//*****************************************************************************

boss_boat_ai()
{
	self endon("death");

	//
	//				*********************
	//				*** Get the nodes ***
	//				*********************
	//
	//		node 1							node 2
	//
	//			node 5					node 6
	//
	//						node 9
	//
	//			node 7					node 8
	//
	//		node 4							node 3
	//
	
	//
	// PATH TYPES: 
	//		"outer_circle"		Boats drives around the outr edge of the arena
	//		"break_path"		Boat breaks away and paths through the middle buildings
	//
	//
		
	//
	// Get all the nodes that the boss boats uses to navigate
	//

	all_nodes = [];
	all_nodes[ all_nodes.size ] = getVehicleNode( "boat_node_1", "targetname" );	// dummy entry
	all_nodes[ all_nodes.size ] = getVehicleNode( "boat_node_1", "targetname" );
	all_nodes[ all_nodes.size ] = getVehicleNode( "boat_node_2", "targetname" );
	all_nodes[ all_nodes.size ] = getVehicleNode( "boat_node_3", "targetname" );
	all_nodes[ all_nodes.size ] = getVehicleNode( "boat_node_4", "targetname" );
	all_nodes[ all_nodes.size ] = getVehicleNode( "boat_node_5", "targetname" );
	all_nodes[ all_nodes.size ] = getVehicleNode( "boat_node_6", "targetname" );
	all_nodes[ all_nodes.size ] = getVehicleNode( "boat_node_7", "targetname" );
	all_nodes[ all_nodes.size ] = getVehicleNode( "boat_node_8", "targetname" );
	all_nodes[ all_nodes.size ] = getVehicleNode( "boat_node_9", "targetname" );
	all_nodes[ all_nodes.size ] = getVehicleNode( "boat_node_10", "targetname" );

	self SetSpeed( 40 );						// 45

	self SetNearGoalNotifyDist( 500 );			// 500

	self.direct_attack_min_distance = 1200;		// 
	
	player = get_players()[0];
	
	
	//*****************************
	// Follow a path of array nodes
	//*****************************

	node_index = 1;
	path = get_main_circular_path( all_nodes, node_index );
	
	clockwise = 0;

	path_type = "outer_circle";
	next_path = path_type;

	ignore_direct_attack = 1;
	
	
	//*************************************************************************	
	//*************************************************************************
	//** MAIN PATHING LOOP
	//*************************************************************************
	//*************************************************************************
				
	debug_boss_boat = 0;
	
	current_node = undefined;
	while( 1 )
	{
		//****************************************************************************
		// Set the start index.
		// The array contains a clockwise followed by an anti-clockwise array of nodes
		//****************************************************************************
		
		start_index = 0;
		end_index = path.size;

		// Set the position in the array based on clockwise-ness
		if( path_type == "outer_circle" )
		{
			if( clockwise )
			{
				start_index = 0;
			}
			else
			{
				start_index = 4;
			}
		
			end_index = start_index + 4;
		}
	
	
		//************************************************************************************************
		// Follow the path of nodes
		// When we reach a node, there is a chance we'll break out of the path and head towards the center
		//************************************************************************************************
		
		for( index=start_index; index<end_index; index++ )
		{
			//*************************
			// Set the destination node
			//*************************
			
			current_node = path[index];


			//***********************************************************************************
			// If the boat is looking at approximately at the player while moving to the new node
			// We may go into a more aggressive mode of attacking the player
			//***********************************************************************************

			direct_attack_player = self check_for_player_direct_attack( current_node );
			if( ignore_direct_attack )
			{
				ignore_direct_attack = 0;
				direct_attack_player = 0;
			}

			// *** DEBUG ***	
			if( debug_boss_boat	)
			{
				self print_debug_boat_path( clockwise, current_node, direct_attack_player );
			}
			
			// Drive towards the next target node
			speed = boat_get_node_max_speed( current_node );
			self SetSpeed( speed, 20, 20 );

			// New: Focused attack against the player
			if( direct_attack_player )
			{
				self thread boat_direct_attack( current_node );
			}
			
			self thread boat_slow_near_node( current_node );
			
			self SetVehGoalPos( current_node.origin, 0, 0 );
			self waittill( "near_goal" );
			
			self notify( "reached_node" );


			//*******************************************************************
			// Boat has reached the next node in the path, lets have a think.....
			//*******************************************************************

			wait( 0.01 );


			//************************************************************************
			// If the player is directly behind the boat, maybe reverse and attack him
			//************************************************************************

			if( path_type == "outer_circle" )
			{
				if( randomint( 100 ) < 75 )		// 60
				{
					attack_him = self check_if_target_behind_me( all_nodes, player  );
					if( attack_him )
					{
						//iPrintLnBold("BEHIND ME ATTACK!!!");

						// Swap direction
						if( clockwise )
						{
							clockwise = 0;
						}
						else
						{
							clockwise = 1;
						}
						break;
					}
				}
			}

			
			//************************************************************
			// If in an LOS with the player maybe use a break through path
			//************************************************************

			if( path_type == "outer_circle" )
			{
				if( randomint( 100 ) < 60 )		// 50
				{
					attack_him = self check_for_break_attack_path( all_nodes, current_node, player  );
					if( attack_him )
					{
						//iPrintLnBold("BREAKING PATH!!!");
				
						node_index = get_node_index_from_node_array( all_nodes, current_node );
						path = get_breakaway_path( all_nodes, node_index );
						next_path = "break_path";
						break;
					}
				}
			}
			

			//*************************************************
			// Does the boat want to randomly change direction?
			//*************************************************

			if( path_type == "outer_circle" )
			{
				if( randomint( 100 ) < 12 )		// 45
				{
					if( clockwise )
					{
						clockwise = 0;
					}
					else
					{
						clockwise = 1;
					}
								
					break;
				}
			}
		}

		
		//***************************************************
		//* The current path has either ended or been aborted
		//***************************************************
		
		// If we don't have a new path setup, set one!
		if( next_path == "" )
		{
			node_index = get_node_index_from_node_array( all_nodes, current_node );
			path = get_main_circular_path( all_nodes, node_index );
			path_type = "outer_circle";
		}
		
		else
		{
			path_type = next_path;
		}

		
		//************************************************************
		// After any path as been setup the AI resumes a circular path
		//************************************************************
		
		next_path = "";
	}
}


//*****************************************************************************
// self = boat
//*****************************************************************************

check_if_target_behind_me( all_nodes, target  )
{
	boat_forward = AnglesToforward( self.angles );
	boat_forward = VectorNormalize( boat_forward );
	
	dir_to_target = target.origin - self.origin;
	dir_to_target = VectorNormalize( dir_to_target );
	
	// Is the player behind me?
	dot = vectordot( dir_to_target, boat_forward );
	if( dot < -0.70 )	// -0.8
	{
		return( 1 );
	}

	return( 0 );	
}


//*****************************************************************************
// self = boat
//*****************************************************************************

check_for_break_attack_path( all_nodes, my_node, target )
{
	//
	// Only the folowing nodes have potential direct attack paths
	//
	// 1 -> 3
	// 2 -> 4
	// 3 -> 1
	// 4 -> 2
	//

	node_index = get_node_index_from_node_array( all_nodes, my_node );
	target_node = undefined;
	switch( node_index )
	{
		case 1:
			target_node = all_nodes[3];
		break;
		
		case 2:
			target_node = all_nodes[4];
		break;
		
		case 3:
			target_node = all_nodes[1];
		break;
		
		case 4:
			target_node = all_nodes[2];
		break;
	}

	// Do we have a potential target node?
	if( isdefined(target_node) )
	{
		// Get a direction vector to the target
		dir_to_target = target.origin - self.origin;
		dir_to_target = VectorNormalize( dir_to_target );
	
		// Get a direction vector to the optential target node		
		dir_to_node = target_node.origin - self.origin;
		dir_to_node = VectorNormalize( dir_to_node );

		// Is the player near the target node?
		dot = vectordot( dir_to_target, dir_to_node );
		if( dot > 0.7 )		// 0.7
		{
			return( 1 );
		}
	}

	return( 0 );
}


//*****************************************************************************
// self = boat
//*****************************************************************************

check_for_player_direct_attack( node )
{
	player = get_players()[0];
	
	// First check we are not too close for a direct attack
	dist = Distance( player.origin, self.origin );
	if( dist < self.direct_attack_min_distance )
	{
		return( 0 );
	}
		
	// Is the boat looking at the player?
	dir_to_player = player.origin - self.origin;
	dir_to_player = VectorNormalize( dir_to_player );
	
	dir_to_node = node.origin - self.origin;
	dir_to_node = VectorNormalize( dir_to_node );
	
	dot = vectordot( dir_to_player, dir_to_node );

	// If looking, do we want to attack?
	if( dot > 0.78 )		// 0.83
	{
		rval = randomint( 100 );
		if( rval < 100 )
		{
			return( 1 );
		}
	}
	
	return( 0 );

}


//*****************************************************************************
// self = boat
//*****************************************************************************

boat_direct_attack( node )
{
	self endon( "death" );
	self endon( "reached_node" );

	max_speed = boat_get_node_max_speed( node );

	current_speed = -1;

	while( 1 )
	{
		//iprintlnbold( "DIRECT FIRE" );
	
		break_attack = 0;
	
	
		//******************************
		// First check dist to node
		//******************************

		dist_to_node = Distance( self.origin, node.origin );
		if( dist_to_node < 1000 )
		{
			break_attack = 1;
			return;
		}
	
	
		//******************************
		// If close to target, break out
		//******************************
		dist_to_target = Distance( level.player.origin, self.origin );
		if( dist_to_target < self.direct_attack_min_distance )
		{
			break_attack = 1;
			return;
		}

		/*******************************/
		/* Set speed based on distance */
		/*******************************/

		if( dist_to_target > 3500 )
		{
			speed = max_speed;
		}
		else if( dist_to_target > 2800 )
		{
			speed = (4 * max_speed) / 5;
		}
		else if( dist_to_target > 1800 )
		{
			speed = (3 * max_speed) / 5;
		}
		else
		{
			speed = (max_speed) / 2;
		}
	
		if( speed != current_speed )
		{
// turn off, if we do this the boat doesn't head to the node correctly?
//			self SetSpeed( speed, 20, 20 );
//			self SetVehGoalPos( node.origin, 0, 0 );
			current_speed = speed;
		}
		
//		iprintlnbold( "DIST: " + dist_to_target + "  SPEED: " + speed );
		
		
		//***************************************************************
		// If the player gets out of a direct attack view cone, break out
		//***************************************************************
			
		dir_to_player = level.player.origin - self.origin;
		dir_to_player = VectorNormalize( dir_to_player );
		dir_to_node = node.origin - self.origin;
		dir_to_node = VectorNormalize( dir_to_node );
		dot = vectordot( dir_to_player, dir_to_node );
	
		if( dot < 0.6 )
		{
			break_attack = 1;
		}

		//********************************************************************************
		// If loooking at the player and in close fire proximity, open up and fire rockets
		//********************************************************************************

		missile_fire_range = 4500;						// 4200

		if( dist_to_target < missile_fire_range )
		{
			if( dot > 0.74 )							// 0.78
			{
				rval = randomint( 100 );
				if( rval > 85 )							// 75
				{
					boss_boat_missile( level.boat );
				}
			}
		}


		//***********************************************************
		// Does the boat want to break out of the direct attack mode?
		//***********************************************************

		if( break_attack )
		{
			self SetSpeed( max_speed, 20, 20 );
			self SetVehGoalPos( node.origin, 0, 0 );
			return;
		}

		delay = randomfloatrange( 0.3, 0.8 );			// 0.7, 1.1
		wait( delay );
	}
}


//*****************************************************************************
// self = boat
//*****************************************************************************

boat_slow_near_node( node )
{
	self endon( "death" );
	self endon( "reached_node" );

	close_to_node = 1200;
	approach_speed = 28;

	while( 1 )
	{
		dist = Distance( self.origin, node.origin ); 
		if( dist < 500 )
		{
			current_speed = self GetSpeed();
			if( current_speed > approach_speed )
			{
			
//IPrintLnBold("BOSS SLOWING SPEED");
			
				self SetSpeed( approach_speed );
				return;
			}
		}
	
		wait( 0.1 );
	}
}


//*****************************************************************************
//*****************************************************************************
print_debug_boat_path( clockwise, current_node, direct_attack_player )
{
	if( clockwise )
	{
		dir_text = "clock";
	}
	else
	{
		dir_text = "anti c";
	}
	
	if( direct_attack_player )
	{
		attack = "PLAYER ATTACK  ";
	}
	else
	{
		attack = " ";
	}
	
	//iPrintLnBold( attack + dir_text, " NODE: " + current_node.targetname );
}


//*****************************************************************************
//*****************************************************************************

get_main_circular_path( all_nodes, start_node )
{
	path = [];

	switch( start_node )
	{
		// NW PATH
		case 1:
			path[ path.size ] = all_nodes[2];
			path[ path.size ] = all_nodes[3];
			path[ path.size ] = all_nodes[4];
			path[ path.size ] = all_nodes[1];
			path[ path.size ] = all_nodes[4];
			path[ path.size ] = all_nodes[3];
			path[ path.size ] = all_nodes[2];
			path[ path.size ] = all_nodes[1];
		break;

		// NE PATH
		case 2:
			path[ path.size ] = all_nodes[3];
			path[ path.size ] = all_nodes[4];
			path[ path.size ] = all_nodes[1];
			path[ path.size ] = all_nodes[2];
			path[ path.size ] = all_nodes[1];
			path[ path.size ] = all_nodes[4];
			path[ path.size ] = all_nodes[3];
			path[ path.size ] = all_nodes[2];
		break;

		// SW PATH
		case 4:
			path[ path.size ] = all_nodes[1];
			path[ path.size ] = all_nodes[2];
			path[ path.size ] = all_nodes[3];
			path[ path.size ] = all_nodes[4];
			path[ path.size ] = all_nodes[3];
			path[ path.size ] = all_nodes[2];
			path[ path.size ] = all_nodes[1];
			path[ path.size ] = all_nodes[4];
		break;

		// SE PATH
		case 3:
			path[ path.size ] = all_nodes[4];
			path[ path.size ] = all_nodes[1];
			path[ path.size ] = all_nodes[2];
			path[ path.size ] = all_nodes[3];
			path[ path.size ] = all_nodes[2];
			path[ path.size ] = all_nodes[1];
			path[ path.size ] = all_nodes[4];
			path[ path.size ] = all_nodes[3];
		break;
	}
	
	return( path );
}


//*****************************************************************************
//*****************************************************************************

get_breakaway_path( all_nodes, node_index )
{
	path = [];

	switch( node_index )
	{
		//*********************************
		//*********************************
		case 1:
			path[ path.size ] = all_nodes[ 5 ];
			path[ path.size ] = all_nodes[ 10 ];
			if( randomint( 2 ) == 0 )
			{
				path[ path.size ] = all_nodes[ 6 ];
				path[ path.size ] = all_nodes[ 2 ];
			}
			else
			{
				path[ path.size ] = all_nodes[ 8 ];
				path[ path.size ] = all_nodes[ 3 ];
			}
		break;


		//*********************************
		//*********************************
		case 2:
			path[ path.size ] = all_nodes[ 6 ];
			path[ path.size ] = all_nodes[ 9 ];
			if( randomint( 2 ) == 0 )
			{
				path[ path.size ] = all_nodes[ 5 ];
				path[ path.size ] = all_nodes[ 1 ];
			}
			else
			{
				path[ path.size ] = all_nodes[ 7 ];
				path[ path.size ] = all_nodes[ 4 ];
			}
		break;


		//*********************************
		//*********************************
		case 3:
			path[ path.size ] = all_nodes[ 8 ];
			path[ path.size ] = all_nodes[ 9 ];
			if( randomint( 2 ) == 0 )
			{
				path[ path.size ] = all_nodes[ 5 ];
				path[ path.size ] = all_nodes[ 1 ];
			}
			else
			{
				path[ path.size ] = all_nodes[ 7 ];
				path[ path.size ] = all_nodes[ 4 ];
			}
		break;


		//*********************************
		//*********************************
		case 4:
			path[ path.size ] = all_nodes[ 7 ];
			path[ path.size ] = all_nodes[ 10 ];
			if( randomint( 2 ) == 0 )
			{
				path[ path.size ] = all_nodes[ 6 ];
				path[ path.size ] = all_nodes[ 2 ];
			}
			else
			{
				path[ path.size ] = all_nodes[ 8 ];
				path[ path.size ] = all_nodes[ 3 ];
			}
		break;
	}

	return( path );
}


//*****************************************************************************
//*****************************************************************************

get_node_index_from_node_array( all_nodes, node )
{
	index = -1;

	for( i=1; i<all_nodes.size; i++ )
	{
		if( all_nodes[i] == node )
		{
			return( i );
		}
	}
	
	return( index );
}


//*****************************************************************************
//*****************************************************************************

boat_get_node_max_speed( node )
{
	speed = 0;

	switch( node.targetname )
	{
		case "boat_node_1":
		case "boat_node_2":
		case "boat_node_3":
		case "boat_node_4":
			speed = 50;			// 54
		break;
		
		case "boat_node_5":
		case "boat_node_6":
		case "boat_node_7":
		case "boat_node_8":
			speed = 36;			// 35
		break;
		
		case "boat_node_9":
		case "boat_node_10":
			speed = 25;			// 25
		break;
		
		default:
			speed = 0;
		break;
	}
	
	return( speed );
}


//*****************************************************************************
// self = boat (model: t5_veh_boat_nvapatrolboat)
//*****************************************************************************

boss_boat_check_damage()
{
	//*************************************
	// Damage State 1 happens at 30% damage
	//*************************************
	
	damage_frac = 1.0;
	while( damage_frac > 0.7 )
	{
		self waittill( "damage", damage, attacker, direction, point, type );
		self thread boss_boat_check_for_missile_impact( damage, attacker, direction, point, type );
		
		damage_frac = self.health / self.max_health;
				
		//iprintlnbold( "FRAC: " + damage_frac );
		//wait( 0.1 );
	}

	//*******************
	// VO: Damage State 1
	//*******************
	
	// Record the time, the last time he took damage
	boss_takes_damage_time = GetTime();
	
	rval = randomint( 2 );
	if( rval == 0 )
	{
		level.woods thread maps\river_vo::playVO_proper( "hes_on_fire_keep_at_it", 0.2 );
	}
	else
	{
		level.woods thread maps\river_vo::playVO_proper( "we_hit_the_engine", 0.2 );
	}
		
	//playfxOnTag( level._effect[ "temp_destructible_building_fire_medium" ], self, "tag_passenger2" );		// up right out/low
	//playfxOnTag( level._effect[ "temp_destructible_building_fire_large" ], self, "tag_passenger6" );		// up right out/med
	//playfxOnTag( level._effect[ "temp_destructible_building_fire_medium" ], self, "tag_passenger7" );		// up left in/med
	
	// up right out/low
	self.effect1 = maps\river_util::link_effect_to_ents_tag( self, "tag_passenger2", level._effect[ "temp_destructible_building_fire_medium" ] );
 	// up right out/med
 	self.effect2 = maps\river_util::link_effect_to_ents_tag( self, "tag_passenger6", level._effect[ "temp_destructible_building_fire_large" ] );
 	// up right out/med
 	self.effect3 = maps\river_util::link_effect_to_ents_tag( self, "tag_passenger7", level._effect[ "temp_destructible_building_fire_medium" ] );
 	
	playfxOnTag( level._effect["vehicle_explosion"], self, "tag_origin" );
	self playsound( "exp_shell_hit_boat" );
		

	//*************************************
	// Damage State 2 happens at 65% damage
	//*************************************

	while( damage_frac > 0.4 )
	{
		self waittill( "damage", damage, attacker, direction, point, type );
		self thread boss_boat_check_for_missile_impact( damage, attacker, direction, point, type );
	
		damage_frac = self.health / self.max_health;
		
		//iprintlnbold( "FRAC: " + damage_frac );
		//wait( 0.1 );
	}

	level thread maps\river_util::boss_boat_throw_ai( "boss_boat_driver_2", self, "tag_gunner_turret2" );

	// VO: Damage State 2
	// Only say vo if its taken 3 seconds to get to the next damage state
	time = GetTime();
	dt = ( time - boss_takes_damage_time ) / 1000;
	if( dt > 2 )
	{
		level.woods thread maps\river_vo::playVO_proper( "hes_spewing_oil", 0.2 );
		boss_takes_damage_time = time;
	}
	
	//playfxOnTag( level._effect[ "temp_destructible_building_fire_large" ], self, "tag_passenger8" );		// low left in/low
	//playfxOnTag( level._effect[ "temp_destructible_building_fire_medium" ], self, "tag_passenger9" );		// low right in/low
	
	// low left in/low
	self.effect4 = maps\river_util::link_effect_to_ents_tag( self, "tag_passenger8", level._effect[ "temp_destructible_building_fire_large" ] );
	// low right in/low
	self.effect5 = maps\river_util::link_effect_to_ents_tag( self, "tag_passenger9", level._effect[ "temp_destructible_building_fire_medium" ] );
 	
	playfxOnTag( level._effect["vehicle_explosion"], self, "tag_origin" );
	self playsound( "exp_shell_hit_boat" );


	//*************************************
	// Damage State 3 happens at 90% damage
	//*************************************
	
	while( damage_frac > 0.2 )
	{
		self waittill( "damage", damage, attacker, direction, point, type );
		self thread boss_boat_check_for_missile_impact( damage, attacker, direction, point, type );
	
		damage_frac = self.health / self.max_health;

		//iprintlnbold( "FRAC: " + damage_frac );
		//wait( 0.1 );
	}
	
	level thread maps\river_util::boss_boat_throw_ai( "boss_boat_driver_1", self, "tag_gunner_turret1" );

	// VO: Damage State 3
	time = GetTime();
	dt = ( time - boss_takes_damage_time ) / 1000;
	if( dt > 2 )
	{
		level.woods thread maps\river_vo::playVO_proper( "smoked_him_take_him_out", 0.2 );
		boss_takes_damage_time = time;
	}
		
	//playfxOnTag( level._effect[ "temp_destructible_building_fire_medium" ], self, "tag_passenger12" );		// med right in/mid
	//playfxOnTag( level._effect[ "temp_destructible_building_fire_large" ], self, "tag_passenger13" );		// med left in/mid
	//playfxOnTag( level._effect[ "temp_destructible_building_fire_large" ], self, "tag_passenger3" );		// high right in/hi
	//playfxOnTag( level._effect[ "temp_destructible_building_fire_medium" ], self, "tag_passenger5" );		// med left out/med
	
	// med right in/mid
	self.effect6 = maps\river_util::link_effect_to_ents_tag( self, "tag_passenger12", level._effect[ "temp_destructible_building_fire_medium" ] );
 	// med left in/mid
 	self.effect7 = maps\river_util::link_effect_to_ents_tag( self, "tag_passenger13", level._effect[ "temp_destructible_building_fire_large" ] );
 	// high right in/hi
 	self.effect8 = maps\river_util::link_effect_to_ents_tag( self, "tag_passenger3", level._effect[ "temp_destructible_building_fire_large" ] );
 	// med left out/med
 	self.effect9 = maps\river_util::link_effect_to_ents_tag( self, "tag_passenger5", level._effect[ "temp_destructible_building_fire_medium" ] );
 
	playfxOnTag( level._effect["vehicle_explosion"], self, "tag_origin" );
	self playsound( "exp_shell_hit_boat" );


	//*************************************
	// Wait for boat to die
	//*************************************

	while( self.health > 0 )
	{
		self waittill( "damage", damage, attacker, direction, point, type );
		
		self thread boss_boat_check_for_missile_impact( damage, attacker, direction, point, type );

		//iprintlnbold( "HEALTH: " + self.health );
		//wait( 0.1 );
	}

//	self waittill( "death" );
	
	self SetSpeed( 0 );
	self ClearVehGoalPos();
	
	//
	self.effect1 delete();
 	self.effect2 delete();
 	self.effect3 delete();
 	self.effect4 delete();
 	self.effect5 delete();
 	self.effect6 delete();
 	self.effect7 delete();
 	self.effect8 delete();
 	self.effect9 delete();
 
	wait( 0.1 );
	
 
	// VO: KILLED HIM
	level.bowman thread maps\river_vo::playVO_proper( "we_got_him", 0.2 );
	level.mason thread maps\river_vo::playVO_proper( "that_all_they_got", 2.0 );
	
	level.bowman thread maps\river_vo::playVO_proper( "medic", 4.5 );

	// Delete the boss boat search light
	self.search_light delete();
	
	playfxOnTag( level._effect["vehicle_explosion"], self, "tag_origin" );
			
	self playsound( "exp_shell_hit_boat" );
	
	level thread boss_boat_dies( self );
}


//*****************************************************************************
// self = level
//*****************************************************************************

boss_boat_dies( boss_boat )
{
	// Keeps the guys in position on the players boat
	level.woods.ignoreall = true;
	level.bowman.ignoreall = true;

	// This is guarding an assert. if the boat's death anim is playing, Woods and Bowman are killed and show up as undefined.
	if( flag( "playing_boat_death" ) )
	{
		wait( 10 );  // the wait is here so we don't need to do this check in other functions
		return;
	}	

	// Hide the Boss Boat
	boss_boat SetSpeedImmediate( 0, 30000, 30000 );
	wait( 0.01 );
	boss_boat hide();

	// Inform game the boss boat is defeated, gets rid of Destroy Marker
	flag_set( "boss_boat_killed" );
			
	// Get Boat position and angles
	boat_pos = boss_boat.origin;
	boat_angles = boss_boat.angles;

	// Create a fake dead boss boat
	ent = spawn( "script_model", boat_pos );
	ent.angles = boat_angles;
	ent setModel( "t5_veh_boat_nvapatrolboat_dead" );

	// Add fire effects
	playfxOnTag( level._effect[ "temp_destructible_building_fire_medium" ], ent, "tag_passenger2" );
	playfxOnTag( level._effect[ "temp_destructible_building_fire_large" ], ent, "tag_passenger6" );
	playfxOnTag( level._effect[ "temp_destructible_building_fire_medium" ], ent, "tag_passenger7" );

	playfxOnTag( level._effect[ "temp_destructible_building_fire_large" ], ent, "tag_passenger8" );
	playfxOnTag( level._effect[ "temp_destructible_building_fire_medium" ], ent, "tag_passenger9" );
	
	playfxOnTag( level._effect[ "temp_destructible_building_fire_medium" ], ent, "tag_passenger12" );
	playfxOnTag( level._effect[ "temp_destructible_building_fire_large" ], ent, "tag_passenger13" );
	playfxOnTag( level._effect[ "temp_destructible_building_fire_large" ], ent, "tag_passenger3" );
	playfxOnTag( level._effect[ "temp_destructible_building_fire_medium" ], ent, "tag_passenger5" );

	wait( 0.6 );	// 1.0 - Need this delay for the boat to disconnect paths????

	sink_pos = ( boat_pos[0], boat_pos[1], boat_pos[2] - 400 );
	
	speed = boss_boat getspeed();
	forward = anglestoforward( boss_boat.angles );
	sink_pos = sink_pos + (forward * speed * 1.1);
		
	sink_time = 6;
	ent moveTo( sink_pos, sink_time, 0.5, 0.5 );	// 0.5 0.5
	
	sink_angles = ( boat_angles[0]-30, boat_angles[1], boat_angles[2]-15 );
	rotate_time = 2.2;	// 1.9
	ent rotateTo( sink_angles, rotate_time );

	// Sink Explosion
	playfxOnTag( level._effect["vehicle_explosion"], ent, "tag_origin" );
	ent playsound( "exp_shell_hit_boat" );
	
	// kill the old hidden boss boat
	boss_boat delete();

	wait( 0.75 );
	PlayFX( level._effect[ "quad50_temp_death_effect" ], ent.origin, AnglesToForward( ent.angles ) );
	ent playsound( "exp_shell_hit_boat" );
	wait( 5.25 );

	// Kill the fake boss boat	
	ent delete();

	// Notify the boat is dead
	wait( 0.5 );
	level notify( "boss_boat_destroyed" );
}


//*****************************************************************************
// self = boat
//*****************************************************************************

boss_boat_check_for_missile_impact( damage, attacker, direction, point, type )
{
	// Draw a big explosion if we hit it with the missile
	if( type == "MOD_PROJECTILE" )
	{
		playSoundAtPosition( "shell_explode_default", point );
		PhysicsExplosionSphere( point, 42*12, 42*10, 25 );
		level thread maps\river_util::PlayFxTimed( level._effect["quad50_temp_death_effect"], point, 1.5 );
	}
}


//*****************************************************************************
// self = boat
//*****************************************************************************

boss_boat_fire_update()
{
	self endon("death");

	player = get_players()[0];

	
	// If Player is within this range then the boat can potentially fire at the player
	in_fire_range = 8000;
	
	// Reverse fire distance and angle
	in_reverse_fire_range = 2200;			// 2000
	reverse_fire_angle = -0.65;				// -0.65
	
	// Boat fires side-cross shots
	missile_cross_shot_range = 2600;		// 2500
	cross_shot_angle = 0.26;				// 0.24
	
	// Full on angle of attack
	forward_fire_angle = 0.62;				// 0.66
	

	/**************************/
	/* Boss Boat AI Main Loop */
	/**************************/

	while( self.health > 0 )
	{
		// How far is the boat from the player
		dist = self boat_dist_to_target( player );
		
//speed = self GetSpeedMPH();		
//iprintlnbold( "Speed:" + speed );

		// Is the boat looking at the player
		if( dist < in_fire_range )
		{	
			//********************************
			// Can we fire the forward Weapon?
			//********************************
			dot = 1.0;
			while( dot > forward_fire_angle )
			{
				boat_forward = AnglesToforward( self.angles );
				dir = ( player.origin[0]-self.origin[0], player.origin[1]-self.origin[1], 0 );
				dir_norm = vectorNormalize( dir );
				dot = vectordot( dir_norm, boat_forward );
	
//				iprintlnbold( "FORWARD DOT: " + dot );

				if( dot > forward_fire_angle )
				{
					rval = randomint( 100 );
					if( rval < 75 )		// 70
					{
						boss_boat_missile( level.boat );
						wait( 0.2 );	// 0.26
					}
					else
					{
						fire_time = randomfloatrange( 0.75, 1.5 );
						self maps\river_util::vehicle_static_line_fire( 0, player.origin, player.origin, fire_time );
						wait( fire_time );
						wait( 0.1 );
					}
				}
				else
				{
					break;
				}
			}
			
			//*****************************
			// Can we fire the rear Weapon? 
			//*****************************
			dot = -1.0;
			while( (dot < reverse_fire_angle ) && (dist < in_reverse_fire_range) )
			{
				boat_forward = AnglesToforward( self.angles );
				dir = ( player.origin[0]-self.origin[0], player.origin[1]-self.origin[1], 0 );
				dir_norm = vectorNormalize( dir );
				dot = vectordot( dir_norm, boat_forward );
	
//				iprintlnbold( "REAR DIST:" + dist + "  DOT:" + dot );
			
				if( dot < reverse_fire_angle )
				{
					fire_time = randomfloatrange( 0.75, 1.5);
					self maps\river_util::vehicle_static_line_fire( 1, player.origin, player.origin, fire_time );
					wait( fire_time );
					wait( 0.1 );
				}
				else
				{
					break;
				}
				
				dist = self boat_dist_to_target( player );
			}


			//************************************
			// Can we fire the side ways missiles?
			//************************************

			if( dist < missile_cross_shot_range )
			{
				dot = 0.0;
				while( abs(dot) < cross_shot_angle )
				{
					boat_forward = AnglesToforward( self.angles );
					dir = ( player.origin[0]-self.origin[0], player.origin[1]-self.origin[1], 0 );
					dir_norm = vectorNormalize( dir );
					dot = vectordot( dir_norm, boat_forward );
	
					if( abs(dot) < cross_shot_angle )
					{
						boss_boat_missile( level.boat );
						wait( randomfloatrange( 0.3, 1.0 ) );
					}
					else
					{
						break;
					}
					
					//iprintlnbold( "SIDE ATTACK:" );
				}
			}
		}

		wait( 0.25 );
	}
}


//*****************************************************************************
// self = boat
//*****************************************************************************

boat_dist_to_target( target )
{
	dist = ( (target.origin[0]-self.origin[0]) * (target.origin[0]-self.origin[0]) + 
			 (target.origin[1]-self.origin[1]) * (target.origin[1]-self.origin[1]) );
	dist = sqrt( dist );
	return( dist );
}


//*****************************************************************************
// self = boat
//*****************************************************************************

boss_boat_missile( target )
{
	start_pos = self.origin;
	
	// Get the missile start position
	forward = AnglesToforward( self.angles );
	up = AnglesToup( self.angles );
	start_pos = start_pos + ( forward * (42*0) ) + ( up * 42*4);
	
	// Adjust start posityion based on boats speed
	//my_speed = self GetSpeed();
	//inc_vec = (forward * my_speed);
	//start_pos = start_pos + inc_vec;
			
	// Set the target position, use a little bullet prediction based on targets velocity
	end_pos = target.origin;
	offset = ( randomfloatrange(-20, 20), randomfloatrange(-20, 20), randomfloatrange(20, 70) );
	end_pos = end_pos + offset;
			
	// Use "huey_rockets" weapon fire as an override for now
	self playsound( "wpn_rocket_fire_chopper" );

	// adjust end_pos, based on its speed
	projectile_speed = 1500;  // GDT setting
	vec_inc = self predict_vehicle_movement_offset( target, projectile_speed );
	end_pos = end_pos + vec_inc;

	//MagicBullet( "rpg_river_missile_sp", start_pos, end_pos, self );
	MagicBullet( "rpg_river_infantry_sp", start_pos, end_pos, self );
	
	// Draw a muzzle flash at fire point
	dir = end_pos - start_pos;
	dir_norm = vectorNormalize( dir );
	PlayFX( level._effect["artillery_muzzle"], start_pos, dir_norm );
}


//*****************************************************************************
// self = boat that is firing
//*****************************************************************************
predict_vehicle_movement_offset( target, projectile_speed )
{
	current_distance = Distance( target.origin, self.origin );
		
	target_forward = AnglesToForward( target.angles );
	target_speed = target GetSpeed();
	
	estimated_offset = ( 0, 0, 0 );
	
	if( abs(target_speed) > 5 )
	{
		// inches / (inches/sec) = sec
		time_to_hit = current_distance / projectile_speed;
		scale_forward = target_speed * time_to_hit ;  
		estimated_offset = ( target_forward * scale_forward );
	}
	
	return( estimated_offset );
}			


//*****************************************************************************
// self = player boat
//*****************************************************************************

boat_ads_control()
{
	//normal_fov = GetDvarFloat( #"cg_fov" );
	default_fov = 65;
	zoomed_fov = 40;	// 40
	
	wait_for_button_release = 0;
	
	level.player_has_used_ads = 0;
	level.ads_active = 0;
		
	while( 1 )
	{
		// Turn off ADS after boss boat defeated
		if( IsDefined("boss_boat_killed") )
		{
			if( flag( "boss_boat_killed" ) )
			{
				level.player SetClientDvar( "cg_fov", default_fov );
				level.ads_active = 0;
				return;
			}
		}
	
		// Wait for the ADS button to be released
		if( wait_for_button_release )
		{
			if( (level.player MeleeButtonPressed()==0) )
			{
				wait_for_button_release = 0;
				level.player_has_used_ads = 1;
			}
		}
		
		else
		{
			ads_changed = 0;
			if( level.player MeleeButtonPressed() )
			{
				if( level.ads_active == 1 )
				{
					level.ads_active = 0;
				}
				else
				{
					level.ads_active = 1;
				}

				ads_changed = 1;
				wait_for_button_release = 1;
			}

			if( ads_changed )
			{
				if( level.ads_active )
				{
					level.player SetClientDvar( "cg_fov", zoomed_fov );
				}
				else
				{
					level.player SetClientDvar( "cg_fov", default_fov );
				}
			}
		}
				
		wait( 0.01 );
	}
}


//*****************************************************************************
// BOAT HUD INIT
//
// self = player
//*****************************************************************************

boat_hud_init( boat )
{
	if(! IsDefined(self.rocket_hud) )
	{
		self.rocket_hud = [];
	}

	xsync = -100;

	self.rocket_hud["border_left"] = newHudElem();
	self.rocket_hud["border_left"].alignX = "right";
	self.rocket_hud["border_left"].alignY = "bottom";
	self.rocket_hud["border_left"].horzAlign = "user_right";
	self.rocket_hud["border_left"].vertAlign = "user_bottom";
	self.rocket_hud["border_left"].y = -23;
	self.rocket_hud["border_left"].x = -55+xsync;
	self.rocket_hud["border_left"].alpha = 1.0;
	self.rocket_hud["border_left"] fadeOverTime( 0.05 );
	self.rocket_hud["border_left"] SetShader( "hud_hind_rocket_border_left", 72, 20 );
	self.rocket_hud["border_left"].hidewheninmenu = true;
		
	self.rocket_hud["woods1"] = newHudElem();
	self.rocket_hud["woods1"].alignX = "right";
	self.rocket_hud["woods1"].alignY = "bottom";
	self.rocket_hud["woods1"].horzAlign = "user_right";
	self.rocket_hud["woods1"].vertAlign = "user_bottom";
	self.rocket_hud["woods1"].y = -30;
	self.rocket_hud["woods1"].x = -80+xsync;
	self.rocket_hud["woods1"].alpha = 0.55;
	self.rocket_hud["woods1"] fadeOverTime( 0.05 );
	self.rocket_hud["woods1"] SetShader( "hud_hind_rocket", 48, 48 );
	self.rocket_hud["woods1"].hidewheninmenu = true;
	
	self.rocket_hud["woods2"] = newHudElem();
	self.rocket_hud["woods2"].alignX = "right";
	self.rocket_hud["woods2"].alignY = "bottom";
	self.rocket_hud["woods2"].horzAlign = "user_right";
	self.rocket_hud["woods2"].vertAlign = "user_bottom";
	self.rocket_hud["woods2"].alpha = 0.55;
	self.rocket_hud["woods2"] fadeOverTime( 0.05 );
	self.rocket_hud["woods2"].y = -30;
	self.rocket_hud["woods2"].x = -70+xsync;
	self.rocket_hud["woods2"] SetShader( "hud_hind_rocket", 48, 48 );
	self.rocket_hud["woods2"].hidewheninmenu = true;
	
	self.rocket_hud["woods3"] = newHudElem();
	self.rocket_hud["woods3"].alignX = "right";
	self.rocket_hud["woods3"].alignY = "bottom";
	self.rocket_hud["woods3"].horzAlign = "user_right";
	self.rocket_hud["woods3"].vertAlign = "user_bottom";
	self.rocket_hud["woods3"].alpha = 0.55;
	self.rocket_hud["woods3"] fadeOverTime( 0.05 );
	self.rocket_hud["woods3"].y = -30;
	self.rocket_hud["woods3"].x = -60+xsync;
	self.rocket_hud["woods3"] SetShader( "hud_hind_rocket", 48, 48 );
	self.rocket_hud["woods3"].hidewheninmenu = true;
		
	self.rocket_hud["woods4"] = newHudElem();
	self.rocket_hud["woods4"].alignX = "right";
	self.rocket_hud["woods4"].alignY = "bottom";
	self.rocket_hud["woods4"].horzAlign = "user_right";
	self.rocket_hud["woods4"].vertAlign = "user_bottom";
	self.rocket_hud["woods4"].alpha = 0.55;
	self.rocket_hud["woods4"] fadeOverTime( 0.05 );
	self.rocket_hud["woods4"].y = -30;
	self.rocket_hud["woods4"].x = -50+xsync;
	self.rocket_hud["woods4"] SetShader( "hud_hind_rocket", 48, 48 );
	self.rocket_hud["woods4"].hidewheninmenu = true;
	
	self.rocket_hud["button"] = newHudElem();
	self.rocket_hud["button"].alignX = "center";
	self.rocket_hud["button"].alignY = "bottom";
	self.rocket_hud["button"].horzAlign = "user_right";
	self.rocket_hud["button"].vertAlign = "user_bottom";
	self.rocket_hud["button"].y = -10;
	self.rocket_hud["button"].x = -62+xsync;
	self.rocket_hud["button"].foreground = true;
	self.rocket_hud["button"] SetText("^3[{+speed_throw}]^7");
	self.rocket_hud["button"].hidewheninmenu = true;

	self.rocket_hud["border_right"] = newHudElem();
	self.rocket_hud["border_right"].alignX = "right";
	self.rocket_hud["border_right"].alignY = "bottom";
	self.rocket_hud["border_right"].horzAlign = "user_right";
	self.rocket_hud["border_right"].vertAlign = "user_bottom";
	self.rocket_hud["border_right"].y = -23;
	self.rocket_hud["border_right"].x = 0+xsync;
	self.rocket_hud["border_right"].alpha = 1.0;
	self.rocket_hud["border_right"] fadeOverTime( 0.05 );
	self.rocket_hud["border_right"] SetShader( "hud_hind_rocket_border_right", 72, 20 );
	self.rocket_hud["border_right"].hidewheninmenu = true;
	
	self.rocket_hud["bowman4"] = newHudElem();
	self.rocket_hud["bowman4"].alignX = "right";
	self.rocket_hud["bowman4"].alignY = "bottom";
	self.rocket_hud["bowman4"].horzAlign = "user_right";
	self.rocket_hud["bowman4"].vertAlign = "user_bottom";
	self.rocket_hud["bowman4"].alpha = 0.55;
	self.rocket_hud["bowman4"] fadeOverTime( 0.05 );
	self.rocket_hud["bowman4"].y = -30;
	self.rocket_hud["bowman4"].x = -30+xsync;
	self.rocket_hud["bowman4"] SetShader( "hud_hind_rocket", 48, 48 );
	self.rocket_hud["bowman4"].hidewheninmenu = true;
	
	self.rocket_hud["bowman3"] = newHudElem();
	self.rocket_hud["bowman3"].alignX = "right";
	self.rocket_hud["bowman3"].alignY = "bottom";
	self.rocket_hud["bowman3"].horzAlign = "user_right";
	self.rocket_hud["bowman3"].vertAlign = "user_bottom";
	self.rocket_hud["bowman3"].alpha = 0.55;
	self.rocket_hud["bowman3"] fadeOverTime( 0.05 );
	self.rocket_hud["bowman3"].y = -30;
	self.rocket_hud["bowman3"].x = -20+xsync;
	self.rocket_hud["bowman3"] SetShader( "hud_hind_rocket", 48, 48 );
	self.rocket_hud["bowman3"].hidewheninmenu = true;
	
	self.rocket_hud["bowman2"] = newHudElem();
	self.rocket_hud["bowman2"].alignX = "right";
	self.rocket_hud["bowman2"].alignY = "bottom";
	self.rocket_hud["bowman2"].horzAlign = "user_right";
	self.rocket_hud["bowman2"].vertAlign = "user_bottom";
	self.rocket_hud["bowman2"].alpha = 0.55;
	self.rocket_hud["bowman2"] fadeOverTime( 0.05 );
	self.rocket_hud["bowman2"].y = -30;
	self.rocket_hud["bowman2"].x = -10+xsync;
	self.rocket_hud["bowman2"] SetShader( "hud_hind_rocket", 48, 48 );
	self.rocket_hud["bowman2"].hidewheninmenu = true;
	
	self.rocket_hud["bowman1"] = newHudElem();
	self.rocket_hud["bowman1"].alignX = "right";
	self.rocket_hud["bowman1"].alignY = "bottom";
	self.rocket_hud["bowman1"].horzAlign = "user_right";
	self.rocket_hud["bowman1"].vertAlign = "user_bottom";
	self.rocket_hud["bowman1"].alpha = 0.55;
	self.rocket_hud["bowman1"] fadeOverTime( 0.05 );
	self.rocket_hud["bowman1"].y = -30;
	self.rocket_hud["bowman1"].x = 0+xsync;
	self.rocket_hud["bowman1"] SetShader( "hud_hind_rocket", 48, 48 );
	self.rocket_hud["bowman1"].hidewheninmenu = true;
	
	self thread hud_rocket_think();
}


//*****************************************************************************
// BOAT MINI GUN HUD
//
// self = player
//*****************************************************************************

hud_minigun_create( xpos, ypos )
{
	if(!IsDefined(self.minigun_hud))
	{
		self.minigun_hud = [];
	}
	
	// OAA: 9/16/10 Removed for code driven overheat bar
	//self.minigun_hud["gun"] = newHudElem();
	//self.minigun_hud["gun"].alignX = "right";
	//self.minigun_hud["gun"].alignY = "bottom";
	//self.minigun_hud["gun"].horzAlign = "right";
	//self.minigun_hud["gun"].vertAlign = "bottom";
	//self.minigun_hud["gun"].alpha = 0.55;
	//self.minigun_hud["gun"].x = xpos;
	//self.minigun_hud["gun"].y = ypos;
	////self.minigun_hud["gun"] fadeOverTime( 0.05 );
	////self.minigun_hud["gun"] SetShader( "hud_hind_cannon01", 64, 64 );
	//self.minigun_hud["gun"] SetShader( "hud_icon_m60e4", 64, 64 );
	//self.minigun_hud["gun"].hidewheninmenu = true;
		
	
	xsync = -100;

	self.minigun_hud["button"] = newHudElem();
	self.minigun_hud["button"].alignX = "center";
	self.minigun_hud["button"].alignY = "bottom";
	self.minigun_hud["button"].horzAlign = "user_right";
	self.minigun_hud["button"].vertAlign = "user_bottom";
	self.minigun_hud["button"].foreground = true;
	self.minigun_hud["button"].x = -155+xsync;
	self.minigun_hud["button"].y = -10;
	self.minigun_hud["button"] SetText("^3[{+attack}]^7");
	self.minigun_hud["button"].hidewheninmenu = true;
	self.minigun_hud["button"].fontscale = 1.0;
}


//******************************************************************************
// self = player
//******************************************************************************

hud_create_bar( xpos, ypos, width, height, shader )
{
	if(!IsDefined(self.minigun_overheat_bar))
	{
		self.minigun_overheat_bar = newHudElem();
	}

	bar = self.minigun_overheat_bar;

	bar.alignX = "left";
	bar.alignY = "bottom";
	bar.horzAlign = "right";
	bar.vertAlign = "bottom";
	bar.x = xpos;
	bar.y = ypos;
	bar.width = width;
	bar.height = height;
	//bar.foreground = true;
	bar.frac = 0;
	bar.color = ( 1.0, 1.0, 1.0 );
	bar.shader = shader; 
	bar setShader( shader, width, height );
	
	return( bar );
}


//*****************************************************************************
// self = player
//*****************************************************************************

hud_rocket_think()
{
	self endon( "death" );

	woods_mode = "missiles_active";
	woods_num_missiles = level.woods.bulletsInClip;
	
	bowman_mode = "missiles_active";
	bowman_num_missiles = level.bowman.bulletsInClip;

	visible_alpha = 0.55;
	alpha_fade_time = 0.05;


	/****************************************************/
	/* While the boat is alive, update the hud missiles */
	/****************************************************/

	while( level.boat.boat_health > 0 )
	{
		/*************************/
		/* Update Woods Missiles */
		/*************************/
		
		switch( woods_mode )
		{
			case "missiles_active":
				if( level.woods.bulletsInClip < woods_num_missiles )
				{
					index = woods_num_missiles;
					self.rocket_hud["woods" + index] SetShader( "hud_hind_rocket", 48, 48 );
					self.rocket_hud["woods" + index].alpha = 0;
					self.rocket_hud["woods" + index] fadeOverTime( alpha_fade_time );
				}
				woods_num_missiles = level.woods.bulletsInClip;
				if( woods_num_missiles <= 0 )
				{
					woods_mode = "missiles_reloading";
				}
			break;

			case "missiles_reloading":
				if( level.woods.bulletsInClip > 0 )
				{
					woods_num_missiles = level.woods.bulletsInClip;
					for( i=0; i< woods_num_missiles; i++ ) 
					{
						index = 1 + i;
						self.rocket_hud["woods" + index] SetShader( "hud_hind_rocket", 48, 48 );
						self.rocket_hud["woods" + index].alpha = visible_alpha;
						self.rocket_hud["woods" + index] fadeOverTime( alpha_fade_time );
					}
					woods_mode = "missiles_active";
				}
			break;
		}


		/**************************/
		/* Update Bowman Missiles */
		/**************************/

		switch( bowman_mode )
		{
			case "missiles_active":
				if( level.bowman.bulletsInClip < bowman_num_missiles )
				{
					index = bowman_num_missiles;
					self.rocket_hud["bowman" + index] SetShader( "hud_hind_rocket", 48, 48 );
					self.rocket_hud["bowman" + index].alpha = 0;
					self.rocket_hud["bowman" + index] fadeOverTime( alpha_fade_time );
				}
				bowman_num_missiles = level.bowman.bulletsInClip;
				if( bowman_num_missiles <= 0 )
				{
					bowman_mode = "missiles_reloading";
				}
			break;

			case "missiles_reloading":
				if( level.bowman.bulletsInClip > 0 )
				{
					bowman_num_missiles = level.bowman.bulletsInClip;
					for( i=0; i< bowman_num_missiles; i++ ) 
					{
						index = 1 + i;
						self.rocket_hud["bowman" + index] SetShader( "hud_hind_rocket", 48, 48 );
						self.rocket_hud["bowman" + index].alpha = visible_alpha;
						self.rocket_hud["bowman" + index] fadeOverTime( alpha_fade_time );
					}
					bowman_mode = "missiles_active";
				}
			break;
		}
	
		wait( 0.02 );
		
		
		/*******************************************/
		/* Is it time to turn off the Missile Hud? */
		/*******************************************/

		if( IsDefined("woods_bowman_m202_ended") )
		{
			if( flag( "woods_bowman_m202_ended" ) )
			{
				break;
			}
		}
	}
	
	self hud_rocket_destroy();
}




/**********************************************************************************************************/
/* Make sure the state of the shaders visible state matches the number of missiles  woods and bowman have */
/*																										  */
/* self = player																						  */
/**********************************************************************************************************/

hud_rocket_reset_m202()
{
	while( !IsDefined( self.rocket_hud ) )  // wait for hud to be restored after save reload
	{
		wait( 0.1 );
	}
	
	for( index=1; index<=4; index++ )
	{
		if( level.woods.bulletsInClip >= index )
		{
			self.rocket_hud["woods" + index].alpha = 0.55;
			self.rocket_hud["woods" + index] fadeOverTime( 0.05 );
		}
		else
		{
			self.rocket_hud["woods" + index].alpha = 0;
			self.rocket_hud["woods" + index] fadeOverTime( 0.05 );
		}
	}
	
	for( index=1; index<=4; index++ )
	{
		if( level.bowman.bulletsInClip >= index )
		{
			self.rocket_hud["bowman" + index].alpha = 0.55;
			self.rocket_hud["bowman" + index] fadeOverTime( 0.05 );
		}
		else
		{
			self.rocket_hud["bowman" + index].alpha = 0;
			self.rocket_hud["bowman" + index] fadeOverTime( 0.05 );
		}
	}
}


//*****************************************************************************
//*****************************************************************************

hud_rocket_destroy()
{
	self.rocket_hud["border_left"] Destroy();
	self.rocket_hud["woods1"] Destroy();
	self.rocket_hud["woods2"] Destroy();
	self.rocket_hud["woods3"] Destroy();
	self.rocket_hud["woods4"] Destroy();
	self.rocket_hud["button"] Destroy();
	self.rocket_hud["border_right"] Destroy();
	self.rocket_hud["bowman1"] Destroy();
	self.rocket_hud["bowman2"] Destroy();
	self.rocket_hud["bowman3"] Destroy();
	self.rocket_hud["bowman4"] Destroy();
}


//*****************************************************************************
// self = player
//*****************************************************************************

hud_minigun_destroy()
{
	if( isdefined(self.minigun_hud) )
	{
		//self.minigun_hud["gun"] Destroy();
		self.minigun_hud["button"] Destroy();
	}
}


//******************************************************************************
// Check if the player is attacking
//******************************************************************************

is_attacker_player_controller_boat( attacker )
{
	if( isplayer( attacker ) 
   			|| ( isdefined( attacker.targetname ) 
   			&& ( ( attacker.targetname == "woods_ai" ) || ( attacker.targetname == "bowman_ai" ) ) ) )
   	{
		return( 1 );
   	}
   	return( 0 );
}


//******************************************************************************
// Warn the player not to attack the bridge while the mortar objective is active
//******************************************************************************

dont_shoot_enter_base_trigger()
{
	level endon( "river_mortar_objective_complete" );

	bridge_trigger = GetEnt( "enter_base_bridge_damage_trigger", "targetname" );
	
	if( !isdefined(bridge_trigger) )
	{
		return;
	}
	

	/**************************************/
	/* Wait for the breige to take damage */
	/**************************************/   	
   		
	vo_index = randomint( 4 );
   	
   	last_vo_time = 0;
	vo_repeat_delay = 3;
   		
   	while( 1 )
	{
   		bridge_trigger waittill( "damage", amount, attacker, direction, point, dmg_type, modelName, tagName );

		time = GetTime();

		// Don't damage the bridge, its just a warning message 
		amount = 0;
	
   		player_attacking = 0;
   			
   		// Check if the player is attacking, its a warning trigger, don't do any damage
   		if( is_attacker_player_controller_boat( attacker ) )
   		{
  			player_attacking = 1;
   		}

		// Don't play the vo too often
		if( player_attacking )
		{
			dt = ( time - last_vo_time ) / 1000;
			if( dt < vo_repeat_delay )
			{
				player_attacking = 0;
			}
		}

		// If the player is attacking, maybe give a warning
		if( player_attacking )
		{
			if( vo_index == 0 )
			{
				level.woods thread maps\river_vo::playVO_proper( "save_it_mason", 0.2 );
			}
			else if( vo_index == 1 )
			{
				level.bowman thread maps\river_vo::playVO_proper( "no_we_need_to_destroy", 0.2 );
			}
			else if (vo_index == 2 )
			{
				level.woods thread maps\river_vo::playVO_proper( "no_mason_save_it", 0.2 );
			}
			else
			{
				level.bowman thread maps\river_vo::playVO_proper( "not_yet_mason_we_need", 0.2 );
			}
			
			vo_index++;
			if( vo_index >= 4 )
			{
				vo_index = 0;
			}

			last_vo_time = time;
		}
   	}
   	
   	bridge_trigger delete();
}


//******************************************************************************
// self = level
//******************************************************************************

attack_the_mortars_reminder()
{
	level endon( "river_mortar_objective_complete" );

	warning_pos = ( -14359, -58511, 0 );
	
	too_close_distance = 1900;
	vo_index = 0;

	last_warning_time = -10000;
	warning_time_delay = 8;

	while( 1 )
	{
		player_pos = ( level.player.origin[0], level.player.origin[1], 0 );
		
		dist = Distance( warning_pos, player_pos ); 
		if( dist < too_close_distance )
		{
			time = GetTime();
			dt = ( time - last_warning_time ) / 1000;
			
			if( dt > warning_time_delay )
			{
				last_warning_time = time;
			
				if( vo_index == 0 )
				{
					level.woods maps\river_vo::playVO_proper( "wrong_way_mason", 0.2 );
				}
				else
				{
					level.woods maps\river_vo::playVO_proper( "no_mason_not_that_way", 0.2 );
				}
			
				vo_index++;
				if( vo_index > 1 )
				{
					vo_index = 0;
				}
			}
		}
		
		//IPrintLnBold( "DIST:" + dist );
		
		wait( 0.1 );
	}	
}


//******************************************************************************
// Player blows up building 1 on left start island
//******************************************************************************

player_shoots_left_start_building_1()
{
	level endon( "river_mortar_objective_complete" );

	building_trigger = GetEnt( "left_start_building_1", "targetname" );
	if( !isdefined(building_trigger) )
	{
		return;
	}
	
	health = 150;
	
	// Wait for player damage
  	while( 1 )
	{
   		building_trigger waittill( "damage", amount, attacker, direction, point, dmg_type, modelName, tagName );
   	
		if( is_attacker_player_controller_boat(attacker) )
		{
			if( amount > 30 )	// make sure its the player machine gun, not the front gunner
			{
				health -= amount;
				if( health <= 0 )
				{
					level.woods thread maps\river_vo::playVO_proper( "yeah_fucking_tear_em_up", 0.2 );
					break;
				}
			}
		}
   	}
   	
   	building_trigger delete();
}


//******************************************************************************
// Player blows up building 2 on left start island
//******************************************************************************

player_shoots_left_start_building_2()
{
	level endon( "river_mortar_objective_complete" );

	building_trigger = GetEnt( "left_start_building_2", "targetname" );
	if( !isdefined(building_trigger) )
	{
		return;
	}
	
	health = 150;
		
	// Wait for player damage
  	while( 1 )
	{
   		building_trigger waittill( "damage", amount, attacker, direction, point, dmg_type, modelName, tagName );
   	
		if( is_attacker_player_controller_boat(attacker) )
		{
			if( (amount > 30) )	// make sure its the player machine gun, not the front gunner
			{
				health -= amount;
				if( health <= 0 )
				{
					level.reznov thread maps\river_vo::playVO_proper( "show_no_mercy", 0.2 );
					break;
				}
			}
		}
   	}
   	
   	building_trigger delete();
}


//******************************************************************************
// Player blows up RPGs to right of base island
//******************************************************************************

player_shoots_right_of_base_island()
{
	level endon( "boat_drive_done" );
	
	building_trigger = GetEnt( "base_island_on_right", "targetname" );
	if( !isdefined(building_trigger) )
	{
		return;
	}
	
	health = 150;
	
	// Wait for player damage
  	while( 1 )
	{
   		building_trigger waittill( "damage", amount, attacker, direction, point, dmg_type, modelName, tagName );
   	
		if( is_attacker_player_controller_boat(attacker) )
		{
			if( amount > 30 )	// make sure its the player machine gun, not the front gunner
			{
				health -= amount;
				if( health <= 0 )
				{
					level.woods thread maps\river_vo::playVO_proper( "shred_those_bastards", 0.2 );
					break;
				}
			}
		}
   	}
   	
   	building_trigger delete();
}


//******************************************************************************
// Player blows up vorkuta building
//******************************************************************************

player_shoots_vorkuta_building()
{
	level endon( "boat_drive_done" );
	
	if( !isdefined(level.vorkuta_building_vo) )
	{
		level.vorkuta_building_vo = 0;
	}

	building_trigger = GetEnt( "base_island_vorkuta", "targetname" );
	if( !isdefined(building_trigger) )
	{
		return;
	}
	
	health = 150;
	
	// Wait for player damage
	while( level.vorkuta_building_vo == 0 )
  	{
   		building_trigger waittill( "damage", amount, attacker, direction, point, dmg_type, modelName, tagName );
   	
   		if( level.vorkuta_building_vo == 0)
   		{
   			if( is_attacker_player_controller_boat(attacker) )
			{
				if( amount > 30 )	// make sure its the player machine gun, not the front gunner
				{
					health -= amount;
					if( health <= 0 )
					{
						level.reznov thread maps\river_vo::playVO_proper( "its_just_like_back_in", 0.2 );
						level.vorkuta_building_vo = 1;
						break;
					}
				}
			}
		}
   	}
   	
   	building_trigger delete();
}


//******************************************************************************
// Player blows up vorkuta building (well the one to the right of it)
//******************************************************************************

player_shoots_vorkuta_building_nextto()
{
	level endon( "boat_drive_done" );
	
	if( !isdefined(level.vorkuta_building_vo) )
	{
		level.vorkuta_building_vo = 0;
	}

	building_trigger = GetEnt( "base_island_vorkuta_nextto", "targetname" );
	if( !isdefined(building_trigger) )
	{
		return;
	}
	
	health = 150;
	
	// Wait for player damage
  	while( level.vorkuta_building_vo == 0 )
	{
   		building_trigger waittill( "damage", amount, attacker, direction, point, dmg_type, modelName, tagName );

		if( level.vorkuta_building_vo == 0)
		{
			if( is_attacker_player_controller_boat(attacker) )
			{
				if( amount > 30 )	// make sure its the player machine gun, not the front gunner
				{
					health -= amount;
					if( health <= 0 )
					{
						// If we are limiting the lines here, then this one gets to override - MikeA
						level.reznov thread maps\river_vo::playVO_proper( "its_just_like_back_in", 0.2 );
						//level.woods thread maps\river_vo::playVO_proper( "great_shot_mason", 0.2 );
						level.vorkuta_building_vo = 1;
						break;
					}
				}
			}
		}
   	}
   	
   	building_trigger delete();
}


