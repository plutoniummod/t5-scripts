/*
//-- Level: Underwater Base
//-- Level Designer: Gavin Goslin
//-- Scripter: Alfeche/Vento
*/

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\_anim; // Be sure to include this for _anim calls.
#include maps\underwaterbase_util;

// ~~~ The start of everything ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// From here, script will fundamentally switch to either the P1 or P2 player path, depending on which
// version of the level the player is visiting.  We'll be leaning on the level skipto system to accomplish
// this, so there's a standalone skipto even for event1 of both versions, as there will /always/ be cleanup to do
main()
{	
	
	// toggle the use of drones
	level.toggle_drones = false;
	
	init_precache();
	init_flags();
	init_dvars();	
	init_starts();
	init_func_pointers();
	init_constants();

	// setup character models
	setup_characters();
	
	// init for TOW mounted launcher
	maps\_tvguidedmissile::init();
	
	// if CreateFX is running, delete the water volume
	if( GetDvar( #"createfx" ) != "" )
	{
		level.water_volume = GetEnt( "underwaterbase_water_volume", "targetname" );
		level.water_volume Delete();
	}
	
	maps\underwaterbase_fx::main();

	maps\_load::main();

	//turn trigger damages off by default so we don't break progression
	init_triggers();

	init_level_variables();

	setup_spawn_functions();
	enable_random_alt_weapon_drops();
	
	maps\_rusher::init_rusher();

	// drones setup	
	if(level.toggle_drones)
	{
		maps\underwaterbase_drones::init_drones();
	}

	maps\underwaterbase_amb::main();
	maps\underwaterbase_anim::main();

	// remove LMG anims
	level thread remove_lmg_anims();
	level thread start_level();
}

start_level()
{
	// spawn heroes
	setup_heroes();
	
	// make sure every player is in
	wait_for_first_player();
	flag_wait( "all_players_connected" );

	player = get_players()[0];
	player.animname = "mason";

	// damage override
	level.default_damage_func = player.overridePlayerDamage;

	// open up bridge blocker
	blocker = GetEnt("bridge_player_blocker", "targetname");
	blocker rotateyaw(-150, 1);
	blocker connectpaths();	

	// Hide the texture used for the Dragovich fight
	water_texture = GetEnt( "dragovich_water_texture", "targetname" );
	water_texture trigger_off();

	// First instance of swimming is going to be in the dive section
// 	level maps\_swimming::set_default_vision_set( "UWB_MoonPool" );
// 	level maps\_swimming::set_swimming_vision_set( "UWB_Dive" );

 	//player SetClientDvar( "player_disableWeaponsInWater", 0 );
 	
 	player SetThreatBiasGroup("player");
	SetThreatBias("player", "player_hater", 999999);
	SetThreatBias("player_hater", "player", 999999);

//	SetThreatBias("good_guys", "bad_guys", 999999);
//	SetThreatBias("bad_guys", "good_guys", 999999);

//	SetThreatBias("support_huey", "rpg_guys", 999999);

//	SetIgnoreMeGroup("player", "bad_guys");
//	SetIgnoreMeGroup("good_guys", "player_hater");
//	SetIgnoreMeGroup("player", "rpg_guys");
//	SetIgnoreMeGroup("good_guys", "rpg_guys");
	
	//player thread maps\_tvguidedmissile::watchForGuidedMissileFire();

	// _swimming.csc has got some extra waits in it, so we have to wait ourselves 
	wait( 0.5 );
	player enable_swimming();
}

// ~~~ Precache any special items/weapons/etc ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
init_precache()
{
	// HUD icons
	precacheshader("hud_hind_minigun");
	precacheshader("hud_hind_rocket");
	precacheShader("cinematic");
	
	// special weapons
	precacherumble( "damage_light" );		// rumble
	precacherumble( "damage_heavy" );		// rumble

	PreCacheShellShock("explosion");
	PrecacheModel("p_glo_bullet_tip");		// bullet slo mo
	PreCacheModel("t5_weapon_strela_obj");	// tow shader model
	PreCacheModel("t5_veh_helo_hind_cockpit_control");
	PreCacheModel("t5_veh_helo_huey_damaged_low");
	PreCacheModel("t5_veh_helo_huey_att_interior");
	PreCacheModel("t5_veh_helo_huey_att_uwb_dmg_blood");
	PreCacheModel("t5_veh_helo_huey_att_uwb_dmg_dials");
	PreCacheModel("t5_veh_helo_huey_att_uwb_dmg_glass");
	PreCacheModel("t5_veh_helo_huey_att_uwb_dmg_scorch");
	PreCacheModel("vehicle_ch46e");
	PreCacheModel("t5_veh_jet_f4_gearup");
	PreCacheModel("t5_veh_helo_huey_damaged_door_front");
	PreCacheModel("t5_veh_helo_huey_damaged_rotor_tip");
	PreCacheModel("t5_veh_helo_huey_damaged_rotor");

	// Precache weapons
	// Sidearms
	PrecacheItem( "cz75_sp" );
	PrecacheItem( "cz75_auto_sp" );
	PrecacheItem( "cz75dw_sp" );
	PrecacheItem( "cz75dw_auto_sp" );

	// SMG
	PrecacheItem( "mac11_sp" );
	PrecacheItem( "mac11_elbit_sp" );
	PrecacheItem( "mac11dw_sp" );
	PrecacheItem( "mac11_extclip_sp" );
	PrecacheItem( "mac11_elbit_extclip_sp" );	// dual attachment

	PrecacheItem( "ak74u_acog_sp" );
	PrecacheItem( "ak74u_dualclip_sp" );
	PrecacheItem( "ak74u_gl_sp" );
	PrecacheItem( "ak74u_reflex_sp" );
	PrecacheItem( "ak74u_extclip_sp" );
 	PrecacheItem( "ak74u_acog_extclip_sp" );	// dual attachment
 	PrecacheItem( "ak74u_reflex_gl_sp" );		// dual attachment

	//	Shotgun

	//	Assault
	PrecacheItem( "galil_sp" );
	PrecacheItem( "galil_acog_sp" );
	PrecacheItem( "galil_dualclip_sp" );
	PrecacheItem( "galil_extclip_sp" );
	PrecacheItem( "galil_gl_sp" );
	PrecacheItem( "galil_ir_sp" );
	PrecacheItem( "galil_mk_sp" );
	PrecacheItem( "galil_reflex_sp" );
	PrecacheItem( "galil_ir_dualclip_sp" );	// dual attachment
	PrecacheItem( "galil_acog_gl_sp" );		// dual attachment

	PrecacheItem( "famas_sp" );
	PrecacheItem( "mk_famas_sp" );
	PrecacheItem( "gl_famas_sp" );
	PrecacheItem( "famas_reflex_sp" );
	PrecacheItem( "famas_gl_sp" );
	PrecacheItem( "famas_mk_sp" );
	PrecacheItem( "famas_dualclip_sp" );
	PrecacheItem( "famas_acog_sp" );
	PrecacheItem( "famas_reflex_mk_sp" );		// dual attachment
	PrecacheItem( "famas_reflex_gl_sp" );		// dual attachment
	PrecacheItem( "famas_reflex_dualclip_sp" );	// dual attachment

	//	LMG
	PrecacheItem( "stoner63_sp" );
	PrecacheItem( "stoner63_acog_sp" );
	PrecacheItem( "stoner63_extclip_sp" );
	PrecacheItem( "stoner63_reflex_sp" );
	PrecacheItem( "stoner63_ir_sp" );
	PrecacheItem( "stoner63_reflex_extclip_sp" );	// dual attachment

	PrecacheItem( "rpk_sp" );
	PrecacheItem( "rpk_acog_sp" );
	PrecacheItem( "rpk_dualclip_sp" );
	PrecacheItem( "rpk_extclip_sp" );
	PrecacheItem( "rpk_ir_sp" );
	PrecacheItem( "rpk_reflex_sp" );
	PrecacheItem( "rpk_acog_extclip_sp" );		// dual attachment
	PrecacheItem( "rpk_reflex_extclip_sp" );	// dual attachment

	// Launchers
	PrecacheItem( "rpg_sp" );
	PreCacheItem( "uwb_m220_tow_sp" );

	// Vehicle Weapons
	PreCacheItem("huey_rockets_uwb");
	PreCacheItem("hind_rockets_sp_uwb");
	PreCacheItem("hind_rockets_sp_player_uwb");

	PreCacheItem("sam_uwb_sp");

	// Dive Mask
	PreCacheItem("divemask_sp");

	// for the finale...precache models
	maps\underwaterbase_thesurface::setup_floating_debris_types();
}

// ~~~ Creates the valid start point shortcuts ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
init_starts()
{	
	add_start( "e11_thesurface",		maps\underwaterbase_thesurface::run_skipto,	&"UNDERWATERBASE_SKIPTO_SURFACE" );	 
	add_start( "e10_escape",			maps\underwaterbase_escape::run_skipto,		&"UNDERWATERBASE_SKIPTO_ESCAPE" );	 
	add_start( "e9_dragovichfight",		maps\underwaterbase_deactivatecode::run_skipto, &"UNDERWATERBASE_SKIPTO_DEACTIVATECODE" );	 	
	add_start( "e8_broadcastcenter",	maps\underwaterbase_broadcastcenter::run_skipto, &"UNDERWATERBASE_SKIPTO_BROADCASTCENTER" );	 
	add_start( "e7_upshaft",			maps\underwaterbase_upshaft::run_skipto,	&"UNDERWATERBASE_SKIPTO_UPSHAFT" );	 
	add_start( "e6_bigflood",			maps\underwaterbase_bigflood::run_skipto,	&"UNDERWATERBASE_SKIPTO_BIGFLOOD" );	 
	add_start( "e5_enterbase",			maps\underwaterbase_enterbase::run_skipto,	&"UNDERWATERBASE_SKIPTO_ENTERBASE" );	 
	add_start( "e4_divetobase",			maps\underwaterbase_divetobase::run_skipto, &"UNDERWATERBASE_SKIPTO_DIVETOBASE" );
	add_start( "e3_bigigc",				maps\underwaterbase_bigigc::run_skipto,		&"UNDERWATERBASE_SKIPTO_BIGIGC" ); 
	add_start( "e2_rendezvous",			maps\underwaterbase_rendezvous::run_skipto, &"UNDERWATERBASE_SKIPTO_RENDEZVOUS" ); 
	add_start( "e1a_snipe",				maps\underwaterbase_snipe::run_skipto,		&"UNDERWATERBASE_SKIPTO_SNIPE" ); 
	add_start( "e1_airsupport",			maps\underwaterbase_airsupport::run_skipto, &"UNDERWATERBASE_SKIPTO_AIRSUPPORT" );
// 	add_start( "introigc", maps\underwaterbase_introigc::run_skipto, "E1: Intro IGC" ); 

	default_start( maps\underwaterbase_introigc::run_skipto, true );	

	
}

// ~~~ Sets up level flags ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
init_flags()
{
	flag_init( "deck_cleanup" );
	flag_init( "dive_cleanup" );
	flag_init( "base_cleanup" );

	maps\underwaterbase_util::init_util_flags();

	maps\underwaterbase_introigc::init_flags();
}

init_dvars()
{
	SetPhysicsGravityDir( (0,0,-800) );
	SetSavedDvar( "sm_sunAlwaysCastsShadow", 1 );
// 	SetSavedDvar( "phys_buoyancy", 0 );
// 	SetSavedDvar( "phys_ragdoll_buoyancy", 0 );
}


init_func_pointers()
{
	if(level.toggle_drones)
	{
		level.heli_attack_drone_targets_func = maps\underwaterbase_huey::heli_attack_drone_targets;
	}

	// for congrats lines while in the helicopter
	level.overrideActorKilled = ::actor_killed_override;
}

init_constants()
{
	level.huey_fov = 75;
	level.huey_zoom_fov = 40;
	level.default_fov = GetDvarFloat( #"cg_fov" );
}

init_triggers()
{
//	trigger_off( "trig_in_landing_zone", "targetname");	
//	trigger_off( "bridge_missile_trigger", "targetname");
//	trigger_off( "spawn_hinds", "targetname" );
	trigger_off( "huey_landing_pad_trigger","targetname" );
	
	// checkpoint triggers
//	trigger_off( "mid_ship_checkpoint_trigger", "targetname");
//	trigger_off( "interior_ship_checkpoint_trigger", "targetname");
	
	// airsupport blockers
//	array_thread( GetEntArray("rpg_containment_clip","targetname"), ::turn_on_containment_clips );
//	array_thread( GetEntArray("mid_port_containment_clip","targetname"), ::turn_on_containment_clips );
//	array_thread( GetEntArray("bow_containment_clip","targetname"), ::turn_on_containment_clips );
//	array_thread( GetEntArray("front_bow_containment_clip","targetname"), ::turn_off_containment_clips );
}

init_level_variables()
{
	level.curr_obj_num = 0;
	level.support_troops_count = 0;

	init_water_volume();

	level.callbackVehicleDamage = ::underwaterbase_vehicle_damage;

	// get start water plane
	level.water_planes = [];
	level.water_planes["ship_exterior"] = GetEnt("ocean_surface_01", "targetname");
	level.water_planes["ship_exterior"] SetForceNoCull();

	level.heli_kill_streak = 0;
	level.heli_streak_encourage_kills = 3;
	level.heli_streak_max_kills = 6;
	level.heli_streak_max_time = 6;
	level.heli_kill_streak_time_stamp = 0;

	level.heli_restore_spot = "";

	// override rank function
	level._override_rank_func = ::uwb_override_rank_func;
}


//
//
init_water_volume( targetname )
{
	level.water_texture = GetEnt( "underwaterbase_water_texture", "targetname" );
	level.water_volume	= GetEnt( "underwaterbase_water_volume", "targetname" );

	// activate underwater base water volume
  	SetWaterBrush( level.water_volume );	

    // attach water texture to dynamic volume
	level.water_texture.origin = level.water_volume.origin;// offset to match water volume and texture
	level.water_texture linkto(level.water_volume);
	level.water_texture Hide();

	if ( IsDefined( targetname ) )
	{
		set_water_height( targetname );
	}
}


setup_heroes()
{
	level.heroes = [];
	
	setup_hero( "hudson", "Hudson", "hudson" );
	setup_hero( "weaver", "Weaver", "weaver" );
}

setup_hero( targetname, vis_name, name )
{
	level.heroes[ name ] = simple_spawn_single( targetname );
	level.heroes[ name ].animname = name;
	level.heroes[ name ].name = vis_name;
	level.heroes[ name ] make_hero();
}

setup_characters()
{
	character\c_usa_huey_pilot_1::precache();
	character\c_usa_ubase_divegear::precache();

	// setup an array of characters...each array entry is a function pointer to the main for that character
	level.character["pilot"] = character\c_usa_huey_pilot_1::main;
	level.character["hudson"] = character\c_usa_ubase_hudson_combat::main;
	level.character["redshirt"] = character\c_usa_ubase_combat::main;
	level.character["redshirt_diver"] = character\c_usa_ubase_divegear::main;
	level.character["weaver"] = character\c_usa_ubase_weaver::main;
}

setup_spawn_functions()
{
 	CreateThreatBiasGroup("good_guys");
 	CreateThreatBiasGroup("bad_guys");
 	CreateThreatBiasGroup("player_hater");
 	CreateThreatBiasGroup("player");
 	CreateThreatBiasGroup("rpg_guys");
 	CreateThreatBiasGroup("support_huey");
 	
	weaver_riders = GetEntArray("airsupport_weaver_riders", "script_noteworthy");
	array_thread(weaver_riders, ::add_spawn_function, maps\underwaterbase_airsupport::huey_riders_think);

	support_riders = GetEntArray("airsupport_support_riders", "script_noteworthy");
	array_thread(support_riders, ::add_spawn_function, maps\underwaterbase_airsupport::huey_riders_think);

	support_rpg_guys = GetEntArray("airsupport_mid_rpg_guys", "script_noteworthy");
	array_thread(support_rpg_guys, ::add_spawn_function, maps\underwaterbase_airsupport::mid_rpg_guys_spawnfunc);

	deck_enemies_a = GetEntArray("airsupport_mid_enemies_a", "script_noteworthy");
	array_thread(deck_enemies_a, ::add_spawn_function, maps\underwaterbase_airsupport::deck_enemies_spawnfunc);

	deck_enemies_b = GetEntArray("airsupport_mid_enemies_b", "script_noteworthy");
	array_thread(deck_enemies_b, ::add_spawn_function, maps\underwaterbase_airsupport::deck_enemies_spawnfunc);

	deck_enemies_c = GetEntArray("airsupport_mid_enemies_c", "script_noteworthy");
	array_thread(deck_enemies_c, ::add_spawn_function, maps\underwaterbase_airsupport::deck_enemies_spawnfunc);

	deck_enemies_d = GetEntArray("airsupport_mid_enemies_d", "script_noteworthy");
	array_thread(deck_enemies_d, ::add_spawn_function, maps\underwaterbase_airsupport::deck_enemies_spawnfunc);

	rendezvous_rpg_guys = GetEntArray("rendezvous_rpg_guys", "script_noteworthy");
	array_thread(rendezvous_rpg_guys, ::add_spawn_function, maps\underwaterbase_rendezvous::rpg_guys_spawnfunc);

	stern_enemies_a = GetEntArray("airsupport_stern_enemies_a", "script_noteworthy");
	array_thread(stern_enemies_a, ::add_spawn_function, maps\underwaterbase_airsupport::shoot_at_player);

	stern_enemies_c = GetEntArray("airsupport_stern_enemies_c", "script_noteworthy");
	array_thread(stern_enemies_c, ::add_spawn_function, maps\underwaterbase_airsupport::shoot_at_player);

	bow_resistance = GetEntArray("resistance_bow_guys", "targetname");
	array_thread(bow_resistance, ::add_spawn_function, maps\underwaterbase_introigc::resistance_guy_kill_me, "aa_gun_heavy_resistance_cleared_bow");

	mid_resistance = GetEntArray("resistance_mid_guys", "targetname");
	array_thread(mid_resistance, ::add_spawn_function, maps\underwaterbase_introigc::resistance_guy_kill_me, "aa_gun_heavy_resistance_cleared_mid");
}

actor_killed_override(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime)
{
	if (IsPlayer(attacker))
	{
		// If this is the players first kill
		if (level.heli_kill_streak == 0)
		{
			level.heli_kill_streak++;
			level.heli_kill_streak_time_stamp = GetTime();
		}
		else 
		{
			// get the current time
			new_time = GetTime();

			// calculate time since last kill
			dt = (new_time - level.heli_kill_streak_time_stamp) / 1000;

			// if we're still within the time range
			if (dt < level.heli_streak_max_time)
			{
				// save before we increment
				prev_heli_kill_streak = level.heli_kill_streak;

				// count it!
				level.heli_kill_streak++;

				// check to see if we hit the max
				if (level.heli_kill_streak >= level.heli_streak_max_kills)
				{
					// send notify
					level notify("heli_kill_streak");
					//IPrintLnBold("kill streak");

					// reset the streak
					level.heli_kill_streak = 0;
				}
				else if (level.heli_kill_streak >= level.heli_streak_encourage_kills && prev_heli_kill_streak < level.heli_streak_encourage_kills)
				{
					// player is almost there...give him some encouragement
					level notify("heli_encourage_kill_streak");
				}
			}
			else
			{
				// kill happened out of time range so restart the streak
				level.heli_kill_streak = 1;
				level.heli_kill_streak_time_stamp = GetTime();
			}

			//IPrintLn("Streak: " + level.heli_kill_streak + " Time: " + dt);
		}
	}

	if ( IsDefined( self.actor_killed_override ) )
	{
		self [[ self.actor_killed_override ]]( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime );
	}
}


//
//	The base is being hit from torpedos
base_impacts( initial_state, initial_delay )
{
	level endon( "stop_base_impacts" );

	player = get_players()[0];
	level.explosion_state = "wait";

	if ( IsDefined( initial_state ) )
	{
		set_base_impact_state( initial_state, initial_delay );
	}

	while ( 1 )
	{
		level notify( "base_impact" );
		switch ( level.impact_state )
		{
		case "occasional":
			Earthquake( RandomFloatRange(0.25, 0.5) , 0.5, player.origin, 500 );
			playsoundatposition( "evt_uwb_explosion", (0,0,0) );
			player PlayRumbleOnEntity( "damage_light" );
			wait( RandomIntRange( 10, 20 ) );
			break;
		case "medium":
			Earthquake( RandomFloatRange(0.25, 0.75) , 2.0, player.origin, 500 );
			playsoundatposition( "evt_uwb_explosion", (0,0,0) );
			player PlayRumbleOnEntity( "grenade_rumble" );
			wait( RandomIntRange( 5, 15 ) );
			break;
		case "high":
			Earthquake( RandomFloatRange(0.5, 0.75) , 1.0, player.origin, 500 );
			playsoundatposition( "evt_uwb_explosion", (0,0,0) );
			//clientnotify( "exsnp" );
			player PlayRumbleOnEntity( "artillery_rumble" );
			wait( RandomIntRange( 3, 5 ) );
			break;
		case "wait":
		default:
			wait( 0.5 );
			break;
		}
	}
}


//
// change states for the base_impacts.  Optionally add a delay value before proceeding
set_base_impact_state( state, delay )
{
	if ( !IsDefined( delay ) )
	{
		delay = RandomIntRange( 2, 5 );
	}
	wait( delay );

	level.impact_state = state;
}


//
//	Removes LMG anims to save memory
remove_lmg_anims()
{
    wait_for_first_player();
    
    // KIDS, DON?T TRY THIS AT HOME
    anim.anim_array["default"]["move"]["stand"]["mg"] = undefined;
    anim.pre_move_delta_array["default"]["move"]["stand"]["mg"] = undefined;
    anim.move_delta_array["default"]["move"]["stand"]["mg"] = undefined;
    anim.post_move_delta_array["default"]["move"]["stand"]["mg"] = undefined;
    anim.angle_delta_array["default"]["move"]["stand"]["mg"] = undefined;           
}

uwb_override_rank_func(lastname)
{
	rank = RandomInt( 100 ); 
	if( rank > 50 )
	{
		fullname = "Cpl. " + lastname; 
		self.airank = "corporal"; 
	}
	else
	{
		fullname = "Sgt. " + lastname; 
		self.airank = "sergeant"; 
	}

	self.name = fullname;
}
