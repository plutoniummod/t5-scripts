#include common_scripts\utility; 
#include maps\_utility;

//_createart generated.  modify at your own risk. Changing values should be fine.
main()
{
 
 	// *Fog section* 

	setdvar("scr_fog_exp_halfplane", "4000");
	setdvar("scr_fog_exp_halfheight", "300");
	setdvar("scr_fog_nearplane", "2000");
	setdvar("scr_fog_red", "0.05");
	setdvar("scr_fog_green", "0.05");
	setdvar("scr_fog_blue", "0.05");
	setdvar("scr_fog_baseheight", "50");
	
 
// flashlight values
	set_standard_flashlight_values();
//	set_dim_flashlight_values()
	
	level thread art_settings_for_meatshield();
	level thread change_fog_setting_for_village_dock();	
	level thread change_art_settings_tunnel();
	level thread tunnel_collapse_art();
	level thread tunnel_light_end_art();
	level thread tunnel_cliffhanger_art();
//	level thread dof_change_looking_at_woods_from_hole();
	
	
	//SetDvar( "r_heroLightScale", "1 1 1" ); Depricated Hero Lighting
	VisionSetNaked( "creek_1", 0 );
	SetSavedDvar( "sm_sunSampleSizeNear", 0.5 );
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.40 );
	SetSavedDvar( "r_lightGridContrast", .25 );
	
}

art_settings_inside_crashed_huey()
{
//---------------------------------------------------------------
// START OF LEVEL


	// we change depth of the field for swimming
	maps\_utility::set_swimming_depth_of_field(true, false, 10, 60, 341, 2345, 6, 2.16);
		
	// However, sicne swimming is disabled at the start of the level, the last line may
	// not have taken effect. Add any direct dof modifications here as well.
	
	start_dist = 595;
	half_dist = 603;
	half_height = 1346;
	base_height = 140;
  fog_r = 0.875;
	fog_g = 0.954;
	fog_b = 1;
	fog_scale = 10;
	sun_col_r = 0;
	sun_col_g = 0;
	sun_col_b = 0;
	sun_dir_x = -0.13239;
	sun_dir_y = -0.596622;
	sun_dir_z = 0.791528;
	sun_start_ang = 0;
	sun_stop_ang = 1;
	time = 0;
	max_fog_opacity = 1;

		setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
						
	SetSavedDvar( "r_lightTweakSunLight", 12 ); 
	

		// Depth of Field settings
	near_start = 10;
	near_end = 60;
	far_start = 98.6;
	far_end = 1853;
	near_blur = 5.1;
	far_blur = 1;
	player = GetPlayers()[0];	
	player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur);

	
	// Wait for player to load in. We need the player to be ready to call the client scripts
	// for anything visionset related
	wait( 1.5 );
	player = get_players()[0];


	// vision set for inside helicopter at the start of the level
	// We need all these lines to make sure server, client, and swimming scripts are all on the same page
	clientNotify( "use_helicopter_start_visionset" );
	level maps\_swimming::set_default_vision_set( "creek_1_helicopter_start" );
	level maps\_swimming::set_swimming_vision_set( "creek_1_helicopter_start" );
	VisionSetNaked( "creek_1_helicopter_start", 0 );
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.2 );
	SetSavedDvar( "r_lightGridContrast", .25 );

	
//---------------------------------------------------------------
// PLAYER MOVING TO FRONT OF HUEY

	level waittill( "player_move_to_huey_front" );
	
	//IPrintLnBold("New dof I put in for front of huey");
		
	
//---------------------------------------------------------------
// PLAYER CHECKS THE PILOT

	level waittill( "player_grabs_pilot" );
	
	near_start = 1;
	near_end = 2.6;
	far_start = 2.7;
	far_end = 130;
	near_blur = 4;
	far_blur = 2.2;
	player = GetPlayers()[0];	
	player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur);
	
	SetSavedDvar( "r_lightTweakSunLight", 6.5); 
	VisionSetNaked( "creek_1_helicopter", 2 );
	
		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.25 );
	SetSavedDvar( "r_lightGridContrast", .15 );
	

//---------------------------------------------------------------
// COPILOT IS SHOT

	level waittill( "pilot_shot_in_head" );
	SetSavedDvar( "r_lightTweakSunLight", 12); 
	

