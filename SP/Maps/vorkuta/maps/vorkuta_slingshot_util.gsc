#include common_scripts\utility; 
#include maps\_utility;
#include maps\vorkuta_util;
#include maps\_anim;
#include maps\_music;


/***********************************
Slingshot currently requires some map entities in order to function:

script_struct placed at the position the slingshot will be.  This should be angled facing the direction you want everything to face.
  Currently needs to be named 'slingshot_align_node'.  Node should be dropped to ground.
	
trigger_multiple place in front of the script_struct.  Targetname of 'slingshot_activate'.

Please see SLINGSHOTTEST test map for use
************************************/

slingshot_precache()
{
	PreCacheItem("molotov_slingshot_sp");
	PreCacheItem("napalmblob_sp");	
	PreCacheModel("anim_rus_vork_slingshot_far");
	PreCacheModel("anim_rus_vork_slingshot_ammo");
	PreCacheShader("reticle_m203");
	PrecacheRumble( "damage_light" );
	PrecacheRumble( "damage_heavy" );
}

setup_slingshot()
{
	thread debug_show();

	thread setup_slingshot_friendly_fire();
	
	flag_init("slingshot_fired_vo");
	flag_init("slingshot_loading_sling");
	flag_init("slingshot_give_back_weapon");
	
	level.reznov_speech_end = false;
	
	//fail to pull back lines
	level.shoot_fail_vo[0] = "fail_shot_1";
	level.shoot_fail_vo[1] = "fail_shot_2";
	level.shoot_fail_vo[2] = "fail_shot_3";

	level.slingshot_input = 0;
	level.slingshot_weights = [];
	
	//-- the drones are so far away we don't need the sounds
	level._drones_sounds_disable = true;	
	//level.slingshot_view_angles = 30;
	level.max_drones["axis"] = 50;
	//spawn slingshot model
	level.slingshot_anim_node = getstruct("slingshot_align_node", "targetname");
	
	level.slingshot = Spawn("script_model", level.slingshot_anim_node.origin);
	level.slingshot SetModel("anim_rus_vork_slingshot_far");
	level.slingshot.angles = level.slingshot_anim_node.angles;
	level.slingshot.animname = "slingshot";
	
	//Prep ammo for first contact
	level.slingshot_ammo = spawn_slingshot_ammo( level.slingshot );
	level.slingshot_ammo.angles = level.slingshot_anim_node.angles;
	level.slingshot_ammo.animname = "slingshot_ammo";
	level.slingshot_ammo UseAnimTree( level.scr_animtree["slingshot_ammo"] );
	
	//spawn the two prisoners to hold the slingshot
	level.prisoner_left = Simple_Spawn_Single( "slingshot_ally_left", ::setup_prisoner_helper, "slingshot_prisoner_left" );
	level.prisoner_right = Simple_Spawn_Single( "slingshot_ally_right", ::setup_prisoner_helper, "slingshot_prisoner_right");	
	
	//create VO node
	level.slingshot_ai_vo_node = Spawn( "script_origin", level.prisoner_right.origin );
	level.slingshot_ai_vo_node.random_target_vo_set = false;
	level.slingshot_ai_vo_node.animname = "rrd3";
	
	// create player arm
	player = get_players()[0];
	hands = spawn_anim_model( "slingshot_body" );
	hands.animname = "slingshot_body";
	level.slingshot_hands = hands;
	//level.slingshot_hands.origin = level.slingshot_anim_node.origin - (0, -10, 0);
	level.slingshot_hands.angles = level.slingshot_anim_node.angles;
	level.slingshot_hands Hide();

//	/#
//	recordEnt( level.slingshot );
//	recordEnt( level.slingshot_ammo );
//	recordEnt( level.slingshot_hands );
//
//	SetDvar("g_dumpAnims", level.slingshot_hands GetEntNum());
//	SetDvar("g_dumpAnimsCommands", level.slingshot_hands GetEntNum());
//
//	iprintln( "hands: " + level.slingshot_hands GetEntNum() );
//	iprintln( "slingshot: " + level.slingshot GetEntNum() );
//	iprintln( "ammo: " + level.slingshot_ammo GetEntNum() );
//	#/

	flag_wait("flag_player_on_roof");

	level.slingshot.active = false;
	level.slingshot_ready = false;
	level thread slingshot_trigger_hint_press();	
	level thread slingshot_ai_vo();
	level thread slingshot_nagger("player_on_slingshot");
	player thread setup_low_ready_roof();
	level waittill("slingshot_roof_done");
	
	//FOR REZNOV'S SPEECH
	level.reznov_speech_end = true;
	
	level.slingshot_ai_vo_node.animname = "crow";
	level.slingshot_ai_vo_node thread anim_single( level.slingshot_ai_vo_node, "success_slingshot_ura" );
	disable_slingshot();	
}

setup_low_ready_roof()
{
	level endon("slingshot_roof_done");

	while(1)
	{
		trigger_wait("vision_slingshot");
		self SetLowReady(true);

		trigger_wait("sling_roof_trig");
		self SetLowReady(false);
	}

}	

