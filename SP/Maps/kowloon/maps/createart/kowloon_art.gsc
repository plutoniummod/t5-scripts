//_createart generated.  modify at your own risk. Changing values should be fine.
#include common_scripts\utility; 
#include maps\_utility;


//
//	DO NOT PUT ANY WAITS IN THIS FUNCTION
main()
{
//     flag_init( "all_players_connected" );
// 	
	level thread vision_sets();

	//level thread fog_updater(); 

	//shabs - moving this over to the server as we dont need it on the client
	//level thread start_lightning();
	
	///////////New Hero Lighting///////////////
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.7 );
	SetSavedDvar( "r_lightGridContrast", .3 );

}


vision_sets()
{
	wait_for_first_player();

	//shabs - need this wait here to have intro DOF working properly.
	wait( 2 );

	// Interrogation only settings
	e1_near_start	= 0;
	e1_near_end		= 1;
	e1_far_start	= 32;
	e1_far_end		= 57;
	e1_near_blur	= 4;
	e1_far_blur		= 1.5;
	player = get_players()[0];
	player SetDepthOfField( e1_near_start, e1_near_end, e1_far_start, e1_far_end, e1_near_blur, e1_far_blur );
	VisionSetNaked( "kowloon_level_start", 0.05 );

//setdvar( "r_finalShiftX ", "1.23 0.0 0.0" );
//SetDvar( "r_finalShiftX ", "1.23” “0.0” “0.0" );

	flag_wait( "event2" );

	wait( 2 );

	player maps\_art::setdefaultdepthoffield();
	VisionSetNaked( "kowloon", 2.0 );
	
		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.7 );
	SetSavedDvar( "r_lightGridContrast", .3 );

	//saving default DOF for the last scene
//	Default_Near_Start = 0;
//	Default_Near_End = 1;
//	Default_Far_Start = 8000;
//	Default_Far_End = 10000;
//	Default_Near_Blur = 6;
//	Default_Far_Blur = 0;
//
//	player SetDepthOfField( Default_Near_Start, Default_Near_End, Default_Far_Start, Default_Far_End, Default_Near_Blur, Default_Far_Blur );

	// Start event 2
//	player = get_players()[0];
//	int_near_start	= player GetDepthOfField_NearStart();
//	int_near_end	= player GetDepthOfField_NearEnd();
//	int_far_start	= player GetDepthOfField_FarStart();
//	int_far_end		= player GetDepthOfField_FarEnd();
//	int_near_blur	= player GetDepthOfField_NearBlur();
//	int_far_blur	= player GetDepthOfField_FarBlur();
//	player SetDepthOfField( int_near_start, int_near_end, int_far_start, int_far_end, int_near_blur, int_far_blur );

	vs_trigs = GetEntArray( "visionset", "targetname" );
	array_thread( vs_trigs, ::vision_set );
}

//fog_updater()
//{
//	wait_for_first_player();
//
//	// *Fog section* 
//	start_dist = 8.35587;
//	half_dist = 308.541;
//	half_height = 248.487;
//	base_height = 2723.84;
//	fog_r = 0.0666667;
//	fog_g = 0.101961;
//	fog_b = 0.113725;
//	fog_scale = 3.14083;
//	sun_col_r = 0.552941;
//	sun_col_g = 0.686275;
//	sun_col_b = 0.729412;
//	sun_dir_x = 0.163263;
//	sun_dir_y = -0.944148;
//	sun_dir_z = 0.286235;
//	sun_start_ang = 0;
//	sun_stop_ang = 99.2932;
//	time = 0;
//	max_fog_opacity = 0.866884;
//
//
//
//	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
//		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
//		sun_stop_ang, time, max_fog_opacity);
//
//	// Now wait for the player to spawn
//	wait_for_all_players();
//
//	// magic number to let the player spawn in and be at a real height.
//	// On MapRestart, the player's height can be at 0, which causes problems with the
//	//	offset calculations
//	wait( 1.0 );
//
//	player_start = GetStruct( "start_player_e2", "targetname" );
//	player_z = player_start.origin[2];
//	base_height_offset = base_height - player_z;
//
//	last_player_z = 0;
//	time = 0.5;
//	while (1)
//	{
//	 	player = get_players()[0];
//		player_z = player.origin[2];
//
//		if ( abs(player_z - last_player_z) > 32 )
//		{
//			base_height = player_z+base_height_offset;
//
//			setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
//				sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
//				sun_stop_ang, time, max_fog_opacity);
//
//			last_player_z = player_z;
//		}
//		wait(0.5);
//	}
//}


