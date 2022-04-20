#include maps\mp\_utility; 

// fx prop anim effects
#using_animtree ( "fxanim_props_dlc3" );
precache_fx_prop_anims()
{
	level._fxanims = [];
	level._fxanims[ "fxanim_mp_grid_pennants" ] = %fxanim_mp_grid_pennants_anim;
	level._fxanims[ "fxanim_mp_roofvent_snow" ] = %fxanim_mp_roofvent_snow_anim;
	level._fxanims[ "fxanim_gp_wirespark_med_anim" ] = %fxanim_gp_wirespark_med_anim;

	level.gridlock_fx = [];
	level.gridlock_fx[ "fx_elec_spark" ] = loadfx( "env/electrical/fx_elec_wire_spark_burst_xsm" );
}

// Scripted effects
precache_scripted_fx()
{
	level._effect = [];
	level._effect["rocket_blast_trail"]								= loadfx("vehicle/exhaust/fx_russian_rocket_exhaust_mp");
	level._effect["mig_trail"]												= loadfx("trail/fx_geotrail_jet_contrail");
	level._effect["rocket_explosion"]									= loadfx("maps/flashpoint/fx_exp_rocket_soyuz");
}

precache_createfx_fx()
{
	level._effect["fx_ship_fire_smolder_area"] 				= loadfx("maps/mp_maps/fx_mp_fire_smolder_sm_area");
//	level._effect["fx_fire_lg_fuel"] 									= loadfx("env/fire/fx_fire_lg_fuel");
//	level._effect["fx_fire_md_fuel"] 									= loadfx("env/fire/fx_fire_md_fuel");	
	level._effect["fx_fire_md_fuel_sm"] 							= loadfx("env/fire/fx_fire_md_fuel_sm2");	
	level._effect["fx_fire_sm_fuel"] 									= loadfx("env/fire/fx_fire_sm_fuel");	
//	level._effect["fx_embers_column_md"] 							= loadfx("env/fire/fx_embers_column_md");			

	level._effect["fx_mp_fire_sm_smolder_low"] 				= loadfx("maps/mp_maps/fx_mp_fire_sm_smolder_low");	

//	level._effect["fx_fire_ember_column_md"]					= loadfx("env/fire/fx_fire_ember_column_md");
//	level._effect["fx_ash_embers_light"]							= loadfx("maps/mp_maps/fx_mp_fire_ash_embers");

//	level._effect["fx_smk_field_sm"]									= loadfx("maps/mp_maps/fx_mp_smk_field_sm");
//	level._effect["fx_smk_field_md"]									= loadfx("maps/mp_maps/fx_mp_smk_field_md");

//	level._effect["fx_mp_smk_smolder_rubble_plume"]		= loadfx("maps/mp_maps/fx_mp_smk_smolder_rubble_plume");
	level._effect["fx_mp_smk_smolder_rubble_area"]		= loadfx("maps/mp_maps/fx_mp_smk_smolder_rubble_area");
	level._effect["fx_smk_smolder_sm"]								= loadfx("maps/mp_maps/fx_mp_smk_smolder_sm");
	level._effect["fx_mp_smk_plume_xsm_black"]				= loadfx("maps/mp_maps/fx_mp_smk_plume_xsm_black");

	level._effect["fx_insects_swarm_md_light"]				= loadfx("bio/insects/fx_insects_swarm_md_light");
	level._effect["fx_insects_ambient"]								= loadfx("bio/insects/fx_insects_ambient");	
	level._effect["fx_insects_butterfly_flutter_radial"]= loadfx("bio/insects/fx_insects_butterfly_moths_radial");	

	level._effect["fx_debris_papers_narrow"]					= loadfx("env/debris/fx_debris_papers_narrow");
	level._effect["fx_debris_papers"]									= loadfx("env/debris/fx_debris_papers");
//	level._effect["fx_debris_papers_lg"]							= loadfx("env/debris/fx_debris_papers_lg");
	level._effect["fx_leaves_ground_windy"]						= loadfx("env/foliage/fx_leaves_ground_windy");
	level._effect["fx_leaves_ground_windy_narrow"]    = loadfx("env/foliage/fx_leaves_ground_windy_narrow");
	level._effect["fx_leaves_ground_windy_short"]     = loadfx("env/foliage/fx_leaves_ground_windy_short");		

	level._effect["fx_pipe_steam_md"]									= loadfx("env/smoke/fx_pipe_steam_md");
	
	level._effect["fx_water_drip_light_long"]					= loadfx("maps/mp_maps/fx_mp_water_drip_xlight_long");	
	level._effect["fx_water_drip_light_short"]				= loadfx("maps/mp_maps/fx_mp_water_drip_xlight_short");
	level._effect["fx_water_faucet_drip_fast"]				= loadfx("env/water/fx_water_faucet_drip_fast");		

	level._effect["fx_mp_distortion_heat_field_lg"]		= loadfx("maps/mp_maps/fx_mp_distortion_heat_field_lg");		
	level._effect["fx_mp_distortion_heat_field_sm"]		= loadfx("maps/mp_maps/fx_mp_distortion_heat_field_sm");
	level._effect["fx_mp_sand_blowing_lg"]						= loadfx("maps/mp_maps/fx_mp_sand_blowing_lg2");	
	level._effect["fx_mp_sand_blowing_xlg"]						= loadfx("maps/mp_maps/fx_mp_sand_blowing_xlg");
	level._effect["fx_mp_sand_blowing_xlg_distant"]		= loadfx("maps/mp_maps/fx_mp_sand_blowing_xlg_distant");
	level._effect["fx_mp_sand_windy_slow_sm_os"]			= loadfx("maps/mp_maps/fx_mp_sand_windy_slow_sm_os");	

	level._effect["fx_dust_crumble_int_sm"]						= loadfx("env/dirt/fx_dust_crumble_int_sm");
	level._effect["fx_dust_crumble_int_md"]						= loadfx("env/dirt/fx_dust_crumble_int_md");
	level._effect["fx_dust_crumble_int_lg"]						= loadfx("env/dirt/fx_dust_crumble_int_lg");

	level._effect["fx_mp_light_dust_motes_md"]				= loadfx("maps/mp_maps/fx_mp_light_dust_motes_md");
	level._effect["fx_mp_light_dust_motes_falling"]		= loadfx("maps/mp_maps/fx_mp_light_dust_motes_falling");
	
	level._effect["fx_mp_elec_spark_burst_sm"]				= loadfx("maps/mp_maps/fx_mp_elec_spark_burst_sm");
	level._effect["fx_mp_elec_spark_burst_xsm_thin"]	= loadfx("maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin");
	
	level._effect["fx_light_beacon_red"]							= loadfx("env/light/fx_light_beacon_red_sm");
	level._effect["fx_light_tinhat_cage_white"]				= loadfx("env/light/fx_light_tinhat_cage_white");	
	level._effect["fx_mp_outskirts_floures_glow1"]		=	loadfx("maps/mp_maps/fx_mp_outskirts_floures_glow_1");
	level._effect["fx_mp_light_diner_sign"]						=	loadfx("maps/mp_maps/fx_mp_light_diner_sign");	
	level._effect["fx_mp_light_motel_sign"]						=	loadfx("maps/mp_maps/fx_mp_light_motel_sign");
	level._effect["fx_mp_light_motel_sign_back"]			=	loadfx("maps/mp_maps/fx_mp_light_motel_sign_back");				
	level._effect["fx_mp_light_office_sign"]					=	loadfx("maps/mp_maps/fx_mp_light_office_sign_glow");
	level._effect["fx_light_wall_sconce_outdoor_yellow"]= loadfx("env/light/fx_light_wall_sconce_outdoor_yellow");	
	level._effect["fx_mp_outskirts_spotlight_glow_1"]	=	loadfx("maps/mp_maps/fx_mp_outskirts_spotlight_glow_1");
	level._effect["fx_light_pent_ceiling_light"]			= loadfx("env/light/fx_light_pent_ceiling_light");
	level._effect["fx_light_floodlight_int_yllw_sqr"]	= loadfx("env/light/fx_light_floodlight_int_yllw_sqr");		

	level._effect["fx_light_godray_md_warm"]					= loadfx("maps/mp_maps/fx_mp_light_gray_solid_md");
	level._effect["fx_light_godray_sm_warm"]					= loadfx("maps/mp_maps/fx_mp_light_gray_solid_sm");

	level._effect["fx_light_road_flare"]							= loadfx("env/light/fx_light_road_flare");

	level._effect["fx_truck_headlight"] 					    = loadfx("maps/mp_maps/fx_mp_light_truck_headlight");	
	level._effect["fx_smoke_exhaust_truck"] 				  = loadfx("maps/mp_maps/fx_mp_smk_exhaust_3");	
	level._effect["fx_distortion_heat_truck"] 				= loadfx("maps/mp_maps/fx_mp_distortion_heat_engine");
	level._effect["fx_police_light"] 									= loadfx("vehicle/light/fx_police_car_beacon_red");
	level._effect["fx_light_beacon_yllw_police_horse"]= loadfx("env/light/fx_light_beacon_yllw_police_horse");

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

	maps\mp\createfx\mp_gridlock_fx::main();
	maps\mp\createart\mp_gridlock_art::main();
	
	wind_initial_setting();
}


