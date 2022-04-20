////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL SCRIPTS
// PJL 04/21/10
//
//
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include maps\_ambientpackage;
#include maps\_utility;
#include maps\_flyover_audio;
#include common_scripts\utility;
#include maps\_music;


////////////////////////////////////////////////////////////////////////////////////////////
// MAIN FUNCTION
////////////////////////////////////////////////////////////////////////////////////////////
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

	level thread rattle_audio();
	level thread alarm();
	level thread alarm_off();
	level thread blast_off();
	//level thread convoy_audio();
	level thread mig_audio();
	level thread gantry_audio();
	level thread level_end_rocket();
	level thread level_end_rocket_amb();
	level thread antenna_explo();
	level thread music_for_event_8();
	level thread weaver_room_fire();
	//level thread test();
	
	
	level thread maps\flashpoint_e5::comms_music_setup();
}
music_for_event_8()
{
	flag_wait ("BEGIN_EVENT8");
	//TUEY set music back to the fight song
	setmusicstate("POST_GANTRY_FIGHT");		
}
alarm()
{
	level waittill("alarm");
	alarm = getent("alarm","targetname");
	warningl = getent("warningl","targetname");
	warningr = getent("warningr","targetname");
	level endon("alarm_off");
	
	while(1)
	{
		alarm playloopsound("evt_flashpoint_alarm",.1);
		wait 5;
		alarm stoploopsound(.1);
		warningl playsound("evt_flashpoint_warn_voicel");
		wait 1;
		warningr playsound("evt_flashpoint_warn_voicer","sounddone");
		warningr waittill("sounddone");
	}
	
	
	


}

alarm_off()
{
	level waittill("alarm_stop");
	alarm = getent("alarm","targetname");
	level notify("alarm_off");
	alarm stoploopsound(.1);

}

blast_off()
{
	//thread countdown();
	
	level waittill("blast_off");
	
	rocket = getent("dist_rocket","targetname");
	
	if( IsDefined(rocket) )
	{
		rocket playsound("evt_flashpoint_launch2");
		//wait 9;
		rocket playsound("evt_flashpoint_air_distf");
		rocket playsound("evt_flashpoint_air_distr");
	}
}

countdown()
{
	wait 2;
	countdownl = getent("countdownl","targetname");
	countdownr = getent("countdownr","targetname");
	if( IsDefined( countdownl )&& IsDefined(countdownr) )
	{	
		countdownl playsound( "vox_Fla1_711A_RUA1" , "sounddone" );
		wait .112;
		countdownr playsound( "vox_Fla1_711A_RUA1" );
		countdownl waittill( "sounddone" );
		
		countdownl playsound( "vox_Fla1_712A_RUA1" , "sounddone" );
		wait .112;
		countdownr playsound( "vox_Fla1_712A_RUA1" );
		countdownl waittill( "sounddone" );
		
		countdownl playsound( "vox_Fla1_713A_RUA1" , "sounddone" );
		wait .112;
		countdownr playsound( "vox_Fla1_713A_RUA1" );
		countdownl waittill( "sounddone" );
		
		countdownl playsound( "vox_Fla1_714A_RUA1" );
		wait .112;
		countdownr playsound( "vox_Fla1_714A_RUA1" );
	}
	
}

elevator_audio(wait_time)
{
	
	elevator = getentarray( "elevator", "targetname" );
	
	elevator[0] playsound( "evt_flashpoint_elevator_start" );
	elevator[0] playloopsound( "evt_flashpoint_elevator_loop" , .5 );
	
	wait wait_time;
	
	elevator[0] playsound( "evt_flashpoint_elevator_stop" );
	
	elevator[0] waittill ( "movedone" );
	
	elevator[0] stoploopsound (.5);
	//iprintlnbold( "STOP LOOP" );
	//elevator[0] stoploopsound (2);
}

