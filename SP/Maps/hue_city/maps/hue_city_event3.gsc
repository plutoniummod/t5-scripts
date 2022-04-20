#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_anim;
#include maps\_music;
#include maps\flamer_util;
#include maps\_hud_util;
#include maps\hue_city;
#include maps\_vehicle_turret_ai;
#include maps\hue_city_ai_spawnfuncs;

cleanup_street_ents()
{
	kill_spawnernum(1);
	wait(.05);
	kill_spawnernum(2);
	wait(.05);
	kill_spawnernum(3);
	wait(.05);
	kill_spawnernum(4);
	wait(.05);
	kill_spawnernum(5);
	wait(.05);
	kill_spawnernum(2001);
	wait(.05);
	kill_spawnernum(2002);
	wait(.05);
	//kill_spawnernum(3000);
	kill_spawnernum(3001);
	wait(.05);
	maps\hue_city_event2::delete_chopper_volume_stuff();
	wait(.05);
	maps\hue_city_event2::cleanup_macv_ents();
}

event3_start()
{
	kill_spawnernum(3004);
	tp_to_start("e3");
	cleanup_street_ents();
	
	battlechatter_on();
	
	/*
	boat = getstructent("end_save_boat", "targetname", "t5_veh_boat_pbr_sugarfree");
	//boatdeck = spawn_a_model("t5_veh_boat_pbr_set01", boat.origin, boat.angles);
	//boatdeck LinkTo(boat);
	pbr_guys(boat);
	nextspot = getstruct("boat_drift_spot", "targetname");
	boat moveto (nextspot.origin, 3, 0, 1);
	boat RotateTo (nextspot.angles, 3, 0, 1);
	trigger_wait("player_jumpting_to_boat");
	level thread maps\hue_city_anim::jumpto_boat(boat);
	wait 99;
	*/	
	
	//THE CLIPS NEAR THE AA GUN WHEN IT FALLS DOWN
	aa_gun_clips = GetEntArray("alley_falling_ceiling_d", "targetname");
	for(i=0;i<aa_gun_clips.size;i++)
	{
		aa_gun_clips[i] connectpaths();
		aa_gun_clips[i] trigger_off();
	}
	
	trig = GetEnt("near_claymore_trig", "targetname");
	Objective_Add(1, "done", &"HUE_CITY_OBJ_1",  trig.origin+(0,0,100) );
	Objective_Add(2, "active", &"HUE_CITY_OBJ_2B",  trig.origin+(0,0,100) );
			
	level.player GiveWeapon("commando_sp");
	level.player SwitchToWeapon("commando_sp");
	
	trigger_use("e3_skipto_aagun_spawner");
	trigger_use("e3_skipto_tank_spawner");
	trigger_use("e3_skipto_skydemon_spawner");
	//level thread maps\hue_city_event2::save_loop();

	wait 0.3;
	level thread notify_delay ("stop_alley_tank_fire_loop", 1.5);
	level thread notify_delay ("stop_alley_tank_fire_loop", 12.5);
		
	tank = GetEnt("alley_tank", "targetname");
	tank AttachPath(GetVehicleNode("alley_tank_final_node", "script_noteworthy"));
	flag_set("alleytank_at_end");

	maps\hue_city_event2::aagun_fall();

	level.skydemon thread fill_huey_with_script_models("event2_over");


	level thread event3();
}

event3b_start()
{
	tp_to_start("e3b", "e3");
	cleanup_street_ents();
	battlechatter_on();
	
	trigger_use("d_allies_1", "target");
	//trigger_use("friendly_reinforcements", "script_noteworthy");
	level thread clear_ai_back_in_city();


	level thread c4_pickup_station();
	level thread claymore_pickup_station();
	level thread rpg_timing();
	level thread blow_defend_gates();
	level thread event3_dialogue();

	level thread event3_flow();
	wait 0.5;

	level thread e3_spawner_wave_flow();

	clip = GetEnt("defend_chopper_clip", "targetname");
	clip ConnectPaths();
	clip Delete();


}
	
event3c_start()
{
	tp_to_start("e3b", "e3");
	cleanup_street_ents();
	battlechatter_on();
	level.skipto = "e3c";
	
	//level.player GiveWeapon("commando_acog_sp");	
	

	level thread clear_ai_back_in_city();
	level thread blow_defend_gates();
	level thread event3_dialogue();
//	
//	level._first_wave_through_smoke_guys = 0;
//	level._attackers_chasing_player = 0;
//	level._last_side_warning_in_seconds = 0;
//	level._mortar_enemies_called = 0;
//	
//	wait 1;
	level thread heroes_runto_boat();
//	
	wait 1;
//	
	GetEnt("defend_tank_ishere", "targetname") UseBy (level.player);
//
	flag_set("wave2_timer_done");
//	
//	flag_wait("saying_direct_fire_support");
//	wait 1.5;
///	autosave_by_name("bomber_support_ready");
//	
	flag_set("bomber_support_ready");
	level.player thread maps\_chopper_support::use_air_support();
//	
	level waittill ("final_airstrike_called");
//	
	//level.player.ignoreme = true;
//	
//	
	level thread objective_control(7);
	level thread get_to_boat_display();
	GetEnt("player_running_to_boat_trig", "targetname") trigger_on();
	
	level waittill ("building_fallover_now");
	
	
	Earthquake (0.6, 1, level.player.origin, 5000);

}	

event3()
{
	
	trig = GetEnt("e3_start_trig", "targetname");
	if (!IsDefined(trig))
	{
		return;
	}
	level.woods set_force_color("r");
			// cleanup
	trigger_use("e3_start_trig");  // just cleans up allied spawners in E2 and color chain

	event3_cleanup();	
	
	level.bowman enable_ai_color();
	squad_to_e3_startspots();
	
	
	level thread landing_zone();
	level thread blow_defend_gates();
	level thread rpg_timing();
	level thread event3_dialogue();
	//level thread allies_crouch_near_chopper();
//	level.player thread keep_commando_acog();
	
	flag_set("doing_defend_color_chains");
	
	clip = GetEnt("defend_split_ai_pathing_clip", "targetname");
	clip trigger_on();
	wait 0.05;
	clip DisconnectPaths();
	wait 20;
	clip ConnectPaths();
	clip Delete();

	
}

squad_to_e3_startspots()
{
	allies = GetAIArray("allies");
	spot = undefined;
	spots = getstructarray("redshirt_defend_warp_spot", "targetname");
	counter = 0;
	for (i=0; i < allies.size; i++)
	{
		if (allies[i] == level.bowman)
		{
			spot = getstruct("bowman_defend_warp_spot", "targetname");
			allies[i] forceteleport( spot.origin, spot.angles);
			continue;
		}
		if (allies[i] == level.woods)
		{
			spot = getstruct("woods_defend_warp_spot", "targetname");
			allies[i] forceteleport( spot.origin, spot.angles);
			continue;
		}
		if (allies[i] == level.reznov)
		{
			continue;
		}
		spot = spots[counter];
		allies[i] forceteleport( spot.origin, spot.angles);
		counter++;
	}
}

heroes_runto_boat()
{
	level notify ("heroes_to_boat");
	spot = getstruct("heroes_runto_boat_spot", "targetname");	
	keys = getArrayKeys( level.squad );
	for (i=0; i < keys.size; i++)
	{
		//level.squad[keys[i]].goalradius = 128;
		//level.squad[keys[i]] SetGoalPos(spot.origin);
	}
	
	wait 0.1;
	
	level waittill ("final_airstrike_called");
	boat_save();
}

