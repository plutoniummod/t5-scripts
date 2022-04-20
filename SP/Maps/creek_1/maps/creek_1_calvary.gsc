#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_music;
#include maps\creek_1_assault;
#include maps\creek_1_util;

calvary_main()
{
	level thread extra_hueys_distance();
	level thread aa_gun();
	// level thread calvary_real_aa();
	level thread calvary_setup();
	level thread beat_3_wooden_island_init();
	level thread beat_3_play_island_hut_explosion();
	level thread beat_3_island_hut_damaged();
	
	wait( 1 );
	/*
	add_spawn_function_veh( "extra_aa_sampans_1", ::custom_calvary_sampan_death );
	add_spawn_function_veh( "extra_aa_sampans_2", ::custom_calvary_sampan_death );
	add_spawn_function_veh( "extra_aa_sampans_3", ::custom_calvary_sampan_death );
	add_spawn_function_veh( "extra_aa_sampans_4", ::custom_calvary_sampan_death );
	add_spawn_function_veh( "extra_aa_sampans_5", ::custom_calvary_sampan_death );
	
	add_spawn_function_veh( "extra_aa_sampans_1", ::load_up_sampan_drones );
	add_spawn_function_veh( "extra_aa_sampans_2", ::load_up_sampan_drones );
	add_spawn_function_veh( "extra_aa_sampans_3", ::load_up_sampan_drones );
	add_spawn_function_veh( "extra_aa_sampans_4", ::load_up_sampan_drones );
	add_spawn_function_veh( "extra_aa_sampans_5", ::load_up_sampan_drones );
	*/
}

extra_hueys_distance()
{
	add_spawn_function_veh( "huey_extra_aa_1", ::delete_after_aa_destroyed );
	add_spawn_function_veh( "huey_extra_aa_2", ::delete_after_aa_destroyed );
	add_spawn_function_veh( "huey_extra_aa_3", ::delete_after_aa_destroyed );
	wait( 0.5 );
	trigger_use( "spawn_extra_hueys_aa" );
}

delete_after_aa_destroyed()
{
	level waittill( "aa_gun_destroyed" );
	vehicle_node_wait( self.script_string, "script_noteworthy" );
	self delete();
}

load_up_sampan_drones()
{
	level thread load_up_sampan( self );
	
	trigger_wait("water_explosion");

	self notify( "damage" );
	self ai_suicide();
	self SetSpeed( 0, 5 );
}

custom_calvary_sampan_death()
{
	level thread maps\creek_1_assault::custom_sampan_death( self );
}

//handles aa gun destruction
aa_gun()
{
	//setup dead model
	gun_dead = GetEnt( "aa_gun_dead", "targetname");
	gun_dead Hide();
	
	//to do: flag_wait or waittill player is in dock area
	
	// objects
	// trigger
	aa_damage_trigger = GetEnt( "trigger_damage_waterhut_aa", "targetname" );
	int_how_many_hits = 0;
		
	//setup aa gun - should use vehicle
	gun = GetEnt( "aa_gun", "targetname" );
	gun SetCanDamage( true );
	gun.health = 500000;	//doesn't matter 
	
	// wait for the right time
	//flag_wait( "reveal_island_aa" );
	
	gun thread look_aa_fire();
	
	level thread setup_aa_gunner( gun );
	
	level thread aa_gun_destruction( aa_damage_trigger, gun, gun_dead );
	
	level waittill_either( "aa_gun_explosive_hit", "aa_gunner_shot" );

	//trigger_use( "aa_gun_spawn_extra_boats" );
	
	// dialogue for the calvary
	wait( 1 );
	level.hudson thread say_dialogue( "nest_is_empty" );
	wait( 5.0 );
	level.barnes thread say_dialogue( "understood_dock" );
	wait( 1.0 );
	
	/*
	level.barnes thread say_dialogue( "bring_air_support" );
	wait( 4.0 );
	level.hudson thread say_dialogue( "need_birds_now" );
	wait( 4.0 );
	*/
	
	level notify( "calvary_scene_start" );
	trigger_use("trigger_calvary");
	
	// choppers start moving
	level thread maps\_audio::switch_music_wait ("CHOPPERS_INBOUND", 0.1);
	// response from hueys
	player = get_players()[0];
	player say_dialogue( "hornets_inbound" );
	player say_dialogue( "coming_in_hot" );
}

