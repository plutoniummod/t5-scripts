#include common_scripts\utility;
#include maps\_utility;
#include maps\cuba_util;
#include maps\cuba_anim;
#include maps\_anim;
#include maps\_music;
start()
{
	setup_cuba_melee();

	// TEMP - setting this flag for skipto to work
	flag_set("zipline_event_done");

	// main compound function
	event_thread( "compound", ::compound_main );
	
	flag_wait("parking_door_opened");

	// save after compound
	autosave_by_name( "compound_event_done" );
}

#using_animtree("generic_human");

setup_cuba_melee()
{
	maps\_contextual_melee::add_melee_sequence("default", "cubagarrote", "stand", "stand",	%int_contextual_melee_garrote, %ai_contextual_melee_garrote);
	maps\_contextual_melee::add_melee_sequence("default", "cubagarrote", "crouch", "stand", %int_contextual_melee_garrote, %ai_contextual_melee_garrote);

	setup_cuba_melee_weapon();
}

#using_animtree("animated_props");

setup_cuba_melee_weapon()
{
	maps\_contextual_melee::add_melee_weapon("default", "cubagarrote", "stand", "stand", "t5_weapon_garrot_wire", %prop_contextual_melee_garrote_garrotewire);
	maps\_contextual_melee::add_melee_weapon("default", "cubagarrote", "crouch", "stand", "t5_weapon_garrot_wire", %prop_contextual_melee_garrote_garrotewire);
}

setup_compound_flags()
{
	// All the flags that are initialized by triggers/vehicle nodes should go in here for reference 
	//flag_init("first_contextual_melee_over"); 	// set when player kills the first contextual melee AI
	//flag_init("player_out_in_compound");			// set when player comes into compound out of the door
	//flag_init("comp_player_near_trucks");			// set when player enters the truck inloading area

	flag_init("first_contextual_melee_started");  	// set when player starts killing the first contextual melee AI
	flag_init("compound_door_opened");				// set when woods opens the door on the compound

	flag_init("convoy1_vehicles_clear");			// set when the convoy trucks are moved up
	flag_init("convoy1_clear");						// set when first convoy of trucks and AI is cleared

	flag_init("convoy2_stop");						// set when convoy2 will start
	flag_init("convoy2_vehicle_clear");				// set when all convoy2 the vehicles are out of the way
	flag_init("convoy2_clear");						// set when convoy2 vehicles and AI are cleared, and squad can move up
	flag_init("convoy2_outside_compound");			// set when all the vehicles are outside compound gate

	flag_init("compound_stealth_broken");			// set when the compound stealth broken

	flag_init("start_parkingdoor_breach");			// set when parking door breach starts
	flag_init("parking_door_opened");				// set when squad opens the door to enter parking garage
}

// --------------------------------------------------------------------------------
// ---- Compound main function ----
// --------------------------------------------------------------------------------

compound_main()
{
	// player needs to be within this distance to start the door breach
	level.DOOR_PLAYER_DIST_SQ = 200 * 200;
	
	// get heros
	level.bowman  = get_hero_by_name( "bowman" );
	level.woods   = get_hero_by_name( "woods" );
	level.friendlies = array( level.bowman, level.woods );
	

	level.woods.a.forceCqbStopIdle = true;

	set_objective( level.OBJ_COMPOUND, level.woods, "follow" );

	get_players()[0].animname = "mason";

	// spawn a stealth controllers that can be accessed by AI and player
	level.stealth = SpawnStruct();
		
	// listeners for the AI to maintain stealth	
	level.stealth.listeners = [];
	level.stealth.listeners[0]	= "grenade danger";
	level.stealth.listeners[1] 	= "gunshot";
	level.stealth.listeners[2] 	= "bulletwhizby";
	
	// open compound gates
	compound_gates_open();
	
	// thread that closes the gates when needed
	level thread compound_gates_close();

	// function waits for the compound stealth to break
	level thread compound_stealth_think();
	
	// player movement speed and stealth in the compound
	level thread compound_player_think();

	// friendly movement think
	level thread compound_friendly_movement_think();

	// contextual melee dude that player needs to kill to move on
	level thread compound_contextual_enemy_think();

	// manage escort convoy on the main road in compound
	level thread compound_convoy_think();

	// ambiant planes in compound and parking
	level thread ambiant_planes_compound();

}

ambiant_planes_compound()
{
	// start ambiant planes for compound
	level thread ambiant_planes( "parking_door_opened", "compound" );
}

// waits for the stealth to be broken in the compound until convoy2 is cleared
// spawns backup dudes and kills the player
compound_stealth_think()
{
	// no need to wait for stealth if convoy2 is clear	
	level endon( "convoy2_clear" );

	// wait for stealth to be broken
	flag_wait( "compound_stealth_broken" );

	player = get_players()[0];
	
	// get the closest convoy guys to the player
	convoy_ai = get_ai_group_ai( "comp_convoy2_aigroup" );
	array_thread( convoy_ai, ::convoy2_ai_react_to_stealth );

	// woods and bowman stop ignoring everyone
	level.bowman set_ignoreall( false );
	level.woods set_ignoreall( false );
	level.bowman set_ignoreme( false );
	level.woods set_ignoreme( false );

	// spawn guys on the staircase
	spawn_manager_enable( "staircase_enemy_manager" );

	// spawn additional dudes
	stealth_enemies = simple_spawn( "compound_stealth_enemies" );
	
	wait(8);

	mission_failed( "blew_cover" );
}


