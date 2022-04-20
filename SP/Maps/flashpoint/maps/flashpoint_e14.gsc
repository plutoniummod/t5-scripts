////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL SCRIPTS
// 
//
// Script for event 14 - this covers the following scenes from the design:
//		Slides 80-85
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;
#include maps\flashpoint_util;

////////////////////////////////////////////////////////////////////////////////////////////
// EVENT14 FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////


event14_BTRDrive()
{
/*
 Player now switches to 3rd person view of BTR
 Player has independent control of BTR (LS) and Turret (RS) just like WaW “Blood & Iron” level
 CONTROLS NOTE: There should be mini-training text explaining the above controls
 Including RT to fire, LT to zoom in / ADS
 ART NOTE: The BTR should have a very strong metal shine (compare to tank in “Blood & Iron”)
 AUDIO NOTE: Again, like “Blood & Iron”, there should be a rousing music track playing
 EFFECTS NOTE: If BTR damaged, refer to “Blood and Iron” for audio and screen effect benchmark
 SEQUENCE NOTE: The following section should remain sub 5 mins
*/
//	compound_vehicles = GetEntArray( "compound_vehicles", "targetname" );
//	array_func( compound_vehicles, ::self_delete );
//
//	truck = GetEnt("pushjeep", "targetname");
//	truck Delete();
//
//	escape_path_trucks = GetEntArray( "escape_path_trucks", "targetname" );
//	array_func( escape_path_trucks, ::self_delete );

//	gate_blocker_uaz = maps\_vehicle::spawn_vehicles_from_targetname( "gate_blocker_uaz" )[0]; //1210.8 -1910.6 324.3
//	gate_blocker_uaz thread vehicle_gibs_death();

	//gate_blocker_uaz SetBrake(1);

	//spawn destructible vehicles to replace static ones
//	compound_entrance_veh = maps\_vehicle::spawn_vehicles_from_targetname( "compound_entrance_veh" )[0]; //1210.8 -1910.6 324.3
//	compound_mid_1_veh = maps\_vehicle::spawn_vehicles_from_targetname( "compound_mid_1_veh" )[0]; //255.8 -149.6 276.3
//	compound_mid_2_veh = maps\_vehicle::spawn_vehicles_from_targetname( "compound_mid_2_veh" )[0]; //112.5 16.9 280.6
//	compound_left_veh = maps\_vehicle::spawn_vehicles_from_targetname( "compound_left_veh" )[0]; //-756.3 408 269.9

//	compound_entrance_veh SetBrake(1);
//	compound_mid_1_veh SetBrake(1);
//	compound_mid_2_veh SetBrake(1);
//	compound_left_veh SetBrake(1);

	//-- turn the btr triggers on
//	trigger_on( "btr_trigger", "script_noteworthy" );
//
//	level thread btr_chase_fail();
//
//	level thread event14_update_obj_after_entering_btr();
//	level thread first_gate_truck();
//
//	//spawn trucks if player runs this way
//	level thread heli_pad_reinforcements();
//
////	level thread event14_open_first_gate();
//
//	level thread second_limo_sighting();
//
//	level thread first_gate_poppers();
//
//	level thread compound_trucks();
}

//btr_chase_fail()
//{
//	trigger_wait( "btr_chase_fail" );
//	
//	flag_set( "limo_escaped_fail" );
//}

event14_BTRDriveSlow()
{
/*
 BTR has already undergone damage from the preceding RPG attack, leaving 2 conseq4uences:
	1) Inside/back of the BTR is on fire/damaged, so Woods and Bowman are running ahead outside the BTR
	2) Woods tells Player to drive slow so BTR can protect them
 The Player, Brooks and Weaver inside the BTR, Woods & Bowman outside, the Player is now on the hunt for Dragovich
 Player must protect Woods and Bowman who are on foot, and advance through the level
*/
}

event14_BridgeCollapse()
{
/*
 Woods & Bowman have run ahead of the BTR and are waiting under the bridge
 Above them, 2 RPG carrying Russians have emerged and are threatening the Player
 This should be an easy ‘training’ for shooting at targets
 When the Player fires upon the bridge, it should collapse (the squad members below have moved to safety on the other side)
 NOTE: There is constant radio communication between the squad outside & Player on the turret. For this area, Player should say “I’ve got these 2, watch for the bridge”
 NOTE: If Player chooses not to kill the RPG guys, BTR will be taken out by the RPGs
*/
}

event14_ProtectSquad()
{
/*
 The squad comes under more RPG fire from the building to the left
 Woods and Bowman jump over the barrier to go deal with them
 At the same time, foot soldiers are streaming in ahead, and are going after Woods and Bowman
 Player must protect Woods and Bowman from the foot soldiers while at the same time dodging fire from the RPGs
*/
}

event14_BTRAttack()
{
/*
 The ever enterprising Spetznaz are trying to ambush the Player with a bunch of BTRs
 This is enough fire power to force the Player back
 NOTE: More soldiers are running in to further threaten Woods and Bowman
 NOTE: BTRs should slowly advance, not be stationary targets
*/

	//Goto next event
	flag_set("BEGIN_EVENT15");
}


//event14_update_obj_after_entering_btr()
//{
//
//	trigger_wait( "trig_start_limo" );
//
//	spawn_manager_enable( "first_gate_random_spawner" );
//
//	level.btr waittill("enter_vehicle");
////	level.btr MakeVehicleUnusable();
//	
////	level thread btr_rumble_based_on_speed();
//
//	//2 migs flyby
////	enter_btr_mig_1 = maps\_vehicle::spawn_vehicles_from_targetname( "enter_btr_mig_1" )[0];
////	enter_btr_mig_2 = maps\_vehicle::spawn_vehicles_from_targetname( "enter_btr_mig_2" )[0];
////
////	enter_btr_mig_1 veh_magic_bullet_shield( 1 );
////	enter_btr_mig_2 veh_magic_bullet_shield( 1 );
////
////	enter_btr_mig_1 thread go_path( GetVehicleNode(enter_btr_mig_1.target,"targetname") );
////	enter_btr_mig_2 thread go_path( GetVehicleNode(enter_btr_mig_2.target,"targetname") );
////
////	enter_btr_mig_1 thread playPlaneFx();
////	enter_btr_mig_2 thread playPlaneFx();
////
////	//kevin adding jet audio
////	enter_btr_mig_1 thread maps\flashpoint_amb::mig_fake_audio(1);
////	enter_btr_mig_2 thread maps\flashpoint_amb::mig_fake_audio(1.7);
//	
//	btr_controller_tutorial();
//
//	level.btr thread go_path( GetVehicleNode(level.btr.target,"targetname") );
//
//	spawn_manager_disable( "first_gate_random_spawner" );
//
////	level.btr SetAcceleration(80);
////	level.btr SetVehMaxSpeed(40);
//
//	simple_spawn( "first_gate_enemies", ::shrink_my_radius ); //3 AI
//
//	battlechatter_off( "axis" );
//	
//	Objective_State( level.obj_num, "done" );
//	level.obj_num++;
//	Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_CATCH_THE_LIMO" );
//
//	level.player EnableInvulnerability(true); //-- TODO: need to come up with a way to do the health differently probably
//	level.player magic_bullet_shield();
//	level.btr veh_magic_bullet_shield(1);
//
//	wait(0.15);
//
//	autosave_by_name("ChaseDragovich");
//}

