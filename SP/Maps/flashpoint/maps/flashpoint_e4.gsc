////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL SCRIPTS
//
//
// Script for event 4 - this covers the following scenes from the design:
//		Slides 27-30
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_vehicle;
#include maps\_anim;
#include maps\flashpoint_util;
#include maps\_music;
#include maps\_audio;
#include maps\_vehicle_aianim;


////////////////////////////////////////////////////////////////////////////////////////////
// EVENT4 FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
// Squad walks thru compound
///////////////////////////////////////////////////////////////////////////////////////
cover_blown()
{
	self endon( "death" );
	level endon( "COMMS_BUILDING_DOOR_OPEN" );
	flag_wait( "PLAYER_MUST_DIE" );
	self.ignoreall = false;
	self StopAnimScripted();
	
// 	level.player SetLowReady( false );
// 	level.player AllowAds( true );
// 	level.player AllowSprint( true );
//  	level.player setclientdvar( "g_speed", default_speed );
}

die_in_x_sec( sec )
{
	level endon( "COMMS_BUILDING_DOOR_OPEN" );
	self endon( "death" );
	
	flag_wait( "PLAYER_MUST_DIE" );
	maps\_utility::missionFailedWrapper(&"FLASHPOINT_DEAD_COMM_SHOOT");	
	level.woods thread playVO_proper( "snipers", 1.0 );//Snipers!!!
	wait( sec );
	level.player Die();
	level.player Die();
}

cover_blown_player()
{	
	level endon( "COMMS_BUILDING_DOOR_OPEN" );
	self endon( "death" );
	
	self thread die_in_x_sec( 6.0 );
	
	self waittill( "damage" );
	//SetDvar( "ui_deadquote", "" ); 
	//level.player Die();
	//level.player Die();
}


// cover_blown_player()
// {
// 	//self endon( "death" );
// 	level endon( "COMMS_BUILDING_DOOR_OPEN" );
// 	flag_wait( "PLAYER_MUST_DIE" );
// 	SetDvar( "ui_deadquote", &"FLASHPOINT_DEAD_BASECOVER_BLOWN" ); 
// 	
// 	self waittill( "damage" );
// 	self Die();
// }

player_runs_off_wrong_way_fail()
{
	level endon( "COMMS_DOOR_SHUT" );
	
	exit_to_weaver_building_fail_trig = getent( "exit_to_weaver_building_fail", "targetname" );
	exit_to_weaver_building_fail_trig waittill( "trigger" );
	
	//FAIL!
	maps\_utility::missionFailedWrapper(&"FLASHPOINT_DEAD_STAY_WITH_WOODS");	
}

player_breaks_stealth_base()
{	
	self endon( "death" );
	level endon( "COMMS_BUILDING_DOOR_OPEN" );
	
	//while( isdefined( self ) )
	{
		self waittill_any( "weapon_fired", "grenade_fire" );
		flag_set( "PLAYER_MUST_DIE" );

		axis = GetAIArray( "axis" );	
		array_func( axis, ::turn_on_sticky_aim );
	}
}

woods_walk_compound()
{
	//TUEY SET music state to BASE_WALK
	setmusicstate ("BASE_WALK");
	
	self thread cover_blown();
	flag_wait( "BASE_ALERT" );
	
	level waittill( "do_what_they_do" );
	//self enable_cqbwalk();
	//wait( 0.3 );
	//self notify( "end_patrol" );
	
	self waittill( "reached_path_end" );
	
	node_woods4 = getnode( "node_woods_comms_start", "targetname" );
	self SetGoalNode( node_woods4 );
	
	flag_set( "READY_FOR_DISTRACTION_ANIM" );
	self waittill( "goal" );
	
	//Woods idle at bottom of stairs
	self thread anim_single( self, "reduced_to_one_idle" );
	
	//flag_set( "READY_FOR_DISTRACTION_ANIM" );
}

brooks_walk_compound()
{
	self thread cover_blown();
	flag_wait( "BASE_ALERT" );
	
	level waittill( "do_what_they_do" );
	wait( 0.4 );
	self waittill( "reached_path_end" );
	
	anim_node = get_anim_struct( "9" );
	anim_node anim_reach_aligned( self, "reduced_to_one_brooks_idle" );
	anim_node thread anim_loop_aligned( self, "reduced_to_one_brooks_idle" );
	flag_set( "DISTRACTION_SCENE_BROOKS_AT_GOAL" );
	self.goalradius = 64;
}

bowman_walk_compound()
{
	self thread cover_blown();
	flag_wait( "BASE_ALERT" );
	
	level waittill( "do_what_they_do" );
	wait( 0.5 );
	self waittill( "reached_path_end" );

	anim_node = get_anim_struct( "9" );
	anim_node anim_reach_aligned( self, "reduced_to_one_bowman_idle" );
	anim_node thread anim_loop_aligned( self, "reduced_to_one_bowman_idle" );

	flag_set( "DISTRACTION_SCENE_BOWMAN_AT_GOAL" );
	self.goalradius = 64;
}

alert_snipers()
{
//	comms_spawner_roof_sniper_array = getentarray( "comms_spawner_roof_sniper", "targetname" );
//	for( i=0; i<comms_spawner_roof_sniper.size; i++ )
//	{
//		comms_spawner_roof_sniper_array[i].ignoreall = false;
//	}
}

takes_damage_door_guard()
{
	level endon( "CLEANUP_BASE_ON_ROOF" );
	level endon( "COMMS_BUILDING_DOOR_OPEN" );
	level endon( "start_door_kick" );
	level endon( "DOOR_GUARD_DEAD" );
	
	self waittill_any( "damage" );
	wait( 0.2 );
	
	flag_set( "PLAYER_MUST_DIE" );
	flag_set( "BASE_ALERT" );
	alert_snipers();	

	if( isdefined(self) && isalive(self) )
	{
		self StopAnimScripted();
		self.ignoreall = false;
	}

}

takes_damage()
{
	//self endon( "PLAYER_MUST_DIE" );
	//self endon( "death" );
	level endon( "CLEANUP_BASE_ON_ROOF" );
	level endon( "COMMS_BUILDING_DOOR_OPEN" );
	
	self waittill_any( "damage" );
	flag_set( "PLAYER_MUST_DIE" );
	flag_set( "BASE_ALERT" );
	alert_snipers();	
	
	if( isdefined(self) && isalive(self) )
	{
		self StopAnimScripted();
		self.ignoreall = false;
	}
}

// takes_damage_from_player()
// {
// 	self endon( "PLAYER_MUST_DIE" );
// 	self endon( "death" );
// 	
// 	self waittill_any( "damage", "death" );
// 	while( 1 )
// 	{
// 		self waittill( "damage", amount, attacker );
// 		if( attacker==level.player )
// 		{
// 			playVO( "Player must die", "Russia" );
// 			
// 			self StopAnimScripted();
// 			self.ignoreall = false;
// 			alert_snipers();
// 			
// 			flag_set( "PLAYER_MUST_DIE" );
// 			flag_set( "BASE_ALERT" );
// 		}
// 	}
// }

kill_player()
{	
	self endon( "death" );
	
	flag_wait( "PLAYER_MUST_DIE" );
	self StopAnimScripted();
	self.ignoreall = false;
}

kill_player_door_guard()
{	
	self endon( "death" );
	
	level endon( "CLEANUP_BASE_ON_ROOF" );
	level endon( "COMMS_BUILDING_DOOR_OPEN" );
	level endon( "start_door_kick" );
	
	flag_wait( "PLAYER_MUST_DIE" );
	wait( 0.2 );
	self StopAnimScripted();
	self.ignoreall = false;
}

cleanup_onroof()
{
	self endon( "death" );
	flag_wait( "CLEANUP_BASE_ON_ROOF" );
	self Delete();
}

cleanup_afterzipline()
{
	self endon( "death" );
	flag_wait( "CLEANUP_BASE_AFTER_ZIPLINE" );
	self Delete();
}

setup_base_guard()
{
	self endon("death");
	
	//self.old_sightdist = self.maxsightdistsqrd;
	//self.maxsightdistsqrd = 262144;
	
	//self.dofiringdeath = false;
	self.goalradius = 32;
	self.ignoreall = true;
	self.dropweapon = false;
	self.allowdeath = true;
	//self.animname = "dump_guard";
	self contextual_melee( false );
	self.disable_melee = true;
	
	self thread takes_damage();
	self thread kill_player();
	self thread cleanup_onroof();
}

setup_custom_base_guard()
{
	self endon("death");
	
	//self.old_sightdist = self.maxsightdistsqrd;
	//self.maxsightdistsqrd = 262144;
	
	//self.dofiringdeath = false;
	self.goalradius = 32;
	self.ignoreall = true;
	self.dropweapon = false;
	self.allowdeath = true;
	//self.animname = "dump_guard";
	self contextual_melee( false );
	self.disable_melee = true;
	
	//self thread takes_damage();
	self thread takes_damage_door_guard();
	self thread kill_player_door_guard();
	self thread cleanup_onroof();
	
}


