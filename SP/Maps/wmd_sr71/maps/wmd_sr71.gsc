/*
	
	WMD_SR71
	Builder: Brian Glines
	Scripter: Chris Pierro, Dan Laufer, Walter Williams

*/

#include maps\wmd_sr71_util;
#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_music;


main()
{

	// This MUST be first for CreateFX!
	maps\wmd_sr71_fx::main();
	
	//-- Starts
	add_start( "sr71_test", ::skipto_sr71_test, &"WMD_SR71_TEST_SR71" );
	add_start("rts_test",maps\wmd_rts::main,&"WMD_SR71_RTS_TEST");
	//add_start("safehouse", ::wmd_sr71_safehouse, "SAFEHOUSE");
	//add_start("barracks", ::wmd_sr71_barracks, "BARRACKS");
	add_start("win_level", ::wmd_sr71_win, &"WMD_SR71_WIN");
	default_start( ::wmd_sr71_start );
	
	level.supportsPistolAnimations = true;
	
	precache_level_assets();
	maps\wmd_rts::precache_materials();
	maps\wmd_sr71_anim::init_rts_sounds();
	
	maps\_load::main();

	maps\wmd_sr71_fx::main();
	maps\wmd_sr71_amb::main();
	maps\wmd_sr71_anim::main();
	
	// -- WWILLIAMS: SETUP FLAGS AND OTHER PREP FOR SR71
	init_level_flags();
	maps\wmd_rts::init_rts_flags();
	battlechatter_off("allies");
	maps\wmd_sr71_fx::clouds();
	
	level maps\_rusher::init_rusher();
	
	// -- WWILLIAMS: NOT SURE WHAT THESE ARE FOR, MOVING THEM OVER IN CASE
	// -- TODO: WHAT IS THIS FOR?
	//////depricated hero lighting, new system is set in art gsc////////////////////
	//SetDvar( "r_heroLightScale", "1 1 1" );
	SetDvar( "ui_deadquote", "" );
		
}


wmd_sr71_start()
{
	//-- This DVar is for tracking whether or not you played through
	//  the level in a single sitting.
	SetDvar("wmd_rts_achievement", 1 );

	//SR71 intro
//	maps\wmd_sr71_util::screen_fade_in();
	maps\wmd_intro::main();
}


wmd_sr71_safehouse()
{
	wait_for_first_player();
	
	flag_set("sr71_dialogue_done");
	flag_set("optics_check");
	flag_set("squad_located");
	flag_set("squad_hidden");
	
	wait(1.0);
	
	level thread maps\wmd_rts::main();
	
	wait(0.5);
	
	level notify("stop_color_logic");
	
	wait(0.5);
	
	trigger_use("spawn_convoy");
	trigger_use("spawn_patrol");
}


wmd_sr71_barracks()
{
	wait_for_first_player();
}


wmd_sr71_win()
{
	wait_for_first_player();
	level thread maps\wmd_intro::main();
	get_players()[0] SetClientDvar( "cg_defaultFadeScreenColor", "1 1 1 0" );
	wait(5);
	nextmission();
}


