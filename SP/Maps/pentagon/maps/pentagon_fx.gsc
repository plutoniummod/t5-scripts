//[ceng] pentagon_fx.gsc (borrowed from pow_fx.gsc)

#include common_scripts\utility;
#include maps\_utility;

main()
{		
	precache_util_fx();
	precache_createfx_fx();
	precache_scripted_fx();
	precache_screenfx();

	//[ceng] (from pow_fx.gsc): "calls the createfx server script (i.e., the list of ambient effects and their attributes)"	
	maps\createfx\pentagon_fx::main();
	
	//[ceng 7/2/2010] Moved this into pentagon.gsc, fog settings will only show up once a player connects, so we need to wait until then.
	//maps\createart\pentagon_art::main();
}

// fx used by util scripts
precache_util_fx()
{

}

// Scripted effects
precache_scripted_fx()
{	
	level._effect[ "chinook_main_blade" ] = LoadFX( "vehicle/props/fx_pent_main_blade_full" );
	level._effect[ "chinook_rear_blade" ] = LoadFX( "vehicle/props/fx_pent_rear_blade_full" );
	
	level._effect[ "car_policelight" ] = LoadFX( "env/light/fx_police_car_flashing" );
	level._effect[ "bike_exhaustpipe" ] = LoadFX( "maps/pentagon/fx_pent_motorcycle_exhaust" );

	level._effect[ "heli_interior_light" ] = LoadFX( "maps/pentagon/fx_pent_ch46_interior_light" );
	level._effect[ "limo_interior_light" ] = LoadFX( "maps/pentagon/fx_pent_limo_interior_light" );
	
	level._effect[ "elevator_interior_light" ] = LoadFX( "maps/pentagon/fx_pent_elevator_light" );
	
	level._effect[ "limo_peelout_exhaust" ] = LoadFX( "maps/pentagon/fx_pent_limo_exhaust" );
	
	level._effect[ "headlight_expensive" ] = LoadFX( "vehicle/light/fx_pent_mp_headlight" );
	level._effect[ "taillight_expensive" ] = LoadFX( "vehicle/light/fx_pent_mp_taillight" );
	
	level._effect[ "lady_smoking" ] = LoadFX( "maps/pentagon/fx_pent_smoker_exhale" );
	level._effect[ "lady_smoking_tip_light" ] = LoadFX( "maps/pentagon/fx_pent_cigarette_tip_smoke" );
	level._effect[ "lady_smoking_tip_smoke" ] = LoadFX( "maps/fullahead/fx_cigarette_lit_smk"); 
	level._effect[ "helicopter_light" ] = LoadFX("maps/pentagon/fx_pent_ch46_spot_light");
	
	level._effect["limo_bloom"] = LoadFX ("maps/pentagon/fx_pent_limo_interior_bloom");
	
	//police car
	level._effect["headlight_cheap"] = LoadFX("vehicle/light/fx_pent_mp_headlight");
	level._effect["taillight_cheap"] = LoadFX("vehicle/light/fx_pent_mp_taillight");
	
	// limo
	level._effect["headlight_limo"] = LoadFX("vehicle/light/fx_us_limo_headlight");
	level._effect["taillight_l_limo"] = LoadFX("vehicle/light/fx_us_limo_taillight_l");
	level._effect["taillight_r_limo"] = LoadFX("vehicle/light/fx_us_limo_taillight_r");

	// motorcycle
	level._effect[ "bike_head_light" ] = LoadFX("vehicle/light/fx_pent_motorcycle_headlight");
	level._effect[ "bike_tail_light" ] = LoadFX("vehicle/light/fx_pent_motorcycle_taillight");
	level._effect[ "bike_siren" ] = LoadFX("env/light/fx_motorcycle_siren_lights");

}

