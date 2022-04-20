/*
	Rebirth: Mason Lab Event - 
		
	The player goes down the elevator shaft, fights through the labs, and ends in Steiner's office.

*/

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_vehicle;
#include maps\rebirth_anim;
#include maps\_anim;
#include maps\_civilians;
#include maps\_civilians_anim;
#include maps\rebirth_utility;
#include maps\_music;

/*------------------------------------------------------------------------------------------------------------
																								Event:  Mason Lab
------------------------------------------------------------------------------------------------------------*/

//------------------------------------
// Main event thread.  Controls the flow of the event.  
// Waits for the proper flag to be set to move on.
event_mason_lab() 
{		
	reznov_is_defined = false;
	while(!reznov_is_defined)
	{
		if( IsDefined( level.heroes[ "reznov" ] ) )
		{
			reznov_is_defined = true;
		}
		
		wait(1.0);
	}
	level.heroes["reznov"] set_ignoreall( false );
	
	level thread mason_lab_objectives();
	
	battlechatter_on();
	battlechatter_on( "allies" );
	battlechatter_on( "axis" );
	get_players()[0].animname = "mason";
	
	destructible_jeeps = GetEntArray("destructible_jeep", "targetname");
	array_thread(destructible_jeeps, ::jeep_death_damage);
	
	// event functions
	level thread maps\rebirth_mason_stealth::docks_clean_up();
	level thread keep_mason_in_lab();
//	level thread lab_lights_spin();
	level thread lab_pigs();
	level thread lab_monkey_manager();
	//level thread monkey_see();
	level thread human_room_gas();
	level thread flash_room_doors();
	level thread flash_chamber();
	level thread flashroom_enemy_flank_player();
	//level thread get_reznov_into_tunnel();
	level thread lab_vo();
	level thread steiners_hallway();
	//level thread make_flash_guy_leave();
	//level thread delete_reznov_color_chain_left();
	//level thread delete_reznov_color_chain_right();
	level thread confront_steiner();
	
	flag_wait( "event_mason_lab_done" );
}

//	trigger_wait( "in_elevator" );
//	rebirth_dialogue( "reznov_in_elevator" );

//------------------------------------
// Spin the warning lights inside the lab
//lab_lights_spin()
//{
//	level endon( "stop_alarm_lights" );
//	
//	rotate_lights = GetEntArray( "rotating_light", "targetname" );	
//	
//	while( true )
//	{
//		for( i = 0; i < rotate_lights.size; i++ )
//		{
//			rotate_lights[i] RotateYaw( 360, 1 );
//		}
//		
//		rotate_lights[0] waittill( "rotatedone" );
//	}
//}

jeep_death_damage()
{
	self waittill("death");
	
	self RadiusDamage(self.origin, 250, 500, 500, undefined, "MOD_EXPLOSIVE");
}

make_flash_guy_target_player()
{
	self endon("death");
	self endon("stop_targeting_player");
	
	player = get_players()[0];
	num_seconds = 3;
	while(true)
	{
		if( self CanSee( player ) )
		{
			self shoot_at_target( player, undefined, 1 );
		}
		else
		{
			self aim_at_target( player, num_seconds );
		}
		wait(0.06);
	}
}

//------------------------------------
// Open the door that's needed, close the one
// that is not.
flash_room_doors()
{
	flag_wait( "mason_doors_setup_done" );
	
	// Door that Reznov closes
	hall_door_clip = GetEnt( "flash_room_to_hall_door", "targetname" );
	hall_door = GetEnt( "steiner_hall_door", "targetname" );
	
	// Door for Mason and Reznov
	steiner_door_clip = GetEnt( "steiner_door_clip", "targetname" );
	steiner_office_door = GetEnt( "steiner_office_door", "targetname" );
	
	// Door for Hudson and Weaver
	door_to_office = GetEnt( "flash_room_to_office_door", "targetname" );
	clip_to_office = GetEnt( "flash_room_to_office_clip", "targetname" );
	clip_to_office LinkTo( door_to_office );

                //door_to_hall.original_pos = door_to_hall.origin;
                //door_to_hall MoveZ( door_to_hall.origin[2] - 500, .1 );
                //door_to_hall SetModel(steiner_hall_door);
                //door_to_hall.origin = steiner_hall_door.origin;
	hall_door_clip ConnectPaths();
	hall_door_clip LinkTo(hall_door);
	if(level.start_point == "default" || level.start_point == "mason_stealth" || level.start_point == "mason_lab")
	{
		hall_door RotateYaw(-90, .1);
	}
                
	steiner_door_clip LinkTo(steiner_office_door);
                //steiner_office_door RotateYaw(90, .1);
                
	flag_wait( "event_lab_entrance_done" );
                
                //steiner_door_clip MoveZ( steiner_door_clip.origin[2] - 500, .1 );
                //steiner_hall_door RotateYaw(-90, .1);
	hall_door_clip DisconnectPaths();
	
	level.steiner_window SetModel("p_rus_rb_steiner_window_01");
	
	// Reset the fusebox angle
	/*
	if(level.start_point == "default" || level.start_point == "mason_stealth" || level.start_point == "mason_lab")
	{
		fusebox = GetEnt("fusebox2", "targetname");
		fusebox.angles = level.fusebox_angles;
	}
	*/
                
	flag_wait( "hudson_in_office" );
	wait(.5);
	clip_to_office ConnectPaths();
	//door_to_office MoveZ( door_to_office.origin[2] - 500, .1 );
	door_to_office_open = ( 14910.1, 11362.1, -337 );
	door_to_office MoveTo( door_to_office_open, 0.09 );
	
	steiner_door_clip ConnectPaths();
	if(level.start_point != "default" || level.start_point != "mason_stealth" || level.start_point != "mason_lab")
	{
		steiner_office_door RotateYaw(90, .1);
		//steiner_office_door ConnectPaths();
  }
  
  prevent_hazmat_in_flash();
}

prevent_hazmat_in_flash()
{
	stop_hazmat = GetEntArray("stop_hazmat", "targetname");
	close_chamber_doors_0 = getstruct("close_chamber_doors_0", "targetname");
	
	for(i = 0; i < stop_hazmat.size; i++)
	{
		stop_hazmat[i] MoveTo((stop_hazmat[i].origin[0], stop_hazmat[i].origin[1], close_chamber_doors_0.origin[2]), 0.4);
		wait(0.4);
		stop_hazmat[i] DisconnectPaths();
	}
}

delete_reznov_color_chain_left()
{
	level endon( "flash_color_deleted_left" );
	level endon( "reznov_closed_the_door" );
	
	reznov = level.heroes["reznov"];
	flash_color_left = GetEnt( "flash_color_left", "targetname" );
	
	while( !reznov IsTouching( flash_color_left ) )
	{
		wait(0.05);
	}
	
	level notify( "flash_color_deleted_right");

	reznov = level.heroes["reznov"];
	reznov.script_forcegoal = true;

	reznov_flash_color_chain = GetEntArray( "flash_reznov_color_chain", "script_noteworthy" );
	for(i = 0; i < reznov_flash_color_chain.size; i++)
	{
		reznov_flash_color_chain[i] Delete();
	}
}

