
#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_music;
#include maps\vorkuta_util;
#include maps\vorkuta;
#include maps\_motorcycle_ride;



event7_main()
{
	level.old_vehicle_damage = level.overrideVehicleDamage;
	level.overrideVehicleDamage = ::e7_vehicle_damage_logic;

	//turn on battlechatter
	battlechatter_off();

	level thread bike_achievement();

	level thread e7_intro();
	level thread e7_init_e7_flags();
	level thread e7_player_bike_setup();
	level thread E7_scripted_fx();
	level thread e7_player_exit_fail();
	level thread e7_power_pole_fall();
	level thread e7_train();
	level thread e7_rez_bike();
	level thread e7_bike_prompts();
	level thread e7_spawn_functions();
	level thread e7_window_exit_enemy_management();
	level thread e7_player_rez_speed_monitor();
	level thread chopper_wind_helper();
	//level thread e7_debug_hud(); //displays bike speed
	level thread e7_chopper();
	level thread chopper_bullets_on_jump();
	level thread e7_window_bullet();
	level thread e7_bridge_rpg_at_player();
	level thread e7_bridge_quad_50_attacks();
	level thread e7_bike_exit_troops_trucks();
	level thread e7_cleanup();
	level thread e7_tracking_player();
	level thread e7_slowmo_manager();
	level thread e7_player_speed_fail_logic();
	level thread e7_reznovs_demise();
	level thread e7_vo();
	level thread bullets_sparks_on_bike_exit();
	level thread truck_fail();

	level thread barricade_collision();	

	level thread e7_rail_trigger_activation();
	level thread player_carjack_setup();
	level thread rez_carjack_setup();
	level thread e7_player_bike_to_truck();
	level thread barrel_truck();
	level thread e7_rez_truck_setup();
	level thread vorkuta_mission_end();

	level thread player_directional_monitor();
	level.ai_motorcycle_death_launch_vector = (380, 380, 40);

	level.POSSIBLE_FOV = .8;

}

bike_achievement()
{
	level.vehicle_achievement_count = 0;

	trigger_wait ("final_turn");

	if(level.vehicle_achievement_count >= 15)
	{
		get_players()[0] giveachievement_wrapper("SP_LVL_VORKUTA_VEHICULAR");
	}

}

bike_achievement_add()
{
	level.vehicle_achievement_count++;
}

#using_animtree ("animated_props");
e7_intro()
{
	addNotetrack_customFunction("reznov", "start_bike", ::e7_intro_bike, "warehouse_intro");
	addNotetrack_customFunction("reznov", "start_tarp", ::e7_pull_tarp, "warehouse_intro");

	//turns on light over Reznov
	exploder(71);

	//make sure Reznov has head look off
	level.reznov LookAtEntity();

	//turn off invisible ramp collision at top
	ramp = GetEnt("ramp","targetname");
	ramp NotSolid();

	anim_node = getstruct("start_e7_bike_rez","targetname");

	b_origin = GetStartOrigin(anim_node.origin, anim_node.angles, %ch_vor_b04_step8_bike);
	b_angles = GetStartAngles(anim_node.origin, anim_node.angles, %ch_vor_b04_step8_bike);

	real_bike = GetEnt("rez_bike","targetname");
	real_bike veh_toggle_tread_fx(0);
	real_bike hide();
	real_bike NotSolid();

	level.warehouse_bike = spawn_anim_model("bike", real_bike.origin, real_bike.angles);

	player = get_players()[0];
	player thread e7_intro_player();
	player TakeAllWeapons();
	level.reznov gun_remove();

	player_body = spawn_anim_model( "player_body" );
	player_body.angles = player GetPlayerAngles();
	player_body.origin = player.origin;
	player PlayerLinkToAbsolute(player_body, "tag_player");

	actors[0] = level.reznov;
	actors[1] = player_body;

	anim_node anim_single_aligned(actors, "warehouse_intro");

	player Unlink();
	player_body Delete();

	//turns off light
	stop_exploder(71);

	player SetClientDvar( "compass", 1 );
	player SetClientDvar("cg_drawfriendlynames", 1);

	//flag to display the objectives
	flag_set("player_recovered");

	//save after the animation is complete
	autosave_by_name("vorkuta_warehouse");

	anim_node thread anim_loop_aligned(level.reznov, "warehouse_intro_loop");

	flag_wait ("player_on_bike");

	ramp Solid();

	level.reznov StopAnimScripted();

	real_bike.origin = b_origin; 
	real_bike.angles = b_angles;
	real_bike Show();
	real_bike Solid();
}

e7_intro_player()
{
	level.fadeToBlack = NewHudElem(); 
	level.fadeToBlack.x = 0; 
	level.fadeToBlack.y = 0;
	level.fadeToBlack.alpha = 0;
	level.fadeToBlack.horzAlign = "fullscreen"; 
	level.fadeToBlack.vertAlign = "fullscreen"; 
	level.fadeToBlack.foreground = false; 
	level.fadeToBlack.sort = 50; 

	self SetBlur(8, 2);

	level.fadeToBlack SetShader( "black", 640, 480 );
	level.fadeToBlack FadeOverTime( 0.5 );
	level.fadeToBlack.alpha = 0.5; 

	wait(1.0);

	level.fadeToBlack FadeOverTime( 1.0 );
	level.fadeToBlack.alpha = 0.0; 

	wait(3.0);

	self SetBlur(4, 2);

	wait(3.0);

	level.fadeToBlack FadeOverTime(2);
	level.fadeToBlack.alpha = 1.0;

	wait(3.0);

	level.fadeToBlack FadeOverTime(2);
	level.fadeToBlack.alpha = 0;

	self SetBlur(1, 3);

	wait(7.5);

	level.fadeToBlack FadeOverTime(2);
	level.fadeToBlack.alpha = 1.0;

	wait(2.0);

	level.fadeToBlack FadeOverTime(2);
	level.fadeToBlack.alpha = 0;

	self SetBlur(0, 3);

	wait(1.0);

	level thread anim_single(self, "freedom", "mason");

	wait(2.0);

	level.fadeToBlack Destroy();
}

e7_intro_bike( reznov )
{
	anim_node = getstruct("start_e7_bike_rez","targetname");

	anim_node anim_single_aligned(level.warehouse_bike, "warehouse_intro");
	anim_node thread anim_loop_aligned(level.warehouse_bike, "warehouse_intro_loop");
	wait(0.5);
	clientNotify ("rez_bike_ready");

	flag_wait("player_on_bike");

	real_bike = GetEnt("rez_bike","targetname");
	real_bike veh_toggle_tread_fx(1);

	level.warehouse_bike StopAnimScripted();
	level.warehouse_bike Delete();
}

e7_pull_tarp( reznov )
{
	level notify("bike_tarp_start");
}

e7_player_exit_fail()
{
	level endon("player_on_bike");

	//hardcoded hack that represents outside of warehouse
	while(get_players()[0].origin[0] < 11248)
	{
		wait(0.05);
	}

	SetDvar( "ui_deadquote", &"VORKUTA_SERGEI_DOOR_FAIL" ); 
	missionFailedWrapper();
}

e7_init_e7_flags()
{

	flag_init ("displaying_speed_warning");
	flag_init ("player_under_bridge");
	flag_init ("player_bike_in_jump_position");
	flag_init ("begin_truck_event");
	flag_init ("train_jump_begin");
	flag_init ("player_jumped_on_train");
	flag_init ("player_dies_by_vehicle");
	flag_init ("player_close_to_truck");
	flag_init ("rez_truck_warped");
	flag_init ("start_train_warp");
	flag_init ("start_roadblock_wind");
	flag_init ("rez_vo_done");
	flag_init ("did_truck_slowmo");
	flag_init ("flag_bike_shotgun_fired");

}


vorkuta_mission_end()
{
	//trigger at end of train tracks. 
	trigger_wait ("end_mission");

	clientnotify( "fdo" );

	level notify("start_movie");

	//remove the compass for the black screen at the end
	get_players()[0] SetClientDvar( "compass", 0 );

	fade_out(0.5);

	level waittill("end_movie");
	level.fade_out_overlay.foreground = true;  // arcademode compatible
	
	//turn off before next level
	SetDvar("r_streamFreezeState", 0);

	nextmission();
}	

enemy_dodge_bike()
{
	self endon("death");

	player = get_players()[0];

	if(!flag("player_on_bike"))
	{
		return;
	}

	while(1)
	{
		distance_check = linear_map(level.player_speed, 0, 60, 200, 600);

		if(Distance2D(player.origin, self.origin) < distance_check)
		{
			if( player is_player_looking_at(self.origin + (0,0,60), 0.5) )
			{
				if(RandomInt(100) < 50)
				{
					anim_generic(self, "roll_right");
				}
				else
				{
					anim_generic(self, "roll_left");
				}
			}

		}
		wait(0.1);		
	}
}


// player invulnerablility handler for bike
turn_off_for_bike_player_damage_override() // self = player
{
	self notify("player_bike_override_end");
	self DisableInvulnerability();
	self.player_bike_invulnurablility_interval_thread_running = undefined;
}

e7_player_damage_control( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	//self = player
	//waittillframeend;
	if( flag( "player_dies_by_vehicle" ) )
	{
		turn_off_for_bike_player_damage_override();

		// this means that the flag is set and player bumped into someone
		flag_clear( "player_dies_by_vehicle" );
		return iDamage;	// this damage is going to be self.health + 100
	}

	// only do this if the player is not dying from vehicle damage
	if( !IsDefined( self.last_damage_time ) 
		|| ( GetTime() > self.last_damage_time + self.player_bike_invulnurablility_interval ) )
	{		
		// here we are going to damage him 
		self.last_damage_time = GetTime();

		// always make sure that the damage is less than max
		if( iDamage > self.motorbike_max_damage )
		{
			iDamage = self.motorbike_max_damage;
		}

		return iDamage;	
	}

	// if it gets here, then no damage
	self EnableInvulnerability();
	self thread bike_disable_invulnerability_over_time( self.player_bike_invulnurablility_interval / 1000 );
	return 0;

}	

//player damage override function while on the truck
player_truck_damage_override( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	if( IsDefined(eAttacker.script_noteworthy) && eAttacker.script_noteworthy == "no_damage" )
	{
		return 0;
	}

	if( !IsDefined( self.last_damage_time ) 
		|| ( GetTime() > self.last_damage_time + self.player_truck_invulnurablility_interval ) )
	{		
		// here we are going to damage him 
		self.last_damage_time = GetTime();

		// always make sure that the damage is less than max
		if( iDamage > self.truck_max_damage )
		{
			iDamage = self.truck_max_damage;
		}
	}
	else
	{
		iDamage = 0;
	}


	return iDamage;	
}

barricade_collision()
{
	trigger = trigger_wait("bike_barricade");
	trigger.who.overridePlayerDamage = undefined;
	trigger.who DisableInvulnerability();
	trigger.who DoDamage(trigger.who.health + 1000, trigger.who.origin);
}

bike_disable_invulnerability_over_time( time )
{
	self endon( "player_bike_override_end" );

	if( IsDefined( self.player_bike_invulnurablility_interval_thread_running ) )
		return;

	self.player_bike_invulnurablility_interval_thread_running = 1;

	wait( time );

	self DisableInvulnerability();
	self.player_bike_invulnurablility_interval_thread_running = undefined;
}

e7_vehicle_damage_logic (eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName)
{
	//special case for the "merge_dropoff_guys" truck
	if( self.targetname == "merge_guys_dropoff" )
	{
		//player is attacker
		if(IsPlayer(eAttacker))
		{
			//player shot truck
			if(sWeapon == "motorcycle_driver_gunner") 
			{	
				//player is shooting truck, blow up truck
				PlayFXOnTag (level._effect["truck_explosion_linked"], self, "tag_origin"); 	
				array_thread (self.riders, ::e7_rider_crash); 
			}	
			//player crashed into truck
			if(sMeansOfDeath =="MOD_CRUSH")
			{
				player = get_players()[0];
				flag_set( "player_dies_by_vehicle" );	
				player DoDamage(self.health +100, self.origin);
			}
		}						
		//otherwise take 0 damage from anything else
		else
		{
			iDamage = 0;
		}
	}
	//if player crashes into any of these vehicles types with motorcycle for 300 damage, kill player
	damage_vehicles = [];
	damage_vehicles[ damage_vehicles.size ] = "truck_gaz66_physics";
	damage_vehicles[ damage_vehicles.size ] = "truck_gaz66_troops";
	damage_vehicles[ damage_vehicles.size ] = "truck_gaz66_troops_attacking_physics";

	if( IsDefined( eInflictor ) && IsDefined( self.vehicletype ) )
	{
		if( is_in_array( damage_vehicles, self.vehicletype ) )
		{
			if( IsDefined(eInflictor.vehicletype) && (eInflictor.vehicletype == "motorcycle_player" ))
			{
				if( IsPlayer( eAttacker ) && iDamage > 300 )
				{
					if(Distance2D(eAttacker.origin, self.origin) < 250 )
					{
						//IPrintLnBold( "killing player cause he bumped into " + self.vehicletype);
						player = get_players()[0];
						player.overridePlayerDamage = undefined;
						player DisableInvulnerability();
						flag_set( "player_dies_by_vehicle" );
						player DoDamage(self.health +100, self.origin);
					}			
				}
			}	
		}
	}

	return iDamage;
}	

