//
// file: hue_city_amb.gsc
// description: level ambience script for hue_city
// scripter: 
//

#include maps\_ambientpackage;
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_busing;
#include maps\_music;

main()
{
	//init_heli_sounds();
//	thread ambient_woosh();
//	thread low_alt_warning();
//	thread evt_1_torture();
//	thread setbusses();
//	thread play_telephone();
//	thread play_chopper_accel();
//	thread sound_timescale_chopper_event();
		level thread bomb_drop();
		level thread heli_attack_entrance();
		level thread heli_attack_destruction();
		level thread heli_attack_bullets_loop();
		level thread tank_intro_music();
		level thread mowdown_minigun();
		level thread morse_guy_sounds_think();
		level thread morse_guy_sounds();
		level thread m60_turret_audio_thread();
		array_thread(GetEntArray("amb_telephone", "targetname"), ::phone_loop);
		array_thread(GetEntArray("amb_telephone", "targetname"), ::phone_damage);
		//level thread play_bullet_impacts();
		//level thread fake_huey_loops();
}
play_telephone()
{
	phone_counter = 0;
	trig = getent("audio_telephone_trigger", "targetname");	
	phone = getstruct ("audio_telephone", "targetname");
	if (IsDefined (trig) && IsDefined (phone))
	{
		trig waittill("trigger");
		
		while(phone_counter < 8)
		{
			playsoundatposition("evt_4_phone", phone.origin);
			wait (3);
			phone_counter ++;
					
		}
	}	
}
setbusses()
{
	wait(5);
	setbusstate("in_chopper");
	level waittill("out_of_chopper");
	setbusstate("default");
		
}
play_fake_rpg_sound(shotspot, hitspot)
{
	while(1)
	{
		player = getplayers();
		moving_ent = spawn ("script_origin", (0,0,0));
		moving_ent playloopsound("wpn_rpg_loop");
		moving_ent moveTo ( player[0].origin, 1, 0.1, 0.1);
		//wait(5);
		//moving_ent delete();
		
		wait(0.5);
	}
	
}
play_chopper_accel()
{
		wait(2);
	woosh_point = getent("mountain_woosh", "targetname");
	players = getplayers();
	
		dist = distance( players[0].origin, woosh_point.origin);
		//iprintlnbold(dist);
	
	while (distance( players[0].origin, woosh_point.origin) > 13950)	
	{
		wait(0.1);
		dist = distance( players[0].origin, woosh_point.origin);
		//iprintlnbold(dist);
		
	}	
	playsoundatposition ("evt_1_chopper_accel", (0,0,0));
	
}
low_alt_warning()
{
	wait(2);
	woosh_point = getent("mountain_woosh", "targetname");
	players = getplayers();
	
		dist = distance( players[0].origin, woosh_point.origin);
		//iprintlnbold(dist);
	
	while (distance( players[0].origin, woosh_point.origin) > 8250)	
	{
		wait(0.1);
		dist = distance( players[0].origin, woosh_point.origin);
		//iprintlnbold(dist);
		
	}	
	playsoundatposition ("evt_1_low_alt_warning", (0,0,0));
	
	
}
ambient_woosh()
{
	wait(2);
	woosh_point = getent("mountain_woosh", "targetname");
	players = getplayers();
	
		dist = distance( players[0].origin, woosh_point.origin);
		//iprintlnbold(dist);
	
	while (distance( players[0].origin, woosh_point.origin) > 2800)
	{
		wait(0.1);
		dist = distance( players[0].origin, woosh_point.origin);
		//iprintlnbold(dist);
		
	}	
	woosh_point playsound ("amb_deep_whoosh");
	
	
}

play_heli_ext_sounds()  // self is heli
{

	self.soundEntOutsideCruiseRotor =  Spawn( "script_origin", self GetTagOrigin("main_rotor_jnt")); 
	self.soundEntOutsideCruiseRotor linkto(self);
	self.soundEntOutsideCruiseRotor playloopsound("veh_huey_rotor_cruise", 0.2);
	
	
}

play_heli_spin()  // self is heli
{

	//iprintlnbold("RRRRRRRRRRRRRRRRRRRRR");
	self playsound("veh_huey_spin");
	wait (1.5);
	if(IsDefined(self.soundEntOutsideCruiseRotor))
	{
		self.soundEntOutsideCruiseRotor stoploopsound(13.5);
	}
	
}

