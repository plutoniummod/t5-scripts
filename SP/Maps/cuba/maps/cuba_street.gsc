#include common_scripts\utility;
#include maps\_utility;
#include maps\cuba_util;
#include maps\_vehicle;
#include maps\_anim;
#include maps\cuba_drive;
#include maps\_music;

#using_animtree("generic_human");

start()
{
 	level.movie_fade_in_time = .5;

	level.QTE_duck = false;
	level.enable_car_turning = true;

	level.spawnerCallbackThread = ::spawn_think;

	level.magicbullet_weapon = "rpk_magicbullet_noflash";

	init_street();
	spawn_funcs();

	vehicles();

	get_players()[0] SetMoveSpeedScale(.70);

	if (!IsDefined(level.start_point)
		|| level.start_point == "default"
		|| level.start_point == "bar"
		|| level.start_point == "street")
	{
		// This stuff is only for starting at the beginning of the street
		event_thread("street", ::turn_around);
	}
	
	if (level.start_point != "drive")
	{
		heroes_controller();
	}

	event_thread("street", ::battle_flow);
	event_thread("street", ::stand_off);
	event_thread("street", ::saves);
	event_thread("street", ::fire_hydrant);
	event_thread("street", ::police_chatter);
	event_thread("street", ::cleanup_before_alley);
	event_thread("street", ::alley_bullets);
	event_thread("street", ::kill_zone);
	event_thread("street", ::player_in_alley_watch);

	getaway();

	//TUEY Audio notify
	clientNotify ("sm");

	wait (level.movie_fade_in_time);

	level thread streamer_hint();
	//level thread save_when_movie_is_done();	//SHolmes: removing

	level thread cleanup();

	// delete heroes before we spawn new ones (they have different character models)
	array_func(get_heroes_by_name("woods", "bowman"), ::self_delete);

	level thread movie_rumble();
 	
	level waittill("movie_done");
	//-- GLocke: Rest Dvar used during movie playback
	SetSavedDvar("r_streamFreezeState", 0);

	level.spawnerCallbackThread = undefined;

	player = get_players()[0];
	player ShowViewModel();
	player Unlink();
	player DisableInvulnerability();
	player FreezeControls(false);
	player AllowStand(true);
	player AllowCrouch(true);
	player AllowProne(true);
	player EnableWeapons();

	player SetClientDvar( "cg_fov", GetDvarFloat( #"cg_fov_default") );

	level.car Delete();
	level.player_model Delete();
	level.player_camera Delete();

	wait(.05);//Sholmes:wait a frame to ensure angles change properly
	
	get_heroes_by_name("woods", "bowman");
	start_teleport("start_zipline", "squad");

	//TUEY Audio notify
	clientNotify ("md");
}

movie_rumble()
{
	flag_wait("movie_loaded");

	wait 12;

	for (i = 0; i < 20; i++)
	{
		get_players()[0] PlayRumbleOnEntity("damage_heavy");
		wait RandomFloatRange(.1, .3);
	}
}

streamer_hint()
{
	struc = getstruct("start_zipline", "targetname");
	streamer_hint = CreateStreamerHint(struc.origin, 1.0);
	level waittill("movie_done");
	wait 2;
	streamer_hint Delete();
}
/*
save_when_movie_is_done()
{
	flag_waitopen("movie_loaded");
	wait 4;
	autosave_by_name("car_end");
}
*/
init_street()
{
	level.woods = get_hero_by_name("woods");
	level.bowman = get_hero_by_name("bowman");
	level.carlos = get_hero_by_name("carlos");
	
	level.woods ent_flag_init("ready_to_dodge_car");
	level.bowman ent_flag_init("ready_to_dodge_car");
	
	level.bowman ent_flag_init("in_alley");

	level.disableLongDeaths = true;

	array_thread(GetEntArray("trig_sparks", "targetname"), ::trig_sparks);

	level.path_anim_func["alley_wait"] = ::carlos_sprint_down_alley;

	GetEnt("drive_get_in", "targetname") trigger_off();

	node_array = GetNodeArray("police_car_5", "script_noteworthy");
	array_thread(node_array, ::police_car_5_nodes);
}

trig_sparks()
{
	level endon("street_complete");
	org = getstruct(self.target, "targetname");

	elec_box_orgs = [];
	while (IsDefined(org))
	{
		elec_box_orgs = array_add(elec_box_orgs, org);

		if (IsDefined(org.target))
		{
			org = getstruct(org.target, "targetname");
		}
		else
		{
			break;
		}
	}

	if (!IsDefined(level.elec_box_orgs))
	{
		level.elec_box_orgs = [];
	}

	level.elec_box_orgs = array_combine(level.elec_box_orgs, elec_box_orgs);

	self endon("death");
	self waittill("trigger");
	self thread do_trig_sparks(elec_box_orgs);
}

do_trig_sparks(orgs)
{
	level endon("street_complete");

	for (i = 0; i < orgs.size; i++)
	{
		org = orgs[i];

		wait RandomFloatRange(.1, .5);

		RadiusDamage(org.origin, 100, 100, 100);

		if (org.script_noteworthy == "top")
		{
			//PlayFXOnTag(level._effect["elec_box_top"], org, "tag_origin");
			PlayFX(level._effect["elec_box_top"], org.origin, AnglesToForward(org.angles), AnglesToUp(org.angles));
		}
		else
		{
			//PlayFXOnTag(level._effect["elec_box_bottom"], org, "tag_origin");
			PlayFX(level._effect["elec_box_bottom"], org.origin, AnglesToForward(org.angles), AnglesToUp(org.angles));
		}
	}
}

fire_hydrant()
{
	fire_hydrant = GetEnt("fire_hydrant", "targetname");
	flag_wait("blow_fire_hydrant");
	PlayFXOnTag(level._effect["fire_hydrant"], fire_hydrant, "tag_origin");
}

spawn_funcs()
{
	array_func(GetEntArray("turn_around_guys", "targetname"), ::add_spawn_function, ::sf_turn_around_guys);
	array_func(GetEntArray("runaway_guys", "targetname"), ::add_spawn_function, ::sf_runaway_guys);
	array_func(GetEntArray("in_front_of_car_civs", "targetname"), ::add_spawn_function, ::in_front_of_car_civs);
	array_func(GetEntArray("street_alley_chasers", "targetname"), ::add_spawn_function, ::street_alley_chasers);
	array_func(GetEntArray("street_blockade_guys", "targetname"), ::add_spawn_function, ::street_blockade_guys);
	array_func(GetEntArray("drive_street_blockers_spawner", "targetname"), ::add_spawn_function, ::drive_street_blockers);
	array_func(GetEntArray("vehicle_riders", "targetname"), ::add_spawn_function, ::veh_rider_ragdoll_delay);
}

// don't let guys ragdoll right away when they're getting out of the car
// AI_TODO: next project - may want to look at extending this in a more generic way for all AI
veh_rider_ragdoll_delay()
{
	self endon("death");

	self.allow_ragdoll_getout_death = false;

	self waittill("jumping_out");

	// approximately enough time for the AI to be at least partially out
	// so that the ragdoll pushes out in the correct direction
	wait(1.5);

	self.allow_ragdoll_getout_death = true;
}

in_front_of_car_civs()
{
	self.takedamage = false;
}

sf_civ_runners()
{
	self endon("death");
	self.goalradius = 0;
	self waittill("goal");
	self Delete();
}

spawn_think(spawn)
{
	spawn endon("death");

	if (IsDefined(self.script_flag_wait))
	{
		if (!IsDefined(level.flag[self.script_flag_wait]))
		{
			flag_init(self.script_flag_wait);
		}
	}

	if (IsDefined(spawn.script_animation))
	{
		spawn thread do_spawn_anim();
	}

	if (flag("turn_around") && !flag("turn_back"))
	{
		if (!IsDefined(spawn.aigroup) || (spawn.aigroup != "street_group_4"))
		{
			spawn.ignoreme = true;
			flag_wait("turn_back");
			spawn.ignoreme = false;
		}
	}
}

do_spawn_anim()
{
	self endon("death");

	self.align = self;
	if (IsDefined(self.target))
	{
		node = GetNode(self.target, "targetname");
		if (IsDefined(node))
		{
			self.align = node;
			self.align anim_generic_reach_aligned(self, self.script_animation);
		}
	}
	else
	{
		self.goalradius = 0;
		self SetGoalPos(self.origin);
	}

	if (IsDefined(self.script_flag_wait))
	{
		flag_wait(self.script_flag_wait);
	}

	self anim_set_blend_in_time(.3);
	
	self.align anim_generic_aligned(self, self.script_animation);

	if (is_true(self.script_death))
	{
		self ragdoll_death();
	}
	else
	{
		self.goalradius = 0;
		self SetGoalPos(self.origin);

		self set_ignoreall(false);
		self shoot_at_target(level.player_model, "tag_camera", 0, -1);
	}
}

heroes_controller()
{
	heroes = get_heroes_by_name("woods", "bowman", "carlos");
	
	for (i = 0; i < heroes.size; i++)
	{
		hero = heroes[i];

		hero thread hero_movement();
		hero thread make_effective();
	}
}

make_effective()
{
	level endon("street_complete");
	self endon("death");

	self.script_accuracy = 3;

	PERFECT_AIM_DIST_SQ = 250 * 250;

	while (true)
	{
		self waittill("enemy");

		if (IsDefined(self.enemy))
		{
			if (DistanceSquared(self.origin, self.enemy.origin) <= PERFECT_AIM_DIST_SQ)
			{
				self.perfectaim = true;
			}
			else
			{
				if (!is_true(self.keep_perfect_aim))
				{
					self.perfectaim = false;
				}
			}
		}
	}
}

perfect_aim(toggle)
{
	self.keep_perfect_aim = toggle;
	self.perfectaim = toggle;
}

hero_movement()
{
	level endon("street_complete");

	self endon("death");
	self endon("stop_hero_movement");

	self ent_flag_init("cuba_end_path");

	path = [];
	path_node = GetNode(ToLower(self.name) + "_path", "targetname");
	while (IsDefined(path_node))
	{
		path = array_add(path, path_node);

		if (IsDefined(path_node.target))
		{
			path_node = GetNode(path_node.target, "targetname");
		}
		else
		{
			path_node = undefined;
		}
	}

	self enable_cqbwalk();
	self enable_heat();

	wait 1;

	suppressionthreshold = self.suppressionthreshold;
	grenadeawareness = self.grenadeawareness;
	pathenemylookahead = self.pathenemylookahead;
	pathenemyfightdist = self.pathenemyfightdist;
	fixednodesaferadius	= self.fixednodesaferadius;

	disable_ai_color();

	GOAL_RADIUS = 20;

	self.goalradius = GOAL_RADIUS;
	self.disablearrivals = true;

	self.pathenemyfightdist = 0;
	self.pathenemylookahead = 0;
	self.ignoresuppression = true;
	self.suppressionthreshold = 1;
	self.nododgemove = true;
	self.grenadeawareness = 0;
	self.meleeattackdist = 0;
	self.fixednodesaferadius = 0;
	
	MAX_DIST_SQ = 800 * 800;
	SPRINT_DIST_SQ = 200 * 200;

	i = 0;
	while (IsDefined(path[i]))
	{
		while (is_true(self.cuba_pause_path))
		{
			wait .05;
		}

		if (IsDefined(self.cuba_next_node))
		{
			// advance to next node
			if (!IsDefined(path[i].script_noteworthy) || (path[i].script_noteworthy != self.cuba_next_node))
			{
				i += 1;
				continue;
			}
		}

		self.cuba_next_node = undefined;

		if (!FindPath(self.origin, path[i].origin))
		{
			wait .05;
			continue;
		}

		dist = DistanceSquared(get_players()[0].origin, self.origin);
		player_in_front = self player_in_front(get_players()[0]);

		if (player_in_front)
		{
			enable_cqbsprint();
		}
		else
		{
			disable_cqbsprint();
		}

		if (is_true(self.cuba_keep_moving) || (dist < MAX_DIST_SQ) || player_in_front)
		{
			if (IsDefined(path[i].radius) && (path[i].radius != 0))
			{
				self.goalradius = path[i].radius;
			}
			else
			{
				self.goalradius = GOAL_RADIUS;
			}

			if (!self cuba_path_animation(path[i], true))
			{
				self set_goal_node(path[i]);
				self waittill("goal");
			}

			if (IsDefined(path[i].script_notify))
			{
				self notify(path[i].script_notify);
			}

			if (IsDefined(path[i].script_disable_cqbwalk))
			{
				self disable_cqbwalk();
			}
			else if (IsDefined(path[i].script_enable_cqbwalk))
			{
				self enable_cqbwalk();
			}

			if (IsDefined(path[i].script_ignoreall))
			{
				self set_ignoreall(path[i].script_ignoreall);
			}

			if (IsDefined(path[i].script_flag_set))
			{
				self ent_flag_set(path[i].script_flag_set);
			}

			if (IsDefined(path[i].script_aigroup))
			{
				waittill_ai_group_cleared(path[i].script_aigroup);
			}

			if (IsDefined(path[i].script_flag_wait))
			{
				flag_wait(path[i].script_flag_wait);
			}

			if (IsDefined(path[i].script_waittill)
				&& (path[i].script_waittill != "look_at"))
			{
				self waittill(path[i].script_waittill);
			}

			if (IsDefined(path[i].script_wait))
			{
				path[i] script_wait();
			}

			self cuba_path_animation(path[i]);

			i += 1;
		}
		else
		{
			// wait for player to catch up
			wait .2;			
		}
	}

	enable_pain();

	self.suppressionthreshold = suppressionthreshold;
	self.grenadeawareness = grenadeawareness;
	self.pathenemylookahead = pathenemylookahead;
	self.pathenemyfightdist = pathenemyfightdist;
	self.fixednodesaferadius = fixednodesaferadius;
	
	self.disablearrivals = undefined;
	self.ignoresuppression = false;
	self.nododgemove = false;

	self set_ignoreall(false);

	self ent_flag_set("cuba_end_path");
}

cuba_path_animation(path, before)
{
	if (IsDefined(path.script_animation))
	{
		if (IsDefined(path.script_string) && flag(path.script_string))
		{
			return false;
		}

		if (is_true(before)
			&& (!IsDefined(path.script_parameters)
			|| (path.script_parameters != "anim_after")))
		{
			self do_path_anim(path, true);
			return true;
		}
		else if (!is_true(before)
			&& IsDefined(path.script_parameters)
			&& (path.script_parameters == "anim_after"))
		{
			if (IsDefined(path.angles))
			{
				self OrientMode("face angle", path.angles[1]);
				wait .3;
			}

			self do_path_anim(path);
			return true;
		}
	}

	return false;
}

do_path_anim(path, b_reach)
{
	self anim_set_blend_in_time(.3);

	if (is_true(b_reach))
	{
		if (IsDefined(path.script_int))
		{
			path anim_reach_aligned(self, path.script_animation);
		}
		else
		{
			path anim_reach(self, path.script_animation);
		}
	}

	if (IsDefined(path.script_string) && flag(path.script_string))
	{
		return false;
	}

	self do_path_anim_anim(path);
	self anim_set_blend_in_time();
}

do_path_anim_anim(path)
{
	player = get_players()[0];

	if (IsDefined(path.script_waittill)
		&& (path.script_waittill == "look_at"))
	{
// 		if (!player is_player_looking_at(self.origin, .6, false))
// 		{
// 			path anim_first_frame(self, path.script_animation);
// 			player waittill_player_looking_at(self.origin, .6, false);
// 		}
	}

	self notify(path.script_animation);

	if (IsDefined(level.path_anim_func[path.script_animation]))
	{
		self thread [[ level.path_anim_func[path.script_animation] ]]();
	}

	if (is_true(path.script_looping))
	{
		if (IsDefined(path.script_int))
		{
			path anim_loop_aligned(self, path.script_animation);
		}
		else
		{
			path anim_loop(self, path.script_animation);
		}
	}
	else
	{
		if (IsDefined(path.script_int))
		{
			path anim_single_aligned(self, path.script_animation);
		}
		else
		{
			path anim_single(self, path.script_animation);
		}
	}

	self notify(path.script_animation);
}

player_in_front(player)
{
	forward = AnglesToForward(self.angles);
	vec = player.origin - self.origin;

	if (VectorDot(forward, vec) > .4)
	{
		return true;
	}

	return false;
}

delete_blockers()
{
	blockers = GetEntArray("car_vis_blockers", "targetname");
	array_func(blockers, ::self_delete);
}

vehicles()
{
	level.cuba_custom_getouts["police_car_2"]["tag_driver"]		= %ch_police_exit_car_01;
	level.cuba_custom_getouts["police_car_2"]["tag_passenger"]	= %ch_police_exit_car_02;

 	level.cuba_custom_getouts["police_car_3"]["tag_driver"]		= %ch_police_out_of_car_C_driver;
 	level.cuba_custom_getouts["police_car_3"]["tag_passenger"]	= %ch_police_out_of_car_C_pass;

	level.cuba_custom_getouts["police_car_4"]["tag_driver"]		= %ch_police_out_of_car_D_driver;
	level.cuba_custom_getouts["police_car_4"]["tag_passenger"]	= %ch_police_out_of_car_D_pass;

	level.cuba_custom_getouts["police_car_5"]["tag_driver"]		= %ai_cuba_police01_death;

	level.cuba_custom_getouts["police_car_8"]["tag_driver"]		= %ch_police_out_of_car_C_driver;
	level.cuba_custom_getouts["police_car_8"]["tag_passenger"]	= %ch_police_out_of_car_C_pass;

	level.cuba_custom_getouts["police_car_13"]["tag_driver"]	= %ch_police_out_of_car_D_driver;
	level.cuba_custom_getouts["police_car_13"]["tag_passenger"]	= %ch_police_out_of_car_D_pass;

	level.cuba_custom_getouts["crash_car"]["tag_driver"]	= %ai_cuba_police02_death;
	level.cuba_custom_getouts["crash_car"]["tag_passenger"]	= %ai_cuba_police01_passenger_death;

	level.cuba_custom_getouts["crash_car_2"]["tag_driver"]	= %ai_cuba_police03_death;

	level.vehicle_noteworthy_funcs["police_car_2"]	= ::police_car_2;
	level.vehicle_noteworthy_funcs["police_car_3"]	= ::police_car_3;
	level.vehicle_noteworthy_funcs["police_car_4"]	= ::police_car_4;
	level.vehicle_noteworthy_funcs["police_car_5"]	= ::police_car_5;
	level.vehicle_noteworthy_funcs["police_car_13"]	= ::police_car_13;

	level.vehicle_noteworthy_funcs["crash_car"]		= ::crash_car;
	level.vehicle_noteworthy_funcs["crash_car_2"]	= ::crash_car_2;

	level.vehicle_noteworthy_funcs["end_of_street_cars"]	= ::end_of_street_cars;

	add_spawn_function_veh("police_cars",	::police_cars);
	add_spawn_function_veh("police_cars2",	::police_cars2);
	add_spawn_function_veh("police_cars",	::play_veh_drive_audio);
}

set_street_objective()
{
	get_players()[0] SetClientDvar("cg_objectiveIndicatornearFadeDist", 500);

	set_objective(level.OBJ_STREET, level.woods, "follow");
}

police_cars()
{
	self endon("death");
	self thread affect_friendlies();

	self._vehicle_use_interior_lights = true;

	self thread maps\cuba_util::play_sirens();

	self maps\_vehicle::godon();
	self police_cars_noteworthy();

	self waittill("reached_end_node");
	self maps\_vehicle::godoff();
}

police_cars2()
{
	self thread police_cars();
	self._vehicle_use_interior_lights = false;
}

affect_friendlies()
{
	level endon("start_drive");
	squad = array(level.woods, level.bowman, level.carlos);

	self waittill("death");

	if (IsDefined(self))
	{
		for (i = 0; i < squad.size; i++)
		{
			if (IsAlive(squad[i]))
			{
				if (Distance2DSquared(self.origin, squad[i].origin) < 400 * 400)
				{
					squad[i] DoDamage(300, self.origin, self, undefined, "explosive");
				}
			}
		}
	}
}

police_cars_noteworthy()
{
	if (IsDefined(self.script_noteworthy))
	{
		custom_getouts = level.cuba_custom_getouts[self.script_noteworthy];
		if (IsDefined(custom_getouts))
		{
			if (IsDefined(custom_getouts["tag_driver"]))
			{
				self vehicle_override_anim("getout", "tag_driver", custom_getouts["tag_driver"]);
			}

			if (IsDefined(custom_getouts["tag_passenger"]))
			{
				self vehicle_override_anim("getout", "tag_passenger", custom_getouts["tag_passenger"]);
			}
		}

		if (IsDefined(level.vehicle_noteworthy_funcs[self.script_noteworthy]))
		{
			self thread [[ level.vehicle_noteworthy_funcs[self.script_noteworthy] ]]();
		}
	}
}

police_car_2()
{
	if (IsDefined(level.start_point)
		&& level.start_point == "alley")
	{
		self Delete();
	}

	self.dontunloadonend = true;

	self waittill("reached_end_node");

	wait 2;

	fx_org = Spawn("script_model", self GetTagOrigin("tag_body"));
	fx_org.angles = self GetTagAngles("tag_body");
	fx_org SetModel("tag_origin");
	PlayFXOnTag(level._effect["engine_fire"], fx_org, "tag_origin");

	//self DoDamage(1000, self.origin, level.woods);

	wait 4;

	self DoDamage(1000, self.origin, level.woods);
	fx_org Delete();

	wait 1;

	level thread show_alt_weapon_message();
}

clear_alt_weapon_message()
{
	level waittill("start_drive");
	screen_message_delete();
}

show_alt_weapon_message()
{
	level thread clear_alt_weapon_message();
	level endon("start_drive");

	player = get_players()[0];

	flag_wait("player_used_ads");
	while (!flag("player_used_alt_weapon"))
	{
		curr_weapon = player GetCurrentWeapon();
		if (is_weapon_attachment(curr_weapon))
		{
			flag_set("player_used_alt_weapon");
			screen_message_delete();
			return;
		}
		else
		{
			has_alt_weapon = false;
			weapons_list = player GetWeaponsList();
			for ( i = 0; i < weapons_list.size; i++)
			{
				if( is_weapon_attachment( weapons_list[i] ) )
				{
					has_alt_weapon = true;
					screen_message_create(&"CUBA_HINT_ALT_WEAPON");
					thread screen_message_delay_fade_delete( 10, "start_drive", 0, "player_used_alt_weapon" );
					break;
				}
			}

			if (!has_alt_weapon)
			{
				screen_message_delete();
			}
		}

		player waittill("weapon_change", weapon);
	}
}

police_car_3()
{
	if (IsDefined(level.start_point)
		&& level.start_point == "alley")
	{
		self Delete();
	}
}

police_car_4()
{
	if (IsDefined(level.start_point)
		&& level.start_point == "alley")
	{
		self Delete();
	}
}

end_of_street_cars()
{
	self waittill("reached_end_node");
	floodlights_on();
}

police_car_5_nodes()
{
	SetEnableNode(self, false);
}

police_car_5_enable_nodes()
{
	self waittill("reached_end_node");
	node_array = GetNodeArray("police_car_5", "script_noteworthy");
	for (i = 0; i < node_array.size; i++)
	{
		SetEnableNode(node_array[i], true);
	}
}

police_car_5()
{
	self thread police_car_5_enable_nodes();

	self.dontunloadonend = true;
	driver = self.riders[0]; // the only guy in the car

	driver.vehicle_idle_override = %ai_cuba_police01_struggle;

	driver.a.nodeath = true;
	driver.overrideActorDamage = ::police_car_5_driver_damage;

	level.woods thread police_car_5_kill_driver(self, driver);

	self thread police_car_5_death();
	self endon("death");
	
	driver waittill_either("damage", "shot");

	flag_set("shoot_up_car_guy_dead");

	driver.allow_ragdoll_getout_death = false;
	driver.a.nodeath = false;
	driver.overrideActorDamage = undefined;
	self vehicle_unload();	// unload anim kills dude
}

police_car_5_death()
{
	self waittill("death");
	flag_set("shoot_up_car_guy_dead");
}

police_car_5_driver_damage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime)
{
	if (is_true(self.a.doingRagdollDeath) || (sMeansOfDeath == "MOD_EXPLOSIVE"))
	{
		return iDamage;
	}
	else if (IsPlayer(eAttacker))
	{
		return 1;
	}

	return 0;
}

sf_runaway_guys()
{
	self.ignoreme = true;
	self endon("death");
	flag_wait("street_runaway");
	node = GetNode("runaway_node", "targetname");
	self thread force_goal();
	self delete_at_node(node);
}

police_car_5_kill_driver(car, driver)
{
	driver endon("death");
	self waittill("shoot_up_car");
	wait .5;
	driver notify("shot");
}

police_car_13()
{
	self.dontunloadonend = true;
	flag_wait("almost_slomo");
	self vehicle_unload();	// unload anim kills dude
}

crash_car()
{
 	self waittill("reached_end_node");

	fx_org = self GetTagOrigin("tag_body");
	fx_ang = self GetTagAngles("tag_body");

	fire_fx = Spawn("script_model", fx_org);
	fire_fx SetModel("tag_origin");
	fire_fx.angles = fx_ang;

	PlayFXOnTag(level._effect["engine_fire"], fire_fx, "tag_origin");

	self thread crash_car_explode();
	self thread crash_car_drop_sign();

	self waittill("death");
	
	fire_fx Delete();
}

crash_car_explode()
{
	self endon("death");
	wait 3;
	self DoDamage(11000, self.origin);
}

crash_car_drop_sign()
{
	self waittill("death");
	wait 1;
	GetEnt("sign_sparks_trig", "script_noteworthy") notify("trigger");
	level notify("cuba_sign_start");
}

crash_car_2()
{
	self waittill("reached_end_node");

 	org = getstruct("fruit_stand_eplosion", "targetname");
 	PhysicsExplosionSphere(org.origin, org.radius, org.radius / 2, 20, 50);
}

police_spotlight()
{
	wait(randomfloatrange(0.1, 1));
	
	PlayFXOnTag(level._effect["police_floodlight"], self, "tag_origin");
	self playsound ("evt_spotlight");
	flag_wait("player_by_car");
	self Delete();
}

battle_flow()
{
	set_ai_group_cleared_count("street_group_0", 1);
	set_ai_group_cleared_count("street_group_1", 1);
	set_ai_group_cleared_count("street_group_2", 1);
	set_ai_group_cleared_count("street_group_3", 1);
	//set_ai_group_cleared_count("street_group_4", 1);
	set_ai_group_cleared_count("street_group_7", 1);
	//set_ai_group_cleared_count("street_group_last", 1);

	waittill_ai_group_cleared("street_group_2");
	flag_set("keep_moving");
}

police_chatter()
{
	while (true)
	{
		if (flag("police_chatter"))
		{
			axis = GetAIArray("axis");
			for (i = 0; i < axis.size; i++)
			{
				guy = axis[i];
				if (!IsAlive(guy))
				{
					continue;
				}

				if (cointoss())
				{
					type = "normal";
					if (RandomIntRange(0,100)<=12)
					{
						type = "radio";
					}

					vo_array = level.police_chatter[type]["chatter"];

					if (cointoss() && !IsDefined(self.ridingvehicle))
					{
						guy PlaySound(random(vo_array), "police_chatter");
						guy waittill_either("police_chatter", "death");
					}
				}
			}
		}

		wait(3.5);
	}
}

saves()
{
	waittill_ai_group_cleared("street_group_5");
	autosave_by_name("street_1");
}

turn_around()
{
	array_thread(array(level.woods, level.bowman), ::get_ready_to_dodge);

	level flag_wait("dodge_car");
	array_thread(array(level.woods, level.bowman), ::dodge_car);

	spawn_manager_enable("turn_around_spawner");
	playsoundatposition ("evt_police_megaphone_1", (-12168, -2072, -768));

	wait 2;

	
	
	level.woods play_vo("behind_us");

	level.woods perfect_aim(true);
	level.bowman perfect_aim(true);
	waittill_ai_group_cleared("street_group_4");

	wait .2;

	level.woods.cuba_pause_path = true;
	level.bowman.cuba_pause_path = true;

	level.carlos play_vo("thanks");

	level.bowman thread turn_back();

	wait .5;	// staggered movement

	level.woods turn_back();

	flag_set("turn_back");

	get_players()[0].no_magic_bullet_damage = true;

	level.woods play_vo("into_the_alley");
	level.woods play_vo("get_to_the_car");

	wait  1;

	level.bowman play_vo("reinforcements"); //Reinforcements!

	wait .5;

	level.woods play_vo("too_many_of_them"); //Shit... Too many of them!

	level.woods play_vo("cover_our_six"); //Shit... Too many of them!

	//TUEY set music to STREET
	setmusicstate ("STREET_ENDING");


	flag_wait("player_by_car");
	get_players()[0].no_magic_bullet_damage = undefined; // at this point I don't care if you get hit by magic bullets - get in the car!
}

sf_turn_around_guys()
{
	if (!IsDefined(level.turn_around_guys_count))
	{
		level.turn_around_guys_count = 0;
	}

	level.turn_around_guys_count++;

	if (level.turn_around_guys_count == 3)
	{
		// this is the last guy

		level.woods thread shoot_at_target_untill_dead(self, undefined, 3);
	}
}

turn_back()
{
	level anim_single(self, "heat_180");
	self.cuba_pause_path = undefined;
	self.cuba_next_node = "node_turn_back";
	self perfect_aim(false);
	self disable_cqbwalk();
	self notify("turn_back");
}

kill_zone()
{
	flag_wait("player_in_alley");
	trig = GetEnt("trig_player_kill_zone", "targetname");

	while (!flag("start_drive"))
	{
		trig waittill("trigger", player);
		if (IsPlayer(player))
		{
			trig thread trigger_thread(player, ::player_in_kill_zone, ::player_not_in_kill_zone);		
		}
	}

	delete_punk_buster();
	trig Delete();
}

player_in_kill_zone(player, endon_condition)
{
	player endon(endon_condition);

	spawn_manager_enable("drive_street_blockers");

	bullet_orgs = getstructarray("player_kill_zone_orgs", "targetname");

	while (!flag("start_drive"))
	{
		start_org = random(bullet_orgs).origin;
		end_org = player.origin + (RandomIntRange(-200, 200), RandomIntRange(-200, 0), 0);
		MagicBullet(level.magicbullet_weapon, start_org, end_org);

		wait .05;
	}
}

player_not_in_kill_zone(player)
{
	spawn_manager_disable("drive_street_blockers");
}

drive_street_blockers()
{
	self.overrideActorDamage = ::no_magicbullet_damage;
	self endon("death");
	self.goalradius = 128;
	self SetGoalEntity(get_players()[0]);
	flag_wait("start_drive");
	self ragdoll_death();
}

stand_off()
{
	level endon("player_in_car");

	flag_wait("stand_off");

	wait 2; // wait for cars to get in place
	playsoundatposition ("evt_police_megaphone_2", (-12168, -2072, -768));
	
	spawn_manager_enable("standoff_spawner");

	//Spotlight
	spotlights = GetEntArray("police_spotlight_fx", "targetname");
	array_thread(spotlights, ::police_spotlight);

	event_thread("street", ::set_floodlight_vision);

	player = get_players()[0];
	player thread stand_off_bullets();
	player thread stand_off_damage();
}

stand_off_bullets()
{
	self endon("death");
	level endon("player_in_car");

	mb_orgs = getstructarray("blockade_magic_bullet_orgs", "targetname");

	while (true)
	{
		start_org = random(mb_orgs).origin;
		end_org = self.origin + (RandomInt(200), RandomInt(200), 0);

		MagicBullet(level.magicbullet_weapon, start_org, end_org);
		wait .05;
	}
}

stand_off_damage()
{
	self endon("death");

	kill_trig = GetEnt("standoff_kill_trig", "targetname");

	floodlights_org = getstruct("floodlights_org", "targetname");

	while (!flag("player_in_car"))
	{
		if (self IsTouching(kill_trig))
		{
			self DoDamage(20, floodlights_org.origin, get_punk_buster());
			wait .4;
		}
		else
		{
			if (BulletTracePassed( floodlights_org.origin, self get_eye(), false, undefined))
			{
				self DoDamage(5, floodlights_org.origin, get_punk_buster());
			}

			wait 3;
		}

		wait .05;
	}
}

street_blockade_guys()
{
	self SetEntityTarget(get_players()[0]);
}

set_floodlight_vision()
{
	level endon("player_in_car");

	org = getstruct("floodlights_org", "targetname");

	while (true)
	{
		if (get_players()[0] is_player_looking_at(org.origin, .5, true))
		{
			VisionSetNaked("cuba_streets_floodlights", 1);
		}
		else
		{
			VisionSetNaked("cuba_streets", 1);
		}

		wait .05;
	}
}

floodlights_on()
{
	//PlayFxOnTag(level._effect["police_floodlight"], self, "tag_mirror_left");
	//wait RandomFloat(.5);
	PlayFxOnTag(level._effect["police_floodlight"], self, "tag_mirror_right");
}

get_ready_to_dodge()
{
	level endon("dodge_car");
	self endon("death");
	self ent_flag_wait("ready_to_dodge_car");
 	self set_ignoreall(true);
	self.cuba_keep_moving = true;
	self waittill("wait_for_car");
	
	wait 5;

	trig = GetEnt("trig_turn_back_cars", "targetname");
	if (IsDefined(trig))
	{
		trig notify("trigger");
	}
}

dodge_car()
{
	if (self ent_flag("ready_to_dodge_car"))
	{
		self AnimCustom(::dodge_car_anim);
		self waittill("dodge_car_done");
	}
	else
	{
		self.cuba_pause_path = true;
		level flag_wait("turn_around");
	}

	self.cuba_pause_path = undefined;
	self.cuba_next_node = "node_turn_around";
	self notify("goal"); // stop going to current node, go to next one

	self set_ignoreall(false);
}

dodge_car_anim()
{
	disable_pain();
	disable_react();

	animation = self get_anim("dodge_car");

	self SetFlaggedAnimKnobAll("dodge_car", animation, %root, 1, .2, 1);
	self do_notetracks("dodge_car");

	enable_pain();
	enable_react();

	self notify("dodge_car_done");
}

street_alley_chasers()
{
	self endon("death");
	self.goalradius = 128;
	self SetGoalEntity(get_players()[0]);
}

getaway()
{
	flag_wait("start_drive_event");

	level.car = scripted_spawn(90)[0];
	level.car thread player_vehicle();
	level.car thread maps\cuba_amb::play_car_radio();
	
	sound_tag = level.car GetTagOrigin( "tag_engine_left" );
	sound_ent = spawn ("script_origin", sound_tag);
	sound_ent linkto (level.car);
	sound_ent playloopsound ("evt_car_idle");

	flag_wait_either("street_group_5_cleared", "player_by_car");
	get_players()[0] SetClientDvar("player_sprintUnlimited", 1);

	array_func(get_heroes_by_name("woods", "bowman", "carlos"), ::disable_pain);

	if (!IsDefined(level.start_point)
		|| level.start_point != "drive")
	{
		get_players()[0] SetMoveSpeedScale(1);
		get_players()[0] SetClientDvar("player_sprintUnlimited", 1);

		level.bowman thread bowman_sprint_down_alley();
		level.woods thread woods_sprint_down_alley();
	}

	flag_wait("friendlies_by_car");

	obj_org = Spawn("script_origin", level.car GetTagOrigin("tag_driver"));
	set_objective(level.OBJ_CAR, obj_org, "enter");

	level.car HidePart("tag_drivers_seat");
	level.car ShowPart("tag_drivers_seat_objective");

	level.woods thread get_to_the_car_nag();

	GetEnt("drive_get_in", "targetname") trigger_on();
	trigger_wait("drive_get_in");
	obj_org Delete();

	flag_wait("start_drive");
	
	/////////////////////////////////////////////////////////////////////////////////
	//Adding vision call for inside the car (colin)
	//Adding fog too :)
	VisionSetNaked( "cuba_car", 5 );
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.2 );
	SetSavedDvar( "r_lightGridContrast", 0.0 );
	
	start_dist = 330.464;
	half_dist = 485.741;
	half_height = 379.546;
	base_height = -844.179;
	fog_r = 0.133333;
	fog_g = 0.145098;
	fog_b = 0.156863;
	fog_scale = 7.82455;
	sun_col_r = 0.439216;
	sun_col_g = 0.501961;
	sun_col_b = 0.501961;
	sun_dir_x = 0.737921;
	sun_dir_y = -0.573606;
	sun_dir_z = 0.355598;
	sun_start_ang = 0;
	sun_stop_ang = 55.1892;
	time = 0;
	max_fog_opacity = 0.840488;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
 /////////////////////////////////////////////////////////////////////////////////

	level.car HidePart("tag_drivers_seat_objective");
	level.car ShowPart("tag_drivers_seat");

	level.car waittill("drive_getin");
	flag_set("player_in_car");
	/////////////////////////////////////////////////////////////////////////////////
	//Adding vision call for inside the car (colin)
	//Adding fog too :)
	VisionSetNaked( "cuba_car", 5 );
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.2 );
	SetSavedDvar( "r_lightGridContrast", 0.0 );
	
	start_dist = 330.464;
	half_dist = 485.741;
	half_height = 379.546;
	base_height = -844.179;
	fog_r = 0.133333;
	fog_g = 0.145098;
	fog_b = 0.156863;
	fog_scale = 7.82455;
	sun_col_r = 0.439216;
	sun_col_g = 0.501961;
	sun_col_b = 0.501961;
	sun_dir_x = 0.737921;
	sun_dir_y = -0.573606;
	sun_dir_z = 0.355598;
	sun_start_ang = 0;
	sun_stop_ang = 55.1892;
	time = 0;
	max_fog_opacity = 0.840488;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
 /////////////////////////////////////////////////////////////////////////////////
	battlechatter_off();

	level.car waittill("drive_done");
	level notify("drive_done");
	sound_ent stoploopsound();
	sound_ent delete();

	screen_message_delete();

	wait .85;

	level notify("start_movie");

	Objective_State(level.OBJ_CAR, "done");
	get_players()[0] EnableInvulnerability();
	get_players()[0] FreezeControls(true);
}

