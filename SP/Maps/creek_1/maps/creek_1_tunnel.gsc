#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;
#include maps\creek_1_util;
#include maps\_music;

main()
{	
	// MISC SETUP //////////////////////////////////////////////////////////////////////////
	
	level maps\_swimming::set_default_vision_set( "creek_1" );
	level maps\_swimming::set_swimming_vision_set( "creek_1_water" );
	
	player = get_players()[0];
	player AllowMelee( true );

	add_spawn_function_veh( "tunnel_entrance_hueys_3_stay", ::hover_and_fire_at_entrance );
	add_spawn_function_veh( "tunnel_entrance_hueys_3_stay", ::load_up_fake_huey_ais_l );
	add_spawn_function_veh( "tunnel_entrance_huey_1a", ::load_up_fake_huey_ais_l );
	add_spawn_function_veh( "tunnel_entrance_huey_1b", ::load_up_fake_huey_ais_l );
	add_spawn_function_veh( "tunnel_entrance_huey_1c", ::load_up_fake_huey_ais_l );
	add_spawn_function_veh( "tunnel_entrance_huey_2a", ::load_up_fake_huey_ais_lr );
	add_spawn_function_veh( "tunnel_entrance_huey_2b", ::load_up_fake_huey_ais_lr );
	add_spawn_function_veh( "tunnel_entrance_huey_2c", ::load_up_fake_huey_ais_lr );
	add_spawn_function_veh( "tunnel_entrance_huey_3d", ::load_up_fake_huey_ais_lr );
	add_spawn_function_veh( "tunnel_entrance_huey_3e", ::load_up_fake_huey_ais_lr );
	
	wait( 0.2 );
		
	//add_spawn_function_veh( "tunnel_entrance_huey_3a", ::huey_fire_mg_no_target );
	//add_spawn_function_veh( "tunnel_entrance_huey_3b", ::huey_fire_mg_no_target );
	//add_spawn_function_veh( "tunnel_entrance_huey_3c", ::huey_fire_mg_no_target );
	
	add_spawn_function_veh( "tunnel_entrance_hueys_3_stay", ::huey_fire_mg_no_target );
	add_spawn_function_veh( "tunnel_entrance_huey_1a", ::huey_fire_mg_no_target );
	add_spawn_function_veh( "tunnel_entrance_huey_1b", ::huey_fire_mg_no_target );
	add_spawn_function_veh( "tunnel_entrance_huey_1c", ::huey_fire_mg_no_target );
	
	wait( 0.2 );
	
	flashlight = getent( "b4_flashlight_toss", "targetname" );
	flashlight hide();

	level.reznov.threatbias = -1000; // no need for AI to target Reznov
	
	level.ground_ref_ent = spawn( "script_model", (0,0,0) );
	player playerSetGroundReferenceEnt( level.ground_ref_ent );
	
	// For parts of the tunnel, player will move slower and cannot sprint or stand.
	// Since the player CAN stand and run in certain rooms in the tunnel, we need
	// to detect if/when the player is in a low-speed zone.
	player thread set_speed_limit_zones( "tunnel_low_speed_zone", "event_4_ends" );
	
	// Player will switch to flashlight-pistol. He will be warned if he changes 
	// or drops this weapon
	player thread use_flashlight_weapon_in_tunnels();
	
	// Reznov will always be crouching in this event
	//level.reznov thread no_standing_in_tunnels();
	
	// once player is in tunnel, change reznov's anims and weapons
	level thread reznov_tunnel_setup();
	
	// manage all objectives for this beat
	level thread objectives_tunnels();
	
	// set default start (occurs if the player did not come here directly with skipto)
	if( !isdefined( level.skipped_to_event_4 ) || level.skipped_to_event_4 == false )
	{		
		level.section4 = "start";
		// for now, teleport Reznov and Barnes to position
		//teleport_ai_single( "barnes_ai", "b4_barnes_gate_start" );
		//teleport_ai_single( "hudson", "b4_hudson_gate_start" );
	}
	
	if( isdefined( level.skipped_to_event_4 ) && level.skipped_to_event_4 == true )
	{
		level.swift = simple_spawn_single( "swift" );
		level.swift thread magic_bullet_shield();
		level.swift.animname = "swift";
		level.swift.name = "Swift";
	}
	
	level thread tunnel_light_on_and_off();
	
	level thread rats_moving();
	
	// spawn functions
	array_thread( GetEntArray( "vc_tunnel_room2_2", "targetname" ), ::add_spawn_function, ::flashlight_vc_behavior );
	array_thread( GetEntArray( "vc_tunnel_room2_2", "targetname" ), ::add_spawn_function, ::vc_room_2_think );
	array_thread( GetEntArray( "vc_tunnel_room2_new", "targetname" ), ::add_spawn_function, ::flashlight_vc_behavior );
	array_thread( GetEntArray( "vc_tunnel_room2_new", "targetname" ), ::add_spawn_function, ::vc_room_2_think );
	
	array_thread( GetEntArray( "vc_tunnel_room2_1", "targetname" ), ::add_spawn_function, ::vc_jump_out_attack_1 );
	array_thread( GetEntArray( "vc_tunnel_room2_7", "targetname" ), ::add_spawn_function, ::vc_jump_out_attack_2 );
	
	// MOMENTS //////////////////////////////////////////////////////////////////////////////
	
	if( level.section4 == "start" )
	{
		level thread tunnel_section_1_gate();				// Barnes kick open gate and rush to rat tunnel entrance
		level thread tunnel_section_1_entrance();		// Player drops down to the tunnel
		level thread tunnel_section_1_flashlight_hint();
		level thread swift_movements();
		level thread tunnel_section_1_split_path();	// Meets Reznov, who takes another path
		level thread tunnel_section_1_room();				// Clear 2 VC in room, regroup with Reznov, open path for exit
		level.section4 = "continue";
	}
	
	wait( 0.5 );

	if( level.section4 == "4b" || level.section4 == "continue" )
	{
		level thread tunnel_section_2_drown_guy();		// Reznov kills VC hiding and drowns him
		level thread tunnel_section_2_ambush_1();			// VC hiding in an alcove, attacks player with melee when close
		level thread tunnel_section_2_ambush_2();			// 2nd VC in ambush
		level thread tunnel_section_2_ambush_3();			// extra ambush guy
		level thread tunnel_section_2_ambush_clear();	// Reznov moves forward once all ambushes are cleared
		level thread tunnel_section_2_room();					// Clear room of 2 VCs
		level.section4 = "continue";
	}
	
	wait( 0.5 );
	
	if( level.section4 == "4c" || level.section4 == "continue" )
	{
		level thread tunnel_section_3_war_room();
		
		level thread tunnel_section_3_see_light();			// See flickering lights ahead, VC movements
		level thread tunnel_section_3_falling_stuff();
		level thread tunnel_section_3_falling_stuff_2();
		//level thread tunnel_section_3_end_transition();	// Exit the tunnel. Event ends
		
		level thread tunnel_extra_vos();
	}
	
	// TEMP: For demo, we will end the event early
	level thread temp_tunnel_collapse();
	
	//level thread temp_end_testing();
	level thread ending_choppers();
	/*
	level waittill( "event_4_ends" );
	
	// make sure the player can stand afterwards
	player AllowStand( true );
	player AllowSprint( true );	
	player AllowMelee( true );
	level thread maps\creek_1_tank_battle::main();
	*/
	
	wait( 1 );
	add_spawn_function_veh( "end_huey_1", ::load_up_fake_huey_ais_lr );
	add_spawn_function_veh( "end_huey_2", ::load_up_fake_huey_ais_lr );
	add_spawn_function_veh( "end_huey_3", ::load_up_fake_huey_ais_lr );
	add_spawn_function_veh( "end_huey_3_extra_a", ::load_up_fake_huey_ais_lr );
	add_spawn_function_veh( "end_huey_3_extra_b", ::load_up_fake_huey_ais_lr );
	
	wait( 1 );
	add_spawn_function_veh( "firing_hueys_air_1a", ::load_up_fake_huey_ais_r );
	add_spawn_function_veh( "firing_hueys_air_1b", ::load_up_fake_huey_ais_r );
	add_spawn_function_veh( "firing_hueys_air_1c", ::load_up_fake_huey_ais_r );
	add_spawn_function_veh( "firing_hueys_air_1a", ::huey_fire_mg );
	add_spawn_function_veh( "firing_hueys_air_1b", ::huey_fire_mg );
	add_spawn_function_veh( "firing_hueys_air_1c", ::huey_fire_mg );
	
	wait( 1 );
	add_spawn_function_veh( "end_huey_floating_a", ::load_up_fake_huey_ais_lr );
	add_spawn_function_veh( "end_huey_floating_b", ::load_up_fake_huey_ais_lr );
	add_spawn_function_veh( "end_huey_floating_c", ::load_up_fake_huey_ais_lr );
	add_spawn_function_veh( "end_huey_floating_d", ::load_up_fake_huey_ais_lr );
	add_spawn_function_veh( "end_huey_floating_e", ::load_up_fake_huey_ais_lr );
	
	wait( 1 );
	add_spawn_function_veh( "end_huey_floating_a", ::huey_fire_mg );
	add_spawn_function_veh( "end_huey_floating_b", ::huey_fire_mg );
	add_spawn_function_veh( "end_huey_floating_c", ::huey_fire_mg );
	add_spawn_function_veh( "end_huey_floating_d", ::huey_fire_mg );
	add_spawn_function_veh( "end_huey_floating_e", ::huey_fire_mg );
}

tunnel_extra_vos()
{
	player = get_players()[0];
	
	trigger_wait( "b4_passed_crawling_guy" );
	level.reznov thread say_dialogue( "careful_i_hear" );
	
	trigger_wait( "tunnel_vc2_attack_end" );
	player thread say_dialogue( "son_of_a_b" );
	
	// wait for player to get close
	target_struct = getstruct( "b4_objective_pos_13", "targetname" );
	while( distance( player.origin, target_struct.origin ) > 150 )
	{
		wait( 0.1 );
	}
	level.reznov thread say_dialogue( "this_is_it" );
}


vc_jump_out_attack_1( guy )
{
	self endon( "death" );
	
	self.health = 1;
	self.allowdeath = 1;
	
	anim_node = getstruct( "anim_tunnel_attack_1", "targetname" );
	
	anim_node anim_first_frame( self, "jump_out_attack_1" );
	
	// wait for player to get closer
	trigger_wait( "tunnel_vc1_attack" );
	
	// jump out and attack
	anim_node anim_single_aligned( self, "jump_out_attack_1" );
	
	// once the attack is over, if the player has not come close yet, 
	// wait for him to be inside the attack trigger again and do the other anim
	if( !flag( "tunnel_vc1_attack_end" ) )
	{
		anim_node anim_first_frame( self, "jump_out_attack_2" );
		self thread assault_player_if_close( "tunnel_vc1_attack_end" );
	}
	
	wait( 2 );
	
	trigger_wait( "tunnel_vc1_attack" );
	if( !flag( "tunnel_vc1_attack_end" ) )
	{
		anim_node anim_single_aligned( self, "jump_out_attack_2" );
	}
	
	wait( 2 );
	
	self stopanimscripted();
	player = get_players()[0];
	self.goalradius = 64;
	self.disableMelee = true;
	//self setgoalpos( player.origin );
	self setgoalentity( player );
}

