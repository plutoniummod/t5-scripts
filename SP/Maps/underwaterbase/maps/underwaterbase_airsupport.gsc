/*
//-- Level: Underwater Base
//-- Level Designer: Gavin Goslin
//-- Scripter: Alfeche/Vento
*/

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\underwaterbase_util;
#include maps\_vehicle_aianim;
#include maps\_anim;

// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{	
	maps\createart\underwaterbase_art::set_chopper_fog_and_vision();
	
	// start spawners
	level flag_set("start_stern_firefight");	

	// set this flag 
	flag_set("heavy_resistance_encountered");

	// place player in helicopter
	maps\underwaterbase_huey::start();

	// Put Hudson in the co-pilots seat
	level.heroes["hudson"] LinkTo(level.huey, "tag_passenger");
	level.huey thread anim_loop_aligned(level.heroes["hudson"], "pilot_idle", "tag_passenger");

	// init friendly helicopters
	init_jumpto_helis();
		
	//level thread manage_billboard();	
	level thread objectives(0);
		
	// move the heli	
	heli_snipe_origin = GetStruct("airsupport_heli_start", "targetname");
	AssertEx( IsDefined(heli_snipe_origin), "THE HELI SKIPTO ORIGIN IS NOT DEFINED!");
	AssertEx( IsDefined(level.huey), "THE huey IS NOT DEFINED AND THE LEVEL JUST BROKE!");	
	level.huey.origin = heli_snipe_origin.origin;	
	
	player = get_player();
	player FreezeControls(false);

	level.huey thread maps\underwaterbase_huey::init_huey_weapons();

	// remove sam missiles
	missiles = GetEntArray("sam_missile_stern", "script_noteworthy");
	array_delete(missiles);
	
	missiles = GetEntArray("sam_missile_mid_ship", "script_noteworthy");
	array_delete(missiles);
	
	missiles = GetEntArray("sam_missile_bow", "script_noteworthy");
	array_delete(missiles);

	aa_guns = GetEntArray("aa_gun_heavy_resistance_bow", "script_noteworthy");
	array_delete(aa_guns);

	aa_guns = GetEntArray("aa_gun_heavy_resistance_mid", "script_noteworthy");
	array_delete(aa_guns);

	aa_guns = GetEntArray("aa_gun_heavy_resistance_stern", "script_noteworthy");
	array_delete(aa_guns);

	// start the water movement
	//level thread update_water_plane("ship_exterior", 40.0, 25.0, (-0.5,0,0.5));

	// set aggressive cull radius
	player = get_players()[0];
	player SetClientDvar("cg_aggressiveCullRadius", 500);
	
	// misc setup necessary to make the skipto work goes here
	run();
}

run()
{
	init_event();

	level thread weaver_heli_think();
	level thread support_heli_think();
	level thread airsupport_stern_enemies();
	level thread airsupport_stern_enemies_death_watcher();
	//level thread support_weaver_fail_condition();

	level thread dialogue();

	flag_wait("stern_deck_cleared");

	level thread allied_team_deck_support();

	flag_wait("mid_deck_cleared");

	level thread allied_team_bow_support();

	flag_wait("bow_cleared");

	level thread weaver_team_support_done();

	cleanup();
	
	maps\underwaterbase_snipe::run();
}

init_event()
{	
	// make turret tarps notsolid
	tarp_array = GetEntArray( "temp_tarp", "script_noteworthy" );
	for( i = 0; i < tarp_array.size; i++ )
	{	
		tarp_array[i] notsolid();
	}	
	
	get_players()[0] setClientDvar( "cg_fov", level.huey_fov );
	
	SetThreatBias("good_guys", "bad_guys", 999999);
	SetThreatBias("bad_guys", "good_guys", 999999);
	
	// start spawners
	flag_set("start_stern_firefight");	

	// turn off friendly fire for heli
//	level.friendlyFireDisabled = 1;	
//	SetDvar( "friendlyfire_enabled", "0" );

	get_players()[0] setclientdvar( "cg_objectiveIndicatorFarFadeDist", "99999" );
	
	wait(0.1);

	SetHeliHeightPatchEnabled("airsupport_clip_1", 0);
	SetHeliHeightPatchEnabled("airsupport_clip_deck", 0);
//	SetHeliHeightPatchEnabled("default_heli_clip", 0);

	level.huey thread maps\underwaterbase_huey::heli_pitch_align("airsupport_pitch_align_1", 3, 10, 0, 700);

	setup_topside_water();

	level thread open_and_close_that_one_door();
}

