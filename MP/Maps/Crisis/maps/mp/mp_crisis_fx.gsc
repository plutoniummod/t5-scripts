#include maps\mp\_utility; 

precache_createfx_fx()
{
//	level._effect["fx_light_floodlight_ext_warm"]			= 	loadfx("env/light/fx_light_floodlight_ext_warm");
	level._effect["fx_light_tinhat_cage_white_lg"]		= 	loadfx("env/light/fx_light_tinhat_cage_white_lg");
  level._effect["fx_light_office_light_03"]         = loadfx("env/light/fx_light_office_light_03");
	
//	level._effect["fx_mp_light_gray_warm_lrg"]						= loadfx("maps/mp_maps/fx_mp_light_gray_warm_lrg");		
//	level._effect["fx_mp_light_gray_warm_sm"]							= loadfx("maps/mp_maps/fx_mp_light_gray_warm_sm");		
//	level._effect["fx_mp_light_gray_warm_md"]							= loadfx("maps/mp_maps/fx_mp_light_gray_warm_md");	
	
	level._effect["fx_seagulls_shore_distant"]				= 	loadfx("bio/animals/fx_seagulls_shore_distant");	
//	level._effect["fx_insects_swarm_md_light"]				= 	loadfx("bio/insects/fx_insects_swarm_md_light");
	
	level._effect["fx_water_river_shore2"]						= 	loadfx("env/water/fx_water_river_shore2");
	level._effect["fx_mp_water_wave_break_sm"]				= 	loadfx("env/water/fx_mp_water_wave_break_sm");
	level._effect["fx_cuba_waves_shorebreak"]					= 	loadfx("maps/mp_maps/fx_mp_waves_shorebreak_mp");

//	level._effect["fx_smk_vent"]											= 	loadfx("env/smoke/fx_smk_vent");
//	level._effect["fx_mp_fumes_vent_sm"]							= 	loadfx("maps/mp_maps/fx_mp_fumes_vent_sm");
//	level._effect["fx_mp_fumes_haze_md"]							= 	loadfx("maps/mp_maps/fx_mp_fumes_haze_md");
	level._effect["fx_mp_fumes_vent_sm_int"]					= 	loadfx("maps/mp_maps/fx_mp_fumes_vent_sm_int");
	level._effect["fx_pipe_steam_md"]									= 	loadfx("env/smoke/fx_pipe_steam_md");
	level._effect["fx_smk_linger_lit"]								= 	loadfx("maps/mp_maps/fx_mp_smk_linger");
	level._effect["fx_fog_interior_md"]          			= 	loadfx("env/smoke/fx_fog_interior_md");
	
	level._effect["fx_dust_crumble_int_sm"]						= loadfx("env/dirt/fx_dust_crumble_int_sm");
	level._effect["fx_dust_crumble_int_md"]						= loadfx("env/dirt/fx_dust_crumble_int_md");

	level._effect["fx_mp_elec_spark_burst_xsm_thin"]	= 	loadfx("maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin");
//	level._effect["fx_mp_elec_spark_burst_lg"]				= 	loadfx("maps/mp_maps/fx_mp_elec_spark_burst_lg");
	level._effect["fx_mp_elec_spark_burst_sm"]				= 	loadfx("maps/mp_maps/fx_mp_elec_spark_burst_sm");
	
//	level._effect["fx_debris_papers"]									= 	loadfx("env/debris/fx_debris_papers");
	
//	level._effect["fx_mp_smk_plume_xsm_grey"]					= 	loadfx("maps/mp_maps/fx_mp_smk_plume_xsm_grey");
//	level._effect["fx_mp_smk_plume_md_grey"]					= 	loadfx("maps/mp_maps/fx_mp_smk_plume_md_grey");
	
	level._effect["fx_water_spray_leak_sm"]						= 	loadfx("env/water/fx_water_spray_leak_sm");
	level._effect["fx_water_drip_light_short"]				=		loadfx("env/water/fx_water_drip_light_short");
		
	level._effect["fx_fire_md"]												= 	loadfx("env/fire/fx_fire_md");
//	level._effect["fx_fire_sm"]												= 	loadfx("env/fire/fx_fire_sm");
	level._effect["fx_fire_ember_column_md"]					=		loadfx("env/fire/fx_fire_ember_column_md");
	level._effect["fx_embers_wind_md"]								=		loadfx("env/fire/fx_embers_wind_md");

	level._effect["fx_mp_light_dust_motes_md"]				= 	loadfx("maps/mp_maps/fx_mp_light_dust_motes_md");
	
	level._effect["fx_mp_smk_smolder_sm"]							= 	loadfx("maps/mp_maps/fx_mp_smk_smolder_sm");
	level._effect["fx_smk_smolder_sm_blk"]          	= 	loadfx("env/smoke/fx_smk_smolder_sm_blk");
//	level._effect["fx_smk_smolder_xsm_blk"]          	= 	loadfx("env/smoke/fx_smk_smolder_xsm_blk");
	level._effect["fx_smk_smolder_rubble_md"]         = 	loadfx("env/smoke/fx_smk_smolder_rubble_md");

	level._effect["fx_fire_column_sm_thin"] 					= 	loadfx("env/fire/fx_fire_column_sm_thin");
//	level._effect["fx_fire_line_sm"] 									= 	loadfx("env/fire/fx_fire_line_sm");
	level._effect["fx_fire_line_xsm_thin"] 						= 	loadfx("env/fire/fx_fire_line_xsm_thin");
	level._effect["fx_fire_line_sm_thin"] 						= 	loadfx("env/fire/fx_fire_line_sm_thin");
	
	level._effect["fx_sand_blowing_deast_sm"]					= 	loadfx("env/dirt/fx_sand_blowing_deast_sm");
	
}

wind_initial_setting()
{
SetDvar( "enable_global_wind", 1); // enable wind for your level
SetDvar( "wind_global_vector", "-110 -100 -110" );    // change "0 0 0" to your wind vector
SetDvar( "wind_global_low_altitude", -175);    // change 0 to your wind's lower bound
SetDvar( "wind_global_hi_altitude", 4000);    // change 10000 to your wind's upper bound
SetDvar( "wind_global_low_strength_percent", .5);    // change 0.5 to your desired wind strength percentage
}

main()
{
	maps\mp\createfx\mp_crisis_fx::main();
	precache_createfx_fx();
	maps\mp\createart\mp_crisis_art::main();
	
	wind_initial_setting();
}