event3_flow()
{
	//level thread decrease_respawner_count();
	
	level waittill ("mortar_guys_clear");
	
	//TUEY Set music state to DEFEND_PHASE_TWO
	setmusicstate ("DEFEND_PHASE_TWO");
	
	wait 5;
	level thread city_choppers_retreat();
	level thread audio_play_distant_roar();
	wait 6;
	level thread struct_spawn("helicopter_haters", ::helicopter_haters);
	
	wait 14;
	
	level thread audio_play_closer_roars();
	
	//wait 20;	

	level waittill ("spawn_tanks_soon");
	level thread heroes_runto_boat();
	
	level notify( "kill_color_replacements" );
	
//	spawners = shuffle_array(GetEntArray("mortar_spotter", "targetname"));
//	num_guys = RandomIntRange(1,3);
//	for (i=0; i < num_guys; i++)
//	{
//		spawners[i] StalingradSpawn();
//	}
//	wait 15;
//	
//	flag_clear("doing_defend_color_chains");
//	level thread mortar_color_chains(1);
//	
//	wait 15;

	//level thread pbr_here_dialogue(level.woods,level.player, level._extra, level.bowman, level.reznov);
	GetEnt("defend_tank_ishere", "targetname") UseBy (level.player);
	
	//wait(20);
	//level waittill ("wave2_timer_done");
	
	flag_wait("saying_direct_fire_support");
	wait 1.5;
	autosave_by_name("bomber_support_ready");
	
	flag_set("bomber_support_ready");
	level.player thread maps\_chopper_support::use_air_support();
	flag_set ("claymores_depeleted");	// dont want to take away air support and prog break
	
	level thread objective_control(6);
	level waittill ("final_airstrike_called");
	
	//TUey set music to RUN TO BOAT
	setmusicstate ("RUN_TO_BOAT");
	
	level thread boat_run_ignore_player();

	level thread objective_control(7);
	level thread get_to_boat_display();
	GetEnt("player_running_to_boat_trig", "targetname") trigger_on();
	
	level waittill ("building_fallover_now");
	
	Earthquake (0.6, 1, level.player.origin, 5000);
	
}	

boat_run_ignore_player()
{
	//trigger to base position off of
	safe_line = GetEnt("player_running_to_boat_trig","targetname");

	//while the player hasn't gotten on the boat
	while( !IsDefined(level.player_jumped_in_boat) )
	{
		//if player y is greater than the trigger y
		if(level.player.origin[1] > safe_line.origin[1])
		{
			//have the NVA ignore the player so he doesn't get shot in the back
			level.player.ignoreme = true;	
		}
		else
		{
			level.player.ignoreme = false;
		}

		wait(1.0);
	}
}

landing_zone()
{
	trigs1 = GetEntArray("first_d_chains", "script_noteworthy");
	trigs2 = GetEntArray("second_d_chains", "script_noteworthy");
	for (i=0; i < trigs1.size; i++)
	{
		trigs1[i] UseBy (get_players()[0]);
	}

	trigger_use("d_allies_1", "target");
	
	level thread create_defend_satchels();
	level thread create_defend_claymores();
	
	skydemon_land();
	
	level thread skydemon_takeoff();

	level thread c4_pickup_station();
	level thread claymore_pickup_station();

//	trigs1 = GetEntArray("first_d_chains", "script_noteworthy");
//	trigs2 = GetEntArray("second_d_chains", "script_noteworthy");
//	for (i=0; i < trigs1.size; i++)
//	{
//		trigs1[i] UseBy (get_players()[0]);
//	}

	wait 3;
	level thread objective_control(4);
	
	autosave_by_name("at_defend");
	
	level thread pre_wave1_control_1();
	
	wait 6;
	for (i=0; i < trigs2.size; i++)
	{
		trigs1[i] UseBy (level.player);
	}
	wait 5;

	flag_wait("defend_loudspeaker_started");
	
	level thread defend_satchels_glow("off");
	level thread defend_claymores_glow("off");

	level thread clear_ai_back_in_city();


	wait 7;
	//for (i=0; i < trigs1.size; i++)
	//{
	//	trigs1[i] UseBy (get_players()[0]);
	//}
	
	level thread stop_street_exploders();
	
	ent = spawn( "script_origin" , (500.8, -116.8, 7484) );
	ent thread fake_smoke_audio();
	delaythread(20, ::flag_set, "defend_wave1_smoke_fading");
	delaythread(28, ::flag_clear, "defend_wave1_smoke_fading");
	exploder(730); // smokescreen exploder
	
	GetEnt("e3_allies_defend_colors", "script_noteworthy") UseBy (level.player);
	wait 6;
	level thread e3_spawner_wave_flow();
	wait 2;

	level thread event3_flow();
	
	level.player.ignoreme = true;
	wait 15;
	level.player.ignoreme = false;
	wait 15;
	
}

//kevin adding fake smoke function
fake_smoke_audio()
{
	self playsound( "wpn_smoke_grenade_explode" , "sound_done" );
	self waittill( "sound_done" );
	self playloopsound( "wpn_smoke_hiss_lp" , .1 );
	wait 10;
	self stoploopsound(.1);
	self playsound( "wpn_smoke_hiss_end" , "sound_done" );
	self waittill( "sound_done" );
	self delete();
}

defend_timer()
{
	level endon ("next_defend_state");
	level._defend_phase_length = 0;
	while(1)
	{
		level._defend_phase_length++;
		wait 1;
	}
}

		// time and kill metric before continuing to next phase of defend
progress_to_next_state(weight_threshold, disable_spawn_managers)
{
	
	level thread defend_timer();
	level._attackers_killed_by_player = 0;
	
	while(1)
	{
		guys_killed_weight = level._attackers_killed_by_player *6;
		time_weight = level._defend_phase_length;
		
		total_weight = guys_killed_weight + time_weight;
		
		
		if (total_weight > weight_threshold)
		{
			level notify ("next_defend_state");
			break;
		}
		
		wait 1;
	}
	
	if (IsDefined(disable_spawn_managers))
	{
		flag_clear("street_sm_on");
		flag_clear("ruins_sm_on");
		flag_clear("dock_sm_on");
		flag_clear("defend_light_sm_on");	
	}	
}

skydemon_land()
{
	node = GetVehicleNode("skydemon_landed_node", "script_noteworthy");
	while( DistanceSquared(level.skydemon.origin, node.origin) > (200*200) )
	{
		wait 0.3;
	}
	
	spot = Spawn("script_origin", (3000, 424, 6726) );
	
	level.skydemon SetTurretTargetEnt( spot);
	level.skydemon SetgunnerTargetent( spot, (0,0,0), 0	);
	level.skydemon SetgunnerTargetent( spot, (0,0,0), 1 );
	
	stop_exploder(720);
	exploder(721);   // stop purple smoke , start flushing it away
	/*
	
	while(1)
	{
		if (level.player UseButtonPressed() )
		{
			spot.origin = spot.origin + (0,0,1);

		}
		if (level.player AttackButtonPressed() )
		{
			spot.origin = spot.origin + (0,0,-1);

		}
		wait 0.05;
	}		
	*/	
	
	trig = GetEnt("player_near_landed_skydemon", "targetname");
	while(!level.player IsTouching(trig))
	{
		wait 0.1;
	}
	exploder(723); // idle chopper effects
		// play animations of getting wounded on board
	flag_set("e3_player_near_leaving_chopper");
	spot Delete();
}

skydemon_takeoff()
{
	flag_wait("wounded_on_skydemon");
	
	mylookent = getstructent("chopper_defend_lookat_spot", "targetname");
	mylookent moveto (mylookent.origin + (-4000,5000,0), 10);

	delaythread( 1, ::stop_exploder, 723 );
	delaythread( 1, ::exploder, 724 );
	delaythread( 2, ::stop_exploder, 721 );
	delaythread( 3, ::exploder, 720 );

	struct = getstruct("chopper_defend_takeoff_struct", "targetname");
	level.skydemon 	SetVehGoalPos( struct.origin );
	level.skydemon SetLookAtEnt(mylookent);
	
	level.skydemon.goalradius = 25;
	myspeed = 20;
	level.skydemon SetSpeed(myspeed,10,10);
	
	wait 1.2;
	clip = GetEnt("defend_chopper_clip", "targetname");
	clip ConnectPaths();
	clip Delete();
	
	level.skydemon waittill ("goal");
	


	for (i=0; i < 6; i++)
	{
		struct = getstruct(struct.target, "targetname");
		level.skydemon 	SetVehGoalPos( struct.origin );
		level.skydemon.goalradius = 100;
		myspeed += 10;
		level.skydemon SetSpeed(myspeed,10,10);
		level.skydemon waittill ("goal");
	}

	level.skydemon Delete();
}

clear_ai_back_in_city()
{
	guys = GetAIArray();
	for (i=0; i < guys.size; i++)
	{
		if ( (guys[i].origin[0] < -1000 || guys[i].origin[1] < -2000) && !guys[i] is_hero() )
		{
			guys[i] killme();
			guys[i] Delete();
		}
	}
}

		// Turns a spawn manager with associated "side" on, clears a flag when completed
e3_spawner_wave_on(side)
{
	flag_set(side+"_sm_on");
	
	sm = GetEnt(side+"_sm_on", "targetname");
	sm._wave_guys_spawned = 0;
	spawn_manager_enable(sm.targetname);
	
	while( flag(side+"_sm_on") )
	{
		wait 0.2;
	}
	
	spawn_manager_disable(sm.targetname);
	
	sm thread clean_up_my_guys();

}

		// keeps a lighter spawn manager on until flag is cleared
