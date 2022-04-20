#include maps\mp\_utility;
#include common_scripts\utility;

main()
{
	precachemodel( "p_stk_rolldoor_switch_on_red" );
	PrecacheString( &"MP_OPERATE_DOOR" );
	
	//needs to be first for create fx
	maps\mp\mp_outskirts_fx::main();

	maps\mp\_load::main();

	/#
		level thread devgui_outskirts();
		execdevgui( "devgui_mp_outskirts" );
	#/

	maps\mp\mp_outskirts_amb::main();

//	maps\mp\_compass::setupMiniMap("compass_map_mp_stockpile"); 
	if ( GetDvarInt( #"xblive_wagermatch" ) == 1 )
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_stockpile_wager");
	}
	else
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_stockpile");
	}	

	// If the team nationalites change in this file, you must also update the level's csc file,
	// the level's csv file, and the share/raw/mp/mapsTable.csv
	maps\mp\gametypes\_teamset_winterspecops::level_init();

	// Set up the default range of the compass
	setdvar("compassmaxrange","2100");

	// Set up some generic War Flag Names.
	// Example from COD5: CALLSIGN_SEELOW_A is the name of the 1st flag in Selow whose string is "Cottage" 
	// The string must have MPUI_CALLSIGN_ and _A. Replace Mapname with the name of your map/bsp and in the 
	// actual string enter a keyword that names the location (Roundhouse, Missle Silo, Launchpad, Guard Tower, etc)

	game["strings"]["war_callsign_a"] = &"MPUI_CALLSIGN_MAPNAME_A";
	game["strings"]["war_callsign_b"] = &"MPUI_CALLSIGN_MAPNAME_B";
	game["strings"]["war_callsign_c"] = &"MPUI_CALLSIGN_MAPNAME_C";
	game["strings"]["war_callsign_d"] = &"MPUI_CALLSIGN_MAPNAME_D";
	game["strings"]["war_callsign_e"] = &"MPUI_CALLSIGN_MAPNAME_E";

	game["strings_menu"]["war_callsign_a"] = "@MPUI_CALLSIGN_MAPNAME_A";
	game["strings_menu"]["war_callsign_b"] = "@MPUI_CALLSIGN_MAPNAME_B";
	game["strings_menu"]["war_callsign_c"] = "@MPUI_CALLSIGN_MAPNAME_C";
	game["strings_menu"]["war_callsign_d"] = "@MPUI_CALLSIGN_MAPNAME_D";
	game["strings_menu"]["war_callsign_e"] = "@MPUI_CALLSIGN_MAPNAME_E";

	// enable new spawning system
	maps\mp\gametypes\_spawning::level_use_unified_spawning(true);

	door_system_init();
}

door_system_init()
{
	level.const_door_move_time = 4;
	level.const_door_move_dist = 96;
	level.const_door_accel_time = .6;
	level.const_door_decel_time = .6;
	level.const_door_cooldown_time = 3;

	doors = GetEntArray( "moving_door", "targetname" );

	array_func( doors, ::door_init );
	array_thread( doors, ::door_think ); 
}

//Self is the moving door
door_init()
{
	//This number should be unique to the moving door and each thing associated with it
	door_number = self.script_int;

	// visuals
	self OverrideLightingOrigin();
	self.switch_models = GetEntArray( "switch_model" + door_number, "targetname" );

	self.fx_green = undefined;
	self.fx_red = undefined;

	if ( IsDefined( self.script_noteworthy ) )
	{
		exploders = StrTok( self.script_noteworthy, " " );
		assert( IsDefined( exploders ) );

		self.fx_green = exploders[0];
		self.fx_red	= exploders[1];
		self.fx_dust = exploders[2];
	}

	// sound
	self.sound_emitter = GetStruct( "door_sound_emitter" + door_number, "targetname" );

	// triggers
	self.kill_trigger = GetEnt( "door_kill_trig" + door_number, "targetname" );
	self.kill_trigger EnableLinkTo();
	self.kill_trigger LinkTo( self );

	self.use_triggers = GetEntArray( "moving_door_trig" + door_number, "targetname" );
	array_thread( self.use_triggers, ::trigger_prox_think );

	// player clip
	self.clip = GetEnt( "moving_door_clip" + door_number, "targetname" );
	self.clip LinkTo( self );
}