// Ambient effects
precache_createfx_fx()
{
	level._effect["fx_pent_helipad_red_light"]            = LoadFX("maps/pentagon/fx_pent_helipad_red_light");	
	level._effect["fx_pent_hwy_sign_light"]               = LoadFX("maps/pentagon/fx_pent_hwy_sign_light");
	level._effect["fx_pent_cigar_smoke"]                  = LoadFX("maps/pentagon/fx_pent_cigar_smoke");
	level._effect["fx_pent_street_light"]                 = LoadFX("maps/pentagon/fx_pent_street_light");	
	level._effect["fx_pent_street_wind"]                  = LoadFX("maps/pentagon/fx_pent_street_wind");		
	level._effect["fx_pent_helo_treadfx"]                 = LoadFX("maps/pentagon/fx_pent_helo_treadfx");		
	level._effect["fx_pent_flag_light"]                   = LoadFX("maps/pentagon/fx_pent_flag_light");		
	level._effect["fx_glo_studio_light"]                  = LoadFX("maps/pentagon/fx_glo_studio_light");
	level._effect["fx_pent_tinhat_light"]                 = LoadFX("maps/pentagon/fx_pent_tinhat_light");		
	level._effect["fx_pent_water_cooler_bubbles"]         = LoadFX("maps/pentagon/fx_pent_water_cooler_bubbles");			
	level._effect["fx_pent_lamp_desk_light"]              = LoadFX("maps/pentagon/fx_pent_lamp_desk_light");
	level._effect["fx_pent_security_camera"]              = LoadFX("maps/pentagon/fx_pent_security_camera");				
	level._effect["fx_pent_globe_projector"]              = LoadFX("maps/pentagon/fx_pent_globe_projector");
	level._effect["fx_pent_globe_projector_blue"]         = LoadFX("maps/pentagon/fx_pent_globe_projector_blue");	
	level._effect["fx_pent_movie_projector"]              = LoadFX("maps/pentagon/fx_pent_movie_projector");	
	level._effect["fx_pent_tv_glow"]                      = LoadFX("maps/pentagon/fx_pent_tv_glow");		
	level._effect["fx_pent_tv_glow_sm"]                   = LoadFX("maps/pentagon/fx_pent_tv_glow_sm");			
	level._effect["fx_pent_smk_ambient_room"]             = LoadFX("maps/pentagon/fx_pent_smk_ambient_room");	
	level._effect["fx_pent_smk_ambient_room_lg"]          = LoadFX("maps/pentagon/fx_pent_smk_ambient_room_lg");		
	level._effect["fx_pent_smk_ambient_room_sm"]          = LoadFX("maps/pentagon/fx_pent_smk_ambient_room_sm");						

}

precache_screenfx()
{
	PrecacheShellShock("pentagon");
}

//****************************
//VEHICLE UTILITY FX
//****************************
vehicle_lights_on( useExpensiveLights, is_bike ) //self == any vehicle
{
	if( !IsDefined( self.model ) )
	{
		PrintLn( "^1car_lights_on(): self has an invalid model!" );
		return;
	}
	
	//Create an array of common tagnames that we need to attach FX to.
	tags = array
	(	
		"tag_headlight_left",
		"tag_headlight_right",
		"tag_brakelight_left",
		"tag_brakelight_right",
		"tag_taillight_left",
		"tag_taillight_right",
		"tag_light_left_back",
		"tag_light_left_front",
		"tag_light_right_back",
		"tag_light_right_front"
	);
		
	//Assume that we want to use the cheap, non-dynamic lights.
	headlightEffect = level._effect[ "headlight_cheap" ];
	taillightEffect = level._effect[ "taillight_cheap" ];
	
	//But if specifically asked for, use the dynamic lights instead.
	if( is_true( useExpensiveLights ) )
	{

		if(IsDefined(is_bike))
		{

			headlightEffect = level._effect[ "bike_head_light" ];
			taillightEffect = level._effect[ "bike_tail_light" ];
		}
		else
		{
			//IPrintLnBold("bike fx on");
			headlightEffect = level._effect[ "headlight_expensive" ];
			taillightEffect = level._effect[ "taillight_expensive" ];
		}

	}

	//For each tagname we are interested in...
	for( i = 0; i < tags.size; i++ )
	{
		//If the vehicle has the tag...
		if( IsDefined( self GetTagOrigin( tags[i] ) ) )
		{
			//Is the tag for a headlight or taillight/brakelight?
			if( IsSubStr( tags[i], "head" ) || IsSubStr( tags[i], "front" ) )
			{
				PlayFXonTag( headlightEffect, self, tags[i] );
			}
			else if( IsSubStr( tags[i], "tail" ) || IsSubStr( tags[i], "brake" ) || IsSubStr( tags[i], "back" ) )
			{
				PlayFXonTag( taillightEffect, self, tags[i] );
			}
		} 
	}
}

