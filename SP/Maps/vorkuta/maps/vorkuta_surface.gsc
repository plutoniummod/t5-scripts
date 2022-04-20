
#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_music;
#include maps\vorkuta_util;




surface_main()
{
	
	//tower
	level thread tower();
	
	//slingshot
	level thread slingshot();
		
	//courtyard
	level thread courtyard();
	
	flag_wait( "courtyard_done" );
}

tower()
{
	level thread tower_gate();
	level thread tower_destroy();
	level thread omaha_drone_vox();
	level thread tower_vo();
	level thread digger_rotate();

	level thread tower_custom_death_message();

	tower_cart();
}

tower_custom_death_message()
{
	level endon( "tower_done" );

	player = get_players()[0];
	player waittill( "death", attacker, cause, weaponName ); 

	if( RandomInt( 100 ) > 50 )
	{
		SetDvar( "ui_deadquote", &"VORKUTA_OMAHA_FAIL_1" ); 
	}
	else
	{
		SetDvar( "ui_deadquote", &"VORKUTA_OMAHA_FAIL_2" ); 
	}
	return;
}

//spins the digger wheel in the slingshot area, viewable for a majority of the map
digger_rotate()
{
	digger_wheel = GetEnt("digger_wheel","targetname");

	while(1)
	{
		digger_wheel RotatePitch(360, 20);
		digger_wheel waittill("rotatedone");
	}
}

tower_cart()
{
	level thread tower_mg();

	flag_wait("flag_bridge_done");
		
	//temp
	level.outdoor = true;
		
	level thread tower_cart_left();
	level thread tower_cart_events();
	
	//reznov and sergei to cart
	cart_right = GetEnt( "cart_right", "targetname" );
	cart_col = GetEnt("cart_col_right","targetname");
	cart_col LinkTo( cart_right);
	cart_right_pile = GetEnt("cart_right_pile","targetname");
	cart_right_pile LinkTo( cart_right);
	cart_top = GetEnt("cart_top_right","targetname");
	cart_top LinkTo(cart_right);

	waittill_multiple_ents( level.reznov, "in_position", level.sergei, "in_position" );

	//wait for player to be in range
	trigger_wait("start_cart");
	
	//Starting the PA
	clientNotify ("spa");
	
	
	autosave_by_name( "vorkuta_at_cart" );

	//stop initial drone waves
	drone_trigger = GetEnt("drone_omaha_initial_waves","script_noteworthy");
	drone_trigger notify("stop_drone_loop");
	level thread remove_drone_structs(drone_trigger);

	//kill player if he strays
	level thread tower_mg_kill();

	//turn off FX in inclinator
	stop_exploder(1100);

	actors = array(level.reznov, level.sergei);
	cart_right anim_single_aligned( actors, "right_cart_trans_push" );
	cart_right thread anim_loop_aligned( actors, "right_cart_push"); 

	flag_set("flag_cart_start");
		
	//TUEY set music state to MINE_CART_PUSH
	setmusicstate ("MINE_CART_PUSH");

	//start left side drones
	drone_trigger = GetEnt("drone_omaha_left_side", "script_noteworthy");
	drone_trigger activate_trigger();
	level notify( "start_omaha_drones" );

	level thread tower_drone_think();

	//start actual prisoners spawning from tunnel
	array_thread( GetEntArray("omaha_prisoner","script_noteworthy"), ::add_spawn_function, ::tower_prisoner_think );
	trigger_use("sm_omaha_prisoners");

	//C. Ayers - Adding in Cart Movement Audio
	cart_right thread play_cart_movement_audio();
	level.sergei PlayLoopSound( "vox_sergei_minecart_push_loop", 1 );
	
	//temp till anim
	start_pt = getstruct( "cart_right_start", "targetname" );
	end_pt = getstruct( start_pt.target, "targetname" );
	cart_right moveto( end_pt.origin, 66, 1, 1 );
	cart_right thread tower_cart_connect_paths(cart_col);
	cart_right waittill( "movedone" );

	flag_set("flag_cart_end");
	
	level.sergei StopLoopSound( 1 );
	
	autosave_by_name( "vorkuta_tower_destroyed" );
	
}

tower_cart_connect_paths(cart_col)
{
	self endon("movedone");

	while(1)
	{
		cart_col ConnectPaths();
		cart_col DisconnectPaths();
		wait(1);
	}
}

tower_prisoner_think()
{
	self endon( "death" );

	self thread maps\_prisoners::make_prisoner();
	self.goalradius = 32;
	self.ignoreme = false;
	self.noDodgeMove = false; 

	goal = GetNode(self.script_string, "targetname" );
	self SetGoalPos( goal.origin );	

	cart_right = GetEnt( "cart_right", "targetname" );

	//wait( RandomFloatRange(8.0, 16.0) );
	while(self.origin[1] < cart_right.origin[1] + RandomInt(100) )
	{
		wait(0.05);
	}

	self bloody_death();
}

tower_drone_think()
{
	level endon("tower_done");

	while(1)
	{
		drones = GetEntArray("drone","targetname");
		array_thread(drones, ::tower_drone_think_internal);
		wait(1);
	}
}

tower_drone_think_internal()
{
	self endon("death");

	cart_right = GetEnt( "cart_right", "targetname" );

	while(self.origin[1] < cart_right.origin[1] + RandomInt(100) )
	{
		wait(0.05);
	}

	self bloody_death();
}

//handles guard in tower and mg etc.
tower_cart_anim( actor )
{
	self anim_reach_aligned( actor, "right_cart_enter" );
	actor LinkTo(self);
	self anim_single_aligned( actor, "right_cart_enter" );
	self thread anim_loop_aligned( actor, "right_cart_idle1"); 
		
	//notify the cart that actor is ready to start pushing
	actor notify("in_position");

	flag_wait("flag_cart_end");
	self anim_single_aligned( actor, "right_cart_trans_idle" );
	self thread anim_loop_aligned( actor, "right_cart_idle2" ); 

	flag_wait( "tower_done" );

	if(actor == level.sergei)
	{
		wait(2);
	}
	self anim_single_aligned( actor, "right_cart_exit" );
	actor notify("left_cart");
		
}

//handles effects nr player and killing player if he strays
tower_mg()
{
	level.tower_guards = simple_spawn( "MG_tower_guards", ::tower_mg_ai);
	
	player = getplayers()[0];

	tower_mg = GetEnt( "tower_mg", "targetname" );
	sound_ent = Spawn( "script_origin", tower_mg.origin );
	sound_ent thread delete_sound_ent();

	//take over onto the player
	flag_wait("flag_bridge_done");

	cooldown = 0;

	while(IsDefined(tower_mg))
	{
		//fire at players feet
		pos[0] = player.origin + (-72,32,0 );
		pos[1] = player.origin + ( 72,48,0 );
		pos[2] = player.origin + ( -72,112,0 );
		pos[3] = player.origin + ( -72,96,0 );
		pos[4] = player.origin + ( 72,96,0 );
		pos[5] = player.origin + ( -72,72,0 );
		pos[6] = player.origin + ( -72,64,0 );
		pos[7] = player.origin + ( -72,48,0 );
		
		index = RandomInt(pos.size);

		MagicBullet( "rus_aa_bipod_stand", tower_mg GetTagOrigin("tag_flash"), pos[index] );
		PlayFXOnTag( level._effect["omaha_muzzle_flash"], tower_mg, "tag_flash");

		if(IsDefined(sound_ent))
		{	
			sound_ent PlayLoopSound( "wpn_50cal_fire_loop_npc" );
		}

		wait(0.4);	

		//give the gun a break every once in a while for visibility
		if(cooldown > 40)
		{
			cooldown = 0;
			wait(RandomFloatRange(0.5, 1.0));
		}
		else
		{
			cooldown++;
		}		
	}
}

tower_mg_ai()
{
	self magic_bullet_shield();
	self disable_pain();
	self disable_react();
}

//kills player if he strays to far
tower_mg_kill()
{
	player = getplayers()[0];
	dist_kill = 350 * 350;
	dist_warn = 250 * 250;

	tower_mg = GetEnt( "tower_mg", "targetname" );
	
	//while the tower hasn't been destroyed
	while( !flag("tower_done") )
	{
		dist = Distance2Dsquared( level.reznov.origin, player.origin );

		if( dist > dist_kill ) 
 		{
			player DoDamage( player.health + 500, tower_mg.origin );
		}
		else if( dist > dist_warn )
		{
			//TO DO: play warning audio
			player DoDamage( 20, tower_mg.origin );
			wait( RandomFloatRange(0.3, 0.5) );
		}
		wait(0.05);
	}
}	

tower_cart_events()
{
	//remove canister collision
	canister_col = GetEnt("canister_collision","targetname");
	canister_col trigger_off();
	canister_col ConnectPaths();

	tower_cart_trigger_wait("tower_chase");

	level thread tower_chase();

	tower_cart_trigger_wait("tower_window_trig");
	level thread tower_window();

	tower_cart_trigger_wait("tower_debris_trig");
	level thread tower_debris();

	flag_wait("shoot_tower");

	level notify( "stop_omaha_drones" );
}