//---------------------------------------------------------------
// PLAYER HAVE CONTROL AND STARTS SHOOTING AT VC


	flag_wait("player_has_control");

	clientNotify( "use_helicopter_visionset" );
	level maps\_swimming::set_default_vision_set( "creek_1_helicopter" );
	level maps\_swimming::set_swimming_vision_set( "creek_1_helicopter" );
	
	
	// Depth of Field settings
	near_start = 0;
	near_end = 32;
	far_start = 100;
	far_end = 5260;
	near_blur = 4;
	far_blur =10;
	player = GetPlayers()[0];	
	player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur);

	

	

//---------------------------------------------------------------
// PLAYER FALLS BACK INTO WATER
	
	// wait until player is about to fall into the water as heli sinks
	flag_wait("player_below_water");
	

	
	// player is going to fall in water
	clientNotify( "use_helicopter_water_visionset" );
	

	level maps\_swimming::set_default_vision_set( "creek_1_helicopter_water" );
	level maps\_swimming::set_swimming_vision_set( "creek_1_helicopter_water" );
	VisionSetNaked( "creek_1_helicopter_water", 0 );

	start_dist = 854.29;
	half_dist = 1242.17;
	half_height = 1578.25;
	base_height = 155.672;
	fog_r = 0.466667;
	fog_g = 0.52549;
	fog_b = 0.533333;
	fog_scale = 4.05841;
	sun_col_r = 1;
	sun_col_g = 1;
	sun_col_b = 1;
	sun_dir_x = -0.13239;
	sun_dir_y = -0.596622;
	sun_dir_z = 0.791528;
	sun_start_ang = 0;
	sun_stop_ang = 69.353;
	time = 0;


	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.5 );
	SetSavedDvar( "r_lightGridContrast", .2 );
		
	
//---------------------------------------------------------------
// DOOR OPENS UP
	
	// Reznov shows up to help with the door
	flag_wait("open_huey_door");
	
		//IPrintLnBold("open_huey_door");
		
	clientNotify( "huey_door_opens" );
	level maps\_swimming::set_default_vision_set( "creek_1" );
	level maps\_swimming::set_swimming_vision_set( "creek_1_helicopter_water_exit" );
	VisionSetNaked( "creek_1", 3 );
	SetSavedDvar( "r_lightTweakSunLight", 4 );
	
//---------------------------------------------------------------
// PLAYER OUT OF THE HUEY
	
	// wait for player to be out of the huey and start swimming
	flag_wait("heli_crash_scene_done");
	
		//IPrintLnBold("heli_crash_scene_done");	
			
	// Aliu: Reset the near plane to normal
	player reset_near_plane();

start_dist = 718.422;
	half_dist = 1746.33;
	half_height = 1463.11;
	base_height = 155.672;
	fog_r = 0.376471;
	fog_g = 0.505882;
	fog_b = 0.533333;
	fog_scale = 4.05841;
	sun_col_r = 1;
	sun_col_g = 1;
	sun_col_b = 1;
	sun_dir_x = -0.13239;
	sun_dir_y = -0.596622;
	sun_dir_z = 0.791528;
	sun_start_ang = 0;
	sun_stop_ang = 69.353;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	// comment this out until we get some actual light values
		//IPrintLnBold("sunlight tweaked again in player_near_plane function");
	SetSavedDvar( "r_lightTweakSunLight", 4 ); 
	
		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.5 );
	SetSavedDvar( "r_lightGridContrast", .2 );
}

art_settings_for_meatshield()
{
//---------------------------------------------------------------
// PLAYER CLIMBING ON THE SAMPAN

	wait( 6 );
	
	flag_wait( "player_meatshield_ready" );	
	SetSavedDvar( "r_lightTweakSunLight", 9); 
//IPrintLnBold("player_meatshield_ready");
	// If needed, wait a second or 2 here to get the time when player grabs the VC
	// TODO: Add art settings here

	wait(2);
	
	// Depth of Field settings
	near_start = 1;
	near_end = 12;
	far_start = 1000;
	far_end = 1200;
	near_blur = 4;
	far_blur = 1;
	player = GetPlayers()[0];	
	player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur);
	
			SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.0 );
	SetSavedDvar( "r_lightGridContrast", .25 );

