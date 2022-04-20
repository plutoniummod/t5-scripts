#include maps\_utility;
#include common_scripts\utility;
#include maps\wmd_util;
#include maps\_anim;
#include maps\_music;





basejump_main()
{
	// -- WWILLIAMS: BOOL FOR THE PLAYER REACHING THE FINAL POI
	level.last_poi = false;
	
	level clientNotify( "kill_jump_goggles" );
	OnSaveRestored_Callback( ::base_jump_save_restore );
	level thread players_jump_from_cliff();
	level thread audio_stylized_start();
}


base_jump_save_restore()
{
	level clientNotify( "kill_jump_goggles" );
}


players_jump_from_cliff()
{
	flag_wait("player_signaled_reznov");
	players = get_players();
	for(i=0;i<players.size;i++)
	{
		players[i] disableweapons();
		//players[i] thread basejump_force_player_landing_spot();
		players[i] thread Wait_For_Player_To_Jump();
	}
}


wait_for_player_to_jump()
{
	self endon("death");
	self endon("disconnect");
		
	trigger_wait("start_fall");
	
	self thread parachute_into_base();
	
	//TUEY Falling !!!
	//setmusicstate ("FALLING");
	
	clientnotify ("falling");  // sound snapshot on client
	
	level notify ("player_has_jumped"); // stopping a looping sound
	
	//self thread show_message( 4, &"PLATFORM_FREEFALL" ,0);
	//self thread lerp_fov_over_time(3,100);
	wait(1);
	self AllowStand( true );
	self AllowCrouch( false );
	self AllowProne( false );
	
	// -- WWILLIAMS: SPAWN OUT THE VEHICLES FOR THE FIELD
	level thread maps\wmd_base::field_init();
	
	flag_set ("players_jumped");
	
	level thread fog_freefall_settings();
		
	//flag_set("players_landed");
	
	//temp for press demo - jc 
	//level waittill( "chute_hint_given" );
	// -- TODO: CLEAN THIS UP
	wait(4.2);
	
	//changelevel("frontend");
}


fog_freefall_settings()
{
	//while freefalling
	start_dist = 159.888;
	half_dist = 3393.03;
	half_height = 8442.7;
	base_height = 10418.4;
	fog_r = 0.313726;
	fog_g = 0.341176;
	fog_b = 0.34902;
	fog_scale = 10;
	sun_col_r = 0.52549;
	sun_col_g = 0.490196;
	sun_col_b = 0.490196;
	sun_dir_x = -0.175571;
	sun_dir_y = 0.67452;
	sun_dir_z = 0.717076;
	sun_start_ang = 9.3213;
	sun_stop_ang = 53.7526;
	time = 3;
	max_fog_opacity = 1;
	
	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
	sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
	sun_stop_ang, time, max_fog_opacity);
	
	flag_wait("cord_pull");

	//during chute fall
	start_dist = 159.888;
	half_dist = 2172.58;
	half_height = 1781.78;
	base_height = 10418.4;
	fog_r = 0.313726;
	fog_g = 0.341176;
	fog_b = 0.34902;
	fog_scale = 10;
	sun_col_r = 1;
	sun_col_g = 0.784314;
	sun_col_b = 0.576471;
	sun_dir_x = -0.175571;
	sun_dir_y = 0.67452;
	sun_dir_z = 0.717076;
	sun_start_ang = 9.3213;
	sun_stop_ang = 53.7526;
	time = 3;
	max_fog_opacity = 1;
	
	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
	sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
	sun_stop_ang, time, max_fog_opacity);
	
	flag_wait("players_landed");

	//landed
	start_dist = 612.888;
	half_dist = 5538.83;
	half_height = 2454.62;
	base_height = 10418.4;
	fog_r = 0.313726;
	fog_g = 0.341176;
	fog_b = 0.34902;
	fog_scale = 10;
	sun_col_r = 1;
	sun_col_g = 0.784314;
	sun_col_b = 0.576471;
	sun_dir_x = -0.175571;
	sun_dir_y = 0.67452;
	sun_dir_z = 0.717076;
	sun_start_ang = 9.3213;
	sun_stop_ang = 53.7526;
	time = 5;
	max_fog_opacity = 0.732627;
	
	setVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
	sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, 
	sun_stop_ang, time, max_fog_opacity); 
}