convoy_audio(car_number)
{
	if( car_number == "vip_car_01" )
	{
		self playsound( "evt_flashpoint_driveby_00" );
	}
	if( car_number == "vip_car_02" )
	{
		self playsound( "evt_flashpoint_driveby_01" );
	}
	if( car_number == "vip_car_03" )
	{
		self playsound( "evt_flashpoint_driveby_02" );
		self playsound( "evt_flashpoint_police_radio" );
	}
	
}

gantry_audio()
{
	//trigger = getent( "trigger_gantry", "targetname" );  //Taken from Junes script rocket_gantry() in graveyard.gsc
	//trigger waittill( "trigger" ); //jpark - trigger no longer activates gantry, button press for roll up door does
	
	level waittill( "open_gantry_audio" );
	
	org1 = getent( "gantry_1", "targetname" );
	org2 = getent( "gantry_2", "targetname" );
	
	gantry_center = getent( "gantry_center" , "targetname" );
	gantry_left = getent( "gantry_left" , "targetname" );
	gantry_right = getent( "gantry_right" , "targetname" );
	
	if( IsDefined( gantry_center )&& IsDefined(gantry_left)&& IsDefined(gantry_right)&& IsDefined(org1)&& IsDefined(org2) )
	{
		thread gantry_alarm(10);
		thread stabilizer_audio();
		
		//level waittill( "gantry_steam");
		gantry_center playsound( "evt_flashpoint_gantry_3dloop" );
		
		wait 4.4;
		
		//level waittill( "gantry_audio_intro");
		org1 playloopsound( "evt_flashpoint_gantry_2dloopf" , .5 );
		
		wait 27;
		
		org1 stoploopsound( 20 );
		gantry_center playsound( "evt_flashpoint_gantry_2dflexf" );
		
		
	}
}

gantry_alarm(x)
{
	//for( y=0; y<2; y++ )
	//{
		for( i=0; i<x; i++ )
		{
			thread alarm_echo(15 , "amb_alarm_buzz");
			wait 1.5;
		}
		//if( y<1 )
		//{
		//	thread alarm_echo(12 , "vox_Fla1_701A_RUA1");
		//	wait 3.8;
		//}
	//}
	//level notify( "gantry_steam" );
	//wait 4.4;
	//level notify( "gantry_audio_intro");
}

alarm_echo(time , sound_alias)
{
	gantry_center = getent( "gantry_center" , "targetname" );
	gantry_left = getent( "gantry_left" , "targetname" );
	gantry_right = getent( "gantry_right" , "targetname" );
	
	if( IsDefined( gantry_center )&& IsDefined(gantry_left)&& IsDefined(gantry_right) )
	{
		gantry_center playsound( sound_alias );
		wait time*.016;
		gantry_left playsound( sound_alias );
		wait time*.016;
		gantry_right playsound( sound_alias );
	}
	
	
}

stabilizer_audio()
{
	stab_big = getent( "rocket_stabilizer_big", "targetname" );
	
	level waittill( "stabilizer_audio" );
	
	if( isdefined( stab_big ) )
	{
		stab_big playsound( "evt_flashpoint_gantry_stab" );
	}
	
	
}

mig_fake_audio(x)
{
	wait (x);
	self playsound( "evt_f4_long_wash" );
}
mig_fake_audio2()
{
	wait 3;
	self playsound( "evt_jet_pass" );
}