//btr_controller_tutorial()
//{
////	//------------ TUTORIAL -------------------------
////	screen_message_create(&"FLASHPOINT_BTR_INSTRUCT_LS");
////	//------------ TUTORIAL -------------------------
////	wait(3);
////	screen_message_delete();			
//	//------------ TUTORIAL -------------------------
//	screen_message_create(&"FLASHPOINT_BTR_INSTRUCT_FIRE");
//	//------------ TUTORIAL -------------------------
//	wait(3);
//	screen_message_delete();			
//	//------------ TUTORIAL -------------------------
//	screen_message_create(&"FLASHPOINT_BTR_INSTRUCT_RS");
//	//------------ TUTORIAL -------------------------
//	wait(3);
//	screen_message_delete();			
//}

//heli_pad_reinforcements()
//{
//	level endon( "player_in_btr" );
//
//	trig_spawn_reinforcements = trigger_wait( "trig_spawn_reinforcements" );
//	trig_spawn_reinforcements Delete();
//	
//	flag_wait( "limo_gone" );
//
//	flag_set( "spawn_heli_uaz_2" );
//	flag_set( "spawn_first_gate_truck" );
//
//}
//	
//first_gate_truck()
//{
//	flag_wait( "spawn_first_gate_truck" );
//
//	first_gate_truck = maps\_vehicle::spawn_vehicles_from_targetname( "first_gate_truck" )[0];
//	first_gate_truck thread go_path( GetVehicleNode(first_gate_truck.target,"targetname") );
//	first_gate_truck thread vehicle_gibs_death();
//}

//shrink_my_radius()
//{
//	self endon( "death" );
//
//	self.goalradius = 32;
//}

//event14_spawn_escort_migs()
//{
//	//2 migs flyby
//	chase_escort_mig_1 = maps\_vehicle::spawn_vehicles_from_targetname( "chase_escort_mig_1" )[0];
//	chase_escort_mig_2 = maps\_vehicle::spawn_vehicles_from_targetname( "chase_escort_mig_2" )[0];
//
//	chase_escort_mig_1 veh_magic_bullet_shield( 1 );
//	chase_escort_mig_2 veh_magic_bullet_shield( 1 );
//
//	chase_escort_mig_1 thread go_path( GetVehicleNode(chase_escort_mig_1.target,"targetname") );
//	chase_escort_mig_2 thread go_path( GetVehicleNode(chase_escort_mig_2.target,"targetname") );
//
//	chase_escort_mig_1 thread playPlaneFx();
//	chase_escort_mig_2 thread playPlaneFx();
//
//	//kevin adding jet audio
//	chase_escort_mig_1 thread maps\flashpoint_amb::mig_fake_audio(1);
//	chase_escort_mig_2 thread maps\flashpoint_amb::mig_fake_audio(1.5);
//}

// Opens the first gate where the player gets into
// the btr.
//event14_open_first_gate()
//{
//	gates = [];
//	gates[0] = GetEnt("gate1l", "targetname");
//	gates[1] = GetEnt("gate1r", "targetname");
//	
//	gate_structs = [];
//	gate_structs[0] = getstruct("struct_gate1l", "targetname");
//	gate_structs[1] = getstruct("struct_gate1r", "targetname");
//	
//	for( i = 0; i < gates.size; i++ )
//	{
//		gates[i].angles = gate_structs[i].angles;
//	}
//}
//
//second_limo_sighting()
//{
//
//	flag_wait( "player_in_btr" );
//
//	flag_set( "spawn_heli_uaz_2" );
//	flag_set( "spawn_first_gate_truck" );
//
//	trig_spawn_limo_2 = trigger_wait( "trig_spawn_limo_2" );
//	trig_spawn_limo_2 Delete();
//
//	exit_heli_magic_rpgs = getstructarray( "exit_heli_magic_rpgs", "targetname" );
//	array_thread( exit_heli_magic_rpgs, ::play_magic_rpgs );
//
//	level thread second_timeout_fail();
//
//	level.limo = maps\_vehicle::spawn_vehicles_from_targetname( "limo_chase_compound" )[0];
//	level.limo veh_toggle_tread_fx(1);	
//
//	flag_wait( "limo_2_start_driving" );
//
//	level.limo thread go_path( GetVehicleNode(level.limo.target,"targetname") );
//	level.limo veh_magic_bullet_shield( 1 );
//
//	Objective_AdditionalPosition( level.obj_num, 0, level.limo );
//	Objective_Set3D( level.obj_num, true, "default", &"FLASHPOINT_CAPTURE" );
//}

//play_magic_rpgs()
//{
//	end_rpg_spot = getstruct(self.target,"targetname");
//	MagicBullet( "rpg_magic_bullet_sp", self.origin, end_rpg_spot.origin );
//}

//second_timeout_fail()
//{
//	level endon( "btr_hits_gate" );
//	wait( 20 );
//
//	flag_set( "limo_escaped_fail" );
//}