bike_sirens_on() //self == motorcycle vehicle
{
	//playFXonTag( level._effect[ "car_policelight" ], self, "tag_headlight_left" );
	playFXonTag( level._effect[ "bike_siren" ], self, "tag_headlight_left" );
}

//[scrapper] we might want to move these, but here for now.
limo_interior_lights_on()	//self = ent w/ model "t5_veh_us_limo"
{
	if( !isDefined(self.model) || self.model != "t5_veh_us_limo" )
	{
		printLn( "^1limo_interior_lights_on(): self has invalid model!" );
		return;
	}
	
	self.interior_lights = Spawn("script_model", self.origin);
	self.interior_lights SetModel("tag_origin");
	
	//scrapper Don't hate.  
	self.interior_lights LinkTo(self, "tag_body", (0,0,-13.891424), (0,0,0) );
	
	playFXonTag( level._effect["limo_interior_light"], self.interior_lights, "tag_origin" );
}

heli_interior_lights_on()	//self == ent w/ model "vehicle_ch46e_expensive"
{
	if( !isDefined(self.model) || self.model != "vehicle_ch46e_interior" )
	{
		printLn( "^1heli_interior_lights_on(): self has invalid model!" );
		return;
	}
	
	self.interior_lights = Spawn( "script_model", self.origin );
	self.interior_lights SetModel("tag_origin");
	
	// heli's tag_origin != model origin, therefore
	// 0,0,80 from tag_ground is effectively 'model origin' that fx is offsetting from. 
	self.interior_lights LinkTo(self, "tag_ground", (0,0,80), (0,0,0));
	
	playFXonTag( level._effect["heli_interior_light"], self.interior_lights, "tag_origin" );
}

//****************************
//WIND FX
//****************************
//[ceng] - Borrowed from pow_fx.gsc.
wind_initial_setting()
{
	//Exagerating tree sway so that we can see it during Event 1 (Skyline).
	SetSavedDvar( "wind_global_vector", "150 -35 0" );      // change "0 0 0" to your wind vector
	SetSavedDvar( "wind_global_low_altitude", 0);           // change 0 to your wind's lower bound
	SetSavedDvar( "wind_global_hi_altitude", 580);          // change 10000 to your wind's upper bound
	SetSavedDvar( "wind_global_low_strength_percent", 0.75); //0.05); // change 0.5 to your desired wind strength percentage
}

wind_calm_setting()
{
	//Called during Event 2 (Helipad) now that we do not need to exagerate tree sway.
	SetSavedDvar( "wind_global_vector", "150 -35 0" );       // change "0 0 0" to your wind vector
	SetSavedDvar( "wind_global_low_altitude", 0);            // change 0 to your wind's lower bound
	SetSavedDvar( "wind_global_hi_altitude", 580);           // change 10000 to your wind's upper bound
	SetSavedDvar( "wind_global_low_strength_percent", 0.50); //0.05); // change 0.5 to your desired wind strength percentage
}

wind_still_setting()
{
	//Called during Event 4 (Security) now that we do not need any tree sway.
	SetSavedDvar( "wind_global_vector", "150 -35 0" );       // change "0 0 0" to your wind vector
	SetSavedDvar( "wind_global_low_altitude", 0);            // change 0 to your wind's lower bound
	SetSavedDvar( "wind_global_hi_altitude", 580);           // change 10000 to your wind's upper bound
	SetSavedDvar( "wind_global_low_strength_percent", 0.0);  // change 0.5 to your desired wind strength percentage
}

