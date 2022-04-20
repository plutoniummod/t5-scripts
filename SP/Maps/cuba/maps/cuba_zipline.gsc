#include common_scripts\utility;
#include maps\_flyover_audio;
#include maps\_utility;
#include maps\cuba_util;
#include maps\cuba_anim;
#include maps\_anim;
#include maps\_music;

#using_animtree("generic_human");
start()
{
	level thread maps\cuba_street::cleanup();

	battlechatter_on();

	flag_set("transition_sky");

	event_thread( "zipline", ::zipline_main );

	flag_wait( "zipline_event_done" );
	autosave_by_name("zipline_event_done");
}

setup_zipline_flags()
{
	// FLAGS INITILIAZED BY KVP'S IN RADIANT SHOULD GO HERE
	flag_init("compound_gates_opened");				// set when the compound gates have been opened for convoy
	flag_init("compound_gates_closed");				// set when the compound gates are closed already
	flag_init("invasion_start");		   			// set when invasion should start
	flag_init("player_zipline_ready");	   			// set when player presses X to zipline	
	flag_init("player_entered_zipline"); 			// set when player player linked and plays entry animation of zipline
	flag_init("woods_ahead_on_zipline");   			// set when woods is set ahead of the player properly on zipline
	flag_init("player_zipline_exit_started");		// set when player starts the exit animation
	flag_init("start_ai_exit");					    // set when AI should play their exit animation
	flag_init("zipline_event_done");	   			// set when the zipline event is done	
}

// --------------------------------------------------------------------------------
// ---- Zipline main function ----
// --------------------------------------------------------------------------------
zipline_main()
{		
	ClearAllCorpses();//SHolmes: per James S removing corpses from Streets
	 
	level.bowman 	 = get_hero_by_name( "bowman" );
	level.woods 	 = get_hero_by_name( "woods" );
	level.friendlies = array( level.bowman, level.woods );

	// set blend in and blend outs for scripted animations
	//array_func( level.friendlies, ::anim_set_blend_in_time, 0.2 );
	//array_func( level.friendlies, ::anim_set_blend_out_time, 0.2 );
		
	// this flag will be set when bowman and woods finish anim_reach to zipline animation
	// also when the player is in position to start the zipline event
	array_func( level.friendlies, ::ent_flag_init, "in_pos_for_zipline" );

	// no random heat anims for woods and bowman	
	level.woods disable_heat();
	level.bowman disable_heat();

	level.woods.noHeatAnims  = 1;
	level.bowman.noHeatAnims = 1;

	// zipline doesnt use color system
	level.woods  disable_ai_color();
	level.bowman disable_ai_color();

	// invasion ambiance - flare, planes, security patrols and vehicles
	level thread invasion_ambiance();

	// do ai zipline
	level thread zipline_ai_think();

	// spawn zipline enemies that are killed by woods and bowman
	level thread zipline_enemies_think();
	
	// do player zipline
	level thread zipline_player_think();
}

invasion_start( guy )	// animation callback
{
	// now we know player is in position start the invasion
	flag_set( "invasion_start" );
}

