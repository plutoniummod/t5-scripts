////////////// ////////////////////////////////////////////////////////////////////////////////////////////
/*
MAP: WMD
BUILDER: BRIAN GLINES, ROSS KAYLOR
SCRIPTER: CHRIS PIERRO, JUNE PARK, WALTER WILLIAMS, JOE CHIANG


*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////
#include maps\_utility;
#include common_scripts\utility;
#include maps\wmd_util;
#include maps\_anim;
#include maps\_music;




base_main() 
{
	flag_wait("players_jumped");
	
	level thread base_area_music_trigger();
	level thread base_reset_patrol_flags();
	level thread base_reset_squad_ai();
	level thread base_reset_Fog();
	level thread truck_spawn_functions();
	level thread test_end_wmd_level( 1 );
	level thread interior_door_vo();
	level thread interior_open_door();
	level thread interior_cover_tracks_init();
	level thread interior_first_line_fallback();
	level thread interior_clear_group_b_move_up();
	level thread interior_wire_vo();
	level thread activate_steiner_objective();
	level thread base_visionset_triggerin();
	level thread base_visionset_triggerout();
	level thread mg_kill_player();
	level thread street_mgunner();
	level thread warehouse_init();
	level thread truck_init();
	
	flag_wait("players_landed");
	
	level thread base_occluder();
	level thread base_fires();
	
	//enemy alert monitor
	level thread enemy_spawn_function();
	level thread base_weapon_check();
	level thread check_base_death();
	
	flag_wait( "base_complete" );
}


base_fires()
{
	triggers = getentarray("trigger_base_fire", "targetname");
	
	for(i=0; i<triggers.size; i++)
	{
		triggers[i] thread base_fire_damage();
	}
}


base_fire_damage()
{
	level endon("steiner_office_start_main");
	
	player = get_players()[0];
	
	while(1)
	{
		if (player isTouching(self))
		{
			player DoDamage(15, player.origin);
			player = get_players()[0];
		}
		
		wait(0.1);
	}
}


base_occluder()
{
	baseindoors = getstructarray("occlude_baseindoors", "targetname");
	topside = getstructarray("occlude_topside", "targetname");
	
	for(i=0; i<baseindoors.size; i++)
	{
		SetCellVisibleAtPos(baseindoors[i].origin);
	}
	
	for(i=0; i<topside.size; i++)
	{
		SetCellInvisibleAtPos(topside[i].origin);
	}
}


base_weapon_check()
{
	level endon("area_alerted");
	
	while(1)
	{
		player = get_players()[0];
		
		if (player AttackButtonPressed())
		{
			currentweapon =  player GetCurrentWeapon();
				
			if (currentweapon == "crossbow_explosive_alt_sp")
			{
				wait(2.5);	//wait for explosion
				flag_set ("area_alerted");
			}
				
			if ((currentweapon == "crossbow_vzoom_alt_sp") || (currentweapon == "aug_arctic_acog_silencer_sp"))
			{
				wait(0.05);
			}
			else
			{
				wait(1.0);
				flag_set("area_alerted");
			}
		}
				
		wait(0.1);
	}
}


enemy_spawn_function()
{
	guys = getaiarray("axis");
	
	for(i=0; i<guys.size; i++)
	{
		guys[i] thread check_base_alert();
	} 
}


check_base_alert()
{
	self endon("death");
	
	self waittill_any("alert", "bulletwhizby", "damage", "grenade danger");
	
	wait(1.0);
	
	flag_set("area_alerted");
}


check_base_death()
{
	wait(1.0);
	
	guys = getaiarray("axis");
	
	num_alive = guys.size;
	
	while(guys.size == num_alive)
	{
		guys = getaiarray("axis");
		
		wait(0.1);
	}
	
	wait(1.0);
	
	flag_set("area_alerted");
}


base_visionset_triggerin()
{
	trigin = getentarray("vision_base_interior", "targetname");
	
	for( i=0; i<trigin.size; i++)
	{
		trigin[i] thread base_visionset_in();
	}
}


base_visionset_in()
{
	while(1)
	{
		self waittill("trigger", ent);
	
		VisionSetNaked("wmd_lower_valley_interior");
		
		while(ent isTouching(self))
		{
			wait(0.05);
		}
	}
}


base_visionset_triggerout()
{
	trigout = getentarray("vision_base_exterior", "targetname");
	
	for( i=0; i<trigout.size; i++)
	{
		trigout[i] thread base_visionset_out();
	}
}


base_visionset_out()
{
	while(1)
	{
		self waittill("trigger", ent);
	
		VisionSetNaked("wmd_lower_valley");
		
		while(ent isTouching(self))
		{
			wait(0.05);
		}
	}
}


/*
// -- makes sure all flags on squad ai are set to normal
*/
base_reset_squad_ai()
{
	// -- If you jump to the base then run the reset on the squad ai
	if( IsDefined( level.skipped_to_missile ) && level.skipped_to_missile )
	{
		array_thread( level.heroes, ::field_squad_behave );
		return;
	}
	
	// objects
	struct_array_heroes_start = getstructarray( "struct_base_heroes_jumpto", "targetname" );
	weaver_landing_struct = getstruct( "struct_weaver_landing", "script_noteworthy" );
	brooks_landing_struct = getstruct( "struct_brooks_landing", "script_noteworthy" );
	
	// set up the array numbers for level.heroes
	keys = GetArrayKeys( level.heroes );
	
	//level.weaver thread base_squad_behave_at_landing( weaver_landing_struct );
	//level.brooks thread base_squad_behave_at_landing( brooks_landing_struct );
	
	level thread base_squad_behave_at_landing();
	
	wait( 0.1 );
	
	level thread base_field_chain_hookup();

}

/*
// -- runs on the squad to keep them from starting the landing fight early SELF == AI
*/
base_squad_behave_at_landing()
{
	flag_wait( "players_jumped" );
	
	level.weaver thread field_squad_behave();
	level.brooks thread field_squad_behave();
	
	flag_wait("cord_pull");
	
	wait(3.0);
	
	if( IsDefined(level.weaver.anchor))
	{
		level.weaver.anchor Unlink();
		level.weaver.anchor Delete();
	}
	if( IsDefined(level.brooks.anchor))
	{
		level.brooks.anchor Unlink();
		level.brooks.anchor Delete();
	}
	
	// stop anims
	level.weaver notify( "stop_wait_loop" );
	level.weaver StopAnimScripted();
	
	level.brooks notify( "stop_wait_loop" );
	level.brooks StopAnimScripted();
	
	// unlink the vehicle
	level.weaver Unlink();
	level.brooks Unlink();
	
	pos_weaver = getstruct("struct_weaver_land", "targetname");
	pos_brooks = getstruct("struct_brooks_land", "targetname");
	
	level.weaver stopanimscripted();
	level.brooks stopanimscripted();
	level.weaver ForceTeleport(pos_weaver.origin);
	level.brooks ForceTeleport(pos_brooks.origin);
	level.weaver.ignoreall = false;
	level.brooks.ignoreall = false;
	level.weaver.ignoreme = false;
	level.brooks.ignoreme = false;
	level.weaver enable_cqbwalk();
	level.brooks enable_cqbwalk();
		
	level.weaver ent_flag_set( "basejump_done" );
	level.brooks ent_flag_set( "basejump_done" );
	
	trigger_use("triggercolor_post_land");
	
	flag_wait("players_landed");
	
	wait(1.0);
	
	level.brooks handsignal("moveup");
	
	trigger_use("triggercolor_base_weaver");
		
	wait(1.5);
	
	trigger_use("triggercolor_base_brooks");
}


/*
// -- test to get the guys back on the friendly chain after the base jump
*/
base_field_chain_hookup()
{
	field_color_chain_start = GetEnt( "trigger_first_base_color_chain", "targetname" );
	
	level.brooks ent_flag_wait( "basejump_done" );
	level.weaver ent_flag_wait( "basejump_done" );
	
	players = get_players();
	
	// wait( 0.2 );
	
	//field_color_chain_start UseBy( players[0] );
	
	level.brooks notify( "stop_follow" );
	level.weaver notify( "stop_follow" );
	
	level.brooks set_force_color( "g" );
	level.weaver set_force_color( "c" );
}

/*
// -- fog set before the jump needs to be reset
*/
base_reset_fog()
{
	if( IsDefined( level.skipped_to_missile ) && level.skipped_to_missile )
	{
		wait( 5.0 );
	}
	
	
	// -- values provided by N Masiclat
	start_dist = 159.888;
	half_dist = 3969.69;
	half_height = 2454.62;
	base_height = 10418.4;
	fog_r = 0.301961;
	fog_g = 0.341176;
	fog_b = 0.34902;
	fog_scale = 10;
	sun_col_r = 1;
	sun_col_g = 0.788235;
	sun_col_b = 0.572549;
	sun_dir_x = -0.175571;
	sun_dir_y = 0.67452;
	sun_dir_z = 0.717076;
	sun_start_ang = 9.3213;
	sun_stop_ang = 53.7526;
	time = 5;
	max_fog_opacity = 0.517498;

	

	
	flag_wait( "player_opened_chute" );
	
	// -- WWILLIAMS: HACK TO FIX THE FOGGYNESS AT THE BOTTOM OF THE MOUNTAIN. VALUES FROM NEIL MASICLAT
	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
		sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
		sun_stop_ang, time, max_fog_opacity);
}



/*
// -- resets the flags needed for the patrol system
*/
base_reset_patrol_flags()
{
	// make sure the patrol flags are correctly set
	if( flag( "area_alerted" ) )
	{
		flag_clear( "area_alerted" );
	}
	// tells _patrol the field enemies can react to the normal tells
	if( !flag( "allow_alert" ) )
	{
		flag_set( "allow_alert" );
	}
}

test_end_wmd_level( int_time ) // -- WWILLIAMS: ENDS THE LEVEL UNTIL PROGRESSION IS FINISHED
{
	flag_wait( "finish_avalanche" );
	
	custom_fade_screen_out( "white", int_time );
	
	wait(3.0);
	
	flag_set( "base_complete" );
	
	nextmission();
}

/*
// -- reset enemy ai upon goal
*/
wmd_ai_reset_on_goal()
{
	self endon( "death" );
	
	self waittill( "goal" );
	
	if( self.ignoreall == 1 )
	{
		self.ignoreall = 0;
	}
	
	if( self.ignoreme == 1 )
	{
		self.ignoreme = 0;
	}
}


/*
// using this in most situations for a generic patrol attitude over the base areas SELF == AI
*/
patrol_spawn_function()
{
	self endon( "death" );
	
	self.goalradius = 64;
	self.pacifist = true;
	self.pacifistwait = 0;
	self.disableArrivals = true;
	self.disableExits = true;
	
	if( self.script_int == 1 )
	{
		self SetGoalPos( self.origin );
	}
	
	self.animname = "generic";
	self set_generic_run_anim( "patrol_walk" );
	
	//self thread setup_patroller( self.script_int, undefined, undefined, 0 );
	
	flag_wait( "area_alerted" );
	
	self.pacifist = false;
	self.pacifistwait = 1;
	self clear_run_anim();
	self.disableArrivals = false;
	self.disableExits = false;
	self.goalraidus = 512;
}

/*******************************************************************
// -- JUMPTO FUNCTIONS -- //
*******************************************************************/
/*
// -- spawns out the vehicles for the skipto
*/
base_jumpto_init()
{
	level field_jumpto_hero_init();
	level field_player_skipto();
	
	flag_set("players_jumped");
	flag_set( "players_landed" );
	flag_set("allow_alert"); //allows the area to go hot
	
	level notify( "ground_parachutes_start" ); // -- WWILLIAMS: MAKES SURE THE PARACHUTE ANIMS HAPPEN
	
	level thread field_loading_truck_spawn();
	level thread field_backup_truck();
	// level base_jumpto_remove_harris();
	
	level thread field_squad_landing_dialogue();
	level thread field_squad_moves_in();
	
	level thread field_clean_up();
	
	level base_main();
}

/*
// -- moves the field vehicles in to position
*/
field_teleport_vehicles_jumpto()
{
	AssertEx( IsDefined( self.script_string ), "field vehicle missing script_string" );
	
	end_v_node = GetVehicleNode( self.script_string, "targetname" );
	
	// self ForceTeleport( end_v_node.origin, end_v_node.angles );
	self.origin = end_v_node.origin;
	self.angles = end_v_node.angles;
}

/*
// -- move the heroes to the base skipto starts
*/
field_jumpto_hero_init()
{
	// objects
	struct_array_heroes_start = getstructarray( "struct_base_heroes_jumpto", "targetname" );
	
	keys = GetArrayKeys( level.heroes );
	
	for( i = 0; i < struct_array_heroes_start.size; i++ )
	{
		if( IsDefined( level.heroes[ keys[ i ] ] ) && IsAlive( level.heroes[ keys[ i ] ] ) )
		{
			level.heroes[ keys[ i ] ] ForceTeleport( struct_array_heroes_start[i].origin, struct_array_heroes_start[i].angles );
			level.heroes[ keys[ i ] ] SetGoalPos( struct_array_heroes_start[i].origin );
		}
		
	}
	
	level.skipped_to_missile = true;

}

/* 
// -- moves the player to the base skipto start
*/
field_player_skipto()
{
	// objects
	struct_player_start = getstruct( "struct_base_player_jumpto", "targetname" );
	
	players = get_players();
	
	// players[0] FreezeControls( true );
	players[0] SetOrigin( struct_player_start.origin );

	
}

/*
// -- jump to for the warehouse
*/
base_jumpto_warehouse()
{
	squad_nodes = GetNodeArray( "node_warehouse_skipto", "targetname" );
	player_struct = getstruct( "struct_player_warehouse_skipto", "targetname" );
	
	level.base_skipto_warehouse = true;
	
	// move squad in to spots
	level.weaver ForceTeleport( squad_nodes[0].origin, squad_nodes[0].angles );
	level.weaver SetGoalNode( squad_nodes[0] );
	level.brooks ForceTeleport( squad_nodes[1].origin, squad_nodes[1].angles );
	level.brooks SetGoalNode( squad_nodes[1] );
	level.harris ForceTeleport( squad_nodes[2].origin, squad_nodes[2].angles );
	level.harris SetGoalNode( squad_nodes[2] );
	
	// move player
	players = get_players();
	players[0] SetOrigin( player_struct.origin );
	players[0] SetPlayerAngles( player_struct.angles );
	
	level thread test_end_wmd_level( 1 );
	level thread base_reset_fog();
	level thread warehouse_init();
	level thread truck_init();
}

