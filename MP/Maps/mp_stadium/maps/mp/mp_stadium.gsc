#include maps\mp\_utility;
main()
{
	//needs to be first for create fx
	maps\mp\mp_stadium_fx::main();

	maps\mp\_load::main();

	maps\mp\mp_stadium_amb::main();

//	maps\mp\_compass::setupMiniMap("compass_map_mp_stadium"); 
	if ( GetDvarInt( #"xblive_wagermatch" ) == 1 )
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_stadium_wager");
	}
	else
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_stadium");
	}	
	

	// If the team nationalites change in this file,
	// you must update the team nationality in the level's csc file as well!
	maps\mp\gametypes\_teamset_urbanspecops::level_init();

  
	// enable new spawning system
	maps\mp\gametypes\_spawning::level_use_unified_spawning(true);
	
	thread tvsound();
}

tvsound ()
    {
        audio_trigger_damage = GetEnt("amb_tv_damage", "targetname");
 	
 	    if (isdefined (audio_trigger_damage))
	    { 	
	    	tv = getent("amb_tv_origin", "targetname");		
	    	tv playloopsound ("amb_monitor_whine");
		    audio_trigger_damage waittill( "trigger", amount, attacker, direction, point, method );	
		    tv stoploopsound (.2);
			wait .5;
		//	tv PlayLoopSound ("amb_monitor_static");	       	                  	        
	    }
    }        
        
  

        