//***************************
//	DEPTH OF FIELD
//***************************
//scrapper Depth of field settings. 
dof_chopper_setting(time)
{
	if(!isDefined(time))
	{
		time = 1;
	}
	near_start =  0;
	near_end   = 32;
	far_start = 7000;
	far_end = 20000;
	near_blur = 6;
	far_blur = 0.25;
	player = GetPlayers()[0];	
	player thread tweenDof( near_start, near_end, far_start, far_end, near_blur, far_blur, time);
	
}

dof_default_setting(time)
{
	if(!isDefined(time))
	{
		time = 1;
	}
	
	//[ceng 7/14/2010] These numbers are the defaults for DOF tweaks, not what we really want.
	//near_start = 10;
	//near_end = 60;
	
	near_start =  0;
	near_end   = 32;
	far_start = 1000;
	far_end = 20000;
	near_blur = 6;
	far_blur = 0.25;
	player = GetPlayers()[0];	
	player thread tweenDof( near_start, near_end, far_start, far_end, near_blur, far_blur, time);
	
	//[ceng 7/14/2010] This blur is not applicable since the player will never be holding a gun,
	//and the arms that are visible are actually a full body model we are linking the player to.
	//vm_start = 2;
	//vm_end = 8;
	//player SetViewModelDepthOfField(vm_start, vm_end);
}

dof_limo_setting(time)
{
	if(!isDefined(time))
	{
		time = 5;
	}
	near_start = 0;
	near_end = 15;
	far_start = 450;
	far_end = 2500;
	near_blur = 4;
	far_blur = 1.5;
	
	player = GetPlayers()[0];	
	player thread tweenDof( near_start, near_end, far_start, far_end, near_blur, far_blur, time);
	
}

dof_tarmac_setting(time)
{
	if(!isDefined(time))
	{
		time = 1;
	}
	near_start =  0;
	near_end   = 32;
	far_start = 9900;
	far_end = 20000;
	near_blur = 4;
	far_blur = 0.7;
	player = GetPlayers()[0];	
	player thread tweenDof( near_start, near_end, far_start, far_end, near_blur, far_blur, time);
	
}

dof_road_setting(time)
{
	if(!isDefined(time))
	{
		time = 1;
	}
	near_start =  0;
near_end   = 320;
	far_start = 2900;
	far_end = 4300;
	near_blur = 6;
	far_blur = 1.85;

	player = GetPlayers()[0];	
	player thread tweenDof( near_start, near_end, far_start, far_end, near_blur, far_blur, time);
	
}

dof_security_setting(time)
{
	if(!isDefined(time))
	{
		time = 1;
	}
	near_start =  0;
	near_end   = 32;
	far_start = 221;
	far_end = 1100;
	near_blur = 6;
	far_blur = 1;

	player = GetPlayers()[0];	
	player thread tweenDof( near_start, near_end, far_start, far_end, near_blur, far_blur, time);
	
}

dof_pool_setting(time)
{
	if(!isDefined(time))
	{
		time = 1;
	}
	near_start =  0;
	near_end   = 18;
	far_start = 221;
	far_end = 2000;
	near_blur = 6;
	far_blur = 1;
	player = GetPlayers()[0];	
	player thread tweenDof( near_start, near_end, far_start, far_end, near_blur, far_blur, time);
	
}

dof_warroom_setting(time)
{
	if(!isDefined(time))
	{
		time = 1;
	}
	near_start =  0;
	near_end   = 18;
	far_start = 194;
	far_end = 1800;
	near_blur = 6;
	far_blur = 0.6;
	player = GetPlayers()[0];	
	player thread tweenDof( near_start, near_end, far_start, far_end, near_blur, far_blur, time);
	
}

dof_jfk_setting(time)
{
	if(!isDefined(time))
	{
		time = 1;
	}
	near_start =  0;
	near_end   = 18;
	far_start = 145;
	far_end = 485;
	near_blur = 6;
	far_blur = 0.6;
	player = GetPlayers()[0];	
	player thread tweenDof( near_start, near_end, far_start, far_end, near_blur, far_blur, time);
	
}

