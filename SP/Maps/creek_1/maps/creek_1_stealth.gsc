#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;
#include maps\creek_1_util;
#include maps\_music;

#using_animtree ("generic_human");

main()
{
	// MISC SETUP //////////////////////////////////////////////////////////////////////////

	flag_set( "beat_2_starts" );	
	clientNotify( "beat_2_starts" );
	
	level thread change_underwater_fog_at_hey_charlie();
	
	//level thread delayed_autosave_start(); //cant save in h20 - jc
	
	array_thread( GetEntArray("beat2_ridge1_vc_top1", "script_noteworthy"), ::add_spawn_function, ::beat2_ridge1_vc1_actions );
	array_thread( GetEntArray("beat2_ridge1_vc_top2", "script_noteworthy"), ::add_spawn_function, ::beat2_ridge1_vc2_actions );


	array_thread( GetEntArray( "beat2_river1_battle", "targetname" ), ::add_spawn_function, ::periodic_charger );
	array_thread( GetEntArray( "beat2_ridge1_backup_spawners", "targetname" ), ::add_spawn_function, ::periodic_charger );
	
	// set teh correct visionsets
	level maps\_swimming::set_default_vision_set( "creek_1" );
	level maps\_swimming::set_swimming_vision_set( "creek_1_water" );
	
	// set default start (occurs if the player did not come here directly with skipto)
	if( !isdefined( level.skipped_to_event_2 ) || level.skipped_to_event_2 == false )
	{		
		level.section2 = "start";
		teleport_ai_single( "hudson", "b2_hudson_start" );
	}
	
	// animate floating stuff (probably should do this earlier, like at the start of level)
	level thread setup_floating_objects(); 
	
	level thread wait_for_player_at_gap();
	
	level thread maps\creek_1_anim::prepare_water_gate_idle(); 

	// objectives
	level thread beat_2_objectives();
	
	level thread kill_jungle_ais_later();
	
	// slow down player during certain areas
	player = get_players()[0];
	player thread set_speed_limit_zones( "b2_river_walk_speed", "ready_to_call_event_3", true );
	
	// livestock 
	level thread beat_2_critters();
	
	level thread additional_reznov_vo();
	
	level.barnes hold_fire();
	level.reznov hold_fire();
	level.hudson hold_fire();
	level.barnes.goalradius = 16;
	level.reznov.goalradius = 16;
	level.hudson.goalradius = 16;
	
	// drop player into water
	level thread push_player_downwards( undefined, "player_drops_into_water" );
	level thread push_player_downwards( "b2_stealth_trigger_7b" );

	// Move reznov to shore, who will fight upon flag "beat2_ridge1_start"
	level thread beat2_reznov_teleport_to_shore(); 
	
	// when player gets on shore, Woods prepares to fight and sets "beat2_ridge1_start"
	level thread beat2_river_walk_start(); 
	
	// spawns enemies at "beat2_ridge1_start", when all dead sets "beat2_ridge1_clear"
	level thread beat2_ridge1_fight(); 

	
	player = get_players()[0];
	player AllowMelee( true );
	player GiveWeapon( "knife_sp", 0 );

	// animate first frame
	actual_door = getent( "regroup_hut_door_model", "targetname" );
	actual_door.animname = "regroup_gate";
	anim_node = getstruct( "anim_b2_regroup_hut_new", "targetname" );
	level thread maps\creek_1_anim::play_creek_object_anim_firstframe( actual_door, anim_node, "open" );

	
	// MOMENTS //////////////////////////////////////////////////////////////////////////////
	
	if( level.section2 == "start" )
	{
		//level thread play_snake_anim();
		level thread setup_section_1_vcs();
		level thread take_and_give_back_player_weapons( "trigger_give_knife" );
		level thread stealth_water_reveal();	// Player emerges from water
		level thread stealth_sampan_kill();		// Kill 2 VCs on sampan // -- PRESS DEMO 4-19 HACK: NO VC ON SAMPAN FOR DEMO
		level thread stealth_hut_kill();			// Kill 2 VCs in a hut // -- PRESS DEMO 4-19 HACK: NO VC ON SAMPAN FOR DEMO
		level thread stealth_evade_window();	// evade pass the window VC
		level thread clean_up_section_1_vcs();
		level.section2 = "continue";
	}

	if( level.section2 == "2b" || level.section2 == "continue" )
	{
		level thread setup_section_2_vcs();
		level thread stealth_surprise_vc();		// kill the surprise VC
		level thread stealth_bridge_vc();			// 2 VCs on bridge killed
		level thread stealth_dive_under();		// dive under the boats to evade vc
		level thread stealth_hut_regroup();		// meet up in the hut
		level thread clean_up_section_2_vcs();
		level.section2 = "continue";
	}
	
	level thread beat2_hey_charlie_disable_weapons();
	
	level thread notify_when_player_can_melee();
	/*
	
	level thread play_intro_sequence();
	//level thread island_hut_encounter();
	
	level thread main_hut_regroup();
	*/
	
	// TODO: Remove this after demo.  DSL

	level.overrideActorDamage = ::Callback_DemoActorDamage;	
	
	// This may get called just prior to all event 2 scripting ends, to ensure that 
	// everything in the next beat is setup in advance
	level waittill( "ready_to_call_event_3" );
	level thread maps\creek_1_assault::main();
	
	player = get_players()[0];
	player GiveWeapon( "frag_grenade_sp" );
}

notify_when_player_can_melee()
{
	trigger_wait( "b2_sampan_kill_detected" );

	fails =  GetPersistentProfileVar( 3, 0 );
	should_notify = ( fails > 1 );

	if( should_notify )
	{
		screen_message_create( &"CREEK_1_UNDERWATER" );
		wait( 5 );
		screen_message_delete();
	}
}

delayed_autosave_start()
{
	wait( 3 );
	autosave_by_name( "b2_starts" );	
}

wait_for_player_at_gap()
{
	trigger_wait( "b2_close_to_gap" );
	flag_set( "ready_to_move_from_gap" );
}

beat2_bowman_put_down_weapon( guy )
{
	guy detach( "t5_weapon_ak47_world", "tag_weapon_right" );
	
	guy.temp_ak = spawn( "script_model", guy GetTagOrigin( "tag_weapon_right" ) );
	guy.temp_ak.angles = guy GetTagAngles( "tag_weapon_right" );
	guy.temp_ak SetModel( "t5_weapon_ak47_world" );
	guy.temp_ak useweaponhidetags( "ak47_sp" );
}

beat2_bowman_take_back_weapon( guy )
{
	guy.temp_ak delete();
	guy Attach( "t5_weapon_ak47_world", "tag_weapon_right" );
	guy useweaponhidetags( "ak47_sp" );
}

kill_jungle_ais_later()
{
	trigger_wait( "b2_move_barnes_begin_2" );
	
	ais = getentarray( "b2_ridge_vc_top_ai", "targetname" );
	for( i = 0; i < ais.size; i++ )
	{
		ais[i] ai_suicide();
	}
	
	ais = getentarray( "beat2_ridge1_backup_spawners_ai", "targetname" );
	for( i = 0; i < ais.size; i++ )
	{
		ais[i] ai_suicide();
	}
	
	ais = getentarray( "beat2_river1_battle_ai", "targetname" );
	for( i = 0; i < ais.size; i++ )
	{
		ais[i] ai_suicide();
	}
}

change_underwater_fog_at_hey_charlie()
{
	trigger_wait( "b2_stealth_trigger_1e" );
	player = get_players()[0];
	player clientNotify( "c4_underwater_fog" );
}

additional_reznov_vo()
{
	trigger_wait( "b2_sampan_kill_detected" );
	wait( 3 );
	player = get_players()[0];
	player say_dialogue( "steiner" );
}	

Callback_DemoActorDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	// Allies are unaffected.
	// Damage that will kill is unaffected.
	// Otherwise damage is increased, so next hit should kill.
	
	if(self.team == "allies")
	{
		return iDamage;
	}
	
	if(IsDefined(eAttacker) && eAttacker != get_players()[0])
	{
		return iDamage;	// don't make friendlies do more damage.
	}
	
	if(iDamage > self.health)
	{
		return iDamage;
	}
	
	if(iDamage < (self.health - 5))
	{
		iDamage = self.health - 5;
	}
	
	return iDamage;
}

//---------------------------------------------------------------------------

periodic_charger()
{
	self endon( "death" );	
	
	if( isdefined( self.script_string ) && self.script_string == "charger" )
	{
		// after certain time, they may become rushers
		wait( randomfloat( 16 ) + 8 );
		
		self thread maps\_rusher::rush();
	}
}

play_snake_anim()
{
	trigger_wait( "b2_reveal_player_start_trig" );
	wait( 2 );
	level notify("snakeswim_start");
}

beat_2_critters()
{
	chickens = getentarray( "b2_chicken_group_0", "targetname" );
	for( i = 0; i < chickens.size; i++ )
	{
		chickens[i] thread maps\creek_1_livestock::start_critter_anims( "chicken", true, 120, undefined, undefined, undefined, "bridge_kill" );
	}
}

