//================================================================================
// SetPoseMovement - Sets the pose (stand, crouch) and movement (run, walk, 
// stop) to the specified values.  Accounts for all possible starting poses 
// and movements.
//================================================================================

#include animscripts\zombie_Utility;
#include maps\_Utility;
#include common_scripts\utility;

#using_animtree ("generic_human");

SetPoseMovement(desiredPose, desiredMovement)
{
	// Scripts can pass empty strings, meaning they don't want to change that aspect of the state.
	if (desiredPose=="")
	{
		desiredPose = self.a.pose;
	}
	if (!IsDefined(desiredMovement) || desiredMovement=="")
	{
		desiredMovement = self.a.movement;
	}

	// Now call the function.
	[[anim.SetPoseMovementFnArray[desiredPose][desiredMovement]]]();
}

// *****************************
//  All of the following "Begin" functions ensure that the actor is in the given pose and movement type.
//  They return false if nothing needs to be done, true otherwise.
// *****************************

InitPoseMovementFunctions()
{
	// Make an array of movement and pose changing functions.  
	// Indices are: "desired movement", "desired pose"
	anim.SetPoseMovementFnArray["stand"]["stop"] =	::BeginStandStop;
	anim.SetPoseMovementFnArray["stand"]["walk"] =	::BeginStandWalk;
	anim.SetPoseMovementFnArray["stand"]["run"] =	::BeginStandRun;

	anim.SetPoseMovementFnArray["crouch"]["stop"] =	::BeginCrouchStop;
	anim.SetPoseMovementFnArray["crouch"]["walk"] =	::BeginCrouchWalk;
	anim.SetPoseMovementFnArray["crouch"]["run"] =	::BeginCrouchRun;
}

//--------------------------------------------------------------------------------
// Standing poses
//--------------------------------------------------------------------------------

BeginStandStop()
{
	switch (self.a.pose)
	{
	case "stand":
		switch (self.a.movement)
		{
		case "stop":
			return false;

		case "walk":
			StandWalkToStand();
			break;

		default:
			assert(self.a.movement == "run");
			StandRunToStand();
			break;
		}
		break;

	case "crouch":
		switch (self.a.movement)
		{
		case "stop":
			CrouchToStand();
			break;

		case "walk":
			CrouchWalkToStand();
			break;

		default:
			assert(self.a.movement == "run");
			CrouchRunToStand();
			break;
		}
		break;

	default:
		assertEX(0, "SetPoseMovement::BeginStandStop "+self.a.pose+" "+self.a.movement);
		break;
	}
	
	return true;
}

BeginStandWalk()
{
	switch (self.a.pose)
	{
	case "stand":
		switch (self.a.movement)
		{
		case "stop":
			BlendIntoStandWalk();
			break;

		case "walk":
			return false;

		default:
			assert(self.a.movement == "run");
			BlendIntoStandWalk();
			break;
		}
		break;

	case "crouch":
		switch (self.a.movement)
		{
		case "stop":
			CrouchToStandWalk();
			break;

		case "walk":
			BlendIntoStandWalk();
			break;

		default:
			assert(self.a.movement == "run");
			BlendIntoStandWalk();
			break;
		}
		break;

	default:
		assertEX(0, "SetPoseMovement::BeginStandWalk "+self.a.pose+" "+self.a.movement);
		break;
	}
	
	return true;
}

BeginStandRun()
{
	switch (self.a.pose)
	{
	case "stand":
		switch (self.a.movement)
		{
		case "stop":
			BlendIntoStandRun();
			break;

		case "walk":
			BlendIntoStandRun();
			break;

		default:
			assert(self.a.movement == "run");
			return false;
		}
		break;

	case "crouch":
		switch (self.a.movement)
		{
		case "stop":
			CrouchToStandRun();
			break;

		default:
			assert(self.a.movement == "run" || self.a.movement == "walk");
			BlendIntoStandRun();
			break;
		}
		break;

	default:
		assertEX(0, "SetPoseMovement::BeginStandRun "+self.a.pose+" "+self.a.movement);
		break;
	}
	
	return true;
}

