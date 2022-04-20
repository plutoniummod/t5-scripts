/*
	
	KOWLOON E4 Rooftop Battle

	This starts when the player enters the balcony facing the large rooftop battle.
	It ends when we get to the slide-down roof.
*/
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim; 
#include maps\_music;

event4()
{
	flag_wait( "event4" );
	
	//TUEY Set music to ROOFTOPS_ONE
	level thread maps\_audio::switch_music_wait("ROOFTOPS_ONE", 3);

	level thread rooftop_battle();
	level thread pipe_slide();
	level thread temple_roof();

	level thread trigger_rooftop_dialog();
	level thread rigged_watertank_leak();

	level thread maps\kowloon_slide_in_and_out::event5();

	// Wait for the end of the event
	flag_wait( "event5" );
	wait( 0.05 );	// Wait for event5 threads to start

	// Savegame is at the end of the current even so that it doesn't 
	// save immediately after starting a jumpto
	autosave_by_name( "kowloon_slide" );
}


//	Battle without honor or humanity
//
rooftop_battle()
{
	level thread rooftop_battle_advance();
	level thread ai_redirect( "trig_e4_roof_drop_low", "trig_e4_roof_drop", level.ai_e4_roof_drop, "ai_e4_roof_drop", "e4_rooftop_ne_low" );
	level thread ai_redirect( "trig_e4_roof_mid_low",  "trig_e4_roof_mid",  level.ai_e4_roof_mid,  "ai_e4_roof_mid",  "e4_rooftop_e_low" );

	level notify( "civilians" );
	
	// Civs come running out
	ai = simple_spawn( "ai_e4_start_civs", maps\kowloon_util::delete_on_goal );
	array_thread( ai, ::play_civilian_yells );
	array_thread( ai, maps\kowloon_util::civ_timeout_death );

	ai = simple_spawn( "ai_e4_roof_start" );

	if( level.gameskill == 3 )
	{
		array_thread( ai, maps\kowloon_util::reduce_accuracy_veteran );
	}

	ai[0] thread spez_roof_dialog();
	// Then 
	trigger_wait( "trig_e4_roof_drop" );

	level thread maps\kowloon_util::spawn_airplane( "ss_747_e4", "evt_jet_flyover_2" );

	// Civs come running out
	ai = simple_spawn( "ai_e4_start_civs2", maps\kowloon_util::delete_on_goal );
	array_thread( ai, maps\kowloon_util::civ_timeout_death );

	array_thread( ai, ::play_civilian_yells );
	door = GetEnt( "e4_shack_door", "targetname" );
	door RotateYaw( 135, 0.7 );
	door ConnectPaths();
	door waittill( "rotatedone" );

	level.ai_e4_roof_drop = simple_spawn( "ai_e4_roof_drop" );
	ai_e4_roof_drop_single = simple_spawn_single( "ai_e4_roof_drop_single" );

	// Mid-point
	trigger_wait( "trig_e4_roof_mid" );

	level thread maps\kowloon_anim::rooftop_rappel();
	ai = simple_spawn( "ai_e4_roof_mid_windows" );
	level.ai_e4_roof_mid = simple_spawn( "ai_e4_roof_mid" );

	trigger_wait( "trig_e4_stairs_down" );

	level notify("objective_pos_update" );	// Head to pipe

	// End
	trigger_wait( "trig_e4_roof_end" );

//	level thread background_rappel_guys();	

//	autosave_by_name( "kowloon_rooftop_end" );
	wait(0.05);

	ai = simple_spawn( "ai_e4_roof_end", maps\kowloon_util::force_goal_self );

	// Waittill trigger or e4_alley aigroup cleared
	trig = GetEnt( "trig_e4_pipe_ready", "targetname" );
	waittill_any_ents( trig, "trigger", level, "e4_alley_cleared" );

	level notify( "head_to_the_pipe" );
	level.heroes[ "clarke" ] thread maps\kowloon_anim::npc_pipe_slide( "n_pipe_wait_clarke" );
	wait( 4.0 );
	level.heroes[ "weaver" ] thread maps\kowloon_anim::npc_pipe_slide(  "n_pipe_wait_weaver" );

	level.heroes[ "clarke" ] waittill("goal");
	
	wait( 2.5 );
	lines[0] = "Hurry_it_up";
	lines[1] = "Get_ass_down";
	level thread maps\kowloon_util::nag_dialog( level.heroes[ "clarke" ], lines, 10, "player_start_pipe_slide" );
}

