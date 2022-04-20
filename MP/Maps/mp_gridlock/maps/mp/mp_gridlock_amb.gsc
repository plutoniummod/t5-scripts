//
// file: mp_gridlock_amb.gsc
// description: level ambience script for mp_gridlock
// scripter: 
//

#include maps\mp\_utility;
#include maps\mp\_ambientpackage;
#include common_scripts\utility;

main()
{
	thread cafe_jukebox();
	thread tv_sound();
}

cafe_jukebox()
{
	audio_trigger_damage = getent("amb_juke_music", "targetname");

 	if (isdefined (audio_trigger_damage))
	{ 	
		jukebox = getent("amb_juke_music_origin", "targetname");
		jukebox playloopsound ("amb_juke_song");
		jukeplaying = true;

		
		while (jukeplaying)		
		{
			audio_trigger_damage waittill( "damage", amount, attacker, direction, point, method );
	
				jukebox stoploopsound (.2);
				wait .5;
				jukebox playsound ("dst_electronics_sparks_lg");
				jukeplaying = false;

				wait .5;
		}
		wait .5;
	}
}	


tv_sound()
{
    tv_damage_trigs = GetEntArray ("amb_tv_damage", "targetname");
    if (isdefined (tv_damage_trigs))
	  {
    	array_thread (tv_damage_trigs, ::tv_whine);
    }
}

tv_whine()
{
		self playloopsound ("amb_tv_whine");
		self waittill( "trigger", amount, attacker, direction, point, method );	
		self stoploopsound (.2);
		wait .5;       	                  	        
}
       
        