//scrapper utility to tween the depth of field over a given time
//	does not work for viewmodel, there's no way to get our current value? 
//	self == player
tweenDof(near_start, near_end, far_start, far_end, near_blur, far_blur, time)
{
	old_near_start = self GetDepthOfField_NearStart();
	old_near_end = self GetDepthOfField_NearEnd();
	old_far_start = self GetDepthOfField_FarStart();
	old_far_end = self GetDepthOfField_FarEnd();
	old_near_blur = self GetDepthOfField_NearBlur();
	old_far_blur = self GetDepthOfField_FarBlur();
	
	endTime = time;
	deltaTime = 0;
	
	while( endTime > deltaTime )
	{
		if(endTime == 0)
		{
			break;
		}
		ratio = deltaTime/endTime;
		delta_near_start = calcDof(old_near_start, near_start, ratio);
		delta_near_end = calcDof(old_near_end, near_end, ratio);
		delta_far_start = calcDof(old_far_start, far_start, ratio);
		delta_far_end = calcDof(old_far_end, far_end, ratio);
		delta_near_blur = calcDof(old_near_blur, near_blur, ratio);
		delta_far_blur = calcDof(old_far_blur, far_blur, ratio);
		
		self SetDepthOfField(delta_near_start, delta_near_end, delta_far_start, delta_far_end, delta_near_blur, delta_far_blur);
		
		//wait, then loop.
		wait 0.05;
		deltaTime = deltaTime + 0.05;
	}
	
	//done with tween, set to values. 
	self SetDepthOfField(near_start, near_end, far_start, far_end, near_blur, far_blur);
}

calcDof(old, new, ratio)
{
	return (((new-old)*ratio)+old);
}

//**************************
//	SCRIPTED LEVEL FX
//**************************
//[scrapper] Watercooler turns on
//self == guy who notetrack was played on
watercooler_start( guy )
{
	exploder( 100 );
}

//[scrapper]] Whiteout at the end of the level. 
whiteout(time) //self == level 
{
	//hardcoded because I don't know how to get these? 
	base_exposure = 1.25;
	base_tint = 0;
	base_streak = 0.25;
	
	//hardcoded dest values
	exposure = 16;
	tint = 1;
	streak = 3;
	
	incs = int((time)/.05);
	
	inc_exp = ( exposure - base_exposure )/incs;
	inc_tint = ( tint - base_tint )/incs;
	inc_streak = ( streak - base_streak )/incs;
	
	curr_exposure = base_exposure;
	curr_tint = base_tint;
	curr_streak = base_streak;
	
	SetDvar( "r_bloomTweaks", "1" );
	SetDvar( "r_exposureTweak", "1" );
	
	for ( i=0; i<incs; i++ )
	{
		exposure_val = curr_exposure;
		tint_val = "" + curr_tint + " " + curr_tint + " " + curr_tint + " 1";
		streak_val = "" + curr_streak + " " + curr_streak + " " + curr_streak + " 1";
		
		setdvar( "r_exposureValue", exposure_val );
		setdvar( "r_bloomStreakXTint", tint_val );
		setdvar( "r_bloomStreakLevels0", streak_val );
		
		curr_exposure += inc_exp;
		curr_tint += inc_tint;
		curr_streak += inc_streak;
		
		wait .05;
	}
	
	//Add white fade to flesh out the bloom effect.
	level maps\pentagon_code::hud_utility_show( "white", 0.5 );
	
	//Now that the whitescreen is fully opaque, we can deactivate the bloom.
	//NOTE: must return Dvars to default before handing off to the next level!
	SetDvar( "r_bloomTweaks", "0" );
	SetDvar( "r_exposureTweak", "0" );
	
	//Let the whitescreen settle in before we move onto Flashpoint.
	wait 0.5;
}


//**************************
//Visual Settings, Bundled!
//**************************
set_helicopter_visuals( lerpTime )
{	
	if( !IsDefined( lerpTime ) )
	{
		lerpTime = 0.05;
	}
	
	//--------
	//Depth of Field
	//--------
	level dof_chopper_setting( lerpTime );

	//--------
	//Fog
	//--------
	//No change from default.
	
	//--------
	//Shock
	//--------
	get_players()[0] StopShellShock();
	
	//--------
	//Timescale
	//--------
	level maps\pentagon_code::fast_forward_end();
	
	//--------
	//Visionset
	//--------
	get_players()[0] set_vision_set( "pentagon", lerpTime );
	//SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	//SetSavedDvar( "r_lightGridIntensity", 1.85 );
	//SetSavedDvar( "r_lightGridContrast", 0.5 );
	
	//--------
	//Wind
	//--------
	level wind_calm_setting();
}

