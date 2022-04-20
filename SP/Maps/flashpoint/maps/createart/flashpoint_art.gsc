#include maps\_utility;
#include common_scripts\utility; 
//_createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 
	////////setting new hero lighting////////////
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.15 );
	SetSavedDvar( "r_lightGridContrast", 0.1 );
	
	//* Fog section * 

	setdvar("scr_fog_exp_halfplane", "3759.28");
	setdvar("scr_fog_exp_halfheight", "243.735");
	setdvar("scr_fog_nearplane", "601.593");
	setdvar("scr_fog_red", "0.806694");
	setdvar("scr_fog_green", "0.962521");
	setdvar("scr_fog_blue", "0.9624");
	setdvar("scr_fog_baseheight", "-475.268");
	
	
start_dist = 69.3651;
	half_dist = 263.497;
	half_height = 315.672;
	base_height = -457;
	fog_r = 0.113725;
	fog_g = 0.172549;
	fog_b = 0.164706;
	fog_scale = 4.89644;
	sun_col_r = 1;
	sun_col_g = 0.54902;
	sun_col_b = 0.180392;
	sun_dir_x = -0.415321;
	sun_dir_y = 0.886763;
	sun_dir_z = 0.202878;
	sun_start_ang = 0;
	sun_stop_ang = 83;
	time = 0;
	max_fog_opacity = 0.691749;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


	VisionSetNaked( "flashpoint", 0 );
	//SetSunLight(0.9336, 0.778, 0.508);

	level thread set_default_fog();
	level thread set_commsbuildingroof_fog();
	level thread set_weaverbuilding_fog();
	level thread set_tunnels_gas_on_fog();
	level thread set_tunnels_gas_off_fog();
	level thread tunnel_vision();
	
	level thread slide_6_dof();
	level thread slide_1_dof();
	level thread slide_2_dof();
	level thread slide_4_dof();
	
}

set_default_fog()
{
	level waittill("set_default_fog");
	
	start_dist = 69.3651;
	half_dist = 263.497;
	half_height = 315.672;
	base_height = -457;
	fog_r = 0.113725;
	fog_g = 0.172549;
	fog_b = 0.164706;
	fog_scale = 4.89644;
	sun_col_r = 1;
	sun_col_g = 0.54902;
	sun_col_b = 0.180392;
	sun_dir_x = -0.415321;
	sun_dir_y = 0.886763;
	sun_dir_z = 0.202878;
	sun_start_ang = 0;
	sun_stop_ang = 83;
	time = 0;
	max_fog_opacity = 0.691749;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	VisionSetNaked( "flashpoint", 0 );
	//SetSunLight(0.9336, 0.778, 0.508);

   SetSavedDvar( "r_lightTweakSunLight", 8 );

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.15 );
	SetSavedDvar( "r_lightGridContrast", 0.1 );
	
}

set_commsbuildingroof_fog()
{
	level waittill("set_commsbuildingroof_fog");
	
start_dist = 137.562;
	half_dist = 279.422;
	half_height = 250.669;
	base_height = 182.411;
	fog_r = 0.113725;
	fog_g = 0.172549;
	fog_b = 0.164706;
	fog_scale = 4.10983;
	sun_col_r = 1;
	sun_col_g = 0.486275;
	sun_col_b = 0.137255;
	sun_dir_x = -0.415321;
	sun_dir_y = 0.886763;
	sun_dir_z = 0.202878;
	sun_start_ang = 0;
	sun_stop_ang = 84;
	time = 3;
	max_fog_opacity = 0.807658;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

            
	VisionSetNaked( "flashpoint", 0 );
}

set_weaverbuilding_fog()
{
	level waittill("set_weaverbuilding_fog");
	
start_dist = 0;
	    half_dist = 2076.9;
	    half_height = 323.416;
	    base_height = -127.798;
	    fog_r = 0.415686;
	    fog_g = 0.501961;
	    fog_b = 0.521569;
	    fog_scale = 3.05482;
      sun_col_r = 1;
      sun_col_g = 0.745098;
      sun_col_b = 0.298039;
      sun_dir_x = -0.415321;
      sun_dir_y = 0.886763;
      sun_dir_z = 0.202878;
      sun_start_ang = 0;
      sun_stop_ang = 180;
      time = 2;
      max_fog_opacity = 0.807658;

      setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
            sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
            sun_stop_ang, time, max_fog_opacity);

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.25 );
	SetSavedDvar( "r_lightGridContrast", 0.15 );

	VisionSetNaked( "flashpoint_tunnels", 2 );

}

