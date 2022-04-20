#include maps\_utility;
#include common_scripts\utility; 
#include maps\_anim;
#include maps\river_drag_util;

main()
{
	// once both flags below are set the boat drag can initiate
	flag_init( "drag_chinook_in_position" );		// chinook flew in and stopped at the end position
	flag_init( "player_in_position_for_drag" ); // player boat finished the rail and is at end position
	
	flag_init( "second_impact" ); // used to time fx
	flag_init( "third_impact" ); // used to time fx
			
	flag_init( "player_pressed_rope_tie_button" ); // player pressed the rope-tying button
	
	flag_init( "rope_cut_failed" ); // boat crashed to shore, game over
	flag_init( "rope_cut_success" ); // player just cut the rope
	flag_init( "drag_anim_complete" ); // after rope cut success, boat finishes settling down anim
	flag_init( "drag_end_vo_complete" ); // all the talking is finished
		
	level.drag_use_rope_tech = false;
	
	// delete any existing AIs
	bow_gun_guy = getent( "bow_gun_redshirt_ai", "targetname" );
	safe_delete_ent( bow_gun_guy );
	delete_all_enemies();
	
	level thread test_anims();

	// prepare boats and AIs
	initial_preparation();
	
	trigger_use( "drag_chinook_spawn_trigger" );
		
	// wait for player to drive into a trigger
	//flag_wait( "drag_chinook_in_position" );	
	trigger_wait( "drag_sequence_starts" );
	//iprintlnbold( "WOODS: Mason, get us in position for the lift." );
	
	// docking_sequence
	pre_drag_docking_sequence();
	
	// wait for both player and chinook to be in position
	flag_wait_all( "drag_chinook_in_position",  "player_in_position_for_drag" );
	
	// any additional setup just prior to animation
	pre_drag_preparation();
	
	// grab the rope
	pre_drag_grab_rope();
	
	// start the animation
	level thread boat_drag();
	
	flag_wait( "drag_anim_complete" );
		
	// anything to clean up in the end
	drag_aftermath();
	
	drag_cleanup();
	
	flag_wait( "drag_end_vo_complete" );
	level waittill( "player_driving_boat_again" );
}

test_anims()
{
	wait( 5 );
	//level notify("pbr_debris_start");
}

dev_skip_boat_drag()
{
	level thread drag_fade_to_black( 4, 4 );
	
	wait( 5 );
	
	river_pacing_start = getstruct( "river_pacing_boat_start_new", "targetname" );
	AssertEx( IsDefined( river_pacing_start ), "river_pacing_start is missing" );
	
	// Force tye boat and player to look in the direction of the pacing section
	level.boat.angles = river_pacing_start.angles;
	level.boat.origin = river_pacing_start.origin;
	get_players()[0] SetPlayerAngles( river_pacing_start.angles );
}


//---------------------------------------------------------------------------

initial_preparation()
{
	add_spawn_function_veh( "drag_chinook", ::drag_chinook_think );
	add_spawn_function_veh( "drag_huey_1", ::drag_huey_1_think );
	add_spawn_function_veh( "drag_huey_2", ::drag_huey_2_think );
	
	// leg for player (need to change to a full model)
	level.player_legs = simple_spawn_single( "boat_drag_player_legs" );
	level.player_legs.animname = "player_legs";
	
	// ais along the ride
	level.boat_drag_guys = [];
	level.boat_drag_guys[0] = level.woods;
	level.boat_drag_guys[1] = level.bowman;
	level.boat_drag_guys[2] = level.reznov;
	level.boat_drag_guys[3] = simple_spawn_single( "boat_drag_guy_4" );
	level.boat_drag_guys[3].animname = "boat_guy_4";
	level.boat_drag_guys[3] hide();
	
	level.woods StopAnimScripted();
	level.bowman StopAnimScripted();
	level.reznov StopAnimScripted();
	
	wait( 0.05 );
	level.boat_drag_guys[0].animname = "woods";
	level.boat_drag_guys[1].animname = "bowman";
	level.boat_drag_guys[2].animname = "reznov";
	
	//level.drag_chinook Hide();
	level.drag_crash_pbr_1 = GetEnt( "drag_crash_pbr_1", "targetname" );
	level.drag_crash_pbr_2 = GetEnt( "drag_crash_pbr_2", "targetname" );
	level.drag_crash_pbr_3 = GetEnt( "drag_crash_pbr_3", "targetname" );
	level.drag_crash_pbr_1 pbr_attach_props();
	level.drag_crash_pbr_2 pbr_attach_props();
	level.drag_crash_pbr_3 pbr_attach_props();
	level.drag_crash_pbr_1 Hide();
	level.drag_crash_pbr_2 Hide();
	level.drag_crash_pbr_3 Hide();
	
	// link the ropes
	level.drag_rope_1_end.origin = level.boat GetTagOrigin( "tag_body" );
	level.drag_rope_1_end.angles = level.boat GetTagAngles( "tag_body" );
	level.drag_rope_1_end linkto( level.boat, "tag_body" );
	
	//reset_ai_after_boat_drag();
}

