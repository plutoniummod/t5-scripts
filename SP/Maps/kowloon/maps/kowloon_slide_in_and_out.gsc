/*
	
	KOWLOON E5 Slide, In-And_Out

	This starts when the player slides down the roof.
	This ends when we get to the locked gate defend sequence
*/
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim; 
#include maps\_music;

event5()
{

//	level thread disable_player_offhand();

	trigger_wait( "trig_e5" );

	level thread maps\kowloon_util::kill_aigroup( "e4_stealth" );

	flag_set( "event5" );

	level thread slide();
	level thread breach();
	level thread fish_tank();
	level thread cache_area();
	level thread balcony_on_left_dialog();
	level thread slide_in_and_out_dialog();

	level thread maps\kowloon_defend::event6();

	// Wait for the end of the event
	flag_wait( "event6" );

	// Savegame is at the end of the current even so that it doesn't 
	// save immediately after starting a jumpto
	autosave_by_name( "kowloon_defend" );
}


//	Slide down slow mo sweetness
//
slide()
{
	player = get_players()[0];

	level thread slide_timeout();

	trigger_wait( "trig_e5_slide" );
	
	//shabs - turning DDS back on 
	maps\_dds::dds_enable( "allies" );

	SetDVar( "player_sliding_friction", 7.0 );
	flag_set( "e5_player_slide" );

	// start crows
	level notify( "slide_crows_start" );
	playsoundatposition( "evt_crow_2", (-3878,-1481,1724) );

	exploder(5001);

	if ( !flag( "e5_player_slide_timeout" ) )
	{
		ai = simple_spawn( "ai_e5_slide", ::init_e5_slide_guys );

		playsoundatposition ("evt_time_slow_start", (0,0,0));
		clientnotify ("tsg");
	
		//TUEY set music state to SLO_MO_SLIDE
		setmusicstate("SLO_MO_SLIDE");
		
		// Special DOF Setting
		ext_near_start	= 262;
		ext_near_end	= 47;
		ext_far_start	= 616;
		ext_far_end		= 4755;
		ext_near_blur	= 4;
		ext_far_blur	= 0.125;
		player SetDepthOfField( ext_near_start, ext_near_end, ext_far_start, ext_far_end, ext_near_blur, ext_far_blur );

		level notify("timescale_tween");	// kill any hanging threads
		wait( 0.5 );
		
		level thread timescale_tween( 1.0, 0.3, 1.0 );

		level thread maps\createart\kowloon_art::trigger_lightning();
		maps\kowloon_util::slowdown_wait( "trig_e5_sabotage", "e5_slide_cleared" );	// blocking wait call
			
		//shabs - setting a flag to turn on aim assist on slide enemies
		flag_set( "slide_slow_done" );

		level timescale_tween( GetTimeScale(), 1.0, 1.0 );
		playsoundatposition ("evt_time_slow_stop", (0,0,0));
		clientnotify ("tss");

		SetDVar( "player_sliding_friction", 1.5 );
		level thread sabotage();
	}
	else
	{
		SetDVar( "player_sliding_friction", 1.5 );

		trigger_wait( "trig_e5_sabotage" );
		level thread sabotage();
	}

}

//disable_player_offhand()
//{
//	player = get_players()[0];
//
//	trigger_wait( "disable_player_offhand" );
//
//	player disableoffhandweapons();
//}

//
//	If the player doesn't go down, then have AI do it...
slide_timeout()
{
	level endon( "e5_player_slide" );

	level.heroes[ "clarke" ] waittill( "goal" );
	level.heroes[ "weaver" ] waittill( "goal" );
	wait( 30 );

	ai = simple_spawn( "ai_e5_slide", ::init_e5_slide_guys );

	flag_set( "e5_player_slide_timeout" );
	trigger_use( "trig_e5_slide_colors" );
	trigger_use( "trig_e5_slide" );
}

init_e5_slide_guys()
{
	self endon( "death" );
	
	self enable_cqbwalk();
	self disable_aim_assist();
	self thread maps\kowloon_util::force_goal_self();

	flag_wait( "slide_slow_done" );

	self enable_aim_assist();
}

disable_aim_assist()
{
	self DisableAimAssist();
}

enable_aim_assist()
{
	self EnableAimAssist();
}