tower_cart_trigger_wait(trigger_name)
{
	trigger = GetEnt(trigger_name, "targetname");

	while(1)
	{
		trigger waittill("trigger", ent);
		if(ent == level.reznov)
		{
			trigger Delete();
			return;
		}
	}
}

tower_cart_left_reach(anim_node)
{
	anim_node anim_reach_aligned(self, "left_cart_enter");
	anim_node anim_single_aligned( self, "left_cart_enter" );
	anim_node thread anim_loop_aligned( self, "left_cart_idle1"); 
	self LinkTo(anim_node);
	self notify("ready");
}

tower_cart_left()
{
	guys = simple_spawn( "cart_left_guy", ::tower_left_cart_think );
	level.cart_guys = guys;

	//left side
	cart_left = GetEnt( "cart_left", "targetname" );
	cart_col = GetEnt("cart_col_left","targetname");
	cart_col LinkTo( cart_left );
	cart_left_pile = GetEnt("cart_left_pile","targetname");
	cart_left_pile LinkTo( cart_left );
		
	//guys pushing cart
	guys[0].animname = "prisoner_1";
	guys[1].animname = "prisoner_2";
	guys[2].animname = "prisoner_3";

	array_thread(guys, ::tower_cart_left_reach, cart_left);
	array_wait(guys, "ready");

	flag_wait("flag_cart_start");
			
	//C. Ayers - Adding in Cart Movement Audio
	cart_left thread play_cart_movement_audio();
	cart_left anim_single_aligned( guys, "left_cart_trans_push" );
	cart_left thread anim_loop_aligned(guys, "left_cart_push"); 
	
	//move cart
	end_pt = getstruct( "cart_left_end", "targetname" );
	cart_left moveto( end_pt.origin, 55, 5, 5 );
	cart_left waittill( "movedone" );
	cart_col DisconnectPaths();

	for( i = 0; i < guys.size; i++ )
	{
		guys[i] UnLink();
	}
	
	cart_left anim_single_aligned( guys, "left_cart_trans_idle" );
		
	spawn_manager_kill("sm_omaha_prisoners");

	//stop left side drones from spawning
	drone_trigger = GetEnt("drone_omaha_left_side", "script_noteworthy");
	drone_trigger notify("stop_drone_loop");
	level thread remove_drone_structs(drone_trigger);
		
	level thread tower_sling_vo();

	//fire the slingshot
	cart_left.slingshot = spawn_anim_model( "slingshot" );
	cart_left thread anim_single_aligned(cart_left.slingshot, "left_cart_sling");
	cart_left anim_single_aligned( guys, "left_cart_sling" );
	
	guys[2] notify("leave_cart");
	wait(0.5);
	guys[1] notify("leave_cart");
	wait(2);
	guys[0] notify("leave_cart");
	
}

tower_sling_vo()
{
	//dialog while slingshot anim sets up
	player = get_players()[0];
	player.animname = "mason";

	anim_single( level.reznov, "omaha_step3" );	
	anim_single( player, "omaha_rain" );
	anim_single( level.reznov, "omaha_see" );
}

tower_left_cart_think()
{
	self thread maps\_prisoners::make_prisoner(); 
	self thread magic_bullet_shield();
	
	self waittill("leave_cart");

	//self SetGoalPos(self.origin);

	//trigger_wait("slingshot_start");

	

	goals = GetNodeArray( "trans_delete" , "targetname" );
	self SetGoalPos( goals[RandomInt(goals.size)].origin );	

	self waittill( "goal" );
	self Delete();
}

tower_fireball_load(guy)
{
	fireball = spawn_a_model ("tag_origin", guy GetTagOrigin("TAG_INHAND"));
	fireball LinkTo(guy, "TAG_INHAND");

	wait(1);
	PlayFXOnTag( level._effect["slingshot_molotov_wicker"], fireball, "tag_origin" );

	flag_wait("tower_done");
	fireball Delete();
}

tower_fireball(guy)
{
	//fire slingshot at tower
	tower_mg = GetEnt( "tower_mg", "targetname" );

	//TUEY Set mine cart end music
	setmusicstate ("FINISHED_MINECART");

	flag_set( "tower_done" );

	fireball = spawn_a_model ("tag_origin", guy GetTagOrigin("TAG_INHAND"));
	PlayFXOnTag( level._effect["slingshot_molotov_wicker"], fireball, "tag_origin" );
	fireball thread fake_physicslaunch( tower_mg.origin, 1000 );

	playsoundatposition( "wpn_ai_slingshot", guy.origin );
	playsoundatposition( "wpn_slingshot_molotov_shot", guy.origin );

	wait(0.2);

	PlayFXOnTag(level._effect["slingshot_projectile"], fireball, "tag_origin");

	wait (1.5);

	playsoundatposition( "wpn_molotov_impact", tower_mg.origin );
	playsoundatposition( "evt_target_explo", tower_mg.origin );
	PlayFX (level._effect["vehicle_explosion"], tower_mg.origin);
	exploder(4);	//glass burst fx

	Earthquake(0.5, 1.0, get_players()[0].origin, 100);
	get_players()[0] PlayRumbleOnEntity("damage_heavy");

	for( i =0; i < level.tower_guards.size; i++ )
	{
		level.tower_guards[i] stop_magic_bullet_shield();
		level.tower_guards[i] thread burn_me();
		level.tower_guards[i] StartRagdoll();
		level.tower_guards[i] Launchragdoll( (0, -50, 100) );
		wait( .25 );
		get_players()[0] PlayRumbleOnEntity("damage_heavy");
	}	
	
	level thread play_fire_sound( tower_mg.origin );

	//cleanup ents
	fireball Delete();

	wait(1);

	tower_mg Delete();
}

//temp - replace by anim
tower_chase()
{
	level.chase_node = GetNode( "chase_node", "targetname" );
	level thread simple_spawn( "chase_guy", :: chase_guy_think );
	wait 1.5;
	level thread simple_spawn( "chase_guard", :: prisoner_guard_think );
		
	anim_single( level.reznov, "omaha_right" );

	//slide open the door
	sliding_door = GetEnt("omaha_rollup_door", "targetname");
	sliding_door MoveZ(-100, 2, 1);
	sliding_door waittill("movedone");
	sliding_door DisconnectPaths();

	trigger_wait( "tower_chase2" );
	
	anim_single( level.reznov, "omaha_left" );
	
	level.chase_node = GetNode( "chase_node2", "targetname" );
	level thread simple_spawn( "chase_guy2", :: chase_guy_think );
	wait 2;
	level thread simple_spawn( "chase_guard2", :: prisoner_guard_think );
}

chase_guy_think()
{
	self thread maps\_prisoners::make_prisoner();
	self SetGoalPos( level.chase_node.origin );
	waittill_notify_or_timeout("goal", RandomFloatRange(1.0, 4.0) );

	self bloody_death();
}

prisoner_guard_think()
{
	self endon( "death" );

	self.health = 75;
	self.script_accuracy = 0.5;
	self AllowedStances("stand");

	player = get_players()[0];
	cart_right = GetEnt( "cart_right", "targetname" );

	while(1)
	{
		//guard is too far behind the player's mine cart so kill them off
		if( (self.origin[1] + 200) < cart_right.origin[1] )
		{
			while(self player_can_see_me( player ))
			{
				wait(0.5);
			}
			self bloody_death();
		}
		else if( flag( "tower_done" ) )
		{
			wait(RandomFloatRange(2.0, 5.0));
			self bloody_death();
		}
	
		wait(0.1);
	}
}

tower_window()
{
	anim_single( level.reznov, "omaha_right");
		
	simple_spawn_single( "window_guard", ::prisoner_guard_think );
	simple_spawn_single( "window_guard", ::prisoner_guard_think );

	trigger = trigger_wait( "window_lookat" );
	trigger Delete();
		
	//break window
	exploder(2); //glass burst fx

	Earthquake(0.4, 1.2, get_players()[0].origin, 100);
	get_players()[0] PlayRumbleOnEntity("damage_heavy");
	
	guy_origins = GetStructArray( "window_guy", "targetname" );
	for( i = 0; i < guy_origins.size; i++ )
	{
		guy = create_guard_model(undefined, guy_origins[i].origin);
		guy StartRagdoll();
		guy	Launchragdoll( (-64, -32, 32) );
		if(i == 0)
		{
			PlayFX (level._effect["vehicle_explosion"], guy.origin);
			guy PlaySound( "exp_omaha_window_explode" );
		}		
	}
}

tower_debris()
{
	//don't explode the barrels if the tower is destroyed
	level endon("tower_done");

	anim_single( level.reznov, "omaha_unite");
	level thread anim_single( level.reznov, "omaha_friends");

	//wait for player to look at
	trigger = trigger_wait("fx_barrel_lookat");
	trigger Delete();

	exp_org = getstruct("omaha_canister_explosion","targetname");
	PlayFX (level._effect["vehicle_explosion"], exp_org.origin);

	level notify("canister_start");
	
	playsoundatposition( "exp_glass_blowout", (-311, 3295, 1362) );
	playsoundatposition( "exp_glass_blowout", (-351, 2999, 1362) );
	exploder(3); //glass burst fx

	Earthquake(0.3, 1.0, get_players()[0].origin, 100);
	get_players()[0] PlayRumbleOnEntity("damage_heavy");
	
	canister_col = GetEnt("canister_collision","targetname");
	canister_col trigger_on();
	canister_col DisconnectPaths();
}

