////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL SCRIPTS
//
//
// Script for event 5 - this covers the following scenes from the design:
//		Slides 31-33
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_vehicle;
#include maps\_anim;
#include maps\flashpoint_util;
#include maps\_music;


////////////////////////////////////////////////////////////////////////////////////////////
// EVENT5 FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////

// 
// #using_animtree( "generic_human" );
// contextual_melee_karambit_init()
// {
// 	maps\_contextual_melee::add_melee_sequence( "default", "karambit", "stand", "stand", %int_contextual_melee_karambit, %ai_contextual_melee_karambit );
// 	maps\_contextual_melee::add_melee_sequence( "default", "karambit", "crouch", "stand", %int_contextual_melee_karambit, %ai_contextual_melee_karambit );
// 	maps\_contextual_melee::add_melee_weapon( "default", "karambit", "stand", "stand", "t5_knife_sog" );
// 
// 	maps\_contextual_melee::add_melee_sequence( "default", "neckstab", "stand", "stand", %int_contextual_melee_neckstab, %ai_contextual_melee_neckstab );
// 	maps\_contextual_melee::add_melee_sequence( "default", "neckstab", "crouch", "stand", %int_contextual_melee_neckstab, %ai_contextual_melee_neckstab );
// 	maps\_contextual_melee::add_melee_weapon( "default", "neckstab", "stand", "stand", "t5_knife_sog" );
// 	
// 	maps\_contextual_melee::add_melee_sequence( "default", "neckstab_quick", "stand", "stand", %int_contextual_melee_neckstab_quick, %ai_contextual_melee_neckstab_quick );
// 	maps\_contextual_melee::add_melee_sequence( "default", "neckstab_quick", "crouch", "stand", %int_contextual_melee_neckstab_quick, %ai_contextual_melee_neckstab_quick );
// 	maps\_contextual_melee::add_melee_weapon( "default", "neckstab_quick", "stand", "stand", "t5_knife_sog" );
// }



// int_contextual_melee_neckstab_quick
// ai_contextual_melee_neckstab_quick
// 



// ai_comms_floor1_blue_idle (pushing buttons – loop)
// ai_comms_floor1_blue_idle_2_inspect (to doorway)
// ai_comms_floor1_blue_inspect_idle (Idling, looking towards doorway – loop, in case dialogue is long)
// ai_comms_floor1_blue_inspect_2_idle (back to idle position from doorway check)
// 
// 

setup_comms_guard()
{
	self endon("death");
	self.comms_guard = 1;
	self.dofiringdeath = false;
	self.goalradius = 256;
	self disable_long_death();
	self.ignoreall = false;
	self.dropweapon = true;
	self.allowdeath = true;
}

getcloseto_stairs_trigger()
{
	getcloseto_stairs_trig = getent( "getcloseto_stairs", "targetname" );
	getcloseto_stairs_trig waittill( "trigger" );
	
	flag_set( "FLOOR1_AI_DOWN_STAIRS" );
	
	//level.player notify( "break_stealth" );
	
//  	if( isdefined( level.comms_flr1_blue ) && isalive( level.comms_flr1_blue ) )
//  	{
//  		level.comms_flr1_blue.ignoreall = false;
//  	}
//  	if( isdefined( level.comms_flr1_orange ) && isalive( level.comms_flr1_orange ) )
//  	{
//  		level.comms_flr1_orange.ignoreall = false;
//  	}	
}

getcloseto_stairs()
{
	//level thread getcloseto_stairs_trigger();
	
	//Guard starts to come down stairs
	level.comms_flr1_orange thread guard_runs_up_stairs();
	

	
	//After x sec he shouts something then runs back up
	wait( 5.0 );
	
	//TUEY SET MUSIC STATE TO BASE_MELEE
	setmusicstate("BASE_MELEE");
	
	//TUEY SET MUSIC STATE TO PRE_BASE_FIGHT
	//setmusicstate("PRE_BASE_FIGHT");
	
	
// 	if( isdefined( level.comms_flr1_orange ) && isalive( level.comms_flr1_orange ) )
// 	{
// 		level.comms_flr1_orange thread playVO_proper( "intruders" );	 //(Translated) Intruders!!!
// 		
// 		if( isdefined( level.comms_flr1_blue ) && isalive( level.comms_flr1_blue ) )
// 		{
// 			level.comms_flr1_blue.ignoreall = false;
// 		}
// 	
// 	
// 		if( isdefined( level.comms_flr1_orange ) && isalive( level.comms_flr1_orange ) )
// 		{
// 			level.player thread playVO_proper( "runner", 1.0 );		//We got a runner!
// 		}
// 		
// 		//Player may have killed him by now
// 		wait( 2.0 );
// 		
// 		if( isdefined( level.comms_flr1_orange ) && isalive( level.comms_flr1_orange ) )
// 		{
// 			level.woods thread playVO_proper( "afterhim" );	//Get after him!	
// 		}
// 
// 	}
	
    //TUEY SET MUSIC STATE TO BASE_FIGHT
    setmusicstate("BASE_FIGHT");
	
	//getcloseto_stairs_trig = getent( "getcloseto_stairs", "targetname" );
	//getcloseto_stairs_trig waittill( "trigger" );
	
// 	if( isdefined( level.comms_flr1_blue ) && isalive( level.comms_flr1_blue ) )
// 	{
// 		level.comms_flr1_blue.ignoreall = false;
// 	}
	
	//level.comms_flr1_orange thread guard_runs_up_stairs();
	
	//Toss a grenade down the stairs
	
	//self maps\_grenade_toss::force_grenade_toss(target_org.origin, "frag_grenade_sp", 2.0, undefined, undefined);
	
}

guard_runs_up_stairs()
{
	self endon( "death" );
	
	//level endon( "COMMS_ON_ALERT" );
	//self thread comms_stop_anim_alert();

	anim_node = get_anim_struct( "9" );
	//self.animname = "guard";

 	anim_node thread anim_single_aligned( self, "runs_up_stairs" );
 	wait( 0.1 );
 	println( "guard runs_up_stairs=" + self.origin );
 	anim_node waittill( "runs_up_stairs" );
 	self setgoalpos( self.origin );
 	
 	stairs_runner_node = getnode( "stairs_runner_node", "targetname" );
 	self setgoalnode( stairs_runner_node );
 	self waittill( "goal" );
 	//self.ignoreall = false;
}

check_for_weapon_fire()
{	
	level endon( "ROOF_AI_STAGE2_DEAD" );
	level endon( "check_for_weapon_fire_hit" );

	level.comms_on_alert = false;
	while( 1 )
	{
		self waittill_any( "weapon_fired", "break_stealth", "grenade_fire" );

		flag_set( "COMMS_ON_ALERT" );
		level.comms_on_alert = true;
		
		//Alert everyone!!!!
		ai_array = GetAIArray( "axis" );
		for(i = ai_array.size - 1; i >= 0; i-- )
		{
			if( IsDefined(ai_array[i].animname) && ai_array[i].animname != "sniper" && !isdefined( ai_array[i].dontalert) )
			{
				ai_array[i].ignoreall = false;
				ai_array[i] StopAnimScripted();
			}
		}
		
		//Comms door lines
	    level.comms_flr1_blue thread playVO_proper( "intruders", 1.0 );		//(Translated) Intruders!!!
	    //level.woods thread playVO_proper( "damn_made", 2.0 );				//Damn!... We've been made! 
	    
	    wait( 4.0 );
	    level notify( "check_for_weapon_fire_hit" );
	} 
	
}

comms_stop_anim_alert()
{
	self endon( "death" );
	flag_wait( "COMMS_ON_ALERT" );
	wait( 0.1 );
	self StopAnimScripted();
 	self setgoalpos( self.origin );
}

comms_flr1_blue_anim()
{
	self endon( "death" );
	level endon( "COMMS_ON_ALERT" );
	self thread comms_stop_anim_alert();

	//Get AI into first frame
	anim_node = get_anim_struct( "comm_2" );
	anim_node thread anim_loop_aligned( self, "idle" );
	
	flag_wait( "START_COMMS_AI" );
	
	anim_node thread anim_single_aligned( self, "to_door" );
 	anim_node waittill( "to_door" );
 	
	anim_node thread anim_loop_aligned( self, "door_idle" );
	self thread playVO_proper( "outside", 1.0 );		//(Translated) What is all the noise outside?
	
	wait( 3.0 );
	
	flag_set( "FLOOR1_AI_DOWN_STAIRS" );
	
	anim_node thread anim_single_aligned( self, "from_door" );
 	anim_node waittill( "from_door" );
 	
 	anim_node thread anim_loop_aligned( self, "idle" );
}

