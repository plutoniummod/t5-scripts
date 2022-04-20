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
	level._effect["bloody_death"][0]			= LoadFX("impacts/flesh_hit_body_fatal_lg_exit");
	level._effect["bloody_death"][1]			= LoadFX("impacts/flesh_hit_body_fatal_exit");
	level._effect["bloody_death"][2]			= LoadFX("impacts/flesh_hit_extreme");

	//fx for intro fight
	level._effect["punch_blood"]				= LoadFX("bio/blood/fx_blood_squirting_punch_hit");
	level._effect["fall_dust"]					= LoadFX("maps/vorkuta/fx_footstep_scuffle_kickup_dust");
	
	level._effect["bloody_hit"]					= LoadFX("impacts/flesh_hit_head_fatal_exit");

	//played on the hit helicopter in the courtyard
	level._effect[ "rpg_trail" ]				= LoadFX("weapon/grenade/fx_trail_rpg");
	
	//smoke that comes off the engine train cart
	level._effect[ "train_smoke" ] 				= LoadFX("maps/vorkuta/fx_smoke_train");

	//spotlight used on the courtyard hip
	level._effect[ "spotlight" ]				= LoadFX( "maps/river/fx_river_headlight_huey" ); 
	
	//warning fire fx for the gaz
	level._effect["warning_fire"]				= LoadFX("maps/vorkuta/fx_fire_fuel_outdoor_md");

	//explosions
	level._effect["truck_explosion"]			= LoadFX("maps/vorkuta/fx_explosion_truck_main");
	level._effect["truck_explosion_linked"]		= LoadFX("maps/vorkuta/fx_explosion_truck_linked");
	level._effect["vehicle_explosion"]			= LoadFX("maps/vorkuta/fx_explosion_tower_main");
	level._effect["fuel_tank_explosion"]		= LoadFX("maps/vorkuta/fx_explosion_fuel_barrels");
	level._effect["armory_window"]			    = LoadFX("explosions/fx_grenadeexp_concrete");
	
	//welding sparks
	level._effect["welding_sparks"]      = LoadFX("env/electrical/fx_elec_burst_oneshot");
	
	//smoke plumes for E2 left vista
	level._effect["black_smoke"]          = LoadFX("env/smoke/fx_smk_plume_sm_blk");
		
	//welding sparks
	level._effect["welding_sparks"]      = LoadFX("maps/vorkuta/fx_flame_welding_torch_sparks");
		
	//smoke plumes for E2 left vista
	level._effect["black_smoke"]          = LoadFX("env/smoke/fx_smk_plume_sm_blk");
		
	//bike Damage
	level._effect["bike_smoke"]          = LoadFX("vehicle/vfire/fx_vfire_m72_bike_damage");
		
	level._effect["river_splash"]          = LoadFX("maps/vorkuta/fx_water_splash_impact_lg_forward");
		
	//enemy bike damage (sparks, lg flesh hit)
	level._effect["bike_sparks"]          = LoadFX("impacts/fx_xtreme_metalhit");
	level._effect["flesh_hit_lg"]			= LoadFX("impacts/fx_flesh_hit_body_fatal_lg_exit");
			
	//character burn fx
	level._effect["character_fire_pain_sm"]     = LoadFX( "env/fire/fx_fire_player_sm_1sec" );
	level._effect["character_fire_death_sm"]    = LoadFX( "env/fire/fx_fire_player_md" );
	level._effect["character_fire_death_torso"] = LoadFX( "env/fire/fx_fire_player_torso" );
	
	//outdoor fx on player
	level._effect["player_outdoor"]     = LoadFX( "maps/vorkuta/fx_player_env_spawner" );
	level._effect["player_mine"]		= LoadFX( "maps/vorkuta/fx_footstep_kickup_dust" );

	
	//TRANSPARENT smoke (AI can see through)
	level._effect["defend_start_smoke"] = LoadFX( "weapon/grenade/fx_smoke_grenade_nbloc");
	
	//Temp fire fx
	level._effect["firebig"] = loadfx("maps/wmd/fx_vehicle_fuel_tank_fire1");
	
	//Slingshot ammo
	level._effect["slingshot_molotov_wicker"] = LoadFX( "maps/vorkuta/fx_fire_molotov_wicker" );

	//3rd person slingshot projectile
	level._effect["slingshot_projectile"] = LoadFX( "maps/vorkuta/fx_fire_projectile_1" );

	//Guard bloodspray
	level._effect["impale_blood"] = LoadFX( "maps/vorkuta/fx_blood_exit" );
	level._effect["impale_blood_long"] = LoadFX( "maps/vorkuta/fx_blood_exit_long" );

	// heli hip explosion
	level._effect["hip_explosion"] = LoadFX( "vehicle/vexplosion/fx_vexplode_hip_aerial" );

	//Sergei coughing up blood
	level._effect["cough_blood"] = LoadFX( "bio/blood/fx_blood_squirting_cough" );

	// lights
	level._effect["test_spin_fx"] = LoadFX( "env/light/fx_light_warning");
}		

