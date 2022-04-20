#include common_scripts\utility;
#include maps\_utility;
#include maps\cuba_util;
#include maps\cuba_anim;
#include maps\_anim;
#include maps\_music;

#using_animtree ("generic_human");
start()
{
	// main mansion function
	event_thread( "mansion", ::mansion_main );

	flag_wait("start_big_room_door_breach");

	autosave_by_name( "mansion over" );
}


setup_mansion_flags()
{
	//flag_init("start_castro_assasination");	// set when mansion enemies are cleared and its safe to start assasination
	//flag_init("player_inside_mansion");  		// set when player enters mansion
	flag_init("player_in_big_room");			// set when player is just about to get into the big room
	flag_init("window_guard_shot_by_player");   // set if the window guard gets shot by the player
	flag_init("start_mansion_door_breach");		// set when the mansion door breach needs to start
	flag_init("mansion_door_opened");			// set when woods opens the door to enter mansion
	flag_init("player_outside_mansion");  		// set when player is outside the mansion
	flag_init("halt_mansion_ambiance");  		// set when need to turn off the ambiance in the mansion
	flag_init("window_guard_dead");      //SHolmes: set when window guard is dead in mansion breach
}	

// --------------------------------------------------------------------------------
// ---- Mansion main function ----
// --------------------------------------------------------------------------------
mansion_main()
{
	level.DOOR_PLAYER_DIST_SQ = 300 * 300;
	
	// get heros
	level.bowman  = get_hero_by_name( "bowman" );
	level.woods   = get_hero_by_name( "woods" );
	level.friendlies = array( level.bowman, level.woods );
	
	level.woods.a.forceCqbStopIdle = true;

	get_players()[0].animname = "mason";
		
	// now we are in parking section of the mansion start ambiant planes in parking section
	level thread ambiant_planes( "player_inside_mansion", "parking" );	

	// player movement think
	level thread mansion_player_movement_think();

	// friendly movement think
	level thread mansion_friendly_movement_think();
	
	// start thread that creates ambiant effects around the player
	level thread ambiant_effect_think();
	
	// TEMP - dialogue inside the mansion
	level thread mansion_dialogue_think();
}

// --------------------------------------------------------------------------------
// ---- Player movement in mansion ----
// --------------------------------------------------------------------------------
mansion_player_movement_think()
{
	
}

// --------------------------------------------------------------------------------
// ---- Friendly movement in mansion ----
// --------------------------------------------------------------------------------
mansion_friendly_movement_think()
{
	// no random heat anims for woods and bowman	
	level.woods disable_heat();
	level.bowman disable_heat();

	level.woods.noHeatAnims  = 1;
	level.bowman.noHeatAnims = 1;
	
	// no suppression on woods and bowman
	level.woods set_ignoresuppression( true );
	level.bowman set_ignoresuppression( true );

	// set blend in and blend outs for scripted animations
	array_func( level.friendlies, ::anim_set_blend_in_time, 0.2 );
	array_func( level.friendlies, ::anim_set_blend_out_time, 0.2 );
	
	// SUMEET_TODO - add dynamic speed logic
	array_func( level.friendlies, ::enable_cqbwalk );

	// mansion door breach nodes flags
	level.woods  ent_flag_init("mansion_door_node_reached");
	level.bowman ent_flag_init("mansion_door_node_reached");
	
	// mansion door breach
	level.woods thread mansion_door_breach();	

	// follow path from parking to the entry in the mansion
	level.woods thread follow_path( "woods_parking_start" );
	level.bowman thread follow_path( "bowman_parking_start" );	

	flag_wait( "mansion_door_opened" );

}

// entrance door to the mansion
mansion_door_breach() // self = woods
{
	player = get_players()[0];
	
/#
	level.woods thread debug_mansion_door_breach();
#/
	
	// hiding the destoyed model of the window guard door before player gets into the mansion
	models = GetEntArray( "mansion_door_dest", "targetname" );
	array_func( models, ::door_parts_hide );
	
	objective_on_door = false;	
	door_obj_struct = getstruct( "mansion_door_obj_struct", "targetname" );

	// get the animation node
	//level.mansion_door_breach_node = GetNode( "mansion_door_breach_node", "targetname" );
	mansion_door_breach_node = getstruct( "new_woods_struct", "targetname" );

	// start waiting for woods to get in position
	level.woods thread mansion_door_breach_woods( mansion_door_breach_node );
		
	// guards
	level thread mansion_door_breach_window_guard( mansion_door_breach_node );
	level thread mansion_door_breach_cabinet_guard( mansion_door_breach_node );

	distSq = DistanceSquared( level.woods.origin, player.origin );

	while( !level.woods ent_flag( "mansion_door_node_reached" ) 
		   || !level.bowman ent_flag( "mansion_door_node_reached" )
		   || ( distSq > level.DOOR_PLAYER_DIST_SQ )
		  )
	{
		if( !objective_on_door 
			&& level.woods ent_flag( "mansion_door_node_reached" )
			&& level.bowman ent_flag( "mansion_door_node_reached" )
		  )
		{
			objective_on_door = true;	
			
			//Objective_Add( level.OBJ_MISC, "active", "", door_obj_struct.origin );
			//Objective_Set3D( level.OBJ_MISC, true, (1, 1, 1), "" );

			set_objective(level.OBJ_COMPOUND, door_obj_struct);

			// start nag lines from woods to the player
			mansion_nag_array = create_woods_nag_array( "door_breach" );
			level.woods thread do_vo_nag_loop( "woods", mansion_nag_array, "start_mansion_door_breach", 6 );

		}

		wait(0.5);
		distSq = DistanceSquared( level.woods.origin, player.origin );
	}
	
	flag_set("start_mansion_door_breach");
	
	//TUEY set music to STINGER_MANSION_DOORS
	setmusicstate ("STINGER_MANSION_DOORS");
	
	// play another VO before getting into the mansion
	//level.woods play_vo("this_way"); // this way - inside" SHolmes: now played via notetrack
	
	//Objective_State(level.OBJ_MISC, "done");

	set_objective(level.OBJ_COMPOUND, level.woods, "follow");
	
	autosave_by_name( "mansion_door_opened" );
		
	// doing this right away so that we make sure that friendlies are always ahead of the player
	flag_set("mansion_door_opened");
}

