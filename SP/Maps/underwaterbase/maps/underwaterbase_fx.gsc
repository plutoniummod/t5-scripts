#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#using_animtree("fxanim_props");

main()
{
	initModelAnims();
	precache_util_fx();
	precache_createfx_fx();
	precache_scripted_fx();

	init_dvars();
	init_exploders();
	init_flags();

	//footsteps();

	// calls the createfx server script (i.e., the list of ambient effects and their attributes)
	maps\createfx\underwaterbase_fx::main();
	maps\createart\underwaterbase_art::main();

	wind_initial_setting();
}

// Initialize DVars
init_dvars()
{

}


//
//	Exploder threads
init_exploders()
{
	// stop all exploders from ship
	stop_dive[0] = 100;
	stop_dive[1] = 101;
	stop_dive[2] = 102;
	stop_dive[3] = 103;
	stop_dive[4] = 104;
	stop_dive[5] = 105;
	stop_dive[6] = 71002;
	stop_dive[7] = 107;
	stop_dive[8] = 110;
	stop_dive[9] = 120;
	stop_dive[10] = 121;
	stop_dive[11] = 123;
	stop_dive[12] = 124;
	stop_dive[13] = 125;
	stop_dive[14] = 126;
	stop_dive[15] = 127;
	stop_dive[16] = 128;
	stop_dive[17] = 129;
	stop_dive[18] = 130;
	stop_dive[19] = 131;
	stop_dive[20] = 132;
	stop_dive[21] = 133;
	stop_dive[22] = 134;
	stop_dive[23] = 135;
	stop_dive[24] = 136;
	stop_dive[25] = 137;
	stop_dive[26] = 71001;
	stop_dive[27] = 71010;
	stop_dive[28] = 71011;
	stop_dive[29] = 71012;
	stop_dive[30] = 71013;
	stop_dive[31] = 71014;
	stop_dive[32] = 71015;
	stop_dive[33] = 71016;
	stop_dive[34] = 71017;
	stop_dive[35] = 71018;
	stop_dive[36] = 71019;
	stop_dive[37] = 71020;
	stop_dive[38] = 71021;
	stop_dive[39] = 71022;
	stop_dive[40] = 71023;
	stop_dive[41] = 71024;
	stop_dive[42] = 71025;
	stop_dive[43] = 71026;
	stop_dive[44] = 71027;
	stop_dive[45] = 71028;
	stop_dive[46] = 71029;

	level thread exploder_wait( "exp_divetobase",	401, stop_dive );		// Dive 

	level thread exploder_wait( "exp_enter_base",	501, 401 );	// Enter Base start

	level thread exploder_wait( "exp_torp1",		511 );	// 1st torpedo attack

// 	stop_chamber[0] = 501;
// 	stop_chamber[0] = 511;
	level thread exploder_wait( "exp_chamber1",		601 );	// 1st hallway after sub pen

	stop_flood[0] = 501;
	stop_flood[1] = 511;
	stop_flood[2] = 601;
	level thread exploder_wait( "exp_flood",		611, stop_flood);	// flood fx
	level thread exploder_wait( "exp_chamber2",		621 );				// next section

	level thread exploder_wait( "exp_ladder",		631 );	// ladder up

  	stop_ladder[0] = 611;
	level thread exploder_wait( "exp_chamber3",		701, stop_ladder );		// top of ladder

 	stop_chamber3_5[0] = 621;
 	stop_chamber3_5[1] = 631;
	level thread exploder_wait( "exp_chamber3_5",	711, stop_chamber3_5 );	// last hallway
	level thread exploder_wait( "exp_control",		801 );		// broadcast

 	stop_escape[0] = 701;
 	stop_escape[1] = 711;
	level thread exploder_wait( "exp_escape",		901, stop_escape );	// escape hall

	stop_surface[0] = 801;
	stop_surface[1] = 901;
	level thread exploder_wait( "exp_surface",		951,	stop_surface );	// surface
}


//
//
init_flags()
{
	flag_init( "wires_slack_start" );
}


//
exploder_wait( msg, exploder_num, stop_exploder_num )
{
	level waittill( msg );

	if ( IsDefined( stop_exploder_num ) )
	{
		if ( IsArray( stop_exploder_num ) )
		{
			for ( i=0; i<stop_exploder_num.size; i++ )
			{
				stop_exploder( stop_exploder_num[i] );
			}
		}
		else
		{
			stop_exploder( stop_exploder_num );
		}
		wait(1.0);
	}

	if ( IsDefined( exploder_num ) )
	{
		exploder( exploder_num );
	}
	wait_network_frame();
}


// fx used by util scripts
precache_util_fx()
{
}

// Scripted effects
precache_scripted_fx()
{
	level._effect[ "explosion_heli" ] 					= LoadFX("explosions/fx_exp_vehicle_gen");
	level._effect[ "rpg_trail" ]						= LoadFX("weapon/grenade/fx_trail_rpg_uwb");
	level._effect[ "smoketrail" ] 						= LoadFX("weapon/rocket/fx_LCI_rocket_geotrail");

	level._effect["huey_fire"]							= LoadFX("vehicle/vfire/fx_vsmoke_huey_trail_uwb");
	level._effect["aa_gun_impact"]						= LoadFX("maps/hue_city/fx_impact_hue_huey");
	level._effect["huey_explosion"] 					= LoadFX("vehicle/vexplosion/fx_vexp_truck_gaz66");
	//level._effect["turret_explosion"] 					= LoadFX("explosions/fx_large_vehicle_explosion");

	level._effect["huey_bandaid"]						= LoadFX("maps/underwaterbase/fx_dmg_huey_panel_bandaid");

	level._effect["player_explo"]						= LoadFX("vehicle/vexplosion/fx_vexplode_hind_aerial_sm");

	// divetobase
	level._effect["buoy_lights"]						= LoadFX("maps/underwaterbase/fx_uwb_buoy_lights");
	level._effect["bubbles"]							= LoadFX("bio/player/fx_player_underwater_bubbles_torso_loop");
	level._effect["landing_fx"] 						= LoadFX("bio/player/fx_player_underwater_sediment");

	// Dragovich fight
	level._effect["dragovich_hit"]						= LoadFX( "maps/underwaterbase/fx_uwb_blood_hit" );
	level._effect["dragovich_bubbles"]					= LoadFX( "maps/underwaterbase/fx_uwb_bubbles_mouth" );
	level._effect["dragovich_spit"]						= LoadFX( "maps/underwaterbase/fx_uwb_mouth_spit" );

	// sparks for FX anim wires
	level._effect["wire_spark"]							= LoadFX("env/electrical/fx_elec_burst_heavy_sm_os_int");

	// _swimming FX
	level._effect["underwater"] 						= LoadFX( "maps/underwaterbase/fx_uwb_particles_surface_fxr" );
	level._effect["deep"]	 							= LoadFX( "env/water/fx_water_particle_dp_spawner" );
	level._effect["drowning"] 							= LoadFX( "bio/player/fx_player_underwater_bubbles_drowning" );
	level._effect["exhale"] 							= LoadFX( "bio/player/fx_player_underwater_bubbles_exhale" );
	level._effect["hands_bubbles_left"] 				= LoadFX( "bio/player/fx_player_underwater_bubbles_hand_fxr" );
	level._effect["hands_bubbles_right"] 				= LoadFX( "bio/player/fx_player_underwater_bubbles_hand_fxr_right" );
	level._effect["hands_debris_left"] 					= LoadFX( "bio/player/fx_player_underwater_hand_emitter");
	level._effect["hands_debris_right"] 				= LoadFX( "bio/player/fx_player_underwater_hand_emitter_right");
	level._effect["sediment"] 							= LoadFX( "bio/player/fx_player_underwater_sediment_spawner");
	level._effect["wake"] 								= LoadFX( "bio/player/fx_player_water_swim_wake" );
	level._effect["ripple"] 							= LoadFX( "bio/player/fx_player_water_swim_ripple" );

	//f4 phantom fx
	level._effect["jet_exhaust"]	           			= LoadFX( "vehicle/exhaust/fx_exhaust_jet_afterburner" );
	level._effect["jet_contrail"]             			= LoadFX( "trail/fx_geotrail_jet_contrail" );

	level._effect["prop_main"] = LoadFX("vehicle/props/fx_hind_main_blade_full");
	level._effect["prop_tail"] = LoadFX("vehicle/props/fx_hind_small_blade_full");
	level._effect["prop_tail_smoke"] = LoadFX("vehicle/props/fx_hind_small_blade_damaged");
	level._effect["hip_dead"] = LoadFX("explosions/fx_exp_vehicle_gen");
	level._effect["hind_dead"] = LoadFX("vehicle/vexplosion/fx_vexplode_hind_aerial_sm");
	level._effect["prop_smoke"]	= LoadFX("vehicle/vfire/fx_vsmoke_hind_trail");
	level._effect["huey_rotor_main"] = LoadFX("vehicle/props/fx_huey_main_blade_full");
	level._effect["huey_rotor_tail"] = LoadFX("vehicle/props/fx_huey_small_blade_full");
	level._effect["chinook_main"] = LoadFX("vehicle/props/fx_seaknight_main_blade_full");
	level._effect["chinook_tail"] = LoadFX("vehicle/props/fx_seaknight_rear_blade_full");

	// Huey Damage FX
	level._effect["panel_dmg_sm"] = LoadFX("maps/underwaterbase/fx_dmg_huey_panel_sm");
	level._effect["panel_dmg_md"] = LoadFX("maps/underwaterbase/fx_dmg_huey_panel_md");
	level._effect["wire_fx_internal"] = LoadFX("maps/pow/fx_pow_dmg_spark_wire_cockpit");
	level._effect["wire_fx"] = LoadFX("maps/pow/fx_pow_spark_wire_cockpit_fxr");

	level._effect["fx_bubble_vent_xlarge"] = LoadFX("maps/underwaterbase/fx_uwb_bubble_vent_xlg");
	level._effect["fx_bubble_vent_small"] = LoadFX("maps/underwaterbase/fx_uwb_bubble_vent_sm");
	level._effect["diver_splash"] = LoadFX("bio/player/fx_player_water_splash");
}



