//
// file: mp_berlinwall2_amb.gsc
// description: level ambience script for mp_berlinwall2
//

#include maps\mp\_utility;
#include maps\mp\_ambientpackage;
#include common_scripts\utility; 

main()
{
	level.alarm_sound = "off";	
	level.trespassers = 0;	
	//thread alarm_trigger();
    thread Bwall2RecPlayer();
 	
}


alarm_trigger()
{
	siren_trig = GetEntArray ("siren_trigger", "targetname");
 	array_thread( siren_trig, ::snd_alarm_nozone);
}

snd_alarm_nozone()
{
	for (;;)
	{
		self waittill ( "trigger", trigplayer);	
		self thread trigger_thread(trigPlayer, ::alarm_sound_on, ::alarm_sound_off);
	}
}

alarm_sound_on(trigPlayer, endon_string)
{
	level endon ("alarm_off");
	level.trespassers += 1;
	while (1)
	{
		if (level.alarm_sound == "off")
		{			
			alarm = GetEnt ("alarm", "targetname");	
			IPrintLnBold ("play sound");
			alarm PlaySound("evt_alert_siren");	
			level.alarm_sound = "on";		
				
		}
		wait (7);	
		level.alarm_sound = "off";	

	}
}

alarm_sound_off(trigPlayer)
{
 	level.trespassers -= 1;
	if (level.trespassers == 0)
	{
		level.alarm_sound = "off";			

	}
}	

alarm_sound()
{
	level endon ("disconnect");
	while (level.alarm_sound == "on")
	{			
		alarm = GetEnt ("alarm", "targetname");	
		IPrintLnBold ("play sound");
		alarm PlaySound("evt_alert_siren");	
		wait (7);	
	}
	wait (1);		
}

bwall2RecPlayer()
{	
	audio_trgger_damage = getent("amb_rec_player", "targetname");

 	if (isdefined (audio_trgger_damage))
	{ 	
		radio = getent("amb_rec_player_origin", "targetname");		
		radio playloopsound ("amb_rec_player");
		radioplaying = true;
		
		while (radioplaying)		
		{
			audio_trgger_damage waittill( "damage", amount, attacker, direction, point, method );
	
				radio stoploopsound (.2);
			
				//iprintln ("music bar stop loop");
				wait .5;
				radio playsound ("dst_electronics_sparks_lg");
				radioplaying = false;
//			}
			wait .5;
		}
		wait .5;
	}
}