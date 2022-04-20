#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#using_animtree("fxanim_props");

// fx used by util scripts
precache_util_fx()
{
}

// Scripted effects
precache_scripted_fx()
{
	//cold breath
	level._effect["cold_breath"] 				= LoadFX("bio/player/fx_cold_breath2");
	level._effect["cold_breath_elem"] 	= LoadFX("bio/player/fx_cold_breath2_elem");
	level._effect["cold_breath_player"] = LoadFX("bio/player/fx_cold_breath2_player");

	// flashlight
	level._effect[ "flashlight_cone" ] = LoadFX("env/light/fx_spotlight_flashlight");

	// explosions
	level._effect[ "explosion_1" ] = LoadFX( "maps/fullahead/fx_exp_ship_sink" );

	// mortar
	level._effectType["mortar"]		= "mortar";
	level._effect["mortar"]	   		= LoadFX("weapon/mortar/fx_mortar_exp_snow");
	//level._effect["mortar"]	   		= LoadFX("weapon/artillery/fx_artillery_exp_strike_concrte_mp");
	level._effect["mortar_flash"] = LoadFX("weapon/mortar/fx_mortar_launch_trail_fake");
	level.mortar = level._effect["mortar"];

	level._effect["orange_smoke"]					= loadfX("maps/fullahead/fx_smoke_marker_orange");
	level._effect["orange_smoke_int"]			= loadfx("maps/fullahead/fx_smoke_marker_orange_int");

	// tracker
	level._effect["tracking_device"] = LoadFX( "env/light/fx_police_car_flashing" );
	level._effect["tracking_beacon"] = LoadFX( "misc/fx_light_c4_blink" );

	// welding
	level._effect["torch_sparks"]= LoadFX("misc/fx_metal_torch_cutting_sparks");

	// guys catching on fire
	level._effect["enemy_on_fire"] = LoadFx("env/fire/fx_fire_player_torso");
	
	// scripted retreating guys getting shot
	level._effect["bloodspurt"] 	= LoadFX( "impacts/fx_flesh_hit_body_fatal_lg_exit" );
	
	// Reznov vignette fade in snow
	level._effect["vignette_snow"] = LoadFX("maps/fullahead/fx_vignette_fadein");

	level._effect["cig_smoke"] =  LoadFX("maps/fullahead/fx_cigarette_lit_smk");
	level._effect["cig_drag"] =  LoadFX("maps/fullahead/fx_cigarette_lit_smk_drag");
	level._effect["cig_exhale"] = LoadFX("maps/fullahead/fx_cigarette_smk_exhale");
	level._effect["cig_flick"] = LoadFX("maps/fullahead/fx_cigarette_lit_flick");
	
	//kravchenko muzzleflash
	level._effect["muzzle_flash"] = LoadFX("weapon/muzzleflashes/fx_pistol_flash_base");

	//kravchenko throat slice
	level._effect["throat_slice"] = LoadFX("impacts/fx_melee_neck_stab_crouching");

	//patrenko puss
	level._effect["gas_puss"] = LoadFX("maps/rebirth/fx_nova6_death_fumes_ai");

	//patrenko vomit
	level._effect["vomit_floor"] = LoadFX("maps/flashpoint/fx_vomit_projectile");
	level._effect["engine_heat"] = LoadFX("vehicle/exhaust/fx_engine_heat_snowcat");
	level._effect["snowcat_exhaust"] =  LoadFX("vehicle/exhaust/fx_exhaust_snowcat");

}



