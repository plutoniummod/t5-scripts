/*===========================================================================
RIVER UTILITIES
 spawn functions
 setup functions
 general utility functions
===========================================================================*/

#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;


//*****************************************************************************
//*****************************************************************************

main()
{	
	/#  // debug only
		all_spawners = GetSpawnerArray();
		
		for(i=0;i<all_spawners.size; i++)
		{
			all_spawners[i] add_spawn_function(::living_actor_count);
		}
		
		//level thread maps\flamer_util::debug_ai();
		
		//level thread show_actor_count();
	#/
	
	setup_mg_damage();
	
	wait_for_first_player();
	
	player = get_players()[0];
	player SetClientDvar("cg_objectiveIndicatorFarFadeDist", 80000);
	player = get_players()[0];
	player SetClientDvar( "missilewatermaxdepth", 1000 );
	player SetClientDvar("phys_ai_collision_mode", 1);  // turn on new collision dvar		
	
	// Initialize friednly fire
	init_friendly_fire_stats();
	
	// enable alt weapon drops
	enable_random_alt_weapon_drops(); 
	set_random_alt_weapon_drops( "ft", false ); // disable the flamethrower alt weapon
	set_random_alt_weapon_drops( "gl", false ); // disable the grenade launcher alt weapon
	set_random_alt_weapon_drops( "mk", true ); // enable the masterkey alt weapon
}


//*****************************************************************************
//*****************************************************************************

init_friendly_fire_stats()
{
	// min_participation / friend_kill_points = number of friendly troops that the player must kill to fail mission
	level.friendlyfire[ "friend_kill_points" ] = -1;  // this is the number of points per friendly you kill
	level.friendlyfire[ "min_participation" ] = -200000; // point threshold the player has to reach before friendly fire mission failure activates
	
	// Handles friednly fire for River
	level thread river_friendly_fire();

}


//*****************************************************************************
//*****************************************************************************

friendly_fire_mission_failure()
{
	level.player thread maps\_friendlyfire::missionfail();
}


//*****************************************************************************
// player.participation = players friendly fire count
//*****************************************************************************

//
// TODO:-
//
// OPEN - attacking friendly boats
//

river_friendly_fire()
{
	flag_wait( "starting final intro screen fadeout" );

	wait( 1 );
		
	// Should never happen unless using a skipto
	if( !isdefined(level.player.participation) )
	{
		level.player.participation = 0;
	}


	/***************************************************************************/
	/* Firendly fire can come from woods, bowman and accidently the bow gunner */
	/***************************************************************************/

	level.friendlyfire_override_attacker_entity = ::river_friendly_fire_attacker_override;

	level.woods.friendly_attack_time = 0;
	level.bowman.friendly_attack_time = 0;
	
	// If the attacker is a vehicle and the owner is the player, don't force the player to be the attacker
	level.player.friendlyfire_attacker_not_vehicle_owner = 1;

	level notify( "friendly_fire_terminate" );
		

	/*****************************************************************/
	/* Loop every frame checking for player friendly fire conditions */
	/*****************************************************************/

	last_participation = level.player.participation;

	vo_last_time = 0;
	vo_delay_time = 1.75;	// 2.0
	vo_guy = "woods";
	vo_woods_index = randomint( 4 );
	vo_bowman_index = randomint( 4 );
	
	
	/**********************************************************************/
	/* If 3 warnings are given in a X amount of time, its mission failure */
	/**********************************************************************/
	
	num_warnings = 0;
	warnings_started_time = 0;
	
	forgive_warning_delay = 5.5;		// Forgive a warning every X seconds
	end_game_warning_num = 4;			// If we reach this number of warnings, its game over


	/**********************************************/
	/* Keep checking for friendly fire casualties */
	/**********************************************/
	
	while( 1 )
	{
		time = GetTime();
	
		/**************************************/
		/* Has the player hit a friendly guy? */
		/**************************************/
		
		if( level.player.participation < last_participation )
		{
			last_participation = level.player.participation;

			/****************************************************/
			/* If its been a while since a vo warning, give one */
			/****************************************************/

			dt = ( time - vo_last_time ) / 1000;
			if( dt > vo_delay_time )
			{
				vo_last_time = time;
			
				/*****************************************************/
				/* Increase the number of warnings, is it game over? */
				/*****************************************************/

				num_warnings++;
				if( num_warnings >= end_game_warning_num )
				{
					level.player friendly_fire_mission_failure();
					return;
				}
				
				warnings_started_time = time;

			
				/***************************************/
				/* Player still has some warnings left */
				/***************************************/
							
				delay = 0.1;
			
				if( vo_guy == "woods" )
				{
					if( vo_woods_index == 0 )
					{
						level.woods thread maps\river_vo::playVO_proper( "no_mason_there_on_our_side", delay );
					}
					else if( vo_woods_index == 1 )
					{
						level.woods thread maps\river_vo::playVO_proper( "what_are_you_doing", delay );
					}
					else if( vo_woods_index == 2 )
					{
						level.woods thread maps\river_vo::playVO_proper( "mason_youre_killing", delay );
					}
					else
					{
						level.woods thread maps\river_vo::playVO_proper( "Friendly fire", delay );
					}
					
					vo_woods_index++;
					if( vo_woods_index >= 4 )
					{
						vo_woods_index = 0;
					}
					vo_guy = "bowman";
				}
				else
				{
					if( vo_bowman_index == 0 )
					{
						level.bowman thread maps\river_vo::playVO_proper( "watch_out_there_ours", delay );
					}
					else if( vo_bowman_index == 1 )
					{
						level.bowman thread maps\river_vo::playVO_proper( "stop_firing_mason", delay );
					}
					else if( vo_bowman_index == 2 )
					{
						level.bowman thread maps\river_vo::playVO_proper( "mason_no_there_our", delay );
					}
					else
					{
						level.bowman thread maps\river_vo::playVO_proper( "cease_fire_friendlies", delay );
					}

					vo_bowman_index++;
					if( vo_bowman_index >= 4 )
					{
						vo_bowman_index = 0;
					}
					vo_guy = "woods";
				}
			}
		}
		
		/***********************************************/
		/* OK, no friendly casualties, update counters */
		/***********************************************/
		
		else
		{
			// This is because you get bonus for killing friendlies
			last_participation = level.player.participation;
		
			// Is the player currently in a warning state?
			if( num_warnings )
			{
				dt = ( time - warnings_started_time ) / 1000;
				if( dt > forgive_warning_delay )
				{
					num_warnings--;
					if( num_warnings > 0 )
					{
						warnings_started_time = time;
					}
				}
			}
		}

		wait( 0.01 );
		
		
		/*************************************/
		/* If the boat drive is over, end it */
		/*************************************/
		
		if( flag( "boat_drive_done") == true )
		{
			break;
		}
	}
	
	
	/************************************************/
	/* Switch off friendly fire for the land battle */
	/************************************************/
	
	reset_games_default_friendly_fire_state();
}


//*****************************************************************************
// Reset the games default friendly fire state
//*****************************************************************************

reset_games_default_friendly_fire_state()
{
	// Make sure the global system is on
	level.friendlyFireDisabled = 0;
	
	// Reset the overrides
	level.friendlyfire_override_attacker_entity = maps\_friendlyfire::default_override_attacker_entity;
	level.player.friendlyfire_attacker_not_vehicle_owner = undefined;
	
	// Reset the participation management
	level.player.participation = 0; 
	level.player thread maps\_friendlyfire::participation_point_flattenovertime();
	level.friendlyfire[ "friend_kill_points" ] = -600;
	level.friendlyfire[ "min_participation" ] = -1600;	// when the player hit this number of participation points the mission is failed
}


//*****************************************************************************
//*****************************************************************************

river_friendly_fire_attacker_override( entity, damage, attacker, direction, point, method )
{
	if( isdefined(entity) )
	{
		// If you manage to clip the bow gunner, don't register the kill
		if( isdefined(level.kid) )
		{
			if( entity == level.kid )
			{
				return( level.boat );
			}
		}
	
		// If for some reason its AXIS, don't register the kill
		if( isdefined(entity.team) )
		{
			if( entity.team == "axis" )
			{
				return( level.boat );
			}
		}
	}
	
	// Test Check
//	if( attacker == level.player )
//	{
//		return( level.player );
//	}
	
	time = GetTime();

	woods_bowman_delay = 0.05;

	if( attacker == level.woods )
	{
		dt = ( time - level.woods.friendly_attack_time ) / 1000;
		if( dt > woods_bowman_delay )
		{
			level.woods.friendly_attack_time = time;
			return( level.player );
		}
	}
	
	if( attacker == level.bowman )
	{
		dt = ( time - level.bowman.friendly_attack_time ) / 1000;
		if( dt > woods_bowman_delay )
		{
			level.bowman.friendly_attack_time = time;
			return( level.player );
		}
	}

	return( undefined );
}


//*****************************************************************************
// self = entity we want to check for friendly fire against
//*****************************************************************************

friendly_fire_checker()
{
	self endon( "death" );

	last_boat_hit_time = -1000;
	
	boat_hit_counter = 0;
	hit_warning_number = 5;
	
	ignore_fire_time = 1;		// If the last time we hit a boat is greater then don;t add to counter
	
	while( 1 )
	{
		self waittill( "damage", amount, who, direction, point, type, modelName, tagName );
		
		//***********************************************************************
		// If its a friendly boat, use some tollerance, it must be targetted fire
		// Basically ignore occasional fire
		//***********************************************************************
		
		if( isdefined(self.targetname) && (self.targetname == "friendly_npc_pbr") )
		{
			time = GetTime();
			dt = ( time - last_boat_hit_time ) / 1000;
			last_boat_hit_time = time;
			
			// If we've not hit the boat recently, reset the warning counter
			if( dt > ignore_fire_time )
			{
				boat_hit_counter = 0;
			}

			// Check if we've hit the boat enough times to trigger a warning
			boat_hit_counter++;
			if( boat_hit_counter >= hit_warning_number )
			{
				boat_hit_counter = 0;
			}
			else
			{
				continue;
			}
		}

		
		//*******************************************************
		// We may want a special case that overrides the attacker
		//*******************************************************
		
		override = river_friendly_fire_attacker_override( self, amount, who, direction, point, type );
		if ( isdefined(override) )
		{
			who = override;
		}
		
		if( who == level.player )
		{
			level.player.participation -= 5;
		}
	}
}


/*==========================================================================
FUNCTION: get_array_keys_in_order
SELF: level (not used)
PURPOSE: GetArrayKeys returns keys in reverse order. This function returns 
	them in sequential order.

ADDITIONS NEEDED:
==========================================================================*/
get_array_keys_in_order( array )
{
	if( !IsDefined( array ) )
	{
		PrintLn( "array missing in get_array_keys_in_order" );
		return undefined;
	}
	
	backwards_keys = [];
	backwards_keys = GetArrayKeys( array );
	
	if( backwards_keys.size == 0 )  
	{
		PrintLn( "array passed to get_array_keys_in_order has size 0." );
	}
	
	keys = [];
	
	for( i = backwards_keys.size - 1; i >= 0; i-- )
	{								
		keys[ keys.size ] = backwards_keys[ i ];  // if backwards_keys.size = 4.. keys[3] = backwards_keys[0], etc
	}
	
	return keys;
}

/*==========================================================================
FUNCTION: friendly_fire_instant_fail
SELF: friendly AI doing animations
PURPOSE: we don't want players to kill off friendlies involved in vignettes,
 	but we may want them to die afterwards. this auto-fails the player if 
 	the actor is killed before we allow him to be killed off

ADDITIONS NEEDED: find best way to kill off player
==========================================================================*/
friendly_fire_instant_fail( ender )
{
	if( IsDefined( ender ) ) 
	{
		level endon( ender );
	}
	
	self waittill( "death", attacker );
	
	if( IsPlayer( attacker ) )
	{
		fail_threshold = level.friendlyfire[ "min_participation" ];
		fail_threshold -= 1;  // put player below 
		get_players()[0].participation = fail_threshold;  // this should instantly fail player for friendly fire
	}	
}

living_actor_count()
{
	if(!IsDefined(level.actor_count))
	{
		level.actor_count = 0;
	}
	
	level.actor_count++;
	
	self waittill("death");
	
	level.actor_count--;
}

show_actor_count()
{
	message = NewHudElem();
	message.horizAlign = "left";
	message.vertAlign = "bottom";
	message.x = -0;
	message.y = -0;
	message.font_scale = 1.5;
	message.color = (1.0, 1.0, 1.0);
	message.font = "objective";
	
	if(!IsDefined(level.actor_count))
	{
		level.actor_count = 0;
	}
	
	old_count = level.actor_count;
	
	while(true)
	{		
		wait(0.5);
		
		current_count = level.actor_count;
		if(current_count != old_count)  // change message
		{
			message SetText("Number of active AI: " + current_count);
		}
		
		old_count = current_count;	
	}	
}

Show_vehicle_count()
{
	if(!IsDefined(level.vehicle_count))
	{
		level.vehicle_count = 0;
	}
	
	
}


/*===========================================================================
this function will track how long it takes to complete an event. waits for 
a flag that's passed in as input argument, then prints time in seconds to
console
===========================================================================*/
event_timer(event_name, flag_name)
{
	start_time = GetTime();
	
	flag_wait(flag_name);
	end_time = GetTime();
	total_time = (end_time - start_time)*0.001;  // convert to seconds
//	IPrintLn(event_name + " completed in " + total_time + " seconds");
	
	hud_elem = NewHudElem();
	hud_elem.horizAlign = "left";
	hud_elem.vertAlign = "middle";
	hud_elem.fontScale = 1.5;
	hud_elem.color = (255, 255, 0);
	hud_elem.font = "objective";
	hud_elem SetText(event_name + " completed in " + total_time + " seconds");
	
	wait(10);
	
	hud_elem Destroy();
}


setup_player_boat()
{
	level.boat = GetEnt("player_controlled_boat", "targetname");
	AssertEx(IsDefined(level.boat), "player controlled boat is missing");
	
	// set up nodes for AI pathing
//	level.boat.bow_port_node = GetNode("bow_port_node", "targetname");
//	AssertEx(IsDefined(level.boat.bow_port_node), "bow_port node for boat is missing");
//	level.boat.center_port_node = GetNode("center_port_node", "targetname");
//	AssertEx(IsDefined(level.boat.center_port_node), "center_port node for boat is missing");
//	level.boat.stern_port_node = GetNode("stern_port_node", "targetname");
//	AssertEx(IsDefined(level.boat.stern_port_node), "stern_port node for boat is missing");
//	level.boat.bow_starboard_node = GetNode("bow_starboard_node", "targetname");
//	AssertEx(IsDefined(level.boat.bow_starboard_node), "bow_starboard node for boat is missing");
//	level.boat.center_starboard_node = GetNode("center_starboard_node", "targetname");
//	AssertEx(IsDefined(level.boat.center_starboard_node), "center_starboard node is missing");
//	level.boat.stern_starboard_node = GetNode("stern_starboard_node", "targetname");
//	AssertEx(IsDefined(level.boat.stern_starboard_node), "stern_starboard node for boat is missing");
	
	level.boat setseatoccupied(2, true);
	level.boat setseatoccupied(3, true);
	
	// attach the use trigger
	use_trigger = getent( "player_drive_touch_trigger", "targetname" );
	use_trigger EnableLinkTo();
	use_trigger linkto( level.boat );
	
	level.boat MakeVehicleUnusable();  // this will need to be called in script later to enable it
	level.boat thread maps\_vehicle::friendlyfire_shield();
	level.boat thread maps\river_amb::setup_radio();
//	level.boat thread fake_damage_state();
	OnSaveRestored_Callback(maps\river_util::save_restored_function);	
}


fake_damage_state()  // self = level.boat
{
	while( IsAlive( self ) )
	{
		self waittill( "damage", amount, who );

		//IPrintLnBold( "boat took " + amount + " damage from " + who.targetname );
	}
}

// add models to friendly PBRs, then get ent initializations done

/*===========================================================================
		death_explosion_up10			// Flies up 10 feet in the air.
		death_explosion_back13			// Flies back 13 feet.
		death_explosion_forward13		// etc.
		death_explosion_left11
		death_explosion_right13
===========================================================================*/
setup_friendly_npc_boats()
{
	maps\_vehicle::scripted_spawn( 20 );	
	
	level.friendly_boats = GetEntArray("friendly_npc_pbr", "targetname");
	AssertEx(IsDefined(level.friendly_boats), "friendly_npc_pbr array missing");
	
	for(i=0; i<level.friendly_boats.size; i++)
	{
		level.friendly_boats[ i ].drivepath = 1;
		level.friendly_boats[ i ].vehicleavoidance = 0;
		level.friendly_boats[ i ].takedamage = true;	
		level.friendly_boats[ i ].health = 999999;
		level.friendly_boats[ i ] thread maps\_vehicle::friendlyfire_shield();
		level.friendly_boats[ i ] thread armada_initializations();	
		//level.friendly_boats[ i ] thread end_spline_behavior();
		level.friendly_boats[ i ] thread ent_name_visible( true );
		//level.friendly_boats[ i ].crew = simple_spawn("friendly_pbr_crew_" + level.friendly_boats[ i ].script_int, ::friendly_pbr_crew_spawn_function, level.friendly_boats[ i ] );
		level.friendly_boats[ i ] populate_pbr();
		
		//add_part_to_vehicle( "t5_veh_boat_pbr_antenna_static", level.friendly_boats[ i ] );
		//level.friendly_boats[ i ] attach( "anim_jun_sampan_large_a", "tag_driver" );
	//	level.friendly_boats[ i ] attach( "t5_veh_boat_pbr_antenna_static", "tag_origin" );
	}
}


