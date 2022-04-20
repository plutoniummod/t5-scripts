/*	
	BASIC BEAT FLOW:

*/

#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;
#include maps\creek_1_util;
#include maps\_music;
#include maps\_civilians;
#include maps\_civilians_anim;

main()
{

//-----------------------------------------------------------------------------------
// GENERAL SETUP 

	flag_set( "beat_3_starts" );
	level maps\_swimming::set_default_vision_set( "creek_1" );
	level maps\_swimming::set_swimming_vision_set( "creek_1_water" );
	
	level.hudson show();
	
	//level thread player_hurt_fire();
	
	//SetAILimit( 26 );
	
	// Alex: Critters will now be setup in beat 2. This is kept here for skipto purpose only.
	if( isdefined( level.skipped_to_event_3 ) && level.skipped_to_event_3 == true )
	{
		level thread village_livestock_setup();
		
		// take away player weapons
		player = get_players()[0];
		player take_player_weapons();
		player GiveWeapon( "knife_sp", 0 );
	}
	
	/*
	// temp, lets get rid of these covers
	covers = getentarray( "aa_island_cover", "targetname" );
	for( i = 0; i < covers.size; i++ )
	{
		covers[i] delete();
	}
	*/
	
	level.section = "continue";
	
	level thread beat_3_objectives();
	
	level thread give_player_lots_of_m202_ammo();
	
	//level thread hide_and_show_additional_rockets();
	
	// WWILLIAMS: village functions
	level thread beat_2_and_3_functions();
	
	// WWILLIAMS: temp ignore reznov
	level.reznov.ignoreme = 1;
	
	level.hudson.animname = "hudson";
	
	// stealth behavior in the beginning
	village_stealth();
	
//-----------------------------------------------------------------------------------
	// -- End the main function
	flag_wait( "demo_line_6_clear" );
	battlechatter_off();
	wait( 0.05 );

	// WWILLIAMS: Call the next main
	level thread maps\creek_1_tunnel::main();
}

player_hurt_fire()
{
	level endon( "demo_line_6_clear" );
	
	fire_hurt_structs = getstructarray( "fire_hurt", "targetname" );
	player = get_players()[0];
	while( 1 )
	{
		for( i = 0; i < fire_hurt_structs[i].size; i++ )
		{
			distance_to = distance2dsquared( fire_hurt_structs[i].origin, player.origin );
			if( distance_to < 900 )
			{
				RadiusDamage( fire_hurt_structs[i].origin, 30, 15, 5 );
			}
		}
		wait( 0.4 );
	}	
}

give_player_lots_of_m202_ammo()
{
	level endon( "demo_line_6_clear" );
	player = get_players()[0];
	while( 1 )
	{
		weapon = player GetCurrentWeapon();
		
		if( weapon == "m202_flash_magic_bullet_sp" )
		{
			player SetWeaponAmmoClip( weapon, 4 );
			player GiveMaxAmmo( weapon );
			return;
		}
		wait( 0.05 );
	}
}

// WWILLIAMS: Runs all the new functions for creek's village area
beat_2_and_3_functions()
{
	level thread wait_for_player_to_exit_first_hut();
	
	// -- General Setup -----------------------------------------------------------------//
	// -- WWILLIAMS: Civilians in the village
	level thread beat_3_civilian_init();
	// -- WWILLIAMS: Setup the two different roof doors into level vars for other functions
	level thread beat_3_roof_door_init();
	// -- WWILLIAMS: sampan that lands on the shore
	level thread beat_3_sampan_init();
	// opens hatch for ratholes
	level thread beat_3_rathole_hatch_opens();
	// rathole closing by grenade
	level thread beat_3_rathole_grenade_close( "rattunnel_1_explosion_damage", "rathole_manager_line_3", 
																						 "rathole_1st_fx", "rat_hole_1_started" );
	level thread beat_3_rathole_grenade_close( "rattunnel_2_explosion_damage", "rathole_manager_line_5", 
																						 "trigger_hut_rathole_entrance", "demo_line_4_clear" );
	//-----------------------------------------------------------------------------------//
	
	// push the squad forward
	// This is the main progression/objective thread for this event
	level thread beat_3_push_foward();
	
	// -- Ambush a.k.a. First Line ------------------------------------------------------------------------//
	// -- WWILLIAMS: moves the squad to ambush position
	level thread beat_3_village_redshirts();
	level thread beat_3_into_ambush_position();
	level thread beat_3_vc_intro();
	// The logic handling for succeeding/failing stealth
	level thread beat_3_give_player_plunger();
	level thread village_stealth();
	// -- WWILLIAMS: Controls the distraction hut states
	level thread beat_3_distraction_hut_destruction();
	// -- WWILLIAMS: guy jumps through the window on the left when at the catwalk
	level thread beat_3_vc_jump_out_window_init();
	// -- WWILLIAMS: vc shoots through a window after the ambush starts
	level thread beat_3_window_shooter();
	// -- WWILLIAMS: RPG roof attacker, to the left after stealth is broken
	level thread beat_3_roof_rpg_vc();
	// -- WWILLIAMS: Keep line somewhat busy until the player moves up
	level thread beat_3_keep_line_1_busy();

	// -- Second Line --------------------------------------------------------------------//
	// -- WWILLIAMS: controls the backup leader of the interior
	level thread beat_3_reinforcement_leader();
	// -- WWILLIAMS: starts the backup slider
	level thread beat_3_backup_slider_init();
	// -- WWILLIAMS: starts the parkour
	level thread beat_3_backup_parkour();
	// -- WWILLIAMS: starts the hurdler that becomes a rusher
	level thread beat_3_backup_hurdle_rusher();
	// aa gun
	//level thread village_aa_gun_guards();
	level thread village_aa_gun();
	//-----------------------------------------------------------------------------------//
	
	// -- Third Line --------------------------------------------------------------------//
	// rathole 1
	level thread beat_3_vc_rathole_1();
	// -- WWILLIAMS: starts the vc that fire from on the ridge
	//level thread beat_3_ridge_vc_line_3();
	// -- WWILLIAMS: starts the vc that slides down the ridge into the village
	level thread beat_3_backup_ridge_slider_init();
	// -- WWILLIAMS: vc on top of ridge hut has special death animation
	level thread beat_3_ridge_roof_roller();
	// -- WWILLIAMS: spawns out the vc that shoots out the window for line 3
	level thread beat_3_line_3_window_shooter();
	//------------------------------------------------------------------------------------//
	
	// -- Shore a.k.a. Fourth Line -------------------------------------------------------//
	// -- WWILLIAMS: Start up vehicle sampans with guys on them
	level thread beat_3_attack_sampans_init();
	// -- WWILLIAMS: puts a rpg vc at teh waterhut window, he explodes the hut
	level thread beat_3_rpg_from_hut_window();
	// -- WWILLIAMS: tracks the ai that the player fights on the shore
	level thread beat_3_track_ai_line_4();
	// -- WWILLIAMS: makes an ai run out, die and drop a m202
	level thread beat_3_m202_dropped();
	// additional_ais on island
	level thread beat_3_additional_ais_island();
	//------------------------------------------------------------------------------------//
	
	// -- Fifth Line ---------------------------------------------------------------------//
	// -- WWILLIAMS: tracks the progress of line 5
	level thread beat_3_track_line_5();
	// -- WWILLIAMS: Starts the guys who populate the roof of a shore building
	level thread beat_3_shore_roof();
	// -- WWILLIAMS: shore hut drop down
	//level thread beat_3_shore_hut_drop_init();
	// -- WWILLIAMS: causes the chickencoop to react to the vc running by it
	level thread beat_3_shore_hut_drop_chickencoop();
	// -- WWILLIAMS: starts the rathole for line 5
	level thread beat_3_line_5_rathole();
	//------------------------------------------------------------------------------------//
	
	// -- MG Ridge ----------------------------------------------------------------------//
	//level thread move_reznov_to_ridge();
	// allows player to kill MG using M202
	level thread m202_on_mg();
	// -- WWILLIAMS: temp hiding door
	level thread Beat_3_Hiding_Door_Progress();
	// -- WWILLIAMS: tracks the ai alive after the player moves up to a certain point
	level thread beat_3_track_mg_ridge_ai();
	// -- WWILLIAMS: moves the squad to the right position at the gate
	level thread beat_3_squad_to_gate_door();
	// -- WWILLIAMS: getting the first past of the ridge fight back in
	level thread beat_3_ridge_fight();
	// -- WWILLIAMS: VC who uses the ridge MG
	level thread beat_3_mg_gunner_init();
	// -- WWILLIAMS: vc that slides down the tree next to teh ridge
	level thread beat_3_tree_hugger_init();
	// -- WWILLIAMS: vc opens flap on the ridge hut's roof
	level thread beat_3_ridge_roof_awning();
	//-----------------------------------------------------------------------------------//
	
	// -- Sixth Line --------------------------------------------------------------------//
	// -- WWILLIAMS: checks the count of the vc in line 6
	level thread beat_3_track_line_6();
	// -- WWILLIAMS: controls the spawning of the vc for line 6
	level thread beat_3_populate_line_6();
	//-----------------------------------------------------------------------------------//
	
	// -- WWILLIAMS: temp end to beat 3
	// level thread beat_3_temp_end();
	
	level thread spawn_swift();
	
	wait( 1 );
	level thread move_hut_ais_back();
	
}

move_hut_ais_back()
{
	trigger_wait( "trigger_move_to_ridge_hut_2" );
	enemies = getaiarray( "axis" );
	close_trigger = getent( "hut_move_back_trigger", "targetname" );
	found_count = 0;
	for( i = 0; i < enemies.size; i++ )
	{
		if( enemies[i] istouching( close_trigger ) )
		{
			if( found_count == 0 )
			{
				node = getnode( "back_off_hut_2", "targetname" );
				enemies[i] SetGoalNode( node );
				enemies[i].goalradius = 64;
			}
			else if( found_count == 1 )
			{
				node = getnode( "back_off_hut_1", "targetname" );
				enemies[i] SetGoalNode( node );
				enemies[i].goalradius = 64;
			}
			else if( found_count == 2 )
			{
				node = getnode( "back_off_hut_3", "targetname" );
				enemies[i] SetGoalNode( node );
				enemies[i].goalradius = 64;
			}
			else
			{
				enemies[i] ai_suicide();
			}
			found_count++;
		}
	}
	
	bad_nodes = getnodearray( "do_not_use_hut", "targetname" );
	for( i = 0; i < bad_nodes.size; i++ )
	{
		SetEnableNode( bad_nodes[i], false );
	}
}

wait_for_player_to_exit_first_hut()
{
	trigger_wait( "trig_setup_beat_3_intro" );
	flag_set( "player_exitted_last_hut" );
}

beat_3_spawn_functions() // -- WWILLIAMS: spawn functions for the village
{
	// top of the ridge guys should always stand
	ridge_stand_spawner = GetEnt( "b3_always_stand", "script_noteworthy" );
	ridge_stand_spawner add_spawn_function( ::always_stand );
	
	// force gibbing on these guys meant for MG
	array_thread( GetEntArray( "b3_gibbing_guys", "script_noteworthy" ), ::add_spawn_function, ::gib_fest );
}

// ---------------------------------------------------------------------------------//
// -- BEAT 3 CIVILIANS -- //
// ---------------------------------------------------------------------------------//
beat_3_civilian_init() // -- WWILLIAMS: Set up the civilians in the village
{
	trigger_wait( "trig_setup_beat_3_intro" );
	
	// spawn out the civs
	vc_ai_array = simple_spawn( "spawner_beat_3_civ_hut", ::beat_3_civ_idle_and_react_hut );
	vc_ai_array_2 = simple_spawn( "spawner_beat_3_civ", ::beat_3_civ_idle_and_react );
}

beat_3_civ_idle_and_react() // -- WWILLIAMS: Civ function runs the idle and react as well as the cower function on the guy
{
	// make civilians un-killable
	self thread magic_bullet_shield();
	self disable_pain();
	self disable_react();
	
	self be_stupid();
	self.disableArrivals = true;
	self.disableExits = true;
	self.disableTurns = true;
	
	// handle the idle part of their anims
	// parameters: guy, idle_anim, reaction_anim, tag, react_flag
	self thread civilian_ai_idle_and_react( self, "idle_smoke", "surprise_react", undefined, "run_to_cower" );
	
	// run them away
	self thread beat_3_civ_run_to_cower();
}

beat_3_civ_idle_and_react_hut()
{
	// make civilians un-killable
	self thread magic_bullet_shield();
	self disable_pain();
	self disable_react();
	
	self be_stupid();
	self.disableArrivals = true;
	self.disableExits = true;
	self.disableTurns = true;
	
	// handle the idle part of their anims
	// parameters: guy, idle_anim, reaction_anim, tag, react_flag
	self thread civilian_ai_idle_and_react( self, "idle_smoke", "surprise_react", undefined, "run_to_cower" );
	
	// run them away
	self thread beat_3_civ_run_to_cower( "line_1_backup_manager_start" );
}

beat_3_civ_run_to_cower( trigger_name) // -- WWILLIAMS: Civilian runs to predetermined node (self.script_string) after village assault starts
{
	self endon( "death" );

	if( isdefined( trigger_name ) )
	{
		trigger_wait( trigger_name );
	}
	else
	{
		// when village is alerted, stops the idle anims
		flag_wait("break_stealth");
	}
	self notify( "run_to_cower" );

	// run the civilian through his linked nodes
	node_array = get_linked_nodes( self.script_string );
	self go_through_linked_nodes( node_array );

	// delete the civilian once he's out of the way
	self Hide();
	self Delete();
}
// ---------------------------------------------------------------------------------//
// -- BEAT 3 CIVILIANS -- //
// ---------------------------------------------------------------------------------//

// ---------------------------------------------------------------------------------//
// -- BEAT 3 INTRO AMBUSH -- //
// ---------------------------------------------------------------------------------//

beat_3_village_redshirts() // -- WWILLIAMS: Spawn out the first redshirts for the village
{
	// wait for player to exit hut
	trigger_wait( "trig_setup_beat_3_intro" );
	
	// spawn out the guys
	first_village_redshirts = simple_spawn( "spawner_village_redshirt" );
	array_thread( first_village_redshirts, ::beat_3_redshirt_setup_for_ambush );
	
	// when player moves up a bit, tell the guys to move forward more
	trigger_wait( "trigger_start_redshirts_for_ambush" );
	flag_set( "ambush_redshirt_move_up" );
}


beat_3_redshirt_setup_for_ambush()
{
	self endon( "death" );
	
	// in case we need the redshirt to open fire prior to him completing the walk
	self endon( "failsafe_interrupt" );
	
	// make sure they don't start shooting
	self thread hold_fire();
	
	// make them follow the nodes more exactly
	self.goalradius = 24;
	
	// tokenize the script_string
	
	// move to the first node and get into a stance
	start_ambush_approach_node = GetNode( self.script_string, "targetname" );
	self SetGoalNode( start_ambush_approach_node );
	self waittill( "goal" );
	self AllowedStances( "crouch" );
	
	// get the list of nodes to go through next
	next_nodes = get_linked_nodes( start_ambush_approach_node.target );
	
	// failsafe: In case player pulls trigger early, use this to interrupt the walk
	self thread failsafe_for_ambush( next_nodes[next_nodes.size-1] );
			
	// wait for player to pass by
	flag_wait( "ambush_redshirt_move_up" );
	
	self thread allow_stand_after_chain();
	
	// walk through the nodes to the final cover spot
	self go_through_linked_nodes( next_nodes, "player_presses_plunger" );
}