//Self is the moving door
door_think()
{
	level waittill( "prematch_over" );

	open = true;
	self door_fx_exploder( self.fx_green );
	
	while( 1 )
	{
		//This waittill_any sets it up so up to 7 switches can be associated with a specific door
		level waittill_any_ents ( self.use_triggers[0], "trigger", 
								  self.use_triggers[1], "trigger", 
								  self.use_triggers[2], "trigger",
								  self.use_triggers[3], "trigger", 
								  self.use_triggers[4], "trigger", 
								  self.use_triggers[5], "trigger", 
								  self.use_triggers[6], "trigger" );

		array_func( self.use_triggers, ::trigger_off );
		array_func( self.switch_models, ::door_set_switch_model, "p_stk_rolldoor_switch_on_red" );

		self door_fx_exploder( self.fx_red );
		
		if( open )
		{
			target_origin = ( self.origin[0], self.origin[1], self.origin[2] - level.const_door_move_dist );
		}
		else
		{
			target_origin = ( self.origin[0], self.origin[1], self.origin[2] + level.const_door_move_dist );
		}

		PlaySoundAtPosition( "evt_garage_buzzer", self.sound_emitter.origin );
		PlaySoundAtPosition( "evt_door_start", self.sound_emitter.origin );
		self PlayLoopSound( "evt_door_move" );

		self.clip destroy_corpses();

		self door_move( target_origin, open );

		self StopLoopSound();
		PlaySoundAtPosition( "evt_door_stop", self.sound_emitter.origin );

		open = !open;

		wait( level.const_door_cooldown_time / 2 );
		self.clip destroy_corpses();

		wait( level.const_door_cooldown_time / 2 );
		self.clip destroy_corpses();

		array_func( self.use_triggers, ::trigger_on );
		array_func( self.switch_models, ::door_set_switch_model, "p_stk_rolldoor_switch_on_green" );
		
		for( i = 0; i < self.use_triggers.size; i++ )
		{
			if( IsDefined( self.use_triggers[i] ) )
			{
				PlaySoundAtPosition( "evt_door_ready", self.use_triggers[i].origin );
			}
		}

		self door_fx_exploder( self.fx_green );
	}
}

// self = the door
door_fx_exploder( exploder_num )
{
	if ( !IsDefined( self.fx_green ) )
	{
		return;
	}

	if ( !IsDefined( self.fx_red ) )
	{
		return;
	}

	if ( exploder_num == self.fx_green )
	{
		exploder_stop( self.fx_red );
		exploder( self.fx_green );
	}
	else
	{
		exploder_stop( self.fx_green );
		exploder( self.fx_red );
	}
}

// self = switch model
door_set_switch_model( model )
{
	self SetModel( model );
}

// self = the door
door_move( origin, crush )
{
	self MoveTo( origin, level.const_door_move_time, level.const_door_accel_time, level.const_door_decel_time );
	
	self thread door_move_think( origin, crush );
	self thread door_move_waittill_stop();

	if ( crush )
	{
		self.kill_trigger door_crush_think( origin, self );
		self.clip DisconnectPaths();
	}
	else
	{
		self waittill( "movedone" );
		self.clip ConnectPaths();
	}

	self.clip destroy_corpses();
}

// self = the door
door_move_think( origin, closing )
{
	self.clip endon( "movedone" );

	fx = false;

	for ( ;; )
	{
		wait( 0.2 );

		self.clip destroy_tactical_insertions();
		self.clip destroy_equipment();
		self.clip destroy_supply_crates();

		if ( !closing )
		{
			self.clip destroy_stuck_weapons();
		}

		z_diff = Abs( origin[2] - self.origin[2] );

		if ( closing && z_diff < 25 )
		{
			self door_crush_prone_players();
		}

		if ( closing && !fx && z_diff < 7 )
		{
			if ( IsDefined( self.fx_dust ) )
			{
				exploder( self.fx_dust );
			}

			fx = true;
		}
		else if ( !closing && !fx )
		{
			if ( IsDefined( self.fx_dust ) )
			{
				exploder( self.fx_dust );
			}

			fx = true;
		}
	}
}