// --------------------------------------------------------------------------------
// ---- Zipline player ----
// --------------------------------------------------------------------------------
zipline_player_think()
{
	player = get_players()[0];
	player SetLowReady( true );
	
	flag_wait( "player_zipline_ready" );
	player DisableWeapons();

	// start art transition traking as player is going down the zipline
	flag_set( "art_trasition_tracking" );

	// setup start align node
	start_node = getstruct( "zipline_player", "targetname" );
	start_node.angles = ( 0, 90, 0 );

	// set up end point 
	end_node = getstruct( "zipline_player_end", "targetname" );
	
	end_struct = SpawnStruct();
	end_struct.origin = GetStartOrigin( end_node.origin, end_node.angles, level.scr_anim["player_hands"]["zipline_exit"] );
	end_struct.angles = GetStartAngles( end_node.origin, end_node.angles, level.scr_anim["player_hands"]["zipline_exit"] );
		
	// spawn actual fullbody model, and put it in first frame
	level.player_model = spawn_anim_model("player_hands");
	level.player_model.animname = "player_hands";
	start_node anim_first_frame( level.player_model, "zipline_entry" );

	// hide the model until the animation starts, and the player is in place
	level.player_model Hide();

	// lerp the player to the position
	player lerp_player_view_to_position( level.player_model GetTagOrigin( "tag_player" ), level.player_model GetTagAngles( "tag_player" ), 0.5 );
	
	// attach hook
	level.player_model Attach("anim_rus_zipline_hook", "tag_weapon");

	/#
		level thread debug_tag_player_tag_camera();
	#/


	// link the player to this model
	player PlayerLinkToAbsolute( level.player_model, "tag_player" );
	
	// set depth of field settings on the player
	maps\createart\cuba_art::set_cuba_dof( "zipline" );

	// now player is linked to the zipline
	flag_set("player_entered_zipline");
	//Tuey set music to zipline
	setmusicstate ("ZIPLINE");

	level thread maps\cuba_amb::air_raid_sound();

	// zipline entry
	level.player_model Show();
	start_node anim_single_aligned( level.player_model, "zipline_entry" );
	
	// allow little headlook now
	//player PlayerLinkTo( level.player_model, "tag_player", 0, 20, 20, 10, 20 );

	// now player needs to idle and move down the zipline
	move_ent = Spawn( "script_model", level.player_model GetTagOrigin( "tag_origin" ) );
	move_ent SetModel( "tag_origin" );
	move_ent.angles = level.player_model GetTagAngles( "tag_origin" );

	// link the player body to this model
	level.player_model LinkTo( move_ent, "tag_origin", ( 0, 0, 0 ),  ( 0, 0, 0 ) );

	// start rumble and screenshake
	player thread player_zipline_effects();

	// play idle animation
	//level thread anim_loop( level.player_model, "zipline_idle" );
	level.player_model SetAnim( level.scr_anim["player_hands"]["zipline_idle"][0], 1, 0.2 );
	
	//kevin adding zipline audio
	player playloopsound( "evt_zipline_slide" , 1 );

	// now move the start point ent to the end position over some time
	move_ent MoveTo( move_ent.origin + vector_scale( ( end_struct.origin - move_ent.origin ), 1.5 ), 6, 0.1, 1 );
	
	dist = Distance2D( move_ent.origin, end_struct.origin );
	while(  dist > 16 )
	{
		wait(0.05);
		dist = Distance2D( move_ent.origin, end_struct.origin );
	}

	player stoploopsound(.1);
	
	// player is at the end of the zipline, start exit, no headlook
	level.player_model Unlink();
	
	//player StartCameraTween( 0.5 );
	//player PlayerLinkToAbsolute( level.player_model, "tag_player" );	

	flag_set( "player_zipline_exit_started" );

	// hide the player model
	//level.player_model Hide();
	
	end_node anim_single_aligned( level.player_model, "zipline_exit" );
		
	// unlink the player
	player Unlink();

	// delete the model as we dont need it anymore
	move_ent Delete();

	player EnableWeapons();
	player SetLowReady(false);

	// reset DOF
	maps\createart\cuba_art::reset_cuba_dof();

	flag_set( "zipline_event_done" );

	// delete the player model
	level.player_model Delete();
}

/#
debug_tag_player_tag_camera()
{
	while( !flag( "zipline_event_done" ) )
	{
		start = level.player_model GetTagOrigin( "tag_player" );
		end = start + vector_scale( AnglesToForward( level.player_model GetTagAngles( "tag_player" ) ), 100 );
		RecordLine( start, end, ( 1,1,1 ), "Script", level.player_model );

		start = level.player_model GetTagOrigin( "tag_camera" );
		end = start + vector_scale( AnglesToForward( level.player_model GetTagAngles( "tag_camera" ) ), 100 );
		RecordLine( start, end, ( 1,1,1 ), "Script", level.player_model );

		wait(0.05);	
	}
}
#/