/*
// -- jump to the avalanche moment
*/
base_jumpto_avalanche()
{
	// truck to leave on
	truck_spawn_trigger = GetEnt( "trigger_spawn_truck_mg", "targetname" );
	avalanche_squad_nodes = GetNodeArray( "node_skipto_avalanche", "targetname" );
	avalanche_spline_start = GetVehicleNode( "vnode_run_from_avalanche", "targetname" );
	
	// level var to know there was a skipto
	level.base_skipto_avalanche = true;
	
	players = get_players();
	truck_spawn_trigger UseBy( players[0] );
	level waittill( "vehiclegroup spawned5005" );
	
	wait( 1.0 );
	
	avalanche_truck = GetEnt( "vehicle_escape_truck", "targetname" );
	avalanche_truck AttachPath( avalanche_spline_start );
	
	// level base_jumpto_remove_harris();
	// move squad to position
	level.weaver ForceTeleport( avalanche_squad_nodes[0].origin, avalanche_squad_nodes[0].angles );
	//level.weaver thread run_to_vehicle_load( avalanche_truck, true, "tag_driver" );
	level.brooks ForceTeleport( avalanche_squad_nodes[1].origin, avalanche_squad_nodes[1].angles );
	level.brooks SetGoalNode( avalanche_squad_nodes[1] );
	level.harris ForceTeleport( avalanche_squad_nodes[2].origin, avalanche_squad_nodes[2].angles );
	//level.harris thread run_to_vehicle_load( avalanche_truck, true, "tag_passenger" );
	
	get_on_trigger = GetEnt( "trigger_truck_get_on", "targetname" );
	get_on_trigger trigger_off();
	
	
	// teleport the player to the vehicle
	players = get_players();
	avalanche_truck UseVehicle( players[0], 1 );
	
	// turn off the truck's use
	// avalanche_truck MakeVehicleUnusable();
	
	//autosave_by_name( "wmd" );
	
	// flag
	// flag_set( "player_on_truck" );
	
	level thread base_reset_fog();
	level thread test_end_wmd_level( 1 );
	level thread truck_init();
}



/*
// -- remove harris/"glines" from the map
*/
base_jumpto_remove_harris()
{
	remove_ent = level.heroes[ "glines" ];
	level.heroes[ "glines" ] unmake_hero();
	
	level.heroes[ "glines" ] Delete();
}





/*******************************************************************
// -- JUMPTO FUNCTIONS -- //
*******************************************************************/

/*******************************************************************
// -- FIELD FUNCTIONS -- //
*******************************************************************/

/*
// -- field init, runs all the functions that needs to start when the player jumps
*/
field_init()
{	
	level thread field_squad_landing_dialogue();
	level thread field_squad_moves_in();

	level thread field_loading_truck_spawn();
	level thread field_backup_truck();
	
	level thread field_clean_up();
}


/*
// spawns the loading truck and the enemies around it
*/
field_loading_truck_spawn()
{
	level.disc = false;
	level.paper1 = false;
	level.paper2 = false;
	
	level.paper_right = false;
	level.paper_right2 = false;
	level.paper_left = false;
	level.paper_left2 = false;
	
	level.barrel1_right = false;
	level.barrel2_right = false;
	level.barrel1_left = false;
	level.barrel2_left = false;
	
	//spawn_trigger = GetEnt( "trigger_spawn_field_loading_truck", "targetname" );
	
	working_guard_spawner = GetEnt( "spawner_field_working_guard", "targetname" );
	truck_guard_spawners = GetEntArray( "spawner_field_truck_guards", "targetname" );
	pacing_guard_spawners = GetEntArray( "spawner_field_pacing_guards", "targetname" );
	fire_guard_spawners = GetEntArray( "spawner_fire_guy", "targetname" );
	field_guard_spawners = GetEntArray( "spawner_field_guard", "targetname" );
	
	//loading_truck_spawner_array = GetEntArray( "spawner_field_loading_truck", "targetname" );
	
			
	// extra spawn functions for the ai that come out of the spawners
	//array_thread( loading_truck_spawner_array, ::add_spawn_function, ::field_loading_truck_goal_volumes );
	
	// spawn out vehicle
	trigger_use("trigger_spawn_field_loading_truck");
	//players = get_players();
	//spawn_trigger UseBy( players[0] );
	
	// spawn out the guys
	working_guards = simple_spawn_single( working_guard_spawner, ::field_working_guards );
	truck_guards = simple_spawn( truck_guard_spawners, ::field_truck_guards );
	pacing_enemies = simple_spawn( pacing_guard_spawners, ::field_pacing_guards );
	fire_guards = simple_spawn( fire_guard_spawners, ::field_fire_guards );
	field_guards = simple_spawn( field_guard_spawners, ::setup_field_guard );
	
	//loading_truck_enemies = simple_spawn( loading_truck_spawner_array, ::patrol_spawn_function );
		
	// wait for the player to land
	
	// start the tracking of the enemies in this line
	level thread field_loading_line_clear();
	
	wait( 0.2 );
	
	level thread field_russian_dialogue_1( pacing_enemies );
	level thread field_russian_dialogue_2( truck_guards );
	
	guy1 = getai_by_noteworthy("truck_guard1");
	guy2 = getai_by_noteworthy("truck_guard2");
	
	guy1 thread guard1_detach_stuff();
	guy2 thread guard2_detach_stuff();
	
	fire_pile1 = getai_by_noteworthy("fire_pile_1");
	fire_pile2 = getai_by_noteworthy("fire_pile_2");
	
	fire_pile1 thread fire_pile1_detach();
	fire_pile2 thread fire_pile2_detach();
	
	barrel_pile1 = getai_by_noteworthy("barrel_fire_1");
	barrel_pile2 = getai_by_noteworthy("barrel_fire_2");
	
	barrel_pile1 thread fire_barrel1_detach();
	barrel_pile2 thread fire_barrel2_detach();
	
	fire_guard1 = getai_by_noteworthy("fire_guard_1");
	fire_guard2 = getai_by_noteworthy("fire_guard_2");
	
	truck_guard1 = getai_by_noteworthy("truck_guard1");
	truck_guard2 = getai_by_noteworthy("truck_guard2");
	
	working_guard = getent("spawner_field_working_guard_ai", "targetname");
	
	flag_wait("area_alerted");
	
	battlechatter_on();
	
	node_fire1 = getnode("node_fire_pile1", "targetname");
	node_fire2 = getnode("node_fire_pile2", "targetname");
	node_guard1 = getnode("node_fire_guard1", "targetname");
	node_guard2 = getnode("node_fire_guard2", "targetname");
	node_barrel1 = getnode("node_barrel1", "targetname");
	node_barrel2 = getnode("node_barrel2", "targetname");
	node_work = getnode("node_working", "targetname");
	node_truck1 = getnode("node_truck1", "targetname");
	node_truck2 = getnode("node_truck2", "targetname");
	
	 if (isAlive(fire_pile2))
	{
		fire_pile2 thread force_goal();
		fire_pile2 setgoalnode(node_fire2);
	}
	
	wait(0.3);
	
	if (isAlive(fire_guard1))
	{
		fire_guard1 thread force_goal();
		fire_guard1 setgoalnode(node_guard1);
	}
	if (isAlive(fire_guard2))
	{
		fire_guard2 thread force_goal();
		fire_guard2 setgoalnode(node_guard2);
	}
	
	wait(0.2);
	
	if (isAlive(barrel_pile1))
	{
		barrel_pile1 thread force_goal();
		barrel_pile1 setgoalnode(node_barrel1);
	}
	if (isAlive(barrel_pile2))
	{
		barrel_pile2 thread force_goal();
		barrel_pile2 setgoalnode(node_barrel2);
	}
	
	wait(0.1);
	
	if (isAlive(working_guard))
	{
		working_guard thread force_goal();
		working_guard setgoalnode(node_work);
	}
	
	if (isAlive(truck_guard1))
	{
		truck_guard1 thread force_goal();
		truck_guard1 setgoalnode(node_truck1);
	}
	if (isAlive(truck_guard2))
	{
		truck_guard2 thread force_goal();
		truck_guard2 setgoalnode(node_truck2);
	}
}


fire_barrel1_detach()
{
	self endon("death");
	
	flag_wait("area_alerted");
	
	if (isAlive(self) && level.barrel1_left)
	{
		self Detach("p_rus_crumpled_paper_01", "tag_weapon_left");
	}
	
	if (isAlive(self) && level.barrel1_right)
	{
		self Detach("p_rus_crumpled_paper_01", "tag_inhand");
	}
}


fire_barrel2_detach()
{
	self endon("death");
	
	flag_wait("area_alerted");
	
	if (isAlive(self) && level.barrel2_left)
	{
		self Detach("p_rus_crumpled_paper_01", "tag_weapon_left");
	}
	
	if (isAlive(self) && level.barrel2_right)
	{
		self Detach("p_rus_crumpled_paper_01", "tag_inhand");
	}
}


fire_pile1_detach()
{
	self endon("death");
	
	flag_wait("area_alerted");
	
	if (isAlive(self) && level.paper_left)
	{
		self Detach("p_rus_crumpled_paper_01", "tag_weapon_left");
	}
	
	if (isAlive(self) && level.paper_right)
	{
		self Detach("p_rus_crumpled_paper_01", "tag_inhand");
	}
}


fire_pile2_detach()
{
	self endon("death");
	
	flag_wait("area_alerted");
	
	if (isAlive(self) && level.paper_left2)
	{
		self Detach("p_rus_crumpled_paper_01", "tag_weapon_left");
	}
	
	if (isAlive(self) && level.paper_right2)
	{
		self Detach("p_rus_crumpled_paper_01", "tag_inhand");
	}
}


guard1_detach_stuff()
{
	self endon("death");
	
	flag_wait("area_alerted");
	
	if (isAlive(self) && level.disc)
	{
		self Detach("p_rus_reel_disc", "tag_inhand");
	}
	
	if (isAlive(self) && level.paper1)
	{
		self Detach("dest_glo_paper_01_d0", "tag_inhand");
	}
}


guard2_detach_stuff()
{
	self endon("death");
	
	flag_wait("area_alerted");
	
	if (isAlive(self) && level.paper2)
	{
		self Detach("dest_glo_paper_02_d0", "tag_inhand");
	}
}


field_russian_dialogue_1( ent_array )
{
	AssertEx( ent_array.size > 1, "ent_array passed in less than 2 ai" );
	
	// -- endons
	ent_array[0] endon( "death" );
	ent_array[0] endon( "damage" );
	
	ent_array[1] endon( "death" );
	ent_array[1] endon( "damage" );
	
	level endon( "area_alerted" );
	// -- endons
	
	flag_wait( "players_landed" );
	
	trigger_wait("trigger_russian_chatter");
	
	flag_wait("player_field_comment");
	
	if( ent_array[0].animname == "pacing_guard_1" )
	{
		ent_array[0] anim_single(ent_array[0], "are_we_doing");	//What are we doing with all this?
	}
	else if( ent_array[1].animname == "pacing_guard_1" )
	{
		ent_array[1] anim_single(ent_array[1], "are_we_doing");	//What are we doing with all this?
	}
	
	if( ent_array[0].animname == "pacing_guard_2" )
	{
		ent_array[0] anim_single(ent_array[0], "burn_everything");	//Burn it.  Burn everything.
	}
	else if( ent_array[1].animname == "pacing_guard_2" )
	{
		ent_array[1] anim_single(ent_array[1], "burn_everything");	//Burn it.  Burn everything.
	}
	
	flag_set( "field_russian_dialogue_1" );
}

/*
// -- second set of russian dialogue for the field
// -- plays after the first set is complete
*/
field_russian_dialogue_2( ent_array )
{
	level endon( "area_alerted" );
	
	talking_russian = undefined;
	
	AssertEx( ent_array.size > 0, "ent_array for second feidl russian dialogue empty!" );
	
	for( i = 0; i < ent_array.size; i++ )
	{
		if( ent_array[i].animname == "truck_guard_1" )
		{
			talking_russian = ent_array[i];
		}
	}
	
	AssertEx( IsDefined( talking_russian ), "talking_russian still undefined" );
	
	flag_wait( "field_russian_dialogue_1" );
	
	talking_russian anim_single(talking_russian, "have_your_orders");		//You have your orders... Leave nothing behind.
	
	wait(0.5);
	
	talking_russian anim_single(talking_russian, "go_on_the_fire");		//If it does not go on a truck, it is to go on the fire.
	
	wait(0.5);
	
	talking_russian anim_single(talking_russian, "hurry_it_up");		//Hurry it up... We blow the base in less than thirty minutes.
}


field_fire_guards()
{
	self endon( "death" );
	
	anim_struct = getstruct( "struct_fire_align", "targetname" );
	
	self.ignoreall = 1;
	self.pacifist = 1;
	self.allowdeath = 1;
	//self thread setup_patroller( 1, undefined, undefined, 0 );
	//self thread field_loading_truck_goal_volumes();
	
	//self AnimMode("gravity");
	
	anim_struct thread anim_loop_aligned( self, "burn_pile_loop" );
	
	flag_wait( "area_alerted" );
	
	//wait(RandomFloatRange(0.1, 0.8));
	
	// turn on ai
	self.ignoreall = 0;
	self.pacifist = 0;
	
	self notify( "stop_looping" );
	
	//self stopanimscripted();
	
	self anim_single(self, "burn_notice_react");
}


/*
// -- controls the two guys pacing away from the mountain
// -- SELF == AI
*/
field_pacing_guards()
{
	self endon( "death" );
	
	//anim_struct = getstruct( "struct_field_pacing_align", "targetname" );
	anim_struct = getent("exterior_barrel_fire", "targetname");
	
	self.ignoreall = 1;
	self.pacifist = 1;
	self.allowdeath = 1;
	//self thread setup_patroller( 1, undefined, undefined, 0 );
	//self thread field_loading_truck_goal_volumes();
	
	//self AnimMode("gravity");
	
	//anim_struct thread anim_loop_aligned( self, "pacing_loop" );
	anim_struct thread anim_loop_aligned( self, "burn_notice_loop" );
	
	flag_wait( "area_alerted" );
	
	//wait(RandomFloatRange(0.1, 0.8));
	
	// turn on ai
	self.ignoreall = 0;
	self.pacifist = 0;
	
	self notify( "stop_looping" );
	
	//self anim_single_aligned( self, "pacing_react" );
	self anim_single(self, "burn_notice_react");
}


/*
// -- runs the guards unloading the truck until the field is alerted
// -- SELF == AI
*/
field_truck_guards()
{
	self endon( "death" );
	
	field_truck = GetEnt( "vehicle_field_loading_truck", "targetname" );
	
	AssertEx( IsDefined( self.script_animname ), "truck giard missing script_animname" );
	AssertEx( IsDefined( field_truck ), "field truck not spawned in yet" );
	
	self.ignoreall = 1;
	self.pacifist = 1;
	self.allowdeath = 1;
	//self thread setup_patroller( 1, undefined, undefined, 0 );
	//self thread field_loading_truck_goal_volumes();
	
	field_truck thread anim_loop_aligned( self, "unload_loop" );
	
	flag_wait( "area_alerted" );
	
	// turn on ai
	self.ignoreall = 0;
	self.pacifist = 0;
	
	field_truck anim_single_aligned( self, "unload_react" );
}