vc_jump_out_attack_2( guy )
{
	self endon( "death" );
	
	self.health = 1;
	self.allowdeath = 1;
	
	anim_node = getstruct( "anim_tunnel_attack_2", "targetname" );
	
	anim_node anim_first_frame( self, "jump_out_attack_1" );
	
	// wait for player to get closer
	trigger_wait( "tunnel_vc2_attack" );
	
	// jump out and attack
	anim_node anim_single_aligned( self, "jump_out_attack_1" );
	
	// once the attack is over, if the player has not come close yet, 
	// wait for him to be inside the attack trigger again and do the other anim
	if( !flag( "tunnel_vc2_attack_end" ) )
	{
		anim_node anim_first_frame( self, "jump_out_attack_2" );
		self thread assault_player_if_close( "tunnel_vc2_attack_end" );
	}
	
	wait( 2 );
	
	trigger_wait( "tunnel_vc2_attack" );
	if( !flag( "tunnel_vc2_attack_end" ) )
	{
		anim_node anim_single_aligned( self, "jump_out_attack_2" );
	}
	
	wait( 2 );
	
	self stopanimscripted();
	player = get_players()[0];
	self.disableMelee = true;
	self setgoalentity( player );
}

assault_player_if_close( flag_name )
{
	self endon( "death" );
	flag_wait( flag_name );
	self stopanimscripted();
	player = get_players()[0];
	self.disableMelee = true;
	self setgoalentity( player );
}

extra_huey_explosions()
{
	wait( 8.5 );
	single_explosion_at_struct( "tunnel_entrance_explosions_1" );
	wait( 1 );
	single_explosion_at_struct( "tunnel_entrance_explosions_2" );
	wait( 0.7 );
	single_explosion_at_struct( "tunnel_entrance_explosions_3" );
	
	wait( 12 );
	single_explosion_at_struct( "tunnel_entrance_explosions_4" );
	wait( 1 );
	single_explosion_at_struct( "tunnel_entrance_explosions_5" );
	wait( 1 );
	single_explosion_at_struct( "tunnel_entrance_explosions_6" );
}

single_explosion_at_struct( struct_name )
{
	struct_pos = getstruct( struct_name, "targetname" );
	playsoundatposition( "exp_mortar_dirt", struct_pos.origin );
	playfx( level._effect["fx_explosion_satchel_hut"], struct_pos.origin );
	playfx( level._effect["fx_explosion_satchel_hut_core"], struct_pos.origin );
}

hover_and_fire_at_entrance()
{
	wait( 10 );
	self SetSpeed( 0 );
	
	wait( 3 );
	self ResumeSpeed( 10 );
}

load_up_fake_huey_ais()
{
	load_up_huey( self, true, true, true );
}

load_up_fake_huey_ais_l()
{
	load_up_huey( self, true, true, false );
}

load_up_fake_huey_ais_r()
{
	load_up_huey( self, true, false, true );
}

load_up_fake_huey_ais_lr()
{
	load_up_huey( self, true, true, true );
}

rats_moving()
{
	trigger_wait( "b4_rats_trigger" );
	level notify( "creek_rats_start" );
}

#using_animtree ("player");

temp_tunnel_collapse()
{
	trigger_wait( "end_crawl_trigger" );
	
	level thread maps\createart\creek_1_art::art_settings_for_tunnel_crawl();
	
	// reset reznov anims
	level.reznov animscripts\anims::setIdleAnimOverride();
	level.reznov animscripts\anims_table::setup_default_wounded_anim_array();
	
	// push player down to ground first
	player = get_players()[0];
	earthquake( 0.7, 2.5, player.origin, 500 );
	player PlaySound( "evt_tuco_collapse_to_prone" );
	//player SetStance( "prone" );
	//player AllowCrouch( false );
	//player AllowStand( false );
	player DisableWeapons();
	
	wait( 0.5 );
	play_massive_rumble();
	player PlayRumbleLoopOnEntity( "tank_rumble" );
	
	// get ready for the animation
	anim_node = getstruct( "b4_anim_tunnel_out", "targetname" );
	hands = spawn_anim_model( "player_body" );
	hands.animname = "player_body";
	player.anim_hands = hands;

	hands thread wait_for_scale_notify();
	hands thread tuco_crawling_anim_audio();  //AUDIO: C. Ayers - Sounds that plays off the "Crawl_In" notetrack
	
	level thread swap_rocks_at_timer( 12 );

	// play the anim and lerp the player
	hands AnimScriptedSkipRestart( "crawl_anim", anim_node.origin, anim_node.angles, %int_creek_tunnel_crawl_and_get_up, "normal", undefined, 1.0 );
	wait( 0.05 );
	player PlayerLinkToDelta( hands, "tag_player", 1, 0.01, 0.01, 0.01, 0.01, true );
	player StartCameraTween( 0.5 );
	
	player thread player_not_move_fail();
/*
	model3_new = spawn( "script_model", player.anim_hands.origin );
	model3_new.angles = player.anim_hands.angles;
	model3_new SetModel( "weapon_satchel_charge_obj" );
	model3_new linkto( player.anim_hands, "tag_player" );
	*/
	// keep up the earthquakes
	level thread loop_earthquakes();
	
	// adjust speed of movement
	level thread tunnel_speed_adjustment( anim_node, hands );
	
	player thread animate_camera_wobble_idle();
	
	// wait for the anim to end
	while( 1 )
	{
		hands waittill( "crawl_anim", notetrack );
		if( notetrack == "end" )
		{
			level notify( "crawl_tunnel_end" );
			break;
		}
	}
	
	level.reznov.name = "";
	level.barnes.name = "";
	level.hudson.name = "";
	
	player StopRumble( "tank_rumble" );
	
	new_rock = getent( "cave_breakout_rock", "targetname" );
	new_rock.animname = "tunnel_rock";

	// anims for the rocks breaking apart
	level thread rock_break_anim_1( new_rock, anim_node );
	level thread rock_break_anim_2( new_rock, anim_node );
	level thread rock_break_anim_3( new_rock, anim_node );

	// play the breaking rock anims
	level.reznov thread say_dialogue( "claw_out_here" );
	//level.barnes say_dialogue( "holding_pattern" );
	//wait( 1 );
	level thread kill_player_timer_flag( 4, "rock_1_broken" );
	screen_message_create( &"CREEK_1_PRESS_DIG" );
	while( player meleeButtonPressed() == false )
	{
		wait( 0.05 );
	}
	flag_set( "rock_1_broken" );	
	screen_message_delete();
	anim_node anim_Single_aligned( hands, "tunnel_melee_a" );
	
	level thread kill_player_timer_flag( 4, "rock_2_broken" );
	screen_message_create( &"CREEK_1_PRESS_DIG" );
	while( player meleeButtonPressed() == false )
	{
		wait( 0.05 );
	}
	flag_set( "rock_2_broken" );	
	screen_message_delete();
	anim_node anim_Single_aligned( hands, "tunnel_melee_b" );
	level.reznov thread say_dialogue( "dig_mason" );
	
	level thread kill_player_timer_flag( 4, "rock_3_broken" );
	screen_message_create( &"CREEK_1_PRESS_DIG" );
	while( player meleeButtonPressed() == false )
	{
		wait( 0.05 );
	}
	flag_set( "rock_3_broken" );	

	screen_message_delete();
	
	level thread player_player_last_anim( anim_node, hands );
	
	level thread ending_rumble();
	
	level thread extra_vo_shit();
	
	wait( 22 );
	//level notify( "tunnel_burstout" ); //AUDIO: C. Ayers - Adding notify to stop earthquake loopsound
	
	/*
	wait( 2 );
	maps\creek_1_fade_screen::custom_fade_screen_out( "black", 0 );
	wait( 0.5 );
	nextmission();
	*/
	
	// now we idle the player on the cliff edge
	
	/*
	anim_node thread anim_loop_aligned( hands, "cliffhang_idle" ); 
	player unlink();
	player PlayerLinkToDelta( hands, "tag_player", 1, 90, 90, 50, 90, true );
	
	trigger_use( "ending_extras_2" );
	maps\creek_1_fade_screen::custom_fade_screen_out( "black", 2 );
	wait( 2 );
	*/
	
	level thread maps\creek_1_fade_screen::custom_fade_screen_out( "black", 0.5 );
	wait( 0.5 );
	level.barnes thread say_dialogue( "get_out_here" );
	wait( 2.5 );
	StopAllRumbles();
	nextmission();
}

player_player_last_anim( anim_node, hands )
{
	anim_node anim_Single_aligned( hands, "tunnel_melee_c" );
	linker = spawn( "script_origin", hands.origin );
	linker.angles = hands.angles;
	hands linkto( linker );
}

extra_vo_shit()
{
	wait( 2.5 );
	player = get_players()[0];
	player say_dialogue( "shit_cliff" );
}

ending_rumble()
{
	player = get_players()[0];
	wait( 17.2 );
	player PlayRumbleOnEntity( "tank_fire" );
	wait( 1.4 );
	play_massive_rumble();
	player PlayRumbleLoopOnEntity( "tank_rumble" );
}

swap_rocks_at_timer( timer )
{
	wait( timer );	
	flag_set( "cave_rock_swap" );
}

player_not_move_fail()
{
	level endon( "cave_rock_swap" );
	pos_3_sec = self.origin;
	wait( 1 );
	pos_2_sec = self.origin;
	wait( 1 );
	pos_1_sec = self.origin;

	while( !flag( "cave_fill_complete" ) )
	{
		wait( 1 );
		pos_now = self.origin;
		distance_moved = distance2d( pos_now, pos_3_sec );
		if( distance_moved < 35 )
		{
			self tunnel_player_fail();
		}
		
		pos_3_sec = pos_2_sec;
		pos_2_sec = pos_1_sec;
		pos_1_sec = pos_now;
	}
}

tunnel_player_fail()
{
	Earthquake( 0.5, 2.0, self.origin, 100, self );
	//playfx( level._effect["big_explosion"], self.origin );
	//RadiusDamage( self.origin, 1000, self.health + 100, self.health + 100 );

	missionfailedwrapper( "@CREEK_1_FAIL_TUNNEL" );
	
	player = get_players()[0];
	fx_origin = player.origin + ( 0, 0, 70 );
	
	playfx( level._effect["fx_dirt_tunnel_collapse"], fx_origin );
	playfx( level._effect["fx_dirt_tunnel_collapse_blast"], fx_origin );
	wait( 0.5 );
	playfx( level._effect["fx_dirt_tunnel_collapse"], fx_origin + ( 0, 0, -10 ) );
	playfx( level._effect["fx_dirt_tunnel_collapse_blast"], fx_origin + ( 0, 0, -10 ) );
	wait( 0.5 );
	playfx( level._effect["fx_dirt_tunnel_collapse"], fx_origin + ( 0, 0, -20 ) );
	playfx( level._effect["fx_dirt_tunnel_collapse_blast"], fx_origin + ( 0, 0, -20 ) );
	wait( 0.5 );
	playfx( level._effect["fx_dirt_tunnel_collapse"], fx_origin + ( 0, 0, -30 ) );
	playfx( level._effect["fx_dirt_tunnel_collapse_blast"], fx_origin + ( 0, 0, -30 ) );
	RadiusDamage( self.origin, 1000, self.health + 100, self.health + 100 );
}

rock_break_anim_1( new_rock, anim_node )
{
	level waittill( "player_hit_breakout_1" );
	player = get_players()[0];
	player PlayRumbleOnEntity( "tank_fire" );
	maps\creek_1_anim::play_creek_object_anim_single( new_rock, anim_node, "breakout1" );
}
rock_break_anim_2( new_rock, anim_node )
{
	level waittill( "player_hit_breakout_2" );
	player = get_players()[0];
	player PlayRumbleOnEntity( "tank_fire" );
	maps\creek_1_anim::play_creek_object_anim_single( new_rock, anim_node, "breakout2" );
}

rock_break_anim_3( new_rock, anim_node )
{
	level waittill( "player_hit_breakout_3" );
	
	player = get_players()[0];
	play_massive_rumble();
	
	maps\creek_1_anim::play_creek_object_anim_single( new_rock, anim_node, "breakout3" );
	wait( 1 );
}

loop_earthquakes()
{
	level endon( "crawl_tunnel_end" );
	player = get_players()[0];
	while( 1 )
	{
		earthquake( 0.7, randomfloatrange( 1.0, 2.0 ), player.origin, 500 );
		player PlaySound( "evt_tuco_earthquake_oneshot" );
		wait( 3.5 );
	}
}

