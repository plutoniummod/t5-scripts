#include common_scripts\utility;
#include maps\_utility;
#include maps\cuba_util;
#include maps\_anim;

main()
{
	level.vehicleSpawnCallbackThread = ::sf_vehicle;
	array_thread(getstructarray("script_model_police_car", "targetname"), ::script_model_police_car);

	level.overridePlayerDamage = ::override_player_damage;

	maps\cuba_street::delete_blockers();

	street();
	zipline_compound();
	escape();

	array_thread(GetEntArray("trigger_point", "script_noteworthy"), ::trigger_point);
	array_thread(getstructarray("trigger_point", "script_noteworthy"), ::trigger_point);

	array_thread(GetEntArray("set_wind_normal", "targetname"), ::trig_set_wind_normal);
	array_thread(GetEntArray("set_wind_goatpath", "targetname"), ::trig_set_wind_goatpath);

	array_func(GetEntArray("civ", "script_noteworthy"), ::add_spawn_function, maps\cuba_street::sf_civ_runners);
}

/* -------------------------------------------------------------------------------------------
Stuff that needs to happen before _load::main
-------------------------------------------------------------------------------------------- */
pre_load()
{
	incoming_bombers = GetEntArray("incoming_bombers", "targetname");
	level.incoming_bombers_size = incoming_bombers.size;
	for (i = 0; i < level.incoming_bombers_size; i++)
	{
		targetname = "incoming_bomber" + i;
		incoming_bombers[i].targetname = targetname;
	}

	beach_vehicles = GetEntArray("beach_vehicles", "targetname");
	level.beach_vehicles_size = beach_vehicles.size;
	for (i = 0; i < level.beach_vehicles_size; i++)
	{
		targetname = "beach_vehicles" + i;
		beach_vehicles[i].targetname = targetname;
	}
}

/* -------------------------------------------------------------------------------------------
Street specific stuff that happens on map load
-------------------------------------------------------------------------------------------- */
street()
{
}

/* -------------------------------------------------------------------------------------------
Escape specific stuff that happens on map load
-------------------------------------------------------------------------------------------- */
escape()
{
	downstair_runners = GetEntArray( "downstair_runners", "targetname" );
	array_thread( downstair_runners, ::add_spawn_function, maps\cuba_escape::downstair_ground_ambient_ai );

	pacifist_guy_goal = GetEntArray( "pacifist_guy_goal", "script_noteworthy" );
	array_thread( pacifist_guy_goal, ::add_spawn_function, ::pacifist_till_goal );

	courtyard_baddies = GetEntArray( "courtyard_baddies", "script_noteworthy" );
	array_thread( courtyard_baddies, ::add_spawn_function, maps\cuba_escape::courtyard_baddies_logic );
}

/* -------------------------------------------------------------------------------------------
zipline or compound specific stuff 
-------------------------------------------------------------------------------------------- */
zipline_compound()
{
	// enemies in compound section
	array_thread( GetEntArray( "compound_truck_enemy", "targetname" ), ::add_spawn_function, maps\cuba_compound::compound_truck_enemies_think );
	

	// special death animations for staircase enemies
	//SHolmes removing stair animation per notes
	array_thread( GetEntArray( "staircase_enemy", "targetname" ), ::add_spawn_function, maps\cuba_compound::staircase_enemy_think );
}

/* -------------------------------------------------------------------------------------------
Spawn Functions
-------------------------------------------------------------------------------------------- */
sf_hero()
{
	AssertEx(IsDefined(self.name), "Hero with no name.");

	self make_hero();

	name = ToLower(self.name);
	level.heroes[name] = self;

	flag_set(name + "!spawned");
	level thread squad_death(self);
}

squad_death(guy)
{
	name = ToLower(guy.name);
	guy waittill("death");
	flag_clear(name + "!spawned");
}

sf_vehicle(vehicle)
{
	if (IsDefined(vehicle.script_noteworthy))
	{
		switch (vehicle.script_noteworthy)
		{
		case "zpu_aa_gun":
			vehicle maps\cuba_util::init_zpu_aa_gun();
			break;
		}
	}
}
/* -------------------------------------------------------------------------------------------
End Spawn Functions
-------------------------------------------------------------------------------------------- */