e7_spawn_functions()
{
	//array_thread( GetEntArray("e7_road_guys", "targetname"), ::add_spawn_function, ::e7_roadside_guys_logic );
	//array_thread( GetEntArray("e7_road_guys", "targetname"), ::add_spawn_function, ::enemy_dodge_bike );

	//ENEMY MOTORCYCLES
	add_spawn_function_veh( "enemy_bikes", ::e7_enemy_motorycle_logic);
	//non-threat bikes
	add_spawn_function_veh( "nothreat_bikes", ::e7_nothreat_bikes_logic);

	add_spawn_function_veh( "gaz_chaser", ::e7_gaz_chaser_logic);

	add_spawn_function_veh( "gaz_rail", ::e7_gaz_rail_logic);

	//add_spawn_function_veh( "merge_guys_dropoff", ::merge_truck_destruction);

	//remove tread fx from certain vehicles during the event
	add_spawn_function_veh( "merge_guys_dropoff", ::veh_toggle_tread_fx, false);
	add_spawn_function_veh( "merge_gaz_crash", ::veh_toggle_tread_fx, false);
	add_spawn_function_veh( "oncoming_truck", ::veh_toggle_tread_fx, false);

	//guys on bridge after the river
	array_thread( GetEntArray("bridge_guys", "targetname"), ::add_spawn_function, ::e7_bridge_guy_logic);
	array_thread( GetEntArray("bridge_truck_guys", "script_noteworthy"), ::add_spawn_function, ::e7_bridge_guy_logic);

	array_thread( GetEntArray("bridge_repel_guy", "script_noteworthy"), ::add_spawn_function, maps\_ai_rappel::start_ai_rappel, undefined, undefined, true);

	array_thread( GetEntArray("e7_road_guys", "targetname"), ::add_spawn_function, ::e7_roadside_guys_logic);
	array_thread( GetEntArray("e7_road_guys", "targetname"), ::add_spawn_function, ::enemy_dodge_bike);

	array_thread( GetEntArray("merge_dropoff_guys", "targetname"), ::add_spawn_function, ::e7_roadside_guys_logic);
	array_thread( GetEntArray("merge_dropoff_guys", "targetname"), ::add_spawn_function, ::enemy_dodge_bike);

	array_thread( GetEntArray("bike_warehouse_repel", "script_noteworthy"), ::add_spawn_function, ::e7_bridge_repel_guys_logic, 590);

	array_thread( GetEntArray("bike_warehouse_breach", "targetname"), ::add_spawn_function, ::e7_warehouse_breachguys_logic);

	array_thread( GetEntArray("exit_runners", "targetname"), ::add_spawn_function, ::e7_warehouse_breachguys_logic);
	array_thread( GetEntArray("exit_runners", "targetname"), ::add_spawn_function, ::enemy_dodge_bike);

	array_thread( GetEntArray("exit_runners_hut", "targetname"), ::add_spawn_function, ::e7_warehouse_breachguys_logic);
	array_thread( GetEntArray("exit_runners_hut", "targetname"), ::add_spawn_function, ::enemy_dodge_bike);

	array_thread( GetEntArray("rail_bridge_guys", "targetname"), ::add_spawn_function, ::e7_rail_bridge_guys_logic);

}

merge_truck_destruction()
{
	//self = truck dropping guys off at main road merge

	level endon ("begin_truck_event");

	while(1)
	{
		self waittill ("damage", amount, inflictor, direction, point, type);

		if (isplayer(inflictor))
		{
			PlayFX (level._effect["truck_explosion"], self.origin);
			self thread truck_wipeout();
			wait(.5);
			level Spawn_vehicle_gibs(self);
			PhysicsExplosionSphere (self.origin, 800, 790, 10);		

			array_thread (self.riders, ::e7_rider_crash); 
		}

	}	

}	



E7_scripted_fx()
{
	flag_wait ("player_on_bike");

	//temp fog 
	//SetVolFog( start_dist, halfway_dist, halfway_height, base_height, red, green, blue, trans_time );

	river_exit_trig = GetEnt ("water_fx", "targetname");
	river_exit_trig thread watersheet_on_trigger();

	splash_trig = GetEnt ("splash", "targetname");
	splash_trig thread splash_trig_logic();

}	

Chopper_Wind_Helper()
{
	flag_wait ("player_on_bike");
	spots = getstructarray ("wind", "targetname");

	trigger_wait ("e7_out_window");
	for (i = 0; i < spots.size; i++ )
	{
		PhysicsExplosionSphere (spots[i].origin, 1000, 490, 50);
	}		

	flag_wait ("start_roadblock_wind");
	roadblock_wind = getstruct ("roadblock_wind", "targetname");

	PhysicsExplosionSphere (roadblock_wind.origin, 800, 790, 5);	

}	

e7_power_pole_fall()
{
	flag_wait ("player_on_bike");
	crash_node = GetVehicleNode ("gaz_crash", "targetname");
	pole = GetEnt ("pole", "targetname");
	gaz_crash_brush = GetEnt ("gaz_crash_brush", "targetname");

	sparks = getstructarray ("pole_sparks", "targetname");
	array_thread (sparks, ::pole_sparks_logic, pole, crash_node);


	pole_struct = getstruct ("pole_struct", "targetname");

	pole_mover = Spawn ("script_origin", pole_struct.origin);
	pole_mover.angles = pole_struct.angles;
	pole LinkTo( pole_mover );

	//ROPE STUFF
	rope1_start = getstruct ("rope1_start", "script_noteworthy");
	rope1_end = getstruct ("rope1_end", "script_noteworthy");
	rope1_end_attached = Spawn ("script_origin", rope1_end.origin);
	rope1_end_attached LinkTo (pole);

	rope = createrope(rope1_start.origin, rope1_end_attached.origin, 2200, rope1_end_attached);

	//trigger_wait ("oncoming_truck_trigger");
	crash_node waittill ("trigger");
	pole_mover PlaySound( "evt_power_pole_fall" );
	pole_mover RotateRoll (-90,1, 1);
	gaz_crash_brush Delete();
	wait (2);
	pole notify ("fallen");

}	

bullets_sparks_on_bike_exit()
{
	window_bullet_trigger = GetEnt ("window_bullet_trigger", "targetname");
	window_bullet_trigger trigger_off();
	bike = GetEnt ("bike", "targetname");
	bullets_start = bike.origin;
	spots = getstructarray ("bullets_sparks", "targetname");

	//wait for player to get on bike
	flag_wait ("player_on_bike");
	window_bullet_trigger trigger_on();

	//wait for bike to go on ramp
	trigger_wait ("window_bullet_trigger");

	level thread window_bullets_on_exit();

	//play sparks at random spots on steps as player exits. 
	for (i = 0; i < 12; i++ )
	{
		random_spot = random (spots);
		PlayFX (level._effect["bike_sparks"], random_spot.origin);
		playsoundatposition( "prj_bullet_impact_xtreme_metal", random_spot.origin );
		wait(RandomFloatRange(.2,.4));
	}	


}	


window_bullets_on_exit()

{
	//shoots magic bullets at the window/wall player drives towards on exit with bike
	spots = getstructarray ("bullets");
	gun = getstruct ("shoot_start", "targetname");

	for (i = 0; i < spots.size; i++ )
	{
		MagicBullet("ks23_sp", gun.origin, spots[i].origin);
		wait(RandomFloatRange(.2, .6));
	}

}		






pole_sparks_logic(pole, node)
{

	sparks = Spawn ("script_origin", self.origin);
	sparks LinkTo (pole);
	pole endon ("fallen");
	node waittill ("trigger");

	while(1)
	{
		sparks PlaySound( "evt_comp_room_sparks" );
		PlayFX (level._effect["bike_sparks"], sparks.origin);
		wait(.20);
	}

}	

watersheet_on_trigger()
{
	level endon ("begin_truck_event");
	self waittill( "trigger");  

	player = get_players()[0];
	// player setwatersheeting(1);
	player SetWaterDrops( 100 );      
	wait(3);
	player SetWaterDrops(0);  
	// player setwatersheeting(0);  

}

splash_trig_logic()

{
	//self = trigger to cause splash 

	player_bike = GetEnt ("bike", "targetname");
	player = get_players()[0];
	//who.played_splash = 0;

	self waittill("trigger");  

	//PlayFXOnTag (level._effect["river_splash"], player_bike.fx_tag, "tag_origin"); 
	PlayFXOnTag (level._effect["river_splash"], player_bike, "tag_front_fork"); 
	//IPrintLnBold ("splash!");
	player PlaySound( "evt_moto_splash" );

}


e7_warehouse_breachguys_logic()
{
	//self = guys breaching warehouse when player gets on bike!
	//self thread Print3d_on_ent ("!");
	self endon ("death");
	self.script_accuracy = .1;
	self.moveplaybackrate = 1.4;

	if(!IsDefined(self.script_noteworthy)) 
	{
		return;
	}

	trigger_wait ("delete_warehouse_guys");
	self set_spawner_targets ("gate_guys");

}	


e7_rail_trigger_activation()
{
	//triggers along the road that should only be triggered after player is on truck
	bridge_repel_guy_spawner = GetEnt ("bridge_repel_guy_spawner", "targetname");
	bridge_repel_guy_spawner trigger_off();

	final_turn = GetEnt ("final_turn", "targetname");
	final_turn trigger_off();

	enemy_rail_bikes = GetEnt ("enemy_rail_bikes", "targetname");
	enemy_rail_bikes trigger_off();

	rail_bikes2 = GetEnt ("rail_bikes2", "targetname");
	rail_bikes2 trigger_off();

	rail_gaz_spawn = GetEnt ("rail_gaz_spawn", "targetname");
	rail_gaz_spawn trigger_off();

	player_under_attack_bridge = GetEnt ("player_under_attack_bridge", "targetname");
	player_under_attack_bridge trigger_off();

	rail_roadside_guys_spawner = GetEnt ("rail_roadside_guys_spawner", "targetname");
	rail_roadside_guys_spawner trigger_off();

	truck_fail = GetEnt ("truck_fail", "targetname");//this detects when the player has failed to get on the truck


	flag_wait ("rez_truck_warped");

	truck_fail trigger_off();//truck event has started so turn this off now

	trigger_use("bridge_repel_guy_spawner");
	final_turn trigger_on();
	enemy_rail_bikes trigger_on();
	rail_bikes2 trigger_on();
	rail_gaz_spawn trigger_on();
	player_under_attack_bridge trigger_on();
	rail_roadside_guys_spawner trigger_on();

}	

e7_roadside_guys_logic()
{

	self.dropweapon = 0;
	self.script_accuracy = .1;
	self.a.allow_weapon_switch = false;

}


e7_bridge_guy_logic()
{
	self.dropweapon = 0;
	self.script_accuracy = .4;
	self thread launch_ragdoll_on_death(0,-40,0);


}	