tower_gate()
{
	flag_wait("shoot_tower");

	gate_l = GetEnt( "omaha_gate_left", "targetname" );
	gate_l_clip = GetEnt("omaha_gate_left_clip","targetname");
	gate_l_clip LinkTo(gate_l);

	gate_r = GetEnt( "omaha_gate_right", "targetname" );
	gate_r_clip = GetEnt("omaha_gate_right_clip","targetname");
	gate_r_clip LinkTo(gate_r);

	gate_l RotateYaw(-120, 2);
	gate_r RotateYaw(110, 2.1);

	gate_r waittill("rotatedone");

	gate_r_clip ConnectPaths();
	gate_l_clip ConnectPaths();

	wait(3);

	anim_single( level.reznov, "omaha_left");
}

tower_destroy()
{
	flag_wait( "tower_done" );

	//turn on FX in slingshot building
	exploder(1400);

	//unlink from cart
	level.sergei Unlink();
	level.reznov Unlink();
	
	delayThread(1, ::slingshot_int);
	delayThread(1, ::slingshot_int_sergei);
			
	array_thread( GetEntArray("omaha_after_tower","script_noteworthy"), ::add_spawn_function, ::after_tower_think );

	trigger_infront = GetEnt("omaha_infront_wall","targetname");
	trigger_behind = GetEnt("omaha_behind_wall","targetname");

	trigger_infront thread after_tower_trigger_infront();
	trigger_behind thread after_tower_trigger_behind();

	trigger_wait("slingshot_start");

	trigger_infront Delete();
	trigger_behind Delete();

	spawn_manager_kill("sm_omaha_infront_wall");
	spawn_manager_kill("sm_omaha_behind_wall");	
}

after_tower_trigger_behind()
{
	self endon("delete");

	while(1)
	{
		self waittill("trigger");
		spawn_manager_disable("sm_omaha_behind_wall");
		spawn_manager_enable("sm_omaha_infront_wall");
		wait(0.05);
	}
}

after_tower_trigger_infront()
{
	self endon("delete");

	while(1)
	{
		self waittill("trigger");
		spawn_manager_disable("sm_omaha_infront_wall");
		spawn_manager_enable("sm_omaha_behind_wall");
		wait(0.05);
	}
}

after_tower_think()
{
	self endon( "death" );
	
	self thread maps\_prisoners::make_prisoner();
	self.goalradius = 32;
		
	goals = GetNodeArray( "trans_delete" , "targetname" );
	self SetGoalPos( goals[RandomInt(goals.size)].origin );	
		
	self waittill( "goal" );
	self Delete();
	
}

tower_vo()
{
	player = get_players()[0];
	player.animname = "mason";
	
	flag_wait( "tower_done" );

	//crowd off of player
	level thread play_prisoner_crowd_vox( "vox_vor1_s99_324A_rrd5", "vox_vor1_s99_325A_rrd6", "vox_vor1_s99_326A_rrd7" );
	player thread play_delayed_cheer();
	player anim_single( player, "omaha_crowd2", "crow" );

	level.reznov anim_single( level.reznov, "omaha_lose" );
	level.reznov anim_single( level.reznov, "omaha_month" );
	level.reznov anim_single( level.reznov, "omaha_pause" );
	level.reznov anim_single( level.reznov, "omaha_falter" );
	level.reznov anim_single( level.reznov, "omaha_free" );
}

play_delayed_cheer()
{
    wait(2);
    self PlaySound( "amb_vox_fight_cheer_3" );
    level thread play_prisoner_crowd_vox( "vox_vor1_s99_321A_rrd5", "vox_vor1_s99_322A_rrd6", "vox_vor1_s99_323A_rrd7" );
    self anim_single( self, "rope_cheer", "crow" );
}

//***********************************************************//




