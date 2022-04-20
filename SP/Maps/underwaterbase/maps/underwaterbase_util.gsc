/*
//-- Level: Underwater Base
//-- Level Designer: Gavin Goslin
//-- Scripter: Alfeche/Vento
*/
#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\_anim;


//	Util flags
init_util_flags()
{
	flag_init( "dof_transition" );	
}


// ~~~ Wrapper for the print function, so it can be disabled easily if needed ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ub_print( print_message )
{
	println( " UNDERWATERBASE> " + print_message );
}

//******************************************************************************
//******************************************************************************

// ~~~ Stolen from somewhere... does a fullscreen fade ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

//******************************************************************************
//******************************************************************************

// ~~~ Stolen from somewhere... does a fullscreen fade ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fade_in( time, shadername_arg, delay_time )
{
	if( isdefined(delay_time) )
	{
		wait( delay_time );
	}
	
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

	level.fade_out_overlay.alpha = 1;
	level.fade_out_overlay fadeOverTime( time );
	level.fade_out_overlay.alpha = 0;
	wait( time );
	level notify( "fade_in_complete" );
}

//******************************************************************************
//******************************************************************************

get_player()
{
	return get_players()[0];
}

//******************************************************************************
//******************************************************************************

player_to_struct( struct_targetname )
{
	newpos = getstruct( struct_targetname, "targetname" );
	p = get_player();
	p setorigin( newpos.origin );

	angles = (0,0,0);
	if ( IsDefined( newpos.angles ) )
	{
		angles = newpos.angles;
	}
	p setplayerangles( angles );
}


//******************************************************************************
//******************************************************************************
ent_origin( ent_name )
{
	return GetEnt(ent_name, "targetname") GetOrigin();
}

struct_origin( struct_name )
{
	return GetStruct( struct_name, "targetname" ).origin ;	
}


//******************************************************************************
//******************************************************************************

setup_gib()	// self = spawner
{
	// set up gib
	self.force_gib = true; 
	self.custom_gib_refs = [];
	self.custom_gib_refs[0] = "right_arm";
	self.custom_gib_refs[1] = "left_arm";
	self.custom_gib_refs[2] = "no_legs";	
}

//******************************************************************************
//******************************************************************************
// attack_friendly_spawners()
// {
// 	self endon("death");
// 	
// 	self setup_gib();
// 	self SetThreatBiasGroup("bad_guys");
// 	self thread player_damage_only();
// 	self.health = 1000;
// 	self.goalradius = 5;
// 	self.ignoreall = 1;
// 	self.ignoreme = 1;
// 	self disable_ai_color();
// 	self disable_react();
// 	self disable_pain();	// turn off so we can use balcony deaths
// 	self.ignoresuppression = true;
// 	self.suppressionthreshold = 1; 
// 	self.noDodgeMove = true; 
// 	self.dontShootWhileMoving = true;
// 	self.grenadeawareness = 0;
// 	self.pathenemylookahead = 0;
// 	self.meleeAttackDist = 0;	
// 	self.pacifist = true;
// 	self waittill("goal");
// 
// 	self enable_rambo();
// 	self.pacifist = false;
// 	self.ignoreme = false;
// 	self.ignoreall = false;
// 	self AllowedStances( "stand" );
// }
// 
// last_man_standing_group_one_watcher( spn_mgr_name )
// {
// 	level endon("attack_sequence_finished");
// 	
// 	spawn_manager_enable( spn_mgr_name );
// 	waittill_spawn_manager_complete( spn_mgr_name );
// 	
// 	while(1)
// 	{
// 		if(level.last_man_standing_group_one_count <= 1)
// 		{
// 			break;	
// 		}
// 		
// 		wait(0.05);
// 	}
// 	
// 	level notify("group_one_death_rattle");
// }
// 
// // gets called on the spawner
// last_man_standing_group_one()
// {	
// 	self thread group_one_death_rattle();	// kills last man standing
// 	self thread group_one_ai_death();		// decrements count when dies
// 	
// 	self setup_gib();
// 	self SetThreatBiasGroup("bad_guys");
// 	self thread player_damage_only();
// 	self.health = 1000;
// 	self.goalradius = 5;
// 	self.ignoreall = 1;
// 	self.ignoreme = 1;
// 	self disable_ai_color();
// 	self disable_react();
// 	//self disable_pain();	// turn off so we can use balcony deaths
// 	self.ignoresuppression = true;
// 	self.suppressionthreshold = 1; 
// 	self.noDodgeMove = true; 
// 	self.dontShootWhileMoving = true;
// 	self.grenadeawareness = 0;
// 	self.pathenemylookahead = 0;
// 	self.meleeAttackDist = 0;	
// 	self.pacifist = true;
// 	self waittill("goal");
// 
// 	if(IsAlive(self))
// 	{
// 		self enable_rambo();
// 		self.pacifist = false;
// 		self.ignoreme = false;
// 		self.ignoreall = false;
// 		self AllowedStances( "stand" );
// 	}
// }
// 
// group_one_ai_death()
// {
// 	self waittill("death");
// 	level.last_man_standing_group_one_count--;
// }
// 
// // this will kill off last man standing in group one
// group_one_death_rattle()	// self = ai in group one
// {
// 	level endon("attack_sequence_finished");
// 
// 	level waittill("group_one_death_rattle");
// 	
// 	// make sure currently not already removed
// 	if(isDefined(self))
// 	{	
// 		self DoDamage(self.health*2, self.origin);
// 	}
// }
// 
// last_man_standing_group_two_watcher( spn_mgr_name )
// {
// 	level endon("attack_sequence_finished");
// 	
// 	spawn_manager_enable( spn_mgr_name );
// 	waittill_spawn_manager_complete( spn_mgr_name );
// 	
// 	while(1)
// 	{
// 		if(level.last_man_standing_group_two_count <= 1)
// 		{
// 			break;	
// 		}
// 		
// 		wait(0.05);
// 	}
// 	
// 	level notify("group_two_death_rattle");
// }
// 
// // this will kill off last man standing in group two
// group_two_death_rattle()	// self = ai in group two
// {
// 	level endon("attack_sequence_finished");
// 
// 	level waittill("group_two_death_rattle");
// 	
// 	// make sure currently not already removed
// 	if(isDefined(self))
// 	{
// 		self DoDamage(self.health*2, self.origin);
// 	}
// }
// 
// last_man_standing_group_two()
// {	
// 	self thread group_two_death_rattle();
// 	self thread group_two_ai_death();
// 	
// 	self setup_gib();
// 	self SetThreatBiasGroup("bad_guys");
// 	self thread player_damage_only();
// 	self.health = 1000;
// 	self.goalradius = 5;
// 	self.ignoreall = 1;
// 	self.ignoreme = 1;
// 	self disable_ai_color();
// 	self disable_react();
// 	//self disable_pain();	// turn off so we can use balcony deaths
// 	self.ignoresuppression = true;
// 	self.suppressionthreshold = 1; 
// 	self.noDodgeMove = true; 
// 	self.dontShootWhileMoving = true;
// 	self.grenadeawareness = 0;
// 	self.pathenemylookahead = 0;
// 	self.meleeAttackDist = 0;	
// 	self.pacifist = true;
// 	self waittill("goal");
// 
// 	if(IsAlive(self))
// 	{
// 		self enable_rambo();
// 		self.pacifist = false;
// 		self.ignoreme = false;
// 		self.ignoreall = false;
// 		self AllowedStances( "stand" );
// 	}
// }
// 
// group_two_ai_death()
// {
// 	self waittill("death");
// 	level.last_man_standing_group_two_count--;
// }
// 
// get_spawnmanager_spawn_count( spn_mgr_name )
// {
// 	for(i=0; i<level.spawn_managers.size; i++)
// 	{
// 		if(level.spawn_managers[i].sm_id == spn_mgr_name)
// 		{
// 			return Int(level.spawn_managers[i].sm_count);
// 		}	
// 	}
// 
// 	ASSERTEX( 0, "Spawn Manager is not found: " + spn_mgr_name );
// 	return 0;
// }
// 


