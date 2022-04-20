#include maps\mp\_utility; 

// fx used by utility scripts
precache_util_fx()
{
	
}

// fx prop anim effects
#using_animtree ( "fxanim_props_dlc2" );
precache_fx_prop_anims()
{
	level.discovery_fxanims = [];
	level.discovery_fxanims["icebridge01_back_anim"] = %fxanim_mp_icebridge01_back_anim;
	level.discovery_fxanims["icebridge01_front_anim"] = %fxanim_mp_icebridge01_front_anim;
	level.discovery_fxanims["icebridge02_anim"] = %fxanim_mp_icebridge02_anim;
	level.discovery_fxanims["icebridge03_anim"] = %fxanim_mp_icebridge03_anim;
	level.discovery_fxanims["icebridge04_anim"] = %fxanim_mp_icebridge04_anim;
	level.discovery_fxanims["icebridge05_anim"] = %fxanim_mp_icebridge05_anim;
}

// Scripted effects
precache_scripted_fx()
{

}

// Ambient effects
precache_createfx_fx()
{
	level._effect["fx_mp_discovery_aurore"] 							= loadfx("maps/mp_maps/fx_mp_discovery_aurore2");
	level._effect["fx_mp_discovery_aurore_cloud"] 				= loadfx("maps/mp_maps/fx_mp_discovery_aurore_cloud");

	level._effect["fx_mp_snow_gust_rooftop"] 							= loadfx("maps/mp_maps/fx_mp_snow_gust_rooftop_oo");
	level._effect["fx_mp_snow_gust_rooftop_oo_thin"] 			= loadfx("maps/mp_maps/fx_mp_snow_gust_rooftop_oo_thin");
	level._effect["fx_mp_snow_gust_ground_lg"] 						= loadfx("maps/mp_maps/fx_mp_snow_gust_ground_lg");
	level._effect["fx_mp_snow_gust_ground_lg_thin"] 			= loadfx("maps/mp_maps/fx_mp_snow_gust_ground_lg_thin");
	level._effect["fx_mp_snow_gust_ground_lg_oo"] 				= loadfx("maps/mp_maps/fx_mp_snow_gust_ground_lg_oo");
	level._effect["fx_mp_snow_gust_ground_lg_thin_oo"] 		= loadfx("maps/mp_maps/fx_mp_snow_gust_ground_lg_thin_oo");
	level._effect["fx_mp_snow_gust_ground_sm_os"] 				= loadfx("maps/mp_maps/fx_mp_snow_gust_ground_sm_fast_os");
	level._effect["fx_mp_snow_gust_door_low"] 						= loadfx("maps/mp_maps/fx_mp_snow_gust_door_low_no_snow");
	
	level._effect["fx_mp_snow_wall_hvy_loop_sm"] 					= loadfx("maps/mp_maps/fx_mp_snow_wall_hvy_loop_sm_oo");
	
	level._effect["fx_mp_elec_spark_burst_xsm_thin"]			= loadfx("maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin");
	
	level._effect["fx_pipe_steam_md"] 										= loadfx("env/smoke/fx_pipe_steam_md");
	level._effect["fx_fumes_vent_xsm_int"]								= loadfx("maps/mp_maps/fx_mp_fumes_vent_xsm_int");
	level._effect["fx_fumes_vent_sm_int"]									= loadfx("maps/mp_maps/fx_mp_fumes_vent_sm_int");
	
	level._effect["fx_fog_interior_md"]          					= loadfx("env/smoke/fx_fog_interior_md");
	level._effect["fx_snow_falling_ceiling"] 							= loadfx("maps/mp_maps/fx_mp_snow_falling_ceiling");	
	level._effect["fx_truck_headlight"] 					    		= loadfx("maps/mp_maps/fx_mp_headlight_truck");	
  level._effect["fx_snow_swirl_ambience"] 				   		= loadfx("maps/mp_maps/fx_mp_snow_gust_swirl_amb");	
  level._effect["fx_snow_puff"] 				            		= loadfx("maps/mp_maps/fx_mp_snow_puff");
  level._effect["fx_spotlight_1"] 				            	= loadfx("maps/mp_maps/fx_mp_light_spot_1");
  level._effect["fx_light_lantern_1"] 				         	= loadfx("maps/mp_maps/fx_mp_light_lantern_1");	   
  level._effect["fx_smoke_exhaust_truck"] 				     	= loadfx("maps/mp_maps/fx_mp_smk_exhaust_1");	 
  level._effect["fx_distortion_heat_truck"] 				   	= loadfx("maps/mp_maps/fx_mp_distortion_heat_engine");
  level._effect["fx_distortion_heat_lamp"] 				    	= loadfx("maps/mp_maps/fx_mp_distortion_heat_lamp");
  level._effect["fx_smoke_exhaust_generator"] 		     	= loadfx("maps/mp_maps/fx_mp_smk_exhaust_2");	 
  level._effect["fx_smoke_clouds_distant"] 				     	= loadfx("maps/mp_maps/fx_mp_discovery_distant_clouds2");	
  level._effect["fx_smoke_clouds_distant2"] 				   	= loadfx("maps/mp_maps/fx_mp_discovery_distant_clouds3");    	      	    	
				
		
// Exploders for Ice falling  1001,1002,1003...
	level._effect["fx_mp_snow_wall_lg_os"] 								= loadfx("maps/mp_maps/fx_mp_snow_wall_lg_os");

}

main()
{
	// art file would be called here
	
	precache_util_fx();
	precache_createfx_fx();
	precache_scripted_fx();
	precache_fx_prop_anims();
	// calls the createfx server script (i.e., the list of ambient effects and their attributes)
	maps\mp\createfx\mp_discovery_fx::main();
	
	maps\mp\createart\mp_discovery_art::main();

	SetDvar( "enable_global_wind", 1 );
	SetDvar( "wind_global_vector", "-120 -85 -120" );
	SetDvar( "wind_global_low_altitude", -175 );
	SetDvar( "wind_global_hi_altitude", 4000 );
	SetDvar( "wind_global_low_strength_percent", .5 );
}