// Ambient effects <<<<<QUINN SECTION>>>>>
precache_createfx_fx()
{
	level._effect["ash_cloud_1"]                           = LoadFX( "maps/vorkuta/fx_ash_cloud_1" );
	level._effect["ash_coal_dust_falling"]                 = LoadFX( "maps/vorkuta/fx_ash_coal_dust_falling" );	
	level._effect["ash_cloud_gush_indoor"]                 = LoadFX( "maps/vorkuta/fx_ash_cloud_gush_indoor" );	
  level._effect["ash_cloud_2"]                           = LoadFX( "maps/vorkuta/fx_ash_cloud_2" );
  level._effect["ash_cloud_2_dense"]                     = LoadFX( "maps/vorkuta/fx_ash_cloud_2_dense" );  
  level._effect["ash_cloud_3"]                           = LoadFX( "maps/vorkuta/fx_ash_cloud_3_spawner" ); 
//  level._effect["snow_gust_1"]                           = LoadFX( "maps/vorkuta/fx_snow_gust_1" );  
  level._effect["snow_gust_2"]                           = LoadFX( "maps/vorkuta/fx_snow_gust_2" );  
  level._effect["snow_gust_3"]                           = LoadFX( "maps/vorkuta/fx_snow_gust_3" );     
  level._effect["snow_gust_spot_1"]                      = LoadFX( "maps/vorkuta/fx_snow_gust_spot_1" ); 
  level._effect["snow_gust_spot_2"]                      = LoadFX( "maps/vorkuta/fx_snow_gust_spot_2" ); 
  level._effect["snow_gust_spot_2distant"]               = LoadFX( "maps/vorkuta/fx_snow_gust_spot_2distant" );   
  level._effect["wind_lead_sm"]                          = LoadFX( "maps/vorkuta/fx_wind_lead_sm" ); 
  level._effect["wind_lead_sm_loop"]                     = LoadFX( "maps/vorkuta/fx_wind_lead_sm_loop" );      
  level._effect["wind_lead_md"]                          = LoadFX( "maps/vorkuta/fx_wind_lead_md" );       
//  level._effect["cloud_rolling_small"]                   = LoadFX( "maps/vorkuta/fx_cloud_rolling_sm" ); 
  level._effect["cloud_rolling_medium"]                  = LoadFX( "maps/vorkuta/fx_cloud_rolling_md" ); 
  level._effect["cloud_rolling_medium_right"]            = LoadFX( "maps/vorkuta/fx_cloud_rolling_md_right" );   
  level._effect["cloud_rolling_glow_large"]              = LoadFX( "maps/vorkuta/fx_cloud_rolling_glow_lg" ); 
  level._effect["smoke_plume_distant_1"]                 = LoadFX( "maps/vorkuta/fx_smoke_plume_distant_1" );
  level._effect["smoke_stack_distant_1"]                 = LoadFX( "maps/vorkuta/fx_smoke_stack_distant_1" ); 
  level._effect["smoke_stack_close"]                     = LoadFX( "maps/vorkuta/fx_smoke_stack_close" );      
  level._effect["smoke_env_linger_mine"]                 = LoadFX( "maps/vorkuta/fx_smoke_env_linger_mine" ); 
  level._effect["smoke_env_linger_factory"]              = LoadFX( "maps/vorkuta/fx_smoke_env_linger_factory" );   
  level._effect["smoke_fire_runner_1"]                   = LoadFX( "maps/vorkuta/fx_smoke_fire_runner_1" );       
//  level._effect["fire_smoke_stack_distant_1"]            = LoadFX( "maps/vorkuta/fx_fire_smoke_stack_distant_1" ); 
  level._effect["light_glow_spot_1"]                     = LoadFX( "maps/vorkuta/fx_light_glow_spot_1" ); 
  level._effect["light_glow_bulb_red"]                   = LoadFX( "maps/vorkuta/fx_light_glow_bulb_red" );  
  level._effect["light_glow_bulb_white"]                 = LoadFX( "maps/vorkuta/fx_light_glow_bulb_white" );     
  level._effect["light_glow_spot_1a"]                    = LoadFX( "maps/vorkuta/fx_light_glow_spot_1a" );   
  level._effect["light_glow_spot_2"]                     = LoadFX( "maps/vorkuta/fx_light_glow_spot_2" );  
  level._effect["light_glow_spot_3"]                     = LoadFX( "maps/vorkuta/fx_light_glow_spot_3" );  
  level._effect["light_glow_spot_4"]                     = LoadFX( "maps/vorkuta/fx_light_glow_spot_4" );    
  level._effect["light_glow_spot_2group"]                = LoadFX( "maps/vorkuta/fx_light_glow_spot_2group" );    
  level._effect["light_glow_lantern_1"]                  = LoadFX( "maps/vorkuta/fx_light_glow_lantern_1" );  
  level._effect["god_rays_medium"]                       = LoadFX( "maps/vorkuta/fx_god_rays_md" );  
  level._effect["god_rays_medium_long"]                  = LoadFX( "maps/vorkuta/fx_god_rays_md_long" );  
  level._effect["god_rays_medium_long_mine"]             = LoadFX( "maps/vorkuta/fx_god_rays_md_long_mine" );    
  level._effect["god_rays_medium_long_wide"]             = LoadFX( "maps/vorkuta/fx_god_rays_md_long_wide" );     
  level._effect["god_rays_small"]                        = LoadFX( "maps/vorkuta/fx_god_rays_sm" ); 
  level._effect["god_rays_small_long"]                   = LoadFX( "maps/vorkuta/fx_god_rays_sm_long" );   
  level._effect["god_rays_door_open"]                    = LoadFX( "maps/vorkuta/fx_god_rays_door_open" ); 
  level._effect["god_rays_bloom"]                        = LoadFX( "maps/vorkuta/fx_god_rays_bloom" );          
  level._effect["fire_ceiling_1"]                        = LoadFX( "maps/vorkuta/fx_fire_ceiling_1" );  
  level._effect["fire_wall_1"]                           = LoadFX( "maps/vorkuta/fx_fire_wall_1" ); 
  level._effect["fire_wall_2"]                           = LoadFX( "maps/vorkuta/fx_fire_wall_2" ); 
  level._effect["fire_wall_2_light"]                     = LoadFX( "maps/vorkuta/fx_fire_wall_2_light" );          
  level._effect["fire_indoor_sm"]                        = LoadFX( "maps/vorkuta/fx_fire_fuel_indoor_sm" );  
  level._effect["fire_indoor_md"]                        = LoadFX( "maps/vorkuta/fx_fire_fuel_indoor_md" );  
  level._effect["fire_outdoor_sm"]                       = LoadFX( "maps/vorkuta/fx_fire_fuel_outdoor_sm" );   
  level._effect["fire_outdoor_md"]                       = LoadFX( "maps/vorkuta/fx_fire_fuel_outdoor_md" ); 
  level._effect["fire_outdoor_lg"]                       = LoadFX( "maps/vorkuta/fx_fire_fuel_outdoor_lg" );  
  level._effect["fire_embers_md"]                        = LoadFX( "maps/vorkuta/fx_fire_embers_md" ); 
  level._effect["fire_residual_small"]                   = LoadFX( "maps/vorkuta/fx_fire_projectile_elem4_loop" ); 
  level._effect["fire_residual_small_6sec"]              = LoadFX( "maps/vorkuta/fx_fire_projectile_elem4" ); 
  level._effect["fire_residual_small_24sec"]             = LoadFX( "maps/vorkuta/fx_fire_projectile_elem4a" );    
  level._effect["fire_residual_large"]                   = LoadFX( "maps/vorkuta/fx_fire_projectile_elem5_loop" );     
  level._effect["shrimp_horde_right"]                    = LoadFX( "maps/vorkuta/fx_shrimp_horde_right" );    
  level._effect["shrimp_horde_left"]                     = LoadFX( "maps/vorkuta/fx_shrimp_horde_left" );  
  level._effect["shrimp_horde_back1"]                    = LoadFX( "maps/vorkuta/fx_shrimp_horde_back1" ); 
  level._effect["shrimp_horde_back2"]                    = LoadFX( "maps/vorkuta/fx_shrimp_horde_back2" );      
  level._effect["dirt_falling_ceiling_1"]                = LoadFX( "maps/vorkuta/fx_dirt_falling_ceiling" ); 
  level._effect["glass_shard_burst_lg"]                  = LoadFX( "maps/vorkuta/fx_glass_burst_large" );  
  level._effect["glass_shard_burst_rappel"]              = LoadFX( "maps/vorkuta/fx_glass_burst_rappel" );    
  level._effect["steam_burst_1"]                         = LoadFX( "maps/vorkuta/fx_steam_burst_1_spawner" ); 
  level._effect["steam_flow_2"]                          = LoadFX( "maps/vorkuta/fx_steam_flow2" );   
  level._effect["water_drip_line"]                       = LoadFX( "env/water/fx_water_drip_xlight_line" ); 
  level._effect["fog_low_mine"]                          = LoadFX( "maps/vorkuta/fx_smoke_env_low_fog_mine" ); 
  level._effect["fog_barrier_mine"]                      = LoadFX( "maps/vorkuta/fx_fog_barrier_mine" );   
  level._effect["sparks_burst_1"]                        = LoadFX( "maps/vorkuta/fx_sparks_burst_spawner" ); 
  level._effect["sparks_lock_burst"]                     = LoadFX( "maps/vorkuta/fx_sparks_lock_burst" );  
  level._effect["explosion_omaha_tower"]                 = LoadFX( "maps/vorkuta/fx_explosion_slingshot_1_omaha" ); 
  level._effect["explosion_starwars_charge"]             = LoadFX( "maps/vorkuta/fx_explosion_starwars_charge" );  
  level._effect["explosion_starwars_burst"]              = LoadFX( "maps/vorkuta/fx_explosion_starwars_burst" );   
  level._effect["explosion_starwars_gas"]                = LoadFX( "maps/vorkuta/fx_explosion_starwars_gas" );  
  level._effect["explosion_armory_burst"]                = LoadFX( "maps/vorkuta/fx_explosion_armory_burst" );  
  level._effect["explosion_helicopter"]                  = LoadFX( "maps/vorkuta/fx_explosion_helicopter" );  
  level._effect["explosion_helicopter2"]                 = LoadFX( "maps/vorkuta/fx_explosion_helicopter2" ); 
  level._effect["explosion_helicopter3"]                 = LoadFX( "maps/vorkuta/fx_explosion_helicopter3" );           
  level._effect["inclinator_dlight"]					 = LoadFX( "maps/vorkuta/fx_dlight_inclinator" );
  level._effect["omaha_muzzle_flash"]					 = LoadFX( "maps/vorkuta/fx_muzzleflash_distant" );
  level._effect["slingshot_muzzle_flash"]				 = LoadFX( "maps/vorkuta/fx_tracer_large" );  
  level._effect["dust_door_burst"]					     = LoadFX( "maps/vorkuta/fx_dust_plume_door" );
  level._effect["blowtorch_scorch_mark"]                 = LoadFX( "maps/vorkuta/fx_decal_blowtorch" );        
                                                                    
}


