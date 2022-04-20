////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL SCRIPTS
// 
//
//
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include maps\_utility;
#include maps\_anim;
#include common_scripts\utility;


////////////////////////////////////////////////////////////////////////////////////////////
// MAIN FUNCTION
////////////////////////////////////////////////////////////////////////////////////////////

#using_animtree("fxanim_props");


// fx used by util scripts
precache_util_fx()
{
	
}

// Scripted effects
precache_scripted_fx() 
{
	//Vomit
	level._effect["vomit_exp"]	= LoadFX("maps/flashpoint/fx_vomit_projectile");
	
	
	//-- FX
	//level._effect["fuel_fire"]	= LoadFX("env/fire/fx_fire_md_fuel");
	//level._effect["large_exp"]	= LoadFX("explosions/fx_exp_aerial_lg");
	//level._effect["fire_med"]	= LoadFX("env/fire/fx_fire_md_fuel");
	
	level._effect["vehicle_explosion"]	= LoadFX("explosions/fx_large_vehicle_explosion");
	//level._effect["vehicle_fire"]	= LoadFX("explosions/fx_large_vehicle_explosion");
		
	// TEMP
	//level._effect["midair_exp"]	= LoadFX( "temp_effects/fx_tmp_exp_midair_large" );
	//level._effect["midair_exp_xlrg"]	= LoadFX( "temp_effects/fx_tmp_exp_midair_xlarge" );
	//level._effect["veh_exp"]	= LoadFX( "explosions/fx_large_vehicle_explosion" );
	
	//level._effect["tear_gas"]	= LoadFX( "weapon/grenade/fx_gas_tear" );
	//level._effect["tear_gas_loop"]	= LoadFX( "maps/flashpoint/fx_gas_tear_cloud_looping" );
	
	// level._effect["pipe_steam"]	= LoadFX( "destructibles/fx_dest_pipe_steam" );
	// level._effect["pipe_fire"]	= LoadFX( "destructibles/fx_dest_pipe_fire" );
			
	// Rocket Takeoff
	level._effect["rocket_blast"]	= LoadFX("maps/flashpoint/fx_russian_rocket_exhaust");
	level._effect["rocket_exp_1"]			= loadfx("maps/flashpoint/fx_exp_rocket_stage_1");
	level._effect["rocket_exp_2"]			= loadfx("maps/flashpoint/fx_exp_rocket_stage_2");
	level._effect["rocket_top_trail"]	= loadfx("maps/flashpoint/fx_rocket_top_trail");
	//level._effect["rocket_coolant"]	= LoadFX("maps/flashpoint/fx_space_rocket_coolant");	// should not be used
	//level._effect["rocket_explosion"]	= LoadFX("maps/flashpoint/fx_exp_rocket_soyuz");	// should not be used
	level._effect["rocket_launch_dist"]	= LoadFX("maps/flashpoint/fx_russian_rocket_exhaust_dist");
	//level._effect["rocket_launch_base_dist"]	= LoadFX("maps/flashpoint/fx_rocket_launch_dist_smoke");	// should not be used
	level._effect["rocket_glare"]	= LoadFX("vehicle/exhaust/fx_russian_rocket_exhaust_glare_mp");
	//level._effect["rocket_engine"]	= LoadFX("vehicle/exhaust/fx_russian_rocket_exhaust_fla");	// should not be used
	
	// Helicopter
	//level._effect["smoke_trail"]	= LoadFX("trail/fx_trail_plane_smoke_damage");
	
	// Rocket debris
	// level._effect["falling_debris_lg"]	= LoadFX("maps/flashpoint/fx_falling_debris_area_lg");
	// level._effect["falling_debris_sm"]	= LoadFX("maps/flashpoint/fx_falling_debris_area_sm");
	// level._effect["falling_debris_single"]	= LoadFX("maps/flashpoint/fx_falling_debris_single_lg");
	// level._effect["debris_trail_lg"]	= LoadFX("maps/flashpoint/fx_falling_debris_trail_lg");
	// level._effect["debris_embers"]	= LoadFX("maps/flashpoint/fx_falling_debris_embers_lg");
	//level._effect["anim_trail_lg"]	= LoadFX("maps/flashpoint/fx_anim_debris_trail_lg");	// no longer necessary
	//level._effect["anim_trail_md"]	= LoadFX("maps/flashpoint/fx_anim_debris_trail_md");	// no longer necessary
	
	//Elevator fall
	level._effect["elevator_fall"]	= loadfx("maps/flashpoint/fx_elevator_fall");
	
	// UAZ
	level._effect[ "uaz_exhaust" ]	= LoadFX( "vehicle/exhaust/fx_exhaust_jeep_uaz" );
	level._effect[ "uaz_headlight" ]	= LoadFX( "vehicle/light/fx_jeep_uaz_headlight" );
	level._effect[ "uaz_taillight" ]	= LoadFX( "vehicle/light/fx_jeep_uaz_taillight" );
	
	// Kristina window
	//level._effect[ "kristina_window" ]	= LoadFX( "maps/flashpoint/fx_window_break_kristina" );
	level._effect[ "zipline_whoosh" ] = LoadFX( "env/weather/fx_zipline_whoosh" );
	
	// MiGs
	level._effect[ "jet_trail" ]	= LoadFX( "trail/fx_geotrail_jet_contrail" );
	level._effect[ "jet_exhaust" ]	= LoadFX( "vehicle/exhaust/fx_exhaust_jet_afterburner" );
	
	// Light Tower - these have been made into exploders
	//level._effect[ "light_tower" ]	= LoadFX( "maps/flashpoint/fx_tower_light_glow" );
	level._effect[ "light_tower_exp" ]	= LoadFX( "maps/flashpoint/fx_tower_light_exp" );
	
	// Weaver / Krav Scene
	level._effect[ "eye_blood" ] = LoadFX( "maps/flashpoint/fx_blood_eye_spurt" );
	
	// Karambit
	level._effect["karambit_stand_blood"] = LoadFX( "maps/flashpoint/fx_karambit_blood" );
	level._effect["body_dragging_dust"] = LoadFX( "maps/flashpoint/fx_sand_body_drag" );
	
	level._effect["enemy_on_fire"] = LoadFx("env/fire/fx_fire_player_torso");
	
	level.fake_muzzleflash	= loadfx ("weapon/muzzleflashes/fx_standard_flash");
	
	// Diorama scripted effects
	level._effect["fx_diorama_muzflash_rifle"]					= loadfx("maps/flashpoint/fx_diorama_muzflash_rifle");

	level._effect["slide_muzzle_flash"] = LoadFX( "maps/flashpoint/fx_diorama_muzflash_rifle" );

	//TEMP - shabs - until we get our animated fx for limo
	//level._effect["fx_glass_rappel_window_smash"]			= LoadFX("maps/kowloon/fx_glass_rappel_window_smash"); // 3501
	//level._effect["fire_ground"]							= LoadFX("env/fire/fx_fire_barrel_small");
	//level._effect["wire_sparks"] 							= LoadFX("env/electrical/fx_elec_wire_spark_burst");
	//level._effect["wire_sparks_no_smoke"] 				= LoadFX("env/electrical/fx_elec_wire_sparks");
	level._effect["test_pulse_fx"] = LoadFX( "env/light/fx_light_gen_pulse_red" );
	level._effect["test_spin_fx"] = LoadFX( "env/light/fx_light_warning");
}

