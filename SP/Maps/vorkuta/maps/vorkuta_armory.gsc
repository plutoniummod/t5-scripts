#include maps\_utility;
#include maps\_vehicle_turret_ai;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_music;
#include maps\vorkuta_util;
#include maps\vorkuta;


armory_main()
{
	player = get_players()[0];
	
	level.reznov set_force_color("c");
	
	trigger_use("triggercolor_reznov_downstairs");

	//start allowing the ak47-gl to drop
	enable_random_alt_weapon_drops(); 
	
	player thread floor_tracker();
	
	level.reznov thread vo_reznov_armory_floor_1();
	level.reznov thread vo_reznov_armory_floor_2();
	level.reznov thread vo_reznov_defend();
	level.reznov thread vo_reznov_minigun();
	level.reznov thread reznov_down_alley();
		
	level thread armory_setup();
	level thread enter_armory();
	level thread setup_welder_prop();
		
	level thread shield_deployment();
	level thread end_delete_secondfloor();
	
	level thread e4_player_through_door_ai_management();
	level thread e4_spawn_functions();
	level thread e4_floor1_stairs();
	level thread e4_antinov_defend_squad_management();
	level thread e4_antinov_health_monitor();
	level thread e4_welding_timer();
	level thread e4_welding_vault_door_movement();
	
	level thread e4_rolling_door_closing();
	
	flag_wait("begin_alley");
}


armory_setup()
{
	trigger_to_armory = getent("squad_to_stairs", "targetname");
	trigger_to_armory trigger_on();
	
	shield1 = getent("tactical_shield1", "targetname");
	shield2 = getent("tactical_shield2", "targetname");
	clip_shield1 = getent("clip_tactical_shield1", "targetname");
	clip_shield2 = getent("clip_tactical_shield2", "targetname");
	
	clip_shield1 linkto(shield1);
	clip_shield2 linkto(shield2);
	
	walkway_before = getentarray("armory_entrance", "targetname");
	for(i=0; i<walkway_before.size; i++)
	{
		if (isdefined(walkway_before[i]))
		{
			walkway_before[i] delete();
		}
	}
	
	walkway = getentarray("armory_entrance_model", "targetname");
	for(i=0; i<walkway.size; i++)
	{
		if (isdefined(walkway[i]))
		{
			walkway[i] delete();
		}
	}
	
	walkway_after = getentarray("armory_entrance_destroyed", "targetname");
	for(i=0; i<walkway_after.size; i++)
	{
		if (isdefined(walkway_after[i]))
		{
			walkway_after[i] connectpaths();
			walkway_after[i] show();
		}
	}
	
	walkway_dest = getentarray("armory_entrance_destroyed_model", "targetname");
	for(i=0; i<walkway_dest.size; i++)
	{
		if (isdefined(walkway_dest[i]))
		{
			walkway_dest[i] show();
		}
	}
	
	guys = getaiarray("axis");
	for (i=0; i<guys.size; i++)
	{
		guys[i] delete();
	}
	
	door_clean = getent("roll_up_door", "targetname");
	door_dest = getent("roll_up_door_destroyed", "targetname");
	
	door_dest hide();
	
	trigger_btr_reinforce = getent("trigger_btr_reinforcement", "targetname");
	trigger_btr_reinforce trigger_off();
	
	triggerwindow = getent("trigger_reznov_window", "targetname");
	triggerwindow trigger_off();
	
	armory_wall1 = getent("armory_backwall_destroyed_01", "targetname");
	armory_wall2 = getent("armory_backwall_destroyed_02", "targetname");
	armory_wall3 = getent("armory_backwall_destroyed_03", "targetname");
	armory_wall4 = getent("armory_backwall_destroyed_04", "targetname");
	
	armory_wall1 hide();
	armory_wall2 hide();
	armory_wall3 hide();
	armory_wall4 hide();
	
	dest = getentarray("armory_back_door_destroyed", "targetname");
	for(i=0; i<dest.size; i++)
	{
		dest[i] hide();
	}
	
	triggerswroom = getent("trigger_playerin_swroom", "targetname");
	triggerswroom trigger_off();
	
	clip_rolldoor = getent("clip_player_rolldoor", "targetname");
	clip_rolldoor trigger_off();
	
	door_button = getent("door_button_after", "targetname");
	door_button hide();
}


enter_armory()
{
	array_thread(getentarray("armory_rush", "targetname"), ::add_spawn_function, ::setup_armory_rush);
	array_thread(getentarray("armory_straggler", "targetname"), ::add_spawn_function, ::setup_armory_rush);
	array_thread(getentarray("prisoner_with_player", "targetname"), ::add_spawn_function, ::setup_prisoner_rush);
	array_thread( GetEntArray("first_floor_armory", "targetname"), ::add_spawn_function, ::setup_first_defense);
	array_thread( GetEntArray("prisoner_first_fight", "targetname"), ::add_spawn_function, ::setup_first_defense);
	array_thread( GetEntArray("prisoner_upstairs", "targetname"), ::add_spawn_function, ::setup_secondfloor_rush);
	array_thread( GetEntArray("prisoner_rolldoor", "targetname"), ::add_spawn_function, ::setup_prisoner_rolldoor);
	array_thread( GetEntArray("button_attacker", "targetname"), ::add_spawn_function, ::setup_button_attacker);
	
	add_spawn_function_veh( "gaz_gate", ::play_vehicle_arrival_audio, "truck" );
	add_spawn_function_veh( "motor_1", ::play_vehicle_arrival_audio, "moto" );
	add_spawn_function_veh( "motor_2", ::play_vehicle_arrival_audio, "moto" );
	
	spawn_manager_enable("manager_armory_rush");
	
	level thread spawn_stragglers();
	level thread delete_armory_rush();
	level thread reznov_to_armory();
	
	trigger_wait("trigger_courtyard_exit");
	
	spawn_manager_enable("manager_prisoner_first_fight");
	spawn_manager_enable("manager_first_floor_armory");
	
	guys = getaiarray("allies");
	for (i=0; i<guys.size; i++)
	{
		guys[i] notify("end_delete");
	}
}


setup_prisoner_rolldoor()
{
	self endon("death");
	
	retreat_pos = getstruct("retreat_pt", "targetname");
	
	self.goalradius = 64;
	
	self setgoalpos(retreat_pos.origin + (RandomIntRange(-50, 200), RandomIntRange(-100, 100), 0));
	
	flag_wait("player_opened_rolling_door");
	
	set_force_color("o");
}


setup_button_attacker()
{
	self endon("death");
	
	self.ignoresuppression = true;
	self.goalradius = 16;
	
	self waittill("goal");
	
	wait(0.1);
	
	self.goalradius = 16;
	self.ignoresuppression = false;
	
	flag_wait("player_opened_rolling_door");
	
	self.goalradius = 2048;
}


spawn_stragglers()
{
	level endon("delete_rush");
	
	waittill_spawn_manager_complete("manager_armory_rush");
	
	spawn_manager_enable("manager_armory_straggler");
}


delete_armory_rush()
{
	//set on the trigger leaving the helicopter building
	flag_wait("delete_rush");
	
	spawn_manager_kill("manager_armory_rush");
	spawn_manager_kill("manager_armory_straggler");
}

reznov_to_armory()
{
	trigger_wait("squad_to_stairs");
	
	spawn_manager_enable("manager_prisoner_with_player");
}

setup_armory_rush()
{
	self endon("death");
	self endon("delete_rush");
		
	self.ignoreall = true;
	self.disablearrivals = true;
	self waittill("goal");
	trigger = getent("trigger_armory_entered", "targetname");
	self setgoalpos(trigger.origin + (RandomIntRange(0, 100), RandomIntRange(-100, 0), 0));
	self waittill("goal");

	//delete the AI if they are out of LOS, otherwise kill them or it will be too crowded
	if(flag("flag_kill_armory_stragglers"))
	{
		self bloody_death();
	}
	else
	{
		self delete();
	}
}


setup_prisoner_rush()
{
	self endon("death");
	
	self.disablearrivals = true;
	
	self waittill("goal");
	self waittill("goal");
	
	self.disablearrivals = false;
}


setup_first_defense()
{
	self endon("death");
	
	self thread shield_until_player();
	
	self.ignoresuppression = true;
	self.goalradius = 16;
	
	self waittill("goal");
	
	wait(0.1);
	
	self.goalradius = 16;
	self.ignoresuppression = false;
	
	flag_wait_any("shield1_dead", "shield2_dead");
	
	self.goalradius = 2048;
}


shield_until_player()
{
	self endon("death");
	
	self magic_bullet_shield();
	
	flag_wait("player_on_1st_floor_armory");
	
	self stop_magic_bullet_shield();
}


shield_deployment()
{
	shield_nodes = GetNodeArray("riot_shield_node","script_noteworthy");
	for(i = 0; i < shield_nodes.size; i++)
	{
		SetEnableNode(shield_nodes[i], false);
	}

	trigger_wait("trigger_armory_entered");
	
	//disables fx playing on the player
	level.outdoor = false;

	shield_1 = shield_setup("tactical_shield1");
	shield_2 = shield_setup("tactical_shield2");
	
	//set on a trigger_lookat inside the armory
	flag_wait("tactical_shield");

	level thread reinforce_first_floor();	
	level thread shield_deploy(shield_1, shield_2);
	
	waittill_ai_group_cleared("group_first_floor");
	
	flag_wait("shield1_dead");
	flag_wait("shield2_dead");
	
	spawn_manager_enable("manager_prisoner_upstairs");
	spawn_manager_kill("manager_prisoner_with_player");
}

shield_setup(targetname)
{
	shield = GetEnt(targetname,"targetname");
	shield.clip = GetEnt("clip_" + targetname, "targetname");
	shield.clip LinkTo(shield);
	
	shield.moving = false;
	shield.stop = false;
	shield.guards = simple_spawn(shield.target, ::shield_guard_think, shield);

	shield thread shield_monitor();

	return shield;
}

