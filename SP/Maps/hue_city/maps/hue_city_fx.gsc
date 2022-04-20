#include maps\_utility;
#include maps\_anim;
#include maps\flamer_util;
#include common_scripts\utility;

#using_animtree("fxanim_props");

// fx used by util scripts
precache_util_fx()
{
}

// Scripted effects
precache_scripted_fx()
{
		//event1
	//level._effect["napalm1"] = loadfx("weapon/napalm/fx_napalmexp_xlg_blk_smk_01"); // incorrect/unnecessary effect
	level._effect["napalm2"] = loadfx("weapon/napalm/fx_napalm_drop_bombs_only");
	//level._effect["chopper_explode"] = loadfx("vehicle/vexplosion/fx_vexplode_huey_exp"); // incorrect/unnecessary effect
	level._effect["huey_main_blade"] = loadfx("vehicle/props/fx_huey_main_blade_full");
	level._effect["shotgun_impact"] = loadfx("impacts/fx_flesh_hit_body_fatal_exit");
	level._effect["jet_exhaust"]	= LoadFX( "vehicle/exhaust/fx_exhaust_jet_afterburner" );

		// reznov building read
	//level._effect["smoke_xlg"] = LoadFX("env/smoke/fx_smk_plume_xlg_tall_blk");
	level._effect["jet_contrail"] = loadfx("trail/fx_geotrail_jet_contrail"); // dale should track

		// sparks for hanging electrical wires
	level._effect["wire_spark"] = loadfx("env/electrical/fx_elec_burst_heavy_sm_os_int");


		// tree fx

	// event 2 streets
	level._effect["spotlightd"] = loadfx("vehicle/light/fx_huey_spotlight");	
	level._effect["spotlightd_target"] = loadfx("vehicle/light/fx_huey_spotlight_target");
	
	// SUMEET - Added this macv specific spotlight effect, this has a primary light
	level._effect["macv_spotlight"] = loadfx("maps/hue_city/fx_huey_spotlight_macv");
	
	//level._effect["spotlightd"] = loadfx("env/light/fx_ray_spotlight_md_dlight");
	
		//event3

	level._effect["tank_hit"] = loadfx("maps/hue_city/fx_exp_hue_tank1");	// This is a duplicate to an exploder
	level._effect["strafe_hit"] = loadfx("maps/hue_city/fx_huey_minigun_strafe_single");
	level._effect["airstrike_hit"] = loadfx("explosions/fx_mortarexp_dirt");
	level._effect["door_dust"] = LoadFX("destructibles/fx_dest_door");
	level._effect["tank_top_trail"] = LoadFX("maps/hue_city/fx_tank1_top_trail");

	level._effect["smoke_grenades"] = LoadFX("maps/hue_city/fx_defend_smoke_grenades");	// remove this when using smoke exploders
	level._effect["body_splash"] 		= LoadFX("impacts/fx_water_hit_lg");


	level._effect["airstrike_valid_target"] = LoadFX("misc/fx_heli_ui_airstrike_grn");
	level._effect["airstrike_invalid_target"] = LoadFX("misc/fx_heli_ui_airstrike_red");
	level._effect["airstrike_confirmed_target"] = LoadFX("misc/fx_heli_ui_airstrike_yellow");


	//MACV
	level._effect["chopper_hit"] = loadfx("maps/hue_city/fx_exp_hue_huey");
	level._effect["chopper_bullet_impact"] = loadfx("maps/hue_city/fx_impact_hue_huey");
	level._effect["chopper_burning"] = loadfx("vehicle/vfire/fx_vsmoke_huey_trail");
	level._effect["def_explosion"] = loadfx("explosions/fx_default_explosion"); // remove this when gates exploder is in
	level._effect["macv_intro_glass"] = loadfx("maps/quagmire/fx_quag_glass_rappel");
	level._effect["chopper_rotor"] = loadfx("vehicle/props/fx_huey_main_blade_full");
	level._effect["chopper_tail_rotor"] = loadfx("vehicle/props/fx_huey_small_blade_full");


	//level._effect["fire_medium"] = loadfx("env/fire/fx_fire_md");
	//level._effect["fire_large"] = loadfx("env/fire/fx_fire_lg");



	// BEAT 3 - DEFEND

	level._effect["radio_light"] =  loadfx("maps/sandbox_modules/module_2/fx_mod2_hand_radio_light");

	// SUMEET - effects for MACV

	level._effect["war_room_explosion"]         = LoadFX( "explosions/fx_grenadeexp_concrete" );

	// interior light fx for repel heli
	level._effect["heli_interior_light"] 		= LoadFX( "vehicle/light/fx_huey_interior_emergency_light" );

	// mowdown death effects
	level._effect["heli_mowdown_blood_geyser"]  = LoadFX("maps/hue_city/fx_mowdown_blood_geyser");
	level._effect["heli_mowdown_multihit"]      = LoadFX("maps/hue_city/fx_mowdown_blood_multihit");
	level._effect["squirting_blood"]      			= LoadFX("trail/fx_trail_blood_streak");

	//neck stab
	level._effect["neck_stab"]	= LoadFX("maps/hue_city/fx_vc_neck_stab");

	// death effect for spas
	level._effect["spas_death"]                 = LoadFX("env/fire/fx_fire_player_torso_dragons");
	level._effect["defend_bombing_run"]         = LoadFX("explosions/fx_exp_bomb_huge");
	level._effect["defend_bomb_smoke"]         = LoadFX("env/smoke/fx_smk_column_xlg_blk");
		
	level._effect["rocket_trail"] = loadfx("weapon/napalm/fx_napalm_streak_geotrail_lod1");
	

}