delete_reznov_color_chain_right()
{
	level endon( "flash_color_deleted_right" );
	level endon( "reznov_closed_the_door" );
	
	reznov = level.heroes["reznov"];
	flash_color_right = GetEnt( "flash_color_right", "targetname" );
	while( !reznov IsTouching( flash_color_right ) )
	{
		wait(0.05);
	}

	level notify( "flash_color_deleted_left");

	reznov = level.heroes["reznov"];
	reznov.script_forcegoal = true;
	
	reznov_flash_color_chain = GetEntArray( "flash_reznov_color_chain", "script_noteworthy" );
	for(i = 0; i < reznov_flash_color_chain.size; i++)
	{
		reznov_flash_color_chain[i] Delete();
	}
}

//------------------------------------
// Clean up spawners and AI in the lab
lab_clean_up()
{	
	lab_guys = GetEntArray( "lab_int_mason_enemy", "script_noteworthy" );
	lab_enemy_deck = GetEntArray( "lab_mason_enemy_deck", "script_noteworthy" );
	reznov_lab_color_chain = GetEntArray( "lab_reznov_color_chain", "script_noteworthy" );
	reznov_flash_color_chain = GetEntArray( "flash_reznov_color_chain", "script_noteworthy" );
	lab_civs = GetEntArray( "lab_civilians", "script_noteworthy" );
	lab_cower_civs = GetEntArray( "lab_cower_civilians", "script_noteworthy" );
	lab_observ_civs = GetEntArray( "lab_observ_civilians", "script_noteworthy" );
	mason_lab_save = GetEntArray("mason_lab_save", "script_noteworthy");
	mason_lab_obj = GetEntArray("mason_lab_obj", "script_noteworthy");
	mason_lab_extra = GetEntArray("mason_lab_extra", "script_noteworthy");
	mason_lab_clean_ents = GetEntArray( "mason_lab_spawner", "script_noteworthy" );
	
	mason_lab_clean_ents = array_merge(mason_lab_clean_ents, lab_guys);
	mason_lab_clean_ents = array_merge(mason_lab_clean_ents, lab_enemy_deck);
	mason_lab_clean_ents = array_merge(mason_lab_clean_ents, reznov_lab_color_chain);
	mason_lab_clean_ents = array_merge(mason_lab_clean_ents, reznov_flash_color_chain);
	mason_lab_clean_ents = array_merge(mason_lab_clean_ents, lab_civs);
	mason_lab_clean_ents = array_merge(mason_lab_clean_ents, lab_cower_civs);
	mason_lab_clean_ents = array_merge(mason_lab_clean_ents, lab_observ_civs);
	mason_lab_clean_ents = array_merge(mason_lab_clean_ents, mason_lab_save);
	mason_lab_clean_ents = array_merge(mason_lab_clean_ents, mason_lab_obj);
	mason_lab_clean_ents = array_merge(mason_lab_clean_ents, mason_lab_extra);
	
	mason_lab_clean_ents[mason_lab_clean_ents.size] = GetEnt("reznov_close_door", "script_noteworthy");
	mason_lab_clean_ents[mason_lab_clean_ents.size] = GetEnt("obj_outside_steiner_door", "script_noteworthy");
	mason_lab_clean_ents[mason_lab_clean_ents.size] = GetEnt("obj_open_steiner_door", "script_noteworthy");
	//mason_lab_clean_ents[mason_lab_clean_ents.size] = GetEnt("enemy_flashroom", "script_noteworthy");
	
	for(i = 0; i < mason_lab_clean_ents.size; i++)
	{
		mason_lab_clean_ents[i] Delete();
	}
	
	/*	
	for( i = 0; i < lab_spawners.size; i++ )
	{
		lab_spawners[i] Delete();
	}
	
	for( i = 0; i < lab_guys.size; i++ )
	{
		lab_guys[i] Delete();
	}
	
	for( i = 0; i < lab_enemy_deck.size; i++ )
	{
		lab_enemy_deck[i] Delete();
	}
	
	for( i = 0; i < lab_civs.size; i++ )
	{
		lab_civs[i] Delete();
	}	
	
	for( i = 0; i < reznov_color_chain.size; i++ )
	{
		reznov_color_chain[i] Delete();
	}

	monkeys = GetEntArray( "lab_monkey", "script_noteworthy" );
	for( i = 0; i < monkeys.size; i++ )
	{
		monkeys[i] Delete();
	}
	
	monkey_trigs = GetEntArray( "monkey_trig", "script_noteworthy" );
	for( i = 0; i < monkey_trigs.size; i++ )
	{
		monkey_trigs[i] Delete();
	}
	*/
}

//------------------------------------
// Plays the gas leak effects
human_room_gas()
{
	trigger_wait( "human_room_canisters" );
	exploder( 229 );	
	
	wait( 5 );
	stop_exploder( 229 );
}

mason_is_camping()
{
	self endon("death");
	level endon("stop_camping_function");
	
	enemy_hunting_player = false;
	player_origin_previous = self.origin;
	while( true )
	{
		wait(10.0);
		
		player_origin_current = self.origin;
		player_previous_min_x = player_origin_previous + (-64, 0, 0);
		player_previous_max_x = player_origin_previous + (64, 0, 0);
		player_previous_min_y = player_origin_previous + (0, -64, 0);
		player_previous_max_y = player_origin_previous + (0, 64, 0);
		player_previous_min_z = player_origin_previous + (0, 0, -64);
		player_previous_max_z = player_origin_previous + (0, 0, 64);
		
		if( (player_origin_current[0] > player_previous_min_x[0]) && (player_origin_current[0] < player_previous_max_x[0])
		 && (player_origin_current[1] > player_previous_min_y[1]) && (player_origin_current[1] < player_previous_max_y[1])
		 && (player_origin_current[2]> player_previous_min_z[2]) && (player_origin_current[2] < player_previous_max_z[2]) )
		{
			if(enemy_hunting_player == false)
			{
				enemy_ais = get_ai_array("lab_int_mason_enemy", "script_noteworthy");
				if(enemy_ais.size > 0)
				{
					random_int = RandomIntRange(0, enemy_ais.size);
					enemy_ais[random_int] maps\rebirth_hudson_lab::hunt_down_player();
					//enemy_hunting_player = true;
				}
			}
		}
		
		player_origin_previous = player_origin_current;
	}
}

//------------------------------------
// Have reznov ignore everything and go in
get_reznov_into_tunnel()
{
	//trigger_wait( "start_lead_to_steiner" );
	
	reznov = level.heroes["reznov"];
	
	enemy_ais = get_ai_array("lab_int_mason_enemy", "script_noteworthy");
	array_thread( enemy_ais, maps\rebirth_hudson_lab::hunt_down_player );
	
	reznov disable_ai_color();
	
	//enemies_left_on_deck = get_ai_array("lab_mason_enemy_deck", "script_noteworthy");
	enemies_left = get_ai_array("lab_int_mason_enemy", "script_noteworthy");
	
	//enemies_left = array_merge(enemies_left, enemies_left_on_deck);
	if(enemies_left.size > 0)
	{
		/*
		reznov_final_node = GetNode( "reznov_last_stand", "targetname" );
		reznov SetGoalNode( reznov_final_node );
	
		reznov waittill("goal");
		*/
	
		//enemies_left_on_deck = get_ai_array("lab_mason_enemy_deck", "script_noteworthy");
		enemies_left = get_ai_array("lab_int_mason_enemy", "script_noteworthy");
		enemies_left[enemies_left.size] = get_ai("enemy_flashroom", "script_noteworthy" );
	
		//enemies_left = array_merge(enemies_left, enemies_left_on_deck);
		for(i = 0; i < enemies_left.size; i++)
		{
			while( IsDefined(enemies_left[i]) )
			{
				//MagicBullet("ak74u_sp", reznov.origin, enemies_left[i].origin);
				reznov shoot_at_target( enemies_left[i] );
				//enemies_left[i] DoDamage(enemies_left[i].health * 2, reznov.origin);
				wait(0.06);
			}
		}
	}
	
	reznov set_ignoreall( true );
	reznov set_ignoreme( true );
}



