/*
//-- Level: Underwater Base
//-- Level Designer: Gavin Goslin
//-- Scripter: Alfeche/Vento
*/

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\underwaterbase_util;
#include maps\_vehicle;
#include maps\_ai_rappel;
#include maps\_rusher;
#include maps\_anim;
#include maps\_music;

// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	level thread objectives(0);
 	
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
	
	player_to_struct( "rendezvous_start" );

	init_jumpto_helis();

	maps\createart\underwaterbase_art::set_rendezvous_fog_and_vision();

	// start the water movement
	//level thread update_water_plane("ship_exterior", 40.0, 25.0, (-0.5,0,0.5));

	// set aggressive cull radius
	player = get_players()[0];
	player SetClientDvar("cg_aggressiveCullRadius", 600);

	level thread maps\underwaterbase_introigc::ship_destruction();

//	level.huey notify("end_player_heli");	// turn off huey firing loops
	wait(1);

	// misc setup necessary to make the skipto work goes here
	run();
}

run()
{
	init_event();
	
	// save game
	autosave_by_name( "underwaterbase" );
	wait( 0.05 );

	maps\_rusher::init_rusher();
	// jump to huey
	if (!IsDefined(level.support_huey))
	{
		level.support_huey = GetEnt("rendezvous_support_huey", "targetname");
	}

	level notify("deck_fxanim_start");

	ClientNotify("start_dynent_cleanup");
	level.dynent_cleanup_active = true;

	level.support_huey thread support_huey_think();

	level thread manage_exploders();
	level thread player_squad_movement();
	level thread tow_wait_for_pickup();
	level thread tow_missile_moment();
	level thread enemy_hips();
	level thread turn_off_water();
	level thread dialogue();
	level thread do_phys_pulses();
	level thread handle_deck_end_door();
	level thread achievement_watcher();
	level thread player_height_kill();
	level thread ship_deck_cleanup();

	flag_wait( "player_reached_umbilical" );

	cleanup();
	maps\underwaterbase_bigigc::run();
}

init_event()
{
	ub_print( "init rendezvous\n" );

	// show player hud elements
    player = get_players()[0];	
	player SetClientDvar( "compass", "1" );
	player SetClientDvar( "hud_showstance", "1" );
	player SetClientDvar( "actionSlotsHide", "0" );
	player SetClientDvar( "ammoCounterHide", "0" );

	// turn this off
	player.flying_huey = false;

	// turn ADS back on
	player AllowADS(true);

	// deck fx
	exploder(104);
	clientnotify( "snfxfr" );
 	
    level.seaent = spawn( "script_origin", player.origin );
    player PlayerSetGroundReferenceEnt( level.seaent );
    level.seaent thread roll_sea_entity();
    
    // the gravity thread
    level thread ship_gravity();

	level.tow_launcher = undefined;

	setup_topside_water();

	// turn on battle chatter
	battlechatter_on("allies");
	battlechatter_on("axis");

	level.squads = [];
	level.squads["purple"] = [];
	level.squads["blue"] = [];

	// turn off these triggers
	trig1 = GetEnt("sm_rendezvous_enemies_d", "targetname");
	trig1 trigger_off();

	trig2 = GetEnt("trig_rendezvous_final_guys", "targetname");
	trig2 trigger_off();

//	player = get_players()[0];
//	player SetClientDvar("cg_aggressiveCullRadius", 2000);

	// set this back...3 secs
	anim.gibDelay = 3 * 1000;
}

// gets run through at start of level
init_flags()
{
	flag_init( "close_to_weaver" );
	flag_init( "enemy_hinds_arrive" );
	flag_init( "player_get_tow" );
	flag_init( "player_got_tow" );
	flag_init( "hip_1_rappel_done" );
	flag_init( "destroyed_enemy_hind_1" );
	flag_init( "destroyed_enemy_hind_2" );
	flag_init( "player_reached_umbilical" );
	flag_init( "turn_off_outside_ship_water" );
	flag_init( "squad_go" );
	
	maps\underwaterbase_bigigc::init_flags();
}

// rendezvous_save_restore()
// {
// 	if (IsDefined(level.dynent_cleanup_active) && level.dynent_cleanup_active == true)
// 	{
// 		ClientNotify("stop_dynent_cleanup");
// 		ClientNotify("start_dynent_cleanup");
// 	}
// }

cleanup()
{
	ub_print( "cleanup rendezvous\n" );
}

