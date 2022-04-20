#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;


////////////////////////////////////////////////////////////////////////////
// General AI behavior manipulation



hold_fire()
{
	if( isalive( self ) )
	{
		self.pacifist = 1;
		self.ignoreall = 1;
	}
}

resume_fire()
{
	if( isalive( self ) )
	{
		self.pacifist = 0;
		self.ignoreall = 0;
	}
}

go_to_node_by_name( node_name )
{
	node = getnode( node_name, "targetname" );
	self setgoalnode( node );
}

go_to_node_by_noteworthy( node_name )
{
	node = getnode( node_name, "script_noteworthy" );
	self setgoalnode( node );
}

force_go_to_node_by_name( node_name )
{
	old_radius = self.goalradius;
	self.goalradius = 32;
	old_pacifist = self.pacifist;
	old_ignoreall = self.ignoreall;
	self.pacifist = 1;
	self.ignoreall = 1;

	node = getnode( node_name, "targetname" );
	self setgoalnode( node );
	self waittill( "goal" );

	self.goalradius = old_radius;
	self.pacifist = old_pacifist;
	self.ignoreall = old_ignoreall;
}

////////////////////////////////////////////////////////////////////////////
// Spawner behavior

force_to_goal()
{
	self endon( "death" );

	old_radius = self.goalradius;
	self.goalradius = 4;

	self waittill( "goal" );

	wait( 2 );

	self.goalradius = old_radius;
}

reset_radius_at_goal()
{	
	self endon( "death" );

	self.goalradius = 64;

	self waittill( "goal" );

	self.goalradius = 1024;
}

one_hit_kill()
{
	self.health = 1;
}

use_low_goalradius()
{
	self.goalradius = 32;
}

use_patrol_anim()
{
	self.disableArrivals = true;
	self.disableExits = true;

	self.animname = "generic";
	self set_generic_run_anim( "patrol_walk" );

	self waittill_either( "damage", "resume_attack" );
	self clear_run_anim();
}

use_patrol_anim_at_goal()
{
	self.goalradius = 32;
	self waittill( "goal" );
	self.animname = "generic";
	self set_generic_run_anim( "patrol_walk" );

	self.disableArrivals = true;
	self.disableExits = true;

	self waittill_either( "damage", "resume_attack" );
	self clear_run_anim();
}

no_grenade()
{
	self.grenadeammo = 0; 
}

no_long_death()
{
	self.a.disableLongDeath = true;
}

b2_rushers()
{
	self endon( "death" );
	self.grenadeammo = 0; 
	self.a.disableLongDeath = true;
	self hold_fire();
	self.goalradius = 256;

	self thread alerted_by_others();
	self thread resume_fire_at_goal();
	self waittill( "damage", amount, inflictor, direction );
	//self dodamage( self.health + 100, direction, inflictor );
	level notify( "player_interruption" );
}

alerted_by_others()
{
	level waittill( "player_interruption" );
	//wait( randomfloat( 0.5 ) + 0.5 );
	self resume_fire();
	self.goalradius = 1024;
}

resume_fire_at_goal()
{
	self endon( "death" );
	self waittill( "goal" );

	self resume_fire();
	self.goalradius = 1024;
}

b2_rushers_2()
{
	self endon( "death" );
	self.grenadeammo = 0; 
	self.a.disableLongDeath = true;
	self hold_fire();
	self.goalradius = 16;

	wait( 5 );
	wait( randomfloat( 1 ) );
	self resume_fire();
	self.goalradius = 1024;
}


////////////////////////////////////////////////////////////////////////////
// Animation related