//background_rappel_guys()
//{
//
//	trigger_wait( "trig_spawn_background_rappellers" );
//
//	background_rappel_right_guy = simple_spawn_single( "background_rappel_right_guy", maps\kowloon_anim::background_rappel );
//	wait( 0.50 );
//	background_rappel_left_guy = simple_spawn_single( "background_rappel_left_guy", maps\kowloon_anim::background_rappel );
//}

//
//	Supplemental thread for the rooftop battle
//	Tries to move AI around to support the battle locations3
ai_redirect( trigger_name, activate_trigger_name, ai_array, spawner_name, spawner_target_name )
{
	trigger_wait( trigger_name );

	if ( !IsDefined( ai_array ) )
	{
		ai_array = simple_spawn( spawner_name );

		// Make other stuff happen
		trigger_use( activate_trigger_name );
	}

	// Redirect guys to lower areas
	player = get_players()[0];
	for ( i=0; i<ai_array.size; i++ )
	{
		if ( IsAlive( ai_array[i] ) )
		{
			ai_array[i] GetPerfectInfo( player );	// Help them get to where they need to be
			ai_array[i] thread maps\_spawner::go_to_spawner_target( array(spawner_target_name) );
			wait( 0.1 );
		}
	}
}


//
//	Keeps the battle moving if the player hangs back
rooftop_battle_advance()
{
	level endon("kill_advancer");

	// shortcuts to advance the battle as people die
	waittill_ai_group_cleared( "e4_roof_start" );
	trigger_use( "trig_e4_roof_drop" );

	waittill_ai_group_cleared( "e4_roof_drop" );
	trigger_use( "trig_e4_roof_mid" );
}


//	Simplified stealth
stealth_alert()
{
	level endon( "event5" );

	angle = 80;	// FOV vision angles for AI.  Can see this many degrees left or right.
	player = get_players()[0];
	stealth_broke = false;
	ai = undefined;	// scope declaration
	while( !stealth_broke )
	{
		ai = GetAIArray( "axis" );
		if ( ai.size < 2 )
		{
			// someone died
			stealth_broke = true;
			break;
		}

		// LOS check
		//	The arccosine of a vector dot operation will give you the angle between two vectors.
		//	So we can check to see if it's within a visual cone.
		for ( i=0; i<ai.size; i++ )
		{
			vector_to_player = VectorNormalize( player.origin - ai[i].origin );
			my_vector = AnglesToForward(ai[i].angles);
			angle_to_player = acos( VectorDot( my_vector, vector_to_player ) );
			if ( abs(angle_to_player) < angle )
			{
				stealth_broke = true;
				break;
			}
		}

		// Player shot his gun
		if ( player AttackButtonPressed() )
		{
			stealth_broke = true;
			break;
		}
		wait( 0.05 );
	}

	// Stealth broken
	for (i=0; i<ai.size; i++ )
	{
		ai[i] notify( "stealth_break" );
	}
}


//
//	Simplified stealth behavior
stealth_guy()
{
	self endon( "death" );

	self.ignoreme = 1;
	self.ignoreall = 1;
	self enable_cqbwalk();
	self waittill_any( "damage", "bulletwhizby", "stealth_break" );

	level notify( "e4_stealth_cleared" );

	// Be aware
	self.ignoreme = 0;
	self.ignoreall = 0;

// 	player = get_players()[0];
// 	player.ignoreme = 0;
// 	level.heroes[ "clarke" ].ignoreme = 0;
// 	level.heroes[ "weaver" ].ignoreme = 0;
}