//---------------------------------------------------------------
// ALL ENEMIES KILLED

	// wait for bullet cam to start
	player = get_players()[0];
	player waittill("_bulletcam:start");
	player maps\_art::setdefaultdepthoffield();
//IPrintLnBold("all_meatshield_vc_dead");
	
	// TODO: Restore art settings
	player = GetPlayers()[0];	
 	player maps\_art::setdefaultdepthoffield();
 	
 start_dist = 287.817;
	half_dist = 1597.85;
	half_height = 515.622;
	base_height = 114.736;
	fog_r = 0.376471;
	fog_g = 0.505882;
	fog_b = 0.533333;
	fog_scale = 4.05841;
	sun_col_r = 1;
	sun_col_g = 1;
	sun_col_b = 1;
	sun_dir_x = -0.13239;
	sun_dir_y = -0.596622;
	sun_dir_z = 0.791528;
	sun_start_ang = 0;
	sun_stop_ang = 69.353;
	time = 30;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
}

art_settings_for_light_rain()
{
	player = get_players()[0];
	player clientNotify( "set_creek_rain_visionset" );
	level maps\_swimming::set_default_vision_set( "creek_1_rain" );
	

	VisionSetNaked( "creek_1_rain", 20 );
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.33 );
	SetSavedDvar( "r_lightGridContrast", 0.15 );
	
	start_dist = 222.817;
	half_dist = 929.353;
	half_height = 404.445;
	base_height = -7.62267;
	fog_r = 0.203922;
	fog_g = 0.25098;
	fog_b = 0.258824;
	fog_scale = 4.05841;
	sun_col_r = 1;
	sun_col_g = 1;
	sun_col_b = 1;
	sun_dir_x = -0.13239;
	sun_dir_y = -0.596622;
	sun_dir_z = 0.791528;
	sun_start_ang = 0;
	sun_stop_ang = 69.353;
	time = 20;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	//IPrintLnBold( "r_lightTweakSunLight 7");	
	level thread lerp_my_dvar( "r_lightTweakSunLight", 8, 4 );
	//SetSavedDvar( "r_lightTweakSunLight", 3 ); 
	
	//iprintlnbold( "light rain" );
}

// for the rain section
alternating_fog_values( end_msg )
{
	level endon( end_msg ); // stop alternating when this message is received

	while( 1 )
	{
		// set fog value 2 (the lighter version)

	start_dist = 222.58;
	half_dist = 839.702;
	half_height = 228.645;
	base_height = -7.62267;
	fog_r = 0.203922;
	fog_g = 0.25098;
	fog_b = 0.258824;
	fog_scale = 4.05841;
	sun_col_r = 1;
	sun_col_g = 1;
	sun_col_b = 1;
	sun_dir_x = -0.13239;
	sun_dir_y = -0.596622;
	sun_dir_z = 0.791528;
	sun_start_ang = 0;
	sun_stop_ang = 71.3103;
	time = 5;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


			
			//IPrintLnBold( "r_lightTweakSunLight 7");				
		level thread lerp_my_dvar( "r_lightTweakSunLight", 8, 2 );
		
		wait( randomfloat( 3 ) + 4 ); // wait randomly between 4-7 seconds
		
		// set fog value 1 (the thicker version)
		
  start_dist = 222.58;
	half_dist = 372;
	half_height = 228.645;
	base_height = -7.62267;
	fog_r = 0.203922;
	fog_g = 0.25098;
	fog_b = 0.258824;
	fog_scale = 4.05841;
	sun_col_r = 1;
	sun_col_g = 1;
	sun_col_b = 1;
	sun_dir_x = -0.13239;
	sun_dir_y = -0.596622;
	sun_dir_z = 0.791528;
	sun_start_ang = 0;
	sun_stop_ang = 71.3103;
	time = 5;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

			
			//IPrintLnBold( "r_lightTweakSunLight 3");									
	 level thread lerp_my_dvar( "r_lightTweakSunLight", 6, 2 );
		
		wait( randomfloat( 3 ) + 4 ); // wait randomly between 4-7 second
	}
}

