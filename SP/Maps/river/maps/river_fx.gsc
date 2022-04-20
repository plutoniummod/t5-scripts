#include maps\_utility; 
#include common_scripts\utility;
#include maps\_anim;
#using_animtree("fxanim_props");


//*****************************************************************************
// 
//*****************************************************************************

main()
{
		initModelAnims();
//	precache_util_fx();
//	precache_createfx_fx();
//	precache_scripted_fx();

	//[ceng] (from pow_fx.gsc): "calls the createfx server script (i.e., the list of ambient effects and their attributes)"	
	maps\createfx\river_fx::main();
//	maps\createart\river_art::main();	
	
	
//	level._effect["truck_headlight"] = loadfx( "maps/river/fx_river_headlight_truck" );
	level._effect["truck_headlight"]   = loadfx( "maps/river/fx_river_headlight_huey" );	
	level._effect["tree_sniper_glint"] = loadfx( "maps/river/fx_river_sniper_scope_glint" );
	level._effect["guard_tower_death"] = LoadFX("maps/river/fx_river_tower_collapse_plume");

//	level._effect["chinook_smoke"] = LoadFX("env/smoke/fx_smk_column_lg_blk");
	level._effect["water_mortar"] = LoadFX("maps/river/fx_river_splash_mortar");
	level._effect["water_mortar_small"] = LoadFX("explosions/fx_grenadeexp_water");
	level._effect["friendly_boat_death"] = LoadFX("maps/river/fx_river_vehicle_explo");	
	level._effect["friendly_boat_death_alcove"] = LoadFX( "maps/river/fx_river_vehicle_explo" );	
	level._effect["sampan_gun_death"] = LoadFX("vehicle/vexplosion/fx_vexp_sampan_machinegun_river");
	level._effect["sampan_explosive_death"] = LoadFX("vehicle/vexplosion/fx_vexp_sampan_sinking_river");
	level._effect["bow_effect_on_sampan_death"] = LoadFX( "vehicle/water/fx_pbr_sampan_wood_break_river" );
	level._effect["sampan_death"] = LoadFX( "vehicle/vexplosion/fx_vexp_sampan_river" );
	level._effect[ "temp_destructible_building_smoke_black" ] = LoadFX( "env/smoke/fx_smk_fire_lg_black" );
	level._effect[ "temp_destructible_building_smoke_white" ] = LoadFX( "env/smoke/fx_smk_fire_lg_white" );
	level._effect[ "temp_destructible_building_embers" ] = LoadFX( "env/fire/fx_embers_up_dist" );
	level._effect[ "temp_destructible_building_fire_large" ] = LoadFX( "maps/river/fx_river_fire_lg" );
	level._effect[ "temp_destructible_building_fire_medium" ] = LoadFX( "maps/river/fx_river_fire_md" );
	level._effect[ "woodbridge_splash" ] = LoadFX( "destructibles/fx_river_woodbridge_splash" );
  level._effect[ "woodbridge_explosion" ] = LoadFX( "maps/river/fx_river_woodbridge_explo" );
	level._effect[ "quad50_temp_death_effect" ] = LoadFX( "maps/river/fx_river_vehicle_explo" );
	level._effect[ "heli_death" ] = LoadFX( "maps/river/fx_river_vehicle_explo" );

	level._effect["smoketrail"] = loadfx("weapon/rocket/fx_LCI_rocket_geotrail");
	level._effect["airstrike_hit"] = loadfx("explosions/fx_mortarexp_dirt");
	level._effect["water_rpg_hit"] = Loadfx("maps/river/fx_river_splash_mortar");
	level._effect["artillery_muzzle"] = Loadfx("weapon/muzzleflashes/fx_artillery_flash");
	level._effect["water_large_hit"] = Loadfx("maps/river/fx_river_splash_explo");

	level._effect[ "tree_sniper_hide" ] = LoadFX( "maps/river/fx_river_palm_frond" );
	level._effect[ "tree_sniper_reveal" ] = LoadFX( "maps/river/fx_river_palm_frond_reveal" );
//	
//	level._effect["flare_trail"]	= LoadFX("misc/fx_cuba_flare");
//	level._effect["flare_burst"]	= LoadFX("misc/fx_cuba_flare_burst");
	
	level._effect["flare_trail"]	= LoadFX("maps/river/fx_river_flare_red_sky");
	level._effect["flare_burst"]	= LoadFX("maps/river/fx_river_flare_red_sky_burst");	
	
// Ambient effects
//	level._effect["fx_fire_sm"]                          = LoadFX("env/fire/fx_fire_sm");
	level._effect["fx_fire_sm"]                          = LoadFX("maps/river/fx_river_campfire_sm");	
	level._effect["fx_river_woodbridge_explo"]           = LoadFX("maps/river/fx_river_woodbridge_explo");
	level._effect["fx_river_woodbridge_splash"]          = LoadFX("maps/river/fx_river_woodbridge_splash");		
//	level._effect["fx_cloud_layer"]                      = loadfx("maps/in_country/fx_cloud_layer_treetop_invert");	
	level._effect["fx_cloud_layer_glow"]                 = loadfx("maps/in_country/fx_cloud_layer_fire_close");		
	level._effect["fx_water_river_wash_mild"]		     	= loadfx("maps/in_country/fx_water_wash_mild");		
	level._effect["fx_water_splash_waterfall"]		   	= loadfx("maps/in_country/fx_water_splash_waterfall_loop");		
	level._effect["fx_ambient_fog_lg"]					      = loadfx("maps/in_country/fx_ambient_fog_lg");
	level._effect["fx_ambient_fog_lg_2"]					      = loadfx("maps/in_country/fx_ambient_fog_lg");	

	level._effect["fx_bats_circling"]						 	   	= loadfx("maps/in_country/fx_bats_circling");	
//	level._effect["fx_birds_circling"]						 	  = loadfx("maps/in_country/fx_birds_circling");	
//	level._effect["fx_insects_ambient"]								= loadfx("maps/creek/fx_insect_swarm");	
	level._effect["fx_insects_dragonflies_ambient"]		= loadfx("bio/insects/fx_insects_dragonflies_ambient");

	level._effect["fx_river_fire_embers_distant"]     = LoadfX("maps/river/fx_river_fire_embers_distant");	
	level._effect["fx_river_fire_outdoor_line_sm"]    = LoadfX("maps/river/fx_river_fire_outdoor_line_sm");		
	level._effect["fx_river_fire_lg"]                 = LoadfX("maps/river/fx_river_fire_outdoor_md");		
	level._effect["fx_river_fire_outdoor_sm"]         = LoadfX("maps/river/fx_river_fire_outdoor_sm");	
	level._effect["fx_river_campfire_sm"]             = LoadfX("maps/river/fx_river_campfire_sm");	
	level._effect["fx_river_smoke_fire_distant"]      = LoadfX("maps/river/fx_river_smoke_fire_distant");
	level._effect["fx_river_smoke_fire_distant_sm"]   = LoadfX("maps/river/fx_river_smoke_fire_distant_sm");	
	level._effect["fx_river_smoke_fire_distant_xsm"]  = LoadfX("maps/river/fx_river_smoke_fire_distant_xsm");		
	level._effect["fx_river_water_wash_med"]          = LoadfX("maps/river/fx_river_water_wash_med");	
	level._effect["fx_river_water_wash_lg"]           = LoadfX("maps/river/fx_river_water_wash_lg");		
	level._effect["fx_river_sparks_small_loop"]       = LoadfX("maps/river/fx_river_sparks_small_loop");	
	level._effect["fx_river_fireflies"]               = LoadfX("maps/river/fx_river_insects_fireflies_ambient");	
  level._effect["fx_dlight_red"]                  	  = LoadfX("maps/river/fx_river_dlight_red");		
  level._effect["fx_flare_sky_red"]                 = LoadfX("maps/river/fx_river_flare_red");	
  level._effect["fx_waterfall_xsm"]                 = LoadfX("maps/river/fx_river_waterfall_xsm");	  
  level._effect["fx_waterfall_med"]                 = LoadfX("maps/river/fx_river_waterfall_med");	 
  level._effect["fx_waterfall_sm"]                  = LoadfX("maps/river/fx_river_waterfall_sm");	 
  level._effect["fx_godrays_lg"]                    = LoadfX("maps/river/fx_river_godrays_lg");	
  level._effect["fx_godrays_xlg"]                    = LoadfX("maps/river/fx_river_godrays_xlg");	  
  level._effect["fx_godrays_sm"]                    = LoadfX("maps/river/fx_river_godrays_sm");	
  level._effect["fx_godrays_xsm"]                   = LoadfX("maps/river/fx_river_godrays_xsm");	  
  level._effect["fx_dust_falling"]                  = LoadfX("maps/river/fx_river_dust_falling");	 
  level._effect["fx_dust_kickup"]                   = LoadfX("maps/river/fx_river_dust_kickup");	
  level._effect["fx_fog_mountain"]                  = LoadfX("maps/river/fx_river_fog_mountain");	  
	level._effect["fx_boat_drop_splash"]              = LoadFX("vehicle/water/fx_wake_pbr_boat_drop_splash");   
  level._effect["fx_glow_lamp"]                     = LoadfX("maps/river/fx_river_glow_lamp");
  
 	level._effect["fx_river_fire_line_sm_nosmk"]      = LoadfX("maps/river/fx_river_fire_line_sm_nosmk");
 	level._effect["fx_river_fire_sm_nosmk"]           = LoadfX("maps/river/fx_river_fire_sm_nosmk");	
 	level._effect["fx_river_fire_lg_nosmk"]           = LoadfX("maps/river/fx_river_fire_lg_nosmk"); 	 	 	                	  
	
	// Player boat damage states
	level._effect["player_pbr_damage_1"]			= LoadfX("maps/river/fx_river_pbr_damage_state1");
	level._effect["player_pbr_damage_2"]			= LoadfX("maps/river/fx_river_pbr_damage_state2");
	level._effect["player_pbr_damage_3"]			= LoadfX("maps/river/fx_river_pbr_damage_state3");
	level._effect["player_pbr_damage_4"]			= LoadfX("maps/river/fx_river_pbr_damage_state4");
	
	
	// Vehicle Explosion
	level._effect["vehicle_explosion"] 			= Loadfx("maps/river/fx_river_vehicle_explo");
	
	LoadFX("vehicle/water/fx_wake_nvaboat_churn_river");
	LoadFX("vehicle/props/fx_hind_main_blade_full");
	LoadFX("vehicle/props/fx_hind_small_blade_full");
	LoadFX("vehicle/props/fx_hind_main_blade_static");
	LoadFX("vehicle/props/fx_hind_small_blade_stop");
	LoadFX("vehicle/props/fx_hind_main_blade_start");
	
	// Fx for the Huey Helicopter, could also try "fx_hind_main_blade_full"
	level._effect["chinook_blade"] 				= loadfx("vehicle/props/fx_seaknight_main_blade_full");
	level._effect["boat_drop_splash"]               = LoadFX("vehicle/water/fx_wake_pbr_boat_drop_splash");            
	
	level._effect[ "camera_flash" ] 			= LoadFX( "maps/wmd/fx_wmd_camera_flash" );
	
	// Fog	
	level thread fog_setup();
	
	// boat drag
	level thread boat_drag_fx_setup();
}