//first_gate_poppers()
//{
//	flag_wait( "player_in_btr" );
//
//	trig_first_gate_poppers = trigger_wait( "trig_first_gate_poppers" );
//	trig_first_gate_poppers Delete();	
//
//	//2 migs flyby
//	split_path_mig_right = maps\_vehicle::spawn_vehicles_from_targetname( "split_path_mig_right" )[0];
//	split_path_mig_left = maps\_vehicle::spawn_vehicles_from_targetname( "split_path_mig_left" )[0];
//
//	split_path_mig_right veh_magic_bullet_shield( 1 );
//	split_path_mig_left veh_magic_bullet_shield( 1 );
//
//	split_path_mig_right thread go_path( GetVehicleNode(split_path_mig_right.target,"targetname") );
//	split_path_mig_left thread go_path( GetVehicleNode(split_path_mig_left.target,"targetname") );
//
//	split_path_mig_right thread playPlaneFx();
//	split_path_mig_left thread playPlaneFx();
//
//	//kevin adding jet audio
//	split_path_mig_right thread maps\flashpoint_amb::mig_fake_audio(0.40);
//	split_path_mig_left thread maps\flashpoint_amb::mig_fake_audio(0.30);
//
//	level thread event14_push_door_closed();
//	level thread ram_gate_uaz();
//	level thread VO_around_the_turn();
//
//	//shabs - adding two guys to pop out here.
//	simple_spawn( "pre_ram_gate_enemies" );
//
//	flag_set( "limo_2_start_driving" );
//}

//ram_gate_uaz()
//{
//	spawn_ram_gate_uaz = trigger_wait( "spawn_ram_gate_uaz" );
//	spawn_ram_gate_uaz Delete();
//
//	ram_gate_uaz = maps\_vehicle::spawn_vehicles_from_targetname( "ram_gate_uaz" )[0];
//	ram_gate_uaz thread go_path( GetVehicleNode(ram_gate_uaz.target,"targetname") );
//	ram_gate_uaz thread vehicle_gibs_death();
//}
//
//VO_around_the_turn()
//{
//	level.btr anim_single( level.btr, "losing_him");
//	wait(0.1);
//	level.btr anim_single( level.btr, "faster_mason");
//}