base_guard_encounter_woods()
{
	anim_node = get_anim_struct( "8" );
	self.animname = "woods";
	anim_node thread anim_single_aligned( self, "play_it_cool" );
	//wait( 0.1 );
	//println( "PLAYITCOOL = " + self.animname + " = " + self.origin );
	anim_node waittill( "play_it_cool" );
	flag_set( "BASE_ALERT" );
	
}

base_guard_encounter_bowman()
{
	anim_node = get_anim_struct( "8" );
	self.animname = "bowman";
	anim_node thread anim_single_aligned( self, "play_it_cool" );
	//wait( 0.1 );
	//println( "PLAYITCOOL = " + self.animname + " = " + self.origin );
	anim_node waittill( "play_it_cool" );
	flag_set( "BASE_ALERT" );
}

base_guard_encounter_guard1()
{
	anim_node = get_anim_struct( "8" );
	self.animname = "soldier1";
	anim_node thread anim_single_aligned( self, "play_it_cool" );
	//wait( 0.1 );
	//println( "PLAYITCOOL = " + self.animname + " = " + self.origin );
	anim_node waittill( "play_it_cool" );
	flag_set( "BASE_ALERT" );
	self.animname = "generic";
 	self set_run_anim( "run_fast" );
	self setgoalnode( getnode("base_guard_01_ptB", "targetname") );
}

base_guard_encounter_guard2()
{
	anim_node = get_anim_struct( "8" );
	self.animname = "soldier2";
	anim_node thread anim_single_aligned( self, "play_it_cool" );
	//wait( 0.1 );
	//println( "PLAYITCOOL = " + self.animname + " = " + self.origin );
	anim_node waittill( "play_it_cool" );
	flag_set( "BASE_ALERT" );
	self.animname = "generic";
 	self set_run_anim( "run_fast" );
	self setgoalnode( getnode("base_guard_02_ptB", "targetname") );
}

base_guard_encounter()
{
	trigger_gate_guard = getent( "trigger_gate_guard", "targetname" );
	trigger_gate_guard waittill( "trigger" );
	level notify( "base_guard_encounter_started" );
	debug_script( "HIT GUARD TRIGGER" );
	
 	//level.bowman thread base_guard_encounter_bowman();
 	//level.woods thread base_guard_encounter_woods();
 	
 	//Guards for distraction scene
	level.base_guard_distraction_1 = simple_spawn_single( "base_guard_distraction_2", ::setup_base_guard );
	level.base_guard_distraction_2 = simple_spawn_single( "base_guard_distraction_1", ::setup_base_guard );
	
 	level.base_guard_distraction_1 thread base_guard_encounter_guard1();
 	level.base_guard_distraction_2 thread base_guard_encounter_guard2();
 	
 	level.woods thread playVO_proper( "becool" );
 	
	
	
	/*
	//Play it cool
	//spetz2 ends on Run Gun Down pose for AI run, spetz1 disappears out of sight
	//node anims are attached to is the one around viewpos (704 -660 309) at the bend in the road			"8"
	level.scr_anim["woods"]["play_it_cool"]				= %ch_flash_ev04_play_it_cool_woods;
	level.scr_anim["bowman"]["play_it_cool"]			= %ch_flash_ev04_play_it_cool_bowman;
	level.scr_anim["soldier1"]["play_it_cool"]			= %ch_flash_ev04_play_it_cool_spetz1;
	level.scr_anim["soldier2"]["play_it_cool"]			= %ch_flash_ev04_play_it_cool_spetz2;
	*/
	
	
	
 	//level.base_guard_01.animname = "generic";
 	//level.base_guard_01 set_run_anim( "patrol_walk" );
 	//level.base_guard_01.disablearrivals = true;
 	//level.base_guard_01.disableexits = true;
 		
 	//level.base_guard_02.animname = "generic";
 	//level.base_guard_02 set_run_anim( "patrol_walk" );
 	//level.base_guard_02.disablearrivals = true;
 	//level.base_guard_02.disableexits = true;
	
	//level.base_guard_01 setgoalnode( getnode("base_guard_01_ptA", "targetname") );
	//level.base_guard_02 setgoalnode( getnode("base_guard_02_ptA", "targetname") );
	
	//playVO( "papers please.......", "Guard1" );
	
	//level.base_guard_02 waittill("goal");
	
	//wait( 1.0 );
	//flag_set( "BASE_ALERT" );
	
	//Kevin adding alarm
	//level thread maps\flashpoint_amb::base_alarm(10);
	//playVO( "BASE ALERT.....", "Guard2" );
	//wait( 1.0 );
	
	flag_wait( "BASE_ALERT" );
	level thread maps\flashpoint_amb::base_alarm(10);
	thread base_helicopters();
	
 	//level.base_guard_01.animname = "generic";
 	//level.base_guard_01 set_run_anim( "run_fast" );
 	//level.base_guard_01.disablearrivals = false;
 	//level.base_guard_01.disableexits = false;
 		
 	//level.base_guard_02.animname = "generic";
 	//level.base_guard_02 set_run_anim( "run_fast" );
 	//level.base_guard_02.disablearrivals = false;
 	//level.base_guard_02.disableexits = false;
	
	
	//level.base_guard_01 setgoalnode( getnode("base_guard_01_ptB", "targetname") );
	//level.base_guard_02 setgoalnode( getnode("base_guard_02_ptB", "targetname") );
}

base_truck_04()
{
	//Truck 04
	truck_start_node_04 = GetVehicleNode( "base_truck_04_start", "targetname" );
	base_truck_04 = SpawnVehicle( "t5_veh_gaz66", "base_truck_04", "truck_gaz66_troops", truck_start_node_04.origin, (0,0,0) );
	base_truck_04 thread cleanup_afterzipline();
	base_truck_04 maps\_vehicle::lights_on();
	base_truck_04 thread maps\flashpoint_e1::check_play_vehicle_rumble( 800.0 );
	maps\_vehicle::vehicle_init( base_truck_04 );
	base_truck_04 thread spawn_and_attach_truck_driver();

	// getonpath will attach us to the path and allow us to get script_noteworthy notifies from nodes
	base_truck_04 thread maps\_vehicle::getonpath( truck_start_node_04 );
	
	trigger_base_truck_04 = getent( "trigger_base_truck_04", "targetname" );
	trigger_base_truck_04 waittill( "trigger" );
	debug_script( "HIT TRUCK04 TRIGGER" );
	
	//base_truck_04 thread go_path( truck_start_node_04 );
	
	// gopath starts us on the path
	base_truck_04 thread maps\_vehicle::gopath();
}

cleanup_when_in_comms()
{
	self endon( "death" );
	level waittill( "COMMS_DOOR_SHUT" );
	self Delete();

	uaz_gate_dude = GetEnt( "uaz_gate_dude", "script_noteworthy" );
	if( IsDefined(uaz_gate_dude) && IsAlive( uaz_gate_dude) )
	{
		uaz_gate_dude Delete();
	}
}

base_helicopters()
{
	base_heli_01_start = GetVehicleNode( "base_heli_01_start", "targetname" );
	base_heli_02_start = GetVehicleNode( "base_heli_02_start", "targetname" );
	base_heli_03_start = GetVehicleNode( "base_heli_03_start", "targetname" );
	base_heli_01 = SpawnVehicle( "t5_veh_helo_mi8_woodland", "base_heli_01", "heli_hip", base_heli_01_start.origin, (0,0,0) );
	base_heli_02 = SpawnVehicle( "t5_veh_helo_mi8_woodland", "base_heli_02", "heli_hip", base_heli_02_start.origin, (0,0,0) );
	base_heli_03 = SpawnVehicle( "t5_veh_helo_mi8_woodland", "base_heli_03", "heli_hip", base_heli_03_start.origin, (0,0,0) );
	level.base_heli_onpad = SpawnVehicle( "t5_veh_helo_mi8_woodland", "base_heli_onpad", "heli_hip", (658.0, 1390.2, 561.0), (0, 247.8, 0) );
	base_heli_01 thread maps\flashpoint_e1::check_play_vehicle_rumble();
	base_heli_02 thread maps\flashpoint_e1::check_play_vehicle_rumble();
	base_heli_03 thread maps\flashpoint_e1::check_play_vehicle_rumble();
	base_heli_01 thread cleanup_afterzipline();
	base_heli_02 thread cleanup_afterzipline();
	base_heli_03 thread cleanup_afterzipline();
	level.base_heli_onpad thread cleanup_when_in_comms();
	maps\_vehicle::vehicle_init( base_heli_01 );
	maps\_vehicle::vehicle_init( base_heli_02 );
	maps\_vehicle::vehicle_init( base_heli_03 );
	maps\_vehicle::vehicle_init( level.base_heli_onpad );
	base_heli_01.health = 99999;
	base_heli_01.drivepath = 1;
	base_heli_02.health = 99999;
	base_heli_02.drivepath = 1;
	base_heli_03.health = 99999;
	base_heli_03.drivepath = 1;
	base_heli_01 thread go_path( base_heli_01_start );
	wait( 1.0 );
	base_heli_02 thread go_path( base_heli_02_start );
	wait( 4.3 );
	base_heli_03 thread go_path( base_heli_03_start );
	
}

