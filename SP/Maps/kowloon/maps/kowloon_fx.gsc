#include common_scripts\utility; 
#include maps\_utility; 
#include maps\_anim;
#using_animtree("fxanim_props");

// fx used by utility scripts
precache_util_fx()
{
	
}

// Scripted effects
precache_scripted_fx()
{
	level._effect["fx_blood_punch"]				= LoadFx("maps/kowloon/fx_blood_punch_clark");
	level._effect["fx_blood_spit"]				= LoadFx("maps/kowloon/fx_blood_spit_clark");

	level._effect["fx_gas_nova6_spray"]	= LoadFx("maps/kowloon/fx_gas_nova6_canister_spray");
	level._effect["rotor_full"] = LoadFx("vehicle/props/fx_hind_main_blade_full");
	level._effect["rotor_small"] = LoadFx("vehicle/props/fx_hind_small_blade_full");

	level._effect["plane_light"] = LoadFx("vehicle/light/fx_747_running_lights");

	level._effect["water_tank_leak"] = LoadFx("maps/kowloon/fx_impact_water_tower");

	level._effect["heli_smoke"] = LoadFx("vehicle/vfire/fx_vsmoke_hind_dmg_trail");
	level._effect["heli_explosion"] = LoadFx("vehicle/vexplosion/fx_vexp_hip_ground_impact");
	level._effect["building_explosion"] = LoadFx("explosions/fx_exp_bomb_huge");

	level._effect["fish_leak"] = LoadFx("destructibles/fx_dest_fishtank_water_lg");

	level._effect["head_shot"] = LoadFx("maps/kowloon/fx_head_fatal_lg_exit");

	level._effect["van_lights"] = LoadFx("vehicle/light/fx_van_kow_headlight_set");

	level._effect[ "spotlight" ]							= LoadFX( "maps/rebirth/fx_hip_spotlight_beam" ); 
	
	level._effect["fx_rain_sys_heavy_windy_1"]				= LoadFx("env/weather/fx_rain_sys_heavy_windy_1");
	level._effect["fx_rain_sys_heavy_windy_2"]				= LoadFx("env/weather/fx_rain_sys_heavy_windy_2");
	level._effect["fx_rain_sys_heavy_windy_3"]				= LoadFx("env/weather/fx_rain_sys_heavy_windy_3");

	level._effect["gas_death_fumes"]						= LoadFX( "maps/rebirth/fx_nova6_death_fumes_ai" );

	level._effect["chopper_burning"] 						= LoadFX("vehicle/vfire/fx_vsmoke_huey_trail");

	//shabs - clarke's detonator light
	level._effect["radio_light"]							=  LoadFX("maps/sandbox_modules/module_2/fx_mod2_hand_radio_light");
	level.fake_muzzleflash									= LoadFX("weapon/muzzleflashes/fx_standard_flash");


}


