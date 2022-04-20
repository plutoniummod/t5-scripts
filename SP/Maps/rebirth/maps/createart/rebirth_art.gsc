//_createart generated.  modify at your own risk. Changing values should be fine.
main()
{
 
	// *Fog section* 

start_dist = 423.417;
      half_dist = 2453.56;
      half_height = 1169.27;
      base_height = -1950.22;
      fog_r = 0.435294;
      fog_g = 0.431373;
      fog_b = 1;
      fog_scale = 10;
      sun_col_r = 0.843137;
      sun_col_g = 0.611765;
      sun_col_b = 1;
      sun_dir_x = -0.900619;
      sun_dir_y = -0.431677;
      sun_dir_z = -0.0503976;
      sun_start_ang = 0;
      sun_stop_ang = 61.3263;
      time = 0;
      max_fog_opacity = 0.659332;
 
	VisionSetNaked( "rebirth", 0 );
	
	///////////New Hero Lighting///////////////
		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.75 );
	SetSavedDvar( "r_lightGridContrast", .35 );   
	
	level thread roof_trigger();
	// level thread lab_trigger();
}


// DOF FOR LEVEL OPENING
dof_opening()
{

	near_start = 10;
	near_end = 55;
	far_start = 1000;
	far_end = 7000;
	near_blur = 4;
	far_blur = 0.17;
	player = GetPlayers()[0];	
	player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur);
}

dof_reset()
{
	near_start = 50;
	near_end = 40;
	far_start = 8000;
	far_end = 7000;
	near_blur = 4;
	far_blur = 0.17;
	player = GetPlayers()[0];	
	player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur);
}

// DOF FOR STEINERS OFFICE
dof_steiner_office_1()
{
	near_start = 205;
	near_end = 200;
	far_start = 335;
	far_end = 790;
	near_blur = 4;
	far_blur = 9.5;
	r_dof_viewModelStart = 2;
	r_dof_viewModelEnd = 10;
	player = GetPlayers()[0];	
	//player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur, r_dof_viewModelStart, r_dof_viewModelEnd );
	player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur );
}

dof_steiner_office_2()
{
	near_start = 860.8;
	near_end = 0;
	far_start = 0;
	far_end = 166.693;
	near_blur = 4;
	far_blur = 3;
	r_dof_viewModelStart = 2;
	r_dof_viewModelEnd = 8;
	player = GetPlayers()[0];	
	//player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur, r_dof_viewModelStart, r_dof_viewModelEnd );
	player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur );
}

dof_steiner_office()
{
	near_start_1 = 10;
	near_end_1 = 55;
	far_start_1 = 1000;
	far_end_1 = 7000;
	near_blur_1 = 4;
	far_blur_1 = 0.17;
	r_dof_viewModelStart_1 = 2;
	r_dof_viewModelEnd_1 = 10;
	
	near_start_2 = 860.8;
	near_end_2 = 0;
	far_start_2 = 0;
	far_end_2 = 166.693;
	near_blur_2 = 4;
	far_blur_2 = 4.5;
	r_dof_viewModelStart_2 = 2;
	r_dof_viewModelEnd_2 = 8;
	
	num_of_seconds = 19;
	player = GetPlayers()[0];	
		
	for(i = 0; i <= num_of_seconds; i++)
	{
		t = i / num_of_seconds;
		
		near_start = (1 - t) * near_start_1 + t * near_start_2;
		near_end = (1 - t) * near_end_1 + t * near_end_2;
		far_start = (1 - t) * far_start_1 + t * far_start_2;
		far_end = (1 - t) * far_end_1 + t * far_end_2;
		near_blur = (1 - t) * near_blur_1 + t * near_blur_2;
		far_blur = (1 - t) * far_blur_1 + t * far_blur_2;
		r_dof_viewModelStart = (1 - t) * r_dof_viewModelStart_1 + t * r_dof_viewModelStart_2;
		r_dof_viewModelEnd = (1 - t) * r_dof_viewModelEnd_1 + t * r_dof_viewModelEnd_2;
		
		player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur );
		
		wait(1.0);
	}
}

roof_trigger()
{
	trig = GetEnt("docks_fog_stairs", "script_noteworthy");
	trig waittill("trigger");
	rooftop_fog();
}


lab_trigger()
{
	trig = GetEnt("lab_interior", "script_noteworthy");
	trig waittill("trigger");
	lower_lab_area_fog();
}

start_crate_lowered_fog()
{
	start_dist = 206.943;
half_dist = 3167.22;
  half_height = 908.805;
  base_height = -399.995;
  fog_r = 0.635294;
  fog_g = 0.584314;
  fog_b = 0.352941;
  fog_scale = 2.13132;
  sun_col_r = 0.843137;
  sun_col_g = 0.611765;
  sun_col_b = 0.196078;
  sun_dir_x = 0.958623;
  sun_dir_y = -0.269662;
  sun_dir_z = -0.0912419;
  sun_start_ang = 0;
  sun_stop_ang = 44.8296;
  time = 0;
  max_fog_opacity = 0.659332;
  
	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.25 );
	SetSavedDvar( "r_lightGridContrast", .45 );
}