boat_drag_fx_setup()
{
	// attach to chinook models
	level._effect["chinook_blade"] 		  	= LoadFx("vehicle/props/fx_seaknight_main_blade_full");
	
	// spotlight on chinook
	level._effect["chinook_spotlight"] 			= LoadFx("maps/river/fx_river_headlight_huey");
	level._effect["tower_spotlight"] 			= LoadFx("maps/river/fx_river_headlight_huey");	
	level._effect["huey_spotlight"] 			= LoadFx("maps/river/fx_river_headlight_huey");
	level._effect["huey_blinking"]  			= LoadFx("maps/river/fx_river_lights_huey");
	level._effect[ "sampan_light" ]				= LoadFX( "maps/river/fx_river_headlight_huey" );
	level._effect[ "Hind_spotlight" ]			= LoadFx("maps/river/fx_river_headlight_huey");
	
	// rocket attack
	//level._effect["little_rockets"]			  = LoadFX("maps/river/fx_river_little_rockets");
	level._effect["chopper_explosion"]	  = LoadFX("maps/river/fx_river_vehicle_explo");
	//level._effect["chopper_smoke"]			  = LoadFX("maps/river/fx_river_chinook_smoke");
	//level._effect["heli_trail_sparks"]	  = LoadFX("maps/creek/fx_smk_heli_trail_sparks");

	// guy falling down
	//level._effect["guy_falling_blood"]	= LoadFX("maps/creek/fx_pbr_guy_falling_blood");
	
	// water splash
	//level._effect["wake_splash"]				= LoadFX("vehicle/water/fx_wake_pbr_boat_drop_splash");
	
	// smash into things
	//level._effect["pbr_impact_left"]		= LoadFX("maps/creek/fx_pbr_impact_left");
	//level._effect["pbr_impact_right"]		= LoadFX("maps/creek/fx_pbr_impact_right");
}



