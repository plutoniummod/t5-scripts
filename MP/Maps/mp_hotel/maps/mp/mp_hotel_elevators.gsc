#include maps\mp\_utility;
#include common_scripts\utility;
	
init()
{
	level.elevator_move_time = getDvarIntDefault( #"scr_elevator_move_time", 3 );
	level.elevator_move_dist = getDvarIntDefault( #"scr_elevator_move_dist", 215 );
	level.elevator_accel_time = getDvarFloatDefault( #"scr_elevator_accel_time", .6 );
	level.elevator_decel_time = getDvarFloatDefault( #"scr_elevator_decel_time", .6 );
	level.elevator_cooldown_time = getDvarIntDefault( #"scr_elevator_cooldown_time", 3 );
	level.elevator_door_move_time = getDvarFloatDefault( #"scr_elevator_door_move_time", .9 );
	level.elevator_door_stagger_time = getDvarFloatDefault( #"scr_elevator_door_move_time", .15 );
	level.elevator_max_riders = getDvarIntDefault( #"scr_elevator_max_riders", 3 );
	level.elevator_failsafe = getDvarIntDefault( #"scr_elevator_failsafe", 0 );

	if ( GetDvarInt( #"xblive_wagermatch" ) == 1 )
	{
		level.elevator_failsafe = 1;
	}

	thread shaft_kill_trig_init();

	node_catchers = GetEntArray( "node_catcher", "targetname" );

	/#
		PrintLn( node_catchers.size + " node catching brushes in map" );
	#/
	
	for ( i = 0; i < node_catchers.size; i++ )
	{
		node_catchers[i] Delete();			
	}

	level elevator_parts_enable_linkto();

	level.elevators = GetEntArray( "script_elevator", "targetname" );
	level.ragdoll_override = ::mp_hotel_ragdoll_override;
	level.levelSpecificKillcam = ::insideElevatorKillcam;

	/#
		PrintLn( level.elevators.size + " moving elevators in map" );
	#/

	array_func( level.elevators, ::elevator_init );
	array_thread( level.elevators, ::elevator_think ); 	
	array_thread( level.elevators, ::elevator_prox_think ); 	
}

//---------------------------------------------------------------------------------------------------
// ELEVATOR OBJECT FUNCTIONS
//---------------------------------------------------------------------------------------------------

// self is the elevator
elevator_init()
{
	self.location = "lower";

	// create the killcam entity
	self.killcament = createKillCamEnt();

	// link all ents with parents
	self elevator_parts_linkto();

	// pull out the moving parts
	self.elevator_doors = self door_get_elevator_doors();
	self.floor_doors = self door_get_floor_doors();

	// pull out the triggers
	self.use_triggers = self elevator_get_use_triggers();

	if ( level.elevator_failsafe )
	{
		self.use_triggers[ "main" ] SetHintString( &"MP_ELEVATOR_UNAVAILABLE" );
		self.use_triggers[ "upper" ] SetHintString( &"MP_ELEVATOR_UNAVAILABLE" );
		self.use_triggers[ "lower" ] SetHintString( &"MP_ELEVATOR_UNAVAILABLE" );
	}

	volumes = GetEntArray( "elevator_occupy_volume", "targetname" );
	self.occupy_volume = GetClosest( self.origin, volumes );

	// dynamic node script brushes
	self.ai_clip = [];
	
	clip = GetEntArray( "elevator_ai_clip_upper", "targetname" );
	self.ai_clip[ "upper" ] = GetClosest( self.origin, clip );

	clip = GetEntArray( "elevator_ai_clip_lower", "targetname" );
	self.ai_clip[ "lower" ] = GetClosest( self.origin, clip );

	// fx
	fx = GetStructArray( "elevator_fx", "targetname" );
	fx = GetClosest( self.origin, fx );

	self.fx = spawn( "script_model", fx.origin );
	self.fx SetModel( "tag_origin" );
	self.fx.angles = fx.angles;
	self.fx LinkTo( self );

	self.displays = [];
	displays = GetEntArray( "elevator_interior_display", "targetname" );
	self.displays[ "interior" ] = GetClosest( self.origin, displays );

	displays = GetEntArray( "elevator_display_upper", "targetname" );
	self.displays[ "upper" ] = GetClosest( self.origin, displays );

	if ( Distance2D( self.displays[ "upper" ].origin, self.origin ) > 256 )
	{
		self.displays[ "upper" ] = undefined;
	}

	displays = GetEntArray( "elevator_display_lower", "targetname" );
	self.displays[ "lower" ] = GetClosest( self.origin, displays );

	if ( Distance2D( self.displays[ "lower" ].origin, self.origin ) > 256 )
	{
		self.displays[ "lower" ] = undefined;
	}

	// set the door open/closed origins
	door_set_origins( self.elevator_doors[ "upper" ] );
	door_set_origins( self.elevator_doors[ "lower" ] );
	door_set_origins( self.floor_doors[ "upper" ] );
	door_set_origins( self.floor_doors[ "lower" ] );
}

//Self is the moving elevator
elevator_think()
{
	// close upstairs doors
	door_instant_close( self.elevator_doors[ "upper" ][ "left" ], self.elevator_doors[ "lower" ][ "left" ].origin[2] );
	door_instant_close( self.elevator_doors[ "upper" ][ "right" ], self.elevator_doors[ "lower" ][ "right" ].origin[2] );
	door_instant_close( self.floor_doors[ "upper" ][ "left" ] );
	door_instant_close( self.floor_doors[ "upper" ][ "right" ] );
	wait( 0.05 );

	door_relink( self.elevator_doors[ "upper" ] );
	
	self elevator_disconnect_paths( "upper" );
	self elevator_connect_paths( "lower" );

	if ( level.elevator_failsafe )
	{
		door_instant_close( self.elevator_doors[ "lower" ][ "left" ] );
		door_instant_close( self.elevator_doors[ "lower" ][ "right" ] );
		door_instant_close( self.floor_doors[ "lower" ][ "left" ] );
		door_instant_close( self.floor_doors[ "lower" ][ "right" ] );

		self elevator_disconnect_paths( "lower" );
		return;
	}

	elevator_set_use_triggers_active( true, "main", "upper" );
	elevator_set_use_triggers_active( false, "lower" );

	wait( 0.1 );

	self.occupy_volume PlayLoopSound ( "amb_bg_bossa_vader", .3 );	
	self.fx SetClientFlag( level.const_flag_elevator_fx );

	self elevator_display_fx();
	
	while ( 1 )
	{
		self.obstruction_count = 0;

		self thread elevator_use_trigger_notify( "main" );
		self thread elevator_use_trigger_notify( "upper" );
		self thread elevator_use_trigger_notify( "lower" );

		self waittill( "trigger", id, player );

		// pre-move setup
		self elevator_set_use_triggers_active( false, "main", "upper", "lower" );
		self.use_triggers[ id ] PlaySound ( "evt_elev_btn" );

		self.occupy_volume halt_dogs( true );
		self thread elevator_door_close();
		self waittill ( "doors_closed" );

		riders = self elevator_get_players();

		// only move if under the max players
		if ( riders.size <= level.elevator_max_riders )
		{
			self.occupy_volume destroy_supply_crates();
			self.occupy_volume halt_dogs( true );

			self elevator_move();
			//self elevator_check_players( riders );
		}
		else
		{
			self PlaySound( "evt_elev_reject" );
			self.use_triggers[ "main" ] SetHintString( &"MP_ELEVATOR_OVER_MAX" );
			self elevator_set_use_triggers_active( true, "main" );
		}

		// post-move
		self elevator_door_open();
		self.occupy_volume halt_dogs( false );

		wait( level.elevator_cooldown_time );
		
		self.use_triggers[ "main" ] SetHintString( &"MP_USE_ELEVATOR" );

		if ( self.location == "upper" )
		{
			self elevator_set_use_triggers_active( true, "main", "lower" );
		}
		else
		{
			self elevator_set_use_triggers_active( true, "main", "upper" );
		}
	}
}

// self is the elevator
elevator_use_trigger_notify( id )
{
	self endon( "trigger" );
	
	self.use_triggers[ id ] waittill( "trigger", player );
	self notify( "trigger", id, player );
}

// self is the level
elevator_parts_enable_linkto()
{
	parts = GetEntArray( "elevator_part", "script_noteworthy" );

	for ( i = 0; i < parts.size; i++ )
	{
		if ( !IsDefined( parts[i].target ) )
		{
			continue;
		}

		if ( IsSubStr( parts[i].classname, "trigger" ) )
		{
			parts[i] EnableLinkTo();
		}
	}
}

// self is the elevator
elevator_parts_linkto()
{
	parts = GetEntArray( "elevator_part", "script_noteworthy" );

	// Links parts with a 'target'. The 'target' is considered the parent and the part is the child.
	for ( i = 0; i < parts.size; i++ )
	{
		if ( !IsDefined( parts[i].target ) )
		{
			continue;
		}

		parents = GetEntArray( parts[i].target, "targetname" );
		parent = GetClosest( parts[i].origin, parents );

		parts[i] LinkTo( parent );
	}
}

// self is the elevator
elevator_get_use_triggers()
{
	elevator_triggers = [];
		
	triggers = GetEntArray( "elevator_trigger_use", "targetname" );
	elevator_triggers[ "main" ] = GetClosest( self.origin, triggers );

	triggers = GetEntArray( "elevator_call_trigger_upper", "targetname" );
	elevator_triggers[ "upper" ] = GetClosest( self.origin, triggers );

	triggers = GetEntArray( "elevator_call_trigger_lower", "targetname" );
	elevator_triggers[ "lower" ] = GetClosest( self.origin, triggers );
	
	elevator_triggers[ "main" ] SetHintString( &"MP_USE_ELEVATOR" );
	elevator_triggers[ "upper" ] SetHintString( &"MP_CALL_ELEVATOR" );
	elevator_triggers[ "lower" ] SetHintString( &"MP_CALL_ELEVATOR" );

	return elevator_triggers;
}

// self is the elevator
elevator_set_use_triggers_active( active, string1, string2, string3 )
{
	self.use_triggers[ string1 ] use_trigger_set_active( active );
	
	if ( IsDefined( string2 ) )
	{
		self.use_triggers[ string2 ] use_trigger_set_active( active );
	}

	if ( IsDefined( string3 ) )
	{
		self.use_triggers[ string3 ] use_trigger_set_active( active );
	}
}

// self = the elevator
elevator_door_close()
{
	self endon( "door_obstruction" );

	// disconnect paths
	self elevator_disconnect_paths( self.location );

	// unlink and move
	door_move( self.floor_doors[ self.location ], "close" );
	wait ( level.elevator_door_stagger_time );
	door_move( self.elevator_doors[ self.location ], "close" );

	self PlaySound ( "evt_door_close" );	

	// doors close at the same rate, need to only wait for one to notify us
	self.elevator_doors[ self.location ][ "left" ] waittill( "movedone" );

	// relink to the elevator
	door_relink( self.elevator_doors[ self.location ] );

	self notify ( "doors_closed" );
}

// self = the elevator
elevator_door_open()
{
	// unlink and move
	door_move( self.floor_doors[ self.location ], "open" );

	wait ( level.elevator_door_stagger_time );
	self PlaySound ( "evt_door_open_1" );	

	door_move( self.elevator_doors[ self.location ], "open" );

	// doors open at the same rate, need to only wait for one to notify us
	self.elevator_doors[ self.location ][ "left" ] waittill( "movedone" );

	// relink to the elevator
	door_relink( self.elevator_doors[ self.location ] );

	// reconnect paths
	self elevator_connect_paths( self.location );
}

// self = the elevator
elevator_move()
{
	if ( IsDefined( self.script_float ) )
	{
		elevator_move_dist = self.script_float;
	}
	else
	{
		elevator_move_dist = level.elevator_move_dist;
	}

	if ( self.location == "upper" )
	{
		move_dist = ( elevator_move_dist * -1 );
	}
	else
	{
		move_dist = elevator_move_dist;
	}

	originalZ = self.origin[2];
	self MoveZ( move_dist, level.elevator_move_time, level.elevator_accel_time, level.elevator_decel_time );
	self thread elevator_destroy_corpses();

	self PlayLoopSound ( "evt_elev_run", .3 );	
	
	self thread watch_for_reached_floor();
	self thread watch_for_migration( originalZ, move_dist );

	self waittill ( "reachedFloor" );	
	self Stoploopsound ( .3 );

	if ( self.location == "upper" )
	{
		self.location = "lower";
	}
	else
	{
		self.location = "upper";
	}

	self elevator_display_fx();
}

watch_for_migration( originalZ, move_dist )
{
	self endon( "reachedFloor" );
	level waittill( "host_migration_begin" );
	
	// stop the elevator
	self MoveZ( 0, 0.05 );
	
	level waittill( "host_migration_end" );
	
	distanceMoved = self.origin[2] - originalZ;
	distanceLeft = move_dist - distanceMoved;

	self MoveZ( distanceLeft, level.elevator_move_time, level.elevator_accel_time, level.elevator_decel_time );
	
	self waittill("movedone");
	
	self notify( "reachedFloor" );
}

watch_for_reached_floor()
{
	self endon( "reachedFloor" );
	level endon( "host_migration_begin" );

	self waittill("movedone");
	
	self notify( "reachedFloor" );
}

// self is the elevator
elevator_handle_obstruction( ent )
{
	self notify ( "door_obstruction" );
	self.obstruction_count++;

	if ( IsDefined( ent ) && IsPlayer( ent ) && IsAlive( ent ) )
	{
		ent DoDamage( ent.maxhealth / 4, ent.origin, ent, ent, 0, "MOD_SUICIDE" );
	}

	self elevator_door_open();

	//Give elevators a pause before they attempt to close again.
	wait ( 0.5 * clamp( self.obstruction_count, 1, 6 ) );

	self thread elevator_door_close();
}

// self is the elevator
elevator_destroy_corpses()
{
	self endon( "reachedFloor" );

	for ( ;; )
	{
		self destroy_corpses();
		self.occupy_volume destroy_corpses();

		wait( 0.2 );
	}
}

// self is the elevator
elevator_get_players()
{
	riders = [];
	players = get_players();

	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if ( !IsDefined( player ) )
		{
			continue;
		}

		if ( player.sessionstate != "playing" )
		{
			continue;
		}

		if ( !IsAlive( player ) )
		{
			continue;
		}

		if ( !player IsTouching( self.occupy_volume  ) )
		{
			continue;
		}

		riders[ riders.size ] = player;
	}

	return riders;
}

// self is the elevator
elevator_check_players( riders )
{
	current_riders = self elevator_get_players();

	for ( i = 0; i < riders.size; i++ )
	{
		if ( !riders[i] elevator_check_escaped_player( current_riders ) )
		{
			riders[i] elevator_kill_player();
		}
	}
}

// self is the player to check
elevator_check_escaped_player( current_riders )
{
	for ( i = 0; i < current_riders.size; i++ )
	{
		if ( self == current_riders[i] )
		{
			return true;
		}
	}

	return false;
}

// self is the elevator
createKillCamEnt()
{
	x = getDvarFloatDefault( #"scr_elevator_killcam_x", 85.0 );
	y = getDvarFloatDefault( #"scr_elevator_killcam_y", 60.0 );
	z = getDvarFloatDefault( #"scr_elevator_killcam_z", 50.0 );
	
	killcamOrigin = self.origin + ( x, y, z );

	killCamEnt = spawn( "script_model", killcamOrigin );

	killCamEnt linkTo( self );

	return killCamEnt;
}

// self is the elevator
elevator_prox_think()
{
	if ( level.elevator_failsafe )
	{
		return;
	}

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
			if ( players[i] maps\mp\gametypes\_bot::bot_is_idle() && cointoss() )
			{
				if ( DistanceSquared( players[i].origin, self.origin ) < 256 * 256 )
				{
					players[i] SetScriptGoal( self.origin - ( 0, 0, 60 ), 64 );
					event = players[i] waittill_any_return( "goal", "bad_path", "death", "disconnect" );

					if ( event == "goal" )
					{
						players[i] PressUseButton( 1 );

						wait( 3 );
						
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

// self is the elevator
elevator_disconnect_paths( location )
{
	self.ai_clip[ location ] Solid();
	self.ai_clip[ location ] DisconnectPaths();
}

// self is the elevator
elevator_connect_paths( location )
{
	self.ai_clip[ location ] ConnectPaths();
	self.ai_clip[ location ] NotSolid();
}

// self is the elevator
elevator_display_fx()
{
	if ( self.location == "lower" )
	{
		self.displays[ "interior" ] SetClientFlag( level.const_flag_elevator_floor_fx );

		if ( IsDefined( self.displays[ "upper" ] ) )
		{
			self.displays[ "upper" ] SetClientFlag( level.const_flag_elevator_floor_fx );
		}

		if ( IsDefined( self.displays[ "lower" ] ) )
		{
			self.displays[ "lower" ] SetClientFlag( level.const_flag_elevator_floor_fx );
		}
	}
	else
	{
		self.displays[ "interior" ] ClearClientFlag( level.const_flag_elevator_floor_fx );

		if ( IsDefined( self.displays[ "upper" ] ) )
		{
			self.displays[ "upper" ] ClearClientFlag( level.const_flag_elevator_floor_fx );
		}

		if ( IsDefined( self.displays[ "lower" ] ) )
		{
			self.displays[ "lower" ] ClearClientFlag( level.const_flag_elevator_floor_fx );
		}
	}
}

//---------------------------------------------------------------------------------------------------
// DOOR OBJECT FUNCTIONS
//---------------------------------------------------------------------------------------------------

// self is the elevator
door_get_elevator_doors()
{
	doors = [];
	doors[ "upper" ] = [];
	doors[ "lower" ] = [];

	parts = GetEntArray( "elevator_door_upper_right", "targetname" );
	doors[ "upper" ][ "right" ] = GetClosest( self.origin, parts );

	parts = GetEntArray( "elevator_door_upper_left", "targetname" );
	doors[ "upper" ][ "left" ] = GetClosest( self.origin, parts );

	parts = GetEntArray( "elevator_door_lower_right", "targetname" );
	doors[ "lower" ][ "right" ] = GetClosest( self.origin, parts );

	parts = GetEntArray( "elevator_door_lower_left", "targetname" );
	doors[ "lower" ][ "left" ] = GetClosest( self.origin, parts );

	// hold on to the obstruction triggers
	parts = GetEntArray( "elevator_door_trigger_upper_right", "targetname" );
	doors[ "upper" ][ "right" ].trigger = GetClosest( self.origin, parts );

	parts = GetEntArray( "elevator_door_trigger_upper_left", "targetname" );
	doors[ "upper" ][ "left" ].trigger = GetClosest( self.origin, parts );

	parts = GetEntArray( "elevator_door_trigger_lower_right", "targetname" );
	doors[ "lower" ][ "right" ].trigger = GetClosest( self.origin, parts );

	parts = GetEntArray( "elevator_door_trigger_lower_left", "targetname" );
	doors[ "lower" ][ "left" ].trigger = GetClosest( self.origin, parts );

	return doors;
}

// self is the elevator
door_get_floor_doors()
{
	doors = [];
	doors[ "upper" ] = [];
	doors[ "lower" ] = [];

	parts = GetEntArray( "door_upper_right", "targetname" );
	doors[ "upper" ][ "right" ] = GetClosest( self.origin, parts );

	parts = GetEntArray( "door_upper_left", "targetname" );
	doors[ "upper" ][ "left" ] = GetClosest( self.origin, parts );

	parts = GetEntArray( "door_lower_right", "targetname" );
	doors[ "lower" ][ "right" ] = GetClosest( self.origin, parts );

	parts = GetEntArray( "door_lower_left", "targetname" );
	doors[ "lower" ][ "left" ] = GetClosest( self.origin, parts );

	return doors;
}

door_set_origins( doors )
{
	diff = doors[ "left" ].origin - doors[ "right" ].origin;
	offset = diff / 4;

	doors[ "left" ].origin_open = doors[ "left" ].origin;
	doors[ "left" ].origin_closed = doors[ "left" ].origin - offset;

	doors[ "right" ].origin_open = doors[ "right" ].origin;
	doors[ "right" ].origin_closed = doors[ "right" ].origin + offset;

	doors[ "left" ] OverrideLightingOrigin();
	doors[ "right" ] OverrideLightingOrigin();
}

// self is the elevator
door_instant_close( door, z_origin )
{
	door Unlink();
	
	if ( !IsDefined( z_origin ) )
	{
		z_origin = door.origin_closed[2];
	}

	door.origin = ( door.origin_closed[0], door.origin_closed[1], z_origin );
}

// self is the elevator
door_move( doors, direction )
{
	doors[ "left" ] Unlink();
	doors[ "right" ] Unlink();

	if ( direction == "open" )
	{
		doors[ "left" ] MoveTo( doors[ "left" ].origin_open, level.elevator_door_move_time );
		doors[ "right" ] MoveTo( doors[ "right" ].origin_open, level.elevator_door_move_time );
	}
	else
	{
		doors[ "left" ] MoveTo( doors[ "left" ].origin_closed, level.elevator_door_move_time );
		doors[ "right" ] MoveTo( doors[ "right" ].origin_closed, level.elevator_door_move_time );

		// do checks for obstructions
		if ( IsDefined( doors[ "left" ].trigger ) )
		{
			doors[ "left" ].trigger thread trigger_obstruction_think( doors[ "left" ], self );
		}

		if ( IsDefined( doors[ "right" ].trigger ) )
		{
			doors[ "right" ].trigger thread trigger_obstruction_think( doors[ "right" ], self );
		}
	}

	doors[ "left" ] thread destroy_stuck_weapons();
	doors[ "right" ] thread destroy_stuck_weapons();
	doors[ "left" ] thread door_destroy_C4();
	doors[ "right" ] thread door_destroy_C4();
	doors[ "left" ] destroy_corpses( 64 );
	doors[ "right" ] destroy_corpses( 64 );
}

// self is the elevator
door_relink( doors )
{
	assert( doors[ "left" ].target == "script_elevator" );
	assert( doors[ "right" ].target == "script_elevator" );

	doors[ "left" ] LinkTo( self );
	doors[ "right" ] LinkTo( self );
}

//---------------------------------------------------------------------------------------------------
// TRIGGER FUNCTIONS
//---------------------------------------------------------------------------------------------------

// self is the use trigger 
use_trigger_set_active( active )
{
	if ( active )
	{
		self SetVisibleToAll();
	}
	else
	{
		self SetInvisibleToAll();
	}
}

//self is the trigger attached to this door
trigger_obstruction_think( door, elevator )
{
	elevator endon ( "doors_closed" );
	elevator endon ( "door_obstruction" );

	self thread trigger_obstruction_nonplayer_think( elevator );
	self waittill ( "trigger", ent );

	elevator thread elevator_handle_obstruction( ent );
}


//self is the trigger attached to this door
trigger_obstruction_nonplayer_think( elevator )
{
	elevator endon ( "doors_closed" );
	elevator endon ( "door_obstruction" );

	while ( 1 )
	{
		wait( 0.2 );

		self destroy_tactical_insertions();
		self destroy_equipment();
		self destroy_supply_crates();
		self destroy_corpses( 64 );
	}
}

//---------------------------------------------------------------------------------------------------
// MISC/HELPER FUNCTIONS
//---------------------------------------------------------------------------------------------------

shaft_kill_trig_init()
{
	shaft_kill_triggers = GetEntArray( "shaft_kill_trig", "targetname" );

	/#
		PrintLn( shaft_kill_triggers.size + " elevator shaft kill triggers in map" );
	#/

	if( shaft_kill_triggers.size > 0 )
	{
		array_thread( shaft_kill_triggers, ::shaft_kill_trig_think );
	}
}

//self is the kill trigger at the bottom of the elevaot shaft
shaft_kill_trig_think()
{
	while( 1 )
	{
		self waittill( "trigger", ent );
		ent elevator_kill_player();
	}
}

// self is the player
elevator_kill_player()
{
	if ( IsDefined( self ) && IsPlayer( self ) )
	{
		self DoDamage( self.health * 2, self.origin, self, self, 0, "MOD_SUICIDE" );
	}
}

// self is the trigger attached to the edge of a closing elevator door
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

// self is the door ent
destroy_stuck_weapons()
{
	self endon ( "movedone" );

	while( 1 )
	{
		wait( 0.2 );
	    weapons = GetEntArray( "sticky_weapon", "targetname" );
    
	    origin = self GetPointInBounds( 0.0, 0.0, -0.6 );
	    z_cutoff = origin[2];
		    
	    for( i = 0 ; i < weapons.size ; i++ )
	    {
		    weapon = weapons[i];
    
		    if( !weapon IsTouching( self ) ) 
		    {
			    if ( !IsDefined( self.trigger ) )
			    {
				    continue;
			    }
			    else if ( !weapon IsTouching( self.trigger ) )
			    {
				    continue;
			    }
		    }
			weapon delete();
	    }
	}
}

// self is the door ent
door_destroy_C4()
{
	self endon ( "movedone" );

	while( 1 )
	{
		wait( 0.2 );
		grenades = GetEntArray( "grenade", "classname" );

		for( i = 0; i < grenades.size; i++ )
		{
			item = grenades[i];

			if( !IsDefined( item.name ) )
			{
				continue;
			}

			if( item.name != "satchel_charge_mp" )
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
				if ( !IsDefined( self.trigger ) )
				{
					continue;
				}
				else if ( !item IsTouching( self.trigger ) )
				{
					continue;
				}
			}

			watcher = item.owner getWatcherForWeapon( item.name );

			if( !IsDefined( watcher ) )
			{
				continue;
			}

			watcher thread maps\mp\gametypes\_weaponobjects::waitAndDetonate( item, 0.0, undefined );
		}
	}
}

// self is the trigger attached to the edge of a closing elevator door
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

// self is the trigger attached to the edge of a closing elevator door
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

// self is an entity to check if a corpse is touching
destroy_corpses( radius )
{
	if ( !IsDefined( radius ) )
	{
		radius = 0;
	}

	corpses = GetCorpseArray();

	for ( i = 0; i < corpses.size; i++ )
	{
		if( corpses[i] IsTouching( self ) ) 
		{
			corpses[i] delete();
		}
		else if ( DistanceSquared( corpses[i].origin, self.origin ) < radius * radius )
		{
			corpses[i] delete();
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

insideElevatorKillcam()
{
	for ( i = 0; i < level.elevators.size; i++ )
	{
		assert( IsDefined( level.elevators[i].occupy_volume ) );

		if ( self isTouching( level.elevators[i].occupy_volume ) )
		{
			return ( level.elevators[i].killcament );
		}
	}

	return undefined;
}

// self is a player in his death animation
mp_hotel_ragdoll_override()
{
	for ( i = 0; i < level.elevators.size; i++ )
	{
		if ( self IsTouching( level.elevators[i].occupy_volume ) )
		{
			return true;
		}
	}

	return false;
}

halt_dogs( halt )
{
	if ( !IsDefined( level.dogs ) || level.dogs.size <= 0 )
	{
		return;
	}

	for ( i = 0; i < level.dogs.size; i++ )
	{
		dog = level.dogs[i];

		if ( !IsDefined( dog ) )
		{
			continue;
		}

		if ( !IsAlive( dog ) )
		{
			continue;
		}

		if ( !dog IsTouching( self ) )
		{
			continue;
		}

		dog.halt_patrol = halt;
		dog.ignoreall = halt;
	}
}