set_entertunnels_fog()
{
	//level waittill("set_entertunnels_fog");						//NOT DONE YET - PETER
	
	start_dist = 153.026;
	half_dist = 744.518;
	half_height = 31965.1;
	base_height = -457.46;
	fog_r = 0.0588235;
	fog_g = 0.101961;
	fog_b = 0.164706;
	fog_scale = 3.56721;
	sun_col_r = 1;
	sun_col_g = 0.54902;
	sun_col_b = 0.160784;
	sun_dir_x = -0.415321;
	sun_dir_y = 0.886763;
	sun_dir_z = 0.202878;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 5;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	VisionSetNaked( "flashpoint_tunnels", 5 );
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.25 );
	SetSavedDvar( "r_lightGridContrast", 0.15 );
	
	// enter_b_tunnels + exit_b_tunnels
}

set_tunnels_gas_on_fog()
{
	level waittill("set_tunnels_gas_on_fog");
	
	//VisionSetNaked( "flashpoint_gasmask", 0 );
//	SetVolFog(335.0, 38.0, 300.0, 300.0, 1.0, 0.9, 0.7, 5.0 );

	start_dist = 255.676;
	half_dist = 104.928;
	half_height = 300;
	base_height = 468.034;
	fog_r = 0.941177;
	fog_g = 0.945098;
	fog_b = 0.917647;
	fog_scale = 3.55878;
	sun_col_r = 0.501961;
	sun_col_g = 0.501961;
	sun_col_b = 0.501961;
	sun_dir_x = 1;
	sun_dir_y = 0;
	sun_dir_z = 0;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 2.0;
	max_fog_opacity = 0.962057;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);	
		
	VisionSetNaked( "flashpoint_gasmask", 0 );
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.25 );
	SetSavedDvar( "r_lightGridContrast", 0.15 );
}

set_tunnels_gas_off_fog()
{
	level waittill("set_tunnels_gas_off_fog");
	
	//VisionSetNaked( "flashpoint", 0 );
	
	
	  start_dist = 0;
      half_dist = 175.629;
      half_height = 233.134;
      base_height = -457;
      fog_r = 0.356863;
      fog_g = 0.501961;
      fog_b = 0.521569;
      fog_scale = 3.05482;
      sun_col_r = 1;
      sun_col_g = 0.745098;
      sun_col_b = 0.298039;
      sun_dir_x = -0.415321;
      sun_dir_y = 0.886763;
      sun_dir_z = 0.202878;
      sun_start_ang = 0;
      sun_stop_ang = 180;
      time = 0;
      max_fog_opacity = 0.807658;

      setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
            sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
            sun_stop_ang, time, max_fog_opacity);
            
      VisionSetNaked( "flashpoint_tunnels", 0 );
      SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	    SetSavedDvar( "r_lightGridIntensity", 1.25 );
	    SetSavedDvar( "r_lightGridContrast", 0.15 );
}

set_exittunnels_fog()
{
	//level waittill("set_exittunnels_fog");						//NOT DONE YET - PETER
	
	// enter_b_tunnels + exit_b_tunnels
	
	start_dist = 69.3651;
	half_dist = 162.044;
	half_height = 250.672;
	base_height = -457;
	fog_r = 0.113725;
	fog_g = 0.172549;
	fog_b = 0.164706;
	fog_scale = 7.06547;
	sun_col_r = 1;
	sun_col_g = 0.54902;
	sun_col_b = 0.160784;
	sun_dir_x = -0.415321;
	sun_dir_y = 0.886763;
	sun_dir_z = 0.202878;
	sun_start_ang = 0;
	sun_stop_ang = 38.9984;
	time = 5;
	max_fog_opacity = 0.691749;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

		
	VisionSetNaked( "flashpoint", 0 );
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.3 );
	SetSavedDvar( "r_lightGridContrast", 0.1 );
		
}


