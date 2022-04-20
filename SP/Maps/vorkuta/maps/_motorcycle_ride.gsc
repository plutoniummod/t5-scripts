#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;

motorcycle_init( player_body_model, player_motorcycle_model, motorcycle_gunModel )
{	
	level.UPDATE_TIME      			= 0.05;
	level.BLEND_TIME	   			= 0.1;
	level.STEER_MIN		   			= -1.0;	
	level.STEER_MAX		   			= 1.0;
	level.TURN_ANIM_RATE_MULTIPLIER = 0.5;

	level.SHOOT_PULLOUT_RATE		= 2.0;
	level.SHOOT_PUTAWAY_RATE		= 2.0;

	level.SHOOT_BLEND_TIME 			= 0.1;
	level.SHOOT_ARM_UP_DELAY		= 3.0;
	level.SHOOT_FIRE_TIME			= 0.4;
	level.SHOOT_AMMO_COUNT			= 2;

	level.THROTTLE_BLEND_TIME		= 0.08;
	level.STEERING_BLEND_TIME		= 0.08;

	level.DEFAULT_FOV				= 55;
	level.DEFAULT_FOV_LERP_TIME		= .5;

	level.SHOOT_FOV					= 0.94;
	level.SHOOT_TARGET_DISTANCE     = 2000;
	
	// player hands/body model, we are using two hand rig now
	if( !IsDefined( player_body_model ) )
		level.player_body_model = "viewmodel_rus_prisoner_player";
	else
		level.player_body_model = player_body_model;

	// motorcycle model
	if( !IsDefined( player_motorcycle_model ) )
		level.player_motorcycle_model = "t5_veh_bike_m72_player";
	else
		level.player_motorcycle_model = player_motorcycle_model;

	// gun on the motorcycle
	if( !IsDefined( motorcycle_gunModel ) )
		level.motorcycle_gunModel = "t5_weapon_model_1887_viewmodel";
	else
		level.motorcycle_gunModel = motorcycle_gunModel;

	// the real gun that gets magic bulletted on
	level.motorcycle_magicGun = "vorkuta_motorcycle_shotgun_sp";

	PrecacheItem( level.motorcycle_magicGun );
	PrecacheModel( level.player_body_model );
	PrecacheModel( level.player_motorcycle_model );
	PrecacheModel( level.motorcycle_gunModel );

	// precache rumbles
	precacherumble( "damage_heavy" );
	precacherumble( "damage_light" );

	motorycle_weapon_fx();
	motorcycle_anims();
}

motorycle_weapon_fx()
{
	//muzzle flash for shotgun
	level._effect["shotgun_muzzleflash"]	= LoadFX("weapon/muzzleflashes/fx_shotgun_flash_base_vorkuta");
	
}	