getting_killed( by_who, from_position )
{
	gunner = undefined;
	gunner_position = (0,0,0);

	if( isdefined( by_who ) )
	{
		gunner = by_who;

		if( isdefined( from_position ) )
		{
			gunner_position = from_position;
		}
		else
		{
			gunner_position = by_who.origin;
		}
	}
	else
	{
		friendly_ais = getaiarray( "allies" );
		if( friendly_ais.size == 0 )
		{
			//iprintlnbold( "Need at least one live friendly AI" );
			return;
		}
		gunner = friendly_ais[0];

		if( !isdefined( from_position ) )
		{
			//iprintlnbold( "Need to specify a firing position" );
			return;
		}
		gunner_position = from_position;
	}

	if( isdefined( gunner ) )
	{
		PlayFxOnTag( level._effect["muzzle_flash"], gunner, "tag_flash" );
	}
	BulletTracer( gunner_position + (0,0,60), self.origin + (0,0,60) );
	wait( 0.05 );
	if( isdefined( gunner ) )
	{
		PlayFxOnTag( level._effect["muzzle_flash"], gunner, "tag_flash" );
	}
	BulletTracer( gunner_position + (0,0,60), self.origin + (2,2,58) );
	wait( 0.05 );
	if( isdefined( gunner ) )
	{
		PlayFxOnTag( level._effect["muzzle_flash"], gunner, "tag_flash" );
	}
	BulletTracer( gunner_position + (0,0,60), self.origin + (0,0,61) );
	wait( 0.05 );
	if( isdefined( gunner ) )
	{
		PlayFxOnTag( level._effect["muzzle_flash"], gunner, "tag_flash" );
	}
	BulletTracer( gunner_position + (0,0,60), self.origin + (2,2,58) );

	possible_tag_array = [];
	possible_tag_array[0] = "J_Neck";
	possible_tag_array[1] = "J_Head";
	possible_tag_array[2] = "TAG_WEAPON_CHEST";
	possible_tag_array[3] = "J_Shoulder_LE";
	possible_tag_array[4] = "J_Shoulder_RI";
	possible_tag_array[5] = "J_ShoulderRaise_LE";
	possible_tag_array[6] = "J_ShoulderRaise_RI";

	possible_tag_array = array_randomize( possible_tag_array );

	PlayFxOnTag( level._effect["flesh_hit"], self, possible_tag_array[0] );  

	self dodamage( self.health + 100, gunner_position, gunner );

	wait( 0.1 );
	PlayFxOnTag( level._effect["flesh_hit"], self, possible_tag_array[1] );  
	wait( 0.1 );
	PlayFxOnTag( level._effect["flesh_hit"], self, possible_tag_array[2] );  
}


start_teleport_ai_custom( start_name, ai_names )
{
	// grab specified friendly ai
	friendly_ai = getentarray( ai_names, "script_noteworthy" );

	// Grab the starting points, should be script_structs
	ai_starts = getstructarray( start_name + "_ai", "targetname");

	assertex( ai_starts.size >= friendly_ai.size, "Need more start positions for ai!" ); 

	for (i = 0; i < ai_starts.size; i++)
	{
		for (j = 0; j < friendly_ai.size; j++)
		{
			if( ai_starts[i].script_noteworthy == friendly_ai[j].targetname )
			{
				// found a match

				// teleport the ai. make them use the struct's angles if they exist
				if( IsDefined( ai_starts[i].angles ) )
				{
					friendly_ai[j] forceteleport( ai_starts[i].origin, ai_starts[i].angles );		
				}
				else
				{
					friendly_ai[j] forceteleport( ai_starts[i].origin );	
				}
		
				// so they don't run back to their original spot
				friendly_ai[j] SetGoalPos(ai_starts[i].origin);

				continue;
			}
		}
	}	
}


////////////////////////////////////////////////////////////////////////////
// Misc

hit_trigger_by_name( trigger_name )
{
	players = get_players();
	trigger = getent( trigger_name, "targetname" );
	trigger UseBy( players[0] );
}

hit_trigger_by_noteworthy( trigger_name )
{
	players = get_players();
	trigger = getent( trigger_name, "script_noteworthy" );
	trigger UseBy( players[0] );
}

wait_for_trigger_by_name( trigger_name )
{
	trigger = getent( trigger_name, "targetname" );
	trigger waittill( "trigger" );
}

wait_for_trigger_by_noteworthy( trigger_name )
{
	trigger = getent( trigger_name, "script_noteworthy" );
	trigger waittill( "trigger" );
}

single_rpg_shot( start_pos, end_pos, time, fx_name )
{
	rocket = spawn( "script_model", start_pos );
	rocket setmodel( "tag_origin" );
	rocket moveTo( end_pos, time );
	playfxontag(level._effect["rpg_trail"], rocket, "tag_origin" );
	wait( time );
	playfx( level._effect[fx_name], end_pos );
	rocket delete();
}

entities_exist_by_name( target_name )
{
	ents = getentarray( target_name, "targetname" );
	if( isdefined( ents ) && ents.size > 0 )
	{
		return true;
	}
	return false;
}

all_entities_exist_by_name( target_name1, target_name2, target_name3, target_name4 )
{
	ents1 = getentarray( target_name1, "targetname" );
	if( !isdefined( ents1 ) )
	{
		return false;
	}

	if( isdefined( target_name2 ) )
	{
		ents2 = getentarray( target_name2, "targetname" );
		if( !isdefined( ents2 ) )
		{
			return false;
		}
	}

	if( isdefined( target_name3 ) )
	{
		ents3 = getentarray( target_name3, "targetname" );
		if( !isdefined( ents3 ) )
		{
			return false;
		}
	}

	if( isdefined( target_name4 ) )
	{
		ents4 = getentarray( target_name4, "targetname" );
		if( !isdefined( ents4 ) )
		{
			return false;
		}
	}

	return true;
}


