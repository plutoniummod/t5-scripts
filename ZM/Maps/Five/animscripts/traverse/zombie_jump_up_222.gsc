#include animscripts\utility;
#include animscripts\traverse\zombie_shared;
#using_animtree ("generic_human");

main()
{
	if( IsDefined( self.is_zombie ) && self.is_zombie )
	{
		if ( !self.isdog )
		{ 
			if ( self.has_legs == true )
			{
				if( self.animname == "quad_zombie" )
				{
					jump_up_quad();
				}
				else
				{
					jump_up_zombie();
				}
			}
			else
			{
				jump_up_crawler();
			}
		}
		else
		{
			dog_jump_up(222, 7);
		}
	}
}

jump_up_zombie()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			= %ai_zombie_jump_up_222;

	DoTraverse( traverseData );
}

jump_up_quad()
{
	traverseData = [];
	traverseData[ "traverseAnim" ] 			= %ai_zombie_jump_up_222;
	
	DoTraverse( traverseData );
}


jump_up_crawler()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			= %ai_zombie_jump_up_222;

	DoTraverse( traverseData );
}
