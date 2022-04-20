//_createart generated.  modify at your own risk. Changing values should be fine.

////////////////////////////////////////////////// BOOT UP SETTINGS /////////////////////////////////////////////////

main()
{

	level.tweakfile = true;
 
	//* Fog section * 

		VisionSetNaked( "int_frontend_default", 0 );
			
	
	//SetDvar( "r_heroLightScale", "1 1 1" );
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.3 );
	SetSavedDvar( "r_lightGridContrast", 0.2 );
	
	
// Threads for Visionsets		
	
	thread set_default_fog();
	thread set_out_of_chair_vision();
	thread set_numbers_vision();
	thread set_first_junction_vision();
	thread set_brainwash_vision();
	thread set_rocket_hallway_vision();
	thread set_hudson_control_vision();
	thread set_castro_reveal_vision();

// Threads for Fog

	thread set_hallway_fog_trigger();




}


////////////////////////////////////////////////// TRIGGERS /////////////////////////////////////////////////


// Fog Triggers

set_hallway_fog_trigger()
{
	
	self endon("death");

	trig = GetEnt("fog_hallway", "script_noteworthy");
	trig waittill("trigger");

	// update fog settings
	
	fog_hallway_settings();
	
}



////////////////////////////////////////////////// VISIONSET SETTINGS /////////////////////////////////////////////////

set_out_of_chair_vision()
{
	level waittill ("out_of_chair_vision");
	VisionSetNaked( "INT_ESC", 5);
}

set_numbers_vision()
{
	level waittill ("numbers_vision");
	VisionSetNaked("INT_ESC_NUMBERS", 3);
}

		// after First double doors in hallway
		
set_first_junction_vision()
{
	while(1)
	{
		
		level waittill ("first_junction");
		VisionSetNaked( "int_first_junction", 0 );
		fog_hallway_settings();
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.3 );
	SetSavedDvar( "r_lightGridContrast", 0.2 );
	}
}

		// first vorkuta brainwash
		 
set_brainwash_vision()
{
	while(1)
	{
	
		level waittill ("brainwash");
		VisionSetNaked( "int_brainwash", 0 );
		brainwash_room_settings();
		
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.3 );
	SetSavedDvar( "r_lightGridContrast", 0.2 );
	}
}

	// start as turning corner into hallway
	
set_rocket_hallway_vision()
{
	level waittill ("approaching_rocket_hall");
	VisionSetNaked( "int_rocket_hallway", 5 );
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.3 );
	SetSavedDvar( "r_lightGridContrast", 0.2 );
}

	// as we're approaching the com room, as we enter last hallway to comm room
	
set_hudson_control_vision()
{
	while (true)
	{

	   level waittill ("hudson_control_vision", t);
		 VisionSetNaked( "int_hudson_control", t );
		 
	//SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	//SetSavedDvar( "r_lightGridIntensity", 1.3 );
	//SetSavedDvar( "r_lightGridContrast", 0.2 );
	}
}

// after numbers, during castro reveal
	
set_castro_reveal_vision()
{
	while (true)
	{
		level waittill ("castro_reveal");
		VisionSetNaked("int_castro_reveal", 1);
		
	//SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	//SetSavedDvar( "r_lightGridIntensity", 0.0 );
	//SetSavedDvar( "r_lightGridContrast", 0.0 );
	}
}



////////////////////////////////////////////////// FOG SETTINGS /////////////////////////////////////////////////

fog_hallway_settings()
{
	
	start_dist = 139.037;
	half_dist = 779.173;
	half_height = 657.938;
	base_height = 106.647;
	fog_r = 0.0705882;
	fog_g = 0.180392;
	fog_b = 0.258824;
	fog_scale = 10;
	sun_col_r = 1;
	sun_col_g = 1;
	sun_col_b = 1;
	sun_dir_x = 0;
	sun_dir_y = 0;
	sun_dir_z = 1;
	sun_start_ang = 0;
	sun_stop_ang = 76.1805;
	time = 0;
	max_fog_opacity = 0.321875;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		
}

set_default_fog()
{
	fogsettings = getfogsettings();
	while(1)
	{
		level waittill ("set_default_fog");
		start_dist 			= 0;
		half_dist 			= 10000;
		half_height 		= 20000;
		base_height		  = 10000;
		fog_r					  = 0;
		fog_g 					= 0;
		fog_b 					= 0;
		fog_scale 		  = 0;
		sun_col_r		 		= 0;
		sun_col_g		 		= 0;
		sun_col_b		 		= 0;
		sun_dir_x 			= 0;
		sun_dir_y 			= 0;
		sun_dir_z 			= 0;
		sun_start_ang 	= 0;
		sun_stop_ang 		= 0;
		time					  = 0;
		max_fog_opacity = 0;
		
		setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		
			SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 0.5 );
	SetSavedDvar( "r_lightGridContrast", 0.0 );
	}
}

brainwash_room_settings()
{
	start_dist = 329.963;
	half_dist = 477.457;
	half_height = 657.938;
	base_height = 655.347;
	fog_r = 0.643137;
	fog_g = 0.596078;
	fog_b = 0.454902;
	fog_scale = 1.04374;
	sun_col_r = 0;
	sun_col_g = 0;
	sun_col_b = 0;
	sun_dir_x = 0;
	sun_dir_y = 0;
	sun_dir_z = 0;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 0;
	max_fog_opacity = 0.321875;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		
		VisionSetNaked( "int_brainwash", 0 );
		
			SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.3 );
	SetSavedDvar( "r_lightGridContrast", 0.2 );
}