// ROOFTOP
rooftop_fog()
{

start_dist = 0;
	half_dist = 3870.82;
	half_height = 1169.27;
	base_height = 651.969;
	fog_r = 0.435294;
	fog_g = 0.431373;
	fog_b = 0.439216;
	fog_scale = 3.06873;
	sun_col_r = 0.843137;
	sun_col_g = 0.611765;
	sun_col_b = 0.196078;
	sun_dir_x = 0.958623;
	sun_dir_y = -0.269662;
	sun_dir_z = -0.0912419;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 1;
	max_fog_opacity = 1;


	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	SetSunLight(0.38, 0.795, 0.932);

}


// LAB AREA
lower_lab_area_fog()
{

start_dist = 525.144;
	half_dist = 883.471;
	half_height = 0;
	base_height = -265.921;
	fog_r = 0.27451;
	fog_g = 0.431373;
	fog_b = 0.501961;
	fog_scale = 1.325;
	sun_col_r = 0.529412;
	sun_col_g = 0.741176;
	sun_col_b = 0.968628;
	sun_dir_x = 0.18;
	sun_dir_y = 0.92;
	sun_dir_z = 0.33;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 0;
	max_fog_opacity = 0.8;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	VisionSetNaked( "rebirth_lab_interior", 5 );
	
		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.2 );
	SetSavedDvar( "r_lightGridContrast", 0.0 );
}

// BTR RAIL
btr_rail_fog()
{
	
start_dist = 384.017;
	half_dist = 297.013;
	half_height = 258.721;
	base_height = 465.005;
	fog_r = 0.2588;
	fog_g = 0.321569;
	fog_b = 0.286275;
	fog_scale = 1.9375;
	sun_col_r = 0.482353;
	sun_col_g = 0.647059;
	sun_col_b = 0.6;
	sun_dir_x = 0.561746;
	sun_dir_y = -0.257472;
	sun_dir_z = -0.786225;
	sun_start_ang = 0;
	sun_stop_ang = 86.3121;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

        
   ///////////Setting Sunlight for back half of map//////////////
   SetSavedDvar( "r_lightTweakSunLight", 4 );
   
   SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.5 );
	SetSavedDvar( "r_lightGridContrast", .25 );
	
	SetSavedDvar( "r_skyTransition", 1 );
	SetSavedDvar( "r_skyColorTemp", (5900)); 
	SetSunLight(0.38, 0.795, 0.932);


	
}

// GAS ATTACK
gas_attack_enter_fog(trans_time)
{
	start_dist = 0;
	half_dist = 58.7525;
	half_height = 63.7105;
	base_height = 593.111;
	fog_r = 0.529412;
	fog_g = 0.454902;
	fog_b = 0.203922;
	fog_scale = 2.02834;
	sun_col_r = 1;
	sun_col_g = 0.407843;
	sun_col_b = 0.27451;
	sun_dir_x = 0.304335;
	sun_dir_y = 0.15607;
	sun_dir_z = -0.939693;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = trans_time;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


	VisionSetNaked( "rebirth_gas_attack", trans_time );
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.6 );
	SetSavedDvar( "r_lightGridContrast", .05 );
	SetSunLight(0.9, 0.57, 0.3);

	SetSavedDvar( "r_skyTransition", 1 );

}

gas_attack_exit_fog(trans_time)
{
	/*
		start_dist = 0;
	half_dist = 258.7525;
	half_height = 63.7105;
	base_height = 593.111;
	fog_r = 0.529412;
	fog_g = 0.454902;
	fog_b = 0.203922;
	fog_scale = 2.02834;
	sun_col_r = 1;
	sun_col_g = 0.407843;
	sun_col_b = 0.27451;
	sun_dir_x = 0.304335;
	sun_dir_y = 0.15607;
	sun_dir_z = -0.939693;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = trans_time;
	max_fog_opacity = 0.6;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
*/
start_dist = 154.825;
	half_dist = 947.663;
	half_height = 397.967;
	base_height = 31.8212;
	fog_r = 0.262745;
	fog_g = 0.345098;
	fog_b = 0.282353;
	fog_scale = 1.39892;
	sun_col_r = 0.788235;
	sun_col_g = 0.298039;
	sun_col_b = 0.0705882;
	sun_dir_x = 0.868379;
	sun_dir_y = -0.335118;
	sun_dir_z = -0.365534;
	sun_start_ang = 12;
	sun_stop_ang = 100.813;
	time = trans_time;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

 
	VisionSetNaked( "rebirth", trans_time );
	SetSavedDvar( "r_skyTransition", 1 );
	SetSavedDvar( "r_skyTransition", 1 );
	SetSavedDvar( "r_skyColorTemp", (5900)); 
	SetSunLight(0.38, 0.795, 0.932);

}

lab_exterior_fog(trans_time)
{
	start_dist = 154.825;
	half_dist = 947.663;
	half_height = 397.967;
	base_height = 31.8212;
	fog_r = 0.262745;
	fog_g = 0.345098;
	fog_b = 0.282353;
	fog_scale = 1.39892;
	sun_col_r = 0.788235;
	sun_col_g = 0.298039;
	sun_col_b = 0.0705882;
	sun_dir_x = 0.868379;
	sun_dir_y = -0.335118;
	sun_dir_z = -0.365534;
	sun_start_ang = 12;
	sun_stop_ang = 100.813;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

		
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.5 );
	SetSavedDvar( "r_lightGridContrast", .45 );
	SetSavedDvar( "r_skyTransition", 1 );
	SetSavedDvar( "r_skyTransition", 1 );
	SetSavedDvar( "r_skyColorTemp", (5900)); 
	SetSunLight(0.38, 0.795, 0.932);


}