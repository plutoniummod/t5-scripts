//
// file: mp_kowloon_amb.gsc
// description: level ambience script for mp_kowloon
// scripter: 
//

#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\_ambientpackage;
#include maps\mp\_artillery;


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
		level thread play_TV();
		level thread play_TV_2();
}

plane_position_updater (miliseconds, soundalias_1, soundalias_2)
{
	//length of sound file to fly overhead in ms
	apex = miliseconds;
	
	soundid = -1;
	dx = undefined;
	last_time = undefined;
	last_pos = undefined;
	start_time = 0;
	if(!IsDefined (soundalias_1))
	{
		self.soundalias_1 = "veh_mig_flyby";		
	}
	else
	{
		self.soundalias_1 = soundalias_1;
	}
	if(!IsDefined (soundalias_2))
	{
		self.soundalias_2 = "veh_mig_flyby_lfe";			
	}
	else
	{
		self.soundalias_2 = soundalias_2;
	}
	
	while(IsDefined(self))
	{
		//setfakeentorg(0, fake_ent, plane.origin);
		
		if((soundid < 0) && isdefined(last_pos))
		{
			dx = self.origin - last_pos;
			
			if(length(dx) > .01)
			{
				velocity = dx / (GetTime()-last_time);
				assert(isdefined(velocity));
				players = get_players();
				assert(isdefined(players));
				other_point = self.origin + (velocity * 100000);
				point = closest_point_on_line(players[0].origin, self.origin, other_point );
				assert(isdefined(point));
				dist = Distance( point, self.origin );	
				assert(isdefined(dist));
				time = dist / length(velocity);
				assert(isdefined(time));
				
				if(time < apex)
				{
					self playsound(self.soundalias_1);	
					if(self.soundalias_2 != "null")
					{			
						self playsound (self.soundalias_2);
					}
					start_time = GetTime();
					break;
				}
				
			//	println("vel:"+velocity+" pnt:"+point+" dst:"+dist+" t:"+time+"\n");
			}
	
		}
		
		last_pos = self.origin;
		last_time = GetTime();
		

		if(start_time != 0)
		{
			/#
			iprintlnbold("time: "+((GetTime()-start_time)/1000)+"\n");		
			#/
		}

					
		wait(0.1);		
		
	}
	//deletefakeent(0, fake_ent);

}
closest_point_on_line( Point, LineStart, LineEnd )
{
	
	LineMagSqrd = lengthsquared(LineEnd - LineStart);
 
    t =	( ( ( Point[0] - LineStart[0] ) * ( LineEnd[0] - LineStart[0] ) ) +
				( ( Point[1] - LineStart[1] ) * ( LineEnd[1] - LineStart[1] ) ) +
				( ( Point[2] - LineStart[2] ) * ( LineEnd[2] - LineStart[2] ) ) ) /
				( LineMagSqrd );
 
  if( t < 0.0  )
	{
		return LineStart;
	}
	else if( t > 1.0 )
	{
		return LineEnd;
	}
	else
	{
		start_x = LineStart[0] + t * ( LineEnd[0] - LineStart[0] );
		start_y = LineStart[1] + t * ( LineEnd[1] - LineStart[1] );
		start_z = LineStart[2] + t * ( LineEnd[2] - LineStart[2] );
		
		return (start_x,start_y,start_z);
	}
}

play_TV()
{
	wait(5);
	TV_sound = spawn ("script_origin", (1969, 376, -72));
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
	TV_sound_b = spawn ("script_origin", (302, -44, 120));
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