/*
//-- Level: Underwater Base
//-- Level Designer: Gavin Goslin
//-- Scripter: Alfeche/Vento
*/

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\underwaterbase_util;
#include maps\_vehicle_turret_ai;
#include maps\_vehicle;
#include maps\_ai_rappel;
#include maps\_vehicle_aianim;
#include maps\_anim;

// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	// misc setup necessary to make the skipto work goes here
	run();
}

run()
{
	//initialize the event
	init_event();

	// JMA - TEMP helicopter until huey
	level thread maps\underwaterbase_huey::start();

	// dialogue
	level thread dialogue();

	// first play the intro cinematic, whatever that may be // TODO: Remove if there is no intro cinematic
	play_intro_cinematic();

	// setup the objectives
	level thread objectives(0);
	
	// destruction thread
	level thread ship_destruction();

	// start the player Huey in formation
	level thread start_player_flight_sequence();
	
	// start the friendly Huey formation
	level thread start_heli_friendly_sequence();

	// thread that starts aa gun fire
	level thread activate_heavy_resistance();

	// thread the SAM attack that occurs on the incoming friendly Huey formation
	level thread start_Huey_SAM_attack_sequence();

	level thread fire_damage();

	// start the water movement
	//level thread update_water_plane("ship_exterior", 40.0, 25.0, (-0.5,0,0.5));

	// clean up threads
	level thread level_spawner_cleanup();
	level thread level_damage_trigger_cleanup();

	clear_heavy_resistance();

	autosave_by_name("airsupport_start");

	cleanup();
	
	// run the airsupport sequence
	maps\underwaterbase_airsupport::run();
}

init_event()
{	
	ub_print( "init introigc\n" );

	maps\createart\underwaterbase_art::set_chopper_fog_and_vision();

	setup_topside_water();

	get_players()[0] setClientDvar( "cg_fov", level.huey_fov );

	//  test gib delay
	anim.gibDelay = 0;

	player = get_players()[0];
	player SetClientDvar("cg_aggressiveCullRadius", 500);
}

// gets run through at start of level
init_flags()
{
	flag_init( "heavy_resistance_encountered" );
	flag_init( "aa_gun_heavy_resistance_cleared_bow" );
	flag_init( "aa_gun_heavy_resistance_cleared_mid" );
	flag_init( "aa_gun_heavy_resistance_cleared_stern" );
	flag_init( "sam_heavy_resistance_cleared" );
	flag_init( "all_heavy_resistance_cleared" );
	flag_init( "sam_missile_bow" );
	flag_init( "sam_missile_mid_ship" );
	flag_init( "sam_missile_stern" );
	
	maps\underwaterbase_airsupport::init_flags();
}

