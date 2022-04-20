/*
	
	KOWLOON E3 Cache Run

	This the starts after the player leaps into the cache room.
	It controls up to kowloon_rooftop_battle when the player enters the balcony
		facing the large rooftop battle.
*/
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim; 
#include maps\_music;

event3()
{
	flag_wait( "event3" );
	playsoundatposition ("evt_huge_landing", (0,0,0));

	//shabs - turning off grenade awareness for just the cache room
	level.heroes[ "clarke" ].grenadeawareness = 0;
	level.heroes[ "weaver" ].grenadeawareness = 0;
	
	level.difficult = false;

	Objective_Set3D( level.obj_num, false );	// Hide

	level notify( "sprint_jump_cleared" );

	level thread stop_tv_glow();
	level thread fridge_move_dialog();
	level thread player_lands();
	
	flag_set("on_fridge");
	level notify("on_fridge");
	
	level thread trigger_cache_dialog();

	flag_init( "e3_door_open" );

	level thread cache_room();
	level thread cache_hallway();
	level thread flashbangers();
	level thread window_breach();
	level thread hallway_guy();

	level thread maps\kowloon_rooftop_battle::event4();

	// Wait for the end of the event
	flag_wait( "event4" );

	// Savegame is at the end of the current even so that it doesn't 
	// save immediately after starting a jumpto
	//autosave_by_name( "kowloon_rooftop_battle" ); //shabs - moved this to happen slightly earlier for issue 43266 
}

stop_tv_glow()
{
	exploder(10001);
	tv = GetEnt("exploder_off", "targetname");
	tv waittill("trigger");
	stop_exploder(10001);
}


//
//	Effects for when the player lands from the big jump to the cache room
player_lands()
{
	player = get_players()[0];
	while (!player IsOnGround() )
	{
		wait(0.05);
	}

//	player.animname = "player";
//	player thread anim_single(player, "oomph");

	level thread maps\createart\kowloon_art::turn_lightning_off();
	exploder(3102);

	player thread take_and_giveback_weapons("return_weapon");
	player SetBlur(2, 0.5);
	player PlayRumbleOnEntity("kowloon_awning_rumble");
	Earthquake(1, 0.5, player.origin, 200);
	PhysicsExplosionSphere( player.origin, 150, 10, 1 );
	wait(0.5);

	player notify("return_weapon");
	player Setblur(0, 0.5);

	player stop_magic_bullet_shield();
	player.health = 100;
}

//	Clark reveals the weapons cache
//	NOTE: The animations were chained from the jump over at the end of E2
cache_room()
{
	flag_wait("Clarke_cache_done");
	flag_wait("Weaver_cache_done");
	trigger_wait( "trig_e3_hallway" );
	
	autosave_by_name( "kowloon_cache_open" );
	wait( 0.05 );

	//TUEY Set music state to HALLWAY
	setmusicstate ("HALLWAY");

	maps\kowloon_anim::move_cache_door();

	flag_set( "e3_door_open" );

}


//
//	Breach setup
room_breach( delay, play_anim )
{
	self endon( "death" );

	if ( !IsDefined( play_anim ) )
	{
		play_anim = false;
	}

	// I'm invisible
	self.pacifist	= true;
	self.ignoreme	= true;
	self.ignoreall	= true;

	if ( play_anim )
	{
		self maps\kowloon_anim::door_breach_1( delay );
	}
	else
	{
		// Wait until the door opens
		flag_wait( "e3_door_open" );

		wait( delay );
	}
	
	flag_wait( "e3_door_open" );

	// The guy is targeting a door node to stack up
	//	Go to the next node after the breach.
	old_radius		= self.goalradius;
	self.goalradius	= 16;
	outside_node = GetNode( self.target, "targetname" );
	self thread force_goal( outside_node, 64 );

	inside_node = GetNode( outside_node.target, "targetname" );
	self thread force_goal( inside_node, 64 );
	self waittill_notify_or_timeout( "goal", 2 );

	// I'm normal again
	self.goalradius	= old_radius;
	self.pacifist	= false;
	self.ignoreme	= false;

	breacher_inside_node = GetNode( "breacher_inside_node", "targetname" );
	self SetGoalNode( breacher_inside_node );
	
	wait(2.5);
	
	self.ignoreall = false;
}

