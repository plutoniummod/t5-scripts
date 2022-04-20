//_createart generated.  modify at your own risk. Changing values should be fine.
#include maps\_utility;
#include common_scripts\utility;

main()
{

	level.tweakfile = true;
 
	//* Fog section * 
	VisionSetNaked( "underwaterbase", 0 );
	
	///////////New Hero Lighting///////////////
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.3 );
	SetSavedDvar( "r_lightGridContrast", .2 );
	
	////////Sky setup
	SetSunLight(0.818, 0.71, 0.59);
  SetSavedDvar( "r_lightTweakSunLight", 11 );
  SetSavedDvar( "r_skyColorTemp", (5600)); 


	thread vision_sets_init();
}

set_chopper_fog_and_vision()
{
   start_dist = 536.001;
	half_dist = 3798.38;
	half_height = 1702.91;
	base_height = -600;
	fog_r = 0.109804;
	fog_g = 0.141176;
	fog_b = 0.14902;
	fog_scale = 6.50019;
	sun_col_r = 0.854902;
	sun_col_g = 0.654902;
	sun_col_b = 0.45098;
	sun_dir_x = -0.428335;
	sun_dir_y = -0.796543;
	sun_dir_z = 0.426671;
	sun_start_ang = 0;
	sun_stop_ang = 94.0532;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


	VisionSetNaked("UWB_Chopper", 0);

	SetSavedDvar( "sm_sunSampleSizeNear", 0.0625 );
	SetSunLight(0.818, 0.71, 0.59);
  SetSavedDvar( "r_lightTweakSunLight", 13 );   	
  SetSavedDvar( "r_skyColorTemp", (5600)); 

}

set_rendezvous_fog_and_vision()
{
	start_dist = 536.001;
	half_dist = 3798.38;
	half_height = 1702.91;
	base_height = -600;
	fog_r = 0.109804;
	fog_g = 0.141176;
	fog_b = 0.14902;
	fog_scale = 4.50019;
	sun_col_r = 0.854902;
	sun_col_g = 0.654902;
	sun_col_b = 0.45098;
	sun_dir_x = -0.428335;
	sun_dir_y = -0.796543;
	sun_dir_z = 0.426671;
	sun_start_ang = 0;
	sun_stop_ang = 94.0532;
	time = 20;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


	VisionSetNaked("UWB_ShipDeck", time);
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.5 );
	SetSavedDvar( "r_lightGridContrast", 0.4 );
	
	SetSavedDvar( "sm_sunSampleSizeNear", 0.25 );
	SetSunLight(0.818, 0.71, 0.59);
  SetSavedDvar( "r_lightTweakSunLight", 10 );

}

set_ship_interior_fog_and_vision()
{
start_dist = 88.638;
	half_dist = 1716.87;
	half_height = 1468.18;
	base_height = -602.289;
	fog_r = 0.266667;
	fog_g = 0.356863;
	fog_b = 0.384314;
	fog_scale = 1;
	sun_col_r = 0;
	sun_col_g = 0;
	sun_col_b = 0;
	sun_dir_x = 0;
	sun_dir_y = 0;
	sun_dir_z = 0;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 5;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


  //VisionSetNaked("UWB_ShipInt", time);
	VisionSetNaked("UWB_ShipInt", 3);

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.4 );
	SetSavedDvar( "r_lightGridContrast", 0.35 );
}

set_umbilical_fog_and_vision()
{
	//this is the big igc room
start_dist = 88.638;
	half_dist = 1716.87;
	half_height = 1468.18;
	base_height = -602.289;
	fog_r = 0.266667;
	fog_g = 0.356863;
	fog_b = 0.384314;
	fog_scale = 1;
	sun_col_r = 0;
	sun_col_g = 0;
	sun_col_b = 0;
	sun_dir_x = 0;
	sun_dir_y = 0;
	sun_dir_z = 0;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 5;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	VisionSetNaked("UWB_BigIGC", time);
}

set_dive_fog_and_vision()
{
	////This fog actually isn't called here- its in the client script
	start_dist = 0;
	half_dist = 1382.53;
	half_height = 28501.2;
	base_height = 0;
	fog_r = 0;
	fog_g = 0.0392157;
	fog_b = 0.0588235;
	fog_scale = 1;
	sun_col_r = 0.160784;
	sun_col_g = 0.34902;
	sun_col_b = 0.580392;
	sun_dir_x = 0.0415454;
	sun_dir_y = 0.301728;
	sun_dir_z = -0.952489;
	sun_start_ang = 0;
	sun_stop_ang = 17.4411;
	time = 0;
	max_fog_opacity = 0.875916;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	VisionSetNaked("UWB_End", 0);

	player = get_players()[0];
	player SetClientDvar( "r_lightTweakSunDirection", (-23.9242, 71.0835, 3.98697));  
	SetSunLight(0, 0.644, 0.74);
	
	//reset sky temp
	SetSavedDvar( "r_skyColorTemp", (6500)); 
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.2 );
	SetSavedDvar( "r_lightGridContrast", 0.2 );
}