reset_ai_after_boat_drag()
{
	// put woods back into a normal AI state
	level.woods AllowedStances( "stand", "crouch", "prone" );
	level.woods gun_switchto( "commando_acog_sp", "right" );
	level.woods useweaponhidetags( "commando_acog_sp" );
	level.woods notify( "stop_rpg_turret_ai" );
	
	// put bowman back into normal AI state
	level.bowman AllowedStances( "stand", "crouch", "prone" );
	level.bowman gun_switchto( "commando_acog_sp", "right" );
	level.bowman useweaponhidetags( "commando_acog_sp" );
	level.bowman notify( "stop_rpg_turret_ai" );	
	level.boat notify( "stop_player_aim_entity_update" );
	
	level.bowman ClearEntityTarget();
	level.woods ClearEntityTarget();	
	
	level.woods enable_react();
	level.woods.ignoreall = false;
	level.woods enable_pain(); 
	level.woods.grenadeawareness = 1;
	
	level.bowman enable_react();
	level.bowman.ignoreall = false;
	level.bowman enable_pain(); 
	level.bowman.grenadeawareness = 1;	
}

drag_chinook_think( veh )
{
	level.drag_chinook = self;
	
	// link the ropes for the drag
	level.drag_rope_1.origin 			= level.drag_chinook GetTagOrigin( "origin_animate_jnt" );
	level.drag_rope_2_3_4.origin 	= level.drag_chinook GetTagOrigin( "origin_animate_jnt" );
	level.drag_rope_1.angles 			= level.drag_chinook GetTagAngles( "origin_animate_jnt" );
	level.drag_rope_2_3_4.angles 	= level.drag_chinook GetTagAngles( "origin_animate_jnt" );
	level.drag_rope_1 linkto( level.drag_chinook, "origin_animate_jnt" );
	level.drag_rope_2_3_4 linkto( level.drag_chinook, "origin_animate_jnt" );
	
	// play fx
	PlayFxOnTag( level._effect["chinook_blade"], level.drag_chinook, "main_rotor_jnt" );
	PlayFxOnTag( level._effect["chinook_blade"], level.drag_chinook, "tail_rotor_jnt" );
	
	PlayFxOnTag( level._effect["chinook_spotlight"], level.drag_chinook, "tag_light_belly" );

	level.drag_chinook thread attach_arrival_ropes();
	
	//play VO 
	self.animname = "chinook";
	self thread vo_chinook_arrival();
}

drag_huey_1_think()
{
	level endon( "drag_starts" );
	
	// at some point the huey starts firing
	vehicle_node_wait( "drag_huey_1_firing" );
	firing_target = getent( "drag_huey_1_target", "targetname" );
	self thread periodic_firing_mg_at_target( firing_target, "drag_starts" );
	self thread periodic_firing_back_from_target( firing_target, "drag_starts" );
	
	self waittill( "reached_end_node" );
	self SetVehGoalPos( self.origin, 1 );
	self SetHoverParams( 50, 50, 10 );
}

drag_huey_2_think()
{
	level endon( "drag_starts" );
	self endon( "death" );
	
	// at some point the huey starts firing
	vehicle_node_wait( "drag_huey_2_firing" );
	firing_target = getent( "drag_huey_2_target", "targetname" );
	
	self thread periodic_firing_behavior( firing_target );
	
	self waittill( "reached_end_node" );
	self SetVehGoalPos( self.origin, 1 );
	self SetHoverParams( 50, 50, 10 );
}

periodic_firing_behavior( firing_target )
{
	flag_wait( "drag_chinook_in_position" );
	self thread periodic_firing_back_from_target( firing_target, "drag_starts" );
	
	wait( 3 );
	self thread periodic_firing_mg_at_target( firing_target, "drag_starts" );
}

// fire front turret
periodic_firing_mg_at_target( firing_target, end_msg )
{
	level endon( end_msg );
	self endon( "death" );
	
	flag_wait( "drag_chinook_in_position" );
	while( 1 )
	{
		// pick a target around the actual target
		position = firing_target.origin + ( randomint( 600 ) - 300, randomint( 200 ) - 100, randomint( 200 ) - 100 );
		self SetGunnerTargetVec( position, 2 ); // front gun
		wait( 0.1 );
		
		// fire 2-4 short bursts
		burst = randomintrange( 2, 4 );
		for( i = 0; i < burst; i++ )
		{
			num_shots = randomintrange( 4, 8 );
			for( j = 0; j < num_shots; j++ )
			{
				self FireGunnerWeapon(2);
				wait .2;
			}
			wait( 1 + randomfloat( 0.6 ) );
		}
		
		wait( 2 + randomfloat( 0.6 ) );
	}
}