//******************************************************************************
//******************************************************************************
// attack_player_spawners()
// {
// 	self endon("death");
// 	
// 	self setup_gib();
// 	self SetThreatBiasGroup("player_hater");
// 	self.a.allow_weapon_switch = false;	
// 	self.goalradius = 5;
// 	self.ignoreall = 1;
// 	self.ignoreme = 1;
// 	self disable_ai_color();
// 	self disable_react();
// 	self disable_pain();
// 	self.ignoresuppression = true;
// 	self.suppressionthreshold = 1; 
// 	self.noDodgeMove = true; 
// 	self.dontShootWhileMoving = true;
// 	self.grenadeawareness = 0;
// 	self.pathenemylookahead = 0;
// 	self.meleeAttackDist = 0;	
// 	self.pacifist = true;
// 	self waittill("goal");
// 
// 	self.pacifist = false;
// 	self.ignoreme = false;
// 	self.ignoreall = false;
// 	self AllowedStances( "stand" );
// }


//******************************************************************************
//******************************************************************************
// 
// player_damage_only()	// self = spawned AI
// {
// 	self endon("death");
// 	player = get_players()[0];
// 	player endon("death");
// 	player endon("disconnect");
// 	
// 	while(1)
// 	{
// 		self waittill("damage", damagetaken, attacker);
// 		if(attacker != player)
// 		{			
// 			self.health += damagetaken;
// 		}
// 	}	
// }
// 
//******************************************************************************
//******************************************************************************
// 
// take_player_damage_only( damage_trigger_name )
// {
// 	level endon(damage_trigger_name + "_stop");
// 	level.weaver_assistance_fail_time = 20;	// seconds
// 	
// 	player = get_players()[0];
// 	player endon("death");
// 	player endon("disconnect");
// 	
// 	dmg_trigger = GetEnt(damage_trigger_name,"targetname");
// 	ASSERTEX( IsDefined( dmg_trigger ), "Damage trigger is not defined: " + damage_trigger_name );
// 	
// 	if(!isDefined(level.weaver_assistance_start_time))
// 	{
// 		level.weaver_assistance_start_time = 0;
// 	}
// 	
// 	dmg_trigger thread weaver_needs_help_timer();
// 	while(1)
// 	{
// 		dmg_trigger waittill("damage", damagetaken, attacker);
// 		if(attacker == player)
// 		{			
// 			level.weaver_assistance_start_time = 0;
// 		}
// 	}
// }
// 
// 
// //******************************************************************************
// //******************************************************************************
// 
// friendly_movement_reset( friendly_squad_array )
// {
// 	for(i=0; i<friendly_squad_array.size; i++)
// 	{	
// 		friendly_squad_array[i] ent_flag_clear("reached_goal_friendly");
// 	}
// }
// 
// //******************************************************************************
// //******************************************************************************
// 
// friendly_movement_wait( friendly_squad_array )	// self = level
// {
// 	for(i=0; i<friendly_squad_array.size; i++)
// 	{	
// 		friendly_squad_array[i] ent_flag_wait("reached_goal_friendly");
// 	}	
// }
// 
// //******************************************************************************
// //******************************************************************************
// 
// friendly_movememnt_advance( friendly_squad_array, node_targetname )
// {
// 	// clear flags for next friendly movement
// 	friendly_movement_reset( friendly_squad_array );
// 	
// 	dest_nodes = GetNodeArray(node_targetname, "targetname");
// 	ASSERTEX( dest_nodes.size > 0, "Couldn't find pathnodes for friendlies to go to:  " + node_targetname);
// 	ASSERTEX( dest_nodes.size >= friendly_squad_array.size , "Not enough nodes for friendlies to go to:  " + node_targetname);
// 	
// 	for(i=0; i<friendly_squad_array.size; i++)
// 	{	
// 		friendly_squad_array[i] thread friendly_movememnt_advance_logic(dest_nodes[i]); 
// 	}	
// }
// 
// //******************************************************************************
// //******************************************************************************
// 
// friendly_movememnt_advance_logic( dest_node )	// self = friendly ai
// {
// 	self SetGoalNode(dest_node);
// 	self.goalradius = 256;		
// 	self.ignoreall = 1;
// 	self.ignoreme = 0;
// 	self disable_ai_color();
// 	self disable_react();
// 	self disable_pain();
// 	self.ignoresuppression = true;
// 	self.suppressionthreshold = 1; 
// 	self.noDodgeMove = true; 
// 	self.dontShootWhileMoving = true;
// 	self.grenadeawareness = 0;
// 	self.pathenemylookahead = 0;
// 	self.meleeAttackDist = 0;	
// 	self.pacifist = true;
// 	self waittill("goal");
// 
// 	self enable_pain();
// 	self.pacifist = false;
// 	self.ignoreme = false;
// 	self.ignoreall = false;	
// 	self ent_flag_set("reached_goal_friendly");
// //	iprintlnbold("Friendly reached goal");
// }
// 
// setup_friendly_teams()
// {	
// 	for(i = 0; i < level.weaver_team_members; i++)
// 	{
// 		squad_ai = simple_spawn_single("friendly_ai");
// 		
// 		if(isDefined(squad_ai))
// 		{
// 			if(i==0)
// 			{
// 				level.weaver = squad_ai;
// 			}
// 			
// 			squad_ai.goalradius = 32;
// 			squad_ai.NoFriendlyfire = true;
// 			squad_ai thread make_hero();
// 			squad_ai SetThreatBiasGroup("good_guys");
// 			squad_ai ent_flag_init("reached_goal_friendly");
// 			level.weaver_team = add_to_array( level.weaver_team, squad_ai );
// 		}
// 	}
// 	
// 	for(i = 0; i < level.redshirt_team_members; i++)
// 	{
// 		squad_ai = simple_spawn_single("friendly_ai");
// 		
// 		if(isDefined(squad_ai))
// 		{			
// 			if(i==0)
// 			{
// 				level.redshirt_leader = squad_ai;
// 			}
// 			
// 			squad_ai.goalradius = 32;
// 			squad_ai.NoFriendlyfire = true;
// 			squad_ai thread make_hero();
// 			squad_ai SetThreatBiasGroup("good_guys");
// 			squad_ai ent_flag_init("reached_goal_friendly");
// 			level.redshirt_team = add_to_array( level.redshirt_team, squad_ai );
// 		}
// 	}	
// }
// 
// //******************************************************************************
// //******************************************************************************
// 
// spawn_a_model(model, myorigin, myangles)
// {
// 	spot = spawn ("script_model", myorigin);
// 	if (isdefined(myangles))
// 	{
// 		spot.angles = myangles;
// 	}
// 	spot setmodel(model);
// 	return spot;
// }
// 
// //******************************************************************************
// //******************************************************************************
// 
// area_explosion( dist, team )
// {
// 	player = get_players()[0];	
// 	
// 	// grab nearby guys
// 	explosion_distance = dist;
// 	nearby_ai = undefined;
// 	ai = getAIArray( team );
// 	
// 	if(level.toggle_drones)
// 	{	
// 		ai = maps\underwaterbase_huey::heli_attack_drone_targets( ai, "axis" );	// including drones to explosion
// 		ai = maps\underwaterbase_huey::heli_attack_drone_targets( ai, "allies" );	// including drones to explosion
// 	}
// 		
// 	for( i=0; i<ai.size; i++ )
// 	{
// 		if(isDefined(ai[i]))
// 		{
// 			dist = distance( self.origin, ai[i].origin);
// 			if( dist < explosion_distance )
// 			{
// 				// kill them and toss them toward the player
// 				ai[i] StartRagDoll();
// 				
// 				toward_player = Vector_Multiply( VectorNormalize( player.origin - ai[i].origin ), 100);
// 				toward_player = toward_player + ( RandomIntRange(-50, 50), RandomIntRange(-50, 50), 250);
// 				ai[i] DoDamage(ai[i].health*2, ai[i].origin);
// 				wait(.05);
// 				
// 				ai[i] LaunchRagDoll( toward_player, ai[i].origin );
// 				
// 			}
// 		}
// 	}
// 	
// }
// 
//******************************************************************************
//******************************************************************************