// FXanim Props
initModelAnims()
{
	level.scr_anim["fxanim_props"]["a_crow_walk01"] = %fxanim_gp_crow_walk01_anim;
	level.scr_anim["fxanim_props"]["a_crow_idle"][0] = %fxanim_gp_crow_look_anim;
	level.scr_anim["fxanim_props"]["a_crow_idle"][1] = %fxanim_gp_crow_look02_anim;
	level.scr_anim["fxanim_props"]["a_crow_idle"][2] = %fxanim_gp_crow_eat_anim;
	level.scr_anim["fxanim_props"]["a_crow_90rfly_fast"] = %fxanim_gp_crow_90rfly_fast_anim;
	level.scr_anim["fxanim_props"]["a_crow_quickfly"] = %fxanim_gp_crow_quickfly_anim;	
	
	level.scr_anim["fxanim_props"]["a_awning_tear"] = %fxanim_kowloon_awning01_tear_anim;
	level.scr_anim["fxanim_props"]["a_awning_loop"] = %fxanim_kowloon_awning01_loop_anim;
	level.scr_anim["fxanim_props"]["a_fishtank_lrg_loop"] = %fxanim_kowloon_fishtank_lrg_loop_anim;
	level.scr_anim["fxanim_props"]["a_fishtank_lrg_spill"] = %fxanim_kowloon_fishtank_lrg_spill_anim;
	level.scr_anim["fxanim_props"]["a_fishtank_sm_loop"] = %fxanim_kowloon_fishtank_sm_loop_anim;
	level.scr_anim["fxanim_props"]["a_fishtank_sm_spill_01"] = %fxanim_kowloon_fishtank_sm_spill_01_anim;
	level.scr_anim["fxanim_props"]["a_fishtank_sm_spill_02"] = %fxanim_kowloon_fishtank_sm_spill_02_anim;
	level.scr_anim["fxanim_props"]["a_door_breach"] = %fxanim_kowloon_door_breach_anim;
	level.scr_anim["fxanim_props"]["a_ceiling_collapse"] = %fxanim_kowloon_ceiling_collapse_anim;
	level.scr_anim["fxanim_props"]["a_neon_sign"] = %fxanim_kowloon_neon_sign_anim;
	level.scr_anim["fxanim_props"]["a_ceiling_garbage"] = %fxanim_kowloon_ceiling_garbage_anim;
	level.scr_anim["fxanim_props"]["a_neon_sign_alley"] = %fxanim_kowloon_neon_sign_alley_anim;
	level.scr_anim["fxanim_props"]["a_weapon_cache"] = %fxanim_kowloon_weapon_cache_anim;
	
	
	ent1 = GetEnt( "fxanim_kowloon_awning01_mod", "targetname" );
	ent2 = GetEnt( "fxanim_fishtank_lrg_01", "targetname" );
	ent3 = GetEnt( "fxanim_fishtank_sm_01", "targetname" );
	ent4 = GetEnt( "fxanim_fishtank_sm_02", "targetname" );
	ent5 = GetEnt( "fxanim_kowloon_door_breach_mod", "targetname" );
	ent6 = GetEnt( "fxanim_kowloon_ceiling_collapse_mod", "targetname" );
	ent7 = GetEnt( "fxanim_kowloon_neon_sign_mod", "targetname" );
	ent8 = GetEnt( "fxanim_kowloon_awning02_mod", "targetname" );
	ent9 = getent( "fxanim_gp_crow_01", "targetname" );
	ent10 = getent( "fxanim_gp_crow_02", "targetname" );	
	ent11 = getent( "fxanim_gp_crow_03", "targetname" );
	ent12 = getent( "fxanim_gp_crow_04", "targetname" );
	ent13 = getent( "fxanim_gp_crow_05", "targetname" );
	ent14 = getent( "fxanim_gp_crow_06", "targetname" );
	ent15 = getent( "fxanim_gp_crow_07", "targetname" );
	ent16 = getent( "fxanim_gp_crow_08", "targetname" );
	ent17 = getent( "fxanim_kowloon_neon_sign_alley_mod", "targetname" );
	ent18 = getent( "fxanim_kowloon_weapon_cache_mod", "targetname" );
	
	enta_ceiling_garbage = GetEntArray( "fxanim_kowloon_ceiling_garbage_mod", "targetname" );
	
	if (IsDefined(ent1)) 
	{
		ent1 thread awning();
		println("************* FX: awning *************");
	}
	
	if (IsDefined(ent2)) 
	{
		ent2 thread fishtank_lrg_01();
		println("************* FX: fishtank_lrg_01 *************");
	}
	
	if (IsDefined(ent3)) 
	{
		ent3 thread fishtank_sm_01();
		println("************* FX: fishtank_sm_01 *************");
	}
	
	if (IsDefined(ent4)) 
	{
		ent4 thread fishtank_sm_02();
		println("************* FX: fishtank_sm_02 *************");
	}
	
	if (IsDefined(ent5)) 
	{
		ent5 thread door_breach();
		println("************* FX: door_breach *************");
	}
	
	if (IsDefined(ent6)) 
	{
		ent6 thread ceiling_collapse();
		println("************* FX: ceiling_collapse *************");
	}
	
	if (IsDefined(ent7)) 
	{
		ent7 thread neon_sign();
		println("************* FX: neon_sign *************");
	}
	
	if (IsDefined(ent8)) 
	{
		ent8 thread awning02();
		println("************* FX: awning02 *************");
	}
	
	for(i=0; i<enta_ceiling_garbage.size; i++)
	{
 		enta_ceiling_garbage[i] thread ceiling_garbage(1,3);
 		println("************* FX: ceiling_garbage *************");
	}
	
	if (IsDefined(ent9)) 
	{
		ent9 thread crow_01();
		println("************* FX: crow_01 *************");
	}
	
	if (IsDefined(ent10)) 
	{
		ent10 thread crow_02();
		println("************* FX: crow_02 *************");
	}
	
	if (IsDefined(ent11)) 
	{
		ent11 thread crow_03();
		println("************* FX: crow_03 *************");
	}
	
	if (IsDefined(ent12)) 
	{
		ent12 thread crow_04();
		println("************* FX: crow_04 *************");
	}
	
	if (IsDefined(ent13)) 
	{
		ent13 thread crow_05();
		println("************* FX: crow_05 *************");
	}
	
	if (IsDefined(ent14)) 
	{
		ent14 thread crow_06();
		println("************* FX: crow_06 *************");
	}
	
	if (IsDefined(ent15)) 
	{
		ent15 thread crow_07();
		println("************* FX: crow_07 *************");
	}
	
	if (IsDefined(ent16)) 
	{
		ent16 thread crow_08();
		println("************* FX: crow_08 *************");
	}
	
	if (IsDefined(ent17)) 
	{
		ent17 thread neon_sign_alley();
		println("************* FX: neon_sign_alley *************");
	}
	
	if (IsDefined(ent18)) 
	{
		ent18 thread weapon_cache();
		println("************* FX: weapon_cache *************");
	}
}