//*****************************************************************************
// NOTE: To setup a tree do the following:-
//			- Set TARGETNAME to fxanim_tree
//			- Set SCRIPT_NOTEWORTHY to the anim name to play when the tree falls
//			- Optional SCRIPT_STRING to force the name of the animation played on the tree
//			- Optional SCRIPT_INT used to delete trees in groups using function ::fx_treedelete()
//*****************************************************************************


// FXanim Props 
initModelAnims()
{	
	level.scr_anim["fxanim_props"]["a_tree_01_a"] = %fxanim_gp_tree_aquilaria_dest01_anim;
	level.scr_anim["fxanim_props"]["a_tree_01_b"] = %fxanim_gp_tree_aquilaria_dest02_anim;
	level.scr_anim["fxanim_props"]["a_tree_02_a"] = %fxanim_gp_tree_palm_coco02_dest01_anim;
	level.scr_anim["fxanim_props"]["a_tree_02_b"] = %fxanim_gp_tree_palm_coco02_dest02_anim;
	level.scr_anim["fxanim_props"]["a_woodbridge"] = %fxanim_river_woodbridge_anim;
	level.scr_anim["fxanim_props"]["a_tent01"] = %fxanim_river_tent01_anim;
	level.scr_anim["fxanim_props"]["a_tower_water"] = %fxanim_river_tower_water_anim;
	level.scr_anim["fxanim_props"]["a_tower_land"] = %fxanim_river_tower_land_anim;
	level.scr_anim["fxanim_props"]["a_tower_explode"] = %fxanim_river_tower_explode_anim;
	level.scr_anim["fxanim_props"]["a_pbr_props"] = %fxanim_river_pbr_props_anim;	
	level.scr_anim["fxanim_props"]["a_bunker01"] = %fxanim_river_bunker01_anim;
	level.scr_anim["fxanim_props"]["a_bunker02"] = %fxanim_river_bunker02_anim;
	level.scr_anim["fxanim_props"]["a_tree_sm_01_a"] = %fxanim_gp_tree_aquilaria_dest01_sm_anim;
	level.scr_anim["fxanim_props"]["a_tree_sm_01_b"] = %fxanim_gp_tree_aquilaria_dest02_sm_anim;
	level.scr_anim["fxanim_props"]["a_tree_sm_02_a"] = %fxanim_gp_tree_palm_coco02_dest01_sm_anim;
	level.scr_anim["fxanim_props"]["a_tree_sm_02_b"] = %fxanim_gp_tree_palm_coco02_dest02_sm_anim;
	level.scr_anim["fxanim_props"]["a_dead_body_tarp01"] = %fxanim_khesanh_deadbody_tarp_idle_anim;
	level.scr_anim["fxanim_props"]["a_dead_body_tarp02"] = %fxanim_khesanh_deadbody_tarp_idle02_anim;
	level.scr_anim["boss_boat"]["death_anim"] = %Fxanim_river_boss_boat_death_anim;
	level.scr_anim["fxanim_props"]["a_plane_blocker_02"] = %fxanim_river_plane_blocker_02_anim;
	
	ent1 = getent( "fxanim_pow_woodbridge_mod", "targetname" );
	ent2 = getent( "fxanim_river_tent01_mod", "targetname" );
	ent3 = getent( "river_tower_01", "targetname" );
	ent4 = getent( "river_tower_02", "targetname" );
	ent5 = getent( "river_tower_03", "targetname" );
	ent6 = getent( "river_tower_04", "targetname" );
	ent7 = getent( "river_tower_05", "targetname" );
	ent8 = getent( "fxanim_river_pbr_props_mod", "targetname" );	
	ent9 = getent( "river_bunker", "targetname" );
	ent10 = getent( "plane_blocker02", "targetname" );
	
	tree_array = GetEntArray( "fxanim_tree", "targetname" );
	tree_array_sm = GetEntArray( "fxanim_tree_sm", "targetname" );	
	
	enta_dead_body_tarp01 = getentarray( "dead_body_tarp01", "targetname" );
	enta_dead_body_tarp02 = getentarray( "dead_body_tarp02", "targetname" );
	
	if( IsDefined(ent1) )
	{
		ent1 thread woodbridge();
		println("************* FX: woodbridge *************");
	}
	
	if( IsDefined(ent2) )
	{
		ent2 thread tent01();
		println("************* FX: tent01 *************");
	}
	
	if(tree_array.size > 0) 
	{
		array_thread( tree_array, ::fx_treefall );
		println("************* FX: trees *************");
	}	
	
	if(tree_array.size > 0) 
	{
		array_thread( tree_array_sm, ::fx_treefall_sm );
		println("************* FX: trees *************");
	}
	
		for(i=0; i<enta_dead_body_tarp01.size; i++)
	{
 		enta_dead_body_tarp01[i] thread dead_body_tarp01(1,3);
 		println("************* FX: dead_body_tarp01 *************");
	}
	
	for(i=0; i<enta_dead_body_tarp02.size; i++)
	{
 		enta_dead_body_tarp02[i] thread dead_body_tarp02(1,3);
 		println("************* FX: dead_body_tarp02 *************");
	}
	
	if( IsDefined(ent3) )
	{
		ent3 thread tower_01();
		println("************* FX: tower_01 *************");
	}
	
	if( IsDefined(ent4) )
	{
		ent4 thread tower_02();
		println("************* FX: tower_02 *************");
	}
	
	if( IsDefined(ent5) )
	{
		ent5 thread tower_03();
		println("************* FX: tower_03 *************");
	}
	
	if( IsDefined(ent6) )
	{
		ent6 thread tower_04();
		println("************* FX: tower_04 *************");
	}
	
	if( IsDefined(ent7) )
	{
		ent7 thread tower_05();
		println("************* FX: tower_05 *************");
	}
	
	if( IsDefined(ent8) )
	{
		ent8 thread pbr_props();
		println("************* FX: pbr_props *************");
	}	
	
	if( IsDefined(ent9) )
	{
		ent9 thread river_bunker();
		println("************* FX: river_bunker *************");
	}
	
	if( IsDefined(ent10) )
	{
		ent10 thread plane_blocker_02();
		println("************* FX: plane_blocker_02 *************");
	}
}