turn_off_containment_clips()
{
	self connectpaths();
	self Delete();	
}

//******************************************************************************
//******************************************************************************

turn_on_containment_clips()
{
	self Solid();
	self disconnectpaths();	
	self NotSolid();	// so ai can still attack
}


//******************************************************************************
//******************************************************************************

spawn_fake_rpg( start_org , dest_org, travel_time)
{
	fake_rpg = spawn ("script_model", start_org);
	fake_rpg setmodel("tag_origin");

	PlayFXOnTag(level._effect["rpg_trail"], fake_rpg, "tag_origin");
	fake_rpg moveto ( dest_org, travel_time);	
	wait(travel_time);
	
	fake_rpg Delete();	
}


// //******************************************************************************
// //******************************************************************************
// 
// play_all_deck_effects_snipe_skipto()
// {
// 	// play all of the effects
// 
// 	// play Huey A related exploder effects - first Huey to explode over cargo doors
//  	exploder(10);	// Huey A deck debris
// 
// 	// play Huey B related exploder effects - second Huey to explode and crash into crane
// 	exploder(20); // Huey B model
// 	exploder(30); // Huey B deck debris
// 	
// 	// play Huey C related exploder effects - crashes into helipad
//  	exploder(40);	// Huey C model
//  	exploder(50);	// Huey C deck debris
//  	
//  	// aa gun debris effects
//  	exploder(70); // aa gun 1 debris
//  	exploder(80); // aa gun 2 debris	
// }


// 
// //******************************************************************************
// //******************************************************************************
// 
// white_flash()
// {	
// 	fadetowhite = newhudelem();
// 
// 	fadetowhite.x = 0; 
// 	fadetowhite.y = 0; 
// 	fadetowhite.alpha = 0; 
// 
// 	fadetowhite.horzAlign = "fullscreen"; 
// 	fadetowhite.vertAlign = "fullscreen"; 
// 	fadetowhite.foreground = true; 
// 	fadetowhite SetShader( "white", 640, 480 ); 
// 
// 	// Fade into white
// 	fadetowhite FadeOverTime( 0.1 ); 
// 	fadetowhite.alpha = 0.8; 
// 
// 	wait 0.2;
// 	fadetowhite FadeOverTime( 1.0 ); 
// 	fadetowhite.alpha = 0; 
// 
// 	wait 1.1;
// 	fadetowhite destroy();
// }
// 
// 
// //******************************************************************************
// //******************************************************************************
// 
// reached_goal()
// {
// //	self endon("death");
// //	self waittill("goal");
// 	self.takedamage = true;	
// 	self.pacifist = false;
// 	
// 	// put this guy on the blue team -- unless he's Hudson
// 	if(( self.name != "Hudson" ) && isalive(self))
// 	{
// 		self set_force_color( "b" );
// 	}
// }
// 


//******************************************************************************
//******************************************************************************
create_hud_elem( client, xpos, ypos, shader, alpha, width, height, alignX, alignY, horizAlign, vertAlign )
{
	if( IsDefined( client ) )
	{
		hud = NewClientHudElem( client ); 
	}
	else
	{
		hud = NewHudElem(); 
	}

	hud.x = xpos;
	hud.y = ypos;

//	hud.sort = 1;
	hud.hidewheninmenu = true;

	if (!IsDefined(alignX))
	{
		alignX = "center";
	}

	if (!IsDefined(alignY))
	{
		alignY = "middle";
	}

	if (!IsDefined(horizAlign))
	{
		horizAlign = "center";
	}

	if (!IsDefined(vertAlign))
	{
		vertAlign = "middle";
	}


	hud.alignX = alignX;
	hud.alignY = alignY;
	hud.horzAlign = horizAlign;
	hud.vertAlign = vertAlign;
	hud.foreground = true;

	if( isdefined(alpha) )
	{
		hud.alpha = alpha;
	}
	
	hud.color = ( 1.0, 1.0, 1.0 );
	
	if( isdefined(shader) )
	{
		hud setshader( shader, width, height );
	}
		
	return hud; 
}


//******************************************************************************
//******************************************************************************
create_hud_bar( xpos, ypos, width, height, shader )
{
	barElem = newClientHudElem(	self );
	barElem.x = xpos;
	barElem.y = ypos;
	barElem.width = width;
	barElem.height = height;
	barElem.frac = 0;
	barElem.color = ( 1.0, 1.0, 1.0 );
	barElem.sort = -2;
	
	barElem.alignX = "left";
	barElem.alignY = "middle";
	barElem.horzAlign = "center";
	barElem.vertAlign = "middle";
	
	barElem.shader = shader;
	barElem setShader( shader, width, height );
	//barElem.hidden = false;

//	if ( isDefined( flashFrac ) )
//	{
//		barElem.flashFrac = flashFrac;
//	}
	
	return( barElem );
}