// Ambient effects
precache_createfx_fx()
{
	level._effect["fx_tunnel_end_steam"]							= loadfx("maps/flashpoint/fx_tunnel_end_steam");
	level._effect["fx_gantry_coolant_xlg"]						= loadfx("maps/flashpoint/fx_gantry_coolant_xlg");
	level._effect["fx_coolant_pool_cloud"]						= loadfx("maps/flashpoint/fx_coolant_pool_cloud");
	level._effect["fx_gantry_light"]									= loadfx("maps/flashpoint/fx_gantry_light");
	// level._effect["fx_clouds_rocket_cover"]						= loadfx("maps/flashpoint/fx_clouds_rocket_cover");
	
	level._effect["fx_sand_windy_heavy_md_drop"]			= loadfx("env/weather/fx_sand_windy_heavy_md_drop");
	level._effect["fx_distortion_heat_pipe_lg"]				= loadfx("env/distortion/fx_distortion_heat_pipe_lg");
	
	// Exploders
	// All full-speed ambient effects in diorama areas:																																 50
	level._effect["fx_heli_hover_os"]									= loadfx("maps/flashpoint/fx_heli_hover_os");									// 101, 210
	level._effect["fx_metal_dust_loosen_os"]					= loadfx("maps/flashpoint/fx_metal_dust_loosen_os");					// 101, 103
	level._effect["fx_pigeon_panic_flight_med"]				= loadfx("bio/animals/fx_crows_panic_flight_med_left");				// 102
	//level._effect["fx_sand_impact_sm"]								= loadfx("env/dirt/fx_sand_impact_sm");												// 105
	level._effect["fx_rocket_launch_base"]						= loadfx("maps/flashpoint/fx_rocket_launch_dist_smoke");			// 110
	level._effect["fx_rocket_launch_dist_shockwave"]	= loadfx("maps/flashpoint/fx_rocket_launch_dist_shockwave");	// 110
	level._effect["fx_clouds_rocket_cover_lit"]				= loadfx("maps/flashpoint/fx_clouds_rocket_cover_lit");				// 112
	level._effect["fx_gantry_light_flashing"]					= loadfx("maps/flashpoint/fx_gantry_light_flashing");					// 120
	level._effect["fx_tower_light_glow"]							= loadfx("maps/flashpoint/fx_tower_light_glow");							// 121
	// camera on Weaver is at (-3726 -2325 328) : 121 1, FOV is 2(?)
	level._effect["fx_distance_shimmer"]							= loadfx("maps/flashpoint/fx_helipad_shimmer");
	
	level._effect["fx_rocket_booster_condensation"]		= loadfx("maps/flashpoint/fx_rocket_booster_condensation");		// 201
	level._effect["fx_space_rocket_coolant"]					= loadfX("maps/flashpoint/fx_space_rocket_coolant");					// 201
	level._effect["fx_coolant_blastpad_cloud"]				= loadfx("maps/flashpoint/fx_coolant_blastpad_cloud");				// 201
	level._effect["fx_coolant_blastpad_cloud_spill"]	= loadfx("maps/flashpoint/fx_coolant_blastpad_cloud_spill");	// 201
	level._effect["fx_falling_debris_area_sm_ice"]		= loadfx("maps/flashpoint/fx_falling_debris_area_sm_ice");		// 201
	
	level._effect["fx_jet_dust_wake_2"]								= loadfx("maps/flashpoint/fx_jet_dust_wake_2");								// 320
	
	level._effect["fx_door_breach_kick"]							= loadfx("maps/flashpoint/fx_door_breach_kick");							// 501
	
	level._effect["fx_zipline_window_crash"]					= loadfx("maps/flashpoint/fx_zipline_window_crash");					// 601
	level._effect["fx_debris_papers_windy_os"]				= loadfx("env/debris/fx_debris_papers_windy_os");							// 601
	// sniper dust tell: 610-624
	level._effect["fx_exp_vehicle_gen"]								= loadfx("explosions/fx_exp_vehicle_gen");										// 701
	
	level._effect["fx_exp_control_room_wall"]					= loadfx("maps/flashpoint/fx_exp_control_room_wall");					// 800
	level._effect["fx_rocket_launch_trench_smoke"]		= loadfx("maps/flashpoint/fx_rocket_launch_trench_smoke");		// 801
	level._effect["fx_rocket_launch_dust"]						= loadfx("maps/flashpoint/fx_rocket_launch_dust");						// 801
	//level._effect["fx_tower_light_exp"]								= loadfx("maps/flashpoint/fx_tower_light_exp");								// 804
	level._effect["fx_impact_dust_antenna_lg"]				= loadfx("maps/flashpoint/fx_impact_dust_antenna_lg");				// 805
	level._effect["fx_rocket_ground_exp_lg"]					= loadfx("maps/flashpoint/fx_rocket_booster_impact_exp");			// 808
	level._effect["fx_falling_debris_area_sm_dirt"]		= loadfx("maps/flashpoint/fx_falling_debris_area_sm_dirt");		// 808
	level._effect["fx_rocket_ground_exp_sm"]					= loadfx("maps/flashpoint/fx_rocket_top_impact_exp");					// 810
	level._effect["fx_rocket_debris_impact_dirt"]			= loadfx("maps/flashpoint/fx_rocket_debris_impact_dirt");			// 820
	level._effect["fx_rocket_debris_impact_fence"]		= loadfx("maps/flashpoint/fx_rocket_debris_impact_fence");		// 825
	level._effect["fx_rocket_debris_impact_wall"]			= loadfx("maps/flashpoint/fx_rocket_debris_impact_wall");			// 830
		// rocket_debris_fire_start																																										// 835
	level._effect["fx_falling_debris_single_lg"]			= loadfx("maps/flashpoint/fx_falling_debris_single_lg");	// 840-846
		// debris blocks path to rocket									// 840
		// debris hits entrance to launch pad						// 841
		// debris hits launch pad top										// 842
		// debris hits blast pad												// 843
		// debris hits near rocket_debris_fire_start		// 844
		// debris hits far side of flame trench					// 845
		// debris hits above bunker entrance to event 9	// 846
	// Elevator impact and smoke poof:																																								 910
	
	// Scene 1: -11360 284 -75 212 17
	level._effect["fx_diorama_glass_shatter"]					= loadfx("maps/flashpoint/fx_diorama_glass_shatter");					// 1310
	level._effect["fx_diorama_tracer_group"]					= loadfx("maps/flashpoint/fx_diorama_tracer_group");
	level._effect["fx_diorama_tracer"]								= loadfx("maps/flashpoint/fx_diorama_tracer");
	level._effect["fx_diorama_blood_impact"]					= loadfx("maps/flashpoint/fx_diorama_blood_impact");
	// Scene 2: -4217 -2125 385 344 17
	level._effect["fx_diorama_windshield_impact"]			= loadfx("maps/flashpoint/fx_diorama_windshield_impact");			// 1320
	// Scene 3: -3016 -521 348 349 352
	level._effect["fx_diorama_veh_dust_cloud"]				= loadfx("maps/flashpoint/fx_diorama_veh_dust_cloud");				// 1330
	level._effect["fx_diorama_impact_dirt"]						= loadfx("maps/flashpoint/fx_diorama_impact_dirt");
	level._effect["fx_diorama_jet_trail"]							= loadfx("maps/flashpoint/fx_diorama_jet_trail");
	// Scene 4: 488 -4147 414 157 0
	level._effect["fx_diorama_launchpad_smk"]					= loadfx("maps/flashpoint/fx_diorama_launchpad_smk");					// 1340
	level._effect["fx_diorama_car_fire"]							= loadfx("maps/flashpoint/fx_diorama_car_fire");
	// Scene 5: 418 -5888 1460 241 33 to 270 -6137 1289 244 36
	level._effect["fx_diorama_heli_dust"]							= loadfx("maps/flashpoint/fx_diorama_heli_dust");							// 1350
	
	level._effect["fx_sand_cloud_dist"]								= loadfx("maps/flashpoint/fx_sand_cloud_dist");
	level._effect["fx_sand_windy_fast_sm"]						= loadfx("env/weather/fx_sand_windy_fast_sm");
	level._effect["fx_sand_windy_fast_door_os"]				= loadfx("env/weather/fx_sand_windy_fast_door_os");
	level._effect["fx_sand_windy_heavy_sm"]						= loadfx("env/weather/fx_sand_windy_heavy_sm");
	level._effect["fx_sand_windy_heavy_md"]						= loadfx("env/weather/fx_sand_windy_heavy_md");
	// level._effect["fx_sand_windy_heavy"]							= loadfx("env/weather/fx_sand_windy_heavy");
	level._effect["fx_sand_shifting_distant"]					= loadfx("env/weather/fx_sand_shifting_distant");
	level._effect["fx_distortion_fumes_md"]						= loadfx("env/distortion/fx_distortion_fumes_md");
	level._effect["fx_smk_plume_md_wht_wispy"]				= loadfx("env/smoke/fx_smk_plume_md_wht_wispy");
	level._effect["fx_pipe_steam_md"]									= loadfx("env/smoke/fx_pipe_steam_md");
	level._effect["fx_water_spray_leak_md"]						= loadfx("env/water/fx_water_spray_leak_md");
	level._effect["fx_water_spray_leak_sm"]						= loadfx("env/water/fx_water_spray_leak_sm");
	level._effect["fx_sand_windy_lit"]								= loadfx("env/weather/fx_sand_windy_lit");
	level._effect["fx_steam_hallway_md"]							= loadfx("env/smoke/fx_steam_hallway_md");
	// level._effect["fx_pipe_steam_md_runner"]					= loadfx("env/smoke/fx_pipe_steam_md_runner");
	level._effect["fx_quinn_steam_blast_lg"]					= loadfx("maps/underwaterbase/fx_uwb_steam_blast_lg");
	level._effect["fx_elec_burst_heavy_os_int"]				= loadfx("env/electrical/fx_elec_burst_heavy_os_int");
	// level._effect["fx_elec_burst_shower_sm_os_int"]		= loadfx("env/electrical/fx_elec_burst_shower_sm_os_int");
	
	// level._effect["fx_fire_sm_fuel"]									= loadfx("env/fire/fx_fire_sm_fuel");
	level._effect["fx_fire_line_sm"]									= loadfx("env/fire/fx_fire_line_sm");
	level._effect["fx_fire_line_md"]									= loadfx("env/fire/fx_fire_line_md");
	level._effect["fx_fire_line_lg_dist"]							= loadfx("env/fire/fx_fire_line_lg_dist");
	level._effect["fx_fire_sm_smolder"]								= loadfx("env/fire/fx_fire_sm_smolder");
	// level._effect["fx_fire_md_smolder"]								= loadfx("env/fire/fx_fire_md_smolder");
	level._effect["fx_smk_plume_md_wht_wispy"]				= loadfx("env/smoke/fx_smk_plume_md_wht_wispy");
	level._effect["fx_smk_plume_xlg_wht"]							= loadfx("env/smoke/fx_smk_plume_xlg_wht");
	level._effect["fx_smk_plume_xlg_blk"]							= loadfx("env/smoke/fx_smk_plume_xlg_blk");
	
	level._effect["fx_smolder_mortar_crater"]					= loadfx("env/fire/fx_smolder_mortar_crater");
	// level._effect["fx_smk_fire_md_gray"]							= loadfx("env/smoke/fx_smk_fire_md_gray");
	level._effect["fx_smk_fire_md_black"]							= loadfx("env/smoke/fx_smk_fire_md_black");
	
	// level._effect["fx_light_floodlight_dim"]					= loadfx("env/light/fx_light_floodlight_dim");
	level._effect["fx_light_floodlight_bright"]				= loadfx("env/light/fx_light_floodlight_bright");
	level._effect["fx_light_overhead"]								= loadfx("env/light/fx_light_overhead");
	level._effect["fx_fluorescent_flare"]							= loadfx("env/light/fx_fluorescent_flare");
	level._effect["fx_ray_sm_1sd"]										= loadfx("env/light/fx_ray_sm_1sd");
	// level._effect["fx_ray_md_1sd"]										= loadfx("env/light/fx_ray_md_1sd");
	level._effect["fx_ray_spread_sm_1sd"]							= loadfx("env/light/fx_ray_spread_sm_1sd");
	level._effect["fx_ray_spread_md_1sd"]							= loadfx("env/light/fx_ray_spread_md_1sd");
	level._effect["fx_light_godray_overcast_sm"]			= loadfx("env/light/fx_light_godray_overcast_sm");
	level._effect["fx_light_dust_motes_xsm_short"]		= loadfx("env/light/fx_light_dust_motes_xsm_short");
	level._effect["fx_light_dust_motes_xsm"]					= loadfx("env/light/fx_light_dust_motes_xsm");
	level._effect["fx_light_dust_motes_sm"]						= loadfx("env/light/fx_light_dust_motes_sm");
	level._effect["fx_light_dust_motes_xsm_wide"]			= loadfx("env/light/fx_light_dust_motes_xsm_wide");
	level._effect["fx_smk_linger_lit"]								= loadfx("env/smoke/fx_smk_linger_lit");
	level._effect["fx_smk_linger_lit_fast"]						= loadfx("env/smoke/fx_smk_linger_lit_fast");

}

