//_createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 
	//* Fog section * 

	//setdvar("scr_fog_exp_halfplane", "3759.28");
	//setdvar("scr_fog_exp_halfheight", "243.735");
	//setdvar("scr_fog_nearplane", "601.593");
	//setdvar("scr_fog_red", "0.806694");
	//setdvar("scr_fog_green", "0.962521");
	//setdvar("scr_fog_blue", "0.9624");
	//setdvar("scr_fog_baseheight", "-475.268");

	setdvar("visionstore_glowTweakEnable", "0");
	setdvar("visionstore_glowTweakRadius0", "5");
	setdvar("visionstore_glowTweakRadius1", "");
	setdvar("visionstore_glowTweakBloomCutoff", "0.5");
	setdvar("visionstore_glowTweakBloomDesaturation", "0");
	setdvar("visionstore_glowTweakBloomIntensity0", "1");
	setdvar("visionstore_glowTweakBloomIntensity1", "");
	setdvar("visionstore_glowTweakSkyBleedIntensity0", "");
	setdvar("visionstore_glowTweakSkyBleedIntensity1", "");
	setdvar("r_skyColorTemp", "6128");
	setdvar("r_dof_farBlur", "3");
	setdvar("r_dof_farStart", "1024");
	setdvar("r_dof_farEnd", "7500");
	
	start_dist = 926.432;
	half_dist = 4557.05;
	half_height = 1045.6;
	base_height = 786.52;
	fog_r = 0.394118;
	fog_g = 0.505882;
	fog_b = 0.415686;
	fog_scale = 1.04787;
	sun_col_r = 0.803922;
	sun_col_g = 0.956863;
	sun_col_b = 0.929412;
	sun_dir_x = -0.652496;
	sun_dir_y = 0.402488;
	sun_dir_z = 0.642069;
	sun_start_ang = 17.4307;
	sun_stop_ang = 35.6191;
	time = 0;
	max_fog_opacity = 1;


      setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
            sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
            sun_stop_ang, time, max_fog_opacity);






	VisionSetNaked( "mp_zoo", 0 );
	SetDvar( "r_lightGridEnableTweaks", 1 );
	SetDvar( "r_lightGridIntensity", 1.8 );
	SetDvar( "r_lightGridContrast", 0.12 );
}


