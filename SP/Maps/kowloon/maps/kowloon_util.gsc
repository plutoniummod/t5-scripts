/*
	
	KOWLOON Util

	Misc. Utility functions go here
*/
#include common_scripts\utility; 
#include maps\_anim;
#include maps\_utility;


//
//
nag_dialog( actor, lines, delay, endon_msg )
{
	level endon("kill_old_dialog");
	if ( IsDefined( endon_msg ) )
	{
		level endon( endon_msg );
	}

	if ( !IsDefined(actor) )
	{
		actor = level.heroes[ "clarke" ];
	}

	if ( !IsDefined(lines) )
	{
		lines[0] = "follow_clarke_1";
		lines[1] = "follow_clarke_2";
		lines[2] = "follow_clarke_3";
		lines[3] = "follow_clarke_4";
		lines[4] = "follow_clarke_6";
	}
	if ( !IsDefined( delay ) )
	{
		delay = 10;
	}

	line_num = lines.size;
	while (1)
	{
		line_num++;
		if ( line_num >= lines.size )
		{
			line_num = 0;
			last_line = lines[ lines.size - 1 ];
			lines = array_randomize( lines );
			// Don't play the same line twice in a row
			if ( lines[0] == last_line )
			{
				temp					= lines[ lines.size-1 ];
				lines[ lines.size-1 ]	= lines[0];
				lines[0]				= temp;
			}
		}

		self  anim_single( actor, lines[ line_num ] );
		wait(delay);
	}
}


//
//	Deletes an ai once he's reached his destination.
//	Becomes an ally if too close to enemies
//		self is an ai
civ_flee()
{
	self endon( "death" );

	thread delete_on_goal();
	while (1)
	{
		ai = GetAIArray( "axis" );
		for ( i=0; i<ai.size; i++ )
		{
			if ( DistanceSquared( self.origin, ai[i].origin ) < 256 )
			{
				self.team = "allies";
				return;
			}
		}
		wait( 0.5 );
	}
}


//
//	Deletes an ai once he's reached his destination
//		self is an ai
delete_on_goal()
{
	self endon( "death" );

	//force_goal_self();
	force_goal();
	self waittill( "goal" );

	player = get_players()[0];
	if ( self CanSee( player ) )
	{
		self DoDamage( self.health, self.origin );
	}
	else
	{
		self die();
	}
}


//
//	Have AI follow the player around
//
follow_player( goal_radius )
{
	self endon( "stop_following" );

	self disable_ai_color();

	if ( !IsDefined( goal_radius ) )
	{
		goal_radius = 512;
	}
	self.goalradius = goal_radius;
	player = get_players()[0];
	while (1)
	{
		self.fixedNode = 0;
		self SetGoalPos( player.origin );
		wait( 1.0 );
	}
}




// //	Goto spot makes AI get to an exact spot he's targeting before releasing himself.
// goto_spot( node )
// {
// 	if ( !IsDefined(node) )
// 	{
// 		if ( IsDefined(self.target) )
// 		{
// 			node = GetNode( self.target, "targetname" );
// 		}
// 	}
// 
// 	old_goalradius = self.goalradius;
// 	self.goalradius = 24;
// 
// 	self disable_react();
// 	self.ignoresuppression = true;
// 	self.suppressionthreshold = 1; 
// 	self.noDodgeMove = true; 
// 	self.dontShootWhileMoving = false;
// 	self.grenadeawareness = 1;
// 	self.pathenemylookahead = 0;
// 	self.meleeAttackDist = 0;
// 	self SetGoalNode(node);
// 
// 	self waittill( "goal" );
// 
// 	self.goalradius = old_goalradius;
// }


