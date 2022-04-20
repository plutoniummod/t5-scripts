//_createart generated.  modify at your own risk. Changing values should be fine.

main()
{

	level.tweakfile = true;
 
	// *Fog section* 

	setdvar("scr_fog_exp_halfplane", "416");
	setdvar("scr_fog_exp_halfheight", "200");
	setdvar("scr_fog_nearplane", "167");
	setdvar("scr_fog_red", "0.5");
	setdvar("scr_fog_green", "0.5");
	setdvar("scr_fog_blue", "0.5");
	setdvar("scr_fog_baseheight", "124");

//	// *depth of field section* 
//	level.do_not_use_dof = true;
//	level.dofDefault["nearStart"] = 0;
//	level.dofDefault["nearEnd"] = 60;
//	level.dofDefault["farStart"] = 2000;
//	level.dofDefault["farEnd"] = 10000;
//	level.dofDefault["nearBlur"] = 6;
//	level.dofDefault["farBlur"] = 2;
//
//	players = maps\_utility::get_players();
//	for( i = 0; i < players.size; i++ )
//	{
//		players[i] maps\_art::setdefaultdepthoffield();
//	}
	
	setdvar("visionstore_glowTweakEnable", "1");
	setdvar("visionstore_glowTweakRadius0", "5");
	setdvar("visionstore_glowTweakRadius1", "5");
	setdvar("visionstore_glowTweakBloomCutoff", "0.5");
	setdvar("visionstore_glowTweakBloomDesaturation", "0");
	setdvar("visionstore_glowTweakBloomIntensity0", "2");
	setdvar("visionstore_glowTweakBloomIntensity1", "2");
	setdvar("visionstore_glowTweakSkyBleedIntensity0", "0.29");
	setdvar("visionstore_glowTweakSkyBleedIntensity1", "0.29");

	level thread fog_settings();
 
	//VisionSetNaked("cheat_bw", 0);
	
	VisionSetNaked( "zombie_asylum", 0 );
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.25 );
	SetSavedDvar( "r_lightGridContrast", .2 );
}

fog_settings()
{
	start_dist = 244.829;
	half_dist = 697.262;
	half_height = 200;
	base_height = 124;
	fog_r = 0.419608;
	fog_g = 0.321569;
	fog_b = 0.25098;
	fog_scale = 2;
	sun_col_r = 0.815686;
	sun_col_g = 0.466667;
	sun_col_b = 0.180392;
	sun_dir_x = 0.273329;
	sun_dir_y = -0.954149;
	sun_dir_z = 0.12203;
	sun_start_ang = 0;
	sun_stop_ang = 50.3866;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);



	println("Done Setting Fog");
}