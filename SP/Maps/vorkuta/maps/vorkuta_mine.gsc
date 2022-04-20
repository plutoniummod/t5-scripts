/*
Filename: vorkuta_mine.gsc
Author:   Kevin Drew
Date:     APR 30 14:08:00 PST 2010

Description: This file contains the implementation of
			 functions for the mine section of Vorkuta.
*/

#include maps\_utility;
#include common_scripts\utility;
#include maps\vorkuta_util;
#include maps\_anim;
#include maps\_music;

main() 
{
	mine_spawn_funcs();

	mine_setup_reznov();
	mine_setup_player();

	//turn on battlechatter
	battlechatter_off();

	switch(GetDvar( #"start"))
	{
	case "start_mine":
		level thread event_2_los_delete();
		event_2_escape();
	case "start_inclinator":
		event_3_inclinator();
		event_4_exit();
		break;
	default:
		event_1_intro();
		event_2_escape();
		event_3_inclinator();
		event_4_exit();
	}

	battlechatter_on();
}

event_1_intro()
{
	player_body = spawn_anim_model( "player_body" );
	player = get_players()[0];
	player SetClientDvar("cg_drawfriendlynames", 0);
	player SetClientDvar( "compass", 0 );
	default_CullRadius = GetDvar("cg_aggressiveCullRadius"); 
	player SetClientDvar( "cg_aggressiveCullRadius", 1000 );
	
	player_body.angles = player GetPlayerAngles();
	player_body.origin = player.origin;

	player PlayerLinkToAbsolute(player_body,"tag_player");
	
	level.intro_guard = simple_spawn_single("mine_guard_intro", maps\_baton_guard::make_baton_guard);

	actors[0] = level.reznov;
	actors[1] = level.intro_guard;
	actors[1].dropweapon = 0;
	actors[2] = player_body;
	
	//TUEY Set music state to INTRO_FIGHT
	setmusicstate ("INTRO_FIGHT");
	playsoundatposition( "evt_num_num_02_r" , (0,0,0) );
	
	anim_node = GetNode("anim_mine_start_room","targetname");

	//starting anim of reznov punching player with guard approaching the fight to break it up
	anim_node thread anim_single_aligned(actors, "intro_player");
	player thread event_1_rumble_shake();
	
	//create the 6 immediate prisoners around the fight and thread their logic
	level.intro_prisoners = [];
	for(i = 0; i < 6; i++)
	{
		level.intro_prisoners[i] = mine_create_prisoner("prisoner_" + (i+1), true, "mine_prisoner_goal_tunnel_1");
		level.intro_prisoners[i] thread event_1_crowd_logic(anim_node);
		wait(0.05);
	}
	level thread event_1_crowd();

	level waittill("unfreeze");

	//turn bottom prisoners on and top prisoners
	level thread event_2_los_delete();
	trigger_use("sm_mine_prisoners_start");
	trigger_use("sm_mine_prisoners_top_start");

	//wait for the player to push the r trigger or else the anim plays through and the player dies
	level thread event_1_wait_for_punch();

	flag_wait("flag_intro_punch_happened");
	//C. Ayers: Adding in TEMP notify for crowd vox
	level clientnotify( "gef" );

	autosave_by_name("vorkuta_intro_01");
	
	//anim of player punching reznov off and then reznov taunting the guard
	player StartCameraTween(1.0);
	player PlayerLinkToDelta( player_body, "tag_player", 0.0, 10, 10, 10, 10, true );
	player_body Attach("p_rus_vork_single_rock","tag_weapon");

	actors = array(actors[0], actors[1]);
	anim_node thread event_1_beat_loop(actors);
	anim_node anim_single_aligned(player_body, "intro_player_punch");
		
	//allow player movement
	player Unlink();
	player_body Hide();

	
	//wait for the player to move up to the guard and hit the contextual melee button
	level thread event_1_wait_for_melee(actors[1]);
	flag_wait("flag_intro_melee_happened");

	//stop spawning guys down below 
	spawn_manager_disable("sm_mine_prisoners_start");

	//player knocks the guard out and helps Reznov up
	anim_node thread event_1_guard_death(actors[1]);
	anim_node thread anim_single_aligned(level.reznov, "intro_player_smash");
	player thread event_1_camera_tween(player_body);
	anim_node anim_single_aligned(player_body, "intro_player_smash");
	
	player Unlink();
	player SetClientDvar("cg_drawfriendlynames", 1);
	player SetClientDvar( "compass", 1 );
	player SetClientDvar( "cg_aggressiveCullRadius", default_CullRadius );
	player_body Delete();

	flag_set("flag_intro_fight_done");

	level thread event_1_knife_tutorial();
	
	//AUDIO: C. Ayers
	//clientnotify( "mas" );
	setmusicstate( "MINE_INTRO" );
}

#using_animtree("player");
event_1_intro_freeze(player_body)
{
	level thread event_1_intro_ai_freeze();
	level thread event_1_intro_props_freeze();
	player_body SetFlaggedAnimLimited("player_message", %ch_vor_b01_intro_player, 1.0, 0.5, 0.0);
	player_body thread message_catcher();
	
	level clientNotify ("intro_ss");
	
	anim_single(get_players()[0], "movie_1_01", "mason");
	anim_single(get_players()[0], "movie_1_02", "mason");
	level notify("unfreeze");
	
	level clientNotify ("unfrz");
	
	player_body SetFlaggedAnimLimited("player_message", %ch_vor_b01_intro_player, 1.0, 0.5, 1.0);

	level thread play_additional_crowd();
	//turn on FX for the mines and inclinator tunnel
	exploder(7);
	exploder(1000);
	exploder(1100);
}
play_additional_crowd()
{
	wait(2);
	playsoundatposition ("amb_vox_fight_cheer_1", (-561,-6495,-234));	
	wait(0.1);
	playsoundatposition ("amb_vox_fight_cheer_3", (-799,-6618,-271.9));	
	wait(0.25);
	playsoundatposition ("amb_vox_fight_end_cheer_0", (-722,-6868,-297));	
}
message_catcher()
{
	while(1)
	{
		self waittill( "player_message", msg );

		if(msg == "end")
		{
			return;
		}
		if( msg == "info_show")
		{
			level notify("show_level_info");
		}
		if( msg == "prompt_start")
		{
			level notify("punch_prompt_start");
		}
		if( msg == "prompt_end")
		{
			level notify("punch_prompt_end");
		}
	}
}

#using_animtree("generic_human");
event_1_intro_ai_freeze()
{
	level.reznov SetAnimLimited(%ch_vor_b01_intro_resnov, 1.0, 0.5, 0.0);
	level.intro_guard SetAnimLimited(%ch_vor_b01_intro_guard, 1.0, 0.5, 0.0);
	level.intro_prisoners[0] SetAnimLimited(%ch_vor_b01_intro_prisoner1, 1.0, 0.5, 0.0);
	level.intro_prisoners[1] SetAnimLimited(%ch_vor_b01_intro_prisoner2, 1.0, 0.5, 0.0);
	level.intro_prisoners[2] SetAnimLimited(%ch_vor_b01_intro_prisoner3, 1.0, 0.5, 0.0);
	level.intro_prisoners[3] SetAnimLimited(%ch_vor_b01_intro_prisoner4, 1.0, 0.5, 0.0);
	level.intro_prisoners[4] SetAnimLimited(%ch_vor_b01_intro_prisoner5, 1.0, 0.5, 0.0);
	level.intro_prisoners[5] SetAnimLimited(%ch_vor_b01_intro_prisoner6, 1.0, 0.5, 0.0);	

	for(i = 0; i < level.intro_models.size; i++)
	{
		animation = level.scr_anim["generic"]["rail_cheer_" + level.intro_models[i].offset + "_loop"][0];
		level.intro_models[i] SetAnim(animation, 1.0, 0.5, 0.0);
	}

	level waittill("unfreeze");
	
	level.reznov SetAnimLimited(%ch_vor_b01_intro_resnov, 1.0, 0.5, 1.0);
	level.intro_guard SetAnimLimited(%ch_vor_b01_intro_guard, 1.0, 0.5, 1.0);
	level.intro_prisoners[0] SetAnimLimited(%ch_vor_b01_intro_prisoner1, 1.0, 0.5, 1.0);
	level.intro_prisoners[1] SetAnimLimited(%ch_vor_b01_intro_prisoner2, 1.0, 0.5, 1.0);
	level.intro_prisoners[2] SetAnimLimited(%ch_vor_b01_intro_prisoner3, 1.0, 0.5, 1.0);
	level.intro_prisoners[3] SetAnimLimited(%ch_vor_b01_intro_prisoner4, 1.0, 0.5, 1.0);
	level.intro_prisoners[4] SetAnimLimited(%ch_vor_b01_intro_prisoner5, 1.0, 0.5, 1.0);
	level.intro_prisoners[5] SetAnimLimited(%ch_vor_b01_intro_prisoner6, 1.0, 0.5, 1.0);	
}

#using_animtree("fxanim_props");
event_1_intro_props_freeze()
{
	chains = getentarray( "fxanim_gp_chain_650_mod", "targetname" );

	for(i = 0; i < chains.size; i++)
	{
		chains[i] SetAnim(%fxanim_gp_chain_650_anim, 1.0, 0.5, 0.0);
	}

	level waittill("unfreeze");

	for(i = 0; i < chains.size; i++)
	{
		chains[i] SetAnim(%fxanim_gp_chain_650_anim, 1.0, 0.5, 1.0);
	}
}


event_1_guard_death(guard)
{
	guard magic_bullet_shield();
	guard DisableAimAssist();
	self anim_single_aligned(guard, "intro_player_smash");
	self anim_loop_aligned(guard, "intro_player_dead");
}

event_1_beat_loop(actors)
{
	self anim_single_aligned(actors, "intro_player_punch");
	self anim_loop_aligned(actors, "intro_player_beat_loop");
}

event_1_camera_tween(player_body)
{
	self StartCameraTween(0.5);
	self PlayerLinkToAbsolute(player_body,"tag_player");
	wait(0.25);
	player_body Show();
}

//adds camera shake and rumble to the intro, self is player
event_1_rumble_shake()
{
	//initial fall to the ground
	wait(0.1);
	self PlayRumbleLoopOnEntity("damage_heavy");
	wait(1);
	self StopRumble("damage_heavy");

	//Reznov's punch
	level waittill("unfreeze");
	self PlayRumbleOnEntity("grenade_rumble");

	//player grabs Reznov and punches back
	flag_wait("flag_intro_punch_happened");
	wait(0.5);
	self PlayRumbleOnEntity("damage_heavy");
	wait(0.6);
	self PlayRumbleOnEntity("grenade_rumble");

	//pick up the rock
	wait(17);
	self PlayRumbleOnEntity("damage_light");
	wait(0.6);
	self PlayRumbleOnEntity("grenade_rumble");

	//grab guard and knock him out
	flag_wait("flag_intro_melee_happened");
	wait(0.8);
	self PlayRumbleOnEntity("damage_heavy");
	wait(1.2);
	self PlayRumbleOnEntity("grenade_rumble");

	//grab Reznov's hand
	wait(5);
	self PlayRumbleOnEntity("damage_light");

}

event_1_crowd_logic(anim_node)
{
	anim_node thread anim_single_aligned(self, "intro_player");

	flag_wait("flag_intro_punch_happened");
	
	anim_node anim_single_aligned(self, "intro_player_punch");
	anim_node thread anim_loop_aligned(self, "intro_player_beat_loop");

	//set in reznov's final animation for the fight
	flag_wait("flag_stop_intro_prisoner_loop");

	if( (self.animname == "prisoner_6") || (self.animname == "prisoner_5") )
	{
		self StopAnimScripted();
		self Delete();
		return;
	}

	anim_node thread anim_single_aligned(self, "intro_player_smash");

	//this prisoner is too troublesome so we are getting rid of him when he leaves player sight
	if(self.animname == "prisoner_2")
	{
		wait_time = GetAnimLength(level.scr_anim["prisoner_2"]["intro_player_smash"]);
		wait(wait_time - 1);
		self delete();
	}

}

event_1_delta_camera(player_body)
{
	player = get_players()[0];
	player StartCameraTween(1.0);
	wait(0.5);
	player PlayerLinkToDelta( player_body, "tag_player", 0.0, 10, 10, 20, 20, true );
}

event_1_audio_01(player_body)
{
	level thread play_prisoner_crowd_vox( "vox_vor1_s99_300A_rrd5", "vox_vor1_s99_301A_rrd6", "vox_vor1_s99_302A_rrd7" );
	flag_set("flag_obj_step_1");
}

event_1_audio_02(player_body)
{
	level thread play_prisoner_crowd_vox( "vox_vor1_s99_321A_rrd5", "vox_vor1_s99_322A_rrd6", "vox_vor1_s99_323A_rrd7" );
	level clientnotify( "mas" );
}

#using_animtree("animated_props");
event_1_grab_keys(reznov)
{
	keys_origin = GetStartOrigin(self.origin, self.angles, %ch_vor_b01_intro_key_smash);
	keys_angles = GetStartAngles(self.origin, self.angles, %ch_vor_b01_intro_key_smash);
	keys = spawn_anim_model("keys", keys_origin, keys_angles);
	self anim_single_aligned(keys,"intro_player_smash");
	keys Delete();
}

#using_animtree ("generic_human");
event_1_grab_baton(reznov)
{
	level.intro_guard.baton Hide();

	baton = Spawn( "script_model", reznov GetTagOrigin("tag_weapon_right") );
	baton.angles = reznov GetTagAngles("tag_weapon_right");
	baton SetModel( GetWeaponModel( "baton_sp" ) );
	baton LinkTo( reznov, "tag_weapon_right", (0,0,0), (0,0,0) );

	flag_wait("flag_intro_fight_done");

	baton Unlink();
	baton PhysicsLaunch();

	wait(60);

	baton Delete();
}

event_1_wait_for_punch()
{
	level endon("flag_intro_punch_happened");

	level waittill("punch_prompt_start");
	//level thread event_1_r_trigger_pressed();
	wait(1);

	flag_set("flag_intro_punch_happened");
	level waittill("punch_prompt_end");
	screen_message_delete();
	flag_set("flag_intro_punch_happened");
}

event_1_r_trigger_pressed()
{
	level endon("punch_prompt_end");

	player = get_players()[0];
	screen_message_create( &"VORKUTA_PUNCH_REZ" );
	while(!player AttackButtonPressed() )
	{
		wait( .05 );
	}
	flag_set("flag_intro_punch_happened");
	screen_message_delete();
}

event_1_wait_for_melee(guard)
{
	level endon("flag_intro_melee_happened");

	//make up difference of player animation ending shortly before the loop starts
	wait(0.5);

	level thread event_1_melee_pressed(guard);
	level thread event_1_monitor_arena();

	//duration for the player to melee
	waittill_notify_or_timeout("left_arena", 6);

	//reznov passes out from the beatdown
	level notify("melee_did_not_happen");
	screen_message_delete();

	//fail the player
	SetDvar( "ui_deadquote", &"VORKUTA_GENERIC_FAIL" ); 
	missionFailedWrapper();
}

event_1_monitor_arena()
{
	level endon("flag_intro_melee_happened");

	player = get_players()[0];
	trigger = GetEnt("intro_arena","targetname");

	while(player IsTouching(trigger))
	{
		wait(0.05);
	}

	level notify("left_arena");
}

event_1_melee_pressed(guard)
{
	self endon("melee_did_not_happen");

	player = get_players()[0];
	reznov = level.reznov;
	
	//to prevent button press from being too soon
	wait(0.1);

	while(1)
	{
		if( player event_1_player_can_melee(guard) )
		{
			player SetScriptHintString(&"SCRIPT_HINT_MELEE");
			if(player MeleeButtonPressed())
			{
				flag_set("flag_intro_melee_happened");
				
				//C. Ayers: Adding in TEMP notify for the client
				level clientnotify( "gko" );
				
				player SetScriptHintString("");
				return;
			}
		}
		else
		{
			player SetScriptHintString("");
		}
		wait(0.05);
	}
}

event_1_player_can_melee(guy)
{
	dist = DistanceSquared(guy.origin, self.origin);

	if (dist < 40*40)
	{
		looking_at = is_player_looking_at(guy GetTagOrigin("J_Neck"), .7, false);

		facing_same_way = (VectorDot(AnglesToForward(guy.angles), AnglesToForward(self GetPlayerAngles())) > 0.4);

		return looking_at && facing_same_way;
	}

	return false;
}

event_1_crowd()
{
	positions = GetStructArray("intro_crowd","targetname");
	level.intro_models = [];

	offset = 1;
	for(i = 0; i < positions.size; i++)
	{
		if( IsDefined(positions[i].script_noteworthy) && positions[i].script_noteworthy == "human")
		{
			level.intro_models[i] = mine_create_prisoner("generic", true, "mine_prisoner_goal_rail_crowd");
			level.intro_models[i] forceteleport(positions[i].origin, positions[i].angles);
		}
		else
		{
			level.intro_models[i] = create_prisoner_model();
			level.intro_models[i].origin = positions[i].origin;
			level.intro_models[i].angles = positions[i].angles;
		}
		
		level.intro_models[i] thread anim_generic_loop(level.intro_models[i], "rail_cheer_" + offset + "_loop");
		level.intro_models[i].offset = offset;

		offset++;
		if(offset > 6)
		{
			offset = 1;
		}

		wait(0.1);
	}

	level waittill("unfreeze");

	for(i = 0; i < level.intro_models.size; i++)
	{
		level.intro_models[i] thread anim_generic_loop(level.intro_models[i], "rail_cheer_" + level.intro_models[i].offset + "_loop");
	}	

	flag_wait("flag_intro_fight_done");

	level thread event_1_clean_up(level.intro_models);

	for(i = 0; i < level.intro_models.size; i++)
	{
		if( IsAI(level.intro_models[i]) )
		{
			wait( RandomFloatRange(0.5, 1.0) );
			if( IsDefined(level.intro_models[i]) )
			{
				level.intro_models[i] anim_generic(level.intro_models[i], "rail_cheer_" + level.intro_models[i].offset + "_exit");
			}
		}
	}	
}

event_1_clean_up(models)
{
	flag_wait("mine_move_reznov_01");

	spawn_manager_kill("sm_mine_prisoners_top_start");

	for(i = 0; i < models.size; i++)
	{
		if( IsDefined(models[i]) && !IsAI(models[i]) )
		{
			models[i] Delete();
		}		
	}
}

event_1_knife_tutorial()
{
	screen_message_create(&"VORKUTA_KNIFE_HINT");
	wait(3);
	screen_message_delete();
}

delayed_save()
{
	wait 1;
	autosave_by_name("vorkuta_intro_02");
}

event_2_escape()
{
	get_players()[0] GiveWeapon( "knife_sp", 0 );
	get_players()[0] GiveWeapon( "vorkuta_knife_sp", 0 );
	get_players()[0] SwitchToWeapon( "vorkuta_knife_sp" );
	
	level thread event_2_audio_01();
	level thread event_2_one_off();

	level thread delayed_save();

	delayThread(10, ::spawn_manager_enable, "sm_mine_prisoners_start");

	//clip used to steer AI in the opening
	clip = GetEnt("intro_monster_clip","targetname");
	clip Delete();
		
	level thread event_2_reznov_path();

	level thread event_2_strobe_tunnel_fight();
	level thread event_2_top_of_tunnel();
	
	trigger_wait("mine_vignettes_1");

	level thread event_2_guard_attack_player();
	
	delayThread(2, ::event_2_vig_pre_sergei_01);
	delayThread(3, ::event_2_vig_pre_sergei_02);
	delayThread(4, ::event_2_vig_pre_sergei_03);

	trigger_wait("mine_sergei_intro_vignette");

	//form the progression blocking wall of people
	level thread event_2_sergei_intro_blocker();

	level event_2_sergei_intro();
}

event_2_one_off()
{
	trigger_wait("mine_one_off");

	prisoner = mine_create_prisoner("generic", true, "mine_prisoner_goal_tunnel_1");
	node = GetNode("mine_one_off","targetname");
	prisoner Teleport(node.origin, node.angles);
}

event_2_audio_01()
{
	player = get_players()[0];
	player.animname = "mason";
	
	//step 2
	anim_single(level.reznov, "mine_steps_01");
	anim_single(player, "mine_steps_02", "crow");

	//for objective bread crumbs
	flag_set("flag_obj_step_2");
	
	//step 3
	if(!flag("flag_sergei_intro_start"))
	{
		anim_single(level.reznov, "mine_steps_03");
		level thread play_prisoner_crowd_vox( "vox_vor1_s99_306A_rrd5", "vox_vor1_s99_307A_rrd6", "vox_vor1_s99_308A_rrd7" );
		anim_single(player, "mine_steps_04", "crow");
	}	
	
	//step 4
	if(!flag("flag_sergei_intro_start"))
	{
		anim_single(level.reznov, "mine_steps_05");
		level thread play_prisoner_crowd_vox( "vox_vor1_s99_309A_rrd5", "vox_vor1_s99_310A_rrd6", "vox_vor1_s99_311A_rrd7" );
		anim_single(player, "mine_steps_06", "crow");
	}	
	
	//step 5
	if(!flag("flag_sergei_intro_start"))
	{
		anim_single(level.reznov, "mine_steps_07");
		level thread play_prisoner_crowd_vox( "vox_vor1_s99_312A_rrd5", "vox_vor1_s99_313A_rrd6", "vox_vor1_s99_314A_rrd7" );
		anim_single(player, "mine_steps_08", "crow");
	}	
	
	//step 6
	if(!flag("flag_sergei_intro_start"))
	{
		anim_single(level.reznov, "mine_steps_09");
		level thread play_prisoner_crowd_vox( "vox_vor1_s99_315A_rrd5", "vox_vor1_s99_316A_rrd6", "vox_vor1_s99_317A_rrd7" );
		anim_single(player, "mine_steps_10", "crow");
	}
	
	//step 7
	if(!flag("flag_sergei_intro_start"))
	{
		anim_single(level.reznov, "mine_steps_11");
		level thread play_prisoner_crowd_vox( "vox_vor1_s99_318A_rrd5", "vox_vor1_s99_319A_rrd6", "vox_vor1_s99_320A_rrd7" );
		anim_single(player, "mine_steps_12", "crow");
	}
}

event_2_reznov_path()
{
	anim_node = GetNode("anim_mine_tunnel_1","targetname");

	anim_node anim_reach_aligned(level.reznov, "guide_mine_start_01");

	if(!flag("mine_move_reznov_01"))
	{
		anim_node anim_single_aligned(level.reznov, "guide_mine_start_01");
		anim_node thread anim_loop_aligned(level.reznov, "guide_mine_loop_01");
		flag_wait("mine_move_reznov_01");
		anim_node anim_single_aligned(level.reznov, "guide_mine_end_01");
	}

	drone_trigger = GetEnt("mine_drone_first_tunnel","script_noteworthy");
	drone_trigger notify("stop_drone_loop");
	level thread remove_drone_structs(drone_trigger);
		
	anim_node = GetNode("anim_mine_wall","targetname");

	anim_node anim_reach_aligned(level.reznov, "guide_mine_start_02");
	
	if(!flag("mine_move_reznov_02"))
	{
		anim_node anim_single_aligned(level.reznov, "guide_mine_start_02");
		anim_node thread anim_loop_aligned(level.reznov, "guide_mine_loop_02");
		flag_wait("mine_move_reznov_02");
		anim_node anim_single_aligned(level.reznov, "guide_mine_end_02");
	}

	anim_node = GetNode("anim_mine_sergei","targetname");

	anim_node anim_reach_aligned(level.reznov, "intro_sergei");
	flag_set("flag_sergei_intro_start");
	anim_node anim_single_aligned(level.reznov, "intro_sergei");

	anim_node = GetNode("anim_mine_inclinator","targetname");
	anim_node thread anim_reach_aligned(level.reznov, "unlock_inclinator_enter");

	flag_set("flag_sergei_intro_over");
}

event_2_los_delete()
{
	level endon("mine_clean_up_2");

	trigger = GetEnt("mine_los_delete","targetname");
	player = get_players()[0];

	while(!flag("mine_clean_up_2"))
	{
		trigger waittill("trigger", entity);
		if( IsDefined(entity) && IsDefined(entity.los_delete) && entity.los_delete )
		{
			eye = player GetEye();
			if( !entity SightConeTrace(eye,player) )
			{
				entity delete();
			}
		}
		wait(0.05);
	}
}

//spawn the guard at the top of the first tunnel who attacks the player
event_2_guard_attack_player()
{
	anim_node = GetNode("anim_mine_tunnel_1","targetname");

	guard_2 = mine_create_guard("guard_2");

	anim_node anim_single_aligned(guard_2, "mine_vig_guard_attack_player");
}

//spawns a prisoner to idle until a guard runs and grabs
event_2_top_of_tunnel()
{
	anim_node = GetNode("anim_mine_tunnel_1","targetname");

	prisoner_1 = mine_create_prisoner("prisoner_1", true, "mine_prisoner_goal_tunnel_1");
	anim_node thread anim_loop_aligned(prisoner_1, "mine_vig_guard_attack_player_intro");
	
	flag_wait("mine_move_reznov_01");

	guard_1 = mine_create_guard("guard_1");
	
	actors[0] = prisoner_1;
	actors[1] = guard_1;

	anim_node anim_single_aligned(actors, "mine_vig_guard_attack_player");

	anim_node thread anim_loop_aligned(prisoner_1, "mine_vig_guard_attack_player_outro");
	if(IsAlive(guard_1))
	{
		anim_node thread anim_loop_aligned(guard_1, "mine_vig_guard_attack_player_outro");
	}
	
	prisoner_1 thread event_2_prisoner_recovery(guard_1, anim_node, "mine_vig_guard_attack_player_exit");
	
	flag_wait("mine_clean_up_1");

	mine_array_remove(actors);

}

event_2_prisoner_recovery(guard, anim_node, anim_name)
{
	self endon("death");

	guard waittill("death");

	anim_node anim_single_aligned(self, anim_name);
}

event_2_prisoner_death(guard)
{
	self endon("death");

	guard waittill("death");

	wait(1);

	self ragdoll_death();
}

event_2_strobe_tunnel_fight()
{
	anim_node = GetNode("anim_mine_tunnel_1","targetname");

	actors[0] = create_prisoner_model("prisoner_1");
	actors[1] = create_prisoner_model("prisoner_2");
	actors[2] = create_guard_model("guard");

	anim_node thread anim_loop_aligned(actors, "mine_vig_first_encounter");

	flag_wait("mine_clean_up_1");

	mine_array_remove(actors);
}

//guard beating prisoner
event_2_vig_pre_sergei_01()
{
	actors[0] = mine_create_prisoner("prisoner", true, "mine_prisoner_goal_tunnel_1");
	actors[1] = mine_create_guard("guard");

	anim_node = GetNode("anim_mine_tunnel_1","targetname");

	anim_node thread anim_loop_aligned(actors,"mine_vig_pre_sergei_01");

	actors[0] thread event_2_prisoner_death(actors[1]);
	
	flag_wait("mine_clean_up_1");

	mine_array_remove(actors);
}

//guard dragging prisoner and then beating him
event_2_vig_pre_sergei_02()
{
	actors[0] = mine_create_prisoner("prisoner", true, "mine_prisoner_goal_tunnel_1");
	actors[1] = mine_create_guard("guard");

	actors[0] thread event_2_prisoner_death(actors[1]);

	anim_node = GetNode("anim_mine_tunnel_1","targetname");

	anim_node anim_single_aligned(actors,"mine_vig_pre_sergei_02_intro");
	if(IsAlive(actors[0]) && IsAlive(actors[1]))
	{
		anim_node thread anim_loop_aligned(actors,"mine_vig_pre_sergei_02");
	}

	flag_wait("mine_clean_up_1");

	mine_array_remove(actors);
}

//several prisoners holding back guards allowing you to move forward
event_2_vig_pre_sergei_03()
{
	anim_node = GetNode("anim_mine_wall","targetname");
	
	prisoners[0] = mine_create_prisoner("prisoner_1", true, "mine_prisoner_goal_tunnel_1");
	prisoners[1] = mine_create_prisoner("prisoner_2", true, "mine_prisoner_goal_tunnel_1");
	prisoners[2] = mine_create_prisoner("prisoner_3", true, "mine_prisoner_goal_tunnel_1");
	prisoners[3] = mine_create_prisoner("prisoner_4", true, "mine_prisoner_goal_tunnel_1");
	prisoners[4] = mine_create_prisoner("prisoner_5", true, "mine_prisoner_goal_tunnel_1");
	guards[0] = mine_create_guard("guard_1");
	guards[1] = mine_create_guard("guard_2");
	guards[2] = mine_create_guard("guard_3");

	for(i = 0; i < prisoners.size; i++)
	{
		prisoners[i].noDodgeMove = true;
	}

	array_thread(guards, ::magic_bullet_shield);

	actors = array_combine(prisoners, guards);
	while(!flag("mine_move_reznov_02"))
	{
		anim_node anim_single_aligned(actors, "mine_vig_pre_sergei_wall");
	}

	//if anyone was killed remove them before playing their exit anims
	actors = array_removeDead(actors);
	anim_node anim_single_aligned(actors, "mine_vig_pre_sergei_wall");
	actors = array_removeDead(actors);
	anim_node anim_single_aligned(actors, "mine_vig_pre_sergei_wall_exit");

	array_thread(guards, ::stop_magic_bullet_shield);

	//spawn an entity to attack for the guards
	target = Spawn( "script_origin", GetStruct("mine_prisoner_goal_tunnel_1","targetname").origin );

	//set all the guards targets
	guards = array_removeDead(guards);	
	for(i = 0; i < guards.size; i++)
	{
		if( IsDefined(guards[i]) && IsAlive(guards[i]) )
		{
			guards[i].los_delete = true;
			guards[i].noDodgeMove = true; 
			guards[i] SetEntityTarget(target);
		}			
	}

	//have one of the guards come after the player if they didn't move forward
	if( !flag("flag_sergei_guards") )
	{	
		guards[0].los_delete = false;
		guards[0] ClearEntityTarget();
	}

	flag_wait("mine_clean_up_2");

	mine_array_remove(actors);
	target Delete();
}

event_2_sergei_intro()
{
	anim_node = GetNode("anim_mine_sergei","targetname");

	level thread event_2_sergei_post_intro();

	autosave_by_name("vorkuta_mine_01");

	//stop the drones in the unreachable tunnel
	drone_trigger = GetEnt("mine_drone_back_tunnel","script_noteworthy");
	drone_trigger notify("stop_drone_loop");
	level thread remove_drone_structs(drone_trigger);

	//start the drones behind the formed wall
	drone_trigger = GetEnt("mine_drone_last_tunnel","script_noteworthy");
	drone_trigger notify("trigger");

	//trigger the drones to spawn in front of the fire behind the progression wall
	drone_trigger = GetEnt("mine_drone_main_tunnel","script_noteworthy");
	drone_trigger notify("stop_drone_loop");
	level thread remove_drone_structs(drone_trigger);

	flag_wait("flag_sergei_intro_start");

	//Sergei's intro vignette
	victim_1 = create_guard_model("victim_1");
	victim_2 = create_guard_model("victim_2");
	victim_3 = create_guard_model("victim_3");
	level.sergei = simple_spawn_single("sergei", maps\_sergei::init_sergei);
	
	actors = array(victim_1, victim_2, victim_3);
	anim_node thread anim_single_aligned(actors, "intro_sergei");
	anim_node anim_single_aligned(level.sergei, "intro_sergei");
	level thread event_3_sergei_board();
}

event_2_sergei_intro_player_vo(reznov)
{
	player = get_players()[0];
	
	if(Distance2D(reznov.origin, player.origin) < 350)
	{
		anim_single(player, "sergei_intro_03", "mason");
	}
}

event_2_sergei_intro_blocker()
{
	anim_node = GetNode("anim_mine_sergei","targetname");

	actors_e[0] = mine_create_guard("victim_1");
	actors_e[1] = mine_create_guard("victim_2");
		
	level.mine_russians[0] = mine_create_prisoner("prisoner_russian_1", false);
	level.mine_russians[1] = mine_create_prisoner("prisoner_russian_2", false);
		
	actors = array_combine(actors_e, level.mine_russians);

	anim_node anim_single_aligned(actors, "intro_sergei_wall_start");
	for(i = 0; i < actors.size; i++)
	{
		anim_node thread anim_loop_aligned(actors[i], "intro_sergei_wall");
	}	

	flag_wait("flag_sergei_intro_start");

	wait(3);

	//stop spawning drones behind the wall
	drone_trigger = GetEnt("mine_drone_last_tunnel","script_noteworthy");
	drone_trigger notify("stop_drone_loop");
	level thread remove_drone_structs(drone_trigger);

	wait(2);

	wall = GetEnt("sergei_intro_player_wall","targetname");
	wall Delete();

	array_thread(actors_e, ::event_2_sergei_intro_blocker_die);
	array_thread(level.mine_russians, ::event_3_russians_board);
}

event_2_sergei_intro_blocker_die()
{
	anim_node = GetNode("anim_mine_sergei","targetname");
	anim_node anim_single_aligned(self, "intro_sergei_wall_death");
	self ragdoll_death();
}

event_2_sergei_post_intro()
{
	trigger_wait("mine_vignettes_2");

	//right side by mine cart
	level thread event_2_vig_post_sergei("mine_vig_post_sergei_01", "animation");
	wait(0.1);

	//back left
	level thread event_2_vig_post_sergei("mine_vig_post_sergei_02", "animation");
	wait(0.1);

	//middle left
	level thread event_2_vig_post_sergei("mine_vig_post_sergei_03", "animation", true);
	wait(0.1);

	//first on the left
	level thread event_2_vig_post_sergei("mine_vig_post_sergei_04", "mine_prisoner_goal_tunnel_1");
	wait(0.1);

	level thread event_2_vig_control_box_guy();
	wait(2);
	level thread event_2_vig_ready_passengers();	
}

event_2_vig_post_sergei(anim_name, goal_name, has_intro)
{
	anim_node = GetNode("anim_mine_sergei","targetname");

	actors[0] = mine_create_prisoner("prisoner", false);
	actors[1] = mine_create_guard("guard");
	actors[1] magic_bullet_shield();

	if(IsDefined(has_intro) && has_intro)
	{
		anim_node anim_single_aligned(actors, anim_name + "_entry");
	}
		
	player = get_players()[0];
	while(!flag("flag_player_at_inclinator") && (DistanceSquared(actors[0].origin, player.origin) > (350*350)) )
	{
		anim_node anim_single_aligned(actors, anim_name);
	}
	actors[1] stop_magic_bullet_shield();
	anim_node anim_single_aligned(actors, anim_name + "_exit");

	if(goal_name == "animation")
	{
		actors[0].turnrate = 220;
		anim_node = GetNode("anim_mine_inclinator","targetname");
		anim_node anim_reach_aligned(actors[0], anim_name + "_enter");
		anim_node anim_single_aligned(actors[0], anim_name + "_enter");
		anim_node thread anim_loop_aligned(actors[0], anim_name + "_loop");
	}
	else
	{
		goal_pos = GetStruct(goal_name,"targetname").origin;
		actors[0].los_delete = true;
		actors[0] SetGoalPos( goal_pos );
	}
	
	flag_wait("mine_clean_up_2");

	mine_array_remove(actors);
}


//4 prisoners waiting in front of the elevator
event_2_vig_ready_passengers()
{
	anim_node = GetNode("anim_mine_inclinator","targetname");

	level.mine_passengers[0] = mine_create_prisoner("prisoner_1", false);
	wait(0.1);
	level.mine_passengers[1] = mine_create_prisoner("prisoner_2", false);
	wait(0.1);
	level.mine_passengers[2] = mine_create_prisoner("prisoner_4", false);
	wait(0.1);
	level.mine_passengers[3] = mine_create_prisoner("prisoner_5", false);
	
	level.mine_passengers[1] thread play_group_vox_on_guy();

	anim_node thread anim_loop_aligned(level.mine_passengers, "mine_wait_inclinator");

	flag_wait("flag_front_board");

	front_board = array_remove(level.mine_passengers, level.mine_passengers[2]);

	anim_node thread event_2_passenger_stay(level.mine_passengers[2]);
	anim_node anim_single_aligned(front_board, "mine_board_inclinator");

	elevator = GetEnt("elevator", "targetname");
	for(i = 0; i < front_board.size; i++)
	{
		front_board[i] LinkTo(elevator.anim_origin);
		front_board[i] DisableClientLinkTo();
		elevator.anim_origin thread anim_loop_aligned(front_board[i], "mine_ride_inclinator");
	}	

	flag_set("flag_front_passengers_in_inclinator");
}

event_2_passenger_stay(passenger)
{
	self anim_single_aligned(passenger, "mine_stay_behind");
	self thread anim_loop_aligned(passenger, "mine_stay_behind_loop");
}

event_2_vig_control_box_guy()
{
	anim_node = GetNode("anim_mine_inclinator","targetname");

	level.mine_control_guy = mine_create_prisoner("prisoner_cntrl", false);

	anim_node thread anim_loop_aligned(level.mine_control_guy, "mine_control_loop");

	//in case Sergei intro played out but player stayed back
	if( !flag("flag_sergei_intro_over") )
	{
		level waittill("reznov_coming");
		wait(6);
	}
	
	anim_node anim_single_aligned(level.mine_control_guy, "mine_control_move");
	anim_node thread anim_loop_aligned(level.mine_control_guy, "mine_control_wait");

	flag_wait("flag_front_board");

	anim_node anim_single_aligned(level.mine_control_guy, "mine_board_inclinator");

	elevator = GetEnt("elevator", "targetname");
	level.mine_control_guy LinkTo(elevator.anim_origin);
	level.mine_control_guy DisableClientLinkTo();
	elevator.anim_origin anim_loop_aligned(level.mine_control_guy, "mine_ride_inclinator");
}

event_3_inclinator()
{
	//get elevator script_brushmodels 
	elevator = GetEnt ("elevator", "targetname");
	elevator UseAnimTree(level.scr_animtree["inclinator"]);
	elevator.animname = "inclinator";

	elevator.clip = GetEnt("elevator_clip", "targetname");
	elevator.clip LinkTo(elevator);

	player_pos = getstruct("inclinator_player_pos","targetname");
	elevator.player_pos = spawn_a_model("tag_origin", player_pos.origin, player_pos.angles);
	elevator.player_pos LinkTo(elevator);

	anim_node = GetNode("anim_mine_inclinator","targetname");
	elevator.anim_origin = spawn_a_model("tag_origin", anim_node.origin, anim_node.angles);
	elevator.anim_origin LinkTo(elevator, "tag_origin");

	//start looping door anim
	elevator thread anim_loop(elevator, "front_door_loop");

	elevator.starting_pos = elevator.origin;

	elevator.clutter = GetEntArray("inclinator_clutter","targetname");
	for(i = 0; i < elevator.clutter.size; i++)
	{
		elevator.clutter[i] LinkTo(elevator);
	}

	//fx wires
	elevator.fx_wires = GetEnt( "fxanim_vorkuta_elevator_wires", "targetname" );
	elevator.fx_wires LinkTo(elevator, "tag_origin");
	
	//front elevator door
	elevator.front_door_clip = GetEnt("elevator_door_clip", "targetname");
	elevator.front_door_clip LinkTo(elevator, "anim_door_front");

	//back elevator door
	elevator.back_door_clip = GetEnt("elevator_door_back_clip", "targetname");
	elevator.back_door_clip LinkTo(elevator, "anim_door_back");

	spark_pos = GetStructArray("inclinator_spark_fx","targetname");
	for(i = 0; i < spark_pos.size; i++)
	{
		elevator.fx[i] = spawn_a_model("tag_origin", spark_pos[i].origin, spark_pos[i].angles);
		elevator.fx[i] LinkTo(elevator);
		PlayFXOnTag( level._effect["sparks_burst_1"], elevator.fx[i], "tag_origin");
	}

	//have reznov open inclinator door setting off several events
	level thread event_3_reznov_unlock_door(elevator);

	//brush trigger in the elevator
	inside_elevator = GetEnt ("inside_elevator", "targetname");
	players = get_players();

	//elevator wont go until player and reznov are inside of it (prisoners are already in)
	trigger_wait("inside_elevator");

	flag_set("flag_player_in_inclinator");

	level thread event_3_inclinator_light();

	players[0] lerp_player_view_to_tag( elevator.player_pos, "tag_origin", 0.8, 1, 70, 70, 15, 15);
	players[0] SetLowReady(true);
	players[0] AllowMelee(false);

	//turn off mine FX
	stop_exploder(1000);
		
	//remove any enemy guards so they don't kill the player
	array_thread(GetAIArray("axis"), ::stop_magic_bullet_shield);
	array_thread(GetAIArray("axis"), ::ragdoll_death);

	//make sure everyone is on board before taking off
	flag_wait("flag_reznov_in_inclinator");
	flag_wait("flag_sergei_in_inclinator");
	flag_wait("flag_front_passengers_in_inclinator");

	//start VO between reznov and prisoner
	flag_set("flag_inclinator_moving");

	level thread event_3_vig_exit_room(elevator);

	//close door
	elevator.front_door_clip PlaySound( "evt_elev_door_close" );
	players[0] PlaySound( "evt_elev_go_start" );
	players[0] PlayRumbleLoopOnEntity("damage_light");
	
	//2 seconds for the fake door shut
	wait(2);

	//big close rumble
	players[0] PlayRumbleLoopOnEntity("damage_heavy");
	StopAllRumbles();
		
	wait(1); //C.Ayers - For Audio Purposes
    players[0] thread elevator_scrape_oneshots( elevator );
    
    //TUEY Sets the music back to the Underscore
    setmusicstate("UNDERSCORE");
    
	destination = GetStruct("inclinator_end","targetname");
	elevator MoveTo(destination.origin, 25, 10, 5);
	players[0] thread event_3_shake_player(23);
	players[0] PlayLoopSound( "evt_elev_go_looper", .25 );
	
	//start fx wires
	flag_set("elevator_wires_start");

	elevator waittill("movedone");
	players[0] StopLoopSound( .5 );
	players[0] PlaySound( "evt_elev_go_end" );

	//move the prisoners onto the elevator
	level thread event_3_board_and_exit_inclinator();

	//stop fx wires
	flag_clear("elevator_wires_start");

	//open gate
	gate = GetEnt("mine_gate","targetname");
	gate_collision = GetEnt("mine_gate_collision","targetname");
	gate_collision LinkTo(gate);
	gate MoveZ(190,4,4);
	players[0] PlayRumbleOnEntity("damage_light");

	//TUEY set music to Sergei Axe
	setmusicstate ("SERGEI_AXE");

	//sergei is going in for the kill, unlock the player
	flag_wait("flag_sergei_skewer");

	//open rear door
	players[0] PlayRumbleLoopOnEntity("damage_light");
	elevator.back_door_clip PlaySound( "evt_elev_door_open" );
	elevator anim_single(elevator, "back_door_open");
	players[0] PlayRumbleOnEntity("damage_heavy");
	StopAllRumbles();

	//turn on FX in Omaha
	exploder(1200);
	exploder(1300);

	level thread event_3_player_armed();

	players[0] Unlink();
	SetSavedDvar( "r_enableFlashlight","0" );   
	players[0] SetLowReady(false);
	players[0] AllowMelee(true);

	level thread event_3_remove_inclinator(elevator);
}

event_3_inclinator_light()
{
	brightness = 0.0;

	SetSavedDvar( "r_flashLightRange", "436" );
	SetSavedDvar( "r_flashLightEndRadius", "500" );
	SetSavedDvar( "r_flashLightBrightness", brightness );
	SetSavedDvar( "r_flashLightOffset", "-10.3 -7.8 -4.2" );
	SetSavedDvar( "r_flashLightFlickerAmount", "0.2" );
	SetSavedDvar( "r_flashLightFlickerRate", "62" );
	SetSavedDvar( "r_flashLightColor", "1 1 1" );
	SetSavedDvar( "r_enableFlashlight","1" );   

	while(brightness < 5.0)
	{
		brightness += 0.05;
		SetSavedDvar( "r_flashLightBrightness", brightness );
		wait(0.05);
	}
}

event_3_audio_01(elevator)
{
	player = get_players()[0];
	player.animname = "mason";

	flag_wait("flag_player_at_inclinator");

	wait(4.5);
	level thread play_prisoner_crowd_vox( "vox_vor1_s99_303A_rrd5", "vox_vor1_s99_304A_rrd6", "vox_vor1_s99_305A_rrd7" );
	
	flag_wait("flag_player_in_inclinator");
	flag_wait("flag_reznov_in_inclinator");
	flag_wait("flag_front_passengers_in_inclinator");
	
	level.mine_passengers[1] anim_set_blend_in_time(0.2);
	level.mine_passengers[1] anim_set_blend_out_time(0.2); 

	elevator.anim_origin thread event_3_inclinator_conversation(level.reznov);
	elevator.anim_origin thread event_3_inclinator_conversation(level.mine_passengers[1]);
}

event_3_inclinator_conversation(actor)
{
	self anim_single_aligned(actor, "mine_inclinator_talk");
	if(!flag("flag_sergei_skewer"))
	{
		self anim_loop_aligned(actor, "mine_inclinator_talk_loop");
	}	
}

event_3_audio_02()
{
	player = get_players()[0];
	player.animname = "mason";

	//You know your men will die?
	anim_single(player, "mine_exit_02");
	wait(2);
}

event_3_pick_up_axe(sergei)
{
	sergei Attach("p_rus_vork_pickaxe_sergei","tag_weapon_right");

	pick_axe = GetEnt("sergei_axe","targetname");
	pick_axe Delete();

}

event_3_remove_inclinator(elevator)
{
	player = get_players()[0];

	flag_wait("flag_exit_mine");

	while(Distance2DSquared(elevator.origin, player.origin) < 600*600)
	{
		wait(0.05);
	}

	gate = GetEnt("mine_gate","targetname");
	gate MoveZ(-190,2,2);

	elevator.back_door_clip PlaySound( "evt_elev_door_open" ); 
	elevator anim_single(elevator, "back_door_close");
	
	elevator MoveTo(elevator.starting_pos, 20, 13, 5);
	elevator waittill("movedone");

	//wait until the player is at the cart so they can't see the inclinator was removed
	trigger_wait("start_cart");

	//delete all the elevator parts
	elevator Delete();
	elevator.player_pos Delete();
	elevator.clip Delete();
	elevator.front_door_clip Delete();
	elevator.back_door_clip Delete();
	elevator.fx_wires Delete();
	for(i = 0; i < elevator.clutter.size; i++)
	{
		elevator.clutter[i] Delete();
	}
	for(i = 0; i < elevator.fx.size; i++)
	{
		elevator.fx[i] Delete();
	}
}

event_3_shake_player(time)
{
	Earthquake(0.3, 0.5, self.origin, 256);
	self PlayRumbleOnEntity("grenade_rumble");

	//convert to frames per second
	while(time >= 0)
	{
		Earthquake(0.1, 0.5, self.origin, 256);
		self PlayRumbleOnEntity("damage_heavy" );
		wait(1);
		time--;
	}

	Earthquake(0.3, 0.5, self.origin, 256);
	self PlayRumbleOnEntity("grenade_rumble");
}

//the rear passengers that close up on the player
event_3_russians_board()
{
	anim_node = GetNode("anim_mine_sergei","targetname");
	anim_node anim_single_aligned(self, "intro_sergei_wall_exit");
	anim_node = GetNode("anim_mine_inclinator","targetname");
	array_thread(self, ::event_3_russians_wait, anim_node);
}

event_3_sergei_board()
{
	anim_node = GetNode("anim_mine_inclinator","targetname");
	anim_node anim_reach_aligned(level.sergei, "approach_inclinator");
	anim_node anim_single_aligned(level.sergei, "approach_inclinator");
	anim_node thread anim_loop_aligned(level.sergei, "unlock_inclinator");

	flag_wait("flag_sergei_board");

	anim_node anim_single_aligned(level.sergei, "mine_board_inclinator");
	
	elevator = GetEnt ("elevator", "targetname");
	level.sergei LinkTo(elevator.anim_origin);
	level.sergei DisableClientLinkTo();
	elevator.anim_origin thread anim_loop_aligned(level.sergei, "mine_ride_inclinator");

	flag_set("flag_sergei_in_inclinator");
}

event_3_russians_wait(anim_node)
{
	anim_node anim_reach_aligned(self, "approach_inclinator");
	anim_node anim_single_aligned(self, "approach_inclinator");
	anim_node thread anim_loop_aligned(self, "unlock_inclinator");
}

event_3_reznov_unlock_door(elevator)
{
	anim_node = GetNode("anim_mine_inclinator","targetname");

	flag_wait("flag_sergei_intro_over");

	level notify("reznov_coming");

	anim_node anim_reach_aligned(level.reznov, "unlock_inclinator_enter");
	anim_node anim_single_aligned(level.reznov, "unlock_inclinator_enter");
	anim_node thread anim_loop_aligned(level.reznov, "unlock_inclinator_loop");

	flag_wait("flag_player_at_inclinator");

	autosave_by_name("vorkuta_mine_02");

	level thread event_3_audio_01(elevator);
	level thread event_3_open_inclinator_door(elevator);
	
	anim_node anim_single_aligned(level.reznov, "unlock_inclinator");	

	elevator = GetEnt ("elevator", "targetname");
	level.reznov LinkTo(elevator.anim_origin);
	elevator.anim_origin thread anim_loop_aligned(level.reznov, "mine_ride_inclinator");

	flag_set("flag_reznov_in_inclinator");

}

event_3_open_inclinator_door(elevator)
{
	flag_wait("flag_front_board");

	elevator.front_door_clip PlaySound( "evt_elev_door_open_first" ); 
	level clientnotify( "ele" );
	elevator anim_single(elevator, "front_door_open");
}

event_3_board_and_exit_inclinator()
{
	//all passengers that are not reznov and sergei
	passengers[0] = level.mine_russians[0];
	passengers[1] = level.mine_russians[1];
	passengers[2] = level.mine_passengers[0];
	passengers[3] = level.mine_passengers[1];
	passengers[4] = level.mine_passengers[2];
	passengers[5] = level.mine_passengers[3];
	passengers[6] = level.mine_control_guy;
	
	flag_wait("flag_sergei_skewer");

	for(i = 0; i < passengers.size; i++)
	{
		passengers[i] UnLink();
	}
		
	anim_node = GetNode("anim_mine_exit_room","targetname");
	array_thread(passengers, ::event_4_passenger_exit_inclinator, anim_node);
}

event_3_vig_exit_room(elevator)
{
	flag_wait("mine_clean_up_2");

	trigger = GetEnt("mine_los_delete","targetname");
	trigger Delete();

	gun_pos = GetEntArray("mine_exit_gun","targetname");
	for(i = 0; i < gun_pos.size; i++)
	{
		guard = create_guard_model(undefined, gun_pos[i].origin);
		guard StartRagdoll();
	}

	//critical wait time to start the top stairs cutscene
	wait(0.8);

	anim_node = GetNode("anim_mine_exit_room","targetname");

	//guard who shoots two prisoners and gets skewered
	actors[0] = simple_spawn_single("inclinator_exit_guard");
	actors[1] = mine_create_prisoner("prsnr1");
	actors[1].takedamage = true;
	actors[2] = mine_create_prisoner("prsnr2");
	actors[2].takedamage = true;

	//prisoners watching guard get skewered who move to the door
	prisoners[0] = mine_create_prisoner("prsnr3");
	prisoners[1] = mine_create_prisoner("prsnr4");
	prisoners[2] = mine_create_prisoner("prsnr5");
	prisoners[3] = mine_create_prisoner("prsnr6");

	anim_node thread anim_single_aligned(actors, "mine_sergei_vs_guard");
	
	//move living prisoners to the door
	array_thread(prisoners, ::event_3_move_to_door, anim_node);

	wait(0.1);
	//level thread event_3_vig_skirmish_1(anim_node);
	wait(0.1);
	//level thread event_3_vig_skirmish_2(anim_node);
	
	flag_wait("flag_sergei_skewer");

	level notify("get_off_inclinator");
		
	level.sergei UnLink();
	level.reznov UnLink();

	level.reznov thread event_4_reznov(anim_node);
	anim_node anim_single_aligned(level.sergei, "mine_sergei_vs_guard");
	
	//move sergei and reznov to the door
	level.sergei thread event_4_sergei(anim_node);
}

event_3_drop_axe(sergei)
{
	axe = Spawn( "script_model", sergei GetTagOrigin("tag_weapon_right") );
	axe.angles = sergei GetTagAngles("tag_weapon_right");
	axe SetModel( "p_rus_vork_pickaxe_sergei" );
	axe PhysicsLaunch();
	sergei Detach("p_rus_vork_pickaxe_sergei", "tag_weapon_right");
}

event_3_bleed( guard )
{
	guard endon("death");

	//if not mature setting return
	if( !is_mature() )
	{
		return;
	}

	PlayFXOnTag(level._effect["impale_blood_long"], guard, "J_SpineUpper");
	
	for(i = 0; i < 5; i++)
	{
		PlayFXOnTag(level._effect["impale_blood"], guard, "J_SpineUpper");
		wait(0.5);
	}
	
}

event_3_move_to_door(anim_node)
{
	self.turnrate = 220;
	anim_node anim_single_aligned(self, "mine_sergei_vs_guard");
	anim_node anim_reach_aligned(self, "move_to_door");
	anim_node anim_single_aligned(self, "move_to_door");
	anim_node thread anim_loop_aligned(self, "mine_exit_ready");
}

event_3_vig_skirmish_1(anim_node)
{
	actors[0] = mine_create_guard("guard");
	actors[1] = mine_create_prisoner("fight3_prisoner_1");
		
	anim_node thread anim_loop_aligned(actors, "exit_fight_05_loop");

	level waittill("get_off_inclinator");

	anim_node anim_single_aligned(actors[0], "exit_fight_05_exit");
	actors = array_remove(actors, actors[0]);
	anim_node anim_single_aligned(actors, "exit_fight_05_exit");
	anim_node thread anim_loop_aligned(actors, "mine_exit_ready");

	flag_set("flag_skirmish_1_done");
}

event_3_vig_skirmish_2(anim_node)
{
	actors[0] = mine_create_prisoner("fight4_prisoner_1");
	actors[1] = mine_create_prisoner("fight4_prisoner_2");
	
	anim_node thread anim_loop_aligned(actors, "exit_fight_06_loop");

	level waittill("get_off_inclinator");

	anim_node anim_single_aligned(actors, "exit_fight_06_exit");
	anim_node thread anim_loop_aligned(actors, "mine_exit_ready");

	flag_set("flag_skirmish_2_done");
}

event_3_player_armed()
{	
	player = get_players()[0];
	player SetMoveSpeedScale(1);
	player AllowProne(true);
	player.overridePlayerDamage = undefined;

	while( player GetWeaponsListPrimaries().size < 2)
	{
		wait(0.05);
	}

	player TakeWeapon("vorkuta_knife_sp");	

	player_weapons = player GetWeaponsListPrimaries();
	for(i = 0; i < player_weapons.size; i++)
	{
		player GiveMaxAmmo( player_weapons[i] );
	}	
}	

event_4_exit()
{
	array_thread(GetEntArray("omaha_guard","script_noteworthy"), ::add_spawn_function, maps\vorkuta_surface::prisoner_guard_think);

	//wait for the player and everyone else to be at the doors
	/*if( !IsDefined(level.tower_start) )
	{
		flag_wait("flag_skirmish_1_done");
		flag_wait("flag_skirmish_2_done");
	}	*/
	
	flag_wait("flag_exit_mine");

	//TUEY set music state to OPEN_THE_DOOR
	setmusicstate ("OPEN_THE_DOOR");
	clientnotify( "ext" );  //C. Ayers - Changing snapshot

	level thread event_4_lamp_pulse();
	level thread event_4_hanging_bodies();
	level thread event_4_bridge();
	level thread event_4_damage_player();

	//play the anim of everyone pushing the doors open
	anim_node = GetNode("anim_mine_exit_room","targetname");
	passengers = GetAIArray("allies");
	passengers = array_remove(passengers, level.reznov);
	passengers = array_remove(passengers, level.sergei);
	array_thread(passengers, ::event_4_exit_think, anim_node);

	//prepare the doors to animate open
	doors = GetEnt("omaha_exit_doors", "targetname");	
	door_l = GetEnt("tunnel_door1_clip", "targetname");
	door_l LinkTo(doors, "hinge_right");
	door_r = GetEnt("tunnel_door2_clip", "targetname");
	door_r LinkTo(doors, "hinge_left");
	doors useanimtree(level.scr_animtree["omaha_door"]);
	doors.animname = "omaha_door";
		
	//initial drone waves outside
	drone_trigger = GetEnt("drone_omaha_initial_waves","script_noteworthy");
	drone_trigger notify("trigger");

	//slide open the door in omaha that will shut
	sliding_door = GetEnt("omaha_rollup_door", "targetname");
	sliding_door MoveZ(100, 0.05);
	sliding_door waittill("movedone");
	sliding_door ConnectPaths();

	//fx during door opening
	exploder( 1 );

	door_l PlaySound( "evt_upper_room_door_l" );
	door_r PlaySound( "evt_upper_room_door_r" );

	autosave_by_name("vorkuta_mine_exit");

	flag_set ("tower_start");

	//open the doors
	anim_node thread anim_single_aligned(doors, "omaha_exit");

	//fix for a bug where firing outside would fail the player to friendly fire
	level.friendlyFireDisabled = 1;

	//remove the invisible collision that prevented player getting stuck in Prisoner anims
	wall = GetEnt("mine_exit_blocker","targetname");
	wall Delete();

	//connect paths as doors open
	for(i = 0; i < 10; i++)
	{
		door_l ConnectPaths();
		door_r ConnectPaths();	
		wait(1);
	}

	//reset friendly fire after 10 seconds
	level.friendlyFireDisabled = 0;
}

event_4_exit_mg()
{
	self endon("flag_bridge_done");

	position = getstruct("omaha_bridge_target","targetname").origin;
	tower_mg = GetEnt( "tower_mg", "targetname" );

	guards = GetEntArray("omaha_bridge_guard_ai","targetname");
	
	//fire at players feet
	pos[0] = position + (-72,32,0 );
	pos[1] = position + ( 72,48,0 );
	pos[2] = position + ( -72,112,0 );
	pos[3] = position + ( -72,96,0 );
	pos[4] = position + ( 72,96,0 );
	pos[5] = position + ( -72,72,0 );
	pos[6] = position + ( -72,64,0 );
	pos[7] = position + ( -72,48,0 );

	while(1)
	{
		for(i = 0; i < guards.size; i++)
		{
			index = RandomInt(pos.size);
			MagicBullet( "ak47_sp", guards[i] GetTagOrigin("tag_flash"), pos[index] );
		}
		wait (0.3);	
	}
}

event_4_exit_think(anim_node)
{
	self endon("death");
	self anim_set_blend_in_time(0.5);
	self anim_set_blend_out_time(0.5); 

	self.takedamage = true;
	anim_node anim_single_aligned(self, "mine_exit_final");
	self event_4_exit_impacts();
	self ragdoll_death();
}

event_4_notetrack_impacts(prisoner)
{
	prisoner.a.nodeath = true;
	prisoner.allowdeath = true;
	for(i = 0; i < 2; i++)
	{
		prisoner event_4_exit_impacts();
		wait( RandomFloatRange(0.1,0.5) );
	}	
}

event_4_exit_impacts()
{
	tags = [];
	tags[0] = "j_hip_le";
	tags[1] = "j_hip_ri";
	tags[2] = "j_head";
	tags[3] = "j_spine4";
	tags[4] = "j_elbow_le";
	tags[5] = "j_elbow_ri";
	tags[6] = "j_clavicle_le";
	tags[7] = "j_clavicle_ri";

	random = RandomInt(tags.size);
	fxName = level._effect["bloody_death"][ RandomInt(level._effect["bloody_death"].size) ];

	if(IsDefined(self))
	{
		if( is_mature() )
		{
			PlayFxOnTag( fxName, self, tags[random] );
		}
		self PlaySound ("prj_bullet_impact_large_flesh");
	}	
}

event_4_passenger_exit_inclinator(anim_node)
{
	anim_node anim_single_aligned(self, "exit_inclinator");
	anim_node anim_reach_aligned(self, "mine_exit_inclinator");
	anim_node anim_single_aligned(self, "mine_exit_inclinator");
	level notify( "guys_at_door" );
	anim_node anim_loop_aligned(self, "mine_exit_ready");
}

event_4_reznov(anim_node)
{
	anim_node anim_single_aligned(self, "mine_sergei_vs_guard");
	anim_node anim_reach_aligned(self, "exit_inclinator");
	anim_node anim_single_aligned(self, "exit_inclinator");
	anim_node thread anim_loop_aligned(self, "exit_door_loop");

	player = get_players()[0];

	//look at player
	self LookAtEntity(player);

	//set from a player trigger by the exit
	flag_wait("flag_everyone_at_doors");

	anim_single(player, "mine_exit_02", "mason");
	anim_node anim_single_aligned(self, "exit_speech");

	flag_wait("flag_exit_mine");

	//clear look at
	self LookAtEntity();

	self thread event_4_reznov_warning(anim_node);
	anim_node thread anim_loop_aligned(self,"exit_door_open_loop");

	flag_wait("flag_bridge_done");
	
	//in case Reznov is warning player to stay back
	wait(0.5);
	
	//switch from reznov to the minecart
	flag_set("flag_obj_step_3");

	anim_node anim_single_aligned(self, "exit_final");
	
	cart_right = GetEnt( "cart_right", "targetname" );
	cart_right maps\vorkuta_surface::tower_cart_anim( self );
}

event_4_reznov_warning(anim_node)
{
	level endon("flag_bridge_done");

	flag_wait("flag_bridge_early");

	//self thread anim_single( level.reznov, "omaha_back" );
	anim_node anim_single_aligned(self, "exit_warn");
	anim_node anim_loop_aligned(self,"exit_door_open_loop");
}

event_4_sergei(anim_node)
{
	level.sergei EnableClientLinkTo();
	anim_node anim_reach_aligned(self, "exit_inclinator");
	anim_node anim_single_aligned(self, "exit_inclinator");
	anim_node thread anim_loop_aligned(self, "exit_door_loop");

	flag_wait("tower_start");

	wait(3);

	anim_node anim_single_aligned(self, "exit_flinch");
	anim_node thread anim_loop_aligned(self, "exit_door_open_loop");

	flag_wait("flag_bridge_done");

	//offset from Reznov's exit
	wait(1.5);

	anim_node anim_single_aligned(self, "exit_final");

	cart_right = GetEnt( "cart_right", "targetname" );
	cart_right maps\vorkuta_surface::tower_cart_anim( self );
}

event_4_lamp_pulse()
{
	structs = GetStructArray("omaha_lamp_pulse","targetname");
	for(i = 0; i < structs.size; i++)
	{
		PhysicsExplosionSphere(structs[i].origin, 32, 28, 0.2);
	}	
}

event_4_hanging_bodies()
{
	structs = getstructarray( "hanging_guy", "targetname" );

	for(i = 0; i < structs.size; i++)
	{
		guy = create_prisoner_model("generic", structs[i].origin + (0, 0, -72));
		structs[i].ropeid = CreateRope( structs[i].origin, (0,0,0), 72, guy, structs[i].script_noteworthy, 1 );
		guy startragdoll();
	}

	flag_wait("flag_cart_start");

	for(i = 0; i < structs.size; i++)
	{
		RopeRemoveAnchor(structs[i].ropeid, 0.5);
	}
}

event_4_bridge()
{
	start_anim[0]  = %ch_vor_b02_bridge_guard1;
	start_anim[1]  = %ch_vor_b02_bridge_guard2;
	start_anim[2]  = %ch_vor_b02_bridge_guard3;

	anim_node = GetStruct("omaha_bridge","targetname");
	anchor = Spawn( "script_origin", anim_node.origin );
	shoot_target = Spawn( "script_origin", GetStruct("omaha_bridge_target","targetname").origin);

	//spawn guards before the doors open
	bridge_guards = [];
	for(i = 0; i < 3; i++)
	{
		num = i + 1;
		bridge_guards[i] = simple_spawn_single( "omaha_bridge_guard", ::event_4_bridge_guards_think, shoot_target );
		bridge_guards[i].dropweapon = 0;
		bridge_guards[i].animname = "guard_" + num;
		bridge_guards[i] forceteleport( GetStartOrigin(anim_node.origin, anim_node.angles, start_anim[i]), GetStartAngles(anim_node.origin, anim_node.angles, start_anim[i]) );
		bridge_guards[i] LinkTo(anchor);
		wait(0.1);
	}
	
	flag_wait( "tower_start" );

	level thread event_4_audio_01();
	level thread event_4_exit_mg();

	//vignettes
	level thread event_4_vig_kick("anim_node_cart_vig1");
	level thread event_4_vig_kick("anim_node_bridge_vig1");

	wait(3);	

	//spawn prisoners for the anim
	prisoners = [];
	for(i = 0; i < 3; i++)
	{
		num = i + 1;
		prisoners[i] = mine_create_prisoner("prisoner_" + num);
		prisoners[i].noDodgeMove = true; 
		wait(0.1);
	}

	actors = array_combine(bridge_guards, prisoners);
	array_thread(actors, ::event_4_bridge_think, anim_node);
	
	level thread play_bridge_audio( anim_node.origin );
	
	wait(5);
	
	flag_set("flag_bridge_done");

	wait(15);
	
	//looping drones on bridge
	drone_trigger = GetEnt("drone_omaha_bridge","script_noteworthy");
	drone_trigger notify("trigger");

	anchor Delete();

	level waittill( "stop_omaha_drones" );

	drone_trigger notify("stop_drone_loop");
	level thread remove_drone_structs(drone_trigger);
}

event_4_panel_1(guard)
{
	level notify("bridge01_start");
	guard.takedamage = true;
}

event_4_panel_2(guard)
{
	level notify("bridge02_start");
	guard.takedamage = true;
}

event_4_bridge_think(anim_node)
{
	self endon("death");
    
    self thread play_fake_death_vox( anim_node.origin );
    
	self UnLink();
	self ClearEntityTarget();
	anim_node anim_single_aligned(self, "omaha_bridge");
	
	self SetGoalPos( GetStruct("omaha_bridge_goal","targetname").origin );
	self waittill("goal");
	self Delete();
}

event_4_audio_01()
{
	flag_wait("flag_bridge_done");

	anim_single( level.reznov, "omaha_mason" );

	trigger_wait("start_cart");

	//clear look at
	level.reznov LookAtEntity();

	anim_single( get_players()[0], "omaha_tower", "rrd2" );
	wait(0.5);
	anim_single( level.reznov, "omaha_faith" );
}

event_4_bridge_guards_think(shoot_target)
{
	self set_ignoreall(true);
	self.takedamage = false;
	self AllowedStances( "crouch" );
	self.goalradius = 32;

	flag_wait( "tower_start" );
	self AllowedStances( "stand" );
	self SetEntityTarget(shoot_target);
}

event_4_vig_kick(anim_node_name)
{
	actors[0] = mine_create_prisoner("prisoner");
	actors[1] = mine_create_guard("guard");
	
	anim_node = GetNode(anim_node_name,"targetname");
	anim_node thread anim_loop_aligned(actors,"mine_vig_pre_sergei_01");
	wait(1);
	actors[1] EnableAimAssist();
	actors[1] waittill_notify_or_timeout("death", 40);

	array_thread(actors, ::ragdoll_death);
}

event_4_damage_player()
{
	player = get_players()[0];
	player endon("death");

	source = getstruct("omaha_hurt_radius","targetname");
	player_exposed = false;

	damage_source = GetEnt("tower_mg","targetname");

	//immediate damage check outside the door until the guards are killed
	while( !flag("flag_bridge_done") )
	{
		if(player.origin[1] > source.origin[1])
			player_exposed = true;
		else
			player_exposed = false;

		//if the player is outside of the building do damage
		if(player_exposed)
		{
			flag_set("flag_bridge_early");
			player DoDamage(40, damage_source.origin, damage_source, undefined, "MOD_PISTOL_BULLET");
		}

		wait(0.25);
	}

	//check a wider radius while the player is moving to the cart
	while( !flag("flag_cart_start") )
	{
		player_dis = Distance2D(player.origin, source.origin);

		if(player.origin[1] > source.origin[1])
			player_exposed = true;
		else
			player_exposed = false;

		if(player_exposed && (player_dis > source.radius) ) 
		{
			player DoDamage(40, level.tower_guards[0].origin, level.tower_guards[0], undefined, "MOD_PISTOL_BULLET");
		}

		wait(0.25);
	}
}

mine_spawn_funcs()
{
	array_thread( GetEntArray("mine_prisoner_tunnel","script_noteworthy"), ::add_spawn_function, ::mine_setup_prisoner, true, "mine_prisoner_goal_tunnel_1");
	array_thread( GetEntArray("mine_prisoner_tunnel_top","script_noteworthy"), ::add_spawn_function, ::mine_setup_prisoner, true, "mine_prisoner_goal_rail_crowd");
}

mine_setup_reznov()
{
	level.reznov = simple_spawn_single ("reznov", maps\_prisoners::make_prisoner);
	level.reznov.name = "Reznov";
	level.reznov anim_set_blend_in_time(0.2);
	level.reznov anim_set_blend_out_time(0.2); 
	//level.reznov.noDodgeMove = true;
}

mine_setup_player()
{
	//take player weapons and set speed
	player = get_players()[0];

	//remove the weapons
	player TakeAllWeapons();

	//scale speed of player
	player SetMoveSpeedScale(0.8);

	//disable prone
	player AllowProne(false);

	//override the player damage function so that baton hits scale based on difficulty
	player.overridePlayerDamage = ::mine_melee_damage;
}

mine_create_guard(animname)
{
	guard = simple_spawn_single("mine_guard", maps\_baton_guard::make_baton_guard);
	guard.animname = animname;
	guard.dropweapon = 0;
	guard.allowDeath = true;

	guard DisableAimAssist();

	return guard;
}

mine_create_prisoner(animname, los_delete, goal_name)
{
	prisoner = simple_spawn_single("mine_prisoner");
	prisoner.animname = animname;
	prisoner.takedamage = false;

	//for secured head variation
	if(!IsDefined(level.prisoner_head_index))
	{
		level.prisoner_head_index = 0;
	}

	//remove random head and replace with linear head
	head_array = xmodelalias\c_rus_prisoner_headalias::main();
	prisoner detach(prisoner.headModel);

	//the four special cases are the inclinator passengers
	switch(prisoner.animname)
	{
	case "prisoner_cntrl":
		prisoner.headModel = head_array[1];
		break;
	case "prisoner_1":
		prisoner.headModel = head_array[2];
		break;
	case "prisoner_2":
		prisoner.headModel = head_array[0];
		break;
	case "prisoner_5":
		prisoner.headModel = head_array[3];
		break;
	default:
		prisoner.headModel = head_array[level.prisoner_head_index];
		break;
	}
	prisoner attach(prisoner.headModel, "", true);

	//keep the index within the size of the array of heads
	level.prisoner_head_index++;
	if(level.prisoner_head_index == head_array.size)
	{
		level.prisoner_head_index = 0;
	}

	prisoner thread maps\_prisoners::make_prisoner();

	if(!IsDefined(los_delete))
	{
		los_delete = true;
	}

	if(los_delete)
	{
		prisoner.los_delete = true;
	}

	if(IsDefined(goal_name))
	{
		goal_pos = GetStruct(goal_name,"targetname").origin;

		prisoner SetGoalPos( goal_pos );
	}

	return prisoner;
}

mine_setup_prisoner(los_delete, goal_name)
{
	self thread maps\_prisoners::make_prisoner();

	if(!IsDefined(los_delete))
	{
		los_delete = true;
	}

	if(IsDefined(goal_name))
	{
		goal_pos = GetStruct(goal_name,"targetname").origin;

		self SetGoalPos( goal_pos );
	}
	
	if(los_delete)
	{
		self.los_delete = true;
	}
}	

mine_melee_damage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	if( sMeansOfDeath == "MOD_MELEE" )
	{
		switch( GetDifficulty() )
		{
		case "hard":
			iDamage = iDamage + 50;
			break;
		case "fu":
			iDamage = self.health + 100;
			break;			
		}
	}

	return iDamage;
}

mine_array_remove( array )
{
	for(i = 0; i < array.size; i++)
	{
		if(IsDefined(array[i]))
		{
			array[i] Delete();
		}
	}
}

elevator_scrape_oneshots( elevator )
{
    elevator endon( "movedone" );
    
    wait( 4 );
    
    for( i=0; i<3; i++ )
    {
        playsoundatposition( "evt_elev_scrape_" + i, (0,0,0) );
        wait(RandomIntRange( 4, 7 ) );
    }
}

play_bridge_audio( origin )
{
    ent = Spawn( "script_origin", origin );
    ent PlayLoopSound( "amb_vox_group_fighting_1" );
    flag_wait("flag_bridge_done");
    ent PlayLoopSound( "amb_vox_group_running_0" );
    playsoundatposition( "amb_vox_fight_end_cheer_1", origin );
    level waittill( "stop_omaha_drones" );
    ent Delete();
}

play_fake_death_vox( origin )
{
    self waittill( "death" );
    playsoundatposition( "dds_ru" + RandomIntRange(0,3) + "_death", origin );
}

play_group_vox_on_guy()
{
    player = get_players()[0];
    ent = Spawn( "script_origin", player.origin );
    ent LinkTo( player );
    
    self PlayLoopSound( "amb_vox_fight_joking_loop_0", 2 );
	flag_wait("flag_front_board");
    self StopLoopSound( 1 );
    level thread play_prisoner_crowd_vox( "vox_vor1_s99_321A_rrd5", "vox_vor1_s99_322A_rrd6", "vox_vor1_s99_323A_rrd7" );
    //level waittill("back_board");
    ent PlayLoopSound( "amb_vox_fight_joking_loop_0", 2 );
    level waittill( "get_off_inclinator" );
    ent StopLoopSound( 1 );
    playsoundatposition( "amb_vox_fight_cheer_3", self.origin );
    level waittill( "guys_at_door" );
    ent Delete();
    self PlayLoopSound( "amb_vox_fight_gearup_loop_1", 1 );
    flag_wait("flag_exit_mine");
    level thread play_prisoner_crowd_vox( "vox_vor1_s99_324A_rrd5", "vox_vor1_s99_325A_rrd6", "vox_vor1_s99_326A_rrd7" );
    self StopLoopSound( 1 );    
}