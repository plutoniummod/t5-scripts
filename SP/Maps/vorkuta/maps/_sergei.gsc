/*
 * Sergei for Vorkuta
*/

// --------------------------------------------------------------------------------
// ---- Global TODO list ----
// - Replace civilian animations to actual sergei animations
// --------------------------------------------------------------------------------


#include maps\_utility; 
#include common_scripts\utility;
#include animscripts\Utility;
#include animscripts\combat_utility;
#include animscripts\Debug;
#include animscripts\anims_table;

// --------------------------------------------------------------------------------
// ---- Init function for sergei, called from level main script ----
// --------------------------------------------------------------------------------
#using_animtree( "generic_human" );
init_sergei()
{	
	// setup the run cycle animation and animname
	self.animname = "sergei";
	level.scr_anim[ self.animname ][ "run_cycle" ] = %ai_sergei_run_upright;

	set_run_anim( "run_cycle", 1 );
	
	self set_sergei_script_settings();
	
	// setup all special animations
	self setup_sergei_anim_array();
	
	self setclientflag(15);
}

// --------------------------------------------------------------------------------
// ---- settings for sergei ----
// --------------------------------------------------------------------------------

set_sergei_script_settings()
{	
	self.name				  = "Sergei";
	self.is_sergei			  = true;
	self.ignoreall 	 		  = true; 		// dont pick any enemy.
	self.ignoreme    		  = true;		// dont pick me as enemy.
			
	self.grenadeawareness     = 0;
	self.badplaceawareness    = 0;

	self.ignoreSuppression    = true; 	
	self.noDodgeMove 		  = true; 
	self.dontShootWhileMoving = true;
	self.disableIdleStrafing  = true;
	
	self.dropweapon           = false;

	self.a.oldgoalradius 	  = self.goalradius;
	self.goalradius 		  = 32;

	self.specialReact		  = true;	  // react doesnt happen if the AI is set to ignoreall
										  // this is to override it		

	self.a.runOnlyReact		  = true;	// in this case prisoners will only react while running
			
	self disable_pain(); 				  // prisoeners dont play pain, their health is really low.
	self PushPlayer( true ); 		      // should be pushable if comes in path
	
	self gun_remove();					  // take gun away

	self thread magic_bullet_shield();
	
	self.alwaysRunForward = true;		  	
}
