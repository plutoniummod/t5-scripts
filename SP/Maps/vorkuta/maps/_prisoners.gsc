/*
 * Prisoners for Vorkuta
*/

// --------------------------------------------------------------------------------
// ---- Global TODO list ----
// - Replace civilians animations to actual prisoner animations
// - Anything that Vorkuta Scripters want!!	
// --------------------------------------------------------------------------------


#include maps\_utility; 
#include common_scripts\utility;
#include animscripts\Utility;
#include animscripts\combat_utility;
#include animscripts\Debug;
#include maps\_prisoners_anim;
#include animscripts\anims_table;

// --------------------------------------------------------------------------------
// ---- Init function for prisoners, called from level main script ----
// --------------------------------------------------------------------------------
#using_animtree( "generic_human" );
init_prisoners()
{
	setup_prisoners_override_animations();
}

// --------------------------------------------------------------------------------
// ---- Make a prisoner ----
// --------------------------------------------------------------------------------

make_prisoner() // self = prisoner
{
	self set_prisoner_script_settings();
	
	// setup special run cycle
	self set_prisoner_run_cycle("prisoner_run_cycle");

	// setup all special animations
	self setup_prisoner_anims();
}


// --------------------------------------------------------------------------------
// ---- Unmake a Prisoner ----
// --------------------------------------------------------------------------------
unmake_prisoner( weaponName ) // self = prisoner
{
	self endon("death");

	self reset_prisoner_script_settings( weaponName );

	self reset_prisoner_run_cycle();

	self reset_prisoner_anims();
}

// --------------------------------------------------------------------------------
// ---- settings for prisoners ----
// --------------------------------------------------------------------------------

set_prisoner_script_settings()
{
	self.is_prisoner 		  = true;		// for prisoener specific overrides in animscripts.
	self.ignoreall 	 		  = true; 		// dont pick any enemy.
	self.ignoreme    		  = true;		// dont pick me as enemy.
			
	self.grenadeawareness     = 0;
	self.badplaceawareness    = 0;

	self.ignoreSuppression    = true; 	
	self.noDodgeMove 		  = false; 
	self.dontShootWhileMoving = true;
	
	self.dropweapon           = false;

	self.a.oldgoalradius 	  = self.goalradius;
	self.goalradius 		  = 32;

	self.specialReact		  = true;	// react doesnt happen if the AI is set to ignoreall
										// this is to override it		

	self.a.runOnlyReact		  = true;	// in this case prisoners will only react while running
			
	self disable_pain(); 				  // prisoeners dont play pain, their health is really low.
	self PushPlayer( true ); 		      // should be pushable if comes in path
	
	self gun_remove();					  // take gun away
	
	self.alwaysRunForward = true;		  	
}

reset_prisoner_script_settings( weaponName )
{
	self.is_prisoner 		  = false;		
	self.ignoreall 	 		  = false; 		
	self.ignoreme    		  = false;		
			
	self.grenadeawareness     = 1;
	self.badplaceawareness    = 1;

	self.ignoreSuppression    = false; 	
	self.noDodgeMove 		  = false; 
	self.dontShootWhileMoving = undefined;
	self.disableIdleStrafing  = true;
		
	self.dropweapon           = true;
	self.goalradius 		  = self.a.oldgoalradius;

	self.specialReact		  = undefined;		
	self.a.runOnlyReact		  = undefined;	

	self enable_pain(); 				  
	self PushPlayer( false ); 		      
	
	if( IsDefined( weaponName ) )	
		self gun_switchto( weaponName, "right" );
	else
		self gun_recall();					  
	
	self allowedStances( "stand", "crouch", "prone" );

	self.alwaysRunForward = undefined;		  	
}


// --------------------------------------------------------------------------------
// ---- Prisoner run cycle ----
// --------------------------------------------------------------------------------

set_prisoner_run_cycle( state )
{	
	// if this AI is reznov then we want a specific run cycle
	if( IsDefined( self.animType ) && self.animType == "reznov" )
		self.a.combatrunanim	= %ai_prisoner_run_upright;
	else
		self.a.combatrunanim 	= level.prisoner[self.a.pose][state][ RandomInt( level.prisoner[self.a.pose][state].size ) ];

	self.run_noncombatanim  = self.a.combatrunanim;
	self.walk_combatanim 	= self.a.combatrunanim;
	self.walk_noncombatanim = self.a.combatrunanim;
}

reset_prisoner_run_cycle()
{	
	self.a.combatrunanim 	= undefined;
	self.run_noncombatanim  = undefined;
	self.walk_combatanim 	= undefined;
	self.walk_noncombatanim = undefined;
}