get_to_the_car_nag()
{
	self endon("death");
	level endon("start_drive");

	wait 5;

	carlos_nag_array = maps\cuba_anim::create_carlos_nag_array( "carlos_alley" );
	level thread do_vo_nag_loop( "carlos", carlos_nag_array, "player_in_alley", 5 );

	flag_wait("player_in_alley");

	level thread alley_cleanup();

	wait 3;

	woods_nag_array = maps\cuba_anim::create_woods_nag_array( "woods_alley" );
	level thread do_vo_nag_loop( "woods", woods_nag_array, "start_drive", 4, ::filter_nag_vo );
}

filter_nag_vo()
{
	if (get_players()[0] is_player_looking_at(level.car.origin + (0, 0, 70), .7, true))
	{
		return false;
	}
	
	return true;
}

bowman_sprint_down_alley()
{
	self endon("death");

	self ent_flag_wait("in_alley");

	disable_cqbsprint();
	disable_cqbwalk();

	self.sprint = true;
	self force_goal();
}

woods_sprint_down_alley()
{
	self endon("death");

	disable_cqbsprint();
	disable_cqbwalk();

	self.sprint = true;
	self force_goal();
}

carlos_sprint_down_alley()
{
	self endon("death");

	self waittill("alley_wait"); // intro anim done

	self thread anim_loop(self, "alley_wait_loop");

	wait .05;

	flag_wait("player_in_alley");

// 	self waittill("_anim_playing");
// 	wait 1;

	self anim_stopanimscripted(.5);

	disable_cqbsprint();
	disable_cqbwalk();

	self.sprint = true;
	self force_goal();
}