player_zipline_effects() // self = player
{	
	self SetBlur( 0.7, 1 );
	self PlayRumbleLoopOnEntity( "damage_heavy" );
	timescale_tween( 1, 2.0, 1.2 );

	while( !flag( "player_zipline_exit_started" ) )
	{
		Earthquake( 0.2, 0.1, level.player_model GetTagOrigin( "tag_weapon" ), 60 );	
		wait(0.1);
	}

	self StopRumble( "damage_light" );
	self StartFadingBlur( 1, 0.1 );
	
	timescale_tween( 2.0, 1, 1 );
	
	wait 0.5;
	
	flag_set( "zipline_event_done" );
}

zipline_player_objective() // self = player
{
	level thread zipline_nag_delay();
	
	// set up a trigger objective on the trigger
	trigger = GetEnt( "player_zipline_trig", "targetname" );

	obj_struct = SpawnStruct();
	obj_struct.origin = trigger.origin;

	set_objective( level.OBJ_ZIPLINE, obj_struct, "" );

	self look_at_and_use( "player_zipline_trig", "targetname", Cos(90), undefined, &"CUBA_ZIPLINE_HUD", "player_zipline_ready", true );

	//Objective_State(level.OBJ_ZIPLINE, "done");
	
}

zipline_nag_delay()
{
	
	wait(4);
	if(!flag("player_zipline_ready"))
	{	
		// start nag lines from woods to the player
		nag_array = create_woods_nag_array( "zipline" );
		level.woods thread do_vo_nag_loop( "woods", nag_array, "player_zipline_ready", 6 );
	}	
	
}	


start_ai_exit( guy )
{
	flag_set( "start_ai_exit" );
}

player_on_ground( guy )
{
	// SUMEET - Need sound and effects here 
	player = get_players()[0];
	Earthquake( .8, 1.5, player.origin, 100 );	
	exploder( 410 );
}

// --------------------------------------------------------------------------------
// ---- Zipline ai ----
// --------------------------------------------------------------------------------
zipline_ai_think()
{	
	// go to zipline ( anim_reach )
	array_thread( level.friendlies, ::go_to_and_setup_zipline );

	// and start zipline
	array_thread( level.friendlies, ::do_zipline );
}

go_to_and_setup_zipline() // self = bowan/woods
{
	// setup align nodes, and rope
 	setup_ai_zipline();

	// setup the crossbow, put it in the right position
	self thread zipline_setup_crossbow();

	// send AI to the zipline intro animation node
	self.start_node anim_reach_aligned( self, "zipline_in" );

	self ent_flag_set( "in_pos_for_zipline" );
}

setup_ai_zipline()
{
	// setup zipline start node
	setup_start_node();
		
	// setup zipline end node
	setup_end_struct();

	// rope
	zipline_setup_rope();
}

setup_start_node() // self = woods/bowman
{
	// get the alignment node for the zipline in animation
	if( self == level.woods )
	{
		self.start_node = getstruct( "zipline_player", "targetname" );
		self.start_node.angles = ( 0,90,0 );
	}
	else
	{
		self.start_node = getstruct( "zipline_bowman", "targetname" );
		self.start_node.angles = ( 0,90,0 );
	}
}

setup_end_struct() // self = woods/bowman
{
	// get the alignment node for the zipline in animation
	if( self == level.woods )
		self.end_node = getstruct( "zipline_player_end", "targetname" );
	else
		self.end_node = getstruct( "zipline_bowman_end", "targetname" );
		
	// end point of the zipline is based on the exit animation 
	// get the delta for exit animations from the align nodes for exits
	// this is where AI will need to be when the zipline exit animation needs to start
	self.end_struct = SpawnStruct();
	self.end_struct.origin = GetStartOrigin( self.end_node.origin, self.end_node.angles, level.scr_anim[self.animname]["zipline_exit"] );
	self.end_struct.angles = GetStartAngles( self.end_node.origin, self.end_node.angles, level.scr_anim[self.animname]["zipline_exit"] );
}	