// Handles the gate that gets closed by soldiers that the player
// rams the BTR through.
//event14_push_door_closed()
//{
//
//	flag_wait( "player_in_btr" );
//
//	simple_spawn( "right_side_runners", ::shrink_my_radius );
//
//	gates = [];
//	gates[0] = GetEnt("gate2l", "targetname");
//	gates[1] = GetEnt("gate2r", "targetname");
//	
//	gate_structs = [];
//	gate_structs[0] = getstruct("struct_gate2l", "targetname");
//	gate_structs[1] = getstruct("struct_gate2r", "targetname");
//	
//	gate_guys = simple_spawn( "spawner_gate_throw", ::setup_gate_guys );
//
//	for( i = 0; i < gates.size; i++ )
//	{
//		gates[i] RotateTo(gate_structs[i].angles, 2, 0.1, 0.5 );
//	}
//	
//	array_thread( gates, ::close_gate_until_hit );
//	
//	wait(1);
//	
//	obj_object = GetEnt("obj_ram_gate", "targetname");
//	new_obj = Spawn("script_model", obj_object.origin);
//	new_obj SetModel("tag_origin");
//	Objective_AdditionalPosition( level.obj_num, 0, new_obj );
//	Objective_Set3D( level.obj_num, true, "default", &"FLASHPOINT_OBJ_RAM" );
//	
//	level thread VO_ram_the_gate();
//	
//	level waittill("btr_hits_gate");
//
//	Earthquake( 0.4, 0.4, level.btr.origin, 1000, level.player );
//	level.player PlayRumbleOnEntity( "explosion_generic" );
//	//level.player SetBlur( 0.75, 0.25 );
//
//	ram_gate_magic_rpgs = getstructarray( "ram_gate_magic_rpgs", "targetname" );
//	array_thread( ram_gate_magic_rpgs, ::play_magic_rpgs );
//
//	level thread third_timeout_fail();
//
//	level thread setup_left_uaz();
//	
//	Objective_Set3D( level.obj_num, false);
//	
//	end_turn_obj_breadcrumb = getstruct("end_turn_obj_breadcrumb", "targetname");
//	Objective_Position(level.obj_num, end_turn_obj_breadcrumb.origin + (0,0,25));
//	objective_set3d(level.obj_num, true);
//
//	gates[0] RotateTo(gate_structs[0].angles + (0,170,0), 0.5, 0.05, 0.05 );
//	gates[1] RotateTo(gate_structs[1].angles - (0,170,0), 0.5, 0.05, 0.05 );
////	level thread throw_gate_guys( VectorNormalize(gate_structs[0].angles + (30,0,0) ) * 300 );
//	
//	level thread event14v2_drag_at_gate();
//
//	human_roadblock_guys = simple_spawn( "human_roadblock_guys", ::shrink_my_radius );
//
//	//2 migs flyby
//	chase_mig_1 = maps\_vehicle::spawn_vehicles_from_targetname( "chase_mig_1" )[0];
//	chase_mig_2 = maps\_vehicle::spawn_vehicles_from_targetname( "chase_mig_2" )[0];
//
//	chase_mig_1 veh_magic_bullet_shield( 1 );
//	chase_mig_2 veh_magic_bullet_shield( 1 );
//
//	chase_mig_1 thread go_path( GetVehicleNode(chase_mig_1.target,"targetname") );
//	chase_mig_2 thread go_path( GetVehicleNode(chase_mig_2.target,"targetname") );
//
//	chase_mig_1 thread playPlaneFx();
//	chase_mig_2 thread playPlaneFx();
//
//	//kevin adding jet audio
//	chase_mig_1 thread maps\flashpoint_amb::mig_fake_audio(1);
//	chase_mig_2 thread maps\flashpoint_amb::mig_fake_audio(1.7);
//}
//
//setup_left_uaz()
//{
//	chase_left_uaz = maps\_vehicle::spawn_vehicles_from_targetname( "chase_left_uaz" )[0];
//	chase_left_uaz thread go_path( GetVehicleNode(chase_left_uaz.target,"targetname") );
//	chase_left_uaz thread vehicle_gibs_death();
//
//	chase_left_uaz thread launch_vehicle_destruction( "stop_left_uaz_launch" );
//	chase_left_uaz waittill( "reached_end_node" );
//	level notify( "stop_left_uaz_launch" );
//
//}
//
//setup_chase_uaz()
//{
//	chase_uaz = maps\_vehicle::spawn_vehicles_from_targetname( "chase_uaz" )[0];
//	chase_uaz thread go_path( GetVehicleNode(chase_uaz.target,"targetname") );
//	chase_uaz thread vehicle_gibs_death();
//
//	chase_uaz thread launch_vehicle_destruction( "stop_chase_uaz_launch" );
//	chase_uaz waittill( "reached_end_node" );
//	level notify( "stop_chase_uaz_launch" );
//}
//
//third_timeout_fail()
//{
//	level endon( "kill_third_timeout_fail" );
//	wait( 15 );
//
//	flag_set( "limo_escaped_fail" );
//}
//
//init_left_side_runners_ignore()
//{
//	self endon( "death" );
//	
//	self.goalradius = 32;
//	self.pacifist = true;
//	goal_node = GetNode( self.target, "targetname" );
//	
//	self waittill( "goal" );
//	self.pacifist = false;
//}
//
//compound_trucks()
//{
//	spawn_chase_trucks = trigger_wait( "spawn_chase_trucks" );
//	spawn_chase_trucks Delete();	
//
//	simple_spawn( "left_side_runners_ignore", ::init_left_side_runners_ignore );
//
//	chase_left_truck = maps\_vehicle::spawn_vehicles_from_targetname( "chase_left_truck" )[0];
//	chase_left_truck thread go_path( GetVehicleNode(chase_left_truck.target,"targetname") );
//	chase_left_truck thread vehicle_gibs_death();
//
//	level thread setup_chase_uaz();
//
//	trig_setup_ending_limo = trigger_wait( "trig_setup_ending_limo" );
//	trig_setup_ending_limo Delete();
//
//	//limo damage states
//	level thread limo_half_damage_state();
//	level thread limo_final_damage_state();
//
//	kill_aigroup( "first_gate_enemies" );
//	
//	//delete spawners
//	first_gate_enemies = GetEntArray( "first_gate_enemies", "script_noteworthy" );
//	array_func( first_gate_enemies, ::self_delete );
//
//	level.limo = maps\_vehicle::spawn_vehicles_from_targetname( "limo_chase_ending" )[0];
//	level.limo maps\_vehicle::lights_on();
//	level.limo veh_toggle_tread_fx(1);	
//
//	//this will probably be cut
//	end_rail_gunner_truck= maps\_vehicle::spawn_vehicles_from_targetname( "end_rail_gunner_truck" )[0];
//	end_rail_gunner_truck maps\_vehicle::lights_on();
//	end_rail_gunner_truck veh_toggle_tread_fx(1);	
//
//	level thread init_end_rail_gunner_truck( end_rail_gunner_truck );
//
//	level thread event14v2_ram_drag_now();
//
//	start_limo_ending = trigger_wait( "start_limo_ending" );
//	start_limo_ending Delete();
//
//	end_road_rpg_guy = simple_spawn_single( "end_road_rpg_guy" );
//	goal_node = GetNode( end_road_rpg_guy.target, "targetname" );
//	end_road_rpg_guy thread force_goal( goal_node, 64 );
//
//	level thread ending_rpg_fail();
//	level thread end_limo_escaped_fail();
//
//	end_path_magic_rpgs = getstructarray( "end_path_magic_rpgs", "targetname" );
//	array_thread( end_path_magic_rpgs, ::play_magic_rpgs );
//
//	end_path_truck = maps\_vehicle::spawn_vehicles_from_targetname( "end_path_truck" )[0];
//	end_path_truck thread go_path( GetVehicleNode(end_path_truck.target,"targetname") );
//
//	level.limo thread go_path( GetVehicleNode(level.limo.target,"targetname") );
//	level.limo SetSpeedImmediate( 30 );
//	level.limo thread limo_destroyed();
//	level.limo thread limo_health_monitor();
//
//	//level thread event14v2_match_btr_to_limo_speed();
//	level thread end_sequence_clean_up();
//	level thread limo_fail_crash();
//	level thread end_scene_dialogue();
//
//	Objective_Set3D( level.obj_num, false);
//
//	Objective_AdditionalPosition( level.obj_num, 0, level.limo );
//	Objective_Set3D( level.obj_num, true, "default", &"FLASHPOINT_CAPTURE" );
//
//	level thread end_chase_vo();
//}
//
//init_end_rail_gunner_truck( truck )
//{
//	truck thread go_path( GetVehicleNode(truck.target,"targetname") );
//
//	//truck_driver = simple_spawn_single ("truck_driver", ::init_truck_driver, self );
//	level.end_truck_gunner = simple_spawn_single ("end_truck_gunner", ::end_truck_gunner_think, truck);
//	level.end_truck_gunner thread monitor_gunner_death( truck );
//
//	gunner_start_firing_node = GetVehicleNode( "gunner_start_firing_node", "script_noteworthy" ); 
//	gunner_start_firing_node waittill( "trigger" );
//
//	truck waittill( "reached_end_node" );
//	flag_set( "start_gunner_fire" );
//
//	truck veh_magic_bullet_shield( 0 );
//	truck.health = 400;
//}
//
//end_truck_gunner_think( truck )
//{
//	self endon( "death" );
//
//	self gun_remove();
//	self.ignoreme = true;
//	self.ignoreall = true;
//	self.animname = "generic";
//	self.truck = truck;
//	self maps\_vehicle_aianim::vehicle_enter(truck, "tag_gunner1" );
//
//	self.truck SetGunnerTargetEnt(level.player, (RandomIntRange(-50, 50), RandomIntRange(-50, 50), RandomIntRange(-50, 50)));
//
//	flag_wait( "start_gunner_fire" );
//
//	self.truck ClearTurretTarget(); 		
//	self.truck thread gunner_direct_fire_at_player();
//}
//
//gunner_direct_fire_at_player()
//{
//	self endon("death");
//	self endon("gunner_dead");
//
//	clip = 150;
//	
//	self SetGunnerTurretOnTargetRange( 0, 50 );
//
//	sound_ent = Spawn( "script_origin", self.origin );
//	sound_ent LinkTo( self, "rear_hatch_jnt" );
//	self thread delete_gunner_sound_ent( sound_ent );
//	
//	while(IsDefined(level.player))
//	{
//		for(i=0; i<clip; i++)
//		{
//			if (IsDefined(level.player))
//			{
//				self SetGunnerTargetEnt(level.player, (RandomIntRange(-50, 50), RandomIntRange(-50, 50), RandomIntRange(-50, 50)));
//				self waittill_notify_or_timeout("gunner_turret_on_target", 0.25);
//				self fireGunnerWeapon();
//				sound_ent PlayLoopSound( "wpn_50cal_fire_loop_npc" );
//				wait(0.1);
//			}
//		}
//		sound_ent StopLoopSound( .1 );
//		self PlaySound( "wpn_50cal_fire_loop_ring_npc" );
//		wait(RandomFloatRange(2.5, 3.0));
//	}
//}
//
//delete_gunner_sound_ent( ent )
//{
//    self waittill_any( "death", "gunner_dead" );
//    ent Delete();
//}
//
//
//monitor_gunner_death( truck )
//{
//	self.truck = truck;
//	self waittill( "death" );
//
//	self.truck ClearGunnerTarget();
//	self.truck notify("gunner_dead");
//}
//
//
////btr gets owned
//ending_rpg_fail()
//{
//	flag_wait( "rpg_btr_ownage" );
//
//	level.player stop_magic_bullet_shield();
//	level.player EnableInvulnerability(false); 
//	level.btr veh_magic_bullet_shield(0);
//
//	level.btr anim_single( level.btr, "wake_up_mason");
//
//	level thread random_rpg_trails_behind_player();
//
//	wait( 4 );
//	
//	level.btr thread anim_single( level.btr, "dammit");
//
//	if( IsDefined( level.player ) )
//	{
//		level.player notify( "death" );
//	}
//
//	if( IsDefined( level.btr ) )
//	{
//		level.btr notify( "death" );
//	}
//
//	SetDvar( "ui_deadquote", &"FLASHPOINT_LIMO_ESCAPED" );
//	missionfailedwrapper();
//
//	//level thread rpg_at_the_player();
//}
//
//end_limo_escaped_fail()
//{
//	level endon( "rpg_btr_ownage" );
//
//	flag_wait( "end_limo_escaped_fail" );
//	
//	level.btr anim_single( level.btr, "dammit");
//	level.btr thread anim_single( level.btr, "wake_up_mason");
//
//	SetDvar( "ui_deadquote", &"FLASHPOINT_LIMO_ESCAPED" );
//	missionfailedwrapper();
//}
//
//random_rpg_trails_behind_player()
//{
//	while(1)
//	{
//		wait(RandomFloatRange(0.20,0.70));
//		
//		back = AnglesToForward( level.splayer.angles ) * -120;
//		
//		if( cointoss() )
//		{
//			side = AnglesToRight(level.player.angles) * 50;
//		}
//		else
//		{
//			side = AnglesToRight(level.player.angles)	 * - 50;
//		}		
//		
//		point = level.player.origin + back + side + (0,0,40);
//
//		MagicBullet( "rpg_magic_bullet_sp", point, level.btr.origin + (0,0,45) + AnglesToForward(level.btr.angles) * 100 );
//	}	
//}

