#include maps\mp\_utility;
#include common_scripts\utility; 

main()
{
	//needs to be first for create fx
	maps\mp\mp_berlinwall2_fx::main();
	
	precachemodel("collision_wall_128x128x10");

	maps\mp\_load::main();

	maps\mp\mp_berlinwall2_amb::main();

//	maps\mp\_compass::setupMiniMap("compass_map_mp_berlinwall2"); 
	if ( GetDvarInt( #"xblive_wagermatch" ) == 1 )
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_berlinwall2_wager");
	}
	else
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_berlinwall2");
	}	
	
	// COLLISION - to prevent players from walking on the ledge on the exterior of the brewery
	spawncollision("collision_wall_128x128x10","collider",(1624.96, -1937.84, 296), (0, 280, 0));

	// If the team nationalites change in this file,
	// you must update the team nationality in the level's csc file as well!
	maps\mp\gametypes\_teamset_urbanspecops::level_init();

	// enable new spawning system
	maps\mp\gametypes\_spawning::level_use_unified_spawning(true);

	precacheItem( "minigun_turret_mp" );

	//For targeting and damaging players that enter the kill zones in front of the guard towers
	level thread killzone_init();
	level thread nomansland_alarm_watch();
}

killzone_init() // self == level
{
	level._berlin_firing_delay = 0.1;
	level._berlin_firing_start_z = -60;
	level._berlin_firing_end_z = 30;
	level._berlin_firing_increment_z = 10;
	level._berlin_firing_spread = 15;

	SetDvar( "scr_berlin_firing_delay", level._berlin_firing_delay );
	SetDvar( "scr_berlin_firing_start_z", level._berlin_firing_start_z );
	SetDvar( "scr_berlin_firing_end_z", level._berlin_firing_end_z );
	SetDvar( "scr_berlin_firing_increment_z", level._berlin_firing_increment_z );
	SetDvar( "scr_berlin_firing_spread", level._berlin_firing_spread );
	level thread update_dvars();
	level thread watch_killzone_paths();

	// grab the triggers and thread watchers
	for( i = 1; i < 7; i++ )
	{
		trig = GetEnt( "killzone_trigger_" + i, "targetname" );
		if( IsDefined( trig ) )
		{
			trig thread watch_killzone();
		}
	}
}

