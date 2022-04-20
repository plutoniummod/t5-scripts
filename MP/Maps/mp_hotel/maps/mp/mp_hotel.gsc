#include maps\mp\_utility;
#include common_scripts\utility;

main()
{
	PrecacheString( &"MP_CALL_ELEVATOR" );
	PrecacheString( &"MP_USE_ELEVATOR" );

	PrecacheModel( "p_htl_slot_machine_symbols" );
	PrecacheModel( "p_htl_slot_machine_symbols_off" );

	precachemodel("collision_wall_256x256x10");
	
	//needs to be first for create fx
	maps\mp\mp_hotel_fx::main();
	
	maps\mp\_load::main();

//	maps\mp\_compass::setupMiniMap("compass_map_mp_hotel2"); 
	if ( GetDvarInt( #"xblive_wagermatch" ) == 1 )
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_hotel2_wager");
	}
	else
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_hotel2");
	}	
	
	/#
		execdevgui( "devgui_mp_hotel" );
	#/

	maps\mp\mp_hotel_amb::main();
	

	// If the team nationalites change in this file,
	// you must update the team nationality in the level's csc file as well!
	maps\mp\gametypes\_teamset_cubans::level_init();

	// Set up the default range of the compass
	setdvar("compassmaxrange","2100");

	// Set up some generic War Flag Names.
	// Example from COD5: CALLSIGN_SEELOW_A is the name of the 1st flag in Selow whose string is "Cottage" 
	// The string must have MPUI_CALLSIGN_ and _A. Replace Mapname with the name of your map/bsp and in the 
	// actual string enter a keyword that names the location (Roundhouse, Missle Silo, Launchpad, Guard Tower, etc)

	game["strings"]["war_callsign_a"] = &"MPUI_CALLSIGN_MAPNAME_A";
	game["strings"]["war_callsign_b"] = &"MPUI_CALLSIGN_MAPNAME_B";
	game["strings"]["war_callsign_c"] = &"MPUI_CALLSIGN_MAPNAME_C";
	game["strings"]["war_callsign_d"] = &"MPUI_CALLSIGN_MAPNAME_D";
	game["strings"]["war_callsign_e"] = &"MPUI_CALLSIGN_MAPNAME_E";

	game["strings_menu"]["war_callsign_a"] = "@MPUI_CALLSIGN_MAPNAME_A";
	game["strings_menu"]["war_callsign_b"] = "@MPUI_CALLSIGN_MAPNAME_B";
	game["strings_menu"]["war_callsign_c"] = "@MPUI_CALLSIGN_MAPNAME_C";
	game["strings_menu"]["war_callsign_d"] = "@MPUI_CALLSIGN_MAPNAME_D";
	game["strings_menu"]["war_callsign_e"] = "@MPUI_CALLSIGN_MAPNAME_E";

	SetDvar( "scr_spawn_enemy_influencer_radius", 2600 );
	SetDvar( "scr_spawn_dead_friend_influencer_radius", 1100 );

	//Lets smoke grenades explode when they're in the pool
	level.water_duds = false;

	// enable new spawning system
	maps\mp\gametypes\_spawning::level_use_unified_spawning(true);

	// Function for moving the elevators.
	maps\mp\mp_hotel_elevators::init();

	// spawn collision to stop players from accessing ledges by El Royale sign
	spawncollision("collision_wall_256x256x10","collider",(3452, 875, 91), (0, 0, 0));
	spawncollision("collision_wall_256x256x10","collider",(2500, 875, 91), (0, 0, 0));
	
	// spawn collision to stop players from accessing ledge by Casino Vault
	spawncollision("collision_wall_256x256x10","collider",(1601, -2178, 62), (0, 0, 0));
	
}