do_zipline() // self = bowman/woods
{			

/#
	self thread debug_zipline( self.start_node.origin, self.end_node.origin, ( 1, 0, 0 ) );
#/

	// play the zipline in animation
	self.start_node anim_single_aligned( self, "zipline_in" );
		
	// now start idle animation
	self.start_node thread anim_loop_aligned( self, "zipline_loop" );

	// woods is ready on the zipline now
	if( self == level.woods )
	{
		flag_set( "woods_ahead_on_zipline" );
	
		get_players()[0] thread zipline_player_Objective(); // give a prompt to the player to hook up
	}

	// wait for the player to stack up
	flag_wait("player_zipline_ready");

	// spawn another rope that is smaller and straight
	zipline_setup_second_rope();

	// get on the rope
	self.start_node anim_single_aligned( self, "zipline_start" );	
	
	// now that the in animation is finished, create move entity at the origin of this AI
	self.move_ent = create_move_ent();

	// disabling clientside linkto to avoid the hitching in the animation
	self DisableClientLinkTo();

	// link AI to move entity
	self LinkTo( self.move_ent, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );

	self thread anim_loop( self, "zipline_idle" );	

	flag_wait( "player_entered_zipline" );
	
	if( self == level.woods )
	{
		wait(0.5);
		thread zipline_move_along_rope( 9, 3.5, 2 );
	}
	else
	{
		thread zipline_move_along_rope( 9.5, 3, 1 );
	}
				
	flag_wait( "start_ai_exit" );

	self Unlink();
	
	// this notification will also start zipline enemies animations
	self notify("start_exit");

	// exit animation
	self.end_node anim_single_aligned( self, "zipline_exit" );

	// delete the start offset model as we dont need it anymore
	self.move_ent Delete();

	// enable clientside linkto back again
	self EnableClientLinkTo();
}

// spawn zipline move entity that will take the AI down along the zipline rope
create_move_ent() // self = bowman / woods
{
	move_ent = Spawn( "script_model", self.origin );
	move_ent SetModel( "tag_origin" );
	move_ent.angles = self.end_struct.angles;

	return move_ent;
}

// this function moves the zipline move entity to the end of the zipline
zipline_move_along_rope( zipline_time, accel_time, decel_time ) // self = woods / bowman
{

	// AI will keep moving down the zipline until player jumps down 
	// this is to avoid paused hanging AI in place
	// once player jumps down AI will be poped in place
	move_to_end = self.move_ent.origin + vector_scale( self.end_struct.origin - self.move_ent.origin, 1.5 );

/#
	self thread debug_zipline( self.move_ent.origin, move_to_end, ( 1, 1, 1 ) );
#/
	
	self playloopsound( "evt_zipline_slide_ai" , 1 );
	
	self.move_ent thread zipline_rotate( self.end_struct.angles, zipline_time/2  );

	self.move_ent MoveTo( move_to_end, zipline_time, accel_time, decel_time );	
	
	flag_wait( "start_ai_exit" );
	
	self stoploopsound(.1);
}

zipline_rotate( angles, time ) // self = player's, woods's, bowman's move ent
{
	self RotateTo( angles, time );
}

#using_animtree( "cuba" );

zipline_setup_crossbow() // self = woods/bowman
{
	crossbow = GetEnt( self.animname + "_crossbow", "targetname" );
	crossbow init_anim_model("crossbow", true);

	self.start_node thread anim_loop_aligned( crossbow, self.animname + "_setup" );

	flag_wait( "zipline_event_done" );

	crossbow Delete();
}

#using_animtree( "generic_human" );
zipline_setup_rope() // self = woods / bowman
{
	crossbow = GetEnt( self.animname + "_crossbow", "targetname" );
	origin = crossbow GetTagOrigin( "tag_flash" );
	
	self.anchor = Spawn( "script_model", origin );
	self.anchor SetModel( "tag_origin" );

	self.anchor LinkTo( crossbow );

	length_of_rope = Distance( self.start_node.origin, self.end_node.origin ) * 0.3;

	self.rope = CreateRope( self.start_node.origin, ( 0, 0, -1 ), length_of_rope, self.anchor, "tag_origin" );

	ropesetflag( self.rope, "collide", 1 );
}