//adjust friendly fire fail based on difficulty settings
setup_slingshot_friendly_fire()
{
	default_friendly_fail = level.friendlyfire[ "min_participation" ];

	switch( GetDifficulty() )
	{
	case "easy": 
		level.friendlyFireDisabled = 1;
		break;
	case "medium":
		level.friendlyfire[ "min_participation" ] = default_friendly_fail;
		break;
	case "hard":
		level.friendlyfire[ "min_participation" ] = default_friendly_fail + 400;
		break;
	case "fu":
		level.friendlyfire[ "min_participation" ] = default_friendly_fail + 800;
		break;			
	}

	level waittill("slingshot_roof_done");

	//reset default friendly fire behavior
	level.friendlyFireDisabled = 0;
	level.friendlyfire[ "min_participation" ] = default_friendly_fail;
}

//Setup whatever is needed for the prisoner helpers
setup_prisoner_helper(animname)
{
	self maps\_prisoners::make_prisoner();
	self magic_bullet_shield();	

	self.animname = animname;

	self LookAtEntity(get_players()[0]);

	flag_wait("player_on_slingshot");

	self LookAtEntity();
}

//Places ammo into the desired position based on the slingshot unit passed in
spawn_slingshot_ammo( slingshot )
{
	ammo_pos = slingshot.origin + (0,0,0);//Add any necessary offset
	slingshot_ammo = Spawn( "script_model", ammo_pos );
	slingshot_ammo SetModel("anim_rus_vork_slingshot_ammo");	
	return( slingshot_ammo );
}

//The actual firing portion of the weapon, called when notetrack activates it
fire_slingshot(slingshot_center_ent)
{	
	if(level.fired_early)
	{
		level.fired_early = false;
		return;
	}

	//grab the player angles without control
	player = get_players()[0];
	player FreezeControls(true);
	wait(0.1);
	fire_angles = player GetPlayerAngles();
	player FreezeControls(false);

	//this value will affect the arc as it essentially aims further away, gives more velocity
	slingshot_vel_min = 1200;
	
	//clamp the forward direction
	fire_yaw = fire_angles[1];
	if( (fire_yaw < 0) && (fire_yaw > -116) )
	{
		fire_yaw = -116;
	}
	else if( (fire_yaw > 0) && (fire_yaw < 145) )
	{
		fire_yaw = 145;
	}
	fire_angles = (fire_angles[0], fire_yaw, fire_angles[2]);

	//Check player facing everytime we fire
	//level.fire_angles = level.slingshot_hands GetTagAngles("tag_camera");
	player_forward = AnglesToForward( fire_angles );
	
	origin_up = AnglesToUp(fire_angles);//This is the upwards offset for fire origin
	origin_forward = AnglesToForward(fire_angles);//This is the forward offset for fire origin
	
	highest_pitch = -10;
	lowest_pitch = 15;

	fire_pitch = fire_angles[0];
	fire_pitch = clamp(fire_pitch, highest_pitch, lowest_pitch);

	t = (fire_pitch - lowest_pitch) / ( highest_pitch - lowest_pitch );

	//Update target relative to player facing with respect to shot origin
	slingshot_velocity = player_forward * (slingshot_vel_min + (t * 300.0) );//Fire velocity based on player facing			

	extra_up = 300 + t * 400;
	slingshot_velocity += (0,0,extra_up);

	//origin_up_offset = slingshot_center_ent.origin + up * 50;
	////origin_with_offset = slingshot_center_ent.origin + (origin_forward * 60) + (origin_up * 60);//Calculate the molotov origin based upon offsets
	origin_with_offset = level.slingshot_hands GetTagOrigin("tag_camera") /*+ (origin_forward * 60) + (origin_up * 60)*/;
	
	//target = level.slingshot_hands GetTagOrigin("tag_camera") + player_forward * 2500;//For testing aim only
	//thread draw_debug_line(origin_with_offset, target, 20);	//For testing aim only
	
	//Fire weapon: Note that magicgrenadetype takes in a velocity and not a target as magicgrenade() does
	level.cocktail = player MagicGrenadetype("molotov_slingshot_sp", origin_with_offset, slingshot_velocity, 0.5);//Timer currently does not work for molotov
	level.cocktail thread grenade_watch();
	//PrintLn("BUTTON PRESSED");	
	
	level.slingshot_ammo Unlink();
	level.slingshot_ammo Hide();
}

//on explosion
grenade_watch()
{
	self waittill("death");
	g_org = self.origin;
	player = get_players()[0];

	//molotov hit the bottom section with all the shrimps and drones
	if( (g_org[2] < 800) && (GetDifficulty() != "easy") )
	{
		for(i = 0; i < 2; i++)
		{
			prisoner_model = create_prisoner_model(undefined, g_org);
			prisoner_model StartRagdoll();
			ragdoll_direction = (RandomIntRange(-100, 100), RandomIntRange(-100,100), 200);
			prisoner_model Launchragdoll( ragdoll_direction );
			wait(0.1);
		}		
	}

	for(i = 0; i < 5; i++)
	{
		drones = GetEntArray("drone","targetname");

		on_fire = get_array_of_closest(g_org, drones, undefined, undefined, 256);
		for(j = 0; j < on_fire.size; j++)
		{
			on_fire[j] thread maps\_drones::drone_flameDeath();
		}

		wait(2.0);
	}
}

