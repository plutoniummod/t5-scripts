#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#using_animtree("fxanim_props"); 

// fx used by util scripts
precache_util_fx()
{
}

// Scripted effects
precache_scripted_fx()
{
	level._effect["bloody_death"][0]			= LoadFX("impacts/flesh_hit_head_fatal_exit");
	level._effect["bloody_death"][1]			= LoadFX("impacts/flesh_hit_head_fatal_exit");
	level._effect["bloody_death"][2]			= LoadFX("impacts/flesh_hit_head_fatal_exit");
	
	level._effect["camera_flash"] = loadfx("maps/wmd/fx_wmd_camera_flash");
	
	level._effect["truck_fire"] = loadfx("vehicle/vfire/fx_vfire_truck_standard");
	
	level._effect["player_cloud"] = loadfx("env/weather/fx_basejump_freefall_speedvisual");
	level._effect["cloud_layers"] = loadfx("env/weather/fx_clouds_basejump_cl_layer");
	level._effect["landing_fx"] = loadfx("env/dirt/fx_dirt_basejump_land");
	level._effect["ledge_rocks"] = loadfx("env/dirt/fx_rock_ledge_basejump");
	
	level._effect["spotlight_fx"] = loadfx("env/light/fx_search_light_tower");
	level._effect["barrel_fire"] = loadfx("env/fire/fx_fire_barrel_small");
	level._effect["garage_sparks"]= loadfx("env/electrical/fx_elec_burst_oneshot_distant");
	level._effect["wire_sparks"] = loadfx("env/electrical/fx_elec_panel_spark_md");
	
	//window breach
	level._effect["breach_water"] = loadfx("maps/wmd/fx_wmd_water_impact_burst");
	level._effect["breach_cotton"] = loadfx("maps/wmd/fx_wmd_cottonpuff_impact_burst");
	level._effect["breach_sparks"] = loadfx("maps/wmd/fx_wmd_sparks_impact_burst");
	level._effect["swirling_amb"] = loadfx("maps/wmd/fx_wmd_room_swirling_ambience");
	level._effect["dyn_light_glow"] = loadfx("maps/wmd/fx_wmd_lamp_breech_light_glow");
	
	//barrel in shed
	level._effect["barrel_exp"] = loadfx("destructibles/fx_barrelExp");
	
	//gaz truck explosion
	level._effect["gaz_exp"] = loadfx("maps/wmd/fx_vehicle_fuel_tank_explosion");
	level._effect["gaz_firebig"] = loadfx("maps/wmd/fx_vehicle_fuel_tank_fire1");
	level._effect["gaz_firesml"] = loadfx("maps/wmd/fx_vehicle_fuel_tank_fire2");
	level._effect["tanker_fuel"] = loadfx("maps/wmd/fx_wmd_gasoline_gush");
	
	//character snow fx
	level._effect["snow_falloff"] = loadfx("maps/wmd/fx_snow_player_falloff");
	level._effect["snow_puff"] = loadfx("maps/wmd/fx_snow_player_prone_puff");
	level._effect["snow_puff_land"] = loadfx("maps/wmd/fx_snow_player_land_puff");
	

	//uaz
	level._effect[ "uaz_exhaust" ]	= LoadFX( "vehicle/exhaust/fx_exhaust_jeep_uaz" );
	level._effect[ "uaz_headlight" ]	= LoadFX( "vehicle/light/fx_jeep_uaz_headlight" );
	level._effect[ "uaz_taillight" ]	= LoadFX( "vehicle/light/fx_jeep_uaz_taillight" );
	
	
	level._effect["avalanche"] = loadfx("maps/wmd/fx_avalanche_base");
	//level._effect["sa2_trail"] = loadfx("smoke/smoke_geotrail_sa_2");
	//level._effect["snow_burst"] = loadfx("maps/wmd/fx_snow_ai_burst");
	
	level._effect["blackbird_exhaust"] = LoadFX("vehicle/exhaust/fx_exhaust_blackbird");
	level._effect["blackbird_exhaust_smoke"] = LoadFX("smoke/smoke_sr71_turbine_ignite_burst");
	level._effect["blackbird_takeoff_wind"] = LoadFX("env/weather/fx_wind_layer_speedvisual_sr71");
	level._effect["blackbird_wheel_light"] = LoadFX("maps/wmd/fx_wmd_sr71_headlight" );
 	level._effect["flesh_hit"]							= LoadFX("impacts/fx_flesh_hit");
 	level._effect["rts_guy_trail"] = loadfx("maps/wmd/fx_wmd_rts_ghosting");
 	level._effect["flashlight"] = loadfx("env/light/fx_flashlight_nolight");
	
	//level._effect["custom_tracer"] = loadfx("maps/wmd/fx_wmd_rts_muzzleflash_tracer");
	//level._effect["rts_uaz_headlight"] = loadfx("maps/wmd/fx_wmd_rts_vehicle_headlight");
	//level._effect["rts_flare"] = loadfx("weapon/napalm/fx_napalm_marker_trail");
	//level._effect["rts_bloodsplatter"] = loadfx("maps/wmd/fx_wmd_rts_impact_fatal_hit");
	//level._effect["bang"] = loadfx("explosions/fx_flashbang");

	//spetznaz door breach
	level._effect["breach_door_smoke"] 		= loadfx("maps/wmd/fx_smoke_door_breech");
	
	level._effect["hinge_shot"] 		= loadfx("maps/wmd/fx_wmd_door_hinge_sparks");
	
	//cold breath
	level._effect["cold_breath"] = loadfx("bio/player/fx_cold_breath2");
	level._effect["cold_breath_elem"] = loadfx("bio/player/fx_cold_breath2_elem");
	level._effect["cold_breath_player"] = loadfx("bio/player/fx_cold_breath2_player");
	
	// --  WWILLIAMS: FX FOR THE AVALANCHE AT THE END
	level._effect[ "avalanche_wave" ] = LoadFX( "maps/wmd/fx_avalanche_base" );
	
	// -- WWILLIAMS: FX FOR STREET TRUCK EXPLOSION AND IF THE PLAYER FAILS TO ESCAPE IN TIME
	level._effect[ "temp_explosion" ] = LoadFX( "vehicle/vexplosion/fx_vexp_truck_gaz66" );
	level._effect["street_truck_explosion"] = LoadFX("maps/vorkuta/fx_explosion_truck_linked");
}