//******************************************************************************
//******************************************************************************
destroy_hud_elem()
{
	self Destroy(); 
}


/*------------------------------------------------------------------------------------------------------------
	Ragdoll Explosion
------------------------------------------------------------------------------------------------------------*/
guy_explosion_launch(org, force)
{
	if(!IsDefined(self._launched))
	{
		self StopAnimScripted();
		self.force_gib = true;
		self._launched = true;
		self DoDamage( self.health * 100, org, self, undefined, "explosive" );
		self StartRagdoll( 1 );
		self LaunchRagdoll( force );
	}
}

explosion_launch_monitor()
{
	while(1)
	{
		level._num_launches = 0;
		wait(0.3);
	}
}

explosion_launch(org, radius, min_force, max_force, min_launch_angle, max_launch_angle)
{
	
	if(!IsDefined(level._explosion_launch_choke))
	{
		level thread explosion_launch_monitor();
		level._explosition_launch_choke = true;
	}
	
	if(level._num_launches < 6)
	{
		PhysicsExplosionSphere(org, radius, radius / 2, 1 );
		level._num_launches ++;
	}

	allies = []; //GetAIArray("allies");
	axis = GetAIArray("axis");

	ai_array = array_merge(allies, axis);

	radiusSquared = radius * radius;
	for (i = 0; i < ai_array.size; i++)
	{
		is_hero = IsDefined(ai_array[i].script_hero) && (ai_array[i].script_hero == 1);

		if (IsDefined(ai_array[i]) && !IsGodMode(ai_array[i]) && !is_hero && !IsDefined(ai_array[i]._launched))
		{
			distSquared = Distance2DSquared(org, ai_array[i].origin);
			if (distSquared < radiusSquared)
			{
				dir = ai_array[i].origin - org;
				dir = (dir[0], dir[1], 0);
				dir = VectorNormalize(dir);
				launch_angles = VectorToAngles(dir);

				launch_pitch = linear_map(distSquared, 0, radiusSquared, min_launch_angle, max_launch_angle);
				launch_pitch = launch_pitch * -1;
				launch_angles = (launch_pitch, launch_angles[1], launch_angles[2]);

				dir = AnglesToForward(launch_angles);

				force_mag = linear_map(distSquared, 0, radiusSquared, min_force, max_force);
				force = dir * force_mag;
				
				ai_array[i] guy_explosion_launch(org, force);
			}
		}
	}
}