fade_out( time )
{
	if( !isdefined( level.fade_out_overlay ) )
	{
		level.fade_out_overlay = NewHudElem();
		level.fade_out_overlay.x = 0;
		level.fade_out_overlay.y = 0;
		level.fade_out_overlay.horzAlign = "fullscreen";
		level.fade_out_overlay.vertAlign = "fullscreen";
		level.fade_out_overlay.foreground = false;  // arcademode compatible
		level.fade_out_overlay.sort = 50;  // arcademode compatible
		level.fade_out_overlay SetShader( "black", 640, 480 );
	}

	// start off invisible
	level.fade_out_overlay.alpha = 0;

	level.fade_out_overlay fadeOverTime( time );
	level.fade_out_overlay.alpha = 1;
	wait( time );
}


fade_in( time, delay_time )
{
	if( isdefined( delay_time ) )
	{
		wait( delay_time );
	}

	if( !isdefined( level.fade_out_overlay ) )
	{
		level.fade_out_overlay = NewHudElem();
		level.fade_out_overlay.x = 0;
		level.fade_out_overlay.y = 0;
		level.fade_out_overlay.horzAlign = "fullscreen";
		level.fade_out_overlay.vertAlign = "fullscreen";
		level.fade_out_overlay.foreground = false;  // arcademode compatible
		level.fade_out_overlay.sort = 50;  // arcademode compatible
		level.fade_out_overlay SetShader( "black", 640, 480 );
	}

	level.fade_out_overlay.alpha = 1;

	level.fade_out_overlay fadeOverTime( time );
	level.fade_out_overlay.alpha = 0;
	wait( time );
}

say_dialogue( theLine, delay_time )
{
	if( isdefined( delay_time ) )
	{
		wait( delay_time );
	}
	
	if( isplayer( self ) )
	{
		self.animname = "mason";	
	}
	
	if( !isdefined( self.animname ) )
	{
		if( self == level.hudson )
		{
			self.animname = "hudson";
		}
		else
		{
			self.animname = "generic";
		}
	}

	/#
	add_dialogue_line( self.animname, theLine );
	#/
	
	self anim_single( self, theLine );
}

shoot_and_kill( enemy )
{
	self endon( "death" );
	enemy endon( "death" );

	//self.perfectAim = true;
	enemy.health = 1;
	self thread shoot_at_target( enemy );
	enemy waittill( "death" );
	//self.perfectAim = false;

	self thread stop_shoot_at_target();
	self notify( "enemy_killed" );
}


waittill_zone_is_cleared( zone_name, trigger_override_name, trigger_to_hit_name )
{
	if( isdefined( trigger_override_name ) )
	{
		level endon( trigger_override_name );
		trigger_override = getent( trigger_override_name, "targetname" );
		level thread trigger_notify_level( trigger_override );
	}

	trigger = getent( zone_name, "targetname" );

	while( 1 )
	{
		enemies_remain_in_zone = false;
		enemies = getaiarray( "axis" );
		for( i = 0; i < enemies.size; i++ )
		{
			if( enemies[i] istouching( trigger ) )
			{
				enemies_remain_in_zone = true;
			}
		}

		if( enemies_remain_in_zone == false )
		{
			return;
		}

		wait( 0.1 );
	}

	if( isdefined( trigger_to_hit_name ) )
	{
		hit_trigger_by_name( trigger_to_hit_name );
	}
}

trigger_notify_level( trigger )
{
	trigger waittill( "trigger" );
	level notify( trigger.targetname );
}

trigger_flag_set( trigger_name, flag_name )
{
	trigger = getent( trigger_name, "targetname" );
	trigger waittill( "trigger" );

	flag_set( flag_name );
}

update_objective_position_by_trigger( trigger_name, objective_num )
{
	trigger = getent( trigger_name, "targetname" );
	trigger waittill( "trigger" );

	if( isdefined( trigger.target ) )
	{
		struct_pos = getstruct( trigger.target, "targetname" );
		origin = struct_pos.origin;

		Objective_Position( objective_num, origin );
	}
}

detachWeapon( weapon )
{
	self.a.weaponPos[self.weaponInfo[weapon].position] = "none";
	self.weaponInfo[weapon].position = "none";
}


attachWeapon( weapon, position )
{
	self.weaponInfo[weapon].position = position;
	self.a.weaponPos[position] = weapon;
}

pbr_prep_model()
{
	self.extra_model_1 = spawn( "script_model", self.origin );
	self.extra_model_1.angles = self.angles;
	self.extra_model_1 setmodel( "t5_veh_boat_pbr_set01" );
	self.extra_model_1 linkto( self, "tag_origin_animate" );

	self.extra_model_2 = spawn( "script_model", self.origin );
	self.extra_model_2.angles = self.angles;
	self.extra_model_2 setmodel( "t5_veh_boat_pbr_stuff" );
	self.extra_model_2 linkto( self, "tag_origin_animate" );
}

