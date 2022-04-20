////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL SCRIPTS
//
//
// Script for event 1 - this covers the following scenes from the design:
//		Slides 1-14		
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;
#include maps\flashpoint_util;
#include maps\_music;
#include maps\_audio;


////////////////////////////////////////////////////////////////////////////////////////////
// EVENT1 FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////


hide_view()
{
	level endon( "PLAYER_DROPPED_DOWN" );
	
	//Get array of ents to hide/show
	view_ents = getentarray( "hide_from_start_view", "script_noteworthy" );
	
	is_prev_in_view = 1;
	is_curr_in_view = 1;	//starts off in view
	
	while( 1 )
	{
		//If inside trigger then hide the view	
		hideview_trig = getent( "hide_view", "targetname" );
		
		if( level.player IsTouching( hideview_trig ) )
		{
			//hide view
			is_curr_in_view = 0;
		}
		else
		{
			//show view
			is_curr_in_view = 1;
		}
		
		//If view has changed
		if( is_curr_in_view!=is_prev_in_view )
		{
			for( i=0;i<view_ents.size;i++ )
			{
				if( is_curr_in_view )
					view_ents[ i ] Show();
				else
					view_ents[ i ] Hide();
			}
		}
		is_prev_in_view = is_curr_in_view;
		
		wait( 0.1 );
	}
}

rotateRadarDishOnCommsbuilding()
{	
	radar1_ent = getent( "radar1", "targetname" );
	
	//kevin adding audio
	radar1_ent playloopsound( "amb_radar_move_loop" );
	
	//Stop when the rocket gets blown up
	while( !flag("ROCKET_DESTROYED") )
	{
		radar1_ent rotateto(radar1_ent.angles + (0.0,5.0,0.0), 0.25);
		wait( 0.25 );
	}
	radar1_ent stoploopsound(1);
}

chopperOverhead()
{
	//Start the helicopter to fly over head
	heli_start_node = GetVehicleNode( "heli_search_start", "targetname" );
	chopper_heli_search = SpawnVehicle( "t5_veh_helo_mi8_woodland", "heli_search", "heli_hip", heli_start_node.origin, (0,0,0) );
	maps\_vehicle::vehicle_init( chopper_heli_search );
	chopper_heli_search thread check_play_vehicle_rumble();
	chopper_heli_search.health = 999999;
	chopper_heli_search thread go_path( heli_start_node );

	//Apply a camera shake and controller rumble for when the helicopter passes overhead
	//Kevin adding notify to start rattle audio
	level notify( "rattle_audio" );
	Earthquake( 0.1, 6.0, level.player.origin, 1000, level.player );
	//level.player PlayRumbleOnEntity( "damage_heavy" );
	
	//Start ambient rocket shell rattle
	level thread panel_rattle();
}

chopperOverhead_1stdrop()
{
	wait( 1.0 );
	
	//Start the helicopter to fly over head
	heli_start_node = GetVehicleNode( "heli_search_1ststop_start", "targetname" );
	chopper_heli_search = SpawnVehicle( "t5_veh_helo_mi8_woodland", "heli_search_1ststop", "heli_hip", heli_start_node.origin, (0,0,0) );
	chopper_heli_search thread check_play_vehicle_rumble();
	maps\_vehicle::vehicle_init( chopper_heli_search );
	chopper_heli_search.health = 999999;
	chopper_heli_search thread go_path( heli_start_node );

	wait( 2.0 );
	//Apply a camera shake and controller rumble for when the helicopter passes overhead
	//Kevin adding notify to start rattle audio
	//level notify( "rattle_audio" );
	Earthquake( 0.1, 6.0, level.player.origin, 1000, level.player );
	//level.player PlayRumbleOnEntity( "damage_heavy" );
}

panel_rattle()
{
	wait( 2.7 );
	
	//Start ambient rocket shell rattle
	level notify( "rocket_panel_rattle_01_start" );
	
	exploder( 101 );
	wait( 0.5 );
	exploder( 102 );
}

trackTargetToGoal( target, linker )
{
	self endon( "stop_tracking" );
	
	while( 1 )
	{
		vecToTarget = target.origin - self.origin;
		linker.angles = VectorToAngles( vecToTarget );
		wait( 0.01 );
	}
}

///////////////////////////////////////////////////////////////////////////////////////
// Intro anim - self = player
///////////////////////////////////////////////////////////////////////////////////////
#using_animtree("flashpoint");
intro_anim()
{
	anim_node = get_anim_struct( "1" );
	
	self.body = spawn_anim_model( "player_body", anim_node.origin );
	self PlayerLinktoAbsolute(self.body, "tag_player");
	//self PlayerLinkToDelta(self.body, "tag_camera", 1, 15, 15, 15, 15, false );
	//self PlayerLinkTo(self.body, "tag_player" );//, 1, 15, 15, 15, 15, true );
	self.body SetAnim( level.scr_anim["player_body"]["intro_a_player"], 1, 0 ,0 );
	
	flag_wait("starting final intro screen fadeout");
	
	//TUEY Set music state to INTRO
	setmusicstate("INTRO");
	
	self DisableWeapons();
 	self FreezeControls( true );
 
 	//spawn the player body
	anim_node thread anim_single_aligned( self.body, "intro_a_player" );
	
	wait( 0.05 );
	
	//self StartCameraTween(.2);
	
	anim_node waittill("intro_a_player");
	//Give control back to the player
	level.player thread waitThenGiveControlToPlayer( 1.0 );
	
	self Unlink();
	self.body Unlink();
	self.body Delete();
	
	self setlowready( true );

	self DisableOffhandWeapons();
}


player_breaks_stealth_by_greande_throw()
{	
	self endon( "death" );
	level endon( "START_BINOC_ANIM" );
	
	self waittill( "grenade_fire" );
	maps\_utility::missionFailedWrapper(&"FLASHPOINT_DEAD_START_BROKESTEALTH");				
}