boss_boat_death()
{
	level.boss_boat.animname = "boss_boat";
	level.boss_boat UseAnimTree(#animtree);
	anim_single( level.boss_boat, "death_anim" );
}

woodbridge()
{
	level.woodbridge_destroyed = 0;

	level waittill( "woodbridge_explosion_start" );
	
	level.woodbridge_destroyed = 1;
	
	// The createfx explosion for when the woodbridge explodes
	exploder( 999 );
	
	// Sound
	self PlaySound( "evt_bridge_wood_explo" );

	//	level thread maps\pow_utility::dialog_fly_extra("wooden_bridge");
	
	level thread woodbridge_destroy_collision();
			
	self UseAnimTree(#animtree);
	
	// The 1st param is a notify that gets sent off when the animation completes
	level thread anim_single(self, "a_woodbridge", "fxanim_props");
}

tent01()
{
	wait(.5);
	self UseAnimTree(#animtree);
	anim_single(self, "a_tent01", "fxanim_props");
}

fx_treefall()  // self == tree
{
	self endon( "cleaning_up_death" );

	self SetCanDamage(true);
	
	if ( isdefined( self.script_health ) )
	{
		self.health = self.script_health;
	}
	else
	{
		self.health = 250;
	}
	
	//self waittill("damage");
	
	self waittill("death");
	
	AssertEX( IsDefined(self.script_noteworthy), "Tree does not have script_noteworthy" );
	tree_anim = self.script_noteworthy;
	
	// Is there a pre-defined animation for the tree death, if not play a random tree falling animation
	if( IsDefined(self.script_string) )
	{
		tree_anim = self.script_string;
		self PlaySound("dst_tree_B");
	}
	else
	{
		if( RandomInt(2) < 1 )
		{
			tree_anim = tree_anim + "_a";
			self PlaySound("dst_tree_A");
		}
		else
		{
			tree_anim = tree_anim + "_b";
			self PlaySound("dst_tree_B");
		}	
	}
	
	self UseAnimTree(#animtree);
	anim_single( self, tree_anim, "fxanim_props" );
}

fx_treedelete()
{
	self notify( "cleaning_up_death" );
	wait( 1 );
	self delete();
}

tower_01()
{
	level waittill("tower_01_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_tower_water", "fxanim_props");
}

tower_02()
{
	level waittill("tower_02_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_tower_explode", "fxanim_props");
}

tower_03()
{
	level waittill("tower_03_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_tower_land", "fxanim_props");
}

tower_04()
{
	level waittill("tower_04_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_tower_water", "fxanim_props");
}

tower_05()
{
	level waittill("tower_05_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_tower_explode", "fxanim_props");
}

river_bunker()
{
	bunker_trigger = GetEnt( "concrete_MG_bunker_damage_trigger", "targetname" );
	
	level waittill("bunker01_start");
	self UseAnimTree(#animtree);
	anim_single(self, "a_bunker01", "fxanim_props");
	flag_wait( "bunker_dead" );  // scripter mod - fix for tower not playing second damage state. -TJanssen
	
	if( IsDefined( bunker_trigger ) )
	{
		PlayFX( level._effect[ "guard_tower_death" ], bunker_trigger.origin );
		playsoundatposition( "evt_sam_explo" , bunker_trigger.origin );
	}
	
	self UseAnimTree(#animtree);
	anim_single(self, "a_bunker02", "fxanim_props");
}

dead_body_tarp01(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_dead_body_tarp01", "fxanim_props");
}

dead_body_tarp02(delay_min,delay_max)
{
	wait(delay_min);
	wait(randomfloat(delay_max-delay_min));
	self UseAnimTree(#animtree);
	anim_single(self, "a_dead_body_tarp02", "fxanim_props");
}

plane_blocker_02()
{
	self Hide();
	level waittill("plane_blocker_02_start");
	
	self Show();
	self UseAnimTree(#animtree);
	anim_single(self, "a_plane_blocker_02", "fxanim_props");
}

pbr_props()
{
	while( !isdefined( level.boat ) )
	{
		wait( 0.05 );
	}
	
	level.boat endon( "death" );
	
	self UseAnimTree(#animtree);
	
	// attach the model to the boat
	self.origin = level.boat GetTagOrigin( "tag_body" );
	self.angles = level.boat GetTagAngles( "tag_body" );
	self LinkTo( level.boat, "tag_body" );
	
	//level waittill( "animate_boat_props" );
	while( 1 )
	{
		anim_single(self, "a_pbr_props", "fxanim_props");
	}
}

fx_treefall_sm() //self == tree
{
	//level endon("kill_tree_behavior");
	
	self SetCanDamage(true);
	//self.health = 1000;
	
	if ( isdefined( self.script_health ) )
	{
		self.health = self.script_health;
	}
	else
	{
		self.health = 250;
	}
	self waittill("death");
	
	AssertEX(IsDefined(self.script_noteworthy), "Tree does not have script_noteworthy");
	tree_anim = self.script_noteworthy;

	if( IsDefined(self.script_string) )
	{
		tree_anim = self.script_string;
		self PlaySound("dst_tree_B");
	}
	else
	{
		if(RandomInt(2) < 1)
		{
			tree_anim = tree_anim + "_a";
			//SOUND - Shawn J - tree fall sound A
			//iprintlnbold ( "timber A!");
			self PlaySound("dst_tree_A");
		}
		else
		{
			tree_anim = tree_anim + "_b";
			//SOUND - Shawn J - tree fall sound B
			//iprintlnbold ( "timber B!");
			self PlaySound("dst_tree_B");
		}	
	}
	
	//only for trees at end of level
	if( isdefined(level.flag["plane_attack"]) )
	{
		if( flag("plane_attack") )
		{
			//fire on tree
			PlayFX( level._effect[ "fx_river_fire_outdoor_sm" ], self.origin + (0,0,48) );
		}
	}
	self UseAnimTree(#animtree);
	anim_single( self, tree_anim, "fxanim_props");
	//dust
	//PlayFX( level._effect[ "guard_tower_death" ], self.origin );

}




//*****************************************************************************
// Fog Setup
//*****************************************************************************

fog_setup()
{
	startDist = 700;			//30.3545;
	halfwayDist = 5600;			//198;
	halfwayHeight = 420;		//470
	baseHeight = 0;
	red = 0.46;
	green = 0.52;
	blue = 0.47;
	transition_time = 1;
	
	setvolfog(startDist, halfwayDist, halfwayHeight, baseHeight, red, green, blue, transition_time);
}


//*****************************************************************************
//*****************************************************************************

woodbridge_destroy_collision()
{
	ai_collision_ent = getent( "bridge_ai_collision", "targetname" );	
	
	ai_collision_ent Delete();
}


/*===========================================================================
POSSIBLE TAGS:
	tag_front_corner_joint_01
	tag_front_corner_joint_02
	tag_cabin_roof_joint_02
	
	
	vehicle = boat_sampan_physics
	model = dest_jun_sampan_large_d0
===========================================================================*/
sampan_spotlight()  // self = sampan that needs a spotlight effect on it
{
	tag = "tag_front_corner_joint_01";
	
	if( IsDefined( self GetTagOrigin( tag ) ) )
	{
		fx_origin = Spawn( "script_model", self GetTagOrigin( tag ) );
		fx_origin SetModel( "tag_origin" );

		// tag position is facing inward in relation to sampan's forward direction, so spin it 180 degrees	
		origin_offset = ( -20, 0, -10 );
		angles_offset = ( 0, 180, 0 );
		
		fx_origin LinkTo( self, tag, origin_offset, angles_offset );
		
		PlayFXOnTag( level._effect[ "sampan_light" ], fx_origin, "tag_origin" );
		
		self waittill( "death" );
		fx_origin Delete();
	}
}