// Ambient effects
precache_createfx_fx()
{
  
	level._effect["rocks_falling"]					        = loadfx("env/dirt/fx_rock_debris_ropebridge");
	level._effect["wind_gusts"]					            = loadfx("env/weather/fx_clouds_mountaintop_blowing");
	level._effect["clouds_os"]					            = loadfx("env/weather/fx_clouds_basejump_cl_layer");
	level._effect["clouds_cl"]					            = loadfx("env/weather/fx_clouds_basejump_cl_layer");
	level._effect["clouds_os2_only"]				      	= loadfx("env/weather/fx_clouds_basejump_cl_layer");
	level._effect["cloud_layers"] 						      = loadfx("env/weather/fx_clouds_basejump_cl_layer");
  level._effect["vis_blocker"] 					        	= loadfx("env/weather/fx_clouds_basejump_cl_layer");
  level._effect["freefall_cloud_layer1"] 					= loadfx("maps/wmd/fx_basejump_cloud_layer"); 
  level._effect["freefall_cloud_layer2"] 					= loadfx("maps/wmd/fx_basejump_cloud_layer2");  
       
  
  level._effect["snow_tree_fall_big"] 						= loadfx("env/foliage/fx_snow_falling_tree_big");
  level._effect["snow_tree_fall_big_spawner"] 		= loadfx("env/foliage/fx_snow_falling_tree_big_spawner");  
  level._effect["snow_tree_fall_light"] 					= loadfx("env/foliage/fx_snow_falling_tree_light");
  level._effect["snow_tree_fall_small"] 					= loadfx("env/foliage/fx_snow_falling_tree_small");
  level._effect["snow_flakes_windy_blizzard"] 		= loadfx("env/weather/fx_snow_blizzard_intense");
  level._effect["snow_flakes_windy_mild"] 		    = loadfx("env/weather/fx_snow_blizzard_mild");  
  level._effect["snow_flakes_windy_blizzard2"] 		= loadfx("env/weather/fx_snow_blizzard_intense2");  
  level._effect["snow_flakes_windy_sm"] 					= loadfx("env/weather/fx_snow_flakes_windy_small");
  level._effect["snow_ground_rolling_dist"] 			= loadfx("env/weather/fx_snow_ground_rolling_dist");
  level._effect["snow_gust_wind_burst"] 					= loadfx("env/weather/fx_snow_gust_wind_burst");
  level._effect["snow_windy_fast_door_os"] 				= loadfx("env/weather/fx_snow_windy_fast_door_os");
  level._effect["snow_windy_fast_sm_os"] 					= loadfx("env/weather/fx_snow_windy_fast_sm_os");
  level._effect["snow_windy_fast_lg_os"] 					= loadfx("env/weather/fx_snow_windy_fast_lg_os"); 
  level._effect["snow_windy_fast_xlg_os"] 				= loadfx("env/weather/fx_snow_windy_fast_xlg_os");    
  level._effect["snow_windy_heavy_md"] 						= loadfx("env/weather/fx_snow_windy_heavy_md");
  level._effect["snow_windy_heavy_md_rts"] 		   	= loadfx("env/weather/fx_snow_windy_heavy_md_rts");    
  level._effect["snow_windy_heavy_sm"] 						= loadfx("env/weather/fx_snow_windy_heavy_sm");
  level._effect["snow_windy_heavy_md"] 						= loadfx("env/weather/fx_snow_windy_heavy_md");
  level._effect["snow_windy_heavy_xsm"] 					= loadfx("env/weather/fx_snow_windy_heavy_xsm");  
	level._effect["snow_fog_field_lg"] 						  = loadfx("env/weather/fx_snow_fog_field_lg");
	level._effect["snow_gust_ground_lg"] 					  = loadfx("env/weather/fx_snow_gust_ground_lg");
  level._effect["snow_gust_wind_dense"] 				  = loadfx("env/weather/fx_snow_gust_wind_dense");
	level._effect["snow_fall_off_rock_hvy"] 				= loadfx("env/weather/fx_snow_wall_hvy");
	level._effect["snow_fall_off_rock_hvy_loop"] 	  = loadfx("env/weather/fx_snow_wall_hvy_loop");	
	level._effect["snow_fall_off_rock_hvy_loop_direct"] 	  = loadfx("env/weather/fx_snow_wall_hvy_loop_direct");	
	level._effect["snow_fall_off_rock_hvy_loop_sm"] = loadfx("env/weather/fx_snow_wall_hvy_loop_sm");	
	level._effect["snow_fall_avalanche_base"]     	= loadfx("maps/wmd/fx_avalanche_base_sm");	
	level._effect["snow_fall_avalanche_base_move"]	= loadfx("maps/wmd/fx_avalanche_base");	
	level._effect["snow_fall_avalanche_base_start"] = loadfx("maps/wmd/fx_avalanche_base_slide");	
	level._effect["snow_fall_avalanche_base_start2"] = loadfx("maps/wmd/fx_avalanche_base_slide2");							
	level._effect["snow_fall_avalanche"] 			    	= loadfx("env/weather/fx_snow_wall_avalanche");	
	level._effect["snow_fall_avalanche2"] 			   	= loadfx("env/weather/fx_snow_wall_avalanche2");	
	level._effect["snow_fall_avalanche3"] 			   	= loadfx("env/weather/fx_snow_wall_avalanche3");	
	level._effect["snow_fall_avalanche4"] 			   	= loadfx("env/weather/fx_snow_wall_avalanche4");	
	level._effect["snow_fall_avalanche5"] 			   	= loadfx("env/weather/fx_snow_wall_avalanche5");
	level._effect["snow_fall_avalanche6"] 			   	= loadfx("env/weather/fx_snow_wall_avalanche6");						
	level._effect["snow_fall_avalanche_elem1"] 			= loadfx("env/weather/fx_snow_wall_avalanche_elem");	
	level._effect["snow_fall_avalanche_elem2"] 			= loadfx("env/weather/fx_snow_wall_avalanche_elem2");		
	level._effect["snow_fall_avalanche_elem3"] 			= loadfx("env/weather/fx_snow_wall_avalanche_elem3");			
  level._effect["snow_debris_plume_sm"] 			    = loadfx("env/weather/fx_snow_debris_plume_sm"); 
  level._effect["snow_debris_plume_md"] 			    = loadfx("env/weather/fx_snow_debris_plume_md");    	
	level._effect["snow_gust_kickup1"] 				  	  = loadfx("env/weather/fx_snow_gust_kickup1");
	level._effect["snow_gust_kickup2"] 				  	  = loadfx("env/weather/fx_snow_gust_kickup2");	
  level._effect["cloud_layer_rolling3_lg"] 			  = loadfx("maps/wmd/fx_cloud_layer_rolling_3_lg");	
  level._effect["cloud_layer_rolling3_md"] 			  = loadfx("maps/wmd/fx_cloud_layer_rolling_3_md");	  
  level._effect["cloud_layer_rolling2"] 				  = loadfx("maps/wmd/fx_cloud_layer_rolling_2");
  level._effect["cloud_layer_rolling2_sm"] 			  = loadfx("maps/wmd/fx_cloud_layer_rolling_2_sm");  
  level._effect["cloud_layer_rolling2_xsm"] 			= loadfx("maps/wmd/fx_cloud_layer_rolling_2_xsm"); 
  level._effect["cloud_layer_rolling2_xsm_det_left"]	  = loadfx("maps/wmd/fx_cloud_layer_rolling_2_xsm_detail_l");  
  level._effect["cloud_layer_rolling2_xsm_det_right"] 	= loadfx("maps/wmd/fx_cloud_layer_rolling_2_xsm_detail_r");     
  level._effect["cloud_layer_rolling2_lg"] 			  = loadfx("maps/wmd/fx_cloud_layer_rolling_2_lg");    
  level._effect["debris_papers_windy"]            = loadfx("env/debris/fx_debris_papers_windy");
  level._effect["glass_break"]                    = loadfx("maps/wmd/fx_break_glass_window_large" );
  level._effect["ambience_swirling1"]             = loadfx("maps/wmd/fx_wmd_room_swirling_ambience" );  
  level._effect["godray_md"]                      = loadfx("maps/wmd/fx_light_godray_wmd_md"); 
  level._effect["godray_md_long"]                 = loadfx("maps/wmd/fx_light_godray_wmd_md2");  
  level._effect["godray_sm"]                      = loadfx("maps/wmd/fx_light_godray_wmd_sm");          
  level._effect["light_lamp_glow_white"]          = loadfx("maps/wmd/fx_wmd_lamp_white_light_glow"); 
  level._effect["light_lamp_glow_red"]            = loadfx("maps/wmd/fx_wmd_lamp_red_light_glow");   
  level._effect["light_glow_red"]                 = loadfx("maps/wmd/fx_wmd_tower_red_light_glow");  
  level._effect["light_glow_green"]               = loadfx("maps/wmd/fx_wmd_tower_green_light_glow");  
  level._effect["light_glow_amber"]               = loadfx("maps/wmd/fx_wmd_tower_amber_light_glow"); 
  level._effect["base_explosion_stage_4"]         = loadfx("maps/wmd/fx_explosion_fuel_tank_stage4"); 
  level._effect["base_explosion_stage_5"]         = loadfx("maps/wmd/fx_explosion_fuel_tank_stage5"); 
  level._effect["base_explosion_stage_6"]         = loadfx("maps/wmd/fx_explosion_fuel_tank_stage6");        
  level._effect["fuel_tank_fire_lg"]              = loadfx("maps/wmd/fx_vehicle_fuel_tank_fire1");
  level._effect["fuel_tank_fire_sm"]              = loadfx("maps/wmd/fx_vehicle_fuel_tank_fire2"); 
  level._effect["fuel_tank_fire_xsm"]             = loadfx("maps/wmd/fx_vehicle_fuel_tank_fire3"); 
  level._effect["snow_door_fallen_puff"]          = loadfx("maps/wmd/fx_snow_door_fallen_puff");  
  level._effect["breech_wind_gust_loop"]          = loadfx("maps/wmd/fx_wmd_breech_wind_gust");   
  level._effect["snow_falling_drift_small"]       = loadfx("maps/wmd/fx_snow_falling_drift"); 
  level._effect["snow_building_impact"]           = loadfx("maps/wmd/fx_snow_building_impact"); 
  level._effect["snow_building_impact_sm"]        = loadfx("maps/wmd/fx_snow_building_impact_sm");       
  level._effect["snow_falling_curtain"]           = loadfx("maps/wmd/fx_snow_falling_curtain"); 
  level._effect["light_flare_player"]             = loadfx("maps/wmd/fx_wmd_light_flare_player"); 
  level._effect["radar_wire_sparks"]              = loadfx("maps/wmd/fx_wmd_sparks_impact_burst2"); 
  level._effect["fire_indoor_sm"]                 = loadfx("maps/wmd/fx_fire_indoor_sm");   
  level._effect["embers_indoor_sm"]               = loadfx("maps/wmd/fx_embers_indoor_sm");  
  level._effect["embers_indoor_lg"]               = loadfx("maps/wmd/fx_embers_indoor_lg");                                                       
  level._effect["sparks_element1"]                = loadfx("env/electrical/fx_elec_burst_shower_sm_os");  
  level._effect["light_glow_spot_3"]              = LoadFX("maps/vorkuta/fx_light_glow_spot_3" );                        
}


