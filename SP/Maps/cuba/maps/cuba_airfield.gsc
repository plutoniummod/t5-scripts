
#include common_scripts\utility;
#include maps\_utility;
#include maps\cuba_util;
#include maps\_vehicle;
#include maps\_anim;
#include maps\_flyover_audio;
#include maps\_music;

start()
{
	
	battlechatter_off();
	//hangars that get destroyed
	init_hangars();
	
	level.player_minigun_max_damage = 10;
	level.player_minigun_invulnurablility_interval = 6 * 1000;
	
	init_steves_flags();
	
	zpu = spawn_vehicles_from_targetname("player_zpu")[0];
	
	//set up some drone overrides
	//level.max_drones["axis"] = 50;
	//level.max_drones["allies"] = 50;	
	//level._drones_sounds_disable = 1;
		
	//disable physics pulse on mortar impacts
	level.no_mortar_physics = 1;
	
	level._explosion_stopNotify = [];
	level._explosion_stopNotify["airfield_ambient_mortar"] = "stop_first_mortars";	
	level._explosion_stopNotify["airfield_ambient_mortar_right"] = "stop_right_mortars";	
	
	level.spawners_to_delete = getentarray("axis_spawners_delete","script_noteworthy");
	
	//init flags, etc...
	init_airfield_settings();

	maps\cuba_goatpath::kill_bombers();	
	flag_set("ambient_artillery");
	
	//ambient stuff
	ambient_airfield_aa_fire();
	setup_airfield_mortars();
	
	//spawn planes, jeeps, trucks and bombers
	level thread spawn_planes();
	wait(.5);
	level thread spawn_jeeps_and_trucks();
	wait(.5);
	//level thread spawn_bombers();
	wait(.5);
	level thread spawn_static_vehicles();		
	
	level thread create_craters();
	
	level thread hangar1_player_prevention(); //prevent player from going into the left hangar per Hutch

	
	//some friendly AI come in on trucks 
	level thread setup_airfield_rebels();
		
	//override the drone muzzleflash fx
	//level thread setup_drone_FX();	
	
	//level thread setup_airfield_shrimps();
	
	//waits for the player to get close then kicks off the dialogue
	level thread wait_for_player_to_approach_airfield();	
	
	level thread stun_player(); //shell shocks player at hangar
	level thread put_player_on_aa_gun();
	
	//the plane the player escapes in
	wait(.1);
	spawn_vehicles_from_targetname("ac130_escape");	
	wait(.1);
	spawn_vehicles_from_targetname("hangar1_fuel_trucks");
	wait(.1);
	//spawn_vehicles_from_targetname("parked_b17");

	//setup the heros for this event when it starts
	level thread setup_init_hero_state();	
	
	//objectives for this event
	level thread airfield_objectives();	
	
	//make the zpu usable
	zpu makevehicleusable();
	zpu thread veh_magic_bullet_shield(1);		
	
	//mortar run when player goes thru the airfield
	level thread start_mortar_run();		
	
	//clean up a bunch of stuff that isn't needed at this point 
	level thread cleanup();
			
	//the ropes that the squad uses to rappel down
	level thread setup_idle_ropes();
	
	level thread tower_destruction();
	
	level thread hangar1_ai_management();
	
	level thread runway_jets();
	
	level thread background_trucks();

	level thread runway_zpus();
	
	level thread steve_cleanup();
	
	level thread rail_enemy_spawn_logic();
	
	level thread player_gets_captured();
	
	level thread rail_bomber_timing();
	
	level thread epic_sugarfield_jets();
	
	level thread fuel_truck_zpus();
	
	level thread plane_warpto();
	
	//level thread rpg_guy_tower_setup();
	
	level thread AA_gun_read();
	
	level thread fail_takeoff();
	
	level thread plane_too_far_to_warp();
	
	level thread propeller_death_trig_setup();
	
	//level thread plane_takeoff_monitor();
	
	plane = GetEnt ("ac130_escape", "targetname");
	plane.overrideVehicleDamage = ::escape_plane_override;
	//plane thread veh_magic_bullet_shield(1);
	
	airfield_axis = GetSpawnerTeamArray ("axis");
	array_thread(airfield_axis,::add_spawn_function,::no_explosive_death_anim);
	
	//allies on airfirled 
	trigger_use ("ally_airfield_spawner");
	
}


		

no_explosive_death_anim()
{
	self.noExplosiveDeathAnim = 1;
	
	// set up gib
	self.force_gib = true; 
	self.custom_gib_refs = [];
	self.custom_gib_refs[0] = "right_arm";
	self.custom_gib_refs[1] = "left_arm";
	self.custom_gib_refs[2] = "no_legs";
	self.custom_gib_refs[0] = "right_arm";
	self.custom_gib_refs[1] = "left_leg";
	self.custom_gib_refs[2] = "right_leg";
	
}

	
	
init_steves_flags()
{
	flag_init ("rappel_started");
	flag_init ("rappel_finished");
	flag_init ("carlos_ai_on_board");
	flag_init ("woods_ai_on_board");
	flag_init ("bowman_ai_on_board");	
	flag_init	("all_aboard");
	flag_init ("player_stunned");
	flag_init ("hangar1_blown");
	flag_init ("player_on_plane");
	flag_init ("plane_turning_corner");
	flag_init ("player_on_aa_gun");
	//flag_init ("mason_deals");
	flag_init ("player_being_warned");
	flag_init ("player_failed_mortar_run");
	flag_init ("player_failed_clearing_runway");
	flag_init ("plane_too_far_to_warp");
	flag_init ("plane_warped");
	flag_init ("zpus_start");
	flag_init ("runway_vo_complete");
	flag_init ("player_shot_plane");
	flag_init("static_vehicles_spawned");
}	

setup_idle_ropes()
{
	anim_node = getstruct("rappel","targetname");
	
	level.player_rope = spawn_rope("rope");
	level.bowman_rope = spawn_rope("left_rope");
	level.woods_rope = spawn_rope("right_rope");
	
	anim_node thread anim_loop_aligned(level.player_rope,"rappel_idle");
	anim_node thread anim_loop_aligned(level.bowman_rope,"rappel_idle");
	anim_node thread anim_loop_aligned(level.woods_rope,"rappel_idle");
}


airfield_axis_logic()
{
	self.health = 10;
	self.dropWeapon = false;
	
}	

setup_airfield_destructibles()
{
	//self = destructible 
	//self thread Maps\cuba_escape::Print3d_on_ent("!");
	self SetCanDamage(0);
	flag_wait ("player_on_plane");
	self SetCanDamage(1);
}	


delete_all_touching(val,key)
{
	if(!isDefined(key))
	{
		key = "targetname";
	}
	vol = getent(val,key);
	if(!isDefined(vol))
	{
		return;
	}
	ai = getaiarray();
	for(i=0;i<ai.size;i++)
	{
		if( ai[i] istouching(vol))
		{
			ai[i] notify("death");
			ai[i] delete();
		}
	}
}

#using_animtree("generic_human");
hangar_signal_guy_logic()
{
	self.ignoreme = 1;
	self.ignoreall = 1;
	self.disableArrivals = true;
	self.disableExits = true;
	self.disableTurns = true;
	self.force_gib = 1;
	self.animname = "hangar_guy";
	
	self.movePlayeBackRate = RandomFloatRange( 1.6, 2 );
	spot = getstruct ("signal_spot", "targetname");
	my_anim = (level.scr_anim[ "troop_signal_ai" ][ "signal" ][0]);
	
	trigger_wait ("signal_guy_go");
	
	//anim_length = GetAnimLength(level.scr_anim[ "troop_signal_ai" ][ "signal" ][0]);
	spot anim_reach_aligned( self, "signal" ); 
	
	spot anim_single_aligned( self,"signal"); 
	
	self.animname = "civ_explode";
	level thread Maps\cuba_escape::do_a_mortar(self, get_players()[0]);
	anim_single (self, "death_explode5");

}

hangar_guy2_logic()
{
	self endon ("player_on_plane");
	self endon ("death");
	self.animname = "hangar_guy2";
	self.ignoreme = 1;
	self disable_pain();
	self disable_react();
	self.allowdeath = true;
	spot = getstruct ("hangar_guy2_spot", "targetname");
	//self thread magic_bullet_shield();
	node = GetNode (self.target, "targetname");
	self SetGoalNode (node);
	self waittill ("goal");
	trigger_wait ("start_mortar_run");
	spot anim_single_aligned (self, "signal2");
	
	//self stop_magic_bullet_shield();
	self die();

}	


crater_guy_logic()
{
	self thread magic_bullet_shield();
	self.ignoreme = 1;
	self.animname = "civ_explode";
	level waittill ("crater2_blown");
	self stop_magic_bullet_shield();
	self anim_single (self, "death_explode2");
	
}	

spawn_rope(animname)
{
	anim_node = getstruct("rappel","targetname");
	
	rope = spawn("script_model",anim_node.origin);
	rope  setmodel("anim_jun_rappel_rope");
	rope.angles = anim_node.angles;	
	rope.animname = animname;	
	rope  useanimtree(level.scr_animtree["rope"]);
	return rope;
}

init_hangars()
{
	level.hangar_0_good = getent("hanger_0","targetname");
	level.hangar_1_good = getent("hanger_1","targetname");
	//level.hangar_2_good = getent("hanger_2","targetname");
	level.hangar_3_good = getent("hanger_3","targetname");
	level.hangar_4_good = getent("hanger_4","targetname");
	
	level.hangar_0_bad = getent("hanger_dmg_0","targetname");
	level.hangar_1_bad = getent("hanger_dmg_1","targetname");
	//level.hangar_2_bad = getent("hanger_dmg_2","targetname");
	level.hangar_3_bad = getent("hanger_dmg_3","targetname");
	level.hangar_4_bad = getent("hanger_dmg_4","targetname");
	
	level.hangar_0_bad hide();
	level.hangar_1_bad hide();
	//level.hangar_2_bad hide();
	level.hangar_3_bad hide();
	level.hangar_4_bad hide();	
	
}

destroy_palm_tree2()
{
//	level waittill("airfield_dlg_done");	
//	trigger_wait("blow_palmtree");
//
//	//blow up hangar 0 here instead
////	structs = getstructarray("hangar0_mortars","targetname");
////	for(i=0;i<structs.size;i++)
////	{
////		playfx(level._effect["fx_cuba_bomb_explo"],structs[i].origin);
////		Earthquake( .45, 3, structs[i].origin, 3048 );
//// 		wait(.1);
////	}
//	
////	level.hangar_0_bad show();
////	level.hangar_0_good delete();
//	
//	wait(randomfloat(5.8));
//	tree = getent("palm_tree_hangar2","targetname");
//	playfx(level._effect["airfield_ambient_mortar"],tree.origin);
//	Earthquake( .45, 3, tree.origin, 3048 ); 
//	level thread maps\_mortar::mortar_rumble_on_all_players("damage_light","damage_heavy", tree.origin, 3048, 3048 );
//	tree moveto(	(3074.73, 7841.69, -1144.92),1.1);
//	tree rotateto( (0.269188, 359.443 ,75.2558),1);			
}

destroy_plane(plane_noteworthy)
{
	plane = getent(plane_noteworthy,"script_noteworthy");
	playfx(level._effect["vehicle_explosion"],plane.origin);
	//plane setmodel("t5_veh_jet_mig17_gear_dead");
}

destroy_palmtree2b()
{
	wait(randomfloatrange(1.5,2.5));
	tree = getent("palm_tree_hangar2_b","targetname");	
	tree rotateto( (0.269188 ,14.443, 75.2558),1);
	tree moveto( (4237.6 ,8296.2, -1144.9),1.1);
	playfx(level._effect["airfield_ambient_mortar"],tree.origin);
	Earthquake( .45, 3, tree.origin, 3048 ); 
	level thread maps\_mortar::mortar_rumble_on_all_players("damage_light","damage_heavy", tree.origin, 3048, 3048 );
	wait(randomfloatrange(1.5,2.5));
	level thread destroy_palmtree2a();	
}

destroy_palmtree2a()
{
	tree = getent("palm_tree_hangar2_a","targetname");	
	tree rotateto( (0.269188, 291.043, 75.2558),1);
	tree moveto( (4650, 7576.6, -1120.9),1.1);
	playfx(level._effect["airfield_ambient_mortar"],tree.origin);
	Earthquake( .45, 3, tree.origin, 3048 ); 
	level thread maps\_mortar::mortar_rumble_on_all_players("damage_light","damage_heavy", tree.origin, 3048, 3048 );
	
}

airfield_objectives()
{
	woods = get_hero_by_name("woods");
	set_objective(level.OBJ_AIRFIELD ,woods, "follow");
	
	trigger_wait("start_airfield_dialogue");
	//objective_state(level.OBJ_AIRFIELD,"done");
			
	level waittill("airfield_dlg_done");
	set_objective(level.OBJ_RAPPEL_DOWN );
	
	level waittill("player_rappel_done");
	
	set_objective(level.OBJ_PLANE, woods, "follow");
	
	trigger_wait ("start_mortar_run"); //set objective to plane once player exits first hangar

	ent = getstruct ("obj_enter_plane","targetname");
	//set_objective(level.OBJ_PLANE,ent,"");
	//Objective_Position( level.OBJ_PLANE, ent.origin);
	//Objective_Set3d(level.OBJ_PLANE, 1); 

	set_objective(level.OBJ_PLANE, ent);
	
	flag_wait("player_on_plane");	

	set_objective(level.OBJ_PROTECT_PLANE);
	
	level waittill("mason_deals");
	
	clientNotify ("exit_plane");
	//TUEY set music state to MASON_HERO
	level thread maps\_audio::switch_music_wait("MASON_HERO", 4);
	
	
	player_zpu = getent("player_zpu","targetname");
	
	obj_model = Spawn("script_model", player_zpu.origin);
	obj_model.angles = player_zpu.angles;
	obj_model SetModel ("vehicle_zpu4_obj");
	
	player_zpu Hide();
	
	org = spawn("script_origin",player_zpu.origin + (0,0,75));
	set_objective(level.OBJ_AA_GUN, org ,"");
	
	flag_wait ("player_on_aa_gun");
	player_zpu Show();
	obj_model Hide();
	
	flag_wait("truck_exploded");
	objective_state(level.OBJ_AA_GUN,"done");
	Objective_Delete(level.OBJ_AA_GUN);
	objective_Set3d(level.OBJ_AA_GUN, false);

}

setup_init_hero_state()
{
	woods = get_hero_by_name("woods");
	bowman = get_hero_by_name("bowman");
	
	woods make_oblivious();
	bowman make_oblivious();
	
}

make_oblivious()
{
	self.moveplaybackrate = 1.35;
	self.ignoreme = 1;
	self.ignoreall = 1;
	self.ignoresuppression = 1;
	self disable_pain();
	self.grenadeawareness =0;
	self disable_react();
	//self.animplaybackrate = 2.5;
}


setup_spawn_functions()
{

	explosive_items = GetEntArray ("airfield_destructible", "script_noteworthy");
	array_thread (explosive_items, ::setup_airfield_destructibles);

	riders_2_delete = getentarray("airfield_truck2_riders","targetname");
	array_thread(riders_2_delete,::add_spawn_function,::spawnfunc_truck_riders_delete);
	
	airfield_rebel_spawners = getentarray("garage1_onetime_spawners","targetname");
	array_thread(airfield_rebel_spawners,::add_spawn_function,::fire_rpg_at_random_drones);
	
	airfield_enemy_spawners = getentarray("axis_airfield_guys","targetname");
	array_thread(airfield_enemy_spawners,::add_spawn_function,::fire_rpg_at_random_drones);
	
	add_spawn_function_veh("airfield_fuel_truck",::explode_on_damage);
	
	//add_spawn_function_veh("parked_b17",::parked_b17_logic);
	
	add_spawn_function("hangar2_rushers",::spawnfunc_player_rusher);
	
	rail_guys1 = getentarray("troops_truck1_guys","targetname");
	array_thread(rail_guys1,::add_spawn_function,::attack_player_after_unload);
	
	rail_guys2 = getentarray("rail_baddies","script_noteworthy");
	array_thread(rail_guys2,::add_spawn_function,::airfield_axis_logic);
	
	hangar1_runners = getentarray("hangar1_runners","targetname");
	array_thread(hangar1_runners,::add_spawn_function,::hangar1_runner_logic);
	
	rail_uaz_guys = getentarray("rail_uaz_guys","targetname");
	array_thread(rail_uaz_guys,::add_spawn_function,::player_seek_no_cover);
	
	fuel_truck_runners = getentarray("fuel_truck_runners","targetname");
	array_thread(fuel_truck_runners,::add_spawn_function,::fuel_truck_runner_logic);
	
	hangar1_middle_guys = getentarray("hangar1_middle_guys","targetname");
	array_thread(hangar1_middle_guys,::add_spawn_function,::hangar1_middle_guys_logic);
	
	middle_island_guys = getentarray("middle_island_guys","targetname");
	array_thread(middle_island_guys,::add_spawn_function,::middle_island_guys_logic);
	
	misc_rail_guys = getentarray("misc_rail_guys","targetname");
	array_thread(misc_rail_guys,::add_spawn_function,::spawnfunc_player_rusher);
	

	add_spawn_function_veh("hangar1_fuel_trucks", ::hangar1_fuel_trucks_logic);
	
	add_spawn_function_veh("uaz_rail", ::uaz_rail_logic);
	
	
	new_dropoff_guys = getentarray("new_dropoff_guys","targetname");
	array_thread(new_dropoff_guys,::add_spawn_function,::force_goal_after_unload);
	
	
}