objectives( starting_obj_num )
{
	level.curr_obj_num = starting_obj_num;

	flag_wait("heavy_resistance_encountered");
	
	// player takes out heavy resistance	
	objective_add( level.curr_obj_num, "current", &"UNDERWATERBASE_OBJ_ASSAULT_RUSALKA" );
	objective_set3d( level.curr_obj_num, true, "default", &"UNDERWATERBASE_OBJ_TARGET" );

	// get bow resistance
	for (i = 0; i < level.aa_guns["bow"].size; i++)
	{
		if (IsAlive(level.aa_guns["bow"][i]))
		{
			level.aa_guns["bow"][i].obj_num = i;
			Objective_AdditionalPosition(level.curr_obj_num, i, level.aa_guns["bow"][i].origin + (0,0,128));		
		}
	}

	sam_missile_bow = GetEnt("sam_missile_bow", "script_noteworthy");
	sam_missile_bow.obj_num = level.aa_guns["bow"].size + 1;
	if (IsDefined(sam_missile_bow.script_int))
	{
		if (IsAlive(sam_missile_bow))
		{
			obj_struct = GetStruct("heavy_resistance_target_" + Int(sam_missile_bow.script_int), "targetname");
 			Objective_AdditionalPosition(level.curr_obj_num, sam_missile_bow.obj_num, obj_struct.origin);
		}
	}

	flag_wait("aa_gun_heavy_resistance_cleared_bow");
	flag_wait("sam_missile_bow");

	for (i = 0; i < 8; i++)
	{
		Objective_AdditionalPosition(level.curr_obj_num, i, (0,0,0));		
	}
	wait( 0.1 );	// give time for death notifies to be triggerred

	// get mid ship resistance
	for (i = 0; i < level.aa_guns["mid"].size; i++)
	{
		if (IsAlive(level.aa_guns["mid"][i]))
		{
			level.aa_guns["mid"][i].obj_num = i;
			Objective_AdditionalPosition(level.curr_obj_num, i, level.aa_guns["mid"][i].origin + (0,0,128));
		}
	}

	//sam_missile_mid = GetEnt("sam_missile_mid_ship", "script_noteworthy");
	//sam_missile_mid.obj_num = level.aa_guns["mid"].size + 1;
	//if (IsDefined(sam_missile_mid.script_int))
	//{
	//	if (IsAlive(sam_missile_mid))
	//	{
	//		obj_struct = GetStruct("heavy_resistance_target_" + Int(sam_missile_mid.script_int), "targetname");
	//		Objective_AdditionalPosition(level.curr_obj_num, sam_missile_mid.obj_num, obj_struct.origin);
	//	}
	//}

	flag_wait("aa_gun_heavy_resistance_cleared_mid");
	//flag_wait("sam_missile_mid_ship");

	for (i = 0; i < 8; i++)
	{
		Objective_AdditionalPosition(level.curr_obj_num, i, (0,0,0));		
	}
	wait( 0.1 );	// give time for death notifies to be triggerred

	// get stern resistance
	for (i = 0; i < level.aa_guns["stern"].size; i++)
	{
		if (IsAlive(level.aa_guns["stern"][i]))
		{
			level.aa_guns["stern"][i].obj_num = i;
			Objective_AdditionalPosition(level.curr_obj_num, i, level.aa_guns["stern"][i].origin + (0,0,128));		
		}
	}

	sam_missile_stern = GetEnt("sam_missile_stern", "script_noteworthy");
	sam_missile_stern.obj_num = level.aa_guns["stern"].size + 1;
	if (IsDefined(sam_missile_stern.script_int))
	{
		if (IsAlive(sam_missile_stern))
		{
			obj_struct = GetStruct("heavy_resistance_target_" + Int(sam_missile_stern.script_int), "targetname");
 			Objective_AdditionalPosition(level.curr_obj_num, sam_missile_stern.obj_num, obj_struct.origin + (0,0,128));
		}
	}

	flag_wait("aa_gun_heavy_resistance_cleared_stern");
	flag_wait("sam_missile_stern");

	flag_set( "all_heavy_resistance_cleared" );

	objective_state( level.curr_obj_num, "done" );
	objective_set3d( level.curr_obj_num, false );
//	objective_delete( level.curr_obj_num );
	level.curr_obj_num++;
	maps\underwaterbase_airsupport::objectives( level.curr_obj_num );
}