beat_2_objectives()
{
	explosive_charge = getent( "b2_satchel", "targetname" );
	explosive_charge hide();
	explosive_charge_2 = getent( "b2_satchel_2", "targetname" );
	explosive_charge_2 hide();
	explosive_charge_2_obj = getent( "b2_satchel_old_2", "targetname" );
	explosive_charge_2_obj hide();
	
	// once the enemies are all dead
	flag_wait( "b1to2_path_1_passed" );
	
	
	// follow woods
	Objective_Add( 1, "current", &"CREEK_1_RENDEZVOUS", level.barnes );
	Objective_Set3D( 1, true, "yellow", &"CREEK_1_FOLLOW" );

	// at the gap, add a new obj to kill the sampan VCs
	trigger_wait( "b2_reveal_player_start_trig" );
	pos_struct = getstruct( "b2_obj_2", "targetname" );
	Objective_Add( 2, "current", &"CREEK_1_KILL_BOAT_VC", pos_struct.origin );
	Objective_AdditionalCurrent( 1 );
	Objective_Set3D( 1, false );
	Objective_Set3D( 2, true, "yellow" );
	
	// VC sampan killed
	level waittill( "stealth_sampan_action_start" );
	Objective_Set3D( 2, false );
	Objective_State( 2, "done" );
	Objective_Delete( 2 );
	
	// back to follow Woods
	level waittill( "stealth_sampan_complete" );
	level.vc_stealth_killed++; // this counts as a knife kill guaranteed
	Objective_Set3D( 1, true, "yellow", &"CREEK_1_FOLLOW" );
	
	// regroup starts, the obj to regroup is now done
	trigger_wait( "b2_hut_barnes_move_up" );
	wait( 10 );
	Objective_State( 1, "done" );
	Objective_Set3D( 1, false );
	
	// regroup ends
	flag_wait( "hut_kill_done" );
	Objective_Add( 2, "current", &"CREEK_1_DESTROY_AA", level.barnes );
	Objective_Add( 4, "current",  &"CREEK_1_OBJ_PLANT_EXPLOSIVE", explosive_charge.origin + ( 0, 0, 15 ) );
	Objective_Set3D( 4, true, "yellow" );
	Objective_AdditionalCurrent( 2 );
	
	level thread explosive_trigger_hint_press();
	level thread c4_set_nag_lines( 20, "explosive_set" );

	level waittill( "explosive_set" );
	old_model = getent( "b2_satchel_old", "targetname" );
	old_model delete();
	maps\creek_1_anim::play_player_setting_bomb_anim( explosive_charge );
	
	island_blocker = getent( "b2_block_island_get_up", "targetname" );
	island_blocker delete();
	flag_set( "bomb_1_set" );
	
	Objective_State( 4, "done" );
	Objective_Delete( 4 );
	
	// follow woods again
	Objective_Set3D( 2, true, "yellow", &"CREEK_1_FOLLOW" );
	
	// when player gets close to rice guy, prompt to kill him
	flag_wait( "approaching_rice_eating_guy" );
	Objective_Position( 2, level.vc_rice );
	Objective_Set3D( 2, false );
	Objective_Set3D( 2, true, "yellow" );
	
	// when the rice guy is dead we don't need obj star for a bit
	level waittill( "rice_vc_action_complete" );
	Objective_Set3D( 2, false );
	
	// at this point, the player may drop down early
	level thread obj_player_does_not_drop_early( explosive_charge_2 );
	level thread obj_player_does_drop_early( explosive_charge_2 );
	
	level waittill( "explosive_set_2" );
	Objective_State( 4, "done" );
	Objective_Delete( 4 );
	
	ladder_struct = getstruct( "anim_b2_falling_guy", "targetname" );
	Objective_Position( 2, ladder_struct.origin );
	Objective_Set3D( 2, true, "yellow" );
	
	trigger_wait( "b2_stealth_trigger_8_ladder" );
	Objective_Position( 2, level.barnes );
	Objective_Set3D( 2, true, "yellow", &"CREEK_1_FOLLOW" );
}

obj_player_does_not_drop_early( explosive_charge_2 )
{
	level endon( "players_drops_down_early" );
	level waittill( "woods_stop_talking_split" );

	hole_struct = getstruct( "b2_obj_8", "targetname" );
	Objective_Add( 4, "current",  &"CREEK_1_OBJ_PLANT_EXPLOSIVE", hole_struct.origin );
	Objective_Set3D( 4, true, "yellow" );
	Objective_AdditionalCurrent( 2 );
	
	trigger_wait( "b2_obj_trigger_1" );
	Objective_Position( 4, explosive_charge_2.origin );
}

obj_player_does_drop_early( explosive_charge_2 )
{
	level endon( "woods_stop_talking_split" );
	trigger_wait( "b2_obj_trigger_1" );
	level notify( "players_drops_down_early" );
	
	Objective_Add( 4, "current",  &"CREEK_1_OBJ_PLANT_EXPLOSIVE", explosive_charge_2.origin );
	Objective_Set3D( 4, true, "yellow" );
	Objective_AdditionalCurrent( 2 );
}
	
	
explosive_trigger_hint_press()
{
	level endon( "explosive_set" );
	use_trigger = getent( "b2_satchel_set", "targetname" );
	level thread explosive_trigger_press( use_trigger );
	player = get_players()[0];
	while( 1 )
	{
		while( 1 )
		{
			if( player istouching( use_trigger ) )
			{
				break;
			}
			wait( 0.05 );
		}	
		player = get_players()[0];
		player SetScriptHintString( &"CREEK_1_HINT_PLANT_CHARGE" );
		//screen_message_create( &"CREEK_1_HINT_PLANT_CHARGE" );
		while( 1 )
		{
			if( player istouching( use_trigger ) == false )
			{
				break;
			}
			wait( 0.05 );
		}	
		player SetScriptHintString( "" );
		//screen_message_delete();
	}
}

explosive_trigger_press( trigger )
{
	player = get_players()[0];
	while( 1 )
	{
		while( player use_button_held() == false )
		{
			wait( 0.05 );
		}
		if( player istouching( trigger ) )
		{
			level notify( "explosive_set" );
			level thread plant_sound();
			trigger delete();
			player = get_players()[0];
			player SetScriptHintString( "" );
			//screen_message_delete();
			return;
		}
		wait( 0.05 );
	}
}

explosive_trigger_hint_press_2()
{
	level endon( "explosive_obj_fail" );
	level endon( "explosive_set_2" );
	use_trigger = getent( "b2_satchel_set_2", "targetname" );
	level thread explosive_trigger_press_2( use_trigger );
	player = get_players()[0];
	while( 1 )
	{
		while( 1 )
		{
			if( player istouching( use_trigger ) )
			{
				break;
			}
			wait( 0.05 );
		}	
		player = get_players()[0];
		player SetScriptHintString( &"CREEK_1_HINT_PLANT_CHARGE" );
		//screen_message_create( &"CREEK_1_HINT_PLANT_CHARGE" );
		while( 1 )
		{
			if( player istouching( use_trigger ) == false )
			{
				break;
			}
			wait( 0.05 );
		}	
		player SetScriptHintString( "" );
		//screen_message_delete();
	}
}

explosive_trigger_press_2( trigger )
{
	level endon( "explosive_obj_fail" );
	
	player = get_players()[0];
	while( 1 )
	{
		while( player use_button_held() == false )
		{
			wait( 0.05 );
		}
		if( player istouching( trigger ) )
		{
			level notify( "explosive_set_2" );
			level thread plant_sound();
			trigger delete();
			player = get_players()[0];
			player SetScriptHintString( "" );
			//screen_message_delete();
			return;
		}
		wait( 0.05 );
	}
}

objective_follow_barnes_custom( obj_num )
{
	level endon( "stop_following_barnes_obj" );
	
	// try to display objectve 3d always above Barnes' head
	align_tag = "J_NECK";
	offset = ( 0, 0, 26 );
	
	while( 1 )
	{
		pos = level.barnes GetTagOrigin( align_tag );
		pos += offset;
		Objective_Position( obj_num, pos );
		wait( 0.05 );
	}
}

take_and_give_back_player_weapons( trigger_name )
{
	if( isdefined( trigger_name ) )
	{
		trigger_wait( trigger_name );
	}
	
	// iprintlnbold( "Keep quiet. Put away your weapons. Knife only" );
	// level thread beat2_knife_memories_dialogue();
	
	players = get_players();
	// players[0] take_player_weapons();
	
	weapon_inventory = players[0] GetWeaponsList();
	current_weapon = weapon_inventory[0];
	ammo_clip = players[0] GetWeaponAmmoClip( current_weapon );
	ammo_stock = players[0] GetWeaponAmmoStock( current_weapon );
	
	players[0] TakeAllWeapons();
	players[0] GiveWeapon( "creek_knife_sp", 0 );
	players[0] GiveWeapon( "knife_creek_sp", 0 );

	players[0] GiveWeapon( current_weapon );
	players[0] SetWeaponAmmoClip( current_weapon, ammo_clip );
	players[0] SetWeaponAmmoStock( current_weapon, ammo_stock );
	
	players[0] SwitchToWeapon( "creek_knife_sp" );
	
	players[0] thread hack_to_switch_melee_weapons();
}

hack_to_switch_melee_weapons()
{
	level endon( "player_gets_commando" );
	
	current_weapon = self GetCurrentWeapon();
	while( 1 )
	{
		// wait for player to change weapon
		weapon_changed = false;
		new_weapon = self GetCurrentWeapon();
		if( new_weapon != current_weapon )
		{
			current_weapon = new_weapon;
			weapon_changed = true;
		}
		
		if( weapon_changed )
		{
			if( current_weapon == "creek_knife_sp" )
			{
				self TakeWeapon( "knife_sp" );
				self GiveWeapon( "knife_creek_sp", 0 );
			}
			else if( current_weapon == "knife_creek_sp" || current_weapon == "knife_sp" )
			{
				// don't need to do anything
			}
			else
			{				
				self TakeWeapon( "knife_creek_sp" );
				self GiveWeapon( "knife_sp", 0 );
			}
		}
		
		wait( 0.05 );
	}
}

//---------------------------------------------------------------------------