// --------------------------------------------------------------------------------
// ---- Compound gates, called by zipline and compound both ----
// --------------------------------------------------------------------------------
compound_gates_open()
{
	if( flag( "compound_gates_opened" ) )
		return;

	// open compound doors at right end
	door = GetEnt( "convoy_gate01_left", "targetname" );
	door playsound ("amb_door_open_wood");
	door RotateYaw( 135, 1 );
	door ConnectPaths();

	door = GetEnt( "convoy_gate01_right", "targetname" );
	door playsound ("amb_door_open_wood");
	door RotateYaw( -135, 1 );
	door ConnectPaths();

	// open compound doors at left end
	door = GetEnt( "convoy_gate02_left", "targetname" );
	door playsound ("amb_door_open_wood");
	door RotateYaw( 135, 1 );
	door ConnectPaths();

	door = GetEnt( "convoy_gate02_right", "targetname" );	
	door playsound ("amb_door_open_wood");
	door RotateYaw( -135, 1 );
	door ConnectPaths();

	// tell everyone that the gates are already opened, so that we dont try to open it again
	// in compound script
	flag_set("compound_gates_opened");
}

compound_gates_close()
{
	if( flag( "compound_gates_closed" ) )
		return;

	// wait until the convoy clear, and friendlies move up
	flag_wait( "convoy2_clear" );

	// close compound doors at right end
	door = GetEnt( "convoy_gate01_left", "targetname" );
	door RotateYaw( -135, 4 );
	door = GetEnt( "convoy_gate01_right", "targetname" );
	door RotateYaw( 135, 4 );
	
	// waittill all the convoy is outside the compound
	flag_wait( "convoy2_outside_compound" );

	// close compound doors on the left end
	door = GetEnt( "convoy_gate02_left", "targetname" );
	door RotateYaw( -135, 4 );
	door = GetEnt( "convoy_gate02_right", "targetname" );	
	door RotateYaw( 135, 4 );

	// tell everyone that the compound doors are closed
	flag_set("compound_gates_closed");
}	

// --------------------------------------------------------------------------------
// ---- Player movement ----
// --------------------------------------------------------------------------------
compound_player_think()
{
	player = get_players()[0];

	// player movement speed control
	player thread compound_player_speed_control();

	// stealth before player moves outside the first building in the compound
	player thread compound_player_inside_building_stealth();

	// stealth outside the building in the convoy area
	player thread compound_player_outside_building_stealth();
}

compound_player_outside_building_stealth()
{
	player = get_players()[0];

	player endon("death");

	// first trigger that stops additional convoy
	// player can be within this trigger but cant be firing and alerting the AI
	compound_trigger1 = GetEnt("compound_stealth_trigger1", "targetname");
	compound_trigger2 = GetEnt("compound_stealth_trigger2", "targetname");

	// waits for player and woods to get into compound into position 
	// and raises a flag that will stop the convoy2 from spawning
	player thread compound_player_outside();

	// waittill player enters the stealth section
	//flag_wait("convoy2_stop");
	flag_wait("compound_door_opened");//SHolmes: door opened = player cant shoot inside anymore
	
	// start the stealth logic on the player as 
	while( !flag("convoy2_clear") && !flag("compound_stealth_broken") )
	{
		// if player is touching this trigger then stealth is broken
		if( player IsTouching( compound_trigger2 ) )
		{
			flag_set("compound_stealth_broken");
		
			/#
			//IPrintLn( "stealth_alerted - player ran ahead" );
			#/
			
			break;
		}

		// only do stealth when player is within the stealth trigger
		do_stealth = player IsTouching( compound_trigger1 );

		if( !do_stealth )
			wait(0.05);

		// also check if player is firing
		if( player AttackButtonPressed() || player FragButtonPressed() ) //SHolmes removed isFiring() because it was returning knife attacks too
		{
			flag_set("compound_stealth_broken");

			/#
			//IPrintLn( "stealth_alerted - player firing or running to fast" );
			#/
			
			break;
		}

		wait(0.05);
	}
	
	// delete the stealth triggers as we dont need them anymore
	if( flag( "convoy2_clear" ) )
	{
		compound_trigger1 Delete();
		compound_trigger2 Delete();
	}
}


compound_player_inside_building_stealth()
{
	level endon ("convoy1_clear"); //Sholmes dont want player to fail after 1st convoy has passed if shooting inside
	
	// this trigger will only turn on after the contextual melee kill
	compound_window_trig = GetEnt( "compound_window_trig", "targetname" );

	// waittill either the trigger takes damage or player is outside in the compound
	waittill_any_ents( compound_window_trig, "trigger", level, "player_out_in_compound" );

	// if player is not outside in the compound and this trigger takes damage then 
	if( !flag( "player_out_in_compound" ) )
		mission_failed( "blew_cover" );
}

compound_player_outside() // self = player 
{
	// wait until player comes into the building
	flag_wait("player_out_in_compound");
	flag_set("convoy2_stop");

	// waittill woods in position hiding in bushes behind rocks
	level.woods ent_flag_wait("compound_woods_hiding");

	// wait a little bit more so that there will be more convoy that player can see
	//SHolmes removed wait to get convoy to stop quicker

	// now stop spawning more convoy
	//trying this when player gets outside
	flag_set("convoy2_stop");
}

compound_player_speed_control() // self = player
{
	flag_wait("compound_door_opened");
	get_players()[0] SetMoveSpeedScale(0.8);
	
	flag_wait("comp_player_near_trucks");	
	get_players()[0] SetMoveSpeedScale(1);
}

// --------------------------------------------------------------------------------
// ---- Friendly movement in compound ----
// --------------------------------------------------------------------------------