pbr_prep_model_special()
{
	self.extra_model_3 = spawn( "script_model", self.origin );
	self.extra_model_3.angles = self.angles;
	self.extra_model_3 setmodel( "t5_veh_boat_pbr" );
	self.extra_model_3 linkto( self, "tag_origin_animate" );
}


playfx_on_array_angled( pos_array, fx_id, ender )
{
	model_array = [];
	
	for( i = 0; i < pos_array.size; i++ )
	{
		model_array[i] = spawn( "script_model", pos_array[i].origin );
		model_array[i].angles = pos_array[i].angles;
		model_array[i] setmodel( "tag_origin" ); 
		playfxontag( fx_id, model_array[i], "tag_origin" );
	}
	
	// clean up
	level waittill( ender );
	for( i = 0; i < model_array.size; i++ )
	{
		model_array[i] delete();
	}
}

force_move_guy( guy, final_pos, final_angle, duration, lock_in_place )
{
	guy.mover = spawn( "script_origin", guy.origin );
	guy.mover.angles = guy.angles;
	guy linkto( guy.mover );
	
	guy.mover moveto( final_pos, duration, 0.1, 0.1 );
	guy.mover rotateto( final_angle, duration, 0.1, 0.1 );
	wait( duration );
	
	if( isdefined( lock_in_place ) && lock_in_place == true )
	{
		return;
	}
	
	guy unlink();
	guy.mover delete();
}

ai_corpses_cleanup()
{
	corpses = entsearch( level.CONTENTS_CORPSE, get_players()[0].origin, 10000 );
	for( i = 0; i < corpses.size; i++ )
	{
		corpses[i] delete();
	}
}

waittill_either_trigger( trigger_1, trigger_2 )
{
	trigger_1._triggered = false;
	trigger_2._triggered = false;
	level thread waittill_trigger_special( trigger_1, trigger_2 );
	level thread waittill_trigger_special( trigger_2, trigger_1 );
	while( trigger_1._triggered == false && trigger_2._triggered == false )
	{
		wait( 0.05 );
	}
	if( trigger_1._triggered == true )
	{
		return( trigger_1 );
	}
	else
	{
		return( trigger_2 );
	}
}

waittill_trigger_special( trigger, trigger_other )
{
	trigger endon( "reset_hit_trigger" );
	trigger waittill( "trigger" );
	trigger_other notify( "reset_hit_trigger" );

	trigger._triggered = true;
}

reduce_to_1_health()
{
	self.health = 1;
}

teleport_ai_single( ai_targetname, node_targetname )
{
	guy = getent( ai_targetname, "targetname" );
	ai_start = getnode( node_targetname, "targetname");
	if( !isdefined( ai_start ) )
	{
		ai_start = getstruct( node_targetname, "targetname");
	}
	
	guy unlink();
	guy StopAnimScripted();
	
	if( isdefined( ai_start.angles ) )
	{
		guy forceteleport( ai_start.origin, ai_start.angles );		
		
		// Hack
		/*
		linker = Spawn( "script_origin", guy.origin );
		guy Linkto( linker );
		linker MoveTo( ai_start.origin, 1.0, 0.1, 0.1 );
		linker RotateTo( ai_start.angles, 1.0, 0.1, 0.1 );
		linker waittill( "movedone" );
		guy unlink();
		linker delete();
		*/	
	}
	else
	{
		guy forceteleport( ai_start.origin );	
	}
}

teleport_first_player( node_targetname )
{
	player_start = getnode( node_targetname, "targetname");
	if( !isdefined( player_start ) )
	{
		player_start = getstruct( node_targetname, "targetname");
	}	

	player = get_players()[0];
	player setOrigin( player_start.origin );
	if( IsDefined( player_start.angles ) )
	{
		player setPlayerAngles( player_start.angles );
	}	
}

