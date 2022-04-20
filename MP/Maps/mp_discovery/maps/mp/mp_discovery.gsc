#include maps\mp\_utility;	
#include common_scripts\utility;

main()	
{	
	//needs to be first for create fx
	maps\mp\mp_discovery_fx::main();
	
	precachemodel("collision_vehicle_64x64x64");
	precachemodel("collision_wall_128x128x10");

	if ( GetDvarInt( #"xblive_wagermatch" ) == 1 )
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_discovery2_wager");
	}
	else
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_discovery2");
	}
	
	maps\mp\_load::main();

	/#
		level thread devgui_discovery();
		execdevgui( "devgui_mp_discovery" );
	#/
	
	//maps\mp\mp_discovery_amb::main();
	
	
	// If the team nationalites change in this file,
	// you must update the team nationality in the level's csc file as well!
	//maps\mp\gametypes\_teamset_urbanspecops::level_init();
	maps\mp\gametypes\_teamset_winterspecops::level_init();
	
	//collision to prevent RC car falling into map-hole by ice cave
	spawncollision("collision_vehicle_64x64x64","collider", (-1105.96, 2118.02, 148), (0, 335.7, 0));
	
	//collision to prevent players from getting out of map through Weather Station
	spawncollision("collision_wall_128x128x10","collider", (-1439, 1383, 150), (0, 0, 0));
	spawncollision("collision_wall_128x128x10","collider", (-1384.63, 1392.93, 150), (0, 315, 0));


	//collision to prevent players from laying prone in the rocks on the edge of the map
	spawncollision("collision_geo_sphere_64","collider", (729.5, 1099, -5.5), (0, 348.4, 0));
	
	
	// spawning little ice rock to cover hole in texture on top of barracks/kitchen building.
	icechunk1 = Spawn("script_model", (-958.025, -1587.14, 179) );
	if ( IsDefined(icechunk1) )
	{
		icechunk1.angles = (0, 129.067, 0);
		icechunk1 SetModel("p_rus_snow_chunk_04");
	}

	// enable new spawning system
	maps\mp\gametypes\_spawning::level_use_unified_spawning(true);

	level thread dynamic_path_init();
	
	// rock ledge kill trigger
	thread trigger_killer( (-1831, -192.5, -228), 64, 128);  // tall and thin

}	

dynamic_path_init()
{
/# 
	level endon( "dynamic_path_reset" );
#/

	level.destroyed_paths = [];
	dynamic_path_triggers = GetEntArray( "dynamic_path", "targetname" );
	array_thread( dynamic_path_triggers, ::dynamic_path_think );
	
/#
	array_thread( dynamic_path_triggers, ::dynamic_path_debug );
#/

	for( ;; )
	{
		level waittill( "connected", player );
		player thread dynamic_path_delete();
	}
}

dynamic_path_delete()
{
	self endon( "disconnect" );
	self wait_endon( 5, "spawned" );

	for ( i = 0; i < level.destroyed_paths.size; i++ )
	{
		self ClientNotify( level.destroyed_paths[i] );
		wait( 0.1 );
	}
}

dynamic_path_think()
{
	client_notify = undefined;
	player_collisions = [];
	ai_collisions = [];

	remove = true;

/#
	level endon( "dynamic_path_reset" );
	self.health = 32000;
	remove = false;
#/

	if ( IsDefined( self.script_noteworthy ) )
	{
		client_notify = self.script_noteworthy + "_anim";

		player_collisions = GetEntArray( self.script_noteworthy + "_collision", "targetname" );
		ai_collisions = GetEntArray( self.script_noteworthy + "_ai_collision", "targetname" );
	}

	for ( i = 0; i < ai_collisions.size; i++ )
	{
		ai_collisions[i] NotSolid();
		ai_collisions[i] ConnectPaths();
	}

/#
	for ( i = 0; i < player_collisions.size; i++ )
	{
		if ( IsDefined( player_collisions[i].og_origin ) )
		{
			player_collisions[i].origin = player_collisions[i].og_origin;
		}
	}
#/

	self.fake_health_max = 500;
	self.fake_health = self.fake_health_max;

	self thread sound_small_think();
	self thread sound_heavy_think();

	for ( ;; )
	{
		self waittill( "damage", amount, attacker, direction, point, type );

		if ( !IsDefined( type ) )
		{
			continue;
		}

		if ( type == "MOD_MELEE" || type == "MOD_UNKNOWN" || type == "MOD_IMPACT" )
		{
			continue;
		}

		self.fake_health -= amount;

		if( self.fake_health <= self.fake_health_max / 2 )
		{
			self notify( "damage_small" );
		}

		if( self.fake_health <= self.fake_health_max / 4 )
		{
			self notify( "damage_heavy" );
		}

		if ( self.fake_health <= 0 )
		{
			break;
		}
	}

	if ( IsDefined( client_notify ) )
	{
		level ClientNotify( client_notify );
		level.destroyed_paths[ level.destroyed_paths.size ] = client_notify + "_delete";
	}

	for ( i = 0; i < ai_collisions.size; i++ )
	{
		ai_collisions[i] Solid();
		ai_collisions[i] DisconnectPaths();
	}

	for ( i = 0; i < player_collisions.size; i++ )
	{
		if ( remove )
		{
			player_collisions[i] delete();
		}
		else
		{
			player_collisions[i].og_origin = player_collisions[i].origin;
			player_collisions[i].origin = player_collisions[i].origin + ( 0, 0, -10000 );
		}
	}

	PlayRumbleOnPosition( "grenade_rumble", self.origin );
	Earthquake( 0.5, 0.5, self.origin, 800 );
	playsoundatposition ( "dst_glacier_fall", self.origin );	

	level thread dropAllToGround( self.origin, 128, 128 );
	self dynamic_path_destroy_equipment();

	// bombs & flags
	if ( IsDefined( level.sdBomb ) && level.sdBomb.visuals[0] IsTouching( self ) )
	{
		level.sdBomb maps\mp\gametypes\_gameobjects::returnHome();
	}

	if ( IsDefined( level.sabBomb ) && level.sabBomb.visuals[0] IsTouching( self ) )
	{
		level.sabBomb maps\mp\gametypes\_gameobjects::returnHome();
	}

	if ( IsDefined( level.flags ) )
	{
		for ( i = 0; i < level.flags.size; i++ )
		{
			if ( IsDefined( level.flags[i].visuals ) && level.flags[i].visuals[0] IsTouching( self ) )
			{
				level.flags[i] maps\mp\gametypes\_gameobjects::returnHome();
			}
		}
	}

	if ( remove )
	{
		self delete();
	}
}

