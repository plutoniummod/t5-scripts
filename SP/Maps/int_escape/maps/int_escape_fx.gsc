#include maps\_utility; 
#include maps\_anim;
#using_animtree("fxanim_props");

main()
{
	initModelAnims();
	precache_scripted_fx();
	precache_createfx_fx();
	footsteps();
		
	maps\createfx\int_escape_fx::main();
	maps\createart\int_escape_art::main();
	
}


// FXanim Props
initModelAnims()
{
	level.scr_anim["fxanim_props"]["a_respirator"] = %fxanim_escape_respirator_anim;
	level.scr_anim["fxanim_props"]["a_streamer01"] = %fxanim_gp_streamer01_anim;
	level.scr_anim["fxanim_props"]["a_ceiling_sm"] = %fxanim_escape_ceiling_sm_anim;
	level.scr_anim["fxanim_props"]["a_ceiling_lrg"] = %fxanim_escape_ceiling_lrg_anim;
	level.scr_anim["fxanim_props"]["a_ceiling_cement"] = %fxanim_escape_ceiling_cement_anim;
	level.scr_anim["fxanim_props"]["a_ui_throw"] = %fxanim_escape_ui_throw_anim;
	level.scr_anim["fxanim_props"]["a_tv_wall"] = %fxanim_escape_wall_fall_anim;
	level.scr_anim["fxanim_props"]["a_tray"] = %fxanim_escape_tray_anim;
	level.scr_anim["fxanim_props"]["a_tray_curtains"] = %fxanim_escape_tray_curtains_anim;
	level.scr_anim["fxanim_props"]["a_brainwash_wires"] = %fxanim_escape_brainwash_wires_anim;
	level.scr_anim["fxanim_props"]["a_brainwash_chains"] = %fxanim_escape_brainwash_chains_anim;
	level.scr_anim["fxanim_props"]["a_wires_single"] = %fxanim_escape_int_room_wires_single_anim;
	level.scr_anim["fxanim_props"]["a_wires_multi"] = %fxanim_escape_int_room_wires_multi_anim;
	
	ent1 = GetEnt( "fxanim_escape_respirator_mod", "targetname" );
	ent2 = GetEnt( "ceiling_01_mod", "targetname" );
	ent3 = GetEnt( "ceiling_02_mod", "targetname" );
	ent4 = GetEnt( "ceiling_03_mod", "targetname" );
	ent5 = GetEnt( "ceiling_04_mod", "targetname" );
	ent6 = GetEnt( "ceiling_05_mod", "targetname" );
	ent7 = GetEnt( "cement_01_mod", "targetname" );
	ent8 = GetEnt( "cement_02_mod", "targetname" );
	ent9 = GetEnt( "cement_03_mod", "targetname" );
	ent10 = GetEnt( "cement_04_mod", "targetname" );
	ent11 = GetEnt( "fxanim_escape_ui_throw_mod", "targetname" );
	ent12 = GetEnt( "fxanim_escape_wall_fall_mod", "targetname" );
	ent13 = GetEnt( "fxanim_escape_tray_mod", "targetname" );
	ent14 = GetEnt( "brainwash_wires", "targetname" );
	ent15 = GetEnt( "brainwash_chain", "targetname" );
	ent16 = GetEnt( "wires_single", "targetname" );
	
	enta_streamer01 = GetEntArray( "streamer01", "targetname" );
	enta_wires_multi = GetEntArray( "wires_multi", "targetname" );
	
	
	if (IsDefined(ent1)) 
	{
		ent1 thread respirator();
		println("************* FX: respirator *************");
	}
	
	for(i=0; i<enta_streamer01.size; i++)
	{
 		enta_streamer01[i] thread streamer01(1,3);
 		println("************* FX: streamer01 *************");
	}
	
	if (IsDefined(ent2)) 
	{
		ent2 thread ceiling_01();
		println("************* FX: ceiling_01 *************");
	}
	
	if (IsDefined(ent3)) 
	{
		ent3 thread ceiling_02();
		println("************* FX: ceiling_02 *************");
	}
	
	if (IsDefined(ent4)) 
	{
		ent4 thread ceiling_03();
		println("************* FX: ceiling_03 *************");
	}
	
	if (IsDefined(ent5)) 
	{
		ent5 thread ceiling_04();
		println("************* FX: ceiling_04 *************");
	}
	
	if (IsDefined(ent6)) 
	{
		ent6 thread ceiling_05();
		println("************* FX: ceiling_05 *************");
	}
	
	if (IsDefined(ent7)) 
	{
		ent7 thread cement_01();
		println("************* FX: cement_01 *************");
	}
	
	if (IsDefined(ent8)) 
	{
		ent8 thread cement_02();
		println("************* FX: cement_02 *************");
	}
	
	if (IsDefined(ent9)) 
	{
		ent9 thread cement_03();
		println("************* FX: cement_03 *************");
	}
	
	if (IsDefined(ent10)) 
	{
		ent10 thread cement_04();
		println("************* FX: cement_04 *************");
	}
	
	if (IsDefined(ent11)) 
	{
		ent11 thread ui_throw();
		println("************* FX: ui_throw *************");
	}
	
	if (IsDefined(ent12)) 
	{
		ent12 thread tv_wall();
		println("************* FX: tv_wall *************");
	}
	
	if (IsDefined(ent13)) 
	{
		ent13 thread tray();
		println("************* FX: tray *************");
	}
	
	if (IsDefined(ent14)) 
	{
		ent14 thread brainwash_wires();
		println("************* FX: brainwash_wires *************");
	}
	
	if (IsDefined(ent15)) 
	{
		ent15 thread brainwash_chains();
		println("************* FX: brainwash_chains *************");
	}
	
	if (IsDefined(ent16)) 
	{
		ent16 thread wires_single();
		println("************* FX: wires_single *************");
	}
	
	for(i=0; i<enta_wires_multi.size; i++)
	{
 		enta_wires_multi[i] thread wires_multi(1,3);
 		println("************* FX: wires_multi *************");
	}
}

