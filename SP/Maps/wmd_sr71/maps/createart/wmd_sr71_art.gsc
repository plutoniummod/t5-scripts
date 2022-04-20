#include maps\wmd_sr71_util;

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
	level thread reset_fog();
	level thread set_rts_fog();
	level thread set_rts_fps_fog();
	level thread set_first_fps_dof();
}

set_default_dof()
{
	player = GetEnt( "player", "classname" );
	player maps\_art::setdefaultdepthoffield();
}

set_runway_cam_cuts_dof()
{
	player = GetEnt( "player", "classname" );
	player SetDepthOfField( 1, 500, 1000, 7000, 6, 0 );
	//player SetDepthOfField(near_start, near_end,far_start, far_end,near_blur,far_blur);
	
	
	//////////////////////////////////////////////
		start_dist = 60;
	half_dist = 250;
	half_height = 1240;
	base_height =  39818;
	fog_r = 0;
	fog_g = 0;
	fog_b = 1;
	fog_col_scale = 5.56;
	sun_col_r = 1.0;
	sun_col_g = 0.757;
	sun_col_b = 0.604;
	sun_dir_x = -0.27;
	sun_dir_y = 0.93;
	sun_dir_z = 0.23;
	sun_start_ang = 0;
	sun_stop_ang = 64.7;
	time = 2;
	max_fog_opacity = 0.5;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_col_scale,
						sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
						sun_stop_ang, time, max_fog_opacity);		
	
}

set_runway_dof()
{
	level waittill( "set_runway_dof" );
	player = GetEnt( "player", "classname" );
	
	//player SetDepthOfField( 10, 15.93, 2859.25, 20000, 6, 1.4 );
	player SetDepthOfField( 0, 20, 2859.25, 20000, 4, 0 );
		//player SetDepthOfField(near_start, near_end,far_start, far_end,near_blur,far_blur);
}

set_first_fps_dof()
{
	level waittill("set_first_fps_dof");
	player = GetEnt("player", "classname");
	
	// Inside the interiors on the fps ground areas
	near_blur = 6;
	far_blur = 1.8;
 	//viewmodel start 2.3
	//viewmodel end 17
	near_start = 0;
	near_end = 16.5;
	far_start = 190;
	far_end = 510;
	
	
	player SetDepthOfField(near_start, near_end,far_start, far_end,near_blur,far_blur);
	
	level waittill("reset_dof");
	
	player thread lerp_dof_over_time(level.dofDefault["nearStart"], level.dofDefault["nearEnd"], level.dofDefault["farStart"], level.dofDefault["farEnd"], level.dofDefault["nearBlur"], level.dofDefault["farBlur"], 1.0);

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
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.25 );
	SetSavedDvar( "r_lightGridContrast", 0.1 );
	
}


set_rts_fog()
{
	while(1)
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
	sun_col_g = 0.12549;
	sun_col_b = 0.12549;
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

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 0.4);
	SetSavedDvar( "r_lightGridContrast", -0.25 );
	
	
	}
}

set_rts_fps_fog()
{
	while(1)
	{
		level waittill("set_rts_fps_fog");
		
		start_dist = 198.546;
	half_dist = 266.203;
	half_height = 11270.6;
	base_height = -36.3231;
	fog_r = 0.176471;
	fog_g = 0.223529;
	fog_b = 0.243137;
	fog_scale = 3.30445;
	sun_col_r = 0.380392;
	sun_col_g = 0.498039;
	sun_col_b = 0.556863;
	sun_dir_x = -0.446301;
	sun_dir_y = 0.810017;
	sun_dir_z = 0.380379;
	sun_start_ang = 0;
	sun_stop_ang = 180;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.25 );
	SetSavedDvar( "r_lightGridContrast", 0.15 );
	
	}


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
	
	start_dist = 60;
	half_dist = 290;
	half_height = 1240;
	base_height =  39818;
	fog_r = 0.333;
	fog_g = 0.349;
	fog_b = 0.329;
	fog_col_scale = 5.56;
	sun_col_r = 1.0;
	sun_col_g = 0.757;
	sun_col_b = 0.604;
	sun_dir_x = -0.27;
	sun_dir_y = 0.93;
	sun_dir_z = 0.23;
	sun_start_ang = 0;
	sun_stop_ang = 64.7;
	time = 0;
	max_fog_opacity = 0.5;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_col_scale,
						sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
						sun_stop_ang, time, max_fog_opacity);		
						
	//VisionSetNaked( "wmd", 0 );
	
}

set_relay_station_fog()
{

	level waittill("set_relay_station_fog");
		
	start_dist = 60;
	half_dist = 2500;
	half_height = 1240;
	base_height =  39818;
	fog_r = 0.333;
	fog_g = 0.349;
	fog_b = 0.329;
	fog_col_scale = 5.56;
	sun_col_r = 1.0;
	sun_col_g = 0.757;
	sun_col_b = 0.604;
	sun_dir_x = -0.27;
	sun_dir_y = 0.93;
	sun_dir_z = 0.23;
	sun_start_ang = 0;
	sun_stop_ang = 64.7;
	time = 2;
	max_fog_opacity = 0.5;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_col_scale,
						sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
						sun_stop_ang, time, max_fog_opacity);		
	//VisionSetNaked( "wmd", 0 );
	
}

reset_fog()
{

	level waittill("relay_station_cleared");	
	
	start_dist = 60;
	half_dist = 290;
	half_height = 1240;
	base_height =  33389;
	fog_r = 0.333;
	fog_g = 0.349;
	fog_b = 0.329;
	fog_col_scale = 5.56;
	sun_col_r = 1.0;
	sun_col_g = 0.757;
	sun_col_b = 0.604;
	sun_dir_x = -0.27;
	sun_dir_y = 0.93;
	sun_dir_z = 0.23;
	sun_start_ang = 0;
	sun_stop_ang = 64.7;
	time = 0;
	max_fog_opacity = 0.5;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_col_scale,
						sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
						sun_stop_ang, time, max_fog_opacity);		
	//VisionSetNaked( "wmd", 0 );
	
}