e3_spawner_wave_on_light(side)
{
	flag_set("defend_light_sm_on");
	
	sm = GetEnt(side+"_light_sm_on", "targetname");
	spawn_manager_enable(sm.targetname);

	while(flag("defend_light_sm_on"))
	{
		wait 1;
	}
	
	spawn_manager_disable(sm.targetname);
	sm thread clean_up_my_guys(); 

}

e3_spawner_wave_flow()
{
	
	group = [];
	group[0] = "ruins";
	group[1] = "street";
	group[2] = "dock";
	
	for (i=0; i < group.size; i++)
	{
		//level thread friendly_chain_control(group[i]); // friendly chains respond to how far up enemies are
	}
	
	shuffledgroup = shuffle_array(group);
	
	level._attackers_chasing_player = 0;
	level._last_side_warning_in_seconds = 0;
	level._first_wave_through_smoke_guys = 0;
	level._mortar_enemies_called = 0;
	
	level thread safe_forced_save();
	
	level thread event3_threatbias_management();
	
			// do this unless we're in e3b skipto
	if ( !IsDefined(level.skipto) || ( IsDefined(level.skipto) && level.skipto != "e3b"))
	{
		level thread e3_spawner_wave_on("ruins");
		level thread e3_spawner_wave_on("street");
		
		flag_wait("ruins_sm_on");
		flag_wait("street_sm_on");
		
		flag_wait("defend_wave1_smoke_fading");
		progress_to_next_state(21, 1);
			
		level thread e3_spawner_wave_on(shuffledgroup[0]);
		level thread e3_spawner_wave_on_light(shuffledgroup[1]);
		progress_to_next_state(21, 1);
	
		autosave_by_name("defend_save2");
		
		//for (i=0; i < group.size; i++)	// turn on light spawners during mortars
		//{
		//	level thread e3_spawner_wave_on_light ( group[i] );
		//}
		//mortar_guys();
	}
	
	flag_set("mortar_guys_clear");
	flag_clear("defend_light_sm_on");		
	
	level.bowman line_please("they_retreating", 5);
	level.reznov line_please("not_retreating_regroup", 0.5);
	level thread second_wave_dialogue(level.woods, level.player, level._extra, level.bowman, level.reznov);
	
	autosave_by_name("defend_save3");
	wait 30;
	//level thread safe_forced_save();
	//wait 35;
	//flag_set("2nd_wave_on");
//	level thread wave2_timer();
//	autosave_by_name("defend_save5");
//	
//	
//	ent = spawn( "script_origin" , (500.8, -116.8, 7484) );
//	ent delaythread(10, ::fake_smoke_audio);
//	delaythread(20, ::flag_set, "defend_wave1_smoke_fading");
//	delaythread(28, ::flag_clear, "defend_wave1_smoke_fading");
//	delaythread(10, ::exploder,731); // smokescreen exploder
//	
//	
//	level thread delaythread( 15, ::spawn_manager_enable,"e3_building_sm");
//	
//	shuffledgroup = shuffle_array(group);
//	level thread e3_spawner_wave_on(shuffledgroup[0]);
//	level thread e3_spawner_wave_on_light(shuffledgroup[1]);	
//	level thread e3_spawner_wave_on_light(shuffledgroup[2]);	
//	progress_to_next_state(30, 1);
//
//	shuffledgroup = shuffle_array(group);
//	level thread e3_spawner_wave_on(shuffledgroup[0]);
//	level thread e3_spawner_wave_on_light(shuffledgroup[1]);	
//	level thread e3_spawner_wave_on_light(shuffledgroup[2]);	
//	progress_to_next_state(30, 1);
//	
//	level thread safe_forced_save();

	level notify("spawn_tanks_soon");
	
	shuffledgroup = shuffle_array(group);
	level thread e3_spawner_wave_on(shuffledgroup[0]);
	level thread e3_spawner_wave_on(shuffledgroup[1]);	
	level thread e3_spawner_wave_on_light(shuffledgroup[2]);	
	progress_to_next_state(30, 1);
	
	
	autosave_by_name("30sec_left_save");
	
	while(1)
	{
		level thread e3_spawner_wave_on(shuffledgroup[0]);
		level thread e3_spawner_wave_on(shuffledgroup[1]);	
		level thread e3_spawner_wave_on(shuffledgroup[2]);	
		progress_to_next_state(30, 1);
		
	}
}



//mortar_guys()
//{
//	level endon ("stop_mortar_guys");
//	spawners = GetEntArray("mortar_spotter", "targetname");
//	guyarray = [];
//	level._normals_killed_during_mortars = 0;
//	
//	level thread mortar_color_chains();
//	flag_clear("doing_defend_color_chains");
//	flag_set("mortar_guys_out");
//	for (i=0; i < 3; i++)
//	{
//		spawner = random_int_not_in_array(0, spawners.size, guyarray);
//		guyarray = array_add(guyarray, spawner);
//		
//		guy = undefined;
//		while(!IsDefined(guy))
//		{
//			guy = spawners[spawner] StalingradSpawn();
//			if (!spawn_failed(guy))
//			{
//				break;
//			}
//			wait 0.05;
//		}
//	}
//	
//	wait 3;
//	level thread mortar_guys_objective();
//	
//	while( get_ai_group_ai("mortar_spotters").size > 0)
//	{
//		if (level._normals_killed_during_mortars > 10)
//		{
//			level._normals_killed_during_mortars = 0;
//			get_ai_group_ai("mortar_spotters")[0] killme();
//		}
//		wait 0.5;
//	}
//	flag_clear("mortar_guys_out");
//	flag_set("doing_defend_color_chains");
//}

//mortar_guys_objective()
//{
//	wait 7;
//	level thread objective_control(5);
//	
//	first_location_callout = 10; // at 20 seconds
//	second_location_callout = 20; 
//	objective_marker_all = 30;
//	objective_marker_all_safety = 15;
//	objective_markers_set = 0;
//	
//	groupsize = 3;
//		
//	counter = 0;
//	
//				// for recruit make it easier
//	if ( level.gameskill == 0)
//	{
//		counter = objective_marker_all;
//	}
//	
//	while(flag("mortar_guys_out") )
//	{
//		counter++;
//		
//		if ( counter == first_location_callout )
//		{
//			get_ai_group_ai("mortar_spotters")[0] thread mortar_location_callout();
//		}
//		if ( counter == second_location_callout )
//		{
//			get_ai_group_ai("mortar_spotters")[0] thread mortar_location_callout(1);
//		}	
//		if ( counter >= objective_marker_all && objective_markers_set == 0 && !flag("acog_objective_active") )
//		{
//			objective_markers_set = 1;
//			guys = get_ai_group_ai("mortar_spotters");
//			Objective_Position(7,guys[0].origin + (0,0,70) );
//			Objective_Set3D ( 7, 1, "default", &"HUE_CITY_SPOTTER" );
//			
//			guys[0] thread mortar_guy_objective_remove(0);
//			
//			for (i=1; i < guys.size; i++)
//			{
//				Objective_AdditionalPosition( 7, i, guys[i].origin+(0,0,70) );
//				guys[i] thread mortar_guy_objective_remove(i);
//			}
//			
//			counter = 0;
//		}
//		
//		if (get_ai_group_ai("mortar_spotters").size < groupsize )
//		{
//			if (get_ai_group_ai("mortar_spotters").size == 2)
//			{
//				Objective_String(7,&"HUE_CITY_OBJ_7B");
//			}
//			if (get_ai_group_ai("mortar_spotters").size == 1)
//			{
//				Objective_String(7,&"HUE_CITY_OBJ_7C");
//			}
//			groupsize--;
//		}
//		if ( get_ai_group_ai("mortar_spotters").size == 3 && counter > objective_marker_all_safety) // if no spotters killed after 15 seconds
//		{
//			counter = objective_marker_all;
//		}
//			
//		wait 1;
//	}
//	wait 0.1;
//
//}