compound_friendly_movement_think()
{
	// no random heat anims for woods and bowman	
	level.woods disable_heat();
	level.bowman disable_heat();
		
	level.woods.noHeatAnims  = 1;
	level.bowman.noHeatAnims = 1;

	// no suppression on woods and bowman
	level.woods set_ignoresuppression( true );
	level.bowman set_ignoresuppression( true );

	// compound door breach nodes flags
	level.woods  ent_flag_init("in_position_for_compound_door");
	level.bowman ent_flag_init("in_position_for_compound_door");
	level.bowman ent_flag_init("start_copound_door_open"); // set when bowman gets a notetrack from woods animation

	level.woods  ent_flag_init("parking_door_node_reached");
	level.bowman ent_flag_init("parking_door_node_reached");

	// set when woods hides behind a rock
	level.woods ent_flag_init("compound_woods_hiding");
	
	// set blend in and blend outs for scripted animations
	array_func( level.friendlies, ::anim_set_blend_in_time, 0.2 );
	array_func( level.friendlies, ::anim_set_blend_out_time, 0.2 );
		
	// SUMEET_TODO - add dynamic speed logic
	array_func( level.friendlies, ::enable_cqbwalk );

	// first door that woods opens to get into compound area	
	level.woods thread compound_door_breach();
	level.woods thread parking_door_breach();
	level thread friendlies_compound_dialogue();
	
	// follow path inside radio room
	level.woods thread follow_path( "woods_zipline_start" );
	level.bowman thread follow_path( "bowman_zipline_start" );
	
	flag_wait( "compound_door_opened" );

	// follow path after the compound door is opened
	level.woods thread follow_path( "woods_compound_start" );
	level.bowman thread follow_path( "bowman_compound_start" );
	
	// wait until the parking door is opened
	flag_wait( "parking_door_opened" );
}

// first compound door
compound_door_breach() // self = woods
{
	player = get_players()[0];

/#
	//level.woods thread debug_compound_door_breach();
#/
	// waittill convoy1 is clearead	and woods in position
	//flag_wait( "convoy1_clear" );
	
	// waittill contextual melee is started
	flag_wait("first_contextual_melee_started");

	objective_on_door = false;	
	door_obj_struct = getstruct( "comp_door_obj_struct", "targetname" );

	// get the align node for animation
	door_align_node = getstruct( "radioroom", "targetname" );
	door_align_node.angles = ( 0,0,0 );

	// bowman animation
	level.bowman thread compound_door_breach_bowman( door_align_node );

	// woods animation	
	level.woods thread compound_door_breach_woods( door_align_node );
	
	while( !level.woods ent_flag( "in_position_for_compound_door" ) 
		   || !level.bowman ent_flag( "in_position_for_compound_door" )
		 )
	{
		if( !objective_on_door
			&& level.woods ent_flag( "in_position_for_compound_door" )
			&& level.bowman ent_flag( "in_position_for_compound_door" )
		  )
		{
			objective_on_door = true;

			set_objective(level.OBJ_COMPOUND, door_obj_struct, "");
// 			Objective_Add( level.OBJ_MISC, "active", "", door_obj_struct.origin );
// 			Objective_Set3D( level.OBJ_MISC, true, (1, 1, 1), "" );
		}

		wait(0.5);
	}

// 	Objective_State(level.OBJ_MISC, "done");
	set_objective(level.OBJ_COMPOUND, level.woods, "follow");

	//autosave_by_name( "compound_door_breach" );

	// doing this right away so that we make sure that friendlies are always ahead of the player
	flag_set("compound_door_opened");
}

compound_breach_door_open( guy )
{
	door = GetEnt( "compound_door", "targetname" );
	door playsound ("amb_door_open_wood");
	door RotateYaw( 120, 2, .5, 1.5);
  door waittill ("rotatedone");
  door RotateYaw( -25, 3, .5, 2.5);
  
	//door ConnectPaths();
}

compound_door_breach_woods( node ) // self = woods
{		
	// go and start the animation
	node anim_reach_aligned( level.woods, "compound_breach" );
	
	level.woods ent_flag_set( "in_position_for_compound_door" );
	
	node anim_single_aligned( level.woods, "compound_breach" );
}

compound_door_breach_bowman( node ) // self = bowman
{
	// get bowman to play part 1 of his animation
	node anim_reach_aligned( level.bowman, "compound_breach_part1" );

	level.bowman ent_flag_set( "in_position_for_compound_door" );
	
	node anim_single_aligned( level.bowman, "compound_breach_part1" );

	// now start idling until woods takes position to start his animation and sends a notetrack to bowman to start his compound door open animation
	// this might not happen at all based on when woods starts
	if( !level.bowman ent_flag( "start_copound_door_open" ) )
		node thread anim_loop_aligned( level.bowman, "compound_breach_idle" );
}

compound_breach_bowman_open_door( guy )
{
	node = getstruct( "radioroom", "targetname" );
	node.angles = ( 0,0,0 );

	// set this flag so that if we end up trying to loop, it will not be needed
	level.bowman ent_flag_set("start_copound_door_open");
	
	node anim_single_aligned( level.bowman, "compound_breach_part2" );
}

/#

debug_compound_door_breach()
{
	level endon( "compound_door_opened" );

	while(1)
	{
		node = GetNode( "comp_door_node_woods", "script_noteworthy" );
		origin = GetStartOrigin( node.origin, node.angles, level.scr_anim["woods"]["compound_breach"] );
		vec = GetStartAngles( node.origin, node.angles, level.scr_anim["woods"]["compound_breach"] );
		level.woods debug_door_breach_line( origin, vec, ( 0, 1, 0 ) );

		node = GetNode( "comp_door_node_bowman", "script_noteworthy" );
		origin = GetStartOrigin( node.origin, node.angles, level.scr_anim["bowman"]["compound_breach"] );
		vec = GetStartAngles( node.origin, node.angles, level.scr_anim["bowman"]["compound_breach"] );
		level.bowman debug_door_breach_line( origin, vec, ( 1, 0, 0 ) );
	
		wait( 0.05 );
	}
}

#/

// second door that gets us into the mansion parking
parking_door_breach() // self = woods
{
	level thread parking_door_nag_timing();
	
	player = get_players()[0];
	
/#
	level.woods thread debug_parking_door_breach();
#/

	//objective_on_door = false;	
	door_obj_struct = getstruct( "parking_door_obj_struct", "targetname" );
	
	flag_wait("player_at_paking_door");//trigger_radius at parking door
	//objective_on_door = true;	

	//Objective_Add( level.OBJ_MISC, "active", "", door_obj_struct.origin );
	//Objective_Set3D( level.OBJ_MISC, true, (1, 1, 1), "" );

	set_objective(level.OBJ_COMPOUND, door_obj_struct, "");

	flag_set("start_parkingdoor_breach");

	//Objective_State(level.OBJ_MISC, "done");

	set_objective(level.OBJ_COMPOUND, level.woods, "follow");

	// spawn enemies that will be killed in this breach by woods and bowman
	parking_breach_enemies();	
	
	level.parking_door_breach_node = GetNode( "parking_door_align_node", "script_noteworthy" );

	level thread heroes_breach();
}