//------------------------------------
// Have door block the player from backtracking
keep_mason_in_lab()
{
	door_clip = GetEnt( "mason_door_blocker", "targetname" );
	mason_door_model_blocker = GetEnt( "mason_door_model_blocker", "targetname" );
	mason_door_model_blocker_open = (14505.5, 14488.3, -337);
	door_clip LinkTo( mason_door_model_blocker );
	//mason_door_model_blocker LinkTo( door_clip );
	door_clip DisconnectPaths();
	
	trigger_wait( "trig_caught_vertov" );
	mason_door_model_blocker MoveTo( mason_door_model_blocker_open, 0.09);
	door_clip ConnectPaths();
	//door Delete();
}



//------------------------------------
// if canisters are shot, seal up the flash chamber
flash_chamber()
{
	level.gas_by_player = false;	
	
	//trigger_wait( "chamber_canister_hit" );
	chamber_canister_damage_trig = GetEnt("chamber_canister_hit", "targetname");
	chamber_canister_damage_trig waittill("trigger", attacker);
	
	player = get_players()[0];
	
	if(attacker == player)
	{
		level.gas_by_player = true;	
	}
	
	exploder( 230 );
	
	// SOUND - Shawn J
	playsoundatposition ("evt_gas_leak", (14622, 11755, -328));
	
	//wait( 1 );
	
	clientnotify ("fans_chamber_on");
	fans = GetEntArray( "chamber_fan", "targetname" );
	array_thread( fans, ::flash_chamber_fans );
	
	flash_chamber_doors = GetEntArray( "flash_chamber_door", "targetname" );
	clip_chamber_doors = GetEntArray( "clip_chamber_doors", "targetname" );
	
	for(i = 0; i < clip_chamber_doors.size; i++)
	{
		clip_chamber_doors[i] LinkTo(flash_chamber_doors[i]);
	}
	
	array_thread( flash_chamber_doors, ::slam_chamber_doors );
	
	/*
	chamber_door_0 = GetEntArray( "chamber_door_0", "targetname" );
	array_thread( chamber_door_0, ::slam_chamber_doors );
	
	chamber_door_1 = GetEntArray( "chamber_door_1", "targetname" );
	array_thread( chamber_door_1, ::slam_chamber_doors );
	*/
	
	level thread kill_chamber_occupants();
	
	wait( 9 );
	//stop_exploder( 230 );
	
	clientnotify( "fans_chamber_off" );
}

flash_chamber_fans()
{
	clientnotify( "fans_chamber_off" );
	while( true )
	{
		self RotateYaw( 360, .19 );	
		//self waittill( "rotatedone" );
		wait(0.16);
	}
}

slam_chamber_doors()
{
	/*
	if(self.targetname == "chamber_door_0")
	{
		close_chamber_doors_0 = getstruct("close_chamber_doors_0", "targetname");
		self MoveTo(close_chamber_doors_0.origin, 0.4);
	}
	else if(self.targetname == "chamber_door_1")
	{
		close_chamber_doors_1 = getstruct("close_chamber_doors_1", "targetname");
		self MoveTo(close_chamber_doors_1.origin, 0.4);
	}
	*/
	if(self.targetname == "flash_chamber_door")
	{
		close_chamber_doors_0 = getstruct("close_chamber_doors_0", "targetname");
		self MoveTo((self.origin[0], self.origin[1], close_chamber_doors_0.origin[2]), 0.4);
		wait(0.4);
		self DisconnectPaths();
	}
	/*
	else
	{
		targ_struct = getstruct( self.target, "targetname" );
		door_offset = 23;
		self MoveTo( targ_struct.origin + ( 0, 0, door_offset ), .4 );
		wait( .4 );
		self DisconnectPaths();
	}
	*/
}

flashroom_enemy_flank_player()
{
	trigger_wait("inside_flash_chamber");
	
	enemy_ais = get_ai_array("lab_int_mason_enemy", "script_noteworthy");
	array_thread( enemy_ais, ::flank_player_at_flashroom );
}

flank_player_at_flashroom()
{
	self endon("death");
	
	while( true )
	{
		trigger_wait("inside_flash_chamber");
		
		flank_node = GetNode( "flashroom_flank", "targetname" );
		self SetGoalNode( flank_node );
		
		self set_ignoreall(true);
	
		self waittill("goal");
	
		chamber_canister_trig = GetEnt("chamber_canister_hit", "targetname");
		inside_flashroom = GetEnt( "inside_flash_chamber", "targetname" );
		player = get_players()[0];
		while( player IsTouching( inside_flashroom ) )
		{
			if( IsDefined( self ) )
			{
				self shoot_at_target( chamber_canister_trig );
			}
			wait(0.06);
		}
	
		reset_node = GetNode( "reznov_last_stand", "targetname" );
		self SetGoalNode( reset_node );
		self waittill("goal");
		//sef maps\rebirth_hudson_lab::hunt_down_player();
		self set_ignoreall(false);
		cover_door = GetEnt( "cover_door_volume", "targetname" );
		self SetGoalVolume( cover_door );
		
		wait(0.06);
	}
}

kill_chamber_occupants()
{
	death_trig = GetEnt( "inside_flash_chamber", "targetname" );
	
	players = get_players();
	for( i = 0; i < players.size; i++ )
	{
		if( IsDefined( players[i] ) && players[i] IsTouching( death_trig ) )
		{
			players[i] thread player_die_in_chamber();
		}
	}
	
	enemies = GetAIArray( "axis" );
	for( i = 0; i < enemies.size; i++ )
	{
		if( IsDefined( enemies[i] ) && IsAlive( enemies[i] ) && enemies[i] IsTouching( death_trig ) )
		{
			enemies[i] thread ai_die_in_chamber();
			enemies[i] SetClientFlag(0);
		}
	}
	
	level notify("kill_monkeys_with_gas");
}

ai_die_in_chamber()
{
	//wait(2);
	self.a.nodeath = true;
	self thread anim_generic( self, "gas_death_1" );
	
	self StartRagdoll();
}

player_die_in_chamber() 
{
	flag_clear( "can_save" );
	wait(0.5);
	//self DoDamage( self.health +10, self.origin );
	
	if( !flag( "killed_in_flashroom" ) )
	{
		flag_set( "killed_in_flashroom" );
		
		self DisableWeapons();
		self StartPoisoning();
	
		//Sound - Shawn J
		self playsound( "evt_gas_poison" );

		wait(0.5);

		player_hands = spawn_anim_model("player_hands", self.origin, self.angles);
		self PlayerLinkToAbsolute(player_hands, "tag_player");
		player_hands anim_single(player_hands, "gas_death");
	
		//Sound - Shawn J
		self playsound( "evt_gas_death" );
	
		// SetDvar( "ui_deadquote", &"REBIRTH_NOVA6_EXPOSED" );
		// self thread maps\_load_common::special_death_indicator_hudelement( "hud_obit_nova_gas", 96, 96 );
		missionfailedwrapper( &"REBIRTH_NOVA6_EXPOSED", "hud_obit_nova_gas", 64, 64, undefined, 0, 15 );
	}
	
	flag_clear( "can_save" );
}