shield_deploy(shield_1, shield_2)
{
	shield_1 MoveX(-128, 1.5, .25, .25);
	shield_1 shield_move();

	wait(0.3);
	
	shield_2 MoveX(-218, 3.5, 1.75, 1.75);
	shield_2 shield_move();

	flag_set("go_shields");

	if(!shield_2.stop)
	{
		shield_2 MoveY(250, 3, 1.5, 1.5);
		shield_2 shield_move();
	}

	wait(0.3);

	if(!shield_1.stop)
	{
		shield_1 MoveY(250, 3, 1.5, 1.5);
		shield_1 shield_move();
	}

	num_moves = 2;
	for(i = 0; i < num_moves; i++)
	{
		if(!shield_2.stop)
		{
			shield_2 MoveY(125, 2.0, 1, 1);
			shield_2 shield_move(true);
			shield_nodes = GetNodeArray("shield_2_" + i,"script_noteworthy");
			for(i = 0; i < shield_nodes.size; i++)
			{
				SetEnableNode(shield_nodes[i], true);
			}
		}
		wait(1.0);
		if(!shield_1.stop)
		{
			shield_1 MoveY(125, 2.0, 1, 1);
			shield_1 shield_move(true);
			shield_nodes = GetNodeArray("shield_1_" + i,"script_noteworthy");
			for(i = 0; i < shield_nodes.size; i++)
			{
				SetEnableNode(shield_nodes[i], true);
			}
		}
		wait(1.0);
	}
	shield_1.stop = true;
	shield_2.stop = true;
}

//handles sound, animation, and pathing of a shield moving
shield_move(engage)
{
	self RotateRoll(5, 0.5);

	//self.guards[0].anim_origin thread anim_generic_loop_aligned(self.guards[0], "shield_push");
	//self.guards[1].anim_origin thread anim_generic_loop_aligned(self.guards[1], "shield_push");

	self.moving = true;
	self PlayLoopSound( "evt_shield_loop", .1 );
	self waittill("movedone");
	self StopLoopSound(.1);
	self.clip DisconnectPaths();
	self RotateRoll(-5, 0.5);
	self waittill("rotatedone");
	self.moving = false;


	if(IsDefined(engage) && engage)
	{
		//self.guards[0].anim_origin thread anim_generic_loop_aligned(self.guards[0], "shield_right_shoot_low");
		//self.guards[1].anim_origin thread anim_generic_loop_aligned(self.guards[1], "shield_left_shoot_low");
	}
}

shield_monitor()
{
	//grab the player to detect distance
	player = get_players()[0];

	//while the player is a safe distance and both guards are alive on the self
	while( (self.guards.size > 1) && (Distance2D(player.origin, self.origin) > 400) )
	{
		//update array of guards to remove the dead
		self.guards = array_removeDead(self.guards);
		wait(0.05);
	}

	//set the flag on the entity so it will stop moving
	self.stop = true;

	if(self.targetname == "tactical_shield1")
	{
		flag_set("shield1_dead");
	}
	else
	{
		flag_set("shield2_dead");
	}	
}


shield_guard_think(shield)
{
	self endon("death");
	
	self.goalradius = 32;
	self.ignoreall = true;
	self gun_remove();
	self disable_pain();
	
	self.anim_origin = spawn_a_model("tag_origin", self.origin + (25,110,0), self.angles + (0,90,0));
	self.anim_origin LinkTo(shield);
	self LinkTo(self.anim_origin);

	wait(RandomFloat(1.0));

	self.allowdeath = true;
	self.anim_origin thread anim_generic_loop_aligned(self, "shield_push");
	
	//shields are in position to move forward
	flag_wait("go_shields");
	
	while(!shield.stop || shield.moving)
	{
		wait(0.05);
	}

	self StopAnimScripted();
	self unlink();
	self.anim_origin Delete();

	wait(0.3);
	self gun_recall();
	self enable_pain();
	self.ignoreall = false;
	self set_goal_pos(self.origin);
	//self.goalradius = 128;
}

reinforce_first_floor()
{
	flag_wait("first_floor");
	
	simple_spawn("first_floor_guard");
}

setup_fallguy()
{
	self.goalradius = 64;
	self.ignoreall = true;
	self.ignoreme = true;
	self.animname = "stair_guy";
	self magic_bullet_shield();
	self gun_remove();
		
	self thread fallguy_right();
	self thread fallguy_left();
}


fallguy_right()
{
	self endon("death");
	self endon("fallen_left");
	
	trigger_wait("trigger_fallguy_right");
	self PlaySound( "dds_ru0_death" );
	self PlaySound( "fly_guy_stair_tumble" );
	
	spawn_manager_enable("manager_fallback");
	
	self stop_magic_bullet_shield();
	self notify("fallen_right");
	
	pos = getstruct("pos_fallguy", "targetname");

	fire = getstruct("fire_fallguy_pos", "targetname");
			
	pos thread anim_single_aligned(self, "stairdeath");
	
	wait(0.8);
	
	MagicBullet("ks23_sp", fire.origin, self.origin + (0, 0, 40));
	playfx(	level._effect["bloody_hit"], self.origin + (0, 0, 40));
}


fallguy_left()
{
	self endon("death");
	self endon("fallen_right");
	
	trigger_wait("trigger_fallguy_left");
	self PlaySound( "dds_ru0_death" );
	self PlaySound( "fly_guy_stair_tumble" );
	
	spawn_manager_enable("manager_fallback");
	
	self stop_magic_bullet_shield();
	self notify("fallen_left");
	
	pos = getstruct("pos_fallguy", "targetname");
	
	fire = getstruct("fire_fallguy_pos", "targetname");
			
	pos thread anim_single_aligned(self, "stairdeath_left");
	
	wait(0.8);
	
	MagicBullet("ks23_sp", fire.origin, self.origin + (0, 0, 40));
	playfx(	level._effect["bloody_hit"], self.origin + (0, 0, 40));
}


setup_fallback()
{
	self.pathEnemyFightDist = 32;
	self.goalradius = 16;
	
	self waittill("goal");
	
	self.pathEnemyFightDist = 350;
}


setup_secondfloor_rush()
{
	self endon("death");
	self endon("end_second_delete");
	
	self.goalradius = 16;
	//self.disablearrivals = true;
	
	self waittill("goal");
	
	//self set_spawner_targets("cover_prisoner_hallway");
	
	//self thread delete_upon_secondfloor();
	
	if (!flag("end_secondfloor"))
	{
		self delete();
	}
		
	//self.disablearrivals = false;
}


delete_upon_secondfloor()
{
	self endon("death");
	self endon("end_second_delete");
	
	self.goalradius = 16;
	
	//self waittill("goal");
	
	if (!flag("end_secondfloor"))
	{
		self delete();
	}
}


end_delete_secondfloor()
{
	level endon("player_rolled");
	
	trigger_wait("trigger_fallguy");
	
	flag_set("end_secondfloor");
	
	spawn_manager_enable("manager_hall_defense");
	spawn_manager_enable("manager_prisoner_stalemate");
	
	flag_wait("unleash_hall_defense");
	
	flag_wait_or_timeout("kill_hall_defense", 25);
	flag_set("kill_hall_defense");	
	spawn_manager_kill("manager_hall_defense");
	
	triggercolor = getent("trigger_delete_friendly", "targetname");
	triggercolor trigger_off();
	
	level thread e4_armory_siren();
	clientNotify( "rotate_lights" );
	
	//have all remaining enemies attempt to run under the door but die in the process	
	guards = getaiarray("axis");
	for (x=0; x<guards.size; x++)
	{
		if (isAlive(guards[x]))
		{
			guards[x] thread hall_defense_fallback();
		}
	}
	
	//TUEY set music to SERGEI_DOOR
	setmusicstate ("SERGEI_DOOR");

	//don't move up the friendlies until the player starts the door slide
	trigger_wait("trigger_under_door");
	
	trigger_use("squad_to_door_area");
	
	wait(0.5);
	
	guys = getaiarray("allies");
	guys = array_exclude(guys, level.reznov);
	
	retreat_pos = getstruct("retreat_pt", "targetname");
	
	advancer_array = [];
	
	num = advancer_array.size;
	
	while(num < 5)
	{
		guys = getaiarray("allies");
		guys = array_exclude(guys, advancer_array);
		
		advancer = getclosest(retreat_pos.origin, guys);
		
		if (isdefined(advancer))
		{
			advancer thread advance_to_door();
			advancer_array = array_add(advancer_array, advancer);
		}
		
		num = advancer_array.size;
						
		wait(0.3);
	}
}


hall_defense_fallback()
{
	self endon("death");
	
	retreat_pos = getstruct("roll_pos", "targetname");
	
	wait(RandomFloatRange(0.1, 0.4));

	self thread force_goal(retreat_pos.origin, 32);

	self waittill_notify_or_timeout("goal", RandomFloatRange(2.0, 5.0) );

	tags = [];
	tags[0] = "j_hip_le";
	tags[1] = "j_hip_ri";
	tags[2] = "j_head";
	tags[3] = "j_spine4";
	tags[4] = "j_elbow_le";
	tags[5] = "j_elbow_ri";
	tags[6] = "j_clavicle_le";
	tags[7] = "j_clavicle_ri";

	random = RandomInt(tags.size);
	PlayFxOnTag( level._effect["bloody_death"][1], self, tags[random] );
	self PlaySound ("prj_bullet_impact_large_flesh");
	self DoDamage( self.health + 100, self.origin);
}


advance_to_door()
{
	self endon("death");
	
	retreat_pos = getstruct("retreat_pt", "targetname");
	
	wait(RandomFloatRange(0.1, 0.3));
	
	self.goalradius = 64;
	self.ignoresuppression = true;
	self.grenadeawareness = false;
	self disable_pain();
	self disable_react();
	self.old_pathenemyFightdist = self.pathenemyFightdist;
	self.pathenemyFightdist=64;
	
	x = RandomIntRange(-100, 0);
	y = RandomIntRange(-100, 100);
	
	self setgoalpos(retreat_pos.origin + (x, y, 0));
	
	self waittill("goal");
	
	self.ignoresuppression = false;
	self.grenadeawareness = true;
	self enable_pain();
	self enable_react();
	self.pathenemyFightdist = self.old_pathenemyFightdist;
	
	num = RandomIntRange(1, 11);
	
	guys = getaiarray("axis");
	
	while(guys.size > 0)
	{
		guys = getaiarray("axis");
		wait(0.1);
	}
	
	door = getent("sergei_door", "targetname");
	self aim_at_target(door);
	
	flag_wait("player_rolled");
	
	self stop_aim_at_target();
}


setup_hall_defense()
{
	self endon("death");
	
	self thread stalemate_wait_player();
	
	self.goalradius = 16;
	
	self waittill("goal");
	
	wait(0.1);
	
	self.goalradius = 16;
}