//--------------------------------------------------------------------------------
// Crouching functions
//--------------------------------------------------------------------------------
BeginCrouchStop()
{
	switch (self.a.pose)
	{
	case "stand":
		switch (self.a.movement)
		{
		case "stop":
			StandToCrouch();
			break;
		case "walk":
			StandWalkToCrouch();
			break;
		case "run":
			StandRunToCrouch();
			break;
		default:
			assertEX(0, "SetPoseMovement::BeginCrouchStop "+self.a.pose+" "+self.a.movement);
		}
		break;
	case "crouch":
		switch (self.a.movement)
		{
		case "stop":
			// Do nothing
			break;
		case "walk":
			CrouchWalkToCrouch();
			break;
		case "run":
			CrouchRunToCrouch();
			break;
		default:
			assertEX(0, "SetPoseMovement::BeginCrouchStop "+self.a.pose+" "+self.a.movement);
		}
		break;
	default:
		assertEX(0, "SetPoseMovement::BeginCrouchStop "+self.a.pose+" "+self.a.movement);
	}
}

BeginCrouchWalk()
{
	switch (self.a.pose)
	{
	case "stand":
		switch (self.a.movement)
		{
		case "stop":
			BlendIntoStandWalk();
			BlendIntoCrouchWalk();
			break;

		case "walk":
			BlendIntoCrouchWalk();
			break;

		default:
			assert(self.a.movement == "run");
			BlendIntoCrouchWalk();
			break;
		}
		break;

	case "crouch":
		switch (self.a.movement)
		{
		case "stop":
			CrouchToCrouchWalk();
			break;
			
		case "walk":
			return false;

		default:
			assert(self.a.movement == "run");
			BlendIntoCrouchWalk();
			break;
		}
		break;

	default:
		assertEX(0, "SetPoseMovement::BeginCrouchWalk "+self.a.pose+" "+self.a.movement);
		break;
	}
	
	return true;
}

BeginCrouchRun()
{
	switch (self.a.pose)
	{
	case "stand":
		switch (self.a.movement)
		{
		case "stop":
			BlendIntoStandRun();
			BlendIntoCrouchRun();
			break;

		default:
			assert(self.a.movement == "run" || self.a.movement == "walk");
			BlendIntoCrouchRun();
			break;
		}
		break;

	case "crouch":
		switch (self.a.movement)
		{
		case "stop":
			CrouchToCrouchRun();
			break;

		case "walk":
			BlendIntoCrouchRun();
			break;

		default:
			assert(self.a.movement == "run");
			return false;
		}
		break;

	default:
		assertEX(0, "SetPoseMovement::BeginCrouchRun "+self.a.pose+" "+self.a.movement);
		break;
	}
	
	return true;
}

//--------------------------------------------------------------------------------
// Standing support functions
//--------------------------------------------------------------------------------

PlayBlendTransition( transAnim, crossblendTime, endPose, endMovement )
{
	endTime = GetTime() + crossblendTime * 1000;
	
	self SetFlaggedAnimKnobAll( "blendTransition", transAnim, %body, 1, crossblendTime, 1 );
	
	wait crossblendTime / 2;
	
	self.a.pose = endPose;
	self.a.movement = endMovement;
	
	self.a.alertness = "casual";
	
	waittime = (endTime - GetTime()) / 1000;
	if ( waittime < 0.05 )
	{
		waittime = 0.05;
	}
	
	wait waittime;
}

PlayTransitionStandWalk(transAnim, finalAnim)
{
	PlayTransitionAnimation(transAnim, "stand", "walk", 1, finalAnim);
}

StandWalkToStand()
{
	assertEX(self.a.pose == "stand", "SetPoseMovement::StandWalkToStand "+self.a.pose);
	assertEX(self.a.movement == "walk", "SetPoseMovement::StandWalkToStand "+self.a.movement);

	// no transition animations.

	self.a.movement = "stop";
}

StandWalkToCrouch()
{
	StandWalkToStand();
	StandToCrouch();
}