objectives( starting_obj_num )
{
	level.curr_obj_num = starting_obj_num;
	
	Objective_Add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_RENDEZVOUS" );
	Objective_Position( level.curr_obj_num, struct_origin("head_toward_bow_objective") );
	Objective_Set3D( level.curr_obj_num, true );
	
	// enemy hinds will appear
	flag_wait( "enemy_hinds_arrive" );	
	Objective_Set3D( level.curr_obj_num, false );	// temp off current objective
	level.curr_obj_num++;
	Objective_Add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_DESTROY_HIPS" );
	level.curr_obj_num++;

	Objective_Add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_PICKUP_TOW" );
	Objective_Set3D( level.curr_obj_num, true, "default", &"UNDERWATERBASE_OBJ_TOW" );
	Objective_Position( level.curr_obj_num, level.tow_launcher.origin + (0,0,16) );

	flag_set("player_get_tow");

	flag_wait("player_got_tow");

	Objective_Delete( level.curr_obj_num );
	level.curr_obj_num--;

	Objective_AdditionalPosition(level.curr_obj_num, 1, level.hip_1);
	Objective_AdditionalPosition(level.curr_obj_num, 2, level.hip_2);
	
	Objective_Set3D( level.curr_obj_num, true );
	
	flag_wait( "destroyed_enemy_hind_1" );	
	flag_wait( "destroyed_enemy_hind_2" );
	
	clientnotify( "alms2" );
	
	// bow objective active again
	Objective_Delete( level.curr_obj_num );
	level.curr_obj_num--;
	Objective_State( level.curr_obj_num, "current" );	// temp off current objective
	Objective_Set3D( level.curr_obj_num, true );
	
	flag_wait( "head_toward_bow_objective_trigger" );
	
//	Objective_State( level.curr_obj_num, "done" );
//	level.curr_obj_num++;
//	Objective_Add( level.curr_obj_num, "active", &"UNDERWATERBASE_OBJ_RENDEZVOUS" );
	Objective_Position( level.curr_obj_num, struct_origin("interior_1_objective_rendezvous") );
	Objective_Set3D( level.curr_obj_num, true );	
	flag_wait( "interior_1_objective" );
	
//	Objective_Position( level.curr_obj_num, struct_origin("interior_2_objective_rendezvous") );
//	flag_wait( "interior_2_objective" );
	
	Objective_Position( level.curr_obj_num, struct_origin("interior_3_objective_rendezvous") );
	flag_wait( "interior_3_objective" );

	// HACK! Turn off water
	flag_set("turn_off_outside_ship_water");

	Objective_Position( level.curr_obj_num, struct_origin("interior_4_objective_rendezvous") );
	flag_wait( "interior_4_objective" );
	
	clientnotify( "dlsnfx" );	
	setmusicstate("LOWER_DECK_FIGHT");
	
	Objective_Position( level.curr_obj_num, struct_origin("interior_5_objective_rendezvous") );
	flag_wait( "interior_5_objective" );	
	
	Objective_Position( level.curr_obj_num, struct_origin("interior_6_objective_rendezvous") );
	flag_wait( "interior_6_objective" );
		
	Objective_Set3D( level.curr_obj_num, false );

	// HAXXXORRR...chill out water
	setup_umbilical_water();

// 	Objective_Position( level.curr_obj_num, struct_origin("interior_7_objective_rendezvous") );
// 	flag_wait( "interior_7_objective" );
// 
// 	Objective_Position( level.curr_obj_num, struct_origin("temp_rendezvous_objective") );
// 	flag_wait( "temp_rendezvous_objective" );
// 
// 	Objective_State( level.curr_obj_num, "done" );
 	flag_set("player_reached_umbilical");
// 	
//	level.curr_obj_num++;
	maps\underwaterbase_bigigc::objectives( level.curr_obj_num );
}


roll_sea_entity()
{
	level endon( "enter_sea" );
	
    while(true)
    {
        self rotateto( (1.5,0,1.5), 3, 0.5, 0.75 );
        self waittill( "rotatedone" );
        self rotateto( (-1.5,0,-1.5), 3, 0.5, 0.75 );
        self waittill( "rotatedone" );
    }
}

ship_gravity()
{
	level endon( "enter_sea" );
		
	while(1)
	{
		wait .05;
//		down = ( 0, 0, -800 );
		level.seaent.up = anglestoup( level.seaent.angles );
		vec1 = vector_multiply( anglestoup( level.seaent.angles ), -800 );
		// magnify the x and y components
		vec2 = vector_multiply( ( vec1[0], vec1[1], 0 ), 10 );
		vec = vec1 + vec2;
		setPhysicsGravityDir( vec );
	}
}