// enemies fire back
periodic_firing_back_from_target( firing_target, end_msg )
{
	level endon( end_msg );
	self endon( "death" );
	
	while( 1 )
	{
		// pick a start_pos around the actual target
		start_position = firing_target.origin + ( randomint( 600 ) - 300, randomint( 200 ) - 100, randomint( 200 ) - 100 );
		// get the end position near the huey
		end_position = self.origin + ( randomint( 600 ) - 300, randomint( 200 ) - 100, randomint( 200 ) - 150 );
		BulletTracer( start_position, end_position, 1 );
		wait( 0.2 );
	}
}

attach_arrival_ropes()
{
	rope_end = getstruct( "test_chinook_rope_pos", "targetname" );
	
	level.drag_chinook show();
	
	level.drag_chinook.rope_1 = createrope( rope_end.origin, (0,10,0), 955, level.drag_chinook, "tag_light_belly" );
	level.drag_chinook.rope_2 = createrope( rope_end.origin, (-10,5,0), 970, level.drag_chinook, "tag_light_belly" );
	level.drag_chinook.rope_3 = createrope( rope_end.origin, (5,-10,0), 990, level.drag_chinook, "tag_light_belly" );
	level.drag_chinook.rope_4 = createrope( rope_end.origin, (0,0,0), 950, level.drag_chinook, "tag_light_belly" );
	
	ropesetparam( level.drag_chinook.rope_1, "width", 5 );
	ropesetparam( level.drag_chinook.rope_2, "width", 5 );
	ropesetparam( level.drag_chinook.rope_3, "width", 5 );
	ropesetparam( level.drag_chinook.rope_4, "width", 5 );
	
	ropesetflag( level.drag_chinook.rope_1, "force_update", 1 );
	ropesetflag( level.drag_chinook.rope_2, "force_update", 1 );
	ropesetflag( level.drag_chinook.rope_3, "force_update", 1 );
	ropesetflag( level.drag_chinook.rope_4, "force_update", 1 );
	
	ropesetflag( level.drag_chinook.rope_1, "force_update", 1 ); 
	ropesetflag( level.drag_chinook.rope_2, "force_update", 1 ); 
	ropesetflag( level.drag_chinook.rope_3, "force_update", 1 ); 
	ropesetflag( level.drag_chinook.rope_4, "force_update", 1 ); 

	wait( 0.1 );

	RopeRemoveAnchor( level.drag_chinook.rope_1, 0 );
	RopeRemoveAnchor( level.drag_chinook.rope_2, 0 );
	RopeRemoveAnchor( level.drag_chinook.rope_3, 0 );
	RopeRemoveAnchor( level.drag_chinook.rope_4, 0 );
	
	// now move the chinook
	wait( 2.0 );
	trigger_use( "drag_chinook_move_trigger" );
	
	level.drag_chinook waittill( "reached_end_node" );
	level.drag_chinook SetVehGoalPos( level.drag_chinook.origin, 1 );
	level.drag_chinook SetHoverParams( 50, 50, 10 );
	
	flag_set( "drag_chinook_in_position" );
	
	while( !flag( "player_in_position_for_drag" ) )
	{
		wait( 1.5 );
		PhysicsExplosionSphere( level.drag_chinook.origin + ( 0, 0, -800 ), 200, 0, 8 );
	}
	
	level waittill( "tie_rope_to_AI_hands" );
	
	ropesetparam( level.drag_chinook.rope_1, "width", 1 );
	ropesetparam( level.drag_chinook.rope_2, "width", 1 );
	RopeAddEntityAnchor( level.drag_chinook.rope_1, 0, level.woods, ( 0, 0, 55 ) );
	RopeAddEntityAnchor( level.drag_chinook.rope_2, 0, level.bowman, ( 0, 0, 55 ) );
	
	if( level.drag_use_rope_tech == false )
	{
		deleterope( level.drag_chinook.rope_3 );
		deleterope( level.drag_chinook.rope_4 );
	}
	
	wait( 5 );
	if( level.drag_use_rope_tech == false )
	{
		deleterope( level.drag_chinook.rope_1 );
		deleterope( level.drag_chinook.rope_2 );
	}
}

pbr_attach_props()
{
	self Attach( "t5_veh_boat_pbr_stuff", "tag_body" );
	self Attach( "t5_veh_boat_pbr_set01", "tag_body" );
	self Attach( "t5_veh_boat_pbr_antenna_static", "tag_body" );
}

//---------------------------------------------------------------------------