/*------------------------------------
This handles blending the viewmodel hand anims as the player moves the left stick during the descent
// self == player
------------------------------------*/
#using_animtree("wmd");
watch_player_controls() 
{
	self endon("death");
	self endon("disconnect");	
	self endon("landed");
	
	self.my_hands anim_first_frame( self.my_hands, "first_frame_fall" );
	
	self.my_hands anim_single(self.my_hands, "fall_intro");
	
	while(!flag("cord_pull"))
	{
		
		wait(.05);
		
		if(!self._chute_pulled)
		{
			loop = level.scr_anim["player_fall_loop"];
			left = level.scr_anim["player_fall_left"];
			right = level.scr_anim["player_fall_right"];
		}
		else
		{
			loop =	level.scr_anim["player_chuteopen_loop"];
			left = 	level.scr_anim["player_chuteopen_left"];
			right =	level.scr_anim["player_chuteopen_right"];
		}
		
		// dont' want any of these anims blending if deploying chute
		if(self._deploying_chute)
		{						
			self.my_hands clearanim(level.scr_anim["player_fall_loop"],0);
			self.my_hands clearanim(level.scr_anim["player_fall_left"],0);
			self.my_hands clearanim(level.scr_anim["player_fall_right"],0);
			self.my_hands clearanim(level.scr_anim["player_chuteopen_loop"],0);
			self.my_hands clearanim(level.scr_anim["player_chuteopen_left"],0);
			self.my_hands clearanim(level.scr_anim["player_chuteopen_right"],0);
			
			while(self._deploying_chute)
			{
				wait(0.05); //-- don't try and set any anims while this is happening
			}
			
			continue;
		}		
				
		norm_move = self getnormalizedmovement();		
		
		// left
		weight = 0;
		if(norm_move[1] < 0)
		{
			weight = norm_move[1] * -1;
		}
		self.my_hands SetAnim(left, weight);
		
		//right
		weight = norm_move[1];
		if(norm_move[1] < 0)
		{
			weight = 0;
		}
		self.my_hands SetAnim(right, weight);	

		
		if(norm_move[0] < 0)
		{
			weight = norm_move[0] * -1;
		}
		else if(norm_move[0] >0)
		{
			weight = norm_move[0];

		}
		else if(norm_move[0] == 0 && norm_move[1] == 0)
		{
			weight = 1;
		}
		
		//self.my_hands Show();
		self.my_hands SetAnim(loop, weight);		
	}
}


/*------------------------------------
checks to see if the player collides with a surface when descending in freefall or after the chute is pulled
------------------------------------*/
is_on_surface(player)
{
	trace = bullettrace( self.origin,self.origin + (0,0,-500) ,0,undefined);
	org = trace["position"];
	dist = distancesquared(self.origin, org);
	
	distcheck = 125 * 125;
	
	if(player._chute_pulled)
	{
		distcheck = 65 * 65;
	}
	
	if(dist < distcheck)
	{
		return true;
	}
	
	return false;

}


do_basejump_fov()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	clientNotify( "start_basejump_fov" );
	
		//wait( 0.5 );
	/*
	player = GetPlayers()[0];
	
	max_fall_speed = 110;
	base_fov = 65;
	final_fov = 95;
	while( 1 )
	{
		if( IsDefined( self.my_fall_speed ) )
		{
			speed_percent = self.my_fall_speed / max_fall_speed;
			fov = base_fov + (final_fov - base_fov)*speed_percent;
			player SetClientDvar( "cg_fov", fov );
		}
		wait( 0.05 );
	}
	*/
}

veclength(v)
{
	return distance((0,0,0), v);
}

wait_for_poi_arrival()
{
	approaching = true;

	prev_dist = DistanceSquared( self.origin, self.curr_poi.origin );
	wait( 0.05 );
	
	while( approaching ) 
	{
		dist = DistanceSquared( self.origin, self.curr_poi.origin );
		//draw_line_for_time( self.origin, self.curr_poi.origin, 1, 0, 0, 0.05 );
		if( dist > prev_dist )
		{
			approaching = false;
			self notify( "poi_arrival" );
		}
		prev_dist = dist;
		wait( 0.05 );
	}
}