lab_vo()
{
	player = get_players()[0];
	reznov = level.heroes["reznov"];
	
	player thread mason_is_camping();
	
	vo_russian = Spawn("script_model", player.origin);
	vo_russian SetModel("tag_origin");
	vo_russian.animname = "base_loudspeaker";
	
	vo_russian anim_single( vo_russian, "priority_one_alert" );
		
	trigger_wait( "weaver_at_security_door" );
	
	level notify("stop_camping_function");
	
	enemy_ais = get_ai_array("lab_int_mason_enemy", "script_noteworthy");
	
	for(i = 0; i < enemy_ais.size; i++)
	{
		if(enemy_ais[i].script_string == "flashroom_enemy")
		{
			enemy_ais = array_remove(enemy_ais, enemy_ais[i]);
		}
	}
	
	array_thread( enemy_ais, maps\rebirth_hudson_lab::hunt_down_player );
	
	level thread delete_reznov_color_chain_left();
	level thread delete_reznov_color_chain_right();
	
	if( IsDefined(reznov) )
	{
		reznov anim_single( reznov, "be_cautious" );
	}
	
	level thread mason_lab_hudson_vo();
	vo_russian anim_single( vo_russian, "remain_calm" );
	
	delete_lab_colors = GetEntArray("lab_reznov_color_chain", "script_noteworthy");
	for(i = 0; i < delete_lab_colors.size; i++)
	{
		delete_lab_colors[i] Delete();
	}
	
	//level thread delete_reznov_color_chain_left();
	//level thread delete_reznov_color_chain_right();
}

mason_lab_hudson_vo()
{
	wait(3);
	player = get_players()[0];
	player anim_single( player, "mason_this_is_hudson" );
	playsoundatposition( "evt_num_num_18_d" , (0,0,0) );
}

wait_to_be_clear()
{
	trigger_wait("weaver_at_security_door");
	
	waittill_ai_group_cleared("mason_flash_first_floor");
	
	trigger_use("start_lead_to_steiner");
}

player_stop_sprinting()
{
	player = get_players()[0];
	
	player SetMoveSpeedScale( 0.74 );
	
	while( player IsSprinting() )
	{
		wait(0.03);
	}
	
	player AllowSprint(false);
}

steiners_hallway()
{
	reznov = level.heroes[ "reznov" ];
	anim_struct = getstruct( "anim_struct_steiner_hall", "targetname" );
	hall_door = GetEnt( "steiner_hall_door", "targetname" );
	hall_door_clip = GetEnt( "flash_room_to_hall_door", "targetname" );
	reznov_close_door = GetEnt( "reznov_close_door", "script_noteworthy");
	obj_outside_steiner_door = GetEnt("obj_outside_steiner_door", "script_noteworthy");
	stop_player_from_leaving = GetEnt("stop_player_from_leaving", "targetname");
	
	stop_player_from_leaving MoveTo( stop_player_from_leaving.origin - (0, 0, 500 ), 0.4 );
	reznov_close_door trigger_off();
	obj_outside_steiner_door trigger_off();
	
	model = spawn("script_model",hall_door.origin - (0, 0, 51) );
	model.angles = hall_door.angles + (0, 90, 0 ) ;
	model setmodel("tag_origin_animate");
	model.animname = "door";
	model useanimtree(level.scr_animtree["door"]);
	anim_struct anim_first_frame( model, "lead_to_steiner_door" );
	//hall_door linkto(model,"origin_animate_jnt");	
	
	flag_set( "mason_doors_setup_done" );
	
	level thread wait_to_be_clear();
	
	trigger_wait( "start_lead_to_steiner" );
	
	get_reznov_into_tunnel();
	
	anim_struct anim_reach_aligned( reznov, "to_steiner_intro" );
	reznov_close_door trigger_on();
	
	reznov LookAtEntity( get_players()[0] );
	anim_struct anim_single_aligned( reznov, "to_steiner_intro" );
	anim_struct thread anim_loop_aligned( reznov, "to_steiner_intro_idle", undefined, "steiner_hall_walk" );
	
	trigger_wait( "player_in_hall" );
	//level thread player_stop_sprinting();
	stop_player_from_leaving MoveTo( stop_player_from_leaving.origin + (0, 0, 500 ), 0.4 );
	obj_outside_steiner_door trigger_on();
	reznov LookAtEntity();
	reznov notify( "steiner_hall_walk" );
	
	//reznov thread anim_single( reznov, "lets_end_this" );	
	
	//recordEnt(hall_door);

	hall_door linkto(model,"origin_animate_jnt");	
	anim_struct thread anim_single_aligned( model, "lead_to_steiner_door" );
	
	//reznov_close_door trigger_on();
	level notify("reznov_closed_the_door");
	
	anim_struct anim_single_aligned( reznov, "to_steiner_walk" );
	hall_door_clip DisconnectPaths();
	
	enemies_left_on_deck = get_ai_array("lab_mason_enemy_deck", "script_noteworthy");
	for(i = 0; i < enemies_left_on_deck.size; i++)
	{
		if( IsDefined( enemies_left_on_deck[i] ) )
		{
			//MagicBullet("ak74u_sp", reznov.origin, enemies_left_on_deck[i].origin);
			enemies_left_on_deck[i] DoDamage(enemies_left_on_deck[i].health * 2, reznov.origin);
		}
	}
	
	anim_struct thread anim_loop_aligned( reznov, "to_steiner_idle", undefined, "starting_steiners_office" );
	reznov LookAtEntity( get_players()[0] );
	
	//level waittill( "starting_confront_steiner" );
	flag_wait( "confront_steiner_1" );
	reznov LookAtEntity();
	anim_struct notify( "starting_steiners_office" );
	hall_door_clip DisconnectPaths();
	
	wait(18);
	
	reznov gun_remove();
	reznov gun_switchto( "makarov_sp", "right" );
}

