////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL SCRIPTS
// PJL 04/21/10
//
// Script for event 11 - this covers the following scenes from the design:
//		Slides 67-71
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;
#include maps\flashpoint_util;


////////////////////////////////////////////////////////////////////////////////////////////
// EVENT11 FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////

// 
// //Barrel kicking anims
// //level.scr_anim["spetz"]["barrel1"]					= %ch_flash_ev11_kickingbarrels_01;
// //level.scr_anim["spetz"]["barrel2"]					= %ch_flash_ev11_kickingbarrels_02;
// // 
// // 	"barrel1_spawner"
// // 	"barrel2_spawner"escort_guard_spawner
// 	
// 	
// setup_cowering_scientist()
// {
// 	self endon("death");
// 
// 	self.animname = "scientist";
// 	self.dofiringdeath = false;
// 	self.ignoreall = true;
// 	self.dropweapon = false;
// 	self.noragdoll = false;
// 	self.goalradius = 32;
// 	self.allowDeath = true;
// 	self.ignoresuppression = 1;
// 	self.grenadeawareness = 0;
// 	self.team = "axis";
// 	
// 	self waittill( "goal" );
// 	anim_node = get_anim_struct( "26" );
// 	anim_node thread anim_single_aligned( self, "to_cower" );
// 	anim_node waittill( "to_cower" );
// 
// 	anim_node thread anim_loop_aligned( self, "cowering" );
// }
// 
// cowering_scientist_trig()
// {
// 	suicide_scientist_spawn_trig = getent( "suicide_scientist_spawn_trig", "targetname" );
// 	suicide_scientist_spawn_trig waittill( "trigger" );
// 	cowering_scientist = simple_spawn_single( "cowering_scientist_spawner", ::setup_cowering_scientist );
// 	
// 	cowering_scientist_trig = getent( "cowering_scientist_trig", "targetname" );
// 	cowering_scientist_trig waittill( "trigger" );
// 	suicide_scientist = simple_spawn_single( "suicide_scientist_spawner", ::setup_suicide_scientist );
// }
// 
// setup_suicide_scientist()
// {
// 	self endon("death");
// 
// 	self.animname = "scientist";
// 	self.dofiringdeath = false;
// 	self.ignoreall = true;
// 	self.dropweapon = false;
// 	self.noragdoll = false;
// 	self.goalradius = 32;
// 	self.allowDeath = true;
// 	self.ignoresuppression = 1;
// 	self.grenadeawareness = 0;
// 	self.team = "axis";
// 	
// 	self thread suicide_scientist_trig();
// }
// 
// suicide_scientist_trig()
// {
// 	self endon("death");
// 	
//  	suicide_scientist_trig = getent( "suicide_scientist_trig", "targetname" );
//  	suicide_scientist_trig waittill( "trigger" );
// 	
// 	anim_node = get_anim_struct( "27" );
// 	anim_node thread anim_single_aligned( self, "backingup" );
// 	anim_node waittill( "backingup" );
// 	anim_node thread anim_loop_aligned( self, "panic" );
// 	
// 	suicide_scientist_trig = getent( "suicide_scientist_trig_2", "targetname" );
// 	if( isdefined( suicide_scientist_trig ) )
// 	{
// 		suicide_scientist_trig waittill( "trigger" );
// 	}
// 	
// 	anim_node thread anim_single_aligned( self, "suicide" );
// 	anim_node waittill( "suicide" );
// 	
// 	self StartRagDoll();
// }
// 
// setup_tape_knockover()
// {
// 	self endon("death");
// 
// 	self.animname = "spetz";
// 	self.dofiringdeath = false;
// 	self.ignoreall = false;
// 	self.noragdoll = false;
// 	self.goalradius = 32;
// 	self.allowDeath = true;
// 	self.ignoresuppression = 1;
// 	self.grenadeawareness = 0;
// 	
// 	self waittill( "goal" );
// 	anim_node = get_anim_struct( "28" );
// 	anim_node thread anim_single_aligned( self, "racktapes" );
// 	anim_node waittill( "racktapes" );
// 	self setgoalpos( self.origin );
// 	self.goalradius = 256;
// }
// 
// tape_knockover_trig()
// {
// 	tape_knockover_trig = getent( "tape_knockover_trig", "targetname" );
// 	tape_knockover_trig waittill( "trigger" );
// 	tape_knockover_spetz = simple_spawn_single( "tape_knockover_spawner", ::setup_tape_knockover );
// 	
// 	
// // 	level wait("start_rack_fall");
// // 	level notify("reel_rack_start");
// 	
// 	// targetname = "fxanim_flash_reel_rack_mod"
// }
// 
// custom_death_anim( anim_node )
// {	
// 	self.allowDeath = false;
// 	self waittill( "damage" );
// 	anim_node anim_single_aligned( self, "escortdeath" );
// 	self.allowDeath = true;
// 	self ragdoll_death();
// }
// 
// setup_sci_escort()
// {
// 	self endon("death");
// 
// 	self.animname = "scientist";
// 	self.dofiringdeath = false;
// 	self.ignoreall = false;
// 	self.noragdoll = false;
// 	self.goalradius = 32;
// 	self.allowDeath = true;
// 	self.ignoresuppression = 1;
// 	self.grenadeawareness = 0;
// 	self.team = "axis";
// 	
// 	//self waittill( "goal" );
// 	anim_node = get_anim_struct( "24" );
// 	anim_node thread anim_single_aligned( self, "escort" );
// 	anim_node waittill( "escort" );
// 	
// 	//self setgoalpos( self.origin );
// 	//self.goalradius = 256;
// 	
// 	anim_node thread anim_loop_aligned( self, "escortidle" );
// 	self thread custom_death_anim( anim_node );
// }
// 
// setup_guard_escort()
// {
// 	self endon("death");
// 
// 	self.animname = "spetz";
// 	self.dofiringdeath = false;
// 	self.ignoreall = false;
// 	self.noragdoll = false;
// 	self.goalradius = 32;
// 	self.allowDeath = true;
// 	self.ignoresuppression = 1;
// 	self.grenadeawareness = 0;
// 	
// 	//self waittill( "goal" );
// 	anim_node = get_anim_struct( "24" );
// 	anim_node thread anim_single_aligned( self, "escort_spetz" );
// 	anim_node waittill( "escort_spetz" );
// 	self setgoalpos( self.origin );
// 	self.goalradius = 256;
// }
// 
// escort_trig()
// {
// 	escort_trig = getent( "escort_trig", "targetname" );
// 	escort_trig waittill( "trigger" );
// 	
// 	escort_sci_ai = simple_spawn_single( "escort_sci_spawner", ::setup_sci_escort );
// 	escort_guard_ai = simple_spawn_single( "escort_guard_spawner", ::setup_guard_escort );
// 	
// 	
// // 	level.scr_anim["scientist"]["escort"]				= %ch_flash_ev11_scientistescort_scientist;				//TODO
// // 	level.scr_anim["scientist"]["escortdeath"]			= %ch_flash_ev11_scientistescort_scientist_death;		//TODO
// // 	level.scr_anim["scientist"]["escortidle"][0]		= %ch_flash_ev11_scientistescort_scientist_idle;		//TODO
// // 	level.scr_anim["scientist"]["escortspetz"]			= %ch_flash_ev11_scientistescort_spetznatz;				//TODO
// }
// 
// 
// setup_barrel_ai()
// {
// 	self endon("death");
// 
// 	self.animname = "spetz";
// 	self.dofiringdeath = false;
// 	self.ignoreall = false;
// 	self.noragdoll = false;
// 	self.goalradius = 32;
// 	self.allowDeath = true;
// 	self.ignoresuppression = 1;
// 	self.grenadeawareness = 0;
// }
// 
// play_barrel_push_first_frame( anim_node, anim_name )
// {
// 	anim_node thread anim_first_frame( self, anim_name );
// }
// 
// play_barrel_push( anim_node, anim_name )
// {
// 	anim_node thread anim_single_aligned( self, anim_name );
// 	anim_node waittill( anim_name );
// 	self setgoalpos( self.origin );
// 	self.goalradius = 256;
// }
// 
// barrel_trig()
// {
// 
// 	barrel1_ai = simple_spawn_single( "barrel1_spawner", ::setup_barrel_ai );
// 	barrel2_ai = simple_spawn_single( "barrel2_spawner", ::setup_barrel_ai );
// 	//barrel3_ai = simple_spawn_single( "barrel3_spawner", ::setup_barrel_ai );
// 	
// 	anim_node = get_anim_struct( "25" );
// 	barrel1_ai thread play_barrel_push_first_frame( anim_node, "barrel1" );
// 	barrel1_ai thread play_barrel_push_first_frame( anim_node, "barrel2" );
// 	
// 	barrel_trig = getent( "barrel_trig", "targetname" );
// 	barrel_trig waittill( "trigger" );
// 	if( isdefined(barrel1_ai) && isalive(barrel1_ai) )
// 	{
// 		barrel1_ai thread play_barrel_push( anim_node, "barrel1" );
// 		level notify( "flash_barrel_01_start" );
// 	}
// 	if( isdefined(barrel2_ai) && isalive(barrel2_ai) )
// 	{
// 		barrel2_ai thread play_barrel_push( anim_node, "barrel2" );
// 		level notify( "flash_barrel_02_start" );
// 	}
// }
// 
// event11_AssassinateScientists()
// {
// 	autosave_by_name("flashpoint_e11");
// 	Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_ASSASSINATE_SCIENTISTS" );
// 	
// 	level thread escort_trig();
// 	level thread barrel_trig();
// 	level thread cowering_scientist_trig();
// 	level thread tape_knockover_trig();
// 	
// 	head_sci_checkpoint_trig = getent( "head_sci_checkpoint", "targetname" );
// 	head_sci_checkpoint_trig waittill( "trigger" );
// 	
// 	//Clean up prev AI
// 	ai_array = GetAIArray( "axis" );
// 	for(i = ai_array.size - 1; i >= 0; i-- )
// 	{
// 		ai_array[i] Delete();
// 	}
// 
// 	//Goto next event
// 	flag_set("BEGIN_EVENT12");
// }


event11_AssassinateScientists()
{
	//Goto next event
	flag_set("BEGIN_EVENT12");
}

////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////