e4_spawn_functions()
{
	array_thread( GetEntArray("covering_fire_guys" , "targetname"), ::add_spawn_function, ::e4_covering_fire_guys_logic);
		
	array_thread( GetEntArray("hallway_runner" , "targetname"), ::add_spawn_function, ::e4_hallway_runner_logic);
		
	array_thread( GetEntArray("repel_guy" , "targetname"), ::add_spawn_function, maps\_ai_rappel::start_ai_rappel, undefined, undefined, true);
	array_thread( GetEntArray("rappeler" , "targetname"), ::add_spawn_function, maps\_ai_rappel::start_ai_rappel, undefined, undefined, true);
		
	//enemies come in while antinov welds. 
	array_thread( GetEntArray("weld_upstairs_attacker" , "targetname"), ::add_spawn_function, ::e4_weld_upstairs_attacker_logic);
	
	//guys run by window in welding equipment room
	array_thread( GetEntArray("heavy_escort" ,"targetname"), ::add_spawn_function, ::setup_heavy_escort);

	//guy in the hallway on the way back
	array_thread( GetEntArray("extra_bridge", "targetname"), ::add_spawn_function, ::setup_extra_bridge);
	
	//guys on the roof after star wars room
	array_thread( GetEntArray("bridge_ambush", "targetname"), ::add_spawn_function, ::setup_bridge_autodeath);
	
	array_thread( GetEntArray("fallguy" ,"targetname"), ::add_spawn_function, ::setup_fallguy);
	array_thread( GetEntArray("fallback" ,"targetname"), ::add_spawn_function, ::setup_fallback);
	array_thread( GetEntArray("hall_defense" ,"targetname"), ::add_spawn_function, ::setup_hall_defense);
	array_thread( GetEntArray("prisoner_stalemate" ,"targetname"), ::add_spawn_function, ::setup_hall_offense);
	
	array_thread( GetEntArray("minigun_victim_heavy" ,"targetname"), ::add_spawn_function, ::setup_stormtrooper_heavy);
	array_thread( GetEntArray("heavy" ,"targetname"), ::add_spawn_function, ::setup_stormtrooper_heavy);
		
	array_thread( GetEntArray("rebel_soldier" ,"targetname"), ::add_spawn_function, ::setup_rebel);
	
	array_thread( GetEntArray("button_troops_right" ,"targetname"), ::add_spawn_function, ::setup_button_troops);

	//defend event weapon drop check
	array_thread( GetEntArray("heavy","targetname") , ::add_spawn_function, ::defend_reznov_weapon_drop_check);
	array_thread( GetEntArray("first_floor_defend","targetname") , ::add_spawn_function, ::defend_reznov_weapon_drop_check);
	
	//gaz gunners
	add_spawn_function_veh("gaz_gunner_1", ::armory_exit_gaz_gunner_1);
	add_spawn_function_veh("gaz_gunner_2", ::armory_exit_gaz_gunner_2);
	add_spawn_function_veh("gaz_alley", ::truck_monitor);
	
	//gaz that drives in on the catwalk
	add_spawn_function_veh("gaz_gate", ::setup_gaz_gate);
}


setup_gaz_gate()
{
	self endon("gaz_gate_destroyed");
	
	self thread monitor_gaz_gate();
}


monitor_gaz_gate()
{
	self.health = 20000;
	
	while( self.health > 15000)
	{
		wait(0.05);
	}
	
	self notify("gaz_gate_destroyed");
	
	self PlaySound( "evt_truck_explo" );
	playfx(	level._effect["truck_explosion"], self.origin);
	PlayFXOnTag (level._effect["truck_explosion_linked"], self, "tag_origin");
	
	self ClearVehGoalPos();
	
	force = AnglesToRight(self.angles) * 165;
	hitpos = (50, -50, 0);
	
	self LaunchVehicle(force, hitpos, true, true);
	
	RadiusDamage(self.origin, 100, self.health, self.health);
	
	self setspeedimmediate(0, 15, 5);
	
	self ClearVehGoalPos();
	
	wait(2.0);
	
	self disconnectpaths();
}

setup_button_troops()
{
	self endon("death");
	
	self.ignoreall = true;
	
	wait(4.0);
	
	self.ignoreall = false;
}


setup_hall_offense()
{
	self endon("death");
	
	self magic_bullet_shield();
	
	flag_wait("unleash_hall_defense");  //set by trigger
	
	self stop_magic_bullet_shield();
}


stalemate_wait_player()
{
	self endon("death");
	
	self magic_bullet_shield();
	
	flag_wait("unleash_hall_defense");  //set by trigger
	
	self stop_magic_bullet_shield();
}


setup_armory_defend()
{
	self endon("death");
	
	self.goalradius = 300;
	
	guys = getaiarray("allies");
	player = get_players()[0];
	
	targets = array(guys, player);
	
	self setgoalentity(targets[RandomIntRange(0, targets.size)]);
}


setup_heavy_escort()
{
	self endon("death");

	//looks bad when the gun takes over aiming at the door
	self DisableAimAssist();
	
	self.goalradius = 16;
	self.ignoreme = true;
	self.ignoreall = true;
	self waittill("goal");
	self delete();
}


e4_weld_upstairs_attacker_logic()
{
	//self = guy attacking while antinov welds
	self endon ("death");
	self.script_accuracy = .6;
	self.goalradius = 32;
	self.a.disableLongDeath = true;
	
	if(self.script_noteworthy == "catwalk")
	{
		self set_spawner_targets ("catwalk_stop");
		self waittill ("goal");
		wait RandomIntRange (6, 8);
		self set_spawner_targets ("attack_antinov");
		self thread go_no_matter_what();
	}
	else
	{
		set_spawner_targets("left_pos_1");
		self waittill ("goal");
		wait RandomIntRange (6, 8);
		self set_spawner_targets ("attack_antinov");
		self thread go_no_matter_what();
	}
		
}
	

e4_armory_siren()
{
	level endon("rez_closed_door");
	
	siren = getentarray("rotating_light", "targetname");
	
	array_thread( getstructarray( "audio_armory_alarms", "targetname" ), ::play_armory_alarm_audio );
	level thread stop_looper();
	
	for(i=0; i<siren.size; i++)
	{
		siren[i] thread rotate_siren();
		//siren[i] PlayLoopSound( "amb_armory_alarm", 1 );
		wait(0.2);
	}
}


rotate_siren()
{
	self endon("death");
	
	while(1)
	{
		self RotateYaw (360, 1);
		wait(0.95);	
	}
}


stop_looper()
{
    flag_wait( "rez_closed_door" );
    
    siren = getentarray("rotating_light", "targetname");
    
    for(i=0; i<siren.size; i++)
	{
		siren[i] delete();
	}
}	


e4_hallway_runner_logic()
{
	self endon ("death");
	self.goalradius = 32;
	self waittill ("goal");
	self Delete();
}	


e4_floor1_stairs()
{
	flag_wait("player_rolled");
	
	level thread defend_armory_spawners();
	level thread delete_friendlies_hallway();
	
	wait(1.0);
	
	spawn_manager_enable("manager_prisoner_rolldoor");
}


delete_friendlies_hallway()
{
	guys1 = getentarray("prisoner_stair_left_ai", "targetname");
	guys2 = getentarray("prisoner_stair_right_ai", "targetname");
	guys3 = getentarray("prisoner_upstairs_ai", "targetname");
	guys4 = getentarray("prisoner_stalemate_ai", "targetname");
	
	for (i=0; i<guys1.size; i++)
	{
		if (isdefined(guys1[i]))
		{
			guys1[i] delete();
		}
	}
	for (j=0; j<guys2.size; j++)
	{
		if (isdefined(guys2[j]))
		{
			guys2[j] delete();
		}
	}
	for (k=0; k<guys3.size; k++)
	{
		if (isdefined(guys3[k]))
		{
			guys3[k] delete();
		}
	}
	for (l=0; l<guys4.size; l++)
	{
		if (isdefined(guys4[l]))
		{
			guys4[l] delete();
		}
	}
}


e4_covering_fire_guys_logic()
{
	//self = AI in the hall covering the "stairs_enemies"
	self endon ("death");
	self.goalradius = 24;
	//corky wants the player to see these guys retreat is possible	
	self.health = 180;
	self waittill ("goal");
	wait(RandomIntRange(10,15) );
	
	self set_spawner_targets("2nd_story_interior_attack");
	self thread go_no_matter_what();
	flag_set ("covering_fire_guys_retreating");
}


floor_tracker()  //self = player
{
	self endon("death");
	
	//wait for player to go inside and trigger first enemeies
	trigger_wait("trigger_armory_entered");
	level thread maps\vorkuta_amb::activate_fake_friendly_dds();
	
	level thread first_hall_gunfire();
	level thread prisoner_firstfloor_moveup();
	
	flag_set ("player_on_1st_floor_armory");
	
	flag_wait("player_second_floor");
	
	autosave_by_name("2nd_floor");
	
	flag_wait("unleash_hall_defense");
	
	level thread delete_first_floor();
	
	trigger_wait("trigger_third_floor");
	
	//check to see if the button was pushed
	if (!flag("player_opened_rolling_door"))
	{
		level.reznov notify ("end_vo");
		level.reznov anim_single(level.reznov, "nooo"); //Nooo!!!
		
		SetDvar( "ui_deadquote", &"VORKUTA_SERGEI_DOOR_FAIL" ); 
		missionFailedWrapper();
	}
	else
	{
		flag_set("player_3rd_floor");
	}
}


first_hall_gunfire()
{
	gunfire = getstruct("pos_hall_gunfire", "targetname");
	trgt = gunfire.origin + (0, 900, 0);
	
	for (i=0; i<30; i++)
	{
		start = gunfire.origin + (RandomIntRange(-70, 70), 0, RandomIntRange(-16, 0));
		end = gunfire.origin + (RandomIntRange(-100, 100), 900, RandomIntRange(-24, 24));
		MagicBullet("ak47_sp", start, end);
		wait(RandomFloatRange(0.05, 0.2));
	}
}


prisoner_firstfloor_moveup()
{
	flag_wait("shield1_dead");
	flag_wait("shield2_dead");
	
	guys = getaiarray("allies");
	guys = array_exclude(guys, level.reznov);
	
	for (i=0; i<guys.size; i++)
	{
		if (isdefined(guys[i]))
		{
			guys[i] set_force_color("b");
		}
	}
	
	wait(0.5);
	
	trigger_use("triggercolor_advance_armory");
}


delete_first_floor()
{
	guys1 = getentarray("armory_rush1_ai", "targetname");
	guys2 = getentarray("armory_rush2_ai", "targetname");
	guys3 = getentarray("armory_rush3_ai", "targetname");
	guys4 = getentarray("armory_straggler_ai", "targetname");
	guys5 = getentarray("prisoner_first_fight_ai", "targetname");
	guys6 = getentarray("prisoner_with_player_ai", "targetname");
	
	for(i=0; i<guys1.size; i++)
	{
		if (isdefined(guys1[i]))
		{
			guys1[i] delete();
		}
	}
	for(j=0; j<guys2.size; j++)
	{
		if (isdefined(guys2[j]))
		{
			guys2[j] delete();
		}
	}
	for(k=0; k<guys3.size; k++)
	{
		if (isdefined(guys3[k]))
		{
			guys3[k] delete();
		}
	}
	for(x=0; x<guys4.size; x++)
	{
		if (isdefined(guys4[x]))
		{
			guys4[x] delete();
		}
	}
	for(y=0; y<guys5.size; y++)
	{
		if (isdefined(guys5[y]))
		{
			guys5[y] delete();
		}
	}
	for(z=0; z<guys6.size; z++)
	{
		if (isdefined(guys6[z]))
		{
			guys6[z] delete();
		}
	}
}


