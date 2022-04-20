#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;

#using_animtree("fxanim_props");

main()
{	
	initModelAnims();
//precache_util_fx();
//precache_createfx_fx();

	maps\createfx\cuba_fx::main();

	level._effect["fire_hydrant"]		= LoadFX("destructibles/fx_cuba_dest_hydrant");
	level._effect["light_pole"]			= LoadFX("maps/cuba/fx_cuba_dest_light_pole");
	level._effect["elec_box_top"]		= LoadFX("destructibles/fx_cuba_dest_elec_box");
	level._effect["elec_box_bottom"]	= LoadFX("destructibles/fx_cuba_dest_elec_box_low");
	level._effect["police_spotlight"]	= LoadFX("maps/hue_city/fx_huey_spotlight_macv");
	level._effect["police_floodlight"]	= LoadFX("maps/cuba/fx_cuba_flood_light");

	level._effect["engine_fire"]		= LoadFX("vehicle/vfire/fx_cuba_veh_engine_fire");

	level._effect["taillight_left"]		= LoadFX("vehicle/light/fx_cuba_police_taillight_left");
	level._effect["taillight_right"]	= LoadFX("vehicle/light/fx_cuba_police_taillight_right");
	level._effect["siren_light"]		= LoadFX( "maps/cuba/fx_cuba_siren_light" );
	level._effect["head_lights"]		= LoadFX("vehicle/light/fx_cuba_police_headlight");
	level._effect["head_dlight"]		= LoadFX("maps/cuba/fx_cuba_veh_front_end_lights");

	level._effect["car_wind"]		= LoadFX("maps/cuba/fx_cuba_car_wind");
	level._effect["cig_smk"]		= LoadFX("maps/cuba/fx_cuba_cig_tip_smk");

	level._effect["glass_brk_f"]	= LoadFX("maps/cuba/fx_cuba_car_glass_brk_f");
	level._effect["glass_brk_l"]	= LoadFX("maps/cuba/fx_cuba_car_glass_brk_l");
	level._effect["glass_brk_r"]	= LoadFX("maps/cuba/fx_cuba_car_glass_brk_r");
	level._effect["glass_brk_b"]	= LoadFX("maps/cuba/fx_cuba_car_glass_brk_b");
	level._effect["glass_brk_kick"]	= LoadFX("maps/cuba/fx_cuba_car_glass_kick");
	
	// effects in zipline area
	level._effect["flare_trail"]	= LoadFX("misc/fx_cuba_flare");
	level._effect["flare_burst"]	= LoadFX("misc/fx_cuba_flare_burst");

	level._effect["garrot_kill"]	= LoadFX("maps/cuba/fx_cuba_garrote_spit");

	level._effect["sirens"]					= LoadFX("env/light/fx_police_car_flashing");
	level._effect["chopper_burning"]		= LoadFX("vehicle/vfire/fx_vsmoke_huey_trail");
	level._effect["fx_ks_ambient_aa_flak"]	= LoadFX("maps/khe_sanh/fx_ks_ambient_aa_flak");	
	level._effect["airfield_artillery"]		= LoadFX("explosions/artilleryExp_dirt_brown");	
	
	//airfield mortars
	level._effectType["airfield_ambient_mortar"]		= "mortar";
	level._effect["airfield_ambient_mortar"]			= LoadFX("maps/cuba/fx_cuba_mortarexp_dirt");	
	level._effectType["airfield_ambient_mortar_right"]	= "mortar";
	level._effect["airfield_ambient_mortar_right"]		= LoadFX("maps/cuba/fx_cuba_mortarexp_dirt");	
	level._effectType["airfield_ambient_mortar_left"]	= "mortar";
	level._effect["airfield_ambient_mortar_left"]		= LoadFX("maps/cuba/fx_cuba_mortarexp_dirt");
	
	//ac130 plane FX
	level._effect["plane_prop_1"] = LoadFX("maps/cuba/fx_cuba_c130_prop_slow");
	level._effect["plane_prop_2"] = LoadFX("maps/cuba/fx_cuba_c130_prop_half");
	level._effect["plane_prop_3"] = LoadFX("maps/cuba/fx_cuba_c130_prop_full");
	
	//succss smoke spirals
	level._effect["plane_smoke_spiral"] = LoadFX("maps/cuba/fx_cuba_c130_smk_fly_through"); 
	
	//fail explosion
	level._effect["fail_explosion"] = LoadFX("maps/cuba/fx_cuba_c130_fail_explo");
	
	
	//temp black smoke colums in the airfield
	level._effect["airfield_smoke"]				= LoadFX("env/smoke/fx_smk_column_xlg_blk");
	level._effect["airfield_fire_smoke"]		= LoadFX("env/smoke/fx_smk_fire_lg_black");
	
	level._effect["fx_glass_heli_break"]		= LoadFX("maps/creek/fx_glass_heli_break");		
	
	level._effect["drone_muzzle_flash"]			= LoadFX("maps/cuba/fx_tracer_distant_drones");

	level._effect["fire_med"]					= LoadFX("env/fire/fx_fire_md");

	level._effect["wallbreach"]					    = LoadFX( "maps/cuba/fx_cuba_mortarexp_dirt" );   //btr door breech
	level._effect["fallingboards_fire"]			= LoadFX( "maps/ber2/fx_debris_wood_boards_fire" );
	level._effect["fx_door_breach_kick"]		= LoadFX("maps/flashpoint/fx_door_breach_kick");
	
	level._effect["concrete_ceiling_dust"]		= LoadFX("env/dirt/fx_concrete_ceiling_impact_md");  
	level._effect["bow_effect_on_sampan_death"]	= LoadFX( "maps/cuba/fx_cuba_btr_door_exp" );    //btr door breech
	

	level._effect["founatin_splash_1"]	= LoadFX( "maps/mp_maps/fx_mp_hotel_fountain_splash01" );
	level._effect["founatin_splash_2"]	= LoadFX( "maps/mp_maps/fx_mp_hotel_fountain_splash02" );

  // Ambient Effects
	level._effect["fx_cuba_candle"]                 = LoadFX("maps/cuba/fx_cuba_candle"); 
	level._effect["fx_cuba_candle_smoke_only"]      = LoadFX("maps/cuba/fx_cuba_candle_smoke_only"); 	
	level._effect["fx_cuba_cigar_smoke"]            = LoadFX("maps/cuba/fx_cuba_cigar_smoke"); 
	level._effect["fx_cuba_smk_ambient_room"]       = LoadFX("maps/cuba/fx_cuba_smk_ambient_room");	
	level._effect["fx_cuba_smk_ambient_room_md"]    = LoadFX("maps/cuba/fx_cuba_smk_ambient_room_md");		
	level._effect["fx_cuba_dust_motes_interior"]    = LoadFX("maps/cuba/fx_cuba_dust_motes_interior");		
	level._effect["fx_cuba_window_break_bar"]       = LoadFX("maps/cuba/fx_cuba_window_break_bar");			
	level._effect["fx_cuba_insect_swarm"]           = LoadFX("maps/cuba/fx_cuba_insect_swarm");		
	level._effect["fx_cuba_moths_light"]            = LoadFX("maps/cuba/fx_cuba_moths_light");			
	level._effect["fx_cuba_water_fountain"]         = LoadFX("maps/cuba/fx_cuba_water_fountain");	
//	level._effect["fx_cuba_water_fountain_tilt"]    = LoadFX("maps/cuba/fx_cuba_water_fountain_tilt");								
	level._effect["fx_cuba_tinhat_light"]           = LoadFX("maps/cuba/fx_cuba_tinhat_light");
	level._effect["fx_cuba_tinhat_light_lrg"]       = LoadFX("maps/cuba/fx_cuba_tinhat_light_lrg");	
	level._effect["fx_cuba_tinhat_light_interior"]  = LoadFX("maps/cuba/fx_cuba_tinhat_light_interior");			
	level._effect["fx_cuba_street_light"]           = LoadFX("maps/cuba/fx_cuba_street_light");	
	level._effect["fx_cuba_street_light_sml"]       = LoadFX("maps/cuba/fx_cuba_street_light_sml");		
	level._effect["fx_cuba_street_battle_wind"]     = LoadFX("maps/cuba/fx_cuba_street_battle_wind");		
	level._effect["fx_cuba_leaves_falling"]         = LoadFX("maps/cuba/fx_cuba_leaves_falling");
	level._effect["fx_cuba_seagulls"]               = LoadFX("maps/cuba/fx_cuba_seagulls");	
	level._effect["fx_cuba_bomb_explo"]             = LoadFX("maps/cuba/fx_cuba_bomb_explo");	
	level._effect["fx_cuba_aa_flak_ambient_low"]    = LoadFX("maps/cuba/fx_cuba_aa_flak_ambient_low");	
	level._effect["fx_cuba_aa_flak_ambient_high"]   = LoadFX("maps/cuba/fx_cuba_aa_flak_ambient_high");
	level._effect["fx_cuba_smk_column_sm_os"]       = LoadFX("maps/cuba/fx_cuba_smk_column_sm_os");			
	level._effect["fx_cuba_smk_column_sm"]          = LoadFX("maps/cuba/fx_cuba_smk_column_sm");			
	level._effect["fx_cuba_smk_column_md"]          = LoadFX("maps/cuba/fx_cuba_smk_column_md");			
	level._effect["fx_cuba_smk_column_xlg"]         = LoadFX("maps/cuba/fx_cuba_smk_column_xlg");
	level._effect["fx_cuba_explo_hanger_sm"]        = LoadFX("maps/cuba/fx_cuba_explo_hanger_sm");
	level._effect["fx_cuba_explo_hanger_out"]       = LoadFX("maps/cuba/fx_cuba_explo_hanger_out");	
	level._effect["fx_cuba_god_ray_short_wide"]     = LoadFX("maps/cuba/fx_cuba_god_ray_short_wide");	
	level._effect["fx_cuba_god_ray_med"]            = LoadFX("maps/cuba/fx_cuba_god_ray_med");	
	level._effect["fx_cuba_god_ray_lrg"]            = LoadFX("maps/cuba/fx_cuba_god_ray_lrg");			
	level._effect["fx_cuba_god_ray_xlg"]            = LoadFX("maps/cuba/fx_cuba_god_ray_xlg");			
	level._effect["fx_cuba_fire_line_sm"]           = LoadFX("maps/cuba/fx_cuba_fire_line_sm");			
	level._effect["fx_fire_sm"]                     = LoadFX("env/fire/fx_fire_sm");	
	level._effect["fx_fire_line_xsm_thin"]				  = LoadFX("env/fire/fx_fire_line_xsm_thin");		
	level._effect["fx_fire_detail_sm_nodlight"]			= LoadFX("env/fire/fx_fire_detail_sm_nodlight");
	level._effect["fx_cuba_fire_detail_sm"]         = LoadFX("maps/cuba/fx_cuba_fire_detail_sm");				
	level._effect["fx_fire_ceiling_md_slow"]			  = LoadFX("env/fire/fx_fire_ceiling_md_slow");
	level._effect["fx_fire_md"]			                = LoadFX("env/fire/fx_fire_md");					
	level._effect["fx_ash_embers_light"]				    = LoadFX("env/fire/fx_ash_embers_light");		
	level._effect["fx_ks_smoldering_tree"]				  = LoadFX("maps/khe_sanh/fx_ks_smoldering_tree");		
	level._effect["fx_cuba_bomb_crater"]            = LoadFX("maps/cuba/fx_cuba_bomb_crater");
//	level._effect["fx_cuba_shrimp_left"]            = LoadFX("maps/cuba/fx_cuba_shrimp_left");
//	level._effect["fx_cuba_shrimp_right"]           = LoadFX("maps/cuba/fx_cuba_shrimp_right");		
//	level._effect["fx_cuba_shrimp_forward_left"]    = LoadFX("maps/cuba/fx_cuba_shrimp_forward_left");
//	level._effect["fx_cuba_shrimp_forward_right"]   = LoadFX("maps/cuba/fx_cuba_shrimp_forward_right");						
	level._effect["fx_cuba_c130_explo_finale"]      = LoadFX("maps/cuba/fx_cuba_c130_explo_finale");
	level._effect["fx_cuba_ceiling_collapse"]       = LoadFX("maps/cuba/fx_cuba_ceiling_collapse");		
	level._effect["fx_cuba_btr_explo"]              = LoadFX("maps/cuba/fx_cuba_btr_explo");	
	level._effect["fx_cuba_hand_stab"]              = LoadFX("maps/cuba/fx_cuba_hand_stab");				
	level._effect["fx_cuba_window_break"]           = LoadFX("maps/cuba/fx_cuba_window_break");	
	level._effect["fx_cuba_dest_light_pole"]        = LoadFX("maps/cuba/fx_cuba_dest_light_pole");	
	level._effect["fx_cuba_zip_landing"]            = LoadFX("maps/cuba/fx_cuba_zip_landing");						
	level._effect["fx_cuba_hall_collapse"]          = LoadFX("maps/cuba/fx_cuba_hall_collapse");				
	level._effect["fx_cuba_cliff_rappel"]           = LoadFX("maps/cuba/fx_cuba_cliff_rappel");		
	level._effect["fx_cuba_tower_collapse"]         = LoadFX("maps/cuba/fx_cuba_tower_collapse");		
	level._effect["fx_cuba_fidel_bed"]              = LoadFX("maps/cuba/fx_cuba_fidel_bed");	
	level._effect["fx_cuba_embers_field_sm"]        = LoadFX("maps/cuba/fx_cuba_embers_field_sm");		
	level._effect["fx_cuba_dest_barricade"]         = LoadFX("maps/cuba/fx_cuba_dest_barricade");		
										
	
	//bowman victim blood fx
	level._effect["blood"]			= LoadFX( "impacts/flesh_hit_body_fatal_exit" );
						
	//masnion chandelier
	level._effect["chandelier_on"]			= LoadFX( "maps/cuba/fx_cuba_chandelier_lrg" );
		
	// mansion effects	
	level._effect["dust_light"]	= LoadFX("maps/cuba/fx_cuba_ceiling_low_dust_heavy");
	level._effect["dust_heavy"]	= LoadFX("maps/cuba/fx_cuba_ceiling_low_dust_light");

	// additional glass effect for breaches, used in pre-assasination and castro assasination
	level._effect["breach_glass_window"]	= LoadFX("maps/cuba/fx_cuba_window_break_sm");

	// Dont delete, being used on clientscript for dynents
	level._effect["chandelier_fx"]	= LoadFX("maps/cuba/fx_cuba_chandelier_med");

	// assassination bulletcam headshot
	level._effect["_bulletcam_impact"] = LoadFX( "maps/cuba/fx_cuba_headshot" );
				
	level._effect["uaz_headlight"]		= LoadFX( "vehicle/light/fx_jeep_uaz_headlight" );
	level._effect["btr_headlight_fx"]	= LoadFX( "vehicle/light/fx_apc_btr60_headlight" );
	level._effect["btr_taillight"]		= LoadFX( "vehicle/light/fx_jeep_uaz_taillight" );

	level._effect["jet_contrail"]	= LoadFX("trail/fx_geotrail_jet_contrail");
	level._effect[ "jet_exhaust" ]	= LoadFX( "vehicle/exhaust/fx_exhaust_jet_afterburner" );
	
	//more airfield fx 
	level._effect["vehicle_explosion"]	= LoadFX("explosions/fx_exp_vehicle_gen");
	level._effect["darwins_vehicle_explosion"]	= LoadFX("maps/cuba/fx_cuba_veh_explo" );
	wind_initial_setting();	
	
	//burning guys
	level._effect["ai_fire"] = LoadFx("env/fire/fx_fire_player_torso");
	
	//plane takes damage
	level._effect["plane_dmg1"] = LoadFx("maps/cuba/fx_cuba_c130_fire_1");
	level._effect["plane_dmg2"] = LoadFx("maps/cuba/fx_cuba_c130_fire_2");
	level._effect["plane_dmg3"] = LoadFx("maps/cuba/fx_cuba_c130_fire_2");
	level._effect["plane_dmg4"] = LoadFx("maps/cuba/fx_cuba_c130_fire_3");
	
	level._effect["cigar_fx"] = LoadFx("maps/cuba/fx_cuba_fidel_cigar");
}