// FXanim Props
initModelAnims()
{

	level.scr_anim["fxanim_props"]["a_trespassing"] = %fxanim_flash_trespassing_anim;
	level.scr_anim["fxanim_props"]["a_sheetmetal"] = %fxanim_flash_sheetmetal_anim;
	level.scr_anim["fxanim_props"]["a_rockettarp"] = %fxanim_flash_rockettarp_anim;
	level.scr_anim["fxanim_props"]["a_lighttower"] = %fxanim_flash_lighttower_anim;
	level.scr_anim["fxanim_props"]["a_cloth01"] = %fxanim_gp_cloth01_anim;
	level.scr_anim["fxanim_props"]["a_rocket_launch"] = %fxanim_flash_rocket_launch_anim;
	level.scr_anim["fxanim_props"]["a_rocket_explode"] = %fxanim_flash_rocket_explode_anim;
	level.scr_anim["fxanim_props"]["a_rocket_panel_rattle_01"] = %fxanim_flash_rocket_panel_rattle_01_anim;
	level.scr_anim["fxanim_props"]["a_rocket_panel_rattle_02"] = %fxanim_flash_rocket_panel_rattle_02_anim;
	level.scr_anim["fxanim_props"]["a_wire_sway_01_slow"] = %fxanim_gp_wire_sway_01_slow_anim;
	level.scr_anim["fxanim_props"]["a_wire_sway_02_slow"] = %fxanim_gp_wire_sway_02_slow_anim;
	level.scr_anim["fxanim_props"]["a_wire_sway_03_slow"] = %fxanim_gp_wire_sway_03_slow_anim;
	level.scr_anim["fxanim_props"]["a_wire_sway_04_slow"] = %fxanim_gp_wire_sway_04_slow_anim;
	level.scr_anim["fxanim_props"]["a_blast_deflector"] = %fxanim_gp_blast_deflector_down_anim;
	level.scr_anim["fxanim_props"]["a_windsock"] = %fxanim_gp_windsock_anim;
	level.scr_anim["fxanim_props"]["a_streamer01"] = %fxanim_gp_streamer01_anim;
	level.scr_anim["fxanim_props"]["a_streamer02"] = %fxanim_gp_streamer02_anim;
	level.scr_anim["fxanim_props"]["a_wall_smash"] = %fxanim_flash_rocket_wall_smash_anim;
	level.scr_anim["fxanim_props"]["a_wall_debris"] = %fxanim_flash_rocket_wall_debris_anim;
	level.scr_anim["fxanim_props"]["a_rocket_debris_fire"] = %fxanim_flash_rocket_debris_lrg_01_anim;
	level.scr_anim["fxanim_props"]["a_crow_fly_away"] = %fxanim_gp_crow_90rflyr_anim;
	level.scr_anim["fxanim_props"]["a_c4_bunker"] = %fxanim_flash_c4_bunker_anim;
	level.scr_anim["fxanim_props"]["a_ceiling_light_fall"] = %fxanim_flash_ceiling_light_fall_anim;
	level.scr_anim["fxanim_props"]["a_snake_coiled_loop"] = %fxanim_gp_snake_coiled_loop_anim;
	level.scr_anim["fxanim_props"]["a_snake_coiled_death"] = %fxanim_gp_snake_coiled_death_anim;
	level.scr_anim["fxanim_props"]["a_hide_body_tarp"] = %fxanim_flash_hide_body_tarp_anim;
	level.scr_anim["fxanim_props"]["a_hide_body_tarp_idle"] = %fxanim_flash_hide_body_tarp_idle_anim;
	level.scr_anim["fxanim_props"]["a_snake_slither"] = %fxanim_flash_snake_slither_anim;
	level.scr_anim["fxanim_props"]["a_table_throw"] = %fxanim_flash_table_throw_anim;
	level.scr_anim["fxanim_props"]["a_chunk_debris_01"] = %fxanim_flash_chunk01smb_anim;
	level.scr_anim["fxanim_props"]["a_chunk_debris_02"] = %fxanim_flash_chunk02lrgs_anim;
	level.scr_anim["fxanim_props"]["a_chunk_debris_03"] = %fxanim_flash_chunk02sms_anim;
	level.scr_anim["fxanim_props"]["a_chunk_debris_04"] = %fxanim_flash_chunk01lrgw_anim;
	level.scr_anim["fxanim_props"]["a_wirespark_long"] = %fxanim_gp_wirespark_long_anim;
	level.scr_anim["fxanim_props"]["a_wirespark_med"] = %fxanim_gp_wirespark_med_anim;		
	
	ent1 = getent( "fxanim_flash_trespassing_mod", "targetname" );
	ent2 = getent( "fxanim_flash_sheetmetal_mod", "targetname" );
	ent3 = getent( "fxanim_flash_rockettarp_mod", "targetname" );
	ent4 = getent( "fxanim_flash_lighttower_mod", "targetname" );
	ent5 = getent( "fxanim_gp_cloth01_mod", "targetname" );
	ent6 = getent( "fxanim_flash_rocket_mod", "targetname" );
	ent7 = getent( "fxanim_flash_rocket_panel_rattle_01_mod", "targetname" );
	ent8 = getent( "fxanim_flash_rocket_panel_rattle_02_mod", "targetname" );
	ent9 = getent( "fxanim_gp_blast_deflector_mod", "targetname" );
	ent10 = getent( "fxanim_flash_rocket_wall_smash_mod", "targetname" );
	ent11 = getent( "fxanim_flash_rocket_wall_debris_mod", "targetname" );
	ent12 = getent( "fxanim_flash_rocket_debris_fire", "targetname" );
	ent13 = getent( "fxanim_gp_crow_01", "targetname" );
	ent14 = getent( "fxanim_gp_crow_02", "targetname" );
	ent15 = getent( "fxanim_gp_crow_03", "targetname" );
	ent16 = getent( "fxanim_flash_c4_bunker_mod", "targetname" );
	ent17 = getent( "fxanim_gp_ceiling_light_02_mod", "targetname" );
	ent18 = getent( "fxanim_gp_snake_coiled_mod", "targetname" );
	ent19 = getent( "fxanim_flash_hide_body_tarp_mod", "targetname" );
	ent20 = getent( "fxanim_gp_snake_slither_mod", "targetname" );
	ent21 = getent( "fxanim_flash_reel_rack_mod", "targetname" );
	ent22 = getent( "table_throw_01", "targetname" );
	ent23 = getent( "table_throw_02", "targetname" );
	ent24 = getent( "flash_chunk_debris_01", "targetname" );
	ent25 = getent( "flash_chunk_debris_02", "targetname" );
	ent26 = getent( "flash_chunk_debris_03", "targetname" );
	ent27 = getent( "flash_chunk_debris_04", "targetname" );	
		
	enta_wire_sway_01 = getentarray( "fxanim_gp_wire_sway_01_mod", "targetname" );
	enta_wire_sway_02 = getentarray( "fxanim_gp_wire_sway_02_mod", "targetname" );
	enta_wire_sway_03 = getentarray( "fxanim_gp_wire_sway_03_mod", "targetname" );
	enta_wire_sway_04 = getentarray( "fxanim_gp_wire_sway_04_mod", "targetname" );
	enta_windsock = getentarray( "fxanim_gp_windsock_mod", "targetname" );
	enta_streamer01 = getentarray( "fxanim_gp_streamer01_mod", "targetname" );
	enta_streamer02 = getentarray( "fxanim_gp_streamer02_mod", "targetname" );
	enta_wirespark_long = getentarray( "fxanim_gp_wirespark_long_mod", "targetname" );
	enta_wirespark_med = getentarray( "fxanim_gp_wirespark_med_mod", "targetname" );	
	
		
	if (IsDefined(ent1)) 
	{
		ent1 thread trespassing();
		println("************* FX: trespassing *************");
	}
	
	if (IsDefined(ent2)) 
	{
		ent2 thread sheetmetal();
		println("************* FX: sheetmetal *************");
	}
	
	if (IsDefined(ent3)) 
	{
		ent3 thread rockettarp();
		println("************* FX: rockettarp *************");
	}
	
	if (IsDefined(ent4)) 
	{
		ent4 thread lighttower();
		println("************* FX: lighttower *************");
	}
	
	if (IsDefined(ent5)) 
	{
		ent5 thread cloth01();
		println("************* FX: cloth01 *************");
	}
	
	if (IsDefined(ent6)) 
	{
		ent6 thread rocket();
		println("************* FX: rocket *************");
	}
	
	if (IsDefined(ent7)) 
	{
		ent7 thread rocket_panel_rattle_01();
		println("************* FX: rocket_panel_rattle_01 *************");
	}
	
	if (IsDefined(ent8)) 
	{
		ent8 thread rocket_panel_rattle_02();
		println("************* FX: rocket_panel_rattle_02 *************");
	}
	
	for(i=0; i<enta_wire_sway_01.size; i++)
	{
 		enta_wire_sway_01[i] thread wire_sway_01(1,3);
 		println("************* FX: wire_sway_01 *************");
	}
	
	for(i=0; i<enta_wire_sway_02.size; i++)
	{
 		enta_wire_sway_02[i] thread wire_sway_02(1,3);
 		println("************* FX: wire_sway_02 *************");
	}
	
	for(i=0; i<enta_wire_sway_03.size; i++)
	{
 		enta_wire_sway_03[i] thread wire_sway_03(1,3);
 		println("************* FX: wire_sway_03 *************");
	}
	
	for(i=0; i<enta_wire_sway_04.size; i++)
	{
 		enta_wire_sway_04[i] thread wire_sway_04(1,3);
 		println("************* FX: wire_sway_04 *************");
	}
	
	if (IsDefined(ent9)) 
	{
		ent9 thread blast_deflector();
		println("************* FX: blast_deflector *************");
	}
	
	for(i=0; i<enta_windsock.size; i++)
	{
 		enta_windsock[i] thread windsock(1,5);
 		println("************* FX: windsock *************");
	}
	
	for(i=0; i<enta_streamer01.size; i++)
	{
 		enta_streamer01[i] thread streamer01(1,3);
 		println("************* FX: streamer01 *************");
	}
	
	for(i=0; i<enta_streamer02.size; i++)
	{
 		enta_streamer02[i] thread streamer02(1,3);
 		println("************* FX: streamer02 *************");
	}
	
		for(i=0; i<enta_wirespark_long.size; i++)
	{
 		enta_wirespark_long[i] thread wirespark_long(1,3);
 		println("************* FX: wirespark_long *************");
	}

	for(i=0; i<enta_wirespark_med.size; i++)
	{
 		enta_wirespark_med[i] thread wirespark_med(1,3);
 		println("************* FX: wirespark_med *************");
	}	
	
	if (IsDefined(ent10)) 
	{
		ent10 thread wall_smash();
		println("************* FX: wall_smash *************");
	}
	
	if (IsDefined(ent11)) 
	{
		ent11 thread wall_debris();
		println("************* FX: wall_debris *************");
	}
	
	if (IsDefined(ent12)) 
	{
		ent12 thread rocket_debris_fire();
		println("************* FX: rocket_debris_fire *************");
	}
	
	if (IsDefined(ent13)) 
	{
		ent13 thread crow_01();
		println("************* FX: crow_01 *************");
	}
	
	if (IsDefined(ent14)) 
	{
		ent14 thread crow_02();
		println("************* FX: crow_02 *************");
	}
	
	if (IsDefined(ent15)) 
	{
		ent15 thread crow_03();
		println("************* FX: crow_03 *************");
	}
	
	if (IsDefined(ent16)) 
	{
		ent16 thread c4_bunker();
		println("************* FX: c4_bunker *************");
	}
	
	if (IsDefined(ent17)) 
	{
		ent17 thread ceiling_light_fall();
		println("************* FX: ceiling_light_fall *************");
	}
	
	if (IsDefined(ent18)) 
	{
		ent18 thread snake_coiled();
		println("************* FX: snake_coiled *************");
	}
	
	if (IsDefined(ent19)) 
	{
		ent19 thread hide_body_tarp();
		println("************* FX: hide_body_tarp *************");
	}
	
	if (IsDefined(ent20)) 
	{
		ent20 thread snake_slither();
		println("************* FX: snake_slither *************");
	}

	if (IsDefined(ent21)) 
	{
		ent21 thread reel_rack();
		println("************* FX: reel_rack *************");
	}
	
	if (IsDefined(ent22)) 
	{
		ent22 thread table_throw_01();
		println("************* FX: table_throw_01 *************");
	}	
	
	if (IsDefined(ent23)) 
	{
		ent23 thread table_throw_02();
		println("************* FX: table_throw_02 *************");
	}		
	
	if (IsDefined(ent24)) 
	{
		ent24 thread chunk_debris_01();
		println("************* FX: chunk_debris_01 *************");
	}		
	
	if (IsDefined(ent25)) 
	{
		ent25 thread chunk_debris_02();
		println("************* FX: chunk_debris_01 *************");
	}	
	
	if (IsDefined(ent26)) 
	{
		ent26 thread chunk_debris_03();
		println("************* FX: chunk_debris_01 *************");
	}	
	
	if (IsDefined(ent27)) 
	{
		ent27 thread chunk_debris_04();
		println("************* FX: chunk_debris_01 *************");
	}					
}