mansion_left_door( guy )
{
	door = GetEnt( "mansion_door_left", "targetname" );
	door playsound ("amb_door_open_wood");
	door RotateYaw( 120, 1 );
	//door ConnectPaths();
}

mansion_right_door( guy )
{
	door = GetEnt( "mansion_door_right", "targetname" );
	door RotateYaw( -120, .5 );
	door playsound ("amb_door_open_wood_00");
	door waittill ("rotatedone");
	door playsound ("amb_door_open_wood_01");
	door RotateYaw( 20, 3 );
	//door ConnectPaths();
}


mansion_door_breach_woods( node ) // self = woods
{	
	// waittill second round of enemies are dead in this area
	waittill_ai_group_cleared( "mansion_entrance_enemy_aigroup2" );
		
	node anim_reach_aligned( level.woods, "mansion_breach" );
	
	level.woods ent_flag_set("mansion_door_node_reached");

	// wait for player to come close before starting the breach
	flag_wait("start_mansion_door_breach");

	node anim_single_aligned( level.woods, "mansion_breach" );
	
	level.woods kill_window_guy();
	
	// once player and AI is in the mansion it will follow different path
	level.woods thread follow_path( "mansion_door_breach_node" );
	
	// dialogue after the breach on woods and bowman
	// if window guard is not killed by player woods shouts at player to wake up
	/*
	if( !flag( "window_guard_shot_by_player" ) )
	{
		level.woods  play_vo( "mason" ); 		 // mason!
		level.woods  play_vo( "wake_up_mason" ); // wake the f* up
	}
*/
	level.woods play_vo("bowman_split"); 	//Bowman - Take the roof.
	level.woods play_vo("trouble_yell"); 	//Any trouble - give us a yell.
	level.bowman thread play_vo("got_it"); 	//Got it.

	wait(1);

	level.woods play_vo("search_castro"); 	//Mason - on me. We search room to room 'till we find Castro.	
}

kill_window_guy()
{
	//if window enemy is alive, wait 1 sec then kill him
	wait(1);
	
	self.perfectAim = true;
	
	guy = GetEnt ("mansion_window_guard_ai", "targetname");
	
	if( IsDefined(guy) )
	{
		//Mason didnt shoot window guy - do VO line
		level.woods  play_vo( "wake_up_mason" ); // wake the f* up
		
		while( IsAlive(guy) )
		{
			self shoot_at_target(guy, "J_head");
			wait(0.05);
		}
	}
	self.perfectAim = false;
	
}	

mansion_door_breach_bowman( guy ) // self = bowman
{
	// set when bowman goes to the cover node by follow_node system
	level.bowman ent_flag_wait("mansion_door_node_reached");
	
	// bowman is aligned to the cover node he is on
	node = GetNode( "mansion_door_breach_bowman_node", "targetname" );
	
	//Sholmes waiting for window guy to die and open window first since this occurs at varying times now
	flag_wait("window_guard_dead");
	
	node anim_single_aligned( level.bowman, "mansion_breach" );
	
	//SHolmes: climb on to ladder traversal to roof area and out of sight
	level.bowman set_ignoreme(true);
	level.bowman set_ignoreall(true);
	node = GetNode ("bowman_roof", "targetname");
	level.bowman set_goalradius(32);
	level.bowman SetGoalNode (node);
}



