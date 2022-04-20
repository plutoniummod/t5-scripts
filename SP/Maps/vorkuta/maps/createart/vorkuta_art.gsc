//_createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 
	///////////New Hero Lighting///////////////
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.25 );
	SetSavedDvar( "r_lightGridContrast", .45 );
	
	SetSavedDvar( "sm_sunSampleSizeNear", "0.25" );
	
	level thread vision_mines();
	level thread vision_inclinator();
	level thread vision_exterior();
	level thread vision_interior();
	level thread vision_slingshot();
	level thread vision_warehouse();
	level thread vision_bike();

	level thread fog_stairs();
	level thread fog_slingshot();
	level thread fog_courtyard();
	level thread fog_armory();
	level thread fog_minigun();
	level thread fog_bike_downhill();
	level thread fog_bike_train();
}

//called at the start of the level once
vision_mines()
{
	VisionSetNaked( "vorkuta_mines", 0 );
	
		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.3 );
	SetSavedDvar( "r_lightGridContrast", 0.0 );
	
	fog_mines();
}

//called once as player boards the inclinator
vision_inclinator()
{
	level waittill("mine_clean_up_2");

	VisionSetNaked( "vorkuta_inclinator", 5 );
	
			SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.6 );
	SetSavedDvar( "r_lightGridContrast", 0.0 );
	
	fog_inclinator();
}

//triggers placed through map
vision_exterior()
{
	trigger = GetEnt("vision_exterior","targetname");

	while(1)
	{
		trigger waittill("trigger");

		current_vision = GetPlayers()[0] GetVisionSetNaked();
		if(current_vision != "vorkuta_exterior")
		{
			VisionSetNaked( "vorkuta_exterior", 5 );
			
			SetSavedDvar( "r_lightGridEnableTweaks", 1 );
			SetSavedDvar( "r_lightGridIntensity", 1.65 );
			SetSavedDvar( "r_lightGridContrast", .2 );
		}	
		wait(0.05);
	}	
}

//triggers placed through map
vision_interior()
{
	trigger = GetEnt("vision_interior","targetname");
	
	while(1)
	{
		trigger waittill("trigger");

		current_vision = GetPlayers()[0] GetVisionSetNaked();
		if(current_vision != "vorkuta_interior")
		{
			VisionSetNaked( "vorkuta_interior", 3 );
			
		   SetSavedDvar( "r_skyColorTemp", 6500.0 );

			
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.45 );
	SetSavedDvar( "r_lightGridContrast", -0.45 );
		}		
		wait(0.05);
	}	
}

//triggers placed through map
vision_slingshot()
{
	trigger = GetEnt("vision_slingshot","targetname");
	
	while(1)
	{
		trigger waittill("trigger");

		current_vision = GetPlayers()[0] GetVisionSetNaked();
		if(current_vision != "vorkuta_slingshot")
		{
			VisionSetNaked( "vorkuta_slingshot", 3 );
			
		 SetSavedDvar( "r_skyColorTemp", 4500.0 );

			
		  SetSavedDvar( "r_lightGridEnableTweaks", 1 );
			SetSavedDvar( "r_lightGridIntensity", 1.3 );
	    SetSavedDvar( "r_lightGridContrast", 0.0 );
		}		
		wait(0.05);
	}	
}

//called once during transition to warehouse
vision_warehouse()
{
	level waittill("player_in_warehouse");

	VisionSetNaked( "vorkuta_warehouse", 0 );
	
				SetSavedDvar( "r_lightGridEnableTweaks", 1 );
			SetSavedDvar( "r_lightGridIntensity", 1.5 );
			SetSavedDvar( "r_lightGridContrast", 0.37 );
			
	level thread fog_warehouse();
}

//called once as player exits the warehouse
vision_bike()
{
	level waittill("Player_out_window");

	VisionSetNaked( "vorkuta_bike", 3 );
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.3 );
	SetSavedDvar( "r_lightGridContrast", .25 );
}

//called when vision is changed
fog_mines()
{
	start_dist = 308;
	half_dist = 787.097;
	half_height = 4517.71;
	base_height = -287.284;
	fog_r = 0.435294;
	fog_g = 0.490196;
	fog_b = 0.501961;
	fog_scale = 1.54045;
	sun_col_r = 0.501961;
	sun_col_g = 0.501961;
	sun_col_b = 0.501961;
	sun_dir_x = 1;
	sun_dir_y = 0;
	sun_dir_z = 0;
	sun_start_ang = 0;
	sun_stop_ang = 0;
	time = 0;
	max_fog_opacity = 1;



	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

}

//called when vision is changed
fog_inclinator()
{
	start_dist = 459.668;
	half_dist = 760.616;
	half_height = 498.519;
	base_height = 1011.22;
	fog_r = 0.207843;
	fog_g = 0.25098;
	fog_b = 0.215686;
	fog_scale = 6.42926;
	sun_col_r = 1;
	sun_col_g = 1;
	sun_col_b = 0.866667;
	sun_dir_x = 1;
	sun_dir_y = 0;
	sun_dir_z = 0;
	sun_start_ang = 0;
	sun_stop_ang = 41.6463;
	time = 20;
	max_fog_opacity = 1;



	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		

	
}

//trigger located at base of stairs before slingshot building
fog_stairs()
{
	trigger = GetEnt("fog_stairs","targetname");
	trigger waittill("trigger");

	start_dist = 96.9132;
	half_dist = 747.894;
	half_height = 180.824;
	base_height = 1123.11;
	fog_r = 0.207843;
	fog_g = 0.25098;
	fog_b = 0.219608;
	fog_scale = 6.50297;
	sun_col_r = 1;
	sun_col_g = 1;
	sun_col_b = 0.858824;
	sun_dir_x = -0.313523;
	sun_dir_y = 0.700154;
	sun_dir_z = 0.641473;
	sun_start_ang = 0;
	sun_stop_ang = 41.3838;
	time = 5;
	max_fog_opacity = 1;


	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		
}