event1_Woods()
{
	debug_event( "event1_Woods", "start" );
	autosave_by_name("flashpoint_e1");
	
	level.allow_rumbles = true;

	maps\flashpoint::common_event_startup();
	level.player thread hide_view();
	level.player thread player_breaks_stealth_by_greande_throw();
	
	//level.default_run_speed = 190; 
	SetSavedDvar( "g_speed", 170 ); 
	
	//Spawn Woods who starts with the player (fyi:barnes was the old name)
	maps\flashpoint::spawn_woods( undefined, true );
	level.woods.name = "";
	
	//Get woods into the first frame of the anim
	anim_node = get_anim_struct( "1" );
	//anim_node anim_first_frame( level.woods, "intro_a" );

	//Start lights on the Gantry
	Exploder(120);
	
	//Play lights on the "stadium lights"
	exploder(121);
	//light_tower = getent( "fxanim_flash_lighttower_mod", "targetname" );
	//PlayFXOnTag( level._effect["light_tower"], light_tower, "tag_origin" );
	
	level.player thread intro_anim();
	
	//Wait for the intro screen to go away before starting the level
	flag_wait("starting final intro screen fadeout");
	
	Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_INFILTRATE_BASE", level.woods );
	Objective_Set3D( level.obj_num, false );
	
	level thread rotateRadarDishOnCommsbuilding();
	level thread chopperOverhead();
	
	anim_node thread anim_single_aligned( level.woods, "intro_a" );
	
	//level.woods SetGoalPos( level.woods.origin );
	anim_node waittill("intro_a_player");
	Objective_Set3D( level.obj_num, true, "default", &"FLASHPOINT_OBJ_FOLLOW" );
	
	level thread chopperOverhead_1stdrop();
	level.woods thread playVO_proper( "pick_it_up", 2.0 );
	level.woods.name = "Woods";

	anim_node waittill( "intro_a" );
	//Goto the next part of this event
	debug_event( "event1_Woods", "end" );
	event1_WoodsRunsJumpsDives();
}

woodsFirstStopAnim()
{
	//Make woods SPRINT to his next node
	self.sprint = true;
	woods_dive_point = getnode( "woods_dive_point", "targetname" );
	level.woods set_run_anim( "run_fast", true );
	/*
	level.woods setgoalnode( woods_dive_point );
	level.woods.goalradius = 16;
	level.woods.disableArrivals = true;
	level.woods waittill( "goal" );
	*/
	//Play wait animation
	// TODO "aboutotlaunch_wait"
	//anim_node_2 = get_anim_struct( "2" );
	anim_node_2 = get_anim_struct( "1" );
	anim_node_2 thread anim_loop_aligned( level.woods, "aboutotlaunch_wait" );	
	
	
	//wait( 0.5 );
	level.woods.disableArrivals = false;
	flag_set( "WOODS_AT_FIRST_STOP" );
}


remove_blocker( guy )
{
	//Remove clip that blocks the way
	clip = getent( "clip_woods_dive", "targetname" );
	clip delete();
}

play_woods_run_up_hill_anim()
{
	anim_node_2 = get_anim_struct( "2" );
	println( "woods aboutotlaunch=" + self.origin );
	anim_node_2 thread anim_single_aligned( self, "aboutotlaunch" );
	//level.woods LookAtEntity( level.player );	//Look at the player
	anim_node_2 waittill( "aboutotlaunch" );
	flag_set( "WOODS_IS_UP_HILL" );
}

event1_WoodsRunsJumpsDives()
{
	debug_event( "event1_WoodsRunsJumpsDives", "start" );
	
	level.woods thread woodsFirstStopAnim();	
	dive_trigger = GetEnt("dive_trigger", "targetname");
	dive_trigger waittill( "trigger" );
	debug_script( "HIT DIVE TRIGGER" );

	level thread snake_kill_easter_egg();

	flag_wait( "WOODS_AT_FIRST_STOP" );
	
	level.woods thread play_woods_run_up_hill_anim();
	
//	anim_node_2 = get_anim_struct( "2" );
//	println( "woods aboutotlaunch=" + level.woods.origin );
//	anim_node_2 thread anim_single_aligned( level.woods, "aboutotlaunch" );
	//level.woods LookAtEntity( level.player );	//Look at the player
//	anim_node_2 waittill( "aboutotlaunch" );
	//level.woods LookAtEntity();					//Stop looking at the player
		
	
	//Remove clip that blocks the way
	//clip = getent( "clip_woods_dive", "targetname" );
	//clip delete();
	
	debug_event( "event1_WoodsRunsJumpsDives", "end" );
	event1_AwesomeRead();
}

snake_kill_easter_egg()
{
	level.player setlowready( false );

	wait( 5 );

	level.player setlowready( true );
}

lerp_player()
{
	//Move player to the correct position (this will get done by an animation)
//	self SetStance("prone");
	player_binoculars_point = getnode( "player_binoculars_point", "targetname" );
	mover_ent = spawn( "script_origin", self.origin );
	mover_ent.angles = self.angles;
	self playerlinkto( mover_ent );
	mover_ent.angles = player_binoculars_point.angles;
	mover_ent moveto( player_binoculars_point.origin, 2.5 );
	mover_ent waittill( "movedone" );
	mover_ent Delete();
	

	
}

panel2_rattle()
{
	wait( 1.0 );
	
	//Start ambient rocket shell rattle
	level notify( "rocket_panel_rattle_02_start" );

	exploder( 103 );
}


heli_02_flyover()
{
	//Start the helicopter to fly over head when the player gets close enough
	//chopper_heli_search_02_trigger = GetEnt("chopper_heli_search_02_trigger", "targetname");
	//chopper_heli_search_02_trigger waittill( "trigger" ); 
	
	//level thread playVO( "Something isn't right... Too much activity", "Woods" );

	heli_02_start_node = GetVehicleNode( "heli_search_02_start", "targetname" );
	chopper_heli_search_02 = SpawnVehicle( "t5_veh_helo_mi8_woodland", "heli_search_02", "heli_hip", heli_02_start_node.origin, (0,0,0) );
	chopper_heli_search_02 thread check_play_vehicle_rumble();
	maps\_vehicle::vehicle_init( chopper_heli_search_02 );
	chopper_heli_search_02.health = 999999;
	chopper_heli_search_02 thread go_path( heli_02_start_node );
	level thread panel2_rattle();	
}
	