//	Full screen fadeout
//
fade_out( time, shadername_arg )
{
	shadername = "black";
	if( isdefined(shadername_arg) )
	{
		shadername = shadername_arg;
	}
	
	if( !isdefined( level.fade_out_overlay ) )
	{
		level.fade_out_overlay = NewHudElem();
		level.fade_out_overlay.x = 0;
		level.fade_out_overlay.y = 0;
		level.fade_out_overlay.horzAlign = "fullscreen";
		level.fade_out_overlay.vertAlign = "fullscreen";
		level.fade_out_overlay.foreground = false;  // arcademode compatible
		level.fade_out_overlay.sort = 50;  // arcademode compatible
	}
	
	level.fade_out_overlay SetShader( shadername, 640, 480 );

	// start off invisible
	level.fade_out_overlay.alpha = 0;
	level.fade_out_overlay fadeOverTime( time );
	level.fade_out_overlay.alpha = 1;
	wait( time );
	level notify( "fade_out_complete" );
}


//
//	CQB walk and fight
indoor_fighter()
{
	self endon( "death" );
	
	self enable_cqbwalk();
	if ( is_exact_string( self.script_noteworthy, "rush" ) )
	{
		self maps\_rusher::rush();
		self.pacifist = 1;
		wait(1.5);

		self.pacifist = 0;
	}
}


//
//	CQB walk and move to goal
indoor_force_goal()
{
	self endon( "death" );

	self thread enable_cqbwalk();
	self thread force_goal();
}


/* 
============= 
///ScriptDocBegin
"Name: is_exact_string(<check>)"
"Summary: For string checks undefined means false."
"Module: Utility"
"MandatoryArg: <check> : The boolean value you want to check."
"Example: if ( is_exact_string( self.script_noteworthy, "bob" ) { //do stuff }"
"SPMP: both"
///ScriptDocEnd
============= 
*/
is_exact_string(check, comparison)
{
	return( IsDefined(check) && check == comparison );
}


//
//
make_civilian()
{
	self gun_remove();

}


//
//	Attaches a player to a script_origin
//		self is a player
player_stick( can_look )
{
	if ( !IsDefined( can_look ) )
	{
		can_look = false;
	}

	if ( !IsDefined(level.player_stick_origin) )
	{
		level.player_stick_origin = Spawn( "script_origin", self.origin );
	}
	else
	{
		level.player_stick_origin.origin = self.origin;
	}
	level.player_stick_origin.angles = self.angles;

	if ( !can_look )
	{
		self LinkTo( level.player_stick_origin );
	}
	else
	{
		self LinkTo( level.player_stick_origin );
	}
}


// a background ai...runs somewhere and deletes
silent_runner_bg()
{
	self endon( "death" );

	self.ignoreme = 1;
	set_pacifist( true );

	self thread delete_on_goal();
}

// Someone who runs away and should be ignored by the AI
silent_runner()
{
	self endon( "death" );

	self.ignoreme = 1;
	set_pacifist( true );
}


//
//	Wait for either the player to reach the bottom, an message to be sent,
//	time limit expires or all AI to die
//	Or for their clip to empty
slowdown_wait( trigger_name, end_msg, time_limit )
{
	if ( IsDefined( trigger_name ) )
	{
		trig = GetEnt( trigger_name, "targetname" );
		if ( IsDefined( trig ) )
		{
			trig endon( "trigger" );
		}
	}

	if ( IsDefined( end_msg ) )
	{
		level endon( end_msg );
	}

	if ( !IsDefined( time_limit ) )
	{
		time_limit = 10;
	}
	player = get_players()[0];
	time_over = GetTime() + time_limit*1000;

	// Wait until their clip empties or time expires
	bullets = 1;
	while ( bullets && GetTime() < time_over )
	{
//		current_offhand = player GetCurrentOffhand();
//
//		if( current_offhand == "frag_grenade_sp" || current_offhand == "willy_pete_sp" )
//		{
//			wait( 0.05 );
//		}

		wait( 0.05 );
	
		bullets = player GetCurrentWeaponClipAmmo();
	}
}