/* 
// -- runs the guy working on the truck
// -- SELF == AI
*/
field_working_guards()
{
	self endon( "death" );
	
	anim_struct = getstruct( "struct_working_guard_anim", "targetname" );
	
	AssertEx( IsDefined( self.script_animname ), "working guard has no script_animname" );
	AssertEx( IsDefined( anim_struct ), "working guard anim_struct not defined" );
	
	self.ignoreall = 1;
	self.pacifist = 1;
	self.allowdeath = 1;
	//self thread setup_patroller( 1, undefined, undefined, 0 );
	//self thread field_loading_truck_goal_volumes();
	
	anim_struct thread anim_loop_aligned( self, "working_loop" );
	
	flag_wait( "area_alerted" );
	
	// turn on ai
	self.ignoreall = 0;
	self.pacifist = 0;
	
	self notify( "stop_looping" );
	
	anim_struct anim_single_aligned( self, "working_react" );
}


setup_field_guard()
{
	self endon( "death" );
	
	self.goalradius = 16;
	self.pacifist = true;
	self.pacifistwait = 0;
	self.disableArrivals = true;
	self.disableExits = true;
	
	flag_wait( "area_alerted" );
	
	self.pacifist = false;
	self.pacifistwait = 1;
	self.disableArrivals = false;
	self.disableExits = false;
	self.goalraidus = 2048;
}


/*
// -- controls the goal volumes the loading ai should be in SELF == AI
*/
field_loading_truck_goal_volumes()
{
	self endon( "death" );
	
	// objects
	front_line_volume = GetEnt( "field_loading_truck_front_volume", "targetname" );
	front_line_struct = getstruct( front_line_volume.target, "targetname" );
	// script_spawner_targets for the front line:  field_line_1
	
	rear_line_volume = GetEnt( "field_loading_truck_back_volume", "targetname" );
	rear_line_struct = getstruct( rear_line_volume.target, "targetname" );
	// script_spawner_targets for the rear line:  field_line_2
	
	// wait for the area to go hot
	flag_wait( "area_alerted" );
	
	// fight from the front line
	// self.goalradius = front_line_struct.radius;
	// self SetGoalPos( front_line_struct.origin );
	self set_spawner_targets( "field_line_1" );
	self SetGoalVolume( front_line_volume );
	
	flag_wait( "field_line_fallback" );
	
	// fight from the rear line
	// self.goalradius = rear_line_struct.radius;
	// self SetGoalPos( rear_line_struct.origin );
	self set_spawner_targets( "field_line_2" );
	self SetGoalVolume( rear_line_volume );
	
}
base_area_music_trigger()
{
	// wait for the area to go hot
	flag_wait( "area_alerted" );
	
	//TUEY Set music state to BASE_FIGHT
	setmusicstate ("BASE_FIGHT");	
	
}
/*
// -- squad stays quiet until the right time
*/
field_squad_behave()
{
	// endon
	self endon( "death" );
	
	self thread enable_cqbwalk();
	self.ignoreme = true;
	// self.ignoreall = true;
	self.pacifist= true;
	
	flag_wait("area_alerted");
	
	self thread disable_cqbwalk();
	self.ignoreme = false;
	// self.ignoreall = false;
	self.pacifist= false;
}

/*
// -- field react to the player presence if they push up
*/
field_squad_moves_in()
{
	// objects
	react_trigger = GetEnt( "trigger_pre_move_up_to_backup_line", "targetname" );
	
	flag_wait( "players_landed" );
	
	react_trigger waittill( "trigger" );
	
	// make an ai shoot at another ai to set it off
	// weaver shoots a patroller or a guy sitting still
	
	if( !flag( "area_alerted" ) )
	{
		flag_set( "area_alerted" );
		battlechatter_on();
		battlechatter_on("allies");
		battlechatter_on("axis");
		//TUEY Set music state to BASE_FIGHT
		setmusicstate ("BASE_FIGHT");	
		
	}

}

/*
// -- watches for the loading truck set of field enemies to clear and then set friendly chain forward, runs after the guys spawn
*/
field_loading_line_clear()
{
	waittill_ai_group_count( "field_truck_loading", 2 );
	
	// flag starts the fallback
	flag_set( "field_line_fallback" );
		
	trigger_use("trigger_pre_move_up_to_backup_line");
	
	wait(5.0);
	
	trigger_use("trigger_move_up_to_backup_line");
}


/*
// -- spawns out and moves the field backup truck guys
*/
field_backup_truck()
{
	// objects
	trigger_spawn = GetEnt( "trigger_truck_field_backup_spawn", "targetname" );
	trigger_move = GetEnt( "trigger_truck_field_backup_move", "targetname" );
	first_truck_spawner = GetEnt( "vehicle_field_truck_backup", "targetname" );
	second_truck_spawner = GetEnt( "vehic_second_gaz66_backup", "targetname" );
	backup_truck_spawners = GetEntArray( "spawner_field_truck_backup", "targetname" );
	
	flag_wait( "area_alerted" );
	
	level.streamhint = createStreamerHint((14004, -6100, 9990), 1);
	
	// spawn the vehicle
	players = get_players();
	trigger_spawn UseBy( players[0] );
	
	wait( 2.0 );
	
	// move the vehicle in to place
	backup_truck = GetEnt( "vehicle_field_truck_backup", "targetname" );
	players = get_players();
	trigger_move UseBy( players[0] );
	
	//vehicle_node_wait( "vnode_start_second_backup_truck" );
	wait(7.0);
	
	trigger_use("trigger_spawn_second_backup_truck");
	
	wait( 0.05 );
	
	trigger_use("trigger_move_second_backup_truck");
	
	flag_set( "field_backup_spawned" );
	
	level thread monitor_base_ai();
	level thread field_backup_line_clear();
	
	backup_truck waittill( "reached_end_node" );
	backup_truck vehicle_unload();
}


/*
// -- watches for the second truck to be destroyed then sets a flag SELF == VEHICLE
*/
field_second_backup_truck_death()
{
	self thread veh_magic_bullet_shield( 1 );
	
	flag_wait( "street_mggunner" );
	
	self thread veh_magic_bullet_shield( 0 );
	
	self waittill( "death" );
	
	flag_set( "street_truck_destroyed" );
}


/*
// -- unloads any enemies in the second truck SELF == VEHICLE
*/
field_second_backup_truck_unload()
{
	self endon( "death" );
	
	//self.dontDisconnectPaths = true;
	
	self waittill( "reached_end_node" );
	
	self vehicle_unload();
}


/*
// -- watches the ai group of enemies that come on the truck, starts when the truck ends its path
*/
monitor_base_ai()
{
	wait(3.0);
	
	guys = getaiarray("axis");
	
	while(guys.size > 0)
	{
		guys = getaiarray("axis");
		
		wait(0.1);
	}
	
	flag_set("mg_activate");
}


field_backup_line_clear()
{
	flag_wait("mg_activate");
	
	level thread vo_mg();
		
	trigger_use("trigger_pre_move_to_the_base_streets_0");
	
	wait( 0.2 );
	
	trigger_use("trigger_move_to_the_base_streets");
}


vo_mg()
{
	level.weaver.animname = "weaver";
	
	wait(1.0);
	
	level.weaver anim_single(level.weaver, "mg_in_the_tower");		//Got an MG in the tower!
	
	wait(0.5);
	
	player = get_players()[0];
	player.animname = "hudson";
	player anim_single(player, "into_the_building");	//Into the building!
	
	wait(0.5);
	
	level.weaver anim_single(level.weaver, "here");		//Here!
}


/*
// -- enemies who come on the backup truck
*/
backup_truck_spawn_function()
{
	self endon( "death" );
	
	self.goalradius = 24; // 
	
	backup_volume = GetEnt( "volume_backup_truck", "targetname" );
	backup_volume_struct = getstruct( backup_volume.target, "targetname" );
	
	self waittill( "jumpedout" );
	
	self.goalradius = 24; // 
	
	self waittill( "goal_changed" );
	
	// set the ai to the script_spawner_targets
	self set_spawner_targets( "field_truck_backup_nodes" );
	wait( 0.1 );
	self.goalradius = 24; // 
	self SetGoalVolume( backup_volume );
	
	self waittill( "goal" );
	
	// set ai to the volume
	// self waittill( "goal" );
	wait( 1.0 );
	self.goalradius = 512;
}

/*
// -- cleans up any spawners and etc that needs to be removed
*/
field_clean_up()
{
	flag_wait( "player_in_base" );
	
	// grab the spawners for the field
	field_spawners = GetEntArray( "spawner_field_loading_truck", "targetname" );
	backup_spawners = GetEntArray( "spawner_field_truck_backup", "targetname" );
	
	array_delete( field_spawners );
	array_delete( backup_spawners );
	
}

/*
// -- field dialogue on the squad
*/
field_squad_landing_dialogue()
{
	level endon( "area_alerted" );
	
	dialogue_trigger = GetEnt( "trigger_start_field_dialogues", "targetname" );
	
	flag_wait( "players_landed" );
	
	dialogue_trigger waittill( "trigger" );
	
	// run the dialogue for the moment
	player = get_players()[0];
	player.animname = "hudson";
	player anim_single(player, "clearing_house");	//Shit... They've already started clearing house - Move!
		
	flag_set( "player_field_comment" );
}


/*******************************************************************
// -- BASE STREET FUNCTIONS -- //
*******************************************************************/
/*
// -- controls the street mgunner floodspawning
*/
street_mgunner()
{
	flag_wait("mg_activate");
	
	flag_set( "street_mggunner" );
	
	simple_floodspawn( "spawner_base_mgunner", ::street_mg_target );
	
	flag_wait( "street_truck_destroyed" );
	
	trigger_use("trigger_start_base_mgunner");
		
	trigger_use("trigger_interior_truck");
}


mg_kill_player()
{
	trigger_wait("mg_kill_player");
	
	flag_set("mg_activate");
}


