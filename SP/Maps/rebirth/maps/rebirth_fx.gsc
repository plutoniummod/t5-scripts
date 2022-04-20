#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#using_animtree("fxanim_props");

precache_util_fx()
{
}

precache_scripted_fx()
{
	//level._effect[ "decontamination_spray" ] 	= LoadFX( "maps/rebirth/fx_decontamination_spray" );	
	level._effect[ "spotlight" ]							= LoadFX( "maps/rebirth/fx_hip_spotlight_beam" ); 
//	level._effect[ "spotlight_sc" ]						= LoadFX( "maps/rebirth/fx_hip_spotlight_target_light" );	// don't use this!
	level._effect[ "spotlight_circle" ] 			= LoadFX( "maps/rebirth/fx_hip_spotlight_target_circle" );
	level._effect[ "distant_explosion" ]			= LoadFX( "explosions/fx_exp_bomb_huge" );
	
	level._effect[ "flashlight_beam" ]				= LoadFX( "env/light/fx_flashlight_ai_spotlight" );
	
	level._effect[ "rocket_muzzleflash" ]			= LoadFX( "weapon/rocket/fx_heli_rocket_muzzleflash" );
	
	level._effect[ "ks23_muzzleflash" ] 			= LoadFX( "weapon/muzzleflashes/fx_shotgun_flash_base" );
	
	//character burn fx
	level._effect["character_fire_pain_sm"]     = LoadFX( "env/fire/fx_fire_player_sm_1sec" );
	level._effect["character_fire_death_sm"]    = LoadFX( "env/fire/fx_fire_player_md" );
	level._effect["character_fire_death_torso"] = LoadFX( "env/fire/fx_fire_player_torso" );	
	
	//level._effect["vehicle_explosion"]			= LoadFX("maps/vorkuta/fx_explosion_tower_main");

	// BTR Headlights
	level._effect["btr_headlight"]				= LoadFX("vehicle/light/fx_apc_btr60_headlight");
	//level._effect["btr_headlight_spot"]			= LoadFX("vehicle/light/fx_apc_btr60_headlight_left_spot");
	
	level._effect["btr_hood_fire"]			= LoadFX("maps/rebirth/fx_btr_hood_fire");
	
	level._effect[ "uaz_headlight" ]	= LoadFX( "vehicle/light/fx_jeep_uaz_headlight" );
	level._effect[ "uaz_taillight" ]	= LoadFX( "vehicle/light/fx_jeep_uaz_taillight" );	

	// Heli Rotors
	level._effect["heli_rotors"]					= LoadFX("vehicle/props/fx_hip_main_blade_full");
	level._effect["hip_crash_exp_impact"]	= LoadFX("maps/rebirth/fx_hip_crash_exp_impact");
	level._effect["hip_crash_smoke"]			= LoadFX("maps/rebirth/fx_hip_crash_exp_trail");
	level._effect["hip_crash_impact01"]		= LoadFX("maps/rebirth/fx_hip_crash_tire_smoke");
	level._effect["hip_crash_gas_attack"]	= LoadFX( "vehicle/vfire/fx_vsmoke_hip_trail" );

	// Gas FX
	level._effect["gas_bomb_outside"]			= LoadFX("maps/rebirth/fx_nova6_exp_outside");
	level._effect["gas_bomb_inside"]			= LoadFX( "maps/rebirth/fx_nova6_bomblet" );
	level._effect["gas_death_fumes"]			= LoadFX( "maps/rebirth/fx_nova6_death_fumes_ai" );
	
	level._effect["heat_shimmer"]					= LoadFX( "maps/rebirth/fx_ir_heat_trail" );
	
	// Makarov FX
	level._effect["makarov_flash"] = LoadFX("weapon/muzzleflashes/fx_pistol_flash_base");
	level._effect["makarov_shell"] = LoadFX("weapon/shellejects/fx_pistol");
	
	// Seagull Fall impact
	level._effect["seagull_hit_ground"]		= LoadFX( "bio/animals/fx_seagull_death_feathers" );

	// Lights
	level._effect["test_spin_fx"] = LoadFX( "env/light/fx_light_warning");
	
	// Blood spit effects
	//level._effect["blood_punch"] = LoadFX("maps/kowloon/fx_blood_punch_clark");
	level._effect["blood_punch"] = LoadFX("maps/rebirth/fx_punch_blood_spray");
	level._effect["blood_spit"] = LoadFX("maps/rebirth/fx_punch_blood_spray");

	// blood fx
	level._effect["hatchet_thrown_blood"] = LoadFX( "maps/rebirth/fx_axe_to_the_chest" );
	level._effect["hatchet_arm_blood"] = LoadFX( "maps/rebirth/fx_axe_to_the_arm" );
}