create_craters()
{
	
	crater = "mortor_hole_after_0";
	num = 1;
	
	//hide the script_brushmodel craters
	for (i = 0; i < 3; i++ )
	{
		Hide_spot = GetEnt (crater+num, "targetname");
		Hide_spot Hide();
		num++;
	}		
	trigger_wait ("start_mortar_run");
	player = get_players()[0];
	
	//script_origins in each crater
	craters = getstructarray ("craters", "script_noteworthy");
	array_thread (craters, ::crater_distance_monitor, player);
	
}	


crater_distance_monitor(player)
{
	//self = script_origin in crater waiting to blow up
	//spot = self.origin;
	
	//establish the "after" script_brushmodel to show on impact
	if(self.targetname == "mortor_hole_04") 
	{
		self.before = GetEnt ("mortor_hole_before_04", "targetname");
		self.after = GetEnt ("mortor_hole_after_04", "targetname");
	}	
	else if(self.targetname == "mortor_hole_01") 
	{
		self.before = GetEnt ("mortor_hole_before_01", "targetname");
		self.after = GetEnt ("mortor_hole_after_01", "targetname");
	}	
	else 
	{
		self.before = GetEnt ("mortor_hole_before_02", "targetname");
		self.after = GetEnt ("mortor_hole_after_02", "targetname");
	}	
	

	while(1)
	{
		dist = DistanceSquared (self.origin, player.origin);
		{
			if(dist <= 500*500)
			{
				level thread Maps\cuba_escape::do_a_mortar(self, player);
				self.before Hide();
				self.after Show();
				if(self.targetname == "mortor_hole_02")
				{
					//AI plays death anim on this notify
					level notify ("crater2_blown");
				}				
				break;
			}
		}
		wait(.05);
	}	
				
}
	
attack_player_after_unload(script_spawner_targets)
{
	self endon("death");
	self.noExplosiveDeathAnim = 1;
	self set_goalradius( 32  );
	wait(1);
	if(IsDefined(self.ridingvehicle))
	{
		self.ridingvehicle thread veh_magic_bullet_shield(1);	
		self.ridingvehicle waittill ("reached_end_node");
		self.ridingvehicle thread veh_magic_bullet_shield(0);
	}	
	
	if(self.classname !="actor_CU_e_FNFAL_RPG_STRAIGHT")	
	{	
		self.disablemelee = 1;
		self.script_radius = RandomIntRange(90,150);
		self SetGoalEntity( get_players()[0] );
		self thread force_goal();
	}
	else
	{
		self thread fire_rpg_at_plane();
	}
	
}

force_goal_after_unload()
{
	self endon("death");
	self set_goalradius( 32  );
	self.ignoreall = 1;
	
	wait(1);
	if(IsDefined(self.ridingvehicle))
	{
		self.ridingvehicle thread veh_magic_bullet_shield(1);	
		self.ridingvehicle waittill ("reached_end_node");
		self.ridingvehicle thread veh_magic_bullet_shield(0);
	}	
	
	wait(1.5); //unloading?
	self thread force_goal();
	
	//guy at cover_right at hangar entrance should not shoot. 
	if(IsDefined(self.script_noteworthy) && self.script_noteworthy == "door_cover_guy")
	{
		return;
	}
	
	self set_spawner_targets ("runway_island");
	self waittill ("goal");
	self.ignoreall = 0;

}	

#using_animtree("generic_human");
explode_on_damage()
{

	//self veh_toggle_tread_fx(0);
	self waittill("reached_end_node");	
	if(!flag("truck_exploded"))
	{
		self thread wait_for_player_to_damage_me();		
		flag_wait("truck_exploded");		
		self notify("death");
		playsoundatposition ("exp_veh_large", self.origin);
	}	

}

put_player_on_aa_gun()
{
	trigger_wait ("aa_bump_trigger");
	player = get_players()[0];
	player.ignoreme = 1;
	zpu = getent("player_zpu","targetname");
	
	//facing player same angles as ZPU before entring vehicle to prevent bugs where gun would face odd direcions at first
	player FreezeControls(true);
	player SetPlayerAngles (zpu.angles);
	
	zpu UseVehicle( player, 0);
	level thread display_prompt_until_player_hits_attack();
	zpu MakeVehicleUnusable();
	
	player FreezeControls(false);
	
	flag_set ("player_on_aa_gun");
	//damage trig by trucks sets same flag as when player shoots the actual trucks
	level thread fuel_trucks_backup_trigger();

	
	//turn off damage trig once player fails
	trig = GetEnt ("fuel_trucks_damage_trigger", "targetname");
	flag_wait ("player_failed_clearing_runway");
	trig trigger_off();

}	



player_gets_captured()
{
	zpu = getent("player_zpu","targetname");
	player = get_players()[0];
	
	flag_wait ("player_on_aa_gun"); //handled by bump_trig now. 
	//player thread lerp_fov_overtime( 1, 40 );
	level thread setup_runway_trucks_and_drones();
		
	flag_wait("truck_exploded");
	
	//reset the FOV	
	
	/*
	anchor = Spawn ("script_origin", player.origin);
	anchor.angles = player GetPlayerAngles();
	player Unlink();
	wait(.05);
	player PlayerLinkToDelta (anchor,undefined, 0,10,10,45,20);
	//player PlayerLinkToDelta (mover, undefined, 0, 45, 45, 15, 15 );
	*/
	
	//ground explosion
	playsoundatposition ("evt_big_explof", (0,0,0));
	
	exploder(990);
	//wait for plane to get airborn
	

	//spots = getentarray("enemy_aagun_warpto","targetname");
	
	level notify("stop_axis_drones");
	level notify("stop_allied_drones");		

	//wait(4);	
	//set up the scene
	
	drones = getentarray("drone","targetname");
	for(i=0;i<drones.size;i++)
	{
		drones[i] notify("death");
		drones[i] delete();
	}	
	
}

smoke_spiral(plane)
{
	level endon ("player_failed_clearing_runway");
	plane waittill ("airborne");
	wait(.1);
	PlayFXOnTag(level._effect["plane_smoke_spiral"], plane, "tag_origin");
}	
	

outro_scene()
{
	//Anim align struct
	node = getstruct("your_dead_align","targetname");	
	
	//get start pos and angles of scene 
	start_origin = GetStartOrigin(node.origin, node.angles, level.scr_anim["player_hands"]["your_dead"] );
	start_angles = GetStartAngles(node.origin, node.angles, level.scr_anim["player_hands"]["your_dead"] );
	
	//spawn actors
	kravchenko = simple_spawn_single("airfield_Kravchenko");	
	dragovich = simple_spawn_single("airfield_dragovitch");
	castro = simple_spawn_single("airfield_cuba");	
	
	//put them in an array
	bad_guys = array(kravchenko, dragovich, castro);
	
	//anim names
	castro.animname = "castro";
	dragovich.animname = "dragovich";
	kravchenko.animname = "kravchenko";
	
	//just sets ignore all, me, etc
	array_thread (bad_guys, ::setup_enemy_aagun_guys);
	
	//starts streaming process early
	stream_helper = createStreamerHint (start_origin, 1.0);
	
	flag_wait("start_outro");//gets set after player captured scene on AA gun
	flag_set("cuba_end_script_started");
	
	player = get_players()[0];
	player SetClientDvar("cg_drawfriendlynames", 0);
	
	stream_helper Delete();
	
	//SOUND New seagulls are visible here. 
	
	//player is still inked to this model from AA gun capture, player gets warped to this location here
	
	player Unlink();
	player.ignoreme = true;
	
	player_model = spawn_anim_model("player_hands",start_origin);
	player_model.angles = start_angles;
	player_model.animname = "player_hands";
	
	start_movie_scene();
	add_scene_line(&"cuba_vox_cub1_s01_953A_maso", 1.5, 3.5);		//Oh, he did. Dragovich sure did.
	
	level.movie_trans_in = "black";

	//stream bik movie
	level thread play_movie("mid_cuba_3", 0, 0, "start_outro_movie", 1, "outro_movie_done", 1);
	//                     (movie_name, is_looping, is_in_memory, start_on_notify, use_fullscreen_fade, notify_when_done, notify_offset)

	maps\createart\cuba_art::set_cuba_dof("airfield_outro");	
	
	simple_spawn ("cutscene_extra", ::cutscene_extra_logic); //guys on the ship
		
	castro.cigar = Spawn( "script_model", ( 0,0,0 ) );
	castro.cigar SetModel("p_glo_cuban_cigar01");
	castro.cigar LinkTo( castro, "tag_weapon_left", ( 0,0,0 ), ( 0,0,0 ) );

	//changing this array to undefined before creating this new one with the actors
	//bad_guys = undefined;
	
	//put actors and player in array
	ents = array(player_model,castro,dragovich,kravchenko);
	
	//get time for the anim scene
	anim_length = GetAnimLength( level.scr_anim["dragovich"]["your_dead"] );
	
	//START ANIM SCENE
	node thread anim_single_aligned(ents,"your_dead");
	wait .05;
	
	player SetOrigin(player_model GetTagOrigin("tag_camera"));
	player SetPlayerAngles(player_model GetTagAngles("tag_camera"));
	player PlayerLinkToAbsolute(player_model, "tag_camera");
	//wait(0.05);
	//FADE IN
	custom_fade_screen_in(1.95);	
	
	wait(anim_length - 6);
	//-- GLocke: Reset Dvar used during movie playback
	SetSavedDvar("r_streamFreezeState", 1);
	
	//wait length of scene minus 2 secs
	wait(3.5);
	
	clientnotify( "enden" );
	
	//START MOVIE 
	level notify ("start_outro_movie");
	
	//MOVIE ENDS HERE
	level waittill ("outro_movie_done");
	//-- GLocke: Reset Dvar used during movie playback
	SetSavedDvar("r_streamFreezeState", 0);
	custom_fade_screen_out("black",1);	
	wait(1);
	
	player SetDepthOfField( 0, 0, 0, 0,0,0 );
	player setClientDvar( "r_dof_tweak", 0 );
	
	player SetClientDvar("cg_drawfriendlynames", 1);
	
	nextmission();	
}

castro_cigar_fx(guy)
{
	//castro cigar fx notetrack
	spot = guy.cigar GetTagOrigin ("tag_FX");	
	//ent = Spawn ("script_origin", spot);
	//ent LinkTo (guy.cigar);
	//ent thread Maps\cuba_escape::Print3d_on_ent("!");
	
	PlayFXOnTag(level._effect["cigar_fx"], guy.cigar, "tag_FX");
	
}	

cutscene_extra_logic()
{
	self.animname = "generic";
	self.ignoreall = 1;
	self.ignoreme = 1;
	self.disableArrivals = true;
	self.disableExits = true;
	self.disableTurns = true;
	self set_generic_run_anim( "patrol_walk" );
	
}	

setup_runway_trucks_and_drones()
{
	trigger_use("spawn_additional_trucks");
	//trigger_use("drones_run","script_noteworthy"); //replacing drones with AI
}
setup_enemy_aagun_guys()
{
	self disable_react();
	self disable_pain();
	self.ignoreall = 1;
	self.ignoreme = 1;
}


/*------------------------------------

------------------------------------*/
setup_airfield_rebels()
{
	trigger_wait("spawn_incoming_trucks");
	
	//truck comes in and unloads 5 guys into the battle
	vehicles = spawn_vehicles_from_targetname("airfield_truck1");
	vehicles[0] thread go_path(getvehiclenode(vehicles[0].target,"targetname"));
	vehicles[0] veh_magic_bullet_shield(1);

	wait(2);
	other_vehicles = spawn_vehicles_from_targetname("airfield_truck2");
	other_vehicles[0] thread go_path(getvehiclenode(other_vehicles[0].target,"targetname"));	
	
	getent("spawn_incoming_trucks","targetname") delete();
	
	woods = get_hero_by_name("woods");
	bowman = get_hero_by_name("bowman");
	
	woods thread heros_reach_to_rappel_spot_and_idle();
	bowman thread heros_reach_to_rappel_spot_and_idle();
	
	vehicles[0] waittill ("reached_end_node");
	
	vehicles[0] thread rappel_truck_explosion();

}