//	Sets the vision set when triggered
//
vision_set()
{
	AssertEx( IsDefined(self.script_noteworthy), "vision_set:: trigger needs to have a script_noteworthy for the vision set" );
	time = 2.0;
	if ( IsDefined( self.script_float ) )
	{
		time = self.script_float;
	}

	// Get default DOF Settings
	player = get_players()[0];
	int_near_start	= player GetDepthOfField_NearStart();
	int_near_end	= player GetDepthOfField_NearEnd();
	int_far_start	= player GetDepthOfField_FarStart();
	int_far_end		= player GetDepthOfField_FarEnd();
	int_near_blur	= player GetDepthOfField_NearBlur();
	int_far_blur	= player GetDepthOfField_FarBlur();

	ext_near_start	= 262;
	ext_near_end	= 47;
	ext_far_start	= 616;
	ext_far_end		= 4755;
	ext_near_blur	= 4;
	ext_far_blur	= 1.8;

	// Now wait for vision_set triggers
	while ( 1 )
	{
		self waittill( "trigger" );

	 	player = get_players()[0];
		if ( player GetVisionSetNaked() != self.script_noteworthy )
		{
			VisionSetNaked( self.script_noteworthy, time );

			if ( self.script_noteworthy == "kowloon" )
			{
				// Interiors
				//player SetDepthOfField( int_near_start, int_near_end, int_far_start, int_far_end, int_near_blur, int_far_blur );
			}
			else
			{
				// Exteriors
				//player SetDepthOfField( ext_near_start, ext_near_end, ext_far_start, ext_far_end, ext_near_blur, ext_far_blur );
			}
		}
	}
}


//setting the current states of lightning from off/roof/indoor
lightning_states()
{
	level.lightning_state = "off";

	level thread trigger_shadow_on_wall_lightning();
	level thread trigger_roof_lighting();
	level thread trigger_combat_roof_lighting();
	while(1)
	{
		level waittill("lightning_change");

		if(level.lightning_state == "off")
		{
			wait(0.05);
			continue;
		}
		else if(level.lightning_state == "indoor")
		{
			level thread start_lightning_indoor();
		}
		else if(level.lightning_state == "roof")
		{
			level thread start_lightning_roof();
		}
		else if(level.lightning_state == "combat_roof")
		{
			level thread start_lightning_combat_roof();
		}
	}
}

//start playing the roof lightning affect as well as change the sunlight direction
start_lightning_roof()
{
	level endon("lightning_change");
	while(1)
	{

		if( level.lightning_vision_set == 1 )
		{
			VisionSetNaked("kowloon_rooftop_lightning", 0);	
		}

		//SetSavedDvar( "r_lightTweakSunDirection", (-30, -71, 0) );
		//clientnotify("lightning");
		//level notify( "lightning");
		self thread trigger_lightning_exploder();
		self thread do_a_lightning_1();
		//wait(1.05);

		//change sunlight direction back to normal

		if( level.lightning_vision_set == 1 )
		{
			VisionSetNaked("kowloon_rooftop", 0);	
		}

		SetSavedDvar( "r_lightTweakSunDirection", (-30.5, -104,0) );
		wait( 4 + randomfloat(3) );	
	}
}

start_lightning_combat_roof()
{
	level endon("lightning_change");
	while(1)
	{
		//change sunlight direction to lightning
		//SetSavedDvar( "r_lightTweakSunDirection", (-61, 127, 0) );

		if( level.lightning_vision_set == 1 )
		{
			VisionSetNaked("kowloon_rooftop_lightning", 0);	
		}
		//clientnotify("lightning");
		//level notify( "lightning");
		self thread trigger_lightning_exploder();
		self thread do_a_lightning_1();
		//wait(1.05);

		if( level.lightning_vision_set == 1 )
		{
			VisionSetNaked("kowloon_rooftop", 0);	
		}
		//change sunlight direction back to normal
		SetSavedDvar( "r_lightTweakSunDirection", (-30.5, -104,0) );
		wait( 4 + randomfloat(3) );	
	}
}


//start playing the indoor lightning effect as well as change sunlight direction
start_lightning_indoor()
{
	level endon("lightning_change");

	while(1)
	{
		//change sunlight direction to lightning
		SetSavedDvar( "r_lightTweakSunDirection", (-19, -58, 0) );
		//clientnotify("lightning");
		//level notify( "lightning");
		self thread trigger_lightning_exploder();
		self thread do_a_lightning_1();
		//wait(1.15);
		//change sunlight direction back to normal
		SetSavedDvar( "r_lightTweakSunDirection", (-30.5, -104,0) );
		wait( 4 + randomfloat(3) );	
	}
}