set_underwater_base_fog()
{	
	start_dist = 266.064;
	half_dist = 697.564;
	half_height = 2632.47;
	base_height = -6491.97;
	fog_r = 0.121569;
	fog_g = 0.172549;
	fog_b = 0.180392;
	fog_scale = 2.55865;
	sun_col_r = 0;
	sun_col_g = 0;
	sun_col_b = 0;
	sun_dir_x = 0;
	sun_dir_y = 0;
	sun_dir_z = 0;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 0;
	max_fog_opacity = 1;


	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.2 );
	SetSavedDvar( "r_lightGridContrast", 0.2 );
	SetSunLight(0, 0.644, 0.74);
}

set_risetosurface_base_fog()
{
	// This is for the ending cinematic
	
 start_dist = 459.814;
	half_dist = 2697.34;
	half_height = 205.078;
	base_height = -3703.35;
	fog_r = 0.223529;
	fog_g = 0.266667;
	fog_b = 0.235294;
	fog_scale = 2.76143;
	sun_col_r = 1;
	sun_col_g = 0.682353;
	sun_col_b = 0.364706;
	sun_dir_x = 0.229004;
	sun_dir_y = 0.967664;
	sun_dir_z = 0.105757;
	sun_start_ang = 0;
	sun_stop_ang = 27.703;
	time = 0;
	max_fog_opacity = 0.875837;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


	
	VisionSetNaked("UWB_End", 0);

	SetSunLight(0.818, 0.71, 0.59);
	player = get_players()[0];
	player SetClientDvar( "r_lightTweakSunDirection", (-23.9242, 71.0835, 3.98697));  
  SetSavedDvar( "r_lightTweakSunLight", 13 );     
}

set_risetosurface_water_fog()
{
	//not sure this is called
	start_dist = 0;
	half_dist = 5465.3;
	half_height = 9422.67;
	base_height = 18859.5;
  fog_r = 0;
  fog_g = 0.0901961;
  fog_b = 0.0745098;
  fog_scale = 3.90903;
  sun_col_r = 0.317647;
  sun_col_g = 0.509804;
  sun_col_b = 0.968628;
	sun_dir_x = -0.0781881;
	sun_dir_y = 0.273071;
	sun_dir_z = -0.958811;
	sun_start_ang = 0;
	sun_stop_ang = 35.1747;
	max_fog_opacity = 0.874845;

	SetVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, 1.0, max_fog_opacity);   
}

//
//	Setup threads for vision set triggers
vision_sets_init()
{
	wait_for_first_player();

	vs_trigs = GetEntArray( "visionset", "targetname" );
	array_thread( vs_trigs, ::vision_set );
}


//
//	Sets the vision set when triggered
vision_set()
{
	AssertEx( IsDefined(self.script_noteworthy), "vision_set:: trigger needs to have a script_noteworthy for the vision set" );
	time = 2.0;
	if ( IsDefined( self.script_float ) )
	{
		time = self.script_float;
	}

	// Now wait for vision_set triggers
	while ( 1 )
	{
		self waittill( "trigger" );

	 	player = get_players()[0];
		vs = player GetVisionSetNaked();
		if ( player GetVisionSetNaked() != ToLower(self.script_noteworthy) )
		{
//iprintlnbold ("old VS = " + vs );
			// Set fog settings if necessary...
			switch ( self.script_noteworthy )
			{
			case "UWB_ShipDeck":
				thread set_rendezvous_fog_and_vision();
				break;
			case "UWB_ShipInt":
				thread set_ship_interior_fog_and_vision();
				break;
			case "UWB_BigIGC":
				thread set_umbilical_fog_and_vision();
				break;
			case "UWB_Dive":
				thread set_dive_fog_and_vision();
				break;
			case "UWB_MoonPool":
				thread set_underwater_base_fog();

				VisionSetNaked( self.script_noteworthy, time );
				break;
// 			case "UWB_Corridor_01":
// 			case "UWB_Corridor_02":
// 			case "UWB_BroadcastCenter":
			default:
				VisionSetNaked( self.script_noteworthy, time );
			}

//iPrintLnBold( "vision set: " + self.script_noteworthy );
		}
	}
}