zipline_setup_second_rope() // self = woods / bowman
{
	DeleteRope( self.rope  );

	self.rope = CreateRope( self.start_node.origin, ( 0, 0, -1 ), 100, self.anchor, "tag_origin" );

	ropesetflag( self.rope, "collide", 1 );
}

rope_shoot_think( guy )  // self = woods / bowman
{
	guy.anchor Unlink();
	
	ropesetflag( guy.rope, "collide", 0 );

	// hide the flash tag so that the hook on the gun will disappear
	crossbow = GetEnt( guy.animname + "_crossbow", "targetname" );
	crossbow HidePart( "tag_flash" );

	// now spawn additional hook-only model and link it to the the rope with the same angles as the tag flash 
	// of the gun so that the rope will appear as if its travelling with the hook
	rope_hook = Spawn( "script_model", crossbow GetTagOrigin( "tag_flash" ) );
	rope_hook.angles = crossbow GetTagAngles( "tag_flash" );
	rope_hook SetModel( "t5_weapon_al54_hook" );
	rope_hook LinkTo( guy.anchor );

	guy.anchor MoveTo( guy.end_node.origin, RandomFloatRange( 2.5, 3.5 ) );
	guy.anchor waittill("movedone");

	// waittill player is at mansion door and delete the rope entity and the rope too
	flag_wait( "mansion_door_opened" );

	// delete the rope hook and anchor entity
	rope_hook Delete();	
	guy.anchor Delete();

	DeleteRope( guy.rope  );
}

crossbow_attach( guy )
{
	crossbow = GetEnt( guy.animname + "_crossbow", "targetname" );
	crossbow LinkTo( guy, "tag_weapon_right", ( 0, 0, 0 ), ( 0, 0, 0 ) );
}

crossbow_detach( guy )
{
	crossbow = GetEnt( guy.animname + "_crossbow", "targetname" );
	crossbow Unlink();	
}

hook_attach( guy )
{
	guy.hook = Spawn( "script_model", ( 0,0,0 ) );
	guy.hook SetModel( "anim_rus_zipline_hook" );

	/#
		RecordEnt( guy.hook );
	#/


	guy.hook LinkTo( guy, "tag_weapon_left", ( 0,0,0 ), ( 0,0,0 ) );
}

hook_detach( guy )
{
	guy.hook Delete();
}


ai_on_ground( guy ) // friendly AI land on the ground
{	
	// play dust effects on landing
	if( guy == level.woods )
		exploder( 411 );	
	else
		exploder( 412 );
}

// --------------------------------------------------------------------------------
// ---- Two zipline enemies that are killed by heros ----
// --------------------------------------------------------------------------------
zipline_enemies_think()
{
	// spawn these enemies after the zipline is ready, when player is not looking
	flag_wait( "player_zipline_ready" );

	simple_spawn( "zipline_enemies", ::zipline_enemies_idle_and_death );
}

zipline_enemies_idle_and_death() // self = zipline enemy AI
{
	self endon("death");

	// get the related allies zipline hero that is going to kill this AI
	if( self.script_noteworthy == "bowman_enemy" )
	  zipline_ally = level.bowman;
	else
	  zipline_ally = level.woods;	

	// keep playing the idle animation until this AI is killed
	zipline_ally.end_node thread anim_loop_aligned( self, "zipline_idle" );	

	// waittill zipline enemy start exit animation
	zipline_ally waittill("start_exit");

	// play the exit_death animation, it has start_ragdoll noterack in it. that will kill the AI
	zipline_ally.end_node anim_single_aligned( self, "zipline_exit" );
}



// --------------------------------------------------------------------------------
// ---- Zipline End ----
// --------------------------------------------------------------------------------



// --------------------------------------------------------------------------------
// ---- Invasion ambiance ----
// --------------------------------------------------------------------------------
invasion_ambiance()
{	
	player = get_players()[0];
	
	// compound gates
	maps\cuba_compound::compound_gates_open();

	// thread that closes the gates when needed
	level thread maps\cuba_compound::compound_gates_close();	

	// security patrol, vehicle, 
	level thread compound_security_think();	
	
	// planes
	level thread invasion_planes_think();
		
	// sound, sirens
	
}