set_tarmac_visuals( lerpTime )
{
	if( !IsDefined( lerpTime ) )
	{
		lerpTime = 3;
	}
	
	//--------
	//Depth of Field
	//--------
	level dof_tarmac_setting( lerpTime );

	//--------
	//Fog
	//--------
	level set_tarmac_fog( lerpTime );
	
	//--------
	//Shock
	//--------
	get_players()[0] StopShellShock();
	
	//--------
	//Timescale
	//--------
	level maps\pentagon_code::fast_forward_end();
	
	//--------
	//Visionset
	//--------
	get_players()[0] set_vision_set( "pentagon_tarmac", lerpTime );
	SetSavedDvar( "r_skyColorTemp", 6700.0 );
	
	//--------
	//Wind
	//--------
	level wind_calm_setting();
}

set_limousine_visuals( lerpTime )
{
	if( !IsDefined( lerpTime ) )
	{
		lerpTime = 5;
	}
	
	//--------
	//Depth of Field
	//--------
	level dof_limo_setting( lerpTime );

	//--------
	//Fog
	//--------
	level set_road_fog( lerpTime );
	
	//--------
	//Shock
	//--------
	get_players()[0] StopShellShock();
	
	//--------
	//Timescale
	//--------
	level maps\pentagon_code::fast_forward_end();
	
	//--------
	//Visionset
	//--------
	get_players()[0] set_vision_set( "pentagon_limousine", lerpTime );
	
	//--------
	//Wind
	//--------
	level wind_calm_setting();
}

set_highway_visuals( lerpTime )
{
	if( !IsDefined( lerpTime ) )
	{
		lerpTime = 2;
	}
	
	//--------
	//Depth of Field
	//--------
	level dof_road_setting( lerpTime );

	//--------
	//Fog
	//--------
	level set_road_fog( lerpTime );
	
	//--------
	//Shock
	//--------
	get_players()[0] StopShellShock();
	
	//--------
	//Timescale
	//--------
	//TODO: MOVE TIMESCALE FROM PENTAGON.GSC TO HERE?
	//level maps\pentagon_code::fast_forward_end();
	
	//--------
	//Visionset
	//--------
	get_players()[0] set_vision_set( "pentagon_highway", lerpTime );
	
	//--------
	//Wind
	//--------
	level wind_calm_setting();
}

set_security_visuals( lerpTime )
{
	if( !IsDefined( lerpTime ) )
	{
		lerpTime = 0.05;
	}
	
	//--------
	//Depth of Field
	//--------
	level dof_security_setting( lerpTime );

	//--------
	//Fog
	//--------
	level set_security_fog( lerpTime );
	
	//--------
	//Shock
	//--------
	get_players()[0] StopShellShock();
	
	//--------
	//Timescale
	//--------
	level maps\pentagon_code::fast_forward_end();
	
	//--------
	//Visionset
	//--------
	get_players()[0] set_vision_set( "pentagon_interior", lerpTime );
	
	//--------
	//Wind
	//--------
	level wind_still_setting();
}

set_security_fastforward_visuals( guy, lerpTime )
{
	if( !IsDefined( lerpTime ) )
	{
		lerpTime = 0.05;
	}
	
	//--------
	//Fog
	//--------
	level dof_pool_setting( lerpTime );
  	
	//--------
	//Visionset
	//--------
	get_players()[0] set_vision_set( "pentagon_speed_security", lerpTime );
	
	//--------
	//Timescale
	//--------
	level maps\pentagon_code::fast_forward_begin();
	
	//--------
	//Shock
	//--------
	get_players()[0] ShellShock( "pentagon", 60, true );
	
	//--------
	//Depth of Field
	//--------
	//No change.
	
	//--------
	//Wind
	//--------
	//No change.
}

