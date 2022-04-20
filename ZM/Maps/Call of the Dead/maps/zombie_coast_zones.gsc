
#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;


//*****************************************************************************
// Setup the Zones in the Map
//*****************************************************************************

init_zombie_zones()
{
	level.zombie_rise_spawners = [];	// Zombie riser control
	
	// Create a list of zones
	level.zones = [];
	level.zones[ level.zones.size ] = "start_zone";
	level.zones[ level.zones.size ] = "start_residence_zone";
	level.zones[ level.zones.size ] = "start_cave_zone";
	level.zones[ level.zones.size ] = "lighthouse1_zone";
	level.zones[ level.zones.size ] = "lighthouse2_zone";
	level.zones[ level.zones.size ] = "residence1_zone";
	level.zones[ level.zones.size ] = "residence_roof_zone";
	level.zones[ level.zones.size ] = "shipfront_bottom_zone";
	level.zones[ level.zones.size ] = "shipfront_stairs_zone";
	level.zones[ level.zones.size ] = "shipfront_near_zone";
	level.zones[ level.zones.size ] = "shipfront_far_zone";
	level.zones[ level.zones.size ] = "shipback_near_zone";
	level.zones[ level.zones.size ] = "shipback_far_zone";
	level.zones[ level.zones.size ] = "shipback_level1_zone";
	level.zones[ level.zones.size ] = "shipback_level2_zone";
	level.zones[ level.zones.size ] = "shipback_level3_zone";
	level.zones[ level.zones.size ] = "catwalk_zone";
	level.zones[ level.zones.size ] = "catwalk_top_zone";
	level.zones[ level.zones.size ] = "beach_zone";

		
	// Activate them
	for( i=0; i<level.zones.size; i++ )
	{
		thread zombie_zone_update( level.zones[i], "targetname" );
	}

	// disable locked barriers
	thread deactivate_initial_barrier_goals();
}


//*****************************************************************************
// ZOMBIE ZONE UPDATE
//
// Zones are represented by into_volume Entities
// If any player is in any of the zones with given zone_name, then activate all spwaners in all shared zones
//  - They have targetnames (can be shared by multiple zones) eg. "receiver_zone"
//  - They have targets that link them to zombie spawner(s) eg. "receiver_zone_spawner"
//  - They have script_noteworthy "player_volume"
//
// 
// have a info_volume target spawners
// to turn them on/off - probably the best way to handle this
//
// TODO: switch over the previous script_string stuff in the other function
//
//*****************************************************************************