open_and_close_that_one_door()
{
	door = GetEnt("ship_deck_door", "targetname");
	if (IsDefined(door))
	{
		door Hide();
	}

	level waittill("end_player_heli");

	if (IsDefined(door))
	{
		door Show();
	}

	open_door = GetEnt("ship_deck_door_open", "targetname");
	if (IsDefined(open_door))
	{
		open_door Hide();
	}
}

// gets run through at start of level
init_flags()
{
	flag_init( "weaver_squad_unloaded" );
	flag_init( "start_stern_firefight" );
	flag_init( "stern_deck_cleared" );
	flag_init( "mid_deck_cleared" );
	flag_init( "bow_cleared" );
	flag_init( "weaver_team_unload" );
	flag_init( "support_team_unload" );
	flag_init( "stern_deck_group_a" );
	flag_init( "mid_deck_group_a_done" );
	flag_init( "mid_deck_group_b_done" );
	flag_init( "mid_deck_group_c_done" );
	flag_init( "mid_deck_group_d_done" );
	flag_init( "bow_group_a" );
	flag_init( "bow_group_b" );
	flag_init( "bow_group_c" );

	maps\underwaterbase_snipe::init_flags();
}

init_jumpto_helis()
{
	trigger_use("trig_start_friendly_hueys");
	wait(0.05);

	// delete destoryed hueys
	huey_c = GetEnt("friendly_huey_C", "targetname");
	huey_c delete();

	huey_d = GetEnt("friendly_huey_D", "targetname");
	huey_d delete();

	// init weaver heli
	weaver_heli = GetEnt("friendly_huey_A", "targetname");
	weaver_heli init_friendly_heli( "weaver_heli_airsupport_jumpto" );
	weaver_heli thread heli_avoidance();

	weaver_heli.pilot = spawn_character("pilot", (0,0,0), (0,0,0), "pilot");
	weaver_heli.pilot LinkTo(weaver_heli, "tag_driver");
	weaver_heli thread anim_loop_aligned(weaver_heli.pilot, "idle", "tag_driver");

	weaver_heli.copilot = spawn_character("pilot", (0,0,0), (0,0,0), "copilot");
	weaver_heli.copilot LinkTo(weaver_heli, "tag_passenger");
	weaver_heli thread anim_loop_aligned(weaver_heli.copilot, "idle", "tag_passenger");

	// init support heli
	support_heli = GetEnt("friendly_huey_B", "targetname");
	support_heli init_friendly_heli( "support_heli_airsupport_jumpto" );
	support_heli thread heli_avoidance();

	support_heli.pilot = spawn_character("pilot", (0,0,0), (0,0,0), "pilot");
	support_heli.pilot LinkTo(support_heli, "tag_driver");
	support_heli thread anim_loop_aligned(support_heli.pilot, "idle", "tag_driver");

	support_heli.copilot = spawn_character("pilot", (0,0,0), (0,0,0), "copilot");
	support_heli.copilot LinkTo(support_heli, "tag_passenger");
	support_heli thread anim_loop_aligned(support_heli.copilot, "idle", "tag_passenger");

	// spawn fake riders
	//support_heli thread spawn_fake_huey_riders();
}

cleanup()
{
	ub_print( "cleanup cleardeck\n" );
	
	if(level.toggle_drones)
	{	
		maps\underwaterbase_drones::stop_drone_spawning_area("mid_to_bow_drone_start_path_0");
		maps\underwaterbase_drones::stop_drone_spawning_area("mid_to_bow_drone_start_path_1");
		maps\underwaterbase_drones::stop_drone_spawning_area("mid_to_bow_drone_start_path_2");
		maps\underwaterbase_drones::stop_drone_spawning_area("bow_drone_start_path");
	}
}