precache_level_assets()
{
	
	// -- WWILLIAMS: WMD_SR71 STUFF
	PreCacheModel("viewmodel_usa_sr71_pilot_player_fullbody");
	PreCacheModel("viewmodel_usa_sr71_pilot_player");
	PreCacheModel("viewmodel_hands_no_model");
	PreCacheModel("c_usa_sr71_groundcrew_body");
	PreCacheModel("c_usa_sr71_groundcrew_head1");
	PreCacheModel("c_usa_sr71_groundcrew_head2");
	PreCacheModel("c_usa_sr71_groundcrew_head3");
	PreCacheModel("c_usa_sr71_groundcrew_head4");
	PreCacheModel("c_usa_sr71_pilot_fb" );
	PreCacheModel("t5_veh_jet_sr71_flightstick");
	PreCacheModel("t5_veh_jet_sr71_cockpit");
	PreCacheModel("t5_veh_jet_sr71_gear_doors");
	PreCacheModel("c_rus_spetznaz_snow_sr71_fb");
	PreCacheModel("tag_origin_animate");
	
	PreCacheModel( "tag_origin" );
	PreCacheModel( "p_glo_cardboardbox_1" );
	PreCacheModel( "anim_glo_clipboard_wpaper" );
	PreCacheModel( "anim_jun_lights_searchlight" );
	PreCacheModel( "melee_chair" );
	
	PreCacheModel( "t5_weapon_aug_viewmodel_arctic" );
	PreCacheModel("viewmodel_usa_blackops_winter_player");
	
	// -- WWILLIAMS: WMD SR71 RUMBLE
	PrecacheRumble("sr71_exterior");
	PrecacheRumble("sr71_interior");
	PrecacheRumble("sr71_interior_gforce");
	PrecacheRumble("rappel_falling");

	// -- Weaver's knife.
	PreCacheModel( "t5_knife_animate" );
	PreCacheModel( "weapon_semtex_grenade" );
	
	PreCacheItem( "aug_arctic_acog_silencer_sp" );
	PreCacheItem( "aug_arctic_acog_sp" );
	PreCacheItem( "flash_grenade_sp" );
	PreCacheItem( "satchel_charge_sp" );	
	PreCacheItem( "famas_sp" );	
	PreCacheItem( "famas_acog_sp" );	
	PreCacheItem( "famas_dualclip_sp" );	
	PreCacheItem( "famas_elbit_sp" );	
	PreCacheItem( "famas_gl_sp" );
	PreCacheItem( "gl_famas_sp" );
	PreCacheItem( "famas_reflex_sp" );	
	PreCacheItem( "cz75dw_auto_sp" );
	PreCacheItem( "cz75lh_auto_sp" );
	PreCacheItem( "hk21_sp" );	
	PreCacheItem( "hk21_acog_sp" );
	PreCacheItem( "hk21_reflex_sp" );	
	PreCacheItem( "hk21_extclip_sp" );
	PreCacheItem( "skorpion_sp" );
	PreCacheItem( "skorpion_extclip_sp" );
}


init_level_flags()
{
	// sr71 intro
	flag_init("pre_engine_dialog_done");
	flag_init("engine_prompt_given");
	flag_init("engines_hit");
	flag_init("thrusters_on");
	flag_init("camera_cut_1");
	flag_init("camera_cut_2");
	flag_init("camera_cut_3");
	flag_init("camera_cut_4");
	flag_init("camera_cuts_done");
	flag_init("begin_gforce");
	flag_init("takeoff_success");
	flag_init("takeoff_fail");
	flag_init("takeoff_complete");
	flag_init("sr71_dialogue_done");

}

skipto_sr71_test()
{
	flag_wait("all_players_spawned");
	level thread sr71_test();
	player = get_players()[0];
	sr71 = ent_get("sr71_cam");
	player allowstand(true);
	player allowcrouch(false);
	player allowprone(false);
	player SetClientDvar( "compass", 0);	
	player DisableWeapons();
	player playerlinkto(sr71,"tag_passenger");
	PrintLn("*** Sending SR71");
	
	clientnotify("sr71_relaystation");
		
	level waittill("stop_sr71_test");
	
	clientnotify("sr71_test_end");	
	get_players()[0] SetClientDvar( "compass", 1);	
	get_players()[0] EnableWeapons();
}

sr71_test()
{
	//maps\wmd_event1::spawn_event1_initial_enemies();
	// maps\wmd_approach_radar::spawn_event1_initial_enemies();
	
	guards = get_ai_group_ai("e1_relay_guys");
	set_white_body_models(guards);
	
	trigs = getentarray("lookat_trigs","targetname");
	spawn_sr71_cam("extra_cam_pos2","sr71_test_end",true,true);
	
	wait(10);
	player = get_players()[0];
	while(!player attackbuttonpressed() )
	{
		wait (.05);
	}
	
	player unlink();
	spot = ent_get("test_player_warp");
	player setorigin(spot.origin);
	

	player setplayerangles(spot.angles);
	player startcameratween(.35);
	
	if(isDefined(level.marked_targets))
	{
		for(i=0;i<level.marked_targets.size;i++)
		{
			trig = trigs[i];
			trig.obj_num = i;
			trig.origin = level.marked_targets[i];
			objective_add(i,"current");
			objective_position(i,level.marked_targets[i]);
			trig thread wait_to_be_looked_at();
			Objective_Set3D( i, true,"default",&"WMD_ENEMY_LOCATION" );
		}
		
	}
	
	player allowstand(true);
	player allowcrouch(true);
	player allowprone(true);
	player SetClientDvar( "compass", 1);	
	player EnableWeapons();	
	restore_body_model(guards);
	
}