//mortar_guy_objective_remove(index)
//{
//	self waittill ("death");
//	Objective_AdditionalPosition( 7, index, (0,0,0) );
//}
//			
//mortar_location_callout(wave2)
//{
//	self endon ("death");
//	
//	weapons = level.player GetWeaponsList();
//	hascommando = false;
//	for (i=0; i < weapons.size; i++)
//	{
//		if (weapons[i] == "commando_acog_sp")
//		{
//			hascommando = true;
//		}
//	}
//	if (hascommando == false && !flag("said_grab_scoped") )
//	{
//		level thread acog_objective();
//		level.bowman line_please("grab_scoped_rifle");
//		flag_set("said_grab_scoped");
//		wait 3;
//	}
//	
//	
//	
//	if (IsDefined(wave2))
//	{
//		level.woods line_please("artillery!");
//	}
//	if (self.script_noteworthy == "roof_east")
//	{
//		level.woods line_please("to_east");
//
//	}
//	if (self.script_noteworthy == "roof_south")
//	{
//		level.woods line_please("coming_from_south");
//	}
//	if (self.script_noteworthy == "roof_northeast")
//	{
//		level.woods line_please("from_northeast");
//	}
//	if (!IsDefined(wave2))
//	{
//		if ( !flag("said_there_on_roof") )
//		{
//			level.reznov line_please("there_on_roof");
//			flag_set("said_there_on_roof");
//		}
//		else if ( !flag("said_need_take_out_spotters") )
//		{
//			level.bowman line_please("need_take_out_spotters");
//			flag_set("said_need_take_out_spotters");
//		}
//		else if (!flag("said_on_the_rooftop"))
//		{
//			level.woods line_please("on_the_rooftop");
//			flag_set("said_on_the_rooftop");
//		}
//	}
//}


airstrike_hit(time)
{
	if (IsDefined(time))
	{
		wait time;
	}
	PlayFX(level._effect["airstrike_hit"], self.origin);
	RadiusDamage(self.origin, 500, 5000, 100);
	Earthquake(0.6, 0.5, self.origin, 3000);
}

c4_pickup_station()
{
	level endon ("wave2_timer_done");
	trig = GetEnt("near_c4_trig", "targetname");
	//display = a_text_display("", undefined, 300,200);
	//display thread destroy_on_notify("satchels_depeleted", level);
	player = get_players()[0];
	
	level thread defend_satchels_glow("off");
	hint_string_shown = false;
		
	while(1)
	{
				
		if (level.player IsTouching(trig) )
		{
			if(!hint_string_shown)
			{
				player SetScriptHintString(&"HUE_CITY_TAKE_c4_FROM_STASH");
				hint_string_shown = true;
			}
			if (player UseButtonPressed() )	
			{
				if ( !level.player HasWeapon("satchel_charge_sp") || (level.player HasWeapon("satchel_charge_sp") && level.player GetWeaponAmmoStock ("satchel_charge_sp") < 4) )
				{
					take_satchels_from_top(2);
				}
				if ( (level.player HasWeapon("satchel_charge_sp") && level.player GetWeaponAmmoStock ("satchel_charge_sp") == 4) )
				{
					take_satchels_from_top(1);
				}
						
				if ( !level.player HasWeapon("satchel_charge_sp") )
				{
					//screen_message_create(&"HUE_CITY_C4_HINT_EQUIP");
					//level thread kill_c4_equip_hint();
					level thread notify_delay("satchel_charge_sp", 5);
					//level thread func_on_notify("c4_equipped", ::screen_message_delete);
					level thread c4_throw_hint();
					//level thread c4_ammo_glitch();
				}
			
				level notify ("c4_acquired");
				level.player GiveWeapon( "satchel_charge_sp" );
				level.player SetActionSlot( 1, "weapon", "satchel_charge_sp" );
				level.player SetWeaponAmmoStock("satchel_charge_sp",9);
				level.player SetWeaponAmmoClip("satchel_charge_sp",9);
				level.player SwitchToWeapon( "satchel_charge_sp" );
				
				player SetScriptHintString("");
				hint_string_shown = false;
				level thread defend_satchels_glow("off");
				
				wait 5;

				while( level.player UseButtonPressed() )
				{
					wait 0.1;
				}
			}
			
			weapList = level.player GetWeaponsListPrimaries();
			for (i=0; i < weapList.size; i++)
			{
				level.player GiveMaxAmmo(weapList[i]);
				if (flag("satchels_depeleted"))
				{
					return;
				}
			}
			
		}
		else
		{
			//only turn this off if the player is NOT standing in the claymore trig or this trig
			if( !player istouching(GetEnt("near_claymore_trig", "targetname")))
			{
				player SetScriptHintString("");
				hint_string_shown = false;
			}
			//player SetScriptHintString("");
			//hint_string_shown = false;

		}
		wait 0.2;
	}
}

//kill_c4_equip_hint()
//{
//	level endon ("c4_equipped");
//	while(1)
//	{
//		if ( level.player GetCurrentWeapon() == "satchel_charge_sp")
//		{
//			level notify ("c4_equipped");
//		}
//		wait 0.1;
//	}
//}
	
kill_c4_throw_hint()
{
	level endon ("c4_thrown");
	while(1)
	{
		if ( (level.player GetCurrentWeapon() == "satchel_charge_sp" && level.player ThrowButtonPressed() )
		 ||
		 	level.player GetCurrentWeapon() != "satchel_charge_sp" )
		{
			level notify ("c4_thrown");
		}
		wait 0.1;
	}
}

c4_throw_hint()
{
	level endon ("c4_thrown");
	while(level.player GetCurrentWeapon() != "satchel_charge_sp")
	{
		wait 0.1;
	}
	level thread kill_c4_throw_hint();
	wait 1;
	
	screen_message_create(&"HUE_CITY_C4_HINT_THROW");
	level thread notify_delay("c4_thrown", 5);
	level thread func_on_notify("c4_thrown", ::screen_message_delete);
}

//c4_ammo_glitch()
//{
//	wait 1;
//	while(1)
//	{
//		if (level.player GetCurrentWeapon() != "satchel_charge_sp"
//		&& level.player GetWeaponAmmoStock("satchel_charge_sp") == 0)
//		{
//			level.player SetWeaponAmmoStock("satchel_charge_sp", 1);
//			
//			while( level.player GetCurrentWeapon() != "satchel_charge_sp")
//			{
//				wait 0.2;
//			}
//			stock = level.player GetWeaponAmmoStock("satchel_charge_sp");
//			if (stock > 1)
//			{
//				continue;
//			}
//			level.player SetWeaponAmmoStock("satchel_charge_sp", 0);
//			level.player SetWeaponAmmoClip("satchel_charge_sp", 0);
//		}
//		wait 0.4;
//	}
//}


claymore_pickup_station()
{
	level endon ("wave2_timer_done");
	trig = GetEnt("near_claymore_trig", "targetname");
	//display = a_text_display("", undefined, 300,200);
	//display thread destroy_on_notify("claymores_depeleted", level);
	
	level thread defend_claymores_glow("off");
	player = get_players()[0];
	hint_string_shown = false;
		
	while(1)
	{
		if (level.player IsTouching(trig) )
		{
			if(!hint_string_shown)
			{
				player SetScriptHintString(&"HUE_CITY_TAKE_CLAYMORE_FROM_STASH");
				hint_string_shown = true;
			}		
			
			if (player UseButtonPressed() )	
			{
				if ( !level.player HasWeapon("claymore_sp") || (level.player HasWeapon("claymore_sp") && level.player GetWeaponAmmoStock ("claymore_sp") < 4) )
				{
					take_claymores_from_top(2);
				}
				if ( (level.player HasWeapon("claymore_sp") && level.player GetWeaponAmmoStock ("claymore_sp") == 4) )
				{
					take_claymores_from_top(1);
				}
				
				if ( !level.player HasWeapon("claymore_sp") )
				{
					//screen_message_create(&"HUE_CITY_CLAYMORE_HINT_EQUIP");
					//level thread kill_claymore_equip_hint();
					level thread notify_delay("claymore_equipped", 5);
					//level thread func_on_notify("claymore_equipped", ::screen_message_delete);
					level thread claymore_throw_hint();
				}
			
				level notify ("claymore_acquired");
				level.player GiveWeapon( "claymore_sp" );
				level.player SetActionSlot( 4, "weapon", "claymore_sp" );
				level.player SetWeaponAmmoStock("claymore_sp",9);
				level.player SetWeaponAmmoClip("claymore_sp",9);
				level.player SwitchToWeapon( "claymore_sp" );
				
				level thread defend_claymores_glow("off");
				player SetScriptHintString("");
				hint_string_shown = false;
								
				wait 5;

				while( level.player UseButtonPressed() )
				{
					wait 0.1;
				}
			}
			
			weapList = level.player GetWeaponsListPrimaries();
			for (i=0; i < weapList.size; i++)
			{
				level.player GiveMaxAmmo(weapList[i]);
				if (flag("claymores_depeleted"))
				{
					return;
				}
			}
			
		}
		else
		{
			//only turn this off if the player is NOT standing in the c4 trig or this trig
			if( !player istouching(GetEnt("near_c4_trig", "targetname")))
			{
				player SetScriptHintString("");
				hint_string_shown = false;
			}
		}
		wait 0.2;
	}
}