pre_drag_docking_sequence()
{
	level notify( "docking_sequence_initiated" );
	
	// boat is no longer player controlled. Vehicles nodes take over
	level.boat.drivepath = 1;
	
	// remove player from driver position
	player = get_players()[0];
	level.boat UseBy( player );
	
	// remove the Use icon on driver's position
	level.boat MakeVehicleUnusable();
	
	// clear any targets the turret is targeting
	level.boat stopfireweapon();
	level.boat ClearTurretTarget();
	
	// link player to his old tag instead
	player playerlinktodelta( level.boat, "tag_driver", 1, 40, 40, 20, 20, true );
	
	// remove player's weapons, for now
	player take_player_weapons();
	
	// the new boat should move to a spline
	path_start = GetVehicleNode( "rail_docking_boat_start", "targetname" );
	level.boat SetDrivePathPhysicsScale( 3.0 );
	level.boat go_path( path_start );
	
	// wait till the boat reaches the end of the path
	level.boat waittill( "reached_end_node" );
	
	// attach the melee trigger at this point
	level.drag_melee_trigger = GetEnt( "boat_drag_melee_trigger", "targetname" );
	level.drag_melee_trigger EnableLinkto();
	level.drag_melee_trigger Linkto( level.boat );
	
	flag_set( "player_in_position_for_drag" );
	//iprintlnbold( "WOODS: Rescue 1, ready when you are." );
}

//---------------------------------------------------------------------------

pre_drag_preparation()
{
	// show the vehicles
	level.drag_crash_pbr_1 Show();
	level.drag_crash_pbr_2 Show();
	level.drag_crash_pbr_3 Show();
}

//---------------------------------------------------------------------------

#using_animtree ("generic_human");
pre_drag_grab_rope()
{
	// make the vehicles animatible
	level.boat.drivepath = 0;
	level.drag_chinook.drivepath = 0;
	level.boat.supportsAnimScripted = true;
	level.boat ClearVehGoalPos();
	level.drag_chinook.supportsAnimScripted = true;
	level.drag_chinook ClearVehGoalPos();
	
	level thread vo_woods_tie_rope();
	
	// test
	if( level.drag_use_rope_tech )
	{
		level thread grab_rope_actions();
	}
	
	maps\river_util::look_forward_on_boat( level.woods, level.bowman );
	
	// animate the AIs, who are linked to the boat
	level.woods Linkto( level.boat, "tag_origin_animate" );
	level.bowman Linkto( level.boat, "tag_origin_animate" );
	level.reznov Linkto( level.boat, "tag_origin_animate" );
	level.boat_drag_guys[3] Linkto( level.boat, "tag_origin_animate" );
	
	level.reznov hide();
	
	level.boat thread anim_single_aligned( level.woods, "hook_up_ropes" );
	level.boat thread anim_single_aligned( level.bowman, "hook_up_ropes" );
	

	// animate the vehicles
	//level thread play_vehicle_anim_single_solo( level.drag_chinook, "chinook", anim_node, "tie_rope_start" );
	//level thread play_vehicle_anim_single_solo( level.boat, "pbr", anim_node, "tie_rope_start" );
	
	// animate player
	play_player_pre_hook_up_anim();
	
	level notify( "boat_drag_tell_player_grab_rope" );
	player = get_players()[0];
	player SetScriptHintString( &"RIVER_TIE_ROPE" );
	//screen_message_create( &"RIVER_TIE_ROPE" );
	
	// wait for player to press the button
	player = get_players()[0];
	while( player UseButtonPressed() == false )
	{
		wait( 0.05 );
	}
	player SetScriptHintString( "" );
	//screen_message_delete();
	// wait for the rope to finish a loop
	// level waittill( "rope_idle_finished" );
	flag_set( "player_pressed_rope_tie_button" ); 
	
	level thread vo_player_tie_rope();
	
	level thread notify_when_player_turns_around();
	
	level.boat thread anim_single_aligned( level.woods, "rope_done" );
	level.boat thread anim_single_aligned( level.bowman, "rope_done" );
	play_player_finish_hook_up_anim();
	
	// now we can play the rope tie anim
	//level thread play_vehicle_anim_single_solo( level.boat, "pbr", anim_node, "tie_rope" );
	//play_player_anim_on_vehicle( level.boat, "tie_rope", "tag_origin_animate" );
}

notify_when_player_turns_around()
{
	wait( 4 );
	level notify( "player_turns_around" );
}

#using_animtree ( "player" );
play_player_pre_hook_up_anim()
{
	player = get_players()[0];
	player Unlink();

	hands = spawn_anim_model( "player_body" );
	hands.animname = "player_body";

	player.anim_hands = hands;
	
	hands.origin = level.boat GetTagOrigin( "tag_origin_animate" );
	hands.angles = level.boat GetTagAngles( "tag_origin_animate" );
	hands Linkto( level.boat, "tag_origin_animate" );

	// link player to hand
	player PlayerLinkToAbsolute( hands, "tag_player" );

	// animate hand
	level.boat anim_single_aligned( hands, "prepare_rope_hookup" ); 
	
	player StartCameraTween( 1.0 );
}

play_player_finish_hook_up_anim()
{
	player = get_players()[0];
	player.anim_hands.animname = "player_body";
	level.boat anim_single_aligned( player.anim_hands, "hook_up_ropes" ); 
	player unlink();
	player.anim_hands Delete();
}