init_heli_sounds()
{
	level.player_heli1 start_heli_sounds();
}

start_heli_sounds() //self is heli
{
	self.PlayerOutside = false;
	
	
	// Allow time for player spawns
	//wait(5.0);
	
	self thread player_in_or_out();
}

player_in_or_out() //self is heli
{
	self endon("death");

	players = get_players();
	maneuvers_heli_audio_trig_var = getent("maneuvers_heli_audio_trig", "script_noteworthy");
	maneuvers_heli_audio_trig_var enablelinkto();
	maneuvers_heli_audio_trig_var linkto(self);

	self.soundEntInsideIdleRotor =  Spawn( "script_origin", self GetTagOrigin("main_rotor_jnt")); 
	self.soundEntInsideIdleRotor linkto(self);
	self.soundEntInsideIdleRotor playloopsound ("veh_huey_rotor_int_idle",0.2);
	
	self.soundEntInsideIdleLF =  Spawn( "script_origin", self.origin );
	self.soundEntInsideIdleLF linkto(self);
	self.soundEntInsideIdleLF playloopsound ("veh_huey_lf_int_idle", 0.2);

	self.soundEntInsideIdleHF =  Spawn( "script_origin", self.origin );
	self.soundEntInsideIdleHF linkto(self);
	self.soundEntInsideIdleHF playloopsound ("veh_huey_hf_int_idle", 0.2);
	
	self.soundEntInsideIdleWhine =  Spawn( "script_origin", self.origin ); 
	self.soundEntInsideIdleWhine linkto(self);
	self.soundEntInsideIdleWhine playloopsound ("veh_huey_whine_int_idle", 0.2);
	
	self.soundEntRotorWindInt =  Spawn( "script_origin", self.origin );
	self.soundEntRotorWindInt linkto(self);
	self.soundEntRotorWindInt playloopsound("veh_huey_rotor_wind_int_sand", 0.2);
	
	while(true)
	{
		if(self.PlayerOutside)
		{
			while(self.PlayerOutside)
			{
				if ((players[0] istouching (maneuvers_heli_audio_trig_var)))
				{
					self player_entered_heli();
					self.PlayerOutside = false;
				}	

				wait(0.05);
			}
		}	

		while(!self.PlayerOutside)
		{
			if (!((players[0] istouching (maneuvers_heli_audio_trig_var))))
			{
				self player_exited_heli();
				self.PlayerOutside = true;
			}	

			wait(0.05);
		}
	}	
}

player_entered_heli() // self is heli
{
	if(IsDefined(self.soundEntOutsideIdleRotor))
	{
		self.soundEntOutsideIdleRotor stoploopsound(0.5);
	}
	if(IsDefined(self.soundEntOutsideIdleLF))
	{
		self.soundEntOutsideIdleLF stoploopsound(0.5);
	}
	if(IsDefined(self.soundEntOutsideIdleHF))
	{
		self.soundEntOutsideIdleHF stoploopsound(0.5);
	}
	if(IsDefined(self.soundEntOutsideIdleWhine))
	{
		self.soundEntOutsideIdleWhine stoploopsound(0.5);
	}
	
	if(IsDefined(self.soundEntRotorWind))
	{
		self.soundEntRotorWind stoploopsound(1.5);
	}
	
	
	self.soundEntInsideIdleRotor =  Spawn( "script_origin", self GetTagOrigin("main_rotor_jnt")); 
	self.soundEntInsideIdleRotor linkto(self);
	self.soundEntInsideIdleRotor playloopsound ("veh_huey_rotor_int_idle",0.2);
	
	self.soundEntInsideIdleLF =  Spawn( "script_origin", self.origin );
	self.soundEntInsideIdleLF linkto(self);
	self.soundEntInsideIdleLF playloopsound ("veh_huey_lf_int_idle", 0.2);

	self.soundEntInsideIdleHF =  Spawn( "script_origin", self.origin );
	self.soundEntInsideIdleHF linkto(self);
	self.soundEntInsideIdleHF playloopsound ("veh_huey_hf_int_idle", 0.2);
	
	self.soundEntInsideIdleWhine =  Spawn( "script_origin", self.origin ); 
	self.soundEntInsideIdleWhine linkto(self);
	self.soundEntInsideIdleWhine playloopsound ("veh_huey_whine_int_idle", 0.2);
	
	self.soundEntRotorWindInt =  Spawn( "script_origin", self.origin );
	self.soundEntRotorWindInt linkto(self);
	self.soundEntRotorWindInt playloopsound("veh_huey_rotor_wind_int_sand", 0.2);
	
	wait(1.0);
	
 	// delete entities
	if(IsDefined(self.soundEntOutsideIdleRotor))
	{
		self.soundEntOutsideIdleRotor delete();
	}
	if(IsDefined(self.soundEntOutsideIdleLF))
	{
		self.soundEntOutsideIdleLF delete();
	}
	if(IsDefined(self.soundEntOutsideIdleHF))
	{
		self.soundEntOutsideIdleHF delete();
	}
	if(IsDefined(self.soundEntOutsideIdleWhine))
	{
		self.soundEntOutsideIdleWhine delete();
	}
	
	if(IsDefined(self.soundEntRotorWind))
	{
		self.soundEntRotorWind delete();
	}
	
}

