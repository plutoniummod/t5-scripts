#include maps\mp\_utility;

main()
{
	precache_util_fx();
	precache_createfx_fx();
	precache_scripted_fx();
	precache_fx_prop_anims();
	maps\mp\createfx\mp_kowloon_fx::main();
	maps\mp\createart\mp_kowloon_art::main();

	SetDvar( "enable_global_wind", 1 );
	SetDvar( "wind_global_vector", "-110 -150 -110" );
	SetDvar( "wind_global_low_altitude", -175 );
	SetDvar( "wind_global_hi_altitude", 4000 );
	SetDvar( "wind_global_low_strength_percent", .5 );
}

// fx prop anim effects
#using_animtree ( "fxanim_props_dlc2" );
precache_fx_prop_anims()
{
	level.kowloon_fxanims = [];
	level.kowloon_fxanims[ "mp_fish_tank01_anim" ] = %fxanim_mp_fish_tank01_anim;
}


// Ambient effects
precache_createfx_fx()
{
	level._effect["fx_mp_kowloon_lightning_runner"]					= loadfx("maps/mp_maps/fx_mp_kowloon_lightning_runner");
	level._effect["fx_rain_downpour_looping_md"]						= LoadFx("env/weather/fx_rain_downpour_looping_md");
	level._effect["fx_mp_rain_fog_wall"]										= LoadFx("maps/mp_maps/fx_mp_rain_fog_wall");
	level._effect["fx_mp_water_roof_spill_md_hvy"]					= loadfx("maps/mp_maps/fx_mp_water_roof_spill_md_hvy");
	level._effect["fx_mp_water_roof_spill_md_hvy_long"]			= loadfx("maps/mp_maps/fx_mp_water_roof_spill_md_hvy_long");
	level._effect["fx_mp_water_roof_spill_lg_hvy"]					= LoadFx("maps/mp_maps/fx_mp_water_roof_spill_lg_hvy");
	level._effect["fx_mp_water_roof_spill_lg_hvy_long"]			= LoadFx("maps/mp_maps/fx_mp_water_roof_spill_lg_hvy_long");
	level._effect["fx_mp_water_roof_spill_lg_hvy_shrt"]			= LoadFx("maps/mp_maps/fx_mp_water_roof_spill_lg_hvy_shrt");
	level._effect["fx_mp_water_drip_long"]									= loadfx("maps/mp_maps/fx_mp_water_drip_long");
	level._effect["fx_water_spill_sm"]											= loadfx("env/water/fx_water_spill_sm");
	level._effect["fx_water_spill_sm_thin"]									= loadfx("env/water/fx_water_spill_sm_thin");

	level._effect["fx_water_spill_sm_splash"]								= loadfx("maps/mp_maps/fx_mp_water_spill_sm_splash");
	level._effect["fx_water_spill_splash_wide"]							= loadfx("env/water/fx_water_spill_splash_wide");
	level._effect["fx_mp_rain_splash_area_50_hvy_lp"]				= LoadFx("maps/mp_maps/fx_mp_rain_splash_area_50_hvy_lp");
	level._effect["fx_mp_rain_splash_area_50x150"]					= loadfx("maps/mp_maps/fx_mp_rain_splash_area_50x150");
	level._effect["fx_mp_rain_splash_area_100_hvy_lp"]			= LoadFx("maps/mp_maps/fx_mp_rain_splash_area_100_hvy_lp");
	level._effect["fx_mp_rain_splash_area_200_hvy_lp"]			= LoadFx("maps/mp_maps/fx_mp_rain_splash_area_200_hvy_lp");
	level._effect["fx_mp_rain_splash_area_300_hvy_lp"]			= LoadFx("maps/mp_maps/fx_mp_rain_splash_area_300_hvy_lp");
	level._effect["fx_mp_rain_splash_area_400_hvy_lp"]			= LoadFx("maps/mp_maps/fx_mp_rain_splash_area_400_hvy_lp");
	level._effect["fx_mp_rain_splash_area_500_hvy_lp"]			= LoadFx("maps/mp_maps/fx_mp_rain_splash_area_500_hvy_lp");

	level._effect["fx_mp_smk_tin_hat_chimney_sm"]						= LoadFx("maps/mp_maps/fx_mp_smk_tin_hat_chimney_sm");

	level._effect["fx_sign_glow1"]													= loadfx("maps/mp_maps/fx_mp_light_sign1_glow_kowloon");
	level._effect["fx_sign_glow2"]													= loadfx("maps/mp_maps/fx_mp_light_sign2_glow_kowloon");
	level._effect["fx_sign_glow2_tall"]											= loadfx("maps/mp_maps/fx_mp_light_sign2_glow_kowloon_tall");
	level._effect["fx_sign_glow3"]													= loadfx("maps/mp_maps/fx_mp_light_sign3_glow_kowloon");
	level._effect["fx_light_sign4_glow"]										= loadfx("maps/mp_maps/fx_mp_light_sign4_glow_kowloon");
	level._effect["fx_sign_glow5"]													= loadfx("maps/mp_maps/fx_mp_light_sign5_glow_kowloon");


	level._effect["fx_insects_swarm_md_light"]							= loadfx("bio/insects/fx_insects_swarm_md_light");

  level._effect["fx_mp_fumes_haze_md"]										= loadfx("maps/mp_maps/fx_mp_fumes_haze_md");

  level._effect["fx_fog_interior_md"]											= loadfx("maps/mp_maps/fx_mp_fog_interior_md");
  level._effect["fx_mp_smk_vent_xlg"]											= loadfx("maps/mp_maps/fx_mp_smk_vent_xlg");
  level._effect["fx_mp_smk_vent_xxlg"]										= loadfx("maps/mp_maps/fx_mp_smk_vent_xxlg");

	level._effect["fx_mp_elec_spark_burst_lg"]							= loadfx("maps/mp_maps/fx_mp_elec_spark_burst_lg");
	
	level._effect["fx_mp_zipline_light"]										= loadfx("maps/mp_maps/fx_mp_zipline_light");
	
	level._effect["fx_water_aquarium_bubbles"]							= loadfx("env/water/fx_water_aquarium_bubbles");
	level._effect["fx_water_aquarium_pump"]									= loadfx("env/water/fx_water_aquarium_pump");
	level._effect["fx_mp_water_faucet_drip"]								= loadfx("maps/mp_maps/fx_mp_water_faucet_drip");
	level._effect["fx_fog_ice_cream_bin"]										= loadfx("env/smoke/fx_fog_ice_cream_bin");
	level._effect["fx_mp_smk_linger"]												= loadfx("maps/mp_maps/fx_mp_smk_linger");
	level._effect["fx_ray_spread_sm_1sd"]										= loadfx("env/light/fx_ray_spread_sm_1sd");
	level._effect["fx_mp_elec_spark_burst_sm_runner"]				= loadfx("maps/mp_maps/fx_mp_elec_spark_burst_sm_runner");
	level._effect["fx_mp_elec_spark_burst_xsm_thin_runner"]	= loadfx("maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin_runner");
	level._effect["fx_pipe_steam_sm_slow"]									= loadfx("env/smoke/fx_pipe_steam_sm_slow");
	level._effect["fx_mp_steam_vent_sm"]										= loadfx("maps/mp_maps/fx_mp_steam_vent_sm");
	level._effect["fx_env_ray_window_md_warm"]							= loadfx("env/light/fx_env_ray_window_md_warm");
	level._effect["fx_mp_kowloon_grate_light"]							= loadfx("maps/mp_maps/fx_mp_kowloon_grate_light");
	level._effect["fx_light_hue_ray_street"]								= loadfx("maps/mp_maps/fx_mp_kowloon_street_light");
	
	level._effect["fx_mp_kowloon_fog_distant"]							= loadfx("maps/mp_maps/fx_mp_kowloon_fog_distant");
	level._effect["fx_mp_kowloon_fog_distant_sm"]						= loadfx("maps/mp_maps/fx_mp_kowloon_fog_distant_sm");
	
	level._effect["fx_mp_kowloon_light_overhead"]						= loadfx("maps/mp_maps/fx_mp_kowloon_light_overhead");
	
	// Exploders
	level._effect["fx_mp_kowloon_rain_skylight"]						= loadfx("maps/mp_maps/fx_mp_kowloon_rain_skylight");	// 101


}


// Scripted effects
precache_scripted_fx()
{
	level.fx_local_heli_rain											= loadfx("maps/mp_maps/fx_mp_kowloon_heli_rain");
}

// fx used by utility scripts
precache_util_fx()
{
}