//------------------------------------
// Play VO off of triggers
confront_steiner()
{
	//TUEY sets a snapshot to remove an unwanted helicopter sound from playing in steiners office.
	level clientNotify ("in_base");

	player = get_players()[0];
	reznov = level.heroes["reznov"];
	weaver = level.heroes["weaver"];
	steiner_door = GetEnt( "steiner_office_door", "targetname" );	
	open_door_trigger = GetEnt("open_steiners_door", "targetname" );
	anim_struct = getstruct( "mason_at_steiner", "targetname" );
	//obj_open_steiner_door = GetEnt("obj_open_steiner_door", "script_noteworthy");
	
	fusebox = GetEnt("fusebox2", "targetname");
	//level.fusebox_angles = fusebox.angles;
	fusemodel = spawn("script_model",fusebox.origin);
	fusemodel setmodel("tag_origin_animate");
	fusemodel.angles = fusebox.angles;
	fusemodel.animname = "fuse";
	fusemodel UseAnimTree( level.scr_animtree["fuse"] );
	fusebox linkto(fusemodel,"origin_animate_jnt");
	
	chair_struct = getstruct("steiner_chair", "targetname");
	level.mason_lab_chair = Spawn("script_model", chair_struct.origin);
	level.mason_lab_chair.angles = chair_struct.angles;
	level.mason_lab_chair SetModel("p_rus_computer_terminal_chair_blood");
	level.mason_lab_chair HidePart("tag_blood");

	//chair = GetEnt("steiner_chair", "targetname");
	//level.chair_angles = chair.angles;
	//chair HidePart("tag_blood");
	
	chairmodel = spawn("script_model", level.mason_lab_chair.origin);
	chairmodel setmodel("tag_origin_animate");
	chairmodel.angles = level.mason_lab_chair.angles;
	chairmodel.animname = "chair";
	chairmodel UseAnimTree( level.scr_animtree["chair"] );
	level.mason_lab_chair linkto(chairmodel,"origin_animate_jnt");
	
	floor_blood = GetEnt("steiner_floor_blood", "targetname");
	floor_blood Hide();
	
	open_door_trigger trigger_off();
	
	model = spawn("script_model", steiner_door.origin - (0, 0, 51) );
	model.angles = steiner_door.angles - (0, 90, 0 ) ;
	model setmodel("tag_origin_animate");
	model.animname = "door";
	model useanimtree(level.scr_animtree["door"]);

	level waittill("reznov_closed_the_door");
	
	//TUEY STEINER HALL
	setmusicstate ("STEINER_HALL");
	//Snapshot Fix
	level clientNotify ("in_base");
	
	open_door_trigger UseTriggerRequireLookAt();
	open_door_trigger SetHintString( &"REBIRTH_OPEN_STEINER_DOOR" );
	//level thread player_look_at_door();
	open_door_trigger trigger_on();
	
	trigger_wait( "open_steiners_door" );
	
	trigger_use("obj_open_steiner_door", "script_noteworthy");
	
	player.player_body = spawn_anim_model( "player_body", player.origin, player.angles );	
	player.player_body Hide();
	
	anim_struct anim_first_frame( player.player_body, "confront_steiner" );
	
	steiner_door linkto(model, "origin_animate_jnt");		
	
	player DisableWeapons();
	wait(0.5);

	player StartCameraTween( 0.2 );
	player PlayerLinktoAbsolute( player.player_body, "tag_player" ); // , 1, 0, 0, 0, 0, true );		
	player.player_body Show();
	
	//flag_set( "confront_steiner_1" );
	
	//reznov anim_stopanimscripted();
	
	player SetClientDvar("cg_drawFriendlyNames", 0);
	
	//TUEY set music to STEINER_LAB
	level thread maps\_audio::switch_music_wait("STEINER_LAB", 0.5);
	
//	level thread maps\_audio::switch_music_wait("REZNOV_SPEAKS", 15);
	
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	

	steiner = undefined;
	
	while(!isdefined(steiner))
	{	
		wait(0.05); // Trying to fix what looks like a timing issue between steiener getting created - and us getting him here.
		steiner = get_ai( "mason_steiner", "script_noteworthy" );
	}
	
	steiner.animname = "steiner";
	steiner gun_remove();
	// steiner SetModel( "c_ger_steiner_rebirth_fb" );
	
	radio_origin = steiner GetTagOrigin( "tag_weapon_left" );
	level.radio = spawn_anim_model("rebirth_radio", radio_origin);
	level.radio.angles = steiner GetTagAngles( "tag_weapon_left" );
	level.radio LinkTo( steiner, "tag_weapon_left" );
	
	hudson = get_ai( "mason_hudson", "script_noteworthy" );
	hudson Detach(hudson.hatModel);
	hudson.animname = "hudson";
	
	steiner_door_use_trig = GetEnt("open_steiners_door", "targetname");
	steiner_door_use_trig trigger_off();
	
	//level notify( "starting_confront_steiner" );
	//flag_set( "confront_steiner_1" );

	// give reznov the appropriate gun
	//reznov thread replace_gun_with_pistol();
	//structarray_remove( reznov.weaponinfo, "ak74u_sp" );
	
	//player.player_body = spawn_anim_model( "player_body", player.origin, player.angles );	
	//player.player_body Hide();

	anim_ents = [];
	anim_ents[ anim_ents.size ] = steiner;
	anim_ents[ anim_ents.size ] = reznov;
	anim_ents[ anim_ents.size ] = hudson;
	anim_ents[ anim_ents.size ] = weaver;
	anim_ents[ anim_ents.size ] = fusemodel;
	anim_ents[ anim_ents.size ] = chairmodel;
	anim_ents[ anim_ents.size ] = player.player_body;	
	
	//anim_struct = getstruct( "mason_at_steiner", "targetname" );
	/*
	anim_struct anim_first_frame( player.player_body, "confront_steiner" );
	
	steiner_door linkto(model, "origin_animate_jnt");		
	
	player DisableWeapons();
	wait(0.5);
	
	anim_struct anim_first_frame( player.player_body, "confront_steiner" );
	player StartCameraTween( 0.2 );
	player PlayerLinktoAbsolute( player.player_body, "tag_player" ); // , 1, 0, 0, 0, 0, true );		
	player.player_body Show();
	*/
	
	flag_set( "confront_steiner_1" );
	
	level thread lab_clean_up();
	level thread movie_wait(player.player_body);
	level thread adjusting_dof_in_steiner_office();
	
	reznov gun_remove();
	reznov gun_switchto( "makarov_sp", "right" );
	reznov anim_stopanimscripted();
	
	anim_struct thread anim_single_aligned( model, "confront_steiner_door" );
	anim_struct anim_single_aligned( anim_ents, "confront_steiner" );
	
	stop_exploder( 490 );
}

adjusting_dof_in_steiner_office()
{
	//maps\createart\rebirth_art::dof_steiner_office_1();
	
	//wait(18.0);
	//IPrintLnBold("NEXT DOF");
	
	//maps\createart\rebirth_art::dof_steiner_office_2();
	
	//wait(19.0);
	
	maps\createart\rebirth_art::dof_steiner_office();
}

replace_gun_with_pistol()
{
	self gun_switchto( "makarov_sp", "right" );
}

confront_steiner_slam( guy )
{
	exploder(380);
}

confront_steiner_spit( guy )
{
	wait(0.10);
	//PlayFXOnTag(level._effect["blood_spit"], guy, "j_lip_top_ri");
	if( is_mature() )
	{
		PlayFXOnTag(level._effect["blood_spit"], guy, "j_jaw");
	}
}

confront_steiner_punch( guy )
{
	wait(0.14);
	//PlayFXOnTag(level._effect["blood_spit"], guy, "j_lip_top_ri");
	if( is_mature() )
	{
		PlayFXOnTag(level._effect["blood_punch"], guy, "j_jaw");
	}
}


//------------------------------------
// triggered by notetrack, fade out of this section
confront_steiner_fade_out( guy )
{
	//thread wait_for_movie_to_be_done();
	thread white_overlay();
	
	player = get_players()[0];
	player FreezeControls( true );
	player SetClientDVAR( "compass", "0" );
	player SetClientDVAR( "hud_showstance", "0" );
	player SetClientDVAR( "actionslotshide" , "1" );
	player SetClientDvar( "ammoCounterHide", "1" );
	player SetClientDvar("cg_drawFriendlyNames", 1);
	//player AllowSprint(true);
	//player SetMoveSpeedScale( 1 );
	
	stop_exploder(380);
	stop_exploder(230);
	clientNotify ("mason_int");
	//movie_time();
	
	//SetSavedDvar("r_streamFreezeState",1);
	
	wait(0.35);
	
	maps\createart\rebirth_art::dof_reset();
	
	level notify("start_flashback_movie");
	
	level waittill("flashback_movie_done");

	SetSavedDvar("r_streamFreezeState",0);

	flag_set("movie_done");
	flag_set( "event_mason_lab_done" );
	
	
	player.animname = "hudson";
	
	//wait(3);
	//get_players()[0] Unlink();
	//player.player_body Delete();
	//player EnableWeapons();
}