parking_door_nag_timing()
{
	level endon ("parking_door_opened");
	
	// waittill woods in position
	level.woods ent_flag_wait( "parking_door_node_reached" );
	
	if(!flag("player_at_paking_door"))
	{	
		// start nag lines from woods to the player
		parking_nag_array = create_woods_nag_array( "door_breach" );
		level.woods thread do_vo_nag_loop( "woods", parking_nag_array, "start_parkingdoor_breach", 6 );
	}
	
}	
	


parking_breach_door_open( guy )
{
	door = GetEnt( "parking_door", "targetname" );
	door playsound ("amb_door_open_wood");
	door RotateYaw( 160, 1.5 );

	// doing this right away so that we make sure that friendlies are always ahead of the player
	flag_set("parking_door_opened");
	
	level thread mansion_portals_hide();

	//door ConnectPaths();
}


//Sholmes: Woods and Bowman reach_aligned to the door then play anim now to prevent popping at doorstep. 
heroes_breach() 
{
	//reach to door, one at a time
	level.parking_door_breach_node anim_reach_aligned( level.woods, "parking_breach" );
	level.parking_door_breach_node anim_reach_aligned( level.bowman, "parking_breach" );
	
	//do breach scene together
	level.parking_door_breach_node thread anim_single_aligned( level.woods, "parking_breach" );
	level.parking_door_breach_node anim_single_aligned( level.bowman, "parking_breach" );
}



parking_breach_enemies()
{
	// SUMEET_TODO - make these guys not script forcespawn. Talk to paul to close the windows
	enemies[0] = simple_spawn_single( "parking_door_enemies1" );
	enemies[1] = simple_spawn_single( "parking_door_enemies2" );
	enemies[2] = simple_spawn_single( "parking_door_enemies3" );

	// setup death anims for these enemies
	array_func( enemies, ::parking_breach_enemies_setup );
}

parking_breach_enemies_setup() // self - parking door enemy
{
	self set_ignoreme( true );
	self set_ignoreall( true );
}

parking_door_friendly_kill( guy ) // guy = bowman/woods
{
	if( guy == level.bowman )
		enemy = GetEnt( "parking_door_enemies2_ai", "targetname" );
	else	
		enemy = GetEnt( "parking_door_enemies1_ai", "targetname" );
		
	guy = GetEnt ("parking_door_enemies3_ai", "targetname");
	guy set_ignoreall( false );
	guy set_ignoreme( false );

	if( IsDefined( enemy ) )
	{
		enemy set_ignoreall( false );
	
		bone[0] = "J_Knee_LE"; 
		bone[1] = "J_Ankle_LE"; 
		bone[2] = "J_Clavicle_LE"; 
		bone[3] = "J_Shoulder_LE"; 
		bone[4] = "J_Elbow_LE"; 
			
		impacts = 3;
		for( i = 0; i < impacts; i++ )
		{
			playfxontag(  level._effect["blood"], enemy, bone[RandomInt( bone.size )] ); 	           		
			wait( 0.05 ); 
		}
		
		enemy die();
	}
	
} 


/#
debug_parking_door_breach()
{
	level endon( "parking_door_opened" );

	while(1)
	{
		node = GetNode( "parking_door_align_node", "script_noteworthy" );

		origin = GetStartOrigin( node.origin, node.angles, level.scr_anim["woods"]["parking_breach"] );
		vec = GetStartAngles( node.origin, node.angles, level.scr_anim["woods"]["parking_breach"] );
		level.woods debug_door_breach_line( origin, vec, ( 0, 1, 0 ) );

		origin = GetStartOrigin( node.origin, node.angles, level.scr_anim["bowman"]["parking_breach"] );
		vec = GetStartAngles( node.origin, node.angles, level.scr_anim["bowman"]["parking_breach"] );
		level.bowman debug_door_breach_line( origin, vec, ( 1, 0, 0 ) );
	
		wait( 0.05 );
	}
}
#/


friendlies_compound_dialogue()
{
	// wait for player to get into the compound after the door breach
	//level.woods ent_flag_wait( "compound_woods_hiding"); 
	flag_wait("player_out_in_compound");	//changed to this as convoy comes sooner -jc

	level.woods play_vo( "sit_tight" ); 		//Sit tight... let them pass.
		
	// waittill convoy2 is out of the way and its safe to move up
	flag_wait( "convoy2_clear" );
	
	level.woods play_vo( "bowman_left_flank" ); //bowman - Take the left flank.
	level.woods play_vo( "go_up" ); 			//Go." 
	
	
	//TUEY STINGER
	setmusicstate ("STINGER_POST_ZIPLINE");

	waittill_ai_group_cleared( "truck_enemies" );
	
	level.woods play_vo("move_quickly"); 		// Move quickly
	level.woods play_vo( "up_the_stairs" ); 	//This way - up the stairs.
	level.bowman play_vo( "got_it" );			// got it

	wait( 1.5 );

	// play dialogues for paranoid castro before starting the breach
	level.woods play_vo("castro_paranoid"); 	//Castro's paranoid... With good reason... we've been trying to get to him for three years.
	get_players()[0] play_vo("we_succeed"); 	//Today's the day we succeed
}

