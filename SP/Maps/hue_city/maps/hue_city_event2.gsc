#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_anim;
#include maps\_music;
#include maps\flamer_util;
#include maps\_hud_util;
#include maps\hue_city;
#include maps\_vehicle_turret_ai;


#using_animtree("generic_human");
event2()
{
	event2_setup();	
	
	//enable_ai_revive();
	
	//level thread save_loop();
	level thread objective_control(3);
	level thread authorization_operation_said_timer();
	level thread balcony_fallout();
	level thread sky_cowbell();
	level thread event2_dialogue();
	level thread street_start();
	level thread spawn_manager_insurance();
	level thread street_converge();
	level thread up_the_street1();
	level thread pillar_area_battle();
	level thread blue_building();
	level thread section_2_retreat();
	level thread street_end_ready_and_go();
	level thread street_mg_turret_setup();
	level thread alley_setup();	
	level thread event2_threatbias_management();
	level thread post_tank_retreat();
	level thread apc_in_place_tank_go();
	level thread street_fire_locations();
	level thread event2_playersprint_failsafe();
	level thread no_longer_ignore_player();
	// performance optimization tweaks
	level thread lower_friendly_for_aicount();
	sms = [];
		
	
	dispensable_sm_count = 8;
	
	for (i=1; i < dispensable_sm_count+1; i++)
	{
		sms = array_add(sms, GetEnt("dispensable_sm_"+i, "targetname"));
	}
	
	array_thread(sms, ::disable_for_high_aicount);
	
	
	waittill_spawn_manager_enabled("first_street_guys_sm");
	array_thread(GetAIArray("allies"), ::ignore_off);
	

}

cleanup_macv_ents()
{
	kill_spawnernum(101);
	wait(.05);
	kill_spawnernum(102);
	wait(.05);
	kill_spawnernum(71);
	wait(.05);
	kill_spawnernum(73);
	wait(.05);
	kill_spawnernum(75);
	wait(.05);
	kill_spawnernum(78);
	wait(.05);
	trigs = GetEntArray("macv_triggers", "script_noteworthy");
	trigs = array_add(trigs, GetEnt("post_skydemon_trig", "script_noteworthy") );
	
			// stop exploders as it SHOULD reduce clientside ent count
	stop_exploder(11);
	wait(.05);
	stop_exploder(20);
	wait(.05);
	stop_exploder(21);
	wait(.05);
	stop_exploder(22);
	wait(.05);
	for (i=30; i < 43; i++)
	{
		stop_exploder(i);
		wait(.05);
	}
	wait(.05);
	stop_exploder(51);
	wait(.05);
	stop_exploder(52);
	wait(.05);
	stop_exploder(53);
	wait(.05);
	stop_exploder(101);
	
	for (i=0; i < trigs.size; i++)
	{
		wait(.05);
		trigs[i] Delete();
	}
	wait 1;
	map_collectibles = getentarray ( "collectible", "targetname" );
	
	models = GetEntArray("script_model", "classname");
	for (i=0; i < models.size; i++)
	{
		for(x=0;x<level.collectibles.size;x++)
		{
			if(models[i] == level.collectibles[x])
			{
				models[i].dont_delete= 1;
			}
		}
		if (models[i].origin[1] < -4000 && models[i].origin[0] < -1000  && !isDefined(models[i].dont_delete))
		{
			models[i] Delete();
			wait(.05);	
		}
	}
	
	clientnotify ("clean_macv_client_destructibles");
	
}
	

event2_setup()
{
	level.player SetClientDvar ("cg_objectiveIndicatorFarFadeDist", "120000");
	level.player SetClientDvar ("cg_objectiveIndicatornearFadeDist", "64");
	flag_set("event2_start_go");
	
	level thread cleanup_macv_ents();
	
	level.player.ignoreme = true;
	//Kevin adding music state
	setmusicstate("STREETS_INTRO");	
}

alley_setup()
{
	trig = GetEnt("aa_gun_trig", "targetname"); // this resets this in case midsection is on no compile
	if (!IsDefined(trig))
	{
		return;
	}
	
	//THE CLIPS NEAR THE AA GUN WHEN IT FALLS DOWN
	aa_gun_clips = GetEntArray("alley_falling_ceiling_d", "targetname");
	for(i=0;i<aa_gun_clips.size;i++)
	{
		aa_gun_clips[i] connectpaths();
		aa_gun_clips[i] trigger_off();
	}
	
	
	level thread aa_gun();
	level thread looking_down_midstreet();
	level thread before_balcony();
	level thread aagun_fall();
	level thread alley_door_scene();
	
	level thread alley_flank_ai_behavior();
	level thread tank_knockdown_balcony();
	level thread tankstop_spot_b4_aagun();
	level thread delay_flag2_on_flag1("playboy_blowthrough_go", "get_off_street_go", 1.3);
	
	flag_wait("ready_for_defend");
	level thread maps\hue_city_event3::event3();
	
}

event2_start()
{
	wait_for_all_players();
	tp_to_start("e2");
	battlechatter_on();
	
	flag_set("event2_skipto");
	level notify("set_street_fog");
	
	level.player GiveWeapon("spas_db_sp");
	level.player SwitchToWeapon("spas_db_sp");
	level.player GiveWeapon("commando_sp");
	
	level.woods set_force_color("r");
	
	event2();
}

event2b_start()
{
		GetEnt("street_converge", "targetname") Delete();
	
	wait_for_all_players();
	tp_to_start("e2b");
	cleanup_macv_ents();
	battlechatter_on();


	trigger_use("near_ally_radio_guy_trig");
	level.player thread maps\_chopper_support::chopper_support_setup();
	
	simple_spawn("street_redshirts_2");
	simple_spawn("street_redshirts_1");
	flag_set("alleyskipto_start");
	flag_set("event2_start_go");
	flag_set("authorization_operation_said");
	flag_set("apc_reached_end_node");
	
	level thread event2_dialogue();
	
	
	trigger_use("near_ally_radio_guy_trig");
	wait 1;
	
	level.player GiveWeapon("spas_db_sp");
	level.player GiveWeapon("commando_sp");
	//level.player GiveWeapon("spas_sog_sp");
	//level.player SwitchToWeapon("spas_db_sp");

	
	level.skydemon = GetEnt("skydemon", "targetname");

	wait 3;
	
	level thread pillar_area_battle();
	
	
	level thread alley_setup();
	level thread objective_control(3);
	
}

event2c_start()
{
	//level thread alley_setup();
	
	wait_for_all_players();
	
	wait 0.05;
	trigger_use("aa_gun_trig");
	
	trigs = GetEntArray("street_spawnmanagers_4", "script_noteworthy");
	trigs = array_add(trigs,GetEnt("up_to_etank1", "targetname") );
	trigs = array_add(trigs,GetEnt("aa_gun_trig", "targetname") );
	
	for (i=0; i < trigs.size; i++)
	{
		trigs[i] Delete();
	}
	
	GetEnt("pillar_area_battle", "script_noteworthy") Delete();
	GetEnt("street_converge", "targetname") Delete();
	
	level.player GiveWeapon("commando_sp");
	level.player SwitchToWeapon("commando_sp");
	
	
	tp_to_start("e2c", "e2b");
	flag_set("street_end_go");
	flag_set("skydemon_ran_from_aa_gun");
	
	//TUEY Set music state to CHOPPER_RETREAT
	setmusicstate ("CHOPPER_RETREAT");
	
	level thread alley_door_scene();

}


event2d_start()
{
	wait_for_all_players();
	tp_to_start("e2d", "e2b");
	flag_set(	"player_on_alley_balcony");
	level.player GiveWeapon("commando_sp");
	level.player SwitchToWeapon("commando_sp");
	wait 1;
	level thread alley_balcony_fall();
	level thread aagun_fall();
}



street_spawn_managers()
{
	GetEnt("street_retreaters_1", "target") waittill ("trigger");
	
	trigs = GetEntArray("street_spawnmanagers_1", "script_noteworthy");
	enable_sms(undefined, trigs);
}

street_start()
{
	level thread street_spawn_managers();
	trigger_wait("chopper_move_out", "script_noteworthy");
	trigger_wait("apc_start_lookat_trig", "targetname");

	//GetEnt("ally_radio_guy", "targetname") StalingradSpawn();	
	trigger_use("spawn_apc_trig");
	
	level.player.ignoreme = true;
	level.reznov set_force_color("r");
	
	trig = GetEnt("near_ally_radio_guy_trig", "targetname");
	looktrig = GetEnt("crosby_lookat_trig", "targetname");
	
	level thread radio_nag_lines();
	
	counter = 0;
	countmax = 300;
	
	autosave_by_name("to_perch");
	
	message_shown = false;
	
	while(1)
	{
		if (level.player IsTouching(trig))
		{
			counter++;
		}
		if (level.player IsTouching(trig) && (level.player IsLookingAt(looktrig) || level.player IsLookingAt(level.crosby) ) )
		{
			if(!message_shown)
			{
				level.player SetScriptHintString(&"HUE_CITY_TAKE_RADIO");
				message_shown = true;
			}
			//level thread text_display(&"HUE_CITY_TAKE_RADIO", undefined, 300,200,"player_took_radio", 1.25 );
		}
				// if player pressed use while looking at crosby or looktrig , or counter is over countmax - AND is touching touchtrig
		if ( ( (level.player use_button_held() && (level.player IsLookingAt(level.crosby) || level.player IsLookingAt(looktrig)))  || counter > countmax)  && level.player IsTouching(trig)  )
		{
			level notify ("player_took_radio");
			level.player SetScriptHintString("");
			break;
		}
		if (!level.player IsTouching(trig) || ( !level.player IsLookingAt(level.crosby) && !level.player IsLookingAt(looktrig)) )
		{
			level.player SetScriptHintString("");
			message_shown = false;
		}
		wait 0.1;
	}
	
	flag_set("get_chopper_now");
	flag_wait("chopper_vignette_over");

	level.player thread maps\_chopper_support::chopper_support_setup();
	
	objective_add(12, "current" );
	Objective_Position( 12, (-5149.5, -144, 7783)  );	
	objective_Set3D ( 12, 1, "default", &"HUE_CITY_TARGET" );
	
	flag_wait("first_airstrike_called");
	
	objective_delete(12);
	
	//level.reznov thread maps\hue_city_ai_spawnfuncs::street_reznov_setup();
	
	delete_early_e2_trigs();
	
	clips = GetEntArray("perch_blocker", "targetname") ;
	for (i=0; i < clips.size; i++)
	{
		clips[i] ConnectPaths();
		clips[i] Delete();
	}
	
	flag_wait("chopperstrike_1_called");
	wait 8;
	flag_set("dont_clear_friendlies");
	trigger_use("charge_respawn_trig", "script_noteworthy");
	struct_spawn("street_charge_guys", maps\hue_city_ai_spawnfuncs::street_charge_guys_setup);
	
	wait 10;
	flag_clear("dont_clear_friendlies");
	trigger_use("post_perch_friendly_respawn", "script_noteworthy");
}