respirator()
{
	wait(1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_respirator", "fxanim_props");
}

streamer01(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_streamer01", "fxanim_props");
}

ceiling_01()
{
	level waittill("escape_ceiling_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_sm", "fxanim_props");
	self delete();
}

ceiling_02()
{
	level waittill("escape_ceiling_start");
	wait(1.5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_lrg", "fxanim_props");
	self delete();
}

ceiling_03()
{
	level waittill("escape_ceiling_start");
	wait(3.5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_lrg", "fxanim_props");
	self delete();
}

ceiling_04()
{
	level waittill("escape_ceiling_start");
	wait(5.5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_sm", "fxanim_props");
	self delete();
}

ceiling_05()
{
	level waittill("escape_ceiling_start");
	wait(7);
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_lrg", "fxanim_props");
	self delete();
}

cement_01()
{
	level waittill("escape_ceiling_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_cement", "fxanim_props");
	self delete();
}

cement_02()
{
	level waittill("escape_ceiling_start");
	wait(1.5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_cement", "fxanim_props");
	self delete();
}

cement_03()
{
	level waittill("escape_ceiling_start");
	wait(3.5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_cement", "fxanim_props");
	self delete();
}

cement_04()
{
	level waittill("escape_ceiling_start");
	wait(5.5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_cement", "fxanim_props");
	self delete();
}

cement_05()
{
	level waittill("escape_ceiling_start");
	wait(7);
	self UseAnimTree(#animtree);
	anim_single(self, "a_ceiling_cement", "fxanim_props");
	self delete();
}

ui_throw()
{
	level waittill("ui_throw_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_ui_throw", "fxanim_props");
}

tv_wall()
{
	level waittill("tv_wall_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_tv_wall", "fxanim_props");
}

tray()
{
	wait(1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_tray_curtains", "fxanim_props");
	level waittill("tray_start");
	anim_single(self, "a_tray", "fxanim_props");
}

brainwash_wires()
{
	wait(.1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_brainwash_wires", "fxanim_props");
}

brainwash_chains()
{
	wait(.1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_brainwash_chains", "fxanim_props");
}

wires_single()
{
	wait(1);
	self UseAnimTree(#animtree);
	anim_single(self, "a_wires_single", "fxanim_props");
}

wires_multi(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_wires_multi", "fxanim_props");
}



// Scripted effects
precache_scripted_fx() 
{
	level._effect["rocket_blast"]	= LoadFX("maps/flashpoint/fx_russian_rocket_exhaust");
	level._effect["rocket_smoke"]	= LoadFX("maps/flashpoint/fx_rocket_launch_trench_smoke");
	level._effect["rocket_trail"]	= LoadFX("maps/interrogation_escape/fx_interrog_rocket_exhaust");
	level._effect["rocket_launch_base_dist"]	= LoadFX("maps/flashpoint/fx_rocket_launch_dist_smoke");
	level._effect["rocket_lift_glow"] = LoadFX("maps/flashpoint/fx_clouds_rocket_cover_lift");

	//level._effect["floating_number"]  = LoadFX("maps/interrogation_escape/fx_misc_nix_num_lg_move");
	//level._effect["floating_number_notlit"]  = LoadFX("maps/interrogation_escape/fx_misc_nix_num_lg_move_notlit");
	level._effect["floating_number"]  = LoadFX("maps/interrogation_escape/fx_misc_nix_num_lg_move_notlit");
	level._effect["steiner_numbers"]  = LoadFX("maps/interrogation_escape/fx_misc_nix_num_steiner");
	

	level._effect["floating_number_fade"]  = LoadFX("maps/interrogation_escape/fx_misc_nix_num_lg_move_fade");
		
	level._effect["camera_light"]						= LoadFX("props/fx_lights_int_security_camera");
	level._effect["p_pent_control_console"]	= LoadFX("props/fx_lights_pent_control_console"); //– (prop) p_pent_control_console
	level._effect["p_pent_telephone_board"]	= LoadFX("props/fx_lights_pent_telephone_board"); //– (prop) p_pent_telephone_board
	level._effect["p_rus_data_computer"]		= LoadFX("props/fx_lights_rus_data_computer");			//– (prop) p_rus_data_computer
	level._effect["p_rus_electricmeter"]			= LoadFX("props/fx_lights_rus_electricmeter");				//– (prop) p_rus_eletricmeter
	level._effect["p_rus_panel_pent_04"]				= LoadFX("props/fx_lights_rus_panel_pent_04");					//– (prop)  p_rus_panel_pent

	level._effect["test_spin_fx"] = LoadFX( "env/light/fx_light_warning");
}


// Ambient effects
precache_createfx_fx()
{
	level._effect["fx_nix_tunnel_ramp_up"]				 = loadfx("maps/interrogation_escape/fx_misc_nix_tunnel_ramp_up"); // 4001
	level._effect["fx_nix_ship_numbers"]					 = loadfx("maps/interrogation_escape/fx_misc_nix_ship_numbers"); // 903
	
	level._effect["fx_interrog_ship_num_explo1"]	  = loadfx("maps/interrogation_escape/fx_interrog_ship_num_explo1");
	level._effect["fx_interrog_ship_num_explo2"]	  = loadfx("maps/interrogation_escape/fx_interrog_ship_num_explo2");	
	
	level._effect["fx_nix_numbers"]							     = loadfx("misc/fx_misc_nix_numbers");
	level._effect["fx_nix_numbers_mover"]				     = loadfx("misc/fx_misc_nix_numbers_mover");
	level._effect["fx_nix_numbers_pc"]						   = loadfx("misc/fx_misc_nix_numbers_pc");
	level._effect["fx_misc_nix_num_ceiling_pc"]		   = loadfx("misc/fx_misc_nix_numbers_cl_pc");
	level._effect["fx_nix_numbers_rotate"]				   = loadfx("misc/fx_misc_nix_numbers_rotate");
  level._effect["fx_nix_numbers_sphere"]				   = loadfx("misc/fx_misc_nix_numbers_sphere");
  level._effect["fx_nix_numbers_wall"]				     = loadfx("misc/fx_misc_nix_numbers_wall");
  
	level._effect["fx_fog_low"]								= loadfx("env/smoke/fx_fog_low");
	level._effect["fx_fog_low_sm"]						= loadfx("env/smoke/fx_fog_low_sm");
	level._effect["fx_cig_smoke"]							= loadfx("env/smoke/fx_cig_smoke_front_end");
	level._effect["fx_fog_low_hall_500"]			= loadfx("env/smoke/fx_fog_low_hall_500");
	level._effect["fx_dust_motes_lg"]					= loadfx("maps/frontend/fx_frontend_dust_motes_lg");
	level._effect["fx_dust_motes_sm"]					= loadfx("maps/frontend/fx_frontend_dust_motes_sm");
	level._effect["fx_light_ceiling"]					= loadfx("maps/frontend/fx_light_ceiling");	
	level._effect["fx_light_chair_flood"]			= loadfx("maps/frontend/fx_light_chair_flood");	
	
	level._effect["fx_water_faucet_drip_fast"]		  = loadfx("env/water/fx_water_faucet_drip_fast");
	level._effect["fx_interrog_morgue_mist"]	      = loadfx("maps/interrogation_escape/fx_interrog_morgue_mist");	
	level._effect["fx_interrog_blink_red_light"]	  = loadfx("maps/interrogation_escape/fx_interrog_blink_red_light");
	level._effect["fx_interrog_god_ray_xlg"]	      = loadfx("maps/interrogation_escape/fx_interrog_god_ray_xlg");	
	level._effect["fx_interrog_little_bubbles"]	    = loadfx("maps/interrogation_escape/fx_interrog_little_bubbles");		
	level._effect["fx_interrog_cart_cig_smk"]	      = loadfx("maps/interrogation_escape/fx_interrog_cart_cig_smk");		
	level._effect["fx_interrog_battery_spark"]	    = loadfx("maps/interrogation_escape/fx_interrog_battery_spark");			
	level._effect["fx_interrog_movie_projector"]	  = loadfx("maps/interrogation_escape/fx_interrog_movie_projector");					
	level._effect["fx_interrog_studio_light"]	      = loadfx("maps/interrogation_escape/fx_interrog_studio_light");
	level._effect["fx_interrog_light_beam"]	        = loadfx("maps/interrogation_escape/fx_interrog_light_beam");	
	level._effect["fx_interrog_light_sm"]	          = loadfx("maps/interrogation_escape/fx_interrog_light_sm");		
	level._effect["fx_interrog_tv_glow"]	          = loadfx("maps/interrogation_escape/fx_interrog_tv_glow");
	level._effect["fx_interrog_rocket_smk"]	        = loadfx("maps/interrogation_escape/fx_interrog_rocket_smk");	
	level._effect["fx_interrog_rocket_coolant"]	    = loadfx("maps/interrogation_escape/fx_interrog_rocket_coolant");			
	level._effect["fx_interrog_steam_cup"]	        = loadfx("maps/interrogation_escape/fx_interrog_steam_cup");	
	level._effect["fx_interrog_drips"]	            = loadfx("maps/interrogation_escape/fx_interrog_drips");
	level._effect["fx_interrog_win_numbers"]	      = loadfx("maps/interrogation_escape/fx_interrog_win_numbers");	
	
	level._effect["fx_interrog_ship_num_lg"]	      = loadfx("maps/interrogation_escape/fx_interrog_ship_num_lg");
	level._effect["fx_interrog_ship_num_sm"]	      = loadfx("maps/interrogation_escape/fx_interrog_ship_num_sm");	
			
	level._effect["fx_interrog_ceiling_dust"]	      = loadfx("maps/interrogation_escape/fx_interrog_ceiling_dust");
	level._effect["fx_interrog_ceiling_dest"]	      = loadfx("maps/interrogation_escape/fx_interrog_ceiling_dest");				
	
	level._effect["fx_interrog_dest_tv"]	          = loadfx("maps/interrogation_escape/fx_interrog_dest_tv");		
	level._effect["fx_interrog_dest_tv_sparks"]	    = loadfx("maps/interrogation_escape/fx_interrog_dest_tv_sparks");										
		
	level._effect["fx_axis_marker"]						= loadfx("fx_tools/fx_Tools_axis_sm");
}

footsteps()
{
	animscripts\utility::setFootstepEffect( "asphalt", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "brick", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "carpet", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "cloth", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "concrete", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "dirt", LoadFx( "bio/player/fx_footstep_sand" ) );
	animscripts\utility::setFootstepEffect( "foliage", LoadFx( "bio/player/fx_footstep_sand" ) );
	animscripts\utility::setFootstepEffect( "gravel", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "grass", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "metal", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "mud", LoadFx( "bio/player/fx_footstep_mud" ) );
	animscripts\utility::setFootstepEffect( "paper", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "plaster", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "rock", LoadFx( "bio/player/fx_footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "water", LoadFx( "bio/player/fx_footstep_water" ) );
	animscripts\utility::setFootstepEffect( "wood", LoadFx( "bio/player/fx_footstep_dust" ) );
}



