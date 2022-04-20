/*===========================================================================
RIVER EVENT 2
 beat 1: boat_landing
 beat 2: helicopter_flyby
 beat 3: fight_uphill
 beat 4: investigate_plane
 beat 5: plane_nose_section
 beat 6: run_to_boat
===========================================================================*/

#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;
#include maps\_rusher;
#include maps\_music;


/*===========================================================================
Logic: use beats via function pointers and strings that are the same name. 
	GetArrayKeys returns keys in reverse order, so a function was written to
	return them in sequential order. After that, loop through them sequentially
	and autosave after each function is completed.
===========================================================================*/
main( beat_name )
{
	setup_event_wide_functions();
	
	beats = [];
	beats[ "boat_landing" ]			= ::boat_landing;
	beats[ "NVA_ambush" ]			= ::NVA_ambush;
	beats[ "fight_uphill" ] 		= ::fight_uphill;
	beats[ "HIND_attack" ] 			= ::HIND_attack;	
	beats[ "investigate_plane" ] 	= ::investigate_plane;
//	beats[ "plane_nose_section" ] 	= ::plane_nose_section;	// MOVED TO RIVER_PLANE.GSC
//	beats[ "run_to_boat" ] 			= ::run_to_boat;		// MOVED TO RIVER_PLANE.GSC

	keys = maps\river_util::get_array_keys_in_order( beats );

	beat_num = 0; 

	if( IsDefined( beat_name ) )
	{
		for( i = 0; i < beats.size; i++ )
		{
			if( keys[ i ] == beat_name )
			{
				beat_num = i;
			}
		}
	}

	for( i = beat_num; i < beats.size; i++ )
	{
		current_beat = [[ beats[ keys[ i ] ] ]]();
		
		if( i == 0 )
		{
			level thread boat_landing_save_check();
		}
		else
		{
			autosave_by_name( "river_autosave" );
		}
	}
}

// make sure player isn't touching the boat when we save
boat_landing_save_check()
{
	trigger = GetEnt( "boat_landing_boat_area_trigger", "targetname" );
	
	if( !IsDefined( trigger ) )
	{
		PrintLn( "can't save - boat landing trigger is missing" );
		return;
	}
	
	player = get_players()[0];
	
	while( player IsTouching( trigger ) )
	{
		wait( 0.05 );
	}
	
	PrintLn( "SAVING NOW" );
	autosave_by_name( "river_autosave" );
}

setup_event_wide_functions()
{
	platoon_leader = GetEnt( "platoon_leader", "targetname" );  // all_yours vignette guy 
	support_huey_guys = GetEntArray( "support_huey_3_passenger", "targetname" );
	
	//support_huey_guys[ support_huey_guys.size ] = platoon_leader;
	
	for( i = 0; i < support_huey_guys.size; i++ )
	{
		support_huey_guys[ i ] add_spawn_function( maps\river_util::friendly_fire_instant_fail, "jungle_ambush_begins" );
	}	
	
	level thread setup_spawners();
	
//	C5_spawner_trigger = GetEnt( "player_in_C5_nose", "targetname" );
//	AssertEx( IsDefined( C5_spawner_trigger ), "C5_spawner_trigger is missing" );
//	C5_spawner_trigger trigger_off();	
	
	// threat bias setup
	CreateThreatBiasGroup("player");
	CreateThreatBiasGroup( "snipers" );
	CreateThreatBiasGroup("friendly_squad");
	CreateThreatBiasGroup("axis");
	CreateThreatBiasGroup("recapture_pbr_enemies");
	level.max_threat_bias = 2147483648;  // absolute max for threat bias
		
	for(i=0; i<level.friendly_squad.size; i++)
	{
		level.friendly_squad[i] SetThreatBiasGroup("friendly_squad");
	}	
	
	wait( 0.1 );
	
	// set up support helicopters
	add_spawn_function_veh( "jungle_support_huey_1", ::vehicle_path_loop, "survey_huey_1_start", "survey_huey_1_loop_start" );
	add_spawn_function_veh( "jungle_support_huey_2", ::vehicle_path_loop, "survey_huey_2_start", "survey_huey_2_loop_start" );
	add_spawn_function_veh( "jungle_support_huey_3", ::huey_peel_and_dropoff, "survey_huey_3_loop_5", "huey_dropoff_peeloff_rail_start", "dropoff_peel", "dropoff_troops" );	
	
	wait( 0.1 );
	
	add_spawn_function_veh( "jungle_support_huey_1", maps\river_util::huey_cone_light );
	add_spawn_function_veh( "jungle_support_huey_2", maps\river_util::huey_cone_light );
	add_spawn_function_veh( "jungle_support_huey_3", maps\river_util::huey_cone_light );	

	wait( 0.1 );

	add_spawn_function_veh( "jungle_support_huey_1", maps\river_util::ent_name_visible );
	add_spawn_function_veh( "jungle_support_huey_2", maps\river_util::ent_name_visible );
	add_spawn_function_veh( "jungle_support_huey_3", maps\river_util::ent_name_visible );
	
	wait( 0.1 );
	
	add_spawn_function_veh( "jungle_support_huey_1", ::heli_hover );
	add_spawn_function_veh( "jungle_support_huey_2", ::heli_hover );
	add_spawn_function_veh( "jungle_support_huey_3", ::heli_hover );	
}


setup_spawners()
{
	spawn_manager_set_global_active_count(12);
	
	hillside_guys = GetEntArray("hillside_guys", "script_noteworthy");
	AssertEx((hillside_guys.size > 0), "hillside_guys missing");
	for(i=0; i<hillside_guys.size; i++)
	{
		hillside_guys[i] add_spawn_function(::hillside_guys_behavior);
	}		
	
	wait( 0.2 );
	
//	spetsnaz_group_1 = GetEntArray("heli_rappel_dropoff_1_troops", "targetname");
//	AssertEx((spetsnaz_group_1.size > 0), "spetsnaz_group_1 guys missing");
//	for(i=0; i<spetsnaz_group_1.size; i++)
//	{
//		spetsnaz_group_1[i] add_spawn_function(maps\river_util::initialize_ent_flags,"rappel_done");
//		spetsnaz_group_1[i] add_spawn_function(maps\river_util::go_to_nodes, "spetsnaz_plane_cover_nodes", "rappel_done");
//	}
//	
//	spetsnaz_group_2 = GetEntArray("heli_rappel_dropoff_2_troops", "targetname");
//	AssertEx((spetsnaz_group_2.size > 0), "spetsnaz_group_2 guys missing");
//	for(i=0; i<spetsnaz_group_2.size; i++)
//	{
//		spetsnaz_group_2[i] add_spawn_function(maps\river_util::initialize_ent_flags,"rappel_done");		
//		spetsnaz_group_2[i] add_spawn_function(maps\river_util::go_to_nodes, "spetsnaz_cover_nodes", "rappel_done");
//	}	
	
//	sniper_support_enemies = GetEntArray( "recapture_pbr_enemies", "script_noteworthy" );
//	AssertEx( ( sniper_support_enemies.size > 0 ), "sniper_support_enemies missing" );
//	for( i=0; i < sniper_support_enemies.size; i++ )
//	{
//		sniper_support_enemies[i] add_spawn_function( ::recapture_pbr_enemy_function );
//	}
	
//	C5_nose_crash_guys = GetEntArray( "C5_nose_crash_guys", "script_noteworthy" );
//	AssertEx( ( C5_nose_crash_guys.size > 0 ), "C5_nose_crash_guys are missing" );
//	for( i = 0; i < C5_nose_crash_guys.size; i++ )
//	{
//		C5_nose_crash_guys[i] add_spawn_function( ::recapture_pbr_enemy_function ) ;
//	}
	
	// recapture_pbr_sampan_east, recapture_pbr_sampan_east_2
	add_spawn_function_veh( "recapture_pbr_sampan_east", maps\river_util::vehicle_setup );
	add_spawn_function_veh( "recapture_pbr_sampan_east_2", maps\river_util::vehicle_setup );
	add_spawn_function_veh( "west_shore_sampan_1", maps\river_util::vehicle_setup );

	wait( 0.2 );	
	
	add_spawn_function_veh( "west_shore_sampan_2", maps\river_util::vehicle_setup );
	add_spawn_function_veh( "boat_landing_patrol_boat", maps\river_util::vehicle_setup );
	add_spawn_function_veh( "recapture_pbr_patrol_boat", maps\river_util::vehicle_setup );	

	wait( 0.1 );	
	
	add_spawn_function_veh( "recapture_pbr_sampan_west", maps\river_util::vehicle_setup );	
	add_spawn_function_veh( "recapture_pbr_sampan_west_2", maps\river_util::vehicle_setup );	
	
	wait( 0.2 );
	
//	sampan_landers = GetEntArray( "sampan_landing_guys", "script_noteworthy" );
//	AssertEx( ( sampan_landers.size > 0 ), "sampan_landers are missing" );
//	for( i = 0; i < sampan_landers.size; i++ )
//	{
//		sampan_landers[i] add_spawn_function( maps\river_util::sampan_landing_function );
//		sampan_landers[i] add_spawn_function( maps\river_util::sampan_landing_death_counter );
//		sampan_landers[i] add_spawn_function( maps\river_util::patrol_boat_gunner_locality_check );
//	}
//
//	alcove_spawners = GetEntArray( "alcove_spawners", "script_noteworthy" );
//	AssertEx( ( alcove_spawners.size > 0 ), "alcove_spawners missing" );
//	for( i = 0; i < alcove_spawners.size; i++ )
//	{
//		alcove_spawners[i] add_spawn_function( maps\river_util::sampan_landing_function, "boatjack_started" );
//		alcove_spawners[i] add_spawn_function( maps\river_util::sampan_landing_death_counter );		
//		alcove_spawners[i] add_spawn_function( ::fire_at_friendly_pbr );
//	}
//	
//	patrol_boat_gunners = GetEntArray( "patrol_boat_spawners", "targetname" );
//	AssertEx( ( patrol_boat_gunners.size > 0 ), "patrol_boat_gunners are missing" );
//	for( i = 0; i < patrol_boat_gunners.size; i++ )
//	{
//		patrol_boat_gunners[i] add_spawn_function( maps\river_util::patrol_boat_gunner_locality_check );
//	}
	
	helicopter_massacre_guys = GetEntArray( "hillside_helicopter_kill_guys", "targetname" );
	AssertEx( ( helicopter_massacre_guys.size > 0 ), "helicopter_massacre_guys are missing in river_jungle" );
	for( i = 0; i < helicopter_massacre_guys.size; i++ )
	{
		helicopter_massacre_guys[ i ] add_spawn_function( ::go_to_unoccupied_node, "hillside_helicopter_kill_cover_nodes" );
		//helicopter_massacre_guys[ i ] add_spawn_function( ::force_target, "jungle_support_huey_3" );
		helicopter_massacre_guys[ i ] add_spawn_function( ::force_vehicle_turret_target, "jungle_support_huey_3" );
		helicopter_massacre_guys[ i ] add_spawn_function( ::death_counter_huey );
		wait( 0.05 );
	}
	
	rappel_group_1 = GetEntArray( "heli_rappel_dropoff_2_troops", "script_noteworthy" );
	AssertEx( ( rappel_group_1.size > 0 ), "rappel_group_1 is missing" );
	for( i = 0; i < rappel_group_1.size; i++ )
	{
		rappel_group_1[ i ] add_spawn_function( ::go_to_unoccupied_node, "spetsnaz_dropdown_cover" );
	}
	
	wait( 0.1 );
	
	rappel_group_2 = GetEntArray( "heli_rappel_dropoff_1_troops_group", "script_noteworthy" );
	AssertEx( ( rappel_group_2.size > 0 ), "rappel_group_2 is missing" );
	
	tree_snipers = GetEntArray( "actor_VC_e_tree_sniper_Dragunov", "classname" );
	for( i = 0; i < tree_snipers.size; i++ )
	{
		tree_snipers[ i ] add_spawn_function( ::tree_sniper_func );
	}
	
	wait( 0.2 );
	
	vc_ambushers = GetEntArray( "first_hill_wave_guys", "targetname" );
	for( i = 0; i < vc_ambushers.size; i++ )
	{
		vc_ambushers[i] add_spawn_function( ::ambush_second_wave_spawner );
	}
	
}

tree_sniper_func( bias )  // self = tree sniper. bias = percent chance to target player. defaults to 80.
{
	self.dropweapon = false;

	if( !IsDefined( bias ) )
	{
		bias = 80;
	}
	
	if( IsDefined( self.targetname ) )
	{
		switch( self.targetname )
		{
			case "tree_sniper_waterfall_left_ai":
				bias = 50;
				break;
			
			case "tree_sniper_hinds_right_ai":
				bias = 80;
				break;
			
			case "tree_sniper_ruins_ai":
				bias = 90;
				break;
		}
	}
	
	self AllowedStances( "crouch" );
	
	self disable_react();
	self disable_pain();
	
	self.grenadeammo = 0;  // don't want our snipers throwing grenades.
	self.dofiringdeath = false;
	self.a.disablelongdeath = true;
	self set_ignoreme( true );
	self set_ignoreall( true );
	self.takedamage = false;
	self dds_exclude_this_ai();  // don't let snipers talk for DDS
	
	self waittill( "tree_sniper_reveal" );
	
	self enable_react();
	self enable_pain();
	
	self set_ignoreme( false );
	self set_ignoreall( false );
	self.takedamage = true;
	
	while( IsAlive( self ) )
	{
		x = RandomIntRange( 0, 100 );
		
		if( x <= bias )  // shoot player 
		{
		//	IPrintLnBold( "shooting player. x = " + x );
			self Shoot_at_target( get_players()[ 0 ] );
		}
		else
		{
		//	IPrintLnBold( "shooting squad. x = " + x );
			self Shoot_at_target( random( level.friendly_squad ) );
		}
		
		wait( 0.05 );
	}
	
}

/*==========================================================================
FUNCTION: death_counter
SELF: AI 
PURPOSE: implement a counter for number of deaths, then wait for a guy to die
	so you can count him

ADDITIONS NEEDED:
==========================================================================*/
death_counter_huey()
{
	if( !IsDefined( level.support_huey_kills ) )  // check for existance of counter_var
	{
		level.support_huey_kills = 0;
	}
	
	self waittill( "death" );
	
	level.support_huey_kills++;
}

/*==========================================================================
FUNCTION: force_vehicle_turret_target
SELF: AI
PURPOSE: when guy spawns in, put him in the forced target array on a vehicle

ADDITIONS NEEDED:
==========================================================================*/
force_vehicle_turret_target( vehicle_targetname )  // self = AI
{
	if( !IsDefined( vehicle_targetname ) )
	{
		PrintLn( "vehicle_targetname is missing for force_vehicle_turret_target on " + self.targetname );
		return;
	}
	
	vehicle = GetEnt( vehicle_targetname, "targetname" );
	
	if( !IsDefined( vehicle ) )
	{
		PrintLn( "forced_vehicle_turret_target found no vehicle found with targetname " + vehicle_targetname );
		return;
	}
	
	vehicle maps\_vehicle_turret_ai::set_forced_target( self );
	
	self waittill( "death", killer );
	
//	IPrintLnBold( "killer = " + killer.targetname );
}

/*==========================================================================
FUNCTION: go_to_unoccupied_node
SELF: AI
PURPOSE: spawn in a guy, then make him go to a unique node that other guys
	aren't already using. The number of possible guys versus nodes is notify
	checked here.

ADDITIONS NEEDED:
==========================================================================*/
go_to_unoccupied_node( node_array_targetname )  // self = AI
{
	self endon( "death" );
	
	if( !IsDefined( node_array_targetname ) )
	{
		PrintLn( "node_array_targetname is missing for " + self.targetname );
		return;
	}
	
	nodes = GetNodeArray( node_array_targetname, "targetname" );
	
	if( nodes.size == 0 )
	{
		PrintLn( "no nodes found with targetname " + node_array_targetname + "!" );
		return;
	}
	
	goal = random( nodes );
	
	while( IsNodeOccupied( goal ) == true )
	{
		goal = random( nodes );
		wait( 1 );
	}
	
	self SetGoalNode( goal );
}

/*==========================================================================
FUNCTION: force_target
SELF: AI
PURPOSE: make AI prioritize an ent over everything else from spawn in

ADDITIONS NEEDED:
==========================================================================*/
force_target( target_targetname ) // self = AI
{
	self endon( "death" );
	
	if( !IsDefined( target_targetname ) )
	{
		PrintLn( "force_target is missing a target_targetname for " + self.targetname );
		return;
	}
	
	target = GetEnt( target_targetname, "targetname" );
	if( !IsDefined( target ) )
	{
		PrintLn( "target is missing for " + self.targetname );
		return;
	}
	
	self SetEntityTarget( target, 1 );
}

recapture_pbr_enemy_function()
{
	self SetThreatBiasGroup("recapture_pbr_enemies");
	self.goalradius = 64;
	
	cover_nodes = GetNodeArray( "sniper_support_enemy_cover_nodes", "targetname" );
	AssertEx( (cover_nodes.size > 0 ), "cover_nodes for recapture_pbr_enemy_function are missing");
	
	goal = random( cover_nodes );
	
	count = 0;			

	while( IsNodeOccupied( goal ) == true )
	{
		if( count > 3 )
		{
			break;
		}
		
		goal = random( cover_nodes );
		count++;
	}
	
	self SetGoalNode(goal);
	
	self waittill("death");
	
	PrintLn("recapture_pbr_enemy killed");
	
	if( !IsDefined( level.recapture_pbr_enemies_killed ) )
	{
		level.recapture_pbr_enemies_killed = 0;
	}
	
	level.recapture_pbr_enemies_killed++;
}