helicopter_fly_past()
{
	chopper_heli_search_02_trigger_b = GetEnt("chopper_heli_search_02_trigger_b", "targetname");
	chopper_heli_search_02_trigger_b waittill( "trigger" ); 
	self SetLowReady(true);
	self AllowMelee( false );
	level thread heli_02_flyover();
}

event1_AwesomeRead()
{
	debug_event( "event1_AwesomeRead", "start" );
	
	level notify( "set_portal_override_run_to_binoculars" );
	
	//Move player to the correct position when he is in range of the starting animation (this will get done by an animation)
	//level.player thread lerp_player();
	level.player thread take_binocular_anim();
	level.player thread helicopter_fly_past();
	
	chopper_heli_search_02_trigger = GetEnt("chopper_heli_search_02_trigger", "targetname");
	
	//binoculars_trigger = GetEnt("binoculars_trigger", "targetname");
	//binoculars_trigger trigger_off();
	//level thread heli_02_flyover();

	//Make woods sprint to his next node
	level.woods.speed = "sprint";
	woods_binoculars_point = getnode( "woods_binoculars_point", "targetname" );	
	level.woods set_run_anim( "run_fast", true );
	/*
	level.woods setgoalnode( woods_binoculars_point );
	level.woods.goalradius = 16;
	//level.woods.disableArrivals = true;
	level.woods waittill( "goal" );
	*/
	
	
	flag_wait( "WOODS_IS_UP_HILL" );
	
	
	//Play custom woods animation to give binoculars
 	anim_node_3 = get_anim_struct( "3" );
 	
 	anim_node_3 thread anim_loop_aligned( level.woods, "before_binoc_wait_idle");
 	
	//Start the helicopter to fly over head when the player gets close enough
	//chopper_heli_search_02_trigger = GetEnt("chopper_heli_search_02_trigger", "targetname");
	chopper_heli_search_02_trigger waittill( "trigger" ); 
	
	//TUEY SET MUSIC STATE TO EYE_SCENE
	setmusicstate ("EYE_SCENE");

	level thread activity1_ambient();
	level thread activity1_helis();
	//level thread heli_02_flyover();
	
	
 	println( "woods binocular_give=" + level.woods.origin );
 	
 	anim_node_3 anim_single_aligned( level.woods, "binocular_give" );
	if(!flag("START_BINOC_ANIM"))
	{
		anim_node_3 thread anim_loop_aligned( level.woods, "binocular_give_loop" );
	}
	//level.woods Attach("viewmodel_binoculars", "TAG_WEAPON_LEFT");
	
	//Apply a camera shake and controller rumble for when the helicopter passes overhead
	//Kevin adding notify to start rattle audio
	level notify( "rattle_audio2" );
	//Earthquake( 0.1, 6.0, level.player.origin, 1000, level.player );
	//level.player PlayRumbleOnEntity( "damage_heavy" );

	level thread spawn_binoculars_scene();
	
	level thread spawn_weaver_eye_helicopter();

	debug_event( "event1_AwesomeRead", "end" );
	event1_Binoculars();
}

spawn_weaver_eye_helicopter()
{
	heli_weaver_eye_start = GetVehicleNode( "heli_weaver_eye_start", "targetname" );
	level.pipe_chopper_02 = SpawnVehicle( "t5_veh_helo_mi8_woodland", "base_heli_01", "heli_hip", heli_weaver_eye_start.origin, (0,0,0) );
	level.pipe_chopper_02 thread check_play_vehicle_rumble();
	maps\_vehicle::vehicle_init( level.pipe_chopper_02 );
	level.pipe_chopper_02.health = 999999;
	level.pipe_chopper_02 thread go_path( heli_weaver_eye_start );
}

delete_fake_weaver_and_krav_and_woods()
{
	flag_wait( "binocular_done" );
	level.weaver_dummy Delete();
	level.weaver_dummy_head Delete();
	level.krav_dummy Delete();
	level.woods_dummy Delete();
}



spawn_fake_weaver_and_krav_and_woods()
{
	level endon( "binocular_done" );
	
	wait( 7.0 );
	
	spawn_point = ( -773.9, -8482.3, 433.415 );
	
	level.weaver_dummy = spawn( "script_model", spawn_point );
	level.weaver_dummy SetModel("c_usa_blackops_weaver_disguise_body" );
	
	level.weaver_dummy_head = spawn( "script_model", spawn_point );
	level.weaver_dummy_head SetModel("c_usa_blackops_weaver_disguise_head" );
	
	level.krav_dummy = spawn( "script_model", spawn_point );
	level.krav_dummy SetModel("c_rus_kravchenko_fb" );
	
	level.woods_dummy = spawn( "script_model", spawn_point );
	level.woods_dummy SetModel("c_usa_specop_barnes_fb" );

	
	//Keep models close to camera
	while( 1 )
	{
		if( isdefined( level.player_hands ) )
		{
			camera_point = level.player_hands GetTagOrigin( "tag_camera" );
			camera_point = camera_point + ( 0.0, 0.0, 10.0 );
			level.weaver_dummy.origin = camera_point;
			level.weaver_dummy_head.origin = camera_point;
			level.krav_dummy.origin = camera_point;
			level.woods_dummy.origin = camera_point;
		}
		else
		{
		//	level.weaver_dummy Hide();
		//	level.weaver_dummy_head Hide();
		//	level.krav_dummy Hide();
		//	level.woods_dummy Hide();
			level.weaver_dummy.origin = spawn_point;
			level.weaver_dummy_head.origin = spawn_point;
			level.krav_dummy.origin = spawn_point;
			level.woods_dummy.origin = spawn_point;
		}
		wait( 0.05 );
	}
}


