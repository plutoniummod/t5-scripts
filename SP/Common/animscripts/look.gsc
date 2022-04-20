#include animscripts\Utility;
#include animscripts\Combat_Utility;
#include animscripts\SetPoseMovement;

// Look.gsc
// Controls looking left and right by blending animation weights, and provides support functions so that the 
// correct left and right poses are chosen.
#using_animtree ("generic_human");


// spot is the spot we want the head to look at, if it isn't defined, we'll track our enemy
// by default
trackWithHead(spot) /* void */ 
{
	self endon("killanimscript");
	self endon("movemode");
	//self setanimknob(%head_aiming,1);
	
	self.rightAimLimit = 60.0;
	self.leftAimLimit = -60.0;
	self.upAimLimit = 20; 
	self.downAimLimit = -20; 
	self.headHorizontalWeight = 0; 
	self.headVerticalWeight = 0; 
	
//	self SetAnim(%exposed_level,1,.1);
//	self SetAnimKnobAll(animarray("straight_level"),%exposed_level,1);
	
	if(!IsDefined(self.enemy) && !IsDefined(spot))
	{
		return;
	}	
	
	for(;;)
	{
		if(IsDefined(spot))
		{
			yawDelta = getYawToSpot(spot);
			pitchDelta = getPitchToSpot(spot);			
		}
		else
		{
			break;
		}
			
		// need to have fudge factor because the gun's origin is different than our origin,
		// the closer our distance, the more we need to fudge. 
		angleFudge = asin(-3/distance(self.origin,spot));
		yawDelta += angleFudge; 
		//println(yawdelta);
		if(yawDelta > 0 && yawDelta < self.rightAimLimit)
		{
			self SetAnim(%combatrun_head_4,0,0);
			self SetAnim(%combatrun_head_6,1,0);
	
			self.headHorizontalWeight = yawDelta / self.rightAimLimit;
		}  
		if(yawDelta < 0 && yawDelta > self.leftAimLimit)
		{
			self SetAnim(%combatrun_head_6,0,0);
			self SetAnim(%combatrun_head_4,1,0);						
	
			self.headHorizontalWeight = yawDelta / self.leftAimLimit;
		}
		
		if(pitchDelta > 0 && pitchDelta < self.upAimLimit)
		{
			self SetAnim(%combatrun_head_2,0,0);
			self SetAnim(%combatrun_head_8,1,0);
			
			self.headVerticalWeight = pitchDelta / self.upAimLimit;
		}  
		
		if(pitchDelta < 0 && pitchDelta > self.downAimLimit)
		{
			self SetAnim(%combatrun_head_8,0,0);
			self SetAnim(%combatrun_head_2,1,0);
			
			self.headVerticalWeight = pitchDelta / self.downAimLimit;
		}

		wait(0.05);
	}
}

lookThread()
{
	self endon("death");
//	self thread cleanHeadOnKill();
//	for(;;)
//	{
//		if( self.a.script == "move" && ( !IsDefined( self.cqbwalking ) || ( self.cqbwalking == false ) ) )
//			self glance(chooseSomethingToLookAt(), 1, true);				
//		wait(1.0 + RandomFloat(3));	
//	}
}

chooseSomethingToLookAt()
{
	if(IsDefined(self.enemy))
		return self.enemy GetShootAtPos();		
}

/*
WaitForEyesOnlyLook()
{
	self endon ("death");
	for (;;)
	{
		self waittill ("eyes look now");
		println]]("eyes look now notified");#/
		self notify ("stop looking");
		self thread lookAtTarget("eyes only");
	}
}
*/
/*
cleanUpThread()
{
	self endon ("death");
	self waittill ("never look at anything again");
	self finishLookAt();
	//self stopLookAt(self.a.lookTargetSpeed);
}
*/
/*
periodicallyGlanceAtThePlayer()
{
	self endon ("death");	// So thread won't persist after I die.
	self endon ("never look at anything again");

	timeBetweenGlances = RandomFloatRange(8.0, 10.0);
	firstLookWait = (timeBetweenGlances/2) + RandomFloat(timeBetweenGlances/2);
	lastLookedAtThePlayer = (GetTime()/1000) - firstLookWait; 
	wait (firstLookWait);
	player = anim.player;
	for (;;)
	{
		success = TryToGlanceAtThePlayerNow();
		if (success)
		{
			lastLookedAtThePlayer = (GetTime()/1000);
		}
		// Wait until next time to check to see if we can see the player
		timeToWait = lastLookedAtThePlayer - (GetTime()/1000) + RandomFloatRange(timeBetweenGlances*0.8, timeBetweenGlances);
		if (timeToWait < 0.5)
			timeToWait = 0.5;
		wait (timeToWait);
	}
}
*/