base_jeeps()
{
	wait( 5 );
	
	//jeeps
//	base_jeep_01_start = GetVehicleNode( "base_jeep_01_start", "targetname" );
	base_jeep_02_start = GetVehicleNode( "base_jeep_02_start", "targetname" );
//	base_jeep_01 = SpawnVehicle( "vehicle_uaz_hardtop", "base_jeep_01", "jeep_uaz_closetop", base_jeep_01_start.origin, (0,0,0) );
	////base_jeep_02 = SpawnVehicle( "vehicle_uaz_hardtop", "base_jeep_02", "jeep_uaz_closetop", base_jeep_02_start.origin, (0,0,0) );
	
	base_jeep_02 = maps\_vehicle::spawn_vehicles_from_targetname( "base_jeep_02" )[0];
	//base_jeep_02 thread maps\_vehicle::getonpath( base_jeep_02_start );
	
	ai_for_jeep = base_jeep_02 vehicle_get_riders();
	for( i=0; i<ai_for_jeep.size; i++ )
	{
		if( isdefined(ai_for_jeep[i]) && isalive(ai_for_jeep[i]) )
		{
			ai_for_jeep[i].ignoreall = true;
		}
	}
	
	
	base_jeep_02 maps\_vehicle::lights_on();
	base_jeep_02 thread maps\flashpoint_e1::check_play_vehicle_rumble( 800.0 );
//	base_jeep_01 thread cleanup_afterzipline();
	base_jeep_02 thread cleanup_afterzipline();
//	maps\_vehicle::vehicle_init( base_jeep_01 );
	//maps\_vehicle::vehicle_init( base_jeep_02 );
//	base_jeep_01 thread spawn_and_attach_uaz_driver();
//	base_jeep_02 thread spawn_and_attach_uaz_driver();

	
	// getonpath will attach us to the path and allow us to get script_noteworthy notifies from nodes
//	base_jeep_01 thread maps\_vehicle::getonpath( base_jeep_01_start );
	base_jeep_02 thread maps\_vehicle::getonpath( base_jeep_02_start );
	
	level waittill( "base_helis_started" );
	
	wait( 3 );

//	base_jeep_01 thread maps\_vehicle::gopath();
//	wait( 1.0 );
	base_jeep_02 thread maps\_vehicle::gopath();
}

close_front_gates()
{
	gates = [];
	gates[0] = GetEnt("compound_gate1L", "targetname");
	gates[1] = GetEnt("compound_gate1r", "targetname");
	
	gate_structs = [];
	gate_structs[0] = getstruct("struct_gate_front_1l", "targetname");
	gate_structs[1] = getstruct("struct_gate_front_1r", "targetname");
	
	close_front_gate_trig = getent( "close_front_gate", "targetname" );
	close_front_gate_trig waittill( "trigger" );
	
	front_col_left = getent( "front_col_left", "targetname" );
	front_col_left Delete();
	front_col_right = getent( "front_col_right", "targetname" );
	front_col_right Delete();
	
 	for( i = 0; i < gates.size; i++ )
 	{
 		gates[i] RotateTo(gate_structs[i].angles, 2, 0.1, 0.5 );
 	}
	
	//gates[1] RotateTo(gate_structs[1].angles, 2, 0.1, 0.5 );
	
	//struct_gate_front_1r_blocker
	struct_gate_front_1r_blocker = getent( "struct_gate_front_1r_blocker", "targetname" );
	struct_gate_front_1r_blocker Solid();
	struct_gate_front_1l_blocker = getent( "struct_gate_front_1l_blocker", "targetname" );
	struct_gate_front_1l_blocker Solid();
	
}


base_helicopters_in_distance()
{
	//Wait for the player to hit the  trigger
	trigger_base_distant_helis = getent( "trigger_base_distant_helis", "targetname" );
	trigger_base_distant_helis waittill( "trigger" );
	level notify( "base_helis_started" );
	
	//thread base_jeeps();
	level thread base_migs();
	//level thread close_front_gates();


	base_heli_04_start = GetVehicleNode( "base_heli_04_start", "targetname" );
	base_heli_05_start = GetVehicleNode( "base_heli_05_start", "targetname" );
	base_heli_06_start = GetVehicleNode( "base_heli_06_start", "targetname" );
	base_heli_07_start = GetVehicleNode( "base_heli_07_start", "targetname" );
	base_heli_04 = SpawnVehicle( "t5_veh_helo_mi8_woodland", "base_heli_04", "heli_hip", base_heli_04_start.origin, (0,0,0) );
	base_heli_05 = SpawnVehicle( "t5_veh_helo_mi8_woodland", "base_heli_05", "heli_hip", base_heli_05_start.origin, (0,0,0) );
	base_heli_06 = SpawnVehicle( "t5_veh_helo_mi8_woodland", "base_heli_06", "heli_hip", base_heli_06_start.origin, (0,0,0) );
	base_heli_07 = SpawnVehicle( "t5_veh_helo_mi8_woodland", "base_heli_07", "heli_hip", base_heli_07_start.origin, (0,0,0) );
	base_heli_04 thread cleanup_afterzipline();
	base_heli_05 thread cleanup_afterzipline();
	base_heli_06 thread cleanup_afterzipline();
	base_heli_07 thread cleanup_afterzipline();
	maps\_vehicle::vehicle_init( base_heli_04 );
	maps\_vehicle::vehicle_init( base_heli_05 );
	maps\_vehicle::vehicle_init( base_heli_06 );
	maps\_vehicle::vehicle_init( base_heli_07 );
	base_heli_04.health = 99999;
	base_heli_05.health = 99999;
	base_heli_06.health = 99999;
	base_heli_07.health = 99999;
	base_heli_04.drivepath = 1;
	base_heli_05.drivepath = 1;
	base_heli_06.drivepath = 1;
	base_heli_07.drivepath = 1;
	
	base_heli_04 thread go_path( base_heli_04_start );
	base_heli_05 thread go_path( base_heli_05_start );
	base_heli_06 thread go_path( base_heli_06_start );
	base_heli_07 thread go_path( base_heli_07_start );	
}
	
base_migs()
{
	//Wait for the player to hit the  trigger
	trigger_base_migs = getent( "trigger_base_migs", "targetname" );
	trigger_base_migs waittill( "trigger" );
	level notify( "base_migs_started" );

	//Mig flyover scene
	base_mig_01_start = GetVehicleNode( "base_mig_01_start", "targetname" );
	base_mig_02_start = GetVehicleNode( "base_mig_02_start", "targetname" );
	base_mig_01 = SpawnVehicle( "t5_veh_air_mig_21_ussr_flying", "base_mig_01", "plane_mig21_lowres", base_mig_01_start.origin, (0,0,0) );
	base_mig_02 = SpawnVehicle( "t5_veh_air_mig_21_ussr_flying", "base_mig_02", "plane_mig21_lowres", base_mig_02_start.origin, (0,0,0) );
	//kevin adding sound calls
	base_mig_01 thread maps\flashpoint_amb::mig_fake_audio2();
	base_mig_01 thread cleanup_afterzipline();
	base_mig_02 thread cleanup_afterzipline();
	maps\_vehicle::vehicle_init( base_mig_01 );
	maps\_vehicle::vehicle_init( base_mig_02 );
	base_mig_01 thread go_path( base_mig_01_start );
	base_mig_02 thread go_path( base_mig_02_start );
	
	base_mig_01 thread playPlaneFx();
	base_mig_02 thread playPlaneFx();
}


base_guard_anim_reach_then_loop( _animname, _anim, _animnode )
{
	self endon( "death" );
	anim_node = get_anim_struct( _animnode );
	self.animname = _animname;
 	anim_node anim_reach_aligned( self, _anim );
 	anim_node thread anim_loop_aligned( self, _anim );
}

base_guard_anim_single_then_loop( _animname, _anim, _anim_idle, _animnode )
{
	self endon( "death" );
	anim_node = get_anim_struct( _animnode );
	self.animname = _animname;
	
	anim_node thread anim_single_aligned( self, _anim );
 	anim_node waittill( _anim );
 	
 	//anim_node anim_reach_aligned( self, _anim_idle );
 	anim_node thread anim_loop_aligned( self, _anim_idle );
}

base_guard_anim_reach_then_playonce( _animname, _anim, _animnode, exitnode_str )
{
	self endon( "death" );
	anim_node = get_anim_struct( _animnode );
	self.animname = _animname;
 	anim_node anim_reach_aligned( self, _anim );
 	anim_node thread anim_single_aligned( self, _anim );
 	anim_node waittill( _anim );
 	
 	self thread got_to_exit( exitnode_str );
}

base_guard_anim_playonce( _animname, _anim, _animnode, exitnode_str )
{
	self endon( "death" );
	anim_node = get_anim_struct( _animnode );
	self.animname = _animname;
 	anim_node thread anim_single_aligned( self, _anim );
 	anim_node waittill( _anim );
 	
 	self thread got_to_exit( exitnode_str );
}

base_guard_anim( _animname, _anim, _animnode, exitnode_str )
{
	self endon( "death" );
	anim_node = get_anim_struct( _animnode );
	self.animname = _animname;
 	anim_node thread anim_loop_aligned( self, _anim );
 	
 	if( isdefined(exitnode_str) )
 	{
 		self thread got_to_exit( exitnode_str );
 	}
}