alley_bullets()
{
	level endon("backing_up");

	flag_wait("player_in_alley");

	level.bullet_start_org = getstruct("alley_target", "targetname");
	bullet_end_orgs = getstructarray("alley_targets", "targetname");

	player = get_players()[0];

	max_time = 8;

	while (max_time > 0)
	{
		bullet_end_orgs = array_randomize(bullet_end_orgs);
		for (i = 0; i < bullet_end_orgs.size; i++)
		{
			if (IsDefined(bullet_end_orgs[i]) && IsDefined(bullet_end_orgs[i].origin))
			{
				if (!player is_player_looking_at(level.bullet_start_org.origin, .4, false))
				{
					hit = bullet_end_orgs[i].origin + (RandomIntRange(-10, 10), RandomIntRange(-10, 10), RandomIntRange(-10, 10));
					MagicBullet(level.magicbullet_weapon, level.bullet_start_org.origin, hit);
				}
			}

			wait .1;
			max_time -= .1;
		}

		wait .05;
		max_time -= .05;
	}
}

no_magicbullet_damage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime)
{
	// don't get hurt by all the magic bullets flying around
	if (IsDefined(eAttacker.classname) && (eAttacker.classname == "worldspawn"))
	{
		iDamage = 0;
	}

	return iDamage;
}