/*==========================================================================
FUNCTION: populate_pbr
SELF: boat that needs some animated guys on it
PURPOSE: to save AI count by replacing guys with animated models for boat drivepath
	sequence

ADDITIONS NEEDED:
==========================================================================*/
#using_animtree( "generic_human" );
populate_pbr( )
{
	// driver = tag_driver
	driver = spawn("script_model", (0,0,0) );
//	driver character\c_usa_specop_assault::main();
	driver maps\river_anim::redshirt_setup_basic();
	driver UseAnimTree(#animtree);
	driver thread put_actor_in_drivers_seat( self );
	//driver maps\_vehicle_aianim::vehicle_enter( self, "tag_driver" );
	if( IsDefined( self.script_noteworthy ) )
	{
		driver.targetname = "driver_" + self.script_noteworthy;	//fix non deleting driver in pbr - jc
	}
	
	// gunner = tag_gunner_turret1
	gunner = spawn("script_model", (0,0,0) );
//	gunner character\c_usa_specop_assault::main();
	gunner maps\river_anim::redshirt_setup_basic();
	gunner UseAnimTree(#animtree);
	gunner thread put_actor_on_bow_gun( self );	
	//gunner maps\_vehicle_aianim::vehicle_enter( self, "tag_gunner_turret1" );				
}

/*==========================================================================
FUNCTION: ent_name_visible
SELF: entity that you want to keep track of for debug purposes
PURPOSE: make it easier to find the names of things when models look similar;
	for example, friendly boats/crews

ADDITIONS NEEDED:
==========================================================================*/
ent_name_visible( noteworthy )
{
	/#
	if( IsDefined( GetDvar( "ent_names" ) ) )
	{
		if( GetDvar( "ent_names" ) != "" )
		{
			if( IsDefined( noteworthy ) && ( noteworthy == true ) )
			{
				name = self.script_noteworthy;
			}
			else
			{
				name = self.targetname;
			}
			
			while( IsAlive( self ) )
			{
				Print3d( self.origin, name, ( 0, 1, 0 ), 1, 2, 10 );
				wait( 0.5 );
			}
		}
	}
	#/
}

/*==========================================================================
FUNCTION: vehicle_cleanup
SELF: level
PURPOSE: delete all vehicles except those specified as input arguments

ADDITIONS NEEDED: 
==========================================================================*/
vehicle_cleanup( vehicle1, vehicle2 )
{
	if( ( !IsDefined( vehicle1 ) ) && ( !IsDefined( vehicle2 ) ) )
	{
		PrintLn( "no input arguments specified in vehicle_cleanup - deleting all active vehicles" );
	}
	
	active_vehicles = GetEntArray( "script_vehicle", "classname" );
	if( active_vehicles.size == 0 )
	{
		PrintLn( "vehicle_cleanup didn't find any active vehicles" );
		return;
	}
	else
	{
		before_cleaning = active_vehicles.size;
		active_vehicles = remove_dead_from_array( active_vehicles );  // make sure no removed entities make it into loop
		after_cleaning = active_vehicles.size;
		num_corpses = before_cleaning - after_cleaning; 
		if( num_corpses != 0 )
		{
			PrintLn( "vehicle_cleanup removed " + num_corpses + " corpses" );
		}
		
		PrintLn( "vehicle_cleanup found " + active_vehicles.size + " vehicles. cleaning up..." );
		
		for( i = 0; i < active_vehicles.size; i++ )
		{
			if( ( IsDefined( vehicle1 ) && ( IsDefined( active_vehicles[i].targetname ) ) && ( vehicle1.targetname == active_vehicles[i].targetname ) ) )
			{
				continue; // do not delete
			}
			
			if( ( IsDefined( vehicle2 ) ) && ( IsDefined( active_vehicles[i].targetname ) && ( vehicle2.targetname == active_vehicles[i].targetname ) ) )
			{
				continue;  // do not delete
			}
			
			active_vehicles[i] Delete();
		}
		
		active_vehicles = remove_dead_from_array( active_vehicles );
		PrintLn( "vehicle_cleanup done. " + active_vehicles.size + " vehicles are left" );
	}
	
}

friendly_pbr_crew_spawn_function( vehicle_name )  // self = guy on friendly PBR
{
	self set_ignoreall(true);
	self.takedamage = false;
	
	AssertEx(IsDefined(self.script_int), "script_int must be defined on friendly_pbr_crew_guys so you can determine seating");
	
	if(self.script_int == 0)  // driver
	{
		self thread put_actor_in_drivers_seat(vehicle_name);
	}
	else if(self.script_int == 1) // bow gunner
	{
		self thread put_actor_on_bow_gun(vehicle_name);
	}
	
	self waittill("death");
	self Unlink();
}

chinook_setup()
{
	chinook = GetEnt("boat_drag_helicopter", "targetname");
	chinook thread armada_initializations();
	chinook ent_flag_init("blow_up_bridge");
}

armada_initializations()  // self = friendly npc boat
{
	self ent_flag_init("can_move");
	self ent_flag_init( "ignore_speed_check" );
	if(self is_boat())
	{
		self ent_flag_init("stop_for_blockade");
	}
	
	self thread stop_for_blockade();
	
}


stop_for_blockade()
{
	self waittill("stop_for_bridge_blockade");
	
	self ent_flag_set("stop_for_blockade");
	
	flag_wait("blockade_destroyed");
	
	self ent_flag_clear("stop_for_blockade");
}

// physics vehicles can't be killed with damage as of 3/6/2010, so we delete them and
// replace them with a death model
end_spline_behavior()  // self = physics vehicle
{
	self waittill("reached_end_node");
	
	self.takedamage = true;
	
	death_model = Spawn("script_model", self.origin);
	death_model.angles = self.angles;
	
	self maps\_vehicle_turret_ai::disable_turret( 0 );	
	
	if(self.script_int != 1)  // boat#1 doesn't die at the end of its rail
	{
		PlayFX(level._effect["friendly_boat_death"], self.origin);
	//	self Delete();  // "kill" the boat
		self notify("physics_vehicle_death");
	}
	else
	{
		//self redshirts_go_ashore_in_alcove();
	}
	
}

redshirts_go_ashore_in_alcove()  // self = boat
{
	shore_destinations = getstructarray("redshirt_boat_crew_structs", "targetname");
	AssertEx((shore_destinations.size > 0), "shore_destinations for redshirts are missing");
	
	AssertEx((self.crew.size > 0), "crew missing for " + self.targetname);
	AssertEx((shore_destinations.size >= self.crew.size), "need at least as many structs as redshirts in the boat");
	for(i=0; i<self.crew.size; i++)
	{
		self.crew[i] StopAnimScripted();
		self.crew[i] Unlink();
		self.crew[i] maps\river_util::actor_moveto(shore_destinations[i], 2);
	}	
}

/*===========================================================================
pass on a vehicle (boat or helicopter) to make it maintain a similar position
relative to the player's boat. if it's a boat, required ent_flag("ready_for_boat_drive")
be initialized before use
===========================================================================*/
convoy_speed_check_old()  // self = friendly boat or helicopter
{
	self endon("death");
	self endon("stop_speed_check");
	
	if(self maps\_vehicle::is_corpse() == false)
	{
		if(self is_boat())
		{
			threshold_distance = 2000;	
			max_threshold = 4000;		
			vehicle_type = "boat";	
			self ent_flag_wait("ready_for_boat_drive");	
		}
		else if(self is_helicopter())
		{
			threshold_distance = 8000;	
			max_threshold = 10000;	
			vehicle_type = "helicopter";
			self ent_flag_wait("ready_for_boat_drive");	
		}
		else
		{
			//IPrintLnBold("convoy_speed_check can only be used on boats and helicopters");
			threshold_distance = 2000;
			max_threshold = 4000;	
			vehicle_type = "DEFAULT_VEHICLE_TYPE";
		}	
				
		PrintLn(vehicle_type + " #" + self.script_int + " ready for player to move up.");				
		
		new_speed = 30; // arbitrary -  to keep variables in scope
		
		while(true)
		{
			//current_distance = Distance(self.origin, level.boat.origin);
			boat_speed = level.boat GetSpeedMPH();
			current_speed = self GetSpeedMPH();
			
			vector_to_player_boat = level.boat.origin - self.origin;
			forward = AnglesToForward(self.angles);
			
			current_distance = VectorDot(vector_to_player_boat, forward);		
			
			if(current_distance >= 0)  // our vehicle is in front of player's boat, or to the side of it
			{
				if(current_distance > threshold_distance)  // if our vehicle is far from player's boat...
				{
					new_speed = boat_speed-20;  // slow down
				}
				else if(current_distance > max_threshold)
				{
					new_speed = 0;
				}
				else // if distance is within threshold
				{
					new_speed = boat_speed;  // match player boat's speed
				}
			}
			else // our vehicle is behind the player's boat.
			{
				current_distance = current_distance * (-1);  // will be a negative number, and we just want distance now
				PrintLn(vehicle_type + " # " + self.script_int + " is behind the player's boat");
				
				new_speed = boat_speed;  //
				
	//			if(current_distance > threshold_distance)  // if our vehicle is too slow
	//			{
	//				new_speed = boat_speed + 15;  // speed up
	//			}
	//			else if(current_distance > max_threshold)
	//			{
	//				new_speed = boat_speed+25;  // catch up quickly
	//			}
	//			else // our vehicle is within the acceptable threshold
	//			{
	//				new_speed = boat_speed+10;  // maintain speed
	//			}			
			}
			
			if(new_speed <= 0)
			{
				new_speed = 0;
			}
			
			self SetSpeed(new_speed);
			//PrintLn(vehicle_type + " #" + self.script_int + " changing speed to " + new_speed + ". Distance = " + current_distance);				
			
			wait(0.5);
		}
	}
}

/*===========================================================================
heroes: woods, bowman, reznov
TODO: make these a function with multiple input parameters, calling name and
      several spawn functions
===========================================================================*/
setup_hero_squad()
{
	wait_for_first_player();
		
	// WOODS
	woods = GetEnt("woods", "targetname");
	AssertEx(IsDefined(woods), "woods is missing");
	woods add_spawn_function(::woods_behavior);
	woods add_spawn_function( ::init_hero_ent_flags );
	simple_spawn("woods");
	level.woods = GetEnt("woods_ai", "targetname");
	level.woods.animname = "woods";
	AssertEx(IsDefined(level.woods), "woods_ai is missing");
	// Main: Commando_acog_sp, Sidearm: m1911_sp, Grenades: frag_grenade_sp
	level.woods custom_ai_weapon_loadout( "m202_flash_sp_river", "commando_acog_sp", "frag_grenade_sp" );
	level.woods useweaponhidetags( "commando_acog_sp" );

	// BOWMAN	
	bowman = GetEnt("bowman", "targetname");
	AssertEx(IsDefined(bowman), "bowman is missing");
	bowman add_spawn_function(::bowman_behavior);
	bowman add_spawn_function( ::init_hero_ent_flags );
	simple_spawn("bowman");
	level.bowman = GetEnt("bowman_ai", "targetname");
	level.bowman.animname = "bowman";
	AssertEx(IsDefined(level.bowman), "bowman_ai is missing");
	level.bowman custom_ai_weapon_loadout( "m202_flash_sp_river", "commando_acog_sp", "frag_grenade_sp" );
	level.bowman useweaponhidetags( "commando_acog_sp" );
	
	// REZNOV	
	reznov = GetEnt("reznov", "targetname");
	AssertEx(IsDefined(reznov), "reznov is missing");
	reznov add_spawn_function(::reznov_behavior);
	reznov add_spawn_function( ::init_hero_ent_flags );
	simple_spawn("reznov");
	level.reznov = GetEnt("reznov_ai", "targetname");
	AssertEx(IsDefined(level.reznov), "reznov_ai is missing");
	level.reznov.animname = "reznov";
	level.reznov thread wont_disable_player_firing();
	
	// PLAYER
	level.player = get_players()[0];
	level.player.animname = "mason";
	level.mason = level.player;
	
	//
	level.friendly_squad = [];
	level.friendly_squad = array_add(level.friendly_squad, level.woods);
	level.friendly_squad = array_add(level.friendly_squad, level.reznov);
	level.friendly_squad = array_add(level.friendly_squad, level.bowman);
}

woods_behavior()
{	
	self.goalradius = 32;
	self.script_accuracy = 0.5;
	self.overrideActorDamage = ::reduce_friendly_fire_damage;
	self ent_flag_init( "anim_done" );
	self ent_flag_init( "reach_done" );
}

bowman_behavior()
{
	self.goalradius = 32;	
	self.script_accuracy = 0.5;
	self.overrideActorDamage = ::reduce_friendly_fire_damage;
	self ent_flag_init( "anim_done" );
	self ent_flag_init( "reach_done" );
}

reznov_behavior()
{
	self.goalradius = 32;
	self.script_accuracy = 0.5;
	self.overrideActorDamage = ::reduce_friendly_fire_damage;
	self gun_switchto( "commando_acog_sp", "right" );
	self ent_flag_init( "anim_done" );
	self ent_flag_init( "reach_done" );
}

init_hero_ent_flags()
{
	self ent_flag_init( "ready_to_move" );
	self ent_flag_init( "ready_for_boat_drive" );
}

// callback function used to make friendly AI heroes take zero damage when hit by boat turret weapons
reduce_friendly_fire_damage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	// special case to kill them in boat
	if( eAttacker == level.boat && iDamage == self.health * 2 )
	{
		return( iDamage );
	}
	// TODO: add boat guns to this so player can't kill AI with them
	return 0;
}

// this used to spawn in models and reorient angles, Attach takes care of that.
// TODO: replace all calls to this in script with Attach instead
add_part_to_vehicle(boat_part_model_name, vehicle_name)
{
	AssertEx(IsDefined(vehicle_name), "boat is missing.");
	if(!IsDefined(boat_part_model_name))
	{
		AssertMsg(boat_part_model_name + "is not defined as a part of the boat model");
		return;
	}
	
	vehicle_name Attach( boat_part_model_name, "tag_origin_animate");
}


/*===========================================================================
Plays a vignette according to the input parameters. The actors will be spawned
and then play a vignette and do nothing else. They will be cleaned up after
the vignette is finished
-----------------------------------------------------------------------------
THINGS THIS FUNCTION REQUIRES:
----SCRIPT----
vignette_name: this will be used with GetEntArray with "script_noteworthy" KVP
scene_name: this is what's referenced in the animation's scene name 
    example: level.scr_anim["anim_name"]["SCENE_NAME"]
anim_node_name: this is a struct to which the vignette is aligned
scene_ender: flag that signals the end of the vignette
----RADIANT----
script_noteworthy + scene_name
script_animname + .animname (referenced from river_anim.gsc)
===========================================================================*/
general_vignette_function(vignette_name, scene_name, anim_node_name, scene_ender, oneshot_then_loop )
{
	level endon("death");
	
	guys = GetEntArray(vignette_name, "targetname");  // for spawners
	AssertEx((guys.size > 0), vignette_name + " guys are missing in " + scene_name + " scene");
	
	guys_ai = [];  // use this array for once guys are spawned in
	
	for(i=0; i<guys.size; i++)
	{
		guys[i] add_spawn_function(::general_vignette_spawn_function);
	}
	
	guys_ai = simple_spawn( guys );
	
	anim_node = getstruct(anim_node_name, "targetname");
	AssertEx(IsDefined(anim_node), anim_node_name + " anim node for " + scene_name + " " + vignette_name + " is missing");
	
	if( IsDefined( oneshot_then_loop ) && ( oneshot_then_loop == true ) )
	{
		array_thread( guys_ai, ::oneshot_then_loop, scene_name, anim_node );
	}
	else
	{
		for(i=0; i<guys_ai.size; i++)
		{
			anim_node thread anim_loop_aligned(guys_ai[i], scene_name);
		}
	}
	
	if(IsDefined(scene_ender))
	{
		flag_wait(scene_ender);
	
		for(i=0; i<guys_ai.size; i++)
		{
			if( IsAlive(guys_ai[i]))
			{
				guys_ai[i] StopAnimScripted();
				guys_ai[i] Delete();
			}
		}
	}
}

oneshot_then_loop( scene_name, anim_node )  // self = AI
{
	self endon( "death" );

	if( !IsDefined( scene_name ) )
	{
		Print_debug_message( "scene_name missing for " + self.targetname, true );
		return;
	}
	
	if( !IsDefined( anim_node ) )
	{
		Print_debug_message( "anim_node missing for " + self.targetname, true );
		return;
	}	
	
	if( !IsDefined( self.script_animname ) )
	{
		Print_debug_message( "script_animname missing for " + self.targetname, true );
		return;
	}	
	
	loop_animname = self.script_animname + "_loop";
	
	anim_node anim_single_aligned( self, scene_name );
	
	self.animname = loop_animname;
	
	anim_node anim_loop_aligned( self, scene_name );
	
}

// for use with general_vignette_function
general_vignette_spawn_function(flag_name)  // self = AI animating in aftermath beat
{
	self set_ignoreme(true);	
	self set_ignoreall(true);
	
	if(!IsDefined(self.script_animname))
	{
		AssertMsg("script_animname required on " + self.targetname);
	}
}

actor_moveto(destination, time)  // self = AI to be moved
{
	AssertEx(IsDefined(destination), "destination is missing in actor_moveto function");
	
	if(!IsDefined(time))
	{
		time = 1;
	}
	
//	if(IsString(destination))
//	{
//		new_destination = getstruct(destination.targetname, "targetname");
//		AssertEx(IsDefined(new_destination), "destination string is invalid in actor_moveto function AND must be a struct");
//		
//		destination = undefined;
//		destination = new_destination;
//	}
	
	
	
	origin = Spawn("script_origin", self.origin);
	self LinkTo(origin);
	
	origin moveto(destination.origin, time);
	origin waittill("movedone");
	self notify( "fake_teleport_done" );
	
	self Unlink();
	origin Delete();
}

new_actor_moveto(destination, start, time)
{
	AssertEx(IsDefined(destination), "destination is missing in actor_moveto function");
	
	if(!IsDefined(time))
	{
		time = 1;
	}
	
	if(IsDefined(start))  // move to start position if one is defined
	{
		start_position = start;
		
		origin = Spawn("script_origin", self.origin);
		self LinkTo(origin);
		origin moveto(start_position.origin, 0.1);  
		self waittill("movedone");
		self Unlink();
	}

	origin = Spawn("script_origin", self.origin);
	self LinkTo(origin);
	
	origin moveto(destination.origin, time);
	origin waittill("movedone");
	self Unlink();
	origin Delete();
}


setup_C5_nose_section()
{
	nose = GetEnt( "plane_nose", "targetname" );	
	if( !IsDefined( nose ) )
	{
		AssertMsg( "plane_nose is missing, level is broken!" );
	}
	
	nose Hide();  
}


// make guys on sampans die easily and have poor accuracy
sampan_spawn_function()
{
	self.health = 1;
	self.accuracy = 0.5;
}


/*===========================================================================
 this will move the squad of friendly PBRs with the player as it goes through the level.
 location_for_skipto references a targetname. The location_for_skipto SHOULD
 be a vehicle node so the path can resume. this function only covers placement; movement
 will be done inside level scripts
===========================================================================*/
move_friendly_boats(location_for_skipto)
{
	AssertEx((level.friendly_boats.size > 0), "level.friendly_boats are missing");
	
	positions = GetVehicleNodeArray(location_for_skipto, "targetname");
	AssertEx((positions.size > 0), "positions for move_friendly_boats are missing");
	
	to_delete = [];
	
	// loop through boats to see if it can find a match on the script_int value it uses
	for(i=0; i<level.friendly_boats.size; i++)
	{
		level.friendly_boats[i].found_correct_position = false;
		
		for(j=0; j<positions.size; j++)
		{
			if(level.friendly_boats[i].script_int == positions[j].script_int)
			{
				level.friendly_boats[i].origin = positions[j].origin;
				level.friendly_boats[i].angles = positions[j].angles;
				level.friendly_boats[i].found_correct_position = true;
				level.friendly_boats[i] thread go_path(positions[j]);
				level.friendly_boats[i] SetSpeed( 0 );
			}	
			
			level.friendly_boats[i] ent_flag_set("can_move");  // need to manually set this for skipto
		}
		
		// once for loop is done, check parameter ".found_correct_position". if it didn't find
		// one, add it to a seperate array so you can delete it safely. the boat will be assumed
		// dead if it doesn't find a pair
		if(level.friendly_boats[i].found_correct_position == false)
		{
			to_delete = array_add(to_delete, level.friendly_boats[i]);
			PrintLn("level.friendly_boats # " + level.friendly_boats[i].script_int + " has no accompanying node. Deleting!");
		}
	}
	
	array_delete(to_delete);
}


/*==========================================================================
FUNCTION: set_flag_on_death
SELF: an entity, probably AI or vehicle
PURPOSE: send out a custom notification when self dies
		originally for use in conjunction with update_objective_on_death, 
		but can be used elsewhere.

ADDITIONS NEEDED: move to river_util
==========================================================================*/
set_flag_on_death( flag_to_set )
{
	AssertEx( IsDefined( flag_to_set ), "flag_to_set is missing. required for set_flag_on_death" );
	
	if( !IsDefined( level.flag[ flag_to_set ] ) )
	{
		flag_init( flag_to_set );
	}
	
	self waittill( "death" );
	
	flag_set( flag_to_set );
	
}

/*===========================================================================
purpose: pass in one parameter, a script_noteworthy, and be able to:
1) spawn a sampan from it
2) spawn guys on top of it (from specified spawner, then move him)
3) send it down a rail
-----------------------------------------------------------------------------
CONVENTIONS FOR RADIANT: targetname for vehiclenodes and spawners are the SAME
-script_int on each vehicle node AND spawner to make it spawn the correct guys
===========================================================================*/
sampan_spawner_setup(section_name, kill_at_end_of_spline)
{
	sampans = GetVehicleNodeArray(section_name, "targetname");
	AssertEx((sampans.size > 0), "sampan starts for " + section_name + " are missing");

	for(i=0; i<sampans.size; i++)
	{
		sampans[i] thread individual_sampan_setup(section_name, kill_at_end_of_spline);  // not using array_thread since it doesn't support input arguments
	}
}

delete_me_after_flag(flag_name, delay_time)
{	
	self endon("death");
	
	if(!IsDefined(flag_name))
	{
		//IPrintLnBold("flag_name is not defined for spawner " + self.targetname);
	}
	
	flag_wait(flag_name);
	
	if(IsDefined(delay_time))
	{
		wait(delay_time);
	}
	
	self die();
}

/*===========================================================================
this function currently supports 2 vehicle types: boat_sampan and truck_gaz63_quad50
-if guys are supposed to be on a vehicle, their targetname needs to match the 
 script_noteworthy on the vehicle itself
-----------------------------------------------------------------------------
-vehicle targeting start node for spline is required
-vehicle with any guys that should be riding on it should have the same
 script_noteworthy as their spawner name
===========================================================================*/
vehicle_setup( target, alt_fire, engagement_distance )  // self = vehicle
{
	self endon("death");
	
	if( ( self.vehicletype == "boat_sampan_physics" ) || ( self.vehicletype == "boat_sampan" ) )
	{
//		AssertEx(IsDefined(self.script_int), "script_int needs to be defined on all vehicles used with vehicle_setup function");
		AssertEx(IsDefined(self.target), "each vehicle used with vehicle_setup needs a target to tell the vehicle where to go_path");
		AssertEx(IsDefined(self.script_noteworthy), "script_noteworthy is required on sampans to find correct AI spawners");
		
		if( ( flag( "boat_drive_done") == true ) && ( !IsDefined( self.ent_flag[ "landing_done"] ) ) )
		{
			ent_flag_init( "landing_done" );
		}
		
		if( flag( "boat_drive_done" ) == true )
		{
			simple_spawn( self.script_noteworthy, ::sampan_guy_function );
		}
		else
		{
			for( i = 0; i < 3; i++ )
			{
				sampan_guys = simple_spawn_single(self.script_noteworthy, ::sampan_guy_function, i );
			}
		}
		
		path_start = GetVehicleNode(self.target, "targetname");
		self.vehicleavoidance = 1;
		self go_path(path_start);
		
		if( flag( "boat_drive_done" ) == false )
		{
			self waittill("reached_end_node");
			
//			// after go_path, it'll be the end of the rail
//			RadiusDamage(self.origin + (0,0,100), 400, 200, 200);  // do radius damage to kill off guys on sampan
//			PlayFX(level._effect["sampan_death"], self.origin);
//			self Delete();	
		}
		else
		{
			self waittill_either( "reached_end_node", "goal" );
			if( IsDefined( self.ent_flag[ "landing_done" ] ) )
			{
				self ent_flag_set( "landing_done" );
			}
		}
		
	}
	else if( self.vehicletype == "boat_patrol_nva" )
	{
		if( IsDefined ( self.targetname ) )
		{
			if( ( self.targetname == "boat_landing_patrol_boat" ) || ( self.targetname == "recapture_pbr_patrol_boat" ) )
			{
				//self.overrideVehicleDamage = ::player_damage_only;
				
				self.gunners = 0;
				self.gunners_killed = 0;
				self.rear_gunner = 0;
				self.front_gunner = 0;
				
				self.front_gunner_struct = Spawn( "script_origin", self GetTagOrigin( "tag_enter_gunner1" ) + ( 0, 0, 50 ) );
				self.front_gunner_struct LinkTo( self );
				self.rear_gunner_struct = Spawn( "script_origin", self GetTagOrigin( "tag_enter_gunner2" ) + ( 0, 0, 50 ) );
				self.rear_gunner_struct LinkTo( self );
				
				self thread patrol_boat_disability_check();
				self thread patrol_boat_death_check();
				self thread damage_state_check();
				
				self waittill( "reached_end_node" );
				flag_set( "patrol_boat_landed" );	
			}
		}	
	}
	else if( ( self.vehicletype == "truck_gaz63_quad50" ) || ( self.vehicletype == "truck_gaz63_quad50_low" )  || ( self.vehicletype == "truck_gaz63_quad50_med" ) )
	{
		PrintLn("gaz63 with quad50 spawned");
		
		if( IsDefined( engagement_distance ) )
		{
			self.engagement_distance = engagement_distance;
		}
		
		self setup_vehicle_damage( alt_fire );
		//self quad50_fires_guns( target, noteworthy_to_wait_for, stop_on_notify, resume_notify  );
	}
	else if(self.vehicletype == "truck_gaz63_troops")
	{
		if(IsDefined(self.script_noteworthy))
		{
			self waittill("reached_end_node");  // temp "drop off guys" solution until you get guys on trucks working
			simple_spawn(self.script_noteworthy);
		}
	}	
	else
	{
		PrintLn("case for " + self.vehicletype + " is not handled by vehicle_setup function yet");
	}
}

damage_state_check()  // self = vehicle
{
	damage_state_1 = self.healthmax * 0.6;
	damage_state_2 = self.healthmax * 0.3;
	
	self.damage_state_1 = false;
	self.damage_state_2 = false;
	
	while( self maps\_vehicle::is_corpse() == false )
	{
		if( self.health > damage_state_1 )
		{
			// do nothing
		} 
		else if( ( self.health < damage_state_1 ) && ( self.health > damage_state_2 ) )
		{
			if( self.damage_state_1 == false )
			{
				PlayFX( level._effect[ "chinook_smoke" ], self.origin );
				self.damage_state_1 = true;
			}
			else
			{
				// it's already in this state; do nothing
			}
		}
		else if( self.health < damage_state_2 )
		{
			if( self.damage_state_2 == false )
			{
				// find some effect for this state
				self.damage_state_2 = true;
			}
			else
			{
				// it's already in this state; do nothing
			}
		}
	
		wait( 2 );		
	}
}

vehicle_player_damage_only( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, damageFromUnderneath, modelIndex, partName )
{
	if( eInflictor != get_players()[0] )
	{
		//IPrintLnBold( "zero damage" );
		return 0;  // don't do any damage from non-player sources
	}
	else
	{
		//IPrintLnBold( "player did " + iDamage * 3 + " damage to " + self.targetname + ". HP remaining: " + self.health );
		return (iDamage * 3);
	}
	
	//IPrintLnBold( "player damage function hit" );
}

/*==========================================================================
FUNCTION: actor_player_damage_only
SELF: AI that we want only the player doing damage to
PURPOSE: to eliminate possibility of specific guys getting killed early

ADDITIONS NEEDED:
==========================================================================*/
actor_player_damage_only( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	if( ( eAttacker == get_players()[0] ) || ( eAttacker == level.boat ) )
	{
		return iDamage;	
	}
	else if( sWeapon == "m202_flash_sp_river" )
	{
		return iDamage;
	}
	else
	{
		iDamage = 0;
		return iDamage;
	}
}

scripted_damage_sources_only( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	if( IsDefined( self._damage_source ) )
	{
		if( eAttacker == self._damage_source )
		{
			iDamage = iDamage;
		}
		else
		{
			iDamage = 0;
		}
	}
	else
	{
		Print_debug_message( self.targetname + "is missing ._damage_source", true );
	}
	
	return iDamage;
}
sampan_guy_function( seat_num )  // self = guy on sampan
{
	AssertEx(IsDefined(self.target), "target needs to defined for sampan_guy_function - shows which sampan to attach to");
	
	sampan = GetEnt(self.target, "targetname");	
	
	self.health = 1;
	self.accuracy = 0.5;
	self.overrideActorDamage = ::actor_player_damage_only;
	
	if( IsDefined( seat_num ) )
	{
		if( seat_num == 0 )
		{
			seat_position = "tag_passenger3";
		}
		else if( seat_num == 1 )
		{
			seat_position = "tag_passenger2" ;
		}
		else if( seat_num == 2 ) 
		{
			seat_position = "tag_driver";
		}
		else if (seat_num == 3 )
		{
			seat_position = "tag_passenger1";
		}
		else
		{
			//IPrintLnBold( self.targetname + " has an unhandled seat_num value" );
			seat_position = "tag_passenger3";
		}
		
		if( seat_num != 0 )
		{
			if( self.weapon == "rpg_river_infantry_sp" )  // if RPG isn't main hand, switch to it instead of whatever else he's carrying
			{
				self gun_switchto( "AK74u_sp", "right" );
			}
		}
		else
		{
			self thread maps\river_util::RPG_fire_prediction( 6500, 0.5, 1.1, true, undefined, 60, 100 );  // only medium shots
		}
	}
	else
	{
		if( IsDefined( self.script_int ) )
		{
			if( self.script_int == 0 )
			{
				seat_position = "tag_passenger3";
			}
			else if( self.script_int == 1 )
			{
				seat_position = "tag_passenger2" ;
			}
			else if( self.script_int == 2 ) 
			{
				seat_position = "tag_driver";
			}
			else if (self.script_int == 3 )
			{
				seat_position = "tag_passenger1";
			}
			else
			{
				//IPrintLnBold( self.targetname + " has an unhandled script_int value" );
				seat_position = "tag_passenger3";
			}
		}
		else
		{			
			seat_position = "tag_passenger3";
			//IPrintLnBold( "script_int is required on spawner " + self.targetname );
		}
	}
	
	self LinkTo(sampan, seat_position, (0,0,0), (0,0,0));
	
	if( !IsDefined( sampan.occupants ) )
	{
		sampan.occupants = [];
	}
	
	sampan.occupants array_add( sampan.occupants, self );
}

sampan_landing_function( wait_flag )  // self = AI
{	
	self endon( "death" );
	
	AssertEx(IsDefined(self.target), "target needs to defined for sampan_guy_function - shows which sampan to attach to");
	
	self set_ignoreme( true );  // so they don't get killed early by friendly AI
	self set_ignoreall( true );
	sampan = GetEnt(self.target, "targetname");	
	
	seat_position = "tag_driver";
	
	if( IsDefined( self.script_int ) )
	{
		if( self.script_int == 0 )
		{
			seat_position = "tag_passenger3";
		}
		else if( self.script_int == 1 )
		{
			seat_position = "tag_passenger2" ;
		}
		else if( self.script_int == 2 ) 
		{
			seat_position = "tag_driver";
		}
		else if (self.script_int == 3 )
		{
			seat_position = "tag_passenger1";
		}
		else
		{
			//IPrintLnBold( self.targetname + " has an unhandled script_int value" );
			seat_position = "tag_passenger3";
		}
	}
	else
	{
		AssertMsg( "script_int is required on spawner " + self.targetname );
	}
		
	if( sampan.script_int == 100 ) // boat's script_int
	{
		exit_positions = getstructarray( "sampan_landing_1", "targetname" );
		node_locations = "hill_charger_nodes";
	}
	else if( sampan.script_int == 101 ) 
	{
		exit_positions = getstructarray( "sampan_landing_2", "targetname" );
		node_locations = "boat_defenders_nodes";	
	}
	else if( sampan.script_int == 102 ) 
	{
		exit_positions = getstructarray( "sampan_landing_3", "targetname" );
		node_locations = "sniper_support_enemy_cover_nodes";
	}
	else if( sampan.script_int == 103 ) 
	{
		exit_positions = getstructarray( "sampan_landing_4", "targetname" );
		node_locations = "sniper_support_enemy_cover_nodes";
	}		
	else if( sampan.script_int == 104 ) 
	{
		exit_positions = getstructarray( "alcove_sampan_landing_1", "targetname" );
		node_locations = "sniper_support_enemy_cover_nodes";
	}
	else if( sampan.script_int == 105 ) 
	{
		exit_positions = getstructarray( "alcove_sampan_landing_2", "targetname" );
		node_locations = "sniper_support_enemy_cover_nodes";
	}	
	else
	{
		//IPrintLnBold( self.targetname + " doesn't know where to go once his sampan lands" );
		exit_positions = getstructarray( "sampan_landing_1", "targetname" );
		node_locations = "sniper_support_enemy_cover_nodes";
	}
	
	AssertEx( ( exit_positions.size > 0 ), "exit positions missing for " + self.targetname );
	
	self LinkTo(sampan, seat_position, (0,0,0), (0,0,0));	
	
	sampan waittill_either( "near_goal", "reached_end_node" );
	if( IsDefined( sampan.ent_flag[ "landing_done" ] ) )
	{
		sampan ent_flag_set( "landing_done" );
	}
	
	self actor_moveto( random( exit_positions ) );
	
	if( IsDefined( wait_flag ) )
	{
		self set_ignoreall( true );
		flag_wait( wait_flag );
		self set_ignoreall( false );
	}
	
	self set_ignoreme( false );
	self set_ignoreall( false );
	
	nodes = GetNodeArray( node_locations, "targetname" );
	AssertEx( ( nodes.size > 0 ), "nodes missing for landing point" );
	goal = random( nodes );
	
	self SetGoalNode( goal );
}

sampan_landing_death_counter()  // self = guy on sampan that's trying to land
{
//	if( IsDefined( self.target ) )
//	{
		sampan = GetEnt( self.target, "targetname" );
//	}
//	else
//	{
//		AssertMsg("sampan missing for " + self.targetname );
//	}
	
	AssertEx( IsDefined( sampan ), "sampan missing for sampan_landing_death_counter" );	
	
	if( !IsDefined( sampan.lander_count ) )
	{
		sampan.lander_count = 0;
	}
	
	sampan.lander_count++;
	
	self waittill( "death" );
	
	if(sampan ent_flag( "landing_done" ) == true )
	{
		// do nothing, sampan has landed
	}
	else
	{
		sampan.lander_count--;
	}
	
	if( sampan.lander_count == 0 )
	{
		sampan SetSpeedImmediate( 0, 15, 15 );  // stop sampan if all guys are dead
		sampan ent_flag_set( "landing_done" );
		sampan notify( "fire_RPG" );
	}
}

// what this does: spawns destructible sampan script_vehicle with guys to go on it
individual_sampan_setup(sampan_spawner_name, kill_at_end_of_spline) // self = sampan's vehicle start node
{	
	if(IsDefined(self.script_int))
	{
		sampan = SpawnVehicle("dest_jun_sampan_large_d0", sampan_spawner_name + self.script_int, "boat_sampan", self.origin, self.angles, "dest_jun_sampan_large");
		wait(0.05);
		
		guys = simple_spawn(sampan_spawner_name + "_" + self.script_int + "_guys", ::sampan_spawn_function);
		
//		guys = simple_spawn(sampan_spawner_name + "_guys", ::sampan_spawn_function);
		AssertEx((guys.size > 0), "guys are missing for " + sampan_spawner_name);
		
		wait(0.1);
		
		origins = [];
		origins[0] = sampan GetTagOrigin("tag_passenger3");
		origins[1] = sampan GetTagOrigin("tag_passenger2");
		
		angles = [];
		angles[0] = sampan GetTagOrigin("tag_passenger3");
		angles[1] = sampan GetTagOrigin("tag_passenger2");
		
		for(i=0; i<1; i++)  // NOT arbitrary. only 1 guy per sampan right now
		{
			guys[i] Teleport(origins[1], angles[1]);
		}
		
		wait(0.25);
		
		sampan go_path(self);	
		
		if(IsDefined(kill_at_end_of_spline))
		{
			if(kill_at_end_of_spline == true)
			{
				RadiusDamage(sampan.origin + (0,0,100), 400, 200, 200);  // do radius damage to kill off guys on sampan
				PlayFX(level._effect["sampan_gun_death"], sampan.origin );
				sampan Delete();
				PrintLn("sampan dies - end of rail");
			}
		}
	}
	else
	{
		//IPrintLnBold("script_int needs to be defined on the start nodes for the sampans");
		return;
	}	

}

/*===========================================================================
"bow_gunner" anim needs to be defined in CSV and in anim load. This only makes 
a guy animate then links him to the gun. turret AI is handled in "enable_bow_turret_fire"
===========================================================================*/
put_actor_on_bow_gun(vehicle_name, use_bow_gun)  // self = AI to be put on bow gun of PBR
{	
	self endon("death");

	AssertEx(IsDefined(vehicle_name), "vehicle name is required parameter for put_actor_on_bow_gun function");
	
	//self.animname = "bow_gunner";
	
	self enter_vehicle( vehicle_name, "tag_gunner_turret1" );
	
//	vehicle_name thread anim_loop(self, "boat_anims");
	
//	self LinkTo(vehicle_name, "tag_gunner_turret1", (0,0,0), (0,0,0));
	
	if( ( IsDefined( use_bow_gun ) ) && ( use_bow_gun == true ) )
	{
		vehicle_name thread enable_bow_turret_fire();
	}
	else
	{
		vehicle_name setseatoccupied( 1, true );	// this is normally handled in enable_bow_turret_fire, but set it since skipped
	}
	
	self.isonvehicle = true;
}

patrol_boat_gunner( patrol_boat_name, gun_number )  // self = AI that is about to become a patrol boat gunner
{	
//	self endon( "death" );
	
	self set_ignoreme( true );
	self set_ignoreall( true );
	
	AssertEx( IsDefined( gun_number ), "gun_number is a required parameter in patrol_boat_gunner function for " + self.targetname );
	
	self.patrol_boat_gunner_number = gun_number;
//	self thread patrol_boat_gunner_death_check( patrol_boat_name );
	
	AssertEx( IsDefined( patrol_boat_name ), "patrol_boat_name is missing in patrol_boat_gunner function" );
	
	if( !IsDefined( patrol_boat_name.gunners ) )
	{
		patrol_boat_name.gunners = 0;
		patrol_boat_name.front_gunner = 0;
		patrol_boat_name.rear_gunner = 0;
		patrol_boat_name.gunners_killed = 0;
	}
	else
	{
		if( gun_number == 1 )
		{
			patrol_boat_name.gunners++;
		}
		else
		{
			// don't increment since only front gunner goes toward counts
		}
	}
	
	self.animname = "gunner";
	
//	patrol_boat_name thread anim_loop( self, "patrol_boat_crew" );
	
	if( gun_number == 1 )
	{
		gunner_seat = "tag_gunner1";
		patrol_boat_name.front_gunner = 1;		
	}
	else if( gun_number == 2 )
	{
		gunner_seat = "tag_gunner2";
		patrol_boat_name.rear_gunner = 1;	
	}
	else
	{
		gunner_seat = "tag_gunner_turret1";
		//IPrintLnBold( "unhandled case for patrol boat gunner used on " + self.targetname );
	}
	
	self LinkTo( patrol_boat_name, gunner_seat, ( 0, 0, 0 ), ( 0, 0, 0 ) );
	self AllowedStances( "stand" );
	self.isonvehicle = true;
	
	if( !IsDefined( self._turret_gunners_targets ) )
	{
		self._turret_gunners_targets = [];
		self._turret_gunners_targets[ 0 ] = get_players()[0];
		self._turret_gunners_targets[ 1 ] = level.woods;
		self._turret_gunners_targets[ 2 ] = level.bowman;
		self._turret_gunners_targets[ 3 ] = level.reznov;
	}
	
	//patrol_boat_name maps\_vehicle_turret_ai::set_forced_targets( get_players()[0] );
//	patrol_boat_name maps\_vehicle_turret_ai::enable_turret( gun_number - 1, "mg", "allies" );  // turn on boat's AI turret	
	patrol_boat_name thread patrol_boat_fires_guns( 0, undefined, self._turret_gunners_targets, "patrol_boat_landed", 2.5 );
	PrintLn( "patrol boat bow gun enabled" );
		
	self waittill( "death" );

	level._time_of_death_patrol_boat_gunner = GetTime();
	
//	patrol_boat_name maps\_vehicle_turret_ai::disable_turret( gun_number - 1 );
	patrol_boat_name notify( "turn_off_guns" );
	PrintLn( "patrol boat bow gun DISABLED" );
	
	if( gunner_seat == "tag_gunner1" )
	{
		patrol_boat_name.front_gunner = 0;	
		patrol_boat_name.gunners--;
		patrol_boat_name.gunners_killed++;		
	}
	else if( gunner_seat == "tag_gunner2" )
	{
		patrol_boat_name.rear_gunner = 0;
	}
	else
	{
		//IPrintLnBold( "FIX THIS CASE" );
	}
}

patrol_boat_gunner_death_check( patrol_boat_name )  // self = AI on patrol boat gun
{
	AssertEx( IsDefined( patrol_boat_name ), "patrol_boat_name required for patrol_boat_gunner_death_check" );
	
	self waittill( "death" );
	if( IsDefined( patrol_boat_name.gunners ) )
	{
		//IPrintLnBold( "gunners parameter missing in patrol_boat_gunner_death_check on " + self.targetname );
	}
	else
	{
		patrol_boat_name.gunners--;
	}
	
	if( patrol_boat_name maps\_vehicle::is_corpse() == false )
	{
		if( IsDefined( self.patrol_boat_gunner_number ) )
		{
			patrol_boat_name maps\_vehicle_turret_ai::disable_turret( self.patrol_boat_gunner_number - 1 );
		}
		else
		{
			//IPrintLnBold( "patrol_boat_gunner_number is missing on " + self.targetname );
		}
	}
	else
	{
		// do nothing, patrol boat is dead already
	}
}

put_actor_in_drivers_seat(vehicle_name)  // self = AI to be "driving" pbr
{
	self endon("death");

	AssertEx(IsDefined(vehicle_name), "vehicle name is required parameter for put_actor_in_drivers_seat function");
	
	tag = "tag_gunner_turret1";
	
	self.animname = "pbr_driver";
	
	origin = Spawn( "script_model", vehicle_name GetTagOrigin ( tag ) );
	origin.angles = vehicle_name GetTagAngles( tag );
	origin SetModel( "tag_origin" );
	
	origin LinkTo( vehicle_name );

	self LinkTo( origin, "tag_origin", ( 0,0,0 ), ( 0,0,0 ) );
	
	//vehicle_name thread anim_loop(self, "boat_anims");
	origin thread anim_loop_aligned( self, "boat_anims", "tag_origin" );
	
	
	self.isonvehicle = true;
}

remove_actor_from_drivers_seat(vehicle_name)  // self = AI
{
	self endon("death");
	AssertEx(IsDefined(vehicle_name), "vehicle name is required parameter for remove_actor_from_drivers_seat function");
	
	self StopAnimScripted();
	self Unlink();
	self.isonvehicle = false;
}


/*===========================================================================
	vehicle_name thread anim_loop(self, "boat_anims");
	
	self LinkTo(vehicle_name, "tag_gunner_turret1", (0,0,0), (0,0,0));
===========================================================================*/
put_reznov_on_player_controlled_gun()
{
	level.reznov endon("death");
	
//	level thread add_dialogue_line("Reznov", "I will shoot while you drive, comrade. Point out the things you want to die.");
	
	level.reznov.animname = "reznov";
	
	level.reznov set_ignoreall( true );
	level.reznov AllowedStances("stand");
	
	level.boat thread anim_loop_aligned(level.reznov, "boat_anims", "tag_gunner_turret4" ); // 
	level.reznov LinkTo( level.boat , "tag_gunner_turret4", (0,0,200), (0,0,0) );	// 
	
//	gunner_node = GetNode("boat_driver_gunner_node", "targetname");
//	level.reznov actor_moveto(gunner_node);
//	
//	level.reznov LinkTo(level.boat);
}

reznov_leaves_player_controlled_gun()
{
	level.reznov endon("death");
	
	level.reznov Unlink();
	
	level.reznov StopAnimScripted();
	
	level.reznov AllowedStances("stand", "crouch", "prone");
	
	level.reznov set_ignoreall( false );
}

// note to clarify potential confusion: driver SEAT = 0, bow gun seat = 1. turret 0 is bow gun
enable_bow_turret_fire()  // self = vehicle (friendly/player's PBR)
{
	if(IsDefined(level.boat getseatoccupant( 1 )))
	{
		//IPrintLnBold("cannot put an actor in bow gun since it's occupied.");
	}
	else
	{
		self setseatoccupied( 1, true);
		self.turret_audio_override = true;
		self.turret_audio_ring_override_alias = true;
	  self.turret_audio_override_alias = "wpn_btr_fire_loop_npc";
	  self.turret_audio_ring_override_alias = "wpn_btr_fire_loop_ring_npc";
		self maps\_vehicle_turret_ai::enable_turret( 0, "mg", "axis");  // turn on boat's AI turret
	}
}

disable_bow_turret_fire(guy)  // self = vehicle (friendly/player's PBR)
{
	if(IsDefined(guy))
	{
		self maps\_vehicle_turret_ai::disable_turret( 0 );
		//self maps\river_jungle::vehicle_unload_single( guy, 0 );  // leaving this comment in case we need this elsewhere
		if( !IsDefined( level.boat getseatoccupant( 1 ) ) ) // if there is nobody in the seat, set it to occupied. the player should never get in this gun
		{			
			//self setseatoccupied(1, true);
		}
		guy StopAnimScripted();
		guy Unlink();
		guy.isonvehicle = false;
	}
	else
	{
		//IPrintLnBold("nobody in the gunner's seat");
	}
}

setup_quad50_truck(vehicle_node_name)  // self = level
{
	AssertEx(IsDefined(vehicle_node_name), "setup_zpu_truck requires a vehicleNode targetname to work");
	path_node = GetVehicleNode(vehicle_node_name, "targetname");
	
	quad50_truck = SpawnVehicle("t5_veh_truck_gaz63", vehicle_node_name + "_quad50_truck", "truck_gaz63_quad50", path_node.origin, path_node.angles);
	
	quad50_truck thread go_path(path_node);
	
	quad50_truck thread quad50_fires_guns();
}

// this function gets an array of goal volumes, then threads the monitor_goalvolume function on each one
monitor_spawners(volume_noteworthy)
{
	AssertEx((IsDefined(volume_noteworthy)), "volume_noteworthy is a required input parameter for monitor_spawners function");
	volumes = GetEntArray(volume_noteworthy, "script_noteworthy");
	AssertEx((volumes.size > 0), "volumes are missing for " + volume_noteworthy);
	array_thread(volumes, ::monitor_goalvolume);
}


// checks to see if a player is within a goal volume, then waits until he exits it. after the player
// leaves, all enemy AI within that goal volume will be deleted
monitor_goalvolume()  // self = goal volume
{
	threshold = 2;
	wait_time = 0.75;
	
	// wait until the player touches goal volume
	while(true)
	{
		if(get_players()[0] IsTouching(self))
		{
			break;
		}
		else
		{
			wait(wait_time);
		}
	}

	PrintLn("player is now inside volume: " + self.targetname);
	
	start_time = GetTime();
	time_outside = 0;
	
	if(!IsDefined(self.target))  // must be first volume in series
	{		
		while(time_outside < threshold )  // loop forever until player leaves volume for 3 seconds or more
		{
			if(get_players()[0] IsTouching(self) == false)
			{
				time_outside++;
			}
			else
			{
				time_outside = 0;
			}
			
			wait(wait_time);
		}
	}
	else  // this volume has a target; check both
	{
		old_volume = GetEnt(self.target, "targetname");
		
		while(time_outside < threshold)
		{
			if((get_players()[0] IsTouching(self) == false) && (get_players()[0] IsTouching(old_volume) == false))
			{
				time_outside++;
			}
			else
			{
				time_outside = 0;
			}
			
			wait(1);
		}
	}
	
	// player has left volume for more than 'threshold' seconds. delete all AI in this area of axis type
	guys = get_ai_touching_volume("axis", self.targetname);
	guys_killed = guys.size;
	spread_array_thread(guys, ::kill_me);
	
	exit_time = GetTime();
	total_time = exit_time - start_time;
	PrintLn("player spent " + (total_time * 0.001) + " seconds inside " + self.targetname + ". Killed off " + guys_killed );
}

kill_me()  // self = ai
{
	if( self.takedamage == false ) 
	{
		self.takedamage = true;
	}
	
	if( IsDefined( self.overrideActorDamage ) )
	{
		self.overrideActorDamage = undefined;
	}
	
	self DoDamage( self.health + 150, self.origin );
}

/*==========================================================================
FUNCTION: NVA_go_to_target
SELF: AI
PURPOSE: simple function that gets the target of AI and makes him run to it, 
		not firing along the way unless fired at

ADDITIONS NEEDED:
==========================================================================*/
NVA_go_to_target( multiple_targets )
{

	self.goalradius = 32;
	
	if(IsDefined(self.target))
	{
		self set_pacifist(true);	
		
		if( IsDefined( multiple_targets ) && ( multiple_targets == true ) )
		{
			goals = GetNodeArray( self.target, "targetname" );
			goal = random( goals );
		}
		else
		{
			goal = GetNode(self.target, "targetname");
		}
		
		self SetGoalNode(goal);
		self waittill("goal");
		self set_pacifist(false);	
	}
}

/*==========================================================================
FUNCTION: launch_guys_near_point
SELF: level
PURPOSE: get a point and radius, then gather all guys within that range and
	physics launch them

ADDITIONS NEEDED:
==========================================================================*/
launch_guys_near_point( reference_object, radius, severity_min, severity_max, team, z_offset )
{
	if( !IsDefined( reference_object ) || !IsDefined( radius ) )
	{
		print_debug_message( "no reference point or radius in launch_guys_near_point" );
		return;
	}
	
	if( !IsDefined( severity_min ) ) 
	{
		severity_min = 200;
	}
	
	if( !IsDefined( severity_max ) )
	{
		severity_max = 250;
	}
	
	if( !IsDefined( team ) )
	{
		team = "axis";
	}
	
	if( !IsDefined( z_offset ) )
	{
		z_offset = ( 0, 0, 0 ); 
	}
	
	guys = GetAIArray( team );
	launcher_guys = get_within_range( reference_object.origin, guys, radius );
	
	for( i = 0; i < launcher_guys.size; i++ )
	{
		scale = RandomIntRange( severity_min, severity_max );
		launcher_guys[ i ] StartRagdoll();
		launcher_guys[ i ] starttanning();
		launcher_guys[ i ] Launchragdoll( scale * VectorNormalize( launcher_guys[ i ].origin - ( reference_object.origin + z_offset ) ) );
		launcher_guys[ i ] DoDamage( launcher_guys[ i ].health + 100, launcher_guys[ i ].origin, get_players()[0] );
		x = RandomInt( 100 );
		if( x <= 25 )
		{
			PlayFXOnTag( level._effect[ "temp_destructible_building_fire_medium" ], launcher_guys[ i ], "tag_eye" );	
		}
	}
}


/*===========================================================================
PURPOSE:	this function sets up vehicle damage parameters for use in the global
         	vehicle damage callback, as well as some firing parameters
USAGE: 		set up all changes to vehicle damage here instead of inside callback;
			this function references it
SELF: vehicle

TO DO:		
===========================================================================*/
setup_vehicle_damage( alt_fire, engagement_distance )
{
	if( self maps\_vehicle::is_corpse() == true )
	{
		PrintLn( "vehicle is dead. aborting setup_vehicle_damage" );
	}
	
	
	if( ( self.vehicletype == "truck_gaz63_quad50" ) || ( self.vehicletype == "truck_gaz63_quad50_low" )  || ( self.vehicletype == "truck_gaz63_quad50_low" ) || ( self.vehicletype == "truck_gaz63_quad50_med" ) ) //-- QUAD50 ---
	{ 
		self.quad50_bursts_to_kill = 4;  // kills player's boat from full in X bursts
		self.quad50_burst_duration = 2;  // length of burst fire (in seconds)
		self.quad50_rounds_per_burst = 20 * self.quad50_burst_duration;  // fires 20 times per seconds max; duration * #frames (20/s)
		if( IsDefined( alt_fire ) && ( alt_fire == true ) )
		{
			self.quad50_burst_min_wait = 0.4;
			self.quad50_burst_max_wait = 1.0;
		}
		else
		{
			self.quad50_burst_min_wait = 2.5;  // random wait floor for time between bursts
			self.quad50_burst_max_wait = 3.5;  // random wait cieling for time between bursts
		}
		
		level._quad50_damage = Int( (  level.boat.healthmax / ( self.quad50_rounds_per_burst * self.quad50_bursts_to_kill ) ) ); 
		

	}

}

setup_mg_damage()
{
		// currently this is based off GDT values, not script defined ones like the quad50 above. the idea is the same.
		// damage = boat's max hp / ( number of bullets it takes to kill boat in a period of X seconds )
		// currently, X = 4 seconds
		
		MG_weapontype = "rus_aa_bipod_stand_big_flash";
		
		firetime = WeaponFireTime( MG_weapontype );
		
		shoreline_MG_bullets_per_second = 1 / 0.06; // thie is fire_rate in the GDT. # bullets fired per second
		shoreline_MG_seconds_to_kill = 6;  // seconds
		level._shoreline_MG_damage = Int( level._player_boat_health / ( shoreline_MG_bullets_per_second * shoreline_MG_seconds_to_kill ) );	
}


quad50_fires_guns( target, noteworthy_to_wait_for, stop_on_notify, resume_notify ) //self == zsu
{
	if( self maps\_vehicle::is_corpse() == true )
	{
		//-- quad50 is already dead so don't shoot
		return;
	}
	
	self endon("death");
	
	self notify("stop_firing");
	self endon("stop_firing");
	
	sound_ent = spawn( "script_origin" , self.origin);
	self thread maps\river_drive::audio_ent_fakelink( sound_ent );
	self thread audio_ent_fakelink_delete(sound_ent);
	self thread fakelink_failsafe(sound_ent);
	
	if( IsDefined( noteworthy_to_wait_for ) )
	{
		self waittill( noteworthy_to_wait_for );
		
		if( IsDefined( stop_on_notify ) && ( stop_on_notify == true ) )
		{
			self SetSpeedImmediate( 0, 30 );
			
			if ( IsDefined( resume_notify ) )  // don't wait unless vehicle is stopped
			{
				level waittill( resume_notify );
				
				self ResumeSpeed( 30 );
			}
		}		
	}	
	
	if( !IsDefined( self.engagement_distance ) )
	{
		engagement_dist = 10000;	
	}
	else
	{
		engagement_dist = self.engagement_distance;
	}
	
	target_within_range = false;
		
	burst_fire_time = self.quad50_burst_duration;
	fire_time = 0;
	
	if( !IsDefined( target ) )
	{
		target = get_players()[0];
	}
	
	self SetTurretTargetEnt( target );
	
	while(IsDefined(self))
	{
		if( target_within_range == true )  // 
		{
			if(fire_time < burst_fire_time )  // && DistanceSquared(self.origin, target.origin) < engagement_dist*engagement_dist
			{
				self FireWeapon();
				//IPrintLnBold( "AA GUN LOOP" );
				sound_ent playloopsound( "wpn_50cal_fire_loop_npc" );
				wait(0.05);
				fire_time += 0.05;
			}
			else
			{
				//IPrintLnBold( "STOP LOOP" );
				sound_ent stoploopsound();
				sound_ent playsound( "wpn_50cal_fire_loop_ring_npc" );
				fire_time = 0;
				random_wait = RandomFloatRange(self.quad50_burst_min_wait, self.quad50_burst_max_wait );
				wait(random_wait);
			}
		}
		else
		{
			if( DistanceSquared( self.origin, target.origin ) < engagement_dist * engagement_dist )
			{
				target_within_range = true;
			}
			
			wait( 0.25 );
		}
	}
}

audio_ent_fakelink_delete(sound_ent)
{
	self waittill( "death" );
	if( IsDefined( sound_ent ) )
	{
		sound_ent delete();
	}
}

fakelink_failsafe(sound_ent)
{
	//level endon( "boat_drive_done" );
	level waittill( "boss_boat_killed" );
	if( IsDefined( sound_ent ) )
	{
		//IPrintLnBold( "failsafe" );
		sound_ent delete();
	}
}

/*==========================================================================
FUNCTION: line_fire
SELF: vehicle with mounted gun
PURPOSE: make vehicle's gun look intimidating by having it fire 

ADDITIONS NEEDED:
	- who to fire at?
	- where will fire start?
	- how long should we lead up to the target?
	- how often should the weapon fire? (rounds/second)
==========================================================================*/
line_fire( target_ent, line_fire_start, leadup_time, rounds_per_second )
{
	//
}


// sWeapons: "rus_aa_bipod_stand", "creek_big_flash_ak47_sp", "ak47_sp", "gaz_quad50_turret", "boat_nva_patrol_turret"

// self = vehicle that has been hit with damage
// eInflictor = who damage is credited to (will be a vehicle or mounted gun if fired by AI/player)
// eAttacker = person using turret/vehicle
check_vehicle_damage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName)
{
	if(self maps\_vehicle::is_corpse() == false)
	{

		if(self.vehicletype == "boat_pbr_player")
		{	
			if(flag("display_boat_hp") == false)  // don't allow boat damage when hp isn't being displayed
			{
				return;
			}
			
			if(IsAI(eInflictor))
			{
				if(eInflictor.team == "allies")
				{
					return;
				}
				else  // axis
				{
					// rpgs do normal damage
					if( sWeapon == "rpg_river_infantry_sp" )
					{
						self.boat_health -= iDamage;
						self.health += iDamage;
						self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
					}
					else if( sWeapon == "rus_aa_bipod_stand_big_flash" )
					{
						//iDamage = 30;
						iDamage = level._shoreline_MG_damage;
						
						iDamage = bunker_damage_calc( eAttacker );
						
						self.boat_health -= iDamage;
						self.health += iDamage;
						self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
					}
//					if( ( sWeapon == "creek_big_flash_ak47_sp" )  || ( sWeapon =="ak47_sp" ) || ( sWeapon == "ak74u_sp" ) )
//					{
//						iDamage = 0; //iDamage-75;  // ak47 damage spread = 85-100
//					}
					else
					{
//						self.boat_health -= iDamage;
//						self.health += iDamage;
//						self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
						return;
					}
				}			
			}
			else if( isplayer( eInflictor ) )
			{
				return;
			}
			else if( ( sWeapon == "rpg_river_missile_sp" ) || ( sWeapon == "m202_flash_sp_river" ) ) // this is the weapon Woods and Bowman use. don't let it damage boat.
			{
				return;
			}			
			else if( IsDefined( eInflictor.vehicletype ) && 
								( ( eInflictor.vehicletype == "boat_pbr_player" ) || ( eInflictor.vehicletype == "boat_pbr" ) ) ) 
			{	
//				if(eInflictor.vehicletype == "boat_pbr_player") // player's own boat
//				{
					return;
//				}
//				else
//				{
//					iDamage = iDamage - 50;  // quad50 damage spread = 45-75, 100 to player
//					self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
//				}
			}
			// 4/29/2010 - T.Janssen - workaround for not being able to check sWeapon for MGs
			//else if( sWeapon == "rus_aa_bipod_stand" )
			else if( IsDefined( einflictor.targetname ) 
						&&( ( eInflictor.targetname == "split_bridge_island_mg" ) 
						|| ( eInflictor.targetname == "split_bridge_left_side_mg" ) 
						|| ( eInflictor.targetname == "split_bridge_right_side_mg" ) 
						|| ( eInflictor.targetname == "s_curve_mg" ) ) )
			{
				iDamage = 10;
				self.boat_health -= iDamage;
				self.health += iDamage;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
			else if( sWeapon == "gaz_quad50_turret" )
			{
				iDamage = level._quad50_damage;
				
				if( IsDefined( eInflictor.targetname ) && ( eInflictor.targetname == "truck_with_gun_north" ) )
				{
					iDamage = Int( level._quad50_damage * 0.5 );
					
					iDamage = ZPU_damage_calc( eAttacker );
				}
								
				self.boat_health -= iDamage;
				self.health += iDamage;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
			else if( sWeapon == "gaz_single50_turret" )
			{
				iDamage = iDamage;  // placeholder until we tune this
				self.boat_health -= iDamage;
				self.health += iDamage;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}			
			else if( sWeapon == "boat_nva_patrol_turret" )  // TODO
			{
				iDamage = 15; // ARBITRARY - CHANGE TO CALCULATED VALUE WHEN ONE IS DECIDED UPON
				self.boat_health -= iDamage;
				self.health += iDamage;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
			else if( IsDefined( eInflictor ) && IsDefined( eInflictor.vteam ) && ( eInflictor.vteam == "allies" ) )
			{
				return;
			}
//			else if( sWeapon == "huey_minigun_gunner" )
//			{
//				return;
//			}
			else if( ( IsDefined( eInflictor ) && ( IsDefined( eInflictor.vehicletype ) ) && ( eInflictor.vehicletype == "boat_sampan_physics" ) ) )  // sampans doing collision damage to player boat
			{
				iDamage = 20;
				self.boat_health -= iDamage;
				self.health += iDamage;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
			else if( IsDefined( eInflictor.vehicletype ) && ( eInflictor.vehicletype == "boat_patrol_nva_physics" ) )
			{
				iDamage = 40;  // collision damage from "boss boat"
				self.boat_health -= iDamage;
				self.health += iDamage;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
				
			}
			else
			{
				self.boat_health -= iDamage;
				self.health += iDamage;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
		}
		else if(self.vehicletype == "boat_pbr")
		{
			if( sWeapon == "gaz_quad50_turret" )
			{
				//iDamage = Int(iDamage * 0.333 );
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
			else if( ( sWeapon == "rpg_river_infantry_sp" ) || ( sWeapon == "ak47_sp" ) || ( sWeapon == "ak74u_sp" ) )
			{
				iDamage = 1;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
			else if ( sWeapon == "m202_flash_sp_river" )  // take 1 damage from Woods/Bowman so notify fires off
			{
				iDamage = 1;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);							
			}
			else if( sWeapon == "pbr_driver_gun" ) // take 1 damage from player's driver gun so notify fires off
			{
				iDamage = 1;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);						
			}
			else
			{
				iDamage = 0;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
		}
		else if( self.vehicletype == "heli_huey_assault_river" )  // helicopters should take damage from HINDS so notify fires off
		{
			if( sWeapon == "hind_rockets_sp" )  // only allow damage with HIND rockets
			{
				iDamage = 1;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);							
			}
			else if( sMeansOfDeath == "MOD_CRUSH" )  // check for collision damage
			{
				if( isdefined( eInflictor ) )  // check to see if collision damage is being done by player boat
				{
					if( isdefined( eInflictor.targetname ) && ( eInflictor.targetname == "player_controlled_boat" ) )
					{
						iDamage = 0;
					}
				}
				
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);							
			}
			else  // friendly helicopters shouldn't take damage from anything else
			{
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);							
			}
		}
		else if( self.vehicletype == "truck_gaz63_single50" || self.vehicletype == "truck_gaz63_single50_low" )
		{
			if( ( sWeapon == "rpg_river_missile_sp" ) || ( sWeapon == "m202_flash_sp_river" ) ) // one hit kill with rockets
			{
				iDamage = 99999;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
			else  // normal damage elsewhere
			{
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
		}
		else if( self.vehicletype == "boat_patrol_nva" )
		{
			player = get_players()[0];
			if( eAttacker != player )
			{
				return 0;  // don't do any damage from non-player sources
			}
			else
			{
				if( IsDefined( eInflictor.classname ) )
				{
					if( ( eInflictor.classname == "grenade" ) || ( eInflictor.classname == "rocket" ) )
					{
						iDamage = Int(self.healthmax * 0.333 );  // kill in three hits with rockets or grenades
					}
					else
					{
						iDamage = Int( iDamage * 0.25 ); // quarter damage with bullets		
					}
				}
				else  // bullet damage
				{
					iDamage = Int( iDamage * 0.25 );
				}
								
			//	IPrintLnBold( "player did " + iDamage * 3 + " damage to " + self.targetname + ". HP remaining: " + self.health );
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false); 
			}
		}
		else if(self.vehicletype == "boat_sampan_physics")
		{			
			if( sWeapon == "pbr_driver_gun"  )
			{				
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
			else if( ( sWeapon == "rpg_river_missile_sp" ) || ( sWeapon == "m202_flash_sp_river" ) )  // one hit kill with missile from woods or bowman
			{
				iDamage = 999999;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
			else if( IsDefined( eInflictor.targetname ) && ( eInflictor.targetname == "player_controlled_boat" ) ) // player boat doing collision damage to sampan
			{
				iDamage = 200;  
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
			else if( sWeapon == "china_lake_sp" )
			{
				iDamage = 99999;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}			
			else
			{
				if( IsAI( eAttacker ) )
				{
					if( !IsPlayer( eAttacker ) )  // non-player AI shouldn't damage sampans
					{
						return;
					}
					else  // player can still damage sampans
					{
						self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
					}
					
				}

				else
				{
					return;
				}
			}
		
			
			if( self.health <= 10 )
			{	
				if(sMeansOfDeath == "MOD_CRUSH")
				{
					iDamage = iDamage + 10000;  // insta-kill sampan
				//	PlayFX(level._effect["sampan_death"], self.origin, AnglesToForward( self.angles ) );	
					
					if( IsDefined( eInflictor.targetname ) )
					{
						if( eInflictor.targetname == "player_controlled_boat" )
						{
							//PlayFX( level._effect[ "bow_effect_on_sampan_death"], level.boat.origin, AnglesToForward( level.boat.angles ) );
						}
					}
					self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
					//self Delete();
					self thread kill_off_sampan( "collision" );
					return;
				}
				else if( sMeansOfDeath == "MOD_RIFLE_BULLET" )
				{
					//iDamage = iDamage + 10000;  // insta-kill sampan
					//PlayFX(level._effect["sampan_gun_death"], self.origin, AnglesToForward( self.angles ) );	
					self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);				
					//self Delete();
					self thread kill_off_sampan( "bullet" );
					return;
				}
				else if( ( sMeansOfDeath == "MOD_EXPLOSIVE" ) || ( sMeansOfDeath == "MOD_PROJECTILE" ) || ( sMeansofDeath == "MOD_PROJECTILE_SPLASH" ) || ( sMeansofDeath == "MOD_IMPACT" ) || ( sMeansOfDeath == "MOD_GRENADE_SPLASH" ) || ( sMeansOfDeath == "MOD_GRENADE" ))
				{
					//iDamage = iDamage + 10000;  // insta-kill sampan
					//PlayFXOnTag(level._effect["sampan_explosive_death"], self, "tag_origin_animate" );	
					self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);				
					//self Delete();
					self thread kill_off_sampan( "explosive" );
					return;				
				}
			}
		}
		else if( ( self.vehicletype == "truck_gaz63_quad50" ) || ( self.vehicletype == "truck_gaz63_quad50_low" )|| ( self.vehicletype == "truck_gaz63_quad50_low" ) || ( self.vehicletype == "truck_gaz63_quad50_med" ) )
		{
			if( sWeapon == "huey_minigun_gunner" )  // no damage from huey miniguns
			{
				return;
			}
			else if( sWeapon == "pbr_driver_gun"  )  // full damage from PBR driver gun
			{				
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
			else if( ( sWeapon == "rpg_river_missile_sp" ) || ( sWeapon == "m202_flash_sp_river" ) )  // one hit kill with missile from woods or bowman
			{
				iDamage = 999999;
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}			
			else if( sWeapon == "gaz_quad50_turret" )  // don't allow vehicle to damage itself
			{
				return;
			}
			else  // should not take damage from any other sources
			{
				return;  
				//self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);				
			}
		}
		else if( IsDefined( self.vehicletype ) && ( self.vehicletype == "boat_patrol_nva_physics" ) )
		{
			if( IsDefined( eInflictor.vehicletype ) && ( eInflictor.vehicletype == "boat_pbr_player" ) )
			{
				iDamage = 40;  // collision damage from "boss boat"
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
			else
			{
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
			}
		}
		else  // chances are it's a quad50
		{
			iDamage = iDamage - 40; // gaz63_quad50_turret damage = 75
			self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);			
		}
	}
}

ZPU_damage_calc( eAttacker )
{
	base_damage =  Int( level._quad50_damage * 0.5 ); // this may not be enough to guaranteed kill player on recruit. test!
	
	dot_threshold = 0;  // anything over this is is normal damage, under = double damage 
	
	vector_to_attacker = eAttacker.origin - self.origin;
	
	dot = VectorDot( AnglesToForward( self.angles ), vector_to_attacker );
	
	if( dot > dot_threshold )
	{
		iDamage = base_damage;
	}
	else
	{
		iDamage = base_damage * 4;  // note: the ZPU does half AA gun damage by default
	}
	
	return iDamage;
}

bunker_damage_calc( eAttacker )
{
	base_damage = 45;  // this may not be enough to guaranteed kill player on recruit. test!
	
	full_damage_dist = 4000;
	
	current_dist = Distance( self.origin, eAttacker.origin );
	
	scale = full_damage_dist / current_dist;
	
	iDamage = Int( base_damage * scale );
	
	return iDamage;
}

kill_off_sampan( death_type )
{
	anim_origin = Spawn( "script_origin", self.origin );  // spawn an anim rigin so the effect will move with physics sampan instead of playing stationary	
	anim_origin LinkTo( self, "tag_origin_animate", ( 0, 0, 0 ), ( 0, 0, 0 ) );	
	
	if( IsDefined( death_type ) )
	{		
		if( death_type == "explosive" )
		{
			PlayFX(level._effect["sampan_explosive_death"], anim_origin.origin, AnglesToForward( self.angles ) );	
		}
		else if( death_type == "collision" )
		{
			PlayFX(level._effect["sampan_death"], anim_origin.origin, AnglesToForward( self.angles ) );	
			PlayFX(level._effect["bow_effect_on_sampan_death"], level.boat.origin, AnglesToForward( level.boat.angles ) );	
		}
		else if( death_type == "bullet" )
		{
			PlayFX(level._effect["sampan_gun_death"], anim_origin.origin, AnglesToForward( self.angles ) );	
		}
		else
		{
			PlayFX(level._effect["sampan_explosive_death"], anim_origin.origin, AnglesToForward( self.angles ) );
		}
	}
	else
	{
		print_debug_message( "kill_off_sampan is missing a death_type: " + self.targetname );
	}
	
	launch_guys_near_point( self, 300, 125, 300, "axis", ( 0, 0, -100 ) );
	
	self Hide();
	
	wait( 1.5 );
	
	self notify( "nodeath_thread" );
	
	wait( 1 ); 
	
	anim_origin Unlink();
	self Delete();
}

monitor_boat_damage_state()  // self = level.boat
{
	self endon("stop_displaying_boat_health");

	flag_set("display_boat_hp"); // make sure flag isn't set here so it doesn't need to be turned on elsewhere manually
	level.boat.takedamage = true;

	if(!IsDefined(level.boat.max_hp)) //boat's health is 44000, but dies at 24000. 20000 of that is a health buffer
	{
		level.boat.max_hp = level._player_boat_health; 	
	}
 
	player = get_players()[0]; 
	player thread boat_health_overlay( level.boat );
}

/*==========================================================================
FUNCTION: vehicle_line_fire
SELF: helicopter with miniguns 
PURPOSE: wrapper function that can be threaded off a helicopter to make things
	easier to read and set up. "vehicle_static_line_fire" function really does
	all the work here

ADDITIONS NEEDED:
==========================================================================*/
vehicle_line_fire( turret_num, start_point, end_point, time, notify_to_wait_for )
{
	if( IsDefined( notify_to_wait_for ) )
	{
		self waittill( notify_to_wait_for );
	}
	
	self maps\river_util::vehicle_static_line_fire( turret_num, start_point, end_point, time );
}

huey_cone_light()
{	
	if( IsDefined( self GetTagOrigin( "tag_flash_gunner4" ) ) )  // if tag doesn't exist, this will return undefined
	{
		PlayFXOnTag( level._effect["huey_spotlight"], self, "tag_flash_gunner4" );
	}	
	else
	{
		PrintLn( "huey_cone_light couldn't find tag to play spotlight effect off of on " + self.targetname );
	}
	
	// Blinking light
	PlayFXOnTag( level._effect["huey_blinking"], self, "tag_origin" );
		
	// Add friendly fire threads to the hueys
	if( flag("boat_docked") == false )
	{
		self.health = 999999;
		// sb41 - turning off for now, the helicopters seem to occasionally collide with the player and cause a warning
		self thread maps\river_util::friendly_fire_checker();
	}
}

helicopter_fires_rockets_at_target(wait_for_notification, target1, target2, num_volleys )  // self = helicopter. should be huey or tags won't work right
{
	self endon( "death" );
	
	AssertEx(IsDefined(wait_for_notification), "wait_for_notification must be defined for helicopter rocket function");
	AssertEx(IsDefined(target1), "target1 must be defined in helicopter_fires_rockets_at_target1!");
	
	self waittill(wait_for_notification);
	
	if( IsDefined( num_volleys ) )
	{
		volleys = num_volleys;
	}
	else
	{
		volleys = 4; // 8 rockets, 2 from each side - tag_rocket_left, tag_rocket_right
	}
	
	scale_forward = 150;

	for(i=0; i<volleys; i++)
	{
		left_launcher = self GetTagOrigin("tag_rocket_left") + (AnglesToForward(self.angles) * scale_forward) + (AnglesToRight(self.angles) * scale_forward * -1);
		right_launcher = self GetTagOrigin("tag_rocket_right") + (AnglesToForward(self.angles) * scale_forward) + (AnglesToRight(self.angles) * scale_forward);		
		
		playsoundatposition ("wpn_rocket_fire_chopper", self.origin);
		MagicBullet("rpg_magic_bullet_sp", right_launcher, target1.origin, self);
		wait(0.25);
		playsoundatposition ("wpn_rocket_fire_chopper", self.origin);
		MagicBullet("rpg_magic_bullet_sp", left_launcher, target1.origin, self);
		wait(0.25 + i);
	}
	
	if( IsDefined( target2 ) )
	{
		wait( RandomFloat( 1.0, 3.0 ) );
		
		for(i=0; i<volleys; i++)
		{
			left_launcher = self GetTagOrigin("tag_rocket_left") + (AnglesToForward(self.angles) * scale_forward) + (AnglesToRight(self.angles) * scale_forward * -1);
			right_launcher = self GetTagOrigin("tag_rocket_right") + (AnglesToForward(self.angles) * scale_forward) + (AnglesToRight(self.angles) * scale_forward);		
			
			playsoundatposition ("wpn_rocket_fire_chopper", self.origin);
			MagicBullet("rpg_magic_bullet_sp", right_launcher, target2.origin, self);
			wait(0.25);
			playsoundatposition ("wpn_rocket_fire_chopper", self.origin);
			MagicBullet("rpg_magic_bullet_sp", left_launcher, target2.origin, self);
			wait(0.25 + i);
		}		
	}
}

save_restored_function()
{
	level.boat maps\river_drive::restore_boat_health();
	
	if(flag("river_pacing_done") == false)  // player takes no damage until he's out of the boat
	{
		wait_for_first_player();
		
		player = get_players()[0];
		player.invulnerable = true; 
		player EnableInvulnerability();
	}
}

keep_player_in_boat()
{
	player = get_players()[0];
	player AllowJump(false);  // no jumping on the boat!
	player AllowMelee( false );	//creates a bug, melee sound when zooming -jc
//	player.overridePlayerDamage = ::demigod_mode_on_boat;
	player EnableInvulnerability();  // to be removed when player leaves boat
	player.invulnerable = true;
	
	/#
	if( IsDefined( GetDvar( "debug_river" ) ) )
	{
		if( GetDvar( "debug_river" ) != "" )
		{
			level.boat MakeVehicleUsable();
		}
	}
	#/
}

let_player_leave_boat()
{
	player = get_players()[0];
	player AllowJump(true);
	player AllowMelee( true );	//turned off at start of level -jc
	player DisableInvulnerability();  // set originally in boat drag section
	player.invulnerable = false;  // remove .invulnerable parameter from callback	
}

demigod_mode_on_boat( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	if( flag( "player_inside_boat" ) == false ) // don't modify anything if player isn't in driveable boat sequence
	{
		return iDamage; 
	}
	else  // player is inside boat; enable "demigod" state
	{
		if( ( self.boat_health - iDamage ) <= 1 )
		{
			iDamage = 0;
			return iDamage;
		}
		else
		{
			return iDamage;
		}
	}
}

patrol_boat_fires_guns(gunner_weapon, is_it_foreshadowing, turret_targets, flag_delay, time_offset, flag_ender )
{
	self endon("death");
	self endon("turn_off_guns");
	if( IsDefined( flag_ender ) )
	{
		level endon( flag_ender );
	}
	
	if( !IsDefined( turret_targets ) )
	{
		targets = [];
		targets = level.friendly_squad;
	}
	else
	{
		if( IsArray( turret_targets ) == false )
		{
			targets = [];
			targets[ targets.size ] = turret_targets;
		}
		else
		{
			// correct case. targets = array and is defined
			targets = [];
			targets = turret_targets;
		}	
	}
	
	if( IsDefined( flag_delay ) )
	{
		flag_wait( flag_delay );
	}
	
	if( IsDefined( time_offset ) )
	{
		wait( time_offset );
	}
	
	if((IsDefined(is_it_foreshadowing)) && (is_it_foreshadowing == true))
	{
		count = 1;
		max_count = 20;
		
		while(1)
		{
			gun_tag = self GetTagOrigin("tag_gunner_barrel" + (gunner_weapon + 1));		
			boat_bow = level.boat GetTagOrigin("tag_gunner1");	
						
			if( SightTracePassed(gun_tag, boat_bow, true, undefined))
			{
				patrol_boat_angles = self.origin + AnglesToForward(self.angles);
				player_boat_angles = level.boat.origin + AnglesToForward(level.boat.angles);
				
				for(count=1; count<max_count; count++)
				{
	//				dot = VectorDot(patrol_boat_angles, player_boat_angles);
	//				normal = VectorNormalize(dot);
					angles = VectorNormalize(patrol_boat_angles - player_boat_angles);
					target = vector_scale(angles, count);
					self SetGunnerTargetVec(target, gunner_weapon);
					self FireGunnerWeapon(gunner_weapon);	
//					count++;
				}
				
				random_time = RandomFloatRange(1.0, 2.0);
				wait(random_time);
			
			}
			else
			{
				wait(0.1);				
			}		
		}
	}
	else
	{
		count_max = 20;
		count = 0;
		focus_target = 0;

		target = random( targets );				
		
		while(1)
		{
			if( focus_target == 0 )
			{
				target = random( targets );		
			}

			self setgunnertargetent( target, (0, 0, 0), gunner_weapon );	
			
			if(Distance2D( target.origin, self.origin ) < 5000) 
			{
				self FireGunnerWeapon(gunner_weapon);
				count++;
			}
			
			if(count >= count_max)
			{
				random_time = RandomFloatRange(1.0, 2.0);
				wait(random_time);
				count = 0;
				
				focus_target++;
			
				if( focus_target >= 3 )  // focus on a target for 3 intervals, then switch
				{
					focus_target = 0;  
				}
			}
			wait(0.1);
			

		}			
	}	
}


stay_in_front_of_player_boat()
{
	self endon("death");
	self endon("stop_speed_check");
	
	if(self maps\_vehicle::is_corpse() == false)
	{
		if(self is_boat())
		{
			threshold_distance = 2000;	
			max_threshold = 4000;		
			vehicle_type = "boat";	
			self ent_flag_wait("can_move");	
		}
		else
		{
			//IPrintLnBold("stay_in_front_of_player_boat can only be used on boats");
			threshold_distance = 2000;
			max_threshold = 4000;	
			vehicle_type = "DEFAULT_VEHICLE_TYPE";
		}	
				
		PrintLn(vehicle_type + " #" + self.script_int + " ready for player to move up.");				
		
		new_speed = 30; // arbitrary -  to keep variables in scope
		
		while(true)
		{	
			if((self ent_flag("stop_for_blockade") == true))
			{
				wait(1);
				continue;
			}	
			
			//current_distance = Distance(self.origin, level.boat.origin);
			boat_speed = level.boat GetSpeedMPH();
			current_speed = self GetSpeedMPH();
			
//			vector_to_player_boat = level.boat.origin - self.origin;
			vector_to_player_boat = AnglesToForward(level.boat.angles);
			forward = AnglesToForward(self.angles);
			
			current_dot = VectorDot(vector_to_player_boat, forward);		
			current_distance = Distance(self.origin, level.boat.origin);
			
			PrintLn(vehicle_type + " # " + self.script_int + " is placed correctly");	
			
			if(current_dot >= 0)  // our vehicle is in front of player's boat, or to the side of it
			{
				if((current_distance > threshold_distance) && (current_distance < max_threshold))  // acceptable range
				{
					new_speed = boat_speed;  // match boat's speed
				}
				else if(current_distance > max_threshold)  // if the boat's too far up...
				{
					new_speed = 0;  // stop it from moving up any farther
				}
				else if(current_distance < threshold_distance) // if distance is within "too close" threshold
				{
					new_speed = boat_speed+15;  // exceed player boat's speed so the player is behind the boat
				}
				else
				{
					PrintLn(vehicle_type + " # " + self.script_int + " is in unhandled situation");	
					new_speed = boat_speed;
				}
			}
			else // our vehicle is behind the player's boat.
			{
				current_distance = current_distance * (-1);  // will be a negative number, and we just want distance now
				PrintLn(vehicle_type + " # " + self.script_int + " is BEHIND the player's boat");
				
				new_speed = boat_speed+30;  //speed up quick. this should never happen.		
			}
			
			if(new_speed <= 0)
			{
				new_speed = 0;
			}
			
			self SetSpeed(new_speed);
			//PrintLn(vehicle_type + " #" + self.script_int + " changing speed to " + new_speed + ". Distance = " + current_distance);				
			
			wait(0.5);
		}
	}	
}

stay_behind_player_boat()
{
	self endon("death");
	self endon("stop_speed_check");
	
	if(self maps\_vehicle::is_corpse() == false)
	{
		if(self is_boat())
		{
			threshold_distance = 2000;	
			max_threshold = 3000;		
			vehicle_type = "boat";	
			self ent_flag_wait("can_move");	
		}
		else
		{
			//IPrintLnBold("stay_in_front_of_player_boat can only be used on boats");
			threshold_distance = 2000;
			max_threshold = 4000;	
			vehicle_type = "DEFAULT_VEHICLE_TYPE";
		}	
				
		PrintLn(vehicle_type + " #" + self.script_int + " ready for player to move up.");				
		
		new_speed = 30; // arbitrary -  to keep variables in scope
		
		while(flag("friendly_boat_speed_checks_done") == false )
		{
			if((self ent_flag("stop_for_blockade") == true))
			{
				new_speed = 0;
				wait(1);
				PrintLn(vehicle_type + " #" + self.script_int + " waiting for blockade to be destroyed");					
				continue;
			}
			
			
			//current_distance = Distance(self.origin, level.boat.origin);
			boat_speed = level.boat GetSpeedMPH();
			current_speed = self GetSpeedMPH();
			
			vector_to_player_boat = AnglesToForward(level.boat.angles);
			forward = AnglesToForward(self.angles);
			
			current_dot = (VectorDot(forward, vector_to_player_boat) * (-1));  // we WANT him to be behind player boat
			current_distance = Distance(self.origin, level.boat.origin);	
			
			if(current_dot >= 0)  // our vehicle is in front of player's boat, or to the side of it
			{
				new_speed = 0;  // stop. this should never happen in this function
				PrintLn(vehicle_type + " # " + self.script_int + " is IN FRONT the player's boat");
			}
			else // our vehicle is behind the player's boat.
			{
//				current_distance = current_distance * (-1);  // will be a negative number, and we just want distance now
				PrintLn(vehicle_type + " # " + self.script_int + " is BEHIND the player's boat");
				
				if((current_distance > threshold_distance) && (current_distance < max_threshold))  // acceptable range
				{
					new_speed = boat_speed;  // match boat's speed to keep pacing
				}
				else if(current_distance > max_threshold)  // if the boat's too ahead
				{
					new_speed = boat_speed+30;  // move up quickly
				}
				else // if distance is within "too close" threshold
				{
					new_speed = boat_speed-20;  // slow down to let the player pass
				}	
			}
			
			if(new_speed <= 0)
			{
				new_speed = 0;
			}
			
			self SetSpeed(new_speed);
			//PrintLn(vehicle_type + " #" + self.script_int + " changing speed to " + new_speed + ". Distance = " + current_distance);				
			
			wait(0.5);
		}
		
		// should only get to this point after flag is set (player on land)
		
		rail_path = GetVehicleNode("boat_1_river_pacing", "targetname");
		AssertEx(IsDefined(rail_path), "rail_path for transition_to_laos is missing");
		self.origin = rail_path.origin;
		self.hasstarted = 0;
		
		self drivepath(rail_path);
		self waittill("reached_end_node");
	}	
}	

convoy_speed_check()
{
		if(self is_boat())
		{
			self ent_flag_wait("can_move");	
			AssertEx(IsDefined(self.script_int), "script_int required for boats in convoy_speed_check");
			if(self.script_int == 1)
			{
				//self thread stay_behind_player_boat();
				self thread snider_convoy_speed_check(-1200);
			}
			else if(self.script_int == 2)
			{
//				self thread stay_in_front_of_player_boat();
				self thread snider_convoy_speed_check();
			}
			else if(self.script_int == 3)
			{
				// do nothing. handled elsewhere
			}
			else
			{
				AssertMsg("unhandled script_int in convoy_speed_check");
			}
		}
		else if(self is_helicopter())
		{
			self thread convoy_speed_check_old();
			
		}
		else
		{
			AssertMsg("convoy_speed_check can only be used on boats and helicopters");
		}		
}

/*===========================================================================
pass on a vehicle (boat or helicopter) to make it maintain a similar position
relative to the player's boat. if it's a boat, required ent_flag("ready_for_boat_drive")
be initialized before use
===========================================================================*/
snider_convoy_speed_check(player_boat_offset)  // self = friendly boat or helicopter
{
	self notify( "stop_speed_check" );  // make sure only one instance of this is running
	self endon( "stop_speed_check" );  
	self endon("death");
	self endon("boat_docked");
	
	if(self maps\_vehicle::is_corpse() == false)
	{
		if(self is_boat())
		{
			threshold_distance = 2000;	
			max_threshold = 4000;		
			vehicle_type = "boat";	
			self ent_flag_wait("can_move");	
		}
		else if(self is_helicopter())
		{
			threshold_distance = 8000;	
			max_threshold = 10000;	
			vehicle_type = "helicopter";
		}
		else
		{
			//IPrintLnBold("convoy_speed_check can only be used on boats and helicopters");
			threshold_distance = 2000;
			max_threshold = 4000;	
			vehicle_type = "DEFAULT_VEHICLE_TYPE";
		}	
				
		PrintLn(vehicle_type + " #" + self.script_int + " ready for player to move up.");				
		
		new_speed = 30; // arbitrary -  to keep variables in scope
		if(!IsDefined(player_boat_offset))
		{
			self.player_boat_offset = 1200;
		}
		else
		{
			self.player_boat_offset = player_boat_offset;
		}
		
		self.try_to_pass_player = false;
		
		while( true )
		{
			if( IsDefined( self.ent_flag[ "can_move" ] ) )
			{
				if( IsDefined( self.ent_flag[ "ignore_speed_check" ] ) )
				{
					if( self ent_flag( "ignore_speed_check" ) )  // assume all speed manipulation is done elsewhere
					{
						while( self ent_flag( "ignore_speed_check" ) )
						{
							wait( 0.3 );
						}
					}
				}
				
				if( self ent_flag( "can_move" ) == true )
				{
					//current_distance = Distance(self.origin, level.boat.origin);
					boat_speed = level.boat GetSpeedMPH();
					current_speed = self GetSpeedMPH();
					
					vector_to_player_boat = level.boat.origin - self.origin;
		
					if( !isdefined(self.pathlookpos) )
					{
						forward = AnglesToForward(self.angles);
					}
					else
					{
						forward = vectornormalize(self.pathlookpos - self.origin);
					}
					
					current_distance = VectorDot(vector_to_player_boat, forward);  // distance scaled by dot	
					dot_dist = current_distance;
					current_distance += self.player_boat_offset;
					
					max_goal_dist_away = 600;
				
					current_distance = clamp( current_distance, max_goal_dist_away * -1, max_goal_dist_away );
		
					speed_scale = 1 + (current_distance / max_goal_dist_away);
		
					if( boat_speed < 15 )
						boat_speed = 15;
										
					if( self.try_to_pass_player == true )
					{
					//	dot = VectorDot( VectorNormalize( forward ), VectorNormalize( vector_to_player_boat ) );
					//	dist = unscaled_dist / dot;
						dot = VectorDot( VectorNormalize( forward ), VectorNormalize( vector_to_player_boat ) );
						dist = Distance( self.orIgin, level.boat.origin );
						
						if( dot < 0.2 )  // check to see if npc boat is already in front of the player 
						{
							self.try_to_pass_player = false;  // turn normal speed scale back on since pass occurred
							continue;
						}
						
						if( dist < 800 )  // pace player boat
						{
						//	IPrintLnBold( self.script_int + " is pacing boat" );
							//Print3d( self.origin, dot_dist, ( 1, 1, 1 ), 1, 2, 2 );
							
							player_boat_forward = AnglesToForward( level.boat.angles );
							//angle_dot = VectorDot( VectorNormalize( forward ), VectorNormalize( player_boat_forward ) );
							
							if( dot > 0.3 )  // case where player's boat would be rammed by npc boat
							{
								//IPrintLnBold( self.script_int + " STOPPING" );
								self SetSpeed( 0 ); 
								wait( 0.05 );
								continue;
							}
							else 
							{
								new_speed = level.boat GetSpeedMPH();
								if( new_speed < 0 )
								{
									new_speed = 0;
								}
								
								self SetSpeed( new_speed );
								wait( 0.05 );
								continue;
							}
						}
						else  // continue normal speed scale function 
						{
							new_speed = boat_speed * speed_scale;
							self SetSpeed( new_speed );
							print_debug_message(vehicle_type + " #" + self.script_int + " changing speed to " + new_speed + ". Distance = " + current_distance);				
							wait( 0.3 );
						}
					}
					else
					{
						new_speed = boat_speed * speed_scale;
						self SetSpeed( new_speed );
						print_debug_message(vehicle_type + " #" + self.script_int + " changing speed to " + new_speed + ". Distance = " + current_distance);				
					}
				}
				else
				{
					maps\river_util::print_debug_message( "boat #" + self.script_int + " is waiting. offset = " + self.player_boat_offset );
					self SetSpeedImmediate( 0, 30 );
				}
			}

			
			
			wait(0.3);
		}
	}
}


manage_triggers(trigger_noteworthy, trigger_state)
{
	AssertEx((IsDefined(trigger_noteworthy) && IsDefined(trigger_state)), "trigger_noteworthy and trigger_state are required for manage_triggers");
	
	triggers = GetEntArray(trigger_noteworthy, "script_noteworthy");
	AssertEx((triggers.size > 0), "triggers missing for manage_triggers function");
	for(i=0; i<triggers.size; i++)
	{
		if(trigger_state == true)
		{
			triggers[i] trigger_on();
		}
		else if(trigger_state == false)
		{
			triggers[i] trigger_off();
		}
		else // not a boolean
		{
			AssertMsg("trigger_state parameter needs to be a boolean value");
		}
	}
	
	if(trigger_state == true)
	{
		PrintLn(trigger_noteworthy + " triggers on");
	}
	else
	{
		PrintLn(trigger_noteworthy + " triggers off");
	}
} 

initialize_ent_flags(ent_flag_name)  // self = AI
{
	AssertEx(IsDefined(ent_flag_name), "ent_flag_name is undefined in initialize_ent_flags");
	ent_flag_init(ent_flag_name);
}

go_to_nodes(node_array_name, ent_flag_delay_name)  // self = AI
{
	AssertEx(IsDefined(node_array_name), "node_array_name is missing for go_to_nodes spawn function");
	node_array = GetNodeArray(node_array_name, "targetname");
	AssertEx((node_array.size > 0), "node_array nodes are missing");
	
	if(IsDefined(ent_flag_delay_name))
	{
		ent_flag_wait(ent_flag_delay_name);
	}
	
	goal = random(node_array);
	count = 0;
	while(IsNodeOccupied(goal) == true)  // if somebody is there, move
	{
		goal = random(node_array);  
		count++;
		
		if(count > 3)
		{
			break;	
		}
	}
	
	self SetGoalNode(goal);	
}

actor_move_group(node_array_targetname) // self = array of AI to be moved
{
	if( !IsArray( self ) )
	{
		actor_array = [];
		actor_array[actor_array.size] = self;
	}
	else
	{
		actor_array = self;
	}
	
	AssertEx( IsDefined( node_array_targetname ), "node_array_targetname is missing in actor_move_group" );
	
	node_array = GetNodeArray( node_array_targetname, "targetname" );
	AssertEx( ( node_array.size > 0 ), "node_array is missing in actor_move_group" );
	AssertEx( ( node_array.size >= actor_array.size ), "number of nodes must exceed number of AI in actor_move_group" );
	
	for( i = 0; i < actor_array.size; i++ )
	{
		actor_array[i] thread actor_moveto( node_array[i] );
	}
}

kill_player_outside_volume( volume_name, endon_flag )
{
	AssertEx( ( IsDefined( volume_name ) && IsDefined( endon_flag ) ), "kill_player_outside_volume requires both a volume name and an endon flag" );
	
	level endon( endon_flag );
	
	volume = GetEnt( volume_name, "targetname" );
	AssertEx( IsDefined( volume ), "volume is missing for kill_player_outside_volume" );
	
	while( flag( endon_flag ) == false )
	{
		if( get_players()[0] IsTouching( volume ) == false )
		{
			player = get_players()[0];
			player DoDamage( player.health + 1, player.origin );
			maps\_utility::missionFailedWrapper();
		}
		
		wait( 1 );
	}
}


wait_for_player_to_use_boat()
{
	use_trigger = getent( "player_drive_touch_trigger", "targetname" );
	player = get_players()[0];
	if( isdefined( use_trigger ) )
	{
		while( 1 )
		{
			trigger_wait( "player_drive_touch_trigger" );
			if( VectorDot( AnglesToForward( player.angles ), AnglesToForward( level.boat.angles ) ) > 0 )
			{
				break;
			}
		}
		detach_player_clip_to_pbr();
		level.boat MakeVehicleUsable();
		level.boat usevehicle( player, 0 );
		player SetLowReady( 0 );
		player AllowSprint( true );
		player SetMoveSpeedScale( 1.0 ); 
		player AllowMelee( false );	//creates a bug, melee sound when zooming -jc
		player AllowAds( true );
		flag_set("player_driving_boat");
	}
	else
	{
		while( get_players()[0] isinvehicle() == false )
		{
			wait( 0.5 );
		}
	}
	
	level notify( "player_using_boat" );
	
	// Setup Boat Specific VO
	level.boat thread maps\river_vo::vo_boat_misc_features();
	level.boat thread maps\river_features::boat_ads_control();
	level.player thread maps\river_features::boat_hud_init( level.boat );
	
	level.boat MakeVehicleUnusable();
}

attach_player_clip_to_pbr( clip_name )
{
	// clip at the opening
	if( clip_name == "player_pbr_clip_opening" )
	{
		if( !isdefined( level.boat.player_clip_opening ) )
		{
			clip = getent( "player_pbr_clip_opening", "targetname" );
			if( isdefined( clip ) )
			{
				level.boat.player_clip_opening = clip;
				level.boat.player_clip_opening.origin = level.boat.origin;
				level.boat.player_clip_opening.angles = level.boat.angles;
				level.boat.player_clip_opening LinkTo( level.boat, "tag_origin" );
			}
		}
	}
	// clip after boat drag
	else if( clip_name == "player_pbr_clip" )
	{
		if( !isdefined( level.boat.player_clip ) )
		{
			clip = getent( "player_pbr_clip", "targetname" );
			if( isdefined( clip ) )
			{
				level.boat.player_clip_opening = clip;
				level.boat.player_clip_opening.origin = level.boat.origin;
				level.boat.player_clip_opening.angles = level.boat.angles;
				level.boat.player_clip_opening LinkTo( level.boat, "tag_origin" );
			}
		}
	}
	// clip at boat exit
	else if( clip_name == "player_pbr_clip_exit" )
	{
		if( !isdefined( level.boat.player_clip_exit ) )
		{
			clip = getent( "player_pbr_clip_exit", "targetname" );
			if( isdefined( clip ) )
			{
				level.boat.player_clip_opening = clip;
				level.boat.player_clip_opening.origin = level.boat.origin;
				level.boat.player_clip_opening.angles = level.boat.angles;
				level.boat.player_clip_opening LinkTo( level.boat, "tag_origin" );
			}
		}
	}
}

detach_player_clip_to_pbr()
{
	if( isdefined( level.boat.player_clip ) )
	{
		level.boat.player_clip unlink();
		level.boat.player_clip.origin = ( 0, 0, 0 );
	}
	if( isdefined( level.boat.player_clip_exit ) )
	{
		level.boat.player_clip_exit unlink();
		level.boat.player_clip_exit.origin = ( 0, 0, 0 );
	}
	
	opening_clip = getent( "player_pbr_clip_opening", "targetname" );
	if( isdefined( opening_clip ) )
	{
		opening_clip delete();
	}
	
	dock_clip = getent( "dock_clip", "targetname" );
	if( isdefined( dock_clip ) )
	{
		dock_clip delete();
	}
}

boss_boat_throw_ai( spawner_name, boat, tag_name )
{
	spawner = getent( spawner_name, "targetname" );
	if( !isdefined( spawner ) )
	{
		return;
	}
	
	guy = simple_spawn_single( spawner_name );
	guy forceteleport( boat GetTagOrigin( tag_name ), boat GetTagAngles( tag_name ) );
	guy.animname = "generic";
	level thread boss_boat_throw_ai_fx( guy );
	guy anim_single( guy, "explosive_death_front" );
}

boss_boat_throw_ai_fx( guy )
{
	// play a fire FX on his back
	fx_linker = spawn( "script_model", guy GetTagOrigin( "J_SpineLower" ) );
	fx_linker.angles = guy GetTagAngles( "J_SpineLower" );
	fx_linker SetModel( "tag_origin" );
	fx_linker Linkto( guy, "J_SpineLower" );
	
	playfxontag( level._effect["fx_fire_sm"], fx_linker, "tag_origin" );
	
	// wait for guy to hit water
	while( isdefined( guy ) )
	{
		water_height = GetWaterHeight( guy.origin );
		if( water_height >= guy.origin[2] )
		{
			// AI hit water surface
			fx_linker delete();
			return;
		}
		wait( 0.05 );
	}
}

// for use with "squad_moves_to_next_safe_point" function
check_for_enemies_within_threshold(dist_threshold, ender_flag, flag_to_wait_for, nearby_enemy_threshold )  // self == AI
{
//	level endon( "squad_moving" );
	AssertEx( IsDefined( ender_flag ), "ender_flag missing in check_for_enemies_within_threshold" );
	
	if( !IsDefined( self.ent_flag[ "ready_to_move" ] ) ) // initialize this if it's missing
	{
		self ent_flag_init("ready_to_move");
	}
	
	if( IsDefined( flag_to_wait_for ) )
	{
		flag_wait( flag_to_wait_for );
	}
	
	if( !IsDefined( level._safe_moveup_dist_threshold ) )
	{
		level._safe_moveup_dist_threshold = 10000;	
	}
	
	if( !IsDefined( dist_threshold ) )
	{
		
	}
	
	if( !IsDefined( nearby_enemy_threshold ) )
	{
		nearby_enemy_threshold = 0;
	}
	
	while( flag( ender_flag ) == false )
	{
		if( flag( "squad_moving" ) == true )
		{
			self ent_flag_clear( "ready_to_move" );
			wait( 1.5 );
			continue;
		}
		
		enemies = GetAIArray( "axis" );
		enemies_in_range = get_within_range( self.origin, enemies, level._safe_moveup_dist_threshold );
		
		if( flag( "squad_stays_with_player" ) == false )
		{
			if( enemies_in_range.size <= nearby_enemy_threshold )
			{
				self ent_flag_set( "ready_to_move" );
			}
			else
			{
				self ent_flag_clear( "ready_to_move" );
			}
		}
		else
		{
			player = get_players()[0];
			
			if( ( enemies_in_range.size <= nearby_enemy_threshold ) && ( ( Distance( player.origin, self.origin ) < 1500 ) || ( VectorDot(AnglesToForward( self.angles ), player GetPlayerAngles() ) >= 0 ) ) )
			{
				self ent_flag_set( "ready_to_move" );
			}
			else
			{
				self ent_flag_clear( "ready_to_move" );
			}
		}
		wait(1.5);
	}
}

/*===========================================================================
this function takes in a mandatory argument "start_point_array", which is an
array of nodes. it's called on an array of AI, which will be the ones moved up
by the function. This function requires a pretty strict naming convention - 
things must be named "start_point_array_<n>", where "<n>" begins at zero and 
ends arbitrarily
-----------------------------------------------------------------------------
TODO: add mandatory endon_flag argument
===========================================================================*/
squad_moves_to_next_safe_point( start_point_array, ender_flag, optional_dialogue, offset, stay_with_player, nearby_enemy_threshold )  // self = array of AI to move
{
	AssertEx( IsDefined( ender_flag ), "required argument ender_flag missing in squad_moves_to_next_safe_point" );
	
	if( IsDefined( offset ) )
	{
		times_squad_has_moved = offset;
	}
	else
	{
		times_squad_has_moved = 0;	
	}
	
	if( !IsArray( self ) )
	{
		squad = [];
		squad = array_add( squad, self );
	}
	else  // it's an array already, so make it into "squad"
	{
		squad = self;  
	}
	
	if( IsDefined( stay_with_player ) )
	{
		if( stay_with_player == true )
		{
			flag_set( "squad_stays_with_player" );
		}
	}
	else
	{
		flag_clear( "squad_stays_with_player" );
	}
	
	// put two mandatory functions on each member of the array. these check for nearby enemies, and make sure
	// fire suppression is ignored when no enemies are close by so move ups are possible
	for( i = 0; i < squad.size; i++ )  
	{
		// check_for_enemies_within_threshold(dist_threshold, ender_flag, flag_to_wait_for, nearby_enemy_threshold )
		squad[i] thread check_for_enemies_within_threshold( undefined, ender_flag, undefined, nearby_enemy_threshold );
		squad[i] thread enable_moveup( ender_flag );
	}
	
	// for first instance, put squad in correct starting position
	nodes = GetNodeArray( start_point_array + times_squad_has_moved, "targetname" );
	AssertEx( ( nodes.size > 0 ), "nodes are missing in squad_moves_to_next_safe_point" );
	for( i = 0; i < squad.size; i++ )
	{
		squad[i] SetGoalNode( nodes[i] );
	}
	
	AssertEx( IsDefined( start_point_array ), "start_point_array for squad_moves_to_next_safe_point is missing" );
			
	// loop until nodes don't have targets
	while( flag( ender_flag ) == false )
	{		
		flag_clear( "squad_moving" );  // reset squad_moving so they can't run through points too quickly
		nodes = GetNodeArray( start_point_array + times_squad_has_moved, "targetname" );
		AssertEx( ( nodes.size > 0 ), "nodes are missing in squad_moves_to_next_safe_point" );		
		
		next_nodes = GetNodeArray( start_point_array + ( times_squad_has_moved + 1 ), "targetname" );  // size can be zero; will exit loop
		
		// find max distance between current nodes and next set, if it exists
		dist_to_next_node = 0; // reset the distance for each loop
		
		for( i = 0; i < nodes.size; i++)  // check every node in this set and the next set for max distance
		{
			for( j = 0; j < next_nodes.size ; j++ )
			{
				new_dist_to_next_node = DistanceSquared( nodes[i].origin, next_nodes[j].origin ); 
				
				if( new_dist_to_next_node > dist_to_next_node )
				{
					dist_to_next_node = new_dist_to_next_node;
				}
			}
		}
	
		// run "check_for_enemies_within_threshold" on each squadmate with max distance threshold we just found
		if( dist_to_next_node == 0 )
		{
			PrintLn( "ender_flag set: " + ender_flag );
			flag_set( ender_flag );  // kill thread
			break;
		}
		else
		{	
			dist_to_next_node = Int( sqrt( dist_to_next_node ) ); // since we used distance squared before, convert to just distance and make it an int
			level._safe_moveup_dist_threshold = dist_to_next_node;
		}
		
		// check for ent flags on each squad mate; if all are set, send notify and move up. Note: these flags should be set in 
		// "check_for_enemies_within_threshold" function	
		while( flag( "squad_moving" ) == false )
		{
			squad_ready_to_move = 0;
			
			for( i = 0; i < squad.size; i++ )
			{
				if( squad[i] ent_flag( "ready_to_move" ) == true )
				{
					squad_ready_to_move++;
				}
			}
			
			// if squad is all clear to move, notify level of the move, clear flags, move squad to next set of nodes
			if( squad.size == squad_ready_to_move)  
			{
				flag_set( "squad_moving" );  // 
				
				if( IsDefined( optional_dialogue ) )
				{
//					level thread add_dialogue_line("Woods", random( level._temp_dialogue_lines[ optional_dialogue ] ) );
				}
				
				
				for( i = 0; i < squad.size; i++ )
				{
					squad[i] ent_flag_clear( "ready_to_move" );
					squad[i] SetGoalNode( next_nodes[i] );
				}
				
			}
			
			wait( 2 );  // check every 2 seconds
		}
		
		times_squad_has_moved++;
		
		wait( 2 ); // don't move up quicker than every few seconds
	}
}

enable_moveup( ender_flag )  // self = AI
{
	while( flag( ender_flag ) == false )
	{
		flag_wait( "squad_moving" );
		
	//	self.ignoresuppression = true;
		
		self waittill("goal");
		
	//	self.ignoresuppression = false;
		
//		wait( 2 );  // goal: flag should be reset by the time it hits top of this loop again
	}
}

patrol_boat_gunner_locality_check()  // self = AI
{
	level endon( "patrol_boat_dead" );
	level endon( "patrol_boat_disabled" );
//	self endon( "death" );  // endon removed due to the waiting for returns for "think" functions to complete
	
	total_possible_gunners = 3;
	
	patrol_boat = GetEnt( "recapture_pbr_patrol_boat", "targetname" );
	while( !IsDefined( patrol_boat ) )
	{
		wait(2);
		patrol_boat = GetEnt( "recapture_pbr_patrol_boat", "targetname" );
	}
	
	dist_threshold = 300;
	
	while(  IsAlive( self ) == true )
	{
		wait( 2 );		
		
		if( ( flag( "patrol_boat_disabled") == true ) || ( flag( "patrol_boat_dead") == true ) )
		{
			break;
		}		
		
		if( patrol_boat.gunners < total_possible_gunners )  // 2 total possible gunners
		{
			if( IsAlive( self ) )
			{			
				validity_check = self patrol_boat_runner_think( patrol_boat );
			}
			else
			{
				break;
			}
			
			if( IsDefined( validity_check ) )
			{
				if( validity_check == true )  // AI can run
				{				
					if( patrol_boat.gunners == 0 )  // final check - is there somebody on the bow gun already?
					{
						if( IsAlive( self ) )
						{
							self thread patrol_boat_gunner( patrol_boat, 1 );
						}
						else
						{
							break;
						}
	//					turret_position = patrol_boat GetTagOrigin( "tag_gunner1" );
	//					gunner_location = patrol_boat.front_gunner_struct;
	//					gun_number = 1;
	//					
	//					self actor_moveto( gunner_location, 2 );
	//					self LinkTo( patrol_boat, "tag_gunner1", ( 0, 0, 0 ), ( 0, 0, 0 )  );
	//					patrol_boat.gunners++;
						
						if( flag( "sniper_support_done" ) )
						{
							patrol_boat thread patrol_boat_fires_guns( 0, undefined, level.woods );
						}
						else
						{
							patrol_boat thread patrol_boat_fires_guns( 0, undefined, self._turret_gunners_targets );
						}
						
	//					self waittill("death");
	//					IPrintLnBold( "boat gunner died" );
	//					patrol_boat.gunners--;
	//					patrol_boat notify( "turn_off_guns" );
						
						break;					
					}
	//				else if( patrol_boat.rear_gunner == 0 )
	//				{
	//					turret_position = patrol_boat GetTagOrigin( "tag_gunner2" );
	//					gunner_location = patrol_boat.rear_gunner_struct;
	//					gun_number = 2;
	//				}
					else  // there's somebody on the bow gun already.
					{
		//				gun_number = 1;
		//				turret_position = patrol_boat GetTagOrigin( "tag_gunner1" );  // no positions available
						//IPrintLnBold( "patrol_boat_gunner_locality_check given unhandled condition" );
						continue;
					}
				
					// this is where animation of some kind would play, but there are no assets for it yet
				}
				else
				{
					wait( 2 );
				}
			}
			else
			{
				break; // AI is dead
			}
		}
	}	
}

//TODO: make this patrol boat specific rather than level specific, since you have 2 patrol boats
// self = AI that wants to go to the patrol boat's gun
// we want one guy max to run to the boat at a time, and it can only happen only every few seconds
patrol_boat_runner_think( patrol_boat )
{
	level endon( "patrol_boat_dead" );
	level endon( "patrol_boat_disabled" );
	
	if( !IsDefined( level._patrol_boat_runners ) )
	{
		level._patrol_boat_runners = 0;
	}
	
	if( !IsDefined( level._patrol_boat_runners_time ) )
	{
		level._time_of_last_runner = 0;
	}	
	
	if( ! IsDefined( level._time_of_death_patrol_boat_gunner ) )
	{
		level._time_of_death_patrol_boat_gunner = 0;
	}
	
	if( !IsDefined( level._gunner_time_of_death_window ) )
	{
		level._gunner_time_of_death_window = 6000; // miliseconds. this is constant.
	}
	
	if( !IsDefined( level._patrol_boat_runner_frequency ) )
	{
		level._patrol_boat_runner_frequency = 6000;  // miliseconds. this is constant.
	}	

	// current time - time of last runner = time_window_check
	level._time_since_last_runner = GetTime() - level._time_of_last_runner;	
	level._time_since_last_gunner = GetTime() - level._time_of_death_patrol_boat_gunner;
	
	if( IsAlive( self ) )
	{
		if( patrol_boat.gunners != 0 )
		{
			//PrintLn( self GetEntityNumber() + " knows all patrol boat gunner positions are occupied already" );
			return false;  // no debug print message here since it'll be spammed
		}
		else if( patrol_boat.gunners == 0 ) // no gunners
		{
			if( level._time_since_last_gunner <= level._gunner_time_of_death_window )
			{
				PrintLn( self getentitynumber() + " wanted to run to the patrol boat, but it's too soon after a gunner died. " );
				return false;
			} 
			else if( level._patrol_boat_runners > 0 )
			{
				//PrintLn( self getentitynumber() + " wanted to run to the patrol boat, but someone else is running already. " );
				return false;
			}
			else if( level._time_since_last_runner < level._patrol_boat_runner_frequency )
			{
				PrintLn( self getentitynumber() + " wanted to run to the patrol boat, but not enough time has elapsed. " );
				return false;
			}
			else if( ( level._patrol_boat_runners == 0 ) 
					 && ( level._time_since_last_runner > level._patrol_boat_runner_frequency ) 
					 && ( level._time_since_last_gunner > level._gunner_time_of_death_window ) )
			{
	
				validity_check = self time_runner();
				if( validity_check == false )
				{
					return false; // did not make it to the boat
				}
				else
				{
					return true;  // made it to the boat
				}
			}		
			else
			{
				//IPrintLnBold( "unhandled case in patrol_boat_runner_think" );
				return false;
			}
		}
		else
		{
			//IPrintLnBold( "ah ha!" );
		}
		
	}
}

time_runner()
{
	if( !IsDefined( level._patrol_boat_runners ) )
	{
		level._patrol_boat_runners = 1;
	}
	else
	{
		level._patrol_boat_runners++;
	}
	
	if( level._patrol_boat_runners > 1 )
	{
		//IPrintLnBold( "MORE THAN ONE PATROL BOAT RUNNER ACTIVE" );
	}	

	patrol_boat_goal_node = GetNode( "patrol_boat_gunner_node", "targetname" );
	AssertEx( IsDefined( patrol_boat_goal_node ), "patrol_boat_goal_node is missing!" );
	
	self SetGoalNode( patrol_boat_goal_node );
	
	ent_num = self GetEntityNumber();  // need to document this since death causes this value to be undefined

	PrintLn( ent_num + " is running to the patrol boat!" );	
	level._patrol_gunner_runner_ent = self GetEntityNumber();
	self.goalradius = 256;
	self set_ignoreme( true );	
	
	self waittill_either( "death", "goal" );
	
	wait( 0.25 );  // give script time to process death if it occurred
	
	level._patrol_boat_runners--;	
	
	if( IsAlive( self ) == true )
	{
		PrintLn( self getentitynumber() + " made it to the patrol boat" );
		return true;
	}
	else
	{
		PrintLn( ent_num + " died trying to get to the patrol boat" );
		
		if( !IsDefined( level._runners_died_trying ) )
		{
			level._runners_died_trying = 0;
		}
		
		level._runners_died_trying++;
		
		return false;
	}
}

patrol_boat_disability_check()  // self = patrol boat
{
	level endon( "patrol_boat_dead" );
	
	if( !IsDefined( self.gunners_killed ) )
	{
		self.gunners_killed = 0;
	}
	
	if( !IsDefined( self.max_gunners_killed ) )
	{
		self.max_gunners_killed = 2;  // arbitrary values
	}
	
	if( !IsDefined( level._runners_died_trying ) )
	{
		level._runners_died_trying = 0;
	}
	
	while( ( self.gunners_killed < self.max_gunners_killed ) || ( level._runners_died_trying <= 3 ) )
	{
		wait( 2 );
	}
	
	flag_set( "patrol_boat_disabled" );
	PrintLn( "patrol boat disabled: " + self.targetname );
//	level thread add_dialogue_line( "Reznov", "Hah! See? They are learning to not jump onto that gun!" );
}

patrol_boat_death_check()  // self = patrol boat
{
	level endon( "patrol_boat_disabled" );
	
	while( self maps\_vehicle::is_corpse() == false )
	{
		wait( 1 );
	}
	
	flag_set( "patrol_boat_dead" );
	
//	level thread add_dialogue_line( "Reznov", "Well done, comrade! There will be no escape for them!" );
}

//limit_boat_speed_for_drive()
//{
//	level.boat setvehmaxspeed( 35 );
//	level.boat SetAcceleration( 8 );
//}

unlimit_boat_speed_for_rail()
{
	level.boat setvehmaxspeed( 200 ); // not the actual value; capped by GDT
//	level.boat SetAcceleration( 15 );
}

rail_enemy_boat_crew_setup()
{
	AssertEx( IsDefined( self.script_int ), "script_int missing in boat_crew_setup spawner named " + self.targetname );
	AssertEx( IsDefined( self.target), "target missing in boat_crew_setup for " + self.targetname );
	
	boat = GetEnt( self.target, "targetname" );
	
	seat_num = self.script_int;
	
	switch( seat_num )
	{
		case 1: 
				seat = "tag_driver";
				break;
		case 2:
				seat = "tag_gunner1";
				break;		
		case 3:
				seat = "tag_gunner2";
				break;		
		case 4:
				seat = "tag_passenger2";
				break;		
		case 5:
				seat = "tag_passenger3";
				break;		
		case 6:
				seat = "tag_passenger5";
				break;		
		case 7:
				seat = "tag_passenger6";  // weird location for boat_patrol_nva
				break;		
		case 8:
				seat = "tag_passenger7";
				break;		
		case 9:
				seat = "tag_passenger8";
				break;		
		case 10:
				seat = "tag_passenger9";
				break;		
		case 11:
				seat = "tag_passenger12";
				break;		
		case 12:
				seat = "tag_passenger13";
				break;		
		default:
				seat = "tag_gunner1";
				//IPrintLnBold( "INVALID SCRIPT INT: " + self.targetname );
				break;		
	}
	
	self LinkTo( boat, seat, ( 0, 0, 0 ), ( 0, 0, 0 ) );
}


/*===========================================================================
FUNCTION: difficulty_scale
SELF: level
PURPOSE: set up certain parameters that will change depending on difficulty level
NOTE: hp regen per frame = HP/time_before_regen/20(frames per second)

ADDITIONS NEEDED:
===========================================================================*/
difficulty_scale()
{
	switch( GetDifficulty() )
	{
		case "easy": 

			level._player_boat_health = 4500;		// 
			level._time_before_regen = 5;			// seconds
			level._max_enemy_targets = 4;			// rocket guys or vehicles
			level._percent_life_at_checkpoint = 1;  // 1 = 100%, 0.75 = 75%, etc
			break;
		case "medium":
			level._player_boat_health = 4000;		// 
			level._time_before_regen = 5;			// seconds
			level._max_enemy_targets = 4;			// rocket guys or vehicles
			level._percent_life_at_checkpoint = 1;  // 1 = 100%, 0.75 = 75%, etc
			break;
		case "hard":
			level._player_boat_health = 3500;		// 
			level._time_before_regen = 5;			// seconds
			level._max_enemy_targets = 4;			// rocket guys or vehicles
			level._percent_life_at_checkpoint = 1;  // 1 = 100%, 0.75 = 75%, etc
			break;
		case "fu":
			level._player_boat_health = 3000;		// 
			level._time_before_regen = 5;			// seconds
			level._max_enemy_targets = 4;			// rocket guys or vehicles
			level._percent_life_at_checkpoint = 1;  // 1 = 100%, 0.75 = 75%, etc
			break;									
			
	}

	level.boat.boat_health = level._player_boat_health;
	//level._boat_hp_regen_per_frame = Int( level._player_boat_health / level._time_before_regen / 20 ) ;
	level._boat_hp_regen_per_frame = Int( level._player_boat_health / level._time_before_regen / 20 ) ;
}

/*===========================================================================
function gives health back to the boat after it's been damaged based on global
parameters defined in "setup_boat_regen"
===========================================================================*/
setup_boat_regen()
{
	// TODO: make this work for all player vehicles if we do co-op
	level.boat thread regen_boat_health();
}


/////////////////////////////////
// FUNCTION: regen_armor
// CALLED ON: player vehicle
// PURPOSE: This waits until the player has not been damaged for a sufficiently long time (set
//					in river_util::difficulty_scale ) and then begins armor regeneration.
// ADDITIONS NEEDED: None
////////////////////////////////
regen_boat_health()
{
	self endon( "death" );
	
	self.time_since_last_damage = 0;
	
	self thread update_damage_timer();
	self thread wait_for_damage_events();
	
	self thread player_boat_damage_effects();
	
	while( 1 )
	{
		if( self.time_since_last_damage > level._time_before_regen )
		{
			self thread begin_armor_regen();
			self waittill_either( "damage", "armor_full" );
		}

		wait( 0.05 );
	}
}

/////////////////////////////////
// FUNCTION: update_damage_timer
// CALLED ON: player vehicle
// PURPOSE: Increments the time since the player tank has last been damaged
// ADDITIONS NEEDED: None
/////////////////////////////////
update_damage_timer()
{
	self endon( "death" );
	while( 1 )
	{
		self.time_since_last_damage += 0.05;
		wait( 0.05 );
	}
}

/////////////////////////////////
// FUNCTION: wait_for_damage_events
// CALLED ON: player vehicle
// PURPOSE: resets the damage timer to zero whenever the player tank is damaged
// ADDITIONS NEEDED: None
/////////////////////////////////
wait_for_damage_events()
{
	self endon( "death" );
	while( 1 )
	{
		self waittill( "damage" );
		self.time_since_last_damage = 0;
		wait( 0.05 );
	}
}

/////////////////////////////////
// FUNCTION: begin_armor_regen
// CALLED ON: player vehicle
// PURPOSE: This begins regenerating the player armor until the player is damaged or dies
// ADDITIONS NEEDED: None
/////////////////////////////////
begin_armor_regen()
{
	self endon( "damage" );
	self endon( "death" );
	
	while( 1 )
	{
		if( self.boat_health > level._player_boat_health )
		{
			self.boat_health = level._player_boat_health;
		}
		if( self.boat_health == level._player_boat_health )
		{
			break;
		}
		
		self.boat_health += level._boat_hp_regen_per_frame;
		wait( 0.05 );
	}
	self notify( "armor_full" );
}



//*****************************************************************************
// self = player boat
//
// self.boat_health = current health
// level._player_boat_health = max boat health
//*****************************************************************************

player_boat_damage_effects()
{
	self endon( "death" );

	max_health = level._player_boat_health;

	loop_time = 2.2;		// 2.0


	//**********************************************************************
	// Setup the data tables for the 4 damage states, from highest to lowest
	//**********************************************************************
	
	damage = [];
	damage[1] = spawnstruct();
	damage[1].frac = 0.7;			// 0.65
	damage[1].start_time = 0;
	damage[1].effect = level._effect["player_pbr_damage_1"];
	damage[1].mode = 1;

	damage[2] = spawnstruct();
	damage[2].frac = 0.5;			// 0.4
	damage[2].start_time = 0;
	damage[2].effect = level._effect["player_pbr_damage_2"];
	damage[2].mode = 2;
	
	damage[3] = spawnstruct();
	damage[3].frac = 0.35;			// 0.28
	damage[3].start_time = 0;
	damage[3].effect = level._effect["player_pbr_damage_3"];
	damage[3].mode = 3;

	damage[4] = spawnstruct();
	damage[4].frac = 0.12;			// 0.13
	damage[4].start_time = 0;
	damage[4].effect = level._effect["player_pbr_damage_4"];
	damage[4].mode = 4;

	current_mode = 0;			// The damage mode we are in
	required_mode = 0;			// The damage mode we would like to be in

	while( 1 )
	{
		time = GetTime();
		damage_frac = self.boat_health / max_health;


		//**********************************
		// What is the required damage mode?
		//**********************************

		if( damage_frac <= damage[4].frac )
		{
			required_mode = 4;
		}
		else if( damage_frac <= damage[3].frac )
		{
			required_mode = 3;
		}
		else if( damage_frac <= damage[2].frac )
		{
			required_mode = 2;
		}
		else if( damage_frac <= damage[1].frac )
		{
			required_mode = 1;
		}
		else
		{
			required_mode = 0;
		}


		//***************************************************************************************************
		// If the required mode is greater than the current mode, force the current mode to the required mode
		//***************************************************************************************************

		if( required_mode > current_mode )
		{
			current_mode = required_mode;
		}


		//***********************************************************
		// Cycle through the damage modes from worse to least visible
		//***********************************************************

		all_modes_active = 0;

		for( i=4; i>=1; i-- )
		{
			state = damage[i];

			//***********************************
			// Check if the mode should be active
			//***********************************

			if( (current_mode >= state.mode) || (state.start_time) || (all_modes_active) )
			{
				// If not started, start it
				if( !state.start_time )
				{
					PlayFXOnTag( state.effect, self, "tag_origin" );
					state.start_time = time;
				}
				// If loop has ended, restart it
				else
				{
					dt = (time - state.start_time);
					dt = dt / 1000.0;
					// If the effect has timed out, should we restart it?
					if( dt >= loop_time )
					{
						restart_effect = 0;
						if( required_mode >= state.mode )
						{
							restart_effect = 1;
						}
						else if( (all_modes_active) && (current_mode < required_mode) )
						{
							restart_effect = 1;
						}
					
						if( restart_effect )
						{
							PlayFXOnTag( state.effect, self, "tag_origin" );
							state.start_time = time;
						}
						else
						{
							state.start_time = 0;
							if( (current_mode > 0) && (required_mode < current_mode) )
							{
								current_mode--;
							}
						}
					}
				}
				
				// Make sure all subsequent modes are active
				if( current_mode >= state.mode )
				{
					all_modes_active = 1;
				}
			}
			
			// Mode is finished with
			else
			{
				state.start_time = 0;
				if( current_mode > required_mode )
				{
					current_mode--;
				}
			}
		}

		wait( 0.01 );
	}
}


/*==========================================================================
FUNCTION: setup_destructible_buildings
SELF: level
PURPOSE: get all damage_triggers with specific targetname, then thread behavior
		function "destructible_building_behavior" on them. prints message if none
		are found.

ADDITIONS NEEDED:
==========================================================================*/
setup_destructible_buildings( ender )
{
	// --- setup behavior ---
//	destructible_building_triggers = GetEntArray( "destructible_building_trigger", "targetname" );
//	
//	if( destructible_building_triggers.size == 0 )
//	{
//		PrintLn( "no destructible_building_triggers found." );
//	}
//	
//	if( IsDefined( ender ) )
//	{
//		array_thread( destructible_building_triggers, ::destructible_building_behavior, ender );
//	}
//	else
//	{
//		array_thread( destructible_building_triggers, ::destructible_building_behavior );
//	}
//	
	
	// --- setup destructible killspawners ---
	killspawners = GetEntArray( "destructible", "targetname" );
	if( killspawners.size == 0 )
	{
		PrintLn( "no killspawners found." );
	}
	
	if( IsDefined( ender ) )
	{
		array_thread( killspawners, ::kill_spawners_with_destructible );
	}	
	else
	{
		array_thread( killspawners, ::kill_spawners_with_destructible, ender );
	}	
}


/*==========================================================================
FUNCTION:  
SELF: vehicle with mounted gun on it
PURPOSE: make a vehicle turret fire in a line beginning at A and ending at B.
	In the case that the vehicle has a turret weapon attached (like gaz63_quad50), 
	it'll use turret firing the same way

ADDITIONS NEEDED:
==========================================================================*/
vehicle_static_line_fire( turret_num, start_point, end_point, time )
{
	self endon( "death" );
	
	AssertEx( IsDefined( turret_num ), "turret_num is missing in vehicle_static_line_fire" );
	AssertEx( IsDefined( start_point ), "start_point is missing in vehicle_static_line_fire" );
	AssertEx( IsDefined( end_point ), "end_point is missing in vehicle_static_line_fire" );
	AssertEx( IsDefined( time ), "time is missing in vehicle_static_line_fire" );
	
	sound_ent = spawn( "script_origin" , self.origin);
	self thread maps\river_drive::audio_ent_fakelink( sound_ent );
	sound_ent thread audio_ent_fakelink_delete();
	
	weapon = self SeatGetWeapon( turret_num + 1);
	if( !IsDefined( weapon ) )
	{
		weapon = self seatgetweapon( turret_num );
		is_turret = true;
	}
	else
	{
		is_turret = false;
	}
	
	if( !IsDefined( weapon ) )
	{
		PrintLn( "Invalid turret_num passed to vehicle_static_line_fire. Returning." );
		return;		
	}

	firetime = WeaponFireTime( weapon );
	
	// number of bullets fired = ( fire_rate/sec ) * seconds
	shots_fired_total = Ceil( ( 1 / firetime ) * time );  // using ceiling since we divide by this number; should never be zero
	
	// position to fire at = end_point - start_point * scale (iterative based on number shots fired already)
	vector_length = Length( end_point - start_point );
	vector_line = VectorNormalize( end_point - start_point ); 
	scale = vector_length / shots_fired_total;

	time_min = 3;
	time_max = 12;

	if( time < time_min )  // short fire line
	{
		total_bursts = 2;
	}
	else if( ( time > time_min ) && ( time < time_max ) )  // medium fire line
	{
		total_bursts = RandomIntRange( 3, 5 );  // min and max number of bursts
	}
	else  // long fire line
	{
		total_bursts = RandomIntRange( 5, 7 );
	}
	
	total_pulses = ( total_bursts * 2 ) ;  // on/off/off/on/etc behavior 
	shots_per_burst = Int( shots_fired_total / total_pulses );

	use_burst_fire = true;  // ALWAYS start with burst fire. this is toggled on and off
	
	if( is_turret == false )
	{	
		self SetGunnerTargetVec( start_point, turret_num );
		wait( 0.2 );
		
		for( pulse_count = 0; pulse_count < total_pulses; pulse_count++ )  // loop through num pulses
		{
			if( use_burst_fire == true )
			{
				for( shots_fired = 0; shots_fired < shots_per_burst; shots_fired++ )  // loop through burst fire
				{
					point = start_point + ( vector_line * scale * ( shots_fired + 1 ) );
					self SetGunnerTargetVec( point, turret_num );  // add 1 so you don't fire at 0,0,0
					//IPrintLnBold( "STATIC FIRE 1111" );
					sound_ent playloopsound( "wpn_50cal_fire_loop_npc" );
					self fireGunnerWeapon( turret_num );
	
					wait( firetime );
					
				}
				sound_ent stoploopsound();
				sound_ent playsound( "wpn_50cal_fire_loop_ring_npc" );
			}
			else
			{
				wait_time = shots_per_burst * firetime;
				wait( wait_time );
			}
			
			// toggle burst fire
			if( use_burst_fire == true )
			{
				use_burst_fire = false;
			}
			else
			{
				use_burst_fire = true;
			}	
		}
			
	}	
	else  
	{
		self SetTurretTargetVec( start_point );  // reposition the turret before firing so it doesn't fire a high shot immediately		
		wait( 0.2 );
		for( shots_fired = 0; shots_fired < shots_fired_total; shots_fired++ )
		{
			point = start_point + ( vector_line * scale * ( shots_fired + 1 ) );
			self SetTurretTargetVec( point );  // add 1 so you don't fire at 0,0,0
			self FireWeapon();
			//IPrintLnBold( "STATIC FIRE 2222" );
			sound_ent playloopsound( "wpn_50cal_fire_loop_npc" );
			wait( firetime );
		}	
		sound_ent stoploopsound();
		sound_ent playsound( "wpn_50cal_fire_loop_ring_npc" );
		self stopfireweapon();
		//self clearturretyaw();
		self ClearTurretTarget();
	}
	
	print_debug_message( self.targetname + " fired " + shots_fired_total + " shots with vehicle_static_line_fire function. Turret = " + is_turret );
	self notify( "done_line_firing" );
}


/*==========================================================================
FUNCTION: vehicle_gunner_fire
SELF: vehicle
PURPOSE: make a vehicle gunner auto fire at a target

ADDITIONS NEEDED:
==========================================================================*/
vehicle_gunner_fire( gunner_num, target )
{
	self endon( "death" );
	
	AssertEx( IsDefined( gunner_num ), "gunner_num is missing in vehicle_static_line_fire" );
	
	if( !IsDefined( target ) )
	{
		PrintLn( "target is missing in vehicle_static_line_fire" );
		return;	
	}
	
	weapon = self seatgetweapon( gunner_num );
	
	if( !IsDefined( weapon ) )
	{
		PrintLn( "Invalid gunner_num passed to vehicle_gunner_fire. Returning." );
		return;		
	}

	firetime = WeaponFireTime( weapon );
	
	// number of bullets fired = ( fire_rate/sec ) * seconds
	//shots_fired_total = Ceil( ( 1 / firetime ) * time );  // using ceiling since we divide by this number; should never be zero
	
	// position to fire at = end_point - start_point * scale (iterative based on number shots fired already)
	//vector_length = Length( end_point - start_point );
	//vector_line = VectorNormalize( end_point - start_point ); 
	//scale = vector_length / shots_fired_total;

	count = 0;
	
	while( IsAlive( target ) )
	{
		if( count > 20 )
		{
			wait( RandomFloat( 0.75, 1.5 ) );
			count = 0;
		}
		
		//point = start_point + ( vector_line * scale * ( shots_fired + 1 ) );
//		self setgunnertargetent( target, ( 0, 0, 0 ), gunner_num );  // add 1 so you don't fire at 0,0,0
//		self fireGunnerWeapon( gunner_num );
		self SetTurretTargetEnt( target );  // add 1 so you don't fire at 0,0,0
		self FireWeapon();
		wait( firetime );
	}
	
	PrintLn( "target dead. resetting gun position" );
	self stopfireweapon();
	//self clearturretyaw();
	self ClearTurretTarget();	
	
}

/*==========================================================================
FUNCTION: reduce_vehicle_damage
SELF: AI that's being shot at by a turret
PURPOSE: make certain types of AI less likely to die via turret gunners

ADDITIONS NEEDED:
==========================================================================*/
reduce_vehicle_damage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	if( IsDefined( sWeapon ) )
	{
		if( sWeapon == "pbr_front_gunner" )
		{
			iDamage = 0;
		}
		else if( sWeapon == "pbr_front_gunner_big_flash" )
		{
			iDamage = 0;
		}
		else if( sWeapon == "pbr_front_gunner_river" )
		{
			iDamage = 0;
		}
		else if( sWeapon == "huey_minigun_gunner" )
		{
			iDamage = 0;
		}
		else if( sWeapon == "rpg_magic_bullet_sp" )
		{
			iDamage = 0;
		}
		else if( iDamage < 20 )  	// this is a hack. trying to eliminate bow gun damage, but sWeapon registers as "none", 
		{							// and both player turret and show up as "player" for eAttacker, and eInflictor = "player_controlled_boat"
			iDamage = 0;
		}
		else if( sWeapon == "none" )  // worldspawn usually does this
		{
			iDamage = 0;  
		}
	}
	else if( IsDefined( eInflictor.classname ) && ( eInflictor.classname == "worldspawn" ) )
	{
		iDamage = 0;
	}
	
	return iDamage;
}

MG_gunner_function()
{
	self.goalradius = 64;
	
	if(IsDefined(self.target))
	{
		self set_ignoreall(true);
		
		goal = GetNode(self.target, "targetname");
		self SetGoalNode(goal);
		self waittill("goal");
		
		self set_ignoreall(false);
	}
}


/*==========================================================================
FUNCTION: play_fx_on_destructible_death
SELF: destructible
PURPOSE: without art support, we needed a way to get a feel of destruction 
		into River based on the destructible system but don't have our own
		assets. THIS IS A TEMP SOLUTION.

ADDITIONS NEEDED: art support should completely replace the use of this function.
	This should not ship with the game.
==========================================================================*/
play_fx_on_destructible_death()
{
	
}

/*==========================================================================
FUNCTION: destructible_building_behavior
SELF: trigger_damage (defined in Radiant)
PURPOSE: when trigger is hit, smoke effect will play. Bullet damage will NOT
	trigger them (set up in spawnflags on trigger), so only other types of 
	damage will work. When "ender" flag is hit, threads are killed.
NOTES: 	targetname = destructible_building_trigger. ALWAYS.
		script_noteworthy will determine special behavior (i.e. towers)
		script_string = notify to be sent out when destructible is killed

ADDITIONS NEEDED: currently this doesn't detect if the destructible building
	is in a destroyed state; it'll play the effect based on the trigger only, 
	not the state of the destructible. If we stick with this system, we'll 
	need to update it. -TJanssen 5/4/2010
==========================================================================*/
destructible_building_behavior( ender )
{
	if( IsDefined( ender ) )  // give this an endon condition if this is defined, and it should be.
	{
		level endon( ender );
	}
	
	if( self.classname != "trigger_damage" )
	{
		//IPrintLnBold( "invalid destructible_building_trigger! must be trigger_damage, you're using " + self.classname + " at " + self.origin );
		return;
	}
	
	// --- behavior setup ---
	tower_damage_distance = 1000;
	tower_damage = 300;
	
	// -- trigger setup ---
	//self.spawnflags = 3; // (n-1)XXXXXXXX11 = no rifle damage(1) / no pistol damage(1). the rest are ignored (X)
	
	self waittill( "trigger" );
	
	if( IsDefined( self.script_noteworthy ) )  // define special behavior here. if this is missing, it's skipped.
	{
		behavior = self.script_noteworthy;
		
		switch( behavior )
		{
			case "tower":  // do damage to kill guys in tower above the legs (where trigger is set)
				RadiusDamage( self.origin, tower_damage_distance, tower_damage, tower_damage, get_players()[0] );
				break;
			default: 
				PrintLn( "unhandled script_noteworthy value passed into behavior for destructible_building_behavior" );
				break;
		}
	}
	
	if( IsDefined( self.script_string ) )
	{
		added_behavior = self.script_string;
		
		switch( added_behavior )
		{
			case "fire":
				PlayFX( level._effect[ "temp_destructible_building_fire" ], self.origin );
				break;
			default:
				PrintLn( "unhandled script_string value passed into behavior for destructible_building_behavior" );
		}
	}
	
	PlayFX( level._effect[ "temp_destructible_building_smoke_black" ], self.origin );
}


/*==========================================================================
FUNCTION: kill_spawners_with_destructible
SELF: destructible (will always have targetname = destructible)
PURPOSE: when destructibles of certain types are considered dead, send out a 
		notify that stops spawning guys. 
NOTES:	script_string = notify to be sent out when destructible is killed 
		on destructible (in geo) = destructible_killspawner
ADDITIONS NEEDED:
==========================================================================*/
kill_spawners_with_destructible( ender )
{
	if( IsDefined( ender ) )  // optional endon condition
	{
		level endon( ender );
	}
	
	while( true )
	{
		self waittill( "broken", destructible_event, attacker );

		if( destructible_event == "death" )
		{
			if( IsDefined( self.script_string ) )
			{
				level notify( self.script_string );
				PrintLn( "level notify sent from destructible death: " + self.script_string );
			}
			
			if( IsDefined( self.destructibledef ) )
			{
				type = self.destructibledef;
				
				switch( type )
				{
					case "dest_jun_camp_building_med01":  // "medium concrete building"
						PlayFX( level._effect[ "temp_destructible_building_smoke_white" ], self.origin );
						PlayFX( level._effect[ "temp_destructible_building_fire_large" ], self.origin );
						break;
					case "dest_jun_village_building02":  // "small wooden hut"
						PlayFX( level._effect[ "temp_destructible_building_embers" ], self.origin );
						PlayFX( level._effect[ "temp_destructible_building_fire_medium" ], self.origin );
						break;
					case "dest_jun_camp_building_sml02":  // "small concrete bunker"
						PlayFX( level._effect[ "temp_destructible_building_smoke_white" ], self.origin );
						break;
					case "dest_jun_village_building01":  // "raised wooden building on stilts"
						PlayFX( level._effect[ "temp_destructible_building_smoke_white" ], self.origin );
						break;
					default:
						PlayFX( level._effect[ "temp_destructible_building_smoke_white" ], self.origin );
						Print_debug_message( type + " is not set up to play specific fx", true );
						break;
				}
			}
			else
			{
				Print_debug_message( "missing destructibledef parameter at " + self.origin, true );
			}
			
			break;
		}
	}
}


/*==========================================================================
FUNCTION: print_debug_message
SELF: level (but not used)
PURPOSE: looks for a dvar, and prints debug messages if it exists and is set.
		No debug messages should be printed otherwise.
		-if "bold_text" parameter is set to true, will print to screen instead
		 of console only
		-dvar name: debug_river
		
ADDITIONS NEEDED:
==========================================================================*/
print_debug_message( debug_string, bold_text )
{
	/#
	if( IsDefined( GetDvar( "debug_river" ) ) )
	{
		if( GetDvar( "debug_river" ) != "" )
		{
			if( IsDefined( bold_text ) && ( bold_text == true ) )
			{
				IPrintLnBold( debug_string );
			}
			else
			{
				PrintLn( debug_string );
			}
		}
	}
	#/
}


/*==========================================================================
FUNCTION: general_debug_message
SELF: level (but not used)
PURPOSE: looks for a dvar, and prints debug messages if it exists and is set.
                                No debug messages should be printed otherwise.
                                -if "bold_text" parameter is set to true, will print to screen instead
                                 of console only
                                -example dvar name: debug_river
==========================================================================*/
general_debug_message( dvar_name, debug_string, bold_text )
{
	/#
	if( IsDefined( GetDvar( dvar_name ) ) )
	{
	    if( GetDvar( dvar_name ) != "" )
	    {
            if( IsDefined( bold_text ) && ( bold_text == true ) )
            {
                IPrintLnBold( debug_string );
            }
            else
            {
            	PrintLn( debug_string );
            }
	    }
	}
	#/
}


/*==========================================================================
FUNCTION: RPG_fire_prediction
SELF: AI
PURPOSE: make AI shoot at where the boat should be based on the boat's speed,
		position, range, and RPG projectile speed

ADDITIONS NEEDED: - make each value distancesquared so it's faster? maybe?
==========================================================================*/
RPG_fire_prediction( engagement_dist, min_wait_time, max_wait_time, target_playerboat_only, go_to_goal, min_range, max_range, specific_target )
{
	self endon( "death" );
	self endon( "stop_firing" );
	
	if( !IsDefined( engagement_dist ) )
	{
		engagement_dist = 4500;
	}
	
	if( !IsDefined( min_wait_time ) )
	{
		min_wait_time = 4;
	}
	
	if( !IsDefined( max_wait_time ) )
	{
		max_wait_time = 6;
	}
	
	if( max_wait_time < min_wait_time )  // if parameters passed in incorrectly, swap them
	{
		temp = min_wait_time;
		min_wait_time = max_wait_time;
		max_wait_time = temp;  
	}
	
	if( !IsDefined( min_range ) )
	{
		min_range = 0;		
	}
	
	if( !IsDefined( max_range ) )
	{
		max_range = 100;
	}
	
	if( IsDefined( self.a.rockets ) )
	{
		self.a.rockets = 200;	
	}	
	
	if( IsDefined( self.overrideActorDamage ) )
	{
		self.overrideActorDamage = undefined;
	}
	
	self.dofiringdeath = false;
	self.overrideActorDamage = maps\river_util::reduce_vehicle_damage;
	
	ent_num = self GetEntityNumber();	
	
	RPG_destabilization_distance = 3000;  // determined by type of rocket in GDT
	max_dist_squared = RPG_destabilization_distance * RPG_destabilization_distance;  // max distance to use this 
	projectile_speed = 1500;  // GDT setting
	scale_rocket = 300;
	
	self set_ignoreall( true );  // don't fire at anything automatically; this is handled within this function
	self set_ignoreme( true );
	self set_ignoresuppression( true );
	
//	if( IsDefined( self.ent_flag[ "at_goal" ] ) )  // wait to do anything if this exists
//	{
//		self ent_flag_wait( "at_goal" );
//	}
	
	
	if( IsDefined( go_to_goal ) && ( go_to_goal == true ) )
	{
		self waittill( "goal" );	
	}
	
	self thread aim_at_target( level.boat );
	
	while( true )
	{
		if( !IsDefined( specific_target ) )
		{
			if( IsDefined( target_playerboat_only ) && ( target_playerboat_only == true ) )
			{
				vehicle_target = level.boat;
			}
			else
			{
				x = RandomInt( 100 );
				
				if( x >= 20 )
				{
					vehicle_target = level.boat;
				}
				else
				{
					vehicle_target = random( level.friendly_boats );
				}
			}
		}
		else
		{
			vehicle_target = specific_target;
		}
		
		current_distance = Distance( level.boat.origin, self.origin );
		
		if( current_distance < engagement_dist )
		{			
			if( self.weapon != "rpg_river_infantry_sp" )  // if RPG isn't main hand, switch to it instead of whatever else he's carrying
			{
				self gun_switchto( "rpg_river_infantry_sp", "right" );
			}
			
			boat_forward_angles = AnglesToForward( vehicle_target.angles );
			boat_speed = vehicle_target GetSpeed();
			time_to_hit = current_distance / projectile_speed; // inches / (inches/sec) = sec
			scale_forward = boat_speed * time_to_hit ;  
			
			height = RandomIntRange( min_range, max_range );  
			if( height <= 20 )  
			{
				random_z_offset = ( 0, 0, -48 );  // aim for the lowest point on the boat so the rocket hits water
				//IPrintLnBold( "low shot" );
			}
			else if( ( height > 20 ) && ( height < 60 ) )  
			{
				random_z_offset = ( 0, 0, 112 );  // aim for highest point on boat so rocket zooms by player's head
				//IPrintLnBold( "high shot" );
			}
			else  // between 60 and 100
			{
				random_z_offset = ( 0, 0, 35 );  // aim directly for boat origin (no offset)
				//IPrintLnBold( "medium shot" );
			}
			
			if( boat_speed > -30 && boat_speed < 30 )  // special case for near stationary boats
			{
				location_estimate = vehicle_target.origin + ( 0, 0, 90 );
			}
			else
			{
				location_estimate = vehicle_target.origin + ( boat_forward_angles * scale_forward ) + random_z_offset;
			}
			
			//Line( self gettagorigin( "tag_flash" ), location_estimate, ( 1, 1, 1 ), 1, 0, 150 );			
			target_ent = Spawn( "script_origin", location_estimate );  // create entity to shoot at
		
			//self shoot_at_target( target_ent, undefined, 0.5, 1 );
			self aim_at_target( vehicle_target, 1 );
			MagicBullet( "rpg_river_infantry_sp", self GetTagOrigin( "tag_flash" ), location_estimate, self );
			
			target_ent Delete();  // remove entity since we won't use it again
			
			wait( RandomFloatRange( min_wait_time, max_wait_time ) );
		}
		else
		{
			print_debug_message( ent_num + " is out of engagement range of boat. waiting." );
			wait( RandomFloatRange( ( min_wait_time / 2 ), ( max_wait_time / 2 ) ) );
		}
	}
}


/*==========================================================================
FUNCTION: boat_health_overlay
SELF: player
PURPOSE: Represents damage as a full screen overlay as the player boat takes damage

ADDITIONS NEEDED: can i replace level.boat references with just "boat"?
==========================================================================*/

boat_health_overlay( boat )
{
	self endon( "death" );
	self endon( "stop_displaying_boat_health" );

	// NOTE: Potential overlays:-
	//			"overlay_low_health"
	//			"overlay_low_health_splat"
	//			"overlay_blood_meat_shield"
	//			"damage_feedback"

	// Init the "Red Edges" old style overlay
	red_edge_overlay = NewClientHudElem( self );
	red_edge_overlay SetShader( "overlay_low_health", 640, 480 );
	red_edge_overlay.x = 0;
	red_edge_overlay.y = 0;
	red_edge_overlay.splatter = true;
	red_edge_overlay.alignX = "left";
	red_edge_overlay.alignY = "top";
	red_edge_overlay.sort = 1;
	red_edge_overlay.foreground = 0;
	red_edge_overlay.horzAlign = "fullscreen";
	red_edge_overlay.vertAlign = "fullscreen";
	red_edge_overlay.alpha = 0;

	// Init the "blood splats" overlay
	blood_splats_overlay = NewClientHudElem( self );
	blood_splats_overlay SetShader( "overlay_low_health_splat", 640, 480 );
	blood_splats_overlay.x = 0;
	blood_splats_overlay.y = 0;
	blood_splats_overlay.splatter = true;
	blood_splats_overlay.alignX = "left";
	blood_splats_overlay.alignY = "top";
	blood_splats_overlay.sort = 1;
	blood_splats_overlay.foreground = 0;
	blood_splats_overlay.horzAlign = "fullscreen";
	blood_splats_overlay.vertAlign = "fullscreen";
	blood_splats_overlay.alpha = 0;

	hud_display = NewHudElem();
	hud_display.horizAlign = "center";
	hud_display.vertAlign = "middle";
	hud_display.x = 300;
	hud_display.y = 150;
	hud_display.font_scale = 6;
	hud_display.color = (1.0, 1.0, 1.0);
	hud_display.font = "big";

	
	// boat's health is 44000, but dies at 24000. 20000 of that is a health buffer
	// *** not exactly sure whats going on here ***
	if(!IsDefined(level.boat.max_hp)) 
	{
		level.boat.max_hp = level._player_boat_health; 	
	}

	max_hp = level.boat.max_hp;

	// Loop forever until we don't want to see boat's hp anymore
	frac = 1.0;
	last_frac = 1.0;
	while( flag("display_boat_hp") == true )
	{
		// If god mode is on, make the boat stop taking damage
		if( IsGodMode(get_players()[0]) == true )
		{
			level.boat.boat_health = level._player_boat_health;
		}
		
		current_health = level.boat.boat_health;
	
		//iprintlnbold( "MAX: " + max_hp + "CURR: " + current_health );
			
		frac = current_health / max_hp;
		if( frac <= 0.0 )
		{
			//iprintlnbold( "Health Frac Problem < 0" + frac );
			frac = 0.0;
			
			level thread custom_boat_death();
			return;
		}
		else if ( frac > 1.0 )
		{
			//iprintlnbold( "Health Frac Problem > 1" + frac );
			frac = 1.0;
		}

		// Set the alpha values of the screen overlays
		alpha = 1.0 - frac;
		red_edge_overlay.alpha = alpha;
		blood_splats_overlay.alpha = alpha;
				
		// Debug: Display HP on screen		
		/#
			// Danny wants the HP removed
			//message = &"RIVER_BOAT_HP" + current_health;
			//hud_display SetText( current_health ); 
		#/
				
		wait( 0.1 );
		last_frac = frac;
	}
	
	// Clean up HUD Elements
	red_edge_overlay Destroy();
	blood_splats_overlay Destroy();
}

custom_boat_death()
{
	flag_set( "playing_boat_death" );
	
	level thread player_death_vo();

	// make AIs get thrown off
	level.woods.noGibDeathAnim = true;
	level.bowman.noGibDeathAnim = true;
	
	level.woods stop_magic_bullet_shield();
	level.bowman stop_magic_bullet_shield();
	
	explosion_origin = level.boat GetTagOrigin( "tag_enter_gunner3" );
	level.woods DoDamage( level.woods.health * 2, explosion_origin, level.boat, -1, "explosive" );
	level.bowman DoDamage( level.bowman.health * 2, explosion_origin, level.boat, -1, "explosive" );
	
	// play explosion fx #1
	playfx( level._effect["vehicle_explosion"], explosion_origin );
	
	// earthquake
	player = get_players()[0];
	player playsound( "exp_shell_hit_boat" );
	earthquake( 0.7, 2.5, player.origin, 500 );

	// Lets us hear the death vo
	wait( 1.6 );
	
	// blur
	player SetBlur( 2, .3 );

	maps\_utility::missionFailedWrapper();
	
	// a secondary explosion
	wait( 0.2 );
	player SetBlur( 10, .5 );
	second_explosion_origin = level.boat GetTagOrigin( "tag_enter_gunner2" );
	playfx( level._effect["vehicle_explosion"], second_explosion_origin );
	wait( 0.1 );
	playfx( level._effect["heli_death"], explosion_origin );
}


//*****************************************************************************
//*****************************************************************************

player_death_vo()
{
	rval = randomint( 100 );
	line_rval = randomint( 100 );
	
	vo_delay = 0.2;
	
	// Woods
	if( rval > 66 )
	{
		if( line_rval > 50 )
		{
			level.woods thread maps\river_vo::playVO_proper( "its_all_over", vo_delay );
		}
		else
		{
			level.woods thread maps\river_vo::playVO_proper( "were_going_down", vo_delay );
		}
	}
	// Bowman
	else if ( rval> 33 )
	{
		if( line_rval > 50 )
		{
			level.bowman thread maps\river_vo::playVO_proper( "were_sinking", vo_delay );
		}
		else
		{
			level.bowman thread maps\river_vo::playVO_proper( "woods", vo_delay );
		}
	}
	// Mason
	else
	{
		if( line_rval > 50 )
		{
			level.mason thread maps\river_vo::playVO_proper( "were_burning", vo_delay );
		}
		else
		{
			level.mason thread maps\river_vo::playVO_proper( "taking_water", vo_delay );
		}
	}
}


/*==========================================================================
FUNCTION: fallback_behavior
SELF: AI that will fall back
PURPOSE: to make AI seem more intelligent by making them fall back to predetermined
	positions based on player's location

ADDITIONS NEEDED:
==========================================================================*/
fallback_behavior( fallback_trigger_targetname, fallback_nodes_targetname )
{
	self endon( "death" );
	
	if( !IsDefined( fallback_trigger_targetname ) )
	{
		print_debug_message( self.targetname + " at " + self.origin + " is missing a fallback trigger", true );
	}
	
	if( !IsDefined( fallback_nodes_targetname ) )
	{
		print_debug_message( self.targetname + " at " + self.origin + " is missing fallback nodes", true );
	}
	
	nodes = GetNodeArray( fallback_nodes_targetname, "targetname" );
	AssertEx( ( nodes.size > 0 ), "nodes are missing in fallback_behavior for " + self.targetname );
	
	trigger = GetEnt( fallback_trigger_targetname, "targetname" );
	AssertEx( IsDefined( trigger ), "trigger is missing in fallback_behavior for " + self.targetname );
	trigger waittill( "trigger" );
	
	self notify( "stop_firing" ); // special notify to turn off RPG_fire_prediction if it's on
	
	goal = random( nodes );
	
	self set_ignoreall( true );
	self set_ignoresuppression( true );
	
	self SetGoalNode( goal );
	
	self waittill( "goal" );
	self set_ignoreall( false );
	self set_ignoresuppression( false );
	
 	if( self.classname == "actor_VC_e_RIVER_RPG_AK47"  || self.classname == "actor_VC_e_RIVER_RPG_AK74u" )
	{
		self thread RPG_fire_prediction();
	}
}


/*==========================================================================
FUNCTION: generic_hint_dialogue
SELF: level
PURPOSE: provide some hint lines to play to direct players better

ADDITIONS NEEDED: 
==========================================================================*/
generic_hint_hint_lines( hint_lines, time_between_lines, trigger_name, wait_time, ender )
{
	AssertEx( ( IsDefined( hint_lines ) ), "hint_lines are missing in generic_hint_hint_lines" );
	
	if( IsDefined( ender ) )
	{
		level endon( ender );
	}
	
	if( IsDefined( trigger_name ) )
	{
		trigger = GetEnt( trigger_name, "targetname" );
		AssertEx( IsDefined( trigger ), "trigger is missing in generic_hint_hint_lines function" );
	}
	else
	{
		trigger = level;
	}

	if( !IsDefined( wait_time ) )  // wait_time is the static amount of time to wait between hints
	{
		wait_time = 10;
	}

	if( IsDefined( time_between_lines ) )
	{
		Line_frequency_s = time_between_lines;  // Line_frequency_s = how often lines can be played in seconds
	}
	else
	{
		Line_frequency_s = 10;	// arbitrary time
	}
	
	Line_frequency = Line_frequency_s * 1000; // convert to ms for GetTime
	
	current_line = 9999;  // arbitrary number outside the number of hint_lines lines
	last_line_played = 9999;  
	
	last_time_played = 0;  
	
	while( true )
	{
		if( IsDefined( trigger_name ) )
		{
			trigger waittill( "trigger" );
		}
		else
		{
			wait( wait_time );
		}
		
		current_time = GetTime();
		
		if( ( current_time - last_time_played ) > Line_frequency )
		{
			while( current_line == last_line_played )
			{
				current_line = RandomInt( hint_lines.size );
			}
			
			// this is where VO would play whenever that's available
//			level thread add_dialogue_line( "Woods", hint_lines[ current_line ] );
			last_time_played = GetTime();
			last_line_played = current_line;
		}
		else
		{
			wait( 0.1 );
		}
	}
}

/*==========================================================================
FUNCTION: flag_wait_then_func
SELF: anything you want to run the function on. defaults to level 
PURPOSE: wait for a flag to be set, then run a function. this can eliminate the 
	need for lots of unneeded "one-off" functions 

ADDITIONS NEEDED:
==========================================================================*/
flag_wait_then_func( flag_name, func, arg1, arg2, arg3, arg4, arg5, arg6 )
{
	PrintLn( flag_name + " is waiting" );
	flag_wait( flag_name );
	PrintLn( flag_name + " hit! running function" );
	
	self [[ func ]]( arg1, arg2, arg3, arg4, arg5, arg6 );
}

//******************************************************************************
//******************************************************************************

create_hud_elem( client, xpos, ypos, shader, width, height )
{
	if( IsDefined( client ) )
	{
		hud = NewClientHudElem( client ); 
	}
	else
	{
		hud = NewHudElem(); 
	}

	hud.x = xpos;
	hud.y = ypos;

//	hud.sort = 1;
	hud.hidewheninmenu = true;

	hud.alignX = "center";
	hud.alignY = "middle";
	hud.horzAlign = "center";
	hud.vertAlign = "middle";
	hud.foreground = true;

	hud.alpha = 1.0;
	hud.color = ( 1.0, 1.0, 1.0 );
	
	if( isdefined(shader) )
	{
		hud setshader( shader, width, height );
	}
		
	return hud; 
}


//******************************************************************************
//******************************************************************************

destroy_hud_elem()
{
	self Destroy(); 
}


remove_rpg_firing()
{
	if( ( self.weapon == "rpg_river_missile_sp" ) || ( self.weapon == "m202_flash_sp_river" ) ) // if using RPG/M202, swap out to commando_acog
	{
		self.a.allow_weapon_switch = true;
		self gun_switchto( "commando_acog_sp", "right" );
		//self waittill( "weapon_switched" );  // make sure switch is done
		wait( 1 );  // give AI enough time to switch weapon since weapon_switched notify may not be sent
	}
	else  
	{
		// already using RPG, don't switch
	}
	
	self.a.allow_weapon_switch = false;
}

/*==========================================================================
FUNCTION: cleanup_spawners
SELF: level
PURPOSE: wrapper function for spawner deletion. This will NOT delete AI. When
	debug dvar is set, this will print the number of ents found and deleted.

ADDITIONS NEEDED:
==========================================================================*/
cleanup_spawners( spawner_noteworthy, use_targetname )
{
	if( !IsDefined( spawner_noteworthy ) )
	{
		print_debug_message( "cleanup_spawners is missing spawner_noteworthy. returning.", true );
		return 0;
	}
	
	if( IsDefined( use_targetname ) && ( use_targetname  == true ) )
	{
		Spawners = GetEntArray( spawner_noteworthy, "targetname" );
	}
	else
	{
		Spawners = GetEntArray( spawner_noteworthy, "script_noteworthy" );
	}
	
	print_debug_message( "found " + Spawners.size + " ents with name " + spawner_noteworthy );
	
	Spawner_count = 0;
	
	for( i = 0; i < Spawners.size; i++ )
	{
		if( Spawners[ i ] is_spawner() )  // only delete spawners. AI will be deleted too if this check isn't done
		{
			Spawner_count++;
			Spawners[ i ] Delete();
		}
	}
	
	Print_debug_message( "deleted " + Spawner_count + " ents with name " + spawner_noteworthy );
	return Spawner_count;
}

/*==========================================================================
FUNCTION: cleanup_triggers
SELF: level
PURPOSE: clean up a bunch of triggers in one line. not just a generic "delete"
	function so it's easier to keep track of what stuff is

ADDITIONS NEEDED:
==========================================================================*/
cleanup_triggers( noteworthy )
{
	if( !IsDefined( noteworthy ) )
	{
		print_debug_message( "cleanup_triggers function is missing noteworthy" );
		return 0;
	}
	
	triggers = GetEntArray( noteworthy, "script_noteworthy" );
	trigger_count = triggers.size;
	
	print_debug_message( "deleting " + trigger_count + " triggers with noteworthy " + noteworthy );
	
	for( i = 0; i < triggers.size; i++ )
	{
		triggers[ i ] Delete();
	}
	
	return trigger_count;
}

/*==========================================================================
FUNCTION: cleanup_guys
SELF: level
PURPOSE: one line call to kill a group of guys

ADDITIONS NEEDED:
==========================================================================*/
cleanup_guys( ai_targetname )
{
	if( !IsDefined( ai_targetname ) )
	{
		print_debug_message( "cleanup_guys function is missing ai_targetname" );
		return 0;
	}
	
	ai_targetname = ai_targetname + "_ai";  // would return spawners without "_ai"
	
	guys = GetEntArray( ai_targetname, "targetname" );
	
	count = guys.size;
	
	array_thread( guys, ::kill_me );
	
	print_debug_message( "deleted " + count + " guys with name " + ai_targetname );
	
	return count;
}


//********************************************************************************
// General Function: Creates a temp ent, plays an effect on it, kills after X time
//********************************************************************************

PlayFxTimed( effect, origin, time )
{
	temp_ent = Spawn( "script_model", origin );
	temp_ent setModel( "tag_origin" );
				
	playfxontag( effect, temp_ent, "tag_origin" );
	wait( time );

	temp_ent delete();
}


//*****************************************************************************
// self = moving entity (usually player)
// wait until we
//*****************************************************************************

wait_to_reach_struct( struct_name, radius, default_pos )
{
	struct = getstruct( struct_name, "targetname" );
	if( isdefined(struct) )
	{
		pos = ( struct.origin[0], struct.origin[1], 0 );
	}
	else
	{
		pos = default_pos;
	}
	
	dist = radius *2;
	while( dist > radius )
	{
		dist = Distance( self.origin, pos );
		//IPrintLnBold("DIST: " + dist );
		wait( 0.1 );
	}
}


//*****************************************************************************
// self = level
// Used to straighten up AI's angle on the boat prior to starting an animation
// can be used with one more more AIs
//*****************************************************************************

look_forward_on_boat( ai_1, ai_2, ai_3, ai_4 )
{
	// we want to turn the AIs so they all face the front of the boat
	if( isdefined( ai_1 ) )
	{
		ai_1 thread look_foward_on_boat_single();
	}
	if( isdefined( ai_2 ) )
	{
		ai_2 thread look_foward_on_boat_single();
	}
	if( isdefined( ai_3 ) )
	{
		ai_3 thread look_foward_on_boat_single();
	}
	if( isdefined( ai_4 ) )
	{
		ai_4 thread look_foward_on_boat_single();
	}

	wait( 1 );
}

look_foward_on_boat_single( look_back )
{
	self notify("stop_rpg_turret_ai");
	
	// spawn an ent in front of the ai
	vector_forward = AnglesToForward( level.boat.angles );
	vector_forward = VectorNormalize( vector_forward );
	
	offset = ( 0, 0, 52 );
	
	if( IsDefined( look_back ) && ( look_back == true ) )
	{
		vector_forward = vector_forward * ( -1 );
		offset = ( 0, 0, 52 );
	}	
	
	distance_foward = 100;
	position_foward = self.origin + distance_foward * vector_forward;
	position_foward = position_foward + offset;
	
	if( !isdefined( self.boat_rotation_target ) )
	{
		self.boat_rotation_target = spawn( "script_origin", position_foward );
		self.boat_rotation_target linkto( level.boat );
	}
	self aim_at_target( self.boat_rotation_target );

	wait( 1.05 );
	self stop_aim_at_target();
}


//*****************************************************************************
//*****************************************************************************
 
link_effect_to_ents_tag( ent, tag_name, effect_name )
{
	tag_position = ent GetTagOrigin( tag_name );
	tag_offset = tag_position - ent.origin;
	
	link_origin = spawn( "script_model", ent.origin );
	link_origin.angles = ( 0, 0, 0 );
 	link_origin SetModel( "tag_origin" );

	//link_origin linkto( ent, tag_name );
	link_origin linkto( ent, "tag_origin", tag_offset, ( 0, 0, 0 ) );
	
 	playfxontag( effect_name, link_origin, "tag_origin" );
 	return( link_origin );
}


//*****************************************************************************
// self = client
//*****************************************************************************

fade_cross_hair( required_alpha, total_time )
{
	self endon( "death" );

	//*****************************************************************
	// Set the start alpha value and fade increment
	// We can't get the value in script, so assume its either on or off
	//*****************************************************************
		
	if( required_alpha > 0 )
	{
		start_alpha = 0.0;
	}
	else
	{
		start_alpha = 1.0;
	}
	
	//***************************
	// Fade in/out the cross hair	
	//***************************
	
	total_time = total_time * 1000;		// Turn into ms
	
	start_time = GetTime();
	time = start_time;
	end_time = start_time + total_time;
	
	while( time < end_time )
	{
		time = GetTime();
				
		frac = 1.0 - ((end_time - time) / total_time);
				
		alpha = start_alpha + ( (required_alpha - start_alpha) * frac );
		if( alpha <= 0.0 )
		{
			alpha = 0.0;
		}
		else if ( alpha >= 1.0 )
		{
			alpha = 1.0;
		}
		
		self SetClientDvars( "cg_crosshairAlpha", alpha );

		wait( 0.01 );
	}	
	
	self SetClientDvars( "cg_crosshairAlpha", required_alpha );
}