mig_audio()
{
	trigger_migs = getent( "trigger_migs", "targetname" );
	trigger_migs waittill( "trigger" );
	
	wait_network_frame();
	
	migs = getentarray("mig", "targetname");
	migs2 = getentarray( "mig2", "targetname" );
	
	if( isdefined( migs )&& isdefined( migs2 ) )
	{
		thread mig_array_audio(migs);
		thread mig_array_audio(migs2);
	}
}
mig_array_audio(array_name)
{
	for( i=0; i<array_name.size; i++ )
		{
			//adding 2d sound here because its easier to distribute the playsound.
			array_name[i] playsound ("veh_mig_flyby_2d");
			//Kevin flyover audio
	    array_name[i] thread plane_position_updater (5000);
		}
}
level_end_rocket()
{
	rocket_dyn_bottom = getent( "rocket_bottom_piece", "targetname" );
	level waittill( "rocket_launch_start" );
	playsoundatposition ("evt_flashpoint_bunker_rocketf", (0,0,0));
	
	wait(2.0);
	rocket_dyn_bottom playloopsound( "evt_flashpoint_launch_loop_rocket" );
	
	flag_wait( "ROCKET_DESTROYED" );
	rocket_dyn_bottom stoploopsound(.1);
	
	playsoundatposition( "evt_flashpoint_bunker_rocket_explo3d" , rocket_dyn_bottom.origin );
	
	wait 5;
	//thread debris_audio();
			
}
level_end_rocket_amb()
{
	level waittill( "start_rocket_loop" );
	rocket_dyn_bottom_s = getent( "rocket_bottom_piece", "targetname" );
	rocket_dyn_bottom_s playloopsound( "evt_flashpoint_bunker_rocket_loop" , 2 );	
	level waittill( "rocket_launch_start" );
	rocket_dyn_bottom_s stoploopsound(.1);
	
	
}

light_tower_audio( time , explo_origin )
{
	
	playsoundatposition( "evt_flashpoint_tower_hit" , explo_origin );	
	wait time;	
	self playsound( "evt_flashpoint_tower_fall" );  //self is the tower
	wait .240;
	self playsound( "evt_flashpoint_tower_fallf" );
	level notify( "debris_audio" );
}

test()
{
	level waittill( "end_rocket_audio" );
	while(1)
	{
		playsoundatposition( "amb_alarm_buzz" , (0,0,0) );
		wait 1;
	}
}

debris_audio()
{
	gantry_center = getent( "gantry_center" , "targetname" );
	
	gantry_center playloopsound( "evt_flashpoint_hot_debris_2dloopf" );
	
	thread chemical_alarm(20);
	thread ambient_explos(1,3);
	
	level waittill( "stop_embers" );
	//iprintlnbold( "STOP LOOP" );
	gantry_center stoploopsound(1);
}

chemical_alarm(x)
{
	gantry_left = getent( "gantry_left" , "targetname" );
	
	wait 2;
	
	for( i=0; i<x; i++ )
	{
		gantry_left playsound( "amb_chem_alarm" );
		
		wait 2.5;
	}
}

base_alarm(x)
{
	gantry_left = getent( "door_blocker" , "targetname" );
	
	gantry_left playloopsound( "amb_radar_station_alarm" );
	
	thread base_alarm_vo();
	
	flag_wait( "window_breached" );
	
	gantry_left stoploopsound(1);
	
	//wait 2;
	/*
	for( i=0; i<x; i++ )
	{
		gantry_left playsound( "amb_radar_station_alarm" );
		
		wait 3.5;
	}
	*/
}

base_alarm_vo()
{
	//temp vo.  This is using the rocket launch countdown until we can get new lines if possible
	gantry_left = getent( "door_blocker" , "targetname" );
	
	gantry_left playsound( "vox_fla1_s02_055A_ruld_f" , "sound_done" );
	gantry_left waittill ( "sound_done" );
	gantry_left playsound( "vox_fla1_s02_056A_ruld_f" , "sound_done" );
	gantry_left waittill ( "sound_done" );
	gantry_left playsound( "vox_fla1_s02_057A_ruld_f" );
}

ambient_explos( min , max )
{
	level endon( "stop_debris_approach" );
	
	gantry_left = getent( "gantry_left" , "targetname" );
	
	wait 10;
	
	while( 1 )
	{
		gantry_left playsound( "evt_flashpoint_ambient_st_explof" );
		
		wait RandomFloatRange( min , max );
		
		gantry_left playsound( "evt_flashpoint_ambient_st_explor" );
		
		wait RandomFloatRange( min , max );
	}
	
	
}