/* ---------------------------------------------------------------------------------
structs that act like lookat triggers because lookat triggers blow.
--------------------------------------------------------------------------------- */
trigger_point()
{
	wait_for_all_players();

	self endon("death");

	if( IsDefined( self.script_flag_true ) )
	{
		level thread maps\_load_common::script_flag_true_trigger( self );
	}

	if( IsDefined( self.script_flag_set ) )
	{
		level thread maps\_load_common::flag_set_trigger( self, self.script_flag_set );
	}

	if( IsDefined( self.script_flag_clear ) )
	{
		level thread maps\_load_common::flag_clear_trigger( self, self.script_flag_clear );
	}

	if( IsDefined( self.script_flag_false ) )
	{
		level thread maps\_load_common::script_flag_false_trigger( self );
	}
// 
// 	if( IsDefined( self.script_autosavename ) || IsDefined( self.script_autosave ) )
// 	{
// 		level thread maps\_autosave::autosave_name_think( self );
// 	}

// 	if( IsDefined( self.script_fallback ) )
// 	{
// 		level thread maps\_spawner::fallback_think( self );
// 	}

// 	if( IsDefined( self.script_mgTurretauto ) )
// 	{
// 		level thread maps\_mgturret::mgTurret_auto( self );
// 	}

	if( IsDefined( self.script_killspawner ) )
	{
		level thread maps\_spawner::kill_spawner_trigger( self );
	}

// 	if( IsDefined( self.script_emptyspawner ) )
// 	{
// 		level thread maps\_spawner::empty_spawner( self );
// 	}

	if( IsDefined( self.script_prefab_exploder ) )
	{
		self.script_exploder = self.script_prefab_exploder;
	}

	if( IsDefined( self.script_exploder ) )
	{
		level thread maps\_load_common::exploder_load( self );
	}

// 	if( IsDefined( self.script_bctrigger ) )
// 	{
// 		level thread maps\_load_common::bctrigger( self );
// 	}
// 
// 	if( IsDefined( self.script_trigger_group ) )
// 	{
// 		self thread maps\_load_common::trigger_group();
// 	}

	if( IsDefined( self.script_notify ) )
	{
		level thread maps\_load_common::trigger_notify( self, self.script_notify );
	}

	self thread trigger_point_action();

	if (!IsDefined(self.script_timer))
	{
		self.script_timer = 0;
	}

	update_interval = .05;

	while (true)
	{
		player = get_players()[0];

		dot = .8;
		if (IsDefined(self.script_float))
		{
			dot = self.script_float;
		}

		if (	!is_true(self.trigger_off) &&
				player is_player_looking_at(self.origin, .8, self is_true(self.script_trace))
			)
		{
			timer = trigger_point_get_timer();

			/#
				Print3d(self.origin, timer, (1, 1, 1), 1, 2, Int(update_interval * 20));
			#/

			if (timer >= self.script_timer)
			{
				self notify("trigger", get_players()[0]);
			}
		}
		else
		{
			trigger_point_reset_timer();
		}

		wait update_interval;
	}
}

trigger_point_get_timer()
{
	t = GetTime();

	if (!IsDefined(self.trigger_point_timer_start))
	{
		self.trigger_point_timer_start = t;
	}

	return ((t - self.trigger_point_timer_start) / 1000);
}

trigger_point_reset_timer()
{
	self.trigger_point_timer_start = undefined;
}

trigger_point_action()
{
	self endon("death");

	while (true)
	{
		self waittill("trigger");

		if (IsDefined(self.target))
		{
			spawn_manager_enable(self.target, true);
		}

		/#
			Print3d(self.origin, "trigger", (1, 1, 1), 1, 2, 30);
		#/

		if (is_true(self.script_delete))
		{
			waittillframeend;

			if (IsDefined(self.classname) && (self.classname == "script_origin"))
			{
				self Delete();
			}
			else
			{
				self notify("death"); // fake death for structs
			}
		}
	}
}
/* ---------------------------------------------------------------------------------
End trigger point stuff
--------------------------------------------------------------------------------- */

