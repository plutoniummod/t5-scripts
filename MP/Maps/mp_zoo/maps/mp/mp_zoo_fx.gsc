#include maps\mp\_utility; 

// fx prop anim effects
#using_animtree ( "fxanim_props_dlc3" );
precache_fx_prop_anims()
{
	level.zoo_fxanims = [];
	level.zoo_fxanims[ "fxanim_mp_zoo_lights" ] = %fxanim_mp_zoo_lights_anim;
	level.zoo_fxanims[ "fxanim_mp_zoo_drapes" ] = %fxanim_mp_zoo_drapes_anim;
	level.zoo_fxanims[ "fxanim_gp_wirespark_med_anim" ] = %fxanim_gp_wirespark_med_anim;
	level.zoo_fxanims[ "fxanim_gp_wirespark_long_anim" ] = %fxanim_gp_wirespark_long_anim;
	level.zoo_fxanims[ "fxanim_gp_zoo_fish" ] = %fxanim_mp_zoo_fish_01_anim;
	level.zoo_fxanims[ "fxanim_mp_zoo_rail_wire02" ] = %fxanim_mp_zoo_rail_wire02_anim;
	level.zoo_fxanims[ "fxanim_mp_zoo_lights_frnt" ] = %fxanim_mp_zoo_lights_frnt_anim;
	level.zoo_fxanims[ "fxanim_mp_zoo_lights_back" ] = %fxanim_mp_zoo_lights_back_anim;
	level.zoo_fxanims[ "fxanim_gp_chain01" ] = %fxanim_gp_chain01_anim;
	level.zoo_fxanims[ "fxanim_gp_chain02" ] = %fxanim_gp_chain02_anim;
	level.zoo_fxanims[ "fxanim_gp_chain03" ] = %fxanim_gp_chain03_anim;
	level.zoo_fxanims[ "fxanim_mp_zoo_rail_wire01" ] = %fxanim_mp_zoo_rail_wire01_anim;
	level.zoo_fxanims[ "fxanim_mp_zoo_birdnet_ropes" ] = %fxanim_mp_zoo_birdnet_ropes_anim;
	level.zoo_fxanims[ "fxanim_mp_zoo_banner" ] = %fxanim_mp_zoo_banner_anim;

	level.zoo_fx = [];
	level.zoo_fx[ "fx_light_bulb_incandescent" ] = loadfx( "env/light/fx_light_bulb_incandescent" );
	level.zoo_fx[ "fx_light_bulb_incandescent_dim" ] = loadfx( "env/light/fx_light_bulb_incandescent_dim" );
	level.zoo_fx[ "fx_elec_spark" ] = loadfx( "env/electrical/fx_elec_wire_spark_burst_xsm" );
}

// Scripted effects
precache_scripted_fx()
{
	
}

