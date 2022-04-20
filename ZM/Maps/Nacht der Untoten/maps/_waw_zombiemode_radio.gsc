#include maps\_utility;
#include common_scripts\utility;

init()
{

	level._ZOMBIE_RADIO_CLIENTFLAG = 14;

	// radio spark
	level._effect["broken_radio_spark"] = LoadFx( "env/electrical/fx_elec_short_oneshot" );

	name = "kzmb";
	key = "targetname";
	if ( IsDefined( level.kzmb_name ) )
	{
		name = level.kzmb_name;
	}
	if ( IsDefined( level.kzmb_key ) )
	{
		key = level.kzmb_key;
	}

		
	// kzmb, for all the latest killer hits
	radios = getentarray(name, key);
	
	// no radios, return
	if (!isdefined(radios) || !radios.size)
	{
		println("no radios");
		return;
	}

	println("Found radios: " + radios.size);
	
	array_thread(radios, ::zombie_radio_play );
	level thread stop_the_radio();
}
zombie_radio_play()
{
	self setcandamage(true);
	if(!IsDefined (level.music_override))
	{
		level.music_override = false;
	}
	while (1)
	{
		self waittill ("damage");

		println("changing radio stations");
		if(level.music_override != true)
		{
        self SetClientFlag(level._ZOMBIE_RADIO_CLIENTFLAG);      
				wait_network_frame();
				self ClearClientFlag(level._ZOMBIE_RADIO_CLIENTFLAG);
				wait (4);  //adding a wait so you can't spam it anymore and get multiple tracks playing.
		}
	}
}
stop_the_radio()
{
	if(!IsDefined (level.music_override))
	{
		level.music_override = false;
	}
	while(1)
	{
			if (level.music_override == false)
			{
				wait(0.5);
			}
			else
			{
				level clientNotify ("ktr");  //Kill the Radio
				//iprintlnbold ("stopping_radio_from_GSC");
				while ( level.music_override == true)
				{
					wait(0.5);
				}
				level clientNotify ("rrd"); //Resume the radio
				//iprintlnbold ("resuming_radio_from_GSC");
				
			}
			wait(0.5);
	}	
}