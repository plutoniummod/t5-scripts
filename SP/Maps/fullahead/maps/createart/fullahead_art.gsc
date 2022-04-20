#include maps\_utility;
#include common_scripts\utility;

main()
{
	
	start_dist = 0;
	half_dist = 3041.32;
	half_height = 1390.12;
	base_height = -1.2451;
	fog_r = 0.207843;
	fog_g = 0.247059;
	fog_b = 0.266667;
	fog_scale = 3.1;
  sun_col_r = 0.439216;
	sun_col_g = 0.466667;
	sun_col_b = 0.498039;
	sun_dir_x = -0.58614;
	sun_dir_y = 0.80253;
	sun_dir_z = 0.111289;
	sun_start_ang = 0;
	sun_stop_ang = 132.465;
	time = 0;
	max_fog_opacity = 1;


	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);



VisionSetNaked( "fullahead_base", 0 );

// Flashlight settings
	SetSavedDvar( "r_flashLightRange", "545" );
	SetSavedDvar( "r_flashLightEndRadius", "420" );
	SetSavedDvar( "r_flashLightBrightness", "25" );
	SetSavedDvar( "r_flashLightOffset", "-10.3 -7.8 -4.2" );
	VisionSetNaked( "creek_1_tunnel", 0 );
	
	SetSavedDvar( "r_flashLightFlickerAmount", "0.03" );
	SetSavedDvar( "r_flashLightFlickerRate", "62" );
	SetSavedDvar( "r_flashLightBobAmount", "3 3 3" );
	SetSavedDvar( "r_flashLightBobRate", "0.17 0.16 0.25" );
	SetSavedDvar( "r_flashLightColor", ".61 .54 .45" );
	
	////////////Depricated Hero Lighting///////////////////
	//SetDvar( "r_heroLightColorTemp", "6500" );
	//SetDvar( "r_heroLightSaturation", "1" );
	//SetDvar( "r_heroLightScale", "0.5 0.5 0.5" );
	/////////////New Hero Lighting////////////////////////
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.0 );
	SetSavedDvar( "r_lightGridContrast", 0.0 );
	



	//Fog Thread
	
	level thread map_start();

}

// Connects trigger to thread
map_start()
{
	self endon("death");

	trig = GetEnt("test", "script_noteworthy");
	trig waittill("trigger");

	// update vision settings
	map_start_fog_trigger();
}


dogsled_fog()
{
	
		start_dist = 134.317;
	half_dist = 1155.17;
	half_height = 468.28;
	base_height = -1.2451;
	fog_r = 0.145098;
	fog_g = 0.211765;
	fog_b = 0.207843;
	fog_scale = 10;
	sun_col_r = 0.831373;
	sun_col_g = 0.933333;
	sun_col_b = 0.960784;
	sun_dir_x = -0.460823;
	sun_dir_y = 0.765521;
	sun_dir_z = 0.449021;
	sun_start_ang = 0;
	sun_stop_ang = 58.8056;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.0 );
	SetSavedDvar( "r_lightGridContrast", 0.15 );
}

ghostship_fog()
{
	
	start_dist = 57.6853;
	half_dist = 697.379;
	half_height = 417.796;
	base_height = -1.2451;
	fog_r = 0.0666667;
	fog_g = 0.113725;
	fog_b = 0.129412;
	fog_scale = 6.03432;
	sun_col_r = 0.831373;
	sun_col_g = 0.933333;
	sun_col_b = 0.960784;
	sun_dir_x = -0.460823;
	sun_dir_y = 0.765521;
	sun_dir_z = 0.449021;
	sun_start_ang = 0;
	sun_stop_ang = 74.9642;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

		
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.1 );
	SetSavedDvar( "r_lightGridContrast", -0.1 );
	SetSavedDvar( "r_skyColorTemp", (5900)); 


}


base_fog()
{
	
	
	start_dist = 150.472;
	half_dist = 573.203;
	half_height = 417.796;
	base_height = -385.448;
	fog_r = 0.203922;
	fog_g = 0.25098;
	fog_b = 0.266667;
	fog_scale = 7.49371;
	sun_col_r = 0.831373;
	sun_col_g = 0.933333;
	sun_col_b = 0.960784;
	sun_dir_x = -0.460823;
	sun_dir_y = 0.765521;
	sun_dir_z = 0.449021;
	sun_start_ang = 0;
	sun_stop_ang = 80.2092;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


		
			SetSavedDvar( "r_lightGridEnableTweaks", 1 );
			SetSavedDvar( "r_lightGridIntensity", 1.2 );
			SetSavedDvar( "r_lightGridContrast", 0.0 );



}

default_fog()
{
	
	start_dist = 0;
	half_dist = 3041.32;
	half_height = 1390.12;
	base_height = -1.2451;
	fog_r = 0.207843;
	fog_g = 0.247059;
	fog_b = 0.266667;
	fog_scale = 3.1;
  sun_col_r = 0.439216;
	sun_col_g = 0.466667;
	sun_col_b = 0.498039;
	sun_dir_x = -0.58614;
	sun_dir_y = 0.80253;
	sun_dir_z = 0.111289;
	sun_start_ang = 0;
	sun_stop_ang = 132.465;
	time = 0;
	max_fog_opacity = 1;


	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity); 
		
			SetSavedDvar( "r_lightGridEnableTweaks", 1 );
			SetSavedDvar( "r_lightGridIntensity", 1.0 );
			SetSavedDvar( "r_lightGridContrast", 0.0 );
}

bridge_fog()
{
	
	start_dist = 336.8727;
	half_dist = 240.842;
	half_height = 290.241;
	base_height = -1.2451;
	fog_r = 0.572549;
	fog_g = 0.713726;
	fog_b = 0.776471;
	fog_scale = 2.59065;
	sun_col_r = 0.831373;
	sun_col_g = 0.933333;
	sun_col_b = 0.960784;
	sun_dir_x = -0.460823;
	sun_dir_y = 0.765521;
	sun_dir_z = 0.449021;
	sun_start_ang = 0;
	sun_stop_ang = 80.2092;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


			SetSavedDvar( "r_lightGridEnableTweaks", 1 );
			SetSavedDvar( "r_lightGridIntensity", 1.0 );
			SetSavedDvar( "r_lightGridContrast", 0.0 );
			SetSavedDvar( "r_skyColorTemp", (5900)); 
			//SetSunLight(0.999, 0.935, 0.826);

}


map_start_fog_trigger()
{
//	IPrintLnBold("hello world");
	clientnotify ("example_mixer_event_name");
}