animate_camera_wobble_idle()
{
	// at this point we no longer wobble
	level endon( "cave_fill_complete" );	
	
	wait( 0.05 );
	
	while( 1 )
	{
		if( self.anim_hands.current_playback_speed < 0.3 )
		{
			self notify( "player_stop_moving" );
			self thread begin_camera_wobble();
			
			while( self.anim_hands.current_playback_speed < 0.5 )
			{
				wait( 0.05 );
			}
			
			self notify( "player_moves_again" );
			self thread stop_camera_wobble();
		}
		wait( 0.05 );
	}
}

begin_camera_wobble()
{
	self endon( "player_moves_again" );

	wobble_speed = 0.3;
	
	ud_look_angle = -5 + randomfloat( 10 ); // range -5 to 5
	lr_look_angle = -10;
	chance = randomint( 100 );
	if( chance < 50 )
	{
		lr_look_angle *= -1;
	}
		
	level.ground_ref_ent rotateto( ( ud_look_angle, lr_look_angle, 0 ), wobble_speed, 0.1, 0.2 );
	wait( wobble_speed );
	
	while( 1 )
	{
		lr_look_angle = lr_look_angle * -1;  // reverse l r
		ud_look_angle = -10 + randomfloat( 20 ); // randomize u d
		level.ground_ref_ent rotateto( ( ud_look_angle, lr_look_angle, 0 ), wobble_speed * 2, 0.2, 0.3 );
		wait( wobble_speed * 2 );
	}
}

stop_camera_wobble()
{
	level.ground_ref_ent rotateto( ( 0, 0, 0 ), 0.3, 0.1, 0.1 );
}

tunnel_speed_adjustment( anim_node, hands )
{
	level endon( "crawl_tunnel_end" );
	player = get_players()[0];
	hands.current_playback_speed = 1.0;
	while( 1 )
	{
		playback_speed = 0;
		stick_movement = player GetNormalizedMovement();
		// if the player is pushing up, we may change the speed
		if( stick_movement[0] > 0 )
		{
			// we want to make sure that he is not pushing to the sides too much
			if( stick_movement[1] < 0.5 && stick_movement[1] > -0.5 )
			{
				playback_speed = stick_movement[0];
			}
		}
		
		if( hands.allow_crawl_control == true )
		{
			hands.current_playback_speed = playback_speed;
			hands AnimScriptedSkipRestart( "crawl_anim", anim_node.origin, anim_node.angles, %int_creek_tunnel_crawl_and_get_up, "normal", undefined, playback_speed );
		}
		else
		{
			if( hands.current_playback_speed != 1.0 )
			{
				hands AnimScriptedSkipRestart( "crawl_anim", anim_node.origin, anim_node.angles, %int_creek_tunnel_crawl_and_get_up, "normal", undefined, 1.0 );
				hands.current_playback_speed = 1.0;
			}
		}
		wait( 0.05 );
	}
}

wait_for_scale_notify()
{
	self.allow_crawl_control = true;
	while( 1 )
	{
		self waittill( "crawl_anim", notetrack );
		if( notetrack == "crawl_in" )
		{
			self.allow_crawl_control = false;
		}
		if( notetrack == "crawl_out" )
		{
			self.allow_crawl_control = true;
		}
	}
}

#using_animtree ("generic_human");

/*
play_music_stingers()
{
	
	// TUEY - this plays a music stinger (not through the music system) whene player is close to an enemy AND has LOS 
	self endon ("death");
	if(!isdefined (level.wait_music))
	{
		level.wait_music = 0;
		
	}	
	player = getplayers();
	for(;;)
	{
		distance_to_player = distance (self.origin, player[0].origin);
		while (distance_to_player > 350)
		{			
			distance_to_player = distance (self.origin, player[0].origin);
	//		iprintlnbold( distance_to_player );
			wait(1.0);	
		}
		flashlight = self SightConeTrace( self gettagorigin("tag_eye"), self, self.angles, 40 );
		//iprintlnbold( flashlight );
		
		if (flashlight && level.wait_music == 0 )
		{		
			level.wait_music = 1 ;	
			self thread maps\_audio::create_2D_sound_list ("mus_tunnel_stg");	
			level waittill ("2D_sound_finished");
			level.wait_music = 0;					
		}
		wait(1.0);
	}
	
}
*/

play_music_stinger()
{
    wait(1);
    playsoundatposition( "mus_tunnel_stg_0", (0,0,0) );
}

skipto_flashlight_setup()
{
	wait( 2 );
	player = get_players()[0];
	player GiveMaxAmmo( "creek_flashlight_pistol_sp" );
	player SwitchToWeapon( "creek_flashlight_pistol_sp" );
	level notify( "tunnel_visionset_change" );
	//SetSavedDvar( "r_enableFlashlight","1" );      
}

//---------------------------------------------------------------------------------------------------------
// SECTION 1

tunnel_section_1_gate()
{
	if( !isdefined( level.skipped_to_event_4 ) || level.skipped_to_event_4 == false )
	{	
		
	}
	else
	{
		// make sure the AIs don't run away
		level.barnes SetGoalPos( level.barnes.origin );
		level.hudson SetGoalPos( level.hudson.origin );
		//level.reznov SetGoalPos( level.reznov.origin );
		
		// when player comes closer, barnes kicks open door
		trigger_wait( "b4_barnes_kick_door" );
	}
	flag_set( "b4_player_near_tunnel" );			

	level thread play_tunnel_enter_choppers();
	// level thread vo_b4_vc_across_wall();
	
	//Tuey switch music state to Village fight...
	setmusicstate ("IN_THE_JUNGLE_AMBIENT");
	
	level.barnes.goalradius = 16;
	level.reznov.goalradius = 16;
	level.hudson.goalradius = 16;
	level.swift.goalradius = 16;
	
	level thread maps\creek_1_anim::b4_tunnel_entrance_anim();
}

play_tunnel_enter_choppers()
{
	level waittill("cover_start");
	trigger_use( "tunnel_entrance_hueys_3" );
	level thread extra_huey_explosions();
}

tunnel_section_1_entrance()
{
	// wait for player to enter, then send in Reznov
	trigger_wait( "player_enter_tunnel", "script_noteworthy" );
	
	level.reznov gun_switchto( "m1911_sp", "right" );
		
	player = get_players()[0];
	while( player IsOnGround() == false )
	{
		wait( 0.05 );
	}
	
	level notify( "player_entered_tunnel" );
	//player AllowMelee( false );

	//TUEY Change music to tunnel_underscore
	setmusicstate("TUNNEL_UNDERSCORE");
	clientNotify( "tun" );
	
	level thread maps\creek_1_anim::b4_tunnel_player_drop_anim();
	
	level thread vo_tunnel_section_1();
}

tunnel_light_on_and_off()
{
	level waittill( "player_entered_tunnel" );
	
	player = get_players()[0];
	player clientNotify( "flahslight_start" );
	player.flashlight_on = false;
	player.flashlight_on_off_enabled = false;
	level.light_overwrite = false;
	
	// player clientNotify( "flahslight_on" );
	// player clientNotify( "flahslight_off" );
	
	// wait for player to 
	player thread detect_flashlight_weapon_switch();
	player thread detect_flashlight_on_off_button();
	player thread flashlight_melee_detection();
	playsoundatposition( "evt_num_num_02_r" , (0,0,0) );
}

detect_flashlight_weapon_switch()
{
	level endon( "no_more_flashlight" );
	level.default_light = "off"; // light is on or off when weapon is initially equipped
	
	while( 1 )
	{
		// wait till we have the flashlight weapon equipped
		while( 1 )
		{
			currentweapon = self GetCurrentWeapon();
			if( isdefined( currentweapon ) && currentweapon == "creek_flashlight_pistol_sp" )
			{
				break;
			}
			wait( 0.05 );
		}
		
		// wait a moment (for weapon to pull up, then turn on light
		wait( 0.5 );
		self.flashlight_on_off_enabled = true;
		SetSavedDvar( "r_enableFlashlight","1" );  

		if( level.default_light == "off" )
		{
			self flashlight_off();
		}
		else
		{
			self flashlight_on();
		}
		
		// now wait till player switch to something else
		while( 1 )
		{
			currentweapon = self GetCurrentWeapon();
			if( isdefined( currentweapon ) && currentweapon != "creek_flashlight_pistol_sp" )
			{
				break;
			}
			wait( 0.05 );
		}
		
		self.flashlight_on_off_enabled = false;
		self flashlight_off();
	}
}

detect_flashlight_on_off_button()
{
	level endon( "no_more_flashlight" );
	while( 1 )
	{
		if( self sprintButtonPressed() && self.flashlight_on_off_enabled && self IsMeleeing() == false )
		{
			if( self.flashlight_on )
			{
				self flashlight_off();
				//SOUND - Shawn J - sound for flashlight switch
			  self PlaySound("fly_flashlight_switch");
			}
			else
			{
				self flashlight_on();
				//SOUND - Shawn J - sound for flashlight switch
			  self PlaySound("fly_flashlight_switch");
			}
			
			// wait for player to let go the button
			while( self sprintButtonPressed() )
			{
				wait( 0.05 );
			}
			
			// wait some extra time
			wait( 0.1 );
		}
		wait( 0.05 );
	}
}

flashlight_on()
{
	level notify( "flahslight_on" );
	self clientNotify( "flahslight_on" );
	self.flashlight_on = true;
	maps\createart\creek_1_art::set_standard_flashlight_values();
}

flashlight_off()
{
	level notify( "flahslight_off" );
	self clientNotify( "flahslight_off" );
	self.flashlight_on = false;
	maps\createart\creek_1_art::set_dim_flashlight_values(); 
}

flashlight_melee_detection()
{
	while( 1 )
	{
		// wait for melee start
		while( self IsMeleeing() == false )
		{
			wait( 0.05 );
		}
		// wait for melee complete
		while( self IsMeleeing() == true )
		{
			wait( 0.05 );
		}
		
		self clientNotify( "melee_end" );
	}
}

vo_tunnel_section_1()
{
	trigger_wait( "b4_vo_tunnel_1" );
	//player = get_players()[0];
	//PlaySoundAtPosition( level.scr_sound["carter"]["easy_easy"], player.origin );
	autosave_by_name( "creek_1_vots1" );
}

tunnel_section_1_flashlight_hint()
{
	level waittill( "player_entered_tunnel" );
	wait( 1 );
	
	player = get_players()[0];
	while( !isdefined( player.flashlight_on_off_enabled ) || player.flashlight_on_off_enabled == false )
	{
		wait( 0.05 );	
	}
	
	if( player.flashlight_on == true )
	{
		// skip the message
	}
	else
	{
		screen_message_create( &"CREEK_1_TURN_FLASHLIGHT" );
		while( player.flashlight_on == false )
		{
			wait( 0.05 );
		}
		wait( 0.3 );
		screen_message_delete();
	}
}

tunnel_section_1_split_path()
{
	trigger_wait( "vc_tunnel_trap_tripped" );

	// prepare Reznov at this point
	level thread maps\creek_1_anim::b4_reznov_blinded();

	
	// reznov shows up
	//trigger_wait( "vc_tunnel_split_path_1" );
	level waittill( "play_reznov_blinded_anim" );
	
	level thread reznov_stinger_force_wait();
	
	level thread vo_reznov_appearing();
	level.reznov AllowedStances( "stand" );
/*
	teleport_ai_single( "reznov_ai", "b4_tunnel_reznov_appears" );
	level thread vo_reznov_appearing();
	wait( 2 );
*/
	level waittill( "reznov_blinded_anim_done" );
	level.reznov go_to_node_by_name( "vc_tunnel_split_path_1_left_node" );
	level.reznov thread reznov_temporary_disappear();
	
	trigger_wait( "vc_tunnel_ambush_1_attack" );
	wait( 1 );
	player = get_players()[0];
	player say_dialogue( "shit" );
}