e7_bridge_repel_guys_logic(rope_length)
{
	//self = AI repeling down
	//self should target struct at rope start point
	//rope start point should target the rope end-point struct

	self endon ("death");

	//self thread ignore_on();
	self.dropweapon = 0;
	self.script_accuracy = .1;

	//script_structs at rope start/stop point
	bullet_spot = getstruct (self.target, "targetname");
	end_spot = getstruct (bullet_spot.target, "targetname").origin;

	//create rope
	rope = createrope(bullet_spot.origin, end_spot, rope_length);
	//make it collide
	//RopeCollide( rope, 1 );
	ropesetflag( rope, "collide", 1 );

	mover = Spawn_a_model("tag_origin", bullet_spot.origin);
	mover Hide();

	level force_move_guy( self, bullet_spot.origin, self.angles, .20);

	self LinkTo(mover, "tag_origin" );

	mover moveto (end_spot, 1, 0.1, 0.9);

	mover waittill ("movedone");
	self Unlink();
	//self set_spawner_targets ("bridge_repel_spots");
	RopeRemoveAnchor(rope,0);

	self waittill ("goal");
	//self thread ignore_off();

}	




e7_window_exit_enemy_management()
{

	flag_wait  ("player_on_bike");

	trigger_use("exit_runners_spawner");

}	

e7_train()

{
	level.using_jump_skipto = false;

	flag_wait ("player_on_bike");

	train = GetEntArray ("train", "script_noteworthy");
	array_thread (train, ::train_logic);

	trigger_wait("e7_out_window");
	flag_set ("Player_out_window");
}	



train_logic()
{

	self veh_magic_bullet_shield(1);
	self thread play_train_audio();

	//play smoke off the engine car
	if( self.targetname == "car1" )
	{
		PlayFXOnTag(level._effect[ "train_smoke" ], self, "tag_origin");
	}

	flag_wait ("Player_out_window");
	self.startnode = GetVehicleNode (self.targetname +"_start", "targetname");
	self thread go_path(self.startnode);
	self thread play_train_audio();
	self SetSpeed (45);

	rez_truck = GetEnt ("rez_truck", "targetname");
	flag_wait ("player_at_final_turn");
	//wait(.5);
	speed = rez_truck GetSpeedMPH();
	self.startnode = GetVehicleNode (self.targetname +"_start2", "targetname"); 	
	//wait(3);
	self thread go_path(self.startnode);
	self thread play_train_audio();
	self SetSpeed (45);

	flag_wait ("start_train_warp");
	self StopLoopSound( .05 );
	self.startnode = GetVehicleNode (self.targetname +"_warpto", "targetname");
	self thread go_path(self.startnode);
	self thread play_train_audio();
	self SetSpeed (40); 	


}	


e7_slowmo_manager()
{
	//jump out window
	flag_wait ("Player_out_window");
	level thread timescale_tween(1, .4, .3);
	wait(1);
	level thread timescale_tween(.4, 1, .3);

	//final jump starts
	flag_wait ("jump_begin");
	
	level thread timescale_tween(1, .3, .1);

	trigger_wait ("delete_bridge_guys");
	level thread timescale_tween(1, .4, .3);
	wait(1);

	level thread timescale_tween(.4, 1, .3);

}

e7_warehouse_breach()
{
	//spawns enemies that flood warehouse when player gets on bike. 
	flag_wait ("player_on_bike");
	trigger_use ("bike_warehouse_breach_spawner");

}	




#using_animtree ("generic_human");
e7_rez_bike()
{

	level.using_jump_skipto  = false;

	rez_bike = GetEnt ("rez_bike", "targetname");
	rez_bike thread e7_rez_bike_logic();

	rez_bike_start = GetVehicleNode ("rez_bike_start", "targetname");

	flag_wait( "player_on_bike" );
	//level.reznov thread custom_ai_weapon_loadout ("ak74u_sp");
	level.reznov maps\_motorcycle::ride_and_shoot( rez_bike );
	level.reznov.script_accuracy = .1;
	level.reznov.takedamage = false;
	level.reznov.ignoreall = false;

	level.reznov.max_bike_total_yaw_angle	= 60;
	level.reznov.min_blindspot_time		= 999999;

	if(level.using_jump_skipto == true)
	{
		skipto_start = GetVehicleNode ("rez_truck_skipto_start", "script_noteworthy");
		rez_bike DrivePath(skipto_start);
	}
	else
	{
		rez_bike DrivePath(rez_bike_start);
	}	

}


e7_enemy_bike_rider_logic(bike)
{
	//self = guy on bike
	self.bike = bike;
	self.health = 300000;
	//custom loadout for these guys
	//self thread custom_ai_weapon_loadout ("ak74u_sp");

	//bike thread Print3d_on_ent ("ENEMY!");

	self PlayLoopSound( "veh_moto_looper_fast_ai" );

	//if the player is not on the truck yet, run this thread
	if(!flag("player_bike_in_jump_position"))
	{
		self thread Delete_on_truck_transition(bike);
	}	

	self waittill("damage", amount ,attacker, direction_vec, P, type);

	if( IsDefined(attacker) && ( (attacker == level.reznov) || (attacker == get_players()[0]) ) )
	{
		bike_achievement_add();
	}
	else if( IsDefined(type) && (type == "MOD_EXPLOSIVE") )
	{
		bike_achievement_add();
	}

	self StopLoopSound( .5 );
	self PlaySound( "vox_moto_death" );

	self thread enemy_bike_deathFX(self.bike);
	self.bike thread motorcycle_wipeout();

}	

Delete_on_truck_transition(bike)
{	
	//delete existing enemy bike and riders when player gets on truck
	//self = AI on bike
	self endon("death");
	
	flag_wait ("player_bike_in_jump_position");

	self thread enemy_bike_deathFX(self.bike);
	self.bike thread motorcycle_wipeout();

}


enemy_bike_deathFX(bike)
{
	//self = guy getting killed
	//bike = guys bike

	//possible tags to play blood fx
	self endon("death");
	
	enemy_tag_array = [];
	enemy_tag_array[0] = "J_Neck";
	enemy_tag_array[1] = "J_Head";
	enemy_tag_array[2] = "J_Shoulder_LE";
	enemy_tag_array[3] = "J_Shoulder_RI";
	enemy_tag_array[4] = "J_ShoulderRaise_LE";
	enemy_tag_array[5] = "J_ShoulderRaise_RI";

	//randomize order or list		
	possible_tag_array = array_randomize( enemy_tag_array );

	//play death FX 2x
	if( is_mature() )
	{
		PlayFXOnTag( level._effect["flesh_hit_lg"], self, enemy_tag_array[0] ); 
		PlayFXOnTag( level._effect["flesh_hit_lg"], self, enemy_tag_array[1] ); 
	}
	
	bike_tag_array = [];
	bike_tag_array[0] = "tag_body";
	bike_tag_array[1] = "tag_wheel_back";
	bike_tag_array[2] = "tag_fx_tank";
	bike_tag_array[3] = "tag_taillight_left";

	possible_bike_tag_array = array_randomize( bike_tag_array );

	//sparks on bike
	PlayFXOnTag( level._effect["bike_sparks"], bike, bike_tag_array[0] ); 
	PlayFXOnTag( level._effect["bike_sparks"], bike, bike_tag_array[1] ); 

}	


e7_rider_crash()
{

	self endon ("death");
	self thread animscripts\death::flame_death_fx();
	//self gun_remove();
	fwd = AnglesToForward( flat_angle(self.angles) );
	my_velocity = Vector_Scale (fwd, 380);
	my_velocity_with_lift = (my_velocity[0], my_velocity[1], 20);

	self Unlink();
	self StartRagdoll(); 
	wait(0.1); // wait 2 frames for the animation velocity to be calculated and applied to ragdoll

	//self.a.nodeath = true;
	self.a.doingRagdollDeath = true;                          
	self LaunchRagdoll(my_velocity_with_lift, self.origin);	

}	


e7_bike_crash_at_end_node(rider)
{
	//self is bike 
	rider endon ("death"); //end if rider gets killed by player

	self waittill ("reached_end_node");
	//IPrintLnBold ("reached end node");

	rider PlaySound( "vox_moto_death" );
	rider StopLoopSound( .5 );

	self thread motorcycle_wipeout(); 

	rider DoDamage(1, rider.origin);

}	

e7_nothreat_bikes_logic()
{
	//self = drone bikes that just go and delete at end node (no crash)

	my_rider = spawn_enemy_bike_rider( ::ignore_on );

	if( IsDefined(my_rider) )
	{
		my_rider maps\_motorcycle::ride_and_shoot( self );
	}

	//start node is same as script_noteworthy + "_start"
	start_node = GetVehicleNode (self.script_noteworthy +"_start", "script_noteworthy");		

	self DrivePath(start_node);

	self waittill ("reached_end_node");
	my_rider Delete();
	self Delete();

}	

motorcycle_wipeout()// this only works on physics vehicles.
{

	//self = bike that is crashing
	//rider = guy on bike
	self endon ("death");
	self ClearVehGoalPos();

	chance = randomint( 100 );

	if( chance > 66 )
	{
		// Take out the front end and cause motorcycle to spin out
		force = AnglesToRight( self.angles ) * 50;
		hitpos = (50,0,0);
		self PlaySound( "veh_moto_death_spinout" );
	}
	else if( chance > 33 )
	{
		// launch the back end up causing it to flip end over end
		force = (0,0,100);
		hitpos = (-50,0,0);
		self PlaySound( "veh_moto_death_flip" );
	}
	else
	{
		// turn the front wheel hard right and cause a wipeout
		dir = AnglesToRight( self.angles ) * 2000;
		self SetVehGoalPos( self.origin + dir );
		force = (0,0,0);
		hitpos = (0,0,0);  
		self PlaySound( "veh_moto_death_wipeout" );
	}

	self notify( "nodeath_thread" ); //Per Gavin to fix a _vehicle error I kept getting
	self LaunchVehicle( force, hitpos, true, true );

	wait 2;
	self ClearVehGoalPos();

	self notify ("crashed");

	wait 4;

	if(IsDefined(self))//in case the ent is removed at this point
	{
		self Delete();
	}

}

truck_wipeout()// this only works on physics vehicles.
{

	self ClearVehGoalPos();

	chance = randomint( 100 );

	if( chance > 66 )
	{  
		force = (332, 116, 104);
		hitpos = (-76, -14, 34);
	}
	else if( chance > 33 )
	{  
		force = (332, 46, 296);
		hitpos = (-50,0,0);
	}
	else
	{
		force = (620, 8, 372);
		hitpos = (76, 2, 18);  
	}

	self LaunchVehicle( force, hitpos, true, true );

	self ClearVehGoalPos();

	//no slowmo for a coupla specific trucks
	no_slowmo_vehicles = [];
	no_slowmo_vehicles[no_slowmo_vehicles.size] = ("merge_guys_dropoff");
	no_slowmo_vehicles[no_slowmo_vehicles.size] = ("barrel_truck");

	if( is_in_array( no_slowmo_vehicles, self.targetname ) )
	{
		return;
	}	

	if(flag("did_truck_slowmo") )
	{
		return;
	}	

	//slowmo
	level thread timescale_tween(1, .4, .3);
	clientnotify( "slow" );
	wait(1);
	clientnotify( "fast" );
	level thread timescale_tween(.4, 1, .3);

	flag_set ("did_truck_slowmo");


}

Spawn_vehicle_gibs(vehicle)
{
	vehicle_gib=[];
	vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_tire_low");
	vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_tire_low");
	vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_door_dest");
	vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_door_dest");
	vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_bumper_dest");
	vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_bumper_dest");

	up = AnglesToUp(vehicle.angles);
	velocity_up = Vector_Scale (up, 500);

	for (i = 0; i < vehicle_gib.size; i++ )
	{
		x= RandomFloatRange (10,180);
		gib = Spawn ("script_model", vehicle.origin +(0,0,80) );
		gib.angles = (x,x,x);
		gib SetModel (vehicle_gib[i]);
		gib PhysicsLaunch (gib.origin, velocity_up);
	}

}	

e7_player_rez_speed_monitor()
{
	level endon ("player_bike_in_jump_position");

	level.player_too_slow = false;

	player_bike = GetEnt ("bike", "targetname");
	rez_bike = GetEnt ("rez_bike", "targetname");

	flag_wait ("player_on_bike");

	while(1)
	{
		level.player_speed = player_bike GetSpeedMPH();
		level.rez_speed = rez_bike GetSpeedMPH();
		{
			if (level.player_speed <= 41)
			{
				level.player_too_slow = true;
				//IPrintLnBold ("You're going too slow! Catch up with Reznov!");
			}
			else if (level.player_speed > 41)
			{
				level.player_too_slow = false;				
			}		
			wait(.05);
		}
		wait(.05);
	}	

}	