slingshot()
{
	//just before slingshot bldg
	trigger_wait("slingshot_start");

	//spawn and kill a guard upstairs
	guard_pos = GetEnt("sling_radio_trig","targetname");
	guard = create_guard_model(undefined, guard_pos.origin);
	guard StartRagdoll();
	guard Launchragdoll( (10, 10, 0) );

	//so slingshot obj show up
	level._old_drawdist = getDvarInt( #"cg_objectiveIndicatorFarFadeDist");
	player = get_players()[0];
	player  SetClientDVar ("cg_objectiveIndicatorFarFadeDist",8000000);	
	
	level thread slingshot_roof();
	level thread slingshot_shotgun();
}

slingshot_int()
{
	level endon("flag_player_on_roof");

	//in case the player blasts up to the roof
	level thread slingshot_int_skip();

	//move reznov to the door
	anim_node = getstruct( "sergei_shotgun_door", "targetname" );
	
	level.reznov waittill("left_cart");
	anim_node anim_reach_aligned( level.reznov, "slingshot_door_enter");
	anim_node anim_single_aligned( level.reznov, "slingshot_door_enter");
	anim_node thread anim_loop_aligned( level.reznov, "slingshot_door_loop");

	trigger_wait("slingshot_start");

	level.reznov LookAtEntity();
	level.reznov thread anim_single( level.reznov, "sling_go" );
	anim_node anim_single_aligned(level.reznov, "slingshot_door_exit");

	//rez to stairs
	anim_node anim_reach_aligned( level.reznov, "reznov_start" );
	anim_node anim_single_aligned( level.reznov, "reznov_start" );

	//freeze reznov until play goes through second doorway
	anim_node anim_first_frame( level.reznov, "reznov_instruct" );

	//wait for player to enter main room before starting anim
	flag_wait("flag_slingshot_interior");

	delayThread(8, ::flag_set, "flag_obj_step_4");
	anim_node anim_single_aligned( level.reznov, "reznov_instruct" );
		
	//send rez to  radio
	anim_node = getstruct( "reznov_radio", "targetname" );
	
	anim_node anim_reach_aligned( level.reznov, "reznov_radio" );
	anim_node anim_single_aligned( level.reznov, "reznov_radio" );
	anim_node thread anim_loop_aligned( level.reznov, "reznov_radio_idle" );
	
	level thread slingshot_int_linger();

	
}

slingshot_int_door_open( reznov )
{
	door = GetEnt("slingshot_door_ent", "targetname" );
	door_col = GetEnt( door.target, "targetname" );
	door_col LinkTo( door );
	door_col ConnectPaths();
	door RotateYaw(-100, 0.7, 0.0, 0.5 );

	//if the player is close shake camera and controller rumble
	player = get_players()[0];
	distance = Distance2D(door.origin, player.origin);
	if( distance < 200)
	{
		Earthquake(0.1, 0.5, player.origin, 256);
		player PlayRumbleOnEntity( "damage_light" );
	}

	door waittill("rotatedone");
	door RotateYaw(3, 0.5, 0.0, 0.2);

	roof_door = GetEnt("sling_door_roof", "targetname" ); 
	roof_door_col = GetEnt( roof_door.target, "targetname" );
	roof_door_col LinkTo( roof_door );
	roof_door RotateYaw( -120, 0.1 );

	//player done with slingshot close doors
	flag_wait("player_has_shotgun");

	door RotateYaw( 97, 0.05 );
	roof_door RotateYaw( 120, 0.7 );
}

//handle sergei 
slingshot_int_sergei()
{
	anim_node = getstruct( "sergei_shotgun_door", "targetname" );
	
	anim_node anim_reach_aligned(level.sergei, "cover_left_enter");
	anim_node anim_single_aligned(level.sergei, "cover_left_enter");
	anim_node thread anim_loop_aligned(level.sergei, "cover_left");

	flag_wait("flag_slingshot_interior");

	//sergei to door
	anim_node anim_single_aligned( level.sergei, "reznov_instruct" );
	anim_node anim_loop_aligned( level.sergei, "reznov_instruct_loop");
}

slingshot_int_sergei_door(anim_node)
{
	player = get_players()[0];

	//if the player is close shake camera and controller rumble
	distance = Distance(self.origin, player.origin);
	height = Abs(self.origin[2] - player.origin[2]);

	if( distance < 75 && height < 64 )
	{
		Earthquake(0.3, 0.5, player.origin, 256);
		player PlayRumbleOnEntity( "damage_heavy" );
	}
	else if( distance < 150 && height < 64 )
	{
		Earthquake(0.1, 0.5, player.origin, 256);
		player PlayRumbleOnEntity( "damage_light" );
	}

	//play dust fx regardless
	exploder(501);
}

slingshot_int_linger()
{
	level endon("flag_player_on_roof");

	trigger = GetEnt("sling_radio_trig","targetname");
	trigger waittill("trigger");
	trigger Delete();

	level thread slingshot_int_linger_vo();

	anim_node = getstruct( "reznov_radio", "targetname" );
	anim_node anim_single_aligned( level.reznov, "reznov_radio_talk" );
	anim_node thread anim_loop_aligned( level.reznov, "reznov_radio_idle2" );
}

slingshot_int_linger_vo()
{
	level endon("flag_player_on_roof");

	player = get_players()[0];

	player anim_single( player, "sling_you", "mason");
	wait(4);
	//level.reznov anim_single( level.reznov, "sling_plan" );
	player anim_single( player, "sling_four", "mason");
	//level.reznov anim_single( level.reznov, "sling_rally" );
}

slingshot_int_skip()
{
	flag_wait("flag_player_on_roof");

	//stop all vo from Mason and Reznov
	get_players()[0] StopSounds();
	level.reznov StopSounds();
	level.reznov StopAnimScripted();

	anim_node = getstruct( "reznov_radio", "targetname" );
	anim_node thread anim_loop_aligned( level.reznov, "reznov_radio_idle2" );
}

slingshot_roof()
{
	flag_init("player_on_slingshot");
	level.slingshot_target_killed = 0;

	//for achievement tracking
	level.slingshot_shots_taken = 0;

	//handles drones and shrimps
	level thread slingshot_ambient_prisoners();

	//spawn all guards
	sling_guards = simple_spawn( "sling_guards", ::slingshot_guards_think );

	//setup slingshot mechanic
	level thread maps\vorkuta_slingshot_util::Setup_Slingshot();

	//trigger right before the roof on the stairs
	trigger_wait("sling_roof_trig");

	autosave_by_name("vorkuta_slingshot");

	//have player ignored - so easier to shoot
	player = getplayers()[0];
	player.ignoreme = true;
	
	//C. Ayers: Setting up a Slingshot Snapshot on the client
	clientnotify( "slng" );

	//setup damage trigs	
	sling_trigs = GetEntArray( "sling_trigs", "targetname" );

	//populate location array
	for(i= 0; i < sling_trigs.size; i++)
	{
		level.sling_vo_locations[i] = sling_trigs[i].script_string;
	}

	array_thread( sling_trigs, ::slingshot_trigger_think );
	
	//make them objectives for 3d text
	level thread slingshot_3d_objectives( sling_trigs );
			
	//wait for all targets to be destroyed
	while( level.slingshot_target_killed < sling_trigs.size )
	{
		wait 1;
	}
	
	level notify ("slingshot_roof_done");

	//check to see if the event was completed with the minimal amount of shots required
	if(level.slingshot_shots_taken <= 3)
	{
		player giveachievement_wrapper("SP_LVL_VORKUTA_SLINGSHOT");
	}

	//remove Sergei to stop the pounding sound
	level.sergei Delete();

	clientnotify( "sdd" );
	player.ignoreme = false;
}

slingshot_ambient_prisoners()
{
	//shrimps
	level thread slingshot_shrimp_manager();

	//vista FX on
	exploder(1500);

	//start upper drones - may replace with particles
	drone_trigger = GetEnt("upper_left_wave_group", "script_noteworthy");
	drone_trigger thread slingshot_drones();

	drone_trigger = GetEnt("upper_middle_wave_group", "script_noteworthy");
	drone_trigger thread slingshot_drones();

	//start lower drones
	drone_trigger = GetEnt("lower_left_wave_group", "script_noteworthy");
	drone_trigger thread slingshot_drones();

	drone_trigger = GetEnt("lower_middle_wave_group", "script_noteworthy");
	drone_trigger thread slingshot_drones();

	drone_trigger = GetEnt("lower_right_wave_group", "script_noteworthy");
	drone_trigger thread slingshot_drones();	

	//1 target down
	level waittill("sling_target_destroyed");
	level.shrimp_wait = 6;

	//2 targets down
	level waittill("sling_target_destroyed");
	level.shrimp_wait = 9;
		
	//3 targets down
	level waittill("sling_target_destroyed");
	level notify("stop_shrimps");

	//all targets down
	//level waittill("sling_target_destroyed");
	level notify("stop_sling_drones");
}

slingshot_shrimp_manager()
{
	level endon("stop_shrimps");

	level.shrimp_wait = 3;

	while(1)
	{
		PlayFX(level._effect["shrimp_horde_right"], (-5731.44, 4184.71, 767.5), AnglesToForward((0, 16, 0)));             
		PlayFX(level._effect["shrimp_horde_left"], (-4786.48, 3432.43, 749.5), AnglesToForward((358.405, 25.9937, -1.75)));                    
		PlayFX(level._effect["shrimp_horde_back1"], (-7329.71, 3945.44, 1002.63), AnglesToForward((0, 26, 0)));
		PlayFX(level._effect["shrimp_horde_back2"], (-6002.27, 2900.33, 992.88), AnglesToForward((0, 26, 0))); 	

		wait(level.shrimp_wait);
	}
}

//damage trigs
slingshot_trigger_think( )
{
	player = getplayers()[0];
		
	while(1)
	{
		if( IsDefined(level.cocktail) && self IsTouching(level.cocktail) )//Make sure player can't trigger these early
		{
			break;
		}
		
		wait 0.1;	 
	}
	level.slingshot.active = false;//Protect from player hitting a 2 for 1 shot
	//blow up target
	PlayFX (level._effect["vehicle_explosion"], self.origin);
	playsoundatposition( "evt_target_explo", self.origin );

	player PlayRumbleOnEntity( "damage_heavy" );

	//check if ai in trigger - not the best way
	guards = GetAIArray( "axis" );
	for( i = 0; i < guards.size; i++ )
	{
		if( IsDefined( guards[i] ) && guards[i] IsTouching (self ) )
		{
			guards[i] thread slingshot_guards_kill();				
		}	
	}
	exploder(self.script_noteworthy);
	//keep track of targets killed	
	level.slingshot_target_killed++;
	
	if(level.slingshot_target_killed < 3)//Should not be hardcoded, but works for now
		thread play_target_destroyed_vo();

	//watched in slingshot_ambient_prisoners to turn off ambience progressively
	level notify("sling_target_destroyed");
		
	level.sling_vo_locations = array_remove(level.sling_vo_locations, self.script_string);
	
	//cleanup
	self Delete();
	wait(.1);
	level.slingshot.active = true;	
}

play_target_destroyed_vo()
{
	if(!level.slingshot_ai_vo_node.random_target_vo_set)
	{
		level.target_success_vo = [];
		level.target_success_vo[0] = "good_shot_mason";//Good shot Mason!
		level.target_success_vo[1] = "got_him_mason";//You got him Mason!
		level.target_success_vo[2] = "excellent_shot_friend";//Excellent shot my friend!
		level.target_success_vo[3] = "nice_work_mason";//Nice work Mason.
		level.target_success_vo[4] = "another_one_down";//Another one down!
		level.target_success_vo[5] = "you_got_him";//You got him.
		level.target_success_vo[6] = "impressive";//Impressive!
		level.slingshot_ai_vo_node.random_target_vo_set = true;
	}
	wait(.5);
	index = RandomIntRange(0, level.target_success_vo.size);
	level.slingshot_ai_vo_node thread anim_single( level.slingshot_ai_vo_node, level.target_success_vo[index] );
	level.target_success_vo = array_remove_index(level.target_success_vo, index);//Remove what we just played so it doesn't repeat
}

//put 3d text on targets
slingshot_3d_objectives( trigs )
{
	flag_wait("player_on_slingshot");
	for( i = 0; i < trigs.size; i++ )
	{
		y_offset = get_slingshot_objective_offset(trigs[i].script_noteworthy);
		objective_add(i +7 ,"current");
		objective_position(i+7,trigs[i].origin +(0,0, y_offset));
	
		//print "targets" text
		Objective_Set3D( i+7, true, "default", &"VORKUTA_OBJ_TARGET" );
		
		//thread each indiv trig
		trigs[i] thread slingshot_obj_update( i+7 );
	}
	
}

get_slingshot_objective_offset(offset_noteworthy)
{
	switch(offset_noteworthy)
	{
		case "21":
			offset = 100;
		break;
		
		case "22":
			offset = 10;
		break;
		
		case "23":
			offset = 160;
		break;
		
		case "24":
			offset = -80;
		break;
		
		case "25":
			offset = 45;
		break;
		
		default:
			offset = 0;//should assert here
		break;
	}
	
	return offset;
}

//remove text when destroyed
slingshot_obj_update( num )
{
	while( IsDefined( self ) )
	{
		wait 0.1;
	}
	
	objective_set3d(num,0);
	objective_delete(num);	
}



slingshot_guards_kill()
{
	if( IsAlive( self ) )
	{
		self stop_magic_bullet_shield();
		self StartRagdoll();
		self Launchragdoll( (128, 64, 192) );
		self burn_me();
	}
}

//spawn drones
slingshot_drones( )
{
	//start drones
	self activate_trigger();

	//stop drones - change so it stops once player leaves the roof
	level waittill( "stop_sling_drones" );

	self notify("stop_drone_loop");
	
	//free up ents and script variables by removing trigger and structs
	level thread remove_drone_structs(self);	
}

slingshot_guards_think()
{
		drone_targets = [];		
		self magic_bullet_shield();//Make sure player or some something mysterious kills them first
		self.goalradius = 16;//This is to help the guards stay put

		self thread slingshot_guards_flash();
		
		//turn off rpg's for some guys, they interfere with grenades
		//if( self.script_noteworthy == "sling_tower_guards" )
			self.a.rockets = 0;
				
		//grab targets from drone spline	
		if( self.script_noteworthy == "sling_upper_guards" || self.script_noteworthy == "sling_tower_guards" || self.script_noteworthy == "sling_indoor_guards" )
		{	
			//use upper targs
			drone_targets = getstructarray( "upper_targs",  "script_noteworthy" );
		}
		else if( /*self.script_noteworthy == "sling_lower_guards"*/ IsSubStr(self.script_noteworthy, "lower") )
		{
			//use lower targs
			drone_targets = getstructarray( "lower_targs",  "script_noteworthy" );
		}

		//spawn one org for ai to shoot at
		target_org = spawn ("script_origin", drone_targets[0].origin);
	
		//while guard is alive
		while( IsAlive( self ))
		{	
				//pick a random target and put org there
				target_org.origin = drone_targets[ RandomInt( drone_targets.size ) ].origin;
				
				x = RandomInt(100);
				if( x < 80 )
				{
					//fire at org
					self SetEntityTarget( target_org ); 
				}
				else
				{
					if( self.script_noteworthy != "sling_tower_guards" && self.script_noteworthy != "sling_indoor_guards" )
					{
						self maps\_grenade_toss::force_grenade_toss(target_org.origin, "frag_grenade_sp", 3.0, undefined, undefined);
					}
				}
				wait 2;
		}
		
		//cleanup
		target_org Delete();
	
}

slingshot_guards_flash()
{
	self endon("death");
	
	while(1)
	{
		self waittill("shoot");

		if( IsDefined(self GetTagOrigin("tag_flash") ) )
		{
			PlayFXOnTag( level._effect["slingshot_muzzle_flash"], self, "tag_flash");
			wait(0.5);
			PlayFXOnTag( level._effect["slingshot_muzzle_flash"], self, "tag_flash");
			wait(0.5);
		}
	}
}

slingshot_shotgun()
{
	//move shotgun pile and trigger
	tower_shotgun = GetEnt("tower_shotgun", "targetname" );
	tower_shotgun trigger_off();
	shotguns = GetEntArray("sergei_weapon_door_dmg", "targetname" );
	for(i=0; i<shotguns.size; i++)
	{
		shotguns[i] MoveZ( -128, 0.1 );
	}
		
	level waittill( "slingshot_roof_done" );

	//turn the trigger on after the slingshot event
	tower_shotgun trigger_on();
	silo = GetEnt("fxanim_vorkuta_towers_mod","targetname");
	silo Show();
	armory = GetEnt("fxanim_vorkuta_armory_mod","targetname");
	armory Show();

	//turn the lights on in the courtyard
	exploder(27);
	exploder(1600);
	
	//give reznov weapon
	level.reznov maps\_prisoners::unmake_prisoner();
	level.reznov StopAnimScripted();
	level.reznov LookAtEntity();

	//send rez to stairs and wait
	anchor = spawn("script_origin", level.reznov.origin);
	anchor.angles = level.reznov.angles;
	level.reznov LinkTo(anchor);

	node = GetNode( "rez_post_sling", "targetname" );

	anchor MoveTo( node.origin, 0.1);
	anchor RotateTo( node.angles, 0.1);
	anchor waittill("rotatedone");

	level.reznov Unlink();
	anchor Delete();
	
	door = GetEnt( "sergei_weapon_door", "targetname" );
	door Delete();
	
	//show shotguns and broken door
	for(i=0; i<shotguns.size; i++)
	{
		shotguns[i] MoveZ( 128, 0.1 );
	}

	//spawn squad after slingshot event 
	trigger_use ("sm_courtyard_friendly_1");

	//friendly chain for reznov and prisoners
	trigger_use("courtyard_gate_chain");

	trigger_wait( "sling_roof_trig" );

	level thread slingshot_shotgun_vo();
	
	//send rez to door
	node = GetNode( "rez_sling_exit", "targetname" );
	level.reznov SetGoalNode( node );
	
	door = GetEnt( "sling_door_exit", "targetname" );
	door_col = GetEnt( "slingshot_exit_col", "targetname" );
	door_col ConnectPaths();
	door_col LinkTo( door );
	door RotateYaw( -120,0.1 );
	
	//give player shotgun	
	
	tower_shotgun thread slingshot_shotgun_refill();
	tower_shotgun waittill ("trigger");
	get_players()[0] PlaySound("wpn_weap_pickup_plr");	
	get_players()[0] GiveWeapon("ks23_sp");

	//turn off rooftop FX
	stop_exploder(1500);

	//allow the player to throw back grenades
	get_players()[0] GiveWeapon("frag_grenade_sp");
	get_players()[0] TakeWeapon("frag_grenade_sp");

	get_players()[0] SwitchToWeapon ("ks23_sp");
	
	flag_set ("player_has_shotgun");
	maps\vorkuta_slingshot_util::slingshot_cleanup();//Cleanup stuff from slingshot event

	//put reznov on the orange friendly chain
	level.reznov set_force_color( "o" );
	level.reznov enable_ai_color();		

	autosave_by_name( "shotgun" );

	
	//wait for player to get a decent distance from this area
	flag_wait("flag_shoot_rope_guy");

	//delete models
	for(i=0; i< shotguns.size; i++)
	{
		shotguns[i] Delete();
	} 
	tower_shotgun Delete();
}

slingshot_shotgun_refill()
{
	self endon("delete");

	while(1)
	{
		self waittill("trigger", player);
		player GiveMaxAmmo("ks23_sp");
		wait(0.05);
	}
}


slingshot_shotgun_vo()
{
	//squad guy who questions step 5
	prisoner = simple_spawn_single("step_5_prisoner");
	prisoner set_ignoreall(true);
	prisoner.animname = "squad";
	prisoner LookAtEntity(get_players()[0]);

	anim_single( level.reznov, "sling_exit" );
	anim_single( level.reznov, "sling_arm" );
	anim_single( level.reznov, "sling_reinforce" );
	anim_single(get_players()[0], "sling_anticip", "mason");
	prisoner anim_single( prisoner, "sling_step5" );
	level.reznov anim_single( level.reznov, "sling_weapon" );

	trigger_wait("courtyard_back");

	//check to see if the player was a jerk and killed this guy
	if(IsAlive(prisoner))
	{
		prisoner set_force_color( "o" );
		prisoner enable_ai_color();
		prisoner set_ignoreall(false);
		prisoner LookAtEntity();
	}	
}

courtyard()
{
	//setup courtyard threat bias so the battle isn't as player focused
	array_thread( GetEntArray("courtyard_ai","script_noteworthy"), ::add_spawn_function, ::courtyard_threatbias_group);

	switch( GetDifficulty() )
	{
	case "easy": 
		courtyard_adjust_threatbias(2500);
		break;
	case "medium":
		courtyard_adjust_threatbias(2000);
		break;
	case "hard":
		courtyard_adjust_threatbias(1500);
		break;
	case "fu":
		courtyard_adjust_threatbias(1000);
		break;			
	}

	level thread courtyard_intro();
	level thread courtyard_heli();
	level thread courtyard_rope();
	level thread courtyard_hint();
	
	add_spawn_function_veh( "courtyard_truck1", ::play_truck_arrival_audio );
	add_spawn_function_veh( "courtyard_truck2", ::play_truck_arrival_audio );

	add_spawn_function_veh( "courtyard_truck1", ::truck_monitor );
	add_spawn_function_veh( "courtyard_truck2", ::truck_monitor );
	
	add_spawn_function_veh( "courtyard_heli", ::heli_toggle_rotor_fx, true );
}

courtyard_threatbias_group()
{
	if(self.team == "axis")
	{
		self SetThreatBiasGroup("standard_enemies");
	}
	if(self.team == "allies")
	{
		self SetThreatBiasGroup("friendly_ai");
	}
}

courtyard_adjust_threatbias(num)
{
	CreateThreatBiasGroup("standard_enemies");
	CreateThreatBiasGroup("friendly_ai");

	SetThreatBias("standard_enemies","friendly_ai",num);
	SetThreatBias("friendly_ai","standard_enemies",num);
}

//let player know he can use grenade launcher
courtyard_hint()
{
	//wait for player to pickup ak47gl
	player = getplayers()[0];
	while(!player HasWeapon("ak47_gl_sp"))
	{
		wait(0.1);
	}
	
	//hint text on screen
	screen_message_create(&"VORKUTA_HINT_GL");
	wait 5;
	screen_message_delete();
}

courtyard_intro()
{
	trigger_wait( "sm_courtyard_start" );

	level thread courtyard_gate();
	level thread courtyard_friendly_manager();

	//start drones
	drone_trigger = GetEnt("courtyard_drone_front", "script_noteworthy");
	drone_trigger activate_trigger();
		
	level spawn_manager_enable( "courtyard_wave1" );
	
	level waittill( "courtyard_gate_open" );
	
	level thread courtyard_intro_vo();

	//stop initial friendly spawner
	spawn_manager_kill("sm_courtyard_start");
	
	//stop the drones from spawning in the intro courtyard area
	drone_trigger notify("stop_drone_loop");
	level thread remove_drone_structs(drone_trigger);

	//player enters the battle space
	trigger_wait("courtyard_back");

	//kill the enemy sm for the first section
	spawn_manager_kill("courtyard_wave1");

	//use truck trigger
	trigger_wait("courtyard_friendly_1");

	//spawn more friendlies coming from the rear 
	trigger_use("sm_courtyard_friendly_2");

	//when the helicopter spawns
	flag_wait("flag_courtyard_helicopter");

	//attempt to save halfway through the fight
	autosave_by_name("courtyard_halfway");
}

courtyard_intro_vo()
{
	//flag set once the helicopter spawns in
	level endon("flag_courtyard_helicopter");

	player = get_players()[0];

	//intro cheer
	level.reznov anim_single(level.reznov, "court_forward");
	level.reznov anim_single(level.reznov, "court_intro_cheer");
	player anim_single(player, "court_intro_cheer", "mason");

	//create an array of reznov's lines for the area
	reznov_line[0] = "court_spare";
	reznov_line[1] = "court_veng";
	reznov_line[2] = "court_paint";
	reznov_line[3] = "court_tear";
	reznov_line[4] = "court_bury";
	reznov_line[5] = "court_fight";

	reznov_line = array_randomize(reznov_line);

	for(i = 0 ; i < reznov_line.size; i++)
	{
		wait( RandomFloatRange(8.0, 12.0) );
		level.reznov anim_single( level.reznov, reznov_line[i] );
	}
}

//used to move the friendlies forward if the player stays back
courtyard_friendly_manager()
{
	//spawn manager for the start of the fight
	waittill_ai_group_amount_killed("courtyard_wave_1", 2);
	courtyard_kill_off( get_ai_group_ai("courtyard_wave_1") );

	//grab the friendly trigger_once and check to see if it exists
	color_trigger = GetEnt("courtyard_friendly_1","targetname");
	if(IsDefined(color_trigger))
	{
		color_trigger activate_trigger();
	}

	waittill_ai_group_amount_killed("courtyard_wave_2", 4);

	color_trigger = GetEnt("courtyard_friendly_2","targetname");
	if(IsDefined(color_trigger))
	{
		color_trigger activate_trigger();
	}

	waittill_ai_group_amount_killed("courtyard_truck_ai", 5);
	
	color_trigger = GetEnt("courtyard_friendly_3","targetname");
	if(IsDefined(color_trigger))
	{
		color_trigger activate_trigger();
	}

	waittill_ai_group_amount_killed("courtyard_wave_3", 5);
	
	color_trigger = GetEnt("courtyard_friendly_4","targetname");
	if(IsDefined(color_trigger))
	{
		color_trigger activate_trigger();
	}

}

courtyard_kill_off( enemy_array )
{
	for(i = 0; i < enemy_array.size; i++)
	{
		if(IsDefined(enemy_array[i]) && IsAlive(enemy_array[i]))
		{
			enemy_array[i] DoDamage(enemy_array[i].health + 100, enemy_array[i].origin);
			wait( RandomFloatRange(1.0,3.0) );
		}
	}
}

courtyard_gate()
{
	level.reznov LookAtEntity(get_players()[0]);
	level.reznov thread anim_single( level.reznov, "court_lock" );

	gate_col = GetEnt( "courtyard_gate_col", "targetname" );

	nodes = GetNodeArray("courtyard_gate_cover","script_noteworthy");
	array_thread(nodes, ::courtyard_gate_nodes);

	//a damage trigger that only triggers based on shotgun damage
	trigger = trigger_wait("courtyard_gate_damage");	
	trigger Delete();

	playsoundatposition( "evt_gate_lock_shoot", (0,0,0) );
	gate_lock = GetEntArray( "gate_lock", "targetname" );
	PlayFX (level._effect["sparks_lock_burst"], gate_lock[0].origin);
	array_thread( gate_lock, ::Delete_me);
	
	gate_col ConnectPaths();
	gate_col Delete();

	level notify( "gate_locked_start" );
	level notify( "courtyard_gate_open" );

	level.reznov LookAtEntity();
	level.reznov set_ignoreall(false);
	
	flag_set("flag_obj_step_5");
	autosave_by_name("vorkuta_courtyard_start");

	//spawn specific enemies with AK-47s to turn the corner
	level spawn_manager_enable( "courtyard_gate_sm" );
	
	wait 2; //pause before sending guys through
	trigger_use("courtyard_enter");
	
	//TUEY set music state to Courtyard Fight
	setmusicstate ("COURTYARD_FIGHT");
	level thread maps\vorkuta_amb::activate_fake_friendly_dds();

}

courtyard_gate_nodes()
{
	while(!flag("flag_obj_step_5"))
	{
		person = GetNodeOwner(self);
		if(IsDefined(person))
		{
			person ToggleIK(true);
			person.ikpriority = 5;
		}
		wait(0.05);
	}
}

#using_animtree("generic_human");

//handles the heli
courtyard_heli()
{
	//hide destroyed towers
	silo_dmg = GetEntArray( "court_silo_dmg", "targetname" );
	for( i=0; i < silo_dmg.size; i++ )
	{
		silo_dmg[i] Hide();		
	}
	
	
	//intro heli
	trigger_wait( "courtyard_heli_trig" );
	
	level thread courtyard_heli_vo();
	
	wait 1; //temp
	
	heli = GetEnt( "courtyard_heli", "targetname" );
	heli SetCanDamage( false );

	//disables the start up fx
	//heli heli_toggle_rotor_fx( true );

	heli thread courtyard_heli_think();
	heli thread heli_spotlight_enable();
	
	//spawn models and attach pilot and gunner
	pilot = spawn_anim_model("guard_model");
	pilot character\c_rus_prison_guard::main();
	pilot UseAnimTree(#animtree);
	pilot enter_vehicle(heli, "tag_passenger");

	gunner = spawn_anim_model("guard_model");
	gunner character\c_rus_prison_guard::main();
	gunner UseAnimTree(#animtree);
	gunner enter_vehicle(heli, "tag_gunner1");
	
	//shoot heli on roof - temp
	flag_wait("flag_inside_hookshot_building");
	
	//TUEY set music state to PRE SKEWER
	setmusicstate ("PRE_SKEWER");
			
	//kill heli
	flag_wait("flag_heli_hit");
	
	//stop firing and have gunner fall
	heli thread maps\_vehicle_turret_ai::disable_turret(0);	
	
	start_node = GetVehicleNode( "heli_roof", "targetname" );
	heli drivepath( start_node );
	wait 0.1;
	heli StartPath();	//lock to spline
	heli waittill( "reached_end_node" );

	//send the guy out of the gunner
	gunner StartRagdoll();
		
	//play the destruct anim
	heli thread courtyard_heli_anim();
		
	//delete all friends
	friends = GetAIArray( "allies" );
	for( i=0; i<friends.size; i++ )
	{
		friends[i] dodamage( friends[i].health + 100, (0,0,0), friends[i] );
	}
		
	//wait till heli anim is done
	level waittill( "heli_crash_done" );
	
	//handle silo damage states
	silo = GetEntArray( "court_silo", "targetname" );
	//show destroyed towers
	for( i=0; i<silo.size; i++ )
	{
		silo[i] Hide();		
		
	}
	for( i=0; i<silo_dmg.size; i++ )
	{
		silo_dmg[i] Show();	
	}
	
	pilot Delete();
		
	//delete armory entrance
	armory_entrance = GetEntArray("armory_entrance", "targetname");
	PlayFX (level._effect["vehicle_explosion"], armory_entrance[0].origin);
	playsoundatposition( "evt_courtyard_building_explo", armory_entrance[0].origin );

	flag_set ("courtyard_done");

	flag_wait("delete_rush");
	
	autosave_by_name("vorkuta_courtyard_done");
}

#using_animtree("fxanim_props");
courtyard_heli_anim()
{
	//play anim
	self UseAnimTree(#animtree);
	level notify( "towers_start" );

	self anim_single( self, "a_heli_crash", "fxanim_props");

	self heli_spotlight_enable(false);

	//spawn a deathmodel and replace the helicopter to remove fx
	deathmodel = Spawn("script_model", self GetTagOrigin("origin_animate_jnt") );
	deathmodel.angles = self GetTagAngles("origin_animate_jnt");
	deathmodel SetModel("t5_veh_helo_mi8_woodland_dead");

	self Delete();
	
	level notify( "heli_crash_done" );
}

courtyard_heli_player()
{
	self endon("stop_free_fly");

	player = get_players()[0];

	self.health = 20000;
	self.takedamage = true;

	while(1)
	{
		self waittill ("damage", amount, inflictor, direction, point, type);

		self.health = 20000;

		if(inflictor == player)
		{
			self.player_attacking = true;
			self maps\_vehicle_turret_ai::clear_forced_target();
			self maps\_vehicle_turret_ai::set_forced_target(player); 

			wait(10);

			self maps\_vehicle_turret_ai::clear_forced_target(player);
			self.player_attacking = false;
		}
	}
}

courtyard_heli_allies()
{
	self endon("stop_free_fly");

	while(1)
	{
		if(!self.player_attacking)
		{
			allies = GetAIArray("allies");
			allies = array_remove(allies, level.reznov);
			allies = array_add(allies, get_players()[0]);
			self maps\_vehicle_turret_ai::set_forced_target(allies);
		}
		wait(0.5);
	}
}

courtyard_heli_think()
{
	level endon( "flag_heli_hit" );

	self veh_toggle_tread_fx(0);
	
	self.turret_audio_override = true;
	self thread maps\_vehicle_turret_ai::enable_turret(0, "mg", "allies");	
	self thread maps\_vehicle_turret_ai::enable_turret(2, "huey_spotlight", "allies");	
	
	self waittill("reached_end_node");

	//used to determine what the helicopter should shoot at
	self.player_attacking = false;

	self thread courtyard_heli_free_fly();
	self thread courtyard_heli_player();
	self thread courtyard_heli_allies();
	
	//start the drones that die
	trigger_wait("courtyard_roof_ent");
	
	//save
	autosave_by_name( "courtyard_rope" );

	//player in building move to spot and hover
	trigger_wait( "teleport_chopper" );
	
	//start spawning the fodder
	level thread courtyard_heli_drones();
	
	self notify("stop_free_fly");
	self.takedamage = false;
	
	//teleport the chopper
	teleport_org = GetVehicleNode("copter_teleport_start","targetname");
	self go_path(teleport_org);
	
	node = getvehiclenode("heli_roof", "targetname");
	self SetVehGoalPos( node.origin, 1 );
	self SetGoalYaw( node.angles[1] );

	//shoot drones until the player looks out the door
	while( !flag("flag_shoot_rope_guy") )
	{
		fodder = GetEntArray("drone", "targetname");
		self maps\_vehicle_turret_ai::set_forced_target( fodder ); 
		wait(0.1);
	}
	
	//shoot rope guys -use magic bullet to insure?
	self maps\_vehicle_turret_ai::clear_forced_target();
	self maps\_vehicle_turret_ai::set_forced_target( level.rope_guys );  

	while(level.rope_guys.size > 0)
	{
		level.rope_guys = array_removeDead(level.rope_guys);
		wait(0.1);
	}

	//shoot drones until the player grabs the weapon
	while( !flag("flag_has_rope_gun") )
	{
		fodder = GetEntArray("drone", "targetname");
		self maps\_vehicle_turret_ai::set_forced_target( fodder ); 
		wait(0.1);
	}
		
	//after rope guys dead - target rez
	//self maps\_vehicle_turret_ai::set_forced_target( level.reznov );

	player = get_players()[0];
	player EnableInvulnerability();
	self maps\_vehicle_turret_ai::clear_forced_target();
	self maps\_vehicle_turret_ai::set_forced_target( player );
	
	//player is taking too long, shoot him
	wait(8);

	player DisableInvulnerability();
}

courtyard_heli_free_fly()
{
	self endon("stop_free_fly");

	positions = getstructarray("courtyard_helicopter_pos","targetname");

	while( !flag("flag_reznov_to_helicopter") )
	{
		new_pos = positions[RandomInt(positions.size)];
		self SetVehGoalPos( new_pos.origin, 1 );
		self SetGoalYaw( new_pos.angles[1], 1 );

		self waittill("goal");
		wait(RandomFloatRange(3.0, 6.0));
	}

	positions = getstructarray("courtyard_helicopter_pos_2","targetname");

	while( 1 )
	{
		new_pos = positions[RandomInt(positions.size)];
		self SetVehGoalPos( new_pos.origin, 1 );
		self SetGoalYaw( new_pos.angles[1], 1 );

		self waittill("goal");
		wait(RandomFloatRange(3.0, 6.0));
	}
}

courtyard_heli_drones()
{
	//start drones
	drone_trigger = GetEnt("courtyard_roof_drone_trig", "script_noteworthy");
	drone_trigger activate_trigger();

	//stop drones
	trigger_wait( "rope_give" );
	drone_trigger notify("stop_drone_loop");
	level thread remove_drone_structs(drone_trigger);
}

//player does not hit heli
courtyard_heli_fail()
{
		level.reznov thread anim_single( level.reznov, "nooo" );

		player = get_players()[0];
		heli = GetEnt( "courtyard_heli", "targetname" );
		heli thread maps\_vehicle_turret_ai::disable_turret(0);	
		heli SetGunnerTargetEnt( player, (0,0,48), 0);

		player DisableInvulnerability();
		
		//have the helicopter fire at the player
		for( i=0; i<10; i++ )
		{
				heli FireGunnerWeapon(0);
				wait( 0.1);
		}
		
		//kill the player with custom death message
		player DoDamage ( player.health + 500, player.origin );
}

courtyard_heli_vo()
{
	player = get_players()[0];
	player.animname = "mason";

	//making sure to not override current vo for reznov
	wait(3);
	
	courtyard_heli_vo_reveal(player);
	
	flag_wait("flag_reznov_to_helicopter");
	
	level.reznov disable_ai_color();
	level.reznov thread ignore_me_timer( 10, "goal" );
	node = GetNode("rez_roof_ent", "targetname" );
	level.reznov force_goal( node, undefined, true);
	
	level.reznov thread anim_single( level.reznov, "rope_way" ); //This way!

	flag_wait("flag_heli_hit");

	level.reznov anim_single( level.reznov, "rope_ura" );

	player anim_single( player, "rope_cheer", "crow" );	//temp for crowd
	level thread play_prisoner_crowd_vox( "vox_vor1_s99_321A_rrd5", "vox_vor1_s99_322A_rrd6", "vox_vor1_s99_323A_rrd7" );
	wait(1.5);
	level thread play_prisoner_crowd_vox( "vox_vor1_s99_324A_rrd5", "vox_vor1_s99_325A_rrd6", "vox_vor1_s99_326A_rrd7" );
	
}

courtyard_heli_vo_reveal(player)
{
	level endon("flag_reznov_to_helicopter");

	//lines played off the player in case Reznov is too far away
	anim_single( player, "chopper_here", "reznov");
	anim_single( player, "chopper_how", "rrd4");
	anim_single( player, "chopper_wish", "reznov");
	anim_single( player, "rope_step");
	anim_single( player, "rope_skewer", "reznov");
	anim_single( player, "quickly", "reznov");
}

//attempts to teleport Reznov closer to the player
courtyard_teleport_reznov()
{
	player = get_players()[0];
	eye = player GetEye();

	if( !level.reznov SightConeTrace(eye, player) )
	{
		anchor = spawn("script_origin", level.reznov.origin);
		anchor.angles = level.reznov.angles;
		level.reznov LinkTo(anchor);
		level.reznov Hide();

		node = GetNode( "rez_roof_ent", "targetname" );
		anchor MoveTo( node.origin, 0.1);
		anchor RotateTo( node.angles, 0.1);
		anchor waittill("rotatedone");
		level.reznov Show();
		level.reznov Unlink();
		anchor Delete();
	}
}

//if for some reason he did not make it inside before door close
courtyard_teleport_reznov_inside()
{
	node = GetNode( "courtyard_safety_reznov", "targetname" );

	if( level.reznov.origin[0] < node.origin[0] )
	{
		anchor = spawn("script_origin", level.reznov.origin);
		anchor.angles = level.reznov.angles;
		level.reznov LinkTo(anchor);
		
		anchor MoveTo( node.origin, 0.1);
		anchor waittill("movedone");
		level.reznov Unlink();
		anchor Delete();
	}	
}

courtyard_rope()
{
	//open the door to the roof
	ent_door = GetEnt( "rope_entrance", "targetname" );
	ent_door_col = GetEnt( "rope_ent_col", "targetname" );
	ent_door_col LinkTo( ent_door );
	ent_door RotateYaw( -100, 0.05 );
	ent_door_col ConnectPaths();

	//player blocker turn off
	blocker = GetEnt("hookshot_blocker","targetname");
	blocker trigger_off();

	//set inside the building, also teleports the chopper
	flag_wait("flag_inside_hookshot_building");
	
	level thread maps\vorkuta_amb::deactivate_fake_friendly_dds();	
	
	//attempt to teleport Reznov closer and send him upstairs
	courtyard_teleport_reznov();
	level thread courtyard_reznov_block();
	level thread courtyard_rope_vo();

	//spawn rope guys
	level thread courtyard_rope_anim();
	level thread kill_all_enemies();	//from vorkuta_util

	//send friends inside
	delayThread(2.0, ::trigger_use, "courtyard_roof_chain");
	
	spawn_manager_kill("sm_courtyard_friendly_1");
	spawn_manager_kill("sm_courtyard_friendly_2");

	//player got the hookshot weapon
	flag_wait("flag_has_rope_gun");
	level thread play_rope_taut_sound();
	blocker trigger_on();

	//give player the harpoon and take away his other weapons
	player = get_players()[0];
	player DisableWeaponCycling();
	player take_weapons();
	wait(0.05);
	player GiveWeapon ("ks23_hook_sp");
	player SwitchToWeapon ("ks23_hook_sp");
	player EnableWeaponCycling();

	//wait for the shot
	player waittill( "weapon_fired" );
	
	//shake and rumble for gun shot
	player PlayRumbleOnEntity("damage_heavy");	
	Earthquake(1, 0.3, player.origin, 256);
				
	player PlaySound( "wpn_rope_gun_shot" );
		
	start = player GetWeaponMuzzlePoint();
	forward = player GetWeaponForwardDir();
	end = start + vector_scale( forward, 8000 );
	
	trace = BulletTrace(start, end, false, undefined);
	
	point_abs = trace["position"];
	hitent = trace["entity"];
	
	missile = MagicBullet( "rpg_magic_bullet_sp", start, end, player );
	missile PlayLoopSound( "wpn_rope_shot", .1 );
	
	//remove harpoon and giveback weapons
	player TakeWeapon("ks23_hook_sp" );
	player give_weapons();
	player DisableInvulnerability();
	blocker Delete();

	if( isdefined( point_abs ) )
	{
		len = distance( start, point_abs );
		
		if( len > 3000 )
		{
			len = 3000;
		}
		
		println( "rope len: " + len );
		rope_building_anchor = getstruct( "rope_anchor", "targetname" );
		
		ropeid = CreateRope( rope_building_anchor.origin, ( 0, 0, 0 ), len * 0.9, missile );
		RopeSetParam( ropeid, "width", 4 );
		
		if( isdefined( hitent ) && hitent.targetname == "courtyard_heli" )
		{
			//TUEY set music state to SKEWER_THE_BEAST
			setmusicstate("SKEWER_THE_BEAST");

			//shake and rumble for contact
			player PlayRumbleOnEntity("damage_light");	
			Earthquake(1, 0.2, player.origin, 256);

			//spawn and link an origin to play smoke fx from
			hit_loc = Spawn("script_model", point_abs);
			hit_loc SetModel("tag_origin");
			hit_loc LinkTo(hitent, "origin_animate_jnt");
			PlayFXOnTag(level._effect["bike_smoke"], hit_loc, "tag_origin");
			
			point_loc = hitent WorldToLocalCoords( point_abs );
			missile waittill( "death" );
			PlaySoundAtPosition( "wpn_rope_hit", hitent.origin );
			RopeAddEntityAnchor( ropeid, 1, hitent, point_loc );
			
			flag_set("flag_heli_hit");

			player.overridePlayerDamage = undefined;

			//delete rope when heli destroyed
			flag_wait( "courtyard_done" );
			DeleteRope( ropeid );
			hit_loc Delete();

			//remove the blocker brush so player can mantle off the roof
			blocker = GetEnt("helicopter_roof_blocker","targetname");
			blocker Delete();

			//remove FX at omaha and slingshot building
			stop_exploder(1300);
			stop_exploder(1400);

			//start FX in armory part 1
			exploder(1700);
		}
		else
		{
			//make sure the rope doesn't stay connected to nothing
			ropesetflag( ropeid, "keep_ent_anchors", 1 );
			wait(0.5);
			RopeRemoveAnchor( ropeid, 1);

			//have the helicopter shoot and kill the player		
			level courtyard_heli_fail();
		}
	}
}

courtyard_reznov_block()
{
	level.reznov set_ignoreme(true);
	level.reznov set_ignoreall(true);

	//send Reznov to the second story
	node = GetNode( "rez_heli_node", "targetname" );
	level.reznov thread force_goal(node, 4);

	//player got the hookshot weapon
	flag_wait("flag_has_rope_gun");

	//close door downstairs
	enter_door = GetEnt( "rope_entrance", "targetname" );
	enter_door RotateYaw( 100, 0.1 );
	enter_door waittill("rotatedone");

	//exit door open
	exit_door =  GetEnt( "rope_exit", "targetname" );
	exit_door_col = GetEnt( "rope_exit_col", "targetname" );
	exit_door_col LinkTo(exit_door);
	exit_door RotateYaw(120, 0.3);
	exit_door_col ConnectPaths();

	//in case he didn't make it inside for whatever reason
	courtyard_teleport_reznov_inside();

	//Reznov moves to block the entrance
	if(!flag("flag_heli_hit"))
	{
		node = GetNode( "rope_block_node", "targetname" );
		level.reznov force_goal(node, 4);
		level.reznov LinkTo(GetEnt("rope_give","targetname"));
		heli = GetEnt("courtyard_heli","targetname");
		level.reznov thread aim_at_target(heli);
	}

	//player successfully shot the helicopter
	flag_wait("flag_heli_hit");

	//reset reznov
	level.reznov set_ignoreme(false);
	level.reznov set_ignoreall(false);
	level.reznov stop_aim_at_target();
	level.reznov Unlink();

	level.reznov set_force_color("c");
	trigger_use("triggercolor_reznov_downstairs");
}

//guys that give rope to player
courtyard_rope_anim()
{
	level.rope_guys[0] = simple_spawn_single( "rope_guy1", ::rope_guy_think );
	level.rope_guys[1] = simple_spawn_single( "rope_guy2", ::rope_assistant_think );

	level.rope_guys[0] waittill("death");

	level.gun = Spawn( "script_model", level.rope_guys[0] GetTagOrigin("tag_weapon_right") );
	level.gun.angles = level.rope_guys[0] GetTagAngles("tag_weapon_right");
	level.gun SetModel( GetWeaponModel( "ks23_hook_sp" ) );
	level.gun MoveTo( GetEnt("rope_give","targetname").origin, 0.3 );
	level.gun waittill("movedone");
	level.gun PhysicsLaunch(level.gun.origin, (5, 15, -15) );

	flag_wait("flag_has_rope_gun");

	level.gun Delete();
}

//logic on the AI on the roof handing the harpoon gun off
rope_guy_think()
{
	self magic_bullet_shield();
	self.goalradius = 16;
	self.ignoreall = true;
	self.ignomeme = true;
	self AllowedStances("stand");
	self disable_long_death();

	heli = GetEnt("courtyard_heli", "targetname");
	self aim_at_target(heli);
	
	flag_wait("flag_shoot_rope_guy");
	
	//make them targets
	self stop_magic_bullet_shield();
	self.ignomeme = false;
	self.ignoreall = false;

	wait(1);

	self bloody_death();
}

rope_assistant_think()
{
	self AllowedStances("crouch");

	heli = GetEnt("courtyard_heli", "targetname");
	self SetEntityTarget(heli);

	flag_wait("flag_shoot_rope_guy");
	
	wait(0.2);

	self bloody_death();
}

courtyard_rope_vo()
{
	player = get_players()[0];
	player.animname = "mason";
	
	level.reznov anim_single( level.reznov, "rope_upstairs" );
	
	player anim_single( player, "rope_ready" );

	flag_wait("flag_shoot_rope_guy");
	
	level.reznov anim_single( level.reznov, "rope_harpoon" );

	flag_wait( "flag_has_rope_gun" );

	level.reznov anim_single( level.reznov, "rope_choose" );

	//level.reznov anim_single( level.reznov, "rope_fire" );

}

//**************
// AUDIO
//**************

play_cart_movement_audio()
{
    self PlaySound( "evt_omaha_cart_start" );
    self PlayLoopSound( "evt_omaha_cart_loop", 1 );
    
    self thread play_cart_randoms();
    
    self waittill( "movedone" );
    
    self PlaySound( "evt_omaha_cart_end" );
    self StopLoopSound( .5 );
}

play_cart_randoms()
{
    self endon( "movedone" );
    
    while(1)
    {
        wait( RandomIntRange( 3, 11 ) );
        self PlaySound( "evt_omaha_cart_randoms" );
    }
}

omaha_drone_vox()
{
    level endon( "stop_omaha_drones" );
    
    level waittill( "start_omaha_drones" );

    while(1)
    {
        level notify( "force_stop_old_drone_vox" );
        
        player_org = get_players()[0].origin;
    
        //Grab all the drones then get the closest 3   
        omaha_drones = GetEntArray( "omaha_drone", "script_noteworthy" );
        
        if( IsDefined( omaha_drones[1] ) )
            omaha_drones[1] PlayLoopSound( "amb_vox_group_running_0" );
        
        closest = get_array_of_closest( player_org, omaha_drones, undefined, 1, 750 );
        
        array_thread( closest, ::play_omaha_drone_vox );
        
        wait(2.5);
    }
}

//Self = Omaha Drone
play_omaha_drone_vox()
{
    level endon( "force_stop_old_drone_vox" );
    self endon( "death" );
    
    while(1)
    {
        self PlaySound( "vox_fake_friendly_dds", "sounddone" );
        self waittill( "sounddone" );
        wait(RandomFloatRange(.5,2));
    }
}

play_omaha_drone_death_vox( guy )
{ 
    last_origin = undefined;
    
    while( IsAlive( self ) )
    {
        last_origin = self.origin;
        wait(.25);
    }
    wait(RandomFloatRange(0,2));
    playsoundatposition( "dds_ru" + guy + "_death", last_origin );
}

delete_sound_ent()
{
    flag_wait( "tower_done" );
    wait(2);
    self stoploopsound(1);
    playsoundatposition ("wpn_50cal_fire_loop_ring_npc", self.origin);
    wait(1);
    self Delete();
}

play_truck_arrival_audio()
{
    front = self GetTagOrigin( "tag_engine_left" );
    ent1 = Spawn( "script_origin", front );
    ent1 LinkTo( self, "tag_engine_left" );
    ent1 PlayLoopSound( "veh_truck_front_courtyard_special" );
    self waittill( "reached_end_node" );
    ent1 StopLoopSound( .25 );
    playsoundatposition( "veh_truck_stop", ent1.origin );
    wait(3);
    ent1 Delete();
}

play_fire_sound( origin )
{
    ent = Spawn( "script_origin", origin );
    ent PlayLoopSound( "amb_mine_fire" );
    level waittill("slingshot_roof_done");
    ent Delete();
}

play_rope_taut_sound()
{
    flag_wait("flag_heli_hit");
    wait(2);
    playsoundatposition( "evt_helo_rope_tighten", (0,0,0) );
}