awning()
{
	level waittill("awning_tear_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_awning_tear", "fxanim_props");
	anim_single(self, "a_awning_loop", "fxanim_props");	
}

fishtank_lrg_01()
{
	wait(1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_fishtank_lrg_loop", "fxanim_props");
	
	self SetCanDamage(true);
	self waittill("damage");
	
	//SOUND - Shawn J	
	self playsound ("dst_fish_tank");
		
	PlayFXOnTag(level._effect["fish_leak"], self, "lrg_fx_f_jnt");
	anim_single(self, "a_fishtank_lrg_spill", "fxanim_props");
}

fishtank_sm_01()
{
	wait(1.3);
	self UseAnimTree(#animtree);
	anim_single(self, "a_fishtank_sm_loop", "fxanim_props");
	
	self SetCanDamage(true);
	self waittill("damage");
		
	//SOUND - Shawn J	
	self playsound ("dst_fish_tank");
	
	PlayFXOnTag(level._effect["fish_leak"], self, "sm_fx_l_jnt");
	PlayFXOnTag(level._effect["fish_leak"], self, "sm_fx_b_jnt");
	PlayFXOnTag(level._effect["fish_leak"], self, "sm_fx_f_jnt");
	PlayFXOnTag(level._effect["fish_leak"], self, "sm_fx_r_jnt");
	anim_single(self, "a_fishtank_sm_spill_01", "fxanim_props");
}

fishtank_sm_02()
{
	wait(1.5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_fishtank_sm_loop", "fxanim_props");
	
	self SetCanDamage(true);
	self waittill("damage");
	
	//SOUND - Shawn J	
	self playsound ("dst_fish_tank");
	
	PlayFXOnTag(level._effect["fish_leak"], self, "sm_fx_l_jnt");
	PlayFXOnTag(level._effect["fish_leak"], self, "sm_fx_b_jnt");
	PlayFXOnTag(level._effect["fish_leak"], self, "sm_fx_f_jnt");
	PlayFXOnTag(level._effect["fish_leak"], self, "sm_fx_r_jnt");
	anim_single(self, "a_fishtank_sm_spill_02", "fxanim_props");
}

door_breach()
{
	level waittill("door_breach_start");
	
	level thread door_breach_exploder_wait();

	ss = GetStruct( "ss_e5_breach_pulse", "targetname" );
	physicsExplosionCylinder(ss.origin, 100, 50, 0.5);

	wait( 0.30 );

	self UseAnimTree(#animtree);
	anim_single(self, "a_door_breach", "fxanim_props");
}

door_breach_exploder_wait()
{
	exploder(6001);	
}

ceiling_collapse()
{
	level waittill("ceiling_collapse_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_collapse", "fxanim_props");
}

neon_sign()
{
	self hide();
	level waittill("neon_sign_start");
	self UseAnimTree(#animtree);

	//shabs - rumble and screenshake when sign falls
	player = get_players()[0];
	player PlayRumbleOnEntity("damage_light");

	anim_single(self, "a_neon_sign", "fxanim_props");
}

awning02()
{
	level waittill("awning02_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_awning_tear", "fxanim_props");
	anim_single(self, "a_awning_loop", "fxanim_props");	
}

ceiling_garbage(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_garbage", "fxanim_props");
}

crow_idle( fly_away_notify )
{
	level endon( fly_away_notify );
	
	while( 1 )
	{
		anim_single(self, "a_crow_idle", "fxanim_props");
	}
}

crow_idle_and_fly_away( fly_away_notify, anim_name )
{
	self thread crow_idle( fly_away_notify );
	level waittill( fly_away_notify );
	anim_single(self, anim_name, "fxanim_props");
}

crow_01()
{
	wait(14);
	self UseAnimTree(#animtree);
	anim_single(self, "a_crow_walk01", "fxanim_props");
	self crow_idle_and_fly_away( "glass_break_crows_start", "a_crow_90rfly_fast" );
	self delete();
}

crow_02()
{
	level waittill("glass_break_crows_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_crow_quickfly", "fxanim_props");
	self delete();
}

crow_03()
{
	self Hide();
	level waittill("airplane_crows_start");

	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_crow_quickfly", "fxanim_props");
	self delete();
}

crow_04()
{
	self Hide();
	level waittill("airplane_crows_start");

	self Show();
	wait(.2);
	self UseAnimTree(#animtree);
	anim_single(self, "a_crow_quickfly", "fxanim_props");
	self delete();
}

crow_05()
{
	self Hide();

	level waittill("airplane_crows_start");

	self Show();
	wait(.35);
	self UseAnimTree(#animtree);
	anim_single(self, "a_crow_quickfly", "fxanim_props");
	self delete();
}

crow_06()
{
	level waittill("slide_crows_start");
	wait(.2);
	self UseAnimTree(#animtree);
	anim_single(self, "a_crow_quickfly", "fxanim_props");
	self delete();
}

crow_07()
{
	level waittill("slide_crows_start");
	wait(.4);
	self UseAnimTree(#animtree);
	anim_single(self, "a_crow_quickfly", "fxanim_props");
	self delete();
}

crow_08()
{
	level waittill("slide_crows_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_crow_quickfly", "fxanim_props");
	self delete();
}

neon_sign_alley()
{
	level waittill("neon_sign_alley_start");
	self UseAnimTree(#animtree);

	//shabs - rumble and screenshake when sign falls
	player = get_players()[0];
	player PlayRumbleOnEntity("damage_light");

	anim_single(self, "a_neon_sign_alley", "fxanim_props");
}

weapon_cache()
{
	level waittill("weapon_cache_start");

	//SOUND - Shawn J
	self playsound( "evt_cache_door" );

	self UseAnimTree(#animtree);
	anim_single(self, "a_weapon_cache", "fxanim_props");
}




// Ambient effects
precache_createfx_fx()
{
	level._effect["fx_fog_low"]												= LoadFx("env/smoke/fx_fog_low");
	level._effect["fx_fog_low_sm"]										= LoadFx("env/smoke/fx_fog_low_sm");
	
//level._effect["fx_rain_downpour_looping_md"]			= LoadFx("env/weather/fx_rain_downpour_looping_md");

  level._effect["fx_rain_splash_detail"]						= Loadfx("env/weather/fx_rain_splash_detail");
	level._effect["fx_rain_mist"]											= LoadFx("env/weather/fx_rain_mist");
	level._effect["fx_rain_mist_sm"]									= LoadFx("env/weather/fx_rain_mist_sm");
	level._effect["fx_rain_heavy_looping"]						= LoadFx("env/weather/fx_rain_heavy_looping");
	level._effect["fx_rain_light_looping"]						= LoadFx("env/weather/fx_rain_light_looping");
	level._effect["fx_rain_xlight_oneshot"]						= LoadFx("env/weather/fx_rain_xlight_oneshot");
	level._effect["fx_rain_xlight_looping"]						= LoadFx("env/weather/fx_rain_xlight_looping");	


	level._effect["fx_water_drip_tree_xlight"]				= LoadFx("env/water/fx_water_drip_tree_xlight");
	level._effect["fx_water_drip_xlight_line"]				= LoadFx("env/water/fx_water_drip_xlight_line");
	level._effect["fx_water_drip_hvy_long"]						= LoadFx("env/water/fx_water_drip_hvy_long");	

	level._effect["fx_fog_low_hall_500"]						= LoadFx("env/smoke/fx_fog_low_hall_500");		
	level._effect["fx_fog_low_hall_1000"]						= LoadFx("env/smoke/fx_fog_low_hall_1000");	
	
	level._effect["fx_fire_cooking"]								= LoadFx("env/fire/fx_fire_cooking_kowloon");
	level._effect["fx_water_spill_sm"]							= LoadFx("env/water/fx_water_spill_sm");
	level._effect["fx_water_spill_md"]							= LoadFx("env/water/fx_water_roof_spill_md");
	level._effect["fx_water_spill_lg"]							= LoadFx("env/water/fx_water_roof_spill_lg");
	level._effect["fx_water_spill_sm_int"]					= LoadFx("env/water/fx_water_spill_sm_int");
	level._effect["fx_water_spill_sm_thin"]					= LoadFx("env/water/fx_water_spill_sm_thin");
	level._effect["fx_water_spill_sm_splash"]				= LoadFx("env/water/fx_water_spill_sm_splash");

	level._effect["fx_pipe_steam_md"]						    = LoadFx("env/smoke/fx_pipe_steam_md");
	level._effect["fx_smk_chimney_wht_kow"]		      = LoadFx("maps/kowloon/fx_smk_chimney_wht_kow");
	
	level._effect["fx_water_roof_spill_lg_hvy"]		    = LoadFx("env/water/fx_water_roof_spill_lg_hvy");	
	level._effect["fx_water_roof_spill_md_hvy"]		    = LoadFx("env/water/fx_water_roof_spill_md_hvy");	
	level._effect["fx_water_spill_md_spray"]		      = LoadFx("env/water/fx_water_spill_md_spray");
	level._effect["fx_water_sheeting_md_hvy"]					= LoadFx("env/water/fx_water_sheeting_md_hvy");
	level._effect["fx_water_sheeting_lg_hvy"]					= LoadFx("env/water/fx_water_sheeting_lg_hvy");
	level._effect["fx_water_roof_spill_lg_hvy_grav"]	= LoadFx("env/water/fx_water_roof_spill_lg_hvy_grav");	
	level._effect["fx_rain_splash_area_100_hvy_lp"]		= LoadFx("env/weather/fx_rain_splash_area_100_hvy_lp");	
	level._effect["fx_rain_splash_area_200_hvy_lp"]		= LoadFx("env/weather/fx_rain_splash_area_200_hvy_lp");	
	level._effect["fx_rain_splash_area_300_hvy_lp"]		= LoadFx("env/weather/fx_rain_splash_area_300_hvy_lp");
	level._effect["fx_rain_splash_area_400_hvy_lp"]		= LoadFx("env/weather/fx_rain_splash_area_400_hvy_lp");	
	level._effect["fx_rain_splash_area_500_hvy_lp"]		= LoadFx("env/weather/fx_rain_splash_area_500_hvy_lp");
						
		// Lights and godrays - DustMotes
	level._effect["fx_light_kow_ray_md_wide"]				= LoadFx("maps/kowloon/fx_light_kow_ray_md_wide");
	level._effect["fx_light_kow_ray_wide"]					= LoadFx("maps/kowloon/fx_light_kow_ray_wide");
	level._effect["fx_light_kow_ray_sm"]						= LoadFx("maps/kowloon/fx_light_kow_ray_sm");
	level._effect["fx_light_kow_ray_sm_thin"]				= LoadFx("maps/kowloon/fx_light_kow_ray_sm_thin");
	level._effect["fx_light_kow_ray_street"]				= LoadFx("maps/kowloon/fx_light_kow_ray_street");
	
	level._effect["fx_ray_lampost_white"]						= LoadFx("env/light/fx_ray_lampost_white");
	level._effect["fx_light_incandescent"]					= LoadFx("env/light/fx_light_incandescent");
	level._effect["fx_light_fluorescent"]				 		= LoadFx("env/light/fx_light_fluorescent");
	level._effect["fx_light_fluorescent_tubes"]			= LoadFx("env/light/fx_light_fluorescent_tubes");
	level._effect["fx_light_fluorescent_tubes_flkr"] = LoadFx("env/light/fx_light_fluorescent_tubes_flkr");
	level._effect["fx_light_dust_motes_xsm"]				= LoadFx("env/light/fx_light_dust_motes_xsm");
	level._effect["fx_light_dust_motes_xsm_short"]	= LoadFx("env/light/fx_light_dust_motes_xsm_short");
	level._effect["fx_light_dust_motes_sm"]					= LoadFx("env/light/fx_light_dust_motes_sm");
	level._effect["fx_light_dust_motes_md"]					= LoadFx("env/light/fx_light_dust_motes_md");
	
	level._effect["fx_light_glow_spot_flare"] 			= LoadFx("maps/kowloon/fx_light_glow_spot_flare");
	level._effect["fx_light_overhead"] 							= LoadFx("env/light/fx_light_overhead");
	
	level._effect["fx_sign_glow1"] 							= loadfx("maps/kowloon/fx_light_sign1_glow");
	level._effect["fx_sign_glow2"] 							= loadfx("maps/kowloon/fx_light_sign2_glow");
	level._effect["fx_sign_glow3"] 							= loadfx("maps/kowloon/fx_light_sign3_glow");
	level._effect["fx_sign_glow4"] 							= loadfx("maps/kowloon/fx_light_sign4_glow");
	level._effect["fx_sign_glow5"] 							= loadfx("maps/kowloon/fx_light_sign5_glow");
	level._effect["fx_sign_glow6"] 							= loadfx("maps/kowloon/fx_light_sign6_glow");
	level._effect["fx_sign_glow7"] 							= loadfx("maps/kowloon/fx_light_sign7_glow");
	level._effect["fx_sign_glow8"] 							= loadfx("maps/kowloon/fx_light_sign8_glow");
		
	// Exploders Kowloon
	level._effect["fx_glass_elbow_smash"]			        = LoadFx("maps/kowloon/fx_glass_elbow_smash"); // 1001
	level._effect["fx_kow_glass_glint"]		      		  = LoadFx("maps/kowloon/fx_kow_glass_glint");	// 10051
	
	level._effect["fx_glass_impact_int_room"]		      = LoadFx("maps/kowloon/fx_glass_impact_int_room");	// 1101
	level._effect["fx_large_metalhit"]		     				= LoadFx("impacts/fx_large_metalhit"); // 1101
	level._effect["fx_small_concrete"]		     				= LoadFx("impacts/fx_small_concrete"); // 1101	
	level._effect["fx_tracer_fake_concrete"]		     	= LoadFx("maps/kowloon/fx_tracer_fake_md_concrete"); // 1101
	level._effect["fx_tracer_fake_metal"]		     			= LoadFx("maps/kowloon/fx_tracer_fake_md_metal"); // 1101
	level._effect["fx_tracer_fake_glass"]		     			= LoadFx("maps/kowloon/fx_tracer_fake_sm_glass"); // 1101
				
	level._effect["fx_breach_wall_start"]			        = LoadFx("maps/kowloon/fx_breach_wall_start"); // 1201
	level._effect["fx_breach_door_wood"]			        = LoadFx("maps/kowloon/fx_breach_door_wood"); // 1301-1302
  level._effect["fx_gas_nova6_room_filler"]			    = LoadFx("maps/kowloon/fx_gas_nova6_room_filler"); // 2001
  level._effect["fx_ladder_ladder_light"]			      = LoadFx("maps/kowloon/fx_light_kow_ray_md_wide"); // 2101
	level._effect["fx_awning_jump_collapse"]			    = LoadFx("maps/kowloon/fx_awning_jump_collapse"); // 3101
	level._effect["fx_debris_mattress_impact"]			  = LoadFx("maps/kowloon/fx_debris_mattress_impact"); // 3102
	level._effect["fx_debris_frig_push"]			        = LoadFx("maps/kowloon/fx_debris_frig_push"); // 3103
	level._effect["fx_glass_rappel_window_smash"]			= LoadFx("maps/kowloon/fx_glass_rappel_window_smash"); // 3501
	level._effect["fx_debris_sliding_slow_mo"]		  	= LoadFx("maps/kowloon/fx_debris_sliding_slow_mo"); // 5001
	level._effect["fx_exp_heli_roof_explosion"]			  = LoadFx("maps/kowloon/fx_exp_heli_roof_explosion"); // 5501
	level._effect["fx_elec_sign_sparks_huge"]			    = LoadFx("maps/kowloon/fx_elec_sign_sparks_huge"); // 5551
	level._effect["fx_glass_impact_heli_building"]	  = LoadFx("maps/kowloon/fx_glass_impact_heli_building"); // 5601
	level._effect["fx_exp_heli_ground_explosion"]	    = LoadFx("maps/kowloon/fx_exp_heli_roof_explosion"); // 5701
	level._effect["fx_breach_door_metal"]			        = LoadFx("maps/kowloon/fx_breach_door_metal"); // 6001
	level._effect["fx_breach_ceiling_collapse"]			  = LoadFx("maps/kowloon/fx_breach_ceiling_collapse"); // 6101
	level._effect["fx_debris_flour_room_fill"]				= LoadFx("maps/kowloon/fx_debris_flour_room_fill");
	level._effect["fx_debris_sliding_roof"]			    	= LoadFx("maps/kowloon/fx_debris_sliding_roof"); // 8101
	level._effect["fx_elec_burst_shower_lg_os"]			  = LoadFx("env/electrical/fx_elec_burst_shower_lg_os"); // 8201
	level._effect["fx_awning_slide_collapse"]			    = LoadFx("maps/kowloon/fx_awning_slide_collapse"); // 9001
	level._effect["fx_van_garage_impact"]			      	= LoadFx("maps/kowloon/fx_van_garage_impact"); // 9101
	level._effect["fx_lightning_flash_single_lg"]			= LoadFx("env/weather/fx_lightning_flash_single_lg"); // 7001-7004
	level._effect["fx_light_tv_flicker"]		      		= LoadFx("maps/kowloon/fx_light_tv_flicker");	// 10001-
	
	// PLACEHOLDERS
  level._effect["fx_dust_crumble_sm_runner"]			= LoadFx("env/dirt/fx_dust_crumble_sm_runner");
	level._effect["fx_dust_crumble_md_runner"]			= LoadFx("env/dirt/fx_dust_crumble_md_runner");
	level._effect["fx_dust_crumble_int_sm"]					= LoadFx("env/dirt/fx_dust_crumble_int_sm");
	level._effect["fx_projector_motes"]							= LoadFx("props/fx_projector_motes");

	level._effect["fx_debris_papers"]								= LoadFx("env/debris/fx_debris_papers");
	level._effect["fx_debris_papers_windy_slow"]		= LoadFx("env/debris/fx_debris_papers_windy_slow");
	level._effect["fx_debris_papers_fall_burning"]	= LoadFx("env/debris/fx_debris_papers_fall_burning");
	level._effect["fx_debris_papers_obstructed"]		= LoadFx("env/debris/fx_debris_papers_obstructed");
	
// Electric stuff
	level._effect["fx_elec_burst_heavy_os"]					= LoadFx("env/electrical/fx_elec_burst_heavy_os");
	level._effect["fx_elec_burst_shower_sm_os_int"]	= LoadFx("env/electrical/fx_elec_burst_shower_sm_os_int");
	level._effect["fx_elec_burst_shower_sm_os"]			= LoadFx("env/electrical/fx_elec_burst_shower_sm_os");

	
// Smoke
	level._effect["fx_smk_plume_md_wht_wispy"]			= LoadFx("env/smoke/fx_smk_plume_md_wht_wispy");
	level._effect["fx_smk_plume_xsm_blk"]						= LoadFx("env/smoke/fx_smk_plume_xsm_blk");
	level._effect["fx_smk_plume_lg_wht"]						= LoadFx("env/smoke/fx_smk_plume_lg_wht");
	level._effect["fx_smk_plume_xlg_wht"]						= LoadFx("env/smoke/fx_smk_plume_xlg_wht");
	level._effect["fx_smk_plume_xlg_blk"]						= LoadFx("env/smoke/fx_smk_plume_xlg_blk");
	level._effect["fx_smk_plume_xlg_tall_blk"]			= LoadFx("env/smoke/fx_smk_plume_xlg_tall_blk");
	
	level._effect["fx_smk_fire_md_gray_int"]				= LoadFx("env/smoke/fx_smk_fire_md_gray_int");
	level._effect["fx_smk_fire_md_black"]						= LoadFx("env/smoke/fx_smk_fire_md_black");
	level._effect["fx_smk_fire_lg_black"]						= LoadFx("env/smoke/fx_smk_fire_lg_black");
	level._effect["fx_smk_fire_lg_white"]						= LoadFx("env/smoke/fx_smk_fire_lg_white");
	level._effect["fx_smk_smolder_rubble_md"]				= LoadFx("env/smoke/fx_smk_smolder_rubble_md");
	level._effect["fx_smk_smolder_rubble_lg"]				= LoadFx("env/smoke/fx_smk_smolder_rubble_lg");
	level._effect["fx_smk_smolder_sm_int"]					= LoadFx("env/smoke/fx_smk_smolder_sm_int");
	level._effect["fx_smk_hue_hallway_med"]					= LoadFx("maps/hue_city/fx_smk_hue_hallway_med");
	level._effect["fx_smk_hue_room_med"]						= LoadFx("maps/hue_city/fx_smk_hue_room_med");
	level._effect["fx_smk_haze_lg_os"]							= LoadFx("env/smoke/fx_smk_haze_lg_os");
	level._effect["fx_smk_hue_smolder_huge"]				= LoadFx("maps/hue_city/fx_smk_hue_smolder_huge");
	level._effect["fx_smk_field_xsm_int"]						= LoadFx("env/smoke/fx_smk_field_xsm_int");
	level._effect["fx_smk_field_sm_int"]						= LoadFx("env/smoke/fx_smk_field_sm_int");
	level._effect["fx_smk_linger_lit"]							= LoadFx("env/smoke/fx_smk_linger_lit");
	level._effect["fx_smk_ceiling_crawl"]						= LoadFx("env/smoke/fx_smk_ceiling_crawl");	
	
// Fires
	level._effect["fx_fire_destruction_distant_xlg"]= LoadFx("env/fire/fx_fire_destruction_distant_xlg");
	level._effect["fx_fire_detail_sm_nodlight"]			= LoadFx("env/fire/fx_fire_detail_sm_nodlight");
	level._effect["fx_fire_column_creep_xsm"]				= LoadFx("env/fire/fx_fire_column_creep_xsm");
	level._effect["fx_fire_column_creep_sm"]				= LoadFx("env/fire/fx_fire_column_creep_sm");
	level._effect["fx_fire_wall_md"]								= LoadFx("env/fire/fx_fire_wall_md");
	level._effect["fx_fire_ceiling_md"]							= LoadFx("env/fire/fx_fire_ceiling_md");
	level._effect["fx_fire_sm_smolder"]							= LoadFx("env/fire/fx_fire_sm_smolder");
	level._effect["fx_fire_md_smolder"]							= LoadFx("env/fire/fx_fire_md_smolder");
	level._effect["fx_fire_sm"]											= LoadFx("env/fire/fx_fire_sm");
	level._effect["fx_fire_md"]											= LoadFx("env/fire/fx_fire_md");
	level._effect["fx_fire_lg"]											= LoadFx("env/fire/fx_fire_lg");
}

wind_initial_setting()
{
	SetSavedDvar( "wind_global_vector", "152 50 0" );    // change "0 0 0" to your wind vector
	SetSavedDvar( "wind_global_low_altitude", 0);    // change 0 to your wind's lower bound
	SetSavedDvar( "wind_global_hi_altitude", 6000);    // change 10000 to your wind's upper bound
	SetSavedDvar( "wind_global_low_strength_percent", 0.3);    // change 0.5 to your desired wind strength percentage
}

main()
{
	initModelAnims();
	precache_util_fx();
	precache_createfx_fx();
	precache_scripted_fx();
	
	footsteps();
	
	maps\createfx\kowloon_fx::main();
	//maps\createart\kowloon_art::main(); //shabs - moving to onplayerconnect func in kowloon.gsc
	
	wind_initial_setting();

	level thread rain_controller();
}

footsteps()
{
	animscripts\utility::setFootstepEffect( "asphalt", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "brick", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "carpet", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "cloth", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "concrete", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "dirt", LoadFx( "bio/player/fx_footstep_sand" ) );
	animscripts\utility::setFootstepEffect( "foliage", LoadFx( "bio/player/fx_footstep_sand" ) );
	animscripts\utility::setFootstepEffect( "gravel", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "grass", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "metal", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "mud", LoadFx( "bio/player/fx_footstep_mud" ) );
	animscripts\utility::setFootstepEffect( "paper", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "plaster", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "rock", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "water", LoadFx( "bio/player/fx_footstep_water" ) );
	animscripts\utility::setFootstepEffect( "wood", LoadFx( "bio/player/fx_footstep_dust" ) );
}

//	Handles the rain effects 
//
rain_controller()
{
	wait( 1.0 );

	level.rain_fx = level._effect["fx_rain_sys_heavy_windy_1"];

	level thread rain_loop();

	flag_wait( "event3" );
	level.rain_fx = level._effect["fx_rain_sys_heavy_windy_2"];

	flag_wait( "event6" );
	level.rain_fx = level._effect["fx_rain_sys_heavy_windy_3"];
}


//	Play rain over the player's head
//
rain_loop()
{
	players = undefined;
	while ( !IsDefined(players) || players.size == 0 )
	{
		players = get_players();
		wait( 0.1 );
	}

	player = players[0];
	while (1)
	{
		pos = player.origin+(0,0,1000);
		PlayFX( level.rain_fx, pos );

		wait( 0.1 );
	}
}