movie_wait(player_body)
{
	wait_time = GetAnimLength(level.scr_anim[ "steiner" ][ "confront_steiner" ]);
	
	player_body thread hide_player_body(wait_time);
	
	//wait(wait_time - 6);
	start_movie_scene();
	add_scene_line(&"rebirth_vox_reb1_s01_701A_maso", .1, 6);		//I swear to God, that's how Steiner died. Reznov killed him right in front of me!
	add_scene_line(&"rebirth_vox_reb1_s01_702A_inte", 6.5, 3);		//You're lying Mason. You killed Steiner. We know you did.
	add_scene_line(&"rebirth_vox_reb1_s01_703A_maso", 11, 5);		//Reznov got exactly what he wanted. Revenge.
	add_scene_line(&"rebirth_vox_reb1_s01_704A_inte", 16, 6);		//We saw the report Mason. Viktor Reznov did not kill Friedrich Steiner. Hudson saw what happened.
	level thread play_movie( "mid_rebirth_2", false, false, "start_flashback_movie", false, "flashback_movie_done", 1 );
	level.rebirth_movie = true;
	
	wait(wait_time - 3); //-- GLocke: just gave it a little extra time since this is threaded
	
	SetSavedDvar("r_streamFreezeState",1);
}

hide_player_body(wait_time)
{
	wait( wait_time / 2 );;
	
	self Hide();
	
	flag_wait( "event_mason_lab_done" );
	
	self Show();
}

movie_time()
{
	player = get_players()[0];
	
	//wait(10.0);
	
	level notify("start_flashback_movie");
	SetSavedDvar("r_streamFreezeState",1);
	
	vo_mason = Spawn("script_model", player.origin);
	vo_mason SetModel("tag_origin");
	vo_mason.animname = "mason_flashback";
		
	vo_interrogator = Spawn("script_model", player.origin);
	vo_interrogator SetModel("tag_origin");
	vo_interrogator.animname = "interrogator_flashback";
	
	wait(0.5);
	
	/*
	vo_mason anim_single( vo_mason, "i_swear" );
	vo_interrogator anim_single( vo_interrogator, "you_killed_steiner_a" );
	vo_mason anim_single( vo_mason, "reznov_got_revenge" );
	vo_interrogator anim_single( vo_interrogator, "hudson_filed_his_report_a" );
	*/
	
	vo_mason Delete();
	vo_interrogator Delete();
}

wait_for_movie_to_be_done()
{
	level waittill("flashback_movie_done");
	
	flag_set("movie_done");
	SetSavedDvar("r_streamFreezeState",0);
}

white_overlay()
{
	level.black = maps\rebirth_btr_rail::create_overlay_element( "white", 0 );	
	//level.black fadeovertime( 3 );
	//level.black.alpha = 0;
	
	flag_wait("movie_done");
	
	level.black = maps\rebirth_btr_rail::create_overlay_element( "white", 0 );	
	level.black fadeovertime( 0.01 );
	level.black.alpha = 1;
}

/*------------------------------------------------------------------------------------------------------------
																								Critters
------------------------------------------------------------------------------------------------------------*/