#using_animtree("fxanim_props");
rappel_truck_explosion()
{
	//self = truck that blows up when player rappels down

	flag_wait ( "airfield_forward_rappel_start" );
	player = get_players()[0];
	wait(4);
	//
	
	stunt_double = Spawn("script_model", self.origin);
  stunt_double SetModel("t5_veh_truck_gaz63_dead");
  stunt_double.animname = "airfield_truck";
  stunt_double.angles = self.angles;
  
  stunt_double UseAnimTree(#animtree);
  stunt_double.vehicletype = self.vehicletype;
  
  PlayFX( level._effect[ "darwins_vehicle_explosion" ], self.origin );    
  self Delete();                    
  
	stunt_double thread anim_single( stunt_double, "explode2" );
	
	PlaySoundAtPosition  ("wpn_grenade_explode", stunt_double.origin);
			
	//rumble
	player PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake(.95, .7, player.origin,80);	
	
	wait(3);
  stunt_double Delete();
	
}	

#using_animtree("generic_human");
heros_reach_to_rappel_spot_and_idle()
{
	level endon("started_rappel");

	//self = woods or bowman
	anim_node = getstruct("rappel","targetname");
	
	anim_node anim_reach_aligned(self,"forward_rappel_arrive");
	anim_node anim_single_aligned(self,"forward_rappel_arrive");
	anim_node anim_loop_aligned(self,"rappel_idle");	
}


setup_non_rpg_guy()
{
	self endon("death");
	self.ignoreall = true;
	self.ignoreme = true;
	self waittill("goal");
	self.ignoreall = false;
	self.ignoreme = false;
}

fire_rpg_at_random_drones()
{
	flag_wait("all_players_spawned");	
	
	self.ignoreall = true;
	self.ignoreme = true;
		
	if(!issubstr( ToLower( self.classname ),"rpg"))
	{
		self thread setup_non_rpg_guy();
		return;
	}	
	self endon("death");
	level endon("stop_firing_rpg");
	self waittill("goal");
	
	wait(3);
	
	self thread switch_weapon_ASAP();
	self waittill("weapon_switched");
	self.a.allow_weapon_switch = false;
	self.ignoreall = false;
	
	while(1)
	{
		if(self.team != "axis")
		{
			drones = getentarray("axis_drones","script_noteworthy");
			ai = getaiarray("axis");
			all_drones = array_combine(drones,ai);
		}
		else
		{
			ai = getaiarray("allies");
			drones = getentarray("allied_drones","script_noteworthy");
			all_drones = array_combine(drones,ai);
		}
		
		if(all_drones.size < 1)
		{
			wait(.05);
			continue;
		}
		
		drones = get_array_of_closest(self.origin, all_drones,undefined,undefined,5000);
		if(drones.size < 1 )
		{
			wait(.05);
			continue;
		}
		target = random(drones);
		self thread shoot_at_target( target,"J_head",undefined, 3 );
		wait(3);				
	}	
}

/*------------------------------------
flags and vars for the airfield section
------------------------------------*/
init_airfield_settings()
{
	//flags
	flag_init("ambient_artillery");
	flag_init("truck_exploded");
	flag_init("rpg_change_targets");
	flag_init("player_in_plane");
	flag_init("woods_on_plane");
	flag_init("airfield_vision");

	
	//drone spawn funcs
	//level.drone_spawnFunction["allies"] = character\c_cub_tropas_drone::main; 
	//level.drone_spawnFunction["axis"] = character\c_cub_tropas_drone::main;	
	
	setup_spawn_functions();
	
}

/*------------------------------------
a cheaper version of "blooody death" 
------------------------------------*/
kill_self()
{	
	self endon("death");
	
	bone[0] = "J_Knee_LE"; 
	bone[1] = "J_Ankle_LE"; 
	bone[2] = "J_Clavicle_LE"; 
	bone[3] = "J_Shoulder_LE"; 
	bone[4] = "J_Elbow_LE"; 
		
	impacts = ( 1 + RandomInt( 2 ) ); 
	for( i = 0; i < impacts; i++ )
	{
		playfxontag(  level._effect["blood"], self, bone[RandomInt( bone.size )] ); 
		           		
		wait( 0.05 ); 
	}
	self dodamage(self.health + 100,self.origin);
}


/*------------------------------------
clean up some stuff before everything starts
------------------------------------*/
cleanup()
{
	
	wait(5);
	
	//delete all the rogue bombs
	ents = getentarray("script_model","classname");
	for(i=0;i<ents.size;i++)
	{
		if(isDefined(ents[i].model) && ents[i].model == "aircraft_bomb")
		{
			ents[i] delete();		
		}
	}
	
	//delete any weapons laying around
	ents = GetItemArray();
	array_delete(ents);
	
	//delete exploders
	ents = getentarray("exploderchunk visible","targetname");
	array_delete(ents);
			
	/*
	ents = getentarray("destructible","targetname");
	for(i=0;i<ents.size;i++)
	{
		if(isDefined(ents[i].script_noteworthy) && ents[i].script_noteworthy == "airfield_destructible")
		{
			continue;
		}
		ents[i] delete();
	}
	*/
	ents = getentarray("vehicles_to_delete","targetname");
	array_delete(ents);
	
	ents = undefined;	
}

/*------------------------------------
set up the airfield ambient mortars
------------------------------------*/
setup_airfield_mortars()
{	
	//set_mortar_delays( mortar_name, min_delay, max_delay, barrage_min_delay, barrage_max_delay, set_default )

	
	maps\_mortar::set_mortar_delays("airfield_ambient_mortar", 4, 4.75, 4.25, 5);
	maps\_mortar::set_mortar_range( "airfield_ambient_mortar", 1000, 40000 );
	maps\_mortar::set_mortar_damage( "airfield_ambient_mortar", 384, 50, 1000 );
	maps\_mortar::set_mortar_quake( "airfield_ambient_mortar", .21, 2, 10000 );
	maps\_mortar::set_mortar_chance( "airfield_ambient_mortar", .8 );
	
	maps\_mortar::set_mortar_delays("airfield_ambient_mortar_left", 4, 4.75, 4.25, 5);
	maps\_mortar::set_mortar_range( "airfield_ambient_mortar_left", 1000, 40000 );
	maps\_mortar::set_mortar_damage( "airfield_ambient_mortar_left", 384, 50, 1000 );
	maps\_mortar::set_mortar_quake( "airfield_ambient_mortar_left", .21, 2, 10000 );
	maps\_mortar::set_mortar_chance( "airfield_ambient_mortar_left", .8 );
	
	maps\_mortar::set_mortar_delays("airfield_ambient_mortar_right", 4, 4.75, 4.25, 5);
	maps\_mortar::set_mortar_range( "airfield_ambient_mortar_right", 1000, 40000 );
	maps\_mortar::set_mortar_damage( "airfield_ambient_mortar_right", 384, 50, 1000 );
	maps\_mortar::set_mortar_quake( "airfield_ambient_mortar_right", .21, 2, 10000 );
	maps\_mortar::set_mortar_chance( "airfield_ambient_mortar_right", .8 );
		
		
	level thread maps\_mortar::mortar_loop( "airfield_ambient_mortar", 6 );
	level thread maps\_mortar::mortar_loop( "airfield_ambient_mortar_right", 6 );
	level thread maps\_mortar::mortar_loop( "airfield_ambient_mortar_left", 6 );
}

ambient_airfield_aa_fire()
{	
	array = getstructarray("airfield_ambient_aa","targetname");
	for(i=0;i<array.size;i++)
	{
		playfx(level._effect["fx_ks_ambient_aa_flak"],array[i].origin);
	}	
}

spawn_static_vehicles()
{
	vehicles = spawn_vehicles_from_targetname("airfield_static_vehicles");
	//zpu's on runway
	spawn_vehicle_from_targetname ("runway_zpu1");
	spawn_vehicle_from_targetname ("runway_zpu2");
	spawn_vehicle_from_targetname ("hutch_truck");
	
	
	//2 ZPU's blocking runway when plane takes off
	spawn_vehicles_from_targetname("fuel_truck_zpu");
	
	
	
	wait(.10);
	
	flag_set ("static_vehicles_spawned");
}

spawn_planes()
{
	flag_wait("all_players_spawned");
	
	level endon("stop_airfield_planes");
			
	nodes = GetVehicleNodeArray("airfield_bombing_paths","targetname");
	maps\_plane_weapons::build_bombs( "plane_mig17_gear", "aircraft_bomb", "explosions/fx_mortarExp_dirt", "artillery_explosion" );
	maps\_plane_weapons::build_bomb_explosions( "plane_mig17_gear", 0.5, 2.0, 1024, 768, 400, 25 );	
	x=0;
	times = randomintrange(20,30);
	while(1)
	{
		node = random(nodes);	
		plane = SpawnVehicle("t5_veh_jet_mig17_gear", "airfield_bomb", "plane_mig17_gear", node.origin, node.angles);

		plane.script_numbombs =  2;
		maps\_vehicle::vehicle_init(plane);
		plane thread plane_position_updater (5500, "evt_f4_long_wash", "null");  
		playfxontag( level._effect["jet_contrail"], plane, "tag_origin"); 
		plane thread go_path(node);
		for(i=0;i<times;i++)
		{
			wait(1);			
		}
		times = randomintrange(20,30);
		wait(.05);
	}
	
}

sugar_field_planes()
	
{
	flag_wait ("stop_sugarcane_nag_lines");
	node = GetVehicleNode ("sugar_field_flyover", "script_noteworthy");
	
	level endon ("rappel_started");
	
	while(1)
	{	
		plane = SpawnVehicle("t5_veh_jet_mig17_gear", "airfield_bomb", "plane_mig17_gear", node.origin, node.angles);

		plane.script_numbombs =  0;
		maps\_vehicle::vehicle_init(plane);
		plane thread plane_position_updater (5500, "evt_f4_long_wash", "null");  
		plane thread go_path(node);
		wait(RandomIntRange(5, 8) );
	}
}	


rail_bomber_timing()
{
	trigger_wait("rail_bombers");
	level thread do_rail_bombers(3);
}	
	

do_rail_bombers(num) //12 secs to runway from call
{
	//bombers visible while player is on rail 
	nodes = GetVehicleNodeArray("runway_visible_bombers","script_noteworthy");
	
	for (i = 0; i < num; i++ )
	{
		node = random (nodes);
		plane = SpawnVehicle("t5_veh_jet_mig17_gear", "airfield_bomb", "plane_mig17_gear", node.origin, node.angles);

		plane.script_numbombs =  0;
		maps\_vehicle::vehicle_init(plane);
		plane thread plane_position_updater (5500, "evt_f4_long_wash", "null");  
		plane thread go_path(node);
		wait(1);
	}	

}	

runway_jets()
{
	node = GetVehicleNode ("jet_takeoff", "script_noteworthy");
	while(!flag("rappel_started"))
	{
		do_a_jet(node, 5500,"evt_f4_long_wash");
		wait(RandomIntRange(20,25) );
	}	
	
	trigger_wait ("hangar2_physics_pulse"); //another one as player approaches runway
	level thread do_a_jet(node, 5500,"evt_f4_long_wash");
	
	trigger_wait ("tower_start");//turning the corner in the escape plane
	level thread do_a_jet(node, 5500,"evt_f4_long_wash");
	
	//visible jets when mason gets off plane
	flag_wait ("mason_deals");
	wait(3);
	node = GetVehicleNode ("final_zpu_jets", "script_noteworthy");
	jet1 = do_a_jet(node, 2500,"evt_f4_short_wash");
	jet1 veh_toggle_tread_fx(0);
	wait(1.5);
	jet2 = do_a_jet(node, 3500,"evt_f4_long_wash");
	jet2 veh_toggle_tread_fx(0);
	

}	

do_a_jet(node, updater_time, updater_alias)
{
	plane = SpawnVehicle("t5_veh_jet_mig17_gear", "airfield_bomb", "plane_mig17_gear", node.origin, node.angles);

	plane.script_numbombs =  0;
	maps\_vehicle::vehicle_init(plane);
	plane thread plane_position_updater (updater_time, updater_alias, "null");  
	plane thread go_path(node);
	playfxontag( level._effect["jet_contrail"], plane, "tag_origin"); 
	return plane;
	
}	

epic_sugarfield_jets()

{
	//the two jets that flyover players head and split apart at airfield reveal
	trigger_wait ("epic_sugarfield_flyover");
	node1 = GetVehicleNode ("epic_sugarfield_flyover_left", "targetname");
	node2 = GetVehicleNode ("epic_sugarfield_flyover_right", "targetname");
	level thread do_a_jet(node1, 1500, "evt_f4_short_wash");

	level thread do_a_jet(node2, 1500, "evt_f4_long_wash");
}	
	




//spawn_bombers()
//{
//	flag_wait("all_players_spawned");
//	nodes = GetVehicleNodeArray("airfield_ambient_bomber_paths","targetname");
//	
//	level endon("stop_airfield_bombers");
//		
//	while(1)
//	{
//		node = random(nodes);	
//		plane = SpawnVehicle("t5_veh_air_c130", "airfield_bomber", "plane_hercules", node.origin, node.angles);
//		maps\_vehicle::vehicle_init(plane);
//		plane thread go_path(node);
//		plane SetSpeedImmediate( randomintrange(110,150), 100 * .25,100 * .25);
//		nodes = array_remove(nodes,node);
//		if(nodes.size == 0)
//		{
//			nodes = GetVehicleNodeArray("airfield_ambient_bomber_paths","targetname");
//			wait(randomintrange(15,20));
//		}
//		else
//		{
//			wait(randomfloatrange(1,2));
//		}
//	}	
//}

spawn_jeeps_and_trucks()
{
	flag_wait("all_players_spawned");
	nodes = GetVehicleNodeArray("airfield_vehicle_paths","targetname");
	node = random(nodes);	
	
	level endon("stop_airfield_trucks");
	
	while(1)
	{
		trucks = GetEntArray ("airfield_vehicle", "targetname");
		
		if(IsDefined(trucks) && trucks.size <= 3)
		{
			if(randomint(100) >50)
			{
				truck1 = SpawnVehicle("t5_veh_truck_gaz63", "airfield_vehicle", "truck_gaz63_troops_bulletdamage", node.origin, node.angles);
			}
			else
			{
				truck1 = SpawnVehicle("t5_veh_truck_gaz63", "airfield_vehicle", "truck_gaz63_tanker", node.origin, node.angles);							 
			}
			maps\_vehicle::vehicle_init(truck1);
			truck1.drivepath = 1;		
			truck1 thread go_path(node);
			truck1 veh_magic_bullet_shield( 1 );	
		}
		wait(randomintrange(9,14));
	}
}
/*
setup_drone_FX()
{
	flag_wait("all_players_spawned");
	//level.drone_muzzleflash = level._effect["drone_muzzle_flash"];
}

setup_airfield_shrimps()
{
	trig = GetEnt ("start_airfield_scripts", "script_noteworthy");
	trig waittill ("trigger");
	level notify( "stop_low_bombers" ); //courtyard bombers from previous event
	exploder(901);
}	

*/
start_rappel()
{
	trig = getent("start_rappel","targetname");
	
	
	player = get_players()[0];
	//player SetClientDvar( "ammoCounterHide", "1" );
	//player_weapon = player GetCurrentWeapon();
	//Player SetWeaponAmmoStock(player_weapon, 0);
	
	wait_for_use_button_while_in_trigger(trig); //displays prompt as well
	
	//get_players()[0] SetLowReady(1);

	flag_set ("rappel_started");
	stop_airfield_vehicles(); //moving this here to avoid trucks and AI colliding on mortar run
	
	//remove the BTR from the road 
	btr = getent("sugarcane_btr","targetname");
	if(isDefined(btr))
	{
		btr delete();
	}
		
	trig delete();
	
	level notify("started_rappel");
	level thread hero_rappels_down("woods");
	level thread hero_rappels_down("bowman");
	wait(.3);
	level thread player_rappels_down();	

	wait(7);
	level notify("rappel_dialogue");
	
	//shrimps
	stop_exploder(901);
	
	level thread do_sprint_unlimited();
	
	//stop the trucks/jeeps at this point 
	wait(1);
	

}


wait_for_use_button_while_in_trigger(trigger)
{
	player = get_players()[0];
	
	while(1)
	{
		if(player IsTouching (trigger) )
		{
			player SetScriptHintString(&"CUBA_AIRFIELD_RAPPEL");				
			if(player use_button_held())
			{			
				player SetScriptHintString("");
				return;
			}	
		}	
		else
		{
			player SetScriptHintString("");
		}		
	 wait 0.05;	
	}

}

display_prompt_until_player_hits_attack()
{
	
	player = get_players()[0];
	screen_message = NewHudElem(); 
	screen_message.horzAlign = "center";
	screen_message.vertAlign = "middle";
	screen_message.alignX = "center"; 
	screen_message.alignY = "middle";
	screen_message.y = 20;
	screen_message.sort = 2;
	screen_message.font = "small";
	screen_message.fontscale = 1.7;
	screen_message.color = ( 1, 1, 1 );
	screen_message.alpha = 1;
	screen_message SetText(&"CUBA_ZPU_FIRE");	
	
	while(1)
	{			
		if (player AttackButtonPressed() )
		{			
			screen_message Destroy();
			return;
		}	
		wait(.05);
	}	

}

hero_rappels_down(hero)
{
	guy = get_hero_by_name(hero);
	
	anim_node = getstruct("rappel","targetname");
		
	if(hero == "woods")
	{
		rope = level.woods_rope;	
		anim_node anim_single_aligned(array(rope,guy),"forward_rappel");		
	}
	else if( hero == "bowman")
	{
		rope = level.bowman_rope;
		anim_node anim_single_aligned(array(rope,guy),"forward_rappel");
	}

	trace_start = guy.origin + (0,0,100);
	trace_end = guy.origin + (0,0,-100);
	ground_trace = BulletTrace(trace_start, trace_end, false, guy);

	if (guy.origin[2] < ground_trace["position"][2])
	{
		PrintLn("forward rappel teleport hacking!");
		guy forceteleport(ground_trace["position"], guy.angles);
	}
	
	self.moveplaybackrate = 1.4;
}

/*------------------------------------
player forward-rappels down the cliffside
and into the airfield battle

TODO- actually add the rappeling
once we get anim support
------------------------------------*/

spawn_rappel_hands()
{
	hands = spawn_anim_model("rappel_hands");
	hands Hide();
	level thread show_rappel_hands(hands);
	return hands;
}

show_rappel_hands(hands)
{
	wait .1;
	hands Show();
}

player_rappels_down()
{
	
	//stop the axis drones from respawning in
	level notify("stop_axis_drones");
	
	anim_node = getstruct("rappel","targetname");
	
	player = get_players()[0];
	player AllowCrouch(0);
	player AllowProne(0);
	player SetStance ("stand");

	level.player_model = spawn_rappel_hands();	

	// take all the weapons from the player
	player DisableWeapons();
	
	// link the player to the model, no control until the intro animation is over
	player PlayerLinkToAbsolute( level.player_model, "tag_player" );

	flag_set( "airfield_forward_rappel_start" );
	
	anim_ents = array(level.player_model, level.player_rope);

	//blow up the palm tree
	level thread destroy_palmtree2b();

	// start intro animation
	level thread do_rappel_shake_and_rumble();
	player StartCameraTween(.25);
	
	//set the depth of field for the rappel
	level thread set_rappel_dof(player,"forward_rappel");	
	level thread shoot_bullets_at_rappel();	
	
	//rocks sliding down cliff as player rappels
	exploder(899);
	
	//ACTUAL RAPPEL ANIM HERE
	anim_node anim_single_aligned( anim_ents, "forward_rappel" );
		
	player SetDepthOfField( 0, 0, 0, 0,0,0 );
	player SetClientDvar( "r_dof_tweak", 0 );
		
	player Unlink();
	level.player_model delete();
	
	struct = getstruct("player_rappel_land", "targetname");
	player StartCameraTween(.25);
	player SetPlayerAngles(struct.angles);

	level notify("player_rappel_done");		
	player enableweapons();
	
	//magic bullet shield during mortar run
	player thread magic_bullet_shield();
	
	level.player_rope Delete();
	level.bowman_rope Delete();
	level.woods_rope  Delete();
	
	//link carlos to the plane for now
	level thread link_carlos_to_plane();
	
	level thread autosave_by_name("cuba_rappel_done");	
	
	flag_set ("rappel_finished");
	
	player AllowCrouch(1);
	player AllowProne(1);

	//Player SetLowReady(0);
}


player_rappel_land(guy)
{
	//notetrack for player landing off rappel
	player = get_players()[0];
	Earthquake( 2, .6, player.origin, 100 );
	rumble_for_time(.10, "artillery_rumble");
	//player PlayRumbleOnEntity("explosion_generic");
	//IPrintLn("land");
	level thread Spawn_vignette_guys();

}	

Spawn_vignette_guys()
{
	simple_spawn_single("hangar_signal_guy", ::hangar_signal_guy_logic);
	simple_spawn_single("crater_guy", ::crater_guy_logic);
	simple_spawn_single("hangar_guy2", ::hangar_guy2_logic);
	simple_spawn_single ("hangar_runner");
	
}	



spawn_a_rope(start, end)
{
	amount = Distance (start.origin, end.origin); 
	//end_ent = Spawn( "script_model", end.origin );
	//end_ent SetModel( "tag_origin" );
	
	rope = CreateRope(start.origin, end.origin, amount +10);
	ropesetflag(rope, "collide", 1 );
	//end_ent PhysicsLaunch (end_ent.origin, (0,0,0) );
	
	wait(.05);
	RopeRemoveAnchor(rope, 1);
}	



/*------------------------------------
depth of field settings for the rappel sequence
------------------------------------*/
set_rappel_dof(player,anim_name)
{
	wait(3);
	maps\createart\cuba_art::set_cuba_dof("forward_rappel");
}

/*------------------------------------
rough pass on the camera shake & rumble during the rappel
------------------------------------*/
do_rappel_shake_and_rumble()
{
	time = getanimlength(level.scr_anim["rappel_hands"]["forward_rappel"] );
	time = time -2;	
	player = get_players()[0];
	timer = gettime()+(time*1000);	
	wait(2.5);
	while(gettime()<timer)
	{
		if(randomint(100)>60)
		{
			Earthquake( .35, .5, player.origin, 500 );
		}
		
		if(randomint(100) < 90)
		{
			player PlayRumbleOnEntity("damage_heavy");
		}
		wait( 0.1 );
	}
}


stop_airfield_vehicles()
{
	level notify("stop_airfield_planes");	
	level notify("stop_airfield_trucks");
}


/*------------------------------------
sets some initial states for the event
------------------------------------*/
wait_for_player_to_approach_airfield()
{
	//turn off rappel trigger
	trig = getent("start_rappel","targetname");
	trig trigger_off();
	
	ClearAllCorpses();
	
	level thread do_airfield_dialogue();	

	level waittill("airfield_dlg_done");
	
	//Kick off the engine sounds on the plane for the rail.
	level thread startup_plane_sounds();
	level thread play_plane_flyaway_sound();
	
	level thread start_rappel();
	trig trigger_on();	
	
	//monitor for the player and squad to reach the plane 
	level thread wait_for_player_to_reach_plane();
	level thread wait_for_ai_to_reach_plane();
	
	//drop hangar physics objects as player nears
	level thread rumble_hangars();	
}

rumble_hangars()
{
	trigger_wait("hangar2_physics_pulse");
	player = get_players()[0];	
	spot = getstruct("hangar2_physics_pulse","targetname");
	playfx(level._effect["airfield_ambient_mortar"],spot.origin);
	Earthquake( .45, 3, spot.origin, 1024 ); 
 	playsoundatposition("exp_mortar_dirt", spot.origin);	
	level thread maps\_mortar::mortar_rumble_on_all_players("damage_light","damage_heavy", spot.origin, 2048 * 0.75, 2048 * 1.25);		
	PhysicsExplosionSphere( spot.origin, spot.radius, spot.radius, .3 );
	
}

do_burning_death(spot)
{
	ai = getaiarray("axis");
	for(i=0;i<ai.size;i++)
	{
		if(distance(ai[i].origin,spot) < 850)
		{
			ai[i] thread burning_death();
		}
	}
}

burning_death()
{
	wait(RandomFloatRange(.2,.5) );

	if (is_mature())
	{
		PlayFxOnTag(level._effect["ai_fire"], self, "tag_origin");
		self starttanning();
		self.deathAnim = random(level.scr_anim["fire_death"]);
	}

	self dodamage(self.health *2,self.origin);
}

do_airfield_dialogue()
{
	woods = get_hero_by_name("woods");
	bowman = get_hero_by_name("bowman");
	carlos = get_hero_by_name("carlos");
	mason  = get_players()[0];
	mason.animname = "mason";

	anim_single(woods,"theres_airfield");//There's the airfield.
	anim_single(bowman,"carlos_secured");//Let's hope Carlos secured that evac.
	anim_single(woods,"aint_let_us_down"); //He ain't let us down yet.
	
	//trigger_wait("start_airfield_dialogue");
	trig = GetEnt("start_airfield_dialogue", "targetname");
	if (IsDefined(trig))
	{
		trig waittill("trigger");
	}
	
	anim_single(bowman,"rebels_asses_kicked");//Looks like the Rebels are getting their asses kicked!
	
	//blow up hangar 0
	exploder(910);
	
	level.hangar_0_bad show();
	level.hangar_0_good delete();
	
	//blow up plane
	
	
	anim_single(woods,"hook_up"); //Better get down there - Hook up...
	level notify("airfield_dlg_done");
	flag_wait ("rappel_started");
	wait(RandomFloatRange(1.5, 2.2) );
	anim_single(woods,"hook_up_go"); //Go!
	
	
	level waittill("rappel_dialogue");
	
	anim_single(carlos,"falling_apart");//Woods!  It's all falling apart...  You need to get out of here!
	anim_single(woods,"did_secure_transport");//You secure our transport?
	anim_single(carlos,"plane_ready"); //The plane is ready... but we'll be torn to pieces on take off!
	
	anim_single(woods,"one_thing");//On thing at a time, brother.
	
	anim_single(woods,"escape_nag0"); //We're leaving... Move!		
	level thread do_sprint_hint();
	
	level.carlos_nag_lines = array ("escape_nag1","escape_nag2","escape_nag3","escape_nag4");
		
	level thread do_vo_nag_loop( "carlos", level.carlos_nag_lines, "player_in_plane", 7 );
	
	flag_wait("player_in_plane");

	
	wait(4);
	anim_single(woods,"give_cover");//Give us cover, Mason!
	//anim_single(woods,"keep_in_one_piece");//We need to keep this plane in one piece!
	
	
	flag_wait ("zpus_start");
	//woods thread maps\_anim::anim_single_queue(woods, "zpus" );
	
	
	trigger_wait("blow_up_hangar4");	
	anim_single(bowman,"we_got_problem");//Woods! We got a problem!
	anim_single(bowman,"vehicles_blocking");//Those fucking vehicles are blocking the runway!
	anim_single(mason,"I_hear_you");
	anim_single(woods,"not_enough_room");//There's not gonna be enough room to take off!
	
	//flag_set ("mason_deals"); <= set by brush trig on runway now.
	
	level notify ("mason_out");
	
	anim_single (mason,"deal_with_it"); //I'll deal with it! 
	
	wait(1);
	anim_single(woods,"chew_you_up");//Mason are you crazy? They'll chew you up out there!
	anim_single(woods,"what_are_doing"); //Mason!  What are you doing?!!!
	anim_single(woods,"mason_no"); //Mason!!!!

	flag_wait ("truck_exploded");
	wait(2);
	anim_single(mason, "runways_clear");
	anim_single(woods,"dam_you");
	wait(1.5);
	anim_single(mason, "no_choice");
	anim_single(mason, "ill_be_fine");
	wait(1);
	flag_set("runway_vo_complete");
	


	
	level waittill("capture_dialoge",guys);
	guys[0].animname = "castro";
	guys[1].animname = "dragovich";
	anim_single(mason,"we_killed_you");
	anim_single(guys[0],"no_killed_double");
	anim_single(guys[1],"we_always_know");
	wait(1);
	anim_single(guys[0],"do_as_you_wish");
	anim_single(guys[0],"make_him_suffer");
	wait(.5);
	anim_single(guys[1],"he_will_suffer");
	wait(.5);
	anim_single(guys[1],"i_have_plans");
	wait(1);
	level notify("capture_dlg_done");			
}

set_hero_run_anim()
{
	if(self.animname == "woods")
	{
		if(randomint(100)>50)
		{
			self set_generic_run_anim( "sprint_patrol_1");
		}
		else
		{
			self set_generic_run_anim( "sprint_patrol_2");
		}
	}
	else if(self.animname == "bowman")
	{
		if(randomint(100)>50)
		{
			self set_generic_run_anim( "sprint_patrol_3");
		}
		else
		{
			self set_generic_run_anim( "sprint_patrol_4");
		}
	}
	self.noDodgeMove = true;
}

wait_for_ai_to_reach_plane()
{
	trig = getent("ac130_escape_trig","targetname");
	player = get_players()[0];
	carlos = get_hero_by_name("carlos");
	while(!flag("player_in_plane"))
	{
		trig waittill("trigger",who);
		if(who != player && who != carlos)
		{
			if(who.animname == "woods")
			{
				flag_set("woods_on_plane");			
			}
			//IPrintLnBold ("bowman on plane?");
			level thread link_ai_to_plane(who);
		}
	}
		
	trig delete();	
}

wait_for_player_to_reach_plane()
{
	trig = GetEnt ("ac130_escape_trig_player", "targetname");
	plane = GetEnt ("ac130_escape", "targetname");
	trig EnableLinkTo();
	trig LinkTo (plane);
	
	trigger_wait("ac130_escape_trig_player");
	
	level notify("stop_player_mortar_run");
	flag_set("player_in_plane");
	clientNotify ("in_plane");
	//TUEY set music state to PLANE_ESCAPE
	level thread maps\_audio::switch_music_wait("PLANE_ESCAPE", 2);
	
	//adjust the mortars		
	maps\_mortar::set_mortar_range( "airfield_ambient_mortar", 5000, 40000 );
	maps\_mortar::set_mortar_range( "airfield_ambient_mortar_left", 5000, 40000 );
	maps\_mortar::set_mortar_range( "airfield_ambient_mortar_right", 5000, 40000 );	
	maps\_mortar::set_mortar_chance( "airfield_ambient_mortar", .8 );
	maps\_mortar::set_mortar_chance( "airfield_ambient_mortar_left", .8 );
	maps\_mortar::set_mortar_chance( "airfield_ambient_mortar_right", .8 );	
	maps\_mortar::set_mortar_quake( "airfield_ambient_mortar", .16, 1.5, 10000 );
	maps\_mortar::set_mortar_quake( "airfield_ambient_mortar_left", .16, 1.5, 10000 );
	maps\_mortar::set_mortar_quake( "airfield_ambient_mortar_right", .16, 1.5, 10000 );
	
	level thread link_player_to_plane();
	level thread drop_mortars_on_plane_ride();
	
	wait(1);
	
	//spawn in the first group of guys who rush the player
	spawners = getentarray("rail_enemy_group0","targetname");		
	//simple_spawn("rail_enemy_group0",::spawnfunc_player_rusher);
	simple_spawn("rail_enemy_group0", ::player_seek_no_cover);
	array_delete(spawners);
	spawners = undefined;	
	
	
	//level thread nearby_guys_rush_plane();
	wait(9);
	trigger_use("spawn_troops_truck1");

}

player_seek_no_cover( alt_target, delay )
{
	self.noDodgeMove = 1;
	self.moveplaybackrate = ( RandomFloatRange(1,2) );
	if(IsDefined(self.target))
	{
		return;
	}
	
	if(IsDefined(delay))
	{
		wait(delay);
	}
	
	self endon("death");
	
	//ignore suppression so that this AI can charge the player
	self.ignoresuppression = 1;

	player = get_players()[0];
	min_dist = 300;
	max_dist = 600;
	while(1)
	{
		dist = RandomIntRange(min_dist, max_dist);
		// set the goal entity
		self SetGoalEntity( player );
		self set_goalradius( 12 );
		
		while(!self CanSee( player )||(DistanceSquared(self.origin, player.origin) > dist*dist)  )
		{
			wait(0.15);
		}
		
		self SetGoalPos(self.origin);
		self set_goalradius( 128 );
		time = 0;
		max_time = RandomFloatRange(1,4);
		while(self CanSee( player ) && (time < max_time)) 
		{
			time += 0.15;
			wait(0.15);
		}
		max_dist = min_dist;
		
		min_dist = 120;
		if(min_dist == max_dist)
		{
			max_dist = min_dist+1;
		}	
	}

}


/*------------------------------------
guys near the plane as it taxi's out of the hangar
will run towards the player & attack
------------------------------------*/
nearby_guys_rush_plane()
{
	volume = getent("hangar1_volume","targetname");
	ai = getaiarray("axis");
	for(i=0;i<ai.size;i++)
	{
		if( ai[i] istouching(volume))
		{
			wait(1);
			ai[i] thread spawnfunc_player_rusher();
		}
	}	
}
/*
plane_takeoff_monitor()
{
	flag_wait ("woods_ai_on_board");
	flag_wait ("bowman_ai_on_board");
	flag_wait("carlos_ai_on_board");
	flag_set ("all_aboard");
		
}	*/

/*------------------------------------
links the AI to the plane 
------------------------------------*/
link_ai_to_plane(who)
{
	if(!isDefined(who.in_plane))
	{
		plane = getent("ac130_escape","targetname");		
		who.in_plane = true;		
		
		plane anim_reach_aligned(who,"get_on_plane");
		plane anim_single_aligned(who,"get_on_plane");

		flag_set(who.targetname+"_on_board");
		
		who Hide();
		
		node = getent("plane_" + who.animname + "_linkto","targetname");
		node linkto(plane);
		who forceteleport( node.origin,node.angles);
		who.ignoreme = true;
		who.ignoreall = true;
		who linkto(getent("plane_" + who.animname + "_linkto","targetname"));
	}
}

check_ai_onboard(plane)
{
	//checks if AI is on plane when player is.
	if(!flag("woods_ai_on_board"))
	{
		woods = get_hero_by_name("woods");
		woods thread warp_ai_to_plane(plane);
	}
	if(!flag("bowman_ai_on_board"))
	{
		bowman = get_hero_by_name("bowman");
		bowman thread warp_ai_to_plane(plane);
	}	
	
}	

warp_ai_to_plane(plane)
{
	//Forces AI on to plane
	node = getent("plane_" + self.animname + "_linkto","targetname");
	node linkto(plane);
	self forceteleport( node.origin,node.angles);
	self.ignoreme = true;
	self.ignoreall = true;
	self linkto(getent("plane_" + self.animname + "_linkto","targetname"));
	self Hide();
}	


link_carlos_to_plane()
{
	carlos = get_hero_by_name("carlos");	
	woods = get_hero_by_name("woods");
	player = get_players()[0];
	
	carlos thread magic_bullet_shield();
	
	plane = getent("ac130_escape","targetname");
	
	
	plane thread anim_loop_aligned(carlos,"wait_for_squad");
	
	while(1)
	{
		if(distancesquared(player.origin,carlos.origin) < 925*925)
		{
			break;
		}
		wait(.05);
	}
	carlos anim_stopanimscripted();
	plane anim_reach_aligned(carlos,"get_on_plane");
	plane anim_single_aligned(carlos,"get_on_plane");
	flag_set("carlos_ai_on_board");
	
	carlos Hide();

	getent("plane_carlos_linkto","targetname") linkto(getent("ac130_escape","targetname"));
	
	carlos forceteleport( getent("plane_carlos_linkto","targetname").origin,getent("plane_carlos_linkto","targetname").angles);
	
	carlos.ignoreme = true;
	carlos.ignoreall = true;
	carlos linkto(getent("plane_carlos_linkto","targetname"));
}



link_player_to_plane()
{
	autosave_by_name("cuba_on_plane");
	flag_set ("player_on_plane");
	
	level.ai_spots = GetEntArray ("ai_goto", "targetname");
	
	// take all the weapons from the player
	player = get_players()[0];
	player DisableWeapons();
	
	//delete some of the drones 
	level notify("stop_hangar_drones");
	
	time = GetAnimLength( level.scr_anim["player_hands"]["get_on_plane"]  ); 
	
	drones = getentarray("hangar_drones","script_noteworthy");
	if(drones.size > 0)
	{
		array_notify(drones,"death");
		array_delete(drones);
	}	
	
	//delete a few of the vehicle corpses
	getent("vehicle_blowup_left","script_noteworthy") delete();
	getent("vehicle_blowup_right","script_noteworthy") delete();
	
	spawn_manager_kill("ally_airfield_spawner");
	
	player = get_players()[0];
	node = getent("plane_player_linkto","targetname");
	plane = getent("ac130_escape","targetname");

	clip = getent("plane_clip","targetname");
	
	clip linkto(plane);
	
	for (i = 0; i < level.ai_spots.size; i++ )
	{
		level.ai_spots[i].radius = 128;
		level.ai_spots[i] LinkTo(plane);
	}
		
	node linkto(plane);	

	//link the dmg trig	
	dmg_trig = getent("plane_dmg_trig","targetname");
	dmg_trig enablelinkto();
	dmg_trig linkto(plane); 
	
	dmg_trig thread monitor_engine_damage();
	
	level.player_model = spawn_anim_model("player_hands", player.origin);
	level.player_model Hide();
	level.player_model.animname = "player_hands";
	
	// start intro animation
	plane thread anim_single_aligned( level.player_model, "get_on_plane" );
	
	wait(.05);
	
	// link the player to the model, no control until the intro animation is over
	player PlayerLinkToAbsolute( level.player_model, "tag_player" );
	
	plane waittill ("get_on_plane");
	
	level.player_model delete();
	
	player unlink();
	
	//moving ot node?
	Player StartCameraTween(.2);
	player lerp_player_view_to_position (node.origin, node.angles, .1, 1);
	
	//player setorigin(node.origin);	
	//Player SetPlayerAngles(node.angles);
	wait .05;		
	//linking to node?
	player playerlinktodelta(node,undefined,1,80,87,80,80);
	
	player.ignoreme = false;
	player stop_magic_bullet_shield();
	
	player TakeAllWeapons();

	player giveweapon("m60_explosive_sp");
	player givemaxammo("m60_explosive_sp");
	player switchtoweapon("m60_explosive_sp");
	
	//refilling ammo and hiding ammo counter
	level thread keep_max_ammo();
	
	player SetClientDvar( "ammoCounterHide", "1" ); 
	
	//making it a bit easier to move gun around
	SetSavedDvar( "aim_view_sensitivity_override", "1.3" );
	
	//Regulates damage to prevent damage hud from getting too large
	player.overridePlayerDamage = ::minigun_player_override;
	
	player enableweapons();
	
	player AllowSprint(false);
	
	//delete some dudes
	ai = get_ai_group_ai("axis_post_mortar_run");
	array_notify(ai,"death");
	array_delete(ai);

	plane = GetEnt ("ac130_escape", "targetname");
	
	esc_node = getvehiclenode("escape_plane_node","targetname");	
	plane thread go_path(esc_node);
	
	level thread check_ai_onboard(plane);
	
	level thread do_rail_bombers(3);
	
	wait(5);	
	//starts the mortars dropping in players view while on the plane
	level notify("start_plane_mortars");
	level thread blow_up_hangar_4();
	
	level thread spawn_50cal_attackers();
	
	spawn_manager_kill("post_airfield_axis");
	spawn_manager_kill("hangar2_allied_spawnmanager");
	spawn_manager_kill("axis_spawnmanager_1");
		
	trigger_wait ("final_runway_start");
	
	level thread player_captured();//Start streaming the AI that knocks player off AA gun

	trigger_wait("spawn_blocker_vehicles");	
	ai = get_ai_group_ai("axis_post_rail_north");
	array_notify(ai,"death");
	array_delete(ai);
	
	//KEY TIMING RIGHT HERE FOR ZPU ALIGNMENT
	
	flag_wait ("mason_deals");
	//player EnableInvulnerability();
	
	//turn off sensitivity tweak
	SetSavedDvar( "aim_view_sensitivity_override", "0" );
	
	player_model = spawn_anim_model("player_hands", node.origin);
	player_model.angles = node.angles;
	player_model linkto(node);
	player_model.animname = "player_hands";

	// take all the weapons from the player
	player DisableWeapons();	
	
	player startcameratween(.15);
	
	// link the player to the model, no control until the intro animation is over
	player PlayerLinkToAbsolute( player_model, "tag_player" );
	
	// start intro animation
	node anim_single( player_model, "launch" );		
	player Unlink();	
	player_model Delete();
	
	
	level thread random_gun_shots_behind_player();
	
	//begins streaming outro scene early
	level thread outro_scene();
	
	//switch back to pistol on eject
	player TakeWeapon("m60_explosive_sp");
	player GiveWeapon ("asp_sp");
	player SwitchToWeapon("asp_sp");
	
	player AllowSprint(true);
	player enableweapons();
	level notify("player_off_plane");	

	player SetMoveSpeedScale(1.5);
}


AA_gun_read()
{

	flag_wait ("mason_deals");
	
	wait(3);
	trigger_use ("late_fuel_trucks");
	level thread fuel_truck_rpgs();
	
}	


keep_max_ammo()
{
	level endon ("mason_deals");
	player = get_players()[0];	
	
	while(1)
	{
		player SetWeaponAmmoClip("m60_explosive_sp", 80);
		player SetWeaponAmmoStock("m60_explosive_sp", 0);
		wait(4);
	}	
		
}	
   
mortar_run_vehicles_blow_up()
{
	trigger_wait("blow_up_vehicles");
	
	left_vehicle = getent("vehicle_blowup_left","script_noteworthy");
	right_vehicle = getent("vehicle_blowup_right","script_noteworthy");
	
	playfx(level._effect["airfield_ambient_mortar"],left_vehicle.origin);
	left_vehicle notify("death");
	
	//flaming damaged plane flys by
	level thread mortar_run_flyby();
	
	wait(4);
	playfx(level._effect["airfield_ambient_mortar"],right_vehicle.origin);
	right_vehicle notify("death");
}


/*------------------------------------
guys attack the player for a bit, then die
------------------------------------*/
spawnfunc_player_rusher()
{
	
	self endon("death");
	self.noExplosiveDeathAnim = 1;
	// ignore suppression so that this AI can charge the player
	self.ignoresuppression = 1;
	self.goalradius = 300;
	
	// now keep reducing the goalradius so this ai comes closer to the player in stages
	while(1)
	{	
		if( self.goalradius > 100 )		
		{
			// keep reducing the goal distance
			self.goalradius = self.goalradius - RandomIntRange(20, 50);
			
			// modify the path enemy distance so that AI goes near the goal
			self.pathenemyFightdist = self.goalradius;
	
			// set the goal entity
			spot = random(level.ai_spots);
			self thread force_goal();
			self SetGoalPos( spot.origin ); //script_origin in front of player's pos. on plane
			wait(RandomIntRange(6,9));
		}
		else
		{
			self.goalradius = 300;
		}	
	}
}

/*------------------------------------
guys jump out of the truck, run to their goal, then delete
------------------------------------*/
spawnfunc_truck_riders_delete()
{
	self endon("death");
	self.goalradius = 64;
	self waittill("goal");
	self delete();	
}

/*------------------------------------
throws flaming ragdolls out of the hangars
when they explode
------------------------------------*/
spawnfunction_burning_guy()
{
	player = get_players()[0];
	self gun_remove();
	PlayFxOnTag(level._effect["ai_fire"], self, "tag_origin");
	self starttanning();
	self ragdoll_death();
	
	dir = (player.origin[0],player.origin[1],self.origin[2] + 50) - self.origin;				
	self launchragdoll(dir);
	
}

/*------------------------------------
the small little out of place looking wooden tower destructible in the runway
should be replaced by something appropriate
------------------------------------*/
blow_up_tower()
{
	wait(3.5);
	
	spot = getstruct("airfield_tower_damage","targetname");
	playfx(level._effect["airfield_ambient_mortar"],spot.origin);
	playsoundatposition ("exp_veh_large", spot.origin);
	Earthquake( .45, 3, spot.origin, 2048 ); 
	radiusdamage(spot.origin,500,500,500);
	
	/*
	wait(8);
	simple_spawn("rpg_guy1",::fire_rpg_at_plane);		
	wait(2);		
	simple_spawn("rpg_guy2",::fire_rpg_at_plane);	

	simple_spawn("hangar4_rushers",::spawnfunc_player_rusher);	
	*/
}


/*------------------------------------
blow up the hangar to the right of the player
------------------------------------*/
blow_up_hangar_1()
{
	wait(19);
	flag_set ("hangar1_blown");
	structs = getstructarray("hangar1_mortars","targetname");
	Earthquake( .35, 3, structs[0].origin, 3048 );
	simple_spawn("hangar1_burning_guys",::spawnfunction_burning_guy);
	exploder(920);
	level notify ("tree_palm_coco01_start");
	level.hangar_1_bad show();
	level.hangar_1_good delete();
	level thread do_burning_death(structs[0].origin);	
	playsoundatposition ("exp_veh_large", structs[0].origin);
	destroy_plane("hangar1_plane");
	PhysicsExplosionSphere( (747.5, 12039.5, -1096), 512, 512, 1.5);
	
	
	
}

hangar1_runner_logic()
{
	self endon ("death");
	self.goalradius = (RandomIntRange(100,300) );
	self set_spawner_targets ("hangar1_runner_nodes");
	self waittill ("goal");
	self thread kill_self();
	
}	
	
	

/*------------------------------------
hangar 2 is the hangar the player originally comes out of
------------------------------------*/

blow_up_hangar_2()
{
	wait(3.5);

	structs = getstructarray("hangar2_mortars","targetname");
	Earthquake( .45, 3, structs[0].origin, 3048 );
	exploder(930);
	playsoundatposition ("exp_veh_large", structs[0].origin);
	//level.hangar_2_bad show();
	//level.hangar_2_good delete();
	
	//destroy_plane("hangar2_plane");
	level notify ("tree_palm_coco02_start");
	blow_up_hangar_3();
	
}

blow_up_hangar_3()
{
	//this is hangar 3
	wait(4);
	exploder(940);
	playsoundatposition ("evt_bomb_distant", (4727.47, 8875.91, -1139.88));
	level notify ("tree_aquilaria_dest02_start");
	level.hangar_3_bad show();
	level.hangar_3_good delete();	
}


blow_up_hangar_4()
{
	//blow up the palm tree and damage the hangar as the player rolls by	
	trigger_wait("blow_up_hangar4");
	//tree = getent("palm_tree_hangar4","targetname");
	//playfx(level._effect["airfield_ambient_mortar"],tree.origin);
	//playsoundatposition ("exp_mortar_dirt", tree.origin);
	//Earthquake( .45, 3, tree.origin, 2048 ); 
	//tree moveto(	(7255.95, 10360.7, -1129.83),1.1);
	//tree rotateto( (34.0515, 57.5893, -83.9617),1);	
	wait(6);
	
	structs = getstructarray("hangar4_mortars","targetname");
	Earthquake( .45, 3, structs[0].origin, 3048 );
	exploder(950);
	playsoundatposition ("exp_veh_large", structs[0].origin);
	level.hangar_4_bad show();
	level.hangar_4_good delete();
	
	PhysicsExplosionSphere( (8821, 11374, -1113), 712, 712, 1.75);
	
}

spawn_50cal_attackers()
{
	
	wait(30);
	
	//delete all the guys in the first area by the hangar
	delete_all_touching("hangar1_volume");
	
	
	//spawn in the first truck w/the gunner
	//gaz_50cal1 = spawn_vehicles_from_targetname( "plane_rail_attacker1" )[0];
	//level thread setup_50cal( gaz_50cal1,"gaz_gunner1" );	
	
	level thread blow_up_tower();

	wait(4);	
	level thread blow_up_hangar_2();
	
	wait(11);
	
	//gaz_50cal2 = spawn_vehicles_from_targetname( "plane_rail_attacker2" )[0];
	//level thread setup_50cal( gaz_50cal2,"gaz_gunner2" );
}

plane_truck_gunner_logic(truck)
{
	self gun_remove();
	self.ignoreme = true;
	self.animname = "generic";
	self maps\_vehicle_aianim::vehicle_enter(truck, "tag_gunner1" );
	self.truck = truck;
	self.truck thread gunner_fire_at_player();
	self thread handle_truck_death();
}

start_mortar_run()
{
	
	//ambient stuff blows up as the player runs through the airfield
	level thread mortar_run_vehicles_blow_up();
	
	
	trigger_wait("start_mortar_run","targetname");		
	
	level notify ("runway_crate01_start");//animating tarps on crates
	
	//delete the trucks that are behind the hangar where the player entered
	truck = getent("airfield_truck2","targetname");
	if(IsDefined(truck) )
	{
		truck delete();
	}
	
	truck = getent("airfield_truck1","targetname");
	if(IsDefined(truck) )
	{
		truck delete();
	}
	
	//delete the AI who rode in on the jeeps originally
	ai = get_ai_group_ai("back_jeep_guys");
	array_notify(ai,"death");
	array_delete(ai);
	
	//start up the plane rotor fx
	level thread plane_prop_fx_timing();
	
	//fail conditions on the mortar run
	level thread fail_mortar_run();
	
	//mortars land in front of player as he's running
	level thread drop_mortars_in_front_of_player();
	
	//make random bodies fly past the player
	//level thread ragdoll_flies_past_player();
	
	//random rocket trails behind the player
	level thread random_rpg_trails_behind_player();
	
	//random bullet tracers going past the player
	level thread random_bullet_tracers();
	
	//stop the chaos ;)
	level thread stop_mortar_run();
	
}

plane_prop_fx_timing()
{
	plane = GetEnt ("ac130_escape", "targetname");
	
	//SOUND: 3 stages of propeler (and engine) speed here. We may want to have the engine rev higher as these increase?	
	
	//starting point
	plane Spawn_fx_on_temp_ent("tag_origin", "plane_prop_1");
	
	//first hangar blows at corner
	flag_wait ("player_on_plane");
	plane.fx_ent Delete();
	plane Spawn_fx_on_temp_ent("tag_origin", "plane_prop_2");
	
	//when AA guns start firing on straight-away
	trigger_wait ("zpus_start");
	plane.fx_ent Delete();
	plane Spawn_fx_on_temp_ent("tag_origin", "plane_prop_3");
	
}	

	
Spawn_fx_on_temp_ent(tag, fx_alias)
{
	//creates self.fx_ent (tag_origin model) to play FX on so it (and fx) can be deleted	
	//self = ent to play fx on
	
	//location to spawn ent at
	if(!IsDefined(tag))
	{
		tag = "tag_origin";
	}
	spot = self GetTagOrigin (tag);
	self.fx_ent = Spawn ("script_model", spot);
	self.fx_ent.angles = self.angles;
	self.fx_ent SetModel ("tag_origin");	
	self.fx_ent LinkTo (self, tag);
	//self.fx_ent thread Maps\cuba_escape::Print3d_on_ent("!");
	PlayFXOnTag(level._effect[fx_alias],self.fx_ent,"tag_origin");
	 
}		
	

fail_mortar_run()
{
	//fail by not running fast enough or not heading towards goal
	level thread monitor_player_mortar_run();
		
	trig = 	GetEnt ("fail_mortar_run", "targetname");
	trig thread mortar_fail_trig_logic();
	
	//trigger_wait("fail_mortar_run");
	//kill_player_with_mortar();
}

mortar_fail_trig_logic()
{
	//self = brush triggrs lining path to hangar to detect player going off course
	player = get_players()[0];
	level endon ("player_in_plane");
	warning_count = 0;
	
	while(1)
	{
		if(player isTouching(self))
		{				
			wait(2);
			if(player isTouching(self))
			{
				level thread run_mortar_fail_manager();
				wait(3);
			}
		}
		wait(.05);	
	}
}	
	
run_mortar_fail_manager()
{
	level endon ("player_failed_mortar_run");
	
	//wait here if this thread is already running
	while(flag("player_being_warned"))
	{
		wait(.5);
	}
	//announce this is being run
	flag_set ("player_being_warned");
	
	//if this is the first instance start the warning count at 1
	if(!IsDefined(level.warning_count))
	{
		 level.warning_count = 1;
	}
	//kill player on 3rd instance	 		
	if(level.warning_count >= 3)
	{
		kill_player_with_mortar();	
		flag_set ("player_failed_mortar_run");
		return;
	}	
	/*
	if(cointoss() )
	{
		screen_message_create (&"CUBA_AIRFIELD_WARNING1");	
	}
	else 
	{
		screen_message_create (&"CUBA_AIRFIELD_WARNING2");	
	}	
		
	//IPrintLn("Warning " +level.warning_count+ " of 3");
	wait(3);
	screen_message_delete();			
	*/
	wait(1);
	level.warning_count++;
	flag_clear("player_being_warned");
}	


kill_player_with_mortar()
{	
	if(flag("player_stunned"))
	{
		wait(2);
		return;
	}
	
	player = get_players()[0];
	
	SetDvar( "ui_deadquote", &"CUBA_FAIL_MORTAR" ); 	
	player stop_magic_bullet_shield();
	playfx(level._effect["airfield_ambient_mortar"],player.origin);
	Earthquake( .55, 3, player.origin, 500 ); 
	player dodamage(player.health +1000, player.origin);
	wait(1.5);
	missionFailedWrapper();	
}

drop_mortars_in_front_of_player()
{
	
	//stop the mortar chances
	maps\_mortar::set_mortar_chance( "airfield_ambient_mortar_right", 0 );
	maps\_mortar::set_mortar_chance( "airfield_ambient_mortar_left", 0 );
	maps\_mortar::set_mortar_chance( "airfield_ambient_mortar", 0 );
	
	maps\_mortar::set_mortar_damage( "airfield_ambient_mortar_right", 96, 100, 500 );
	maps\_mortar::set_mortar_damage( "airfield_ambient_mortar_left", 96, 100, 500 );
	maps\_mortar::set_mortar_damage( "airfield_ambient_mortar", 96, 100, 500 );


	for(i=0;i<level.spawners_to_delete.size;i++)
	{
		level.spawners_to_delete[i] delete();
	}	
	
	//level notify("stop_first_mortars");		
	
	level endon("stop_all_mortar_loops");
	level endon("stop_flinging");
	
	player = get_players()[0];
	radius = 2048;
	physRadius = 500;
	shocked = false;
	mortar_drops = 0;
	//player SetMoveSpeedScale(0.9);
	while(1)
	{
		spot = get_random_spot_in_player_view(450,600,100,150,"stop_mortar_run");
		ent = spawn("script_origin",spot);
		
		playfx(level._effect["airfield_ambient_mortar"],spot);
		Earthquake( .35, 2, spot, radius ); 
		ent playsound("exp_mortar_dirt","sounddone");	
		level thread maps\_mortar::mortar_rumble_on_all_players("damage_light","damage_heavy", spot, radius * 0.75, radius * 1.25);
		
		//nearby ai react to the mortar blast
		level thread nearby_ai_react_to_mortar(spot);
					
//		if(!shocked && mortar_drops > 1 )
//		{
//			shocked = true; 
//			level notify( "shell shock player", 3);
//			level.playerMortar = true; 		
//			maps\_shellshock::main( spot, 3);
//		}
		
		ent waittill("sounddone");
		ent delete();		
		mortar_drops ++;
		wait(randomfloat(6,9));
	}	
}
startup_plane_sounds()
{
	level.plane_damage = 0;
	level.plane_is_damaged = false;

	plane = getent("ac130_escape","targetname");	
	
	
	engine_1 = plane GetTagOrigin( "tag_engine1" );
	engine_2 = plane GetTagOrigin( "tag_engine2" );
	engine_3 = plane GetTagOrigin( "tag_engine3" );
	engine_4 = plane GetTagOrigin( "tag_engine4" );
	
	
	plane_engine = spawn ("script_origin", engine_1);
	plane_engine_2 = spawn ("script_origin", engine_2);
	plane_engine_3 = spawn ("script_origin", engine_3);
	plane_engine_4 = spawn ("script_origin", engine_4);
	
		
	plane_engine linkto(plane, "tag_engine1");
	plane_engine_2 linkto(plane, "tag_engine2");
	plane_engine_3 linkto(plane, "tag_engine3");
	plane_engine_3 linkto(plane, "tag_engine4");
	
	
	plane_engine playloopsound ("veh_plane_engine_no_damage");
	plane_engine_2 playloopsound ("veh_plane_engine_no_damage");
	plane_engine_3 playloopsound ("veh_plane_engine_no_damage");
	plane_engine_4 playloopsound ("veh_plane_engine_no_damage");
	
		
	while (1)
	{
		level waittill ("plane_taking_damage");
		playsoundatposition ("veh_plane_engine_hit", (0,0,0));
		level.plane_damage ++;
		if (level.plane_damage > 1 && (level.plane_is_damaged == false))
		{
			level.plane_is_damaged = true;
			plane_engine stoploopsound(1);
			plane_engine_2 stoploopsound(1);
			plane_engine_3 stoploopsound(1);
			plane_engine_4 stoploopsound(1);
				
			plane_engine playsound ("veh_plane_engine_damaged");
			plane_engine_2 playsound ("veh_plane_engine_damaged");
			plane_engine_3 playsound ("veh_plane_engine_damaged");
			plane_engine_4 playsound ("veh_plane_engine_damaged");
		
			wait(1.5);
			plane_engine playloopsound ("veh_plane_engine_no_damage");
			plane_engine_2 playloopsound ("veh_plane_engine_no_damage");
			plane_engine_3 playloopsound ("veh_plane_engine_no_damage");
			plane_engine_4 playloopsound ("veh_plane_engine_no_damage");
			level.plane_is_damaged = false;
			
		}			
		
	}
	
	
}
play_plane_flyaway_sound()
{
	level waittill ("mason_deals");
	
	plane = getent("ac130_escape","targetname");	
	plane_fly_away = spawn ("script_origin", plane.origin);
	plane_fly_away linkto(plane, "tag_origin");
	
	wait(2);
	//TEMP - move to origin later (TUEY)
	playsoundatposition ("veh_plane_takeoff", (0,0,0));
	
}

monitor_engine_damage()
{
	//self = damage trig attached to plane
	//wait for player to get outside
	trigger_wait ("hangar1_middle_guys_spawner");
	level endon ("mason_deals");
	level.did_zpu_warning = 0;
	
	dmg = 0;
	plane = getent("ac130_escape","targetname");
	woods = get_hero_by_name ("woods");
	
	while(1)
	{	
		self waittill( "damage", amount, inflictor, direction, point, type, modelName, tagName );
		//ignore player damage
		if(!IsPlayer(inflictor))
		{	
			//RPG DAMAGE FX/SOUND
			if( (type == "MOD_PROJECTILE_SPLASH")||(type == "MOD_PROJECTILE") ) //MOD_PISTOL_BULLET inflictor.turretweapon == "zpu_turret"?
			{		
				dmg++;
				level notify("plane_taking_damage");
							
				//IPrintLn ("plane hit " +dmg+ " times.");
				if(dmg > 6)
				{
					break;
				}
				if(dmg<=4) //we only have 4 levels of damage FX
				{
					playfxontag(level._effect["plane_dmg" + dmg],plane,"tag_origin");
				}
				Earthquake( .45, .7, get_players()[0].origin, 100 ); 	
				playsoundatposition ("veh_plane_engine_hit", (0,0,0));
					
				//VO FEEDBACK DELIGATION			
				//for tower RPG guys
				if( (IsDefined(inflictor.targetname))&&(inflictor.targetname == "tower_rpg_dudes_ai") )
				{					
					do_a_rpg_tower_damage_line();
				}	
				else
				{
					do_a_generic_plane_damage_line();
				}	
			}
			//ZPU damage
			else 
			{
				if( (IsDefined(inflictor.turretweapon) )&&(inflictor.turretweapon == "zpu_turret") ) 
				{
					//only do it once
					if(level.did_zpu_warning ==0)
					{
						woods thread maps\_anim::anim_single_queue( woods, "zpus" );
						level.did_zpu_warning =1;
					}	
				}	
			}	
		}
		wait(.05);			
	}
	/*
	SetDvar( "ui_deadquote", &"CUBA_FAIL_PROTECT"); 
	player = get_players()[0];
	player stop_magic_bullet_shield();
	player dodamage(player.health +1000,player.origin);
	missionFailedWrapper();	
	*/
}

do_a_generic_plane_damage_line()
{
	//self = level
	//establish the array of lines to use
	if(!IsDefined(level.plane_damage_lines))
	{
		level.plane_damage_lines = [];
		//Bowman
		level.plane_damage_lines[level.plane_damage_lines.size] ="trying_to_take_engines";
		level.plane_damage_lines[level.plane_damage_lines.size] ="without_fight";
		level.plane_damage_lines[level.plane_damage_lines.size] ="shit_takin_damage";
		level.plane_damage_lines[level.plane_damage_lines.size] ="barely_holding";
		//Woods
		level.plane_damage_lines[level.plane_damage_lines.size] ="mason_protect_plane";
		level.plane_damage_lines[level.plane_damage_lines.size] ="rpgs_tearing_us_up";
		level.plane_damage_lines[level.plane_damage_lines.size] ="cant_take_much_more";
		level.plane_damage_lines[level.plane_damage_lines.size] ="mason_rpg";
		level.plane_damage_lines[level.plane_damage_lines.size] ="were_getting_hit";
	}

	//and the used_lines array as well
	if(!IsDefined(level.used_plane_damage_lines))
	{
		level.used_plane_damage_lines = [];
	}	
	woods = get_hero_by_name ("woods");
	bowman = get_hero_by_name("bowman");
	
	wait(1);
	
	//if the damage is from the tower rpg guys
	mixed_lines = array_randomize( level.plane_damage_lines );
	random_line = random (mixed_lines);	
	//if it's a bowman line have bowman do it
	if( (random_line =="trying_to_take_engines")||(random_line =="without_fight")||(random_line =="shit_takin_damage")||(random_line =="barely_holding") )
	{
		bowman thread maps\_anim::anim_single_queue( bowman, random_line );
	}
	else
	{			
		//otherwise it's woods
		woods thread maps\_anim::anim_single_queue( woods, random_line );
	}	
		
	//Prevent lines in the source array from being repeated until we use them all
	//add current line to used array
	level.used_plane_damage_lines = add_to_array (level.used_plane_damage_lines, random_line );
	
	//remove the line from the lines array
	level.plane_damage_lines = array_remove (level.plane_damage_lines, random_line);
	
	//if we've used all the lines
	if(level.plane_damage_lines.size == 0)
	{
		//reset the array 
		level.plane_damage_lines = level.used_plane_damage_lines;
				
		//empty the used lines array
		level.used_plane_damage_lines = [];	
	}	
}	

do_a_rpg_tower_damage_line()
{
	//self = level
	//establish the array of lines to use
	if(!IsDefined(level.rpg_tower_damage_lines))
	{
		level.rpg_tower_damage_lines = [];
		//Bowman
		level.rpg_tower_damage_lines[level.rpg_tower_damage_lines.size] ="rpgs_tower";
		level.rpg_tower_damage_lines[level.rpg_tower_damage_lines.size] ="take_damned_rpgs";
		level.rpg_tower_damage_lines[level.rpg_tower_damage_lines.size] ="mason_take_rpgs";
	}
	//and the used_lines array as well
	if(!IsDefined(level.used_rpg_tower_damage_lines))
	{
		level.used_rpg_tower_damage_lines = [];
	}	
	woods = get_hero_by_name ("woods");
	wait(1);	
	//if the damage is from the tower rpg guys
	mixed_lines = array_randomize( level.rpg_tower_damage_lines );
	random_line = random (mixed_lines);	
	//if it's a bowman line have bowman do it
	
	//otherwise it's woods
	woods thread maps\_anim::anim_single_queue( woods, random_line );

	//Prevent lines in the source array from being repeated until we use them all
	//add current line to used array
	level.used_rpg_tower_damage_lines = add_to_array (level.used_rpg_tower_damage_lines, random_line );
	
	//remove the line from the lines array
	level.rpg_tower_damage_lines = array_remove (level.rpg_tower_damage_lines, random_line);
	
	//if we've used all the lines
	if(level.rpg_tower_damage_lines.size == 0)
	{
		//reset the array 
		level.rpg_tower_damage_lines = level.used_rpg_tower_damage_lines;
				
		//empty the used lines array
		level.used_rpg_tower_damage_lines = [];	
	}	
	
}	

monitor_gunner( truck )
{
	self.truck = truck;
	self waittill( "death" );

	self.truck ClearGunnerTarget();
	self.truck notify("gunner_dead");
	self.truck notify("death");
}

monitor_player_mortar_run()
{
	target = getent("ac130_escape_trig","targetname");
	player = get_players()[0];
	
	//level endon("player_mortar_fail");
	level endon("stop_player_mortar_run");
	
	while(!flag("player_in_plane") )	
	{
		dist = distance(player.origin,target.origin);
		if(flag("player_stunned"))
		{
			while(flag("player_stunned"))
			{
				wait(10);
			}
		}	
		else
		{			
			wait(1);
		}
		new_dist = distance(player.origin,target.origin);
		if(dist <= new_dist)
		{
			wait(1);
			dist = distance(player.origin,target.origin);
			wait(1);
			new_dist = distance(player.origin,target.origin);
			if( (dist <= new_dist)&&(!flag("player_stunned")) ) 
			{		
				level thread run_mortar_fail_manager();
			}
		}

	}		
}

stop_mortar_run()
{
	trigger_wait("end_mortar_run");
	level notify("stop_flinging");	
	
	//get_players()[0] SetMoveSpeedScale(1.1);
	
	//stop the drones from spawning in
	level notify("stop_allied_drones");
	wait(.05);
	
	//kill off allied drones
	drones = getentarray("drone","targetname");
	for(i=0;i<drones.size;i++)
	{
		if( drones[i].team != "axis" )
		{
			drones[i] notify("death");
			drones[i] delete();
		}
	}
			
	spawn_manager_kill("hangar2_allied_spawnmanager");
	//spawn_manager_kill("garage1_spawnmanager");
	//spawn_manager_kill("ai_mortar_run_sm");
	
	alive_ai = get_ai_group_ai("airfield_allied_ai");
	for(i=0;i<alive_ai.size;i++)
	{
		alive_ai[i] notify("death");
		alive_ai[i] delete();
	}
	
	
	
	//respawn axis drones
	//trigger_use("post_airfield_axis_drones","script_noteworthy");
	//trigger_use("post_airfield_axis");
	//trigger_use("post_airfield_axis1");		
}
/*
ragdoll_flies_past_player()
{
		
	level endon("stop_all_mortar_loops");
	level endon("stop_flinging");
	
	player = get_players()[0];		
	
	while(1)
	{
		wait(randomfloatrange(4.5,6.5));
		
		back = AnglesToForward( player.angles ) * -120;
		
		if( cointoss() )
		{
			side = AnglesToRight(player.angles) * 30;
		}
		else
		{
			side = AnglesToRight(player.angles)	 * - 30;
		}		
		
		point = player.origin + back + side;
		
		playfx(level._effect["airfield_ambient_mortar"],point);
		Earthquake( .45, 3, point, 1024 ); 							
		model = spawn("script_model",point);
		model playsound("exp_mortar_dirt","sounddone");	
		
		model thread fling_body(point,player,side);
		if( cointoss() )
		{
			wait(randomfloatrange(.1,1));
			model = spawn("script_model",point + ( randomintrange(30,60),randomintrange(30,60),randomintrange(5,10)));
			model thread fling_body(point,player,side);
		}
	}	
}
*/
random_rpg_trails_behind_player()
{
	level endon("stop_flinging");	
	player = get_players()[0];		
	
	while(1)
	{
		wait(randomfloatrange(4.5,6.5));
		
		back = AnglesToForward( player.angles ) * -120;
		
		if( cointoss() )
		{
			side = AnglesToRight(player.angles) * 50;
		}
		else
		{
			side = AnglesToRight(player.angles)	 * - 50;
		}		
		
		point = player.origin + back + side + (0,0,40);

		MagicBullet( "rpg_magic_bullet_sp", point, player.origin + (0,0,45) + anglestoforward(player.angles) * 100 );
	}	
}

random_gun_shots_behind_player()
{
	level endon("player_on_aa_gun");	
	player = get_players()[0];		
	
	wait(2);
	
	while(1)
	{
		front =  AnglesToForward( player.angles ) * 120;
		back = AnglesToForward( player.angles ) * -120;
		
		if( cointoss() )
		{
			side = AnglesToRight(player.angles) * 50;
		}
		else
		{
			side = AnglesToRight(player.angles)	 * - 50;
		}		
		
		point = player.origin + back + side + (0,0,40);

		MagicBullet( "fnfal_sp", point, front );
		
		wait(RandomFloatRange(.02,.6));
	}	
}

random_bullet_tracers()
{
	level endon("stop_flinging");	
	player = get_players()[0];		
	
	while(1)
	{
		wait(randomfloatrange(.15,1));
		
		back = AnglesToForward( player.angles ) * -120;
		
		if( cointoss() )
		{
			side = AnglesToRight(player.angles) * randomintrange(5,80);
		}
		else
		{
			side = AnglesToRight(player.angles)	 * randomintrange(5,80) * -1;
		}		
		
		point = player.origin + back + side + (0,0,40);
		bullettracer(point, player.origin + (0,0,45) + side + anglestoforward(player.angles) * 500,1) ;
		//MagicBullet( "rpg_magic_bullet_sp", point, player.origin + (0,0,45) + anglestoforward(player.angles) * 100 );
	}	
}



fling_body(point,player,side)
{
	
	self character\c_cub_rebels_3::main();
	
//TODO - need to add these back once proper gibbed characters come online for the cuban rebels
//	if(randomint(100) > 20)
//	{
//		if(randomint(100)>50)
//		{
//			self setmodel("c_rus_military_body3_g_torso");
//		}
//		else
//		{
//			 self setmodel("c_rus_military_body1_g_rarmoff");
//		}
//		if(randomint(100)>50)
//		{
//			self attach("c_rus_military_body1_g_lowclean");
//		}
//		else
//		{
//			self attach( "c_rus_military_body1_g_llegoff");
//		}
//	}
	
	self startragdoll(); 	
	
	//random chance to make the body fly diagonally across the view
	if( cointoss() )
	{
		side = side * -1;
	}
	
	launch_spot = player.origin + (0,0,100) + (AnglesToForward( player.angles ) * 50) + side;
	
	dir = launch_spot - point;
	
	self launchragdoll( dir );	
	wait(8);
	self delete();
	
}

#using_animtree("generic_human");
nearby_ai_react_to_mortar(point)
{
	anims = array(%run_pain_stomach, %run_pain_stumble);
	
	friends = getaiarray("allies");
	for(i=0;i<friends.size;i++)
	{		
		if(distancesquared(friends[i].origin,point) < 150 * 150 )
		{
			friends[i] animscripted("mortar_react",friends[i].origin,friends[i].angles,random(anims));
		}		
	}	
}

fling_ai(point)
{
	player = get_players()[0];
	ai = getaiarray();
	riders = get_ai_group_ai("50cal_riders");
	
	for(i=0;i<ai.size;i++)
	{
		if(isDefined(ai[i].magic_bullet_shield))
		{
			continue;
		}
		if(isDefined(ai[i].targetname) && issubstr( ai[i].targetname ,"rpg_guy"))
		{
			continue;
		}
		if(riders.size > 0)
		{
			if(ai[i] == riders[0] )
			{
				continue;
			}
		}
		if(distancesquared(ai[i].origin,point) < 384 * 384 )
		{
			rand = randomintrange(5,30);
			if( cointoss() )
			{
				side = AnglesToRight(player.angles) * rand ;
			}
			else
			{
				side = AnglesToRight(player.angles)	 * (rand * -1);
			}
						
			launch_spot = ai[i].origin + (0,0,100) + (AnglesToForward( player.angles ) * -180) ;
			
			dir = launch_spot - ai[i].origin;
						
			ai[i].deathFunction = ::special_death;
			
			ai[i].launch_dir = dir;
			ai[i] dodamage(ai[i].health + 10,ai[i].origin);
			
		}		
	}	
}


special_death()
{
		//self ragdoll_death();			
		if( IsDefined( self ) )
		{
			refs[0] = "guts";
			refs[1] = "right_arm"; 
			refs[2] = "left_arm"; 
			refs[3] = "right_leg"; 
			refs[4] = "left_leg"; 
			refs[5] = "no_legs";
			refs[6] = "head";
			self.a.gib_ref = refs[randomint(refs.size)];
			self animscripts\death::do_gib();
			
			self startragdoll();
			self launchragdoll(self.launch_dir);
		}
		
		return true;
}
/*
fling_drones(point)
{
	player = get_players()[0];
	drones = getentarray("drone","targetname");
	for(i=0;i<drones.size;i++)
	{
		if(distancesquared(drones[i].origin,point) < 384 * 384 )
		{
			rand = randomintrange(5,30);
			if( cointoss() )
			{
				side = AnglesToRight(player.angles) * rand ;
			}
			else
			{
				side = AnglesToRight(player.angles)	 * (rand * -1);
			}
						
			launch_spot = drones[i].origin + (0,0,100) + (AnglesToForward( player.angles ) * -180) ;
			
			dir = launch_spot - drones[i].origin;
			drones[i] notify("death");
			drones[i] startragdoll();
			drones[i] launchragdoll(dir);
		}		
	}	
}
*/
drop_mortars_on_plane_ride()
{

	level waittill("start_plane_mortars");
	level endon("player_off_plane");
	
	level thread blow_up_hangar_1();
	/*
	player = get_players()[0];
	radius = 2048;
	physRadius = 500;
	wait(8);
	while(1)
	{
		spot = get_random_spot_in_player_view(450,900,50,250,"stop_mortar_run");
		ent = spawn("script_origin",spot);
		
		playfx(level._effect["airfield_ambient_mortar"],spot);
		Earthquake( .15, 3, spot, radius ); 
		ent playsound("exp_mortar_dirt","sounddone");	
				
		level thread maps\_mortar::mortar_rumble_on_all_players("damage_light","damage_heavy", spot, radius * 0.75, radius * 1.25);
		
		level thread fling_ai(spot);	
		level thread fling_drones(spot);		
		wait(randomfloat(8,10));		
		ent delete();
	}
	
	*/
}


setup_50cal( truck,gunner,driver )
{
	truck thread go_path( GetVehicleNode(truck.target,"targetname") );
	
	//TODO -	handle the driver

	truck_gunner = simple_spawn_single (gunner, ::plane_truck_gunner_logic, truck);
	truck_gunner thread monitor_gunner(truck);
}

do_sprint_unlimited()
{

	//give unlimited sprint 
	get_players()[0]SetClientDvar("player_sprintUnlimited", 1);
	
	woods = get_hero_by_name("woods");
	bowman = get_hero_by_name("bowman");
	
	woods set_hero_run_anim();
	bowman set_hero_run_anim();

}

do_sprint_hint()
{
	//tell player to sprint
	//screen_message_create( "Press [{+breath_sprint}] to Sprint" );
	screen_message_create( &"CUBA_SPRINT_HINT" );
	
	while(1)
	{
		if( get_players()[0] issprinting( true ) || (flag("player_on_plane")))
		{
			screen_message_delete();
			break;
		}
		else
		{
			wait .5;		
		}	
	}
}

/*------------------------------------

------------------------------------*/
handle_truck_death()
{

	self waittill ("death");
	if(!isDefined(self))
	{
		return;
	}
	playfxontag (level._effect["vehicle_explosion"], self, "tag_origin");
	playsoundatposition ("exp_veh_large", self.origin);
	level spawn_vehicle_gibs(self);
}

spawn_vehicle_gibs(vehicle)
{
	vehicle_gib=[];
	vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_tire_low");
	vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_tire_low");
	vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_door_dest");
	vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_door_dest");
	vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_bumper_dest");
	vehicle_gib[vehicle_gib.size] =("t5_veh_gaz66_bumper_dest");

	up = AnglesToUp(vehicle.angles);
	velocity_up = Vector_Scale (up, 500);

	for (i = 0; i < vehicle_gib.size; i++ )
	{
		x= RandomFloatRange (10,180);
		gib = Spawn ("script_model", vehicle.origin +(0,0,80) );
		gib.angles = (x,x,x);
		gib SetModel (vehicle_gib[i]);
		gib PhysicsLaunch (gib.origin, velocity_up);
	}	
}	
		
gunner_fire_at_player()
{
	self endon("death");
	self endon("gunner_dead");
	
	sound_ent = Spawn( "script_origin", self.origin );
	sound_ent LinkTo( self, "tag_gunner1" );
	self thread maps\cuba_escape::delete_gunner_sound_ent( sound_ent );
	
	//node = getvehiclenode(self.targetname + ("_gunner_fire"),"script_noteworthy");
	//node waittill("trigger");
	wait(5);
	player = get_players()[0];
	
	while(isdefined(player))
	{
		if (isdefined(player))
		{
			self SetGunnerTargetEnt(player, (RandomIntRange(-50, 50), RandomIntRange(-50, 50), RandomIntRange(-50, 50)));
			self waittill_notify_or_timeout("gunner_turret_on_target", 0.25);
			self fireGunnerWeapon();
			sound_ent PlayLoopSound( "wpn_50cal_fire_loop_npc" );
			wait(0.1);
		}
	}
}

/*------------------------------------
crashing plane that flys by the player during the mortar run
------------------------------------*/
mortar_run_flyby()
{
	wait(2);
	start_node = GetVehicleNode( "mortar_run_plane_start", "targetname" );	
	plane = SpawnVehicle("t5_veh_air_c130", "mortar_plane", "plane_hercules", start_node.origin, start_node.angles);
	plane veh_magic_bullet_shield( 1 );
	maps\_vehicle::vehicle_init(plane);
	plane thread go_path(start_node);
	plane thread setup_airfield_crashing_plane();
	//kevin adding plane flyby
	plane playsound( "evt_balcony_plane_flyby" );
}

setup_airfield_crashing_plane()
{
	PlayFXOnTag( level._effect["chopper_burning"], self, "tag_origin" );

	self waittill( "reached_end_node" );
	
	//kevin adding crash sound
	self playsound( "evt_balcony_plane_crash" );
	PlayFX( level._effect[ "darwins_vehicle_explosion" ], self.origin );
	self veh_magic_bullet_shield( 0 );
	self Delete();
}


/*------------------------------------
player gets the gun butt to the head after firing on the fuel trucks
------------------------------------*/
player_captured()
{
	
	
	basher2 = undefined;
	zpu = getent("player_zpu","targetname");
	kravchenko = simple_spawn_single("airfield_Kravchenko");
	kravchenko.animname = "basher2";
	kravchenko thread magic_bullet_shield();
	kravchenko set_ignoreall(true);
	kravchenko Hide();
	
	guys = simple_spawn("enemy_aagun_guys",::setup_enemy_aagun_guys);
	for(i=0;i<guys.size;i++)
	{	
		if(isDefined(guys[i].script_noteworthy) && guys[i].script_noteworthy =="basher")
		{
			guys[i].animname = guys[i].script_noteworthy;
			guys[i] thread magic_bullet_shield();
			basher2 = guys[i];			
		}
	}
	
	basher2 set_ignoreall(true);
	basher2 Hide();
	

	
	start_origin = GetStartOrigin (zpu.origin, zpu.angles, level.scr_anim["player_hands"] ["player_caught"] );
	start_angles = GetStartAngles (zpu.origin, zpu.angles, level.scr_anim["player_hands"] ["player_caught"] );
	
	stream_helper = createStreamerHint (start_origin, 1.0);
	
	anim_length = GetAnimLength( level.scr_anim["basher2"]["player_caught"] );
	
	//START ANIM HERE
	flag_wait("runway_vo_complete");
	
	//TUEY set music state to CAPTURED
	level thread maps\_audio::switch_music_wait("CAPTURED", 0.1);
	
	player_model = spawn_anim_model("player_hands",start_origin);
	player_model.angles = start_angles;
	player_model.animname = "player_hands";
	player_model Hide();
	
	stream_helper Delete();
	
	//eliminates the camera tween when "using" a vehicle
	SetSavedDvar ("cg_cameraVehicleExitTweenTime", "0");
	
	//take all the weapons from the player
	player = get_players()[0];
	player DisableWeapons();
	//player take_weapons();
	player HideViewModel();
	player freezecontrols(true);
		
	basher2 Show();
	kravchenko Show();
	
	ents = array(kravchenko,basher2,player_model);
		
	zpu thread anim_single_aligned( ents, "player_caught" );
	
	//doing a proper useBy to get player off instead of Unlink to prevent camera issues
	zpu MakeVehicleUsable();
	zpu UseBy( player);
	wait(.05);
	
	//player thread lerp_fov_overtime( 1, 65 );
	player StartCameraTween(.2);
	player PlayerLinkToAbsolute( player_model, "tag_player");
	player_model Show();
	
	wait(anim_length - 2);
	
	custom_fade_screen_out("black",.4);	
	
	//Tuey put this sound in later
	//iprintlnbold ("evt_captured");
	playsoundatposition ("evt_capture", (0,0,0));
	
	wait(5);	//KEY TIMING RIGHT HERE SOUND. Ambient sounds on docks, seagulls, boat, ocean, etc
	
	//TUEY set music to END LEVEL
	setmusicstate ("END_LEVEL");
	flag_set("start_outro");
	
}

player_caught_impact(guy)
{
	//NOTETRACK for impact of gun to players face
	player = get_players()[0];
	clientnotify( "endst" );
	Earthquake( .25, .15, player.origin, 500 ); 
	player PlayRumbleOnEntity("damage_heavy");

	level notify( "shell shock player", 3);
	maps\_shellshock::main( player.origin, 3);

 	setmusicstate("MUSIC_OFF");

}	
/*------------------------------------
force guys to fire at the plane engines
they die after 2 shots
------------------------------------*/
fire_rpg_at_plane()
{
	self endon("death");
	self endon("stop_firing_rpg");
	/*
	if(self.targetname =="tower_rpg_dudes_ai")
	{
		self.deathFunction=::passenger_death;
	}	
	*/
	self.ignoreall = true;
	self.ignoreme = true;
	
	self gun_switchto( self.secondaryweapon, "right");
	dmg_trig = getent("plane_dmg_trig","targetname");
	
	self thread aim_at_target (dmg_trig);
	plane = GetEnt ("ac130_escape", "targetname");		
	
	counter = 0;
	
	while(counter < 9)
	{
		// 50/50 chance of hitting damage trig (engine) or (harmless) shot at wheel
		if(cointoss() )
		{
			target = dmg_trig.origin;
		}
		else
		{
			target = 	plane GetTagOrigin ("tag_wheel_front");
		}	
		
		wait(randomfloatrange(5,7));
		spot = self GetTagOrigin("tag_flash");
		if (IsDefined(spot))
		{
			MagicBullet( "rpg_magic_bullet_sp", self GetTagOrigin("tag_flash"), target);
			self playsound ("wpn_rpg_fire_npc");
			counter++;
		}
		
	}
	self gun_switchto( self.primaryweapon, "right");
}


/*------------------------------------
player fails to blow up the trucks
------------------------------------*/
fail_takeoff()
{
	//fail logic begins when player is off plane
	flag_wait ("mason_deals");
	
	level endon("truck_exploded");
	trig = getent("fail_takeoff","targetname");
	plane = getent("ac130_escape","targetname");
	
	while(1)
	{
		if(plane istouching(trig))
		{
			break;
		}
		wait(.05);
	}

	if(!flag("truck_exploded")) //player completed objective
	{
		flag_set ("player_failed_clearing_runway");		
		plane thread plane_dest_fx();	
		if(!flag("player_shot_plane") )
		{
			SetDvar( "ui_deadquote", &"CUBA_FAIL_TAKEOFF"); 
		}	
		else 
		{
			SetDvar( "ui_deadquote", &"CUBA_PLAYER_SHOT_PLANE"); 
		}
		wait(1);
		missionfailedwrapper();		
	}
}

plane_dest_fx()

{
	//self = plane
	tags=[];
	tags[tags.size]="side_door_l_jnt"; 
	tags[tags.size]="tag_engine1";
	tags[tags.size]="tag_wheel_back_left";
	
	player = get_players()[0];
	
	array_randomize(tags);
	for (i = 0; i < tags.size; i++ )
	{
		playfxontag( level._effect["darwins_vehicle_explosion"], self, tags[i]); 
		Earthquake( .30, .50, player.origin, 100 );
		player PlayRumbleOnEntity("damage_heavy");
		
		playsoundatposition ("veh_plane_engine_hit", (0,0,0));
		wait(RandomFloatRange(.2,.4));
	}	
	playsoundatposition ("veh_plane_engine_hit", (0,0,0));
	playfxontag( level._effect["fail_explosion"], self, "tag_origin");
	
}	

minigun_player_override( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
		if( Isdefined( self.player_minigun_proximity_damage ) && self.player_minigun_proximity_damage )
		{
			self.minigun_last_damage_time = GetTime();
			return iDamage;
		}
			
				
		// take damage only if damage has never been taken before, or not taken for a while
		if( !IsDefined( self.minigun_last_damage_time ) 	|| 
		  ( IsDefined( self.minigun_last_damage_time ) && ( GetTime() > self.minigun_last_damage_time + level.player_minigun_invulnurablility_interval ) ) 
		  )
		  {
		  		// if player has enough health to take max damage
		  		if( self.health > level.player_minigun_max_damage )
		  		{
		  			self.minigun_last_damage_time = GetTime();
		  		  					  			
		  			// lower the damage if greater than max damage
		  			if( iDamage > level.player_minigun_max_damage )
		  				return level.player_minigun_max_damage;
		  			else
		  				return iDamage;
		  		}
		  }
		  
		  // if it gets here, then no damage
		  self EnableInvulnerability();
		  self thread disable_invulnerability_over_time( level.player_minigun_invulnurablility_interval / 1000 );
		  return 0;
}

disable_invulnerability_over_time( time ) // self = player
{
	self endon( "player_minigun_proximity_damage" );
	
	if( IsDefined( self.disable_invulnerability_thread_running ) )
		return;

	self.disable_invulnerability_thread_running = 1;
			
	wait( time );
		
	self DisableInvulnerability();
	self.disable_invulnerability_thread_running = undefined;
}

tower_destruction()
{
	trigger_wait ("tower_start");
	//wait(4);
	flag_set ("plane_turning_corner");
	exploder(902);
	level notify ("radar_tower_start");

}	

stun_player()
{	
	//Hutch crater!	
	crater_before = GetEnt ("mortor_hole_before_03", "targetname");
	crater_after = GetEnt ("mortor_hole_after_03", "targetname");
	
	trigger_wait("shock_player");
	wait(RandomFloatRange (1.5, 2.1));
	clientnotify( "stnd" );
	woods = get_hero_by_name("woods");
	flag_set("player_stunned");
	player = get_players()[0];
	//orig_angles = player GetPlayerAngles();
	
	//look_down = getstruct ("look_down", "targetname");
	
	//spot in front ofplayer
	vector_dir = AnglesToForward(player GetPlayerAngles() );
	vector_dir = Vector_Scale(vector_dir, 50);
	point = player.origin + vector_dir;
	
	playsoundatposition("exp_mortar", player.origin);	
	playfx(level._effect["airfield_ambient_mortar"],point);
	
	//player PlayRumbleOnEntity("damage_heavy");
	level thread rumble_for_time(2);
	//maps\_shellshock::main( player.origin, .2);
	player DisableWeapons();
	player ShellShock("explosion", 2.5);
	Earthquake( .25, .15, player.origin, 500 );
	
	player SetMoveSpeedScale(.2);
	player SetStance("crouch");
	//player startcameratween(.2);
	//player SetPlayerAngles (look_down.angles);
	//player SetLowReady(1);
	
	crater_before Hide();
	crater_after Show();
	
	wait(3);
	
	//player startcameratween(1);
	//player SetPlayerAngles (orig_angles);
	player EnableWeapons();
	player SetMoveSpeedScale(1.2);
	//player SetLowReady(0);
	clientnotify( "stndo" );
	flag_clear("player_stunned");
	
	SetSavedDvar("cg_aggressiveCullRadius", 0); //reseting this to 0 before we get on plane
}	

rumble_for_time(time, rumble_type)
{
	player = get_players()[0];
	level endon ("stop_timed_rumble");
	level thread rumble_timer(time);
	if(!IsDefined(rumble_type))
	{
		rumble_type = "damage_heavy";
	}	
	while(1)
	{
		player PlayRumbleOnEntity(rumble_type);
		wait(.05);
	}		
}		

rumble_timer(time)
{
	x = 0;
	while(x <= time )
	{
		wait(1);
		x++;
	}		
	level notify ("stop_timed_rumble");
}	

hangar1_ai_management()
{
	flag_wait ("player_on_plane");
	trigger_use ("hangar1_runners_spawner");
	flag_wait ("hangar1_blown");
	spawn_manager_kill ("hangar1_runners_spawner");
}	

background_trucks()
{
	flag_wait ("player_on_plane");
	node = GetVehicleNode ("background_truck_start", "script_noteworthy");
	
	while(!flag("hangar1_blown"))
	{
		Spawn_a_background_truck(node, 38, 40);
		wait(RandomIntRange (6,9) );	
	}	
	
	node = GetVehicleNode ("runway_backroad_truck_start", "script_noteworthy");
	while(!flag("mason_deals"))
	{
		Spawn_a_background_truck(node, 48, 50);
		wait(RandomIntRange (10,15) );	
	}	
	
}	


Spawn_a_background_truck(node, speedmin, speedmax)
{
	truck1 = SpawnVehicle("t5_veh_truck_gaz63", "airfield_fuel_truck", "truck_gaz63_tanker", node.origin, node.angles);
	maps\_vehicle::vehicle_init(truck1);
	truck1.drivepath = 1;		
	//truck1 veh_toggle_tread_fx(0);
	truck1 thread go_path(node);
	truck1.vehicleavoidance = 1;
	truck1 SetSpeed (RandomIntRange(speedmin,speedmax));
}	

runway_zpus()
{	
	trig = GetEnt ("zpus_start", "targetname");
	trig trigger_off();
	
	flag_wait ("static_vehicles_spawned");
	
	zpu1 = GetEnt ("runway_zpu1", "targetname");
	zpu1 thread veh_magic_bullet_shield(1);
	
	zpu2 = GetEnt ("runway_zpu2", "targetname");
	zpu2 thread veh_magic_bullet_shield(1);
	
	flag_wait ("player_on_plane");
	zpu1 thread setup_my_driver();
	zpu2 thread setup_my_driver();
	
	trigger_wait("final_runway_start");
	
	trig trigger_on();
	trig waittill ("trigger");
	flag_set ("zpus_start");

	zpu1 thread runway_zpu_aiming_logic();
	zpu1 thread veh_magic_bullet_shield(0);
	
	zpu2 thread runway_zpu_aiming_logic();
	zpu2 thread veh_magic_bullet_shield(0);
	
	//level thread give_player_rpg();
	/*
	player GiveWeapon ("rpg_player_sp");
	wait(1);
	player SwitchToWeapon("rpg_player_sp");
	*/
}		
		
setup_my_driver()
{
	//self = ZPU AA gun
	self.driver = simple_spawn_single ("zpu_guy");
	self.driver.health = 10;
	self.driver.animname = "aa_gunner_fire";
	self.driver gun_remove();
	
	driver_seat = self GetTagOrigin("tag_driver");
	driver_seat_angle = self GetTagAngles("tag_driver");

	self.driver LinkTo(self, "tag_driver", (0,0,0 ) );
	self thread anim_loop_aligned( self.driver, "fire", "tag_driver");
	self.driver.allowdeath = true;
	
	self.driver.AA_gun = self;
	self.driver.deathFunction = ::zpu_driver_deathfunction;
	
}			
		
zpu_driver_deathfunction()
{
	//self = AI on ZPU gun
	self.AA_gun notify ("driver_death");
	self ragdoll_death();

}			
		
		
runway_zpu_aiming_logic()
{
	//zpus in airfield event
	self endon("death");
	self endon("driver_death");
	level endon ("truck_exploded");
	plane = GetEnt ("ac130_escape", "targetname");
	dmg_trig = getent("plane_dmg_trig","targetname");
	
	if(self.targetname == "fuel_truck_zpu")
	{
		self thread steady_fire("truck_exploded");
	}
	else
	{
		self thread burst_fire( "wpn_50cal_fire_loop_npc" , "wpn_50cal_fire_loop_ring_npc" );
	}
		
	self thread die_from_rpg();

	while(1)
	{	
		if(cointoss() )
		{
			target = dmg_trig.origin;
		}
		else
		{
			target= plane GetTagOrigin ("geardoor_r_nose_jnt4");
		}
		self SetTurretTargetVec(target);
		wait(RandomFloatRange(.5,.8) );	
	}
	
}		

die_from_rpg()
{
	self endon ("death");
	while(1)
	{
		self waittill( "damage", amount, inflictor, direction, point, type, modelName, tagName );
		if( (type == "MOD_PROJECTILE_SPLASH")||(type == "MOD_PROJECTILE") )
		{		
			self notify ("death");
		}
	}
}		

/*
give_player_rpg()
{	
	plane = GetEnt ("ac130_escape", "targetname");
	player = get_players()[0];
	gun = Spawn ("weapon_rpg_player_sp", player.origin);
	gun LinkTo (plane);
	
	while(!player HasWeapon("rpg_player_sp"))
	{
		wait(0.1);
	}
	
	player GiveMaxAmmo("rpg_player_sp");
	
}		
*/
steve_cleanup()
{
	flag_wait ("player_on_plane");
	wait(1);
	//delete all cuban friendlies
	allies = GetAIArray("allies");
	for (i = 0; i < allies.size; i++ )
	{
		if(IsSubStr(allies[i].classname, "actor_CU_a"))
		{
			allies[i] die();
			allies[i] Delete();
		}
	}
			
	trigger_wait ("final_runway_start");
	guys = GetEntArray ("rail_enemy_group0_ai", "targetname");
	truck_guys = GetEntArray ("troops_truck1_guys_ai", "targetname");
	more_guys = array_combine (truck_guys, guys);	
	hangar1_middle_guys = GetEntArray ("hangar1_middle_guys_ai", "targetname");
	all_guys = array_combine (more_guys, hangar1_middle_guys);
	
	array_thread (all_guys, ::self_delete);
	
	//sandbag runway guys
	trigger_wait ("zpus_start");
	guys = GetEntArray("runway_sandbag_dudes_ai", "targetname");
	array_thread (guys, ::self_delete);

	flag_wait ("player_on_aa_gun");
	spawn_manager_kill("misc_rail_guys_spawner");
	spawn_manager_kill("middle_island_guys_spawner");
	
	guys = GetEntArray ("rail_tent_guys_ai", "targetname");
	truck_guys = GetEntArray ("misc_rail_guys_ai", "targetname");

	almost_all_guys = array_combine (truck_guys, guys);
	
	middle_island_guys = GetEntArray ("middle_island_guys_ai", "targetname");
	
	all_guys = array_combine(middle_island_guys, almost_all_guys);
	
	array_thread (all_guys, ::self_delete);
	
	//delete all baddies final cutscene
	flag_wait ("cuba_end_script_started");
	
	wait(4);
	//IPrintLnBold ("deleting axis");
	axis = GetAIArray("axis");
	for (i = 0; i < axis.size; i++ )
	{
		if(IsSubStr(axis[i].classname, "actor_CU_e"))
		{
			axis[i] Delete();
		}
	}		
	
}	

rail_enemy_spawn_logic()
{
	trig = GetEnt ("hangar1_middle_guys_spawner", "targetname");
	trig trigger_off();
	flag_wait ("player_on_plane");
	trig trigger_on();
	
	trigger_wait ("tower_start");
	trigger_use ("runway_sandbag_dudes_spawner");
	trigger_use ("misc_rail_guys_spawner");
	
	trigger_wait("final_runway_start");
	
	simple_spawn ("tower_rpg_dudes", ::fire_rpg_at_plane);

	trigger_use("middle_island_guys_spawner");
	
	flag_wait ("player_on_aa_gun");
	trigger_use("fuel_truck_runners_spawner");
	
	
}	


fuel_truck_runner_logic()
{
	self endon ("death");
	self thread make_oblivious();
	self.dieQuietly = true;
	//self thread run_shoot_logic();
	
	if(cointoss() )
	{
		self set_generic_run_anim( "sprint_patrol_1");
	}
	else
	{
		self set_generic_run_anim( "sprint_patrol_2");
	}
	
	flag_wait ("truck_exploded");
	wait(RandomFloat(1) );
	
	if (cointoss() )
	{
		self AnimCustom(Maps\cuba_escape::building_hit_anim);
	}
	else
	{
		self die();
	}

}	

run_shoot_logic()
{
	wait(1);
	self endon ("truck_exploded");
	while(IsDefined(self))
	{
		plane = GetEnt ("ac130_escape", "targetname");
		MagicBullet("fnfal_sp", self GetTagOrigin("tag_flash"), plane.origin);
		BulletTracer(self GetTagOrigin("tag_flash").origin, plane.origin);
		wait(RandomFloatRange(.1,.3));
	}	
	
}	

hangar1_middle_guys_logic()
{
	
	self endon ("death");
	self.noExplosiveDeathAnim = 1;
	if(cointoss() )
	{
		self.script_radius = 32;
		self set_spawner_targets ("hangar1_middle_guys");
	}
	else
	{
		self.disablemelee = 1;
		self.script_radius = RandomIntRange(90,150);
		self SetGoalEntity( get_players()[0] );
		self thread force_goal();
	}
}	
			
shoot_bullets_at_rappel()
{	
	wait(2.5);
	count = 1;
	from = getstruct ("mg_bullet_gun", "targetname");
	num = RandomIntRange(2,3);
	while(count<=4)
	{
		for( i=0; i < num; i++ ) 
		{
			target = getstruct ("mg_bullet_target"+count, "targetname");
			Shoot_magic_bullets("fnfal_sp", from, target);
			wait(.2);
		}	
		count++;
		wait(.3);
	}

}	

Shoot_magic_bullets(weapon, from, target)
{
	MagicBullet(weapon, from.origin, target.origin);
	BulletTracer(from.origin, target.origin);
	//level thread draw_line_for_time (from.origin, target.origin, 1,0,0, 1);
	
}		
		
fuel_truck_zpus()
{
	flag_wait ("mason_deals");
	guns = GetEntArray ("fuel_truck_zpu", "targetname");
	array_thread (guns, ::runway_zpu_aiming_logic);
	array_thread (guns, ::fuel_truck_zpu_damage_notify);
	//blow up ZPUs when player shots trucks
	flag_wait ("truck_exploded");
	array_notify(guns, "death");
	
}	

fuel_truck_zpu_damage_notify()
{
	self thread wait_for_player_to_damage_me();
	flag_wait ("truck_exploded");
	playsoundatposition ("exp_veh_large", self.origin);

}	

plane_warpto()
{
	flag_wait ("player_on_aa_gun");
	//wait(1);
	
	//this flag is set when the plane reaches a certain point in the spline too far down its path
	//if(flag("plane_too_far_to_warp"))
	//{
	//	return;
	//}	
	
	plane = GetEnt ("ac130_escape", "targetname");
	node = GetVehicleNode ("plane_escape_warpto", "targetname");
	level thread smoke_spiral(plane);
	//level thread display_plane_speed(plane);
	
	//plane thread go_path(node);
	//plane SetSpeed(40);
	//flag_set ("plane_warped");
	
	flag_wait ("truck_exploded");
	plane SetSpeed(60);


}	

plane_too_far_to_warp()
{
	flag_wait ("mason_deals");
	level endon ("plane_warped");
 	plane = GetEnt ("ac130_escape", "targetname");	
 	plane waittill ("plane_too_far");
 	flag_set ("plane_too_far_to_warp");	
 	//IPrintLnBold ("plane too far?");
}


middle_island_guys_logic()
{
	self endon ("death");
	self set_goalradius( 32  );
	self.noExplosiveDeathAnim = 1;
	self.animplaybackrate = 2;
	self thread force_goal();
	
	if(cointoss())
	{
		self set_generic_run_anim( "sprint_patrol_1");
	}
	else
	{
		self set_generic_run_anim( "sprint_patrol_2");
	}
		
}	

hangar1_fuel_trucks_logic()
{
	level.player_blew_up_truck = 0;
	
	self thread veh_magic_bullet_shield(1);
	
	flag_wait("player_on_plane");
	
	self thread veh_magic_bullet_shield(0);
	
	dmg_src = getstruct ("barrel_truck_damage", "targetname");
	
	while(1)
	{	
		self waittill ("damage", attacker);	
		if( ( IsPlayer ( attacker ))&&(self.health <= 900) )
		{
			if(level.player_blew_up_truck)
			{
				return;		
			}	
			level.player_blew_up_truck = 1;
			PlayFX( level._effect["fire_med"], dmg_src.origin );
			self notify ("death");
			level spawn_vehicle_gibs(self);			
			PlayFX (level._effect["darwins_vehicle_explosion"], dmg_src.origin);
			PlaySoundatposition( "exp_veh_large", dmg_src.origin );
			RadiusDamage (dmg_src.origin, 300, 1000, 1000);
			PhysicsExplosionSphere (dmg_src.origin, 500, 490, 2);	
			ai = GetAIArray ("axis");
			guys = get_within_range( dmg_src.origin, ai, 500 );
			for (i = 0; i < guys.size; i++ )
			{
					guys[i] thread burning_death();						
			}
			return;	
		}		
	}	

}	

truck_wipeout()
{

  chance = randomint( 100 );
  
  if( chance > 66 )
  {  
    force = (232, 95, 80);
    hitpos = (-76, -14, 34);
  }
  else if( chance > 33 )
  {  
    force = (232, 46, 196);
    hitpos = (-50,0,0);
  }
  else
  {
    force = (420, 8, 172);
    hitpos = (76, 2, 18);  
  }

  self LaunchVehicle( force, hitpos, true, true );
  self ClearVehGoalPos();
  wait(3);
  self notify ("death");
  
} 
  
uaz_rail_logic()
{
	//self veh_magic_bullet_shield( 1 );
	self.overrideVehicleDamage = ::runway_uaz_damage_override;
	level.crashed_uaz = undefined;

}	  

runway_uaz_damage_override(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName)
{	
	
	//health 850 or more
	if(self.health >= 900)
	{
		iDamage = 20;
		return iDamage;
	}
	//health less than 850 and has not crashed yet
	else if( (self.health <= 900)&&(!IsDefined(level.crashed_uaz)) )
	{
		//crash the vehicle
		PlayFX (level._effect["darwins_vehicle_explosion"], self.origin);
		PlaySoundatposition( "exp_veh_large", self.origin );
		Earthquake( .30, .50, get_players()[0].origin, 100 );
		get_players()[0] PlayRumbleOnEntity("damage_heavy");
		self thread truck_wipeout();
		
		for (i=0;i<self.attachedguys.size;i++)
		{
			if (isDefined(self.attachedguys[i]))
			{
				self.attachedguys[i] thread passenger_death();
			}
		}

		level.crashed_uaz = 1;		
		iDamage = 0;
		return iDamage;		
	}
	else
	{
		iDamage = 0;
		return iDamage;
	}	
	
}	

passenger_death()
{
	self endon ("death");

	if (is_mature())
	{
		self thread animscripts\death::flame_death_fx();
	}
	
	//self gun_remove();
	fwd = AnglesToForward( flat_angle(self.angles) );
	my_velocity = Vector_Scale (fwd, 200);
	my_velocity_with_lift = (my_velocity[0], my_velocity[1], 20);
	
	self Unlink();
	self StartRagdoll(); 
	wait(0.1); // wait 2 frames for the animation velocity to be calculated and applied to ragdoll
	
	//self.a.nodeath = true;
	self.a.doingRagdollDeath = true;                          
	self LaunchRagdoll(my_velocity_with_lift, self.origin);	
}

fuel_trucks_backup_trigger()
{
	trig = GetEnt ("fuel_trucks_damage_trigger", "targetname");
	trig wait_for_player_to_damage_me();
	
}		

wait_for_player_to_damage_me()
{
	//self = ent we want player to damage
	level endon ("player_failed_clearing_runway");
	level endon ("truck_exploded");

	flag_wait("player_on_aa_gun");

	while(1)
	{
		self waittill( "damage", amount, attacker, direction, point, dmg_type, modelName, tagName );		
		
		if( (IsPlayer(attacker) )&&(dmg_type == "MOD_PISTOL_BULLET") )    //
		{
			if(!flag("player_failed_clearing_runway"))
			{
				flag_set ("truck_exploded");
				return;
			}	
		}
		
	}		

}		

escape_plane_override(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName)
{
	if (!IsDefined(level.player_inflicted_damage))
	{
		level.player_inflicted_damage = 0;
	}
	
	//returning 0 iDamage after player completes objective
	if(flag("truck_exploded"))
	{
		iDamage = 0;
		return iDamage;
	}	
	
	//if player shoots plane
	//player does 155dmg per shot vs plane (155 310 465 620 775)
	if( (IsDefined (eInflictor.targetname)) && (eInflictor.targetname == ("player_zpu")) )
	{
		//tally up damage player is doing 
		level.player_inflicted_damage = level.player_inflicted_damage + iDamage;
		//if player shot it 4x = fail
		if(level.player_inflicted_damage >= 620)
		{
			level thread player_shot_plane();
		}
		iDamage = 0;
		return iDamage;	
	}
		
	//eInflictor.targetname == "zpu_player_turret"
	//isPlayer eAttacker
	//sWeapon == zpu_player_turret
	iDamage = 0;
	return iDamage;

}
	
	
escape_plane_override_no_damage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName)
{
	//always return 0 after runway objective is completed
	iDamage = 0;
	return iDamage;
}
	
	
player_shot_plane()
{
	flag_set ("player_shot_plane");

}	