//trigger placed on the door to the roof
fog_slingshot()
{
	trigger = GetEnt("vision_slingshot","targetname");
	trigger waittill("trigger");

	start_dist = 1743.4;
	half_dist = 771.007;
	half_height = 699.024;
	base_height = 1143.61;
	fog_r = 0.0941177;
	fog_g = 0.12549;
	fog_b = 0.12549;
	fog_scale = 10;
	sun_col_r = 1;
	sun_col_g = 0.85098;
	sun_col_b = 0.568627;
	sun_dir_x = -0.343552;
	sun_dir_y = 0.678895;
	sun_dir_z = 0.648903;
	sun_start_ang = 42.2251;
	sun_stop_ang = 89.8043;
	time = 5;
	max_fog_opacity = 1;


	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		


}

//trigger is the same as the one used to spawn initial friendlies for courtyard
fog_courtyard()
{
	trigger = GetEnt("tower_shotgun","targetname");
	trigger waittill("trigger");

	start_dist = 155.353;
	half_dist = 1274.95;
	half_height = 299.978;
	base_height = 1082.11;
	fog_r = 0.160784;
	fog_g = 0.180392;
	fog_b = 0.156863;
	fog_scale = 10;
	sun_col_r = 1;
	sun_col_g = 0.666667;
	sun_col_b = 0.439216;
	sun_dir_x = -0.313523;
	sun_dir_y = 0.700154;
	sun_dir_z = 0.641473;
	sun_start_ang = 0;
	sun_stop_ang = 72.0989;
	time = 5;
	max_fog_opacity = 1;


	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		
}

//trigger in script to notify the player is in the armory
fog_armory()
{
	trigger = GetEnt("trigger_armory_proximity","targetname");
	trigger waittill("trigger");
	
	start_dist = 174.933;
	half_dist = 4492.95;
	half_height = 567.778;
	base_height = 1211.26;
	fog_r = 0.329412;
	fog_g = 0.415686;
	fog_b = 0.431373;
	fog_scale = 3.05663;
	sun_col_r = 0.996078;
	sun_col_g = 0.811765;
	sun_col_b = 0.47451;
	sun_dir_x = -0.395724;
	sun_dir_y = 0.704049;
	sun_dir_z = 0.589676;
	sun_start_ang = 0;
	sun_stop_ang = 88.3684;
	time = 5;
	max_fog_opacity = 0.803343;



	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		
}

//after the player drops down from armory
fog_minigun()
{
	trigger = GetEnt("manager_rpg_bridge","targetname");
	trigger waittill("trigger");

	start_dist = 454.44;
	half_dist = 1585.11;
	half_height = 435.685;
	base_height = 1400.8;
	fog_r = 0.329412;
	fog_g = 0.415686;
	fog_b = 0.431373;
	fog_scale = 6.93566;
	sun_col_r = 0.996078;
	sun_col_g = 0.811765;
	sun_col_b = 0.47451;
	sun_dir_x = -0.395724;
	sun_dir_y = 0.704049;
	sun_dir_z = 0.589676;
	sun_start_ang = 0;
	sun_stop_ang = 88.3684;
	time = 5;
	max_fog_opacity = 0.803343;



	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		
}

//called when vision is changed
fog_warehouse()
{
start_dist = 223.319;
	half_dist = 502.993;
	half_height = 1022.46;
	base_height = -1300.89;
	fog_r = 0.329412;
	fog_g = 0.415686;
	fog_b = 0.431373;
	fog_scale = 6.93566;
	sun_col_r = 0.996078;
	sun_col_g = 0.811765;
	sun_col_b = 0.47451;
	sun_dir_x = -0.395724;
	sun_dir_y = 0.704049;
	sun_dir_z = 0.589676;
	sun_start_ang = 0;
	sun_stop_ang = 90.4145;
	time = 0;
	max_fog_opacity = 0.803343;




	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
		
		SetSavedDvar( "r_skyColorTemp", 10000.0 );

}

fog_bike_downhill()
{
	trigger = GetEnt("chopper1_spawn","targetname");
	trigger waittill("trigger");
	
start_dist = 450.319;
	half_dist = 4600.993;
	half_height = 1022.46;
	base_height = 1.89;
	fog_r = 0.329412;
	fog_g = 0.415686;
	fog_b = 0.431373;
	fog_scale = 6.93566;
	sun_col_r = 0.996078;
	sun_col_g = 0.811765;
	sun_col_b = 0.47451;
	sun_dir_x = -0.395724;
	sun_dir_y = 0.704049;
	sun_dir_z = 0.589676;
	sun_start_ang = 0;
	sun_stop_ang = 90.4145;
	time = 5;
	max_fog_opacity = 0.803343;



	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
}

//trigger right before train jump
fog_bike_train()
{
	trigger = GetEnt("delete_bridge_guys","targetname");
	trigger waittill("trigger");
	
start_dist = 500.319;
	half_dist = 5600.993;
	half_height = 1022.46;
	base_height = -100;
	fog_r = 0.329412;
	fog_g = 0.415686;
	fog_b = 0.431373;
	fog_scale = 6.93566;
	sun_col_r = 0.996078;
	sun_col_g = 0.811765;
	sun_col_b = 0.47451;
	sun_dir_x = -0.395724;
	sun_dir_y = 0.704049;
	sun_dir_z = 0.589676;
	sun_start_ang = 0;
	sun_stop_ang = 90.4145;
	time = 5;
	max_fog_opacity = 0.803343;


	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
}