#using_animtree( "zombie_dog" );

main()
{
	self endon( "death" );
	self notify( "killanimscript" );

	self.codeScripted[ "root" ] = %root;	// TEMP!

	self trackScriptState( "Scripted Main", "code" );
	self endon( "end_sequence" );

	self StartScriptedAnim( self.codeScripted[ "notifyName" ], self.codeScripted[ "origin" ], self.codeScripted[ "angles" ], self.codeScripted[ "anim" ], self.codeScripted[ "AnimMode" ], self.codeScripted[ "root" ], self.codeScripted["goalTime"]);

	self.a.script = "scripted";
	self.codeScripted = undefined;

	if ( IsDefined( self.deathstring_passed ) )
	{
		self.deathstring = self.deathstring_passed;
	}

	self waittill( "killanimscript" );
}

init( notifyName, origin, angles, theAnim, AnimMode, root, goalTime )
{
	self.codeScripted[ "notifyName" ] = notifyName;
	self.codeScripted[ "origin" ] = origin;
	self.codeScripted[ "angles" ] = angles;
	self.codeScripted[ "anim" ] = theAnim;

	if ( IsDefined( AnimMode ) )
	{
		self.codeScripted[ "AnimMode" ] = AnimMode;
	}
	else
	{
		self.codeScripted[ "AnimMode" ] = "normal";
	}

	if ( IsDefined( root ) )
	{
		self.codeScripted[ "root" ] = root;
	}
	else
	{
		self.codeScripted[ "root" ] = %root;
	}

	if (IsDefined(goalTime))
	{
		self.codeScripted["goalTime"] = goalTime;
	}
}