debug_aimer()
{
	player = get_players()[0];
	while(1)
	{
		fire_angles = player GetPlayerAngles();
		player_forward = AnglesToForward( fire_angles );	
		slingshot_velocity = player_forward * 2500;
		target = player.origin + slingshot_velocity;
		thread draw_debug_line(player.origin, target, .5);	//For testing aim only
		wait(.5);
	}
}

slingshot_trigger_hint_press()
{
	level endon( "slingshot_roof_done" );

	level thread slingshot_trigger_press();
	player = get_players()[0];
	trigger_wait("slingshot_activate");

	player DisableWeapons();

	//stop FX in omaha
	stop_exploder(1200);

	//spawn an origin to lerp the player and lock them until the first shot
	anchor = spawn("script_origin", level.slingshot_anim_node.origin);
	anchor.origin = anchor.origin + (20, 0, 0);
	anchor.angles = level.slingshot_anim_node.angles;

	//flag to notify the nag function to stop
	flag_set("player_on_slingshot");

	player lerp_player_view_to_position(anchor.origin, anchor.angles, 0.5, 1);
	player PlayerLinkToDelta( anchor, undefined, 0, 25, 25, 20, 10, false );
	
	
	//instructions on how to use the slingshot
	screen_message_create(&"PLATFORM_SLING_HINT");

	setmusicstate("SLINGSHOT_SPEECH");
	
	level thread play_reznov_speech();

	//clientnotify( "sgs" );  //Notifying the client of the SlinG Speech
	//level thread play_reznov_vox();
	level thread slingshot_hud();
	level.slingshot_ready = true;
	player setlowready(true);

	flag_wait("slingshot_loading_sling");

	screen_message_delete();

	level waittill("slingshot_roof_done");

	//remove the entity no longer being used
	anchor Delete();

	player setlowready(false);
	level.slingshot_ready = false;
}

slingshot_additional_tutorial_hint_press()
{
	level endon("slingshot_loading_sling");
	level endon( "slingshot_roof_done" );

	wait(3);

	screen_message_create(&"PLATFORM_SLING_HINT");

	flag_wait("slingshot_loading_sling");

	screen_message_delete();
}

slingshot_trigger_press()
{
	level endon( "slingshot_roof_done" );

	level.fired_early = false;

	player = get_players()[0];
	//player DisableWeapons();	

	while( 1 )
	{
		level thread slingshot_play_idle_anim();
		
		if(!level.slingshot.active)
		{
			while( !level.slingshot_ready )
			{
				wait( 0.05 );
			}
			thread slingshot_ready_vo();
		}
		else if(level.sling_vo_locations.size > 1)
		{
			index = RandomInt(level.sling_vo_locations.size);
			level.slingshot_ai_vo_node anim_single( level.slingshot_ai_vo_node, level.sling_vo_locations[index] );
		}

		level thread slingshot_additional_tutorial_hint_press();
				
		//wait for player to push the L stick back
		while( !player slingshot_holding_stick() )
		{
			wait( 0.05 );
		}

		//remove the tutorial message if it exists
		screen_message_delete();

		//achievement tracking
		level.slingshot_shots_taken++;

		player PlayLoopSound( "wpn_slingshot_molotov_loop", 1.5 );
		player thread slingshot_play_pull_anim();

		//detects the case where they let go before pulling the sling back all the way
		level thread slingshot_early_fire();

		level waittill( "slingshot_loading_sling" );

		if(!level.fired_early)
		{
			//get in starting position
			level thread slingshot_hands_animator_think();
			wait(.05);
			level.slingshot.active = true;
			player PlayRumbleLoopOnEntity( "damage_heavy" );

			effect_ent = Spawn("script_model", level.slingshot_ammo GetTagOrigin("tag_animate_body"));
			effect_ent SetModel("tag_origin");
			effect_ent LinkTo( level.slingshot_ammo, "tag_animate_body", (0,0,0), (0,0,0) );
			slingshot_fx = PlayFXOnTag( level._effect["slingshot_molotov_wicker"], effect_ent, "tag_origin" );

			//We want to fire on release
			while( player slingshot_holding_stick() )
			{
				wait( 0.05 );
			}

			//while the player idles allow look in all directions
			player PlayerLinkToDelta( level.slingshot_hands, "tag_player", 0, 25, 25, 20, 10, false );

			level.slingshot_fire_weights = level.slingshot_weights;
			player startcameratween( 2 );
			effect_ent Delete();
			level.slingshot_player_pull = false;
			player StopRumble( "damage_light" );
			player StopLoopSound( .5 );
			player PlaySound( "wpn_slingshot_fire" );

			//shake the camera on release of the sling
			Earthquake(1, 0.5, player.origin, 256);

			player slingshot_play_fire_straight_anim(level.slingshot_fire_weights);

			//player slingshot_play_fire_blend_anim();
		}
		else
		{
			level waittill("early_sling_release_done");
		}
	}
}

