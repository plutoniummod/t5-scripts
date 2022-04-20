/*
	
	KOWLOON E7 Platforming

	This starts after Clark falls to his death.
	This ends when we get to the van at the end of the mission
*/
#include common_scripts\utility; 
#include maps\_anim; 
#include maps\_utility;
#include maps\_music;

event7()
{
	level thread platform_dialog();
	level thread clark_death();
	level thread player_hunters();
	level thread platformers();
	level thread awning_ripped();
	level thread final_fall();

	flag_wait("event7");

	//shabs - landing rumble on player
	landing_rumble_on_player();

	Objective_Set3D( level.obj_num, false );
}


//  Preps the Clark death scene
clark_death()
{
//	clip = GetEnt( "e7_player_blocker", "targetname" );
//	clip thread clip_link();
//	trigger_wait( "trig_e7_clarke_jump" );

	trigger_wait( "go_jump_clarke" );

	//shabs - turning off DTP here
	allow_divetoprone( false );

	// Savegame is at the end of the current even so that it doesn't 
	// save immediately after starting a jumpto
	autosave_by_name( "kowloon_platform" );
	wait( 0.05 );

	level thread sprint_jump_check();

	level.heroes[ "clarke" ] thread maps\kowloon_anim::send_clark_ahead_to_jump();
	flag_wait( "e7_clark_jump" );
//	clip Unlink();
//	clip Delete();

	level.heroes[ "weaver" ] enable_ai_color();
}


//
//	Check to see if the player needs a hint.  If he dies on the jump, put up a hint
sprint_jump_check()
{
	// Player jumps
	trigger_wait("trig_e7_big_jump");

	level thread maps\kowloon_util::sprint_jump_custom_death_message();
}


//
//	
//clip_link()
//{
//	level endon( "e7_clark_jump" );
//
//	// hacky player clip so they don't jump ahead of him.
//	clip = GetEnt( "e7_player_blocker", "targetname" );
//
//	while (1)
//	{
//		clip MoveTo( level.heroes[ "clarke" ].origin, 0.05 );
//		wait( 0.05 );
//	}
//}


//
//	Keep the player moving
pusher_spawn()
{
	level endon( "e7_final_fall" );

	player = get_players()[0];

	while ( 1 )
	{
		ai = simple_spawn_single( self, ::force_goal );
		if ( IsDefined( ai ) )
		{
			self.script_forcespawn = 0;

			ai.disableIdleStrafing = 1;
			ai disable_react();
			ai.grenadeawareness = 0;
			ai.ignoreme = 1;
			ai.ignoresuppression = true;
			ai.meleeAttackDist = 0;
			ai.noDodgeMove = true; 
			ai.pathenemylookahead = 0;
			ai.script_accuracy = 0;
			ai.suppressionthreshold = 1;

			level.pushers = add_to_array( level.pushers, ai );
			ai waittill( "death" );

			level.pushers = array_remove( level.pushers, ai );
			wait( 2.0 );
		}
		wait( 0.5 );
	}
}


//
//	AI shoots at player.  Keeps player moving
player_hunters()
{
	level endon( "e7_final_fall" );

	flag_wait("event7");

	//shabs - delay pushers
	wait( 5 );

	level notify( "sprint_jump_cleared" );

	// Okay now kill all current enemies
	ai = GetAIArray( "axis" );
	for ( i=0; i<ai.size; i++ )
	{
		if ( IsAlive( ai[i] ) )
		{
			ai[i] DoDamage( ai[i].health, ai[i].origin );
		}
		wait( RandomFloatRange( 0.2, 0.5 ) );
	}

	spawners = GetEntArray( "ai_e7_pusher", "targetname" );
	for ( i=0; i<spawners.size; i++ )
	{
		spawners[i] thread pusher_spawn();
	}
}