player_squad_movement()
{
//	level thread squad_disable_hero_watcher();

	level.heroes["hudson"] disable_ai_color();
	level.heroes["hudson"] SetGoalNode(GetNode("rendezvous_hudson_start", "targetname"));

	trigger_wait("trig_rendezvous_allies_color_0");

	flag_set("squad_go");
	level.heroes["hudson"] enable_ai_color();

	squad = get_ai_array("redezvous_player_squad", "script_noteworthy");
	array_thread(squad, ::squad_init);

	trigger_wait("sm_rendezvous_enemies_a");

//	array_notify(level.squads["purple"], "sprint");
//	array_notify(level.squads["blue"], "sprint");

//	rpg_guys = simple_spawn("rendezvous_rpg_guys");

	waittill_ai_group_count("rendezvous_enemies_a", 1);

	trigger_use("trig_rendezvous_allies_color_1");

	waittill_ai_group_count("rendezvous_enemies_a_2", 1);

	trigger_use("trig_rendezvous_allies_color_2");

	trigger_use("sm_rendezvous_enemies_b");

	waittill_ai_group_count("rendezvous_enemies_b_1", 1);

	trigger_use("trig_rendezvous_allies_color_3");

	waittill_ai_group_count("rendezvous_enemies_b_2", 1);

	trigger_use("trig_rendezvous_allies_color_4");

	waittill_ai_group_count("rendezvous_enemies_b_3", 1);

	trigger_use("trig_rendezvous_allies_color_5");

	waittill_spawn_manager_cleared("sm_rendezvous_enemies_b");

	trigger_use("trig_rendezvous_allies_color_6");

	flag_wait("enemy_hinds_arrive");

	autosave_by_name("enemy_hips");

	trigger_use("trig_rendezvous_allies_color_7");

	flag_wait("destroyed_enemy_hind_1");
	flag_wait("destroyed_enemy_hind_2");

	// turn these triggers back on
	trig1 = GetEnt("sm_rendezvous_enemies_d", "targetname");
	trig1 trigger_on();

	trig2 = GetEnt("trig_rendezvous_final_guys", "targetname");
	trig2 trigger_on();

	autosave_by_name("enemy_hips_dead");

	trigger_use("sm_rendezvous_enemies_c");

	waittill_ai_group_count("rendezvous_enemies_c_1", 1);

	trigger_use("trig_rendezvous_allies_color_8");

	waittill_ai_group_count("rendezvous_enemies_c_2", 1);

	trigger_use("trig_rendezvous_allies_color_9");

	waittill_ai_group_cleared("rendezvous_enemies_c_3");

	trigger_use("trig_rendezvous_allies_color_10");

	waittill_ai_group_cleared("rendezvous_enemies_d_1");

	trigger_use("trig_rendezvous_allies_color_11");

	waittill_spawn_manager_cleared("sm_rendezvous_enemies_d");

	autosave_by_name("under_ship");

	level.heroes["hudson"] thread hudson_under_ship_movement();
	level thread squad_move_inside_ship();

	flag_wait("interior_3_objective");
	//	Some cleanup starts now, so give it time to settle before saving.
	wait( 1.0 );

	autosave_by_name("under_ship_2");

	// delete our left over squad
//	squad = get_ai_array("redezvous_player_squad", "script_noteworthy");
//	array_delete(squad);
}

squad_init()
{
	self enable_cqbsprint();
	self enable_ai_color();
	self.ignoresuppression = 1;
	self.grenadeawareness = 0;

	if (IsDefined(self.script_forcecolor))
	{
		if (self.script_forcecolor == "p")
		{
			level.squads["purple"] = array_add(level.squads["purple"], self);
		}
		else if (self.script_forcecolor == "b")
		{
			level.squads["blue"] = array_add(level.squads["blue"], self);
		}
	}

	//self thread squad_sprint_watcher();
}

squad_sprint_watcher()
{
	self endon("death");
	self endon("stop_sprint_watch");

	while (1)
	{
		self waittill("sprint");
		self.sprint = true;
		self waittill("goal");
		self.sprint = false;
	}
}

squad_disable_hero_watcher()
{
	trigger_wait("sm_rendezvous_enemies_d");

	squad = get_ai_array("redezvous_player_squad", "script_noteworthy");
	array_thread(squad, ::unmake_hero);
}

squad_move_inside_ship()
{
	squad = get_ai_array("redezvous_player_squad", "script_noteworthy");
	nodes = GetNodeArray("rendezvous_under_ship_squad_nodes_1", "targetname");

	for (i = 0; i < squad.size; i++)
	{
		squad[i] SetGoalNode(nodes[i]);
	}
}

//------------------------------------
// Wait for the player to find and pick up the tow
tow_wait_for_pickup()
{
	player = get_players()[0];
	player endon( "disconnect" );
	player endon( "death" );

	flag_wait( "player_get_tow" );

	while( player GetCurrentWeapon() != "uwb_m220_tow_sp" )
	{
		wait( .1 );
	}

	if (IsDefined(level.obj_model))
	{
		level.obj_model delete();
	}

	player thread tv_missile_controls();
	player thread tow_unlimited_ammo();
	flag_set( "player_got_tow" );
}

