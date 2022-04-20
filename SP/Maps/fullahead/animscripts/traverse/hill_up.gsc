#include common_scripts\utility;
#include animscripts\traverse\shared;
#include animscripts\anims;

#using_animtree ("generic_human");

main()
{
	level.hill_angles = [];
	level.hill_angles[0] = 20;
	level.hill_angles[1] = 25;
	level.hill_angles[2] = 30;
	level.hill_angles[3] = 35;
	
	self.a.script = "move";
	
	switch (self.type)
	{
	case "human": human(); break;
	default: assertmsg("Traversal: 'hill_up' doesn't support entity type '" + self.type + "'.");
	}
}

human()
{
	self endon( "death" );
	self endon( "delete" );
	
	self thread do_hill_pain_anims();
	self thread do_hill_death_anims();
	self thread do_hill_aim_anims();
	
	self.a.nodeath = true;
	self.a.disablePain = true;
	
	movement = PrepareForTraverse();

	self TraverseMode( "gravity" );

	self.traverseStartNode = self GetNegotiationStartNode();
	self.traverseEndNode = self GetNegotiationEndNode();
	
	self OrientMode( "face angle", self.traverseStartNode.angles[1] );
	
	rise = self.traverseEndNode.origin[2] - self.traverseStartNode.origin[2];
	diff = (self.traverseEndNode.origin[0]-self.traverseStartNode.origin[0], self.traverseEndNode.origin[1]-self.traverseStartNode.origin[1], 0 );
	fullRun = Length( diff );
	run = fullRun - 29 - 9.5;
	
	riseOverRun = rise/run;
	
	angle = ATan( riseOverRun );
	
	totalDist = fullRun / Cos( angle );
	
	if( angle < level.hill_angles[0] )
	{
		angle = level.hill_angles[0];
	}
	
	if( angle > level.hill_angles[ level.hill_angles.size - 1 ] )
	{
		angle = level.hill_angles[ level.hill_angles.size - 1 ];
	}
	
	prev = level.hill_angles.size - 2;
	next = level.hill_angles.size - 1;
	
	for( i = 0; i < level.hill_angles.size - 1; i++ )
	{
		if( angle >= level.hill_angles[i] && angle < level.hill_angles[i+1] )
		{
			prev = i;
			next = i+1;
		}
	}

	ratio_next = (angle - level.hill_angles[prev])/(level.hill_angles[next] - level.hill_angles[prev]);
	
	if( ratio_next <= 0 )
	{
		ratio_next = 0.01;
	}
	
	prevInAnim = animArray( "hill_up_in_"+level.hill_angles[prev], movement );
	prevOutAnim = animArray( "hill_up_out_"+level.hill_angles[prev], movement );
	prevAnim = animArray( "hill_up_"+level.hill_angles[prev], movement );
	nextInAnim = animArray( "hill_up_in_"+level.hill_angles[next], movement );
	nextOutAnim = animArray( "hill_up_out_"+level.hill_angles[next], movement );
	nextAnim = animArray( "hill_up_"+level.hill_angles[next], movement );
	
	inLength = Length( GetMoveDelta( prevInAnim, 0, 1) );
	outLength = Length( GetMoveDelta( prevOutAnim, 0, 1 ) );
	cycles = (fullRun - inLength - outLength ) /(  Length( GetMoveDelta( prevAnim, 0, 1 ) ) * (1 - ratio_next ) + Length( GetMoveDelta( nextAnim, 0, 1 ) ) * ratio_next );
	
	animTime = (cycles * GetAnimLength( prevAnim )) - 0.3;

	self.traverseDeathIndex = 0;

	self ClearAnim( %body, 0.25 );
	self notify( "begin_hill" );
	if( ratio_next < 1 )
	{
		self SetFlaggedAnimRestart( "prevInAnim", prevInAnim, 1 - ratio_next, 0.25, 1.0 );
		self thread animscripts\shared::DoNoteTracks( "prevInAnim", ::handleTraverseNotetracks );
	}
	if( ratio_next > 0 )
	{
		self SetFlaggedAnimRestart( "nextInAnim", nextInAnim, ratio_next, 0.25, 1.0 );
		self thread animscripts\shared::DoNoteTracks( "nextInAnim", ::handleTraverseNotetracks );
	}
	wait( GetAnimLength( prevInAnim ) );

	self ClearAnim( %hill, 0.05 );
	if( ratio_next < 1 )
	{
		self SetFlaggedAnimRestart( "prevAnim", prevAnim, 1 - ratio_next, 0.05, 1.0 );
		self thread animscripts\shared::DoNoteTracks( "prevAnim", ::handleTraverseNotetracks );
	}
	if( ratio_next > 0 )
	{
		self SetFlaggedAnimRestart( "nextAnim", nextAnim, ratio_next, 0.05, 1.0 );
		self thread animscripts\shared::DoNoteTracks( "nextAnim", ::handleTraverseNotetracks );
	}
	
	wait( animTime );
	
	self ClearAnim( %hill, 0.2 );
	if( ratio_next < 1 )
	{
		self SetFlaggedAnimRestart( "prevOutAnim", prevOutAnim, 1 - ratio_next, 0.2, 1.0 );
		self thread animscripts\shared::DoNoteTracks( "prevOutAnim", ::handleTraverseNotetracks );
	}
	if( ratio_next > 0 )
	{
		self SetFlaggedAnimRestart( "nextOutAnim", nextOutAnim, ratio_next, 0.2, 1.0 );
		self thread animscripts\shared::DoNoteTracks( "nextOutAnim", ::handleTraverseNotetracks );
	}
	wait( GetAnimLength( prevOutAnim ) - 0.1 );
	if( !isAlive( self ) )
	{
		return;
	}
	
	self.a.nodeath = false;
	self.a.disablePain = false;
	self notify( "finish_hill" );
	
	self SetAnimKnobAllRestart( animscripts\run::GetRunAnim(), %body, 1, 0.3, 1 );

	wait( 0.3 );
}