/*
lookAtTarget(eyesOnly)
{
	self endon ("death");	// So thread won't persist after I die.
	self endon ("stop looking");
	self endon ("never look at anything again");

	assertEX(self.a.lookTargetType=="sentient" || self.a.lookTargetType=="entity" || self.a.lookTargetType=="origin", "Currently, lookTargetType must be sentient or origin, was "+self.a.lookTargetType);
	assert]]( !IsDefined(eyesOnly) || (eyesOnly=="eyes only") );#/
	println]]("Start looking");#/

	if (self.a.lookTargetType == "sentient")
	{
		targetEntity = self.a.lookTargetEntity;
		if (!IsSentient(targetEntity))
		{
			println("Tried to look at sentient but entity is not a sentient.");
			return;
		}

		lookTargetPos = targetEntity GetShootAtPos();
	}
	else if (self.a.lookTargetType == "entity")
	{
		targetEntity = self.a.lookTargetEntity;
		if (!IsDefined(targetEntity))
		{
			println("Tried to look at entity but entity is not defined.");
			return;
		}

		lookTargetPos = targetEntity.origin;
	}
	else
	{
		targetEntity = undefined;
		lookTargetPos = self.a.lookTargetPos;
	}

	// Set initial lookat position
	self setLookAt(lookTargetPos, self.a.lookTargetSpeed);
	
	updatePeriod = 0.05;
	self.a.lastYawTime = GetTime();
	startTime = GetTime();
	blendtime = 1;

	// Now update the angles once per frame until we're finished looking.
	while ( GetTime() < self.a.lookEndTime )
	{
		if (self.a.lookTargetType == "sentient")
		{
			if (IsAlive(targetEntity))
			{
				// Only update the target pos if it's alive - otherwise assume it hasn't moved.
				lookTargetPos = targetEntity GetShootAtPos();
			}
			self setLookAt(lookTargetPos);
		}
		else if (self.a.lookTargetType == "entity")
		{
			lookTargetPos = targetEntity.origin;
			self setLookAt(lookTargetPos);
		}
		eyePos = self GetShootAtPos();
/#
		debugTargetPos = (lookTargetPos[0], lookTargetPos[1], lookTargetPos[2]-2);	// So player can see debug line aimed at him.
		// Draw a yellow line for eyesonly, green line for full lookat.
		if ( IsDefined(eyesOnly) && eyesOnly=="eyes only" )
			thread animscripts\utility::drawDebugLine(eyePos, debugTargetPos, (1,1,0), 2);
		else
			thread animscripts\utility::drawDebugLine(eyePos, debugTargetPos, (0,1,0), 2);
#/

		// Make the eyes look in the correct direction
		currentEyeAngles = self GetTagAngles ("TAG_EYE");
		currentEyeUp = anglesToUp( currentEyeAngles );
		currentEyeRight = AnglesToRight( currentEyeAngles );
		targetDir = VectorNormalize( lookTargetPos - eyePos );
		rightAmount = vectorDot(currentEyeRight, targetDir);
		upAmount	= vectorDot(currentEyeUp, targetDir);
		rightAngle	= asin(rightAmount);
		upAngle		= asin(upAmount);
		// Tweak the numbers empirically, to make it work better.
		upAngle += 7;
		upAngle *= 0.6;
		rightAngle *= 0.5;

		// Some things only need to updated periodically, such as what look animations to use for the current pose.
		if ( (GetTime()-startTime) % 500 < 50 )
		{
			SetLookAnims(self.a.pose, self.a.movement, self.a.alertness, self.a.special, self.a.idleset, blendtime, eyesOnly);
			// Print debugging info periodically also
			//println]]("LookAtTarget: Right angle: "+rightAngle+", up angle: "+upAngle);#/
		}
		// Limit the angles to a range that I can actually look at.
		eyeLookLimit = 30;
		if ( rightAngle < (-1*eyeLookLimit) )
		{
			rightAngle = (-1*eyeLookLimit);
		}
		else if ( rightAngle > eyeLookLimit )
		{
			rightAngle = eyeLookLimit;
		}
		if ( upAngle < (-1*eyeLookLimit) )
		{
			upAngle = (-1*eyeLookLimit);
		}
		else if ( upAngle > eyeLookLimit )
		{
			upAngle = eyeLookLimit;
		}
		
		eyeLookMax = 30;
		// Do right first
		fractionToBlend = rightAngle / eyeLookMax;
		if (fractionToBlend > 1)
		{
			fractionToBlend = 1;
		}
		else if (fractionToBlend < -1)
		{
			fractionToBlend = -1;
		}
		if (fractionToBlend > 0)
		{
			self SetAnim(%eyes_lookright_30, fractionToBlend, 0.1);
			self SetAnim(%eyes_lookleft_30, 0, 0.1);
		}
		else 
		{
			fractionToBlend = -1*fractionToBlend;
			self SetAnim(%eyes_lookleft_30, fractionToBlend, 0.1);
			self SetAnim(%eyes_lookright_30, 0, 0.1);
		}

		// Now do up the same way.
		fractionToBlend = upAngle / eyeLookMax;
		if (fractionToBlend > 1)
		{
			fractionToBlend = 1;
		}
		else if (fractionToBlend < -1)
		{
			fractionToBlend = -1;
		}
		if (fractionToBlend > 0)
		{
			self SetAnim(%eyes_lookup_30, fractionToBlend, 0.1);
			self SetAnim(%eyes_lookdown_30, 0, 0.1);
		}
		else 
		{
			fractionToBlend = -1*fractionToBlend;
			self SetAnim(%eyes_lookdown_30, fractionToBlend, 0.1);
			self SetAnim(%eyes_lookup_30, 0, 0.1);
		}
		self SetAnim(%eyes_straight, 1, 0.1);	// The animations are all made at double the angle so they can be diluted like this.



		self.a.lastYawTime = GetTime();
		wait (updatePeriod);
	}

	finishLookAt();
}
*/