//	Hallway encounters
//
cache_hallway()
{
	level thread hallway_advancer();

	// Setup room breach
	ai = simple_spawn_single( "ai_e3_hallway_breach1", ::room_breach, 0.05, true );
	ai thread monitor_death_stop_door();
	ai = simple_spawn_single( "ai_e3_hallway_breach2", ::room_breach, 2.0, false );
    ai thread spz_breach_dialog();

	level thread open_hallway_door();

	// Wait until the door opens
	flag_wait( "e3_door_open" );

//	door = GetEnt( "e3_breach_door", "targetname" );
//	door_clip = GetEnt( "e3_breach_door_clip", "targetname" );
//	door_clip LinkTo( door );
//	door_clip ConnectPaths();
//	door RotateYaw( 115, 0.5 );

	// Other guys
	ai = simple_spawn( "ai_e3_hallway_stairs", ::stair_guy );

	wait( 1.0 );

	ai = simple_spawn( "ai_e3_hallway", maps\kowloon_util::indoor_fighter );

	if( level.gameskill == 3 )
	{
		array_thread( ai, maps\kowloon_util::reduce_accuracy_veteran );
	}

	// Next wave
	trigger_wait( "trig_e3_hallway2" );

	//shabs - turning grenade awareness back on 
	//level.heroes[ "clarke" ].grenadeawareness = 1;
	//level.heroes[ "weaver" ].grenadeawareness = 1;
	
//	level.heroes[ "weaver" ] enable_cqbwalk();
//	level.heroes[ "clarke" ] enable_cqbwalk();

	ai = simple_spawn( "ai_e3_hallway2", maps\kowloon_util::indoor_fighter );
}



monitor_death_stop_door()
{
	self waittill( "death" );
	level notify( "door_kicker_killed" );
}

open_hallway_door()
{
	level endon( "door_kicker_killed" );

	//flag_wait( "e3_door_open" );
	flag_wait( "hallway_door_open" );

	door = GetEnt( "e3_breach_door", "targetname" );
	door_clip = GetEnt( "e3_breach_door_clip", "targetname" );
	door_clip LinkTo( door );
	door_clip ConnectPaths();
	door RotateYaw( 115, 0.5 );
}

//
//	Advances the battle even if the player doesn't move up
hallway_advancer()
{
	waittill_ai_group_cleared( "e3_hallway_start" );
	trigger_use( "trig_e3_hallway2" );
}

//
//
stair_guy()
{
	self endon( "death" );

	maps\kowloon_util::indoor_fighter();
	
	self.grenadeawareness = 0;

	//shabs - makes sure the guys runs down
	e3_stairs_node = GetNode( "e3_stairs_node", "targetname" );
	self thread force_goal( e3_stairs_node, 64 );

	self thread	e3_stairwell_dialog();
}


//	Player gets flashbanged and rushed
//
flashbangers()
{
	trigger_wait( "trig_e3_flashbang" );

	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "flashbang_anim");

	flashbang = GetStruct( "ss_e3_flashbang", "targetname" );
	target = GetStruct( flashbang.target, "targetname" );
	direction = VectorNormalize(target.origin - flashbang.origin);
	vector = vector_multiply( direction, 500 );

	ai = simple_spawn( "ai_e3_flashbangers", maps\kowloon_util::indoor_fighter );
	ai[0] MagicGrenadeType("flash_grenade_sp", flashbang.origin, vector, 1.0); //shabs - cutting flash detonation in half

	//shabs - making heroes ignore grenades so they dont run away from the flash
	level.heroes[ "weaver" ].grenadeawareness = 0;
	level.heroes[ "clarke" ].grenadeawareness = 0;

	wait( 5 );

	level.heroes[ "weaver" ].grenadeawareness = 1;
	level.heroes[ "clarke" ].grenadeawareness = 1;
}


//	Guys rappel down and bust in through the windows
window_breach()
{
	trigger_wait( "trig_e3_window_breach" );
//	ai = simple_spawn( "ai_e3_window_breach", ::enable_cqbwalk );

	first_rappel_guy_1 = simple_spawn_single( "first_rappel_guy_1", maps\kowloon_anim::rappel_window_breach );//kiparis
	second_rappel_guy_2 = simple_spawn_single( "second_rappel_guy_2", maps\kowloon_anim::rappel_window_breach ); //spas
	second_rappel_guy_1 = simple_spawn_single( "second_rappel_guy_1", maps\kowloon_anim::rappel_window_breach );//kiparis
	
//	first_rappel_guy_2 = simple_spawn_single( "first_rappel_guy_2", maps\kowloon_anim::rappel_window_breach );//kiparis
	first_rappel_guy_3 = simple_spawn_single( "first_rappel_guy_3", maps\kowloon_anim::rappel_window_breach );//kiparis

	wait( 0.25 );
	
	player = get_players()[0];
	
	if (level.gameskill > 1)
	{
		dvarName = "player" + player GetEntityNumber() + "downs";
		player.downs = getdvarint( dvarName );
	}
	
	//this should slow a sprinter type down
	
	if (level.gameskill > 1 && player.downs > 1)
	{
		level.difficult = true;
	}
	else
	{
		sprint_blocker = simple_spawn_single( "sprint_blocker", ::init_sprint_blocker );
	}

	//ai thread maps\kowloon_anim::rappel_window_breech();
	level thread rappel_glass_break();

	level thread look_outside();

	//setting new fog settings
	start_dist 		= 101.084;
	half_dist 		= 493.043;
	half_height 	= 1247.69;
	base_height 	= 1553.19;
	fog_r 			= 0.211765;
	fog_g 			= 0.247059;
	fog_b 			= 0.258824;
	fog_scale 		= 3.14083;
	sun_col_r 		= 0.271;
	sun_col_g 		= 0.278;
	sun_col_b 		= 0.302;
	sun_dir_x 		= 0.163263;
	sun_dir_y 		= -0.944148;
	sun_dir_z 		= 0.286235;
	sun_start_ang 	= 0;
	sun_stop_ang 	= 99.2932;
	time 			= 5;
	max_fog_opacity = 0.857762;
	
	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale, sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, sun_stop_ang, time, max_fog_opacity);

}

