/*
	
	KOWLOON E1 Interrogate

	This starts at the beginning of the level
	It ends immediately after the player gains control.
*/
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_music;

event1()
{
	flag_init( "wall_breach" );
	battlechatter_off();

	//shabs - hiding ladder until hatch opens
//	player_ladder = GetEnt( "player_ladder", "targetname" );
//	player_ladder trigger_off();
	
	//Decreasing sun sample size near
	sssn = GetDvar("sm_sunSampleSizeNear" );
	SetSavedDvar("sm_sunSampleSizeNear", "0.0625" );

	//setting new fog settings
	start_dist = 8.35587;
	half_dist = 308.541;
	half_height = 248.487;
	base_height = 2975.97;
	fog_r = 0.0666667;
	fog_g = 0.101961;
	fog_b = 0.113725;
	fog_scale = 3.14083;
	sun_col_r = 0.552941;
	sun_col_g = 0.686275;
	sun_col_b = 0.729412;
	sun_dir_x = 0.163263;
	sun_dir_y = -0.944148;
	sun_dir_z = 0.286235;
	sun_start_ang = 0;
	sun_stop_ang = 99.2932;
	time = 0;
	max_fog_opacity = 0.866884;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale, sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, sun_stop_ang, time, max_fog_opacity);

	//player DOF for intro scene

	//TUEY set's up the INTRO music state
	setmusicstate ("INTRO");
	//level thread play_punches();

	// Interrogation
	level thread maps\kowloon_anim::interrogation_setup();
	level waittill("interrogation_midway_through");
	
	//TUEY set's up the INTRO music state
	setmusicstate ("CLARK_SPEAKS");

	// Wait until we're midway through interrogation
	wait( 35 );
	// Spawn guys running around the roofs.
	ai_rooftop_runners = simple_spawn( "ai_e1_rooftop_runners", maps\kowloon_util::silent_runner_bg );
	array_thread( ai_rooftop_runners, maps\kowloon_util::civ_timeout_death );

	// Spawn active enemies
	ai_rooftops = simple_spawn( "ai_e1_rooftops", ::wait_for_action );
	array_thread( ai_rooftops, maps\kowloon_gas_leak::turn_off_jump_aim_assist );

	wait( 18 );

	//Return sun sample size near
	SetSavedDvar("sm_sunSampleSizeNear", sssn );
	
	level thread maps\kowloon_gas_leak::event2();
	flag_set( "event2" );

	// Savegame is at the end of the current even so that it doesn't 
	// save immediately after starting a jumpto
	autosave_by_name( "kowloon_gas_leak" );

	//wait(5);
	//iprintln("Get out of There!");

	//notify clark to open the escape hatch
	level notify("start_escape");

	//TUEY Set music state to EARLY_ACTION
	setmusicstate ("EARLY_ACTION");
	level thread play_window_shot_audio();

	// Cleanup
	flag_wait( "event3" );
}


//
//	Run to your staging spots and then start shooting when the breach starts
wait_for_action()
{
	self thread maps\kowloon_util::silent_runner();
	flag_wait( "event2" );

	self.ignoreme = 0;
	set_pacifist( false );

	self thread maps\kowloon_util::force_goal_self();
}


//
//
play_window_shot_audio()
{
    wait(1.5);
    playsoundatposition( "evt_window_shot", (0,0,0) );
    playsoundatposition( "evt_pre_breach", (1624,760,3486) );

}

play_punches()
{
  	wait(3);
		playsoundatposition ("evt_white_punch", (0,0,0));
	
	//shabs - added a slight rumble
	player = get_players()[0];
	player PlayRumbleOnEntity( "damage_heavy" );
}