e4_player_through_door_ai_management()
{
	//armory door trigger
	trigger_wait("trigger_armory_entrance");
	
	flag_set("door_event_over");//so the nag loop stops
	
	flag_set("player_in_armory");

	//turn on the clip
	clip_rolldoor = getent("clip_player_rolldoor", "targetname");
	clip_rolldoor trigger_on();
	
	//wait for the player to push the button
	flag_wait("player_opened_rolling_door");

	//open the door back up
	pos = getstruct("pos_sergei_door", "targetname");
	sergei_rolldoor = getent("sergei_roll_door", "targetname");
	pos thread anim_single_aligned(sergei_rolldoor, "door_open");
		
	door_button_glo = getent("door_button_before", "targetname");
	door_button_glo delete();
	
	door_button = getent("door_button_after", "targetname");
	door_button show();
	
	spawn_manager_kill("manager_button_attacker");
	
	//send squad inside!
	wait(2.0);
	
	trigger_use("triggercolor_enter_rolldoor");
	
	wait(5.0);
	
	flag_set("go_upstairs");
	
	spawn_manager_kill("manager_prisoner_rolldoor");
	
	trigger_use("reznov_up_stairs");
	
	wait(1.0);
	
	trigger_use("triggercolor_guard_doorways");
	
	flag_set ("rez_closed_door");
	flag_set("armory_defend_started");
	
	level thread play_roof_footsteps_audio();
	
	//close the door again
	wait(1);
	pos = getstruct("pos_sergei_door", "targetname");
	pos anim_single_aligned(sergei_rolldoor, "door_close");

	rolling_door_ai();

	//clean up exploders in courtyard and 1st part of armory
	stop_exploder(1600);
	stop_exploder(1700);
}

e4_rolling_door_closing()
{
	//self = rolling door top and bottom
	level endon ("player_opened_rolling_door"); //needs to be interuptable when player hits button to to open door
	
	trigger_wait ("player_in_front_of_armory");
	
	spawn_manager_kill("manager_prisoner_upstairs");
	
	door = getent("sergei_door", "targetname");
	door rotateyaw(120, 0.6);
	door connectpaths();
	
	level.sergei = simple_spawn_single("sergei_armory", ::setup_sergei_door);
		
	level thread player_under_door();
}

setup_sergei_door()
{
	addNotetrack_flag( "sergei", "stop_hero", "sergei_dead", "door_end" );
	addNotetrack_FXOnTag( "sergei", "door_end", "cough", "cough_blood", "J_Mouth_RI" );
	
	self maps\_sergei::init_sergei();
	self magic_bullet_shield();
	self.script_friendname = "Sergei";
	self.animname = "sergei";
	
	anim_node = getstruct("pos_sergei_door", "targetname");
		
	sergei_rolldoor = getent("sergei_roll_door", "targetname");
	sergei_rolldoor useanimtree(level.scr_animtree["roll_door"]);
	sergei_rolldoor.animname = "roll_door";

	actors[0] = self;
	actors[1] = sergei_rolldoor;
	
	anim_node anim_single_aligned(actors, "door_start");
	anim_node thread anim_loop_aligned(actors, "door_loop");

	anim_single(get_players()[0], "sergei_hold", "mason");

	self thread sergei_fail_timer(anim_node, actors);

	flag_set("sergei_inposition");

	//spawn the guard that is shooting Sergei down
	simple_spawn_single("button_guard", ::door_sergei_guard);
	
	flag_wait("player_rolled");
		
	anim_node anim_single_aligned(actors, "door_end");

	model = spawn_anim_model("sergei_model");
	model character\c_rus_sergei::main();
	model.animname = "sergei";
	anim_node anim_first_frame(model, "door_end_loop");
	
	self Delete();
}

//self = guard shooting sergei
door_sergei_guard()
{
	self endon("death");

	tags = [];
	tags[0] = "j_hip_le";
	tags[1] = "j_hip_ri";
	tags[2] = "j_elbow_le";
	tags[3] = "j_elbow_ri";
	tags[4] = "j_clavicle_le";
	tags[5] = "j_clavicle_ri";

	self.goalradius = 16;
	self aim_at_target(get_players()[0]);
	self AllowedStances("stand");

	while(!flag("sergei_dead"))
	{
		rand_tag = tags[RandomInt(tags.size)];
		start = self GetTagOrigin("tag_flash");
		end = level.sergei GetTagOrigin(rand_tag);
		MagicBullet("ak47_sp", start, end);
		BulletTracer(start, end);
		wait(RandomFloatRange(0.05, 0.1));
	}

	self stop_aim_at_target();
	self AllowedStances ("crouch", "stand");
}

//self = sergei
sergei_fail_timer(anim_node, actors)
{
	level endon("player_rolled");

	//time before it fails the player
	wait(10.0);

	if(!flag("player_rolled"))
	{
		//set the flag so player can no longer roll under the door
		flag_set("sergei_dead");

		//put clip on door
		clip_rolldoor = getent("clip_player_rolldoor", "targetname");
		clip_rolldoor trigger_on();

		//play the death anim
		anim_node anim_single_aligned(actors, "door_end");
		anim_node anim_first_frame(actors[0], "door_end_loop");
		
		//custom fail message
		SetDvar( "ui_deadquote", &"VORKUTA_SERGEI_DOOR_FAIL" ); 
		missionFailedWrapper();
	}
}

#using_animtree ("player");
player_under_door()
{
	trigger_wait("trigger_under_door");

	if (!flag("sergei_dead"))
	{
		player = get_players()[0];
		
		player.ignoreme = true;
		player disableweapons();

		//start FX in part 2 of armory and minigun
		exploder(1800);
		exploder(1900);
				
		anim_node = getstruct("pos_sergei_door", "targetname");

		player_body = spawn_anim_model( "player_body", player.origin );
		weapon_model = GetWeaponModel( player GetCurrentWeapon() );
		player_body Attach(weapon_model, "tag_weapon");
		player_body UseWeaponHideTags( player GetCurrentWeapon() );
		player_body Hide();
		player_body.angles = player GetPlayerAngles();
							
		flag_set("player_rolled");
		anim_node thread anim_single_aligned(player_body, "player_roll");

		wait(0.05);	

		player StartCameraTween(0.1);
		player PlayerLinkToAbsolute(player_body,"tag_player");

		//make sure player is fully tweened to the body before showing it
		wait(0.3);
		player_body Show();

		//sweet slide rumbles
		player PlayRumbleLoopOnEntity("damage_light");
		wait(2);
		player StopRumble("damage_light");
		wait(0.2);
		player PlayRumbleOnEntity("damage_heavy");

		anim_node waittill("player_roll");
		
		player_body Delete();
		player Unlink();
		player.ignoreme = false;

		//start thread to detect button push
		player thread rolling_door_button();

		//teleport Reznov to the front of the door just in case
		anchor = spawn("script_origin", level.reznov.origin);
		anchor.angles = level.reznov.angles;
		level.reznov LinkTo(anchor);
		position = GetEnt( "trigger_under_door", "targetname" );
		anchor MoveTo( position.origin, 0.1);
		anchor RotateTo( position.angles, 0.1);
		anchor waittill("rotatedone");
		level.reznov Unlink();
		level.reznov LookAtEntity();
		anchor Delete();				

		flag_wait("sergei_dead");
		
		spawn_manager_enable("manager_button_troops_left");
		spawn_manager_enable("manager_button_troops_right");
		
		wait(6.0);
		
		spawn_manager_enable("manager_button_attacker");
	}
}

player_under_door_gun(player_body)
{
	player = get_players()[0];
	player enableweapons();
}

//self is the player
rolling_door_button()
{
	door_button = getstruct ("door_button", "targetname");
	max_dist = 100 * 100;

	while( !flag("player_opened_rolling_door") )
	{
		player_dist = DistanceSquared(self.origin, door_button.origin);

		//if player is within the radius passed through and in front show hint string
		if( (player_dist < max_dist) && (self.origin[0] > door_button.origin[0]) )
		{
			self SetScriptHintString(&"VORKUTA_BUTTON_OPEN_DOOR");
			if( self use_button_held() )
			{
				self SetScriptHintString("");
				PlaySoundAtPosition( "evt_button_press", (0,0,0) );
				flag_set("player_opened_rolling_door");
			}
		}
		else
		{
			self SetScriptHintString("");
		}	

		wait( 0.05 );
	}
}

rolling_door_ai()
{
	allies = GetAIArray ("allies");
	allies = array_exclude(allies, level.reznov);
	allies = array_exclude(allies, level.sergei);
	
	triggerdelete = getent("trigger_delete_allies", "targetname");
	
	for (x=0; x<allies.size; x++)
	{
		if (allies[x] isTouching(triggerdelete))
		{
			if (isdefined(allies[x]))
			{
				allies[x] delete();
			}
		}
	}
}

e4_antinov_damage_mod(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	iDamage = 10;
	return iDamage;
}	

e4_antinov_health_monitor()
{
	level endon ("welding_stopped");
	
	flag_wait ("antinov_going_to_garage");
	
	level.reznov.health = 500;

	while(IsAlive(level.reznov))
	{
		wait(0.05);
	}	
	
	flag_set ("antinov_died");
	SetDvar( "ui_deadquote", &"VORKUTA_GENERIC_FAIL" ); 
	missionFailedWrapper();
}	

antinov_damage_feedback()
{	
	//Tells player when Antinov takes damage. 
	//self = Antinov
	flag_wait ("antinov_going_to_garage");
	level endon ("welding_stopped");
	
	antinov_damage = [];
	antinov_damage[0] = "I'M TAKING FIRE!";
	antinov_damage[1] = "COVER ME I'M TAKING FIRE!";
	antinov_damage[2] = "TAKING FIRE DAMMIT!";
	antinov_damage[3] = "MASON I'M UNDER FIRE!!";
	
	//random_damage_warn = random(antinov_damage);
	
	while(1)
	{
		self waittill ("damage", amount, inflictor, direction, point, type);
		random_damage_warn = random (antinov_damage);
		//add_dialogue_line ("Reznov", random_damage_warn);
	}

}	


