#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;

#using_animtree("vehicles");

drive_turning_anims( car, player_model, version ) // self = player
{
	car endon("exit_vehicle");
	car endon("death");

	level endon("drive_slomo");

	level.UPDATE_TIME      			= 0.05;
	level.BLEND_TIME	   			= 0.1;
	level.STEER_MIN		   			= -1.0;	
	level.STEER_MAX		   			= 1.0;
	level.TURN_ANIM_RATE_MULTIPLIER = 0.5;

	oldAnim = "turn_right2left";
	newAnim = "turn_left2right";
	curAnim = newAnim;

	car init_car_anims(version);
	player_model init_player_anims(version);

	lastDirection = 1;
	movement	  = 0;	
		
	animLength[ newAnim ] = GetAnimLength( car getanim( newAnim ) );
	animLength[ oldAnim ] = GetAnimLength( car getanim( oldAnim ) );

	while(1)
	{
		//-------------------------------------------------------
		// Steer the handlebars based on the player's input
		//-------------------------------------------------------
		movement_last = movement;
		//movement = car GetSteerFactor() * -1.0;
		//movement = self get_scaled_steer_over_speed(car) * -1.0;
		movement = self GetNormalizedMovement()[1] * -1.0;

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

			oldAnim = "turn_left2right";
			newAnim = "turn_right2left";
		}
		if ( movementChange > 0 ) // left to right
		{
			// change to turn right anims
			if ( lastDirection != 1 )
				newDirection = true;
			lastDirection = 1;

			oldAnim = "turn_right2left";
			newAnim = "turn_left2right";
		}
		
		//---------------------------
		// Animate the bars and hands
		//---------------------------

		// See where the opposite animation needs to start so that it matches the previous animations position
		newAnimStartTime = car GetAnimTime( car getanim( curAnim ) );	
		
		if ( newDirection )
		{
			newAnimStartTime = abs( 1 - newAnimStartTime );
		}

		animTimeGoal = abs( ( steerValue - level.STEER_MIN ) / ( level.STEER_MIN - level.STEER_MAX ) );

		if( abs( steerValue ) == 0 && ( newAnimStartTime != 0.5 ))
			animTimeGoal = 0.5;
				
		if ( newAnim == "turn_right2left" )
			animTimeGoal = 1.0 - animTimeGoal;

		animTimeGoal = cap_value( animTimeGoal, 0.0, 1.0 );
	
		// Fix for bug where handlebars would sometimes get stuck left or right when there is no stick movement.
		// Happens when stick goes from one side to the other very quickly within 0.05 server framerate.
		// Just setting newDirection fixes this because it causes it to animate back to where it should be instead of overshooting it's goal time.
		if( newAnimStartTime > animTimeGoal )
		{
			newDirection = true;
		}
		
		// See how far the new animation needs to travel
		amountChange = abs( animTimeGoal - newAnimStartTime );

		// See what animrate we should play the animation at so that it reaches the animGoalTime over level.UPDATE_TIME time.
		if ( movementChange == 0 && ( !amountChange ) )
		{
			estimatedAnimRate = 0;
		}
		else
		{
			estimatedAnimRate = abs( ( animLength[ newAnim ] / level.UPDATE_TIME ) * amountChange ) * level.TURN_ANIM_RATE_MULTIPLIER;
		}

		estimatedAnimRate= cap_value( estimatedAnimRate, 0.0, 1.0 );
						
		if ( newDirection )
		{
			// clear the anim from the other direction
			car ClearAnim( car getanim( oldAnim ), 0 );
			player_model ClearAnim( player_model getanim( oldAnim ), 0 );

			// set the time on the new direction anim so it doesn't start animating from the beginning,
			// since the previous anim probably wasn't at the end
			car SetAnimLimited( car getanim( newAnim ), 1, level.BLEND_TIME, estimatedAnimRate );
			car SetAnimTime( car getanim( newAnim ), newAnimStartTime );

			player_model SetAnimLimited( player_model getanim( newAnim ), 1, level.BLEND_TIME, estimatedAnimRate );
			player_model SetAnimTime( player_model getanim( newAnim ), newAnimStartTime );
		}
		else
		{
			car SetAnimLimited( car getanim( newAnim ), 1, level.BLEND_TIME, estimatedAnimRate );
			player_model SetAnimLimited( player_model getanim( newAnim ), 1, level.BLEND_TIME, estimatedAnimRate );
		}

		curAnim = newAnim;
		wait level.UPDATE_TIME*2;
	}
}

get_scaled_steer_over_speed(car)
{
	//steer_factor  = self GetSteerFactor();
	steer_factor = self GetNormalizedMovement()[1];
	current_speed = car GetSpeedMPH();
	max_speed	  = 70;

	current_speed = Int(current_speed);

	t = current_speed / max_speed;
	scale = 1.0 - t;
	scale = clamp( scale, 0.3, 1.0 );

	steer_factor = steer_factor * scale;
	return steer_factor;
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

init_car_anims(version)
{
	if (!IsDefined(version) || version == 1)
	{
		// one hand
		level.scr_anim["car"]["turn_left2right"]	= %v_cub_b01_carsequence_turnright_1hand_car_brian; 
		level.scr_anim["car"]["turn_right2left"]	= %v_cub_b01_carsequence_turnleft_1hand_car_brian;
	}
	else
	{
		// two hands
		level.scr_anim["car"]["turn_left2right"]	= %v_cub_b01_carsequence_turnright_2hands_car_brian;
		level.scr_anim["car"]["turn_right2left"]	= %v_cub_b01_carsequence_turnleft_2hands_car_brian;
	}

	self ClearAnim( %cuba_car_turning, 0 );
	self SetAnim( %cuba_car_turning, 1.0, 0.0, 1.0 );
	self SetAnimLimited( self getanim( "turn_left2right" ), 1.0, .5, 0.0 );
	self SetAnimTime( self getanim( "turn_left2right" ), 0.5 );
}

#using_animtree("generic_human");
init_player_anims(version)
{
	if (!IsDefined(version) || version == 1)
	{
		// one hand
		level.scr_anim["player"]["turn_left2right"]	= %ch_cub_b01_carsequence_turnright_1hand_player_brian; 
		level.scr_anim["player"]["turn_right2left"]	= %ch_cub_b01_carsequence_turnleft_1hand_player_brian;
	}
	else
	{
		// two hands
		level.scr_anim["player"]["turn_left2right"]	= %ch_cub_b01_carsequence_turnright_2hands_player_brian;
		level.scr_anim["player"]["turn_right2left"]	= %ch_cub_b01_carsequence_turnleft_2hands_player_brian;
	}

	self StopAnimScripted( .5 );
	self ClearAnim( %root, 0 );
	self SetAnim( %cuba_car_turning, 1.0, 0.0, 1.0 );
	self SetAnimLimited( self getanim( "turn_left2right" ), 1.0, .5, 0.0 );
	self SetAnimTime( self getanim( "turn_left2right" ), 0.5 );
}