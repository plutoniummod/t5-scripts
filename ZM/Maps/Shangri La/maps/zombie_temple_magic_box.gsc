///  zombie_temple_magic_box.gsc
/// Control magic box indicators

#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;

magic_box_init()
{
	// get a list of all the magic box board indicators
	level thread _update_magic_box_indicators();
	level thread _watch_fire_sale();
}

_update_magic_box_indicators()
{
	// wait for all the clients to be connected before sending them messages
	wait_for_all_players();

	while ( true )
	{
		//setclientsysstate( "box_indicator", _get_current_chest() );

		flag_wait("moving_chest_now");

		//setclientsysstate( "box_indicator", "moving" );

		while ( flag("moving_chest_now") )
		{
			wait(0.1);
		}
	}
}

_watch_fire_sale()
{
	while ( 1 )
	{
		level waittill( "powerup fire sale" );

		//setclientsysstate( "box_indicator", "fire_sale" );

		level waittill( "fire_sale_off");

		//setclientsysstate( "box_indicator", _get_current_chest() );
	}
}

_get_current_chest()
{
	return level.chests[level.chest_index].script_noteworthy;
}