reznov_stinger_force_wait()
{
//    wait(1.5);
	level notify ("inside_cave");
    playsoundatposition ("mus_tunnel_reznov", (0,0,0));
}

vo_reznov_appearing()
{
	/*
	iprintlnbold( "Carter: Christ Reznov! You nearly took a bullet." );
	wait( 3 );
	iprintlnbold( "Reznov: No one fights alone Carter. I will work my way around." );
	wait( 3 );
	iprintlnbold( "Carter: Just stay out of my way. And move quietly!" );
	*/
	autosave_by_name( "creek_1_vora" );
}

reznov_temporary_disappear()
{
	self waittill( "goal" );
	//teleport_ai_single( "reznov", "reznov_b4_tunnel_start" );
	waittill_ai_group_cleared( "b4_room1_guys" );
	//teleport_ai_single( "reznov", "vc_tunnel_split_path_1_left_node" );
}

tunnel_section_1_room()
{
	use_trigger = getent( "b4_player_use_hatch", "targetname" );
	//use_trigger trigger_off();
	
	anim_node = getstruct( "anim_b4_room_1", "targetname" );
	level thread maps\creek_1_anim::play_tunnel_shelf_fall( anim_node );
	
	// spawn enemies
	trigger_wait( "vc_tunnel_split_path_1_right2" );
	
	simple_spawn_single( "vc_tunnel_room1_1", ::vc_room_1_think_1 );
	simple_spawn_single( "vc_tunnel_room1_2", ::vc_room_1_think_2_strafe );
	simple_spawn_single( "vc_tunnel_room1_3" );
	simple_spawn_single( "vc_tunnel_room1_4", ::vc_room_1_think_2 );
	
	top_guy = getent( "vc_tunnel_room1_3_ai", "targetname" );
	top_guy.ignoreall = true;
	
	level thread play_music_stinger();
	
	enemies = getaiarray ("axis");	
	for (i=0; i<enemies.size; i++)
	{
		//enemies[i] thread play_music_stingers();
		enemies[i] thread flashlight_vc_behavior();
	}
	
	
	
	level thread maps\creek_1_anim::b4_tunnel_room_1_barrier();
		
	// wait till all the enemies are killed
	waittill_ai_group_cleared( "b4_room1_guys" );
	//waittill_ai_group_cleared( "b4_room1_guys_special" );
	//trigger_wait( "b4_room_1_look_at_hatch" );
	wait( 1 );
	level notify( "hatch_opens_above" );
	level notify( "cave_panel_start" );
	
	autosave_by_name( "creek_1_cps" );
	
	level waittill( "reznov_at_shelf" );
	//iprintlnbold( "Reznov: Do not mention it. Here, help me." );
	//use_trigger trigger_on();
	
	level thread detect_player_use_shelf_trigger( use_trigger );
	level waittill( "shelf_pushed" );
	//level notify( "push_over_shelf" );
	//use_trigger delete();
	
	level notify( "door_opened" );
	//hatch = getent( "tunnel_blocker", "targetname" );
	//hatch NotSolid();
	//hatch ConnectPaths();
	//hatch Delete();
	
	flag_set( "b4_room_1_cleared" );
	
	autosave_by_name( "creek_1_b4_r1c" );
}

detect_player_use_shelf_trigger( use_trigger )
{
	level endon( "shelf_pushed" );
	level thread shelf_push_trigger_press( use_trigger );
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
		player SetScriptHintString( &"CREEK_1_HINT_PUSH_SHELF" );
		//screen_message_create( &"CREEK_1_HINT_PUSH_SHELF" );
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

shelf_push_trigger_press( trigger )
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
			playsoundatposition ( "evt_dresser_fall", (0,0,0) );
			level notify( "shelf_pushed" );
			flag_set( "barricade_pushed" );
			trigger delete();
			player SetScriptHintString( "" );
			//screen_message_delete();
			return;
		}
		wait( 0.05 );
	}
}

vc_room_1_think_1()
{
	self AllowedStances( "crouch", "prone" );
	original_node_name = self.target;
	
	self endon( "death" );
	self.pacifist = 1;
	self.health = 1;
	
	self waittill( "goal" );
	self.pacifist = false;
	self.goalradius = 512;
	
	alternate_node_name = self.script_string;
	level waittill( "flahslight_off" );
	self go_to_node_by_name( alternate_node_name );
	
	level waittill( "flahslight_on" );
	self go_to_node_by_name( original_node_name );
}

vc_room_1_think_2()
{
	self AllowedStances( "crouch", "prone" );
	original_node_name = self.target;
	
	self endon( "death" );
	self.pacifist = 1;
	self.health = 1;
	self.goalradius = 16;
	self waittill( "goal" );
	self.pacifist = false;
	self.goalradius = 512;
	
	alternate_node_name = self.script_string;
	level waittill( "flahslight_off" );
	self go_to_node_by_name( alternate_node_name );
	
	level waittill( "flahslight_on" );
	self go_to_node_by_name( original_node_name );
}

vc_room_1_think_2_strafe()
{
	self AllowedStances( "crouch", "prone" );
	original_node_name = self.target;
		
	self endon( "death" );
	self.allowdeath = true;
	self.health = 1;
	self.goalradius = 512;
	
	anim_node = getstruct( "anim_b4_room_1", "targetname" );
	anim_node anim_single_aligned( self, "strafe_attack" );
	
	alternate_node_name = self.script_string;
	level waittill( "flahslight_off" );
	self go_to_node_by_name( alternate_node_name );
	
	level waittill( "flahslight_on" );
	self go_to_node_by_name( original_node_name );
}

vc_room_2_think()
{
	self AllowedStances( "crouch", "prone" );
	
	original_node_name = self.target;
	self endon( "death" );
	self waittill( "goal" );
	self.goalradius = 2000;

	if( isdefined( self.script_string ) )
	{
		alternate_node_name = self.script_string;
		level waittill( "flahslight_off" );
		self go_to_node_by_name( alternate_node_name );
		
		level waittill( "flahslight_on" );
		self go_to_node_by_name( original_node_name );
	}
}


vc_room_1_think_special()
{
	self endon( "death" );

	self.health = 1;
	//self AllowedStances( "prone" );
	
	// when everyone else in the room dies, this guy will be killed by Reznov
	// however, we want to make sure the player is inside the room first, or he won't see
	// this vc at all
	waittill_ai_group_cleared( "b4_room1_guys" );
	//trigger_wait( "b4_room_1_look_at_hatch" );
	//iprintlnbold( "Player sees hiding vc" );
	wait( 5 );
	//iprintlnbold( "VC death sound" );
	wait( 1 );
	self ai_suicide();
}

//---------------------------------------------------------------------------------------------------------
// SECTION 2


tunnel_section_2_drown_guy()
{
	//flag_wait( "b4_room_1_cleared" );
	trigger_wait( "vc_tunnel_exit_room_1" );
	
	level.reznov go_to_node_by_name( "b4_reznov_wait_for_kill1" );
	trigger_wait( "b4_passed_crawling_guy" );
	
	// spawn a guy in prone
	//vc = simple_spawn_single( "vc_tunnel_prone_guy" );

	level thread maps\creek_1_anim::b4_reznov_drowns_vc();	
	level thread play_stinger_drown();
	
	level waittill( "reznov_drown_vc_anim_done" );
	level thread which_way_vo();

	//TUEY changing the music state here
	setmusicstate("TUNNEL_UPHILL");
	
	autosave_by_name( "creek_1_rdvcad" );
	
	level.reznov SetGoalPos( level.reznov.origin );
	//level.reznov go_to_node_by_name( "b4_reznov_ambush_spots_1" );
	wait( 3 );
	//level.reznov thread say_dialogue( "careful_carter" );
	
	//trigger_wait( "b4_player_enter_room2" );
	//player = get_players()[0];
	//player say_dialogue( "don't_breath" );
}

which_way_vo()
{
	trigger_wait( "b4_ambush_cleared" );
	player = get_players()[0];
	player say_dialogue( "which_way" );
	level.reznov say_dialogue( "follow_instincts" );
}

play_stinger_drown()
{
	wait(4.25);
	playsoundatposition ("mus_reznov_fight", (0,0,0));	
}

// these guys hold position and attack player when close
tunnel_section_2_ambush_1()
{
	trigger_wait( "vc_tunnel_exit_room_1" );
	vc = simple_spawn_single( "vc_tunnel_ambush_guy1", ::vc_ambush_think );
	//vc thread flashlight_vc_behavior();
	
	vc.machete = getent( "vc_machete_1", "targetname" );
	vc.machete.origin = vc GetTagOrigin( "tag_weapon_left" );
	vc.machete.angles = vc GetTagAngles( "tag_weapon_left" );	
	vc.machete Linkto( vc, "tag_weapon_left" );
	
	vc waittill( "death" );
	if( isdefined( vc.machete ) )
	{
		vc.machete delete();
	}
	level.reznov notify( "stop_loop" );
	level.reznov go_to_node_by_name( "b4_reznov_ambush_complete_1" );
	autosave_by_name( "creek_1_b4rac1" );
	wait( 1 );
	//level.reznov thread say_dialogue( "good_work_friend" );
}

tunnel_section_2_ambush_2()
{
	trigger_wait( "vc_tunnel_exit_room_1" );
	vc = simple_spawn_single( "vc_tunnel_ambush_guy2", ::vc_ambush_think );
	//vc thread flashlight_vc_behavior();

	vc.machete = getent( "vc_machete_2", "targetname" );
	vc.machete.origin = vc GetTagOrigin( "tag_weapon_left" );
	vc.machete.angles = vc GetTagAngles( "tag_weapon_left" );	
	vc.machete Linkto( vc, "tag_weapon_left" );
	
	vc waittill( "death" );
	if( isdefined( vc.machete ) )
	{
		vc.machete delete();
	}
	level.reznov notify( "stop_loop" );
	level.reznov go_to_node_by_name( "b4_reznov_ambush_complete_2" );
	autosave_by_name( "creek_1_b4rac2" );
	wait( 2 );
	
	//level.reznov thread say_dialogue( "we_are_good_team" );
}

tunnel_section_2_ambush_3()
{
	trigger_wait( "b4_tunnel_spawn_extra_ai" );
	vc = simple_spawn_single( "vc_tunnel_ambush_guy3" );
	vc thread flashlight_vc_behavior();
	vc.health = 1;
	vc.goalradius = 16;
	vc go_to_node_by_name( "b4_ambush_3_node" );
}
		
vc_ambush_think()
{
	self endon( "death" );
	self endon( "ambush_aborted" );
	self.pacifist = true;
	self.health = 1;
	
	self thread maps\creek_1_anim::b4_vc_ambush_idle();
	
	if( self.animname == "vc_tunnel_ambush_guy1" )
	{
		trigger_wait( "vc_tunnel_ambush_1_attack" );
	}
	else
	{
		self thread vc_ambush_break();
		trigger_wait( "vc_tunnel_ambush_2_attack" );
	}

	self.pacifist = false;
	//iprintlnbold( "VC Attacks!" );
	
	level thread play_uphill_stingers();
	
	self notify( "ambush_starts" );
	
	self thread maps\creek_1_anim::b4_vc_ambush_slash();
}

play_uphill_stingers()
{
	if(!IsDefined (level.uphill_stinger))
	{
		level.uphill_stinger = 0;		
	}	
	playsoundatposition( "mus_tunnel_uphill_stg_" + level.uphill_stinger, (0,0,0));
	level.uphill_stinger++;
	
	
	
}
vc_ambush_break()
{
	self endon( "ambush_starts" );
	trigger_wait( "vc_tunnel_ambush_2_break" );
	self.pacifist = false;
	self notify( "ambush_aborted" );
	self notify( "stop_loop" );
	if( isdefined( self.machete ) )
	{
		self.machete delete();
	}
}

