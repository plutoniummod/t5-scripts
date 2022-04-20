//_createart generated.  modify at your own risk. Changing values should be fine.

#include common_scripts\utility;
#include maps\_utility;

main()
{
	//SetDvar("r_heroLightScale", "1 1 1"); depricated hero lighting
	/////////////////new hero lighting//////////////////////////////
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.26 );
	SetSavedDvar( "r_lightGridContrast", 0.0 );
	
	level.tweakfile = true;
 
	//* Fog section * 

	setdvar("scr_fog_exp_halfplane", "3759.28");
	setdvar("scr_fog_exp_halfheight", "243.735");
	setdvar("scr_fog_nearplane", "901.593");
	setdvar("scr_fog_red", "0.806694");
	setdvar("scr_fog_green", "0.462521");
	setdvar("scr_fog_blue", "0.7624");
	setdvar("scr_fog_baseheight", "-475.268");

	// STREET SECTION
/* pre disc bkup
	start_dist = 512.24;
	half_dist = 485.74;
	half_height = 379.546;
	base_height = -844.179;
	fog_r = 0.129412;
	fog_g = 0.184314;
	fog_b = 0.196078;
	fog_scale = 5.43234;
	sun_col_r = 0.52549;
	sun_col_g = 0.411765;
	sun_col_b = 0.329412;
	sun_dir_x = 0.796269;
	sun_dir_y = 0.553714;
	sun_dir_z = 0.243631;
	sun_start_ang = 0;
	sun_stop_ang = 32.126;
	time = 0;
	max_fog_opacity = 0.840488;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
*/
/* old
		start_dist = 512.24;
	half_dist = 485.741;
	half_height = 379.546;
	base_height = -844.179;
	fog_r = 0.133333;
	fog_g = 0.145098;
	fog_b = 0.156863;
	fog_scale = 7.82455;
	sun_col_r = 0.44;
	sun_col_g = 0.501961;
	sun_col_b = 0.501961;
	sun_dir_x = 0.796269;
	sun_dir_y = 0.553714;
	sun_dir_z = 0.243631;
	sun_start_ang = 0;
	sun_stop_ang = 32.126;
	time = 0;
	max_fog_opacity = 0.840488;
*/
//new
start_dist = 357.267;
	half_dist = 391.755;
	half_height = 183.252;
	base_height = -844.179;
	fog_r = 0.113725;
	fog_g = 0.145098;
	fog_b = 0.156863;
	fog_scale = 8.77963;
	sun_col_r = 0.176471;
	sun_col_g = 0.239216;
	sun_col_b = 0.313726;
	sun_dir_x = 0.796269;
	sun_dir_y = 0.553714;
	sun_dir_z = 0.243631;
	sun_start_ang = 0;
	sun_stop_ang = 51.7103;
	time = 0;
	max_fog_opacity = 0.840488;


	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	VisionSetNaked( "cuba", 0 );

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.25 );
	SetSavedDvar( "r_lightGridContrast", 0.2 );
	
	level thread sky_transition();
}

sky_transition()
{
	sunlight = GetDvarInt("r_lightTweakSunLight");
	color = (1, 0.813, 0.7);	// original worldspawn setting

	transition_time = 0;
	if (!IsDefined(level.start_point)
		|| level.start_point == "default"
		|| level.start_point == "bar"
		|| level.start_point == "street"
		|| level.start_point == "alley"
		|| level.start_point == "drive"
		|| level.start_point == "goatpath")
	{
		set_night_values();
		flag_wait("transition_sky");
		transition_time = .1;
	}

	// Day Values /////////////////////////////////////////////////////////

	level thread set_sunlight(transition_time, sunlight, color, undefined, true);
	
	start_dist = 300.619;
	half_dist = 1216.1;
	half_height = 1233.18;
	base_height = -2265.55;
	fog_r = 0.196078;
	fog_g = 0.235294;
	fog_b = 0.27451;
	fog_scale = 10;
	sun_col_r = 0.984314;
	sun_col_g = 0.678431;
	sun_col_b = 0.490196;
	sun_dir_x = 0.796269;
	sun_dir_y = 0.553714;
	sun_dir_z = 0.243631;
	sun_start_ang = 0;
	sun_stop_ang = 39.8454;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	VisionSetNaked( "cuba_sunrise", transition_time );
	SetSavedDvar( "r_skyColorTemp", 5500.0 );

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.3 );
	SetSavedDvar( "r_lightGridContrast", 0.3 );
}