sound_small_think()
{
	self endon( "death" );

/#
	level endon( "dynamic_path_reset" );
#/

	self waittill( "damage_small" );
	playsoundatposition ( "evt_glacier_crack_small", self.origin );
}

sound_heavy_think()
{
	self endon( "death" );

/#
	level endon( "dynamic_path_reset" );
#/

	self waittill( "damage_heavy" );
	playsoundatposition ( "evt_glacier_crack_heavy", self.origin );
}

/#
dynamic_path_debug()
{
	self endon( "death" );
	level endon( "dynamic_path_reset" );

	for ( ;; )
	{
		if ( GetDvarInt( "scr_discovery_path_debug" ) > 0 )
		{
			print3d( self.origin, self.fake_health );
			wait( 0.05 );
		}
		else
		{
			wait( 1 );
		}
	}
}
#/

dynamic_path_destroy_equipment()
{
	grenades = GetEntArray( "grenade", "classname" );

	for ( i = 0; i < grenades.size; i++ )
	{
		item = grenades[i];

		if ( !IsDefined( item.name ) )
		{
			continue;
		}

		if ( !IsDefined( item.owner ) )
		{
			continue;
		}

		if ( !IsWeaponEquipment( item.name ) )
		{
			continue;
		}

		if ( !item IsTouching( self ) )
		{
			continue;
		}

		watcher = item.owner getWatcherForWeapon( item.name );

		if ( !IsDefined( watcher ) )
		{
			continue;
		}

		watcher thread maps\mp\gametypes\_weaponobjects::waitAndDetonate( item, 0.0, undefined );
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

/#
devgui_discovery( cmd )
{
	SetDvar( "scr_discovery_path_debug", "0" );

	dynamic_path_triggers = GetEntArray( "dynamic_path", "targetname" );
	warp = 0;

	for ( ;; )
	{
		wait( 0.5 );

		devgui_string = GetDvar( #"devgui_notify" );

		switch( devgui_string )
		{
			case "":
			break;

			case "discovery_path_rebuild":
				iprintln( "Rebuilding Dynamic Paths" );
				level notify( "dynamic_path_reset" );
				level ClientNotify( "dynamic_path_reset" );
				level thread dynamic_path_init();
			break;

			case "scr_discovery_path_debug":
			break;

			case "discovery_path_warp_next":
				GetHostPlayer() SetOrigin( dynamic_path_triggers[ warp ].origin + ( 0, 0, 60 ) );
				warp++;

				if ( warp >= dynamic_path_triggers.size )
					warp = 0;
			break;

			case "discovery_path_warp_prev":
				GetHostPlayer() SetOrigin( dynamic_path_triggers[ warp ].origin + ( 0, 0, 60 ) );
				warp--;

				if ( warp < 0 )
					warp = dynamic_path_triggers.size - 1;
			break;

			default:
				level notify( devgui_string );
			break;
		}

		SetDvar( "devgui_notify", "" );
	}
}
#/

	//function to set up trigger_killer for spawned in kill trigger_radius
	trigger_killer( position, width, height )
{
	kill_trig = spawn("trigger_radius", position, 0, width, height);

		while(1)
		{
			kill_trig waittill("trigger",player);
			if (isplayer( player ))
			{
				player suicide();
			}
		}
}