#using_animtree("vehicles");
motorcycle_anims()
{	
	level.scr_animtree["motorcycle_player"]			 			 = #animtree;
	level.scr_model["motorcycle_player"]			 			 = level.player_body_model;

	level.scr_anim["motorcycle_player"]["root"]		 			 = %root;

	// left arm
	level.scr_anim["motorcycle_player"]["left_arm"]				 = %player_motorcycle_left_arm;			  // tree node
	level.scr_anim["motorcycle_player"]["drive_left_arm"]		 = %player_motorcycle_drive_left_arm;	  // tree node
	level.scr_anim["motorcycle_player"]["turn_left2right_L"]	 = %int_bike_m72_drive_turn_left2right_L; 
	level.scr_anim["motorcycle_player"]["turn_right2left_L"]	 = %int_bike_m72_drive_turn_right2left_L;

	// left arm shooting
	level.scr_anim["motorcycle_player"]["shoot_left_arm"]			 = %player_motorcycle_shoot_left_arm;
	level.scr_anim["motorcycle_player"]["gun_fire" ]				 = %int_bike_m72_gun_fire;
	level.scr_anim["motorcycle_player"]["gun_idle" ]				 = %int_bike_m72_gun_idle;
	level.scr_anim["motorcycle_player"]["gun_pullout_root" ]		 = %player_motorcycle_gun_pullout_root;
	level.scr_anim["motorcycle_player"]["gun_pullout_L" ]		 	 = %int_bike_m72_gun_pullout_L;
	level.scr_anim["motorcycle_player"]["gun_pullout" ]			 	 = %int_bike_m72_gun_pullout;
	level.scr_anim["motorcycle_player"]["gun_pullout_R" ]		 	 = %int_bike_m72_gun_pullout_R;
	level.scr_anim["motorcycle_player"]["gun_putaway_root" ]		 = %player_motorcycle_gun_putaway_root;
	level.scr_anim["motorcycle_player"]["gun_putaway_L" ]		 	 = %int_bike_m72_gun_putaway_L;
	level.scr_anim["motorcycle_player"]["gun_putaway" ]			 	 = %int_bike_m72_gun_putaway;
	level.scr_anim["motorcycle_player"]["gun_putaway_R" ]		 	 = %int_bike_m72_gun_putaway_R;
	level.scr_anim["motorcycle_player"]["gun_reload" ]			 	 = %int_bike_m72_gun_reload;
	level.scr_anim["motorcycle_player"]["gun_rechamber" ]		 	 = %int_bike_m72_gun_rechamber;

	//rightarm
	level.scr_anim["motorcycle_player"]["right_arm"]			 	 = %player_motorcycle_right_arm;		  // tree node
	level.scr_anim["motorcycle_player"]["turn_left2right_R"]	 	 = %int_bike_m72_drive_turn_left2right_R;
	level.scr_anim["motorcycle_player"]["turn_right2left_R"]	 	 = %int_bike_m72_drive_turn_right2left_R;

	level.scr_anim["motorcycle_player"][ "glock" ]					 = %motorcycle_shotgun;
	level.scr_anim["motorcycle_player"][ "glock_fire" ]				 = %viewmodel_bike_m72_shotgun_fire;
	level.scr_anim["motorcycle_player"][ "glock_last_fire" ]		 = %viewmodel_bike_m72_shotgun_last_fire;
	level.scr_anim["motorcycle_player"][ "glock_reload" ]			 = %viewmodel_bike_m72_shotgun_reload;
	level.scr_anim["motorcycle_player"][ "glock_rechamber" ]		 = %viewmodel_bike_m72_shotgun_rechamber;

	// throttle animations
	level.scr_anim[ "motorcycle_player" ][ "throttle_add" ]			 = %player_motorcycle_drive_throttle_add;
	level.scr_anim[ "motorcycle_player" ][ "throttle" ]				 = %int_bike_m72_drive_throttle;

	level.scr_anim[ "motorcycle_player" ][ "throttle_add_left" ]	 = %player_motorcycle_drive_throttle_add_left;
	level.scr_anim[ "motorcycle_player" ][ "throttle_left" ]		 = %int_bike_m72_drive_throttle_left;

	level.scr_anim[ "motorcycle_player" ][ "throttle_add_right" ]	 = %player_motorcycle_drive_throttle_add_right;
	level.scr_anim[ "motorcycle_player" ][ "throttle_right" ]		 = %int_bike_m72_drive_throttle_right;

}


drive_motorcycle() // self = motorcycle
{
	Assert( IsSubStr( self.classname, "vehicle" ), "This function can only be called on drivable vehicles" );
	motorcycle = self;

	wait_for_first_player();	

	motorcycle waittill ("enter_vehicle", player );

	motorcycle thread maps\_motorcycle_ride_audio::init_motorcycle_audio();

	// set DOF
	player setClientDvar( "r_dof_tweak", 1 );
	player SetDepthOfField( 0, 44, 1000, 7000, 4, 0 );

	// Set the default FOV
	player thread lerp_fov_overtime( level.DEFAULT_FOV_LERP_TIME, level.DEFAULT_FOV );

	// start FOV lerping in clientscripts
	motorcycle setclientflag(15);
	
	Assert( IsDefined( player ) && IsPlayer( player ) );

	if ( !player flag_exists( "player_shot_on_motorcycle" ) )
		player ent_flag_init( "player_shot_on_motorcycle" );

	// give ammo to the vehicle
	motorcycle.motorcycleAmmoCount = level.SHOOT_AMMO_COUNT;

	motorcycle.player = player;
	motorcycle.animname = "motorcycle_player";
	motorcycle assign_animtree();

	// target selection for shooting 
	player thread drive_target_enemy( motorcycle );

	// rumbles, other generic rumbles and camera shakes are handled in _driving_fx.csc
	// this function also shakes camera
	motorcycle thread add_rumble_for_notify( "gear_changed", "damage_light", player, false );
	motorcycle thread add_rumble_for_notify( "player_shooting", "damage_light", player, true );

	// first person driving
	player drive_switch_to_first_person( motorcycle );

	motorcycle waittill_either( "exit_vehicle", "death" );
	player setClientDvar( "r_dof_tweak", 0 );
}


