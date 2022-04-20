/*
//-- Level: Full Ahead
//-- Full Ahead Utility Scripts
//-- Level Designer: Christian Easterly
//-- Scripter: Jeremy Statz
*/

#include maps\_utility;
#include common_scripts\utility;
#include maps\_utility_code;
#include maps\_anim;
#include maps\fullahead_drones;

// ~~~ Wrapper for the print function, so it can be disabled easily if needed ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fa_print( print_message )
{
	println( "\n  FULLAHEAD> " + print_message );
}

// ~~~ Stolen from somewhere... does a fullscreen fade from white ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fade_out( time, shadername_arg, opacity )
{
	fa_print( "fade_out starting" );
	startalpha = 0.0;
	shadername = "black";
	
	if( isdefined(shadername_arg) )
	{
		shadername = shadername_arg;
	}
	
	if( isdefined(opacity) )
	{
		startalpha = opacity;
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
	level.fade_out_overlay.alpha = startalpha;
	level.fade_out_overlay fadeOverTime( time );
	level.fade_out_overlay.alpha = 1;
	wait( time );
	level notify( "fade_out_complete" );
	fa_print( "fade_out done" );
}

// ~~~ Stolen from somewhere... does a fullscreen fade to white ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fade_in( time, shadername_arg, delay_time, opacity, send_completed_notify )
{
	fa_print( "fade_in starting" );
	shadername = "black";
	endalpha = 0.0;
	
	if( isdefined(delay_time) )
	{
		wait( delay_time );
	}
	
	if( isdefined(opacity) )
	{
		endalpha = opacity;
	}

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

	level.fade_out_overlay.alpha = 1;
	level.fade_out_overlay fadeOverTime( time );
	level.fade_out_overlay.alpha = endalpha;
	wait( time );
	
	// each reznov cutscene sends this notify out twice 
	if( isDefined( send_completed_notify ) && send_completed_notify == true )
	{
		level notify( "fade_in_complete" );
	}
	
	fa_print( "fade_in done" );
}

// ~~~ Returns the first player, nothing more ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
get_player()
{
	return get_players()[0];
}

// ~~~ teleports the player to the specified script_struct ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
player_to_struct( struct_targetname )
{
	newpos = getstruct( struct_targetname, "targetname" );
	p = get_player();
	p setorigin( newpos.origin );
	p setplayerangles( newpos.angles );
	p.health = 100;
}

// ~~~ Takes all your weapons away, for real ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fa_take_weapons() // self should be player
{
	weapons = self getweaponslist();

	for (i=0; i<weapons.size; i++)
	{
// 		if( issubstr(weapons[i],"grenade") ) // don't take it away, or you can't throw grenades back
// 		{
// 			fa_print( "Setting ammo to 0: " + weapons[i] );
// 			self setweaponammostock( weapons[i], 0 );
// 		}
// 		else
//		{
			fa_print( "Removing weapon: " + weapons[i] );
			self takeweapon (weapons[i]);
// 		}
	}

	player_flashlight_enable( false );
}

// ~~~ Gives the player the flashlight, then turns it on ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
player_flashlight_pistol()
{
	p = get_player();
	p giveweapon( level.flashlightWeapon );
	p givemaxammo( level.flashlightWeapon );
	p switchtoweapon( level.flashlightWeapon );

	p thread detect_flashlight_weapon_switch();
	
	// flashlight is always on
	//p thread detect_flashlight_on_off_button();

}

// ~~~ Takes the flashlight away, turns off the light ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
player_flashlight_remove()
{
	player_flashlight_enable( false );
	get_player() takeweapon( level.flashlightWeapon );
}

// ~~~ Turns on and off the flashlight light ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
player_flashlight_enable( is_enabled )
{
	self.flashlight_on = is_enabled;

	if( self.flashlight_on )
	{
		SetSavedDvar( "r_enableFlashlight","1" );
	}
	else
	{
		SetSavedDvar( "r_enableFlashlight","0" );
	}
}

detect_flashlight_weapon_switch()
{
	level.default_light = "on"; // light is on or off when weapon is initially equipped

	while( 1 )
	{
		// wait till we have the flashlight weapon equipped
		while( 1 )
		{
			currentweapon = self GetCurrentWeapon();
			if( isdefined( currentweapon ) && currentweapon == level.flashlightWeapon )
			{
				break;
			}
			wait( 0.05 );
		}

		// wait a moment (for weapon to pull up, then turn on light
		wait( 0.5 );
		self.flashlight_on_off_enabled = true;
		self player_flashlight_enable(true);

		if( level.default_light == "off" )
		{
			self player_flashlight_enable(false);
		}
		else
		{
			self player_flashlight_enable(true);
		}

		// now wait till player switch to something else
		while( 1 )
		{
			currentweapon = self GetCurrentWeapon();
			if( isdefined( currentweapon ) && currentweapon != level.flashlightWeapon )
			{
				break;
			}
			wait( 0.05 );
		}

		self.flashlight_on_off_enabled = false;
		self player_flashlight_enable(false);
	}
}

set_move_speed( dest )
{
	level.player_movespeed_scale = dest;
	self SetMoveSpeedScale( dest );
}

// ~~~~~ transitions the player's speedscale over time ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
gradiate_move_speed( dest, increment ) // self should be player
{
	if( !isdefined(increment) )
	{
		increment = 0.01;
	}

	if( !isdefined(level.player_movespeed_scale) )
	{
		level.player_movespeed_scale = 1.0;
	}

	current = level.player_movespeed_scale;

	while( true )
	{
		if( current > dest )
		{
			current -= increment;
			if( current <= dest )
			{
				current = dest;
				break;
			}
		}
		else
		{
			current += increment;
			if( current >= dest )
			{
				current = dest;
				break;
			}
		}

		level.player_movespeed_scale = current;
		self SetMoveSpeedScale( current );
		wait( 0.05 );
	}

	level.player_movespeed_scale = current;
	self SetMoveSpeedScale( current );
}

// ~~~ returns the origin of the entity with the specified targetname ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ent_origin( e_targetname )
{
	entity = getent( e_targetname, "targetname" );
	if( isdefined(entity) )
	{
		return entity.origin;
	}

	struct = getstruct( e_targetname, "targetname" );
	if( isdefined(struct) )
	{
		return struct.origin;
	}

	return undefined;
}

// ~~~ returns the opposite team ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
get_other_team( team )
{
	if ( team == "allies" )
		return "axis";
	else if ( team == "axis" )
		return "allies";

	assertMsg( "getOtherTeam: invalid team " + team );
}

// self should be the AI to teleport
teleport_ai_to_node( value, key )
{
	node = getnode( value, key );
	self forceteleport( node.origin, node.angles );
	self setgoalnode( node );
	self.goalradius = 32;
}

// self is level
player_follow_struct_chain( start_targetname, trans_speed, move_speed )
{
	p = get_player();
	org = spawn( "script_origin", p.origin );
	org.angles = p.angles;
	p linkto( org );

	nextnode = getstruct( start_targetname, "targetname" );
	org moveto( nextnode.origin, trans_speed );
	org rotateto( nextnode.angles, trans_speed );
	wait( trans_speed );

	while( isdefined(nextnode.target) )
	{
		nextnode = getstruct( nextnode.target, "targetname" );
		org moveto( nextnode.origin, move_speed );
		org rotateto( nextnode.angles, move_speed );
		wait( move_speed );
	}

	p unlink();
}

// self is the entity doing the following
follow_struct_chain( start_targetname, trans_speed, move_speed )
{
	nextnode = getstruct( start_targetname, "targetname" );
	dist = distance( self.origin, nextnode.origin );
	duration = dist/trans_speed;

	if( duration <= 0 ) // moveto doesn't handle this very well
	{
		duration = 0.05;
	}

	self moveto( nextnode.origin, duration );
	self rotateto( nextnode.angles, duration );

	self waittill_multiple( "movedone", "rotatedone" );

	while( isdefined(nextnode.target) )
	{
		prevnode = nextnode;
		nextnode = getstruct( prevnode.target, "targetname" );
		dist = distance( self.origin, nextnode.origin );
		duration = dist/move_speed;

		self moveto( nextnode.origin, duration );
		self rotateto( nextnode.angles, duration );

		self waittill_multiple( "movedone", "rotatedone" );
	}
}

// for a "squad" of two
// <door> : which nodes they are being sent to: "p2shiparrival_" + door + "_0"+n
// <usewalk>: not actually used at the moment
// <waitnode>:  STRING: second guy won't move until first guy has gotten to the node with this targetname.  The idea is for this to be some node acceptably far from the departure point
//				that the second guy won't bash into the first guy, but not all the way to the next door.
shiparrival_front_two_to_nodes( door, usewalk, waitnode )
{
	level notify( "override_front_two_to_nodes" );
	wait(0.1);
	level endon( "override_front_two_to_nodes" );
	
	if( isdefined(usewalk) )
	{
		// future use, perhaps
	}
	
		
	level.shipsquad[0].ignoresuppression = true;
	level.shipsquad[0].goalradius = 32;	
	if ( isdefined( waitnode ) && (waitnode != "") )
	{
		level.shipsquad[0] SetGoalNode_tn( waitnode );
		level.shipsquad[0] waittill( "goal" );
		level.shipsquad[0] SetGoalNode( GetNode( "p2shiparrival_" + door + "_01", "targetname" ) );
	}
	else
	{	
		level.shipsquad[0] SetGoalNode( GetNode( "p2shiparrival_" + door + "_01", "targetname" ) );
		wait( 1.8 );
	}
	
	if( isalive( level.shipsquad[1] ) )
	{
		level.shipsquad[1].noDodgeMove = true;
		level.shipsquad[1].ignoresuppression = true;
		level.shipsquad[1] SetGoalNode( GetNode( "p2shiparrival_" + door + "_02", "targetname" ) );
		level.shipsquad[1].goalradius = 32;
	}	
}

// for a "squad" of two
shiparrival_back_two_to_nodes( door, usewalk, delay_time )
{
	level notify( "override_back_two_to_nodes" );
	wait(0.1);
	level endon( "override_back_two_to_nodes" );
	
	if( isdefined(usewalk) )
	{
		// future use, perhaps
	}

	if( isdefined( delay_time ) && ( delay_time > 0.0 ) )
	{
		wait( delay_time );
	}		
	
	if( isalive( level.shipsquad[2] ) )
	{
		level.shipsquad[2].ignoresuppression = true;
		level.shipsquad[2] SetGoalNode( GetNode( "p2shiparrival_" + door + "_03", "targetname" ) );
		level.shipsquad[2].goalradius = 32;		
	}

	if( isalive( level.shipsquad[3] ) )
	{
		wait( 1.8 );
		
		level.shipsquad[3].noDodgeMove = true;
		level.shipsquad[3].ignoresuppression = true;
		level.shipsquad[3] SetGoalNode( GetNode( "p2shiparrival_" + door + "_04", "targetname" ) );
		level.shipsquad[3].goalradius = 32;
	}	
	
}

shiparrival_squad_to_nodes( door, usewalk )
{
	// JMA - I've turned this function to a thread, so any calls to this will end any
	//	previous destinations and send the AI to a new node
	level notify( "override_squad_to_nodes" );
	wait(0.1);
	level endon( "override_squad_to_nodes" );
	
	waitarray = array( 1.8, 2.0, 1.5, 3.0 );
	waitCount = 0; 
	
	
	if( isdefined(usewalk) )
	{

	}
		
	level.shipsquad[0].ignoresuppression = true;
	level.shipsquad[0] SetGoalNode( GetNode( "p2shiparrival_" + door + "_01", "targetname" ) );
	level.shipsquad[0].goalradius = 32;
	
	if( isalive( level.shipsquad[1] ) )
	{
		wait( waitarray[waitCount] );
		waitCount++;
		
		level.shipsquad[1].noDodgeMove = true;
		level.shipsquad[1].ignoresuppression = true;
		level.shipsquad[1] SetGoalNode( GetNode( "p2shiparrival_" + door + "_02", "targetname" ) );
		level.shipsquad[1].goalradius = 32;
	}
	
	if( isalive( level.shipsquad[2] ) )
	{
		wait( waitarray[waitCount] );
		waitCount++;
	
		level.shipsquad[2].noDodgeMove = true;		
		level.shipsquad[2].ignoresuppression = true;
		level.shipsquad[2] SetGoalNode( GetNode( "p2shiparrival_" + door + "_03", "targetname" ) );
		level.shipsquad[2].goalradius = 32;
	}
	
	if( isalive( level.shipsquad[3] ) )
	{
		wait( waitarray[waitCount] );
		waitCount++;
	
		level.shipsquad[3].noDodgeMove = true;		
		level.shipsquad[3].ignoresuppression = true;
		level.shipsquad[3] SetGoalNode( GetNode( "p2shiparrival_" + door + "_04", "targetname" ) );
		level.shipsquad[3].goalradius = 32;
	}
}

shiparrival_vip_to_nodes( door, do_blocker, blocker_trigger_targetname, delay_time )
{
	// JMA - I've turned this function to a thread, so any calls to this will end any
	//	previous destinations and send the AI to a new node
	level notify( "override_vip_to_nodes" );
	wait(0.1);
	level endon( "override_vip_to_nodes" );

	waitarray = array( 2.0, 1.5, 1.5 );
	waitCount = 0; 
			
	if( isdefined( delay_time ) && ( delay_time > 0.0 ) )
	{
		wait( delay_time );
	}

	
	// Kravchenko leads
	if( flag("P2SHIPARRIVAL_EXECUTION_FINISHED") )
	{
		level.kravchenko SetGoalNode( GetNode( "p2shiparrival_" + door + "_krav", "targetname" ) );
		level.kravchenko.goalradius = 64;
	}

	wait( waitarray[waitCount] );
	waitCount++;
			
	// then Steiner, so Dragovich can keep an eye on him
	level.steiner SetGoalNode( GetNode( "p2shiparrival_" + door + "_steiner", "targetname" ) );
	level.steiner.goalradius = 64;	
	
	wait( waitarray[waitCount] );
	waitCount++;
	
	// Dragovich brings up the rear		
	level.dragovich SetGoalNode( GetNode( "p2shiparrival_" + door + "_vertov", "targetname" ) );
	level.dragovich.goalradius = 64;

	if( isdefined(do_blocker) && do_blocker == true )
	{
		level notify( "nextblocker" );
		level endon( "nextblocker" );

		blocker = getent( "p2shiparrival_" + door + "_blocker", "targetname" );
		trig = getent( blocker_trigger_targetname, "targetname" );

		level.dragovich waittill( "goal" );
		p = get_player();

		while(true)
		{
			if( p istouching(trig) )
			{
				blocker solid();
				return;
			}
			wait(0.05);
		}
	}
}

shiparrival_back_five_to_nodes( door, do_blocker, blocker_trigger_targetname, delay_time )
{
	// JMA - I've turned this function to a thread, so any calls to this will end any
	//	previous destinations and send the AI to a new node
	level notify( "override_back_five_to_nodes" );
	wait(0.1);
	level endon( "override_back_five_to_nodes" );

	waitarray = array( 2.0, 1.5, 1.5, 1.5, 1.5 );
	waitCount = 0; 
			
	if( isdefined( delay_time ) && ( delay_time > 0.0 ) )
	{
		wait( delay_time );
	}

	
	// Kravchenko leads
	if( flag("P2SHIPARRIVAL_EXECUTION_FINISHED") )
	{
		level.kravchenko SetGoalNode( GetNode( "p2shiparrival_" + door + "_krav", "targetname" ) );
		level.kravchenko.goalradius = 64;
	}

	wait( waitarray[waitCount] );
	waitCount++;
			
	// then Steiner, so Dragovich can keep an eye on him
	level.steiner SetGoalNode( GetNode( "p2shiparrival_" + door + "_steiner", "targetname" ) );
	level.steiner.goalradius = 64;	
	
	wait( waitarray[waitCount] );
	waitCount++;
	
	// Dragovich brings up the rear of the VIPs		
	level.dragovich SetGoalNode( GetNode( "p2shiparrival_" + door + "_vertov", "targetname" ) );
	level.dragovich.goalradius = 64;

	
	// ... and now your other two squad guys who were in the front group
	if( isalive( level.shipsquad[2] ) )
	{
		wait( waitarray[waitCount] );
		waitCount++;
	
		level.shipsquad[2].noDodgeMove = true;		
		level.shipsquad[2].ignoresuppression = true;
		level.shipsquad[2] SetGoalNode( GetNode( "p2shiparrival_" + door + "_03", "targetname" ) );
		level.shipsquad[2].goalradius = 32;
	}
	
	if( isalive( level.shipsquad[3] ) )
	{
		wait( waitarray[waitCount] );
		waitCount++;
	
		level.shipsquad[3].noDodgeMove = true;		
		level.shipsquad[3].ignoresuppression = true;
		level.shipsquad[3] SetGoalNode( GetNode( "p2shiparrival_" + door + "_04", "targetname" ) );
		level.shipsquad[3].goalradius = 32;
	}	
	
	if( isdefined(do_blocker) && do_blocker == true )
	{
		level notify( "nextblocker" );
		level endon( "nextblocker" );

		blocker = getent( "p2shiparrival_" + door + "_blocker", "targetname" );
		trig = getent( blocker_trigger_targetname, "targetname" );

		level.dragovich waittill( "goal" );
		p = get_player();

		while(true)
		{
			if( p istouching(trig) )
			{
				blocker solid();
				return;
			}
			wait(0.05);
		}
	}
}

teleport_ship_squad( door )
{
	level.shipsquad[0] forceteleport_goal( GetNode( "p2shiparrival_" + door + "_01", "targetname" ).origin );
	if( isalive( level.shipsquad[1] ) )
		level.shipsquad[1] forceteleport_goal( GetNode( "p2shiparrival_" + door + "_02", "targetname" ).origin );
	if( isalive( level.shipsquad[2] ) )
		level.shipsquad[2] forceteleport_goal( GetNode( "p2shiparrival_" + door + "_03", "targetname" ).origin );
	if( isalive( level.shipsquad[3] ) )
		level.shipsquad[3] forceteleport_goal( GetNode( "p2shiparrival_" + door + "_04", "targetname" ).origin );
		
	level.steiner forceteleport_goal( GetNode( "p2shiparrival_" + door + "_steiner", "targetname" ).origin );
	level.dragovich forceteleport_goal( GetNode( "p2shiparrival_" + door + "_vertov", "targetname" ).origin );
	level.kravchenko forceteleport_goal( GetNode( "p2shiparrival_" + door + "_krav", "targetname" ).origin );
}

// point should be a vector
forceteleport_goal( point )
{
	self forceteleport( point );
	self setgoalpos( point );
}

// self should be the speaker
// blocks until dialogue complete
fa_speak( dialogue, delay )
{
	if( isDefined(delay) )
	{
		wait(delay);
	}

	while( isdefined(self.is_speaking) )
	{
		fa_print( "fa_speak preventing overtalking!" );
		wait(0.2);
	}

	displayname = self.targetname;
	if( isdefined(self.name) )
	{
		displayname = self.name;
	}
	else if( self == get_player() )
	{
		displayname = "Reznov";
	}

	duration = randomint(2) + 2;

	self.is_speaking = true;
	//print3d( self.origin + (0,0,64), dialogue, (1,1,1), 1, 0.5, duration*20 ); // duration here is in server frames
	//iprintlnbold( displayname + ": " + dialogue );



	fa_print( displayname + " is saying: " + dialogue );

	// varying amounts of wait, just to make sure the script that's using this doesn't lean on a fixed duration
	wait( duration );
	self notify( "fa_speak_finished" );
	self.is_speaking = undefined;
}

// returns when the player hits use while within the trigger
// self should be the trigger
trigger_use_button( prompt )
{
	message = &"FULLAHEAD_USEPROMPT";

	if( isdefined(prompt) )
		message = prompt;

	p = get_player();

	lastcheckstate = false;

	while( true )
	{
		if( p istouching(self) )
		{
			if( p use_button_held() )
			{
				hint_message_delete();
				return;
			}

			if( lastcheckstate == false )
			{
				lastcheckstate = true;
				hint_message_create( message );
			}
		}
		else
		{
			if( lastcheckstate == true )
			{
				lastcheckstate = false;
				hint_message_delete();
			}
		}

		wait( 0.1 );
	}
}

trigger_look_use_button( entlist, prompt )
{
	message = prompt;
	p = get_player();

	lastcheckstate = false;

	while( true )
	{
		start_pos = p geteye();
		end_dir = anglestoforward( p getplayerangles() );
		end_pos = start_pos + ( end_dir * 100.0 ); // trace forward by 100 units
		trace = bullettrace( start_pos, end_pos, false, undefined );

		//Line( start_pos, end_pos, (1,1,1), 1, false, 10 );

		if( isdefined(trace["entity"]) )
		{
			if( within_array( entlist, trace["entity"] ) )
			{
				if( p usebuttonpressed() )
				{
					hint_message_delete();
					return trace["entity"];
				}

				if( lastcheckstate == false )
				{
					lastcheckstate = true;
					hint_message_create( message );
				}
			}
			else
			{
				if( lastcheckstate == true )
				{
					lastcheckstate = false;
					hint_message_delete();
				}
			}
		}

		wait( 0.1 );
	}
}

within_array( array, entity )
{
	for( i=0; i<array.size; i++ )
	{
		if( array[i] == entity )
			return true;
	}

	return false;
}

hint_message_create( hint )
{
	get_player() SetScriptHintString( hint );
}

hint_message_delete()
{
	get_player() SetScriptHintString( "" );
}


// self should be whoever needs their run anim reset
reset_run_anim()
{
	self endon ("death");
	self.a.combatrunanim = undefined;
	self.run_noncombatanim = self.a.combatrunanim;
	self.walk_combatanim = self.a.combatrunanim;
	self.walk_noncombatanim = self.a.combatrunanim;
	self.preCombatRunEnabled = false;
}

skipto_activate_trigger_delay( trig_targetname, trig_delay )
{
	wait( trig_delay );
	trig = getent( trig_targetname, "targetname" );
	trig useby( self );
}

play_spark_fx( position, duration )
{
	linker = Spawn( "script_model", position );
	linker SetModel( "tag_origin" );
	playfxontag( level._effect["torch_sparks"], linker, "tag_origin" );
	wait( duration );
	linker delete();
}

ship_door_setup( doornum, model )
{
	fa_print( "ship_door_setup: " + doornum );
	
	door = getent( "ship_door" + doornum, "targetname" );
	if( isdefined(door) )
	{
		door delete(); // cleanup in case of redundancy
	}
	
	struct = getstruct( "shiparrival_hinge_closed_door" + doornum, "targetname" );
	door = spawn( "script_model", struct.origin );
	if( IsDefined( model ) )
	{
		//need animated door
		door setModel( model );
	}
	else
	{
		door setModel( "p_rus_shipdoor_pi" );
	}
	door.angles = struct.angles;
	door.targetname = "ship_door" + doornum;
	

	door.origin = struct.origin;
	door.angles = struct.angles;
}

ship_door_delete( doornum )
{
	door = getent( "ship_door" + doornum, "targetname" );
	if( isdefined(door) )
	{
		door delete();
	}
}

ship_door_open( doornum )
{
	fa_print( "ship_door_open: " + doornum );
	
	half = getstruct( "shiparrival_hinge_half_door" + doornum, "targetname" );
	open = getstruct( "shiparrival_hinge_open_door" + doornum, "targetname" );

	door = getent( "ship_door" + doornum, "targetname" );
	
	assert( isdefined(open) );

	if( isdefined(half) )
	{
		door rotateto( half.angles, 1, 0.5, 0 );
		door moveto( half.origin, 1, 0.5, 0 );

		wait( 1 );

		door rotateto( open.angles, 1, 0, 0.5 );
		door moveto( open.origin, 1, 0, 0.5 );
	}
	else
	{
		door rotateto( open.angles, 2, 0.5, 0.5 );
		door moveto( open.origin, 2, 0.5, 0.5 );
	}
}

ship_door_open_sudden( doornum )
{
	fa_print( "ship_door_open_sudden: " + doornum );
	
	half = getstruct( "shiparrival_hinge_half_door" + doornum, "targetname" );
	open = getstruct( "shiparrival_hinge_open_door" + doornum, "targetname" );

	door = getent( "ship_door" + doornum, "targetname" );
	
	assert( isdefined(open) );

	if( isdefined(half) )
	{
		door rotateto( half.angles, 0.1, 0, 0 );
		door moveto( half.origin, 0.1, 0, 0 );

		wait( 1 );

		door rotateto( open.angles, 0.1, 0, 0.05 );
		door moveto( open.origin, 0.1, 0, 0.05 );
	}
	else
	{
		door rotateto( open.angles, 0.2, 0, 0.05 );
		door moveto( open.origin, 0.2, 0, 0.05 );
	}
}

ship_door_close( doornum )
{
	fa_print( "ship_door_close: " + doornum );
	
	half = getstruct( "shiparrival_hinge_half_door" + doornum, "targetname" );
	closed = getstruct( "shiparrival_hinge_closed_door" + doornum, "targetname" );

	door = getent( "ship_door" + doornum, "targetname" );
	
	assert( isdefined(closed) );

	if( isdefined(half) )
	{
		door rotateto( half.angles, 1, 0.5, 0 );
		door moveto( half.origin, 1, 0.5, 0 );

		wait( 1 );

		door rotateto( closed.angles, 1, 0, 0.5 );
		door moveto( closed.origin, 1, 0, 0.5 );
	}
	else
	{
		door rotateto( closed.angles, 2, 0.5, 0.5 );
		door moveto( closed.origin, 2, 0.5, 0.5 );
	}
}

delete_ent_array( array )
{
	for( i=0; i<array.size; i++ )
	{
		array[i] delete();
	}
}

activate_triggers( field_value, field_name )
{
	trigs = getentarray( field_value, field_name );

	if( !isdefined(trigs) )
		return;

	for( i=0; i<trigs.size; i++ )
	{
		trigs[i] useby( get_players()[0] );
	}
}

disable_triggers_with_noteworthy( msg )
{
	triggers = getentarray( msg, "script_noteworthy" );
	for( i=0; i<triggers.size; i++ )
		triggers[i] trigger_off();
}

enable_triggers_with_noteworthy( msg )
{
	triggers = getentarray( msg, "script_noteworthy" );
	for( i=0; i<triggers.size; i++ )
		triggers[i] trigger_on();
}

disable_triggers_with_targetname( msg )
{
	triggers = getentarray( msg, "targetname" );
	for( i=0; i<triggers.size; i++ )
		triggers[i] trigger_off();
}

enable_triggers_with_targetname( msg )
{
	triggers = getentarray( msg, "targetname" );
	for( i=0; i<triggers.size; i++ )
		triggers[i] trigger_on();
}

// ~~~ Starts a visionset_change_thread on appropriate triggers ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
setup_visionset_triggers()
{
	trigs = getentarray( "visionset_change", "targetname" );
	for( i=0; i<trigs.size; i++ )
	{
		trigs[i] thread visionset_change_thread();
	}
}

// ~~~ Switch visionsets when you touch the trigger ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
visionset_change_thread()
{
	level endon( "kill_visionset_triggers" );
	assert( isdefined(self.script_noteworthy) );

	while( true )
	{
		self waittill( "trigger" );

		if( isdefined(level.last_visionset) && level.last_visionset == self.script_noteworthy )
		{

		}
		else
		{
			fa_print( "VISIONSET CHANGE: " + self.script_noteworthy );

			if( self.script_noteworthy == "bright" )
				fa_visionset_bright();
			else if ( self.script_noteworthy == "dark" )
				fa_visionset_dark();
			else if ( self.script_noteworthy == "nazibase" )
				fa_visionset_nazibase();
			else if ( self.script_noteworthy == "dogsled" )
				fa_visionset_dogsled();
			else if ( self.script_noteworthy == "shipstart" )
				fa_visionset_shipstart();

			level.last_visionset = self.script_noteworthy;
		}

		wait(0.05 );
	}
}

base_fog()
{
	maps\createart\fullahead_art::base_fog();
}

dogsled_fog()
{
	maps\createart\fullahead_art::dogsled_fog();
}

default_fog()
{
	maps\createart\fullahead_art::default_fog();
}

ghostship_fog()
{
	maps\createart\fullahead_art::ghostship_fog();
}

bridge_fog()
{
	maps\createart\fullahead_art::bridge_fog();
}



get_there(node)
{
	self ignore_everything();
	self SetGoalNode(node);
}

ignore_everything()
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
}