break_pipe_walker_stealth()
{
	level endon( "e4_stealth_cleared" );
	self endon( "death" );

	//trigger_wait( "break_pipe_walkers" );

	trig_e4_temple = GetEnt( "trig_e4_temple", "targetname" );
	trig_e4_temple waittill_notify_or_timeout( "trigger", 30 );

	self notify( "stealth_break" );
	level notify( "stealth_break" );

	self.ignoreme = 0;
	self.ignoreall = 0;
}	


//	We enter a narrow space 
//
pipe_slide()
{

	// Slide the player down the pipe
	trigger_wait( "trig_e4_pipe_slide" );
	
  //setting new fog
	start_dist = 193.571;
	half_dist = 800.269;
	half_height = 699.319;
	base_height = 1553.19;
	fog_r = 0.0901961;
	fog_g = 0.121569;
	fog_b = 0.133333;
	fog_scale = 3.99082;
	sun_col_r = 0.360784;
	sun_col_g = 0.388235;
	sun_col_b = 0.431373;
	sun_dir_x = 0.163263;
	sun_dir_y = -0.944148;
	sun_dir_z = 0.286235;
	sun_start_ang = 0;
	sun_stop_ang = 66.7167;
	time = 5;
	max_fog_opacity = 1;
	
	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale, sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, sun_stop_ang, time, max_fog_opacity);

	level notify("objective_pos_update" );	// Head to slide cache

	//SOUND: Shawn J - pipe slide audio
	playsoundatposition("evt_pipe_slide", (0,0,0));
	flag_set("player_start_pipe_slide");

	player = get_players()[0];
	player thread maps\kowloon_anim::player_pipe_slide();
	
	level thread pipe_slide_save();
	
	// Clean up enemies
	level notify("kill_advancer");	// don't trigger anything else
	ai = GetAIArray( "axis" );
	for ( i=0; i<ai.size; i++ )
	{
		if( IsAlive( ai[i] ) )
		{
			ai[i] Delete();
			wait_network_frame();
		}
	}

	// Spawn the guys running under the player
	trigger_wait( "trig_e4_pipe_walk" );

	ai = simple_spawn( "ai_e4_pipe_walk", ::stealth_guy );
	array_thread( ai, ::break_pipe_walker_stealth );
	level thread stealth_alert();
	ai thread spez_rooftop_conversation();

	level.heroes[ "weaver" ] ent_flag_wait("pipe_traversed");
	level.heroes[ "clarke" ] ent_flag_wait("pipe_traversed");
	waittill_ai_group_cleared( "e4_stealth" );

	flag_set("e4_pipe_down");
}


pipe_slide_save()
{
	animtime = GetAnimLength(level.scr_anim["player"]["pipe_slide"]);
	
	wait(animtime - 0.5);
	
	autosave_by_name( "kowloon_pipeslide" );
}


//	Traverse across!
//
temple_roof()
{
//	trigger_wait( "trig_e4_temple" );

	level thread maps\kowloon_anim::temple_roof_traversal_setup();
	level thread maps\kowloon_anim::move_fake_buidling_and_sign();
}


trigger_rooftop_dialog()
{

	level notify("kill_old_dialog");
	level thread rooftop_battle_dialog();

	trigger_wait("trig_e4_roof_end");

	level waittill( "head_to_the_pipe" );

	level notify("kill_old_dialog");
	level thread clark_down_the_pipe();

	trigger_wait("trig_e4_pipe_walk");

	level notify("kill_old_dialog");
	level thread catwalk_dialog();

	flag_wait("e4_pipe_down");
	wait( 2.0 );	// give a little pause for pacing
	level notify("kill_old_dialog");
	level thread temple_roof_top_dialog();

	trigger_wait("trig_e5_slide");


	level notify("kill_old_dialog");
	wait(1);
	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "Targets_at_12");

}