drive_switch_to_first_person( motorcycle ) // self = player
{
	if( IsDefined( motorcycle.firstperson ) )
		return;

	motorcycle setModel( level.player_motorcycle_model );
	motorcycle attach( level.player_body_model, "tag_origin" );
	motorcycle clearAnim( motorcycle getanim( "root" ), 0 );
	
	motorcycle.firstperson = true;

	self thread drive_firstperson_anims( motorcycle );
}

drive_firstperson_anims( motorcycle ) // self = player
{
	motorcycle endon("exit_vehicle");
	motorcycle endon("death");

	self thread drive_turning_anims( motorcycle );
	self thread drive_shooting_anims( motorcycle );
	self thread drive_throttle_anims( motorcycle );
}

get_scaled_steer_over_speed() // self = motorcycle
{
	steer_factor  = self GetSteerFactor();
	current_speed = self GetSpeedMPH();
	max_speed	  = 70;

	current_speed = Int(current_speed);

	t = current_speed / max_speed;
	scale = 1.0 - t;
	scale = clamp( scale, 0.3, 1.0 );

	steer_factor = steer_factor * scale;
	return steer_factor;
}

drive_turning_anims( motorcycle ) // self = player
{
	motorcycle endon("exit_vehicle");
	motorcycle endon("death");

	lastDirection = 1;
	movement	  = 0;	

	oldAnim = "turn_right2left_";
	newAnim = "turn_left2right_";
	curAnim = newAnim;
		
	animLength[ newAnim ][ "L" ] = GetAnimLength( motorcycle getanim( newAnim + "L" ) ); // left hand
	animLength[ newAnim ][ "R" ] = GetAnimLength( motorcycle getanim( newAnim + "R" ) ); // right hand
	
	animLength[ oldAnim ][ "L" ] = GetAnimLength( motorcycle getanim( oldAnim + "L" ) ); // left hand
	animLength[ oldAnim ][ "R" ] = GetAnimLength( motorcycle getanim( oldAnim + "R" ) ); // right hand

	motorcycle SetAnim( motorcycle getanim( "left_arm" ), 1.0, 0.0, 1.0 );  // left hand
	motorcycle SetAnim( motorcycle getanim( "right_arm" ), 1.0, 0.0, 1.0 ); // right hand

	motorcycle SetAnimLimited( motorcycle getanim( curAnim + "L" ), 1.0, level.BLEND_TIME, 0.0 ); // left hand
	motorcycle SetAnimLimited( motorcycle getanim( curAnim + "R" ), 1.0, level.BLEND_TIME, 0.0 ); // right hand

	motorcycle SetAnimTime( motorcycle getanim( curAnim + "L" ), 0.5 ); // left hand
	motorcycle SetAnimTime( motorcycle getanim( curAnim + "R" ), 0.5 );	// right hand

	while(1)
	{
		//-------------------------------------------------------
		// Steer the handlebars based on the player's input
		//-------------------------------------------------------
		movement_last = movement;
		//movement = motorcycle GetSteerFactor() * -1.0;
		movement = motorcycle get_scaled_steer_over_speed() * -1.0;

		movementChange = movement - movement_last;
		steerValue = movement;

		steerValue = clamp( steerValue, level.STEER_MIN, level.STEER_MAX );

		//-------------------------------------------------------
		// Blend turn anims on the vehicle with the right weights
		//-------------------------------------------------------
		
		newDirection = false;

		if ( movementChange < 0 ) // right to left
		{
			// change to turn left anims
			if ( lastDirection != -1 )
				newDirection = true;
			lastDirection = -1;

			oldAnim = "turn_left2right_";
			newAnim = "turn_right2left_";
		}
		if ( movementChange > 0 ) // left to right
		{
			// change to turn right anims
			if ( lastDirection != 1 )
				newDirection = true;
			lastDirection = 1;

			oldAnim = "turn_right2left_";
			newAnim = "turn_left2right_";
		}
		
		//---------------------------
		// Animate the bars and hands
		//---------------------------

		// See where the opposite animation needs to start so that it matches the previous animations position
		newAnimStartTime[ "L" ]	= motorcycle GetAnimTime( motorcycle getanim( curAnim + "L" ) );	
		newAnimStartTime[ "R" ]	= motorcycle GetAnimTime( motorcycle getanim( curAnim + "R" ) );	
		
		if ( newDirection )
		{
			newAnimStartTime[ "L" ] = abs( 1 - newAnimStartTime[ "L" ] );
			newAnimStartTime[ "R" ] = abs( 1 - newAnimStartTime[ "R" ] );
		}

		animTimeGoal = abs( ( steerValue - level.STEER_MIN ) / ( level.STEER_MIN - level.STEER_MAX ) );

		if( abs( steerValue ) == 0 && ( newAnimStartTime[ "L" ] != 0.5 || newAnimStartTime[ "R" ] != 0.5 ) )
			animTimeGoal = 0.5;
				
		if ( newAnim == "turn_right2left_" )
			animTimeGoal = 1.0 - animTimeGoal;

		animTimeGoal = cap_value( animTimeGoal, 0.0, 1.0 );
	
		/*
		// check if player is reversing, in that case we dont want to turn handle much to avoid 
		// cliping into hands
		reversing = false;
		if( motorcycle getSpeed() < -3 )
		{
			reversing = true;
			animTimeGoal = cap_value( animTimeGoal, 0.3, 0.7 );
		}
		
		if ( animTimeGoal < newAnimStartTime[ "L" ] )
		{
			newAnimStartTime[ "L" ] = animTimeGoal;
		}

		if ( animTimeGoal < newAnimStartTime[ "R" ] )
		{
			newAnimStartTime[ "R" ] = animTimeGoal;
		}
		*/

		// Fix for bug where handlebars would sometimes get stuck left or right when there is no stick movement.
		// Happens when stick goes from one side to the other very quickly within 0.05 server framerate.
		// Just setting newDirection fixes this because it causes it to animate back to where it should be instead of overshooting it's goal time.
		if( newAnimStartTime[ "L" ] > animTimeGoal )
		{
			newDirection = true;
		}
		
		// See how far the new animation needs to travel
		amountChange[ "L" ] = abs( animTimeGoal - newAnimStartTime[ "L" ] );
		amountChange[ "R" ] = abs( animTimeGoal - newAnimStartTime[ "R" ] );

		// See what animrate we should play the animation at so that it reaches the animGoalTime over level.UPDATE_TIME time.
		if ( movementChange == 0 && ( !amountChange[ "L" ] && !amountChange[ "L" ] ) )
		{
			estimatedAnimRate[ "L" ] = 0;
			estimatedAnimRate[ "R" ] = 0;
		}
		else
		{
			estimatedAnimRate[ "L" ] = abs( ( animLength[ newAnim ][ "L" ] / level.UPDATE_TIME ) * amountChange[ "L" ] ) * level.TURN_ANIM_RATE_MULTIPLIER;
			estimatedAnimRate[ "R" ] = abs( ( animLength[ newAnim ][ "R" ] / level.UPDATE_TIME ) * amountChange[ "R" ] ) * level.TURN_ANIM_RATE_MULTIPLIER;
		}

		estimatedAnimRate[ "L" ] = cap_value( estimatedAnimRate[ "L" ], 0.0, 1.0 );
		estimatedAnimRate[ "R" ] = cap_value( estimatedAnimRate[ "R" ], 0.0, 1.0 );
						
		if ( newDirection )
		{
			// clear the anim from the other direction
			motorcycle ClearAnim( motorcycle getanim( oldAnim + "L" ), 0 );
			motorcycle ClearAnim( motorcycle getanim( oldAnim + "R" ), 0 );


			// set the time on the new direction anim so it doesn't start animating from the beginning,
			// since the previous anim probably wasn't at the end
			motorcycle SetAnimLimited( motorcycle getanim( newAnim + "L" ), 1, level.BLEND_TIME, estimatedAnimRate[ "L" ] );
			motorcycle SetAnimLimited( motorcycle getanim( newAnim + "R" ), 1, level.BLEND_TIME, estimatedAnimRate[ "R" ] );

			motorcycle SetAnimTime( motorcycle getanim( newAnim + "L" ), newAnimStartTime[ "L" ] );
			motorcycle SetAnimTime( motorcycle getanim( newAnim + "R" ), newAnimStartTime[ "R" ] );
		}
		else
		{
			motorcycle SetAnimLimited( motorcycle getanim( newAnim + "L" ), 1, level.BLEND_TIME, estimatedAnimRate[ "L" ] );
			motorcycle SetAnimLimited( motorcycle getanim( newAnim + "R" ), 1, level.BLEND_TIME, estimatedAnimRate[ "R" ] );
		}

		curAnim = newAnim;
		
		/#
//		debug( movement, newDirection, newAnimStartTime[ "L" ], newAnimStartTime[ "R" ], estimatedAnimRate[ "L" ], estimatedAnimRate[ "R" ] );
		#/
		
		wait level.UPDATE_TIME*2;
	}
}