// --------------------------------------------------------------------------------
// ---- Compound security main ----
// --------------------------------------------------------------------------------
compound_security_think()
{
	// spawn the patrollers on the roof and in the building
	compound_patrollers = simple_spawn( "comp_security_patrol", ::compound_non_alert_patrollers_think );

	// this thread spawns a random vehicles on the path in the compound before the zipline 
	//level thread compound_security_vehicles_think(); //SHolmes removing convoy until radio room event per performce notes

	// wait until the invasion starts 
	flag_wait("invasion_start");

	// then start spawning alerted guys in the compound
	level thread compound_alert_patrollers_think();

	// wait for players zipline finished, and kill all the ambiant guys
	flag_wait("zipline_event_done");
	array_thread( get_ai_group_ai( "compound_ambiant_ai" ), ::self_delete );
}

// --------------------------------------------------------------------------------
// ---- Compound security Patrollers ----
// --------------------------------------------------------------------------------

// patrollers, run to safe spot after the invasion starts and delete themselves
compound_non_alert_patrollers_think() // self = patroller
{
	self endon("death");

	// as the invasion starts these AI will go into the small room and get killed.
	flag_wait("invasion_start");

	// now stop patrolling and run into the room
	self notify( "end_patrol" );
	
	wait( RandomFloatRange( 0.1, 1.0 ) );

	self set_goalradius( 16 );
	self set_goal_node( GetNode( self.script_noteworthy, "targetname" ) );
	self waittill( "goal" );

	self Delete();
}


// alert patrollers, spawned in after the invasion starts and start running towards the airfield
compound_alert_patrollers_think()
{
	spawner = GetEnt( "comp_security_alerted_patrol", "targetname" );
	spawner_count = spawner.count;
	spawned_count = 0;

	// if player has finished ziplining then we dont need to spawn anymore	
	while( !flag( "zipline_event_done" ) )
	{
		patroller = simple_spawn_single( "comp_security_alerted_patrol", ::sprint_patrollers_movement, "comp_security_alerted_patrol_node", "zipline_event_done" );
		spawned_count++;
		wait(4);
	}

	// delete the spawner if its not exhausted yet, frees the entity count
	if( spawner_count < spawner_count )
		spawner	Delete();
}

// --------------------------------------------------------------------------------
// ---- Compound security vehicles ----
// --------------------------------------------------------------------------------

compound_security_vehicles_think()
{
	start_node = GetVehicleNode( "convoy2_start_node", "targetname" );

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


	// having these vehicles keep going until the first contextual melee guy is being attacked by the player
	while( !flag( "zipline_event_done" ) )
	{
		index = RandomIntRange( 0, vehicles.size );

		model_name = vehicles[index].model;
		vehicle_type = vehicles[index].vehicle_type;

		// spawn the vehicle
		vehicle = SpawnVehicle( model_name , "security_vehicle", vehicle_type, start_node.origin, start_node.angles );
		vehicle.script_lights_on = 1;			
		vehicle.script_vehicle_selfremove = 1; 
		//vehicle NotSolid();
		vehicle.script_string = "no_deathmodel"; 		
		maps\_vehicle::vehicle_init( vehicle );   
		
		// if invasion is started, then speed all the vehicles now
		if( flag("invasion_start") )
			array_func( GetEntArray( "security_vehicle", "targetname" ), ::compund_vehicle_move_faster );
		
		// send this plane along the path
		vehicle thread go_path( start_node );

		wait(3);
	}
}

compund_vehicle_move_faster() // self = vehicle
{
	self SetSpeedImmediate( 35, 10, 5 );
}

// --------------------------------------------------------------------------------
// ---- Planes ----
// --------------------------------------------------------------------------------

