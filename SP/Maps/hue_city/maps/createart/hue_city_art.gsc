//_createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 
	//* Fog section * 

	setdvar("scr_fog_exp_halfplane", "3759.28");
	setdvar("scr_fog_exp_halfheight", "243.735");
	setdvar("scr_fog_nearplane", "601.593");
	setdvar("scr_fog_red", "0.806694");
	setdvar("scr_fog_green", "0.962521");
	setdvar("scr_fog_blue", "0.9624");
	setdvar("scr_fog_baseheight", "-475.268");
	
	/*
	///////color tweaked demo version
	start_dist = 0;
	half_dist = 250.277;
	half_height = 526.611;
	base_height = 7471.46;
	fog_r = 0.4353;
	fog_g = 0.345;
	fog_b = 0.29;
	fog_scale = 1;
	sun_col_r = 1;
	sun_col_g = 0.415686;
	sun_col_b = 0.235294;
	sun_dir_x = -0.560367;
	sun_dir_y = 0.732266;
	sun_dir_z = 0.387009;
	sun_start_ang = 0;
	sun_stop_ang = 50.1075;
	time = 0;
	max_fog_opacity = 1;
		VisionSetNaked( "hue_city", 0 );

*/

	
	level thread set_intro_fog();
	level thread set_macv_fog();
	level thread set_war_room_fog();
	level thread set_street_fog();
	level thread set_defend_fog();
	level thread set_rappel_dof();
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.4 );
	SetSavedDvar( "r_lightGridContrast", .25 );
}


set_intro_fog()
{
		level waittill("set_intro_fog");
		
	///////color tweaked demo version
	start_dist = 0;
	half_dist = 250.277;
	half_height = 526.611;
	base_height = 7471.46;
	fog_r = 0.4353;
	fog_g = 0.345;
	fog_b = 0.29;
	fog_scale = 1;
	sun_col_r = 1;
	sun_col_g = 0.415686;
	sun_col_b = 0.235294;
	sun_dir_x = -0.560367;
	sun_dir_y = 0.732266;
	sun_dir_z = 0.387009;
	sun_start_ang = 0;
	sun_stop_ang = 50.1075;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	VisionSetNaked( "hue_city", 0 );
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.0 );
	SetSavedDvar( "r_lightGridContrast", 0.0 );
}

set_macv_fog()
{
	level waittill("set_macv_fog");
	
start_dist = 141.943;
	half_dist = 446.285;
	half_height = 458.452;
	base_height = 7653.7;
	fog_r = 0.321569;
	fog_g = 0.266667;
	fog_b = 0.231373;
	fog_scale = 1;
	sun_col_r = 0.960784;
	sun_col_g = 0.364706;
	sun_col_b = 0;
	sun_dir_x = -0.560367;
	sun_dir_y = 0.732266;
	sun_dir_z = 0.387009;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 3;
	max_fog_opacity = 0.984345;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	VisionSetNaked( "macv_main", 0 );

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.4 );
	SetSavedDvar( "r_lightGridContrast", .25 );

}

set_street_fog()
{
	level waittill("set_street_fog");
	
	////////////////////////////////////blue
start_dist = 221.024;
	half_dist = 296.63;
	half_height = 350.797;
	base_height = 7526.19;
	fog_r = 0.223529;
	fog_g = 0.223529;
	fog_b = 0.223529;
	fog_scale = 1.1;
	sun_col_r = 0.764706;
	sun_col_g = 0.423529;
	sun_col_b = 0.305882;
	sun_dir_x = -0.560367;
	sun_dir_y = 0.732266;
	sun_dir_z = 0.387009;
	sun_start_ang = 0;
	sun_stop_ang = 17.9138;
	time = 0;
	max_fog_opacity = 0.956632;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


	VisionSetNaked( "hue_city_streets", 3 );

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.35 );
	SetSavedDvar( "r_lightGridContrast", 0.1 );

}

set_war_room_fog()
{
	level waittill("set_war_room_fog");
	
start_dist = 141.943;
	half_dist = 446.285;
	half_height = 458.452;
	base_height = 7653.7;
	fog_r = 0.321569;
	fog_g = 0.266667;
	fog_b = 0.231373;
	fog_scale = 1;
	sun_col_r = 0.00392157;
	sun_col_g = 0;
	sun_col_b = 0;
	sun_dir_x = 0;
	sun_dir_y = 0;
	sun_dir_z = 0;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 3;
	max_fog_opacity = 0.984345;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.4 );
	SetSavedDvar( "r_lightGridContrast", .25 );
}

set_defend_fog()
{
	level waittill("set_defend_fog");
		////////////////////////////////////blue
start_dist = 221.024;
	half_dist = 350.851;
	half_height = 229.963;
	base_height = 7526.19;
	fog_r = 0.223529;
	fog_g = 0.223529;
	fog_b = 0.223529;
	fog_scale = 1.1;
	sun_col_r = 0.764706;
	sun_col_g = 0.423529;
	sun_col_b = 0.305882;
	sun_dir_x = -0.560367;
	sun_dir_y = 0.732266;
	sun_dir_z = 0.387009;
	sun_start_ang = 0;
	sun_stop_ang = 47.05;
	time = 0;
	max_fog_opacity = 0.956632;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	VisionSetNaked( "hue_city_streets", 0 );

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.5 );
	SetSavedDvar( "r_lightGridContrast", 0.3 );

	SetCullDist(0);

}

set_rappel_dof()
{
	// notify happens when player is looking at woods in the helicopter
	level waittill("set_rappel_dof");
	level.player SetDepthOfField( 10, 60, 341, 2345, 6, 2.16 );

	// Not sure how to turn off the DOF...right now we are just waiting and setting back to some
	// default values. There is no script function for turning off dof. I only found examples of 
	// setting back to defaults
	wait(1);
	level.player SetDepthOfField(0, 1, 8000, 10000, 6, 0);
}