allow_stand_after_chain()
{
	self waittill( "reached_end_of_node_array" );
	self AllowedStances( "stand", "crouch" );
}

failsafe_for_ambush( go_to_node )
{
	self endon ( "death" );
	
	flag_wait( "grenade_explode" );

	self SetGoalNode( go_to_node );
	self AllowedStances( "stand", "crouch" );
	self thread resume_fire();
	
	self notify( "failsafe_interrupt" );
}

beat_3_into_ambush_position() // -- WWILLIAMS: moves barnes into position for the ambush
{
	//TUEY Change Music State
	//setmusicstate("VILLAGE_PRE_FIGHT");
	
	anim_node = getstruct( "plunger_anim_node", "targetname" );
	
	// setup barnes and hudson
	level.barnes.goalradius = 24;
	//level.barnes AllowedStances( "crouch" );
	level.hudson.goalradius = 24;
	level.hudson AllowedStances( "crouch" );
	
	// hudson teleport and plays first frame of anim
	start_node = getnode( "b3_lewis_ambush_teleport", "targetname" );
	level.hudson forceteleport( start_node.origin, start_node.angles );	
	level.hudson SetGoalNode( start_node );
	//anim_node thread anim_first_frame( level.hudson, "plunger_talk" );
	
	level thread barnes_reaching_for_plunger_anim();
	
	// wait for the explosion
	flag_wait( "grenade_explode" );
		
	// handles if barnes has reached his anim or not
	if( level.barnes_in_position_for_plunger == false )
	{
		level.barnes StopAnimScripted();
		level.hudson StopAnimScripted();
		level.barnes disable_cqbwalk();
		level.barnes set_run_anim( "custom_run" );
	}
	else
	{
		level.barnes StopAnimScripted();
		level.hudson StopAnimScripted();
		level.barnes disable_cqbwalk();
		level.barnes set_run_anim( "custom_run" );
		
		anim_node thread anim_single_aligned( level.barnes, "plunger_attack" );
		anim_node anim_single_aligned( level.hudson, "plunger_attack" );
	}
	
	// barnes and hudson get ready to attack
	level.barnes AllowedStances( "stand", "crouch", "prone" );
	level.hudson AllowedStances( "stand", "crouch", "prone" );
	
	barnes_attack_node = getnode( "b3_barnes_rush_node", "targetname" );
	hudson_attack_node = getnode( "node_hudson_after_ambush", "targetname" );
	level.barnes SetGoalNode( barnes_attack_node );
	level.hudson SetGoalNode( hudson_attack_node );
	
	level.barnes thread set_and_restore_force_goal();
	level.hudson thread set_and_restore_force_goal();
}

set_and_restore_force_goal()
{
	self.script_forcegoal = 1;
	self waittill( "goal" );
	self.script_forcegoal = 0;
	
	self.ignoreall = false;
}


barnes_reaching_for_plunger_anim()
{
	level.barnes_in_position_for_plunger = false;
	anim_node = getstruct( "plunger_anim_node", "targetname" );
	
	level endon( "grenade_explode" );
	
	// barnes simply reach for the anim
	level.barnes.disableArrivals = true;
	reach_node_1 = getnode( "village_barnes_reach_ambush_1", "targetname" );
	level.barnes SetGoalNode( reach_node_1 );
	level.barnes waittill_close_to_goal( reach_node_1, 45 );
	level.barnes enable_cqbwalk();
	
	reach_node_2 = getnode( "village_barnes_reach_ambush_2", "targetname" );
	level.barnes SetGoalNode( reach_node_2 );
	level.barnes waittill_close_to_goal( reach_node_2, 45 );
	reach_node_3 = getnode( "village_barnes_reach_ambush_3", "targetname" );
	level.barnes SetGoalNode( reach_node_3 );
	level.barnes waittill_close_to_goal( reach_node_3, 45 );
	
	flag_wait( "player_exitted_last_hut" );
	
	anim_node anim_reach_aligned( level.barnes, "plunger_talk" );
	level.barnes.disableArrivals = false;
	
	// move the redshirts up too
	player = get_players()[0];
	redshirt_moveup_trigger = getent( "trigger_start_redshirts_for_ambush", "targetname" );
	redshirt_moveup_trigger UseBy( player );
	
	level thread temp_wait_for_reach_barnes();
	
	// time to play the full anim
	anim_node thread anim_single_aligned( level.hudson, "plunger_talk" );
	anim_node anim_single_aligned( level.barnes, "plunger_talk" );
	level.barnes disable_cqbwalk();
	level.barnes set_run_anim( "custom_run" );
	
	// loop idle
	anim_node thread anim_loop_aligned( level.barnes, "plunger_idle" );
	anim_node thread anim_loop_aligned( level.hudson, "plunger_idle" );
	
	// ask player to use the plunger
	level thread barnes_tells_player_to_ready_plunger();
}

temp_wait_for_reach_barnes()
{
	wait( 5.5 );
	level.barnes_in_position_for_plunger = true;
}

waittill_close_to_goal( goal_node, dist )
{
	self endon( "death" );
	
	while( distance( self.origin, goal_node.origin ) > dist )
	{
		wait( 0.05 );
	}
}

barnes_tells_player_to_ready_plunger()
{
	flag_set( "ready_to_start_ambush" );
}

village_stealth()
{
	level thread detect_player_alerted_vc();

	// wait for Carter to be given the plunger
	//flag_wait( "ready_to_start_ambush" );
	
	//trigger_wait("trigger_start_ambush");
	//flag_set( "plunger_to_player" );
	flag_wait( "ambush_success" );

	//level thread lewis_distraction();
	flag_set( "break_stealth" );
	flag_set( "village_alerted" );
	
	//TUEY: Changing music state once battle starts\
	
	level thread switch_music_check();
	battlechatter_on();
	
	level thread play_screams();
	
	clientnotify( "bst" ); //Notifying the client that Stealth was broken
	
	level thread beat_3_track_ai_line_1();
	
	//TUEY Moved this battle chatter call to the music call!!!
	//battlechatter_on( "axis" );
		
	level.barnes resume_fire();
	
	level.barnes thread beat_3_barnes_kills_catwalk_vc();
	
	// move redshirts up since barnes and lewis moved
	//trigger_use("trigger_redshirt_positions_after_explosion");
}

beat_3_push_foward()
{
	level thread force_barnes_to_move_up_bridge();
	
	// push guys up once stealth is broken
	flag_wait( "grenade_explode" );
	
	level.hudson resume_fire();
	level.barnes resume_fire();
	
	wait( 2 );
	
	level.barnes set_force_color( "r" );
	level.barnes enable_ai_color();

	level.hudson set_force_color( "y" );
	level.hudson enable_ai_color();
	
	// spawn couple more AIs on bridge
	ais = simple_spawn( "b3_additional_ai_bridge", ::bridge_extend_radius );
	
	trigger_use( "b3_ambush_fc_1" );
	level thread force_ais_to_move_up( "first_village_area_cleared" );
	level.barnes say_dialogue( "weapons_free" );
	level.barnes say_dialogue( "keep_eye_open_aa" );
	level thread dialog_additional_lines_w_timeout( "first_village_area_cleared" );
	
	level thread push_through_village_part_1();
	
	// wait for player to start the rathole vcs
	flag_wait( "rat_hole_1_started" );
	trigger_use( "b2_village_fc4" );
	
	flag_set( "squad_at_aa_village" );
	
	// change to not eliminate the AA gun, instead just clear the area
	flag_wait( "village_aa_area_secured" );

	/*
		level thread dialog_m202_redshirt();
		wait( 3 );
		// spawn the m202 guy
		level notify( "ready_to_spawn_m202" );
		
		level waittill( "village_m202_destroyed" );
	*/
	battlechatter_off( "allies" );
	
	level.hudson thread say_dialogue( "zpu_on_river", 3 );
	level.hudson thread say_dialogue( "move_it_brother", 7 );
	level thread dialog_additional_lines_w_timeout_2();
		
	// start calvary
	level thread maps\creek_1_calvary::calvary_main();
	
	//waittill_zone_is_cleared( "b3_zone_3" ); // rathole area is clear
	trigger_use( "trigger_dmg_ridge_rathole" ); // stop the rathole for good
	level notify( "fourth_village_area_cleared" );
	
	// tell AIs to get close to shore (but not yet). Wait for player to get closer, then commit to the shore
	trigger_use( "trigger_fc_shore_line_start" );
	spawn_manager_enable( "waterhut_manager" );
	level thread force_ais_to_move_up( "river_cleared" );
	//level.barnes waittill( "goal" );
	trigger_wait( "trigger_approach_shore" );
	trigger_use( "trigger_fc_shore_line" );
	level thread force_ais_to_move_up( "river_cleared" );
	trigger_use( "extra_village_friendlies_trigger", "script_noteworthy" ); // change reinforcement position
	
	wait( 5 );
	level.barnes go_to_node_by_name( "m202_wingman_node" );
	//autosave_by_name( "creek_1_b3_pf" );
}

push_through_village_part_1()
{
	level endon( "rat_hole_1_started" );
	
	// wait for the immediate bridge area to clear, then push the AIs up
	waittill_ai_group_count( "village_vc_area_a", 4 );
	clear_entities( "b3_additional_ai_bridge" );
	
	waittill_zone_is_cleared( "b3_zone_0" );

	flag_set( "first_village_area_cleared" );
	
	chance = randomint( 100 );
	if( chance < 50 )
	{
		level.hudson thread say_dialogue( "clear_move_move" );
	}
	else
	{
		level.barnes thread say_dialogue( "area_clear!" );
	}
	level.barnes thread say_dialogue( "need_you_in_pos", 3 );
	
	level.barnes thread say_dialogue( "eyes_left_mason", 12 );
	
	// move the squad up
	trigger_use( "b3_move_up_to_bridge" );
	level thread force_ais_to_move_up( "second_village_area_cleared" );
	
	// spawn a few more AIs
	friendies_extra = simple_spawn( "c_friendly_respawn" );
	
	// spawn guys from large hut
	trigger_use( "line_1_backup_manager_start" );

//-----------------------------------------------------------------------

	// wait for the village center to be cleared
	wait( 3 );
	waittill_zone_is_cleared( "b3_zone_1" );
	flag_set( "second_village_area_cleared" );

	//level.barnes thread say_dialogue( "area_clear!", 3 );
	
	trigger_use( "b2_village_fc4" );
	level thread force_ais_to_move_up( "fourth_village_area_cleared" );
	
	// spawn reinforcements
	trigger_use( "trigger_catwalk_passed", "script_noteworthy" );
	trigger_use( "line_1_backup_manager_stop" );
	// spawn ridge enemies
	trigger_use( "b2_village_spawn_ridge" );

	level thread rathole_open_timeout();
}


force_barnes_to_move_up_bridge()
{
	trigger_wait( "b3_move_up_to_bridge" );
	level.barnes go_to_node_by_name( "village_patrol_1_2" );
}

rathole_open_timeout()
{
	wait( 10 );
	waittill_zone_is_cleared( "b3_zone_3b" );
	
	if( !flag( "rat_hole_1_started" ) )
	{
		flag_set( "rat_hole_1_started" );
		level notify( "rat_tunnel_already_started" );	
		spawn_manager_enable( "rathole_manager_line_3" );
	}
}

bridge_extend_radius()
{
	self endon( "death" );
	self waittill( "goal" );
	wait( 2 );
	self.goalradius = 512;
}

force_ais_to_move_up( end_msg )
{
	level endon( end_msg );
	
	level.barnes thread force_ai_to_move_up( end_msg, 0 );
	level.hudson thread force_ai_to_move_up( end_msg, 0 );
}

force_ai_to_move_up( end_msg, delay_time )
{
	wait( delay_time );
	self.goalradius = 24;
	self be_stupid();
	self waittill( "goal" );
	self stop_being_stupid();
}

play_screams()
{
	wait(2);
	playsoundatposition ("vox_play_crowd_yell", (0,0,0));	
}

give_player_plunger_early()
{
	trigger_wait( "trigger_start_redshirts_for_ambush" );
	flag_wait( "player_out_of_hut_village" );
	flag_set( "plunger_to_player" );
}

beat_3_give_player_plunger() // -- WWILLIAMS: takes the player weapons and places the plunger in their hands
{
	level endon( "village_stealth_fail" );
	
	level thread give_player_plunger_early();
	
	flag_wait( "plunger_to_player" );
	
	if( flag( "ambush_fail" ) )
	{
		return;
	}
	
	level thread plunger_vo();

	// take player weapons
	players = get_players();
	players[0] take_player_weapons();

	// give the player the flamethrower
	// NOTE: m2_flamethrower is no longer a viable weapon, we have flamethrower as an attachment now
	players[0] GiveWeapon( "creek_satchel_charge_sp" );
	players[0] SwitchToWeapon( "creek_satchel_charge_sp" );
	
	level thread plunger_use_text();

	// push the plunger automatically?
	//flag_wait( "lewis_explosive_ready" ); 

	//players[0] waittill_any( "detonate", "alt_detonate" );
	
	while( true )
	{
		if (get_players()[0] AttackButtonPressed())
		{
			break;
		}

		wait( 0.05 );
	}

	
	get_players()[0] PlayRumbleOnEntity( "grenade_rumble" );
	get_players()[0] PlayRumbleOnEntity( "tank_rumble" );
	get_players()[0] PlayRumbleOnEntity( "tank_fire" );
	get_players()[0] PlayRumbleOnEntity( "artillery_rumble" );

	level notify( "player_presses_plunger" );
	flag_set( "ambush_success" );
	level.barnes AllowedStances( "stand", "crouch", "prone" );
	level.hudson AllowedStances( "stand", "crouch", "prone" );
	
	if( !flag( "village_stealth_fail" ) )
	{
		exploder( 3000 );
	}
	wait( 1.0 );
	
	level notify( "player_gets_commando" );
	// remove plunger and give back weapons
	player = get_players()[0];
	player TakeAllWeapons();
	player GiveWeapon( "knife_sp", 0 );
	player GiveWeapon( "frag_grenade_sp", 0 );
	//player GiveWeapon( "m8_white_smoke_sp", 0 );
	player GiveWeapon( "commando_gl_sp", 0, 8 ); // tiger camo
	//player GiveWeapon( "commando_sp", 0 );
	player GiveWeapon( "wa2000_sp", 0, 9 ); // urban german camo
	player GiveMaxAmmo( "commando_gl_sp" );
	//player GiveMaxAmmo( "commando_sp" );
	player GiveMaxAmmo( "wa2000_sp" );
	player SwitchToWeapon( "commando_gl_sp" );
	//player SwitchToWeapon( "commando_sp" );
	
	//player thread replenish_gl_ammo();
}

plunger_vo()
{
	level endon( "player_presses_plunger" );
	player = get_players()[0];
	level.barnes say_dialogue( "detonator_ready" );
	player say_dialogue( "right_here" );
}

plunger_use_text()
{
	wait( 0.5 );
	if( !flag( "ambush_success" ) )
	{
		screen_message_create( &"CREEK_1_DETONATE_STRING" );
		flag_wait( "ambush_success" );
		screen_message_delete();
	}
}

replenish_gl_ammo()
{
	while( 1 )
	{
		// if we have the gl equipped and have no ammo, reset it to 3
		my_weapon = self GetCurrentWeapon();
		
		clip_ammo = self GetWeaponAmmoClip( "gl_commando_sp" );
		stock_ammo = self GetWeaponAmmoStock( "gl_commando_sp" );
		total_ammo = clip_ammo + stock_ammo;
		
		if( my_weapon == "gl_commando_sp" && total_ammo == 1 )
		{
			self GiveMaxAmmo( "gl_commando_sp" );
		}
		wait( 0.05 );
	}
}