anim_notetrack_functions()
{
	// SUMEET - Added custom notetrack functions for the exploders
	addNotetrack_customFunction( "fxanim_props", "window_01_break", ::wallshoot_exploders, "a_wallshoot" );	
	addNotetrack_customFunction( "fxanim_props", "window_02_break", ::wallshoot_exploders, "a_wallshoot" );	
	addNotetrack_customFunction( "fxanim_props", "window_03_break", ::wallshoot_exploders, "a_wallshoot" );	
	addNotetrack_customFunction( "fxanim_props", "window_04_break", ::wallshoot_exploders, "a_wallshoot" );	
	addNotetrack_customFunction( "fxanim_props", "window_05_break", ::wallshoot_exploders, "a_wallshoot" );	
	addNotetrack_customFunction( "fxanim_props", "window_06_break", ::wallshoot_exploders, "a_wallshoot" );	
	addNotetrack_customFunction( "fxanim_props", "window_07_break", ::wallshoot_exploders, "a_wallshoot" );	
	addNotetrack_customFunction( "fxanim_props", "window_08_break", ::wallshoot_exploders, "a_wallshoot" );	
	addNotetrack_customFunction( "fxanim_props", "window_09_break", ::wallshoot_exploders, "a_wallshoot" );	
	addNotetrack_customFunction( "fxanim_props", "window_10_break", ::wallshoot_exploders, "a_wallshoot" );	
	addNotetrack_customFunction( "fxanim_props", "window_11_break", ::wallshoot_exploders, "a_wallshoot" );	
	addNotetrack_customFunction( "fxanim_props", "window_12_break", ::wallshoot_exploders, "a_wallshoot" );	

	addNotetrack_FXOnTag( "fxanim_props", "a_wirespark_long", "long_spark_wire", "wire_spark", "long_spark_06_jnt");
	addNotetrack_FXOnTag( "fxanim_props", "a_wirespark_med", "med_spark_wire", "wire_spark", "med_spark_06_jnt");

	addNotetrack_exploder( "fxanim_props", "tree_impact", 		2011,		  "a_tank01_entrance" );	
	addNotetrack_exploder( "fxanim_props", "pole_01_start",	  2012, 		"a_tank01_entrance" );	
	addNotetrack_exploder( "fxanim_props", "pole_01_impact", 	2013, 		"a_tank01_entrance" );	
	addNotetrack_exploder( "fxanim_props", "pole_02_start", 	2014, 		"a_tank01_entrance" );	
	addNotetrack_exploder( "fxanim_props", "pole_02_impact", 	2015,  		"a_tank01_entrance" );	
	
	addNotetrack_customFunction( "fxanim_props", "pole_01_impact", ::pole_falls, "a_tank01_entrance" );	
	addNotetrack_customFunction( "fxanim_props", "pole_02_impact", ::pole_falls, "a_tank01_entrance" );	
	
	addNotetrack_customFunction( "fxanim_props", "tank01death_tank_explode", 		::blow_tank, 	"a_tank01_death" );	
	addNotetrack_customFunction( "fxanim_props", "tank01death_movie_hit", 			::movie_sign_fall,  "a_tank01_death");
	addNotetrack_customFunction( "fxanim_props", "tank01death_tank_hit", 				::fire_hydrant_timing,  "a_tank01_death");
	addNotetrack_customFunction( "fxanim_props", 	"tank01death_turret_impact", 	::tank_hit_ground,  "a_tank01_death");
	addNotetrack_customFunction( "fxanim_props", 	"tank01death_movie_ground", 	::moviesign_hit_ground,  "a_tank01_death");

	addNotetrack_exploder( "fxanim_props", "tank01death_sign_01", 			2022,  "a_tank01_death");
	addNotetrack_exploder( "fxanim_props", "tank01death_pole_start", 		2023,	 "a_tank01_death");
	addNotetrack_exploder( "fxanim_props", "tank01death_tank_hit",		  2024,  "a_tank01_death");
	addNotetrack_exploder( "fxanim_props", "tank01death_sign_02", 			2025,  "a_tank01_death");
	addNotetrack_exploder( "fxanim_props",  "tank01death_pole_impact",	2026,  "a_tank01_death");


	addNotetrack_exploder( "fxanim_props", "tank01death_corrugated_impact",	2028,	 "a_tank01_death");
	addNotetrack_exploder( "fxanim_props", "tank01death_pole_impact2 ", 		2030,  "a_tank01_death");
	addNotetrack_exploder( "fxanim_props", "tank01death_movie_snap", 				2032,	 "a_tank01_death");
	addNotetrack_exploder( "fxanim_props", "tank01death_movie_awning",		  2033,  "a_tank01_death");
	
	addNotetrack_exploder( "fxanim_props", "sign_start", 			2056,  "a_sign_leyna");
	addNotetrack_exploder( "fxanim_props", "n_start",					2057,	 "a_sign_leyna");
	addNotetrack_exploder( "fxanim_props", "n_impact", 			2058,  "a_sign_leyna");

	addNotetrack_exploder( "fxanim_props", "balcony_01_hit",	2051,  "a_balcony");
	addNotetrack_exploder( "fxanim_props", "balcony_02_hit",	2052,	 "a_balcony");
	addNotetrack_exploder( "fxanim_props", "balcony_03_hit", 	2053,  "a_balcony");
	addNotetrack_exploder( "fxanim_props", "balcony_land", 		2054,  "a_balcony");
	addNotetrack_exploder( "fxanim_props", "large_chunk_hit",	2055,	 "a_balcony");
}