//
//rpg_at_the_player()
//{
//
//	player = get_players()[0];		
//	
//	while(1)
//	{
//		wait(RandomFloatRange(0.50,2.0));
//		
//		back = AnglesToForward( level.player.angles ) * -120;
//		
//		if( cointoss() )
//		{
//			side = AnglesToRight(level.player.angles) * 30;
//		}
//		else
//		{
//			side = AnglesToRight(level.player.angles)	 * - 30;
//		}		
//		
//		point = level.player.origin + back + side;
//									
//		model = spawn("script_model",point);
//		model PlaySound("exp_mortar_dirt","sounddone");	
//		
//		if( cointoss() )
//		{
//			wait(randomfloatrange(.1,1));
//			MagicBullet( "rpg_magic_bullet_sp", point, level.btr.origin );
//		}
//	}	
//}
//
//limo_destroyed()
//{
//	level endon( "limo_crashing" );
//	
//	flag_wait( "limo_fully_damaged" );
//
//	wait( 0.10 );
//
//	level.btr anim_single( level.btr, "dammit");
//
//	SetDvar( "ui_deadquote", &"FLASHPOINT_LIMO_DESTROYED" );
//	missionfailedwrapper();
//}
//
//limo_health_monitor() //self == level.limo
//{
//	
//	self veh_magic_bullet_shield( 0 ); //turn off limo god mode
//	self.health = 20000;
//	
//	while( self.health > 10000)
//	{
//		wait(0.05);
//	}
//	
//	//TODO: Set some flags that cause some of the destruction
//	flag_set( "limo_half_damaged" );
//
//	level.btr thread anim_single( level.btr, "limo_taking_damage");
//
//	/#
//	IPrintLnBold( "limo_damaged" );
//	#/
//
//	while( self.health > 5000)
//	{
//		wait(0.05);
//	}
//
//	//TODO: Set the last destruction flags on the limo
//	flag_wait( "limo_fully_damaged" );
//	
//	/#
//	IPrintLnBold( "limo_dead" );
//	#/
//}
//
//vehicle_gibs_death()
//{
//	self waittill( "death" );
//	if(!IsDefined(self))
//	{
//		return;
//	}
//
//	vehicle_gib=[];
//
//	if(IsSubStr(self.vehicletype,"gaz66"))
//	{
//		vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_tire_low");
//		vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_tire_low");
//		vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_door_dest");
//		vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_door_dest");
//		vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_bumper_dest");
//		vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_bumper_dest");
//	}
//	else
//	{
////		vehicle_gib[vehicle_gib.size] =("vehicle_uaz_wheel_LF");
////		vehicle_gib[vehicle_gib.size] =("vehicle_uaz_wheel_RF");
////		vehicle_gib[vehicle_gib.size] =("vehicle_uaz_door_RB");
////		vehicle_gib[vehicle_gib.size] =("vehicle_uaz_door_LF");
////		vehicle_gib[vehicle_gib.size] =("vehicle_uaz_mirror_L");
////		vehicle_gib[vehicle_gib.size] =("vehicle_uaz_mirror_R");
//
//		vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_tire_low");
//		vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_door_dest");
//		vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_door_dest");
//		vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_bumper_dest");
//		vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_bumper_dest");
//	}	
//
//	up = AnglesToUp(self.angles);
//	velocity_up = Vector_Scale(up, 500);
//
//	for (i = 0; i < vehicle_gib.size; i++ )
//	{
//		x= RandomFloatRange (10,180);
//		gib = Spawn ("script_model", self.origin +(0,0,80) );
//		gib.angles = (x,x,x);
//		gib SetModel (vehicle_gib[i]);
//		gib PhysicsLaunch (gib.origin, velocity_up);
//	}
//
//}
//
//event14v2_drag_at_gate()
//{
//	btr_find_drag_gate = trigger_wait( "btr_find_drag_gate" );
//	btr_find_drag_gate Delete();
//
//	level thread event14_spawn_escort_migs();
//
//	level thread ending_timeout_fail();
//
//	level notify( "kill_third_timeout_fail" );
//	
//	kill_aigroup( "first_half_compound_ai" );
//
//	//delete spawners
//	first_half_compound_ai = GetEntArray( "first_half_compound_ai", "script_noteworthy" );
//	array_func( first_half_compound_ai, ::self_delete );
//}
//
//ending_timeout_fail()
//{
//	level endon( "limo_escaped" );
//	level endon( "limo_crashing" );
//
//	wait( 60 );
//		
//	flag_set( "end_limo_escaped_fail" );
//}