radio_nag_lines()
{
	level endon ("get_chopper_now");
	trigger_wait("sky_cowbell_2_trig");
	
	lines = [];
	lines[0] = "hurry_up_get_radio";
	lines[1] = "grab_damn_radio";
	wait 20;
	
	while(1)
	{
		level.woods line_please(lines[RandomInt(lines.size)]);
		wait 15;

	}
}

new_friendly_apc_movement(apc)
{
	node = GetVehicleNode("apc_stop_node_1", "script_noteworthy");
	trig = GetEnt("apc_inspot1_chain", "targetname");
	node trig_on_trig(trig);
	apc SetSpeed(0,100,100);
	
	flag_wait("player_on_perch");
	
	node = GetVehicleNode("apc_stop_node_2", "script_noteworthy");
	trig = GetEnt("apc_stop_chain_2", "targetname");
	apc ResumeSpeed(10);
	node trig_on_trig(trig);
	apc SetSpeed(0,100,100);
	flag_wait("apcchain1_go");
	//Kevin adding music state
	setmusicstate("METAL_LOOP1");
	apc ResumeSpeed(10);
}

disconnect_paths_around_vehicle()
{
	self endon("death");

	wait(0.1);
	self vehicle_kill_disconnect_paths_forever();

	lastPos = self.origin;
	while( IsDefined(self) )
	{
		currentPos = self.origin;

		// disconnect while on the move
		if( DistanceSquared(currentPos, lastPos) > 32*32 )
		{
			self DisconnectPaths();
			lastPos = currentPos;
		}
		else if( self getspeed() < 1 ) // disconnect when stopped
		{
			self DisconnectPaths();

			while( self getspeed() < 1 )
			{
				wait( 0.05 ); 
			}
			lastPos = self.origin;
		}

		wait(0.2);
	}
}

ensure_trigger()
{
	GetEnt("street_l_chain2", "targetname") thread trig_on_notify("chopperstrike_spot2_fire"); // make sure this gets triggered
	GetEnt("apc_move3", "targetname") thread trig_on_notify("chopperstrike_spot2_fire"); // make sure this gets triggered
	GetEnt("apc_move4", "targetname") thread trig_on_notify("chopperstrike_spot2_fire");
}		

