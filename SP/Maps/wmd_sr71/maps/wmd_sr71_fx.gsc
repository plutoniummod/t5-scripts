
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
	//for bloody death utility script:
	level._effect["bloody_death"][0]			= LoadFX("impacts/flesh_hit_head_fatal_exit");
	level._effect["bloody_death"][1]			= LoadFX("impacts/flesh_hit_head_fatal_exit");
	level._effect["bloody_death"][2]			= LoadFX("impacts/flesh_hit_head_fatal_exit");
	
	level._effect["knife_death"]					= LoadFX("impacts/flesh_hit_head_fatal_exit");
	
	//flesh_hit_body_fatal_exit
	//flesh_hit_neck_fatal
	//flesh_hit_head_fatal_exit
	//flesh_hit_knife
	//flesh_hit_splat_large
	//flesh_slash_knife_blood_emitter
	
	level._effect["player_cloud"] = loadfx("env/weather/fx_basejump_freefall_speedvisual");
	level._effect["cloud_layers"] = loadfx("env/weather/fx_clouds_basejump_cl_layer");
	level._effect["landing_fx"] = loadfx("env/dirt/fx_dirt_basejump_land");
	level._effect["ledge_rocks"] = loadfx("env/dirt/fx_rock_ledge_basejump");
	
	level._effect["spotlight_fx"] = loadfx("env/light/fx_search_light_tower");
	level._effect["barrel_fire"] = loadfx("env/fire/fx_fire_barrel_small");
	level._effect["garage_sparks"]= loadfx("env/electrical/fx_elec_burst_oneshot_distant");
	level._effect["wire_sparks"] = loadfx("env/electrical/fx_elec_panel_spark_md");
	level._effect["garage_big_spark1"] = loadfx("env/electrical/fx_elec_burst_shower_sm_os");
	level._effect["garage_big_spark2"] = loadfx("env/electrical/fx_elec_burst_heavy_os");
	

	//uaz
	level._effect[ "uaz_exhaust" ]	= LoadFX( "vehicle/exhaust/fx_exhaust_jeep_uaz" );
	level._effect[ "uaz_headlight" ]	= LoadFX( "vehicle/light/fx_jeep_uaz_headlight" );
	level._effect[ "uaz_taillight" ]	= LoadFX( "vehicle/light/fx_jeep_uaz_taillight" );
	
	
	level._effect["avalanche"] = loadfx("maps/wmd/fx_avalanche_base");
	level._effect["sa2_trail"] = loadfx("smoke/smoke_geotrail_sa_2");
	level._effect["snow_burst"] = loadfx("maps/wmd/fx_snow_ai_burst");
	
	level._effect["blackbird_exhaust"] = LoadFX("vehicle/exhaust/fx_exhaust_blackbird");
	level._effect["blackbird_exhaust_smoke"] = LoadFX("smoke/smoke_sr71_turbine_ignite_burst");
	level._effect["blackbird_takeoff_wind"] = LoadFX("env/weather/fx_wind_layer_speedvisual_sr71");
	level._effect["blackbird_wheel_light"] = LoadFX("maps/wmd/fx_wmd_sr71_headlight" );
 	level._effect["flesh_hit"]							= LoadFX("impacts/fx_flesh_hit");
 	level._effect["rts_guy_trail"] = loadfx("maps/wmd/fx_wmd_rts_ghosting");//LoadFX( "weapon/rocket/fx_rocket_m202_geotrail");
 	level._effect["flashlight"] = loadfx("env/light/fx_flashlight_nolight");
	
	level._effect["custom_tracer"] = loadfx("maps/wmd/fx_wmd_rts_muzzleflash_tracer");
	level._effect["rts_uaz_headlight"] = loadfx("maps/wmd/fx_wmd_rts_vehicle_headlight");
	level._effect["rts_flare"] = loadfx("weapon/napalm/fx_napalm_marker_trail");
	level._effect["rts_bloodsplatter"] = loadfx("maps/wmd/fx_wmd_rts_impact_fatal_hit");
	level._effect["bang"] = loadfx("explosions/fx_flashbang");

	
	level._effect["electric_box"] = loadfx("destructibles/fx_dest_elec_box");

	
	//cold breath
	level._effect["cold_breath"] = loadfx("bio/player/fx_cold_breath2");
	level._effect["cold_breath_elem"] = loadfx("bio/player/fx_cold_breath2_elem");
	level._effect["cold_breath_player"] = loadfx("bio/player/fx_cold_breath2_player");
}