//fade_out( time )
//{
//	if( !isdefined( level.fade_out_overlay ) )
//	{
//		level.fade_out_overlay = NewHudElem();
//		level.fade_out_overlay.x = 0;
//		level.fade_out_overlay.y = 0;
//		level.fade_out_overlay.horzAlign = "fullscreen";
//		level.fade_out_overlay.vertAlign = "fullscreen";
//		level.fade_out_overlay.foreground = false;  // arcademode compatible
//		level.fade_out_overlay.sort = 50;  // arcademode compatible
//		level.fade_out_overlay SetShader( "black", 640, 480 );
//	}
//
//	// start off invisible
//	level.fade_out_overlay.alpha = 0;
//
//	level.fade_out_overlay fadeOverTime( time );
//	level.fade_out_overlay.alpha = 1;
//	wait( time );
//}

//event14v2_match_btr_to_limo_speed()
//{
//	level endon("ram_drag");
//	
//	//level.btr SetVehMaxSpeed(35);
//	//level.limo SetSpeed(35);
//	
//	increment = 0.2;
//	decrement = 0.3;
//	MAX_SPEED = 45; //-- this is old
//	MIN_SPEED = 30;
//	
//	current_max_speed = 35;
//	level.MIN_DIST = 190;
//	
//	while(1)
//	{
//		
//		//MAX_SPEED = level.btr.gear_speeds[level.btr.gear];=
//		prev_max_speed = current_max_speed;
//		
//		if( DistanceSquared( flat_origin(level.btr.origin), flat_origin(level.limo.origin)) > 384*384 )
//		{
//			if(current_max_speed < MAX_SPEED)
//			{
//				current_max_speed += increment;
//			}
//		}
//		else if( DistanceSquared( flat_origin(level.btr.origin), flat_origin(level.limo.origin)) < level.MIN_DIST*level.MIN_DIST )
//		{
//			if(current_max_speed > MIN_SPEED)
//			{
//				current_max_speed -= decrement;
//			}
//			
//			if( current_max_speed > level.limo GetSpeedMPH())
//			{
//				current_max_speed = level.limo GetSpeedMPH();
//			}
//		}
//		
//		if(prev_max_speed != current_max_speed)
//		{
//			level.btr SetVehMaxSpeed( current_max_speed );
//		}
//		
//		wait(0.05);
//	}
//}