/***************************************************************/
//	spawn_character
//
//	spawns a script model and assigns it the models of a character
/***************************************************************/
#using_animtree("generic_human");
spawn_character(character_type, origin, angles, anim_name)
{
	Assert(IsDefined(level.character[character_type]), "No entry for character type: " + character_type + " defined in character array.");

	model = spawn("script_model", origin);

	if (IsDefined(angles))
	{
		model.angles = angles;
	}

	model [[level.character[character_type]]]();

	if (IsDefined(anim_name))
	{
		model.animname = anim_name;
	}

	model UseAnimTree(#animtree);

	return model;
}

init_friendly_heli( start_path_name )	// self = heli
{
	self.health = 10;
	self AddVehicleToCompass("helicopter");
	self.takedamage = false;
//	self.lockheliheight = true;
//	self.drivepath = true;
	self.dontunloadonend = true;

	start_node = GetVehicleNode( start_path_name, "targetname" );
	AssertEx( IsDefined(start_node), "Unknown start node for huey pathing: " + start_path_name);
	self thread go_path(start_node);

//	self waittill("reached_end_node");
//	self.drivepath = true;
}


heli_engage(target, engage_dist, min_height, min_height_delta, max_height_delta, min_recalc_pos_time, max_recalc_pos_time, end_notify, num_guns)
{
	self endon("death");
	self endon(end_notify);
	target endon("death");

	self SetSpeed(70, 35, 35);
	
	double_dist = engage_dist*2;
	double_distsq = double_dist*double_dist;

	curr_angle = target.angles[1]; 
	self.firing = false;

	while( true )
	{
		angle_offset = RandomFloatRange(45, 60);
		if (RandomIntRange(0, 100) < 50)
		{
			angle_offset = angle_offset * -1;
		}

		curr_angle = target.angles[1];
		curr_angle = AbsAngleClamp360(curr_angle + angle_offset);

		forward = VectorNormalize( AnglesToForward( (0, curr_angle, 0) ) ) * engage_dist;
		target_point = target.origin + forward;
		target_point = ( target_point[0], target_point[1], target_point[2] );

		height_delta = RandomFloatRange(min_height_delta, max_height_delta);
		target_point_z = (target_point[2] + min_height) + height_delta;
		target_point = (target_point[0], target_point[1], target_point_z);
	
		self SetVehGoalPos( target_point, true );	
		self SetLookAtEnt( target );
		
//		self thread heli_engage_debug(target, target_point, end_notify);
		self waittill("goal");
		self thread heli_fire_burst(target, 1.5, 2.0, num_guns);

		if (self.vehicletype == "heli_huey_side_minigun" || self.vehicletype == "heli_huey_side_minigun_uwb")
		{
			self thread heli_fire_rockets(target, 4);
		}

		wait( RandomFloatRange( min_recalc_pos_time, max_recalc_pos_time ) );
	}
}

heli_engage_debug(target, target_point, end_notify)
{
	self endon("death");
	self endon("goal");
	self endon(end_notify);
	target endon("death");

	while (true)
	{
		Line(self.origin, target.origin, (1, 0, 0));
		Line(self.origin, target_point, (1, 1, 0));

		wait(0.05);
	}
}

heli_fire_burst(target, min_burst_time, max_burst_time, num_guns)
{
	self endon("death");
	self endon("stop_firing");
	target endon("death");

	if (!IsDefined(self.firing))
	{
		self.firing = false;
	}

	if (self.firing)
		return;

	if (!IsDefined(target))
		return;

	for (i = 0; i < num_guns; i++)
	{
		self SetGunnerTargetEnt(target, (0, 0, 0), i);
	}

//	if (self.vehicleType != "heli_hip_sidegun" && self.vehicleType != "heli_hip_sidegun_uwb")
//	{
//		self waittill("turret_on_vistarget");
//	}
	
	sound_ent = spawn( "script_origin" , self.origin );
	self thread burst_fire_audio_delete(sound_ent, max_burst_time);

	time = RandomFloatRange(min_burst_time, max_burst_time);
	while (time > 0.0)
	{
		if (IsDefined(sound_ent))
		{
			sound_ent playloopsound( "wpn_hind_pilot_fire_loop_npc" );
		}

		for (i = 0; i < num_guns; i++)
		{
			self FireGunnerWeapon(i);

			if (self.vehicleType != "heli_hip_sidegun" && self.vehicleType != "heli_hip_sidegun_uwb")
			{
				wait(0.05);
			}
		}

		if (self.vehicleType != "heli_hip_sidegun" && self.vehicleType != "heli_hip_sidegun_uwb")
		{
			time -= 0.05;
			wait(0.05);
		}
		else
		{
			time -= 0.1;
			wait(0.1);
		}
	}

	if (IsDefined(sound_ent))
	{
		sound_ent stoploopsound();
	}
	self.firing = false;
}

heli_fire_rockets(target, num_rockets)
{
	self endon("death");
	target endon("death");

	if (!IsDefined(target))
		return;

	self SetTurretTargetEnt(target);
	//self waittill("turret_on_vistarget");
	
	for (i = 0; i < num_rockets; i++)
	{	
		self FireWeapon();
		wait(0.25);
	}
}

burst_fire_audio_delete(sound_ent, burst_time)
{
	self notify( "force_delete_sound" );
	self waittill_any_or_timeout( burst_time + 1, "death" , "stop_firing", "force_delete_sound", "resistance_done", "stop_engage" );

	if (IsDefined(sound_ent))
	{
		sound_ent delete();
	}
}

group_objective_marker(group_name)
{
	myIndex = -1;

	// find a free marker
	for (i = 0; i < 8; i++)
	{
		if (level.group_objective_markers[i] == (0,0,0))
		{
			myIndex = i;
			break;
		}
	}

	if (myIndex < 0)
		return;

	group = get_ai_array(group_name, "script_noteworthy");
	while (group.size == 0)
	{
		group = get_ai_array(group_name, "script_noteworthy");
		wait(0.05);
	}

	while (group.size > 0)
	{
		group = get_ai_array(group_name, "script_noteworthy");
		group = array_removedead(group);
		group = array_removeundefined(group);

		if (group.size == 0)
			break;

		average_pos = (0,0,0);
		for (i = 0; i < group.size; i++)
		{
			average_pos += (group[i].origin + (0,0,128));	
		}

		average_pos /= group.size;

		level.group_objective_markers[myIndex] = average_pos;

		Objective_AdditionalPosition(level.curr_obj_num, myIndex, average_pos);

		wait(0.05);
	}

	level.group_objective_markers[myIndex] = (0,0,0);
	Objective_AdditionalPosition(level.curr_obj_num, myIndex, level.group_objective_markers[myIndex]);
}

get_closest_objective_group()
{
	closest = -1;
	closest_dist = 99999999.0;

	player = get_players()[0];

	for (i = 0; i < level.group_objective_markers.size; i++)
	{
		// skip inactive objective markers
		if (level.group_objective_markers[i] == (0,0,0))
			continue;

		dist = Distance2D(player.origin, level.group_objective_markers[i]);

		if (dist < closest_dist)
		{
			closest_dist = dist;
			closest = i;
		}
	}

	objective_pos = undefined;
	if (closest > -1)
	{
		objective_pos = level.group_objective_markers[closest];
	}

	return objective_pos;
}

rocket_rumble_when_close(target, final_barrage)
{
	self endon("death");
	
	while(DistanceSquared(target.origin, self.origin) > 500 * 500)
	{
		wait(0.05);
	}

	if (!IsDefined(level.did_notetrack))
	{
		level.did_notetrack = false;
	}

	if (IsDefined(final_barrage) && final_barrage == true && !level.did_notetrack)
	{
		level.did_notetrack = true;
		level notify("huey_int_dmg_start");
		//IPrintLnBold("Damage State 3");
	}

	player = get_players()[0];
	player PlayRumbleOnEntity( "damage_light" );
	Earthquake( 0.3, 1.5, self.origin, 700 );
}



//
//	Print a debug string that follows the ent
debug_text( text )
{
	self endon( "death" );

	while (1)
	{
		print3d( self.origin, text, (1,1,1), 1, 1, 1 );
		wait( 0.05 );
	}
}


//
//	Put on your dive mask
divemask_equip()
{
	// Put on divemask
	player = get_players()[0];
	player take_weapons();		// Weapons re-enabled in enterbase::moonpool_move_player
	player GiveWeapon( "divemask_sp" );
	player SwitchToWeapon( "divemask_sp" );
	wait( 0.05 );
	player DisableWeapons();
//	player HideViewModel();		// Hide the mask
//	player hide_swimming_arms();	// need to hide swimming arms so the mask weapon stays up
	level waittill( "divemask_unequip" );

	fade_out(0.5, "black");
//	player ShowViewModel();			// Show the mask so we can remove it
	player give_weapons();			// this will remove the mask
//	player show_swimming_arms();	// turn swimming arms back on
	player EnableWeapons();
	wait( 0.3 );

	fade_in(0.5, "black");
}


//
//	Transition in and out of Depth of field smoothly
//	call flag_clear( "dof_transition" ) to return DOF to previous settings
//	NOTE: This is hardcoded to track Dragovich at the moment...desparate times...
dof_transition( trans_in_time, trans_out_time, near_start, near_end, far_start, far_end, near_blur, far_blur )
{
	// Get default DOF Settings
	player = get_players()[0];
	def_near_start	= player GetDepthOfField_NearStart();
	def_near_end	= player GetDepthOfField_NearEnd();
	def_far_start	= player GetDepthOfField_FarStart();
	def_far_end		= player GetDepthOfField_FarEnd();
	def_near_blur	= player GetDepthOfField_NearBlur();
	def_far_blur	= player GetDepthOfField_FarBlur();
	tracking = false;
	if ( !IsDefined( near_end ) )
	{
		tracking = true;
		// Focus on him
		focus_distance = Distance( player.origin, level.dragovich.origin );
		near_start	= 0;
		if ( near_start < 0 )
		{
			near_start = 0;
		}
		near_end	= focus_distance - 80;
		if ( near_end < 1 )
		{
			near_end = 1;
		}

		far_start	= focus_distance + 20;
		far_end		= focus_distance + 40;
	}
	player dof_lerp( trans_in_time, near_start, near_end, far_start, far_end, near_blur, far_blur );

	flag_set("dof_transition");
	while( flag("dof_transition") )
	{
		if ( tracking )
		{
			focus_distance = Distance( player.origin, level.dragovich.origin );
			near_start	= 0;
			if ( near_start < 0 )
			{
				near_start = 0;
			}
			near_end	= focus_distance - 80;
			if ( near_end < 1 )
			{
				near_end = 1;
			}

			far_start	= focus_distance + 20;
			far_end		= focus_distance + 40;
 			player SetDepthOfField( near_start, near_end, far_start, far_end, near_blur, far_blur );
		}
		wait( 0.05 );
	}

	player dof_lerp( trans_out_time, def_near_start, def_near_end, def_far_start, def_far_end, def_near_blur, def_far_blur );
}

//
//	Smoothly change depth of field
//	self is player
dof_lerp( time, near_start, near_end, far_start, far_end, near_blur, far_blur )
{
	// Get current DOF Settings
	curr_near_start	= self GetDepthOfField_NearStart();
	curr_near_end	= self GetDepthOfField_NearEnd();
	curr_far_start	= self GetDepthOfField_FarStart();
	curr_far_end	= self GetDepthOfField_FarEnd();
	curr_near_blur	= self GetDepthOfField_NearBlur();
	curr_far_blur	= self GetDepthOfField_FarBlur();

	steps = time / 0.05;
	for ( i=0; i<=steps; i++ )
	{
		fraction = steps * 0.05 / time;
		next_near_start	= LerpFloat( curr_near_start,	near_start,	fraction );
		next_near_end	= LerpFloat( curr_near_end,		near_end,	fraction );
		next_far_start	= LerpFloat( curr_far_start,	far_start,	fraction );
		next_far_end	= LerpFloat( curr_far_end,		far_end,	fraction );
		next_near_blur	= LerpFloat( curr_near_blur,	near_blur,	fraction );
		next_far_blur	= LerpFloat( curr_far_blur,		far_blur,	fraction );

		self SetDepthOfField( next_near_start, next_near_end, next_far_start, next_far_end, next_near_blur, next_far_blur );
	}
}


// 
//	Open a door and connect paths
//
door_close( targetname, rotation, time )
{
	if (!IsDefined(time) )
	{
		time = 2.0;
	}
	door = GetEnt( targetname, "targetname" );
	door RotateYaw( rotation, time, time/2.1, time/2.1 );
	door DisconnectPaths();
	wait time;
}


// 
//	Open a door and connect paths
//
door_open( targetname, rotation, time )
{
	if (!IsDefined(time) )
	{
		time = 2.0;
	}
	door = GetEnt( targetname, "targetname" );
	door RotateYaw( rotation, time, time/2.1, time/2.1 );
	door ConnectPaths();
	wait time;
}


//
//	Turn tightly and forcegoal
indoor_forcegoal()
{
	self enable_cqbsprint();
	self force_goal();
}

//
//	Turn tightly and rush
indoor_rusher()
{
	self enable_cqbsprint();
	self maps\_rusher::rush();
}


//
//	Randomizes nag dialog.  Doesn't play the same line twice
//
//	actor = the one who says the lines
//	lines - an array of line aliases
//	delay - gap between lines
//	endon_msg - msg to listen for to stop.
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
		lines[0] = "come_on_mason2";
		lines[1] = "keep_moving";
		lines[2] = "on_me";
		lines[3] = "get_up_here";
		lines[4] = "out_of_time";
		lines[5] = "need_to_move_mason";
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
//	Pass in the name of a NODE or STRUCT for the actor to start at
//		self is an actor
set_actor_start( targetname, color )
{
	start = GetStruct( targetname, "targetname" );
	if ( !IsDefined( start ) )
	{
		start = GetNode( targetname, "targetname" );
	}
	if ( IsDefined( start ) )
	{
		self ForceTeleport( start.origin, start.angles );
	}

	if ( IsDefined( color ) )
	{
		self set_force_color( color );
	}
}


//	Sets the water volume and texture to the origin of the target
set_water_height( targetname, show_texture )
{
	// set water volume to moonpool height
	new_height = GetStruct( targetname, "targetname" );
	level.water_volume.origin = new_height.origin;	// offset to match water volume and texture

	// Do we need to change the state of the texture?
	if ( is_true(show_texture) )
	{
		if ( show_texture )
		{
			level.water_texture Show();
		}
		else
		{
			level.water_texture Hide();
		}
	}
}


//
//
setup_topside_water()
{
	player = get_players()[0];
	player SetClientDvar( "missileWaterMaxDepth", 1000 );

	SetDvar( "r_waterWaveAngle", "86 20 66 216" );
	SetDvar( "r_waterWaveWavelength", "369 537 329 217" );
	SetDvar( "r_waterWaveAmplitude", "38.5 22.5 34 13" );
	SetDvar( "r_waterWavePhase", "0.0 0.0 0.0 0.0" );
	SetDvar( "r_waterWaveSteepness", "1.0 1.0 1.0 1.0" );
	SetDvar( "r_waterWaveSpeed", "0.6 0.5 0.55 0.7" );
}

setup_ending_water()
{
	// setup water
	SetDvar( "r_waterWaveAngle", "0 45 92 180" );
	SetDvar( "r_waterWaveWavelength", "353 134 465 623" );
	SetDvar( "r_waterWaveAmplitude", "5.8 2.62 8.72 4.2" );
	SetDvar( "r_waterWavePhase", "0.0 0.0 0.0 0.0" );
	SetDvar( "r_waterWaveSteepness", "0.22 0.26 0.134 0.163" );
	SetDvar( "r_waterWaveSpeed", "1.19 0.344 1.25 0.75" );
}

setup_umbilical_water()
{
	if ( !flag( "swim_init_done" ) )
	{		
		SetDvar( "r_waterWaveAngle", "86 20 66 216" );
		SetDvar( "r_waterWaveWavelength", "369 537 329 217" );
		SetDvar( "r_waterWaveAmplitude", "1.0 0.0 1.0 1.0" );
		SetDvar( "r_waterWavePhase", "0.0 0.0 0.0 0.0" );
		SetDvar( "r_waterWaveSteepness", "1.0 1.0 1.0 1.0" );
		SetDvar( "r_waterWaveSpeed", "0.6 0.5 0.55 0.7" );
	}
}


underwaterbase_vehicle_damage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName)
{
	//self = vehicle that is taking Damage
	/*
	if( self IsVehicleImmuneToDamage( iDFlags, sMeansOfDeath, sWeapon ) )
	{
		return;
	}
	*/
	
	if(self.vehicletype == "heli_huey_player_uwb")
	{
		//iprintln("player hind damage");
		self.last_weapon_hit = sWeapon;

		switch( self.last_weapon_hit )
		{
			case "hind_rockets_sp":
			case "hind_rockets_2x_sp":
			case "hind_rockets_sp_uwb":
			case "rpg_sp":
			case "rpg_uwb_sp":
			case "sam_uwb_sp":
				self PlaySound( "evt_player_hit" );
				player = get_players()[0];
				player PlayRumbleOnEntity( "artillery_rumble" );
				Earthquake( 0.5, 1.0, self.origin, 700 );
			break;
		}

		// Hax for the helicopter dying from some massive damage.
		if ( iDamage >= self.health )
		{
			if ( self.health < 2 )
			{
				self.health = 10;
			}
			iDamage = 1;
		}
	}
	else if (self.vehicletype == "heli_hip_sidegun" || self.vehicletype == "heli_hip_sidegun_uwb")
	{
		if (sWeapon != "uwb_m220_tow_sp")
		{
			iDamage = 0;
		}
	}
	else if (self.vehicletype == "heli_hind_doublesize" || self.vehicletype == "heli_hind_doublesize_uwb")
	{
		health = self.health;
		new_health = health - iDamage;
		if (new_health <= 0)
		{
			if (!self ent_flag("im_out_this_bitch"))
			{
				self ent_flag_set("im_out_this_bitch");
				self maps\underwaterbase_snipe::enemy_hind_fire_rocket_barrage();
			}
			else
			{
				iDamage = 0;
				return;
			}
		}
	}
			
	self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);
}