// Ambient effects
precache_createfx_fx()
{
	level._effect["a_sand_blowing_xlg"]				    	= loadfx("env/dirt/fx_sand_blowing_xlg");
	level._effect["a_sand_blowing_xlg_direct"]		  = loadfx("env/dirt/fx_sand_blowing_xlg_direct");	
	level._effect["sand_windy_md"]		              = loadfx("env/weather/fx_sand_windy_md");		
  level._effect["scene_runway_dust"]              = loadfx("maps/wmd/fx_wmd_scene_dust_gust_runway"); 
  level._effect["scene_runway_lights"]            = loadfx("maps/wmd/fx_wmd_scene_lights_runway");     	
	level._effect["rocks_falling"]					        = loadfx("env/dirt/fx_rock_debris_ropebridge");
  level._effect["cloud_layer_speedvisual"] 				= loadfx("env/weather/fx_cloud_layer_speedvisual"); 
  level._effect["cloud_layer_speedvisual2"] 			= loadfx("env/weather/fx_cloud_layer_speedvisual2");  
  level._effect["cloud_layer_speedvisual3"] 			= loadfx("env/weather/fx_cloud_layer_speedvisual3"); 
  level._effect["cloud_layer_speedvisual4"] 			= loadfx("env/weather/fx_cloud_layer_speedvisual4");       
  level._effect["rts_cloud_layer1"] 				    	= loadfx("env/weather/fx_rts_cloud_layer");         
  

  level._effect["snow_tree_fall_big_spawner"] 		= loadfx("env/foliage/fx_snow_falling_tree_big_spawner");  
  level._effect["snow_flakes_windy_blizzard"] 		= loadfx("env/weather/fx_snow_blizzard_intense");
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
	level._effect["snow_gust_ground_lg"] 					  = loadfx("env/weather/fx_snow_gust_ground_lg");
  level._effect["snow_gust_wind_dense"] 				  = loadfx("env/weather/fx_snow_gust_wind_dense");
  level._effect["snow_gust_wind_dense_rts"] 		  = loadfx("env/weather/fx_snow_gust_wind_dense_rts");     	
  level._effect["snow_debris_plume_sm"] 			    = loadfx("env/weather/fx_snow_debris_plume_sm"); 
  level._effect["snow_debris_plume_md"] 			    = loadfx("env/weather/fx_snow_debris_plume_md");    	
	level._effect["snow_gust_kickup1"] 				  	  = loadfx("env/weather/fx_snow_gust_kickup1");
	level._effect["snow_gust_kickup2"] 				  	  = loadfx("env/weather/fx_snow_gust_kickup2");	
  level._effect["cloud_layer_earth"] 		        	= loadfx("maps/wmd/fx_cloud_layer_earth");
  level._effect["cloud_layer_earth2"] 		       	= loadfx("maps/wmd/fx_cloud_layer_earth2");  
  level._effect["cloud_layer_earth_flash"] 		   	= loadfx("maps/wmd/fx_cloud_layer_earth_flash");  
  level._effect["glass_break"]                    = loadfx("maps/wmd/fx_break_glass_window_large" );
  level._effect["ambience_swirling1"]             = loadfx("maps/wmd/fx_wmd_room_swirling_ambience" ); 
  level._effect["ambience_swirling2"]             = loadfx("maps/wmd/fx_wmd_room_swirling_ambience2" );  
  level._effect["ambience_swirling2a"]            = loadfx("maps/wmd/fx_wmd_room_swirling_ambience2a" );    
  level._effect["godray_md"]                      = loadfx("maps/wmd/fx_light_godray_wmd_md"); 
  level._effect["godray_sm"]                      = loadfx("maps/wmd/fx_light_godray_wmd_sm_sr71");   
  level._effect["satellite_glint"]                = loadfx("maps/wmd/fx_satellite_glint"); 
  level._effect["rts_ghosting_elem"]              = loadfx("maps/wmd/fx_wmd_rts_ghosting_elem"); 
  level._effect["rts_ghosting"]                   = loadfx("maps/wmd/fx_wmd_rts_ghosting"); 
  level._effect["sr71_inst_lighting1"]            = loadfx("maps/wmd/fx_wmd_sr71_instrument_lights1"); 
  level._effect["sr71_inst_lighting2"]            = loadfx("maps/wmd/fx_wmd_sr71_instrument_lights2"); 
  level._effect["sr71_inst_lighting3"]            = loadfx("maps/wmd/fx_wmd_sr71_instrument_lights3"); 
  level._effect["light_runway_glow_red"]          = loadfx("maps/wmd/fx_wmd_runway_red_light_glow");      
  level._effect["sr71_runway_lighting1"]          = loadfx("maps/wmd/fx_wmd_sr71_runway_lights1"); 
  level._effect["sr71_runway_lighting2"]          = loadfx("maps/wmd/fx_wmd_sr71_runway_lights2");
  level._effect["sr71_runway_lighting3"]          = loadfx("maps/wmd/fx_wmd_sr71_runway_lights3");  
  level._effect["sr71_contrails"]                 = loadfx("maps/wmd/fx_wmd_sr71_contrails");  
  level._effect["sr71_dressing"]                  = loadfx("maps/wmd/fx_wmd_sr71_dressing");        
  level._effect["light_lamp_glow_white"]          = loadfx("maps/wmd/fx_wmd_lamp_white_light_glow"); 
  level._effect["light_lamp_glow_red"]            = loadfx("maps/wmd/fx_wmd_lamp_red_light_glow");   
  level._effect["light_glow_red"]                 = loadfx("maps/wmd/fx_wmd_tower_red_light_glow");  
  level._effect["light_glow_green"]               = loadfx("maps/wmd/fx_wmd_tower_green_light_glow");  
  level._effect["light_glow_amber"]               = loadfx("maps/wmd/fx_wmd_tower_amber_light_glow");  
  level._effect["fuel_tank_fire_lg"]              = loadfx("maps/wmd/fx_vehicle_fuel_tank_fire1");
  level._effect["fuel_tank_fire_sm"]              = loadfx("maps/wmd/fx_vehicle_fuel_tank_fire2"); 
  level._effect["fuel_tank_fire_xsm"]             = loadfx("maps/wmd/fx_vehicle_fuel_tank_fire3"); 
  level._effect["snow_door_fallen_puff"]          = loadfx("maps/wmd/fx_snow_door_fallen_puff");  
  level._effect["breech_wind_gust_loop"]          = loadfx("maps/wmd/fx_wmd_breech_wind_gust");   
  level._effect["snow_falling_drift_small"]       = loadfx("maps/wmd/fx_snow_falling_drift"); 
  level._effect["light_flare_player"]             = loadfx("maps/wmd/fx_wmd_light_flare_player"); 
  level._effect["radar_wire_sparks"]              = loadfx("maps/wmd/fx_wmd_sparks_impact_burst2"); 
  level._effect["console_destroyed_sparks"]       = loadfx("maps/wmd/fx_wmd_sparks_impact_burst3");                                                  
  level._effect["distortion_heat_field_lg"]       = loadfx("env/distortion/fx_distortion_heat_field_lg"); 
  level._effect["distortion_heat_field_sm"]       = loadfx("env/distortion/fx_distortion_heat_field_sm");
  level._effect["sr71_wind_speedvisual"]          = loadfx("env/weather/fx_wind_layer_speedvisual_sr71"); 
  level._effect["sr71_wind_speedvisual_elem"]     = loadfx("env/weather/fx_wind_layer_speedvisual_sr71_elem"); 
  level._effect["sr71_exhaust_smoke_burst"]       = loadfx("smoke/smoke_sr71_turbine_ignite_burst");  
  level._effect["sparks_element1"]                = loadfx("env/electrical/fx_elec_burst_shower_sm_os");   
  level._effect["rts_snow_blizzard_detail"]       = loadfx("maps/wmd/fx_snow_blizzard_detail_rts");   
  level._effect["light_glow_spot_3"]              = LoadFX("maps/vorkuta/fx_light_glow_spot_3" );  
  level._effect["snow_gust_window"]               = LoadFX("maps/wmd/fx_snow_gust_window" );  
  level._effect["snow_gust_door"]                 = LoadFX("maps/wmd/fx_snow_gust_door" );       
                     
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
	level.scr_anim["fxanim_props"]["a_streamer_01"] = %fxanim_gp_streamer01_anim;
	level.scr_anim["fxanim_props"]["a_streamer_02"] = %fxanim_gp_streamer02_anim;	


	ent1 = getent( "fxanim_gp_tarp_wood_stack_mod", "targetname" );
	ent2 = getent( "fxanim_wmd_fuel_hose_mod", "targetname" );
	ent3 = getent( "fxanim_gp_aspen_05_mod", "targetname" );

	
	enta_windsock = getentarray( "fxanim_gp_windsock_mod", "targetname" );
	enta_streamer_01 = getentarray( "fxanim_gp_streamer01_mod", "targetname" );
	enta_streamer_02 = getentarray( "fxanim_gp_streamer02_mod", "targetname" );
	
	
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
	maps\createfx\wmd_sr71_fx::main();
		
	wind_initial_setting();
	maps\createart\wmd_sr71_art::main();
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