drive_throttle_anims( motorcycle ) // self = player
{
	motorcycle endon("exit_vehicle");
	motorcycle endon("death");

	motorcycle SetAnim( motorcycle getanim( "throttle" ), 1.0, 0.0, 1.0 );
	motorcycle SetAnim( motorcycle getanim( "throttle_left" ), 1.0, 0.0, 1.0 );
	motorcycle SetAnim( motorcycle getanim( "throttle_right" ), 1.0, 0.0, 1.0 );

	for( ;; )
	{
		if( IsDefined( motorcycle.gearStateChanged ) && motorcycle.gearStateChanged )
		{	
			//IPrintLn( "Server : gear change processed" );
			motorcycle.gearStateChanged = false;
			throttle = 0;
		}
		else
		{
			throttle = Abs( motorcycle GetThrottle() );
		}

		//steerValue = motorcycle GetSteerFactor() * -1.0;
		steerValue = motorcycle get_scaled_steer_over_speed() * -1.0;
		steerValue = clamp( steerValue, level.STEER_MIN, level.STEER_MAX );

		if ( steerValue >= 0.0 )
		{
			throttleWeight = throttle * ( 1.0 - steerValue );
			throttleLeftWeight = 0.0;
			throttleRightWeight = throttle * steerValue;
		}
		else
		{
			throttleWeight = throttle * ( 1.0 + steerValue );
			throttleLeftWeight = throttle * steerValue * -1.0;
			throttleRightWeight = 0.0;
		}

		motorcycle SetAnim( motorcycle getanim( "throttle_add" ), throttleWeight, level.THROTTLE_BLEND_TIME, 1.0 );
		motorcycle SetAnim( motorcycle getanim( "throttle_add_left" ), throttleLeftWeight, level.THROTTLE_BLEND_TIME, 1.0 );
		motorcycle SetAnim( motorcycle getanim( "throttle_add_right" ), throttleRightWeight, level.THROTTLE_BLEND_TIME, 1.0 );

		wait level.UPDATE_TIME;
	}
}