//
//	Guys coming out as you jump down
platformers()
{
	level waittill( "clark_death_done" );

	autosave_by_name( "kowloon_end_run" );
	wait( 0.05 );

	// start platforming
	Objective_Set3D( level.obj_num, true );
	level notify("objective_pos_update" );	// Start heading down one level

	simple_spawn( "ai_e7_platform1", maps\kowloon_util::force_goal_self );
	trigger_wait( "trig_e7_platform1" );

	landing_rumble_on_player();

	level notify("objective_pos_update" );	// Head down another level.

	trigger_wait( "trig_e7_platform2" );

	landing_rumble_on_player();

	level notify("objective_pos_update" );	// Platforms, head to back wall
	simple_spawn( "ai_e7_platform2", maps\kowloon_util::force_goal_self );

	trigger_wait( "trig_e7_platform3" );
	level notify("objective_pos_update" );	// Platforms, near the final slide

	level thread maps\kowloon_util::kill_aigroup( "up_top_enemies" );

	//shabs - delete all force death trigs
	force_fall_death_trig = GetEntArray( "force_fall_death_trig", "targetname" );
	array_thread( force_fall_death_trig, ::self_delete );

	landing_rumble_on_player();

	trigger_wait( "trig_e7_platform4" );

	autosave_by_name( "kowloon_finale" );
	wait( 0.05 );

	level notify("objective_pos_update" );	// Bottom of the final slide

	flag_wait( "teleport_weaver" );

	//shabs - teleporting weaver down and sending him to his node when players angles are forward from the fall
	weaver_end_teleport_spot = getstruct( "weaver_end_teleport_spot", "targetname" );
	level.heroes[ "weaver" ] forceteleport( weaver_end_teleport_spot.origin, weaver_end_teleport_spot.angles );

	// Send Weaver to the bottom
	level.heroes[ "weaver" ] disable_ai_color();
	level.heroes[ "weaver" ].goalradius = 32;
	node = GetNode( "n_e7_fall", "targetname" );
//	level.heroes[ "weaver" ] SetGoalNode( node );
//	level.heroes[ "weaver" ] waittill( "goal" );

	level.heroes[ "weaver" ] thread force_goal( node, 64 );

	level.heroes[ "weaver" ] AllowedStances( "crouch" );

}

landing_rumble_on_player()
{
	//shabs - landing rumble on player
	player = get_players()[0];
	player PlayRumbleOnEntity( "damage_heavy" );
}
	
//
//	Awning tears when someone jumps through
awning_ripped()
{
	ripped_awning = GetEnt("fxanim_kowloon_awning02_mod", "targetname");
	ripped_awning hide();
	trigger_wait("trig_e7_finale");

	//blinking_ambient_civs = simple_spawn( "blinking_ambient_civs", maps\kowloon_util::delete_on_goal );
	//array_thread( blinking_ambient_civs, maps\kowloon_util::civ_timeout_death );

	non_ripped_awning = GetEnt("anim_glo_awning04b", "targetname");
	non_ripped_awning delete();
	ripped_awning show();
	
	//SOUND - Shawn J
	playsoundatposition ("evt_tear_awning", (0, 0, 0));	

	level thread set_pistol_dof();
	//blink_once();

	player = get_players()[0];
	player FreezeControls(false);

	flag_set( "player_at_ending" );

	level notify("awning02_start");
}

//blink_once()
//{
//	player = get_players()[0];
//
//	player ShellShock( "default", 1 );
//
//	//shabs - added a rumble when player hits awning
//	player PlayRumbleOnEntity( "kowloon_awning_rumble" );
//
//	overlay = newClientHudElem(player);
//	overlay.x = 0;
//	overlay.y = 0;
//	overlay setshader( "black", 640, 480 );
//	overlay.alignX = "left";
//	overlay.alignY = "top";
//	overlay.horzAlign = "fullscreen";
//	overlay.vertAlign = "fullscreen";
//	overlay.alpha = 0;
//	overlay.sort = 1;
//
//	overlay fadeOverlay( 0.01, 1, 5 );
//
//	//setting DOF for the last scene
//	near_blur = 5;
//	far_blur = 1.8;
//	near_start = 0;
//	near_end = 36;
//	far_start = 640;
//	far_end = 1680;
//
//	player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur );
//
//	wait( 0.50 );
//	overlay restoreVision( 1.5, 1.5);
//}