player_exited_heli()  // self is heli
{
	if(IsDefined(self.soundEntInsideIdleRotor))
	{
		self.soundEntInsideIdleRotor stoploopsound(0.5);
	}
	if(IsDefined(self.soundEntInsideIdleLF))
	{
		self.soundEntInsideIdleLF stoploopsound(0.5);
	}
	if(IsDefined(self.soundEntInsideIdleHF))
	{
		self.soundEntInsideIdleHF stoploopsound(0.5);
	}
	if(IsDefined(self.soundEntInsideIdleWhine))
	{
		self.soundEntInsideIdleWhine stoploopsound(0.5);
	}
	
	if(IsDefined(self.soundEntRotorWindInt))
	{
		self.soundEntRotorWindInt stoploopsound(0.5);
	}

	self.soundEntOutsideIdleRotor =  Spawn( "script_origin", self GetTagOrigin("main_rotor_jnt")); 
	self.soundEntOutsideIdleRotor linkto(self);
	self.soundEntOutsideIdleRotor playloopsound("veh_huey_rotor_idle", 0.2);
	
	self.soundEntOutsideIdleLF =  Spawn( "script_origin", self.origin );
	self.soundEntOutsideIdleLF linkto(self);
	self.soundEntOutsideIdleLF playloopsound("veh_huey_lf_ext_idle", 0.2);
	
	self.soundEntOutsideIdleHF =  Spawn( "script_origin", self.origin ); 
	self.soundEntOutsideIdleHF linkto(self);
	self.soundEntOutsideIdleHF playloopsound("veh_huey_hf_ext_idle", 0.2);

	self.soundEntOutsideIdleWhine =  Spawn( "script_origin", self.origin );
	self.soundEntOutsideIdleWhine linkto(self);
	self.soundEntOutsideIdleWhine playloopsound("veh_huey_whine_ext_idle", 0.2);

	self.soundEntRotorWind =  Spawn( "script_origin", self.origin );
	self.soundEntRotorWind linkto(self);
	self.soundEntRotorWind playloopsound("veh_huey_rotor_wind_sand", 0.2);
	
	wait(1.0);

	// delete entities
	if(IsDefined(self.soundEntInsideIdleRotor))
	{
		self.soundEntInsideIdleRotor delete();
	}
	if(IsDefined(self.soundEntInsideIdleLF))
	{
		self.soundEntInsideIdleLF delete();
	}
	if(IsDefined(self.soundEntInsideIdleHF))
	{
		self.soundEntInsideIdleHF delete();
	}
	if(IsDefined(self.soundEntInsideIdleWhine))
	{
		self.soundEntInsideIdleWhine delete();
	}

	if(IsDefined(self.soundEntRotorWindInt))
	{
		self.soundEntRotorWindInt delete();
	}
	
}
evt_1_torture()
{
	trig = getent ("audio_torture_trig", "targetname");
	torture = getent("audio_torture", "targetname");
	
	if( IsDefined (trig))
	{
		trig waittill ("trigger", who);
		
		if( IsDefined (torture))
		{
			torture playsound ("evt_4_torture");
		}
			
	}	
	
	
}
evt_1_screams()
{
	
	screamers = getstructarray("audio_screams", "targetname");	
	
	for(i=0; i<screamers.size; i++)
	{
		screamers[i] thread play_evt_1_screams(); 		
			
	}
	
}
play_evt_1_screams()
{
	level endon ("exit_mac_v");
	
	level thread play_evt_4_civs_run();
	
	while(1)
	{
		wait(randomintrange(6, 16));
		playsoundatposition ("evt_4_screams", self.origin);
		wait(randomintrange(4, 14));		
	}	
	
}
play_evt_4_civs_run()
{
	//plays a crowd screaming---greenlight only
	trig = getent("audio_civs_scream", "targetname");
	if(IsDefined ( trig))
	{
		trig waittill("trigger");
		playsoundatposition ("evt_4_civs_run_left", (-77087, -25755, 7664));
		playsoundatposition ("evt_4_civs_run_right", (-76794, -25623, 7776));
		level clientnotify ("top");
	}
	
}
sound_timescale_chopper_event()
{
	level waittill("chopper_shooting");
	SetTimeScale( 0.75 );
	playsoundatposition ("evt_4_time_slow_in", (0,0,0));
	
	level clientnotify ("csfx");	
	level waittill("chopper_done_shooting");
	playsoundatposition ("evt_4_time_slow_out", (0,0,0));
	level clientnotify ("rsfx");
	settimescale(1);
		
	
	
}