set_speed_limit_zones( trigger_name, ender, allow_run )
{
	level endon( ender );
	
	zones = getentarray( trigger_name, "targetname" );
	
	// some basic error checking
	if( zones.size == 0 )
	{
		//iprintlnbold( "no zones found" );
		return;
	}
	
	for( i = 0; i < zones.size; i++ )
	{
		if( !isdefined( zones[i].speed ) )
		{
			//iprintlnbold( "zone without speed defined" );
			return;
		}
	}
	
	self.move_speed = 1.0; 		// current speed
	self.target_speed = 1.0;	// target speed
	
	while( 1 )
	{
		// .speed must be an integer, so we set the player speed to 100 here instead of 1
		// then adjust it back later.
		slowest_allowed_speed = 100;
		for( i = 0; i < zones.size; i++ )
		{
			// if player is touching multiple zones, take the slowest speed
			if( self istouching( zones[i] ) && zones[i].speed < slowest_allowed_speed )
			{
				slowest_allowed_speed = zones[i].speed;
			}
		}
		slowest_allowed_speed *= 0.01;
		
		// if player has changed zone and needs to change speed
		// this could be result of entering/leaving a zone or going
		// from one zone to another with different speeds
		if( slowest_allowed_speed != self.target_speed )
		{
			//iprintlnbold( "change speed to " + slowest_allowed_speed );
			
			// if the player goes into a low speed zone from a normal speed zone, force him to crouch
			
			if( isdefined( allow_run ) && allow_run == true )
			{
				// no change
			}
			else
			{
				if( slowest_allowed_speed < 1.0 && self.target_speed == 1.0 )
				{
					self AllowStand( false );
					self AllowSprint( false );
					if( self GetStance() == "stand" )
					{
						self SetStance( "crouch" );
					}
				}
			
				// if the player goes into a normal speed zone from a low speed zone, allow stand
				if( slowest_allowed_speed == 1.0 && self.target_speed < 1.0 )
				{
					self AllowStand( true );
					self AllowSprint( true );	
				}
			}
			
			// change the speed. This change will take place over 1 second
			self notify( "reset_move_speed" );
			self.target_speed = slowest_allowed_speed;
			self thread set_player_speed( self.target_speed, 1.0, ender, "reset_move_speed" );
		}
		
		wait( 0.1 );
	}
}

// Required parameter: speed (0-1.0)
// Speed change is lerped if time is defined, otherwise it's instant
set_player_speed( speed, time, ender1, ender2 )
{
	if( isdefined( ender1 ) )
	{
		self endon( ender1 );
	}

	if( isdefined( ender2 ) )
	{
		self endon( ender2 );
	}
	
	if( !isdefined( self.move_speed ) )
	{
		self.move_speed = 1.0;
	}
	
	if( !isdefined( time ) )
	{
		self.move_speed = speed;
		self SetMoveSpeedScale( self.move_speed ); 
	}
	else
	{
		// lerp the speed over time
		intervals = time * 20;
		increment = ( speed - self.move_speed ) / intervals;
		for( i = 0; i < intervals; i++ )
		{
			self.move_speed = self.move_speed + increment;
			self SetMoveSpeedScale( self.move_speed ); 
		}
		self SetMoveSpeedScale( speed ); 
	}
}

// why this function is not in _utility is beyond me
take_player_weapons()
{
	self.weaponInventory = self GetWeaponsList();
	self.lastActiveWeapon = self GetCurrentWeapon();

	self.weaponAmmo = [];
	
	for( i = 0; i < self.weaponInventory.size; i++ )
	{
		weapon = self.weaponInventory[i];
		
		self.weaponAmmo[weapon]["clip"] = self GetWeaponAmmoClip( weapon );
		self.weaponAmmo[weapon]["stock"] = self GetWeaponAmmoStock( weapon );
	}
	
	self TakeAllWeapons();
}

giveback_player_weapons()
{
	ASSERTEX( IsDefined( self.weaponInventory ), "player.weaponInventory is not defined - did you run take_player_weapons() first?" );
	
	for( i = 0; i < self.weaponInventory.size; i++ )
	{
		weapon = self.weaponInventory[i];
		
		self GiveWeapon( weapon );
		self SetWeaponAmmoClip( weapon, self.weaponAmmo[weapon]["clip"] );
		self SetWeaponAmmoStock( weapon, self.weaponAmmo[weapon]["stock"] );
	}
	
	// if we can't figure out what the last active weapon was, try to switch a primary weapon
	if( self.lastActiveWeapon != "none" )
	{
		self SwitchToWeapon( self.lastActiveWeapon );
	}
	else
	{
		primaryWeapons = self GetWeaponsListPrimaries();
		if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
		{
			self SwitchToWeapon( primaryWeapons[0] );
		}
	}
}

ai_suicide( killer )
{
	if( isdefined( killer ) )
	{
		self DoDamage( self.health + 100, killer.origin, killer );
	}
	else
	{
		self DoDamage( self.health + 100, level.barnes.origin, level.barnes );
	}
}


//---------------------------------------------------------------------------
// floating objects

setup_floating_objects()
{
	// -- objects = getentarray( "floating_branch", "targetname" ); // wwilliams: housekeeping, floating items in the village
	// -- array_thread( objects, ::bobbing_on_water ); // wwilliams: housekeeping, turning off floating objects in the village

	// floating boats behave differently
	sampans_small = getentarray( "sampan_small", "targetname" );
	array_thread( sampans_small, ::bobbing_on_water, 3 );
	array_thread( sampans_small, ::tilt_on_water );

	sampans_medium = getentarray( "sampan_medium", "targetname" );
	array_thread( sampans_medium, ::bobbing_on_water, 4 );
	array_thread( sampans_medium, ::tilt_on_water );

	sampan_large = getentarray( "sampan_large", "targetname" );
	array_thread( sampan_large, ::bobbing_on_water, -9 );
	array_thread( sampan_large, ::tilt_on_water );
}