play_village_explosion( num, struct )
{
    if( !IsDefined( struct ) )
        return;
       
    playsoundatposition( "exp_village_hut_" + num, struct.origin );
}

beat_3_barnes_kills_catwalk_vc()// -- WWILLIAMS: causes barnes to target the vc on the catwalk at ambush
{
	// nodes
	// shoot_at_vc_node = GetNode( "node_barnes_shoots_catwalk_vc", "targetname" );
	cover_after_ambush = GetNode( "node_barnes_after_ambush", "targetname" );
	// ent
	target_vc = level.vc_catwalk;
	
	old_goalradius = self.goalradius;
	self.goalradius = 32;
	
	self SetEntityTarget( target_vc ); 
	
	self.script_accuracy = 10;
	
	self SetGoalNode( cover_after_ambush );

	target_vc waittill( "death" );
	
	self ClearEntityTarget();
	
	self.script_accuracy = 1;
	
}

beat_3_roof_rpg_vc() // -- WWILLIAMS: Vc runs out onto roof and gets into the fight
{
	flag_wait( "break_stealth" );
	wait_for_either_trigger( "trigger_start_roof_rpg_box", "b2_alert_vc_1" );

	vc_with_rpg = simple_spawn_single("spawner_roof_rpg_vc");

	// endon
	vc_with_rpg endon( "death" );
	
	vc_with_rpg.goalradius = 64;
	vc_with_rpg.animname = "roof_rpg_vc";
	// makes sure the guy doesn't switch from the rpg
	vc_with_rpg.a.allow_weapon_switch = false;
	// keeps the ammo count of the rpg up
	vc_with_rpg thread beat_3_rpg_ammo_control(); 
	
	struct_anim = getstruct( "anim_struct_village_large_building_1", "targetname" );

// 	roof_attack_node = GetNode( "node_fire_rpg", "targetname" );

	level.rpg_roof.animname = "roof_rpg_vc_door";

	struct_anim thread animate_beat_3_roof_rpg_door(level.rpg_roof);
	struct_anim anim_single_aligned( vc_with_rpg, "rpg_death_from_above" );
	
	wait( 3 );
	level.barnes thread say_dialogue( "contact_on_roof" );
}

