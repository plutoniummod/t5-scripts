#include maps\mp\_utility;
#include common_scripts\utility;

#using_animtree ( "mp_critter" );

main()
{

	PrecacheModel("p_kow_airplane_747");
	PrecacheItem( "zipline_mp" );
	PrecacheString( &"MP_ZIPLINE" );
	
	//needs to be first for create fx
	maps\mp\mp_kowloon_fx::main();

	precachemodel("collision_wall_128x128x10");
	precachemodel("collision_geo_128x128x128");
	precachemodel("p_jun_woodbarrel_asian_lid_wet");

	if ( GetDvarInt( #"xblive_wagermatch" ) == 1 )
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_kowloon_wager");
	}
	else
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_kowloon");
	}

	maps\mp\_load::main();

	/#
		level thread devgui_kowloon();
		execdevgui( "devgui_mp_kowloon" );
	#/

	maps\mp\mp_kowloon_amb::main();

	// If the team nationalites change in this file,
	// you must update the team nationality in the level's csc file as well!
	maps\mp\gametypes\_teamset_urbanspecops::level_init();



	// enable new spawning system
	maps\mp\gametypes\_spawning::level_use_unified_spawning(true);

	// Start a killtrigger to keep players from standing on thier carepackages outside the map.
	thread trigger_killer((920, -336, -592), 1725, 128);
	thread trigger_killer((1440, 1848, -592), 1725, 128);

	// spawn collision to keep the player out the corner by the stairs. 
	spawncollision("collision_geo_128x128x128","collider",(-486, -1115, -181), (0, 0, 0));
	spawncollision("collision_geo_128x128x128","collider",(-514, -1115, -128), (40, 0, 0));
	spawncollision("collision_geo_128x128x128","collider",(-571, -998, -129), (0, 270, 0));
	spawncollision("collision_wall_128x128x10","collider",(-514, -998, -17), (0, 270, 0));

	// spawn in collision to prevent players from landing on the ledge by the ragdoll pachinko pit
	spawncollision("collision_wall_128x128x10","collider",(1293, 1015, 14), (0, 0, 9.19996));

	// spawn collision to keep the player out the corner by the stairs. 
	//spawncollision("collision_geo_32x32x128","collider",(-440, -1040, -206), (0, 0, 0));

	// spawn a barrel in the corner by the stairs to account for the collision.
	/*wetBarrel1 = Spawn("script_model", (-442, -1038, -193) );
	if ( IsDefined(wetBarrel1) )
	{
		wetBarrel1.angles = (0, 0, 0);
		wetBarrel1 SetModel("p_jun_woodbarrel_asian_lid_wet");
	}*/
		
	
	//Sets up zipline functionality
	level thread zipline_init();

	// Planes fly overhead periodically
	level thread handle_ambient_planes();

	animal_anims = [];
	animal_anims[ animal_anims.size ] = %a_monkey_freaked_01;
	animal_anims[ animal_anims.size ] = %a_monkey_freaked_02;
	animal_anims[ animal_anims.size ] = %a_monkey_freaked_03;
	animal_anims[ animal_anims.size ] = %a_chicken_freaked_01;
	animal_anims[ animal_anims.size ] = %a_chicken_freaked_02;
	animal_anims[ animal_anims.size ] = %a_chicken_freaked_03;
	
	level thread glass_exploder_init();
}

trigger_killer( position, width, height )
{
	kill_trig = spawn("trigger_radius", position, 0, width, height);

	while(1)
	{
		kill_trig waittill("trigger",player);
		if ( isplayer( player ) )
		{
			player suicide();
		}
	}
}


//Starts a thread on all the zipline use triggers
zipline_init()
{
	SetDvar( "scr_zipline_accelerate", "1" );
	SetDvar( "scr_zipline_decelerate", ".3" );
	SetDvar( "scr_zipline_line_up", ".35" );

	level waittill( "prematch_over" );

	//Grab all zipline triggers in the map and run a thread on them
	zipline_trigs = GetEntArray( "zipline_trigger","targetname" );
	array_thread( zipline_trigs, ::zipline_trigger_func );
	array_thread( zipline_trigs, ::zipline_prox_think );
}

//Self is the zipline trigger. Waits for player to use it and then starts a thread on the player.
zipline_trigger_func()
{
	//TODO: Make proper string
	self SetHintString( &"MP_ZIPLINE" );

	start_point = GetStruct( self.target );
	end_point = GetStruct( start_point.target );
	zipline_speed = self.script_float;
	AssertEx( IsDefined( zipline_speed ),"Zip line use trigger does not have a script_float K/V pair defined" );

	moving_ent = Spawn( "script_model",start_point.origin );
	moving_ent SetModel( "tag_origin" );

	while( 1 )
	{
		self waittill ( "trigger", player );

		if( canZipline( player ) )
		{
			player.enteringVehicle = true;
			player thread zipline_player_func( start_point, end_point.origin, moving_ent, zipline_speed );
			self trigger_off();
			//If player dies, disconnects or reaches their destination, reset moving_ent and turn trigger back on
			waittill_any_ents( player,"death",player,"disconnect", moving_ent,"zip" );
			
			if ( IsDefined( player ) )
			{
				player.enteringVehicle = false;
			}

			moving_ent stoploopsound();
			self trigger_on();
		}
	}
}