fuel_truck_rpgs()
{
	spots = getstructarray ("near_truck_struct", "targetname");
	dmg_trig = getent("plane_dmg_trig","targetname");
	
	while(!flag("truck_exploded"))
	{	
		array_randomize (spots);
		for (i = 0; i < spots.size; i++ )
		{
			MagicBullet("rpg_magic_bullet_sp", spots[i].origin, dmg_trig.origin);
			wait(RandomFloatRange(.3,1.5));
		}
	}
}			
	
	
propeller_death_trig_setup()
{
	trig = GetEnt ("propeller", "targetname");
	trig trigger_off();
	flag_wait ("player_stunned");
	trig trigger_on();
	trig thread propeller_death_trig_logic();

}


propeller_death_trig_logic()
{
	//self = trig surrounding spinning propellers of escape plane
	player = get_players()[0];
	while(!flag("player_on_plane"))
	{
		self waittill("trigger",who);
		if(who == player)	
		{ 
			SetDvar( "ui_deadquote", &"CUBA_PROPELLER_DEATH");
			player stop_magic_bullet_shield();
			player die();
		}	
	}
		
}	

hangar1_player_prevention()
{
	level endon ("player_on_plane");
	player = get_players()[0];
	volume = GetEnt ("hangar1_volume", "targetname");
	
	while(1)
	{
		if(player IsTouching (volume) )
		{
			kill_player_with_mortar();
		}	
		wait(1);
	}	
}	
	