friendly_apc_movement() // self = apc
{

	level endon ("apc_destroyed");
	level thread ensure_trigger();

	gunner = spawn("script_model", (0,0,0) );
	gunner character\c_usa_jungmar_tanker::main();
	gunner UseAnimTree(#animtree);
	//gunner makefakeai();
	//gunner.name = "Sgt. Pierro";
	gunner maps\_vehicle_aianim::vehicle_enter( self, "tag_gunner4" );
	gunner thread delete_on_ent_notify(self, "death");
	
	apc = GetEnt("e2_friendly_apc", "targetname");
	
	apc thread apc_audio();
	self.turret_audio_override = true;
	self.turret_audio_ring_override_alias = true;
  self.turret_audio_override_alias = "wpn_btr_fire_loop_npc";
  self.turret_audio_ring_override_alias = "wpn_btr_fire_loop_ring_npc";
	apc thread enable_turret(3);
	apc SetVehicleLookAtText ("Bottom Feeder", &"HUE_CITY_APC_TYPE" );

	apc thread disconnect_paths_around_vehicle();
	
	apc SetCanDamage(false);
	new_friendly_apc_movement(apc);
	
	node = GetVehicleNode("friendapc_chain1", "script_noteworthy");
	trig = GetEnt("apcchain1", "targetname");
	node trig_on_trig(trig);
	apc SetSpeed(0,100,100);
	
	flag_wait("apcchain2_go");
	
	//Kevin adding music state
//	setmusicstate("STREET_INST");
	
	level.player.ignoreme = false;
	apc ResumeSpeed(10);
	node = GetVehicleNode("friendapc_chain2", "script_noteworthy");
	GetEnt("apcchain2", "targetname") notify ("trigger");
	node waittill ("trigger");
	apc SetSpeed(0,1000,1000);
	
	flag_wait("apcchain3_go");
	apc ResumeSpeed(15);
	node = GetVehicleNode("friendapc_chain3", "script_noteworthy");
	GetEnt("apcchain3", "targetname") notify ("trigger");
	node waittill ("trigger");
	apc SetSpeed(0,1000,1000);
	
	flag_wait("apcchain4_go");
	apc ResumeSpeed(20);
	node = GetVehicleNode("friendapc_chain4", "script_noteworthy");
	trig = GetEnt("apcchain4", "targetname");
	node trig_on_trig(trig);
	apc SetSpeed(0,1000,1000);
	flag_set("apc_reached_end_node");
	
	flag_wait("apcchain5_go");
	apc ResumeSpeed(5);
	
	
}

apc_audio()
{
	if(!isDefined(self))
	{
		return;
	}
	level endon("apc_destroyed");
	ent1 = spawn( "script_origin" , self.origin);
	ent2 = spawn( "script_origin" , self.origin);
	self thread audio_ent_fakelink( ent1,ent2 );
	level thread audio_ent_fakelink_delete(ent1,ent2);
	while(1)
	{
		if( self GetSpeedMPH() > 1)
		{
			ent2 stoploopsound( .5 );
			ent1 playloopsound( "veh_apc_move_high_ovr" , .5 );
		}
		else if ( self GetSpeedMPH() < 1)
		{
			ent1 stoploopsound( .5 );
			ent2 playloopsound( "veh_apc_idle_low_ovr" , .5 );
		}
		wait(.5);
	}
}

audio_ent_fakelink( ent1,ent2 )
{
	level endon("apc_destroyed" );
	
	while(1)
	{
		if(ent1.origin != self.origin)
		{
			ent1 moveto( self.origin,.5 );
			ent2 moveto(self.origin,.5);
			ent1 waittill("movedone");
		}
		wait(.5);
	}
}

audio_ent_fakelink_delete(ent1,ent2)
{
	level waittill( "apc_destroyed" );
	
	ent1 delete();
	ent2 delete();
}

street_converge()
{
	trigger_wait("apcchain4", "targetname");
	enable_sms("street_spawnmanagers_2");
	
	level thread clear_left_building_guys();
	kill_spawnernum(1);
	kill_spawnernum(2);
	kill_spawnernum(2001);
	kill_spawnernum(2002);
	kill_spawnernum(3000);
	kill_spawnernum(3001);

	wait 10;
	kill_spawnernum(3);
	
}


clear_left_building_guys()
{
	guys = GetEntArray("street_e_1_ai", "targetname");
	guys = array_combine(guys, GetEntArray("street_e_2_ai", "targetname") );
	for (i=0; i < guys.size; i++)
	{
		guys[i] thread wait_and_kill(RandomFloat(2));
	}
}

kill_axis_tank_reminder()
{
	self endon ("death");
	level endon ("chopperstrike_5_called");
	wait 10;
	while(1)
	{
		wait 30;
		chopper_support_killtank_reminder_voiceover();
	}
}

axis_tank_fire_loop()
{
	self thread kill_axis_tank_reminder();
	wait 4;
	self endon ("death");
	while(1)
	{
		allies = GetAIArray("allies");
		if (!flag("chopperstrike_5_called"))
		{
			allies = array_add(allies, level.player);
		}
		self SetTurretTargetEnt( allies[ RandomInt(allies.size) ] );
		wait 6;
		self FireWeapon();
	}
}

etank1_wait_for_apc()
{
	while(!flag("apc_reached_end_node"))
	{
		self SetSpeed(0,100,100);
		if (level.player.origin[0] > -3800)
		{
			etank1_own_player();
			break;
		}
		wait 0.1;
	}

	flag_wait("apc_reached_end_node");
}

etank1_own_player()
{
	self thread gunner_turret_own_target(level.player, 0, "apc_reached_end_node");
	self thread turret_own_target(level.player, undefined, "apc_reached_end_node");
}

apc_in_place_tank_go()
{
	flag_wait("apc_reached_end_node");
	trigger_wait("tank_entrance_lookat");
	if (!flag("apcchain5_go"))
	{
		trigger_use("street_converge");
	}
}

enemytank1_setup()
{
	
	node = GetVehicleNode("etank1_wait_spot", "script_noteworthy");
	node waittill ("trigger");
	

	spot = getstruct("enemytank1_target", "targetname");
	self SetTurretTargetVec(spot.origin);
	
	apc = GetEnt("e2_friendly_apc", "targetname");
	apc SetSpeed(12);
	
	etank1_wait_for_apc();

	trigger_use("apc_move4");
	tank = GetEnt("enemytank1", "targetname");
	apc SetCanDamage(true);
	tank SetTurretTargetEnt(apc, (0,0,50));
	wait 0.4;
	self SetSpeed(0,100,100);
	
	tank thread disconnect_paths_around_vehicle();
	
	GetEnt("tank_entrance_lookat", "targetname") thread notify_on_trigger("tank1_entrance_go");
	level thread notify_delay("tank1_entrance_go", 4);
	level waittill ("tank1_entrance_go");
	
	level.player thread magic_bullet_shield();
	wait 0.1;
	
	tank FireWeapon();
	
	wait 0.1;
	level notify ("apc_destroyed");
	
	//TUEY Set music state to APC_OWNED
	setmusicstate ("APC");

	
	RadiusDamage(apc.origin, 50, 999999, 99999);
	Earthquake(0.7, 1.5, apc.origin, 1000);
	if (DistanceSquared(level.player.origin, apc.origin) < (300*300) )
	{
		level.player PlayRumbleOnEntity("artillery_rumble");	
		level.player ShellShock("tankblast", 2.5);
		level.player DoDamage(2, apc.origin);
	}
	wait 0.1;
	level.player stop_magic_bullet_shield();

	level notify ("tank01_entrance_start");
	wait 0.5;
	self ResumeSpeed(3);
	
	trigger_use("apcchain5");

	tank.turret_audio_override = true;
	tank.turret_audio_ring_override_alias = true;
  tank.turret_audio_override_alias = "wpn_50cal_fire_loop_npc";
  tank.turret_audio_ring_override_alias = "wpn_50cal_fire_loop_ring_npc";
	tank thread enable_turret( 0, "mg", "allies" );

	//tank ResumeSpeed(5);
	flag_set_delayed("tank_ok_to_target",2);

	tank thread axis_tank_fire_loop();
	
	node = GetVehicleNode("enemy_tank_pause", "script_noteworthy");
	
	node waittill ("trigger");
	tank SetSpeed(0,1000,1000);
	wait 0.3;
	tank ResumeSpeed(5);

	delete_array("apc_chains", "script_noteworthy");

	
}

up_the_street1()
{
	trigger_wait("tankbuilding_chain");
	level thread enable_sms("street_spawnmanagers_3");
	
	waittill_spawn_manager_enabled("endstreet_blubuilding_guys_sm");
	guys = GetAIArray("axis");
	for (i=0; i < guys.size; i++)
	{
		if (guys[i].origin[0] < level.player.origin[0]  )
		{
			guys[i] killme();
		}
	}
}

pillar_area_battle()
{
	trigger_wait("pillar_area_battle", "script_noteworthy");
	enable_sms("street_spawnmanagers_4");
}

save_loop()
{
	successsaves = 0;
	while(1)
	{
		wait 30;
		if (!flag("miniguns_on") && (GetAIArray().size < 28) )
		{
			if ( successsaves == 0)
			{
				autosave_by_name("saveloop");
				successsaves ++;
			}
			else
			{
				successsaves = 0;
			}
		}
	}
}

aa_gun()
{
	flag_wait("alley_aa_gun_spawned");
	autosave_by_name("alley_aa_gun_spawned");
	
	GetEnt("aa_gun_street_sm_1", "targetname") trigger_on();
	
	gun = GetEnt("alley_aa_gun", "targetname");
	
	target = getstructent("alley_aa_gun_target1", "targetname");
	
	level thread aagun_target_move(target);
	level thread alley_cross_chopper_shootdown();
	level thread at_aagun_jets();
	
	gun SetTurretTargetEnt(target);
	
	gun endon ("death");
	
	sound_ent = spawn( "script_origin" , gun.origin);
	
	gun thread stop_aa_audio_failsafe(sound_ent);
	
	flag_wait("skydemon_taking_aa_fire");
	
	counter = 0;
	
	did_alley_jets1 = 0;
	did_aagun_gun_target_2_random_move = 0;
	did_jets_mover = 0;
	
	while( isdefined(gun) && gun.health > 0)
	{
		gun fireweapon();
		wait(0.096);
		sound_ent playloopsound( "wpn_50cal_fire_loop_npc" );
		
		counter++;
		
		if (counter > RandomIntRange(100,200) && flag("alleyjets_1_gone") )
		{
			sound_ent stoploopsound();
			sound_ent playsound( "wpn_50cal_fire_loop_ring_npc" );
			wait RandomFloatRange(1,3);
			counter = 0;
		}
		if (flag("sending_alley_jets_1") && did_alley_jets1 == 0)
		{
			plane = GetEnt("alleyjets_1_r_start", "targetname");
			gun SetTurretTargetEnt(plane);
			flag_clear("sending_alley_jets_1");
			level thread aagun_target_random_move(target);
			did_alley_jets1++;
		}
		if (flag("alleyjets_1_gone") && !flag("alley_balcony_fell") && !flag("alley_cross_chopper_shootdown_go") )
		{
			gun SetTurretTargetEnt(target);
		}
		if (flag("alley_cross_chopper_shootdown_go") )
		{
			chopper = GetEnt("shotdown_chopper", "targetname");
			gun SetTurretTargetEnt(chopper);
		}
		if (flag("alley_balcony_fell") && did_aagun_gun_target_2_random_move ==0 && !flag("at_aagun_jets_go") )
		{
			spot = getstructent ("alley_aa_gun_target_2", "targetname");
			level thread aagun_gun_target_2_random_move(spot);
			gun SetTurretTargetEnt(spot);
			did_aagun_gun_target_2_random_move++;
		}
		if (flag("at_aagun_jets_go") && did_jets_mover==0 )
		{
			did_jets_mover = 1;
			did_aagun_gun_target_2_random_move = 0;
			
			mover = getstructent("aagun_jets_target1", "targetname");
			spot2 = getstruct("aagun_jets_target2", "targetname");
			gun SetTurretTargetEnt(mover);
			wait 2;
			mover moveto (spot2.origin, 3);
			mover thread wait_and_delete(4);
		}
	}
}

stop_aa_audio_failsafe(ent)
{
	self waittill( "death" );
	ent Delete();
}

at_aagun_jets()
{
	flag_wait("at_aagun_jets_go");
	wait 2.2;
	level thread streets_jets_group("at_aagun_jets", undefined, 3.5);
	wait 4.5;
	flag_clear("at_aagun_jets_go");
}
	

alley_cross_chopper_shootdown()
{
	level waittill ("alley_cross_chopper_shootdown_go");
	chopper = GetEnt("shotdown_chopper", "targetname");
	wait 0.2;
	Earthquake(0.5, 1.2,chopper.origin, 3000);
	PlayFX(level._effect["chopper_hit"], chopper.origin);
	PlayFXOnTag(level._effect["tank_top_trail"], chopper, "tag_origin");
	wait 1.7;
	flag_clear("alley_cross_chopper_shootdown_go");
}

target_move(aa_target)
{
	node = GetVehicleNode("alley_chopper_shotdown_node", "script_noteworthy");
	node endon ("trigger");
	org = aa_target.origin;
	while(1)
	{
		y = RandomIntRange(-200,200);
		aa_target moveto (org+(0,y,400), 1.2 );
		aa_target waittill ("movedone");
		y = RandomIntRange(-200,200);
		aa_target moveto (org+(0,y,-200), 1.2 );
		aa_target waittill ("movedone");
		y = RandomIntRange(-200,200);
		aa_target moveto (org+(0,y,0), 0.6 );
		aa_target waittill ("movedone");
	}
}




skydemon_trail()
{
	level endon ("stop_skydemon_trail");
	counter = 0;
	level._skydemon_trail = Spawn("script_origin", level.skydemon.origin);

	
	while(1)
	{
		tempspot = level.skydemon.origin;
		wait .5;
		level._skydemon_trail.origin = tempspot;
	}
}

aagun_target_move(target)
{

	flag_wait("skydemon_taking_aa_fire");
	
	//TUEY Set music state to CHOPPER_RETREAT
	setmusicstate ("CHOPPER_RETREAT");
	
	level thread skydemon_trail();
		
	wait 1;
	for (i=0; i < 4; i++)
	{

		offset = (0,0,-100);
		if (i>1 && i < 4)
		{
			offset = (0,0,-200);
		}
		if (i > 3)
		{
			offset = (0,0,200);
		}
		
		spot = level._skydemon_trail.origin + offset;
		target moveto (spot, 0.7);
		target waittill ("movedone");
	}
	
	level notify ("stop_skydemon_trail");
	target LinkTo (level.skydemon, "tag_origin", (0, 500, 100) );
	wait 1;
	flag_set("skydemon_ran_from_aa_gun");

}
	
	


aagun_target_random_move(target)
{
	level endon ("at_aagun_jets_go");
	org = (-2527, -128, 7964);
	target Unlink();

	while(!flag("alley_balcony_fell"))
	{		
		tempy = RandomIntRange(-200,300);
		tempz = RandomIntRange(-10,200);		
	
		neworg = org+(0,tempy,tempz);
		target moveto (neworg, 4);
		target waittill ("movedone");
	}
	target Delete();
}

aagun_gun_target_2_random_move(target)
{
	org = target.origin;
	level endon ("at_aagun_jets_go");
	while(!flag("aagun_blown"))
	{
	
		tempx = RandomIntRange(-500,1000);	
		tempz = RandomIntRange(-200,600);
	
		neworg = org+(tempx,0,tempz);
		target moveto (neworg, 4);
		target waittill ("movedone");
	}
	target Delete();
}

looking_down_midstreet()
{
	trigger_wait("on_midstreet_trig", "targetname");
	trig = GetEnt("looking_down_midstreet_trig", "targetname");
	trig thread notify_delay("trigger", 1);
	trig waittill ("trigger");
	
	delete_chopper_volume_stuff();
	
	flag_set("sending_alley_jets_1");
	flytime = 5;
	level thread three_jet_squadron("alleyjets_1", flytime, 1);
	
	wait 1.5;
	//wait flytime;

	flag_set("alleyjets_1_gone");
	wait 1;
}


before_balcony()
{
	node = GetVehicleNode("alleytank_stopnode_1", "script_noteworthy");
	node waittill ("trigger");
	tank = GetEnt("alley_tank", "targetname");
	tank SetSpeed (0,100,100);
	flag_wait("player_is_before_balcony");

	tank ResumeSpeed(2);
}

skydemon_kill_tank()
{
	flag_wait("alleytank_at_end");
	spot = GetVehicleNode("skydemon_killtank_spline_1", "targetname");
	trigger_use("e3_skipto_skydemon_spawner");	
	
	skydemon = get_skydemon();
	skydemon AttachPath(spot);	
	
	skydemon StartPath();
	skydemon ResumeSpeed(10);
	
	structs = getstructarray("skydemon_kill_tank_spline", "script_noteworthy");
	
	skydemon thread kill_alley_tank();
	tank = GetEnt("alley_tank", "targetname");

		
}

kill_alley_tank()
{

	tank = GetEnt("alley_tank", "targetname");
	tank setforcenocull();
	//self SetLookAtEnt( tank);
	self SetTurretTargetEnt(tank);
	self SetGunnerTargetent(tank, (0,0,0), 3 );
	
	trig = GetEnt("skydemon_kill_alleytank_touch_trig", "targetname");
	while(!self IsTouching(trig))
	{
		wait 0.1;
	}
	wait 0.5;
	
	level.skydemon notify ("event2_over");
	level.skydemon thread fill_huey_with_script_models("death", 1);
	wait 1;
	
	tank.health = 1;
	
		
	for (i=0; i < 5; i++)
	{
		self FireWeapon();
		wait 0.25;
	}	

	RadiusDamage(tank.origin, 100, 15000, 10000);
	spot = getstructent("player_fall_to_spot", "targetname");
	//self SetLookAtEnt(spot);

	
	axis = GetAIArray("axis");
	for (i=0; i < axis.size; i++)
	{
		axis[i] killme();
	}
		
	flag_set("ready_for_defend");
	

}

aagun_fall()
{
	c4 = getstructent("c4_spot", "targetname", "weapon_c4");
	c4 Hide();
	c4obj = GetstructEnt("c4_obj", "targetname", "weapon_c4_obj");
	level thread aa_area_shake();
	trig = GetEnt("at_c4_trig", "targetname");
	c4_prompt = a_text_display("", undefined, 300,200,"c4_planted", 1.25 );
	c4_prompt.font = "small";
	
	// Make reznov look at the player

	//level.reznov LookAtEntity(level.player);
	//relax_ik_headtracking_limits();
	
	while(1)
	{
		if (	level.player IsTouching(trig)  )
		{
			c4_prompt SetText(&"HUE_CITY_C4_PLANT");
			if (level.player use_button_held() )
			{
				break;
			}
		}
		else
		{
			c4_prompt SetText("");
		}
		
		wait 0.05;
	}

	exploder(720); // for landing zone smoke

	level notify ("set_defend_fog");
	flag_set("c4_planted");
	
	c4obj Delete();
	
	weap = level.player GetCurrentWeapon();
	//level.player take_player_weapons();
	
//	if (level.player GetCurrentWeapon() == "spas_db_sp")
//	{
//		level.player SwitchToWeapon("spas_sog_sp");
//		while(level.player GetCurrentWeapon() == "spas_db_sp")
//		{
//			wait 0.05;
//		}
//	}
	
	level.player thread take_and_giveback_weapons("giveback_weapons");
	
	maps\hue_city_anim::plant_c4_on_roof();


	c4 Show();

	
	level.player GiveWeapon("satchel_charge_sp");
	level.player SwitchToWeapon("satchel_charge_sp");
	level.player SetWeaponAmmoClip("satchel_charge_sp", 0);
	level.player SetWeaponAmmoStock("satchel_charge_sp", 0);
	level.player DisableWeaponCycling();
	level.player DisableOffhandWeapons();
	
	level thread player_c4_ready_go_vo(c4.origin);
	
	while(1)
	{
		if (level.player GetCurrentWeapon() == "satchel_charge_sp" && level.player AttackButtonPressed() )
		{
			break;
		}
		wait 0.05;
	}
	
	wait 0.2;

	//kevin adding explo sound
	c4 playsound ( "evt_c4_det" );
	
	//TUEY set music state to C4
	setmusicstate("C4");
	
	Earthquake(0.7, 1, c4.origin, 2000);
	RadiusDamage( c4.origin, 300, 500, 10);
	level.player PlayRumbleOnEntity("explosion_generic");
	exploder(705);
	
	// Stop Reznov from looking at the player
	//level.reznov LookAtEntity();
	//restore_ik_headtracking_limits();
	
	level thread wait_and_rumble(1, "grenade_rumble");
	level thread wait_and_shake_custom(1, 0.5, 0.5);
	
	flag_set("aagun_blown");
	level.player notify ("aagun_blown");
	
	wait 0.3;
	
	roof = GetEntArray("alley_falling_ceiling", "targetname");
	for (i=0; i < roof.size; i++)
	{
		roof[i] Hide();
		roof[i] thread wait_and_delete(0.3);
	}
	
	//THE CLIPS NEAR THE AA GUN WHEN IT FALLS DOWN
	aa_gun_clips = GetEntArray("alley_falling_ceiling_d", "targetname");
	for(i=0;i<aa_gun_clips.size;i++)
	{
		aa_gun_clips[i] trigger_on();
		aa_gun_clips[i] disconnectpaths();
	}
	
	
	
	array_thread(GetEntArray("remnant_aa_gun_roof_models", "targetname"), ::wait_and_delete,0.1);
	
	gun = GetEnt("alley_aa_gun", "targetname");
	spot = Spawn("script_origin", gun.origin);
	
	level notify ("aagun_bldg_start");
		
	c4 Delete();
	
	wait 0.7;
	level.player EnableWeaponCycling();
	level.player TakeWeapon("satchel_charge_sp");
	//level.player giveback_player_weapons();
	level.player notify("giveback_weapons");
	level.player enableoffhandweapons();

	player_clip = getent("aa_gun_playerclip","targetname");
	player_clip delete();
	
	wait 2;	
	
//	trigger_use("friendly_reinforcements", "script_noteworthy");
	level thread skydemon_kill_tank();
	
	wait 0.8;
		// kevin adding wall fall audio
	level thread maps\hue_city_amb::aa_gun_wall_audio();
	
	wall = GetEntArray("aa_gun_tonys_wall", "targetname");
	for (i=0; i < wall.size; i++)
	{
		wall[i] ConnectPaths();
		wall[i] RotateRoll(-90, 2, 2);
	}
	
	door = getent("aagun_door","targetname");
	door connectpaths();
	door rotateroll(-90,1.6,1);

	//corpse removal
	corpses = EntSearch(level.CONTENTS_CORPSE, door.origin, 500);
	for(i = 0; i < corpses.size; i++)
	{
		if(IsDefined(corpses[i]))
		{
			corpses[i] Delete();
		}
	}

	level.reznov enable_cqbwalk();
	level.reznov setgoalnode(getnode("post_c4_reznov_node","targetname"));
	
	wait 1.9;
	Earthquake(0.6, 0.5, spot.origin, 2000);
	level.player PlayRumbleOnEntity("grenade_rumble");
	
	physicsExplosionSphere( wall[0].origin, 300, 50, 10 );

	level.woods disable_cqbwalk();
	spot Delete();

}

player_c4_ready_go_vo(org)
{
	level.player endon("death");
	level endon ("aagun_blown");
	
	while(distancesquared(level.player.origin,org) < (350 * 350) )
	{
		wait .25;
	}
	
	level.player playsound("vox_hue1_s02_486A_maso");
	
}

aa_area_shake()
{
	level endon ("aagun_blown");
	shaketrig = GetEnt("aa_shake_trig", "targetname");
	shaketrig waittill ("trigger");
	Earthquake (0.2, 5, level.player.origin, 2000);
}

blue_building()
{
	trigger_wait("e2_bluebuilding_upstairs_trig");
	trigger_wait("balcony_crossbuilding_lookat_trig");
	wait 3;
	kill_spawnernum(3001);
}


alley_door_scene()
{
	level thread playboy_vignette();
	level thread tank_crush_entrance();
}

tank_crush_entrance()
{
	car = GetstructEnt("alley_car_flip", "targetname", "t5_veh_civ_tiara");
	flag_wait("alley_tank_trig_fired");
	wait 0.5;
	tank = GetEnt("alley_tank", "targetname");
	sound_ent = Spawn( "script_origin", tank.origin );
	sound_ent LinkTo( tank );
	sound_ent PlayLoopSound( "veh_hue_t55_move_high" );

	//car = Spawn_a_model("t5_veh_civ_tiara", car1.origin, car1.angles);
	
	node = GetVehicleNode("tank_crush_blownode", "script_noteworthy");
	node waittill ("trigger");
	playsoundatposition( "evt_tank_wall_hit", node.origin );
	exploder(700);
	
	level thread delaythread(1.3,	::exploder,701);
	level thread play_delayed_tank_land( tank, sound_ent );
	level thread wait_and_rumble(1.3, "barrel_explosion");
	level thread wait_and_shake_custom(1.3, 0.7, 0.8);
	
	spot = getstruct("tank_crush_blowspot", "targetname");
	Earthquake(0.5, 0.6, tank.origin, 2000);
	RadiusDamage(spot.origin, 200, 2000,3000);

	spot = getstruct("alley_car_flip", "targetname");
	tank SetTurretTargetVec(spot.origin);

	level waittill ("alley_car_explosion");
	level.player PlaySound("vox_Qua1_082A_CART");

	exploder(702);

	tank FireWeapon();
	level notify ("alleytank_doorblast");
	wait 0.05;
	
	//Earthquake(0.5, 1, level.player.origin, 2000);
	carspot1 = getstruct("alley_car_flip_spot1", "targetname");
	carspot2 = getstruct("alley_car_flip_spot2", "targetname");
	carspot3 = getstruct("alley_car_flip_spot3", "targetname");
	
	
	car moveto (carspot1.origin, 0.2);
	car RotateTo (carspot1.angles, 0.2);
	//SetTimeScale (0.2);
	car waittill ("movedone");
	car moveto (carspot2.origin, 0.3);
	car RotateTo (carspot2.angles, 0.3);
	
	
	//level.player ShellShock("tankblast", 2.5);

	
	car waittill ("movedone");
	car moveto (carspot3.origin, 0.35);
	car RotateTo (carspot3.angles, 0.35);
	spot2 = getstruct("flung_spot2","targetname"); 
	
	//level.player lerp_player_view_to_position( spot2.origin, spot2.angles, .1, 0, 0, 0, 0, 0, undefined );
	wait 0.1;
	//Earthquake(0.7, 1, level.player.origin, 2000);

	//level.player AllowStand(false);
	//level.player AllowCrouch(false);
	//level.player AllowProne(true);

	car Delete();
	flipped_car = getstructent("alley_car_flipped", "targetname", "t5_veh_civ_tiara"); 

	level.woods set_force_color("p");
	level.woods enable_cqbwalk();
	
	tank.turret_audio_override = true;
	tank.turret_audio_ring_override_alias = true;
  tank.turret_audio_override_alias = "wpn_50cal_fire_loop_npc";
  tank.turret_audio_ring_override_alias = "wpn_50cal_fire_loop_ring_npc";
	tank thread enable_turret( 0, "mg", "allies" );
}

play_delayed_tank_land( tank, ent )
{
    wait(1.15);
    playsoundatposition( "veh_hue_tank_land", tank.origin );
    wait(2);
    ent StopLoopSound( 1 );
    wait(1);
    ent Delete();
}


	
playboy_vignette()
{
	trig = GetEnt("alley_door_trig", "targetname");
	trigger_wait("alley_door_trig", "targetname");
	
	flag_wait("woods_at_playboy");
	
	waittillframeend;
	
	while(!level.player istouching(trig) ) // loop until player opens door
	{
		wait 0.05;
	}
	
	tank = GetEnt("alley_tank", "targetname");
	if(isdefined(tank))
	{
		tank delete();
	}
	level.player._my_last_weapon = level.player GetCurrentWeapon();
	level.player DisableWeapons();
	wait 0.4;
	
	
	level.player thread magic_bullet_shield();
	flag_set("playboy_blowthrough_go");
	trigger_use("alley_tank_trig");
	
	player = level.player;
	tank = GetEnt("alley_tank", "targetname");
	
	flag_set("player_ready_alley_door");
	level notify ("alley_door_breached");
}

section_2_retreat()
{
	flag_wait("chopperstrike_2_called"); // called when section to is about to be over
	level waittill ("clear_clearzone");	// called when section 2 is clear, signal retreat
	autosave_by_name("section_2_clear");
	
	kill_spawnernum(3001);
	axis = GetAIArray("axis");
	for (i=0; i < axis.size; i++)
	{
		if (axis[i].origin[2] > 7550) // if they are above the gound floor kill them
		{
			axis[i] thread killme();
		}
		
		if (axis[i].origin[0] < -4000 && IsAlive(axis[i]) ) // if they are prior to the tank entrance location
		{
			nodes = GetNodeArray("section_2_retreat_nodes", "script_noteworthy");
			for (j=0; j < nodes.size; j++)
			{
				if (!IsDefined(nodes[j]._retreated_to) )
				{
					axis[i] disable_cqbwalk();
					axis[i] thread force_goal(nodes[j], 256);
					nodes[j]._retreated_to = 1;
					break;
				}
			}
		}
	}
}

spawn_manager_insurance()
{
	level thread ensure_next_group("street_spawnmanagers_2", "street_spawnmanagers_3");
	//level thread ensure_next_group("street_spawnmanagers_3", "street_spawnmanagers_4");
}

ensure_next_group(sms1sn, sms2sn, ender) // ensure there is never too much of a lull in the battle
{
	level endon ("street_end_go");
	sms1 = GetEntArray(sms1sn, "script_noteworthy");
	
	for (i=0; i < sms1.size; i++)
	{
		tn = sms1[i].targetname;
		waittill_spawn_manager_complete(tn);
	}
	
	counter = 0;
	
	while(counter < 5)
	{
		axis = GetAIArray("axis");
		if (axis.size < 5)
		{
			counter ++;
		}
		wait 0.6;
	}
	
	enable_sms(sms2sn);
}


event2_dialogue()
{
	level._lines_being_spoken = 0;
	
	flag_wait("event2_start_go");
	wait 1;
	
	woods = level.woods;
	woods.animname = "woods";
	
	bowman = level.bowman;
	bowman.animname = "bowman";
	
	player = level.player;
	player.animname = "mason";
	
	reznov = level.reznov;
	
	level._pilot = Spawn("script_origin", level.player.origin );
	pilot = level._pilot;
	pilot LinkTo (level.player);
	pilot.animname = "pilot";
	pilot.targetname = "pilot_voiceover";
	
	level._extra = Spawn("script_origin", level.player.origin );
	extra = level._extra;
	extra LinkTo (level.player);
	extra.animname = "nva";
	extra.targetname = "extra_voiceover";
	
	jumpto = GetDvar("start");
	if (flag("alleyskipto_start") )
	{
		transition_dialogue(woods, bowman, player, pilot, extra, reznov);
		return;
	}
	
	steet_dialogue(woods, bowman, player, pilot, extra, reznov);
}

steet_dialogue(woods, bowman, player, pilot, extra, reznov)
{

	extra thread line_please("we_luv_you");
	woods thread line_please("gonna_need", 0, "gonna_need_as");
	

	
	player line_please("give_me_radio_son", 3.1, "gimmie_son");
	woods line_please("xray_move_up_perch", 2,"apcchain1_go");
	
	woods line_please("shit", 0, "tank_ok_to_target");
	bowman line_please("t55_on_us",0.2);
	

	
	woods line_please("mason_tag_sob", 0.5);
	
	woods line_please("xray_move_up", 3.5, "street1_tank_dead_now");
	woods line_please("lz_half_click", 10);

	transition_dialogue(woods, bowman, player, pilot, extra, reznov);

}

transition_dialogue(woods, bowman, player, pilot, extra, reznov)
{

	
	pilot line_please("evasive_action", 0, "skydemon_taking_aa_fire");
	pilot line_please("texas_pulling_out",1.5);
	player line_please("understood_texas");
	
	//mason line_please("get_gate_open", 0.5);
	bowman line_please("zsu_second_floor", 0, "through_alley_gate" );
	woods line_please("street_beating_zone", undefined, undefined, "playboy_blowthrough_go");
	reznov line_please("use_building_flank", undefined, undefined, "playboy_blowthrough_go");
	flag_set("street_beating_zone_said");
	
	level.bowman line_please("got_a_t55", 0, "get_off_street_go" );
	level.bowman line_please("get_off_street",2.4 );	
	level.player line_please("jesus..");

	woods line_please("lets_move_to_zsu", 6.0, "playboy_ohshit_go");
	bowman line_please("got_it");
	
	reznov line_please("still_1_piece", 0.5, "flashback_done");
	player line_please("im_good");		
	
	//woods line_please("blocked_up_stairs", 0.5, "in_alley_stair_room");
	woods Line_please("mason!!", 0, "alley_balcony_fell");
	woods Line_please("u_ok_bro", 1);
	
	player Line_please("still_breathing");
	player Line_please("we_meet_u_at_rp");
	
	//extra line_please("xray_pick_it_up", 0, "player_is_before_balcony");
	//woods line_please("hold_ground");

	waittill_ai_group_cleared("aagun_protection_guys");
	autosave_by_name("at_aa_gun");
	
	player line_please("zsu_above_us", 0.5, undefined, "c4_planted");
	reznov line_please("charge_ceiling", undefined, undefined, "c4_planted");
	extra line_please("charlie_in_pocket", 0, "c4_planted","aagun_blown" );
	player line_please("3_seconds", undefined, undefined, "aagun_blown");
	reznov line_please("get_safe_distance", undefined, undefined, "aagun_blown");
	
	reznov line_please("good_work_mason", 2,"aagun_blown" );
	wait 5;
}


chopper_support_killtank_reminder_voiceover()
{
	reminders[0] = SpawnStruct();
	reminders[0].actor = level.woods;
	reminders[0].line = "mason_tag_sob";
	
	reminders[1] = SpawnStruct();
	reminders[1].actor = level.bowman;
	reminders[1].line = "t55_killing_us";
	
	reminder = reminders[RandomInt(reminders.size)];
	reminder.actor line_please(reminder.line);
}


chopper_support_request_voiceover(attackspot, danger_close)
{
	requests = [];
	requests[0] = "target_is_tagged";
	requests[1] = "ordinance_my_mark";
	requests[2] = "marking_coordinates";
	requests[3] = "target_marked";
	flag_set("requesting_air_support");
	
	
	request = requests[RandomInt(requests.size)];
	if (IsDefined(danger_close) && cointoss() )
	{
		request = "hit_danger_close";
	}

	if (!IsDefined(level._first_airstrike_called))
	{
		level._first_airstrike_called = 1;
		flag_set("first_airstrike_called");
		//TUEY (moved) setting music state CROSBY_BUILD
		setmusicstate("CROSBY_BUILD");
		
		if ( IsDefined(level._since_auth_been_said) && level._since_auth_been_said > 4 )
		{
			// do nothing, call in the air support line normal because it has been awhile since player talked into radio
			level._first_airstrike_called++;
		}
		else
		{
			flag_clear("requesting_air_support");
			return;
		}
	}

	if (attackspot IsTouching(GetEnt("chopperstrike_zone5", "targetname")) )
	{
		wait 0.1; // have to wait so flag can get set
		if (flag("chopperstrike_5_called") && !flag("street1_tank_dead_now") ) // check to see if play tank_specific VO
		{
			tankrequests = [];
			//tankrequests[0] = "texas_on_t55";
			tankrequests[0] = "enemy_armor";
		
		
			request = tankrequests[RandomInt(tankrequests.size)];
			level.player line_please(request);
			flag_clear("requesting_air_support");
			return;
		}
	}
	
	level.player line_please(request);
	flag_clear("requesting_air_support");
}

chopper_support_custom_confirm_check(attackspot)
{
	myvolume = undefined;
	custom_building_volumes = GetEntArray("custom_building_volumes", "script_noteworthy");
	for (i=0; i < custom_building_volumes.size; i++)
	{
		if (attackspot IsTouching(custom_building_volumes[i]))
		{
			myvolume = custom_building_volumes[i];
			break;
		}
	}
	if (!IsDefined(myvolume))
	{
		return undefined;
	}
	
	type = myvolume.targetname;
	myline = "copy_"+type;
	return myline;
}

chopper_support_confirm_kills_voiceover(tank_killed)
{
	confirm_kills = [];
	confirm_kills[0] = "target_eliminated";
	confirm_kills[1] = "enemy_down";
	confirm_kills[2] = "multiple_kha";
	confirm_kills[3] = "mul_conf_kill";
	
	confirm_kill = confirm_kills[RandomInt(confirm_kills.size)];
	if (IsDefined(tank_killed))
	{
		confirm_kill = "armor_destroyed";
	}
	
	level._pilot line_please(confirm_kill);
	
	if (cointoss())
	{
		reznov_cheer = [];
		reznov_cheer[0] = "excellent";
		reznov_cheer[1] = "rain_fire";
		reznov_cheer[2] = "keep_on_them";
		reznov_cheer[3] = "fight_by_side_once_more";
		level.reznov thread line_please(reznov_cheer[RandomInt(reznov_cheer.size)], 0.6);
	}
	
}
	

chopper_support_confirm_voiceover(attackspot, danger_close)
{
	if (!IsDefined(attackspot))
	{
		attackspot = level.player;
	}
	
	custom_confirm = chopper_support_custom_confirm_check(attackspot);
	
	confirms = [];
	confirms[0] = "we_are_inbound";
	confirms[1] = "copy_hold_tight";
	confirms[2] = "understood_engaging";
	confirms[3] = "affirmative_heads_down";
	confirms[4] = "texas_on_its_way";
	confirms[5] = "support_on_its_way";

	confirm = confirms[RandomInt(confirms.size)];
	
	danger_close_confirms = [];
	danger_close_confirms[0] = "understood_clear_squad";
	danger_close_confirms[1] = "affirmative_clear_area";
	woods_dc_confirms = [];
	woods_dc_confirms[0] = "clear_area_danger_close";
	woods_dc_confirms[0] = "first_squad_get_out";
	
	if (level._first_airstrike_called ==1 )
	{
		flag_wait("authorization_operation_said");
		level._first_airstrike_called++;
		
		if (IsDefined(level._since_auth_been_said) && level._since_auth_been_said > 3 )
		{
			// do nothing, deliver normal response
		}
		else
		{
			return;
		}
	}
	
	chop5zone = GetEnt("chopperstrike_zone5", "targetname");
	
	if (IsDefined(chop5zone) && attackspot IsTouching(chop5zone) )
	{
		wait 0.1; // have to wait so flag can get set
		if (flag("chopperstrike_5_called") && !flag("street1_tank_dead_now") ) // check to see if play tank_specific VO
		{
			tankconfirms = [];
			tankconfirms[0] = "rain_down_hell";
			tankconfirms[1] = "coming_strafing_run";
	
			if (!flag("enemytank1_almost_inplace"))
			{
				confirm = "strafe_will_be_late";
				level.player line_please(confirm);
				flag_wait("tank_strafe_commencing");
				confirm = "late_strafe_ready";
				level.player line_please(confirm);
				return;
			}

	
			tankconfirm = tankconfirms[RandomInt(tankconfirms.size)];
			level._pilot line_please(tankconfirm);
			return;
		}
	}
	
	if (IsDefined(danger_close))
	{
		danger_close_confirm = danger_close_confirms[RandomInt(danger_close_confirms.size)];
		woods_dc_confirm = woods_dc_confirms[RandomInt(woods_dc_confirms.size)];
		level._pilot line_please(danger_close_confirm);
		level.woods line_please(woods_dc_confirm);
		return;
	}
	
	if (IsDefined(custom_confirm)&& cointoss() ) // don't guarantee custom confirm
	{
		confirm = custom_confirm;
	}
	
	level._pilot line_please(confirm);
}


chopper_support_negative_voiceover(denied)
{
	
	negatives = [];
	negatives[0] = "negative_friendlies";
	negatives[1] = "coordinates_on_friendlies";
	negatives[2] = "negative_invalid_target";

	negative = negatives[RandomInt(negatives.size)];
	
	if (IsDefined(denied) ) // don't guarantee custom confirm
	{
		negative = negatives[2];
	}
	
	level._pilot line_please(negative);
}

chopper_support_reminder_voiceover()
{

	if (flag("tank_ok_to_target") && !flag("street1_tank_dead_now") )
	{
		return;
	}

	reminders = [];

	reminders[0] = SpawnStruct();
	reminders[0].actor = level._pilot;
	reminders[0].line = "requesting_coordinates";
	
	reminders[1] = SpawnStruct();
	reminders[1].actor = level._pilot;
	reminders[1].line = "texas_standing_by";
	
	reminders[2] = SpawnStruct();
	reminders[2].actor = level._pilot;
	reminders[2].line = "waiting_for_command";
	
	reminders[3] = SpawnStruct();
	reminders[3].actor = level.woods;
	reminders[3].line = "mason_use";

	reminder = reminders[RandomInt(reminders.size)];
	reminder.actor line_please(reminder.line);
}

	
lower_friendly_for_aicount()
{
	level endon ("aagun_blown");
	aimax = 18;
	friendly_min = 3;
	while(1)
	{
		flag_waitopen("dont_clear_friendlies");
		killed = 0;
		ai = GetAIArray();
		if (ai.size > aimax)
		{
			guys = get_ai_array("e2_allies");
			for (i=0; i < guys.size; i++)
			{
				if ( get_ai_array("e2_allies").size < 4)
				{
					continue;
				}
				guys[i] killme();
				killed++;
				if (killed > 2)
				{
					break;
				}
			}					
		}
		wait 1;
	}
}
	
disable_for_high_aicount()
{
	
	self endon ("death");
	axismax = 17;
	self waittill_any ("enable", "trigger");
	
	while(1)
	{
		axis = GetAIArray("axis");
		if (axis.size > axismax)
		{
			spawn_manager_disable(self.targetname); 
			self thread kill_my_guys();
			delaythread (3,::kill_excess_enemies);
			
			while(1)
			{
				axis = GetAIArray("axis");
				if (axis.size < axismax - 3)
				{
					spawn_manager_enable(self.targetname); 
					break;
				}
				wait 0.3;
			}
		}
		wait 0.3;
	}
}

kill_excess_enemies()
{
	amount_to_kill = 3;
	ai = get_ai_array("non_essential_street_ai");
	guys = get_array_of_closest( level.player.origin, ai );
	killed = 0;
	{
		for (i=guys.size; i > 0; i--)
		{
			killed++;
			guys[i] thread wait_and_kill(RandomFloat(3));
			if (killed > 2)
			{
				return;
			}
		}
	}
}

kill_my_guys()
{
	myguys = get_ai_array(self.target+"_ai", "targetname");
	for (i=0; i < myguys.size; i++)
	{
		myguys[i] thread wait_and_kill(RandomFloat(2) );
	}
}

sky_cowbell()
{
	trigger_wait("street_redshirts_1", "target");
	//kevin adding audio for heli audio
	playsoundatposition( "evt_heli_flyby" , (-3663,1840,8208) );
	
	travel_offset = (-15000,0,0);
	level thread street_chopper_group( travel_offset, "sky_cowbell_1", 30);
	trigger_wait("sky_cowbell_2_trig");
	//kevin adding audio for jet audio
	playsoundatposition( "evt_jet_flyby1" , (-3663,1841,8208) );
	travel_offset = (-17000,0,0);
	level thread streets_jets_group("sky_cowbell_2", undefined, 3.5);
	//kevin adding audio for jet audio and sending notify
	playsoundatposition( "evt_jet_flyby2" , (-3663,1841,8208) );
	level notify( "bomb_drop" );

	
	flag_wait("apcchain1_go");
	travel_offset = (0,15000, 0);
	level thread street_chopper_group( travel_offset, "sky_cowbell_2b", 25);
	
	travel_offset = (0,30000,0);
	level thread streets_jets_group("sky_cowbell_2a", travel_offset, 4);
	wait 3;
	
	
	trigger_wait("sky_cowbell_3_lookat_trig");
	level thread streets_jets_group("sky_cowbell_3", undefined, 3.5); 
	wait 4;
	level thread streets_jets_group("sky_cowbell_4", undefined, 3.5); 
	
	flag_wait("apcchain4_go");
	while(!flag("apcchain5_go"))
	{
		level thread street_chopper_group( undefined, "sky_cowbell_5", 40);
		wait 60;
	}
}

model_spotlight(complete_notify)
{
	struct = getstruct("model_spotlight_struct", "targetname");
	
	PlayFXOnTag(level._effect["huey_main_blade"], self, "main_rotor_jnt");
	//vista moveto (target, traveltime);
			// mock tag_flash_gunner4_spot
	ang1 = AnglesToForward(self.angles);
	ang2 = AnglesToUp(self.angles);
	offset = (ang1 * 140 )+( ang2*-135);

	myorigin = self GetTagOrigin("tag_origin");
	org = self.origin+ offset;

	
	
	spot = spawn_a_model("tag_origin", org, self.angles );
	spot RotatePitch(52, 0.05);
	spot waittill ("rotatedone");
	//spot thread move_along_with(self, "sky_cowbell_1_done", offset, "tag_origin");
	PlayFXOnTag(level._effect["spotlightd"],spot, "tag_origin");
	spot LinkTo(self );

	level waittill (complete_notify);

	spot Delete();
}

streets_jets_group(mytargetname, offset, time)
{
	structs = getstructarray(mytargetname, "targetname");
	jets = [];
	
	//optimizing by removing 2 vehicles from each group
	group_size = structs.size; 
	if( group_size - 2 > 0 )
	{
		group_size = group_size - 2;
	}
	
	for (i=0; i < group_size; i++)
	{
		jets[i] = spawn_a_model("t5_veh_jet_f4_gearup_lowres", structs[i].origin, structs[i].angles);
		playfxontag(level._effect["jet_contrail"], jets[i], "tag_left_wingtip");
		playfxontag(level._effect["jet_contrail"], jets[i], "tag_right_wingtip");
		
		if (IsDefined(structs[i].target))
		{
			dest = getstruct(structs[i].target, "targetname").origin;
		}
		else
		{
			dest = jets[i].origin + offset;
		}
		jets[i] SetForceNoCull();
		jets[i] moveto (dest, time);
	}
	
	wait time;
	for (i=0; i < group_size; i++)
	{
		jets[i] Delete();
	}
}

street_chopper_group(travel_offset, mytargetname, traveltime)
{
	structs = getstructarray(mytargetname, "targetname");
	complete_notify = mytargetname+"_done";
	
	jets = [];
	
	//optimizing by removing 2 vehicles from each group
	group_size = structs.size; 
	if( group_size - 2 > 0 )
	{
		group_size = group_size - 2;
	}
	
	for (i=0; i < group_size; i++)
	{
		
		jets[i] = spawn_a_model("t5_veh_helo_huey_vista", structs[i].origin, structs[i].angles);
		jets[i] Attach ( "t5_veh_helo_huey_att_interior_vista", "tag_body");
		
		blades = jets[i] GetTagOrigin( "tag_body" );
		jets[i].sound_ent = spawn ("script_origin", blades);
		jets[i].sound_ent linkto(jets[i], "tag_body");
		jets[i].sound_ent playloopsound ("veh_hind_rotor_special");
		
		if (IsDefined(structs[i].script_noteworthy) )
		{
			if (structs[i].script_noteworthy == "spotlight")
			{
				jets[i] thread model_spotlight(complete_notify);
			}
		}
		
		if (IsDefined(structs[i].target))
		{
			target = getstruct(structs[i].target, "targetname").origin;
		}
		else
		{
			target = jets[i].origin + travel_offset;
		}
		playfxontag(level._effect["huey_main_blade"], jets[i], "main_rotor_jnt");
		playfxontag(level._effect["chopper_tail_rotor"], jets[i], "tail_rotor_jnt");
		wait 0.1;
		jets[i] SetForceNoCull();
		jets[i] moveto (target, traveltime);
	}
	
	wait traveltime;
	for (i=0; i < group_size; i++)
	{
		if(isDefined(jets[i]))
		{
			jets[i].sound_ent delete();
			jets[i] Delete();
		}
	}
	
	level notify (complete_notify);
}

balcony_fallout()
{
	flag_wait("chopperstrike_1_called");
	level waittill("balcony_start");  
	
	balcony = GetEntArray("balcony_crash", "targetname");
	for (i=0; i < balcony.size; i++)
	{
		RadiusDamage(balcony[i].origin, 300, 1000, 500); 
		//balcony[i] disconnectpaths();
		balcony[i] Delete();
	}
	clip = GetEnt("balcony_fell_mclip", "targetname");
	clip trigger_on();
	clip DisconnectPaths();
}

authorization_operation_said_timer()
{
	flag_wait("authorization_operation_said");
	if (IsDefined(level._first_airstrike_called) )
	{
		level thread chopper_support_confirm_voiceover();
	}
	else
	{
		level._pilot thread line_please("affirmative_xray");
		level._since_auth_been_said = 0;
		while (!IsDefined(level._first_airstrike_called) )
		{
			level._since_auth_been_said++;
			wait 1;
		}
	}
	

}

alley_flank_ai_behavior()
{
	trigger_wait("alley_obj_trig_2", "script_noteworthy");
	level.player SetThreatBiasGroup("player_ignored");
	flag_set("ignore_player_now");
	guys = get_ai_array("alley_enemies");
	guys = array_add(guys, get_ai("alley_balcony_guys") );
	for (i=0; i < guys.size; i++)
	{
		guys[i] thread maps\hue_city_ai_spawnfuncs::ignore_player_onflag_setup();
	}
	wait 5;
	level.player SetThreatBiasGroup("player");
}

tank_balcony_speed_control()
{
	node = GetVehicleNode("tank_in_good_balconyshot_position", "script_noteworthy");
	node waittill ("trigger");
	flag_set("tank_in_good_balconyshot_position");
	tank = GetEnt("alley_tank", "targetname");
	tank SetSpeed(0,10,10);
	
	flag_wait("player_on_alley_balcony");
	tank ResumeSpeed(5);
}

tank_knockdown_balcony()
{
	GetEnt("aa_gun_dest_balcony_d", "targetname") Hide();
	
	level thread tank_balcony_speed_control();
	
	trigger_wait("player_near_alley_balcony");
	tank = GetEnt("alley_tank", "targetname");
	trig = GetEnt("alleytank_balcony_firetrig", "targetname");
	if (!flag("tank_in_good_balconyshot_position"))
	{
		tank SetSpeed(3.5,5,5);
	}
	
	trigger_wait("player_on_alley_balcony");
	
	if (!flag("tank_in_good_balconyshot_position"))
	{
		tank SetSpeed(5.5,5,5);
	}
	
	level notify ("stop_alley_tank_fire_loop");
	tank SetTurretTargetEnt(trig );
	
	trig waittill ("trigger");
	exploder(703);
	tank FireWeapon();
	wait 0.05;
	
	alley_balcony_fall();
}
	
	
alley_balcony_fall()
{
	hud_hide();	
	Objective_Set3D( 4, 0);
	
	start_movie_scene();
	add_scene_line(&"hue_city_vox_hue1_s01_702A_maso", 2.5, 4.5);		//I couldn't believe Reznov was here in Hue City.  That he was the defector.
	add_scene_line(&"hue_city_vox_hue1_s01_703A_inte", 7, 4);		//He came back for you Mason. Reznov was back.

	level.movie_trans_in = "black";
	level.movie_trans_out = "black";
	level thread play_movie("mid_hue_city_2", false, false, "start_flashback",true, "flashback_done", 1);
	//-- GLocke: Reset Dvar used during movie playback
	SetSavedDvar("r_streamFreezeState", 1);
	
	level.reznov disable_ai_color();
	level.reznov forceteleport(getstruct("alley_floorfall_hero_warpspot", "targetname").origin);

	exploder(704);
	
	level.player thread magic_bullet_shield();
	wait 0.05;
	origspeed = Int(GetDvar("g_speed")) ;
	SetSavedDvar("g_speed", 5);
	
	level.player SetStance("crouch");
	linker = Spawn_a_model("tag_origin", level.player.origin);
	level.player PlayerLinkToDelta(linker, "tag_origin", 1, 90,90,90,90); 
	spot = getstruct("balcony_collapse_endspot", "targetname");
	linker moveto (spot.origin, 0.4);
	level.player DisableWeapons();
	
	Earthquake(0.9, 2, level.player.origin, 1000);
	level.player PlayRumbleOnEntity("explosion_generic");
	level.player PlayRumbleOnEntity("melee_garrote");
	level thread wait_and_stoprumble(1.7, "melee_garrote");
	level.player ShellShock("tankblast", 3.5);

	balcony = GetEnt("aa_gun_dest_balcony", "targetname");
	balcony Delete();
	GetEnt("aa_gun_dest_balcony_d", "targetname") Show();
	
	level thread shake_player_ref();

 	level.player ShellShock("quagmire_window_break", 3);
	level.player disableoffhandweapons();
	level.player thread player_speed_set(origspeed, 8);
	flag_set("alley_balcony_fell");	
	
	
	//wait 0.4;
	wait(2.0);
	level notify("start_flashback");
	level.player SetStance ("prone");

	//remove any corpses from previous events
	ClearAllCorpses();

	level waittill("flashback_done");
	//-- GLocke: Reset Dvar used during movie playback
	SetSavedDvar("r_streamFreezeState", 0);
	flag_set("flashback_done");
	level.player Unlink();
	linker Delete();
	
	level.player EnableWeapons();
	

	
	Objective_Set3D( 4, 1, "default", "" );
			
	
	//level thread safe_forced_save();
	wait 2;
	level.reznov enable_ai_color();
	wait 2;
	level.player stop_magic_bullet_shield();
	
	level.player SetClientDvar( "hud_showStance", "1" ); 
	level.player SetClientDvar( "compass", "1" ); 
	level.player SetClientDvar( "ammoCounterHide", "0" );
}

shake_player_ref()
{
	level.ground_ref_ent = Spawn( "script_model", ( 0, 0, 0 ) );
	level.player PlayerSetGroundReferenceEnt( level.ground_ref_ent );
	
	tilt_point = (7, 40, -20 );
	angles = level.player adjust_angles_to_player( tilt_point );
	level.ground_ref_ent rotateto( angles, 1 );
	level.ground_ref_ent waittill ("rotatedone");
	
	tilt_point = (-7, -40, 5 );
	angles = level.player adjust_angles_to_player( tilt_point );
	level.ground_ref_ent rotateto( angles, 1 );
	level.ground_ref_ent waittill ("rotatedone");
	
	level.ground_ref_ent rotateto( (0,0,0), 1 );
	level.ground_ref_ent waittill ("rotatedone");
}

drag_player_towards_spot(spot, startrate)
{
	linker = spawn_a_model("tag_origin", level.player.origin, level.player.angles);
	level.player playerlinktodelta(linker, "tag_origin", 1, 10,10,90,90); 
	counter = 1;
	if (IsDefined(startrate))
	{
		counter = startrate;
		PlayFXOnTag(level._effect["def_explosion"], linker, "tag_origin");
		linker RotateTo(spot.angles, 1);
	}
	
	while( DistanceSquared(level.player.origin, spot.origin) > (50*50) ) 
	{
		vec = spot.origin - level.player.origin;
		nvec = VectorNormalize(vec);
		dest = linker.origin + (nvec*counter);
		linker moveto (dest, 0.1);
		linker waittill ("movedone");
		counter+=3;
	}
	level.player Unlink();
	linker Delete();
	
}

delete_chopper_volume_stuff()
{
	stuff = array_combine(GetEntArray("chopper_zones", "script_noteworthy"), GetEntArray("player_zones", "script_noteworthy") );
	stuff = array_combine(stuff, GetEntArray("chopperstrike_zones", "script_noteworthy") );
	stuff = array_combine(stuff, GetEntArray("custom_building_volumes", "script_noteworthy") );
	stuff = array_combine(stuff, GetEntArray("custom_building_volumes", "script_noteworthy") );
	stuff = array_combine(stuff, GetEntArray("street_section_2_trigs", "script_noteworthy") );
	for (i=0; i < stuff.size; i++)
	{
		if (IsDefined(stuff[i]))
			stuff[i] Delete();
	}

}

street_end_ready_and_go()
{
	flag_wait("street_end_ready");
	autosave_by_name("at_end_of_street");
	wait 90;
	flag_set("street_end_go");
}

street_mg_turret_setup()
{
	mg1 = GetEnt("1st_building_mg", "targetname");
	mg1 thread street_mg_turret_loop("chopperstrike_1_called");
	
	mg2 = GetEnt("2nd_building_mg", "targetname");
	mg2 thread street_mg_turret_loop("chopperstrike_2_called");
	
//	mg3 = GetEnt("end_building_mg", "targetname");
//	mg3 thread street_mg_turret_loop("chopperstrike_5_called");
}
	
street_mg_turret_loop(ender)
{
	level endon (ender);
	while(1)
	{
		if (!IsDefined( self GetTurretOwner() ) )
		{
			ai = GetAIArray("axis");
			for (i=0; i < ai.size; i++)
			{
				if (DistanceSquared(ai[i].origin, self.origin) < (60*60) )
				{
					ai[i] maps\_spawner::use_a_turret(self);
					wait 3;
					break;
				}
			}
		}
		wait 1;
	}
}

event2_threatbias_management()
{
//	if ( is_hard_mode() )
//	{
//		return;
//	}
	//level.player SetThreatBiasGroup("player");
	level.player SetThreatBiasGroup("player_ignored");
	level waittill ("clear_clearzone");	// called when section 2 is clear, signal retreat
	level.player SetThreatBiasGroup("player");
	set_generic_threatbias(1500);
	
	flag_wait("apcchain4_go");
	set_generic_threatbias(3000);
	
	flag_wait("tank_ok_to_target");
	set_generic_threatbias(4000);
		
	flag_wait("chopperstrike_5_called");
	autosave_by_name("took_tank_out");
	level.player SetThreatBiasGroup("player_ignored");
	level.player.ignoreme = true;
	
	flag_wait("end_strafe");
	level.player SetThreatBiasGroup("player");
	level.player.ignoreme = false;
	set_generic_threatbias(2000);
	
	if ( level.gameskill == 0)
	{
		set_generic_threatbias(3000);
		return;
	}
	
	wait 60;
	set_generic_threatbias(1500);
}

post_tank_retreat()
{
	flag_wait("end_strafe");
	nodes = GetNodeArray("post_tank_strafe_retreat_nodes", "script_noteworthy");
	
	axis = GetAIArray("axis");
	for (i=0; i < axis.size; i++)
	{		
		if (axis[i].origin[0] < -2700 && axis[i].origin[2] < 7600) 
		{
			nodes = GetNodeArray("post_tank_strafe_retreat_nodes", "script_noteworthy");
			for (j=0; j < nodes.size; j++)
			{
				if (!IsDefined(nodes[j]._retreated_to) )
				{
					axis[i] disable_cqbwalk();
					axis[i] thread force_goal(nodes[j], 256);
					nodes[j]._retreated_to = 1;
					break;
				}
			}
		}
	}
}

street_fire_locations()
{
	macv_fire_trigs = GetEntArray("macv_fire_locations", "script_noteworthy");
	for (i=0; i < macv_fire_trigs.size; i++)
	{
		macv_fire_trigs[i] Delete();
	}
	
	structs = getstructarray("street_fire_locations", "script_noteworthy");
	for (i=0; i < structs.size; i++)
	{
		trig = Spawn("trigger_radius", structs[i].origin, 0, structs[i].radius, 60);
		trig.targetname = structs[i].targetname;
		trig.script_noteworthy = structs[i].script_noteworthy;
		trig thread trig_burn_u();
	}
}

tankstop_spot_b4_aagun()
{
	node = GetVehicleNode("tankstop_spot_b4_aagun", "script_noteworthy");
	node waittill ("trigger");
	tank = GetEnt("alley_tank", "targetname");
	tank endon ("death");
	
	tank SetSpeed(0,5,5);
	flag_wait("aagun_blown");
	tank SetSpeed(2.5,5,5);
	spot = getstruct("alleytank_final_target", "targetname").origin;
	
	tank SetTurretTargetVec( spot );
	wait 5;
	tank FireWeapon();
	wait 5;
	tank FireWeapon();
}

delete_early_e2_trigs()
{
	delete_array("early_e2_trigs", "script_noteworthy");
	for (i=1; i < 13; i++)
	{
		trig = GetEnt("macv_obj_trig_"+i, "script_noteworthy");
		if (IsDefined(trig))
		{
			trig Delete();
		}
	}
}


clear_guys_near_etank1()
{
	flag_wait("tank_strafe_commencing");
	kill_spawnernum(4);
	axis = GetAIArray("axis");
	for (i=0; i < axis.size; i++)
	{
		if (axis[i].origin[0] < -3292 || axis[i].origin[1] > 1236)
		{
			axis[i] thread wait_and_kill(RandomFloat(5));
		}
	}
}


event2_playersprint_failsafe()
{
	level.player endon("death");
	level endon("tank_strafe_commencing");
	
	trigger_wait("street_converge");
		
	tank = GetEnt("enemytank1", "targetname");
	while(!isDefined(tank))
	{
		wait(.1);
		tank = GetEnt("enemytank1", "targetname");
	
	}
	while(1)
	{
		//iprintlnbold("player " + level.player.origin[0], ", tank: " + tank.origin[0]);
		if( level.player.origin[0] > tank.origin[0] )
		{
			player = level.player;	
			player stop_magic_bullet_shield();
			Earthquake( .55, 3, player.origin, 500 ); 
			player dodamage(player.health +1000, player.origin);
			wait(1.5);
			missionFailedWrapper();	
		}
		wait(.1);
	}	
}


take_player_weapons()
{
	self.weaponInventory = self GetWeaponsList();
	self.lastActiveWeapon = self GetCurrentWeapon();

	self.weaponAmmo = [];
	
	for( i = 0; i < self.weaponInventory.size; i++ )
	{
		weapon = self.weaponInventory[i];
		
		self.weaponAmmo[weapon]["clip"] = self GetWeaponAmmoClip( weapon );
		self.weaponAmmo[weapon]["stock"] = self GetWeaponAmmoStock( weapon );
	}
	
	self TakeAllWeapons();
}

giveback_player_weapons()
{
	ASSERTEX( IsDefined( self.weaponInventory ), "player.weaponInventory is not defined - did you run take_player_weapons() first?" );
	
	for( i = 0; i < self.weaponInventory.size; i++ )
	{
		weapon = self.weaponInventory[i];
		
		self GiveWeapon( weapon );
		self SetWeaponAmmoClip( weapon, self.weaponAmmo[weapon]["clip"] );
		self SetWeaponAmmoStock( weapon, self.weaponAmmo[weapon]["stock"] );
	}
	wait(.1);
	// if we can't figure out what the last active weapon was, try to switch a primary weapon
	if( self.lastActiveWeapon != "none" )
	{
		self SwitchToWeapon( self.lastActiveWeapon );
	}
	else
	{
		primaryWeapons = self GetWeaponsListPrimaries();
		if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
		{
			self SwitchToWeapon( primaryWeapons[0] );
		}
	}
}

no_longer_ignore_player()
{
	trigger_wait("sky_cowbell_3_trig");
	level.player.ignoreme = false;
	
}