// --------------------------------------------------------------------------------
// ---- Compound contextual melee enemy ----
// --------------------------------------------------------------------------------
#using_animtree ("generic_human");
compound_contextual_enemy_think()
{
	contextual_melee_guy = simple_spawn_single( "comp_contextual_melee" );
	contextual_melee_guy.animname = "contextual_melee_guard";
	
	contextual_melee_guy ent_flag_init( "player_near_by" );
	
	stream_helper = createStreamerHint (contextual_melee_guy.origin, 1.0);

	contextual_melee_guy.allowdeath = true;
	contextual_melee_guy.health = 10;

	// here we know that player entered the trigger, start a timer before guy reacts
	contextual_melee_guy thread contextual_melee_guard_idle_react();
	contextual_melee_guy thread compound_contextual_guy_vo();
	contextual_melee_guy thread contextual_melee_prompt();
	contextual_melee_guy thread contextual_melee_blood();
	
	// waittill player starts melee or this AI reacts
	player = get_players()[0];
	waittill_any_ents( player, "do_contextual_melee", contextual_melee_guy, "reacted", contextual_melee_guy, "death" );
	
	stream_helper Delete();
		
	// moveup to the door
	flag_set("first_contextual_melee_started");
	
	//Objective_State(level.OBJ_MISC, "done");
	set_objective( level.OBJ_COMPOUND, level.woods, "follow" );
	
	contextual_melee_guy waittill("death");

	// setting this flag will move friendlies ahead
	flag_set("first_contextual_melee_over");
}

contextual_melee_blood() // self = contextual melee guy
{
	self endon("death");

	get_players()[0] waittill( "do_contextual_melee" );
	
	clientNotify ("cms_go");
	//TUEY set music to CONTEXT_MELEE
	setmusicstate("CONTEXT_MELEE");
	
	PlayFXOnTag( level._effect["garrot_kill"], self, "J_Head" ); 
}

contextual_melee_guard_idle_react() // self = contextual melee guy
{
	self endon( "death" );
	
	player = get_players()[0];
	player endon("do_contextual_melee"); // stop this logic if player starts contextual melee
	
	// start animating this AI with his idle animation
	self thread anim_loop_aligned( self, "idle", undefined );

	self thread watch_damage();

	// wait until player is in this AI's view or doesnt contextual melee this guy within some time
	while(1) 
	{
		movement = Length( player GetVelocity() );

		if( IsDefined( self.took_damage )
		    || ( within_fov( self.origin, self.angles, player.origin, Cos( 90 ) ) && self ent_flag( "player_near_by" ) )
		  )
		{	
		 
		  break;
		}
		else
		{
			wait 0.05;
		}
	}

	// stop ignoring the player
	self set_ignoreall( false );
	self set_ignoreme( false );
	
	// react to the player
	self notify( "reacted" );
	self anim_single_aligned( self, "exit" );	
}

watch_damage() // self = contextual melee guy
{
	self endon( "death" );

	player = get_players()[0];
	player endon("do_contextual_melee"); // stop this logic if player starts contextual melee

	trigger_wait( "contextual_melee_prompt_trig", "targetname" );
	
	for( i=0; i<level.stealth.listeners.size; i++)
		self AddAIEventListener( level.stealth.listeners[i] );	
	
	self waittill_any( "damage", level.stealth.listeners[0], level.stealth.listeners[1], level.stealth.listeners[2] );
	
	self.took_damage = 1;
}

contextual_melee_prompt() // self = contextual melee guy
{
	// wait for the player to get closer, on the door
	trigger_wait( "contextual_melee_prompt_trig", "targetname" );

	// bowman tells the player to take melee guy
	level.bowman play_vo( "take_him_out" );

// 	Objective_Add( level.OBJ_MISC, "active", "", self );
// 	Objective_Set3D( level.OBJ_MISC, true, (1, 1, 1), &"CUBA_3D_MELEE" );

	set_objective(level.OBJ_COMPOUND, self, "melee");
	
	self ent_flag_set( "player_near_by" );
	
	screen_message_create( &"CUBA_CONTEXTUAL_MELEE_HUD" );

	level waittill_notify_or_timeout( "first_contextual_melee_started", 4 );

	screen_message_delete();
}

compound_contextual_guy_vo() // self = contextual_melee_guard
{
	self endon("death");
	self endon("stop_vo");
	self thread contextual_melee_killvo();

	while( !flag( "first_contextual_melee_started" ) )
	{
		if( cointoss() )
		{
			self play_vo( "guard_invasion" ); 		//(Translated) The invasion has begun!
			self play_vo( "guard_under_attack" );   //(Translated) The airfield is under attack...
			self play_vo( "guard_on_their_way" );   //(Translated) We have men on their way now...
		}
	
		// here is where woods start his reply
		//I was told by cowell that this line needs to come after the melee
		//level.woods thread compound_contextual_woods_dialogue();
	
		if( cointoss() )
		{
			self play_vo( "guard_reinforce" ); 		//(Translated) Hold position until reinforcements arrive.
		}

		self play_vo( "guard_repeat" ); 		//(Translated) I Repeat -

		wait( RandomFloatRange( 2, 4 ) );
	}
	
	// stop all the sounds
	self StopSounds();
}

contextual_melee_killvo() //this stops the vo if you start the melee while he is still talking
{
	//this is generating errors when he gets killed by grenade launcher, or shot. 
	flag_wait( "first_contextual_melee_started" );
	self notify( "stop_vo" );
	//wait 1; 
	self StopSounds();
	flag_wait("first_contextual_melee_over");
}

// --------------------------------------------------------------------------------
// ---- Compound convoy setup ----
// --------------------------------------------------------------------------------
compound_convoy_think()
{
	level thread compound_convoy1();    //  three trucks right outside the building
	level thread compound_convoy2();	// convo2 is the one going across the compound
}

convoy_audio()//kevin adding function to call the convoy audio
{
	flag_wait("first_contextual_melee_over");
	ent = spawn( "script_origin" , (-3208, -3448, -208));
	ent playloopsound( "amb_convoy" , 1 );
	flag_wait( "convoy2_clear" );
	ent stoploopsound(5);
	wait 5;
	ent delete();
	
}

