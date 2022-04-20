//_createart generated.  modify at your own risk. Changing values should be fine.

main()
{
	start_dist = 4419.25;
	half_dist = 2369.63;
	half_height = 319.682;
	base_height = 637.217;
	fog_r = 0.890196;
	fog_g = 0.905882;
	fog_b = 0.905882;
	fog_scale = 3.3393;
	sun_col_r = 0.45098;
	sun_col_g = 0.47451;
	sun_col_b = 0.631373;
	sun_dir_x = -0.0852991;
	sun_dir_y = 0.969857;
	sun_dir_z = 0.228259;
	sun_start_ang = 17.1683;
	sun_stop_ang = 78.4212;
	time = 0;
	max_fog_opacity = 0.743441;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
	sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
	sun_stop_ang, time, max_fog_opacity);


	VisionSetNaked( "mp_munich2", 0 );
	SetDvar( "r_lightGridEnableTweaks", 1 );
	SetDvar( "r_lightGridIntensity", 1.35 );
	SetDvar( "r_lightGridContrast", 0.35 );
}