setup_section_1_vcs()
{
	// -- PRESS DEMO 4-19 HACK: DON'T SPAWN THE VC ON THE SAMPAN -- ////////////////////////
	level.vc_sampan_1 = simple_spawn_single( "b2_vc_sampan_1", ::vc_stealth_kill_ignoreall );
	level.vc_sampan_1.animname = "b2_vc_sampan_1";
	level.vc_sampan_2 = simple_spawn_single( "b2_vc_sampan_2", ::vc_stealth_kill_ignoreall );
	level.vc_sampan_2.deathanim = %exposed_death_headshot;
	level.vc_sampan_2.animname = "b2_vc_sampan_2"; 
	// level.vc_sampan_2 thread player_dive_text_instruction(); // -- WWILLIAMS: REMOVED BECAUSE B FUNCTIONALITY IN THE WATER HAS BEEN REMOVED.
	
	
	linker = getent( "anim_b2_sampan_temp", "targetname" );
	level thread maps\creek_1_anim::player_takedown_sampan_vc();
	//level.vc_sampan_2 contextual_melee( "creeksampanmelee", "scripted" );
	// -- PRESS DEMO 4-19 HACK: DON'T SPAWN THE VC ON THE SAMPAN -- ////////////////////////
	
	level.vc_hut_1 = simple_spawn_single( "b2_vc_hut_1", ::vc_stealth_kill_ignoreall );
	level.vc_hut_2 = simple_spawn_single( "b2_vc_hut_2", ::vc_stealth_kill_ignoreall );
	// level thread maps\creek_1_anim::b2_hut_kills_vc_reach(); // -- WWILLIAMS: REMOVING THIS TO SETUP THE NEW OPENING HUT ANIMS
	// beat2_hey_charlie_loop( anim_node, str_animation1, str_animation2 )
	anim_node = getstruct( "b2_huts_anim_node_2", "targetname" );
	anim_node thread anim_loop_aligned( level.vc_hut_1, "hey_charlie_idle" );
	anim_node thread anim_loop_aligned( level.vc_hut_2, "hey_charlie_idle" );
	
	//level.vc_chef_1 = simple_spawn_single( "b2_vc_chef_1", ::vc_stealth_kill_ignoreall );
	//level.vc_chef_2 = simple_spawn_single( "b2_vc_chef_2", ::vc_stealth_kill_ignoreall );
	level.vc_sleeping_1 = simple_spawn_single( "b2_vc_sleeping_1", ::vc_stealth_kill_sleeping_1 );
	level.vc_sleeping_2 = simple_spawn_single( "b2_vc_sleeping_2", ::vc_stealth_kill_sleeping_2 );
	level.vc_sleeping_1 disable_pain();
	level.vc_sleeping_2 disable_pain();
	level.vc_sleeping_1.script_nodropweapon = true;
	level.vc_sleeping_2.script_nodropweapon = true;
	
	//level.vc_chef_1 thread maps\creek_1_anim::b2_talking_chef();
	//level.vc_chef_2 thread maps\creek_1_anim::b2_talking_chef_hack();
	
	// the anim is done by Lewis and redshirt
	level.b2_redshirt = simple_spawn_single( "b2_redshirt" );
	level.b2_redshirt.ignoreall = true;
	level.b2_redshirt.goalradius = 16;
	level.b2_redshirt.health = 99999;
	level.b2_redshirt.animname = "marine_redshirt";
	level.b2_redshirt.targetname = "marine_redshirt";
	// level.b2_redshirt thread beat2_hey_charlie_loop( getstruct( "b2_huts_anim_node_2", "targetname" ), "hey_charlie_idle", "hey_charlie" );
	// level.b2_redshirt thread beat2_just_hey_charlie_for_the_squad( getstruct( "b2_huts_anim_node_2", "targetname" ) );
	// level.hudson thread beat2_hey_charlie_loop( getstruct( "b2_huts_anim_node_2", "targetname" ), "hey_charlie_idle", "hey_charlie" );
	
	chicken = getent( "b2_chicken_island", "targetname" );
	chicken delete();
	//chicken thread maps\creek_1_livestock::start_critter_anims( "chicken", true, 50, "b2_chicken_island_trigger" );
	
	// level thread hide_reznov();
	// 4-19 DEMO FADE OUT ////////////////////////////////////////////////////////////////////////////////
	level.hudson Hide();
	level.hudson_no_backpack = simple_spawn_single( "spwn_bowman_nobackpack" );
	level.hudson_no_backpack.targetname = "hudson_no_backpack";
	level.hudson_no_backpack.animname = "hudson_no_backpack";
	level.hudson_no_backpack.ignoreall = 1;
	level.hudson_no_backpack.ignoreme = 1;
	level.hudson_no_backpack thread magic_bullet_shield();
	level.hudson_no_backpack.name = "Bowman";
	// level.hudson_no_backpack thread beat2_hey_charlie_loop( getstruct( "b2_huts_anim_node_2", "targetname" ), "hey_charlie_idle", "hey_charlie" );
	// level.hudson_no_backpack thread beat2_just_hey_charlie_for_the_squad( getstruct( "b2_huts_anim_node_2", "targetname" ) );
	// 4-19 DEMO FADE OUT ////////////////////////////////////////////////////////////////////////////////
}


hide_reznov()
{
	teleport_node = getstruct( "hide_reznov", "targetname");
	level.reznov forceteleport( teleport_node.origin, teleport_node.angles );		
}

clean_up_section_1_vcs()
{
	trigger_wait( "b2_stealth_trigger_7b" );
	level notify( "cleaning_up_beat_2" );
	wait( 0.05 );
	
	if( isdefined( level.vc_sleeping_1 ) )
	{
		level.vc_sleeping_1 delete();
	}
	if( isdefined( level.vc_sleeping_2 ) )
	{
		level.vc_sleeping_2 delete();
	}

	//level.vc_chef_1 delete();
	//level.vc_chef_2 delete();
	level.b2_redshirt delete();
}

vc_stealth_kill_ignoreall()
{
	self.ignoreall = 1;
	self.goalradius = 16;
}

vc_stealth_kill_sleeping_1()
{
	self thread vc_stealth_kill_ignoreall();
	self.health = 100000;
	self thread maps\creek_1_anim::b2_sleeping_vc( "hammock_l", "b2_vc_sleeping_2_ai" );
	self thread vc_snoring_1();
}

vc_stealth_kill_sleeping_2()
{
	self thread vc_stealth_kill_ignoreall();
	self.health = 100000;
	self thread maps\creek_1_anim::b2_sleeping_vc( "hammock_r", "b2_vc_sleeping_1_ai" );
	self thread vc_snoring_2();
}

//---------------------------------------------------------------------------

stealth_water_reveal()
{
	// Barnes tells the player to dive through a gap. He follows and shows up on the other side.
	
	level thread maps\creek_1_anim::barnes_intro_swim(); // -- WWILLIAMS: PRESS DEMO 4-19 HACK. KEEPS THE WEAPONS FROM BEING REMOVED
	//level.barnes go_to_node_by_name( "b2_barnes_reveal_node" );
	//level.barnes waittill( "gap_reached" );
	trigger_wait( "b2_close_to_gap" );
	level thread vo_barnes_dive_gap(); // -- WWILLIAMS: PRESS DEMO 4-19 HACK. REMOVE BARNES'S LINES AT GAP
}


vo_barnes_dive_gap()
{
	if( flag( "knife_only_starts" ) )
	{
		wait( 1 );
		level.barnes say_dialogue( "shh_vc" );
	}
	wait( 1 );

	level.vc_sampan_1 endon( "death" );
	level.vc_sampan_2 endon( "death" );
	level endon( "sampan_searches_for_player" );
	level endon( "stealth_sampan_action_start" );
	
	level.vc_sampan_1 say_dialogue( "catch_anything" );
	level.vc_sampan_2 say_dialogue( "not_biting_today" );
	level.vc_sampan_1 say_dialogue( "but_for_me" );
}


//---------------------------------------------------------------------------

stealth_sampan_kill()
{
	player = get_players()[0];
	// Barnes and player drag 2 VCs down from a sampan and kill them
	level waittill( "reveal_anim_done" );
		
	//level.barnes go_to_node_by_name( "b2_barnes_drag_sampan_node" );
	//level.barnes waittill( "goal" );
	//iprintlnbold( "Barnes signals player to act" );
	
	//trigger_wait( "b2_drag_vc_in_water" );
	//level waittill( "player_close_enough_to_sampan" );
	
	level thread detect_player_melee_sampan_button();
	level waittill( "stealth_sampan_action_start" );
	level thread stealth_sampan_musicstate();
	//level.vc_sampan_2 unlink();
	//level.vc_sampan_2 notify("start_scripted_melee", get_players()[0]);
	player waittill( "melee_done" );
	//level.vc_sampan_2 unlink();
	//level.vc_sampan_1 ai_suicide();
	//level.vc_sampan_2 ai_suicide();
	//iprintlnbold( "Player drags a VC into water and kills him" );

	level notify( "stealth_sampan_complete" );
	
	// temp, teleport player and Barnes
	//wait( 1 );
	//teleport_ai_single( "barnes_ai", "b2_sampan_kill_barnes_end" );
	//teleport_first_player( "b2_sampan_kill_player_end" );
	
	//autosave_by_name( "creek_1_sampan_complete" );
}

stealth_sampan_musicstate()
{
	//level waittill ("stealth_sampan_action_start");	
	setmusicstate("BOAT_KILL");
}

detect_player_melee_sampan_button()
{
	level endon( "stealth_sampan_action_fail" );
	level endon( "stealth_sampan_action_fail_water" );

	drag_trigger = getent( "b2_drag_vc_in_water", "targetname" );
	// player has to be within this range
	message_displayed = false;
	player = get_players()[0];
	while( 1 )
	{
		//distance_player = distance( level.vc_sampan_2.origin, player.origin );
		if( player istouching( drag_trigger ) == true && message_displayed == false )
		{
			player = get_players()[0];
			player SetScriptHintString( &"CREEK_1_PRESS_L3" );
			//screen_message_create( &"CREEK_1_PRESS_L3" );
			message_displayed = true;
		}
		else if( player istouching( drag_trigger ) == false && message_displayed == true )
		{
			player = get_players()[0];
			player SetScriptHintString( "" );
			//screen_message_delete();
			message_displayed = false;
		}
		
		if( message_displayed == true && player meleeButtonPressed() == true )
		{
			level notify( "stealth_sampan_action_start" );
			player = get_players()[0];
			player SetScriptHintString( "" );
			//screen_message_delete();
			return;
		}

		wait( 0.05 );
	}
}