handle_player_poi()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon("player_pulled_chute");
	
	curr_poi = 1;
	while( 1 )
	{
		curr_poi_struct = getstruct( "player_poi_"+curr_poi, "targetname" );
				
		if( !IsDefined( curr_poi_struct ) )
		{
			break;
		}
		
		// -- WWILLIAMS: IF THIS IS THE LAST POI OF THE SPLINE IT IS TIME TO GET READY TO MOVE THE PLAYER
		// -- TO THE RIGHT LANDING SPOT
		if( !IsDefined( curr_poi_struct.target ) )
		{
			/#
			//IPrintLnBold( "last poi reached!" );
			#/
			level.last_poi = true;
		}
		
		reached_poi = false;
		self.prev_origin = self.origin;
		self.curr_poi = undefined;
		while( !reached_poi )
		{
			double_speed_sq = 9 * (DistanceSquared( self.prev_origin, self.origin ) / 0.05);
			dist_z = abs( self.origin[2] - curr_poi_struct.origin[2] );
			if( (dist_z * dist_z) <= double_speed_sq )
			{
				self.curr_poi = curr_poi_struct;
				self thread wait_for_poi_arrival();
				self waittill( "poi_arrival" );
				reached_poi = true;
			}
			self.prev_origin = self.origin;
			wait( 0.05 ); 
		}
		curr_poi++;
		wait( 0.05 );
	}
}