tunnel_section_2_ambush_clear()
{
	// 2 ways to initiate Reznov to move up, either both ambushers are dead, or player moved to a trigger
	//level thread clear_after_ambushers_killed();
	level thread clear_after_trigger_hit();
	level waittill( "reznov_move_up" );
	level.reznov go_to_node_by_name( "b4_reznov_stop_passage" );
	level.reznov waittill( "goal" );
	
	trigger_wait( "b4_player_enter_room2" );
	level.reznov go_to_node_by_name( "b4_reznov_stop_room2" );
}

clear_after_ambushers_killed()
{
	level endon( "reznov_move_up" );
	waittill_ai_group_cleared( "b4_ambushers" );
	//iprintlnbold( "Tunnel cleared" );
	level notify( "reznov_move_up" );
}

clear_after_trigger_hit()
{
	level endon( "reznov_move_up" );
	trigger_wait( "b4_ambush_cleared" );
	level notify( "reznov_move_up" );
}
play_fake_vox()
{
	self endon ("death");
	while(1)
	{
		rand = randomintrange(1,6);
		{
			if( rand < 2)
			{
				self playsound ("vox_play_uphill");				
			}
			
		}	
		wait(3);		
		
	}	
}
tunnel_section_2_room()
{
	level thread what_kind_animal_vo();
	trigger_wait( "b4_ambush_cleared" );
		
	// spawn ais
	//simple_spawn_single( "vc_tunnel_room2_1", ::vc_room_2_think );
	//simple_spawn_single( "vc_tunnel_room2_2", ::vc_room_2_think );

	enemies = getaiarray("axis");
	for (i=0; i<enemies.size; i++)
	{
		enemies[i] thread play_fake_vox();			
		enemies[i] thread flashlight_vc_behavior();
	}
	
	//Guarantee at least one VO to play on the hill here...
	playsoundatposition ("vox_play_uphill", (-18967.5, 36528.5, -124.5));


	// wait till all the enemies are killed
	waittill_ai_group_cleared( "b4_room2_guys" );
	autosave_by_name( "creek_1_b4rg" );
	level.reznov go_to_node_by_name( "b4_reznov_room2_exit" );
}

what_kind_animal_vo()
{
	trigger_wait( "b4_tunnel_spawn_extra_ai" );
	level.reznov say_dialogue( "getting_close" );
}

//---------------------------------------------------------------------------------------------------------
// SECTION 3

tunnel_section_3_see_light()
{
	// player sees movement of light ahead
	trigger_wait( "b4_objective_trigger_3" );
	//level thread maps\creek_1_anim::b4_peek_vc();
	//level thread maps\creek_1_anim::b4_peek_vc();
	
	// player drops down and don't see any enemies
	trigger_wait( "b4_reznov_last_tunnel_p2" );
	level.reznov go_to_node_by_name( "b4_reznov_last_tunnel_enter" );
	
	//trigger_wait( "b4_objective_trigger_5" );
	//wait( 2 );
	//player = get_players()[0];
	//PlaySoundAtPosition( level.scr_sound["carter"]["light_ahead"], player.origin );
	//wait( 3 );
	//level.reznov thread say_dialogue( "always" );
	
	//autosave_by_name( "creek_1_always" );
}

tunnel_section_3_falling_stuff()
{	
	trigger_wait( "b4_end_bamboo_fall_1" );
	player = get_players()[0];
	level notify("bamboo_01_start");
	Exploder( 5001 );
	earthquake( 0.5, 1.0, player.origin, 500 );
	play_massive_rumble();
	
	trigger_wait( "b4_end_bamboo_fall_2" );
	level notify("bamboo_02_start");
	Exploder( 5002 );
	earthquake( 0.3, 1.5, player.origin, 500 );
	play_massive_rumble();
	
	trigger_wait( "b4_end_bamboo_fall_3" );
	level notify("bamboo_03_start");
	Exploder( 5003 );
	earthquake( 0.5, 1.5, player.origin, 500 );
	play_massive_rumble();
}

tunnel_section_3_falling_stuff_2()
{
	player = get_players()[0];
	
	trigger_wait( "tunnel_collapse_trig_1" );
	level notify("cave_bolder_start");
	Exploder( 5010 );
	player PlaySound( "evt_tuco_rockfall_1" );
	play_massive_rumble();
	
	trigger_wait( "tunnel_collapse_trig_2" );
	level notify("cave_sprinkle_start");
	Exploder( 5011 );
	player PlaySound( "evt_tuco_rockfall_2" );
	play_massive_rumble();
	
	trigger_wait( "tunnel_collapse_trig_3" );
	level notify("cave_bolder_ceiling_start");
	Exploder( 5012 );
	player PlaySound( "evt_tuco_rockfall_3" );
	play_massive_rumble();
	
	trigger_wait( "tunnel_collapse_trig_4" );
	level notify("cave_fill_start");
	Exploder( 5013 );
	player PlaySound( "evt_tuco_rockfall_final" );
	play_massive_rumble();
	
	wait(2);
	player PlaySound( "evt_tuco_rockfall_4" );
	play_massive_rumble();
}

tunnel_section_3_end_transition()
{
	trigger_wait( "player_leaves_tunnel" );

	//iprintlnbold( "End Event 4" );
	level notify( "event_4_ends" );
}

play_massive_rumble()
{
	player = get_players()[0];
	player PlayRumbleOnEntity( "grenade_rumble" );
	player PlayRumbleOnEntity( "tank_rumble" );
	player PlayRumbleOnEntity( "tank_fire" );
	player PlayRumbleOnEntity( "artillery_rumble" );
}

//---------------------------------------------------------------------------------------------------------
// MISC

use_flashlight_weapon_in_tunnels()
{
	level waittill( "remove_flashlight" );

	self DisableWeapons();
	
	level notify( "no_more_flashlight" );
	
	self flashlight_off();

	self.flashlight_on_off_enabled = false;

	
	/*
	current_weapon = self GetCurrentWeapon();
	if( current_weapon == "creek_flashlight_pistol_sp" )
	{
		// restore original weapons       
		self giveback_player_weapons();
	}
	*/
	wait 0.1; //needed else settings don't take -jc
	level thread maps\createart\creek_1_art::tunnel_war_room_light_settings();
	
	// turn off flashlight (the actual light)
	SetSavedDvar( "r_enableFlashlight","0" );   
	
	// turn off flashlight FX
	//self clientNotify( "flahslight_off" );
	
	if( isdefined( self.flashlight_on ) )
	{
		self.flashlight_on = false;
	}
}

no_standing_in_tunnels()
{
	trigger_wait( "vc_tunnel_split_path_1" );
	self AllowedStances( "prone", "crouch" );
	trigger_wait( "player_leaves_tunnel" );
	self AllowedStances( "prone", "crouch", "stand");
}

objectives_tunnels()
{
	trigger = getent( "war_room_entrance_open", "targetname" );
	if( !isdefined( level.skipped_to_event_4 ) )
	{
		trigger maps\_door_breach::door_breach_trigger_off();
	}
	
	level.current_obj_num = 4;
	
	level waittill( "tunnel_open" );
	Objective_Add( 3, "current", &"CREEK_1_FIND_KRAVCHENKO" );
	
	// wait till the tunnel is open, then tell the player to get in
	level waittill( "swift_anim_done" );
	
	blocker = getent( "b4_tunnel_cover_blocker", "targetname" );
	blocker delete();
	
	obj_pos_struct = getstruct( "b4_objective_pos_2", "targetname" );
	Objective_Add( 4, "current", &"CREEK_1_OBJ_B4_TUNNEL_IN", obj_pos_struct.origin );
	Objective_Set3D( 4, true, "yellow" );
	Objective_AdditionalCurrent( 3 );
	level waittill( "player_entered_tunnel" );
	Objective_State( 4, "done" );
	Objective_Delete( 4 );
	
	// make the player follow through the tunnel
	update_obj_position_with_trigger( 3, "b4_objective_trigger_0", "b4_objective_pos_3" );
	Objective_Set3D( 3, true, "yellow" );
	update_obj_position_with_trigger( 3, "b4_vo_tunnel_1", "b4_objective_pos_4" );
	update_obj_position_with_trigger( 3, "vc_tunnel_trap_tripped", "b4_objective_pos_5" );
	update_obj_position_with_trigger( 3, "vc_tunnel_split_path_1", "b4_objective_pos_6" );
	update_obj_position_with_trigger( 3, "vc_tunnel_split_path_1_right", "b4_objective_pos_7" );
	update_obj_position_with_trigger( 3, "vc_tunnel_split_path_1_right2", "b4_objective_pos_8" );
	
	// tells player to open the barrier
	level waittill( "reznov_at_shelf" );
	obj_pos_struct = getstruct( "b4_objective_pos_9", "targetname" );
	Objective_Set3D( 3, false );
	Objective_Add( 4, "current",  &"CREEK_1_OBJ_B4_OPEN_DOOR", obj_pos_struct.origin );
	Objective_Set3D( 4, true, "yellow" );
	Objective_AdditionalCurrent( 3 );
	
	flag_wait( "barricade_pushed" );
	//level waittill( "door_opened" );
	Objective_State( 4, "done" );
	Objective_Delete( 4 );
	Objective_Set3D( 3, true, "yellow" );
	
	// restore original objective, then follow it through the tunnel
	Objective_State( 3, "current" );
	obj_pos_struct = getstruct( "b4_objective_pos_10", "targetname" );
	Objective_Position( 3, obj_pos_struct.origin );
	
	update_obj_position_with_trigger( 3, "b4_objective_trigger_1", "b4_objective_pos_11" );
	update_obj_position_with_trigger( 3, "b4_objective_trigger_2", "b4_objective_pos_12" );
	
	trigger_wait( "b4_player_enter_room2" );
	Objective_Position( 3, ( -19607, 36695.5, -160.4 ) );
	
	// wait for all enemies to die
	center_origin = ( -19607, 36695.5, -160.4 );
	while( 1 )
	{
		ais_alive = false;
		ais = getaiarray( "axis" );
		for( i = 0; i < ais.size; i++ )
		{
			if( isalive( ais[i] ) && distance( ais[i].origin, center_origin ) < 700 )
			{
				ais_alive = true;
			}
		}
		
		if( ais_alive == false )
		{
			break;
		}
		wait( 0.1 );
	}
	
	struct_obj = getstruct( "b4_objective_pos_13", "targetname" );
	Objective_Position( 3, struct_obj.origin );

	////////////////////////
	// war room objective
	trigger = getent( "war_room_entrance_open", "targetname" );
	if( !isdefined( level.skipped_to_event_4 ) )
	{
		trigger maps\_door_breach::door_breach_trigger_on();
	}
	trigger waittill( "door_opening" );	
	Objective_Set3D( 3, false );
	
	//level waittill( "war_room_inspection_begins" );
	Objective_Add( 4, "current",  &"CREEK_1_OBJ_B4_INSPECT_ROOM" );
	Objective_Set3D( 4, false );
	
	flag_wait( "recording_playback_finished" );
	obj_pos_struct = getstruct( "war_room_exit_obj", "targetname" );
	Objective_Position( 4, obj_pos_struct.origin );
	Objective_Set3D( 4, true, "yellow" );
	
	trigger = getent( "war_room_entrance_out", "targetname" );
	trigger waittill( "door_opening" );	
	wait( 1 );
	Objective_Set3D( 4, false );
	Objective_State( 4, "done" );
	Objective_Delete( 4 );
	Objective_State( 3, "done" );

	Objective_Add( 4, "current",  &"CREEK_1_Escape" );
	Objective_Set3D( 4, true, "yellow" );
	obj_pos_struct = getstruct( "b4_objective_pos_14", "targetname" );
	Objective_Position( 4, obj_pos_struct.origin );
	update_obj_position_with_trigger( 4, "b4_objective_trigger_4", "b4_objective_pos_15" );
	update_obj_position_with_trigger( 4, "b4_objective_trigger_5", "b4_objective_pos_16" );

	trigger_wait( "tunnel_collapse_trig_4" );
	Objective_Set3D( 4, false );
	
	flag_wait( "rock_3_broken" );	
	
	//TUEY SETMUSIC STATE
	setmusicstate ("CLIFF_HANGER");
	
	wait( 1 );
	Objective_State( 4, "done" );
	Objective_Delete( 4 );

	//nextmission();
}


