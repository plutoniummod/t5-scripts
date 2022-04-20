//
// file: wmd_amb.gsc
// description: level ambience script for wmd
// scripter: 
//

#include maps\_ambientpackage;
#include maps\_utility;
#include common_scripts\utility;
#include maps\wmd_util;
// #include maps\wmd_event1;


main()
{
	level thread heartbeat_init();
	level thread play_environmental_fire();
	level thread play_random_distant_PA();
	

}
play_environmental_fire()
{
	wood_fire = spawn ("script_origin", (12380, -7205, 10000));
	barrel_fire = spawn ("script_origin", (12530, -7276, 10000));
	
	wood_fire playloopsound ("amb_wood_fire");
	barrel_fire playloopsound ("amb_barrel_fire");
	
}
heartbeat_init()
{
	level.current_heart_waittime = 2;
	level.heart_waittime = 2;
	level.current_breathing_waittime = 4;
	level.breathing_waittime = 4;
	level.emotional_state_system = 0;

}

event_heart_beat( emotion, loudness )
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
				playsoundatposition ("vox_breath_scared_stop", (0,0,0));
				level.emotional_state_system = 0;				
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
	player = getplayers()[0];
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
		
		player PlayRumbleOnEntity("damage_light");	
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
//kevin addin special case to stop the heartbeat and breathing when the player has landed after the base jump.
base_jump_heartbeat_stop()
{
	flag_wait( "players_jumped" );
	level thread event_heart_beat( "none" , 0 );
}

play_radar_alert()
{
	level endon ("base_alarm_off");
	if(!IsDefined (level.countme))
	{
		level.countme = 1;
		playsoundatposition ("vox_radar_base_alert", (11975, -30287, 38749.5));	
		wait (5);
		
		
		while(1)
		{
			// TO DO -- Change music track during this fight and turn the Alarm back on.
			playsoundatposition ("amb_radar_station_alarm", (11975, -30287, 38749.5));	
			wait(3.5);
		
		}	
	}
	
}

computer_sounds_power_relay()
{
//	iprintlnbold("Found a computer sound");
	
	level waittill("base_sounds_upper");
	
	self.comp_sound_upper = spawn("script_origin", self.origin );
	self.comp_sound_upper playloopsound ("amb_computer_sounds", 0);
	self thread wait_for_power_out_upper();
	self waittill ("rus_console_rad_break");
	self.comp_sound_upper stoploopsound(0.5);
//	iprintlnbold ("It frakkin' worked.");
	
	wait(1);

	self.comp_sound_upper delete();
	
	
	
}
	
wait_for_power_out_upper()
{
	level waittill ("radar_disabled");
	self.comp_sound_upper stoploopsound(0.5);
	wait(1);
	
	self.comp_sound_upper delete();
	
	
}

computer_sounds_main_base()
{
	
	level waittill("start_base_sounds");	
	
	self.comp_sound = spawn("script_origin", self.origin);	
	self.comp_sound playloopsound ("amb_computer_sounds");	
	self thread wait_for_power_out_lower();
	self waittill ("rus_console_rad_break");
	self.comp_sound stoploopsound(0.5);
	wait(1);
	self.comp_sound delete();
}



wait_for_power_out_lower()
{
	level waittill ("radar_disabled");
	self.comp_sound stoploopsound(0.5);
	wait(1);
	
	self.comp_sound delete();
	
	
}
radar_dish_sounds_start(dish)
{

	
	secondary_ent = spawn ("script_origin", dish.origin);	
	dish playsound ("amb_radar_start");
	wait(0.15);
	dish playloopsound ("amb_radar_move_loop");
	secondary_ent playloopsound ("amb_radar_move_loop_close");
	level waittill ("dish_stop");
	dish stoploopsound (0.25);
	secondary_ent stoploopsound (0.25);
	playsoundatposition ("amb_radar_stop", dish.origin);
	secondary_ent delete();
	
	
}
radar_dish_sounds_stop(dish)
{
	level notify ("dish_stop");	
}
play_random_distant_PA()
{
	level endon("close_to_base");
	//randomly plays "vox_reb1_s01_022A_rus1_f" from the base while you are walking down to the base
	
	while(1)
	{
		wait(randomintrange(15, 20));
		playsoundatposition ("vox_russian_base_PA", (11975, -30287, 38749.5)); //same as alarm coords.
		
	}	
	
}

cb_audio_chatter()
{
	self playsound( "vox_cb1" , "sound_done" );
	self waittill( "sound_done" );
	self playsound( "vox_cb2" , "sound_done" );
	self waittill( "sound_done" );
	self playsound( "vox_cb3" , "sound_done" );
	self waittill( "sound_done" );
	self playsound( "vox_cb4" , "sound_done" );
	self waittill( "sound_done" );
	self playsound( "vox_cb5" , "sound_done" );
	self waittill( "sound_done" );
}

player_turret_audio()
{
	level endon( "stop_turret_audio" );
	player = get_players()[0];
	sound_ent = Spawn( "script_origin", (0, 0, 0) );
	self thread turret_audio_failsafe( sound_ent );
	//IPrintLnBold("PLAYER TURRET START");

	while( 1 )
	{
		while(!player AttackButtonPressed())
		{
			wait( 0.05 );
		}
		while(player AttackButtonPressed())
		{
			sound_ent playloopsound( "wpn_pbr_turret_fire_loop_plr" );
			wait( 0.05 );
		}
		sound_ent stoploopsound();
		sound_ent playsound( "wpn_pbr_turret_fire_loop_ring_plr" );
	}
	
}

turret_audio_failsafe( sound_ent )
{
	self waittill_any( "death" , "disconnect" , "end_player_heli", "player_not_using_boat" );
	//IPrintLnBold("AUDIO ENNND");
	level notify( "stop_turret_audio" );
	player = get_players()[0];
	if( player AttackButtonPressed() )
	{
		sound_ent stoploopsound();
		sound_ent playsound( "wpn_pbr_turret_fire_loop_ring_plr" );
	}
}
