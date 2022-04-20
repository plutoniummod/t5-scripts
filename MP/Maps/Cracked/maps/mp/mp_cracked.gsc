#include maps\mp\_utility;
main()
{
	//PrecacheModel( "t5_veh_helo_huey_lowres" );

	//needs to be first for create fx
	maps\mp\mp_cracked_fx::main();

	if ( GetDvarInt( #"xblive_wagermatch" ) == 1 )
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_cracked_wager");
	}
	else
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_cracked");
	}

	maps\mp\_load::main();

	maps\mp\mp_cracked_amb::main();

	// If the team nationalites change in this file,
	// you must update the team nationality in the level's csc file as well!
	maps\mp\gametypes\_teamset_junglemarines::level_init();



	// enable new spawning system
	maps\mp\gametypes\_spawning::level_use_unified_spawning(true);
}