//tutorial messages for the tv guided missile, self is the player
tv_missile_controls()
{
	level endon("tv_missile_instruction_displayed");
	
	while(1)
	{
		//wait until the player obtained the weapon
		while( self GetCurrentWeapon() != "uwb_m220_tow_sp" || !isADS(self))
		{
			wait(0.05);
		}
	
		//display how to steer the rocket in air
		wait(0.5);
	
		if( self GetCurrentWeapon() == "uwb_m220_tow_sp" && isADS(self))
		{
			self thread tv_missile_controls_message(&"UNDERWATERBASE_MISSLE_CONTROL");
			level notify("tv_missile_instruction_displayed");
		}
	}
}

tv_missile_controls_message(message)
{
	screen_message_create(message);
	wait(3);
	screen_message_delete();
}

tow_unlimited_ammo()
{
	self endon("death");

	while (!flag("destroyed_enemy_hind_1") || !flag("destroyed_enemy_hind_2"))
	{
		if (self GetCurrentWeapon() == "uwb_m220_tow_sp")
		{
			self GiveMaxAmmo("uwb_m220_tow_sp");
		}	

		wait(0.05);
	}
}

init_jumpto_helis()
{
	// init support heli
	support_heli = spawn_vehicle_from_targetname("rendezvous_support_huey");
	support_heli init_friendly_heli( "rendezvous_support_huey_start" );

	support_heli.skipto = true;
}

support_huey_think()
{
	self endon("death");

	if (IsDefined(self.skipto) && self.skipto)
	{
		self support_huey_drop();
	}

	wait(5.5);

	deck_start = GetStruct("rendezvous_support_huey_targets_start", "targetname");
	deck_align = GetStruct("rendezvous_support_huey_align", "targetname");
	look_at = spawn("script_origin", deck_align.origin);
	self SetVehGoalPos(deck_start.origin, 1);
	self SetLookAtEnt(look_at);
//	self.lockheliheight = true;

	self waittill("goal");

	player = get_players()[0];
	player SetThreatBiasGroup("player");

//	self.lockheliheight = false;
	self SetJitterParams((20, 20, 20), 2, 3);
	self SetHoverParams(25, 10, 5);
	self SetSpeed(25, 12, 12);

	trigger_wait("sm_rendezvous_enemies_a");

	self thread support_huey_deck_targets_2();

	//flag_wait("enemy_hinds_arrive");
	level waittill("tow_missile_guy");

	self SetSpeed(40, 20, 20);

	level.vehicle_death_thread[self.vehicletype] = maps\underwaterbase_snipe::heli_crash_think;

	go_pos = GetStruct("support_heli_tow_missile_spot", "targetname");

	self SetVehGoalPos(go_pos.origin, 1);
	self SetLookAtEnt(level.tow_missile_guy);
	self.takedamage = true;

	if (IsDefined(self.pilot))
	{
		self.pilot delete();
	}

	if (IsDefined(self.copilot))
	{
		self.copilot delete();
	}
}

support_huey_deck_targets()
{
	self endon("death");
	level endon("tow_missile_guy");
	self endon("enemy_hinds_arrive");

	player = get_players()[0];
	align_node = GetStruct("rendezvous_support_huey_align", "targetname");
	right_vector = AnglesToRight(align_node.angles);
	forward_vector = AnglesToForward(align_node.angles);

	self thread support_huey_weapon_think();

	while (true)
	{
		self_origin = self.origin;
		player_origin = player.origin;

		new_pos = player_origin + (right_vector * RandomFloatRange(750, 800));
		new_pos = new_pos + (forward_vector * RandomFloatRange(750, 800));
		new_pos = (new_pos[0], new_pos[1], new_pos[2] + 300);

		self SetVehGoalPos(new_pos, 1);

		wait(RandomFloatRange(2, 3));
	}
}

support_huey_deck_targets_2()
{
	self endon("death");
	level endon("tow_missile_guy");
	self endon("enemy_hinds_arrive");

	self thread support_huey_weapon_think();

	go_pos = GetStruct("support_heli_spot_1", "targetname");
	self SetVehGoalPos(go_pos.origin, 1);

	self waittill("goal");

	wait(3);

	go_pos = GetStruct("support_heli_spot_2", "targetname");
	look_pos = GetStruct("support_heli_spot_look_1", "targetname");
	look_ent = spawn("script_origin", look_pos.origin);

	self SetVehGoalPos(go_pos.origin, 1);
	self SetLookAtEnt(look_ent);

	self waittill("goal");

	trigger_use("trig_rendezvous_rpg_guys_b");
}