antinov_warn_player(warning_count)
{
	//this picks random warning lines and delivers to the player when called. 
	//if its the 3rd warning possible mission fail
	
	antinov_warn = [];
	antinov_warn[0] = "stay_with_me";
	antinov_warn[1] = "keep_them_off";
	antinov_warn[2] = "where_going";
	antinov_warn[3] = "keep_off_mason";

	random_antinov_warn = random(antinov_warn);

	level.reznov anim_single(level.reznov, random_antinov_warn);
	
	wait(5);	//buffer to give player a chance to catch up	
}	
	
	
defend_armory_spawners()
{
	flag_wait("player_3rd_floor");

	level thread maps\vorkuta_amb::deactivate_fake_friendly_dds();
	
	level.reznov thread defend_reznov();
	
	level thread rappel_lookat_trigger();
		
	simple_spawn_single("rappel_lure", ::setup_rappel_lure);

	simple_spawn_single("3rd_floor_runner", ::setup_rappel_lure);
	wait(0.1);
	simple_spawn_single("3rd_floor_runner", ::setup_rappel_lure);

	spawn_manager_enable("manager_rebel_soldier");
	simple_spawn_single("rebel_soldier_victim", ::setup_rebel_victim);
	
	flag_wait("welding_half_done");

	//remove the clip on the window to prevent player progression
	player_clip = GetEnt("armory_defend_player_blocker","targetname");
	player_clip Delete();
	
	level thread check_player_dropdown();
	
	//blow open the side door
	defend_blow_heavy_wall();
		
	spawn_manager_enable("manager_heavy");

	//for VO purposes
	flag_set("heavy_armor");
	
	//once player gets the minigun shift spawners
	flag_wait("got_minigun");

	spawn_manager_kill("manager_first_floor_defend");
	spawn_manager_kill("manager_heavy");
	
	guys = getentarray("prisoner_backup_ai", "targetname");
	for (i=0; i<guys.size; i++)
	{
		if (isdefined(guys[i]))
		{
			guys[i] clear_force_color();
		}
	}
	
	level.reznov set_force_color("c");

	//blow out the wall
	armory_exit_under_fire();

	//corpse removal
	inside_pos = getstruct("door_button","targetname");
	corpses = EntSearch(level.CONTENTS_CORPSE, inside_pos.origin, 400);
	for(i = 0; i < corpses.size; i++)
	{
		if(IsDefined(corpses[i]))
		{
			corpses[i] Delete();
		}
	}

}


check_player_dropdown()
{
	trigger_1 = GetEnt("defend_fail_extra", "targetname");
	trigger_2 = GetEnt("manager_rpg_bridge", "targetname");

	waittill_any_ents(trigger_1, "trigger", trigger_2, "trigger");
	
	if (!flag("got_minigun"))
	{
		level.reznov notify ("end_vo");
		level.reznov anim_single(level.reznov, "nooo"); //Nooo!!!
		level.reznov PlaySound( "wpn_grenade_explode" );
		earthquake(0.3, 1.0, get_players()[0].origin, 100);
				
		SetDvar( "ui_deadquote", &"VORKUTA_GENERIC_FAIL" ); 
		missionFailedWrapper();
	}

	flag_set("begin_alley");

	level thread spawn_prisoners();
}

reznov_down_alley()  //self = level.reznov
{
	flag_wait_any("begin_alley", "btr1_dead", "btr2_dead");
	
	rez_outside = getstruct("rez_outside", "targetname");
	
	self.ignoreall = true;
	self.ignoresuppression = true;
	self.goalradius = 64;
	self setgoalpos(rez_outside.origin);
	self waittill("goal");
	self.ignoreall = false;
	self.ignoresuppression = false;
}


spawn_prisoners()
{
	//kill off spawners inside and start audio
	spawn_manager_kill("manager_alley_fighter");
	flag_set("final_step");

	//make sure the player has dropped down before saving
	trigger_wait("manager_rpg_bridge");
	autosave_by_name("minigun_alley_start");

	//turn off FX in the armory
	stop_exploder(1800);

	//trigger towards the end of the alley
	flag_wait("last_guy");
	spawn_manager_kill("manager_prisoner_alley");
}


setup_rappel_lure()
{
	self endon("death");
	self.ignoresuppression = true;
	self.goalradius = 16;
	self waittill("goal");
	self.ignoresuppression = false;
}


setup_rebel()
{
	self endon("death");
	self magic_bullet_shield();
}


setup_rebel_victim()
{
	self endon("death");
	
	self.health = 1;
	
	node1 = getnode("rebel_victim_bridge", "targetname");
	node2 = getnode("rebel_victim", "targetname");
	
	self magic_bullet_shield();
	
	flag_wait("goto_weld");
	
	self setgoalnode(node2);
	
	flag_wait("heavy_intro");
	
	self stop_magic_bullet_shield();
}


rappel_lookat_trigger()
{
	trigger = getent("rappel_lookat", "targetname");
	trigger waittill("trigger");
	
	spawn_manager_enable("manager_rappeler");
	level thread rappel_shoot_glass_out("roof_rappel_wave_1");
	
	wait(5.0);
	
	spawn_manager_enable("repel_guy_spawner");
	level thread rappel_shoot_glass_out("roof_rappel_wave_2");
}

//shoots the glass before rappelling
rappel_shoot_glass_out(targetname)
{
	origins = GetStructArray(targetname, "targetname");
	for(i = 0; i < origins.size; i++)
	{
		start_pos = origins[i].origin;
		end_pos = start_pos + (0, 0, -100);
		MagicBullet("ak47_sp", start_pos, end_pos);
		wait(0.1);
		MagicBullet("ak47_sp", start_pos, end_pos);
		wait(0.1);
		MagicBullet("ak47_sp", start_pos, end_pos);
	}
}

//self = level.reznov
defend_reznov()
{
	self endon("death");  
	
	level autosave_by_name("Protect Antinov");

	//make sure to clear all head look
	self LookAtEntity();
	restore_ik_headtracking_limits();
	
	//take Reznov off the color chain
	self clear_force_color();
	
	//set after the audio line "Wield a fist of iron!"
	flag_wait("goto_weld");

	//send friendlies to star wars room
	trigger_use("triggercolor_to_torch");
	
	//spawn backup friendlies to fill the space
	spawn_manager_enable("manager_prisoner_backup");
	
	//move to right before the bridge
	self SetGoalNode( GetNode("cover_reznov_bridge", "targetname") );
	//self waittill("goal");
	
	//wait for player to be in range or Reznov or check to see if he is in the room
	self thread reznov_to_bridge();
	level thread player_in_swroom();
	
	flag_wait("to_bridge");
	
	flag_set("antinov_going_to_garage");

	//send him halfway across the bridge to look at vehicles coming in
	self SetGoalNode( GetNode ("antinov_looks_at_vehicles", "targetname") );
	self waittill ("goal");
	
	//opens gate outside that trucks drive through
	level thread defend_open_outside_gates();
	
	//spawn the vehicles
	delayThread(2.0, ::trigger_use, "trigger_gaz_gate");

	//for VO
	flag_set("btr_entry");
	
	//give player time to see vehicles drive by
	wait(4); 
	
	flag_set("get_weld");

	//move him to the room to pickup the blowtorch
	anim_node = getstruct("pos_pickup_weld", "targetname");
	anim_node anim_reach_aligned(self, "weld_pickup");
	
	flag_set("at_welder");
	
	self stop_magic_bullet_shield();
	
	//CODE CALLBACK DAMAGE MOD 
	self.overrideActorDamage = ::e4_antinov_damage_mod;
	
	//tells player when he takes fire
	self thread antinov_damage_feedback();
	
	level thread spawn_heavy_guy();
	
	actors = array(self, level.torch);
	anim_node anim_single_aligned(actors, "weld_pickup");
		
	flag_set("welding_cart_moving");

	level thread defend_welding_room_fail();
	
	spawn_manager_kill("manager_prisoner_backup");
	
	weld_cover = GetNode("cover_reznov_weld", "targetname");
	self SetGoalNode(weld_cover);
		
	waittill_ai_group_cleared("group_stormtroopers");

	node_bridge = GetNode("cover_welder_bridge", "targetname");
	self SetGoalNode(node_bridge);
	
	spawn_manager_enable("manager_bridge_ambush");
	spawn_manager_enable("manager_bridge_hopper");
	spawn_manager_enable("manager_bridge_heavy");
	
	level thread bridge_hopper();
	
	flag_set("reznov_pinned");
	
	waittill_ai_group_cleared("group_bridge_ambush");
		
	wait(0.5);
	
	spawn_manager_enable("manager_first_floor_defend");
		
	node_cover = getnode("cover_welder_bridge", "targetname");
	SetEnableNode(node_cover, false);
	
	
	
	/*===================
	begin welding at vault
	===================*/

	spawn_manager_enable("manager_weld_backup");
	
	autosave_by_name ("welding_started");
	
	self.allowdeath = true;
	
	anim_node = getstruct("pos_weld", "targetname");
		
	anim_node anim_reach_aligned(self, "weld_enter");

	flag_set("welding_cart_at_vault");

	anim_node anim_single_aligned(self, "weld_enter");
	anim_node thread anim_loop_aligned(self, "weld_idle"); 
	
	/*===================
	Welding Done
	===================*/
	
	flag_wait("welding_stopped");

	autosave_by_name ("welding_finished");

	spawn_manager_kill("manager_weld_backup");

	self make_hero();
	
	weld_door = GetEnt("welding_door", "targetname");	
	weld_door useanimtree(level.scr_animtree["weld_door"]);
	weld_door.animname = "weld_door";

	actors = array(self, level.torch, weld_door);
	anim_node anim_single_aligned(actors, "weld_exit");
	flag_set("vault_open");
	
	node = GetNodeArray("cover_post_weld", "targetname");
	self SetGoalNode(node[RandomInt(node.size)]);
	
	wait(2.0);

	//back into combat
	self.ignoreall = false;
	
	flag_wait("goto_window");
	
	spawn_manager_enable("manager_prisoner_alley");
	spawn_manager_enable("manager_alley_fighter");
	
	self set_force_color("c");
	
	trigger_use("reznov_to_window");
	
	triggerwindow = getent("trigger_reznov_window", "targetname");
	triggerwindow trigger_on();
	triggerwindow waittill("trigger");
	triggerwindow delete();
	
	waittill_spawn_manager_cleared("manager_minigun_victim_heavy");
}