aa_gun_destruction( aa_damage_trigger, gun, gun_dead )
{
	level thread wait_for_player_to_use_m202( aa_damage_trigger );
	level thread wait_for_calvary_to_hit_aa();
	
	level waittill( "aa_gun_explosive_hit" );
	
	
	gun dodamage( gun.health + 100, (0,0,0) );
	level notify( "aa_gun_destroyed" );
	level notify( "zpu_hut_start" );
	
	//play explosion
	PlayFX(level._effect["vehicle_explosion"], gun.origin);
	playsoundatposition( "evt_aa_gun_explode", gun.origin );
	PhysicsExplosionSphere( gun.origin, 512, 256, 1.5 );

	//swap to destroyed model
	gun_dead.origin = gun.origin;
	gun_dead.angles = gun.angles;
	gun_dead Show();
	gun Delete();
	
	PlayFX(level._effect["fx_fire_ember_column_lg"], gun_dead.origin);
	PlayFX(level._effect["fx_smk_plume_hut_sm_white"], gun_dead.origin);
}

wait_for_player_to_use_m202( aa_damage_trigger )
{
	level endon( "aa_gun_explosive_hit" );
	
	while( 1 )
	{
		aa_damage_trigger waittill( "trigger" );
		
		// make sure player has m202
		player = get_players()[0];
		my_weapon = player GetCurrentWeapon();
		if( my_weapon == "m202_flash_magic_bullet_sp" || my_weapon == "m202_flash_sp" )
		{
			level notify( "aa_gun_explosive_hit" );
			break;
		}
	}
}

wait_for_calvary_to_hit_aa()
{
	level endon( "aa_gun_explosive_hit" );
	
	trigger_wait("trigger_calvary");
	
	level waittill( "huey4_water2" );
	wait( 1.0 );
	
	level notify( "aa_gun_explosive_hit" );
}

look_aa_fire()
{
	self endon( "death" );
	level endon( "aa_gun_destroyed" );
	level endon( "aa_gunner_shot" );
	
	self.shooting_turrets = false;
	
	self thread aa_gun_audio();
	
	self thread pick_targets();
	while( 1 )
	{
		if( self.shooting_turrets == true )
		{
			self FireWeapon();
			
		}
		wait( 0.05 );
	}
}

aa_gun_audio()
{
	self endon( "death" );
	level endon( "aa_gun_destroyed" );
	level endon( "aa_gunner_shot" );
	
	sound_ent = spawn( "script_origin" , self.origin);
	sound_ent thread audio_ent_delete();
	
	while(1)
	{
		while( self.shooting_turrets == false )
		{
			wait( 0.05 );
		}
		while( self.shooting_turrets == true )
		{
			sound_ent playloopsound( "wpn_50cal_fire_loop_npc" );
			wait( 0.05 );
		}
		sound_ent stoploopsound();
		sound_ent playsound( "wpn_50cal_fire_loop_ring_npc" );
		wait( 0.05 );
	}
}

audio_ent_delete()
{
	level waittill_any( "aa_gun_destroyed" , "aa_gunner_shot" );
	self delete();
}

pick_targets()
{
	self endon( "death" );
	level endon( "aa_gun_destroyed" );
	level endon( "aa_gunner_shot" );
	
	all_targets = getstructarray( "aa_air_target", "targetname" );
	
	while( 1 )
	{
		// pick a random target
		current_targets = [];
		current_targets[0] = all_targets[randomint(all_targets.size)];		
		current_targets[1] = getstruct( current_targets[0].target, "targetname" );
		
		// aim at the first target and start firing
		self SetTurretTargetVec( current_targets[0].origin );
		self waittill( "turret_on_target" );
		self.shooting_turrets = true;
		
		number_of_sweeps = randomintrange( 2, 4 );
		for( i = 1; i < number_of_sweeps + 1; i++ )
		{
			target_index = number_of_sweeps % 2;
			target_pos = current_targets[target_index].origin;
			// add some variations
			target_pos = target_pos + ( randomint( 300 ) - 150, randomint( 300 ) - 150, randomint( 300 ) - 150 );
			self SetTurretTargetVec( target_pos );
			self waittill( "turret_on_target" );
			wait( 1.0 );
		}
		self.shooting_turrets = false;
	}
}