get_punk_buster()
{
	if (!IsDefined(level.punk_buster))
	{
		level.punk_buster = simple_spawn_single("punk_buster");
		if (IsDefined(level.punk_buster))
		{
			level.punk_buster.goalradius = 0;
			level.punk_buster SetGoalPos(level.punk_buster.origin);
			level.punk_buster.takedamage = false;
			level.punk_buster set_ignoreall(true);
		}
	}
	
	return level.punk_buster;
}

delete_punk_buster()
{
	if (IsDefined(level.punk_buster))
	{
		level.punk_buster Delete();
	}
}

player_in_alley_watch()
{
	level endon("player_in_car");

	trig = GetEnt("alley_trig", "targetname");

	while (!flag("player_in_car"))
	{
		trig waittill("trigger", player);	
		trig thread trigger_thread(player, ::player_in_alley, ::player_not_in_alley);
	}
}

player_in_alley(player, endon_condition)
{
	player endon("endon_condition");
	level endon("player_in_car");
	flag_set("player_in_alley");
}

player_not_in_alley(player)
{
	level endon("player_in_car");
	flag_clear("player_in_alley");

	while (!flag("player_in_alley") && !flag("player_in_car"))
	{
		player DoDamage(50, player.origin, get_punk_buster());
		wait .2;
	}
}

