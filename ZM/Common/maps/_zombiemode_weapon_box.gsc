#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;


//*****************************************************************************
//*****************************************************************************

init()
{
	/***************************************/
	/* Do we have a weapon box in the map? */
	/***************************************/

	level.wepbox = GetEnt( "weapon_box" , "targetname" );
	if( !isdefined( level.wepbox ) )
	{
		return;
	}
	
	
	/*******************/
	/* Init weapon box */
	/*******************/
	
	level.wepbox setHintString( &"ZOMBIE_WEAPON_BOX_OPEN" );
	//level.wepbox setHintString( &"ZOMBIE_TRADE_WEAPONS" );
	//level.wepbox setHintString( &"ZOMBIE_WEAPON_BOX_STORE" );
	
	level.wepbox_players = [];
	for( i=0; i<4; i++ )
	{
		level.wepbox_players[i] = "empty";
	}
	
	
	level.wepbox thread weapon_box_update();
}


//*****************************************************************************
//*****************************************************************************

weapon_box_update()
{
	while( 1 )
	{
		self waittill( "trigger", player );

		//player_index = player GetEntityNumber();

		/#
		iprintln( "WEAPON BOX USE" );
		#/
		
		wait( 1.0 );
	}
}


//*****************************************************************************
//*****************************************************************************