//one quick burst to trigger to lightning to cast shadow on the stairwell.
trigger_shadow_on_wall_lightning()
{
	trigger_wait("lightning_shadow_on_wall");
	//change sun light direction to normal sunlight
	SetSavedDvar( "r_lightTweakSunDirection", (-30, -104, 0) );
//	iprintln("shadow_on_wall_lightning");
	level.lightning_state = "off";

	level thread turn_lightning_off();
	//change sunlight direction to lightning
	SetSavedDvar( "r_lightTweakSunDirection", (-14, -31, 0) );
	//clientnotify("lightning");
	//level notify( "lightning");
	self thread trigger_lightning_exploder();
	self thread do_a_lightning_1();
	//wait(2);
	//change sunlight direction back to normal
	SetSavedDvar( "r_lightTweakSunDirection", (-30, -104,0) );
}


//
//one quick burst to trigger to lightning
trigger_lightning()
{
	level endon("lightning_change");

	//change sun light direction to normal sunlight
	SetSavedDvar( "r_lightTweakSunDirection", (-30, -104, 0) );

	level.lightning_state = "off";

	//change sunlight direction to lightning
	SetSavedDvar( "r_lightTweakSunDirection", (-14, -31, 0) );
//	clientnotify("lightning");
	self thread trigger_lightning_exploder();
	self thread do_a_lightning_1();
	//wait(2);
	//change sunlight direction back to normal
	SetSavedDvar( "r_lightTweakSunDirection", (-30, -104,0) );
}


//start the roof lightning, able to change the sun light direction as well.
trigger_roof_lighting()
{

	trigger_wait("lightning_change_on_roof");
	//change sun light direction to normal sunlight
	//SetSavedDvar( "r_lightTweakSunDirection", (-14, -31, 0) );
//	SetSavedDvar( "sm_sunSampleSizeNear", "0.9" );
	//iprintln("roof_lightning");
	level thread turn_lightning_on_roof();

}

trigger_combat_roof_lighting()
{
	flag_wait("event4");
	level thread turn_lightning_on_combat_roof();
}


turn_lightning_on_indoor()
{
	wait( RandomFloat(1.0, 3.0) );
	//iprintln("indoor_lightning");
	level.lightning_state = "indoor";
//	SetSavedDvar( "sm_sunSampleSizeNear", "0.5" );
	level notify("lightning_change");
}

turn_lightning_on_roof()
{
	level.lightning_state = "roof";
	level notify("lightning_change");
}

turn_lightning_on_combat_roof()
{
	level.lightning_state = "combat_roof";
	level notify("lightning_change");
}

turn_lightning_off()
{
	level.lightning_state = "off";
	level notify("lightning_change");
}

trigger_lightning_exploder()
{
	level endon("lightning_change");

	exploder(7001);
	exploder(7002);
	exploder(7003);
	exploder(7004);
}

//start_lightning()
//{
//	while(1)
//	{
//		level waittill("lightning");
//		do_a_lightning_1();
//	}
//}


lightning_normal_func()
{
	level endon("lightning_change");
	//realWait( 0.05 );
	wait(0.05);
	ResetSunLight();
	//setVolFog( 0, 86, 32, fog_value, 0.860, 0.810, 0.316, .05 );
}

lightning_flash_func()
{
	level endon("lightning_change");
	
	//SetSunLight( sun_value_below_water_r, sun_value_below_water_g, sun_value_below_water_b );

	SetSunLight( 1, 1, 1.5 ); 
	wait(0.05);
	//realWait( 0.014 );              
	SetSunLight( 1.5, 1.5, 2 );
	wait(0.05);
	//realWait( 0.0010 ); 
	SetSunLight( 5, 5, 5.5 );
	wait(0.05);
	//realWait( 0.0011 ); 
	SetSunLight( 1, 1, 1.5 );
	wait(0.05);
	//realWait( 0.0015 ); 
	SetSunLight( 2.5, 2.5, 3 ); 
	wait(0.05);
	//realWait(0.0010);
}

do_a_lightning_1()
{

	//setVolFog( 0, 86, 32, fog_value, 0.860, 0.810, 0.316, .0.5 );
	
	//SOUND - Shawn J * NOTE - this needs to be at the top of this function or the sound is too late!
	PlaySoundAtPosition ("amb_thunder_clap", (-1912, -1786, 4911) );

	lightning_flash_func();
	lightning_flash_func();
	wait(0.05);
	lightning_flash_func();
	lightning_flash_func();
	lightning_flash_func();
	wait(0.1);
	lightning_flash_func();
	lightning_normal_func();
}