ai_naviage_thru_hallway()	// ai = self
{
	self.goalradius = 32;	
	self.noDodgeMove = true;	
	self.dontShootWhileMoving = true;	
}

wait_for_trigger_clear_of_ai( team, trigger_targetname)
{
	is_occupied = true;

	while( is_occupied )
	{
		enemy_ai = get_ai_touching_volume( team, trigger_targetname );
		if( enemy_ai.size <= 0 )
		{
			is_occupied = false;
		}
		else
		{
			if_occupied = false;
			for( i=0; i<enemy_ai.size; i++ )
			{
				if( isalive(enemy_ai[i]) )
				{
					is_occupied = true;
				}
			}
		}
		wait(1.5);
	}
}

clear_earlier_objectives( num )
{
	for( i = num-1; i>=0; i-- )
	{
		objective_delete( i );
	}
}

burning_death()
{
	self endon("death");

	PlayFxOnTag(level._effect["enemy_on_fire"], self, "tag_origin");
	self starttanning();

	if( isalive(self) ) // shouldn't need this due to the endon, but saw an SRE indicating otherwise...
	{
		self anim_generic(self, "flame_death_run_die" );
		self dodamage(self.health + 100, self.origin);
	}
}

burning_ragdoll( direction )
{

	PlayFxOnTag(level._effect["enemy_on_fire"], self, "tag_origin");
	self starttanning();
	self dodamage( self.health*2, self.origin );
	self startragdoll();
	self launchragdoll( direction, self.origin );
}