set_pistol_dof()
{
	//setting DOF for the last scene
	near_blur = 5;
	far_blur = 1.8;
	near_start = 0;
	near_end = 36;
	far_start = 640;
	far_end = 1680;

	player = get_players()[0];
	player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur );

	flag_wait( "e7_pistol_grabbed" );

	player maps\_art::setdefaultdepthoffield();

	//saving default DOF for the last scene
//	Default_Near_Start = 0;
//	Default_Near_End = 1;
//	Default_Far_Start = 8000;
//	Default_Far_End = 10000;
//	Default_Near_Blur = 6;
//	Default_Far_Blur = 0;
//
//	player SetDepthOfField( Default_Near_Start, Default_Near_End, Default_Far_Start, Default_Far_End, Default_Near_Blur, Default_Far_Blur );
}

fadeOverlay( duration, alpha, blur )
{
	self fadeOverTime( duration );
	self.alpha = alpha;
	get_players()[0] SetBlur( blur, duration );
	wait duration;
	get_players()[0] SetBlur( 0, duration );

}

restoreVision( duration, blur )
{
	//wait duration;
	self fadeOverlay( duration, 0, blur );
}

//
//	This is the last fall for the player at the end of the level.
//	He's crippled in prone mode and enemies storm after him.
final_fall()
{
	player			= get_players()[0];
	player_location = getstruct("e7_player_finale_location", "targetname");
	gun_location	= getstruct("cz75_location", "targetname");
	cz_gun			= GetEnt("fake_czgun", "targetname");
	fake_origin		= GetEnt("fake_czgun_origin", "targetname");
	start_location	= Getstruct("e7_player_finale_location", "targetname");

	// Need to spawn a tag_origin because the gun has an off-centered axis point.
	cz_gun_origin = spawn( "script_model", fake_origin.origin);
	cz_gun_origin.angles = fake_origin.angles;
	cz_gun_origin setmodel( "tag_origin" );

	cz_gun useweaponhidetags( "cz75_sp" );
	cz_gun linkto(cz_gun_origin);
	cz_gun Hide();

	// Added this check so people can't just jump down and land on the trigger at the bottom.
	trigger_wait( "trig_e7_platform4" );	

	ai_e7_civ_back = simple_spawn( "ai_e7_civ_back", maps\kowloon_util::delete_on_goal );
	array_thread( ai_e7_civ_back, maps\kowloon_util::civ_timeout_death );

	trigger_wait( "trig_e7_finale" );
	
	ai_e7_civ = simple_spawn( "ai_e7_civ", maps\kowloon_util::delete_on_goal );
	array_thread( ai_e7_civ, maps\kowloon_util::civ_timeout_death );

	// Stop weaver from being a killing machine now.
	level.heroes["weaver"].script_accuracy = 0.1;

	//TUEY set music state to FELL_DOWN
	setmusicstate ("FELL_DOWN");

	exploder(9001);
	flag_set( "e7_final_fall" );

	player SetClientDvar( "compass", "0" );

	player thread reach_for_pistol();

	// remove the hunters
	if ( IsDefined( level.pushers ) )
	{
		for ( i=0; i<level.pushers.size; i++ )
		{
			level.pushers[i] Delete();
		}
	}

	// Falling
	player SetBlur( 3, .5 );
	player TakeAllWeapons();

	player SetWaterDrops(50);

	fall_time = 0.5;
	linker = spawn( "script_model", player.origin);
	linker.angles = player.angles;
	linker setmodel( "tag_origin" );
	player AllowSprint( false );
  	player AllowStand( false );
  	player AllowCrouch( false );
	player AllowLean( true );
	player AllowJump( true );
	player AllowMelee( true );

//	player SetStance( "prone" );
//	wait(0.05);
	player PlayerLinkToDelta(linker, "tag_origin", fall_time, 0, 0, 0, 0);
	linker rotateto(player_location.angles, fall_time);
	linker moveto(player_location.origin, fall_time);
	
	//SOUND - Shawn J
	playsoundatposition ("evt_land_dumpster", (0, 0, 0));	

	player ShellShock("pain", 2);
	Earthquake( 0.65, 1, player.origin, 512 );
	player PlayRumbleOnEntity("kowloon_awning_rumble");

	player ShellShock("quagmire_window_break", 3);

	player FreezeControls(true);
	
	wait( fall_time );

	player startcameratween(0.5);
	player SetPlayerAngles((9.6, 4.3, 0));

	// last stand
	player Unlink();
	player FreezeControls(false);
	player SetBlur( 0, 1 );
	player SetStance( "prone" );
	PhysicsExplosionSphere( player.origin+(0,0,10), 120, 100, 1 );

	flag_set( "teleport_weaver" );

	// Spawn the gun
//	wait(1);

	flag_wait( "player_at_ending" );

	level notify("objective_pos_update" );	// Grab the gun!
	//Objective_Set3D( level.obj_num, false );

	level thread early_ending_trigs();

	cz_gun Show();
	
	//SOUND - Shawn J
//	iprintlnbold ("gun spin");
	playsoundatposition ("evt_gun_spin", (cz_gun_origin.origin));	

	cz_gun_origin rotateyaw(1150, 3.0, 0.0, 2.9 );
	cz_gun_origin moveto(gun_location.origin, 1.5, 0.0, 1.4 );

	cz_gun_origin waittill("movedone");

	rushers = simple_spawn( "e7_enemies", ::rush_player );
	for(i = 0 ; i < rushers.size; i++)
	{
		rushers[i].disableIdleStrafing = 1;
	}
	victims = simple_spawn( "e7_enemies_victims", ::victim_setup );
	flag_set( "e7_enable_pistol" );
	level thread wait_for_pistol_grabbed( victims, rushers );
	level thread van_entrance_timeout(); //need this to have van guys come out if player doesnt pick up pistol

//	flag_wait( "e7_pistol_grabbed" );
//
//	victims thread maps\kowloon_anim::start_spetsnaz_van_crash();
//
//	level thread timescale_tween( 1.0, 0.5, 1.0 );
//	maps\kowloon_util::slowdown_wait( undefined, "e7_van_crash", undefined );
//
//	level timescale_tween( GetTimeScale(), 1.0, 1.0 );
//
//	level waittill("kill_rest");
//	wait(1.0);
//
//	for ( i=0; i<rushers.size; i++ )
//	{
//	    if ( IsAlive( rushers[i] ) )
//		{
//			rushers[i] DoDamage( rushers[i].health, level.sgt_2.origin );
//			wait( RandomFloatRange( 0.2, 0.3 ) );
//		}
//	}
//	//
//	ai = GetAiArray( "axis", "allies" );
//	for ( i=0; i<ai.size; i++ )
//	{
//		ai[i].ignoreall = 1;
//	}
//
//	// Return to normal
//	player SetStance( "stand" );
//	player AllowStand( true );
//	player AllowCrouch( true );
//	player AllowSprint( true );
//
//	node = GetNode( "n_e7_end", "targetname" );
//	level.heroes[ "weaver" ] SetGoalNode( node );
//	level.heroes[ "weaver" ].ignoreall = 1;
//
//	//shabs - deleting pre-placed player clip so player can now move around
//	finale_player_clip = GetEnt( "finale_player_clip", "targetname" );
//	finale_player_clip Delete();
//
//	van = GetEnt( "van", "targetname" );
//	end_struct = getstruct( "auto222", "targetname" );
//
////	player_enter_van_trig = Spawn( "trigger_radius", end_struct.origin, 0, 128, 250 );
////	player_enter_van_trig waittill_notify_or_timeout( "trigger", 500 );
//
//	//shabs - spawns player van enter trig
//	flag_set( "van_waiting" );
//
//	array_notify( level.van_guys, "start_player_van" );

//	level notify("objective_pos_update" );	// Get to the van
//	wait(5);
//
//	level notify( "closing_dialog" );
//	wait(1);
//
//	level maps\kowloon_util::fade_out(2);
//	wait(2);
//
//	nextmission();
}