base_guard_anim_firstframe( _animname, _anim, _animnode )
{
	self endon( "death" );
	anim_node = get_anim_struct( _animnode );
	self.animname = _animname;
 	anim_node thread anim_first_frame( self, _anim );
}

got_to_exit_on_alert( exitnode_str )
{
	self endon( "death" );
	
	flag_wait( "BASE_ALERT" );
	exitnode = getnode( exitnode_str, "targetname" );
	self StopAnimScripted();
	self clear_run_anim();
	self setgoalnode( exitnode );
	self waittill( "goal" );
	self Delete();
}

got_to_exit( exitnode_str )
{
	self endon( "death" );

	exitnode = getnode( exitnode_str, "targetname" );
	self StopAnimScripted();
	self clear_run_anim();
	self setgoalnode( exitnode );
	self waittill( "goal" );
	self Delete();
}

/*
ai_exit_node_1
...
ai_exit_node_7
*/

turn_and_run()
{
	level waittill( "base_guard_encounter_started" );
	
	//level.base_guard_alerted_turn_1 = simple_spawn_single( "base_guard_alerted_turn_1", ::setup_base_guard );
	//level.base_guard_alerted_turn_2 = simple_spawn_single( "base_guard_alerted_turn_2", ::setup_base_guard );
	level.base_guard_alerted_turn_1 thread base_guard_anim_reach_then_playonce( "soldier", "base_spetzalert1a", "8", "ai_exit_node_1" );//bend
 	level.base_guard_alerted_turn_2 thread base_guard_anim_reach_then_playonce( "soldier", "base_spetzalert1b", "8", "ai_exit_node_2" );//bend
}

out_truck_and_run()
{
	level waittill( "base_guard_encounter_started" );
	
	level.base_guard_jeep_getout_1 thread base_guard_anim_playonce( "soldier", "base_spetz_truck1a", "8b", "ai_exit_node_3" );
	level.base_guard_jeep_getout_2 thread base_guard_anim_playonce( "soldier", "base_spetz_truck1b", "8b", "ai_exit_node_4" );
}

run_on_right()
{
	//level waittill( "base_guard_encounter_started" );
	level waittill( "base_helis_started" );
	//level waittill( "base_migs_started" );
	
	level.base_guard_run_rightside_1 thread base_guard_anim_reach_then_playonce( "soldier", "base_spetz2a", "8b", "ai_exit_node_5" );
	level.base_guard_run_rightside_2 thread base_guard_anim_reach_then_playonce( "soldier", "base_spetz2b", "8b", "ai_exit_node_6" );
}

run_on_left()
{
	//level waittill( "base_guard_encounter_started" );
	level waittill( "base_helis_started" );
	//level waittill( "base_migs_started" );
	
	level.base_guard_redirector_leftside_1 thread base_guard_anim_reach_then_playonce( "soldier", "base_spetz1a", "8b", "ai_exit_node_6" );
	level.base_guard_redirector_leftside_2 thread base_guard_anim_reach_then_playonce( "soldier", "base_spetz1b", "8b", "ai_exit_node_7" );
}

delete_at_end_of_patrol()
{	
	self endon( "death" );
	self waittill( "reached_path_end" );
	self Delete();
}

guys_exiting_base_doors()
{
	level.base_guard_jeep_follow_1.animname = "generic";
 	level.base_guard_jeep_follow_2.animname = "generic";
 	//level.base_guard_jeep_follow_3.animname = "generic";
 	//level.base_guard_jeep_follow_4.animname = "generic";
 	level.base_guard_jeep_follow_5.animname = "generic";
 	level.base_guard_jeep_follow_6.animname = "generic";
 	
 	level.base_guard_jeep_follow_1.patrol_walk_anim = "run_fast";
 	level.base_guard_jeep_follow_2.patrol_walk_anim = "run_fast";
 	//level.base_guard_jeep_follow_3.patrol_walk_anim = "run_fast";
 	//level.base_guard_jeep_follow_4.patrol_walk_anim = "run_fast";
 	level.base_guard_jeep_follow_5.patrol_walk_anim = "run_fast";
 	level.base_guard_jeep_follow_6.patrol_walk_anim = "run_fast";
 	
	level.base_guard_jeep_follow_1 thread delete_at_end_of_patrol();
	level.base_guard_jeep_follow_2 thread delete_at_end_of_patrol();
	//level.base_guard_jeep_follow_3 thread delete_at_end_of_patrol();
	//level.base_guard_jeep_follow_4 thread delete_at_end_of_patrol();
	level.base_guard_jeep_follow_5 thread delete_at_end_of_patrol();
	level.base_guard_jeep_follow_6 thread delete_at_end_of_patrol();
 
	wait( 0.5 );
	level.base_guard_jeep_follow_1 thread maps\_patrol::patrol( "right_exit_base_path_1" );
	level.base_guard_jeep_follow_2 thread maps\_patrol::patrol( "left_exit_base_path_1" );
	wait( 0.5 );
	//level.base_guard_jeep_follow_3 thread maps\_patrol::patrol( "right_exit_base_path_2" );
	//level.base_guard_jeep_follow_4 thread maps\_patrol::patrol( "left_exit_base_path_2" );
	wait( 0.5 );
	level.base_guard_jeep_follow_5 thread maps\_patrol::patrol( "right_exit_base_path_3" );
	level.base_guard_jeep_follow_6 thread maps\_patrol::patrol( "left_exit_base_path_3" );
}

guys_b_exiting_base_doors()
{
	level waittill( "base_helis_started" );
	
	level.base_guard_jeep_follow_1b.animname = "generic";
 	level.base_guard_jeep_follow_2b.animname = "generic";
 	//level.base_guard_jeep_follow_3b.animname = "generic";
 	//level.base_guard_jeep_follow_4b.animname = "generic";
 	level.base_guard_jeep_follow_5b.animname = "generic";
 	level.base_guard_jeep_follow_6b.animname = "generic";
 	
 	level.base_guard_jeep_follow_1b.patrol_walk_anim = "run_fast";
 	level.base_guard_jeep_follow_2b.patrol_walk_anim = "run_fast";
 //	level.base_guard_jeep_follow_3b.patrol_walk_anim = "run_fast";
 //	level.base_guard_jeep_follow_4b.patrol_walk_anim = "run_fast";
 	level.base_guard_jeep_follow_5b.patrol_walk_anim = "run_fast";
 	level.base_guard_jeep_follow_6b.patrol_walk_anim = "run_fast";
 	
 	level.base_guard_jeep_follow_1b thread delete_at_end_of_patrol();
	level.base_guard_jeep_follow_2b thread delete_at_end_of_patrol();
	//level.base_guard_jeep_follow_3b thread delete_at_end_of_patrol();
	//level.base_guard_jeep_follow_4b thread delete_at_end_of_patrol();
	level.base_guard_jeep_follow_5b thread delete_at_end_of_patrol();
	level.base_guard_jeep_follow_6b thread delete_at_end_of_patrol();
 
	wait( 4.0 );
	level.base_guard_jeep_follow_1b thread maps\_patrol::patrol( "right_exit_base_path_1b" );
	level.base_guard_jeep_follow_2b thread maps\_patrol::patrol( "left_exit_base_path_1b" );
	wait( 0.5 );
	//level.base_guard_jeep_follow_3b thread maps\_patrol::patrol( "right_exit_base_path_2b" );
	//level.base_guard_jeep_follow_4b thread maps\_patrol::patrol( "left_exit_base_path_2b" );
	wait( 0.5 );
	level.base_guard_jeep_follow_5b thread maps\_patrol::patrol( "right_exit_base_path_3b" );
	level.base_guard_jeep_follow_6b thread maps\_patrol::patrol( "left_exit_base_path_3b" );
}

binoc_snipers_basewalk_behavior()
{
	self endon( "death" );
	self endon( "delete" );
	
	self.ignoreall = true;
	self.animname = "generic";
	self set_generic_run_anim( "patrol_walk" );
	
	level waittill("delete_binoc_snipers_basewalk");
	self Delete();
}

snipers_on_roof()
{
	binoc_snipers_basewalk_spawners = GetEntArray("binoc_snipers_basewalk", "targetname" );
	array_thread( binoc_snipers_basewalk_spawners, ::add_spawn_function, ::binoc_snipers_basewalk_behavior );
	
	level waittill("spawn_binoc_snipers_basewalk");
	snipers = simple_spawn( "binoc_snipers_basewalk" );
}

gate_guard_a()
{
	self endon( "death" );
	anim_node = get_anim_struct( "8" );
	self.animname = "soldier";
 	anim_node thread anim_single_aligned( self, "base_start_a" );
 	anim_node waittill( "base_start_idle_a" );
}

gate_guard_b()
{
	self endon( "death" );
	anim_node = get_anim_struct( "8" );
	self.animname = "soldier";
 	anim_node thread anim_single_aligned( self, "base_start_idle_ba" );
 	anim_node waittill( "base_start_idle_b" );
}


