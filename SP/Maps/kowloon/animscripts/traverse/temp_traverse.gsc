#include common_scripts\utility;
#include maps\_utility;
#include animscripts\traverse\shared;
#include animscripts\anims;

#using_animtree ("generic_human");

main()
{
    startnode = self getnegotiationstartnode();
    endnode = self getnegotiationendnode();
	time = 1.0;

	// Link AI to a script_origin
	anchor = Spawn( "script_origin", self.origin );
	anchor.angles = self.angles ;
	self LinkTo( anchor );

	// Move the anchor to our destination
	anchor MoveTo( endnode.origin, time );
	self OrientMode( "face angle", endnode.angles[1] );
	anchor waittill( "movedone" );

	// Return to normal
	self UnLink();
	self OrientMode( "face default" );
	anchor Delete();

}
