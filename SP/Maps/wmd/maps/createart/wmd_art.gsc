//_createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 
	//* Fog section * 

	setdvar("scr_fog_exp_halfplane", "2600.0");
	setdvar("scr_fog_exp_halfheight", "6000.0");
	setdvar("scr_fog_nearplane", "1500.0");
	setdvar("scr_fog_red", "0.32");
	setdvar("scr_fog_green", "0.31");
	setdvar("scr_fog_blue", "0.28");
	setdvar("scr_fog_baseheight", "39817.9");
	
	start_dist = 6000;
	halfway_dist = 6000;
	halfway_height = 300;
	base_height = 0;
	red = 1;
	green = 1;
	blue = 1;
	trans_time = 0;
	
	//setVolFog(	start_dist, halfway_dist, halfway_height, base_height, red, green, blue, trans_time );
	VisionSetNaked( "wmd", 0 );
	
	///////////New Hero Lighting///////////////
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.25 );
	SetSavedDvar( "r_lightGridContrast", .45 );
	
	level thread set_runway_fog();
	level thread set_runway_dof();
	level thread set_inflight_fog();	
	level thread set_curvature_fog();
	level thread set_ambush_fog();
	level thread set_relay_station_fog();
	level thread set_radar_station_fog();
	level thread set_ledge_fog();
}

set_default_dof()
{
	player = GetEnt( "player", "classname" );
	player maps\_art::setdefaultdepthoffield();
}

set_runway_cam_cuts_dof()
{
	player = GetEnt( "player", "classname" );
	player SetDepthOfField( 0, 200, 1000, 7000, 10, 2 );
}

set_runway_dof()
{
	level waittill( "set_runway_dof" );
	player = GetEnt( "player", "classname" );
	
	//player SetDepthOfField( 10, 15.93, 2859.25, 20000, 6, 1.4 );
	player SetDepthOfField( 0, 500, 2859.25, 20000, 4, 1.4 );
}

set_runway_fog()
{
	level waittill("set_runway_fog");
	
	
	start_dist = 1032.78;
	half_dist = 1274.12;
	half_height = 439.084;
	base_height = -44669.4;
	fog_r = 0.482353;
	fog_g = 0.454902;
	fog_b = 0.498039;
	fog_scale = 3.02027;
	sun_col_r = 0.701961;
	sun_col_g = 0.54902;
	sun_col_b = 0.392157;
	sun_dir_x = -0.2;
	sun_dir_y = 0.95;
	sun_dir_z = 0.24;
	sun_start_ang = 0;
	sun_stop_ang = 50.7848;
	time = 0;
	max_fog_opacity = 0.94;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

		

	//VisionSetNaked( "wmd", 0 );
	
}


set_rts_fog()
{
	level waittill("set_rts_fog");
	
	start_dist = 0;
	half_dist = 1059;
	half_height = 1010.86;
	base_height = -1.97569;
	fog_r = 1;
	fog_g = 0.996078;
	fog_b = 1;
	fog_scale = 10;
	sun_col_r = 0.12549;
	sun_col_g = 0;
	sun_col_b = 0;
	sun_dir_x = 0.572559;
	sun_dir_y = 0.317478;
	sun_dir_z = 0.755899;
	sun_start_ang = 123.074;
	sun_stop_ang = 180;
	time = 0;
	max_fog_opacity = 0.48;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

}


set_curvature_fog()
{
	level waittill("set_curvature_fog");
	
	start_dist = 3412.54;
	half_dist = 8245.25;
	half_height = 4380.65;
	base_height =  9539;
	fog_r = 1.0;
	fog_g = 1.0;
	fog_b = 0.944;
	fog_col_scale = 1;
	sun_col_r = 0;
	sun_col_g = 0;
	sun_col_b = 0;
	sun_dir_x = 0;
	sun_dir_y = 0;
	sun_dir_z = 0;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_col_scale,
						sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
						sun_stop_ang, time, max_fog_opacity);		
						
	//VisionSetNaked( "wmd", 0 );
	
}