//kill_claymore_equip_hint()
//{
//	level endon ("claymore_equipped");
//	while(1)
//	{
//		if ( level.player GetCurrentWeapon() == "claymore_sp")
//		{
//			level notify ("claymore_equipped");
//		}
//		wait 0.1;
//	}
//}
//	
kill_claymore_throw_hint()
{
	level endon ("claymore_thrown");
	while(1)
	{
		if ( (level.player GetCurrentWeapon() == "claymore_sp" && level.player AttackButtonPressed() )
		 ||
		 	level.player GetCurrentWeapon() != "claymore_sp" )
		{
			level notify ("claymore_thrown");
		}
		wait 0.1;
	}
}

claymore_throw_hint()
{
	level endon ("claymore_thrown");
	while(level.player GetCurrentWeapon() != "claymore_sp")
	{
		wait 0.1;
	}
	level thread kill_claymore_throw_hint();
	wait 1;
	
	screen_message_create(&"HUE_CITY_CLAYMORE_HINT_THROW");
	level thread notify_delay("claymore_thrown", 5);
	level thread func_on_notify("claymore_thrown", ::screen_message_delete);
}

event3_cleanup()
{
	GetEnt("alley_respawn_trigger", "script_noteworthy") Delete();
	GetEnt("chopper_move_out", "script_noteworthy") Delete();
	GetEnt("midstreet_friendly_respawn", "script_noteworthy") Delete();
	guys = GetAIArray("axis");
	for (i=0; i < guys.size; i++)
	{
		guys[i] Delete();
	}
}

clean_up_my_guys() // deletes live AI from this spawner_manager
{
	myguys = get_ai_group_ai(self.targetname+"_guys");
	for (i=0; i < myguys.size; i++)
	{
		if (!flag("2nd_wave_on"))
		{
			myguys[i] notify ("defend_wave_retreating");
			myguys[i] SetGoalPos(myguys[i]._my_spawn_origin);
		}
		//myguys[i].ignoreall = true;
		myguys[i] thread wait_and_kill(RandomFloat(10) );
	}
}

city_choppers_retreat()
{

	level thread maps\hue_city_event2::street_chopper_group( (15000,15000,0), "city_retreat_choppers", 33);
	wait 5;
	trigger_use("escape_chopper_vehicle_trig");
	flag_set("retreat_choppers_flyover");
	wait 0.5;
	trigger_use("escape_chopper_vehicle_trig2");
	delaythread(12, ::exploder, 753);
}

e3_call_the_jets()
{

}

boat_save()
{
	boat = getstructent("end_save_boat", "targetname", "t5_veh_boat_pbr_sugarfree");
	//boatdeck = spawn_a_model("t5_veh_boat_pbr_set01", boat.origin, boat.angles);
	//boatdeck LinkTo(boat);
	pbr_guys(boat);
	
	level thread woods_dock_behavior();
	
	pickupspot = getstruct("boat_pickup_spot", "targetname");
	
	boat moveto(pickupspot.origin, 5,0,2);
	boat RotateTo(pickupspot.angles,5,0,2);
	
	boat waittill ("movedone");
	flag_wait("player_running_to_boat");
	level.player thread magic_bullet_shield();
	
	nextspot = getstruct("boat_drift_spot", "targetname");
	boat moveto (nextspot.origin, 3, 0, 1);
	boat RotateTo (nextspot.angles, 3, 0, 1);
	
	trigger_wait("nearboat_hide_weapons");
	level.player DisableWeapons();
		
	ai = GetAIArray("allies");
	for (i=0; i < ai.size; i++)
	{
		if (!ai[i] is_hero() )
		{
			ai[i] killme();
		}

	}
		
	trigger_wait("player_jumpting_to_boat");

	//player did not make it before the countdown ended
	if( IsDefined(level.player_jumped_in_boat) && !level.player_jumped_in_boat )
	{
		return;
	}

	level.player_jumped_in_boat = true;
	level thread maps\hue_city_anim::jumpto_boat(boat);
	level thread objective_control(8);
	
	wait 2.15;
	flag_set("player_in_boat");

	get_players()[0] thread magic_bullet_shield();
	
	clip = GetEnt("boat_phys_clip", "targetname");
	clip trigger_on();
	clip LinkTo(boat);
	
	
	wait 1.2;
	SetTimeScale (0.1);
	wait 0.3;
	SetTimeScale (1);
	playsoundatposition( "evt_num_num_02_r" , (0,0,0) );
	wait 6;
	
	
	level clientnotify( "fdo" );
	
	bg = NewHudElem(); 
	bg.x = 0; 
	bg.y = 0; 
	bg.horzAlign = "fullscreen"; 
	bg.vertAlign = "fullscreen"; 
	bg.foreground = true; 
	bg SetShader( "black", 640, 480 ); 
	bg.alpha = 0;
	bg FadeOverTime( 3);
	bg.alpha = 1; 
	wait 12;

	nextmission();
}

get_to_boat_display()
{
	flag_wait("get_people_back_said");
	
	hud1_xpos = 312;
	hud1_ypos = 30;
			
	hud2_xpos = 356;
	hud2_ypos = 55;
			
	hud1_flashrate = 0.5;
	hud1_scale = 1.9;
	hud2_scale = 1.5;
	
	text_display(&"HUE_CITY_GET_TO_BOAT", undefined, hud1_xpos,hud1_ypos,"player_in_boat", hud1_scale, hud1_flashrate );
	starttime = 200;
	mytimer = a_text_display(starttime, undefined, hud2_xpos,hud2_ypos, undefined, hud2_scale);
	while(starttime > 0 && !flag("player_in_boat"))
	{
		wait 0.1;
		if(isDefined(level.player_jumped_in_boat))
		{
			if(isDefined(mytimer))
			{
				mytimer Destroy();
			}
			continue;
		}
		starttime -= 1;
		truetime = starttime / 10;
		if ( is_int_in_range( truetime, 30 ) )
			mytimer SetText(truetime+".0");
		else
			mytimer SetText(truetime);			
	}
	
	if(isDefined(mytimer))
	{
		mytimer Destroy();
	}

	//give the player a little extra breathing room
	wait(1);
	
	if (flag("player_in_boat"))
	{
		return;
	}
	
	//level notify ("player_in_boat");
	
	level.player_jumped_in_boat = false;

 	level notify ("building_fallover_now");
	spots = getstructarray("defend_bombingrun", "targetname");
	
	//kevin adding airstrike sound
	maps\_dds::dds_disable( "allies" );
	playsoundatposition( "evt_final_airstrike2f" , (0,0,0) );
	
	exploder(800);
	
	ai = GetAIArray("axis");
	
	for (i=0; i < ai.size; i++)
	{
		ai[i] thread maps\_chopper_support::launch_me_baby();
	}
	
	//level waittill ("building_fallover_now");
	if(isDefined(level.player.magic_bullet_shield))
	{
		level.player stop_magic_bullet_shield();	
	}	
	setdvar( "ui_deadquote", &"HUE_CITY_ESCAPE_FAILED" );
	missionFailedWrapper();	
}

woods_dock_behavior(woodspot)
{

	startnode = GetNode("woods_dock_node", "targetname");
	endnode = GetNode("end_dock_node", "targetname");
	
	level.woods disable_ai_color();
	level.woods.goalradius = 16;
	level.woods thread force_goal(startnode);
	level.woods.perfectaim = 1;
	
	flag_wait("final_airstrike_called");
	
	looktrig = GetEnt("woods_dock_lookat_trig", "targetname");
	docktrig = GetEnt("player_running_to_boat_trig", "targetname");
	
	looktrig thread notify_on_trigger("woods_run_to_half_dock");
	docktrig thread notify_on_trigger("woods_run_to_half_dock");
	
	level thread send_allies_here(endnode);
	

	
	
	level waittill ("woods_run_to_half_dock");
	level.woods.ignoreall = true;
	level.woods disable_pain();
	
	halfnode = GetNode("woods_halfway_dock_node", "targetname");
	level.woods thread force_goal(halfnode);
	
	wait 2;
	level.woods.ignoreall = false;
	flag_wait("player_running_to_boat");
	level.woods.ignoreall = true;
	lastnode = GetNode("woods_jumpfrom_dock_node", "targetname");
	
	reznode = GetNode("reznov_jumpfrom_dock_node", "targetname");
	bownode = GetNode("bowman_jumpfrom_dock_node", "targetname"); 
	
	level.reznov thread force_goal(reznode);
	level.bowman thread force_goal(bownode);
	
}