run_and_delete()
{
	self endon( "death" );

	self.goalradius	= 64;
	self.health = 25;
	self.ignoreme = true;
	self.ignoreall = true;

	self waittill( "goal" );

	self Delete();
}

trig_set_wind_normal()
{
	self endon("death");

	while (true)
	{
		self waittill("trigger");
		
		maps\cuba_fx::wind_initial_setting();
		
		level notify("wind_changed");
		level waittill("wind_changed");
	}
}

trig_set_wind_goatpath()
{
	self endon("death");

	while (true)
	{
		self waittill("trigger");

		maps\cuba_fx::wind_goatpath_setting();

		level notify("wind_changed");
		level waittill("wind_changed");
	}
}

override_player_damage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	switch (sMeansOfDeath)
	{
	case "MOD_EXPLOSIVE":
		{
			if (IsDefined(eInflictor)
				&& IsDefined(eInflictor.classname)
				&& (eInflictor.classname == "script_vehicle"))
			{
				self ShellShock("death", 3);
				self SetStance("crouch");
				iDamage = 0;
			}

			break;
		}
	}

	if (is_true(self.no_magic_bullet_damage))
	{
		if (IsDefined(eAttacker.classname) && (eAttacker.classname == "worldspawn"))
		{
			iDamage = 0;
		}
	}

	return iDamage;
}

script_model_police_car()
{
	lights_on = true;
	sirens_on = true;

	group = self.script_vehiclespawngroup;
	level waittill("spawnvehiclegroup" + group);

	car = Spawn("script_model", self.origin, 0, 0, 0, "veh_cuban_police_destructible");
	car.angles = self.angles;

	car.destructibledef = "veh_cuban_police_destructible";
	car thread maps\_destructible::destructible_think();

	car.script_noteworthy = self.script_noteworthy;
	car.targetname = self.script_string;

	// Sirens
	//lights_org = Spawn("script_model", car GetTagOrigin("tag_origin_animate_jnt"));
	//lights_org.angles = car GetTagAngles("tag_origin_animate_jnt");
	lights_org = Spawn("script_model", car GetTagOrigin("tag_body"));
	lights_org.angles = car GetTagAngles("tag_body");
	lights_org SetModel("tag_origin");
	lights_org LinkTo(car);

	PlayFXOnTag(level._effect["siren_light"], lights_org, "tag_origin");

	// Front D-light
	PlayFXOnTag(level._effect["head_dlight"], lights_org, "tag_origin");

	// Left Taillight
	taillight_left_org = Spawn("script_model", car GetTagOrigin("tag_brakelight_left"));
	taillight_left_org.angles = car GetTagAngles("tag_brakelight_left");
	taillight_left_org SetModel("tag_origin");
	taillight_left_org LinkTo(car);

	PlayFXOnTag(level._effect["taillight_left"], taillight_left_org, "tag_origin");

	// Right Taillight
	taillight_right_org = Spawn("script_model", car GetTagOrigin("tag_brakelight_right"));
	taillight_right_org.angles = car GetTagAngles("tag_brakelight_right");
	taillight_right_org SetModel("tag_origin");
	taillight_right_org LinkTo(car);

	PlayFXOnTag(level._effect["taillight_right"], taillight_right_org, "tag_origin");

	// Left Headlight
	headlight_left_org = Spawn("script_model", car GetTagOrigin("tag_headlight_left"));
	headlight_left_org.angles = car GetTagAngles("tag_headlight_left");
	headlight_left_org SetModel("tag_origin");
	headlight_left_org LinkTo(car);

	PlayFXOnTag(level._effect["head_lights"], headlight_left_org, "tag_origin");

	// Right Headlight
	headlight_right_org = Spawn("script_model", car GetTagOrigin("tag_headlight_right"));
	headlight_right_org.angles = car GetTagAngles("tag_headlight_right");
	headlight_right_org SetModel("tag_origin");
	headlight_right_org LinkTo(car);

	PlayFXOnTag(level._effect["head_lights"], headlight_right_org, "tag_origin");

	car waittill("death");

	lights_org Delete();
	taillight_left_org Delete();
	taillight_right_org Delete();
	headlight_left_org Delete();
	headlight_right_org Delete();
}