//------------------------------------
// Animate the pigs in the pens
#using_animtree( "critter" );
lab_pigs()
{
	//pigs = GetEntArray( "piggy", "script_noteworthy" );
	pigs_struct = getstructarray("pigs_struct", "targetname");
	pigs = [];
	
	//anim_i = 1;
	for( i = 0; i < pigs_struct.size; i++) 
	{
		pigs[i] = Spawn("script_model", pigs_struct[i].origin);
		pigs[i].angles = pigs_struct[i].angles;
		pigs[i] SetModel("viet_pig");
		pigs[i].animname = "pig";
		pigs[i] UseAnimTree( #animtree );
		//pigs[i] thread anim_loop( pigs[i], "panic_pig_idle_" + anim_i );
		pigs[i].dead = false;
		pigs[i] thread pig_random_animations();
		
		pigs[i] SetCanDamage( true ); 
		pigs[i].health = 99999;
		pigs[i] thread pig_wait_to_be_shot();
		//SOUND - Shawn J ( Collin actually came up with this elegant little function)
		pigs[i] thread pig_sounds();		
		
		/*
		anim_i++;
		if( anim_i >= 4 )
		{
			anim_i = 1;
		}
		*/
	}
	
	hoist_pig_struct = getstruct("hoist_pig_struct", "targetname");
	hoist_pig_struct_model = Spawn("script_model", hoist_pig_struct.origin + (0, 0, 22));
	hoist_pig_struct_model.angles = hoist_pig_struct.angles;
	hoist_pig_struct_model SetModel( "tag_origin" );

	hoist_piggy = Spawn( "script_model", hoist_pig_struct.origin );
	hoist_piggy.angles = hoist_pig_struct.angles;
	//hoist_piggy.angles = (0, 30, 0);
	hoist_piggy SetModel( "viet_pig" );
	hoist_piggy LinkTo(hoist_pig_struct_model);
	hoist_piggy.animname = "pig";
	hoist_piggy UseAnimTree( #animtree );
	
	hoist_pig_struct_model thread anim_loop( hoist_piggy, "pig_hoist_squirm", "stop_squirming" );
	
	hoist_piggy SetCanDamage( true );
	hoist_piggy.health = 99999;
	hoist_piggy.dead = false;
	
	hoist_piggy thread pig_sounds();
	
	hoist_piggy waittill ( "damage", damage, attacker, direction_vec, point);
	
	hoist_piggy notify( "stop_squirming" );
	hoist_piggy.dead = true;
	hoist_pig_struct_model anim_single( hoist_piggy, "pig_hoist_death" );
	hoist_pig_struct_model anim_loop( hoist_piggy, "pig_hoist_deathpose" );
}

pig_random_animations()
{
	while(!self.dead)
	{
		anim_i = RandomIntRange( 1, 4 );
		self anim_single(self, "panic_pig_idle_" + anim_i );
		wait(0.01);
	}
}

pig_wait_to_be_shot()
{
	self waittill ( "damage", damage, attacker, direction_vec, point);
	
	self.dead = true;
	
	impact_dir = point - self.origin;
	impact_dir_normal = VectorNormalize(impact_dir);
	piggy_forward_vec = AnglesToForward( self.angles );
	piggy_right_vec = AnglesToRight( self.angles );
	
	dot_with_forward = VectorDot( piggy_forward_vec, impact_dir_normal );
	dot_with_right = VectorDot( piggy_right_vec, impact_dir_normal );
	
	impact_orient = "";
	if( abs(dot_with_forward) < 0.4 )
	{
		impact_orient = "mid_";
	}
	else if( dot_with_forward < 0 )
	{
		impact_orient = "rear_";
	}
	else
	{
		impact_orient = "front_";
	}
	
	if( dot_with_right < 0 )
	{
		impact_orient = impact_orient + "left";
	}
	else
	{
		impact_orient = impact_orient + "right";
	}
	
	switch( impact_orient )
	{
		case "mid_left":
			//IPrintLnBold(impact_orient);
			//pigs[i] thread anim_loop( pigs[i], "panic_pig_idle_" + anim_i );
			self anim_single(self, "pig_death_from_left");
		break;
		
		case "mid_right":
			//IPrintLnBold(impact_orient);
			self anim_single(self, "pig_death_from_right");
		break;
		
		case "front_left":
			//IPrintLnBold(impact_orient);
			self anim_single(self, "pig_death_from_front");
		break;
		
		case "front_right":
			//IPrintLnBold(impact_orient);
			self anim_single(self, "pig_death_from_front");
		break;
		
		case "rear_left":
			//IPrintLnBold(impact_orient);
			self anim_single(self, "pig_death_from_back");
		break;
		
		case "rear_right":
			//IPrintLnBold(impact_orient);
			self anim_single(self, "pig_death_from_back");
		break;
		
		default:
		break;
	}
}

lab_monkey_manager()
{
	level endon( "event_mason_lab_done" );
	
	level.monkey_tracker = 0;
	
	monkey_portals = GetEntArray( "monkey_trig", "script_noteworthy" );
	array_thread( monkey_portals, ::monkey_portal_think );
	
//	while(true)
//	{
//		IPrintLn( level.monkey_tracker );
//		wait(1);
//	}
}

monkey_portal_think()
{
	//level endon( "event_mason_lab_done" );
	player = get_players()[0];
	monkeys = getstructarray( self.target, "targetname" );
	
	while( true )
	{
		self waittill( "trigger" );
		
		array_thread( monkeys, ::lab_monkeys_show );
		
		while( player IsTouching( self ) )
		{
			wait( 1 );
		}
		
		array_thread( monkeys, ::lab_monkeys_hide );
	}
}

monkey_see()
{
	level endon( "event_mason_lab_done" );
	
	level.monkey_tracker = 0;
	monkeys_are_defined = false;
	
	monkeys = getstructarray( "lab_monkey", "script_noteworthy");
	array_thread( monkeys, ::monkey_do );
}

monkey_do()
{
		level endon( "event_mason_lab_done" );
		
		player = get_players()[0];
		already_showing = false;
		
		while(true)
		{
			if( self player_can_see_me( player ) && already_showing == false )
			{
				self thread lab_monkeys_show();
				already_showing = true;
			}
			else if( !(self player_can_see_me( player )) && already_showing == true )
			{
				self thread lab_monkeys_hide();
				already_showing = false;
			}
			
			wait(1.0);
		}
}

#using_animtree( "critter" );
/*
lab_monkeys_show_old()
{
	self endon( "monkey_stop" );
	
	if( !IsDefined( self.monkeydead ) )
	{
		level.monkey_tracker++;
		anim_i = RandomIntRange( 1, 4 );
		
		self.monkey = Spawn( "script_model", self.origin );
		self.monkey.angles = self.angles;
		self.monkey SetModel( "anim_monkey" );
		self.monkey.animname = "monkey";
		self.monkey UseAnimTree( #animtree );
		self.monkey thread anim_loop( self.monkey, "freaked_" + anim_i, "monkey_stop" );
		self.monkey SetAnimTime( level.scr_anim[ "monkey" ][ "freaked_" + anim_i][0], RandomFloat( 0.99 ) );
		
		self.monkey SetCanDamage( true ); 
		self.monkey.health = 99999;	
		
		self.monkey waittill( "damage", amount, attacker );
		
		self.monkeydead = true;
		player = get_players()[0];
		if( attacker == player )
		{
			player thread achievement_record_monkey_death();
		}
		
		self.monkey notify( "monkey_stop" );
		self.monkey anim_single( self.monkey, "shot_death" );
		
		// self.monkey SetAnim( %a_monkey_shot_death, 1, 0.2, 1 );		
	}
}
*/

lab_monkeys_show()
{
	self endon( "monkey_stop" );
	
	level.monkey_tracker++;
	
	if( !IsDefined( self.monkey_dead ) || self.monkey_dead == false)
	{
		//IPrintLnBold( "create monkey" );
		
		anim_i = RandomIntRange( 1, 4 );
		//anim_i = 3;
		
		self.monkey = Spawn( "script_model", self.origin );
		self.monkey.angles = self.angles;
		self.monkey SetModel( "anim_monkey" );
		self.monkey.animname = "monkey";
		self.monkey UseAnimTree( #animtree );
		self.monkey_anim_spot = Spawn( "script_model", self.origin );
		self.monkey_anim_spot.angles = self.angles;
		self.monkey_anim_spot SetModel( "tag_origin" );
		self.monkey_anim_spot thread anim_loop_aligned( self.monkey, "freaked_" + anim_i, "tag_origin", "monkey_stop" );
		self.monkey SetAnimTime( level.scr_anim[ "monkey" ][ "freaked_" + anim_i][0], RandomFloat( 0.99 ) );
		
		self.monkey SetCanDamage( true ); 
		self.monkey.health = 99999;
			
		self thread wait_to_be_shot();
		
		if(self.targetname == "gas_monkey")
		{
			self thread wait_to_be_gas();
		}
	}
	else
	{
		//IPrintLnBold( "show monkey" );
		
		self.monkey Show();
	}
}

wait_to_be_gas()
{	
	//level endon("event_mason_lab_done");
	self.monkey endon( "delete_monkey" );
	
	level waittill("kill_monkeys_with_gas");
	
	self.monkey_dead = false;
	if( !self.monkey_dead )
	{
		self.monkey_dead = true;
		self.monkey SetModel( "anim_monkey_gas" );
		if( is_mature() )
		{
			self.monkey SetClientFlag(0);
		}
		
		wait_time = RandomIntRange(1, 3);
		wait(wait_time);
		
		//anim_i = RandomIntRange(1, 3);
		//self.monkey anim_single(self.monkey, "gas_death_" + anim_i);
		
		if( level.gas_by_player == true )
		{
			player = get_players()[0];
			player	achievement_i_hate_monkeys();
		}
		
		self.monkey_anim_spot anim_single_aligned(self.monkey, "gas_death_1");
	}
}

wait_to_be_shot()
{	
	//level endon("event_mason_lab_done");
	self.monkey endon( "delete_monkey" );
	
	self.monkey_dead = false;
	while( !self.monkey_dead )
	{
		//self.monkey waittill( "damage", amount, attacker );
		self.monkey waittill( "damage", amount, attacker, direction_vec, point, type );

		if(type != "MOD_MELEE")
		{
			self.monkey_dead = true;
			player = get_players()[0];
	
			if(attacker == player)
			{
				player	achievement_i_hate_monkeys();
			}
	
			//anim_i = RandomIntRange(1, 3);
			//self.monkey anim_single(self.monkey, "shot_death_" + anim_i);
			self.monkey_anim_spot anim_single_aligned(self.monkey, "shot_death_1");
		}
	}
}

lab_monkeys_hide()
{
	level.monkey_tracker--;
	
	self notify( "monkey_stop" );
	
	if( IsDefined( self.monkey_dead ) && self.monkey_dead == true )
	{
		//if( self.monkey_dead == true )
		//IPrintLnBold( "hide monkey" );
			
		self.monkey Hide();
	}
	else //if( IsDefined( self.monkey ) )
	{
		//IPrintLnBold( "delete monkey" );
		
		self.monkey notify( "delete_monkey" );
		self.monkey Delete();
		self.monkey_anim_spot Delete();
	}
}

/*
lab_monkeys_hide_old()
{
	level.monkey_tracker--;
	
	self notify( "monkey_stop" );
	
	if( IsDefined( self.monkey ) )
	{
		self.monkey Delete();
	}
}
*/

achievement_i_hate_monkeys()
{
	if( !IsDefined( self.rb_monkey_kills ) )
	{
		self.rb_monkey_kills = [];
	}
	
	num_monkeys_to_kill = 7;
	curr_time = GetTime();
	ten_seconds = 10000; // in milliseconds
	self.rb_monkey_kills[ self.rb_monkey_kills.size ] = curr_time;
	
	if( self.rb_monkey_kills.size >= num_monkeys_to_kill )
	{
		kills_to_achieve = 0;
		ten_monkeys_before = self.rb_monkey_kills.size - num_monkeys_to_kill;
		ten_seconds_before = curr_time - ten_seconds;
		
		for( i = ten_monkeys_before; i < self.rb_monkey_kills.size; i++)
		{
			if( self.rb_monkey_kills[i] >= ten_seconds_before )
			{
				kills_to_achieve++;
			}
		}
		
		if(kills_to_achieve >= num_monkeys_to_kill)
		{
			self giveachievement_wrapper( "SP_LVL_REBIRTH_MONKEYS" );
		}
	}
}

/*
achievement_record_monkey_death()
{
	self endon( "monkey_achievement_got" ); 
	
	if( !IsDefined( self.rb_monkey_kills ) )
	{
		self.rb_monkey_kills = [];
	}
	
	kill_time = GetTime();
	self.rb_monkey_kills[ self.rb_monkey_kills.size ] = kill_time;
	
	if( self.rb_monkey_kills.size >= 1 )
	{
		kills_in_ten = 0;
		for( i = 0; i < self.rb_monkey_kills.size; i++ )
		{
			if( self.rb_monkey_kills[i] >= kill_time - 10000 )
			{
				kills_in_ten++;
			}
		}
				
		if( kills_in_ten >= 10 )
		{
			self giveachievement_wrapper( "SP_LVL_REBIRTH_MONKEYS" );
			self notify( "monkey_achievement_got" ); 
		}
	}	
}
*/


/*------------------------------------------------------------------------------------------------------------
																								Objectives
------------------------------------------------------------------------------------------------------------*/

//------------------------------------
// Update objectives and objective markers
mason_lab_objectives()
{
	Objective_Add( level.obj_iterator, "current", &"REBIRTH_OBJECTIVE_1", level.heroes["reznov"] );
	maps\rebirth_utility::rb_objective_breadcrumb( level.obj_iterator, "obj_breadcrumb_mason_lab" );
}



/*------------------------------------------------------------------------------------------------------------
																								Spawn Functions
------------------------------------------------------------------------------------------------------------*/

#using_animtree( "generic_human" );
lab_civs_spawnfunc()
{
	self endon( "death" );
	self.team = "axis";
	self.script_forcegoal = true;
	self.noDodgeMove = true;
	self PushPlayer(true);
	maps\rebirth_hudson_lab::corpse_sci_memory_spawnfunc();
	
	self thread civilian_ai_idle_and_react( self, "cower_idle", "cower_react", undefined, self.script_string );
	
	random_wait = RandomIntRange(0, 4);
	
	wait(random_wait);
	
	self notify( self.script_string );

	if( self.script_string == "mason_scientist_front_hallway" )
	{
		node_blocker = GetNode( "node_front_hallway_blocker", "script_noteworthy" );
		node_owner = GetNodeOwner( node_blocker );
		if( IsDefined( node_owner ) )
		{
			alt_path = GetNode( "mason_alt_front_hallway", "targetname" );
			self SetGoalNode( alt_path );
			
			self waittill( "goal" );
		}
	}
	
	if( self.script_string != "mason_scientist_end_hallway" && self.script_string != "mason_scientist_flash_room" )
	{
		choose_path = RandomIntRange(0, 2);
	
		if( choose_path == 0)
		{
				alt_path = GetNode( "mason_alt_path", "targetname" );
				self SetGoalNode( alt_path );
				
				self waittill( "goal" );
		}
	}
	
	choose_path = RandomIntRange(0, 2);
	
	if( choose_path == 0)
	{
		alt_path = GetNode( "mason_alt_path_right", "targetname" );
		self SetGoalNode( alt_path );
	}
	else
	{
		alt_path = GetNode( "mason_alt_path_left", "targetname" );
		self SetGoalNode( alt_path );
	}
	self waittill( "goal" );
	
	if( !self player_can_see_me( get_players()[0] ) )
	{
		self Delete();
	}

	delete_scientists = GetNode( "delete_scientists", "targetname" );
	self SetGoalNode( delete_scientists );
	
	self waittill( "goal" );
	
	self Delete();
}

lab_civ_idle_react_spawnfunc()
{
	self endon( "death" );
	self.team = "axis";
	self.script_forcegoal = true;
	self.noDodgeMove = true;
	self PushPlayer(true);
	self thread civilian_ai_idle_and_react( self, "cower_idle", "cower_react", undefined, self.script_string );
	
	level waittill( self.script_string );
	
	random_wait = RandomIntRange(0, 5);
	
	wait(random_wait);
	
	self notify( self.script_string );
	
	if( self.script_string != "mason_scientist_end_hallway" && self.script_string != "mason_scientist_flash_room" )
	{
		choose_path = RandomIntRange(0, 2);
	
		if( choose_path == 0)
		{
				alt_path = GetNode( "mason_alt_path", "targetname" );
				self SetGoalNode( alt_path );
				
				self waittill( "goal" );
		}
	}
	
	choose_path = RandomIntRange(0, 2);
	
	if( choose_path == 0)
	{
		alt_path = GetNode( "mason_alt_path_right", "targetname" );
		self SetGoalNode( alt_path );
	}
	else
	{
		alt_path = GetNode( "mason_alt_path_left", "targetname" );
		self SetGoalNode( alt_path );
	}
	self waittill( "goal" );
	
	if( !self player_can_see_me( get_players()[0] ) )
	{
		self Delete();
	}
		
	delete_scientists = GetNode( "delete_scientists", "targetname" );
	self SetGoalNode( delete_scientists );
	
	self waittill( "goal" );
	
	self Delete();
}

lab_observ_civs_spawnfunc()
{
	self endon( "death" );
	self.team = "axis";
	self.script_forcegoal = true;
	self.noDodgeMove = true;
	self PushPlayer(true);
	
	self waittill("goal");
	
	self Delete();
}

mason_lab_flash_guy_spawnfunc()
{
	self endon("death");
	
	self thread make_flash_guy_target_player();
	
	trigger_wait( "get_flash_guy_out_trig" );
	
	self notify("stop_targeting_player");

	player = get_players()[0];
	if( IsDefined(self) )
	{
		self thread maps\rebirth_hudson_lab::hunt_down_player();
		self shoot_at_target( player, undefined, 2 );
	}
}

mason_lab_steiner_spawnfunc()
{
	self endon("death");
	
	self.animname = "crate_kill_worker";
	self gun_remove();
	
	anim_struct = getstruct( "steiner_idle", "targetname" );
	anim_struct anim_loop( self, "container_worker_idle" );
}

lab_spets_spawnfunc()
{
	self enable_cqbwalk();
}

hatchet_achievement_spawnfunc()
{
	level endon( "hatchet_achieve_given" );
	self waittill( "death", attacker, damagetype, killweapon );
	
	if( IsDefined( killweapon ) && killweapon == "hatchet_sp" && !flag( "hatchet_achieve_given" ) )
	{
		level.num_hatchet_kills++;
		// IPrintLnBold( "hatchet kill! " + level.num_hatchet_kills );
		
		if( level.num_hatchet_kills >= 5 )
		{
			get_players()[0] giveachievement_wrapper( "SP_LVL_REBIRTH_MONKEYS" );
			flag_set( "hatchet_achieve_given" );
		}
	}
}

lab_difficulty_balance_spawnfunc()
{	
	if( GetDifficulty() == "fu" )
	{
		self.script_accuracy = .9;
	}
}

pig_sounds()
{
	while (self.dead == false)
	{
		playsoundatposition ("amb_piggy", self.origin);
		wait(RandomIntRange(2,4));
	}
	//playsoundatposition ("amb_piggy", self.origin);
}