init_sprint_blocker()
{
	self endon( "death" );

	self.goalradius = 4;
	
	trigger_wait( "trig_e4_lower_rooftop" );
	if( IsAlive( self) )
	{
		self die();
	}
}

//
//	Spawn some stuff outside if the player looks outside
look_outside()
{
	level endon( "event4" );

	// Don't do it until the first set of breachers are killed.
	waittill_ai_group_cleared( "e3_window_breach1" );

	trigger_wait( "trig_e3_look_outside" );

	ai = simple_spawn( "ai_e3_civs", maps\kowloon_util::delete_on_goal );
	array_thread( ai, maps\kowloon_util::civ_timeout_death );

	wait( 2.0 );

	ai = simple_spawn( "ai_e3_rooftop" );
}


rappel_glass_break()
{
	wait(2.0);
	
	//exploder( 3501 );
	//damage_spot = getstruct("guy_2_damage_struct", "targetname");
	//RadiusDamage( damage_spot.origin, 40, 400, 400);
	//wait( 0.5 );

	damage_spot = getstruct("guy_3_damage_struct", "targetname");
	RadiusDamage( damage_spot.origin, 20, 400, 400);
	
	wait(0.1);

	damage_spot = getstruct("guy_4_damage_struct", "targetname");
	RadiusDamage( damage_spot.origin, 20, 400, 400);
	
	damage_spot = getstruct("guy_2_damage_struct", "targetname");
	RadiusDamage( damage_spot.origin, 20, 400, 400);
}

	
hallway_guy()
{
	trigger_wait( "trig_e3_final_corridor" );
	
	if (!level.difficult)
	{
		ai = simple_spawn_single( "ai_e3_final_corridor", ::force_goal );
		ai.goalradius = 32;
		ai.grenadeawareness = 0;
	}
}

trigger_cache_dialog()
{
	trigger_wait("e3_hallway_dialog");

	level notify("kill_old_dialog");
	level thread e3_hallway_dialog();

//	level.heroes[ "weaver" ] disable_cqbwalk();
//	level.heroes[ "clarke" ] disable_cqbwalk();

	trigger_wait("trig_e3_window_breach");

	level notify("objective_pos_update" );	// Head to rooftop battle
	level notify("kill_old_dialog");
	level thread e3_window_breach_dialog();

	trigger_wait("trig_e3_final_corridor");

	autosave_by_name( "kowloon_rooftop_battle" );

	level notify("kill_old_dialog");
	level thread e3_which_way_dialog();
}


fridge_move_dialog()
{
	level endon("kill_old_dialog");
	
	level waittill("end_cache_loop");

	//level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "help_me_move");

	wait(2);

	//.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "grab_what_you_need");
	level notify("objective_pos_update" );	// Head to cache room
	Objective_Set3D( level.obj_num, true );	// show

	wait(13);
	//level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "this_way_clarke");
	level notify("objective_pos_update" );	// Head down the hall
}

e3_hallway_dialog()
{
	level endon("kill_old_dialog");

	player = get_players()[0];
	player.animname = "player";

	if ( get_ai_group_sentient_count( "e3_hallway_start" ) > 0 )
	{
		player anim_single(player, "on_me");
		wait( 1 );
	}

	level notify( "check_left" );
}

//
//	Watch out for the guy on the stairs
e3_stairwell_dialog()
{
	self endon( "death" );

	level waittill( "check_left" );
	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "eye_left");
}


spz_breach_dialog()
{
	self endon("death");
	self.animname = "spz";

	self anim_single(self, "they_down_here");
	self anim_single(self, "Check_all_apartments");
	flag_wait( "e3_door_open" );
	self anim_single(self, "team_7_breach");
}

e3_window_breach_dialog()
{

	level endon("kill_old_dialog");
	//wait( 1.5 );
	wait( 0.75 );

	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "window_breach");
	
}

e3_which_way_dialog()
{

	level endon("kill_old_dialog");

	player = get_players()[0];
	player.animname = "player";

	player anim_single(player, "which_way");

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "left_door");

}