spawn_base()
{
	//Base Guards
// 	level.base_guard_01 = simple_spawn_single( "base_guard_01", ::setup_base_guard );
// 	level.base_guard_02 = simple_spawn_single( "base_guard_02", ::setup_base_guard );
	
	//Use a single spawner
// 	spawner = GetEnt( "base_guard_c1", "targetname" );
// 	spawner.count = 20;
// 
// 	
// 	level.base_guard_a01 = simple_spawn_single( "base_guard_a1", ::setup_base_guard );
// 	level.base_guard_a02 = simple_spawn_single( "base_guard_a2", ::setup_base_guard );
// 	level.base_guard_a03 = simple_spawn_single( "base_guard_a3", ::setup_base_guard );
// 	level.base_guard_a04 = simple_spawn_single( "base_guard_a4", ::setup_base_guard );
// 	level.base_guard_a05 = simple_spawn_single( "base_guard_b1", ::setup_base_guard );
// 	level.base_guard_a06 = simple_spawn_single( "base_guard_b2", ::setup_base_guard );
// 	level.base_guard_a07 = simple_spawn_single( "base_guard_b3", ::setup_base_guard );
// 	level.base_guard_a08 = simple_spawn_single( "base_guard_c1", ::setup_base_guard );
// 	level.base_guard_a09 = simple_spawn_single( "base_guard_c2", ::setup_base_guard );
// 	level.base_guard_a10 = simple_spawn_single( "base_guard_c3", ::setup_base_guard );
// 	
// 	level.base_guard_a11 = simple_spawn_single( "base_guard_c1", ::setup_base_guard );
// 	level.base_guard_a12 = simple_spawn_single( "base_guard_c1", ::setup_base_guard );
// 	level.base_guard_a13 = simple_spawn_single( "base_guard_c1", ::setup_base_guard );
	
	
// 	//Guards for distraction scene
// 	level.base_guard_distraction_1 = simple_spawn_single( "base_guard_distraction_2", ::setup_base_guard );
// 	level.base_guard_distraction_2 = simple_spawn_single( "base_guard_distraction_1", ::setup_base_guard );
	
	//Guards idle at gate
	level.base_guard_idle_gate_1 = simple_spawn_single( "base_guard_idle_gate_1", ::setup_base_guard );
	level.base_guard_idle_gate_2 = simple_spawn_single( "base_guard_idle_gate_2", ::setup_base_guard );
	level.base_guard_idle_gate_3 = simple_spawn_single( "base_guard_idle_gate_3", ::setup_base_guard );
	level.base_guard_idle_gate_1 set_generic_run_anim( "patrol_walk" );
	level.base_guard_idle_gate_2 set_generic_run_anim( "patrol_walk" );
	level.base_guard_idle_gate_3 set_generic_run_anim( "patrol_walk" );
	level.base_guard_idle_gate_1.disableTurns = true;
	level.base_guard_idle_gate_2.disableTurns = true;
	level.base_guard_idle_gate_3.disableTurns = true;

	level.base_guard_idle_gate_1 thread base_guard_anim_single_then_loop( "soldier", "base_start_a", "base_start_idle_a", "8" );
	level.base_guard_idle_gate_2 thread base_guard_anim_single_then_loop( "soldier", "base_start_b", "base_start_idle_b", "8" );
	level.base_guard_idle_gate_3 thread base_guard_anim_single_then_loop( "soldier", "base_start_c", "base_start_idle_c", "8" );
	//level.base_guard_idle_gate_3 thread base_guard_anim_reach_then_loop( "soldier", "base_spetz_idle3", "8" );//bend
	
	level.base_guard_idle_gate_1 thread got_to_exit_on_alert( "gate_exitnode" );//bend
	level.base_guard_idle_gate_2 thread got_to_exit_on_alert( "gate_exitnode" );//bend
	level.base_guard_idle_gate_3 thread got_to_exit_on_alert( "gate_exitnode" );//bend
	
	wait( 0.1 );
	
	//Guards for comms door - the ones thatn run round the corner and get killed (3 to 1 )
	level.base_guard_comms_door_1 = simple_spawn_single( "base_guard_comms_door_1", ::setup_custom_base_guard );
	level.base_guard_comms_door_2 = simple_spawn_single( "base_guard_comms_door_2", ::setup_custom_base_guard );
	//level.base_guard_comms_door_1 setgoalpos( (-1097.95, 69.9563, 351.726) );
	//level.base_guard_comms_door_2 setgoalpos( (-1131.72, 37.4709, 350.814) );
	
// 	level.woods thread distraction_anim_woods();
// 	level.brooks thread distraction_anim_brooks();
// 	level.bowman thread distraction_anim_bowman();
	level.base_guard_comms_door_1.animname = "guard1";
	level.base_guard_comms_door_2.animname = "guard2";
	level.base_guard_comms_door_1.dontalert = true;
	level.base_guard_comms_door_2.dontalert = true;
	level.base_guard_comms_door_1 thread distraction_anim_guard1();
	level.base_guard_comms_door_2 thread distraction_anim_guard2();
	level.base_guard_comms_door_1.allowdeath = true;
	level.base_guard_comms_door_2.allowdeath = true;
	
	wait( 0.1 );
	
	//Guard idle at crate
	level.base_guard_crate_idle = simple_spawn_single( "base_guard_crate_idle", ::setup_base_guard );
	level.base_guard_crate_idle thread base_guard_anim( "soldier", "base_spetz_crate", "8b" );
	
	wait( 0.1 );
	
	//Guards jumping out jeep
	level.base_guard_jeep_getout_1 = simple_spawn_single( "base_guard_jeep_getout_1", ::setup_base_guard );
	level.base_guard_jeep_getout_2 = simple_spawn_single( "base_guard_jeep_getout_2", ::setup_base_guard );
	//level.base_guard_jeep_getout_1 thread base_guard_anim_firstframe( "soldier", "base_spetz_truck1a", "8b" );
	//level.base_guard_jeep_getout_2 thread base_guard_anim_firstframe( "soldier", "base_spetz_truck1b", "8b" );
	
	wait( 0.1 );
	
	//Guards who get alerted and turn and run
	level.base_guard_alerted_turn_1 = simple_spawn_single( "base_guard_alerted_turn_1", ::setup_base_guard );
	level.base_guard_alerted_turn_2 = simple_spawn_single( "base_guard_alerted_turn_2", ::setup_base_guard );
	//level.base_guard_alerted_turn_1 thread base_guard_anim_reach_then_playonce( "soldier", "base_spetzalert1a", "8" );//bend
 	//level.base_guard_alerted_turn_2 thread base_guard_anim_reach_then_playonce( "soldier", "base_spetzalert1b", "8" );//bend

	wait( 0.1 );

	//Guards running right of the road - from behind the jeeps
	level.base_guard_run_rightside_1 = simple_spawn_single( "base_guard_run_rightside_1", ::setup_base_guard );
	level.base_guard_run_rightside_2 = simple_spawn_single( "base_guard_run_rightside_2", ::setup_base_guard );
	//level.base_guard_run_rightside_1 thread base_guard_anim( "soldier", "base_spetz2a", "8b" );
	//level.base_guard_run_rightside_2 thread base_guard_anim( "soldier", "base_spetz2b", "8b" );
	
	wait( 0.1 );
	
	//Guards to left of road - one redirects the other
	level.base_guard_redirector_leftside_1 = simple_spawn_single( "base_guard_redirector_leftside_1", ::setup_base_guard );
	level.base_guard_redirector_leftside_2 = simple_spawn_single( "base_guard_redirector_leftside_2", ::setup_base_guard );
	//level.base_guard_redirector_leftside_1 thread base_guard_anim( "soldier", "base_spetz1a", "8b" );
	//level.base_guard_redirector_leftside_2 thread base_guard_anim( "soldier", "base_spetz1b", "8b" );
	
	wait( 0.1 );
	
	//Guards running to left of comms building
//	level.base_guard_run_left_comm_1 = simple_spawn_single( "base_guard_run_left_comm_1", ::setup_base_guard );
//	level.base_guard_run_left_comm_2 = simple_spawn_single( "base_guard_run_left_comm_2", ::setup_base_guard );
//	level.base_guard_run_left_comm_3 = simple_spawn_single( "base_guard_run_left_comm_3", ::setup_base_guard );
//	level.base_guard_run_left_comm_1 thread base_guard_anim( "soldier", "base_spetz3a", "9" );
//	level.base_guard_run_left_comm_2 thread base_guard_anim( "soldier", "base_spetz3b", "9" );
//	level.base_guard_run_left_comm_3 thread base_guard_anim( "soldier", "base_spetz3c", "9" );
	
	wait( 0.1 );
		
	//Guard standing idle to left just before comms building
	level.base_guard_idle_left_comm = simple_spawn_single( "base_guard_idle_left_comm", ::setup_base_guard );
	level.base_guard_idle_left_comm thread base_guard_anim( "soldier", "base_spetz_alert1", "8b" );//middle of 2 trucks
	
	wait( 0.1 );
	
	//Guards following the trucks
	level.base_guard_jeep_follow_1 = simple_spawn_single( "base_guard_jeep_follow_1", ::setup_base_guard );
	level.base_guard_jeep_follow_2 = simple_spawn_single( "base_guard_jeep_follow_2", ::setup_base_guard );
	//level.base_guard_jeep_follow_3 = simple_spawn_single( "base_guard_jeep_follow_3", ::setup_base_guard );
	//level.base_guard_jeep_follow_4 = simple_spawn_single( "base_guard_jeep_follow_4", ::setup_base_guard );
	level.base_guard_jeep_follow_5 = simple_spawn_single( "base_guard_jeep_follow_5", ::setup_base_guard );
	level.base_guard_jeep_follow_6 = simple_spawn_single( "base_guard_jeep_follow_6", ::setup_base_guard );
	
	level.base_guard_jeep_follow_1 contextual_melee( false );
	level.base_guard_jeep_follow_2 contextual_melee( false );
	level.base_guard_jeep_follow_5 contextual_melee( false );
	level.base_guard_jeep_follow_6 contextual_melee( false );
	
	level.base_guard_jeep_follow_1 super_pusher_on();
	level.base_guard_jeep_follow_2 super_pusher_on();
	level.base_guard_jeep_follow_5 super_pusher_on();
	level.base_guard_jeep_follow_6 super_pusher_on();
	
	
	//Guards following the trucks
/*	level.base_guard_jeep_follow_1b = simple_spawn_single( "base_guard_jeep_follow_1b", ::setup_base_guard );
	level.base_guard_jeep_follow_2b = simple_spawn_single( "base_guard_jeep_follow_2b", ::setup_base_guard );
	//level.base_guard_jeep_follow_3b = simple_spawn_single( "base_guard_jeep_follow_3b", ::setup_base_guard );
	//level.base_guard_jeep_follow_4b = simple_spawn_single( "base_guard_jeep_follow_4b", ::setup_base_guard );
	level.base_guard_jeep_follow_5b = simple_spawn_single( "base_guard_jeep_follow_5b", ::setup_base_guard );
	level.base_guard_jeep_follow_6b = simple_spawn_single( "base_guard_jeep_follow_6b", ::setup_base_guard );*/

	level thread base_jeeps();
	level thread snipers_on_roof();
	level thread guys_exiting_base_doors();
//	level thread guys_b_exiting_base_doors();
	level thread turn_and_run();
	level thread run_on_left();
	level thread run_on_right();
	level thread out_truck_and_run();
	level thread base_guard_encounter();
	level thread base_truck_04();
	level thread base_helicopters_in_distance();

	//Trucks
	truck_start_node_01 = GetVehicleNode( "base_truck_01_start", "targetname" );
	truck_start_node_03 = GetVehicleNode( "base_truck_03_start", "targetname" );
	base_truck_01 = SpawnVehicle( "t5_veh_gaz66", "base_truck_01", "truck_gaz66_troops", truck_start_node_01.origin, (0,0,0) );
	base_truck_02 = SpawnVehicle( "t5_veh_gaz66", "base_truck_02", "truck_gaz66_tanker", truck_start_node_01.origin, (0,0,0) );
	base_truck_01 maps\_vehicle::lights_on();
	base_truck_02 maps\_vehicle::lights_on();
	//base_truck_03 = SpawnVehicle( "t5_veh_gaz66", "base_truck_03", "truck_gaz66_troops", truck_start_node_03.origin, (0,0,0) );
	base_truck_01 thread maps\flashpoint_e1::check_play_vehicle_rumble( 800.0 );
	base_truck_02 thread maps\flashpoint_e1::check_play_vehicle_rumble( 800.0 );
	base_truck_01 thread cleanup_afterzipline();
	base_truck_02 thread cleanup_afterzipline();
	//base_truck_03 thread cleanup_afterzipline();
	maps\_vehicle::vehicle_init( base_truck_01 );
	maps\_vehicle::vehicle_init( base_truck_02 );
	//maps\_vehicle::vehicle_init( base_truck_03 );
	base_truck_01 thread spawn_and_attach_truck_driver();
	base_truck_02 thread spawn_and_attach_truck_driver();
	//base_truck_03 thread spawn_and_attach_truck_driver();
	base_truck_01 thread go_path( truck_start_node_01 );
	wait( 2.3 );
	base_truck_02 thread go_path( truck_start_node_01 );
	wait( 2.3 );
	//base_truck_03 thread go_path( truck_start_node_03 );
	
}