door_crush_prone_players()
{
	start = self.kill_trigger GetPointInBounds( 0.5, -1, -1.0 );
	start = start + ( 0, 0, -1 );

	end = self.kill_trigger GetPointInBounds( 0.5, 1, -1.0 );
	end = end + ( 0, 0, -1 );
	
	trace = PlayerBulletTrace( start, end, undefined );

	if ( IsDefined( trace[ "entity" ] ) && IsPlayer( trace[ "entity" ] ) && IsAlive( trace[ "entity" ] ) )
	{
		player = trace[ "entity" ];

		if ( player.sessionstate != "playing" )
			return;

		if ( player.team == "spectator" )
			return;

		if ( player GetStance() != "prone" )
			return;

		self.kill_trigger notify( "trigger", player );
	}
}

//Self is a trigger. The triggers are placed in places players may get caught between moving script brushes
door_crush_think( origin, door )
{
	self endon( "movedone" );

	door thread door_move_pause( origin );

	//This only loops while the door is moving
	while( 1 )
	{
		self waittill( "trigger", ent );

		if( IsPlayer( ent ) && IsAlive( ent ) )
		{
			ent DoDamage(ent.health * 2, self.origin, ent, ent, 0, "MOD_CRUSH" );
			door notify( "killed_player" );
		}
		else if( IsDefined( ent.targetname ) && ent.targetname == "rcbomb" )
		{	
			//Destroy RC bomb
			ent maps\mp\_rcbomb::rcbomb_force_explode(); 
		}
		//This kills dogs
		else if ( IsAI( ent ) )
		{
			ent DoDamage( ent.health * 2, ent.origin);
		}
	}
}

// self = the door
door_move_waittill_stop()
{
	self endon( "killed_player" );

	self waittill( "movedone" );
	self.kill_trigger notify( "movedone" );
	self.clip notify( "movedone" );
}

// self = the door
door_move_pause( origin )
{
	self.clip endon( "movedone" );

	for ( ;; )
	{
		self waittill( "killed_player" );
		self MoveTo( self.origin, 0.01 );

		self StopLoopSound();
		self PlaySound( "evt_door_blocked" );

		wait( 2 );

		PlaySoundAtPosition( "evt_door_start", self.sound_emitter.origin );
		self PlayLoopSound( "evt_door_move" );

		z_diff = Abs( origin[2] - self.origin[2] );
		frac = ( z_diff / level.const_door_move_dist );

		time = level.const_door_move_time * frac;
		self thread door_move_waittill_stop();

		if ( level.const_door_accel_time + level.const_door_decel_time > time )
		{
			self MoveTo( origin, time );
		}
		else
		{
			self MoveTo( origin, time, level.const_door_accel_time, level.const_door_decel_time );
		}
	}
}

destroy_equipment()
{
	grenades = GetEntArray( "grenade", "classname" );

	for( i = 0; i < grenades.size; i++ )
	{
		item = grenades[i];

		if( !IsDefined( item.name ) )
		{
			continue;
		}

		if( !IsDefined( item.owner ) )
		{
			continue;
		}

		if( !IsWeaponEquipment( item.name ) )
		{
			continue;
		}

		if( !item IsTouching( self ) ) 
		{
			continue;
		}

		watcher = item.owner getWatcherForWeapon( item.name );

		if( !IsDefined( watcher ) )
		{
			continue;
		}

		watcher thread maps\mp\gametypes\_weaponobjects::waitAndDetonate( item, 0.0, undefined );
	}
}

destroy_tactical_insertions()
{
	players = get_players();

	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if ( !IsDefined( player.tacticalInsertion ) )
		{
			continue;
		}

		if ( player.tacticalInsertion IsTouching( self ) )
		{
			player.tacticalInsertion maps\mp\_tacticalinsertion::destroy_tactical_insertion();
		}
	}
}