objectives( starting_obj_num )
{
	level.curr_obj_num = starting_obj_num;

	level.group_objective_markers = [];
	for (i = 0; i < 8; i++)
	{
		level.group_objective_markers[i] = (0,0,0);
	}
	
	flag_wait("start_stern_firefight");
	
	// Primary Objective - Protect Weaver's squad
	level.weaver_follow_objective_number = level.curr_obj_num;
	Objective_Add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_PROTECT_SQUAD" );
	Objective_Position( level.curr_obj_num, level.heroes["weaver"] );	
	Objective_Set3D( level.curr_obj_num, true, "green", &"UNDERWATERBASE_OBJ_PROTECT", -1, (0,0,30) );

	// Seondary Objective - Stern Firefight
	level.curr_obj_num++;	
	Objective_Add( level.curr_obj_num, "active", "" );
	Objective_Set3D( level.curr_obj_num, true, "default", &"UNDERWATERBASE_OBJ_TARGETS" );
	Objective_additionalCurrent(level.weaver_follow_objective_number);	

	flag_wait( "bow_cleared" );

	Objective_State( level.curr_obj_num - 1, "done" );
	Objective_State( level.curr_obj_num, "done" );

	Objective_Delete(level.curr_obj_num - 1);
	Objective_Delete(level.curr_obj_num);

	level.curr_obj_num++;

	maps\underwaterbase_snipe::objectives( level.curr_obj_num );
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

weaver_heli_think()
{
	heli = GetEnt("friendly_huey_A", "targetname");
	heli notify("move_mid_ship");
	heli notify("resistance_done");
	
	heli heli_land();

	flag_set("weaver_team_unload");

	trigger_use("trig_landing_zone_allies_color");

	wait(1.0);

	start_node = GetStruct("landing_zone_path_1", "targetname");
	look_node_1 = spawn("script_origin", start_node.origin + AnglesToForward(start_node.angles) * 1500);
	heli SetVehGoalPos(start_node.origin);
	heli SetLookAtEnt(look_node_1);
	heli SetSpeed(25, 12, 12);

	heli waittill("goal");

	heli thread support_huey_strafe_stern();
	heli thread heli_avoidance();

//	airsupport_pos = GetStruct("airsupport_pos_2", "targetname");
//	look_ent_3 = spawn("script_origin", airsupport_pos.origin + AnglesToForward(airsupport_pos.angles) * 1500);
//
//	heli SetVehGoalPos(airsupport_pos.origin, 1);
//	heli SetLookAtEnt(look_ent_3);
//	heli SetSpeed(40, 20, 20);
//
//	heli waittill("goal");
//
//	heli SetJitterParams( (5,0,5), 0.5, 1.0 );
//	heli SetHoverParams( 10, 10, 15 );

	flag_set("weaver_squad_unloaded");

	flag_wait("stern_deck_cleared");

//	heli.lockheliheight = true;

	heli notify("stop_firing");
	heli notify("done_strafing");

//	heli thread huey_rpg_guys_support();

	heli thread heli_deck_movement();

	self waittill("goal");

//	heli.lockheliheight = false;

//	heli thread huey_deck_support("airsupport_deck_support_1", "airsupport_deck_support_look_1");
//
//	heli waittill("goal");
//	heli.lockheliheight = false;
//
//	trigger_wait("trig_airsupport_allies_color_2");
//
//	heli notify("new_support_pos");
//
//	heli thread huey_deck_support("airsupport_deck_support_2", "airsupport_deck_support_look_2");
//
//	look_node_1 delete();
//	look_ent_3 delete();
}

support_heli_think()
{
	heli = GetEnt("friendly_huey_B", "targetname");
	heli notify("move_mid_ship");
	heli notify("resistance_done");

//	airsupport_pos = GetStruct("airsupport_pos_1", "targetname");
//	look_ent = spawn("script_origin", airsupport_pos.origin + AnglesToForward(airsupport_pos.angles) * 1500);
//	heli SetVehGoalPos(airsupport_pos.origin, 1);
//	heli SetLookAtEnt(look_ent);
//	heli SetSpeed(40, 20, 20);
//	heli waittill("goal");

	heli thread support_huey_strafe_stern("upper");

	flag_wait("weaver_squad_unloaded");

	heli notify("stop_firing");
	heli notify("done_strafing");

//	heli heli_land();
//
//	flag_set("support_team_unload");
//
//	heli.pilot thread anim_single(heli.pilot, "go_go");
//
//	wait(1.5);
//
	crash_node = GetStruct( "anim_align_helipad", "targetname" );

	start_node = GetStruct("landing_zone_path_1", "targetname");
	look_node_1 = spawn("script_origin", start_node.origin + AnglesToForward(start_node.angles) * 1500);
	heli.goalradius = 16;
	heli SetVehGoalPos(crash_node.origin);
	heli SetLookAtEnt(look_node_1);
	heli SetSpeed(25, 12, 12);

	heli waittill("goal");

	heli rpg_take_out_support_huey();

	heli.supportsAnimScripted = true;
	heli.animname = "helicopter";
	heli UseAnimTree(level.scr_animtree["helicopter"]);
	
	crash_node thread anim_single_aligned(heli, "heli_crash_1");

	heli waittillmatch("single anim", "missle_impact");
	
	heli PlaySound( "evt_enemy_crash" );

	PlayFxOnTag(level._effect["huey_fire"], heli, "origin_animate_jnt");

	heli.pilot thread anim_single(heli.pilot, "shit_going_down");

	heli waittillmatch("single anim", "crane_impact");
	
	level notify("crane_impact");

	heli thread launch_fake_huey_riders();
	heli waittillmatch("single anim", "deck_impact");

    playsoundatposition( "exp_veh_large", heli.origin );
	PlayFx( level._effect["explosion_heli"], heli.origin, (0,0,1), (1,0,0) );	

	heli waittillmatch("single anim", "end");

	if (IsDefined(heli.pilot))
	{
		heli.pilot delete();
	}

	if (IsDefined(heli.copilot))
	{
		heli.copilot delete();
	}

	heli Delete();
//	look_ent delete();
}

heli_land()
{
	// go in for a landing
	start_node = GetStruct("landing_zone_path_1", "targetname");
	look_node_1 = spawn("script_origin", start_node.origin + AnglesToForward(start_node.angles) * 1500);
	self SetVehGoalPos(start_node.origin);

	dist = Distance2DSquared(start_node.origin, self.origin);

	if (dist > (2000 * 2000))
	{
		far_look_node = spawn("script_origin", start_node.origin);
		self SetLookAtEnt(far_look_node);
		self SetSpeed(60, 30, 30);
	}
	else
	{
		self SetLookAtEnt(look_node_1);
		self SetSpeed(25, 12.5, 12.5);
	}

	self waittill("goal");

	self notify("landing");

	self SetJitterParams( (0,0,0), 5.0, 7.0 );
	self SetHoverParams( 0, 0, 0 );

//	self SetSpeed(15, 7.0, 7.0);

	self.goalradius = 32;
	end_node = GetStruct("landing_zone_path_2", "targetname");
	look_node_2 = spawn("script_origin", end_node.origin + AnglesToForward(end_node.angles) * 1500);
	self SetVehGoalPos(end_node.origin, 1);
	self SetLookAtEnt(look_node_2);

	self waittill("goal");

	self maps\_vehicle::do_unload(0);
}

huey_riders_think()
{
	self SetThreatBiasGroup("good_guys");

	level.support_troops_count++;

	self magic_bullet_shield();
	self waittill("death");

	level.support_troops_count--;

//	IPrintLn("Man Down! " + level.support_troops_count);
}

airsupport_stern_wave(group_name)
{
	stern_enemies = simple_spawn(group_name);
	level thread group_objective_marker(group_name);

//	IPrintLn("Wave: " + group_name);
}

airsupport_stern_enemies()
{
	level endon("crane_impact");

	wait(3.0);

	level thread airsupport_stern_wave("airsupport_stern_enemies_a");

	flag_set("stern_deck_group_a");

	wait(5.0);

	level thread airsupport_stern_wave("airsupport_stern_enemies_b");

	wait(4.0);

	level thread airsupport_stern_wave("airsupport_stern_enemies_c");

	wait(5.0);

	level thread airsupport_stern_wave("airsupport_stern_enemies_d");

	wait(4.0);

	level thread airsupport_stern_wave("airsupport_stern_enemies_e");

	waittill_dead(get_ai_array("airsupport_stern_enemies_b", "script_noteworthy"));

	wait(3.0);

	level thread airsupport_stern_wave("airsupport_stern_enemies_b");

	waittill_dead(get_ai_array("airsupport_stern_enemies_a", "script_noteworthy"));

	wait(3.0);

	level thread airsupport_stern_wave("airsupport_stern_enemies_a");

	waittill_dead(get_ai_array("airsupport_stern_enemies_d", "script_noteworthy"));

	wait(4.0);

	level thread airsupport_stern_wave("airsupport_stern_enemies_d");

	waittill_dead(get_ai_array("airsupport_stern_enemies_c", "script_noteworthy"));

	wait(4.0);

	level thread airsupport_stern_wave("airsupport_stern_enemies_c");

	waittill_dead(get_ai_array("airsupport_stern_enemies_e", "script_noteworthy"));

	wait(3.0);

	level thread airsupport_stern_wave("airsupport_stern_enemies_e");
}

airsupport_stern_enemies_death_watcher()
{
	level waittill("crane_impact");

	waittill_dead(get_ai_array("airsupport_stern_enemies_a", "script_noteworthy"));
	waittill_dead(get_ai_array("airsupport_stern_enemies_b", "script_noteworthy"));
	waittill_dead(get_ai_array("airsupport_stern_enemies_c", "script_noteworthy"));
	waittill_dead(get_ai_array("airsupport_stern_enemies_d", "script_noteworthy"));
	waittill_dead(get_ai_array("airsupport_stern_enemies_e", "script_noteworthy"));

	flag_set("stern_deck_cleared");
}

squad_death_watcher()
{
	level endon("airsupport_done");

	// ghetto
	while(level.support_troops_count == 0)
	{
		wait(0.05);
	}

	while(true)
	{
		if (level.support_troops_count < 1)
		{
			MissionFailed();
		}

		wait(0.05);
	}
}

allied_team_deck_support()
{
	SetHeliHeightPatchEnabled("airsupport_clip_deck", 1);
//	SetHeliHeightPatchEnabled("airsupport_clip_1", 0);
	SetHeliHeightPatchEnabled("default_heli_clip", 0);

	level.deck_support = true;

	autosave_by_name("deck_cleared");

	level.huey notify("stop_pitch_align");
	level.huey thread maps\underwaterbase_huey::heli_pitch_align("airsupport_pitch_align_2", 3, 10, 0, 700);

	trigger_use("trig_airsupport_allies_color_1");
	trigger_use("sm_airsupport_mid_enemies_a");

	level thread group_objective_marker("airsupport_mid_enemies_a");

	waittill_ai_group_count("airsupport_mid_enemies_a", 1);

	flag_set( "mid_deck_group_a_done" );

	starboard_side_guys = get_ai_array("airsupport_support_riders", "script_noteworthy");
	array_delete(starboard_side_guys);

	trigger_use("trig_airsupport_allies_color_2");
	trigger_use("sm_airsupport_mid_enemies_b");

	level thread group_objective_marker("airsupport_mid_enemies_b");

	waittill_ai_group_count("airsupport_mid_enemies_b", 1);

	flag_set( "mid_deck_group_b_done" );

	trigger_use("trig_airsupport_allies_color_3");
	trigger_use("sm_airsupport_mid_enemies_c");

	level thread group_objective_marker("airsupport_mid_enemies_c");

	waittill_ai_group_count("airsupport_mid_enemies_c", 1);

	flag_set( "mid_deck_group_c_done" );

	trigger_use("trig_airsupport_allies_color_4");
	trigger_use("sm_airsupport_mid_enemies_d");

	level thread group_objective_marker("airsupport_mid_enemies_d");

	waittill_ai_group_cleared("airsupport_mid_enemies_d");

	flag_set( "mid_deck_group_d_done" );

	flag_set( "mid_deck_cleared" );
}

allied_team_bow_support()
{
	trigger_use("trig_airsupport_allies_color_5");

//	SetHeliHeightPatchEnabled("airsupport_clip_1", 0);
	SetHeliHeightPatchEnabled("airsupport_clip_deck", 0);
	SetHeliHeightPatchEnabled("default_heli_clip", 1);

	trigger_use("trig_airsupport_bow_enemies_c");
	level thread airsupport_stern_wave("airsupport_bow_enemies_c");

	wait(4.0);

	level thread airsupport_stern_wave("airsupport_bow_enemies_a");

	wait(2.0);

	trigger_use("trig_airsupport_bow_enemies_b");
	level thread airsupport_stern_wave("airsupport_bow_enemies_b");

	waittill_ai_group_cleared("airsupport_bow_enemies_a");
	waittill_ai_group_cleared("airsupport_bow_enemies_b");
	waittill_ai_group_cleared("airsupport_bow_enemies_c");

	flag_set("bow_cleared");

	level.huey notify("stop_pitch_align");
	level.huey SetDefaultPitch(2);
}

mid_rpg_guys_spawnfunc()
{
	self endon("death");
	self SetThreatBiasGroup("player_hater");

	self thread shoot_at_player();
	
	while(IsAlive(self))
	{
		self.a.rockets = 10;
		wait(1);
	}
}

deck_enemies_spawnfunc()
{
	self SetThreatBiasGroup("bad_guys");
	self.health = 10;
}

huey_deck_support(pos, look)
{
	self endon("new_support_pos");

	pos_struct = GetStruct(pos, "targetname");
	look_struct = GetStruct(look, "targetname");
	look_ent = spawn("script_model", look_struct.origin);
	look_ent.angles = look_struct.angles;

	self SetSpeed(50, 25, 25);
	self SetVehGoalPos(pos_struct.origin, 1);
	self SetLookAtEnt(look_ent);

	self waittill("goal");

//	self SetHoverParams(25, 20, 10);
//	self SetJitterParams((25, 25, 25), 2, 3);

	self heli_engage(look_ent, 1000, 250, 250, 500, 3, 4, "stop_engage", 2);
}

weaver_team_support_done()
{
	level notify("airsupport_done");

//	flag_wait("bow_cleared");
	weaver_team = get_ai_array("airsupport_weaver_riders", "script_noteworthy");
	goal_pos = GetStruct("weaver_team_support_done", "targetname");
	array_thread(weaver_team, ::weaver_team_done, goal_pos.origin);

	level.heroes["weaver"].goalradius = 32;
	level.heroes["weaver"] SetGoalPos(goal_pos.origin);
	level.heroes["weaver"] waittill("goal");
	level.heroes["weaver"] delete();

	// set this so that if we die during the hind fight we can prevent the save restore from enabling the wrong
	// heli height mesh
	level.deck_support = false;
}

weaver_team_done(pos)
{
	self.goalradius = 32;
	self SetGoalPos(pos);
	self waittill("goal");
	self delete();
}

support_huey_strafe_stern(level_override)
{
	self endon("done_strafing");

	strafe_side = "left";
	
	stern_levels = [];
	stern_levels[0] = "upper";
	stern_levels[1] = "mid";
	stern_levels[2] = "lower";

	while (1)
	{
		strafe_level = undefined;

		if (IsDefined(level_override))
		{
			strafe_level = level_override;
		}
		else
		{
			strafe_level = Random(stern_levels);
		}

		strafe_org = GetEnt("airsupport_strafe_" + strafe_level, "targetname");

		self SetLookAtEnt(strafe_org);
		
		strafe_pos = GetStruct("airsupport_strafe_" + strafe_level + "_" + strafe_side);

		far_dist = 2000 * 2000;
		dist = Distance2DSquared(strafe_pos.origin, self.origin);
		if (dist > far_dist)
		{
			self SetSpeed(55, 22.5, 22.5);
		}
		else
		{
			self SetSpeed(30, 15, 15);
		}

		self.goal_pos = strafe_pos.origin;
		self SetVehGoalPos(self.goal_pos);

		self waittill_any("goal", "obstructed");

		self thread heli_fire_burst(strafe_org, 4.0, 5.0, 2);
		self thread heli_fire_rockets(strafe_org, 4);

		strafe_side = "right";
		strafe_pos = GetStruct("airsupport_strafe_" + strafe_level + "_" + strafe_side);

		self.goal_pos = strafe_pos.origin;
		self SetVehGoalPos(self.goal_pos);

		self waittill_any("goal", "obstructed");

		self thread heli_fire_burst(strafe_org, 4.0, 5.0, 2);
		self thread heli_fire_rockets(strafe_org, 4);

		strafe_side = "left";
	}
}

dialogue()
{
	player = get_players()[0];
	player.animname = "mason";

	level.hero_speak = false;

	level thread play_player_is_awesome_line();
	level thread play_player_is_almost_awesome_line();

	level.hero_speak = true;
	level.heroes["hudson"] anim_single(level.heroes["hudson"], "secure_lz");
	player anim_single(player, "on_it");
	level.hero_speak = false;

	flag_wait("stern_deck_group_a");
	wait(2.0);	// wait for them to get out of the building

	level.hero_speak = true;
	level.heroes["hudson"] anim_single(level.heroes["hudson"], "rpgs_upper_deck");
	level.hero_speak = false;

	flag_wait("weaver_team_unload");

	level.hero_speak = true;
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "yankee_in_position");
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "go_go_go");
	level.hero_speak = false;

	flag_wait("stern_deck_cleared");

	level.hero_speak = true;
	level.heroes["hudson"] anim_single(level.heroes["hudson"], "weaver?");
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "yankee_team_position");
	level.heroes["hudson"] anim_single(level.heroes["hudson"], "provide_support");
	level.hero_speak = false;

	level.hero_speak = true;
	support_heli = GetEnt("friendly_huey_A", "targetname");
	support_heli.pilot anim_single(support_heli.pilot, "roger_moving");

	level.heroes["weaver"] anim_single(level.heroes["weaver"], "yankee_on_me");
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "go");

	level.heroes["hudson"] anim_single(level.heroes["hudson"], "take_us_port");
	player anim_single(player, "moving_port");

	level.heroes["weaver"] anim_single(level.heroes["weaver"], "weapons_free");

	level.hero_speak = false;

	// start nags
	level thread stay_close_to_weaver_nags();
	level thread fire_support_nags();

	flag_wait("mid_deck_group_a_done");

	level.hero_speak = true;
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "clear_to_move");	
	level.hero_speak = false;

	wait(2.0);

	level.hero_speak = true;
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "hit_them");
	level.heroes["hudson"] anim_single(level.heroes["hudson"], "roger_that");
	level.hero_speak = false;

	flag_wait("mid_deck_group_b_done");

	level.hero_speak = true;
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "moving_up");	
	level.hero_speak = false;

	wait(2.0);

	level.hero_speak = true;
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "engaging");
	level.hero_speak = false;

	flag_wait("mid_deck_group_c_done");

	level.hero_speak = true;
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "go_go_go");	
	level.hero_speak = false;

	wait(2.0);

	level.hero_speak = true;
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "weapons_free");
	level.heroes["weaver"] anim_single(level.heroes["hudson"], "rpgs_bridge");
	level.hero_speak = false;

	flag_wait("mid_deck_group_d_done");

	level.hero_speak = true;
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "thanks");
	level.hero_speak = false;

	flag_wait("bow_cleared");

	level.hero_speak = true;
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "yankee_in_position");
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "lower_decks");
	level.heroes["hudson"] anim_single(level.heroes["hudson"], "behind_you");
	level.hero_speak = false;
}