// FXanim Props
initModelAnims()
{
	level.scr_anim["fxanim_props"]["a_wires"] = %fxanim_fullahead_wires_anim;
	level.scr_anim["fxanim_props"]["a_panel_rattle"] = %fxanim_fullahead_panel_rattle_anim;
	level.scr_anim["fxanim_props"]["a_windsock"] = %fxanim_gp_windsock_anim;
	level.scr_anim["fxanim_props"]["a_tarp_stack"] = %fxanim_gp_tarp_wood_stack_anim;	
	level.scr_anim["fxanim_props"]["a_barrier"] = %fxanim_fullahead_barrier_anim;
	level.scr_anim["fxanim_props"]["a_bridge"] = %fxanim_fullahead_bridge_anim;
	level.scr_anim["fxanim_props"]["a_warehouse01"] = %fxanim_fullahead_warehouse01_anim;
	level.scr_anim["fxanim_props"]["a_ship_debris"] = %fxanim_fullahead_ship_debris_anim;
	level.scr_anim["fxanim_props"]["a_rocket_fall"] = %fxanim_fullahead_rocket_fall_anim;		

	ent1 = GetEnt( "fxanim_fullahead_wires_mod", "targetname" );
	ent2 = GetEnt( "fxanim_fullahead_barrier", "targetname" );
	ent3 = GetEnt( "fxanim_fullahead_bridge_mod", "targetname" );
	ent4 = GetEnt( "fullahead_warehouse01", "targetname" );
	ent5 = GetEnt( "fxanim_fullahead_ship_debris_mod", "targetname" );
	ent6 = GetEnt( "fxanim_fullahead_rocket_fall_mod", "targetname" );
	
	enta_panel_rattle = GetEntArray( "fxanim_fullahead_panel_rattle_mod", "targetname" );
	enta_windsock = getentarray( "fxanim_gp_windsock_mod", "targetname" );
	enta_tarp_stack = getentarray( "fxanim_gp_tarp_wood_stack_mod", "targetname" );		

	if (IsDefined(ent1)) 
	{
		ent1 thread wires();
		println("************* FX: wires *************");
	}
	
	if (IsDefined(ent2)) 
	{
		ent2 thread barrier();
		println("************* FX: barrier *************");
	}
	
	for(i=0; i<enta_panel_rattle.size; i++)
	{
 		enta_panel_rattle[i] thread panel_rattle(1,3);
 		println("************* FX: panel_rattle *************");
	}	
	
	for(i=0; i<enta_windsock.size; i++)
	{
 		enta_windsock[i] thread windsock(1,5);
 		println("************* FX: windsock *************");
	}	
	
	for(i=0; i<enta_tarp_stack.size; i++)
	{
 		enta_tarp_stack[i] thread tarp_stack(1,5);
 		println("************* FX: tarp_stack *************");
	}
	
	if (IsDefined(ent3)) 
	{
		ent3 thread bridge();
		println("************* FX: bridge *************");
	}
	
	if (IsDefined(ent4)) 
	{
		ent4 thread warehouse01();
		println("************* FX: warehouse01 *************");
	}

	if (IsDefined(ent5)) 
	{
		ent5 thread ship_debris();
		println("************* FX: ship_debris *************");
	}	
	
	if (IsDefined(ent6)) 
	{
		ent6 thread rocket_fall();
		println("************* FX: rocket_fall *************");
	}
}