#using_animtree ("generic_human");
reznov_tunnel_setup()
{
	level waittill( "player_entered_tunnel" );
	
	// we swp reznov
	level.reznov delete();
	
	level.reznov = simple_spawn_single( "reznov_pistol" );
	level.reznov.name = "Reznov";
	level.reznov hold_fire();
	level.reznov make_hero();
	level.reznov.animname = "reznov"; // just in case it's changed before
	
	level.reznov wont_disable_player_firing();
	
	// this prevents standard turn_run anim from kicking in during turns
	level.reznov.disableTurns = true;
	level.reznov.disableArrivals = true;
	level.reznov.disableExits = true;

	// change the run anim.
	// NOTE: The pathnodes should be standard. Don't make them "crouch only"
	level.reznov set_run_anim( "tunnel_crouch_walk", true ); 
	
	// change the idle anims
	level.reznov animscripts\anims::setIdleAnimOverride( %ai_reznov_crouchwalk_idle );
	level.reznov.anim_array[level.reznov.animType]["stop"]["stand"]["rifle"]["idle_trans"] = %ai_reznov_crouchwalk_idle_in;
	level.reznov.anim_array[level.reznov.animType]["move"]["stand"]["rifle"]["exit_exposed"][2] = %ai_reznov_crouchwalk_idle_out;
	level.reznov.anim_array[level.reznov.animType]["move"]["stand"]["rifle"]["exit_exposed"][4] = %ai_reznov_crouchwalk_idle_out;
	level.reznov.anim_array[level.reznov.animType]["move"]["stand"]["rifle"]["exit_exposed"][6] = %ai_reznov_crouchwalk_idle_out;
	level.reznov.anim_array[level.reznov.animType]["move"]["stand"]["rifle"]["exit_exposed"][8] = %ai_reznov_crouchwalk_idle_out;

	// switch his weapon
	//self gun_remove();
	//wait( 1 );
	//self gun_switchto( "m1911_silencer_sp", "right" );
}

swift_tunnel_setup()
{
	self.ignoreall = 1;
	self.goalradius = 16;
	self.disableTurns = true;
	self.disableArrivals = true;
	self.disableExits = true;
	self.bulletsInClip = WeaponClipSize( self.weapon ); // don't reload once in the tunnel
	self set_run_anim( "tunnel_crouch_walk", true ); 
	self animscripts\anims::setIdleAnimOverride( %ai_reznov_crouchwalk_idle );
	self.anim_array[self.animType]["stop"]["stand"]["rifle"]["idle_trans"] = %ai_reznov_crouchwalk_idle_in;
	self.anim_array[self.animType]["move"]["stand"]["rifle"]["exit_exposed"][2] = %ai_reznov_crouchwalk_idle_out;
	self.anim_array[self.animType]["move"]["stand"]["rifle"]["exit_exposed"][4] = %ai_reznov_crouchwalk_idle_out;
	self.anim_array[self.animType]["move"]["stand"]["rifle"]["exit_exposed"][6] = %ai_reznov_crouchwalk_idle_out;
	self.anim_array[self.animType]["move"]["stand"]["rifle"]["exit_exposed"][8] = %ai_reznov_crouchwalk_idle_out;
	self gun_remove();
	
	self Attach( "t5_weapon_1911_world", "tag_weapon_right" );
	//wait( 2 );
	//self gun_switchto( "m1911_sp", "right" );
}

swift_movements()
{
	level waittill( "swift_anim_done" );
	
	node_1 = getnode( "swift_node_1", "targetname" );
	level.swift SetGoalNode( node_1 );
	level.swift thread swift_tunnel_setup();
	
	trigger_wait( "swift_node_1_move" );
	node_2 = getnode( "swift_node_2", "targetname" );
	level.swift SetGoalNode( node_2 );
	
	level.swift thread say_dialogue( "fighting_no_more" );
	
	trigger_wait( "swift_node_2_move" );
	node_3 = getnode( "swift_node_before_death", "targetname" );
	level.swift SetGoalNode( node_3 );
	
	player = get_players()[0];
	if( player.flashlight_on == true )
	{
		level.swift thread say_dialogue( "keep_steady" );
	}
	
	trigger_wait( "vc_tunnel_split_path_1" );
		
	level thread make_reznov_come_down_early();
	
	anim_node = getstruct( "anim_struct_swift_kill", "targetname" );
	anim_node anim_reach_aligned( level.swift, "swift_death" );
	level.swift.ignoreme = 1;
	//node_3 = getnode( "swift_node_3", "targetname" );
	//level.swift SetGoalNode( node_3 );
	
	//level waittill( "reznov_blinded_anim_done" );
	
	//trigger_wait( "swift_node_3_move" );
	//iprintlnbold( "swift_kill" );
	animate_swift_death();
}

make_reznov_come_down_early()
{
	level notify( "play_reznov_blinded_anim" );
	player = get_players()[0];
	player thread say_dialogue( "hold" );
}

#using_animtree ("generic_human");
animate_swift_death()
{
	anim_node = getstruct( "anim_struct_swift_kill", "targetname" );
	
	// spawn the vc
	vc = simple_spawn_single( "vc_tunnel_trap" );
	vc.health = 9999;
	vc.allowdeath = false;
	vc AllowedStances( "crouch" );
	
	// attach a knife to the VC
	vc gun_remove();
	vc Attach( "t5_knife_animate", "tag_weapon_right" );
	
	// make the VC idle a bit before swift is ready
	//anim_node thread anim_first_frame( vc, "swift_death" );
	
	// now let swift get into position
	//anim_node anim_reach_aligned( level.swift, "swift_death" );
	level.swift stop_magic_bullet_shield();
	
	level thread tunnel_vo_broken( vc );
	
	vc endon( "death" );
	vc thread force_play_VC_death_audio();
	
	// time to play the anim
	level thread animate_swift_getting_killed( anim_node );
	
	anim_node anim_single_aligned( vc, "swift_death" );

	level.swift.ignoreMe = true;
	
	
	// the VC becomes ready to fire at player
	vc.goalradius = 1024;
	//vc SetGoalPos( vc.origin );
	vc Detach( "t5_knife_animate", "tag_weapon_right" );
	vc gun_switchto( "ak47_sp", "right" );
	vc.health = 1;
	vc.deathanim = %exposed_crouch_death_twist;
	vc resume_fire();
	
	node = getnode( "swift_kill_vc_node", "targetname" );
	vc SetGoalNode( node );
}

tunnel_vo_broken( vc )
{
	level thread end_vo_at_tunnel_end( "vc_tunnel_split_path_1_right3" );
	level endon( "vc_tunnel_split_path_1_right3" );
	vc waittill( "death" );
	
	player = get_players()[0];
	player say_dialogue( "xray_come_in" );
	level.barnes say_dialogue( "go_ahead_mason" );
	player say_dialogue( "swift_dead_vc" );
	level.barnes say_dialogue( "lama_9_sweep" );
	player say_dialogue( "xray_copy" );
	player say_dialogue( "xray_shit" );
}

end_vo_at_tunnel_end( trigger_name )
{
	trigger_wait( trigger_name );
	level notify( trigger_name );
}

animate_swift_getting_killed( anim_node )
{
	anim_node thread anim_single_aligned( level.swift, "swift_death" );

	// wait till almost end of anim and then just hold it there
	wait( GetAnimLength( level.scr_anim["swift"]["swift_death"] ) - 0.2 );
	level.swift SetAnimRateComplete(0);

	// stop reticle from turning green
	level.swift notsolid();
}

#using_animtree ("generic_human");

tunnel_section_3_war_room()
{
	level.player_is_talking = false;
	level.reznov_is_talking = false;
	
	// lock the player in after entering
	level thread war_room_lock_player_in();
	
	// wait for player to open the room door
	trigger = getent( "war_room_entrance_open", "targetname" );
	trigger waittill( "door_opening" );
	playsoundatposition ( "evt_krav_door_kick" , (-19498, 36736.5, -141.4));
	
	blocker = getent( "warroom_entrance_block", "targetname" );
	blocker delete();
	
	level notify( "remove_flashlight" );
	trigger waittill( "kick_door_opened" );
	
	//TUEY Set music state to TUNNEL DOOR OPEN
	setmusicstate("TUNNEL_DOOR_OPEN");
	
	//autosave_by_name( "creek_1_tdo" );
	
	level notify( "war_room_inspection_begins" );
	
	// the exit is temporarily disabled
	exit_trigger = getent( "war_room_entrance_out", "targetname" );
	exit_trigger maps\_door_breach::door_breach_trigger_off();
	
	// move Reznov in
	teleport_node = getnode( "war_room_reznov_teleport", "targetname" );
	level.reznov forceteleport( teleport_node.origin, teleport_node.angles );
	level.reznov.goalradius = 16;
	//desk_node = getnode( "war_room_reznov_search", "targetname" );
	//level.reznov SetGoalNode( desk_node );
	
	level thread reznov_intro_in_lair();
	level thread reznov_intro_anim_in_lair();
	anim_node = getstruct( "anim_krav_lair", "targetname" );
	level thread escape_drop_flag();
	
	level thread kravchenko_recording();
	
	flag_wait( "recording_playback_finished" );

	autosave_by_name( "creek_1_rpf" );
	
	// wait for player to kick door
	exit_trigger maps\_door_breach::door_breach_trigger_on();
	exit_trigger waittill( "door_opening" );
	playsoundatposition ( "evt_krav_other_door_kick" , (0,0,0));
	flag_set( "warroom_exit_door_kick" );
	
	level thread last_run_kill_player();
	
	wait( 0.4 );
	level notify( "warroom_door_kick_start" );
	playfx( level._effect["fx_dirt_tunnel_collapse_blast"], ( -18684, 36810, -87 ) );
	
	blocker = getent( "war_room_exit", "targetname" );
	blocker delete();
	
	wait( 1.5 );
	
	//flag_set( "reznov_search_anim_should_finish" );
	//flag_wait( "reznov_search_anim_finish" );
	flag_set( "lair_explosion_starts" );
	
	level thread war_room_explosions();
	level thread war_room_explosions_vo();
	
	//wait( 2 );
	//playfx( level._effect["fx_dirt_tunnel_collapse"], ( -18684, 36810, -87 ) );
	//playfx( level._effect["fx_dirt_tunnel_collapse_blast"], ( -18684, 36810, -87 ) );
	
	trigger_wait( "war_exited" );
	flag_set( "player_escapes_war_room" );
	level.reznov go_to_node_by_name( "b4_reznov_room2_drop_wait" );
	
	//autosave_by_name( "creek_1_pewr" );
}

last_run_kill_player()
{
	level thread kill_player_timer_flag( 7, "escape_section_1" );
	trigger_wait( "b4_objective_trigger_3" );
	flag_set( "escape_section_1" );
	
	level thread kill_player_timer_flag( 7, "escape_section_2" );
	trigger_wait( "b4_objective_trigger_4" );
	flag_set( "escape_section_2" );
	
	level thread kill_player_timer_flag( 7, "escape_section_3" );
	trigger_wait( "b4_objective_trigger_5" );
	flag_set( "escape_section_3" );
	
	level thread kill_player_timer_flag( 7, "escape_section_4" );
	trigger_wait( "end_crawl_trigger" );
	flag_set( "escape_section_4" );
}

kill_player_timer_flag( timer, success_flag )
{
	level endon( success_flag );
	wait( timer );
	if( !flag( success_flag ) )
	{
		player = get_players()[0];
		player tunnel_player_fail();
	}
}