// FXanim Props
initModelAnims()
{

	level.scr_anim["fxanim_props"]["a_chain_650"] = %fxanim_gp_chain_650_anim;
	level.scr_anim["fxanim_props"]["a_chain01"] = %fxanim_gp_chain01_anim;
	level.scr_anim["fxanim_props"]["a_chain02"] = %fxanim_gp_chain02_anim;
	level.scr_anim["fxanim_props"]["a_chain03"] = %fxanim_gp_chain03_anim;
	level.scr_anim["fxanim_props"]["a_towers"] = %fxanim_vorkuta_towers_anim;
	level.scr_anim["fxanim_props"]["a_heli_crash"] = %fxanim_vorkuta_heli_crash_anim;
	level.scr_anim["fxanim_props"]["a_elevator_wires_loop"] = %fxanim_vorkuta_elevator_wires_loop_anim;
	level.scr_anim["fxanim_props"]["a_elevator_wires_stop"] = %fxanim_vorkuta_elevator_wires_stop_anim;
	level.scr_anim["fxanim_props"]["a_doorblast"] = %fxanim_vorkuta_doorblast_anim;
	level.scr_anim["fxanim_props"]["a_bridge01"] = %fxanim_vorkuta_bridge01_anim;
	level.scr_anim["fxanim_props"]["a_bridge02"] = %fxanim_vorkuta_bridge02_anim;
	level.scr_anim["fxanim_props"]["a_armory"] = %fxanim_vorkuta_armory_anim;
	level.scr_anim["fxanim_props"]["a_tarp1"] = %fxanim_gp_tarp1_anim;
	level.scr_anim["fxanim_props"]["a_canister"] = %fxanim_vorkuta_canister_anim;
	level.scr_anim["fxanim_props"]["a_gate_locked"] = %fxanim_vorkuta_gate_locked_anim;
	level.scr_anim["fxanim_props"]["a_lantern_hang_on"] = %fxanim_gp_lantern_hang_on_anim;
	level.scr_anim["fxanim_props"]["a_bike_tarp"] = %fxanim_vorkuta_bike_tarp_anim;

	addNotetrack_customFunction( "fxanim_props", "towers_explode", ::audio_play_debris, "a_towers" );
	addNotetrack_customFunction( "fxanim_props", "tank01_wall_impact", ::audio_tank1_impact_wall, "a_canister" );
	addNotetrack_customFunction( "fxanim_props", "tank01_ground_impact1", ::audio_tank1_impact_ground1, "a_canister" );
	addNotetrack_customFunction( "fxanim_props", "tank01_ground_impact2", ::audio_tank1_impact_ground2, "a_canister" );
	addNotetrack_customFunction( "fxanim_props", "tank02_wall_impact", ::audio_tank2_impact_wall, "a_canister" );
	addNotetrack_customFunction( "fxanim_props", "tank02_ground_impact1", ::audio_tank2_impact_ground1, "a_canister" );
	addNotetrack_customFunction( "fxanim_props", "tank02_ground_impact2", ::audio_tank2_impact_ground2, "a_canister" );
	addNotetrack_customFunction( "fxanim_props", "tank02_ground_impact3", ::audio_tank2_impact_ground3, "a_canister" );
	
	ent1 = getent( "fxanim_vorkuta_towers_mod", "targetname" );
	ent2 = getent( "fxanim_vorkuta_elevator_wires", "targetname" );
	ent3 = getent( "fxanim_vorkuta_doorblast_mod", "targetname" );
	ent4 = getent( "fxanim_vorkuta_bridge01_mod", "targetname" );
	ent5 = getent( "fxanim_vorkuta_bridge02_mod", "targetname" );
	ent6 = getent( "fxanim_vorkuta_armory_mod", "targetname" );
	ent7 = getent( "fxanim_vorkuta_canister_mod", "targetname" );
	ent8 = getent( "fxanim_vorkuta_gate_locked_mod", "targetname" );
	ent9 = getent( "fxanim_vorkuta_bike_tarp_mod", "targetname" );
	
	enta_chain_650 = getentarray( "fxanim_gp_chain_650_mod", "targetname" );
	enta_chain01 = getentarray( "fxanim_gp_chain01_mod", "targetname" );
	enta_chain02 = getentarray( "fxanim_gp_chain02_mod", "targetname" );
	enta_chain03 = getentarray( "fxanim_gp_chain03_mod", "targetname" );
	enta_tarp1 = getentarray( "fxanim_gp_tarp1_mod", "targetname" );
	enta_lantern_hang_on = getentarray( "fxanim_gp_lantern_hang_on_mod", "targetname" );
	
	
	for(i=0; i<enta_chain_650.size; i++)
	{
 		enta_chain_650[i] thread chain_650(1,3);
 		println("************* FX: chain_650 *************");
	}
	
	for(i=0; i<enta_chain01.size; i++)
	{
 		enta_chain01[i] thread chain01(1,3);
 		println("************* FX: chain01 *************");
	}
	
	for(i=0; i<enta_chain02.size; i++)
	{
 		enta_chain02[i] thread chain02(1,3);
 		println("************* FX: chain02 *************");
	}
	
	for(i=0; i<enta_chain03.size; i++)
	{
 		enta_chain03[i] thread chain03(1,3);
 		println("************* FX: chain03 *************");
	}
	
	if (IsDefined(ent1)) 
	{
		ent1 thread towers();
		println("************* FX: towers *************");
	}
	
	if (IsDefined(ent2)) 
	{
		ent2 thread elevator_wires();
		println("************* FX: elevator_wires *************");
	}
	
	if (IsDefined(ent3)) 
	{
		ent3 thread doorblast();
		println("************* FX: doorblast *************");
	}
	
	if (IsDefined(ent4)) 
	{
		ent4 thread bridge01();
		println("************* FX: bridge01 *************");
	}
	
	if (IsDefined(ent5)) 
	{
		ent5 thread bridge02();
		println("************* FX: bridge02 *************");
	}
	
	if (IsDefined(ent6)) 
	{
		ent6 thread armory();
		println("************* FX: armory *************");
	}
	
	for(i=0; i<enta_tarp1.size; i++)
	{
 		enta_tarp1[i] thread tarp1(1,3);
 		println("************* FX: tarp1 *************");
	}
	
	if (IsDefined(ent7)) 
	{
		ent7 thread canister();
		println("************* FX: canister *************");
	}
	
	if (IsDefined(ent8)) 
	{
		ent8 thread gate_locked();
		println("************* FX: gate_locked *************");
	}
	
	for(i=0; i<enta_lantern_hang_on.size; i++)
	{
 		enta_lantern_hang_on[i] thread lantern_hang_on(1,3);
 		println("************* FX: lantern_hang_on *************");
	}

	if (IsDefined(ent9)) 
	{
		ent9 thread bike_tarp();
		println("************* FX: bike_tarp *************");
	}
}