slingshot_holding_stick()
{
	movement = self GetNormalizedMovement();

	if( movement[0] < -0.5 )
	{	
		return( true );
	}
	else
	{
		return( false );
	}
}

slingshot_early_fire()
{
	self notify("stop_slingshot_early_fire");
	self endon("stop_slingshot_early_fire");

	player = get_players()[0];

	//if the player lets go of the right trigger while loading the weapon
	while( flag("slingshot_loading_sling") )
	{
		if( !player slingshot_holding_stick() )
		{
			player notify("released_early");

			//hide the ammo if it was already attached in the notetrack
			level.slingshot_ammo Hide();

			flag_clear("slingshot_loading_sling");

			//while the player idles allow look in all directions
			player PlayerLinkToDelta( level.slingshot_hands, "tag_player", 0, 25, 25, 20, 10, false );
			player startcameratween( 2 );
			player StopRumble( "damage_light" );
			player StopLoopSound( .5 );
			player PlaySound( "wpn_slingshot_snap1" );
			level.fired_early = true;
			
			//play a "failed to pull back" vo nag
			index = RandomInt(level.shoot_fail_vo.size);
			if(IsDefined(level.slingshot_ai_vo_node) && level.slingshot_ai_vo_node.animname == "rrd3")
			{
				level.slingshot_ai_vo_node thread anim_single( level.slingshot_ai_vo_node, level.shoot_fail_vo[index] );
			}

			player slingshot_play_fire_straight_anim(level.slingshot_fire_weights);
			level notify("early_sling_release_done");

		}
		wait(0.05);
	}
}

slingshot_nagger(ender_flag)
{
	nag_line = [];
	nag_line[0] = "our_men_are_dying";
	nag_line[1] = "mason_quickly_cant_hold_out";
	nag_line[2] = "come_one_mason_men_need_you";

	wait(5);
	
	level.slingshot_ai_vo_node.animname = "rrd3";
	maps\vorkuta_util::do_nag_vo_array(level.slingshot_ai_vo_node, nag_line, ender_flag, 8);
}

slingshot_ready_vo()
{
	level.slingshot_ai_vo_node anim_single( level.slingshot_ai_vo_node, "our_men_are_trapped" );//Our men are trapped!
	level.slingshot_ai_vo_node thread anim_single( level.slingshot_ai_vo_node, "clear_a_path" );//Clear a path for them!	
	thread redshirt_corpse_cleanup();
}

disable_slingshot()
{
	player = get_players()[0];
	player Unlink();

	level.slingshot_hands Delete();
	level thread slingshot_play_ending_idle_anim();
	StopAllRumbles();
	level.slingshot_ammo Delete();
	wait(.5);
	player EnableWeapons();
	player SetLowReady(false);
}

slingshot_play_intro_death()
{
	level.slingshot thread slingshot_play_anim( "death_run" );
	level.prisoner_left thread slingshot_ai_play_anim( "death_run" );
	level.prisoner_right thread slingshot_ai_play_anim( "death_run" );
	level.prisoner_dead PlaySound( "dds_ru2_death" );
	level.prisoner_dead slingshot_ai_play_anim( "death_run" );
	
	level.slingshot thread slingshot_play_anim( "death_react" );
	level.prisoner_left thread slingshot_ai_play_anim( "death_react" );
	level.prisoner_right thread slingshot_ai_play_anim( "death_react" );
	level.prisoner_dead PlaySound( "dds_ru2_death" );
	level.prisoner_dead slingshot_ai_play_anim( "death_react" );
}

slingshot_play_wave_anim()
{
	level.slingshot thread slingshot_play_anim( "wave_idle", true );
	level.prisoner_left thread slingshot_ai_play_anim( "wave_idle", true );
	level.prisoner_right thread slingshot_ai_play_anim( "wave_idle", true );	
}

slingshot_play_idle_anim()
{
	level.slingshot thread slingshot_play_anim( "start_idle", true );
	level.prisoner_left thread slingshot_ai_play_anim( "start_idle", true );
	level.prisoner_right thread slingshot_ai_play_anim( "start_idle", true );
}

slingshot_play_pull_anim(player)
{
	//if the player lets go of the right trigger before fully taut
	self endon("released_early");

	self PlayRumbleLoopOnEntity( "damage_light" );

	//shake camera when player grabs sling
	//Earthquake(0.5, 0.3, self.origin, 256);

	flag_set("slingshot_loading_sling");

	time = .7;
	level.slingshot thread slingshot_play_anim( "pull_start" );
	level.prisoner_left thread slingshot_ai_play_anim( "pull_start" );
	level.prisoner_right thread slingshot_ai_play_anim( "pull_start" );
	level.slingshot_hands thread slingshot_player_play_anim( "pull_start" );
	
	wait(.05);
	
	sound_ent = Spawn( "script_origin", (0,0,0) );
	sound_ent PlayLoopSound( "wpn_slingshot_pullback" );
	self thread stop_sound_and_delete_ent_on_early_release( sound_ent );
	self PlayerLinkToDelta( level.slingshot_hands, "tag_player", 0, 25, 25, 20, 10, false );	
	self startcameratween(.5);
	
	wait(.2);
	
	level.slingshot_hands Show();
	
	level.slingshot_anim_node waittill("pull_start");

	level.slingshot thread slingshot_play_anim( "pull_finish" );
	level.prisoner_left thread slingshot_ai_play_anim( "pull_finish" );
	level.prisoner_right thread slingshot_ai_play_anim( "pull_finish" );
	level.slingshot_hands slingshot_player_play_anim( "pull_finish" );

	flag_clear("slingshot_loading_sling");

	slingshot_player_clear_anim();

	level slingshot_play_pull_idle_straight_anim();	
	
	if( IsDefined( sound_ent ) )
	    sound_ent Delete();
}

