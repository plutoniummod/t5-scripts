#include maps\mp\_utility;
main()
{
	//needs to be first for create fx
	maps\mp\mp_crisis_fx::main();
	
	maps\mp\_load::main();

	if ( GetDvarInt( #"xblive_wagermatch" ) == 1 )
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_crisis_wager");
	}
	else
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_crisis");
	}

	//maps\mp\mp_crisis_amb::main();


	// If the team nationalites change in this file,
	// you must update the team nationality in the level's csc file as well!
	maps\mp\gametypes\_teamset_cubans::level_init();

	//setdvar("compassmaxrange","2100");

	// enable new spawning system
	maps\mp\gametypes\_spawning::level_use_unified_spawning(true);
}