// FXanim Props
initModelAnims()
{

	level.scr_anim["fxanim_props"]["a_tarp_woodstack"] = %fxanim_gp_tarp_wood_stack_anim;
	level.scr_anim["fxanim_props"]["a_fuel_hose"] = %fxanim_wmd_fuel_hose_anim;
	level.scr_anim["fxanim_props"]["a_windsock"] = %fxanim_gp_windsock_anim;
	level.scr_anim["fxanim_props"]["a_tanker_tree"] = %fxanim_wmd_aspin_tanker_anim;
	level.scr_anim["fxanim_props"]["a_streamer_01"] = %fxanim_gp_streamer01_anim;
	level.scr_anim["fxanim_props"]["a_streamer_02"] = %fxanim_gp_streamer02_anim;
	level.scr_anim["fxanim_props"]["a_radar01"] = %fxanim_wmd_radar01_anim;
	level.scr_anim["fxanim_props"]["a_radar02"] = %fxanim_wmd_radar02_anim;
	level.scr_anim["fxanim_props"]["a_radar03"] = %fxanim_wmd_radar03_anim;
	level.scr_anim["fxanim_props"]["a_radar04"] = %fxanim_wmd_radar04_anim;
	level.scr_anim["fxanim_props"]["a_radar05"] = %fxanim_wmd_radar05_anim;
	level.scr_anim["fxanim_props"]["a_square_anetta"] = %fxanim_wmd_square_anetta_shake_anim;
	level.scr_anim["fxanim_props"]["a_catwalk"] = %fxanim_wmd_catwalk_anim;
	level.scr_anim["fxanim_props"]["a_catwalk_fall"] = %fxanim_wmd_catwalk_fall_anim;
	level.scr_anim["fxanim_props"]["a_hangar_doors"] = %fxanim_wmd_hangar_doors_anim;
	level.scr_anim["fxanim_props"]["a_heat_pipe01"] = %fxanim_wmd_heat_pipe01_anim;
	level.scr_anim["fxanim_props"]["a_heat_pipe02"] = %fxanim_wmd_heat_pipe02_anim;
	level.scr_anim["fxanim_props"]["a_electric_tower01"] = %fxanim_wmd_electric_tower01_anim;
	level.scr_anim["fxanim_props"]["a_electric_tower02"] = %fxanim_wmd_electric_tower02_anim;
	level.scr_anim["fxanim_props"]["a_electric_tower_top"] = %fxanim_wmd_electric_tower_top_anim;
	level.scr_anim["fxanim_props"]["a_ava_wall"] = %fxanim_wmd_ava_wall_anim;
	level.scr_anim["fxanim_props"]["a_parachute"] = %fxanim_wmd_parachute_anim;

	level thread addNotetrack_customFunction( "fxanim_props", "RADAR_START_SOUND", maps\wmd_amb::radar_dish_sounds_start, "a_radar01" );
	level thread addNotetrack_customFunction( "fxanim_props", "RADAR_STOP_SOUND", maps\wmd_amb::radar_dish_sounds_stop, "a_radar01" ); 		
	level thread addNotetrack_customFunction( "fxanim_props", "RADAR_START_SOUND", maps\wmd_amb::radar_dish_sounds_start, "a_radar02" );
	level thread addNotetrack_customFunction( "fxanim_props", "RADAR_STOP_SOUND", maps\wmd_amb::radar_dish_sounds_stop, "a_radar02" ); 
	level thread addNotetrack_customFunction( "fxanim_props", "RADAR_START_SOUND", maps\wmd_amb::radar_dish_sounds_start, "a_radar03" );
	level thread addNotetrack_customFunction( "fxanim_props", "RADAR_STOP_SOUND", maps\wmd_amb::radar_dish_sounds_stop, "a_radar03" ); 
	level thread addNotetrack_customFunction( "fxanim_props", "RADAR_START_SOUND", maps\wmd_amb::radar_dish_sounds_start, "a_radar04" );
	level thread addNotetrack_customFunction( "fxanim_props", "RADAR_STOP_SOUND", maps\wmd_amb::radar_dish_sounds_stop, "a_radar04" ); 
	level thread addNotetrack_customFunction( "fxanim_props", "RADAR_START_SOUND", maps\wmd_amb::radar_dish_sounds_start, "a_radar05" );
	level thread addNotetrack_customFunction( "fxanim_props", "RADAR_STOP_SOUND", maps\wmd_amb::radar_dish_sounds_stop, "a_radar05" ); 
	
	
	ent1 = getent( "fxanim_gp_tarp_wood_stack_mod", "targetname" );
	ent2 = getent( "fxanim_wmd_fuel_hose_mod", "targetname" );
	ent3 = getent( "fxanim_gp_aspen_05_mod", "targetname" );
	ent4 = getent( "fxanim_wmd_radar_mod", "targetname" );
	ent5 = getent( "fxanim_wmd_catwalk_mod", "targetname" );
	ent6 = getent( "fxanim_wmd_hangar_doors_mod", "targetname" );
	ent7 = getent( "fxanim_wmd_heat_pipe01", "targetname" );
	ent8 = getent( "fxanim_wmd_heat_pipe02", "targetname" );
	ent9 = getent( "fxanim_wmd_electric_tower01_mod", "targetname" );
	ent10 = getent( "fxanim_wmd_electric_tower02_mod", "targetname" );
	ent11 = getent( "fxanim_wmd_ava_wall_mod", "targetname" );
	ent12 = getent( "fxanim_wmd_parachute_01", "targetname" );
	ent13 = getent( "fxanim_wmd_parachute_02", "targetname" );
	ent14 = getent( "fxanim_wmd_parachute_03", "targetname" );
	
	enta_windsock = getentarray( "fxanim_gp_windsock_mod", "targetname" );
	enta_streamer_01 = getentarray( "fxanim_gp_streamer01_mod", "targetname" );
	enta_streamer_02 = getentarray( "fxanim_gp_streamer02_mod", "targetname" );
	enta_square_anetta = getentarray( "fxanim_wmd_square_anetta_mod", "targetname" );
	
	
	if (IsDefined(ent1)) 
	{
		ent1 thread tarp_woodstack();
		println("************* FX: tarp_woodstack *************");
	}
	
	if (IsDefined(ent2)) 
	{
		ent2 thread fuel_hose();
		println("************* FX: fuel_hose *************");
	}
	
	for(i=0; i<enta_windsock.size; i++)
	{
 		enta_windsock[i] thread windsock(1,5);
 		println("************* FX: windsock *************");
	}
	
	if (IsDefined(ent3)) 
	{
		ent3 thread tanker_tree();
		println("************* FX: tanker_tree *************");
	}
	
	for(i=0; i<enta_streamer_01.size; i++)
	{
 		enta_streamer_01[i] thread streamer_01(1,3);
 		println("************* FX: streamer_01 *************");
	}
	
	for(i=0; i<enta_streamer_02.size; i++)
	{
 		enta_streamer_02[i] thread streamer_02(1,3);
 		println("************* FX: streamer_02 *************");
	}
	
	if (IsDefined(ent4)) 
	{
		ent4 thread radar();
		println("************* FX: radar *************");
	}
	
	if (IsDefined(ent5)) 
	{
		ent5 thread catwalk();
		println("************* FX: catwalk *************");
	}
	
	for(i=0; i<enta_square_anetta.size; i++)
	{
 		enta_square_anetta[i] thread square_anetta(1,3);
 		println("************* FX: square_anetta *************");
	}
	
	if (IsDefined(ent6)) 
	{
		ent6 thread hangar_doors();
		println("************* FX: hangar_doors *************");
	}
	
	if (IsDefined(ent7)) 
	{
		ent7 thread heat_pipe01();
		println("************* FX: heat_pipe01 *************");
	}

	if (IsDefined(ent8)) 
	{
		ent8 thread heat_pipe02();
		println("************* FX: heat_pipe02 *************");
	}
	
	if (IsDefined(ent9)) 
	{
		ent9 thread electric_tower01();
		println("************* FX: electric_tower01 *************");
	}
	
	if (IsDefined(ent10)) 
	{
		ent10 thread electric_tower02();
		println("************* FX: electric_tower02 *************");
	}
	
	if (IsDefined(ent11)) 
	{
		ent11 thread ava_wall();
		println("************* FX: ava_wall *************");
	}
	
	if (IsDefined(ent12)) 
	{
		ent12 thread parachute_01();
		println("************* FX: parachute_01 *************");
	}
	
	if (IsDefined(ent13)) 
	{
		ent13 thread parachute_02();
		println("************* FX: parachute_02 *************");
	}
	
	if (IsDefined(ent14)) 
	{
		ent14 thread parachute_03();
		println("************* FX: parachute_03 *************");
	}
}