// setup helis and guys
calvary_setup()
{
	level waittill( "calvary_scene_start" );

	// grab all hueys or spawn them
	hueys = GetEntArray ("calvary_huey", "targetname" );
	
	for (i = 0; i < hueys.size; i++)
	{
		//attach script models, etc
		hueys[i] thread calvary_guys();

		//what the hueys will do
		hueys[i] thread calvary_huey_think();
	
		//Audio - Shawn J - flyover sweeteners

		hueys[i] thread calvary_huey_sound_think();	
		
		if (hueys[i].script_string != "huey5")
			{
				hueys[i] thread calvary_huey_sound_swoosh( i );
			}	

	}
}

#using_animtree("generic_human");

setup_aa_gunner( aa_gun )
{
	org_offset = (0,0,-10);
	ang_offset = (0,0,0);
	
	gunner = simple_spawn_single( "aa_gunner" );
	gunner.health = 99999;
	gunner.allowdeath = true;
	
	gunner forceteleport( aa_gun GetTagOrigin( "tag_driver" ) + org_offset, aa_gun GetTagAngles( "tag_driver" ) + ang_offset );
	wait( 0.05 );
	
	linker = spawn( "script_model", aa_gun GetTagOrigin( "tag_driver" ) + org_offset );
	linker.angles = aa_gun GetTagAngles( "tag_driver" ) + ang_offset;
	linker SetModel( "tag_origin" );
	linker linkto( aa_gun, "tag_driver", org_offset, ang_offset);
	
	gunner linkto( linker );
	
	gunner thread aa_gunner_detect_shot( linker );
	
	//gunner LinkTo( aa_gun, "tag_driver", org_offset, ang_offset);
	linker thread anim_loop_aligned( gunner, "fire_loop" );
	
	level waittill( "aa_gun_destroyed" );
	
	if( isdefined( gunner ) )
	{
		gunner Unlink();
		gunner delete();
	}
	
	linker delete();
}

aa_gunner_detect_shot( linker )
{
	self endon( "death" );
	while( 1 )
	{
		self waittill( "damage", amount, attacker, direction, point, dmg_type, modelName, tagName );
		if( isplayer( attacker ) )
		{
			flag_set( "aa_gunner_shot" );
			//self anim_single_aligned( self, "death" );
			//flag_set( "aa_gunner_shot" );
			self StartRagdoll();
			wait( 1.5 );
			self delete();
			return;
		}
	}
}

calvary_guys()
{
	// Pilots

	/*
	pilot1 = spawn("script_model",self.origin + (0,40,0));
	pilot1 SetModel("c_usa_huey_pilot1_fb" );
	pilot1 UseAnimTree(#animtree);

	pilot2 = spawn("script_model",self.origin + (0,40,0));
	pilot2 SetModel("c_usa_huey_pilot1_fb");
	pilot2 UseAnimTree(#animtree);

	pilot1 enter_vehicle(self, "tag_driver");

	pilot2 enter_vehicle(self, "tag_passenger");
	*/
	
	// Huey 5
	if (self.script_string == "huey5")
	{
		load_up_huey( self, true, false, false );
			
		guy1 = simple_spawn_single("huey_guys");
		guy1 enter_vehicle(self, "tag_passenger4");

		guy2 = simple_spawn_single("huey_guys");
		guy2 enter_vehicle(self, "tag_passenger5");

		guy3 = simple_spawn_single("huey_guys");
		guy3 enter_vehicle(self, "tag_passenger2");

		guy4 = simple_spawn_single("huey_guys");
		guy4 enter_vehicle(self, "tag_passenger3");

		self vehicle_override_anim("getout", "tag_passenger4", %ai_huey_creek_passenger_b_lt_switch_exit);
		self vehicle_override_anim("getout", "tag_passenger5", %ai_huey_creek_passenger_b_rt_exit);
		self vehicle_override_anim("getout", "tag_passenger2", %ai_huey_creek_passenger_f_lt_switch_exit);
		self vehicle_override_anim("getout", "tag_passenger3", %ai_huey_creek_passenger_f_rt_exit);

		self.guys = array(guy1, guy2, guy3, guy4);
	}
	else // All the rest (just drones)
	{
		load_up_huey( self, true, false, false );
		/*
		gunner_right = spawn( "script_model",self.origin + (0,40,0) );
		gunner_right SetModel( "c_usa_huey_pilot1_fb" );
		gunner_right UseAnimTree( #animtree );

		guy_right = spawn("script_model",self.origin + (0,40,0));
		guy_right SetModel("c_usa_huey_pilot1_fb");
		guy_right UseAnimTree(#animtree);

		gunner_right enter_vehicle(self, "tag_gunner1");
		guy_right enter_vehicle(self, "tag_passenger3");
		*/
	}
}
	
