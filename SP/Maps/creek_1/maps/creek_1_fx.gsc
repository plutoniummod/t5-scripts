#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_anim;
#include maps\creek_1_util; 

#using_animtree("fxanim_props");


// fx used by util scripts
precache_util_fx()
{
	
}


// Scripted effects
precache_scripted_fx()
{
	level._effect["melee_blood"]						= LoadFX("maps/creek/fx_creek_contextual_melee1");
	level._effect["melee_rice"]					  	= LoadFX("maps/creek/fx_creek_contextual_melee2");

	level._effect["m202_death"]						  = LoadFX("impacts/fx_flesh_hit");
	level._effect["swift_death"]						= LoadFX("maps/creek/fx_creek_swift_death");
	
	level._effect["chicken_death"]					= LoadFX("bio/animals/fx_chicken_death_feathers");
	level._effect["crow_death"]							= LoadFX("bio/animals/fx_crow_death_feathers");
	level._effect["fish_emitter"]						= LoadFX("bio/animals/fx_fish_emitter");
	
	// Beat 1:
	level._effect["water_splash"]						= LoadFX("env/water/fx_water_splash_leak_md");
		
	// Beat 2:
	level._effect["flashlight_cone"]				= LoadFX("env/light/fx_spotlight_flashlight");	
	
	// pulling sampan vc into water
	level._effect["neck_stab_blood"]				= LoadFX("impacts/fx_melee_neck_stab_uw");	
	level._effect["water_drop_splash"]			= LoadFX("bio/player/fx_player_water_splash_impact");	
		
	// vc kill
	level._effect["flesh_hit"]							= LoadFX("impacts/fx_flesh_hit");

	// guy falling into water
	level._effect["falling_water_splash"]		= LoadFX("bio/player/fx_player_water_splash_impact"); // play at water level
	level._effect["falling_water_bubbles"]	= LoadFX("bio/player/fx_player_underwater_bubbles_emitter"); // play at a few tags on guy
	level._effect["falling_water_blood"]		= LoadFX("bio/player/fx_player_underwater_blood_emitter"); // play at guy's wound position

	// beat 3
	level._effect["grenade_explode"]				= LoadFX("explosions/fx_grenadeexp_dirt");
	// cache the effects needed for ratholes, put this in your level fx file.
	level._effect["rathole_smoke"]					= LoadFX("maps/creek/fx_exp_rat_tunnel");

	// Beat 4:
	level._effect["muzzle_flash"]						= LoadFX("weapon/muzzleflashes/fx_50cal_view");
	level._effect["water_bullet_hit"] 			= Loadfx("impacts/fx_small_waterhit");
	level._effect["dirt_bullet_hit"] 				= Loadfx("impacts/fx_small_dirt");
	level._effect["rpg_trail"]							= LoadFX("weapon/grenade/fx_trail_rpg");
	level._effect["water_rpg_hit"] 					= Loadfx("explosions/fx_mortarExp_water");

	level._effect["rocket_launch"] 					= Loadfx("weapon/rocket/fx_LCI_rocket_ignite_launch");
	level._effect["big_explosion"]					= LoadFX("explosions/fx_mortarExp_dirt");

	level._effect["muzzle_flash"]						= LoadFX("weapon/muzzleflashes/fx_heavy_flash_base");
	level._effect["lingering_fire"]					= LoadFX("env/fire/fx_fire_player_md");
	
	//precache effects
	level._effect["explosion"] 							= Loadfx("temp_effects/fx_tmp_exp_midair_large");
	level._effect["smoke"] 									= Loadfx("env/smoke/fx_smoke_plume_xlg_slow_blk");
	level._effect["water_splash"] 					= Loadfx("explosions/fx_mortarExp_water");
	level._effect["vehicle_explosion"] 			= Loadfx("explosions/fx_large_vehicle_explosion");

	level._effect["water_bullet_impact"] 		= Loadfx("impacts/fx_large_waterhit");

	// setup fx for defend mission
	level._effect["bullet_impact"]					= LoadFX("impacts/fx_large_dirt");
	level._effect["rpg_trail"]							= LoadFX("weapon/rocket/fx_LCI_rocket_geotrail");
	level._effect["rpg_explosion"]					= LoadFX("explosions/fx_mortarExp_dirt");
	level._effect["rpg_explosion_water"]		= LoadFX("explosions/fx_mortarExp_water");
	level._effect["flare"]									= LoadFX("misc/fx_flare_sky_white_10sec");
	level._effect["open_rat_door"]					= LoadFX("impacts/fx_large_mud");
	level._effect["battle_smoke"]						= LoadFX("env/smoke/fx_smoke_plume_xlg_slow_blk");

	// for village mission
	level._effect["water_splash"]						= LoadFX("vehicle/water/fx_wake_lvt_churn");
	level._effect["napalm_drop"]						= LoadFX("temp_effects/fx_tmp_exp_midair_large");
	level._effect["village_fire"]						= LoadFX("env/fire/fx_static_fire_md_ndlight");

	// calvary
	//precache 
	level._effect["vehicle_explosion"] 			= Loadfx("explosions/fx_large_vehicle_explosion");
	level._effect["aa_gun_explode"]					= Loadfx("explosions/fx_large_vehicle_explosion");
	level._effect["water_explode"]					= Loadfx("weapon/rocket/fx_rocket_exp_water");

	// tunnel footstep splash
	level._effect["tunnel_step_water"]			= LoadFX("maps/creek/fx_tunnel_fight_surface_splash");

	// Custom water splashes	
	level._effect["wake_idle"]							= LoadFX("bio/player/fx_player_water_waist_ripple");
	level._effect["swimming_wake"]					= LoadFX("system_elements/fx_water_ai_wake_emit");
	level._effect["water_splash_rise"]			= LoadFX("maps/creek/fx_water_barnes_splash");
	level._effect["water_splash_under"]			= LoadFX("maps/creek/fx_water_barnes_splash");
	level._effect["water_ankle_splash"]			= LoadFX("bio/player/fx_player_water_knee_ripple");

	// ending explosions
	level._effect["explosion_extreme"] = LoadFX("maps/pow/fx_pow_rocket_xtreme_exp_default");
	
	// tracers
	level._effect["ending_flash"] 			= LoadFX("weapon/muzzleflashes/fx_heavy_flash_base");
	level._effect["ending_flash_large"] = LoadFX("weapon/muzzleflashes/fx_zpu4_world");
	level._effect["pigeon_fly"] 				= LoadFX("bio/animals/fx_pigeon_panic_flight_med");
	
	level._effect["huey_main_blade"] = LoadFX("vehicle/props/fx_huey_main_blade_full");
	
	level._effect["huey_mg"] = LoadFX("weapon/muzzleflashes/fx_huey_minigun");
	
	level._effect["custom_sampan_exp"] = LoadFX("weapon/rocket/fx_rocket_xtreme_exp_mud");
}