drive_shooting_anims( motorcycle ) // self = player
{
	motorcycle endon("exit_vehicle");
	motorcycle endon("death");

	motorcycle SetAnim( motorcycle getanim( "drive_left_arm" ), 1.0, level.BLEND_TIME, 1.0 );
	motorcycle SetAnim( motorcycle getanim( "shoot_left_arm" ), 0.0, level.SHOOT_BLEND_TIME, 1.0 );

	while(1)
	{
		shootButtonPressed = is_shoot_button_pressed();

		if ( shootButtonPressed )
		{
			motorcycle SetAnim( motorcycle getanim( "drive_left_arm" ), 0.001, level.SHOOT_BLEND_TIME, 1.0 );
			motorcycle SetAnim( motorcycle getanim( "shoot_left_arm" ), 1.0, level.SHOOT_BLEND_TIME, 1.0 );

			self thread drive_shooting_update_anims( motorcycle );
			
			motorcycle waittill( "drive_shooting_done" );
		}

		motorcycle SetAnim( motorcycle getanim( "drive_left_arm" ), 1.0, level.SHOOT_BLEND_TIME, 1.0 );
		motorcycle SetAnim( motorcycle getanim( "shoot_left_arm" ), 0.0, level.SHOOT_BLEND_TIME, 1.0 );

		wait level.UPDATE_TIME*2;
	}	
}