// FXanim Props
initModelAnims()
{
	level.scr_anim["fxanim_props"]["a_curtain_sheer"] = %fxanim_cuba_curtain_sheer_anim;
	level.scr_anim["fxanim_props"]["a_curtain_sheer_hang"] = %fxanim_cuba_curtain_sheer_hang_anim;
	level.scr_anim["fxanim_props"]["a_lamppost_01_hit"] = %fxanim_cuba_lamppost_01_hit_anim;
	level.scr_anim["fxanim_props"]["a_lamppost_01_fall"] = %fxanim_cuba_lamppost_01_fall_anim;
	level.scr_anim["fxanim_props"]["a_line_flag01"] = %fxanim_cuba_line_flag01_anim;
	level.scr_anim["fxanim_props"]["a_line_flag02"] = %fxanim_cuba_line_flag02_anim;
	level.scr_anim["fxanim_props"]["a_radar_tower"] = %fxanim_cuba_radar_tower_anim;
	level.scr_anim["fxanim_props"]["a_tree_palm_coco02"] = %fxanim_gp_tree_palm_coco02_dest02_anim;	
	level.scr_anim["fxanim_props"]["a_tree_aquilaria_dest02"] = %fxanim_gp_tree_aquilaria_dest02_anim;
	level.scr_anim["fxanim_props"]["a_chandelier_fall"] = %fxanim_cuba_chandelier_fall_anim;
	level.scr_anim["fxanim_props"]["a_chandelier_sway"] = %fxanim_cuba_chandelier_sway_anim;	
	level.scr_anim["fxanim_props"]["a_chandelier_boards"] = %fxanim_cuba_chandelier_boards_anim;
	level.scr_anim["fxanim_props"]["a_cuba_sign"] = %fxanim_cuba_sign_anim;
	level.scr_anim["fxanim_props"]["a_runway_crate01"] = %fxanim_gp_tarp_crate_stack_anim;
	level.scr_anim["fxanim_props"]["a_car_fan"][0] = %fxanim_cuba_car_fan_anim;
	level.scr_anim["fxanim_props"]["a_car_props"][0] = %fxanim_cuba_car_props_anim;
	level.scr_anim["fxanim_props"]["a_car_cig"] = %fxanim_cuba_car_cig_anim;
	level.scr_anim["fxanim_props"]["a_rat_01"] = %fxanim_cuba_rat_01_anim;
	level.scr_anim["fxanim_props"]["a_rat_02"] = %fxanim_cuba_rat_02_anim;

	ent1 = getent( "fxanim_cuba_lamppost_01_mod", "targetname" );
	ent2 = getent( "fxanim_cuba_line_flag01_01", "targetname" );
	
	ent4 = getent( "fxanim_cuba_line_flag01_03", "targetname" );
	ent5 = getent( "fxanim_pow_radar_tower_mod", "targetname" );
	ent6 = getent( "tree_palm_coco01", "targetname" );
	ent7 = getent( "tree_palm_coco02", "targetname" );
	ent8 = getent( "fxanim_gp_tree_aquilaria_mod", "targetname" );
	ent9 = getent( "fxanim_cuba_chandelier_mod", "targetname" );
	ent10 = getent( "fxanim_cuba_chandelier_boards_mod", "targetname" );
	ent11 = getent( "fxanim_cuba_sign_mod", "targetname" );
	ent12 = getent( "fxanim_cuba_car_props_mod", "targetname" );
	ent13 = getent( "fxanim_cuba_car_cig_mod", "targetname" );
	ent14 = getent( "fxanim_cuba_rat_01_anim", "targetname" );
	ent15 = getent( "fxanim_cuba_rat_02_anim", "targetname" );		

	enta_curtain_sheer = GetEntArray( "fxanim_cuba_curtain_sheer_mod", "targetname" );
	enta_curtain_sheer_hang = GetEntArray( "fxanim_cuba_curtain_sheer_hang_mod", "targetname" );
	enta_runway_crate01 = GetEntArray( "runway_crate01", "targetname" );
	enta_line_flag02 = GetEntArray( "fxanim_cuba_line_flag02_mod", "targetname" );

	if (IsDefined(ent1)) 
	{
		ent1 thread lamppost_01_hit();
		println("************* FX: lamppost_01_hit *************");
	}

	if (IsDefined(ent1)) 
	{
		ent1 thread lamppost_01_fall();
		println("************* FX: lamppost_01_fall *************");
	}
	
	for(i=0; i<enta_curtain_sheer.size; i++)
	{
 		enta_curtain_sheer[i] thread curtain_sheer(1,3);
 		println("************* FX: curtain_sheer *************");
	}
	
	for(i=0; i<enta_curtain_sheer_hang.size; i++)
	{
 		enta_curtain_sheer_hang[i] thread curtain_sheer_hang(1,3);
 		println("************* FX: curtain_sheer_hang *************");
	}
	
	if (IsDefined(ent2)) 
	{
		ent2 thread line_flag01();
		println("************* FX: line_flag01 *************");
	}
	
	for(i=0; i<enta_line_flag02.size; i++)
	{
 		enta_line_flag02[i] thread line_flag02(1,3);
 		println("************* FX: line_flag02 *************");
	}
		
	if (IsDefined(ent4)) 
	{
		ent4 thread line_flag03();
		println("************* FX: line_flag03 *************");
	}
		
	if (IsDefined(ent5)) 
	{
		ent5 thread radar_tower();
		println("************* FX: radar_tower *************");
	}
	
	if (IsDefined(ent6)) 
	{
		ent6 thread tree_palm_coco01();
		println("************* FX: tree_palm_coco01 *************");
	}
	
	if (IsDefined(ent7)) 
	{
		ent7 thread tree_palm_coco02();
		println("************* FX: tree_palm_coco02 *************");
	}
	
	if (IsDefined(ent8)) 
	{
		ent8 thread tree_aquilaria_dest02();
		println("************* FX: tree_aquilaria_dest02 *************");
	}
	
	if (IsDefined(ent9)) 
	{
		ent9 thread chandelier();
		println("************* FX: chandelier *************");
	}
	
	if (IsDefined(ent10)) 
	{
		ent10 thread chandelier_boards();
		println("************* FX: chandelier_boards *************");
	}	
	
	if (IsDefined(ent11)) 
	{
		ent11 thread cuba_sign();
		println("************* FX: cuba_sign *************");
	}
	
	for(i=0; i<enta_runway_crate01.size; i++)
	{
 		enta_runway_crate01[i] thread runway_crate01(.1,.5);
 		println("************* FX: runway_crate01 *************");
	}
	
	if (IsDefined(ent12)) 
	{
		ent12 thread car_props();
		println("************* FX: car_props *************");
	}
	
	if (IsDefined(ent13)) 
	{
		ent13 thread car_cig();
		println("************* FX: car_cig *************");
	}
	
	if (IsDefined(ent14)) 
	{
		ent14 thread rat_01();
		println("************* FX: rat_01 *************");
	}
	
	if (IsDefined(ent15)) 
	{
		ent15 thread rat_02();
		println("************* FX: rat_02 *************");
	}		
}