cleanup()
{
	ub_print( "cleanup introigc\n" );
	
	// reset any misc dvars to default
	
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

play_intro_cinematic()
{	
	flag_wait("starting final intro screen fadeout");
	level thread heli_hint_tutorial();
	wait (0.05);

	player = get_players()[0];
	player SetPlayerAngles(level.huey GetTagAngles("tag_driver"));

	//level.huey thread maps\underwaterbase_huey::huey_simple_control();
}

heli_hint_tutorial()
{
	screen_message_create(&"PLATFORM_HELI_INSTRUCTION_1", &"PLATFORM_HELI_INSTRUCTION_2");
	
	wait(4.0);

	screen_message_delete();

	screen_message_create(&"UNDERWATERBASE_HELI_INSTRUCTION_3");

	wait(4.0);

	screen_message_delete();
}

start_player_flight_sequence()
{	
	clip = GetEnt("edge_clip", "targetname");
	clip notsolid();

	SetSavedDvar("cg_hideWeaponHeat", true);

	// Put Hudson in the co-pilots seat
	level.heroes["hudson"] LinkTo(level.huey, "tag_passenger");
	level.huey thread anim_loop_aligned(level.heroes["hudson"], "pilot_idle", "tag_passenger");

	player = get_players()[0];
	level.huey SetViewClamp(player, 45, 45, 25, 20);

	// start the intro 
	start_node = GetVehicleNode( "player_huey_start", "targetname" );
	end_node = GetVehicleNode( start_node.target, "targetname" );
	AssertEx( IsDefined(start_node), "Unknown start node for huey pathing: player_huey_start");
	level.huey.origin = start_node.origin;

	//level.huey.lockheliheight = false;
	//level.huey SetVehMaxSpeed(60);
	//SetSavedDvar("vehHelicopterForcedMoveAxis", "1 0");
	//SetSavedDvar("vehHelicopterScaleTurnAxis", "0");

	//level thread blah();

	//level waittill("start_heavy_resistance");

	//wait(2);

	//level notify("end_rotate");
	//level.huey ResetViewClamp(player);
	//level.huey.lockheliheight = true;
	//level.huey SetVehMaxSpeed(70);
	//SetSavedDvar("vehHelicopterForcedMoveAxis", "0 0");
	//SetSavedDvar("vehHelicopterScaleTurnAxis", "1");

//	velocity = end_node.origin - start_node.origin;
//	velocity = (velocity[0], velocity[1], 0);
//	velocity = VectorNormalize(velocity);
//	velocity = velocity * 1000;

	level.huey thread go_path(start_node);
//	level.huey thread huey_simple_control();

	level.huey waittill ("reached_path_end");
	level.huey unlink();
	level.huey ReturnPlayerControl();
	level.huey ResetViewClamp(player);

	clip solid();	
}

blah()
{
	level endon("end_rotate");

	while (1)
	{
		level.huey SetAngularVelocity((0,0,0));
		wait(0.05);
	}
}

start_heli_friendly_sequence()
{	
	trigger_use("trig_start_friendly_hueys");

	wait(0.05);

	level thread start_friendly_huey_A(); // rear upper right Huey - Weaver's Huey
	level thread start_friendly_huey_B(); // front bottom left Huey - Support Huey
	level thread start_friendly_huey_C(); // rear upper left Huey - gets destroyed at start by SAM
	level thread start_friendly_huey_D(); // front bottom right Huey - gets destroyed at start by SAM
}


// Huey A - Weaver's Huey
start_friendly_huey_A()
{		
	heli = GetEnt("friendly_huey_A", "targetname"); 
	heli init_friendly_heli("friendly_huey_A_start");

	// Put Weaver in the Heli
	level.heroes["weaver"] vehicle_enter(heli, "tag_passenger4");

	// give him a pilot
	heli.pilot = spawn_character("pilot", (0,0,0), (0,0,0), "pilot");
	heli.pilot LinkTo(heli, "tag_driver");
	heli thread anim_loop_aligned(heli.pilot, "idle", "tag_driver");

	// give him a co-pilot
	heli.copilot = spawn_character("pilot", (0,0,0), (0,0,0), "copilot");
	heli.copilot LinkTo(heli, "tag_passenger");
	heli thread anim_loop_aligned(heli.copilot, "idle", "tag_passenger");

	// wait till end node
	heli waittill("reached_end_node");

	heli thread heli_avoidance();

	// grab initial targets
	targets = GetEntArray("aa_gun_bow_portside", "targetname");

	heli thread friendly_huey_think(targets, "move_mid_ship");

	flag_wait("aa_gun_heavy_resistance_cleared_bow");

	heli notify("move_mid_ship");

	// spawn mid ship resistance
	trigger_use("trig_resistance_mid_guys");

	wait(0.05);

	// grab initial targets
	targets = GetEntArray("aa_gun_mid_portside", "targetname");

	heli thread friendly_huey_think(targets, "move_stern_ship");

	flag_wait("aa_gun_heavy_resistance_cleared_mid");

	heli notify("move_stern_ship");

	wait(0.05);

	// grab initial targets
	targets = GetEntArray("aa_gun_stern_portside", "targetname");
	heli._forced_target_ent_array = targets;

	heli thread friendly_huey_think(targets, "resistance_done");

	// wait till targets are down
	flag_wait( "aa_gun_heavy_resistance_cleared_stern" );

	heli notify("resistance_done");
}

// Huey B - Front Left Huey
//	* triggers heavy resistance upon approach
start_friendly_huey_B()
{
	heli = GetEnt("friendly_huey_B", "targetname"); 
	heli init_friendly_heli("friendly_huey_B_start");

	// give us a pilot and copilot
	heli.pilot = spawn_character("pilot", (0,0,0), (0,0,0), "pilot");
	heli.pilot LinkTo(heli, "tag_driver");
	heli thread anim_loop_aligned(heli.pilot, "idle", "tag_driver");

	heli.copilot = spawn_character("pilot", (0,0,0), (0,0,0), "copilot");
	heli.copilot LinkTo(heli, "tag_passenger");
	heli thread anim_loop_aligned(heli.copilot, "idle", "tag_passenger");

	heli waittill("start_heavy_resistance");

	level notify("start_heavy_resistance" );

	rpg_start = GetStructArray("intro_fake_rpg_start", "targetname");
	level thread spawn_fake_rpg( rpg_start[RandomInt(rpg_start.size)].origin , heli.origin, 1.5);
	wait(2);
	level thread spawn_fake_rpg( rpg_start[RandomInt(rpg_start.size)].origin , heli.origin, 1.5);
	
	// spawnt the guys on the bow
	trigger_use("trig_resistance_bow_guys");

	heli waittill("reached_end_node");

	// avoid player
	heli thread heli_avoidance();

	//// move to the starting spot
	//start_pos = GetEnt("introigc_huey_b_start", "targetname");
	//heli SetSpeed(55, 25, 25);
	//heli SetVehGoalPos(start_pos.origin);
	//heli SetLookAtEnt(start_pos);
	//heli waittill("goal");

	// grab initial targets
	targets = GetEntArray("aa_gun_bow_starboard", "targetname");
	heli._forced_target_ent_array = targets;

	heli thread friendly_huey_think(targets, "move_mid_ship");

	// Do exploder
	wait(3.0);
	Exploder(101);

	flag_wait("aa_gun_heavy_resistance_cleared_bow");

	heli notify("move_mid_ship");

	wait(0.05);

	// grab initial targets
	targets = GetEntArray("aa_gun_mid_starboard", "targetname");
	heli._forced_target_ent_array = targets;

	heli thread friendly_huey_think(targets, "move_stern_ship");

	// Do Exploder
	wait(2.0);
	Exploder(102);

	flag_wait("aa_gun_heavy_resistance_cleared_mid");

	heli notify("move_stern_ship");

	wait(0.05);

	// grab initial targets
	targets = GetEntArray("aa_gun_stern_starboard", "targetname");
	heli._forced_target_ent_array = targets;

	heli thread friendly_huey_think(targets, "resistance_done");

	// wait till targets are down
	flag_wait( "aa_gun_heavy_resistance_cleared_stern" );

	heli notify("resistance_done");
}

// Huey C - Gets hit by SAM missile at start
start_friendly_huey_C()
{	
	heli = GetEnt("friendly_huey_C", "targetname"); 
	heli init_friendly_heli("friendly_huey_C_start");

//	heli waittill("fake_rpg_fire");	
//	rpg_start = GetStructArray("intro_fake_rpg_start", "targetname");
//	level thread spawn_fake_rpg( rpg_start[RandomInt(rpg_start.size)].origin , heli.origin, 0.5);
//	level thread spawn_fake_rpg( rpg_start[RandomInt(rpg_start.size)].origin , heli.origin, 0.75);

	heli waittill("explode_me");
	
	heli PlaySound( "evt_enemy_crash" );

	PlayFxOnTag( level._effect["huey_fire"], heli, "origin_animate_jnt" );

	heli.supportsAnimScripted = true;
	heli.animname = "helicopter";
	heli UseAnimTree(level.scr_animtree["helicopter"]);
	heli thread anim_single(heli, "heli_crash_missile_02");

	wait(3.0);

	PlayFx( level._effect["explosion_heli"], heli GetTagOrigin("origin_animate_jnt"), (0,0,1), (1,0,0) );

	heli Delete();
	
	level notify("friendly_huey_death_C");	
}

// Huey D - Gets hit by SAM missile at start
start_friendly_huey_D()
{	
	heli = GetEnt("friendly_huey_D", "targetname"); 
	heli init_friendly_heli("friendly_huey_D_start");

	sam_launcher = GetEnt("sam_missile_bow", "script_noteworthy");
	sam_launcher.lock_on_ent = spawn("script_origin", sam_launcher.origin);
	sam_launcher SetTurretTargetEnt(heli);

//	heli waittill("fake_rpg_fire");	

	wait(5);

	sam_launcher thread sam_missiles_fire(heli, true, true);

//	rpg_start = GetStructArray("intro_fake_rpg_start", "targetname");
//	level thread spawn_fake_rpg( rpg_start[RandomInt(rpg_start.size)].origin , heli.origin, 0.5);
//	level thread spawn_fake_rpg( rpg_start[RandomInt(rpg_start.size)].origin , heli.origin, 0.75);
	
	heli waittill("explode_me");

	level.huey thread player_heli_avoidance(heli);

	heli PlaySound( "evt_enemy_crash" );
	
	PlayFxOnTag( level._effect["huey_fire"], heli, "origin_animate_jnt" );

	heli.supportsAnimScripted = true;
	heli.animname = "helicopter";
	heli UseAnimTree(level.scr_animtree["helicopter"]);
	heli anim_single(heli, "heli_crash_missile_01");

	PlayFx( level._effect["explosion_heli"], heli GetTagOrigin("origin_animate_jnt"), (0,0,1), (1,0,0) );
	heli Delete();	

	level.huey notify("done_avoiding");

	level notify("friendly_huey_death_D");
}

friendly_huey_think(targets, end_notify)
{
	self endon("death");
	self endon(end_notify);

	// simple brain that picks a target and "engages" it
	while (targets.size > 0)
	{
		// pick a target
		//target = Random(targets);
		target = get_closest_living(self.origin, targets);
		if ( IsDefined( target ) )
		{
			self thread heli_engage(target, 1500, 500, 0, 1000, 0.5, 1.0, end_notify, 2);

			target waittill("death");

			targets = array_removeUndefined(targets);
			targets = array_removeDead(targets);
		}
		wait( 0.5 );
	}
}

activate_heavy_resistance()
{
	level.aa_guns = [];
	level.aa_guns["bow"] = GetEntArray("aa_gun_heavy_resistance_bow","script_noteworthy");
	level.aa_guns["mid"] = GetEntArray("aa_gun_heavy_resistance_mid","script_noteworthy");
	level.aa_guns["stern"] = GetEntArray("aa_gun_heavy_resistance_stern","script_noteworthy");

	array_thread(level.aa_guns["bow"], ::aa_gun_init);
	array_thread(level.aa_guns["mid"], ::aa_gun_init);
	array_thread(level.aa_guns["stern"], ::aa_gun_init);

	level waittill("start_heavy_resistance");
	clientnotify( "alms1" );

	flag_set("heavy_resistance_encountered");
	level notify("heavy_resistance_encountered");

	array_thread(level.aa_guns["bow"], ::aa_gun_think);
	array_thread(level.aa_guns["mid"], ::aa_gun_think);
	array_thread(level.aa_guns["stern"], ::aa_gun_think);

	level thread aa_guns_cleared(level.aa_guns["bow"], "aa_gun_heavy_resistance_cleared_bow");
	level thread aa_guns_cleared(level.aa_guns["mid"], "aa_gun_heavy_resistance_cleared_mid");
	level thread aa_guns_cleared(level.aa_guns["stern"], "aa_gun_heavy_resistance_cleared_stern");

	sam_launchers = GetEntArray("sam_missile_launcher", "targetname");
	array_thread(sam_launchers, ::sam_launcher_think);

	// activate sam missiles
	level.sam_heavy_resistance_num = sam_launchers.size;
	level.sam_heavy_resistance_num_destroyed = 0;
}

aa_guns_cleared(aa_guns, flag_name)
{
	for (i = 0; i < aa_guns.size; i++)
	{
		aa_guns[i].flag_name = flag_name;
	}

	array_wait(aa_guns, "death");
	flag_set(flag_name);
}

start_Huey_SAM_attack_sequence()
{	
	flag_wait("heavy_resistance_encountered");	

	SetSavedDvar("cg_hideWeaponHeat", false);
	level.huey thread maps\underwaterbase_huey::init_huey_weapons();
}

clear_heavy_resistance()
{
//	flag_wait( "aa_gun_heavy_resistance_cleared" );
//	flag_wait( "sam_heavy_resistance_cleared" );
//	flag_set( "all_heavy_resistance_cleared" );
//	flag_wait( "weaver_squad_unloaded" );

	flag_wait( "all_heavy_resistance_cleared" );
}

aa_gun_init()
{
	self thread aa_gun_death_watcher();

	player = get_player();	
	
	//setup aa gun - this is a vehicle
	self SetCanDamage( true );
	self.health = 500;
	self.team = "axis";
	
	self.targets_player = false;
	if (IsDefined(self.script_string) && self.script_string == "target_player")
	{
		self.targets_player = true;
		self._forced_target_ent_array = array(player);
	}

	if (self.targets_player)
	{
		heli_target = get_players()[0];
	}
	else
	{
//		heli_target = undefined;
//		if (IsDefined(self.script_int) && self.script_int == 2)
//		{
//			heli_target = GetEnt("friendly_huey_C", "targetname");
//		}
//		else
//		{
			heli_target = getClosest( self.origin, GetEntArray( "huey_allies", "script_noteworthy" ) );
//		}
	}
	self SetTurretTargetEnt( heli_target, (0,0,0) );

	if (IsDefined(self.script_noteworthy) && self.script_noteworthy == "aa_gun_heavy_resistance_bow")
	{
		self thread aa_gun_continuous_fire(15);
	}
}

aa_gun_death_watcher()
{
	self waittill("damage", amount, attacker, direction_vec, P, type);
	shit = 1;
}

//handles aa gun destruction
aa_gun_think()
{
	self thread aa_fireControlThink();
	self thread aa_fire();

	self.obj_num = -1;
	
	self waittill( "death" );	
	
	if (self.obj_num >= 0 )		// && !flag(self.flag_name))
	{
		Objective_AdditionalPosition(level.curr_obj_num, self.obj_num, (0,0,0));
	}

	//playsoundatposition( "evt_aa_gun_explode", gun.origin );
	explosion_launch(self.origin, 256, 150, 200, 35, 45);
	
	// do radius damage to destroy near by stuff
	//RadiusDamage(self.origin, 128, 1500, 1000);
}

// taken from collateral_damage_e5
aa_fireControlThink()
{
	self endon("death");
	self endon("stop_firing");
	
	self.OkToFire = true;
	while(true)
	{
		self waittill("turret_on_vistarget");
		self.OkToFire = true;
		self waittill("turret_no_vis");
		self.OkToFire = false;
	}
}

aa_gun_continuous_fire(time)
{
	self endon( "death" );
	sound_ent = spawn( "script_origin" , self.origin);
	self thread sound_ent_delete( sound_ent );
	
	while( time > 0.0 )
	{
//		heli_target = getClosest( self.origin, GetEntArray( "huey_allies", "script_noteworthy" ) );
//
//		self SetTurretTargetEnt( heli_target );
		self FireWeapon();
		sound_ent playloopsound( "wpn_50cal_fire_loop_npc" );

		time -= 0.05;
		wait(0.05);
	}
	sound_ent stoploopsound();
	sound_ent playsound( "wpn_50cal_fire_loop_ring_npc" );
}

aa_fire()
{
	self endon( "death" );
	
	sound_ent = spawn( "script_origin" , self.origin);
	self thread sound_ent_delete( sound_ent );
	
	burst_count = 0;
	
	while( 1 )
	{
		if( self.okToFire )
		{
			offset = ( RandomIntRange(0, 150), RandomIntRange(-150, 150), RandomIntRange(-150, 150));

			if (self.targets_player)
			{
				heli_target = get_players()[0];
			}
			else
			{
				heli_target = getClosest( self.origin, GetEntArray( "huey_allies", "script_noteworthy" ) );
			}

			if (IsAlive(heli_target))
			{
				self SetTurretTargetEnt( heli_target, offset );
				self FireWeapon();
				sound_ent playloopsound( "wpn_50cal_fire_loop_npc" );
				burst_count++;
				
				if( burst_count > 10 )
				{
					sound_ent stoploopsound();
					sound_ent playsound( "wpn_50cal_fire_loop_ring_npc" );
					wait(2);
					burst_count = 0;
				}
				else
				{
					wait( 0.1 );
				}
			}
		}
		else
		{			
			random_wait = RandomFloatRange(0.05, 0.15);
			wait(random_wait);
		}
	}
}

sound_ent_delete( sound_ent )
{
	self waittill( "death" );
	sound_ent Delete();
}

sam_launcher_think()
{
	// spawn a lock on ent to move around
	if (!IsDefined(self.lock_on_ent))
	{
		self.lock_on_ent = spawn("script_origin", self.origin);
	}

	// start the firing thread
	player = get_players()[0];
	self thread sam_missile_launcher_track_player();
	self thread sam_missiles_fire(player);

	self waittill("death");

	// turn off objective marker
	if (IsDefined(self.obj_num) && self.obj_num >= 0)
	{
		Objective_AdditionalPosition(level.curr_obj_num, self.obj_num, (0,0,0));
	}

	if (IsDefined(self.script_noteworthy))
	{
		flag_set(self.script_noteworthy);
	}

	level.sam_heavy_resistance_num_destroyed++;
	if(level.sam_heavy_resistance_num_destroyed >= level.sam_heavy_resistance_num)
	{
		flag_set( "sam_heavy_resistance_cleared" );
	}
}

sam_missile_launcher_track_player()
{
	self endon("death");

	while (1)
	{
		delta = level.huey.origin - self.origin;

		length = VectorDot(delta, delta);
		angles = VectorToAngles(delta);
		angles = (-23.5, angles[1], 0);

		target_vector = self.origin + AnglesToForward(angles) * length;

		self SetTurretTargetVec(target_vector);
		wait(0.05);
	}
}

sam_missiles_fire(target, force_tracking, single_burst)
{
	self endon("death");
	
	player = get_players()[0];

	//self SetTurretTargetEnt(target);
	
	level.huey.missiles_incoming = [];
	
	sam_missile_tags = [];
	sam_missile_tags[0] = "tag_missile1";
	sam_missile_tags[1] = "tag_missile11";
	sam_missile_tags[2] = "tag_missile22";
	sam_missile_tags[3] = "tag_missile15";
	sam_missile_tags[4] = "tag_missile8";
	sam_missile_tags[5] = "tag_missile34";
	missiles_shot = 0;

	track_dist_squared = 6000 * 6000;
	track_player = true;

	while(1)
	{
		if (IsDefined(force_tracking) && force_tracking)
		{
			track_target = true;
		}
		else
		{
			if (Distance2DSquared(self.origin, target.origin) < track_dist_squared)
			{
				track_target = true;
			}
			else 
			{
				track_target = false;
			}
		}

		if (track_target)
		{
			for (i = 0; i < sam_missile_tags.size; i++)
			{
				sam_origin = self GetTagOrigin(sam_missile_tags[i]);
				sam_angles = self GetTagAngles(sam_missile_tags[i]);

//				sam_origin = sam_origin + AnglesToForward(sam_angles) * 300;

	//			PlayFX(level._effect["sam_launch"], sam_origin);

				missile = undefined;
				if (track_target)
				{
					if (IsDefined(force_tracking) && force_tracking)
					{
						missile = MagicBullet("sam_uwb_sp", sam_origin, target.origin, undefined, target, (0,0,0) );
						missile.lock_on_ent = target;						
					}
					else
					{
						self.lock_on_ent.origin = target.origin;
						missile = MagicBullet("sam_uwb_sp", sam_origin, self.lock_on_ent.origin, undefined, self.lock_on_ent, (0,0,0) );
						missile.lock_on_ent = self.lock_on_ent;
					}
				}
				else
				{
					shoot_point = sam_origin + AnglesToForward(sam_angles) * 1500;
					missile = MagicBullet("sam_uwb_sp", sam_origin, shoot_point);
					missile.lock_on_ent = undefined;
				}

				missile thread missile_damage_watcher();
				missile thread missile_targeting_watcher(target);
				missile thread rocket_rumble_when_close(player);
				missile.origin_pt = sam_origin;
				level.huey.missiles_incoming[level.huey.missiles_incoming.size] = missile;

				wait(0.25);
			}
		}

		if (IsDefined(single_burst) && single_burst)
		{
			return;
		}

		wait(RandomFloatRange(4.0, 5.0));
	}
}

missile_damage_watcher()
{
	self endon("death");

	wait(0.15);
	self Solid();
	self SetCanDamage( true );
	self waittill( "damage" );
	self ResetMissileDetonationTime( 0 );
}

missile_targeting_watcher(target)
{
	self endon("death");

	while (1)
	{
		if (IsDefined(self.lock_on_ent))
		{
			vector_to_target = VectorNormalize(self.lock_on_ent.origin - self.origin);
			dir = AnglesToForward(flat_angle(self.angles));

			dot = VectorDot(vector_to_target, dir);
			if (dot < 0.0)
			{
				self ResetMissileDetonationTime( RandomFloatRange(0.15, 0.25) );
			}

			self.lock_on_ent.origin = (self.lock_on_ent.origin * 0.9) + (target.origin * 0.1);
		}
		wait(0.05);
	}
}

missile_lock_sounds() //-- self == trigger volume
{
	sound_on = false;
	player = get_players()[0];
	
	while(!flag( "sam_heavy_resistance_cleared" ))
	{
			while(self missiles_headed_at_me(self.missiles_incoming) )
			{
				if(!sound_on)
				{
					//iprintlnbold("missiles incoming");
					self.ent = spawn ("script_origin", player.origin );
					self.ent LinkTo( player );
					self.ent playloopsound("wpn_rocket_warning_loop");
					sound_on = true;
				}
			
				wait(0.05);
				self.missiles_incoming = array_removeUndefined(self.missiles_incoming);		
			}
			
			if(sound_on)
			{
				//iprintlnbold("stop looped_sound");
				self.ent StopLoopSound();
				self.ent delete();
				sound_on = false;
			}
			
			wait(0.05);
	}
	
	if(IsDefined(self.ent))
	{
		self.ent StopLoopSound();
		self.ent Delete();
	}
}

missiles_headed_at_me( missiles ) // are missiles headed at me?
{
	missile_warning_range = 20000;
	
	if( missiles.size <= 0 )
	{
		//-- no missiles exist, so none are headed at you
		return false;
	}
	
	for( i=0; i < missiles.size; i++)
	{
		if(IsDefined(missiles[i]))
		{
			me_to_origin = VectorNormalize( self.origin - missiles[i].origin_pt );
			me_to_missile = self.origin - missiles[i].origin;
			dot = VectorDot( me_to_origin, me_to_missile );
			if(  dot > 0 && dot < missile_warning_range)
			{
				if ( dot < 10000 )
				{
					missiles[i]	play_rocket_flyby();
				}			
				
				return true;
			}
		}
	}
	
	return false;
}

play_rocket_flyby()
{
	self endon ("death");
	
	if(IsDefined ( self.flybysound ) )
	{
		return;	
	}
	
	self.flybysound = true;
	self playsound("evt_rocket_flyby_close");		
}

// ship destruction
ship_destruction()
{
	// start exploders
	Exploder(100);
	
	// threads
	level thread bow_crows_nest();
	level thread aft_radio_tower();
	level thread aft_crane();
	level thread fwd_radio_tower();
	level thread fwd_wire_tower();
	level thread aft_wire_tower();
	level thread double_mast();
	level thread smokestack();
}

bow_crows_nest()
{
	damage_trig = GetEnt("trig_damage_bow_crows_nest", "targetname");
	damage_trig waittill("trigger");
	level notify("crows_nest_start");
}

aft_radio_tower()
{
	damage_trig = GetEnt("trig_damage_aft_radio_tower", "targetname");

	damage_trig trigger_off();
	flag_wait("aa_gun_heavy_resistance_cleared_bow");
	damage_trig trigger_on();

	damage_trig waittill("trigger");
	level notify("aft_radio_tower_start");
}

fwd_radio_tower()
{
	damage_trig = GetEnt("trig_damage_fore_radio_tower", "targetname");
	damage_trig waittill("trigger");
	level notify("fwd_radio_tower_start");
}

fwd_wire_tower()
{
	damage_trig = GetEnt("trig_damage_fwd_wire_tower", "targetname");

	damage_trig trigger_off();
	flag_wait("aa_gun_heavy_resistance_cleared_bow");
	damage_trig trigger_on();

	damage_trig waittill("trigger");
	level notify("fwd_wire_tower_b_start");
}

aft_wire_tower()
{
	damage_trig = GetEnt("trig_damage_aft_wire_tower", "targetname");

	damage_trig trigger_off();
	flag_wait("aa_gun_heavy_resistance_cleared_bow");
	damage_trig trigger_on();

	damage_trig waittill("trigger");
	level notify("aft_wire_tower_start");
}

aft_crane()
{
	level waittill("crane_impact");
	level notify("crane_fall_start");
}

double_mast()
{
	damage_trig = GetEnt("trig_damage_mid_mast", "targetname");

	damage_trig trigger_off();
	flag_wait("aa_gun_heavy_resistance_cleared_bow");
	damage_trig trigger_on();

	damage_trig waittill("trigger");
	level notify("dbl_mast_start");
}

smokestack()
{
//	trigger_wait( "trig_smokestack" );
	trig = GetEnt( "trig_smokestack", "targetname" );
	trig waittill( "trigger" );

	stop_exploder(100);	// stack smoke
}


dialogue()
{
	//flag_wait("introscreen_complete");

	player = get_players()[0];
	player.animname = "hudson";

	wait(12);

	player anim_single(level.heroes["weaver"], "visual_rusalka");
	player anim_single(player, "roger_yanker_one");
	player anim_single(level.heroes["weaver"], "approach");
	player anim_single(player, "your_stick");
	player anim_single(level.heroes["weaver"], "maintain_formation");

	level waittill("start_heavy_resistance");

	level.heroes["weaver"] anim_single(level.heroes["weaver"], "aa_fire_deck");
	level.heroes["hudson"] anim_single(level.heroes["hudson"], "expecting");
	level.heroes["hudson"] anim_single(level.heroes["hudson"], "engage_right");
	level.heroes["weaver"] anim_single(level.heroes["weaver"], "breaking_off");

	player.animname = "mason";
}

resistance_guy_kill_me(flag_name)
{
	self endon("death");
	flag_wait(flag_name);
	self DoDamage(self.health + 1000, self.origin);
}


//
//	Handle fire damage triggers
fire_damage()
{
	trigs = GetEntArray( "trig_fire_damage", "targetname" );
	for ( i=0; i<trigs.size; i++ )
	{
		trigs[i] trigger_off();
	}

 	flag_wait( "player_lands_huey" );	

	for ( i=0; i<trigs.size; i++ )
	{
		trigs[i] trigger_on();
	}

	flag_wait( "interior_3_objective" );

	for ( i=0; i<trigs.size; i++ )
	{
		trigs[i] Delete();
	}

}