art_settings_for_heavy_rain()
{
	// fog values will alternate until player get up the ladder after VC drops into water
	level thread alternating_fog_values( "village_hut_start" );

}

// this sets the visionset and fog values when the player enters the large hut
// just before the village ambush
art_settings_for_village_intro()
{
	player = get_players()[0];
	player clientNotify( "set_creek_ambush_visionset" );
	
	level maps\_swimming::set_default_vision_set( "creek_1_ambush_path" );
	
		level thread lerp_my_dvar( "r_lightTweakSunLight", 9, 15 );
		
	VisionSetNaked( "creek_1_ambush_path", 15 );
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.3 );
	SetSavedDvar( "r_lightGridContrast", .25 );
	
	// enable tweaks
	player = get_players()[0];

	start_dist = 299.303;
	half_dist = 5561.75;
	half_height = 732.248;
	base_height = -58;
	fog_r = 0.164706;
	fog_g = 0.188235;
	fog_b = 0.203922;
	fog_scale = 10;
	sun_col_r = 1;
	sun_col_g = 0.921569;
	sun_col_b = 0.862745;
	sun_dir_x = 0.312184;
	sun_dir_y = -0.664536;
	sun_dir_z = 0.678921;
	sun_start_ang = 0;
	sun_stop_ang = 61.3425;
	time = 15;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

}

// this sets the visionset and fog values when the player gets to the cover spot
// just before pulling the detonator
set_village_art_values()
{
	player = get_players()[0];
	player clientNotify( "set_creek_village_visionset" );
	level maps\_swimming::set_default_vision_set( "creek_1_village" );
	

	VisionSetNaked( "creek_1_village", 15 );
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.25 );
	SetSavedDvar( "r_lightGridContrast", 0.25 );
	
	set_village_fog_setting( 30 );

} 

set_village_fog_setting( transition_time )
{

		start_dist = 367.807;
	half_dist = 1000.95;
	half_height = 1163.65;
	base_height = -403.952;
	fog_r = 0.164706;
	fog_g = 0.188235;
	fog_b = 0.203922;
	fog_scale = 4.75241;
	sun_col_r = 0.615686;
	sun_col_g = 0.545098;
	sun_col_b = 0.431373;
	sun_dir_x = 0.312184;
	sun_dir_y = -0.664536;
	sun_dir_z = 0.678921;
	sun_start_ang = 0;
	sun_stop_ang = 63.0388;
	time = 15;
	max_fog_opacity = 0.97;


	if( isdefined( transition_time ) )
	{
		time = transition_time;
	}

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
}

set_dock_fog_setting() 
{
	start_dist = 367.807;
	half_dist = 1172.95;
	half_height = 1163.65;
	base_height = -403.952;
	fog_r = 0.164706;
	fog_g = 0.188235;
	fog_b = 0.203922;
	fog_scale = 4.75241;
	sun_col_r = 0.615686;
	sun_col_g = 0.545098;
	sun_col_b = 0.431373;
	sun_dir_x = 0.312184;
	sun_dir_y = -0.664536;
	sun_dir_z = 0.678921;
	sun_start_ang = 0;
	sun_stop_ang = 63.0388;
	time = 0;
	max_fog_opacity = 0.889268;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

}

lerp_my_dvar( dvar_name, new_value, time )
{
	old_value = GetDvar( dvar_name );
	old_value = float( old_value );
	
	frames = int( time * 20 );
	increment = ( new_value - old_value ) / frames;
	current_value = old_value;
	
	for( i = 0; i < frames; i++ )
	{
		wait( 0.05 );
		current_value += increment;
		SetSavedDvar( dvar_name, current_value );
	}
	
	SetSavedDvar( dvar_name, new_value );
}

