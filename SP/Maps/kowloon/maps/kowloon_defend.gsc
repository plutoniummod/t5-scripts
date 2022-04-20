/*
	
	KOWLOON E6 Defend

	This starts when we get to the locked gate defend sequence.
	This ends after Clark falls to his death.
*/
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim; 
#include maps\_music;

event6()
{
	flag_wait( "event6" );
	
	defend_gate_keypad = GetEnt( "defend_gate_keypad", "targetname" );
	door = GetEnt( "defend_gate", "targetname" );
	
	defend_gate_keypad LinkTo( door );

	level thread maps\createart\kowloon_art::turn_lightning_on_combat_roof();

	level thread defend_dialog();

	//shabs - threading defend_clark
	level thread defend_clark();
	
	// Wait for the end of the event
	level thread maps\kowloon_platform::event7();
}


//
//
defend_floodspawn( end_msg, spawn_func )
{
	level endon( end_msg );

	while (1)
	{
		self.count = 1;
		ai = simple_spawn_single( self );
		if ( IsDefined( ai ) )
		{
			ai thread [[ spawn_func ]]();
			ai waittill( "death" );

			if ( flag( "e6_clark_unlock_done") )
			{
				wait( 15.0 );
			}
			else
			{
				wait( RandomFloatRange( 3.0, 5.0 ) );
			}
		}

		wait( 1.0 );
	}
}


spawn_extra_attackers()
{
	level endon( "stop_defend_spawners" );

	trigger_wait( "defend_event_killspawner" );

	simple_spawn( "extra_defend_rushers", maps\_rusher::rush );
}


room_enforcer()
{
	level endon( "stop_defend_spawners" );

	trigger_wait( "trig_room_enforcer" );
	simple_spawn_single( "room_enforcer", maps\_rusher::rush );
}

//
//	Spawn guys to come after Clark
spawn_attackers()
{
	attackers = GetEntArray( "ai_e6_attackers", "targetname" );
	attackers = array_randomize( attackers );

	// Keep sending guys until Clarke unlocks the doors
	for ( i=0; i<attackers.size; i++ )
	{
		if ( IsDefined( attackers[i].script_noteworthy ) && 
			 attackers[i].script_noteworthy == "rushers" )
		{
			attackers[i] thread defend_floodspawn( "e6_clark_unlock_done", maps\_rusher::rush );
			wait(4.0);
		}
		else
		{
			attackers[i] thread defend_floodspawn( "stop_defend_spawners", ::force_goal );
		}
		wait( 1.0 );
	}
}


//	Defend Clark while he opens a door
//
defend_clark()
{
	wait(15);	// Give player some time to look at weapons

	//killspawns 2 guys if player enters the room
	defend_event_killspawner = GetEnt( "defend_event_killspawner", "targetname" );
	defend_event_killspawner trigger_on();

	trig_room_enforcer = GetEnt( "trig_room_enforcer", "targetname" );
	trig_room_enforcer trigger_on();

	level thread spawn_extra_attackers();
	level thread room_enforcer();

	level thread spawn_attackers();
	wait( 2.0);

	level thread maps\kowloon::kowloon_defend_objective();
	flag_set("e6_start_defending");
	wait( 8 );

	//IPrintLnBold( "VO starting now" );
	//shabs - changing wait above to 8 seconds, adding two lines of dialogue before sending clarke to gate
	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "watch_back");
	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "cover_me");

	// Move to unlock
	level.heroes[ "clarke" ] thread maps\kowloon_anim::clark_unlock_gate();
	
// Not a padlock...it's a keypad - MM
// 	//SOUND - Shawn J
// 	padlock = Spawn("script_origin",(-3704, 153, 646)); 
// 	padlock playloopsound ("evt_lock");

	//
	//	Defend Done
	//
	flag_wait( "e6_clark_unlock_done");

	//SOUND - Shawn J
// 	padlock stoploopsound();	
// 	padlock Delete();
	playsoundatposition("evt_door_unlocked", (-3704, 153, 646));
	
	// Open the door.
	door = GetEnt( "defend_gate", "targetname" );
	door RotateYaw( 100, 1.0, 0.05, 0.5 );
	door ConnectPaths();

	// Move heroes into position for E7
	node = GetNode( "n_e6_clark_jump_wait", "targetname" );
	level.heroes[ "clarke" ] disable_ai_color();
	level.heroes[ "clarke" ].goalradius = 32;
	level.heroes[ "clarke" ] SetGoalNode( node );

	// Move Weaver into position
	node = GetNode( "n_start_weaver_e7", "targetname" );
	level.heroes[ "weaver" ] disable_ai_color();
	level.heroes[ "weaver" ].goalradius = 32;
	level.heroes[ "weaver" ] SetGoalNode( node );

	// Kill off rushers, from farthest to closest
	player = get_players()[0];
	ai = GetAIArray( "axis" );
	ai = get_array_of_closest( player.origin, ai );
	for ( i=ai.size-1; i>=0; i-- )
	{
		if ( IsAlive(ai[i]) )
		{
			ai[i] DoDamage( ai[i].health, level.heroes[ "weaver" ].origin, level.heroes[ "weaver" ] );
			wait( RandomFloatRange( 0.3, 1.0 ) );
		}
	}
}


defend_dialog()
{
	player = get_players()[0];
	player.animname = "player";

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "not_far_now");
	wait( 0.1 );

	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "More_weapons");
	flag_wait("e6_start_defending");
	
	//TUEY set music state to Heavy Action
	setmusicstate ("HEAVY_ACTION");

	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "spetsnaz_inbound");

	wait( 18.5 );

	level.heroes[ "weaver" ] anim_single( level.heroes[ "weaver" ], "combination");

	flag_wait("e6_clark_unlock_done");
	
	level.heroes[ "clarke" ] anim_single( level.heroes[ "clarke" ], "leap_of_faith");
	wait( 5.0 );

	// If player doesn't follow, then nag
	if ( !flag( "e7_start_clark_jump" ) )
	{
		level.heroes[ "clarke" ] maps\kowloon_util::nag_dialog( level.heroes[ "clarke" ], undefined, 7.0, "e7_start_clark_jump" );
	}
}