comms_flr1_green_anim()
{
	self endon( "death" );
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_1" );
	anim_node thread anim_loop_aligned( self, "idle" );
	
	flag_wait( "COMMS_ON_ALERT" );
	anim_node thread anim_single_aligned( self, "alert" );
 	anim_node waittill( "alert" );
 	self setgoalpos( self.origin );
}

#using_animtree("animated_props");
comms_flr1_green_chair_anim()
{
	self endon( "death" );
	
	chair_ent = getent( "comms_flr1_green_chair", "targetname" );
	chair_ent.animname = "floor1_green_chair";
	chair_ent useAnimTree( #animtree ); 
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_1" );
	anim_node thread anim_loop_aligned( chair_ent, "idle" );
	
	flag_wait( "COMMS_ON_ALERT" );

	anim_node thread anim_single_aligned( chair_ent, "alert" );
 	anim_node waittill( "alert" );
}

#using_animtree( "generic_human" );

comms_flr1_orange_anim_down_stairs( anim_node )
{
	self endon( "death" );
	level endon( "COMMS_ON_ALERT" );
	
	flag_wait( "FLOOR1_AI_DOWN_STAIRS" );
	
 	anim_node thread anim_single_aligned( self, "runs_up_stairs" );
 	anim_node waittill( "runs_up_stairs" );
 	self setgoalpos( self.origin );
}


comms_flr1_orange_anim()
{
	self endon( "death" );
	//level endon( "COMMS_ON_ALERT" );
	//self thread comms_stop_anim_alert();
	
	//Get AI into first frame
	anim_node = get_anim_struct( "9" );
	anim_node thread anim_first_frame( self, "runs_up_stairs" );
	
	self thread comms_flr1_orange_anim_down_stairs( anim_node );
	
	flag_wait( "COMMS_ON_ALERT" );
	self StopAnimScripted();
	self notify( "stop_first_frame" );
 	self setgoalpos( self.origin );
}


smash_tapes()
{
	self waittill( "do_contextual_melee" );
	flag_set( "comm_room_burnt");

	wait( 1.0 );
	bash_spot = getstruct("head_bash_tapes", "targetname" );
	radiusDamage(bash_spot.origin, 32, 150, 100);
}

comms_flr1_new_anim()
{
	self endon( "death" );
	self endon( "do_contextual_melee" );
	level.player endon( "do_contextual_melee" );
	
	self thread smash_tapes();
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_1_new" );
	anim_node thread anim_loop_aligned( self, "idle" );
	
	flag_wait( "COMMS_ON_ALERT" );
	self contextual_melee( false );
	self.ignoreall = false;
	anim_node thread anim_single_aligned( self, "alert" );
 	anim_node waittill( "alert" );
 	self setgoalpos( self.origin );
}


where_am_i_in_relation_to_flr2_blue( player, chair_ent, anim_node )
{
	self endon( "death" );
	level endon( "COMMS_ON_ALERT" );
	
	//Wait till i am actually up on the 2nd floor
	ack_blue_flr2_trig = getent( "ack_blue_flr2", "targetname" );
	ack_blue_flr2_trig waittill( "trigger" );
	
	//iprintlnbold( "ack" );
	anim_node thread anim_single_aligned( self, "ack" );
	anim_node thread anim_single_aligned( chair_ent, "ack" );
	anim_node waittill( "ack" );

	while( 1 )
	{
		enemyFwd = AnglesToForward( self.angles );
		enemySide = AnglesToRight( self.angles );
		
		vec2 = VectorNormalize( player.origin - self.origin );// this is the direction from him to us
		
		// comparing the dotproduct of the 2 will tell us if he's facing us and how much so..
		// 0 will mean his direction is exactly perpendicular to us, 
		// 1 will mean he's facing directly at us
		// - 1 will mean he's facing directly away from us 
		vecdot = vectordot( enemyFwd, vec2 );	

		// is the ai facing us?
		if( vecdot < -0.65 )
		{
			//iprintlnbold( "behind" );
			anim_node thread anim_single_aligned( self, "back_in" );
			anim_node thread anim_single_aligned( chair_ent, "back_in" );
 			anim_node waittill( "back_in" );
 			anim_node thread anim_loop_aligned( self, "back_idle" );
 			anim_node thread anim_loop_aligned( chair_ent, "back_idle" );
			wait( 2.0 );
			anim_node thread anim_single_aligned( self, "back_out" );
			anim_node thread anim_single_aligned( chair_ent, "back_out" );
 			anim_node waittill( "back_out" );
		}
		else if( vecdot > 0.65 )
		{
			//iprintlnbold( "front" );
			anim_node thread anim_single_aligned( self, "ack" );
			anim_node thread anim_single_aligned( chair_ent, "ack" );
			anim_node waittill( "ack" );
		}
		else
		{
			//iprintlnbold( "side" );
			vecdot = vectordot( enemySide, vec2 );	
			
			// is the ai facing us?
			if( vecdot > .0 )
			{
				//iprintlnbold( "right" );
				anim_node thread anim_single_aligned( self, "right_in" );
				anim_node thread anim_single_aligned( chair_ent, "right_in" );
 				anim_node waittill( "right_in" );
 				anim_node thread anim_loop_aligned( self, "right_idle" );
 				anim_node thread anim_loop_aligned( chair_ent, "right_idle" );
				wait( 2.0 );
				anim_node thread anim_single_aligned( self, "right_out" );
				anim_node thread anim_single_aligned( chair_ent, "right_out" );
 				anim_node waittill( "right_out" );
			}
			else
			{
				//iprintlnbold( "left" );
				anim_node thread anim_single_aligned( self, "left_in" );
				anim_node thread anim_single_aligned( chair_ent, "left_in" );
 				anim_node waittill( "left_in" );
 				anim_node thread anim_loop_aligned( self, "left_idle" );
 				anim_node thread anim_single_aligned( chair_ent, "left_idle" );
				wait( 2.0 );
				anim_node thread anim_single_aligned( self, "left_out" );
				anim_node thread anim_single_aligned( chair_ent, "left_out" );
 				anim_node waittill( "left_out" );
			}
		}
	
		anim_node thread anim_loop_aligned( self, "idle" );
		anim_node thread anim_loop_aligned( chair_ent, "idle" );
		wait( 4.0 );
	}
}
comms_music_setup()
{
	flag_wait (	"COMMS_ON_ALERT");
	setmusicstate ("BASE_FIGHT");
	
}
comms_flr2_blue_anim()
{
	self endon( "death" );
	
	chair_ent = getent( "comms_flr2_blue_chair", "targetname" );
	chair_ent.animname = "floor2_blue_chair";
	chair_ent useAnimTree( level.scr_animtree[ "floor2_blue_chair" ] ); 
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_6" );
	anim_node thread anim_loop_aligned( self, "idle" );
	anim_node thread anim_loop_aligned( chair_ent, "idle" );
	
	self thread where_am_i_in_relation_to_flr2_blue( level.player, chair_ent, anim_node );
	
	flag_wait( "COMMS_ON_ALERT" );
	anim_node thread anim_single_aligned( self, "alert" );
	anim_node thread anim_single_aligned( chair_ent, "alert" );
 	anim_node waittill( "alert" );
 	self setgoalpos( self.origin );
}

/*#using_animtree("animated_props");
comms_flr2_blue_chair_anim()
{
	self endon( "death" );
	
	chair_ent = getent( "comms_flr2_blue_chair", "targetname" );
	chair_ent.animname = "floor2_blue_chair";
	chair_ent useAnimTree( "animated_props" ); 
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_6" );
	anim_node thread anim_loop_aligned( chair_ent, "idle" );
	
	flag_wait( "COMMS_ON_ALERT" );
	anim_node thread anim_single_aligned( chair_ent, "alert" );
 	anim_node waittill( "alert" );
}*/

#using_animtree( "generic_human" );
comms_flr2_purple_anim()
{
	self endon( "death" );
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_4" );
	anim_node thread anim_loop_aligned( self, "idle" );
	
	flag_wait( "COMMS_ON_ALERT" );
	anim_node thread anim_single_aligned( self, "alert" );
 	anim_node waittill( "alert" );
 	self setgoalpos( self.origin );
}

comms_flr2_green_anim()
{
	self endon( "death" );
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_5" );
	anim_node thread anim_loop_aligned( self, "idle" );
	
	flag_wait( "COMMS_ON_ALERT" );
	anim_node thread anim_single_aligned( self, "alert" );
 	anim_node waittill( "alert" );
 	self setgoalpos( self.origin );
}

#using_animtree("animated_props");
comms_flr2_green_chair_anim()
{
	self endon( "death" );
	
	chair_ent = getent( "comms_flr2_green_chair", "targetname" );
	chair_ent.animname = "floor2_green_chair";
	chair_ent useAnimTree( #animtree ); 
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_5" );
	anim_node thread anim_loop_aligned( chair_ent, "idle" );
	
	flag_wait( "COMMS_ON_ALERT" );
	anim_node thread anim_single_aligned( chair_ent, "alert" );
 	anim_node waittill( "alert" );
}

#using_animtree( "generic_human" );
comms_flr2_orange_anim()
{
	self endon( "death" );
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_7" );
	anim_node thread anim_loop_aligned( self, "idle" );
	
	flag_wait( "COMMS_ON_ALERT" );
	anim_node thread anim_single_aligned( self, "alert" );
 	anim_node waittill( "alert" );
 	self setgoalpos( self.origin );
}

comms_flr3_blue_anim()
{
	self endon( "death" );
	level endon( "COMMS_ON_ALERT" );
	
//	self endon("contextual_melee_start_anim");	
 	self endon( "do_contextual_melee" );
// 	self endon("_contextual_melee_thread");
// 	level.player endon("_contextual_melee_thread");
	
	self thread comms_stop_anim_alert();
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_8" );
	anim_node thread anim_loop_aligned( self, "intro" );
	
	comms_flr3_blue_start_trig = getent( "comms_flr3_blue_start", "targetname" );
	comms_flr3_blue_start_trig waittill( "trigger" );

	anim_node thread anim_single_aligned( self, "walkdown" );
 	anim_node waittill( "walkdown" );

 	level.comms_flr3_blue contextual_melee( false );
	level.comms_flr3_blue contextual_melee( "floor3blue", "quick" );
 	anim_node thread anim_single_aligned( self, "melee_wnd" );
 	anim_node waittill( "melee_wnd" );
 	level.comms_flr3_blue contextual_melee( false );
 	level.comms_flr3_blue contextual_melee( "neckstab", "quick" );
 	
 	anim_node thread anim_single_aligned( self, "walkup" );
 	anim_node waittill( "walkup" );
 	
 	anim_node thread anim_loop_aligned( self, "outloop" );
 	self setgoalpos( self.origin );
}

comms_flr3_green_anim()
{
	self endon( "death" );
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_10" );
	anim_node thread anim_loop_aligned( self, "idle" );
	
	flag_wait( "COMMS_ON_ALERT" );
	anim_node thread anim_single_aligned( self, "alert" );
 	anim_node waittill( "alert" );
 	self setgoalpos( self.origin );
}

#using_animtree("animated_props");
do_floor3green( guy )
{
	guy endon( "death" );
	
 	chair_ent = getent( "comms_flr3_green_chair", "targetname" );
 	chair_ent.animname = "floor3_green_chair";
 	chair_ent useAnimTree( #animtree ); 
 	
 	anim_node = get_anim_struct( "comm_10" );
 	anim_node thread anim_single_aligned( chair_ent, "melee" );
  	anim_node waittill( "melee" );
}

comms_flr3_green_chair_anim()
{
	self endon( "death" );
	
	chair_ent = getent( "comms_flr3_green_chair", "targetname" );
	chair_ent.animname = "floor3_green_chair";
	chair_ent useAnimTree( #animtree ); 
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_10" );
	anim_node thread anim_loop_aligned( chair_ent, "idle" );
	
	flag_wait( "COMMS_ON_ALERT" );
	anim_node thread anim_single_aligned( chair_ent, "alert" );
 	anim_node waittill( "alert" );
 	
/*
	prop_comms_floor3_green_idle_chair
	prop_comms_floor3_green_idle_2_alert_chair
	prop_contextual_melee_comms_floor3_green_chair
*/
}

#using_animtree( "generic_human" );
comms_flr3_orange_anim()
{
	self endon( "death" );
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_9" );
	anim_node thread anim_loop_aligned( self, "idle" );
	
	flag_wait( "COMMS_ON_ALERT" );
	anim_node thread anim_single_aligned( self, "alert" );
 	anim_node waittill( "alert" );
 	self setgoalpos( self.origin );
}

#using_animtree("animated_props");
comms_flr3_orange_chair_anim()
{
	self endon( "death" );
	
	chair_ent = getent( "comms_flr3_orange_chair", "targetname" );
	chair_ent.animname = "floor3_orange_chair";
	chair_ent useAnimTree( #animtree ); 
	
	//Get AI into first frame
	anim_node = get_anim_struct( "comm_9" );
	anim_node thread anim_loop_aligned( chair_ent, "idle" );
	
	flag_wait( "COMMS_ON_ALERT" );
	anim_node thread anim_single_aligned( chair_ent, "alert" );
 	anim_node waittill( "alert" );
}

#using_animtree( "generic_human" );

comms_flr4_orange_anim_death()
{	
	self waittill( "death" );
	self thread ragdoll_death();
}


comms_flr4_orange_anim()
{
	self endon( "death" );
	
	self endon( "do_contextual_melee" );
	
 	//Get AI into first frame
 	anim_node = get_anim_struct( "comm_11" );
 	anim_node thread anim_loop_aligned( self, "idle" );
 	
 	//Wait till we are on the roof
 	flag_wait( "PLAYER_ON_ROOF" );
 	
 	//Wait till we have fired a weapon (or a timeout)
 	level.player waittill_notify_or_timeout( "weapon_fired", 3.0 );
 	
 	self contextual_melee( false );
	self.ignoreall = false;
	
 	anim_node thread anim_single_aligned( self, "alert" );
  	anim_node waittill( "alert" );
  	self setgoalpos( self.origin );
}


which_melee_to_use()
{
	self endon( "death" );
	level endon( "COMMS_ON_ALERT" );
	
	current_melee_is_front = 1;
	
	while( 1 )
	{
		dist = DistanceSquared(self.origin, level.player.origin);
		if (dist < level._CONTEXTUAL_MELEE_DIST_SQ)
		{
			looking_at = level.player is_player_looking_at(self GetTagOrigin("J_Neck"), .7, false);	
			if( looking_at )
			{
				front_melee = (VectorDot(AnglesToForward(self.angles), AnglesToForward(level.player GetPlayerAngles())) < -0.4);
				if( front_melee )
				{
					//front
					if( current_melee_is_front==0 )
					{
						self contextual_melee( false );
						self contextual_melee( "floor4blue", "quick" );
						current_melee_is_front = 1;
					}
				}
				else
				{
					rear_melee = (VectorDot(AnglesToForward(self.angles), AnglesToForward(level.player GetPlayerAngles())) > 0.4);
					if( rear_melee )
					{
						//rear
						if( current_melee_is_front==1 )
						{
							self contextual_melee( false );
							self contextual_melee( "neckstab", "quick" );
							current_melee_is_front = 0;
						}
					}
				}
			}	
		}
		wait( 0.1 );
	}
}



comms_flr4_blue_anim_walk_round_corner( anim_node )
{
	self endon( "death" );
	level endon( "COMMS_ON_ALERT" );

 	comms_flr4_blue_start_trig = getent( "comms_flr4_blue_start", "targetname" );
	comms_flr4_blue_start_trig waittill( "trigger" );
	
	anim_node thread anim_single_aligned( self, "turncorner" );
 	anim_node waittill( "turncorner" );
 	self setgoalpos( self.origin );
}

comms_flr4_blue_anim()
{
	self endon( "death" );

 	//Get AI into first frame
 	//anim_node = get_anim_struct( "comm_12" );
 	//anim_node thread anim_first_frame( self, "turncorner" );
 	
 	//self thread comms_flr4_blue_anim_walk_round_corner( anim_node );
 		
 	//Wait till we are on the roof
 	flag_wait( "PLAYER_ON_ROOF" );
 	
 	//Wait till we have fired a weapon (or a timeout)
 	level.player waittill_notify_or_timeout( "weapon_fired", 6.0 );
 	
 	self contextual_melee( false );
	self.ignoreall = false;
	//self thread player_seek();
 	
  	//anim_node thread anim_single_aligned( self, "alert" );
   	//anim_node waittill( "alert" );
   	//self setgoalpos( self.origin );
   	self.ignoreall = false;
}

comms_flr4_green_anim()
{
	self endon( "death" );
	
 	//Get AI into first frame
 	//anim_node = get_anim_struct( "comm_13" );
 	//anim_node thread anim_loop_aligned( self, "idle" );
 	
 	//Wait till we are on the roof
 	flag_wait( "PLAYER_ON_ROOF" );
 	
 	//Wait till we have fired a weapon (or a timeout)
 	level.player waittill_notify_or_timeout( "weapon_fired", 4.0 );
 	
 	self contextual_melee( false );
	self.ignoreall = false;
	//self thread player_seek();
	
 	//anim_node thread anim_single_aligned( self, "alert" );
  	//anim_node waittill( "alert" );
  	//self setgoalpos( self.origin );
  	self.ignoreall = false;
}

// check_player_not_leaving_woods_behind()
// {
// 	//level endon( "COMMS_ON_ALERT" );
// 	level endon( "comms_clear" );
// 	
// 	while( 1 )
// 	{
// 		is_comms_clear_top_trig = getent( "is_comms_clear_top", "targetname" );
// 		is_comms_clear_top_trig waittill( "trigger" );
// 		
// 		
// 		if( level.comms_clear == true )
// 		{
// 			//good - all clear
// 		}
// 		else
// 		{	
// 			SetDvar( "ui_deadquote", &"FLASHPOINT_DEAD_WOODS_DISCOVERED" ); 
// 			MissionFailed();
// 		}
// 		wait( 0.1 );
// 	}
// }
// 
// check_comms_clear()
// {
// 	//level endon( "COMMS_ON_ALERT" );
// 	level endon( "comms_clear" );
// 	level thread check_player_not_leaving_woods_behind();
// 	level thread check_comms_clear_from_ai();
// 	
// 
// 	msg_displayed = false;
// 	
// 	while( 1 )
// 	{
// 		is_comms_clear_trig = getent( "is_comms_clear", "targetname" );
// 		//is_comms_clear_trig waittill( "trigger" );
// 		
// 		if(level.player istouching(is_comms_clear_trig))
// 		{
// 			if( level.comms_clear == false )
// 			{
// 				//IPrintLnBold( "CLEAR THE COMMS BUILDING BEFORE PROCEEDING - SO WOODS CAN DISABLE THE COMMS" );
// 				
// 				if( msg_displayed == false )
// 				{
// 					screen_message_create(&"FLASHPOINT_CLEAR_COMMS_BUILDING");
// 					msg_displayed = true;
// 				}
// 			}
// 			else
// 			{
// 				level notify( "comms_clear" );
// 			}
// 		}
// 		else
// 		{
// 			if( msg_displayed==true )
// 			{
// 				screen_message_delete();
// 			}
// 			msg_displayed = false;
// 		}
// 		
// 		wait( 0.1 );
// 	}
// }

check_comms_clear_from_ai()
{
	level endon( "COMMS_BUILDING_CLEARED" );
	level endon( "ROOF_AI_STAGE2_DEAD" );

	level.comms_clear = false;
	
	wait( 5.0 );
	
	while( 1 )
	{
		any_still_alive = false;
			
		//Floor 1
		if( isdefined(level.comms_flr1_blue) && isalive(level.comms_flr1_blue) )
		{
			any_still_alive = true;
		}
		if( isdefined(level.comms_flr1_green) && isalive(level.comms_flr1_green) )
		{
			any_still_alive = true;
		}
		if( isdefined(level.comms_flr1_orange) && isalive(level.comms_flr1_orange) )
		{
			any_still_alive = true;
		}
		if( isdefined(level.comms_flr1_new) && isalive(level.comms_flr1_new) )
		{
			any_still_alive = true;
		}
			
		//Floor 2
		if( isdefined(level.comms_flr2_blue) && isalive(level.comms_flr2_blue) )
		{
			any_still_alive = true;
		}
		if( isdefined(level.comms_flr2_purple) && isalive(level.comms_flr2_purple) )
		{
			any_still_alive = true;
		}
		if( isdefined(level.comms_flr2_green) && isalive(level.comms_flr2_green) )
		{
			any_still_alive = true;
		}
		if( isdefined(level.comms_flr2_orange) && isalive(level.comms_flr2_orange) )
		{
			any_still_alive = true;
		}
			
		//Floor 3
		if( isdefined(level.comms_flr3_blue) && isalive(level.comms_flr3_blue) )
		{
			any_still_alive = true;
		}
		if( isdefined(level.comms_flr3_green) && isalive(level.comms_flr3_green) )
		{
			any_still_alive = true;
		}
		if( isdefined(level.comms_flr3_orange) && isalive(level.comms_flr3_orange) )
		{
			any_still_alive = true;
		}
			
		if( any_still_alive )
		{	
			level.comms_clear = false;
		}
		else
		{
			level.comms_clear = true;
			autosave_by_name("flashpoint_e5");
			flag_set( "COMMS_BUILDING_CLEARED" );
		}
		wait( 0.1 );
	}
}

    
spawnguards_in_room()
{
	level.player thread check_for_weapon_fire();
	//level.player thread check_comms_clear();
	
	//FLOOR 1
	level.comms_flr1_blue = simple_spawn_single( "comms_flr1_blue", ::setup_comms_guard );
	level.comms_flr1_green = simple_spawn_single( "comms_flr1_green", ::setup_comms_guard );
	level.comms_flr1_orange = simple_spawn_single( "comms_flr1_orange", ::setup_comms_guard );
	level.comms_flr1_new = simple_spawn_single( "comms_flr1_new", ::setup_comms_guard );
	level.comms_flr1_blue.animname = "comms_flr1_blue";
	level.comms_flr1_green.animname = "comms_flr1_green";
	level.comms_flr1_orange.animname = "comms_flr1_orange";
	level.comms_flr1_new.animname = "comms_flr1_new";
	level.comms_flr1_new.dontalert = true;
// 	level.comms_flr1_blue contextual_melee( "neckstab", "quick" );
// 	level.comms_flr1_green contextual_melee( "neckstab", "quick" );
// 	level.comms_flr1_orange contextual_melee( "neckstab", "quick" );
	level.comms_flr1_new contextual_melee( "floor1new", "quick" );
	
//HEADPHONES --	comms_flr1_green_headphones
	//level.comms_flr1_green Attach( "p_rus_headset", "j_head" );
	//level.comms_flr1_green Attach( "comms_flr1_green_headphones", "j_head" );

	
	level.comms_flr1_blue thread comms_flr1_blue_anim();
	level.comms_flr1_green thread comms_flr1_green_anim();
	level.comms_flr1_green thread comms_flr1_green_chair_anim();
	level.comms_flr1_orange thread comms_flr1_orange_anim();
	level.comms_flr1_new thread comms_flr1_new_anim();
	
	/*
	level.scr_sound["mason"]["anime"] = "vox_fla1_s05_099A_maso"; //On it.
    level.scr_sound["comms_flr1_blue"]["anime"] = "vox_fla1_s05_362A_sgu3"; //(Translated) What is all the noise outside?
    level.scr_sound["mason"]["anime"] = "vox_fla1_s05_363A_maso"; //Clear.
    level.scr_sound["mason"]["anime"] = "vox_fla1_s05_364A_maso"; //Moving up.
    */
	
	wait( 1.0 );
	
	//level.player notify("break_stealth");
	
	//FLOOR 2
	level.comms_flr2_blue = simple_spawn_single( "comms_flr2_blue", ::setup_comms_guard );
	level.comms_flr2_purple = simple_spawn_single( "comms_flr2_purple", ::setup_comms_guard );
	level.comms_flr2_green = simple_spawn_single( "comms_flr2_green", ::setup_comms_guard );
	level.comms_flr2_orange = simple_spawn_single( "comms_flr2_orange", ::setup_comms_guard );
// 	level.comms_flr2_blue.animname = "comms_flr2_blue";
// 	level.comms_flr2_purple.animname = "comms_flr2_purple";
// 	level.comms_flr2_green.animname = "comms_flr2_green";
// 	level.comms_flr2_orange.animname = "comms_flr2_orange";
// 	level.comms_flr2_blue contextual_melee( "neckstab", "quick" );
// 	level.comms_flr2_purple contextual_melee( "floor2purple" );
// 	level.comms_flr2_green contextual_melee( "neckstab", "quick" );
// 	level.comms_flr2_orange contextual_melee( "neckstab", "quick" );
// 	
// //HEADPHONES --	comms_flr2_orange_headphones
// //HEADPHONES --	comms_flr2_green_headphones
// //HEADPHONES --	comms_flr2_purple_headphones
// 	level.comms_flr2_orange Attach( "p_rus_headset", "j_head" );
// 	level.comms_flr2_green Attach( "p_rus_headset", "j_head" );
// 	level.comms_flr2_purple Attach( "p_rus_headset", "j_head" );
// 	//level.comms_flr2_orange Attach( "comms_flr2_orange_headphones", "j_head" );
// 	//level.comms_flr2_green Attach( "comms_flr2_green_headphones", "j_head" );
// 	//level.comms_flr2_purple Attach( "comms_flr2_purple_headphones", "j_head" );
// 	
// 	level.comms_flr2_blue thread comms_flr2_blue_anim();
// 	//level.comms_flr2_blue thread comms_flr2_blue_chair_anim();
// 	level.comms_flr2_purple thread comms_flr2_purple_anim();
// 	level.comms_flr2_green thread comms_flr2_green_anim();
// 	level.comms_flr2_green thread comms_flr2_green_chair_anim();
// 	level.comms_flr2_orange thread comms_flr2_orange_anim();
	
//	wait( 0.4 );
//	level.player notify("break_stealth");
//	wait( 1.0 );
	
	flag_wait( "comm_room_burnt" );
	level.player notify("break_stealth");

	//FLOOR 3
	level.comms_flr3_blue = simple_spawn_single( "comms_flr3_blue", ::setup_comms_guard );
	level.comms_flr3_green = simple_spawn_single( "comms_flr3_green", ::setup_comms_guard );
	level.comms_flr3_orange = simple_spawn_single( "comms_flr3_orange", ::setup_comms_guard );
// 	level.comms_flr3_blue.animname = "comms_flr3_blue";
// 	level.comms_flr3_green.animname = "comms_flr3_green";
// 	level.comms_flr3_orange.animname = "comms_flr3_orange";
// 	level.comms_flr3_blue contextual_melee( "neckstab", "quick" );
// 	level.comms_flr3_green contextual_melee( "floor3green", "quick" );
// 	level.comms_flr3_orange contextual_melee( "floor3orange", "quick" );
// 	
// //HEADPHONES --	comms_flr3_orange_headphones
// 	level.comms_flr3_orange Attach( "p_rus_headset", "j_head" );
// 	//level.comms_flr3_orange Attach( "comms_flr3_orange_headphones", "j_head" );
// 	
// 	level.comms_flr3_blue thread comms_flr3_blue_anim();
// 	level.comms_flr3_green thread comms_flr3_green_anim();
// 	level.comms_flr3_green thread comms_flr3_green_chair_anim();
// 	level.comms_flr3_orange thread comms_flr3_orange_anim();
// 	level.comms_flr3_orange thread comms_flr3_orange_chair_anim();
	
	
	//This forces the building to go to stealth stright away
	//wait( 0.5 );
	//level.player notify("break_stealth");
	
	//flag_wait( "COMMS_BUILDING_CLEARED" );
	
	//FLOOR 4 (ROOF)
	level.comms_flr4_blue = simple_spawn_single( "comms_flr4_blue", ::setup_comms_guard );
	level.comms_flr4_green = simple_spawn_single( "comms_flr4_green", ::setup_comms_guard );
	level.comms_flr4_orange = simple_spawn_single( "comms_flr4_orange", ::setup_comms_guard );
	
	
	//Floor 4 (roof)
	level.comms_flr4_blue.ignoreall = true;
	level.comms_flr4_green.ignoreall = true;
	level.comms_flr4_orange.ignoreall = true;
	
	level.comms_flr4_blue.goalradius = 800;
	level.comms_flr4_green.goalradius = 800;
	level.comms_flr4_orange.goalradius = 800;


// 	level.comms_flr4_blue.animname = "comms_flr4_blue";
// 	level.comms_flr4_green.animname = "comms_flr4_green";
 	level.comms_flr4_orange.animname = "comms_flr4_orange";
// 	level.comms_flr4_blue contextual_melee( "floor4blue", "quick" );
// 	level.comms_flr4_blue._melee_ignore_angle_override = true;	//360 melee
// 	level.comms_flr4_green contextual_melee( "neckstab", "quick" );
 	level.comms_flr4_orange contextual_melee( "floor4orange", "quick" );
 	level.comms_flr4_blue.dontalert = true;
 	level.comms_flr4_green.dontalert = true;
 	level.comms_flr4_orange.dontalert = true;
 	level.comms_flr4_blue thread comms_flr4_blue_anim();
 	level.comms_flr4_green thread comms_flr4_green_anim();
 	level.comms_flr4_orange thread comms_flr4_orange_anim();
 	//level.comms_flr4_orange thread comms_flr4_orange_anim_death();
 	
 	level thread roof_guys_wake_up();
}


roof_guys_wake_up()
{
 	comms_flr4_blue_start_trig = getent( "comms_flr4_blue_start", "targetname" );
	comms_flr4_blue_start_trig waittill( "trigger" );
	
	if( isdefined(level.comms_flr4_blue) && isalive(level.comms_flr4_blue) )
	{
		level.comms_flr4_blue.ignoreall = false;
		//level.comms_flr4_blue.rusher = 1;
		//level.comms_flr4_blue thread player_seek();
	}
	
	if( isdefined(level.comms_flr4_green) && isalive(level.comms_flr4_green) )
	{
		level.comms_flr4_green.ignoreall = false;
		//level.comms_flr4_green.rusher = 1;
		//level.comms_flr4_green thread player_seek();
	}
	
	if( isdefined(level.comms_flr4_orange) && isalive(level.comms_flr4_orange) )	//off roof guy
	{
		level.comms_flr4_orange.ignoreall = false;
	}
}


#using_animtree("animated_props");
check_for_door_close()
{
	//Wait till woods goes into the Comms building and close the door
	//Also make sure the player is inside!
	//flag_wait( "PLAYER_ON_ROOF" );
	
	level endon( "COMMS_DOOR_SHUT" );
	
	trigger_to_check = getent( "check_woods_and_player_are_inside_comms", "targetname" );
	
	while( 1 )
	{
		if( level.player istouching(trigger_to_check) && level.woods istouching(trigger_to_check) )
		{
			level.woods.ignoreall = false;
			
			level.door_blocker Solid();
			
			door_open_blocker = getent( "door_open_blocker", "targetname" );
			door_open_blocker Delete();
			level.door_blocker disconnectpaths();
			
			anim_node = get_anim_struct( "9" );
			comms_door_ent = getent( "comms_door", "targetname" );
			comms_door_ent.animname = "door";
			comms_door_ent useAnimTree( #animtree ); 
		
			//anim_node thread anim_first_frame( comms_door_ent, "comms_open" );
			anim_node thread anim_single_aligned( comms_door_ent, "comms_close" );
			anim_node waittill( "comms_close" );
			
			SetSavedDvar( "sm_sunSampleSizeNear", "0.8" );
			
			
			//Clean up all vehicles
			vehicles = GetEntArray("script_vehicle", "classname");
			for(i = vehicles.size - 1; i >= 0; i--)
			{
				vehicles[i] Delete();
			}
			
			//Clean up all AI outside
			ai_array = GetAIArray( "axis" );
			for(i = ai_array.size - 1; i >= 0; i-- )
			{
				if( !isdefined(ai_array[i].comms_guard) && ( IsDefined(ai_array[i].animname) && ai_array[i].animname!="sniper" ) )
				{
					ai_array[i] Die();
				}
			}
		
			
			level notify( "COMMS_DOOR_SHUT" );
		}
		wait( 0.1 );
	}	
}

//kdrew - called on player to make him less in danger during contextual melees
comms_contextual_melee_watch()
{
	level endon("BEGIN_EVENT6");

	while(1)
	{
		self waittill("do_contextual_melee");

		self.ignoreme = true;

		self waittill_notify_or_timeout("melee_done", 5.0);

		self.ignoreme = false;
	}
}

event5_InvertedDoorKick()
{
	//autosave_by_name("flashpoint_e5");
	
		
	//Wait for player to enter building
	comms_building_trig = getent( "comms_building", "targetname" );
	comms_building_trig waittill( "trigger" );
	level thread check_for_door_close();
	
	level thread check_comms_clear_from_ai();
	
	flag_set( "START_COMMS_AI" );

	level.player thread comms_contextual_melee_watch();
	
	//-- adjustment just for verteran - made easier
	if( GetDvarInt( #"g_gameskill" ) == 3 )
	{
		level.invulTime_onShield_multiplier = 2.0;  //shield will last a little longer
		level.player_attacker_accuracy_multiplier = 0.5;	//enemies will be a little less accurate
	}
	
	
	battlechatter_on( "axis" );
	battlechatter_on( "allies" );
	
	
	//level notify( "set_portal_override_woods_door_kick" );
	
	//FLASHPOINT_OBJ_CLEAR_OUT_COMMS
	set_event_objective( 4, "active" );
	//Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_CLEAR_ROOMS" );
	//Objective_Set3D( level.obj_num, false );
	
	//level thread contextual_melee_karambit_init();
	//level.comms_flr1_blue = simple_spawn_single( "base_guard_e3", ::setup_comms_guard );	//player to kill this one
	//level.comms_flr1_orange = simple_spawn_single( "base_guard_e4", ::setup_comms_guard );	//runs_up_stairs
	level thread getcloseto_stairs_trigger();
	
	//level.woods setgoalpos( level.woods.origin );
	
	//Woods should run up here now
	//woods_comms_wait_point = getnode( "woods_comms_wait_point", "targetname" );
	//level.woods setgoalnode( woods_comms_wait_point );
	//level.woods waittill( "goal" );
	level.woods.ignoreall = true;
	
	//flag_wait( "COMMS_BUILDING_CLEARED" );
	level thread ladder_objective();

	event5_WeaponsFreeOnRoof();
}

ladder_objective()
{
	//waittill_spawn_manager_cleared("comms_building_spawnmgr");
	if(flag("PLAYER_ON_ROOF"))
	{
		return;
	}
	
	//autosave_by_name("flashpoint_e5b");
	
	Objective_State( level.obj_num, "done" );
	Objective_Set3D( level.obj_num, false );
	
	level.obj_num++;
	Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_CLEAR_OUT_COMMS" );
	Objective_Set3D( level.obj_num, true );
	Objective_Position( level.obj_num, (-1640, -64, 812) );
	
	//Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_LADDER", (-1640, -64, 812) );
	
	//level.obj_num++;
	//Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_LADDER", (-1640, -64, 812) );
	//Objective_AdditionalPosition( level.obj_num, 1, (-1640, -64, 812) ); //TODO: make this an entity or struct in the map
	//Objective_Set3D( level.obj_num, true, "default", "LADDER" );
	
	//autosave_by_name("flashpoint_e5b");
	
	flag_wait("PLAYER_ON_ROOF");
	//autosave_by_name("flashpoint_e5b");
	Objective_Set3D( level.obj_num, false );
	
//	level.comms_spawner_roofminigame_2_ents = getentarray( "comms_spawner_roofminigame_2_ai", "targetname" );
//	level.comms_spawner_roofminigame_2_ents[0].animname = "sniper";
//	level.comms_spawner_roofminigame_2_ents[0] thread peek_over_wall_while_player_climbs_ladder();
				
	
	//level thread maps\flashpoint_e7::open_rocket_gantry();
	//level thread maps\flashpoint_e7::preparing_rocket_launch_VO();
	
	//Clean up prev stuff
	flag_set( "CLEANUP_BASE_ON_ROOF" );
	
	//Objective_Set3D( level.obj_num, false );
	//Objective_State( level.obj_num, "done" );
	//wait( 1.0 );
	//Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_CLEAR_ROOF" );
	//Objective_Set3D( level.obj_num, false );
}

//check_roof_enemies_stage1_are_dead()
//{
//	level endon( "ROOF_AI_STAGE1_DEAD" );
//	
//	
//	//Floor 4 (roof)
////	level.comms_flr4_blue.ignoreall = false;
////	level.comms_flr4_green.ignoreall = false;
////	level.comms_flr4_orange.ignoreall = true;
//
//
//// 			comms_spawner_roofminigame_ents[i].ignoreall = false;
//// 			comms_spawner_roofminigame_ents[1] disable_long_death();
//
//	//Once we have killed the 5 roof enemies then bring woods up.
//// 	comms_spawner_roof_sniper_ents = getentarray( "comms_spawner_roof_sniper_ai", "targetname" );
//// 	
//// 	for( i=0; i<comms_spawner_roof_sniper_ents.size; i++ )
//// 	{
//// 		if( isdefined(comms_spawner_roof_sniper_ents[i]) && isalive(comms_spawner_roof_sniper_ents[i]) )
//// 		{
//// 			comms_spawner_roof_sniper_ents[i].ignoreall = false;
//// 		}
//// 	}
//		
//	//goto suitable start nodes
//	//comms_spawner_roof_sniper_ents[0] setgoalnode( getnode( "roof_start1", "targetname" ) );
////	comms_spawner_roof_sniper_ents[1] setgoalnode( getnode( "roof_start2", "targetname" ) );
////	comms_spawner_roof_sniper_ents[2] setgoalnode( getnode( "roof_start3", "targetname" ) );
//	
//	
//	wait( 3.0 );
//	
//// 	comms_spawner_roofminigame_ents = getentarray( "comms_spawner_roofminigame_ai", "targetname" );
//// 	
//// 	for( i=0; i<comms_spawner_roofminigame_ents.size; i++ )
//// 	{
//// 		if( isdefined(comms_spawner_roofminigame_ents[i]) && isalive(comms_spawner_roofminigame_ents[i]) )
//// 		{
//// 			comms_spawner_roofminigame_ents[i].ignoreall = false;
//// 			comms_spawner_roofminigame_ents[1] disable_long_death();
//// 		}
//// 	}
//	
//	while( 1 )
//	{
//		anyalive = false;
//		
//// 		for( i=0; i<comms_spawner_roofminigame_ents.size; i++ )
//// 		{
//// 			if( isdefined(comms_spawner_roofminigame_ents[i]) && isalive(comms_spawner_roofminigame_ents[i]) )
//// 			{
//// 				anyalive = true;
//// 			}
//// 		}
//// 		
//				
//		//Floor 4 (roof)
//		if( isdefined(level.comms_flr4_blue) && isalive(level.comms_flr4_blue) )
//		{
//			anyalive = true;
//		}
//		if( isdefined(level.comms_flr4_green) && isalive(level.comms_flr4_green) )
//		{
//			anyalive = true;
//		}
//		if( isdefined(level.comms_flr4_orange) && isalive(level.comms_flr4_orange) )
//		{
//			anyalive = true;
//		}	
//		
//		if( anyalive==false )
//		{
//			flag_set( "ROOF_AI_STAGE1_DEAD" );
//		}
//		wait( 0.1 );
//	}
//}


//check_roof_enemies_stage2_are_dead()
//{
//	level endon( "ROOF_AI_STAGE2_DEAD" );
//	
//	//comms_spawner_roofminigame_ents = getentarray( "comms_spawner_roofminigame_2_ai", "targetname" );
//	
//	comms_north_west_node = getnode( "comms_north_west", "targetname" );
//	
// 	for( i=0; i<level.comms_spawner_roofminigame_2_ents.size; i++ )
// 	{
// 		if( isdefined(level.comms_spawner_roofminigame_2_ents[i]) && isalive(level.comms_spawner_roofminigame_2_ents[i]) )
// 		{
// 			level.comms_spawner_roofminigame_2_ents[i].ignoreall = false;
//			level.comms_spawner_roofminigame_2_ents[i] disable_long_death();
//			level.comms_spawner_roofminigame_2_ents[i] Hide();		
//			//comms_north_west_node anim_single_aligned( level.comms_spawner_roofminigame_2_ents[i], "l_in" );
//			
// 		}
// 	}
// 	
// 	//Roof top extra lines
//	level.bowman thread playVO_proper( "peekaboo_snipers2", 1.0 );		//Snipers taking positions on the roof.
//	level.woods thread playVO_proper( "peekaboo_snipers1", 4.0 );		//Take out those snipers.
//
//	while( 1 )
//	{
//		anyalive = false;
//
//		for( i=0; i<level.comms_spawner_roofminigame_2_ents.size; i++ )
//		{
//			if( isdefined(level.comms_spawner_roofminigame_2_ents[i]) && isalive(level.comms_spawner_roofminigame_2_ents[i]) && !isdefined(level.comms_spawner_roofminigame_2_ents[i].sniper_dead) )
//			{
//				anyalive = true;
//			}
//		}
//		
//		if( anyalive==false )
//		{
//			flag_set( "ROOF_AI_STAGE2_DEAD" );
//		}
//		wait( 0.1 );
//	}
//}


// goto_node( node )
// {
// 	self endon( "death" );
// 	self.ignoreall = true;
// 	self.goalradius = 64;
// 	self setgoalnode( node );
// 	self waittill( "goal" );
// 	self.ignoreall = false;
// }

wait_till_death()
{
	self.takedamage = true;
	self.allowdeath = true;
	
	hit_count_to_die = 2;
	while( hit_count_to_die>0 )
	{
		self waittill( "damage" );
		hit_count_to_die--;
	}
//	/#
//	iprintlnbold( "Roof sniper - dead" );
//	#/
	self StopAnimScripted();
	self StartRagDoll();
	forward = AnglesToForward( self.angles );
	self LaunchRagdoll( vector_scale( forward, RandomIntRange(2,3) ), "tag_eye" );
	self StartRagDoll();
	self notify( "sniper_dead" );
	self.sniper_dead = true;
	//flag_set( "ROOF_AI_STAGE2_DEAD" );
	//wait( 5.0 );
	self Die();
}

peek_over_wall_while_player_climbs_ladder()
{
	//This is the node to play from
	node = getnode( "comms_west_south", "targetname" );
	self.takedamage = false;
	self.allowdeath = false;
	
	exploder( 614 );

	self.ignoreall = true;
	self.goalradius = 8;
	start_org = GetStartOrigin( node.origin, node.angles, level.scr_anim["sniper"]["l_out"] );
	start_ang = GetStartAngles( node.origin, node.angles, level.scr_anim["sniper"]["l_out"] );
	self forceTeleport( start_org, start_ang );
	
	self Show();
	node anim_single_aligned( self, "l_out" );
	//node thread anim_loop_aligned( self, "l_idle" );
	//wait( 0.1 );
	exploder( 614 );	
	node anim_single_aligned( self, "l_in" );
	exploder( 614 );
	self Hide();
}

show_in_x_sec( time_to_wait )
{	
	wait( time_to_wait );
	self Show();
}

player_can_see_enemy( enemy )
{
	//Figure out which way the player is facing
	playerAngles = level.player getplayerangles();
	playerForwardVec = AnglesToForward( playerAngles );
	playerUnitForwardVec = VectorNormalize( playerForwardVec );
		
	enemyPos = enemy GetOrigin();
	playerPos = level.player GetOrigin();
	playerToEnemyVec = enemyPos - playerPos;
	playerToEnemyUnitVec = VectorNormalize( playerToEnemyVec );
	
	forwardDotBanzai = VectorDot( playerUnitForwardVec, playerToEnemyUnitVec );
	angleFromCenter = ACos( forwardDotBanzai ); 
		
	println( "Enemy is " + angleFromCenter + " degrees from straight ahead." );

	playerCanSeeMe = ( angleFromCenter <= 65.0 );
	
	return playerCanSeeMe;
}


play_fire_left( node, exploder_num )
{
	self endon( "death" );
	self endon( "sniper_dead" );
	self Hide();
	self.ignoreall = true;
	self.goalradius = 8;
	start_org = GetStartOrigin( node.origin, node.angles, level.scr_anim["sniper"]["l_out"] );
	start_ang = GetStartAngles( node.origin, node.angles, level.scr_anim["sniper"]["l_out"] );
	self forceTeleport( start_org, start_ang );
	
	exploder( exploder_num );
	//wait( 1.0 );
	node anim_first_frame( self, "l_out" );
	self thread show_in_x_sec( 0.4 );
	//wait( 2.0 );
	node anim_single_aligned( self, "l_out" );
	//node waittill( "l_out" );
	node thread anim_loop_aligned( self, "l_idle" );
	wait( 1.0 );
	if( player_can_see_enemy( self ) )
	{
		playfxontag( level.fake_muzzleflash, self, "tag_flash" );
		//MagicBullet("m14_scope_silencer_sp", self GetTagOrigin("tag_flash"), level.player.origin, self );
		MagicBullet("ak47_sp", self GetTagOrigin("tag_flash"), level.player.origin, self );		
	}
	wait( 1.0 );
	if( player_can_see_enemy( self ) )
	{
		playfxontag( level.fake_muzzleflash, self, "tag_flash" );
		//MagicBullet("m14_scope_silencer_sp", self GetTagOrigin("tag_flash"), level.player.origin, self );
		MagicBullet("ak47_sp", self GetTagOrigin("tag_flash"), level.player.origin, self );		
	}
	wait( 1.0 );
	node anim_single_aligned( self, "l_in" );
	//node waittill( "l_in" );
	self Hide();
}

play_fire_right( node, exploder_num )
{
	self endon( "death" );
	self endon( "sniper_dead" );
	self Hide();
	self.ignoreall = true;
	self.goalradius = 8;
	start_org = GetStartOrigin( node.origin, node.angles, level.scr_anim["sniper"]["r_out"] );
	start_ang = GetStartAngles( node.origin, node.angles, level.scr_anim["sniper"]["r_out"] );
	self forceTeleport( start_org, start_ang );
	
	exploder( exploder_num );
	//wait( 1.0 );
	node anim_first_frame( self, "r_out" );	
	self thread show_in_x_sec( 0.4 );
	node anim_single_aligned( self, "r_out" );
	//node waittill( "r_out" );
	node thread anim_loop_aligned( self, "r_idle" );
	wait( 1.0 );
	if( player_can_see_enemy( self ) )
	{
		playfxontag( level.fake_muzzleflash, self, "tag_flash" );
		//MagicBullet("m14_scope_silencer_sp", self GetTagOrigin("tag_flash"), level.player.origin, self );
		MagicBullet("ak47_sp", self GetTagOrigin("tag_flash"), level.player.origin, self );
	}
	wait( 1.0 );
	if( player_can_see_enemy( self ) )
	{
		playfxontag( level.fake_muzzleflash, self, "tag_flash" );
		//MagicBullet("m14_scope_silencer_sp", self GetTagOrigin("tag_flash"), level.player.origin, self );
		MagicBullet("ak47_sp", self GetTagOrigin("tag_flash"), level.player.origin, self );
	}
	wait( 1.0 );	
	node anim_single_aligned( self, "r_in" );
	//node waittill( "r_in" );
	self Hide();
}

/*
		//north west - 1
		ent.v[ "origin" ] = ( -1372.32, 487.009, 980.96 );
        ent.v[ "exploder" ] = 610;

		//west north 4
//         ent.v[ "origin" ] = ( -1661.57, 235.624, 978.706 );
//         ent.v[ "exploder" ] = 613;

		//west south 5
        ent.v[ "origin" ] = ( -1669.52, 129.219, 982.141 );
        ent.v[ "exploder" ] = 614;;

		//south west 7
        ent.v[ "origin" ] = ( -1450.84, -109.465, 980.258 );
        ent.v[ "exploder" ] = 616;

		//south east 8
        ent.v[ "origin" ] = ( -1350.27, -129.496, 982.538 );
        ent.v[ "exploder" ] = 617;

		//east south 11
        ent.v[ "origin" ] = ( -1060.71, 121.063, 981.704 );
        ent.v[ "exploder" ] = 620;

		//east north 12
//         ent.v[ "origin" ] = ( -1055.76, 211.598, 980.751 );
//         ent.v[ "exploder" ] = 621;

		//north east 13
        ent.v[ "origin" ] = ( -1282.28, 473.123, 983.017 );
        ent.v[ "exploder" ] = 624;
*/

roof_battle( ai_index )
{
	level endon( "ROOF_AI_STAGE2_DEAD" );
	self endon( "death" );
	self endon( "sniper_dead" );
	
	//4 triggers
	comms_north_trig = getent( "comms_north", "targetname" );
	comms_east_trig = getent( "comms_east", "targetname" );
	comms_south_trig = getent( "comms_south", "targetname" );
	comms_west_trig = getent( "comms_west", "targetname" );
	
	//8 nodes
	comms_north_west_node = getnode( "comms_north_west", "targetname" );
	comms_north_east_node = getnode( "comms_north_east", "targetname" );
	
	comms_east_north_node = getnode( "comms_east_north", "targetname" );
	comms_east_south_node = getnode( "comms_east_south", "targetname" );
	
	comms_south_east_node = getnode( "comms_south_east", "targetname" );
	comms_south_west_node = getnode( "comms_south_west", "targetname" );
	
	comms_west_south_node = getnode( "comms_west_south", "targetname" );
	comms_west_north_node = getnode( "comms_west_north", "targetname" );
	
	/*
	//Comms building
	level.scr_anim["sniper"]["l_idle"][0]				= %ch_flash_ev06_sniper_l_idle;
	level.scr_anim["sniper"]["l_in"]					= %ch_flash_ev06_sniper_l_in;
	level.scr_anim["sniper"]["l_out"]					= %ch_flash_ev06_sniper_l_out;
	level.scr_anim["sniper"]["r_idle"][0]				= %ch_flash_ev06_sniper_r_idle;
	level.scr_anim["sniper"]["r_in"]					= %ch_flash_ev06_sniper_r_in;
	level.scr_anim["sniper"]["r_out"]					= %ch_flash_ev06_sniper_r_out;
	*/
	
	self thread wait_till_death();
	
	while( isdefined(self) && isalive(self) )
	{
		self.ignoreall = true;
		
		//Find the area that the player is in and move the AI into position
		if( level.player IsTouching( comms_north_trig ) )
		{
			if( ai_index == 0 )
			{
				self play_fire_left( comms_east_north_node, 621 );
			}
			else if( ai_index == 1 )
			{
				self play_fire_right( comms_west_north_node, 613 );
			}
			else
			{
				wait( 0.5 );
			}	
		}
		else if( level.player IsTouching( comms_east_trig ) )
		{
			if( ai_index == 0 )
			{
				self play_fire_right( comms_north_east_node, 624 );
			}
			else if( ai_index == 1 )
			{
				self play_fire_left( comms_south_east_node, 617 );
			}
			else
			{
				wait( 0.5 );
			}
		}
		else if( level.player IsTouching( comms_south_trig ) )
		{
			if( ai_index == 0 )
			{
				self play_fire_right( comms_east_south_node, 620 );
			}
			else if( ai_index == 1 )
			{
				self play_fire_left( comms_west_south_node, 614 );
			}
			else
			{
				wait( 0.5 );
			}
		}
		else if( level.player IsTouching( comms_west_trig ) )
		{
			if( ai_index == 0 )
			{
				self play_fire_right( comms_south_west_node, 616 );
			}
			else if( ai_index == 1 )
			{
				self play_fire_left( comms_north_west_node, 610 );
			}
			else
			{
				wait( 0.5 );
			}
		}
		else
		{
			wait( 0.5 );
		}
	}
	self.sniper_dead = true;
}

event5_WeaponsFreeOnRoof()
{
/*
 Player climbs to the roof of the building and exits with a nice read of the rocket
 There are 4 snipers at various locations around the roof
 Woods says “Weapons Free” over the radio – Karambit over
*/

	comms_building_roof_trig = getent( "comms_building_roof", "targetname" );
	comms_building_roof_trig waittill( "trigger" );
	
	level thread maps\flashpoint_e6::spawnExplosiveBoltFriendlyCover();	
	
	level notify("set_commsbuildingroof_fog");
	
	flag_set("PLAYER_ON_ROOF");
	level notify( "set_portal_override_comms_roof" );
	
	level.woods disable_cqbwalk();
	
	//level thread check_roof_enemies_stage1_are_dead();	
	//flag_wait( "ROOF_AI_STAGE1_DEAD" );
	
	//Wait 10.0 seconds before starting top roof AI
	//wait( 10.0 );	
	
	//2 enemies
	//if( isdefined( level.comms_on_alert ) && (level.comms_on_alert==true) )
//	{
//		//comms_spawner_roofminigame_ents = getentarray( "comms_spawner_roofminigame_2_ai", "targetname" );
//		//level.comms_spawner_roofminigame_2_ents[0].animname = "sniper";
//		//level.comms_spawner_roofminigame_2_ents[1].animname = "sniper";
//		
//		if( isdefined( level.comms_spawner_roofminigame_2_ents[0] ) && isalive( level.comms_spawner_roofminigame_2_ents[0] ) )
//		{
//			level.comms_spawner_roofminigame_2_ents[0].animname = "sniper";
//			level.comms_spawner_roofminigame_2_ents[0] thread roof_battle( 0 );
//		}
//		if( isdefined( level.comms_spawner_roofminigame_2_ents[1] ) && isalive( level.comms_spawner_roofminigame_2_ents[1] ) )
//		{
//			level.comms_spawner_roofminigame_2_ents[1].animname = "sniper";
//			level.comms_spawner_roofminigame_2_ents[1] thread roof_battle( 1 );
//		}
//		level thread check_roof_enemies_stage2_are_dead();
//		flag_wait( "ROOF_AI_STAGE2_DEAD" );
//	}
// 	else
// 	{
// 		flag_set( "ROOF_AI_STAGE2_DEAD" );
// 	}

// 	//If you kill one you kill both
// 	if( isdefined( level.comms_spawner_roofminigame_2_ents[0] ) && isalive( level.comms_spawner_roofminigame_2_ents[0] ) )
// 	{
// 		level.comms_spawner_roofminigame_2_ents[0] Die();
// 		level.comms_spawner_roofminigame_2_ents[0] StartRagdoll();
// 		forward = AnglesToForward( level.comms_spawner_roofminigame_2_ents[0].angles );
// 		level.comms_spawner_roofminigame_2_ents[0] LaunchRagdoll( vector_scale( forward, RandomIntRange(2,3) ), "tag_eye" );
// 	}
// 	if( isdefined( level.comms_spawner_roofminigame_2_ents[1] ) && isalive( level.comms_spawner_roofminigame_2_ents[1] ) )
// 	{
// 		level.comms_spawner_roofminigame_2_ents[1] Die();
// 		level.comms_spawner_roofminigame_2_ents[1] StartRagdoll();
// 		forward = AnglesToForward( level.comms_spawner_roofminigame_2_ents[1].angles );
// 		level.comms_spawner_roofminigame_2_ents[1] LaunchRagdoll( vector_scale( forward, RandomIntRange(2,3) ), "tag_eye" );
// 	}

	//flag_wait( "ROOF_AI_STAGE1_DEAD" );
	
	waittill_ai_group_cleared( "roof_dudes" );
	//level thread maps\flashpoint_e7::open_rocket_gantry();
	
	level.bowman thread playVO_proper( "xray_comein", 1.0 ); //X-ray come in, over.
	level.woods thread playVO_proper( "go_ahead_bowman", 2.5 ); //X-ray come in, over.
	level.bowman thread playVO_proper( "weaver_visual", 3.0 ); //X-ray come in, over.

	level.woods.ignoreall = false;
	
	Objective_State( level.obj_num, "done" );
	level.obj_num--;
	
	//Clean up all AI inside comms
	ai_array = GetAIArray( "axis" );
	for(i = ai_array.size - 1; i >= 0; i-- )
	{
		if( isdefined(ai_array[i].comms_guard) )
		{
			ai_array[i] Die();
		}
	}
	
	//Objective_Set3D( level.obj_num, false );
	
	//autosave_by_name("flashpoint_e5c");
	
	//Objective_State(level.obj_num, "done" );
	//level.obj_num++;
	
	
	//-- adjustment just for verteran - reset back to default
	if( GetDvarInt( #"g_gameskill" ) == 3 )
	{
		level.invulTime_onShield_multiplier = 1.0;
		level.player_attacker_accuracy_multiplier = 1.0;
	}
	
	//Goto next event
	flag_set("BEGIN_EVENT6");
}


////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////