attach_models()
{
	self HidePart("tag_drivers_seat_objective");

	self HidePart("tag_glass_lf_d");
	self HidePart("tag_glass_rf_d");
	self HidePart("tag_glass_lb_d");
	self HidePart("tag_glass_rb_d");
	
	self HidePart("tag_glass_back_d");

	// windshield
	self HidePart("tag_glass_front");
	self HidePart("tag_glass_front_d");

	level.car_fxanim_model = GetEnt("fxanim_cuba_car_props_mod", "targetname");
	level.car_fxanim_model LinkTo(self, "body_animate_jnt", (0, 0, 0), (0, 0, 0));
	level.car_fxanim_model.animname = "fxanim_props";

	self thread anim_loop_aligned(level.car_fxanim_model, "a_car_fan", "body_animate_jnt");

	level.car_fxanim_cigar = GetEnt("fxanim_cuba_car_cig_mod", "targetname");
	level.car_fxanim_cigar LinkTo(self, "body_animate_jnt", (0, 0, 0), (0, 0, 0));
	level.car_fxanim_cigar.animname = "fxanim_props";

	level.slomo_start_orgs = GetEntArray("slomo_tracer_start_org", "targetname");
	for (i = 0; i < level.slomo_start_orgs.size; i++)
	{
		level.slomo_start_orgs[i] LinkTo(self);
	}

	level.slomo_end_orgs = GetEntArray("slomo_tracer_end_org", "targetname");
	for (i = 0; i < level.slomo_end_orgs.size; i++)
	{
		level.slomo_end_orgs[i] LinkTo(self);
	}
}