StandRunToStand()
{
	assertEX(self.a.pose == "stand", "SetPoseMovement::StandRunToStand "+self.a.pose);
	assertEX(self.a.movement == "run", "SetPoseMovement::StandRunToStand "+self.a.movement);

	// Do nothing, just blend straight in
	self.a.movement = "stop";
}

StandRunToCrouch()
{
	self.a.movement = "stop";
	self.a.pose = "crouch";
}

PlayBlendTransitionStandRun(animname)
{
	// if we're blending into stand run from stop,
	// we probably just did utility::initialize's ClearAnim(body, .3)
	// so we don't have to spend more than .3 seconds here.
	transtime = 0.2;

	PlayBlendTransition(animname, transtime, "stand", "run");
}

BlendIntoStandRun()
{
	if ( self animscripts\utility::IsInCombat() )
	{
		if (IsDefined(self.run_combatanim))
		{
			PlayBlendTransitionStandRun(self.run_combatanim);
		}
		else
		{
			// Set the specific forward animation we are using to weight 1 immediately
			// we will make sure it is blended smoothly by blending in its parent, combatrun_forward

			self SetAnimKnobLimited( animscripts\zombie_run::GetRunAnim(), 1, 0.2, 1 );

			useLeans = GetDvarInt( #"ai_useLeanRunAnimations");

			if( useLeans && self.isfacingmotion )
			{
				self thread animscripts\zombie_run::UpdateRunWeights( "BlendIntoStandRun", 
					%combatrun_forward,
					%run_lowready_B,
					%ai_run_lowready_f_lean_l,
					%ai_run_lowready_f_lean_r
					);
			}
			else
			{
				self thread animscripts\zombie_run::UpdateRunWeights( "BlendIntoStandRun", 
					%combatrun_forward,
					%run_lowready_B,
					%run_lowready_L,
					%run_lowready_R
					);
			}

			PlayBlendTransitionStandRun(%combatrun);
		}
	}
	else
	{
		if (IsDefined(self.run_noncombatanim))
		{
			PlayBlendTransitionStandRun(self.run_noncombatanim);
		}
		else
		{
			// Set the specific forward animation we are using to weight 1 immediatley
			// we will make sure it is blended smoothly by blending in its parent, combatrun_forward

			self SetAnimKnobLimited( animscripts\zombie_run::GetRunAnim(), 1, 0.2, 1 );

			useLeans = GetDvarInt( #"ai_useLeanRunAnimations");

			if( useLeans && self.isfacingmotion )
			{
				self thread animscripts\zombie_run::UpdateRunWeights( "BlendIntoStandRun", 
					%combatrun_forward,
					%run_lowready_B,
					%ai_run_lowready_f_lean_l,
					%ai_run_lowready_f_lean_r
					);
			}
			else
			{
				self thread animscripts\zombie_run::UpdateRunWeights( "BlendIntoStandRun", 
					%combatrun_forward,
					%run_lowready_B,
					%run_lowready_L,
					%run_lowready_R
					);
			}

			PlayBlendTransitionStandRun(%combatrun);
		}
	}

	self notify ("BlendIntoStandRun");
}

PlayBlendTransitionStandWalk(animname)
{
	if (self.a.movement != "stop")
		self endon("movemode");

	PlayBlendTransition(animname, 0.2, "stand", "walk");
}

BlendIntoStandWalk()
{
	walkanim = animscripts\walk::getStandWalkAnim();
	PlayBlendTransitionStandWalk( walkanim );
}

CrouchToStand()
{
	assertEX(self.a.pose == "crouch", "SetPoseMovement::CrouchToStand "+self.a.pose);
	assertEX(self.a.movement == "stop", "SetPoseMovement::CrouchToStand "+self.a.movement);

	standSpeed = 0.5;
	if (IsDefined (self.fastStand))
	{
		standSpeed = 1.8;
		self.fastStand = undefined;
	}

	// Decide which idle animation to do
	self randomizeIdleSet();

	PlayTransitionAnimation(%crouch2stand, "stand", "stop", standSpeed);
}

//--------------------------------------------------------------------------------
// Crouched Support Functions
//--------------------------------------------------------------------------------


CrouchToCrouchWalk()
{
	assertEX(self.a.pose == "crouch", "SetPoseMovement::CrouchToCrouchWalk "+self.a.pose);
	assertEX(self.a.movement == "stop", "SetPoseMovement::CrouchToCrouchWalk "+self.a.movement);

	BlendIntoCrouchWalk();
}

CrouchToStandWalk()
{
	CrouchToCrouchWalk();
	BlendIntoStandWalk();
}

CrouchWalkToCrouch()
{
	assertEX(self.a.pose == "crouch", "SetPoseMovement::CrouchWalkToCrouch "+self.a.pose);
	assertEX(self.a.movement == "walk", "SetPoseMovement::CrouchWalkToCrouch "+self.a.movement);

	// Do nothing, just blend straight in
		self.a.movement = "stop";
	}

CrouchWalkToStand()
{
	CrouchWalkToCrouch();
	CrouchToStand();
}

CrouchRunToCrouch()
{
	assertEX(self.a.pose == "crouch", "SetPoseMovement::CrouchRunToCrouch "+self.a.pose);
	assertEX(self.a.movement == "run", "SetPoseMovement::CrouchRunToCrouch "+self.a.movement);

	// Do nothing, just blend straight in
		self.a.movement = "stop";
	}

CrouchRunToStand()
{
	CrouchRunToCrouch();
	CrouchToStand();
}

CrouchToCrouchRun()
{
	assertEX(self.a.pose == "crouch", "SetPoseMovement::CrouchToCrouchRun "+self.a.pose);
	assertEX(self.a.movement == "stop", "SetPoseMovement::CrouchToCrouchRun "+self.a.movement);

		BlendIntoCrouchRun();
	}

CrouchToStandRun()
{
	BlendIntoStandRun();
}

BlendIntoCrouchRun()
{
	if (IsDefined(self.crouchrun_combatanim))
	{
		self SetAnimKnobAll(self.crouchrun_combatanim, %body, 1, 0.2);
		PlayBlendTransition(self.crouchrun_combatanim, 0.2, "crouch", "run");
		self notify ("BlendIntoCrouchRun");
	}
	else
	{
		self setanimknob( animscripts\zombie_run::GetCrouchRunAnim(), 1, 0.2 );
		self thread animscripts\zombie_run::UpdateRunWeights(	"BlendIntoCrouchRun", 
														%crouch_fastwalk_F, 
														%crouch_fastwalk_B, 
														%crouch_fastwalk_L,
														%crouch_fastwalk_R
														);

		PlayBlendTransition(%combatrun_forward, 0.2, "crouch", "run");
		self notify ("BlendIntoCrouchRun");
	}
}

BlendIntoCrouchWalk()
{
	if (IsDefined(self.crouchrun_combatanim))
	{
		self SetAnimKnobAll(self.crouchrun_combatanim, %body, 1, 0.2);
		PlayBlendTransition(self.crouchrun_combatanim, 0.2, "crouch", "walk");
		self notify ("BlendIntoCrouchWalk");
	}
	else
	{
		PlayBlendTransition( %crouch_fastwalk_F, 0.2, "crouch", "walk" );
	}
}

StandToCrouch()
{
	assertEX(self.a.pose == "stand", "SetPoseMovement::StandToCrouch "+self.a.pose);
	assertEX(self.a.movement == "stop", "SetPoseMovement::StandToCrouch "+self.a.movement);

	// Decide which idle animation to do
	self randomizeIdleSet();

	crouchSpeed = 0.5;
	if (IsDefined (self.fastCrouch))
	{
		crouchSpeed = 1.8;
		self.fastCrouch = undefined;
	}

	// If we're a zombie, do not play Standtocrouch transition
	if( self is_zombie() )
	{
		return;
	}

	PlayTransitionAnimation( %exposed_stand_2_crouch, "crouch", "stop", 1, undefined, crouchspeed );
}

//--------------------------------------------------------------------------------
// General support functions
//--------------------------------------------------------------------------------

// PlayTransitionAnimation2 is superceding PlayTransitionAnimation, gradually.  Right now it doesn't set pose 
// and movement (since they should be in notetracks).  Eventually it will take a struct instead of individual 
// parameters for anim state variables.
PlayTransitionAnimation2(transAnim, endPose, endMovement, finalAnim)
{
	// Play the anim
	self SetFlaggedAnimKnobAll("transAnimDone1", transAnim, %body, 1, 0.2, 1);
	if (!IsDefined(self.a.pose))
	{
		self.pose = "undefined";
	}

	if (!IsDefined(self.a.movement))
	{
		self.movement = "undefined";
	}

	debugIdentifier = self.a.pose+" to "+endPose+", "+self.a.movement+" to "+endMovement;
	self animscripts\zombie_shared::DoNoteTracks("transAnimDone1", undefined, debugIdentifier);

	// Set state variables in case anything went wrong (like the anim was already halfway through, or the 
	// framerate was so low that the "end" note came before a change pose note.
	self.a.pose = endPose;
	self.a.movement = endMovement;

	self.a.alertness = "casual";

	if (IsDefined(finalAnim))
	{
		self SetAnimKnobAll(finalAnim, %body, 1, 0.2, 1);	// Set the animation instantly
	}
}


PlayTransitionAnimationThread_WithoutWaitSetStates(transAnim, endPose, endMovement, finalAnim, rate)
{
	self endon ("killanimscript"); // the threaded one needs this or it wont die
	self endon ("entered_pose" + endPose);
	PlayTransitionAnimationFunc(transAnim, endPose, endMovement, finalAnim, rate, false);
}

PlayTransitionAnimation(transAnim, endPose, endMovement, finalAnim, rate)
{
	PlayTransitionAnimationFunc(transAnim, endPose, endMovement, finalAnim, rate, true);
}


PlayTransitionAnimationFunc(transAnim, endPose, endMovement, finalAnim, rate, waitSetStatesEnabled)
{
	if (!IsDefined (rate))
		rate = 1;
	
/#
	if (GetDebugDvar("debug_grenadehand") == "on")
	{
		if (endPose != self.a.pose)
		{
			if (!animhasnotetrack(transAnim, "anim_pose = \"" + endPose + "\""))
			{
				println ("Animation ", transAnim, " lacks an endpose notetrack of ", endPose);
				assertEx(0, "A transition animation is missing a pose notetrack (see the line above)");
			}
		}
		if (endMovement != self.a.movement)
		{
			if (!animhasnotetrack(transAnim, "anim_movement = \"" + endMovement + "\""))
			{
				println ("Animation ", transAnim, " lacks an endmovement notetrack of ", endMovement);
				assertEx(0, "A transition animation is missing a movement notetrack (see the line above)");
			}
		}
	}
#/
	
	// Use a second thread to set the anim state halfway through the animation
	if (waitSetStatesEnabled)
	{
		self thread waitSetStates ( getanimlength(transAnim)/2.0, "killtimerscript", endPose);
	}

	// Play the anim
	self SetFlaggedAnimKnobAllRestart("transAnimDone2", transAnim, %body, 1, .2, rate);
	if (!IsDefined(self.a.pose))
	{
		self.pose = "undefined";
	}

	if (!IsDefined(self.a.movement))
	{
		self.movement = "undefined";
	}

	debugIdentifier = "";
	/#debugIdentifier = self.a.script+", "+self.a.pose+" to "+endPose+", "+self.a.movement+" to "+endMovement;#/
	self animscripts\zombie_shared::DoNoteTracks("transAnimDone2", undefined, debugIdentifier);

	// In case we finished earlier than we expected (eg the animation was already playing before we started), 
	// set the variables and kill the other thread.
	self notify ("killtimerscript");
	self.a.pose = endPose;
	self notify ("entered_pose" + endPose);

	self.a.movement = endMovement;
	self.a.alertness = "casual";

	if (IsDefined(finalAnim))
	{
		self SetAnimKnobAll(finalAnim, %body, 1, 0.2, rate);	// Set the animation instantly
	}
}

waitSetStates ( timetowait, killmestring, endPose )
{
	self endon("killanimscript");
	self endon ("death");
	self endon(killmestring);

	oldpose = self.a.pose;
	wait timetowait;
}