zombie_zone_update( zone_name, key )
{	
	// Zones can be deactivated using  *** zoneEnt notify("deactivate_zone"); ***
	self endon("deactivate_zone");

	spawners = undefined;
	dog_spawners = [];
	multiple_zones = [];

	// Get all the zones with specified name	
	multiple_zones = getentarray(zone_name, key);

	// Did we find any zones?
	if( isDefined(multiple_zones[0].target) )
	{
		// Get an array of all spawners
		spawners = getentarray( multiple_zones[0].target, "targetname" );
		
		// Get an array of dag spawners only
		for( i=0; i<spawners.size; i++ )
		{
			if ( issubstr(spawners[i].classname, "dog") )
			{
				dog_spawners = array_add( dog_spawners, spawners[i] );
			}
		}
		
		// Remove dog spawners from the spawners array
		if( dog_spawners.size > 0 )
		{
			for( i=0; i<dog_spawners.size; i++ )
				spawners = array_remove( spawners, dog_spawners[i] );
		}
	}


	//***********************************************************
	// Check the Zones every second for players being inside them
	// Add the spawners if the player is in a zone
	// Remove the spawners if the player is not in a zone
	//***********************************************************

	check_ent = undefined;
	
	while( GetDvarInt( #"noclip") == 0 || GetDvarInt( #"notarget") != 0 )
	{
		// Test to see if any players are in the volume
		zone_active = false;
		
		players = get_players();
		
		// Check the players against a specific ent?
		if( isDefined(check_ent) )
		{
			for( i=0; i<check_ent.size; i++ )
			{
				for( j=0; j<players.size; j++ )
				{
					if( players[j] istouching(check_ent[i]) )
						zone_active = true;
				}
			}
		} 

		// Are there any players in any of the zones?
		for( j=0; j<multiple_zones.size; j++ )
		{
    		for( i=0; i<players.size; i++ )
    		{ 		
				if( players[i] istouching(multiple_zones[j]) )
	    		{
	    			zone_active = true;
	    		}
    		}
 		}
 		
		// Grab all special zombie rise locations		
		main_zone_rise_locations = [];
		main_zone_rise_locations = GetStructArray( multiple_zones[0].target + "_rise", "targetname" );


		adjacent_spawners = [];
		adjacent_zone_rise_locations = [];
//		adjacent_spawners = undefined;
//		adjacent_zone_rise_locations = undefined;

		// If a player is inside one of the zone volumes
		// Activate any associated spawners and adjacent spawners

		if( zone_active )
		{
			//iprintlnbold( "Player Zone: " + multiple_zones[0].targetname );
			
			//***********************************************************
			// DCS: Check adjacent zones
			// does a check for adjacent zones that checks flags
			// on doors and adjusts based on their open state.
			//***********************************************************
			
			adjacent_zones = adjacent_zones_check( multiple_zones[0] );
			for( i=0; i<adjacent_zones.size; i++ )
			{
				// Shows string names of adjoining zones, working.
				//iprintlnbold( adjacent_zones[i] );
				
				zone_array = GetEntArray( adjacent_zones[i], "targetname" );
				if( IsDefined(zone_array) )
				{
					for( j=0; j<zone_array.size; j++ )
					{
						ents = getentarray( zone_array[j].target, "targetname" );
						for( k=0; k<ents.size; k++ )
						{
							adjacent_spawners = add_to_array( adjacent_spawners, ents[k] );
						}

						// Add new spawn locations from adjacent zone
						
						locs = GetStructArray( zone_array[j].target + "_rise", "targetname" );
						for( k=0; k<locs.size; k++ )
						{
							adjacent_zone_rise_locations = add_to_array( adjacent_zone_rise_locations, locs[k] );
						}
					}

					// Shows the number of spawners in adj volumes, working.
					//iprintlnbold( "total spawners in adj vols " + adjacent_spawners.size + " locs " + adjacent_zone_rise_locations.size );
				
					// Add the Adjacent Zone Spawners
					add_spawners( adjacent_spawners, adjacent_zone_rise_locations );
				}	
			}

			// Add the Main Zone Spawners
			add_spawners( spawners, main_zone_rise_locations );
			
			
			// Activate any dogs
			if( flag("dog_round") )
			{
				init_dogs = [];
				init_dogs = getentarray("zombie_spawner_dog_init", "targetname");
				for(i = 0; i < init_dogs.size; i++)
				{						
					//make sure that there are no duplicate spawners 
					no_dupes = array_check_for_dupes( level.enemy_dog_spawns, init_dogs[i] );
					if(no_dupes)
					{
						init_dogs[i].locked_spawner = false;
						level.enemy_dog_spawns = add_to_array(level.enemy_dog_spawns,init_dogs[i]);					
					}
				}	
						
				// Do check again for dogs
				for(x=0;x<dog_spawners.size;x++)
				{
					//make sure that there are no duplicate spawners 
					no_dupes = array_check_for_dupes( level.enemy_dog_spawns, dog_spawners[x] );
					if(no_dupes)
					{
						dog_spawners[x].locked_spawner = false;
						level.enemy_dog_spawns = add_to_array(level.enemy_dog_spawns, dog_spawners[x]);						
					}
				}						
			}		
		}

		else if ( adjacent_is_active( multiple_zones[0] ) )
		{
		}
		
		// If no players in any of the volumes, disable the spawners
		else
		{	
			//iprintln( "Player NOT in volume:  " + multiple_zones[0].targetname );
			println( multiple_zones[0].targetname + " NOT active" );

			if( isDefined(spawners) )
			{
				for( x=0; x<spawners.size; x++ )
				{
					spawners[x].locked_spawner = true;
					level.enemy_spawns = array_remove_nokeys(level.enemy_spawns, spawners[x]);
				}				
			}
			
			// Disable any special zombie_rise locations
			for(i=0; i<main_zone_rise_locations.size; i++)
			{				
				level.zombie_rise_spawners = array_remove_nokeys(level.zombie_rise_spawners, main_zone_rise_locations[i]);
			}							
			
			//iprintln( "Spawners: " + spawners.size +  "ENEMY: " + level.enemy_spawns.size );			
			
			// deactivate initial dogs for center building
			init_dogs = [];
			init_dogs = getentarray("zombie_spawner_dog_init", "targetname");
			for( i=0; i < init_dogs.size; i++ )
			{
				init_dogs[i].locked_spawner = true;
				level.enemy_dog_spawns = array_remove_nokeys(level.enemy_dog_spawns, init_dogs[i]);
			}
			
			// do check again for dogs
			for( x=0; x<dog_spawners.size; x++ )
			{
				dog_spawners[x].locked_spawner = true;
				level.enemy_dog_spawns = array_remove_nokeys(level.enemy_dog_spawns, dog_spawners[x]);	
			}						
		}
	
		// Wait a second before another check
		wait(1);			
		
		
		/**********************************************/
		/* Any Adjacent Zone Spawn stuff to Disable ? */
		/**********************************************/
		
		if( isDefined(adjacent_spawners) )
		{
			for( x=0; x<adjacent_spawners.size; x++ )
			{
				adjacent_spawners[x].locked_spawner = true;
				level.enemy_spawns = array_remove_nokeys( level.enemy_spawns, adjacent_spawners[x] );
			}				
		}
		
		if( isDefined(adjacent_zone_rise_locations) )
		{
			for( x=0; x<adjacent_zone_rise_locations.size; x++ )
			{
				level.zombie_rise_spawners = array_remove_nokeys( level.zombie_rise_spawners, adjacent_zone_rise_locations[x] );
			}
		}
	}
}


//***********************************************************
//***********************************************************

adjacent_is_active( current_zone )
{
	adjacent_zones = adjacent_zones_check( current_zone );
	for( i=0; i<adjacent_zones.size; i++ )
	{
		zone_array = GetEntArray( adjacent_zones[i], "targetname" );
		if( IsDefined(zone_array) )
		{
			for( j=0; j<zone_array.size; j++ )
			{
				if ( player_in_zone( zone_array[j] ) )
				{
					return true;
				}
			}
 		}
	}

	return false;
}

//***********************************************************
//***********************************************************

player_in_zone( zone )
{
	players = get_players();
	for ( i = 0;i < players.size; i++ )
	{
		if( players[i] istouching(zone) )
		{
			return true;
		}
	}

	return false;
}

//***********************************************************
//***********************************************************

add_spawners( spawners, rise_locations )
{
	if( isDefined(spawners) )
	{
		// Make sure that there are no duplicate spawners			
		// Add "spawners" array to "level.enemy_spawns" array
		for( x=0; x<spawners.size; x++ )
		{
			no_dupes = array_check_for_dupes( level.enemy_spawns, spawners[x] );
			if( no_dupes )
			{
				spawners[x].locked_spawner = false;
				level.enemy_spawns = add_to_array( level.enemy_spawns, spawners[x] );
			}
		}
				
		for( i=0; i<rise_locations.size; i++ )
		{
			// check for dupes
			no_dupes = array_check_for_dupes(level.zombie_rise_spawners, rise_locations[i]);
			if(no_dupes)
			{
				rise_locations[i].locked_spawner = false;
				level.zombie_rise_spawners = add_to_array( level.zombie_rise_spawners, rise_locations[i] );
			}
		}
	}	
}


//***********************************************************
// DCS: Check adjacent zones.
// determines what zones are adjacent
// flag check for doors when open.
//***********************************************************

adjacent_zones_check(zone)
{
	// Specify adjacent zones here.  That is, if the player is in an adjacent zone, do you
	//	want zombie spawners to be active in the current zone too?
	adjacent_zones = [];
	
	switch ( zone.targetname )
	{
	case "start_zone":
		adjacent_zones[adjacent_zones.size] = "start_residence_zone";
		adjacent_zones[adjacent_zones.size] = "start_cave_zone";
		if( flag("lighthouse_enter") )
		{
			adjacent_zones[adjacent_zones.size] = "lighthouse1_zone";
		}
		if ( flag( "lighthouse_residence_front" ) )
		{
			adjacent_zones[adjacent_zones.size] = "residence1_zone";
		}				
		if ( flag( "enter_shipfront_bottom" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipfront_bottom_zone";
			adjacent_zones[adjacent_zones.size] = "shipfront_stairs_zone";
		}
		return adjacent_zones;
	
	case "start_residence_zone":
		adjacent_zones[adjacent_zones.size] = "start_zone";
		return adjacent_zones;

	case "start_cave_zone":
		adjacent_zones[adjacent_zones.size] = "start_zone";
		return adjacent_zones;

	case "lighthouse1_zone":
		if( flag("lighthouse_enter") )
		{
			adjacent_zones[adjacent_zones.size] = "start_zone";
		}
		if ( flag("lighthouse2_enter") )
		{
			adjacent_zones[adjacent_zones.size] = "lighthouse2_zone";
		}
		return adjacent_zones;

	case "lighthouse2_zone":
		if ( flag("lighthouse2_enter") )
		{
			adjacent_zones[adjacent_zones.size] = "lighthouse1_zone";
		}
		if ( flag("catwalk_enter") )
		{
			adjacent_zones[adjacent_zones.size] = "catwalk_zone";
		}
		if ( flag("balcony_enter") )
		{
			adjacent_zones[adjacent_zones.size] = "residence_roof_zone";
		}
		return adjacent_zones;

	case "catwalk_zone":
		adjacent_zones[adjacent_zones.size] = "lighthouse2_zone";
		adjacent_zones[adjacent_zones.size] = "catwalk_top_zone";

		// check beach
		if ( flag("lighthouse_enter") )
		{
			adjacent_zones[adjacent_zones.size] = "start_zone";

			// check ship front bottom
			if ( flag( "enter_shipfront_bottom" ) )
			{
				adjacent_zones[adjacent_zones.size] = "shipfront_bottom_zone";

				// check ship front top
				if ( flag( "ship_deck1" ) )
				{
					adjacent_zones[adjacent_zones.size] = "shipfront_near_zone";
				}
			}
		}

		// check ship back
		if ( flag("balcony_enter") && flag("plankB_enter") )
		//if ( flag("balcony_enter") )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_near_zone";

			// TEST 061709
			adjacent_zones[adjacent_zones.size] = "shipback_level1_zone";

			// check ship houses
			/*
			if ( flag( "ship_house1" ) )
			{
				adjacent_zones[adjacent_zones.size] = "shipback_level1_zone";
			}
			*/
//			if ( flag( "ship_house2" ) )
			if ( flag( "shipback_level2_enter" ) )
			{
				adjacent_zones[adjacent_zones.size] = "shipback_level2_zone";
			}
//			if ( flag( "ship_house3" ) )
			if ( flag( "shipback_level3_enter" ) )
			{
				adjacent_zones[adjacent_zones.size] = "shipback_level3_zone";
			}
		}
		return adjacent_zones;


	case "shipfront_bottom_zone":
		if ( flag( "enter_shipfront_bottom" ) )
		{
			adjacent_zones[adjacent_zones.size] = "start_zone";
		}
		if ( flag( "ship_deck1" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipfront_near_zone";

			spawn_point = getstruct("shipfront_a", "script_noteworthy");
			spawn_point.locked = false;
			spawn_point = getstruct("shipfront_b", "script_noteworthy");
			spawn_point.locked = false;
		}
		return adjacent_zones;

	case "shipfront_stairs_zone":
		adjacent_zones[adjacent_zones.size] = "shipfront_bottom_zone";
		if ( flag( "ship_deck1" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipfront_near_zone";

			spawn_point = getstruct("shipfront_a", "script_noteworthy");
			spawn_point.locked = false;
			spawn_point = getstruct("shipfront_b", "script_noteworthy");
			spawn_point.locked = false;
		}
		return adjacent_zones;

	case "shipfront_near_zone":
		if ( flag( "shipfront_far_enter" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipfront_far_zone";
		}
		if ( flag( "ship_deck1" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipfront_bottom_zone";
		}
		if ( flag( "plankA_enter" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_near_zone";

			// TEST 061709
			adjacent_zones[adjacent_zones.size] = "shipback_level1_zone";
		}
		/*
		if ( flag( "ship_house1" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_level1_zone";
		}
		*/
		return adjacent_zones;

	case "shipfront_far_zone":
		adjacent_zones[adjacent_zones.size] = "shipfront_near_zone";
		return adjacent_zones;

	case "shipback_far_zone":
		adjacent_zones[adjacent_zones.size] = "shipback_near_zone";

		// TEST 061709
		adjacent_zones[adjacent_zones.size] = "shipback_level1_zone";
		/*
		if ( flag( "ship_house1" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_level1_zone";
		}
		*/

		return adjacent_zones;

	case "shipback_near_zone":
		// TEST 061709
		adjacent_zones[adjacent_zones.size] = "shipback_level1_zone";

		if ( flag( "shipback_far_enter" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_far_zone";
		}
		if ( flag( "plankA_enter" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipfront_near_zone";

			spawn_point = getstruct("shipfront_a", "script_noteworthy");
			spawn_point.locked = false;
			spawn_point = getstruct("shipfront_b", "script_noteworthy");
			spawn_point.locked = false;
		}
		if ( flag( "plankB_enter" ) )
		{
			adjacent_zones[adjacent_zones.size] = "beach_zone";
		}
		/*
		if ( flag( "ship_house1" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_level1_zone";
		}
		*/
//		if ( flag( "ship_house2" ) )
		if ( flag( "shipback_level2_enter" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_level2_zone";
		}
//		if ( flag( "ship_house3" ) )
		if ( flag( "shipback_level3_enter" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_level3_zone";
		}
		return adjacent_zones;

	case "shipback_level1_zone":
		adjacent_zones[adjacent_zones.size] = "shipback_near_zone";
//		if ( flag( "ship_house2" ) )
		if ( flag( "shipback_level2_enter" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_level2_zone";
		}
		thread activate_barrier_goals( "shipback_level1_zone_barriers", "script_noteworthy" );
		return adjacent_zones;

	case "shipback_level2_zone":
		adjacent_zones[adjacent_zones.size] = "shipback_near_zone";

		// TEST 061709
		adjacent_zones[adjacent_zones.size] = "shipback_level1_zone";
		/*
		if ( flag( "ship_house1" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_level1_zone";
		}
		*/
//		if ( flag( "ship_house3" ) )
		if ( flag( "shipback_level3_enter" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_level3_zone";
		}
		thread activate_barrier_goals( "shipback_level2_zone_barriers", "script_noteworthy" );
		return adjacent_zones;

	case "shipback_level3_zone":
		adjacent_zones[adjacent_zones.size] = "shipback_near_zone";
//		if ( flag( "ship_house2" ) )
		if ( flag( "shipback_level2_enter" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_level2_zone";
		}
		thread activate_barrier_goals( "shipback_level3_zone_barriers", "script_noteworthy" );
		return adjacent_zones;
		
	case "residence1_zone":
		if ( flag( "lighthouse_residence_front" ) )
		{
			adjacent_zones[adjacent_zones.size] = "start_zone";
			adjacent_zones[adjacent_zones.size] = "start_residence_zone";
		}		
		if ( flag( "lighthouse_residence_roof" ) )
		{
			adjacent_zones[adjacent_zones.size] = "residence_roof_zone";
		}
		return adjacent_zones;

	case "residence_roof_zone":
		adjacent_zones[adjacent_zones.size] = "beach_zone";
		if ( flag( "lighthouse_residence_roof" ) )
		{
			adjacent_zones[adjacent_zones.size] = "residence1_zone";
		}
		if ( flag( "balcony_enter" ) )
		{
			adjacent_zones[adjacent_zones.size] = "lighthouse2_zone";
		}
		return adjacent_zones;

	case "beach_zone":
		adjacent_zones[adjacent_zones.size] = "residence_roof_zone";
		if ( flag( "plankB_enter" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_near_zone";

			// TEST 061709
			adjacent_zones[adjacent_zones.size] = "shipback_level1_zone";
		}
		/*
		if ( flag( "ship_house1" ) )
		{
			adjacent_zones[adjacent_zones.size] = "shipback_level1_zone";
		}
		*/
		return adjacent_zones;

	}

	return adjacent_zones;
}


//*****************************************************************************
// BARRIERS
//*****************************************************************************

//
//	Disable exterior_goals that have a script_noteworthy.  This can prevent zombies from
//		pathing to a goal that the zombie can't path towards the player after entering.
//	It is assumed these will be activated later, when the zone gets activated.
//
deactivate_initial_barrier_goals()
{
	special_goals = getstructarray("exterior_goal", "targetname");
	for (i = 0; i < special_goals.size; i++)
	{
		if (IsDefined(special_goals[i].script_noteworthy))
		{
			special_goals[i].is_active = undefined;
			special_goals[i] trigger_off();
		}
	}
}

//
//	Activates barrier goals.
//		Allows zombies to path to the specified barriers.
//
activate_barrier_goals(barrier_name, key)
{
	//deactivate the goals until door is opened
	entry_points = getstructarray(barrier_name, key);
	//for(i=0;i<entry_points.size;i++)
	//{
	//	entry_points[i].is_active = undefined;
	//	entry_points[i] trigger_off();
	//}

	//flag_wait(flag_name);

	//activate any zombie entrypoints now that the door/debris has been removed
	//entry_points = getstructarray(door,key);
	for(i=0;i<entry_points.size;i++)
	{
		entry_points[i].is_active = 1;
		entry_points[i] trigger_on();
	}		
}

