#include common_scripts\utility;
#include maps\_utility;
#include maps\cuba_util;
#include maps\_anim;


// --------------------------------------------------------------------------------
// ---- Ambiant effects main thread ----
// --------------------------------------------------------------------------------

ambiant_effect_thread( wait_flag, endon_flag, one_time_on_player )
{
	// get all the mortor points around and on top of the mansion
	level.mortor_points = getstructarray( "mortor_hit_point", "targetname" );
		
	// get all the dust points
	level.dust_points 	= getstructarray( "dust_point", "targetname" );

	// get all physics pulse points
	level.ambiance_pulse_points = getstructarray( "physics_pulse_points", "targetname" );

	// lamps pulses
	level.lamp_pulse_points = getstructarray( "special_pulse_points", "targetname" );

	// window pulses
	level.window_pulse_points = getstructarray( "window_pulse_points", "targetname" );

	// window pulses
	level.electric_pulse_points = getstructarray( "electric_pulse_points", "targetname" );
	
	// reusing the mansion vision trigger for knowing if the player is inside the mansion
	mansion_vision_trig  = GetEnt( "mansion_vision_trig", "targetname" );

	// get the player 
	player = get_players()[0];

	// create a sound entity
	sound_ent = Spawn( "script_origin", ( 0,0,0 ) );

	no_generic_pulse = false;

	flag_wait( wait_flag );

	while( !flag( endon_flag ) )
	{
		if( !player IsTouching( mansion_vision_trig ) || flag( "halt_mansion_ambiance" ) )
		{
			wait(1);
			continue;
		}
		
		// get a forward vector so that this will always happen in front of the player
		forward_vec = AnglesToForward( player GetPlayerAngles() );
	
		// scale distance based on players movement	speed, as we dont want player to miss things
		movement = player GetNormalizedMovement()[0];
		movement = clamp( movement, 0, 1 );

		scale_dist_min = 200;
		scale_dist_max = 400;

		scale_dist = linear_map( movement, 0, 1, scale_dist_max, scale_dist_min );
		scale_dist = Clamp( scale_dist, scale_dist_min, scale_dist_max );

		// find the reference ambiance point
		// this point will be our reference for everythign else for this instance of ambiance
		offset = RandomIntRange( 20, 70 );
		ambiance_point = player.origin + Vector_scale( forward_vec, scale_dist_min + scale_dist ) + ( 0, 0, offset );		
		ambiance_point_far = player.origin + Vector_scale( forward_vec, scale_dist_min + scale_dist * 2 );

		/#
		Print3d( ambiance_point, "AMBIANCE POINT", ( 1, 0, 0 ) );
		#/

		// MORTOR
		mortor_structs = get_array_of_closest( ambiance_point, level.mortor_points, undefined, 2 );
		mortor_struct = mortor_structs[ RandomIntRange( 0, mortor_structs.size ) ];
	
		// DUST - 4 points -  1 near, 3 around
		dust_structs_near = get_array_of_closest( ambiance_point, level.dust_points, undefined, 1 );
		dust_structs_far  = get_array_of_closest( ambiance_point_far, level.dust_points, undefined, 3 );
		dust_structs      = array_combine( dust_structs_near, dust_structs_far );
			
		// GENERIC PHYSICS PULSE
		generic_pulses = get_array_of_closest( ambiance_point, level.ambiance_pulse_points, undefined, 2, 400 );
				
		// special pulse
		special_pulses = get_array_of_closest( ambiance_point, level.lamp_pulse_points, undefined, 2 );
		
		// window pulse
		window_pulses = get_array_of_closest( ambiance_point, level.window_pulse_points, undefined, 2 );

		// electric PULSE
		electric_pulse_points = get_array_of_closest( ambiance_point, level.electric_pulse_points, undefined, 2, 400 );
		
		// move the sound entity to this point
		sound_ent MoveTo( mortor_struct.origin, 0.1 );
		sound_ent waittill( "movedone" );
		
		// make a plane go by
		level thread plane_whizby( sound_ent );
		
		if( !IsDefined( one_time_on_player ) )
			wait( RandomFloatRange( 0.2, 1.5 ) );
		
		// make mortor crtor_points
		mortor_incoming_sound( sound_ent );
					
		if( !IsDefined( one_time_on_player ) )
			wait( RandomFloatRange( 0.5, 1.5 ) );

		player_ambiance_effect( ambiance_point, one_time_on_player );

		// mortor explosion
		mortor_explosion_sound( mortor_struct );

		array_thread( dust_structs, ::dust_spill );
		wait(0.05);
		array_thread( special_pulses, ::physics_pulse_effect, "special" );
		wait(0.05);
		array_thread( window_pulses,  ::physics_pulse_effect, "window" );
		wait(0.05);
		
		// generic pulses
		array_thread( generic_pulses, ::physics_pulse_effect, "generic_pulse" );

		// electric pulse
		array_thread( electric_pulse_points, ::electric_pulse );

		if( IsDefined( one_time_on_player ) ) 
		{
			sound_ent Delete();
			break;
		}

		wait( RandomIntRange( 1, 5 ) );
	}

	if( IsDefined( sound_ent ) ) 
		sound_ent Delete();
	wait(2);
}