change_fog_setting_for_village_dock()
{
	level endon( "b4_player_near_tunnel" );	
		
	wait( 4 );
	player_at_dock = false;
	dock_trigger = getent( "trigger_near_shore", "targetname" );
	player = get_players()[0];
	
	if(IsDefined(dock_trigger))
	{
		while( 1 )
		{
			if( player istouching( dock_trigger ) && player_at_dock == false )
			{
				player_at_dock = true;
				// change fog setting to dock 
				set_dock_fog_setting();
			}
			else if( player istouching( dock_trigger ) == false && player_at_dock == true )
			{
				player_at_dock = false;
				// change fog setting back to village
				set_village_fog_setting();
			}
			wait( 1 );
		}
	}
}

 dof_change_looking_at_woods_from_hole()
{
	
	// Depth of Field settings
	near_start = 0.2;
	near_end = 69.2;
	far_start = 470;
	far_end = 3845;
	near_blur = 4.7;
	far_blur = 2.6;
	player = GetPlayers()[0];	
	player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur);

}

set_standard_flashlight_values()
{
	SetSavedDvar( "r_flashLightRange", "436" );
	SetSavedDvar( "r_flashLightEndRadius", "300" );
	SetSavedDvar( "r_flashLightBrightness", "25" );
	SetSavedDvar( "r_flashLightOffset", "-10.3 -7.8 -4.2" );
	VisionSetNaked( "creek_1_tunnel", 0 );
	
	player = get_players()[0];
	if( isdefined( player ) )
	{
		player clientnotify( "flashlight_visionset" );
	}
	
	SetSavedDvar( "r_flashLightFlickerAmount", "0.03" );
	SetSavedDvar( "r_flashLightFlickerRate", "62" );
	SetSavedDvar( "r_flashLightBobAmount", "3 3 3" );
	SetSavedDvar( "r_flashLightBobRate", "0.17 0.16 0.25" );
	SetSavedDvar( "r_flashLightColor", "1 1 1" );
	

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 0.5 );
	SetSavedDvar( "r_lightGridContrast", 0 );
}

set_dim_flashlight_values()
{
	SetSavedDvar( "r_flashLightRange", "400" );
	SetSavedDvar( "r_flashLightEndRadius", "1200" );
	SetSavedDvar( "r_flashLightBrightness", "1" );
	SetSavedDvar( "r_flashLightOffset", "0 2 1" );
	VisionSetNaked( "creek_1_tunnel_off", 0 );
	
	player = get_players()[0];
	if( isdefined( player ) )
	{
		player clientnotify( "flashlight_visionset_off" );
	}
	
	SetSavedDvar( "r_flashLightFlickerAmount", "0" );
	SetSavedDvar( "r_flashLightFlickerRate", "65" );
	SetSavedDvar( "r_flashLightBobAmount", "0 0 0" );
	SetSavedDvar( "r_flashLightBobRate", "0 0 0" );
	
	SetSavedDvar( "r_flashLightColor", "0.13 0.21 0.26" );


	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 0.2 );
	SetSavedDvar( "r_lightGridContrast", 0 );
}

change_art_settings_tunnel()
{
	level waittill( "tunnel_visionset_change" );
	//IPrintLnBold( "tunnel entrance?" );
	VisionSetNaked( "creek_1_tunnel_off", 0 );
	
	near_start = 0;
	near_end = 32;
	far_start = 100;
	far_end = 5260;
	near_blur = 4.8;
	far_blur = 2;
	player = GetPlayers()[0];	
	// A Liu: Remove the persistent DOF in tunnel to improve framerate
	//player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur);
	player maps\_art::setdefaultdepthoffield();
}

change_art_settings_2()
{

}

change_art_settings_3()
{

}


tunnel_war_room_light_settings()
{
	
	// set client vision
	player = get_players()[0];
	player clientNotify( "set_creek_warroom_visionset" );
	
	VisionSetNaked( "creek_1_war_room", 2 );
	
	// make characters brighter
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.5 );
	SetSavedDvar( "r_lightGridContrast", 0.4 );
	
	start_dist = 146.633;
	half_dist = 1716.28;
	half_height = 329.6;
	base_height = -110.689;
	fog_r = 0.584314;
	fog_g = 0.8;
	fog_b = 1;
	fog_scale = 1.9969;
	sun_col_r = 0.917647;
	sun_col_g = 1;
	sun_col_b = 1;
	sun_dir_x = -0.169175;
	sun_dir_y = -0.642666;
	sun_dir_z = 0.747235;
	sun_start_ang = 0;
	sun_stop_ang = 49.0202;
	time = 3;
	max_fog_opacity = 0.960193;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
}

