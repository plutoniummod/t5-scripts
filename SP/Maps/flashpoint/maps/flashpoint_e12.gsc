////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL SCRIPTS
//
//
// Script for event 12 - this covers the following scenes from the design:
//		Slides 72-74
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;
#include maps\flashpoint_util;


////////////////////////////////////////////////////////////////////////////////////////////
// EVENT12 FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////

// 
// 
// custom_death_anim()
// {	
// 	self.allowDeath = false;
// 	self waittill( "damage" );
// 	anim_node = get_anim_struct( "30" );
// 	anim_node anim_single_aligned( self, "execute" );
// 	self.allowDeath = true;
// 	self ragdoll_death();
// 	
// 	Objective_State( level.obj_num, "done" );
// 	Objective_Set3D( level.obj_num, false );
// 	
// 	level.woods.ignoreall = false;
// 	level.weaver.ignoreall = false;
// }
// 
// setup_head_scientist()
// {
// 	self endon("death");
// 
// 	self.animname = "head";
// 	self.dofiringdeath = false;
// 	self.ignoreall = true;
// 	self.noragdoll = true;
// 	self.goalradius = 32;
// 	self.allowDeath = true;
// 	self.ignoresuppression = 1;
// 	self.grenadeawareness = 0;
// 	self.team = "axis";
// 	
// 
// 	/*
// 	//Head Scientist
// 	level.scr_anim["head"]["rungather"]					= %ch_flash_ev12_headscientist_runandgather;				//TODO
// 	level.scr_anim["head"]["execute"]					= %ch_flash_ev12_scientistexecution_execute;				//TODO
// 	level.scr_anim["head"]["opendoor"]					= %ch_flash_ev12_scientistexecution_opendoor;				//TODO
// 	level.scr_anim["head"]["pleasedont"][0]				= %ch_flash_ev12_scientistexecution_pleasedontshoot_loop;	//TODO
// 	level.scr_anim["head"]["struggle"][0]				= %ch_flash_ev12_scientistexecution_struggledoor_loop;		//TODO
// 	level.scr_anim["head"]["turnaround"]				= %ch_flash_ev12_scientistexecution_struggleturnaround;		//TODO
// 	*/
// 	
// 	//Get to goal node
// 	//self waittill( "goal" );
// 	anim_node_gather = get_anim_struct( "29" );
// 	anim_node = get_anim_struct( "30" );	
// 	
// 	//Run through room to doors
// 	//iprintlnbold( "rungather - start" );
// 	anim_node_gather thread anim_single_aligned( self, "rungather" );
// 	anim_node_gather waittill( "rungather" );
// 	//iprintlnbold( "rungather - end" );
// 	
// // 	self setgoalpos( (-6304.81, -1888.01, 31.7669) );
// // 	self waittill( "goal" );
// // //AI head run_b=(-6304.81, -1888.01, 31.7669)
// // 	
// // 	
// // 	iprintlnbold( "run_b - start" );
// // 	anim_node_gather thread anim_single_aligned( self, "run_b" );
// // 	wait( 0.1 );
// // 	println( "head run_b=" + self.origin );
// // 	anim_node_gather waittill( "run_b" );
// // 	iprintlnbold( "run_b - end" );
// // 	
// // 	iprintlnbold( "gather_loop - start" );
// // 	anim_node thread anim_loop_aligned( self, "gather_loop" );
// // 	wait( 2.0 );
// // 	iprintlnbold( "gather_loop - end" );
// // 	
// 	
// 	self setgoalpos( (-6105.65, -2080.86, 7.69631) );
// 	self waittill( "goal" );
// //AI head opendoor=(-6105.65, -2080.86, 7.69631)
// 	
// 	
// 	//Open first doors
// 	anim_node thread anim_single_aligned( self, "opendoor" );
// 	wait( 0.1 );
// 	println( "head opendoor=" + self.origin );
// 	anim_node waittill( "opendoor" );
// 	
// 	head_enter_blocker = getent( "head_enter_blocker", "targetname" );
// 	head_enter_blocker NotSolid();
// 	head_enter_left = getent( "head_enter_left", "targetname" );
// 	head_enter_right = getent( "head_enter_right", "targetname" );
// 	head_enter_left Delete();
// 	head_enter_right Delete();
// 	
// 	self setgoalpos( (-5938.1, -1927.95, 7.71138) );
// 	self waittill( "goal" );
// //AI head struggle=(-5938.1, -1927.95, 7.71138)
// 
// 
// 	//Struggle with 2nd doors
// 	anim_node thread anim_loop_aligned( self, "struggle" );
// 	
// 	wait( 0.1 );
// 	println( "head struggle=" + self.origin );
// 	
// 	//Wait for player to get close
// 	head_sci_kill_trig = getent( "head_sci_kill_trig", "targetname" );
// 	head_sci_kill_trig waittill( "trigger" );
// 	
// 	
// 	//FOR FOCUS TEST
//  //	level.player FreezeControls( true );
//  //	level thread gameover_screen();
// 	
// 	
// 	//Turn around
// 	anim_node thread anim_single_aligned( self, "pleasedont" );
// 	anim_node waittill( "pleasedont" );
// 	
// 	//Beg for life!
// 	anim_node thread anim_loop_aligned( self, "pleasedont" );
// 	self thread custom_death_anim();
// 	
// 	//self setgoalpos( self.origin );
// 	//self.goalradius = 256;
// }
// 
// head_scientist_trig()
// {
// 	head_scientist_trig = getent( "head_scientist_trig", "targetname" );
// 	head_scientist_trig waittill( "trigger" );
// 	
// 	head_scientist = simple_spawn_single( "head_scientist_spawner", ::setup_head_scientist );
// 	
// 	Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_ASSASSINATE_HEAD_SCIENTIST", head_scientist );
// 	Objective_Set3D( level.obj_num, true, "yellow", "Head Scientist" );
// }
// 
// clear_room()
// {
// 	clear_room_trig = getent( "clear_room", "targetname" );
// 	clear_room_trig waittill( "trigger" );
// 	
// 	
// 	//Clean up prev AI
// 	ai_array = GetAIArray( "axis" );
// 	for(i = ai_array.size - 1; i >= 0; i-- )
// 	{	
// 		if( isdefined( ai_array[i].animname ) && (ai_array[i].animname == "head") )
// 		{
// 			//ignore
// 		}
// 		else
// 		{
// 			ai_array[i] Die();
// 		}
// 	}
// 	
// 	level.woods.ignoreall = true;
// 	level.weaver.ignoreall = true;
// }
// 
// 
// door_open()
// {
// 	//Open door trigger and the doors to open
// 	garage_door_open = getent( "garage_door_open", "targetname" );
// 	head_exit_left = getent( "head_exit_left", "targetname" );
// 	head_exit_right = getent( "head_exit_right", "targetname" );
// 	garage_door_open sethintstring("Press X to Open the door");
// 	garage_door_open waittill( "trigger" );
// 	head_exit_blocker = getent( "head_exit_blocker", "targetname" );
// 	head_exit_blocker NotSolid();
// 	garage_door_open Delete();
// 	head_exit_left Delete();
// 	head_exit_right Delete();
// 	
// 	meetup_with_bowman_brooks();
// }
// 
// meetup_with_bowman_brooks()
// {
// 	bowman_garage_meetup = getnode( "bowman_garage_meetup", "targetname" );	
// 	brooks_garage_meetup = getnode( "brooks_garage_meetup", "targetname" );	
// 	
// 	maps\flashpoint::spawn_bowman_undercover( bowman_garage_meetup, false );
// 	maps\flashpoint::spawn_brooks_undercover( brooks_garage_meetup, false );
// }
// 
// 
// event12_HeadScientist()
// {
// 	autosave_by_name("flashpoint_e12");
// 	
// 	level thread head_scientist_trig();
// 	level thread clear_room();
// 	level thread door_open();
// 	
// 	garage_checkpoint_trig = getent( "garage_checkpoint", "targetname" );
// 	garage_checkpoint_trig waittill( "trigger" );
// 
// 	//Goto next event
// 	flag_set("BEGIN_EVENT13");
// }
// 



event12_HeadScientist()
{
	//Goto next event
	flag_set("BEGIN_EVENT13");
}


////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////