#using_animtree("creek_1");
animate_beat_3_roof_rpg_door(door)
{
	/#
		RecordEnt(door);
	#/

	door UseAnimTree(#animtree);
	self anim_single_aligned(door, "rpg_death_from_above");
}

beat_3_roof_door_init() // -- WWILLIAMS: grabs the two roof doors and defines them for the event
{
	// the roof doors are in prefab, thus have the same targetname.
	// we can tell them apart by their relative height
	vc_roof_doors = GetEntArray( "roof_door", "targetname" );
	
	if( vc_roof_doors[0].origin[2] > vc_roof_doors[1].origin[2] )
	{
		level.ridge_roof = vc_roof_doors[0];
		level.rpg_roof = vc_roof_doors[1];
		
	}
	else
	{
		level.ridge_roof = vc_roof_doors[1];
		level.rpg_roof = vc_roof_doors[0];
	}
}

beat_3_vc_intro() // -- WWILLIAMS: Spawns out all the village vc and sets them up to handle the scene
{
	// wait for player to exit starting hut
	trigger_wait( "trig_setup_beat_3_intro" );

	// spawn and animate VCs in village intro
	level.vc_intro_actors = simple_spawn( "spawners_vc_village_intro", ::beat_3_intro_anims );
	level thread dialog_vc_intro();
	
	clear_entities( "spawners_vc_village_intro" );
}

beat_3_intro_anims() // -- WWILLIAMS: runs on each vc spawned out for the intro sets their idle anim and reaction to the distraction
{
	self endon( "death" );
	
	// anim node to animated everything from
	self_anim_node = getstruct( "anim_struct_village_under_catwalk_1", "targetname" );
	
	// basic setup
	self hold_fire();
	self.grenadeammo = 0; 
	self.a.disableLongDeath = true;
	self.allowdeath = true;
	
	// this guy is important, don't let him die
	if( self.animname == "vc_distraction_1" )
	{
		self.health = 99999;
	}
	
	// setup VC to play failed stealth anims
	self thread beat_3_vc_react_to_fail( self_anim_node );
	
	// this VC is special. We need Barnes to kill him later
	if( self.animname == "vc_catwalk_high" )
	{
		level.vc_catwalk = self;
	}
	
	// play the idle anim
	self_anim_node thread anim_loop_aligned( self, self.script_string );
	
	// stealth is complete. Time to react and start fighting
	flag_wait_any( "ambush_success", "break_stealth" );

	// play reaction animation
	
	if( flag( "village_stealth_fail" ) && ( self.animname == "vc_distraction_1" ||
		self.animname == "vc_distraction_2" || self.animname == "vc_distraction_3" ) )
	{
		return;
	}

	// test
	if( self.script_noteworthy == "cooking_react" )
	{
		self StopAnimScripted();
		wait( 1 );
	}
	else
	{
		self_anim_node thread anim_single_aligned( self, self.script_noteworthy );
		
		// hack to trigger the explosion early
		if( self.script_noteworthy == "vc_distract_react_1" )
		{
			wait( 0.05 );
			fraction_skip = 115 / 183;
			anim_set_time( self, self.script_noteworthy, fraction_skip );
		}
		else if( self.script_noteworthy == "vc_distract_react_2" )
		{
			wait( 0.05 );
			fraction_skip = 115 / 185;
			anim_set_time( self, self.script_noteworthy, fraction_skip );
		}
		else if( self.script_noteworthy == "vc_distract_react_3" )
		{
			wait( 0.05 );
			fraction_skip = 115 / 190;
			anim_set_time( self, self.script_noteworthy, fraction_skip );
		}
		
		self_anim_node waittill( self.script_noteworthy );
	}

// SPECIAL COMBAT REACTIONS

	// This VC on balcony will fall over upon damage
	if( self.script_noteworthy == "high_react" )
	{
		self.goalradius = 24;
		self SetGoalPos( self.origin );
		self.health = 50000;
		
		// just wait to be damaged and play the falling death anim
		self thread resume_fire_in_a_moment();
		self waittill( "damage" );
		self_anim_node anim_single_aligned( self, "high_death" );
		self ai_suicide();
		return;
	}
	
	if( self.script_noteworthy == "cooking_react" )
	{
		goal_node = getnode( "b3_rusher_dest_2", "targetname" );
		self.goalradius = 16;
		self SetGoalNode( goal_node );
	}
	
	if( self.script_noteworthy == "crate_react" )
	{
		goal_node = getnode( "b3_rusher_dest_1", "targetname" );
		self.goalradius = 16;
		self SetGoalNode( goal_node );
		//self thread maps\_rusher::rush();
	}
	
	self thread resume_fire_in_a_moment();
}

resume_fire_in_a_moment()
{
	self endon( "death" );
	self.ignoreall = true;
	wait( randomfloatrange( 2.0, 3.6 ) );
	self.ignoreall = false;
}

beat_3_vc_react_to_fail( anim_spot ) // -- WWILLIAMS: causes the vc to react to a fail on the stealth
{
	level endon( "ambush_success" );
	self endon( "death" );
	
	AssertEx( IsDefined( anim_spot ), "anim spot not defined" );
	
	flag_wait( "ambush_fail" );
	
	// For a few specific VCs, we will play something special. 
	if( self.animname == "vc_distraction_1" )
	{
		self.health = 1;
		anim_spot thread anim_single_aligned( self, "vc_distract_fail_1" );
	}
	else if( self.animname == "vc_distraction_2" )
	{
		anim_spot thread anim_single_aligned( self, "vc_distract_fail_2" );
	}
	else if( self.animname == "vc_distraction_3" )
	{
		anim_spot thread anim_single_aligned( self, "vc_distract_fail_3" );
	}
	
	// for everyone else, do the basic reaction anim
	else
	{
		anim_spot thread anim_single_aligned( self, self.script_noteworthy );
	}	
}

beat_3_grenade_explosion( guy ) // -- WWILLIAMS: successful grenade distraction notify
{	
	self.health = 1;
	
	if( flag( "ambush_fail" ) )
	{
		return;
	}
	
	flag_set( "grenade_explode" );
	
	// explode grenade
	
	if( !flag( "village_stealth_fail" ) )
	{
		exploder( 3001 );
	}
	
	// hero chunks
	level notify( "hut01_start" );
}

beat_3_ariel_vc_deaths( guy ) // WWILLIAMS: Special function to kill the airborne VCs
{
	guy.ignoreMe = true;  // stops friendlies from shooting these guys
}

beat_3_distraction_hut_destruction() // -- WWILLIAMS: Controls the distraction hut's states
{
	// endon
	// -- TODO: IN case the player breaks stealth before the distraction
	
	// objects
	// ents (hut pieces)
	hut_clean = GetEnt( "roof_clean", "targetname" );
	hut_destroyed = GetEnt( "roof_destroyed", "targetname" );
	
	// hide the destroyed version and show the clean
	// make sure to disconnect and connect paths since they work independantly 
	hut_destroyed DisconnectPaths();
	hut_destroyed Hide();
	hut_destroyed NotSolid();
	
	hut_clean Show();
	hut_clean Solid();
	hut_clean DisconnectPaths();
	hut_clean ConnectPaths();

	// wait for the grenade to explode
	flag_wait( "grenade_explode" );
	
	// swap the two
	hut_clean DisconnectPaths();
	hut_clean Hide();
	hut_clean NotSolid();
	hut_destroyed Show();
	hut_destroyed Solid();
	hut_destroyed ConnectPaths();
	
	//Kevin adding epxplo sound
	level notify( "hut_explo" );
}

// -- WWILLIAMS: Spawns out the guy who jumps out the window on the left at the catwalk
beat_3_vc_jump_out_window_init()
{
	end_node = GetNode( "node_post_window_jump", "targetname" );
	
	flag_wait_any( "ambush_success", "ambush_fail" );
		
	// spawn out the jumper
	window_jumper = simple_spawn_single( "spawner_vc_jump_out_window" );	
	
	// setup animname
	window_jumper.animname = "vc_jump_out_window";
	window_jumper.goalradius = 36;
	//clear_entities( "spawner_vc_jump_out_window" );
	window_jumper endon( "death" );

	// play anim
	window_jumper beat_3_reach_and_anim( "anim_struct_village_under_catwalk_1", "jump_into_intersection" );
	
	// send him to a guard node in the open
	window_jumper SetGoalNode( end_node );
	window_jumper waittill( "goal" );	
}


beat_3_window_shooter() // -- WWILLIAMS: VC shoots through a boarded up window in the building on the left after the ambush starts
{
	flag_wait_any( "ambush_success", "ambush_fail" );
	
	vc_window_shooter = simple_spawn_single( "spawner_window_shooter" );
	
}

beat_3_ambush_fill_left_side() // -- WWILLIAMS: adding more guys for the left of the ambush line
{
	// endon
	
	
	// objects
	fill_left_side_spawner = GetEnt( "spawner_ambush_fill_left", "targetname" );
	array_left_side_nodes = GetNodeArray( fill_left_side_spawner.script_string, "targetname" );
	
	// wait for the ambush to happen
	flag_wait( "grenade_explode" );
	
	// fill up the left
	for( i = 0; i < array_left_side_nodes.size; i++ )
	{
		dude_on_left = simple_spawn_single( fill_left_side_spawner, ::beat_3_go_to_left_node_and_stay, array_left_side_nodes[i] );
		wait( 0.2 ); // make sure the guy leaves the area of the spawner
	}
	//clear_entities( "spawner_ambush_fill_left" );
}

beat_3_go_to_left_node_and_stay( destination_node ) // -- WWILLIAMS: sends the guy to a node and makes him stay there
{
	self endon( "death" );
	
	self.goalradius = 32;
	
	self SetGoalNode( destination_node );
	
	self waittill( "goal" );
}

beat_3_keep_line_1_busy() // -- WWILLIAMS: a spawn manager for extra guys to keep the fight alive after group a dies
{
	// wait for the ambush to start
	flag_wait( "grenade_explode" );
	
	// start tracking the amount of guys
	//waittill_ai_group_count( "village_vc_area_a", 4 );
	wait( 5 );
	
	// start the spawn manager
	spawn_manager_enable( "line_1_backup_manager" );
	
	// once player gets close stop this
	trigger_wait( "line_1_backup_manager_stop" );

	// stop the spawn manager
	spawn_manager_disable( "line_1_backup_manager" );
}

beat_3_line_3_window_shooter() // -- WWILLIAMS: spawns out the window shooter for line 2
{
	// endon
	level endon( "stop_window_vc_at_line_3" );
	
	// objects
	// trigger
 	area_trigger = GetEnt( "trigger_window_shooter_line_3", "targetname" );
	lookat_trigger = GetEnt( "trigger_window_shooter_line_3_lookat", "targetname" );
	
	trigger_wait( "b2_village_spawn_ridge" );
	
	lookat_trigger thread beat_3_line_2_window_shooter_looked_at();
	
	while( 1 )
	{
		area_trigger waittill( "trigger", who );
		
		lookat_trigger trigger_on();
		
		while( who IsTouching( area_trigger ) )
		{
			wait( 0.4 );
		}
		
		lookat_trigger trigger_off();
	}
}

beat_3_line_2_window_shooter_looked_at() // -- WWILLIAMS: runs off trigger, basically spawns the guy when the trigger is seen
{
	// endon
	
	self waittill( "trigger" );
	
	line_2_vc_shooter = simple_spawn_single( GetEnt( "spawner_line_2_window", "targetname" ) );
	
	level notify( "stop_window_vc_at_line_3" );
	//clear_entities( "spawner_line_2_window" );
	// clean up the spawner
}

beat_3_track_ai_line_1() // -- WWILLIAMS: once the ai group is exhausted move the squad up
{
	// trigger 
	waittill_ai_group_count( "village_vc_area_a", 1 );

	// flag
	flag_set( "demo_line_1_clear" );
	
	// make the last vc a rusher
	area_a_vc = get_ai_group_ai( "village_vc_area_a" );
	for( i = 0; i < area_a_vc.size; i++ )
	{
		area_a_vc[i] thread maps\_rusher::rush();
	}
	
	players = get_players();
}

detect_player_alerted_vc()
{
	trigger_wait( "b2_alert_vc_1", "targetname" );
	
	if( !flag( "ambush_success" ) )
	{
		flag_set( "village_stealth_fail" );
		flag_set( "break_stealth" );
		
		player = get_players()[0];
		player take_player_weapons();
		screen_message_delete();
	
		//flag_set( "grenade_explode" );
		
		//iprintlnbold( "Shit. What are you doing Carter?" );
		//wait( 0.5 );
		player dodamage( player.health * 0.5, ( -23864, 35440, 112 ) );
		wait( 0.2 );
		player dodamage( player.health + 0.5, ( -23864, 35440, 112 ) );
		wait( 0.2 );
		player dodamage( player.health + 100, ( -23864, 35440, 112 ) );
		wait( 0.1 );
		player dodamage( player.health + 100, ( -23864, 35440, 112 ) );

		missionfailedwrapper( "@CREEK_1_FAIL_SILENCED" );
	}
}

break_stealth()
{
	level endon("break_stealth");
	flag_wait("break_stealth");
 	flag_set( "village_alerted" );
 	flag_set( "ambush_fail" );
 	flag_set( "grenade_explode" );
}

// ---------------------------------------------------------------------------------//
// -- BEAT 3 INTRO AMBUSH -- //
// ---------------------------------------------------------------------------------//

// ---------------------------------------------------------------------------------//
// -- BEAT 3 INTERIOR SECOND LINE -- //
// ---------------------------------------------------------------------------------//

beat_3_reinforcement_leader() // WWILLIAMS: Spawns out the guy who brings backup to the interior village
{
	trigger_wait( "line_1_backup_manager_stop" );
	
	backup_leader = simple_spawn_single( "spawner_backup_leader" );
	
	if( !isdefined( backup_leader ) )
	{
		return;
	}
	//clear_entities( "spawner_backup_leader" );
	
	backup_leader endon( "death" );
	
	// play anim
	backup_leader beat_3_reach_and_anim( "anim_struct_village_under_catwalk_1", "signal_fight" );
	
	// send him to a node
	backup_leader.goalradius = 32;
	end_node = GetNode( "node_backup_leader_end", "targetname" );
	backup_leader SetGoalNode( end_node );
} 

beat_3_backup_slider_init() // -- WWILLIAMS: spawns out the guy who slides into position after the backup leader
{
	// spawn the AI the same time as the leader
	trigger_wait( "line_1_backup_manager_stop" );
	
	backup_slider = simple_spawn_single( "spawner_backup_slider" );
	
	if( !isdefined( backup_slider ) )
	{
		return;
	}
	//clear_entities( "spawner_backup_slider" );
	backup_slider endon( "death" );
	
	// play anim
	backup_slider beat_3_reach_and_anim( "anim_struct_village_under_catwalk_1", "hut_slide" );
	
	// switch goalradius down again
	backup_slider.goalradius = 32;
	
	// send him to that node
	node_after_anim = GetNode( "node_post_slide_cover", "targetname" );
	backup_slider SetGoalNode( node_after_anim );
	backup_slider waittill( "goal" );
}

beat_3_backup_parkour() // -- WWILLIAMS: Spawns out the pakour backup vc
{
	// spawn the AI the same time as the leader
	trigger_wait( "line_1_backup_manager_stop" );
	
	// spawn out the parkour vc
	backup_parkour = simple_spawn_single( "spawner_backup_parkour" );
	
	if( !isdefined( backup_parkour ) )
	{
		return;
	}
	//clear_entities( "spawner_backup_parkour" );
	
	backup_parkour endon( "death" );
	
	wait( 0.4 ); // -- WWILLIAMS: trying to seperate the clump of ai running in together a bit
	
	backup_parkour.allowdeath = 1;
	backup_parkour beat_3_reach_and_anim( "anim_struct_village_under_catwalk_1", "scale_to_roof" );
	
	level.hudson thread say_dialogue( "vc_on_roof" );
	
	backup_parkour.goalradius = 32;
	end_node = GetNode( "node_parkour_end", "targetname" );
	backup_parkour SetGoalNode( end_node );
	backup_parkour waittill( "goal" );
}


beat_3_backup_hurdle_rusher() // -- WWILLIAMS: Spawns out the hurdle rusher
{
	// spawn the AI the same time as the leader
	trigger_wait( "line_1_backup_manager_stop" );
	
	hurdle_rusher = simple_spawn_single( "spawner_backup_hurdle_rusher" );
	
	if( !isdefined( hurdle_rusher ) )
	{
		return;
	}
	//clear_entities( "spawner_backup_hurdle_rusher" );
	hurdle_rusher endon( "death" );
	
	waittill_ai_group_count( "village_vc_area_b", 3 );
	
	//hurdle_rusher beat_3_reach_and_anim( "anim_struct_village_under_catwalk_1", "hurdle_to_rush" );
	
	// guy becomes a rusher after finishing anim
	hurdle_rusher thread maps\_rusher::rush();
}

beat_3_vc_rathole_1()
{
	level endon( "rat_tunnel_already_started" );
	trigger_wait( "b2_village_rathole_spawn_1new" );
	flag_set( "rat_hole_1_started" );
	
	spawn_manager_enable( "rathole_manager_line_3" );
}

beat_3_ridge_vc_line_3() // -- WWILLIAMS: starts the spawn manager for the vc on top of the ridge
{
	trigger_wait( "b2_village_spawn_ridge" );
	
	// start the spawn manager for the ridge
	spawn_manager_enable( "ridge_manager_line_3" );
}

beat_3_backup_ridge_slider_init() // -- WWIILIAMS: Spawns out the ridge slider
{
	trigger_wait( "b2_village_spawn_ridge" );
	wait( 1 );

	// spawn out the slider
	ridge_slider = simple_spawn_single( "spawner_backup_ridge_slider", ::beat_3_backup_ridge_slider );
}

beat_3_backup_ridge_slider() // -- WWILLIAMS: Controls the ridge slider
{
	// endon
	self endon( "death" );
	
	// objects
	// struct for anim
	anim_struct = getstruct( "anim_struct_top_ridge_2", "targetname" );
	// node
	end_node = GetNode( "node_ridge_slider_end", "targetname" );
	
	// setup ai
	self.animname = "vc_ridge_slider";
	old_goalradius = self.goalradius;
	self.goalradius = 24;
	
	// play anim
	self beat_3_reach_and_anim( "anim_struct_top_ridge_2", "slide_down_ridge" );
	
	self SetGoalPos( self.origin );
	//self waittill( "goal" );
	self.goalradius = old_goalradius;
}

beat_3_ridge_roof_roller() // -- WWILLIAMS: Guy runs to the top of the ridge hut roof, has special death animation when damaged
{
	trigger_wait( "b2_village_spawn_ridge" );

	ridge_rooftop_roller = simple_spawn_single( "spawner_vc_ridge_roof" );
	
	if( !isdefined( ridge_rooftop_roller ) )
	{
		return;
	}
	
	ridge_rooftop_roller thread beat_3_ridge_roof_death_failsafe();

	// endon
	ridge_rooftop_roller endon( "death" );
	
	// objects
	anim_struct = getstruct( "anim_struct_top_ridge_2", "targetname" );
	
	// setup vc
	ridge_rooftop_roller.animname = "vc_on_roof";
	ridge_rooftop_roller.goalradius = 32;
	ridge_rooftop_roller.health = 50000; // -- WWILLIAMS: Trying to see if I can make the anim play no matter what gun kills him
	
	// send him to the right spot
	anim_struct anim_reach( ridge_rooftop_roller, "roof_roll_death" );
	ridge_rooftop_roller SetGoalPos( ridge_rooftop_roller.origin );
	
	ridge_rooftop_roller waittill( "damage" );
	
	// play death anim MUST BE ALIGNED TO PLAY PROPERLY
	anim_struct anim_single_aligned( ridge_rooftop_roller, "roof_roll_death" );
	
	ridge_rooftop_roller DoDamage( ridge_rooftop_roller.health + 5000, ridge_rooftop_roller.origin );
}

beat_3_ridge_roof_death_failsafe() // -- WWILLIAMS: makes sure the guy on the ridge roof dies
{
	// endon
	self endon( "damage" );
	self endon( "death" );
	
	// objects
	// trigger
	lookat_trigger = GetEnt( "trigger_auto_kill_ridge_roof", "targetname" );
	
	// wait till either
	lookat_trigger wait_for_trigger_or_timeout( 8 );
	
	wait( 2.0 );
	
	// shoot the guy
	MagicBullet ( "commando_sp", self.origin + ( 0, 0, 200 ), self.origin + ( 0, 0, 45 ), level.barnes );
}

get_there(node)
{
	self.goalradius = 24;
	self.ignoreall = 1;
	self.ignoreme = 1;
	self disable_ai_color();
	self disable_react();
	self disable_pain();
	self.ignoresuppression = true;
	self.suppressionthreshold = 1; 
	self.noDodgeMove = true; 
	self.dontShootWhileMoving = true;
	self.grenadeawareness = 0;
	self.pathenemylookahead = 0;
	self.meleeAttackDist = 0;
	self SetGoalNode(node);
}

play_firedeath_screams( purple_redshirt )
{
	while (IsAlive (purple_redshirt) )
	{
		self.origin = purple_redshirt.origin;
		wait(0.5);			
	}	
	self playsound ("chr_body_burn", "sound_done");
	self waittill ("sound_done");
	self delete();
}

beat_3_m202_dropped() // -- WWILLIAMS: a marine runs into sight then dies and drops a 202
{
	// wait for the right moments
	level waittill( "ready_to_spawn_m202" );
	
	// spawn out the guy
	drop_marine = simple_spawn_single( "spawner_m202_dropper" );
	drop_wingman = simple_spawn_single( "spawner_m202_dropper2" );

	// fake weapon
	drop_marine Attach( "t5_weapon_m202_world", "tag_weapon_right" );
	drop_marine gun_remove();
	
	drop_marine.health = 9999;
	drop_marine.goalradius = 24;
	drop_marine be_stupid();
	
	drop_wingman.health = 9999;
	drop_wingman.goalradius = 24;
	drop_wingman be_stupid();
	
	drop_marine set_run_anim( "m202_run" );
	
	// the wingman does his own thing
	drop_wingman thread support_m202_to_shore();
	

	if( level.m202_anim_version == "normal" )
	{
		// reach and animate the m202 guy
		//iprintlnbold( "normal" );
		anim_node = getstruct( "dock_m202_anim_struct", "targetname" );
		anim_node anim_reach_aligned( drop_marine, "drop_m202" );
		drop_marine thread bullet_kill_fx( 3.16 );
		anim_node thread anim_single_aligned( drop_marine, "drop_m202" );
	}
	else if( level.m202_anim_version == "fast" )
	{
		//iprintlnbold( "fast" );
		anim_node = getstruct( "dock_m202_anim_struct", "targetname" );
		drop_marine thread bullet_kill_fx( 3.16 );
		drop_marine forceteleport( ( -24348, 35077.4, -15.05 ) );
		anim_node thread anim_single_aligned( drop_marine, "drop_m202" );
	}
	else if( level.m202_anim_version == "run_death" )
	{ 
		//iprintlnbold( "no anim" );
		drop_marine forceteleport( ( -24503, 34574.4, -15.1 ) );
		drop_marine SetGoalPos( ( -24691, 35150, -10.3867 ) );
		drop_marine thread bullet_kill_fx_v2();
		drop_marine waittill( "goal" );
		drop_marine ai_suicide();
		play_m202_guy_drop_m202( drop_marine );
	}
}

play_m202_guy_drop_m202( guy )
{
	guy Detach( "t5_weapon_m202_world", "tag_weapon_right" );
	
	trace = bullettrace( guy GetTagOrigin( "tag_weapon_right" ) + ( 0, 0, 500 ), guy GetTagOrigin( "tag_weapon_right" ) + ( 0, 0, -500 ), 0, undefined );
	ground_pos = trace["position"] + ( 0, 0, 1.5 );
	level.m202_drop = spawn( "weapon_m202_flash_magic_bullet_sp", ground_pos, 1 );
	level.m202_drop.angles = guy GetTagAngles( "tag_weapon_right" );
	level.m202_drop SetModel( "t5_veh_helo_huey_att_interior" );
	level.m202_drop ItemWeaponSetOptions( 9 );
	
	level thread beat_3_pick_up_202();
}

support_m202_to_shore()
{
	self endon( "death" );
	anim_node = getstruct( "dock_m202_anim_struct", "targetname" );
	anim_node anim_reach_aligned( self, "drop_m202" );
	self thread bullet_kill_fx( 3.56 );
	anim_node anim_single_aligned( self, "drop_m202" );
	self thread bloody_death( true );
}

bullet_kill_fx( kill_time )
{
	wait( kill_time - 1.4 );
	bullet_origin = ( -26037, 35046, 26 );
	bullet_end_origin = self GetTagOrigin( "J_Spine4" );
	for( i = 0; i < 30; i++ )
	{
		MagicBullet( "ak47_sp", bullet_origin, bullet_end_origin + ( 0, randomintrange( -12, 12 ), randomintrange( -10, 10 ) ) );
		wait( 0.05 );
	}
}

bullet_kill_fx_v2()
{
	wait( 1.0 );
	bullet_origin = ( -26037, 35046, 26 );
	bullet_end_origin = ( -24691, 35150, -10.3867 );
	for( i = 0; i < 30; i++ )
	{
		MagicBullet( "ak47_sp", bullet_origin, bullet_end_origin + ( 0, randomintrange( -12, 12 ), randomintrange( -10, 10 ) ) );
		wait( 0.05 );
	}
}

beat_3_pick_up_202()
{
	level endon( "demo_line_4_clear" );
	
	// if player picks it up within 2.5 seconds, finish this
	timer = 2.5;
	for( i = 0; i < timer * 20; i++ )
	{
		if( !isdefined( level.m202_drop ) )
		{
			level.player_picked_up_m202 = true;
			flag_set( "player_picks_up_m202_early" );
			return;
		}
		wait( 0.05 );
	}
	
	if( flag( "aa_gunner_shot" ) )
	{
		return;
	}
	
	if( !isdefined( level.m202_drop ) )
	{
		return; // player already picked it up
	}
	
	level notify( "player_should_get_m202" );
	// spawn a fake model
	level.fake_weapon = spawn( "script_model", level.m202_drop.origin );
	level.fake_weapon.angles = level.m202_drop.angles;
	level.fake_weapon SetModel( "t5_weapon_m202_world_obj" );	
	
	while( isdefined( level.m202_drop ) )
	{
		if( flag( "aa_gunner_shot" ) )
		{
			level.fake_weapon delete();
			return;
		}
		
		wait( 0.05 );
	}
	
	// player picked it up
	level notify( "player_got_m202" );
	level.player_picked_up_m202 = true;
	level.fake_weapon delete();
}


beat_3_hiding_door_progress() // -- WWILLIAMS: spawns out the last hiding door guy
{
	// endon
	
	
	// objects
	// trigger start TEMP
	start_trigger = GetEnt( "trigger_last_hiding_door", "targetname" );
	// spawner
	hider_spawner = GetEnt( "spawner_ridge_access_hider", "targetname" );
	// door model
	door_to_open = GetEnt( "model_hiding_door_progress", "targetname" );
	// script brush model
	door_collision = GetEnt( "sbrush_hiding_door_progress", "targetname" );
	// node
	node_to_fight_from = GetNode( "node_hiding_door_progress_guard", "targetname" );
	
	// link the collsion to the door
	door_collision LinkTo( door_to_open );
	
	flag_wait( "demo_line_5_clear" );
	
	spawn_manager_enable( "village_extra_hut_guys" );
	
	start_trigger wait_for_trigger_or_timeout( 1 );
	
	// spawn out the guy
	last_hider = simple_spawn_single( "spawner_ridge_access_hider" );
	last_hider.goalradius = 24;
	last_hider SetGoalNode( node_to_fight_from );
	// -- TODO objective change after this guy dies
	level thread beat_3_wait_for_door_area_clear();
	
	// open the door
	door_to_open NotSolid();
	door_collision NotSolid();
	
	door_to_open ConnectPaths();
	door_collision ConnectPaths();
	
	door_to_open RotateYaw( -160, 0.4 );	
	
}

beat_3_wait_for_door_area_clear()
{
	wait( 1 );
	waittill_ai_group_cleared( "village_hut_extra_guys" );
	
	level notify( "fight_the_mg" );
	flag_set( "ridge_mg_start" );
	
	level.hudson thread say_dialogue( "dock_is_clear" );
	level.barnes thread say_dialogue( "cut_through_hut", 1.3 );
	
	//Tuey Setting the music back to Village Fight
//	level thread switch_music_check();
	
	// move the squad into the building
	old_fc = GetEnt( "trig_to_last_door", "targetname" );
	old_fc delete();
	
	move_into_building_trigger = GetEnt( "trig_bottom_of_ridge_hill", "targetname" );

	players = get_players();
	move_into_building_trigger UseBy( players[0] );
	
	wait( 4 );
	level.barnes thread say_dialogue( "mason_over_here" );
}

switch_music_check()
{
	if(!IsDefined ( level.counterM))
	{
		level.counterM = 0;	
	}	
	if ( level.counterM == 0)
	{
		setmusicstate ("VILLAGE_FIGHT");	
	}
}

beat_3_squad_to_gate_door() // -- WWILLIAMS: moves the squad to the last door once the objectives are cleared
{
	// endon
	
	
	// objects
	// trigger
	move_to_the_door_trig = GetEnt( "trig_to_last_door", "targetname" );
	
	flag_wait( "demo_line_5_clear" );
	
	players = get_players();
	
	if( isdefined( move_to_the_door_trig ) )
	{
		move_to_the_door_trig UseBy( players[0] );
	}
	
//	setmusicstate ("IN_THE_JUNGLE");
	
	//battlechatter_off();
}
// ---------------------------------------------------------------------------------//
// -- BEAT 3 INTERIOR SECOND LINE -- //
// ---------------------------------------------------------------------------------//

// ---------------------------------------------------------------------------------//
// -- BEAT 3 VILLAGE SHORE -- //
// ---------------------------------------------------------------------------------//

beat_3_sampan_init() // -- WWILLIAMS: Setup the landing sampan
{
	// endon
	
	// objects
	// script model
	sampan_model = GetEnt( "model_sampan_for_landing", "targetname" );
	// spawner
	sampan_vc_spawner = GetEnt( "spawner_vc_on_landing_sampan", "targetname" );
	sampan_vc_spawner.count = 4;
	// trigger 
	start_trigger = GetEnt( "trigger_start_shoreline", "targetname" );
	// struct for anim
	anim_struct = getstruct( "anim_struct_shore_line", "targetname" );
	
	// setup the animanme on the sampan
	sampan_model.animname = "landing_sampan";
	
	trigger_wait( "trigger_fc_shore_line" );
	trigger_wait( "trigger_near_shore" );
	
	// move it to the right spot
	anim_struct anim_teleport( sampan_model, "sampan_landing" );
	
	// spawn out the vc and move them over to the sampan
	sampan_driver = simple_spawn_single( "spawner_vc_on_landing_sampan", ::hold_fire );
	if( isdefined( sampan_driver ) )
	{
		sampan_driver.animname = "sampan_driver";
		sampan_driver LinkTo( sampan_model, "tag_driver", ( 0, 0, 0 ), ( 0, 0, 0 ) );
		sampan_driver.ignoreme = 1;
		wait( 0.1 );
	}
	
	sampan_vc_1 = simple_spawn_single( "spawner_vc_on_landing_sampan", ::hold_fire );
	if( isdefined( sampan_vc_1 ) )
	{
		sampan_vc_1.animname = "sampan_vc_1";
		sampan_vc_1 LinkTo( sampan_model, "tag_passenger_1", ( 0, 0, 0 ), ( 0, 0, 0 ) );
		sampan_vc_1.ignoreme = 1;
		sampan_vc_1 AllowedStances( "crouch" );
		wait( 0.1 );
	}
	
	sampan_vc_2 = simple_spawn_single( "spawner_vc_on_landing_sampan", ::hold_fire );
	if( isdefined( sampan_vc_2 ) )
	{
		sampan_vc_2.animname = "sampan_vc_2";
		sampan_vc_2 LinkTo( sampan_model, "tag_passenger_2", ( 0, 0, 0 ), ( 0, 0, 0 ) );
		sampan_vc_2.ignoreme = 1;
		sampan_vc_2 AllowedStances( "crouch" );
		wait( 0.1 );
	}
	
	sampan_vc_3 = simple_spawn_single( "spawner_vc_on_landing_sampan", ::hold_fire );
	if( isdefined( sampan_vc_3 ) )
	{
		sampan_vc_3.animname = "sampan_vc_3";
		sampan_vc_3 LinkTo( sampan_model, "tag_passenger_3", ( 0, 0, 0 ), ( 0, 0, 0 ) );
		sampan_vc_3.ignoreme = 1;
	}
	// wait for the right moment
	//start_trigger waittill( "trigger" );
	
	// TODO: perfect this timing!
	
	if( isdefined( sampan_driver ) )
	{
		// play the animation on the driver and the sampan
		sampan_model thread anim_loop_aligned( sampan_driver, "driver_idle", "tag_origin_animate", "stop_driving" );
	}
	
	// thread the function that plays the anim for the sampan
	sampan_model beat_3_sampan_landing_anim( anim_struct );
	
	// turn the ai back on
	if( isdefined( sampan_vc_1 ) )
	{
		sampan_vc_1 resume_fire();
	}
	if( isdefined( sampan_vc_2 ) )
	{
		sampan_vc_2 resume_fire();
	}
	if( isdefined( sampan_vc_3 ) )
	{
		sampan_vc_3 resume_fire();
	}
	
	// get off after the landing
	level thread beat_3_sampan_landing( sampan_driver, sampan_vc_1, sampan_vc_2, sampan_vc_3, sampan_model );
}


#using_animtree( "creek_1" );
beat_3_sampan_landing_anim( anim_struct ) // -- WWILLIAMS: Plays the sampan landing animation on the sampan
{
	self UseAnimTree( #animtree );

	anim_struct anim_single_aligned( self, "sampan_landing" );
}

beat_3_sampan_landing( driver, vc_1, vc_2, vc_3, ent_to_play_anim_off ) // -- WWILLIAMS: starts teh sampan landing, after animation the ends the vc get off and the driver dies
{
	
	// objects
	// TODO: the nodes the AI run to
	
	if( isdefined( vc_3 ) && IsAlive( vc_3 ) )
	{
		// anim to get off
		vc_3 Unlink();
		vc_3 hold_fire();
		if( IsDefined( ent_to_play_anim_off ) )
		{	
			ent_to_play_anim_off anim_single_aligned( vc_3, "vc_3_shore_depart", "tag_passenger_3" );
		}
		if( isdefined( vc_3 ) && IsAlive( vc_3 ) )
		{
			vc_3 resume_fire();
			// vc_3 beat_3_run_from_landed_sampan( GetNode( "node_sampan_vc_1", "targetname" ) );
			vc_3.goalradius = 12;
			vc_3 SetGoalPos( vc_3.origin );
		}
	}
	
	if( isdefined( vc_2 ) && IsAlive( vc_2 ) )
	{
		// anim to get off
		vc_2 Unlink();
		vc_2 hold_fire();
		if( IsDefined( ent_to_play_anim_off ) )
		{
			ent_to_play_anim_off anim_single_aligned( vc_2, "vc_2_shore_depart", "tag_passenger_2" );
		}
		if( isdefined( vc_2 ) && IsAlive( vc_2 ) )
		{
			vc_2 AllowedStances( "stand", "crouch", "prone" );
			vc_2 resume_fire();
			vc_2 beat_3_run_from_landed_sampan( GetNode( "node_sampan_vc_2", "targetname" ) );
		}
	}
	
	if( isdefined( vc_1 ) && IsAlive( vc_1 ) )
	{
		// anim to get off
		vc_1 Unlink();
		vc_1 hold_fire();
		if( IsDefined( ent_to_play_anim_off ) )
		{	
			ent_to_play_anim_off anim_single_aligned( vc_1, "vc_1_shore_depart", "tag_passenger_1" );
		}
		if( isdefined( vc_1 ) && IsAlive( vc_1 ) )
		{
			vc_1 AllowedStances( "stand", "crouch", "prone" );
			vc_1 resume_fire();
			vc_1 beat_3_run_from_landed_sampan( GetNode( "node_sampan_vc_1", "targetname" ) );
		}
	}
	
	// TEMP: driver death animation
	if( isdefined( driver ) && IsAlive( driver ) )
	{
		driver notify( "stop_driving" );
		driver Unlink();
		if( IsDefined( ent_to_play_anim_off ) )
		{
			ent_to_play_anim_off anim_single_aligned( driver, "driver_death", "tag_driver" );
		}
		if( isdefined( driver ) && IsAlive( driver ) )
		{
			driver DoDamage( driver.health + 5000, driver.origin );
		}
	}
	
	if( isdefined( vc_3 ) && IsAlive( vc_3 ) )
	{
		vc_3 SetGoalNode( GetNode( "node_sampan_vc_1", "targetname" ) );
		vc_3.ignoreme = 0;
	}
}


beat_3_run_from_landed_sampan( node ) // -- WWILLIAMS: Run to node after getting off the sampan
{
	// endon
	self endon( "death" );
	
	self.ignoreme = 0;
	old_goalradius = self.goalradius;
	self.goalradius = 32;
	
	self SetGoalNode( node );
	
	self.goalradius = old_goalradius;
}


beat_3_attack_sampans_init() // -- WWILLIAMS: attack sampans that ride in
{
	level thread allow_sampans_to_attack_earlier();
	level waittill_either( "aa_gun_destroyed", "spawn_sampan_atackers_early" );
	
	// extra wait for the vehicle to spawn out // MAGIC NUMBERS ARE BAD! //
	wait( 0.2 );
	
	// vehicles
	array_thread( GetEntArray( "vehicle_sampan_attack", "targetname" ), ::beat_3_attack_sampan );
}

allow_sampans_to_attack_earlier()
{
	level endon( "reveal_island_aa" ); // once AA gun is revealed we no longer do this
	
	level waittill( "player_heading_to_dock" );
	
	level notify( "spawn_sampan_atackers_early" );
}


beat_3_attack_sampan() // -- WWILLIAMS: controls the sampan for the attack
{
	level thread custom_sampan_death( self );
	
	// endon
	self endon( "death" );
	
	// struct with the info
	// the struct has the same targetname as the first vehicle node
	// since the struct is grabbed with a different API than the vehicle node
	// I can have both targtted without a problem
	info_struct = getstruct( self.target, "targetname" );
	
	// make them invincible
	// self thread veh_magic_bullet_shield( true );

	// -- TODO: Should run a double check here in case I add more sampans...
	
	// objects
	// spawner // -- the struct's string gives me this info
	vc_spawner = GetEnt( info_struct.script_string, "targetname" );

	// start node
	vehicle_start = GetVehicleNode( self.target, "targetname" );
	// vc riding the boat
	vc_on_boat = [];
	// start trigger
	begin_attack_trigger = GetEnt( "trigger_start_shoreline", "script_noteworthy" );
	// -- test
	dude = undefined;
	
	// spawn out the guys and move them to the sampan
	vc_spawner.count = 2;
	for( i = 2; i < 4; i++ ) // only place the vc on tag_passenger2 and tag_passenger3, tag_passenger1 is too hidden
	{
		move_spawner_to_spot = self GetTagOrigin( "tag_passenger" + i );
		vc_spawner.origin = move_spawner_to_spot + ( 0, 0, 12 );
		dude = simple_spawn_single( vc_spawner );
		
		if( isdefined( dude ) )
		{
			// wait( 0.2 );
			dude hold_fire();
			// dude SetGoalPos( dude.origin );
			switch( self.script_parameters )
			{
				case "veh_node_sampan_attack_1": // this one should look to the front
					dude LinkTo( self, "tag_passenger" + i, ( 0, 0, 7 ), ( 0, 180, 0 ) );
					break;
					
				case "veh_node_sampan_attack_2": // these guys should be about 70 degrees to the right
					dude LinkTo( self, "tag_passenger" + i, ( 0, 0, 7 ), ( 0, 110, 0 ) );
					break;
						
				case "": // these guys should be 90 degrees to the right
					dude LinkTo( self, "tag_passenger" + i, ( 0, 0, 7 ), ( 0, RandomIntRange( 90, 95 ), 0 ) );
					break;
			}
			
			vc_on_boat = add_to_array( vc_on_boat, dude, false );
		}
	}
	
	self thread stop_sampan_when_friendlies_are_dead( vc_on_boat );
	
	// wait for the attack
	// begin_attack_trigger waittill( "trigger" );
	
	// turn teh AI back on and drive to shore
	array_thread( vc_on_boat, ::resume_fire );
	
	self thread go_path( vehicle_start );
	self waittill( "goal" );
	
	for( i = 0; i < vc_on_boat.size; i++ )
	{
		vc_on_boat[i] Unlink();
		vc_on_boat[i] SetGoalPos( vc_on_boat[i].origin );
	}
}

custom_sampan_death( sampan )
{
	while( 1 )
	{
		sampan waittill( "damage", damagetaken, attacker, dir, point, mod ); 
		if( isplayer( attacker ) && ( mod == "MOD_PROJECTILE" || mod == "MOD_PROJECTILE_SPLASH" ) )
		{
			//playfxontag( level._effect["custom_sampan_exp"], sampan, "tag_origin" );
			fx_linker = spawn( "script_model", sampan.origin );
			fx_linker.angles = ( 270, 180, 180 );
			fx_linker SetModel( "tag_origin" );
			fx_linker linkto( sampan );
			
			playfxontag( level._effect["aa_gun_explode"], fx_linker, "tag_origin" );
			playfxontag( level._effect["water_explode"], fx_linker, "tag_origin" );
			RadiusDamage( sampan.origin, 200, 500, 20, attacker );
			
			wait( 20 );
			fx_linker delete();
			return;
		}
	}
}

stop_sampan_when_friendlies_are_dead( vc_on_boat )
{
	self endon( "death" );
	
	while( 1 )
	{
		vc_on_boat = array_removeDead( vc_on_boat );
		if( vc_on_boat.size < 1 )
		{
			self setspeed( 0, 40 );
			return;
		}
		wait( 0.1 );
	}
}

beat_3_rathole_hatch_opens()
{
	flag_wait( "rat_hole_1_started" );
	level notify( "rat_hole_lid_01_start" );
	
	level thread dialog_rathole_1_opens();
	
	flag_wait( "demo_line_4_clear" );
	level notify( "rat_hole_lid_02_start" );
}

beat_3_rathole_grenade_close( trigger_name, sm_name, smoke_node_worthy, start_flag, kill_flag )
{
	// start once the rathole opens up
	flag_wait( start_flag );
	
	// wait for the damage trigger
	trigger_wait( trigger_name );
	
	// now kill the spawn manager
	level thread spawn_manager_kill( sm_name );
	
	// play smoke fx
	fx_origin = getent( smoke_node_worthy, "script_noteworthy" );
	playfx( level._effect["rathole_smoke"], fx_origin.origin );
	
	//SOUND - Shawn J
	playsoundatposition("evt_rathole_explo", fx_origin.origin);
	
	// also kill everyone still in the tunnel
	enemies = getaiarray( "axis" );
	trigger_inside = getent( trigger_name, "targetname" );
	for( i = 0; i < enemies.size; i++ )
	{
		if( enemies[i] istouching( trigger_inside ) )
		{
			enemies[i] ai_suicide();
		}
	}
	
	// set a flag so the game knows it's killed
	if( isdefined( kill_flag ) )
	{
		flag_set( kill_flag );
	}
}

village_aa_gun_guards()
{
	trigger_wait( "line_1_backup_manager_stop" );
	guards = simple_spawn( "b3_village_aa_guard" );
	//clear_entities( "b3_village_aa_guard" );
}

//handles aa gun destruction
village_aa_gun()
{
	aa_damage_trigger = GetEnt( "village_aa_damage_trig", "targetname" );
	while( 1 ) 
	{
		aa_damage_trigger waittill( "damage", amount, attacker, direction, point, dmg_type, modelName, tagName );
		if( isplayer( attacker ) && ( dmg_type == "MOD_PROJECTILE" || dmg_type == "MOD_PROJECTILE_SPLASH" 
			|| dmg_type == "MOD_EXPLOSIVE" || dmg_type == "MOD_EXPLOSIVE_SPLASH" 
			|| dmg_type == "MOD_GRENADE" || dmg_type == "MOD_GRENADE_SPLASH" ) )
		{
			break;
		}
		wait(.05);
	}
	level notify("overhang_start");
	exploder( 3003 );

}

beat_3_rpg_from_hut_window() // -- WWILLIAMS: RPG guy who fires at the MG, this should gge the player's attention
{
	trigger_wait( "trigger_fc_shore_line" );
	trigger_wait( "trigger_start_line_4" );
	
	rpg_waterhut_vc = 0;

	// spawn out the vc
	rpg_waterhut_vc = simple_spawn_single( "spawner_waterhut_rpg_dude" );
	rpg_waterhut_vc endon( "death" );
	rpg_waterhut_vc.goalradius = 24;
	rpg_waterhut_vc.targetname = "rpg_vc_waterhut";
	// makes sure the guy doesn't switch from the rpg
	rpg_waterhut_vc.a.allow_weapon_switch = false;
	// keeps the ammo count of the rpg up
	rpg_waterhut_vc thread beat_3_rpg_ammo_control();
	// set death anim
	rpg_waterhut_vc.deathanim = level.scr_anim[ "watergut_rpg" ][ "rpg_death" ];
	
	// send him to the right spot
	rpg_waterhut_node = GetNode( "node_waterhut_rpg_dude", "targetname" );
	rpg_waterhut_vc SetGoalNode( rpg_waterhut_node );
	rpg_waterhut_vc waittill( "goal" );
}

beat_3_waterhut_rpg_targets() // -- WWILLIAMS: targets normally or certain origins depending on the player
{
	// endon
	self endon( "death" );
	
	// level thread beat_3_failsafe_hut_explode( self );
	
	// objects
	// origins
	target_origin_array = GetEntArray( "origin_waterhut_rpg_targets", "targetname" );
	// turret
	shore_turret = GetEnt( "shore_turret", "targetname" );
	
	// set shoot notify
	old_shoot_notify = self.shoot_notify;
	self.shoot_notify = "waterhut_rpg_shot";
	
	// loop the targeting
	while( 1 ) 
	{
		wait( 1.0 );
	}
}

beat_3_failsafe_hut_explode( rpg_vc ) // -- WWILLIAMS: just in case the guy's rocket doesn't make it explode
{
	
	rpg_vc waittill( "death" );
	
	wait( 0.2 );
	
	// fire off the flag
	flag_set( "waterhut_start" );
	
}

beat_3_track_ai_line_4() // -- WWILLIAMS: tracks the ai group that makes up the shore enemies
{
	trigger_wait( "trigger_fc_shore_line" );
	
	level thread beat_3_empty_line_4_failsafe(); // failsafe for the guys to die during the calvary event
	
	// waittill_ai_group_count( "village_vc_area_shore", 0 );
	
	// level waittill( "huey_leaving" );
	flag_wait("calvary_scene_finished");
	// flag
	wait( 1 );
	flag_set( "demo_line_4_clear" );
}

beat_3_empty_line_4_failsafe() // -- WWILLIAMS: kills all the living ai when the hut explodes
{
	// endon
	level endon( "demo_line_4_clear" );
	
	// objects
	
	flag_wait( "waterhut_start" );
	
	// grab all the ai in line 4
	line_4_vc = get_ai_group_ai( "village_vc_area_shore" );
	
	// kill all of the line 4 enemies
	array_thread( line_4_vc, ::bloody_death, true, RandomInt( 7 ) );
	
}

beat_3_helicopter_redshirts() // -- WWILLIAMS
{
}
	
// ---------------------------------------------------------------------------------//
// -- BEAT 3 VILLAGE SHORE -- //
// ---------------------------------------------------------------------------------//

// ---------------------------------------------------------------------------------//
// -- BEAT 3 FIFTH LINE -- //
// ---------------------------------------------------------------------------------//

beat_3_track_line_5() // -- WWILLIAMS: tracks pre_5 and 5 line
{
	// endon
	
	// objects
	
	
	// wait for line 4 to end
	flag_wait( "demo_line_4_clear" );
	
	// level waittill( "huey_leaving" );
	
	// watch for the count of the pre_5 line	
	waittill_ai_group_count( "village_vc_line_pre_5", 0 );
	
	// set flag
	flag_set( "demo_line_pre_5_clear" );
	
}

beat_3_shore_roof() // -- WWILLIAMS: starts the guys who shoot down from a roof close to the water
{
	// starts this as soon as the AA gun is taken out
	//level waittill( "aa_gun_destroyed" );
	level waittill( "last_calvary_target_done" );
	wait( 1.5 );
	
	//flag_wait("calvary_scene_finished");
	//trigger_wait( "b3_close_to_roof" );

	// start spawn manager
	spawn_manager_enable( "shore_roof_manager_line_5" );
	
	// spawn out the hiding window guy
	line_5_window_shooter = simple_spawn_single( "spawner_line_5_hiding_window" );
	wait( 0.1 );
	line_5_window_shooter.grenadeammo = 0;
	wait( 2 );
	level.barnes say_dialogue( "targets_on_roof" );
}

beat_3_shore_hut_drop_init() // -- WWILLIAMS: Guy jumps down from the roof of a hut near the shore
{
	trigger_wait( "b3_close_to_drop_guy" );

	vc_hut_drop = simple_spawn_single( "spawner_shore_jump_down", ::beat_3_shore_hut_drop );
}


beat_3_shore_hut_drop() // -- WWILLIAMS: guy runs out from a hut roof, drops down to the ground then runs to cover 
{ 
	cover_node = GetNode( "node_shore_hut_drop_end", "targetname" );
	// struct
	anim_struct = getstruct( "anim_struct_shore_line", "targetname" );
	
	self.animname = "vc_shore_drop";
	
	// play anim
	self beat_3_reach_and_anim( "anim_struct_shore_line", "shore_drop_down" );
	
	old_goalradius = self.goalradius;
	self.goalradius = 32;
	
	self SetGoalNode( cover_node );
	self waittill( "goal" );
	
	self.goalradius = old_goalradius;
}

beat_3_shore_hut_drop_chickencoop() // -- WWILLIAMS: makes the chicken coop fall when the ai gets near it
{
	// endon
	
	
	// objects
	// trigger
	trigger_drop_chicken_coop = GetEnt( "trigger_drop_the_coop", "targetname" );
	
	// wait for line 4 to finish
	flag_wait( "demo_line_4_clear" );
	
	trigger_drop_chicken_coop waittill( "trigger" );
	
	level notify( "chickencoop_start" );
	
}

beat_3_line_5_rathole() // -- WWILLIAMS: starts the rathole and ends the line once it is destroyed
{
	// wait for pre 5 to finish
	flag_wait( "demo_line_4_clear" );
	
	// activate the rat hole
	level thread spawn_manager_enable( "rathole_manager_line_5" );
	level thread spawn_manager_enable( "line_5_active_manager" );
	
	// wait until all the enemies left over are dead
	waittill_ai_group_ai_count( "hut_rathole", 0 );
	
	// set line 5 clear flag
	flag_set( "demo_line_5_clear" );
	
	// clear the ridge guys
	level thread spawn_manager_kill( "line_5_active_manager" );
	line_5_active_vc = get_ai_group_ai( "ridge_line_5_active" );
	array_thread( line_5_active_vc, ::bloody_death, true, RandomInt( 3 ) );
}
// ---------------------------------------------------------------------------------//
// -- BEAT 3 FIFTH LINE -- //
// ---------------------------------------------------------------------------------//

// ---------------------------------------------------------------------------------//
// -- BEAT 3 MG RIDGE -- //
// ---------------------------------------------------------------------------------//

beat_3_track_mg_ridge_ai() // -- WWILLIAMS: tracks all the enemies on the ridge mg
{
	// objects
	// trigger
	move_squad_to_ridge_hut_trigger = GetEnt( "trigger_move_to_ridge_hut_2", "targetname" );
	
	level waittill( "move_up_mg_hill" );
	
	
	old_trigger = GetEnt( "trigger_move_to_ridge_hut", "targetname" );
	old_trigger delete();
	
	players = get_players();
	move_squad_to_ridge_hut_trigger UseBy( players[0] );
	//level thread force_ais_to_move_up( "move_up_interrupted" );
	
	flag_set( "ridge_mg_cleared" );
}


beat_3_tree_hugger_init() // -- WWILLIAMS: beat three tree slider when the player comes around
{
	// trigger
	start_trigger = GetEnt( "trigger_start_mg_ridge", "script_noteworthy" );
	// tree
	tree_model = GetEnt( "tree_to_slide_down", "targetname" );
	
	// rotate tree to show the animation better
	// TODO: find the best angle
	
	if( isdefined( tree_model ) )
	{
		tree_model.angles = ( 0, 0, 0 );
	
		start_trigger waittill( "trigger" );
	
		vc_tree_hugger = simple_spawn_single( "spawner_tree_hugger", ::beat_3_tree_hugger );
	}
}


beat_3_tree_hugger() // -- WWILLIAMS: guy slides down the tree, traverses over the fence, runs to cover on teh ridge
{
	// endon
	self endon( "death" );
	
	// save old radius
	old_radius = self.goalradius;
	self.goalradius = 32;
	
	// node
	end_node = GetNode( "node_tree_hugger", "targetname" );
	// struct
	// anim_struct = getstruct( "anim_struct_top_ridge_1", "targetname" );
	// script model
	tree_model = GetEnt( "tree_to_slide_down", "targetname" );
	
	if( isdefined( tree_model ) )
	{
		self.animname = "vc_tree_hugger";
		tree_model anim_single_aligned( self, "slide_down" );
		
		self SetGoalNode( end_node );
		self waittill( "goal" );
		
		self.goalradius = old_radius;
	}
}

beat_3_mg_gunner_init() // -- WWILLIAMS: spawns out the vc who uses the ridge mg
{
	trigger_wait( "trigger_start_mg_ridge", "script_noteworthy" );

	// spawn out the gunner
	vc_mg_gunner = simple_spawn_single( "spawner_vc_window_jumper", ::beat_3_ridge_mg_gunner );
	
	// if the mg is still alive, spawn the gunner
	if( !flag( "mg_eliminated" ) )
	{
		level thread beat_3_temp_mg_vc();
	}
	else
	{
		level notify( "mg_cleared" );
	}
}

beat_3_ridge_mg_gunner() // -- WWILLIAMS: plays window jump anim and sends guy to mg spot
{
	// endon
	self endon( "death" );
	
	// objects
	// struct
	anim_struct = getstruct( "anim_struct_top_ridge_1", "targetname" );
	// node
	// ridge_mg_node = GetNode( "node_ridge_mg", "targetname" );
	
	
	// vc setup
	self.animname = "vc_mg_gunner";
	self.goalradius = 32;
	
	// get ai to right position
	anim_struct anim_reach( self, "dive_for_mg" );
	
	// play anim
	anim_struct thread anim_single_aligned( self, "dive_for_mg" );
	
	//SOUND - Shawn J - temp barrels
	playsoundatposition ( "evt_mg_barrels", (0,0,0) );
	
	wait( 0.1 );
	level notify( "windowdive_start" );
}

mg_nag_lines()
{
	level endon( "mg_cleared" );
	
	wait( randomintrange( 8, 10 ) );
	level.hudson thread say_dialogue( "take_sob_down" );
	wait( randomintrange( 5, 8 ) );
	level.barnes thread say_dialogue( "got_eyes_on_him" );
}
	
beat_3_temp_mg_vc()
{
	// endon
	
	// objects
	// spawner
	mg_vc = simple_spawn_single( "spawner_vc_temp_mg" );
	mg_vc.old_health = mg_vc.health;
	mg_vc.health = 99999;
	
	battlechatter_off( "allies" );
	
	// wait( 0.1 );
	
	//mg_vc waittill( "goal" );
	mg_on_ridge = getent( "mg_on_ridge", "script_noteworthy" );
	mg_on_ridge thread maps\creek_1_amb::m60_turret_audio_thread();
	level thread handle_if_mg_is_killed_early( mg_vc, mg_on_ridge );
	mg_on_ridge waittill( "turretstatechange" );
	
	level.barnes thread say_dialogue( "charlie_on_mg" );
	
	level thread mg_nag_lines();
	
	level thread dialog_wait_for_mg_kill( mg_vc );

	// play anim for the mg reveal
	level notify( "mg_start" );
	mg_vc.health = mg_vc.old_health;
	exploder( 3006 );
	
	// TODO
	// clean up spawner
	
	mg_vc waittill( "death" );
	level notify( "mg_cleared" );
	clientnotify( "s4s" ); //AUDIO C. Ayers - Notifying the client that Event 4 is about to start, changing snd snapshot
}

handle_if_mg_is_killed_early( mg_vc, mg_on_ridge )
{
	mg_on_ridge endon( "turretstatechange" );
	mg_vc waittill( "death" );
	
	level notify( "mg_start" );
	exploder( 3006 );
	wait( 0.05 );
	level notify( "mg_cleared" );
	clientnotify( "s4s" );
}

beat_3_ridge_roof_awning() // -- WWILLIAMS: links the door so it is properly animated and sends the vc through his anims
{
	trigger_wait("trigger_start_mg_ridge", "script_noteworthy");
	vc_awning_attacker = simple_spawn_single("spawner_vc_ridge_awning");

	vc_awning_attacker endon( "death" );
	
	anim_struct = getstruct( "anim_struct_top_ridge_2", "targetname" );
	end_node = GetNode( "node_ridge_roof_attacker", "targetname" );
	
	// setup vc
	vc_awning_attacker.animname = "vc_ridge_roof";
	vc_awning_attacker.goalradius = 32;

	// set up door
	level.ridge_roof.animname = "vc_ridge_roof_door";
		
	level.ridge_roof ConnectPaths();
	level.ridge_roof NotSolid();
	
	anim_struct thread animate_ridge_roof_awning(level.ridge_roof);
	anim_struct anim_single_aligned( vc_awning_attacker, "ridge_roof_flap" );
	
	vc_awning_attacker SetGoalNode( end_node );
}

#using_animtree("creek_1");
animate_ridge_roof_awning(door)
{
	/#
		RecordEnt(door);
	#/

	door UseAnimTree(#animtree);
	self anim_single_aligned(door, "ridge_roof_flap");
}

beat_3_ridge_fight() // -- WWILLIAMS: Starts the flood spawners for the ridge fight
{
	// endon
	
	
	// objects
	// trigger
	start_trigger = GetEnt( "trigger_start_mg_ridge", "script_noteworthy" );
	stop_trigger = GetEnt( "trig_stop_ridge_spawning", "targetname" );
	
	start_trigger waittill( "trigger" );
	
	// start spawn manager
	spawn_manager_enable( "ridge_mg_manager" );
	
	stop_trigger waittill( "trigger" );
	flag_set( "ridge_spawning_stopped" );
	
	spawn_manager_disable( "ridge_mg_manager" );
	
}

// ---------------------------------------------------------------------------------//
// -- BEAT 3 MG RIDGE -- //
// ---------------------------------------------------------------------------------//

// ---------------------------------------------------------------------------------//
// -- BEAT 3 LINE 6 -- //
// ---------------------------------------------------------------------------------//

beat_3_track_line_6() // -- WWILLIAMS: makes sure all teh ai for line 6 die before continuing
{
	// endon
	
	// objects 
	
	flag_wait( "ridge_mg_cleared" );
	
	level thread beat_3_line_6_failsafe();
	
	waittill_ai_group_count( "line_6_vc", 0 );
	
	flag_set( "demo_line_6_clear" );
	
	//autosave_by_name( "creek0_dl6c" );
}

beat_3_line_6_failsafe() // -- WWILLIAMS: kills all the guys in line 6 in case the player can't
{
	// endon
	level endon( "demo_line_6_clear" );
	
	// grab all the ai
	line_6_vc = get_ai_group_ai( "line_6_vc" );
	
	for( i = 0; i < line_6_vc.size; i++ )
	{
		line_6_vc[i] thread bloody_death( true );
		wait( 1 );
	}
}


beat_3_populate_line_6() // -- WWILLIAMS: spawns out th last few vc who tries to stop the squad
{
	level thread spawn_flavor_vc();
	
	trigger_wait( "trigger_start_line_6" );
	
	player = get_players()[0];
	player say_dialogue( "tunnel_up_ahead" );
	level.barnes say_dialogue( "i_see_it" );
	
	// start the spawn manager for the core group
	spawn_manager_enable( "manager_line_6_core" );
	
	level thread dialog_rat_tunnel_vcs();
	
	waittill_spawn_manager_complete( "manager_line_6_core" );
}

spawn_flavor_vc()
{
	trigger_wait( "trigger_move_to_ridge_hut_2" );
	vc_line_6_flavor = simple_spawn_single( "spawner_line_6_flavor", ::beat_3_line_6_flavor_fighter );
	//vc_line_6_flavor.pacifist = 1;
	vc_line_6_flavor thread beat_3_on_goal_reset_ignore();
}

beat_3_on_goal_reset_ignore() // -- WWILLIAMS: using this to make sure he doesn't get stupid in case he hits goal
{
	self endon( "death" );
	
	self waittill( "goal" );
	
	//self.pacifist = 0;
}

beat_3_line_6_flavor_fighter() // -- WWILLIAMS: controls the single vc that runs out in front of the player for line 6
{
	// endon
	self endon( "death" );
	
	// objects
	// node
	line_6_flavor_end_node = GetNode( "node_line_6_flavor_dest", "targetname" );
	
	// setup self
	self.goalradius = 24;
	self.ignoreme = 1;
	
	self SetGoalNode( line_6_flavor_end_node );
	self waittill( "goal" );
	
	self.ignoreme = 0;
	
	
}

beat_3_additional_ais_island()
{
	// island ais are being spawned
	trigger_wait( "trigger_fc_shore_line" );
	
	wait( 7 );
	
	// when the number of AIs drop, we enable this
//	waittill_ai_group_count( "village_vc_area_shore", 2 );
	spawn_manager_enable( "island_reinforcement_manager" );

	// after the choppers come, disable the spawner and kill them all
	flag_wait( "waterhut_start" );
	
	spawn_manager_disable( "island_reinforcement_manager" );
	guys = getentarray( "extra_island_guys", "script_noteworthy" );
	for( i = 0; i < guys.size; i++ )
	{
		guys[i] ai_suicide();
	}
}

// ---------------------------------------------------------------------------------//
// -- BEAT 3 LINE 6 -- //
// ---------------------------------------------------------------------------------//


// ---------------------------------------------------------------------------------//
// -- BEAT 3 OBJECTIVES -- //
// ---------------------------------------------------------------------------------//

beat_3_objectives()
{
	player = get_players()[0];
	
	// clear village
	Objective_Add( 4, "current", &"CREEK_1_OBJ_B2_2" );
	Objective_AdditionalCurrent( 2 );
	//autosave_by_name("creek0_b3o_0");
	
	// when player gets the plunger, change objective to use the plunger
	flag_wait( "plunger_to_player" );
	Objective_Add( 5, "current", &"CREEK_1_TRIGGER_CHARGES" );
	Objective_AdditionalCurrent( 2, 4 );
	
	// when player uses the plunger, change objective back to the original
	flag_wait( "ambush_success" );
	Objective_State( 5, "done" );
	Objective_Delete( 5 );
	autosave_by_name("creek0_b3o_1");
	
	// clear the area
	flag_wait( "squad_at_aa_village" );
	Objective_Set3D( 2, false );
	pos_struct = getstruct( "b3_secure_3", "targetname" );
	Objective_Add( 5, "current", &"CREEK_1_DESTROY_RAT", pos_struct.origin );
	Objective_Set3D( 5, true, "yellow" );
	Objective_AdditionalCurrent( 2, 4 );
	
	wait( 3 );

	waittill_zone_is_cleared( "b3_zone_3" );
	Objective_State( 5, "done" );
	Objective_Delete( 5 );
	
	// village is also cleared now
	Objective_State( 4, "done" );
	Objective_Delete( 4 );
	Objective_Add( 4, "current", &"CREEK_1_REINFORCE", ( -24846, 35120, -26 ) );
	Objective_Set3D( 4, true, "yellow" );
	Objective_AdditionalCurrent( 2 );
	
	flag_set( "village_aa_area_secured" );
	
	level thread spawn_ais_at_dock_for_aa_kill();
	
	autosave_by_name("creek0_b3o_2");
	
	level thread wait_for_player_to_reach_shore();
	level thread wait_for_player_to_shoot_aa();
	level waittill( "player_at_shore_aa" );
	
	// wait for the m202 guy to show up, then add objective to get it
	flag_set( "reveal_island_aa" );
	
	if( !flag( "aa_gunner_shot" ) )
	{
		// Added new M202 here

		level thread dialog_m202_redshirt();
		level thread dialog_river_aa_gun();
		//wait( 3 );
		level notify( "ready_to_spawn_m202" );
		
		level thread objective_aa_gun();
		
		level waittill( "objective_aa_gun_complete" );
	
		autosave_by_name("creek0_b3o_aags");
	}
	else
	{
		Objective_State( 4, "done" );
		Objective_Set3D( 4, false ); // disable old objective
		Objective_Delete( 4 );
		aa_gun_obj_taken_out();
		
		// drop an m202 at this spot
		m202 = spawn( "weapon_m202_flash_magic_bullet_sp", ( -24488, 34613, -10 ), 1 );
	}
	
	// once the calvary is done. start the last rathole
	flag_wait( "demo_line_4_clear" ); 
	obj_struct = getstruct( "b3_secure_7", "targetname" );
	Objective_Add( 4, "current", &"CREEK_1_OBJ_CLEAR_N", obj_struct.origin );
	Objective_Set3D( 4, true, "yellow" );
	
	//autosave_by_name("creek0_b3o_3");

	// the last guy runs out of the hut
	flag_wait( "demo_line_5_clear" ); 
	//secure_struct = getstruct( "b3_secure_7", "targetname" );
	//Objective_Position( obj_num, secure_struct.origin );
	
	autosave_by_name("creek0_b3o_4");

	// attack the hill
	trigger_wait( "b3_enter_single_hut" );
	Objective_Position( 4, ( -23489, 33315, 153.1 ) );
	
	//secure_struct = getstruct( "b3_secure_8", "targetname" );
	
	// once MG is introduced, destroy it
	level waittill("mg_start");
	
	if( !flag( "mg_eliminated" ) )
	{
		mg_struct = getstruct( "b3_target_2", "targetname" );
		Objective_Position( 4, mg_struct.origin );
	
		// MG is eliminated
		level waittill( "mg_cleared" );
		autosave_by_name("creek0_b3o_mge");
	}
	Objective_Position( 4, level.barnes );
	Objective_Set3D( 4, true, "yellow", &"CREEK_1_FOLLOW" );
	
	battlechatter_on( "allies" );
	
	stop_trigger = GetEnt( "trig_stop_ridge_spawning", "targetname" );
	stop_trigger useby( player );
	
	level notify( "move_up_mg_hill" );
	level thread kill_remaining_hill_enemies();
	
	level thread spawn_ridge_filler_enemies();
	
	// end event
	flag_wait( "demo_line_6_clear" );
	
	Objective_State( 4, "done" );
	Objective_Set3D( 4, false );
	Objective_Delete( 4 );
}

wait_for_player_to_reach_shore()
{
	// SUPER HACK!
	level.m202_anim_version = "standard";
	
	player = get_players()[0];
	near_shore_trigger = getent( "trigger_near_shore", "targetname" );
	fast_spawn_trigger = getent( "m202_spawn_fast", "targetname" );
	normal_spawn_trigger = getent( "m202_spawn_normal", "targetname" );
	
	if( player istouching( fast_spawn_trigger ) )
	{
		// wait to leave this trigger
		while( player istouching( fast_spawn_trigger ) )
		{
			wait( 0.05 );
		}
		if( player istouching( normal_spawn_trigger ) )
		{
			// do fast anim
			level.m202_anim_version = "fast";
		}
		else
		{
			while( 1 )
			{
				if( player istouching( near_shore_trigger ) && player istouching( fast_spawn_trigger ) )
				{
					level.m202_anim_version = "fast";
					break;
				}
				else if( player istouching( normal_spawn_trigger ) && player istouching( fast_spawn_trigger ) == false )
				{
					level.m202_anim_version = "run_death";
					break;
				}
				wait( 0.05 );
			}
			
		}
	}
	else if( player istouching( normal_spawn_trigger ) )
	{
		level.m202_anim_version = "normal";
		wait( 0.05 );
	}
	else
	{
		while( 1 )
		{
			if( player istouching( near_shore_trigger ) && player istouching( fast_spawn_trigger ) )
			{
				level.m202_anim_version = "fast";
				break;
			}
			else if( player istouching( normal_spawn_trigger ) && player istouching( fast_spawn_trigger ) == false )
			{
				level.m202_anim_version = "run_death";
				break;
			}
			wait( 0.05 );
		}
	}
	
	//trigger_wait( "trigger_approach_shore" );
	level notify( "player_at_shore_aa" );
}

wait_for_player_to_shoot_aa()
{
	while( !flag( "aa_gunner_shot" ) )
	{
		wait( 0.05 );
	}
	level notify( "player_at_shore_aa" );
}
	
objective_aa_gun()
{
		// wait for the m202 guy to show up, then add objective to get it
		level waittill_any_notify( "player_should_get_m202", "aa_gunner_shot", "player_picks_up_m202_early" );
		Objective_State( 4, "done" );
		Objective_Set3D( 4, false ); // disable old objective
		Objective_Delete( 4 );
		//autosave_by_name("creek0_oaag");
		
		if( flag( "aa_gunner_shot" ) )
		{
			aa_gun_obj_taken_out();
			return;
		}
		else if( flag( "player_picks_up_m202_early" ) )
		{
			// do nothing
		}
		else
		{
			if( isdefined( level.fake_weapon ) )
			{
				pos = ( level.fake_weapon.origin + level.fake_weapon GetTagOrigin( "tag_flash" ) ) * 0.5;
				Objective_Add( 4, "current", &"CREEK_1_GET_M202", pos );
			}
			else
			{
				//iprintlnbold( "HACK" );
				Objective_Add( 4, "current", &"CREEK_1_GET_M202", ( -24689, 35142, 55 ) );
			}
			Objective_Set3D( 4, true, "yellow" );
			Objective_AdditionalCurrent( 2 );
			
			// once the player gets it make him target the AA gun
			level waittill_either( "player_got_m202", "aa_gunner_shot" );
			Objective_State( 4, "done" );
			Objective_Delete( 4 );
		}
		
		if( flag( "aa_gunner_shot" ) )
		{
			aa_gun_obj_taken_out();
			return;
		}
		else
		{
			aa_struct = getstruct( "b3_target_1", "targetname" );
			Objective_Position( 2, aa_struct.origin );
			Objective_Set3D( 2, true, "yellow", &"CREEK_1_TARGET" );
		}
	
	// AA gun is eliminated, simply wait for calvary to come over
	level waittill_either( "aa_gun_destroyed", "aa_gunner_shot" );
	aa_gun_obj_taken_out();
	
	level notify ("aa_gun_destroyed");
}


waittill_any_notify( string1, string2, string3 )
{
	if ( IsDefined( string2 ) )
	{
		self endon( string2 );
	}

	if ( IsDefined( string3 ) )
	{
		self endon( string3 );
	}

	self waittill( string1 );
}

aa_gun_obj_taken_out()
{
	Objective_Set3D( 2, false );
	Objective_State( 2, "done" );
	
	player = get_players()[0];
	player say_dialogue( "got_it!" );
	
	level notify( "objective_aa_gun_complete" );
}

spawn_ridge_filler_enemies()
{
	spawn_manager_enable( "mg_hut_filler_ai" );
	trigger_wait( "trigger_start_line_6" );
	spawn_manager_disable( "mg_hut_filler_ai" );

	// kill remaining enemies from this group
	enemies = getentarray( "mg_hut_filler_guys_ai", "targetname" );
	for( i = 0; i < enemies.size; i++ )
	{
		enemies[i] bloody_death( true );
		wait( 0.5 );
	}
}

kill_remaining_hill_enemies()
{
	enemies = getaiarray( "axis" );
	trigger = getent( "mg_area_clearing", "targetname" );
	for( i = 0; i < enemies.size; i++ )
	{
		if( enemies[i] istouching( trigger ) )
		{
			enemies[i] ai_suicide();
			wait( 0.2 );
		}
	}
}



// ---------------------------------------------------------------------------------//
// -- BEAT 3 OBJECTIVES -- //
// ---------------------------------------------------------------------------------//

// ---------------------------------------------------------------------------------
// -- BEAT 3 UTILITY SCRIPTS -- //
// ---------------------------------------------------------------------------------

// -- WWILLIAMS: Quick util that takes in strings to play anims on the AI
beat_3_reach_and_anim( str_anim_struct, str_animation )
{
	// endon
	self endon( "death" );
	
	// objects
	// struct for anim
	anim_struct = getstruct( str_anim_struct, "targetname" );
	
	// setup ai
	// self.animname = str_animname; // -- Setup animname outside of this function, for customnotetracks to be setup
	old_goalradius = self.goalradius;
	self.goalradius = 32;
	
	if( IsDefined( self.animname ) )
	{
		anim_struct anim_reach( self, str_animation );
		anim_struct anim_single_aligned( self, str_animation );
	}
	else
	{
		//IPrintLnBold( "Trying to use reach_and_anim with no animname!" );
	}

	self.goalradius = old_goalradius;
}

beat_3_rpg_ammo_control() // -- WWILLIAMS: keeps an ai with a rpg well stocked
{
	self endon( "death" );
	
	while( IsAlive( self ) )
	{
		if( self.a.rockets < 5 )
		{
			self.a.rockets = 25;
		}
		else
		{
			wait( 2.0 );
		}
	}
}

village_livestock_setup() // WWILLIAMS: Alex's livestock setup for the village
{
	chickens = getentarray( "b2_chicken_group_1", "targetname" );
	for( i = 0; i < chickens.size; i++ )
	{
		chickens[i].no_jump = true;
		chickens[i] thread maps\creek_1_livestock::start_critter_anims( "chicken", true, 80, "b2_chicken_group_1_trigger" );
	}

	chickens2 = getentarray( "b2_chicken_group_2", "targetname" );
	for( i = 0; i < chickens2.size; i++ )
	{
		chickens2[i] thread maps\creek_1_livestock::start_critter_anims( "chicken", true, 120, "b2_chicken_group_2_trigger", undefined, undefined, "village_alerted" );
	}

	chickens3 = getentarray( "b2_chicken_group_3a", "targetname" );
	for( i = 0; i < chickens3.size; i++ )
	{
		chickens3[i] thread maps\creek_1_livestock::start_critter_anims( "chicken", true, 150, "b2_chicken_group_3a_trigger", true );
	}

	chickens3b = getentarray( "b2_chicken_group_3", "targetname" );
	for( i = 0; i < chickens3b.size; i++ )
	{
		chickens3b[i] thread maps\creek_1_livestock::start_critter_anims( "chicken", true, 140, "b2_chicken_group_3b_trigger", true );
	}


	pigs = getentarray( "b2_pigs_group_1", "targetname" );
	for( i = 0; i < pigs.size; i++ )
	{
		pigs[i] thread maps\creek_1_livestock::start_critter_anims( "pig", true, 90, "b2_pigs_group_1_trigger", undefined, undefined, "village_alerted" );
	}

	pigs2 = getentarray( "b2_pigs_group_2", "targetname" );
	for( i = 0; i < pigs2.size; i++ )
	{
		pigs2[i] thread maps\creek_1_livestock::start_critter_anims( "pig", true, 90, "village_pigs_walk_trigger", true );
	}
	
	level thread animate_crow_fly();
}

animate_crow_fly()
{
	trigger_wait( "b2_chicken_group_1_trigger" );
	level notify( "fly_away_1" );
	level notify( "fly_away_2" );
}

audio_vc_alerted()
{
	flag_wait( "village_alerted" );
	
	enemies = getaiarray( "axis" );
	for( i = 0; i < enemies.size; i++ )
	{
		enemies[i] PlaySound( "vox_vc_alerted" );
	}
}

hold_fire_debug( text )
{
	while( self.ignoreall == true )
	{
		wait( 0.05 );
	}
	//iprintlnbold( text );
}

get_shot_to_death( guy )
{
	MagicBullet( "ak47_sp", ( -26037, 35046, 26 ), guy GetTagOrigin( "j_head" ) );
	guy thread bloody_death_fx( "j_head", undefined );
	guy bloody_death( false );
}

// -- COMPLETELY STOLEN FROM GUZZO -- //
// Fake death
// self = the guy getting worked
bloody_death( die, delay )
{
	self endon( "death" );

	if( !is_active_ai( self ) )
	{
		return;
	}

	if( !isdefined( die ) )
	{
		die = true;	
	}

	if( IsDefined( self.bloody_death ) && self.bloody_death )
	{
		return;
	}

	self.bloody_death = true;

	if( IsDefined( delay ) )
	{
		wait( RandomFloat( delay ) );
	}

	if( !IsDefined( self ) )
	{
		return;	
	}

	tags = [];
	tags[0] = "j_hip_le";
	tags[1] = "j_hip_ri";
	tags[2] = "j_head";
	tags[3] = "j_spine4";
	tags[4] = "j_elbow_le";
	tags[5] = "j_elbow_ri";
	tags[6] = "j_clavicle_le";
	tags[7] = "j_clavicle_ri";
	
	for( i = 0; i < 2; i++ )
	{
		random = RandomIntRange( 0, tags.size );
		//vec = self GetTagOrigin( tags[random] );
		if( is_mature() )
		{
			self thread bloody_death_fx( tags[random], undefined );
		}
		wait( RandomFloat( 0.1 ) );
	}

	if( die && IsDefined( self ) && self.health )
	{
		self DoDamage( self.health + 150, self.origin );
	}
}

///////////////////
//
// for use with bloody_death()
//
///////////////////////////////

is_active_ai( suspect )
{
	if( IsDefined( suspect ) && IsSentient( suspect ) && IsAlive( suspect ) )
	{
		return true;
	}
	else
	{
		return false;
	}
}
// -- COMPLETELY STOLEN FROM GUZZO -- //


// self = the AI on which we're playing fx
bloody_death_fx( tag, fxName ) 
{ 
	if( !IsDefined( fxName ) )
	{
		fxName = level._effect["flesh_hit"];
	}

	PlayFxOnTag( fxName, self, tag );
}
// ---------------------------------------------------------------------------------
// -- BEAT 3 UTILITY SCRIPTS -- //
// ---------------------------------------------------------------------------------

m202_on_mg()
{
	// player is allowed to kill mg using M202 after hitting this trigger
	trigger_wait( "b3_enter_single_hut" );
	
	level.barnes say_dialogue( "rest_of_village" );
	
	// at this point, 2 things can happen:
	// 1. player kills mg before its reveal. We will play the reveal anim, plus the fx
	//    and make sure the gunner will not spawn later
	// 2. Player kills mg after reveal. We will play a new collapse anim and kill the gunner (if alive)
	
	damage_trigger = getent( "hill_mg_explosion_trigger", "targetname" );
	fx_struct = getstruct( damage_trigger.target, "targetname" );
	
	// this handles option 1. The thread is killed at the mg reveal
	level thread wait_for_m202_to_hit_mg( damage_trigger, fx_struct, "mg_reveal_finishes", "mg_start" );
	
	level waittill("mg_start");
	
	level thread player_m202_aim_dialog();
	
	// option 2, if needed
	if( !flag( "mg_eliminated" ) )
	{
		level thread wait_for_m202_to_hit_mg_later( damage_trigger, fx_struct, "mg_cleared", "mgexplode_start" );
	}
}

player_m202_aim_dialog()
{
	// wait for the player to aim at the mg with m202 and ADS
	player = get_players()[0];
	while( 1 )
	{
		trigger_wait( "player_aim_at_mg" );
		current_weapon = player GetCurrentWeapon();
		if( ( current_weapon == "m202_flash_sp" || current_weapon == "m202_flash_magic_bullet_sp" ) && player AdsButtonPressed() && player AttackButtonPressed() )
		{
			break;
		}
		wait( 0.05 );
	}

	if( !flag( "mg_eliminated" ) )
	{
		player = get_players()[0];
		player say_dialogue( "hes_mine" );
	}
}

wait_for_m202_to_hit_mg( damage_trigger, fx_struct, end_msg, anim_notify )
{
	level endon( end_msg );
	
	// wait for the rocket
	while( 1 )
	{		
		damage_trigger waittill( "damage", int_amount, ent_attacker, vec_direction, P, dmg_type );
		if( dmg_type == "MOD_PROJECTILE" || dmg_type == "MOD_PROJECTILE_SPLASH" )
		{
				break;
		}
	}
	
	flag_set( "mg_eliminated" );
	flag_set( "mg_eliminated_by_m202" );
	
	// ply fx
	//playfx( level._effect["fx_explosion_satchel_hut_core"], fx_struct.origin );
	exploder( 3007 );
	player = get_players()[0];
	player giveachievement_wrapper( "SP_LVL_CREEK1_DESTROY_MG" );
	//playfx( level._effect["fx_exp_mg_nest"], ( -23126, 33235.2, 257.125 ) );
	
	// delete sandbags
	sandbags = getentarray( "mg_sandbags", "targetname" );
	for( i = 0; i < sandbags.size; i++ )
	{
		sandbags[i] delete();
	}
	
	// play the anim
	level notify( anim_notify );
	
	// do some damage around
	player = get_players()[0];
	RadiusDamage( fx_struct.origin, 512, 1000, 100, player );
}

wait_for_m202_to_hit_mg_later( damage_trigger, fx_struct, end_msg, anim_notify )
{
	// wait for the rocket
	while( 1 )
	{		
		damage_trigger waittill( "damage", int_amount, ent_attacker, vec_direction, P, dmg_type );
		if( dmg_type == "MOD_PROJECTILE" || dmg_type == "MOD_PROJECTILE_SPLASH" )
		{
				break;
		}
	}
	
	if( flag( "mg_eliminated_by_m202" ) )
	{
		return;
	}
	
	flag_set( "mg_eliminated" );
	flag_set( "mg_eliminated_by_m202" );
	
	// ply fx
	//playfx( level._effect["fx_explosion_satchel_hut_core"], fx_struct.origin );
	exploder( 3007 );
	player = get_players()[0];
	player giveachievement_wrapper( "SP_LVL_CREEK1_DESTROY_MG" );
	//playfx( level._effect["fx_exp_mg_nest"], ( -23126, 33235.2, 257.125 ) );
	
	// delete sandbags
	sandbags = getentarray( "mg_sandbags", "targetname" );
	for( i = 0; i < sandbags.size; i++ )
	{
		sandbags[i] delete();
	}
	
	// play the anim
	level notify( anim_notify );
	
	// do some damage around
	player = get_players()[0];
	RadiusDamage( fx_struct.origin, 512, 1000, 100, player );
}

move_reznov_to_ridge()
{
	flag_wait( "demo_line_5_clear" );
	trigger_wait( "hut_entrance_cleared" );
	node = getnode( "mg_reznov_node", "targetname" );
	level.reznov forceteleport( node.origin, node.angles );
	
	destination_node = getnode( "mg_reznov_window_node", "targetname" );
	level.reznov SetGoalNode( destination_node );
	level.reznov resume_fire();
	
	//trigger_wait( "trigger_start_mg_ridge", "script_noteworthy" );
	wait( 1.5 );
	
	player = get_players()[0];
	add_dialogue_line( "Mason", "Told you to stay back" );
	PlaySoundAtPosition( level.scr_sound["mason"]["told_you_back"], player.origin );
}

// VCs chatting when the player is setting explosive
dialog_vc_intro()
{
	level endon( "player_presses_plunger" );
	level thread delete_vo_origin( "player_presses_plunger" );
	
	// wait for the player to get a little closer
	trigger_wait( "trigger_start_redshirts_for_ambush" );
	
	// let's play the sound in space, near the player
	sound_pos = ( -24103, 35936, 11.5 ); // temp position
	
	level.vo_origin = spawn( "script_origin", sound_pos );
	level.vo_origin.animname = "generic";
	
	wait( 2 );
	level.vo_origin say_dialogue( "village_vc_line1" );
	wait( 1 );
	level.vo_origin say_dialogue( "village_vc_line2" );
	wait( 1 );
	level.vo_origin say_dialogue( "village_vc_line3" );
	wait( 1 );
	level.vo_origin say_dialogue( "village_vc_line4" );
	wait( 1 );
	level.vo_origin say_dialogue( "village_vc_line5" );
}

delete_vo_origin( end_msg )
{
	level waittill( end_msg );
	if( isdefined( level.vo_origin ) )
	{
		level.vo_origin delete();
	}
}

dialog_river_aa_gun()
{
	level endon( "aa_gun_destroyed" );
	level endon( "aa_gunner_shot" );
	
	level.barnes thread say_dialogue( "thats_the_gun" );
	
	wait( 4 );
	add_dialogue_line( "Mason", "On my way" );
	player = get_players()[0];
	player say_dialogue( "on_my_way" );

	wait( 1 );
	
	// remind the player where the gun is
	level.hudson say_dialogue( "behind_that_hut" );
	wait( 1 );
	level.hudson say_dialogue( "charles_dont_let" );
}

dialog_m202_redshirt()
{
	level endon( "aa_gun_destroyed" );
	level endon( "aa_gunner_shot" );
	
	level.hudson thread say_dialogue( "need_more_firepwr" );
	
	level thread dialog_remind_player_m202( "player_got_m202" );
	
	level.hudson thread say_dialogue( "can_you_get_m202" );
	
	level waittill( "player_got_m202" );
	add_dialogue_line( "Mason", "Let's hit it" );
	player = get_players()[0];
	player say_dialogue( "lets_hit_it" );
}

dialog_remind_player_m202( end_msg )
{
	level endon( "aa_gun_destroyed" );
	level endon( "aa_gunner_shot" );
	
	level endon( end_msg );
	
	wait( 4 );
	
	while( 1 )
	{
		wait( randomfloat( 3 ) + 5 );
		
		if( player_can_use_m202() )
		{
			chance = randomint( 100 );
			if( chance < 50 )
			{
				level.hudson thread say_dialogue( "use_m202_v1" );
			}
			else
			{
				level.hudson thread say_dialogue( "use_m202_v2" );
			}
		}
		else
		{
			return;
		}
	}
}

player_can_use_m202()
{
	if( !isdefined( level.player_picked_up_m202 ) )
	{
		return true;
	}
	
	// if player has M202 and have ammo, return true
	player = get_players()[0];
	weapon_inventory = player GetWeaponsList();
	for( i = 0; i < weapon_inventory.size; i++ )
	{
		if( weapon_inventory[i] == "m202_flash_magic_bullet_sp" )
		{
			ammo_count = 0;
			ammo_count += player GetWeaponAmmoClip( "m202_flash_magic_bullet_sp" );
			ammo_count += player GetWeaponAmmoStock( "m202_flash_magic_bullet_sp" );
			if( ammo_count > 0 )
			{
				return true;
			}
		}
	}
	
	// if there are M202 on the ground with ammo, return true
	array_of_items = GetItemArray();
	for(i = 0; i < array_of_items.size; i++)
	{
		if( array_of_items[i].classname == "weapon_m202_flash_magic_bullet_sp" )
		{
			found_item = true;
			return true;
		}
	}
	
	return false;
}

dialog_wait_for_mg_kill( mg_vc )
{
	level thread dialog_mg_killed( mg_vc );
	mg_vc endon( "death" );
	
	wait( 7 );
	//level.hudson thread say_dialogue( "take_sob_down" );
}

dialog_mg_killed( mg_vc )
{
	mg_vc waittill( "death" );
	
	wait( 1 );
	level.barnes thread say_dialogue( "push_through" );
	
	wait( 3 );
	level.barnes thread say_dialogue( "make_sure_shack" );
}

dialog_rat_tunnel_vcs()
{
	// let's play the sound in space, near the player
	sound_pos = ( -21928, 33864, 189.4 ); // temp position
	
	if( !isdefined( level.temp_vo_pos ) )
	{
		level.temp_vo_pos = spawn( "script_origin", sound_pos );
	}
	else
	{
		level.temp_vo_pos.origin = sound_pos;
	}
	
	level.barnes thread say_dialogue( "9_o_clock" );
	wait( 1 );
	
	level.temp_vo_pos.animname = "generic";
	level.temp_vo_pos say_dialogue( "rathole_entran_1" );
	wait( 1 );
	level.temp_vo_pos say_dialogue( "rathole_entran_2" );
}

dialog_additional_lines_w_timeout( end_msg )
{
	level endon( end_msg );
	
	wait( 4 );
	level.hudson thread say_dialogue( "keep_head_down" );
	wait( 4 );
	level.barnes thread say_dialogue( "lets_go_on_me" );
}

dialog_additional_lines_w_timeout_2()
{
	level endon( "reveal_island_aa" );

	wait( 12 );
	level.barnes thread say_dialogue( "charlies_on_right" );
}

spawn_ais_at_dock_for_aa_kill()
{
	guys = simple_spawn( "village_aa_kill_redshirt" );
}

dialog_rathole_1_opens()
{
	level.barnes thread say_dialogue( "rathole_ahead" );
	wait( 3 );
	level.barnes thread say_dialogue( "get_a_nade_in_v1" );
}

spawn_swift()
{
	level thread wait_for_spawn_trigger_swift();
	level thread wait_for_spawn_notify_swift();
	level waittill( "ready_to_spawn_swift" );
	
	level.swift = simple_spawn_single( "swift" );
	level.swift thread magic_bullet_shield();
	level.swift.animname = "swift";
	level.swift.name = "Swift";
}

wait_for_spawn_trigger_swift()
{
	trigger_wait( "spawn_swift" );
	level notify( "ready_to_spawn_swift" );
}

wait_for_spawn_notify_swift()
{
	flag_wait( "demo_line_6_clear" );
	level notify( "ready_to_spawn_swift" );
}