destroy_supply_crates()
{
	crates = GetEntArray( "care_package", "script_noteworthy" );

	for ( i = 0; i < crates.size; i++ )
	{
		crate = crates[i];

		if( crate IsTouching( self ) ) 
		{
			PlayFX( level._supply_drop_explosion_fx, crate.origin );
			PlaySoundAtPosition( "wpn_grenade_explode", crate.origin );
			wait ( 0.1 );
			crate maps\mp\gametypes\_supplydrop::crateDelete();
		}
	}
}

destroy_corpses()
{
	corpses = GetCorpseArray();
	origin1 = self GetPointInBounds( 0.5, 0.0, -1.0 );
	origin2 = self GetPointInBounds( 0.5, 1.0, -1.0 );
	origin3 = self GetPointInBounds( 0.5, -1.0, -1.0 );

	for ( i = 0; i < corpses.size; i++ )
	{
		if( corpses[i] IsTouching( self ) ) 
		{
			corpses[i] delete();
		}
		else if ( DistanceSquared( corpses[i].origin, origin1 ) < 64 * 64 )
		{
			corpses[i] delete();
		}
		else if ( DistanceSquared( corpses[i].origin, origin2 ) < 64 * 64 )
		{
			corpses[i] delete();
		}
		else if ( DistanceSquared( corpses[i].origin, origin3 ) < 64 * 64 )
		{
			corpses[i] delete();
		}
	}
}

destroy_stuck_weapons()
{
	weapons = GetEntArray( "sticky_weapon", "targetname" );

	origin = self GetPointInBounds( 0.0, 0.0, -0.6 );
	z_cutoff = origin[2];
		
	for( i = 0 ; i < weapons.size ; i++ )
	{
		weapon = weapons[i];

		if ( weapon IsTouching( self ) && weapon.origin[2] > z_cutoff )
		{
			weapon delete();
		}
	}
}

getWatcherForWeapon( weapname )
{
	if ( !IsDefined( self ) )
	{
		return undefined;
	}

	if ( !IsPlayer( self ) )
	{
		return undefined;
	}

	for ( i = 0; i < self.weaponObjectWatcherArray.size; i++ )
	{
		if ( self.weaponObjectWatcherArray[i].weapon != weapname )
		{ 
			continue;
		}

		return ( self.weaponObjectWatcherArray[i] );
	}

	return undefined;
}

trigger_prox_think()
{
	if ( !IsDefined( self.script_noteworthy ) )
	{
		return;
	}

	self SetHintString( &"MP_OPERATE_DOOR");

	s = strtok( self.script_noteworthy, " " );
	origin = ( Int( s[0] ), Int( s[1] ), Int( s[2] ) );

	for ( ;; )
	{
		wait( RandomIntRange( 5, 10 ) );

		/#
			game[ "bots_spawned" ] = 1;
		#/

		if ( !IsDefined( game[ "bots_spawned" ] ) )
		{
			return;
		}

		players = get_players();

		for ( i = 0; i < players.size; i++ )
		{
			if ( players[i] maps\mp\gametypes\_bot::bot_is_idle() )
			{
				if ( DistanceSquared( players[i].origin, self.origin ) < 256 * 256 )
				{
					players[i] SetScriptGoal( origin, 64 );
					event = players[i] waittill_any_return( "goal", "bad_path", "death", "disconnect" );

					if ( event == "goal" )
					{
						players[i] PressUseButton( 0.5 );
						
						if ( IsDefined( players[i] ) && IsAlive( players[i] ) )
						{
							players[i] ClearScriptGoal();
						}
					}

					break;
				}
			}
		}
	}
}

/#
devgui_outskirts( cmd )
{
	for ( ;; )
	{
		wait( 0.5 );

		devgui_string = GetDvar( #"devgui_notify" );

		switch( devgui_string )
		{
			case "":
			break;

			case "outskirts_operate_1":
				triggers = GetEntArray( "moving_door_trig1", "targetname" );
				triggers[0] notify( "trigger" );
			break;

			case "outskirts_operate_2":
				triggers = GetEntArray( "moving_door_trig2", "targetname" );
				triggers[0] notify( "trigger" );
			break;

			default:
				level notify( devgui_string );
			break;
		}

		SetDvar( "devgui_notify", "" );
	}
}
#/
