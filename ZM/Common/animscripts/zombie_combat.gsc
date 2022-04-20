#include animscripts\zombie_utility;
#include animscripts\Debug;
#include animscripts\zombie_SetPoseMovement;
#include animscripts\Combat_utility;
#include animscripts\zombie_shared;
#include common_scripts\utility;

#using_animtree("generic_human");

main()
{
	self endon("killanimscript");
	
	[[ self.exception[ "exposed" ] ]]();

	animscripts\zombie_utility::initialize("zombie_combat");
	self.a.arrivalType = undefined;
	
	self setup();
	
	self exposedCombatMainLoop();
}

idleThread()
{
	self endon("killanimscript");
	self endon("kill_idle_thread");
	for(;;)
	{
		idleAnim = animArrayPickRandom( "exposed_idle" );
		self setflaggedanimlimited("idle", idleAnim );
		self waittillmatch( "idle", "end" );
		self ClearAnim( idleAnim, .2 );
	}
}

setup()
{
	if(self.a.pose == "stand")
	{
		self set_animarray_standing();
	}
	else if( self.a.pose == "crouch" )
	{
		self set_animarray_crouching();
	}
	else
	{
		assertMsg( "Unsupported self.a.pose: " + self.a.pose );
	}
	
	self thread stopShortly();
	self.previousPitchDelta = 0.0;
	
	self ClearAnim( %root, .2 );
	self SetAnim( animarray("straight_level") );
	self SetAnim( %add_idle );
	
	if ( !isDefined(self.no_idle) )
	{
		self thread idleThread();
	}
}

stopShortly()
{
	self endon("killanimscript");
	self endon("melee");
	// we want to stop at about the time we blend out of whatever we were just doing.
	wait .2;
	self.a.movement = "stop";
}

// CCheng (8/22/2008): This was getting ridiculously convoluted with lots of redundant assignments,
// so I broke down and reorganized it in a more straightforward manner: now the first part sets the 
// default anims, while the second part overrides only as necessary. This way, if you want to know
// what are all the possible anim slots that need to be filled if you add a new pose, just look at
// the default assignment section.

set_animarray_standing()
{
	self.a.array = [];
	
	// START OF DEFAULTS: First, set the defaults, then override with weapon-specific animations.

	self.a.array["exposed_idle"] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );
	
	self.a.array["crouch_2_stand"] = %exposed_crouch_2_stand;
	self.a.array["stand_2_crouch"] = %exposed_stand_2_crouch;

	// END OF DEFAULTS - OVERRIDE STUFF BELOW BASED ON WEAPONS OR WHATEVER ELSE //

	if ( self.animname == "quad_zombie" )
	{
		self.a.array["exposed_idle"] = array( %ai_zombie_quad_idle, %ai_zombie_quad_idle_2 );		
		self.a.array["straight_level"] = %ai_zombie_quad_idle;
		self.a.array["stand_2_crouch"] = %ai_zombie_shot_leg_right_2_crawl;
	}
	else
	if ( self.animname == "boss_zombie" )
	{
		self.a.array["exposed_idle"]	= array( %ai_zombie_boss_idle_a, %ai_zombie_boss_idle_b );
		self.a.array["straight_level"]	= %ai_zombie_boss_idle_a;
		self.a.array["stand_2_crouch"]	= %ai_zombie_boss_idle_a;
	}
	else
	{
		self.a.array["exposed_idle"]	= array( %ai_zombie_idle_v1 );		
		self.a.array["straight_level"]	= %ai_zombie_idle_base;
		self.a.array["stand_2_crouch"]	= %ai_zombie_shot_leg_right_2_crawl;
	}
	if (isDefined(self.set_animarray_standing_override) )
	{
		self [[self.set_animarray_standing_override]]();
	}
}

// CCheng (8/22/2008): This was not as Byzantine as set_animarray_standing(), but it was still 
// becoming increasingly difficult to tell which anims were and were not getting set in any 
// particular case, so I reorganized it to match the new set_animarray_standing().

