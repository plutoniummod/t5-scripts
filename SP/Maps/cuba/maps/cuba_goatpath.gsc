#include common_scripts\utility;
#include maps\_utility;
#include maps\cuba_util;
#include maps\_vehicle;
#include maps\_anim;
#include maps\_music;

/* ---------------------------------------------------------------------------------
This script handles the ambients of the beach and surroundings as the player gets to
the top of the goat path.
--------------------------------------------------------------------------------- */
start()
{
	setup();

	player = get_players()[0];
	player SetMoveSpeedScale(1);

	flag_set("street_done"); // turns on triggers
	//level thread stop_first_drones();
	setmusicstate ("END_STREET");

	event_thread("goatpath", ::meet_up);

	flag_wait("meetup_finished");

	set_objective(level.OBJ_GOATPATH, get_hero_by_name("woods"), "follow");

	trigger_wait("start_goatpath");
	flag_set("transition_sky");
	
	trigger_wait("start_beach");
	event_thread("goatpath", ::vo);

	level thread spawn_beach_vehicles();

	player SetLowReady(true);

	flag_wait( "start_zipline_event" );
}

setup()
{
	//level.max_drones["axis"] = 999999999;
	//level._drones_sounds_disable = 1;
	//level.drone_spawnFunction["axis"] = character\c_cub_tropas_drone::main;

	level.disableLongDeaths = undefined;
}

/* ---------------------------------------------------------------------------------
MEETUP: after street is cleared, group has brief meetup and Carlos splits
--------------------------------------------------------------------------------- */
meet_up()
{
	if (!flag("meetup_finished"))
	{
		level notify ("street_fight_over");
		woods = get_hero_by_name("woods");
		carlos = get_hero_by_name("carlos");
		bowman = get_hero_by_name("bowman");

		woods.nododgemove = true;
		carlos.nododgemove = true;

		woods ent_flag_wait("cuba_end_path");
		carlos ent_flag_wait("cuba_end_path");
		//bowman ent_flag_wait("cuba_end_path");

		Objective_State(level.OBJ_MISC, "done");
		Objective_State(level.OBJ_MISC2, "done");
		Objective_State(level.OBJ_STREET, "done");

		autosave_by_name("cuba_meetup");

		level endon("player_reached_goatpath");

		event_thread("goatpath", ::meet_up_end);

		bowman set_ignoreall(true);
		anim_single(array(woods, carlos), "meetup");
		bowman set_ignoreall(false);

		flag_set("meetup_finished");
	}
}

meet_up_end()
{
	flag_wait_either("meetup_finished", "player_reached_goatpath");

	carlos = get_hero_by_name("carlos");
	woods = get_hero_by_name("woods");
	bowman = get_hero_by_name("bowman");

	woods.nododgemove = false;
	carlos.nododgemove = false;
	
	Objective_State(level.OBJ_STREET, "done");

	array_func(array(carlos, woods, bowman), ::disable_cqbwalk);
	array_func(array(woods, bowman), ::enable_ai_color);

	carlos thread carlos_leaves();

	if (!flag("meetup_finished"))  // temp until animation works
	{
		// Teleport squad so player doesn't have to wait
		if (flag("carlos!spawned"))
		{
			get_hero_by_name("carlos") Delete();
		}

		array_func(array(woods, bowman), ::anim_stopanimscripted);
		start_teleport_ai("start_goatpath", "squad");
	}

	flag_set("meetup_finished");

	//autosave_by_name("cuba_goatpath");
}

carlos_leaves()
{
	self endon("death");
 	node = GetNode("carlos_leave_node", "targetname");
 	self.script_forcegoal = 1;
	self.script_radius = 10;
	self.disablearrivals = 1;
	self.disableturns = 1;
	self maps\_spawner::go_to_node(node);
 	self Delete();
}

vo()
{
	thread air_raid_sound();//kevin adding a wait so that air raid can play for a bit before he mentions it
	wait 5;
	
	get_hero_by_name("bowman") play_vo("air_raid");			//There's the air raid siren.
	get_hero_by_name("woods") play_vo("right_on_schedule");	//Right on schedule.
	get_hero_by_name("woods") play_vo("cuban_pilots");		//Let's hope those Cuban pilots are up to job... Or this is gonna be one short revolution.

	player = get_players()[0];
	player play_vo("distraction");	//Either way, it's all part of the distraction...
}

air_raid_sound()
{
	ent = spawn( "script_origin" , (-10216, -7728, 480));
	ent playloopsound( "amb_air_raid" );
}

spawn_bombers()
{
	level endon("stop_goatpath_bombers");

	x = 0;
	while (true)
	{
		i = 0;
		targetname = "incoming_bomber" + i;

		while (IsDefined(level.vehicle_targetname_array[targetname]))
		{
			spawn_vehicle_from_targetname_and_drive(targetname);

			i++;
			targetname = "incoming_bomber" + i;

			wait RandomFloatRange(0, 5);
		}

		x++;

		wait RandomFloatRange(7, 10);
	}
}

kill_bombers()
{
	level notify("stop_goatpath_bombers");

	i = 0;
	while (i < level.incoming_bombers_size)
	{
		incoming_bombers = GetEntArray("incoming_bomber" + i, "targetname");
		if (incoming_bombers.size)
		{
			array_func(incoming_bombers, ::self_delete);
		}

		i++;
	}
}

spawn_beach_vehicles()
{
	level endon("stop_beach_vehicles");

	x = 0;
	while (true)
	{
		i = 0;
		targetname = "beach_vehicles" + i;

		while (IsDefined(level.vehicle_targetname_array[targetname]))
		{
			spawn_vehicle_from_targetname_and_drive(targetname);

			i++;
			targetname = "beach_vehicles" + i;

			wait RandomFloatRange(0, 5);
		}

		x++;

		wait RandomFloatRange(7, 10);
	}
}

kill_beach_vehicles()
{
	level notify("stop_beach_vehicles");

	i = 0;
	while (i < level.beach_vehicles_size)
	{
		beach_vehicles = GetEntArray("beach_vehicles" + i, "targetname");
		if (beach_vehicles.size)
		{
			array_func(beach_vehicles, ::self_delete);
		}

		i++;
	}
}
/*
stop_first_drones()
{
	wait 15;
	level notify("stop_first_axis_drones");
}
*/
cleanup()
{
	level notify("goatpath_complete");

	kill_beach_vehicles();

	beach_vehicles = GetEntArray("beach_vehicles", "script_noteworthy");
	array_func(beach_vehicles, ::self_delete);
/*
	drone_triggers = GetEntArray("drone_axis", "targetname");
	array_notify(drone_triggers, "stop_drone_loop");

	drones = GetEntArray("drone", "targetname");
	array_func(drones, ::self_delete);
*/
	maps\cuba_fx::wind_initial_setting();
}