spawn_binoculars_scene()
{
	level thread spawn_fake_weaver_and_krav_and_woods();
	level thread delete_fake_weaver_and_krav_and_woods();
	
	//level waittill("start_weaverstab");
	
	kravchenko_eyepoke_node = getnode( "kravchenko_eyepoke_node", "targetname" );
	weaver_eyepoke_node = getnode( "weaver_eyepoke_node", "targetname" );
	
	maps\flashpoint::spawn_weaver( weaver_eyepoke_node, true );
	maps\flashpoint::spawn_kravchenko( kravchenko_eyepoke_node, true );
	
	//Play anims
	eye_scene_node = get_anim_struct( "eye" );
	eye_scene_node thread anim_first_frame( level.weaver, "eye_stab_weaver" );
	eye_scene_node thread anim_first_frame( level.kravchenko, "eye_stab_krav" );
	
	level waittill("start_weaverstab");
	eye_scene_node thread anim_single_aligned( level.weaver, "eye_stab_weaver" );
	eye_scene_node thread anim_single_aligned( level.kravchenko, "eye_stab_krav" );
	eye_scene_node waittill( "eye_stab_krav" );
	
	level.weaver setgoalpos( level.weaver.origin );
	level.kravchenko setgoalpos( level.kravchenko.origin );
	wait( 4.0 );
	
	level.weaver Delete();
	level.kravchenko Delete();
	//level.heli_weaver_eye Delete();
	
	//Make sure we can spawn another weaver for later
	weaver_spawner = GetEnt( "weaver", "targetname" );
	weaver_spawner.count++;
}

event1_Binoculars()
{
	debug_event( "event1_Binoculars", "start" );

	//Play custom woods animation 
	/*
	woods_binoculars_point_2 = getnode( "woods_binoculars_point_2", "targetname" );	
	level.woods_anim_origin = spawn( "script_origin", woods_binoculars_point_2.origin ); 
	level.woods_anim_origin.angles = woods_binoculars_point_2.angles - (0,135,0);
	*/
	level.woods_anim_origin = get_anim_struct( "3" );
	
	flag_set("WOODS_READY_TO_HAND_BINOC");
	flag_wait("START_BINOC_ANIM");
	
	//TUEY Set music state to MASON_BINOCULARS
	setmusicstate ("MASON_BINOCULARS");
	level thread switch_music_wait("END_BINOCULAR_SCENE", 3);

	level.woods_anim_origin thread anim_single_aligned( level.woods, "binocular_handoff" );
	level.woods_anim_origin waittill_either("binocular_handoff", "start_binocular_anim");
	level.woods_anim_origin notify("start_binocular_anim");
	level.woods_anim_origin thread anim_single_aligned( level.woods, "binocular_end" );	
	flag_wait( "binocular_done" );
	level clientNotify( "kill_binoculars" );
		
// 	level thread playVO( "Whiskey team, you in position?", "Woods", 0.0 );
// 	level thread playVO( "Roger Xray. Whiskey is covering the road.", "bowman", 0.5 );
// 	level thread playVO( "Weaver's compromised.  Base will likely be on elevated alert.", "Woods", 1.5 );
// 	level thread playVO( "Hold position. We're inbound.", "Woods", 2.5 );
// 	level thread playVO( "Copy.", "bowman", 3.0 );
// 	level thread playVO( "Let's Go.", "Woods", 3.5 );

	debug_event( "event1_Binoculars", "end" );
	event1_RocketLaunchIGC();
}