support_huey_weapon_think()
{
	self endon("death");
	level endon("tow_missile_guy");
	self endon("enemy_hinds_arrive");

	self.firing = false;

	while (!flag("enemy_hinds_arrive"))
	{
		axis = get_ai_array("rendezvous_enemies_heli_target", "script_noteworthy");
		rpg_guys = get_ai_array("rendezvous_rpg_guys", "script_noteworthy");

		targets = [];
		if (rpg_guys.size > 0)
		{
			targets = rpg_guys;
		}
		else if (axis.size > 0)
		{
			targets = axis;
		}

		if (targets.size > 0)
		{
			target = Random(targets);

			self SetLookAtEnt(target);

			self thread heli_fire_burst(target, 2, 2.5, 2);
			self thread heli_fire_rockets(target, 2);

//			target waittill("death");
			wait(RandomFloatRange(2.5, 3));
		}
		else 
		{
			wait(0.05);
		}
	}
}

rpg_guys_spawnfunc()
{
	self endon("death");
	self SetThreatBiasGroup("rpg_guys");
	
	while(IsAlive(self))
	{
		self.a.rockets = 10;
		wait(1);
	}
}

tow_missile_moment()
{
	trigger_wait("trig_rendezvous_rpg_guys_b");

	level.tow_missile_guy = simple_spawn_single("tow_missile_guy");
	level.tow_missile_guy thread tow_missile_guy_think();

	level notify("tow_missile_guy");
}

tow_missile_guy_think()
{
	self thread tow_missile_dropweapon_delete();

	// get align node
	align_node = GetStruct(self.target, "targetname");
	align_node thread anim_generic_aligned(self, "tow_fire");

	self waittillmatch("single anim", "tow_fire");

	self thread tow_missile_guy_drop_weapon();
	rocket = MagicBullet("uwb_m220_tow_ai_sp", self GetWeaponMuzzlePoint(), level.support_huey.origin - (0,0,50));
}

tow_missile_guy_drop_weapon()
{
	flag_wait("enemy_hinds_arrive");

	tow_spot = GetStruct("rendezvous_tow_spot", "targetname");

	level.tow_launcher = spawn("weapon_uwb_m220_tow_sp", tow_spot.origin);
	level.tow_launcher.angles = tow_spot.angles;

	level.obj_model = undefined;
	if (IsDefined(level.tow_launcher))
	{
		offset = (0,0,-7.5);
		offset += AnglesToRight(tow_spot.angles) * -6;
		offset += AnglesToForward(tow_spot.angles) * -11;

		level.obj_model = spawn("script_model", level.tow_launcher.origin + offset);
		level.obj_model SetModel("t5_weapon_strela_obj");
		level.obj_model.angles = level.tow_launcher.angles + (0,0,90);
	}
}

tow_missile_dropweapon_delete()
{
	self waittill("dropweapon", tow_launcher);

	if (IsDefined(tow_launcher))
	{
		tow_launcher delete();
	}
}

enemy_hips()
{
//	trigger_wait("trig_rendezvous_hips");

	waittill_spawn_manager_ai_remaining("sm_rendezvous_enemies_b", 1);
	trigger_use("trig_rendezvous_hips");

	flag_set("enemy_hinds_arrive");

	level.hips_killed = 0;

	trigger_use("trig_enemy_color_r1004");

	wait(0.05);

	level.hip_1 = GetEnt("rendezvous_hip_1", "targetname");
	level.hip_2 = GetEnt("rendezvous_hip_2", "targetname");

	level.hip_1 thread enemy_hip_1_think();
	level.hip_2 thread enemy_hip_2_think();
}

enemy_hip_1_think()
{
	self endon("death");

	self SetForceNoCull();
	self.takedamage = true;
	self.health = 400;

	self thread enemy_hip_1_death_watcher();
	self thread hip_death_watcher();

	self waittill("reached_end_node");

	end_node = GetVehicleNode("hip_1_end_node", "targetname");
	look_node = spawn("script_origin", end_node.origin + AnglesToForward(end_node.angles) * 1000);

	self SetVehGoalPos(self.origin - (0,0,64), 1);
	self SetLookAtEnt(look_node);
	self waittill("goal");

	self SetHoverParams(25, 15, 8);
	self enemy_hip_rappel(4);

	flag_set("hip_1_rappel_done");

	look_node delete();

	self enemy_hip_strafe("rendezvous_strafe_1");

	player = get_players()[0];
	self.health = 400;
	self thread heli_engage(player, 1500, 500, 250, 500, 3, 4, "stop_engage", 1);
}

enemy_hip_1_death_watcher()
{
	level.vehicle_death_thread[self.vehicletype] = maps\underwaterbase_snipe::heli_crash_think;

	self waittill("death");

	Objective_AdditionalPosition(level.curr_obj_num, 1, (0,0,0));
	flag_set("destroyed_enemy_hind_1");

	level.hips_killed++;
}

enemy_hip_2_think()
{
	self SetForceNoCull();
	self thread enemy_hip_2_death_watcher();
	self thread hip_death_watcher();

	self.takedamage = true;

	flag_wait("hip_fire");

	self thread enemy_hip_fire_player();

	self waittill("reached_end_node");

	self notify("done_strafing");

	player = get_players()[0];
	self.takedamage = true;
	self.health = 400;
	self thread heli_engage(player, 1000, 700, 150, 300, 4, 5, "stop_engage", 1);
}