get_player_aim_pos(range, ignore_ent)
{
	player = get_players()[0];

	start_pos = player GetEye();
	dir = AnglesToForward(player GetPlayerAngles());
	end_pos = start_pos + dir * range;

	hit_pos = PlayerPhysicsTrace(start_pos, end_pos, (-10,-10,0), (10,10,0), ignore_ent);

	//DebugStar( hit_pos, 20, (0.9, 0.7, 0.6) );

	return hit_pos;
}

update_water_plane(water_name, amplitude, frequency, angular_amplitude)
{
	self endon("stop_water_" + water_name);

	a = 150.0;
	w = 25.0;
	t = 0.0;

	if (!IsDefined(angular_amplitude))
	{
		angular_amplitude = (0,0,0);
	}

	water = level.water_planes[water_name];
	water_start = water.origin;
	water_start_angles = water.angles;

	// typical sine wave y(t) = a * sin((w * t) + theta)
	while (true)
	{
		normalized_wave_height = Sin(frequency * t);

		wave_height_z = amplitude * normalized_wave_height;

		water.origin = water_start + (0, 0, wave_height_z);
		water.angles = water_start_angles + (angular_amplitude * normalized_wave_height);

		t += 0.05;
		wait(0.05);
	}
}

play_player_damaged_vo()
{
	lines = [];
	lines[0] = "shit_were_hit";
	lines[1] = "were_hit";
	lines[2] = "taking_fire";
	lines[3] = "evasive_action";
//	lines[4] = "get_out";
//	lines[5] = "pull_up";

	if (!IsDefined(level.last_damage_line))
	{
		level.last_damage_line = -1;
	}

	if (RandomInt(100) < 5)
	{
		if (IsDefined(level.hero_speak) && level.hero_speak == false)
		{
			line = RandomInt(lines.size);
			if (line == level.last_damage_line)
			{
				line = line + 1;
				if (line >= lines.size)
				{
					line = 0;
				}
			}

			level.last_damage_line = line;

			level.heroes["hudson"] maps\_anim::anim_single(level.heroes["hudson"], lines[line]);
		}
	}
}