update_dvars() // self == level
{
	level endon( "game_ended" );

	while( true )
	{
		level._berlin_firing_delay = GetDvarFloat( #"scr_berlin_firing_delay" );
		level._berlin_firing_start_z = GetDvarFloat( #"scr_berlin_firing_start_z" );
		level._berlin_firing_end_z = GetDvarFloat( #"scr_berlin_firing_end_z" );
		level._berlin_firing_increment_z = GetDvarFloat( #"scr_berlin_firing_increment_z" );
		level._berlin_firing_spread = GetDvarFloat( #"scr_berlin_firing_spread" );

		wait(0.5);
	}
}

watch_killzone() // self == killzone trigger
{
	level endon( "game_ended" );

	gun = GetEnt( self.target, "targetname" );

	shooting_pos = gun GetTagOrigin( "tag_flash" );
	shooting_ang = gun GetTagAngles( "tag_flash" );
	killCamEnt = Spawn( "script_model", shooting_pos );
	killCamEnt.angles = shooting_ang;
	killCamEnt LinkTo( gun, "tag_flash" );
	killCamEnt.startTime = gettime();
	gun.killCamEnt = killCamEnt;
	gun.isMagicBullet = true;

	while(true)
	{
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			if( players[i] IsTouching( self ) && players[i].sessionstate == "playing" )
			{
				if ( players[i].team == "spectator" )
				{
					continue;
				}
				
				if ( !IsAlive( players[i] ) )
				{
					continue;
				}

			/#
				if ( players[i] IsInMoveMode( "ufo", "noclip" ) )
				{
					continue;
				}
			#/

				level.play_nomansland_alarm = true;
				players[i] thread acquired_target( gun );
				players[i] thread watch_still_touching( self );
				level waittill( "new_target" );
				gun StopLoopSound();
				PlaySoundAtPosition( "wpn_berturret_stop_npc", gun.origin );
				break;
			}
		}
		wait(0.05);
	}
}

watch_killzone_paths()
{
	ai_collisions = GetEntArray( "dog_clip", "targetname" );

	for ( i = 0; i < ai_collisions.size; i++ )
	{
		ai_collisions[i] DisconnectPaths();
	}

	for ( ;; )
	{
		level waittill( "called_in_the_dogs" );

		for ( i = 0; i < ai_collisions.size; i++ )
		{
			ai_collisions[i] ConnectPaths();
			ai_collisions[i] NotSolid();
		}

		while ( IsDefined( level.dogs ) && level.dogs.size > 0 )
		{
			wait( 1 );
		}

		for ( i = 0; i < ai_collisions.size; i++ )
		{
			ai_collisions[i] Solid();
			ai_collisions[i] DisconnectPaths();
		}
	}
}

acquired_target( gun ) // self == player
{
	level endon( "new_target" );
	self thread watch_death();

	// we have a target and we'll do all of this until we don't have a target anymore
	//PlaySoundAtPosition( "wpn_minigun_start_npc", gun.origin );
	PlaySoundAtPosition( "mpl_turret_alert", gun.origin );
	wait(0.5);
	gun PlayLoopSound( "wpn_berturret_start_npc" );
	gun PlayLoopSound( "wpn_berturret_fire_loop_npc" );

	start_z = level._berlin_firing_start_z;

	while( true )
	{
		// if the gun can't see the player, acquire a new target
		shooting_pos = gun.origin + ( AnglesToForward( gun.angles ) * 40 );
		if( !SightTracePassed( shooting_pos, self.origin + (0, 0, 50), false, undefined ) )
		{
			level notify( "new_target" );
			return;
		}

		fire_pos = self.origin + (0, 0, start_z);

		level thread aim_at_player( fire_pos, gun );
		fire_at_player( fire_pos, gun );

		// fire in front of the player and come to them
		start_z += level._berlin_firing_increment_z;
		if( start_z >= level._berlin_firing_end_z )
			start_z = level._berlin_firing_end_z;

		wait( level._berlin_firing_delay );
	}
}

watch_death() // self == player
{
	level endon( "new_target" );

	self waittill_any( "death", "disconnect" );
	level notify( "new_target" );
}

watch_still_touching( trig ) // self == player
{
	self endon( "death" );
	self endon( "disconnect" );

	while( true )
	{
		if( self.sessionstate != "playing" )
		{
			level notify( "new_target" );
			break;
		}

		if ( self.team == "spectator" )
		{
			level notify( "new_target" );
			break;
		}

		if ( !IsAlive( self ) )
		{
			level notify( "new_target" );
			break;
		}

	/#
		if ( self IsInMoveMode( "ufo", "noclip" ) )
		{
			level notify( "new_target" );
			break;
		}
	#/

		if( !self IsTouching( trig ) )
		{
			level notify( "new_target" );
			break;
		}
		wait(0.05);
	}
}

aim_at_player( target_pos, gun )
{
	aim_angles = VectorToAngles( target_pos - gun.origin );
	gun RotateTo( aim_angles, 0.25, 0, 0 );
	gun waittill( "rotatedone" );
}

fire_at_player( target_pos, gun )
{
	// make a random shot in one of these places, kind of making a square but more like
	/*
		*P*
		***
		where P is the player
	*/

	// randomize the target position
	pos = level._berlin_firing_spread;
	neg = level._berlin_firing_spread * -1;
	positions = [];
	positions[0] = (0, neg, 0);
	positions[1] = (0, neg, neg);
	positions[2] = (0, 0, neg);
	positions[3] = (0, pos, neg);
	positions[4] = (0, pos, 0);
	rand_pos = RandomInt( 5 );

	// give it a 1:3 chance of hitting the target
	switch( RandomInt( 3 ) )
	{
	case 0:
		target_pos += positions[ rand_pos ];
		break;
	case 1:
		// hit the target
		break;
	case 2:
		target_pos += positions[ rand_pos ];
		break;
	}

	vec_scalar = 40;
	shooting_pos = gun.origin + ( AnglesToForward( gun.angles ) * vec_scalar );
	MagicBullet( "minigun_turret_mp", shooting_pos, target_pos, gun );
}

nomansland_alarm_watch()
{	
	level endon( "game_ended" );

	level.play_nomansland_alarm = false;
	for ( ;; )
	{
		wait 0.25;
		if ( level.play_nomansland_alarm )
		{
			
			PlaySoundAtPosition( "evt_alert_siren" ,(1812, -840, 386));
			PlaySoundAtPosition( "evt_alert_siren" ,(-76, -691, 392));

			wait(RandomFloatRange( 6.5, 7.5 ) );

			level.play_nomansland_alarm = false;
			
		}
	}
}