//kill Reznov if the player leaves the room with enemies still alive
defend_welding_room_fail()
{
	level endon("reznov_pinned");

	fail_line = GetNode("cover_reznov_bridge","targetname");
	player = get_players()[0];

	while(1)
	{
		if(player.origin[1] < fail_line.origin[1])
		{
			if(IsAlive(level.reznov))
			{
				level.reznov die();
			}
		}
		wait(0.05);
	}
}

defend_reznov_welding_fx()
{
	flag_wait("welding_cart_at_vault");

	fxOrg = Spawn("script_model", (0,0,0));
	fxOrg SetModel("tag_origin" );

	fxOrg.origin = level.reznov GetTagOrigin("tag_fx");
	fxOrg.angles = level.reznov GetTagAngles("tag_fx");

	fxOrg LinkTo(level.reznov, "tag_fx");

	PlayFXOnTag( level._effect["welding_sparks"], fxOrg, "tag_origin" );

	//50 second long growing scorch marks
	exploder(777);

	flag_wait("welding_stopped");

	fxOrg delete();
}	

//used to make sure weapons only get dropped by AI if they are near the player
defend_reznov_weapon_drop_check()
{
	self endon("death");
	
	while(1)
	{
		if( DistanceSquared(self.origin, get_players()[0].origin) > (300 * 300) )
		{
			self.dropweapon = false;
		}
		else
		{
			self.dropweapon = true;
		}
		wait(1);
	}

}

defend_blow_heavy_wall()
{
	door = getent("armory_backdoor", "targetname");

	level notify("doorblast_start");

	exploder(65);

	RadiusDamage (door.origin, 50, 150, 150);
	PlaySoundAtPosition ("wpn_rocket_explode_dirt", door.origin);
	Earthquake( 0.5, 1, get_players()[0].origin, 100 );

	door = getentarray("armory_back_door", "targetname");
	for(i=0; i<door.size; i++)
	{
		if (isdefined(door[i]))
		{
			door[i] delete();
		}
	}

	dest = getentarray("armory_back_door_destroyed", "targetname");
	for(i=0; i<dest.size; i++)
	{
		if (isdefined(dest[i]))
		{
			dest[i] show();
		}
	}

	clip = getent("armory_backdoor", "targetname");
	clip connectpaths();
	clip delete();
}

defend_open_outside_gates()
{
	left = GetEnt("btr_door_left", "targetname");
	left_clip = GetEnt("btr_door_left_clip","targetname");
	left_clip LinkTo(left);

	right = GetEnt("btr_door_right", "targetname");
	right_clip = GetEnt("btr_door_right_clip","targetname");
	right_clip LinkTo(left);

	left rotateyaw(-100, 2.0);
	right rotateyaw(100, 2.0);

	level waittill("close_alley_gates");

	left rotateyaw(100, 5.0);
	right rotateyaw(-100, 5.0);
}

attach_tank( reznov )
{
	level.reznov attach("anim_rus_torch_backpack_stowed","TAG_STOWED_BACK");
	level.torch hide();
}

detach_tank( reznov )
{
	level.reznov Detach("anim_rus_torch_backpack_stowed","TAG_STOWED_BACK");
	level.torch show();
}

attach_torch( reznov )
{
	level.reznov Attach("anim_rus_torch","TAG_INHAND");
	level.reznov thread defend_reznov_welding_fx();
	level.reznov thread play_welding_audio();
}

detach_torch( reznov )
{
	level.reznov Detach("anim_rus_torch","TAG_INHAND");
}

player_in_swroom()
{
	triggerswroom = getent("trigger_playerin_swroom", "targetname");
	triggerswroom trigger_on();
	triggerswroom waittill("trigger");
	
	flag_set("to_bridge");
}


reznov_to_bridge()
{
	while(Distance2DSquared(self.origin, get_players()[0].origin) > 90000)
	{
		wait(0.1);
	}
	
	flag_set("to_bridge");
}

e4_welding_timer()
{
	level endon ("antinov_died");
	
	welding_time = 50;
	
	flag_wait("welding_cart_at_vault");
	level thread maps\vorkuta_amb::activate_fake_friendly_dds();
	
	wait(welding_time * .25);
	
	flag_set ("welding_half_done");
	
	wait(welding_time * .75);
	
	flag_set("welding_stopped");
	level thread maps\vorkuta_amb::deactivate_fake_friendly_dds();
	
	player = get_players()[0];
	
	while(!player HasWeapon("minigun_sp"))
	{
		wait(0.05);
	}
	
	flag_set("got_minigun");
	
	spawn_manager_enable("manager_minigun_victim_heavy");

	//move backup to the windows
	trigger_use("triggercolor_return_armory");
		
	trigger_btr_reinforce = getent("trigger_btr_reinforcement", "targetname");
	trigger_btr_reinforce trigger_on();
	trigger_btr_reinforce thread armory_exit_gaz_reinforcement();
	
	wait(2.0);
	
	spawn_manager_enable("manager_minigun_victim");
}	


e4_antinov_defend_squad_management()
{
	//wait for antinov to head to garage
	flag_wait ("antinov_going_to_garage");
	//squad back to defending positions
	trigger_use( "squad_defend_antinov" );
}

e4_welding_vault_door_movement(guy)
{
	flag_wait("welding_stopped");

	weld_door = GetEnt("welding_door", "targetname");	
	
	vault_door_l = GetEnt("vault_door_l","targetname");
	vault_door_l LinkTo(weld_door, "hinge_left");

	vault_door_r = GetEnt("vault_door_r", "targetname");
	vault_door_r LinkTo(weld_door, "hinge_right");

	flag_wait("vault_open");

	cover_vault_closed = getnode("cover_vault_closed", "targetname");
	SetEnableNode(cover_vault_closed, false);
}

spawn_heavy_guy()
{
	sm_run_func_when_enabled( "manager_heavy_escort", ::audio_random_redshirt_vox );
	
	flag_set("heavy_intro");
	
	rebels = getentarray("rebel_soldier_ai", "targetname");
	for(i=0; i<rebels.size; i++)
	{
		rebels[i] stop_magic_bullet_shield();
	}
	
	spawn_manager_enable("manager_heavy_escort");
	
	wait(4.2);
	
	simple_spawn_single("heavy_intro", ::setup_heavy_intro);
	
	wait(2.0);
	
	door_clean = GetEnt("roll_up_door", "targetname");
	door_dest = GetEnt("roll_up_door_destroyed", "targetname");
	
	//bullet holes around the door
	exploder(50);

	//rumble for the door burst
	player = get_players()[0];
	room = GetEnt("trigger_playerin_swroom","targetname");
	wait(0.2);
	for(i = 0; i < 10; i++)
	{
		if( player IsTouching(room) )
		{
			player PlayRumbleOnEntity("damage_light");
			wait(0.1);
		}
	}
	wait(0.3);

	level notify( "stop_random_vox" );
	door_dest PlaySound( "evt_garage_door_explo" );
	door_dest PlaySound( "wpn_grenade_explode" );
	door_dest PlaySound( "wpn_smoke_hiss" );
	
	clip_ai = getent("clip_ai_breach", "targetname");
	clip_ai ConnectPaths();
	clip_ai Delete();

	//spawn first heavy to go through
	simple_spawn_single("stormtrooper_heavy", ::setup_stormtrooper_breach);
	
	PhysicsExplosionSphere(door_dest.origin + (0, 0, -50), 280, 280, 3.5);
	Earthquake(0.3, 1.0, get_players()[0].origin, 100);
	player PlayRumbleOnEntity("damage_heavy");

	//TUEY Set Music State to BLOW_TORCH!
	setmusicstate("BLOW_TORCH");
	
	//only slow motion if the player is in the room
	triggerswroom = getent("trigger_playerin_swroom", "targetname");
	if(player IsTouching(triggerswroom))
	{
		timescale_tween(1, 0.25, 0.2);
		wait(0.7);
		timescale_tween(0.25, 1, 1);
	}
	
	rebel = GetEnt("rebel_soldier_victim_ai", "targetname");
	if(IsAlive(rebel))
	{
		rebel thread kill_rebel();
	}	
		
	door_clean delete();
	door_dest show();
	
	//have all the AI in the area take damage	
	array_thread(GetAIArray("allies"), ::react_door_explosion);

	wait(1.0);

	//spawn the two regular AI
	simple_spawn("stormtrooper", ::setup_stormtrooper);

	wait(3.0);

	//spawn the last heavy
	simple_spawn_single("stormtrooper_heavy", ::setup_stormtrooper_breach);
}


kill_rebel()
{
	self endon("death");
	
	door_dest = getent("roll_up_door_destroyed", "targetname");
	
	wait(2.5);
	
	MagicBullet("ks23_sp", door_dest.origin, self.origin + (0, 0, 66));
	playfx(	level._effect["bloody_hit"], self.origin + (0, 0, 40));
}


setup_stormtrooper_breach()
{
	self endon("death");
	
	self maps\_juggernaut::make_juggernaut();
	
	player = get_players()[0];
	
	if (isdefined(player))
	{
		self SetEntityTarget(player);
	}

	self magic_bullet_shield();

	wait(2.5);

	self stop_magic_bullet_shield();
}


bridge_hopper()
{
	waittill_spawn_manager_complete("manager_bridge_ambush");
	
	waittill_spawn_manager_cleared("manager_bridge_ambush");
	
	hopper = getentarray("bridge_hopper_ai", "targetname");
	
	if (isdefined(hopper[0]))
	{
		node = getnode("node_bridge_hopper", "targetname");
		hopper[0] setgoalnode(node);
	}
	else if (isdefined(hopper[1]))
	{
		node = getnode("node_bridge_hopper", "targetname");
		hopper[1] setgoalnode(node);
	}
}


react_door_explosion()
{
	self endon("death");
	
	self dodamage(1.0, self.origin);
	self.ignoreall = true;
	wait(RandomFloatRange(3.5, 4.0));
	self.ignoreall = false;
}


setup_stormtrooper()
{
	self endon("death");
	
	self.goalradius = 64;
	self.ignoresuppression = true;
	self disable_pain();
	self disable_react();
	self enable_cqbwalk();
	
	self waittill("goal");
	
	self.ignoresuppression = false;
	self enable_pain();
	self enable_react();
	self disable_cqbwalk();
}


setup_stormtrooper_heavy()
{
	self endon("death");
	
	self maps\_juggernaut::make_juggernaut();
}

setup_extra_bridge()
{
	self SetEntityTarget(get_players()[0]);
}

setup_bridge_autodeath()
{
	self endon("death");

	flag_wait("welding_cart_at_vault");

	player = get_players()[0];
	eye = player GetEye();

	while( self SightConeTrace(eye,player) )
	{
		eye = player GetEye();
		wait(1);
	}

	self die();
}