bobbing_on_water( offset )
{
	if( !isdefined( offset ) )
	{
		offset = -3;
	}

	water_height = GetWaterHeight( self.origin );

	if( water_height > 1000 || water_height < -1000 )
	{
		return;
	}

	origin_at_water = ( self.origin[0], self.origin[1], water_height + offset );
	origin_below_water = origin_at_water + ( 0, 0, -3 );
	bobbing_time = 2;

	self.origin = origin_at_water;
	
	wait( randomfloat( 1.0 ) );

	while( 1 )
	{
		self moveto( origin_below_water, bobbing_time, 0.5, 0.5 );
		self waittill( "movedone" );
		self moveto( origin_at_water, bobbing_time, 0.5, 0.5 );
		self waittill( "movedone" );
	}
}

tilt_on_water()
{
	water_height = GetWaterHeight( self.origin );

	if( water_height > 1000 || water_height < -1000 )
	{
		return;
	}

	initial_angle = self.angles;
	
	angle_rotate_degree = randomfloat( 2 ) + 2;
	angle_rotate_time = angle_rotate_degree * 0.5;

	max_angle_left = initial_angle + ( 0, 0, angle_rotate_degree );
	max_angle_right = initial_angle + ( 0, 0, -1 * angle_rotate_degree );

	wait( randomfloat( 0.5 ) );
	
	while( 1 )
	{
		self rotateto( max_angle_left, angle_rotate_time, 0.1, 0.1 );
		self waittill( "rotatedone" );
		wait( 0.3 );
		self rotateto( max_angle_right, angle_rotate_time * 2, 0.1, 0.1 );
		self waittill( "rotatedone" );
		wait( 0.3 );
		self rotateto( initial_angle, angle_rotate_time, 0.1, 0.1 );
		self waittill( "rotatedone" );
	}
}

// when the player hits the trigger, that objective updates its position
// to where the struct is at
update_obj_position_with_trigger( obj_num, trigger_name, struct_name )
{
	trigger_wait( trigger_name );
	level notify( "stop_following_barnes_obj" );
	struct_obj = getstruct( struct_name, "targetname" );
	Objective_Position( obj_num, struct_obj.origin );
}

move_to_struct( struct_name, time )
{
	struct = getstruct( struct_name, "targetname" );
	
	self moveto( struct.origin, time, 0.05, 0.05 );
	if( isdefined( struct.angles ) )
	{
		self rotateto( struct.angles, time, 0.05, 0.05 );
	}
	
	self waittill( "movedone" );
}

get_pos_on_water_level()
{
	neck_pos = self GetTagOrigin( "tag_origin" );
	water_height = GetWaterHeight( neck_pos );
	water_pos = ( neck_pos[0], neck_pos[1], water_height );
	return( water_pos );
}

flashlight_vc_behavior()
{
	self endon( "death" );
	
	self AllowedStances( "crouch", "prone" );
	
	self thread vc_flashlight_combat_behavior_on();
	self thread vc_flashlight_combat_behavior_off();
	self thread vc_attack_player_relentlessly();
	
	player = get_players()[0];
	if( player.flashlight_on == true )
	{
		self.pacifist = false;
	}
	else
	{
		self.pacifist = true;
		self thread vc_flashlight_combat_behavior_close();
	}
}

vc_flashlight_combat_behavior_on()
{
	self endon( "death" );
	while( 1 )
	{
		level waittill( "flahslight_on" );
		self.pacifist = false;
		self.ignoreall = false;
	}
}

vc_flashlight_combat_behavior_off()
{
	self endon( "death" );
	while( 1 )
	{
		level waittill( "flahslight_off" );
		self.pacifist = true;
		
		self thread vc_flashlight_combat_behavior_close();
	}
}

vc_attack_player_relentlessly()
{
	self endon( "death" );
	if( isdefined( self.animname ) )
	{
		if( self.animname == "vc_tunnel_room2_1" || self.animname == "vc_tunnel_room2_5" )
		{
			wait( 1 );
		}
		else
		{
			wait( randomfloat( 3 ) + 4 );
		}
	}
	else
	{
		wait( randomfloat( 3 ) + 4 );
	}
	
	// wait for flashlight to be on
	player = get_players()[0];
	while( player.flashlight_on == false )
	{
		wait( 0.05 );
	}
	self setgoalentity( player );
}

vc_flashlight_combat_behavior_close()
{
	self endon( "death" );
	level endon( "flahslight_on" );
	level endon( "flahslight_off" );
	
	player = get_players()[0];
	while( distance( player.origin, self.origin ) > 200 )
	{
		wait( 0.05 );
	}
	self.pacifist = false;
}