invasion_planes_think()
{
	// wait until the invasion starts 
	flag_wait("invasion_start");

	// start ambiant planes thread
	level thread ambiant_planes( "zipline_event_done", "zipline" );

	level thread bomb_exploder_think(); // start a thread that waits for a perticular node and then sets off a exploder

	// get two starting nodes for invasion planes and spawn planes
	array_thread( GetVehicleNodeArray( "invasion_plane_nodes", "targetname" ), ::invasion_planes_think_internal );

	// wait until player start the Zipline and have additional plane go on top of the player
	wait(2);
	array_thread( GetVehicleNodeArray( "invasion_plane_zipline_node", "targetname" ), ::invasion_planes_think_internal_short );	
}
invasion_planes_think_internal_short()
{
	plane = SpawnVehicle("t5_veh_jet_mig17_gear", "invasion_bombers", "plane_mig17_gear", self.origin, self.angles);
	plane.script_numbombs =  3;			 	// give 3 bombs
	plane.script_vehicle_selfremove = 1; 	// remove at the end of the path
	plane.script_string = "no_deathmodel"; 		
	maps\_vehicle::vehicle_init( plane );  
	plane thread plane_position_updater (3200, "evt_f4_short_wash", "null"); 
	
	// send this plane along the path
	PlayFXOnTag( level._effect["jet_contrail"], plane, "tag_left_wingtip" );
	PlayFXOnTag( level._effect["jet_contrail"], plane, "tag_right_wingtip" );

	plane go_path( self );
	
	
}
invasion_planes_think_internal() // self = starting node
{	
	plane = SpawnVehicle("t5_veh_jet_mig17_gear", "invasion_bombers", "plane_mig17_gear", self.origin, self.angles);
	plane.script_numbombs =  3;			 	// give 3 bombs
	plane.script_vehicle_selfremove = 1; 	// remove at the end of the path
	plane.script_string = "no_deathmodel"; 		
	plane.script_numbombs = 2;

	maps\_vehicle::vehicle_init( plane );  

	PlayFXOnTag( level._effect["jet_contrail"], plane, "tag_left_wingtip" );
	PlayFXOnTag( level._effect["jet_contrail"], plane, "tag_right_wingtip" );

	// send this plane along the path
	plane go_path( self );
	
}

bomb_exploder_think()
{
	// get all the vehicle nodes that are supposed to trigger exploders
	array_thread( GetVehicleNodeArray( "exploder_node", "script_noteworthy" ), ::tigger_bomb_exploders );
}

tigger_bomb_exploders() // self = vehicle node
{
	self waittill( "trigger" );

	playsoundatposition ("evt_bomb_distant", self.origin);

	// script int stores the exploder id
	if( IsDefined( self.script_int ) )
		exploder( self.script_int );
}

// --------------------------------------------------------------------------------
// ---- Flare ----
// --------------------------------------------------------------------------------

invasion_flare( guy )
{
	level thread invasion_church_bell();
	
	//TUEY set music state to FLARE
	setmusicstate ("FLARE");
	
	flare = maps\_vehicle::spawn_vehicle_from_targetname( "invasion_flare" );
	flare thread go_path();

	playsoundatposition ("evt_flare_launch", (-5712, -3776, -56));

	// play regualar trail
	model = spawn( "script_model", (0,0,0) );
	model SetModel( "tag_origin" );
	model LinkTo( flare, "tag_origin", (0,0,0), (0,0,0) );
	PlayFXOnTag( level._effect["flare_trail"], model, "tag_origin" );
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


// --------------------------------------------------------------------------------
// ---- Debug Section ----
// --------------------------------------------------------------------------------
/#

debug_zipline( start, end, color ) // self = bowman/ woods
{
	level endon("zipline_event_done");

	while(1)
	{
		// draw start and end of the rappel
		RecordLine( start, end, color, "Script", self );

		wait(0.05);
	}
}

#/

//*********************
//  AUDIO
//*********************

invasion_church_bell()
{
	// wait until the invasion starts 
//	flag_wait("invasion_start");

	playsoundatposition( "evt_bayofpigs_churchbell", (-5712, -3776, -56 ));
    
}