enemy_hip_2_death_watcher()
{
	level.vehicle_death_thread[self.vehicletype] = maps\underwaterbase_snipe::heli_crash_think;

	self waittill("death");

	Objective_AdditionalPosition(level.curr_obj_num, 2, (0,0,0));
	flag_set("destroyed_enemy_hind_2");

	level.hips_killed++;
}

enemy_hip_2_destroy_huey()
{
	level.support_huey endon("death");

	flag_wait("rendezvous_hip_fire_rockets");

	player = get_players()[0];
	self.firing = false;
	while (IsAlive(level.support_huey))
	{
		for(i = 0; i < 4; i++)
		{
			//"tag_rocket1-4"
			rocket = MagicBullet("huey_rockets", self GetTagOrigin("tag_rocket" + (i + 1)), level.support_huey.origin - (0,0,100));
			rocket thread rocket_rumble_when_close(player);
			wait(0.15);
		}

		wait(3);
	}
}

enemy_hip_rappel(num_guys)
{
	self endon("death");

//	look_at = spawn("script_origin", self.origin + AnglesToForward(self.angles) * 500);
//	self SetLookAtEnt(look_at);

	rappel_struct_left = SpawnStruct();
	rappel_struct_left.origin = self GetTagOrigin("tag_enter_gunner");
	rappel_struct_left.targetname = "rendezvous_hip_1_rappel_left";

	self thread enemy_hip_rappel_death_watcher(rappel_struct_left);

	rappel_struct_right = SpawnStruct();

	// project the delta vector from the origin to the left struct pos onto the right vector
	delta = rappel_struct_left.origin - self.origin;
	dist = Abs(VectorDot(delta, AnglesToRight(self.angles)));

	// move the right struct to the exact spot on the other side
	rappel_struct_right.origin = rappel_struct_left.origin + AnglesToRight(self.angles) * (2.0 * dist);
	rappel_struct_right.targetname = "rendezvous_hip_1_rappel_right";

	rappel_spawner = GetEnt("rendezvous_enemies_rappellers", "targetname");
	rappel_spawner.count = 20;

	create_rope = true;
	delete_rope = false;
	while (num_guys > 0)
	{
		if (num_guys == 1)
		{
			delete_rope = true;
		}

		new_guy_left = simple_spawn_single(rappel_spawner);
		new_guy_left.target = "rendezvous_hip_1_rappel_left";
		new_guy_left thread maps\_ai_rappel::start_ai_rappel(2, rappel_struct_left, create_rope, delete_rope);

//		wait(RandomFloatRange(0.25, 0.5));
//
//		new_guy_right = simple_spawn_single(rappel_spawner);
//		new_guy_right.target = "rendezvous_hip_1_rappel_right";
//		new_guy_right thread maps\_ai_rappel::start_ai_rappel(2, rappel_struct_right, create_rope, delete_rope);

		create_rope = false;
		num_guys--;

		wait(RandomFloatRange(1.5, 2.0));
	}

	self notify("hip_rappel_done");
	rappel_struct_left notify("rappel_done");
}

enemy_hip_rappel_death_watcher(rappel_struct)
{
	self endon("hip_rappel_done");

	rappel_struct thread rappel_struct_handle_rope_deletion();

	self waittill("death");

	rappel_struct notify("delete_rope");

	rappellers = get_ai_array("rendezvous_enemies_rappellers", "script_noteworthy");
	if (rappellers.size > 0)
	{
		array_notify(rappellers, "stop_rappel");
	}
}

enemy_hip_strafe(start_node)
{
	self endon("death");

	start = GetEnt(start_node, "targetname");
	end = GetEnt(start.target, "targetname");

	self SetSpeed(50, 25, 25);

	self SetVehGoalPos(start.origin);
	self SetLookAtEnt(start);

	self waittill("goal");

	// start firing after we've reached the first node
	self thread enemy_hip_strafe_fire();

	self SetVehGoalPos(end.origin, 1);
	self SetLookAtEnt(end);

	self waittill("goal");
	self notify("done_strafing");
}

enemy_hip_strafe_fire()
{
	self endon("done_strafing");
	self endon("death");

	while (true)
	{
		angles = self.angles;
		angles = (angles[0] + 45, angles[1], angles[2]);
		fir_dir = AnglesToForward(angles);

		self SetGunnerTargetVec(self.origin + fir_dir * 1000);
		self FireGunnerWeapon(0);
		wait(0.05);
	}
}

enemy_hip_fire_player()
{
	self endon("done_strafing");

	player = get_players()[0];
	while (true)
	{
		self SetGunnerTargetEnt(player);
		self FireGunnerWeapon(0);
		wait(0.05);
	}
}