mission_fail_on_car_death()
{
	level endon("player_in_car");
	self waittill("death");
	mission_failed();
}

player_vehicle()
{
	self thread mission_fail_on_car_death();

	self attach_models();

	self ent_flag_init("going");
	self init_anim_model("car");

	self anim_first_frame(self, "drive_player_getin");

	player = get_players()[0];
	//trigger_wait("drive_get_in");
	flag_wait("start_drive");

	self.takedamage = false;

	level.carlos thread play_vo("see_you");

	player AllowCrouch(false);
	player AllowProne(false);

	while (is_true(player.divetoprone))
	{
		wait .05;
	}

	set_objective(level.OBJ_CAR);
	delaythread(1, ::pre_drive_cleanup);

	self drive_thread(::drive_spawn_thread);

	VisionSetNaked("cuba_drive", 1);

	spawn_manager_kill("standoff_spawner");

	level.player_model = spawn_anim_model("player");
	level.player_camera = spawn_anim_model("player_cam");
	level.player_camera Hide();

	level.player_model Hide();

	level.player_model link_to_car(self);
	level.player_camera link_to_car(self);

	player link_to_car();

	self thread anim_single(self, "drive_player_getin");
	self anim_single_aligned(array(level.player_model, level.player_camera), "drive_player_getin", "tag_driver");

	level thread carlos_leaves();

	self thread anim_loop(self, "drive_lookback");
	self thread anim_loop_aligned(level.woods, "drive_lookback", "body_animate_jnt");
	self thread anim_loop_aligned(array(level.player_model, level.player_camera), "drive_lookback", "tag_driver");

	start_movie_scene();
	add_scene_line(&"CUBA_VOX_CUB1_S01_950A_INTE", 1, 7);
	add_scene_line(&"CUBA_VOX_CUB1_S01_951A_INTE", 9, 2.5);
	add_scene_line(&"CUBA_VOX_CUB1_S01_952A_MASO", 12, 5.5);
	
	level thread play_movie("mid_cuba_1", false, false, "start_movie", true, "movie_done", 3);

	show_drive_hint_reverse();

	//TUEY reverse sound
	playsoundatposition("evt_car_reverse", (0,0,0));

	level thread simple_spawn("drive_by_guys", ::sf_drive_by_guys);

	self drive_thread(::backup_hit_stuff);

	level.bowman anim_set_blend_in_time(1);
	level.car thread anim_loop_aligned(level.car_fxanim_model, "a_car_props", "body_animate_jnt");

	self notify("going");
	self thread go_path();
	self drive_thread(::backup_anims);

	flag_set("backing_up");

	self thread backup_shake();
	self waittill_multiple("reached_end_node", "drive_backward");

	flag_clear("backing_up");

	get_players()[0] DisableInvulnerability();

	level.woods thread play_vo("gtfo");

	//self drive_thread(::drive_fov);
	self drive_thread(::drive_fx);
 	self drive_thread(::speedometer);

	self drive_thread(::turn_car);

	show_drive_hint_forward();

	Earthquake(.2, 5, self.origin, 300);
	get_players()[0] PlayRumbleOnEntity("cuba_peelout");

	self thread break_fence1();
	self thread break_fence2();

// 	self anim_stopanimscripted();
// 	level.player_model anim_stopanimscripted();

	self thread anim_single_aligned(array(level.woods, level.bowman), "start_forward1", "body_animate_jnt");
	self thread anim_single_aligned(level.player_camera, "start_forward1", "tag_driver");
// 	level.player_model SetFlaggedAnim("start_forward1", level.player_model get_anim("start_forward1"), 1, 0, 1);
	self SetFlaggedAnim("start_forward1", self get_anim("start_forward1"), 1, 0, 1);

	playsoundatposition("evt_car_speed_forward", (0,0,0));

	self waittill("hit_dudes");
	playsoundatposition ("evt_hit_dudes", self.origin);
	level.woods thread play_vo("dammit2");

	self waittill("slomo");

	screen_message_delete();

	level.bowman anim_set_blend_in_time(undefined);
	self drive_thread(::duck);

	anim_ents = array(level.woods, level.bowman);
	self thread anim_single(self, "drive_slomo");
	self drive_thread(::speedometer);

	self thread anim_single_aligned(anim_ents, "drive_slomo", "body_animate_jnt");
	self anim_single_aligned(array(level.player_model, level.player_camera), "drive_slomo", "tag_driver");

	self thread anim_loop_aligned(array(level.woods, level.bowman), "drive_forward2", "body_animate_jnt");
	self thread anim_loop_aligned(level.player_camera, "drive_forward2", "tag_driver");

	//self drive_thread(::turn_car);

	level thread end_drive_vo();
	
	wait .5;

	self.driving_state = 2;
	player thread drive_turning_anims(self, level.player_model, 2);

	self drive_thread(::ram_through_stuff);
}

end_drive_vo()
{
	level.bowman play_vo("roadblock");
	get_players()[0] play_vo("i_see_it");
	level.woods play_vo("floor_it");
}

backup_shake()
{
	self waittill("reached_end_node");
	drive_shake();
}

drive_shake()
{
	Earthquake(.5, .5, level.car.origin, 300);
	get_players()[0] PlayRumbleOnEntity("grenade_rumble");
}

drive_spawn_thread()
{
	wait 4;
	level thread simple_spawn("car_reverse_enemies", ::car_reverse_enemies);
	self waittill("spawn_drive_1");
	level thread simple_spawn("spawn_drive_1", ::spawn_drive_1);
	self waittill("spawn_drive_2");
	level thread simple_spawn("spawn_drive_2", ::spawn_drive_2);
}

