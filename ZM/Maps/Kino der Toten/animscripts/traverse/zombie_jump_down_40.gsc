#include animscripts\utility;
#include animscripts\traverse\zombie_shared;
#using_animtree ("generic_human");

main()
{
	if( IsDefined( self.is_zombie ) && self.is_zombie )
	{
		if ( !self.isdog )
		{
			jump_down_zombie();
		}
		else
		{
			dog_jump_down(40, 7);
		}
	}
}


jump_down_zombie()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			= %ai_zombie_jump_down_40;

	DoTraverse( traverseData );
}
