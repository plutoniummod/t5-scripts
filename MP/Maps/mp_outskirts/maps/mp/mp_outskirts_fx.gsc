#include maps\mp\_utility;

// Ambient effects
precache_fx()
{		

	level._effect["fx_mp_light_dust_motes_md"]							= loadfx("maps/mp_maps/fx_mp_light_dust_motes_md");

	level._effect["fx_mp_smk_building_chimney_blk"]					= loadfx("maps/mp_maps/fx_mp_smk_building_chimney_blk");
	level._effect["fx_smk_plume_md_wht_wispy"]							= loadfx("maps/mp_maps/fx_mp_smk_plume_md_wht_wispy");
	level._effect["fx_smk_plume_md_wht_wispy_sm"]						= loadfx("maps/mp_maps/fx_mp_smk_plume_md_wht_wispy_sm");
	level._effect["fx_smk_linger_lit"]											= loadfx("maps/mp_maps/fx_mp_smk_linger_light");
//	level._effect["fx_mp_outskirts_smk_vent"]				        =	loadfx("maps/mp_maps/fx_mp_outskirts_smk_vent");
	level._effect["fx_pipe_steam_md"]					            	=	loadfx("env/smoke/fx_pipe_steam_md");
//	level._effect["fx_mp_outskirts_fumes_haze"]     				=	loadfx("maps/mp_maps/fx_mp_outskirts_fumes_haze");
	level._effect["fx_fumes_vent_xsm_int"]									= loadfx("maps/mp_maps/fx_mp_fumes_vent_xsm_int");
	level._effect["fx_fumes_vent_sm_int"]										= loadfx("maps/mp_maps/fx_mp_fumes_vent_sm_int");

	level._effect["fx_water_drip_light_long"]								= loadfx("maps/mp_maps/fx_mp_water_drip_xlight_long");	
	level._effect["fx_water_drip_light_short"]							= loadfx("maps/mp_maps/fx_mp_water_drip_xlight_short");	
	level._effect["fx_mp_oil_drip_short"]										= loadfx("maps/mp_maps/fx_mp_oil_drip_sngl");	
	
	level._effect["fx_mp_snow_gust_street"]						  		= loadfx("maps/mp_maps/fx_mp_snow_gust_street_fast");	
  level._effect["fx_mp_snow_gust_street_sml"]							= loadfx("maps/mp_maps/fx_mp_snow_gust_street_fast_sm");
//  level._effect["fx_mp_berlin_snow_gust_door"]						= loadfx("maps/mp_maps/fx_mp_berlin_snow_gust_door");
  level._effect["fx_mp_snow_gust_rooftop_slow"]						= loadfx("maps/mp_maps/fx_mp_snow_gust_rooftop_slow");
  level._effect["fx_mp_snow_gust_rooftop_oo_slow"]				= loadfx("maps/mp_maps/fx_mp_snow_gust_rooftop_oo_slow");
//  level._effect["fx_mp_snow_gust_rooftop_oo_slow_thin"]		= loadfx("maps/mp_maps/fx_mp_snow_gust_rooftop_oo_slow_thin");
  level._effect["fx_mp_snow_gust_rooftop_xsm_slow"]				= loadfx("maps/mp_maps/fx_mp_snow_gust_rooftop_xsm_slow"); 
  level._effect["fx_mp_snow_gust_rooftop_lg_slow_distant"]= loadfx("maps/mp_maps/fx_mp_snow_gust_rooftop_lg_slow_distant");  

	level._effect["fx_mp_leaves_falling"]						        =	loadfx("maps/mp_maps/fx_mp_leaves_falling");
	level._effect["fx_debris_papers"]						            =	loadfx("env/debris/fx_debris_papers");
	level._effect["fx_debris_papers_narrow"]						    =	loadfx("env/debris/fx_debris_papers_narrow");
	
//	level._effect["fx_mp_rvn_leaves_falling"]			        	=	loadfx("maps/mp_maps/fx_mp_rvn_leaves_falling");
//	level._effect["fx_mp_outskirts_leaves_blowing"]		    	=	loadfx("maps/mp_maps/fx_mp_outskirts_leaves_blowing");

	level._effect["fx_mp_elec_spark_burst_sm"]				      =	loadfx("maps/mp_maps/fx_mp_elec_spark_burst_sm");

//	level._effect["fx_mp_outskirts_fog"]					          =	loadfx("maps/mp_maps/fx_mp_outskirts_fog");
//	level._effect["fx_mp_outskirts_interior_fog"]		      	=	loadfx("maps/mp_maps/fx_mp_outskirts_interior_fog");
	level._effect["fx_mp_berlin_fog_int"]			          		= loadfx("maps/mp_maps/fx_mp_berlin_fog_int");

	level._effect["fx_mp_dlc3_outskirts_tinhat"]		      	=	loadfx("maps/mp_maps/fx_mp_outskirts_spotlight_glow_1");
//	level._effect["fx_mp_dlc3_outskirts_tinhat_indoor"]		  =	loadfx("maps/mp_maps/fx_mp_dlc3_outskirts_tinhat_indoor");
	level._effect["fx_mp_outskirts_floures_glow1"]		    	=	loadfx("maps/mp_maps/fx_mp_outskirts_floures_glow_1");	
	level._effect["fx_mp_outskirts_floures_glow2"]		    	=	loadfx("maps/mp_maps/fx_mp_outskirts_floures_glow_2");	

	level._effect["fx_mp_outskirts_godray_md"]		        	=	loadfx("maps/mp_maps/fx_mp_outskirts_gray_md");	
	level._effect["fx_mp_outskirts_godray_md_long"]		    	=	loadfx("maps/mp_maps/fx_mp_outskirts_gray_md_long");	
//	level._effect["fx_mp_outskirts_godray_md_long_wide"]		=	loadfx("maps/mp_maps/fx_mp_outskirts_gray_md_long_wide");
	level._effect["fx_mp_outskirts_gray_md_long_distant"]		=	loadfx("maps/mp_maps/fx_mp_outskirts_gray_md_long_distant");	
	level._effect["fx_mp_outskirts_godray_md_short"]		   	=	loadfx("maps/mp_maps/fx_mp_outskirts_gray_md_short");
	level._effect["fx_mp_light_ray_wht_ribbon_sm"]		   		=	loadfx("maps/mp_maps/fx_mp_light_ray_wht_ribbon_sm");	

	level._effect["fx_mp_outskirts_heatlamp_distortion"]	 	=	loadfx("maps/mp_maps/fx_mp_distortion_heat_lamp");	
	
	// Door FX
	level._effect["fx_mp_outskirts_door_light_red"]	 				=	loadfx("maps/mp_maps/fx_mp_outskirts_door_light_red");
	level._effect["fx_mp_outskirts_door_light_green"]	 			=	loadfx("maps/mp_maps/fx_mp_outskirts_door_light_green");	
	level._effect["fx_mp_outskirts_door_snow_impact"]	 			=	loadfx("maps/mp_maps/fx_mp_outskirts_door_snow_impact");		

}