walkThroughDialog()
{
    //Base walkthough
    /*
    //Base walkthough
    level.scr_sound["woods"]["letsmove"] = "vox_fla1_s03_085A_wood_m"; //Alright... Let's move.
    
    
    level.scr_sound["woods"]["becool"] = "vox_fla1_s04_086A_wood_m"; //Be cool.... Don't draw attention.
    level.scr_sound["bowman"]["found_bodies"] = "vox_fla1_s04_088A_bowm_m"; //We may not have the luxury - I think they may have found the bodies.
    level.scr_sound["bowman"]["found_bodies2"] = "vox_fla1_s04_329A_bowm"; //I think they may have found the bodies.
    level.scr_sound["woods"]["dowhattheydo"] = "vox_fla1_s04_089A_wood_m"; //We're good. Just do what they do.
    level.scr_sound["mason"]["commsupahead"] = "vox_fla1_s04_090A_maso"; //Comms building up ahead.
    level.scr_sound["bowman"]["snipersonroof"] = "vox_fla1_s04_091A_bowm"; //Snipers taking positions on the roof.
    level.scr_sound["bowman"]["menoutfront"] = "vox_fla1_s04_092A_bowm"; //Couple of men out front.
    */
    
    level.woods thread playVO_proper( "letsmove" );
    thread base_walla_audio();
}


dialog_for_base_alert()
{
	level endon( "PLAYER_MUST_DIE" );
	
	
	level waittill( "playitcool_dialog" );
	
	//TUEY SET music state to BASE_WALK
	setmusicstate ("BASE_ALERT");
	
	axis = GetAIArray( "axis" );	
	array_func( axis, ::turn_off_sticky_aim );

	level thread switch_music_wait ("BASE_UNDERSCORE", 3);
		
	wait( 5.0 );
	level.bowman thread playVO_proper( "found_bodies2" );
	wait( 2.0 );
	level.woods thread playVO_proper( "dowhattheydo" );
	wait( 3.0 );
	level notify( "do_what_they_do" );
	
	wait( 1.0 );
	level.player thread playVO_proper( "commsupahead" );
	
	wait( 3.0 );
	level.bowman thread playVO_proper( "snipersonroof" );
	
	wait( 4.0 );
	level.bowman thread playVO_proper( "menoutfront" );
	wait( 2.0 );
	level.woods thread playVO_proper( "outtheway" );
	//level.bowman thread playVO_proper( "menoutfront" );
}

turn_off_sticky_aim()
{
	self endon( "death" );

	self DisableAimAssist();
}

turn_on_sticky_aim()
{
	self endon( "death" );

	self EnableAimAssist();
}

