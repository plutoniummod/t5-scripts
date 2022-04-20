//
// file: fullahead_amb.gsc
// description: level ambience script for fullahead
// scripter: 
//

#include maps\_ambientpackage;
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_music;


main()
{
	//declare an ambientpackage, and populate it with elements
	//mandatory parameters are <package name>, <alias name>, <spawnMin>, <spawnMax>
	//followed by optional parameters <distMin>, <distMax>, <angleMin>, <angleMax>
//	declareAmbientPackage( "outdoors_pkg" );
//	addAmbientElement( "outdoors_pkg", "elm_dog1", 3, 6, 1800, 2000, 270, 450 );
//	addAmbientElement( "outdoors_pkg", "elm_dog2", 5, 10 );
//	addAmbientElement( "outdoors_pkg", "elm_dog3", 10, 20 );
//	addAmbientElement( "outdoors_pkg", "elm_donkey1", 25, 35 );
//	addAmbientElement( "outdoors_pkg", "elm_horse1", 10, 25 );

//	declareAmbientPackage( "west_pkg" );
//	addAmbientElement( "west_pkg", "elm_insect_fly", 2, 8, 0, 150, 345, 375 );
//	addAmbientElement( "west_pkg", "elm_owl", 3, 10, 400, 500, 269, 270 );
//	addAmbientElement( "west_pkg", "elm_wolf", 10, 15, 100, 500, 90, 270 );
//	addAmbientElement( "west_pkg", "animal_chicken_idle", 3, 12 );
//	addAmbientElement( "west_pkg", "animal_chicken_disturbed", 10, 30 );

//	declareAmbientPackage( "northwest_pkg" );
//	addAmbientElement( "northwest_pkg", "elm_wind_buffet", 3, 6 );
//	addAmbientElement( "northwest_pkg", "elm_rubble", 5, 10 );
//	addAmbientElement( "northwest_pkg", "elm_industry", 10, 20 );
//	addAmbientElement( "northwest_pkg", "elm_stress", 5, 20, 200, 2000 );

	//explicitly activate the base ambientpackage, which is used when not touching any ambientPackageTriggers
	//the other trigger based packages will be activated automatically when the player is touching them
//	activateAmbientPackage( "outdoors_pkg", 0 );


	//the same pattern is followed for setting up ambientRooms
//	declareAmbientRoom( "outdoors_room" );
//	setAmbientRoomTone( "outdoors_room", "amb_shanty_ext_temp" );

//	declareAmbientRoom( "west_room" );
//	setAmbientRoomTone( "west_room", "bomb_tick" );

//	declareAmbientRoom( "northwest_room" );
//	setAmbientRoomTone( "northwest_room", "weap_sniper_heartbeat" );

//	activateAmbientRoom( "outdoors_room", 0 );
	level thread super_temp_music();
	level thread mg42_turret_audio_thread();

}
super_temp_music()
{
	wait(3);
	setmusicstate ("INTRO");	
	
}

mg42_turret_audio_thread()
{
	wait_for_all_players();
	mg421 = getent( "mg_turret_1", "targetname" );
	mg422 = getent( "mg_turret_2", "targetname" );
	mg423 = getent( "mg_turret_3", "targetname" );
	mg424 = getent( "mg_turret_4", "targetname" );
	if( IsDefined( mg421 )&& IsDefined(mg422)&& IsDefined(mg423)&& IsDefined(mg424) )
	{
		mg421 thread mg42_turret_audio( "wpn_pbr_turret_fire_loop_plr" , "wpn_pbr_turret_fire_loop_ring_plr" , "wpn_pbr_turret_fire_loop_npc" , "wpn_pbr_turret_fire_loop_ring_npc" );
		mg422 thread mg42_turret_audio( "wpn_pbr_turret_fire_loop_plr" , "wpn_pbr_turret_fire_loop_ring_plr" , "wpn_pbr_turret_fire_loop_npc" , "wpn_pbr_turret_fire_loop_ring_npc" );
		mg423 thread mg42_turret_audio( "wpn_pbr_turret_fire_loop_plr" , "wpn_pbr_turret_fire_loop_ring_plr" , "wpn_pbr_turret_fire_loop_npc" , "wpn_pbr_turret_fire_loop_ring_npc" );
		mg424 thread mg42_turret_audio( "wpn_pbr_turret_fire_loop_plr" , "wpn_pbr_turret_fire_loop_ring_plr" , "wpn_pbr_turret_fire_loop_npc" , "wpn_pbr_turret_fire_loop_ring_npc" );
	}
}

mg42_turret_audio( alias1 , alias2 , alias3 , alias4 )//1= plr loop 2 = plr ringoff 3 = npc loop 4 = npc ringoff
{
	self endon( "death" );
	player = get_players()[0];
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
		/*while( IsTurretActive( self ) && (!Player.usingturret) )
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
		}*/
		wait( 0.05 );	
	}
}
