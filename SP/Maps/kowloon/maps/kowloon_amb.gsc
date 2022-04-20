//
// file: kowloon_amb.gsc
// description: level ambience script for kowloon
// scripter: 
//
#include maps\_utility;
#include common_scripts\utility;
#include maps\_ambientpackage;
#include maps\_music;


main()
{

	level thread play_TV();
	level thread play_TV_2();
	level thread play_outside_rain_emitter_intro();

//************************************************************************************************
//                                      THREAD FUNCTIONS
//************************************************************************************************	

	array_thread(GetEntArray("fly_sec_door_damage", "targetname"), ::security_door_damage);
	
	array_thread(GetEntArray("amb_computer_a", "targetname"), ::computer_loop);
	array_thread(GetEntArray("amb_computer_a", "targetname"), ::computer_damage);
	
	array_thread(GetEntArray("amb_ham_radio", "targetname"), ::ham_radio_loop);
	array_thread(GetEntArray("amb_ham_radio", "targetname"), ::ham_radio_damage);
	
	array_thread(GetEntArray("amb_gas_hiss", "targetname"), ::gas_hiss_damage);
	
	array_thread(GetEntArray("amb_civ_male", "targetname"), ::amb_civ_male_loop);	
	array_thread(GetEntArray("amb_civ_female", "targetname"), ::amb_civ_female_loop);	
	
	array_thread(GetEntArray("amb_civ_female_w_dog", "targetname"), ::amb_civ_female_w_dog_loop);	
	array_thread(GetEntArray("amb_dog_damage", "targetname"), ::amb_dog_loop);	
	array_thread(GetEntArray("amb_dog_damage", "targetname"), ::amb_dog_damage);
	
	array_thread( getstructarray( "amb_civ_multiple", "targetname" ), ::play_civ_lines );			
	
}
play_TV()
{
	wait(5);
	TV_sound = spawn ("script_origin", (640, -216, 3192));
	TV_sound playloopsound ("mus_chinese_music_TV");	
	
	
	trigger_tv_1 = getent ("amb_tv_01", "targetname");
	if (IsDefined ( trigger_tv_1 ))
	{
//		iprintlnbold ("found a tv trigger at 640, -216, 3192");
		trigger_tv_1 waittill ("trigger");
//		iprintlnbold ("Damage!!");		
		tv_sound stoploopsound ();
		wait (1.0);
		tv_sound delete();	
//		iprintlnbold ("DELETED!!");	
		
	}
	
}
play_TV_2()
{
	wait(5);
	TV_sound_b = spawn ("script_origin", (-2240, -200, 1024));
	TV_sound_b playloopsound ("mus_chinese_music_TV_02");	
	
	trigger = getent ("amb_tv_02", "targetname");
	if (IsDefined ( trigger ))
	{
//		iprintlnbold ("found a tv trigger");
		trigger waittill ("trigger");
//		iprintlnbold ("Damage!!");		
		TV_sound_b stoploopsound ();
		wait (1.0);
		TV_sound_b delete();	
		wait(0.5);
//		iprintlnbold ("DELETED!!");	
	
	}
		
	
}


	
//************************************************************************************************
//                                      DAMAGE TRIGGERS
//************************************************************************************************		
	
//************ security doors ************

security_door_damage()
{
	while (1)
	{
		self waittill ("trigger");
		self playsound("fly_sec_door_damage");
	}	
}

//************ computers ************

computer_loop()
{

	self playloopsound ("amb_computer_run");

}	

	
computer_damage()
{

	self waittill ("trigger");
	self playsound ("amb_computer_shut_down");
	self stoploopsound();	
	
}

//************ ham radio ************

ham_radio_loop()
{

	self playloopsound ("amb_ham_loop");

}	

	
ham_radio_damage()
{

	self waittill ("trigger");
	self playsound ("amb_ham_shut_down");
	self stoploopsound();	
	
}

//************ gas pipe ************

gas_hiss_damage()
{

	self waittill ("trigger");
	self playloopsound ("amb_gas_hiss");

}

//************ civilians ************

//self = civilian ai

amb_civ_male_loop()
{
	while(1)
	{
		wait(randomfloatrange( 2, 6 ) );
		rand = randomintrange( 0, 100 );
	
		if( rand > 50 )
		{
			self playsound( "amb_civilian_male" );
		}
	}
}


amb_civ_female_loop()
{
	while(1)
	{
		wait(randomfloatrange( 2, 6 ) );
		rand = randomintrange( 0, 100 );
	
		if( rand > 50 )
		{
			self playsound( "amb_civilian_female" );
		}
	}
}

amb_civ_female_w_dog_loop()
{
	level endon( "dog_damage" );
	self thread amb_civ_female_scream();
	
	while(1)
	{
		wait(randomfloatrange( 2, 6 ) );
		rand = randomintrange( 0, 100 );

		if( rand > 50 )
		{
		self playsound( "amb_civilian_female" );
		}
	}
}

//************ dog ************

amb_dog_loop()
{
	level endon( "dog_damage" );
			while(1)
		{
			wait(randomfloatrange( 1.8, 2.3 ) );
			self playsound( "amb_dog_large" );
		}
}	

	
amb_dog_damage()
{

	self waittill ("trigger");
	level notify( "dog_damage" );
	self stopsounds();
	wait (.33);
	self playsound ("amb_dog_pain");
	
	
}

amb_civ_female_scream()
{

	level waittill( "dog_damage" );
	self stopsounds();
	wait (.75);
	self playsound ("amb_civilian_female_scream");
	
}

play_civ_lines()
{ 
    flag_wait( "all_players_connected" );
    
    if( !IsDefined( self ) )
        return;
    
    player = get_players()[0];
    rand_guy = RandomIntRange(0,5);
    self.break_out = false;
    
    while(1)
    {
        dist = DistanceSquared( self.origin, player.origin );
        
        if( dist > (8000*8000) )
        {
            wait(20);
            continue;
        }
        else if( dist > (2000*2000) )
        {
            wait(10);
            continue;
        }
        else if( dist > (1000*1000) )
        {
            wait(2);
            continue;
        }
        else if( dist > (500*500) )
        {
            wait(1);
            continue;
        }
        else if( dist < (500*500) )
        {
            while(1)
            {
                playsoundatposition( "amb_civ_" + rand_guy + "_talk", self.origin );
                wait_time = RandomFloatRange(3,9);
                
                for( i=0; i<(wait_time * 10 ); i++ )
                {
                    if( player IsFiring() )
                    {
                        self.break_out = true;
                        break;
                    }
                    
                    wait(.1);
                }
                
                if( self.break_out == true )
                    break;
            }
            break;
        }
    }
    
    PlaySoundatposition( "amb_civ_" + rand_guy + "_scream", self.origin );
}
play_outside_rain_emitter_intro()
{
	rain_ent = spawn ("script_origin", (1632, 736, 3480));	
	level waittill ("window_break");
	wait(1.0);
	rain_ent playloopsound ("amb_rain_broken_window");
	
}