slowdown_wait_door_breach( trigger_name, end_msg, time_limit )
{
	if ( IsDefined( trigger_name ) )
	{
		trig = GetEnt( trigger_name, "targetname" );
		if ( IsDefined( trig ) )
		{
			trig endon( "trigger" );
		}
	}

	if ( IsDefined( end_msg ) )
	{
		level endon( end_msg );
	}

	if ( !IsDefined( time_limit ) )
	{
		time_limit = 10;
	}
	player = get_players()[0];
	time_over = GetTime() + time_limit*1000;

	// Wait until their clip empties or time expires
	//bullets = 1;
	while ( GetTime() < time_over )
	{
		wait( 0.05 );
	
		//bullets = player GetCurrentWeaponClipAmmo();
	}
}

//
//
spawn_airplane( start_loc, sound )
{
	// Move da plane!
	start = GetStruct( start_loc , "targetname" );
	destination = GetStruct( start.target, "targetname" );

	// Spawn in the plane model
	plane = Spawn( "script_model", start.origin );
	plane.angles = start.angles;
	plane SetModel( "p_kow_airplane_747" );
	plane thread check_play_flyby();
	Playfxontag(level._effect["plane_light"], plane, "tag_origin");

	// SOUND - Shawn J - jet flyover
	//iprintlnbold ( "de plane - DE PLANE!!");
	playsoundatposition( sound,(0,0,0));
	
	plane MoveTo( destination.origin, 30 );
	plane waittill( "movedone" );

	plane delete();
}


//
//	Check to see if the player fails one of the big jumps
//	If so, leave a special death message
sprint_jump_custom_death_message()
{
	level endon( "sprint_jump_cleared" );
	level thread sprint_jump_custom_death_message_stop();

	flag_set( "sprint_jump_check" );
	level.spring_jump_check_active = 1;
	player = get_players()[0];
	player waittill( "death", attacker, cause, weaponName ); 

	if ( maps\kowloon_util::is_exact_string( cause, "MOD_FALLING" ) )
	{
		level notify( "new_quote_string" );

		SetDvar( "ui_deadquote", &"KOWLOON_JUMP_DEATH" );
	}
}

sprint_jump_custom_death_message_stop()
{
	level waittill( "sprint_jump_cleared" );

	flag_clear( "sprint_jump_check" );
}

check_play_flyby()
{

	level endon("heli_explosion");
	self endon("movedone");
	player = get_players()[0];

	while(1)
	{
		if(Distance2DSquared(player.origin, self.origin) < ( 1500 * 1500 ) )
		{
			player PlayRumbleOnEntity("kowloon_rooftop_plane_1");
			wait(0.5);
		}
		else
		{

			//iprintln(Distance2D(player.origin, self.origin));
			wait(0.1);
		}
	}

}