// Ambient effects
precache_createfx_fx()
{
	
// Smoke
	level._effect["fx_smk_plume_xlg_blk"]						= loadfx("env/smoke/fx_smk_plume_xlg_blk");
	level._effect["fx_smk_plume_md_wht_wispy"]			= loadfx("env/smoke/fx_smk_plume_md_wht_wispy");
	level._effect["fx_smk_fire_md_gray_int"]				= loadfx("env/smoke/fx_smk_fire_md_gray_int");
	level._effect["fx_smk_fire_lg_white"]						= loadfx("env/smoke/fx_smk_fire_lg_white");
	level._effect["fx_smk_smolder_rubble_md"]				= loadfX("env/smoke/fx_smk_smolder_rubble_md");
	level._effect["fx_smk_smolder_sm_int"]					= loadfX("env/smoke/fx_smk_smolder_sm_int");
	level._effect["fx_smk_linger_lit"]							= loadfx("env/smoke/fx_smk_linger_lit");
	level._effect["fx_smk_hallway_med"]							= loadfx("env/smoke/fx_smk_hallway_med");
	level._effect["fx_smk_ceiling_crawl"]						= loadfx("env/smoke/fx_smk_ceiling_crawl");
	level._effect["fx_fog_water_lg"]								= loadfx("env/smoke/fx_fog_water_lg");
	level._effect["fx_fog_rolling_md"]							= loadfx("env/smoke/fx_fog_rolling_md");
	level._effect["fx_fog_dropdown_lg"]							= loadfx("env/smoke/fx_fog_dropdown_lg");
	level._effect["fx_steam_hallway_md"]						= loadfx("env/smoke/fx_steam_hallway_md");
	
// Fires
	level._effect["fx_ash_embers_heavy"]						= loadfx("env/fire/fx_ash_embers_heavy");
	level._effect["fx_embers_falling_md"]						= loadfx("env/fire/fx_embers_falling_md");
	level._effect["fx_fire_column_creep_xsm"]				= loadfx("env/fire/fx_fire_column_creep_xsm");
	level._effect["fx_fire_column_creep_sm"]				= loadfx("env/fire/fx_fire_column_creep_sm");
	level._effect["fx_fire_wall_md"]								= loadfx("env/fire/fx_fire_wall_md");
	level._effect["fx_fire_ceiling_md"]							= loadfx("env/fire/fx_fire_ceiling_md");
	level._effect["fx_fire_sm_smolder"]							= loadfx("env/fire/fx_fire_sm_smolder");
	level._effect["fx_fire_md_smolder"]							= loadfx("env/fire/fx_fire_md_smolder");
	level._effect["fx_fire_line_xsm"]								= loadfx("env/fire/fx_fire_line_xsm");
	level._effect["fx_fire_line_sm"]								= loadfx("env/fire/fx_fire_line_sm");
	level._effect["fx_fire_line_md"]								= loadfx("env/fire/fx_fire_line_md");
	
// Exploders
	// Dock fog, turn on in beginning, turn off in labs: 10
	// Dock & lab exterior fog, turn on in beginning, turn off in labs, turn on after last gas section, turn off in labs: 15
	//level._effect["fx_falling_guy_impact_blood"]		= loadfx("impacts/fx_flesh_hit_body_fatal_exit");	//120
	level._effect["fx_dust_impact_body"]						= loadfx("env/dirt/fx_dust_impact_body");	// 121
	level._effect["fx_nova6_gas_leak"]							= loadfx("maps/rebirth/fx_nova6_gas_leak");	// 230
	level._effect["fx_gas_fog_thick_sm_os"]					= loadfx("maps/rebirth/fx_gas_fog_thick_sm_os");	// 230
	level._effect["fx_hip_crash_rotor_car"]					= loadfx("maps/rebirth/fx_hip_crash_rotor_car");	// 321
	level._effect["fx_hip_crash_rotor_ground"]			= loadfx("maps/rebirth/fx_hip_crash_rotor_ground");	// 322
	level._effect["fx_hip_crash_exp"]								= loadfx("explosions/fx_exp_vehicle_gen_stage3");	// 323
	level._effect["fx_hip_crash_ground_impact"]			= loadfx("maps/rebirth/fx_hip_crash_ground_impact");	// 324
	level._effect["fx_exp_gen_window"]							= loadfx("explosions/fx_exp_gen_window");	// 370
	level._effect["fx_steiner_console_smack"]				= loadfx("env/electrical/fx_elec_panel_spark_md");	// 380
	
	// BTR crash fires: 399
	// Gas: 400, 410, 420, 430, 440, 450
	level._effect["fx_gas_fog_thick"]								= loadfx("maps/rebirth/fx_gas_fog_thick");
	level._effect["fx_gas_fog_thick_sm"]						= loadfx("maps/rebirth/fx_gas_fog_thick_sm");
	level._effect["fx_gas_fog_thick_hall"]					= loadfx("maps/rebirth/fx_gas_fog_thick_hall");
	level._effect["fx_nova6_detail_md"]							= loadfx("maps/rebirth/fx_nova6_detail_md");
	level._effect["fx_nova6_detail_lg"]							= loadfx("maps/rebirth/fx_nova6_detail_lg");
	level._effect["fx_nova6_door_exit"]							= loadfx("maps/rebirth/fx_nova6_door_exit");
	level._effect["fx_nova6_window_exit"]						= loadfx("maps/rebirth/fx_nova6_window_exit");
	level._effect["fx_nova6_dropdown"]							= loadfx("maps/rebirth/fx_nova6_dropdown");
	level._effect["fx_nova6_gas_lit"]								= loadfx("maps/rebirth/fx_nova6_gas_lit");
	// Last gas: 455
	// Gas flowing over dropdown: 460
	// Hip Fires: 470
	level._effect[ "fx_decontamination_spray" ] 		= loadfx("maps/rebirth/fx_decontamination_spray");	// 480
	// Lab interior, lower level: 490
// Steiner window break
	level._effect["fx_steiner_window_hit"]					= loadfx("maps/rebirth/fx_steiner_window_hit");			// 501
	level._effect["fx_steiner_window_smash"]				= loadfx("maps/rebirth/fx_steiner_window_smash");		// 502
	level._effect["fx_blood_drip"]									= loadfx("bio/blood/fx_blood_drip");	// Scripted!
	
	// Ending sequence: 570
	level._effect["fx_exp_bomb_huge"]								= loadfx("explosions/fx_exp_bomb_huge");
	
// Lights
	level._effect["fx_light_overhead"]							= loadfx("env/light/fx_light_overhead_amber");
	level._effect["fx_light_overhead_int_amber"]		= loadfx("env/light/fx_light_overhead_int");
	level._effect["fx_light_overhead_sm_amber"]			= loadfx("env/light/fx_light_overhead_sm_amber");
	level._effect["fx_fog_lit_overhead_amber"]			= loadfx("env/smoke/fx_fog_lit_overhead_amber");
	level._effect["fx_light_floodlight_bright"]			= loadfx("env/light/fx_light_floodlight_bright");
	level._effect["fx_light_floodlight_bright_dist"]= loadfx("env/light/fx_light_floodlight_bright_dist");
	level._effect["fx_street_light_green"]					= loadfx("env/light/fx_street_light");
	//level._effect["fx_light_dust_motes_sm"]					= loadfx("env/light/fx_light_dust_motes_sm");
	level._effect["fx_light_dust_motes_xsm"]				= loadfx("env/light/fx_light_dust_motes_xsm");
	level._effect["fx_lab_light_quad"]							= loadfx("maps/rebirth/fx_lab_light_quad");
	level._effect["fx_light_tinhat_cage"]						= loadfx("env/light/fx_light_tinhat_cage");
	level._effect["fx_ray_spread_md_1sd"]						= loadfx("env/light/fx_ray_spread_md_1sd");
	level._effect["fx_light_map_glow"]							= loadfx("maps/flashpoint/fx_light_map_glow");
	level._effect["fx_light_fluorescent_tubes"]			= loadfx("env/light/fx_light_fluorescent_tubes");
	level._effect["fx_light_med_overhead"]					= loadfx("env/light/fx_light_med_overhead");
	
// Water
	level._effect["fx_water_pipe_gush_lg_dirty"]		= loadfx("env/water/fx_water_pipe_gush_lg_dirty");
	level._effect["fx_water_splash_lg_dirty"]				= loadfx("env/water/fx_water_splash_lg_dirty");
	level._effect["fx_pipe_steam_md"]								= loadfx("env/smoke/fx_pipe_steam_md");
	level._effect["fx_pipe_steam_md_runner"]				= loadfx("env/smoke/fx_pipe_steam_md_runner");
	
// Other
	level._effect["fx_seagulls_shore_distant"]			= loadfx("bio/animals/fx_seagulls_shore_distant");
	level._effect["fx_seagulls_near"]								= loadfx("bio/animals/fx_seagulls_near");
}