canZipline( player )
{
	if ( !IsDefined( player ) )
		return false;

	if ( !IsPlayer( player ) )
		return false;

	if ( !IsAlive( player ) )
		return false;

	if ( ( IsDefined( player.isDefusing ) && player.isDefusing ) )
		return false;

	if ( ( IsDefined( player.isPlanting ) && player.isPlanting ) )
		return false;

	if ( IsDefined( player.proxBar ) && !player.proxBar.hidden )
		return false;

	if ( IsDefined( player.revivingTeammate ) && player.revivingTeammate == true )
		return false;

	if ( !player IsOnGround() )
		return false;

	if ( player IsInVehicle() )
		return false;

	if ( player IsThrowingGrenade() )
		return false;

	if ( player IsSwitchingWeapons() )
		return false;

	if ( player IsMeleeing() )
		return false;

	if ( IsDefined( player.laststand ) && player.laststand )
		return false;

	weapon = player GetCurrentWeapon(); 

	if ( !IsDefined( weapon ) )
		return false;

	if ( weapon == "none" )
		return false;

	if ( IsWeaponEquipment( weapon ) && player IsFiring() )
		return false;

	if ( IsWeaponSpecificUse( weapon ) )
		return false;

	return true;
}

//Self is the player that used the zipline trigger. Lerps the player from the starting point to the end point
zipline_player_func( start_point, end_point_origin, moving_ent, zipline_speed )
{
	self endon( "death" );
	self endon( "disconnect" );
	 
	//TODO: Set up correct angles restrictions on player while on zipline
	moving_ent.origin = self.origin + ( 0, 0, 80 );
	moving_ent.angles = self.angles;

	current_weapon = self GetCurrentWeapon(); 

	zipline_accelerate = GetDvarFloat( "scr_zipline_accelerate" );
	zipline_decelerate = GetDvarFloat( "scr_zipline_decelerate" );
	zipline_line_up = GetDvarFloat( "scr_zipline_line_up" );
	end_zipline_offset = 16;
	
	self SetStance( "stand" );
	self GiveWeapon( "zipline_mp" );
	self SwitchToWeapon( "zipline_mp" );
	self FreezeControlsAllowLook( true );
	self DisableWeaponCycling();

	self waittill( "weapon_raising" );

	//Rotate player and move them to line them up with the zipline.
	self PlayerLinkToDelta( moving_ent, "tag_origin", 1 );
	
	moving_ent RotateTo( start_point.angles, zipline_line_up );
	moving_ent MoveTo( start_point.origin, zipline_line_up );
	
	moving_ent waittill ( "movedone" );

	moving_ent playloopsound( "evt_zipline_slide");
	
	moving_ent MoveTo( end_point_origin, zipline_speed, zipline_accelerate, zipline_decelerate );
	dist = Distance2D( moving_ent.origin, end_point_origin );
	self SetDepthOfField( 0, 10, 1000, 7000, 6, 1.8 );

	moving_ent waittill( "movedone" );

	//Player lets go of zipline a little early to make it look more natural.
	while(  dist > end_zipline_offset )
	{
		wait(0.05);
		dist = Distance2D( moving_ent.origin, end_point_origin );
	}
	 
	moving_ent stoploopsound(.5);
	self Unlink();
	self FreezeControlsAllowLook( false );
	self SetDepthOfField( 0, 1, 8000, 10000, 6, 0 );

	if ( IsDefined( current_weapon ) && current_weapon != "none" && self HasWeapon( current_weapon ) )
	{
		self SwitchToWeapon( current_weapon );
		self wait_endon( 2, "weapon_raising" );
	}
	else
	{
		// failsafe: switch to the first primary
		primaries = self GetWeaponsListPrimaries();

		if ( IsDefined( primaries ) && primaries.size > 0 && primaries[0] != "none" )
		{
			self SwitchToWeapon( primaries[0] );
		}

		self wait_endon( 2, "weapon_raising" );
	}
	
	self EnableWeaponCycling();
	self TakeWeapon( "zipline_mp" );

	//Notify sends moving ent back to its start position
	moving_ent notify ( "zip" );

}

zipline_prox_think()
{
	if ( !IsDefined( self.script_noteworthy ) )
	{
		return;
	}

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
			if ( players[i] is_bot() && cointoss() )
			{
				if ( DistanceSquared( players[i].origin, origin ) < 256 * 256 )
				{
					players[i] SetScriptGoal( origin, 32 );
					event = players[i] waittill_any_return( "goal", "bad_path", "death", "disconnect" );

					if ( event == "goal" )
					{
						players[i] PressUseButton( 3 );
						wait( 3 );
						players[i] ClearScriptGoal();
					}

					break;
				}
			}
		}
	}
}


