//
// file: creek_1_amb.gsc
// description: level ambience script for creek_1
// scripter: 
//

#include maps\_ambientpackage;
#include maps\_utility;
#include common_scripts\utility; 


main()
{
	//thread play_village_ambiences();
	thread hut_explo_fires();
	thread river_hut_explo();
	thread jumpto_check();
	thread play_distant_battle();
	//thread bucket_test();
}

play_village_ambiences()
{
	level waittill( "screen_fade_in_begins" );
	
	org1 = Spawn( "script_origin", (-25400, 37128, 120) );
	org2 = Spawn( "script_origin", (-24464, 35696, 144) );
	org3 = Spawn( "script_origin", (-23336, 35072, 104) );
	
	org1 PlayLoopSound( "amb_village_radio" );
	org2 PlayLoopSound( "amb_village_pluck" );
	org3 PlayLoopSound( "amb_village_men" );
	
	level waittill( "break_stealth" );
	
	org1 StopLoopSound(1);
	org2 StopLoopSound(1);
	org3 StopLoopSound(1);
	org1 Delete();
	org2 Delete();
	org3 Delete();
}

hut_explo_fires()
{
	level waittill( "hut_explo" );
	
	hut_destroyed = GetEnt( "roof_destroyed", "targetname" );
	
	playsoundatposition ("evt_creek_sampan_exp", hut_destroyed.origin);
	hut_destroyed playsound( "exp_hut_l" );
	wait .2;
	hut_destroyed playsound( "exp_hut_flame_l" );
	wait .1;
	
	
	org1 = Spawn( "script_origin", (-24192, 35560, 176) );
	wait_network_frame();
	org2 = Spawn( "script_origin", (-24136, 35280, 184) );
	wait_network_frame();
	org3 = Spawn( "script_origin", (-24616, 35728, 128) );
	wait_network_frame();
	org4 = Spawn( "script_origin", (-24480, 35736, 128) );
	wait_network_frame();
	org5 = Spawn( "script_origin", (-24536, 35689, 128) );
	wait_network_frame();
	
	org1 playloopsound( "evt_creek_hut_fire1" );
	org2 playloopsound( "evt_creek_hut_fire3" );
	org3 playloopsound( "amb_fires" );
	org4 playloopsound( "evt_creek_hut_fire1" );
	org5 playloopsound( "evt_creek_hut_fire2" );
	
	wait .7;
	
	hut_destroyed playsound( "evt_creek_debris1_imp" );
	wait .2;
	hut_destroyed playsound( "evt_creek_debris2_imp" );
	
	wait .2;
	
	hut_destroyed playsound( "evt_creek_hut_debris_f" );
	
	
}

bucket_test()
{
	clip_brush = GetEnt( "bucket_clip", "targetname" );
	trigger = GetEnt( "bucket_trigger", "targetname" );
	
	trigger waittill( "trigger" );
	
	PhysicsExplosionSphere( (-26123.5, 36869, 23.5), 50, 25, .2 );
	wait(.4);
	PlaySoundatposition( "evt_bucket_drop", (0,0,0) );
}

river_hut_explo()
{
	level waittill( "waterhut_start" );
	river_hut = GetEnt( "trigger_blow_wooden_island", "targetname" );
	river_hut playsound( "evt_creek_riverhut_exp" );
}

jumpto_check()
{
	wait(3);
	
	if( IsDefined(level.skipped_to_event_2) || IsDefined(level.skipped_to_event_3) || IsDefined(level.skipped_to_event_4) || IsDefined(level.skipped_to_event_5) )
	{
		clientNotify( "skip" );
	}
}

m60_turret_audio_thread()
{
	if(IsDefined(self))
	{
			self thread m60_turret_audio( "wpn_btr_turret_fire_loop_plr" , "wpn_btr_turret_fire_loop_ring_plr" , "wpn_btr_fire_loop_npc" , "wpn_btr_fire_loop_ring_npc" );
	}
}