stop_sound_and_delete_ent_on_early_release( ent )
{
    self notify( "force_stop" );
    self endon( "force_stop" );
    
    self waittill( "released_early" );
    //IPrintLnBold( "RELEASED EARLY!" );
	if(IsDefined(ent))
	{
		ent StopLoopSound( .1 );
		wait(.2);
		ent Delete();
	}
}

slingshot_play_pull_idle_straight_anim()
{
	//level.slingshot thread slingshot_play_anim( "pull_idle_straight", true );//Should be commented out
	//level.slingshot_ammo thread slingshot_play_anim( "pull_idle_straight", true );
	level.prisoner_left thread slingshot_ai_play_anim( "pull_idle", true );
	level.prisoner_right thread slingshot_ai_play_anim( "pull_idle", true );
	//level.slingshot_hands thread slingshot_player_play_anim( "idle_straight", true );//Should be commented out
}

slingshot_play_fire_straight_anim(weights)
{
	if(level.fired_early)
	{
		level.slingshot thread slingshot_play_anim( "fire_straight" );
		level.prisoner_left thread slingshot_ai_play_anim( "fire_release" );
		level.prisoner_right thread slingshot_ai_play_anim( "fire_release" );
		level.slingshot_hands slingshot_player_play_anim( "fire_straight" );
		return;
	}

	player = get_players()[0];
	if(weights[0] >= .5)
		level.slingshot thread slingshot_play_anim( "fire_left" );
	else if(weights[2] >= .5)
		level.slingshot thread slingshot_play_anim( "fire_right" );
	else
		level.slingshot thread slingshot_play_anim( "fire_straight" );
	//level.slingshot_ammo thread slingshot_play_anim( "fire_straight" );
	level.prisoner_left thread slingshot_ai_play_anim( "fire_release" );
	level.prisoner_right thread slingshot_ai_play_anim( "fire_release" );
	self thread fire_rumble();
	if(!flag("slingshot_fired_vo"))
	{//we only want this once, it gets annoying
		level.slingshot_ai_vo_node thread anim_single( level.slingshot_ai_vo_node, "fire" );//Fire!!!
		flag_set("slingshot_fired_vo");
	}
	if(weights[0] >= .5)
	{
		//level.slingshot_anim_node anim_first_frame(level.slingshot_hands,"fire_left");
		//player PlayerLinkToAbsolute(level.slingshot_hands, "tag_player");
		//angles = level.slingshot_hands GetTagAngles( "tag_player" );
		player startcameratween(.5);
		//player SetPlayerAngles(angles);
		level.slingshot_hands slingshot_player_play_anim( "fire_left" );
	}
	else if(weights[2] >= .5)
	{
		//level.slingshot_anim_node anim_first_frame(level.slingshot_hands,"fire_right");	
		//player PlayerLinkToAbsolute(level.slingshot_hands, "tag_player");
		//angles = level.slingshot_hands GetTagAngles( "tag_player" );
		player startcameratween(.5);
		//player SetPlayerAngles(angles);	
		level.slingshot_hands slingshot_player_play_anim( "fire_right" );
	}
	else	
	{
		//level.slingshot_anim_node anim_first_frame(level.slingshot_hands,"fire_straight");	
		//player PlayerLinkToAbsolute(level.slingshot_hands, "tag_player");
		//angles = level.slingshot_hands GetTagAngles( "tag_player" );
		player startcameratween(.5);
		//player SetPlayerAngles(angles);		
		level.slingshot_hands slingshot_player_play_anim( "fire_straight" );
	}
	//player startcameratween(.5);
	//player PlayerLinkToDelta( level.slingshot_hands, "tag_player", 0, 0, 0, 30, -80, false );	
}

slingshot_play_fire_blend_anim()
{
	thread slingshot_blend_slingshot_fire( level.slingshot_fire_weights );
	thread slingshot_blend_ammo_fire( level.slingshot_fire_weights );
	level.prisoner_left thread slingshot_ai_play_anim( "fire_release" );
	level.prisoner_right thread slingshot_ai_play_anim( "fire_release" );
	self thread fire_rumble();
	if(!flag("slingshot_fired_vo"))
	{//we only want this once, it gets annoying
		level.slingshot_ai_vo_node thread anim_single( level.slingshot_ai_vo_node, "fire" );//Fire!!!
		flag_set("slingshot_fired_vo");
	}
	level.slingshot_hands slingshot_blend_player_fire( level.slingshot_fire_weights );
}