handle_ambient_planes()
{
	
	// Longish interval between flyovers
	wait (8);
	
	// Pick a start and end point for the plane path randomly from all that are available in the map
	// Naming goes: plane_flyby_start_1, plane_flyby_start_2, ... N
	//              plane_flyby_end_1, plane_flyby_end_2, ... N
	index = 1;
	count = 0.0;
	foundPlanePoints = true;
	startPos = undefined;
	endPos = undefined;
	while ( foundPlanePoints )
	{
		foundPlanePoints = false;
		startPosEnt = GetStruct("plane_flyby_start_" + index, "targetname");
		endPosEnt = GetStruct("plane_flyby_end_" + index, "targetname");
		if ( IsDefined(startPosEnt) && IsDefined(endPosEnt) )
		{
			foundPlanePoints = true;
			count += 1.0;
			
			if ( RandomFloat(1) <= (1.0/count) )
			{
				startPos = startPosEnt.origin;
				endPos = endPosEnt.origin;
			}	
		}
		index++;
	}
	/*startPos = undefined;
	endPos = undefined;
	startPosEnt = GetStruct("plane_flyby_start_1", "targetname");
	endPosEnt = GetStruct("plane_flyby_end_1", "targetname");*/
	
	// Spawn a script_model and just move from start to end point at the speed a 747 goes while landing
	if ( IsDefined(startPos) && IsDefined(endPos) )
	{
		//speed = 2640.0;// [(150*63360)/60/60] : 150 Miles per hour on take-off and landing [63360 inches per mile]
		//kevin lowered the speed.  The new speed fits the audio better and keeps us from having to add new, large audio files.
		speed = 1340.0;// [(150*63360)/60/60] : 150 Miles per hour on take-off and landing [63360 inches per mile]
		delta = (endPos - startPos);
		dist = Length(delta);
		travelTime = dist / speed;
		
		// Launch the plane
		plane = Spawn("script_model", startPos );
		if ( IsDefined(plane) )
		{
			// Set the plane model and move it from startPos to endPos
			dir = VectorNormalize(delta);
			plane.angles = VectorToAngles(dir);
			plane SetModel("p_kow_airplane_747");
			plane MoveTo(endPos, travelTime);
			
			plane thread maps\mp\mp_kowloon_amb::plane_position_updater (4500, "evt_jet_flyover" );
			
			// Veh_jet_flyover plays from the location over the map where the jet comes closest overhead. 
			// The sound is 10 seconds total. So, the trick is to start it playing so the plane reaches the 
			// sound emitter about 5 seconds after the sound starts. If it works, the plane will be closest 
			// overhead when the sound is its loudest (at 5 seconds).
			/*
			soundPos = startPos + (delta * 0.5); // What we really do here, though, it just put it at the center of its path
			PlaySoundAtPosition("veh_jet_flyover", soundPos);

			// Veh_jet_flyover_lfe is only low frequency. It extends the sound of the flyover if we could have 
			// this play from the same location but start 3 seconds after the first sound starts. 
			wait 3;
			PlaySoundAtPosition("veh_jet_flyover_lfe", soundPos);
			*/

			// Wait for traversal to finish, then delete the plane
			wait travelTime;
			plane Delete();
			//complete = true;
		}
	}
}

/#
devgui_kowloon( cmd )
{
	for ( ;; )
	{
		wait( 0.5 );

		devgui_string = GetDvar( #"devgui_notify" );

		switch( devgui_string )
		{
			case "":
			break;

			default:
				level notify( devgui_string );
			break;
		}

		SetDvar( "devgui_notify", "" );
	}
}
#/

		
glass_exploder_init()
{
	single_exploders = [];
	
	for ( i = 0; i < level.createFXent.size; i++ )
	{
		ent = level.createFXent[ i ];

		if ( !IsDefined( ent ) )
			continue;
	
		if ( ent.v[ "type" ] != "exploder" )
			continue;	

		if ( ent.v[ "exploder" ] == 101 )
		{
			single_exploders[ single_exploders.size ] = ent;
		}
	}

	level thread glass_exploder_think( single_exploders );
}

glass_exploder_think( exploders )
{
	thresholdSq = 60 * 60;

	if ( exploders.size <= 0 )
	{
		return;
	}
	
	for ( ;; )
	{
		closest = 999 * 999;
		closest_exploder = undefined;
		
		level waittill( "glass_smash", origin );

		for ( i = 0; i < exploders.size; i++ )
		{
			if ( !IsDefined( exploders[i] ) )
			{
				continue;
			}

			if ( IsDefined( exploders[i].glass_broken ) )
			{
				continue;
			}

			distSq = DistanceSquared( exploders[i].v[ "origin" ], origin );

			if ( distSq > thresholdSq )
			{
				continue;
			}

			if ( distSq < closest )
			{
				closest_exploder = exploders[i];
				closest = distSq;
			}
		}

		if ( IsDefined( closest_exploder ) )
		{
			closest_exploder.glass_broken = true;
			exploder( closest_exploder.v[ "exploder" ] );
		}
	}
}