//	Clark blows up the area we started in
//
sabotage()
{
	waittill_ai_group_cleared( "e5_slide" );

//	//saving default DOF for the last scene
//	Default_Near_Start = 0;
//	Default_Near_End = 1;
//	Default_Far_Start = 8000;
//	Default_Far_End = 10000;
//	Default_Near_Blur = 6;
//	Default_Far_Blur = 0;
//
	player = get_players()[0];
	player maps\_art::setdefaultdepthoffield();

//	player SetLowReady( true );

//	player SetDepthOfField( Default_Near_Start, Default_Near_End, Default_Far_Start, Default_Far_End, Default_Near_Blur, Default_Far_Blur );

	Objective_Set3D( level.obj_num, false );	// Hide

	// Clark unlocks the cache then detonates his apartment
    level.heroes[ "clarke" ] thread maps\kowloon_anim::start_clark_home_explode();

	flag_wait( "e5_clark_detonation_done" );

	player enableoffhandweapons();
	player thread maps\kowloon_util::refill_ammo();
//	player setlowready(false);

	autosave_by_name( "kowloon_sabotage" );
	wait( 0.05 );

	ai = simple_spawn( "ai_e5_civ_rooftop", maps\kowloon_util::civ_flee );
	array_thread( ai, maps\kowloon_util::civ_timeout_death );

	wait( 4.0 );

	level notify("objective_pos_update" );	// Head to the bottom of the slopes
	Objective_Set3D( level.obj_num, true);	// Show again

	// After the helicopter crashes
	door = GetEnt( "2nd_cache_gate", "targetname" );
	door_clip = GetEnt( "2nd_cache_gate_clip", "targetname" );
	door_clip LinkTo( door );
	door RotateYaw( -90, 0.5 );
	door_clip ConnectPaths();
	door ConnectPaths();
	door playsound( "evt_gate_01" );

	level thread battle();
	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "follow_clarke_1");
}


//
//	Advances the battle even if the player doesn't move up
battle_advancer_low()
{
	waittill_ai_group_cleared( "e5_descent" );
	trigger_use( "trig_e5_descent_start_low" );

	waittill_ai_group_cleared( "e5_descent_low" );
	trigger_use( "trig_e5_descent_mid_low" );
}


//
//	Advances the battle even if the player doesn't move up
battle_advancer_high()
{
	waittill_ai_group_cleared( "e5_descent2" );
	trigger_use( "trig_e5_descent_start_high" );

	waittill_ai_group_cleared( "e5_descent_start_high" );
	trigger_use( "trig_e5_descent_mid_high" );

	waittill_ai_group_cleared( "e5_descent_mid" );
	trigger_use( "trig_e5_descent_end_high" );
}


//	Fighting against the opposite building
//
battle()
{
	// Spawn near enemies
	ai = simple_spawn( "ai_e5_descent_start" );
	ai[0] anim_single( ai[0], "intercept_at_4", "spz" );

	ai = simple_spawn( "ai_e5_descent" );

	if( level.gameskill == 3 )
	{
		array_thread( ai, maps\kowloon_util::reduce_accuracy_veteran );
	}

	level thread spetz_push_civ();

	//	Start
//	trigger_wait("trig_e5_descent");

	//TUEY set music to POST_SLIDE_MOVE
//	setmusicstate ("POST_SLIDE_MOVE");

	thread battle_advancer_high();
	thread battle_advancer_low();
	thread battle_high();
	thread battle_low();
}


//
//	Player takes higher route
battle_high()
{
	trigger_wait( "trig_e5_descent_start_high" );

	ai = simple_spawn( "ai_e5_descent_start_high", ::force_goal );

	//	Middle spawners
	trigger_wait( "trig_e5_descent_mid_high" );

	ai = simple_spawn( "ai_e5_descent_mid", ::force_goal );

	//	End
	trigger_wait( "trig_e5_descent_end_high" );

	ai = simple_spawn( "ai_e5_descent_end_high", ::force_goal );
}


//
//	Player takes lower route
battle_low()
{
	trigger_wait( "trig_e5_descent_start_low" );

	ai = simple_spawn( "ai_e5_descent_low_rush", ::roof_fighters );

	//	Middle spawners
	trigger_wait( "trig_e5_descent_mid_low" );

	ai = simple_spawn( "ai_e5_descent_mid" );
	ai = simple_spawn( "ai_e5_descent_mid_rush", ::roof_fighters);

	//	End
	trigger_wait( "trig_e5_descent_end_low" );
}


