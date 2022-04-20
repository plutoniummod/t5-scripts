////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL SCRIPTS
//
//
// Script for event 9 - this covers the following scenes from the design:
//		Slides 49-58
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;
#include maps\flashpoint_util;
#include maps\_music;
#include maps\_vehicle;

////////////////////////////////////////////////////////////////////////////////////////////
// EVENT9 FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////


difficulty_adjustments()
{
	//-- adjustment just for recruit - made easier
	if( GetDvarInt( #"g_gameskill" ) == 0 )
	{
		level.invulTime_onShield_multiplier = 1.5;  //shield will last a little longer
		level.player_attacker_accuracy_multiplier = 0.5;
	}
	
	//-- adjustment just for verteran - made easier
	if( GetDvarInt( #"g_gameskill" ) == 3 )
	{
		level.invulTime_onShield_multiplier = 2.0;  //shield will last a little longer
		level.player_attacker_accuracy_multiplier = 0.7;
	}
}



tunnels_start_save_point()
{
	tunnels_start_save_point_trig = getent( "tunnels_start_save_point", "targetname" );
	tunnels_start_save_point_trig waittill( "trigger" );
	tunnels_start_save_point_trig Delete();
	autosave_by_name("flashpoint_e9b");
	
	level.woods.ignoreall = false;
	level.weaver.ignoreall = false;
	battlechatter_on( "axis" );
	battlechatter_on( "allies" );
	
	tunnels_start_save_point_trig_2 = getent( "tunnels_start_save_point_2", "targetname" );
	tunnels_start_save_point_trig_2 waittill( "trigger" );
	tunnels_start_save_point_trig_2 Delete();

	autosave_by_name("flashpoint_e9c");
	
	tunnels_start_save_point_trig_3 = getent( "tunnels_start_save_point_3", "targetname" );
	tunnels_start_save_point_trig_3 waittill( "trigger" );
	tunnels_start_save_point_trig_3 Delete();
	autosave_by_name("flashpoint_e9d");
}



drop_piece( distance, time )
{
	drop_pos = self.origin;
	drop_pos = drop_pos - ( 0.0, 0.0, distance );
	self MoveTo( drop_pos, 3.0 );
	self waittill_notify_or_timeout( "movedone", time ); 

	exploder( 1210 );

	level notify( "stop_elevator_sparks" );
}

lift_start_trigger()
{
	//Get current rest position and move the elevator down
	elevator_drop_ents = getentarray( "elevator_drop", "targetname" );
	for( i=0; i<elevator_drop_ents.size; i++ )
	{
		elevator_drop_ents[i].rest_pos = elevator_drop_ents[i].origin;
		elevator_drop_ents[i].origin = elevator_drop_ents[i].origin - ( 0.0, 0.0, 150.0 );
	}
	
	lift_start_trig = getent( "lift_start", "targetname" );
	lift_start_trig waittill( "trigger" );
	
	simple_spawn_single( "elevator_guard", ::force_goal_self );

	time_to_move_up = 14.0;
	//ADD SOUND FOR LIFT MOVING UP  - TIME IS PASSED IN TO NEXT FUNCTION
	elevator_drop_ents[0] playsound ("evt_lift_move");

	for( i=0; i<elevator_drop_ents.size; i++ )
	{
		elevator_drop_ents[i] thread drop_piece( -150.0, time_to_move_up );
	}

}

has_barrel_been_hit()
{
	level endon( "DROP_LIFT" );	
	self waittill( "barrel_dead" );
	flag_set( "DROP_LIFT" );
}

has_progressed_fwd( barrel_pos )
{
	level endon( "DROP_LIFT" );	
	self waittill( "trigger" );
	RadiusDamage( barrel_pos, 300, 300, 100 );
	flag_set( "DROP_LIFT" );
}


lift_drop_trigger()
{
	//Check for barrel being hit
	barrels_to_check = getentarray( "lift_barrel", "script_noteworthy" );
	for( i=0; i<barrels_to_check.size; i++ )
	{
		barrels_to_check[i] thread has_barrel_been_hit();
	}
	
	
	lift_drop_trig = getent( "lift_drop", "targetname" );
	lift_drop_trig thread has_progressed_fwd( barrels_to_check[0].origin );
	
	flag_wait( "DROP_LIFT" );
	
	/*
maps/flashpoint/fx_elevator_fall – Sparks and smoke for elevator drop.  
Place at the bottom front of the elevator.  Aim +X forward and +Z up.  
It needs to be parented with the elevator.  This effect requires sound.  
When the elevator lands, trigger exploder 910.  This won’t do anything until I make my createfx check-in.
*/
		

	//BOOM!!!!!!
	elevator_drop_ents = getentarray( "elevator_drop", "targetname" );
	//self DoDamage( elevator_drop_ents[0].health + 1000, elevator_drop_ents[0].origin );
	//playfx( level._effect["vehicle_explosion"], elevator_drop_ents[0].origin );
	earthquake( 0.6, 1, level.player.origin,  500 );
	level.player PlayRumbleOnEntity( "damage_heavy");
	
	//ADD SOUND FOR LIFT FALLING DOWN  - TIME IS PASSED IN TO NEXT FUNCTION
	elevator_drop_ents[0] playsound ("evt_lift_fall");
	//scream_ent = elevator_drop_ents[0];
	elevator_drop_ents[0] thread play_lift_screams();
	
	elevator_sparks = GetEnt( "elevator_sparks", "script_noteworthy" );
	
	//elevator_sparks LinkTo( elevator_sparks, level._effect["elevator_fall"] );	
	
	time_to_fall_down_stage1 = 2.5;
	for( i=0; i<elevator_drop_ents.size; i++ )
	{
		elevator_drop_ents[i] thread drop_piece( 50.0, time_to_fall_down_stage1 );
	}
	PlayFXOnTag(level._effect["elevator_fall"], elevator_sparks, "tag_origin");	

	wait( time_to_fall_down_stage1 );
	
	//exploder( 1210 );
	
	time_to_fall_down_stage2 = 160.0;
	level thread loop_spark_fx( elevator_sparks );

	for( i=0; i<elevator_drop_ents.size; i++ )
	{
		elevator_drop_ents[i] thread drop_piece( 950.0, time_to_fall_down_stage2 );
	}
	wait( time_to_fall_down_stage2 );
}

loop_spark_fx( elevator_sparks )
{
	level endon( "stop_elevator_sparks" );

	while(1)
	{
		PlayFXOnTag(level._effect["elevator_fall"], elevator_sparks, "tag_origin");	

		wait( 0.05 );
	}

}

play_lift_screams()
{
	wait 2;
	self playsound("evt_lift_scream");	
}
_anim_playonce( _animname, _anim, _animnode, exitnode_str )
{
	self endon( "death" );
	anim_node = get_anim_struct( _animnode );
	self.animname = _animname;
 	anim_node thread anim_single_aligned( self, _anim );
 	anim_node waittill( _anim );
 	
 	self startragdoll();
	self dodamage( self.health, self.origin );
}


setup_fire_scientist()
{
	self endon("death");

	self.deathfunction = animscripts\utility::do_ragdoll_death;
	self.allowdeath = true;
	self.goalradius = 32;
	self.ignoreall = true;
	self.dropweapon = false;
	self.team = "axis";
}

on_fire_scientist()
{
	event9_triggers_on_fire_trig = getent( "event9_triggers_on_fire", "targetname" );
	event9_triggers_on_fire_trig waittill( "trigger" );
	
	on_fire_scientist_1 = simple_spawn_single( "on_fire_scientist_1", ::setup_fire_scientist );
	on_fire_scientist_2 = simple_spawn_single( "on_fire_scientist_2", ::setup_fire_scientist );
	on_fire_scientist_3 = simple_spawn_single( "on_fire_scientist_3", ::setup_fire_scientist );
	on_fire_scientist_4 = simple_spawn_single( "on_fire_scientist_4", ::setup_fire_scientist );
	
	on_fire_scientist_1 thread _anim_playonce( "worker", "onfire1", "15" );
	on_fire_scientist_2 thread _anim_playonce( "worker", "onfire2", "15" );
	on_fire_scientist_3 thread _anim_playonce( "worker", "onfire3", "15" );
	on_fire_scientist_4 thread _anim_playonce( "worker", "onfire4", "15" );
	
// 	PlayFxOnTag(level._effect["enemy_on_fire"], on_fire_scientist_1, "J_SpineLower");
// 	PlayFxOnTag(level._effect["enemy_on_fire"], on_fire_scientist_2, "J_SpineLower");
// 	PlayFxOnTag(level._effect["enemy_on_fire"], on_fire_scientist_3, "J_SpineLower");
// 	PlayFxOnTag(level._effect["enemy_on_fire"], on_fire_scientist_4, "J_SpineLower");
	
// 	on_fire_scientist_1 starttanning();
// 	on_fire_scientist_2 starttanning();
// 	on_fire_scientist_3 starttanning();
// 	on_fire_scientist_4 starttanning();
// 	
	if( is_mature() )
	{
		PlayFxOnTag(level._effect["enemy_on_fire"], on_fire_scientist_1, "J_SpineLower");
		PlayFxOnTag(level._effect["enemy_on_fire"], on_fire_scientist_2, "J_SpineLower");
		PlayFxOnTag(level._effect["enemy_on_fire"], on_fire_scientist_3, "J_SpineLower");
		PlayFxOnTag(level._effect["enemy_on_fire"], on_fire_scientist_4, "J_SpineLower");
		
		on_fire_scientist_1 StartTanning();
		on_fire_scientist_1 SetClientFlag(level.ACTOR_CHARRING);
		
		on_fire_scientist_2 StartTanning();
		on_fire_scientist_2 SetClientFlag(level.ACTOR_CHARRING);
		
		on_fire_scientist_3 StartTanning();
		on_fire_scientist_3 SetClientFlag(level.ACTOR_CHARRING);
		
		on_fire_scientist_4 StartTanning();
		on_fire_scientist_4 SetClientFlag(level.ACTOR_CHARRING);

		on_fire_scientist_1 play_fire_on_enemy();
		on_fire_scientist_2 play_fire_on_enemy();
		on_fire_scientist_3 play_fire_on_enemy();
		on_fire_scientist_4 play_fire_on_enemy();	
	}
}

play_fire_on_enemy()
{
	self playsound("amb_fire_human");	

}
/*
•	env/fire/fx_fire_player_torso – a fire-and-smoke effect played on and oriented to a character’s torso.  This is a one-shot that lasts around 23 seconds.  Use this for characters that need a higher detail fire.
•	env/fire/fx_fire_player_md – a fire-and-smoke effect played on and oriented to a character’s thigh.  This is a one-shot that lasts around 18.5 seconds.  Use this for characters that need a higher detail fire.
•	env/fire/fx_fire_player_sm – a fire-and-smoke effect played on and oriented to a character’s arm.  This is a one-shot that lasts around 14 seconds.  Use this for characters that need a higher detail fire.
•	env/fire/fx_fire_player_torso_loop - a fire-and-smoke effect played on and oriented to a character’s torso.  This is a looping effect.  Use this for secondary or non-focus characters.  You could use about three or four of these for the price of one fx_fire_player_torso.  This effect will have to be stopped manually, though.
*/

run_off_and_delete( node_str, name_of_spawner )
{
	//Bowman and brooks to run off now
	node_to_run_to = getnode( node_str, "targetname" );
	self setgoalnode( node_to_run_to );
	self waittill( "goal" );
	self Delete();
	
	//Increment spawner
	spawner = GetEnt( name_of_spawner, "targetname" );
	spawner.count++;
}

no_sympathy_woods()
{
	self waittill( "goal" );
	flag_set( "NOSYMPATHY_SCENE_WOODS_AT_GOAL" );
	flag_wait( "NOSYMPATHY_SCENE_WEAVER_AT_GOAL" );
	
	anim_node = get_anim_struct( "15" );
	anim_node thread anim_single_aligned( self, "nosympathy" );
	//wait( 0.1 );
	//println( "nosympathy = " + self.animname + " = " + self.origin );
	anim_node waittill( "nosympathy" );
	self setgoalpos( (-9722.91, 4384.1, 120.674) );
	self waittill( "goal" );
	
	//Bowman and brooks to run off now
	level.bowman thread run_off_and_delete( "bowman_in_tunnel_start", "bowman" );
	level.brooks thread run_off_and_delete( "brooks_in_tunnel_start", "brooks" );
	
	//Move to the start of the steam reactions anim
	anim_node = get_anim_struct( "16a" );

	anim_node thread anim_single_aligned( self, "steamreactions" );
	//wait( 0.1 );
	//println( "steamreactions = " + self.animname + " = " + self.origin );
	anim_node waittill( "steamreactions" );
	self setgoalpos( self.origin );
	
	//Then go to the tunnel start node
	weaver_in_tunnel_start = getnode( "woods_in_tunnel_start", "targetname" );
	self setgoalnode( weaver_in_tunnel_start );	
}

no_sympathy_weaver()
{
	self waittill( "goal" );
	flag_set( "NOSYMPATHY_SCENE_WEAVER_AT_GOAL" );
	flag_wait( "NOSYMPATHY_SCENE_WOODS_AT_GOAL" );

	anim_node = get_anim_struct( "15" );
	anim_node thread anim_single_aligned( self, "nosympathy" );
	//wait( 0.1 );
	//println( "nosympathy = " + self.animname + " = " + self.origin );
	anim_node waittill( "nosympathy" );
	self setgoalpos( (-9745.17, 4393.74, 119.851) );
	self waittill( "goal" );
	
	//Move to the start of the steam reactions anim
	anim_node = get_anim_struct( "16a" );
	anim_node thread anim_single_aligned( self, "steamreactions" );
	//wait( 0.1 );
	//println( "steamreactions = " + self.animname + " = " + self.origin );
	anim_node waittill( "steamreactions" );
	self setgoalpos( self.origin );
	
	//Then go to the tunnel start node
	weaver_in_tunnel_start = getnode( "weaver_in_tunnel_start", "targetname" );
	self setgoalnode( weaver_in_tunnel_start );
}

no_sympathy_anims()
{
	event9_triggers_nosympathy_trig = getent( "start_dialog_nosympathy", "targetname" );
	event9_triggers_nosympathy_trig waittill( "trigger" );
	
	level.brooks thread playVO_proper( "poorbast", 0.0 );		//Poor bastards...
	level.woods thread playVO_proper( "nazibast", 1.0 );		//They're Nazi bastards... They don't deserve sympathy.
	level.woods thread playVO_proper( "huntemdown", 3.0 );		//We're here to hunt 'em down.
	
// 	level.scr_sound["woods"]["gettotunnel"] = "vox_fla1_s08_162A_wood_m"; //Get to the tunnels!
//     level.scr_sound["weaver"]["thisway"] = "vox_fla1_s08_193A_weav"; //This way...
//     level.scr_sound["brooks"]["poorbast"] = "vox_fla1_s08_194A_broo"; //Poor bastards...
//     level.scr_sound["woods"]["nazibast"] = "vox_fla1_s08_195A_wood_m"; //They're Nazi bastards... They don't deserve sympathy.
//     level.scr_sound["woods"]["huntemdown"] = "vox_fla1_s08_196A_wood_m"; //We're here to hunt 'em down.
//     level.scr_sound["weaver"]["tryingtoesc"] = "vox_fla1_s08_197A_weav_m"; //The rest of the Ascension group will be trying to escape the facility...
//     level.scr_sound["woods"]["flankround"] = "vox_fla1_s08_198A_wood_m"; //Bowman, Brooks. You flank round to the North tunnel. No one sneaks out that back door!
//     level.scr_sound["woods"]["withme"] = "vox_fla1_s08_200A_wood_m"; //Mason and Weaver, you're on me.
// 	
	//level.woods thread no_sympathy_woods();
	//level.weaver thread no_sympathy_weaver();
}

start_dialog_splitup()
{
	start_dialog_splitup_trig = getent( "start_dialog_splitup", "targetname" );
	start_dialog_splitup_trig waittill( "trigger" );
	start_dialog_splitup_trig Delete();	

	level.weaver thread playVO_proper( "tryingtoesc", 0.0 );		//The rest of the Ascension group will be trying to escape the facility...
	level.woods thread playVO_proper( "flankround", 3.0 );		//Bowman, Brooks. You flank round to the North tunnel. No one sneaks out that back door!
	level.woods thread playVO_proper( "withme", 5.0 );		//Mason and Weaver, you're on me.
	
	//TUEY setmusicstate INFILTRATE BASE
	setmusicstate ("INFILTRATE_BASE");
	
	
	Objective_Set3D( level.obj_num, false );
	Objective_State( level.obj_num, "done" );
	
	//level.obj_num++;		//skip destroy soyuz 2
	
	//level.obj_num++;
	double_door_obj = getstruct( "double_door_obj", "targetname" );
	Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_FIND_DRAGOVICH" );
	Objective_Position(level.obj_num, double_door_obj.origin );
	objective_set3d( level.obj_num, true );
	
}

play_slide_anim( ai )
{
	ai endon( "slide_done" );
	while( 1 )
	{
		self waittill( "trigger", who );
	
		//Play anim
		if( who==ai )
		{
			ai anim_single( ai, "slidebeneath" );
			ai notify( "slide_done" );
		}
		wait( 0.05 );
	}	
}

play_jump_anim( ai )
{
	ai endon( "jump_done" );
	while( 1 )
	{
		self waittill( "trigger", who );
	
		//Play anim
		if( who==ai )
		{
			ai anim_single( ai, "jumpoverfire" );
			ai notify( "jump_done" );
		}
		wait( 0.05 );
	}	
}


damage_triggers_turn_on()
{
	rocket_fire_damage_trigger = getent( "rocket_fire_damage", "targetname" );
	rocket_fire_damage_trigger trigger_on();
}


go_into_tunnel_check()
{
	event9_triggers_into_tunnel = getent( "event9_triggers_into_tunnel", "script_noteworthy" );
	event9_triggers_into_tunnel waittill( "trigger" );
	flag_set( "GO_INTO_TUNNEL" );
}


assult_course_to_goal_node( end_goal_node, in_tunnel_goal )
{
	slide_node_start = getnode( "slide_node_start", "targetname" );
	jump_node_start = getnode( "jump_node_start", "targetname" );
	
	jump_debris_align = getstruct( "jump_debris_align", "targetname" );
	jump_debris_align.angles = (0.0,0.0,0.0);

	slide_node_start anim_reach_aligned( self, "slidebeneath" );
	slide_node_start anim_single_aligned( self, "slidebeneath" );
	
	jump_debris_align anim_reach_aligned( self, "jumpoverfire" );
	jump_debris_align anim_single_aligned( self, "jumpoverfire" );
	
	self setgoalnode( end_goal_node );
	self waittill( "goal" );
	
	flag_wait( "GO_INTO_TUNNEL" );
	self setgoalnode( in_tunnel_goal );
}


assult_course_to_goal_node_and_delete( end_goal_node, in_tunnel_goal )
{
	slide_node_start = getnode( "slide_node_start", "targetname" );
	jump_node_start = getnode( "jump_node_start", "targetname" );
	
	jump_debris_align = getstruct( "jump_debris_align", "targetname" );
	jump_debris_align.angles = (0.0,0.0,0.0);

	slide_node_start anim_reach_aligned( self, "slidebeneath" );
	slide_node_start anim_single_aligned( self, "slidebeneath" );
	
	jump_debris_align anim_reach_aligned( self, "jumpoverfire" );
	jump_debris_align anim_single_aligned( self, "jumpoverfire" );
	
	self setgoalnode( end_goal_node );
	self waittill( "goal" );
	
	flag_wait( "GO_INTO_TUNNEL" );
	self setgoalnode( in_tunnel_goal );
	
	self waittill( "goal" );
	self Delete();
}


wall_smash_slide()
{
	start_moving_trig = getent( "event9_triggers_startmoving", "script_noteworthy" );
	start_moving_trig waittill( "trigger" );
	
	//Everybody go!
	woods_outsidetunnels_node = getnode( "woods_outsidetunnels", "targetname" );
	weaver_outsidetunnels_node = getnode( "weaver_outsidetunnels", "targetname" );
	brooks_outsidetunnels_node = getnode( "brooks_outsidetunnels", "targetname" );
	bowman_outsidetunnels_node = getnode( "bowman_outsidetunnels", "targetname" );
	
	woods_in_tunnel_start_node = getnode( "woods_in_tunnel_start", "targetname" );
	weaver_in_tunnel_start_node = getnode( "weaver_in_tunnel_start", "targetname" );
	brooks_in_tunnel_start_node = getnode( "brooks_in_tunnel_start", "targetname" );
	bowman_in_tunnel_start_node = getnode( "bowman_in_tunnel_start", "targetname" );
	
	level.woods thread assult_course_to_goal_node( woods_outsidetunnels_node, woods_in_tunnel_start_node );
	wait( 0.50 );
	level.weaver thread assult_course_to_goal_node( weaver_outsidetunnels_node, weaver_in_tunnel_start_node );
	wait( 1.5 );
	level.bowman thread assult_course_to_goal_node_and_delete( bowman_outsidetunnels_node, brooks_in_tunnel_start_node );
	wait( 2.0 );
	level.brooks thread assult_course_to_goal_node_and_delete( brooks_outsidetunnels_node, bowman_in_tunnel_start_node );
	
// 	slide_anim_trig thread play_slide_anim( level.woods );
// 	slide_anim_trig thread play_slide_anim( level.weaver );
// 	slide_anim_trig thread play_slide_anim( level.bowman );
// 	slide_anim_trig thread play_slide_anim( level.brooks );
}

// fire_jump()
// {
// 	jump_anim_trig = getent( "jump_anim", "targetname" );
// 	
// 	jump_anim_trig thread play_jump_anim( level.woods );
// 	jump_anim_trig thread play_jump_anim( level.weaver );
// 	jump_anim_trig thread play_jump_anim( level.bowman );
// 	jump_anim_trig thread play_jump_anim( level.brooks );
// }


chunks_a_plenty_1()
{
	chunks_a_plenty_1 = getent( "chunks_a_plenty_1", "targetname" );
	chunks_a_plenty_1 waittill( "trigger" );

	level notify("chunk_debris_01_start");
}

chunks_a_plenty_3()
{
	chunks_a_plenty_3 = getent( "chunks_a_plenty_3", "targetname" );
	chunks_a_plenty_3 waittill( "trigger" );
	chunks_a_plenty_3 Delete();

	level notify("chunk_debris_03_start");
}


wall_smash_start()
{
	wall_smash_trig = getent( "wall_smash", "targetname" );
	wall_smash_trig waittill( "trigger" );
	wall_smash_trig Delete();
	
	level.woods thread playVO_proper( "stayinopen", 0.0 );		//Dammit... Can't stay in the open.
	level.woods thread playVO_proper( "gettotunnel", 2.0 );		//Get to the tunnels!
	
	//level.woods thread playVO_proper( "stayinopen", 1.0 );		//Dammit... Can't stay in the open.
	//level.woods thread playVO_proper( "gettotunnel", 3.0 );		//Get to the tunnels!
	
	wall_smash_audio = getstruct ("evt_debris_wall", "targetname");
	
	level notify( "wall_smash_start" );	
	
	//level notify("chunk_debris_01_start");

	playsoundatposition ("evt_debris_incoming", (wall_smash_audio.origin));

	//playVO( "play_wall_smash_start_exploders", "Woods" );
	exploder( 820 );
	wait( 1.0 );
	
	earthquake( 0.6, 1, level.player.origin,  500 );
	level.player PlayRumbleOnEntity( "damage_heavy");
	
	exploder( 825 );
	playsoundatposition ("evt_debris_hit_wall", (wall_smash_audio.origin));
	level thread play_walldebris_fires();
	wait( 1.0 );
	
	earthquake( 0.6, 1, level.player.origin,  500 );
	level.player PlayRumbleOnEntity( "damage_heavy");
	
	exploder( 830 );

	
}
play_walldebris_fires()
{
	fires = getentarray ("amb_fire_debris", "targetname");	
	for(i=0;i<fires.size;i++)
	{
		fires[i] thread play_walldebris_fire();
	}	
	
}
play_walldebris_fire()
{
	self playloopsound (self.script_sound);	
	
}
rocket_debris_fire_start()
{
	rocket_debris_fire_trig = getent( "rocket_debris_fire", "targetname" );
	rocket_debris_fire_trig waittill( "trigger" );
	falling_debris_audio = getstruct ("evt_debris_fall");
	
	level notify( "rocket_debris_fire_start" );	
	wait( 0.8 );
	playsoundatposition ("evt_flashpoint_particle_imp_lg", falling_debris_audio.origin);
	level thread play_fallingdebris_fires();
	exploder( 835 );
	
	earthquake( 0.6, 1, level.player.origin,  500 );
	level.player PlayRumbleOnEntity( "damage_heavy");
	
	//level waittill("chunk_debris_03_start");
}
play_fallingdebris_fires()
{
	fires = getentarray ("amb_fire_debris_two", "targetname");	
	for(i=0;i<fires.size;i++)
	{
		fires[i] thread play_fallingdebris_fire();
	}	
	
}
play_fallingdebris_fire()
{
	self playloopsound (self.script_sound);			
	
}

// Knock Player Down
// 
// Suggested use of this shellshock, you can use whatever you like.
//                 PreCacheShellShock("quagmire_window_break");
// 
// Self = player
knock_player_down()
{
	self endon( "death" );
	self endon( "disconnect" );

	self ShellShock("quagmire_window_break", 1.5);
	self PlayRumbleOnEntity("explosion_generic");
	Earthquake( 0.6, 0.5, self.origin, 1000, self );

//	self DisableWeapons();

//	self AllowAds( false );
//	self AllowSprint( false );
//	self AllowJump( false );
//	self AllowStand( false ); 
//	self AllowProne( false );

//	self SetStance("crouch");
//	self AllowCrouch( false );
//	self FreezeControls(true);

//	wait( 0.35 );

//	self EnableWeapons();
//	self FreezeControls(false);
//
//	self AllowAds( true );
//	self AllowSprint( true );
//	self AllowJump( true );
//	self AllowCrouch( true );
//	self AllowStand( true ); 
//	self AllowProne( true );

//	self SetStance("stand");
}


lights_falling_over()
{
	//maps/flashpoint/fx_tower_light_exp – a large electrical explosion for the stadium lights.
	
//	falling_light_trig = GetEnt( "falling_light", "targetname" );
//	falling_light_trig waittill( "trigger" );
//	falling_light_trig Delete(); //shabs - save	ent

	trigger_wait( "chunks_a_plenty_1" );
	
	wait( 1 );
	
	exploder( 846 );
	
	earthquake( 0.6, 1, level.player.origin,  500 );
	level.player PlayRumbleOnEntity( "damage_heavy");
		
	
	flash_lighttower_mod_original = getent( "flash_lighttower_mod_original", "targetname" );
	flash_lighttower_mod_original hide();	

	fxanim_flash_lighttower_mod = getent( "fxanim_flash_lighttower_mod", "targetname" );
	fxanim_flash_lighttower_mod show();
	fxanim_flash_lighttower_mod playsound ("evt_light_tower_fall_start");
	
	level notify( "lighttower_start" );
	stop_exploder( 121 );	// The running stadium lights
	//A fiery trail that attaches to top_rocket_jnt.  It should continue to play until the rocket top crashes to the ground.
	playfxontag(level._effect["light_tower_exp"], self, "tag_fx_lights"); // Replaced with exploder 804.
	
	wait( 2.5 );
	
	exploder( 805 );
	
	wait (0.5);
	fxanim_flash_lighttower_mod playsound ("evt_light_tower_fall_impact");

	level.player thread knock_player_down();
	//earthquake( 0.6, 1, level.player.origin,  1000 );
	//level.player PlayRumbleOnEntity( "damage_heavy");
	
	
	//dust impact from falling tower light – I have no idea where or if the light tower is 
	//going to be falling down, so I placed an exploder in a likely impact point.  I’ll move it if or when the 
	//impact point is determined.  Trigger exploder ID 805 when the tower hits the ground.
}








play_exploders()
{
	wait( 1.0 );
	//playVO( "play_aftermath_exploders", "Woods" );
	exploder( 840 );
	wait( 0.1 );
	exploder( 841 );
	wait( 0.1 );
	exploder( 842 );
	wait( 0.1 );
	exploder( 843 );
	wait( 0.1 );
	exploder( 844 );
	wait( 0.1 );
	exploder( 845 );
	//wait( 0.1 );
	//exploder( 846 );
}


rotateFans()
{
	level endon( "BEGIN_EVENT13" );
	
	fan_ents[0] = getent( "fan1", "targetname" );
	fan_ents[1] = getent( "fan2", "targetname" );
	fan_ents[2] = getent( "fan3", "targetname" );
	fan_ents[3] = getent( "fan4", "targetname" );
	fan_ents[4] = getent( "fan5", "targetname" );
	fan_ents[5] = getent( "fan6", "targetname" );
	
	while( 1 )
	{
		for( i=0;i<6; i++ )
		{
			fan_ents[i] rotateto(fan_ents[i].angles + (0.0,100.0,0.0), 0.25);
		}
		wait( 0.25 );
	}
}

end_of_tunnels_movies()
{
	level endon( "BEGIN_EVENT13" );
	
	flashback_1_trig = getent( "flashback_1", "targetname" );
	flashback_1_trig waittill( "trigger" );
	
//	wait( 5.0 );
	
	//Start playing the flashback movies
	min_time = 2.0;
	max_time = 4.0;
	
	play_count = 0;
	
	while( 1 )
	{
		level flashback_movie_play( 1.0 );
		play_count = play_count + 1;
		wait RandomFloatRange(min_time, max_time);
		
		if( play_count > 2 )
		{
			//more frequent
			min_time = 1.0;
			max_time = 3.0;
		}
		
		if( play_count > 4 )
		{
			//more frequent
			min_time = 1.0;
			max_time = 2.0;
		}
	}
}



fire_damage()
{
	while(1)
	{
		if(level.player isTouching(self))
		{
			level.player DoDamage(15, level.player.origin);
		}	
		wait(0.1);
	}
}

fire_damage_setup()
{
	triggers = getentarray("trigger_fire_hurt", "targetname");
	for(i=0; i<triggers.size; i++)
	{
		triggers[i] thread fire_damage();
	}
}


water_drop_touch_trig() //self == player
{
	trig_water_drops = GetEnt( "trig_water_drops", "targetname" );
	
	drops_on = false;
	prev_drops_on = false;
	
	while( 1 )
	{
		if( self IsTouching( trig_water_drops ) )
		{
			drops_on = true;
		}
		else
		{
			drops_on = false;
		}

		//Turn the drops on
		if( drops_on && !prev_drops_on )
		{
			self SetWaterDrops( 50 );
		}
		
		//Turn the drops off
		if( prev_drops_on && !drops_on )
		{
			self SetWaterDrops( 0 );
		}
			
		prev_drops_on = drops_on;
		wait( 0.1 );	
	}
}



event9_SceneFromHell()
{
/*
 The initial read should look like a scene from hell
 Scalding hot steam blasting from damaged pipes (squad anims & Player need to avoid)
 Fires burning everywhere from the spilled rocket fuel (like WTC with aviation fuel)
 A huge chunk of rocket engine sticking through the ceiling
 Wires dangling from the engine, sparking
 Debris everywhere and a mangled body or two
 etc…
*/
	autosave_after_delay(2.0, "flashpoint_e9");
	//autosave_by_name("flashpoint_e9");
	//level thread end_of_tunnels_movies();
	level thread rotateFans();
	level thread tunnels_start_save_point();
	level thread on_fire_scientist();
	level thread no_sympathy_anims();
	level thread start_dialog_splitup();
	level thread lift_start_trigger();
	level thread lift_drop_trigger();
	level thread fire_damage_setup();
	level.player thread water_drop_touch_trig();
	exploder( 121 );	// turn on the stadium lights if they're not on
	
	level thread damage_triggers_turn_on();
	
	difficulty_adjustments();
	
	level.woods.ignoreall = true;
	level.weaver.ignoreall = true;
	level.bowman.ignoreall = true;
	level.brooks.ignoreall = true;
	
	level thread rocket_debris_fire_start();
	level thread wall_smash_slide();
	level thread go_into_tunnel_check();
	//level thread fire_jump();
	level thread wall_smash_start();
	level thread play_exploders();
	level thread chunks_a_plenty_1();
	level thread chunks_a_plenty_3();
	
	level thread tunnel_spawn_funcs();

	//SHABS threads
	level thread glass_room_tunnel_engagements();

	//Set objective to follow Woods
	//Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_FOLLOW_WOODS", level.woods );
	//Objective_Set3D( level.obj_num, true, "yellow", "Follow" );
	
	level.obj_num++;
	Objective_Add( level.obj_num, "current",  &"FLASHPOINT_OBJ_ASSASSINATE_SCIENTISTS", level.woods );
	Objective_Set3D( level.obj_num, true, "yellow", &"FLASHPOINT_OBJ_FOLLOW" );
	
	
	
//	The new Rollup Door good is targetname: blastdoor_good
//The new Damaged Roll Up Door is targetname: blastdoor


	//Hide the good blastdoor and show the damaged version
	blastdoor_good = getent( "blastdoor_good", "targetname" );
	blastdoor_good Delete();

	//Show the destroyed blastdoor's
	blastdoor = getentarray( "blastdoor", "targetname" );
	for (i = 0; i < blastdoor.size; i++)
	{
		blastdoor[i] show();
	}
	
	//Use blocker to stop player backtracking through rocket
	launchpad_blocker = getentarray( "launchpad_blocker", "targetname" );
	for( i=0; i<launchpad_blocker.size; i++ )
	{
		launchpad_blocker[i] Solid();
	}
	
	tunnel_door_blocker = getent( "tunnel_door_blocker", "targetname" );
	tunnel_door_blocker NotSolid();
	
	//Lights falling over
	fxanim_flash_lighttower_mod = getent( "fxanim_flash_lighttower_mod", "targetname" );
	fxanim_flash_lighttower_mod thread lights_falling_over();

	//Goto next event
	//flag_set("BEGIN_EVENT10");
	
	flag_set( "start_glass_room" );

//	event9_GlassRoomFight();
}


/////////////////
///	GLASS ROOM AND ON...
//////////////////////
glass_room_tunnel_engagements()
{

	flag_wait( "start_glass_room" );

	//setup control path extras
	level thread end_extra_control_room();
	level thread extra_control_room();

	//setup locker path extras
	level thread end_extra_locker_room();
	level thread extra_locker_room();

	//Running scientists
	level thread setup_scientist_runners();
	//Weaver Anim
	level thread weaver_vomit_anim();

	level thread one_handed_trig();

	trig_spawn_glass_room = trigger_wait( "trig_spawn_glass_room" );
	trig_spawn_glass_room Delete();
	
	simple_spawn( "glass_room_guys", ::force_goal_self ); //5 AI
	//level thread monitor_glass_room_color_chain();

/////////////////
///	FIRST HALL
//////////////////////
	trig_spawn_first_hallway = GetEnt( "trig_spawn_first_hallway", "script_noteworthy" );
	trig_spawn_first_hallway waittill( "trigger" );
	trig_spawn_first_hallway Delete();

	spawn_manager_disable( "trig_rs_glass_room" );
	spawn_manager_enable( "trig_rs_first_hall" );

	simple_spawn( "first_hall_guys", ::force_goal_self ); //7 AI
	//simple_spawn( "first_hall_rusher", ::make_me_a_rusher ); //2 AI
	//level thread monitor_spawn_first_color_chain();

/////////////////
///	CONTROL ROOM SCIENTISTS
//////////////////////

	//shabs - removed duplicate script call to spawn these guys
	//simple_spawn( "sci_glass_room", ::not_so_smart_now_control_room );

/////////////////
///	SECOND HALL
//////////////////////
	trig_spawn_second_hall = trigger_wait( "trig_spawn_second_hall" );
	trig_spawn_second_hall Delete();

	spawn_manager_disable( "trig_rs_first_hall" );
	spawn_manager_enable( "trig_rs_second_hall" );

	simple_spawn( "second_hall_guys", ::force_goal_self  );
	//simple_spawn_single( "second_hall_rusher", ::make_me_a_rusher );
	level thread monitor_second_hall_color_chain();
	
	//TUEY change the music up
//	setmusicstate("IN_BASE");

/////////////////
///	WINDOW JUMPER
//////////////////////
	trig_spawn_window_jumper = trigger_wait( "trig_spawn_window_jumper" );

	window_jumper = simple_spawn_single( "window_jumper" );

	goal_node = GetNode( window_jumper.target, "targetname" );
	window_jumper thread force_goal( goal_node, 64 );

/////////////////
///	STEAM RUSHERS
//////////////////////
	trig_spawn_steam_squad = trigger_wait( "trig_spawn_steam_squad" );
	trig_spawn_steam_squad Delete();
	

	//start streamer hint with krav in animation
	//level.streamHintEnt_heli_pad = createStreamerHint( (432, 1376, 424), 2 ); //heli pad

	heli_pad_kravchenko = simple_spawn_single( "heli_pad_kravchenko" );
	heli_pad_kravchenko.animname = "krav_slide";

	anim_node = get_anim_struct_no_angles_2( "diorama_06_align_struct" );
	anim_node thread anim_first_frame( heli_pad_kravchenko, "diorama06" );

	spawn_manager_disable( "trig_rs_second_hall" ); //disable spawn manager


/////////////////
///	DELETE ALL BEFORE RUSHERS
//////////////////////
	ai_array = GetAIArray( "axis" );
	for(i = ai_array.size - 1; i >= 0; i-- )
	{
			ai_array[i] Die();
	}

	//steam_rushers_back = simple_spawn_single( "steam_rushers_back" );
	steam_rusher_left_crouch = simple_spawn_single( "steam_rusher_left_crouch" );
	steam_rushers_right = simple_spawn_single( "steam_rushers_right" );
	steam_rushers_front = simple_spawn_single( "steam_rushers_front", ::force_goal_self );

	waittill_ai_group_cleared( "steam_rushers" );
	
	level.streamHintEnt_heli_pad = createStreamerHint( heli_pad_kravchenko get_eye(), 10 ); //heli pad
	trigger_use( "color_last_tunnel" );

	battlechatter_off( "axis" );
	battlechatter_off( "allies" );

	///START WEAVER VOMIT ANIM
	flag_set( "start_weaver_vomit" );

//	Objective_State( level.obj_num, "done" );
	Objective_Set3D( level.obj_num, false );

//	double_door_obj = getstruct( "double_door_obj", "targetname" );
//	Objective_AdditionalPosition( level.obj_num, 0, double_door_obj );
//	Objective_Set3D( level.obj_num, true );

//	Objective_Position(level.obj_num, double_door_obj.origin );
//	objective_set3d(level.obj_num, true);
	
	
// 	Objective_Set3D( level.obj_num, false );
// 	
// 	level.obj_num++;		//skip destroy soyuz 2
// 	
// 	level.obj_num++;
// 	Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_FIND_DRAGOVICH" );
// 	Objective_Position(level.obj_num, double_door_obj.origin );
// 	objective_set3d( level.obj_num, true );

/////////////////
///	TURN ON PLAYER DOOR ANIMATION
//////////////////////
	//trig_player_open_door trigger_on();	
	//trig_player_open_door waittill( "trigger" );

	//objective_set3d(level.obj_num, false);

//	level.player thread maps\flashpoint_anim::ending_doors_playeranim();
//
//	flag_wait( "player_door_anim_done" );

//	if( IsDefined(level.bowman) && IsAlive(level.bowman) )
//	{
//		level.bowman Delete();
//	}
//	if( IsDefined(level.brooks) && IsAlive(level.brooks) )
//	{
//		level.brooks Delete();
//	}
//	if( IsDefined(level.woods) && IsAlive(level.woods) )
//	{
//		level.woods Delete();
//	}
//	if( IsDefined(level.weaver) && IsAlive(level.weaver) )
//	{
//		level.weaver Delete();
//	}	

	flag_wait( "end_weaver_vomit" );
	
//	white_fade_out( 0.05, "white" );
	//flashback_movie_play( 1.0 );
	//maps\flashpoint_e13::whiteout(0.05); //self == level 
 	//Goto next event
	//flashback_movie_play( 1.0 );
	flag_set( "setup_slides" );
	
	//FOR AUDIO
	clientNotify ("slides");


}



get_anim_struct_no_angles_2( name )
{	
	anim_struct = getstruct( name, "targetname" );
	anim_struct.angles = (0.0,0.0,0.0);
	return anim_struct;
}

/*
maps/flashpoint/fx_vomit_projectile – vomit effect for when Weaver throws up.  
Attach to the mouth tag and aim +X away from his face.  It will fall in world 
space.  Ideally, Weaver will move very little while he’s throwing up.  The 
effect projects for ~0.5 seconds, but it lasts about 11 seconds (including 
stuff left over on the floor).  I may have to adjust the effect if it doesn’t 
come out of his mouth properly.
*/


	
weaver_vomit_anim()
{
	flag_wait( "start_weaver_vomit" );
	
	setmusicstate ("SLIDES");

	//fake kravchenko for slides
	level.fake_slide_krav = simple_spawn_single( "fake_slide_krav", ::init_fake_slide_krav );
	level.fake_slide_woods = simple_spawn_single( "fake_slide_woods", ::init_fake_slide_woods );

	//level.streamHintEnt_heli_pad = createStreamerHint( (432, 1368, 424), 1 ); //heli pad
	level.fake_slide_heli_woods = simple_spawn_single( "fake_slide_heli_woods", maps\flashpoint_e13::init_fake_slide_heli_woods );
	level.fake_slide_heli_krav = simple_spawn_single( "fake_slide_heli_krav", maps\flashpoint_e13::fake_slide_heli_krav );

	anim_node = get_anim_struct( "new_weavervomit_node" );
	anim_node anim_reach_aligned( level.weaver, "new_vomit" );

	flag_set( "start_slide_vo" );
	flag_set("BEGIN_EVENT13");

	anim_node thread anim_single_aligned( level.weaver, "new_vomit" );
	anim_time = GetAnimLength( level.scr_anim[level.weaver.animname]["new_vomit"] );
	wait(anim_time - 1);
	//anim_node waittill("new_vomit");
	flag_set( "end_weaver_vomit" );
}

init_fake_slide_krav()
{
	self endon( "death" );

	self.name = "";
	self gun_remove();
	self disable_pain();
	self disable_react();
	self.ignoreme = true;	
	self.ignoreall = true;
	self thread magic_bullet_shield();
//	self Hide();
}

init_fake_slide_woods()
{
	self endon( "death" );

	self thread maps\flashpoint_e13::init_gr_woods();

	self.name = "";
	self gun_remove();
	self disable_pain();
	self disable_react();
	self.ignoreme = true;	
	self.ignoreall = true;
	self thread magic_bullet_shield();
//	self Hide();
}

tunnel_spawn_funcs()
{
	steam_rushers = GetEntArray( "steam_rushers", "script_noteworthy" );
	array_thread( steam_rushers, ::add_spawn_function, ::make_me_a_rusher );
}

make_me_a_rusher()
{
	self endon( "death" );

	self maps\_rusher::rush();
}

/////////////////
///	Scientist Runners
//////////////////////
setup_scientist_runners()
{
	one_handed_trig = trigger_wait( "one_handed_trig" );
	one_handed_trig Delete();

	//deletes scientist runners or kills them
	simple_spawn( "sci_glass_room", ::not_so_smart_now );

	trig_spawn_control_room_sci = trigger_wait( "trig_spawn_control_room_sci" );
	trig_spawn_control_room_sci Delete();

	//deletes scientist runners or kills them
	simple_spawn( "sci_control_room", ::not_so_smart_now );

	trig_spawn_window_jumper = trigger_wait( "trig_spawn_window_jumper" );
	trig_spawn_window_jumper Delete();

	//deletes scientist runners or kills them
	simple_spawn( "not_so_luckly_scientists", ::not_so_smart_now );

	start_magic_bullet_glass = getstruct( "start_magic_bullet_glass", "targetname" );
	end_magic_bullet_glass = getstruct( start_magic_bullet_glass.target, "targetname" );
	
	wait( 1.1 );

	MagicBullet( "ak47_sp", start_magic_bullet_glass.origin, end_magic_bullet_glass.origin );
	MagicBullet( "ak47_sp", start_magic_bullet_glass.origin, end_magic_bullet_glass.origin );
	MagicBullet( "ak47_sp", start_magic_bullet_glass.origin, end_magic_bullet_glass.origin );

}

/////////////////
///	EXTRA SPAWNERS IN CONTROL ROOM
//////////////////////
extra_control_room()
{
	level endon( "end_extra_control_room" );
	trig_spawn_extra_cr = trigger_wait( "trig_spawn_extra_cr" );
	trig_spawn_extra_cr Delete();
	extra_control_room_guy = simple_spawn( "extra_control_room_guy", ::force_goal_self );
}

force_goal_self()
{
	self endon( "death" );
	goal_node = GetNode( self.target, "targetname" );
	self thread force_goal( goal_node, 64 );
}

end_extra_control_room()
{
	end_extra_control_room = trigger_wait( "end_extra_control_room" );
	end_extra_control_room Delete();
	level notify( "end_extra_control_room" );
}

/////////////////
///	EXTRA SPAWNERS IN LOCKER ROOM
//////////////////////
extra_locker_room()
{
	level endon( "end_extra_locker_room" );
	trig_spawn_extra_locker_room = trigger_wait( "trig_spawn_extra_locker_room" );
	trig_spawn_extra_locker_room Delete();
	extra_locker_room_guy = simple_spawn( "extra_locker_room_guy", ::force_goal_self );
}

end_extra_locker_room()
{
	end_extra_locker_room = trigger_wait( "end_extra_locker_room" );
	end_extra_locker_room Delete();
	level notify( "end_extra_locker_room" );
}

//monitor_glass_room_color_chain()
//{
//	waittill_ai_group_cleared( "glass_room_guys" );
//	spawn_manager_disable( "trig_rs_glass_room" ); //disable spawn manager
//	
//	color_glass_room = GetEnt( "color_glass_room", "targetname" );
//	if( IsDefined( color_glass_room ) )
//	{
//		//trigger_use( "color_glass_room" );
//		color_glass_room notify( "trigger" );
//	}
//
//}
//
//monitor_spawn_first_color_chain()
//{
//	waittill_ai_group_cleared( "first_hall_guys" );
//	spawn_manager_disable( "trig_rs_first_hall" ); //disable spawn manager
//
//	color_first_hallway_1 = GetEnt( "color_first_hallway_1", "targetname" );
//	if( IsDefined( color_first_hallway_1 ) )
//	{
//		//trigger_use( "color_first_hallway_1" );
//		color_first_hallway_1 notify( "trigger" );
//	}
//
//	color_first_hallway_2 = GetEnt( "color_first_hallway_2", "targetname" );
//	if( IsDefined( color_first_hallway_2 ) )
//	{
//		//trigger_use( "color_first_hallway_2" );
//		color_first_hallway_2 notify( "trigger" );
//	}
//
//}

monitor_second_hall_color_chain()
{
	waittill_ai_group_cleared( "second_hall_guys" );
	spawn_manager_disable( "trig_rs_second_hall" ); //disable spawn manager

	color_second_hallway = GetEnt( "color_second_hallway", "targetname" );
	if( IsDefined( color_second_hallway ) )
	{
		//trigger_use( "color_second_hallway" );
		color_second_hallway notify( "trigger" );
	}

}

/////////////////
///	One Handed Shooter Guy
//////////////////////	
#using_animtree("animated_props");
table_flip( anim_node )
{
	//level waittill( "FLIP_TABLE" );
	level waittill("flip_table_start");
	level notify( "table_throw_01_start" );
	

	table_throw_01 = GetEnt( "table_throw_01", "targetname" );
	//Flip up sound
	table_throw_01 PlaySound( "evt_table_tip" );

	tablecoll_pre = getent( "tablecoll_pre", "targetname" );
	tablecoll_pre Delete();
	tablecoll_post = getent( "tablecoll_post", "targetname" );
	tablecoll_post Solid();
 
 	//Open door trigger and the doors to open
// 	table_to_flip = getent( "table_throw_01", "targetname" );
// 	table_to_flip_model = spawn("script_model",table_to_flip.origin);
// 	table_to_flip_model.angles = table_to_flip.angles;
// 	table_to_flip_model setmodel("tag_origin_animate");
// 	table_to_flip_model.animname = "table_to_flip";	
// 	table_to_flip_model useanimtree(level.scr_animtree["table_to_flip"]);
// 	
// 	// link the door to the 'tag_origin_animate' model
// 	table_to_flip linkto( table_to_flip_model,"origin_animate_jnt" );
//  	
//  	anim_node thread anim_first_frame( table_to_flip_model, "flip" );
// 
// 	level waittill( "FLIP_TABLE" );
// 	anim_node thread anim_single_aligned( table_to_flip_model, "flip" );
}

#using_animtree("generic_human");
one_handed_trig()
{
	trig_spawn_onehanded_guy = trigger_wait( "trig_spawn_onehanded_guy" );
	trig_spawn_onehanded_guy Delete(); 

 	anim_node = get_anim_struct( "17" );

	onehanded_ai = simple_spawn_single( "one_handed", ::setup_one_handed_ai );

	onehanded_ai thread table_flip_setup( anim_node );

 	level thread table_flip( anim_node );
 	
 	anim_node thread anim_first_frame( onehanded_ai, "onehanded" );
 	
// 	table_flip_trig = trigger_wait( "table_flip_trig" );
//	table_flip_trig Delete();
	
	trigger_wait( "one_handed_trig" );
	
	spawn_manager_enable( "trig_rs_glass_room" );

//	if( isdefined(onehanded_ai) && isalive(onehanded_ai) )
//	{
//		//one_handed_trig = trigger_wait( "one_handed_trig" );
//		level notify( "FLIP_TABLE" );
//		
//		//active count - 2
//		spawn_manager_enable( "trig_rs_glass_room" );
//		
// 		anim_node thread anim_single_aligned( onehanded_ai, "onehanded" );
//		anim_node waittill( "onehanded" );
//		
//		one_handed_node = GetNode( "one_handed_node", "targetname" );
//
//		onehanded_ai SetGoalNode( one_handed_node );
//
//		//onehanded_ai setgoalpos( onehanded_ai.origin );
//		onehanded_ai.goalradius = 256;
//	}
}

table_flip_setup( anim_node )
{
	self endon( "death" );

	trigger_wait( "one_handed_trig" );

	//one_handed_trig = trigger_wait( "one_handed_trig" );
	level notify( "FLIP_TABLE" );
	
	//active count - 2
	//spawn_manager_enable( "trig_rs_glass_room" );
	
	anim_node thread anim_single_aligned( self, "onehanded" );
	anim_node waittill( "onehanded" );

	table_throw_01 = GetEnt( "table_throw_01", "targetname" );
	//Table landing sound
	table_throw_01 PlaySound( "evt_table_hit" );

	one_handed_node = GetNode( "one_handed_node", "targetname" );

	self SetGoalNode( one_handed_node );

	//onehanded_ai setgoalpos( onehanded_ai.origin );
	self.goalradius = 256;
}

one_handed_push_first_frame( anim_node, anim_name )
{
	anim_node thread anim_first_frame( self, anim_name );
}

one_handed_push( anim_node, anim_name )
{
	anim_node thread anim_single_aligned( self, anim_name );
	//anim_node thread glass_room_table_flip();
	anim_node waittill( anim_name );

	self setgoalpos( self.origin );
	self.goalradius = 256;
}

//glass_room_table_flip()
//{
//
//
//}

setup_one_handed_ai()
{
	self endon("death");

	self.animname = "spetz";
	self.dofiringdeath = false;
	self.ignoreall = false;
	self.noragdoll = false;
	self.goalradius = 32;
	self.allowDeath = true;
	self.ignoresuppression = 1;
	self.grenadeawareness = 0;
}

//deletes scientist or kills them
not_so_smart_now()
{
	self endon( "death" );
	
	self gun_remove();

	self thread setup_fire_scientist();

	goal_node = GetNode( self.target, "targetname" );
	self thread force_goal( goal_node, 64 );
	self waittill( "goal" );

	if ( self CanSee( level.player ) )
	{
		self DoDamage( self.health, self.origin );
	}
	else
	{
		self Die();
	}
}

not_so_smart_now_control_room()
{
	self endon( "death" );

	self gun_remove();

	self thread setup_fire_scientist();

	goal_node = GetNode( self.target, "targetname" );
	self thread force_goal( goal_node, 64 );
	self waittill( "goal" );

	self DoDamage( self.health, self.origin );
}

////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////