set_night_values()
{	
	// Night Values /////////////////////////////////////////////////////////
	SetSavedDvar("r_lightTweakSunLight", 11);
	SetSunLight(0.661, 0.6228, 0.727);
	SetSavedDvar( "sm_sunSampleSizeNear", "0.26" );
}

set_sunlight(time, sunlight, color, dir, transition_sky)
{
	level.sun_light = GetDvarInt("r_lightTweakSunLight");

	if (!IsDefined(level.sun_color))
	{
		level.sun_color = array(0.654902, 0.827451, 0.913725); // original color
	}

	if (!IsDefined(level.sun_dir))
	{
		level.sun_dir = GetMapSunDirection();
	}

	step = .05;
	t = 0;
	
	if (time < .05)
	{
		time = .05;
	}

	while (t < time)
	{
		wait(step);
		t += step;

		lerp_t = linear_map(t, 0, time, 0, 1);

		if (IsDefined(sunlight))
		{
			d_sunlight = LerpFloat(level.sun_light, sunlight, lerp_t);
			SetSavedDvar( "r_lightTweakSunLight", d_sunlight );
		}

		if (IsDefined(color))
		{
			d_suncolor = LerpVector((level.sun_color[0], level.sun_color[1], level.sun_color[2]), color, lerp_t);
			SetSunLight( d_suncolor[0], d_suncolor[1], d_suncolor[2] );
		}

		if (IsDefined(dir))
		{
			d_sundir = LerpVector(level.sun_dir, dir, lerp_t);
			SetSunDirection(d_sundir);
		}

		if (transition_sky)
		{
			d_skytrans = LerpFloat(0, 1, lerp_t);
			SetSavedDvar( "r_skyTransition", d_skytrans );
		}
	}

	level.sun_color = color;
	level.sun_dir = dir;
}