decrease_respawner_count()
{
	level endon( "kill_color_replacements" );
	counter = 0;
	amount_killed = 0;
	while(1)
	{
		wait 1;
		counter++;
		if (amount_killed > 3)
		{
			flag_wait("mortar_guys_clear");
		}
		 
		if (counter == 30 && amount_killed < 5 )
		{
			ai = GetAIArray("allies");
			for (i=0; i < ai.size; i++)
			{
				if (ai[i] != level.woods && ai[i] != level.bowman && ai[i] != level.reznov && IsDefined(ai[i].replace_on_death ) )
				{
					ai [i] disable_replace_on_death();
					counter = 0;
					amount_killed++;
					break;
				}
			}
		}
	}
}


shoot_retreat_chopper_down()
{
	self SetSpeed(27);
	node = getvehiclenode("retreat_chopper_rpg_shotnode", "script_noteworthy");
	node waittill ("trigger");
	self ResumeSpeed(25);
	
	node2 = GetVehicleNode(node.target, "targetname");
	
	shotspot = getstruct("retreat_chopper_rpg_shotspot", "targetname").origin;
	hitspot = node2.origin+ (0,0,-50);
	magicbullet("rpg_sp", shotspot,hitspot );
	wait 0.66;
	self PlaySound( "evt_defend_heli_crash" );
	earthquake(0.8, 1, self.origin, 4000);
	PlayFXOnTag(level._effect["chopper_burning"], self, "tag_origin");
	
	node = getvehiclenode("end_node", "script_noteworthy");
	node waittill ("trigger");
	Earthquake(0.9, 1.5, self.origin, 6000);
	level.player PlayRumbleOnEntity("explosion_generic");
	
	playsoundatposition( "exp_mortar_dirt", self.origin );
	self Delete();
}


defend_chopper_targetting()
{
	
	
		spot = spawn_a_model("tag_origin", self GetTagOrigin("tag_flash_gunner4"), self GetTagAngles("tag_flash_gunner4")  );
	spot RotatePitch(52, 0.05);
	spot waittill ("rotatedone");

	vec = spot.angles;
	
	spot.origin = vec;
	spot LinkTo (self);
	spot2 = spawn_a_model("tag_origin", spot.origin);
	spot2 LinkTo(spot);
	
	self setgunnertargetent(spot2, (0,0,0), 3);
	while(IsAlive(self))
	{
		offset = random_offset(5000, 5000, 2, 1000,1000,0);
		spot2 LinkTo (spot, "tag_origin", offset);
		wait 1;
	}
	spot2 Delete();
	spot Delete();
	
}
	

defend_escape_spotlights()
{
	self thread defend_chopper_targetting();
	wait 0.1;
	spot = spawn_a_model("tag_origin", self GetTagOrigin("tag_flash_gunner4"), self GetTagAngles("tag_flash_gunner4") );
	spot LinkTo (self, "tag_flash_gunner4");
	PlayFXOnTag(level._effect["spotlightd"],spot, "tag_origin");
	
	targetspot = spawn_a_model("tag_origin", (0,0,0) );
	PlayFXOnTag(level._effect["spotlightd_target"],targetspot, "tag_origin");
	
	
	while(IsAlive(self) )
	{
		direction = spot.angles;
		direction_vec = anglesToForward( direction );
		org = spot.origin;
		
		// offset 2 units on the Z to fix the bug where it would drop through the ground sometimes
		trace = bullettrace( org, org + vector_multiply( direction_vec , 10000 ), 0, undefined );
		//trace2 = bullettrace(  trace["position"]+(0,0,2),  trace["position"], 0, level.player );
		
		// debug		
		//thread draw_line_for_time( eye, trace2["position"], 1, 0, 0, 0.05 );
		
		targetspot.origin = trace["position"];
		wait 0.05;
	}
	
	spot Delete();
}
defend_retreat_choppers_setup()
{
		self thread fill_huey_with_script_models();
		
		if (IsDefined(self.script_noteworthy) && self.script_noteworthy == "defend_retreat_custom")
		{
			self thread shoot_retreat_chopper_down();
			return;
		}
		if (IsDefined(self.script_noteworthy) && self.script_noteworthy == "spotlight_on")
		{
			self thread defend_escape_spotlights();
			self thread enable_turret(2);
		}
		if (IsDefined(self.script_noteworthy) && is_part_of_name(self.script_noteworthy, "defend_evasive") )
		{
			return;
		}

		node = GetVehicleNode(self.target, "targetname");
		self AttachPath(node);
		spot = getstruct(node.target, "targetname");
		self SetSpeed(30,35,35);
		if (IsDefined(node.script_int))
		{
			self SetSpeed(node.script_int,50,50);
		}
		
		while( IsDefined(spot) )
		{
			//self.goalradius = 2000;
			//self.goalheight = 10000;
			self SetNearGoalNotifyDist( 700 );
			self SetVehGoalPos(spot.origin);
			self waittill_any ("goal", "near_goal");
			if (!IsDefined(spot.target))
			{
				spot = undefined;
			}
			else
				spot = getstruct(spot.target, "targetname");
		}
		self Delete();
}


wave2_timer()
{
	//text_display(&"HUE_CITY_EXTRACTION_IN", undefined, 250,15,"bomber_support_ready" );
	
	starttime = 0;
	minutes = 2;
	//minutestimer = a_text_display(minutes, undefined, 325,15, "bomber_support_ready");
	//mytimer = a_text_display(starttime, undefined, 332,15, "bomber_support_ready");
	
	while(!flag("player_in_boat") )
	{
		starttime -= 1;
		if (starttime < 0)
		{
			starttime = 59;
			minutes--;
			if (minutes == -1)
			{
				break;
			}
			//minutestimer SetText(minutes);
		}
		
		//mytimer SetText(":"+starttime);
		if (starttime < 10)
		{
			//mytimer SetText(":0"+starttime);
		}
		wait 1;
	}
	flag_set("wave2_timer_done");
}

create_defend_satchels()
{
	structs = getstructarray("defend_satchels", "script_noteworthy");
	for (i=0; i < structs.size; i++)
	{
		newsatchel = Spawn_a_model("weapon_c4", structs[i].origin, structs[i].angles);
		newsatchel.targetname = "defend_satchel_models";
	}
}

create_defend_claymores()
{
	structs = getstructarray("defend_claymores", "script_noteworthy");
	for (i=0; i < structs.size; i++)
	{
		newsatchel = Spawn_a_model("weapon_claymore", structs[i].origin, structs[i].angles);
		newsatchel.targetname = "defend_claymore_models";
	}
}

defend_claymores_glow(state)
{
	if (state == "on")
	{
		satchels = GetEntArray("defend_claymore_models", "targetname");
		for (i=0; i < satchels.size; i++)
		{
			satchels[i] SetModel("weapon_claymore_objective");
		}
	}
	if (state == "off")
	{
		satchels = GetEntArray("defend_claymore_models", "targetname");
		for (i=0; i < satchels.size; i++)
		{
			satchels[i] SetModel("weapon_claymore");
		}
	}
}

defend_satchels_glow(state)
{
	if (state == "on")
	{
		satchels = GetEntArray("defend_satchel_models", "targetname");
		for (i=0; i < satchels.size; i++)
		{
			satchels[i] SetModel("weapon_c4_obj");
		}
	}
	if (state == "off")
	{
		satchels = GetEntArray("defend_satchel_models", "targetname");
		for (i=0; i < satchels.size; i++)
		{
			satchels[i] SetModel("weapon_c4");
		}
	}
}


take_satchels_from_top(amount)
{
	satchels = GetEntArray("defend_satchel_models", "targetname");
	satchels = sort_high_to_low(satchels);
	
	if (satchels.size < amount)
	{
		amount = satchels.size;	
	}
	
	for (i=0; i < amount; i++)
	{
		satchels[i] Delete();
	}
	
	satchels = GetEntArray("defend_satchel_models", "targetname");
	if (satchels.size == 0)
	{
		flag_set("satchels_depeleted");
	}
}