van_entrance_timeout()
{
	level endon( "kill_timeout" );
	wait( 5 );
	flag_set( "e7_pistol_grabbed" );
}

wait_for_pistol_grabbed( victims, rushers )
{
	flag_wait( "e7_pistol_grabbed" );
	level notify( "kill_timeout" );

	victims thread maps\kowloon_anim::start_spetsnaz_van_crash();

	level thread timescale_tween( 1.0, 0.5, 1.0 );
	maps\kowloon_util::slowdown_wait( undefined, "e7_van_crash", undefined );

	level timescale_tween( GetTimeScale(), 1.0, 1.0 );

	level waittill("kill_rest");
	wait(1.0);

	for ( i=0; i<rushers.size; i++ )
	{
	    if ( IsAlive( rushers[i] ) )
		{
			rushers[i] DoDamage( rushers[i].health, level.sgt_2.origin );
			wait( RandomFloatRange( 0.2, 0.3 ) );
		}
	}
	//
	ai = GetAiArray( "axis", "allies" );
	for ( i=0; i<ai.size; i++ )
	{
		ai[i].ignoreall = 1;
	}

	node = GetNode( "n_e7_end", "targetname" );
	level.heroes[ "weaver" ] SetGoalNode( node );
	level.heroes[ "weaver" ].ignoreall = 1;

	van = GetEnt( "van", "targetname" );
	level thread van_audio();
	end_struct = getstruct( "auto222", "targetname" );

//	player_enter_van_trig = Spawn( "trigger_radius", end_struct.origin, 0, 128, 250 );
//	player_enter_van_trig waittill_notify_or_timeout( "trigger", 500 );

	//shabs - spawns player van enter trig
	flag_set( "van_waiting" );

	array_notify( level.van_guys, "start_player_van" );

	player = get_players()[0];

	player SetWaterDrops(50);
	wait( 4 );
	level thread ending_vo();

	level notify("objective_pos_update" );	// Get to the van

	player SetWaterDrops(50);

	player SetMoveSpeedScale( 0.5 );
	player setlowready(true);

	// Return to normal
	player SetStance( "stand" );
	player AllowStand( true );
	player AllowCrouch( true );
	player AllowSprint( true );

	//shabs - deleting pre-placed player clip so player can now move around
	finale_player_clip = GetEnt( "finale_player_clip", "targetname" );
	finale_player_clip Delete();


//	player_next_to_van = true;
//	while( player_next_to_van )
//	{
//		if( DistanceSquared( player.origin, van_crash_sync.origin ) < 256 * 256 )
//		{
//			player anim_single(player, "where_we_headed", "sgt");
//			wait( 0.2 );
//		
//			player anim_single(player, "yamantau");
//
//			player_next_to_van = false;
//		}
//		wait( 0.05 );
//	}
}