#using_animtree ("generic_human");
grab_rope_actions()
{
	// we tie 1 rope to the rear left
	RopeAddEntityAnchor( level.drag_chinook.rope_1, 0, level.boat, ( -258.681335, 94.688995, 5.059479 ) + ( 0, 0, 15 ) );
	
	// we link the 2 ropes to entities and then move them to the tags in the front
	rope_mover_1 = spawn( "script_origin", level.boat GetTagOrigin( "snd_stern_port" ) + ( 0, 0, 15 ) ); // rear left
	rope_mover_2 = spawn( "script_origin", level.boat GetTagOrigin( "snd_stern_stbd" ) + ( 0, 0, 15 ) ); // rear right

	RopeAddEntityAnchor( level.drag_chinook.rope_2, 0, rope_mover_1, ( 0, 0, 0 ) );
	RopeAddEntityAnchor( level.drag_chinook.rope_3, 0, rope_mover_2, ( 0, 0, 0 ) );
	
	// these 2 ropes will move to the front of the boat
	rope_mover_1 MoveTo( level.boat GetTagOrigin( "snd_bow_port" ) + ( 0, 0, 15 ) , 3, 0.05, 0.05 );
	rope_mover_2 MoveTo( level.boat GetTagOrigin( "snd_bow_stbd" ) + ( 0, 0, 15 ) , 3, 0.05, 0.05 );
	
	// attach them for good
	rope_mover_1 waittill( "movedone" );

	RopeAddEntityAnchor( level.drag_chinook.rope_2, 0, level.boat, ( 134.613998, 93.257057, -0.740022 ) + ( -12, 0, 15 ) );
	RopeAddEntityAnchor( level.drag_chinook.rope_3, 0, level.boat, ( 134.613998, -89.794777, -0.740022 ) + ( -12, 0, 15 ) );
	
	rope_mover_1 delete();
	rope_mover_2 delete();
}
	

//---------------------------------------------------------------------------

#using_animtree ("generic_human");
boat_drag()
{
	level endon( "rope_cut_success" );
	
	level notify( "drag_starts" );
	
	level thread vo_during_drag();
	
	// test
	if( level.drag_use_rope_tech )
	{
		level thread boat_drag_rope_actions();
	}
	
	// TEMP. Play explosion fx due to lack of notetracks
	level thread notetrack_chopper_hit_explosion( level.drag_chinook );
	
	// play rocket barrage fx
	level thread boat_drag_play_rocket_barrage_fx();
	
	// play additional large water splashes
	level thread boat_drag_play_wake_fx();
	
	// do we need this?
	level.boat.drivepath = 0;
	level.drag_chinook.drivepath = 0;
	
	// remove the props
	level.boat Detach( "t5_veh_boat_pbr_stuff", "tag_origin_animate");
	
	// setup to make the physics boat animatable
	level.boat.supportsAnimScripted = true;
	level.boat ClearVehGoalPos();
	
	level.drag_chinook.supportsAnimScripted = true;
	level.drag_chinook ClearVehGoalPos();
	
	// thread the player anim separately, since he has custom actions once his anim finishes
	level thread boat_drag_player_actions();
	
	// thread that handles when the rope does get cut in time
	level thread boat_drag_rope_cut_success();
	
// Now let's start animating:

	// all vehicle anims align to this node
	anim_node = getstruct( "boat_drag_anim_node_old", "targetname" );
	//anim_node = getstruct( "boat_drag_anim_node", "targetname" );
	
	level.reznov show();
	level.boat_drag_guys[3] show();
	
	// animate the AIs, who are linked to the boat
	for( i = 0; i < level.boat_drag_guys.size; i++ )
	{
		if( i == 2 )
		{
			// hide reznov
			level.boat_drag_guys[i] hide();
		}
		else
		{
			level.boat thread anim_single_aligned( level.boat_drag_guys[i], "dragged" );
		}
	}

	// animate other vehicles
	level thread play_vehicle_anim_single_solo( level.drag_chinook, "chinook", anim_node, "dragged" );
	level thread play_vehicle_anim_single_solo( level.drag_crash_pbr_1, "crash_pbr1", anim_node, "dragged" );
	level thread play_vehicle_anim_single_solo( level.drag_crash_pbr_2, "crash_pbr2", anim_node, "dragged" );
	level thread play_vehicle_anim_single_solo( level.drag_crash_pbr_3, "crash_pbr3", anim_node, "dragged" );
	
	// animate the boat
	play_vehicle_anim_single_solo( level.boat, "pbr", anim_node, "dragged" );
	
	flag_set( "rope_cut_failed" );
	
	//iprintlnbold( "MISSION FAIL" );
}

boat_drag_rope_actions()
{
	// we tie 1 rope to the rear right
	RopeAddEntityAnchor( level.drag_chinook.rope_4, 0, level.boat, ( -258.681335, -94.295067, 5.059479 ) + ( 0, 0, 15 ) );
	
	wait( 14 );
	// cur rear left
	RopeRemoveAnchor( level.drag_chinook.rope_1, 0 );

	wait( 2.5 );
	// cur rear right
	RopeRemoveAnchor( level.drag_chinook.rope_4, 0 );
	
	wait( 6.5 );
	// cur front right
	RopeRemoveAnchor( level.drag_chinook.rope_3, 0 );
	
	// wait for player action to cut the last one
	//level.drag_chinook.rope_2
}
	