// FXanim Props
initModelAnims()
{
	level.scr_anim["fxanim_props"]["a_distant_rappel"] = %fxanim_gp_distant_rappel_anim;
	level.scr_anim["fxanim_props"]["a_rappelfix"] = %fxanim_quag_rappelfix_anim;
	level.scr_anim["fxanim_props"]["a_benches"] = %fxanim_hue_benches01_anim;
	level.scr_anim["fxanim_props"]["a_blind01"] = %fxanim_gp_blind_pulse01_full_anim;
	level.scr_anim["fxanim_props"]["a_blind02"] = %fxanim_gp_blind_pulse01_torn_anim;
	level.scr_anim["fxanim_props"]["a_blind03"] = %fxanim_gp_blind_pulse01_full_anim;
	level.scr_anim["fxanim_props"]["a_blind04"] = %fxanim_gp_blind_pulse01_torn_anim;
	level.scr_anim["fxanim_props"]["a_blind05"] = %fxanim_gp_blind_pulse01_open_anim;
	level.scr_anim["fxanim_props"]["a_blind06"] = %fxanim_gp_blind_pulse01_short_anim;
	level.scr_anim["fxanim_props"]["a_blind07"] = %fxanim_gp_blind_pulse01_open_anim;
	level.scr_anim["fxanim_props"]["a_wallshoot"] = %fxanim_hue_wallshoot_anim;	
	level.scr_anim["fxanim_props"]["a_tile_broke_01"] = %fxanim_hue_tile_broke_01_anim;
	level.scr_anim["fxanim_props"]["a_tile_broke_03"] = %fxanim_hue_tile_broke_03_anim;
	level.scr_anim["fxanim_props"]["a_tile_broke_04"] = %fxanim_hue_tile_broke_04_anim;
	level.scr_anim["fxanim_props"]["a_tile_whole_01"] = %fxanim_hue_tile_whole_01_anim;
	level.scr_anim["fxanim_props"]["a_tile_whole_02"] = %fxanim_hue_tile_whole_02_anim;
	level.scr_anim["fxanim_props"]["a_ceiling_light_01"] = %fxanim_hue_ceiling_light_fall_anim;
	level.scr_anim["fxanim_props"]["a_ceiling_light_02"] = %fxanim_gp_ceiling_light_swing_anim;
	level.scr_anim["fxanim_props"]["a_tank01_entrance"] = %fxanim_hue_tank01_entrance_anim;
	level.scr_anim["fxanim_props"]["a_sign_leyna"] = %fxanim_hue_sign_leyna_anim;
	level.scr_anim["fxanim_props"]["a_tank01_shake"] = %fxanim_hue_tank01_shake_anim;
	level.scr_anim["fxanim_props"]["a_tank01_death"] = %fxanim_hue_tank01_death_anim;
	level.scr_anim["fxanim_props"]["a_tank01_explode"] = %fxanim_hue_tank01_explode_anim;
	level.scr_anim["fxanim_props"]["a_tank01_car_death"] = %fxanim_hue_hatchback_anim;
	level.scr_anim["fxanim_props"]["a_door_office_01"] = %fxanim_hue_door_office_anim;
	level.scr_anim["fxanim_props"]["a_balcony"] = %fxanim_hue_balcony_anim;
	level.scr_anim["fxanim_props"]["a_aagun_bldg"] = %fxanim_hue_aagun_bldg_anim;
	level.scr_anim["fxanim_props"]["a_gate_swing"] = %fxanim_hue_gate_swing_anim;
	level.scr_anim["fxanim_props"]["a_gate_kick"] = %fxanim_hue_gate_kick_anim;
	level.scr_anim["fxanim_props"]["a_tank01_turret"] = %fxanim_hue_tank01_turret_anim;



	ent1 = getent( "fxanim_quag_rappelcrash01_mod", "targetname" );
	ent2 = getent( "fxanim_quag_rappelcrash02_mod", "targetname" );
	ent3 = getent( "fxanim_gp_distant_rappel_mod_01", "targetname" );
	ent4 = getent( "fxanim_gp_distant_rappel_mod_02", "targetname" );
	ent5 = getent( "fxanim_quag_rappelfix_mod", "targetname" );
	ent6 = getent( "fxanim_hue_benches01_mod", "targetname" );
	ent7 = getent( "fxanim_gp_blind01", "targetname" );
	ent8 = getent( "fxanim_gp_blind02", "targetname" );
	ent9 = getent( "fxanim_gp_blind03", "targetname" );
	ent10 = getent( "fxanim_gp_blind04", "targetname" );
	ent11 = getent( "fxanim_gp_blind05", "targetname" );
	ent12 = getent( "fxanim_gp_blind06", "targetname" );
	ent13 = getent( "fxanim_gp_blind07", "targetname" );
	ent14 = getent( "fxanim_hue_wallshoot_mod", "targetname" );
	ent15 = getent( "tile_broke_01", "targetname" );
	ent16 = getent( "tile_whole_01", "targetname" );
	ent17 = getent( "tile_whole_02", "targetname" );
	ent18 = getent( "hue_ceiling_light_01", "targetname" );
	ent19 = getent( "hue_ceiling_light_02", "targetname" );
	ent20 = getent( "fxanim_hue_tank01_entrance_mod", "targetname" );
	ent21 = getent( "fxanim_hue_sign_leyna_mod", "targetname" );
	ent22 = getent( "fxanim_hue_tank01_death_mod", "targetname" );
	ent23 = getent( "fxanim_hue_door_office_01_mod", "targetname" );
	ent24 = getent( "fxanim_hue_balcony_mod", "targetname" );
	ent25 = getent( "tile_broke_03", "targetname" );
	ent26 = getent( "tile_broke_04", "targetname" );
	ent27 = getent( "fxanim_hue_aagun_bldg_mod", "targetname" );
	ent28 = getent( "fxanim_hue_gate_kick_l_mod", "targetname" );
	ent29 = getent( "fxanim_hue_gate_kick_r_mod", "targetname" );
	ent30 = getent( "fxanim_hue_tank01_turret_mod", "targetname" );

	if (IsDefined(ent1))
	{
		ent1 thread rappelcrash01();
		println("************* FX: rappelcrash01 *************");
	}
	
	if (IsDefined(ent2))
	{
		ent2 thread rappelcrash02();
		println("************* FX: rappelcrash02 *************");
	}
	
	if (IsDefined(ent3))
	{
		ent3 thread distant_rappel_01();
		println("************* FX: distant_rappel_01 *************");
	}
	
	if (IsDefined(ent4))
	{
		ent4 thread distant_rappel_02();
		println("************* FX: distant_rappel_02 *************");
	}
	
	if (IsDefined(ent5))
	{
		ent5 thread rappelfix();
		println("************* FX: rappelfix( *************");
	}
	
	if (IsDefined(ent6))
	{
		ent6 thread benches();
		println("************* FX: benches( *************");
	}
	
	if (IsDefined(ent7))
	{
		ent7 thread blind01();
		println("************* FX: blind01( *************");
	}
	
	if (IsDefined(ent8))
	{
		ent8 thread blind02();
		println("************* FX: blind02( *************");
	}
	
	if (IsDefined(ent9))
	{
		ent9 thread blind03();
		println("************* FX: blind03( *************");
	}
	
	if (IsDefined(ent10))
	{
		ent10 thread blind04();
		println("************* FX: blind04( *************");
	}
	
	if (IsDefined(ent11))
	{
		ent11 thread blind05();
		println("************* FX: blind05( *************");
	}
	
	if (IsDefined(ent12))
	{
		ent12 thread blind06();
		println("************* FX: blind06( *************");
	}
	
	if (IsDefined(ent13))
	{
		ent13 thread blind07();
		println("************* FX: blind07( *************");
	}
	
	if (IsDefined(ent14))
	{
		ent14 thread wallshoot();
		println("************* FX: wallshoot( *************");
	}
	
	if (IsDefined(ent15))
	{
		ent15 thread tile_broke_01();
		println("************* FX: tile_broke_01( *************");
	}
	
	if (IsDefined(ent16))
	{
		ent16 thread tile_whole_01();
		println("************* FX: tile_whole_01( *************");
	}
	
	if (IsDefined(ent17))
	{
		ent17 thread tile_whole_02();
		println("************* FX: tile_whole_02( *************");
	}
	
	if (IsDefined(ent18))
	{
		ent18 thread ceiling_light_01();
		println("************* FX: ceiling_light_01( *************");
	}
	
	if (IsDefined(ent19))
	{
		ent19 thread ceiling_light_02();
		println("************* FX: ceiling_light_02( *************");
	}
	
	if (IsDefined(ent20))
	{
		ent20 thread tank01_entrance();
		println("************* FX: tank01_entrance( *************");
	}
	
	if (IsDefined(ent21))
	{
		ent21 thread sign_leyna();
		println("************* FX: sign_leyna( *************");
	}
	
	if (IsDefined(ent22))
	{
		ent22 thread tank01_death();
		println("************* FX: tank01_death( *************");
	}
	
	if (IsDefined(ent23))
	{
		ent23 thread door_office_01();
		println("************* FX: door_office_01( *************");
	}
	
	if (IsDefined(ent24))
	{
		ent24 thread balcony();
		println("************* FX: balcony( *************");
	}
	
	if (IsDefined(ent25))
	{
		ent25 thread tile_broke_03();
		println("************* FX: tile_broke_03( *************");
	}
	
	if (IsDefined(ent26))
	{
		ent26 thread tile_broke_04();
		println("************* FX: tile_broke_04( *************");
	}
	
	if (IsDefined(ent27))
	{
		ent27 thread aagun_bldg();
		println("************* FX: aagun_bldg( *************");
	}
	
	if (IsDefined(ent28))
	{
		ent28 thread gate_swing();
		println("************* FX: gate_swing( *************");
	}
	
	if (IsDefined(ent29))
	{
		ent29 thread gate_kick();
		println("************* FX: gate_kick( *************");
	}
	
	if (IsDefined(ent30))
	{
		ent30 thread tank01_turret();
		println("************* FX: tank01_turret( *************");
	}	
}