play_player_is_awesome_line()
{
	level endon("player_awesome_thread_done");

	player = get_players()[0];

	lines = [];
	lines[0] = "nice";
	lines[1] = "good_shooting";
	lines[2] = "got_em";
	lines[3] = "keep_it_up";
	lines[4] = "taken_out";

	last_line = -1;

	while (1)
	{
		level waittill("heli_kill_streak");

		line = RandomInt(lines.size);
		if (line == last_line)
		{
			line = line + 1;
			if (line >= lines.size)
			{
				line = 0;
			}
		}

		last_line = line;

		if (RandomInt(100) < 75)
		{
			if (IsDefined(level.hero_speak) && level.hero_speak == false)
			{
				level.heroes["hudson"] maps\_anim::anim_single(level.heroes["hudson"], lines[line]);
			}
		}
	}
}

play_player_is_almost_awesome_line()
{
	level endon("player_awesome_thread_done");

	player = get_players()[0];

	lines = [];
	lines[0] = "take_them";
	lines[1] = "stay_on_them";

	last_line = -1;

	while (1)
	{
		level waittill("heli_encourage_kill_streak");

		line = RandomInt(lines.size);
		if (line == last_line)
		{
			line = line + 1;
			if (line >= lines.size)
			{
				line = 0;
			}
		}

		last_line = line;

		if (RandomInt(100) < 50)
		{
			if (IsDefined(level.hero_speak) && level.hero_speak == false)
			{
				level.heroes["hudson"] maps\_anim::anim_single(level.heroes["hudson"], lines[line]);
			}
		}
	}
}

player_height_kill()
{
	player = get_players()[0];

	level endon("stop_player_kill_check");
	player endon("death");

	death_struct = GetStruct("player_death_height", "targetname");
	death_z = death_struct.origin[2];

	while (1)
	{
		player_z = player.origin[2];

		if (player_z < death_z)
		{
			fade_out(0.5, "white");
			player DoDamage(player.health + 1000, player.origin);
			//MissionFailedWrapper();
		}

		wait(0.05);
	}
}

level_spawner_cleanup()
{
	player = get_players()[0];
	player endon("death");
	level endon("stop_spawner_cleanup");

	while (1)
	{
		spawners = GetSpawnerArray();
		for (i = 0; i < spawners[i].size; i++)
		{
			if (IsDefined(spawners[i].count) && spawners[i].count == 0)
			{
				spawners[i] delete();
			}
		}

		wait(0.05);
	}
}

level_damage_trigger_cleanup()
{
	trigs = GetEntArray("trigger_damage", "classname");
	array_thread(trigs, ::single_damage_trigger_cleanup);
}

single_damage_trigger_cleanup()
{
	self waittill("trigger");
	self delete();
}

/***************************************************************/
//
//	sky metal
//
/***************************************************************/
sky_metal(node, parts, count, min_offset, max_offset, min_vel, max_vel, separation, group, ender)
{
	level endon(ender);

	if (!IsDefined(level.metal))
	{
		level.metal = [];
	}

	metal_org = node;
	if (IsString(node))
	{
		metal_org = GetStruct(node, "targetname");
	}

	level.metal[group] = [];
	center = metal_org.origin;
	angles = metal_org.angles;
	up = AnglesToUp(angles);
	forward = AnglesToForward(angles);
	right = AnglesToRight(angles);

	// spawn a bunch of stuff
	for (i = 0; i < count; i++)
	{
		offset = (RandomFloatRange(min_offset[0], max_offset[0]), RandomFloatRange(min_offset[1], max_offset[1]), RandomFloatRange(min_offset[2], max_offset[2]));		
		offset_f = forward * offset[0];
		offset_r = right * offset[1];
		offset_u = up * offset[2];

		if (IsDefined(level.metal_origins[group]))
		{
			if (IsDefined(level.metal_origins[group][i]))
			{
				position = level.metal_origins[group][i];
			}
			else
			{
				position = center + (offset_f + offset_r + offset_u);
			}
		}
		else
		{
			position = center + (offset_f + offset_r + offset_u);
		}

		level.metal[group][i] = spawn("script_model", position);
		level.metal[group][i] SetForceNoCull();
		level.metal[group][i].angles = angles;
		level.metal[group][i] SetModel(parts["main"]);

		if (IsDefined(parts["interior"]))
		{
			level.metal[group][i] Attach(parts["interior"], "tag_body");
		}

		if (IsDefined(parts["rotor_main"]))
		{
			PlayFXOnTag(parts["rotor_main"], level.metal[group][i], "main_rotor_jnt");
		}

		if (IsDefined(parts["rotor_tail"]))
		{
			PlayFXOnTag(parts["rotor_tail"], level.metal[group][i], "tail_rotor_jnt");
		}

		//if(even_number(i))
		//{
		//level.metal[group][i] RotatePitch(12, 0.05);
		//}

		level.metal[group][i].vel = AnglesToForward(angles) * RandomFloatRange(min_vel, max_vel);
	}

	dump_metal_positions(group);

	while (1)
	{
//		Box(center, min_offset, max_offset, angles[1], (1, 0, 0), 1, 1, 1);

		for (i = 0; i < count; i++)
		{
		//	v1 = metal[i] sky_metal_cohesion(metal, 0.001);
			v2 = level.metal[group][i] sky_metal_separation(level.metal[group], 1.0, separation);

			level.metal[group][i].origin = level.metal[group][i].origin + v2 * 0.05;
			level.metal[group][i].origin = level.metal[group][i].origin + level.metal[group][i].vel * 0.05;
		}

		wait(0.05);
	}
}