/*------------------------------------
This handles moving the player downwards in both the freefall and after the player has pulled the chute
self = the player
self.my_hands = viewmodel that the player is linked to

------------------------------------*/
#using_animtree( "wmd" );
move_player_down()
{
	level endon("player_pulled_chute");
	self thread handle_player_poi();
	
	x = 0;
	y = 0;
	z = 10;
	secs = 0;
	
	hint_given = false;
	chute_pulled = false;
	ai_chute = false;
	too_late = false;
	
	speed_up = 0;
	speed_down = 0;
	speed_left = -20;
	speed_right = 20;
	inc = 1;
	poi_inc = 1;
	
	self thread do_basejump_fov();
	
	if(GetDvar( #"endless_fall") == "1")
	{
		self.og_origin = self.origin;
	}
	
	while(1)
	{	
		norm_move = self getnormalizedmovement();	
		
		if( IsDefined( self.curr_poi ) )
		{
			if( self.curr_poi.origin[0] < self.origin[0] )
			{
				if( x - poi_inc > speed_left )
				{
					x = x - poi_inc;
				}
				else
				{
					x = speed_left;
				}
			}
			else if( self.curr_poi.origin[0] > self.origin[0] )
			{
				if( x + poi_inc < speed_right )
				{
					x = x + poi_inc;
				}
				else
				{
					x = speed_right;
				}
			}
			
			if( self.curr_poi.origin[1] < self.origin[1] )
			{
				if( y - poi_inc > speed_down )
				{
					y = y - poi_inc;
				}
				else
				{
					y = speed_down;
				}
			}
			else if( self.curr_poi.origin[1] > self.origin[1] )
			{
				if( y + poi_inc < speed_up )
				{
					y = y + poi_inc;
				}
				else
				{
					y = speed_up;
				}
			}
		}
		else
		{
			//reset the "drift" when the chute is pulled 
			if(self._chute_pulled && !chute_pulled)
			{
				chute_pulled = true;
				x =0;
				y = 0;			
			}
			
			//pressing up - ignore up/down movement
			if(norm_move[0] > 0)
			{
					//y = y + inc;
			}
			else if(norm_move[0] < 0)
			{
					//y = y -.5;
			}
			
			if( y > speed_up )
			{
				y = speed_up;
			}
			else if( y < speed_down )
			{
				y = speed_down;
			}
			
			if(norm_move[1] < 0)
			{
				if( x - inc > speed_left)
				{
					x = x - inc;
				}
				else
				{
					x = speed_left;
				}
			}
			
			if(norm_move[1] > 0)
			{
				if(x + inc < speed_right)
				{
					x = x + inc;
				}
				else
				{
					x = speed_right;
				}
			}
			
			level.player_speed = veclength( (x, y, z) );
			
			PrintLn( "speed: "+level.player_speed );
			
	//		if( (!self._chute_pulled )&& (y + .5 <= speed_up) )
	//		{
	//			y = y + .5;			
	//		}
		}
		
		if(secs > 0 )
		{
			z = z + (secs * secs * 1.2);
			if(z > 125)
			{
				z = 125;
			}
			
			//-- used to tether the AI to the player in ai_move_down_tether();
			self.my_fall_speed = z;
			self.my_forward_speed = y;
		}
		
		// ai pulls chute
		if(self.origin[2] < 20000 && !ai_chute)
		{
			flag_set("ai_pull_chute");
			
			ai_chute = true;
		}
		
		//this shows the hint for the player to pull the chute once he's passed a certain threshold
		//was 18000, changed to 30000 to happen earlier for demo -jc
		// -- WWILLIAMS: changing this to 14000 cause 18000 still feels too high
		if( self.origin[2] < 19000 && !hint_given && !flag( "basejump_toolate" ) )
		{
			hint_given = true;
			self thread wait_for_player_to_pull_chute();
			level notify( "chute_hint_given" );	//temp for demo to know when to fade
			
			self thread pull_chute_instruction();
		}
		
		// -- WWILLIAMS: FAILSAFE FLOOR WHICH SHUTS OFF TEH CHANCE TO PULL THE CHUTE
		// -- GET UNDER THIS NUMBER AND THE PLAYER WILL FAIL INSTEAD OF PULLING THE CHUTE
		if( self.origin[ 2 ] < 10500 && !too_late)
		{
			too_late = true;
			
			flag_set("basejump_toolate");
		}
					
		//move the player down at different rates depending on if he's pulled the chute or not
		if( !self._chute_pulled )
		{	
			self.my_hands moveto(self.my_hands.origin + (x,y,( z * -1)),.05);
		}
		else
		{
			//if( !level.last_poi )
			//{
				speed_up = 10;
				speed_down = -10;
				speed_left = -10;
				speed_right = 10;
				inc = 1;
				// poi_inc = 3;
				self.my_hands moveto(self.my_hands.origin + (x,y,-20),.05);
			//}
			//else
			//{
			//	self thread basejump_force_player_landing_spot();
			//	return;
			//}

		}
		
		wait(.05);
		secs = secs + .05;
		
		if( secs > 6 )
		{
			speed_up = min( 90, speed_up + 6 );
			speed_down = min( 80, speed_down + 6);
		}
		else if( secs > 5 )
		{
			speed_up = min( 80, speed_up + 6 );
			speed_down = min( 70, speed_down + 6);
		}
		else if( secs > 4 )
		{
			speed_up = min( 70, speed_up + 5 );
			speed_down = min( 65, speed_down + 5);
		}
		else if( secs > 3 )
		{
			speed_up = min( 65, speed_up + 4 );
			speed_down = min( 45, speed_down + 4);
		}
		else if( secs > 2 )
		{
			speed_up = min( 55, speed_up + 3 );
			speed_down = min( 40, speed_down + 3);
		}
		else if( secs > 1 )
		{
			speed_up = min( 40, speed_up + 2 );
			speed_down = min( 20, speed_down + 2 );
		}	 
		
		if( secs > 1 && self.my_hands is_on_surface(self) )
		{
			break;
		}	
	}
	
	if(!self._chute_pulled)
	{
		
		if(GetDvar( #"endless_fall") == "1")
		{
			self.my_hands moveto(self.og_origin,.05);
			self.my_hands waittill("movedone");
			x = 0;
			y = 0;
			z = 10;
			secs = 0;
	
			hint_given = false;
			chute_pulled = false;
	
			speed_up = -80;
			speed_down = -80;
			speed_left = -80;
			speed_right = 80;
			inc = 1;
			self thread move_player_down();
		}
		else
		{
		
			self.my_hands moveto(self.my_hands.origin + (0,0,100),.01);
			self.my_hands waittill("movedone");
			level clientnotify( "lnd" );
			self PlaySound( "vox_plr_land" );
			self thread lerp_fov_over_time(.1,65);
			radiusdamage(self.origin,100,2000,1500);
			self notify("landed");
			self.my_hands delete();
		}
	}
	else
	{
		//TODO: Glocke - put in the landing animation here
		
		level clientnotify( "lnd" );
		self notify("landed");
		self PlaySound( "vox_plr_land" );
		self PlayerLinkToAbsolute( self.my_hands );
		self.my_hands clearanim(level.scr_anim[ "player_hands" ][ "chute_loop" ][0],0);
		self.my_hands clearanim(level.scr_anim[ "player_hands" ][ "chute_left" ][0],0);
		self.my_hands clearanim(level.scr_anim[ "player_hands" ][ "chute_right" ][0],0);
		
		self dodamage(10,self.origin);
		earthquake(.95,.5,self.origin,128);
		//self setblur( 8, 1 );
		wait(.25);
		earthquake(.25,1,self.origin,128);
		
		self.my_hands anim_single( self.my_hands, "fall_land" );
		self unlink();
		
		level notify( "ground_parachutes_start" ); // -- WWILLIAMS: MAKES SURE THE PARACHUTE ANIMS HAPPEN
				
		if(isDefined(self.chute))
		{
			self.chute notify("landed");
			self.chute delete();
		}
		if( IsDefined( self.my_hands.wmd_fx_org ) ) // -- TODO: THIS ORG WAS MOVED TO THE PLAYER ARMS DURING THE JUMP, DELETE IT PROPERLY AND THEN REMOVE THIS
		{
			self.my_hands.wmd_fx_org delete();	
		}
		self.my_hands delete();
		
		//player SwitchToWeapon("m4_silencer");
		self enableweapons();
		
		flag_set("players_landed");
		
		self AllowStand( true );
		self AllowCrouch( true );
		self AllowProne( true );
		
		// -- WWILLIAMS: TURN OFF THE FROST ON THE GOOGLES
		clientNotify( "toggle_jump_goggles" );
	}
}


pull_chute_instruction()
{
	screen_message_create(&"WMD_PULL_CHUTE");
			
	//while(!get_players()[0] UseButtonPressed())
	//{
	//	wait(0.05);
	//}
	
	level thread delete_chute_message();
}


delete_chute_message()
{
	flag_wait_any("basejump_toolate", "cord_pull");
	
	screen_message_delete();
}


/*
// -- hack to move the player to the right spot once they pull while going toward the final poi
// -- SELF == PLAYER
*/
basejump_force_player_landing_spot()
{
	self endon( "death" );
	
	landing_spot = getstruct( "struct_base_player_jumpto", "targetname" );
	
	//flag_wait("players_jumped");
	
	//flag_wait("player_pulled_chute");
	
	if( self.origin[2] < 10500 )
	{
		// you failed to pull the chute in time!
		self Unlink();
		
		self.my_hands delete();
		
		self Suicide();
		
		return;
	}
	
	AssertEx( IsDefined( self.my_hands ), "player no longer has the arms!" );
	
	dist_difference = Distance( self.my_hands.origin, landing_spot.origin );
	travel_time = dist_difference/275;
	
	// travel_time = Abs( travel_time );
	// IPrintLnBold( travel_time );
	
	script_mover = Spawn( "script_origin", self.my_hands.origin );
	self.my_hands LinkTo( script_mover );
	//script_mover MoveTo( landing_spot.origin, travel_time, 0, 0 );
	
	script_mover MoveTo(landing_spot.origin, 5.0);
	
	// wait( 5.0 );
	
	script_mover waittill( "movedone" );
	script_mover Unlink();
	
	level clientnotify( "lnd" );
	self notify("landed");
	self PlaySound( "vox_plr_land" );
	
	//TUEY Set music state to POST_BASEJUMP
	setmusicstate ("POST_BASEJUMP");
	
	self PlayerLinkToAbsolute( self.my_hands );
	self.my_hands clearanim(level.scr_anim[ "player_hands" ][ "chute_loop" ][0],0);
	self.my_hands clearanim(level.scr_anim[ "player_hands" ][ "chute_left" ][0],0);
	self.my_hands clearanim(level.scr_anim[ "player_hands" ][ "chute_right" ][0],0);
	
	self dodamage(10,self.origin);
	earthquake(.95,.5,self.origin,128);
	//self setblur( 8, 1 );
	wait(.25);
	earthquake(.25,1,self.origin,128);
	
	self.my_hands anim_single( self.my_hands, "fall_land" );
	self unlink();
	
	level notify( "ground_parachutes_start" ); // -- WWILLIAMS: MAKES SURE THE PARACHUTE ANIMS HAPPEN
			
	if(isDefined(self.chute))
	{
		self.chute notify("landed");
		self.chute delete();
	}
	if( IsDefined( self.my_hands.wmd_fx_org ) ) // -- TODO: THIS ORG WAS MOVED TO THE PLAYER ARMS DURING THE JUMP, DELETE IT PROPERLY AND THEN REMOVE THIS
	{
		self.my_hands.wmd_fx_org delete();	
	}
	self.my_hands delete();
	script_mover Delete();
	
	//player SwitchToWeapon("m4_silencer");
	self enableweapons();
	
	flag_set("players_landed");
	
	self AllowStand( true );
	self AllowCrouch( true );
	self AllowProne( true );
	
	// -- WWILLIAMS: TURN OFF THE FROST ON THE GOOGLES
	clientNotify( "toggle_jump_goggles" );
}


/*------------------------------------
handles the player pulling the chute
------------------------------------*/
#using_animtree("wmd");
wait_for_player_to_pull_chute()
{
	self endon("death");
	self endon("disconnect");
	level endon( "basejump_toolate" );

	while(!self usebuttonpressed() && !flag( "basejump_toolate" ) ) // -- WWILLIAMS: ADDED THE FLAG CHECK FOR THE FLOOR FAILSAFE
	{
		wait (.05);
	}
	
	if( flag( "basejump_toolate" ) || self.origin[2] < 2000 )
	{
		return;
	}
	
	flag_set("cord_pull");
	
	self PlaySound( "evt_para_open_fnt" );
	
	VisionSetNaked("wmd_lower_valley");
	
	self._deploying_chute = true;
	
	self thread parachute_shake();
	
	//wait(0.1);
	
	//self.my_hands anim_single( self.my_hands, "pull_cord" );
	
	self.my_hands ClearAnim(%root, 0);
	
	animtime = GetAnimLength(level.scr_anim["player_hands"]["pull_cord"]);
	
	self.my_hands SetAnim(level.scr_anim["player_hands"]["pull_cord"], 1.0, 0);
	
	wait(animtime - 0.2);
	
	self.my_hands SetAnim(level.scr_anim[ "player_hands" ][ "chute_loop" ][0], 1.0, 0.1);
		
	// -- WWILLIAMS: FLAG TO SET WHEN THE PLAYER OPENS CHUTE, SET BEFORE THE ANIMATION FOR THINGS LIKE FOG
	flag_set( "player_opened_chute" );
	
	self.my_hands notify("freefall_stop");
	
	self notify("stop_freefall_anim");
	
	self clientNotify("para");
	
	flag_set("player_pulled_chute");
	
	//level notify("player_pulled_chute");
	
	self thread basejump_force_player_landing_spot();
	
	self._chute_pulled = true;
	self._deploying_chute = false;
	
	wait(1);
	
	self.my_hands.angles = (0, 120, 0);
	
	// -- WWILLIAMS: RESET THE FOV WHEN THE CHUTE IS DEPLOYED
	self clientNotify( "reset_fov" );
}


parachute_shake()
{
	wait(0.5);
	
	self PlayRumbleOnEntity("grenade_rumble");
	
	earthquake(1.0, 6.0, self.origin, 5000);
}


/*------------------------------------
controller rumble and slight earthquake as the player is freefalling
------------------------------------*/
do_rumble()
{
	self endon("death");
	self endon("disconnect");
	self endon("landed");
	level endon( "players_landed" );
	self endon("stop_freefall_anim");
	
	while(isalive(self))
	{
		wait(randomfloat(.15));
		earthquake(randomfloatrange(.06,.09),5,self.origin,500);
		if(randomint(100) > 80)
		{
			self PlayRumbleOnEntity("grenade_rumble");
		}
	}
}

/*------------------------------------
spawns the chute and animates it
------------------------------------*/
chute_spawn_and_initial_animate()
{
	self.chute = spawn("script_model", self.origin );
	//self.chute hide();
	self.chute setmodel("p_jun_basejump_parachute");
	self.chute.angles = (0,0,0);	
	self.chute.origin = self.origin + (0,0,60);
	self.chute linkto(self.my_hands,"tag_origin",(0,0,0),(0,0,0));
	self.chute UseAnimTree(#animtree);
	self.chute.animname = "ai_chute";
	//self.chute show();
	self.chute anim_single(self.chute, "pull_chute"); 
	//chute animscripted("chute_open",self.origin + (0,0,120),chute.angles,%v_base_jump_chute_open);
	//self.chute hide();
	self.chute thread parachute_loop();	
}



/*------------------------------------
plays animation on the chute after it's deployed
------------------------------------*/
parachute_loop()
{
	self endon("landed");
	
	self PlayLoopSound( "fly_chute_loop" );

	self UseAnimTree(#animtree);
	self.animname = "ai_chute";
	//self show();
	self anim_loop( self, "chute_loop", "landed" );
}

/*------------------------------------
//self = a player
------------------------------------*/
parachute_into_base()
{
	//spawns the viewmodel arms
	spawn_jump_viewmodel();	
	
	//sort of an aribrary angle based on the fact that I know which direction the player needs to face while jumping. 	
	self.my_hands.angles = (0, 90, 0);
	
	//watch for the player to steer himself
	self thread watch_player_controls();
	self thread set_player_angles();
	
	delta_time = 1;
	
	self._chute_pulled = false;
	self._deploying_chute = false;
	
	//fake the freefall
	self thread move_player_down();
	
	wait( delta_time );

	//rumble and player view particles as they are falling
	self thread do_rumble();
	self.my_hands thread do_player_view_particles();
	
	flag_wait("player_pulled_chute");
	
	self.my_hands thread stop_player_view_particles();
}


set_player_angles()
{
	self.my_hands hide();
	
	wait(0.25);
	
	time = 1.6;
	
	self startcameratween(time);
	
	self SetPlayerAngles((45, 90, 0));
	
	wait(time);
	
	self.my_hands show();
}


#using_animtree("wmd");
spawn_jump_viewmodel()
{
	self endon("death");
	self endon("disconnect");
	
	self.my_hands = spawn_anim_model( "player_hands");
	self.my_hands.angles = self.angles;
	self.my_hands.origin = self.origin;	
	
	delta_time = 1;
	
	get_players()[0] playerlinktodelta(self.my_hands,"tag_player",delta_time,35,35,15,30);
	
	self.my_hands Hide();
	
	level.weaver_ent = spawn("script_origin", self.my_hands.origin);
	level.weaver_ent.angles = self.my_hands.angles;
	
	level.player_ent = self.my_hands;
	
	level.brooks_ent = spawn("script_origin", self.my_hands.origin);
	level.brooks_ent.angles = self.my_hands.angles;
	
	//NOT WORKING RIGHT - NEED TO INVESTIGATE
	//self thread wait_for_intro_anim();
}

//NOT WORKING RIGHT - NEED TO INVESTIGATE	
wait_for_intro_anim()
{
	self.my_hands waittill("start_intro_anim");
	
	self.my_hands Show();
	
	self.my_hands anim_first_frame( self.my_hands, "fall_intro" );
	self.my_hands anim_single(self.my_hands, "fall_intro");
			
	//handles blending the player viewarm anims
	self thread watch_player_controls();
}

audio_stylized_start()
{
    player = get_players()[0];
    trigger = GetEnt( "basejump_audio_stylized", "targetname" );
    
    if( !IsDefined( trigger ) )
        return;
    
    trigger waittill( "trigger" );
    
    while( player IsTouching( trigger ) )
    {
        if( player JumpButtonPressed() )
        {
            clientnotify( "bsjsty" );
            setmusicstate ("FALLING");
            return;
        }
        wait(.05);
    }
    
    clientnotify( "bsjsty" );
    setmusicstate ("FALLING");
}