set_animarray_crouching()
{
	self.a.array = [];

	// START OF DEFAULTS: First, set the defaults, then override with weapon-specific animations.

/#
	//SUMEET_TODO - take this block out once the issues are resolved.
	if( GetDvar( #"debug_script_issues") == "on" )
	{
		if( self.a.script != "combat" )
		{
			Print( "AI is in combat script but its script is " + self.a.script );
			anything = undefined;
			if( anything )
			{
				// do nothing, this is just to halt the script debugger, as on AssetEx, it does not halt sometimes.
			}
		}
		//AssertEx(self.a.script == "combat", "AI is in combat script but its script is " + self.a.script );
	}
#/	
	self.a.array["exposed_idle"] = array( %exposed_crouch_idle_alert_v1, %exposed_crouch_idle_alert_v2, %exposed_crouch_idle_alert_v3 );

	self.a.array["crouch_2_stand"] = %exposed_crouch_2_stand;
	self.a.array["stand_2_crouch"] = %exposed_stand_2_crouch;

	self.a.array["exposed_idle"]	= array( %ai_zombie_idle_crawl );		
	self.a.array["straight_level"]	= %ai_zombie_idle_crawl_base;
	self.a.array["stand_2_crouch"]	= %ai_zombie_shot_leg_left_2_crawl;

	// END OF DEFAULTS
	// START OF WEAPON-SPECIFICS: To keep things organized, only override stuff you need to change.
}

exposedCombatMainLoop()
{
	self endon ("killanimscript");
	self endon ("melee");
	self endon ("special_attack");
	
	self thread ReacquireWhenNecessary();
	
	self AnimMode("zonly_physics", false);
	
	// before, we oriented to enemy briefly and then changed to face current.
	// now we just face current immediately and rely on turning.
	self OrientMode( "face angle", self.angles[1] );
	
	self resetGiveUpOnEnemyTime();
	
	// hesitate to crouch.
	// crouching too early can look stupid because we'll tend to stand right back up in a lot of cases.
	self.a.dontCrouchTime = GetTime() + randomintrange( 500, 1500 );
	
	justWaited = false;
		
	for(;;)
	{
		
		self IsInCombat(); // reset our in-combat state

		if ( !justWaited )
		{
			if ( self.a.pose == "stand" )
			{
				self set_animarray_standing();
			}
			else
			{
				self set_animarray_crouching();
			}
		}
		
		justWaited = false;

		if ( TrySpecialAttack() )
		{
			return;
		}

		if ( TryMelee() )
		{
			return;
		}

		exposedWait();
		justWaited = true;
	}
}

exposedWait()
{
	if ( !isDefined(self.can_always_see) && (!IsDefined( self.enemy ) || !self cansee( self.enemy )) )
	{
		self endon("enemy");
		
		wait 0.2 + RandomFloat( 0.1 );
		self waittill("do_slow_things");
	}
	else
	if ( !IsDefined( self.enemy ) )
	{
			self endon("enemy");
			
			wait 0.2 + RandomFloat( 0.1 );
			self waittill("do_slow_things");
	}
	else
	{
		wait 0.05;
	}
}

resetGiveUpOnEnemyTime()
{
	self.a.nextGiveUpOnEnemyTime = GetTime() + randomintrange( 2000, 4000 );
}

// does turntable movement to face the enemy;
// should be used sparingly because turn animations look better.
faceEnemyImmediately()
{
	self endon("killanimscript");
	self notify("facing_enemy_immediately");
	self endon("facing_enemy_immediately");
	
	maxYawChange = 5; // degrees per frame

	while(1)
	{
		yawChange = 0 - GetYawToEnemy();

		if ( abs( yawChange ) < 2 )
		{
			break;
		}

		if ( abs( yawChange ) > maxYawChange )
		{
			yawChange = maxYawChange * sign( yawChange );
		}

		self OrientMode( "face angle", self.angles[1] + yawChange );

		wait .05;
	}

	self OrientMode( "face current" );	
}

TryMelee()
{
	if ( is_true( self.cant_melee ) )
	{
		return false;
	}
	if ( !IsDefined( self.enemy ) )
	{
		return false;
	}
	if ( isDefined(self.in_special_attack) )
	{
		return false;
	}
	// early out
	if ( DistanceSquared( self.origin, self.enemy.origin ) > 512*512 )
	{
		animscripts\zombie_melee::debug_melee( "Not doing melee - Distance to enemy is more than 512 units." );
		return false;
	}
	
	canMelee = animscripts\zombie_melee::CanMeleeDesperate();

	if ( !canMelee )
	{
		return false;
	}

	self thread animscripts\zombie_melee::MeleeCombat();
	self melee_notify_wrapper();

	return true;
}

// If I am a banzai guy, and either I'm attacking an AI or else I randomly choose to, do a banzai attack.
can_banzai_melee()
{
	if ( !IsDefined( self.banzai ) || !self.banzai )
	{
		return false;
	}

	if ( !self maps\_bayonet::has_bayonet() )
	{
		return false;
	}

	return 0;
}

drop_turret()
{
	maps\_mgturret::dropTurret();

	self animscripts\weaponList::RefillClip();
	self.a.needsToRechamber = 0;
	self notify ("dropped_gun");
	maps\_mgturret::restoreDefaults();
}

exception_exposed_mg42_portable()
{
	drop_turret();
}

ReacquireWhenNecessary()
{
	self endon("killanimscript");
	self endon("melee");

	// don't look for a cover node right away. stand and fight.
	self.a.lookForNewCoverTime = GetTime() + randomintrange( 800, 1500 );

	if ( self.fixedNode )
	{
		return;
	}

	while(1)
	{
		wait .05;
		
		if ( self.fixedNode )
		{
			return;
		}

		TryExposedReacquire();
	}
}

// this function is meant to be called many times in succession.
// each time it tries another option, until eventually it finds something it can do.
TryExposedReacquire()
{
	//prof_begin( "TryExposedReacquire" );
	if ( !isValidEnemy(self.enemy) )
	{
		self.reacquire_state = 0;
		return;
	}

	if ( isdefined(self.isAttacking) && self.isAttacking )
	{
		self.reacquire_state = 0;
		return;
	}
	
	if ( self canSee( self.enemy ) )
	{
		self.reacquire_state = 0;
		return;
	}
	
	switch (self.reacquire_state)
	{
	case 0:
		if (self ReacquireStep(32))
		{
			assert(self.reacquire_state == 0);
			return;
		}
		break;

	case 1:
		if (self ReacquireStep(64))
		{
			self.reacquire_state = 0;
			return;
		}
		break;

	case 2:
		if (self ReacquireStep(96))
		{
			self.reacquire_state = 0;
			return;
		}
		break;

	case 3:
		if ( self.a.script != "combat" )
		{
			self.reacquire_state = 0;
			return;
		}

		self FindReacquireNode();
		self.reacquire_state++;
		// fall through

	case 4:
		node = self GetReacquireNode();
		if (IsDefined(node))
		{			
			oldKeepNodeInGoal = self.keepClaimedNodeInGoal;
			oldKeepNode = self.keepClaimedNode;
			self.keepClaimedNodeInGoal = false;
			self.keepClaimedNode = false;

			if (self UseReacquireNode(node))
			{
				self.reacquire_state = 0;
			}
			else
			{
				self.keepClaimedNodeInGoal = oldKeepNodeInGoal;
				self.keepClaimedNode = oldKeepNode;
			}
			
			return;
		}
		break;

	case 5:
		if ( tryRunningToEnemy( false ) )
		{
			self.reacquire_state = 0;
			return;
		}
			
		break;

	default:
		assert(self.reacquire_state == 6);
		self.reacquire_state = 0;
		if ( !(self canSee( self.enemy )) )
			self FlagEnemyUnattackable();
		return;
	}
	
	self.reacquire_state++;
}

TrySpecialAttack()
{
	if ( !isdefined( self.specialAttack ) )
	{
		return false;
	}

	return self [[ self.specialAttack ]]();
}