ending_vo()
{
	level endon( "started_timeout_ending" );
	level endon("started_player_van_ending");
	
	van_crash_sync = getstruct( "van_crash_sync", "targetname" );

	player = get_players()[0];

	player_next_to_van = true;
	while( player_next_to_van )
	{
		if( DistanceSquared( player.origin, van_crash_sync.origin ) < 256 * 256 )
		{
			if (!level.end_vo)
			{
				player anim_single(player, "where_we_headed", "sgt");
			
				level.end_vo = true;
			
				wait( 0.2 );
		
				player anim_single(player, "yamantau");
				player_next_to_van = false;
			
				break;
			}
		}
		wait( 0.05 );
	}
}

van_audio()
{
	player = get_players()[0];
	van_struct = getstruct( "auto222", "targetname" );
	sound_ent = Spawn( "script_origin", van_struct.origin );
	sound_ent playloopsound( "amb_rain_on_van_ext" , 1 );
	level waittill( "started_player_van_ending" );
	wait 2;
	sound_ent stoploopsound(1);
	player playloopsound( "amb_rain_on_van_intf" , 1 );
	clientnotify( "plr_van" );
	//iprintlnbold ("plr van");
	wait (1.7);
	player playsound( "evt_van_door_close" );
	wait (1.3);
	clientnotify( "van_door_close" );
	
	//iprintlnbold ("van door");
	
}