setup_heavy_intro()
{
	self endon("death");
	self.ignoreme = true;
	self.ignoreall = true;
	self.animname = "generic";
	self set_run_anim("active_patrol_walk1");
	self setcandamage(false);
	self.goalradius = 64;
	self waittill("goal");
	self delete();
}

armory_exit_under_fire()
{
	exp_pos1 = getstruct("btr_victim_explosion1", "targetname");
	exp_pos2 = getstruct("btr_victim_explosion2", "targetname");
	exp_pos3 = getstruct("btr_victim_explosion3", "targetname");
	exp_pos4 = getstruct("btr_victim_explosion4", "targetname");
	
	armory_wall1 = getent("armory_backwall_destroyed_01", "targetname");
	armory_wall2 = getent("armory_backwall_destroyed_02", "targetname");
	armory_wall3 = getent("armory_backwall_destroyed_03", "targetname");
	armory_wall4 = getent("armory_backwall_destroyed_04", "targetname");
	
	wall1 = getent("armory_backwall_01", "targetname");
	wall2 = getent("armory_backwall_02", "targetname");
	wall3 = getent("armory_backwall_03", "targetname");
	wall4 = getent("armory_backwall_04", "targetname");
	
	rpg1 = getstruct("rpg_fire1", "targetname");
	rpg2 = getstruct("rpg_fire2", "targetname");
	rpg3 = getstruct("rpg_fire3", "targetname");

	//disable the wall occluder
	EnableOccluder("armory_occluder", false);
	OnSaveRestored_Callback(::armory_on_save_restore);

	player = get_players()[0];
	
	exploder(60);
	playsoundatposition( "evt_window_explo_1", exp_pos1.origin );
	PhysicsExplosionSphere(exp_pos1.origin, 200, 200, 1);
	earthquake(0.3, 1.0, player.origin, 100);
	player PlayRumbleOnEntity("damage_light");
	armory_wall1 Show();
	wall1 Delete();
	
	wait(0.3);
	
	//MagicBullet("rpg_magic_bullet_sp", rpg1.origin, exp_pos1.origin);
	
	wait(0.7);
	
	exploder(61);
	playsoundatposition( "evt_window_explo_2", exp_pos2.origin );
	PhysicsExplosionSphere(exp_pos2.origin, 200, 200, 1);
	earthquake(0.4, 1.2, player.origin, 100);
	player PlayRumbleOnEntity("damage_heavy");
	armory_wall2 Show();
	wall2 Delete();
	
	wait(0.6);
	
	//MagicBullet("rpg_magic_bullet_sp", rpg2.origin, exp_pos3.origin);
	
	wait(0.6);
	
	exploder(62);
	playsoundatposition( "evt_window_explo_3", exp_pos3.origin );
	PhysicsExplosionSphere(exp_pos3.origin, 200, 200, 1);
	earthquake(0.3, 0.9, player.origin, 100);
	player PlayRumbleOnEntity("damage_light");
	armory_wall3 Show();
	wall3 Delete();
	
	wait(0.5);
	
	//MagicBullet("rpg_magic_bullet_sp", rpg2.origin, exp_pos3.origin);
	
	wait(0.5);
	
	exploder(63);
	playsoundatposition( "evt_window_explo_3", exp_pos4.origin );
	PhysicsExplosionSphere(exp_pos4.origin, 200, 200, 1);
	earthquake(0.5, 1.3, player.origin, 100);
	player PlayRumbleOnEntity("damage_heavy");
	armory_wall4 Show();
	wall4 Delete();
	
	wait(0.3);
	
	exploder(64);
	playsoundatposition( "evt_window_explo_3", exp_pos4.origin );
	earthquake(0.3, 1.0, player.origin, 100);
	player PlayRumbleOnEntity("damage_heavy");

	//moved here to make sure there is a save after the occluder is disabled
	//autosave_by_name("minigun"); -occluder state doesn't save -jc
}

//makes sure the occluder is disabled past this checkpoint
armory_on_save_restore()
{
	EnableOccluder("armory_occluder", false);
}

//enemy reinforcements arrive during btr attack (self = trigger_btr_reinforcement)
armory_exit_gaz_reinforcement()
{
	self waittill("trigger");

	trigger_use("gaz_gunner_1_spawn");
	wait(5);
	
	trigger_use("gaz_gunner_2_spawn");
	wait(10);
	
	trigger_use("trigger_gaz_alley");
}

//self is the gaz gun from the gates
armory_exit_gaz_gunner_1()
{
	self endon("death");

	self thread truck_monitor();

	self.gunner = simple_spawn_single("gaz_gunner1", ::armory_exit_monitor_gunner, "btr1_dead");
	self.driver = simple_spawn_single("gaz_driver1");

	self.gunner maps\_vehicle_aianim::vehicle_enter(self, "tag_gunner1");
	self.driver maps\_vehicle_aianim::vehicle_enter(self, "tag_driver");

	//close the gates the gaz comes in from
	level notify("close_alley_gates");

	self thread armory_exit_gaz_gunner_think();

	self waittill("reached_end_node");

	self.gunner stop_magic_bullet_shield();
	self.gunner.health = 400;
	self.gunner thread maps\vorkuta_minigun_alley::auto_kill();
	self.gunner thread armory_exit_gaz_gunner_radius_death();
}

//self is the gaz gun from the alley
armory_exit_gaz_gunner_2()
{
	self endon("death");

	self thread truck_monitor();

	self.gunner = simple_spawn_single("gaz_gunner2", ::armory_exit_monitor_gunner, "btr2_dead");
	self.driver = simple_spawn_single("gaz_driver2");
	
	self.gunner maps\_vehicle_aianim::vehicle_enter(self, "tag_gunner1");
	self.driver maps\_vehicle_aianim::vehicle_enter(self, "tag_driver");

	self thread armory_exit_gaz_gunner_think();

	self waittill("reached_end_node");

	self.gunner stop_magic_bullet_shield();
	self.gunner.health = 400;
	self.gunner thread maps\vorkuta_minigun_alley::auto_kill();
	self.gunner thread armory_exit_gaz_gunner_radius_death();
}

armory_exit_gaz_gunner_radius_death()
{
	self endon("death");

	player = get_players()[0];

	//stay alive as long as the enemy is further ahead than the player
	while( DistanceSquared(self.origin, player.origin) > (256*256) )
	{
		wait(0.05);
	}

	self bloody_death();
}

//self is a gaz gunner
armory_exit_monitor_gunner(flag)
{
	self magic_bullet_shield();

	self waittill("death");

	flag_set(flag);
}

//self is the gaz gun truck
armory_exit_gaz_gunner_think()
{
	self endon("death");
	
	sound_ent = Spawn( "script_origin", self.origin );
	sound_ent LinkTo( self, "rear_hatch_jnt" );
	self thread delete_gunner_sound_ent( sound_ent );
	
	self thread maps\_vehicle_turret_ai::enable_turret(0, "mg", "allies");	

	while( IsAlive(self.gunner) )
	{
		wait(0.05);
	}

	self thread maps\_vehicle_turret_ai::disable_turret(0);
}
	
vo_reznov_armory_floor_1()
{
	self endon("stop_floor_1_vo");
	
	self.animname = "reznov";
	self disable_pain();
	self disable_react();
	
	trigger_wait("squad_to_stairs");
	
	wait(1.5);
	
	self anim_single(self, "know_what");  //You all know what to do!
	level thread play_prisoner_crowd_vox( "vox_vor1_s99_324A_rrd5", "vox_vor1_s99_325A_rrd6", "vox_vor1_s99_326A_rrd7" );
	
	flag_wait("go_shields");

	reznov_lines[0] = "push_forward";
	reznov_lines[1] = "no_fear";
	reznov_lines[2] = "flank";

	//copied from the utility function because it needs to end off one of two flags
	vo_array = array_randomize(reznov_lines);
	vo_index = 0;
	while( !flag("group_first_floor_cleared") || !flag("unleash_hall_defense") )
	{
		anim_single( self, vo_array[vo_index] );
		vo_index++;
		if(vo_index == vo_array.size)
		{
			break;
		}	

		wait(5);
	}

	//wait for the 1st floor to be almost cleared
	waittill_ai_group_ai_count("group_first_floor", 2);
	
	//player hasn't gone upstairs yet
	if( !flag("unleash_hall_defense") )
	{
		self anim_single(self, "upstairs");  //Up the stairs! Go! Take no prisoners!

		//closest friendly ai 
		friendly = get_array_of_closest(self.origin, GetAIArray("allies"), get_heroes());
		friendly[0] anim_single(friendly[0], "heard", "rrd4");  //You heard him  Comrades!
	}
}

//self is reznov
vo_reznov_armory_floor_2()
{
	flag_wait("unleash_hall_defense");

	self notify("stop_floor_1_vo");
	self enable_pain();
	self enable_react();

	wait(2.0);

	//closest friendly ai to player
	friendly = get_array_of_closest(get_players()[0].origin, GetAIArray("allies"), get_heroes());
	friendly[0] anim_single(friendly[0], "lockdown", "rrd4");  //They are trying to lock down the armory!
	
	self anim_single(self, "donotletthem"); //Do not let them!

	wait(0.5);

	self anim_single(self, "keep_firing"); //Keep firing!
	self anim_single(self, "fight"); //Fight!

	//the enemy is retreating
	flag_wait("kill_hall_defense");	

	wait(1);

	self anim_single(self, "seal"); //They're trying to seal the door from the inside!

	flag_wait("sergei_inposition");

	if (!flag("player_rolled"))
	{
		self anim_single(self, "sergei_hold"); //Sergei cannot hold it for much longer!
	}

	wait(0.5);

	if (!flag("player_rolled"))
	{
		self anim_single(self, "hurry"); //Hurry Mason!
	}

	flag_wait("sergei_dead");

	//reznov is not happy with Sergei's death	
	self anim_single(self, "nooo"); //Nooo!!!

	//nag lines while the player needs to open the door
	door_reznov_lines[0] = "open_door";
	door_reznov_lines[1] = "get_door_open";
	door_reznov_lines[2] = "more_door_open";

	level thread do_nag_vo_array(level.reznov, door_reznov_lines, "player_opened_rolling_door", 5, true);
}


