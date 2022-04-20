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
#include maps\_flyover_audio;
#include maps\_anim;
#include maps\_music;

// The level-skip shortcuts go here, the main level flow goes straight to run()

run_skipto()
{
//	init_flags();

	// setup the objectives
	level thread objectives(0);
	
	// misc setup necessary to make the skipto work goes here
	run();
}

run()
{
	//initialize the event
	init_event();

	// pullup!
	weaver_pullup();

	// wait till we're done
//	flag_wait("end_sequence_complete");
	play_end_sequence();

	// Do Clean up
	cleanup();

	// And...done!
	nextmission();
}

init_event()
{
	level notify("stop_spawner_cleanup");

	// set variables
	level.player = get_players()[0];

	// clean up all spawners...we need ents for the crash debris
	spawners = GetSpawnerArray();
	array_removeUndefined(spawners);
	array_delete(spawners);

	// take weapons
	level.player FreezeControls(false);
	level.player take_weapons();

	// hide player hud elements
	level.player SetClientDvar( "compass", "0" );
	level.player SetClientDvar( "hud_showstance", "0" );
	level.player SetClientDvar( "actionSlotsHide", "1" );
	level.player SetClientDvar( "ammoCounterHide", "1" );

	//maps\createart\underwaterbase_art::set_dive_fog_and_vision();

	// Set the underwater vision set
	level.player clientnotify( "uwb_vs" );

	// spawn a player body
	level.player.player_body = spawn_anim_model("player_body", level.player.origin, level.player.angles);

	// spawn a hudons script model
	hudson_start = GetEnt("hudson_start_swim_2", "targetname");

	level.hudson = spawn_character("hudson", hudson_start.origin, hudson_start.angles, "hudson");

	// setup table of vignettes
	level.vignette_funcs = [];
	level.vignette_funcs["diver"] = ::diver_vignette;
	level.vignette_funcs["pointer"] = ::pointer_vignette;
	level.vignette_funcs["activity"] = ::activity_vignette;
	level.vignette_funcs["megaphone"] = ::megaphone_vignette;
	level.vignette_funcs["rope"] = ::rope_vignette;

	player_to_struct("player_start_swim");

	// turn off drowning
	level.disable_drowning = false;
	level.player clientnotify("_enable_drowning");
	level.player enable_swimming();
  	level.default_pitch_up = GetDvarInt("player_view_pitch_up");
  	level.player setclientdvar("player_view_pitch_up", "85");
  	level.default_pitch_down = GetDvarInt("player_view_pitch_down");
  	level.player setclientdvar("player_view_pitch_down", "0");
	level.player SetPlayerViewRateScale( 65 );

  	// set water fog in clientscripts
	ClientNotify("rise_to_surface");

	VisionSetNaked("uwb_dive", 0);

	// god rays exploder
	Exploder(951);

	// skybox trans
	SetSavedDvar( "r_skyTransition", 1.0 );
	SetSavedDvar( "sm_sunSampleSizeNear", 1.03 );

	// starting origins of sky metals
	level.metal_origins = [];

	// chinook b
	level.metal_origins["chinook_a"] = [];
	level.metal_origins["chinook_a"][0] = (15225.6, -45902.3, -1010.16);
	level.metal_origins["chinook_a"][1] = (12705.3, -44800.9, -1704.31);
	level.metal_origins["chinook_a"][2] = (15326.2, -45858.3, -1513.82);
	level.metal_origins["chinook_a"][3] = (11395.1, -46180.9, -766.202);
	level.metal_origins["chinook_a"][4] = (13382.5, -46960.8, -1651.46);
	level.metal_origins["chinook_a"][5] = (12187.2, -44749.7, -1549.22);
	level.metal_origins["chinook_a"][6] = (13573, -47209.5, -2057.71);
	level.metal_origins["chinook_a"][7] = (13338.2, -44108.1, -1817.29);

	// chinook b
	//level.metal_origins["chinook_b"] = [];
	//level.metal_origins["chinook_b"][0] = (11534.8, -35044, -480.781);
	//level.metal_origins["chinook_b"][1] = (10553.8, -36664, -757.209);
	//level.metal_origins["chinook_b"][2] = (14049.5, -34821.2, -208.625);
	//level.metal_origins["chinook_b"][3] = (12988.7, -34095.6, -721.748);
	//level.metal_origins["chinook_b"][4] = (16616.3, -35317.8, -108.161);
	//level.metal_origins["chinook_b"][5] = (11778.7, -35431.7, -39.3135);
	//level.metal_origins["chinook_b"][6] = (14226.5, -37360.6, -316.047);
	//level.metal_origins["chinook_b"][7] = (10015.8, -34190.7, -190.864);

	// chinook b
	level.metal_origins["huey_a"] = [];
	level.metal_origins["huey_a"][0] = (12133.3, -34906.1, -133.441);
	level.metal_origins["huey_a"][1] = (14295.9, -34807.5, 76.8857);
	level.metal_origins["huey_a"][2] = (12631.1, -36912.4, 410.504);
	level.metal_origins["huey_a"][3] = (11491.3, -34506.7, -729.389);
	level.metal_origins["huey_a"][4] = (14688.7, -34874.1, -609.394);
	level.metal_origins["huey_a"][5] = (12246.7, -34107, -612.995);
	level.metal_origins["huey_a"][6] = (13150.5, -38039.2, 80.6089);
	level.metal_origins["huey_a"][7] = (15858.7, -35452.9, 991.314);
	level.metal_origins["huey_a"][8] = (12933.7, -37581.9, 912.701);
	level.metal_origins["huey_a"][9] = (12712.6, -35637.9, 973.309);

	// finally fade the player view in
	level thread fade_in( 3.5, "white" );

	flag_set("swim_init_done");

	// start the rise
	level thread rise_to_surface();

	//wait(0.2);

	// spin thread
	level thread rusalka_sinking_event();
	level thread floating_debris_spawner(level.player.origin + (0, 0, 3000), (-1500, -1500, 0), (1500, 1500, 5000));
	level thread floating_debris();
	level thread moving_ships();
	level thread dialogue();
	level thread rise_to_surface_hueys();
	level thread surface_vignettes();
	level thread sky_metal_insanity();
	level thread finale_helis();
	level thread finale_uber_awesome_phantoms();
	level thread phys_pulse();

	// wavy water
	setup_ending_water();
}