wires()
{
	wait(.5);
	if( IsDefined( self ) )
	{
		self UseAnimTree(#animtree);
		anim_single(self, "a_wires", "fxanim_props");
	}
}

barrier()
{
	level waittill("barrier_start");
	if( IsDefined( self ) )
	{
		self UseAnimTree(#animtree);
		anim_single(self, "a_barrier", "fxanim_props");
	}
}

panel_rattle(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	if( IsDefined( self ) )
	{
		self UseAnimTree(#animtree);
		anim_single(self, "a_panel_rattle", "fxanim_props");
	}
}

windsock(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	if( IsDefined( self ) )
	{
		self UseAnimTree(#animtree);
		anim_single(self, "a_windsock", "fxanim_props");
	}
}

tarp_stack(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	if( IsDefined( self ) )
	{
		self UseAnimTree(#animtree);
		anim_single(self, "a_tarp_stack", "fxanim_props");
	}
}

bridge()
{
	level waittill("bridge_start");
	if( IsDefined( self ) )
	{
		self UseAnimTree(#animtree);
		anim_single(self, "a_bridge", "fxanim_props");
	}
}

warehouse01()
{
	level waittill("warehouse01_start");
	if( IsDefined( self ) )
	{
		self UseAnimTree(#animtree);
		anim_single(self, "a_warehouse01", "fxanim_props");
	}
}

ship_debris()
{
	level waittill("ship_debris_start");
	if( IsDefined( self ) )
	{
		self UseAnimTree(#animtree);
		anim_single(self, "a_ship_debris", "fxanim_props");
	}
}

rocket_fall()
{
	level waittill("rocket_fall_start");
	level.cargobay_rocket LinkTo ( self, "rocket_jnt" );
	if( IsDefined( self ) )
	{
		self UseAnimTree(#animtree);
		anim_single(self, "a_rocket_fall", "fxanim_props");
	}
}



// Ambient effects
precache_createfx_fx()
{
//	Reznov's soliloquy: -1171 -1164 -115 68 359
	
// Exploders
	level._effect["fx_mortar"]													= loadfx("maps/fullahead/fx_exp_building_mortar");	// 100, 110
	level._effect["fx_exp_door_lg"]											= loadfx("explosions/fx_exp_door_lg");						// 100
	level._effect["fx_exp_building_window"]							= loadfx("maps/fullahead/fx_exp_building_window");	// 100, 110
	level._effect["fx_exp_barrier"]											= loadfx("maps/fullahead/fx_exp_barrier");	// 220
	level._effect["fx_cigarette_smk_ambient"]						= loadfx("maps/fullahead/fx_cigarette_smk_ambient");	// 295
	// explosion to block off cargo bay exit: 401
	// Betrayal
		// Scene 1: 12244 -17311 619 30 0
		// Scene 2: 12364 -17303 647 44 4
		// Scene 3: 11966 -17648 693 240 330	// gas container shot
		// Scene 4: 12365 -17290 654 55 27
		// Scene 5: 12309 -17244 620 18 352
		// Scene 6: 12479 -17512 691 130 20
		// Scene 7: 12396 -17483 683 42 7
		// Patrenko death vignette
		// Scene 8: 13152 -12893 598 158 354
	// betrayal room full speed ambient effects: 395
	level._effect["fx_betrayal_dust_motes_amb"]					= loadfx("maps/fullahead/fx_betrayal_dust_motes_amb");	// 396
	level._effect["fx_betrayal_floor_fog"]							= loadfx("maps/fullahead/fx_betrayal_floor_fog");	// 396
	level._effect["fx_betrayal_fog_cold_detail"]				= loadfx("maps/fullahead/fx_betrayal_fog_cold_detail");	// 396
	level._effect["fx_betrayal_nova6_fill"]							= loadfx("maps/fullahead/fx_betrayal_nova6_fill");	// 397
	level._effect["fx_betrayal_nova6_release"]					= loadfx("maps/fullahead/fx_betrayal_nova6_release");	// 397
	level._effect["fx_vomit_glass"]											= loadfx("maps/fullahead/fx_vomit_glass");	// 398
	level._effect["fx_scaffold_impact"]									= loadfx("maps/wmd/fx_snow_door_fallen_puff");	// 410
	level._effect["fx_exp_ship_sink_runner"]						= loadfx("maps/fullahead/fx_exp_ship_sink_runner");	// 545
	level._effect["fx_rocket_xtreme_exp_metal"]					= loadfx("weapon/rocket/fx_rocket_xtreme_exp_metal");	// 545
	level._effect["fx_ship_sinking_splash_runner"]			= loadfx("maps/fullahead/fx_ship_sinking_splash_runner");	// 550
	// Destructible window exploders: 2001-2006
	
// Lights
	level._effect["fx_light_tinhat_cage_yellow"]				= loadfx("env/light/fx_light_tinhat_cage");
	level._effect["fx_light_godray_lrg"]								= loadfx("env/light/fx_light_godray_lrg");
	level._effect["fx_ray_sm_1sd"]											= loadfx("env/light/fx_ray_sm_1sd");
	level._effect["fx_ray_spread_md_1sd"]								= loadfx("env/light/fx_ray_spread_md_1sd");
	level._effect["fx_light_godray_md_cool"]						= loadfx("env/light/fx_light_godray_md_cool");
	level._effect["fx_light_godray_md_warm"]						= loadfx("env/light/fx_light_godray_md_warm");
	level._effect["fx_light_godray_sm_warm"]						= loadfx("env/light/fx_light_godray_sm_warm");
	level._effect["fx_ray_md_1sd_cool"]									= loadfx("env/light/fx_ray_md_1sd_cool");
	level._effect["fx_ray_md_1sd"]											= loadfx("env/light/fx_ray_md_1sd");
	level._effect["fx_fullahead_ray_wide_sm"]						= loadfx("maps/fullahead/fx_fullahead_ray_wide_sm");
	level._effect["fx_fullahead_ray_wide_sm_cool"]			= loadfx("maps/fullahead/fx_fullahead_ray_wide_sm_cool");
	level._effect["fx_light_dust_motes_xsm"]						= loadfx("env/light/fx_light_dust_motes_xsm");
	level._effect["fx_light_dust_motes_sm"]							= loadfx("env/light/fx_light_dust_motes_sm");

// Fires
	level._effect["fx_embers_falling_md"]								= loadfx("env/fire/fx_embers_falling_md");
	level._effect["fx_fire_column_creep_xsm"]						= loadfx("env/fire/fx_fire_column_creep_xsm");
	level._effect["fx_fire_column_creep_sm"]						= loadfx("env/fire/fx_fire_column_creep_sm");
	level._effect["fx_fire_ceiling_md"]									= loadfx("env/fire/fx_fire_ceiling_md");
	level._effect["fx_fire_sm_smolder"]									= loadfx("env/fire/fx_fire_sm_smolder");
	level._effect["fx_fire_md_smolder"]									= loadfx("env/fire/fx_fire_md_smolder");
	level._effect["fx_fire_line_xsm"]										= loadfx("env/fire/fx_fire_line_xsm");
	level._effect["fx_fire_line_sm"]										= loadfx("env/fire/fx_fire_line_sm");
	level._effect["fx_fire_line_md"]										= loadfx("env/fire/fx_fire_line_md");
	
	level._effect["fx_fuel_tank_fire_xsm"]							= loadfx("maps/fullahead/fx_debris_fire_sm_windy");
	level._effect["fx_wastebasket_fire"]								= loadfx("maps/fullahead/fx_wastebasket_fire");

// Smoke
	level._effect["fx_smk_smolder_rubble_md"]						= loadfX("env/smoke/fx_smk_smolder_rubble_md");
	level._effect["fx_smk_linger_lit"]									= loadfx("env/smoke/fx_smk_linger_lit");
	level._effect["fx_smk_fire_xlg_black"]							= loadfx("env/smoke/fx_smk_fire_xlg_black");
	level._effect["fx_smk_plume_xlg_blk"]								= loadfx("env/smoke/fx_smk_plume_xlg_blk");
	level._effect["fx_smoke_stack_distant_1"]						= loadfx("env/smoke/fx_smk_stack_dist");
	level._effect["fx_pipe_steam_md"]										= loadfx("env/smoke/fx_pipe_steam_md");
	level._effect["fx_smk_fire_md_black_fast"]					= loadfx("env/smoke/fx_smk_fire_md_black_fast");
	level._effect["fx_smk_plume_md_blk_wispy_fast"]			= loadfx("env/smoke/fx_smk_plume_md_blk_wispy_fast");

	level._effect["fx_exp_hue_window_glass"]						= loadfx("maps/hue_city/fx_exp_hue_window_glass");
	level._effect["fx_elec_burst_shower_sm_os_int"]			= loadfx("env/electrical/fx_elec_burst_shower_sm_os_int");

// Snow
	level._effect["fx_snow_gust_heavy_1200"]						= loadfx("env/weather/fx_snow_gust_heavy_1200");
	level._effect["fx_snow_gust_road"]									= loadfx("env/weather/fx_snow_gust_road");
	level._effect["fx_snow_gust_rooftop"]								= loadfx("env/weather/fx_snow_gust_rooftop");
	level._effect["fx_snow_gust_rooftop_sm"]						= loadfx("env/weather/fx_snow_gust_rooftop_sm");
	level._effect["fx_snow_blizzard_intense"]						= loadfx("env/weather/fx_snow_blizzard_intense");
	level._effect["fx_snow_windy_fast_door_os"]					= loadfx("env/weather/fx_snow_windy_fast_door_os");
	level._effect["fx_snow_windy_fast_lg_os"]						= loadfx("env/weather/fx_snow_windy_fast_lg_os");
	level._effect["fx_snow_windy_heavy_md"]							= loadfx("env/weather/fx_snow_windy_heavy_md");
	level._effect["fx_snow_windy_heavy_sm"]							= loadfx("env/weather/fx_snow_windy_heavy_sm");
	level._effect["fx_snow_windy_heavy_xsm"]						= loadfx("env/weather/fx_snow_windy_heavy_xsm");
	level._effect["fx_snow_gust_kickup1"]								= loadfx("env/weather/fx_snow_gust_kickup1");
	level._effect["fx_ambience_swirling1"]							= loadfx("maps/fullahead/fx_snow_room_swirling_amb_paper" );
	level._effect["fx_snow_room_swirling_amb"]					= loadfx("maps/fullahead/fx_snow_room_swirling_amb");
	level._effect["fx_snow_windy_fast_sm"]							= loadfx("env/weather/fx_snow_windy_fast_sm");
	level._effect["fx_snow_gust_door"]									= loadfx("env/weather/fx_snow_door_gust_lt");
	level._effect["fx_snow_window_gust_lg"]							= loadfx("env/weather/fx_snow_window_gust_lg");
	level._effect["fx_snow_falling_drift_os"]						= loadfx("maps/fullahead/fx_snow_falling_drift_os");
	level._effect["fx_ice_falling_xlrg_os"]							= loadfx("maps/fullahead/fx_ice_falling_xlrg_os");
	level._effect["fx_ice_falling_lrg"]									= loadfx("maps/fullahead/fx_ice_falling_lrg");
	level._effect["fx_ice_falling_med"]									= loadfx("maps/fullahead/fx_ice_falling_med");
	level._effect["fx_ice_falling_sm"]									= loadfx("maps/fullahead/fx_ice_falling_sm");
	level._effect["fx_fog_hall_cold_md"]								= loadfx("env/smoke/fx_fog_hall_cold_md");
	level._effect["fx_fog_cold_detail"]									= loadfx("env/smoke/fx_fog_cold_detail");
}

wind_initial_setting()
{
	SetSavedDvar( "wind_global_vector", "-172 28 0" );			// change "0 0 0" to your wind vector
	SetSavedDvar( "wind_global_low_altitude", 0);						// change 0 to your wind's lower bound
	SetSavedDvar( "wind_global_hi_altitude", 2775);					// change 10000 to your wind's upper bound
	SetSavedDvar( "wind_global_low_strength_percent", 0.5);	// change 0.5 to your desired wind strength percentage
}

init_building_explosion_states()
{
	level thread firebuilding1_explosion();
	level thread firebuilding2_explosion();
}

firebuilding1_explosion()
{
	building01_roof_intact = GetEnt("building01_roofintact", "targetname");
	building01_roof_intact Show();

	building01_roof_destroyed = GetEnt("building01_roofdestroyed", "targetname");
	building01_roof_destroyed Hide();

	level waittill( "firebuilding1_explode" );
	
	// play the createfx exploders
	exploder(100);
    building01_roof_destroyed PlaySound( "evt_building1_explo" );

	// swap out intact for destroyed roof
	building01_roof_intact = GetEnt("building01_roofintact", "targetname");
	building01_roof_intact Hide();

	building01_roof_destroyed = GetEnt("building01_roofdestroyed", "targetname");
	building01_roof_destroyed Show();
}

firebuilding2_explosion()
{	
	officer_roof_destroyed = GetEnt("officer_roof_destroyed", "targetname");
	officer_roof_intact = GetEnt("officer_roof", "targetname");
	officer_roof_intact Show();
	officer_roof_destroyed Hide();

	level waittill( "firebuilding2_explode" );

	// play the createfx exploders
	exploder(110); // initial mortar hit and related explosions and debris
	officer_roof_destroyed PlaySound( "evt_building2_explo" );

	// swap out intact for destroyed roof
	officer_roof_intact Hide();
	officer_roof_destroyed Show();
}

main()
{
	initModelAnims();
	precache_util_fx();
	precache_scripted_fx();
	precache_createfx_fx();

	footsteps();
	init_building_explosion_states();

	// calls the createfx server script (i.e., the list of ambient effects and their attributes)
	maps\createfx\fullahead_fx::main();
	maps\createart\fullahead_art::main();

	wind_initial_setting();
}

footsteps()
{
	animscripts\utility::setFootstepEffect( "snow", LoadFx( "bio/player/fx_footstep_snow"));
	animscripts\utility::setFootstepEffect( "water", LoadFx( "bio/player/fx_footstep_water"));
}