chain_650(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_chain_650", "fxanim_props");
}

chain01(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_chain01", "fxanim_props");
}

chain02(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_chain02", "fxanim_props");
}

chain03(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_chain03", "fxanim_props");
}

towers()
{
	level waittill("towers_start");

	//addNotetrack_customFunction( <animname>, <notetrack> , <function> , <scene> )"
	level thread addNotetrack_customFunction("fxanim_props", "towers_explode", ::towers_fx, "a_towers");
	level thread addNotetrack_customFunction("fxanim_props", "helicopter_damage", ::heli_fx, "a_towers");

	self UseAnimTree(#animtree);
	anim_single(self, "a_towers", "fxanim_props");
}

//off notetrack from towers anim
towers_fx( guy )
{
	exploder( 30 );
	ent1 = getent( "fxanim_vorkuta_towers_mod", "targetname" );
  PlayFX (level._effect["explosion_omaha_tower"], ent1.origin);	
	playsoundatposition( "evt_rs_heli_whoosh_0", ent1.origin );

}

//play fx and stop rotors and sounds
heli_fx( guy )
{
	heli = GetEnt( "courtyard_heli", "targetname" );
	
	heli heli_toggle_rotor_fx( 0 );
	heli vehicle_toggle_sounds( 0 );
	PlayFXOnTag( level._effect["hip_explosion"], heli, "tag_body" );
	heli thread play_sound_in_space( heli.deathfxsound );
	heli SetModel( heli.deathmodel );	

	player = get_players()[0];
	player PlayRumbleLoopOnEntity("damage_heavy");	
	Earthquake(0.8, 0.5, player.origin, 256);

	wait(0.5);
	StopAllRumbles();
	wait(0.5);

	player PlayRumbleLoopOnEntity("damage_heavy");	
	Earthquake(0.6, 0.5, player.origin, 256);

	wait(0.4);
	StopAllRumbles();
	wait(0.4);

	player PlayRumbleLoopOnEntity("damage_light");	
	Earthquake(0.4, 0.5, player.origin, 256);

	wait(0.3);
	StopAllRumbles();
	wait(0.3);

	player PlayRumbleLoopOnEntity("damage_light");	
	Earthquake(0.3, 0.4, player.origin, 256);

	wait(0.3);
	StopAllRumbles();
	wait(0.3);
	
	Earthquake(0.2, 0.3, player.origin, 256);
	for(i = 0; i < 3; i++)
	{
		player PlayRumbleLoopOnEntity("damage_light");	
		wait(0.3);
		StopAllRumbles();
		wait(0.5);
	}
	
}

elevator_wires()
{
	flag_init("elevator_wires_start");
	
	flag_wait("elevator_wires_start");
	
	self thread elevator_wires_stop();

	self UseAnimTree(#animtree);
	anim_single(self, "a_elevator_wires_loop", "fxanim_props");
}

elevator_wires_stop(org)
{
	while(flag("elevator_wires_start"))
	{
		wait(0.05);
	}
	self UseAnimTree(#animtree);
	wait(0.8);
	self anim_set_blend_in_time(0.5);
	anim_single(self, "a_elevator_wires_stop", "fxanim_props");
}

doorblast()
{
	level waittill("doorblast_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_doorblast", "fxanim_props");
}

bridge01()
{
	level waittill("bridge01_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_bridge01", "fxanim_props");
}

bridge02()
{
	level waittill("bridge02_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_bridge02", "fxanim_props");
}

armory()
{
	level waittill("towers_start");
	wait(7.7);
	self UseAnimTree(#animtree);
	anim_single(self, "a_armory", "fxanim_props");
}

tarp1(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_tarp1", "fxanim_props");
}

canister()
{
	level waittill("canister_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_canister", "fxanim_props");
}

gate_locked()
{
	level waittill("gate_locked_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_gate_locked", "fxanim_props");
}

lantern_hang_on(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_lantern_hang_on", "fxanim_props");
}

bike_tarp()
{
	level waittill("bike_tarp_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_bike_tarp", "fxanim_props");
}





	
wind_initial_setting()
{
	SetSavedDvar( "wind_global_vector", "130 140 0" );    // change "0 0 0" to your wind vector
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
	
	footsteps();

	maps\createfx\vorkuta_fx::main();
		
	wind_initial_setting();
	
	maps\createart\vorkuta_art::main();
}


footsteps()
{
	animscripts\utility::setFootstepEffect( "dirt", LoadFx( "maps/vorkuta/fx_footstep_kickup_dust"));
	animscripts\utility::setFootstepEffect( "snow", LoadFx( "bio/player/fx_footstep_snow_ash"));
}

audio_play_debris( guy )
{
    player = get_players()[0];
    
    level thread play_fire_sounds();
    
    for( i=0; i<10; i++ )
    {
        origin = player.origin;
        random_org = ( RandomIntRange( -100, 100 ), RandomIntRange( -100, 100 ), 0 );
        origin = origin + random_org;
        
        playsoundatposition( "evt_impact_metal_" + i, origin );
        wait(RandomFloatRange(0,2));
    }
}

play_fire_sounds()
{
    sound_ent1 = Spawn( "script_origin", (850, 7160, 1480) );
    sound_ent2 = Spawn( "script_origin", (1425, 7160, 1480) );
    
    sound_ent1 PlayLoopSound( "amb_mine_fire" );
    sound_ent2 PlayLoopSound( "amb_mine_fire" );
    
    flag_wait("player_3rd_floor");
    
    //IPrintLnBold( "SOUND: DELETING FIRE ENTS" );
    sound_ent1 Delete();
    sound_ent2 Delete();
}

audio_tank1_impact_wall( guy )
{
    playsoundatposition( "exp_omaha_debris_wall_0", (655, 3135, 1320) );
}

audio_tank1_impact_ground1( guy )
{
    playsoundatposition( "exp_omaha_debris_ground_0", (645, 3050, 1100) );
}

audio_tank1_impact_ground2( guy )
{
    playsoundatposition( "exp_omaha_debris_ground_2", (485, 2950, 1025) );
}

audio_tank2_impact_wall( guy )
{
    playsoundatposition( "exp_omaha_debris_wall_1", (655, 3135, 1320) );
}

audio_tank2_impact_ground1( guy )
{
    playsoundatposition( "exp_omaha_debris_ground_1", (645, 3050, 1100) );
}

audio_tank2_impact_ground2( guy )
{
    playsoundatposition( "exp_omaha_debris_ground_3", (645, 3050, 1100) );
}

audio_tank2_impact_ground3( guy )
{
    playsoundatposition( "exp_omaha_debris_ground_4", (490, 3175, 1020) );
}