set_cuba_fog(val)
{
	if( IsDefined( level.current_fog_val ) && level.current_fog_val == val )
		return;

	start_dist = undefined;
	half_dist = undefined;
	half_height = undefined;
	base_height = undefined;
	fog_r = undefined;
	fog_g = undefined;
	fog_b = undefined;
	fog_scale = undefined;
	sun_col_r = undefined;
	sun_col_g = undefined;
	sun_col_b = undefined;
	sun_dir_x = undefined;
	sun_dir_y = undefined;
	sun_dir_z = undefined;
	sun_start_ang = undefined;
	sun_stop_ang = undefined;
	time = undefined;
	max_fog_opacity = undefined;

	if( val == "zipline" )  // player on the zipline
	{
		start_dist = 174.513;
		half_dist = 2514.54;
		half_height = 370.944;
		base_height = -1593.72;
		fog_r = 0.309804;
		fog_g = 0.333333;
		fog_b = 0.360784;
		fog_scale = 10;
		sun_col_r = 0.984314;
		sun_col_g = 0.678431;
		sun_col_b = 0.490196;
		sun_dir_x = 0.796269;
		sun_dir_y = 0.553714;
		sun_dir_z = 0.243631;
		sun_start_ang = 0;
		sun_stop_ang = 53.6818;
		time = 5;
		max_fog_opacity = 0.984794;

		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
		SetSavedDvar( "r_lightGridIntensity", 1.3 );
		SetSavedDvar( "r_lightGridContrast", 0.3 );
	}

	if( val == "compound" ) // player in compound
	{
		start_dist = 174.513;
		half_dist = 5137.94;
		half_height = 283.092;
		base_height = -393.713;
		fog_r = 0.309804;
		fog_g = 0.333333;
		fog_b = 0.360784;
		fog_scale = 10;
		sun_col_r = 0.984314;
		sun_col_g = 0.678431;
		sun_col_b = 0.490196;
		sun_dir_x = 0.796269;
		sun_dir_y = 0.553714;
		sun_dir_z = 0.243631;
		sun_start_ang = 0;
		sun_stop_ang = 53.6818;
		time = 5;
		max_fog_opacity = 0.984794;

		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
		SetSavedDvar( "r_lightGridIntensity", 1.3 );
		SetSavedDvar( "r_lightGridContrast", 0.3 );
	}

	if(val == "mansion") // player is inside the mansion
	{
		start_dist = 25.6407;
		half_dist = 159.015;
		half_height = 185.533;
		base_height = -74.972;
		fog_r = 0.12549;
		fog_g = 0.14902;
		fog_b = 0.164706;
		fog_scale = 5.04708;
		sun_col_r = 0.952941;
		sun_col_g = 0.584314;
		sun_col_b = 0.341176;
		sun_dir_x = 0.796269;
		sun_dir_y = 0.553714;
		sun_dir_z = 0.243631;
		sun_start_ang = 0;
		sun_stop_ang = 39.8454;
		time = 5;
		max_fog_opacity = 1;

		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
		SetSavedDvar( "r_lightGridIntensity", 1.25 );
		SetSavedDvar( "r_lightGridContrast", 0.15 );

		SetSavedDvar( "r_skyColorTemp", 6500.0 );

	}

	if(val == "balcony") // player is inside the mansion
	{ 
		start_dist = 25.6407;
		half_dist = 429.553;
		half_height = 185.533;
		base_height = -74.972;
		fog_r = 0.309804;
		fog_g = 0.333333;
		fog_b = 0.360784; 
		fog_scale = 5.04708;
		sun_col_r = 0.952941;
		sun_col_g = 0.517647;
		sun_col_b = 0.247059;
		sun_dir_x = 0.796269;
		sun_dir_y = 0.553714;
		sun_dir_z = 0.243631;
		sun_start_ang = 0;
		sun_stop_ang = 39.8454;
		time = 5;
		max_fog_opacity = 1;

		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
		SetSavedDvar( "r_lightGridIntensity", 1.3 );
		SetSavedDvar( "r_lightGridContrast", 0.3 );
	}

	if(val == "courtyard")  // player is in the courtyard battle
	{
		start_dist = 61.1097;
		half_dist = 1000.999;
		half_height = 186.802;
		base_height = -74.972;
		fog_r = 0.309804;
		fog_g = 0.333333;
		fog_b = 0.360784;
		fog_scale = 10;
		sun_col_r = 1;
		sun_col_g = 0.537255;
		sun_col_b = 0.286275;
		sun_dir_x = 0.796269;
		sun_dir_y = 0.553714;
		sun_dir_z = 0.243631;
		sun_start_ang = 0;
		sun_stop_ang = 39.8454;
		time = 3;
		max_fog_opacity = 0.964425;

		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
		SetSavedDvar( "r_lightGridIntensity", 1.3 );
		SetSavedDvar( "r_lightGridContrast", 0.3 );

		SetSavedDvar( "sm_sunSampleSizeNear", "0.54" );

	}

	if(val == "airfield_start")  // as player is running thru the cane field to the airfield
	{
		start_dist = 1485.84;
		half_dist = 1022.07;
		half_height = 780.204;
		base_height = -1106.06;
		fog_r = 0.309804;
		fog_g = 0.333333;
		fog_b = 0.360784;
		fog_scale = 10;
		sun_col_r = 0.992157;
		sun_col_g = 0.713726;
		sun_col_b = 0.517647;
		sun_dir_x = 0.913097;
		sun_dir_y = 0.385417;
		sun_dir_z = 0.133071;
		sun_start_ang = 0;
		sun_stop_ang = 53.8607;
		time = 5;
		max_fog_opacity = 0.724458;

		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
		SetSavedDvar( "r_lightGridIntensity", 1.3 );
		SetSavedDvar( "r_lightGridContrast", 0.3 );

	}

	if(val == "airfield_rappel") // player rappels down on the airfield, for airfield
	{
		start_dist = 156.779;
		half_dist = 6200;
		half_height = 345.986;
		base_height = -1106.06;
		fog_r = 0.309804;
		fog_g = 0.333333;
		fog_b = 0.360784;
		fog_scale = 10;
		sun_col_r = 0.992157;
		sun_col_g = 0.713726;
		sun_col_b = 0.517647;
		sun_dir_x = 0.796269;
		sun_dir_y = 0.553714;
		sun_dir_z = 0.243631;
		sun_start_ang = 0;
		sun_stop_ang = 53.6818;
		time = 5;
		max_fog_opacity = 0.71546;

		SetSavedDvar( "sm_sunSampleSizeNear", "0.8" );

		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
		SetSavedDvar( "r_lightGridIntensity", 1.3 );
		SetSavedDvar( "r_lightGridContrast", 0.3 );

	}

	if(val == "airfield_outro")	//outro, looking at the Rasulka
	{
		start_dist = 204.799;
		half_dist = 3014.41;
		half_height = 513.74;
		base_height = -2873.79;
		fog_r = 0.258824;
		fog_g = 0.345098;
		fog_b = 0.423529;
		fog_scale = 10;
		sun_col_r = 0.984314;
		sun_col_g = 0.678431;
		sun_col_b = 0.490196;
		sun_dir_x = 0.796269;
		sun_dir_y = 0.553714;
		sun_dir_z = 0.243631;
		sun_start_ang = 0;
		sun_stop_ang = 39.8454;
		time = 0;
		max_fog_opacity = 1;
		
		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
		SetSavedDvar( "r_lightGridIntensity", 1.3 );
		SetSavedDvar( "r_lightGridContrast", 0.1 );
		
		SetSavedDvar( "sm_sunSampleSizeNear", "0.08" );
		SetSavedDvar( "r_lightTweakSunDirection", "-10.5 70 0" );


	}

	AssertEx( IsDefined( start_dist ), "set_cuba_fog : Unsupported type of event " + val );

	/#
		IPrintLn( "FOG:" + val );
	#/

	level.current_fog_val = val;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);	
}