////////////////////////////heli pad
slide_6_dof()
{
	level waittill ("set_slide_6_dof");
	NearStart = 0;
	NearEnd = 10;
	FarStart = 500;
	FarEnd = 1300;
	NearBlur = 4;
	FarBlur = 1;

	get_players()[0] SetDepthOfField( NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur);	

	VisionSetNaked( "flashpoint_slide_a", 0 );
	level._last_visionset = "flashpoint_slide_a";

	start_dist = 69.3651;
	half_dist = 163.935;
	half_height = 250.672;
	base_height = -457;
	fog_r = 0.113725;
	fog_g = 0.172549;
	fog_b = 0.164706;
	fog_scale = 7.06547;
	sun_col_r = 1;
	sun_col_g = 0.54902;
	sun_col_b = 0.160784;
	sun_dir_x = -0.415321;
	sun_dir_y = 0.886763;
	sun_dir_z = 0.202878;
	sun_start_ang = 0;
	sun_stop_ang = 43.796;
	time = 0;
	max_fog_opacity = 0.691749;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
}

/////////////////////////////////// matrix shoot em up
slide_1_dof()
{
	level waittill ("set_slide_1_dof");
	NearStart = 0;
	NearEnd = 32;
	FarStart = 175;
	FarEnd = 630;
	NearBlur = 4;
	FarBlur = 1.5;

	get_players()[0] SetDepthOfField( NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur);	

	VisionSetNaked( "flashpoint_tunnels", 0 );
	level._last_visionset = "flashpoint_tunnels";

	start_dist = 153.026;
	half_dist = 744.518;
	half_height = 31965.1;
	base_height = -457.46;
	fog_r = 0.0588235;
	fog_g = 0.101961;
	fog_b = 0.164706;
	fog_scale = 3.56721;
	sun_col_r = 1;
	sun_col_g = 0.54902;
	sun_col_b = 0.160784;
	sun_dir_x = -0.415321;
	sun_dir_y = 0.886763;
	sun_dir_z = 0.202878;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 0;
	max_fog_opacity = 1;
	
		setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
}


//////////////////////////////// The next series of quick shots
slide_2_dof()
{
	level waittill ("set_slide_2_dof");
	NearStart = 0;
	NearEnd = 32;
	FarStart = 175;
	FarEnd = 630;
	NearBlur = 4;
	FarBlur = 1.5;

	get_players()[0] SetDepthOfField( NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur);	

	VisionSetNaked( "flashpoint_slide_a", 0 );
	level._last_visionset = "flashpoint_slide_a";

	start_dist = 69.3651;
	half_dist = 162.044;
	half_height = 250.672;
	base_height = -457;
	fog_r = 0.113725;
	fog_g = 0.172549;
	fog_b = 0.164706;
	fog_scale = 7.06547;
	sun_col_r = 1;
	sun_col_g = 0.54902;
	sun_col_b = 0.160784;
	sun_dir_x = -0.415321;
	sun_dir_y = 0.886763;
	sun_dir_z = 0.202878;
	sun_start_ang = 0;
	sun_stop_ang = 83;
	time = 0;
	max_fog_opacity = 0.691749;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
}


/////////////////////////////Slide limo		
slide_4_dof()
{
	level waittill ("set_slide_4_dof");
	NearStart = 0;
	NearEnd = 10;
	FarStart = 175;
	FarEnd = 1630;
	NearBlur = 4;
	FarBlur = 1.0;

	get_players()[0] SetDepthOfField( NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur);	

	VisionSetNaked( "flashpoint_slide_a", 0 );
	level._last_visionset = "flashpoint_slide_a";

	start_dist = 69.3651;
	half_dist = 162.044;
	half_height = 250.672;
	base_height = -457;
	fog_r = 0.113725;
	fog_g = 0.172549;
	fog_b = 0.164706;
	fog_scale = 7.06547;
	sun_col_r = 1;
	sun_col_g = 0.54902;
	sun_col_b = 0.160784;
	sun_dir_x = -0.415321;
	sun_dir_y = 0.886763;
	sun_dir_z = 0.202878;
	sun_start_ang = 0;
	sun_stop_ang = 83;
	time = 0;
	max_fog_opacity = 0.691749;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
}

tunnel_vision()
{
	while(1)
	{
		trigger_wait("tunnel_vision_trig");
		set_entertunnels_fog();
		
		trigger_wait("not_tunnel_vision_trig");
		set_exittunnels_fog();
	}
}
		
