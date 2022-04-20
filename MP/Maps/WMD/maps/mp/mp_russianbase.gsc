#include maps\mp\_utility;
main()
{
	//needs to be first for create fx
	maps\mp\mp_russianbase_fx::main();

	maps\mp\_load::main();

	maps\mp\mp_russianbase_amb::main();

	if ( GetDvarInt( #"xblive_wagermatch" ) == 1 )
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_russianbase_wager");
	}
	else
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_russianbase");
	}	

	// If the team nationalites change in this file,
	// you must update the team nationality in the level's csc file as well!
	maps\mp\gametypes\_teamset_winterspecops::level_init();

	// Set up the default range of the compass
	setdvar("compassmaxrange","2100");

	// enable new spawning system
	maps\mp\gametypes\_spawning::level_use_unified_spawning(true);
	
	//fog
	//setExpFog(200, 6000, 0.7, 0.7, 0.73, 0);
	
	/#
		level thread devgui_russianbase();
		execdevgui( "devgui_mp_russianbase" );
	#/

	level thread runTrain();
}

runTrain()
{
	level endon( "game_ended" );
	precacheModel("t5_veh_train_boxcar");
	precacheModel("t5_veh_train_fuelcar");
	precacheModel("t5_veh_train_engine");
	
	// if you change moveTime of numOfCarts you need to change it in client script also
	moveTime = 20;
	numOfCarts = 40;
	originalRation = ( moveTime / 80 );
	maxWaitBetweenTrains = getDvarIntDefault( #"scr_maxWaitBetweenTrains", 200 );
	trainTime = ( moveTime + ( numOfCarts * 4 * originalRation ) );

	
	/# 
	russian_base_train_dev();
	#/ 
	for(;;)
	{
		waitBetweenTrains = randomint( maxWaitBetweenTrains );
		if ( waitBetweenTrains > 0 )
			wait( waitBetweenTrains );
		level clientNotify("play_train");
		wait( trainTime );
	}
}



/#
russian_base_train_dev()
{
	for ( ;; )
	{
		level waittill( "run_train" );
		level clientNotify("play_train");
	}
}

devgui_russianbase( cmd )
{
	for ( ;; )
	{
		wait( 0.5 );

		devgui_string = GetDvar( #"devgui_notify" );

		switch( devgui_string )
		{
			case "":
			break;
			default:
				level notify( devgui_string );
			break;
		}

		SetDvar( "devgui_notify", "" );
	}
}
#/
