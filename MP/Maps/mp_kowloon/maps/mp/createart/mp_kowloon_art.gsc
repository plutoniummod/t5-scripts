//_createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 
	//* Fog section * 

  setdvar("Depth_bias", "3759.28");
	setdvar("scr_fog_exp_halfplane", "3759.28");
	setdvar("scr_fog_exp_halfheight", "243.735");
	setdvar("scr_fog_nearplane", "601.593");
	setdvar("scr_fog_red", "0.806694");
	setdvar("scr_fog_green", "0.962521");
	setdvar("scr_fog_blue", "0.9624");
	setdvar("scr_fog_baseheight", "-475.268");

	setdvar("visionstore_glowTweakEnable", "0");
	setdvar("visionstore_glowTweakRadius0", "5");
	setdvar("visionstore_glowTweakRadius1", "");
	setdvar("visionstore_glowTweakBloomCutoff", "0.5");
	setdvar("visionstore_glowTweakBloomDesaturation", "0");
	setdvar("visionstore_glowTweakBloomIntensity0", "1");
	setdvar("visionstore_glowTweakBloomIntensity1", "");
	setdvar("visionstore_glowTweakSkyBleedIntensity0", "");
	setdvar("visionstore_glowTweakSkyBleedIntensity1", "");

	start_dist = 19194;
	half_dist = 16009.3;
	half_height = 2354.8;
	base_height = 7980;
	fog_r = 0.203922;
	fog_g = 0.239216;
	fog_b = 0.25098;
	fog_scale = 3.68083;
	sun_col_r = 0.552941;
	sun_col_g = 0.686275;
	sun_col_b = 0.729412;
	sun_dir_x = 0.294217;
	sun_dir_y = -0.174397;
	sun_dir_z = 0.939693;
	sun_start_ang = 0;
	sun_stop_ang = 99.2932;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);



		
			VisionSetNaked( "mp_kowloon", 0 );
			SetDvar( "r_lightGridEnableTweaks", 1 );
			SetDvar( "r_lightGridIntensity", 1.83 );
			SetDvar( "r_lightGridContrast", 0.68 );
			
}


