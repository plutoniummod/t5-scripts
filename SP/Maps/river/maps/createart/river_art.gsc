//_createart generated.  modify at your own risk. Changing values should be fine.
main()
{
 
	//* Fog section * 

start_dist = 810.487;
	half_dist = 1323.62;
	half_height = 1384.48;
	base_height = -8.29413;
	fog_r = 0.0588235;
	fog_g = 0.121569;
	fog_b = 0.14902;
	fog_scale = 3.39626;
	sun_col_r = 0.243137;
	sun_col_g = 0.392157;
	sun_col_b = 0.411765;
	sun_dir_x = -0.760298;
	sun_dir_y = -0.339782;
	sun_dir_z = 0.55362;
	sun_start_ang = 0;
	sun_stop_ang = 118.659;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);



	VisionSetNaked( "river", 0 );
		SetSunLight(0.445, 0.577, 0.660);

	
	///////////New Hero Lighting///////////////
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.5 );
	SetSavedDvar( "r_lightGridContrast", .3 );
	
}


// VILLAGE LIGHTING
village_section( trans_time )
{
start_dist = 810.487;
	half_dist = 1323.62;
	half_height = 1384.48;
	base_height = -8.29413;
	fog_r = 0.0588235;
	fog_g = 0.121569;
	fog_b = 0.14902;
	fog_scale = 3.39626;
	sun_col_r = 0.243137;
	sun_col_g = 0.392157;
	sun_col_b = 0.411765;
	sun_dir_x = -0.760298;
	sun_dir_y = -0.339782;
	sun_dir_z = 0.55362;
	sun_start_ang = 0;
	sun_stop_ang = 118.659;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.5 );
	SetSavedDvar( "r_lightGridContrast", .3 );


	VisionSetNaked( "river_village", trans_time );
}


// BOAT SECTION LIGHTING
boat_section( trans_time )
{
start_dist = 810.487;
	half_dist = 1323.62;
	half_height = 1384.48;
	base_height = -8.29413;
	fog_r = 0.0588235;
	fog_g = 0.121569;
	fog_b = 0.14902;
	fog_scale = 3.39626;
	sun_col_r = 0.243137;
	sun_col_g = 0.392157;
	sun_col_b = 0.411765;
	sun_dir_x = -0.760298;
	sun_dir_y = -0.339782;
	sun_dir_z = 0.55362;
	sun_start_ang = 0;
	sun_stop_ang = 118.659;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	VisionSetNaked( "river_boat", trans_time );
	
		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.5 );
	SetSavedDvar( "r_lightGridContrast", .3 );
}


// LAND SECTION LIGHTING
land_section( trans_time )
{
start_dist = 618.921;
	half_dist = 1327.01;
	half_height = 600.331;
	base_height = -8.29413;
	fog_r = 0.0588235;
	fog_g = 0.121569;
	fog_b = 0.14902;
	fog_scale = 3.41725;
	sun_col_r = 0.243137;
	sun_col_g = 0.392157;
	sun_col_b = 0.411765;
	sun_dir_x = -0.760298;
	sun_dir_y = -0.339782;
	sun_dir_z = 0.55362;
	sun_start_ang = 20.0277;
	sun_stop_ang = 114.88;
	time = 5;
	max_fog_opacity = 0.734995;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	VisionSetNaked( "river_land", trans_time );
	
		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.5 );
	SetSavedDvar( "r_lightGridContrast", .3 );
}


// BURNING SECTION LIGHTING
burning_section( trans_time )
{
	start_dist = 363.305;
	half_dist = 354.056;
	half_height = 978.479;
	base_height = -8.29413;
	fog_r = 0.0588235;
	fog_g = 0.121569;
	fog_b = 0.14902;
	fog_scale = 3.41725;
	sun_col_r = 0.243137;
	sun_col_g = 0.392157;
	sun_col_b = 0.411765;
	sun_dir_x = -0.760298;
	sun_dir_y = -0.339782;
	sun_dir_z = 0.55362;
	sun_start_ang = 19.4171;
	sun_stop_ang = 51.0759;
	time = 5;
	max_fog_opacity = 0.685994;



	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


	VisionSetNaked( "river_burn", trans_time );
	
		SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.5 );
	SetSavedDvar( "r_lightGridContrast", .3 );
	
}


// PLANE SECTION LIGHTING
plane_section( trans_time )
{
start_dist = 377.104;
	half_dist = 1701.62;
	half_height = 1348.91;
	base_height = -8.29413;
	fog_r = 0.0588235;
	fog_g = 0.121569;
	fog_b = 0.14902;
	fog_scale = 3.41725;
	sun_col_r = 0.243137;
	sun_col_g = 0.392157;
	sun_col_b = 0.411765;
	sun_dir_x = -0.760298;
	sun_dir_y = -0.339782;
	sun_dir_z = 0.55362;
	sun_start_ang = 19.4171;
	sun_stop_ang = 79.2287;
	time = 5;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


	VisionSetNaked( "river_plane", trans_time );
	
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.5 );
	SetSavedDvar( "r_lightGridContrast", .3 );
}