rpg_take_out_support_huey()
{
	fake_rpg_struct = GetStruct("fake_rpg_stern_start", "targetname");
	rpg = MagicBullet("rpg_sp", fake_rpg_struct.origin, self.origin - (0, 0, 0));
}

stay_close_to_weaver_nags()
{
	level endon("airsupport_done");

	lines = [];
	lines[0] = "get_closer_1";
	lines[1] = "get_closer_2";

	confirm_lines = [];
	confirm_lines[0] = "closer";
	confirm_lines[1] = "roger_that";

	player = get_players()[0];
	weaver = level.heroes["weaver"];
	hudson = level.heroes["hudson"];

	nag_dist = 2500.0;
	nagging = false;
	
	while (1)
	{
		objective_pos = get_closest_objective_group();

		if (IsDefined(objective_pos))
		{
			dist = Distance2D(player.origin, objective_pos);
			//IPrintLn("Dist: " + dist);

			if (dist > nag_dist)
			{
				if (IsDefined(level.hero_speak) && level.hero_speak == false)
				{
					nagging = true;
					hudson anim_single(hudson, Random(lines));
					wait(4.0);
				}
			}
			else 
			{
				if (nagging)
				{
					player anim_single(player, Random(confirm_lines));
				}

				nagging = false;
			}
		}

		wait(0.05);
	}
}