//end_sequence_clean_up()
//{
//	ram_dragovich_now = trigger_wait("ram_dragovich_now");
//	ram_dragovich_now Delete();
//
//	kill_aigroup( "second_half_compound_ai" );
//
//	//delete spawners
//	second_half_compound_ai = GetEntArray( "second_half_compound_ai", "script_noteworthy" );
//	array_func( second_half_compound_ai, ::self_delete );
//	
//}
//
//event14v2_ram_drag_now()
//{
//	level endon( "limo_escaped" );
//
//	level.btr SetVehMaxSpeed( 45 );
//	
//	//start bump
//	event14v2_limo_btr_bump();
//
//	level notify( "limo_crashing" );
//
//	Objective_State( level.obj_num, "done" );
//	//level.obj_num++;
//
//	player_btr_path = level.limo.currentNode;
//
//	level.limo thread set_switch_node( GetVehicleNode("maybe_limo_crash", "targetname"), GetVehicleNode("limo_crash_start", "targetname" ));
//	level.limo ResumeSpeed(0);
//	//level.limo waittill("crash_node");
//
//	level thread player_btr_ending( player_btr_path );
//
//	limo_crash_start = GetVehicleNode( "limo_crash_start", "targetname" );
//	limo_crash_start waittill( "trigger" );
//
//	level.limo.animname = "limo";
//	level notify( "fxanim_flash_car_crash_anim" );
//	level.limo thread anim_loop( level.limo, "end_crash" );
//
//	level.limo waittill( "reached_end_node" );
//	level.limo anim_stopanimscripted(); 
//
//	/#
//	IPrintLnBold( "stop_limo_loop" );
//	#/
//
//	limo_driver = simple_spawn_single( "limo_driver", ::setup_limo_victims );
//	limo_passenger = simple_spawn_single( "limo_passenger", ::setup_limo_victims );
//}
//
//player_btr_ending( player_btr_path )
//{
//
//	level.btr ClearVehGoalPos();
//
//	//level.btr drivepath player_btr_path
//	level.btr drivepath( player_btr_path );
//
//	level.btr SetAcceleration(100);
//	level.btr SetSpeedImmediate( 35 );
//
//	//delete compound vehicles to make room for heli armada
//	chase_vehicles = GetEntArray( "chase_vehicles", "script_noteworthy" );
//	array_func( chase_vehicles, ::self_delete );
//
//	chase_heli_armada = maps\_vehicle::spawn_vehicles_from_targetname( "chase_heli_armada" );
//	array_thread( chase_heli_armada, ::armada_go );
//
//	//kill everyone before spawning in driver and passenger
//	axis = GetAIArray( "axis" );
//	for( i = 0; i < axis.size; i++ )
//	{
//		if( IsAlive( axis[i] ) )
//		{
//			axis[i] die();
//		}
//	}
//
////	trigger_wait( "trig_next_mission" );
//
//	//shabs - progress for disc
//// 	level.player FreezeControls( true );
////	fade_out(1.8);
////	nextmission();
//}
//
//end_scene_dialogue()
//{
//	level endon( "limo_escaped" );
//	
//	start_ending_dialogue = trigger_wait( "start_ending_dialogue" );
//	start_ending_dialogue Delete();
//
//	level.btr SetAcceleration(100);
//	level.btr SetSpeedImmediate( 15 );
//
//	flag_set( "stop_animating_limo" );
//
//	level.btr anim_single( level.btr, "satisfied");//Satisfied, Mason?
//	wait( .10 );
//	level.btr anim_single( level.btr, "see_the_body"); //Not yet... Not until I see the body.
//	wait( .10 );
//	level.btr anim_single( level.btr, "no_get_out" );
//	wait( .10 );
//	level.btr anim_single( level.btr, "rat_briquette"); //Trust me... That rat bastard's a fucking charcoal briquette.
//	wait( .10 );
//	level.btr anim_single( level.btr, "no_time"); //We ain't got time... Gotta go, Mason.
//
//	level.btr SetAcceleration(80);
//	level.btr SetSpeed( 45 );
//
////	fade_out(1.8);
////	nextmission();
//
//}
//
//armada_go()
//{
//	self veh_magic_bullet_shield( 1 );
//	self thread go_path( GetVehicleNode(self.target,"targetname") );
//}
//
//setup_limo_victims()
//{
//	self endon( "death" );
//
//	self magic_bullet_shield();
//	self.ignoreall = 1;
//	self.ignoreme = 1;	
//	self thread animscripts\death::flame_death_fx();
//	PlayFXOnTag(level._effect["enemy_on_fire"], self, "J_SpineLower");
//
//	if( self.targetname == "limo_driver_ai" )
//	{
//		self.animname = "limo_driver";
//		level.limo anim_single( self, "burning_driver" );
//	}
//	else
//	{
//		self.animname = "limo_passenger";
//		level.limo anim_single( self, "burning_passenger" );
//	}
//
//}
//
//limo_fail_crash()
//{
//	level endon( "limo_crashing" );
//
//	fail_limo_crash = GetVehicleNode( "fail_limo_crash", "script_noteworthy" );
//	fail_limo_crash waittill( "trigger" );
//	
//	level notify( "limo_escaped" );
//
//	//mission fail
// 	level.player FreezeControls( true );
//
//	flag_set( "end_limo_escaped_fail" );
//}
//
//btr_collided_limo()
//{
//	level endon( "limo_escaped" );	
//
//	while( 1 )
//	{
//		level.btr waittill("veh_collision", pos, norm, hitintensity, stype, hitent );
//	
//		if( IsDefined( hitent ) && hitent == level.limo )
//		{
//			return;
//		}
//	}
//}
//
//event14v2_limo_btr_bump()
//{
//
//	level endon( "limo_escaped" );	
//
/////////////////////////////////////////////////
////		first hit
////////////////////////////////////////////////
//	level btr_collided_limo(); 
//		
//	level.limo maps\_vehicle::lights_off();
//
//	level.btr PlaySound("phy_impact_glass_glass");
//
//	/#
//	IPrintLnBold( "First HIT!" );
//	#/
//
//	flag_set( "limo_half_damaged" );
//
//	//speed up limo
//	level.limo SetAcceleration(100);
//	level.limo SetSpeedImmediate(60);
//
//	level notify( "stop_chase_dialogue" );
//
//	level thread brake_quick();	
//	btr_slow_down_hit();
//
//	//TODO: Set some flags that cause some of the destruction
//
//	Earthquake( 0.4, 0.4, level.btr.origin, 1000, level.player );
//	level.player PlayRumbleOnEntity( "damage_heavy" );
//	//level.player SetBlur( 0.75, 0.25 );
//
//	//bring back limo to normal speed
//	level.limo SetAcceleration(100);
//	level.limo SetSpeedImmediate(30);
//
//	level.btr SetAcceleration(100);
//	level.btr SetVehMaxSpeed(45);
//
//	level.btr anim_single( level.btr, "hit_him_again");
//	level.btr anim_single( level.btr, "faster_mason" );
//
/////////////////////////////////////////////////
////		final hit
////////////////////////////////////////////////
//	level btr_collided_limo();
//	
//	flag_set( "limo_fully_damaged" );
//
//	level.btr PlaySound("phy_impact_glass_glass");
//
//	/#
//	IPrintLnBold( "FINAL HIT! SUCCESS!!" );
//	#/
//	
////	level thread script_control_btr();
//
//	level thread speed_up_limo_for_crash();
//	
//	level thread brake_quick();	
//	btr_slow_down_hit();
//
//	//TODO: Set the last destruction flags on the limo
//
//	Earthquake( 0.6, 0.5, level.btr.origin, 1000, level.player );
//	level.player PlayRumbleOnEntity( "explosion_generic" );
//	//level.player SetBlur( 0.75, 0.25 );
//
//	//slow down btr
////	level.btr SetAcceleration(80);
////	level.btr SetVehMaxSpeed(25);
//
//}
//
//speed_up_limo_for_crash()
//{
//	//speed up limo
//	level.limo SetAcceleration(100);
//	level.limo SetSpeedImmediate(60);
//
//	wait( .20 );
//
//	//speed up limo
//	level.limo SetAcceleration(50);
//	level.limo SetSpeedImmediate(45);
//}
//
//brake_quick()
//{
//	level.btr setbrake(1);
//	wait( 0.15 );
//	level.btr setbrake(0);
//}
//
//btr_slow_down_hit()
//{
//	//slow down btr
//	level.btr SetAcceleration(100);
//	level.btr SetVehMaxSpeed(10);
//	wait( 0.15 );
//}
//
////script_control_btr()
////{
////	trig_script_control_btr = trigger_wait( "trig_script_control_btr" );
////	trig_script_control_btr Delete();
////
////	level.btr SetAcceleration(100);
////	level.btr SetVehMaxSpeed(25);
////	
////}
//
//limo_half_damage_state()
//{
//	flag_wait( "limo_half_damaged" );
//
//	PlayFXOnTag( level._effect["fx_glass_rappel_window_smash"], level.limo, "tag_brakelight_right" );
//	PlayFXOnTag( level._effect["fx_glass_rappel_window_smash"], level.limo, "tag_brakelight_left" );
//
//	PlayFXOnTag( level._effect["wire_sparks_no_smoke"], level.limo, "tag_brakelight_left" );
//	PlayFXOnTag( level._effect["wire_sparks_no_smoke"], level.limo, "tag_brakelight_right" );
//
//}
//
//limo_final_damage_state()
//{
//
//	flag_wait( "limo_fully_damaged" );
//	flag_set( "limo_half_damaged" );
//
//	PlayFXOnTag( level._effect["wire_sparks"], level.limo, "tag_engine" );
//
//	PlayFXOnTag( level._effect["fx_glass_rappel_window_smash"], level.limo, "tag_brakelight_right" );
//	PlayFXOnTag( level._effect["fx_glass_rappel_window_smash"], level.limo, "tag_brakelight_left" );
//
//	PlayFXOnTag( level._effect["wire_sparks_no_smoke"], level.limo, "tag_brakelight_left" );
//	PlayFXOnTag( level._effect["wire_sparks_no_smoke"], level.limo, "tag_brakelight_right" );
//}