//
//	Spetsnaz pushes civ out the window
#using_animtree ("generic_human");
spetz_push_civ()
{
   victim = simple_spawn_single( "ai_e5_descent_victim" );
  // victim UseAnimTree(#animtree);
   victim.animname = "civilian";

   pusher = simple_spawn_single( "ai_e5_descent_pusher" );
   pusher.animname = "spetznaz";
   
   sync_node = getstruct("anim_node_window_shove", "targetname");
 
   sync_node anim_reach_aligned( victim, "civ_push");
   sync_node anim_reach_aligned( pusher, "civ_push");
   sync_node thread anim_single_aligned( pusher, "civ_push");
   sync_node thread anim_single_aligned( victim, "civ_push");
}


//
//	Guys that spawn in and run on the roofs
roof_fighters()
{
	player = get_players()[0];
	if ( FindPath( self.origin, player.origin ) )
	{
		maps\_rusher::rush();
	}
	else
	{
		self GetPerfectInfo( player );
	}
}


//	A series of breaches on the floor
//
breach()
{
	// Save just before the breach
	trigger_wait( "trig_e5_breach_balcony" );

	
	autosave_by_name( "kowloon_breach" );
	wait(0.05);

	level notify("objective_pos_update" );	// Head to hallway end
	level thread maps\createart\kowloon_art::turn_lightning_off();

	// Door breach
	trigger_wait( "trig_e5_door_breach" );
	
	//kevin adding slowmo audio and client notifies
	playsoundatposition ("evt_time_slow_start", (0,0,0));
	clientnotify ("tsg");

	//TUEY set music to POST_SLIDE_MOVE
	setmusicstate ("DOOR_BREACH");

	ai = simple_spawn( "ai_e5_door_breach", maps\_rusher::rush );
	ai = simple_spawn( "ai_e5_door_breach_roller", maps\kowloon_gas_leak::roller_deathfunc );
	array_thread ( ai, ::roller );

	//SOUND - Shawn J
	playsoundatposition("evt_pre_breach", (-2572, -817, 1170));
	playsoundatposition("evt_door_breach_boom", (-2572, -817, 1170));

	level thread timescale_tween( 0.50, 0.3, 0.5 );
	//exploder(6001);	
	
	//wait(0.5);
	//door = GetEnt( "e5_breach_door", "targetname" );
	//door Delete();

	level notify("door_breach_start");
	
	//SOUND - Shawn J
	playsoundatposition("evt_door_breach", (-2572, -817, 1170));
	
	maps\kowloon_util::slowdown_wait_door_breach( undefined, undefined, 1.5 );

	level thread timescale_tween( 0.3, 1.0, 0.5 );
	
	playsoundatposition ("evt_time_slow_stop", (0,0,0));
	clientnotify ("tss");

	level thread hallway();

	// Ceiling breach!
	trigger_wait( "trig_e5_ceiling_drop" );

	//ai clean up here
	level thread maps\kowloon_util::kill_aigroup( "e5_descent_mid" );
	level thread maps\kowloon_util::kill_aigroup( "roof_top_battle_guys" );

	level notify("ceiling_collapse_start");

	ai = simple_spawn( "ai_e5_ceiling_drop" );

	exploder(6101);
	ceiling = GetEnt("ceiling_breach_hole", "targetname");
	
	//kevin adding ceiling audio
	ceiling playsound( "evt_roof_breach" );

	physicsExplosionCylinder(ceiling.origin, 300, 10, 1);
	ceiling delete();
//	ceiling ConnectPaths();

	//setting new fog
	start_dist 		= 95.7934;
	half_dist 		= 436.925;
	half_height	 	= 884.424;
	base_height 	= 510.224;
	fog_r 			= 0.227451;
	fog_g 			= 0.305882;
	fog_b 			= 0.333333;
	fog_scale	 	= 3.58794;
	sun_col_r 		= 0.352941;
	sun_col_g 		= 0.439216;
	sun_col_b 		= 0.482353;
	sun_dir_x 		= 0.163263;
	sun_dir_y 		= -0.944148;
	sun_dir_z 		= 0.286235;
	sun_start_ang 	= 0;
	sun_stop_ang 	= 45.2634;
	time 			= 5;
	max_fog_opacity = 1;
	
	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale, sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, sun_stop_ang, time, max_fog_opacity);

	// Outside spawners
	trigger_wait( "trig_e5_outsiders" );

	ai = simple_spawn( "ai_e5_outsiders", maps\kowloon_util::force_goal_self );
	wait( 5.0 );
	level thread maps\kowloon_util::spawn_airplane( "ss_747", "evt_jet_flyover_2" );
}