//kevin adding walla vo function
base_walla_audio()
{
	//iprintlnbold( "WAAAALLAAAA" );
	wait 10;
	ent = spawn( "script_origin" , (1144, -1688, 384) );
	ent playsound( "vox_fla1_s99_174A_rcv2" , "sound_done" );
	ent waittill( "sound_done" );
	ent playsound( "vox_fla1_s99_175A_ren1" , "sound_done" );
	ent waittill( "sound_done" );
	ent playsound( "vox_fla1_s99_176A_ren2" , "sound_done" );
	ent waittill( "sound_done" );
	ent playsound( "vox_fla1_s99_177A_ren3" , "sound_done" );
	ent waittill( "sound_done" );
	ent playsound( "vox_fla1_s99_178A_ren1" , "sound_done" );
	ent waittill( "sound_done" );
	ent playsound( "vox_fla1_s99_179A_ren3" , "sound_done" );
	ent waittill( "sound_done" );
	//ent playsound( "vox_fla1_s99_186A_rus1" , "sound_done" );
	//ent waittill( "sound_done" );
	ent delete();
	
}
event4_WalkingRail()
{
/*
 NOTE: Player is now on a walking rail (e.g. No Russian), walking at ¾ speed
 Player’s gun is pointing down (i.e. not aiming straight ahead)
 Jeep full of troops comes into view, slows as one jumps out to talk to our squad, then continues on past us
 This soldier is running towards us
 Woods VO: “Don’t shoot him, don’t shoot him”
 Soldier passes by without incident – trains Player that disguise works
*/

	autosave_by_name("flashpoint_e4");
	debug_event( "event4_WalkingRail", "start" );
	level thread dialog_for_base_alert();
	level thread play_random_russian_chatter();
	
	level thread open_door(); 
	setsaveddvar( "playerPushAmount", "1" );
	level.woods super_pusher_on();
	level.bowman super_pusher_on();
	level.brooks super_pusher_on();
	
	//FLASHPOINT_OBJ_GET_TO_COMMS
	//set_event_objective( 3, "active" );

	if(	flag( "walk_to_compound" ) )  //set by trigger
	{
		//-- player is already up there, so head up!
	}
	else
	{
		guys = getaiarray( "allies" );
		
		for(i = 0; i < guys.size; i++)
		{
			guys[i] SetGoalPos( guys[i].origin );	
		}
		
		array_wait( guys, "goal" );	
		flag_wait("walk_to_compound");
	}
	
	level thread close_front_gates();
	
	//Set objective to follow Woods
	//Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_STAY_WITH_SQUAD", level.woods );
	//Objective_Set3D( level.obj_num, true, "yellow", "Follow" );
	
	//Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_FOLLOW_WOODS_CASUAL", level.woods );
	//Objective_Set3D( level.obj_num, true, "default", "Squad" );
	
	//Spawn the base
	thread spawn_base();


// 	//-- Casual Walk Anims
//  	level.scr_anim[ "woods" ][ "casual_walk" ]				= %ch_flash_casual_walk_woods;
//  	level.scr_anim[ "bowman" ][ "casual_walk" ]				= %ch_flash_casual_walk_bowman;
//  	level.scr_anim[ "brooks" ][ "casual_walk" ]				= %ch_flash_casual_walk_bowman;
//  	
//  	
 	level.woods.unique_patrol_walk_anim = "casual_walk";
 	level.bowman.unique_patrol_walk_anim = "casual_walk";
 	level.brooks.unique_patrol_walk_anim = "casual_walk";
 	level.woods.disable_melee = 1;
 	level.bowman.disable_melee = 1;
 	level.brooks.disable_melee = 1;
 	
 	level.woods.turnrate = 110;
 	level.bowman.turnrate = 110;
 	level.brooks.turnrate = 110;
 	
 	//level.bowman.moveplaybackrate = ( 0.8 );
	level.woods thread maps\_patrol::patrol( "woods_patrol" );
	level.bowman thread maps\_patrol::patrol( "bowman_patrol" );
	level.brooks thread maps\_patrol::patrol( "brooks_patrol" );
	
	level.woods thread woods_walk_compound();
 	level.brooks thread brooks_walk_compound();
 	level.bowman thread bowman_walk_compound();
 	
 	level thread walkThroughDialog();
	
	level.player thread cover_blown_player();
	level.player thread player_runs_off_wrong_way_fail();
	level.player thread player_breaks_stealth_base();
	level.player SetLowReady( true );
	level.player AllowJump( false );
	level.player AllowAds( false );
	level.player AllowSprint( false );
	level.player AllowMelee( false );
	level.player disableoffhandweapons();

	level.player SetMoveSpeedScale( 0.35 );
	SetSavedDvar( "player_runbkThreshhold", 0.0 ); //Fix for rapid footsteps

	//Wait for the player to hit the alert trigger
//	waitForBaseOnAlert = getent( "trigger_compound_01", "targetname" );
//	waitForBaseOnAlert waittill( "trigger" );
	
	flag_wait( "BASE_ALERT" );

	//Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_LOOK_ALERT", level.woods );
	//Objective_Set3D( level.obj_num, true, "yellow", "Follow" );
	
	level waittill( "do_what_they_do" );
	
	level notify("spawn_binoc_snipers_basewalk");
	level.player SetLowReady( false );
	level.player AllowJump( true );
	level.player AllowAds( true );
	level.player AllowSprint( true );
	level.player AllowMelee( true );
	level.player SetMoveSpeedScale( 1.0 );
	level.player enableoffhandweapons();

	SetSavedDvar( "player_runbkThreshhold", 60.0 ); //Resetting to default value

	debug_event( "event4_WalkingRail", "end" );
	event4_BaseOnAlert();
}

event4_BaseOnAlert()
{
/*
 Woods VO: They’ve discovered the bodies, base is going on alert
 Chopper in highlighted area, blades are spinning, soldiers climbing in
 Base alive with soldiers running, general commotion
 Woods – don’t shoot there are too many, let’s keep our cool
 2 more soldiers run past Player and squad – give feeling Player is surrounded to heighten tension
 NOTE: If Player shoots at any point here on, he should face OVERWHELMING odds and be killed (e.g. WaW sniper)
*/
	level endon( "PLAYER_MUST_DIE" );
	
	debug_event( "event4_BaseOnAlert", "start" );
	
	//level thread open_door();
	
	//Base is on high alert
	level.woods.animname = "woods";
	//level.woods.disablearrivals = false;
	//level.woods.disableexits = false;
	level.woods set_run_anim( "run_fast", true );
	
	level.brooks.animname = "brooks";
	//level.brooks.disablearrivals = false;
	//level.brooks.disableexits = false;
	level.brooks set_run_anim( "run_fast", true );
	
	level.bowman.animname = "bowman";
	//level.bowman.disablearrivals = false;
	//level.bowman.disableexits = false;
	level.bowman set_run_anim( "run_fast", true );
	
	level.player SetLowReady( false );
	level.player AllowJump( true );
	level.player AllowMelee( true );
	level.player AllowSprint( true );
	
		
	//Bring up pipe blocker script_brushmodel
	level.door_blocker = getent( "door_blocker", "targetname" );
	level.door_blocker Solid();
	level.door_blocker disconnectpaths();
	
	
	debug_event( "event4_BaseOnAlert", "end" );
	
	event4_CommunicationsBuildingDistraction();
}

distraction_anim_brooks()
{	
	level endon( "PLAYER_MUST_DIE" );
	
	//Wait till squad is in position (only waiting for woods right now)
	flag_wait( "READY_FOR_DISTRACTION_ANIM" );	
	flag_wait( "DISTRACTION_SCENE_BOWMAN_AT_GOAL" );
	flag_wait( "DISTRACTION_SCENE_BROOKS_AT_GOAL" );
	
	anim_node = get_anim_struct( "9" );
	
	wait( 0.1 );
	anim_node thread anim_single_aligned( self, "reduced_to_one_brooks" );
	anim_node waittill( "reduced_to_one_brooks" );
	self setgoalpos( self.origin );
	
	self StopAnimScripted();
	//guard_node = GetNode( self.animname+"_guard_node", "script_noteworthy" );
	guard_node = GetNode( "brooks_comms_wait", "targetname" );
	self SetGoalNode( guard_node );
	
//	anim_node thread anim_loop_aligned( self, "reduced_to_one_end" );
	
	flag_wait( "COMMS_BUILDING_DOOR_OPEN" );
	level notify("delete_binoc_snipers_basewalk");
	
//	self StopAnimScripted();
}

distraction_anim_bowman()
{	
	level endon( "PLAYER_MUST_DIE" );
	
	//Wait till squad is in position (only waiting for woods right now)
	flag_wait( "READY_FOR_DISTRACTION_ANIM" );	
	flag_wait( "DISTRACTION_SCENE_BOWMAN_AT_GOAL" );
	flag_wait( "DISTRACTION_SCENE_BROOKS_AT_GOAL" );
	
	anim_node = get_anim_struct( "9" );
	
	wait( 0.1 );
	anim_node thread anim_single_aligned( self, "reduced_to_one_bowman" );
	anim_node waittill( "reduced_to_one_bowman" );
	self setgoalpos( self.origin );
	
	self StopAnimScripted();
	
	//guard_node = GetNode( self.animname+"_guard_node", "script_noteworthy" );
	guard_node = GetNode( "bowman_comms_wait", "targetname" );
	self SetGoalNode( guard_node );
	
//	anim_node thread anim_loop_aligned( self, "reduced_to_one_end" );
	
	flag_wait( "COMMS_BUILDING_DOOR_OPEN" );
	level notify("delete_binoc_snipers_basewalk");
	
//	self StopAnimScripted();
}


distraction_anim_guard1()
{	
	level endon( "PLAYER_MUST_DIE" );
	self endon( "death" );
	
	anim_node = get_anim_struct( "9" );
	
	//Play idle anim - waiting for scene to start
	anim_node anim_reach_aligned( self, "reduced_to_one_start_guard1" );
	anim_node thread anim_loop_aligned( self, "reduced_to_one_start_guard1" );
	
	//Wait till squad is in position (only waiting for woods right now)
	level waittill_any( "start_guards", "group_gone" );
	anim_node thread anim_single_aligned( self, "reduced_to_one_guard1" );
	anim_node waittill( "reduced_to_one_guard1" );
	
	//anim_node anim_single_aligned( self, "reduced_to_one_end_guard1" );
	anim_node thread anim_loop_aligned( self, "reduced_to_one_end_guard1" );
	flag_set( "DOOR_GUARD_DEAD" );
	self StartRagdoll(); 
	self dodamage( self.health, self.origin );
	
	self die();
	self notify( "death" );
}

distraction_anim_guard2()
{	
	level endon( "PLAYER_MUST_DIE" );
	self endon( "death" );
	
	anim_node = get_anim_struct( "9" );
	
	//Play idle anim - waiting for scene to start
	anim_node anim_reach_aligned( self, "reduced_to_one_start_guard2" );
	anim_node thread anim_loop_aligned( self, "reduced_to_one_start_guard2" );
	
	//Wait till squad is in position (only waiting for woods right now)
	level waittill("start_guards");
	anim_node thread anim_single_aligned( self, "reduced_to_one_guard2" );
	anim_node waittill( "reduced_to_one_guard2" );
	self setgoalpos( self.origin );
	
	anim_node thread anim_loop_aligned( self, "reduced_to_one_end_guard2" );
	flag_set( "DOOR_GUARD_DEAD" );
	self StartRagdoll(); 
	self dodamage( self.health, self.origin );
	
	self die();
	self notify( "death" );
}