heli_attack_entrance()
{
	trig = getent ("heli_entrance", "targetname");
	org = getent ("heli_attack_1", "targetname");
	
	if( IsDefined (trig))
	{
		trig waittill ("trigger");
		//iprintlnbold("HERE IT COMES");
		if( IsDefined (org))
		{
			org playsound ("evt_huey_attack_attack_1");
			wait (1.5);
			org playloopsound ("evt_huey_attack_attack_2_loop", 3.0);
			//level waittill ("chopper_shooting");
			wait (40);
			org stoploopsound(10);
		}			
			
	}
	//trig Delete();
	//org Delete();	
}

heli_attack_destruction()
{

		dst1 = getstruct("dst_a1", "targetname");
		dst2 = getstruct("dst_a2", "targetname");
		dst3 = getstruct("dst_a3", "targetname");
		dst4 = getstruct("dst_a4", "targetname");
		
		level waittill ("chopper_shooting");
	
		//iprintlnbold("HERE IT COMES");
		if( IsDefined (dst1))
		{
			wait (0.3);
			PlaySoundAtPosition("evt_huey_attack_dst_9", dst1.origin);
			wait (0.2);
			PlaySoundAtPosition("evt_huey_attack_dst_10", dst1.origin);
			wait (0.15);
			PlaySoundAtPosition("evt_huey_attack_dst_13", dst1.origin);
			wait (0.2);
			PlaySoundAtPosition("evt_huey_attack_dst_8", dst1.origin);
			wait (0.1);
			PlaySoundAtPosition("evt_huey_attack_dst_9", dst1.origin);
			wait (0.3);
			PlaySoundAtPosition("evt_huey_attack_dst_1", dst1.origin);

		}	
		
		//wait (0.1);
			if( IsDefined (dst2))
		{
				PlaySoundAtPosition("evt_huey_attack_dst_10", dst2.origin);
				wait (0.1);
				PlaySoundAtPosition("evt_huey_attack_dst_8", dst2.origin);
				wait (0.05);
				PlaySoundAtPosition("evt_huey_attack_dst_9", dst2.origin);
				wait (0.1);
				PlaySoundAtPosition("evt_huey_attack_dst_7", dst2.origin);
				wait (0.4);
				PlaySoundAtPosition("evt_huey_attack_dst_5", dst2.origin);
				wait (0.3);
				PlaySoundAtPosition("evt_huey_attack_dst_14", dst2.origin);
				wait (0.2);
				PlaySoundAtPosition("evt_huey_attack_dst_2", dst2.origin);
		
		}			
		//wait (0.3);
			if( IsDefined (dst3))
		{
				PlaySoundAtPosition("evt_huey_attack_dst_4", dst3.origin);
				wait (0.2);
				PlaySoundAtPosition("evt_huey_attack_dst_3", dst3.origin);
				wait (0.15);
				PlaySoundAtPosition("evt_huey_attack_dst_2", dst3.origin);
				wait (0.15);
				PlaySoundAtPosition("evt_huey_attack_dst_1", dst3.origin);
				wait (0.2);
				PlaySoundAtPosition("evt_huey_attack_dst_14", dst3.origin);
				wait (0.3);
				PlaySoundAtPosition("evt_huey_attack_dst_10", dst3.origin);
				wait (0.35);
				PlaySoundAtPosition("evt_huey_attack_dst_5", dst3.origin);
				wait (0.25);
				PlaySoundAtPosition("evt_huey_attack_dst_13", dst3.origin);
				wait (0.2);
				PlaySoundAtPosition("evt_huey_attack_dst_12", dst3.origin);
				wait (0.32);
				PlaySoundAtPosition("evt_huey_attack_dst_8", dst3.origin);
		
		}	
				
		//wait (0.12);
			if( IsDefined (dst4))
		{
				PlaySoundAtPosition("evt_huey_attack_dst_5", dst4.origin);
				wait (0.2);
				PlaySoundAtPosition("evt_huey_attack_dst_14", dst4.origin);
				wait (0.15);
				PlaySoundAtPosition("evt_huey_attack_dst_12", dst4.origin);
				wait (0.15);
				PlaySoundAtPosition("evt_huey_attack_dst_13", dst4.origin);
				wait (0.2);
				PlaySoundAtPosition("evt_huey_attack_dst_11", dst4.origin);
				wait (0.02);
				PlaySoundAtPosition("evt_huey_attack_dst_2", dst4.origin);
				wait (0.3);
				PlaySoundAtPosition("evt_huey_attack_dst_10", dst4.origin);
				wait (0.35);
				PlaySoundAtPosition("evt_huey_attack_dst_9", dst4.origin);
				wait (0.25);
				PlaySoundAtPosition("evt_huey_attack_dst_14", dst4.origin);
				wait (0.04);
				PlaySoundAtPosition("evt_huey_attack_dst_3", dst4.origin);
			}			
}

