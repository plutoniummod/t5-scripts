//_createart generated.  modify at your own risk. Changing values should be fine.

main()
{
 start_dist = 377.498;
	half_dist = 3945.08;
	half_height = 1537.12;
	base_height = 67.6952;
	fog_r = 0.788235;
	fog_g = 0.792157;
	fog_b = 0.65098;
	fog_scale = 4.48803;
	sun_col_r = 1;
	sun_col_g = 0.960784;
	sun_col_b = 0.882353;
	sun_dir_x = -0.246105;
	sun_dir_y = 0.932771;
	sun_dir_z = 0.263385;
	sun_start_ang = 0;
	sun_stop_ang = 63.3448;
	time = 0;
	max_fog_opacity = 0.803505;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);













SetDvar("r_skyColorTemp", (5700));
	SetDvar( "r_lightGridEnableTweaks", 1 );
	SetDvar( "r_lightGridIntensity", 1.45 );
	SetDvar( "r_lightGridContrast", .15 );

 
            //VisionSetNaked( "mp_outskirts", 0 );
}