fire_support_nags()
{
	level endon("airsupport_done");

	inactive_timer = 0.0;
	max_inactive_time = 3.0;

	player = get_players()[0];

	lines = [];
	lines[0] = "pinned_down";
	lines[1] = "taking_fire";
	lines[2] = "fire_support";

	confirm_lines = [];
	confirm_lines[0] = "engaging";
	confirm_lines[1] = "roger_that";

	while (1)
	{
		pressing_fire = player AttackButtonPressed();
		pressing_ads = player AdsButtonPressed();

		if (!pressing_fire && !pressing_ads)
		{
			inactive_timer += 0.05;
		}
		else
		{
			inactive_timer = 0.0;
		}

		if (inactive_timer >= max_inactive_time)
		{
			if (IsDefined(level.hero_speak) && level.hero_speak == false)
			{
				inactive_timer = 0.0;
				level.heroes["weaver"] anim_single(level.heroes["weaver"], Random(lines));
				wait(4.0);
			}
		}

		wait(0.05);
	}
}

huey_rpg_guys_support()
{
	self endon("stop_rpg_support");

	while (1)
	{
		guys = get_ai_array("airsupport_mid_rpg_guys", "script_noteworthy");
		if (guys.size > 0)
		{
			// find the closest dude
			target = getClosest(self.origin, guys);

			// create a point for me to go to
			//dest_node = target GetCoverNode();
			dir = AnglesToForward(target.angles);
			pos = target.origin + dir * 1500;
			pos = pos + (0,0,500);

			// go there
			self SetVehGoalPos(pos, 1);
			self SetLookAtEnt(target);

			// spin off the death thread
			target thread huey_target_death_listener(self);

			// wait till he is dead or we make it to our goal
			self waittill_any("goal", "target_died");

			// check to see if our target is still alive
			if (IsAlive(target))
			{
				// unleash the fury
				self thread heli_fire_burst(target, 2.0, 3.0, 2);
				self thread heli_fire_rockets(target, 4);

				wait(3.0);
			}
		}
		else
		{
			wait(0.05);
		}
	}
}