// --------------------------------------------------------------------------------
// ---- Compound convoy 1 ----
// --------------------------------------------------------------------------------
compound_convoy1()  // three trucks right outside the building
{
	// wait until player start the contextual melee
	flag_wait( "first_contextual_melee_started" );

	// SUMEET - Kevin, moved this one to the right place for clarity.
	thread convoy_audio();

	// truck
	trucks = [];
	
	trucks[0] = maps\_vehicle::spawn_vehicle_from_targetname( "comp_patrol_truck1" );
	trucks[1]  = maps\_vehicle::spawn_vehicle_from_targetname( "comp_patrol_truck2" );
	trucks[2] = maps\_vehicle::spawn_vehicle_from_targetname( "comp_patrol_truck3" );	

	// init a flag on the last vehicle, that will tell us that the vehicle is reached safe area
	// before friendlies can move up
	trucks[2] ent_flag_init( "convoy1_vehicles_clear" );

	// start trucks
	level thread compound_convoy1_vehicles( trucks );

	// start truck patrollers on both sides of the truck
	level thread convoy_patrollers_think( "comp_convoy1_left_ai_a" );
	
	wait (RandomFloatRange (1.6,2.4));
	
	level thread convoy_patrollers_think( "comp_convoy1_left_ai" );

	// waittill the AI and vehicles are cleared
	trucks[2] ent_flag_wait( "convoy1_vehicles_clear" );
	//waittill_ai_group_cleared( "comp_convoy1_aigroup" );

	// now convoy1 is cleared
	flag_set( "convoy1_clear" );
}

compound_convoy1_vehicles( trucks )
{	
	// get the start node
	start_node = GetVehicleNode( "comp_truck_start_node", "targetname" );
	
	// get the trucks moving one after another
	for( i = 0; i < trucks.size; i++ )
	{
		trucks[i] thread convoy_vehicle_movement_think( start_node );
					
		// wait before next truck moves
		wait(2);
	}
}

// --------------------------------------------------------------------------------
// ---- Compound convoy 2 ----
// --------------------------------------------------------------------------------
compound_convoy2() // BTRs, Trucks
{	
	// waittill player comes into compound room
	trigger_wait( "contextual_melee_prompt_trig", "targetname" );

	// start vehicles
	level thread compound_convoy2_vehicles();

	// start patrollers alongside vehicles
	level thread convoy_patrollers_think( "comp_convoy2_left_ai_a", "convoy2_stop" );
	
	wait(RandomFloatRange(4,6));//SHolmes spacing these guys out - one is a lot faster and is bunching up
		
	level thread convoy_patrollers_think( "comp_convoy2_left_ai", "convoy2_stop" );
	
	// waittill convoy2 is told to stop
	flag_wait("convoy2_stop");

	// adding wait here so that the last set vehicle/AI can be spawned
	wait(1);

	// when convoy vehicles and AI's are not touching this trigger anymore then convoy2 is clear, and squad can move up
	// we can close the gates at the right end at this point as well
	compound_trigger = GetEnt("compound_stealth_trigger2", "targetname");

	//  when all AI and convoy vehicles are not touching this trigger that means we can close gate at left end
	compound_outside_trigger = GetEnt("compound_outside_trigger", "targetname");	

	// start with the stealth flags stealth trigger
	vehicle_ent_flag = "convoy2_vehicle_clear";
	trigger = compound_trigger;

	while(1)
	{
		convoy = [];

		patrollers = get_ai_group_ai( "comp_convoy2_aigroup" );
		vehicles = GetEntArray("convoy2_vehicle", "targetname");

		convoy = array_combine( patrollers, vehicles );
	
		touching = false;
		
		for( i = 0; i < convoy.size; i++ )
		{
			if( IsDefined( convoy[i] ) )
			{
				// check if the AI is within unsafe area
				if( IsAI( convoy[i] ) && convoy[i] IsTouching( trigger ) )
				{
					// AI
					touching = true;
					continue;
				}
				else 
				{
					// check if the vehicle is within unsafe area
					if( ( convoy[i].targetname == "convoy2_vehicle" ) && !convoy[i] ent_flag( vehicle_ent_flag ) )
					{
						touching = true;
						continue;
					}
				}
			}
		}

		if( touching )
		{
			wait(1);
		}
		else
		{				
			if( trigger == compound_trigger )
			{
				// now convoy2 is cleared, that means its safe to move up
				flag_set( "convoy2_clear" );
							
				// now switch to the outside trigger
				// so that we track vehicles and AI going outside compound at left end
				trigger = compound_outside_trigger;
				vehicle_ent_flag = "convoy2_outside_compound";
			}
			else	
			{	
				// all the vehicles and AI are outside the compound, and we can close the gate at left end
				flag_set( "convoy2_outside_compound" );

				// delete the trigger as we dont need it anymore
				trigger Delete();

				break;
			}
		}			
	}
}