get_linked_nodes( starting_node_name, first_node )
{
	if( !isdefined( first_node ) )
	{
		first_node = GetNode( starting_node_name, "targetname" );
	}
	
	if( !isdefined( first_node ) )
	{
		return( undefined );	
	}
	
	path_array = [];
	current_node = first_node;
	path_array = add_to_array( path_array, current_node, false );
	while( IsDefined( current_node.target ) )
	{
		current_node = GetNode( current_node.target, "targetname" );
		if( !isdefined( current_node ) )
		{
			return( path_array ); // the chain break and we return what we have so far
		}
		path_array = add_to_array( path_array, current_node, false );
	}
	
	return( path_array );
}

go_through_linked_nodes( path_array, end_msg )
{
	if( isdefined( end_msg ) )
	{
		level endon( end_msg );
	}
	
	self endon( "death" );
	
	for( i = 0; i < path_array.size; i++ )
	{
		self SetGoalNode( path_array[i] );
		self waittill( "goal" );
	}
	
	self notify( "reached_end_of_node_array" );
}

gib_fest()
{
	// set up gib
	self.force_gib = true; 
	self.custom_gib_refs = [];
	self.custom_gib_refs[0] = "right_arm";
	self.custom_gib_refs[1] = "left_arm";
	self.custom_gib_refs[2] = "no_legs";
}

always_stand()
{
	self AllowedStances( "stand" );
}

be_stupid( disable_colors )
{
	if( !isdefined( self.be_stupid ) || self.be_stupid == false )
	{
		self.be_stupid = true;
		
		self.ignoreall_old = self.ignoreall;
		self.ignoreme_old = self.ignoreme;
		self.ignoresuppression_old = self.ignoresuppression;
		self.suppressionthreshold_old = self.suppressionthreshold;
		self.noDodgeMove_old = self.noDodgeMove;
		self.dontShootWhileMoving_old = self.dontShootWhileMoving;
		self.grenadeawareness_old = self.grenadeawareness;
		self.pathenemylookahead_old = self.pathenemylookahead;
		self.meleeAttackDist_old = self.meleeAttackDist;
		
		self disable_react();
		self disable_pain();
		self.ignoresuppression = true;
		self.suppressionthreshold = 1; 
		self.noDodgeMove = true; 
		self.dontShootWhileMoving = true;
		self.grenadeawareness = 0;
		self.pathenemylookahead = 0;
		self.meleeAttackDist = 0;
		self disable_react();
		self disable_pain();
		
		if( isdefined( disable_colors ) && disable_colors == true )
		{
			self.force_disable_color = true;
			self disable_ai_color();
		}
	}
}

stop_being_stupid()
{
	if( isdefined( self.be_stupid ) && self.be_stupid == true )
	{
		self.be_stupid = false;
		
		self enable_react();
		self enable_pain();
		
		self.ignoreall = self.ignoreall_old;
		self.ignoreme = self.ignoreme_old;
		self.ignoresuppression = self.ignoresuppression_old;
		self.suppressionthreshold = self.suppressionthreshold_old;
		self.noDodgeMove = self.noDodgeMove_old;
		self.dontShootWhileMoving = self.dontShootWhileMoving_old;
		self.grenadeawareness = self.grenadeawareness_old;
		self.pathenemylookahead = self.pathenemylookahead_old;
		self.meleeAttackDist = self.meleeAttackDist_old;
		
		if( isdefined( self.force_disable_color ) && self.force_disable_color == true )
		{
			self.force_disable_color = false;
			self enable_ai_color();
		}
	}
}

load_up_sampan( vehicle )
{
	level thread spawn_animate_drone_vc( vehicle, "tag_driver", "idle_crouch", "death_explosive_side_1" );
	level thread spawn_animate_drone_vc( vehicle, "tag_passenger1", "idle_crouch", "death_explosive_side_2" );
	level thread spawn_animate_drone_vc( vehicle, "tag_passenger2", "idle_stand", "death_explosive_side_3" );
	level thread spawn_animate_drone_vc( vehicle, "tag_passenger3", "idle_stand", "death_explosive_side_4" );
}

load_up_huey( vehicle, pilot, left_side, right_side )
{
	if( pilot == true )
	{
		level thread spawn_animate_drone_friendly( vehicle, "tag_driver", "huey_pilot_loop" );
	}
	wait( 0.1 );

	if( left_side == true )
	{
		level thread spawn_animate_drone_friendly( vehicle, "tag_gunner2", "huey_gunner_2_loop" );
		level thread spawn_animate_drone_friendly( vehicle, "tag_passenger2", "huey_passenger_fl_loop" );
		level thread spawn_animate_drone_friendly( vehicle, "tag_passenger4", "huey_passenger_bl_loop" );
	}
	wait( 0.1 );
	
	if( right_side == true )
	{
		level thread spawn_animate_drone_friendly( vehicle, "tag_gunner1", "huey_gunner_1_loop" );
		level thread spawn_animate_drone_friendly( vehicle, "tag_passenger3", "huey_passenger_fr_loop" );
		level thread spawn_animate_drone_friendly( vehicle, "tag_passenger5", "huey_passenger_br_loop" );
	}
}