heli_attack_bullets_loop()
{
		dst_mga = getstruct("dst_mg", "targetname");
		level waittill ("chopper_shooting");

		if( IsDefined (dst_mga))
		{
			mga_ent = spawn ("script_origin", dst_mga.origin);
			mga_ent playloopsound ("evt_huey_attack_attack_4_loop");
			
			level waittill ("chopper_shooting_end");
			mga_ent stoploopsound(0.3);
			mga_ent playsound ("evt_huey_attack_attack_4_end");
			
			wait (2.0);
			mga_ent delete();
		}
}

tank_intro_music()
{
	level waittill( "tank01_entrance_start" );
	wait 6;
//	setmusicstate("METAL_LOOP2");
}

fake_huey_loops()
{
	wait (0.5);
	//iprintlnbold("FAKE HUEY");
	player = getplayers();
	level.huey_ent = spawn ("script_origin", player[0].origin);
	//huey_ent = spawn ("script_origin", (0,0,0));
	level.huey_ent linkto (player[0]);
	level.huey_ent playloopsound ("veh_huey_rotor_idle_sp", 1.5);
	
}	

bomb_drop()
{
	level waittill( "bomb_drop" );
	
	wait 3;
	playsoundatposition( "evt_bomb_whistle2" , (-3663,1843,8208) );
	
	wait 2;
	playsoundatposition( "evt_bomb" , (-3665,1843,8208) );
	
}


play_bullet_impacts()
{
	wait_for_all_players();
	player = get_players()[0];
                
	wait 20;
                
	player PlaySound( "evt_heli_hit_1" );
	
	wait 2;
	
	player PlaySound( "evt_heli_hit_2" );
}




play_cb_chatter()
{
	wait_for_all_players();
	player = get_players()[0];
	
	clientnotify( "heli_intro_verb" );
	
	player playloopsound( "amb_radio_chatter" , 1 );
	
	level waittill( "cb_chatter_off" );
	clientnotify( "heli_intro_verb_off" );
	player stoploopsound(9);
}

morse_guy_sounds_think()
{
	level waittill("morse_interrupted");
	//iprintlnbold("GOTCHA!!!");
	wait(2);
	level notify ("stop_sending");
	if(isdefined(level.morse_code))
		{
			level.morse_code delete();
		}		
}	

morse_guy_sounds()
{
	level endon ("stop_sending");
	level.morse_code = spawn ("script_origin", (-4170, -8885, 7648));
	for(;;)
	{
		level.morse_code playsound("evt_morse_code", "morse_delay");
		level.morse_code waittill("morse_delay");
		//wait (0.1);
	}		
}
mowdown_minigun()
{
	level waittill( "mowdown_starts" );
	player = get_players()[0];
	
	player playsound( "evt_minigun_spin_up");
	wait .9;
	
	player playloopsound( "wpn_minigun_fire_mowdown_loop" , .1 );
	wait 5.5;
	//level waittill( "mowdown_stops" );
	
	player stoploopsound(.1);
	player playsound( "evt_minigun_spin_down" );
	
}