early_ending_trigs()
{
	level endon( "started_player_van_ending" );
//	level endon( "started_timeout_ending" );

	trigger_wait( "trig_end" );

	player = get_players()[0];
	player FreezeControls( true );
	
	array_notify( level.van_guys, "start_player_van" );

	Objective_Set3D( level.obj_num, false );
	//level notify("objective_pos_update" );	// Get to the van

	level notify( "closing_dialog" );
	flag_set("started_timeout_ending");

	if (!level.end_vo)
	{
		player anim_single(player, "where_we_headed", "sgt");
		level.end_vo = true;
		wait( 0.2 );
		player thread anim_single(player, "yamantau");
	}

	level maps\kowloon_util::fade_out(2.5);
	wait( 8.7 );

	nextmission();

}

//
//	Pistol use trigger
reach_for_pistol()
{
	trig = GetEnt( "trig_e7_pistol", "targetname" );
	trig SetHintString( &"KOWLOON_E7_PISTOL" );
	trig trigger_off();

	flag_wait( "e7_enable_pistol" );

	trig trigger_on();
	trig SetCursorHint( "HINT_NOICON" ); //shabs - get rid of old hand icon
	trig waittill( "trigger" );

	self GiveWeapon( "cz75_sp" );
	self SwitchToWeapon( "cz75_sp" );
	cz_gun = GetEnt("fake_czgun", "targetname");
	cz_gun Delete();

	trig Delete();
	flag_set( "e7_pistol_grabbed" );
}


//
//
rush_player()
{
	self endon( "death" );

	self.pacifist = 1;
// 	self enable_cqbwalk();
//	self thread force_goal();
	self thread maps\kowloon_util::force_goal_self();
	self.script_accuracy = 0.5;
	wait(3);

	self.pacifist = 0;
//	self maps\_rusher::rush();
}

victim_setup()
{
	self endon( "death" );

	self.goalradius = 16;
	self disable_pain();
// 	self enable_cqbwalk();
//	self thread force_goal();
	self thread maps\kowloon_util::force_goal_self();

	self.script_accuracy = 0;
	self waittill("goal");

	self.pacifist = 0;
}


//
//
platform_dialog()
{
	player = get_players()[0];

	flag_wait( "e7_clark_jump" );

	// Clark jumps
	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "Raarhhh");
	wait( 0.5 );

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "i_m_slipping");
	level waittill("clark_death_done");

	// start platforming
	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "Red_eye");

	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "immediate_distract");

	sgt = simple_spawn_single("ally_sgt_3");
	sgt.animname = "sgt";	

	sgt anim_single(sgt, "on_our_way");

	sgt anim_single(sgt, "watching_firework");

	sgt delete();

	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "clark_dead");
	wait( 0.2 );

	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "red_out");
	wait( 0.2 );

	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "I_see_way_down");
	wait( 0.2 );

	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "This_way");
	level waittill( "closing_dialog" );

//	player anim_single(player, "where_we_headed", "sgt");
//	wait( 0.2 );
//
//	player anim_single(player, "yamantau");
}