reznov_intro_anim_in_lair()
{
	level.reznov DisableClientLinkTo();
	
	anim_node = getstruct( "anim_krav_lair", "targetname" );
	level.reznov anim_set_blend_in_time( 0.3 );
	anim_node anim_reach_aligned( level.reznov, "enter_war_room" );
	anim_node anim_single_aligned( level.reznov, "enter_war_room" );

	level thread loop_reznov_search_anim( anim_node );
	level waittill( "reznov_ready_to_leave" );
	
	//iprintlnbold( "start loop" );
	//anim_node anim_single_aligned( level.reznov, "loop_war_room" );
	//iprintlnbold( "end loop" );
	
	anim_node anim_single_aligned( level.reznov, "exit_war_room" );
	//level.reznov SetGoalPos( level.reznov.origin );
	
	level.reznov go_to_node_by_name( "b4_reznov_room2_drop_wait" );
	level.reznov EnableClientLinkTo();
}

loop_reznov_search_anim( anim_node )
{
	while( !flag( "warroom_exit_door_kick" ) )
	{
		anim_node anim_single_aligned( level.reznov, "loop_war_room" );
	}
	playsoundatposition ( "evt_krav_other_door_kick" , (0,0,0));
	level notify( "reznov_ready_to_leave" );
}

reznov_intro_in_lair()
{
	player = get_players()[0];
	
	wait( 2 );
	player say_dialogue( "looks_abandoned" );
	level.reznov say_dialogue( "anticipate_arrival" );
	player say_dialogue( "left_in_a_hurry" );
	wait( 1 );
	level.reznov say_dialogue( "look_around" );
	wait( 2 );
	level.reznov say_dialogue( "krav" );
	
	wait( 0.3 );
	player = get_players()[0];
	player say_dialogue( "grab_docs" );
	
	flag_set( "recording_playback_finished" );
}

war_room_explosions_vo()
{
	wait( 0.5 );
	player = get_players()[0];
	player say_dialogue( "shit" );
	level.reznov say_dialogue( "go_go_tunnel" );
	
	level thread exit_run_vo();
}

exit_run_vo()
{
	level thread detect_if_player_sticks_around();
	
	level endon( "cave_fill_complete" );
	flag_wait( "player_escapes_war_room" );
	player = get_players()[0];
	player say_dialogue( "wired_to_blow" );
	wait( 0.2 );
	player say_dialogue( "xray_copy_escape" );
	wait( 0.2 );
	player say_dialogue( "sammit" );
	wait( 0.1 );
	level.reznov say_dialogue( "my_grave" );
	
	if( level.player_crawling_stage == 1 )
	{
		player say_dialogue( "xray_copy_repeat" );
	}
	
	while( level.player_crawling_stage != 3 )
	{
		wait( 0.05 );
	}

	wait( 2 );
	level.barnes say_dialogue( "fire_from_tunnel" );
	level.barnes say_dialogue( "where_are_you" );
	wait( 1 );
	level.barnes say_dialogue( "holding_pattern" );
}

detect_if_player_sticks_around()
{
	level.player_crawling_stage = 1;
	trigger_wait( "b4_end_bamboo_fall_3" );
	level.player_crawling_stage = 2;
	trigger_wait( "end_crawl_trigger" );
	level.player_crawling_stage = 3;
}

war_room_explosions()
{
	level notify( "explosions_start" );
	
	//AUDIO: C. Ayers: Adding 1 second space for sound purposes.  Delete if necessary
	struct = getstruct( "tuco_bomb_0", "targetname" );
	if( IsDefined( struct ) )
	{
	    playsoundatposition( "evt_click", struct.origin );
    }
    
	wait(1);
	
	level thread audio_tuco_begins();
	
	level thread bomb_activate( 0 );
	exploder( 4500 );
	
	player = get_players()[0];
	Earthquake( 1.0, 1.5, player.origin, 500 );
	
	wait( 0.4 );
	level notify( "warroom_start" );
	
	//TUEY Set music state to TUNNEL DOOR OPEN
	setmusicstate("CAVE_IN");
	
	wait( 3 );
	level thread bomb_activate( 1 );
	exploder( 4501 );
	wait( 1.5 );
	level thread bomb_activate( 2 );
	exploder( 4502 );
	wait( 2 );
	wait( 3.5 );
	level thread bomb_activate( 3 );
	exploder( 4503 );
	wait( 3 );
	level thread bomb_activate( 4 );
	exploder( 4504 );
	wait( 2.3 );
  level thread bomb_activate( 5 );
	exploder( 4505 );
	wait( 2.0 );
	level thread bomb_activate( 6 );
	exploder( 4506 );
	
	level thread kill_player_if_not_escaped();
	level thread continue_explosions_till_player_leaves();
}

continue_explosions_till_player_leaves()
{
	while( !flag( "escape_drop" ) )
	{
		level thread bomb_activate( 3 );
		exploder( 4503 );
		wait( 1.8 );
		level thread bomb_activate( 4 );
		exploder( 4504 );
		wait( 1.2 );
		level thread bomb_activate( 1 );
		exploder( 4501 );
		wait( 0.9 );
	  level thread bomb_activate( 5 );
		exploder( 4505 );
		wait( 1.4 );
		level thread bomb_activate( 2 );
		exploder( 4502 );
		wait( 0.7 );
		level thread bomb_activate( 6 );
		exploder( 4506 );
	}
}

escape_drop_flag()
{
	trigger_wait( "b4_objective_trigger_4" );
	flag_set( "escape_drop" );
}

kill_player_if_not_escaped()
{
	trigger = getent( "stay_in_warroom", "targetname" );
	if( !isdefined( trigger ) )
	{
		return;	
	}
	
	player = get_players()[0];
	
	trigger_wait( "stay_in_warroom" );
	// player fails
	level thread bomb_activate( 5 );
	exploder( 4505 );
	level thread bomb_activate( 6 );
	exploder( 4506 );
			
	setdvar( "ui_deadquote", "@CREEK_1_FAIL_TUNNEL" );
	RadiusDamage( player.origin, 1000, player.health + 100, player.health + 100 );
}

explosion_at_struct( struct_name, earthquake_degree, earthquake_time )
{
	struct_exp = getstruct( struct_name, "targetname" );
	playfx( level._effect["vehicle_explosion"], struct_exp.origin );
	player = get_players()[0];
	playsoundatposition( "exp_mortar_dirt", struct_exp.origin );
	Earthquake( earthquake_degree, earthquake_time, player.origin, 500 );
}

war_room_lock_player_in()
{
	blocker = getent( "war_room_entrance_gate", "targetname" );
	blocker moveto( blocker.origin + (0,0,1000), 0.5, 0.1, 0.1 );
	
	trigger_wait( "war_room_player_enter" );
	blocker moveto( blocker.origin + (0,0,-1000), 0.5, 0.1, 0.1 );
}

kravchenko_recording()
{
	level endon( "player_escapes_war_room" );
	level waittill( "turn_on_radio" );
	wait( 0.5 );
	//level endon( "player_searched_entire_room" );
	
	level.vo_origin = spawn( "script_origin", ( -18960, 36845.5, -171.5 ) );
	level.vo_origin.animname = "krav";
	
	level.vo_origin say_dialogue( "recording_1" );
	wait( 0.2 );
	level.vo_origin say_dialogue( "recording_2" );
	wait( 0.2 );
	level.vo_origin say_dialogue( "recording_3" );
	wait( 0.2 );
	level.vo_origin say_dialogue( "recording_4" );
	wait( 0.2 );
	level.vo_origin say_dialogue( "recording_5" );
	wait( 0.2 );
	level.vo_origin say_dialogue( "recording_6" );
	wait( 0.2 );
	level.vo_origin say_dialogue( "recording_7" );
	wait( 0.2 );
	level.vo_origin say_dialogue( "recording_8" );
	wait( 0.2 );
	level.vo_origin say_dialogue( "recording_9" );
	wait( 0.2 );
	level.vo_origin say_dialogue( "recording_10" );

	//flag_set( "recording_playback_finished" );
}

temp_end_testing()
{
	trigger_wait( "temp_end_testing" );
	level notify( "tunnel_burstout" );
}

#using_animtree ("generic_human");

ending_choppers()
{
	level thread ending_smoke_pillar();
	
	flag_wait( "rock_3_broken" );
	
	//TUEY SETMUSIC STATE
	setmusicstate ("CLIFF_HANGER");
	
	level thread animate_woods_huey();
		
	level thread ending_explosions_large();
	level thread ending_explosions_small();
	
	wait( 1.0 );
	//level waittill( "tunnel_burstout" );
	
	level thread ending_tracers_large();
	level thread ending_tracers_small();
	
	wait( 1.5 );
	level thread ending_vc_action();
	
	// spawn the choppers
	trigger_use( "player_leaves_tunnel" );
	wait( 0.2 );
	trigger_use( "player_leaves_tunnel_2" );
	
	wait( 0.5 );
	level thread end_huey_attack( "end_huey_1", "end_huey_1_fire" );
	level thread end_huey_attack( "end_huey_2", "end_huey_2_fire" );
	level thread end_huey_attack_special( "end_huey_3", "end_huey_3_fire" );	
}
#using_animtree ("generic_human");
animate_woods_huey()
{
	anim_node = getstruct( "b4_anim_tunnel_out", "targetname" );
	
	level.save_huey = getent( "end_saved_huey_model", "targetname" );
	PlayFXOnTag(level._effect["huey_main_blade"], level.save_huey, "main_rotor_jnt");
	level.save_huey Attach("t5_veh_helo_huey_att_interior", "tag_body");
	level.save_huey Attach("t5_veh_helo_huey_att_decal_hvyhog", "tag_body");
	level thread load_up_huey( level.save_huey, true, false, false );
	
	level.save_huey.fake_turret = spawn( "script_model", level.save_huey GetTagOrigin( "tag_flash_gunner3" ) );
	level.save_huey.fake_turret SetModel( "tag_origin" );

	level thread maps\creek_1_anim::play_vehicle_anim_single_solo( level.save_huey, "huey", anim_node, "ending_rescue" );
	
	anim_node thread anim_single_aligned( level.barnes, "ending_rescue" );
	anim_node thread anim_single_aligned( level.hudson, "ending_rescue" );
	level thread play_huey_woods_sound();
	
	/*
	turret = spawnTurret( "misc_turret", ( 0, 0, 0 ), "huey_noseturret" );
	turret linkto( level.save_huey, "tag_flash_gunner3", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	//turret SetTargetEntity( ent );
	while( 1 )
	{
		turret shoot();
		wait( 0.1 );
	}
	*/
}
play_huey_woods_sound()
{
	wait(4);
	playsoundatposition ("veh_huey_land", (0,0,0));
}
ending_vc_action()
{
	wait( 1 );
	
	origin_pos = getstruct( "player_reznov_tunnel_pos", "targetname" );
	level.reznov forceteleport( origin_pos.origin, origin_pos.angles );
	level.reznov resume_fire();
	level.reznov.grenadeammo = 0; 
	level.reznov AllowedStances( "crouch" );
	level.reznov.goalradius = 16;
	level.reznov go_to_node_by_name( "reznov_end_cliff_node" );
	
	//iprintlnbold( "reznov here" );
	
	vc1 = simple_spawn_single( "vc_ending_1" );
	vc2 = simple_spawn_single( "vc_ending_2" );
	//iprintlnbold( "VC spawn" );
	
	createthreatbiasgroup( "player" );
	createthreatbiasgroup( "ending_vc" );
	createthreatbiasgroup( "reznov" );
	createthreatbiasgroup( "friendlies" );
	vc1 SetThreatBiasGroup( "ending_vc" );
	vc2 SetThreatBiasGroup( "ending_vc" );
	level.reznov SetThreatBiasGroup( "reznov" );
	level.hudson SetThreatBiasGroup( "friendlies" );
	level.barnes SetThreatBiasGroup( "friendlies" );
	player = get_players()[0];
	player SetThreatBiasGroup( "player" );
	
	SetIgnoreMeGroup( "player", "ending_vc" );
	SetIgnoreMeGroup( "friendlies", "ending_vc" );
	
	wait( 1 );
	vc3 = simple_spawn_single( "vc_ending_3" );
	vc3 SetThreatBiasGroup( "ending_vc" );
	
	//TUEY set's music to CLIFF HANGER
	setmusicstate ("CLIFF_HANGER");
	
	level.reznov thread say_dialogue( "mason_vc_cliff" );
	
	trigger_use( "ending_extras_1" ); // more hueys
	wait( 4 );
	player = get_players()[0];
	player thread say_dialogue( "where_is_woods" );
	wait( 2 );
	//iprintlnbold( "More VC spawn" );

	level thread play_multiple_bullet_impact_fx( vc1 );
	wait( 0.5 );
	if( isalive( vc1 ) )
	{
		vc1 ai_suicide();
	}
	if( isalive( vc2 ) )
	{
		level thread play_multiple_bullet_impact_fx( vc2 );
		wait( 0.5 );
		vc2 ai_suicide();
	}
	if( isalive( vc3 ) )
	{
		level thread play_multiple_bullet_impact_fx( vc3 );
		wait( 0.5 );
		vc3 ai_suicide();
	}
	
	level thread play_multiple_bullet_impact_fx();

	playfx( level._effect["vehicle_explosion"], ( -17019, 38710, -148.2 ) );
	wait( 1.5 );
	level notify( "all_vcs_killed" );
	wait( 1.0 );
	player say_dialogue( "come_on_come_on" );
	wait( 3.5 );

	
	//iprintlnbold( "Woods: Good work. Here. Grab this rope." );
}