e7_player_speed_fail_logic()
{
	level endon ("player_bike_in_jump_position");
	flag_wait ("player_on_bike");
	wait (10); //wait for tutorial prompts to finish before displaying these
	level.speed_fail_time = 10;
	x= 0;
	while(1)
	{
		if(level.player_too_slow ==1)
		{
			wait 1;
			x++;
			if(x == 3)
			{
				flag_set ("displaying_speed_warning");
				screen_message_create (&"VORKUTA_BIKE_SPEED_WARNING");
			}		
			if(x == level.speed_fail_time)
			{
				flag_set ("displaying_speed_warning");
				//SetDvar( "ui_deadquote", &"VORKUTA_SPEED_FAIL" ); 
				maps\_utility::missionfailedwrapper( &"VORKUTA_SPEED_FAIL" );
			}						
		}
		else
		{	
			//only clear the flag one time only
			if(flag("displaying_speed_warning") )
			{
				flag_clear ("displaying_speed_warning");
				screen_message_delete();
			}	
			x = 0;
		}	
		wait (.05);	
	}

}




e7_rez_bike_logic()
{
	//self = reznovs bike

	level endon ("player_bike_in_jump_position");
	flag_wait ("player_on_bike");

	self SetSpeed( 60, 20, 1 );

	//have him just go through the window before tethering
	wait(3);

	//players bike
	player_bike = GetEnt ("bike", "targetname");

	//script_origin at end of event
	finish_line = GetEnt ("finish_line", "targetname");

	//rez_waited_for_player = false;

	while( !flag("begin_truck_event") )
	{
		player = player_bike.origin;	
		rez = self.origin;	
		level.player_rez_dist = DistanceSquared(player,rez);	
		player_finish_dist = Distance2D(player,finish_line.origin);	
		rez_finish_dist = Distance2D(rez,finish_line.origin);

		//PLAYER IS BEHIND REZNOV
		if(player_finish_dist > rez_finish_dist)
		{
			if ( (level.player_rez_dist <= 700*700)&&(level.player_speed > 0) ) //player is close and going FWD
			{
				//go the same speed as the player
				self SetSpeed (level.player_speed + 5);
			}
			else if ( (level.player_rez_dist > 700*700) ) //player is falling behind reznov
			{
				//slow down to wait
				self SetSpeed (20);			
			}
		}
		else //PLAYER IS IN FRONT OF REZNOV
		{
			//PASS PLAYER
			if( Distance2D( self.origin, player ) < 200 )
			{
				// if too close to the player and right behind him, avoid bumping into him
				if( within_fov( self.origin, self.angles, player, 0.7 ) )
				{
					//IPrintLn( "Dont bump into me rezzz.." );
					self.was_behind_player = true;
					if(level.player_speed > 20)
					{
						self SetSpeed( level.player_speed - 20 ); 
					}
					else
					{
						self SetSpeed( level.player_speed );
					}
				}
			}

			if( IsDefined( self.was_behind_player ) && self.was_behind_player )
			{
				self.was_behind_player = true;
				self SetVehMaxSpeed(80);
				self SetSpeed (80, 40);
				wait(2);
			}

			//	IPrintLnBold("trying to pass player");
		}
		wait(0.5);	
	}

	while(1)
	{
		if(level.player_speed > 0)
		{
			self SetSpeed(level.player_speed);
		}
		self SetVehGoalPos(level.anim_spot.origin + (-300,0,0));
		wait(0.05);
	}

}		




e7_debug_hud()
{

	player =NewClientHudElem( get_players()[0] );
	player.horzAlign = "left"; 	// horizontal alignment values can be left, center, or right
	player.vertAlign = "middle";// vertical alignment values can be top, middle, or bottom
	player.alignX = "left"; 		// horizontal alignment values can be left, center, or right
	player.alignY = "top"; 			// vertical alignment values can be top, middle, or bottom
	player.fontScale = 1.7;
	/*
	fov =NewClientHudElem( get_players()[0] );
	fov.horzAlign = "left"; 	// horizontal alignment values can be left, center, or right
	fov.vertAlign = "middle"; // vertical alignment values can be top, middle, or bottom
	fov.alignX = "left"; 			// horizontal alignment values can be left, center, or right
	fov.alignY = "top"; 			// vertical alignment values can be top, middle, or bottom
	fov.fontScale = 1.7;
	fov.y = 15;

	dist =NewClientHudElem( get_players()[0] );
	dist.horzAlign = "left"; 	// horizontal alignment values can be left, center, or right
	dist.vertAlign = "middle"; // vertical alignment values can be top, middle, or bottom
	dist.alignX = "left"; 			// horizontal alignment values can be left, center, or right
	dist.alignY = "top"; 			// vertical alignment values can be top, middle, or bottom
	dist.fontScale = 1.7;
	dist.y = 30;
	*/

	//player_finish_dist = Distance2Dsquared (player,finish_line.origin);	

	flag_wait ("player_on_bike");
	wait(2);

	while(!flag("player_bike_in_jump_position") )
	{
		//player_finish_dist = Distance2Dsquared (player.origin,finish_line.origin);	
		player.label="Player:" +level.player_speed+ "MPH";
		//fov.label ="Dist from end: " +player_finish_dist;
		//rez.label="Reznov:" +level.rez_speed+ "MPH";
		//dist.label="Distance between bikes:" +level.player_rez_dist;
		wait(.5);
	}	

	truck = GetEnt ("rez_truck", "targetname");

	while(1)
	{
		speed = truck GetSpeedMPH();
		player.label="Truck Speed: " +speed+ "MPH";
		wait(.5);
	}	

	//TODO endon
}

player_directional_monitor()
{
	level endon ("player_bike_in_jump_position");

	trigger_wait ("main_road_start"); //doesnt kick in until we pass the main gate
	player = get_players()[0];
	finish_line = GetEnt ("finish_line", "targetname");

	wait(5);
	old_dist = Distance2Dsquared (player.origin,finish_line.origin);	
	warning_count = 0;

	while(1)
	{
		//distance from player to train area
		new_dist = Distance2Dsquared (player.origin,finish_line.origin);		
		//if current dist is MORE than the previous dist
		if(new_dist > old_dist)
		{	
			//player going wrong way. Wait 5 secs to buffer.
			//IPrintLnBold("Wrong way 5 second buffer");
			wait(5);
			//recheck the distance
			new_dist = Distance2Dsquared (player.origin,finish_line.origin);	
			//if player is still going the wrong way
			if(new_dist > old_dist)
			{	
				//increase warning count by 1
				warning_count ++;
				//warn the player 
				level player_directional_warning(warning_count);
			}
			//otherwise start the process over
			else
			{
				//IPrintLnBold("player corrected direction");
				continue;
			}	
		}	
		wait(0.05);
		//update the distance before starting over
		old_dist = new_dist;
	}	
}

player_directional_warning(warning_count)
{
	//this picks random warning lines and delivers to the player when called. 
	//if its the 3rd warning mission fail

	directional_warning = [];
	directional_warning[0] = &"VORKUTA_DIRECTIONAL_WARNING1";
	directional_warning[1] = &"VORKUTA_DIRECTIONAL_WARNING2";
	directional_warning[2] = &"VORKUTA_DIRECTIONAL_WARNING3";

	warning = random(directional_warning);

	//if a speed warning is being displayed, wait. 
	while(flag("displaying_speed_warning"))
	{
		wait(.05);
	}


	//1st and 2nd warning
	if(warning_count < 3) 
	{
		//display the warning
		screen_message_create(warning);
	}
	//3rd warning is the fail message
	else 
	{		
		//screen_message_create(&"VORKUTA_SPEED_FAIL_MESSAGE"); //you were caught! Try keeping up with Reznov next time.
		maps\_utility::missionfailedwrapper( &"VORKUTA_SPEED_FAIL" );
	}

	wait(5);	//buffer to give player a chance to catch up
	screen_message_delete();

}			