finishLookAt()
{
return;	// Look is broken/cut
/*
	// Reset the eyes once the lookat is done.
	self SetAnim(%eyes_lookleft_30, 0, 0.1);
	self SetAnim(%eyes_lookright_30, 0, 0.1);
	self SetAnim(%eyes_lookup_30, 0, 0.1);
	self SetAnim(%eyes_lookdown_30, 0, 0.1);

	// 99.9% of the time this is defined but it's possible to get here without having actually looked at anything.
	if ( IsDefined(self.a.lookTargetSpeed) )	
	{
		// Turn the head slower when we stop looking
		self stopLookAt(self.a.lookTargetSpeed*0.75);
	}
	else
	{
		self stopLookAt(1000);
	}

	self notify ("stop looking");
	println]]("finishLookAt");#/
*/
}

/*
SetLookAnims(pose, movement, alertness, special, idleset, blendtime, eyesOnly)
{
	assert]](alertness=="aiming" || alertness == "alert" || alertness == "casual", "look::setLookAnims: alertness was "+alertness);#/
	println]]("Look animations are ",self.a.LookAnimationLeft,", ",self.a.LookAnimationRight);#/
	if ( (self.a.script=="pain") || (self.a.script=="death") )
	{
		//println]]("WARNING0: Look anims set to nothing "+pose+" "+movement+" "+special+" "+alertness+" "+idleset);#/
		lookAnimYawMax = self.a.targetLookAnimYawMax;
		lookYawLimit = 0;
	}
	else if ( (self.a.script=="scripted") && (IsDefined(self.a.EyesOnlyLook)) && self.a.EyesOnlyLook==true )
	{
		//println]]("Look anims set to \"eyes only\" by script");#/
		lookAnimYawMax = self.a.targetLookAnimYawMax;
		lookYawLimit = 0;
	}
	else if ( (self.a.script=="scripted") && (IsDefined(self.a.LookAnimationLeft)) )
	{
		// (Assume that anim_LookAnimationRight is also defined.)
		println]]("Look anims set by script");#/
		lookAnimYawMax = 90;
		lookYawLimit = 90;
		self SetAnimKnobAll (self.a.LookAnimationLeft, %look_left, 1, blendtime);
		self SetAnimKnobAll (self.a.LookAnimationRight, %look_right, 1, blendtime);
	}
	else if ( IsDefined(eyesOnly) && (eyesOnly=="eyes only") )
	{
		//println]]("Doing \"eyes only\" lookat");#/
		lookAnimYawMax = self.a.targetLookAnimYawMax;
		lookYawLimit = 0;
	}
	else
	{
		switch (pose)
		{
		case "stand":
			if ( (special == "none") && (movement == "stop") )
			{
				if (alertness == "aiming")
				{
					//println]]("Look anims set to stand aim");#/
					lookAnimYawMax = 90;
					lookYawLimit = 90;
					self SetAnimKnobAll (%stand_aim_look_left_90, %look_left, 1, blendtime);
					self SetAnimKnobAll (%stand_aim_look_right_90, %look_right, 1, blendtime);
				}
				else
				{
					if (idleset=="a")
					{
						//println]]("Look anims set to stand alert a");#/
						lookAnimYawMax = 90;
						lookYawLimit = 90;
						self SetAnimKnobAll (%stand_alert_look_left_90, %look_left, 1, blendtime);
						self SetAnimKnobAll (%stand_alert_look_right_90, %look_right, 1, blendtime);
					}
					else
					{
						//println]]("Look anims set to stand alert b");#/
						lookAnimYawMax = 90;
						lookYawLimit = 90;
						self SetAnimKnobAll (%stand_alertb_look_left_90, %look_left, 1, blendtime);
						self SetAnimKnobAll (%stand_alertb_look_right_90, %look_right, 1, blendtime);
					}
				}
			}
			else if ( (special == "cover_left") && (alertness == "casual") )
			{
				if (idleset == "a")
				{
					//println]]("Look anims set to stand corner left a");#/
					lookAnimYawMax = 90;
					lookYawLimit = 90;
					self SetAnimKnobAll (%casualcornerA_right_lookleft, %look_left, 1, blendtime);
					self SetAnimKnobAll (%casualcornerA_right_lookright, %look_right, 1, blendtime);
				}
				else
				{
					assert]](idleset == "b", "Bad idleset: "+idleset);#/
					//println]]("Look anims set to stand corner left b");#/
					lookAnimYawMax = 90;
					lookYawLimit = 90;
					self SetAnimKnobAll (%casualcornerB_right_lookleft, %look_left, 1, blendtime);
					self SetAnimKnobAll (%casualcornerB_right_lookright, %look_right, 1, blendtime);
				}
			}
			else if ( (special == "cover_right") && (alertness == "casual") )
			{
				if (idleset == "a")
				{
					//println]]("Look anims set to stand corner right a");#/
					lookAnimYawMax = 90;
					lookYawLimit = 90;
					self SetAnimKnobAll (%casualcornerA_left_lookleft, %look_left, 1, blendtime);
					self SetAnimKnobAll (%casualcornerA_left_lookright, %look_right, 1, blendtime);
				}
				else
				{
					assert]](idleset == "b", "Bad idleset: "+idleset);#/
					//println]]("Look anims set to stand corner right b");#/
					lookAnimYawMax = 90;
					lookYawLimit = 90;
					self SetAnimKnobAll (%casualcornerB_left_lookleft, %look_left, 1, blendtime);
					self SetAnimKnobAll (%casualcornerB_left_lookright, %look_right, 1, blendtime);
				}
			}
			else
			{
				//println]]("WARNING1: Look anims set to nothing "+pose+" "+movement+" "+special+" "+alertness+" "+idleset);#/
				lookAnimYawMax = self.a.targetLookAnimYawMax;
				lookYawLimit = 0;
			}
			break;
		case "crouch":
			if ( (special == "none") && (movement == "stop") )
			{
				if (alertness == "aiming")
				{
					//println]]("Look anims set to crouch aim");#/
					lookAnimYawMax = 90;
					lookYawLimit = 90;
					self SetAnimKnobAll (%crouch_aim_look_left_90, %look_left, 1, blendtime);
					self SetAnimKnobAll (%crouch_aim_look_right_90, %look_right, 1, blendtime);
				}
				else
				{
					if (idleset == "a")
					{
						//println]]("Look anims set to crouch alert a");#/
						lookAnimYawMax = 90;
						lookYawLimit = 90;
						self SetAnimKnobAll (%crouch_alerta_look_left_90, %look_left, 1, blendtime);
						self SetAnimKnobAll (%crouch_alerta_look_right_90, %look_right, 1, blendtime);
					}
					else if (idleset == "b")
					{
						//println]]("Look anims set to crouch alert b");#/
						lookAnimYawMax = 90;
						lookYawLimit = 90;
						self SetAnimKnobAll (%crouch_alertb_look_left_90, %look_left, 1, blendtime);
						self SetAnimKnobAll (%crouch_alertb_look_right_90, %look_right, 1, blendtime);
					}
					else
					{
						println ("Error: animscripts\look::SetLookAnims: Crouch, idleset is "+idleset);
						lookAnimYawMax = self.a.targetLookAnimYawMax;
						lookYawLimit = 0;
					}
				}
			}
			else if ( (special == "cover_left") && (alertness == "casual") )
			{
				if (idleset == "a")
				{
					//println]]("Look anims set to crouch corner left a");#/
					lookAnimYawMax = 90;
					lookYawLimit = 90;
					self SetAnimKnobAll (%casualcornercrouchA_right_lookleft, %look_left, 1, blendtime);
					self SetAnimKnobAll (%casualcornercrouchA_right_lookright, %look_right, 1, blendtime);
				}
				else
				{
					assert]](idleset == "b", "Bad idleset: "+idleset);#/
					//rintln]]("Look anims set to crouch corner left b");#/
					lookAnimYawMax = 90;
					lookYawLimit = 90;
					self SetAnimKnobAll (%casualcornercrouchB_right_lookleft, %look_left, 1, blendtime);
					self SetAnimKnobAll (%casualcornercrouchB_right_lookright, %look_right, 1, blendtime);
				}
			}
			else if ( (special == "cover_right") && (alertness == "casual") )
			{
				if (idleset == "a")
				{
					//println]]("Look anims set to crouch corner right a");#/
					lookAnimYawMax = 90;
					lookYawLimit = 90;
					self SetAnimKnobAll (%casualcornercrouchA_left_lookleft, %look_left, 1, blendtime);
					self SetAnimKnobAll (%casualcornercrouchA_left_lookright, %look_right, 1, blendtime);
				}
				else
				{
					assert]](idleset == "b", "Bad idleset: "+idleset);#/
					//println]]("Look anims set to crouch corner right b");#/
					lookAnimYawMax = 90;
					lookYawLimit = 90;
					self SetAnimKnobAll (%casualcornercrouchB_left_lookleft, %look_left, 1, blendtime);
					self SetAnimKnobAll (%casualcornercrouchB_left_lookright, %look_right, 1, blendtime);
				}
			}
			else
			{
				//println]]("WARNING2: Look anims set to nothing "+pose+" "+movement+" "+special+" "+alertness+" "+idleset);#/
				lookAnimYawMax = self.a.targetLookAnimYawMax;
				lookYawLimit = 0;
			}
			break;
		default:
			//println]]("WARNING3: Look anims set to nothing "+pose+" "+movement+" "+special+" "+alertness+" "+idleset);#/
			lookAnimYawMax = self.a.targetLookAnimYawMax;
			lookYawLimit = 0;
		}
	}

	assert]](IsDefined(lookAnimYawMax), "lookAnimYawMax wasn't set in SetLookAnims");#/
	assert]](IsDefined(lookYawLimit), "lookYawLimit wasn't set in SetLookAnims");#/

	self.a.targetLookAnimYawMax = lookAnimYawMax;
	
	self setLookAtYawLimits(lookAnimYawMax, lookYawLimit, blendtime);
}
*/