play_multiple_bullet_impact_fx( guy )
{
	if( isdefined( guy ) )
	{
		origin_fx_init = guy.origin;
		for( i = 0; i < 5; i++ )
		{
			origin_fx =  origin_fx_init + ( randomint(50)-25, randomint(50)-25, 0 );
			
			start_pos = level.save_huey GetTagOrigin( "tag_flash_gunner3" );
			angles_forward = VectorToAngles( origin_fx - start_pos );
			
			level.save_huey.fake_turret.origin = start_pos;
			level.save_huey.fake_turret.angles = angles_forward;
				
			playfxontag( level._effect["huey_mg"], level.save_huey.fake_turret, "tag_origin" );
			playfx( level._effect["bullet_impact"], origin_fx );
			wait( 0.1 );
		}
	}
	else
	{
		while( 1 )
		{
			level.save_huey.fake_turret.origin = level.save_huey GetTagOrigin( "tag_flash_gunner3" );
			level.save_huey.fake_turret.angles = level.save_huey GetTagAngles( "tag_flash_gunner3" );
			playfxontag( level._effect["huey_mg"], level.save_huey.fake_turret, "tag_origin" );
			wait( 0.1 );
		}
	}
}

fire_mg_continuously_end()
{
	level endon( "all_vcs_killed" );
	while( 1 )
	{
		self FireGunnerWeapon( 2 );
		wait( 0.1 );
	}
}

end_huey_attack( huey_name, wait_node )
{
	huey = getent( huey_name, "targetname" );
	huey endon( "death" );
	
	vehicle_node_wait( wait_node );
	wait( 0.5 );
	
	targ = GetEnt( huey_name + "_target_1", "targetname" );
	huey thread huey_rocket_shoot( targ );
	wait( 0.1 );
	huey thread huey_rocket_shoot( targ );
	wait( 0.4 );
	
	targ = GetEnt( huey_name + "_target_2", "targetname" );
	huey thread huey_rocket_shoot( targ );
	wait( 0.1 );
	huey thread huey_rocket_shoot( targ );
	wait( 0.4 );
	
	targ = GetEnt( huey_name + "_target_3", "targetname" );
	huey thread huey_rocket_shoot( targ );
	wait( 0.1 );
	huey thread huey_rocket_shoot( targ );
	wait( 0.4 );
	
	targ = GetEnt( huey_name + "_target_4", "targetname" );
	if( !isdefined( targ ) )
	{
		return;
	}
	huey thread huey_rocket_shoot( targ );
	wait( 0.1 );
	huey thread huey_rocket_shoot( targ );
	wait( 0.4 );
	
	targ = GetEnt( huey_name + "_target_5", "targetname" );
	huey thread huey_rocket_shoot( targ );
	wait( 0.1 );
	huey thread huey_rocket_shoot( targ );
}

end_huey_attack_special( huey_name, wait_node )
{
	huey = getent( huey_name, "targetname" );
	huey endon( "death" );

	end_huey_attack( huey_name, wait_node );
	
	targ = getent( "end_huey_mg_target", "targetname" );
	huey thread end_huey_use_mg( targ );
	
	huey huey_rocket_shoot( targ );
	wait( 0.5 );
	huey huey_rocket_shoot( targ );
}

end_huey_use_mg( firing_target )
{
	self SetGunnerTargetEnt( firing_target, (0,0,0), 0 );
	self SetGunnerTargetEnt( firing_target, (0,0,0), 1 );
	self SetGunnerTargetEnt( firing_target, (0,0,0), 2 );
	//self waittill("gunner_turret_on_target");
				
	while( 1 )
	{
		//self FireGunnerWeapon(0);
		//self FireGunnerWeapon(1);
		self FireGunnerWeapon(2);
		wait .2;
		//self FireGunnerWeapon(0);
		//self FireGunnerWeapon(1);
		self FireGunnerWeapon(2);
		wait .2;
		//self FireGunnerWeapon(0);
		//self FireGunnerWeapon(1);
		self FireGunnerWeapon(2);
		wait .2;
		//self FireGunnerWeapon(0);
		//self FireGunnerWeapon(1);
		self FireGunnerWeapon(2);
		wait .2;
		//self FireGunnerWeapon(0);
		//self FireGunnerWeapon(1);
		self FireGunnerWeapon(2);
		wait( 0.2 );
	}
}

huey_rocket_shoot( targ )
{
	self SetTurretTargetEnt(targ);
	self waittill("turret_on_target");
	self FireWeapon("", targ);
	
	wait( 0.5 );
	playfx( level._effect["explosion_extreme"], targ.origin );
}

ending_smoke_pillar()
{
	smoke_structs = getstructarray( "end_fx_smoke_pillar" );
	for( i = 0; i < smoke_structs.size; i++ )
	{
		playfx( level._effect["fx_fire_ember_column_lg"], smoke_structs[i].origin );
		playfx( level._effect["fx_fire_column_creep_xsm"], smoke_structs[i].origin );
	}
}

ending_explosions_large()
{
	explosion_structs = get_chained_structs( "end_fx_explosion_large" );
	
	while( 1 )
	{
		for( i = 0; i < explosion_structs.size; i++ )
		{
			playfx( level._effect["vehicle_explosion"], explosion_structs[i].origin );
			wait( randomfloatrange( 0.4, 0.8 ) );
		}
		
		wait( 0.7 );
	}
}

ending_explosions_small()
{
	explosion_structs = get_chained_structs( "end_fx_explosion_small" );
	
	while( 1 )
	{
		for( i = 0; i < explosion_structs.size; i++ )
		{
			playfx( level._effect["grenade_explode"], explosion_structs[i].origin );
			wait( randomfloatrange( 0.3, 0.6 ) );
		}
		wait( 0.5 );
	}
}

ending_tracers_large()
{
	tracer_structs = getstructarray( "end_fx_tracer_aa" );
	while( 1 )
	{
		for( i = 0; i < tracer_structs.size; i++ )
		{
			playfx( level._effect["grenade_explode"], tracer_structs[i].origin );
			wait( randomfloatrange( 0.2, 0.8 ) );
		}
		wait( 1.5 );
	}
}

ending_tracers_small()
{
	wait( 0.1 );
	tracer_structs = getstructarray( "end_fx_tracer_start" );
	while( 1 )
	{
		for( i = 0; i < tracer_structs.size; i++ )
		{
			playfx( level._effect["grenade_explode"], tracer_structs[i].origin );
			wait( randomfloatrange( 0.2, 0.8 ) );
		}
		wait( 2 );
	}
}

get_chained_structs( struct_start_name )
{
	chain_structs = [];
	first_struct = getstruct( struct_start_name, "targetname" );
	if( !isdefined( first_struct ) )
	{
		return( undefined );
	}
	chain_structs[0] = first_struct;
	current_struct = first_struct;
	
	while( isdefined( current_struct.target ) )
	{
		current_struct = getstruct( current_struct.target, "targetname" );
		if( !isdefined( first_struct ) )
		{
			return( chain_structs );
		}
		chain_structs[chain_structs.size] = current_struct;
	}
	return( chain_structs );
}


huey_fire_mg()
{
	self endon( "death" );
	
	if( !isdefined( self.script_string ) )
	{
		return;
	}
	
	struct_target = getstruct( self.script_string, "targetname" );
	self SetGunnerTargetVec( struct_target.origin, 0 );
	self SetGunnerTargetVec( struct_target.origin, 1 );
	self SetGunnerTargetVec( struct_target.origin, 2 );
	self SetTurretTargetVec( struct_target.origin );
	//self waittill("gunner_turret_on_target");
	
	while( 1 )
	{
		burst_count = randomintrange( 6, 10 );
		for( i = 0; i < burst_count; i++ )
		{
			//self FireGunnerWeapon(0);
			//self FireGunnerWeapon(1);
			self FireGunnerWeapon(2);
			wait .1;
		}
		wait( 0.5 );
	}
}


huey_fire_mg_no_target()
{
	self endon( "death" );
	
	while( 1 )
	{
		burst_count = randomintrange( 6, 10 );
		for( i = 0; i < burst_count; i++ )
		{
			//self FireGunnerWeapon(0);
			//self FireGunnerWeapon(1);
			self FireGunnerWeapon(2);
			wait .1;
		}
		wait( 0.5 );
	}
}


//**********************
//  AUDIO SECTION
//**********************

force_play_VC_death_audio()
{
    position = self.origin;
    self waittill( "death" );
    
    playsoundatposition( "dds_vc1_death", position );
}

audio_tuco_begins()
{
    array_thread( getstructarray( "tuco_ambient_elements", "targetname" ), ::tuco_play_ambient_elements );
    
    ent = Spawn( "script_origin", (0,0,0) );
    ent PlayLoopSound( "evt_tuco_loop_high", 8 );
    
    playsoundatposition( "evt_tuco_start", (0,0,0) );
    wait(2.3);
    playsoundatposition( "evt_tuco_start_hit", (0,0,0) );
    
    level waittill( "crawl_tunnel_end" );
    wait(3);
    
    ent StopLoopSound( 5 );
    
    //playsoundatposition( "evt_tuco_rockfall_final", (0,0,0) );
}

tuco_play_ambient_elements()
{
    level endon( "crawl_tunnel_end" );
    
    if( !IsDefined( self ) )
        return;
    
    while(1)
    { 
        PlaySoundatposition( "evt_tuco_ambient_elements", self.origin );
        wait(RandomFloatRange( 2, 5 ));
    }
}

tuco_crawling_anim_audio()
{
	player = get_players()[0];
	
	while( 1 )
	{
		self waittill( "crawl_anim", notetrack );
		if( notetrack == "crawl_in" )
		{
		    player PlaySound( "evt_tuco_player_crawl" );
		    //IPrintLnBold( "Crawling Noises" );
		}
	}
}

bomb_activate( num )
{
    struct = getstruct( "tuco_bomb_" + num, "targetname" );
    
    if( !IsDefined( struct ) )
        return;

    playsoundatposition( "exp_mortar_dirt", struct.origin );
    player = get_players()[0];
    radiusdamage( struct.origin, 200, player.health + 10, 20 );	player = get_players()[0];
		PlayRumbleOnPosition( "artillery_rumble", struct.origin );
}