rappelcrash01()
{

	self hide();
	level waittill("rappelcrash_start");
	self show();
	self UseAnimTree(#animtree);
	self animscripted("a_rappelcrash01", self.origin, self.angles, %fxanim_quag_rappelcrash01_anim);
}

rappelcrash02()
{
	self hide();
	level waittill("rappelcrash_start");
	self show();
	self UseAnimTree(#animtree);
	self animscripted("a_rappelcrash02", self.origin, self.angles, %fxanim_quag_rappelcrash02_anim);
}

rappelfix()
{
	level waittill("rappelfix_start");

	// SUMEET - Added hiding old rope for a brief moment
	level thread hide_rappelcrash02_for_brief();

	self UseAnimTree(#animtree);
	anim_single(self, "a_rappelfix", "fxanim_props");
}


hide_rappelcrash02_for_brief()
{
	wait(0.5);

	ent2 = getent( "fxanim_quag_rappelcrash02_mod", "targetname" );
	ent2 Hide();

	wait(3);

	ent2 Show();
}

distant_rappel_01()
{
	self UseAnimTree(#animtree);
	while (true)
	{
		level waittill("distant_rappel_01_start");
		anim_single(self, "a_distant_rappel", "fxanim_props");
	}
}

distant_rappel_02()
{
	self UseAnimTree(#animtree);
	while (true)
	{
		level waittill("distant_rappel_02_start");
		anim_single(self, "a_distant_rappel", "fxanim_props");
	}
}

benches()
{
	level waittill("benches_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_benches", "fxanim_props");
}

blind01()
{
	level waittill("benches_start");
	wait (.2);
	self UseAnimTree(#animtree);
	anim_single(self, "a_blind01", "fxanim_props");
}

blind02()
{
	level waittill("benches_start");
	wait (.2);
	self UseAnimTree(#animtree);
	anim_single(self, "a_blind02", "fxanim_props");
}

blind03()
{
	level waittill("benches_start");
	wait (.1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_blind01", "fxanim_props");
}

blind04()
{
	level waittill("benches_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_blind04", "fxanim_props");
}

blind05()
{
	level waittill("benches_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_blind05", "fxanim_props");
}

blind06()
{
	level waittill("benches_start");
	wait (.2);
	self UseAnimTree(#animtree);
	anim_single(self, "a_blind06", "fxanim_props");
}

blind07()
{
	level waittill("benches_start");
	wait (.5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_blind07", "fxanim_props");
}

wallshoot()
{
	level.current_mowdown_exploder_index = 30;

	level waittill("wallshoot_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_wallshoot", "fxanim_props");
}


// SUMEET - Added exploders for mowdown sequence
wallshoot_exploders( guy )
{
	exploder( level.current_mowdown_exploder_index );
	level.current_mowdown_exploder_index++;
}

tile_broke_01()
{
	level waittill("wallshoot_start");
	wait (8);
	self UseAnimTree(#animtree);
	anim_single(self, "a_tile_broke_01", "fxanim_props");
}

tile_whole_01()
{
	level waittill("wallshoot_start");
	wait (5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_tile_whole_01", "fxanim_props");
}

tile_whole_02()
{
	level waittill("wallshoot_start");
	wait (9);
	self UseAnimTree(#animtree);
	anim_single(self, "a_tile_whole_02", "fxanim_props");
}

ceiling_light_01()
{
	level waittill("wallshoot_start");
	wait (2);
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_light_01", "fxanim_props");
}

ceiling_light_02()
{
	level waittill("wallshoot_start");
	wait (3.8);
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_light_02", "fxanim_props");
}

tank01_entrance()
{
	telephone_clip = getent("telephone_clip","targetname");
	telephone_clip connectpaths();
	telephone_clip trigger_off();
	
	//disable the nodes around the fallen telephone pole first before the event kicks off
	nodes = getnodearray("tel_pole_nodes","script_noteworthy");
	for(i=0;i<nodes.size;i++)
	{
		SetEnableNode(nodes[i],false); 
	}
	
	level waittill("tank01_entrance_start");
	self UseAnimTree(#animtree);
	self thread anim_single(self, "a_tank01_entrance", "fxanim_props");
	
	wait(2);
	
	telephone_clip trigger_on();
	telephone_clip disconnectpaths();	
	
	//enable the nodes now that they pole has fallen
	for(i=0;i<nodes.size;i++)
	{
		SetEnableNode(nodes[i],true); 
	}	
	self waittill("a_tank01_entrance");
}

sign_leyna()
{
	level waittill("sign_leyna_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_sign_leyna", "fxanim_props");
}

tank01_death()
{
	level waittill("tank01_death_start");
	level thread blow_car(); // TFLAME - 4/15/10 - triggering car anim and tank shake as well
	level thread shake_tank();
	
	self UseAnimTree(#animtree);
	anim_single(self, "a_tank01_death", "fxanim_props");
}

shake_tank()
{
	oldtank = GetEnt("enemytank1", "targetname");
	//tank = spawn_a_model("t5_veh_tank_t55_lite", oldtank.origin, oldtank.angles);
	//tank.targetname = "enemytank1_anim_model";
	
	//oldtank Hide();
	
	oldtank.animname = "fxanim_props";
	oldtank UseAnimTree(#animtree);
	oldtank anim_single_aligned(oldtank, "a_tank01_shake", "tag_origin");
}
	

blow_tank(guy)
{
	//real vehicle
	oldtank = GetEnt("enemytank1", "targetname");

	//fake death model with turret removed
	tank = spawn_a_model("t5_veh_tank_t55_dead_lite", (-2478, 930, 7422), (-0.235, -180, 0.02) );
	tank HidePart("turret_animate_jnt", "t5_veh_tank_t55_dead_lite");
	if (IsDefined(oldtank) )
	{
		oldtank Hide();
		flag_set("enemytank1_modelswap");
	}
	
	exploder(2029);

	PlayFXOnTag(level._effect["tank_top_trail"], tank, "top_hatch");
	//tank.animname = "fxanim_props";
	//tank UseAnimTree(#animtree);
	//anim_single(tank, "a_tank01_explode");
}	

movie_sign_fall(guy)
{
	GetEnt("theater_sign_on", "targetname") Delete();
	exploder(2027);
}

fire_hydrant_timing(guy)
{
	wait 0.1;
	exploder(2035);
}

moviesign_hit_ground(guy)
{
	exploder(2034);
	get_players()[0] PlayRumbleOnEntity("pistol_fire");
	Earthquake(0.3,0.5, get_players()[0].origin, 3000);
}


tank_hit_ground(guy)
{
	exploder(2031);
	get_players()[0] PlayRumbleOnEntity("artillery_rumble");
	Earthquake(0.5,0.8, get_players()[0].origin, 3000);
}

blow_car()
{
	exploder(2021);
	car = GetEnt("cargoesboom", "targetname");
	car.animname = "fxanim_props";
	car UseAnimTree(#animtree);
	anim_single(car, "a_tank01_car_death");
}

door_office_01()
{
	level waittill("door_office_01_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_door_office_01", "fxanim_props");
}

balcony()
{
	level waittill("balcony_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_balcony", "fxanim_props");
}

tile_broke_03()
{
	level waittill("tiles_stairs_start");
	wait (3);
	self UseAnimTree(#animtree);
	anim_single(self, "a_tile_broke_03", "fxanim_props");
}

tile_broke_04()
{
	level waittill("tiles_stairs_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_tile_broke_04", "fxanim_props");
}

aagun_bldg()
{
	level waittill("aagun_bldg_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_aagun_bldg", "fxanim_props");
}

gate_swing()
{
	level waittill("gate_kick_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_gate_swing", "fxanim_props");
}

gate_kick()
{
	level waittill("gate_kick_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_gate_kick", "fxanim_props");
}	

tank01_turret()
{
	self hide();
	level waittill("tank01_death_start");
	wait (4.3);
	self show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_tank01_turret", "fxanim_props");
}	



// FXanim Props Delay
initModelAnims_delay()
{

	level.scr_anim["fxanim_props"]["a_wirespark_long"] = %fxanim_gp_wirespark_long_anim;
	level.scr_anim["fxanim_props"]["a_wirespark_med"] = %fxanim_gp_wirespark_med_anim;
	level.scr_anim["fxanim_props"]["a_streamer_01"] = %fxanim_gp_streamer01_anim;
	level.scr_anim["fxanim_props"]["a_streamer_02"] = %fxanim_gp_streamer02_anim;

	enta_wirespark_long = getentarray( "fxanim_gp_wirespark_long_mod", "targetname" );
	enta_wirespark_med = getentarray( "fxanim_gp_wirespark_med_mod", "targetname" );
	enta_streamer_01 = getentarray( "fxanim_gp_streamer01_mod", "targetname" );
	enta_streamer_02 = getentarray( "fxanim_gp_streamer02_mod", "targetname" );

	for(i=0; i<enta_wirespark_long.size; i++)
	{
 		enta_wirespark_long[i] thread wirespark_long(1,5);
 		println("************* FX: wirespark_long *************");
	}

	for(i=0; i<enta_wirespark_med.size; i++)
	{
 		enta_wirespark_med[i] thread wirespark_med(1,5);
 		println("************* FX: wirespark_med *************");
	}
	
	for(i=0; i<enta_streamer_01.size; i++)
	{
 		enta_streamer_01[i] thread streamer_01(1,3);
 		println("************* FX: streamer_01 *************");
	}
	
	for(i=0; i<enta_streamer_02.size; i++)
	{
 		enta_streamer_02[i] thread streamer_02(1,3);
 		println("************* FX: streamer_02 *************");
	}
}

wirespark_long(delay_min,delay_max)
{
	self endon ("death");
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
	self endon ("death");
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	while(1)
	{
		anim_single(self, "a_wirespark_med", "fxanim_props");
	}
}

streamer_01(delay_min,delay_max)
{
	self endon ("death");
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_streamer_01", "fxanim_props");
}

streamer_02(delay_min,delay_max)
{
	self endon ("death");
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_streamer_02", "fxanim_props");
}


// Ambient Effects
precache_createfx_fx()
{
	level._effect["fx_light_projector"]							= Loadfx("env/light/fx_light_projector");
	level._effect["fx_projector_motes"]							= Loadfx("env/light/fx_light_dust_motes_projector");

	level._effect["fx_sand_hue_windy_street"]				= Loadfx("maps/hue_city/fx_sand_hue_windy_street");
	level._effect["fx_tracers_flak_amb"]						= loadfx("weapon/tracer/fx_tracers_flak_amb_night");
	level._effect["fx_flak_field_flash"]						= loadfx("weapon/flak/fx_flak_field_flash");
	level._effect["fx_flak_around_huey"]						= loadfx("maps/hue_city/fx_flak_around_huey");

// Exploders - Commented numbers are the associated exploder IDs
	// Napalm explosion: 11
		level._effect["fx_napalm_strike_area"]					= loadfx("maps/hue_city/fx_napalm_strike_area");
	// Huey explosion: 21
		level._effect["fx_exp_vehicle_gen_stage3"]			= loadfx("explosions/fx_exp_vehicle_gen_stage3");
		level._effect["fx_debris_papers_windy_os"]			= loadfx("env/debris/fx_debris_papers_windy_os");
		level._effect["fx_exp_hue_window_glass_embers"]	= loadfx("maps/hue_city/fx_exp_hue_window_glass_embers");
	// Guy falling on desk: 22
		level._effect["fx_dest_paper_pile"]						= loadfx("destructibles/fx_dest_paper_pile");
	// Mowdown room: 30-41
		level._effect["fx_exp_hue_window_glass"]				= loadfx("maps/hue_city/fx_exp_hue_window_glass");
	// Rappel glass break: 51
		level._effect["fx_skylight_break"]							= loadfx("maps/hue_city/fx_skylight_break");
	// Rappel skylight godrays: 52, 53
	// Molotov fire spread:	101
	// Balcony shot by rocket:	110
	// Streets building destruction: 2001-2004
		level._effect["fx_exp_window_fire"]							= loadfx("maps/hue_city/fx_exp_window_fire");
		level._effect["fx_exp_window_smoke"]						= loadfx("maps/hue_city/fx_exp_window_smoke");
		level._effect["fx_dest_hydrant_water"]					= loadfx("destructibles/fx_dest_hydrant_water");
	// 1st building collapsing balconies: 2051-2055
		level._effect["fx_dest_hue_balcony_collapse"]		= loadfx("maps/hue_city/fx_dest_hue_balcony_collapse");
		// Balcony 1: 2051
		// Balcony 2: 2052
		// Balcony 3: 2053
		// Balcony ground hit: 2054
		// Large chunk ground hit: 2055
	// 1st building sign fall: 2056-2058
		// sign start, sparks: 2056
		// 'N' breaks away from sign, sparks: 2057
		// 'N' hits ground, dust poof: 2058
	// 1st tank entrance: 2010-2016
		level._effect["fx_dust_hue_tank1_entrance"]			= loadfx("maps/hue_city/fx_dust_hue_tank1_entrance");	// 2010
		level._effect["fx_impact_hue_tree"]							= loadfx("maps/hue_city/fx_impact_hue_tree");	// 2011
		// Pole 1 start: 2012
		// Pole 1 impact: 2013
		// Pole 2 start: 2014
		// Pole 2 impact: 2015
		// Wire snap: 2016
		level._effect["fx_dust_hue_pole_impact"]				= loadfx("maps/hue_city/fx_dust_hue_pole_impact");	// 2013
		level._effect["fx_impact_hue_brick_crumble"]		= loadfx("maps/hue_city/fx_impact_hue_brick_crumble");	// 2015
		// 1st tank death: 2021-2034
		level._effect["fx_tank1death_car_exp"]					= loadfx("explosions/fx_grenadeexp_concrete");	// 2021
		// sign on right falls down: 2022
		// sign impacts ground, pole gets hit: 2023
		level._effect["fx_tank1death_tank_strafe"]			= loadfx("maps/hue_city/fx_impact_hue_huey");	// 2024
		// sign on left falls down: 2025
		// falling pole hits tank: 2026
		// RapHat sign gets hit: 2027
		// corrugated canopies get hit: 2028
		level._effect["fx_exp_hue_tank1"]								= loadfx("maps/hue_city/fx_exp_hue_tank1");	// 2029
		// pole hits ground: 2030
		// tank turret hits ground: 2031
		// RapHat sign snaps off theater: 2032
		// RapHat sign hits theater awning: 2033
		// RaphHat sign hits the ground: 2034
		// Fire hydrant busts open: 2035
		level._effect["fx_tank2_entrance_debris"]				= loadfx("maps/hue_city/fx_tank2_entrance_debris");		// 700
		level._effect["fx_dust_hue_tank2_entrance"]			= loadfx("maps/hue_city/fx_dust_hue_tank2_entrance");	// 701
		level._effect["fx_tank_car_hit"]								= loadfx("maps/hue_city/fx_exp_hue_huey");						// 702
		// Balcony strike ceiling dust																																				// 703
		level._effect["fx_impact_hue_balcony_land"]			= loadfx("maps/hue_city/fx_impact_hue_balcony_land");	// 704
		level._effect["fx_exp_c4_aagun"]								= loadfx("maps/hue_city/fx_exp_c4_aagun");						// 705
		level._effect["fx_impact_aagun"]								= loadfx("maps/hue_city/fx_impact_aagun");						// 706
	// Huey landing area
		level._effect["fx_hue_lz_smoke"]								= loadfx("maps/hue_city/fx_hue_lz_smoke");						// 720
		level._effect["fx_hue_lz_smoke_scattered"]			= loadfx("maps/hue_city/fx_hue_lz_smoke_scattered");	// 721
		level._effect["fx_hue_huey_defend_landing"]			= loadfx("maps/hue_city/fx_hue_huey_defend_landing");	// 723
		level._effect["fx_hue_huey_defend_idle"]				= loadfx("maps/hue_city/fx_hue_huey_defend_idle");		// 723
		level._effect["fx_hue_huey_defend_rising"]			= loadfx("maps/hue_city/fx_hue_huey_defend_rising");	// 724
	// Smoke grenades
		level._effect["fx_defend_smoke_grenades"]				= loadfx("maps/hue_city/fx_defend_smoke_grenades");		// 730
		level._effect["fx_defend_smoke_grenades_2"]			= loadfx("maps/hue_city/fx_defend_smoke_grenades_2");	// 731
	// Huey group flyover
		// AA fire																																														// 750
		level._effect["fx_huey_flyover_dust"]						= loadfx("maps/hue_city/fx_huey_flyover_dust");				// 751-753
		// Huey 1																																															// 751
		// Huey 2																																															// 752
		// Huey 3																																															// 753
	// Blow the gate																																												// 780
	// End bombing run
		level._effect["fx_airstrike_exp1"]							= loadfx("explosions/fx_exp_bomb_huge");							// 800
		level._effect["fx_airstrike_exp2"]							= loadfx("weapon/rocket/fx_rocket_xtreme_exp_rock");	// 800
		level._effect["fx_airstrike_dust"]							= loadfx("maps/hue_city/fx_airstrike_dust");					// 800
	
// Papers
	level._effect["fx_debris_papers_windy_slow"]		= Loadfx("env/debris/fx_debris_papers_windy_slow");
	level._effect["fx_debris_papers_fall_burning"]	= Loadfx("env/debris/fx_debris_papers_fall_burning");
	level._effect["fx_debris_papers_obstructed"]		= Loadfx("env/debris/fx_debris_papers_obstructed");
	
// Dust crumbles
	level._effect["fx_dust_crumble_sm_runner"]			= LoadFX("env/dirt/fx_dust_crumble_sm_runner");
	level._effect["fx_dust_crumble_md_runner"]			= LoadFX("env/dirt/fx_dust_crumble_md_runner");
	level._effect["fx_dust_crumble_int_sm"]					= LoadFX("env/dirt/fx_dust_crumble_int_sm");
	
// Electric stuff
	level._effect["fx_elec_burst_heavy_os_int"]			= loadfx("env/electrical/fx_elec_burst_heavy_os_int");
	level._effect["fx_elec_burst_shower_sm_os_int"]	= loadfx("env/electrical/fx_elec_burst_shower_sm_os_int");
	level._effect["fx_elec_burst_shower_sm_os"]			= loadfx("env/electrical/fx_elec_burst_shower_sm_os");
	level._effect["fx_elec_burst_shower_lg_os"]			= loadfx("env/electrical/fx_elec_burst_shower_lg_os");
	
// Smoke
	level._effect["fx_smk_plume_md_wht_wispy"]			= loadfx("env/smoke/fx_smk_plume_md_wht_wispy_near");
	level._effect["fx_smk_plume_lg_wht"]						= loadfx("env/smoke/fx_smk_plume_lg_wht");
	level._effect["fx_smk_plume_xlg_tall_blk"]			= loadfx("env/smoke/fx_smk_plume_xlg_tall_blk_near");
	level._effect["fx_smk_column_black_bg"]					= loadfx("env/smoke/fx_smk_column_black_bg");
	
	level._effect["fx_smk_fire_md_gray_int"]				= loadfx("env/smoke/fx_smk_fire_md_gray_int");
	level._effect["fx_smk_fire_md_black"]						= loadfx("env/smoke/fx_smk_fire_md_black");
	level._effect["fx_smk_fire_lg_black"]						= loadfx("env/smoke/fx_smk_fire_lg_black");
	level._effect["fx_smk_fire_lg_white"]						= loadfx("env/smoke/fx_smk_fire_lg_white");
	level._effect["fx_smk_smolder_rubble_md"]				= LoadFX("env/smoke/fx_smk_smolder_rubble_md");
	level._effect["fx_smk_smolder_rubble_lg"]				= LoadFX("env/smoke/fx_smk_smolder_rubble_lg");
	level._effect["fx_smk_smolder_sm"]							= loadfx("env/smoke/fx_smk_smolder_sm");
	level._effect["fx_smk_smolder_sm_int"]					= LoadFX("env/smoke/fx_smk_smolder_sm_int");
	level._effect["fx_smk_hue_hallway_med"]					= LoadFX("maps/hue_city/fx_smk_hue_hallway_med");
	level._effect["fx_smk_hue_room_med"]						= LoadFX("maps/hue_city/fx_smk_hue_room_med");
	level._effect["fx_smk_hue_smolder_huge"]				= loadfx("maps/hue_city/fx_smk_hue_smolder_huge");
	level._effect["fx_smk_linger_lit"]							= loadfx("maps/hue_city/fx_smk_linger_lit_hue");
	level._effect["fx_smk_ceiling_crawl"]						= loadfx("env/smoke/fx_smk_ceiling_crawl");
	
// Fires
	level._effect["fx_ash_embers_heavy"]						= loadfx("env/fire/fx_ash_embers_heavy");
	level._effect["fx_embers_up_dist"]							= loadfx("env/fire/fx_embers_up_dist");
	level._effect["fx_embers_falling_sm"]						= loadfx("env/fire/fx_embers_falling_sm");
	level._effect["fx_embers_falling_md"]						= loadfx("env/fire/fx_embers_falling_md");
	level._effect["fx_fire_destruction_distant_xlg"]= loadfx("env/fire/fx_fire_destruction_distant_xlg");
	level._effect["fx_fire_column_creep_xsm"]				= loadfx("env/fire/fx_fire_column_creep_xsm");
	level._effect["fx_fire_column_creep_sm"]				= loadfx("env/fire/fx_fire_column_creep_sm");
	level._effect["fx_fire_wall_md"]								= loadfx("env/fire/fx_fire_wall_md");
	level._effect["fx_fire_ceiling_md"]							= loadfx("env/fire/fx_fire_ceiling_md");
	level._effect["fx_fire_sm_smolder"]							= loadfx("env/fire/fx_fire_sm_smolder");
	level._effect["fx_fire_md_smolder"]							= loadfx("env/fire/fx_fire_md_smolder");
	level._effect["fx_fire_hue_line_xsm"]						= loadfx("maps/hue_city/fx_fire_hue_line_xsm");
	level._effect["fx_fire_line_sm"]								= loadfx("env/fire/fx_fire_line_sm");
	level._effect["fx_fire_line_md"]								= loadfx("env/fire/fx_fire_line_md");
	level._effect["fx_fire_hue_line_lg"]						= loadfx("maps/hue_city/fx_fire_hue_line_lg");
	
	// Light effects
	level._effect["fx_light_hue_ray_md_wide"]				= loadfx("maps/hue_city/fx_light_hue_ray_md_wide");
	level._effect["fx_light_hue_ray_wide"]					= loadfx("maps/hue_city/fx_light_hue_ray_wide");
	level._effect["fx_light_hue_ray_sm"]						= loadfx("maps/hue_city/fx_light_hue_ray_sm");
	level._effect["fx_light_hue_ray_sm_thin"]				= loadfx("maps/hue_city/fx_light_hue_ray_sm_thin");
	level._effect["fx_light_hue_ray_street"]				= loadfx("maps/hue_city/fx_light_hue_ray_street");
	level._effect["fx_light_dust_motes_xsm_wide"]		= loadfx("env/light/fx_light_dust_motes_xsm_wide");
	level._effect["fx_light_dust_motes_xsm_short"]	= loadfx("env/light/fx_light_dust_motes_xsm_short");
	
}



wind_initial_setting()
{
SetSavedDvar( "wind_global_vector", "125 -20 0" );      // change "0 0 0" to your wind vector
SetSavedDvar( "wind_global_low_altitude", 7500);           // change 0 to your wind's lower bound
SetSavedDvar( "wind_global_hi_altitude", 8500);          // change 10000 to your wind's upper bound
SetSavedDvar( "wind_global_low_strength_percent", 0.4); // change 0.5 to your desired wind strength percentage
}

main()
{
	anim_notetrack_functions();
	initModelAnims();
	init_tflame_model_anims();
	precache_util_fx();	precache_createfx_fx();
	precache_scripted_fx();
	wind_initial_setting();
	maps\createfx\hue_city_fx::main();
	maps\createart\hue_city_art::main();
	
	level thread tiles_fall();
	
}


init_tflame_model_anims()
{
	level.scr_anim["fxanim_props"]["aa_gun_fall"] = %fxanim_hue_aagun_anim;
}

//****  Additional functions from TFlame

aa_gun_fall_anim()
{
	level waittill ("aagun_bldg_start");
	
	gun = GetEnt("alley_aa_gun", "targetname");
	fakegun = spawn_a_model("fxanim_hue_aagun_mod", gun.origin, gun.angles);
	gun vehicle_delete();
	
	fakegun UseAnimTree(#animtree);
	fakegun.animname = "fxanim_props";
	fakegun thread anim_single(fakegun, "aa_gun_fall", "fxanim_props");
	
	wait 0.7;
	Earthquake(0.4, 0.5, fakegun.origin, 2000);

	exploder(706);
}

tiles_fall()
{
	level waittill("spawn_stair_mowdown");
	level notify ("tiles_stairs_start");
}


long_spark_wire(guy)
{
	PlayFXOnTag(level._effect["wire_spark"], guy, "long_spark_06_jnt");
}

med_spark_wire(guy)
{
	PlayFXOnTag(level._effect["wire_spark"], guy, "med_spark_06_jnt");
}


pole_falls(guy)
{
	wait_and_shake_custom(0.1, 0.4, 0.6, "assault_fire");
}
