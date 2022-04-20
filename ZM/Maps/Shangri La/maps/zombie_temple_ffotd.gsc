#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include animscripts\zombie_Utility;


main_start()
{
	SetSavedDvar( "sm_sunShadowSmallScriptPS3OnlyEnable", true );
	PreCacheModel("p_glo_corrugated_metal1");
	
	level thread spikemore_delete_all_on_end_game();
	
	PreCacheModel("collision_wall_256x256x10");
}


main_end()
{
	seam_debris = spawn("script_model", (-574, -1108.5, -415));
	seam_debris setmodel("p_glo_corrugated_metal1");
	seam_debris.angles = (359.542, 192.199, 89.6195);

	// mine cart platform collision fix.
	collision = spawn("script_model", (1623, -668, 114));
	collision setmodel("collision_wall_256x256x10");
	collision.angles = (0, 0, 0);
	collision Hide();


	level.timed_killbrush_in_start_area_geyser = maps\_zombiemode::spawn_kill_brush( (-25, -1025, -175), 90, 170 );
	level.timed_killbrush_in_minecart_area_geyser = maps\_zombiemode::spawn_kill_brush( (1092, -1000, -100), 60, 90 );
	level.player_out_of_playable_area_monitor_callback = ::zombie_temple_player_out_of_playable_area_monitor_callback;
}


spikemore_delete_all_on_end_game()
{
	level waittill( "end_game" );
	
	if ( !isdefined( level.spikemores ) )
	{
		return;
	}
	
	for ( i = level.spikemores.size - 1; i >= 0; i-- )
	{
		level.spikemores[i] delete();
	}
}


zombie_temple_player_out_of_playable_area_monitor_callback()
{
	if ( is_true( self.on_slide ) )
	{
		return false;
	}

	if ( is_true( self.riding_geyser ) )
	{
		return false;
	}

	if ( is_true( self.is_on_minecart ) )
	{
		return false;
	}

	if ( self istouching( level.timed_killbrush_in_start_area_geyser ) )
	{
		// if they are touching this trigger consecutively for 3 seconds, let the kill thread kill, they are exploiting 
		for ( i = 0; i < 60; i++ )
		{
			wait( 0.05 );

			if ( !self istouching( level.timed_killbrush_in_start_area_geyser ) )
			{
				return false;
			}
		}
	}

	if ( self istouching( level.timed_killbrush_in_minecart_area_geyser ) )
	{
		// if they are touching this trigger consecutively for 3 seconds, let the kill thread kill, they are exploiting 
		for ( i = 0; i < 60; i++ )
		{
			wait( 0.05 );

			if ( !self istouching( level.timed_killbrush_in_minecart_area_geyser ) )
			{
				return false;
			}
		}
	}

	return true;
}