//---------------------------------------------------------------------------

stealth_hut_kill()
{
	anim_node = getstruct( "anim_b2_dock", "targetname" );
	
	level waittill( "barnes_starts_swimming_early" );
	//level waittill( "stealth_sampan_complete" );
	
	level thread maps\creek_1_anim::barnes_swim_sampan_to_dock();
	level waittill( "barnes_swim_to_dock_done" );
	
	//level.barnes go_to_node_by_name( "b2_barnes_hut_kill_node" );
	
	// -- TODO: MOVE WOODS FORWARD AGAIN AT THIS POINT
	trigger_wait( "b2_hut_barnes_move_up" );
	//flag_set( "b2_hut_barnes_move_up" );
	//flag_set( "start_hey_charlie" );
	
	// player switch to knife here
	player = get_players()[0];
	player SwitchToWeapon( "creek_knife_sp" );
	
	//TUEY Set music state to TENSION
	setmusicstate("TENSION");
	
	level thread beat2_4_19_press_demo_move_barnes_2_hey_charlie();
	level thread beat2_4_19_press_demo_move_reznov_2_hey_charlie(); 
	
	//level thread beat2_move_woods_up_to_start();
	
	// trigger_wait( "b2_player_enters_hut" );
	// flag_set( "start_hey_charlie" );  
	
	//level thread beat2_woods_animates_hey_charlie();
	
	// -- TODO: ONCE WOODS IS IN POSITION START NEW ANIM
	flag_wait( "hut_kill_done" );
	
	// level thread maps\creek_1_anim::b2_hut_kills();
	// level waittill( "hut_kill_done" );
	
	autosave_by_name( "creek_1_shchkd" );
	
	//Tuey setting music state to stealth...
	setmusicstate("VILLAGE_STEALTH");
	
	// move those 2 out of the way
	// -- WWILLIAMS: MOVED THE GOAL SEND ON THE B2_REDSHIRT TO beat2_redshirt_blocks_exit IN ANIM
	// level.hudson go_to_node_by_name( "b2_hudson_hut_teleport_node" );
}

beat2_hey_charlie_loop( anim_node, str_animation1, str_animation2 ) // -- WWILLIAMS: RUNS ON BOWMAN AND REDSHIRT
{
	self endon( "death" );
	
	
	// self ent_flag_init( "hey_charlie_complete" );
	
	/*
	while( 1 )
	{
		anim_node anim_single_aligned( self, str_animation1 );
		
		if( flag( "start_hey_charlie" ) ) // flag_init( "start_hey_charlie" );
		{
			break;
		}
	}
	*/
	
	// play hey charlie animation
	if( self.targetname == "hudson_no_backpack" )
	{
		//level thread beat2_hey_charlie_backpack_animation(); // -- WWILLIAMS: BOWMAN'S BACKPACK ANIMATION
	}
	anim_node anim_single_aligned( self, str_animation2 );
	
	// -- WWILLIAMS: PUT HUDSON/BOWMAN BACK TO NORMAL MODEL
	if( self.animname == "b2_vc_hut_1" )
	{
		anim_node anim_loop_aligned( self, "hey_charlie_death_loop" );
		self.activatecrosshair = false;
	}
	else if( self.animname == "b2_vc_hut_2" )
	{
		self delete();
	}
	else if( self.targetname == "hudson_no_backpack" )
	{
		self Delete();
		// should clean up this version of bowman and show the normal version
		level.hudson Show();
	}
	 
}

beat2_just_hey_charlie_for_the_squad( anim_node ) // -- WWILLIAMS: RUNNING THE SQUAD THROUGH A DIFFERENT FUNC FOR HEY CHARLIE
{
	//self Hide();
	
	anim_node anim_teleport( self, "hey_charlie" );
	
	//flag_wait( "start_hey_charlie" );
	
	self Show();
	
	// play hey charlie animation
	if( self.targetname == "hudson_no_backpack" )
	{
		//level thread beat2_hey_charlie_backpack_animation(); // -- WWILLIAMS: BOWMAN'S BACKPACK ANIMATION
	}
	anim_node anim_single_aligned( self, "hey_charlie" );
	
	if( self.targetname == "hudson_no_backpack" )
	{
		self thread stop_magic_bullet_shield();
		
		self Delete();
	}
	else if( self == level.b2_redshirt )
	{
		// temp
		node = getnode( "b2_reznov_stealth_node_3", "targetname" );
		self SetGoalNode( node );
		//self setgoalpos( self.origin );
	}
}

beat2_hey_charlie_disable_weapons() // -- WWILLIAMS: PLAYER HAS NO WEAPONS DISPLAYING DURING HEY CHARLIE
{
	trigger_wait( "b2_reveal_player_start_trig" );
	
	players = get_players();
	players[0] DisableWeapons();
	//players[0] AllowMelee( false );
	
	flag_wait( "hut_kill_done" );
	
	players = get_players();
	players[0] EnableWeapons();
	players[0] AllowMelee( true );
}

beat2_move_woods_up_to_start() // -- WWILLIAMS: MOVE WOODS AHEAD TO THE START POSITION
{
	anim_node = getstruct( "b2_huts_anim_node_2", "targetname" );
	
	//level.barnes thread say_dialogue( "quiet" );
	//anim_node anim_single_aligned( level.barnes, "hey_charlie_approach" );
	
	flag_set( "start_hey_charlie" );
	
	/* while( 1 )
	{
		anim_node anim_single_aligned( level.barnes, "hey_charlie_approach_idle_loop" );
		
		if( flag( "start_hey_charlie" ) )
		{
			break;
		}
	} */ 
	
	level thread delayed_delete_hey_charlie_clips();
}

delayed_delete_hey_charlie_clips()
{
	wait( 0.5 );
	blocker = getent( "hey_charlie_blocker", "targetname" );
	blocker delete();
	wait( 3.5 );
	blocker = getent( "hey_charlie_blocker_x", "targetname" );
	blocker delete();
}

beat2_attach_knife_to_woods_hand( guy )
{
	level.barnes gun_remove();
	
	guy Attach( "t5_knife_animate", "TAG_WEAPON_LEFT", true );
}

beat2_detach_knife_from_woods_hand( guy )
{
	guy Detach( "t5_knife_animate", "TAG_WEAPON_LEFT" );
	
	level.barnes gun_recall();
}

beat2_give_woods_back_a_gun( guy )
{
	// put woods gun back on him
	level.barnes gun_recall();
}

beat2_bowman_attach_knife( guy ) // -- WWILLIAMS: GIVE BOWMAN A KNIFE FOR HEY CHARLIE
{
	level.bowman_knife = Spawn( "script_model", guy GetTagOrigin( "TAG_WEAPON_LEFT" ) );
	level.bowman_knife.angles = guy GetTagAngles( "TAG_WEAPON_LEFT" );
	level.bowman_knife Hide();
	level.bowman_knife SetModel( "t5_knife_animate" );
	guy Attach( "t5_knife_animate", "TAG_WEAPON_LEFT" );
	level.bowman_knife Show();
}

beat2_bowman_delete_knife( guy ) // -- WWILLIAMS: DELETE BOWMAN'S KNIFE AFTER KILL IN HEY CHARLIE
{
	guy Detach( "t5_knife_animate", "TAG_WEAPON_LEFT" );
	guy useweaponhidetags( "ak47_sp" );
}

/*
beat2_bowman_attach_c4( guy ) // -- WWILLIAMS: SPAWN C4 IN BOWMAN'S HAND HEY CHARLIE
{
	level.bowman_c4 = Spawn( "script_model", guy GetTagOrigin( "TAG_INHAND" ) );
	level.bowman_c4.angles = guy GetTagAngles( "TAG_INHAND" );
	level.bowman_c4 SetModel( "weapon_c4" );
	guy Attach( "weapon_c4", "TAG_INHAND" );
}

beat2_bowman_delete_c4( guy ) // -- WWILLIAMS: REMOVE BOWMAN C4 DURING HEY CHARLIE
{
	guy Detach( "weapon_c4", "TAG_INHAND" );
	
	level.bowman_c4 Delete();
}
*/

beat2_woods_animates_hey_charlie() // -- WWILLIAMS: WOODS GOES THROUGH HIS ANIM FOR HEY CHARLIE
{
	anim_node = getstruct( "b2_huts_anim_node_2", "targetname" );
	
	anim_node anim_single_aligned( level.barnes, "hey_charlie" );
	//level.barnes thread beat2_detach_knife_from_woods_hand( level.barnes );
	
	flag_set( "hut_kill_done" );
	level notify( "take_slienced_weapons_obj" );
}

beat2_reznov_during_hey_charlie() // -- WWILLIAMS: REZNOV'S ANIMATION DURING HEY CHARLIE
{
	anim_node = getstruct( "b2_huts_anim_node_2", "targetname" );
	
	level.reznov Hide();
	
	anim_node anim_teleport( level.reznov, "hey_charlie" );
	
	flag_wait( "start_hey_charlie" );
	
	level.reznov Show();
	
	anim_node anim_single_aligned( level.reznov, "hey_charlie" );
}

/*
#using_animtree ("creek_1");
beat2_hey_charlie_backpack_animation() // -- WWILLIAMS: PLAYS THE ANIMATION FOR BOWMAN'S BACKPACK
{
	anim_node = getstruct( "b2_huts_anim_node_2", "targetname" );
	level.bowman_backpack = GetEnt( "mdl_bowman_packback", "targetname" );
	level.bowman_backpack.animname = "hudson_backpack";
	level.bowman_backpack SetModel( "c_usa_jungmar_wet_bowman_backpack" );
	
	level.bowman_backpack UseAnimTree( #animtree );

	
	anim_node anim_single_aligned( level.bowman_backpack, "hey_charlie" );
	
	level.bowman_backpack Delete();
}
*/