m60_turret_audio( alias1 , alias2 , alias3 , alias4 )//1= plr loop 2 = plr ringoff 3 = npc loop 4 = npc ringoff
{
	self endon( "death" );
	player = get_players()[0];
	sound_ent = Spawn( "script_origin", self.origin );
	while(1)
	{
		//PrintLn("M60 0");
		turret_user = self GetTurretOwner();
		if( (Player.usingturret) && IsDefined(turret_user) && (turret_user == player) )
		{
			weapon_overheating = player isWeaponOverheating();
			while( (Player.usingturret) && (!player AttackButtonPressed() || weapon_overheating) )//waiting while you are on turret and not firing or overheating
			{
				//PrintLn("M60 1");
				weapon_overheating = player isWeaponOverheating();
				wait( 0.05 );
			}
			while( (Player.usingturret) && player AttackButtonPressed() && !weapon_overheating )// firing turret
			{
				//PrintLn("M60 2 " + player.usingturret + " " + player attackbuttonpressed() + " " + weapon_overheating);
				weapon_overheating = player isWeaponOverheating();
				player playloopsound( alias1 );
				wait( 0.05 );
			}
			if( (Player.usingturret) && !player AttackButtonPressed() )//if the player lets go of the trigger
			{
				//PrintLn("M60 3");
				player stoploopsound();
				player playsound( alias2 );
				wait_network_frame();
			}
			else if( (!Player.usingturret) && player AttackButtonPressed() )//this is if you are hollding the trigger and press x to get off the turret
			{
				//PrintLn("M60 4");
				player stoploopsound();
				player playsound( alias2 );
			}
			else if( (Player.usingturret) && player AttackButtonPressed()&& weapon_overheating )//this is for overheat
			{
				//PrintLn("M60 5");
				player stoploopsound();
				player playsound( alias2 );
				player playsound( "wpn_turret_overheat_plr" );
				while( weapon_overheating )//waits for overheat to finish
				{
					weapon_overheating = player isWeaponOverheating();
					wait( 0.05 );
				}
			}
			if( (!Player.usingturret))//this is a special case that covers the time that it takes to recognize your not on the turret.
			{
				//PrintLn("M60 6");
				player stoploopsound();
			}
		}
		while( IsTurretActive( self ) && (!Player.usingturret) )
		{
			//PrintLn("M60 0");
			while(!IsTurretFiring( self ))
			{
			wait( 0.05 );
			//PrintLn("M60 1 " + IsTurretActive( self ));
			}
			while(IsTurretFiring( self ))
			{
			sound_ent playloopsound( alias3 );
			//PrintLn("M60 2 " + IsTurretFiring( self ));
			wait( 0.05 );
			}
			//PrintLn("M60 3");
			sound_ent stoploopsound();
			sound_ent playsound( alias4 );
		}
		//PrintLn("M60 4");
		sound_ent stoploopsound();
		wait( 0.05 );	
	}
}
play_distant_battle()
{
	level endon ("inside_cave");
	level waittill ("aa_gun_destroyed");
	
	level thread play_distant_battle_track();

	while(1)
	{
		wait (randomintrange (2, 5));
		rand = randomintrange(0,2);
		if (rand == 0)
		{
			playsoundatposition  ("evt_bomb_distant", (	-19728, 35096, 264));
			
		}	
		if (rand == 1)
		{
			playsoundatposition  ("evt_bomb_distant", (	-20424, 34872, 264));
			
		}
		if (rand == 2)
		{
			playsoundatposition  ("evt_bomb_distant", (	-19960, 34624, 264));
			
		}
		
	}
	
}
play_distant_battle_track()
{
	ent1 = spawn ("script_origin", (-19728, 35096, 264));
	ent2 = spawn ("script_origin", (-19960, 34624, 264));
	
	ent1 playloopsound ("amb_fake_battle_l");
	ent2 playloopsound ("amb_fake_battle_r");
	
	level waittill ("inside_cave");
	
	ent1 stoploopsound(4);
	ent2 stoploopsound(4);
	wait(4);
	ent1 delete();
	ent2 delete(); 
	
}