/* ---------------------------------------------------------------------------------
structs that act like lookat triggers because lookat triggers blow.
--------------------------------------------------------------------------------- */
trigger_point()
{
	wait_for_all_players();

	self endon("death");

	if( IsDefined( self.script_flag_true ) )
	{
		level thread maps\_load_common::script_flag_true_trigger( self );
	}

	if( IsDefined( self.script_flag_set ) )
	{
		level thread maps\_load_common::flag_set_trigger( self, self.script_flag_set );
	}

	if( IsDefined( self.script_flag_clear ) )
	{
		level thread maps\_load_common::flag_clear_trigger( self, self.script_flag_clear );
	}

	if( IsDefined( self.script_flag_false ) )
	{
		level thread maps\_load_common::script_flag_false_trigger( self );
	}

	if( IsDefined( self.script_autosavename ) || IsDefined( self.script_autosave ) )
	{
		level thread maps\_autosave::autosave_name_think( self );
	}

	if( IsDefined( self.script_fallback ) )
	{
		level thread maps\_spawner::fallback_think( self );
	}

	if( IsDefined( self.script_mgTurretauto ) )
	{
		level thread maps\_mgturret::mgTurret_auto( self );
	}

	if( IsDefined( self.script_killspawner ) )
	{
		level thread maps\_spawner::kill_spawner_trigger( self );
	}

	if( IsDefined( self.script_emptyspawner ) )
	{
		level thread maps\_spawner::empty_spawner( self );
	}

	if( IsDefined( self.script_prefab_exploder ) )
	{
		self.script_exploder = self.script_prefab_exploder;
	}

	if( IsDefined( self.script_exploder ) )
	{
		level thread maps\_load_common::exploder_load( self );
	}

	if( IsDefined( self.script_bctrigger ) )
	{
		level thread maps\_load_common::bctrigger( self );
	}

	if( IsDefined( self.script_trigger_group ) )
	{
		self thread maps\_load_common::trigger_group();
	}

	if( IsDefined( self.script_notify ) )
	{
		level thread maps\_load_common::trigger_notify( self, self.script_notify );
	}

	self thread trigger_point_action();

	if (!IsDefined(self.script_timer))
	{
		self.script_timer = 0;
	}

	update_interval = .05;

	while (true)
	{
		player = get_players()[0];

		dot = .8;
		if (IsDefined(self.script_float))
		{
			dot = self.script_float;
		}

		if (	!is_true(self.trigger_off) &&
				player is_player_looking_at(self.origin, .8, self is_true(self.script_trace))
			)
		{
			timer = trigger_point_get_timer();

			///#
			//	Print3d(self.origin, timer, (1, 1, 1), 1, 2, Int(update_interval * 20));
			//#/

			if (timer >= self.script_timer)
			{
				self notify("trigger", get_players()[0]);
			}
		}
		else
		{
			trigger_point_reset_timer();
		}

		wait update_interval;
	}
}

trigger_point_get_timer()
{
	t = GetTime();

	if (!IsDefined(self.trigger_point_timer_start))
	{
		self.trigger_point_timer_start = t;
	}

	return ((t - self.trigger_point_timer_start) / 1000);
}

trigger_point_reset_timer()
{
	self.trigger_point_timer_start = undefined;
}

trigger_point_action()
{
	self endon("death");

	while (true)
	{
		self waittill("trigger");

		if (IsDefined(self.target))
		{
			spawn_manager_enable(self.target, true);
		}

		///#
		//	Print3d(self.origin, "trigger", (1, 1, 1), 1, 2, 30);
		//#/

		if (is_true(self.script_delete))
		{
			waittillframeend;
			self Delete();
		}
	}
}

///////////////////
//
// Kills specific ai with specified script_aigroup
//
///////////////////////////////
kill_aigroup( name )
{
	ai = get_ai_group_ai( name );

	for( i = 0; i < ai.size; i++ )
	{
		if( IsAlive( ai[i] ) )
		{
			ai[i] die();
		}
	}	
}



///////////////////
//
// Force goals guy to his node if he is targeting one
//
///////////////////////////////
force_goal_self()
{
	self endon( "death" );

	if( IsDefined( self.target ) )
	{
		goal_node = GetNode( self.target, "targetname" );
		self thread force_goal( goal_node, 64 );
	}
}



refill_ammo() //self = player
{
    self endon( "disconnect" );
    self endon( "death" );

    primary_weapons = self GetWeaponsList();

    for( i=0; i < primary_weapons.size; i++ )
    {
        clip_size = WeaponClipSize( primary_weapons[i] );
        self SetWeaponAmmoClip( primary_weapons[i], clip_size );

        self GiveMaxAmmo( primary_weapons[i] );
    }
}

weaver_set_friendname()
{
	//self.script_friendname = "Weaver";
	self.name = "Weaver";
}

clarke_set_friendname()
{
	//self.script_friendname = "Clarke";
	self.name = "Clarke";
}

remove_weaver_set_friendname()
{
	//self.script_friendname = "Weaver";
	self.name = "";
}

remove_clarke_set_friendname()
{
	//self.script_friendname = "Clarke";
	self.name = "";
}

civ_timeout_death()
{
	self endon( "death" );

	wait( 15 );
	
	if( IsAlive( self ) )
	{
		self die();
	}
}

reduce_accuracy_veteran()
{
	self endon( "death" );
	
	self.script_accuracy = 1.10;
}