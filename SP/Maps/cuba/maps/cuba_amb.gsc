//
// file: cuba_amb.gsc
// description: level ambience script for cuba
// scripter: 
//

#include maps\_ambientpackage;
#include maps\_utility;
#include common_scripts\utility;
#include maps\_music;


main()
{
	//declare an ambientpackage, anpopulate it with elements
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

	level thread bar_fans();
	level thread light_match();
	level thread street_scene_screams();
	level thread mortar_rattle_setup();
	level thread mansion_fans();
	

	

}
bar_amb()
{
//	wait_for_all_players();
	wait(1);
	radio = getent( "radio" , "targetname" );
	bar_walla = getent( "bar_walla" , "targetname" );
	
	radio playsound( "amb_bar_music" , 2 );	
	bar_walla playloopsound( "amb_bar_walla" , 2 );
	
	flag_wait ("thugs_start");
	bar_walla stoploopsound(2);
	
}
bar_cardoor()
{
	wait(32);
	setmusicstate ("BAR_TENSION");
	playsoundatposition ("evt_cub_intro_driveup", (-15808, -1440, -808));	
	
}

bar_fans()
{
	wait(1);
	fan_1 = spawn ("script_origin", (-15976, -1384, -808));
	fan_2 = spawn ("script_origin", (-15808, -1440, -808));
	fan_1 playloopsound ("amb_bar_fan");
	fan_2 playloopsound ("amb_bar_fan");
		
	level waittill ("street_battle");
	fan_1 delete();
	fan_2 delete();
		
	
}

mansion_fans()
{
	mansion_fan_1 = spawn ("script_origin", (-5512, -3136, -272	));
	mansion_fan_1 playloopsound ("amb_bar_fan");
	
}

light_match()
{
	
	flag_wait("start_intro_flame");
	playsoundatposition ("exp_match_open", (0,0,0));
	wait(0.25);
	playsoundatposition("exp_match_light_fail", (0,0,0));
	wait(1.0);
	playsoundatposition("exp_match_light", (0,0,0));
	wait(3.3);
	playsoundatposition("exp_match_close", (0,0,0));
	wait(1.4);	
	playsoundatposition("exp_match_blow", (0,0,0));
	
}

street_scene_screams()
{
	wait(5);
	level thread monitor_street_battle();
	
	scream_points = getstructarray("amb_scream_point", "targetname");	
	for(i=0;i<scream_points.size;i++)
	{
		scream_points[i] thread play_scream_sounds_during_fight();	
		
	}
	level thread play_distant_chaos();
	
}
play_distant_chaos()
{
	chaos = spawn ("script_origin", (-12088, -736, -816));
	chaos playloopsound ("amb_distant_crowd_panicked");	
	
	
	
}
monitor_street_battle()
{
	flag_wait ("street_done");
	level notify ("street_battle_finished");
}
play_scream_sounds_during_fight()
{
	level endon ("street_battle_finished");

	// CUBA_SCRIPTERS_TO_SOUND - if player is already on the ziline then we dont want to do this
	if( flag( "player_entered_zipline" ) )
		return;
		
	player = getplayers();
	self.playing_scream = 0;
		
	while( !flag( "player_entered_zipline" ) )
	{
		
		dist = distance(self.origin, player[0].origin);
//		iprintlnbold ("checkign distance" + dist);
		
		if (dist < 500 && self.playing_scream == 0)
		{
			
			self.playing_scream = 1;
			playsoundatposition ("amb_scream_interior", self.origin);
			wait(3);
			self.playing_scream = 0;				
		}
		
		wait(0.5);
	}	
	
}
mortar_rattle_setup()
{
	// CUBA_SCRIPTERS_TO_SOUND - if player is already outside mansion we dont want to do anything 
	if( flag( "player_outside_mansion" ) )
		return;
		
	wait(5);
	rattle_point = getstructarray ("amb_rattle_point", "targetname");	
	for(i=0;i<rattle_point.size;i++)
	{
		rattle_point[i] thread play_rattle_sounds_when_mortar_hits();	
		
	}
	
}
play_rattle_sounds_when_mortar_hits()
{
	// CUBA_SCRIPTERS_TO_SOUND - if player is already outside mansion we dont want to do anything 
	while( !flag( "player_outside_mansion" ) )
	{
		level waittill ("mansion_exp_hit");
		wait(randomfloatrange(0.05, 0.5));
		playsoundatposition (self.script_sound, self.origin);		
	}
}
play_end_street_music()
{
	level waittill ("street_fight_over");
	//TUEY Set Music state to END_STREET
	setmusicstate ("END_STREET");	
}
play_car_radio()
{
	sound_tag = self GetTagOrigin( "tag_driver" );
	
	sound_ent = spawn ("script_origin", sound_tag);
	sound_ent linkto (self);
	
	players = getplayers();
	dist = distance(players[0].origin, self.origin);
	while (dist > 400)
	{
	//	iprintlnbold (dist);
		dist = distance(players[0].origin, self.origin);
		wait(0.1);		
	}
	sound_ent playloopsound ("mus_quimbara_car");
	level waittill ("drive_done");
	sound_ent stoploopsound();
	sound_ent delete();
	
	
}
air_raid_sound()
{
	//iprintlnbold ("playing siren");	
	clientNotify ("tar");
}	