precache_createfx_fx()
{

	level._effect["fx_pipe_steam_md"]                         = loadfx("env/smoke/fx_pipe_steam_md");
	level._effect["fx_mp_fumes_haze_md"]                      = loadfx("maps/mp_maps/fx_mp_fumes_haze_md");
	
	 level._effect["fx_mp_berlin_smoke_stack"]			      		= loadfx("maps/mp_maps/fx_mp_berlin_smoke_stack");

	level._effect["fx_mp_fog_ground_md"]											= loadfx("maps/mp_maps/fx_mp_fog_ground_md");	
	level._effect["fx_fog_rolling_ground_md"]          				= loadfx("env/smoke/fx_fog_rolling_ground_md_grey");
	level._effect["fx_fog_rolling_ground_md_nrrw"]          	= loadfx("env/smokE/fx_fog_rolling_ground_md_nrrw_grey");	
	level._effect["fx_mp_berlin_fog_int"]			          			= loadfx("maps/mp_maps/fx_mp_fog_xsm_int");
	level._effect["fx_fog_interior_md"]          							= loadfx("env/smoke/fx_fog_interior_md");

	level._effect["fx_leaves_falling_lite"]										= loadfx("env/foliage/fx_leaves_falling_lite");
	level._effect["fx_leaves_falling_lite_w"]      						= loadfx("env/foliage/fx_leaves_falling_lite_w_sm");
	level._effect["fx_leaves_ground_windy"]      							= loadfx("env/foliage/fx_leaves_ground_windy");
	level._effect["fx_leaves_ground_windy_narrow"]      			= loadfx("env/foliage/fx_leaves_ground_windy_narrow");
	level._effect["fx_leaves_ground_windy_short"]      				= loadfx("env/foliage/fx_leaves_ground_windy_short");	
	level._effect["fx_leaves_dust_devil"]      								= loadfx("env/foliage/fx_leaves_dust_devil");	
	
  level._effect["fx_debris_papers"]                         = loadfx("env/debris/fx_debris_papers");
  level._effect["fx_debris_papers_dust_devil2"]      				= loadfx("env/debris/fx_debris_papers_dust_devil2");
  
  level._effect["fx_insects_swarm_md_light"]                = loadfx("bio/insects/fx_insects_swarm_md_light");
  level._effect["fx_insects_roaches_fast"]                	= loadfx("bio/insects/fx_insects_roaches_fast");
  level._effect["fx_insects_moths_light_source"]						= loadfx("bio/insects/fx_insects_moths_light_source");
	level._effect["fx_insects_moths_light_source_md"]					= loadfx("bio/insects/fx_insects_moths_light_source_md");
  
	level._effect["fx_water_drip_light_long"]									= loadfx("maps/mp_maps/fx_mp_water_drip_xlight_long");	
	level._effect["fx_water_drip_light_short"]								= loadfx("maps/mp_maps/fx_mp_water_drip_xlight_short");	
	
	level._effect["fx_mp_light_dust_motes_md"]								= loadfx("maps/mp_maps/fx_mp_light_dust_motes_md");
	
	level._effect["fx_mp_elec_spark_burst_sm"]								= loadfx("maps/mp_maps/fx_mp_elec_spark_burst_sm");
	level._effect["fx_mp_elec_spark_burst_xsm_thin"]					= loadfx("maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin");
	level._effect["fx_elec_burst_oneshot"]										= loadfx("env/electrical/fx_elec_burst_oneshot");	

	level._effect["fx_light_tinhat_cage_white"]								= loadfx("env/light/fx_light_tinhat_cage_white");	
//	level._effect["fx_light_office_light_03"]         				= loadfx("env/light/fx_light_office_light_03");
	level._effect["fx_mp_outskirts_floures_glow1"]		    		=	loadfx("maps/mp_maps/fx_mp_outskirts_floures_glow_1");
	level._effect["fx_mp_dlc3_outskirts_tinhat"]		      		=	loadfx("maps/mp_maps/fx_mp_outskirts_spotlight_glow_1");
	level._effect["fx_light_tram_floor_path_lights"]		      =	loadfx("env/light/fx_light_tram_floor_path_lights");	
	level._effect["fx_light_tram_overhead"]		      					=	loadfx("env/light/fx_light_tram_overhead");		
	level._effect["fx_light_stoplight_red_flicker"]		      	=	loadfx("env/light/fx_light_stoplight_red_flicker");	
	level._effect["fx_monorail_headlight_flicker"]		      	=	loadfx("vehicle/light/fx_monorail_headlight_flicker");	
	level._effect["fx_monorail_headlight_flicker_dim"]		    =	loadfx("vehicle/light/fx_monorail_headlight_flicker_dim");		
	level._effect["fx_monorail_headlight_flicker_os"]		    	=	loadfx("vehicle/light/fx_monorail_headlight_flicker_os");
	level._effect["fx_light_beacon_red"]											= loadfx("env/light/fx_light_beacon_red_sm");
  level._effect["fx_light_beacon_red_distant_slw"]					= loadfx("env/light/fx_light_beacon_red_distant_slw");
  level._effect["fx_light_window_glow_vista"]								= loadfx("env/light/fx_light_window_glow_vista");  
  level._effect["fx_light_window_glow_vista_sm"]						= loadfx("env/light/fx_light_window_glow_vista_sm");    


	level._effect["fx_mp_light_gray_warm_lrg"]								= loadfx("maps/mp_maps/fx_mp_light_gray_warm_lrg");		
	level._effect["fx_mp_light_gray_warm_sm"]									= loadfx("maps/mp_maps/fx_mp_light_gray_warm_sm");		
	level._effect["fx_mp_light_gray_warm_md"]									= loadfx("maps/mp_maps/fx_mp_light_gray_warm_md");
	
	level._effect["fx_mp_zoo_lightning_runner"]								= loadfx("maps/mp_maps/fx_mp_zoo_lightning_runner");	

}

wind_initial_setting()
{
SetDvar( "enable_global_wind", 1); // enable wind for your level
SetDvar( "wind_global_vector", "-125 -115 -125" );    // change "0 0 0" to your wind vector
SetDvar( "wind_global_low_altitude", -175);    // change 0 to your wind's lower bound
SetDvar( "wind_global_hi_altitude", 4000);    // change 10000 to your wind's upper bound
SetDvar( "wind_global_low_strength_percent", .5);    // change 0.5 to your desired wind strength percentage
}

main()
{
	precache_fx_prop_anims();
	precache_scripted_fx();
	precache_createfx_fx();

	maps\mp\createfx\mp_zoo_fx::main();
	maps\mp\createart\mp_zoo_art::main();
	
	wind_initial_setting();
}