// guard that gets thrown out of the window
mansion_door_breach_window_guard( node )
{
	flag_wait("start_mansion_door_breach");
	
	guard = simple_spawn_single( "mansion_window_guard" );
	guard.animname = "guard_window";
	guard magic_bullet_shield();
	guard.deathAnim = level.scr_anim[ "guard_window" ][ "mansion_breach" ];
	
	// make friendlies ignore this guy so that he will not be shot
	//guard set_ignoreme(true);
	//guard.deathfunction =  ::window_guard_hit;
	// start a thread on this guard to track if player hits him
	//guard thread watch_damage_from_player();	
	start_origin = GetStartOrigin (node.origin, node.angles, level.scr_anim["guard_window"] ["mansion_breach"] );
	start_angles = GetStartAngles (node.origin, node.angles, level.scr_anim["guard_window"] ["mansion_breach"] );
	
	//guard SetGoalPos(start_origin);
	//guard waittill ("goal");
	guard force_goal(start_origin);
	//guard thread stop_magic_bullet_shield();
	guard waittill ("damage");
	guard stop_magic_bullet_shield();
	node thread anim_single_aligned( guard, "mansion_breach" );
	
	flag_set ("window_guard_dead");
	//level thread window_guard_hit();
	
	
	//node anim_single_aligned( guard, "mansion_breach" );
}

watch_damage_from_player() // self = window guard
{
	while(1)
	{
		self waittill( "damage", value, attacker );
	
		if( IsPlayer( attacker ) )
		{
			flag_set("window_guard_shot_by_player");
			break;
		}
	}
}

// guard gets shot by woods and hits the table on the right
mansion_door_breach_cabinet_guard( node )
{
	flag_wait("start_mansion_door_breach");

	guard = simple_spawn_single( "mansion_cabinet_guard" );
	guard.animname = "guard_cabinet";
	
	guard.allowDeath = false;
	guard DisableAimAssist();

	node anim_single_aligned( guard, "mansion_breach" );
}

cabinet_guard_pulse( guard )
{
	pulse_position = guard get_eye();
	PhysicsExplosionCylinder( pulse_position, 150, 100, 3 );		
}

window_guard_hit(guy)
{
	//wait(.3);
	
	// hide the pristine door model
	models = GetEntArray( "mansion_door_prist", "targetname" );
	array_thread( models, ::door_parts_hide );

	// show the new destroyed model
	models = GetEntArray( "mansion_door_dest", "targetname" );
	array_thread( models, ::door_parts_show );

	// play glass effect exploder while swapping to the destroyed model
	exploder( 610 );
	
	// play a physics pulse
	//pulse_position = guard get_eye();
	//PhysicsExplosionCylinder( pulse_position, 150, 100, 3 );		
}

door_parts_hide() // self = door part
{
	self Hide();
}

door_parts_show() // self = door part
{
	self Show();
}

/#

debug_mansion_door_breach()
{
	level endon( "mansion_door_opened" );

	while(1)
	{
		mansion_door_breach_node = getstruct( "bowman_exit", "targetname" );

		origin = GetStartOrigin( mansion_door_breach_node.origin, mansion_door_breach_node.angles, level.scr_anim["woods"]["mansion_breach"] );
		vec = GetStartAngles( mansion_door_breach_node.origin, mansion_door_breach_node.angles, level.scr_anim["woods"]["mansion_breach"] );

		level.woods debug_door_breach_line( origin, vec, ( 0, 1, 0 ) );
	
		mansion_door_breach_node = GetNode( "mansion_door_breach_bowman_node", "targetname" );
		origin = GetStartOrigin( mansion_door_breach_node.origin, mansion_door_breach_node.angles, level.scr_anim["bowman"]["mansion_breach"] );
		vec = GetStartAngles( mansion_door_breach_node.origin, mansion_door_breach_node.angles, level.scr_anim["bowman"]["mansion_breach"] );
	
		level.bowman debug_door_breach_line( origin, vec, ( 1, 0, 0 ) );
	
		wait( 0.05 );
	}
}

#/

// --------------------------------------------------------------------------------
// ---- Additional Dialogues inside mansion ----
// --------------------------------------------------------------------------------
mansion_dialogue_think()
{
	flag_wait("player_inside_mansion");
	
	// save the game
	autosave_by_name("player_inside_mansion");
	
	flag_wait( "mansion_door_opened" );

	flag_wait( "player_in_big_room" );

	level thread maps\cuba_mansion_amb::ambiant_effect_thread( "player_in_big_room", "player_outside_mansion", true );

	wait(1);

	level.woods play_vo("what_the_fuck"); //What the fuck was that?!!!
	level.woods play_vo("bowman_whats_happening"); //bowman - what's happening?
	
	level.bowman play_vo("B26"); //It's the B26's!  I don't think they know what the hell they're bombing!
	level.woods play_vo("done_in_5"); //Sit tight... We'll be done in five.

	wait(1);

	level.woods play_vo("target_ahead");   //Target's up ahead...
	get_players()[0] play_vo("copy"); //Copy.

}


// --------------------------------------------------------------------------------
// ---- Ambiant effects ----
// --------------------------------------------------------------------------------
ambiant_effect_think()
{
	maps\cuba_mansion_amb::ambiant_effect_thread( "player_inside_mansion", "player_outside_mansion" );
}
