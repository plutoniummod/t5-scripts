#include animscripts\utility;
#include animscripts\traverse\zombie_shared;
#using_animtree ("generic_human");

main()
{
	if( IsDefined( self.is_zombie ) && self.is_zombie )
	{
		if ( self.has_legs == true )
		{
			if ( self.animname == "monkey_zombie" )
			{
				jump_up_monkey();
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
}

jump_up_zombie()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			= %ai_zombie_jump_up_geyser_alt;

	DoTraverse( traverseData );
}

jump_up_crawler()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			= %ai_zombie_crawl_jump_up_geyser_alt;

	DoTraverse( traverseData );
}

jump_up_monkey()
{
	traverseData = [];
	traverseData[ "traverseAnim" ] 			= %ai_zombie_monkey_jump_up_geyser_alt;
	
	DoTraverse( traverseData );
}