slingshot_play_ending_idle_anim()
{
	level.slingshot thread slingshot_play_anim( "ending_idle" );
	level.prisoner_left thread slingshot_ai_play_anim( "ending_idle" );
	level.prisoner_right slingshot_ai_play_anim( "ending_idle" );
	rightnode = GetNode( "slingshot_redshirt_right", "targetname" );
	leftnode = GetNode( "slingshot_redshirt_left", "targetname" );
	level.prisoner_left SetGoalNode( leftnode );
	//wait(1.5);
	//level.prisoner_right SetGoalNode( rightnode );
}

fire_rumble()
{
	self PlayRumbleOnEntity("damage_heavy");	
}

attach_ammo(ammo)
{
	level.slingshot_ammo LinkTo(level.slingshot, "tag_animate_body", (0,-3,4), (90,90,0));
	level.slingshot_ammo Show();
}

#using_animtree("animated_props");
slingshot_play_anim( anim_name, looping )
{
	self UseAnimTree( #animtree );
	if( IsDefined( looping ) && looping == true )
	{
		level.slingshot_anim_node anim_loop_aligned( self, anim_name );	
	}
	else
	{
		level.slingshot_anim_node anim_single_aligned( self, anim_name );	
	}
}

slingshot_blend_slingshot_aim(weights)
{
	/#
//	recordEntText( weights[0] + " - " + weights[1] + " - " + weights[2], level.slingshot, (1,0,0), "Script" );
//
//	player = get_players()[0];
//	recordLine( player.origin, level.slingshot.origin, (1,0,0), "Script" );
	#/

	level.slingshot ClearAnim(%root, 0.05);
	level.slingshot SetAnim(level.scr_anim["slingshot"]["pull_idle_right"][0], weights[2], 0.05, 1 );
	level.slingshot SetAnim(level.scr_anim["slingshot"]["pull_idle_left"][0], weights[0], 0.05, 1 );
	level.slingshot SetAnim(level.scr_anim["slingshot"]["pull_idle_straight"][0], weights[1], 0.05, 1 );
}

slingshot_blend_slingshot_fire(weights)
{
	level.slingshot ClearAnim(%root, 0.05);
	level.slingshot SetAnimRestart(level.scr_anim["slingshot"]["fire_right"], weights[2], 0.05, 1 );
	level.slingshot SetAnimRestart(level.scr_anim["slingshot"]["fire_left"], weights[0], 0.05, 1 );
	level.slingshot SetAnimRestart(level.scr_anim["slingshot"]["fire_straight"], weights[1], 0.05, 1 );
}

slingshot_blend_ammo_aim(weights)
{
//	level.slingshot_ammo ClearAnim(%root, 0.05);
//	level.slingshot_ammo SetAnim(level.scr_anim["slingshot_ammo"]["pull_idle_right"][0], weights[2], 0.05, 1 );
//	level.slingshot_ammo SetAnim(level.scr_anim["slingshot_ammo"]["pull_idle_left"][0], weights[0], 0.05, 1 );
//	level.slingshot_ammo SetAnim(level.scr_anim["slingshot_ammo"]["pull_idle_straight"][0], weights[1], 0.05, 1 );
	level.slingshot_ammo SetAnim(level.scr_anim["slingshot_ammo"]["pull_idle_straight"][0], 1, 0.05, 1 );
}

slingshot_blend_ammo_fire(weights)
{
//	level.slingshot_ammo ClearAnim(%root, 0.05);
//	level.slingshot_ammo SetAnimRestart(level.scr_anim["slingshot_ammo"]["fire_right"], weights[2], 0.05, 1 );
//	level.slingshot_ammo SetAnimRestart(level.scr_anim["slingshot_ammo"]["fire_left"], weights[0], 0.05, 1 );
//	level.slingshot_ammo SetAnimRestart(level.scr_anim["slingshot_ammo"]["fire_straight"], weights[1], 0.05, 1 );
}

#using_animtree("generic_human");
slingshot_ai_play_anim( anim_name, looping )
{
	if( IsDefined( looping ) && looping == true )
	{
		level.slingshot_anim_node anim_loop_aligned( self, anim_name );	
	}
	else
	{
		level.slingshot_anim_node anim_single_aligned( self, anim_name );	
	}
}

#using_animtree("player");
slingshot_player_play_anim( anim_name, looping )
{
	self UseAnimTree( #animtree );
	if( IsDefined( looping ) && looping == true )
	{
		level.slingshot_anim_node anim_loop_aligned( self, anim_name );	
	}
	else
	{
		level.slingshot_anim_node anim_single_aligned( self, anim_name );	
	}
}

slingshot_player_clear_anim()
{
	level.slingshot_hands anim_stopanimscripted();
	level.slingshot_hands ClearAnim(%root, 0.0);
}

slingshot_blend_player_aim(weights)
{
	level.slingshot_hands SetAnim(level.scr_anim["slingshot_body"]["idle_right"][0], weights[2], 0.05, 1 );
	level.slingshot_hands SetAnim(level.scr_anim["slingshot_body"]["idle_left"][0], weights[0], 0.05, 1 );	
	level.slingshot_hands SetAnim(level.scr_anim["slingshot_body"]["idle_straight"][0], weights[1], 0.05, 1 );
}

slingshot_blend_player_fire(weights)
{
	slingshot_player_clear_anim();

	level.slingshot_hands SetAnimRestart(level.scr_anim["slingshot_body"]["fire_right"], weights[2], 0.05, 1 );
	level.slingshot_hands SetAnimRestart(level.scr_anim["slingshot_body"]["fire_left"], weights[0], 0.05, 1 );	
	level.slingshot_hands SetFlaggedAnimRestart("slingshot_fire_finished",level.scr_anim["slingshot_body"]["fire_straight"], weights[1], 0.05, 1 );

	level.slingshot_hands waittillmatch("slingshot_fire_finished", "end");
}

slingshot_hands_animator_think()
{
	level endon("slingshot_roof_done");
	//thread debug_aimer();
	level.slingshot_weights_init = false;
	
	player = get_players()[0];
	level.slingshot_player_pull = true;
	while(level.slingshot_player_pull)
	{		
		player_rightstick_x = player GetNormalizedCameraMovement()[1];
		level.slingshot_hands slingshot_hands_animator( player_rightstick_x );

		wait(0.05);
	}	
}

slingshot_hands_animator( player_rightstick_x )
{	
	weights = set_slingshot_weights( player_rightstick_x );
			
 	thread slingshot_blend_player_aim(weights);	
	thread slingshot_blend_slingshot_aim(weights);
	thread slingshot_blend_ammo_aim(weights);
}

// 0 - left, 1 - center, 2 - right
set_slingshot_weights( player_rightstick_x )
{
	player_rightstick_x = clamp(player_rightstick_x, -1.0, 1.0);
	level.slingshot_input = player_rightstick_x; //(player_rightstick_x/1.3) * .1;

	//First run, set everything to center
	if(!level.slingshot_weights_init)
	{
		// Set the goal weights
		for( i = 0; i < 3; i++ )
		{
			level.slingshot_weights[i] = 0;
		}		
		level.slingshot_weights[1] = 1;
		level.slingshot_weights_init = true;
		return level.slingshot_weights;
	}

	minStickInput			= 0.01;
	weightChangeSpeedSlow	= 0.001;
	weightChangeSpeedFast	= 0.05;

	//No player input, we keep the weights as is
	if( abs(level.slingshot_input) < minStickInput )
	{
		return level.slingshot_weights;
	}

	// scale the turn speed by how much the player is pushign the stick
	stickSpeed				= (abs(level.slingshot_input) - minStickInput) / (1.0 - minStickInput);
	weightChangeSpeed		= weightChangeSpeedSlow + (weightChangeSpeedFast - weightChangeSpeedSlow) * stickSpeed;
	
	// setup for the algorithm below
	plusSide  = 2;
	otherSide = 0;
	center	  = 1;
	
	// going left
	if( level.slingshot_input > 0 )
	{
		plusSide  = 0;
		otherSide = 2;
	}

	// change the weights based on the direction of the stick,
	// but by no more than weightChangeSpeed per frame
	if( level.slingshot_weights[plusSide] > 0 )
	{
		// already playing that side's anim, just add weight
		level.slingshot_weights[plusSide]	+= weightChangeSpeed;
		level.slingshot_weights[center]		-= weightChangeSpeed;
		level.slingshot_weights[otherSide]  = 0.0;
	}
	else if( level.slingshot_weights[otherSide] < weightChangeSpeed )
	{
		// crossing over the center
		diff = weightChangeSpeed - level.slingshot_weights[otherSide];

		level.slingshot_weights[plusSide]	= diff;
		level.slingshot_weights[center]		= 1.0 - diff;
		level.slingshot_weights[otherSide]  = 0.0;
	}
	else
	{
		// still on the other side
		level.slingshot_weights[plusSide]	= 0;
		level.slingshot_weights[center]		+= weightChangeSpeed;
		level.slingshot_weights[otherSide]	-= weightChangeSpeed;
	}

	// clamp, cause some of these may be negatives
	for( i = 0; i < 3; i++ )
	{
		level.slingshot_weights[i] = clamp(level.slingshot_weights[i], 0.0, 1.0);
	}

	return level.slingshot_weights;	
}

slingshot_ai_vo()
{
	level.slingshot_ai_vo_node.animname = "rrd3";
	level.slingshot_ai_vo_node thread anim_single( level.slingshot_ai_vo_node, "ready_slingshot" );
	
	thread slingshot_play_wave_anim();
	level.slingshot_ai_vo_node.animname = "rrd3";
	level.slingshot_ai_vo_node anim_single( level.slingshot_ai_vo_node, "mason_lets_go" );
}

slingshot_cleanup()
{
	level._drones_sounds_disable = false;	
	level.max_drones["axis"] = 32;

	//stop fire fx
	stop_exploder(21);
	stop_exploder(22);
	stop_exploder(23);
	stop_exploder(24);
	stop_exploder(25);
		
	//delete all models created
	level.slingshot Delete();	
	
	level.slingshot_ai_vo_node Delete();
	
	//delete spawners/drones
	level.prisoner_left = getent( "slingshot_ally_left_ai", "targetname" );
	level.prisoner_right = getent( "slingshot_ally_right_ai", "targetname" );	
	level.prisoner_left Delete();
	level.prisoner_right Delete();
	
	guards = GetEntArray("sling_guards_ai", "targetname");
	for (i=0; i<guards.size; i++)
	{
		if(IsDefined(guards[i]))
			guards[i] delete();
	}
}

play_reznov_vox()
{
    player = get_players()[0];
    player PlaySound( "vox_reznov_speech", "sounddone" );
    wait(124);
    clientnotify( "sdd" );
}

slingshot_hud()
{
	hudReticle = NewHudElem();
	hudReticle.location = 0;
	hudReticle.alignX = "center";
	hudReticle.alignY = "middle";
	hudReticle.foreground = 1;
	hudReticle.fontScale = 2;
	hudReticle.sort = 20;
	hudReticle.x = 320;
	hudReticle.y = 240;
	hudReticle.og_scale = 1;
	hudReticle.color = (1,1,1);
	hudReticle.alpha = 1;
	hudReticle SetShader("reticle_m203", 128, 128);
	
	level waittill("slingshot_roof_done");
	
	hudReticle Destroy();
}

redshirt_corpse_cleanup()
{
	corpses = entsearch( level.CONTENTS_CORPSE, get_players()[0].origin, 200 );
	for( i = 0; i < corpses.size; i++ )
	{
		if( corpses[i].classname == "actor_Prisoner_AK47" )
			corpses[i] delete();
	}
}

debug_show()
{
	/*while(true)
	{
		tmpfacing = VectorNormalize( AnglesToForward( get_players()[0] GetPlayerAngles() ) );
		IPrintLn( "Output: " +  tmpfacing[1] );
		wait(0.05);
	}*/
}

/*
reznov_speech()
{
	player = get_players()[0];
	origin = spawn ("script_origin", player.origin); 
	origin PlaySound( "vox_reznov_speech" );
	origin.speech_done = false;
	origin thread speech_timer();
	trigger_wait( "sling_roof_trig" );
	origin stopsound("vox_reznov_speech");
	origin notify( "trig_hit" );
	
	if( !origin.speech_done )
	    origin PlaySound( "evt_microphone_feedback" );
	    
	wait (1);
	origin delete();
	setmusicstate ("COURTYARD_FIGHT");
}

speech_timer()
{
    self endon( "trig_hit" );
    
    wait(75);
    self.speech_done = true;
}
*/

play_reznov_speech()
{
    level endon( "end_reznov_speech" );
    
    player = get_players()[0];
    
    //Moving the origin out into the courtyard for mix -- TUEY
    origin = Spawn( "script_origin", (-3504, 4912, 1360) );
    
    origin PlaySound( "vox_vor1_s3_083A_rezn_f" );
    wait( 7.35 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_084A_rezn_f" );
    wait( 5 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_085A_rezn_f" );
    wait( 3.8 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_086A_rezn_f" );
    wait( 3.9 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_087A_rezn_f" );
    wait( 7 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_088A_rezn_f" );
    wait( 6 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_089A_rezn_f" );
    wait( 7.45 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_090A_rezn_f" );
    wait( 5.6 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_091A_rezn_f" );
    wait( 2.5 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_092A_rezn_f" );
    wait( 5.45 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_093A_rezn_f" );
    wait( 8.2 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_094A_rezn_f" );
    wait( 6.4 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_095A_rezn_f" );
    wait( 4.3 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_096A_rezn_f" );
    wait( 4.3 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_097A_rezn_f" );
    wait( 5.6 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_098A_rezn_f" );
    wait( 6.9 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_099A_rezn_f" );
    wait( 4.7 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_100A_rezn_f" );
    wait( 7.3 );
    check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_101A_rezn_f" );
    wait( 6 );
    check_reznov_speech_over( origin );
    //origin PlaySound( "vox_vor1_s3_102A_rezn_f" );
    //wait( 4.9 );
    //check_reznov_speech_over( origin );
    //origin PlaySound( "vox_vor1_s3_103A_rezn_f" );
    //wait( 5.2 );
    //check_reznov_speech_over( origin );
    //origin PlaySound( "vox_vor1_s3_104A_rezn_f" );
    //wait( 1.8 );
    //check_reznov_speech_over( origin );
    //origin PlaySound( "vox_vor1_s3_105A_rezn_f" );
    //wait( 2.5 );
    //check_reznov_speech_over( origin );
    origin PlaySound( "vox_vor1_s3_106A_rezn_f" );
    wait( 2.8 );
    origin PlaySound( "vox_vor1_s3_107A_rezn_f" );
    wait( 5 );
    origin PlaySound( "evt_microphone_feedback" );
}

check_reznov_speech_over( origin )
{
    if( level.reznov_speech_end )
    {
        //origin PlaySound( "vox_vor1_s3_106A_rezn_f" );
        //wait( 2.25 );
        //origin PlaySound( "vox_vor1_s3_107A_rezn_f" );
        //wait( 5 );
        origin PlaySound( "evt_microphone_feedback" );
        wait( 1 );
        setmusicstate ("SLINGSHOT_SPEECH_OVER");
        origin Delete();
        level notify( "end_reznov_speech" );
    }
}