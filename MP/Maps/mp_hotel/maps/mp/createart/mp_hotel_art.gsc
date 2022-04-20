//_createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 
 	//* Fog section * 

	setdvar("scr_fog_exp_halfplane", "3585.00");
	setdvar("scr_fog_exp_halfheight", "672.00");
	setdvar("scr_fog_nearplane", "1408");
	setdvar("scr_fog_red", ".843137");
	setdvar("scr_fog_green", "0.941177");
	setdvar("scr_fog_blue", "0.901961");
	setdvar("scr_fog_baseheight", "-1024");

	setdvar("visionstore_glowTweakEnable", "0");
	setdvar("visionstore_glowTweakRadius0", "5");
	setdvar("visionstore_glowTweakRadius1", "");
	setdvar("visionstore_glowTweakBloomCutoff", "0.5");
	setdvar("visionstore_glowTweakBloomDesaturation", "0");
	setdvar("visionstore_glowTweakBloomIntensity0", "1");
	setdvar("visionstore_glowTweakBloomIntensity1", "");
	setdvar("visionstore_glowTweakSkyBleedIntensity0", "");
	setdvar("visionstore_glowTweakSkyBleedIntensity1", "");

	start_dist = 276.582;
	half_dist = 799.232;
	half_height = 745.939;
	base_height = -1398.96;
	fog_r = 0.192157;
	fog_g = 0.235294;
	fog_b = 0.282353;
	fog_scale = 2.56661;
	sun_col_r = 0.94902;
	sun_col_g = 0.560784;
	sun_col_b = 0.356863;
	sun_dir_x = 0.245844;
	sun_dir_y = -0.919734;
	sun_dir_z = 0.306025;
	sun_start_ang = 31;
	sun_stop_ang = 96.2698;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);


                    

	VisionSetNaked( "mp_hotel", 0 );
	SetDvar( "r_lightGridEnableTweaks", 1 );
	SetDvar( "r_lightGridIntensity", 1.65 );
	SetDvar( "r_lightGridContrast", .45 );
}