#using_animtree ("generic_human");
// if player fires with a loud weapon, fail him
stealth_fail_with_noise()
{
	level endon( "event_2_ends" );
	
	player = get_players()[0];
	while( 1 )
	{
		player waittill( "weapon_fired" );

		/*
		current_weapon = player GetCurrentWeapon();
		if( current_weapon != "commando_silencer_sp" && current_weapon != "knife_creek_sp" && current_weapon != "creek_knife_sp" )
		{
			water_height = GetWaterHeight( player.origin );
			if( isdefined( player._swimming ) && player._swimming.is_swimming == true )
			{
				// do nothing, for now.
			}
			else if( water_height > player.origin[2] )
			{
				// also do nothing here, for now
			}
			else
			{
				wait( 1 );
				//screen_message_create( &"CREEK_1_FAIL_SILENCED" );
				//wait( 1 );
				setdvar( "ui_deadquote", "@CREEK_1_FAIL_SILENCED" );
				stealth_broken();
			}
		}
		*/
		
		setdvar( "ui_deadquote", "@CREEK_1_FAIL_SILENCED" );
		stealth_broken();
	}
}

//---------------------------------------------------------------------------

stealth_evade_window()
{
	//trigger_wait( "b2_player_enters_hut" );
	flag_wait( "hut_kill_done" );
	
	//level.barnes AllowedStances( "crouch" );
	level.barnes enable_cqbwalk();
	
	level thread vo_b2_vc_chef(); // -- WWILLIAMS: COMMENTING THESE VOS OUT FOR PRESS DEMO
	level thread maps\creek_1_anim::barnes_shim_over_window();
	
	level thread maps\creek_1_anim::beat2_bowman_checks_in(); // -- WWILLIAMS: BOWMAN LINE WHEN THE PLAYER GETS OUT OF THE WATER AT COOK HUT
	
	trigger_wait( "b2_stealth_trigger_1e" );

	// move the 2 VCs into position, player must crouch under the window to avoid being seen
	//level thread stealth_fail_window_crouch();
	
	level waittill( "barnes_enters_hut" );
	level.barnes go_to_node_by_name( "node_barnes_hammock_hut" );
	// node_wait_inside_hammock_hut = GetNode( "node_barnes_hammock_hut", "targetname" );
	autosave_by_name( "creek_1_beh" );
	
	flag_wait( "approaching_rice_eating_guy" );
	
	level.barnes go_to_node_by_name( "b2_barnes_curtain_node" );
	level.barnes.disableturns = true;
	
	// when he gets close enough we change his stance
	/*
	end_node = getnode( "b2_barnes_curtain_node", "targetname" );
	while( distance( level.barnes.origin, end_node.origin ) > 150 )
	{
		wait( 0.05 );
	}
	//level.barnes AllowedStances( "stand" );
	*/
	
	level.vc_rice waittill( "death" );
	level.barnes.disableturns = false;
	//level.barnes disable_cqbwalk();
}
/*
stealth_fail_window_crouch()
{
	level endon( "player_failed" );
	level endon( "event_2_ends" );
	level.vc_chef_1 endon( "death" );
	level.vc_chef_2 endon( "death" );
	
	trigger = getent( "b2_crouch_window", "targetname" );
	player = get_players()[0];
	
	while( 1 )
	{
		if( player IsTouching( trigger ) )
		{
			if( player GetStance() == "stand" )
			{
				//iprintlnbold( "VC Sees the player" );
				level.vc_chef_1.ignoreall = false;
				level.vc_chef_2.ignoreall = false;
				level.vc_chef_1 StopAnimScripted();
				level.vc_chef_2 StopAnimScripted();
				
				screen_message_create( &"CREEK_1_FAIL_STANDING" );
				wait( 1 );
				level thread stealth_broken();
			}
		}
		wait( 0.1 );
	}
}
*/
//creek_1_util::say_dialogue( theLine, delay_time )
vo_b2_vc_chef()
{
	level endon( "fly_away_5" );
	
	level waittill( "barnes_starts_window" );
	
	level.temp_vo_origin_pos = spawn( "script_origin", ( -26842.7, 37086, -18 ) );
	level.temp_vo_origin_pos.animname = "b2_vc_chef_1";
	level.temp_vo_origin_pos say_dialogue( "with_no_bait" );
	level.temp_vo_origin_pos.animname = "b2_vc_chef_2";
	level.temp_vo_origin_pos say_dialogue( "doesnt_know" );
	level.temp_vo_origin_pos.animname = "b2_vc_chef_1";
	level.temp_vo_origin_pos say_dialogue( "an_empty_line" );
	level.temp_vo_origin_pos.animname = "b2_vc_chef_2";
	level.temp_vo_origin_pos say_dialogue( "a_little_stupid" );
	level.temp_vo_origin_pos.animname = "b2_vc_chef_1";
	level.temp_vo_origin_pos say_dialogue( "fish_are_smarter" );
	level.temp_vo_origin_pos.animname = "b2_vc_chef_2";
	level.temp_vo_origin_pos say_dialogue( "turn_on_you" );
}

//---------------------------------------------------------------------------

#using_animtree ("generic_human");

setup_section_2_vcs()
{
	// -- WWILLIAMS: 4-19 PRESS DEMO HACK -- DON'T SPAWN UNTIL DURING THE FADE IN
	//flag_wait( "stealth_fade_complete" );
	// -- WWILLIAMS: 4-19 PRESS DEMO HACK -- DON'T SPAWN UNTIL DURING THE FADE IN


	level thread beat2_section2_vc_rice_init();
	level thread beat2_section2_vc_snipe_init();
	level thread beat2_section2_vc_drop_water_init();
	
	level thread maps\creek_1_anim::idle_window_shutters();
}

beat2_section2_vc_rice_init() // -- WWILLIAMS: GUY WHO EATS RICE AND HAS A CONTEXTUAL MELEE KILL
{
	
	level.vc_rice = simple_spawn_single( "b2_vc_rice", ::vc_stealth_kill_ignoreall );
	level.vc_rice.health = 1;
	level.vc_rice.animname = "b2_vc_rice";
	
	level.vc_rice.deathanim = %exposed_death_falltoknees;
}

beat2_section2_vc_snipe_init() // -- WWILLIAMS: WHAT DO THESE GUYS DO?
{
	
	level.vc_snipe_1 = simple_spawn_single( "b2_vc_sniped_1", ::vc_stealth_kill_ignoreall );
	level.vc_snipe_2 = simple_spawn_single( "b2_vc_sniped_2", ::vc_stealth_kill_ignoreall );
	//level.vc_snipe_3 = simple_spawn_single( "b2_vc_sniped_3", ::vc_stealth_kill_ignoreall );
	level.vc_snipe_1.health = 1;
	level.vc_snipe_2.health = 1;
	//level.vc_snipe_3.health = 1;
	
	//level.vc_snipe_2 AllowedStances( "crouch" );
}

beat2_section2_vc_drop_water_init() // -- WWILLIAMS: AS PLAYER SWIMS UNDER SAMPANS VC FALLS IN TO WATER
{
	level.vc_drop_water = simple_spawn_single( "b2_vc_drop_water", ::vc_stealth_kill_ignoreall );
	level.vc_drop_water.deathanim = %exposed_death;
	level.vc_drop_water set_run_anim( "patrol_walk", true ); 
	level.vc_drop_water.goalradius = 32;
	level.vc_drop_water.disableArrivals = true;
	level.vc_drop_water.disableExits = true;
	level.vc_drop_water.disableTurns = true;
	level.vc_drop_water.ignoreall = true;
}


clean_up_section_2_vcs()
{
	trigger_wait( "trigger_spawn_intro_vcs" );
	
	//level.vc_snipe_1 delete();
	//level.vc_snipe_2 delete();
	
	level thread maps\creek_1_assault::village_livestock_setup();
}

//---------------------------------------------------------------------------

stealth_surprise_vc()
{
	// -- WWILLIAMS: THIS TRIGGER IS BEING REPURPOSED. INSTEAD OF BEING USED FOR THE CURTAIN ANIMATION
	// -- IT WILL BE MOVED TO THE SLEEPING AREA TO START THE SETUP FOR THE VC EATING RICE
	trigger_wait( "b2_curtains_trigger" );
	
	/*
	trigger = getent( "b2_curtains_trigger", "targetname" );
	message_displayed = false;
	player = get_players()[0];
	
	while( 1 )
	{
		if( player istouching( trigger ) && message_displayed == false )
		{
			screen_message_create( &"CREEK_1_OPEN_CURTAIN" );
			message_displayed = true;
		}
		else if( player istouching( trigger ) == false && message_displayed == true )
		{
			screen_message_delete();
			message_displayed = false;
		}
		
		if( message_displayed == true && player useButtonPressed() == true )
		{
			level notify( "stealth_rice_action_start" );
			screen_message_delete();
			break;
		}

		wait( 0.05 );
	}
	*/
	level notify( "stealth_rice_action_start" );
	
	level thread rice_vc_action();
		
	level.vc_rice waittill( "death" );
	level thread play_rice_stinger();

	level notify( "rice_vc_action_complete" );
	autosave_by_name( "creek_1_rvcac" );
}

play_rice_stinger()
{
	wait(1.5);
	level.vc_rice PlaySound( "vox_vc_rice" );
	wait(.5);
//	playsoundatposition ("mus_village_ricebowl", (0,0,0));
	//TUEY Change Underscore
	setmusicstate("VILLAGE_RICE_SECTION");
}

