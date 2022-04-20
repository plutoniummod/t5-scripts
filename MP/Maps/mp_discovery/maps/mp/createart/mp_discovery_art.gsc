//_createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 
	//* Fog section * 

	setdvar("scr_fog_exp_halfplane", "3200.000");
	setdvar("scr_fog_exp_halfheight", "611.300");
	setdvar("scr_fog_nearplane", "601.593");
	setdvar("scr_fog_red", "0.806694");
	setdvar("scr_fog_green", "0.962521");
	setdvar("scr_fog_blue", "0.9624");
	setdvar("scr_fog_baseheight", "81.000");

	setdvar("visionstore_glowTweakEnable", "0");
	setdvar("visionstore_glowTweakRadius0", "5");
	setdvar("visionstore_glowTweakRadius1", "");
	setdvar("visionstore_glowTweakBloomCutoff", "0.5");
	setdvar("visionstore_glowTweakBloomDesaturation", "0");
	setdvar("visionstore_glowTweakBloomIntensity0", "1");
	setdvar("visionstore_glowTweakBloomIntensity1", "");
	setdvar("visionstore_glowTweakSkyBleedIntensity0", "");
	setdvar("visionstore_glowTweakSkyBleedIntensity1", "");

	start_dist = 95.3957;
	half_dist = 546.464;
	half_height = 234.197;
	base_height = -157.155;
	fog_r = 0.819608;
	fog_g = 0.870588;
	fog_b = 1;
	fog_scale = 1.54332;
	sun_col_r = 0.407843;
	sun_col_g = 0.905882;
	sun_col_b = 0.329412;
	sun_dir_x = 0.130479;
	sun_dir_y = -0.959258;
	sun_dir_z = 0.250599;
	sun_start_ang = 20.132;
	sun_stop_ang = 43.9528;
	time = 0;
	max_fog_opacity = 1;

	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);

	
	VisionSetNaked( "mp_discovery", 0 );
	SetDvar( "r_lightGridEnableTweaks", 1 );
	SetDvar( "r_lightGridIntensity", 1.71 );
	SetDvar( "r_lightGridContrast", 0.15 );
}