wind_initial_setting()
{
SetSavedDvar( "wind_global_vector", "-14 -118 0" );      // change "0 0 0" to your wind vector
SetSavedDvar( "wind_global_low_altitude", -500);           // change 0 to your wind's lower bound
SetSavedDvar( "wind_global_hi_altitude", 4400);          // change 10000 to your wind's upper bound
SetSavedDvar( "wind_global_low_strength_percent", 0.4); // change 0.5 to your desired wind strength percentage
}

// gas fog for createfx only!
gas_attack_start_fog()
{
	level waittill("cfx_start_fog");
	start_dist = 56;
	half_dist = 738;
	half_height = 883.664;
	base_height = 4111.81;
	fog_r = 0.917647;
	fog_g = 0.85098;
	fog_b = 0.376471;
	fog_scale = 1;
	sun_col_r = 0.501961;
	sun_col_g = 0.501961;
	sun_col_b = 0.501961;
	sun_dir_x = 1;
	sun_dir_y = 0;
	sun_dir_z = 0;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 5;
	max_fog_opacity = 0.962;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
}

main()
{
	initModelAnims();
	precache_util_fx();
	precache_createfx_fx();
	precache_scripted_fx();
//	maps\createart\rebirth_art::main();
	wind_initial_setting();
	
	maps\createfx\rebirth_fx::main();

	//level thread gas_attack_start_fog();	// gas fog for createfx
}