e7_chopper()
{

	strafe_start = GetVehicleNode ("strafe_start", "script_noteworthy");
	new_attack_spot = GetVehicleNode ("new_attack_spot", "script_noteworthy");
	new_attack_spot2 = GetVehicleNode ("new_attack_spot2", "script_noteworthy");
	chopper_to_reznov = GetVehicleNode ("chopper_to_reznov", "targetname");
	chopper_ramp_flyover_start = GetVehicleNode ("chopper_ramp_flyover_start", "script_noteworthy");
	road_block = GetVehicleNode ("road_block", "script_noteworthy");
	player = get_players()[0] ;

	rail_attack = GetVehicleNode ("heli_new_start", "targetname");

	//chopper spawns
	trigger_wait("window_bullet_trigger");
	wait(.5);

	// SETUP
	chopper = GetEnt ("chopper", "targetname");
	chopper SetLocalWindSource (true);
	//DRIVER AND GUNNER
	driver = spawn("script_model", (0,0,0) );
	driver character\c_rus_prison_guard::main();
	driver UseAnimTree(#animtree);
	driver maps\_vehicle_aianim::vehicle_enter( chopper, "tag_driver" );

	gunner = spawn("script_model", (0,0,0) );
	gunner character\c_rus_prison_guard::main();

	gunner UseAnimTree(#animtree);
	gunner maps\_vehicle_aianim::vehicle_enter( chopper, "tag_gunner1" );

	chopper PlaySound( "evt_moto_heli_flyby" );
	chopper.drivepath = 1;

	//aim at bike
	chopper setGunnerTargetEnt(level.chopper_target, (0,0,0),0);
	chopper thread gunner_shoot_burts(15);


	//trigger by first ramp (this used to spawn the chopper, no longer does)
	trigger_wait("chopper1_spawn");
	chopper.DrivePath = 0;
	chopper thread go_path (chopper_ramp_flyover_start);

	//main road merge area
	new_attack_spot waittill ("trigger");
	chopper thread gunner_shoot_burts(70);


	//over roadblock / bridge
	chopper_over_bridge = GetVehicleNode ("chopper_over_bridge", "script_noteworthy");
	chopper_over_bridge waittill ("trigger");

	chopper thread gunner_shoot_burts(20);

	chopper SetSpeed (20,10,10);
	chopper SetVehGoalPos( road_block.origin, 1 );
	chopper SetGoalYaw( road_block.angles[1] );
	chopper SetHoverParams(50);

	flag_set ("start_roadblock_wind");


	flag_wait ("rez_truck_warped");
	chopper setGunnerTargetEnt(level.chopper_truck_target, (0,0,0),0);

	chopper Hide();
	trigger_wait ("enemy_rail_bikes");
	chopper Show();
	chopper thread go_path (rail_attack);
	chopper thread chopper_crash_think();
	chopper SetSpeed(58);
	chopper thread gunner_shoot_burts(20);
	//chopper thread chopper_rail_tether_logic();

	flag_wait ("player_jumped_on_train");


	if(IsDefined(chopper))
	{
		chopper SetSpeed(70);
		wait(2);	

		chopper thread go_path (chopper_to_reznov );
		wait(2);
		rez_end = GetVehicleNode("rez_end", "script_noteworthy");

		chopper SetSpeed (50,10,10);
		chopper SetVehGoalPos( rez_end.origin, 1 );
		chopper SetGoalYaw( rez_end.angles[1] );
		chopper SetHoverParams(50);

	}	


}


chopper_bullets_on_jump()
{
	trigger_wait("truck_and_guys_spawner");
	gun = getstruct ("chopper_gun_start", "targetname");
	spots = getstructarray ("chopper_bullet", "targetname");
	for (i = 0; i < spots.size; i++ )
	{
		MagicBullet("btr60_heavy_machinegun_explosive", gun.origin, spots[i].origin);
		wait(.2);
	}	
}	



chopper_rail_tether_logic()
{
	rez_truck = GetEnt ("rez_truck", "targetname");
	self endon ("death");
	self thread btr_fire_at(get_players()[0], 500, 550);

	while(1)
	{
		random_dist = RandomIntRange (100, 150);
		player = rez_truck.origin;	
		dist_from_player = Distance2dSquared(player, self.origin);	
		truck_speed = rez_truck GetSpeedMPH();

		if  (dist_from_player <= random_dist*random_dist ) //player is close and going FWD
		{
			//go roughly the same speed as the player
			self SetSpeed (truck_speed);	
		}
		else if ( (dist_from_player > random_dist*random_dist) ) //player is getting ahead 
		{
			//speed up
			self SetSpeed (truck_speed +40) ;	
		} 
		wait(0.5);		 
	}

}		

#using_animtree ("vehicles");
chopper_crash_think()
{
	self endon ("crashed");
	while(1)
	{
		if(self.health <= 1500)
		{
			//helicopter was shot down add to vehicle count for achievement
			bike_achievement_add();

			new_heli = Spawn("script_model", self.origin);
			new_heli SetModel(self.model);
			new_heli.animname = "helicopter";
			new_heli.angles = self.angles;
			new_heli UseAnimTree(#animtree);
			new_heli.vehicletype = self.vehicletype;
			/*
			//burning corpse?
			burn_guy = spawn_enemy_bike_rider( ::ignore_on );
			burn_guy thread animscripts\death::flame_death_fx();
			level force_move_guy( burn_guy, self.origin, self.angles, .20);
			burn_guy thread Ragdoll_Death();
			*/  
			self notify("nodeath_thread");		  
			playfx (level._effect["vehicle_explosion"], self.origin);

			PlaySoundatposition( "evt_moto_heli_crash", new_heli.origin );
			self Delete();

			new_heli thread anim_single( new_heli, "hip_crash" );
			new_heli thread play_fx_at_ground();
			return;
		}	
		wait(.5);
	}	

}

play_fx_at_ground()
{
	/*
	up = AnglesToup( self.angles);
	down = (up[0], up[1],up[2]*-1);
	ground= Vector_Scale (down, 5000);
	*/
	ground_trace = BulletTrace(self.origin, self.origin -(0,0,5000), false, self);

	while(1)
	{	
		if(self.origin[2]- ground_trace["position"][2] >= 90)
		{
			wait(.05);
		}
		else
		{
			//Colin sound audio !! Chopper hits ground goes BOOM here
			playfx (level._effect["vehicle_explosion"], self.origin);
			return;
		}	
	}
}		



e7_enemy_motorycle_logic()
{
	//self = enemy bike

	level endon ("jump_outcome_set");
	level endon ("player_bike_in_jump_position");
	self endon ("crashed");

	while( IsDefined( level.enemy_bike_rider_spawning_in_progress ) && level.enemy_bike_rider_spawning_in_progress )
	{
		wait(0.05);
	}

	//spawn AI to ride
	my_rider = spawn_enemy_bike_rider ( ::e7_enemy_bike_rider_logic, self);

	AssertEx( IsDefined( my_rider ), "Rider for  " + self.script_noteworthy + " not spawned! " + GetAIArray().size );

	if( IsDefined(my_rider) )
	{
		my_rider maps\_motorcycle::ride_and_shoot( self );
	}

	//crash at end node if rider never gets shot
	self thread e7_bike_crash_at_end_node(my_rider);

	player_bike = GetEnt ("bike", "targetname");

	//script_origin at end of event
	finish_line = GetEnt ("finish_line", "targetname");

	//start node is same as script_noteworthy + "_start"
	start_node = GetVehicleNode (self.script_noteworthy +"_start", "script_noteworthy");		

	self DrivePath(start_node);

	//just go for a bit without tethering
	self SetSpeed (70);

	wait(3);


	if(flag("player_bike_in_jump_position"))
	{
		//different tether logic if player is on truck. 
		self thread enemy_bike_rail_tether_logic();
		return;
	}	

	//tether logic to the player's bike:
	while(1)

	{
		//self = enemy motorcycle
		player = player_bike.origin;	
		dist_from_player = Distance2Dsquared(player, self.origin);	
		player_finish_dist = Distance2Dsquared (player,finish_line.origin);	
		self_finish_dist = Distance2Dsquared(self.origin,finish_line.origin);
		my_speed = self GetSpeedMPH();
		speed_offset = RandomIntRange (5,8);

		max_slow_dist = 1500;
		min_slow_dist = 750;
		slow_speed_change = 30 - 10;
		slow_change_per_unit = slow_speed_change / ( max_slow_dist - min_slow_dist );

		Distance_num = RandomIntRange (750, 850);

		//PLAYER IS BEHIND 
		if(player_finish_dist > self_finish_dist)
		{
			if ( (dist_from_player <= Distance_num*Distance_num)&&(level.player_speed > 0) ) //player is close and going FWD
			{
				//go roughly the same speed as the player
				self SetSpeed (level.player_speed + speed_offset);
				//IPrintLnBold("Player is close. Enemy speed: " +my_speed);
			}
			else if ( (dist_from_player > Distance_num*Distance_num) ) //player is falling behind 
			{
				//slow down to wait
				dist_from_player = clamp( dist_from_player, min_slow_dist, min_slow_dist );
				desired_slow_speed = dist_from_player * slow_change_per_unit;
				desired_slow_speed = clamp( desired_slow_speed, 10, 30 );

				self SetSpeed (desired_slow_speed);	
				// IPrintLnBold("Player is far. Enemy speed: " +my_speed);
			} 
		}
		else //PLAYER IS IN FRONT
		{
			if( Distance2D( self.origin, player ) < 200 )
			{
				// if too close to the player and right behind him, avoid bumping into him
				if( within_fov( self.origin, self.angles, player, 0.7 ) )
				{
					//IPrintLn( "Dont catch me enemy please....." );
					self SetSpeed( level.player_speed ); 
				}
			}
			//PASS PLAYER
			self SetSpeed (80, 45);
			//	IPrintLnBold("Passing Player.Enemy speed: " +my_speed);
		}
		wait(0.5);	
	}

}	

spawn_enemy_bike_rider( spawn_func, vehicle )
{
	while( IsDefined( level.enemy_bike_rider_spawning_in_progress )
		&& level.enemy_bike_rider_spawning_in_progress )
	{
		wait(0.05);
	}

	level.enemy_bike_rider_spawning_in_progress = true;

	if( !IsDefined( spawn_func ) && !IsDefined( vehicle ) )
	{
		rider = simple_spawn_single ("enemy_bike_rider" );
	}
	else if( IsDefined( spawn_func ) && !IsDefined( vehicle ) )
	{
		rider = simple_spawn_single ("enemy_bike_rider", spawn_func );
	}
	else
	{
		rider = simple_spawn_single ("enemy_bike_rider", spawn_func, vehicle );
	}

	level.enemy_bike_rider_spawning_in_progress = false; 

	return rider;
}

enemy_bike_rail_tether_logic()
{
	//IPrintLnBold ("using truck tether logic");
	self endon ("crashed");

	rez_truck = GetEnt ("rez_truck", "targetname");
	//script_origin at end of event
	finish_line = GetEnt ("finish_line", "targetname");

	while(1)
	{
		random_dist = RandomIntRange (600, 800);
		player = rez_truck.origin;	
		dist_from_player = Distance2dSquared(player, self.origin);	
		truck_speed = rez_truck GetSpeedMPH();

		if  (dist_from_player <= random_dist*random_dist ) //player is close and going FWD
		{
			//go roughly the same speed as the player
			self SetSpeed (truck_speed);	
		}
		else if ( (dist_from_player > random_dist*random_dist) ) //player is getting ahead 
		{
			//speed up
			self SetSpeed (80);	
		} 
		wait(0.5);		 
	}

}	

e7_window_bullet()
{

	flag_wait ("player_on_bike");

	//get the 2 structs
	player_window_bullet_hit = getstruct ("player_window_bullet_hit", "targetname");
	rez_window_bullet_hit = getstruct ("window_bullet_hit", "targetname");

	wait(.8);
	//reznovs window on the right. 
	playsoundatposition( "exp_moto_room_glass", rez_window_bullet_hit.origin );
	RadiusDamage (rez_window_bullet_hit.origin, 50, 500, 500);

	//level thread player_window_exploder(); TODO get this to work since I'm blowing it. 

	//players window on left. 
	flag_wait ("Player_out_window");

	playsoundatposition( "exp_moto_room_glass", player_window_bullet_hit.origin );
	RadiusDamage (player_window_bullet_hit.origin, 50, 500, 500);

}
/*

player_window_exploder()
{
//how do you get the exploders?
thresholdSq= 16*16;
level waittill ("glass_shattered", origin);

for ( i = 0; i < exploders.size; i++ )
{
distSq = DistanceSquared( exploders[i].v[ "origin" ], origin );

if ( distSq > thresholdSq )
{
continue;
}
exploder(70);
}
}	
*/

e7_player_bike_setup()
{
	//motorcycle
	player_bike = GetEnt ("bike", "targetname");
	//make bike invulnerable
	player_bike thread veh_magic_bullet_shield(1);
	player_bike MakeVehicleUnusable();

	player_bike thread maps\_motorcycle_ride::drive_motorcycle();

	player = get_players()[0];

	while(Distance2D(player.origin, player_bike.origin) > 75)
	{
		wait(0.05);
	}
	player lerp_player_view_to_position(player_bike.origin, player_bike.angles, 0.5, 1);
	player_bike MakeVehicleUsable();
	player_bike UseVehicle(player, 0);

	//wait til player gets on bike!	
	//player_bike waittill ("enter_vehicle");

	flag_set ("player_on_bike");

	player.motorbike_max_damage = 20;
	player.player_bike_invulnurablility_interval = 4000;
	player.overridePlayerDamage = ::e7_player_damage_control;

	player_bike.fx_tag = Spawn_a_model("tag_origin", player_bike.origin);	
	player_bike.fx_tag LinkTo (player_bike, "tag_front_fork",(200, 0, -50) );

	level.chopper_target = Spawn ("script_origin", player_bike.origin);	
	level.chopper_target LinkTo (player_bike, "tag_origin",(1000, 0, 0) );
	//level.chopper_target thread Print3d_on_ent ("!");


	player DisableWeapons();

	SetSavedDvar( "phys_vehicleWheelEntityCollision", false );

	//sounds and FOV lerp start
	player_bike setclientflag(15);

	/*=============================================
	BASE FOV SET HERE. FOV LERP IN THE .CSC DEPENDS ON THIS
	===============================================*/

	//get_players()[0] lerp_fov_overtime( .5, 75 ); //IF FOV LERP DECREASES FOV

	//get_players()[0] lerp_fov_overtime( .5, 55 ); //IF FOV LERP INCREASES FOV

	player_bike MakeVehicleUnusable();

	//cap max speed to control the left-turn peel-out when we land.
	player_bike SetVehMaxSpeed (45);

	//we hit the ground
	trigger_wait ("delete_warehouse_guys"); //the player hits the ground

	//TUEY Set music state to MOTORCYLE_ESCAPE
	setmusicstate("MOTORCYLE_ESCAPE");
	clientnotify( "eade" );

	//nudge bike's angles towards gate
	player_bike LaunchVehicle ((0,-1,0), (-50,0,0));
	player PlaySound( "evt_moto_peelout" );

	gate = getstruct ("gate", "targetname");

	//tell bike to go towards gate for 1 sec
	player_bike SetVehGoalPos (gate.origin);
	player_bike SetSpeed (70,70);
	wait(1);

	//give back control
	player_bike ClearVehGoalPos();
	player_bike returnplayercontrol();
	//restore max speed
	player_bike SetVehMaxSpeed (60);

	//crash bike after player jumps on truck
	flag_wait ("player_bike_in_jump_position");
	wait(2);

	player_bike Hide();
	wait(2);
	player_bike Delete();


}

e7_bike_prompts()
{
	//player gets on bike
	flag_wait ("player_on_bike");

	//start waiting for shotgun fire
	level thread e7_bike_prompts_shot_flag();

	if( level.console )
		screen_message_create (&"VORKUTA_BIKE_RIGHT_TRIG"); //right trigger accelerate
	else
		screen_message_create (&"PLATFORM_ACCELERATE"); //right trigger accelerate
	wait_for_gas_button();
	screen_message_delete();

	wait(10);

	//only display tutorial if the player has not already fired the shotgun
	if(!flag("flag_bike_shotgun_fired"))
	{
		if( level.console )
			screen_message_create (&"VORKUTA_BIKE_LEFT_TRIG"); //left trig boom stick.
		else
			screen_message_create (&"PLATFORM_ATTACK_TO_SHOOT"); //left trig boom stick.
		wait_for_attack_button_or_timeout(10);
		screen_message_delete();
	}	
}

e7_bike_prompts_shot_flag()
{
	wait_for_attack();
	flag_set("flag_bike_shotgun_fired");
}


e7_rail_bridge_guys_logic()
{
	self endon ("death");
	self.a.allow_weapon_switch = false;
	target = GetEnt ("rez_truck", "targetname");
	wait(1);
	self Shoot_at_target (target);

}	

e7_bridge_rpg_at_player()
{
	trigger_wait ("river_exit");
	waittill_spawn_manager_complete ("river_exit");
	rpg_guy = get_ai ("rpg_bridge_guy", "script_noteworthy");
	rpg_guy.a.allow_weapon_switch = false;
	rpg_guy Shoot_and_kill (get_players()[0]);

}	


e7_bridge_quad_50_attacks()
{
	trigger_wait ("truck_and_guys_spawner");

	quad_50 = GetEnt ("quad_50", "targetname");

	quad_50 thread quad_attack_player_until_flag("player_under_bridge");

}	


quad_attack_player_until_flag(flag_ender)

{
	level endon (flag_ender);

	while(1)
	{
		//changing target to bike instead of player
		target = GetEnt ("bike", "targetname");		

		bullet_count = RandomIntRange(30,40);
		num = RandomIntRange(50,65);	
		self  SetTurretTargetEnt( target, (num,num,num) );

		self waittill_notify_or_timeout( "turret_on_target", 3 );

		for (i = 0; i < bullet_count; i++ )
		{		 
			self fireweapon();
			wait (0.2);
		}
		self ClearTurretTarget(); 		
		wait (1);
	}	

}		


e7_bike_exit_troops_trucks()
{
	flag_wait ("player_on_bike");

	trigger_use ("bike_exit_troops_truck1");


}	

e7_tracking_player()
{

	trigger_wait ("main_road_start");
	flag_set ("player_on_main_road");
	player = get_players()[0];

	trigger_wait ("first_ramp");
	flag_set ("player_at_first_merge");

	trigger_wait ("gaz_chase_1");
	flag_set ("player_under_bridge");

	trigger_wait ("river_exit");
	flag_set ("player_at_river");

	//autosave_by_name ("motorcycle_river");


	trigger_wait ("final_turn");
	get_players()[0].ignoreme = true;
	flag_set ("player_at_final_turn");

	//trigger_wait ("ramp_approach");
	truck_node = GetVehicleNode("new_truck1", "targetname");
	truck_node waittill ("trigger");


	//player_at_final_ramp

}

#using_animtree ("generic_human");
e7_rez_truck_setup()
{
	rez_truck = GetEnt ("rez_truck", "targetname");

	rez_truck_warp_start = GetVehicleNode ("rez_truck_warp_start", "script_noteworthy");

	wait(.5);
	level.chopper_truck_target = Spawn ("script_origin", rez_truck.origin);	
	level.chopper_truck_target LinkTo (rez_truck, "tag_origin",(-300, 0, 0) );
	//level.chopper_truck_target thread Print3d_on_ent ("!!");

	trigger_wait ("chopper1_spawn");

	rez_truck thread play_truck_audio();

	//driver
	level.truck_driver = spawn_enemy_bike_rider ();
	level.truck_driver.ignorall = 1;
	level.truck_driver.animname = "truck_driver";
	level.truck_driver magic_bullet_shield();
	rez_truck thread anim_loop_aligned (level.truck_driver, "idle", "tag_origin_animate_jnt");
	level.truck_driver LinkTo (rez_truck);

	//gunner
	rez_truck_gunner = spawn_enemy_bike_rider (::rez_truck_gunner_logic, rez_truck);

	player_bike = GetEnt ("bike", "targetname");

	rez_truck SetTurretTargetEnt (player_bike);

	//aim turret at player early to avoid waiting
	trigger_wait ("rez_truck_start");

	player = get_players()[0];
	wait(.5);

	//BIKE GETS DAMAGED HERE
	level thread bike_damage();
	clientnotify( "vMF" );  //C. Ayers - Letting the client know that the motorcycle is dying
	player PlaySound( "veh_moto_dying_hit" );


	/*=====================
	CARJACK STARTS HERE
	======================*/

	flag_set ("begin_truck_event");

	player_bike SetVehMaxSpeed (70);
	rez_truck thread rez_truck_let_player_catchup(player_bike); 


	/*=====================
	MOVING TRUCK TO NEW SPOT FOR RAIL
	======================*/
	//wait for player to be next to truck
	flag_wait ("player_bike_in_jump_position");

	//rez_truck thread go_path (rez_truck_warp_start);
	rez_truck SetSpeed (60);

	/*=====================
	RE-ORIENT PLAYER FOR TRAIN JUMP
	=====================*/
	/*
	spot = rez_truck GetTagOrigin ("tag_gunner1");
	player_spot = Spawn ("script_origin", spot - (0,0,25));
	player_spot LinkTo (rez_truck);

	//temp angles ents
	player_lookdown = getstruct ("player_lookdown", "targetname");
	player_lookup = getstruct ("player_lookup", "targetname");
	*/
	trigger_wait ("final_turn");

	rez_truck SetSpeed (45);

	/*=====================
	MOVE REZ INTO PLACE FOR TRAIN JUMP READ
	=====================*/
	//flag is set on train jump note track
	flag_wait ("start_train_warp");
	rez_truck thread go_path (GetVehicleNode ("rez_final_path", "targetname") );
	rez_truck SetSpeed (40);
	flag_wait ("rez_vo_done");
	rez_truck SetSpeed (50);
	wait(3);
	rez_truck ResumeSpeed(10);

	//RIP Reznov
}	


rez_truck_let_player_catchup(player)
{
	//self = truck player is cathcing up to
	//end when player cacthes up and jumps on
	level endon ("player_bike_in_jump_position");
	wait(3);
	while(1)
	{
		//refresh players speed
		playerspeed = player GetSpeedMPH();
		//go half the speed of player
		if(playerspeed > 16 )
		{
			self SetSpeed(playerspeed -15);
		}	

		wait(.5);
	}	
}

#using_animtree ("player");	
player_carjack_setup()
{
	level thread addNotetrack_customFunction("player_body", "NT_switch", ::rez_truck_warp);

	flag_wait ("begin_truck_event");
	player_bike = GetEnt ("bike", "targetname");
	player = get_players()[0];
	rez_truck = GetEnt ("rez_truck", "targetname");
	rez_truck thread veh_magic_bullet_shield(1);

	//get the exact point where the player's carjack anim starts	
	spot  = GetStartOrigin( rez_truck.origin, rez_truck.angles, %int_vor_b04_jump_to_truck);

	level.anim_spot = Spawn ("script_origin", spot);
	level.anim_spot.angles = rez_truck.angles;
	level.anim_spot LinkTo (rez_truck);

	//spawning player body for carjack anim, link to truck, hide
	player_body = spawn_anim_model( "player_body" );
	player_body.angles = rez_truck.angles;
	player_body.origin = level.anim_spot.origin;
	player_body LinkTo (rez_truck);
	player_body Hide();

	fake_bike = spawn_anim_model("bike");
	fake_bike LinkTo(rez_truck);
	fake_bike Hide();

	/*==========================
	PLAYER JUMPS ON TRUCK
	==========================*/

	flag_wait ("player_bike_in_jump_position");
	player_bike notify ("exit_vehicle");
	fake_bike Show();
	player Unlink();

	//clear out any messages
	screen_message_delete();

	//save the game
	autosave_by_name("player_on_truck");

	//link player to body 
	player PlayerLinkToAbsolute(player_body,"tag_player");
	player thread truck_jump_shake(player_body, player_bike);

	//clear the direction of the turret
	rez_truck clearGunnerTarget();
	
	//play the anim of player jumping to truck
	rez_truck thread anim_single_aligned(fake_bike, "player_jump_to_truck", "tag_origin_animate_jnt");
	rez_truck anim_single_aligned (player_body, "player_jump_to_truck", "tag_origin_animate_jnt");

	//put player on the turret
	rez_truck UseVehicle( player, 1);

	switch( GetDifficulty() )
	{
	case "easy": 
		player.truck_max_damage = 5;
		break;
	case "medium":
		player.truck_max_damage = 10;
		break;
	case "hard":
		player.truck_max_damage = 15;
		break;
	case "fu":
		player.truck_max_damage = 20;
		break;			
	}
	
	player.player_truck_invulnurablility_interval = 1000;
	player.overridePlayerDamage = ::player_truck_damage_override;
		
	rez_truck thread maps\vorkuta_amb::player_turret_audio();

	//delete anim body
	player_body Delete();
	fake_bike Delete();
	player DisableInvulnerability();

	crash_bike = SpawnVehicle ("t5_veh_bike_m72_whole", "crashed_bike", "motorcycle_ai", level.anim_spot.origin, rez_truck.angles);
	wait(.05);
	crash_bike thread motorcycle_wipeout();

	wait(1);

	crash_bike = SpawnVehicle ("t5_veh_bike_m72_whole", "crashed_bike", "motorcycle_ai", level.anim_spot.origin, rez_truck.angles);
	wait(.05);
	crash_bike thread motorcycle_wipeout();

	/*===================
	Jump to train 
	====================*/

	trigger_wait ("final_turn");
	//IPrintLnBold ("end_turret");//kevin notify
	level notify( "end_turret_audio" );
	//note track in train jump to know when to warp the tuck and train
	level thread addNotetrack_customFunction("player_body", "NT_switch", ::train_and_truck_warp);

	train = GetEnt ("car3", "targetname");

	//spawn body
	player_body = spawn_anim_model( "player_body" );
	player_body.origin = player.origin;
	player_body.angles = rez_truck GetTagAngles ("tag_gunner1");
	player_body LinkTo (rez_truck);

	//get player off turret
	rez_truck UseBy(player); 

	//link to body
	player PlayerLinkToAbsolute(player_body,"tag_player");

	player thread lerp_fov_overtime( 1, 65 );

	//simulate shake on the truck
	player thread train_jump_shake();

	rez_truck anim_single_aligned (player_body, "player_train_setup", "tag_origin_animate_jnt");
	rez_truck thread anim_loop_aligned (player_body, "player_train_coming", "tag_origin_animate_jnt");
	wait(1.5);
	rez_truck anim_single_aligned (player_body, "player_train_look", "tag_origin_animate_jnt");

	//display prompt and fail condition
	player thread train_jump_timer();
	player thread train_wait_for_jump();

	//play the idle waiting to jump animation
	rez_truck thread anim_loop_aligned(player_body, "player_train_idle", "tag_origin_animate_jnt");

	flag_wait("flag_jumped_to_train");

	//smooth out the anim start transition (there may be some slight pop)
	player_body Unlink();
	player_body LinkTo (train, "tag_ladder1" );

	//turn off friendly names
	player SetClientDvar("cg_drawfriendlynames", 0);

	player thread train_jump_rumble(player_body);
	player thread train_on_shake();

	//turn on dust for the truck now
	rez_truck veh_toggle_tread_fx( true );

	//play the jump animation!
	level clientNotify ("jtt");
	train anim_single_aligned (player_body, "player_train_jump", "tag_ladder1");

	//close in the player's fov so the train appears closer
	player thread lerp_fov_overtime( 1, 50 );

	//give player some camera control after anim is done. 
	player StartCameraTween(.5);
	player PlayerLinkToDelta(player_body,"tag_player", 1, 80,20,10,10, true);
	wait(3);
	level clientNotify ("jttd");
}	

truck_jump_shake(player_body, player_bike)
{
	self StartCameraTween(1);
	wait(.5);
	player_bike Hide();
	player_body Show();

	wait(2);

	Earthquake(0.5, 0.7, self.origin, 256, self);
	self PlayRumbleOnEntity("grenade_rumble");

	wait(2);
	self PlayRumbleOnEntity("grenade_rumble");
}

train_jump_timer()
{
	screen_message_create (&"VORKUTA_BIKE_JUMP_LETGO"); 

	wait(7); //<== IMPORTANT TIMING TWEAK AS NEEDED

	if( !flag("flag_jumped_to_train") )
	{
		screen_message_delete();
		SetDvar( "ui_deadquote", &"VORKUTA_GENERIC_FAIL" ); 
		missionFailedWrapper();
	}
}	

train_jump_shake()
{
	rumble = 0;

	while( !flag("flag_jumped_to_train") )
	{
		Earthquake(0.15,0.05,self.origin,256,self);

		rumble++;
		if(rumble > 20)
		{
			rumble = 0;
			self PlayRumbleOnEntity("damage_light");
		}

		wait(0.05);
	}
}

train_on_shake()
{
	level endon("start_movie");

	wait(1);

	rumble = 0;

	while( 1 )
	{
		Earthquake(0.15,0.05,self.origin,256,self);

		rumble++;
		if(rumble > 10)
		{
			rumble = 0;
			self PlayRumbleOnEntity("damage_light");
		}

		wait(0.05);
	}
}

train_jump_rumble(player_body)
{
	player_body Hide();
	self StartCameraTween(1);

	Earthquake(0.5, 0.7, self.origin, 256, self);
	self PlayRumbleOnEntity("grenade_rumble");
	wait(.3);
	player_body Show();

	timescale_tween(1, 0.25, 0.3);
	wait(0.2);
	timescale_tween(0.25, 1, 0.3);

	//player in the air
	Earthquake(0.6, 1, self.origin, 256, self);
	self PlayRumbleOnEntity("grenade_rumble");
}

train_wait_for_jump()
{
	while(!flag("flag_jumped_to_train"))
	{
		if (self JumpButtonPressed() )
		{
			flag_set("flag_jumped_to_train");
			
			//TUEY switch music to ON THE TRAIN
			level thread maps\_audio::switch_music_wait ("ON_THE_TRAIN", 1);
			screen_message_delete();
		}
		wait 0.05;
	}
}

rez_truck_warp(guy)
{
	//this is the note track function that moves the truck when we carjack it
	rez_truck = GetEnt ("rez_truck", "targetname");

	flag_set ("rez_truck_warped");

	rez_truck thread play_truck_audio();

	rez_truck thread go_path (GetVehicleNode ("rez_truck_warp_start", "script_noteworthy"));
	rez_truck SetSpeed (60);


	//disabling vehicle override 
	level.old_vehicle_damage = level.overrideVehicleDamage;

}	

train_and_truck_warp(guy)
{
	//train and truck are waiting for this flag to warp
	flag_set ("start_train_warp");	

}	



#using_animtree ("generic_human");
rez_carjack_setup()
{
	flag_wait ("begin_truck_event");
	//c_rus_reznov_combat_fb rez model name

	rez_truck = GetEnt ("rez_truck", "targetname");

	flag_wait ("player_bike_in_jump_position");

	level.reznov.ignoreall = true;
	level.reznov gun_remove();

	level.reznov maps\_motorcycle::ai_ride_stop_riding();
	old_bike = GetEnt("rez_bike","targetname");
	old_bike Delete();

	level.reznov LinkTo (rez_truck);
	rez_bike = spawn_anim_model("bike");
	rez_bike LinkTo(rez_truck);

	//stop driving loop
	level.truck_driver anim_stopanimscripted();	

	//thread carjack anim on driver
	rez_truck thread anim_single_aligned (level.truck_driver, "carjack", "tag_origin_animate_jnt"); 

	//reznov carjack anim
	rez_truck thread anim_single_aligned(rez_bike, "rez_carjack", "tag_origin_animate_jnt");
	rez_truck anim_single_aligned (level.reznov, "rez_carjack", "tag_origin_animate_jnt");

	//reznov does driving loop with new animname
	rez_truck thread anim_loop_aligned (level.reznov, "idle", "tag_origin_animate_jnt");

	level.truck_driver Unlink();
	level.truck_driver stop_magic_bullet_shield();
	level.truck_driver ragdoll_death();

	rez_bike Delete();
}	

rez_carjack_open_door(reznov)
{
	rez_truck = GetEnt ("rez_truck", "targetname");
	rez_truck.animname = "truck";
	cycletime = getanimlength( level.scr_anim["truck"]["rez_carjack"] );
	rez_truck SetAnimRestart( level.scr_anim["truck"]["rez_carjack"] );
	wait cycletime;
	rez_truck clearanim( level.scr_anim["truck"]["rez_carjack"], 0 );
}

rez_truck_gunner_logic(truck)
{
	self gun_remove();
	self ignore_on();
	self.animname = "generic";
	self.truck = truck;
	self.truck thread truck_attack_player();
	self thread rez_truck_gunner_vacancy();
	self maps\_vehicle_aianim::vehicle_enter(truck, "tag_gunner1" );

	//self magic_bullet_shield();
	self waittill ("damage");
	self ragdoll_death();

	truck notify ("gunner_dies");

}		

rez_truck_gunner_vacancy()
{
	//self = gunner on back of the reznov truck
	//if the player doesn't shoot him, kill him when the player jumps
	self endon("death");	

	flag_wait ("player_close_to_truck");

	if( (IsDefined(self))&&(IsAlive(self)) )
	{	
		wait(0.5);
		MagicBullet("ak47_sp", level.reznov.origin, self.origin + (0,0,60));
		wait(0.05);
		MagicBullet("ak47_sp", level.reznov.origin, self.origin + (0,0,60));
		wait(0.05);
		MagicBullet("ak47_sp", level.reznov.origin, self.origin + (0,0,60));
		self ragdoll_death();	
	}	
}


truck_attack_player()
{
	//self = truck player gets on
	self endon ("gunner_dies");
	self endon ("player_bike_in_jump_position");
	trigger_wait ("river_exit");
	player = get_players()[0];
	self  setGunnerTargetVec (player.origin); 

	sound_ent = Spawn( "script_origin", self.origin );
	sound_ent LinkTo( self, "rear_hatch_jnt" );
	self thread delete_sound_ent(sound_ent);

	wait(2);

	while(1)
	{
		spot = player.origin;
		shoot_times = RandomIntRange (7, 10);
		self setGunnerTargetVec (spot); //TODO: offset

		for (i = 0; i < shoot_times; i++ )
		{
			self fireGunnerWeapon ();
			if( IsDefined( sound_ent ) )
			{
				sound_ent PlayLoopSound( "wpn_pbr_turret_fire_loop_npc" );
				wait (0.2);
			}
		}
		if( IsDefined( sound_ent ) )
		{
			sound_ent StopLoopSound( .25 );
		}

		self PlaySound( "wpn_pbr_turret_fire_loop_ring_npc" );
		wait (RandomFloatRange (1,2) );	
	}	
}		

bike_damage()
{
	level endon ("player_bike_in_jump_position");

	player = get_players()[0];
	player_bike = GetEnt ("bike", "targetname");

	bike_smoke = PlayFXOnTag ( level._effect["bike_smoke"], player_bike, "tag_origin");

	while(1)
	{
		wait(.5);
		earthquake(.3, .3, player.origin,100);
		player PlayRumbleOnEntity("grenade_rumble");
	}	

}		

e7_player_bike_to_truck()
{

	flag_wait ("begin_truck_event");
	wait(1);
	player_bike = GetEnt ("bike", "targetname");
	rez_truck = GetEnt ("rez_truck", "targetname");

	//wait for player to drive to truck spot
	while(1)
	{
		bike_truck_dist = Distance2Dsquared (player_bike.origin, level.anim_spot.origin);

		if (bike_truck_dist > 500*500)	
		{
			wait(.05);		
		}
		//player is within 100 units sqd of desired spot
		else if(bike_truck_dist < 500*500)	
		{
			break;
		}
		wait(.05);
	}	

	//IPrintLnBold ("taking control of bike");

	//player no longer has control, make invulnerable
	flag_set ("player_close_to_truck");
	get_players()[0] EnableInvulnerability();

	player_bike SetSpeed (70);

	//take control and tractor beam player rest of way
	while(1)
	{
		bike_truck_dist = Distance2Dsquared (player_bike.origin, level.anim_spot.origin);

		if (bike_truck_dist > 100*100)	
		{
			player_bike SetVehGoalPos (level.anim_spot.origin);
			wait(.05);		
		}
		else if(bike_truck_dist < 100*100)	
		{
			break;
		}
		wait(.05);
	}	

	flag_set ("player_bike_in_jump_position");

	//C. Ayers - End Vorkuta Motorcycle Audio
	//level notify( "evM" );
	//clientnotify( "evM" );

	wait(.05);  
	//restore fov?
	get_players()[0] lerp_fov_overtime( .5, 65 );
	//IPrintLnBold ("tractor beam complete");

}		


/*
rez_truck_tether_logic()
{

rez_bike = GetEnt ("rez_bike", "targetname");

finish_line = GetEnt ("finish_line", "targetname");

level endon ("jump_outcome_set");

while(1)
{
//self = truck reznov gets on
rez = rez_bike.origin;	
rez_speed = rez_bike GetSpeedMPH();
dist_from_rez = DistanceSquared(rez, self.origin);	
rez_finish_dist = Distance2D(rez,finish_line.origin);	
self_finish_dist = Distance2D(self.origin,finish_line.origin);
my_speed = self GetSpeedMPH();


//REZ IS BEHIND 
if(rez_finish_dist > self_finish_dist)
{
if ( dist_from_rez <= 10*10) //REZ is close 
{
//go roughly the same speed as the player
self SetSpeed (rez_speed);
//IPrintLnBold("rez is close. My speed: " +my_speed);
}
else if (dist_from_rez > 10*10)  //rez is falling behind 
{
//slow down to wait
self SetSpeed (45);	
} 
}
else //PLAYER IS IN FRONT
{
//PASS PLAYER
//self SetVehMaxSpeed(90);
self SetSpeed (80, 45);
//IPrintLnBold("Passing Rez. My speed: " +my_speed);
}
wait(0.5);	
}

}	

*/
e7_cleanup()

{
	//Guys that breach the warehouse when player gets on bike

	trigger_wait ("delete_warehouse_guys");
	wait(5);
	warehouse_guys = GetEntArray("bike_warehouse_breach_ai", "targetname");
	array_thread (warehouse_guys, ::Delete_me);

	//=-=-=-=-=-=-=-=-=-=-=-=-//

	//guys out the window when player jumps out window

	flag_wait ("player_at_first_merge");
	more_guys = GetEntArray ("exit_runners_hut_ai", "targetname");
	guys = GetEntArray ("exit_runners_ai", "targetname");	
	exit_ents = array_combine (guys, more_guys);
	array_thread (exit_ents, ::Delete_me);

	//=-=-=-=-=-=-=-=-=-=-=-=-//

	//Trucks, guys at intersection by first bridge

	flag_wait ("player_at_river");

	trucks = [];
	trucks[0] = GetEnt ("merge_guys_dropoff", "targetname");
	trucks[1] = GetEnt ("oncoming_truck", "targetname");
	trucks[2] = GetEnt ("oncoming_truck2", "targetname");

	guys = GetEntArray ("merge_dropoff_guys_ai", "targetname");
	more_guys = GetEntArray ("e7_road_guys_ai", "targetname");

	trash = array_combine (guys, more_guys);
	bridge_repel_guys = GetEntArray ("new_bridge_repel_ai", "targetname");

	more_trash = array_combine (trash, bridge_repel_guys);

	all_trash = array_combine (more_trash, trucks);

	array_thread (all_trash, ::Delete_me);


	//=-=-=-=-=-=-=-=-=-=-=-=-//

	//trucks, guys on to pof bridge

	flag_wait ("player_bike_in_jump_position");
	guys = GetEntArray ("bridge_guys_ai", "targetname");
	more_guys = GetEntArray ("bridge_truck_guys_ai", "targetname");
	even_more_guys = GetEntArray ("bridge_repel_guy_ai", "targetname");

	some_guys  = array_combine (guys,more_guys);
	all_guys = array_combine (some_guys, even_more_guys);

	guys = array_removedead (all_guys);

	vehicles = [];
	vehicles[0] = GetEnt ("quad_50", "targetname");
	vehicles[1] = GetEnt ("bridge_dropoff_truck", "targetname");

	trash = array_combine (guys, vehicles);

	array_thread (trash, ::Delete_me);

	//=-=-=-=-=-=-=-=-=-=-=-=-//
	//player get on Truck

	flag_wait ("player_bike_in_jump_position");
	trucks = GetEnt ("river_bridge_truck", "targetname");
	trucks Delete();

	array_thread (GetEntArray ("river_bridge_truck_guys_ai", "targetname"), ::Delete_me);

	//Approaching train
	trigger_wait ("final_turn");
	guys = GetEntArray ("rail_roadside_guys_ai", "targetname");
	array_thread (guys, ::Delete_me);

}	

e7_gaz_chaser_logic()
{

	attacker1 = simple_spawn_single ("attacker1", ::gaz_attacker_logic, "crouch");
	attacker2 = simple_spawn_single ("attacker2", ::gaz_attacker_logic, "crouch");

	wait(.10);

	my_guys = [];
	my_guys[0] = attacker1;
	my_guys[1] = attacker2;

	attacker1 LinkTo (self, "tag_guy4_low", (0,-8,0), (0,-135,0)); //pitch,yaw,roll
	attacker2 LinkTo (self,"tag_guy8_low", (0,10,0), (0,-135,0));

	self thread gaz_tether_logic();
	self thread gaz_guys_death_monitor(my_guys);
	self thread gaz_crash_manager(my_guys);
}	

#using_animtree ("generic_human");
e7_gaz_rail_logic()
{	
	attacker1 = simple_spawn_single ("attacker1", ::gaz_attacker_logic, "stand");
	attacker2 = simple_spawn_single ("attacker2", ::gaz_attacker_logic, "stand");
	my_driver = spawn_enemy_bike_rider();
	my_driver.animname = "generic";
	my_driver maps\_vehicle_aianim::vehicle_enter( self, "tag_driver" );

	wait(.10);

	my_guys = [];
	my_guys[0] = attacker1;
	my_guys[1] = attacker2;

	attacker1 LinkTo (self, "tag_guy1_low", (0,0,0), (0,0,0)); //pitch,yaw,roll
	attacker2 LinkTo (self,"tag_guy5_low", (0,7,0), (0,0,0));

	self thread gaz_rail_tether_logic();
	self thread gaz_guys_death_monitor(my_guys);
	self thread driver_death_monitor(my_driver);
	self thread gaz_crash_manager(my_guys);
}	

driver_death_monitor(my_driver)
{
	self endon("reached_end_node");

	//self = gaz truck
	my_driver waittill ("death");
	self notify ("my_driver_died");

	//truck was killed increase vehicle count for achievment
	bike_achievement_add();
}	

gaz_guys_death_monitor(my_guys)

{	
	//self = gaz truck
	array_wait (my_guys, "death");
	self notify ("my_guys_dead");
}	


gaz_crash_manager(my_guys, my_driver)
{
	//self = gaz truck
	self waittill_any ("my_guys_dead", "reached_end_node", "my_driver_died", "death");

	PlayFX (level._effect["truck_explosion"], self.origin);
	PlayFXOnTag (level._effect["truck_explosion_linked"], self, "tag_origin"); 

	self thread truck_wipeout();

	//remove dead guys from array 
	my_guys = array_removedead (my_guys);

	//add the driver to array if hes alive
	if(IsDefined(my_driver))
	{
		my_guys = add_to_array (my_guys, my_driver);
	}
	//kill them 	
	array_thread (my_guys, ::e7_rider_crash); 

	level Spawn_vehicle_gibs(self);
	wait(.05);
	PhysicsExplosionSphere (self.origin, 800, 790, 10);		

}

gaz_attacker_logic(stance)
{
	//self = guy on back of truck
	self endon ("death");
	self.dropweapon = 0;
	self AllowedStances (stance);
	self waittill ("damage");
	//self thread e7_rider_crash();
}	


gaz_tether_logic()
{
	//self = gaz truck
	start = GetVehicleNode (self.script_noteworthy +"_start", "targetname");
	self drivepath (start);
	self SetSpeed (60);	

	player_bike = GetEnt ("bike", "targetname");

	//script_origin at end of event
	finish_line = GetEnt ("finish_line", "targetname");

	level endon ("player_bike_in_jump_position");

	wait (2);

	while(1)
	{
		//self = enemy motorcycle
		player = player_bike.origin;	
		dist_from_player = DistanceSquared(player, self.origin);	
		player_finish_dist = Distance2D(player,finish_line.origin);	
		self_finish_dist = Distance2D(self.origin,finish_line.origin);
		my_speed = self GetSpeedMPH();
		speed_offset = RandomIntRange (10,15);

		//PLAYER IS BEHIND 
		if(player_finish_dist > self_finish_dist)
		{
			if ( (dist_from_player <= 700*700)&&(level.player_speed > 0) ) //player is close and going FWD
			{
				//go roughly the same speed as the player
				self SetSpeed (level.player_speed + speed_offset);		
			}
			else if ( (dist_from_player > 700*700) ) //player is falling behind 
			{
				//slow down to wait
				self SetSpeed (45);			
			} 
		}
		else //PLAYER IS IN FRONT
		{
			//PASS PLAYER			
			self SetSpeed (80, 45);
		}
		wait(0.5);	
	}

}	


gaz_rail_tether_logic()
{
	//self = gaz truck
	self endon ("death");
	start = GetVehicleNode (self.script_noteworthy +"_start", "targetname");
	self drivepath (start);
	self SetSpeed (70);	
	rez_truck = GetEnt ("rez_truck", "targetname");
	//script_origin at end of event
	finish_line = GetEnt ("finish_line", "targetname");

	wait (1);

	while(1)
	{
		random_dist = RandomIntRange (900, 1400);
		player = rez_truck.origin;	
		dist_from_player = Distance2dSquared(player, self.origin);	
		truck_speed = rez_truck GetSpeedMPH();

		if  (dist_from_player <= random_dist*random_dist ) //player is close and going FWD
		{
			//go roughly the same speed as the player
			self SetSpeed (truck_speed);	
		}
		else if ( (dist_from_player > random_dist*random_dist) ) //player is getting ahead 
		{
			//speed up
			self SetSpeed (80);	
		} 
		wait(0.5);		 
	}

}	

barrel_truck()
{
	trig = GetEnt ("barrel_truck_trigger", "targetname");
	dmg_src = getstruct ("barrel_truck_damage", "targetname");
	barrels = GetEntArray ("truck_barrels", "script_noteworthy");

	trig waittill ("trigger");
	truck = GetEnt ("barrel_truck", "targetname");
	playfx (level._effect["truck_explosion"], dmg_src.origin);
	PlaySoundatposition( "evt_moto_heli_crash", dmg_src.origin );
	RadiusDamage (dmg_src.origin, 300, 1000, 1000);
	truck thread truck_wipeout();

	//these guys will be spawned by now
	guys = GetEntArray ("barrel_truck_guys_ai", "targetname");
	for (i = 0; i < guys.size; i++ )
	{
		guys[i]  thread animscripts\death::flame_death_fx();
		guys[i]  thread Ragdoll_Death();
		wait(.02);
	}
	level Spawn_vehicle_gibs(truck);
	PhysicsExplosionSphere (dmg_src.origin, 500, 490, 2);		

	for (i = 0; i < barrels.size; i++ )
	{
		barrels[i] Hide(); 
	}

}	

train_jump_debug_info( player_body, player_truck) 
{
	// self = player
	flag_wait ("train_jump_begin");
	wait(1);
	train = GetEnt ("car3", "targetname");

	while(1)	
	{
		start_pos = player_body.origin;
		end_pos = train GetTagOrigin( "tag_ladder1" );

		direction_vec = end_pos - start_pos;

		//IPrintLn( direction_vec );
		//IPrintLn( Length (direction_vec) );

		line( start_pos, end_pos, ( 1,1,1 ) );
		RecordLine( start_pos, end_pos, ( 1,1,1 ), "Script", self );

		wait(0.05);
	}
}

truck_fail()
{
	level endon ("player_bike_in_jump_position");//stop monitoring for failure once the player has gotten on the truck succesfully

	trigger_wait("truck_fail"); //wait for trigger by player

	SetDvar( "ui_deadquote", &"VORKUTA_TRUCK_JUMP_FAIL" ); 
	missionFailedWrapper();
}	

e7_reznovs_demise()
{
	//spawns the calvary of vehicles that surround reznov after player jumps on train
	flag_wait ("start_train_warp");
	trigger_use ("reznovs_demise");


}	

e7_VO()
{
	flag_wait ("player_in_warehouse");

	//TUEY Set music state to SPEECH_OF_DECADENCE
	setmusicstate("SPEECH_OF_DECADENCE");

	player = get_players()[0];
	player.animname = "mason";

	//replace with nag if we get one
	//do_nag_vo(level.reznov, "door_nag", "player_on_bike", 15); 

	flag_wait ("player_on_main_road");
	level.reznov anim_single( level.reznov, "faster" );//C'mon Mason!!

	flag_wait ("vo_train");
	level.reznov anim_single( level.reznov, "there_is_train" );////There is the train! Hurry Mason!

	flag_wait ("vo_without_fight"); //bottom of first ramp? Tweak as needed
	player anim_single( player, "without_fight" );////They are not letting us go without a fight!

	flag_wait ("vo_this_way");
	level.reznov anim_single( level.reznov, "this_way" );


	flag_wait ("vo_mg");//after river jump
	level.reznov anim_single( level.reznov, "M_G" ); //MG!!!

	flag_wait ("begin_truck_event");
	AB_nag_vo(level.reznov, "on_mg", "jump_truck", "player_bike_in_jump_position", 5);

	flag_wait ("vo_keep");
	//IPrintLnBold ("enemy bikes triggered?");
	level.reznov anim_single( level.reznov, "keep" ); //keep on them!!

	flag_wait ("vo_wheres_train");
	player anim_single( player, "where_train" ); //where the fucks the train?

	flag_wait ("vo_there");
	level.reznov anim_single( level.reznov, "there" ); //there!!

	flag_wait ("vo_jump_nag");
	level.reznov anim_single( level.reznov, "jump_mason_jump" ); //Jump mason Jump!
	wait(1);
	do_nag_vo(level.reznov, "go_mason_go", "flag_jumped_to_train", 5); 

	//only continue if player made it to the train
	flag_wait("flag_jumped_to_train");
	playsoundatposition( "evt_num_num_02_r_louder" , (0,0,0) );

	start_movie_scene();
	add_scene_line(&"vorkuta_vox_vor1_s1_907A_inte", 1, 2.5);		//And that was the last you saw of Victor Reznov?
	add_scene_line(&"vorkuta_vox_vor1_s1_909A_maso", 3.5, 3);		//Yeah. At least for while...
	//start streaming the end video in

	level.movie_trans_in = "black";
	level.movie_trans_out = "white";
	level thread play_movie("mid_vorkuta_3", false, false, "start_movie", true, "end_movie");

	wait(2);
	player anim_single( player, "your_turn" ); //your turn!
	player anim_single( player, "come_on" ); //come on!!
	player anim_single( player, "step8_freedom" ); //step 8 - FREEDOM!

	level.reznov anim_single( level.reznov, "for_you_mason" ); //for you mason,
	flag_set ("rez_vo_done");
	level.reznov anim_single( level.reznov, "not_for_me" ); //not for me

	player anim_single( player, "reznov" ); //Reznov!!

	//to help audio on final video
	SetDvar("r_streamFreezeState",1);
}	

//SELF = rez_truck
play_truck_audio()
{
	level notify( "truck_audio_end" );

	front = self GetTagOrigin( "tag_engine_left" );
	back = self GetTagOrigin( "rear_hatch_jnt" );

	ent1 = Spawn( "script_origin", front );
	ent2 = Spawn( "script_origin", back );

	ent1 LinkTo( self, "tag_engine_left" );
	ent2 LinkTo( self, "rear_hatch_jnt" );

	ent1 PlayLoopSound( "veh_truck_front" );
	ent2 PlayLoopSound( "veh_truck_rear" );

	level thread delete_truck_ents( ent1, ent2 );

}

delete_truck_ents( ent1, ent2 )
{
	level waittill( "truck_audio_end" );
	ent1 Delete();
	ent2 Delete();
}

delete_sound_ent(sound_ent)
{
	self waittill_any("player_bike_in_jump_position" , "gunner_dies" );
	sound_ent Delete();
}

play_train_audio()
{
	self notify( "train_audio_end" );

	if( self.targetname == "car1" )
	{
		self thread play_train_horn_audio();
	}

	ent = Spawn( "script_origin", self.origin );
	ent LinkTo( self );
	ent PlayLoopSound( "veh_train_move_fast" );
	self waittill( "train_audio_end" );
	ent Delete();
}

play_train_horn_audio()
{
	self endon( "train_audio_end" );

	alias = [];
	alias[0] = "short";
	alias[1] = "med";
	alias[2] = "long";

	while(1)
	{
		self PlaySound( "veh_train_horn_" + alias[RandomIntRange(0,3)], "sounddone" );
		self waittill( "sounddone" );
		wait(RandomFloatRange( 1, 12 ));
	}
}