/* 
// -- forces the mg to shoot at the truck first SELF == AI
*/
#using_animtree("wmd");
street_mg_target()
{
	self endon( "death" );
	level endon("obj_to_steiner_office");
	
	self thread mg_guy_death();
	
	self setcandamage(false);
	self.disableArrivals = true;
	self.disableExits = true;
	self disable_pain();
	self disable_react();
	
	street_mg = GetEnt( "street_mg_turret", "targetname" );
	mg_node = GetNode( "node_street_mg", "targetname" );
	
	// make sure the turret can't be killed
	street_mg SetCanDamage( false );
	
	street_mg.accuracy = 1.0;
	street_mg SetAISpread(0);
	street_mg SetConvergenceTime(0.1);
	
	if( flag( "street_truck_destroyed" ) )
	{
		return;
	}
	
	flag_wait( "field_backup_spawned" );
	
	// grab the second truck
	second_backup_truck = GetEnt( "vehic_second_gaz66_backup", "targetname" );
	target_origin = GetEnt( "origin_tower_mg_target", "targetname" );
	
	// make this vehicle the target

	while( !IsTurretActive( street_mg ) )
	{
		wait( 0.05 );
	}
	
	street_mg SetMode("manual_ai");
	street_mg SetTargetEntity( second_backup_truck );
	
	wait( 2.5 );
	
	force = (0, 0, 200);
	hitpos = (0, 20, 0);
	
	playfx(level._effect["gaz_exp"], second_backup_truck.origin);
	
	playsoundatposition("exp_veh_large", second_backup_truck.origin);
	
	physicsExplosionSphere(second_backup_truck.origin, 300, 300, 4.0);
	
	earthquake(0.5, 1, second_backup_truck.origin, 5000);
	
	//second_backup_truck LaunchVehicle(force, hitpos, true, true);
		
	second_backup_truck.animname = "base_street_truck";
	second_backup_truck UseAnimTree(#animtree);
	second_backup_truck anim_single_aligned( second_backup_truck, "street_block", "tag_origin_animate_jnt", "base_street_truck" );
	
	//wait(1.0);
	
	truck = spawn("script_model", second_backup_truck.origin + (0, 150, 48));
	truck SetModel("t5_veh_gaz66_dead");
	//truck.angles = second_backup_truck.angles;
	truck.angles = (0, 160, 90);
	truck Attach("t5_veh_gaz66_troops_dead", "tag_origin");
	
	second_backup_truck delete();
	
	flag_set( "street_truck_destroyed" );
	sound_ent = spawn("script_origin", truck.origin);
	PlayFXOnTag(level._effect["truck_fire"], truck, "tag_origin");
	sound_ent playloopsound ("amb_fire_large");
	
	street_mg ClearTargetEntity();
	
	self thread street_stay_on_mg( street_mg, mg_node );
}


mg_guy_death()
{
	flag_wait("obj_to_steiner_office");
	
	if (isAlive(self))
	{
		self delete();
	}
}


/*
// -- plays the fx deathanim on the vehicle after the MG opens fire on it
// -- SELF == LEVEL
*/
#using_animtree( "wmd" );
street_truck_explosion( vehicle_truck )
{
	spawn_angles = vehicle_truck.angles;
	spawn_origin = vehicle_truck.origin;

	// vehicle_truck Delete();
	
	// anim_truck = SpawnVehicle( "t5_veh_gaz66", "vehicle_base_street_anim_truck", "truck_gaz66_troops", spawn_origin, spawn_angles );
	vehicle_truck.animname = "base_street_truck";
	vehicle_truck UseAnimTree(#animtree);
	
	vehicle_truck anim_single_aligned( vehicle_truck, "street_block", "tag_origin_animate_jnt", "base_street_truck" );
	PlayFXOnTag( level._effect[ "street_truck_explosion" ], vehicle_truck, "tag_origin" );
	vehicle_truck playsound( "exp_veh_large" );
}


/*
// -- kill the player if they get too close
// -- SELF == AI
*/
street_player_must_die()
{
	street_mg = GetEnt( "street_mg_turret", "targetname" );
	too_close_trigger = GetEnt( "mg_kill_player", "targetname" );
	
	// set up defaults
	default_accuracy = 0.75;
	default_aispread = 1;
	default_convergence = 1.5;
	
	// special settings
	kill_accuracy = 0.9;
	kill_converg_time = 0.2;
	kill_bottom_arc = 175;
	kill_ai_spread = 1;
	kill_supress_time = 90;
	
	
	while(1)
	{
		too_close_trigger waittill( "trigger", who );
		
		// change the damage callbacks on the player to take more damage when inside the trigger
		players = get_players();
		players[0].overridePlayerDamage = ::street_kill_zone_player_damage;
		
		while( who IsTouching( too_close_trigger ) )
		{
			street_mg.accuracy = kill_accuracy;
			street_mg SetAISpread( kill_ai_spread );
			street_mg SetConvergenceTime( kill_converg_time );
			street_mg SetBottomArc( kill_bottom_arc );
			street_mg SetSuppressionTime( kill_supress_time );
			
			if( IsAlive( who ) )
			{
				street_mg SetTargetEntity( who );	
			}
			
			wait( 1.0 );
		}
				
		wait( 1.0 );
		
		// reset defaults
		street_mg.accuracy = default_accuracy;
		street_mg.aispread = default_aispread;
		street_mg.convergencetime = default_convergence;
		
		// reset modified player damage
		players = get_players();
		players[0].overridePlayerDamage = undefined;
	}
}


/*
// -- modifies the damage applied to the player when they are near the turret
*/
street_kill_zone_player_damage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, 
																sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	if( self.health < 40 )
	{
		iDamage = iDamage * 6;
	}
	else
	{
		iDamage = iDamage * 4;	
	}
	
	return iDamage;
}


/*
// -- makes sure the guy is on the turret and if he isn't gets him back on it
// -- SELF == AI
*/
street_stay_on_mg( mg_turret, turret_node )
{
	AssertEx( IsDefined( mg_turret ), "no turret passed in to stay_on_mg" );
	AssertEx( IsDefined( turret_node ), "no turret_node for stay_on_mg" );
	
	self endon( "death" );
	level endon("obj_to_steiner_office");
	
	mg_turret.accuracy = 0.5;
	mg_turret SetAISpread(2.0);
	mg_turret SetConvergenceTime(0.5);
	mg_turret SetSuppressionTime(80);
	
	self thread fake_mg_audio( mg_turret );
	players = get_players();
	mg_turret SetMode("manual_ai");
	mg_turret SetTargetEntity( players[0] );
	
//	while( IsAlive( self ) )
//	{
//		while( IsTurretActive( mg_turret ) )
//		{
//			wait( 0.1 );
//		}
//		
//		// if the turret isn't firing make sure it has a owner
//		if( !IsTurretActive( mg_turret ) )
//		{
//			// get the guy back on the turret
//			self.goalradius = 12;
//			self SetGoalNode( turret_node );
//			self waittill( "goal" );
//			if( self CanUseTurret( mg_turret ) )
//			{
//				self UseTurret( mg_turret );
//				self thread fake_mg_audio( mg_turret );
//				players = get_players();
//				mg_turret SetMode("manual_ai");
//				mg_turret SetTargetEntity( players[0] );
//			}
//		}
//		
//		wait( 0.1 );
//	}	
}


fake_mg_audio( mg_gun )
{
	while(!flag("obj_to_steiner_office"))
	{
		ent = spawn( "script_origin" , (11984, -6680, 10320));
			
		while( !IsTurretActive( mg_gun ) )
		{
			wait .05;
		}
		while( !IsTurretFiring( mg_gun ) )
		{
			wait( 0.05 );
		}
		if( IsTurretFiring( mg_gun ) )
		{
			ent thread mg_firing_states( mg_gun );
			ent playloopsound( "wpn_m60_turret_fire_loop_npc" );
			level waittill( "stop_firing_audio" );
		}
			
		ent stoploopsound(.05);
		ent playsound( "wpn_m60_turret_fire_loop_ring_npc" );
			
		ent delete();
		wait .05;
	}
}


mg_firing_states(audio_gun_ent)
{
	while( IsTurretFiring( audio_gun_ent ) )
	{
		wait( 0.05 );
	}
	level notify( "stop_firing_audio" );
}



/*******************************************************************
// -- BASE STREET FUNCTIONS -- //
*******************************************************************/

/*******************************************************************
// -- INTERIOR FUNCTIONS -- //
*******************************************************************/

/*
// -- dialogue to enter the door for the interior
*/
interior_door_vo()
{
	lookat_trigger = GetEnt( "trigger_door_escape", "targetname" );
	
	flag_wait( "street_truck_destroyed" );
}


/*
// -- opens the door to the cover tracks interior
*/
interior_open_door()
{
	flag_wait( "street_mggunner" );
	
	door = GetEnt( "interior_door", "targetname" );
	door_anim_node = getstruct( "struct_objective_enter_interior", "targetname" );
	
	open_node = GetNode( "node_interior_kick_open_door", "targetname" );
	
	//start_trigger = GetEnt( "trigger_interior_kick_open_door", "targetname" );
	
	// move squad in
	level thread interior_squad_breach_move_in();
	
	//start_trigger waittill( "trigger" );
		
	// level.weaver waittill( "sound_done" );
	flag_set( "player_in_base" );
	
	// move ai to position
	old_radius = level.brooks.goalraidus;
	old_animname = level.brooks.animname;
	
	level.brooks.goalradius = 24;
	level.brooks.animname = "brooks";
	wait( 0.05 );
	
	// level.brooks SetGoalNode( open_node );
	// level.brooks waittill( "goal" );
	door_anim_node anim_reach( level.brooks, "door_kick" );
	
	// play animation
	door_anim_node anim_single( level.brooks, "door_kick" );
	
	flag_set( "area_alerted" );
	
	battlechatter_on();
	
	wait( 7.0 );
	
	level.brooks.animname = old_animname;
}


/*
// -- function called from anim. kick note track on brooks kick makes this door open
*/
interior_door_react_to_kick( guy )
{
	guy endon( "death" );
	
	door = GetEnt( "interior_door", "targetname" );
	door_clip = getent("clip_interior_door", "targetname");
	door_clip_ai = getent("clip_door_ai", "targetname");
	
	// flag set here to get all ai inside ready
	flag_set( "interior_door_kick" );
	
	door RotateYaw( 130, 0.4, 0, 0.2 );
	
	door_clip_ai connectpaths();
	door_clip_ai delete();
	door_clip trigger_off();
	
	exploder( 206 );
	
	trigger_wait("trigger_start_interior_vo");
	
	door_clip trigger_on();
	
	door RotateYaw(-130, 0.3);
}


/*
// -- controls the squad and moves them in to the breached interior room
*/
interior_squad_breach_move_in()
{
	weaver_node = GetNode( "interior_g_weaver_breach", "targetname" );
	harris_node = GetNode( "interior_r_harris_breach", "targetname" );
	brooks_node = GetNode( "interior_c_brooks_breach", "targetname" ); // -- brooks is only valid during a skip to past ledge
	
	color_trigger = GetEnt( "trigger_color_move_into_interior", "targetname" );
	
	flag_wait( "interior_door_kick" );
	
	//TUEY set music to KICK DOOR
	setmusicstate ("KICK_DOOR");
	
	level.brooks thread enable_cqbwalk();
	level.brooks force_goal( brooks_node, 12, true );
	// level.brooks thread interior_breach_without_worry();
	
	// moved the color trigger from the open_door function to here,
	// calling it to keep the sequence going, the color trigger just sends to the same node
	players = get_players();
	color_trigger UseBy( players[0] );
	
	// wait( 2.5 );
	
	// turn off weaver and send him to his node
	level.weaver thread enable_cqbwalk();
	// level.weaver SetGoalNode( weaver_node );
	// level.weaver thread interior_breach_without_worry();
	
	// wait( 2.0 );
	
	// if harris is alive send him to his node
	if( IsDefined( level.harris ) && IsAlive( level.harris ) )
	{
		// harris turn
		level.harris thread enable_cqbwalk();
		// level.harris SetGoalNode( harris_node );
		// level.harris thread interior_breach_without_worry();
	}
	
	

}

/*
// -- interior breach, gets the ai to their node and then resets them
// -- SELF == AI
*/
interior_breach_without_worry()
{
	self endon( "death" );
	
	// self.ignoreall = true;
	old_radius = self.goalradius;
	self.goalraidus = 16;
	self.ignoresuppression = true;
	// self.pacifist = true;
	self thread disable_pain();
	self thread disable_react();
	
	self waittill( "goal" );
	
	// self.ignoreall = false;
	self.ignoresuppression = false;
	// self.pacifist = false;
	self thread enable_pain();
	self thread enable_react();
	self.goalradius = old_radius;
	
}

/*
// -- set up guys destroying evidence
*/
interior_cover_tracks_init()
{
	// objects
	// interior_fight_a_spawners = GetEntArray( "spawner_interior_fight_a", "targetname" );
	interior_fire_barrel_spawners = GetEntArray( "spawner_interior_firebarrel", "targetname" );
	interior_doorway_fallback_spawners = GetEntArray( "spawner_interior_door_fallback", "targetname" );
	interior_boss_spawner = GetEnt( "spawner_interior_hole_manager", "targetname" );

	// array_thread( interior_fight_a_spawners, ::add_spawn_function, ::interior_fight_a_goal_volume );
	
	// set the field to complete
	flag_wait( "player_in_base" );
	
	// reset everything needed for _patrol to work properly
	level base_reset_patrol_flags();
	
	// spawn out the enemies
	simple_spawn( interior_fire_barrel_spawners, ::interior_firebarrel_guys );
	simple_spawn( interior_doorway_fallback_spawners, ::interior_doorway_fallback_guys );
	// simple_spawn( interior_fight_a_spawners, ::patrol_spawn_function );
	simple_spawn_single( interior_boss_spawner, ::interior_hole_boss );
	
	flag_set( "interior_prepped" );
	
}


/*
// -- firebarrel guy animation, loops anim until alerted or killed
// -- SELF == AI
*/
interior_firebarrel_guys()
{
	self endon( "death" );
	
	// make sure the guy can die
	self.allowdeath = 1;
	
	// make sure they stay in the correct areas
	self thread interior_fight_a_goal_volume();
	
	// make sure the anim name is defined
	AssertEx( IsDefined( self.script_animname ), "interior_fire_barrel missing script_string" );
	
	fire_barrel = GetEnt( "smodel_interior_barrel_fire", "targetname" );
	
	// turn off ai
	self.ignoreall = 1;
	self.pacifist = 1;
	
	// loop anim
	fire_barrel thread anim_loop_aligned( self, "burn_notice_loop" );
	
	flag_wait( "area_alerted" );
	
	// turn on ai
	self.ignoreall = 0;
	self.pacifist = 0;
	
	self notify( "stop_looping" );
	
	fire_barrel anim_single_aligned( self, "burn_notice_react" );
	
}

/*
// -- russians fall back through a doorway after the weaver kick, one should probably be shot and killed pretty quickly
// -- SELF == AI
*/
interior_doorway_fallback_guys()
{
	self endon( "death" );
	
	// make sure the guy can die
	self.allowdeath = 1;
	self.health = 5;
	
	// make sure they stay in the correct areas
	self thread interior_fight_a_goal_volume();
	
	AssertEx( IsDefined( self.script_animname ), "doorway_fallback missing script_animname" );
	
	anim_struct = getstruct( "struct_interior_breach_retreat", "targetname" );
	
	anim_struct anim_single_aligned( self, "fallback_doorway" );
	
}

/*
// -- makes the guy near the hole inside the interior turn and talk to others out of sight
// -- SELF == AI
*/
interior_hole_boss()
{
	self endon( "death" );
	
	self.allowdeath = 1;
	
	self thread interior_fight_a_goal_volume();
	
	// turn off ai
	self.ignoreall = 1;
	self.pacifist = 1;
	
	AssertEx( IsDefined( self.script_animname ), "hole boss missing script_animanme" );
	
	anim_struct = getstruct( "struct_interior_breach_retreat", "targetname" );
	
	anim_struct anim_single_aligned( self, "orders_from_the_hole" );
	
	// turn on ai
	self.ignoreall = 0;
	self.pacifist = 0;
}

/*
// -- sets the ai to the interior volume after they are alerted SELF == AI
*/
interior_fight_a_goal_volume()
{
	self endon( "death" );
	
	// objects
	interior_fight_a_volume = GetEnt( "volume_interior_fight_a", "targetname" );
	interior_fight_a_struct = getstruct( interior_fight_a_volume.target, "targetname" );
	
	flag_wait( "area_alerted" );
	
	self.goalradius = interior_fight_a_struct.radius;
	self SetGoalPos( interior_fight_a_struct.origin );
	self SetGoalVolume( interior_fight_a_volume );
	
}



/*
// -- watches the first line enemy amount and causes them to fallback when down to two
*/
interior_first_line_fallback()
{
	// objects
	start_trigger = GetEnt( "trigger_start_interior_fight", "targetname" );
	start_backup_trigger = GetEnt( "trigger_interior_backup_spawn", "targetname" );
	move_up_trigger = GetEnt( "trigger_chase_interior_first_line", "targetname" ); // this is also the friendly chain trigger

	flag_wait( "interior_door_kick" );
	
	level thread spawn_diving_guy();
		
	// watch the amount of the aigroup
	waittill_ai_group_count( "interior_garage_fight_a", 2 );
	
	// enemies fall back to another set of nodes
	first_line_guys = get_ai_group_ai( "interior_garage_fight_a" );
	
	for( i = 0; i < first_line_guys.size; i++ )
	{
		if( IsDefined( first_line_guys[i] ) && IsAlive( first_line_guys[i] ) )
		{
			// clear the goal volume set when they were spawned
			first_line_guys[i] ClearGoalVolume();
			
			first_line_guys[i].ignoreall = 1;
			first_line_guys[i].goalradius = 192;
			
			first_line_guys[i] set_spawner_targets( "interior_fallback_spots" );
			first_line_guys[i] thread wmd_ai_reset_on_goal();
		}
	}
	
	players = get_players();
	move_up_trigger UseBy( players[0] );
	start_backup_trigger UseBy( players[0] );
}


spawn_diving_guy()
{
	flag_wait("diving_guy");
	
	simple_spawn_single("diving_guy");
}


/*
// -- makes the squad move up once the second group of interior guys are defeated
*/
interior_clear_group_b_move_up()
{
	// objects
	color_trigger = GetEnt( "trigger_interior_second_line_move_up" ,"targetname" );
	
	flag_wait( "sm_trigger_interior_backup_spawn_enabled" );
	
	flag_wait( "sm_trigger_interior_backup_spawn_cleared" );
	
	// move the squad up
	players = get_players();
	color_trigger UseBy( players[0] );
	
}


activate_steiner_objective()
{
	trigger_wait("trigger_start_interior_vo");
	
	flag_set("obj_to_steiner_office");	
}


/*
// -- plays the vo for the interior 
// SaySpecificDialogue(facialanim, soundAlias, importance, notifyString, waitOrNot, timeToWait)
// -- HUDSON IS PLAYER!
// players = get_players();
// players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s01_200A_huds", 1.0, "sound_done" ); 
*/
interior_wire_vo()
{
	trigger_wait("trigger_steiner_enter");
	
	level.weaver.animname = "weaver";
	get_players()[0].animname = "hudson";
	
	level.weaver anim_single(level.weaver, "see_these_wires");		//Hudson... Do you see these wires?
	
	wait(0.5);
	
	get_players()[0] anim_single(get_players()[0], "through_the_facility");		//Yeah... Running all through the facility...
	
	wait(0.5);
	
	level.weaver anim_single(level.weaver, "rigged_to_blow");		//They've got the place rigged to blow...
	
	wait(0.5);
	
	get_players()[0] anim_single(get_players()[0], "have_much_time");		//Make it fast people... We don't have much time!
}


/*******************************************************************
// -- INTERIOR FUNCTIONS -- //
*******************************************************************/

/*******************************************************************
// -- WAREHOUSE FUNCTIONS -- //
*******************************************************************/

/*
// -- single function starts all the warehouse functions, this should make the warehouse skip to easier to setup
*/
warehouse_init()
{
	level.ready_4_warehouse = 0;
	
	level thread warehouse_steiner_story();
	level.brooks thread warehouse_steiner_office_brooks();
	level.weaver thread warehouse_steiner_office_weaver();
	// level thread warehouse_steiner_story_vo();
	level thread warehouse_steiner_office_door_init();
	level thread warehouse_seal_back_door();
	level thread warehouse_timer_init();
	level thread warehouse_open_doors();
	level thread warehouse_unload_trucks_init();
	level thread warehouse_truck_mggunner();
	level thread warehouse_line_support();
	level thread warehouse_squad_fights_out();
	level thread warehouse_escape_vo();
}


/*
// -- warehouse_steiner animations/dialogue
*/
warehouse_steiner_story()
{
	// set up the dialogue stuff for steiner's story stuff
	
	move_in_to_office_trigger = GetEnt( "trigger_enter_steiner_office", "targetname" );
	player_in_office_trigger = GetEnt( "trigger_player_in_office", "targetname" );
	anim_struct = getstruct( "struct_steiner_office_anim", "targetname" );
	
	//move_in_to_office_trigger waittill( "trigger" );
	
	trigger_wait("trigger_steiner_enter");
	
	flag_set( "steiner_office_prep" );
	
	flag_wait( "steiner_office_weaver_present" );
	flag_wait( "steiner_office_brooks_present" );
	
	// close the doors
	player_in_office_trigger waittill( "trigger" );
	
	//TUEY set music state to Steiners_office
	setmusicstate ("STEINERS_OFFICE");
	
	// autosave_by_name( "wmd" );
	
	// play the anim
	flag_set( "steiner_office_start_main" );
	
	guys = getaiarray("axis");
	
	for (i=0; i<guys.size; i++)
	{
		guys[i] thread bloody_death();
	}
}

/*
// -- VO for Steiner's office, this should probably be taken care of by the cutscene
// -- MOST LIKELY TEMPORARY
// SaySpecificDialogue(facialanim, soundAlias, importance, notifyString, waitOrNot, timeToWait)
// -- HUDSON IS PLAYER!
// players = get_players();
// players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s01_200A_huds", 1.0, "sound_done" ); 
*/
warehouse_steiner_story_vo()
{
	steiners_voice = GetEnt( "origin_steiner_speakers", "targetname" );
	
	flag_wait( "steiner_office_start_main" );
	
	level.weaver animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_467A_weav", 0.8, "sound_done" ); 
	level.weaver waittill( "sound_done" );
	
	level.weaver animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_469A_weav", 0.8, "sound_done" ); 
	level.weaver waittill( "sound_done" );
	
	players = get_players();
	players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_470A_huds", 0.8, "sound_done" ); 
	players[0] waittill( "sound_done" );
	
	players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_471A_stei_f", 0.8, "sound_done" ); 
	players[0] waittill( "sound_done" );
	
	players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_472A_huds", 0.8, "sound_done" ); 
	players[0] waittill( "sound_done" );
	
	level.weaver animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_506A_weav", 0.8, "sound_done" ); 
	level.weaver waittill( "sound_done" );
	
	players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_473A_stei_f", 0.8, "sound_done" ); 
	players[0] waittill( "sound_done" );
	
	players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_474A_stei_f", 0.8, "sound_done" ); 
	players[0] waittill( "sound_done" );
	
	players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_475A_huds", 0.8, "sound_done" ); 
	players[0] waittill( "sound_done" );
	
	level.weaver animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_476A_weav", 0.8, "sound_done" ); 
	level.weaver waittill( "sound_done" );
	
	players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_477A_stei_f", 0.8, "sound_done" ); 
	players[0] waittill( "sound_done" );
	
	level.weaver animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_478A_weav", 0.8, "sound_done" ); 
	level.weaver waittill( "sound_done" );
	
	players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_479A_huds", 0.8, "sound_done" ); 
	players[0] waittill( "sound_done" );
	
	players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_480A_stei_f", 0.8, "sound_done" ); 
	players[0] waittill( "sound_done" );
	
	players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_482A_stei_f", 0.8, "sound_done" ); 
	players[0] waittill( "sound_done" );
}


warehouse_hudson_line_470(guy)
{
	player = get_players()[0];
	player.animname = "hudson";
	
	player thread speaker_feedback();
	
	player anim_single(player, "what_is_that");		//What is that?
}


speaker_feedback()
{
	self shellshock("explosion", 3.0);
	
	self PlayRumbleOnEntity("rappel_falling");
	
	wait(3.0);
	
	StopAllRumbles();
}


warehouse_steiner_line_471(guy)
{
	speaker = GetEnt( "origin_steiner_speakers", "targetname" );
	speaker.animname = "steiner";
	
	speaker anim_single(speaker, "freidrich_steiner");		//This is Freidrich Steiner.
}


warehouse_hudson_line_472(guy)
{
	player = get_players()[0];
	player.animname = "hudson";
	
	player anim_single(player, "jamming_our_radios");		//He's jamming our radios... He knew we'd be here.
}


warehouse_steiner_line_473(guy)
{
	speaker = GetEnt( "origin_steiner_speakers", "targetname" );
	speaker.animname = "steiner";
	
	speaker anim_single(speaker, "everything_and_everyone");		//Dragovich is burying everything and everyone connected to project Nova.
}


warehouse_steiner_line_474(guy)
{
	speaker = GetEnt( "origin_steiner_speakers", "targetname" );
	speaker.animname = "steiner";
	
	speaker anim_single(speaker, "will_be_next");		//I am sure I will be next.
}


warehouse_hudson_line_475(guy)
{
	player = get_players()[0];
	player.animname = "hudson";
	
	player anim_single(player, "do_you_want");		//What do you want?
}


warehouse_steiner_line_477(guy)
{
	speaker = GetEnt( "origin_steiner_speakers", "targetname" );
	speaker.animname = "steiner";
	
	speaker anim_single(speaker, "sleeper_cells_waiting");		//All across America, Dragovich has sleeper cells waiting for the signal to release the Nova 6.
}


warehouse_hudson_line_479(guy)
{
	player = get_players()[0];
	player.animname = "hudson";
	
	player anim_single(player, "numbers_broadcast");		//The numbers broadcasts - What do they mean?
}


warehouse_steiner_line_480(guy)
{
	speaker = GetEnt( "origin_steiner_speakers", "targetname" );
	speaker.animname = "steiner";
	
	//speaker anim_single(speaker, "36_hours");	//In 36 hours, the sleeper agents will receive their final orders.  Only I can tell you how to stop the broadcast.
	
	speaker anim_single(speaker, "for_my_safety");		//I will tell you everything in exchange for my safety.
}


warehouse_steiner_line_482(guy)
{
	speaker = GetEnt( "origin_steiner_speakers", "targetname" );
	speaker.animname = "steiner";
	
	speaker anim_single(speaker, "choice_is_yours");		//I am at Rebirth Island - the Aral Sea... The choice is yours.
	
	player = get_players()[0];
	player shellshock("explosion", 3.0);
	player PlayRumbleOnEntity("rappel_falling");
	wait(3.0);
	StopAllRumbles();
	
	//Tuey Set Music to Warehouse_fight
	setmusicstate ("WAREHOUSE_FIGHT");
}


/*
// -- starts thre threads for all the doors in steiner's office
*/
warehouse_steiner_office_door_init()
{
	// single door
	office_single_door = GetEnt( "steiner_door_single", "targetname" );
	
	// double doors
	office_double_door_left = GetEnt( "steiner_door_double_L", "targetname" );
	office_double_door_right = GetEnt( "steiner_door_double_R", "targetname" );
	
	office_single_door thread warehouse_steiner_office_single_door();
	
	office_double_door_left thread warehouse_steiner_office_double_door();
	office_double_door_right thread warehouse_steiner_office_double_door();
}


/*
// -- single door to steiner's office, this one starts open and is the one the squad enters
// -- SELF == DOOR MODEL
*/
warehouse_steiner_office_single_door()
{
	AssertEx( IsDefined( self.target ), "single_door missing target" );
	
	door_coll = GetEnt( self.target, "targetname" );
	
	door_coll LinkTo( self );
	
	// door should start open and close when the player activates the scene
	flag_wait( "steiner_office_start_main" );
	
	//clean up ai
	guys = getaiarray("axis");
	for(i=0; i<guys.size; i++)
	{
		guys[i] thread bloody_death(true, 1);
	}
	
	// slam shut
	self RotateYaw( -180, 0.5, 0.1, 0.1 );
	self PlaySound( "evt_wmd_lab_door_slam" );
	self waittill( "rotatedone" );
	self DisconnectPaths();
	door_coll DisconnectPaths();
	
	// wait for the scene to end
	//flag_wait( "warehouse_defend" );
	flag_wait("open_steiner");
	
	// open up
	self RotateYaw( 180, 0.7, 0.1, 0.3 );
	self PlaySound( "evt_wmd_lab_door_unlock" );
	self waittill( "rotatedone" );
	door_coll ConnectPaths();
	self ConnectPaths();	
}


/*
// -- double door control for steiner's office
*/
warehouse_steiner_office_double_door()
{
	AssertEx( IsDefined( self.target ), "one of the double_doors is missing a target for collision" );
	
	door_coll = GetEnt( self.target, "targetname" );
	
	door_coll LinkTo( self );
	
	// no need to wait for the scene to start cause these start closed
	
	// wait for the flag to open though
	//flag_wait( "warehouse_defend" );
	flag_wait("open_steiner");
	
	if( self.targetname == "steiner_door_double_L" )
	{
		self RotateYaw( 160, 0.7, 0.1, 0.3 );
		self waittill( "rotatedone" );
		door_coll ConnectPaths();
		self ConnectPaths();
	}
	else if( self.targetname == "steiner_door_double_R" )
	{
		self RotateYaw( -160, 0.7, 0.1, 0.3 );
		self waittill( "rotatedone" );
		door_coll ConnectPaths();
		self ConnectPaths();
	}
	
}


/*
// -- warehouse steiner office scene on brooks
*/
warehouse_steiner_office_brooks()
{
	self endon( "death" );
	
	anim_struct = getstruct( "struct_steiner_office_anim", "targetname" );
	
	flag_wait( "steiner_office_prep" );
	
	self disable_ai_color();
	
	old_goalradius = self.goalradius;
	self.goalradius = 6;
	self.ignoreall = 1;
	self.ignoreme = 1;
	old_animname = self.animname;
	self.animname = "brooks";
	// self thread enable_cqbwalk();
	
	// get to the start point
	anim_struct anim_reach_aligned( self, "office_leadin" );
	
	anim_struct anim_single_aligned( self, "office_leadin" );
	
	anim_struct thread anim_loop_aligned( self, "office_loop" );
	
	flag_set( "steiner_office_brooks_present" );
	
	// wait for the player to get in the room
	while( !flag( "steiner_office_start_main" ) )
	{
		wait( 0.1 );
	}
	
	// stop the animn
	self notify( "stop_looping" );
	
	get_players()[0] SetLowReady(true);
	
	anim_struct anim_single_aligned( self, "office_main" );
	
	get_players()[0] SetLowReady(false);
	
	self.goalraidus = old_goalradius;
	self.ignoreall = 0;
	self.ignoreme = 0;
	self.pacifist = 0;
	self.animname = old_animname;
	self thread disable_cqbwalk();
	
	//node = getnode("node_brooks_steiner", "targetname");
	
	//self thread force_goal();
	
	//self setgoalnode(node);
}


/*
-- warehouse steiner office scene on weaver
*/
warehouse_steiner_office_weaver()
{
	self endon( "death" );
	
	anim_struct = getstruct( "struct_steiner_office_anim", "targetname" );
	
	flag_wait( "steiner_office_prep" );
	
	self disable_ai_color();
	
	old_goalradius = self.goalradius;
	self.goalradius = 6;
	self.ignoreall = 1;
	self.ignoreme = 1;
	old_animname = self.animname;
	self.animname = "weaver";
	// self thread enable_cqbwalk();
	
	anim_struct anim_reach_aligned( self, "office_leadin" );
	anim_struct anim_single_aligned( self, "office_leadin" );
	
	anim_struct thread anim_loop_aligned( self, "office_loop" );
	
	flag_set( "steiner_office_weaver_present" );
	
	// wait for the player to enter the room
	while( !flag( "steiner_office_start_main" ) )
	{
		wait( 0.05 );
	}
	
	// stop the loop
	self notify( "stop_looping" );
	
	level thread open_the_doors();
	
	anim_struct anim_single_aligned( self, "office_main" );
	
	//flag_set( "warehouse_fight_prepare" );
	
	self.goalraidus = old_goalradius;
	self.ignoreall = 0;
	self.ignoreme = 0;
	self.pacifist = 0;
	self.animname = old_animname;
	self thread disable_cqbwalk();
	
	//node = getnode("node_weaver_steiner", "targetname");
	
	//self thread force_goal();
	
	//self setgoalnode(node);
}


open_the_doors()
{
	animtime = GetAnimLength(level.scr_anim[ "weaver" ][ "office_main" ]);
	
	wait(animtime - 5.5);
	
	flag_set( "warehouse_fight_prepare" );
	flag_set( "warehouse_defend" );
	
	wait(3.0);
	
	flag_set("open_steiner");
}


/*
// -- closes off the back way in for the warehouse, happens during the steiner lock down
*/
warehouse_seal_back_door()
{
	garage_door = GetEnt( "sbrush_close_off_warehouse", "targetname" );
	
	garage_door Hide();
	
	AssertEx( IsDefined( garage_door.script_int ), "garage_door missing script int" );
	
	flag_wait( "steiner_office_start_main" );
	
	garage_door Show();
	
	garage_door MoveZ( ( garage_door.script_int * -1 ), 2.5, 0, 0.2 );
	garage_door waittill( "movedone" );
	garage_door DisconnectPaths();
	
	// clean up the mg in the tower
	mg_gunner = GetEnt( "spawner_base_mgunner_ai", "targetname" );
	spawner = GetEnt( "spawner_base_mgunner", "targetname" );
	if( IsDefined( spawner ) )
	{
		// delete the spawner to stop the flood spawning
		spawner Delete();
	}
	
	if( IsDefined( mg_gunner ) && IsAlive( mg_gunner ) )
	{
		mg_gunner thread stop_magic_bullet_shield();
		mg_gunner Delete();
	}
}


/*
// -- opens the doors of the warehouse that leads to the street
*/
warehouse_open_doors()
{
	// objects
	fx_anim_hangar_door = GetEnt( "fxanim_wmd_hangar_doors_mod", "targetname" );
	fx_anim_hangar_door DisconnectPaths();
	
	flag_wait( "warehouse_fight_prepare" );
	
	//flag_wait( "warehouse_fight_ready" );
		
	//flag_set( "warehouse_defend" );
	
	level notify( "hangar_doors_start" );
	
	level thread connect_hangar_paths();
	
	wait( 1.0 );
	
	fx_anim_hangar_door ConnectPaths();
	
	// finished with first part, start the infantry
	flag_set( "warehouse_doors_phase_1" );
	
	flag_set( "warehouse_doors_open" );
	
	battlechatter_on();
	
	if (isdefined(level.streamhint))
	{
		level.streamhint delete();
	}
}


connect_hangar_paths()
{
	door1 = getent("warehouse_door_1", "targetname");
	door2 = getent("warehouse_door_2", "targetname");
	door3 = getent("warehouse_door_3", "targetname");
	door4 = getent("warehouse_door_4", "targetname");
	
	wait(2.0);
	
	door1 connectpaths();
	door1 delete();
	
	wait(3.0);
	
	door2 connectpaths();
	door2 delete();
	
	wait(3.0);
	
	door3 connectpaths();
	door3 delete();
	
	wait(4.0);
	
	door4 connectpaths();
	door4 delete();
}


/*
// -- sits on the door and waits for the move to finish before setting a flag
*/
warehouse_door_flag_set() // -- SELF == SCRIPT BRUSHMODEL
{
	self ent_flag_init( "movedone" );
	
	self waittill( "movedone" );
	
	self ent_flag_set( "movedone" );
}


/*
// -- two trucks are already at the door and beging unloading when the doors are opening
// -- sets up the spawners and threads off the function to unload the group
*/
warehouse_unload_trucks_init()
{
	// objects
	rear_line_spawners = GetEntArray( "warehouse_spawner_unload_rear_line", "targetname" );
	office_line_spawners = GetEntArray( "warehouse_spawner_unload_office_line", "targetname" );
	// trucks are named: warehouse_veh_unload_trucks
	
	// spawn functions for the spawners go here
	array_thread( rear_line_spawners, ::add_spawn_function, ::warehouse_rear_line );
	array_thread( office_line_spawners, ::add_spawn_function, ::warehouse_office_line );

	flag_wait( "warehouse_fight_prepare" );
	
	// spawn out the trucks and guys
	trigger_use("trigger_warehouse_truck1");
	wait(1.5);
	trigger_use("trigger_warehouse_truck2");
	
	level.ready_4_warehouse++;
	
	flag_wait( "warehouse_defend" );
	
	trigger_use("triggercolor_office_line0");
	trigger_use("triggercolor_rear_line0");
		
	// clean up
	// array_delete( rear_line_spawners );
	// array_delete( office_line_spawners );
	
	// functions for controlling the group
	level thread warehouse_office_line_think();
	level thread warehouse_rear_line_think();
}


/*
// -- unload guys control function
*/
warehouse_unload_enemy_mind()
{
	self endon( "death" );
	
	self.ignoreall = true;
	self.ignoreme = true;
	self.goalradius = 16;
	
	self waittill( "jumpedout" );
	
	self.ignoreall = false;
	self.ignoreme = false;
	self.goalradius = 16;
	
	self waittill( "goal_changed" );
}

/*
// -- office line, group of ai closest to the office
*/
warehouse_office_line()
{
	self endon( "death" );
	self endon( "rushertime" );
	
	fight_volume_0 = GetEnt( "volume_office_line_0", "targetname" );
	fight_volume_1 = GetEnt( "volume_office_line_1", "targetname" );
	
	//self warehouse_unload_enemy_mind();
	
	//set to new targets
	//self set_spawner_targets( "nodea_office_line_0" );
	//self waittill( "goal" );
	//self SetGoalVolume( fight_volume_0 );
	//self.goalradius = 256;
	
	flag_wait( "warehouse_front" );
	
	// should weaken the guy?
	// turn off surpression so he moves right away
	
	//self.ignoresuppression = true;
	//self.goalradius = 16;
	//self set_spawner_targets( "nodea_office_line_1" );
	//self waittill( "goal" );
	//self SetGoalVolume( fight_volume_1 );
	
	//self waittill( "goal" );
	
	//self.goalradius = 16;
	//self.ignoresuppression = false;
}


/*
// -- moves the office_line by watching aigroup and sending the rest to a new area
*/
warehouse_office_line_think()
{
	level endon( "warehouse_front" );
	level thread warehouse_office_line_rushed(); // -- WWILLIAMS: FAILSAFE FOR THOSE WHO LIKE TO PUSH UP
	
	waittill_ai_group_amount_killed( "warehouse_office_line", 4 );
	
	office_line_ai = get_ai_group_ai( "warehouse_office_line" );
	
	if (office_line_ai.size > 0)
	{
		rusher_guy = office_line_ai[ RandomInt( office_line_ai.size ) ];
		wait( 0.05 );
		if( IsAlive( rusher_guy ) )
		{
			rusher_guy notify( "rushertime" );
			rusher_guy thread maps\_rusher::rush();
		}
	}

	wait( 0.1 );
	
	flag_set( "warehouse_front" );	
}


/*
// -- counter way to push the ai back, this is for players who push forward
*/
warehouse_office_line_rushed()
{
	level endon( "warehouse_front" );
	
	take_front_trigger = GetEnt( "trigger_warehouse_push_from_front", "targetname" );
	
	take_front_trigger waittill( "trigger" );
	
	office_line_ai = get_ai_group_ai( "warehouse_office_line" );
	
	rusher_guy = office_line_ai[ RandomInt( office_line_ai.size ) ];
	wait( 0.05 );
	if( IsAlive( rusher_guy ) )
	{
		rusher_guy notify( "rushertime" );
		rusher_guy thread maps\_rusher::rush();
	}

	wait(3.0);
	
	flag_set( "warehouse_front" );
}

/*
// -- runs on the ai that fill up the rear fight of the warehouse
// -- SELF == AI
*/
warehouse_rear_line()
{
	self endon( "death" );
	self endon( "rushertime" );
	
	fight_volume_0 = GetEnt( "volume_rear_line_0", "targetname" );
	fight_volume_1 = GetEnt( "volume_rear_line_1", "targetname" );
	
	//self warehouse_unload_enemy_mind();
	
	
	// send to node
	//self set_spawner_targets( "nodea_rear_line_0" );
	//self waittill( "goal" );
	//self SetGoalVolume( fight_volume_0 );
	//self.goalradius = 256;
	
	flag_wait( "warehouse_rear" );
	
	self.ignoresuppression = true;
	//self.goalradius = 16;
	//self set_spawner_targets( "nodea_rear_line_1" );
	//self waittill( "goal" );
	//self SetGoalVolume( fight_volume_1 );
	//self.goalradius = 256;
	
	//self waittill( "goal" );
	
	self.ignoresuppression = false;
}

/*
// -- moves the office_line by watching aigroup and sending the rest to a new area
*/
warehouse_rear_line_think()
{
	level endon( "warehouse_rear" );
	level thread warehouse_rear_line_rushed(); // -- WWILLIAMS: FAILSAFE FOR THOSE WHO RUN FORWARD
	
	flag_wait( "warehouse_front" );
	
	// waittill_ai_group_count( "warehouse_rear_line", 6 );
	while( get_ai_group_sentient_count( "warehouse_rear_line" ) > 6 )
	{
		wait( 0.7 );
	}
	
	// two rushers this time?
	
	flag_set( "warehouse_rear" );
}


/*
// -- counters a pusher type player who just moves forward
*/
warehouse_rear_line_rushed()
{
	level endon( "warehouse_rear" );
	
	take_rear_trigger = GetEnt( "trigger_warehouse_push_from_rear", "targetname" );
	
	take_rear_trigger waittill( "trigger" );
	
	// remember to add the special reaction that this line uses
	
	flag_set( "warehouse_rear" );
}


/*
// -- controls the sniper line that keeps the player back from the door
*/
warehouse_line_support()
{
	// start the sniper line support
	flag_wait( "warehouse_fight_prepare" );
	
	while( level.ready_4_warehouse <= 1 )
	{
		wait( 0.1 );
	}
	
	// get those doors open
	flag_set( "warehouse_fight_ready" );
	
	// move the squad up to the 3rd line
	flag_wait( "warehouse_rear" );
	
	// waittill_ai_group_cleared( "warehouse_office_line" );
	while( get_ai_group_sentient_count( "warehouse_office_line" ) > 0 )
	{
		wait( 1.0 );
	}
	
	flag_set( "warehouse_out_to_street" );

}

/*
// -- puts an enemy on the truck MG before the warehouse door opens could also keep guys spawning and getting on it
*/
warehouse_truck_mggunner()
{
	flag_wait( "warehouse_fight_prepare" );
	
	// spawn out the truck
	truck_spawn_trigger = GetEnt( "trigger_spawn_truck_mg", "targetname" );
	players = get_players();
	truck_spawn_trigger UseBy( players[0] );
	level waittill( "vehiclegroup spawned5005" );
	wait( 0.2 );
	
	// objects
	mg_truck = GetEnt( "vehicle_escape_truck", "targetname" );
	gunner_spawner = GetEnt( "spawner_truck_gunner", "targetname" );
	driver_spawner = GetEnt( "spawner_truck_driver", "targetname" );
	
	// spawn out the guy
	truck_gunner = simple_spawn_single( gunner_spawner );
	truck_gunner.ignoreme = 1;
	truck_gunner.ignoreall = 1;
	truck_gunner.truck = mg_truck;
	truck_gunner gun_remove();
	truck_gunner.animname = "generic";
	
	// put him on the truck
	truck_gunner maps\_vehicle_aianim::vehicle_enter( mg_truck, "tag_gunner1" );
	
	// set up two guys for the front
	/*
	truck_driver = simple_spawn( driver_spawner );
	driver = truck_driver[0];
	truck_passenger = simple_spawn( driver_spawner );
	passenger = truck_passenger[0];
	wait( 0.1 );
	
	driver.ignoreall = true;
	driver.ignoreme = true;
	passenger.ignoreall = true;
	passenger.ignoreme = true;
	

	driver thread run_to_vehicle_load( mg_truck, false, "tag_driver" );
	passenger thread run_to_vehicle_load( mg_truck, false, "tag_passenger" );
	*/
	
	level.ready_4_warehouse++;
	
	flag_wait( "warehouse_defend" );
	
	// send the truck to the right place
	mg_truck thread go_path();
	
	mg_truck thread warehouse_truck_turret_think();
	
	mg_truck waittill( "reached_end_node" );
	
	// -- get the driver and passenger out the front
	/*
	mg_truck thread maps\_vehicle_aianim::guy_unload( driver, "tag_driver" );
	driver.ignoreall = false;
	driver.ignoreme = false;

	mg_truck thread maps\_vehicle_aianim::guy_unload( passenger, "tag_passenger" );
	passenger.ignoreall = false;
	passenger.ignoreme = false;
	*/

	//self magic_bullet_shield();
	truck_gunner waittill ("death");
	
	flag_set("warehouse_mg_dead");
	
	mg_truck ClearGunnerTarget();
	
	truck_gunner ragdoll_death();
}

/*
// -- warehouse truck turret think, makes the gun fire at the player
// -- SELF == TRUCK
*/
warehouse_truck_turret_think()
{
	self endon( "warehouse_mg_dead" );
	
	sound_ent = Spawn( "script_origin", (11792, -4247, 9992) );
	//sound_ent LinkTo( self, "rear_hatch_jnt" );
	sound_ent thread delete_sound_ent();
	
	wait( 2 );
	
	while( !flag( "warehouse_mg_dead" ) )
	{
		players = get_players();
		shoot_time = RandomIntRange( 5, 18 );
		self SetGunnerTargetEnt( players[0], ( 0, 0, RandomIntRange( 57, 80 ) ) ); //TODO: offset
		
		for (i = 0; i < shoot_time; i++ )
		{
			if( flag( "warehouse_mg_dead" ) )
			{
				break;
			}
			self FireGunnerWeapon ();
			sound_ent PlayLoopSound( "wpn_pbr_turret_fire_loop_npc" );
			wait (0.2);
		}
		
		if( IsDefined( sound_ent ) )
		{
		    sound_ent StopLoopSound( .05 );
		    sound_ent playsound( "wpn_pbr_turret_fire_loop_ring_npc" );
		}

		self PlaySound( "wpn_gaz_quad50_flux_npc_l" );
		
		wait ( RandomFloatRange( 1, 4 ) );	
	}	
	
	
}

/*
// -- deletes the script origin that is playing the mg sound for the truck
// -- SELF == SCRIPT ORIGIN
*/
delete_sound_ent()
{
	flag_wait( "warehouse_mg_dead" );
	
	self Delete();
}



/*
// -- sends each russian to the protect zone -- SELF = AI
*/
warehouse_head_to_protect_volume( ent_volume, str_spawner_targets )
{
	self endon( "death" );
	
	old_goalradius = self.goalradius;
	self.goalradius = 64;
	
	self set_spawner_targets( str_spawner_targets );
	
	wait( 0.05 );
	
	self SetGoalVolume( ent_volume );
	
	self waittill( "goal" );
	
	self.goalradius = old_goalradius;
}

/*
// -- turns off the ai until the doors start to open for the warehouse fight
*/
warehouse_ambush_wait_for_doors()
{
	self endon( "death" );
	
	if( flag( "warehouse_defend" ) )
	{
		return;
	}
	
	self.ignoreall = 1;
	self.ignoreme = 1;
	
	flag_wait( "warehouse_defend" );
	
	self.ignoreall = 0;
	self.ignoreme = 0;
	
	
}

/*
// -- moves the squad out to the truck after the defend
*/
warehouse_squad_fights_out()
{
	colors_trigger_0 = GetEnt( "trigger_fight_out_warehouse_0", "targetname" );
	colors_trigger_1 = GetEnt( "trigger_fight_out_warehouse_1", "targetname" );
	colors_trigger_2 = GetEnt( "trigger_fight_out_warehouse_2", "targetname" );
	colors_trigger_3 = GetEnt( "trigger_fight_out_warehouse_3", "targetname" );
	
	take_front_trigger = GetEnt( "trigger_warehouse_push_from_front", "targetname" );
	take_rear_trigger = GetEnt( "trigger_warehouse_push_from_rear", "targetname" );
	warehouse_cleared = GetEnt( "trigger_warehouse_cleared", "targetname" );
	
	truck_node_array = GetNodeArray( "node_skipto_avalanche", "targetname" );
	brooks_truck_node = GetNode( "node_brooks_truck", "script_noteworthy" );
	weaver_truck_node = GetNode( "node_weaver_truck", "script_noteworthy" );
	
	escape_truck = GetEnt( "vehicle_escape_truck", "targetname" );
	
	//flag_wait( "warehouse_fight_prepare" );
	flag_wait("open_steiner");
	
	level.weaver enable_ai_color();
	level.brooks enable_ai_color();
	
	players = get_players();
	colors_trigger_0 UseBy( players[0] );
	
	// take_front_trigger waittill( "trigger" );
	
	flag_wait( "warehouse_front" );
	
	trigger_use("triggercolor_office_line1");
		
	players = get_players();
	colors_trigger_1 UseBy( players[0] );
	
	// take_rear_trigger waittill( "trigger" );
	
	flag_wait( "warehouse_rear" );
	
	trigger_use("triggercolor_rear_line1");
	
	players = get_players();
	colors_trigger_2 UseBy( players[0] );
		
	flag_wait( "warehouse_out_to_street" );
	
	players = get_players();
	colors_trigger_3 UseBy( players[0] );
	
	//guys_left = GetAIArray( "axis" );
	
	//while( guys_left.size > 0 )
	//{
	//	guys_left = GetAIArray( "axis" );
	//	wait( 0.1 );
		//guys_left = remove_dead_from_array( guys_left );
	//	PrintLn( guys_left.size + " axis still alive" );
	//}
	
	flag_set( "warehouse_cleared" );
	flag_set( "run_for_truck" );
	
	flag_wait("truck_reinforce");
	
	level.weaver SetGoalNode( brooks_truck_node );
	level.brooks SetGoalNode( weaver_truck_node );
		
	trigger_use("triggercolor_office_line2");
	trigger_use("triggercolor_rear_line2");
	
	flag_wait( "player_on_truck" );
	
	//TUEY set music state to TRUCK
	setmusicstate ("TRUCK");
	
	
		
	// level.weaver thread run_to_vehicle_load( escape_truck, true, "tag_driver" );
	// level.brooks thread run_to_vehicle_load( escape_truck, true, "tag_passenger" );
	
}

/*
// -- dialogue lines to escape the base after steiner's office
// SaySpecificDialogue(facialanim, soundAlias, importance, notifyString, waitOrNot, timeToWait)
// -- HUDSON IS PLAYER!
// players = get_players();
// players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s01_200A_huds", 1.0, "sound_done" ); 
*/
warehouse_escape_vo()
{
	level endon( "player_on_truck" );
	
	// Nag Lines
	line_1 = "vox_wmd1_s02_485A_huds";
	line_2 = "vox_wmd1_s02_486A_huds";
	line_3 = "vox_wmd1_s02_487A_weav";
	line_4 = "vox_wmd1_s02_488A_weav";
	
	//flag_wait( "warehouse_defend" );
	flag_wait("open_steiner");
	
	// line from hudson to run
	players = get_players();
	players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_483A_huds", 0.8, "sound_done" ); 
	players[0] waittill( "sound_done" );
	
	// TEMP: TODO: FIND BETTER WAY TO TRIGGER THESE TWO LINES
	wait( RandomIntRange( 4, 8 ) );
	
	players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s02_484A_huds", 0.8, "sound_done" ); 
	players[0] waittill( "sound_done" );
	
	while( !flag( "player_on_truck" ) ) 
	{
		play_nag_line = RandomInt( 3 );
		
		switch( play_nag_line )
		{
			case "0":
				players[0] animscripts\face::SaySpecificDialogue( undefined, line_1, 0.8, "sound_done" ); 
				players[0] waittill( "sound_done" );
				wait( RandomIntRange( 2, 4 ) );
				break;
				
			case "1":
				players[0] animscripts\face::SaySpecificDialogue( undefined, line_2, 0.8, "sound_done" ); 
				players[0] waittill( "sound_done" );
				wait( RandomIntRange( 2, 4 ) );
				break;
			
			case "2":
				level.weaver animscripts\face::SaySpecificDialogue( undefined, line_3, 0.8, "sound_done" ); 
				level.weaver waittill( "sound_done" );
				wait( RandomIntRange( 2, 4 ) );
				break;
				
			case "3":
				level.weaver animscripts\face::SaySpecificDialogue( undefined, line_4, 0.8, "sound_done" ); 
				level.weaver waittill( "sound_done" );
				wait( RandomIntRange( 2, 4 ) );
				break;
		}
		
		wait( RandomIntRange( 5, 12 ) );
	}
	
}

/*
// -- starts the timer and watches to see if the player made it out in time
*/
warehouse_timer_init()
{
	//flag_wait( "warehouse_defend" );
	flag_wait("open_steiner");
	
	level thread warehouse_time_over_death();
	level thread warehouse_player_reached_truck();
	
	screen_timer_create(180, "warehouse_timer_done");
	
	flag_set( "warehouse_timer_on" );
}

/*
// -- if the timer in the warehouse hits 0 then this kills the player
*/
warehouse_time_over_death()
{
	level endon( "player_on_truck" );
	
	flag_wait( "warehouse_timer_on" );
	
	level waittill( "warehouse_timer_done" );
	
	// kill the player
	players = get_players();
	more_booms = Spawn( "script_model", players[0].origin );
	more_booms SetModel( "tag_origin" );
	PlayFX( level._effect[ "temp_explosion" ], players[0].origin, AnglesToForward( players[0].angles ) );
	
	players[0] DoDamage( players[0].health + 500, players[0].origin );
	
	maps\_utility::missionfailedwrapper(&"WMD_TIMER_FAIL");
	
	PlayFXOnTag( level._effect[ "temp_explosion" ], more_booms, "tag_origin" );
	wait( RandomFloatRange( 0.2, 0.7 ) );
	
	PlayFXOnTag( level._effect[ "temp_explosion" ], more_booms, "tag_origin" );
	wait( RandomFloatRange( 0.2, 0.7 ) );
	
	PlayFXOnTag( level._effect[ "temp_explosion" ], more_booms, "tag_origin" );
	wait( RandomFloatRange( 0.2, 0.7 ) );	
}


/*
// -- stop timer once player is on the truck
*/
warehouse_player_reached_truck()
{
	flag_wait( "player_on_truck" );
	
	level thread screen_timer_delete();
	
}


/*
// -- WWILLIAMS: STOLEN FROM K. DREW IN_COUNTRY SO I CAN SET UP THE TIMER IN THE WAREHOUSE
*/
screen_timer_create( time_remaining, str_notify )
{
	AssertEx( IsDefined( time_remaining ), "no time passed in to the timer!" );
	AssertEx( IsDefined( str_notify ), "no string passed in to the timer!" );
	
	//remove the previous message if it exists
	screen_timer_delete();

	//wait a frame to insure the new message is not deleted
	wait 0.05;

	//text element that displays the name of the event
	level._screen_timer = NewHudElem(); 
	level._screen_timer.horzAlign = "user_right";
	level._screen_timer.vertAlign = "user_top";
	level._screen_timer.alignX = "left";
	level._screen_timer.alignY = "top";
	level._screen_timer.x = -150;
	level._screen_timer.y = 32;
	level._screen_timer.sort = 2;
	level._screen_timer.fontscale = 2.5;
	level._screen_timer.color = ( 1, 1, 1 );
	level._screen_timer.alpha = 1;

	level._screen_timer thread screen_internal_timer( time_remaining, str_notify );
}

screen_internal_timer( time_remaining, string_notify )
{
	self endon("screen_timer_stop");
	self setTenthsTimer( time_remaining );

	//grabs the system clock at the creation of the timer in MS
	start = GetTime();

	//set the text of the element to the string passed in
	while( GetTime() - start < time_remaining * 1000 )
	{
		wait(0.05);
	}

	//send out timer over notifies
	level notify("screen_timer_reached");

	//send the optional notify if it exists
	if( IsDefined(string_notify) )
	{
		level notify(string_notify);
	}

	//leave the timer up for a full second
	wait(1);

	//remove the hud element
	self Destroy();

}

screen_timer_delete()
{
	if( IsDefined(level._screen_timer) )
	{
		level._screen_timer notify("screen_timer_stop");
		level._screen_timer Destroy();
	}
}



/*******************************************************************
// -- WAREHOUSE FUNCTIONS -- //
*******************************************************************/

/*******************************************************************
// -- TRUCK FUNCTIONS -- //
*******************************************************************/

/*
// -- truck init, this way the main or the skip to can call it
*/
truck_init()
{
	if( !IsDefined( level.base_skipto_avalanche ) || !level.base_skipto_avalanche )
	{
		level thread truck_is_player_on();
	}
	
	level thread truck_enemies();
	level thread truck_base_detonations();
	level thread truck_heat_pipes();
	level thread truck_wall_react();
	level thread truck_surf_down_road();
	level thread truck_avalanche_control();
	level thread truck_runs_from_avalanche();
	level thread truck_temp_escape_dialogue();
	level thread truck_reinforce();
	level thread disable_diveto_prone();
}


disable_diveto_prone()
{
	flag_wait("truck_reinforce");
	
	allow_divetoprone(false);
}


truck_reinforce()
{
	array_thread(getentarray("reinforce_guys", "targetname"), ::add_spawn_function, ::setup_reinforce_guys);
	
	flag_wait("player_on_truck");
	
	trigger_use("trigger_truck_reinforce1");
	
	wait(3.0);
	
	trigger_use("trigger_truck_reinforce2");
}


setup_truck_reinforce()
{
	self waittill("reached_end_node");
	
	self setbrake(true);
}


setup_reinforce_guys()
{
	self endon("death");
	
	flag_wait("player_on_truck");
	
	self.script_accuracy = 0.1;
}


/*
// -- watches for the player to get on the truck
*/
#using_animtree("wmd");
truck_is_player_on()
{
	//flag_wait( "warehouse_cleared" );
	flag_wait("warehouse_rear");
	
	truck = GetEnt( "vehicle_escape_truck", "targetname" );
	get_on_trigger = GetEnt( "trigger_truck_get_on", "targetname" );
	
	truck thread veh_magic_bullet_shield( 1 );
	
	truck MakeVehicleUnusable();
	
	gunner = getent("spawner_truck_gunner_ai", "targetname");
	
	while(isAlive(gunner))
	{
		gunner = getent("spawner_truck_gunner_ai", "targetname");
		
		wait(0.1);
	}
	
	player = get_players()[0];
	
	dist = int(Distance2D(truck.origin, player.origin));
	
	while(dist > 80)
	{
		player = get_players()[0];
		
		dist = int(Distance2D(truck.origin, player.origin));
		
		wait(0.05);
	}
		
	player takeallweapons();
	
	player setstance("stand");
	
	player_hands = spawn_anim_model("player_hands", truck.origin, truck.angles);
	
	//player PlayerLinkToAbsolute(player_hands, "tag_player");
	player playerlinktoabsolute(player_hands);
	
	player hideviewmodel();
	
	flag_set("mounting_truck");
	
	truck anim_single_aligned(player_hands, "mount_truck");
	
	player unlink();
	player_hands delete();
			
	truck UseVehicle( player, 1 );
	
	truck thread maps\wmd_amb::player_turret_audio();
			
	flag_set( "player_on_truck" );
	
	battlechatter_off("allies");
	
	wait( 6.0 );
	
	flag_wait( "base_explosions_done" );
	
	flag_wait( "base_quiet_before_storm_done" );
}


// -- spawn manager control for the truck moment
truck_enemies()
{
	array_thread(getentarray("pre_avalanche", "targetname"), ::add_spawn_function, ::setup_pre_avalanche);
	array_thread(getentarray("last_guard", "targetname"), ::add_spawn_function, ::setup_pre_avalanche);
		
	//flag_wait( "player_on_truck" );
	flag_wait("truck_reinforce");
	
	spawn_manager_enable("manager_pre_avalanche");
	
	flag_wait("ready_explosion");
	
	//spawn_manager_kill("manager_pre_avalanche");
	
	flag_wait("base_shaken");
	
	wait(0.1);
	
	boom = getstruct("pre_avalanche_boom", "targetname");
	
	RadiusDamage(boom.origin, 2100, 300, 300, get_players()[0], "MOD_EXPLOSIVE");
	
	simple_spawn_single("rpg_avalanche1", ::setup_rpg_avalanche1);
	wait(2.5);
	simple_spawn_single("rpg_avalanche2", ::setup_rpg_avalanche2);
	
	flag_wait("truck_go");
	
	spawn_manager_kill("manager_pre_avalanche");
}


setup_pre_avalanche()
{
	self endon("death");
	
	self.health = 1;
	self.script_accuracy = 0.1;
	self.goalradius = 16;
	self waittill("goal");
	wait(0.1);
	self.goalradius = 16;
}


setup_rpg_avalanche1()
{
	self endon("death");
	
	self.script_accuracy = 0.1;
	self setcandamage(false);
	self.goalradius = 16;
	self waittill("goal");
	wait(0.1);
	self.goalradius = 16;
	
	self aim_at_target(get_players()[0]);
	
	rpgtrg = getstruct("rpg_target1", "targetname");
	
	MagicBullet("rpg_magic_bullet_sp", self.origin + (32, 32, 44), get_players()[0].origin + (-30, 0, 66));
	
	self setcandamage(true);
	
	wait(2.0);
	
	spawn_manager_enable("truck_end_rear");
	
	flag_wait("finish_avalanche");
	
	spawn_manager_disable("truck_end_rear");
}


setup_rpg_avalanche2()
{
	self endon("death");
	
	self setcandamage(false);
	self.goalradius = 16;
	self waittill("goal");
	wait(0.1);
	self.goalradius = 16;
	
	self aim_at_target(get_players()[0]);
	
	rpgtrg = getstruct("rpg_target2", "targetname");
	
	MagicBullet("rpg_magic_bullet_sp", self.origin + (32, 32, 44), get_players()[0].origin + (0, 0, 75));
	
	self setcandamage(true);
}


// -- deals with the explosions that happen on the street during the truck turret event
truck_base_detonations()
{
	flag_wait( "base_explosions" );
	
	// walk the explosions to the player
	
	// big building in the distance
	exploder( 200 );
	level thread play_base_explosion( 0 );
	
	flag_set("base_shaken");
	
	wait(2.75);
	
	exploder(202);	//right building
	level thread play_base_explosion( 1 );
	
	earthquake(0.2, 3.0, get_players()[0].origin,  500);
	
	wait(1.75);
	
	exploder(201);	//left building
	level thread play_base_explosion( 2 );
	
	earthquake(0.2, 3.0, get_players()[0].origin,  500);
	
	wait(2.5);
	
	level notify("electric_towers_start");
	
	wait(0.5);
	
	flag_set( "base_explosions_done" );
}


play_base_explosion( num )
{
    playsoundatposition( "evt_base_explo_" + num, (0,0,0) );
    
    player = get_players()[0];
    
    wait(2);
    
    for(i=0;i<3;i++)
    {
        random_org = ( RandomIntRange( -100, 100 ), RandomIntRange( -100, 100 ), 0 );
        
        playsoundatposition( "evt_impact_metal", player.origin + random_org );
        wait(RandomFloatRange(0,2));
    }
}


/*
// -- notifies the fx heat pipes to go flying
*/
truck_heat_pipes()
{
	trigger_node = GetVehicleNode( "avalanche_heat_pipe", "targetname" );
	
	trigger_node waittill( "trigger" );
	
	level notify( "heat_pipe01_start" );
}


/*
// -- notifies the wall to break out, should also have a radius damage and physics sphere to kill the ai
// -- should kill the spawn managers with this notify
*/
truck_wall_react()
{
	trigger_node = GetVehicleNode( "avalanche_wall_explode", "targetname" );
	
	trigger_node waittill( "trigger" );
	level.avalanche_wall_clean NotSolid();
	
	wait(0.6);
	
	level.avalanche_wall_clean Hide();
	level.avalanche_wall_fxanim Show();
	level notify( "ava_wall_start" );
}


/*
// -- enemy truck gets caught up in the avalanche
// start origin: 9015.77 -8239.84 10066
// updated origin: 11,956 -8045 9951
// start angles: 0 57.2 0
*/
#using_animtree( "wmd" );
truck_surf_down_road()
{
	truck = getent("truck_surfer_truck2", "targetname");
	truck Attach("t5_veh_gaz66_troops", "tag_origin_animate_jnt");
	//add_spawn_function_veh("truck_surfer_truck", ::setup_surfer_truck);
	
	avalanche_moving_node = GetVehicleNode( "vnode_start_avalanche_surfer", "targetname" );
	anim_struct = getstruct( "struct_truck_surfing", "targetname" );
	
	avalanche_moving_node waittill( "trigger" );

	// spawn out the vehicle
	//trigger_use("trigger_spawn_surfer_truck");
	
	truck thread setup_surfer_truck();
}


setup_surfer_truck()	//self = truck
{
	//self setcandamage(false);
	
	self.animname = "surfing_truck";
	self UseAnimTree(#animtree);
	
	wait( 2.2 );
		
	//self SetSpeedImmediate(30, 4, 2);
	
	surfnode = getvehiclenode("surf_node", "targetname");
	
	//surfnode waittill("trigger");
	
	//self SetSpeedImmediate(20, 4, 2);
	
	//self anim_single_aligned( self, "avalanche_surf", "tag_origin_animate_jnt", "surfing_truck" );
	self anim_single_aligned(self, "avalanche_surf", "tag_origin");
}


/*
// -- avalanche control for the truck turret event
*/
truck_avalanche_control()
{
	// endon
	
	//kevin grabbing player to play sound
	player = get_players()[0];
	
	// objects
	avalanche_vehicle = GetEnt( "vehicle_avalanche_fx", "targetname" );
	avalanche_path_start = GetVehicleNode( "vnod_avalanche_start", "targetname" );
	avalanche_path_accelerate_0 = GetVehicleNode( "vnode_avalanche_speed_up_0", "targetname" );
	avalanche_path_accelerate_1 = GetVehicleNode( "vnode_avalanche_speed_up_1", "targetname" );
	avalanche_play_building_exploders = GetVehicleNode( "vnod_truck_building_exploder", "targetname" );
	avalanche_path_truck_overtaken = GetVehicleNode( "vnod_avalanche_at_truck", "targetname" );
	
	brush_avalanche_vehicle = GetEnt( "vehicle_avalanche_filler", "targetname" );
	brush_avalanche_path_start = GetVehicleNode( "vnode_avalanche_filler_brush", "targetname" );
	
	avalanche_vehicle.ignoreme = 1;
	avalanche_vehicle SetTeamForEntity( "axis" );
	level.avalanche_brush NotSolid();
	
	level.avalanche_brush LinkTo( brush_avalanche_vehicle );
	
	// make sure vehicle nodes trigger off properly
	level thread truck_avalanche_vertical_impacts();
	
	// first explosion happens, this causes the avalanche tell to begin
	flag_wait( "base_shaken" );
	
	player thread avalanche_shake_controller();
	
	player playsound( "evt_avalanche_explo" );
	
	wait(4.5);
	
	flag_set("avalanche_go");
	
	exploder( 300 );	//avalanche fx
	
	// flag_wait( "base_quiet_before_storm_done" );
	player playloopsound( "evt_avalanch2_loop" , 5 );
	
	wait(6.0);
	
	// start the fx on the vehicle
	avalanche = PlayFXOnTag( level._effect[ "avalanche_wave" ], avalanche_vehicle, "tag_origin" );
		
	// start the avalanche
	flag_set( "start_avalanche" );
	
	level thread vision_set_avalanche();
		
	// start the avalanche on the path
	avalanche_vehicle thread go_path( avalanche_path_start );
	brush_avalanche_vehicle thread go_path( brush_avalanche_path_start );
	level.avalanche_brush Show();
	
	avalanche_path_accelerate_1 waittill("trigger");
	player thread play_avalanche_close_loop();
	
	avalanche_vehicle waittill( "reached_end_node" );
	
	flag_wait( "finish_avalanche" );
	
	player stoploopsound( .1 );
}


vision_set_avalanche()
{
	wait(10.0);
	
	VisionSetNaked("wmd_avalanche");
}


play_avalanche_close_loop()
{
    self endon( "death" );
    
    ent = Spawn( "script_origin", (0,0,0) );
    ent PlayLoopSound( "evt_avalanch2_loop_close", 3 );
    
    while(1)
    {
        origin_add = (RandomIntRange(-100,100),RandomIntRange(-100,100),0);
        
        playsoundatposition( "evt_avalanch_rock_hit", self.origin + origin_add );
        wait(RandomFloatRange(1,4));
    }
}


avalanche_shake_controller()  //self = player
{
	wait(0.3);
	
	earthquake(0.2, 3.0, self.origin,  500);
	
	flag_wait("avalanche_go");
	
	self thread increase_shake_01();
	
	earthquake(0.1, 20.0, self.origin,  500);
}


increase_shake_01()	//self = player
{
	wait(8.0);
	
	self thread increase_shake_02();
	
	earthquake(0.15, 30.0, self.origin,  500);
}


increase_shake_02()	//self = player
{
	waittime = 0.8;

	while(1)
	{
		wait(waittime);
		
		if( waittime > .5 )
		{
			earthquake(randomfloatrange(.3,.5), .45, self.origin, 5000);
		}
		else
		{
			earthquake(randomfloatrange(.1,.5), .25, self.origin, 5000);
		}
		
		waittime -= .1;
		
		if( waittime < .2 )
		{
			waittime = .2;
		}	
	}
}


truck_avalanche_vertical_impacts()
{
	avalanche_play_building_exploders = GetVehicleNode( "vnod_truck_building_exploder", "targetname" );
	
	avalanche_play_building_exploders waittill( "trigger" );
	
	wait(0.5);
	
	exploder( 301 );
	exploder( 302 );
}


// -- sets the truck to move forward trying to run from the avalanche
truck_runs_from_avalanche()
{
	//truck_start = GetVehicleNode("vnod_truck_building_exploder", "targetname");
	truck_start = GetVehicleNode("node_truck_ready", "targetname");
	avalanche_spline_start = GetVehicleNode( "vnode_run_from_avalanche", "targetname" );
	avalanche_close_vnode = GetVehicleNode( "avalanche_wall_explode", "targetname" );
	
	flag_wait( "player_on_truck" );
	
	gate = getent("avalanche_smashgate", "targetname");
	gate delete();
	
	truck = GetEnt( "vehicle_escape_truck", "targetname" );
	
	// wait for flag to move forward
	truck_start waittill( "trigger" );
	
	//wait(1.5);
	
	flag_set("truck_ready");
	
	wait(0.5);
	
	truck AttachPath( avalanche_spline_start );
	
	// move forward
	// truck thread go_path( avalanche_spline_start );
	truck StartPath();
	
	flag_set("truck_go");
	
	guys = getaiarray("allies");
	for(i=0; i<guys.size; i++)
	{
		guys[i] hide();
	}
	
	//truck waittill( "reached_end_node" );
	
	//end_node = getvehiclenode("escape_end", "targetname");
	//end_node waittill("trigger");
	
	wait(4.5);
	
	flag_set( "finish_avalanche" );
}


/*
// -- temp truck dialogue
// Makes the character play the specified sound and animation.  The anim and the sound are optional - you 
// can just defined one if you don't have both.
// Generally, importance should be in the range of 0.6-0.8 for scripted dialogue.
// Importance is a float, from 0 to 1.  
// 0.0 - Idle expressions
// 0.1-0.5 - most generic dialogue
// 0.6-0.8 - most scripted dialogue 
// 0.9 - pain
// 1.0 - death
// Importance can also be one of these strings: "any", "pain" or "death", which specfies what sounds can 
// interrupt this one.
// SaySpecificDialogue(facialanim, soundAlias, importance, notifyString, waitOrNot, timeToWait)
// -- HUDSON IS PLAYER!
//	players = get_players();
//	players[0] animscripts\face::SaySpecificDialogue( undefined, "vox_wmd1_s01_200A_huds", 1.0, "sound_done" ); 
*/
truck_temp_escape_dialogue()
{
	//flag_wait( "player_on_truck" );
	flag_wait("mounting_truck");

	player = get_players()[0];
	
	level.weaver.animname = "weaver";
	player.animname = "hudson";
	
	player anim_single(player, "weaver_drive");		//Weaver - Drive!... I'll get on the MG!
	
	wait(0.5);
	
	player = get_players()[0];
	player anim_single(player, "out_of_here");		//Get us out of here!!!
	
	wait(0.5);
	
	level.weaver anim_single(level.weaver, "hotwire_it");		//I have to hotwire it!
	level.weaver thread play_weaver_hotwire_audio();
	
	wait( 2.0 );

	player = get_players()[0];
	player anim_single(player, "all_over_us");		//Make it fast - they're all over us!
	
	wait(0.5);
	
	level.weaver anim_single(level.weaver, "need_a_minute");		//I need a minute!
	
	wait(0.5);
	
	player = get_players()[0];
	player anim_single(player, "have_a_minute");		//We don't have a minute!!
	
	flag_set("ready_explosion");

	wait( 2.0 );
	
	// first explosion plays, then start the avalanche starter as a hint
	flag_set( "base_explosions" );
	
	level.weaver anim_single(level.weaver, "stupid_piece_of");		//Come on - Stupid piece of shit truck!
	
	flag_wait("start_avalanche");
	
	//wait(1.0);
	
	player = get_players()[0];
	player anim_single(player, "we_waiting_for");		//What are we waiting for, Weaver?!!!
	
	wait(0.5);
	
	player = get_players()[0];
	player anim_single(player, "mountain_coming_down");		//The whole fucking mountain's coming down!!!
	
	wait(0.2);
	
	level.weaver anim_single(level.weaver, "nearly_there");		//Nearly there...
	
	flag_wait("truck_ready");
	
	level.weaver anim_single(level.weaver, "got_it");		//GOT IT!!
	
	wait(0.1);
	
	player = get_players()[0];
	player anim_single(player, "hit_it_go_go");		//Hit it! Go! GO!
	
	//flag_wait("truck_go");
	
	//player = get_players()[0];
	//player anim_single(player, "go_go");		//Go!! GO!!!!
	
	//player = get_players()[0];
	//player anim_single(player, "faster");		//FASTER!!!
	
	//wait(0.1);
	
	//player anim_single(player, "hudson_led");		//Jason Hudson led the attack on Yamantau.
	
	//wait(0.2);
	
	//player anim_single(player, "ice_cube");		//Yeah. 20 degrees below zero. Fucking ice cube was in his element.
	
	//wait(0.2);
	
	player anim_single(player, "buried");		//The avalanche buried the entire base, but Hudson and Weaver made it out alive. It was almost all over Mason.
}


play_weaver_hotwire_audio()
{
    self PlaySound( "evt_hotwire_plastic_tear" );
    
    while( !flag( "truck_ready" ) )
    {
        wait(RandomFloatRange(1,3));
        self PlaySound( "evt_hotwire_struggle", "sounddone" );
        self waittill( "sounddone" );
    }
    
    self PlaySound( "evt_hotwire_success" );
    wait(1.35);
    self PlaySound( "evt_hotwire_truck_speed_off" );
}


truck_spawn_functions()
{
	add_spawn_function_veh("vehicle_field_loading_truck", ::monitor_truck_health);
	add_spawn_function_veh("vehic_second_gaz66_backup", ::setup_mgdeath_truck);
	add_spawn_function_veh("vehicle_field_truck_backup", ::monitor_truck_health);
	
	add_spawn_function_veh("vehicle_interior_barrel", ::monitor_truck_health);
	add_spawn_function_veh("vehicle_interior_barrel", ::stop_engine_sound);
	
	add_spawn_function_veh("warehouse_veh_unload_truck1", ::monitor_truck_health);
	add_spawn_function_veh("warehouse_veh_unload_truck2", ::monitor_truck_health);
	add_spawn_function_veh("warehouse_veh_unload_truck3", ::monitor_truck_health);
	add_spawn_function_veh("warehouse_veh_unload_truck1", ::unload_truck);
	add_spawn_function_veh("warehouse_veh_unload_truck2", ::unload_truck);
	add_spawn_function_veh("warehouse_veh_unload_truck3", ::unload_truck);
	
	add_spawn_function_veh("truck_reinforce1", ::setup_truck_reinforce);
	add_spawn_function_veh("truck_reinforce2", ::setup_truck_reinforce);
	add_spawn_function_veh("truck_reinforce1", ::monitor_truck_health);
	add_spawn_function_veh("truck_reinforce2", ::monitor_truck_health);
	
	add_spawn_function_veh("truck_surfer_truck", ::monitor_truck_health);
}


setup_mgdeath_truck()
{
	self setcandamage(false);
	
	flag_wait("street_mggunner");
	
	self setcandamage(true);
}


monitor_truck_health()
{
	self thread check_explosive_tip();
	
	self.health = 20000;
	
	while( self.health > 18000)
	{
		wait(0.05);
	}
	
	level.fire = spawn("script_model", (self gettagorigin("tag_fx_cab")));
	level.fire SetModel("tag_origin");
	level.fire linkto(self);
		
	PlayFXOnTag(level._effect["gaz_firesml"], level.fire, "tag_origin");
	
	self thread countdown_to_boom();
	
	while( self.health > 16500)
	{
		wait(0.05);
	}
	
	self truck_go_boom();
}


countdown_to_boom()
{
	self endon("truck_dead");
	
	while(1)
	{
		wait(1.0);
		
		self.health -= 200;
	}
}


truck_go_boom()
{
	self PlaySound( "evt_truck_explo" );
	
	self ClearVehGoalPos();
	
	force = (0, 0, 150);
	hitpos = (0, 0, -50);
	
	self LaunchVehicle(force, hitpos, true, true);
	
	RadiusDamage(self.origin, 100, self.health, self.health);
	
	if (isdefined(level.fire))
	{
		level.fire delete();
	}
	
	guys = getaiarray( "axis" );
			
	for( i=0; i<guys.size; i++ )
	{
		if (Distance2DSquared(self.origin, guys[i].origin) < (256*256))
		{
			vec = VectorNormalize( guys[i].origin - self.origin );
			guys[i] startragdoll();
			guys[i] dodamage( guys[i].health, guys[i].origin );
			guys[i] LaunchRagdoll( ( vec*100 ) + ( 0, 0, 100 ) );
		}
	}
	
	physicsExplosionSphere(self.origin, 300, 300, 7.0);
	
	earthquake(0.3, 1.0, self.origin, 1500);
	
	self setspeedimmediate(0, 15, 5);
	
	self ClearVehGoalPos();
	
	self notify("truck_dead");
	
	wait(2.0);
	
	self disconnectpaths();
}


check_explosive_tip()
{
	self endon("truck_dead");
	
	while(1)
	{
		self waittill("damage", amount, inflictor, direction, point, type, modelName, tagName);
	
		if (IsPlayer(inflictor))
		{	
			inflictor_weapon = inflictor GetCurrentWeapon();
			
			if (inflictor_weapon == "crossbow_explosive_alt_sp")
			{
				self truck_go_boom();
				break;
			}
		}
	}
}


stop_engine_sound()
{
	self StopEngineSound();
}


unload_truck()
{
	wait(2.0);
	
	self vehicle_unload(0.5);
}