setgoalnode_tn( tn )
{
	node = getnode( tn, "targetname" );
	self setgoalnode( node );
}

fa_visionset_reznov()
{
	visionsetnaked( "fullahead_reznov", 2 );
	level.last_visionset = "reznov";
}

fa_visionset_shipstart()
{
	visionsetnaked( "fullahead_ship_out", 3 );
	level.last_visionset = "shipstart";
}

fa_visionset_bright()
{
	visionsetnaked( "fullahead_post_flashlight", 3 );
	level.last_visionset = "bright";
}

fa_visionset_dark()
{
	visionsetnaked( "fullahead_flashlight", 3 );
	level.last_visionset = "dark";
}

fa_visionset_nazibase()
{
	visionsetnaked( "fullahead_post_flashlight", 3 );
	level.last_visionset = "nazibase";
}

fa_visionset_dogsled()
{
	visionsetnaked( "fullahead_base", 3 );
	level.last_visionset = "dogsled";
}

// ~~~~~~~~ spawns the targetted spawner, and force him to rush the player ~~~~~~~~~~~~~~~~~~~~
banzai_thread() // self should be the trigger
{
	assert( isdefined(self.target) );

	self waittill( "trigger" );
	guy = simple_spawn_single( self.target );
	guy thread maps\_rusher::rush();
}