rooftop_battle_dialog()
{
	level endon("kill_old_dialog");

	level notify("objective_pos_update" );	// Head to rooftop stairway
	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "get_on_roof");
	
	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "where_you_going");

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "prepared_for_this");

	trigger_wait("trig_e4_lower_rooftop");

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "downstairs");


}

clark_down_the_pipe()
{
	level endon("kill_old_dialog");
	level endon("player_start_pipe_slide");
	
	if(flag("player_start_pipe_slide"))
		return;

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "down_the_pipe");
}

catwalk_dialog()
{
	level endon("kill_old_dialog");
	level endon( "e4_stealth_cleared" );	// AI Group is dead

	player = get_players()[0];
	player.animname = "player";
	wait(2);

	level.heroes[ "weaver" ] ent_flag_wait("pipe_traversed");

	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "two_more_Asshole");

	player anim_single(player, "no_problem");

	player anim_single(player, "got_em");
}

temple_roof_top_dialog()
{

	level endon("kill_old_dialog");

	player = get_players()[0];
	player.animname = "player";

	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "shut_you_up");

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "nova_6");
	
	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "where_base");

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "yamantau");

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "steiner");

	player anim_single(player, "whisper_rumor");

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "steiner_dragovich");

	player anim_single(player, "what_number");

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "kind_of_plan");
}

//	Spetsnaz dialog
spez_roof_dialog()
{
	self endon("death");
	self.animname = "spz";

	self anim_single(self, "Get_out_of_way");
	self anim_single(self, "tower_2");
}

//	2 Patrollers on temple roof
spez_rooftop_conversation()
{
	self[0] endon ("damage");
	self[1] endon ("damage");

	self[0].animname = "spz";

	self[0] anim_single(self[0], "no_sign_of_them");
	self[1] anim_single(self[0], "Clarke_is_slippery");
	self[0] anim_single(self[0], "his_body_guard");
	self[1] anim_single(self[0], "stay_alert");
}


// SOUND - AI civilian ambient chatter
//self = civilian ai
play_civilian_yells()
{
	self endon( "death" );
	self endon( "goal" );
	
	while(1)
	{
		wait(randomfloatrange( 1, 4 ) );
		rand = randomintrange( 0, 100 );
	
		if( rand > 50 )
		{
			self playsound( "amb_civilian_yell" );
		}
	}
}


//
//	Water spouts from the tank when shot
rigged_watertank_leak()
{

	water_tank = GetEnt("water_tank", "targetname");

	water_tank setcandamage(true);

	water_tank thread wait_for_damage_to_play_water();

	//trigger_bottom = getent("watertank_damage_trigger_bottom", "targetname");
	//trigger_middle = getEnt(trigger_bottom.target, "targetname");
	//trigger_top = GetEnt(trigger_middle.target, "targetname");

	//trigger_top thread wait_for_damage_to_play_water();
	//trigger_middle thread wait_for_damage_to_play_water();
	//trigger_bottom thread wait_for_damage_to_play_water();
}

wait_for_damage_to_play_water()
{
	

	while(1)
	{
		origin = (0, 0, 0);
		direct_vec = undefined;
		self waittill("damage", amount, attacker, direct_vec, origin);

		new_self_origin = (self.origin[0], self.origin[1], origin[2]);
		new_self_origin = origin - new_self_origin;

		angles = VectorToAngles(new_self_origin);

		direct_vec = direct_vec * -1;
	//	PrintLn(origin[0] + " " +origin[1] + " " + origin[2]);
		fx_origin = Spawn( "script_model", origin );

	//	angles = VectorToAngles( direct_vec );
		fx_origin.angles = angles;
		fx_origin SetModel( "tag_origin" );
		fx_origin thread play_water_fx_then_delete();

	//	wait(0.05);

	}

}
play_water_fx_then_delete()
{

	PlayFXOnTag(level._effect["water_tank_leak"], self, "tag_origin");
	wait(3);
	self delete();
}