support_huey_rappel()
{
	start_node = GetStruct("rendezvous_support_huey_start", "targetname");
	look_pos = start_node.origin + AnglesToForward(start_node.angles) * 1000;
	look_ent = spawn("script_origin", look_pos);

	self SetVehGoalPos(start_node.origin, 1);
	self SetLookAtEnt(look_ent);

	self.goalradius = 32;
	self waittill("goal");

	// spawn player squad
	spawners = GetEntArray("redezvous_player_squad", "targetname");
	squad = simple_spawn(spawners);
	for (i = 0; i < squad.size; i++)
	{
		squad[i] SetThreatBiasGroup("good_guys");
	}

	huey_rappel_tags = [];
	huey_rappel_tags[0] = "tag_passenger2";	
	huey_rappel_tags[1] = "tag_passenger5";	
	huey_rappel_tags[2] = "tag_passenger3";
	huey_rappel_tags[3] = "tag_passenger4";

	rappel_structs = [];

	for (i = 0; i < huey_rappel_tags.size; i++)
	{
		rappel_structs[i] = SpawnStruct();
		rappel_structs[i].origin = self GetTagOrigin(huey_rappel_tags[i]);
		rappel_structs[i].angles = self GetTagAngles(huey_rappel_tags[i]);
//		rappel_structs[i].targetname = huey_rappel_tags[i];

		rappel_structs[i].origin += AnglesToForward(rappel_structs[i].angles) * 64;
		rappel_structs[i].angles = (0,0,0);

		squad[i].target = huey_rappel_tags[i];
		squad[i] thread maps\_ai_rappel::start_ai_rappel(undefined, rappel_structs[i], true, true);
		squad[i] thread squad_go_formation();

		wait(0.25);
	}
}

support_huey_drop()
{
	huey_rappel_tags = [];
	huey_rappel_tags[0] = "tag_passenger2";	
	huey_rappel_tags[1] = "tag_passenger5";	
	huey_rappel_tags[2] = "tag_passenger3";
	huey_rappel_tags[3] = "tag_passenger4";

	// spawn player squad
	spawners = GetEntArray("redezvous_player_squad", "targetname");
	squad = simple_spawn(spawners);
	for (i = 0; i < squad.size; i++)
	{
		if (IsDefined(squad[i].script_string))
		{
			squad[i].target = huey_rappel_tags[i];
			squad[i] maps\_vehicle_aianim::vehicle_enter(self, squad[i].script_string);
		}

		squad[i] SetThreatBiasGroup("good_guys");
	}

	start_node = GetStruct("rendezvous_support_huey_start", "targetname");
	look_pos = start_node.origin + AnglesToForward(start_node.angles) * 1000;
	look_ent = spawn("script_origin", look_pos);

	self SetVehGoalPos(start_node.origin, 1);
	self SetLookAtEnt(look_ent);

	self.goalradius = 32;
	self waittill("goal");

	self SetJitterParams((10, 10, 10), 2, 3);
	self SetHoverParams(10, 5, 2.5);

	self maps\_vehicle::do_unload(0);

	array_thread(squad, ::squad_go_formation_2);

	wait(2.0);

	end_node = GetStruct("rendezvous_support_huey_end", "targetname");
	self SetVehGoalPos(end_node.origin, 1);
}

squad_go_formation()
{
	self disable_ai_color();
	self waittill("rappel_done");

	if (!flag("squad_go"))
	{
		self SetGoalNode(GetNode(self.target, "targetname"));
	}
}

squad_go_formation_2()
{
	self disable_ai_color();
//	self waittill("rappel_done");

	if (!flag("squad_go"))
	{
		self SetGoalNode(GetNode(self.target, "targetname"));
	}
}

hudson_under_ship_movement()
{
	self enable_cqbsprint();
	//self enable_cqbwalk();

	num_nodes = 6;
	
	nodes = [];
	for (i = 0; i < num_nodes; i++)
	{
		node_name = "hudson_rendezvous_node_" + (i + 1);
		nodes[i] = GetNode(node_name, "targetname");
	}

	self SetGoalNode(nodes[0]);
	flag_wait("head_toward_bow_objective_trigger");

	self SetGoalNode(nodes[1]);
	flag_wait("interior_3_objective");

	self SetGoalNode(nodes[2]);
	flag_wait("interior_4_objective");

	self SetGoalNode(nodes[3]);
	flag_wait("interior_5_objective");

	self SetGoalNode(nodes[4]);
	flag_wait("interior_6_objective");

	self SetGoalNode(nodes[5]);

	self waittill("goal");

	self disable_cqbsprint();
	self disable_cqbwalk();
}

hudson_crouch_walk()
{
	self waittill("goal");
	self AllowedStances("crouch");
	self waittill("get_up");
	self AllowedStances("stand", "crouch");
}