///////////////////////////////////////////////////////////////////////////////////////
//	Timing for fov, exposure and dof for binocular sequence
// self = player
///////////////////////////////////////////////////////////////////////////////////////
binocular_fov()
{	
	default_fov = GetDvarFloat( #"cg_fov" );
	
	NearStart = 822;
	NearEnd = 823;
	FarStart = 886;
	FarEnd = 887;
	NearBlur = 4;
	FarBlur = 3.9;
	
	level.allow_rumbles = false;
	
	level thread activity2_ambient();
	//level thread activity2_migs();
	
	level notify("spawn_binoc_scientists"); //-- spawns scientists for ambience
	self thread binocular_exposure();
	shutter_switch( 0.0 ); //-- instant shutter the first time
	self thread lerp_fov_over_time( 0.05, 5 );
	//self thread lerp_dof_over_time( 2.0, NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur );
	
	wait(4);
	
	level.pipe_chopper_02 heli_toggle_rotor_fx(0);
	//Kevin stoppping heli sounds so they dont play during binoc scene
	level.pipe_chopper_02 vehicle_toggle_sounds( 0 );
	level thread activity2_migs();
	
	level notify("spawn_binoc_snipers");
	self thread binocular_exposure();
	shutter_switch();
	self thread lerp_fov_over_time( 0.05, 25 );
	//self thread lerp_dof_over_time( 2.0, NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur );
	level waittill("binoc_change");
	
	/*
	shutter_switch();
	self thread binocular_exposure();
	self thread lerp_fov_over_time( 0.05, 20 );
	self thread lerp_dof_over_time( 2.0, NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur );
	*/

	
	wait(2.0);
	
	shutter_switch();
	self thread binocular_exposure();
	self thread lerp_fov_over_time( 0.05, 10 );
	self thread lerp_dof_over_time( 2.0, NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur );
	
	level waittill("binoc_change");
	level notify("delete_binoc_scientists"); //-- delete scientists
	
	/*
	shutter_switch();
	self thread binocular_exposure();
	self thread lerp_fov_over_time( 0.05, 20 );
	self thread lerp_dof_over_time( 2.0, NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur );
	*/
	
	level waittill("binoc_change"); //-- TODO: SEE IF THIS WAS GOOD
	level notify("spawn_binoc_krav_guards");
	
	//level thread spawn_binoculars_scene();
	
	/*
	shutter_switch();
	self thread binocular_exposure();
	self thread lerp_fov_over_time( 0.05, 15 );
	self thread lerp_dof_over_time( 1.0, NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur );
	
	shutter_switch();
	self thread binocular_exposure();
	self thread lerp_fov_over_time( 0.05, 7 );
	self thread lerp_dof_over_time( 1.0, NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur );
	*/
	
	shutter_switch();
	self thread binocular_exposure();
	self thread lerp_fov_over_time( 0.05, 25 );
	self thread lerp_dof_over_time( 1.0, NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur );
	
	level waittill("binoc_change");
	level notify("delete_binoc_snipers");
	level notify("delete_binoc_krav_guards");
	
	level thread shutter_switch( 0 );
	self thread check_binocular( default_fov );
}

///////////////////////////////////////////////////////////////////////////////////////
//	Check when binocular should be destroyed - self = player
///////////////////////////////////////////////////////////////////////////////////////
check_binocular( default_fov )
{
	//flag_wait( "end_binoculars" );
	
	//wait( 1.0 );
	
	flag_set( "binocular_done" );
	level.allow_rumbles = true;
	
	self thread lerp_fov_over_time( 0.05, default_fov );
	
	Default_Near_Start = 0;
	Default_Near_End = 1;
	Default_Far_Start = 8000;
	Default_Far_End = 10000;
	Default_Near_Blur = 6;
	Default_Far_Blur = 0;
	
	self SetDepthOfField( Default_Near_Start, Default_Near_End, Default_Far_Start, Default_Far_End, Default_Near_Blur, Default_Far_Blur );
	
	self StopBinocs();
	level.woods show();
	
	//setdvar( "r_filmTweakLut", "1" );
}
	
///////////////////////////////////////////////////////////////////////////////////////
// Binocular anim (take binoculars)- self = player
///////////////////////////////////////////////////////////////////////////////////////
#using_animtree("flashpoint");
take_binocular_anim()
{
	level thread synchronize_binoc_anims();
	
	anim_node = get_anim_struct( "3" );
	
	//-- build a trigger radius for the player to run into
//	start_org = GetStartOrigin( anim_node.origin, anim_node.angles, level.scr_anim["player_body"]["take_binocular"] );
//	player_trig = Spawn("trigger_radius", start_org - (0,0,140), 0, 30, 256);
//	player_trig waittill("trigger");
	
	take_binoc_trig = getent( "take_binoc_trig", "targetname" );
	take_binoc_trig waittill( "trigger" );
	
	Objective_Set3D( level.obj_num, false );
	
	//self SetLowReady(true);
	self AllowJump(false);

	//self DisableWeapons();
	//self FreezeControls( true );
	
	//spawn the player body
	self.body = spawn_anim_model( "player_body", anim_node.origin, anim_node.angles );
	self.body Hide();
	anim_node anim_first_frame( self.body, "take_binocular" );
	self StartCameraTween(1.0);
	self PlayerLinkToDelta(self.body, "tag_player", 0, 60, 60, 90, 30, false);
	
	flag_set("PLAYER_READY_TO_TAKE_BINOC");
	flag_wait("START_BINOC_ANIM");
	
	self DisableWeapons();
	self FreezeControls( true );
	//self Unlink();
	self PlayerLinktoAbsolute(self.body, "tag_player");
	self StartCameraTween(1.0);
	anim_node thread anim_single_aligned( self.body, "take_binocular" );
	wait(0.05);
	self.body Show();
	
	anim_node waittill_either("take_binocular", "start_binocular_anim");
	anim_node notify("start_binocular_anim");
	
	
	self Unlink();
	self.body Delete();
	
	self StartBinocs();
	level clientNotify( "toggle_binoculars" );
	self thread binocular_anim();
	
}

synchronize_binoc_anims()
{
	flag_wait("PLAYER_READY_TO_TAKE_BINOC");
	flag_wait("WOODS_READY_TO_HAND_BINOC");
	flag_set("START_BINOC_ANIM");
	playsoundatposition( "evt_num_num_10_r" , (0,0,0) );
}

binocular_anim_ambience()
{
	scientists_spawners = GetEntArray("binoc_scientists", "targetname" );
	array_thread( scientists_spawners, ::add_spawn_function, ::binoc_scientist_behavior );
	
	level waittill("spawn_binoc_scientists");
	scientists = simple_spawn( "binoc_scientists" );
	
	sniper_spawners = GetEntArray("binoc_snipers", "targetname" );
	array_thread( sniper_spawners, ::add_spawn_function, ::binoc_sniper_behavior );
	
	level waittill("spawn_binoc_snipers");
	snipers = simple_spawn( "binoc_snipers" );
	
	krav_guards_spawners = GetEntArray("binoc_krav_guards", "targetname" );
	array_thread( krav_guards_spawners, ::add_spawn_function, ::binoc_krav_guards_behavior );
	
	level waittill("spawn_binoc_krav_guards");
	krav_guards = simple_spawn( "binoc_krav_guards" );
}

binoc_scientist_behavior()
{
	if(IsDefined(self.script_noteworthy) && self.script_noteworthy == "stand_still" )
	{
		self.goalradius = 4;
		self.ignoreall = true;
		self SetGoalPos(self.origin);
	}
	else
	{
		self.ignoreall = true;
		self.animname = "generic";
		self set_generic_run_anim( "patrol_walk" );
	}
	
	level waittill("delete_binoc_scientists");
	self Delete();
}

binoc_sniper_behavior()
{
	self.ignoreall = true;
	self.animname = "generic";
	self set_generic_run_anim( "patrol_walk" );
	
	level waittill("delete_binoc_snipers");
	self Delete();
}

binoc_krav_guards_behavior()
{
	self.ignoreall = true;
	self.animname = "generic";
	self set_generic_run_anim( "patrol_walk" );
	
	level waittill("delete_binoc_krav_guards");
	self Delete();
}

///////////////////////////////////////////////////////////////////////////////////////
// Binocular anim - self = player
///////////////////////////////////////////////////////////////////////////////////////
#using_animtree("player");
binocular_anim()
{
	//Kevin starting intro pa audio
	level thread maps\flashpoint_amb::countdown();
	
	level.player_hands = spawn_anim_model( "player_hands" );

	//anim_node = getnode( "player_binoculars_point", "targetname" );
	anim_node = get_anim_struct( "3" );
	
	level thread binocular_anim_ambience();
	self thread binocular_fov();
	
	//-- disable compass
	level.player SetClientDvar( "compass", "0" );
	anim_node thread anim_single_aligned( level.player_hands, "binocular" );
	
	//self StartCameraTween(.2);
	self playerlinktoabsolute( level.player_hands, "tag_player" );
	
	level.woods hide();
	wait(1.0);
	level.woods Detach("viewmodel_binoculars", "TAG_WEAPON_LEFT");
	
	
	anim_node waittill( "binocular" );
	
	//-- enable compass
	level.player SetClientDvar( "compass", "1" );
	
	//Wait till we are done with the binoculars
	//flag_wait( "binocular" );
	self unlink();
	level.player_hands delete();

	self setlowready( false );

	self enableoffhandweapons();
}

heli_flyby_rumble()
{
	wait( 3.0 );
	//Kevin adding notify to start rattle audio
	level notify( "rattle_audio3" );
	earthquake( 0.2, 2.5, level.player.origin,  100 );
}

check_play_vehicle_rumble_binocs( override_rumble_dist, override_rumble_type )
{
	self endon("death");
	
	rumble_dist = 2000;
	if( isdefined( override_rumble_dist ) )
	{
		rumble_dist = override_rumble_dist;
	}
	
	rumble_type = "tank_rumble";
	if( isdefined( override_rumble_type ) )
	{
		rumble_type = override_rumble_type;
	}

	while(1)
	{
		//iprintln( Distance2D(level.player.origin, self.origin) );
		
		if(  (Distance2DSquared(level.player.origin, self.origin) < ( rumble_dist * rumble_dist )) )
		{
			level.player PlayRumbleOnEntity( rumble_type );
			wait(0.2);
		}
		else
		{

			//iprintln(Distance2D(player.origin, self.origin));
			wait(0.1);
		}
	}
}

check_play_vehicle_rumble( override_rumble_dist, override_rumble_type )
{
	self endon("death");
	
	rumble_dist = 2000;
	if( isdefined( override_rumble_dist ) )
	{
		rumble_dist = override_rumble_dist;
	}
	
	rumble_type = "tank_rumble";
	if( isdefined( override_rumble_type ) )
	{
		rumble_type = override_rumble_type;
	}

	while(1)
	{
		//iprintln( Distance2D(level.player.origin, self.origin) );
		
		if( level.allow_rumbles && (Distance2DSquared(level.player.origin, self.origin) < ( rumble_dist * rumble_dist )) )
		{
			level.player PlayRumbleOnEntity( rumble_type );
			wait(0.2);
		}
		else
		{

			//iprintln(Distance2D(player.origin, self.origin));
			wait(0.1);
		}
	}

}


helicopter1_flyby()
{
	level endon( "end_heli_circle" );
	wait( 1.5 );
	level thread heli_flyby_rumble();
	
	heli_flyby_1_start_node = GetVehicleNode( "heli_flyby_1_start_node", "targetname" );
	heli_1 = SpawnVehicle( "t5_veh_helo_mi8_woodland", "intro_helicopter_1", "heli_hip", heli_flyby_1_start_node.origin, (0,0,0) );
	heli_1 thread check_play_vehicle_rumble( 500.0, "damage_heavy" );
	maps\_vehicle::vehicle_init( heli_1 );
	heli_1 thread go_path( heli_flyby_1_start_node );
	heli_1.drivepath = 1;
	heli_1.health = 999999;

	heli_1 helicopter1_setup();
}

helicopter1_setup()
{
	self BypassSledgehammer();
	
	node1 = getvehiclenode( "node_heli_land", "targetname" );
	node2 = getvehiclenode( "node_heli_hover", "targetname" );
	node3 = getvehiclenode( "node_heli_gone", "targetname" );
	node1 waittill( "trigger" );

	self setspeed( 0, 15, 5 );
	self SetWaitNode( node1 );
	self resumespeed( 15 );
	node2 waittill( "trigger" );
	
	self setspeed( 0, 15, 5 );
	self SetWaitNode( node2 );
	node3 waittill( "trigger" );
}

helicopter2_flyby()
{
	wait( 1.5 );
	heli_flyby_2_start_node = GetVehicleNode( "heli_flyby_2_start_node", "targetname" );
	level.pipe_chopper = SpawnVehicle( "t5_veh_helo_mi8_woodland", "intro_helicopter_2", "heli_hip", heli_flyby_2_start_node.origin, (0,0,0) );
	level.pipe_chopper thread check_play_vehicle_rumble( 500.0, "damage_heavy" );
	maps\_vehicle::vehicle_init( level.pipe_chopper );
	level.pipe_chopper thread go_path( heli_flyby_2_start_node );
	level.pipe_chopper.drivepath = 1;
	level.pipe_chopper.health = 99999;
}

activity1_truck_go( startnode, wait_time_to_start )
{
	wait( wait_time_to_start );
	self thread go_path( startnode );
}

activity1_helis()
{
	activity1_heli1_start = GetVehicleNode( "activity1_heli1_start", "targetname" );
	activity1_heli1 = SpawnVehicle( "t5_veh_helo_mi8_woodland", "activity1_heli1", "heli_hip", activity1_heli1_start.origin, (0,0,0) );
	activity1_heli1 thread check_play_vehicle_rumble();
	maps\_vehicle::vehicle_init( activity1_heli1 );
	activity1_heli1.drivepath = 1;
	activity1_heli1 thread go_path( activity1_heli1_start );
	
	activity1_heli2_start = GetVehicleNode( "activity1_heli2_start", "targetname" );
	activity1_heli2 = SpawnVehicle( "t5_veh_helo_mi8_woodland", "activity1_heli2", "heli_hip", activity1_heli2_start.origin, (0,0,0) );
	activity1_heli2 thread check_play_vehicle_rumble();
	maps\_vehicle::vehicle_init( activity1_heli2 );
	activity1_heli2.drivepath = 1;
	activity1_heli2 thread go_path( activity1_heli2_start );
	
	activity1_heli3_start = GetVehicleNode( "activity1_heli3_start", "targetname" );
	activity1_heli3 = SpawnVehicle( "t5_veh_helo_mi8_woodland", "activity1_heli3", "heli_hip", activity1_heli3_start.origin, (0,0,0) );
	activity1_heli3 thread check_play_vehicle_rumble();
	maps\_vehicle::vehicle_init( activity1_heli3 );
	activity1_heli3.drivepath = 1;
	activity1_heli3 thread go_path( activity1_heli3_start );
}

activity1_ambient()
{
	activity1_truck_1_start = GetVehicleNode( "limo_start_node", "targetname" );
	activity1_truck_1 = SpawnVehicle( "vehicle_uaz_hardtop", "activity1_truck_1", "jeep_uaz_closetop", activity1_truck_1_start.origin, (0,0,0) );
	activity1_truck_2 = SpawnVehicle( "t5_veh_gaz66", "activity1_truck_2", "truck_gaz66_tanker", activity1_truck_1_start.origin, (0,0,0) );
	activity1_truck_3 = SpawnVehicle( "t5_veh_gaz66", "activity1_truck_3", "truck_gaz66_troops", activity1_truck_1_start.origin, (0,0,0) );
	activity1_truck_3a = SpawnVehicle( "t5_veh_gaz66", "activity1_truck_3a", "truck_gaz66_troops", activity1_truck_1_start.origin, (0,0,0) );
	activity1_truck_1 maps\_vehicle::lights_on();
	activity1_truck_2 maps\_vehicle::lights_on();
	activity1_truck_3 maps\_vehicle::lights_on();
	activity1_truck_3a maps\_vehicle::lights_on();
	maps\_vehicle::vehicle_init( activity1_truck_1 );
	maps\_vehicle::vehicle_init( activity1_truck_2 );
	maps\_vehicle::vehicle_init( activity1_truck_3 );
	maps\_vehicle::vehicle_init( activity1_truck_3a );
	activity1_truck_1 thread check_play_vehicle_rumble( 750.0 );
	activity1_truck_2 thread check_play_vehicle_rumble( 750.0 );
	activity1_truck_3 thread check_play_vehicle_rumble( 750.0 );
	activity1_truck_3a thread check_play_vehicle_rumble( 750.0 );
	
	activity1_truck_1 thread spawn_and_attach_uaz_driver();
	activity1_truck_2 thread spawn_and_attach_truck_driver();
	activity1_truck_3 thread spawn_and_attach_truck_driver();
	activity1_truck_3a thread spawn_and_attach_truck_driver();
	
	activity1_truck_4_start = GetVehicleNode( "activity1_truck_4_start", "targetname" );
	activity1_truck_6_start = GetVehicleNode( "activity1_truck_6_start", "targetname" );
	activity1_truck_4 = SpawnVehicle( "t5_veh_gaz66", "activity1_truck_4", "truck_gaz66_troops", activity1_truck_4_start.origin, (0,0,0) );
	activity1_truck_5 = SpawnVehicle( "t5_veh_gaz66", "activity1_truck_5", "truck_gaz66_troops", activity1_truck_4_start.origin, (0,0,0) );
	activity1_truck_6 = SpawnVehicle( "t5_veh_gaz66", "activity1_truck_6", "truck_gaz66_troops", activity1_truck_6_start.origin, (0,0,0) );
	activity1_truck_7 = SpawnVehicle( "t5_veh_gaz66", "activity1_truck_7", "truck_gaz66_troops", activity1_truck_6_start.origin, (0,0,0) );
	activity1_truck_4 maps\_vehicle::lights_on();
	activity1_truck_5 maps\_vehicle::lights_on();
	activity1_truck_6 maps\_vehicle::lights_on();
	activity1_truck_7 maps\_vehicle::lights_on();
	maps\_vehicle::vehicle_init( activity1_truck_4 );
	maps\_vehicle::vehicle_init( activity1_truck_5 );
	maps\_vehicle::vehicle_init( activity1_truck_6 );
	maps\_vehicle::vehicle_init( activity1_truck_7 );
	activity1_truck_4 thread check_play_vehicle_rumble( 750.0 );
	activity1_truck_5 thread check_play_vehicle_rumble( 750.0 );
	activity1_truck_6 thread check_play_vehicle_rumble( 750.0 );
	activity1_truck_7 thread check_play_vehicle_rumble( 750.0 );
	activity1_truck_4 thread spawn_and_attach_truck_driver();
	activity1_truck_5 thread spawn_and_attach_truck_driver();
	activity1_truck_6 thread spawn_and_attach_truck_driver();
	activity1_truck_7 thread spawn_and_attach_truck_driver();
	
	activity1_truck_1 thread activity1_truck_go( activity1_truck_1_start, 0.0 );
	activity1_truck_2 thread activity1_truck_go( activity1_truck_1_start, 1.3 );
	activity1_truck_3 thread activity1_truck_go( activity1_truck_1_start, 6.0 );
	activity1_truck_3a thread activity1_truck_go( activity1_truck_1_start, 7.2 );
	activity1_truck_4 thread activity1_truck_go( activity1_truck_4_start, 0.0 );
	activity1_truck_5 thread activity1_truck_go( activity1_truck_4_start, 3.5 );
	activity1_truck_6 thread activity1_truck_go( activity1_truck_6_start, 0.0 );
	activity1_truck_7 thread activity1_truck_go( activity1_truck_6_start, 3.3 );
}

activity2_ambient()
{
	activity2_truck_start = GetVehicleNode( "activity2_truck_start", "targetname" );
	activity2_truck_4 = SpawnVehicle( "t5_veh_gaz66", "activity1_truck_4", "truck_gaz66_troops", activity2_truck_start.origin, (0,0,0) );
	activity2_truck_5 = SpawnVehicle( "t5_veh_gaz66", "activity1_truck_5", "truck_gaz66_troops", activity2_truck_start.origin, (0,0,0) );
	activity2_truck_4 maps\_vehicle::lights_on();
	activity2_truck_5 maps\_vehicle::lights_on();
	maps\_vehicle::vehicle_init( activity2_truck_4 );
	maps\_vehicle::vehicle_init( activity2_truck_5 );
	activity2_truck_4 thread check_play_vehicle_rumble( 750.0 );
	activity2_truck_5 thread check_play_vehicle_rumble( 750.0 );
	activity2_truck_4 thread spawn_and_attach_truck_driver();
	activity2_truck_5 thread spawn_and_attach_truck_driver();

	activity2_truck_4 thread activity1_truck_go( activity2_truck_start, 0.0 );
	activity2_truck_5 thread activity1_truck_go( activity2_truck_start, 3.5 );
}

activity2_migs()
{
	mig_flyover_01_node = GetVehicleNode( "activity2_jet1_start", "targetname" );
	mig_flyover_02_node = GetVehicleNode( "activity2_jet2_start", "targetname" );
	mig_flyover_01 = SpawnVehicle( "t5_veh_air_mig_21_ussr_flying", "activity2_jet1", "plane_mig21_lowres", mig_flyover_01_node.origin, (0,0,0) );
	mig_flyover_02 = SpawnVehicle( "t5_veh_air_mig_21_ussr_flying", "activity2_jet2", "plane_mig21_lowres", mig_flyover_02_node.origin, (0,0,0) );
	maps\_vehicle::vehicle_init( mig_flyover_01 );
	maps\_vehicle::vehicle_init( mig_flyover_02 );
	mig_flyover_01 thread check_play_vehicle_rumble_binocs( 10000.0 );
	mig_flyover_02 thread check_play_vehicle_rumble_binocs( 10000.0 );
	mig_flyover_01 thread go_path( mig_flyover_01_node );
	mig_flyover_02 thread go_path( mig_flyover_02_node );

	//shabs - adding god mode
	mig_flyover_01 veh_magic_bullet_shield( 1 );
	mig_flyover_02 veh_magic_bullet_shield( 1 );

	mig_flyover_01 thread playPlaneFx();
	mig_flyover_02 thread playPlaneFx();
	//kevin adding jet audio
	mig_flyover_01 thread maps\flashpoint_amb::mig_fake_audio(2);
	mig_flyover_02 thread maps\flashpoint_amb::mig_fake_audio(2.5);
}

event1_RocketLaunchIGC()
{
/*
 Remainder of IGC as on MS#6 now plays out (launch, VIP vehicles)
 Woods heads for the pipe exactly as it exists now
*/

	debug_event( "event1_RocketLaunchIGC", "start" );
	
	limo_start_node = GetVehicleNode( "limo_start_node", "targetname" );
	vip_car_01 = SpawnVehicle( "vehicle_uaz_hardtop", "car_01", "jeep_uaz_closetop", limo_start_node.origin, (0,0,0) );
	vip_car_02 = SpawnVehicle( "vehicle_uaz_hardtop", "car_02", "jeep_uaz_closetop", limo_start_node.origin, (0,0,0) );
	vip_car_03 = SpawnVehicle( "vehicle_uaz_hardtop", "car_03", "jeep_uaz_closetop", limo_start_node.origin, (0,0,0) );
	vip_car_01 maps\_vehicle::lights_on();
	vip_car_02 maps\_vehicle::lights_on();
	vip_car_03 maps\_vehicle::lights_on();
	maps\_vehicle::vehicle_init( vip_car_01 );
	maps\_vehicle::vehicle_init( vip_car_02 );
	maps\_vehicle::vehicle_init( vip_car_03 );
	vip_car_01 thread check_play_vehicle_rumble( 800.0 );
	vip_car_02 thread check_play_vehicle_rumble( 800.0 );
	vip_car_03 thread check_play_vehicle_rumble( 800.0 );
	vip_car_01 thread spawn_and_attach_uaz_driver();
	vip_car_02 thread spawn_and_attach_uaz_driver();
	vip_car_03 thread spawn_and_attach_uaz_driver();
	
	vip_car_01 thread go_path( limo_start_node );
	//kevin adding sound calls
	vip_car_01 thread maps\flashpoint_amb::convoy_audio("vip_car_01");
	wait( 1.7 );
	
	//Start helicopter flybys
	level thread helicopter1_flyby();
	level thread helicopter2_flyby();
	
	vip_car_02 thread go_path( limo_start_node );
	vip_car_02 thread maps\flashpoint_amb::convoy_audio("vip_car_02");
	wait( 2.3 );
	vip_car_03 thread go_path( limo_start_node );
	vip_car_03 thread maps\flashpoint_amb::convoy_audio("vip_car_03");
	wait( 4.9 );

	wait( 5.0 );
	level.woods.alwaysRunForward = true;
	//level.woods_anim_origin delete();
	
	debug_event( "event1_RocketLaunchIGC", "end" );
	
	//Give control back to the player
	level.player thread waitThenGiveControlToPlayer( 1.0 );
	wait( 1.0 );
	level.player SetLowReady(false);
	level.player AllowJump(true);
	level.player AllowMelee( true );
	SetSavedDvar( "g_speed", level.default_run_speed );
	//wait( 1.0 ); 
	
	//Goto next event
	flag_set("BEGIN_EVENT2");
}


////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////