lamppost_01_hit()
{
	level waittill("lamppost_01_hit_start");
	self UseAnimTree(#animtree);
	PlayFXOnTag(level._effect["light_pole"], self, "tag_origin");
	anim_single(self, "a_lamppost_01_hit", "fxanim_props");
	flag_set("lamppost_01_hit_start");
}

lamppost_01_fall()
{
	level waittill("lamppost_01_fall_start");
	//level notify("cuba_sign_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_lamppost_01_fall", "fxanim_props");
}

curtain_sheer(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_curtain_sheer", "fxanim_props");
}

curtain_sheer_hang(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_curtain_sheer_hang", "fxanim_props");
}

line_flag01()
{
	wait(1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_line_flag01", "fxanim_props");
}

line_flag02(delay_min,delay_max)
{
  wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_line_flag02", "fxanim_props");
}

line_flag03()
{
	wait(2);
	self UseAnimTree(#animtree);
	anim_single(self, "a_line_flag01", "fxanim_props");
}

radar_tower()
{
	level waittill("radar_tower_start");
	self PlaySound( "evt_radar_tower_hit" );
	self UseAnimTree(#animtree);
	anim_single(self, "a_radar_tower", "fxanim_props");
}

tree_palm_coco01()
{
	level waittill("tree_palm_coco01_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_tree_palm_coco02", "fxanim_props");
}

tree_palm_coco02()
{
	level waittill("tree_palm_coco02_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_tree_palm_coco02", "fxanim_props");
}

tree_aquilaria_dest02()
{
	level waittill("tree_aquilaria_dest02_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_tree_aquilaria_dest02", "fxanim_props");
}

chandelier()
{
	wait(1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_chandelier_sway", "fxanim_props");
	level waittill("chandelier_start");
	self playsound ("evt_chandelier_fall");
	
	anim_single(self, "a_chandelier_fall", "fxanim_props");
}

chandelier_boards()
{
	self Hide();
	level waittill("chandelier_start");
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_chandelier_boards", "fxanim_props");
}

cuba_sign()
{
	level waittill("cuba_sign_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_cuba_sign", "fxanim_props");
}

runway_crate01(delay_min,delay_max)
{
	level waittill("runway_crate01_start");
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_runway_crate01", "fxanim_props");
}

car_props()
{
	self UseAnimTree(#animtree);
}

car_cig()
{
	self UseAnimTree(#animtree);
}

rat_01()
{
	level waittill("alley_rat_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_rat_01", "fxanim_props");
	self delete();
}

rat_02()
{
	level waittill("alley_rat_start");
	wait(.75);
	self UseAnimTree(#animtree);
	anim_single(self, "a_rat_02", "fxanim_props");
	self delete();
}


wind_initial_setting()
{
	SetSavedDvar( "wind_global_vector", "188 146 112" );    // change "0 0 0" to your wind vector
	SetSavedDvar( "wind_global_low_altitude", 0);    // change 0 to your wind's lower bound
	SetSavedDvar( "wind_global_hi_altitude", 6000);    // change 10000 to your wind's upper bound
	SetSavedDvar( "wind_global_low_strength_percent", 0.3);    // change 0.5 to your desired wind strength percentage
}

wind_goatpath_setting()
{
	SetSavedDvar( "wind_global_vector", "228 145 112" );
}