// Ambient effects
precache_createfx_fx()
{
	// effects to eventually replace
	// level._effect["water_bubble_column"]							= LoadFX("env/water/fx_water_bubble_column");
	level._effect["fx_bubble_vent_large"]								= LoadFX("maps/underwaterbase/fx_uwb_bubble_vent_lg");
	level._effect["fx_light_glow_spot_uwater"]						= LoadFX("maps/sandbox_modules/module_4/fx_light_glow_spot_uwater");
	level._effect["fx_sea_particles_large"]							= LoadFX("maps/sandbox_modules/module_4/fx_sea_particles_large");

// Shared effects
	level._effect["fx_pipe_steam_md"]									= loadfx("env/smoke/fx_pipe_steam_md");
	level._effect["fx_pipe_steam_md_runner"]					= loadfx("env/smoke/fx_pipe_steam_md_runner");
	level._effect["fx_quinn_steam_blast_lg"]					= loadfx("maps/underwaterbase/fx_uwb_steam_blast_lg");
	level._effect["fx_steam_hallway_md"]							= loadfx("env/smoke/fx_steam_hallway_md");
	level._effect["fx_light_overhead"] 								= loadfx("env/light/fx_light_overhead_high");
	level._effect["fx_light_incandescent"]						= loadfx("maps/underwaterbase/fx_uwb_light_incandescent");
	level._effect["fx_light_glow_flourescent"]				= loadfx("maps/underwaterbase/fx_uwb_light_glow_flourescent");
	level._effect["fx_smk_linger_lit"]								= loadfx("env/smoke/fx_smk_linger_lit");

// Underwater effects
	level._effect["fx_elec_breaker_sparks_lg"]				= loadfx("maps/underwaterbase/fx_uwb_elec_breaker_sparks_lg");
	level._effect["fx_water_splash_detail_lg"]				= loadfx("maps/underwaterbase/fx_uwb_water_splash_detail_lg");
	// level._effect["fx_uwb_water_spill_sm_splash"]		= loadfx("maps/underwaterbase/fx_uwb_water_spill_sm_splash");
	// level._effect["fx_water_drips_line_100"]					= loadfx("maps/underwaterbase/fx_uwb_water_drips_line_100");
	level._effect["fx_water_drips_line_hvy_100"]			= loadfx("maps/underwaterbase/fx_uwb_water_drips_line_hvy_100");
	level._effect["fx_water_spill_sm"]								= loadfx("maps/underwaterbase/fx_uwb_water_spill_sm");
	level._effect["fx_water_sheet_line_md_100"]				= loadfx("maps/underwaterbase/fx_uwb_water_sheet_line_md_100");
	level._effect["fx_water_sheet_line_md_300"]				= loadfx("maps/underwaterbase/fx_uwb_water_sheet_line_md_300");
	level._effect["fx_water_sheeting_300"]						= loadfx("maps/underwaterbase/fx_uwb_water_sheeting_300");
	level._effect["fx_water_sheeting_100x300"]				= loadfx("maps/underwaterbase/fx_uwb_water_sheeting_100x300");
	level._effect["fx_water_fine_spray_sm"]						= loadfx("maps/underwaterbase/fx_uwb_water_fine_spray_sm");
	level._effect["fx_water_fine_spray_md"]						= loadfx("maps/underwaterbase/fx_uwb_water_fine_spray_md");
	// level._effect["fx_water_pipe_gush_lg"]						= loadfx("maps/underwaterbase/fx_uwb_water_pipe_gush_lg");
	// level._effect["fx_water_splash_gush_lg"]					= loadfx("maps/underwaterbase/fx_uwb_water_splash_gush_lg");
	level._effect["fx_water_spray_leak_sm"]						= loadfx("maps/underwaterbase/fx_uwb_water_spray_leak_sm");
	level._effect["fx_water_spray_leak_md"]						= loadfx("maps/underwaterbase/fx_uwb_water_spray_leak_md");
	// level._effect["fx_water_spray_leak_lg"]						= loadfx("maps/underwaterbase/fx_uwb_water_spray_leak_lg");
	level._effect["fx_water_pipe_spill_sm"]						= loadfx("maps/underwaterbase/fx_uwb_water_pipe_spill_sm");
	// level._effect["fx_water_pipe_spill_md"]						= loadfx("maps/underwaterbase/fx_uwb_water_pipe_spill_md");
	// level._effect["fx_water_pipe_spill_xlg"]					= loadfx("maps/underwaterbase/fx_uwb_water_pipe_spill_xlg");
	level._effect["fx_sea_caustics_lg"]								= loadfx("maps/underwaterbase/fx_uwb_sea_caustics_field");
	level._effect["fx_sea_caustics_xsm"]							= loadfx("maps/underwaterbase/fx_uwb_sea_caustics_field_xsm");
	// level._effect["fx_steam_bounce_1"]								= loadfx("maps/underwaterbase/fx_uwb_steam_bounce_1");
	level._effect["fx_light_glow_flood_sm"]						= loadfx("maps/underwaterbase/fx_uwb_light_glow_flood_sm");
	level._effect["fx_light_glow_flood_lg"]						= loadfx("maps/underwaterbase/fx_uwb_light_blue_flood_lg");
	level._effect["fx_quinn_light_blue_sm"]						= loadfx("maps/underwaterbase/fx_uwb_light_blue_flood_sm");
	level._effect["fx_quinn_light_red_sm"]						= loadfx("maps/underwaterbase/fx_uwb_light_red_sm");
	level._effect["fx_quinn_smoke_sm"]								= loadfx("maps/underwaterbase/fx_uwb_smoke_sm");
	// level._effect["fx_quinn_steam_exhaust_lg"]				= loadfx("maps/underwaterbase/fx_uwb_steam_exhaust_lg");
	// level._effect["fx_quinn_steam_exhaust_sm"]				= loadfx("maps/underwaterbase/fx_uwb_steam_exhaust_sm");
	level._effect["fx_umbilical_light_red"]						  = loadfX("maps/underwaterbase/fx_umbilical_light_red_3_grp2");
	// level._effect["fx_buoy_light_red"]								= loadfx("maps/underwaterbase/fx_umbilical_light_red_3");
	level._effect["fx_flood_room_water_gush"]						= loadfx("maps/underwaterbase/fx_uwb_water_gush_door");	
	level._effect["fx_uwb_explosion_console"]						= loadfx("maps/underwaterbase/fx_uwb_explosion_console");	
	level._effect["fx_uwb_water_plume_splash"]					= loadfx("maps/underwaterbase/fx_uwb_water_plume_splash");	
	level._effect["fx_uwb_water_plume_splash_sm"]				= loadfx("maps/underwaterbase/fx_uwb_water_plume_splash_sm");	
	level._effect["fx_uwb_water_plume_splash_xsm"]			= loadfx("maps/underwaterbase/fx_uwb_water_plume_splash_xsm");			
	level._effect["fx_uwb_water_explosion"]							= loadfx("maps/underwaterbase/fx_explosion_underwater_1_xlg");
	level._effect["fx_quinn_steam_blast_lg_rise"]				= loadfx("maps/underwaterbase/fx_uwb_steam_blast_lg_rise");							
	
	

// Abovewater effects
	
	// Exploders
		// Smokestack smoke:	100
		// First Huey strafe damage, fore:	101
		// First Huey strafe damage, everything else:	102
		// Player Huey crash: 103
		// Damage effects during deck engagement:	104
		
		// Bullethole godrays:	105
		level._effect["fx_ship_bulletholes"]							= loadfx("maps/underwaterbase/fx_ship_bulletholes");
		
		// Smokestack explosion:	71002
		level._effect["fx_ship_dest_smokestack"]					= loadfx("maps/underwaterbase/fx_ship_dest_smokestack");
		
		// Radar array explosion:	71001
		level._effect["fx_ship_dest_fore_radar"]					= loadfx("maps/underwaterbase/fx_ship_dest_fore_radar");
		
		// Ship interior ambient effects:	110
		
		level._effect["fx_ship_exp_hull_hole"]						= loadfx("maps/underwaterbase/fx_ship_exp_hull_hole");
		level._effect["fx_ship_exp_hull_hole_long"]				= loadfx("maps/underwaterbase/fx_ship_exp_hull_hole_long");
		
		// Crane base sparks:	120, level_notify: crane_fall_start, notetrack: n/a
		level._effect["fx_ship_dest_crane_base"]					= loadfx("maps/underwaterbase/fx_ship_dest_crane_base");
		
		// Crane rail smash: 121, notetrack: crane_hits_deck
		level._effect["fx_ship_dest_crane_rail"]					= loadfx("maps/underwaterbase/fx_ship_dest_crane_rail");
		
		// Aft wire tower impact: 123, level_notify: aft_wire_tower_start, notetrack: tower_hits_deck
		
		// Aft radio tower snap: 124, level_notify: aft_radio_tower_start, notetrack: n/a
		
		// Aft radio tower top impact: 125, notetrack: tower_impact01
		level._effect["fx_ship_dest_aft_radio_tower_1"]		= loadfx("maps/underwaterbase/fx_ship_dest_aft_radio_tower_1");
		
		// Aft radio tower body impact: 126, notetrack: tower_impact02
		level._effect["fx_ship_dest_aft_radio_tower_2"]		= loadfx("maps/underwaterbase/fx_ship_dest_aft_radio_tower_2");
		
		// Center mast01 snaps: 127, level_notify: dbl_mast_start, notetrack: n/a
		level._effect["fx_ship_dest_mast_snap"]						= loadfx("maps/underwaterbase/fx_ship_dest_mast_snap");
		
		// Center masts platform impact: 128, notetrack: platform_hits_deck
		level._effect["fx_ship_dest_mast_platform"]				= loadfx("maps/underwaterbase/fx_ship_dest_mast_platform");
		
		// Center mast01 impact: 129, notetrack: mast01_hits_deck
		level._effect["fx_ship_dest_dbl_mast01"]					= loadfx("maps/underwaterbase/fx_ship_dest_dbl_mast01");
		
		// Center mast02 snaps: 130, notetrack: n/a
		// Center mast02 impact: 131, notetrack: mast02_hits_deck
		
		// Forward radio tower snap: 132, level_notify: fwd_radio_tower_start, notetrack: n/a
		// Forward radio tower impact: 133, notetrack: tower_impact01
		
		// Forward wire tower B snap: 134, level_notify: fwd_wire_tower_b_start, notetrack: n/a
		// Forward wire tower B impact: 135, notetrack: fwd_wire_tower_hits_roof
		
		// Forward crow's nest snap: 136, level_notify: crows_nest_start
		// Forward crow's nest impact: 137, notetrack: NEEDS ONE!
		
		// Umbilical room: umbilical frame lights: 220
		level._effect["fx_umbilical_frame_light"]				= loadfx("maps/underwaterbase/fx_umbilical_frame_light");
		level._effect["fx_light_floodlight_bright"]			= loadfx("env/light/fx_light_floodlight_bright");
		level._effect["fx_umbilical_water_churn"]				= loadfx("maps/underwaterbase/fx_umbilical_water_churn");	// 221
		level._effect["fx_steam_ceiling_lg"]						= loadfx("env/smoke/fx_steam_ceiling_lg");

	level._effect["fx_ship_pipe_gush_sm"]							= loadfx("maps/underwaterbase/fx_ship_pipe_gush_sm");
	level._effect["fx_ship_pipe_gush_splash"]					= loadfx("maps/underwaterbase/fx_ship_pipe_gush_splash");

	// Smoke
	level._effect["fx_smk_stack_dist"]								= loadfx("env/smoke/fx_smk_stack_dist");
	level._effect["fx_ship_fire_smoke_column_xlg"]		= loadfx("maps/underwaterbase/fx_ship_fire_smoke_column_xlg");
	level._effect["fx_smk_fire_xlg_black"]						= loadfx("maps/underwaterbase/fx_ship_smk_fire_xlg_black");
	level._effect["fx_smk_fire_lg_black"]							= loadfx("maps/underwaterbase/fx_ship_smk_fire_lg_black");
	level._effect["fx_smk_smolder_rubble_md"]					= loadfX("maps/underwaterbase/fx_ship_smk_smolder");
	level._effect["fx_smk_smolder_sm"]								= loadfx("env/smoke/fx_smk_smolder_sm");
	// level._effect["fx_fumes_vent_sm"]									= loadfx("env/smoke/fx_fumes_vent_sm");

	// Fires
	// level._effect["fx_embers_falling_md"]							= loadfx("env/fire/fx_embers_falling_md");
	level._effect["fx_ship_fire_destruction"]					= loadfx("maps/underwaterbase/fx_ship_fire_destruction");
	level._effect["fx_fire_md_smolder"]								= loadfx("env/fire/fx_fire_md_smolder");
	level._effect["fx_ship_fire_smolder_area"]				= loadfx("maps/underwaterbase/fx_ship_fire_smolder_area");
	level._effect["fx_ship_fire_leak"]								= loadfx("maps/underwaterbase/fx_ship_fire_leak");
	level._effect["fx_fire_line_xsm"]									= loadfx("maps/underwaterbase/fx_ship_fire_line_xsm");
	level._effect["fx_fire_line_sm"]									= loadfx("maps/underwaterbase/fx_ship_fire_line_sm");
	level._effect["fx_fire_line_md"]									= loadfx("maps/underwaterbase/fx_ship_fire_line_md");
	level._effect["fx_fire_line_lg"]									= loadfx("maps/underwaterbase/fx_ship_fire_line_lg");

}