calvary_huey_think()
{
	//setmusicstate("CHOPPERS_INBOUND");
	
	if( IsDefined( self.script_string ) && self.script_string == "huey1" )
	{
		vehicle_node_wait("huey1_fire", "script_noteworthy");
		
		targ = GetEnt( "huey1", "script_noteworthy" );
		self thread calvary_shoot( targ );
	}
	else if( IsDefined( self.script_string ) && self.script_string == "huey2" )
	{
		vehicle_node_wait("huey2_fire", "script_noteworthy");
		
		targ = GetEnt( "huey2", "script_noteworthy" );
		self thread calvary_shoot( targ );
	}
	else if( IsDefined( self.script_string ) && self.script_string == "huey3" )
	{
		//fire at hut nr aa
		vehicle_node_wait("huey3_fire", "script_noteworthy");
		
		targ = GetEnt( "huey3", "script_noteworthy" );	//script origin b/c jess fx will blow up hut
		self thread calvary_shoot( targ );
	}
	else if( IsDefined( self.script_string ) && self.script_string == "huey4" )
	{
		trigger_wait("water_explosion");

		//fire at water - should thread could mess up later
		//3 targets to be fired in order
		for (i = 0; i < 3; i++)
		{
			targ = GetEnt( "huey4_water" + i, "targetname" );
			self thread calvary_shoot( targ );
			wait(1);
			level notify( "huey4_water" + i );
		}
					
		//fire at far hut
		vehicle_node_wait("huey4_fire", "script_noteworthy");

		targ = GetEnt( "huey4", "script_noteworthy" );
		self thread calvary_shoot( targ );

		//bloody death - cleanup ai
		touch_trigger = getent( "trigger_around_zpu", "targetname" );
		enemies = GetAIArray( "axis" );
		for( i = 0; i < enemies.size; i++ )
		{
			if( enemies[i] istouching( touch_trigger ) )
			{
				enemies[i] delete();
			}
			else
			{
				enemies[i] thread bloody_death( true, RandomInt( 3 ) );
			}
		}
		/* for( i = 0; i < enemies.size; i++ )
		{
			PlayFxOnTag( level._effect["flesh_hit"], enemies[i], "J_Head" );  
			wait( RandomFloat( 0.2 ) );

			if (IsAlive(enemies[i]))
			{
				enemies[i] DoDamage( enemies[i].health + 150, enemies[i].origin );
			}
		} */
	}
	else if( IsDefined( self.script_string ) && self.script_string == "huey5" )
	{
		// trying to fix a hitch when chopper leaves
		self BypassSledgehammer();
		self thread calvary_huey5_think();
	}
}

#using_animtree("creek_1");

