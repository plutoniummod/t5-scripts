#include maps\mp\_utility; 

// fx used by util scripts
precache_util_fx()
{
	
}

// Scripted effects
precache_scripted_fx()
{
	
}

// Ambient effects
precache_createfx_fx()
{	
	level._effect["fx_mp_berlin_snow"]							    = loadfx("maps/mp_maps/fx_mp_berlin_snow");
	level._effect["fx_mp_berlin_snow_window"]						= loadfx("maps/mp_maps/fx_mp_berlin_snow_window");	
  level._effect["fx_mp_berlin_light_ray_lrg"]					= loadfx("maps/mp_maps/fx_mp_berlin_light_ray_lrg");
  level._effect["fx_mp_berlin_light_cone"]						= loadfx("maps/mp_maps/fx_mp_berlin_light_cone");			
  level._effect["fx_mp_snow_gust_street"]						  = loadfx("maps/mp_maps/fx_mp_snow_gust_street");	
  level._effect["fx_mp_snow_gust_street_sml"]					= loadfx("maps/mp_maps/fx_mp_snow_gust_street_sml");
  level._effect["fx_mp_berlin_snow_gust_door"]				= loadfx("maps/mp_maps/fx_mp_berlin_snow_gust_door");        
  level._effect["fx_mp_berlin_smk_smolder_sm"]			  = loadfx("maps/mp_maps/fx_mp_berlin_smk_smolder_sm");

	level._effect["fx_smk_building_chimney_wht"]	      = loadfx("maps/mp_maps/fx_mp_smk_building_chimney_wht");  
	level._effect["fx_fog_large_slow"]							    = loadfx("env/smoke/fx_fog_large_slow");
	level._effect["fx_smk_vent"]								        = loadfx("env/smoke/fx_smk_vent");
	level._effect["fx_mp_distortion_wall_heater"] 			= loadfx("maps/mp_maps/fx_mp_distortion_wall_heater");
	level._effect["fx_mp_berlin_pipe_steam_md"] 			  = loadfx("maps/mp_maps/fx_mp_berlin_pipe_steam_md");		
	level._effect["fx_mp_berlin_pipe_steam_sm"] 	      = loadfx("maps/mp_maps/fx_mp_berlin_pipe_steam_sm");		
	
	level._effect["fx_mp_berlin_phone_booth_light"]			= loadfx("maps/mp_maps/fx_mp_berlin_phone_booth_light"); 
	level._effect["fx_mp_berlin_phone_booth_light_2"]		= loadfx("maps/mp_maps/fx_mp_berlin_phone_booth_light_2"); 		 
	level._effect["fx_light_floodlight_dim"]					  = loadfx("env/light/fx_light_floodlight_dim");  	
  level._effect["fx_light_fluorescent_tube_nobulb2"]	= loadfx("env/light/fx_light_fluorescent_tube_nobulb2");
  level._effect["fx_light_overhead_sm_warm"]				  = loadfx("env/light/fx_light_overhead_sm_warm");	
	level._effect["fx_light_beacon_red_distant_slw"]	  = loadfx("env/light/fx_light_beacon_red_distant_slw"); 
	level._effect["fx_mp_light_sign1_glow_bw2"]					= loadfx("maps/mp_maps/fx_mp_light_sign1_glow_bw2");
	level._effect["fx_mp_light_sign2_glow_bw2"]					= loadfx("maps/mp_maps/fx_mp_light_sign2_glow_bw2");
	level._effect["fx_mp_light_sign3_glow_bw2"]					= loadfx("maps/mp_maps/fx_mp_light_sign3_glow_bw2");	
	level._effect["fx_mp_light_sign4_glow_bw2"]					= loadfx("maps/mp_maps/fx_mp_light_sign4_glow_bw2");	
	level._effect["fx_mp_light_sign5_glow_bw2"]					= loadfx("maps/mp_maps/fx_mp_light_sign5_glow_bw2");						 
  
	level._effect["fx_debris_papers"]							      = loadfx("env/debris/fx_debris_papers");
  
	level._effect["fx_smk_plume_lg_grey_wispy_dist"]		= loadfx("env/smoke/fx_smk_plume_lg_grey_wispy_dist");
  level._effect["fx_mp_berlin_smoke_stack"]			      = loadfx("maps/mp_maps/fx_mp_berlin_smoke_stack");		 	
  level._effect["fx_mp_berlin_fog_int"]			          = loadfx("maps/mp_maps/fx_mp_berlin_fog_int");
  level._effect["fx_mp_berlin_smk_vent"]						  = loadfx("maps/mp_maps/fx_mp_berlin_smk_vent");
  level._effect["fx_mp_berlin_smk_smolder_md"]			  = loadfx("maps/mp_maps/fx_mp_berlin_smk_smolder_md");  

	level._effect["fx_mp_berlin_low_clouds"]						= loadfx("maps/mp_maps/fx_mp_berlin_low_clouds");  
		                  
}

main()
{
	maps\mp\createart\mp_berlinwall2_art::main();
	
	precache_util_fx();
	precache_createfx_fx();
	precache_scripted_fx();
	maps\mp\createfx\mp_berlinwall2_fx::main();

	SetDvar( "enable_global_wind", 1 );
	SetDvar( "wind_global_vector", "-110 -150 -110" );
	SetDvar( "wind_global_low_altitude", -175 );
	SetDvar( "wind_global_hi_altitude", 4000 );
	SetDvar( "wind_global_low_strength_percent", .5 );
}