/*
#using_animtree("animated_props");
kick_open_comms_door()
{
    sync_node = getstruct("fridge_sync", "targetname");
	
	fridge = GetEnt("cache_fridge", "targetname");
	linker = Spawn( "script_model", fridge.origin );
	linker.angles = fridge.angles;
	linker SetModel( "tag_origin_animate" );
	linker.animname = "fridge";
	linker useanimtree(#animtree);
	fridge linkto( linker, "origin_animate_jnt" );
	
	linker loop_npc_idle_animation(sync_node, "cache_loop", "end_cache_loop" );
	sync_node anim_single_aligned(linker, "cache_move");

	linker delete();
}
*/


#using_animtree("animated_props");
open_door()
{
	level endon( "PLAYER_MUST_DIE" );
	//level waittill("start_door_kick");
	
    relax_ik_headtracking_limits();
  
	anim_node = get_anim_struct( "9" );
	comms_door_ent = GetEnt( "comms_door", "targetname" );
	comms_door_ent.animname = "door";
	comms_door_ent useAnimTree( #animtree ); 
	
	anim_node thread anim_single_aligned( comms_door_ent, "comms_open" );
	comms_door_ent SetAnim(level.scr_anim["door"]["comms_open"], 1.0, 0.0, 0.0);

	level waittill("start_door_kick");
	exploder( 501 );
	flag_set( "COMMS_BUILDING_DOOR_OPEN" );
	
	comms_door_ent SetAnim(level.scr_anim["door"]["comms_open"], 1.0, 0.0, 1.0);
	level notify( "set_portal_override_woods_door_kick" );
	level.door_blocker NotSolid();
	level.door_blocker connectpaths();

	//if the player is close shake camera and controller rumble
	distance = Distance2D(level.woods.origin, level.player.origin);
	if( distance < 200)
	{
		Earthquake(0.1, 0.5, level.player.origin, 256);
		level.player PlayRumbleOnEntity( "damage_light" );
	}

	level.woods thread playVO_proper( "commsgo", 0.0 ); //GO!	
	//level.player thread playVO_proper( "on_it", 1.0 ); //On it.
	//level.player thread playVO_proper( "onit", 1.0 ); //On it.
	
	level thread timeout_alarm();

	level thread maps\flashpoint_e5::spawnguards_in_room();

	flag_wait( "comm_room_burnt" );

	axis = GetAIArray( "axis" );
	array_func( axis, ::turn_on_sticky_aim );

	clientnotify( "comm_flash" );
	
	level.woods thread playVO_proper( "damn_made", 1.0 );				//Damn!... We've been made! 

	//level thread maps\flashpoint_e5::spawnguards_in_room();
	//level notify( "set_portal_override_woods_door_kick" );
//	level.door_blocker NotSolid();
//	level.door_blocker connectpaths();
	
	//anim_node thread anim_single_aligned( comms_door_ent, "comms_open" );
	//anim_node waittill( "comms_open" );
	
	restore_ik_headtracking_limits();
	
	level.woods.ignoreall = false;
	woods_in_comms_node = getnode( "woods_in_comms", "targetname" );
	//level.woods setgoalnode( woods_in_comms_node );

	level.woods force_goal( woods_in_comms_node, 64 );
	level.woods waittill( "goal" );
	//level.woods.ignoreall = false;
	
// 	//Wait till woods goes into the Comms building and close the door
// 	//Also make sure the player is inside!
// 	flag_wait( "CLOSE_COMMS_DOOR" );
// 	
// 	level.door_blocker Solid();
// 	anim_node thread anim_single_aligned( comms_door_ent, "comms_close" );
// 	anim_node waittill( "comms_close" );
// 	
	
	
	
	//anim_node thread anim_loop_aligned( comms_door_ent, "comms_end" );
	
	/*
		level.scr_anim["door"]["comms_end"][0] = %o_flash_b05_comm_breach_door_endloop;
	level.scr_anim["door"]["comms_open"] = %o_flash_b05_comm_breach_door_opens;
	level.scr_anim["door"]["comms_start"][0] = %o_flash_b05_comm_breach_door_shutloop;
	*/
	
	//Open door
	println( "DOOR OPEN" );
	//flag_set( "COMMS_BUILDING_DOOR_OPEN" );
	
	//comms_door_ent = getent( "comms_door", "targetname" );
	//comms_door_ent Hide();
}

timeout_alarm()
{
	level endon( "comm_room_burnt" );

	wait( 2 );
	
	flag_set( "comm_room_burnt" );

}

#using_animtree( "generic_human" );

distraction_anim_woods()
{	
	level endon( "PLAYER_MUST_DIE" );
	
	//Wait till squad is in position (only waiting for woods right now)
	flag_wait( "READY_FOR_DISTRACTION_ANIM" );
	level waittill("group_gone");
	autosave_by_name("flashpoint_e4b");

	//kdrew adding a wait check for the player to be close
	safe_line = GetEnt("triggercolor_blockhouse","targetname");
	while( level.player.origin[0] >  (safe_line.origin[0] + 150) )
	{
		wait(0.05);
	}

	//self enable_cqbwalk();
	anim_node = get_anim_struct( "9" );
	level.woods thread playVO_proper( "youready", 0.0 ); //You ready?
	
	//self anim_set_blend_in_time(.5);

	wait( 0.10);

	//new method to fix anim pop
//	woods_door_kick_new = GetNode( "woods_door_kick_new", "targetname" );
//	self force_goal( woods_door_kick_new, 64 );
//	self waittill( "goal" );
//
//	wait( 2 );

	//anim_node anim_reach_aligned( self, "reduced_to_one_doorkick" );
	
	anim_node anim_reach_aligned( self, "reduced_to_one_doorkick_trans" );
	anim_node anim_single_aligned( self, "reduced_to_one_doorkick_trans" );
	//anim_node waittill( "reduced_to_one_doorkick_trans" );

	//woods_door_kick = getnode( "woods_door_kick", "targetname" );
	//self setGoalNode( woods_door_kick );
	//self.goalradius = 4;
	//self waittill( "goal" );
	//wait( 1.8 ); 
	
	//Play the actual door kick anim
	anim_node anim_single_aligned( self, "reduced_to_one_doorkick" );
	//anim_node waittill( "reduced_to_one_doorkick" );
	
	//self disable_cqbwalk();
	woods_goal_node = GetNode( "woods_guard_node", "script_noteworthy" );
	self SetGoalNode( woods_goal_node );
}

super_pusher_off()
{
	self.dontavoidplayer = false;
	self.noDodgeMove = false;
	self.pathenemylookahead = self.pathenemylookahead_prev; 
	self PushPlayer( false );
}

super_pusher_on()
{
	self.dontavoidplayer = true;
	self.noDodgeMove = true;
	self.pathenemylookahead_prev = level.woods.pathenemylookahead; 
	self.pathenemylookahead = 0; 
	self PushPlayer( true );
}


event4_CommunicationsBuildingDistraction()
{	
	level endon( "PLAYER_MUST_DIE" );
	
	//Objective_State( level.obj_num, "done" );
	//Objective_Set3D( level.obj_num, false );
		
	//Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_GET_IN_COMMS" );
	//Objective_Set3D( level.obj_num, false );
	
 	level.woods thread distraction_anim_woods();
 	level.brooks thread distraction_anim_brooks();
 	level.bowman thread distraction_anim_bowman();
// 	level.base_guard_comms_door_1.animname = "guard1";
// 	level.base_guard_comms_door_2.animname = "guard2";
// 	level.base_guard_comms_door_1.dontalert = true;
// 	level.base_guard_comms_door_2.dontalert = true;
// 	level.base_guard_comms_door_1 thread distraction_anim_guard1();
// 	level.base_guard_comms_door_2 thread distraction_anim_guard2();
// 	level.base_guard_comms_door_1.allowdeath = true;
// 	level.base_guard_comms_door_2.allowdeath = true;
	
	
	//Wait for Woods to open the door
	flag_wait( "COMMS_BUILDING_DOOR_OPEN" );
	setsaveddvar( "playerPushAmount", "0" );
	level.woods super_pusher_off();
	level.bowman super_pusher_off();
	level.brooks super_pusher_off();
	
	level.woods.turnrate = 220;
 	level.bowman.turnrate = 220;
 	level.brooks.turnrate = 220;
 	
	//Objective_State( level.obj_num, "done" );
	//Objective_Set3D( level.obj_num, false );
	//autosave_by_name("flashpoint_e4b");
	
	//Objective_State( level.obj_num, "done" );
	//Objective_Set3D( level.obj_num, false );

	//Objective_State( level.obj_num, "done" );
	//level.obj_num++;
	//Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_CLEAR_ROOMS" );
	//Objective_Set3D( level.obj_num, false );
	
	//Bring up pipe blocker script_brushmodel
	//level.door_blocker = getent( "pipe_blocker", "targetname" );
	//level.door_blocker NotSolid();

	
//	alert_snipers();
//	level.woods.ignoreall = false;
	
	//Goto next event
	flag_set("BEGIN_EVENT5");
}


////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////