boat_drag_player_actions()
{
	level endon( "rope_cut_failed" );
	
	// animate the player legs
	level.player_legs linkto( level.boat, "tag_origin_animate" );
	level.boat thread anim_single_aligned( level.player_legs, "dragged" );
	
	// animate player camera
	play_player_anim_on_vehicle( level.boat, "dragged", "tag_origin_animate", true );
	
	level notify( "player_finished_drag_anim" );
	
	// delete the legs
	// temp: keep this for now
	//level.player_legs delete();
	
	// once the player anim finishes (the others should still be running), give him the knife
	/*
	player = get_players()[0];
	player GiveWeapon( "creek_knife_sp", 0 );
	player GiveWeapon( "knife_creek_sp", 0 );
	player SwitchToWeapon( "creek_knife_sp" );
	*/
	
	/*
	level thread display_trigger_touch_message( level.drag_melee_trigger, &"RIVER_CUT_ROPE", "rope_cut_failed", "rope_cut_success" );
	
	level.drag_melee_trigger waittill( "trigger" );
	*/
	wait( 2 );
	screen_message_create( &"RIVER_CUT_ROPE" );
	wait( 1.5 );
	level notify( "boat_cut_start" );
	flag_set( "rope_cut_success" );
	screen_message_delete();
	
	maps\river_util::attach_player_clip_to_pbr( "player_pbr_clip" );
}

boat_drag_rope_cut_success()
{
	level endon( "rope_cut_failed" );
	
	flag_wait( "rope_cut_success" );
	
	// stop animating the boat and play the landing anim
	level.boat StopAnimScripted();
	level thread play_vehicle_anim_single_solo( level.boat, "pbr", undefined, "released" );
	
	if( isdefined( level.player_legs ) )
	{
		level.player_legs StopAnimScripted();
		level.player_legs delete();
	}
	
	level thread boat_drag_restore_ai_positions();
	
	// temp
	wait( 1 );
	level.boat StopAnimScripted();
	
	level thread temp_move_and_rotate_boat();
	
	player = get_players()[0];
	player SetPlayerAngles( level.boat.angles );
	
	// delete the extra guy
	if( isdefined( level.Boat_Drag_Guys[3] ) )
	{
		level.boat_drag_guys[3] delete();
	}
	
	level thread vo_after_drag();
	
	wait( 2 );
	
	flag_set( "drag_anim_complete" );
	
	flag_wait( "drag_end_vo_complete" );
	
	level thread vo_extra_reanov_line();
	
	maps\river_util::wait_for_player_to_use_boat();  // sets boat to be useable in this function
	
	level notify( "player_driving_boat_again" );
}

boat_drag_restore_ai_positions()
{
	level.woods unlink();
	level.bowman unlink();
	level.reznov unlink();
	
	wait( 0.1 );
	
	level.reznov show();
	
	level.woods forceteleport( level.boat GetTagOrigin( "tag_passenger10" ), level.boat GetTagAngles( "tag_passenger10" ) );
	level.woods LinkTo( level.boat, "tag_passenger10", ( 0, 0, 0 ) );
	level.bowman forceteleport( level.boat GetTagOrigin( "tag_gunner3" ), level.boat GetTagAngles( "tag_gunner3" ) );
	level.bowman LinkTo( level.boat, "tag_gunner3", ( 0, 0, 0 ) );
	level.reznov forceteleport( level.boat GetTagOrigin( "tag_passenger12" ), level.boat GetTagAngles( "tag_passenger12" ) );
	level.reznov LinkTo( level.boat, "tag_passenger12", ( 0, 0, 0 ) );
}

temp_move_and_rotate_boat()
{
	level.boat.supportsAnimScripted = false;
	level.boat SetDrivePathPhysicsScale( 1.0 );
	
	level.boat SetHoverParams( 200 );
	
	end_pos_1 = ( -10144, -6482, -58 );
	level.boat SetVehGoalPos( end_pos_1 );
	
	wait( 4 );
	end_pos_1 = ( -11576, -5562, -58 );
	level.boat SetVehGoalPos( end_pos_1 );
	
	wait( 1.5 );
	level.boat SetSpeed( 0, 100, 100 );
	wait( 1 );
	level.boat SetHoverParams( 30 );
}