// FXanim Props
initModelAnims()
{
	if( !IsDefined( level.scr_sound ) )
	{
		level.scr_sound = [];
	}

	level.scr_animtree["fxanim_props"] = #animtree;

	level.scr_anim["fxanim_props"]["a_seagull_fall"] = %fxanim_gp_seagull_falling_anim;
	level.scr_anim["fxanim_props"]["a_heli01_rotor"] = %fxanim_rebirth_heli01_rotor_anim;
	level.scr_anim["fxanim_props"]["a_heli01_chunks"] = %fxanim_rebirth_heli01_chunks_anim;
	level.scr_anim["fxanim_props"]["a_seagull_circle_01"][0] = %fxanim_gp_seagull_circle_01_anim;
	level.scr_anim["fxanim_props"]["a_seagull_circle_02"][0] = %fxanim_gp_seagull_circle_02_anim;
	level.scr_anim["fxanim_props"]["a_seagull_circle_03"][0] = %fxanim_gp_seagull_circle_03_anim;
	level.scr_anim["fxanim_props"]["a_container_01"] = %fxanim_rebirth_container_01_anim;
	level.scr_anim["fxanim_props"]["a_container_02"] = %fxanim_rebirth_container_02_anim;
	level.scr_anim["fxanim_props"]["a_container_03"] = %fxanim_rebirth_container_03_anim;
	level.scr_anim["fxanim_props"]["a_gascan_01"] = %fxanim_rebirth_gascan_01_anim;
	level.scr_anim["fxanim_props"]["a_gascan_02"] = %fxanim_rebirth_gascan_02_anim;
	level.scr_anim["fxanim_props"]["a_gascan_03"] = %fxanim_rebirth_gascan_03_anim;
	level.scr_anim["fxanim_props"]["a_streamer01"] = %fxanim_gp_streamer01_anim;
	level.scr_anim["fxanim_props"]["a_streamer02"] = %fxanim_gp_streamer02_anim;
	level.scr_anim["fxanim_props"]["a_cargo_ropes_loop"] = %fxanim_rebirth_cargo_ropes_loop_anim;
	level.scr_anim["fxanim_props"]["a_cargo_ropes_stop"] = %fxanim_rebirth_cargo_ropes_stop_anim;
	
	ent1 = getent( "fxanim_gp_seagull_fall_01", "targetname" );
	ent2 = getent( "fxanim_gp_seagull_fall_02", "targetname" );
	ent3 = getent( "fxanim_gp_seagull_fall_03", "targetname" );
	ent4 = getent( "fxanim_gp_seagull_fall_04", "targetname" );	
	ent5 = getent( "fxanim_gp_seagull_fall_05", "targetname" );
	ent6 = getent( "fxanim_rebirth_heli01_rotor_mod", "targetname" );
	ent7 = getent( "fxanim_rebirth_heli01_chunks_mod", "targetname" );
	ent8 = getent( "container_01", "targetname" );
	ent9 = getent( "container_02", "targetname" );
	ent10 = getent( "container_03", "targetname" );
	ent11 = getent( "gascan_01", "targetname" );
	ent12 = getent( "gascan_02", "targetname" );
	ent13 = getent( "gascan_03", "targetname" );
	ent14 = getent( "cargo_ropes", "targetname" );

	addNotetrack_customFunction( "fxanim_props", "seagull_impact", maps\rebirth_fx::seagull_hit_ground );
	addNotetrack_customFunction( "fxanim_props", "can_01_canister1_burst", maps\rebirth_fx::canister_burst1 );
	addNotetrack_customFunction( "fxanim_props", "can_01_canister2_burst", maps\rebirth_fx::canister_burst2 );
	addNotetrack_customFunction( "fxanim_props", "can_01_canister3_burst", maps\rebirth_fx::canister_burst3 );
	addNotetrack_customFunction( "fxanim_props", "can_01_canister4_burst", maps\rebirth_fx::canister_burst4 );
	addNotetrack_customFunction( "fxanim_props", "can_01_canister5_burst", maps\rebirth_fx::canister_burst5 );
	addNotetrack_customFunction( "fxanim_props", "can_01_canister6_burst", maps\rebirth_fx::canister_burst6 );
	addNotetrack_customFunction( "fxanim_props", "can_01_canister7_burst", maps\rebirth_fx::canister_burst7 );
	addNotetrack_customFunction( "fxanim_props", "can_01_canister8_burst", maps\rebirth_fx::canister_burst8 );
	addNotetrack_customFunction( "fxanim_props", "can_01_canister9_burst", maps\rebirth_fx::canister_burst9 );
	addNotetrack_customFunction( "fxanim_props", "can_01_canister10_burst", maps\rebirth_fx::canister_burst10 );
	addNotetrack_customFunction( "fxanim_props", "can_01_canister11_burst", maps\rebirth_fx::canister_burst11 );
	addNotetrack_customFunction( "fxanim_props", "can_01_canister12_burst", maps\rebirth_fx::canister_burst12 );
	addNotetrack_customFunction( "fxanim_props", "can_01_canister12_burst", maps\rebirth_gas_attack::explode_gas_in_streets );
	
	addNotetrack_customFunction( "fxanim_props", "can_02_canister1_burst", maps\rebirth_fx::canister2_burst1 );
	addNotetrack_customFunction( "fxanim_props", "can_02_canister2_burst", maps\rebirth_fx::canister2_burst2 );
	addNotetrack_customFunction( "fxanim_props", "can_02_canister3_burst", maps\rebirth_fx::canister2_burst3 );
	addNotetrack_customFunction( "fxanim_props", "can_02_canister4_burst", maps\rebirth_fx::canister2_burst4 );
	addNotetrack_customFunction( "fxanim_props", "can_02_canister5_burst", maps\rebirth_fx::canister2_burst5 );
	addNotetrack_customFunction( "fxanim_props", "can_02_canister6_burst", maps\rebirth_fx::canister2_burst6 );
	addNotetrack_customFunction( "fxanim_props", "can_02_canister7_burst", maps\rebirth_fx::canister2_burst7 );
	addNotetrack_customFunction( "fxanim_props", "can_02_canister8_burst", maps\rebirth_fx::canister2_burst8 );
	addNotetrack_customFunction( "fxanim_props", "can_02_canister9_burst", maps\rebirth_fx::canister2_burst9 );
	addNotetrack_customFunction( "fxanim_props", "can_02_canister10_burst", maps\rebirth_fx::canister2_burst10 );		
		
	enta_seagull_circle_01 = GetEntArray( "seagull_circle_01", "targetname" );	
	enta_seagull_circle_02 = GetEntArray( "seagull_circle_02", "targetname" );
	enta_seagull_circle_03 = GetEntArray( "seagull_circle_03", "targetname" );
	enta_streamer01= GetEntArray( "streamer01", "targetname" );
	enta_streamer02= GetEntArray( "streamer02", "targetname" );
		
	if (IsDefined(ent1)) 
	{
		ent1 thread seagull_fall_01();
		println("************* FX: seagull_fall_01 *************");
	}
	
	if (IsDefined(ent2)) 
	{
		ent2 thread seagull_fall_02();
		println("************* FX: seagull_fall_02 *************");
	}
	
	if (IsDefined(ent3)) 
	{
		ent3 thread seagull_fall_03();
		println("************* FX: seagull_fall_03 *************");
	}

	if (IsDefined(ent4)) 
	{
		ent4 thread seagull_fall_04();
		println("************* FX: seagull_fall_04 *************");
	}
	
	if (IsDefined(ent5)) 
	{
		ent5 thread seagull_fall_05();
		println("************* FX: seagull_fall_05 *************");
	}
	
	if (IsDefined(ent6)) 
	{
		ent6 thread heli01_rotor();
		println("************* FX: heli01_rotor *************");
	}
	
	if (IsDefined(ent7)) 
	{
		ent7 thread heli01_chunks();
		println("************* FX: heli01_chunks *************");
	}			
	
	for(i=0; i<enta_seagull_circle_01.size; i++)
	{
 		enta_seagull_circle_01[i] thread seagull_circle_01(1,3);
 		println("************* FX: seagull_circle_01 *************");
	}
	
	for(i=0; i<enta_seagull_circle_02.size; i++)
	{
 		enta_seagull_circle_02[i] thread seagull_circle_02(1,3);
 		println("************* FX: seagull_circle_02 *************");
	}
	
	for(i=0; i<enta_seagull_circle_03.size; i++)
	{
 		enta_seagull_circle_03[i] thread seagull_circle_03(1,3);
 		println("************* FX: seagull_circle_03 *************");
	}
	
	if (IsDefined(ent8)) 
	{
		ent8 thread container_01();
		println("************* FX: container_01 *************");
	}	
	
	if (IsDefined(ent9)) 
	{
		ent9 thread container_02();
		println("************* FX: container_02 *************");
	}	
	
	if (IsDefined(ent10)) 
	{
		ent10 thread container_03();
		println("************* FX: container_03 *************");
	}	
	
		if (IsDefined(ent11)) 
	{
		ent11 thread gascan_01();
		println("************* FX: gascan_01 *************");
	}	
	
	if (IsDefined(ent12)) 
	{
		ent12 thread gascan_02();
		println("************* FX: gascan_02 *************");
	}
	
	if (IsDefined(ent13)) 
	{
		ent13 thread gascan_03();
		println("************* FX: gascan_03 *************");
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
	
	if (IsDefined(ent14)) 
	{
		ent14 thread cargo_ropes();
		println("************* FX: cargo_ropes *************");
	}
}

	
seagull_fall_01()
{
	self Hide();
	level waittill("seagull_fall_01_start");
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_seagull_fall", "fxanim_props");
}

seagull_fall_02()
{
	self Hide();
	level waittill("seagull_fall_02_start");
	wait(1);
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_seagull_fall", "fxanim_props");
}

seagull_fall_03()
{
	self Hide();
	level waittill("seagull_fall_02_start");
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_seagull_fall", "fxanim_props");
}

seagull_fall_04()
{
	self Hide();
	level waittill("seagull_fall_04_start");
	self Show();
	self UseAnimTree(#animtree);
	thread anim_single(self, "a_seagull_fall", "fxanim_props");
}

seagull_fall_05()
{
	self Hide();
	level waittill("seagull_fall_04_start");
	wait(1.5);
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_seagull_fall", "fxanim_props");
}

heli01_rotor()
{
	level waittill("heli01_rotor_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_heli01_rotor", "fxanim_props");
}

heli01_chunks()
{
	level waittill("heli01_chunks_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_heli01_chunks", "fxanim_props");
}

seagull_circle_01(delay_min,delay_max)
{
	self endon( "death" );
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_loop(self, "a_seagull_circle_01", "stop_loop", "fxanim_props");
}

seagull_circle_02(delay_min,delay_max)
{
	self endon( "death" );
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_loop(self, "a_seagull_circle_02", "stop_loop", "fxanim_props");
}

seagull_circle_03(delay_min,delay_max)
{
	self endon( "death" );
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_loop(self, "a_seagull_circle_03", "stop_loop", "fxanim_props");
}

container_01()
{
	self Hide();
	level waittill("container_01_start");
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_container_01", "fxanim_props");
}

container_02()
{
	level waittill("container_02_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_container_02", "fxanim_props");
}

container_03()
{
	level waittill("container_03_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_container_03", "fxanim_props");
	level notify( "crate_kill_trig_stop" );
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

gascan_01()
{
	self Hide();
	level waittill("gascan_start");
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_gascan_01", "fxanim_props");
}

gascan_02()
{
	self Hide();
	level waittill("gascan_start");
	wait(.5);
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_gascan_02", "fxanim_props");
}

gascan_03()
{
	self Hide();
	level waittill("gascan_window_start");
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_gascan_03", "fxanim_props");
}

cargo_ropes()
{
	flag_init("cargo_ropes_start");
	wait(1);
	flag_set("cargo_ropes_start");
	
	self thread cargo_ropes_stop();

  start_crate = GetEnt( "mason_start_crate", "targetname" ); 
  if( IsDefined( start_crate ) )
  {
  	self LinkTo( start_crate );
  }
	self UseAnimTree(#animtree);
	anim_single(self, "a_cargo_ropes_loop", "fxanim_props");
}

cargo_ropes_stop(org)
{
	while(flag("cargo_ropes_start"))
	{
		wait(0.05);
	}
	self UseAnimTree(#animtree);
	wait(0.8);
	self anim_set_blend_in_time(0.5);
	anim_single(self, "a_cargo_ropes_stop", "fxanim_props");
}

get_gascan(name)
{
	can1 = getent( name, "targetname" );
	return can1;
}

get_gascan_two()
{
	can2 = getent( "gascan_02", "targetname" );
	return can2;
}

play_canister_fx(tag, can_num)
{
	if(!can_num)
		gascan = get_gascan("gascan_01");
	else
		gascan = get_gascan("gascan_02");	
	tag_origin = gascan GetTagOrigin(tag);
	tag_angles = gascan GetTagAngles(tag);	
	if( RandomInt( 2 ) % 2 )
	{
		fx = PlayFXOnTag( level._effect["gas_bomb_inside"], self, tag );
	}
	else
	{
		fx = PlayFXOnTag( level._effect["gas_bomb_outside"], self, tag );
	}
	// fx = PlayFX( level._effect["gas_bomb_outside"], tag_origin, AnglesToForward(tag_angles), (1,0,0));
}

seagull_hit_ground(ent)
{
	wait(.2);
	PlayFX( level._effect["seagull_hit_ground"], self.origin );
}

canister_burst1(ent)
{
	ent play_canister_fx("canister_gas_01_jnt", 0);
}

canister_burst2(ent)
{
	ent play_canister_fx("canister_gas_02_jnt", 0);
}

canister_burst3(ent)
{
	ent play_canister_fx("canister_gas_03_jnt", 0);
}

canister_burst4(ent)
{
	ent play_canister_fx("canister_gas_04_jnt", 0);
}

canister_burst5(ent)
{
	ent play_canister_fx("canister_gas_05_jnt", 0);
}

canister_burst6(ent)
{
	ent play_canister_fx("canister_gas_06_jnt", 0);
}

canister_burst7(ent)
{
	ent play_canister_fx("canister_gas_07_jnt", 0);
}

canister_burst8(ent)
{
	ent play_canister_fx("canister_gas_08_jnt", 0);
}

canister_burst9(ent)
{
	ent play_canister_fx("canister_gas_09_jnt", 0);
}

canister_burst10(ent)
{
	ent play_canister_fx("canister_gas_10_jnt", 0);
	wait(1);
	flag_set( "turn_on_gas_exploders" );
}

canister_burst11(ent)
{
	ent play_canister_fx("canister_gas_11_jnt", 0);
}

canister_burst12(ent)
{
	ent play_canister_fx("canister_gas_12_jnt", 0);
}

canister2_burst1(ent)
{
	ent play_canister_fx("canister_gas_01_jnt", 1);
}

canister2_burst2(ent)
{
	ent play_canister_fx("canister_gas_02_jnt", 1);
}

canister2_burst3(ent)
{
	ent play_canister_fx("canister_gas_03_jnt", 1);
}

canister2_burst4(ent)
{
	ent play_canister_fx("canister_gas_04_jnt", 1);
}

canister2_burst5(ent)
{
	ent play_canister_fx("canister_gas_05_jnt", 1);
}

canister2_burst6(ent)
{
	ent play_canister_fx("canister_gas_06_jnt", 1);
}

canister2_burst7(ent)
{
	ent play_canister_fx("canister_gas_07_jnt", 1);
}

canister2_burst8(ent)
{
	ent play_canister_fx("canister_gas_08_jnt", 1);
}

canister2_burst9(ent)
{
	ent play_canister_fx("canister_gas_09_jnt", 1);
}

canister2_burst10(ent)
{
	ent play_canister_fx("canister_gas_10_jnt", 1);
}

canister2_burst11(ent)
{
	ent play_canister_fx("canister_gas_11_jnt", 1);
}

canister2_burst12(ent)
{
	ent play_canister_fx("canister_gas_12_jnt", 1);
}