turn_off_water()
{
	flag_wait("turn_off_outside_ship_water");

	level notify("stop_water_ship_exterior");
	level.water_planes["ship_exterior"] delete();
}

manage_exploders()
{
	flag_wait("interior_1_objective");

	stop_exploder(102);
	stop_exploder(103);
	stop_exploder(104);
	stop_exploder(105);
	stop_exploder(106);
	wait( 0.1 );

	exploder(110);

	stop_exploder(81001);

	for (i = 120; i < 137; i++)
	{
		stop_exploder(i);
		if ( i % 5 )
		{
			wait( 0.05 );
		}
	}

	for (i = 71010; i < 71029; i++)
	{
		stop_exploder(i);
		if ( i % 5 )
		{
			wait( 0.05 );
		}
	}
}

dialogue()
{
	player = get_players()[0];
	player.animname = "mason";

	level notify("player_awesome_thread_done");

	flag_wait("squad_go");

	level.heroes["hudson"] anim_single(level.heroes["hudson"], "sit_rep");
	player anim_single(player, "deck_two");
	level.heroes["hudson"] anim_single(level.heroes["hudson"], "has_to_be");
	player anim_single(player, "keep_looking");

	flag_wait("enemy_hinds_arrive");

	level.heroes["hudson"] anim_single(level.heroes["hudson"], "shit_hips");
	level.heroes["hudson"] anim_single(level.heroes["hudson"], "guided_missile");
	
	flag_wait("player_got_tow");
	
	//SOUND - Shawn J
	clientnotify( "steam_go" );

	level.heroes["hudson"] anim_single(level.heroes["hudson"], "take_down_hips");

	trigger_wait("trig_rendezvous_allies_color_10");

	level.heroes["hudson"] anim_single(level.heroes["hudson"], "go");

	flag_wait("head_toward_bow_objective_trigger");
	
	//TUEY set's music to CALMER LOOP
	setmusicstate ("CALMER_LOOP");

	player anim_single(player, "need_to_see");
	level.heroes["hudson"] anim_single(level.heroes["hudson"], "what_is_it");
	player anim_single(player, "shit");
	player anim_single(player, "damn");
	level.heroes["hudson"] anim_single(level.heroes["hudson"], "weaver!");
	player anim_single(player, "asap");
	level.heroes["hudson"] anim_single(level.heroes["hudson"], "on_our_way");
	//SOUND - Shawn J
	clientnotify( "spools_moving" );
}

achievement_watcher()
{
	level.dead_hip_times = [];

	while (level.dead_hip_times.size != 2)
	{
		wait(0.05);
	}

//	IPrintLn("Time 0: " + level.dead_hip_times[0]);
//	IPrintLn("Time 1: " + level.dead_hip_times[1]);

	if (level.dead_hip_times[0] == level.dead_hip_times[1])
	{
//		IPRINTLNBOLD("ACHIEVEMENT!");
		player = get_players()[0];
		player giveachievement_wrapper("SP_LVL_UNDERWATERBASE_MINI");
	}
}

hip_death_watcher()
{
	self waittill("death");

	level.dead_hip_times[level.dead_hip_times.size] = GetTime();
}

do_phys_pulses()
{
	pulse_locations = GetStructArray("phys_pulse", "targetname");
	for (i = 0; i < pulse_locations.size; i++)
	{
		PhysicsExplosionCylinder( pulse_locations[i].origin, pulse_locations[i].radius, pulse_locations[i].radius, 0.2 );
		wait(0.1);
	}
}

handle_deck_end_door()
{
	trigger_wait("trig_rendezvous_allies_color_10");
	
	deck_end_door_state("open");

	flag_wait("interior_3_objective");

	deck_end_door_state("closed");
}

deck_end_door_state(state)
{
	clip = GetEnt("deck_end_door_clip", "targetname");
	door = GetEnt("deck_end_door", "targetname");

	if (state == "open")
	{
		clip NotSolid();
		clip ConnectPaths();
		door RotateYaw(door.angles[1] - 175, 2.0);
	}
	else if (state == "closed")
	{
		clip Solid();
		clip ConnectPaths();
		door.angles = (door.angles[0], door.angles[1] + 175, door.angles[2]);
	}
}

ship_deck_cleanup()
{
	flag_wait( "interior_3_objective" );

	// doh...bad place for this but it works
	level notify("stop_player_kill_check");
	level notify("enter_sea");
	flag_set( "deck_cleanup" );
	ClientNotify("stop_dynent_cleanup");
	ClientNotify("stop_dynent_monitor");
    p = get_players()[0];
    p PlayerSetGroundReferenceEnt( undefined );
    setPhysicsGravityDir( ( 0, 0, -800 ) );
	SetSavedDvar( "sm_sunAlwaysCastsShadow", 0 );
}