boat_drag_play_rocket_barrage_fx()
{
	//AUDIO: notifying for Fake Rocket audio
	//clientNotify( "frk" );

	struct_1 = getstruct( "drag_missile_launch_1a", "targetname" );
	struct_2 = getstruct( "drag_missile_launch_1b", "targetname" );
	struct_3 = getstruct( "drag_missile_launch_1c", "targetname" );

	wait( 2.5 );
    
    level thread play_slightly_delayed_fake_rocket_audio();
    
	for( i = 0; i < 3; i++ )
	{
		playfx(level._effect["little_rockets"], struct_1.origin, AnglesToForward( struct_1.angles ) );
		wait( 0.5 );
		playfx(level._effect["little_rockets"], struct_2.origin, AnglesToForward( struct_2.angles ) );
		wait( 0.7 );
		playfx(level._effect["little_rockets"], struct_3.origin, AnglesToForward( struct_3.angles ) );
		wait( 4.8 );
	}
}

play_slightly_delayed_fake_rocket_audio()
{
    wait(.5);
    playsoundatposition( "evt_fake_rocket_2d", (0,0,0) );
}

boat_drag_play_wake_fx()
{
	// spawn a script model at the tag_wake
	// it needs to be a reverse angle as the angle of the boat
	level.boat.water_wake_tag = spawn( "script_model", level.boat GetTagOrigin( "tag_wake" ) );
	level.boat.water_wake_tag.angles = level.boat GetTagAngles( "tag_wake" );
	level.boat.water_wake_tag.angles = level.boat.water_wake_tag.angles + ( 0, 180, 0 );
	level.boat.water_wake_tag setmodel( "tag_origin" );
	
	// the tag position needs manual update
	level thread update_boat_wake_tag_position();

	// wait for boat to actuall start moving first
	wait( 11 );  

	// play the fx periodically
	level thread play_periodic_splash_fx();
	
	// wait for player to finish cutting the rope
	level waittill( "rope_cut_success" );

	// play the final splash
	//playfxOnTag( level._effect["wake_splash"], level.boat.water_wake_tag, "tag_origin" );
	playfxOnTag( level._effect["wake_splash"], level.boat, "tag_wake" );
}

// the fx tag position has to be constantly updated
update_boat_wake_tag_position()
{
	level endon( "drag_anim_complete" );
	while( 1 )
	{
		level.boat.water_wake_tag.origin = level.boat GetTagOrigin( "tag_wake" );
		level.boat.water_wake_tag.angles = level.boat GetTagAngles( "tag_wake" );
		level.boat.water_wake_tag.angles = level.boat.water_wake_tag.angles + ( 0, 180, 0 );
		wait( 0.05 );
	}	
}

// every 3 seconds play a large splash fx
play_periodic_splash_fx()
{	
	level endon( "rope_cut_success" );

	while( !flag( "second_impact" ) )
	{
		//playfxOnTag( level._effect["wake_splash"], level.boat.water_wake_tag, "tag_origin" );
		playfxOnTag( level._effect["wake_splash"], level.boat, "tag_wake" );
		wait( 0.5 );
	}
	
	while( !flag( "third_impact" ) )
	{
		//playfxOnTag( level._effect["wake_splash"], level.boat.water_wake_tag, "tag_origin" );
		playfxOnTag( level._effect["wake_splash"], level.boat, "tag_wake" );
		wait( 1.5 );
	}
	
	playfxOnTag( level._effect["wake_splash"], level.boat, "tag_wake" );
	
	// final stretches
	
	wait( 1 );
	while( 1 )
	{
		//playfxOnTag( level._effect["wake_splash"], level.boat.water_wake_tag, "tag_origin" );
		playfxOnTag( level._effect["wake_splash"], level.boat, "tag_wake" );
		wait( 1.5 + randomfloat( 1.0 ) );
	}
}

//---------------------------------------------------------------------------

drag_aftermath()
{
	
	// temp:
	player = get_players()[0];
	player unlink(); 
	
	// delete the 2 supporting hueys
	huey_1 = getent( "drag_huey_1", "targetname" );
	safe_delete_ent( huey_1 );
	huey_2 = getent( "drag_huey_2", "targetname" );
	safe_delete_ent( huey_2 );

	player.anim_hands Delete();
	player EnableWeapons();
	player giveback_player_weapons();
}

//---------------------------------------------------------------------------

// NOTETRACK FUNCTIONS

// play blood fx when the guy falls down
notetrack_blood_guy_falling( guy )
{
	playfxontag( level._effect["guy_falling_blood"], guy, "J_Neck" );
	
	wait( 2 );
	level notify("pbr_debris_start");
}

// play spark/impact fx when pbr bumps into things
notetrack_pbr_hit_fx_1( veh )
{
	wait( .3 );
	playfxontag( level._effect["pbr_impact_left"], level.boat, "tag_passenger10" );
}

notetrack_pbr_hit_fx_2( veh )
{
	level notify( "pbr_hits_boat_2" ); // tells the script to change the wires at this point
	wait( .3 );
	playfxontag( level._effect["pbr_impact_right"], level.boat, "tag_passenger11" );
	flag_set( "second_impact" ); 
}

notetrack_pbr_hit_fx_3( veh )
{
	wait( .3 );
	playfxontag( level._effect["pbr_impact_left"], level.boat, "tag_passenger10" );
	flag_set( "third_impact" ); 
}