rice_vc_action()
{
	// VC runs to his gun and fires at the player. If the player does 
	// not kill him before he fires, game over
	// -- WWILLIAMS: THE CURTAIN HAS BEEN REMOVED AND THE VC HAS AN EATING LOOP. IF THE PLAYER SITS AROUND FOR TOO LONG
	// -- THEN THE VC WILL REACT AND RUN TO THE GUN AS BEFORE.
	
	if( !isalive( level.vc_rice ) )
	{
		return;
	}
	
	level.vc_rice endon( "death" );
	
	level.vc_rice gun_remove();
	
	level thread maps\creek_1_anim::b2_rice_surprise();
	
	level thread b2_rice_allow_achievement_late_kill();
	
	level.vc_rice waittill( "shoot" );
	//screen_message_create( &"CREEK_1_FAIL_RICE" );
	setdvar( "ui_deadquote", "@CREEK_1_FAIL_RICE" );
	stealth_broken();
}

b2_rice_allow_achievement_late_kill()
{
	level.vc_rice endon( "shoot" );
	level endon( "player_rice_melee_successful" );
	
	while( 1 )
	{
		level.vc_rice waittill( "damage", amount, attacker, dir, org, mod );
		if( mod == "MOD_MELEE" && isplayer( attacker ) )
		{
			level.vc_stealth_killed++;
			return;
		}
	}
}

//---------------------------------------------------------------------------

stealth_bridge_vc()
{
	level waittill( "stealth_rice_action_start" );
	//trigger_wait( "b2_curtains_trigger" );
	//level waittill( "rice_vc_action_complete" );
	
	/*
	teleport_ai_single( "hudson", "b2_hudson_stealth_node_4" );
	//teleport_ai_single( "reznov_ai", "b2_reznov_stealth_node_4" );

	if( isalive( level.vc_bridge_1 ) )
	{
		level.vc_bridge_1 set_run_anim( "patrol_walk", true ); 
		level.vc_bridge_1.disableArrivals = true;
		level.vc_bridge_1.disableExits = true;
		level.vc_bridge_1.nodeathragdoll = true;
		level.vc_bridge_1 thread bridge_ai_death( "b2_vc_bridge_goal_1", 9.5, "J_SpineUpper" );
	}
	
	if( isalive( level.vc_bridge_2 ) )
	{
		level.vc_bridge_2 set_run_anim( "patrol_walk", true ); 
		level.vc_bridge_2.disableArrivals = true;
		level.vc_bridge_2.disableExits = true;
		level.vc_bridge_2.nodeathragdoll = true;
		level.vc_bridge_2 thread bridge_ai_death( "b2_vc_bridge_goal_2", 8.5, "J_Head" );
	}
	
	wait( 10 );
	level thread maps\creek_1_anim::lewis_bridge_anim();
	wait( 0.7 );
	*/
	wait( 2 );
	level notify( "bridge_kill" );
}

bridge_ai_death( goal_name, time, tag_name )
{
	self endon( "death" );
	self go_to_node_by_name( goal_name );
	wait( time );
	
	PlayFxOnTag( level._effect["flesh_hit"], self, tag_name );  
	MagicBullet ( "commando_silencer_sp", level.hudson GetTagOrigin( "tag_weapon_right" ), self GetTagOrigin( tag_name ) );

	self ai_suicide( level.hudson );
}

//---------------------------------------------------------------------------

stealth_dive_under()
{
	level thread interrupt_woods_split_talking();
	
	trigger_wait( "b2_curtains_trigger" );
	
	// wait till the rice VC is dead
	while( isalive( level.vc_rice ) )
	{
		wait( 0.05 );
	}
	
	//level.barnes AllowedStances( "crouch" );
	//level.barnes go_to_node_by_name( "b2_barnes_dive_node_1" );
	level thread stealth_swimming_barnes();
	level thread stealth_swimming_action();
	//level thread snipe_enemies();
	
	// if the last VC is alive, kill him and drop him into the water
	trigger_wait( "beat2_drop_body_trigger" );

	if( isalive( 	level.vc_drop_water ) )
	{
		level notify( "preparing_to_drop_vc" );
		//wait( 0.5 );

		level.vc_drop_water PlaySound( "evt_creek_ai_fallingwater_death" );
	
		//drop_pos = getstruct( "b2_drop_water_guy_pos", "targetname" );
		//level.vc_drop_water forceteleport( drop_pos.origin );
		//level.vc_drop_water ai_suicide();
		level thread maps\creek_1_anim::play_guy_falling_water_death( level.vc_drop_water );
	}
	
	trigger_wait( "b2_stealth_trigger_8_ladder" );
	
	/*
	{
		level.barnes thread say_dialogue( "good" );
		wait( 1.2 );
		player = get_players()[0];
		PlaySoundAtPosition( level.scr_sound["carter"]["good"], player.origin );
	}
	*/
}

interrupt_woods_split_talking()
{
	level endon( "woods_stop_talking_split" );

	level waittill( "explosive_set_2" );
	level notify( "split_up_anim_interrupted" );
	level.barnes StopAnimscripted();
	level.barnes StopSounds();
	level.barnes disable_cqbwalk();
	level.barnes LookAtEntity();
	dest_node = getnode( "b2_barnes_snipe_2", "targetname" );
	level.barnes forceteleport( dest_node.origin, dest_node.angles );
	level.barnes go_to_node_by_name( "b2_barnes_snipe_2" );
}

/*
vo_b2_vc_windows()
{
	wait( 1.5 );

	level.vc_snipe_1 thread say_dialogue( "happy_nothing" );
	wait( 3 );
	level.vc_snipe_2 thread say_dialogue( "i_heard_something" );
	wait( 2.5 );
	level.vc_snipe_1 thread say_dialogue( "looking_now_nothing" );
}
*/

stealth_swimming_barnes()
{
	level endon( "player_getting_on_ladder" );
	level thread open_player_path_into_water();
	
	level endon( "split_up_anim_interrupted" );
	
	// Barnes do the "we are splitting up" anim now
	anim_node = getstruct( "split_up_anim_node", "targetname" );
	anim_node anim_reach_aligned( level.barnes, "we_split_up" );
	level.barnes LookAtEntity(get_players()[0]);
	anim_node anim_single_aligned( level.barnes, "we_split_up" );
	level.barnes disable_cqbwalk();
	level.barnes LookAtEntity();
	level.barnes go_to_node_by_name( "b2_barnes_snipe_2" );
}

open_player_path_into_water()
{
	wait( 17 );
	level notify( "woods_stop_talking_split" );
}

stealth_swimming_action()
{
	level thread second_explosive_nag();
		
	trigger_wait( "b2_obj_trigger_1" );
	
	playsoundatposition( "evt_jumpdown_splash", (0,0,0) );
	
	level thread set_second_charge();

	trigger_wait( "b2_window_pop_trigger" );
	
	level.vc_snipe_1.goalradius = 16;
	
	level thread maps\creek_1_anim::vc_look_out_window( level.vc_snipe_1, level.vc_snipe_2 );
	//level thread patrol_balcony_vc_movement();
	//level thread vo_b2_vc_windows();
	
	
	// vc is looking
	// level waittill( "vc_lookout_in_position" );
	flag_wait( "vc_lookout_in_position" ); // -- WWILLIAMS: should fix a prog break where the notify was hitting before the waittill
	//level thread detect_player_in_water();
	
	//level waittill( "window_safe" );
	//level.vc_snipe_1 go_to_node_by_name( "b2_window_far" );
	
	getting_on_ladder();
}

second_explosive_nag()
{
	level endon( "explosive_set_2" );
	level waittill_either( "split_up_anim_interrupted", "woods_stop_talking_split" );
	level thread c4_set_nag_lines( 15, "explosive_set_2" );
}

set_second_charge()
{
	// new obj charge
	level thread explosive_trigger_hint_press_2();
	explosive_charge_2_obj = getent( "b2_satchel_old_2", "targetname" );
	explosive_charge_2_obj show();
	
	level waittill( "explosive_set_2" );

	level thread maps\creek_1_anim::play_player_setting_bomb_anim_2();
	level.barnes LookAtEntity();	
	
	// when player goes to the window
	//trigger_wait( "b2_window_pop_trigger" );
	wait( 5 );
	trigger_use( "b2_window_pop_trigger" );
}

detect_player_in_water()
{
	level endon( "window_safe" );
	trigger_wait( "b2_stealth_trigger_7b" );
	//iprintlnbold( "VC spots player" );
	level.vc_snipe_1.ignoreall = false;
	wait( 2 );
	stealth_broken();
}

getting_on_ladder()
{
	trigger_wait( "b2_stealth_trigger_7c" );
	level notify( "player_getting_on_ladder" );
	teleport_ai_single( "barnes_ai", "b2_barnes_snipe_teleport" );
	teleport_ai_single( "hudson", "b2_reznov_stealth_node_6" );
	
	// make Woods use standard run anim here
	level.barnes set_run_anim( "standard_run" );
	
	level.barnes StoPAnimScripted();
	level.barnes AllowedStances( "stand", "crouch", "prone" );
	level.barnes PushPlayer( true ); // -- WWILLIAMS: HACK TO FIX PLAYERS FROM STOPPING BARNES GETTING INTO THE REGROUP HUT
	//level.hudson go_to_node_by_name( "b2_reznov_stealth_node_6" );
	
	start_node = getnode( "b3_lewis_ambush_teleport", "targetname" );
	level.hudson forceteleport( start_node.origin, start_node.angles );	
	level.hudson SetGoalNode( start_node );
	//level.reznov go_to_node_by_name( "b2_reznov_stealth_node_5_2" );
	//level.hudson go_to_node_by_name( "b2_hudson_stealth_node_5_2" );
	
	trigger_wait( "b2_stealth_trigger_8" );
	
	wait( 1 );
	
	level thread maps\creek_1_anim::barnes_hut_regroup_walk();
	//level.barnes go_to_node_by_name( "b2_barnes_snipe_end" );
	//level.barnes waittill( "goal" );
}

//---------------------------------------------------------------------------

