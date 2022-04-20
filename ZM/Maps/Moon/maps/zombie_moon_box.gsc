
#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;

#include maps\zombie_moon_traps;


//*****************************************************************************
// 
//*****************************************************************************

init_box()
{
//	precachemodel("zombie_zapper_power_box");
//	precachemodel("zombie_zapper_power_box_on");
	precachemodel("zombie_trap_switch_light_on_red");
	precachemodel("zombie_trap_switch_light_on_green");

	level.light_model_scale = 0.3;

	// pandora box setup
	level thread magic_box_limit_location_init();
	
	// 1st time the box moves, move it to the forest
	level.desirable_chest_location = "forest_chest";
}


//*****************************************************************************
// Magic Box Spawn Locations
//*****************************************************************************

magic_box_limit_location_init()
{
	// All locations are valid.  If it goes somewhere you haven't opened, you need to open it.
	level.open_chest_location = [];
	level.open_chest_location[0] = "start_chest";
	level.open_chest_location[1] = "forest_chest";
	level.open_chest_location[2] = "tower_east_chest";
	level.open_chest_location[3] = "bridge_chest";
	//level.open_chest_location[4] = undefined;
}


//*****************************************************************************
// 
//*****************************************************************************

get_chest_index()
{
	rval = 0;
	
	switch( level.chests[level.chest_index].script_noteworthy )
	{
		case "start_chest":
			rval = 1;
		break;
		
		case "forest_chest":
			rval = 2;
		break;

		case "tower_east_chest":
			rval = 3;
		break;

		case "bridge_chest":
			rval = 4;
		break;
	}
		
	return( rval );
}


//*****************************************************************************
// 
//*****************************************************************************

magic_box_map_lights_update()
{
	// Let the level startup
	wait(2);
	
	// Setup
	box_mode = "Box Available";

	turn_all_lights_red();
	
	// Turn Start Location Green on Map	
	light_name = "box_light_" + get_chest_index();
	turn_light_green( light_name );
	
	while( 1 )
	{
		switch( box_mode )
		{
			// Waiting for the Box to Move
			case "Box Available":
				if( flag("moving_chest_now") )
				{
					// Turn the current light location Red
					light_name = "box_light_" + get_chest_index();
					turn_light_red( light_name );
				
					// Next Mode
					box_mode = "Box is Moving";
				}
			break;


			case "Box is Moving":
				// Waiting for the box to finish its move
				while( flag("moving_chest_now") )
				{
					wait( 0.01 );
					turn_all_lights_green();
					wait( 0.01 );
					turn_all_lights_red();
				}

				box_mode = "Box Available";

				// Red the new box location light on the map
				turn_all_lights_red();
				light_name = "box_light_" + get_chest_index();
				turn_light_green( light_name );
			break;
		}

		wait( 0.5 );
	}
}


//*****************************************************************************
//*****************************************************************************

turn_light_green( light_name )
{
	zapper_light_green( light_name, "script_noteworthy" );

}


//*****************************************************************************
//*****************************************************************************

turn_light_red( light_name )
{
	zapper_light_red( light_name, "script_noteworthy" );
}


//*****************************************************************************
//*****************************************************************************

turn_all_lights_red()
{
	zapper_light_red( "magic_box_light", "targetname" );
}


//*****************************************************************************
//*****************************************************************************

turn_all_lights_green()
{
	zapper_light_green( "magic_box_light", "targetname" );
}