model_anim_audio()
{
	//first 4 pieces of metal that falls from the sky after rocket explodes
	ent6 = getent( "rc_grp01_01", "targetname" );
	ent7 = getent( "rc_grp01_02", "targetname" );
	ent8 = getent( "rc_grp01_03", "targetname" );
	ent9 = getent( "rc_grp01_04", "targetname" );
	
	//next 3 pieces that are just over the train tracks
	ent10 = getent( "rc_grp02_01", "targetname" );
	ent11 = getent( "rc_grp02_02", "targetname" );
	ent12 = getent( "rc_grp02_03", "targetname" );
	
	//next 3 pieces that are fall after the gas station gets hit
	ent13 = getent( "rc_grp03_01", "targetname" );
	ent14 = getent( "rc_grp03_02", "targetname" );
	ent15 = getent( "rc_grp03_03", "targetname" );
	
	
	//next 3 pieces that are fall before building gets hit
	ent16 = getent( "rc_grp04_01", "targetname" );
	ent17 = getent( "rc_grp04_02", "targetname" );
	ent18 = getent( "rc_grp04_03", "targetname" );
	
	
	//next 2 pieces that are fall in the beginning of heli area
	ent19 = getent( "rc_grp05_01", "targetname" );
	ent20 = getent( "rc_grp05_02", "targetname" );

	
		

	if (IsDefined(ent6)) 
	{
		ent6 thread grp01_01();
	}
	if (IsDefined(ent7)) 
	{
		ent7 thread grp01_02();
	}
	if (IsDefined(ent8)) 
	{
		ent8 thread grp01_03();
	}
	if (IsDefined(ent9)) 
	{
		ent9 thread grp01_04();
	}
	if (IsDefined(ent10)) 
	{
		ent10 thread grp02_01();
	}
	if (IsDefined(ent11)) 
	{
		ent11 thread grp02_02();
	}
	if (IsDefined(ent12)) 
	{
		ent12 thread grp02_03();
	}
	if (IsDefined(ent13)) 
	{
		ent13 thread grp03_01();
	}
	if (IsDefined(ent14)) 
	{
		ent14 thread grp03_02();
	}
	if (IsDefined(ent15)) 
	{
		ent15 thread grp03_03();
	}
	if (IsDefined(ent16)) 
	{
		ent16 thread grp04_01();
	}
	if (IsDefined(ent17)) 
	{
		ent17 thread grp04_02();
	}
	if (IsDefined(ent18)) 
	{
		ent18 thread grp04_03();
	}
	if (IsDefined(ent19)) 
	{
		ent19 thread grp05_01();
	}
	if (IsDefined(ent20)) 
	{
		ent20 thread grp05_02();
	}
}

grp01_01()
{
	level waittill("grp01_01_start");
	wait 1;
	self playsound( "evt_flashpoint_debris1_imp" );
}

grp01_02()
{
	level waittill("grp01_02_start");
	wait 1;
	self playsound( "evt_flashpoint_debris_short_imp" );
}

grp01_03()
{
	level waittill("grp01_03_start");
	wait 1;
	self playsound( "evt_flashpoint_debris_short_imp" );
}

grp01_04()
{
	level waittill("grp01_04_start");
	wait 1;
	self playsound( "evt_flashpoint_debris_short_imp" );
}

grp02_01()
{
	level waittill("grp02_01_start");
	wait 1;
	self playsound( "evt_flashpoint_debris_short_imp" );
}

grp02_02()
{
	level waittill("grp02_02_start");
	wait 1;
	self playsound( "evt_flashpoint_debris_short_imp" );
}

grp02_03()
{
	level waittill("grp02_03_start");
	wait 1;
	self playsound( "evt_flashpoint_debris_short_imp" );
}