compound_convoy2_vehicles()
{	
	// a node where these vehicles start 	
	start_node = GetVehicleNode( "convoy2_start_node", "targetname" );

	// a node where vehicle needs to pass before setting the clear flag on it 
	clear_node = GetVehicleNode( "convoy2_clear_node", "script_noteworthy" );

	// outside compound node
	outside_compound_node = GetVehicleNode( "convoy2_outside_node", "script_noteworthy" );

	// start a thread on clear node that will track vehicles going pass it
	vehicles = [];
	
	vehicles[0] = SpawnStruct();
	vehicles[0].model = "t5_veh_truck_gaz63";
	vehicles[0].vehicle_type = "truck_gaz63_troops_bulletdamage";

	vehicles[1] = SpawnStruct();
	vehicles[1].model = "t5_veh_truck_gaz63";
	vehicles[1].vehicle_type = "truck_gaz63_player_single50_nodeath";

	vehicles[2] = SpawnStruct();
	vehicles[2].model = "t5_veh_truck_gaz63";
	vehicles[2].vehicle_type = "truck_gaz63_tanker";

	vehicles[3] = SpawnStruct();
	vehicles[3].model = "t5_veh_apc_btr60";
	vehicles[3].vehicle_type = "apc_btr60";

	vehicle = undefined;
	stop_spawning = false;
	level.convoy_total = 1;

	// keep the convoy2 running until the player moves ahead and makes them stop 
	while(1)
	{
		if( flag( "convoy2_stop" ) )
		{	
			// this way player will atleast see one vehicle
			stop_spawning = true;
		}
		
		if(level.convoy_total <= 10) //only want 10 total vehicles at a time
		{
			index = RandomIntRange( 0, vehicles.size );
	
			model_name = vehicles[index].model;
			vehicle_type = vehicles[index].vehicle_type;
	
			// spawn the vehicle
			vehicle = SpawnVehicle( model_name , "convoy2_vehicle", vehicle_type, start_node.origin, start_node.angles );
			vehicle.script_lights_on = 1;		
			vehicle.script_vehicle_selfremove = 1; 		
			vehicle.script_string = "no_deathmodel"; 		
			maps\_vehicle::vehicle_init( vehicle );   
	
			// start tracking if vehicle has passed the clear zone
			// basically once vehicle reaches clear node, it sets a flag
			vehicle ent_flag_init("convoy2_vehicle_clear");
			vehicle ent_flag_init("convoy2_outside_compound");
			vehicle thread track_vehicle_stealth_clearence( clear_node );
			vehicle thread track_vehicle_compound_clearence( outside_compound_node );
	
			// go on the path
			vehicle thread go_path( start_node );
	
			level.convoy_total ++; //increase convoy total
			
			if( stop_spawning )
				break;
		
			wait(3);
		}
		wait(.05);	
	}
}


track_vehicle_stealth_clearence( clear_node ) // self = convoy2 vehicle
{
	level endon("convoy2_clear");
	self endon("death");
	
	self waittill( clear_node.targetname );

	self ent_flag_set( "convoy2_vehicle_clear" );
}

track_vehicle_compound_clearence( outside_compound_node ) // self = convoy2 vehicle
{
	self endon("death");
	
	self waittill( outside_compound_node.targetname );

	self ent_flag_set( "convoy2_outside_compound" );
	
	level.convoy_total --;
}

// moves the vehicle along the path and deletes it if specified
convoy_vehicle_movement_think( start_node, reached_flag ) // self = convoy vehicle
{
	self endon("death");
	
	self SetSpeedImmediate( 25, 10, 5 );

	// go along predefined path
	self go_path( start_node );
		
	// set a flag if needed, usually this means that this is the last vehicle in the convoy
	if( IsDefined( reached_flag ) )
		flag_set( reached_flag );
}


convoy2_ai_react_to_stealth()
{
	self endon("death");

	// stop following nodes
	self stop_following_nodes();

	waittillframeend;
	
	// stop scripted anim if was playing one
	self anim_stopAnimScripted();

	// stop ignoring everyone
	self set_ignoreall( false );
	self set_ignoreme( false );
	self set_goalradius( 1024 );
	
	self.perfectAim = 1;
}

// --------------------------------------------------------------------------------
// ---- Compound patrollers logic  ----
// --------------------------------------------------------------------------------
convoy_patrollers_think( patroller_targetname, stop_spawning_flag )
{
	// get the spawner to check how many spawners we can to spawn
	patroller_spawner = GetEnt( patroller_targetname, "targetname" );

	spawner_count = patroller_spawner.count;
	spawned_count = 0;
	stop_spawning = false;
	
	for( i = 0; i < spawner_count; i++ )
	{
		// if the flag is defined, then stop spawning when the flag is set
		if( IsDefined( stop_spawning_flag ) )
		{
			if( flag( stop_spawning_flag ) )
				stop_spawning = true;				
		}

		// spawn a patroller
		patroller = simple_spawn_single( patroller_targetname );
	
		// start stealth on the patrollers
		patroller thread convoy_patrollers_steath_think();

		// don't slow down when getting close to the goal node
		patroller.stopAnimDistSq = 0.0001;

		// if this AI was meant to do a troop signal animation then do it and then make him follow nodes
		if( IsDefined( patroller.script_string ) && patroller.script_string == "troop_signal" )
		{
			// pick up a random singal animation - signal 1
			patroller.signal_anim =	random( level.scr_anim[ "troop_signal_ai" ][ "signal" ] );
			patroller AnimCustom( ::patroller_signal_animscript );
	
			// pick up a random singal animation - signal 2
			patroller.signal_anim =	random( level.scr_anim[ "troop_signal_ai" ][ "signal" ] );
			patroller AnimCustom( ::patroller_signal_animscript );

			// now setup patroller movement on this guy
			patroller thread sprint_patrollers_movement( patroller_targetname + "_signal", undefined, ::patroller_reached_end_node_func );
		}
		else
		{
			// setup patroller movement on this guy
			patroller thread sprint_patrollers_movement( patroller_targetname + "_node", undefined, ::patroller_reached_end_node_func );
		}

		// if ran out of count on the spawner, stop spawning
		if( !IsDefined( patroller ) ) 		
			break;
		else	
			spawned_count++;

		if( stop_spawning )
			break;

		wait(RandomFloatRange(3,4)); //SHolmes increasing wait to prevent AI from bunching up
	}

	// delete the spawner if the not all the guys are spawned from it
	if( spawned_count < spawner_count )	
		patroller_spawner Delete();
}

// function that runs when patroller is at end of his path, will be ruin by follow nodes
patroller_reached_end_node_func( node ) // self = patroller AI
{
	// stop any stealth logic
	self notify("stop_patroller_stealth");
}

patroller_signal_animscript() // self = patroller AI
{
	self endon("death");

	// play the signal animation and blend it into run 
	anim_length = GetAnimLength( self.signal_anim );
	self SetFlaggedAnimKnobAllRestart( "signal_anim", self.signal_anim, %body, 1, .1, 1 );
	animscripts\shared::DoNoteTracksForTime( anim_length - 0.2, "signal_anim" );	
}