huey_target_death_listener(huey)
{
	self waittill("death");
	huey notify("target_died");
}

heli_deck_movement()
{
	level endon("airsupport_done");

	//self thread heli_near_player();

	self SetJitterParams( (25, 25, 25), 3.0, 4.0 );
	self SetHoverParams( 20, 10, 15 );

	nodes = [];
	num_nodes = 12;
	for (i = 0; i < num_nodes; i++)
	{
		nodes[i] = GetStruct("deck_support_pos_" + (i + 1), "targetname");
	}
//	num_nodes[num_nodes] = GetStruct("deck_support_pos_11", "targetname");

	curr_node = 0;
	while (curr_node < num_nodes)
	{
		speed = 40;
		if (IsDefined(nodes[curr_node].script_float))
		{
			speed = nodes[curr_node].script_float;
		}

		self SetSpeed(speed, speed / 2, speed / 2);
		self SetVehGoalPos(nodes[curr_node].origin, 1);

		look_ent = GetEnt(nodes[curr_node].target, "targetname");
		self SetLookAtEnt(look_ent);

		if (curr_node > 0)
		{
			if (IsDefined(nodes[curr_node].script_string) && nodes[curr_node].script_string == "fire")
			{
				self thread heli_fire_burst(look_ent, 4, 5, 2);
				self thread heli_fire_rockets(look_ent, 4);
			}
		}

		self waittill("goal");

		curr_node++;
	}
}

shoot_at_player()
{
	player = get_players()[0];
	self waittill("goal");
	self shoot_at_target_untill_dead( player );
}

support_weaver_fail_condition()
{
	level endon("airsupport_done");

	player = get_players()[0];
	weaver = level.heroes["weaver"];

	fail_dist = 4500 * 4500;
	fail_time = 0.0;
	max_fail_time = 3.0;

	while (1)
	{
		objective_pos = get_closest_objective_group();

		if (IsDefined(objective_pos))
		{
			dist = Distance2DSquared(player.origin, objective_pos);
			weaver_dist = Distance2DSquared(player.origin, weaver.origin);

			
			if (dist > fail_dist && weaver_dist > fail_dist)
			{
				fail_time += 0.05;
				if (fail_time > max_fail_time)
				{
					MissionFailedWrapper(&"UNDERWATERBASE_AIRSUPPORT_FAIL");
				}
			}
			else
			{
				fail_time = 0.0;
			}
		}

		wait(0.05);
	}
}