take_claymores_from_top(amount)
{
	claymores = GetEntArray("defend_claymore_models", "targetname");
	claymores = sort_high_to_low(claymores);
	
	if (claymores.size < amount)
	{
		amount = claymores.size;	
	}
	
	for (i=0; i < amount; i++)
	{
		claymores[i] Delete();
	}
	
	claymores = GetEntArray("defend_claymore_models", "targetname");
	if (claymores.size == 0)
	{
		flag_set("claymores_depeleted");
	}
}

rpg_timing()
{
	trigger_wait("escape_chopper_vehicle_trig");
	
	wait 4;
	rpgspot1 = getstruct("chop_retreat_rpgspot_1", "targetname").origin;
	hitspot1 = getstruct("chop_retreat_hitspot_1", "targetname").origin;
	MagicBullet("rpg_sp", rpgspot1, hitspot1);
	level thread fakeaa_fire_chase();
	
	wait 3.2;
	rpgspot2 = getstruct("chop_retreat_rpgspot_2", "targetname").origin;
	hitspot2 = getstruct("chop_retreat_hitspot_2", "targetname").origin;
	MagicBullet("rpg_sp", rpgspot2, hitspot2);
	
	
	wait 5.5;
	rpgspot3 = getstruct("chop_retreat_rpgspot_3", "targetname").origin;
	hitspot3 = getstruct("chop_retreat_hitspot_3", "targetname").origin;
	MagicBullet("rpg_sp", rpgspot3, hitspot3);
}
	
	
fakeaa_fire_chase()
{
	chopper = GetEnt("defend_evasive_1", "script_noteworthy");
	shotspot = getstruct("chop_retreat_fakeaa_shotspot", "targetname").origin;
	
	for (i=0; i < 100; i++)
	{
		spot = chopper GetTagOrigin("tail_rotor_jnt") + (0,0,150);
		nvec = VectorNormalize(spot - shotspot);
		spot2 = spot+(nvec*2000);
		
		MagicBullet("zpu_turret", shotspot, spot2);
		BulletTracer( shotspot, spot2, 1);
		wait 0.1;
	}
}

blow_defend_gates()
{
	level waittill ("blow_defend_gates");
	rightgate = GetEnt("defend_gate_right", "targetname");
	leftgate = GetEnt("defend_gate_left", "targetname");
	rightgate ConnectPaths();
	leftgate ConnectPaths();
	
	
	exploder(780); // gate blow
	Earthquake (0.6, 1.5, rightgate.origin, 2000);
	
	rightgate moveto (rightgate.origin+(1000, 4000, 1500), 2);
	leftgate moveto (leftgate.origin+(-1000, 4000, 1500), 2);
	
	rightgate RotateYaw(135, 2);
	rightgate RotatePitch(135, 2);
	rightgate RotateRoll(135, 2);
	leftgate RotateYaw(135, 2);
	leftgate RotatePitch(135, 2);
	leftgate RotateRoll(135, 2);
	
	wait 2;
	rightgate Delete();
	leftgate Delete();
}

send_allies_here(place)
{
	allies = GetAIArray("allies");
	for (i=0; i < allies.size; i++)
	{
		if (!allies[i] is_hero() )
		{
			if (isvec(place))
			{
				allies[i] thread force_goal(place, 16);
				allies[i] thread kill_allies_near_dock(place);
			}
			else
			{
				allies[i] thread force_goal(place.origin, 16);
				allies[i] thread kill_allies_near_dock(place.origin);
			}
		}
	}
}	
	
event3_threatbias_management()
{
	if ( is_hard_mode() )
	{
		return;
	}
	
	starting_threatbias = 5000;
	for (i=0; i < 12; i++)
	{
		wait 21;
		if (level.gameskill == 1)
		{
			set_generic_threatbias( starting_threatbias-(i*400) );
		}
	}
}

event3_dialogue()
{
	if (!IsDefined(level._lines_being_spoken))
	{
		level._lines_being_spoken = 0;
	}
	
	wait 1;
	
	woods = level.woods;
	woods.animname = "woods";
	
	bowman = level.bowman;
	bowman.animname = "bowman";
	
	player = level.player;
	player.animname = "mason";
	
	reznov = level.reznov;
	
	if (!IsDefined(level._extra))
	{
		level._extra = Spawn("script_origin", level.player.origin );
	}
	extra = level._extra;
	extra LinkTo (level.player);
	extra.targetname = "extra_voiceover";
	
	
	if ( !IsDefined(level.skipto) || ( (IsDefined(level.skipto) && level.skipto != "e3b") && (IsDefined(level.skipto) && level.skipto != "e3c") ) )
	{
		woods line_please("theres_our_ride", 1, "ready_for_defend");
		player line_please("not_so_sure");
		
		extra line_please("get_wounded_first", 0, "e3_player_near_leaving_chopper");
		extra line_please("more_birds_on_way"); 
		extra line_please("air_support_offline", 2);
		woods line_please("we_gotta_wait", 1);
		woods line_please("mason_set_up_charges");
		
		level.woods line_please("get_wounded_first", 0, "e3_player_near_leaving_chopper");
		level.woods line_please("more_birds_on_way");
		
		//extra Unlink();
		//loudspeaker_struct = getstruct("loudspeaker_struct", "targetname");
		//extra.origin = loudspeaker_struct.origin;
		
		extra line_please("loudspeaker_squak3", 0, "defend_loudspeaker_started"); // 
		extra line_please("loudspeaker_squak4");
		extra line_please("loudspeaker_squak2");
		
		level.woods line_please("here_they_come", 0.35);
		
		extra line_please("loudspeaker_squak5");
		extra line_please("loudspeaker_squak6");
		extra line_please("loudspeaker_squak7");
		
	//	level.woods line_please("artillery!", 9,	"mortar_guys_out");
		
	//	level.woods line_please("take_out_spotters", 1.5);
		
		//bowman line_please("they_retreating", 5, "mortar_guys_clear");
		//reznov line_please("not_retreating_regroup", 0.5);
	}
	
	//second_wave_dialogue(woods, player, extra, bowman, reznov);
}
	
	
second_wave_dialogue(woods, player, extra, bowman, reznov)
{
	if ( !IsDefined(level.skipto) || (IsDefined(level.skipto) && level.skipto != "e3c")  )
	{
		//extra.origin = level.player GetEye();
		//extra LinkTo (level.player);
		
		woods line_please("command_this_is_sog", 2, "retreat_choppers_flyover");
		woods line_please("praririe_fire");
		extra line_please("citys_falling");
		woods line_please("priority_one");
		extra line_please("find_another_way");
//		extra line_please("trying_to_wrangle", 1);
	
		extra Unlink();
		//loudspeaker_struct = getstruct("loudspeaker_struct", "targetname");
		//extra.origin = loudspeaker_struct.origin;
		
		extra line_please("american_soldiers");
		
		//extra.origin = level.player GetEye();
		//extra LinkTo (level.player);
		
		extra line_please("evac_on_way");
		//extra line_please("eta_2_min");
		
		//extra Unlink();
		//loudspeaker_struct = getstruct("loudspeaker_struct", "targetname");
		//extra.origin = loudspeaker_struct.origin;
		
		extra line_please("returning_to_your_own_country");
		extra line_please("loudspeaker_squak1", 0.5);
		extra line_please("loudspeaker_squak2");
	//	extra line_please("loudspeaker_squak6");
		//extra line_please("loudspeaker_squak7");
		extra line_please("pbr_on_way");//, "wave2_timer_done");
		woods line_please("copy_that_amen");
		
		//extra.origin = level.player GetEye();
		//extra LinkTo (level.player);
		
		//woods line_please("bastards_wont_quit", 15 );
		//extra line_please("pbr_minute_away", 30);
		//bowman line_please("they_all_around", 25 );
	}
	
	pbr_here_dialogue(woods, player, extra, bowman, reznov);
}
	
pbr_here_dialogue(woods, player, extra, bowman, reznov)
{

	flag_set("saying_direct_fire_support");
	extra line_please("direct_fire_support");
	woods line_please("got_it_xray_out", undefined, undefined, "final_airstrike_called");
	woods line_please("mason_mark_target", undefined, undefined, "final_airstrike_called");
		
	player line_please("marking_coord", 0, "final_airstrike_called");
	extra thread line_please("get_people_back");
	bowman line_please("pbr_here", 1.8);	
	flag_set("get_people_back_said");


	woods line_please("get_asses_to_boat", undefined, undefined, "player_in_boat");
	woods line_please("have_incoming", undefined, undefined, "player_running_to_boat");
	bowman line_please("move_move",0,  undefined, "player_in_boat");
	woods line_please("go_get_to_boat", 0, undefined, "player_in_boat");
	woods line_please("get_in", 2, "player_running_to_boat", "player_in_boat");
	
	//bowman line_please("so_much_for_tet", 3.5, "player_in_boat");
	//reznov line_please("enemys_courage", 5, "player_in_boat");
	player line_please("dragovich");
}