convoy_patrollers_steath_think()
{
	for( i=0; i<level.stealth.listeners.size; i++)
	{
		self AddAIEventListener( level.stealth.listeners[i] );	
		self thread convoy_patrollers_steath_logic( level.stealth.listeners[i] );
	}

	self thread convoy_patrollers_stealth_after_clear_logic();
}

convoy_patrollers_steath_logic( type )
{
	self endon( "death" );
	self endon( "stop_patroller_stealth" );
	level endon( "convoy2_clear" );		

	while(1)
	{
		self waittill( type );
	
		if( !flag( "player_out_in_compound" ) )
			continue;
		
		if( !flag( "convoy2_clear" ) )	
		{
			// stealth breaks if convoy2 is not clear
			flag_set("compound_stealth_broken");
		}
		else
		{
			// convoy 2 is clear, but player managed to shoot, just mission fail
			mission_failed( "blew_cover" );
		}

		/#
		//IPrintLn( "stealth_alerted - Convoy AI was recieved danger event " + type );
		#/
				
	}
}


convoy_patrollers_stealth_after_clear_logic()
{
	self endon( "stop_patroller_stealth" );

	flag_wait( "convoy2_clear" );

	self waittill_any( "damage", "death" );

	flag_set("compound_stealth_broken");

	// convoy 2 is clear, but player managed to shoot, just mission fail
	mission_failed( "blew_cover" );

	/#
	//IPrintLn( "stealth_alerted - Convoy AI was recieved danger event " + type );
	#/
}


// --------------------------------------------------------------------------------
// ---- guys on the truck, loading and unloading  ----
// --------------------------------------------------------------------------------
compound_truck_enemies_think() // self = truck AI
{
	level.disc = false;
	level.paper1 = false;
	level.paper2 = false;
	
	self endon("death");

	// spawn staircase enemies if not spawned already
	spawn_manager_enable( "staircase_enemy_manager" );

	// start animating this guy alongside the truck
	//truck  = GetEnt( "compound_truck", "targetname" );
	truck2 = GetEnt( "compound_truck2", "targetname" );
	align_ent = truck2;

	// start a stealth thread to track if player shot around these guy
	self thread truck_stairs_enemies_stealth();
	self thread sped_up_unload_loop( align_ent );
	
	if(self.script_noteworthy == "truck_guard1")
	{
		self thread guard1_detach_stuff();
	}
	else
	{
		self thread guard2_detach_stuff();
	}		
	
	// wait till getting alerted
	flag_wait("comp_player_near_trucks");
	align_ent thread anim_single_aligned( self, "unload_react" );
	
	// this AI is killable now
	self.allowdeath = 1;

	// stop ignoring everyone
	self set_ignoreall( false );
	self set_ignoreme( false );
}


guard1_detach_stuff()
{
	self endon("death");
	
	flag_wait("comp_player_near_trucks");
	
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
	
	flag_wait("comp_player_near_trucks");
	
	if (isAlive(self) && level.paper2)
	{
		self Detach("dest_glo_paper_02_d0", "tag_inhand");
	}
}

sped_up_unload_loop( align_ent ) // self = truck AI
{
	self endon( "death" );
	level endon("comp_player_near_trucks");

	rate = 1.5;
	anim_length = GetAnimLength( level.scr_anim[ "compound_truck_guard_1" ][ "unload_loop" ][ 0 ] ) / rate;
	
	while(1)
	{
		self AnimScripted( "fast_unload_anim", align_ent.origin, align_ent.angles, level.scr_anim[ self.animname ][ "unload_loop" ][ 0 ], "normal", undefined, rate );
		wait( anim_length );
	}
}

truck_stairs_enemies_stealth() // self = truck AI
{
	
	self endon( "death" );
	level endon("comp_player_near_trucks");
	
	// wait until player is pass the convoy
	flag_wait( "convoy2_clear" );

	// start listening for stealth event listeners
	for( i=0; i<level.stealth.listeners.size; i++)
	{
		self AddAIEventListener( level.stealth.listeners[i] );	
	}

	self waittill_any( "damage", level.stealth.listeners[0], level.stealth.listeners[1], level.stealth.listeners[2] );

	flag_set("comp_player_near_trucks");	

}

// --------------------------------------------------------------------------------
// ---- Staircase enemies death animations  ----
// --------------------------------------------------------------------------------
staircase_enemy_set_deathanim()
{
	self.deathAnim = level.scr_anim[ self.script_animname ][ "death_anim" ];

}

staircase_enemy_think()
{
	//self = non truck AI. 1 in shack, another top of stairs
	self endon( "death" );
	
	self.ignoreme = 1;
	self.ignoreall = 1;
	
	// wait until player is pass the convoy
	flag_wait( "convoy2_clear" );
	
	self thread truck_stairs_enemies_stealth();
	
	if( (IsDefined(self.script_noteworthy)) && (self.script_noteworthy == "bottom_guy") )
	{
		thread bottom_stairs_guy_think();
	}	
	else
	{
		self.deathAnim = level.scr_anim[ self.script_animname ][ "death_anim" ];
	}	
	
	flag_wait ("comp_player_near_trucks");
	
	self.ignoreme = 0;
	self.ignoreall = 0;
	
	//both AI become alerted: Guy 1 appears top of steps
	if( (IsDefined(self.script_noteworthy)) && (self.script_noteworthy == "top_guy") )
	{
		node = GetNode ("top_guy", "targetname");
		self SetGoalNode (node);
	}
	else
	{
		//guy 2 rushes player
		self SetGoalEntity (get_players()[0]);
	}	

}	


bottom_stairs_guy_think()
{
	//self = AI in shack next to truck
	self endon ("death");
	level endon ("comp_player_near_trucks");
	flag_wait( "convoy2_clear" );
	wait(RandomFloatRange(3,5) );
	node = GetNode ("bottom_guy_node", "targetname");
	self SetGoalNode (node);
}	


mansion_portals_hide()
{
	
	SetCellInvisibleAtPos( (-512, 2272, 580) ); //breach room
	SetCellInvisibleAtPos( (14, 2272, 574) ); // Castro room
}	