#using_animtree("generic_human");
stealth_hut_regroup()
{
	// player gets onto hut
	trigger_wait( "b2_stealth_trigger_10" );
	flag_set( "event_2_objectives_complete" );
	
	autosave_by_name( "creek_1_e2oc" );

	// wait for anim to finish
	flag_wait( "b2_ready_for_regroup" );
	level.b2_actions_complete = false;
	
	// -- WWILLIAMS: BARNES/WOODS CAN'T PUSH PLAYER ANYMORE
	level.barnes PushPlayer( false );

	level.barnes go_to_node_by_name( "village_barnes_reach_ambush_1" );
	level.barnes AllowedStances( "stand", "crouch", "prone" );

	// delay hudson so he doesn't grab barnes' traversal node
	//wait(0.05);
	//level.hudson go_to_node_by_name( "node_lewis_start_beat_3" );
	
	level notify( "regroup_finished" );	
	
	//level thread delayed_go_to_node_village();
	
	level notify( "event_2_ends" );
	level.b2_actions_complete = true;
	level notify( "ready_to_call_event_3" );
	
	//autosave_by_name( "creek_1_rtce3" );
}

delayed_go_to_node_village()
{
	wait( 3 );
	level.barnes thread force_go_to_node_by_name( "b2_barnes_stealth_node_22" );

	wait( 2 );
	level.hudson thread force_go_to_node_by_name( "b2_hudson_stealth_node_22" );
}


exit_hut_dialog()
{
	wait( 1.5 );
	players = get_players();
	players[0] PlaySound( "VOX_CRE1_069B_CART" );
	
	wait( 3.5 );

	level.barnes thread say_dialogue( "just_appetizer" );
}

plant_sound()
{
	wait (1.2);
	playsoundatposition ( "evt_bomb_plant", (0, 0, 0) );
}

vc_snoring_1()
{
  self playloopsound( "vox_vc_snore_1" );
  self waittill( "melee_kill" );
  self stoploopsound();
}

vc_snoring_2()
{
  self playloopsound( "vox_vc_snore_2" );
  self waittill( "melee_kill" );
  self stoploopsound();
}


//---------------------------------------------------------------------------

stealth_broken()
{
	level notify( "player_failed" );
	//iprintlnbold( "Mission Fail: Player discovered" );
	
	missionfailedwrapper( "@CREEK_1_FAIL_SILENCED" );
}

//---------------------------------------------------------------------------

// -- WWILLIAMS: FUNCTIONS FOR PRESS DEMO PASS ------------------------------

beat2_reznov_teleport_to_shore() // -- WWILLIAMS: GETS REZNOV WHERE HE NEEDS UNTIL WE GET AN ANIM
{
	AssertEx( IsDefined( level.reznov ), "Reznov is missing!" );
	AssertEx( IsAlive( level.reznov ), "Reznov is not alive!" );

	// objects
	
	teleport_node = GetNode( "node_reznov_after_meatshield_tele", "targetname" );
	fight_node = GetNode( "node_reznov_beat2_ridge1", "targetname" );

	level.reznov Unlink();
	level.reznov StopAnimScripted();

	// move reznov to the shore
	level.reznov forceteleport( teleport_node.origin );
	cover_node = GetNode( "node_reznov_after_meatshield", "targetname" );
	level.reznov SetGoalNode( cover_node );
	
	// send reznov to a fight node
	level.reznov.goalradius = 32;
	level.reznov.pacifist = false;
	level.reznov waittill( "goal" );
	//level.reznov SetGoalNode( fight_node );
	
	// make sure reznov fights
	level.reznov.ignoreme = 0;
	level.reznov.ignoreall = 0;
}

beat2_river_walk_start() 
{
	level.barnes say_dialogue( "stay_sharp" );
	flag_set( "beat2_ridge1_start" );
	
	// vcs talking
	origin_pos = getent( "beat2_ridge1_anim_struct", "targetname" );
	origin_pos.animname = "vc1_ridge1";
	origin_pos say_dialogue( "by_the_river" );
	origin_pos say_dialogue( "only_two_of_them" );
	
	level.reznov say_dialogue( "left_flank_ridge" );
	
	wait( 3 );
	
	//barnes calls out the enemies
	level.barnes say_dialogue( "dead_ahead" );

	//battlechatter_on();
}

beat2_4_19_press_demo_fade_cleaning() // -- WWILLIAMS: CLEANS UP ANYTHING THAT NEEDS TO GO WHEN PRESENT
{
	// wait for fade to finish
	level waittill( "screen_fade_out_complete" );
	
	level beat2_4_19_press_demo_clean_up_riverwalk();
	
	// setup the guys on the other side of the river walk
	level setup_section_1_vcs();
	
	// take control from player
	players = get_players();
	players[0] FreezeControls( true );
	
	level thread beat2_4_19_press_demo_move_barnes_2_hey_charlie();
	level thread beat2_4_19_press_demo_move_reznov_2_hey_charlie(); // -- WWILLIAMS: THIS FUNCTION ALSO RUNS A HEY CHARLIE SETUP FOR REZNOV
	
	// notify or flag here
	flag_set( "stealth_fade_complete" );
	
	// move the player in to position
	players = get_players();
	hey_charlie_player_node = GetNode( "node_player_start_4_19_demo", "targetname" );
	
	players[0] ent_flag_init( "hey_charlie_ready" );
	
	players[0] SetOrigin( hey_charlie_player_node.origin );
	players[0] SetPlayerAngles( hey_charlie_player_node.angles );
	players[0] SetStance( "crouch" );
	
	// set up the correct weapons
	players[0] TakeAllWeapons();
	players[0] GiveWeapon( "ak47_sp" );
	// players[0] TakeWeapon( "m1911_sp" );
	players[0] GiveWeapon( "creek_knife_sp", 0 );
	players[0] GiveWeapon( "knife_creek_sp", 0 );
	players[0] SwitchToWeapon( "ak47_sp" );
	
	players[0] ent_flag_set( "hey_charlie_ready" );
}

beat2_4_19_press_demo_clean_up_riverwalk() // -- WWILLIAMS: CLEAN UP LOOSE ENTS FOR PRESS DEMO
{
	// turn off all spawn managers in the river walk
	spawn_manager_kill( "manager_beat2_ridge1" );
	spawn_manager_kill( "manager_beat2_ridge1_backup" );
	spawn_manager_kill( "manager_beat2_river1" );
	
	// get all ai
	riverwalk_enemies = GetAIArray( "axis" );
	
	// shut up the AI
	for( i = 0; i < riverwalk_enemies.size; i++ )
	{
		if( riverwalk_enemies[i].targetname == "b2_vc_sampan_1_ai" )
		{
			//IPrintLnBold( "vc sampan 1" );
		}
		
		riverwalk_enemies[i].ignoreall = 1;
		riverwalk_enemies[i].ignoreme = 1;
		riverwalk_enemies[i] Delete();
	}
	
	// delete spawners
	//ridge1_spawner_1 = GetEnt( "beat2_ridge1_vc1", "script_noteworthy" );
	//ridge1_spawner_2 = GetEnt( "beat2_ridge1_vc2", "script_noteworthy" );
	river1_spawner_array_1 = GetEntArray( "beat2_ridge1_backup_spawners", "targetname" );
	river1_spawner_array_2 = GetEntArray( "beat2_river1_battle", "targetname" );
	
	/*
	// delete the entities
	if( IsDefined( ridge1_spawner_1 ) )
	{
		ridge1_spawner_1 Delete();
	}
	
	if( IsDefined( ridge1_spawner_2 ) )
	{
		ridge1_spawner_2 Delete();
	}
	*/
	
	for( i = 0; i < river1_spawner_array_1.size; i++ )
	{
		if( IsDefined( river1_spawner_array_1[i] ) )
		{
			river1_spawner_array_1[i] Delete();
		}
		
	}
	
	for( i = 0; i < river1_spawner_array_2.size; i++ )
	{
		if( IsDefined( river1_spawner_array_2[i] ) )
		{
			river1_spawner_array_2[i] Delete();
		}
		
	}
}

beat2_4_19_press_demo_move_barnes_2_hey_charlie() // -- WWILLIAMS: MOVES BARNES TO THE PROPER SPOT FOR 4-19 PRESS DEMO
{
	start_hey_charlie_node = GetNode( "node_barnes_start_4_19_demo", "targetname" );
	
	//level.barnes ent_flag_init( "hey_charlie_ready" );
	
	level thread beat2_4_19_press_demo_hit_important_triggers();
	
	//level.barnes.ignoreall = 1;
	//level.barnes.ignoreme = 1;
	
	//level.barnes ForceTeleport( start_hey_charlie_node.origin );
	//level.barnes SetGoalPos( level.barnes.origin );
	
	//level thread beat2_attach_knife_to_woods_hand( level.barnes );
	
	//level.barnes ent_flag_set( "hey_charlie_ready" );
}

beat2_4_19_press_demo_move_reznov_2_hey_charlie() // -- WWILLIAMS: MIGHT NEED TO DO THE SAME WITH REZNOV
{
	move_to_node = GetNode( "node_reznov_before_hey_charlie", "targetname" );
	
	//level.reznov.ignoreall = 1;
	//level.reznov.ignoreme = 1;
	
	//level.reznov ent_flag_init( "hey_charlie_ready" );
	
	level.reznov ForceTeleport( move_to_node.origin );
	level.reznov SetGoalPos( level.reznov.origin );
	
	//level.reznov ent_flag_set( "hey_charlie_ready" );
	
	//level thread beat2_reznov_during_hey_charlie();
}