#using_animtree ("generic_human");
spawn_animate_drone_friendly( vehicle, tag_name, anim_loop_name, death_anim_name )
{
	guy = Spawn( "script_model", vehicle GetTagOrigin( tag_name ) ); 
	guy.angles = vehicle GetTagAngles( tag_name );

	// setup model
	chance = randomint( 100 );
	if( chance < 25 )
	{
		guy character\c_usa_jungmar_wet_assault::main();
	}
	else if( chance < 50 )
	{
		guy character\c_usa_jungmar_wet_snip::main();
	}
	else if( chance < 75 )
	{
		guy character\c_usa_jungmar_wet_lmg::main();
	}
	else
	{
		guy character\c_usa_jungmar_wet_shotgun::main();
	}
	
	guy.weapon = "commando_sp";
	weaponModel = GetWeaponModel( guy.weapon ); 
	guy Attach( weaponModel, "tag_weapon_right" ); 
	
	guy linkto( vehicle, tag_name );
	guy MakeFakeAI(); 
	guy.animname = "generic";
	guy UseAnimTree( #animtree );
	
	// special models
	if( tag_name == "tag_driver" )
	{
		//guy SetModel( "c_usa_huey_pilot1_fb" );
	}
		
	vehicle thread anim_loop_aligned( guy, anim_loop_name, tag_name );
	
	vehicle waittill( "death" );
	
	if( !isdefined( death_anim_name ) )
	{
		guy delete();
	}
	else
	{
		vehicle anim_single_aligned( guy, death_anim_name, tag_name );
		guy delete();
	}
}

spawn_animate_drone_vc( vehicle, tag_name, anim_loop_name, death_anim_name )
{
	guy = Spawn( "script_model", vehicle GetTagOrigin( tag_name ) ); 
	guy.angles = vehicle GetTagAngles( tag_name );
	
	// setup model
	chance = randomint( 100 );
	if( chance < 33 )
	{
		guy character\c_vtn_vc1::main();
	}
	else if( chance < 67 )
	{
		guy character\c_vtn_vc2::main();
	}
	else
	{
		guy character\c_vtn_vc3::main();
	}
	
	guy.weapon = "ak47_sp";
	weaponModel = GetWeaponModel( guy.weapon ); 
	guy Attach( weaponModel, "tag_weapon_right" ); 
	
	guy linkto( vehicle, tag_name, (0,0,0), (0,180,0) );
	guy MakeFakeAI(); 
	guy.animname = "generic";
	guy.script_nodropweapon = true;
	guy UseAnimTree( #animtree );
	
	guy thread anim_loop_aligned( guy, anim_loop_name );
	
	vehicle waittill( "damage" );
	
	if( !isdefined( death_anim_name ) )
	{
		guy delete();
	}
	else
	{
		//vehicle anim_single_aligned( guy, death_anim_name, tag_name );
		guy delete();
	}
}


clear_entities( entity_targetname )
{
	entities_for_delete = getentarray( entity_targetname, "targetname" );
	if( isdefined( entities_for_delete ) && entities_for_delete.size > 0 )
	{
		for( i = 0; i < entities_for_delete.size; i++ )
		{
			entities_for_delete[i] delete();
		}
	}
}

push_player_downwards( trigger_name, trigger_noteworthy )
{
	if( isdefined( trigger_name ) )
	{
		trigger_wait( trigger_name );
	}
	else
	{
		trigger_wait( trigger_noteworthy, "script_noteworthy" );
	}
	
	player = get_players()[0];
	timer = 1;
	
	if( isdefined( player._swimming ) && isdefined( player._swimming.is_underwater ) && player._swimming.is_underwater == true )
	{
		// player is already under water
		return;
	}
	
	for( i = 0; i <= timer; i += 0.05 )
	{ 
		vel = player GetVelocity();
		player SetVelocity( vel + ( 0, 0, -7 ) );
		wait( 0.05 );
	}
}

verify_knife_achievements()
{
	previous_count = 0;
	while( 1 )
	{
		if( level.vc_stealth_killed != previous_count )
		{
			previous_count = level.vc_stealth_killed;
		}
		
		if( level.vc_stealth_killed >= 3 )
		{
			player = get_players()[0];
			player giveachievement_wrapper( "SP_LVL_CREEK1_KNIFING" );
			return;
		}
		wait( 0.05 );
	}
}