//last heli
calvary_huey5_think()
{
	self.health = 99999;
	self thread detect_friendly_fire_fail();
	
	self.animname = "calvary_chopper";
	self thread play_reinforcement_coming_vo();
	
	self UseAnimTree(#animtree);
	
	self SetHoverParams( 0, 0, 0 );

	//fire rocket at dead aa_gun
	//TO DO: add a trig
	//gun_dead = GetEnt( "aa_gun_dead", "targetname");
	//self thread calvary_shoot( gun_dead );
	
	// attach a player clip
	clip = getent( "huey5_playerclip", "targetname" );
	clip.origin = self.origin;
	clip.angles = self.angles;
	clip linkto( self );
	
	vehicle_node_wait("huey5_close_to_dock");
	level notify( "last_calvary_target_done" );
	
	self thread play_reinforcement_arrive_vo();
		
	vehicle_node_wait("huey5_dock");
	self SetSpeed(0);
	wait( 0.5 );
	
	battlechatter_on( "allies" );

	self vehicle_unload();
	
	level thread calvary_huey5_soldiers( self.guys );
		
	flag_set("calvary_scene_finished");
		
	self anim_single(self, "drop_off", "calvary_chopper");
	self SetHoverParams( 20, 5, 2 );
	//add_dialogue_line( "Marine", "Who to you ..." );
	//PlaySoundAtPosition( level.scr_sound["generic"]["who_told_you"], self.origin );
	//////////////////////////////

	flag_set("calvary_is_here");
	level notify( "calvary_unloaded", self.guys );
	
	level thread dialog_rathole_river();
		
	//flag_set("calvary_scene_finished");
	
	//self SetSpeed( 25, 2, 2 );
	self ResumeSpeed( 60 );
	
	//level thread spawn_extra_guys();
	self thread kill_everyone_you_can();

	vehicle_node_wait("calvary_fly_away_node");
//TODO remove this state if its not needed later.
//	setmusicstate("POST_SAMPAN");
	
	vehicle_node_wait("calvary_shoots_village");
	self SetSpeed( 0 );
	
	self thread fire_at_specific_target( "village_huey_5_target_new", "stop_firing" );
	
	wait( 2 );
	level notify( "huey_cleared_next_area" );
	flag_set( "demo_line_5_clear" );
	
	wait( 10 );
	
	self notify( "stop_firing" );
	
	self resumeSpeed( 8 );
	
	/*
	self ClearGunnerTarget( 2 );
	while( 1 )
	{
		self FireGunnerWeapon(2);
		wait .1;
	}
	*/
}

detect_friendly_fire_fail()
{
	while( 1 )
	{
		self waittill( "damage", int_amount, ent_attacker, vec_direction, P, dmg_type );
		if( isplayer( ent_attacker ) && dmg_type == "MOD_PROJECTILE" )
		{
			level maps\_friendlyfire::missionfail();
		}
	}
}

play_reinforcement_coming_vo()
{
	wait( 7 );
	self say_dialogue( "sierra_at_north" );
	//self say_dialogue( "sierra_cleared" );
}
play_reinforcement_arrive_vo()
{
	self say_dialogue( "sierra_cleared" );
	wait( 2 );
	self say_dialogue( "sierra_in_pos" );
	wait( 1 );
	self say_dialogue( "got_it" );
}

calvary_huey5_soldiers( ai_array )
{
	// endon
	
	// objects
	node_array = GetNodeArray( "node_calvary_after_heli", "targetname" );
	
	level.calvary_marines = ai_array;
	
	// wait( 2.0 ); // i think the helicopter is breaking all the paths so the guys don't move
	
	for( i = 0; i < level.calvary_marines.size; i++ )
	{
		if( IsDefined( level.calvary_marines[i] ) && IsAlive( level.calvary_marines[i] ) )
		{
			nodeName = "node_rpg_target_" + i;

			// send each guy to the best node so they don't run into each other
			// this really needs to be done in radiant though
			switch(i)
			{
				case 0:
					nodeName = "node_rpg_target_1";
					break;
				case 1:
					nodeName = "node_rpg_target_4";
					break;
				case 2:
					nodeName = "node_rpg_target_3";
					break;
				case 3:
					nodeName = "node_rpg_target_2";
					break;
			}

			level.calvary_marines[i].goalradius = 24;
			level.calvary_marines[i].ignoreall = 1;
			level.calvary_marines[i].ignoreme = 1;
			level.calvary_marines[i].target = nodeName;
			level.calvary_marines[i] thread calvary_positions_after_chopper( GetNode( nodeName, "targetname"  ) );
			level.calvary_marines[i] thread calvary_marines_ignoreall_false();
		}
		
		wait( 0.05 );
	}
	
	//level thread calvary_rpg_attacker();
}

calvary_marines_ignoreall_false()
{
	self endon( "death" );
	
	wait( 3.0 );
	
	self.ignoreall = 0;
	self.ignoreme = 0;
}

calvary_positions_after_chopper( node )
{
	// endon
	self endon( "death" );
	
	self.script_noteworthy = node.targetname;
	
	old_goalradius = self.goalradius;
	self.ignoreme = 1;
	self.goalraidus = 24;
	// self SetHealth( 55 );
	// self.health = 55;
	
	self SetGoalNode( node );
	self waittill( "goal" );
	self.ignoreme = 0;
	self.goalradius = 512;
}

calvary_rpg_attacker()
{
	// objects
	// spawner
	rpg_spawner = GetEnt( "spawner_rpg_against_calvary", "targetname" );
	// vc
	rpg_vc = 0;
	// node
	fight_node = GetNode( "node_rpg_against_calvary", "targetname" );
	
	flag_wait("calvary_scene_finished");
	
	rpg_vc = simple_spawn_single( rpg_spawner );
	
	if( isdefined( rpg_vc ) )
	{
		rpg_vc endon( "death" );
		old_goalraidus = rpg_vc.goalradius;
		rpg_vc.goalradius = 24;
		rpg_vc.a.allow_weapon_switch = false;
		rpg_vc thread beat_3_rpg_ammo_control(); 
		
		AssertEx( IsDefined( level.calvary_marines ), "calvary marines not defined" );
		
		rpg_vc SetGoalNode( fight_node );
		rpg_vc waittill( "goal" );
		
		target_marine = GetEnt( "node_rpg_target_0", "script_noteworthy" );
		
	//TODO remove this state if its not needed later.
	//	setmusicstate("POST_SAMPAN");
	
		if( IsDefined( target_marine ) && IsAlive( target_marine ) )
		{
			rpg_vc SetEntityTarget( target_marine );
			target_marine waittill( "death" );
			rpg_vc ClearEntityTarget();
		}
		
		rpg_vc.goalradius = old_goalraidus;
	}
}

spawn_extra_guys()
{
	wait 0;
	spawn_manager_enable("sm_after_calvary");
}

kill_everyone_you_can()
{
	self endon("death");

	self SetGunnerTurretOnTargetRange(2, 20);

	has_target = false;
	
	while (true)
	{
		has_target = false;
		all_axis = GetAIArray("axis");
		if (all_axis.size)
		{
			closest_guy = get_closest_living(self.origin, all_axis);
			if (IsDefined(closest_guy))
			{
				has_target = true;
				
				wait .5;
				self SetGunnerTargetEnt(closest_guy, (0,0,0), 0);
				self SetGunnerTargetEnt(closest_guy, (0,0,0), 1);
				self SetGunnerTargetEnt(closest_guy, (0,0,0), 2);
				self waittill("gunner_turret_on_target");
				
				//self FireGunnerWeapon(0);
				//self FireGunnerWeapon(1);
				self FireGunnerWeapon(2);
				wait .1;
				//self FireGunnerWeapon(0);
				//self FireGunnerWeapon(1);
				self FireGunnerWeapon(2);
				wait .1;
				//self FireGunnerWeapon(0);
				//self FireGunnerWeapon(1);
				self FireGunnerWeapon(2);
				wait .1;
				//self FireGunnerWeapon(0);
				//self FireGunnerWeapon(1);
				self FireGunnerWeapon(2);
				wait .1;
				//self FireGunnerWeapon(0);
				//self FireGunnerWeapon(1);
				self FireGunnerWeapon(2);
			}
		}

		if( has_target == false )
		{
			self ClearGunnerTarget(2);
			self FireGunnerWeapon(2);
		}
		wait .2;
	}
}

fire_at_specific_target( name_of_target, end_msg )
{
	self endon( end_msg );
	target_obj = getent( name_of_target, "targetname" );
	
	self SetGunnerTargetEnt( target_obj, (0,0,0), 0);
	self SetGunnerTargetEnt( target_obj, (0,0,0), 1);
	self SetGunnerTargetEnt( target_obj, (0,0,0), 2);
	
	self waittill("gunner_turret_on_target");
	self thread keep_firing_rockets( target_obj, end_msg );
	
	while( 1 )
	{
		//self FireGunnerWeapon(0);
		//self FireGunnerWeapon(1);
		self FireGunnerWeapon(2);
		wait .1;
	}
}

keep_firing_rockets( target_obj, end_msg )
{
	self endon( end_msg );
	self SetTurretTargetEnt( target_obj );
	self waittill("turret_on_target");
	
	wait( 3 );
	for( i = 0; i < 6; i++ )
	{
		self FireWeapon( "", target_obj );
		wait( 0.7 );
	}
}

calvary_shoot( targ )
{
	targ thread calvary_targets_think();

	self SetTurretTargetEnt(targ);
	self waittill("turret_on_target");

	self FireWeapon("", targ);
	wait .25;
	self FireWeapon("", targ);
}

calvary_targets_think()
{
	//check for script_models
	if( self.classname == "script_model" || self.classname == "script_brushmodel")
	{
		self SetCanDamage( true );
		self waittill( "damage" );
		//wait 2;

		//PlayFX(level._effect["water_explode"], self.origin);
		
		//kill ai
		RadiusDamage( self.origin, 1000, 5000, 5000 );
	}
	else
	{
		//otherwise it's a destructible or script_origin
		self waittill( "damage" );
		
		//kill ai 
		RadiusDamage( self.origin, 1000, 1000, 1000 );
	}	
}


beat_3_island_hut_damaged() // -- WWILLIAMS: watches for the damage trigger to be hit
{
	// endon
	
	
	// objects
	// trigger
	explode_trigger = GetEnt( "trigger_blow_wooden_island", "targetname" );
	level.explode_trigger_org = explode_trigger.origin;
	
	// wait for line 3 b to finish
	// level waittill( "ridge_rat_hole_closed" );
	//flag_wait( "ridge_rat_hole_closed" );
	
	while( 1 )
	{		
		explode_trigger waittill( "damage", int_amount, ent_attacker, vec_direction, P, dmg_type );
		
		if( dmg_type == "MOD_PROJECTILE" || dmg_type == "MOD_PROJECTILE_SPLASH" )
		{
			if( ent_attacker.classname == "script_vehicle" || IsPlayer( ent_attacker ) )
			{
				break;
			}
		}
	}
	
	flag_set( "waterhut_start" );
}

beat_3_play_island_hut_explosion() // -- WWILLIAMS: play the fx anim and anything else needed with it
{
	// wait for teh flag
	flag_wait( "waterhut_start" );
	
	//SOUND: C. Ayers - Getting rid of an unneeded sound
	//playsoundatposition( "exp_riverside_hut", level.explode_trigger_org );
	
	exploder( 3002 );
	

}

beat_3_wooden_island_init() // -- WWILLIAMS: flood spawns some vc on the wooden island in the river
{
	// objects
	// trigger
	trigger_start_island = GetEnt( "trigger_start_shoreline", "targetname" );
	
	// wait for line 3 b to finish
	flag_wait( "ridge_rat_hole_closed" );
	
	// trigger wait
	trigger_start_island waittill( "trigger" );
	
	// start the island
	spawn_manager_enable( "waterhut_manager" );
	
	flag_wait( "waterhut_start" );
	
	spawn_manager_kill( "waterhut_manager" );
	
}

// -- STOLEN from Gavin on POW
aa_basic_fire( target ) //self == zsu
{
	if( self maps\_vehicle::is_corpse() )
	{
		//-- zsu is already dead so don't shoot
		return;
	}
	
	self endon("death");
	
	self notify("stop_firing");
	self endon("stop_firing");
		
	burst_fire_time = 2;
	fire_time = 0;
	
	self SetTurretTargetEnt( target );
	
	while(1)
	{
		if(fire_time < burst_fire_time)
		{
			self FireWeapon();
			wait(0.05);
			fire_time += 0.05;
		}
		else
		{
			fire_time = 0;
			random_wait = RandomFloatRange(1.0, 2.0);
			wait(random_wait);
		}
	}
}

calvary_huey_sound_think()
{
	org = spawn("script_origin", self.origin);
	org LinkTo(self);		
			
	org playloopsound ("evt_chopper_sweet");

	while(isdefined(self))
	{		
			wait (.5);
	}
	
	org stoploopsound();
	
	org Delete();
}

calvary_huey_sound_swoosh( i )
{
  self endon( "death" );

  players = get_players();
                
  while( DistanceSquared( self.origin, players[0].origin ) > 1200*1200 )
     {
        wait( 0.1 );
     }
  
  i = i+1;
  
  if( i >= 3 )
    i = 1; 
                
  self PlaySound( "evt_chopper_swoosh_" + i );
}


dialog_rathole_river()
{
	level endon( "demo_line_4_clear" );
	wait( 1 );
	level.hudson thread say_dialogue( "get_a_nade_in_v2" );
	
	wait( 2 );
	clip = getent( "huey5_playerclip", "targetname" );
	clip delete();
}