drive_target_enemy( motorcycle ) // self = player
{
	motorcycle endon("exit_vehicle");
	motorcycle endon("death");

	while(1)
	{		
		// AI enemies
		ai = GetAIArray( "axis" );	

		// destructibles
		targets = GetEntArray( "bike_target", "script_noteworthy" );
		target_group = array_combine( ai, targets );

		self.motorcycle_enemy = undefined;
		target				  = undefined;
		best_targetFov		  = undefined;

		for( i = 0; i < target_group.size; i++ )
		{			
			if( Distance2D( target_group[i].origin, self.origin ) > level.SHOOT_TARGET_DISTANCE )
				continue;
			
			normal  = VectorNormalize( target_group[i].origin - self.origin );
			forward = AnglesToForward( self.angles );
			fov     = VectorDot( forward, normal );
						 
			if( fov > level.SHOOT_FOV )
			{	
				// choose this target if no target is chosen before or this one is at closer angle than the last one
				if( !IsDefined( best_targetFov ) ||  ( fov > best_targetFov ) )
				{					
					best_targetFov = fov;
					target = target_group[i];
				}
			}
		}

		// current target should be the best target of all available ones
		self.motorcycle_enemy = target;

		wait( 0.2 );
	}
}

add_rumble_for_notify( message, rumble, player, shakeCamera ) // self = motorcycle
{
	self endon("exit_vehicle");
	self endon("death");

	for(;;)
	{
		self waittill( message );
		player playrumbleonentity( rumble );

		if( shakeCamera )
			Earthquake( 0.5, 0.3, player.origin, 150 );
	}
}

drive_magic_bullet( motorcycle ) // self = player
{
	end_origin   = undefined;
	start_origin = motorcycle GetTagOrigin( "tag_flash" );
	start_angles = motorcycle GetTagAngles( "tag_flash" );

	// shoot the bullet
	if( IsDefined( self.motorcycle_enemy ) )
	{
		// destructible
		if( IsDefined( self.motorcycle_enemy.script_noteworthy ) && ( self.motorcycle_enemy.script_noteworthy == "bike_target" ) )
		{
			end_origin = self.motorcycle_enemy.origin + ( 0, 0, 20 );
		}
		else if( IsAI( self.motorcycle_enemy ) ) // AI
		{
			end_origin = self.motorcycle_enemy getEye();
		}
	}
	else
	{
		// getting tag_flash of the motorcycle as the gun is attached to motorcycle through viewarms
		end_origin = start_origin + vector_scale( AnglesToForward( start_angles ), 200 );
	}
		
	motorcycle notify("player_shooting");
	//muzzle FX
	PlayFXOnTag ( level._effect["shotgun_muzzleflash"], motorcycle,"tag_flash");
	//actual shooting 
	MagicBullet( level.motorcycle_magicGun, start_origin, end_origin, self);
}