// FXanim Props
initModelAnims()
{

	level.scr_anim["fxanim_props"]["a_windsock"] = %fxanim_gp_windsock_anim;
	level.scr_anim["fxanim_props"]["a_tarp_crate_stack"] = %fxanim_gp_tarp_crate_stack_anim;
	level.scr_anim["fxanim_props"]["a_fish02"] = %fxanim_creek_fish2_anim;
	level.scr_anim["fxanim_props"]["a_fish03"] = %fxanim_creek_fish3_anim;
	level.scr_anim["fxanim_props"]["a_fish04"] = %fxanim_creek_fish1_anim;
	level.scr_anim["fxanim_props"]["a_fish05"] = %fxanim_creek_fish2_anim;
	level.scr_anim["fxanim_props"]["a_crows_nest"] = %fxanim_uwb_fwd_crows_nest_anim;
	level.scr_anim["fxanim_props"]["a_aft_crane_idle"] = %fxanim_uwb_aft_crane_idle_anim;
	level.scr_anim["fxanim_props"]["a_aft_crane_fall"] = %fxanim_uwb_aft_crane_fall_anim;
	level.scr_anim["fxanim_props"]["a_aft_crane_fall_idle"] = %fxanim_uwb_aft_crane_fall_idle_anim;
	level.scr_anim["fxanim_props"]["a_aft_railing"] = %fxanim_uwb_aft_railing_anim;
	level.scr_anim["fxanim_props"]["a_dbl_mast01"] = %fxanim_uwb_dbl_mast01_anim;
	level.scr_anim["fxanim_props"]["a_dbl_mast02"] = %fxanim_uwb_dbl_mast02_anim;
	level.scr_anim["fxanim_props"]["a_dbl_mast_platform"] = %fxanim_uwb_dbl_mast_platform_anim;
	level.scr_anim["fxanim_props"]["a_aft_radio_tower"] = %fxanim_uwb_aft_radio_tower_anim;
	level.scr_anim["fxanim_props"]["a_aft_radio_tower_flag"] = %fxanim_uwb_aft_radio_flag_rail_anim;
	level.scr_anim["fxanim_props"]["a_fwd_radio_tower"] = %fxanim_uwb_fwd_radio_tower_anim;
	level.scr_anim["fxanim_props"]["a_fwd_radio_mast"] = %fxanim_uwb_fwd_radio_mast_anim;
	level.scr_anim["fxanim_props"]["a_aft_wire_tower"] = %fxanim_uwb_aft_wire_tower_anim;
	level.scr_anim["fxanim_props"]["a_fwd_wire_tower_b"] = %fxanim_uwb_fwd_wire_tower_b_anim;
	level.scr_anim["fxanim_props"]["a_shiprope"][0] = %fxanim_uwb_shiprope_sway_anim;
	level.scr_anim["fxanim_props"]["a_door_burst"] = %fxanim_uwb_door_burst_anim;
	level.scr_anim["fxanim_props"]["a_sub_drop"] = %fxanim_uwb_sub_drop_anim;	
	level.scr_anim["fxanim_props"]["a_hoist_drop01"] = %fxanim_uwb_sub_hoist_drop01_anim;	
	level.scr_anim["fxanim_props"]["a_hoist_drop02"] = %fxanim_uwb_sub_hoist_drop02_anim;		
	level.scr_anim["fxanim_props"]["a_hoist_idle"] = %fxanim_uwb_sub_hoist_idle_anim;	
	level.scr_anim["fxanim_props"]["a_hoist_rise01"] = %fxanim_uwb_sub_hoist_rise01_anim;	
	level.scr_anim["fxanim_props"]["a_hoist_rise02"] = %fxanim_uwb_sub_hoist_rise02_anim;	
	level.scr_anim["fxanim_props"]["a_sub_rise"] = %fxanim_uwb_sub_rise_anim;
	level.scr_anim["fxanim_props"]["a_huey_int_idle"] = %fxanim_gp_huey_int_idle_anim;
	level.scr_anim["fxanim_props"]["a_huey_int_break"] = %fxanim_gp_huey_int_dmg_break_anim;
	level.scr_anim["fxanim_props"]["a_huey_int_dmg"] = %fxanim_gp_huey_int_dmg_idle_anim;
	level.scr_anim["fxanim_props"]["a_huey_int_necklace"] = %fxanim_gp_huey_uwb_necklace_idle_anim;
	level.scr_anim["fxanim_props"]["a_amb_wires_loop"] = %fxanim_uwb_umbilical_wires_amb_loop_anim;
	level.scr_anim["fxanim_props"]["a_taught_wires_loop"] = %fxanim_uwb_umbilical_wires_taught_loop_anim;
	level.scr_anim["fxanim_props"]["a_taught_wires_slack"] = %fxanim_uwb_umbilical_wires_taught_slack_anim;
	level.scr_anim["fxanim_props"]["a_taught_wires_slack_loop"] = %fxanim_uwb_umbilical_wires_taught_slack_loop_anim;
	level.scr_anim["fxanim_props"]["a_umbilical_wires_pistons_loop"] = %fxanim_uwb_umbilical_wires_pistons_loop_anim;
	level.scr_anim["fxanim_props"]["a_umbilical_wires_pistons_stop"] = %fxanim_uwb_umbilical_wires_pistons_stop_anim;
	level.scr_anim["fxanim_props"]["a_umbilical_wires_spool_loop"] = %fxanim_uwb_umbilical_wires_spool_loop_anim;
	level.scr_anim["fxanim_props"]["a_umbilical_wires_spool_stop"] = %fxanim_uwb_umbilical_wires_spool_stop_anim;
	level.scr_anim["fxanim_props"]["a_moon_pool_wires"] = %fxanim_uwb_moon_pool_wires_anim;
	level.scr_anim["fxanim_props"]["a_chain02"] = %fxanim_gp_chain02_anim;
	level.scr_anim["fxanim_props"]["a_chain03"] = %fxanim_gp_chain03_anim;
	level.scr_anim["fxanim_props"]["a_wire_sway_01"] = %fxanim_gp_wire_sway_01_slow_anim;
	level.scr_anim["fxanim_props"]["a_wire_sway_04"] = %fxanim_gp_wire_sway_04_slow_anim;
	level.scr_anim["fxanim_props"]["a_uwb_panel"] = %fxanim_uwb_panel_anim;	
	level.scr_anim["fxanim_props"]["a_preserver"] = %fxanim_uwb_preserver_anim;
	level.scr_anim["fxanim_props"]["a_uwb_ropes"] = %fxanim_uwb_ropes_anim;
	level.scr_anim["fxanim_props"]["a_hallway1"] = %fxanim_uwb_hallway1_anim;
	level.scr_anim["fxanim_props"]["a_hallway2"] = %fxanim_uwb_hallway2_anim;
	level.scr_anim["fxanim_props"]["a_broadcast_pipe01_a"] = %fxanim_uwb_broadcast_pipe01_a_anim;
	level.scr_anim["fxanim_props"]["a_broadcast_pipe01_b"] = %fxanim_uwb_broadcast_pipe01_b_anim;
	level.scr_anim["fxanim_props"]["a_broadcast_pipe02_a"] = %fxanim_uwb_broadcast_pipe02_a_anim;
	level.scr_anim["fxanim_props"]["a_broadcast_pipe02_b"] = %fxanim_uwb_broadcast_pipe02_b_anim;
	level.scr_anim["fxanim_props"]["a_broadcast_wires"] = %fxanim_uwb_broadcast_wires_anim;
	level.scr_anim["fxanim_props"]["a_wirespark_long"] = %fxanim_gp_wirespark_long_anim;
	level.scr_anim["fxanim_props"]["a_wirespark_med"] = %fxanim_gp_wirespark_med_anim;
	level.scr_anim["fxanim_props"]["a_wires_multi"] = %fxanim_escape_int_room_wires_multi_anim;
	
	level thread addNotetrack_customFunction( "fxanim_props", "audio_lift_start", ::hoist_rise_audio_start, "a_hoist_rise01" );
	level thread addNotetrack_customFunction( "fxanim_props", "audio_lift_end", ::hoist_rise_audio_end, "a_hoist_rise01" );
	level thread addNotetrack_customFunction( "fxanim_props", "audio_lift_start", ::hoist_rise_audio_start, "a_hoist_rise02" );
	level thread addNotetrack_customFunction( "fxanim_props", "audio_lift_end", ::hoist_rise_audio_end, "a_hoist_rise02" );
	level thread addNotetrack_customFunction( "fxanim_props", "audio_drop", ::hoist_drop_audio, "a_hoist_drop01" );
	level thread addNotetrack_customFunction( "fxanim_props", "audio_drop", ::hoist_drop_audio, "a_hoist_drop02" );
	
	addNotetrack_FXOnTag( "fxanim_props", "a_wirespark_long", "long_spark_wire", "wire_spark", "long_spark_06_jnt");
	addNotetrack_FXOnTag( "fxanim_props", "a_wirespark_med", "med_spark_wire", "wire_spark", "med_spark_06_jnt");

	ent1 = getent( "fxanim_uwb_fwd_crows_nest_mod", "targetname" );
	ent2 = getent( "aft_crane01", "targetname" );
	ent3 = getent( "aft_crane02", "targetname" );
	ent4 = getent( "aft_railing", "targetname" );
	ent5 = getent( "dbl_mast01", "targetname" );
	ent6 = getent( "dbl_mast02", "targetname" );
	ent7 = getent( "dbl_mast_platform", "targetname" );
	ent8 = getent( "fxanim_uwb_aft_radio_tower_mod", "targetname" );	
	ent9 = getent( "fxanim_uwb_aft_radio_flag_rail_mod", "targetname" );	
	ent10 = getent( "fxanim_uwb_fwd_radio_tower_mod", "targetname" );
	ent11 = getent( "fxanim_uwb_fwd_radio_mast_mod", "targetname" );
	ent12 = getent( "aft_wire_tower", "targetname" );
	ent13 = getent( "fwd_wire_tower_b", "targetname" );
	ent14 = getent( "door_burst", "targetname" );
	ent15 = getent( "fxanim_uwb_sub_drop_anim", "targetname" );
	ent16 = getent( "fxanim_uwb_sub_hoist_drop01_anim", "targetname" );
	ent17 = getent( "fxanim_uwb_sub_hoist_drop02_anim", "targetname" );
	ent18 = getent( "fxanim_uwb_sub_hoist_rise01_anim", "targetname" );
	ent19 = getent( "fxanim_uwb_sub_hoist_rise02_anim", "targetname" );
	ent20 = getent( "fxanim_uwb_sub_rise_anim", "targetname" );
	ent21 = getent( "fxanim_gp_huey_int_dmg_mod", "targetname" );
	ent22 = getent( "fxanim_gp_huey_uwb_necklace_mod", "targetname" );
	ent23 = getent( "umbilical_wires_ambient", "targetname" );
	ent24 = getent( "umbilical_wires_taught", "targetname" );
	ent25 = getent( "fxanim_uwb_metal_grate_mod", "targetname" );
	ent26 = getent( "fxanim_uwb_moon_pool_wires_mod", "targetname" );
	ent27 = getent( "fxanim_gp_wire_sway_01_mod", "targetname" );
	ent28 = getent( "fxanim_gp_wire_sway_04_mod", "targetname" );
	
	ent33 = getent( "fxanim_uwb_hallway1_mod", "targetname" );
	ent34 = getent( "fxanim_uwb_hallway2_mod", "targetname" );
	ent35 = getent( "broadcast_wires", "targetname" );
	
	enta_windsock = getentarray( "fxanim_gp_windsock_mod", "targetname" );
	enta_tarp_crate_stack = getentarray( "fxanim_gp_tarp_crate_stack_mod", "targetname" );
	enta_fish02 = getentarray( "fish02", "targetname" );
	enta_fish03 = getentarray( "fish03", "targetname" );
	enta_fish04 = getentarray( "fish04", "targetname" );
	enta_fish05 = getentarray( "fish05", "targetname" );
	enta_shiprope = getentarray( "fxanim_uwb_shiprope_sway_mod", "targetname" );
	enta_wires_spool = getentarray( "umbilical_wires_spool", "targetname" );
	enta_wires_pistons = getentarray( "umbilical_wires_piston", "targetname" );
	enta_chain02 = getentarray( "fxanim_gp_chain02_mod", "targetname" );
	enta_chain03 = getentarray( "fxanim_gp_chain03_mod", "targetname" );
	enta_broadcast_pipe01_a = getentarray( "broadcast_pipe01_a", "targetname" );
	enta_broadcast_pipe01_b = getentarray( "broadcast_pipe01_b", "targetname" );
	enta_broadcast_pipe02_a = getentarray( "broadcast_pipe02_a", "targetname" );
	enta_broadcast_pipe02_b = getentarray( "broadcast_pipe02_b", "targetname" );
	enta_wirespark_long = getentarray( "fxanim_gp_wirespark_long_mod", "targetname" );
	enta_wirespark_med = getentarray( "fxanim_gp_wirespark_med_mod", "targetname" );
	enta_wires_multi = getentarray( "wires_multi", "targetname" );
	enta_deck_panel = getentarray( "fxanim_uwb_panel_mod", "targetname" );
	enta_preserver = getentarray( "fxanim_uwb_preserver_mod", "targetname" );
	enta_deck_ropes_01 = getentarray( "fxanim_uwb_ropes_01", "targetname" );


	for(i=0; i<enta_windsock.size; i++)
	{
 		enta_windsock[i] thread windsock(1,5);
 		println("************* FX: windsock *************");
	}

	for(i=0; i<enta_tarp_crate_stack.size; i++)
	{
 		enta_tarp_crate_stack[i] thread tarp_crate_stack(1,5);
 		println("************* FX: tarp_crate_stack *************");
	}

	for(i=0; i<enta_fish02.size; i++)
	{
 		enta_fish02[i] thread fish02(1,2.5);
 		println("************* FX: fish02 *************");
	}

	for(i=0; i<enta_fish03.size; i++)
	{
 		enta_fish03[i] thread fish03(1,2.5);
 		println("************* FX: fish01 *************");
	}

	for(i=0; i<enta_fish04.size; i++)
	{
 		enta_fish04[i] thread fish04(1,2.5);
 		println("************* FX: fish04 *************");
	}

	for(i=0; i<enta_fish05.size; i++)
	{
 		enta_fish05[i] thread fish05(1,2.5);
 		println("************* FX: fish05 *************");
	}
	
	for(i=0; i<enta_wires_spool.size; i++)
	{
 		enta_wires_spool[i] thread wires_spool(.1,.2);
 		println("************* FX: wires_spool *************");
	}
	
	for(i=0; i<enta_wires_pistons.size; i++)
	{
 		enta_wires_pistons[i] thread wires_pistons(.1,.2);
 		println("************* FX: wires_pistons *************");
	}
	
	if (IsDefined(ent1)) 
	{
		ent1 thread crows_nest();
		println("************* FX: crows_nest *************");
	}	
	
	if (IsDefined(ent2)) 
	{
		ent2 thread aft_crane01();
		println("************* FX: aft_crane01 *************");
	}
	
	if (IsDefined(ent3)) 
	{
		ent3 thread aft_crane02();
		println("************* FX: aft_crane02 *************");
	}
	
	if (IsDefined(ent4)) 
	{
		ent4 thread aft_railing();
		println("************* FX: aft_railing *************");
	}
	
	if (IsDefined(ent5)) 
	{
		ent5 thread dbl_mast01();
		println("************* FX: dbl_mast02 *************");
	}
	
	if (IsDefined(ent6)) 
	{
		ent6 thread dbl_mast02();
		println("************* FX: dbl_mast02 *************");
	}
	
	if (IsDefined(ent7)) 
	{
		ent7 thread dbl_mast_platform();
		println("************* FX: dbl_mast_platform *************");
	}
	
	if (IsDefined(ent8)) 
	{
		ent8 thread aft_radio_tower();
		println("************* FX: aft_radio_tower *************");
	}
	
	if (IsDefined(ent9)) 
	{
		ent9 thread aft_radio_tower_flag();
		println("************* FX: aft_radio_tower_flag *************");
	}	
	
	if (IsDefined(ent10)) 
	{
		ent10 thread fwd_radio_tower();
		println("************* FX: fwd_radio_tower *************");
	}	
	
	if (IsDefined(ent11)) 
	{
		ent11 thread fwd_radio_mast();
		println("************* FX: fwd_radio_mast *************");
	}
	
	if (IsDefined(ent12)) 
	{
		ent12 thread aft_wire_tower();
		println("************* FX: aft_wire_tower *************");
	}
	
	if (IsDefined(ent13)) 
	{
		ent13 thread fwd_wire_tower_b();
		println("************* FX: fwd_wire_tower_b *************");
	}
	
	if (IsDefined(ent14)) 
	{
		ent14 thread door_burst();
		println("************* FX: door_burst *************");
	}
	
	if (IsDefined(ent15)) 
	{
		ent15 thread sub_drop();
		println("************* FX: sub_drop *************");
	}
	
	if (IsDefined(ent16)) 
	{
		ent16 thread hoist_drop01();
		println("************* FX: hoist_drop01 *************");
	}
	
	if (IsDefined(ent17)) 
	{
		ent17 thread hoist_drop02();
		println("************* FX: hoist_drop02 *************");
	}
	
	if (IsDefined(ent18)) 
	{
		ent18 thread hoist_rise01();
		println("************* FX: hoist_rise01 *************");
	}				
	
	if (IsDefined(ent19)) 
	{
		ent19 thread hoist_rise02();
		println("************* FX: hoist_rise02 *************");
	}	
	
	if (IsDefined(ent20)) 
	{
		ent20 thread sub_rise();
		println("************* FX: sub_rise *************");
	}	
	
	//if (IsDefined(ent21)) 
	//{
	//	ent21 thread huey_int();
	//	println("************* FX: huey_int *************");
	//}	
	//
	//if (IsDefined(ent22)) 
	//{
	//	ent22 thread huey_int_necklace();
	//	println("************* FX: huey_int_necklace *************");
	//}		
	
	if (IsDefined(ent23)) 
	{
		ent23 thread umbilical_wires_ambient();
		println("************* FX: umbilical_wires_ambient *************");
	}	
	
	if (IsDefined(ent24)) 
	{
		ent24 thread umbilical_wires_taught();
		println("************* FX: umbilical_wires_taught *************");
	}
		
	if (IsDefined(ent25)) 
	{
		ent25 thread metal_grate();
		println("************* FX: metal_grate *************");
	}
	
	if (IsDefined(ent26)) 
	{
		ent26 thread moon_pool_wires();
		println("************* FX: moon_pool_wires *************");
	}
	
	if (IsDefined(ent27)) 
	{
		ent27 thread wire_sway_01();
		println("************* FX: wire_sway_01 *************");
	}
	
	if (IsDefined(ent28)) 
	{
		ent28 thread wire_sway_04();
		println("************* FX: wire_sway_04 *************");
	}
	
		
	if (IsDefined(ent33)) 
	{
		ent33 thread hallway1();
		println("************* FX: hallway1 *************");
	}
	
	if (IsDefined(ent34)) 
	{
		ent34 thread hallway2();
		println("************* FX: hallway2 *************");
	}		
				
	for(i=0; i<enta_shiprope.size; i++)
	{
 		enta_shiprope[i] thread shiprope(1,2.5);
 		println("************* FX: shiprope *************");
	}	
	
	for(i=0; i<enta_chain02.size; i++)
	{
 		enta_chain02[i] thread chain02(.1,.5);
 		println("************* FX: chain02 *************");
	}
	
	for(i=0; i<enta_chain03.size; i++)
	{
 		enta_chain03[i] thread chain03(.1,.5);
 		println("************* FX: chain03 *************");
	}
	
	for(i=0; i<enta_broadcast_pipe01_a.size; i++)
	{
 		enta_broadcast_pipe01_a[i] thread broadcast_pipe01_a(1,2);
 		println("************* FX: broadcast_pipe01_a *************");
	}
	
	for(i=0; i<enta_broadcast_pipe01_b.size; i++)
	{
 		enta_broadcast_pipe01_b[i] thread broadcast_pipe01_b(.1,1);
 		println("************* FX: broadcast_pipe01_b *************");
	}
	
	for(i=0; i<enta_broadcast_pipe02_a.size; i++)
	{
 		enta_broadcast_pipe02_a[i] thread broadcast_pipe02_a(.1,1);
 		println("************* FX: broadcast_pipe02_a *************");
	}
	
	for(i=0; i<enta_broadcast_pipe02_b.size; i++)
	{
 		enta_broadcast_pipe02_b[i] thread broadcast_pipe02_b(.1,1);
 		println("************* FX: broadcast_pipe02_b *************");
	}
	
	if (IsDefined(ent35)) 
	{
		ent35 thread broadcast_wires();
		println("************* FX: broadcast_wires *************");
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
	
	for(i=0; i<enta_wires_multi.size; i++)
	{
 		enta_wires_multi[i] thread wires_multi(1,2.5);
 		println("************* FX: wires_multi *************");
	}
	
	for(i=0; i<enta_deck_panel.size; i++)
	{
 		enta_deck_panel[i] thread deck_panel(.1,.5);
 		println("************* FX: deck_panel *************");
	}

	for(i=0; i<enta_preserver.size; i++)
	{
 		enta_preserver[i] thread preserver(.1,.5);
 		println("************* FX: preserver *************");
	}	
	
	for(i=0; i<enta_deck_ropes_01.size; i++)
	{
 		enta_deck_ropes_01[i] thread deck_ropes_01(.1,.5);
 		println("************* FX: deck_ropes_01 *************");
	}	
}

windsock(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_windsock", "fxanim_props");
	flag_wait( "deck_cleanup" );
	self delete();
}

tarp_crate_stack(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_tarp_crate_stack", "fxanim_props");
	flag_wait( "deck_cleanup" );
	self delete();
}

fish02(delay_min,delay_max)
{
	flag_wait( "numbers_scene_start" );

	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_fish02", "fxanim_props");
	flag_wait( "dive_cleanup" );
	self delete();
}

fish03(delay_min,delay_max)
{
	flag_wait( "numbers_scene_start" );

	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_fish03", "fxanim_props");
	flag_wait( "dive_cleanup" );
	self delete();
}

fish04(delay_min,delay_max)
{
	flag_wait( "numbers_scene_start" );

	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_fish03", "fxanim_props");
	flag_wait( "dive_cleanup" );
	self delete();
}

fish05(delay_min,delay_max)
{
	flag_wait( "numbers_scene_start" );
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_fish02", "fxanim_props");
	flag_wait( "dive_cleanup" );
	self delete();
}

crows_nest()
{
	level endon( "death" );

	level waittill("crows_nest_start");
	self UseAnimTree(#animtree);
	addNotetrack_exploder( "fxanim_props", "tower_snap", 136, "a_crows_nest" );
	addNotetrack_exploder( "fxanim_props", "tower_impact", 137, "a_crows_nest" );
	anim_single(self, "a_crows_nest", "fxanim_props");
	flag_wait( "deck_cleanup" );
	self delete();
}

aft_crane01()
{
	level endon( "death" );

	wait(0.1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_aft_crane_idle", "fxanim_props");
	level waittill("crane_fall_start");
	exploder(120);
	addNotetrack_exploder( "fxanim_props", "crane_hits_deck", 121, "a_aft_crane_fall" );
	anim_single(self, "a_aft_crane_fall", "fxanim_props");
	anim_single(self, "a_aft_crane_fall_idle", "fxanim_props");
	flag_wait( "deck_cleanup" );

	self delete();
}

aft_crane02()
{
	wait(0.7);
	self UseAnimTree(#animtree);
	anim_single(self, "a_aft_crane_idle", "fxanim_props");
	flag_wait( "deck_cleanup" );

	self delete();
}

aft_railing()
{
	level endon( "death" );

	level waittill("crane_fall_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_aft_railing", "fxanim_props");
	flag_wait( "deck_cleanup" );

	self delete();
}

dbl_mast01()
{
	level endon( "death" );

	level waittill("dbl_mast_start");
	self UseAnimTree(#animtree);
	exploder(127);
	addNotetrack_exploder( "fxanim_props", "mast01_hits_deck", 129, "a_dbl_mast01" );
	thread anim_single(self, "a_dbl_mast01", "fxanim_props");
	level waittill("deck_fxanim_start");
	self SetForceNoCull();
	flag_wait( "deck_cleanup" );
	self delete();
}

dbl_mast02()
{
	level waittill("dbl_mast_start");
	self UseAnimTree(#animtree);
	exploder(130);
	addNotetrack_exploder( "fxanim_props", "mast02_hits_deck", 131, "a_dbl_mast02" );
	thread anim_single(self, "a_dbl_mast02", "fxanim_props");
	level waittill("deck_fxanim_start");
	self SetForceNoCull();
	flag_wait( "deck_cleanup" );
	self delete();
}

dbl_mast_platform()
{
	level waittill("dbl_mast_start");
	self UseAnimTree(#animtree);
	addNotetrack_exploder( "fxanim_props", "platform_hits_deck", 128, "a_dbl_mast_platform" );
	thread anim_single(self, "a_dbl_mast_platform", "fxanim_props");
	level waittill("deck_fxanim_start");
	self SetForceNoCull();
	flag_wait( "deck_cleanup" );
	self delete();
}

aft_radio_tower()
{
	level waittill("aft_radio_tower_start");
	self UseAnimTree(#animtree);
	exploder(124);
	addNotetrack_exploder( "fxanim_props", "tower_impact01", 125, "a_aft_radio_tower" );
	addNotetrack_exploder( "fxanim_props", "tower_impact02", 126, "a_aft_radio_tower" );
	thread anim_single(self, "a_aft_radio_tower", "fxanim_props");
	level waittill("deck_fxanim_start");
	self SetForceNoCull();
	flag_wait( "deck_cleanup" );
	self delete();
}

aft_radio_tower_flag()
{
	level waittill("aft_radio_tower_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_aft_radio_tower_flag", "fxanim_props");
	flag_wait( "deck_cleanup" );

	self delete();
}

fwd_radio_tower()
{
	level waittill("fwd_radio_tower_start");
	self UseAnimTree(#animtree);
	exploder(132);
	addNotetrack_exploder( "fxanim_props", "tower_impact01", 133, "a_fwd_radio_tower" );
	anim_single(self, "a_fwd_radio_tower", "fxanim_props");
	flag_wait( "deck_cleanup" );

	self delete();
}

fwd_radio_mast()
{
	level waittill("fwd_radio_tower_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_fwd_radio_mast", "fxanim_props");
	flag_wait( "deck_cleanup" );

	self delete();
}

aft_wire_tower()
{
	level waittill("aft_wire_tower_start");
	self UseAnimTree(#animtree);
	addNotetrack_exploder( "fxanim_props", "tower_hits_deck", 123, "a_aft_wire_tower" );
	anim_single(self, "a_aft_wire_tower", "fxanim_props");
	flag_wait( "deck_cleanup" );

	self delete();
}

fwd_wire_tower_b()
{
	level waittill("fwd_wire_tower_b_start");
	self UseAnimTree(#animtree);
	exploder(134);
	addNotetrack_exploder( "fxanim_props", "fwd_wire_tower_hits_roof", 135, "a_fwd_wire_tower_b" );
	anim_single(self, "a_fwd_wire_tower_b", "fxanim_props");
	flag_wait( "deck_cleanup" );

	self delete();
}

door_burst()
{
	level waittill("door_burst_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_door_burst", "fxanim_props");
	flag_wait( "base_cleanup" );

	self delete();
}

sub_drop()
{
	level waittill("sub_drop_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_sub_drop", "fxanim_props");
	flag_wait( "base_cleanup" );

	self delete();
}

hoist_drop01()
{
	level waittill("sub_drop_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_hoist_drop01", "fxanim_props");
	anim_single(self, "a_hoist_idle", "fxanim_props");	
	flag_wait( "base_cleanup" );

	self delete();
}

hoist_drop02()
{
	level waittill("sub_drop_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_hoist_drop02", "fxanim_props");
	anim_single(self, "a_hoist_idle", "fxanim_props");
}

hoist_rise01()
{
	level waittill("sub_rise_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_hoist_rise01", "fxanim_props");
}

hoist_rise02()
{
	level waittill("sub_rise_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_hoist_rise02", "fxanim_props");
}

sub_rise()
{
	level waittill("sub_rise_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_sub_rise", "fxanim_props");
}

shiprope(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_shiprope", "fxanim_props");
}

huey_int()
{
	self UseAnimTree(#animtree);

	// looping idle
	self SetAnim(level.scr_anim["fxanim_props"]["a_huey_int_idle"], 1, 0.1, 1);

	// waittill notify
	level waittill("huey_int_dmg_start");

	// break anim
	self ClearAnim(level.scr_anim["fxanim_props"]["a_huey_int_idle"], 0.0);
	self SetFlaggedAnim("break", level.scr_anim["fxanim_props"]["a_huey_int_break"], 1, 0.1, 1);

	// waitill it ends
	self waittillmatch("break", "end");

	// broken loop
	self ClearAnim(level.scr_anim["fxanim_props"]["a_huey_int_break"], 0.0);
	self SetAnim(level.scr_anim["fxanim_props"]["a_huey_int_dmg"], 1, 0.1, 1);
}

huey_int_necklace()
{
	self UseAnimTree(#animtree);
	self SetAnim(level.scr_anim["fxanim_props"]["a_huey_int_necklace"], 1, 0.1, 1);
}

wires_spool(delay_min,delay_max)
{
 	flag_wait("deck_cleanup");

	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	while ( !flag( "wires_slack_start" ) )
	{
		anim_single(self, "a_umbilical_wires_spool_loop", "fxanim_props");
	}
	self UseAnimTree(#animtree);
	anim_single(self, "a_umbilical_wires_spool_stop", "fxanim_props");
	flag_wait( "base_cleanup" );

	self delete();
}

wires_pistons(delay_min,delay_max)
{
 	flag_wait("deck_cleanup");
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	while ( !flag( "wires_slack_start" ) )
	{
		anim_single(self, "a_umbilical_wires_pistons_loop", "fxanim_props");
	}
	self UseAnimTree(#animtree);
	anim_single(self, "a_umbilical_wires_pistons_stop", "fxanim_props");
	flag_wait( "dive_cleanup" );

	self delete();
}

umbilical_wires_ambient()
{
 	flag_wait("deck_cleanup");

	wait(.1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_amb_wires_loop", "fxanim_props");
	flag_wait( "dive_cleanup" );

	self delete();
}

umbilical_wires_taught()
{
 	flag_wait("deck_cleanup");

	wait(.1);
	self UseAnimTree(#animtree);
	while ( !flag( "wires_slack_start" ) )
	{
		anim_single(self, "a_taught_wires_loop", "fxanim_props");
	}
	anim_single(self, "a_taught_wires_slack", "fxanim_props");
	anim_single(self, "a_taught_wires_slack_loop", "fxanim_props");
	flag_wait( "dive_cleanup" );

	self delete();
}

metal_grate()
{
	self Hide();
	level waittill("sub_drop_start");
	wait(5);	

	Exploder( 502 );
	self Show();

	// also, hide the original grates
	grates = GetEntArray( "sub_grates", "targetname" );
	for (i=0; i<grates.size; i++ )
	{
		grates[i] Delete();
	}
	flag_wait( "base_cleanup" );

	self delete();
}

moon_pool_wires()
{
	level waittill("moon_pool_wires_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_moon_pool_wires", "fxanim_props");
	flag_wait( "base_cleanup" );

	self delete();
}

chain02(delay_min,delay_max)
{
	level waittill("moon_pool_wires_start");
  wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_chain02", "fxanim_props");
	flag_wait( "base_cleanup" );

	self delete();
}

chain03(delay_min,delay_max)
{
	level waittill("moon_pool_wires_start");
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_chain03", "fxanim_props");
	flag_wait( "base_cleanup" );

	self delete();
}

wire_sway_01()
{
	wait(.1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_wire_sway_01", "fxanim_props");
}

wire_sway_04()
{
	wait(.1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_wire_sway_04", "fxanim_props");
}


hallway1()
{
	level waittill("hallway1_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_hallway1", "fxanim_props");
}

hallway2()
{
	level waittill("hallway2_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_hallway2", "fxanim_props");
}

broadcast_pipe01_a(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_broadcast_pipe01_a", "fxanim_props");
	flag_wait( "base_cleanup" );

	self delete();
}

broadcast_pipe01_b(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_broadcast_pipe01_b", "fxanim_props");
	flag_wait( "base_cleanup" );

	self delete();
}

broadcast_pipe02_a(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_broadcast_pipe02_a", "fxanim_props");
	flag_wait( "base_cleanup" );

	self delete();
}

broadcast_pipe02_b(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_broadcast_pipe02_b", "fxanim_props");
	flag_wait( "base_cleanup" );

	self delete();
}

broadcast_wires()
{
	wait(1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_broadcast_wires", "fxanim_props");
	flag_wait( "base_cleanup" );

	self delete();
}

wires_multi(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_wires_multi", "fxanim_props");
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
	
deck_panel(delay_min,delay_max)
{
	self Hide();
	level waittill("deck_fxanim_start");
	self Show();
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_uwb_panel", "fxanim_props");
	flag_wait( "deck_cleanup" );

	self delete();
}

preserver(delay_min,delay_max)
{
	self Hide();
	level waittill("deck_fxanim_start");
	self Show();
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_preserver", "fxanim_props");
	flag_wait( "deck_cleanup" );

	self delete();
}

deck_ropes_01(delay_min,delay_max)
{
	self Hide();
	level waittill("deck_fxanim_start");
	self Show();
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_uwb_ropes", "fxanim_props");
	flag_wait( "deck_cleanup" );

	self delete();
}



//footsteps()
//{
//	animscripts\utility::setFootstepEffect( "water", LoadFx( "bio/player/fx_footstep_water"));
//}

wind_initial_setting()
{
	SetSavedDvar( "wind_global_vector", "153 136 0" );    	// change "0 0 0" to your wind vector
	SetSavedDvar( "wind_global_low_altitude", -7200);    				// change 0 to your wind's lower bound
	SetSavedDvar( "wind_global_hi_altitude", 780);    			// change 10000 to your wind's upper bound
	SetSavedDvar( "wind_global_low_strength_percent", 0.5);		// change 0.5 to your desired wind strength percentage

}

//self is F4
f4_add_contrails()
{
	playfxontag(level._effect["jet_contrail"], self, "tag_left_wingtip" );
	playfxontag(level._effect["jet_contrail"], self, "tag_right_wingtip" );
	playfxontag(level._effect["jet_exhaust"], self, "tag_engine_l" );
	playfxontag(level._effect["jet_exhaust"], self, "tag_engine_r" );
}

/////////////////////////////////////////////////////////////////
// Divetobase Sequence
// 
// underwater_death_fx()	// self = spawner
// {
// 	playfxontag( level._effect["falling_water_bubbles"], self, "J_Wrist_LE" );
// 	playfxontag( level._effect["falling_water_bubbles"], self, "J_Wrist_RI" );
// 	playfxontag( level._effect["falling_water_bubbles"], self, "J_Elbow_LE" );
// 	playfxontag( level._effect["falling_water_bubbles"], self, "J_Elbow_RI" );
// 	playfxontag( level._effect["falling_water_bubbles"], self, "J_Ankle_LE" );
// 	playfxontag( level._effect["falling_water_bubbles"], self, "J_Ankle_RI" );
// 	playfxontag( level._effect["falling_water_bubbles"], self, "J_Knee_LE" );
// 	playfxontag( level._effect["falling_water_bubbles"], self, "J_Knee_RI" );
// 	playfxontag( level._effect["falling_water_bubbles"], self, "J_Hip_LE" );
// 	playfxontag( level._effect["falling_water_bubbles"], self, "J_Hip_RI" );
// 	playfxontag( level._effect["falling_water_bubbles"], self, "J_Head" );
// 
// 	// more blood
// 	playfxontag( level._effect["falling_water_blood"], self, "J_Head" );
// }

// play_bubbles()	// self = spawner
// {
// 	self endon("death");
// 	self endon("disconnect");
// 	level endon("moon_pool_room_entered");
// 
// 	while(1)
// 	{
// 		switch(RandomInt(6))
// 		{
// 			case 0:
// 			PlayFxOnTag( level._effect["player_underwater_bubbles_hand"], self, "J_Wrist_LE" );
// 			break;
// 
// 			case 1:
// 			PlayFxOnTag( level._effect["player_underwater_bubbles_hand"], self, "J_Wrist_RI" );
// 			break;
// 
// 			case 2:
// 			PlayFxOnTag( level._effect["player_underwater_bubbles_limb"], self, "J_Elbow_LE" );
// 			break;
// 
// 			case 3:
// 			PlayFxOnTag( level._effect["player_underwater_bubbles_limb"], self, "J_Elbow_RI" );
// 			break;
// 
// 			case 4:
// 			PlayFxOnTag( level._effect["player_underwater_bubbles_torso"], self, "J_Hip_LE" );
// 			break;
// 
// 			case 5:
// 			PlayFxOnTag( level._effect["player_underwater_bubbles_torso"], self, "J_Hip_RI" );
// 			break;
// 		}
// 		wait(0.25);
// 	}
// }


hoist_rise_audio_start( hoist )
{
    ent = Spawn( "script_origin", hoist.origin - (0,0,100) );
    
    ent PlaySound( "evt_hoist_start" );
    ent PlayLoopSound( "evt_hoist_loop", .5 );
    
    hoist waittill( "hoist_done" );
    
    ent StopLoopSound( .5 );
    ent PlaySound( "evt_hoist_end" );
    
    wait(2);
    
    ent Delete();
}

hoist_rise_audio_end( hoist )
{
    hoist notify( "hoist_done" );
}

hoist_drop_audio( hoist )
{
    playsoundatposition( "evt_hoist_drop", hoist.origin - (0,0,100) );
}
