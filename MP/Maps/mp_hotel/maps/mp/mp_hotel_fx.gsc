#include maps\mp\_utility; 
#include common_scripts\utility;

// fx prop anim effects
#using_animtree ( "fxanim_props_dlc3" );
precache_fx_prop_anims()
{
	level._fxanims = [];
	level._fxanims[ "fxanim_mp_htl_pool_umbrella" ] = %fxanim_mp_htl_pool_umbrella_anim;
	level._fxanims[ "fxanim_mp_htl_spotlight" ] = %fxanim_mp_htl_spotlight_anim;
	level._fxanims[ "fxanim_mp_htl_pool_pennant1" ] = %fxanim_mp_htl_pool_pennant1_anim;
	level._fxanims[ "fxanim_mp_htl_pool_pennant2" ] = %fxanim_mp_htl_pool_pennant2_anim;
	level._fxanims[ "fxanim_mp_htl_pool_pennant3" ] = %fxanim_mp_htl_pool_pennant3_anim;
}

// Ambient effects
precache_createfx_fx()
{

	level._effect["fx_mp_hotel_fountain_splash_sm"] 					= Loadfx("maps/mp_maps/fx_mp_hotel_fountain_splash_sm");
	level._effect["fx_mp_hotel_fountain_splash_xsm"] 					= Loadfx("maps/mp_maps/fx_mp_hotel_fountain_splash_xsm");	
//	level._effect["fx_mp_hotel_fountain_splash01"] 						= Loadfx("maps/mp_maps/fx_mp_hotel_fountain_splash01");
	level._effect["fx_mp_hotel_fountain_splash02"] 						= Loadfx("maps/mp_maps/fx_mp_hotel_fountain_splash02");
//	level._effect["fx_water_splash_fountain_lg"]              = loadfx("env/water/fx_water_splash_fountain_lg2");
//  level._effect["fx_water_splash_fountain"]             		= loadfx("env/water/fx_water_splash_fountain");
  level._effect["fx_water_jacuzzi_surface"]             		= loadfx("env/water/fx_water_jacuzzi_surface");  
  level._effect["fx_water_jacuzzi_surface_steam"]           = loadfx("env/water/fx_water_jacuzzi_surface_steam");	
  level._effect["fx_steam_hotel_sauna"]           					= loadfx("env/smoke/fx_steam_hotel_sauna");	
  level._effect["fx_steam_hotel_sauna_door"]           			= loadfx("env/smoke/fx_steam_hotel_sauna_door");	
  level._effect["fx_water_pool_drain"]           						= loadfx("env/water/fx_water_pool_drain");	  

  level._effect["fx_smk_smolder_sm"]												= loadfx("maps/mp_maps/fx_mp_smk_smolder_rubble_sm");
  level._effect["fx_mp_fumes_vent_sm_int"]									= loadfx("maps/mp_maps/fx_mp_fumes_vent_sm_int");
	level._effect["fx_mp_fumes_vent_xsm_int"]									= loadfx("maps/mp_maps/fx_mp_fumes_vent_xsm_int"); 
	level._effect["fx_distortion_heat_truck"] 								= loadfx("maps/mp_maps/fx_mp_distortion_transformer");

	level._effect["fx_mp_light_dust_motes_md"]								= loadfx("maps/mp_maps/fx_mp_light_dust_motes_md");
	level._effect["fx_dust_crumble_int_sm"]										= loadfx("env/dirt/fx_dust_crumble_int_sm");
	level._effect["fx_dust_crumble_int_md"]										= loadfx("env/dirt/fx_dust_crumble_int_md");
	
	level._effect["fx_insects_swarm_md_light"]								= loadfx("bio/insects/fx_insects_swarm_md_light");
	
	level._effect["fx_fire_sm"]																= loadfx("env/fire/fx_fire_sm");	

//	level._effect["fx_light_beacon_red"]											= loadfx("env/light/fx_light_beacon_red_sm");
//  level._effect["fx_light_beacon_red_distant_slw"]					= loadfx("env/light/fx_light_beacon_red_distant_slw");
//  level._effect["fx_mp_berlin_light_cone"]									= loadfx("maps/mp_maps/fx_mp_berlin_light_cone");	
  level._effect["fx_light_floodlight_int_blue_sqr"]					= loadfx("env/light/fx_light_floodlight_int_blue_sqr");
  level._effect["fx_light_overhead_sm_warm"]				  			= loadfx("maps/mp_maps/fx_mp_light_recessed_wrm");	
 	level._effect["fx_light_pent_ceiling_light"]							= loadfx("env/light/fx_light_pent_ceiling_light");
 	level._effect["fx_mp_outskirts_floures_glow1"]						=	loadfx("maps/mp_maps/fx_mp_outskirts_floures_glow_1");
 	level._effect["fx_mp_outskirts_floures_glow_warm"]				=	loadfx("maps/mp_maps/fx_mp_outskirts_floures_glow_warm");	  
 	level._effect["fx_light_bulb_sm_hotel_sconce"]						=	loadfx("env/light/fx_light_bulb_sm_hotel_sconce");	  	
 	level._effect["fx_mp_light_half_globe_hotel"]							=	loadfx("maps/mp_maps/fx_mp_light_half_globe_hotel");
// 	level._effect["fx_light_security_camera"]									=	loadfx("env/light/fx_light_security_camera"); 		
 	level._effect["fx_mp_light_tracklight_sm"]								=	loadfx("maps/mp_maps/fx_mp_light_tracklight_sm"); 
	level._effect["fx_mp_light_tracklight_picture"]						=	loadfx("maps/mp_maps/fx_mp_light_tracklight_picture"); 

 	level._effect["fx_light_godray_lrg_warm"]									=	loadfx("maps/mp_maps/fx_mp_light_gray_hotel_lrg");	
 	level._effect["fx_light_godray_md_warm"]									=	loadfx("maps/mp_maps/fx_mp_light_gray_hotel_md");
 	level._effect["fx_light_godray_md_warm_wide"]							=	loadfx("maps/mp_maps/fx_mp_light_gray_hotel_md_wide"); 		
 	level._effect["fx_light_godray_sm_warm"]									=	loadfx("maps/mp_maps/fx_mp_light_gray_hotel_sm");	
 	level._effect["fx_light_godray_sm_warm_wide"]							=	loadfx("maps/mp_maps/fx_mp_light_gray_hotel_sm_wide");	 	

	level._effect["fx_mp_waves_shorebreak_mp"]								= loadfx("maps/mp_maps/fx_mp_waves_shorebreak_mp_hotel");
	level._effect["fx_mp_waves_shoreline_mp"]									= loadfx("maps/mp_maps/fx_mp_waves_shoreline_mp_hotel");
	
//	level._effect["fx_water_drip_light_short"]								= loadfx("maps/mp_maps/fx_mp_water_drip_xlight_short");
	level._effect["fx_water_faucet_drip_fast"]								= loadfx("env/water/fx_water_faucet_drip_fast");		
	
	level._effect["fx_pent_cigar_smoke"]                  		= LoadFX("maps/zombie/fx_zombie_cigar_tip_smoke");
//	level._effect["fx_pent_cigarette_tip_smoke"]          		= LoadFX("maps/zombie/fx_zombie_cigarette_tip_smoke");
	level._effect["fx_pent_smk_ambient_room"]             		= LoadFX("maps/mp_maps/fx_mp_smk_hotel_casino_md");	
	level._effect["fx_pent_smk_ambient_room_lg"]          		= LoadFX("maps/mp_maps/fx_mp_smk_hotel_casino_lg");
	level._effect["fx_pent_smk_ambient_room_sm"]          		= LoadFX("maps/mp_maps/fx_mp_smk_hotel_casino_sm");
	level._effect["fx_steam_pot"]          										= LoadFX("env/smoke/fx_steam_pot");
	level._effect["fx_smk_kitchen_pan"]          							= LoadFX("env/smoke/fx_smk_kitchen_pan");	

//	level._effect["fx_debris_papers_narrow"]									= loadfx("env/debris/fx_debris_papers_narrow");
//	level._effect["fx_debris_papers"]													= loadfx("env/debris/fx_debris_papers");
//	level._effect["fx_debris_money_cuba"]											= loadfx("env/debris/fx_debris_money_cuba");
//	level._effect["fx_debris_money_usa"]											= loadfx("env/debris/fx_debris_money_usa");	
	level._effect["fx_debris_money_usa_narrow"]								= loadfx("env/debris/fx_debris_money_usa_narrow");	
	level._effect["fx_debris_money_usa_short"]								= loadfx("env/debris/fx_debris_money_usa_short");
	level._effect["fx_debris_money_cuba_narrow"]							= loadfx("env/debris/fx_debris_money_cuba_narrow");	
	level._effect["fx_debris_money_cuba_short"]								= loadfx("env/debris/fx_debris_money_cuba_short");	

//	level._effect["fx_elevator_dlight"]												= loadfx("maps/mp_maps/fx_mp_light_hotel_elevator_dlight");
	
	level._effect["fx_mp_light_hotel_spotlights"]							= loadfx("maps/mp_maps/fx_mp_light_hotel_spotlights");
	level._effect["fx_mp_light_recessed_elevator"]						= loadfx("maps/mp_maps/fx_mp_light_recessed_elevator");
	level._effect["fx_mp_light_elevator_num_glow"]							= loadfx("maps/mp_maps/fx_mp_light_elevator_num_glow");
	level._effect["fx_mp_light_elevator_num_glow_red"]						= loadfx("maps/mp_maps/fx_mp_light_elevator_num_glow_red");
}

spawnfx()
{

}

set_wind()
{ 
	// enable wind for your level
	SetDvar("enable_global_wind",1);
	SetDvar("wind_global_vector","-120 -115 -120");
	SetDvar("wind_global_low_altitude",0);
	SetDvar("wind_global_hi_altitude",2000);
	SetDvar("wind_global_low_strength_percent",.5);    
}

main()
{
	precache_fx_prop_anims();
	maps\mp\createfx\mp_hotel_fx::main();
	maps\mp\createart\mp_hotel_art::main();

	precache_createfx_fx();
	spawnfx();
	set_wind();
}