//_createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 
	//* Fog section * 

	setdvar("scr_fog_exp_halfplane", "4880");
	setdvar("scr_fog_exp_halfheight", "1807");
	setdvar("scr_fog_nearplane", "3112");
	setdvar("scr_fog_red", "0.603922");
	setdvar("scr_fog_green", "0.0431373");
	setdvar("scr_fog_blue", "0.0745098");
	setdvar("scr_fog_baseheight", "-443");

	
	start_dist = 3112;
	half_dist = 4880;
	half_height = 1807;
	base_height = -443;
	fog_r = 0.00784314;
	fog_g = 0.0431373;
	fog_b = 0.0745098;
	fog_scale = 8.15426;
	sun_col_r = 0.603922;
	sun_col_g = 0.403922;
	sun_col_b = 0.211765;
	sun_dir_x = 0.45522;
	sun_dir_y = 0.890105;
	sun_dir_z = 0.0220971;
	sun_start_ang = 0;
	sun_stop_ang = 35.3893;
	time = 0;
	max_fog_opacity = 0.803556;


	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	VisionSetNaked( "pentagon", 0 );
	
			SetSavedDvar( "r_skyColorTemp", 5000.0 );

	///////////New Hero Lighting///////////////
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1 );
	SetSavedDvar( "r_lightGridContrast", 0 );
}