// FXanim Props
initModelAnims()
{
	
	level.scr_anim["fxanim_props"]["a_crow_idle"][0] = %fxanim_gp_crow_look_anim;
	level.scr_anim["fxanim_props"]["a_crow_idle"][1] = %fxanim_gp_crow_eat_anim;
	level.scr_anim["fxanim_props"]["a_crow_idle"][2] = %fxanim_gp_crow_flap_anim;
	level.scr_anim["fxanim_props"]["a_crow_idle"][3] = %fxanim_gp_crow_jump_anim;
	level.scr_anim["fxanim_props"]["a_crow_die"] = %fxanim_gp_crow_die_anim;
	level.scr_anim["fxanim_props"]["a_crow_90rflyr"] = %fxanim_gp_crow_90rflyr_anim;
	
	level.scr_anim["fxanim_props"]["a_hut01"] = %fxanim_creek_hut01_anim;
	level.scr_anim["fxanim_props"]["a_windowdive"] = %fxanim_creek_windowdive_anim;
	level.scr_anim["fxanim_props"]["a_windowshoot"] = %fxanim_creek_windowshoot_anim;
	level.scr_anim["fxanim_props"]["a_banner"] = %fxanim_creek_banner_anim;
	level.scr_anim["fxanim_props"]["a_junk1"] = %fxanim_creek_junk1_anim;
	level.scr_anim["fxanim_props"]["a_junk2"] = %fxanim_creek_junk2_anim;
	level.scr_anim["fxanim_props"]["a_junk3"] = %fxanim_creek_junk3_anim;
	level.scr_anim["fxanim_props"]["a_waterhut"] = %fxanim_creek_waterhut_anim;
	level.scr_anim["fxanim_props"]["a_vinecluster"] = %fxanim_creek_vinecluster_anim;
	level.scr_anim["fxanim_props"]["a_mg"] = %fxanim_creek_mg_anim;
	level.scr_anim["fxanim_props"]["a_mgcurtainside"] = %fxanim_creek_mgcurtainside_anim;
	level.scr_anim["fxanim_props"]["a_mgcurtainfront"] = %fxanim_creek_mgcurtainfront_anim;
	level.scr_anim["fxanim_props"]["a_overhang"] = %fxanim_creek_overhang_anim;
	level.scr_anim["fxanim_props"]["a_snakeswim"] = %fxanim_gp_snakeswim_anim;
	level.scr_anim["fxanim_props"]["a_chickencoop"] = %fxanim_creek_chickencoop_anim;
	level.scr_anim["fxanim_props"]["a_cover"] = %fxanim_creek_cover_anim;
	level.scr_anim["fxanim_props"]["a_hueydamage"] = %fxanim_creek_hueydamage_anim;
	level.scr_anim["fxanim_props"]["a_rat_01"] = %fxanim_creek_rat_01_anim;
	level.scr_anim["fxanim_props"]["a_rat_02"] = %fxanim_creek_rat_02_anim;
	level.scr_anim["fxanim_props"]["a_rat_03"] = %fxanim_creek_rat_03_anim;
	level.scr_anim["fxanim_props"]["a_mgexplode"] = %fxanim_creek_mgexplode_anim;
	level.scr_anim["fxanim_props"]["a_rat_hole_lid"] = %fxanim_creek_rat_hole_lid_anim;
	level.scr_anim["fxanim_props"]["a_cave_pillar"] = %fxanim_creek_cave_pillar_anim;
	level.scr_anim["fxanim_props"]["a_cave_bolder"] = %fxanim_creek_cave_bolder_anim;
	level.scr_anim["fxanim_props"]["a_cave_bolder_ceiling"] = %fxanim_creek_cave_bolder_ceiling_anim;
	level.scr_anim["fxanim_props"]["a_nets"] = %fxanim_creek_net_anim;
	level.scr_anim["fxanim_props"]["a_tarp_cover01"] = %fxanim_creek_tarp_cover01_anim;
	level.scr_anim["fxanim_props"]["a_crane01"] = %fxanim_creek_crane01_anim;
	level.scr_anim["fxanim_props"]["a_crane02"] = %fxanim_creek_crane02_anim;
	level.scr_anim["fxanim_props"]["a_cave_sprinkle"] = %fxanim_creek_cave_sprinkle_anim;
	level.scr_anim["fxanim_props"]["a_cave_fill"] = %fxanim_creek_cave_fill_anim;
	level.scr_anim["fxanim_props"]["a_bamboo_01"] = %fxanim_creek_cave_pillar_break_high_anim;
	level.scr_anim["fxanim_props"]["a_bamboo_02"] = %fxanim_creek_cave_pillar_break_med_anim;
	level.scr_anim["fxanim_props"]["a_bamboo_03"] = %fxanim_creek_cave_pillar_break_low_anim;
	level.scr_anim["fxanim_props"]["a_cave_panel"] = %fxanim_creek_cave_panel_anim;
	level.scr_anim["fxanim_props"]["a_warroom_wires"] = %fxanim_creek_warroom_wires_anim;
	level.scr_anim["fxanim_props"]["a_warroom_flags"] = %fxanim_creek_warroom_flags_anim;
	level.scr_anim["fxanim_props"]["a_warroom_rocks"] = %fxanim_creek_warroom_rocks_anim;
	level.scr_anim["fxanim_props"]["a_zpu_hut"] = %fxanim_creek_zpu_hut_anim;
	level.scr_anim["fxanim_props"]["a_warroom_door_kick"] = %fxanim_creek_door_kick_anim;
	
	
  ent1 = getent( "fxanim_creek_vinecluster_mod", "targetname" );
	ent2 = getent( "fxanim_creek_fish1_mod", "targetname" );
	ent3 = getent( "fxanim_creek_mg_mod", "targetname" );
	ent4 = getent( "fxanim_creek_overhang_mod", "targetname" );	
	ent5 = getent( "fxanim_creek_mgcurtainfront_mod", "targetname" );
	ent6 = getent( "fxanim_gp_crow_mod_01", "targetname" );
	ent7 = getent( "fxanim_gp_crow_mod_02", "targetname" );
	ent8 = getent( "fxanim_gp_crow_mod_03", "targetname" );
	ent9 = getent( "fxanim_creek_hut01_mod", "targetname" );
	ent10 = getent( "fxanim_creek_windowdive_mod", "targetname" );
	ent11 = getent( "fxanim_creek_windowshoot_mod", "targetname" );
	ent12 = getent( "fxanim_creek_banner_mod", "targetname" );
	ent13 = getent( "fxanim_creek_junk1_mod", "targetname" );
	ent14 = getent( "fxanim_creek_junk2_mod", "targetname" );
	ent15 = getent( "fxanim_creek_junk3_mod", "targetname" );
	ent16 = getent( "fxanim_creek_waterhut_mod", "targetname" );

	ent18 = getent( "fxanim_gp_snakeswim_mod", "targetname" );
	ent19 = getent( "fxanim_creek_chickencoop_mod", "targetname" );
	ent20 = getent( "fxanim_creek_cover_mod", "targetname" );
	ent21 = getent( "fxanim_creek_hueydamage_mod", "targetname" );
	ent22 = getent( "creek_rat_01", "targetname" );
	ent23 = getent( "creek_rat_02", "targetname" );
	ent24 = getent( "creek_rat_03", "targetname" );
	ent25 = getent( "fxanim_gp_crow_mod_04", "targetname" );
	ent26 = getent( "fxanim_gp_crow_mod_05", "targetname" );
	ent27 = getent( "fxanim_creek_hueywire_mod", "targetname" );
	ent28 = getent( "fxanim_creek_mgexplode_mod", "targetname" );
	ent29 = getent( "rat_hole_lid_01", "targetname" );
	ent30 = getent( "rat_hole_lid_02", "targetname" );
	ent31 = getent( "bamboo_03_mod", "targetname" );
	ent32 = getent( "fxanim_creek_cave_bolder_mod", "targetname" );
	ent33 = getent( "fxanim_creek_cave_bolder_ceiling_mod", "targetname" );
	ent34 = getent( "crane01_mod", "targetname" );
	ent35 = getent( "crane02_mod", "targetname" );
	ent36 = getent( "fxanim_creek_cave_sprinkle_mod", "targetname" );
	ent37 = getent( "fxanim_creek_cave_fill_mod", "targetname" );
	ent38 = getent( "bamboo_01_mod", "targetname" );
	ent39 = getent( "bamboo_02_mod", "targetname" );
	ent40 = getent( "fxanim_creek_cave_panel_mod", "targetname" );
	ent41 = getent( "fxanim_creek_warroom_wires_mod", "targetname" );
	ent42 = getent( "fxanim_creek_warroom_flags_mod", "targetname" );
	ent43 = getent( "fxanim_creek_warroom_rocks_mod", "targetname" );
	ent44 = getent( "fxanim_creek_zpu_hut_mod", "targetname" );
	ent45 = getent( "fxanim_creek_door_kick_mod", "targetname" );
	
	enta_mgcurtainside = getentarray( "fxanim_creek_mgcurtainside_mod", "targetname" );
	enta_nets = getentarray( "fxanim_creek_nets", "targetname" );
	enta_tarp_cover01 = getentarray( "fxanim_creek_tarp_cover01_mod", "targetname" );

	
	if (IsDefined(ent1)) 
	{
		ent1 thread vinecluster();
	}
	
	if (IsDefined(ent2)) 
	{
		ent2 thread fish1();
	}
	
	if (IsDefined(ent3)) 
	{
		ent3 thread mg();
	}
	
	if (IsDefined(ent4)) 
	{
		ent4 thread overhang();
	}	
	
	if (IsDefined(ent5)) 
	{
		ent5 thread mgcurtainfront();
	}
	
	if (IsDefined(ent6)) 
	{
		ent6 thread crow_01();
	}
	
	if (IsDefined(ent7)) 
	{
		ent7 thread crow_02();
	}
	
	if (IsDefined(ent8)) 
	{
		ent8 thread crow_03();
	}
	
	if (IsDefined(ent9)) 
	{
		ent9 thread hut01();
	}
	
	if (IsDefined(ent10)) 
	{
		ent10 thread windowdive();
	}
	
	if (IsDefined(ent11)) 
	{
		ent11 thread windowshoot();
	}
	
	if (IsDefined(ent12)) 
	{
		ent12 thread banner();
	}
	
	if (IsDefined(ent13)) 
	{
		ent13 thread junk1();
	}
	
	if (IsDefined(ent14)) 
	{
		ent14 thread junk2();
	}
	
	if (IsDefined(ent15)) 
	{
		ent15 thread junk3();
	}
	
	if (IsDefined(ent16)) 
	{
		ent16 thread waterhut();
	}	
	
	for(i=0; i<enta_mgcurtainside.size; i++)
	{
 		enta_mgcurtainside[i] thread mgcurtainside();   
 		enta_mgcurtainside[i] thread mgcurtainside_2();  
	}
	
	if (IsDefined(ent18)) 
	{
		ent18 thread snakeswim();
	}
	
	if (IsDefined(ent19)) 
	{
		ent19 thread chickencoop();
	}
	
	if (IsDefined(ent20)) 
	{
		ent20 thread cover();
	}
	
	if (IsDefined(ent21)) 
	{
		ent21 thread hueydamage();
	}
	
	if (IsDefined(ent22)) 
	{
		ent22 thread rat_01();
	}
	
	if (IsDefined(ent23)) 
	{
		ent23 thread rat_02();
	}
	
	if (IsDefined(ent24)) 
	{
		ent24 thread rat_03();
	}
	
	if (IsDefined(ent25)) 
	{
		ent25 thread crow_04();
	}
	
	if (IsDefined(ent26)) 
	{
		ent26 thread crow_05();
	}

	if (IsDefined(ent28)) 
	{
		ent28 thread mgexplode();
	}
	
	if (IsDefined(ent29)) 
	{
		ent29 thread rat_hole_lid_01();
	}
	
	if (IsDefined(ent30)) 
	{
		ent30 thread rat_hole_lid_02();
	}
	
	if (IsDefined(ent31)) 
	{
		ent31 thread bamboo_03();
	}
	
	if (IsDefined(ent32)) 
	{
		ent32 thread cave_bolder();
	}
	
	if (IsDefined(ent33)) 
	{
		ent33 thread cave_bolder_ceiling();
	}
	
	for(i=0; i<enta_nets.size; i++)
	{
 		enta_nets[i] thread nets(1,3);
	}
	
	for(i=0; i<enta_tarp_cover01.size; i++)
	{
 		enta_tarp_cover01[i] thread tarp_cover01(1,3);
	}
	
	if (IsDefined(ent34)) 
	{
		ent34 thread crane01();
	}
	
	if (IsDefined(ent35)) 
	{
		ent35 thread crane02();
	}
	
	if (IsDefined(ent36)) 
	{
		ent36 thread cave_sprinkle();
	}
	
	if (IsDefined(ent37)) 
	{
		ent37 thread cave_fill();
	}
	
	if (IsDefined(ent38)) 
	{
		ent38 thread bamboo_01();
	}
	
	if (IsDefined(ent39)) 
	{
		ent39 thread bamboo_02();
	}
		
	if (IsDefined(ent40)) 
	{
		ent40 thread cave_panel();
	}
	
	if (IsDefined(ent41)) 
	{
		ent41 thread warroom_wires();
	}
	
	if (IsDefined(ent42)) 
	{
		ent42 thread warroom_flags();
	}
	
	if (IsDefined(ent43)) 
	{
		ent43 thread warroom_rocks();
	}
	
	if (IsDefined(ent44)) 
	{
		ent44 thread zpu_hut();
	}
	
	if (IsDefined(ent45)) 
	{
		ent45 thread warroom_door_kick();
	}
}