dump_metal_positions(group_name)
{
	Print(group_name + "\n");
	for (i = 0; i < level.metal[group_name].size; i++)
	{
		Print("i: " + level.metal[group_name][i].origin[0] + " " + level.metal[group_name][i].origin[1] + " " + level.metal[group_name][i].origin[2] + "\n");
	}
}

// self == metal[i]
sky_metal_cohesion(metal_list, weight)
{
	average_pos = (0, 0, 0);
	
	// sum up the positions
	for (i = 0; i < metal_list.size; i++)
	{
		if (self != metal_list[i])
		{
			average_pos += metal_list[i].origin;
		}
	}

	// find the average
	average_pos = average_pos / (metal_list.size - 1);

	// get the delta to the average position
	delta = average_pos - self.origin;

	// return the weighted average
//	return (delta * weight);
	return (0,0,0);
}

// self == metal[i]
sky_metal_separation(metal_list, weight, min_delta)
{
	delta = (0, 0, 0);
	min_delta_squared = min_delta * min_delta;

	for (i = 0; i < metal_list[i].size; i++)
	{
		if (self != metal_list[i])
		{
			dist = DistanceSquared(self.origin, metal_list[i].origin);
			if (dist < min_delta_squared)
			{
				delta = delta + (self.origin - metal_list[i].origin);
				//dir = VectorNormalize(self.origin - metal_list[i].origin);
				//delta = delta + (dir * (min_delta - Sqrt(dist)));
				//delta = delta + dir;
			}
		}
	}

	return delta * weight;
}

sky_metal_velocity_match(metal_list)
{

}

heli_goal_pos_obstructed(pos)
{
	if (IsDefined(self.velocity))
	{
		trace_start = self.origin - (0,0,100);
		dir = VectorNormalize(self.velocity);
		trace_end = trace_start + dir * 2500;
		trace = BulletTrace(trace_start, trace_end, 0, undefined);

		player = get_players()[0];

		Line(trace_start, trace_end, (1, 1, 1), false, 200);
		if (IsDefined(trace["entity"]))
		{
			if (trace["entity"] == player || trace["entity"] == level.huey)
			{
				Line(trace_start, trace_end, (1, 0, 0), false, 200);
				return true;
			}
		}
	}

	return false;
}

heli_near_player()
{
	self endon("death");
	self endon("stop_heli_near_player_check");
	level.huey endon("death");

	dist = Distance(level.huey.origin, self.origin);
//	IPrintLn("Dist: " + dist);

	if (dist < 750)
	{
		return true;
	}

	return false;
}

heli_avoidance()
{
	self endon("done_avoiding");
	self endon("death");
	self endon("landing");

	max_push_dist = 750;
	max_push_vel = 30;
	avoiding = false;
	while (1)
	{
		if (IsDefined(self.velocity))
		{
			// get current velocity
			velocity = self.velocity;

			// first avoid the player
			dist = Distance(level.huey.origin, self.origin);
			//IPrintLn("Dist: " + dist);

			// if we are with in the bounds 
			if (dist < max_push_dist)
			{
				// find out how far in we are
				//normalized_dist = dist / max_push_dist;
				normalized_dist = 1;

				// push away from the player
				delta = self.origin - level.huey.origin;
				delta = (delta[0], delta[1], 0);
				delta = VectorNormalize(delta);
				dir = (0,0,1);
				push_vel = dir * (max_push_vel * normalized_dist);
				velocity = (velocity[0] * 0.75, velocity[1] * 0.75, velocity[2]);
				velocity = velocity + push_vel;

				avoiding = true;
			}
			else
			{
				if (avoiding)
				{
					velocity = (velocity[0], velocity[1], 0.0);
				}

				avoiding = false;
			}

			self SetVehVelocity(velocity);
		}

		wait(0.05);
	}
}

player_heli_avoidance(avoid_ent)
{
	self endon("done_avoiding");
	self endon("death");
	self endon("landing");

	max_push_dist = 500;
	max_push_vel = 200;
	avoiding = false;
	while (1)
	{
		if (IsDefined(self.velocity))
		{
			// get current velocity
			velocity = self.velocity;

			// first avoid the player
			dist = Distance(avoid_ent.origin, self.origin);
			//IPrintLn("Dist: " + dist);

			// if we are with in the bounds 
			if (dist < max_push_dist)
			{
				// find out how far in we are
				//normalized_dist = dist / max_push_dist;
				normalized_dist = 1;

				// push away from the player
				delta = self.origin - avoid_ent.origin;
				//delta = (delta[0], delta[1], 0);
				delta = VectorNormalize(delta);
				push_vel = delta * max_push_vel;
// 				dir = (0,0,1);
// 				push_vel = dir * (max_push_vel * normalized_dist);
				velocity = (velocity[0] * 0.75, velocity[1] * 0.75, velocity[2]);
				velocity = velocity + push_vel;

				avoiding = true;
			}
			else
			{
				if (avoiding)
				{
					velocity = (velocity[0], velocity[1], 0.0);
				}

				avoiding = false;
			}

			self SetVehVelocity(velocity);
		}

		wait(0.05);
	}
}

#using_animtree("generic_human");
spawn_fake_huey_riders()
{
	positions = [];
	positions[0] = "tag_passenger2";
	positions[1] = "tag_passenger3";
	positions[2] = "tag_passenger4";
	positions[3] = "tag_passenger5";

	self.dudes = [];

	for (i = 0; i < 4; i++)
	{
		self.dudes[i] = spawn_character("redshirt", (0,0,0), (0,0,0));
		self.dudes[i] LinkTo(self, positions[i]);
		self thread anim_generic_loop_aligned(self.dudes[i], positions[i], positions[i]);
	}
}

delete_fake_huey_riders()
{
	if (IsDefined(self.dudes))
	{
		for (i = 0; i < 4; i++)
		{
			self.dudes[i] UnLink();
			self.dudes[i] delete();
		}
	}
}

launch_fake_huey_riders()
{
	if (IsDefined(self.dudes))
	{
		for (i = 0; i < 4; i++)
		{
			dir = self.dudes[i] - self.org;
			dir = VectorNormalize(dir);
			launch_angles = VectorToAngles(dir);

			force_mag = RandomFloatRange(15, 20);
			force = dir * force_mag;
			
			self.dudes[i] thread guy_explosion_launch(self.origin, force);
			self.dudes[i] thread fake_rider_delete();
		}
	}
}

fake_rider_delete()
{
	wait(3.0);
	self delete();
}



