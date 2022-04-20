//_createart generated.  modify at your own risk. Changing values should be fine.

main()
{
      start_dist = 650.36;
	half_dist = 4251.88;
	half_height = 1205.66;
	base_height = 413.257;
	fog_r = 1;
	fog_g = 1;
	fog_b = 1;
	fog_scale = 3.25;
	sun_col_r = 0.552941;
	sun_col_g = 0.466667;
	sun_col_b = 0.34902;
	sun_dir_x = 0.909043;
	sun_dir_y = -0.385585;
	sun_dir_z = 0.158006;
	sun_start_ang = 16.3625;
	sun_stop_ang = 25.6469;
	time = 0;
	max_fog_opacity = 0.5;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


  VisionSetNaked( "mp_berlinwall2", 0 );
	SetDvar( "r_lightGridEnableTweaks", 1 );
	SetDvar( "r_lightGridIntensity", 1.89 );
	SetDvar( "r_lightGridContrast", 0.38 );
}