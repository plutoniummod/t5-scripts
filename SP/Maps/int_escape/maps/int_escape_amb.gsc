//
// file: int_escape_amb.gsc
// description: level ambience script for int_escape
// scripter: 
//
#include maps\_utility;
#include common_scripts\utility;
#include maps\_ambientpackage;
#include maps\_music;

main()
{
	//declare an ambientpackage, and populate it with elements
	//mandatory parameters are <package name>, <alias name>, <spawnMin>, <spawnMax>
	//followed by optional parameters <distMin>, <distMax>, <angleMin>, <angleMax>
//	declareAmbientPackage( "outdoors_pkg" );
//	addAmbientElement( "outdoors_pkg", "elm_dog1", 3, 6, 1800, 2000, 270, 450 );
//	addAmbientElement( "outdoors_pkg", "elm_dog2", 5, 10 );
//	addAmbientElement( "outdoors_pkg", "elm_dog3", 10, 20 );
//	addAmbientElement( "outdoors_pkg", "elm_donkey1", 25, 35 );
//	addAmbientElement( "outdoors_pkg", "elm_horse1", 10, 25 );

//	declareAmbientPackage( "west_pkg" );
//	addAmbientElement( "west_pkg", "elm_insect_fly", 2, 8, 0, 150, 345, 375 );
//	addAmbientElement( "west_pkg", "elm_owl", 3, 10, 400, 500, 269, 270 );
//	addAmbientElement( "west_pkg", "elm_wolf", 10, 15, 100, 500, 90, 270 );
//	addAmbientElement( "west_pkg", "animal_chicken_idle", 3, 12 );
//	addAmbientElement( "west_pkg", "animal_chicken_disturbed", 10, 30 );

//	declareAmbientPackage( "northwest_pkg" );
//	addAmbientElement( "northwest_pkg", "elm_wind_buffet", 3, 6 );
//	addAmbientElement( "northwest_pkg", "elm_rubble", 5, 10 );
//	addAmbientElement( "northwest_pkg", "elm_industry", 10, 20 );
//	addAmbientElement( "northwest_pkg", "elm_stress", 5, 20, 200, 2000 );

	//explicitly activate the base ambientpackage, which is used when not touching any ambientPackageTriggers
	//the other trigger based packages will be activated automatically when the player is touching them
//	activateAmbientPackage( "outdoors_pkg", 0 );


	//the same pattern is followed for setting up ambientRooms
//	declareAmbientRoom( "outdoors_room" );
//	setAmbientRoomTone( "outdoors_room", "amb_shanty_ext_temp" );

//	declareAmbientRoom( "west_room" );
//	setAmbientRoomTone( "west_room", "bomb_tick" );

//	declareAmbientRoom( "northwest_room" );
//	setAmbientRoomTone( "northwest_room", "weap_sniper_heartbeat" );

//	activateAmbientRoom( "outdoors_room", 0 );

	level thread heartbeat_init();
	level thread play_trippy_reznov();
	level thread event_2_music();
}
event_2_music()
{
	flag_wait("out_of_int_chair");	
	setmusicstate ("POST_HUDSON");
	
}
heartbeat_init()
{
	level.current_heart_waittime = 2;
	level.heart_waittime = 2;
	level.current_breathing_waittime = 4;
	level.breathing_waittime = 4;
	level.emotional_state_system = 0;

}

event_heart_beat( emotion, loudness, no_breath )
{	
	
	// Emotional State of Player
	// sedated (super slow heartbeat )
	// relaxed ( normal heart beat )
	// stressed (fast heartbeat)
	
//	iprintlnbold (emotion );
	level.current_emotion = emotion;
	if(!IsDefined (level.last_emotion))
	{
		level.last_emotion = "undefined";		
	}
	if( level.current_emotion != level.last_emotion)
	{	
		if(level.emotional_state_system == 0)
		{
			level.emotional_state_system = 1;
			level thread play_heart_beat();
			level thread play_breathing();
			
		}
		if(!IsDefined (loudness) || (loudness == 0))
		{
			level.loudness = 0;	
		}
		else
		{
			level.loudness = loudness;	
		}
		if(!IsDefined (no_breath) || (no_breath == 0))
		{
			level.no_breath = no_breath;	
		}
		else
		{
			level.no_breath = no_breath;
		}
		switch (emotion)	
		{
			case "sedated":
				level.heart_waittime = 3;
				level.breathing_waittime = 4;
				level.last_emotion = "sedated";				
				break;
				
			case "relaxed":
				level.heart_waittime = 2;
				level.breathing_waittime = 4;
				level.last_emotion = "relaxed";	
				break;
				
			case "stressed":
				level.heart_waittime = 0.5;
				level.breathing_waittime = 2;
				level.last_emotion = "stressed";	
				break;
				
			case "panicked":
				level.heart_waittime = 0.3;
				level.breathing_waittime = 1.5;
				level.last_emotion = "panicked";
				break;
				
			case "none":
				level.last_emotion = "none";
				level notify ("no_more_heartbeat");
				if(level.no_breath == 0)
				{	
					playsoundatposition ("vox_breath_scared_stop", (0,0,0));					
				}
				level.emotional_state_system = 0;
				level.no_breath = 0;				
				break;
			
			default: AssertMsg("Not a Valid Emotional State.  Please switch with sedated, relaxed, happy, stressed, or none");
		}
		thread heartbeat_state_transitions();  //(controls the wait between breaths and beats
	}
		
}
heartbeat_state_transitions()
{
	while (level.current_heart_waittime > level.heart_waittime)
	{
		//iprintlnbold ("current: " + level.current_heart_waittime + "goal: "  + level.heart_waittime);
		level.current_heart_waittime = level.current_heart_waittime - .10;
		wait(.30);	
		
	}
	while (level.current_heart_waittime < level.heart_waittime)
	{
		//iprintlnbold ("current: " + level.current_heart_waittime + "goal: "  + level.heart_waittime);
		level.current_heart_waittime = level.current_heart_waittime + .05;
		wait(.40);	
	}	
	level.current_heart_waittime = level.heart_waittime;
}
play_heart_beat ()
{
	player = getplayers();
	level endon ("no_more_heartbeat");
	if(!IsDefined ( level.heart_wait_counter) )
	{
		level.heart_wait_counter = 0;	
	}
	while( 1 )  
	{
		while( level.heart_wait_counter < level.current_heart_waittime)
		{
			wait(0.1);
			level.heart_wait_counter = level.heart_wait_counter +0.1;
		}
		
		if (level.loudness == 0)
		{
			playsoundatposition ("amb_player_heartbeat", (0,0,0));	
		}
		else
		{
			playsoundatposition ("amb_player_heartbeat_loud", (0,0,0));	
		}
		level.player shellshock("int_escape", 0.25);

		level.player PlayRumbleOnEntity("damage_light");	
		level.heart_wait_counter = 0;
		
	}	
	
}
play_breathing()
{
	level endon ("no_more_heartbeat");	
	
	if(!IsDefined ( level.breathing_wait_counter) )
	{
		level.breathing_wait_counter = 0;	
	}
	for(;;)  
	{
		while( level.breathing_wait_counter < level.current_breathing_waittime )
		{
			wait(0.1);
			level.breathing_wait_counter = level.breathing_wait_counter +0.1;
		}
		playsoundatposition ("amb_player_breath_cold", (0,0,0));
		level.breathing_wait_counter = 0;	
	}
}
play_trippy_reznov()
{
	
	wait(65);
	playsoundatposition ("amb_reznov_calls_mason", (208, 0, 64));
	
}