do_hill_pain_anims()
{
	self endon( "death" );
	self endon( "finish_hill" );
	
	while( true )
	{
		wait( 0.05 );
	}
}

do_hill_death_anims()
{
	self endon( "delete" );
	self endon( "finish_hill" );
	
	self waittill( "death" );
	
	if( IsDefined( self ) )
	{
		self StartRagdoll();
	}
}

do_hill_aim_anims()
{
	self endon( "killanimscript" );
	self endon( "death" );
	self endon( "stop tracking" );
	self endon( "finish_hill" );
	
	self.traverseAimAnims = [];
	self.traverseAimAnims["up"]		= animArray( "staircase_aim_up", "move" );
	self.traverseAimAnims["down"]	= animArray( "staircase_aim_down", "move" );
	self.traverseAimAnims["left"]	= animArray( "staircase_aim_left", "move" );
	self.traverseAimAnims["right"]	= animArray( "staircase_aim_right", "move" );
	
	self.a.isAiming = true;
	self.aimAngleOffset = 0;	

	assert( IsDefined( self.traverseAimAnims ) );

	self waittill( "begin_hill" );

	self SetAnimKnobLimited( self.traverseAimAnims["up"],		1, 0.2 );
	self SetAnimKnobLimited( self.traverseAimAnims["down"],		1, 0.2 );
	self SetAnimKnobLimited( self.traverseAimAnims["left"],		1, 0.2 );
	self SetAnimKnobLimited( self.traverseAimAnims["right"],	1, 0.2 );

	self.rightAimLimit	= 50;
	self.leftAimLimit	= -50;
	self.upAimLimit		= 50;
	self.downAimLimit	= -50;

	self animscripts\shared::setAimingAnims( %traverse_aim_2, %traverse_aim_4, %traverse_aim_6, %traverse_aim_8 );
	self animscripts\shared::trackLoopStart();

	self animscripts\weaponList::RefillClip();

	self.shoot_while_moving_thread = undefined;
	self thread animscripts\run::runShootWhileMovingThreads();
}