set_pool_visuals( guy, lerpTime )
{
	if( !IsDefined( lerpTime ) )
	{
		lerpTime = 3;
	}
	
	//--------
	//Depth of Field
	//--------
	level dof_pool_setting( lerpTime );
	
	//--------
	//Fog
	//--------
	level set_pool_fog( lerpTime );
  
 	//--------
	//Shock
	//--------
	get_players()[0] StopShellShock();
  
 	//--------
	//Timescale
	//--------
	level maps\pentagon_code::fast_forward_end();
  
  //--------
  //Visionset
  //--------  
  get_players()[0] set_vision_set( "pentagon_interior", lerpTime );

	//--------
	//Wind
	//--------
	level wind_still_setting();
}

set_elevator_fastforward_visuals( lerpTime )
{
	if( !IsDefined( lerpTime ) )
	{
		lerpTime = 0.05;
	}
	
	//--------
	//Depth of Field
	//--------
	level dof_default_setting( lerpTime );
	
	//--------
	//Fog
	//--------
	level set_pool_fog( lerpTime );
  
 	//--------
	//Shock
	//--------
	get_players()[0] StopShellShock();
  
 	//--------
	//Timescale
	//--------
	level maps\pentagon_code::fast_forward_begin();
  
  //--------
  //Visionset
  //--------  
  get_players()[0] set_vision_set( "pentagon_speed_elevator", lerpTime );

	//--------
	//Wind
	//--------
	level wind_still_setting();
}

set_warroom_visuals( lerpTime )
{
	if( !IsDefined( lerpTime ) )
	{
		lerpTime = 0.05;
	}
		
	//--------
	//Depth of Field
	//--------
	level dof_warroom_setting( lerpTime );
	
	//--------
	//Fog
	//--------
	level set_warroom_fog( lerpTime );

 	//--------
	//Shock
	//--------
	get_players()[0] StopShellShock();
  
 	//--------
	//Timescale
	//--------
	level maps\pentagon_code::fast_forward_end();
  
  //--------
  //Visionset
  //--------  
	get_players()[0] set_vision_set( "pentagon_warroom", lerpTime );

	//--------
	//Wind
	//--------
	level wind_still_setting();
}

set_briefing_visuals( lerpTime )
{
	if( !IsDefined( lerpTime ) )
	{
		lerpTime = 5;
	}
	
	//--------
	//Depth of Field
	//--------
	level dof_jfk_setting( lerpTime );
	
	//--------
	//Fog
	//--------
	level set_jfk_fog( lerpTime );

 	//--------
	//Shock
	//--------
	get_players()[0] StopShellShock();
  
 	//--------
	//Timescale
	//--------
	level maps\pentagon_code::fast_forward_end();
  
  //--------
  //Visionset
  //--------  
	get_players()[0] set_vision_set( "pentagon_kennedy", lerpTime );

	//--------
	//Wind
	//--------
	level wind_still_setting();
}

set_briefing_bloom_visuals( lerpTime )
{
	if( !IsDefined( lerpTime ) )
	{
		lerpTime = 0.05;
	}
	
	//--------
	//Depth of Field
	//--------
	level dof_jfk_setting( lerpTime );
	
	//--------
	//Fog
	//--------
	level set_jfk_fog( lerpTime );

 	//--------
	//Shock
	//--------
	get_players()[0] StopShellShock();
  
 	//--------
	//Timescale
	//--------
	level maps\pentagon_code::fast_forward_end();
  
  //--------
  //Visionset
  //--------  
	get_players()[0] set_vision_set( "pentagon_kennedy_bloom", lerpTime );

	//--------
	//Wind
	//--------
	level wind_still_setting();
}

//**************************
//	FOG
//**************************
//[scrapper] for no-trigger use, fog gets called with the vision sets here all at once

