#include animscripts\utility;
#include animscripts\traverse\zombie_shared;
#using_animtree ("generic_human");

main()
{
	climb_chain();
}

climb_chain()
{

	traverseData = [];


	traverseData[ "traverseAnim" ]			= %ai_zombie_climb_chain_fast_coast;

/*
	if ( isDefined( level.round_number ) && level.round_number > 3 )
	{
		traverseData[ "traverseAnim" ]			= %ai_zombie_climb_chain_fast_coast;
	}
	else
	{
		traverseData[ "traverseAnim" ]			= %ai_zombie_climb_chain_coast;
	}
*/

	DoTraverse( traverseData );


}
