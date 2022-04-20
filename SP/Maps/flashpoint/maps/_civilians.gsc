/*
 * Feature Civilians
 *
 * Implementation: Sumeet Jakatdar
 *	
 * 
*/

// --------------------------------------------------------------------------------
// ---- Global TODO list ----
// --------------------------------------------------------------------------------


#include maps\_utility; 
#include common_scripts\utility;
#include animscripts\Utility;
#include animscripts\combat_utility;
#include animscripts\Debug;
#include maps\_civilians_anim;

// --------------------------------------------------------------------------------
// ---- Init function for civilians, called from level main script ----
// --------------------------------------------------------------------------------
#using_animtree( "generic_human" );
init_civilians()
{
	// Setup the animations
	self setup_civilian_override_animations();
	
	// Grab all the civilian spawners from the level and start a spawn function thread on them.
	ai = GetSpawnerArray();

	civilians = [];

	for( i = 0; i< ai.size; i++ )
	{
		if( IsSubStr( ToLower( ai[i].classname ), "civilian" ) )
			civilians[civilians.size] = ai[i];
	}

	array_thread( civilians, ::add_spawn_function, ::civilian_spawn_init );
}

// --------------------------------------------------------------------------------
// ---- Spawn function for civilians ----
// --------------------------------------------------------------------------------

civilian_spawn_init( type )
{
	self.is_civilian 		  = true;		// for civilian specific overrides in animscripts.
	self.ignoreall 	 		  = true; 		// dont pick any enemy.
	self.ignoreme    		  = true;		// dont pick me as enemy.
	self.allowdeath  		  = true; 		// allows death during animscripted calls.
		
	self.gibbed      		  = false; 
	self.head_gibbed 		  = false;
	
	self.grenadeawareness     = 0;
	self.badplaceawareness    = 0;

	self.ignoreSuppression    = true; 	
	self.suppressionThreshold = 1; 
	self.dontShootWhileMoving = true;
	self.pathenemylookahead   = 0;

	self.badplaceawareness    = 0;
	self.chatInitialized      = false;
	self.dropweapon           = false; 
	
	self.goalradius 		  = 16;
	self.a.oldgoalradius 	  = self.goalradius;

	self.disableExits		  = true;
	self.disableArrivals	  = true;
	//self.noDodgeMove		  = true;
	
	self.specialReact		  = true;	// react doesnt happen if the AI is set to ignoreall
										// this is to override it		

	self.a.runOnlyReact		  = true;	// in this case prisoners will only react while running

	self disable_pain(); 				  // civilians dont play pain, their health is really low.
	
	self PushPlayer( true ); 		      // should be pushable if comes in path
	
	animscripts\shared::placeWeaponOn( self.primaryweapon, "none" );
	self allowedStances( "stand" );       
	
	// Set the default health if not specified by the level.
	if( !IsDefined( level.civilian_health ) )
		level.civilian_health = 80;

	self.health = level.civilian_health; 

	// always get scared when told to run.
	self set_civilian_run_cycle("scared_run");

	// set civilian attributes
	self setup_civilian_attributes();

	// Place for sound guys to tweak sounds in.
	self thread handle_civilian_sounds();
	
	self notify( "civilian_init_done" );
}


// --------------------------------------------------------------------------------
// ---- Civilian run cycle ----
// --------------------------------------------------------------------------------

set_civilian_run_cycle( state )
{
	// CIVILIAN_TODO - Add run/walk/sprint variations based on the scared or regular AI
	self.alwaysRunForward = true;
	
	self.a.combatrunanim 	= level.civilian[self.a.pose][state][ RandomInt( level.civilian[self.a.pose][state].size ) ];		
	self.run_noncombatanim  = self.a.combatrunanim;
	self.walk_combatanim 	= self.a.combatrunanim;
	self.walk_noncombatanim = self.a.combatrunanim;
}

// --------------------------------------------------------------------------------
// ---- Civilian sounds ----
// --------------------------------------------------------------------------------

handle_civilian_sounds()
{
	self endon( "death" );
	
	// now start waiting until this civilian moves to play screaming sounds
	while(1)
	{
		if( self.a.script != "move" || self.a.movement != "run" )
		{
			wait(0.5);
			continue;
		}

		if( self.civilianSex == "male" )
		{
		    self playsound ("chr_civ_scream_male");
		}
		else
		{
		    self playsound ("chr_civ_scream_female");
		}
		
		wait( RandomIntRange( 2, 5 ) );
	}
}

// --------------------------------------------------------------------------------
// ---- Civilian attributes - sex and nationality ----
// --------------------------------------------------------------------------------

setup_civilian_attributes()
{
	classname	= ToLower( self.classname );
	tokens		= StrTok( classname, "_" );

	// first one is "actor", second is "civilian"
	if( ( tokens.size < 2 ) || ( tokens[1] != "civilian" ) ) 
		return;
		
	// So far the ai types are not setup with specific formatting in classname
	// just comparing against full classname to find out attributes

	// Decide sex
	self.civilianSex = "male";

	if( IsSubStr( classname, "female" ) )
		self.civilianSex = "female";
	
	// Decide nationality
	self.nationality = "default";

	if( IsSubStr( classname, "viet" ) )
		self.nationality = "viet";
	else if( IsSubStr( classname, "russian" ) )
		self.nationality = "russian";
}