set_tarmac_fog(time)
{
	start_dist = 728.729;
	half_dist = 6666;
	half_height = 1198.79;
	base_height = -443;
	fog_r = 0.176471;
	fog_g = 0.25098;
	fog_b = 0.286275;
	fog_scale = 3.26;
	sun_col_r = 0.964706;
	sun_col_g = 0.682353;
	sun_col_b = 0.352941;
	sun_dir_x = 0.41;
	sun_dir_y = 0.88;
	sun_dir_z = 0.23;
	sun_start_ang = 0;
	sun_stop_ang = 52;
	//time = 0;
	max_fog_opacity = 0.88;



  setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
        sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang,
        sun_stop_ang, time, max_fog_opacity);
}

set_road_fog(time)
{
	start_dist = 827.337;
	half_dist = 588.64;
	half_height = 435.318;
	base_height = -443;
	fog_r = 0.0901961;
	fog_g = 0.129412;
	fog_b = 0.113725;
	fog_scale = 5.75426;
	sun_col_r = 0.603922;
	sun_col_g = 0.482353;
	sun_col_b = 0.211765;
	sun_dir_x = 0.45522;
	sun_dir_y = 0.890105;
	sun_dir_z = 0.0220971;
	sun_start_ang = 0;
	sun_stop_ang = 50.9821;
	//time = 0;
	max_fog_opacity = 0.803556;




  setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
        sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang,
        sun_stop_ang, time, max_fog_opacity);
}

set_security_fog(time)
{
	start_dist = 315.668;
	half_dist = 444.668;
	half_height = 4921.28;
	base_height = 143.872;
	fog_r = 0.145098;
	fog_g = 0.243137;
	fog_b = 0.235294;
	fog_scale = 2.08045;
	sun_col_r = 1;
	sun_col_g = 0.682353;
	sun_col_b = 0.305882;
	sun_dir_x = 0.441431;
	sun_dir_y = 0.871025;
	sun_dir_z = 0.215535;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	//time = 0;
	max_fog_opacity = 0.641291;



  setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
        sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang,
        sun_stop_ang, time, max_fog_opacity);
}

set_pool_fog(time)
{
	start_dist = 315.668;
	half_dist = 462.399;
	half_height = 4921.28;
	base_height = 143.872;
	fog_r = 0.145098;
	fog_g = 0.243137;
	fog_b = 0.235294;
	fog_scale = 2.08045;
	sun_col_r = 1;
	sun_col_g = 0.682353;
	sun_col_b = 0.305882;
	sun_dir_x = 0.441431;
	sun_dir_y = 0.871025;
	sun_dir_z = 0.215535;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	//time = 0;
	max_fog_opacity = 0.641291;


  setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
        sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang,
        sun_stop_ang, time, max_fog_opacity);
}

set_warroom_fog(time)
{
	
  start_dist = 277.993;
	half_dist = 2009.68;
	half_height = 4921.28;
	base_height = -632.83;
	fog_r = 0.105882;
	fog_g = 0.243137;
	fog_b = 0.235294;
	fog_scale = 2.78243;
	sun_col_r = 0.313726;
	sun_col_g = 0.478431;
	sun_col_b = 0.439216;
	sun_dir_x = 0.967272;
	sun_dir_y = 0.253507;
	sun_dir_z = 0.0109187;
	sun_start_ang = 0;
	sun_stop_ang = 89.3751;
	//time = 0;
	max_fog_opacity = 1;



  setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
        sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang,
        sun_stop_ang, time, max_fog_opacity);
}

set_jfk_fog(time)
{
	
 start_dist = 215.624;
	half_dist = 272.807;
	half_height = 4921.28;
	base_height = -632.83;
	fog_r = 0.247059;
	fog_g = 0.235294;
	fog_b = 0.2;
	fog_scale = 5.89687;
	sun_col_r = 0.329412;
	sun_col_g = 0.364706;
	sun_col_b = 0.411765;
	sun_dir_x = 0.967272;
	sun_dir_y = 0.253507;
	sun_dir_z = 0.0109187;
	sun_start_ang = 0;
	sun_stop_ang = 89.3751;
	//time = 0;
	max_fog_opacity = 1;


  setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
        sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang,
        sun_stop_ang, time, max_fog_opacity);
}

smoking_lady(guy)
{
	PlayFXOnTag(level._effect["lady_smoking"], guy, "j_head");
}