player_ambiance_effect( ambiance_point, one_time_on_player )
{
	player = get_players()[0];

	// screen shake and rumble
	thread player_screen_shake_rumble( ambiance_point, one_time_on_player );

	// choose random scale for Earthquake
	if( IsDefined( one_time_on_player ) && one_time_on_player )
	{
		position = player.origin;
		earthquake_scale  = 0.6;
	}
	else
	{
		offset = RandomIntRange( 100, 200 );
		position = player.origin + ( RandomIntRange( offset*-1, offset ), RandomIntRange( offset*-1, offset ), 0 );
		earthquake_scale  = RandomFloatRange( .1, 0.5 );
	}
	
	earthquake_time   = RandomFloatRange( 1.0, 2.5 );
	earthquake_radius = RandomIntRange( 250, 450 );
	
	// play earthquake near player
	if( !IsDefined( level.no_ambient_earthquake ) || !level.no_ambient_earthquake )
		Earthquake( earthquake_scale, earthquake_time, position, earthquake_radius );	
}


player_screen_shake_rumble( ambiance_point, one_time_on_player )
{
	player = get_players()[0];

	if( is_true( one_time_on_player ) )
	{	
		player PlayRumbleOnEntity( "damage_heavy" );
		player SetDoubleVision( 5, 4 );
	}
	else
	{
		// play heavy rumble at the ambiance point
		player PlayRumbleOnEntity( "damage_heavy" );
	}
}

plane_whizby( sound_ent )
{
	// TUEYS SOUND MAGIC
	sound_ent_jet = spawn ("script_origin", sound_ent.origin);
	sound_ent_jet moveto((2776, 5896, -816), 3);	
	sound_ent_jet playsound ("evt_f4_short_apex", "sound_done");	
	sound_ent_jet waittill("sound_done");
	sound_ent_jet delete();
}


mortor_incoming_sound( sound_ent )
{
	sound_ent PlaySound( "prj_mortar_incoming", "sounddone" ); 
	//	sound_ent waittill( "sounddone" );
}

mortor_explosion_sound( sound_ent )
{
	playsoundatposition ("exp_mortar_mansion", sound_ent.origin);

	// notifying this to play the rattle sounds
	level notify ("mansion_exp_hit");
}

dust_spill() // self = dust struct
{
	/#
	Print3d( self.origin, "DUST" );
	#/

	if( cointoss() )
	{	
		PlayFX( level._effect[ "dust_light" ], self.origin, ( 90, 0, 0 ) );
		Playsoundatposition("dst_wood_debris", self.origin  );
	}
	else
	{
		PlayFX( level._effect[ "dust_heavy" ], self.origin, ( 90, 0, 0 ) );
		Playsoundatposition("dst_dust_debris", self.origin);
	}
}

physics_pulse_effect( type ) // self = ambiant pulse point
{

	/#
	Print3d( self.origin, "PULSE" );
	#/
	
	// By default the magnitude is 0.5
	if( !IsDefined( self.script_int ) )	
		self.script_int = 0.5;

	// window shatters with random force
	if( type == "window" )
		self.script_int = RandomFloatRange( 2, 3 );

	// decide explosion radius and damage based on the type of pulse
	if( type == "generic_pulse" )
	{
		inner_radius = 10;
		outer_radius = 50;
		inner_damage = RandomIntRange( 60, 100 );
		outer_damage = RandomIntRange( 10, 20 );
	}
	else // window
	{
		inner_radius = 50;
		outer_radius = 100;
		inner_damage = 5;
		outer_damage = 1;
		self thread play_shutter_sounds();
		self thread play_window_break_sound();
	}

	// get the type pf physics explosion, default cylider
	if( !IsDefined( self.script_string ) )
	{
		explosion_type = "cylinder";
	}
	else
	{
		explosion_type = self.script_string;
	}

	// actual physics pulse
	if( explosion_type == "cylinder" )	
	{
		PhysicsExplosionCylinder( self.origin, outer_radius, inner_radius, self.script_int );
	}
	else
	{
		PhysicsExplosionSphere( self.origin, outer_radius, inner_radius, self.script_int, outer_damage, inner_damage );
	}

	// remove this one if its a generic pulse
	if( type == "generic_pulse" )
	{
		level.ambiance_pulse_points = array_remove( level.ambiance_pulse_points, self );
	}
}

play_shutter_sounds()
{
	wait randomfloatrange(0.05, 1);
	playsoundatposition ("evt_shutter_slam", self.origin);	
}

play_window_break_sound()
{
	wait randomfloatrange(0.05, 1);
	playsoundatposition ("dst_generic_glass_med", self.origin);		
	
}

electric_pulse() // self = electric pulse point
{
	wait ( RandomFloatRange( 0.1, 0.6 ) );

	/#
	Print3d( self.origin, "ELECTRIC" );
	#/

	//SHolmes - getting an assert all the sudden about inner damage being greater than outer so Im switching the two. 
	PhysicsExplosionSphere( self.origin, 100, 50, 2, 100, 150 );
}