#include animscripts\zombie_SetPoseMovement;
#include animscripts\combat_utility;
#include animscripts\zombie_utility;
#include animscripts\zombie_shared;
#include common_scripts\utility;

#using_animtree ("generic_human");

main()
{
	self endon("killanimscript");

/#
	if ( GetDvar( #"showlookaheaddir") == "on" )
	{
		self thread drawLookaheadDir();
	}
#/
	
	[[ self.exception[ "move" ] ]]();
	
	previousScript = self.a.script;	// Grab the previous script before initialize updates it.  Used for "cover me" dialogue.
	animscripts\zombie_utility::initialize("zombie_move");

	if (self.moveMode == "run")
	{
		// Say something
		switch (previousScript)
		{
		case "combat": // handle most common cases first
		case "stop":
			// Say random poop.
			self animscripts\battleChatter_ai::evaluateMoveEvent (false);
			break;

		case "cover_crouch":
		case "cover_left":
		case "cover_right":
		case "cover_stand":
		case "concealment_crouch":
		case "concealment_stand":
		case "cover_wide_left":
		case "cover_wide_right":
		case "stalingrad_cover_crouch":
		case "Hide":
		case "turret":
			// Leaving cover.  Say something like "cover me".
			self animscripts\battleChatter_ai::evaluateMoveEvent (true);
			break;

		default:
			// Say random poop.
			self animscripts\battleChatter_ai::evaluateMoveEvent (false);
			break;
		}
	}
	
	MoveMainLoop();
}

MoveMainLoop()
{
	prevLoopTime = self getAnimTime( %walk_and_run_loops );
	self.a.runLoopCount = RandomInt( 10000 ); // integer that is incremented each time we complete a run loop

	// if initial destination is closer than 64 walk to it.
	moveMode = self.moveMode;
	if ( IsDefined( self.pathGoalPos ) && DistanceSquared( self.origin, self.pathGoalPos ) < 4096 )
	{
		moveMode = "walk";
	}
	
	self.needs_run_update = true;
	
	for (;;)
	{
		loopTime = self getAnimTime( %walk_and_run_loops );
		if ( loopTime < prevLoopTime )
		{
			self.a.runLoopCount++;
		}

		prevLoopTime = loopTime;
		
		self animscripts\face::SetIdleFaceDelayed( anim.alertface );
		
		
		self animscripts\zombie_run::MoveRun();
		
		self.exitingCover = false;
	}
}

moveAgain()
{
	self notify("killanimscript");
	animscripts\zombie_move::main();
}

seekingCoverInMyFov()
{
	// Run back to cover if you're not in your goalradius
	if (distance(self.origin, self.node.origin) > self.goalradius)
	{
		return true;
	}

	if (distance(self.origin, self.node.origin) < 80)
	{
		return true;
	}

	enemyAngles = VectorToAngles(self.origin - self.enemy.origin);
	enemyForward = AnglesToForward(enemyAngles);
	nodeAngles = VectorToAngles(self.origin - self.node.origin);
	nodeForward = AnglesToForward(nodeAngles);
	return (vectorDot(enemyForward, nodeforward) > 0.1);
}

/#
drawLookaheadDir()
{
	self endon("killanimscript");

	for (;;)
	{
		line(self.origin + (0,0,20), (self.origin + vector_scale(self.lookaheaddir,64)) + (0,0,20));	
		wait(0.05);
	}
}
#/