vinecluster()
{
	wait(1);
	self UseAnimTree(#animtree);
	self animscripted("a_vinecluster", self.origin, self.angles, %fxanim_creek_vinecluster_anim);
}

fish1()
{
	level waittill("fish1_start");
	self UseAnimTree(#animtree);
	self animscripted("a_fish1", self.origin, self.angles, %fxanim_creek_fish1_anim);
}

mg()
{
	level waittill("mg_start");
	level thread temp_delayed_finish();
	self UseAnimTree(#animtree);
	anim_single(self, "a_mg", "fxanim_props");
}

temp_delayed_finish()
{
	wait( 0.05 );
	level notify( "mg_reveal_finishes" ); 
}

overhang()
{
	level waittill("overhang_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_overhang", "fxanim_props");
}

mgcurtainside()
{
	level waittill("mg_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_mgcurtainside", "fxanim_props");
}

mgcurtainside_2()
{
	level waittill("mgexplode_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_mgcurtainside", "fxanim_props");
}

mgcurtainfront()
{
	level waittill("mg_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_mgcurtainfront", "fxanim_props");
}

crow_idle( fly_away_notify )
{
	if( isdefined( fly_away_notify ) )
	{
		level endon( fly_away_notify );
	}
	
	self UseAnimTree(#animtree);
	self SetCanDamage(true);
	
	self thread crow_idle_loop();

	self waittill("damage");
	playfxontag(level._effect["crow_death"],self,"chest_jnt");
	anim_single(self, "a_crow_die", "fxanim_props");
}

crow_idle_loop()
{
	self endon("damage");
	
	if( isdefined( self.fly_away ) )
	{
		while( self.fly_away == false )
		{
			anim_single(self, "a_crow_idle", "fxanim_props");
			self notify("idle_done");
		}
	}
	else
	{
		while( 1 )
		{
			anim_single(self, "a_crow_idle", "fxanim_props");
		}
	}
}

crow_idle_and_fly_away( fly_away_notify )
{
	self.fly_away = false;
	self thread crow_idle( fly_away_notify );
	level waittill( fly_away_notify );
	self.fly_away = true;
	self waittill("idle_done");
	self playsound ("amb_crow_fly");
	anim_single(self, "a_crow_90rflyr", "fxanim_props");
}

crow_delete()
{
	self delete();
}

crow_01()
{
	wait(1);	
	self crow_idle_and_fly_away( "fly_away_1" );
	
	self crow_delete();
}

crow_02()
{
	wait(1);
	self crow_idle_and_fly_away( "fly_away_2" );
//	self playsound ("amb_crow_fly");
	self crow_delete();
}

crow_03()
{
	wait(1);
	self crow_idle();
}

crow_04()
{
	wait(1);
	self crow_idle();
}

crow_05()
{
	wait(1);
	self crow_idle_and_fly_away( "fly_away_5" );

	self crow_delete();
}

hut01()
{
	level waittill("hut01_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_hut01", "fxanim_props");
}

windowdive()
{
	level waittill("windowdive_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_windowdive", "fxanim_props");
}

windowshoot()
{
	level waittill("windowshoot_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_windowshoot", "fxanim_props");
}

banner()
{
	self UseAnimTree(#animtree);
	self SetCanDamage(true);
	self.health = 99999;
	self.fake_health = 100;

	self thread wait_for_ais_to_appear( "junk_2_falls_down" );
	self thread wait_for_player_damage( "junk_2_falls_down" );
	self waittill( "junk_2_falls_down" );
	
	anim_single(self, "a_banner", "fxanim_props");
}

junk1()
{
	self UseAnimTree(#animtree);
	self SetCanDamage(true);
	self waittill("damage");
	anim_single(self, "a_junk1", "fxanim_props");
}

junk2()
{
	self UseAnimTree(#animtree);
	self SetCanDamage(true);
	self.health = 99999;
	self.fake_health = 100;
	
	self thread wait_for_ais_to_appear( "junk_2_falls_down" );
	self thread wait_for_player_damage( "junk_2_falls_down" );
	self waittill( "junk_2_falls_down" );
	
	anim_single(self, "a_junk2", "fxanim_props");
}

wait_for_ais_to_appear( msg )
{
	self endon( msg );
	level waittill( "last_calvary_target_done" );
	wait( 4.5 );
	self notify( msg );
}

wait_for_player_damage( msg )
{
	self endon( msg );
	while( 1 )
	{
		self waittill( "damage", amount, attacker );
		if( isplayer( attacker ) )
		{
			self.fake_health -= amount;
			if( self.fake_health <= 0 )
			{
				break;
			}
		}
	}
	self notify( msg );
}

junk3()
{
	self UseAnimTree(#animtree);
	self SetCanDamage(true);
	self waittill("damage");
	anim_single(self, "a_junk3", "fxanim_props");
}

waterhut()
{
	level waittill("waterhut_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_waterhut", "fxanim_props");
}

snakeswim()
{
	level waittill("snakeswim_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_snakeswim", "fxanim_props");
	self delete();
}

chickencoop()
{
	level waittill("chickencoop_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_chickencoop", "fxanim_props");
}

cover()
{
	level waittill("cover_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_cover", "fxanim_props");
}

hueydamage()
{
	wait(.5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_hueydamage", "fxanim_props");
}

rat_01()
{
	level waittill("creek_rats_start");
	self PlaySound( "amb_anml_rat_squeak_1" );
	self UseAnimTree(#animtree);
	anim_single(self, "a_rat_01", "fxanim_props");
	self delete();
}

rat_02()
{
	level waittill("creek_rats_start");
	self PlaySound( "amb_anml_rat_squeak_2" );
	self UseAnimTree(#animtree);
	anim_single(self, "a_rat_02", "fxanim_props");
	self delete();
}

rat_03()
{
	level waittill("creek_rats_start");
	self PlaySound( "amb_anml_rat_squeak_3" );
	self UseAnimTree(#animtree);
	anim_single(self, "a_rat_03", "fxanim_props");
	self delete();
}

mgexplode()
{
	level waittill("mgexplode_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_mgexplode", "fxanim_props");
}

rat_hole_lid_01()
{
	level waittill("rat_hole_lid_01_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_rat_hole_lid", "fxanim_props");
}

rat_hole_lid_02()
{
	level waittill("rat_hole_lid_02_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_rat_hole_lid", "fxanim_props");
}

bamboo_03()
{
	level waittill("bamboo_03_start");
	self PlaySound( "evt_tuco_pillar_snap_2" );
	self PlaySound( "evt_tuco_ambient_elements" );
	self PlaySound( "evt_tuco_earthquake_oneshot" );
	self UseAnimTree(#animtree);
	anim_single(self, "a_bamboo_03", "fxanim_props");
}

cave_bolder()
{
	level waittill("cave_bolder_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_cave_bolder", "fxanim_props");
}

cave_bolder_ceiling()
{
	level waittill("cave_bolder_ceiling_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_cave_bolder_ceiling", "fxanim_props");
}

nets(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_nets", "fxanim_props");
}

tarp_cover01(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_tarp_cover01", "fxanim_props");
}

crane01()
{
	level waittill("cranes_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_crane01", "fxanim_props");
	self delete();
}

crane02()
{
	level waittill("cranes_start");
	wait(.5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_crane02", "fxanim_props");
	self delete();
}

cave_sprinkle()
{
	level waittill("cave_sprinkle_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_cave_sprinkle", "fxanim_props");
}

cave_fill()
{
	level waittill("cave_fill_start");
	self UseAnimTree(#animtree);
	thread anim_single(self, "a_cave_fill", "fxanim_props");
	
	flag_wait( "cave_rock_swap" );
	flag_set( "cave_fill_complete" );

		// spawn in the new rock model
	new_rock = getent( "cave_breakout_rock", "targetname" );
	new_rock.animname = "tunnel_rock";
	anim_node = getstruct( "b4_anim_tunnel_out", "targetname" );
	level thread maps\creek_1_anim::play_creek_object_anim_firstframe( new_rock, anim_node, "breakout1" );
	wait( 0.05 );
	self delete();
}

bamboo_01()
{
	level waittill("bamboo_01_start");
	self PlaySound( "evt_tuco_pillar_snap_0" );
	self PlaySound( "evt_tuco_ambient_elements" );
	self PlaySound( "evt_tuco_earthquake_oneshot" );
	self UseAnimTree(#animtree);
	anim_single(self, "a_bamboo_01", "fxanim_props");
}

bamboo_02()
{
	level waittill("bamboo_02_start");
	self PlaySound( "evt_tuco_pillar_snap_1" );
	self PlaySound( "evt_tuco_ambient_elements" );
	self PlaySound( "evt_tuco_earthquake_oneshot" );
	self UseAnimTree(#animtree);
	anim_single(self, "a_bamboo_02", "fxanim_props");
}

cave_panel()
{
	level waittill("cave_panel_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_cave_panel", "fxanim_props");
}

warroom_wires()
{
	level waittill("warroom_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_warroom_wires", "fxanim_props");
}

warroom_flags()
{
	level waittill("warroom_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_warroom_flags", "fxanim_props");
}

warroom_rocks()
{
	level waittill("warroom_start");
	wait(1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_warroom_rocks", "fxanim_props");
}

zpu_hut()
{
	level waittill("zpu_hut_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_zpu_hut", "fxanim_props");
}

warroom_door_kick()
{
	level waittill("warroom_door_kick_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_warroom_door_kick", "fxanim_props");
}

// FXanim Props Delayed
initModelAnims_delay()
{
	enta_fish2 = getentarray( "fxanim_creek_fish2_mod", "targetname" );
	enta_fish3 = getentarray( "fxanim_creek_fish3_mod", "targetname" );
	enta_vinemed = getentarray( "fxanim_gp_vinemed", "targetname" );
	enta_vinesm = getentarray( "fxanim_gp_vinesm", "targetname" );
	enta_leafmed = getentarray( "fxanim_gp_leafmed", "targetname" );
	enta_leafsm = getentarray( "fxanim_gp_leafsm", "targetname" );
	enta_shirts01 = getentarray( "fxanim_gp_shirts01", "targetname" );
	enta_shirts02 = getentarray( "fxanim_gp_shirts02", "targetname" );
	enta_pants01 = getentarray( "fxanim_gp_pants01", "targetname" );
	enta_huey_debris01 = getentarray( "huey_debris01_anim", "targetname" );
	enta_huey_debris02 = getentarray( "huey_debris02_anim", "targetname" );
	enta_huey_debris03 = getentarray( "huey_debris03_anim", "targetname" );
	enta_huey_debris04 = getentarray( "huey_debris04_anim", "targetname" );
	enta_huey_debris05 = getentarray( "huey_debris05_anim", "targetname" );
	enta_roaches = getentarray( "fxanim_gp_roaches_mod", "targetname" );
		
	for(i=0; i<enta_fish2.size; i++)
	{
 		enta_fish2[i] thread fish2(1,10);   
	}
	for(i=0; i<enta_fish3.size; i++)
	{
 		enta_fish3[i] thread fish3(1,3);   
	}
	for(i=0; i<enta_vinemed.size; i++)
	{
 		enta_vinemed[i] thread vinemed(1,3);    
	}
	for(i=0; i<enta_vinesm.size; i++)
	{
 		enta_vinesm[i] thread vinesm(1,3);   
	}
	for(i=0; i<enta_leafmed.size; i++)
	{
 		enta_leafmed[i] thread leafmed(1,3);    
	}
	for(i=0; i<enta_leafsm.size; i++)
	{
 		enta_leafsm[i] thread leafsm(1,3);    
	}
	for(i=0; i<enta_shirts01.size; i++)
	{
 		enta_shirts01[i] thread shirts01(1,3);   
	}
	for(i=0; i<enta_shirts02.size; i++)
	{
 		enta_shirts02[i] thread shirts02(1,3);    
	}
	for(i=0; i<enta_pants01.size; i++)
	{
 		enta_pants01[i] thread pants01(1,3);   
	}
	for(i=0; i<enta_huey_debris01.size; i++)
	{
 		enta_huey_debris01[i] thread huey_debris01(1,3);   
	}
	for(i=0; i<enta_huey_debris02.size; i++)
	{
 		enta_huey_debris02[i] thread huey_debris02(1,3);    
	}
	for(i=0; i<enta_huey_debris03.size; i++)
	{
 		enta_huey_debris03[i] thread huey_debris03(1,3);     
	}
	for(i=0; i<enta_huey_debris04.size; i++)
	{
 		enta_huey_debris04[i] thread huey_debris04(1,3);    
	}
	for(i=0; i<enta_huey_debris05.size; i++)
	{
 		enta_huey_debris05[i] thread huey_debris05(1,3);   
	}
	for(i=0; i<enta_roaches.size; i++)
	{
 		enta_roaches[i] thread roaches(1,3);   
	}
}

#using_animtree("fxanim_props");
fish2(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_fish2", self.origin, self.angles, %fxanim_creek_fish2_anim);
}

#using_animtree("fxanim_props");
fish3(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_fish3", self.origin, self.angles, %fxanim_creek_fish3_anim);
}

#using_animtree("fxanim_props");
vinemed(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_vinemed", self.origin, self.angles, %fxanim_gp_vinemed_anim);
}

#using_animtree("fxanim_props");
vinesm(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_vinesm", self.origin, self.angles, %fxanim_gp_vinesm_anim);
}

#using_animtree("fxanim_props");
leafmed(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_leafmed", self.origin, self.angles, %fxanim_gp_leafmed_anim);
}

#using_animtree("fxanim_props");
leafsm(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_leafsm", self.origin, self.angles, %fxanim_gp_leafsm_anim);
}

#using_animtree("fxanim_props");
shirts01(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_shirts01", self.origin, self.angles, %fxanim_gp_shirt01_anim);
}

#using_animtree("fxanim_props");
shirts02(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_shirts02", self.origin, self.angles, %fxanim_gp_shirt02_anim);
}

#using_animtree("fxanim_props");
pants01(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_pants01", self.origin, self.angles, %fxanim_gp_pant01_anim);
}

#using_animtree("fxanim_props");
huey_debris01(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_huey_debris01", self.origin, self.angles, %fxanim_creek_huey_debris01_anim);
}

#using_animtree("fxanim_props");
huey_debris02(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_huey_debris02", self.origin, self.angles, %fxanim_creek_huey_debris02_anim);
}

#using_animtree("fxanim_props");
huey_debris03(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_huey_debris03", self.origin, self.angles, %fxanim_creek_huey_debris03_anim);
}

#using_animtree("fxanim_props");
huey_debris04(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_huey_debris04", self.origin, self.angles, %fxanim_creek_huey_debris04_anim);
}

#using_animtree("fxanim_props");
huey_debris05(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_huey_debris05", self.origin, self.angles, %fxanim_creek_huey_debris05_anim);
}

#using_animtree("fxanim_props");
roaches(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	self animscripted("a_roaches", self.origin, self.angles, %fxanim_gp_roaches_anim);
}

// Ambient effects
precache_createfx_fx()
{
	level._effect["fx_fog_low"]												= loadfx("env/smoke/fx_fog_low");
	level._effect["fx_fog_low_sm"]										= loadfx("env/smoke/fx_fog_low_sm");

  level._effect["fx_rain_splash_detail"]						= loadfx("env/weather/fx_rain_splash_detail");
	level._effect["fx_rain_mist"]											= loadfx("env/weather/fx_rain_mist");
	level._effect["fx_rain_mist_sm"]									= loadfx("env/weather/fx_rain_mist_sm");
	level._effect["fx_rain_heavy_looping"]						= loadfx("env/weather/fx_rain_heavy_looping");
	level._effect["fx_rain_light_looping"]						= loadfx("env/weather/fx_rain_light_looping");
	level._effect["fx_rain_xlight_oneshot"]						= loadfx("env/weather/fx_rain_xlight_oneshot");
	level._effect["fx_rain_xlight_looping"]						= loadfx("env/weather/fx_rain_xlight_looping");	
	level._effect["fx_rain_splash_swimming_xlg"]			= loadfx("env/weather/fx_rain_splash_swimming_xlg");	
	level._effect["fx_rain_splash_swimming_lg"]				= loadfx("env/weather/fx_rain_splash_swimming_lg");	

	level._effect["fx_water_drip_tree_xlight"]				= loadfx("env/water/fx_water_drip_tree_xlight");
	level._effect["fx_water_drip_xlight_line"]				= loadfx("env/water/fx_water_drip_xlight_line");
	level._effect["fx_water_drip_hvy_long"]						= loadfx("env/water/fx_water_drip_hvy_long");	

	level._effect["fx_water_wake_sanpan"]							= loadfx("maps/creek/fx_water_wake_sanpan");
	level._effect["fx_water_wake_sanpan_med"]					= loadfx("maps/creek/fx_water_wake_sanpan_med");	
	level._effect["fx_water_wake_sanpan_sm"]					= loadfx("maps/creek/fx_water_wake_sanpan_sm");	

	level._effect["fx_water_wake_creek"]							= loadfx("env/water/fx_water_wake_creek");		
	level._effect["fx_water_wake_creek_mouth"]				= loadfx("env/water/fx_water_wake_creek_mouth");
	level._effect["fx_water_wake_creek_mouth_froth"]	= loadfx("env/water/fx_water_wake_creek_mouth_froth");
	level._effect["fx_water_splash_creek_rocks"]			= loadfx("maps/creek/fx_water_splash_creek_rocks");	
	level._effect["fx_water_splash_creek_rocks_sm"]		= loadfx("maps/creek/fx_water_splash_creek_rocks_sm");
	level._effect["fx_water_fall_sm"]									= loadfx("maps/creek/fx_water_fall_sm");
	level._effect["fx_water_fall_xsm"]								= loadfx("maps/creek/fx_water_fall_xsm");		
	level._effect["fx_water_fall_mist"]								= loadfx("maps/creek/fx_water_fall_mist");		
	level._effect["fx_water_wake_creek_flow"]					= loadfx("maps/creek/fx_water_wake_creek_flow");	

	level._effect["fx_water_river_shore"]							= loadfx("maps/creek/fx_water_river_shore");

	level._effect["fx_water_bubble_column"]						= loadfx("env/water/fx_water_bubble_column");
	level._effect["fx_water_bubble_column_thin_sm"]		= loadfx("env/water/fx_water_bubble_column_thin_sm");	
	
	level._effect["fx_insects_ambient_lg"]						= loadfx("maps/creek/fx_insect_swarm_lg");	
	level._effect["fx_insects_dragonflies_ambient"]		= loadfx("bio/insects/fx_insects_dragonflies_ambient");
	level._effect["fx_pigeon_panic_flight_med"]				= loadfx("bio/animals/fx_pigeon_panic_flight_med");
	
	level._effect["fx_leaves_falling_lite"]						= loadfx("env/foliage/fx_leaves_falling_lite");
	
	// tunnel effects
	level._effect["fx_fog_tunnel_sm"]									= loadfx("maps/creek/fx_fog_tunnel_sm");
	level._effect["fx_fog_tunnel_md"]									= loadfx("maps/creek/fx_fog_tunnel_md");
	level._effect["fx_water_drips_tunnel"]						= loadfx("maps/creek/fx_water_drips_tunnel");
	level._effect["fx_water_drips_wtr_tunnel"]				= loadfx("maps/creek/fx_water_drips_wtr_tunnel");
	level._effect["fx_tunnel_fight_vc_drown"]					= loadfx("maps/creek/fx_tunnel_fight_vc_drown");				// 3011
	level._effect["fx_tunnel_fight_vc_blood_cloud"]		= loadfx("maps/creek/fx_tunnel_fight_vc_blood_cloud");	// 3012
	level._effect["fx_tunnel_fight_vc_splash"]				= loadfx("maps/creek/fx_tunnel_fight_vc_splash");				// 3010
	level._effect["fx_tunnel_roach_scurry"]						= loadfx("maps/creek/fx_tunnel_roach_scurry");					// 3020-3022,3024-3031
	level._effect["fx_tunnel_light_exit"]							= loadfx("maps/creek/fx_tunnel_light_exit");
	level._effect["fx_tunnel_godray_exit"]						= loadfx("maps/creek/fx_tunnel_godray_exit");
	level._effect["fx_tunnel_water_foam"]							= loadfx("maps/creek/fx_tunnel_water_foam");
	level._effect["fx_tunnel_reznov_impact"]					= loadfx("maps/creek/fx_tunnel_reznov_impact");					// 3009
	
	// 4500  ceiling dust before main room explosions  
	level._effect["fx_exp_war_room"]									= loadfx("maps/creek/fx_exp_war_room"); // 4501-4506
	level._effect["fx_dirt_tunnel_collapse"]					= loadfx("maps/creek/fx_dirt_tunnel_collapse"); // 5010-
	level._effect["fx_cave_pillar_crush"]							= loadfx("maps/creek/fx_cave_pillar_crush"); // 5010-plays with above effect
	level._effect["fx_cave_rock_hit"]									= loadfx("maps/creek/fx_cave_rock_hit"); // 5020
	level._effect["fx_dirt_tunnel_collapse_blast"]		= loadfx("maps/creek/fx_dirt_tunnel_collapse_blast"); // 5021

	level._effect["fx_lantern_smoke_corona"]					= loadfx("props/fx_lantern_smoke_corona");
	
	level._effect["fx_light_incandescent"]					= loadfx("env/light/fx_light_incandescent");
	level._effect["fx_light_dust_motes_md"]					  = loadfx("env/light/fx_light_dust_motes_md");
	
	level._effect["fx_godray_crk_overcast_sm_thin"]		= loadfx("maps/creek/fx_light_godray_crk_overcast_sm_thin");
	level._effect["fx_godray_crk_overcast_lg"]				= loadfx("maps/creek/fx_light_godray_crk_overcast_lg");

	level._effect["fx_smk_plume_hut_sm_white"]				= loadfx("env/smoke/fx_smk_plume_hut_sm_white");
	level._effect["fx_smk_plume_hut_md_white"]				= loadfx("env/smoke/fx_smk_plume_hut_md_white");	
	level._effect["fx_smk_plume_hut_lg_white"]				= loadfx("env/smoke/fx_smk_plume_hut_lg_white");

	level._effect["fx_fire_ember_column_lg"]					= loadfx("env/fire/fx_fire_ember_column_lg");
	level._effect["fx_ash_embers_light"]							= loadfx("env/fire/fx_ash_embers_light");

	level._effect["fx_fire_hut_wall_xsm"]							= loadfx("env/fire/fx_fire_hut_wall_xsm");
	level._effect["fx_fire_detail_nodlight"]					= loadfx("env/fire/fx_fire_detail_nodlight");
	level._effect["fx_fire_detail_sm_nodlight"]				= loadfx("env/fire/fx_fire_detail_sm_nodlight");	
	
	level._effect["fx_fire_column_creep_xsm"]					= loadfx("env/fire/fx_fire_column_creep_xsm");
	level._effect["fx_fire_column_xsm_thin"]					= loadfx("env/fire/fx_fire_column_xsm_thin");
	level._effect["fx_fire_column_sm_thin"]						= loadfx("env/fire/fx_fire_column_sm_thin");	
	level._effect["fx_fire_line_xsm_thin"]						= loadfx("env/fire/fx_fire_line_xsm_thin");
	level._effect["fx_fire_line_sm_thin"]							= loadfx("env/fire/fx_fire_line_sm_thin");
	level._effect["fx_fire_wall_back_sm"]							= loadfx("env/fire/fx_fire_wall_back_sm");	

	// MG Event
	level._effect["fx_large_woodhit"]									= loadfx("impacts/fx_large_woodhit");	
	level._effect["fx_exp_mg_nest"]										= loadfx("maps/creek/fx_exp_mg_nest");		
	
	level._effect["fx_explosion_satchel_hut"]					= loadfx("maps/creek/fx_exp_satchel_hut");
	level._effect["fx_explosion_satchel_hut_core"]		= loadfx("maps/creek/fx_exp_satchel_hut_core");
	level._effect["fx_explosion_tunnel_hatch_core"]		= loadfx("explosions/fx_exp_tunnel_mouth");
	level._effect["fx_explosion_hut_water"]						= loadfx("maps/creek/fx_exp_hut_water");
	
	// Helicopter Intro
	level._effect["fx_water_heli_spill_sm"]						= loadfx("maps/creek/fx_water_heli_spill_sm");	
	level._effect["fx_water_heli_spill_sm_froth"]			= loadfx("maps/creek/fx_water_heli_spill_sm_froth");	
	level._effect["fx_bullet_hole_gray_heli"]					= loadfx("maps/creek/fx_bullet_hole_gray_heli");		
	level._effect["fx_water_heli_pcloud"]							= loadfx("maps/creek/fx_water_heli_pcloud");
	level._effect["fx_light_huey_dome"]								= loadfx("maps/creek/fx_light_huey_dome");
	level._effect["fx_sparks_heli_mid_pnl_fxr"]				= loadfx("maps/creek/fx_sparks_heli_mid_pnl_fxr");
	level._effect["fx_sparks_heli_mid_pnl"]						= loadfx("maps/creek/fx_sparks_heli_mid_pnl");	
	level._effect["fx_sparks_heli_mid_pnl_smk"]				= loadfx("maps/creek/fx_sparks_heli_mid_pnl_smk");
	level._effect["fx_sparks_heli_upper_pnl_fxr"]			= loadfx("maps/creek/fx_sparks_heli_upper_pnl_fxr");	
	level._effect["fx_sparks_heli_upper_pnl"]					= loadfx("maps/creek/fx_sparks_heli_upper_pnl");
	level._effect["fx_cigarette_floating"]						= loadfx("props/fx_cigarette_floating");	
	level._effect["fx_cigarette_pack_floating"]			= loadfx("props/fx_cigarette_pack_floating");	
	level._effect["fx_heli_insulation_floating_sm"]		= loadfx("props/fx_heli_insulation_floating_sm");	
	level._effect["fx_heli_cloth_floating_sm"]				= loadfx("props/fx_heli_cloth_floating_sm");	
	level._effect["fx_player_water_knee_ripple"]			= loadfx("bio/player/fx_player_water_knee_ripple");		
	level._effect["fx_water_heli_gun_grab"]						= loadfx("maps/creek/fx_water_heli_gun_grab");	
	level._effect["fx_small_waterhit"]								= loadfx("impacts/fx_small_waterhit");		
	level._effect["fx_glass_heli_break"]							= loadfx("maps/creek/fx_glass_heli_break");		
	level._effect["fx_player_underwater_bubbles_drowning"]= loadfx("bio/player/fx_player_underwater_bubbles_drowning");

}

wind_initial_setting()
{
SetSavedDvar( "wind_global_vector", "-170 -100 0" );    // change "0 0 0" to your wind vector
SetSavedDvar( "wind_global_low_altitude", -100);    // change 0 to your wind's lower bound
SetSavedDvar( "wind_global_hi_altitude", 1775);    // change 10000 to your wind's upper bound
SetSavedDvar( "wind_global_low_strength_percent", 0.4);    // change 0.5 to your desired wind strength percentage
}

main()
{
	maps\createart\creek_1_art::main();
	
	initModelAnims();	
	precache_util_fx();
	precache_createfx_fx();
	
	footsteps();
		
	precache_scripted_fx();
	
	// calls the createfx server script (i.e., the list of ambient effects and their attributes)
	maps\createfx\creek_1_fx::main();
	
	wind_initial_setting();
	
	level thread roach_fx_setup();
	
	// set wind value
	level thread set_wind_value();
}

set_wind_value()
{
	wait( 2 );
	SetSavedDvar( "wind_global_vector", "-234 -100 0" );
}

play_guy_falling_water_death_fx()
{

	self PlaySound( "evt_creek_ai_fallingwater_splash" );
	playfx( level._effect["falling_water_splash"], self.origin );

	// play this at a bunch of places
	playfxontag( level._effect["falling_water_bubbles"], self, "J_Wrist_LE" );
	playfxontag( level._effect["falling_water_bubbles"], self, "J_Wrist_RI" );
	playfxontag( level._effect["falling_water_bubbles"], self, "J_Elbow_LE" );
	playfxontag( level._effect["falling_water_bubbles"], self, "J_Elbow_RI" );
	playfxontag( level._effect["falling_water_bubbles"], self, "J_Ankle_LE" );
	playfxontag( level._effect["falling_water_bubbles"], self, "J_Ankle_RI" );
	playfxontag( level._effect["falling_water_bubbles"], self, "J_Knee_LE" );
	playfxontag( level._effect["falling_water_bubbles"], self, "J_Knee_RI" );
	playfxontag( level._effect["falling_water_bubbles"], self, "J_Hip_LE" );
	playfxontag( level._effect["falling_water_bubbles"], self, "J_Hip_RI" );
	playfxontag( level._effect["falling_water_bubbles"], self, "J_Head" );

	// more blood
	if( is_mature() )
	{
		playfxontag( level._effect["falling_water_blood"], self, "J_Head" );
	}
}

boat_drag_wake( pbr )
{
	// wait till pbr is on water surface level
	while( 1 )
	{
		water_height = GetWaterHeight( pbr GetTagOrigin( "tag_origin_animate" ) );
		boat_wake_origin = pbr GetTagOrigin( "tag_wake" );
		boat_height = boat_wake_origin[2];
		boat_height -= 110;


		if( water_height < -1000 || water_height > 1000 ) // error checking
		{
			water_height = -51.875;
		}

		if( boat_height <= water_height )
		{
			break;
		}

		wait( 0.05 );
	}

	// spawn a script model at the tag_wake
	pbr.water_wake_tag = spawn( "script_model", pbr GetTagOrigin( "tag_wake" ) );
	pbr.water_wake_tag.angles = pbr GetTagAngles( "tag_wake" );
	pbr.water_wake_tag.angles = pbr.water_wake_tag.angles + ( 0, 180, 0 );
	pbr.water_wake_tag setmodel( "tag_origin" );

	level thread play_big_splash_fx( pbr, "stop_big_splash" );

	// now start playing idle splash on tag_wake
	level thread play_idle_wake_fx( pbr, "boat_starts_moving" );

	// wait till the boat begins to be dragged
	//level thread timer_wait();
	wait( 1 );
	level notify( "stop_big_splash" );

	level waittill( "drag_starts" );
	wait( 8 );
	level notify( "boat_starts_moving" );

	// start looping moving wake fx on an origin
	level thread play_drag_wake_fx( pbr, "drag_ends" );

	wait( 3 );
	level thread play_periodic_splash_fx( pbr, "drag_ends" );
	
	level waittill( "drag_ends" );

	// final splash
	playfxOnTag( level._effect["pbr_final_splash"], pbr.water_wake_tag, "tag_origin" );
}

// loop idle wake fx on tag_wake until the end_msg is called
play_idle_wake_fx( pbr, end_msg )
{
	level endon( end_msg );

	while( 1 )
	{
		water_height = GetWaterHeight( pbr GetTagOrigin( "tag_origin_animate" ) );
		water_height -= 30;
		//iprintlnbold( water_height );
		if( water_height < -1000 || water_height > 1000 ) // error checking
		{
			water_height = -32;
		}
		tag_wake_origin = pbr GetTagOrigin( "tag_wake" );
		pbr.water_wake_tag.origin = ( tag_wake_origin[0], tag_wake_origin[1], water_height );
		pbr.water_wake_tag.origin += ( 0, 0, 5.5 );
		wake_angles = pbr GetTagAngles( "tag_wake" );
		wake_angles = wake_angles + ( 0, 180, 0 );
		pbr.water_wake_tag.angles = ( 0, wake_angles[1], 0 );
		//iprintlnbold( pbr.water_wake_tag.angles );

		playfxOnTag( level._effect["wake_idle"], pbr.water_wake_tag, "tag_origin" );
		wait( 0.5 );
	}
}

play_drag_wake_fx( pbr, end_msg )
{
	level endon( end_msg );

	while( 1 )
	{
		// update the origin's position
		water_height = GetWaterHeight( pbr GetTagOrigin( "tag_origin_animate" ) );
		water_height -= 30;
		if( water_height < -1000 || water_height > 1000 ) // error checking
		{
			water_height = -32;
		}
		tag_wake_origin = pbr GetTagOrigin( "tag_wake" );
		pbr.water_wake_tag.origin = ( tag_wake_origin[0], tag_wake_origin[1], water_height );
		pbr.water_wake_tag.origin += ( 0, 0, 5.5 );
		wake_angles = pbr GetTagAngles( "tag_wake" );
		pbr.water_wake_tag.angles = ( 0, wake_angles[1], 0 );
		pbr.water_wake_tag.angles = pbr.water_wake_tag.angles;

		// fix
		//pbr.water_wake_tag.angles = pbr.water_wake_tag.angles + ( 0, -180, 0 );

		//iprintlnbold( pbr.water_wake_tag.angles );

		playfxOnTag( level._effect["wake_move"], pbr.water_wake_tag, "tag_origin" );
		wait( 0.1 );
	}
}

play_big_splash_fx( pbr, end_msg )
{
	level endon( end_msg );

	// update the origin's position
	water_height = GetWaterHeight( pbr GetTagOrigin( "tag_origin_animate" ) );
	water_height -= 30;
	if( water_height < -1000 || water_height > 1000 ) // error checking
	{
		water_height = -32;
	}
	tag_wake_origin = pbr GetTagOrigin( "tag_wake" );
	pbr.water_wake_tag.origin = ( tag_wake_origin[0], tag_wake_origin[1], water_height );
	pbr.water_wake_tag.origin += ( 0, 0, 3 );
	pbr.water_wake_tag.angles = pbr GetTagAngles( "tag_wake" );
	pbr.water_wake_tag.angles = pbr.water_wake_tag.angles + ( 0, 180, 0 );

	playfxOnTag( level._effect["boat_drop"], pbr.water_wake_tag, "tag_origin" );
}


play_face_water_drops( timer )
{
	linker = spawn( "script_model", self GetTagOrigin( "J_Neck" ) );
	linker.angles = self GetTagAngles( "J_Neck" );
	linker setmodel( "tag_origin" );
	linker linkto( self, "J_Neck" );
	
	//playfxOnTag( level._effect["face_water_drops"], linker, "tag_origin" );
	wait( timer );

	linker delete();
}

play_initial_water_ripples( delay_timer )
{
	wait( delay_timer );
	for( i = 0; i < 5; i++ )
	{
		barnes_pos = level.barnes get_pos_on_water_level();
		playfx( level._effect["water_entry"], barnes_pos );
		
		wait( 2.5 );
	}
}

play_swimming_wake_fx()
{
	level endon( "no_more_barnes_fx" );

	//self thread play_coming_out_of_water_wake_fx();

	self.keep_playing_wake_fx = true;

	while( 1 )
	{
		self_origin = self GetTagOrigin( "J_Neck" );
		water_height = GetWaterHeight( self_origin );
		wake_pos_on_water = ( self_origin[0], self_origin[1], water_height );

		self_angles = self GetTagAngles( "J_Neck" );
		wake_angles_on_water = self_angles + ( 0, 180, 0 );

		self.linker = spawn( "script_model", wake_pos_on_water );
		self.linker.angles = wake_angles_on_water;
		self.linker setmodel( "tag_origin" );
		
		//playfxOnTag( level._effect["swimming_up_wake"], linker, "tag_origin" );
		playfxOnTag( level._effect["swimming_wake"], self.linker, "tag_origin" );

		while( self.keep_playing_wake_fx )
		{
			self_origin = self GetTagOrigin( "J_Neck" );
			water_height = GetWaterHeight( self_origin );
			wake_pos_on_water = ( self_origin[0], self_origin[1], water_height );

			self_angles = self GetTagAngles( "J_Neck" );
			wake_angles_on_water = self_angles + ( 0, 180, 0 );

			self.linker MoveTo( wake_pos_on_water, 0.05, 0.01, 0.01 );
			self.linker RotateTo( wake_angles_on_water, 0.05, 0.01, 0.01 );

			wait( 0.05 );
		}
	
		self.linker delete();

		while( self.keep_playing_wake_fx == false )
		{
			wait( 0.1 );
		}
	}
}

play_coming_out_of_water_wake_fx()
{
	self_origin = self GetTagOrigin( "tag_origin" );
	water_height = GetWaterHeight( self_origin );
	wake_pos_on_water = ( self_origin[0], self_origin[1], water_height );
	wake_pos_on_water += ( 0, 0, 3 );

	self_angles = self GetTagAngles( "tag_origin" );
	wake_angles_on_water = self_angles + ( 0, 180, 0 );

	linker = spawn( "script_model", wake_pos_on_water );
	linker.angles = wake_angles_on_water;
	linker setmodel( "tag_origin" );

	playfxOnTag( level._effect["water_entry"], linker, "tag_origin" );

	timer = 0;
	while( timer < 2 )
	{
		self_origin = self GetTagOrigin( "tag_origin" );
		water_height = GetWaterHeight( self_origin );
		wake_pos_on_water = ( self_origin[0], self_origin[1], water_height );
		wake_pos_on_water += ( 0, 0, 3 );
	
		self_angles = self GetTagAngles( "tag_origin" );
		wake_angles_on_water = self_angles + ( 0, 180, 0 );

		linker.origin = wake_pos_on_water;
		linker.angles = wake_angles_on_water;

		timer += 0.1;
		wait( 0.1 );
	}

	linker2 = spawn( "script_model", linker.origin );
	//linker2.angles = linker.angles;
	//linker2.angles += ( 90, 0, 0 );
	linker2.angles = ( -90, 0, 0 );
	linker2 setmodel( "tag_origin" );

	linker delete();

	playfxOnTag( level._effect["water_splash"], linker2, "tag_origin" );

	wait( 4 );

	linker2 delete();
}

play_periodic_splash_fx( pbr,  end_msg )
{	
	level endon( end_msg );

	while( 1 )
	{
		//iprintlnbold( "big splash" );
		playfxOnTag( level._effect["wake_splash"], pbr.water_wake_tag, "tag_origin" );
		wait( 3 );
	}
}

barnes_get_in_out_water( delay_time )
{
	for( i = 1; i <= delay_time; i++ )
	{
		wait( 1 );
		//iprintlnbold( i );
	}
	//wait( delay_time );
	pos = level.barnes get_pos_on_water_level();
	playfx( level._effect["water_splash"], pos );
}

barnes_water_idle( timer, end_msg )
{
	level endon( end_msg );
	
	wait( timer );
	while( 1 )
	{
		pos = level.barnes get_pos_on_water_level();
		playfx( level._effect["water_entry"], pos );
		wait( 2.5 );
	}
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

// CUSTOM WATER SPLASH
//////////////////////////////////////////////////////////////////////////////

water_splash_fx_handler()
{
	self endon( "stop_water_fx" );
	self.playing_wake_fx = false;
	
	self thread water_splash_fx_anim_single();
	self thread water_splash_fx_anim_loop();
}

water_splash_fx_anim_single()
{
	self endon( "stop_water_fx" );
	while( 1 )
	{
		self waittill( "single anim", notetrack );
		self thread water_splash_fx_handle_notetrack( notetrack );
	}
}

water_splash_fx_anim_loop()
{
	self endon( "stop_water_fx" );
	while( 1 )
	{
		self waittill( "looping anim", notetrack );
		self thread water_splash_fx_handle_notetrack( notetrack );
	}
}

water_splash_fx_handle_notetrack( notetrack )
{
	//iprintlnbold( notetrack );
	notetrack	= ToLower( notetrack );
	tokens = StrTok( notetrack, "#" );
	
	if( tokens[0] == "wake_start" )
	{
		self thread play_fx_wake_start( tokens );
	}
	else if( tokens[0] == "wake_end" )
	{
		self thread play_fx_wake_end( tokens );
	}
	else if( tokens[0] == "idle_start" )
	{
		self thread play_fx_idle_start( tokens );
	}
	else if( tokens[0] == "idle_end" )
	{
		self thread play_fx_idle_end( tokens );
	}
	else if( tokens[0] == "dive_under" )
	{
		self thread play_fx_dive_under( tokens );
	}
	else if( tokens[0] == "rise_up" )
	{
		self thread play_fx_rise_up( tokens );
	}
	else if( tokens[0] == "splash_left" )
	{
		self thread play_fx_splash_left( tokens );
	}
	else if( tokens[0] == "splash_right" )
	{
		self thread play_fx_splash_right( tokens );
	}
}

get_pos_on_water( tag, tokens )
{
	pos = self GetTagOrigin( tag );
	water_height = GetWaterHeight( pos );
	pos = ( pos[0], pos[1], water_height );
	pos += get_pos_adjustments( tokens );
	return( pos );
}

get_pos_adjustments( tokens )
{
	adjustments = ( 0, 0, 0 );
	if( tokens.size < 3 )
	{
		return( adjustments );
	}
	
	adjust_x = Int( tokens[1] );
	adjust_y = Int( tokens[2] );
	
	if( !isdefined( adjust_x ) || !isdefined( adjust_y ) )
	{
		return( adjustments );
	}
	
	adjustments = ( adjust_x, adjust_y, 0 );
	return( adjustments );
}

//////////////////////////////////////////////////////////////////////////////

play_fx_wake_start( tokens )
{
	tag_used = "J_NECK";
	linker_pos = self get_pos_on_water( tag_used, tokens );
	self.playing_wake_fx = true;
	playfx( level._effect["swimming_wake"], linker_pos );
	wait( 0.1 );
	
	while( self.playing_wake_fx == true )
	{
		linker_pos = self get_pos_on_water( tag_used, tokens );
		playfx( level._effect["swimming_wake"], linker_pos );
		wait( 0.1 );
	}
}

play_fx_wake_end( tokens )
{
	self.playing_wake_fx = false;
	//iprintlnbold( "wake_end" );
}

//////////////////////////////////////////////////////////////////////////////

play_fx_idle_start( tokens )
{
	self notify( "stop_wake_idle" );
	self thread play_fx_idle( tokens );
	//iprintlnbold( "idle_start" );
}

play_fx_idle( tokens )
{
	self endon( "stop_wake_idle" );
	self endon( "stop_water_fx" );
	
	//iprintlnbold( "idle_start" );
	tag_used = "J_NECK";
	while( 1 )
	{
		fxpos = self get_pos_on_water( tag_used, tokens );
		playfx( level._effect["wake_idle"], fxpos );
		wait( .7 );
	}
}

play_fx_idle_end( tokens )
{
	//iprintlnbold( "idle_end" );
	self notify( "stop_wake_idle" );
}

//////////////////////////////////////////////////////////////////////////////

play_fx_dive_under( tokens )
{
	tag_used = "J_NECK";
	fxpos = self get_pos_on_water( tag_used, tokens );
	playfx( level._effect["water_splash_under"], fxpos );
}

play_fx_rise_up( tokens )
{
	tag_used = "J_NECK";
	fxpos = self get_pos_on_water( tag_used, tokens );
	playfx( level._effect["water_splash_rise"], fxpos );
}

//////////////////////////////////////////////////////////////////////////////

play_fx_splash_left( tokens )
{
	tag_used = "J_ANKLE_LE";
	fxpos = self get_pos_on_water( tag_used, tokens );
	playfx( level._effect["water_ankle_splash"], fxpos );
	//iprintlnbold( "splash_left" );
}

play_fx_splash_right( tokens )
{
	tag_used = "J_ANKLE_RI";
	fxpos = self get_pos_on_water( tag_used, tokens );
	playfx( level._effect["water_ankle_splash"], fxpos );
	//iprintlnbold( "splash_right" );
}




roach_fx_setup()
{
	level waittill( "player_entered_tunnel" );
		
	triggers = getentarray( "b4_roach_trigger", "targetname" );
	for( i = 0; i < triggers.size; i++ )
	{
		level thread roach_fx_single( triggers[i] );
	}
}

roach_fx_single( trigger )
{
	exploder_id = Int( trigger.script_noteworthy );
	origin = trigger.script_vector;
	distance_check_sqr = 470 * 470;
	player = get_players()[0];
	end_msg = "roach_trigger_off_" + trigger.script_noteworthy;
	
	//level thread debug_positions( trigger, end_msg );
	
	while( 1 )
	{
		trigger waittill( "trigger" );
		distance_2_player_sqr = distancesquared( player.origin, origin );
		
		if( distance_2_player_sqr < distance_check_sqr )
		{
			level notify( end_msg );
			exploder( exploder_id );
			return;
		}
		
		wait( 0.05 );
	}
}

debug_positions( trigger, msg )
{
	self endon( msg );
	player = get_players()[0];
	while( 1 )
	{
		distance_2_player = distance( player.origin, trigger.script_vector );
		text = trigger.script_noteworthy + " " + distance_2_player;
		print3d( trigger.script_vector, text );
		wait( 0.05 );
	}
}

//------------------------------------------------------------------

player_show_hide_rain_fx()
{
	level.play_rain_fx = false;
	
	level thread play_rain_fx();
	wait( 2 );
	player = get_players()[0];
	player thread hide_rain_fx_when_underwater();
	player thread show_rain_fx_when_abovewater();
}

hide_rain_fx_when_underwater()
{
	while( 1 )
	{
		self waittill("underwater");
		
		if( level.play_rain_fx == true )
		{
			stop_exploder( 2001 );
		}
	}
}

show_rain_fx_when_abovewater()
{
	while( 1 )
	{
		self waittill("surface");
		
		if( level.play_rain_fx == true )
		{
			exploder( 2001 );
		}
	}
}

play_rain_fx()
{
	// start light rain first
	trigger_wait( "b2_start_light_rain" );
	exploder( 2000 );
	
	// level thread maps\creek_1_stealth::beat2_riverwalk_rain_dialogue();

	player = get_players()[0];
	
	level thread maps\createart\creek_1_art::art_settings_for_light_rain();
	level thread lerp_sky_transition( 0, 1, 5 );
	
	// end light rain. Make it heavy
	trigger_wait( "b2_start_heavy_rain" );
	
	level thread maps\createart\creek_1_art::art_settings_for_heavy_rain();
	SetSavedDvar( "r_outdoorfeather", "80" );
	
	stop_exploder( 2000 ); 	// stop light rain
	exploder( 2001 );				// start heavy rain
	level thread notify_delay( "cranes_start", 1 ); // start crane anim
	level.play_rain_fx = true;	// this is used to restore rain for swimming
	
	// start playing with fog values
	//level thread maps\createart\creek_1_art::alternating_fog_values( "village_hut_start" );
	
	// once player is on the ladder, play a looping rain fx at the exit
	trigger_wait( "b2_stealth_trigger_8_ladder" );
	level notify( "village_hut_start" );
	level thread maps\createart\creek_1_art::art_settings_for_village_intro();
	level.keep_rain_fx_playing = true;
	level thread play_temp_rain_fx_in_village();
	
	trigger_wait( "b2_stealth_trigger_10" );
	level notify( "end_rain" );
	
	level thread reset_village_vision_later();
	
	level thread lerp_sky_transition( 1, 0, 5 );
	
	// once player exits the hut turn all rain off (rain drops off in about 2 seconds)
	trigger_wait( "end_rain" );
	stop_exploder( 2001 );
	level.play_rain_fx = false;
	level.keep_rain_fx_playing = false;
	wait( 1.5 );
	SetSavedDvar( "r_outdoorfeather", "8" );
}

reset_village_vision_later()
{
	//trigger_wait( "trigger_reset_village_art" );
	flag_wait( "grenade_explode" );
	level thread maps\createart\creek_1_art::set_village_art_values();
}

lerp_sky_transition( start_value, end_value, time )
{
	frames = time * 20;
	increment = ( end_value - start_value ) / frames;
	
	for( i = 0; i < frames; i++ )
	{
		start_value += increment;
		SetSavedDvar( "r_skyTransition", start_value );
		wait( 0.05 );
	}
	SetSavedDvar( "r_skyTransition", end_value );
}

play_temp_rain_fx_in_village()
{
	while( level.keep_rain_fx_playing )
	{
		exploder( 2002 );
		wait( 1 );
	}
	
	wait( 0.5 );
	exploder( 2002 );
}