// gets run through at start of level
init_flags()
{
	flag_init("player_surfaced");			  	// set when player reaches water surface
	flag_init("player_surface_swim");			// set when player is now free to swim on surface
	flag_init("hudson_surfaced");			  	// set when Hudson reaches water surface
	flag_init("hudson_swim_to_weaver");		// set when Hudson should sweim to Weaver rescue boat
	flag_init("player_reached_weaver");		// set when player reaches weavers boat
	
	flag_init("rescue_boats_start" );			// set when rescue boats should move into place
	flag_init("rise_phantoms_start");			// set when f4 phantoms should start moving above player during rise
	//flag_init("flyover_phantoms_start");
	flag_init("flyby_phantoms_01_start");		// set when background f4 phantoms should start moving
	flag_init("flyby_phantoms_02_start");		// set when background f4 phantoms should start moving
	flag_init("flyby_choppers_01_start");		// set when background choppers should start moving
	flag_init("flyby_choppers_02_start");		// set when background choppers should start moving
	flag_init("flyby_choppers_03_start");		// set when background choppers should start moving
	flag_init("flyby_choppers_04_start");		// set when background choppers should start moving
	
	flag_init("end_sequence_complete");		// set when the end sequence for the level and game are done

	flag_init("swim_init_done");
}

objectives( starting_obj_num )
{
	level.curr_obj_num = starting_obj_num;
	
	flag_wait ( "player_surfaced" );
	
	Objective_Add( level.curr_obj_num, "active", "Swim to Weaver" );
	Objective_Position( level.curr_obj_num, ent_origin("swim_to_weaver_objective") );
	Objective_Set3D( level.curr_obj_num, true );
	flag_wait("player_reached_weaver");
	Objective_State( level.curr_obj_num, "done" );
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rise_to_surface()
{
//	flag_wait("swim_init_done");

	wait(0.1);

	clientnotify( "almof" );
	
	// get swim structs
	player_start = GetEnt("player_start_swim_2", "targetname");
	hudson_start = GetEnt("hudson_start_swim_2", "targetname");

	player_start_2 = GetEnt("player_start_swim", "targetname");
	hudson_start_2 = GetEnt("hudson_start_swim", "targetname");

	// Link Player to body
	//level.player.player_body.origin = player_start.origin;
	//level.player.player_body.angles = player_start.angles;
	//level.player PlayerLinkToDelta(level.player.player_body, "tag_player", 0, 45, 45, 45, 45);

	level.player SetPlayerAngles(player_start.angles);
	level.player PlayerLinkTo(player_start);

	//level thread test_fucking_fog();

	// teleport hudson
	level.hudson.origin = hudson_start.origin;
	level.hudson.angles = hudson_start.angles;

	PlayFXOnTag(level._effect["bubbles"], level.hudson, "j_spine4");

	// start the animations
	level.player.player_body SetAnim(level.scr_anim["player_body"]["ascend"][0], 1, 0.1, 1);
	level.hudson SetAnim(level.scr_anim["hudson"]["ascend"][0], 1, 0.1, 1);

	//player_start thread move_and_rotate_to(player_start_2.origin, player_start_2.angles, 10);
	//level.hudson thread move_and_rotate_to(hudson_start_2.origin, hudson_start_2.angles, 10);

	guys = array(player_start, level.hudson);
	//array_wait(guys, "movedone");

	level notify("water_stuff_go");

	// get hero boat
	align_node = GetStruct("sync_weaver_pullup", "targetname");

	player_anim = level.player.player_body get_anim("finale");
	player_start_org = GetStartOrigin(align_node.origin, align_node.angles, player_anim);
	player_start_angles = GetStartAngles(align_node.origin, align_node.angles, player_anim);

	hudson_anim = level.hudson get_anim("finale");
	hudson_start_org = GetStartOrigin(align_node.origin, align_node.angles, hudson_anim);
	hudson_start_angles = GetStartAngles(align_node.origin, align_node.angles, hudson_anim);

	player_start thread move_and_rotate_to(player_start_org, player_start_angles, 30);
	level.hudson thread move_and_rotate_to(hudson_start_org, hudson_start_angles, 29.75);

	//guys = array(player_start, level.hudson);
	array_wait(guys, "movedone");

	level notify("player_surfaced");
}

weaver_pullup()
{
	level waittill("player_surfaced");

	level.player UnLink();
	level.player PlayerLinkToAbsolute(level.player.player_body, "tag_player");
//	level.player PlayerLinkToDelta(level.player.player_body, "tag_player", 1, 45, 45, 45, 45);

	// spawn the additional actors
	level.weaver = spawn_character("weaver", (0,0,0), (0,0,0), "weaver");
	level.redshirt1 = spawn_character("redshirt", (0,0,0), (0,0,0), "hero_redshirt1");
	level.redshirt2 = spawn_character("redshirt", (0,0,0), (0,0,0), "hero_redshirt2");

	// give them guns
	level.weaver.my_weapon = GetWeaponModel( "famas_reflex_sp" );
	level.weaver Attach(level.weaver.my_weapon, "tag_weapon_right");
	level.weaver UseWeaponHideTags("famas_reflex_sp");

	level.redshirt1.my_weapon = GetWeaponModel( "famas_reflex_sp" );
	level.redshirt1 Attach(level.redshirt1.my_weapon, "tag_weapon_right");
	level.redshirt1 UseWeaponHideTags("famas_reflex_sp");

	level.redshirt2.my_weapon = GetWeaponModel( "famas_reflex_sp" );
	level.redshirt2 Attach(level.redshirt2.my_weapon, "tag_weapon_right");
	level.redshirt2 UseWeaponHideTags("famas_reflex_sp");

	// vision set change thread
	level thread player_surfaced_visuals();

	// get the align node
	align_node = GetStruct("sync_weaver_pullup", "targetname");
	align_ent = spawn("script_origin", align_node.origin);
	align_ent.angles = align_node.angles;

	// Link the heroes to the boat
	weaver_boat = GetEnt("weaver_boat", "targetname");

	// get the offset
	align_offset = align_ent.origin - weaver_boat.origin;

	// link
	align_ent LinkTo(weaver_boat.link_model, "tag_origin", align_offset);

	// bob
	weaver_boat.link_model thread boat_bob(10, 75, (-1, 0, 1));
	level thread roll_sea_entity();

	// make the actor array
	actors = array(level.weaver, level.redshirt1, level.redshirt2, level.player.player_body, level.hudson);

	// play animation
	align_ent anim_single_aligned(actors, "finale");

//	level.player UnLink();
//	level.player PlayerLinkToDelta(level.player.player_body, "tag_player", 0, 65, 65, 65, 65);
}

link_hero_boat()
{
	// Link the heroes to the boat
	weaver_boat = GetEnt("weaver_boat", "targetname");

	// playerbody first
	player_delta = level.player.player_body.origin - weaver_boat.link_model.origin;
	level.player.player_body LinkTo(weaver_boat.link_model, "tag_origin", player_delta);

	// hudson
	hudson_delta = level.hudson.origin - weaver_boat.origin;
	level.hudson LinkTo(weaver_boat.link_model, "tag_origin", hudson_delta);

	// weaver
	weaver_delta = level.weaver.origin - weaver_boat.origin;
	level.weaver LinkTo(weaver_boat.link_model, "tag_origin", weaver_delta);

	// redshirt 1
	redshirt1_delta =level. redshirt1.origin - weaver_boat.origin;
	level.redshirt1 LinkTo(weaver_boat.link_model, "tag_origin", redshirt1_delta);

	// redshirt 2
	redshirt2_delta = level.redshirt2.origin - weaver_boat.origin;
	level.redshirt2 LinkTo(weaver_boat.link_model, "tag_origin", redshirt2_delta);

	// move the hero boat
	weaver_boat.link_model thread boat_bob(10, 75, (-1, 0, 1));
}

player_surfaced_visuals()
{
	maps\createart\underwaterbase_art::set_risetosurface_base_fog();
	//ClientNotify("start_superflare");
}

play_end_sequence()
{
//	wait(6);
//	level.movie_fade_in_time = 4;
//	level thread play_movie("int_number_flash_1", false, true, undefined, true, "movie_done");
//
//	level waittill("movie_done");

	//fade_out( 3, "black" );
	//missionsuccess( "underwaterbase" );
	//nextmission();

	level.fullscreen_cin_hud = NewHudElem();
    level.fullscreen_cin_hud.x = 0;
    level.fullscreen_cin_hud.y = 0;
    level.fullscreen_cin_hud.horzAlign = "fullscreen";
    level.fullscreen_cin_hud.vertAlign = "fullscreen";
    level.fullscreen_cin_hud.foreground = false; 
    level.fullscreen_cin_hud.sort = 0;

    level.fullscreen_cin_hud setShader( "cinematic", 640, 480 );
    level.fullscreen_cin_hud.alpha = 0;
	level thread play_movie("int_number_flash_1", true, true);	

	level.fullscreen_cin_hud FadeOverTime(6);
    level.fullscreen_cin_hud.alpha = 1;

	wait(8);

	fade_out_overlay = NewHudElem();
	fade_out_overlay.x = 0;
	fade_out_overlay.y = 0;
	fade_out_overlay.horzAlign = "fullscreen";
	fade_out_overlay.vertAlign = "fullscreen";
	fade_out_overlay.foreground = false;  // arcademode compatible
	fade_out_overlay.sort = 50;  // arcademode compatible
	fade_out_overlay.alpha = 1;

	fade_out_overlay SetShader( "black", 640, 480 );

	wait(0.5);

	stop_movie();
}

rusalka_sinking_event()
{
	level.rusalka = GetEnt("sinking_rusalka_ship", "targetname");
	level.rusalka SetForceNoCull();
	
	level.rusalka playsound( "evt_underwater_sink" );

	rusalka_start = GetStruct("sinking_rusalka_start", "targetname");
	rusalka_end = GetStruct("sinking_rusalka_end", "targetname");

	move_ent = spawn("script_origin", rusalka_start.origin);
	move_ent.angles = level.rusalka.angles;
	move_ent SetModel("tag_origin");
	
	level.rusalka LinkTo(move_ent, "tag_origin");
	level thread rusalka_bubbles();

	move_ent MoveTo(rusalka_end.origin, 50);
	move_ent RotateTo((75, 214.29, -125), 15, 10, 5);
}

move_and_rotate_to(end_point, end_angles, time)
{
	self MoveTo(end_point, time);
	self RotateTo(end_angles, time);
}

cleanup()
{
	ub_print( "cleanup thesurface\n" );
}

vignette_group(node_name)
{
	nodes = GetStructArray(node_name, "targetname");
	for(i = 0; i < nodes.size; i++)
	{
		level thread vignette(nodes[i]);
	}
}

surface_vignettes()
{
	level waittill("player_surfaced");

	//TUEY set music state to UP TOP
	setmusicstate ("UP_TOP");

	level thread maps\_audio::switch_music_wait("SURFACE", 9.5);

	wait(5.0);

	vignette_group("finale_vignette_group_a");

	level notify("boat_group_a");

	wait(4.0);

	vignette_group("finale_vignette_group_b");

	level notify("boat_group_b");
}

vignette(node)
{
	// get the align node...either from string or was passed to us
	align_node = undefined;
	if (IsString(node))
	{
		align_node = GetStruct(node, "targetname");
	}
	else
	{
		align_node = node;
	}

	// get info from the struct
	type = "";
	if (IsDefined(align_node.script_string))
	{
		type = align_node.script_string;
	}	

	variation = -1;
	if (IsDefined(align_node.script_int))
	{
		variation = align_node.script_int;
	}

	character_type = "redshirt";
	if (type == "diver")
	{
		character_type = "redshirt_diver";
	}

	// spawn an actor
	actor = spawn_character(character_type, align_node.origin, align_node.angles);

	// spawn a script model at the node
	actor.node = spawn("script_model", align_node.origin);
	actor.node.angles = align_node.angles;
	actor.node SetModel("tag_origin");

	// link to the node
	actor LinkTo(actor.node, "tag_origin");

	// link to boat
	parent_boat = GetEnt(align_node.target, "targetname");
	actor.node linkto_parent_boat(parent_boat);

	// check for a delay
	if (IsDefined(align_node.script_float))
	{
		wait(align_node.script_float);
	}

	// call the appropriate function pointer for this "type"
	actor thread [[level.vignette_funcs[type]]](actor.node, variation);
}

linkto_parent_boat(parent_boat)
{
	if (IsDefined(parent_boat.link_model))
	{
		offset = self.origin - parent_boat.link_model.origin;
		angle_offset = self.angles - parent_boat.angles;
		self LinkTo(parent_boat.link_model, "tag_origin");
	}
}

diver_vignette(node, variation)
{
	// unlink myself
	self UnLink();

	// set animname
	self.animname = "diver";

	// create the scene name
	scene = "dive_entrance" + variation;

	// wait for the splash
	self thread diver_splash();

	// play the anim
	self anim_single(self, scene);

	// delete me when done
	self delete();

	// delete the node
	node delete();
}

diver_splash()
{
	self endon("death");

	wait(1.0);

	while (1)
	{
		self.splash_origin = undefined;
		if (self is_in_water(20))
		{
			PlayFX(level._effect["diver_splash"], self.splash_origin + (0,0,8), (0,0,1), (1,0,0));
			return;
		}

		wait(0.05);
	}
}

// Check to see if we're on ground within some tolerance...pass back if we're under the ground
// and the ground pos
is_in_water(tolerance)
{
	trace_start = self.origin + (0, 0, 64);
	trace_end = trace_start + (0, 0, -256);
	trace = BulletTrace(trace_start, trace_end, 0, undefined);
	self.splash_origin = trace["position"];

	dist = DistanceSquared(self.origin, self.splash_origin);
	if (dist > 0.1)
	{
		// get the delta
		delta = self.origin - self.splash_origin;
		up = (0, 0, 1);

		// check to see if we're underground
		dot = VectorDot(delta, up);
		if (dot < 0)
		{
			self.origin = self.splash_origin;
			return true;
		}
	}

	// check vs. tolerance
	check = tolerance * tolerance;
	if (dist < check)
	{
		return true;
	}

	return false;
}

pointer_vignette(node, variation)
{
	self endon("death");

	self.my_weapon = GetWeaponModel( "famas_reflex_sp" );
	self Attach(self.my_weapon, "tag_weapon_right");
	self UseWeaponHideTags("famas_reflex_sp");

	// set animname
	self.animname = "boat_guy" + variation;

	// point loop
	node thread anim_loop(self, "point_loop");
	//self SetAnim(level.scr_anim[self.animname]["point_loop"][0], 1, 0.1, 1);
}

activity_vignette(node, variation)
{
	self endon("death");

	// set animname
	self.animname = "boat_guy" + variation;

	// different loop counts for the different variations
	num_loops = 0;
	if (variation == 1)
	{
		num_loops = 4;
	}
	else if (variation == 2)
	{
		num_loops = 3;
	}

	while (1)
	{
		// generate which loop to play
		loop_num = RandomIntRange(1, num_loops + 1);
		loop_name = "boat_activity" + loop_num;

		// play the loop
		node thread anim_loop(self, loop_name);

//		self SetAnim(level.scr_anim[self.animname][loop_name][0], 1, 0.1, 1);

		// wait
		wait(3);

//		self ClearAnim(level.scr_anim[self.animname][loop_name][0], 1.0);
	}
}

megaphone_vignette(node, variation)
{
	self endon("death");

	while (1)
	{
		loop_num = RandomIntRange(1, 4);
		loop_name = "megaphone" + loop_num;

		node thread anim_generic_loop(self, loop_name);
		//self SetAnim(level.scr_anim["generic"][loop_name][0], 1, 0.1, 1);

		wait(2);

		//self ClearAnim(level.scr_anim["generic"][loop_name][0], 1.0);
	}
}

rope_vignette(node, variation)
{
	self endon("death");
	node thread anim_generic_loop(self, "gather_rope");
	//self SetAnim(level.scr_anim["generic"]["gather_rope"][0], 1, 0.1, 1);
}

floating_debris_spawner(center, mins, maxs)
{
	wait(1);

	center_origin = undefined;
	if (IsString(center))
	{
		center_struct = GetStruct(center, "targetname");
	}
	else
	{
		center_origin = center;
	}

	for (i = 0; i < level.floating_debris.size; i++)
	{
		for (j = 0; j < level.floating_debris[i].count; j++)
		{
			random_offset_x = RandomFloatRange(mins[0], maxs[0]);
			random_offset_y = RandomFloatRange(mins[1], maxs[1]);
			random_offset_z = RandomFloatRange(mins[2], maxs[2]);

			random_pitch = RandomFloatRange(0, 360);
			random_yaw = RandomFloatRange(0, 360);
			random_roll = RandomFloatRange(0, 360);

			model = spawn("script_model", center_origin + (random_offset_x, random_offset_y, random_offset_z));
			model.angles = (random_pitch, random_yaw, random_roll);
			model SetModel(level.floating_debris[i].name);

			model.velocity = RandomFloatRange(level.floating_debris[i].min_vel, level.floating_debris[i].max_vel);

			tag_origin = model GetTagOrigin("tag_origin");
			if (IsDefined(tag_origin))
			{
				if (model.velocity < 15)
				{
					PlayFXOnTag(level._effect["fx_bubble_vent_small"], model, "tag_origin");
				}
				else
				{
					PlayFXOnTag(level._effect["fx_bubble_vent_large"], model, "tag_origin");
				}
			}
			else
			{
				model.fx_model = spawn("script_model", model.origin);
				model.fx_model SetModel("tag_origin");
				model.fx_model LinkTo(model);

				if (model.velocity < 15)
				{
					PlayFXOnTag(level._effect["fx_bubble_vent_small"], model.fx_model, "tag_origin");
				}
				else
				{
					PlayFXOnTag(level._effect["fx_bubble_vent_large"], model.fx_model, "tag_origin");
				}
			}

			model thread debris_move();
			model thread debris_delete();

		}
	}
}

floating_debris()
{
	debris = GetEntArray("floating_debris", "script_noteworthy");
	for (i = 0; i < debris.size; i++)
	{
		if (IsDefined(debris[i].script_float))
		{
			debris[i].velocity = (0,0,1) * (debris[i].script_float * 12);
			debris[i] thread debris_move();
			debris[i] thread debris_delete();

			if (IsDefined(debris[i].script_string) && debris[i].script_string == "huey")
			{
				PlayFXOnTag(level._effect["fx_bubble_vent_large"], debris[i], "tag_origin");
			}
		}
	}
}

debris_move()
{
	level waittill("water_stuff_go");

	new_pos = self.origin - self.velocity * 30;

	if (IsDefined(self.script_string) && self.script_string == "huey")
	{
		self.angles = (25, 45, -10);
		rot_vel = (5, 25, 0);
		self playloopsound ("evt_underwater_debris");
	}
	else
	{
		rot_vel = (RandomFloatRange(-10, 10), RandomFloatRange(-10, 10), 0);
	}
	
	self MoveTo(new_pos, 30);
	self RotateVelocity(rot_vel, 30);
}

debris_delete()
{
	wait(25);

	if (IsDefined(self.fx_model))
	{
		self.fx_model delete();
	}

	self delete();
}

rusalka_bubbles()
{
	level endon("player_surfaced");

	level.fake_rusalka = spawn("script_model", level.rusalka.origin);
	level.fake_rusalka SetModel("tag_origin");
	level.fake_rusalka LinkTo(level.rusalka);

	bubbles_ents = GetStructArray("rusalka_bubbles", "targetname");
	models = [];

	for (i = 0; i < bubbles_ents.size; i++)
	{
		// get offset
		offset = bubbles_ents[i].origin - level.fake_rusalka.origin;
	
		models[i] = spawn("script_model", bubbles_ents[i].origin);
		models[i] SetModel("tag_origin");

		// link me to the rusalka
		models[i] LinkTo(level.fake_rusalka, "tag_origin", offset);

		if (IsDefined(bubbles_ents[i].script_string))
		{
			models[i].script_string = bubbles_ents[i].script_string;
		}

		PlayFXOnTag(level._effect["fx_bubble_vent_xlarge"], models[i], "tag_origin");
	}

	level thread rusalka_explosions(models);

	level waittill("player_surfaced");

	array_delete(models);
	level.fake_rusalka delete();

//	array_delete(bubbles_ents);
}

rusalka_explosions(bubbles_ents)
{
	level endon("player_surfaced");
	player = get_players()[0];

	for (i = 0; i < bubbles_ents.size; i++)
	{
		if (Isdefined(bubbles_ents[i].script_string) && bubbles_ents[i].script_string == "explode")
		{
			PlayFXOnTag(level._effect["fx_uwb_water_explosion"], bubbles_ents[i], "tag_origin");
			playsoundatposition( "evt_underwater_exp" , bubbles_ents[i].origin );
			wait(RandomFloatRange(1.0, 1.5));			
		}
	}

	while (1)
	{
		for (i = 0; i < bubbles_ents.size; i++)
		{
			if (Isdefined(bubbles_ents[i].script_string) && bubbles_ents[i].script_string == "explode")
			{
				PlayFXOnTag(level._effect["fx_uwb_water_explosion"], bubbles_ents[i], "tag_origin");
				playsoundatposition( "evt_underwater_exp" , bubbles_ents[i].origin );
				wait(RandomFloatRange(2.0, 3.0));			
			}
		}
	}
}

moving_ships()
{
	boats = GetEntArray("moving_boat", "script_noteworthy");
	for (i = 0; i < boats.size; i++)
	{
		boats[i].link_model = spawn("script_model", boats[i].origin);
		boats[i].link_model.angles = boats[i].angles;
		boats[i].link_model SetModel("tag_origin");

		time = RandomFloatRange(20, 25);
		if (IsDefined(self.targetname) && self.targetname == "weaver_boat")
		{
			time = 20;
		}

		boats[i] thread boat_move(time);
	}

	level waittill("boat_group_a");

	for (i = 0; i < boats.size; i++)
	{
		if (IsDefined(boats[i].script_string) && boats[i].script_string == "boat_group_a")
		{
			a = RandomFloatRange(8, 10);
			w = RandomFloatRange(75, 100);

			x = RandomFloatRange(-2, 2);
			z = RandomFloatRange(-2, 2);

			x = Min(x, -1);
			x = Max(x, 1);

			z = Min(z, -1);
			z = Max(z, 1);

			boats[i].link_model thread boat_bob(a, w, (x, 0, z));
		}
	}

	level waittill("boat_group_b");

	for (i = 0; i < boats.size; i++)
	{
		if (IsDefined(boats[i].script_string) && boats[i].script_string == "boat_group_b")
		{
			a = RandomFloatRange(8, 10);
			w = RandomFloatRange(75, 100);

			x = RandomFloatRange(-2, 2);
			z = RandomFloatRange(-2, 2);

			x = Min(x, -1);
			x = Max(x, 1);

			z = Min(z, -1);
			z = Max(z, 1);

			boats[i].link_model thread boat_bob(a, w, (x, 0, z));
		}
	}
}

boat_move(time)
{
	if (IsDefined(self.target))
	{
		// get start position
		start_struct = GetStruct(self.target, "targetname");

		// find end position
		end_struct = GetStruct(start_struct.target, "targetname");

		// move me to the start point
		self.origin = start_struct.origin;

		// move to the end point
		self MoveTo(end_struct.origin, time);

		// waittill move is done
		self waittill("movedone");
	}

	// link myself to my link model
	self.link_model.origin = self.origin;
	self.link_model.angles = self.angles;
	self LinkTo(self.link_model, "tag_origin");
}

boat_bob(amplitude, frequency, angular_amplitude)
{
	self endon("death");

//	a = 150.0;
//	w = 25.0;
	t = 0.0;

	if (!IsDefined(angular_amplitude))
	{
		angular_amplitude = (0,0,0);
	}

	start_z = self.origin;
	start_angles = self.angles;

	// typical sine wave y(t) = a * sin((w * t) + theta)
	while (true)
	{
		normalized_wave_height = Sin(frequency * t);

		wave_height_z = amplitude * normalized_wave_height;

		self.origin = start_z + (0, 0, wave_height_z);
		self.angles = start_angles + (angular_amplitude * normalized_wave_height);

		t += 0.05;
		wait(0.05);
	}
}

dialogue()
{
	wait(10);

	player = get_players()[0];

	level.hudson anim_single(level.hudson, "mason", "reznov");

	//wait(1.0);

	//player.animname = "mason";
	//player anim_single(player, "reznov");

	wait(1.0);
	
	level.hudson anim_single(level.hudson, "you_did_it", "reznov");
}

rise_to_surface_hueys()
{
	level waittill("player_surfaced");

	trigger_use("trig_rise_hueys");

	wait(0.05);

	huey_a = GetEnt("rise_to_surface_huey_a", "targetname");
	huey_b = GetEnt("rise_to_surface_huey_b", "targetname");

	huey_a thread rise_huey_think("rise_huey_a_start_pos", 6);
	huey_b thread rise_huey_think("rise_huey_b_start_pos", 5);
}

rise_huey_think(start_pos, move_delay)
{
	start_struct = GetStruct(start_pos, "targetname");

	forward = AnglesToForward(start_struct.angles);
	look_ent = spawn("script_origin", start_struct.origin + forward * 1500);

	self SetSpeed(60, 30, 30);
	self SetJitterParams((50, 50, 50), 3, 4);
	self SetHoverParams(50, 10, 5);
	self SetVehGoalPos(start_struct.origin, 1);
	self SetLookAtEnt(look_ent);

	wait(move_delay);

	go_pos = GetStruct(self.targetname + "_go_pos", "targetname");
	look_ent.origin = go_pos.origin;

	self SetSpeed(45, 22, 22);
	self SetVehGoalPos(go_pos.origin, 1);
	self SetLookAtEnt(look_ent);

	self waittill("goal");

	look_ent delete();
	self delete();
}

sky_metal_insanity()
{
	level waittill("player_surfaced");

	chinook_parts = [];
	chinook_parts["main"] = "vehicle_ch46e";
	chinook_parts["rotor_main"] = level._effect["chinook_main"];
	chinook_parts["rotor_tail"] = level._effect["chinook_tail"];

	huey_parts = [];
	huey_parts["main"] = "t5_veh_helo_huey";
	huey_parts["interior"] = "t5_veh_helo_huey_att_interior";
	huey_parts["rotor_main"] = level._effect["huey_rotor_main"];
	huey_parts["rotor_tail"] = level._effect["huey_rotor_tail"];


	level thread sky_metal("chinook_sky_metal_a", chinook_parts, 8, (-2000, -2000, 0), (2000, 2000, 2000), 350, 400, 1500, "chinook_a", "chinook_a");
	level thread metal_deleter("chinook_a", 25);

	wait(1);

	level thread sky_metal("huey_sky_metal_a", huey_parts, 10, (-2000, -2000, 0), (2000, 2000, 2000), 350, 400, 1500, "huey_a", "huey_a");
	level thread metal_deleter("huey_a", 25);

	wait(2);

	level thread sky_metal("chinook_sky_metal_b", chinook_parts, 8, (-4000, -2000, 0), (4000, 2000, 2000), 350, 400, 1500, "chinook_b", "chinook_b");
	level thread metal_deleter("chinook_b", 65);
}

metal_deleter(group, delay)
{
	wait(delay);
	level notify(group);
	array_delete(level.metal[group]);
}

finale_helis()
{
	level waittill("player_surfaced");

	wait(9);

	trigger_use("trig_finalle_helis");

	wait(0.05);

	helis = GetEntArray("boat_flyby_helis", "targetname");
	array_thread(helis, ::finale_heli_spawn_func);
}

finale_heli_spawn_func()
{
	goal = GetStruct(self.script_noteworthy + "_go", "targetname");
	look_ent = spawn("script_origin", goal.origin);

	speed = goal.script_float;

	self.drivepath = 1;
	self SetSpeed(speed, speed / 2, speed / 2);
	self SetVehGoalPos(goal.origin, 1);
	self SetLookAtEnt(look_ent);

	self waittill("goal");

	look_ent delete();
	self delete();
}

finale_uber_awesome_phantoms()
{
	level waittill("player_surfaced");

	align_node = GetStruct("sync_weaver_pullup", "targetname");
	align_node.angles = (0,0,0);

	phantoms_a = [];
	for (i = 0; i < 3; i++)
	{
		phantoms_a[i] = spawn_anim_model("phantom", align_node.origin, (0,0,0));
		phantoms_a[i].animname = "phantom_" + (i + 1);
		phantoms_a[i] thread plane_position_updater (3200, "evt_f4_short_wash", "null"); 
		phantoms_a[i] SetForceNoCull();
		phantoms_a[i] Hide();
	}

	phantoms_b = [];
	for (i = 0; i < 3; i++)
	{
		phantoms_b[i] = spawn_anim_model("phantom", align_node.origin, (0,0,0));
		phantoms_b[i].animname = "phantom_" + (i + 4);
		phantoms_b[i] thread plane_position_updater (3200, "evt_f4_long_wash", "null"); 
		phantoms_b[i] SetForceNoCull();
		phantoms_b[i] Hide();
	}

	wait(14);

//	IPrintLnBold("FUCK SUACE!!!");

	// you're good to go maverick
	for (i = 0; i < 3; i++)
	{
		phantoms_a[i] Show();
		phantoms_a[i] thread f4_add_contrails();
		align_node thread anim_single(phantoms_a[i], "flyby");
		phantoms_a[i] thread f4_delete_on_end();
	}

	wait(1);

	// roger that iceman
	for (i = 0; i < 3; i++)
	{
		phantoms_b[i] Show();
		phantoms_b[i] thread f4_add_contrails();
		align_node thread anim_single(phantoms_b[i], "flyby");
		phantoms_b[i] thread f4_delete_on_end();
	}
}

f4_delete_on_end()
{
	self waittillmatch("single anim", "end");
	self delete();
}

//self is F4
f4_add_contrails()
{
	playfxontag(level._effect["jet_contrail"], self, "tag_left_wingtip" );
	playfxontag(level._effect["jet_contrail"], self, "tag_right_wingtip" );
	playfxontag(level._effect["jet_exhaust"], self, "tag_engine_l" );
	playfxontag(level._effect["jet_exhaust"], self, "tag_engine_r" );
}

phys_pulse()
{
	level waittill("player_surfaced");

	pulse_struct = GetStruct("finale_phys_pulse", "targetname");
	physicsExplosionSphere( pulse_struct.origin, pulse_struct.radius, pulse_struct.radius * 0.9, 1 );
}

test_fucking_fog()
{
	self endon("fuck sauce");
	level endon("player_surfaced");

	while (1)
	{
		level.player ClientNotify( "swimming_begin" );
		wait(1.0);
	}
}

roll_sea_entity()
{
	level endon( "death" );

    seaent = spawn( "script_origin", level.player.origin );
    level.player PlayerSetGroundReferenceEnt( seaent );

	//self rotateto( (1.5,0,1.5), 3, 0.5, 0.75 );
	//self waittill( "rotatedone" );
	//self rotateto( (-1.5,0,-1.5), 3, 0.5, 0.75 );
	//self waittill( "rotatedone" );

	weaver_boat = GetEnt("weaver_boat", "targetname");
    while(true)
    {
		seaent.angles = (weaver_boat.angles[0], 0, weaver_boat.angles[2]);
		wait(0.05);
    }
}

setup_floating_debris_types()
{
	level.floating_debris = [];

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "anim_rus_airlock_door_pi";
	level.floating_debris[level.floating_debris.size-1].min_vel = 15;
	level.floating_debris[level.floating_debris.size-1].max_vel = 20;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;
	
	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "anim_rus_broadcast_buoy_pi";
	level.floating_debris[level.floating_debris.size-1].min_vel = 40;
	level.floating_debris[level.floating_debris.size-1].max_vel = 50;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;

	//level.floating_debris[level.floating_debris.size] = SpawnStruct();
	//level.floating_debris[level.floating_debris.size-1].name = "dest_glo_dest_glo_crate01_short_d0";
	//level.floating_debris[level.floating_debris.size-1].min_vel = 10;
	//level.floating_debris[level.floating_debris.size-1].max_vel = 12;
	//level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	//level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	//level.floating_debris[level.floating_debris.size-1].count = 1;

	//level.floating_debris[level.floating_debris.size] = SpawnStruct();
	//level.floating_debris[level.floating_debris.size-1].name = "fxanim_creek_fish4_mod";
	//level.floating_debris[level.floating_debris.size-1].min_vel = -17;
	//level.floating_debris[level.floating_debris.size-1].max_vel = -12;
	//level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	//level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	//level.floating_debris[level.floating_debris.size-1].count = 6;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "fxanim_uwb_aft_crane_mod";
	level.floating_debris[level.floating_debris.size-1].min_vel = 45;
	level.floating_debris[level.floating_debris.size-1].max_vel = 50;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "fxanim_uwb_aft_radio_tower_mod";
	level.floating_debris[level.floating_debris.size-1].min_vel = 45;
	level.floating_debris[level.floating_debris.size-1].max_vel = 50;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "fxanim_uwb_fwd_crows_nest_mod";
	level.floating_debris[level.floating_debris.size-1].min_vel = 35;
	level.floating_debris[level.floating_debris.size-1].max_vel = 40;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "fxanim_uwb_sub_hoist_mod";
	level.floating_debris[level.floating_debris.size-1].min_vel = 30;
	level.floating_debris[level.floating_debris.size-1].max_vel = 35;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_dest_transformer_ceilingunit01_base";
	level.floating_debris[level.floating_debris.size-1].min_vel = 10;
	level.floating_debris[level.floating_debris.size-1].max_vel = 12;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_dest_transformer_ceilingunit01_panel";
	level.floating_debris[level.floating_debris.size-1].min_vel = 5;
	level.floating_debris[level.floating_debris.size-1].max_vel = 10;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 3;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_ger_wirespool";
	level.floating_debris[level.floating_debris.size-1].min_vel = 15;
	level.floating_debris[level.floating_debris.size-1].max_vel = 20;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_glo_ac_unit_lrg";
	level.floating_debris[level.floating_debris.size-1].min_vel = 25;
	level.floating_debris[level.floating_debris.size-1].max_vel = 30;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_glo_ammo_box_palette_a_destroyed";
	level.floating_debris[level.floating_debris.size-1].min_vel = 15;
	level.floating_debris[level.floating_debris.size-1].max_vel = 20;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_glo_barrel_metal_green";
	level.floating_debris[level.floating_debris.size-1].min_vel = 10;
	level.floating_debris[level.floating_debris.size-1].max_vel = 15;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 3;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_glo_bucket_metal";
	level.floating_debris[level.floating_debris.size-1].min_vel = -17;
	level.floating_debris[level.floating_debris.size-1].max_vel = -15;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 5;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_glo_barrel_metal_blue_old";
	level.floating_debris[level.floating_debris.size-1].min_vel = 10;
	level.floating_debris[level.floating_debris.size-1].max_vel = 15;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_glo_cans_single04";
	level.floating_debris[level.floating_debris.size-1].min_vel = -12;
	level.floating_debris[level.floating_debris.size-1].max_vel = -10;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 5;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_glo_crate01";
	level.floating_debris[level.floating_debris.size-1].min_vel = 10;
	level.floating_debris[level.floating_debris.size-1].max_vel = 15;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_glo_crate_wood_01";
	level.floating_debris[level.floating_debris.size-1].min_vel = 10;
	level.floating_debris[level.floating_debris.size-1].max_vel = 12;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_glo_gascan";
	level.floating_debris[level.floating_debris.size-1].min_vel = -7;
	level.floating_debris[level.floating_debris.size-1].max_vel = -5;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 4;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_glo_palette";
	level.floating_debris[level.floating_debris.size-1].min_vel = -3;
	level.floating_debris[level.floating_debris.size-1].max_vel = -2;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_jun_fan_lrg";
	level.floating_debris[level.floating_debris.size-1].min_vel = 3;
	level.floating_debris[level.floating_debris.size-1].max_vel = 5;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 3;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_phys_trashcan_metal_black";
	level.floating_debris[level.floating_debris.size-1].min_vel = -6;
	level.floating_debris[level.floating_debris.size-1].max_vel = -4;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 4;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_bulkhead_door_pi";
	level.floating_debris[level.floating_debris.size-1].min_vel = 20;
	level.floating_debris[level.floating_debris.size-1].max_vel = 25;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_bunker_support_brace";
	level.floating_debris[level.floating_debris.size-1].min_vel = 10;
	level.floating_debris[level.floating_debris.size-1].max_vel = 12;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_cargo_palette";
	level.floating_debris[level.floating_debris.size-1].min_vel = 15;
	level.floating_debris[level.floating_debris.size-1].max_vel = 20;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_crail88_pi";
	level.floating_debris[level.floating_debris.size-1].min_vel = 8;
	level.floating_debris[level.floating_debris.size-1].max_vel = 10;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 3;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_crate_metal_1";
	level.floating_debris[level.floating_debris.size-1].min_vel = 10;
	level.floating_debris[level.floating_debris.size-1].max_vel = 14;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_debris_pipe";
	level.floating_debris[level.floating_debris.size-1].min_vel = -7;
	level.floating_debris[level.floating_debris.size-1].max_vel = -5;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 6;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_desk_metal_short";
	level.floating_debris[level.floating_debris.size-1].min_vel = 20;
	level.floating_debris[level.floating_debris.size-1].max_vel = 25;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_fuelstorage_tank";
	level.floating_debris[level.floating_debris.size-1].min_vel = 45;
	level.floating_debris[level.floating_debris.size-1].max_vel = 50;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_hatch_door_pi";
	level.floating_debris[level.floating_debris.size-1].min_vel = 15;
	level.floating_debris[level.floating_debris.size-1].max_vel = 20;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_lifeboat_hoist_pi";
	level.floating_debris[level.floating_debris.size-1].min_vel = 30;
	level.floating_debris[level.floating_debris.size-1].max_vel = 35;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_life_pres_pi";
	level.floating_debris[level.floating_debris.size-1].min_vel = -10;
	level.floating_debris[level.floating_debris.size-1].max_vel = -5;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 4;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_minisub";
	level.floating_debris[level.floating_debris.size-1].min_vel = 55;
	level.floating_debris[level.floating_debris.size-1].max_vel = 60;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_paint_can";
	level.floating_debris[level.floating_debris.size-1].min_vel = -8;
	level.floating_debris[level.floating_debris.size-1].max_vel = -5;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 5;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_pipe_box";
	level.floating_debris[level.floating_debris.size-1].min_vel = 5;
	level.floating_debris[level.floating_debris.size-1].max_vel = 8;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_pipes_modular_clampc";
	level.floating_debris[level.floating_debris.size-1].min_vel = 20;
	level.floating_debris[level.floating_debris.size-1].max_vel = 25;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_pipes_modular_straight_yelow_128";
	level.floating_debris[level.floating_debris.size-1].min_vel = 7;
	level.floating_debris[level.floating_debris.size-1].max_vel = 10;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_pipes_modular_straight_orange_256";
	level.floating_debris[level.floating_debris.size-1].min_vel = 12;
	level.floating_debris[level.floating_debris.size-1].max_vel = 15;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_radar_dish_dest";
	level.floating_debris[level.floating_debris.size-1].min_vel = 45;
	level.floating_debris[level.floating_debris.size-1].max_vel = 50;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_rail52_pi";
	level.floating_debris[level.floating_debris.size-1].min_vel = 8;
	level.floating_debris[level.floating_debris.size-1].max_vel = 12;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 4;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_sign_no_smoking";
	level.floating_debris[level.floating_debris.size-1].min_vel = -10;
	level.floating_debris[level.floating_debris.size-1].max_vel = -5;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_sign_donot_enter";
	level.floating_debris[level.floating_debris.size-1].min_vel = -10;
	level.floating_debris[level.floating_debris.size-1].max_vel = -5;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_storage_crate_dest";
	level.floating_debris[level.floating_debris.size-1].min_vel = 15;
	level.floating_debris[level.floating_debris.size-1].max_vel = 20;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 3;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_rus_tower02";
	level.floating_debris[level.floating_debris.size-1].min_vel = 35;
	level.floating_debris[level.floating_debris.size-1].max_vel = 40;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_uwb_bubble_window";
	level.floating_debris[level.floating_debris.size-1].min_vel = -10;
	level.floating_debris[level.floating_debris.size-1].max_vel = -5;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 4;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_uwb_ship_deck_tiedown";
	level.floating_debris[level.floating_debris.size-1].min_vel = 10;
	level.floating_debris[level.floating_debris.size-1].max_vel = 15;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 2;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "p_uwb_ship_deck_vent_bent";
	level.floating_debris[level.floating_debris.size-1].min_vel = 20;
	level.floating_debris[level.floating_debris.size-1].max_vel = 25;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "undr_aircompressor_lg";
	level.floating_debris[level.floating_debris.size-1].min_vel = 30;
	level.floating_debris[level.floating_debris.size-1].max_vel = 35;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "undr_airtank";
	level.floating_debris[level.floating_debris.size-1].min_vel = 5;
	level.floating_debris[level.floating_debris.size-1].max_vel = 10;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 5;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "undr_locker_military";
	level.floating_debris[level.floating_debris.size-1].min_vel = 15;
	level.floating_debris[level.floating_debris.size-1].max_vel = 20;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 1;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "undr_torpedo_a";
	level.floating_debris[level.floating_debris.size-1].min_vel = 30;
	level.floating_debris[level.floating_debris.size-1].max_vel = 35;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 5;

	level.floating_debris[level.floating_debris.size] = SpawnStruct();
	level.floating_debris[level.floating_debris.size-1].name = "undr_wall_light";
	level.floating_debris[level.floating_debris.size-1].min_vel = -8;
	level.floating_debris[level.floating_debris.size-1].max_vel = -5;
	level.floating_debris[level.floating_debris.size-1].min_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].max_rot_vel = (0,0,0);
	level.floating_debris[level.floating_debris.size-1].count = 4;

	total = 0;
	for (i = 0; i < level.floating_debris.size; i++)
	{
		PreCacheModel(level.floating_debris[i].name);
		total += level.floating_debris[i].count;
	}

	PrintLn("Total: " + total);
}