vo_reznov_defend()
{
	self endon("death");
	self endon("end_vo");
	
	flag_wait("go_upstairs");
	
	self anim_single(self, "upstairs_go"); //Upstairs  let's go
	
	wait(1.0);
	
	vo_redshirt_roof();
	
	wait(0.5);
	
	self anim_single(self, "lambs"); //They too will be lambs to the slaughter!
	
	flag_wait("player_3rd_floor");
	
	wait(2.0);
	
	vo_redshirt_vault();
	
	wait(0.5);
	
	self anim_single(self, "consequence"); //Such matters are of little consequence.
	
	wait(0.5);
	
	player = get_players()[0];
	player.animname = "mason";
	player anim_single(player, "step_six"); //Step six.
	
	wait(0.5);
	
	self anim_single(self, "wield_iron"); //Wield a fist of iron.

	flag_set("goto_weld");
	
	wait(0.5);
	
	self anim_single(self, "this_way"); //This way.
	
	flag_wait("btr_entry");
	
	wait(1.0);
	
	self anim_single(self, "reinforcements"); //More reinforcements!
	self anim_single(self, "little_time"); //We have little time!
	
	flag_wait("get_weld");
	
	wait(2);

	vo_redshirt_breach();
	self anim_single(self, "not_let_them"); //Do not let them!

	flag_wait("reznov_pinned");
	
	wait(1.0);
	
	self anim_single(self, "clear_path"); //You must clear a path for me  Mason!
	
	flag_wait("welding_cart_at_vault");

	protect_reznov_lines[0] = "stand_ground";
	protect_reznov_lines[1] = "concentrate_fire";
	protect_reznov_lines[2] = "keep_off_mason";
	protect_reznov_lines[3] = "keep_them_off";

	level thread do_nag_vo_array(level.reznov, protect_reznov_lines, "welding_stopped", 10, true);

	flag_wait("welding_half_done");
	
	//vo_redshirt_window();
	
	wait(0.5);
		
	flag_wait("heavy_armor");
		
	vo_redshirt_pullback();
	
	wait(0.5);
	
	player = get_players()[0];
	player.animname = "mason";
	player anim_single(player, "need_open"); //We need that vault open - NOW!

	self anim_single(self, "almost_there");
	
	flag_wait("welding_stopped");
	
	self anim_single(self, "yesss"); //Yes!!!
	
	wait(1.5);
	
	self anim_single(self, "grab_minigun"); //Mason! Grab that Mini-gun!
	
	flag_wait("got_minigun");
	
	player = get_players()[0];
	player.animname = "mason";

	flag_set("goto_window");
		
	//TUEY Set music state to MINI_GUN
	setmusicstate("MINI_GUN");
	
	//Kills script on client
	clientNotify ("kill_pa");
	
	self anim_single(self, "good_work"); //Good work Mason!
}


vo_reznov_minigun()
{	
	flag_wait("final_step");
	
	wait(2.0);
	
	self anim_single(self, "step_seven"); //Step Seven Comrades?!
	
	wait(0.5);
	
	vo_redshirt_hell();
	
	wait(1.0);
	
	self anim_single(self, "for_honor"); //For honor!
	
	wait(0.5);
	
	self anim_single(self, "for_vengeance"); //For vengeance!
	
	wait(0.5);
	
	self anim_single(self, "for_russia"); //For Russia!!!
	
	wait(0.5);
	
	vo_redshirt_ura();

	reznov_lines[0] = "burn_place"; //Burn this place to the ground comrades!
	reznov_lines[1] = "diescum"; //Die Scum!
	reznov_lines[2] = "unleash_fury"; //Unleash fury!
	reznov_lines[3] = "kill_all"; //Kill all who stand in our way.
	reznov_lines[4] = "no_mercy"; //Show NO mercy!!!
	reznov_lines[5] = "kill_them"; //Kill them all!

	level thread do_nag_vo_array(level.reznov, reznov_lines, "end_alley", 10);

	flag_wait("gas_attack");
	
	self anim_single(self, "tear_gas"); //They are using tear gas!

	wait(1);

	self anim_single(self, "masonnn"); //MASON!!!!
}

vo_redshirt_roof()
{
	guys = getaiarray("allies");
	guys = array_exclude(guys, level.reznov);
	
	if (isdefined(guys[0]))
	{
		guys[0].animname = "rrd4";
		guys[0] anim_single(guys[0], "roof");  //The roof! I hear them on the roof!
	}
}


vo_redshirt_vault()
{
	guys = getaiarray("allies");
	guys = array_exclude(guys, level.reznov);
	
	if (isdefined(guys[0]))
	{
		guys[0].animname = "rrd4";
		guys[0] anim_single(guys[0], "sealed");  //Reznov! They have sealed the vault!
	}
}


vo_redshirt_breach()
{
	guys = getaiarray("allies");
	guys = array_exclude(guys, level.reznov);

	guy = get_closest_living(get_players()[0].origin, guys);
	guy.animname = "rrd4";
	guy anim_single(guy, "breach");  //(Translated) They're here! Pull back! Pull back!
}


vo_redshirt_pullback()
{
	guys = getaiarray("allies");
	guys = array_exclude(guys, level.reznov);
	
	if (isdefined(guys[0]))
	{
		guys[0].animname = "Russian Prisoner";
		guys[0] anim_single(guys[0], "pullback");  //(Translated) They're here! Pull back! Pull back!
	}
}


vo_redshirt_window()
{
	guys = getaiarray("allies");
	guys = array_exclude(guys, level.reznov);
	
	if (isdefined(guys[0]))
	{
		guys[0].animname = "Russian Prisoner";
		guys[0] anim_single(guys[0], "away_windows");  //(Translated) Stay away from the windows!
	}
}


vo_redshirt_hell()
{
	guys = getaiarray("allies");
	guys = array_exclude(guys, level.reznov);
	
	level thread play_prisoner_crowd_vox( "vox_vor1_s99_318A_rrd5", "vox_vor1_s99_319A_rrd6", "vox_vor1_s99_320A_rrd7" );
	
	if (isdefined(guys[0]))
	{
		guys[0].animname = "crow";
		guys[0] anim_single(guys[0], "raise_hell");  //Raise HELL!!!
	}
}


vo_redshirt_ura()
{
	guys = getaiarray("allies");
	guys = array_exclude(guys, level.reznov);
	
	level thread play_prisoner_crowd_vox( "vox_vor1_s99_324A_rrd5", "vox_vor1_s99_325A_rrd6", "vox_vor1_s99_326A_rrd7" );
	
	if (isdefined(guys[0]))
	{
		guys[0].animname = "crow";
		guys[0] anim_single(guys[0], "uraaa");  //URA!!!!
	}
}

   
play_welding_audio()
{
	flag_wait( "flag_torch_on" );

    self PlaySound( "evt_welder_start" );
    self PlayLoopSound( "evt_welder_loop", .5 );
    
    flag_wait( "flag_torch_off" );
    self PlaySound( "evt_welder_end" );
    self StopLoopSound( .25 );
} 

audio_random_redshirt_vox()
{
    wait(1);
    enemies = GetAIArray("axis");
    array_thread( enemies, ::play_random_vox );
}

play_random_vox()
{
    self endon( "death" );
    level endon( "stop_random_vox" );
    
    vox_line = [];
    vox_line[0] = "rspns_lm_0";
    vox_line[1] = "rspns_act_0";
    
    prefix = "dds_ru" + RandomIntRange(0,3) + "_";
    
    chance = RandomIntRange(0,101);
    if( chance <= 50 )
        return;
    
    wait(RandomFloatRange(1,3));
    
    while( 1 )
    {
        rand = RandomIntRange(0,2);
        alias = vox_line[rand] + RandomIntRange(0,5);
        self PlaySound( prefix + alias, "sounddone" );
        self waittill( "sounddone" );
        wait(RandomFloatRange(1,4));
    }
}

play_vehicle_arrival_audio( type )
{
    alias = undefined;
    tag = undefined;
    
    switch(type)
    {
        case "moto":
            alias = "veh_moto_looper_fast_ai";
            tag = "tag_wheel_front";
            break;
        case "truck":
            alias = "veh_truck_front_courtyard_special";
            tag = "tag_engine_left";
            break;
    }
    
    origin = self GetTagOrigin( tag );
    sound_ent = Spawn( "script_origin", origin );
    sound_ent LinkTo( self, tag );
    sound_ent PlayLoopSound( alias, 2 );
    self waittill_notify_or_timeout( "reached_end_node", 10 );
    sound_ent StopLoopSound( 2 );
    wait(1);
    sound_ent Delete();
}

play_roof_footsteps_audio()
{
    wait(2);
    playsoundatposition( "evt_armory_roof_steps_0", (3032,6254,1525) );
    wait(.5);
    playsoundatposition( "evt_armory_roof_steps_1", (2902,6649,1494) );
    wait(.2);
    playsoundatposition( "evt_armory_roof_steps_2", (3240,6434,1499) );
    wait(.2);
    playsoundatposition( "evt_armory_roof_steps_3", (2761,6416,1518) );
}


#using_animtree("animated_props");
setup_welder_prop()
{
	anim_node = getstruct("pos_pickup_weld", "targetname");
	
	torch_pos = GetStartOrigin(anim_node.origin, anim_node.angles, %ch_vor_b03_reznov_lift_welder_torch);
	torch_angles = GetStartAngles(anim_node.origin, anim_node.angles, %ch_vor_b03_reznov_lift_welder_torch);
	level.torch = spawn_anim_model("torch", torch_pos, torch_angles); 
}

play_truck_driving_audio()
{
    self endon( "death" );
    self endon( "gaz_alley_destroyed" );
    self endon( "gaz_gate_destroyed" );
    self endon( "btr1_destroyed" );
    self endon( "btr2_destroyed" );
    
    front = self GetTagOrigin( "tag_engine_left" );
    sound_ent = Spawn( "script_origin", front );
    sound_ent LinkTo( self, "tag_engine_left" );
    sound_ent PlayLoopSound( "veh_truck_front_courtyard_special" );
    self thread delete_truck_sound_ent( sound_ent );
    self waittill( "truck_stopped" );
    sound_ent StopLoopSound( .25 );
    playsoundatposition( "veh_truck_stop", sound_ent.origin );
    wait(3);
    sound_ent Delete();
}

delete_truck_sound_ent( ent )
{
    self endon( "truck_stopped" );
    
    self waittill_any( "death", "gaz_alley_destroyed", "gaz_gate_destroyed", "btr1_destroyed", "btr2_destroyed" );
    ent Delete();
}

delete_gunner_sound_ent( ent )
{
    self waittill_any( "death", "gunner_dead" );
    ent Delete();
}

play_armory_alarm_audio()
{
    if( !IsDefined( self ) )
        return;
        
    sound_ent = Spawn( "script_origin", self.origin );
    sound_ent PlayLoopSound( "amb_armory_alarm" );
    flag_wait( "rez_closed_door" );
    sound_ent StopLoopSound( 1 );
    wait(2);
    sound_ent Delete();
}