#using_animtree("fxanim_props");
grp03_01()
{
	level waittill("grp03_01_start");
	wait 1;
	self playsound( "evt_flashpoint_debris2_imp" );
}

grp03_02()
{
	//vo line that was too close
	level waittill("grp03_02_start");
	wait 1;
	self playsound( "evt_flashpoint_debris2_imp" );
}

grp03_03()
{
	level waittill("grp03_03_start");
	wait 1;
	self playsound( "evt_flashpoint_debris_short_imp" );
}

grp04_01()
{
	level waittill("grp04_01_start");
	wait 1;
	self playsound( "evt_flashpoint_debris2_imp" );
}

grp04_02()
{
	level waittill("grp04_02_start");
	wait 1;
	self playsound( "evt_flashpoint_debris1_imp" );
}

grp04_03()
{
	level waittill("grp04_03_start");
	wait 1;
	self playsound( "evt_flashpoint_debris2_imp" );
}

grp05_01()
{
	level waittill("grp05_01_start");
	wait 1;
	self playsound( "evt_flashpoint_debris_short_imp" );
}

grp05_02()
{
	level waittill("grp05_02_start");
	wait 1;
	self playsound( "evt_flashpoint_debris_short_imp" );
}

rollup_door_audio()//self is the door
{
	self playsound( "evt_flashpoint_storage_door_open" );
	self playloopsound( "evt_flashpoint_storage_door_loop" , 1 );
	wait 6.5;
	self playsound( "evt_flashpoint_storage_door_close" );
	self stoploopsound( 1 );
}

pa_audio( alias )
{
	countdownl = getent("countdownl","targetname");
	countdownr = getent("countdownr","targetname");
	if( IsDefined( countdownl )&& IsDefined(countdownr) )

	countdownl playsound(alias);
	wait .112;
	countdownr playsound(alias);

}

antenna_explo()
{
	level waittill( "antenna_start" );
	ent3 = getent( "fxanim_flash_antenna_mod", "targetname" );
	
	wait .5;
	
	ent3 playsound( "evt_flashpoint_bunker_rocket_explo3d" );
	
}

helicopter_crash()
{
	heli = getent( "escape_helicopter", "targetname" );
	node1 = getvehiclenode( "node_heli_hit", "targetname" );
	node2 = getvehiclenode( "heli_crash", "targetname" );
	
	node1 waittill( "trigger" );
	
	heli playloopsound( "evt_flashpoint_helicopter_dying_loop" );
	
	node2 waittill( "trigger" );
	
	heli stoploopsound( .112 );
}

rattle_audio()
{
	level waittill( "rattle_audio" );
	player = getplayers()[0];
	player playsound( "evt_flashpoint_rattle_f" );
	
	level waittill( "rattle_audio2" );
	player playsound( "evt_flashpoint_rattle_f" );
	
	level waittill( "rattle_audio3" );
	player playsound( "evt_flashpoint_rattle_f" );
}
rope_gun()
{
	player = getplayers()[0];
	player playloopsound( "wpn_rope_shot" );
	wait .05;
	player StopLoopSound(2);
	wait 1.5;
	player playsound( "wpn_rope_hit" );
	
}
zipline()
{
	player = getplayers()[0];
	player playloopsound( "evt_rappel_slide" );
	//wait 5.8;
	flag_wait( "window_breached" );
	wait .27;
	player stoploopsound(1);
	player playsound( "evt_win_breach_glass_shatter" );
}
bell_alarm()
{
	alarm = getentarray ("amb_bell_alarm", "targetname");	
	for(i=0;i<alarm.size;i++)
	{
		alarm[i] thread play_bell_sound();	
	}
}
play_bell_sound()
{
	self playloopsound ("amb_alarm_bell");	
	
}

weaver_room_fire()
{
	wait_for_all_players();
	ent = spawn( "script_origin" , (-5018.1,-242.4,350.1));
	ent playloopsound( "amb_fire_md" );
}
////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////