tarp_woodstack()
{
	wait(1.0);
	self UseAnimTree(#animtree);
	anim_single(self, "a_tarp_woodstack", "fxanim_props");
}

fuel_hose()
{
	level waittill("fuel_hose_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_fuel_hose", "fxanim_props");
}

windsock(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_windsock", "fxanim_props");
}

tanker_tree()
{
	level waittill("tanker_tree_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_tanker_tree", "fxanim_props");
}

streamer_01(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_streamer_01", "fxanim_props");
}

streamer_02(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_streamer_02", "fxanim_props");
}

catwalk()
{
	level waittill("catwalk_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_catwalk", "fxanim_props");
	level waittill("catwalk_fall_start");
	anim_single(self, "a_catwalk_fall", "fxanim_props");
}

radar()
{
	level endon( "stop_radar_dish" );

	level waittill("radar01_start");
	self UseAnimTree(#animtree);
	
	while( 1 )
	{
		anim_single(self, "a_radar01", "fxanim_props");	
		wait( RandomInt( 5 ) );

		anim_single(self, "a_radar02", "fxanim_props");
		wait( RandomInt( 5 ) );
		
		anim_single(self, "a_radar03", "fxanim_props");
		wait( RandomInt( 5 ) );	
		
		anim_single(self, "a_radar04", "fxanim_props");
		wait( RandomInt( 5 ) );
		
		anim_single(self, "a_radar05", "fxanim_props");
		wait( RandomInt( 5 ) );
	}
}
	
square_anetta(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_square_anetta", "fxanim_props");
}

hangar_doors()
{
	level waittill("hangar_doors_start");
	
	level thread play_door_alarms();
	
	self PlaySound( "evt_wmd_hangar_door_start" );
	self PlayLoopSound( "evt_wmd_hangar_door_loop" );
	self UseAnimTree(#animtree);
	anim_single(self, "a_hangar_doors", "fxanim_props");
	
	level notify( "stop_hangar_door_alarms" );
	
	self StopLoopSound( .5 );
	self PlaySound( "evt_wmd_hangar_door_stop" );
}

play_door_alarms()
{
    sound_ent1 = Spawn( "script_origin", ( 12535, -5512, 10221 ));
    sound_ent2 = Spawn( "script_origin", ( 13198, -4813, 10253 ));
    
    sound_ent1 PlayLoopSound( "evt_wmd_hanfar_door_alarm", .5 );
    sound_ent2 PlayLoopSound( "evt_wmd_hanfar_door_alarm", .5 );
    
    level waittill( "stop_hangar_door_alarms" );
    
    sound_ent1 StopLoopSound( .5 );
    sound_ent2 StopLoopSound( .5 );
}
	
heat_pipe01()
{
	level waittill("heat_pipe01_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_heat_pipe01", "fxanim_props");
}

heat_pipe02()
{
	level waittill("heat_pipe01_start");
	wait(.5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_heat_pipe02", "fxanim_props");
}

electric_tower01()
{
	wait(1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_electric_tower_top", "fxanim_props");
	level waittill("electric_towers_start");
	wait(1);
	anim_single(self, "a_electric_tower01", "fxanim_props");
}	

electric_tower02()
{
	level waittill("electric_towers_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_electric_tower02", "fxanim_props");
}	

ava_wall()
{
	level waittill("ava_wall_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_ava_wall", "fxanim_props");
}

parachute_01()
{
	self Hide();
	level waittill("ground_parachutes_start");
	self Show();
	wait(1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_parachute", "fxanim_props");
}

parachute_02()
{
	self Hide();
	level waittill("ground_parachutes_start");
	self Show();
	wait(.5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_parachute", "fxanim_props");
}

parachute_03()
{
	self Hide();
	level waittill("ground_parachutes_start");
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_parachute", "fxanim_props");
}		




wind_initial_setting()
{
	SetSavedDvar( "wind_global_vector", "-230 -55 0" );    // change "0 0 0" to your wind vector
	SetSavedDvar( "wind_global_low_altitude", 0);    // change 0 to your wind's lower bound
	SetSavedDvar( "wind_global_hi_altitude", 3998);    // change 10000 to your wind's upper bound
	SetSavedDvar( "wind_global_low_strength_percent", 1);    // change 0.5 to your desired wind strength percentage
}

main()
{	

	initModelAnims();
	precache_util_fx();
	precache_createfx_fx();
	precache_scripted_fx();	
	
	Footsteps();
	
	// calls the createfx server script (i.e., the list of ambient effects and their attributes)
	maps\createfx\wmd_fx::main();
		
	wind_initial_setting();
	maps\createart\wmd_art::main();
	//clouds();
	//barrel_fire();
}

footsteps()
{
	animscripts\utility::setFootstepEffect( "snow", LoadFx( "bio/player/fx_footstep_snow"));
	animscripts\utility::setFootstepEffect( "water", LoadFx( "bio/player/fx_footstep_water"));
}

/*------------------------------------
TEMP SCRIPTED FX
------------------------------------*/
clouds()
{
	points = getstructarray("cloud_layer","targetname");
	for(i=0;i<points.size;i++)
	{
		playfx(level._effect["clouds_cl"]	,points[i].origin);
	}
}

barrel_fire()
{
	ent = getent("barrel_fire","targetname");
	playfx(level._effect["barrel_fire"],ent.origin);
}




/*------------------------------------
light under the bunkers in the tunnel
------------------------------------*/
breach_light()
{

	//grab the lantern model
	
	lantern = getent("swing_lamp","targetname");
	lght = getent("swing_light","targetname");
	
	if(!isdefined(lght))
	{
		return;
	}
	
	lght linkto(lantern);
	//lght setlightintensity(2.1);
	
	//UNCOMMENT THIS WHEN YOU GET A LIGHT CONE EFFECT
	/*
	mdl = spawn("script_model",lantern.origin);
	mdl.angles = (90,0,0);
	mdl setmodel("tag_origin");
	mdl linkto(lantern);
	playfxontag(level._effect["tunnel_light_fx"],mdl,"tag_origin");
	*/
	//lantern physicslaunch ( lantern.origin, (randomintrange(-30,30),randomintrange(-30,30),randomintrange(-30,30)) );
	PhysicsExplosionSphere( ( lantern.origin + ( 100, 100,100 ) ), 300, 300, 1.4 );
}