drive_shooting_update_anims( motorcycle ) // self = player
{
	motorcycle endon("exit_vehicle");
	motorcycle endon("death");

	// start pull out anim
	motorcycle SetAnimKnobLimited( motorcycle getanim( "gun_pullout_root" ), 1.0, 0.0, level.SHOOT_PULLOUT_RATE );
	self thread drive_blend_anims_with_steering( motorcycle, "pullout_anim", "pullout_done", "gun_pullout_L", "gun_pullout", "gun_pullout_R", level.SHOOT_PULLOUT_RATE );

	// attach the gun
	motorcycle waittillmatch( "pullout_anim", "attach_gun" );
	motorcycle Attach( level.motorcycle_gunModel, "tag_weapon" );

	// hide ammo parts from the gun here
	motorcycle hidePart( "J_Ammo_01", level.motorcycle_gunModel );
	motorcycle hidePart( "J_Ammo_02", level.motorcycle_gunModel );
		
	motorcycle waittillmatch( "pullout_anim", "end" );
	motorcycle notify( "pullout_done" );

	justPulledGunOut = true;

	// start gun anim
	motorcycle SetAnim( motorcycle getanim( "glock" ), 1.0, 0.0, 1.0 );

	// start idle
	motorcycle SetAnimKnobLimited( motorcycle getanim( "gun_idle" ), 1.0, 0.0, 1.0 );

	motorcycle.snowmobileShootTimer = level.SHOOT_ARM_UP_DELAY;

	for ( ;; )
	{
		if ( motorcycle.snowmobileShootTimer <= 0.0 )
			break;

		shootButtonPressed = is_shoot_button_pressed();
		
		// shoot if the gun has enough ammo and if it was just pulled out or shoot button pressed
		if ( ( motorcycle.motorcycleAmmoCount > 0 ) && ( shootButtonPressed || justPulledGunOut ) )
		{
			assert( isplayer( self ) );
			self ent_flag_set( "player_shot_on_motorcycle" );
			
			justPulledGunOut = false;

			// play gun fire anims
			motorcycle SetFlaggedAnimKnobLimitedRestart( "fire_anim", motorcycle getanim( "gun_fire" ), 1.0, 0.0, 1.0 );

			if ( motorcycle.motorcycleAmmoCount == 1 )
				motorcycle SetAnimKnobLimitedRestart( motorcycle getanim( "glock_last_fire" ), 1.0, 0.0, 1.0 );
			else
				motorcycle SetAnimKnobLimitedRestart( motorcycle getanim( "glock_fire" ), 1.0, 0.0, 1.0 );

			// fire bullet
			self drive_magic_bullet( motorcycle );

			wait( GetAnimLength( motorcycle getanim( "gun_fire" ) ) );
			wait( level.SHOOT_FIRE_TIME );

			motorcycle.motorcycleAmmoCount -= 1;
			motorcycle.snowmobileShootTimer = level.SHOOT_ARM_UP_DELAY;
			
		}
		else if ( motorcycle.motorcycleAmmoCount <= 0 ) // this is rechamber and not reload
		{
			// show the ammo as its needed for rechamber
			motorcycle ShowPart( "J_Ammo_01", level.motorcycle_gunModel );
			motorcycle ShowPart( "J_Ammo_02", level.motorcycle_gunModel );

			// play reload anims
			motorcycle SetFlaggedAnimKnobLimitedRestart( "reload_anim", motorcycle getanim( "gun_reload" ), 1.0, 0.0, 1.0 );
			motorcycle SetAnimKnobLimitedRestart( motorcycle getanim( "glock_reload" ), 1.0, 0.0, 1.0 );

			motorcycle waittillmatch( "reload_anim", "end" );

			motorcycle.motorcycleAmmoCount  = level.SHOOT_AMMO_COUNT;
			motorcycle.snowmobileShootTimer = level.SHOOT_ARM_UP_DELAY;

			// hide ammo parts for other animations
			motorcycle hidePart( "J_Ammo_01", level.motorcycle_gunModel );
			motorcycle hidePart( "J_Ammo_02", level.motorcycle_gunModel );

		}
		else
		{
			// play idle
			motorcycle SetAnimKnobLimited( motorcycle getanim( "gun_idle" ), 1.0, 0.0, 1.0 );
			motorcycle.snowmobileShootTimer -= level.UPDATE_TIME;
		}

		wait level.UPDATE_TIME*2;
	}

	// start put away anim
	motorcycle SetAnimKnobLimited( motorcycle getanim( "gun_putaway_root" ), 1.0, 0.0, level.SHOOT_PUTAWAY_RATE );
	self thread drive_blend_anims_with_steering( motorcycle, "putaway_anim", "putaway_done", "gun_putaway_L", "gun_putaway", "gun_putaway_R", level.SHOOT_PUTAWAY_RATE );

	// detach the gun 
	motorcycle waittillmatch( "putaway_anim", "detach_gun" );
	motorcycle Detach( level.motorcycle_gunModel, "tag_weapon" );
	motorcycle.gun_attached = undefined;

	motorcycle waittillmatch( "putaway_anim", "end" );
	motorcycle notify( "putaway_done" );
	motorcycle notify( "drive_shooting_done" );
}