// boat lands, player takes out first group of NVA
boat_landing()  // beat 1
{	
	slow_engine_trigger = GetEnt("slow_engine_trigger", "targetname");
	AssertEx(IsDefined(slow_engine_trigger), "slow_engine_trigger is missing in boat_landing beat");
	slow_engine_trigger waittill("trigger");

	level thread huey_support_begins();
	
	level thread all_yours_vignette();	
		
	//maps\_vehicle::scripted_spawn( 18 );  // put in NVA patrol boat - not currently used as of 6/15/2010. -TJanssen	
	
	//TUEY change the music to teh uphill fight
	setmusicstate ("UPHILL_FIGHT");

	// SCRIPTED VO - Found Plane
	wait( 0.15 );
	choper = GetEnt( "jungle_support_huey_2", "targetname" );
	choper.animname = "us_pilot_1";

	choper thread maps\river_vo::playVO_proper( "theyve_found_it", 4 );					// 1
	
	// no time to say it
	//choper thread maps\river_vo::playVO_proper( "thats_your_plane_wolf_10", 6 );		// 3
	
	choper thread maps\river_vo::playVO_proper( "repeat_visual_confirmation", 6 );
	
	

	cut_engine_trigger = GetEnt("park_boat_here_trigger", "targetname");
	AssertEx(IsDefined(cut_engine_trigger), "cut_engine_trigger is missing in boat_landing beat");
	cut_engine_trigger waittill("trigger");

	level.boat veh_toggle_tread_fx( 0 );

	level.boat ResumeSpeed( 30 );

	rail_start = GetVehicleNode("boat_landing_rail_18", "targetname");
	AssertEx(IsDefined(rail_start), "rail_start missing for boat_landing");
	level.boat.drivepath = 1;
	level.boat SetDrivePathPhysicsScale( 3.0 );
	level.boat thread go_path(rail_start);
	
	flag_set("river_pacing_done");		
	
//	level.boat waittill( "reached_node" );

	// As the player boat docks
	level.woods thread maps\river_vo::playVO_proper( "mason_head_for_the_shore", 5.75 );// 4
	
// No time to say anymore
	//level.woods thread maps\river_vo::playVO_proper( "this_is_it_remember", 8.25 );		// 7.5

	// Fade in the land vision set
	level thread start_land_visionset();
	
	level thread alcove_redshirts_meet_squad();
	
//	wait(1.5);

	//level.boat StartPath();	
	
	level.boat waittill( "switch_to_startpath" );
	
	//level.boat delaythread( 4.5, maps\river_anim::play_reznov_anim, "finally_mason", "tag_passenger12" );  // 
	level.reznov thread maps\river_vo::playVO_proper( "finally_mason_our_key", 4.5 );
	
	delaythread( 9.5, ::friendly_squad_gets_off_boat);	
	
	level.boat waittill_either("near_goal", "reached_end_node");
	
//	level thread friendly_squad_gets_off_boat();
	
	level thread remove_player_from_boat();
	
	// SCRIPTED VO - The Boat has docked
	level.woods thread maps\river_vo::playVO_proper( "great_have_one_of_your_men", 5.5 );
	//level.us_pilot_2 thread maps\river_vo::playVO_proper( "ill_stay_low_and_cover_you", 7 );

	// attach a clip at the back of the boat to prevent player from leaving
	maps\river_util::attach_player_clip_to_pbr( "player_pbr_clip_exit" );

	//level thread maps\river_util::monitor_spawners("river_jungle_volumes");	
	
	flag_set("boat_docked");
	level.boat notify( "player_not_using_boat" );
	
	// put woods back into a normal AI state
	level.woods AllowedStances( "stand", "crouch", "prone" );
	level.woods gun_switchto( "commando_acog_sp", "right" );
	level.woods notify( "stop_rpg_turret_ai" );
	
	// put bowman back into normal AI state
	level.bowman AllowedStances( "stand", "crouch", "prone" );
	level.bowman gun_switchto( "commando_acog_sp", "right" );
	level.bowman notify( "stop_rpg_turret_ai" );	
	level.boat notify( "stop_player_aim_entity_update" );
	
	level.reznov AllowedStances( "stand", "crouch", "prone" );
	
	// make bowman and woods stop aiming at the boat
	level.bowman ClearEntityTarget();
	level.woods ClearEntityTarget();
	
	level.woods maps\river_util::remove_rpg_firing();
	level.bowman maps\river_util::remove_rpg_firing();	
	
	level.boat maps\_vehicle_turret_ai::disable_turret( 0 );
//	level.boat maps\river_util::disable_bow_turret_fire(level.bowman);
//	level.woods maps\river_util::remove_actor_from_drivers_seat(level.boat);
//	level thread friendly_squad_holds_fire();
//	level thread friendly_squad_clear_to_fire();
		
	flag_clear("display_boat_hp");  // stop displaying boat health
	
//	guys = GetEntArray("boat_landing_sampan_guys", "script_noteworthy");
//	simple_spawn(guys, ::cautious_enemy_function);
	
//	level thread add_dialogue_line("Woods", "What the hell? You hear that? We've got choppers incoming...");		
//	level thread boat_landing_sampan_engagement();


//	level.bowman thread boat_landing_pathing( "boat_landing_bowman" );
//	level.reznov thread boat_landing_pathing( "boat_landing_reznov" );

//	allies_nodes = GetNodeArray( "boat_landing_american_cover", "targetname" );
//	AssertEx( ( allies_nodes.size > 0 ), "allies_nodes missing in boat_landing" );
//
//	for( i = 0; i < level.friendly_squad.size; i++ )
//	{
//		if( level.friendly_squad[ i ].targetname == "woods_ai" )
//		{
//			continue;
//		}
//		
//		level.friendly_squad[ i ] SetGoalNode( allies_nodes[ i ] );
//	}  
	
//	woods_node = GetNode("woods_sampan_landing_stealth_position", "targetname");
//	AssertEx(IsDefined(woods_node), "woods_node for boat_landing is missing");
//	bowman_node = GetNode("bowman_cover_boat_landing", "targetname");
//	AssertEx(IsDefined(bowman_node), "bowman_node for boat_landing is missing");
//	
//	level.woods SetGoalNode(woods_node);
//	level.bowman SetGoalNode(bowman_node);

}

alcove_redshirts_meet_squad()
{
//	nodes = GetNodeArray( "boat_landing_redshirt_nodes", "targetname" );
//	if( nodes.size == 0 )
//	{
//		PrintLn( "alcove_redshirts_meet_squad couldn't find nodes!" );
//		return;
//	}

	nodes = [];
	nodes[ nodes.size ] = GetNode( "boat_landing_rally", "targetname" );
	nodes[ nodes.size ] = GetNode( "boat_landing_rally_2", "targetname" );
	
	guy_spawners = GetEntArray( "boat_landing_redshirts", "targetname" );
	if( guy_spawners.size == 0 )
	{
		PrintLn( "alcove_redshirts_meet_squad couldn't find spawners!" );
		return;
	}
	
	if( nodes.size < guy_spawners.size )
	{
		PrintLn( "not enough nodes for all guys in alcove_redshirts_meet_squad!" );
		return;
	}
	
	guys = simple_spawn( guy_spawners );
	
	for( i = 0; i < guys.size; i++ )
	{
		guys[ i ].goalradius = 32;
		guys[ i ] SetGoalNode( nodes[ i ] );
	}
}

boat_landing_pathing( first_node, second_node )  // self = AI 
{
	if( !IsDefined( first_node ) || !IsDefined( second_node ) )
	{
		PrintLn( "boat_landing_pathing is broken for " + self.targetname );
		return;
	}
	
	first_goal = GetNode( first_node, "targetname" );
	second_goal = GetNode( second_node, "targetname" );
	
	old_goalradius = self.goalradius;
	
	self.goalradius = 16;  // make goal radius small 
	
	self SetGoalNode( first_goal );
	
	self waittill( "goal" );
	
	self SetGoalNode( second_goal );
	
	self waittill( "goal" );
	
	self.goalradius = old_goalradius;  // restore goal radius
}

remove_player_from_boat()
{
	player = get_players()[0];
	level.boat MakeVehicleUsable();
	level.boat UseBy(player);  // take player out of drivers seat
	level.boat MakeVehicleUnusable();		
	maps\river_util::let_player_leave_boat();	
}

//*****************************************************************************
//*****************************************************************************
start_land_visionset()
{
	wait( 3 );
	//IPrintLnBold("STATING NOW");
	level thread maps\createart\river_art::land_section( 8 );
}


//*****************************************************************************
//*****************************************************************************

ambush_spawner_old()  // self = AI
{
	self endon( "death" );

	self AllowedStances( "prone" );
	self set_ignoreme( true );
	self set_ignoreall( true );
	
	self waittill( "ambush_started" );
	
	self AllowedStances( "stand", "crouch", "prone" );
	
	if( IsDefined( self.script_string ) && ( self.script_string == "rusher" ) )
	{
		CreateThreatBiasGroup( "rushers" );
		SetThreatBias( "player", "rushers", 2147483648 ); // max threat bias
		self set_ignoreall( false );		
		self thread rush();
		wait( 0.25 );
		self.health = 150;
	}		
	else
	{
		self set_ignoreme( false );
		self set_ignoreall( false );
	}

}

ambush_spawner()
{
	self endon( "death" );
	
	struct = getstruct( "ambush_anim_node", "targetname" );
	if( !IsDefined( struct ) )
	{
		//IPrintLnBold( "struct missing for ambush_spawner on " + self.targetname );
	}
	else
	{
		if( !IsDefined( level.ambush_first_wave_guys ) )
		{
			level.ambush_first_wave_guys = 0;			
		}
		
		level.ambush_first_wave_guys++;
		
		if( level.ambush_first_wave_guys > 8 )
		{
			// ambush is over, don't keep playing anims
			return;
		}
		
		self.animname = "vc_ambusher_first_wave_" + level.ambush_first_wave_guys;  // 1 through 8 work
		
		node = Spawn( "script_origin", struct.origin );
		node.angles = ( 0, 0, 0 );
				
		node thread anim_single_aligned( self, "vc_appear" );
		
		self thread temporary_invulnerability( 1 );
		
		wait( .5 );
		
		self thread fire_magic_bullets();
		
		if( level.ambush_first_wave_guys != 1 )
		{
			self thread rush();
			wait( 0.25 );
			self.health = 150;
		}
	}	
}

temporary_invulnerability( time )
{
	self.takedamage = false;
	
	wait( time );
	
	self.takedamage = true;
}

fire_magic_bullets( time ) 
{
	self endon( "death" );
	
	if( !IsDefined( time ) )
	{
		time = 2;
	}
	
	bullets_per_sec = 5;
	bullets = bullets_per_sec * time;
	offset = 100;
	wait_time = 1 / bullets_per_sec;
	tag = "tag_flash";
	
	for( i = 0; i < bullets; i++ )
	{
		start_pos = self GetTagOrigin( tag );
		angles = AnglesToForward( self GetTagAngles( tag ) );
		end_pos = start_pos + ( angles * offset );
		MagicBullet( self.weapon, start_pos, end_pos );
		wait( wait_time );
	}
}

ambush_second_wave_spawner()
{
	self endon( "death" );
	
	struct = getstruct( "ambush_anim_node", "targetname" );
	if( !IsDefined( struct ) )
	{
		//IPrintLnBold( "struct missing for ambush_spawner on " + self.targetname );
	}
	else
	{
		if( !IsDefined( level.ambush_second_wave_guys ) )
		{
			level.ambush_second_wave_guys = 0;			
		}
		
		level.ambush_second_wave_guys++;
		
		if( level.ambush_second_wave_guys > 8 )
		{
			// ambush is over, don't keep playing anims
			return;
		}
		
		self.animname = "vc_ambusher_" + level.ambush_second_wave_guys;  // 1 through 8 work
		
		node = Spawn( "script_origin", struct.origin );
		node.angles = ( 0, 0, 0 );
				
		node anim_single_aligned( self, "vc_appear" );
		
		node Delete();
	}	
}

/*==========================================================================
FUNCTION: huey_support_begins
SELF: level 
PURPOSE: set up helicopter behavior in one place

ADDITIONS NEEDED:
==========================================================================*/
huey_support_begins()
{	
	wait( 0.1 );

	//add_spawn_function_veh( "aftermath_landing_huey3", ::huey_passenger_setup, "support_huey_3_passenger", 8 );
	
	maps\_vehicle::scripted_spawn( 39 );
	
	wait( 1 );
	
	huey3 = GetEnt( "jungle_support_huey_3", "targetname" );
	AssertEx( IsDefined( huey3 ), "huey3 is missing" );
	
	// Used for VO dialogue lines
	level.us_pilot_2 = huey3;
	level.us_pilot_2.animname = "us_pilot_2";
	
	level thread huey_support_vo();
	
	huey3 populate_huey( 2, "support_huey_3_passenger" );  // two guys plus 'platoon leader'

//	platoon_leader enter_vehicle( huey3 );
//	huey3.passengers[ huey3.passengers.size ] = platoon_leader;  // doing this for proper unload

	wait( 10 );
	
	// clean up old helicopters
	hovering_huey = GetEnt( "pacing_hover_huey", "targetname" );
	if( IsDefined( hovering_huey ) )
	{
		hovering_huey Delete();
	}
	
	old_huey1 = GetEnt( "pacing_flyby_helicopter_1", "targetname" );
	if( IsDefined( old_huey1 ) )
	{
		old_huey1 Delete();
	}
	
	old_huey2 = GetEnt( "pacing_flyby_helicopter_2", "targetname" );
	if( IsDefined( old_huey2 ) )
	{
		old_huey2 Delete();
	}
	
	old_huey3 = GetEnt( "pacing_flyby_helicopter_3", "targetname" );
	if( IsDefined( old_huey3 ) )
	{
		old_huey3 Delete();
	}	
}


//*****************************************************************************
// VO: For the boat landing <-> huey landing event
//*****************************************************************************

huey_support_vo()
{
	// As the huey lands on land
	level.us_pilot_2 thread maps\river_vo::playVO_proper( "wolf_10_this_is_centurion_3", 12.0 );
	level.us_pilot_2 thread maps\river_vo::playVO_proper( "i_have_limited_ground_support", 15.5 );
}