// fx prop anim effects
#using_animtree ( "fxanim_props_dlc3" );
precache_fx_prop_anims()
{
	level.outskirts_fxanims = [];
	level.outskirts_fxanims[ "fxanim_mp_oildigger" ] = %fxanim_mp_oildigger_anim;
	level.outskirts_fxanims[ "fxanim_mp_roofvent" ] = %fxanim_mp_roofvent_snow_anim;
	level.outskirts_fxanims[ "fxanim_mp_os_pully_anim" ] = %fxanim_mp_os_pully_anim;
	level.outskirts_fxanims[ "fxanim_mp_os_contrl_wire_anim" ] = %fxanim_mp_os_contrl_wire_anim;
	level.outskirts_fxanims[ "fxanim_mp_os_light_hang" ] = %fxanim_mp_os_light_hang_anim;
	level.outskirts_fxanims[ "fxanim_mp_os_sign_red_anim" ] = %fxanim_mp_os_sign_red_anim;
	level.outskirts_fxanims[ "fxanim_mp_os_sign_yellow_anim" ] = %fxanim_mp_os_sign_yellow_anim;
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

//Ratman
/*
	// Get model name, assign to rat01
	init_fxanims()
	{
		rat01 = GetEnt("robotrat","targetname");
		if (IsDefined(rat01)) 
		{
			rat01 thread rat_01_anim();
		}
	}
	
	#using_animtree("fxanim_props");
	rat_01_anim()
	{
		
		level.scr_anim["fxanim_props"]["a_rat_01"] = %fxanim_pow_rat_01_anim;
		wait 20;
		//script_flag_set value is on a trigger somewhere in the world
		//flag_wait("first_rat");
		self PlaySound( "amb_anml_rat_squeak_1" );
		self UseAnimTree(#animtree);
		//anim_single(self, "a_rat_01", "fxanim_props");
		self setanimstate( "a_rat_01" );
	}
*/
main()
{
	maps\mp\createfx\mp_outskirts_fx::main();
	precache_fx();
	precache_fx_prop_anims();
	maps\mp\createart\mp_outskirts_art::main();
	set_wind();
	// Rat anim
	//thread init_fxanims();
}