//
//
roller()
{
	//shabs - added endon death
	self endon( "death" );
	
	maps\kowloon_util::indoor_force_goal();

	//shabs - disabling aim assist
	self DisableAimAssist();

	sync_node = GetStruct( "ss_e5_roll_here", "targetname" );
	sync_node anim_reach_aligned( self, "roll", undefined, "spetznaz" );
	//shabs - so guy can be killed while animating roll
	self.allowdeath = true;
	sync_node anim_single_aligned( self, "roll", undefined, "spetznaz" );
	self.deathfunction = undefined;
	self EnableAimAssist();
}


//	Guys window breach (off screen) into an ajoining hallway
//
hallway()
{
	// Hallway
	trigger_wait( "trig_e5_hallway" );

	ai = simple_spawn( "ai_e5_hallway", ::force_goal );
}


//
//
fish_tank()
{
	// Fish tank room
	trigger_wait( "trig_e5_tank_room" );

	level.lightning_vision_set = 0;

	ai = simple_spawn( "ai_e5_tank_room", ::force_goal );

	//shabs
	ai_e5_tank_room_stair_guy = simple_spawn_single( "ai_e5_tank_room_stair_guy" );	
	ai_e5_tank_room_stair_guy.grenadeawareness =0;
	tank_room_stair_node = GetNode( "tank_room_stair_node", "targetname" );
	ai_e5_tank_room_stair_guy thread force_goal( tank_room_stair_node, 64 );

	level notify("objective_pos_update" );	// Head to defend area

	//setting new fog
	start_dist 		= 112.978;
	half_dist 		= 708.365;
	half_height 	= 2069.37;
	base_height 	= -14.5578;
	fog_r 			= 0.0784314;
	fog_g 			= 0.101961;
	fog_b 			= 0.113725;
	fog_scale 		= 2.99699;
	sun_col_r 		= 0.211765;
	sun_col_g 		= 0.254902;
	sun_col_b 		= 0.294118;
	sun_dir_x 		= 0.163263;
	sun_dir_y 		= -0.944148;
	sun_dir_z 		= 0.286235;
	sun_start_ang 	= 0;
	sun_stop_ang 	= 106.77;
	time 			= 5;
	max_fog_opacity = 1;
	
	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale, sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, sun_stop_ang, time, max_fog_opacity);

}


//
//
cache_area()
{
	// Cache area
	trigger_wait( "trig_e5_cache" );

	ai_e5_cache_guy = simple_spawn_single( "ai_e5_cache_guy" );
	goal_node = GetNode( ai_e5_cache_guy.target, "targetname" );
	ai_e5_cache_guy thread force_goal( goal_node, 64 );

	ai_e5_cache_rpg = simple_spawn_single( "ai_e5_cache_rpg" );
	goal_node = GetNode( ai_e5_cache_rpg.target, "targetname" );
	ai_e5_cache_rpg thread force_goal( goal_node, 64 );
// 	ai = simple_spawn_single( "ai_e5_cache_rpg" );
// 	ai waittill( "goal" );
// 	ai.goal_radius = 12;
}


balcony_on_left_dialog()
{
	trigger_wait("balcony_dialog");

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "balcony_left");

}

slide_in_and_out_dialog()
{

	player = get_players()[0];
	player.animname = "player";

	trigger_wait("trig_e5_hallway");

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "follow_hallway");

	trigger_wait("trig_e5_ceiling_drop");

	wait(0.5);
	level notify("objective_pos_update" );	// Head to outside detour
	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "breach_roof");

	trigger_wait("trig_e5_outsiders");

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "onto_next_balcony");

	//TUEY Setmusic state to Back Outside
	setmusicstate ("BACK_OUTSIDE");

	trigger_wait("balcony_to_right_dialog");
	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "back_outside");

}