/*==========================================================================
FUNCTION: populate_huey
SELF: huey vehicle that needs some guys in it
PURPOSE: put some animated models in a huey in drivers seats and on gunners, 
	then add some optional real AI if need be ( for dropoffs and such )

ADDITIONS NEEDED:
==========================================================================*/
#using_animtree( "generic_human" );
populate_huey( num_ai_passengers, passenger_targetnames, skip_driver, skip_driver2, skip_gunner, skip_gunner2 )
{
	if( IsDefined( skip_driver ) && ( skip_driver == true ) )
	{
		// don't add in driver!
	}
	else
	{
		driver = spawn("script_model", (0,0,0) );
	//	driver character\c_usa_specop_assault::main();
		driver maps\river_anim::redshirt_setup_basic();
		driver UseAnimTree(#animtree);
		driver maps\_vehicle_aianim::vehicle_enter( self, "tag_driver" );
	}

	if( IsDefined( skip_driver2 ) && ( skip_driver2 == true ) )
	{
		// don't add in driver2!
	}		
	else
	{
		driver2 = spawn("script_model", (0,0,0) );
	//	driver2 character\c_usa_specop_assault::main();
		driver2 maps\river_anim::redshirt_setup_basic();
		driver2 UseAnimTree(#animtree);
		driver2 maps\_vehicle_aianim::vehicle_enter( self, "tag_passenger" );
	}

	if( IsDefined( skip_gunner ) && ( skip_gunner == true ) )
	{
		// don't add in gunner!
	}	
	else
	{
		gunner = spawn("script_model", (0,0,0) );
	//	gunner character\c_usa_specop_assault::main();
		gunner maps\river_anim::redshirt_setup_basic();
		gunner UseAnimTree(#animtree);
		gunner maps\_vehicle_aianim::vehicle_enter( self, "tag_gunner1" );		
	}

	if( IsDefined( skip_gunner2 ) && ( skip_gunner2 == true ) )
	{
		// don't add in gunner2!
	}		
	else
	{
		gunner2 = spawn("script_model", (0,0,0) );
	//	gunner2 character\c_usa_specop_assault::main();
		gunner2 maps\river_anim::redshirt_setup_basic();
		gunner2 UseAnimTree(#animtree);
		gunner2 maps\_vehicle_aianim::vehicle_enter( self, "tag_gunner2" );
	}
	
	if( IsDefined( num_ai_passengers ) && IsDefined( passenger_targetnames ) )
	{	
		self.passengers = [];
		
		if( num_ai_passengers < 0 )
		{
			PrintLn( "populate_huey function can't use a negative number of passengers. no AI attached to " + self.targetname );
		}
		else if( num_ai_passengers > 4 ) 
		{
			PrintLn( "hueys support a maximum of 8 passengers. you have 4 animated models already; lowering num_ai_passengers to 4" );
			num_ai_passengers = 4;
		}
		
		for( i = 0; i < num_ai_passengers; i++ )
		{
			guy = simple_spawn_single( passenger_targetnames, ::dropoff_huey_guy_function );
			guy enter_vehicle( self );
			self.passengers[ self.passengers.size ] = guy;
		}
	}
}

dropoff_huey_guy_function()
{
	self endon( "death" );
	
	self.goalradius = 128;

	nodes = GetNodeArray( "boat_landing_american_cover_redshirts", "targetname" );
	AssertEx( ( nodes.size > 0 ), "nodes missing in dropoff_huey_guy_function" );
	
	self waittill( "jumpedout" );
	//IPrintLnBold( "jump done" );
	
	wait( RandomFloatRange( 0.25, 0.75 ) );
	
	goal = random( nodes );
	
	while( IsNodeOccupied( goal ) == true )
	{
		goal = random( nodes );
		wait( 0.5 );
	}
	
	self SetGoalNode( goal );	
}

vehicle_path_loop( vehiclenode_start_targetname, vehiclenode_loop_targetname )  // self = vehicle
{
	self endon( "stop_looping" );  // in case peel off is needed at some point, endon here
	self endon( "stop path" );
	
	start_node = GetVehicleNode( vehiclenode_start_targetname, "targetname" );
	if( !IsDefined( start_node ) )
	{
		//IPrintLnBold( "missing start node on " + self.targetname );
		return;
	}
	
	loop_node = GetVehicleNode( vehiclenode_loop_targetname, "targetname" );
	if( !IsDefined( loop_node ) )
	{
		//IPrintLnBold( "missing loop node on " + self.targetname );
		return;
	}	
	
	self.takedamage = false;
	
	self SetLocalWindSource( true );
	
	self.drivepath = 1; 
	self thread go_path( start_node );
	
//	while( IsAlive( self ) )
//	{	
//		self waittill( "reached_end_node" );
//		
//		self drivepath( loop_node );
//	}
}

huey_peel_and_dropoff( vehiclenode_start_targetname, vehiclenode_peeloff_rail_targetname, peeloff_notify, stopat_notify )
{
	self endon( "dropoff_done" );
	
	start_node = GetVehicleNode( self.target, "targetname" );
	if( !IsDefined( start_node ) )
	{
		//IPrintLnBold( "missing start node on " + self.targetname );
		return;
	}
	
	peeloff_node = GetVehicleNode( vehiclenode_peeloff_rail_targetname, "targetname" );
	if( !IsDefined( vehiclenode_peeloff_rail_targetname ) )
	{
		//IPrintLnBold( "missing peeloff_node on " + self.targetname );
		return;
	}		
	
	if( !IsDefined( peeloff_notify ) )
	{
		//IPrintLnBold( "peeloff_notify is missing on " + self.targetname );
		return;
	}
	
	if( !IsDefined( stopat_notify ) )
	{
		//IPrintLnBold( "stopat_notify is missing on " + self.targetname );
		return;
	}
	
	//self ResumeSpeed( 10 );
	
	self.takedamage = false;
	
//	self SetDrivePathPhysicsScale( 5.0 );
	self.drivepath = 1;
	self thread go_path( start_node );
	
//	self waittill( peeloff_notify );
//	//IPrintLnBold( self.targetname + " hit peeloff notify" );
//	//level thread add_dialogue_line( "HueyPilot", "Chopper3 coming in for infantry support. Going to reinforce your squad, Woods." );
//	
//	self thread go_path( peeloff_node );
	self waittill( "peeloff_rail_started" );
//	IPrintLnBold( "peeloff_rail_started hit" );
//	self SetSpeedImmediate( 50, 30, 30 );
	
//	self waittill( "slowdown" );
//	
//	self SetSpeed( 3, 30 );
	
	self waittill( stopat_notify );

//	IPrintLnBold( "notify hit" );
//	self SetHoverParams( 0 ); 	
	self SetSpeed( 0, 15, 3 );
//	self SetVehGoalPos( self.origin );
	
//	IPrintLnBold( "HOVERING HUEY" );

	
	// TODO: add guys to drop off here
	//IPrintLnBold( self.targetname + " drops off redshirts here" );
//	level thread add_dialogue_line( "HueyPilot", "Out of the chopper, go go go!" );
	
	wait( 2.5 );
	
	// unload guys from the helicopter
	if( IsDefined( self.passengers ) )
	{
		offset = 4;  // this is used to get AI in the correct unload position. driver, copilot, gunner1 and gunner2 = original 4
		
		for( i = 0; i < self.passengers.size; i++ )
		{
			//self thread maps\_vehicle_aianim::guy_unload( self.passengers[ i ], i + offset );	
			//self thread vehicle_unload_single( self.passengers[ i ] );
			self thread vehicle_unload_single( self.passengers[ i ], i + offset );
		}
	}
	
	wait( 6 );
	
//	self SetHoverParams( 50 ); 
	self SetSpeed( 35, 10, 30 );
//	self clearvehgoalpos();
	self ResumeSpeed( 10 );
	
	self waittill_either( "reached_end_node", "near_goal" );
	
//	self vehicle_path_loop( "survey_huey_3_start", "survey_huey_3_loop_start" );
	//IPrintLnBold( self.targetname + " is at the end of its spline" );
	
}

/*===========================================================================
woods and bowman go to their positions, identify targets, count down to kill
===========================================================================*/
boat_landing_sampan_engagement()
{
	waittill_ai_group_cleared("boat_landing_sampan_guys");
	flag_set("boat_landing_sampan_engagement_done");		
//	level thread add_dialogue_line("Woods", "Bowman, take the guy on the left. I've got right. Mason, take the squatters.");
//	
//	level.woods thread squad_behavior_boat_landing_sampan_engagement("woods_sampan_landing_stealth_position");
//	level.bowman thread squad_behavior_boat_landing_sampan_engagement("bowman_sampan_landing_stealth_position");
//	level thread boat_landing_sampan_engagement_synch_shots();
//	level thread boat_landing_sampan_engagement_player_check();
}

squad_behavior_boat_landing_sampan_engagement(stealth_goal_name)
{
	level endon("boat_landing_sampan_engagement_done");
	
	AssertEx(IsDefined(stealth_goal_name), "stealth_goal_name must be defined in squad_behavior_boat_landing_sampan_engagement");
	stealth_goal = GetNode(stealth_goal_name, "targetname");
	
	self.goalradius = 32;
	
	if(self.script_friendname == "Bowman")
	{
		in_position_dialogue_line = "Target acquired.";
		NVA_target = GetEnt("bowman_stealth_target_ai", "targetname");
	}
	else if(self.script_friendname == "Woods")
	{
		in_position_dialogue_line = "Ready?";
		NVA_target = GetEnt("woods_stealth_target_ai", "targetname");
	}
	else
	{
		in_position_dialogue_line = "I'm in position, but I don't have a target!";
		NVA_target = undefined;
	}
	
	self SetGoalNode(stealth_goal);
	self waittill("goal");	
	
	AssertEx(IsDefined(NVA_target), "NVA_target is not defined for " + self.targetname);
//	level thread add_dialogue_line(self.script_friendname, in_position_dialogue_line);
	
	self thread aim_at_target(NVA_target);
	
	self ent_flag_set("synch_shot_ready");
	
	level waittill("fire_at_sampan_guys");
	self shoot_at_target(NVA_target);
	NVA_target DoDamage(NVA_target.health, NVA_target.origin);
	
	self stop_aim_at_target();
}

boat_landing_sampan_engagement_player_check()
{
	level endon("boat_landing_sampan_engagement_done");
	level endon("player_ready_for_synch_shots");
	
	guys = GetEntArray("boat_landing_sampan_guys", "targetname");
	AssertEx((guys.size > 0), "guys for boat_landing_sampan_engagement_player_check are missing");
	
	while(true)
	{
		player = get_players()[0];
		
		for(i=0; i<guys.size; i++)
		{
			if( player is_player_looking_at(guys[i].origin) )
			{
//				level thread add_dialogue_line("Mason", "I'm ready.");
				flag_set("player_ready_for_synch_shots");
				break;
			}
		}
		wait(0.25);
	}
}


// TODO: add conditional checks for who killed who
// - if Mason kills all, yell at him
// - if Mason kills none, yell at him
// - if Mason kills wrong guy, yell at him
// - if Mason kills correct guys, use some awesome one liner
boat_landing_sampan_engagement_synch_shots()
{
	level endon("boat_landing_sampan_engagement_done");
	
	while(true)
	{
		if(level.woods ent_flag("synch_shot_ready") && level.bowman ent_flag("synch_shot_ready") && flag("player_ready_for_synch_shots"))
		{
//			level thread add_dialogue_line("Woods", "OK, on my mark, take them down.");
			break;
		}
		else
		{
			wait(0.5);
		}	
	}
	
	wait(1);
	
//	level thread add_dialogue_line("Woods", "Three...");
	
	wait(1);
	
//	level thread add_dialogue_line("Woods", "Two...");	
	
	wait(1);
	
//	level thread add_dialogue_line("Woods", "One...");	
	
	wait(1);
	
//	level thread add_dialogue_line("Woods", "Mark.");	
	
	level notify("fire_at_sampan_guys");
	
}



// sets ignoreall on friendly squad. "friendly_squad_clear_to_fire" clears it
friendly_squad_holds_fire()
{
	for(i=0; i<level.friendly_squad.size; i++)
	{
		level.friendly_squad[i] set_ignoreall(true);
		level.friendly_squad[i] set_ignoreme(true);
	}
}

friendly_squad_clear_to_fire( flag_name, offset )
{
	AssertEx( IsDefined( flag_name ), "flag_name missing in friendly_squad_clear_to_fire" );
	
	flag_wait( flag_name );
	
	if( IsDefined( offset ) )
	{
		wait( offset );
	}
	
	for(i=0; i<level.friendly_squad.size; i++)
	{
		level.friendly_squad[i] set_ignoreall(false);
		level.friendly_squad[i] set_ignoreme(false);
	}
}

boat_landing_sampan_guys_function()
{		
//	self.overrideActorDamage = ::check_for_killer;
	
	self.goalradius = 32;
	self set_ignoreall(true);
	if(IsDefined(self.animname))
	{
		node = getstruct("boat_landing_sampan_guys_anim_origin", "targetname");
		node.angles = (0,0,0);		
		node thread anim_loop(self, "boat_landing_sampan_guys");
	}
	
	self waittill("death");
	
	level notify("sampan_landing_guy_killed");
}

NVA_patrol_approaches_shore()
{
	patrol_guys = simple_spawn("NVA_jungle_patrol", ::jungle_patrol_function);
}


check_for_killer(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime)
{
	// research
}

/*===========================================================================
SELF = patrolling ai guy (ent) - NEEDS to have target since this is general
===========================================================================*/
jungle_patrol_function()
{
	self endon("death");
	level endon("player_detected");
	self endon("pain");
	self endon("pain_death");
	self set_pacifist(true);
	
	if(IsDefined(self.target) == false)
	{
		AssertMsg(self.targetname + "is missing target for patrol");
	}
	
	self.animname = "generic";
	level.patroller_goalradius = 512;
	level.patroller_sightdist = 262144;
	self.old_sightdist = self.maxsightdistsqrd;  // find out what this does
	self.maxsightdistsqrd = level.patroller_sightdist;
	self.goalradius = level.patroller_goalradius;
	patrol_path = self.target;
	
	self thread waitfor_enemy();  // set goalradius and sightdist when alerted
	
	self thread maps\_patrol::patrol(patrol_path);	
	
	self waittill_either("death", "pain");
//	flag_wait("player_broke_stealth");
	
	flag_set("hillside_encounter_starts");
	self set_pacifist(false);
	self thread rusher_setup();
	PrintLn("player alerted the enemy");
}

cautious_enemy_function()
{	
	self set_pacifist(true);

	self enable_cqbwalk();
	
	if(IsDefined(self.target))
	{
		goal = GetNode(self.target, "targetname");
//		AssertEx(IsDefined(goal), "goal is missing for " + self.targetname);
		self SetGoalNode(goal);
	}
	else
	{
		//IPrintLnBold(self.targetname + " is missing target");
	}
	
	self waittill_either("death", "pain");
	
	flag_set( "hillside_encounter_starts" );
	
}

/*===========================================================================
function for use with "setup_patroller"; will become active if enemy is 
detected or c4 is detonated
===========================================================================*/
waitfor_enemy()
{
	self endon("death");
	self endon("route_changed");
	
	self waittill_either("enemy", "c4_detonated");
	
	self.ignoreall = false;
	self.goalradius = level.default_goalradius;
	self.maxsightdistsqrd = self.old_sightdist;
}

/*===========================================================================
base - friendly_hillside_cover_
	0 - when ambush starts, send guys here. flag_wait( "jungle_ambush_begins" )
	1 - after rushers are dead, send here. may just want to delay it a few seconds after flag set on 0
	2 - go here when "jungle_start_moving_uphill_trigger" trigger is hit. color system is fine here
===========================================================================*/
NVA_ambush()
{
	waterfall_spawner = GetEnt( "jungle_hillside_guys_2_trigger", "targetname" );
//	waterfall_spawner trigger_off();
	
	tree_destruction_trigger = GetEnt( "tree_destruction_trigger", "targetname" );  // turn off trigger so it can't be triggered early
	if( !IsDefined( tree_destruction_trigger ) )
	{
		//IPrintLnBold( "tree_destruction_trigger is missing! can't turn off" );
	}
	
	tree_destruction_trigger trigger_off();	
	
	moveup_nodes = GetNodeArray( "jungle_ambush_american_cover_nodes", "targetname" );  // _far
	AssertEx( ( moveup_nodes.size > 0 ), "moveup_nodes missing in NVA_ambush" );
	
	moveup_trigger = GetEnt( "ambush_moveup_trigger", "targetname" );
	AssertEx( IsDefined( moveup_trigger ), "moveup_trigger is missing in NVA_ambush" );
	moveup_trigger waittill( "trigger" );

	// VO: As the player gets off the boat
	//level.woods thread maps\river_vo::playVO_proper( "follow_me_and_stay_together", 0 );

	choper = GetEnt( "jungle_support_huey_2", "targetname" );
	choper.animname = "us_pilot_1";
	choper thread maps\river_vo::playVO_proper( "activity", 1.8 );
	
	// Can;t say this, Woods is already saying "Have one of your guys guard the boat...."
	//level.woods thread maps\river_vo::playVO_proper( "we_dont_see_anything", 2.0 );


	//..............
	huey_guys = GetEntArray( "support_huey_3_passenger_ai", "targetname" );
	if( huey_guys.size > moveup_nodes.size )
	{
		AssertMsg( "there are more huey_guys than moveup_nodes in NVA_ambush" );
	}
	
	for( i = 0; i < huey_guys.size; i++ )
	{
		huey_guys[ i ].health = 60;
		huey_guys[ i ].goalradius = 128;
		huey_guys[ i ] SetGoalNode( moveup_nodes[ i ] );
	}
	
	ambush_trigger = GetEnt( "jungle_ambush_trigger", "targetname" );  // 
	AssertEx( IsDefined( ambush_trigger ), "trigger is missing for NVA_ambush" );
	ambush_trigger waittill( "trigger", who );
	
	
	// AMBUSH STARTS
	level.us_pilot_2 thread maps\river_vo::playVO_proper( "movement_centurions_4_and_5", 0 );
	wait( 0.5 );

	
	ambush_guys = GetEntArray( "jungle_initial_ambush_guys_ai", "targetname" );
	array_notify( ambush_guys, "ambush_started" );
	
	//IPrintLnBold( "AMBUSH" );
	
	level thread ambush_flare();
	
	flag_set( "jungle_ambush_begins" );	
	
	simple_spawn( "jungle_initial_ambush_guys", ::ambush_spawner );
	
	//TUEY change the music to teh UPHILL_FIGHT_SHORE (kills music)
	setmusicstate ("UPHILL_FIGHT_SHORE");

	delaythread( 1.0, ::kill_guys, huey_guys );


//	battlechatter_on( "allies" );
//	battlechatter_on( "axis" );
	battlechatter_on();

	squad = [];
	squad = array_add( squad, level.bowman );
	squad = array_add( squad, level.woods );
	squad = array_add( squad, level.reznov );	
	
	level.bowman set_force_color( "p" );
	level.woods set_force_color( "b" );
	level.reznov set_force_color( "y" );
	
	wait( 2 );
	
//	squad thread maps\river_util::squad_moves_to_next_safe_point( "friendly_hillside_cover_", "C5_approach_done", undefined, 0, true, 1 );
	squad move_group_to_nodes( "friendly_hillside_cover_0" );

	
	delaythread( 3, ::spawn_manager_enable, "first_hill_wave_guys_spawn_manager" );  // spawn manager on these guys

	squad move_group_to_nodes( "friendly_hillside_cover_1" );  // nodes 2+ are handled with color system
	
}

kill_guys( guys ) 
{
	if( !IsDefined( guys ) || ( guys.size == 0 ) )
	{
		return;
	}
	
	for( i = 0; i < guys.size; i++ )
	{
		guys[ i ].dofiringdeath = true;
		guys[ i ] DoDamage( guys[ i ].health + 10, guys[ i ].origin );
		wait( 0.5 );
	}
}

ambush_flare( guy )
{	
	flare = maps\_vehicle::spawn_vehicle_from_targetname( "ambush_flare" );
	
	flare thread go_path();

	//playsoundatposition ("evt_flare_launch", (-5712, -3776, -56));

	// play regualar trail
	model = spawn( "script_model", (0,0,0) );
	model SetModel( "tag_origin" );
	model LinkTo( flare, "tag_origin", (0,0,0), (0,90,0) );
	PlayFXOnTag( level._effect["fx_flare_sky_red"], model, "tag_origin" );
	playsoundatposition ("evt_flare_launch", model.origin);
	flare waittill( "flare_intro_node" );
	model delete();

	// swap to a burst
	model = spawn( "script_model", (0,0,0) );
	model SetModel( "tag_origin" );
	model LinkTo( flare, "tag_origin", (0,0,0), (0,0,0) );
	PlayFXOnTag( level._effect["flare_trail"], model, "tag_origin" );
	PlayFXOnTag( level._effect["flare_burst"], model, "tag_origin" );
	
	playsoundatposition ("evt_flare_burst", model.origin);
	flare waittill("flare_off");
	model delete();
}

/*===========================================================================
	boat_exit_node = -12918 25160 -32
	#2 -12958 25050 -52
===========================================================================*/
all_yours_vignette()
{
	soldier = simple_spawn_single( "platoon_leader" );
	soldier.goalradius = 32;
	
	soldier = GetEnt( "platoon_leader_ai", "targetname" );
	
	if( (!IsDefined( soldier ) ) || ( !IsDefined( level.woods ) ) )
	{
		AssertMsg( "missing actors for all_yours_vignette" );
	}
	
	structs = getstructarray( "boat_exit_node", "targetname" );  // for some strange reason, there are two of these.
	if( structs.size == 0 )
	{
		AssertMsg( "missing node for all_yours_vignette" );
	}
	
	soldier_goal = GetNode( "platoon_leader_goal", "targetname" );
	if( IsDefined( soldier_goal ) )
	{
		//soldier SetGoalNode( soldier_goal );
	//	Soldier waittill( "goal" );
	}	
	
	dist = 99999999;  // arbitrarily high
	target = ( -12958, 25050, -52 );
	struct = structs[ 0 ];  // initialize this so script doesn't break 
	
	for( i = 0; i < structs.size; i++ )
	{
		current_dist = Distance( target, structs[ i ].origin );  // find the right one
		
		if( current_dist < dist )
		{
			struct = structs[ i ];
			dist = current_dist;
		}
	}
	
//	script_node = getstruct( "boat_exit_script_node", "targetname" );
//	if( IsDefined( script_node ) )
//	{
//		struct = script_node;
		struct.origin = ( -12918, 25176, -32 );
		PrintLn( "using boat_exit_script_node" );
		struct.angles = ( 0, 0, 0 );
//	}	
	
	node = Spawn( "script_origin", struct.origin );
	if( !IsDefined( node.angles ) )
	{
		node.angles = ( 0, 0, 0 );
	}
	else
	{
		node.angles = struct.angles;
	}
	
	soldier.animname = "soldier";
	node thread anim_loop_aligned( soldier, "all_yours_idle", undefined, "start_all_yours" );
	level.woods ent_flag_wait( "anim_done" );
	level.woods thread maps\river_drive::reach_then_loop_aligned( node, "all_yours_idle", "start_all_yours" );
	
	wait( 0.1 );
	
	// soldier and woods should idle when reach is done. "reach_then_loop_aligned" inits/sets flags
//	soldier ent_flag_wait( "reach_done" );
	level.woods ent_flag_wait( "reach_done" );
	
	PrintLn( "notify: start_all_yours" );
	level notify( "start_all_yours" );
	
	guys = [];
	guys[ guys.size ] = soldier;
	guys[ guys.size ] = level.woods;
	
	node thread anim_single_aligned( guys, "all_yours" );
	
	level waittill( "boat_guard_sent" );

	woods_node = GetNode( "boat_landing_american_cover_woods", "targetname" );
	level.woods SetGoalNode( woods_node );	

	soldier_node = GetNode( "boat_landing_reznov", "targetname" );
	soldier SetGoalNode( soldier_node );	
	
	wait( 3 );
	
	reznov_node = GetNode( "boat_landing_bowman", "targetname" );
	level.reznov SetGoalNode( reznov_node );
	
	bowman_node = GetNode( "boat_landing_american_cover_soldier", "targetname" );
	level.bowman SetGoalNode( bowman_node );		
}

move_group_to_nodes( node_array_targetname )
{
	if( !IsDefined( node_array_targetname ) )
	{
		PrintLn( "node_array_targetname is missing in move_group_to_nodes. returning." );
		return;
	}
	
	guy_array = [];
	
	if( !IsArray( self ) )  // make a single entry array so loop will work
	{
		guy_array[ guy_array.size ] = self;
	}
	else  // just use the original array
	{
		guy_array = self;
	}
	
	nodes = GetNodeArray( node_array_targetname, "targetname" );
	if( nodes.size == 0 )
	{
		PrintLn( "no nodes found with targetname " + node_array_targetname );
		return;
	}
	
	if( nodes.size < guy_array.size )
	{
		PrintLn( "not enough nodes for guys to move up. nodes = " + node_array_targetname );
		return;
	}
	
	for( i = 0; i < guy_array.size; i++ )
	{
		guy_array[ i ] SetGoalNode( nodes[ i ] );
	}
	
	//IPrintLnBold( "guys sent to " + node_array_targetname );
}

// helicopter flyby and rappelling spetznaz dropoff, fight NVA
HIND_attack()
{	
	start_trigger = GetEnt("spetsnaz_helicopter_entry_trigger", "targetname");
	AssertEx(IsDefined(start_trigger), "start_trigger for helicopter_flyby beat is missing");
	
	while( true )
	{
		start_trigger waittill( "trigger", who );  // AI can trigger this to bring in enemies. don't trigger helicopters until it's the player.
		if( IsPlayer( who ) ) 
		{
			break;
		}
	}
	
	for( i = 0; i < level.friendly_squad.size; i++ )
	{
		level.friendly_squad[ i ] enable_cqbwalk();
	}
	

//	level thread add_dialogue_line("Woods", "Hold up, we've got movement from the clearing to the North.");	
//	
//	flag_set( "jungle_ambush_begins" );
//	
//	level thread fight_uphill_starts_early();
	
	
	add_spawn_function_veh( "helicopter_nova6_1", ::Hind_spotlight );
	add_spawn_function_veh( "helicopter_nova6_2", ::Hind_spotlight );
	add_spawn_function_veh( "helicopter_rappel", ::Hind_spotlight );
	// spawn in HINDs - don't move - we want them to come in after crashes
	maps\_vehicle::create_vehicle_from_spawngroup_and_gopath( 19 );	
	

	// get hinds
	nova6_helicopter_1 = GetEnt("helicopter_nova6_1", "targetname");
	AssertEx(IsDefined(nova6_helicopter_1), "nova6_helicopter_1 is missing!");	
	nova6_helicopter_1.takedamage = false;
	rappel_helicopter = GetEnt("helicopter_rappel", "targetname");
	AssertEx(IsDefined(rappel_helicopter), "rappel_helicopter is missing!");	
	rappel_helicopter.takedamage = false;
	nova6_helicopter_2 = GetEnt("helicopter_nova6_2", "targetname");
	AssertEx(IsDefined(nova6_helicopter_2), "nova6_helicopter_2 is missing!");	
	nova6_helicopter_2.takedamage = false;
	
	HINDs = [];
	HINDs[ HINDs.size ] = nova6_helicopter_1;
	HINDs[ HINDs.size ] = nova6_helicopter_2;
	HINDs[ HINDs.size ] = rappel_helicopter;

	// get hueys
	huey1 = GetEnt( "jungle_support_huey_1", "targetname" );
	AssertEx( IsDefined( huey1 ), "huey1 is missing" );
	huey2 = GetEnt( "jungle_support_huey_2", "targetname" );
	AssertEx( IsDefined( huey2 ), "huey1 is missing" );
	huey3 = GetEnt( "jungle_support_huey_3", "targetname" );
	AssertEx( IsDefined( huey3 ), "huey3 is missing" );

	huey2.animname = "us_pilot_1";
	huey2 thread maps\river_vo::playVO_proper( "enemy_helicopters_incoming", 5.6 );  // 4.6
	
	//TUEY set music state to CHOPPERS_INBOUND
	setmusicstate ("CHOPPERS_INBOUND");
	
	// tj25 - VO: us pilot 2: they were just waiting for us...	- NO ASSET YET
	huey3.animname = "us_pilot_2";
	huey3 thread maps\river_vo::playVO_proper( "waiting_for_us", 7.8 );
	
	huey1.animname = "us_pilot_3";
	huey1 thread maps\river_vo::playVO_proper( "centurion_4_to_base", 8.5 ); 

	level.woods.bulletsinclip = WeaponMaxAmmo( level.woods.weapon );
	level.bowman.bulletsinclip = WeaponMaxAmmo( level.bowman.weapon );

	level.woods thread shoot_at_target( nova6_helicopter_1, "tag_body", 0, 10 );
	level.bowman thread shoot_at_target( nova6_helicopter_1, "tag_body", 0, 10 );	
	
	// have HINDS fire rockets at hueys
	nova6_helicopter_1 thread HIND_fires_rockets( huey2, 2 );
	nova6_helicopter_2 thread HIND_fires_rockets( huey3, 4 );
	rappel_helicopter thread HIND_fires_rockets( huey1, 2 );
	
//	huey1 SetLookAtEnt( rappel_helicopter );
//	huey2 SetLookAtEnt( nova6_helicopter_2 );
//	huey3 SetLookAtEnt( nova6_helicopter_1 );
	
//	flag_wait("hillside_encounter_starts");
//	autosave_by_name("river_hillside_combat_starts");

	// crash hueys
	huey1 thread damage_then_crash( "huey_1_crash_path_start", "us_pilot_3", undefined );  // huey_1_crash_path_start = us_pilot_3
	huey2 thread damage_then_crash( "huey_2_crash_path_start", "us_pilot_1", undefined ); // huey_2_crash_path_start = us_pilot_1
	huey3 thread damage_then_crash( "support_huey_crash_path_start", "us_pilot_2", undefined );  // support_huey_crash_path_start = us_pilot_2

	// Screen shake, maybee drop some trees
	level thread huey_crash_effects();

	// drop off spetsnaz
	rappel_helicopter thread maps\river_util::ent_name_visible();
	rappel_helicopter thread helicopter_drops_off_troops( "hillside_spetsnaz_rappel_structs", 2 );
	rappel_helicopter thread rappel_helicopter_waits();
	//rappel_helicopter thread helicopter_drops_off_troops("heli_rappel_dropoff_1_troops", "rappel_dropoff");
	nova6_helicopter_1 thread maps\river_util::ent_name_visible();
	nova6_helicopter_1 thread pick_up_nova6();	
	nova6_helicopter_1 thread helicopter_drops_off_troops( "plane_spetsnaz_rappel_structs", 1 );
	nova6_helicopter_2 thread maps\river_util::ent_name_visible();
	nova6_helicopter_2 thread pick_up_nova6();	
	
//	if( !IsDefined( level.hueys_hit ) )
//	{
//		level.hueys_hit = 0;
//	}
//	
//	while( level.hueys_hit != 2 )  // wait until all hueys are hit. this is incremented in "damage_then_crash" 
//	{
//		wait( 1 );
//	}
	
	// bring HINDs into scene
	for( i = 0; i < HINDs.size; i++ )
	{
		path = GetVehicleNode( HINDs[ i ].target, "targetname" );
		HINDS[ i ].drivepath = 1;
		HINDs[ i ] thread go_path( path );
		
	}
	
	level thread proper_tree_sniper( "ruins_snipers" );
	
	level thread ruins_guy_check();
	
	//nova6_helicopter_1 thread helicopter_drops_off_troops("heli_rappel_dropoff_2_troops", "rappel_dropoff", undefined, "spetsnaz_helicopter_entry_trigger");
	
//	nova6_heli_spawners = GetEntArray("heli_rappel_dropoff_1_troops", "targetname");
//	AssertEx((nova6_heli_spawners.size > 0), "nova6_heli_spawners are missing");
//	for(i=0; i<nova6_heli_spawners.size; i++)
//	{
//		nova6_heli_spawners[i] add_spawn_function(::wait_for_trigger_for_combat, "sniper_duel_begins_trigger");
//	}
	
	end_beat_trigger = GetEnt( "hind_takeoff_trigger", "targetname" );
	AssertEx( ( IsDefined( end_beat_trigger ) ), "end_beat_trigger is missing for hind_attack!" );
	end_beat_trigger waittill( "trigger" );
	
	// VISION SET: Burning Section
	level thread maps\createart\river_art::burning_section( 0 );
	
	// Reach rappel guys - VO
	level.woods thread maps\river_vo::playVO_proper( "spetznaz", 0 );
	
	for( i = 0; i < level.friendly_squad.size; i++ )
	{
		level.friendly_squad[ i ] disable_cqbwalk();
	}
}


ruins_guy_check()
{
	level endon( "fight_uphill_done" );
	
	moveup_trigger = GetEnt( "jungle_moveup_trigger_11", "targetname" );
	if( !IsDefined( moveup_trigger ) )
	{
		PrintLn( "ruins_guy_check failed - no moveup_trigger" );
		return;
	}
	moveup_trigger trigger_off();
	
	level thread clear_sm_then_flag( "hind_takeoff_trigger", "ruins_fight_done" );
	
	flag_wait( "ruins_fight_done" );
	
	next_trigger = GetEnt( "jungle_moveup_trigger_11", "targetname" );
	if( IsDefined( next_trigger ) )  // if this is undefined, it's because player moved uphill already. triggering moveup_trigger would cause AI to backpedal
	{
		moveup_trigger notify( "trigger" );  //
	}
}

clear_sm_then_flag( sm_name, flagname, ender )
{
	if( IsDefined( ender ) )
	{
		level endon( ender );
	}
	
	if( !IsDefined( sm_name ) || !IsDefined( flagname ) )
	{
		PrintLn( "missing parameters on clear_aigroup_then_flag" );
		return;
	}
	
//	if( !IsDefined( level._ai_group[ group ] ) ) 
//	{
//		PrintLn( "no aigroup with name " + group );
//		return;
//	}
	
	if( !IsDefined( level.flag[ flagname ] ) )
	{
		flag_init( flagname );
	}
	
	while( true )
	{
		check = is_spawn_manager_cleared( sm_name );
		
		if( check )
		{
			break;
		}
		
		wait( 1 );
	}
	
	flag_set( flagname );
}

//*****************************************************************************
// self = level
//*****************************************************************************

huey_crash_effects()
{
	// 1st huey crashes - 9.5 seconds in
	wait( 9.5 );
	Earthquake( 0.4, 0.6, level.player.origin, 450 );	// power, time, origin, radius
	
	// Tree falls - 9.6 seconds in
	wait( 0.1 );
	tree_pos = ( -10078, 28610, 838 );
	RadiusDamage( tree_pos, 42*12, 99999, 99999, level.player );
	
	// 2nd huey crashes - 11.1 seconds in
	wait( 1.6 );
	Earthquake( 0.5, 1.1, level.player.origin, 750 );	// power, time, origin, radius
	
	// Play pad rumble on player
	for( i=0; i<6; i++ )
	{
		level.player PlayRumbleOnEntity( "damage_heavy" );
		wait( 0.1 );
	}
}


//*****************************************************************************
//*****************************************************************************

Hind_attach_crate()  // self = hind
{
	maps\river_util::Print_debug_message( "attaching rope to " + self.targetname, true );
	
	offset = ( 0, 0, -150 );
	hind_tag = "tag_ground";
	crate_tag = "p_rus_metal_crate";
	
	
	// spawn crate model
	crate = Spawn( "script_model", self.origin + offset );
	crate SetModel( "p_rus_metal_crate" );
	crate RotateRoll( 180, 1 );
	crate waittill( "rotatedone" );
	
	crate LinkTo( self, hind_tag, offset );  // rope is smoke and mirrors need manual link	
	
	// create rope; attach hind and crate
	rope = CreateRope( self GetTagOrigin( hind_tag ), ( 0, 0, 0 ), 150, self );
	RopeSetParam( rope, "width", 8 );
//	RopeAddEntityAnchor( rope, 0, self, self worldtolocalcoords( self GetTagOrigin( hind_tag ) ) );
	wait( 1 );
	roperemoveanchor( rope, 0 );
	wait( 1 );
	RopeAddEntityAnchor( rope, 0, crate, crate worldtolocalcoords( crate GetTagOrigin( crate_tag ) ) );
	RopeSetFlag( rope, "keep_entity_anchors", 1 );
	
//	crate PhysicsLaunch( crate.origin + ( 0, 0, 10 ), ( 0, 0, 5 ) );
}

Hind_spotlight()  // self = hind that needs a spotlight
{
	tag = "tag_turret_door";
	
	if( IsDefined( self GetTagOrigin( tag ) ) )
	{
		PlayFXOnTag( level._effect[ "Hind_spotlight" ], self, tag );
	}
	else
	{
		PrintLn( self.targetname + " couldn't play hind_spotlight effect since tag is missing" );
	}
}

rappel_helicopter_waits()
{
	rappel_dropoff_trigger = GetEnt( "hind_rappel_entry_trigger", "targetname" );
	if( IsDefined( rappel_dropoff_trigger ) )  // Hdon't assert since this is BSP related
	{
		self waittill( "hide" );
		self SetSpeed( 0, 30 );
		
		//rappel_dropoff_trigger waittill( "trigger" );
		flag_wait( "hind_rappel_entry" );  // this is a flag in case player rushes past trigger before hind is in "wait" position
	
		self ResumeSpeed( 20 );	
	}
	else
	{
		//IPrintLnBold( "rappel_dropoff_trigger is missing for HIND attack!" );
	}
}

/*==========================================================================
FUNCTION: tree_sniper_check
SELF: level (not used)
PURPOSE: set up generic tree snipers. this will:
	- randomize tree sniper locations without changing _tree_snipers from CoD5
	- play effect of sniper "reveal"
	- play VO to prompt player to notice the tree sniper

ADDITIONS NEEDED:
==========================================================================*/
tree_sniper_check( trigger_noteworthy )
{
	AssertEx( IsDefined( trigger_noteworthy ), "trigger_noteworthy is missing for tree_sniper_check!" );
	
	sniper_triggers = GetEntArray( trigger_noteworthy, "script_noteworthy" );
	
	if( ( sniper_triggers.size == 0 ) )  // check for more than one since we do a "random" sniper
	{
		//IPrintLnBold( "sniper_triggers missing with noteworthy " + trigger_noteworthy );
		return;
	}
	x = RandomInt( sniper_triggers.size );
	
	if( sniper_triggers.size > 1 )
	{
		for( i = 0; i < sniper_triggers.size; i++ )
		{
			if( i == x )  // we pick one randomly and leave it on
			{
				continue;
			}
			
			sniper_triggers[ i ] trigger_off();  // turn the other ones off - possibly delete later
		}
	}
	else
	{
		x = 0;  // we only haVe one tree sniper, don't turn anything off
	}
	
	// this may look weird, but it has to do with _tree_sniper setup. trigger targets sniper, sniper targets node, node targets struct for anims.
	if( !IsDefined( sniper_triggers[ x ].target ) )  
	{
		PrintLn( "tree_sniper trigger is missing target" );  
		return;
	}
	
	sniper = GetEnt( sniper_triggers[ x ].target, "targetname" );
	
	if( !IsDefined( sniper.target ) )
	{
		PrintLn( "sniper isn't targeting node" );
		return;
	}
	
	node = GetNode( sniper.target, "targetname" );
	
	if( !IsDefined( node.target ) )
	{
		PrintLn( "struct is missing for tree sniper reveal" );
		return;
	}
	
	anim_origin = GetEnt( node.target, "targetname" );
	
	if( !IsDefined( anim_origin.target ) )
	{
		PrintLn( "tree origin is missing" );
		return;
	}
	
	tree_origin = GetEnt( anim_origin.target, "targetname" );
	
	sniper_hide_origin = Spawn( "script_model", tree_origin.origin );
	sniper_hide_origin SetModel( "tag_origin" );
	PlayFXOnTag( level._effect[ "tree_sniper_hide" ], sniper_hide_origin, "tag_origin" );  // play frond effect before trigger
	
	trees = GetEntArray( "tree_sniper_tree", "targetname" );
	
	sniper_triggers[ x ] waittill( "trigger" );
	
	sniper_hide_origin Delete();
	PlayFX( level._effect[ "tree_sniper_reveal" ], tree_origin.origin ); // play "reveal" effect
	
	//IPrintLnBold( "Watch out! Tree sniper!" );

	sniper_vo_warning( 1 );

	sniper thread tree_sniper_glint();
}


proper_tree_sniper( trigger_name )
{
	trigger = GetEnt( trigger_name, "script_noteworthy" );
	sniper_spawner = GetEnt( trigger.target, "targetname" );
	
	trees = GetEntArray( "tree_sniper_tree", "targetname" );
	
	my_tree = trees[ 0 ]; // initialize 
	
	dist = 9999;  // arbitrary number that'd be higher than sniper -> tree distance
	
	// get the tree sniper's tree, since it's in a prefab we need to check to see which is closest 
	for( i = 0; i < trees.size; i++ )
	{
		current_dist = Distance( sniper_spawner.origin, trees[ i ].origin );
		if( current_dist < dist )
		{
			my_tree = trees[ i ];
			dist = current_dist;
		}
	}
	
	anim_node = GetNode( my_tree.target, "targetname" );
	anim_angles = VectorToAngles( AnglesToForward( anim_node.angles ) * ( -1 ) );
	
	anim_origin = Spawn( "script_origin", anim_node.origin );
	//anim_origin.angles = anim_angles;
	anim_origin.angles = anim_node.angles;
	
	frond_origin = Spawn( "script_model", my_tree.origin );
	frond_origin.angles = my_tree.angles;
	frond_origin SetModel( "tag_origin" );
	
	sniper = simple_spawn_single( sniper_spawner );  // spawn function setup elsewhere for bias
	
	counter = 0;
	while( !IsDefined( sniper ) )
	{
		wait( 0.1 );
		counter++;
		
		if( counter == 10 )
		{
			PrintLn( "couldn't spawn sniper, returning. name = " + sniper_spawner.targetname );
			return;
		}
	}
	
	sniper thread maps\_tree_snipers::tree_death( sniper, anim_origin, true );
	
	PlayFXOnTag( level._effect[ "tree_sniper_hide" ], frond_origin, "tag_origin" );  // play frond effect before trigger
	
	trigger waittill( "trigger" );
	
	sniper thread notify_delay( "tree_sniper_reveal", 1 );
	
	if( IsDefined( sniper ) )
	{
		sniper.realhealth = 150;
	}

	sniper_vo_warning( 1 );

	sniper thread tree_sniper_glint();	
	
	frond_origin Delete();  // get rid of "hide" frond effect 
	PlayFX( level._effect[ "tree_sniper_reveal" ], my_tree.origin ); // play "reveal" effect
	
	sniper waittill( "fake tree death" );
	PlayFX( level._effect[ "tree_sniper_reveal" ], my_tree.origin ); // play "reveal" effect again 
	
}


//*****************************************************************************
// self = sniper spawner
//*****************************************************************************

tree_sniper_glint()
{
	wait( 0.2 );
	
//	name = self.targetname + "_ai";
//	sniper = GetEnt( name, "targetname" );
	if( !IsDefined( self ) )
	{
		return;
	}
	
	sniper = self;

	sniper endon( "death" );
	sniper endon( "fake tree death" );
	
	sniper.fake_death = 0;
	sniper thread sniper_wait_for_fake_death();
	
	last_vo_time = GetTime();
	vo_time_delay = 7;
	num_vo_callout = 0;
	
	while( !sniper.fake_death )
	{
		time = GetTime();
		
		if( num_vo_callout < 2 )
		{
			dt = (time - last_vo_time ) / 1000;
			if( dt > vo_time_delay )
			{
				last_vo_time = time;
				sniper_vo_warning( 0 );
				num_vo_callout++;
			}
		}
			
		forward = level.player.origin - sniper.origin; 
		forward = VectorNormalize( forward );
		
		up = AnglesToUp( level.player.angles );
		
		//effect_pos = sniper.origin + (forward*60) + (up*20);
		//effect_pos = sniper GetTagOrigin( "TAG_NSP3A" );
		
		//PlayFX( level._effect["tree_sniper_glint"], effect_pos, forward );
		if( !IsDefined( sniper GetTagOrigin( "tag_scope_VZoom" ) ) )
		{
			break;
		}
		
		PlayFXOnTag( level._effect[ "tree_sniper_glint" ], sniper, "tag_scope_VZoom" );
		wait( 1.0 + RandomFloat(2.0) );		// 1.3   2.5
	}
}


//*****************************************************************************
// Sniper VO 
//*****************************************************************************

sniper_vo_warning( first_time )
{
	if( first_time )
	{
		// Make sure the first time we call out snipers, its the 1st VO line
		if( !isdefined(level.sniper_vo_index) )
		{
			level.sniper_vo_index = 0;
		}
		// 2nd time, use a different one
		else
		{
			rval = randomint( 100 );
			if( rval > 50 )
			{
				level.sniper_vo_index = 1;
			}
			else
			{
				level.sniper_vo_index = 2;
			}
		}
	}
	
	// Play the VO line
	if( level.sniper_vo_index == 0 )
	{
		level.woods maps\river_vo::playVO_proper( "snipers_in_the_trees", 0 );
	}
	else if( level.sniper_vo_index == 1 )
	{
		level.woods thread maps\river_vo::playVO_proper( "check_high_snipers", 0 );		
	}
	else
	{
		level.woods thread maps\river_vo::playVO_proper( "in_the_tree_sniper", 0 );		
	}
	
	// Cycle through the lines
	level.sniper_vo_index++;
	if( level.sniper_vo_index > 2 )
	{
		level.sniper_vo_index = 0;
	}
}


//*****************************************************************************
// self = sniper
//*****************************************************************************

sniper_wait_for_fake_death()
{
	self endon( "death" );

	self waittill( "fake tree death" );
	self.fake_death = 1;
}


//*****************************************************************************
//*****************************************************************************

damage_then_crash( rail_start_node, anim_name, delay_time )
{
	self.takedamage = false;
	self waittill( "HIND_firing_rockets" );
	//self waittill( "HIND_rocket_damage" );
	
//	IPrintLnBold( self.targetname + " HIT!" );
	
	if( !IsDefined( level.hueys_hit ) )
	{
		level.hueys_hit = 0;
	}
	
	level.hueys_hit++;	
	
	self PlaySound( "evt_enemy_heli_crash" );
	
	self maps\river_anim::helicopter_crash_path( rail_start_node, anim_name, delay_time, "HIND_rocket_damage" );
	
//	IPrintLnBold( self.targetname + " DOWN!" );
}

HIND_fires_rockets( target_ent, num_volleys )
{
	self endon("death");	
	
	if( !IsDefined( target_ent ) )
	{
		PrintLn( self.targetname + " missing a target_ent for HIND_fires_rockets" );
		return;
	}
	
	self waittill( "fire_rockets" );
	
	target_ent notify( "HIND_firing_rockets" );
	
	self.hind_target = target_ent;
	
	rocket_tag = "tag_origin";
	wait_min = 5;
	wait_max = 8.5;
	
	rocket_weapon = "hind_rockets_sp";
	switch(self.vehicletype)
	{
		case "heli_hind_doublesize":
		case "heli_hind":
			rocket_tag = "tag_rocket1";
			wait_min = 5;
			wait_max = 8.5;
			rocket_weapon = "hind_rockets_sp";
		break;
		
		case "heli_hip":
			rocket_tag = "tag_rocket_left";
			wait_min = 2;
			wait_max = 3.5;
			rocket_weapon = "hind_rockets_sp";
		break;
	}
		
	//IPrintLnBold( self.targetname + " firing at " + target_ent.targetname );		
		
	if( !IsDefined( num_volleys ) )
	{	
		num_volleys = 6;	
	}
	
	for( i = 0; i < num_volleys; i++ )
	{
//		rand_wait = RandomFloatRange(wait_min, wait_max);
//		wait(rand_wait);
		forward = AnglesToForward(self.angles);
		start_point = self GetTagOrigin(rocket_tag) + (60 * forward);
		rocket = MagicBullet( rocket_weapon, start_point, ( self.hind_target.origin + ( 0, 0, -80 ) ), self, self.hind_target );
		//rocket thread rocket_rumble_when_close(player);
		wait( 0.1 );
	}	
	
	wait( 0.5 );
	
	target_ent notify( "HIND_rocket_damage" );  // in case rockets miss
}

fight_uphill_starts_early()
{
	trigger = GetEnt( "jungle_hillside_guys_2_trigger", "targetname" );
	AssertEx( IsDefined( trigger ), "trigger is missing for fight_uphill_starts_early" );
	trigger waittill( "trigger" );
	
	flag_set( "hillside_encounter_starts" );
}

wait_for_trigger_for_combat(trigger_name)  // self = AI
{
	self endon( "death" );
	
	wait(7);
	
	self set_pacifist(true);
	
	AssertEx(IsDefined(trigger_name), "trigger_name is missing in wait_for_trigger_for_combat");
	trigger = GetEnt(trigger_name, "targetname");
	AssertEx(IsDefined(trigger), "trigger is undefined for wait_for_trigger_for_combat");
	trigger waittill("trigger");
	
	self set_pacifist(false);
	
}

// fight NVA/spetznax uphill leading to plane. 2 remaining helicopters with nova6 fly off
fight_uphill()  // beat 3
{
	PrintLn("fight_uphill started");
	
//	for(i=0; i<level.friendly_squad.size; i++)
//	{
//		level.friendly_squad[i] thread maps\river_util::go_to_nodes("american_hillside_combat_start_nodes");
//	}
	
	level thread hillside_fight_checkpoints();
	level thread hillside_encounter();
	level thread proper_tree_sniper( "waterfall_snipers" );
	//level thread tree_sniper_check( "hind_sniper_left" );
	level thread proper_tree_sniper( "hind_sniper_right" );
	level thread jungle_helicopter_support();
	
	hind_sniper_left = GetEnt( "hind_sniper_left", "script_noteworthy" );
	hind_sniper_left trigger_off();
	
//	end_trigger = GetEnt("sniper_duel_begins_trigger", "targetname");
//	AssertEx(IsDefined(end_trigger), "end_trigger for fight_uphill is missing");
//	end_trigger waittill("trigger");
//	flag_set("hillside_encounter_done");
//	waittill_ai_group_cleared( "plane_spetsnaz" );

	huey1 = GetEnt( "jungle_support_huey_1", "targetname" );
	AssertEx( IsDefined( huey1 ), "huey3 is missing" );

	huey1_idle_location = GetVehicleNode( "survey_huey_1_idle_path_1", "targetname" );
	AssertEx( IsDefined( huey1_idle_location ), "huey_idle_location is missing in fight_uphill" );

	huey2 = GetEnt( "jungle_support_huey_2", "targetname" );
	AssertEx( IsDefined( huey2 ), "huey3 is missing" );

	huey2_idle_location = GetVehicleNode( "huey_2_idle_path_start", "targetname" );
	AssertEx( IsDefined( huey2_idle_location ), "huey_idle_location is missing in fight_uphill" );

	huey3 = GetEnt( "jungle_support_huey_3", "targetname" );
	AssertEx( IsDefined( huey3 ), "huey3 is missing" );

	// huey3 is special - it idles after making a loop on the "support" rail
	huey3_idle_location = GetVehicleNode( "support_huey_idle_location", "targetname" );
	AssertEx( IsDefined( huey3_idle_location ), "huey_idle_location is missing in fight_uphill" );
	
	huey_stop_strafing_trigger =  GetEnt( "support_huey_idle_trigger", "targetname" );
	AssertEx( IsDefined( huey_stop_strafing_trigger ), "huey_stop_strafing_trigger is missing in fight_uphill" );	
	huey_stop_strafing_trigger waittill( "trigger" );
	
	/#
	//IPrintLnBold( "huey idle trigger hit. making huey idle now." );
	#/
	
	huey1 SetDrivePathPhysicsScale( 3.0 );
	huey1 notify( "stop path" );
	huey1 AttachPath( huey1_idle_location );
	huey1.drivepath = 0;
	huey1 thread go_path( huey1_idle_location );
	
	huey2 SetDrivePathPhysicsScale( 3.0 );
	huey2 notify( "stop path" );
	huey2 AttachPath( huey2_idle_location );
	huey2.drivepath = 0;
	huey2 thread go_path( huey2_idle_location );
	
	huey3 SetDrivePathPhysicsScale( 3.0 );
	huey3 notify( "stop path" );
	huey3.drivepath = 0;
	huey3 AttachPath( huey3_idle_location );
	huey3 thread go_path( huey3_idle_location );
}


heli_hover()
{
//	self waittill( "reached_end_node" );
//	
//	self SetVehGoalPos( self.currentnode.origin, true, true );
//	
	self.dontunloadonend = true;
	self waittill( "idle_here" );
	
//	IPrintLnBold( self.targetname + " is idling" );
	
	self ResumeSpeed( 30 );
	
	self SetVehGoalPos( self.origin, true );

	self SetHoverParams( 50 );
}

/*==========================================================================
FUNCTION: jungle_helicopter_support
SELF: level
PURPOSE: set up all huey gunship support behavior here 

ADDITIONS NEEDED:
==========================================================================*/
jungle_helicopter_support()
{	
	huey3 = GetEnt( "jungle_support_huey_3", "targetname" );
	AssertEx( IsDefined( huey3 ), "huey3 is missing" );
	huey3.takedamage = false;
	
	huey3 endon( "death" );
	
	rocket_target1 = getstruct( "support_helicopter_hillside_struct_2", "targetname" );
	rocket_target2 = getstruct( "support_helicopter_hillside_struct_3", "targetname" );
	
	huey3_support_start = GetVehicleNode( "support_huey_hillside_kill_rail_start", "targetname" );
	AssertEx( IsDefined( huey3_support_start ), "huey3_support_start is missing in jungle_helicopter_support" );
	
	flag_wait( "begin_helicopter_support" );
	
	spawn_manager_enable( "hillside_helicopter_kill_spawn_manager" );
	
//	huey3 SetSpeed( 60, 30 );
	huey3 SetDrivePathPhysicsScale( 5.0 );
	
	huey3.drivepath = 0;
	huey3 thread go_path( huey3_support_start );
	wait( 2 );
	huey3 AttachPath( huey3_support_start );
	//huey3 StartPath( huey3_support_start );
	
	huey3 thread maps\river_util::helicopter_fires_rockets_at_target( "hillside_support", rocket_target1, rocket_target2, 1 );
	
	// turn on tree damage trigger so helicopter blows it up every time
	tree_destruction_trigger = GetEnt( "tree_destruction_trigger", "targetname" );
	if( !IsDefined( tree_destruction_trigger ) )
	{
		//IPrintLnBold( "tree_destruction_trigger is missing! can't turn on!" );
	}
	
	tree_destruction_trigger trigger_on();  
	
	level thread trigger_radius_damage( "tree_destruction_trigger", 9999999, 400, true );

	
	huey3 notify_delay( "hillside_support", 6 );
	
//	wait( 2 );
//	
//	huey3 notify( "hillside_support" );
//	huey3 ResumeSpeed( 30 );
	
	//huey3 gunship_support( "support_helicopter_hillside_struct_1", "support_helicopter_hillside_struct_2", "support_helicopter_hillside_struct_3", 1, 1 );
	//IPrintLnBold( "gunship support manual target enabled" );
	//huey3 maps\_vehicle_turret_ai::enable_turret( 0, "fast_mg", "axis", undefined, undefined, undefined );
	
	if( !IsDefined( level.support_huey_kills ) )
	{
		level.support_huey_kills = 0;
	}
	
	while( huey3._forced_target_ent_array.size > 0 )
	{
		target = random( huey3._forced_target_ent_array );
		if( IsDefined( target ) )
		{
			huey3 maps\river_util::vehicle_static_line_fire( 1, target.origin, target.origin, 2 );
		}
		//huey3 maps\river_util::vehicle_gunner_fire( 2, target );
		wait( 3 );
		huey3._forced_target_ent_array = array_removedead( huey3._forced_target_ent_array );
	}
	
	//IPrintLnBold( "hillside clear of targets" );
	spawn_manager_disable( "hillside_helicopter_kill_spawn_manager" );
}

/*==========================================================================
FUNCTION: trigger_radius_damage
SELF: level, though this could be changed to a trigger
PURPOSE: to do radius damage once a trigger is hit

ADDITIONS NEEDED:
==========================================================================*/
trigger_radius_damage( trigger_name, damage, radius, to_delete, offset_struct_name )
{
	if( !IsDefined( trigger_name ) )
	{
		PrintLn( "trigger_name is missing for trigger_radius_damage" );
		return;
	}
	
	if( !IsDefined( damage ) )
	{
		PrintLn( "damage is missing in trigger_radius_damage" );
		return;
	}
	
	if( !IsDefined( radius ) )
	{
		PrintLn( "radius is missing in trigger_radius_damage" );
		return;
	}
	
	trigger = GetEnt( trigger_name, "targetname" );
	if( !IsDefined( trigger ) )
	{
		PrintLn( "trigger is missing for trigger_radius_damage" );
		return;
	}
	
	if( !IsDefined( offset_struct_name ) )
	{
		explosion_point = trigger.origin;	
	}
	else
	{
		struct = getstruct( offset_struct_name, "targetname" );
		if( IsDefined( struct ) )
		{
			explosion_point = struct.origin;
		}
		else
		{
			explosion_point = trigger.origin;
		}
	}	
	
	trigger waittill( "trigger" );
	

	// Add two explosion effects in the area of the trees falling
	for( i=0; i<2; i++ )
	{
		dx = randomfloatrange( -150, 150 );
		dy = randomfloatrange( -150, 150 );
		exp_pos = ( explosion_point[0]+dx, explosion_point[1]+dy, explosion_point[2]+50 );
		playsoundatposition ("evt_big_explo2", (0,0,0));
		PlayFX( level._effect["chopper_explosion"], exp_pos );
	}
	
	RadiusDamage( explosion_point, radius, damage+1, damage );
	
	if( IsDefined( to_delete ) && ( to_delete == true ) )
	{
		trigger Delete();
	}
}

/*==========================================================================
FUNCTION: gunship_support
SELF: helicopter doing some sweeps and killing AI
PURPOSE:

ADDITIONS NEEDED:
==========================================================================*/
gunship_support( sweep_point_1_targetname, sweep_point_2_targetname, sweep_point_3_targetname, num_sweeps, turret_num )
{
	if( !IsDefined( sweep_point_1_targetname ) && !IsDefined( sweep_point_2_targetname ) && !IsDefined( sweep_point_3_targetname ) )
	{
		PrintLn( self.targetname + " not sweeping. No sweep_points detected." );
		return;
	}

	//IPrintLnBold( "Tons of infantry coming from the North-East!" );

	sweep_point_1 = getstruct( sweep_point_1_targetname, "targetname" );
	sweep_point_2 = getstruct( sweep_point_2_targetname, "targetname" );
	sweep_point_3 = getstruct( sweep_point_3_targetname, "targetname" );

	AssertEx( IsDefined( sweep_point_1 ), "sweep_point_1 is missing in gunship_support for " + self.targetname );
	AssertEx( IsDefined( sweep_point_2 ), "sweep_point_2 is missing in gunship_support for " + self.targetname );
	AssertEx( IsDefined( sweep_point_3 ), "sweep_point_3 is missing in gunship_support for " + self.targetname );
	
	if( !IsDefined( turret_num ) )
	{
		turret_num = 0;
	}

	if( !IsDefined( num_sweeps ) )
	{
		num_sweeps = 1;
	}	

	speed = self GetSpeed();
	scaler = 1;

	dist_1_to_2 = Distance( sweep_point_1.origin, sweep_point_2.origin );
	time_1_to_2 = scaler / ( speed / dist_1_to_2 );		
	
	dist_2_to_3 = Distance( sweep_point_2.origin, sweep_point_3.origin );
	time_2_to_3 = scaler / ( speed / dist_2_to_3 );
	
	dist_3_to_1 = Distance( sweep_point_3.origin, sweep_point_1.origin );
	time_3_to_1 = scaler / (speed / dist_3_to_1 );		
	
	for( i = 0; i < num_sweeps; i++ )
	{
		self maps\river_util::vehicle_static_line_fire( turret_num, sweep_point_1.origin, sweep_point_2.origin, time_1_to_2 );
		wait( 0.1 );
		self maps\river_util::vehicle_static_line_fire( turret_num, sweep_point_2.origin, sweep_point_3.origin, time_2_to_3 );
		wait( 0.1 );
		self maps\river_util::vehicle_static_line_fire( turret_num, sweep_point_3.origin, sweep_point_1.origin, time_3_to_1 );		
		wait( 0.1 );
	}
}

/*==========================================================================
FUNCTION: hillside_fight_checkpoints
CALLED ON (self): level
PURPOSE: to reduce a large amount of frustration in fighting uphill in event 2

ADDITIONS NEEDED:
==========================================================================*/
hillside_fight_checkpoints()
{
	level endon( "fight_uphill_done" );
	
	checkpoint1 = GetEnt( "spetsnaz_helicopter_entry_trigger", "targetname" );
	AssertEx( IsDefined( checkpoint1 ), "checkpoint1 is missing in hillside_fight_checkpoints" );
	checkpoint1 waittill( "trigger" );
	autosave_by_name( "river_hill_1" );
	
	checkpoint2 = GetEnt( "hind_takeoff_trigger", "targetname" );
	AssertEx( IsDefined( checkpoint2 ), "checkpoint2 is missing in hillside_fight_checkpoints" );
	checkpoint2 waittill( "trigger" );
	autosave_by_name( "river_hill_2" );	
	
	checkpoint3 = GetEnt( "spetznaz_on_hill_engagement_trigger", "targetname" );
	AssertEx( IsDefined( checkpoint3 ), "checkpoint3 is missing in hillside_fight_checkpoints" );
	checkpoint3 waittill( "trigger" );
	autosave_by_name( "river_hill_3" );	
}

// search through the plane wreckage
investigate_plane() // beat 4
{
	level thread wing_rush_failsafe();
	
	bad_moveup_trigger = GetEnt( "jungle_moveup_trigger_13", "targetname" );  // turn this off to see if we want to delete it
	bad_moveup_trigger trigger_off();
	
	wing_start_trigger = GetEnt( "player_arrives_at_plane_crash_trigger", "targetname" );
	
	level thread set_flag_on_trigger( wing_start_trigger, "player_at_wing" );
	
	waittill_ai_group_cleared( "plane_spetsnaz" );
	//IPrintLnBold( "spetsnaz cleared" );
	//wing_start_trigger notify( "trigger" );

	flag_set( "fight_uphill_done" );
	
	enemies = GetAIArray( "axis" );
	array_thread( enemies, maps\river_util::kill_me );	

	wait( 1 );
	
//	squad = [];
//	squad array_add( squad, level.bowman );
//	squad array_add( squad, level.woods );
//	squad thread maps\river_util::actor_move_group( "recapture_pbr_ground_squad_start" );
	
//	PrintLn("investigate_plane started");
//	maps\river_rail::C5_approach();
}

wing_rush_failsafe()
{
	arrive_at_plane_trigger = GetEnt( "player_arrives_at_plane_crash_trigger", "targetname" );
	AssertEx( IsDefined( arrive_at_plane_trigger ), "arrive_at_plane_trigger is missing in fight_uphill" );
	arrive_at_plane_trigger waittill( "trigger" );
	
	flag_set( "player_at_wing" );
	
	enemies = GetAIArray( "axis" );	
	array_thread( enemies, maps\river_util::kill_me );
}

// your boat is discovered by NVA, must get boat back via sniping from plane
plane_nose_section() // beat 5
{
	PrintLn("recapture_pbr started");
	level thread friendly_squad_holds_fire();
	level thread friendly_squad_clear_to_fire( "patrol_boat_landed", 3 );
	level thread plane_nose_section_friendlies_start();
	
//	simple_spawn( "recapture_pbr_enemies_closer" );
	
	level thread monitor_threat_sniper_threat_bias();
	
/*===========================================================================
sequence of events
1: patrol boat comes in - OK
2: patrol boat drops off guys after it lands  - OK
3: 2 sampans go to alcove, fire on friendly boat, kill friendlies (w/explosion) - on one landing - OK
4. 2 sampans now docked; spawner begins - OK
5. defend squad to shore - OK
6 boat hijacking - OK
7. 2 more sampans come in from right - OK
8. nose knockdown
===========================================================================*/	
	// patrol boat comes in
	level thread patrol_boat_harassment();
	level thread give_player_ammo();
	// 2 sampans go into alcove	
	level thread sampan_arrival();
	level thread boatjacking();	
	
	level thread patrol_boat_hint_dialogue();
	
	flag_wait( "boatjack_started" );
//	IPrintLnBold( "sniper support done" );
//	Spawn_manager_disable( "player_in_C5_nose" );
	
	level thread player_shot_down_from_nose();
	
	flag_wait( "C5_nose_knockdown_done" );
	
	enemies = GetEntArray( "recapture_pbr_enemies_ai", "targetname" );
	// no error check, just in case player killed them all
	array_thread( enemies, maps\river_util::kill_me );
	
}

patrol_boat_hint_dialogue()
{
//	level thread add_dialogue_line( "Woods", "Mason, eyes on the river. Do you see that gun on that patrol boat? That's going to cause all sorts of problems for us." );
	
	flag_wait( "sniper_support_done" );
	
	while( ( flag( "patrol_boat_dead" ) == false ) && ( flag( "patrol_boat_disabled" ) == false ) )
	{
//		level thread add_dialogue_line( "Woods", "We can't move up with that patrol boat pinning us down! Take it out somehow, Mason!" );
		
		wait( 15 );
	}
}

sampan_arrival()
{
	level thread sampans_go_into_alcove_and_kill_friendlies();	
	level thread sampans_land_on_west_shore();	
}

// temp solution to china lake not respawning, and switching weapons drops through plane nose
give_player_ammo()
{
	level endon( "C5_nose_knockdown_done" );
	
	level thread imply_explosives_use();
	
	while( flag( "patrol_boat_dead" ) == false )
	{
		player = get_players()[0];
		
		if( player HasWeapon( "china_lake_sp" ) )
		{
			player GiveMaxAmmo( "china_lake_sp" );
		}
		else
		{
			//
		}
		
		wait( 2 );
	}
}

imply_explosives_use()
{
	level endon( "patrol_boat_dead" );
	level endon( "patrol_boat_disabled" );
	
	flag_wait( "patrol_boat_landed" );

	patrol_boat = GetEnt( "recapture_pbr_patrol_boat", "targetname" );
	
	while( ( flag( "patrol_boat_dead" ) == false ) && ( flag( "patrol_boat_disabled" ) == false ) )
	{
		wait( 10 );
		
		if( patrol_boat.gunners == 1 )
		{
//			level thread add_dialogue_line( "Reznov", "Disable that patrol boat, comrade! The turret on the bow is too dangerous!" );
		}
		else
		{
			// say nothing
		}
	}
}

sampans_land_on_west_shore()
{
//	flag_wait( "patrol_boat_dead" );
	
	wait( RandomInt( 5, 10 ) );
	
	maps\_vehicle::create_vehicle_from_spawngroup_and_gopath( 23 );
	
	wait(1);
	
//	level thread add_dialogue_line( "Woods", "Sampans incoming from the West! Get on them, Mason!" );
	
	sampan1 = GetEnt( "west_shore_sampan_1", "targetname" );
	AssertEx( IsDefined( sampan1 ), "sampan1 is missing in sampans_land_on_west_shore" );
	sampan2 = GetEnt( "west_shore_sampan_2", "targetname" );
	AssertEx( IsDefined( sampan2 ), "sampan2 is missing in sampans_land_on_west_shore" );
	
	sampan1 ent_flag_wait( "landing_done" );
	sampan2 ent_flag_wait( "landing_done" );
	flag_set( "west_shore_sampans_landed" );
}

player_shot_down_from_nose()
{
	maps\_vehicle::create_vehicle_from_spawngroup_and_gopath( 22 );
	
	RPG_sampan = GetEnt( "recapture_pbr_sampan_east", "targetname" );
	AssertEx( IsDefined( RPG_sampan ), "RPG_sampan is missing" );
	
	foreshadow_destination = getstruct( "nose_knockdown_foreshadow_struct", "targetname" );
	AssertEx( IsDefined( foreshadow_destination ), "foreshadow_destination is missing" );
	
	MagicBullet( "rpg_magic_bullet_sp", RPG_sampan.origin + ( 0, 0, 50 ), foreshadow_destination.origin );
	
	RPG_sampan.takedamage = false;  
	
	RPG_sampan waittill( "fire_RPG" );
	wait( 1 );
//	level thread add_dialogue_line( "Woods", "We have sampans coming in from the East - MASON GET DOWN!" );
//	level thread add_dialogue_line( "Bowman", "RPG!!" ) ;
	
	destination = get_players()[0];
	AssertEx( IsDefined (destination ), "destination missing in C5_nose_breaks_off" );		
	
	MagicBullet( "rpg_magic_bullet_sp", RPG_sampan.origin + ( 0, 0, 50 ), destination.origin );
	RPG_sampan.takedamage = true;
	
	maps\_vehicle::create_vehicle_from_spawngroup_and_gopath( 25 );	
	
	wait( 2 );
	
//	level thread maps\river_rail::C5_nose_knockdown();	
	
	enemies = GetEntArray( "recapture_pbr_enemies_ai", "targetname" );	
	for( i = 0; i < enemies.size; i++ )
	{
		enemies[i] maps\river_util::kill_me();
	}
}

patrol_boat_harassment()
{
	flag_wait( "plane_crash_search_done" );
	maps\_vehicle::create_vehicle_from_spawngroup_and_gopath( 21 );  // patrol boat	
//	wait( RandomInt( 15, 20 ) );
	
//	autosave_by_name( "river_boat_suppression" );
	
	patrol_boat = GetEnt( "recapture_pbr_patrol_boat", "targetname" );
//	patrol_boat thread patrol_boat_damage_control();	
//	patrol_boat.health = 2000;
	level thread disable_boats_when_group_cleared( "first_wave_recapture_pbr", 4 );
	patrol_boat thread spawn_guys_on_landing( "patrol_boat_spawner" );
	
	// t5_veh_boat_nvapatrolboat currently (4/8/2010) has no collmap. using a script brush to let guys stand on it
//	clip = GetEnt( "temp_clip_for_patrol_boat", "targetname" );
//	AssertEx( IsDefined( clip ), "clip missing for patrol boat" );
//	clip LinkTo(patrol_boat);
	
	// spawn guys
	guys = simple_spawn( "suppression_patrol_boat_guys" );
	
	// attach one guy to turret in script through spawn function, other guy just fires	
	if( IsDefined( guys[ 0 ] ) )
	{
		gunner1 = guys[0];
		gunner1 thread maps\river_util::patrol_boat_gunner( patrol_boat, 1 );
	}
	if( IsDefined( guys[ 1 ] ) )
	{
		gunner2 = guys[1];
		gunner2 thread maps\river_util::patrol_boat_gunner( patrol_boat, 2 );
	}
	
	// patrol_boat go_path
	patrol_boat_rail = GetVehicleNode( "patrol_boat_suppression_rail_start", "targetname" );
	AssertEx( IsDefined( patrol_boat_rail ), "patrol_boat_rail is missing" );
	patrol_boat thread go_path( patrol_boat_rail );
		
	// patrol boat fires on squad - change _vehicle_turret_ai for this
//	IPrintLnBold( "NVA patrol boat fires at squad on the ground. Player must kill boat's crew" );
	
	while( (patrol_boat maps\_vehicle::is_corpse() == false )  )
	{
		wait( 1 );
	}
	
	if( patrol_boat maps\_vehicle::is_corpse() == false )
	{
		patrol_boat maps\_vehicle_turret_ai::disable_turret( 0 );
		patrol_boat maps\_vehicle_turret_ai::disable_turret( 1 );
	}
	
	flag_set( "patrol_boat_dead" );
	// wait until boat guys are dead
	Spawn_manager_disable( "patrol_boat_spawner" );  // turn off spawn manager since guys can no longer come from the boat
	
	
	// sequence ends
}

disable_boats_when_group_cleared( script_aigroup_name, optional_count)
{
	level endon( "patrol_boat_destroyed" );
	level endon( "patrol_boat_disabled" );
	
	AssertEx( IsDefined( script_aigroup_name ), "script_aigroup_name is missing" );
	
	flag_wait( "patrol_boat_landed" );
	
	if( IsDefined( optional_count ) )
	{
		waittill_ai_group_ai_count( script_aigroup_name, optional_count );
		flag_set( "patrol_boat_disabled" );
	}
	else
	{
		waittill_ai_group_cleared( script_aigroup_name );
		flag_set( "patrol_boat_disabled" );
	}
}

patrol_boat_damage_control()
{
	self.takedamage = false;
	
	self waittill_either( "reached_end_node", "near_goal" );
	
	self.takedamage = true;
}

spawn_guys_on_landing( spawner_name )  // self = vehicle that's landing
{
	self waittill( "reached_end_node" );
	flag_set( "patrol_boat_arrives" );
	
	Spawn_manager_enable( spawner_name );
}

boatjacking()
{
	flag_wait( "sniper_support_done" );
	flag_wait_either( "patrol_boat_dead", "patrol_boat_disabled" );
	flag_wait( "west_shore_sampans_landed" );
	
	flag_set( "boatjack_started" );
	
	autosave_by_name( "river_boatjacking" );
	
//	level thread add_dialogue_line( "Woods", "What the hell? That's our PBR! Kill those assholes!" );
	
	// spawn guy on boat, attach to drive position
	boatjack_rail = GetVehicleNode( "boatjack_rail_start", "targetname" );
	AssertEx( IsDefined( boatjack_rail ), "boatjack_rail missing" );
	
	// animate guy (use utility function)
	boatjacker = simple_spawn( "boatjacker" );
//	boatjacker thread maps\river_util::put_actor_in_drivers_seat( level.boat );
	boatjacker[0] LinkTo( level.boat, "tag_driver", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	boatjacker[0].health = 50;
	boatjacker[0] set_ignoreall( true );
//	boatjacker[0].takedamage = false;
	boatjacker[1] LinkTo( level.boat, "tag_gunner_turret1", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	boatjacker[1].health = 50;
	boatjacker[1] set_ignoreall( true );
		
	// move boat along rail
	level.boat thread go_path( boatjack_rail );
	level.boat thread boatjacking_landing_check();	
	//level.boat maps\_vehicle_turret_ai::enable_turret( 0, "mg", "allies" );
	level.boat thread maps\river_util::patrol_boat_fires_guns(0, false, get_players()[0], undefined, undefined, "boatjack_done" );
	
	while( IsAlive( boatjacker[ 1 ] ) )
	{
		wait( 0.5 );
	}
	
	level.boat notify( "turn_off_guns" );
	
	// player kills driver before he can get away (driver = "boatjacker" )
//	level.boat waittill_either( "reached_end_node", "near_goal" );
//	boatjacker[0].takedamage = true;
	
	waittill_ai_group_cleared( "boatjackers" );
	flag_set( "boatjack_done" );
//	level thread add_dialogue_line( "Woods", "Nice shooting, Mason! We're almost back at the boat, just a little longer!" );
	level.boat SetSpeedImmediate( 10, 15, 15 );
	
	// fail on trigger hit ("boatjacking_fail_trigger"
	fail_trigger = GetEnt( "boatjacking_fail_trigger", "targetname" );
	AssertEx( IsDefined( fail_trigger ), "fail_trigger missing for boatjacking section" );
	fail_trigger Delete();	
}

// fail the player if the boat gets away
boatjacking_landing_check()
{
	level endon( "boatjack_done" );
	level endon( "boatjackers_on_shore" );
	
	self waittill_either( "reached_end_node", "near_goal" );

	flag_set( "boatjackers_on_shore" );	
}

monitor_threat_sniper_threat_bias()
{
	offset = 10000;  // what to subtract from threat bias as each guy is killed
	max_threat = GetThreatBias( "recapture_pbr_enemies", "player" );
	min_threshold = GetThreatBias("recapture_pbr_enemies", "friendly_squad" );
	SetThreatBias( "recapture_pbr_enemies", "player", min_threshold );	
	
	if( !IsDefined( level.recapture_pbr_enemies_killed ) )
	{
		level.recapture_pbr_enemies_killed = 0;
	}
	
	while( flag( "sniper_support_done" ) == false )
	{
		old_value = level.recapture_pbr_enemies_killed;
		
		wait( 2 );
		
		new_value = level.recapture_pbr_enemies_killed;
		
		if( new_value != old_value )
		{
			bias_change = level.recapture_pbr_enemies_killed * offset;
			new_threat = max_threat - offset;
			
			if( new_threat < min_threshold )
			{
				break;
			}
			else
			{
				SetThreatBias( "recapture_pbr_enemies", "friendly_squad", new_threat );	
			}
		}
	}
}


// move friendlies to correct position before event starts
plane_nose_section_friendlies_start()
{
	squad = [];
	squad = array_add( squad, level.bowman );
	squad = array_add( squad, level.woods );
	
	nodes = GetNodeArray( "C5_approach_walk_under_C5", "targetname" );
	AssertEx( IsDefined( nodes ), "nodes are missing" );
	AssertEx( ( nodes.size >= squad.size ), "need more nodes than guys" );
	
	for( i = 0; i < squad.size; i++ )
	{
		squad[i] Teleport( nodes[i].origin, nodes[i].angles );
	}
}

fire_at_friendly_pbr()
{
	self endon( "death" );
	
	boat_target = level.boat;
	
	level.friendly_boats = remove_dead_from_array( level.friendly_boats );
	
	for(i = 0; i < level.friendly_boats.size; i++ )
	{
		if( level.friendly_boats[i] maps\_vehicle::is_corpse() == false )
		{
			if(level.friendly_boats[i].script_int == 1)
			{
				boat_target = level.friendly_boats[i];
			}
		}

	}	
	
	AssertEx( IsDefined( boat_target ), "boat_target missing for fire_at_friendly_pbr" );
	
	self shoot_at_target( boat_target );
}

// sampans arrive during "discovery" of player
sampans_go_into_alcove_and_kill_friendlies()
{
//	flag_wait( "patrol_boat_landed" );
	
	maps\_vehicle::create_vehicle_from_spawngroup_and_gopath( 24 );	 // sampans

	wait( 0.1 );
	
	sampan = GetEnt( "recapture_pbr_sampan_west", "targetname" );
	AssertEx( IsDefined( sampan ), "sampan missing for sampans_go_into_alcove_and_kill_friendlies" );
	sampan waittill_either( "reached_end_node", "near_goal" );
	
	C5_spawner_trigger = GetEnt( "player_in_C5_nose", "targetname" );
	AssertEx( IsDefined( C5_spawner_trigger ), "C5_spawner_trigger is missing" );
//	C5_spawner_trigger trigger_on();
//	spawn_manager_enable("player_in_C5_nose");		
	
//	level thread add_dialogue_line( "Redshirt", "Woods, Bowman! We're being overrun! There's fucking NVA everywhere!" );
	
	level.friendly_boats = remove_dead_from_array( level.friendly_boats );
	
	for(i = 0; i < level.friendly_boats.size; i++ )
	{
			
		if( level.friendly_boats[i] maps\_vehicle::is_corpse() == false )
		{
			if(level.friendly_boats[i].script_int == 1)
			{
				PlayFX( level._effect["friendly_boat_death_alcove"], level.friendly_boats[i].origin );
				PlayFX( level._effect["chinook_smoke"], level.friendly_boats[i].origin );
				level.friendly_boats[i] Delete();
			}
		}
	}
	
	boat_crew = GetEntArray( "friendly_pbr_crew_2_ai", "targetname" );
	//AssertEx( ( boat_crew.size > 0 ), "boat_crew missing for deletion" );  // don't assert - they could be dead already
	
	array_thread( boat_crew, maps\river_util::kill_me );
	
	wait( 2 );
	
//	level thread add_dialogue_line( "Bowman", "Shit, I think we just lost a boat!" );
	
	wait( 1 );
	
//	level thread add_dialogue_line( "Woods", "Mason, we need to get back to the boat! Cover us from the nose of that plane!" );
	
	setup_squad_movement_dialogue();	
	
	wait( 7 );	
	
	squad = [];
	squad = array_add( squad, level.bowman );
	squad = array_add( squad, level.woods );	
	
	squad thread maps\river_util::squad_moves_to_next_safe_point("sniper_support_cover_positions_", "sniper_support_done", "sniper_support_ground_moveup");
}

// make a mad dash back to the boat and start event 3
run_to_boat() // beat 6
{
	autosave_by_name( "river_run_to_boat" );
	
	reposition_node = GetVehicleNode( "getaway_rail_start_node", "targetname" );
	AssertEx( IsDefined( reposition_node ), "reposition_node missing for run_to_boat" );
	level.boat.origin = reposition_node.origin;
	//level.boat MakeVehicleUsable();
	
//	level thread add_dialogue_line( "Woods", "Get to the boat! MOVE MOVE MOVE!" );
	
	flag_wait( "boatjack_done" );
	
//	level thread maps\river_util::kill_player_outside_volume( "run_to_boat_volume",  "run_to_boat_done" );
	
	// volume = "run_to_boat_volume"; magic bullet outside it
//	maps\river_util::wait_for_player_to_use_boat();

//	trigger = GetEnt("squad_back_to_boat_trigger", "targetname" );
//	AssertEx( IsDefined( trigger ), "trigger for run_to_boat is missing" );
//	trigger waittill( "trigger" );

	wait_for_player_to_get_close_to_boat();
	
	enemies = GetAIArray( "axis" );  // no error check on size in case player killed them all
	array_thread( enemies, maps\river_util::kill_me );
	
	flag_set( "run_to_boat_done" );
}

wait_for_player_to_get_close_to_boat()
{
	while( Distance( level.boat.origin, get_players()[0].origin ) > 850 )
	{
		wait( 0.5 );
	}
	
	bow_gun_origin = level.boat GetTagOrigin( "tag_gunner_turret1" );
	bow_gun_angles = level.boat GetTagAngles( "tag_gunner_turret1" );
	
	player = get_players()[0];
	origin = Spawn( "script_origin", player.origin );
	player LinkTo( origin );
	player SetPlayerAngles( bow_gun_angles );
	origin moveto( bow_gun_origin + ( 0, 0, 50 ), 2.5 );
	origin waittill( "movedone" );
	player = get_players()[0];
	player Unlink();
	origin Delete();
}

jungle_approach()
{
//
//	/#
//		level thread update_billboard("E2 B1: jungle_approach", "ambush", "TEMP: 30-45 seconds", "roughout");
//		level thread maps\river_util::event_timer("jungle_approach", "jungle_approach_done");	
//	#/
	
	maps\river_util::let_player_leave_boat();
	flag_clear("display_boat_hp");  // stop displaying boat health
	
	level thread friendly_squad_gets_off_boat();
	
	
	sniper_foreshadowing();
	
	squad_takes_cover_from_sniper();
	
	player_throws_nightingale_distraction();
	
	rendezvous_with_pilots();
}




squad_takes_cover_from_sniper()
{
	bowman_cover = GetNode("sniper_cover_bowman", "targetname");
	reznov_cover = GetNode("sniper_cover_reznov", "targetname");
	woods_cover = GetNode("sniper_cover_woods", "targetname");
	
	level.bowman SetGoalNode(bowman_cover);
	level.bowman set_pacifist(true);
	level.reznov SetGoalNode(reznov_cover);
	level.woods SetGoalNode(woods_cover);
	level.woods waittill("goal");
	
//	add_dialogue_line("Woods", "Shit, there's a sniper by the C5. We need to keep our heads down and get out of the open.");
//	add_dialogue_line("Reznov", "Move into the jungle, comrade. You will be safe until we can flush the sniper.");
	//IPrintLnBold("player takes cover to avoid the sniper");
}

player_throws_nightingale_distraction()
{
//	bowman_cover = GetNode("stream_cover_bowman", "targetname");
	woods_cover = GetNode("stream_cover_woods", "targetname");
	reznov_cover = GetNode("stream_cover_reznov", "targetname");
//	level.bowman SetGoalNode(bowman_cover);
	level.reznov SetGoalNode(reznov_cover);
	level.woods SetGoalNode(woods_cover);
//	level.woods waittill("goal");
	
//	add_dialogue_line("Woods", "Mason, create a distraction so we can buy the pilot some time.");
	
//	IPrintLnBold("player throws grenades or Nightingale over the hill to create a distraction");
	
//	add_dialogue_line("Woods", "Alright, lets move up quickly");
	
	for(i=0; i<level.friendly_squad.size; i++)
	{
		level.friendly_squad[i] enable_cqbwalk();
	}
}

hillside_encounter()
{
//	initial_spawn_trigger = GetEnt("jungle_hillside_guys_1_trigger", "targetname");
//	AssertEx(IsDefined(initial_spawn_trigger), "initial_spawn_trigger is missing in hillside_encounter");
//	simple_spawn("first_hill_wave_guys");
	
	level thread rusher_threatbias_check();
	
//	end_trigger = GetEnt("sniper_duel_begins_trigger", "targetname");
//	AssertEx(IsDefined(end_trigger), "end_trigger for hillside encounter is missing");
//	end_trigger waittill("trigger");
//	IPrintLnBold("plane_approach");
}

hillside_guys_behavior()
{
	self endon("death");
	
	self SetThreatBiasGroup("axis");
	
	if( self.classname == "actor_NVA_e_Dragunov" )  // these guys hit very hard, so lower their accuracy
	{
		self.script_accuracy = 0.85;
	}
	
	self.goalradius = 64;
		
	if(IsDefined(self.target))
	{	
		goal = GetNodeArray(self.target, "targetname");
		AssertEx((goal.size > 0), "goals for hillside_guys_behavior are missing");
		self SetGoalNode(random(goal));	
		
	}	
	
	if( IsDefined( self.script_string ) && ( self.script_string == "rusher" ) )
	{
		self thread rush();
		wait( 0.25 );
		self.health = 150;
		return;
	}
	
	x = RandomInt(3);
	
//	if(x == 0)
//	{
//		self waittill("goal");
//		while(IsAlive(self))
//		{
//			buddy = get_closest_ai(self.origin, "axis");
//			if(DistanceSquared(self.origin, buddy.origin) < 22500)  // 150 squared
//			{
//				self thread rusher_setup();
//				break;
//			}
//			else
//			{
//				wait(2);
//			}
//			
//		}
//	}
//	if( x == 1)
//	{
//		while(IsAlive(self))
//		{
//			player = get_players()[0];
//			if(DistanceSquared(self.origin, player.origin) < 160000)  // 400 squared
//			{
//				PrintLn("rush started");
//				self thread rusher_setup();
//				break;
//			}
//			else
//			{
//				wait(1);
//			}
//		}

//		wait( RandomInt( 2, 6 ) );
//		self rush();
//	}
}

chinook_pilot_behavior()
{
	self.takedamage = false;
	self set_pacifist(true);
}

NVA_go_to_target()
{
	self set_pacifist(true);
	self.goalradius = 20;
	
	if(IsDefined(self.target))
	{
		goal = GetNode(self.target, "targetname");
		self SetGoalNode(goal);
		self waittill("goal");
	}
	
	self set_pacifist(false);
}

friendly_squad_gets_off_boat()
{
	// TODO: make player have to be in a specific "docking" location to enable AI getting off boat
//	player = get_players()[0];
//	while(player isinvehicle() == true)
//	{
//		wait(0.1);
//		player = get_players()[0];
//	}
	
	level.woods disable_heat();
	level.bowman disable_heat();
	level.woods disable_cqbwalk();
	level.bowman disable_cqbwalk();
	
	level.woods maps\river_util::look_foward_on_boat_single( );
	
	//wait( 1 );

//	IPrintLnBold( "friendly squad deboarding" );

	// make sure animnames are set up, even though they should be already
	level.reznov.animname = "reznov";
	level.woods.animname = "woods";
	level.bowman.animname = "bowman";
		
	level.boat thread anim_single_aligned( level.reznov, "boat_landing", "tag_passenger12" );
//	level.boat thread anim_single_aligned( level.woods, "boat_landing", "tag_passenger10" );
	level.boat thread anim_single_aligned( level.bowman, "boat_landing", "tag_gunner3" );	// tag_origin = non-turret, tag_origin = turret
	level.woods maps\river_drive::anim_single_then_flag( level.boat, "boat_landing", "tag_passenger10" );
	
	//wait( 2 );
	
//	level.bowman Unlink();  // bowman turret exit DOES NOT HAVE NOTETRACK YET!
	// unlinks happen in notetrack now - check river_anim.gsc
}

/*===========================================================================
make a shot ring out from the C5 galaxy crash site that warns the player of 
the presence of a sniper; read assisted with bird takeoff effect
===========================================================================*/
sniper_foreshadowing()
{
	squad_on_land_trigger = GetEnt("squad_on_land_trigger", "targetname");
	NPCs_ready = 0;
	
	while(NPCs_ready != level.friendly_squad.size)
	{
		NPCs_ready = 0;
		
		for(i=0; i<level.friendly_squad.size; i++)
		{
			if(level.friendly_squad[i] IsTouching(squad_on_land_trigger))
			{
				NPCs_ready++;
			}
		}
		wait(0.1);
	}
	
	wait(2);
	
	sniper_fired_struct = getstruct("sniper_foreshadow_shot_struct", "targetname");
	AssertEx(IsDefined(sniper_fired_struct), "sniper_fired_struct is missing in sniper_foreshadowing in jungle_approach beat");
	sniper_hit_struct = getstruct("sniper_foreshadow_impact_struct", "targetname");
	AssertEx(IsDefined(sniper_hit_struct), "sniper_hit_struct is missing in sniper_foreshadowing in jungle_approach beat");
	bird_takeoff_struct = getstruct("sniper_foreshadow_pidgeon_struct", "targetname");
	AssertEx(IsDefined(bird_takeoff_struct), "bird_takeoff_struct is missing in sniper_foreshadowing in jungle_approach beat");
	
	MagicBullet("dragunov_sp", sniper_fired_struct.origin, sniper_hit_struct.origin);
	PlayFX(level._effect["temp_pidgeon_takeoff"], bird_takeoff_struct.origin);
	
	//IPrintLnBold("sniper fire rings out from C5's location");
//	add_dialogue_line("bowman", "SNIPER!");	
	flag_set("sniper_foreshadowing_done");
}

rendezvous_with_pilots()
{
	wounded_man_begins_trigger = GetEnt("wounded_man_begins_trigger", "targetname");
	AssertEx(IsDefined(wounded_man_begins_trigger), "wounded_man start trigger is missing");
	wounded_man_begins_trigger waittill("trigger");
	

	
//	NVA_attackers = GetEntArray("NVA_chinook_spawners_ai", "targetname");
//	
//	while(NVA_attackers.size > 0)
//	{
//		wait(1);
//		NVA_attackers = GetEntArray("NVA_chinook_spawners_ai", "targetname");
//	}
	
	flag_wait("chinook_defense_done");
	
	flag_set("jungle_approach_done");
	autosave_by_name("river_jungle_approach");		
}

chinook_defense()
{
	if(!IsDefined(level.chinook_guys_active))
	{
		level.chinook_guys_active = 0;
	}
	
	if(!IsDefined(level.chinook_guys_killed))
	{
		level.chinook_guys_killed = 0;
	}
	
	simple_spawn("NVA_chinook_spawners", ::chinook_NVA_behavior);
	
	while(level.chinook_guys_killed < 15)
	{
		if(level.chinook_guys_active < 4)
		{
			simple_spawn("NVA_chinook_spawners", ::chinook_NVA_behavior);
		}
		else
		{
			wait(1);
		}
	}
	
	flag_set("chinook_defense_done");
	PrintLn("chinook defense done");
}

chinook_NVA_behavior()
{
	if(!IsDefined(level.chinook_guys_active))
	{
		level.chinook_guys_active = 0;	
	}
	
	level.chinook_guys_active++;
	
	self.goalradius = 20;
		
	if(IsDefined(self.target))
	{	
		goal = GetNode(self.target, "targetname");
		self SetGoalNode(goal);	
	}	
	
	self waittill("death");
	
	if(!IsDefined(level.chinook_guys_killed))
	{
		level.chinook_guys_killed = 0;
	}
	
	level.chinook_guys_active--;
	level.chinook_guys_killed++;
}

wounded_man()
{
//	/#
//		level thread update_billboard("E2 B2: wounded_man", "wounded man incubator or vignette", "TEMP: 15-30 seconds", "roughout");
//		level thread maps\river_util::event_timer("wounded_man", "wounded_man_done");
//	#/
	
//	level thread add_dialogue_line("Chinook Pilot", "Thanks for the assist, here's some pivotal plot information and an item so you pay attention to me.");
	wait(4);
	
	pilot = GetEnt("chinook_pilot_ai", "targetname");
	grassy_knoll = getstruct("sniper_foreshadow_shot_struct", "targetname");
	MagicBullet("dragunov_sp", grassy_knoll.origin, pilot.origin);
	
	//IPrintLnBold("sniper shoots pilot. pilot goes down, but he's alive");
	
	//IPrintLnBold("woods and Mason drag pilot to safety behind plane");

	level.reznov clear_force_color();
	level.reznov set_force_color("r");
	level.woods disable_ai_color();
	woods_goal = GetNode("woods_wounded_man_node", "targetname");
	level.woods SetGoalNode(woods_goal);
	
	reznov_goal = getstruct("sniper_duel_start", "targetname");
	level.reznov thread maps\river_util::actor_moveto(reznov_goal);
	
	woods_hides_from_sniper = getstruct("woods_covers_pilot_struct", "targetname");
	level.woods thread maps\river_util::actor_moveto(woods_hides_from_sniper, 3);
	pilot_dragged_here = getstruct("chinook_pilot_wounded_struct", "targetname");
	pilot thread maps\river_util::actor_moveto(pilot_dragged_here, 3);
	
	wait(4);
	
//	add_dialogue_line("Reznov", "Mason! You must kill that sniper! I will help you!");
	
	flag_set("wounded_man_done");
	autosave_by_name("river_wounded_man");
}

//sniper_duel()
//{
//	
//	/#
//		level thread update_billboard("E2 B3: sniper_duel", "kill sniper in C5 Galaxy", "TEMP: 15-30 seconds", "roughout");
//		level thread maps\river_util::event_timer("sniper_duel", "sniper_duel_done");
//	#/	
//	
//	simple_spawn_single("C5_sniper", ::sniper_duel_function);
//	
//	IPrintLnBold("player has to kill sniper here. event ends with his death.");
//
//	flag_wait("sniper_duel_done");
//	autosave_by_name("river_sniper_duel");
//	
//	level.woods enable_ai_color();
//	
//	woods_goal = GetNode("C5_approach_woods", "targetname");
//	level.woods SetGoalNode(woods_goal);
//}


/*==========================================================================
FUNCTION: rappel_guy_counter
SELF: struct or origin that guys will be rappeling from (ONE rope)
PURPOSE: make several guys come out of a single spawner, then make them rappel.
	This was made with helicopters in mind.
SETUP: 	- this is for FIXED RAPPELS ONLY. script struct needs to target another struct
		- script_struct needs unique targetname
		- script_struct needs script_noteworthy for all rappel lines from a point
		- script_struct needs script_string so it knows what spawner to spawn

ADDITIONS NEEDED:
==========================================================================*/
rappel_guy_counter( num_guys_to_rappel )  // self = struct
{
	self._rappel_done = false;
	
	if( !IsDefined( num_guys_to_rappel ) )
	{
		PrintLn( "num_guys_to_rappel is missing in rappel_guy_counter" );
		self._rappel_done = true;
		return;
	}	
	
	if( num_guys_to_rappel <= 0 )
	{
		PrintLn( "rappel_guy_counter passed invalid number for num_guys_to_rappel" );
		self._rappel_done = true;
		return;
	}
	
	if( !IsDefined( self.script_string ) )
	{
		PrintLn( "script_string is required on rappel structs do it knows who to spawn" );
		self._rappel_done = true;
		return;
	}
	
	if( !IsDefined( self._guys_rappeled ) )
	{
		self._guys_rappeled = 0;
	}
	
	while( self._guys_rappeled < num_guys_to_rappel )
	{
		//IPrintLnBold( "spawning guy for " + self.targetname );
		// spawn guy
		guy = simple_spawn_single( self.script_string );  // rappel_guy function should be on him already
		
		if( num_guys_to_rappel == 1 )  // solo rappel - create and cut rope
		{
			guy maps\_ai_rappel::start_ai_rappel( undefined, self, true, true );
		}
		else
		{
			// make him rappel
			if( self._guys_rappeled == 0 )  
			{
				guy maps\_ai_rappel::start_ai_rappel( undefined, self, true, false ); // create rope since he's the first guy to come out
			}
			else if( self._guys_rappeled == ( num_guys_to_rappel - 1 ) )  // minus one because this increments after rappel is done
			{
				guy maps\_ai_rappel::start_ai_rappel( undefined, self, false, true ); // end rope
			}
			else  
			{
				guy maps\_ai_rappel::start_ai_rappel( undefined, self, false, false ); // don't create or end rope since they're middle guys
			}
		}
		
		self._guys_rappeled++;		
		
		wait( RandomFloatRange( 1, 2 ) );	
	}
	
	//IPrintLnBold( "all rappelling done from " + self.targetname );
	self._rappel_done = true;
}

rappel_guy_function( node_array_name )
{
	self endon( "death" );
	
	self go_to_unoccupied_node( node_array_name );	
}

/*==========================================================================
FUNCTION: helicopter_drops_off_troops
SELF: helicopter
PURPOSE: drop off some guys via rappel when helicopter getss "rappel_dropoff" notify.
	All information regarding the number of guys to spawn per struct or the housekeeping
	of those guys is handled in the rappel_guy_counter function

ADDITIONS NEEDED:
==========================================================================*/
helicopter_drops_off_troops( struct_array_noteworthy, guys_per_rappel_line )
{
	if( !IsDefined( struct_array_noteworthy ) )
	{
		PrintLn( "struct_array_noteworthy is missing for " + self.targetname );
		return;
	}
	
	if( !IsDefined( guys_per_rappel_line ) )
	{
		guys_per_rappel_line = 2;  // default
	}	
	
	self waittill( "rappel_dropoff" );
	
	self SetSpeedImmediate( 0 );
	
	PrintLn(self.targetname + " is dropping off rappelling guys");
	
	rappel_structs = getstructarray( struct_array_noteworthy, "script_noteworthy" );
	if( rappel_structs.size == 0 )
	{
		PrintLn( "rappel_structs are MISSING for rappel dropoff on " + self.targetname );
	}
	else
	{
		for( i = 0; i < rappel_structs.size; i++ )
		{
			rappel_structs[ i ] thread rappel_guy_counter( guys_per_rappel_line );
		}
	}
	
	// wait until all rappelling is done 
	while( true ) 
	{
		rappels_finished = 0;
		
		for( i = 0; i < rappel_structs.size; i++ )
		{
			if( rappel_structs[ i ]._rappel_done == true )
			{
				rappels_finished++;
			}
		}
		
		if( rappels_finished == rappel_structs.size )
		{
			break;
		}
		
		wait( 1 );
	}
	
	PrintLn(self.targetname + " is DONE dropping off rappelling guys");

	//wait( 2 );  // make sure rappel guys are down, then leave
	
	self ResumeSpeed(20);	
}

//helicopter_drops_off_troops_old(spawner_name, condition, wait_for_noteworthy, trigger_name )  // self = heli_hip
//{	
//	AssertEx(IsDefined(spawner_name), "spawner_name must be defined for helicopter_drops_off_troops");
//	
//	if(!IsDefined(condition))
//	{
//		condition = "reached_end_node";
//		IPrintLnBold(self.targetname + " is missing a final dropoff condition. FIX THIS");
//	}
//	
//	if(IsDefined(wait_for_noteworthy))
//	{
//		self waittill(wait_for_noteworthy);
//		maps\river_util::Print_debug_message( self.targetname + " is waiting", true );
//		self SetSpeedImmediate( 0 );
//		
//		if(IsDefined(trigger_name))
//		{
//			trigger = GetEnt(trigger_name, "targetname");
//			AssertEx(IsDefined(trigger), "trigger for helicopter_drops_off_troops is missing");
//			trigger waittill("trigger");
//			self ResumeSpeed(20);
//		}
//		else
//		{
//			IPrintLnBold(self.targetname + " won't move again until trigger_name is defined");	
//		}
//		
//	}
//	
//	// throw smoke screen for cover
////	grenade_velocity = (AnglesToUp(self.angles)) * (-1);  // get vector pointing down from helicopter origin
//	
//	rappel_guys = GetEntArray(spawner_name, "targetname");
//	AssertEx((rappel_guys.size > 0), "rappel_guys missing for " + self.targetname);
//	for(i=0; i<rappel_guys.size; i++)
//	{
//		rappel_guys[i] add_spawn_function(::rappel_guy_function);
//	}
//	
//	self waittill(condition);
//	self SetSpeedImmediate(0); // stop for dropoff
//	
////	self MagicGrenadeType("m8_white_smoke_sp", self.origin + (0, 0, -50), grenade_velocity);	
//	wait(2);
//	
//	PrintLn(self.targetname + " is dropping off rappelling guys");
//	rappel_structs = getstructarray( struct_array_name );
//	if( rappel_structs.size == 0 )
//	{
//		PrintLn( "rappel_structs are MISSING for rappel dropoff on " + self.targetname );
//	}
//	else
//	{
//		for( i = 0; i < rappel_structs.size; i++ )
//		{
//			rappel_structs thread rappel_guy_counter( spawner_name, 3 );
//		}
//	}
//	
//	// wait until all rappelling is done 
//	while( true ) 
//	{
//		rappels_finished = 0;
//		
//		for( i = 0; i < rappel_structs.size; i++ )
//		{
//			if( rappel_structs[ i ]._rappel_done == true )
//			{
//				rappels_finished++;
//			}
//		}
//		
//		if( rappels_finished == rappel_structs.size )
//		{
//			break;
//		}
//		
//		wait( 1 );
//	}
//
//	wait( 2 );  // make sure rappel guys are down, then leave
//	
//	self ResumeSpeed(20);
//}

pick_up_nova6()  // self = helicopter that's picking up nova6 off the ground
{
	self endon( "death" );

	self waittill("pickup_nova6");
	PrintLn(self.targetname + " is waiting");
	self SetSpeedImmediate(0);
	self SetHoverParams( 0, 0, 0 );
	
	self Hind_attach_crate();
	
	self SetHoverParams( 20, 1, 0.5 );
	
	takeoff_trigger = GetEnt("spetznaz_on_hill_engagement_trigger", "targetname");  // old = hind_takeoff_trigger. too far away.
	AssertEx(IsDefined(takeoff_trigger), "takeoff_trigger is undefined in pick_up_nova6 function");
	takeoff_trigger waittill("trigger");
	
	wait( 2 );
	
	//IPrintLnBold("helicopters pick up nova6 containers and leave");
	self ResumeSpeed(20);
	
//	crate PhysicsLaunch( crate.origin, crate.origin - ( 50, 0, 0 ) );
	
	// HINDS FLY OFF VO
	if( !isdefined(level.nova6_vo) )
	{
		level.nova6_vo = 1;
		
		level thread ruins_hind_extra_dialogue();
	}
}


ruins_hind_extra_dialogue()
{
	level endon( "player_at_wing" );
	
	level.woods maps\river_vo::playVO_proper( "dont_give_up_the_hinds", 0 );
	//level.bowman maps\river_vo::playVO_proper( "charlies_retreating", 0.5 );
	//level.woods maps\river_vo::playVO_proper( "hell_be_back", 0.5 );
		
	// wait until spetsnaz group cleared 
	waittill_ai_group_cleared( "plane_spetsnaz" );
	
	level.woods maps\river_vo::playVO_proper( "thats_the_last_of_them_spetznaz", 0 );	
	level.woods maps\river_vo::playVO_proper( "thats_why_the_hinds", 0.5 );
	level.mason maps\river_vo::playVO_proper( "it_must_have_been_nova_6", 0.75 );	
	
	flag_set( "player_at_wing" );
}


rusher_setup()  // self = AI
{
	if(!IsDefined(level.rushers_active))
	{
		level.rushers_active = 0;
	}
	
	self rush();
	
	level.rushers_active++;
	
	self waittill("death");
	
	level.rushers_active--;
}

rusher_threatbias_check()
{
	if(!IsDefined(level.rushers_active))
	{
		level.rushers_active = 0;
	}	
	
	while(flag("hillside_encounter_done") == false)
	{
		if(level.rushers_active > 0)
		{
			old_bias = GetThreatBias("axis", "friendly_squad");
			SetThreatBias("axis", "friendly_squad", 999999);
			while(level.rushers_active > 0)
			{
				//IPrintLnBold( level.rushers_active + " rushers active");
				wait(2);
			}
			
			SetThreatBias("axis", "friendly_squad", old_bias);
		}
		else
		{
			// do nothing for now
		}
		
		wait(2);	
	}
}

setup_squad_movement_dialogue()
{
	level._temp_dialogue_lines["sniper_support_ground_moveup"] = [];
	level._temp_dialogue_lines["sniper_support_ground_moveup"][0] = "Mason, give us covering fire!";
	level._temp_dialogue_lines["sniper_support_ground_moveup"][1] = "Bowman, move up!";
	level._temp_dialogue_lines["sniper_support_ground_moveup"][2] = "We're doing good Mason, keep up the support fire!";
	level._temp_dialogue_lines["sniper_support_ground_moveup"][3] = "Moving up now.";
	level._temp_dialogue_lines["sniper_support_ground_moveup"][4] = "Move up!";
	level._temp_dialogue_lines["sniper_support_ground_moveup"][5] = "Get to the boat!";
}

/*==========================================================================
FUNCTION: vehicle_unload_single
SELF: vehicle with guys in it
PURPOSE: take a single guy out a vehicle instead of all of them at once
NOTES: if seat_num is defined, it's prioritized over guy since it's less expensive 
	- the vehicle has several arrays on it to keep track of its passengers.
	.riders[] holds the array of AI currently on the vehicle
	.usedpositions[] holds the array of seats, 1 = occupied, 0 = unoccupied
	

ADDITIONS NEEDED: find a more efficient way of checking for guys in seats
==========================================================================*/
vehicle_unload_single( guy, seat_num )  // self = vehicle
{
	// need guy
	if( !IsDefined( guy ) && !IsDefined( seat_num ) ) 
	{
		PrintLn( "can't vehicle_unload_single without knowing who to unload. returning." );
		return;
	}
	
	// make sure self is a vehicle
	if( !IsDefined( self.vehicletype ) )
	{
		PrintLn( "vehicle_unload_single was not passed on a vehicle. returning." );
		return;
	}
	
	if( IsDefined( seat_num ) )  // passed seat number, make sure there's a guy in the seat, then unload him
	{
		if( ( self.usedpositions.size < seat_num ) || ( seat_num < 0 ) )  // .usedpositions is an array of binary numbers. 1 = occupied, 0 = unoccupied.
		{
			PrintLn( "invalid seat_num passed to vehicle_unload_single. returning." );
			return;
		}
		
		if( self.usedpositions[ seat_num ] == 1 )
		{
			self maps\_vehicle_aianim::guy_unload( self.riders[ seat_num ], seat_num );
		}
		else
		{
			PrintLn( "vehicle_unload_single couldn't find a guy in seat " + seat_num );
			return;
		}
	}
	else  // passed a guy. make sure he's in the vehicle, then unload him
	{
		// make sure there are guys on the vehicle to unload
		if( !IsDefined( self.riders ) || ( self.riders.size == 0 ) )
		{
			PrintLn( "no guys attached. can't vehicle_unload_single. returning." );
			return;
		}
		
		seat_num = -1;  // reserved number for error check
		
		// need to find the seat the guy is in
		for( i = 0; i < self.riders.size; i++ )
		{
			if( guy == self.riders[ i ] )
			{
				seat_num = i; 
				break;
			}
		}
		
		if( seat_num == -1 )
		{
			PrintLn( "vehicle_unload_single couldn't find " + guy.targetname + " in the vehicle" );
			return;
		}
		
		self maps\_vehicle_aianim::guy_unload( guy, seat_num );	
	}
}