// this is currently not fired vy notetrack. It needs to be.
notetrack_chopper_hit_explosion( chinook )
{
	wait( 8 ); // temp
	playfxOnTag( level._effect["chopper_explosion"], chinook, "door_bottom" );
	
	// the spark fx needs to be played periodically, at a different interval than the smoke
	level thread play_chinook_spark_fx( chinook );

	chinook endon( "death" );
	// play the smoke fx
	while( 1 )
	{
		playfxOnTag( level._effect["chopper_smoke"], chinook, "door_bottom" );
		wait( 0.1 );
	}
}

play_chinook_spark_fx( chinook )
{
	chinook endon( "death" );
	while( 1 )
	{
		playfxOnTag( level._effect["heli_trail_sparks"], chinook, "door_bottom" );
		wait( .2 );
	}
}


//------------------------------------------------------------------------

drag_cleanup()
{
	safe_delete_ent( level.drag_rope_1 );
	safe_delete_ent( level.drag_rope_2_3_4 );
	safe_delete_ent( level.drag_rope_1_end );
	
	if( level.drag_use_rope_tech == true )
	{
		deleterope( level.drag_chinook.rope_1 );
		deleterope( level.drag_chinook.rope_2 );
		deleterope( level.drag_chinook.rope_3 );
		deleterope( level.drag_chinook.rope_4 );
	}
	
	safe_delete_ent( level.drag_crash_pbr_1 );
	safe_delete_ent( level.drag_crash_pbr_2 );
	safe_delete_ent( level.drag_crash_pbr_3 );
	safe_delete_ent( level.drag_chinook );

	delete_all_enemies();
}


//---------------------------------------------------------------------
// VO

vo_chinook_arrival()
{
	self thread vo_chinook_in_position();
	
	self thread vo_rp_nag_lines();
	
	level notify( "obj_head_for_chinook" );
	
//	self maps\river_vo::playVO_proper( "got_you_in_sight" );
//	level.woods maps\river_vo::playVO_proper( "roger_airlifted", 0.5 );
	self maps\river_vo::playVO_proper( "abort_evac", 0.5 );
	self maps\river_vo::playVO_proper( "theyd_do_for_us", 0.5 );
	level.woods maps\river_vo::playVO_proper( "ch47_make_it_quick", 0.5 );
}

vo_rp_nag_lines()
{
	level endon( "docking_sequence_initiated" );
	level endon( "player_in_position_for_drag" );
	
	level waittill( "obj_head_for_chinook" );
	while( 1 )
	{
		level.woods maps\river_vo::playVO_proper( "head_for_rp" );
		wait( 8 );
		level.woods maps\river_vo::playVO_proper( "were_out_of_time" );
		wait( 10 );
	}
}

vo_chinook_in_position()
{
	flag_wait( "drag_chinook_in_position" );
	
	self maps\river_vo::playVO_proper( "light_them_up" );
}

// NOTETRACK
vo_woods_tie_rope()
{
	player = get_players()[0];
	player.animname = "mason";
	
	wait( 8 );
	level.woods maps\river_vo::playVO_proper( "i_got_the_front" );
	
	wait( 1 );
	player maps\river_vo::playVO_proper( "reznov_help_rope", 0.5 );
}

vo_player_tie_rope()
{
	level.drag_chinook maps\river_vo::playVO_proper( "rescue_1_pull_out" );
	level.drag_chinook maps\river_vo::playVO_proper( "i_know_out", 0.2 );
	wait( 3 );
	level.woods maps\river_vo::playVO_proper( "mason_go_go", 0.2 );
	wait( 4.5 );
	level.woods maps\river_vo::playVO_proper( "lets_go", 0.5 );
}

vo_during_drag()
{
	wait( 9 );
	level.drag_chinook maps\river_vo::playVO_proper( "we_are_hit" );
	level.woods maps\river_vo::playVO_proper( "fuck_mason_cables", 1 );
	level.drag_chinook maps\river_vo::playVO_proper( "i_can't_hold", 2 );
	level.drag_chinook maps\river_vo::playVO_proper( "brace_for_impact", 2 );
}

vo_after_drag()
{
	level.boat maps\river_vo::playVO_proper( "rescue_1_is_down" );
	
	level.boat anim_single_aligned( level.woods, "stay_with_us", "tag_passenger10" );	
	
	flag_set( "drag_end_vo_complete" );
	
	
}
	
vo_extra_reanov_line()
{
	player = get_players()[0];
	// wait for player to get close to Reznov
	while( distance( player.origin, level.reznov.origin ) > 150 )
	{
		wait( 0.1 );
	}
	player maps\river_vo::playVO_proper( "where_the_hell" );
	
	level.boat anim_single_aligned( level.woods, "gone_for_now", "tag_passenger10" );	
}

notetrack_attach_ropes_to_woods( guy )
{
	level notify( "tie_rope_to_AI_hands" );
}