wait_till_dead( guytargetname )
{
	guy = getent( guytargetname, "targetname" );
	if( isdefined(guy) )
	{
		if( isalive(guy) )
		{
			guy waittill( "death" );
		}
	}
}

// ~~~~~~~~~ Freezes the player's controls after the specified delay ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
freeze_controls_delay( delay ) // self should be a player
{
	wait(delay);
	self freezecontrols(true);
}

// ~~~~~~~~~ Puts the camera in a glowy white room, with Reznov talking ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Do_reznov_cutscene( callback )
{
	camera_struct = getstruct( "whiteroom_camera_struct", "targetname" );
	camera_ent = spawn( "script_origin", camera_struct.origin );
	camera_ent setmodel("tag_origin");
	camera_ent.angles = camera_struct.angles;
	//wait(0.05);

	rez_struct = getstruct( "whiteroom_reznov_struct", "targetname" );

	if(!IsDefined(level.reznov_drone))
	{
		reznov = fa_drone_spawn( rez_struct, "reznovtalky" );
		level.reznov_drone = reznov;
	}
	else 
	{
		reznov = level.reznov_drone;
	}

	wait(0.05);
	
	assert( isdefined(camera_ent) );
	assert( isdefined(rez_struct) );
	
	flag_clear( "reznov_cutscene_startfade" );
	flag_clear( "reznov_cutscene_snow_to_fade" );
	flag_clear( "reznov_cutscene_done" );
	
	

	fa_visionset_reznov();

	p = get_player();
	p notify("stop_breath");
	//p camerasetposition( camera_ent.origin );
	////remove camera tracking when animated camera -jc
	//p thread reznov_cutscene_lookat_update( reznov ); // keeps the camera following Reznov's head movements
	//p cameraactivate( true );
	
	old_fov = GetDvarFloat( #"cg_fov" );
	p SetClientDvar( "cg_fov", 35 );
	
	p fa_show_hud( false );
	p disableweapons();
	
	//rez_struct.angles = (0,0,325); // needed for this particular bench_sit anim
	//rez_struct thread anim_loop_aligned( reznov, "bench_sit" );
	
	if(IsDefined(level._override_shader))
	{
		level thread fade_in( 1, level._override_shader, 0.5  );
	}
	else
	{
		level thread fade_in( 1, "white", 0.5  );
	}
	
	reznov thread [[ callback ]]( );
	p thread reznov_dof_setting();
	flag_wait( "reznov_cutscene_startfade" );
	
	p thread snowy_exit_vignette( p );
	flag_wait( "reznov_cutscene_snow_to_fade" );
	
	level thread fade_out( 1.8, "white", 0.66 );
	
	flag_wait( "reznov_cutscene_done" );
	level notify( "reznov_cutscene_stop_lookat_update" );
	
	//level.reznov delete();
	camera_ent delete();
	
	level._override_shader = undefined;
	
//	p cameraactivate( false );
	p SetClientDvar( "cg_fov", old_fov );
	
	p fa_show_hud( true );
//	p enableweapons();
	
	flag_clear( "reznov_cutscene_snow_to_fade" );
	p thread cold_breath("plyr");
}


reznov_dof_setting()
{
	//self setClientDvar( "r_dof_tweak", 1 );

	NearStart = 0;
	NearEnd = 1;
	FarStart = 11;
	FarEnd = 280;
	NearBlur = 4;
	FarBlur = 4.6;

	self SetDepthOfField( NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur);


	flag_wait( "reznov_cutscene_done" );

	//reset dof
	self maps\_art::setdefaultdepthoffield();
	//self setClientDvar( "r_dof_tweak", 0 );

}


// we're at the player's view when we enter the vignette - self is player
snowy_enter_vignette( is_snowcat_event )
{
	if(!IsDefined(level.current_hands_ent))
	{
		forward = AnglesToForward( self.angles );
		up = AnglesToUp( self.angles );
		fx_linker = Spawn( "script_model", self GetEye());
		fx_linker setmodel("tag_origin");
		fx_linker hide();
		fx_linker.angles = self.angles;
		fx_linker LinkTo( self );
	}
	else
	{
		forward = AnglesToForward( level.current_hands_ent GetTagAngles("tag_camera") );
		up = AnglesToUp( level.current_hands_ent GetTagAngles("tag_camera") );
		fx_linker = Spawn( "script_model", level.current_hands_ent GetTagOrigin("tag_camera"));
		fx_linker setmodel("tag_origin");
		fx_linker hide();
		fx_linker.angles = ( level.current_hands_ent GetTagAngles("tag_camera")  );
		fx_linker LinkTo( level.current_hands_ent );
	}
	
	//if(!IsDefined(is_snowcat_event))
	
	if (flag("P2WRAPUP_SHIP_EXPLODED"))  //for last event since fx_linker's angles get screwed up for some reason
	{
		playfx(level._effect["vignette_snow"], self GetEye(), forward);
	}
	else
	{
		PlayFXonTag( level._effect["vignette_snow"], fx_linker, "tag_origin" );
	}
	
	//else
	//	PlayFXonTag( level._effect["vignette_snow"], level.snowcat_petrenko, "tag_origin" );
		
	wait( 5 );
	if(IsDefined(level._override_shader))
	{
		hud_utility_show(level._override_shader);
	}
	else
	{
		hud_utility_show("white");
	}
	flag_set( "reznov_cutscene_snow_to_fade" );		
}

// we're in the magic white box 3rd person camers when we exit the vignette
snowy_exit_vignette( camera_ent )
{

	forward = AnglesToForward( level.current_hands_ent GetTagAngles("tag_camera") );
	up = AnglesToUp( level.current_hands_ent GetTagAngles("tag_camera") );

	fx_linker = Spawn( "script_model", level.current_hands_ent GetTagOrigin("tag_camera"));
	fx_linker setmodel("tag_origin");
	fx_linker hide();
	fx_linker.angles = ( level.current_hands_ent GetTagAngles("tag_camera")  );
	fx_linker LinkTo( level.current_hands_ent );

	PlayFXontag( level._effect["vignette_snow"],fx_linker, "tag_origin" );
	
	//PlayFX(level._effect["vignette_snow"], fx_linker.origin, forward, up);
	
	wait( 5 );
	hud_utility_show("white");
	flag_set( "reznov_cutscene_snow_to_fade" );		
	fx_linker delete();
}


// self should be a player
fa_show_hud( enabled )
{
	if( isdefined(enabled) && enabled == false )
	{ // disable all the hud elements
		self setclientdvar( "compass", "0" );
		self setclientdvar( "hud_showstance", "0" );
		self setclientdvar( "actionSlotsHide", "1" );
		self setclientdvar( "ammoCounterHide", "1" );
	}
	else
	{ // enable all the hud elements
		self setclientdvar( "compass", "1" );
		self setclientdvar( "hud_showstance", "1" );
		self setclientdvar( "actionSlotsHide", "0" );
		self setclientdvar( "ammoCounterHide", "0" );
	}
}

// self is the player
reznov_cutscene_lookat_update( reznov )
{
	level endon( "reznov_cutscene_stop_lookat_update" );
	time = 0;
	while( true )
	{
		rez_eye_org = reznov gettagorigin( "tag_eye" );
		self camerasetlookat( rez_eye_org + (-8,0,-2) );
		wait(0.05);
		time += 0.05;
		if(time >= 6.5)
			break;

	}
}

#using_animtree ("generic_human");
drone_script_noteworthy_check( sn_name )
{
	if( !isDefined( sn_name ) )
	{
		return;	
	}	
	
	customFirstAnim = undefined;
	switch( sn_name )
	{
		case "railclimb":
			customFirstAnim = %ch_full_b07_climb_bridge_guy01;
			break;
	}
	
	return customFirstAnim;
}

fakerpg( start_struct_name, target_struct_name )
{
	point = getstruct( start_struct_name, "targetname" );
	targ = getstruct( target_struct_name, "targetname" );
	
	assert( isdefined(point) );
	assert( isdefined(targ) );

	magicbullet( "rpg_sp", point.origin, targ.origin );
}

fakefire_thread( start_struct_name, target_struct_name, endon_name )
{
	level endon( endon_name );
		
	point = getstruct( start_struct_name, "targetname" );
	targ = getstruct( target_struct_name, "targetname" );
	
	assert( isdefined(point) );
	assert( isdefined(targ) );
	
	while( true )
	{
		x = randomfloatrange( -64, 32 );
		y = randomfloatrange( -32, 64 );
		z = randomfloatrange( -16, 32 );
		magicbullet( "mp40_sp", point.origin, targ.origin + (x,y,z) );
		wait(0.1);
	}
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// Sets up player containment triggers -- deserters will be shot!
// Shut these down by notifying the level trig_targetname + _end
containment_trigger_startup( trig_targetname )
{
	fa_print( "Enabling containment triggers: " + trig_targetname );
	
	trigs = getentarray( trig_targetname, "targetname" );
	array_thread( trigs, ::containment_trigger_thread, trig_targetname+"_end" );	
}

containment_trigger_shutdown( trig_targetname )
{
	fa_print( "Disabling containment triggers: " + trig_targetname );
	
	level notify( trig_targetname+"_end" );
	
	trigs = getentarray( trig_targetname, "targetname" );
	for( i=0; i<trigs.size; i++ )
	{
		trigs[i] delete();
	}
	
}

// self == a trigger
containment_trigger_thread( end_notify )
{
	level endon( end_notify );

	// if this is an inner trigger, print the warning if the player's touching it
	if( self.script_noteworthy == "inner" )
	{
		lastcheckstate = false;

		while( true )
		{
			if( get_player() istouching(self) )
			{
				if( lastcheckstate == false )
				{
					lastcheckstate = true;
					screen_message_create( &"FULLAHEAD_CONTAINMENT_WARNING" );
				}
			}
			else
			{
				if( lastcheckstate == true )
				{
					lastcheckstate = false;
					screen_message_delete();
				}
			}
	
			wait( 0.33 );
		}
	}
	
	// if this is an outer trigger, prepare to kill the player
	else if( self.script_noteworthy == "outer" )
	{
		self waittill( "trigger" );
		
		screen_message_delete(); // get rid of it, if it exists
		
		p = get_player();
		//SetDvar( "ui_deadquote", &"FULLAHEAD_CONTAINMENT_DESERTER" );
		missionFailedWrapper( &"FULLAHEAD_CONTAINMENT_MISSIONAREA" );
		
		return;
	}
}


activate_upon_notify( level_msg )
{
	self endon( "death" );
	
	self set_ignoreall(true);
	self disable_long_death();
	
	level waittill( level_msg );
	self set_ignoreall(false);	
}

send_to_retreat_node( spawner_name, name_field, node_name)
{
	// should be last guy
	guys = GetEntArray( spawner_name, name_field );
	
	for(i=0; i<guys.size; i++)
	{
		if(guys[i].health > 0)
		{
			guys[i] thread retreat( node_name );
		}
	}
}

retreat( node_name )	// self = ai retreating
{
//	self thread magic_bullet_shield();	
	node = GetNode( node_name, "targetname");
	assert(isdefined(node));
		
	self thread force_goal( node, 128);
	self waittill("goal");
//	self stop_magic_bullet_shield();
}

walk_mode()
{
	self set_run_anim( "ship_point_walk" );
	self.disableArrivals = true;
	self.disableExits = true;
	self.disableTurns = true;	
}

run_mode()
{
	self.disableArrivals = false;
	self.disableExits = false;
	self.disableTurns = false;				
	self reset_run_anim();	
}

run_mode_special()
{
	self.disableArrivals = false;
	self.disableExits = false;
	self.disableTurns = false;				
	//self reset_run_anim();	
}

// self should be an ai
headtracking_start( lookat_ent )
{
	self relax_ik_headtracking_limits();
	self LookAtEntity(lookat_ent);	
}

// self should be an ai
headtracking_stop()
{
	self restore_ik_headtracking_limits();
	self LookAtEntity(); // nothing in particular
}

// self should be an ai
spawnfunc_ikpriority()
{
  	self.ikpriority = 5;
}

cold_breath(type)
{
	self endon("death");
	self endon("stop_breath");

	while(1)
	{
		if (type =="guy")
		{
			playfxontag( level._effect["cold_breath"], self, "tag_eye" );
		}
		if (type =="plyr")
		{
			forward = AnglesToForward( self.angles );
			up = AnglesToUp( self.angles );
			PlayFX( level._effect["cold_breath_player"], self GetEye() + ( 0, 0, -10 ), forward, up );
			// playfxontag( level._effect["cold_breath_player"], self, "J_Jaw" );
		}
		wait(RandomFloatRange(2.0,4.0));
	}
}

hud_utility_show( shader, fadeSeconds )
{
	//If the hud utility does not yet exist...
	if( !isDefined( level.hud_utility ) )
	{
		//Create one now.
		hud_utility_init();
	}

	//If a shader was given, switch to it.
	if( IsDefined( shader ) )
	{
		level.hud_utility SetShader( shader, 640, 480 );
	}

	//If no seconds were specified or are not positive...
	if( !isDefined( fadeSeconds ) || fadeSeconds <= 0 )
	{
		level.hud_utility.alpha = 1;
	}
	else
	{
		//Fade into the color over the specified amount of time.
		level.hud_utility FadeOverTime( fadeSeconds );
		level.hud_utility.alpha = 1;
		wait( fadeSeconds );
	}

	//All done! Notify whoever called this.
	self notify( "fade_complete" );
}

hud_utility_hide( shader, fadeSeconds )
{
	//If the hud utility does not yet exist...
	if( !isDefined( level.hud_utility ) )
	{
		//Create one now.
		hud_utility_init();
	}

	//If a shader was given, switch to it.
	if( isDefined( fadeSeconds ) )
	{
		level.hud_utility setShader( shader, 640, 480 );
	}

	//If no seconds were specified or are not positive...
	if( !isDefined( fadeSeconds ) || fadeSeconds <= 0 )
	{
		level.hud_utility.alpha = 0;
	}
	else
	{
		//Fade into the color over the specified amount of time.
		level.hud_utility fadeOverTime( fadeSeconds );
		level.hud_utility.alpha = 0;
		wait( fadeSeconds );
	}

	//All done! Notify whoever called this.
	self notify( "fade_complete" );
}
hud_utility_init()
{
	//Create a fullscreen element that we can use for fades and flashbacks.
	level.hud_utility 					 = NewHudElem();
	level.hud_utility.x 				 = 0;
	level.hud_utility.y 			   = 0;
	level.hud_utility.horzAlign  = "fullscreen";
	level.hud_utility.vertAlign  = "fullscreen";
	level.hud_utility.foreground = false; //Arcade Mode compatible
	level.hud_utility.sort			 = 3;
	//NOTE: billboard uses layers 0, 1, and 2!

	//Set the default shader.
	level.hud_utility setShader( "black", 640, 480 );

	//Hide the element until needed.
	level.hud_utility.alpha = 0;
}

player_wait_on_mortar_death()
{

	self waittill("death", attacker);
	if(self.health < 0 && attacker.origin == (0, 0, 0))
	{
		SetDvar( "ui_deadquote", &"FULLAHEAD_CONTAINMENT_DESERTER" );
	}
}

show_friendly_names( on )
{
	player = self;
	
	if(!IsPlayer(player))
	{
		player = get_players()[0];
	}
	
	player SetClientDvar("cg_drawFriendlyNames", on);
}