/*

	level._effect["fx_glass_rappel_window_smash"]			= LoadFX("maps/kowloon/fx_glass_rappel_window_smash"); // 3501
	level._effect["fire_ground"]							= LoadFX("env/fire/fx_fire_barrel_small");
	level._effect["wire_sparks"] 							= LoadFX("env/electrical/fx_elec_wire_spark_burst");
	level._effect["wire_sparks_no_smoke"] 					= LoadFX("env/electrical/fx_elec_wire_sparks");

NUMBONES 30
BONE 0 -1 "tag_origin"
BONE 1 0 "tag_origin_animate_jnt"
BONE 2 1 "tag_body"
BONE 3 1 "tag_wheel_back_left"
BONE 4 1 "tag_wheel_back_right"
BONE 5 1 "tag_wheel_front_left"
BONE 6 1 "tag_wheel_front_right"
BONE 7 2 "body_animate_jnt"
BONE 8 5 "left_wheel_01_jnt"
BONE 9 3 "left_wheel_02_jnt"
BONE 10 6 "right_wheel_01_jnt"
BONE 11 4 "right_wheel_02_jnt"
BONE 12 7 "tag_brakelight_left"
BONE 13 7 "tag_brakelight_right"
BONE 14 7 "tag_detach"
BONE 15 7 "tag_driver"
BONE 16 7 "tag_engine"
BONE 17 7 "tag_exhaust_left"
BONE 18 7 "tag_exhaust_right"
BONE 19 7 "tag_front_door_left_jnt"
BONE 20 7 "tag_front_door_right_jnt"
BONE 21 7 "tag_headlight_left"
BONE 22 7 "tag_headlight_right"
BONE 23 7 "tag_parkinglight_left_f"
BONE 24 7 "tag_parkinglight_right_f"
BONE 25 7 "tag_passenger"
BONE 26 7 "tag_passenger2"
BONE 27 7 "tag_passenger3"
BONE 28 7 "tag_rear_door_left_jnt"
BONE 29 7 "tag_rear_door_right_jnt"

*/



//VO_ram_the_gate()
//{
//	level.btr anim_single( level.btr, "ram_the_bastards_woods");
//	wait(0.1);
//	level.btr anim_single( level.btr, "run_right_over");
//}
//
//end_chase_vo()
//{
//	level endon( "stop_chase_dialogue" );
//
//	level.btr anim_single( level.btr, "left_side");
//	wait( 0.20 );
//	level.btr anim_single( level.btr, "ram_him");
//	wait( 0.20 );
//	level.btr anim_single( level.btr, "stay_on_him");
//	wait( 0.20 );
//	level.btr anim_single( level.btr, "out_of_your_sight");
//	wait( 0.20 );
//	level.btr anim_single( level.btr, "haul_ass");
//	wait( 0.20 );
//	level.btr anim_single( level.btr, "off_the_road");
//}
//
//////////////////////////////////////////////////////////////////////////////////////////////
//// Event 14 Specific Utils
//////////////////////////////////////////////////////////////////////////////////////////////
//
//
////throw_gate_guys()
////{
////	gate_guys = simple_spawn( "spawner_gate_throw", ::setup_gate_guys );
////	array_thread( gate_guys, ::throw_gate_guy, direction );
////}
//
//setup_gate_guys()
//{
//	self endon( "death" );
//
//	self.goalradius = 16;
//	self.ignoreme = true;
//	self.ignoreall = true;
//	self.deathfunction = animscripts\utility::do_ragdoll_death;
//
//	goal_node = GetNode( self.target, "targetname" );
//	//self thread force_goal( goal_node, 64 );
//	self SetGoalNode( goal_node );
//	self waittill( "goal" );
//
//	wait( 5 );
//
//	self.goalradius = 2048;
//	self.ignoreme = false;
//	self.ignoreall = false;
//	self set_spawner_targets( "chase_uaz_nodes" );
//}
//
//throw_gate_guy( direction )
//{
//	self endon( "gate_is_locked" );
//	self waittill( "death" );
//
//	self.deathfunction = animscripts\utility::do_ragdoll_death;
//	self StartRagdoll();
////	self LaunchRagdoll( direction, "tag_eye" );
////	self die();
//}
//
//close_gate_until_hit() //-- self == the gate raises a notify when the gates are hit by the btr
//{
//	level endon("btr_hits_gate");
//
//	btr_open_gate = trigger_wait("btr_open_gate");
//	btr_open_gate Delete();	
//
//	level notify("btr_hits_gate");
//}
//
//btr_trig_start_group( _trigger_name, start_group, delay )
//{
//	trigger_wait( _trigger_name );
//	
//	if(IsDefined(delay))
//	{
//		wait(delay);
//	}
//	
//	array_thread( level.vehicle_StartMoveGroup[ start_group ], maps\_vehicle::gopath  );
//}
//
//spawned_ai_dont_move()
//{
//	self.goal_radius = 16;
//}
//
//unlimited_rpgs()
//{
//	if(!IsDefined(self.script_noteworthy) || self.script_noteworthy != "rpg_guy" )
//	{
//		return;
//	}
//	
//	self endon("death");
//	
//	while(IsAlive(self))
//	{
//		self.a.rockets = 10;
//		wait(1);
//	}
//}
//
//
//delete_aigroup_after_trigger( _aigroup_name, _trigger_name )
//{
//	trigger_wait( _trigger_name );
//	
//	ais = get_ai_group_ai( _aigroup_name );
//	array_delete(ais);
//	
//}
//
//
//struct_to_obj( _struct_name )
//{
//	struct = getstruct( _struct_name, "targetname" );
//	obj = Spawn( "script_model", struct.origin );
//	obj SetModel("tag_origin");
//	return obj;
//}
//
//btr_rumble_based_on_speed()
//{
//	level endon( "limo_crashing" );
//	
//	while(1)
//	{
//		current_speed_mph = Abs(level.btr GetSpeedMPH());
//		max_speed_mph = 45;
//
//		speed_percent = current_speed_mph / max_speed_mph;
//		
//		if( speed_percent > 0.9)
//		{
//			level.player PlayRumbleOnEntity( "damage_heavy" );
//			wait(0.1);	
//		}
//		else if(speed_percent > 0.95)
//		{
//			level.player PlayRumbleOnEntity( "damage_light" );
//			wait(0.1);	
//		}
//		else if(speed_percent > 0.5)
//		{
//			level.player PlayRumbleOnEntity( "reload_small" );
//			wait(0.1);
//		}
//		else
//		{
//			// else the player is going too slow so no rumble
//			wait(0.1);
//		}
//	}
//}

////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////