beat2_4_19_press_demo_hit_important_triggers() // -- WWILLIAMS: MAKE SURE EVERYTHING STILL STARTS AS IT IS SUPPOSED TO FOR PRESS DEMO
{
	//level.barnes gun_remove();
	
	// -- WWILLIAMS: HIDE PLAYER WEAPONS DURING HEY CHARLIE
	
	// time to start everything
	beat2_move_woods_up_to_start();
	level.vc_hut_1 detach( "t5_weapon_ak47_world", "tag_weapon_right" );
	level.hudson_no_backpack detach( "t5_weapon_commando_world", "tag_weapon_right" );
	level.hudson_no_backpack attach( "t5_knife_animate", "tag_weapon_left" );
	level.hudson_no_backpack attach( "t5_weapon_ak47_world", "tag_weapon_right" );
	level.hudson_no_backpack useweaponhidetags( "ak47_sp" );
	
	level.b2_redshirt.ignoreall = true;
	level.b2_redshirt anim_set_blend_out_time( 0.5 );
	level.vc_hut_1 thread beat2_hey_charlie_loop( getstruct( "b2_huts_anim_node_2", "targetname" ), "hey_charlie_idle", "hey_charlie" );
	level.vc_hut_2 thread beat2_hey_charlie_loop( getstruct( "b2_huts_anim_node_2", "targetname" ), "hey_charlie_idle", "hey_charlie" );
	level.b2_redshirt thread beat2_just_hey_charlie_for_the_squad( getstruct( "b2_huts_anim_node_2", "targetname" ) );
	level.hudson_no_backpack thread beat2_just_hey_charlie_for_the_squad( getstruct( "b2_huts_anim_node_2", "targetname" ) );
	
	flag_set( "start_hey_charlie" );
	
	level thread delayed_hide_tag();
	
	level thread beat2_woods_animates_hey_charlie();
	
	// -- TODO: ONCE WOODS IS IN POSITION START NEW ANIM
	flag_wait( "hut_kill_done" );
	
	//autosave_by_name( "creek_1_pdhit" );
	
	//Tuey setting music state to stealth...
	setmusicstate("VILLAGE_STEALTH");
	
}

delayed_hide_tag()
{
	wait( 0.1 );
	level.hudson_no_backpack useweaponhidetags( "ak47_sp" );
}

beat2_ridge1_fight() // -- WWILLIAMS: TWO GUYS ON THE RIDGE CLOSEST TO THE WATER
{
	wait( 2 );
	trigger_use( "trig_start_beat2_ridge1_vc" );
	
	level thread kille_ridge_vcs_quickly();
	
	// Exploder of birds
	playsoundatposition( "amb_bird_fly_multiple_00", (0,0,0) );
	exploder( 1005 );
	
	waittill_ai_group_amount_killed( "b2_ridge_vc_up", 2 );
	playsoundatposition( "amb_bird_fly_multiple_00", (0,0,0) );
	exploder( 1006 );
	
	// force the next groups to spawn
	trigger_use( "b2_get_on_shore" );
	waittill_ai_group_amount_killed( "b2_ridge_vc_backup", 3 );
	level notify( "all_path_vc_killed" );
	//waittill_ai_group_cleared( "b2_ridge_vc_backup" );
	trigger_use( "trigger_setup_beat2_river2" );
	waittill_ai_group_amount_killed( "b2_ridge_vc_backup2", 4 );
	waittill_ai_group_amount_killed( "b2_ridge_vc_backup", 4 );
	//waittill_ai_group_cleared( "b2_ridge_vc_backup2" );
	
	flag_set( "b1to2_path_1_passed" );
	setmusicstate("IN_THE_JUNGLE_AMBIENT");
	//TUEY Set Music STate to 
	
	// all enemies are killed
	player = get_players()[0];
	player clientNotify( "river_walk_underwater_fog" );
	beat2_riverwalk_dialogue();
	
	level.barnes.ignoreall = 1;
}

kille_ridge_vcs_quickly()
{
	vcs_ridge = getentarray( "b2_ridge_vc_top_ai", "targetname" );
	wait( 3 );
	
	for( i = 0; i < vcs_ridge.size; i++ )
	{
		if( isdefined( vcs_ridge[i] ) && isalive( vcs_ridge[i] ) )
		{
			vcs_ridge[i] ai_suicide();
		}
		wait( 1 );
	}
}

beat2_ridge1_vc1_actions() // -- WWILLIAMS: PLAYS THE ANIMATION OF A VC ON THE RIDGE, CALLS FOR BACKUP
{
	level thread play_sound_ridge_1_when_dying( self );
}

beat2_ridge1_vc2_actions() // -- WWILLIAMS: PLAYS THE ANIMATION OF A VC ON THE RIDGE, CALLS FOR BACKUP
{
	level thread play_sound_ridge_2_when_dying( self );
}

play_sound_ridge_1_when_dying( guy )
{
	guy waittill( "damage" );
  playsoundatposition ("chr_npc_hifall", (-31682, 36951, 306));
	// play death sound here. The guy only has 1 health so he should die
}

play_sound_ridge_2_when_dying( guy )
{
	guy waittill( "damage" );
  playsoundatposition ("chr_npc_hifall", (-31682, 36951, 306));
	// play death sound here. The guy only has 1 health so he should die
}

beat2_barnes_fight_ridge_1() // SELF == LEVEL.BARNES // -- WWILLIAMS: SETS BARNES TO FIGHT AGAINST THE GUYS ON THE CLOSE RIDGE
{
	// endon
	self endon( "death" );
	
	// objects
	node_out_of_water = GetNode( "node_barnes_post_meatshield", "targetname" );
	node_fight = GetNode( "node_barnes_fight_ridge1", "targetname" );
	
	self.goalradius = 24;
	self.ignoreme = 0;
	self.ignoreall = 0;
	self.pacifist = 0;
	self.ignoresuppression = 1;
	
	self disable_react();
	self disable_pain();
		
	self SetGoalNode( node_fight );
	self thread reenable_react_at_node();
	
	level waittill( "all_path_vc_killed" );
}

reenable_react_at_node()
{
	self waittill( "goal" );
	wait( 2 );
	self enable_react();
	self enable_pain();
}
beat2_riverwalk_dialogue() // -- WWILLIAMS: PLAYS THE DIALOGUE BETWEEN MASON & REZNOV THEN WOODS & MASON
{
	// endon
	level.reznov endon( "death" );
	level.barnes endon( "death" );
	level endon( "stealth_fade_complete" );
	level endon( "start_press_demo_fade_out" );
	
	// battlechatter_off( "allies" );
	// battlechatter_off( "axis" );
	battlechatter_off();
	
	// reznov and the player speak
	wait( 1 );

	level thread reznov_runs_away();
	level.reznov say_dialogue( "impressive" );
	level.reznov say_dialogue( "impressive_p2" );
	
	players = get_players();
	players[0] say_dialogue( "stay_close" );
	

	wait( 2 );
	
	// -- WWILLIAMS: TURN BACK ON SURPRESSION SO IT DOESN'T AFFECT VILLAGE.
	level.hudson.ignoresuppression = 1;
	
	level.hudson say_dialogue( "this_is_whiskey" );
	level.barnes say_dialogue( "this_is_xray" );
	level.hudson say_dialogue( "wed_lost_you" );
	level.barnes say_dialogue( "meet_us_at_the_rp" );
	level.hudson say_dialogue( "whiskey_on_the_job" );

	flag_wait( "b1to2_path_3_passed" );
	wait( 1 );
	level.barnes say_dialogue( "knife_only" );
	flag_set( "knife_only_starts" );
	level thread stealth_fail_with_noise();
}

reznov_runs_away()
{
	wait( 2 );
	
	level.reznov go_to_node_by_name( "river_walk_reznov_run_away" );
	level.reznov waittill( "goal" );
	
	temp_node = getnode( "tunnel_room_2_node", "targetname" );
	
	level.reznov forceteleport( temp_node.origin, temp_node.angles );
}

beat2_riverwalk_rain_dialogue() // -- WWILLIAMS: DELIVERS WOODS DIALOGUE ABOUT THE RAIN
{
	level.barnes say_dialogue( "all_it_does_here" );
}

beat2_knife_memories_dialogue() // -- WWILLIAMS: MASON REMEMBERS THE KNIFE ORIGINS
{
	level.barnes endon( "death" );
	level endon( "stealth_fade_complete" );
	
	level.barnes say_dialogue( "knife_only" );
	
	players = get_players();

	level.reznov say_dialogue( "treat_her_well", 7 );
	
	wait( 5.0 );
	
	players[0] PlaySound( "vox_cre1_s02_042A_maso" );

}

beat2_reach_node() // SELF == GUY // -- WWILLIAMS: MAKES AI TO REACH NODE SENT TO
{
	// endon
	self endon( "death" );
	
	self.goalradius = 24;
	self.ignoreme = 1;
	self.ignoreall = 1;
	// self AllowedStances( "stand" );
	
	self waittill( "goal" );
	
	self.ignoreme = 0;
	self.ignoreall = 0;
}

beat2_on_death_notify( death_ent, str_notify ) // -- WWILLIAMS: SENDS OUT THE NOTIFY WHEN THE ENTITY DIES
{
	death_ent waittill( "death" );
	
	if( !flag( str_notify ) )
	{
		flag_set( str_notify );
	}
	
}

c4_set_nag_lines( wait_time, end_msg )
{
	level endon( end_msg );
	wait( wait_time );
	
	loiter_trigger = getent( "b2_loiter_trigger", "targetname" );
	player = get_players()[0];
	
	while( 1 )
	{
		if( player istouching( loiter_trigger ) )
		{
			level.barnes say_dialogue( "c4_nag_2" );
		}
		else
		{
			level.barnes say_dialogue( "c4_nag_1" );
		}
		wait( randomint( 8 ) + 7 );
		if( player istouching( loiter_trigger ) )
		{
			level.barnes say_dialogue( "c4_nag_2" );
		}
		else
		{
			level.barnes say_dialogue( "c4_nag_3" );
		}
		wait( randomint( 8 ) + 7 );
	}
}
// -- WWILLIAMS: FUNCTIONS FOR PRESS DEMO PASS ------------------------------		