set_cuba_dof(val)
{
	player = get_players()[0];

	near_blur = undefined;
	far_blur = undefined;
	near_start = undefined;
	near_end = undefined;
	far_start = undefined;
	far_end = undefined;

	// settings for the bar
	if(val == "bar")
	{
		//wait(1.0);
		near_blur = 5;
		far_blur = 2.1;
		near_start = 0;
		near_end = 26;
		far_start = 270;
		far_end = 600;
	}

	// settings for the zipline
	if(val == "zipline")
	{
		near_blur = 6;
		far_blur = 1.8;
		near_start = 0;
		near_end = 10;
		far_start = 1000;
		far_end = 7000;
	}
	
	// settings for the breach before assasination
	if(val == "pre_assasination")
	{
		near_blur = 6;
		far_blur = 1.8;
		near_start = 0;
		near_end = 32;
		far_start = 350;
		far_end = 500;
	}

	// settings for the assasination
	if(val == "assasination")
	{
		near_blur = 6;
		far_blur = 1.8;
		near_start = 0;
		near_end = 32;
		far_start = 330;
		far_end = 352;
	}

		// settings for the foward rappel
	if(val == "forward_rappel")
	{
		near_blur = 4;
		far_blur = 1.8;
		near_start = 0;
		near_end = 32;
		far_start = 475;
		far_end = 1350;
	}
		
	//settings for the outro animation when looking at the Rusalka
	if(val == "airfield_outro")
	{
		near_blur = 4;
		far_blur = 0.53;
		near_start = 0;
		near_end = 6;
		far_start = 190;
		far_end = 415;
	}

	AssertEx( IsDefined( near_blur ), "set_cuba_dof : Unsupported type of event " + val );

	/#
	IPrintLn( "DOF:" + val );
	#/
	
	//SetDepthOfField( <near start>, <near end>, <far start>, <far end>, <near blur>, <far blur> )
	player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur );

}

reset_cuba_dof()
{
	/#
	IPrintLn( "DOF: reset" );
	#/

	player = get_players()[0];
	player maps\_art::setdefaultdepthoffield();
}