tunnel_collapse_art()
{
	self endon("death");

	trig = GetEnt("tunnel_collapse_vision", "script_noteworthy");
	trig waittill("trigger");

	// update vision settings
	tunnel_collapse_vision_settings();
}

tunnel_light_end_art()
{
	self endon("death");

	trig = GetEnt("tunnel_light_end_vision", "script_noteworthy");
	trig waittill("trigger");

	// update vision settings
	tunnel_light_end_vision_settings();
}

tunnel_cliffhanger_art()
{
	self endon("death");

	trig = GetEnt("tunnel_cliffhanger_vision", "script_noteworthy");
	trig waittill("trigger");

	// update vision settings
	tunnel_cliffhanger_vision_settings();
}

tunnel_collapse_vision_settings()
{
	start_dist = 83.6521;
	half_dist = 111.522;
	half_height = 3422;
	base_height = -298;
	fog_r = 0.168627;
	fog_g = 0.129412;
	fog_b = 0.0941177;
	fog_scale = 1;
	sun_col_r = 0.858824;
	sun_col_g = 0.8;
	sun_col_b = 0.701961;
	sun_dir_x = -0.12;
	sun_dir_y = -0.61;
	sun_dir_z = 0.78;
	sun_start_ang = 0;
	sun_stop_ang = 98.2;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		
			VisionSetNaked( "creek_1_tunnel_collapse", 2 );
				//IPrintLnBold("collapse_visionset");
				
	// make characters brighter
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.25 );
	SetSavedDvar( "r_lightGridContrast", 0.25 );
}


tunnel_light_end_vision_settings()
{
	start_dist = 88.8813;
	half_dist = 1475.51;
	half_height = 667.283;
	base_height = -943.857;
	fog_r = 1;
	fog_g = 1;
	fog_b = 1;
	fog_scale = 1.9969;
	sun_col_r = 0.917647;
	sun_col_g = 1;
	sun_col_b = 1;
	sun_dir_x = -0.169175;
	sun_dir_y = -0.642666;
	sun_dir_z = 0.747235;
	sun_start_ang = 0;
	sun_stop_ang = 49.0202;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

		VisionSetNaked( "creek_1_tunnel_cave_light_end", 2 );
			//IPrintLnBold("cave light_visionset");
}

tunnel_cliffhanger_vision_settings()
{
		start_dist = 436.144;
	half_dist = 1260.55;
	half_height = 667.283;
	base_height = -943.857;
	fog_r = 0.407843;
	fog_g = 0.568627;
	fog_b = 0.717647;
	fog_scale = 1.70561;
	sun_col_r = 0.901961;
	sun_col_g = 1;
	sun_col_b = 1;
	sun_dir_x = 0.810073;
	sun_dir_y = 0.328559;
	sun_dir_z = -0.485624;
	sun_start_ang = 0;
	sun_stop_ang = 62.7037;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


		
		VisionSetNaked( "creek_1_tunnel_cliffhanger", 2 );
			//IPrintLnBold("cliffhanger_visionset");
			
	// make characters brighter
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.0 );
	SetSavedDvar( "r_lightGridContrast", 0.25 );
}

art_settings_for_tunnel_crawl()
{
	// tunnel crawl starts
	// TODO: Add art setting here for tunnel crawl
	
	// tunnel just completely filled up
	flag_wait( "cave_fill_complete" );	
	// TODO: Add art settings here
	
	// Depth of Field settings
	near_start = 13;
	near_end = 20;
	far_start = 1000;
	far_end = 7000;
	near_blur = 10;
	far_blur = 1.8;
	player = GetPlayers()[0];	
	player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur);
	
	// player just about to break the first rock
	flag_wait("rock_1_broken");
	
	// player just about to break the second rock
	flag_wait("rock_2_broken");
	
	// player just about to break the final rock
	flag_wait("rock_3_broken");

		SetSavedDvar( "r_lightTweakSunLight", 9 );
		//IPrintLnBold("rock3 broken");
	
	// player is now hanging on the cliff
	wait( 2 );
	// change this as needed
	
	// DOF set back to default
	player = GetPlayers()[0];	
 	player maps\_art::setdefaultdepthoffield();
}