trespassing()
{
	wait(1.0);
	self UseAnimTree(#animtree);
	anim_single(self, "a_trespassing", "fxanim_props");
}

sheetmetal()
{
	wait(1.0);
	self UseAnimTree(#animtree);
	anim_single(self, "a_sheetmetal", "fxanim_props");
}

rockettarp()
{
	wait(1.0);
	self UseAnimTree(#animtree);
	anim_single(self, "a_rockettarp", "fxanim_props");
}

lighttower()
{
	level waittill("lighttower_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_lighttower", "fxanim_props");
}

cloth01()
{
	wait(1.0);
	self UseAnimTree(#animtree);
	anim_single(self, "a_cloth01", "fxanim_props");
}


rocket_explode()
{
	level waittill( "rocket_hit" );
	anim_single(self, "a_rocket_explode", "fxanim_props");
}


//Check damage was from the player and they used the correct weapon
rocket_damage()
{	
	level endon( "rocket_hit" );

	while( 1 )
	{
		//self waittill( "damage" );//, damage, attacker, direction, point, method );
		self waittill( "damage", amount, attacker, direction, point, method );
		
		//Check we were holding the correct weapon
		activeWeapon = level.player GetCurrentWeapon();
	
		if( activeWeapon == "flashpoint_m220_tow_sp" )
		{
			level notify( "rocket_is_destroyed" );
			level notify( "rocket_hit" );
		}
		
		//kdrew - the rocket should only be destroyed by the tow missile or crossbow
		/*if( method == "MOD_IMPACT" && (activeWeapon == "crossbow_explosive_alt_sp") )
 		{
 			wait( 2.0 );
 			level notify( "rocket_is_destroyed" );
 			level notify( "rocket_is_destroyed_by_crossbow" );
 			level notify( "rocket_hit" );
 		}
 		
		if( method == "MOD_GRENADE" || method == "MOD_GRENADE_SPLASH" )
 		{
 			level notify( "rocket_is_destroyed" );
 			level notify( "rocket_is_destroyed_by_crossbow" );
 			level notify( "rocket_hit" );
 		}*/
	}
}




rocket()
{
	level waittill("rocket_launch_start");
	self UseAnimTree(#animtree);
	thread anim_single(self, "a_rocket_launch", "fxanim_props");

 	rocket_dyn_top = getent( "rocket_top_piece_orig", "targetname" );
	rocket_dyn_bottom = getent( "rocket_bottom_piece_orig", "targetname" );
	rocket_dyn_top_destroyed = getent( "rocket_top_piece", "targetname" );
	rocket_dyn_bottom_destroyed = getent( "rocket_bottom_piece", "targetname" );
	
 	self SetCanDamage(true);	
	rocket_dyn_top SetCanDamage(true);
	rocket_dyn_bottom SetCanDamage(true);
	rocket_dyn_top_destroyed SetCanDamage(true);
	rocket_dyn_bottom_destroyed SetCanDamage(true);
	
	//Wait for damage
 	rocket_dyn_top thread rocket_damage();
 	rocket_dyn_bottom thread rocket_damage();
 	rocket_dyn_top_destroyed thread rocket_damage();
 	rocket_dyn_bottom_destroyed thread rocket_damage();
 	self thread rocket_damage();
 	
 	//Wait for rocket hit
 	self thread rocket_explode();
}

rocket_panel_rattle_01()
{
	level waittill("rocket_panel_rattle_01_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_rocket_panel_rattle_01", "fxanim_props");
}

rocket_panel_rattle_02()
{
	level waittill("rocket_panel_rattle_02_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_rocket_panel_rattle_02", "fxanim_props");
}

wire_sway_01(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_wire_sway_01_slow", "fxanim_props");
}

wire_sway_02(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_wire_sway_02_slow", "fxanim_props");
}

wire_sway_03(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_wire_sway_03_slow", "fxanim_props");
}

wire_sway_04(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_wire_sway_04_slow", "fxanim_props");
}

blast_deflector()
{
	level waittill("deflector_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_blast_deflector", "fxanim_props");
}

windsock(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_windsock", "fxanim_props");
}

streamer01(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_streamer01", "fxanim_props");
}

streamer02(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_streamer02", "fxanim_props");
}

wall_smash()
{
	level waittill("wall_smash_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_wall_smash", "fxanim_props");
}

wall_debris()
{
	level waittill("wall_smash_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_wall_debris", "fxanim_props");
}

rocket_debris_fire()
{
	self Hide();
	level waittill("rocket_debris_fire_start");
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_rocket_debris_fire", "fxanim_props");
}

crow_01()
{
	level waittill("rocket_panel_rattle_01_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_crow_fly_away", "fxanim_props");
	self delete();
}

crow_02()
{
	level waittill("rocket_panel_rattle_01_start");
	wait(.2);
	self thread crow_delete();
	self UseAnimTree(#animtree);
	anim_single(self, "a_crow_fly_away", "fxanim_props");
}

crow_03()
{
	level waittill("rocket_panel_rattle_01_start");
	wait(.3);
	self thread crow_delete();
	self UseAnimTree(#animtree);
	anim_single(self, "a_crow_fly_away", "fxanim_props");	
}

crow_delete()
{
	wait (5);
	self delete();
}

c4_bunker()
{
	self Hide();
	level waittill("c4_bunker_start");
	
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_c4_bunker", "fxanim_props");
}

ceiling_light_fall()
{
	level waittill("ceiling_light_fall_start");
	self UseAnimTree(#animtree);
	self thread play_fall_sound();
	anim_single(self, "a_ceiling_light_fall", "fxanim_props");
}
play_fall_sound()
{
	wait(3);
	self playsound ("phy_impact_soft_metal");	
}
snake_coiled()
{
	wait(.3);
	self UseAnimTree(#animtree);
	anim_single(self, "a_snake_coiled_loop", "fxanim_props");
	self SetCanDamage(true);
	self waittill("damage");
	anim_single(self, "a_snake_coiled_death", "fxanim_props");	
}

hide_body_tarp()
{
	level waittill("hide_body_tarp_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_hide_body_tarp", "fxanim_props");
	anim_single(self, "a_hide_body_tarp_idle", "fxanim_props");
}

snake_slither()
{
	level waittill("rocket_panel_rattle_01_start");
	wait(8);
	self UseAnimTree(#animtree);
	anim_single(self, "a_snake_slither", "fxanim_props");
}

reel_rack()
{
	level waittill("reel_rack_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_reel_rack", "fxanim_props");
}

table_throw_01()
{
	level waittill("table_throw_01_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_table_throw", "fxanim_props");
}

table_throw_02()
{
	level waittill("table_throw_02_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_table_throw", "fxanim_props");
}

chunk_debris_01()
{
	self Hide();
	level waittill("chunk_debris_01_start");
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_chunk_debris_01", "fxanim_props");
}

chunk_debris_02()
{
	self Hide();
	level waittill("chunk_debris_01_start");
	wait(2);
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_chunk_debris_02", "fxanim_props");
}

chunk_debris_03()
{
	self Hide();
	level waittill("chunk_debris_03_start");
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_chunk_debris_03", "fxanim_props");
}

chunk_debris_04()
{
	self Hide();
	level waittill("chunk_debris_03_start");
	wait(2.5);
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_chunk_debris_04", "fxanim_props");
}

wirespark_long(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	while(1)
	{
		anim_single(self, "a_wirespark_long", "fxanim_props");
	}
}

wirespark_med(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	while(1)
	{
		anim_single(self, "a_wirespark_med", "fxanim_props");
	}
}


footsteps()
{
	animscripts\utility::setFootstepEffect( "asphalt",	LoadFx( "bio/player/fx_footstep_sand" ) );
	animscripts\utility::setFootstepEffect( "brick",		LoadFx( "bio/player/fx_footstep_sand" ) );
	animscripts\utility::setFootstepEffect( "concrete",	LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "dirt",			LoadFx( "bio/player/fx_footstep_sand_loose" ) );
	animscripts\utility::setFootstepEffect( "foliage",	LoadFx( "bio/player/fx_footstep_sand_loose" ) );
	animscripts\utility::setFootstepEffect( "gravel",		LoadFx( "bio/player/fx_footstep_sand" ) );
	animscripts\utility::setFootstepEffect( "grass",		LoadFx( "bio/player/fx_footstep_sand_loose" ) );
	animscripts\utility::setFootstepEffect( "metal",		LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "mud",			LoadFx( "bio/player/fx_footstep_sand_loose" ) );
	animscripts\utility::setFootstepEffect( "rock",			LoadFx( "bio/player/fx_footstep_sand" ) );
	animscripts\utility::setFootstepEffect( "sand",			LoadFx( "bio/player/fx_footstep_sand_loose" ) );
	//animscripts\utility::setFootstepEffect( "water",		LoadFx( "bio/player/fx_footstep_water" ) );
	animscripts\utility::setFootstepEffect( "wood",			LoadFx( "bio/player/fx_footstep_dust" ) );
}

wind_initial_setting()
{
SetSavedDvar( "wind_global_vector", "152 50 0" );    // change "0 0 0" to your wind vector
SetSavedDvar( "wind_global_low_altitude", 0);    // change 0 to your wind's lower bound
SetSavedDvar( "wind_global_hi_altitude", 6000);    // change 10000 to your wind's upper bound
SetSavedDvar( "wind_global_low_strength_percent", 0.3);    // change 0.5 to your desired wind strength percentage
}

//-- Called by a notetrack in flashpoint_anim
weaver_eye_blood( guy )
{
	//IPrintLnBold("BLOOD_FX");
	if( is_mature() )
	{
		PlayFXOnTag( level._effect["eye_blood"], guy, "J_EyeBall_LE" );
	}
}

weaver_vomit( guy )
{
	//IPrintLnBold("VOMIT_FX");
	//PlayFXOnTag( level._effect["eye_blood"], guy, "J_EyeBall_LE" );
	//PlayFXOnTag( level._effect["vomit_exp"], guy, "J_Nose_RI" );
	PlayFXOnTag( level._effect["vomit_exp"], guy, "J_Head" );
}

main()
{	
	//-- shabs -- TEMP
	initModelAnims();
	//precacherumble( "damage_heavy" );
	//precacheitem("g36c_silencer_mp");
	//precacheitem( "m14_scoped_silencer" );
	//precacheitem( "rpg_player" );
	
	precache_util_fx();
	precache_createfx_fx();
	precache_scripted_fx();
	footsteps();
	
	// calls the createfx server script (i.e., the list of ambient effects and their attributes)
	maps\createfx\flashpoint_fx::main();
	maps\createart\flashpoint_art::main();
	
	wind_initial_setting();
}


////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////