friendly_chain_control(path)
{
	level endon ("wave2_timer_done");
	
	while(1)
	{
		wait RandomInt(15,20);
		flag_wait("doing_defend_color_chains");
				
		highest_nodegroup = 1;
		for (i=1; i < 6; i++)
		{
			nodes = GetNodeArray(path+"_d_nodes_"+i, "script_noteworthy");
			for (j=0; j < nodes.size; j++)
			{
				if (IsDefined(nodes[j]._taken) && nodes[j]._taken == true)
				{
					highest_nodegroup = i;
				}
			}
		}
		
		trig = GetEnt(path+"_chain_"+highest_nodegroup, "targetname");
		if ( IsDefined(trig) )
		{
			trigger_use(trig.targetname); // corresponding allied color node, unless falling back to building
		}
		
	}
}
				
		
	

//C. Ayers: this begins to play the distant roar walla
audio_play_distant_roar()
{
    sound_ent = Spawn( "script_origin", (70, -400, 7720 ) );
    sound_ent PlayLoopSound( "amb_walla_distant_loop_1", 15 );
}

//C. Ayers: this begins to play the closer walla
audio_play_closer_roars()
{
    sound_ent1 = Spawn( "script_origin", (1200, -330, 7560 ) );
    sound_ent2 = Spawn( "script_origin", (-540, 915, 7600 ) );
    
    sound_ent1 PlayLoopSound( "amb_walla_distant_loop_2", 15 );
    sound_ent2 PlayLoopSound( "amb_walla_distant_loop_3", 15 );
}

allies_crouch_near_chopper()
{
	crouchdist = 300;
	
	while( !flag("wounded_on_skydemon") )
	{
		allies = GetAIArray("allies");
		for (i=0; i < allies.size; i++)
		{
			if (DistanceSquared(allies[i].origin, level.skydemon.origin) < (crouchdist*crouchdist) )
			{
				allies[i] AllowedStances("crouch", "prone");
				allies[i] disable_cqbwalk();
			}
			else
			{
				allies[i] AllowedStances("stand", "crouch", "prone");
			}
		}
		wait 0.2;
	}
	
	allies = GetAIArray("allies");
	for (i=0; i < allies.size; i++)
	{
		wait (RandomFloat(0.2));
		allies[i] AllowedStances("stand", "crouch", "prone");
	}
	wait 0.2;
	
}


kill_allies_near_dock(dest)
{
	self endon ("death");
	while( DistanceSquared(self.origin, dest) > ( 800 *800) )
	{
		wait 0.1;
	}
	wait RandomFloat(5);
	self killme( (755.8, 1098.3, 7573) );
}

//mortar_color_chains(delete_em)
//{
//	level endon ("doing_defend_color_chains");
//	wait 7;
//	
//	trigger_use("dock_chain_4");
//	trigger_use("street_chain_4");
//	trigger_use("ruins_chain_4");
//	
//	wait 15;
//	
//	trigger_use("dock_chain_5");
//	trigger_use("street_chain_5");
//	trigger_use("ruins_chain_5");
//	
//	if (!IsDefined(delete_em))
//	{
//		return;
//	}
//	
//	trigs = GetEntArray("last_d_chains", "targetname");
//	trigs = array_combine(GetEntArray("d_chains", "script_noteworthy"), trigs);
//	trigs = array_combine(GetEntArray("first_d_chains", "script_noteworthy"), trigs);
//	trigs = array_combine(GetEntArray("second_d_chains", "script_noteworthy"), trigs);
//
//	for (i=0; i < trigs.size; i++)
//	{
//		trigs[i] Delete();
//	}
//	
//}

pre_wave1_control_1()	// end on 20 seconds, nag line at 10
{
	level endon ("defend_loudspeaker_started");
	level endon ("c4_acquired");
	level endon ("claymore_acquired");
	
	level thread pre_wave1_control_2();
	level thread pre_wave1_control_3();
	
	counter = 0;
	while(counter < 20)
	{
		counter++;
		if (counter == 10)
		{
			// do nagline
		}
		wait 1;
	}
	flag_set ("defend_loudspeaker_started");
}

pre_wave1_control_2()	// if weapons picked up, give 10 seconds, then start fight
{
	level endon ("c4_thrown");
	level endon ("defend_loudspeaker_started");	
	level endon ("claymore_thrown");

	level waittill_any ("c4_acquired", "claymore_acquired");
	
	wait 10;
	flag_set ("defend_loudspeaker_started");
}

pre_wave1_control_3() // if weapons thrown, give 8 seconds to finish setting up, then start fight
{
	level endon ("defend_loudspeaker_started");	
	level waittill_any ("c4_thrown", "claymore_thrown");
	wait 8;
	flag_set ("defend_loudspeaker_started");
}


stop_street_exploders()
{
	for (i=2011; i < 2016; i++)
	{
		stop_exploder(i);
	}
	for (i=2022; i < 2034; i++)
	{
		stop_exploder(i);
	}
	for (i=2051; i < 2057; i++)
	{
		stop_exploder(i);
	}
	for (i=2001; i < 2006; i++)
	{
		stop_exploder(i);
	}
	for (i=700; i < 706; i++)
	{
		stop_exploder(i);
	}
	stop_exploder(720);
}

acog_objective()
{
	flag_set("acog_objective_active");
	gunspot = (1057, 707, 7473.7);
	gunangles = (0, 102.2, -90);
	
	Objective_Add(10, "active", &"HUE_CITY_OBJ_ACOG", gunspot+(0,0,20) );
	Objective_Current(10);
	objective_set3d( 10, 1, "default", &"HUE_CITY_SCOPED_RIFLE" );
	
	counter = 0;
	
	while(counter < 30) // check if player has acog and spawn one if there isn't one where it should be
	{
		counter++;
		wait 0.5;
		
		weapons = level.player GetWeaponsList();
		for (i=0; i < weapons.size; i++)
		{
			if (weapons[i] == "commando_acog_sp")
			{
				counter = 31;
			}
			else
			{
				acog_rifle = GetEntArray( "weapon_commando_acog_sp", "classname" );
				if (acog_rifle.size ==0)
				{
					gun = Spawn("weapon_commando_acog_sp", gunspot);
					gun.angles = gunangles;
				}
				
				neargun = 0;
				for( j = 0 ; j < acog_rifle.size; j++ )
				{
					if (DistanceSquared(acog_rifle[j].origin, gunspot) < (40*40) )
					{
						neargun = 1;
					}
				}
				if ( neargun ==0 )
				{
					gun = Spawn("weapon_commando_acog_sp", gunspot);
					gun.angles = gunangles;
				}
			}
		}
	}
	
	flag_clear("acog_objective_active");
	Objective_Delete(10);
}

pbr_guys(boat)
{
	for (i=1; i < 5; i++)
	{
		guy = struct_spawn("pbr_guys")[0];
		guy thread magic_bullet_shield();
		guy make_hero();
		spot = getstructent("pbr_guy_spot_"+i, "targetname", "tag_origin");
		spot LinkTo (boat);
		guy LinkTo(spot, "tag_origin", (0,0,0), (0,0,0) );
		if (i==2)
		{
			guy AllowedStances("crouch");
		}
		if (i==4)
		{
			guy.animname = "pbr_driver";
			guy thread anim_loop(guy, "drive");
		}
	}
}

//keep_commando_acog()
//{
//	self endon ("death");
//	self endon ("disconnect");
//	
//	hascommando = false;
//	while(hascommando == false)
//	{
//		weapons = self GetWeaponsList();
//		hascommando = false;
//		for (i=0; i < weapons.size; i++)
//		{
//			if (weapons[i] == "commando_acog_sp")
//			{
//				hascommando = true;
//			}
//		}
//		wait 1;	
//	}
//	
//	while(1)
//	{
//		if (self GetCurrentWeapon() == "commando_sp")
//		{
//			self TakeWeapon("commando_sp");
//			self GiveWeapon("commando_acog_sp");
//			self SwitchToWeapon("commando_acog_sp");
//		}
//		wait 0.1;
//	}
//}
//