drive_fov()
{
	MAX_FOV = 70;
	MAX_FOV_SPEED = 75;

	while (true)
	{
		speed = self GetSpeedMPH();
		fov = linear_map(speed, 20, MAX_FOV_SPEED, GetDvarFloat( #"cg_fov_default"), MAX_FOV);
		get_players()[0] SetClientDvar( "cg_fov", fov );
		wait .05;
	}
}

drive_fx()
{
	FX_SPEED = 30;

	while (true)
	{
		speed = self GetSpeedMPH();

		if (speed >= FX_SPEED)
		{
			self play_drive_particle_fx();
		}
		else
		{
			self stop_drive_particle_fx();
		}

		wait .3;
	}
}

play_drive_particle_fx()
{
	if (!IsDefined(self.fx_org))
	{
		self.fx_org = Spawn("script_model", self GetTagOrigin("body_animate_jnt"));
		self.fx_org SetModel("tag_origin");
		self.fx_org.anlges = self GetTagAngles("body_animate_jnt");
		self.fx_org LinkTo(self, "body_animate_jnt", (0, 0, 0), (0, 0, 0));
		PlayFXOnTag(level._effect["car_wind"], self.fx_org, "tag_origin");
	}
}

stop_drive_particle_fx()
{
	if (IsDefined(self.fx_org))
	{
		self.fx_org Delete();
	}
}

set_fov(speed)
{
	if (!IsDefined(speed))
	{
		speed = self._rappel.current_speed;
	}

	fov = linear_map(speed, 0, self._rappel.fail_speed, GetDvarFloat( #"cg_fov_default"), self._rappel.fov_max);
	self SetClientDvar( "cg_fov", fov );

	// 	PrintLn("fov: " + fov);
}

car_go(ent)
{
	//GetEnt("trig_drive_road_civs", "targetname") notify("trigger");

	//level.player_camera waittillmatch("start_forward1", "drive_fwd");
	self thread go_path(GetVehicleNode("player_spline", "targetname"));
	create_vehicle_from_spawngroup_and_gopath(88);
	StopAllRumbles();

	get_players()[0] EnableInvulnerability();
}

backup_anims()
{
	self thread anim_single(self, "drive_backward");
	self thread anim_single_aligned(array(level.woods, level.bowman), "drive_backward", "body_animate_jnt");

	self thread anim_single_aligned(level.player_camera, "drive_backward", "tag_driver");

	level.player_model anim_set_blend_out_time(.5);
	self anim_single_aligned(level.player_model, "drive_backward", "tag_driver");

	self AnimScripted("drive_lookforward", self.origin, self.angles, self get_anim("drive_lookforward"));
	//self SetFlaggedAnimKnob("drive_lookforward", self get_anim("drive_lookforward"), 1, 0, 1);
 	//level.player_model AnimScripted("drive_lookforward", self GetTagOrigin("tag_driver"), self GetTagAngles("tag_driver"), level.player_model get_anim("drive_lookforward"));

	get_players()[0] thread drive_turning_anims(self, level.player_model, 1);

	self thread anim_loop_aligned(array(level.bowman, level.woods), "drive_lookforward", "body_animate_jnt");
	self thread anim_loop_aligned(level.player_camera, "drive_lookforward", "tag_driver");
}

start_bowman_anim(player)
{
	level.car endon("going");
	level.car anim_single_aligned(level.bowman, "drive_lookback", "body_animate_jnt");
	level.car anim_loop_aligned(level.bowman, "drive_lookback2", "body_animate_jnt");
}

woods_and_bowman_getin(player)
{
	anim_ents = array(level.woods, level.bowman);

	for (i = 0; i < anim_ents.size; i++)
	{
		anim_ents[i] DisableClientLinkTo();
	}

	array_func(anim_ents, ::link_to_car, self);
	level.car anim_single_aligned(anim_ents, "drive_getin", "body_animate_jnt");
}

link_to_car(car)
{
	if (IsPlayer(self))
	{
		self thread link_player_to_car(car);
	}
	else if ((self == level.player_model) || (self == level.player_camera))
	{
		self LinkTo(car, "tag_driver");
	}
	else
	{
		self LinkTo(car, "body_animate_jnt");
	}
}

link_player_to_car(car)
{
	self HideViewModel();
	self DisableWeapons();

	self StartCameraTween(.1);
	self PlayerLinkToDelta(level.player_camera, "tag_camera", 1, 10, 10, 5, 5);

	wait .3;

 	level.player_model Show();
}

warp_car(ent)
{
	//level.player_model waittillmatch("drive_slomo", "warp_car");

	// Where we're going, we need more road
	// Warp back to a earlier point on the spline

	node = GetVehicleNode("warp_back", "script_noteworthy");
	level.car thread go_path(node);

	maps\_vehicle::scripted_spawn(99);
}

sf_spawn_drive_gate_1()
{
	self endon("death");
	level endon("start_movie");

	target = GetEnt("spawn_drive_gate_1_target", "targetname");
	//self thread shoot_at_target(target, undefined, 0, -1);
	self thread aim_at_target(target, -1);

	wait 3;

	for (i = 0; i < 100; i++)
	{
		self Shoot();
		wait RandomFloatRange(.05, .15);
	}
}

sf_spawn_drive_gate_2()
{
	self endon("death");
	level endon("start_movie");

	target = GetEnt("spawn_drive_gate_2_target", "targetname");
	self thread aim_at_target(target, -1);

	wait 4;
	//-- GLocke: Set Dvar used during movie playback
	SetSavedDvar("r_streamFreezeState", 1);

	for (i = 0; i < 100; i++)
	{
		self Shoot();
		wait RandomFloatRange(.05, .15);
	}
}

mark_past_nodes()
{
	while (true)
	{
		self waittill("reached_node", node);
		node.past = true;
	}
}

turn_car()
{
	//self endon("slomo");

	if (is_true(level.enable_car_turning))
	{
		level.player_spline = [];
		level.player_spline_original_pos = [];
		level.player_spline_right = [];

		node = GetVehicleNode("player_spline", "targetname");
		while (IsDefined(node) && IsDefined(node.target))
		{
			node = GetVehicleNode(node.target, "targetname");
			if (IsDefined(node))
			{
				level.player_spline = array_add(level.player_spline, node);
				level.player_spline_original_pos = array_add(level.player_spline_original_pos, node.origin);
				level.player_spline_right = array_add(level.player_spline_right, AnglesToRight(node.angles));
			}
		}

		self thread mark_past_nodes();
	}

	player = get_players()[0];

	self.right_left = 0;

	SPLINE_RADIUS = 50;

	while (true)
	{
		self.right_left = player GetNormalizedMovement()[1];

		if (is_true(level.enable_car_turning))
		{
			for (i = 0; i < level.player_spline.size; i++)
			{
				node = level.player_spline[i];

				if (!is_true(node.past))
				{
					right_ang = level.player_spline_right[i];

					new_org = level.player_spline_original_pos[i] + self.right_left * right_ang * SPLINE_RADIUS;
					node.origin = new_org;

					/#
	// 					DebugStar(new_org, 20, (1, 1, 1));
					#/
				}
			}
		}

		wait .05;
	}
}

drive_thread(func, arg1, arg2, arg3, arg4, arg5)
{
	self thread do_drive_thread(func, arg1, arg2, arg3, arg4, arg5);
}

do_drive_thread(func, arg1, arg2, arg3, arg4, arg5)
{
	self endon("death");
	single_func(self, func, arg1, arg2, arg3, arg4, arg5);
}

sf_drive_by_guys()
{
	self endon("death");

	target = GetEnt("drive_by_target", "targetname");

	self SetEntityTarget(target, 1, "tag_camera");
	self.a.allow_shooting = false;
	self.cansee_override = true;

	flag_wait("drive_slomo");

	//wait .2;

	self thread shoot_at_target(target, "tag_camera", 0, -1);

	for (i = 0; i < 5; i++)
	{
		//MagicBullet("rpk_sp", self GetTagOrigin("tag_flash"), random(level.slomo_end_orgs).origin);
		self Shoot();
		wait .05;
	}
}

duck()
{
	//NOTIFY for audio
	clientNotify ("tsi");
	
	wait .5;

	SetTimeScale(.1);

	flag_set("drive_slomo");

	self damage_side_windows();

	wait .1;

	
	playsoundatposition ("evt_slomo_glass", (0,0,0));
	playsoundatposition ("mus_quimbara_slotime", (0,0,0));

	self drive_thread(::glass_break_l);
	self drive_thread(::glass_break_f);
	self drive_thread(::glass_break_r);

	// windshield
	self ShowPart("tag_glass_front");
	self ShowPart("tag_glass_front_d");
	self HidePart("tag_windshield");

	level thread timescale_tween(.1, 1, .15);
	playsoundatposition ("evt_shotgun_to_window", (0,0,0));
	wait .1;

	duck_cleanup();
	self thread duck_bullets();

	drive_shake();

	player = get_players()[0];
	player.health = 100;

	player StartCameraTween(.2);
	player PlayerLinkToAbsolute(level.player_camera, "tag_camera");

	wait .2;

	level thread timescale_tween(1, .06, .4);

	level thread spawn_gate_guys_and_delete_others();

	level.car thread anim_single_aligned(level.car_fxanim_cigar, "a_car_cig", "body_animate_jnt");
	PlayFXOnTag(level._effect["cig_smk"], level.car_fxanim_cigar, "cig_fx_jnt");
	playsoundatposition ("evt_cigarette", (0,0,0));
	playsoundatposition ("vox_woods_scream", (0,0,0));
	wait .10;
	flag_clear("drive_slomo");
	timescale_tween(.1, 1, 1.2);
	//NOTIFY for audio
	clientNotify ("tso");
	playsoundatposition ("evt_car_rev", (0,0,0));

	self drive_thread(::kick_windshield_fx);
	
	player StartCameraTween(.2);
	player PlayerLinkToDelta(level.player_camera, "tag_camera", 1, 10, 10, 5, 5);
}

spawn_gate_guys_and_delete_others()
{
	wait .2;

	old_guys = GetEntArray("drive_by_guys", "targetname");
	array_func(old_guys, ::self_delete);

	old_guys = GetAIArray("axis", "neutral");
	array_func(old_guys, ::self_delete);

	simple_spawn("spawn_drive_gate_1", ::sf_spawn_drive_gate_1);
	simple_spawn("spawn_drive_gate_2", ::sf_spawn_drive_gate_2);
}

damage_side_windows()
{
	self ShowPart("tag_glass_lf_d");
	self HidePart("tag_glass_lf");

	self ShowPart("tag_glass_rf_d");
	self HidePart("tag_glass_rf");
}

duck_bullets()
{
	while (flag("drive_slomo"))
	{
		for (i = 0; i < level.slomo_start_orgs.size; i++)
		{
			MagicBullet("rpk_sp", level.slomo_start_orgs[i].origin, random(level.slomo_end_orgs).origin);
		}

		wait .05;
	}
}

glass_break_l()
{
	for (i = 0; i < 10; i++)
	{
		PlayFXOnTag(level._effect["glass_brk_l"], self, "body_animate_jnt");
		PlayFXOnTag(level._effect["glass_brk_l"], self, "body_animate_jnt");
		wait .05;
	}
}

glass_break_f()
{
	PlayFXOnTag(level._effect["glass_brk_kick"], self, "body_animate_jnt");
	
	for (i = 0; i < 5; i++)
	{
		PlayFXOnTag(level._effect["glass_brk_f"], self, "body_animate_jnt");
		wait .1;
	}

	PlayFXOnTag(level._effect["glass_brk_kick"], self, "body_animate_jnt");
}

glass_break_r()
{
	for (i = 0; i < 10; i++)
	{
		PlayFXOnTag(level._effect["glass_brk_r"], self, "body_animate_jnt");
		PlayFXOnTag(level._effect["glass_brk_r"], self, "body_animate_jnt");
		wait .05;
	}
}

kick_windshield_fx()
{
	drive_shake();
	for (i = 0; i < 6; i++)
	{
		PlayFXOnTag(level._effect["glass_brk_kick"], self, "body_animate_jnt");
		wait .2;
	}
}

show_drive_hint_reverse()
{
	screen_message_create(&"CUBA_HINT_DRIVE_REVERSE");

	while (!get_players()[0] ads_button_held())
	{
		wait .05;
	}

	screen_message_delete();
}

show_drive_hint_forward()
{
	FAIL_TIME = 4;
	screen_message_create(&"CUBA_HINT_DRIVE_FORWARD");

	while (!get_players()[0] attack_button_held())
	{
// 		if ((t_now - t_going) / 1000 > FAIL_TIME)
// 		{
// 			get_players()[0] Suicide();
// 			return;
// 		}

		wait .05;
// 		t_now = GetTime();
	}

	screen_message_delete();
}

carlos_leaves()
{
	level.carlos Delete();	// TODO: carlos runs away
}

car_reverse_enemies()
{
	self endon("death");
	self set_ignoreall(true);
	self waittill("goal");
	self set_ignoreall(false);
	self thread shoot_at_target(level.player_camera, "tag_camera", 0, -1);
	self thread damage_player();
	self thread damage_back_window();
	self waittill("drive_backward"); // backward anim done
	self Delete();
}

damage_player()
{
	self endon("death");

	while (IsDefined(self))
	{
		self waittill("shoot");
		get_players()[0] DoDamage(50, self get_eye(), self);
	}
}

damage_back_window()
{
	self endon("death");
	self waittill("shoot");
	level.car HidePart("tag_glass_back");
	level.car ShowPart("tag_glass_back_d");

	while (true)
	{
		PlayFXOnTag(level._effect["glass_brk_b"], level.car, "body_animate_jnt");
		wait .1;
		self animscripts\weaponList::RefillClip();
	}
}

spawn_drive_1()
{
	self endon("death");
	self set_ignoreall(true);
	self waittill("goal");
	self set_ignoreall(false);
	self thread shoot_at_target(level.player_camera, "tag_camera", 0, -1);
	flag_wait("drive_slomo");
	self Delete();
}

spawn_drive_2()
{
	self endon("death");
	self set_ignoreall(true);
	self waittill("goal");
	self set_ignoreall(false);
	flag_wait("drive_slomo");
	flag_waitopen("drive_slomo");
	self Delete();
}

ram_through_stuff()
{
	while (true)
	{
		self RadiusDamage(self.origin, 500, 2000, 2000, undefined, "MOD_EXPLOSIVE");
		wait .05;
	}
}

break_fence1()
{
	self endon("death");
	self waittill("break_fence1");
	exploder(250);
	self playsound ("evt_break_fence");
	self RadiusDamage(self.origin, 400, 2000, 2000, undefined, "MOD_EXPLOSIVE");
	level drive_shake();
}

break_fence2()
{
	self endon("death");
	self waittill("break_fence2");
	exploder(260);
	self playsound ("evt_break_fence");
	self RadiusDamage(self.origin, 400, 2000, 2000, undefined, "MOD_EXPLOSIVE");
	level drive_shake();
}

backup_hit_stuff()
{
	self endon("drive_backward");

	struct = getstruct("drive_backup_hit_trashcan_struct", "targetname");
	
	wait 1.4;
	playsoundatposition ("evt_car_hit_trashcan", struct.origin);
	get_players()[0] EnableInvulnerability();
	self RadiusDamage(struct.origin, 300, 300, 300, undefined, "MOD_EXPLOSIVE");
	
}

cleanup_before_alley()
{
	trigger_wait("trig_stand_off");
	//getstruct("trig_stand_off", "targetname") waittill("trigger");

	//clean_up("blocker_cars_01", "script_noteworthy");
	clean_up("bar_exit_police_driver", "targetname");
	clean_up("bar_exit_police_pass", "targetname");
	clean_up("outside_bar_civ_spawner", "targetname");
	clean_up("outside_bar_police_spawner", "targetname");
	clean_up("vehicle_riders", "targetname");
}

pre_drive_cleanup()
{
	spawn_manager_kill("sm_alley_chasers");
	spawn_manager_kill("standoff_spawner");

	clean_up("outside_bar_civ_spawner", "targetname");
	clean_up("outside_bar_police_spawner", "targetname");
	clean_up("blocker_cars_01", "script_noteworthy");
	clean_up("civ_spawn_triggers", "targetname");
	clean_up("police_cars", "targetname");
	clean_up("street_cars", "targetname");
	clean_up("vehicle_riders2", "targetname");

	street_blockade_guys = get_ai_group_ai("street_blockade_guys");
	array_func(street_blockade_guys, ::self_delete);

	street_alley_chasers = get_ai_group_ai("street_alley_chasers");
	array_func(street_alley_chasers, ::self_delete);

	clean_up("trig_player_kill_zone", "targetname");
}

alley_cleanup()
{
	clean_up("police_car_1", "script_noteworthy");
	clean_up("police_car_2", "script_noteworthy");
	clean_up("police_car_4", "script_noteworthy");
	clean_up("blocker_cars_01", "script_noteworthy");
}

duck_cleanup()
{
	level thread clean_up("duck_cars", "script_noteworthy");
	clean_up("police_car_13", "script_noteworthy");
	clean_up("police_spotlight", "targetname");
	clean_up("blocker_cars", "script_noteworthy");
	clean_up("end_of_street_cars", "script_noteworthy");
	clean_up("spawn_drive_2", "targetname");
	clean_up("spawn_drive_2_ai", "targetname");
}

cleanup()
{
	level notify("street_complete"); // kill event threads

	pre_drive_cleanup();
	duck_cleanup();

	clean_up("blocker_cars_01", "script_noteworthy");
	clean_up("bar_exit_police_driver", "targetname");
	clean_up("bar_exit_police_pass", "targetname");
	clean_up("outside_bar_civ_spawner", "targetname");
	clean_up("outside_bar_police_spawner", "targetname");
	clean_up("vehicle_riders", "targetname");

	ai = GetAIArray("axis", "neutral");
	array_func(ai, ::self_delete);

	clean_up("trig_stand_off", "targetname");
	clean_up("police_spotlight", "targetname");
	clean_up("blocker_cars", "script_noteworthy");
	clean_up("end_of_street_cars", "script_noteworthy");
	clean_up("police_cars2", "targetname");
	clean_up("trig_sparks", "targetname");
	clean_up("vehicle_riders", "targetname");
	clean_up("slomo_tracer_start_org", "targetname");
	clean_up("slomo_tracer_end_org", "targetname");
}

#using_animtree("vehicles");
speedometer()
{
 	self maps\_vehicle_dials::add_dial_vehicle(%v_cub_b01_car_tag_speedometer_delta);
 	self maps\_vehicle_dials::add_animated_dial("speed", %v_cub_b01_car_tag_speedometer_additive, ::get_normalized_speed);
}

get_normalized_speed()
{
	if (!IsDefined(level.last_speed_val))
	{
		level.last_speed_val = 0;
	}

	if (!flag("drive_slomo"))
	{
		speed = self GetSpeedMPH();
		val = linear_map(speed, 0, 100, 0, 1);

		if (val > .5)
		{
			// above 50 mph, shake a little
			val -= RandomFloat(.05);
		}

		level.last_speed_val = val;
		return val;
	}
	else
	{
		return level.last_speed_val;
	}
}

/* -------------------------------------------------------------------------------------------
Spawn func for car that crashes into light pole
-------------------------------------------------------------------------------------------- */

//**********************
//  AUDIO SECTION
//**********************

play_veh_drive_audio()
{
    ent = Spawn( "script_origin", self.origin );
    self thread play_veh_skid_audio(ent);
    ent LinkTo( self, "tag_driver" );
    ent PlayLoopSound( "veh_jeep_move_high" );
    //self waittill( "reached_end_node" );
    self waittill_any("reached_end_node","skidding");
    ent StopLoopSound( .25 );
    playsoundatposition( "veh_police_car_stop", ent.origin );
    wait(1);
    ent Delete();
}
play_veh_skid_audio(ent)
{
	self waittill( "start_skid" );
	//iprintlnbold ("SKIDDING");
	ent playsound( "veh_car_skid" );
	self notify( "skidding" );
}