set_inflight_fog()
{
	level waittill("set_inflight_fog");
	
	start_dist = 60;
	half_dist = 600;
	half_height = 300;
	base_height =  20000;
	fog_r = 1.0;
	fog_g = 1.0;
	fog_b = 1.0;
	fog_col_scale = 1;
	sun_col_r = 0;
	sun_col_g = 0;
	sun_col_b = 0;
	sun_dir_x = 0;
	sun_dir_y = 0;
	sun_dir_z = 0;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_col_scale,
						sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
						sun_stop_ang, time, max_fog_opacity);		
						
	//VisionSetNaked( "wmd", 0 );

}



set_ambush_fog()
{
	level waittill("set_ambush_fog");
	
start_dist = 117.672;
	half_dist = 290;
	half_height = 1240;
	base_height = 39818;
	fog_r = 0.333333;
	fog_g = 0.34902;
	fog_b = 0.329412;
	fog_scale = 5.56;
	sun_col_r = 0.733333;
	sun_col_g = 0.647059;
	sun_col_b = 0.521569;
	sun_dir_x = -0.27;
	sun_dir_y = 0.93;
	sun_dir_z = 0.23;
	sun_start_ang = 0;
	sun_stop_ang = 64.7;
	time = 0;
	max_fog_opacity = 0.5;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.35 );
	SetSavedDvar( "r_lightGridContrast", .25 );
						
	//VisionSetNaked( "wmd", 0 );
	
}

set_relay_station_fog()
{

	level waittill("set_relay_station_fog");
	
	start_dist = 60;
	half_dist = 290;
	half_height = 1508.68;
	base_height = 33389;
	fog_r = 0.333333;
	fog_g = 0.345098;
	fog_b = 0.333333;
	fog_scale = 5.56;
	sun_col_r = 1;
	sun_col_g = 0.756863;
	sun_col_b = 0.603922;
	sun_dir_x = -0.27;
	sun_dir_y = 0.93;
	sun_dir_z = 0.23;
	sun_start_ang = 0;
	sun_stop_ang = 64.7;
	time = 2;
	max_fog_opacity = 0.747905;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.35 );
	SetSavedDvar( "r_lightGridContrast", .1 );
	
	//VisionSetNaked( "wmd", 0 );
	
}

set_radar_station_fog()
{

	level waittill("set_radar_station_fog");	
	
	start_dist = 60;
	half_dist = 290;
	half_height = 1508.68;
	base_height = 33389;
	fog_r = 0.333333;
	fog_g = 0.345098;
	fog_b = 0.333333;
	fog_scale = 5.56;
	sun_col_r = 1;
	sun_col_g = 0.756863;
	sun_col_b = 0.603922;
	sun_dir_x = -0.27;
	sun_dir_y = 0.93;
	sun_dir_z = 0.23;
	sun_start_ang = 0;
	sun_stop_ang = 64.7;
	time = 2;
	max_fog_opacity = 0.747905;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.35 );
	SetSavedDvar( "r_lightGridContrast", 0.15 );
	
	//VisionSetNaked( "wmd", 0 );
	
}

set_ledge_fog()

{

	level waittill("set_ledge_fog");	
	
	start_dist = 60;
	half_dist = 290;
	half_height = 1240;
	base_height =  31546;
	fog_r = 0.333;
	fog_g = 0.349;
	fog_b = 0.329;
	fog_col_scale = 10;
	sun_col_r = 1.0;
	sun_col_g = 0.757;
	sun_col_b = 0.604;
	sun_dir_x = -0.27;
	sun_dir_y = 0.93;
	sun_dir_z = 0.23;
	sun_start_ang = 0;
	sun_stop_ang = 64.7;
	time = 5;
	max_fog_opacity = 0.95;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_col_scale,
						sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
						sun_stop_ang, time, max_fog_opacity);		


	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.35 );
	SetSavedDvar( "r_lightGridContrast", .15 );
	
}