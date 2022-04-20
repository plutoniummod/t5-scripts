//
// file: rebirth_amb.gsc
// description: level ambience script for rebirth
// scripter: 
//

#include maps\_utility;
#include common_scripts\utility;
#include maps\_ambientpackage;
#include maps\_music;


main()
{

//************************************************************************************************
//                                      THREAD FUNCTIONS
//************************************************************************************************	

	
	array_thread(GetEntArray("amb_computer_a", "targetname"), ::computer_loop_a);
	array_thread(GetEntArray("amb_computer_a", "targetname"), ::computer_damage_a);
	array_thread(GetEntArray("amb_computer_b", "targetname"), ::computer_loop_b);
	array_thread(GetEntArray("amb_computer_b", "targetname"), ::computer_damage_b);
	array_thread(GetEntArray("amb_computer_c", "targetname"), ::computer_loop_c);
	array_thread(GetEntArray("amb_computer_c", "targetname"), ::computer_damage_c);
	
	array_thread(GetEntArray("amb_ham_radio", "targetname"), ::ham_radio_loop);
	array_thread(GetEntArray("amb_ham_radio", "targetname"), ::ham_radio_damage);
		
}

	
//************************************************************************************************
//                                      DAMAGE TRIGGERS
//************************************************************************************************		
	

//************ computers ************

computer_loop_a()
{

	self playloopsound ("amb_computer_a_run");

}	

	
computer_damage_a()
{

	self waittill ("trigger");
	self playsound ("amb_computer_a_shut_down");
	self stoploopsound();	
	
}

computer_loop_b()
{

	self playloopsound ("amb_computer_b_run");

}	

	
computer_damage_b()
{

	self waittill ("trigger");
	self playsound ("amb_computer_b_shut_down");
	self stoploopsound();	
	
}

computer_loop_c()
{

	self playloopsound ("amb_computer_c_run");

}	

	
computer_damage_c()
{

	self waittill ("trigger");
	self playsound ("amb_computer_c_shut_down");
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
play_fake_battle(org)
{
	sound_ent = spawn ("script_origin", org.origin);
	sound_ent playloopsound ("amb_fake_light_battle");
}
play_resolution_music( guy )
{
	//called from motetrack
	setmusicstate ("REZNOV_SPEAKS");	
	
	
}