drive_blend_anims_with_steering( motorcycle, animflag, endNotify, leftAnim, centerAnim, rightAnim, rate )
{
	motorcycle endon("exit_vehicle");
	motorcycle endon("death");

	motorcycle endon( endNotify );

	motorcycle SetFlaggedAnimRestart( animflag, motorcycle getanim( leftAnim ), 0.001, level.STEERING_BLEND_TIME, rate );
	motorcycle SetFlaggedAnimRestart( animflag, motorcycle getanim( centerAnim ), 0.001, level.STEERING_BLEND_TIME, rate );
	motorcycle SetFlaggedAnimRestart( animflag, motorcycle getanim( rightAnim ), 0.001, level.STEERING_BLEND_TIME, rate );

	for ( ;; )
	{
		//steerValue = motorcycle GetSteerFactor() * -1.0;
		steerValue = motorcycle get_scaled_steer_over_speed() * -1.0;
		steerValue = clamp( steerValue, level.STEER_MIN, level.STEER_MAX );

		// never set a weight to zero so that all the anims continue to play
		if ( steerValue >= 0.0 )
		{
			leftWeight = 0.001;
			centerWeight = -0.999 * steerValue + 1.0;
			rightWeight = 0.999 * steerValue + 0.001;
		}
		else
		{
			leftWeight = -0.999 * steerValue + 0.001;
			centerWeight = 0.999 * steerValue + 1.0;
			rightWeight = 0.001;
		}

		motorcycle SetFlaggedAnim( animflag, motorcycle getanim( leftAnim ), leftWeight, level.STEERING_BLEND_TIME, rate );
		motorcycle SetFlaggedAnim( animflag, motorcycle getanim( centerAnim ), centerWeight, level.STEERING_BLEND_TIME, rate );
		motorcycle SetFlaggedAnim( animflag, motorcycle getanim( rightAnim ), rightWeight, level.STEERING_BLEND_TIME, rate );

		wait level.UPDATE_TIME*2;
	}
}


cap_value( value, minValue, maxValue )
{
	assert( isdefined( value ) );

	// handle a min value larger than a max value
	if ( minValue > maxValue )
		return cap_value( value, maxValue, minValue );

	assert( minValue <= maxValue );

	if ( isdefined( minValue ) && ( value < minValue ) )
		return minValue;

	if ( isdefined( maxValue ) && ( value > maxValue ) )
		return maxValue;

	return value;
}


is_shoot_button_pressed()
{
	if( level.console )
		return self ThrowButtonPressed();
	else
		return self AttackButtonPressed();
}

// --------------------------------------------------------------------------------
// ---- Debug ----
// --------------------------------------------------------------------------------
debug( movement, newDirection, newAnimStartTime_L, newAnimStartTime_R, estimatedAnimRate_L, estimatedAnimRate_R )
{
	if( !IsDefined( level.debug_motorcycle_hud ) )
	{
		level.debug_motorcycle_hud = NewDebugHudElem();
		level.debug_motorcycle_hud.alignX = "left";
		level.debug_motorcycle_hud.x = -75;
		level.debug_motorcycle_hud.y = 40;
		level.debug_motorcycle_hud.fontScale = 1.25;	
		level.debug_motorcycle_hud.color = (0,1,0);

		level.debug_motorcycle_hud1 = NewDebugHudElem();
		level.debug_motorcycle_hud1.alignX = "left";
		level.debug_motorcycle_hud1.x = -75;
		level.debug_motorcycle_hud1.y = 55;
		level.debug_motorcycle_hud1.fontScale = 1.25;	
		level.debug_motorcycle_hud1.color = (0,1,0);
	}

	level.debug_motorcycle_hud SetText(" Steer Factor - " +  movement 
									 + " newDirection - " + newDirection		
									 );

	level.debug_motorcycle_hud1 SetText(" newAnimStartTime_L - " + newAnimStartTime_L		
									 + " newAnimStartTime_R - "  + newAnimStartTime_R		
									 + " estimatedAnimRate_L - " + estimatedAnimRate_L		
									 + " estimatedAnimRate_R - " + estimatedAnimRate_R 
									 );
}

