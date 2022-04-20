#include maps\mp\_utility;
#include common_scripts\utility; 

main()
{
	//needs to be first for create fx
	maps\mp\mp_hanoi_fx::main();

	maps\mp\_load::main();
	if ( GetDvarInt( #"xblive_wagermatch" ) == 1 )
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_hanoi_wager"); 
	}
	else
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_hanoi"); 
	}
	maps\mp\mp_hanoi_amb::main();

	// If the team nationalites change in this file,
	// you must update the team nationality in the level's csc file as well!
	maps\mp\gametypes\_teamset_junglemarines::level_init();

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

	// enable new spawning system
	maps\mp\gametypes\_spawning::level_use_unified_spawning(true);
	
	level thread spotlight_function();
}

/*
Note that I had to write the spotlight function the way we did because the engine is particular about rendering light on certain textures
based on the original position of a primary light's info null. Otherwise, some textures would never be lit by it. Also, for an unknown reason the 
lighting FX would not play without a delay for an unknown reason. Finally, be aware of jittery shadows produces by the script light.

*/

//Creates rotating spotlight
spotlight_function()
{
	spot_light_model = GetEnt("large_spot_light","targetname");
	AssertEX( IsDefined( spot_light_model ), "'large_spot_light' model is not defined" );
	primary_spot_light = GetEnt("scr_floodlight", "targetname");
	AssertEX( IsDefined( primary_spot_light ), "'scr_floodlight' light is not defined" );
	
	//Sets up the position of my spotlight and light. Seperate from my 'while' loop because of the necessity of positioning the light's info null.
	spot_light_model RotateYaw( -30, 4);
	primary_spot_light RotateYaw( -30, 4);
	spot_light_model waittill("rotatedone");
	
	//Must play this FX after the rotate is done to get it to work. For some reason, the FX doesn't play without the delay.
	//TODO: Find out why the delay is necessary.
	PlayFXOnTag(level._effect["spotlight"],spot_light_model,"tag_flash");
	
	spot_light_angle_change = 60;
	spot_light_speed = 6;
	
	//Get my spot light and light to rotate. Note the rotate value is very specific as altering it can cause problems. 
	while(1)
	{
		spot_light_model RotateYaw(spot_light_angle_change, spot_light_speed);
		primary_spot_light RotateYaw(spot_light_angle_change, spot_light_speed);
		spot_light_model waittill("rotatedone");
		spot_light_model RotateYaw((spot_light_angle_change * -1), spot_light_speed);
		primary_spot_light RotateYaw((spot_light_angle_change * -1), spot_light_speed);
		spot_light_model waittill("rotatedone");
	}	
}