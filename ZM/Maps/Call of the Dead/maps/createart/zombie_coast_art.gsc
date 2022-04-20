
////////////////////////////////////////////////// BOOT UP SETTINGS /////////////////////////////////////////////////

main()
{


	level.tweakfile = true;
	
	// Threads for Fog Settings

	//level thread fog_settings();
	
	// Threads for Visionset triggers
	

	
////////////////////////////////////////////////// Hero Lighting /////////////////////////////////////////////////
	
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.7 );
	SetSavedDvar( "r_lightGridContrast", .2 );
	
}

////////////////////////////////////////////////// FOG SETTINGS /////////////////////////////////////////////////

fog_settings()
{

	     	start_dist =80;
	      half_dist = 200;
	      half_height = 700.242;
	      base_height = 976.119;
				fog_r = 0.137255;
				fog_g = 0.192157;
				fog_b = 0.239216;
				fog_scale = 4.75161;
				sun_col_r = 0.760784;
				sun_col_g = 0.796079;
				sun_col_b = 0.807843;
				sun_dir_x = -0.862899;
				sun_dir_y = 0.264579;
				sun_dir_z = 0.430586;
				sun_start_ang = 0;
				sun_stop_ang = 120;
				time = 10;
				max_fog_opacity = 0.97;		
																		
														
														
	if( IsSplitScreen() )
	{
		  	start_dist =80;
	      half_dist = 200;
	      half_height = 700.242;
	      base_height = 976.119;
				fog_r = 0.137255;
				fog_g = 0.192157;
				fog_b = 0.239216;
				fog_scale = 4.75161;
				sun_col_r = 0.760784;
				sun_col_g = 0.796079;
				sun_col_b = 0.807843;
				sun_dir_x = -0.862899;
				sun_dir_y = 0.264579;
				sun_dir_z = 0.430586;
				sun_start_ang = 0;
				sun_stop_ang = 120;
				time = 10;
				max_fog_opacity = 0.97;	
				
		maps\_utility::set_splitscreen_fog( start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, time);
	}
	else
	{
		setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		
		
	}
}


////////////////////////////////////////////////// VISIONSET TRIGGERS /////////////////////////////////////////////////	




	
////////////////////////////////////////////////// VISIONSET SETTINGS /////////////////////////////////////////////////	
	