fake_intro_helis_flyby()
{
	wait_for_all_players();
	player = get_players()[0];
	
	wait(22);
	
	player playsound( "evt_heli_flyby2" );
}

aa_gun_wall_audio()
{
	//wall = GetEntArray("aa_gun_tonys_wall", "targetname");
	//wall[0] playsound( "exp_hue_wall_fall" );
	tank = GetEnt("alley_tank", "targetname");
	tank playsound( "exp_hue_wall_fall" );
}

//************ telephone ************

phone_loop()
{
	self endon( "phone_damage" );

		while(1)
		{
			self playsound ("amb_telephone");
			wait (4);
		}

}	

	
phone_damage()
{

	self waittill ("trigger");
	self notify( "phone_damage" );
	self stopsounds();
	
}

m60_turret_audio_thread()
{
	m60_ent1 = getent( "defend_right_mg" , "targetname" );
	m60_ent2 = getent( "defeind_mid_mg" , "targetname" );
	if(IsDefined(m60_ent1) && IsDefined(m60_ent2) )
	{
		m60_ent1 thread m60_turret_audio( "wpn_m60_turret_fire_loop_plr" , "wpn_m60_turret_fire_loop_ring_plr" , "wpn_m60_turret_fire_loop_npc" , "wpn_m60_turret_fire_loop_ring_plr" );
		m60_ent2 thread m60_turret_audio( "wpn_m60_turret_fire_loop_plr" , "wpn_m60_turret_fire_loop_ring_plr" , "wpn_m60_turret_fire_loop_npc" , "wpn_m60_turret_fire_loop_ring_plr" );
	}
}

m60_turret_audio( alias1 , alias2 , alias3 , alias4 )//1= plr loop 2 = plr ringoff 3 = npc loop 4 = npc ringoff
{
	self endon( "death" );
	player = get_players()[0];
	while(1)
	{
		//PrintLn("0");
		turret_user = self GetTurretOwner();
		if( (Player.usingturret) && IsDefined(turret_user) && (turret_user == player) )
		{
			weapon_overheating = player isWeaponOverheating();
			while( (Player.usingturret) && (!player AttackButtonPressed() || weapon_overheating) )//waiting while you are on turret and not firing or overheating
			{
				//PrintLn("1");
				weapon_overheating = player isWeaponOverheating();
				wait( 0.05 );
			}
			while( (Player.usingturret) && player AttackButtonPressed() && !weapon_overheating )// firing turret
			{
				//PrintLn("2 " + player attackbuttonpressed() + " " + player.usingturret + " " + weapon_overheating);
				weapon_overheating = player isWeaponOverheating();
				player playloopsound( alias1 );
				wait( 0.05 );
			}
			wait_network_frame();
			if( (Player.usingturret) && !player AttackButtonPressed() )//if the player lets go of the trigger
			{
				//PrintLn("3");
				player stoploopsound();
				player playsound( alias2 );
				wait_network_frame();
			}
			else if( (!Player.usingturret) && player AttackButtonPressed() )//this is if you are hollding the trigger and press x to get off the turret
			{
				//PrintLn("4");
				player stoploopsound();
				player playsound( alias2 );
			}
			else if( (Player.usingturret) && player AttackButtonPressed()&& weapon_overheating )//this is for overheat
			{
				//PrintLn("5");
				player stoploopsound();
				player playsound( alias2 );
				player playsound( "wpn_turret_overheat_plr" );
				while( weapon_overheating )//waits for overheat to finish
				{
					weapon_overheating = player isWeaponOverheating();
					wait( 0.05 );
				}
			}
			if( (!Player.usingturret) )//this is a special case that covers the time that it takes to recognize your not on the turret.
			{
				PrintLn("6");
				player stoploopsound();
			}
		}
		while( IsTurretActive( self ) && (!Player.usingturret) )
		{
			while(!IsTurretFiring( self ))
			{
			wait( 0.05 );
			}
			while(IsTurretFiring( self ))
			{
			self playloopsound( alias3 );
			wait( 0.05 );
			}
			self stoploopsound();
			self playsound( alias4 );
		}
		wait( 0.05 );	
	}
}