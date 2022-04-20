//
// file: wmd_sr71_amb.gsc
// description: level ambience script for wmd_sr71
// scripter: 
//

#include maps\_ambientpackage;
#include maps\_utility;
#include common_scripts\utility;
#include maps\wmd_sr71_util;
main()
{



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
event_heart_beat( emotion, loudness )
{	
	
	// Emotional State of Player
	// sedated (super slow heartbeat )
	// relaxed ( normal heart beat )
	// stressed (fast heartbeat)
	
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
			
			break;
		case "relaxed":
			level.heart_waittime = 2;
			level.breathing_waittime = 4;
			break;
		case "stressed":
			level.heart_waittime = 0.5;
			level.breathing_waittime = 2;
			break;
		case "panicked":
			level.heart_waittime = 0.3;
			level.breathing_waittime = 1.5;
			break;
		case "none":
			level notify ("no_more_heartbeat");	
			playsoundatposition ("vox_breath_scared_stop", (0,0,0));
			level.emotional_state_system = 0;
			
			break;
		
		default: AssertMsg("Not a Valid Emotional State.  Please switch with sedated, relaxed, happy, stressed, or none");
	}
	thread heartbeat_state_transitions();  //(controls the wait between breaths and beats
		
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

play_sr71_surround_track()
{
	
	level thread play_sr71_interior_loops();
	playsoundatposition ("veh_sr71_walkup_front", (0,0,0));
	
	flag_wait( "camera_cut_1" );
	playsoundatposition ("veh_sr71_takeoff_front", (0,0,0));
	
}
play_sr71_interior_loops()
{
	wait(50);
	ent_1 = spawn ("script_origin", (0,0,0));
	ent_2 = spawn ("script_origin", (0,0,0));
	
	ent_1 playloopsound ("veh_sr71_wait_loop_front");
	ent_2 playloopsound ("veh_sr71_wait_loop_rear");
	
	level waittill ("start_takeoff_sounds");
	ent_1 stoploopsound ();
	ent_2 stoploopsound ();
	
	wait(0.2);
	ent_1 delete();
	ent_2 delete();
		
}