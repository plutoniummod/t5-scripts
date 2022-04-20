////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL UTILITY SCRIPTS
//
//
// Utility Scripts for use in Flashpoint
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;
#include maps\flamer_util;

debug_event( eventname, eventstatus )
{
/#
	//println( GetTime() + ":DEBUG EVENT [" + eventname + "-" + eventstatus + "]\n" );
	if( GetDvarInt( #"debug_script" ) >= 1 )
	{
		//iprintlnbold( GetTime() + ":DEBUG EVENT [" + eventname + "-" + eventstatus + "]\n" );
	}
#/
}

debug_script( msg )
{
/#
	//println( GetTime() + ":" + msg + "\n" );
	if( GetDvarInt( #"debug_script" ) >= 1 )
	{
		//iprintlnbold( GetTime() + ":" + msg + "\n" );
	}
#/
}

hud_utility_init()
{
	//Create a fullscreen element that we can use for fades and flashbacks.
	level.hud_utility 					 = NewHudElem();
	level.hud_utility.x 				 = 0;
	level.hud_utility.y 			   = 0;
	level.hud_utility.horzAlign  = "fullscreen";
	level.hud_utility.vertAlign  = "fullscreen";
	level.hud_utility.foreground = false; //Arcade Mode compatible
	level.hud_utility.sort			 = 3;
	//NOTE: billboard uses layers 0, 1, and 2!

	//Set the default shader.
	level.hud_utility setShader( "black", 640, 480 );
	
	//Hide the element until needed.
	level.hud_utility.alpha = 0;
}

hud_utility_show( shader, fadeSeconds, alpha )
{
	//If the hud utility does not yet exist...
	if( !isDefined( level.hud_utility ) )
	{
		//Create one now.
		hud_utility_init();
	}
	
	//If a shader was given, switch to it.
	if( IsDefined( shader ) )
	{
		level.hud_utility SetShader( shader, 640, 480 );
	}
	
	//If no seconds were specified or are not positive...
	if( !isDefined( fadeSeconds ) || fadeSeconds <= 0 )
	{
		level.hud_utility.alpha = alpha;
	}
	else
	{
		//Fade into the color over the specified amount of time.
		level.hud_utility FadeOverTime( fadeSeconds );
		level.hud_utility.alpha = alpha;
		wait( fadeSeconds );
	}
	
	//All done! Notify whoever called this.
	self notify( "fade_complete" );
}

hud_utility_hide( shader, fadeSeconds )
{
	//If the hud utility does not yet exist...
	if( !isDefined( level.hud_utility ) )
	{
		//Create one now.
		hud_utility_init();
	}
	
	//If a shader was given, switch to it.
	if( isDefined( fadeSeconds ) )
	{
		level.hud_utility setShader( shader, 640, 480 );
	}
	
	//If no seconds were specified or are not positive...
	if( !isDefined( fadeSeconds ) || fadeSeconds <= 0 )
	{
		level.hud_utility.alpha = 0;
	}
	else
	{
		//Fade into the color over the specified amount of time.
		level.hud_utility fadeOverTime( fadeSeconds );
		level.hud_utility.alpha = 0;
		wait( fadeSeconds );
	}

	//All done! Notify whoever called this.
	self notify( "fade_complete" );
}

flashback_movie_play( alpha )
{
	hud_utility_show( "cinematic", 0, alpha );


	playsoundatposition ("evt_shocking_1", (0,0,0));
 	play_movie( "int_shocking_1", false );
	
	hud_utility_hide();
}


set_level_objective( obj_num, state )  //state can "active", "done"
{
	/*
	switch( obj_num )
	{
		case 0:
		{
			Objective_Add( level.level_obj, state, &"FLASHPOINT_OBJ_INFILTRATE_BASE");
			break;
		}
		case 1:
		{
			Objective_Add( level.level_obj, state, &"FLASHPOINT_OBJ_STOP_ROCKET");
			break;
		}
		case 2:
		{
			Objective_Add( level.level_obj, state, &"FLASHPOINT_OBJ_ESCAPE_BASE");
			break;
		}
	}
	*/
}

set_event_objective( obj_num, state ) //state can "active", "done"
{
	//level.event_obj = 1;  //Main event objective (MEET SQUAD -> DISABLE COMMS -> RESCUE WEAVER -> STOP ROCKET-> DESTROY ROCKET )
	
	/*
	switch( obj_num )
	{
		case 0:
		{
			Objective_Add( level.event_obj, state, &"FLASHPOINT_OBJ_STEALTH");
			break;
		}
		case 1:
		{
			Objective_Add( level.event_obj, state, &"FLASHPOINT_OBJ_GET_DISGUISE");
			break;
		}
		case 2:
		{
			Objective_Add( level.event_obj, state, &"FLASHPOINT_OBJ_MEET_SQUAD");
			break;
		}
		case 3:
		{
			Objective_Add( level.event_obj, state, &"FLASHPOINT_OBJ_GET_TO_COMMS");
			break;
		}
		case 4:
		{
			Objective_Add( level.event_obj, state, &"FLASHPOINT_OBJ_CLEAR_OUT_COMMS");
			break;
		}
		case 5:
		{
			Objective_Add( level.event_obj, state, &"FLASHPOINT_OBJ_RESCUE_WEAVER");
			break;
		}
		case 6:
		{
			Objective_Add( level.event_obj, state, &"FLASHPOINT_OBJ_C4_BUILDING");
			break;
		}
		case 7:
		{
			Objective_Add( level.event_obj, state, &"FLASHPOINT_OBJ_DESTROY_ROCKET");
			break;
		}
		case 8:
		{
			Objective_Add( level.event_obj, state, &"FLASHPOINT_OBJ_ENTER_TUNNELS");
			break;
		}
	}
	*/
}

set_immediate_objective()
{
	//Starts at level.obj_num = 2;
}





queue_movie()
{
	Start3DCinematic("treyarch", false, false);
	level waittill("cine_notify");
	Pause3DCinematic(true);
}

movie()
{
	sound_ent = spawn("script_origin", (0,0,0));
	FADE_IN = 3;
	FADE_OUT = 3;

	cin_hud = NewHudElem();
	cin_hud SetShader("white", 640, 480);
	cin_hud.x = 0;
	cin_hud.y = 0;
	cin_hud.horzAlign  = "fullscreen";
	cin_hud.vertAlign  = "fullscreen";
	cin_hud.foreground = false; //Arcade Mode compatible
	cin_hud.sort = 0;
	cin_hud.alpha = 0;

	cin_hud FadeOverTime(FADE_IN);
	cin_hud.alpha = 1;

	wait FADE_IN;
	sound_ent playloopsound ("evt_memory_loops");
	level notify("movie_start");

	cin_hud SetShader("cinematic", 640, 480);
	Pause3DCinematic(false);

	//level waittill("cine_notify");
	time_rem = GetCinematicTimeRemaining();
	wait (time_rem - .5); // wait time remaining minus a few frames

	level notify("movie_end");
	sound_ent delete();
	cin_hud SetShader("white", 640, 480);
	cin_hud FadeOverTime(FADE_OUT);
	cin_hud.alpha = 0;
}





///////////////////
//
// Kills specific ai with specified script_aigroup
//
///////////////////////////////
kill_aigroup( name )
{
	ai = get_ai_group_ai( name );

	for( i = 0; i < ai.size; i++ )
	{
		// stop magic bullet shield if it's on
		if ( IsDefined( ai[i].magic_bullet_shield ) && ai[i].magic_bullet_shield )
		{
			ai[i] stop_magic_bullet_shield(); 
		}
		wait( 0.05 );
		
		if( IsAlive( ai[i] ) )
		{
			ai[i] DoDamage( ai[i].health + 1, ( 0, 0, 0 ) );
		}
	}	
}



playVO( msg, who, delay )
{	
	/#
	if( isdefined(delay) )
	{
		wait( delay );
	}
	
	//iprintlnbold( "VO (" + who + "):" + msg + "\n" );
	#/
}

playVO_proper( sound_alias, delay )
{	
	if( isdefined(delay) )
	{
		wait( delay );
	}
	
	if( isdefined(level.adhoc_delay) )
	{
		wait( level.adhoc_delay );
		level.adhoc_delay = undefined;
	}
	
	self anim_single( self, sound_alias );
}

playVO_proper_adhoc( sound_alias, delay )
{	
	if( isdefined(delay) )
	{
		wait( delay );
	}
	
	self anim_single( self, sound_alias );
	
	level.adhoc_delay = 1.0;
	wait( 1.0 );
	level.adhoc_delay = undefined;
}

play_random_russian_chatter()
{
	level endon("kill_russian_chatter");
	current_convo = 0;
	
	// Example
	//level.scr_sound["generic_russian"]["convo1_0"] = "vox_fla1_s99_180A_rus1_f";
	
	while(1)
	{
		russian_array = GetAIArray( "axis" );
			
		if(russian_array.size > 0)
		{
			line_num = 0;
			
			while(true) //-- breaks out when there are no more valid conversations
			{
				convo_id = "convo" + current_convo + "_" + line_num;
				
				if(!IsDefined(level.scr_sound["generic_russian"][convo_id]))
				{
					//conversation is over, so break out
					break;
				}
				
				russian_speaker = getClosest( level.player.origin, GetAIArray( "axis" ) );
				russian_speaker playsound( level.scr_sound["generic_russian"][convo_id] ,"kevin_is_tired");
				russian_speaker waittill("kevin_is_tired");

				wait(RandomFloatRange( 1.5, 3.0));
	
				line_num++;
			}
		
			current_convo++;
		}
		
		//-- Limit Convo Numbers
		if(current_convo > 2)
		{
			current_convo = 0;
		}
		
		wait(20);
	}
	
}

playPlaneFx()
{
	self endon ( "death" );

	playfxontag( level._effect["jet_exhaust"], self, "tag_engine" );
	playfxontag( level._effect["jet_trail"], self, "tag_right_wingtip" );
	playfxontag( level._effect["jet_trail"], self, "tag_left_wingtip" );
}

player_is_wimp_2( my_endon )
{	
	level endon( my_endon );
	self endon( "death" );
	
	self waittill( "damage" );
	self Die();
}

heli_direction_2( player, my_endon )
{
	level endon( my_endon );
	self endon( "death" );
	
	while( 1 )
	{
		vec_to_player = player.origin - self.origin;
		
		launch_yaw	= flat_angle( VectorToAngles( vec_to_player ) );
			
		self cleargoalyaw(); // clear this thing
		self settargetyaw( launch_yaw[1] );
		
		wait( 2.0 );
	}
}

heli_flight_path_2( player, my_endon )
{
	level endon( my_endon );
	self endon( "death" );
	
	heli_tracker_triggers_array = getentarray( "heli_tracker_triggers_base", "targetname" );
	
	self thread heli_direction_2( player, my_endon );
	
	self.goalradius = 512;
	
	while( 1 )
	{
		//Which one is the player in!
	
		for( i=0; i<heli_tracker_triggers_array.size; i++ )
		{
			if( player isTouching ( heli_tracker_triggers_array[i] ) )
			{
				//Found it - move the helicopter to this point
				heli_pos_struct = getstructarray( heli_tracker_triggers_array[i].target );
				
				self SetVehGoalPos( heli_pos_struct[self.myindex].origin );
				self.current_index = i;
				self waittill( "goal" );
				
				//self ClearVehGoalPos();
				
				break;
			}
		}
		wait( 6.0 );
	}
}

attack_player_2( chopper, my_endon )
{
	level endon( my_endon );
	self endon ( "death" );
	chopper endon( "delete" );
	
	//Objective_State ( 0, "done" );
	
	level.woods.ignoreall = false;
	level.player thread player_is_wimp_2( my_endon );
	chopper thread heli_flight_path_2( level.player, my_endon );
	
	while( isdefined( self ) )
	{
		//Go to player	
	//	target = ( self.origin[0], self.origin[1], chopper.origin[2] );
	//	chopper.goalradius = 512;
	//	chopper SetVehGoalPos( target );
	
		chopper waittill( "goal" );
		
		trace_fraction = self SightConeTrace(level.player.origin, level.player);

		if( trace_fraction > 0)
		{
			//chopper waittill_notify_or_timeout( "goal", 2.0 );
			
			chopper SetGunnerTargetEnt( level.player, (0,0,0), 1 );		
			for (j=0; j<8; j++)
			{
				chopper FireGunnerWeapon( 1 );
				wait 0.25;
			}
			wait( 1.0 );// cool down
			
			//Fire
			rocket_weapon = "huey_rockets";
			forward = AnglesToForward( chopper.angles );
			start_point = chopper GetTagOrigin( "tag_rocket1" ) + (60 * forward);
 			MagicBullet( rocket_weapon, start_point, self.origin, chopper, self );
  			wait 0.3;
  			start_point = chopper GetTagOrigin( "tag_rocket2" ) + (60 * forward);	
  			MagicBullet( rocket_weapon, start_point, self.origin, chopper, self );
  			wait 0.3; 
  			start_point = chopper GetTagOrigin( "tag_rocket3" ) + (60 * forward);
  			MagicBullet( rocket_weapon, start_point, self.origin, chopper, self );
  			wait 0.3;
  			start_point = chopper GetTagOrigin( "tag_rocket4" ) + (60 * forward);
  			MagicBullet( rocket_weapon, start_point, self.origin, chopper, self );

			wait( 2.0 );// cool down
		}
		else
		{
			wait( 0.1 );
		}
	}
}

level_fail( reason )
{
	//IPrintLnBold ("Mission Failed - " + reason);
	//Objective_State ( 0, "done" );
	wait(2);
	maps\_utility::missionFailedWrapper();
}

get_anim_struct( name )
{	
	anim_struct = getstruct( name, "targetname" );
	
	//If no angle is set then use a default value 
	if( !isdefined(anim_struct.angles) )
	{
		anim_struct.angles = (0.0,0.0,0.0);
	}
	
	return anim_struct;
}


#using_animtree("generic_human");
spawn_and_attach_truck_driver()
{
	//Setup driver
	self vehicle_override_anim( "idle", "tag_driver", %crew_truck_driver_sit_idle);
	self.driver = spawn("script_model",self.origin + (0,40,0));
	self.driver SetModel("c_rus_spetznaz_assault_fb" );
	self.driver UseAnimTree(#animtree);
	self.driver enter_vehicle( self, "tag_driver" );
	self.driver.health = 9999999;
	self.driver.team = "axis"; 
	self.driver.ignoreme = true;
	self.driver makeFakeAI();			// allow it to be animated
	self.driver.drone_delete_on_unload = true; 
	self.driver setcandamage( true );	
}

#using_animtree("generic_human");
spawn_and_attach_uaz_driver()
{
	//Setup driver
	self.driver = spawn("script_model",self.origin + (0,40,0)); 
	self.driver SetModel("c_rus_spetznaz_assault_fb" );
	self.driver UseAnimTree(#animtree);
	self.driver enter_vehicle( self, "tag_driver" );
	self.driver.health = 9999999;
	self.driver.team = "axis"; 
	self.driver.ignoreme = true;
	self.driver makeFakeAI();			// allow it to be animated
	self.driver.drone_delete_on_unload = true; 
	self.driver setcandamage( true );	
}



play_player_hands_anim_simple( anim_node, animation, lerp_camera_time, use_delta )
{
	//level.player DisableWeapons();

	hands = spawn_anim_model( "player_hands" );
	hands.animname = "player_hands";
	
	level.player.anim_hands = hands;

	if( isdefined( lerp_camera_time ) )
	{
		hands hide();
		anim_node thread anim_single_aligned( hands, animation ); 
		wait( 0.05 );
		if( isdefined( use_delta ) && use_delta == true )
		{
			level.player PlayerLinkToDelta( hands, "tag_player", 1, 30, 30, 20, 10, true );
		}
		else
		{
			level.player PlayerLinkToAbsolute( hands, "tag_player" );
		}
		hands show();
		level.player StartCameraTween( lerp_camera_time );
	}
	else
	{
		anim_node thread anim_single_aligned( hands, animation ); 
		if( isdefined( use_delta ) && use_delta == true )
		{
			level.player PlayerLinkToDelta( hands, "tag_player", 1, 30, 30, 20, 10, true );
		}
		else
		{
			level.player PlayerLinkToAbsolute( hands, "tag_player" );
		}
	}

	anim_node waittill( animation );

	level.player Unlink();
	hands Delete();
	
	level.player notify( "anim_complete" );
}


GetYaw(org)
{
	angles = VectorToAngles(org-self.origin);
	return angles[1];
}

GetYawToOrigin(org)
{
	yaw = self.angles[1] - GetYaw(org);
	yaw = AngleClamp180( yaw );
	return yaw;
}

waitThenGiveControlToPlayerWithDelta( waitTime )
{
	self FreezeControls( true );
	
	//Limit players headlook range and lock player in place
	level.linker = spawn( "script_origin", level.player.origin );
	level.linker.angles = level.player.angles;
	level.player PlayerLinkToDelta( level.linker, "", 1, 30, 60, 15, 15, true );
	
	wait( waitTime );
	
	level.player Unlink();
	level.linker Delete();
	
	//self FreezeControls( false );
	self SetLowReady(false);
	self AllowJump( true );
	self enableweapons();
}

waitThenGiveControlToPlayer( waitTime )
{
	self FreezeControls( true );
	wait( waitTime );
	
	self FreezeControls( false );
	self enableweapons();
}

gameover_screen()
{
	level.blackscreen = NewHudElem(); 
	level.blackscreen.x = 0; 
	level.blackscreen.y = 0; 
	level.blackscreen.horzAlign = "fullscreen"; 
	level.blackscreen.vertAlign = "fullscreen"; 
	level.blackscreen.foreground = true;
	level.blackscreen SetShader( "black", 640, 480 );
}


fade_in_black( fFadeInTime, fTime, bFreeze, bFadeWait )
{
	// set parameters to default if not defined
	if( !IsDefined( fFadeInTime ) )
	{
		fFadeInTime = 1.5;
	}
	if( !IsDefined( fTime ) )
	{
		fTime = 1.5;
	}
	if( !IsDefined( bFreeze ) )
	{
		bFreeze = false;
	}
	if( !IsDefined( bFadeWait ) )
	{
		bFadeWait = false;
	}

	// create black screen  
	hudBlack = newHudElem();
	hudBlack.x = 0;
	hudBlack.y = 0;
	hudBlack.horzAlign = "fullscreen";
	hudBlack.vertAlign = "fullscreen";
	//hudBlack.foreground = true;
	hudBlack.sort = 0;
	hudBlack.alpha = 0;
	hudBlack setShader("black", 640, 480);

	if( bFadeWait )
	{
		wait( 0.05 );
	}

	// fade out black
	hudBlack fadeOverTime(fFadeInTime); 
	hudBlack.alpha = 1;

	// unfreeze player control & destroy hud elem
	wait( fFadeInTime );
	
	wait( fTime );
	
	// fade in black
	hudBlack fadeOverTime(fTime); 
	hudBlack.alpha = 0;
	
	wait( fTime );
	
	hudBlack Destroy();
}


///////////////////////////////////////////////////////////////////////////////////////
// Fade In/Out functions from Alex
///////////////////////////////////////////////////////////////////////////////////////
custom_fade_screen_out( shader, time )
{
	// define default values
	if( !isdefined( shader ) )
	{
		shader = "black";
	}

	if( !isdefined( time ) )
	{
		time = 2.0;
	}

	if( isdefined( level.fade_screen ) )
	{
		level.fade_screen Destroy();
	}

	level.fade_screen = NewHudElem(); 
	level.fade_screen.x = 0; 
	level.fade_screen.y = 0; 
	level.fade_screen.horzAlign = "fullscreen"; 
	level.fade_screen.vertAlign = "fullscreen"; 
	level.fade_screen.foreground = true;
	level.fade_screen SetShader( shader, 640, 480 );

	if( time == 0 )
	{
		level.fade_screen.alpha = 1; 
	}
	else
	{
		level.fade_screen.alpha = 0; 
		level.fade_screen FadeOverTime( time ); 
		level.fade_screen.alpha = 1; 
		wait( time );
	}
	level notify( "screen_fade_out_complete" );
}

custom_fade_screen_in( time )
{
	level notify( "screen_fade_in_begins" );

	if( !isdefined( time ) )
	{
		time = 2.0;
	}

	if( !isdefined( level.fade_screen ) )
	{
		// error: the screen was not faded in in the first place
		//        for now, simply do nothing.
		return;
	}

	if( time == 0 )
	{
		level.fade_screen.alpha = 0; 
	}
	else
	{
		level.fade_screen.alpha = 1; 
		level.fade_screen FadeOverTime( time ); 
		level.fade_screen.alpha = 0; 
	}
	
	wait( time );
	level notify( "screen_fade_in_complete" );
}

///////////////////////////////////////////////////////////////////////////////////////
//	Lerp fov for binocular sequence
///////////////////////////////////////////////////////////////////////////////////////
lerp_fov_over_time( time, destfov )
{
	basefov = GetDvarFloat( #"cg_fov" );
	incs = int( time/.05 );
	incfov = (  destfov  -  basefov  ) / incs ;
	currentfov = basefov;
	for ( i = 0; i < incs; i++ )
	{
		currentfov += incfov;
		self setClientDvar( "cg_fov", currentfov );
		wait .05;
	}
	//fix up the little bit of rounding error. not that it matters much .002, heh
	self setClientDvar( "cg_fov", destfov );
}

///////////////////////////////////////////////////////////////////////////////////////
//	Lerp angle for binocular sequence
///////////////////////////////////////////////////////////////////////////////////////
lerp_angle_over_time( time, angle )
{
	baseang = self.angles;
	incs = int( time/.05 );
	incang = (  angle  -  baseang  ) / incs ;
	currentang = baseang;
	for ( i = 0; i < incs; i++ )
	{
		currentang += incang;
		self.angles = currentang;
		wait .05;
	}
}

///////////////////////////////////////////////////////////////////////////////////////
//	Lerp exposure for binocular sequence
///////////////////////////////////////////////////////////////////////////////////////
lerp_exposure_over_time( time, exposure, intensity, cutoff, white )
{
	base_exposure = 0.786;
	base_intensity = 1.489;
	base_cutoff = 0.468;
	base_white = 14.528;
	
	incs = int( time/.05 );
	
	incexp = ( base_exposure - exposure ) / incs;
	incint = ( base_intensity - intensity ) / incs;
	inccutoff = ( base_cutoff - cutoff ) / incs;
	incwhite = ( base_white - white ) / incs;
	
	current_exposure = exposure;
	current_intensity = intensity;
	current_cutoff = cutoff;
	current_white = white;
	
	setdvar( "r_exposureTweak", "1" );
	
	for ( i = 0; i < incs; i++ )
	{
		exposure_val = "0 0 0 " + current_exposure;
		intensity_val = "" + current_intensity + " " + current_intensity + " " + current_intensity + " 0";
		cutoff_val = "" + current_cutoff + " " + current_cutoff + " " + current_cutoff + " 0";
		white_val = "" + current_white + " " + current_white + " " + current_white + " 0";
		
		setdvar( "r_exposureVar0", exposure_val );
		setdvar( "r_exposureVarA", intensity_val );
		setdvar( "r_exposureVarB", cutoff_val );
		setdvar( "r_exposureVar1", white_val );
		
		current_exposure += incexp;
		current_intensity += incint;
		current_cutoff += inccutoff;
		current_white += incwhite;
		
		wait .05;
	}
	
	setdvar( "r_exposureTweak", "0" );
}

///////////////////////////////////////////////////////////////////////////////////////
//	Lerp dof for binocular sequence
///////////////////////////////////////////////////////////////////////////////////////
lerp_dof_over_time( time, NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur )
{
	Default_Near_Start = 0;
	Default_Near_End = 1;
	Default_Far_Start = 8000;
	Default_Far_End = 10000;
	Default_Near_Blur = 6;
	Default_Far_Blur = 0;
	
	Near_Start = 822;
	Near_End = 823;
	Far_Start = 886;
	Far_End = 887;
	Near_Blur = 4;
	Far_Blur = 3.9;
	
	incs = int( time/.05 );
	
	incNearStart = ( Default_Near_Start - Near_Start ) / incs;
	incNearEnd = ( Default_Near_End - Near_End ) / incs;
	incFarStart = ( Default_Far_Start - Far_Start ) / incs;
	incFarEnd = ( Default_Far_End - Far_End ) / incs;
	incNearBlur = ( Default_Near_Blur - Near_Blur ) / incs;
	incFarBlur = ( Default_Far_Blur - Far_Blur ) / incs;
	
	current_NearStart = Near_Start;
	current_NearEnd = Near_End;
	current_FarStart = Far_Start;
	current_FarEnd = Far_End;
	current_NearBlur = Near_Blur;
	current_FarBlur = Far_Blur;
	
	for ( i = 0; i < incs; i++ )
	{
		self SetDepthOfField( current_NearStart, current_NearEnd, current_FarStart, current_FarEnd, current_NearBlur, current_FarBlur );	
		
		current_NearStart += incNearStart;
		current_NearEnd += incNearEnd;
		current_FarStart += incFarStart;
		current_FarEnd += incFarEnd;
		current_NearBlur += incNearBlur;
		current_FarBlur += incFarBlur;
		
		wait .05;
	}
}

///////////////////////////////////////////////////////////////////////////////////////
//	Black screen to emulate shutter switch
///////////////////////////////////////////////////////////////////////////////////////
shutter_switch(time)
{
	if(!IsDefined(time))
	{
		time = 0.15;
	}
	
	custom_fade_screen_out( "black", time );
	
	wait( 0.15 );
	
	custom_fade_screen_in( 0.15 );
}

///////////////////////////////////////////////////////////////////////////////////////
//	Sets exposure for the binocular sequence - self = player
///////////////////////////////////////////////////////////////////////////////////////
binocular_exposure()
{
	//kevin adding binoc audio
	self playsound( "evt_flashpoint_binoc_zoom" );
	
	//setdvar( "r_exposureVar0", "0 0 0 1.665" );
	//setdvar( "r_exposureVar0", "0 0 0 2.5" );
	//setdvar( "r_exposureVar1", "11.681 11.681 11.681 0" );
	//setdvar( "r_exposureVarA", "3.404 3.404 3.404 0" );
	//setdvar( "r_exposureVarB", "0.34  0.34 0.34 0" );
	
	time = 0.35;
	exposure = 2.5;
	intensity = 3.404;
	cutoff = 0.34;
	white = 11.681;
	
	base_exposure = 0.786;
	base_intensity = 1.489;
	base_cutoff = 0.468;
	base_white = 14.528;
	
	self thread lerp_exposure_over_time( time, exposure, intensity, cutoff, white );
}

launch_vehicle_destruction( _ender )
{
	level endon (_ender);

	while(1)
	{
		self waittill ("damage", amount, inflictor, direction, point, type);
		
		if (IsPlayer(inflictor))
		{
			//PlayFX (level._effect["truck_explosion"], self.origin);
			self thread truck_wipeout();
		}
	}	
}	

truck_wipeout()// this only works on physics vehicles.
{
	
	self ClearVehGoalPos();
	
	chance = randomint( 100 );
	
	if( chance > 66 )
	{  
		force = (332, 116, 104);
		hitpos = (-76, -14, 34);
	}
	else if( chance > 33 )
	{  
		force = (332, 46, 296);
		hitpos = (-50,0,0);
	}
	else
	{
		force = (620, 8, 372);
		hitpos = (76, 2, 18);  
	}
	
	self LaunchVehicle( force, hitpos, true, true );
	
	self ClearVehGoalPos();
	
//	//no slowmo for a coupla specific trucks
//	no_slowmo_vehicles = [];
//	no_slowmo_vehicles[no_slowmo_vehicles.size] = ("merge_guys_dropoff");
//	no_slowmo_vehicles[no_slowmo_vehicles.size] = ("barrel_truck");
//	
//	if( is_in_array( no_slowmo_vehicles, self.targetname ) )
//	{
//	return;
//	}	
//	
//	if(flag("did_truck_slowmo") )
//	{
//	return;
//	}	
//	
//	//slowmo
//	level thread timescale_tween(1, .4, .3);
//	clientnotify( "slow" );
//	wait(1);
//	clientnotify( "fast" );
//	level thread timescale_tween(.4, 1, .3);
//	
//	flag_set ("did_truck_slowmo");
   
}

number_lines(fadeintime, staytime, fadeouttime)
{	
	if (!IsDefined(fadeintime))
	{
		fadeintime = 0;
	}
	
	VisionSetNaked("int_frontend_char_trans", fadeintime);
	wait staytime;
	
	if (IsDefined(fadeouttime))
	{
		VisionSetNaked(level._last_visionset, fadeouttime);
	}
}


white_bloom_in(bloom_in_time, staytime, bloom_out_time)
{
	playsoundatposition ("evt_white_bloom_in", (0,0,0));
	lastvisionset = get_players()[0] getvisionsetnaked();
	if (lastvisionset != "int_frontend_char_trans")
	{
		level._last_visionset = lastvisionset;
	}
	if (!IsDefined(bloom_in_time))
	{
		bloom_in_time = 0;
	}
	
	VisionSetNaked("int_frontend_char_trans", bloom_in_time);
	wait bloom_in_time;
	thread cover_screen_in_white(staytime);
	wait staytime;
	
	if (IsDefined(bloom_out_time))
	{
		VisionSetNaked(level._last_visionset, bloom_out_time);
	}
}

white_bloom_out(staytime, bloom_out_time)
{
	wait staytime;
	playsoundatposition ("evt_white_bloom_out", (0,0,0));
	if (IsDefined(bloom_out_time))
	{
		VisionSetNaked(level._last_visionset, bloom_out_time);
	}
}

	
	

// ~~~ Stolen from somewhere... does a fullscreen fade ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
white_fade_out( time, shadername_arg )
{
	shadername = "black";
	if( isdefined(shadername_arg) )
	{
		shadername = shadername_arg;
	}
	
	if( !isdefined( level.fade_out_overlay ) )
	{
		level.fade_out_overlay = NewHudElem();
		level.fade_out_overlay.x = 0;
		level.fade_out_overlay.y = 0;
		level.fade_out_overlay.horzAlign = "fullscreen";
		level.fade_out_overlay.vertAlign = "fullscreen";
		level.fade_out_overlay.foreground = false;  // arcademode compatible
		level.fade_out_overlay.sort = 50;  // arcademode compatible
	}
	
	level.fade_out_overlay SetShader( shadername, 640, 480 );

	// start off invisible
	level.fade_out_overlay.alpha = 0;
	level.fade_out_overlay fadeOverTime( time );
	level.fade_out_overlay.alpha = 1;
	wait( time );
	level notify( "fade_out_complete" );
}

//******************************************************************************
//******************************************************************************

// ~~~ Stolen from somewhere... does a fullscreen fade ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
white_fade_in( time, shadername_arg, delay_time )
{
	if( isdefined(delay_time) )
	{
		wait( delay_time );
	}
	
	shadername = "black";
	if( isdefined(shadername_arg) )
	{
		shadername = shadername_arg;
	}

	if( !isdefined( level.fade_out_overlay ) )
	{
		level.fade_out_overlay = NewHudElem();
		level.fade_out_overlay.x = 0;
		level.fade_out_overlay.y = 0;
		level.fade_out_overlay.horzAlign = "fullscreen";
		level.fade_out_overlay.vertAlign = "fullscreen";
		level.fade_out_overlay.foreground = false;  // arcademode compatible
		level.fade_out_overlay.sort = 50;  // arcademode compatible
	}
	
	level.fade_out_overlay SetShader( shadername, 640, 480 );

	level.fade_out_overlay.alpha = 1;
	level.fade_out_overlay fadeOverTime( time );
	level.fade_out_overlay.alpha = 0;
	wait( time );
	level notify( "fade_in_complete" );
}

///////////////////
//
// Force goals guy to his node if he is targeting one
//
///////////////////////////////
force_goal_self_util()
{
	self endon( "death" );

	if( IsDefined( self.target ) )
	{
		goal_node = GetNode( self.target, "targetname" );
		self thread force_goal( goal_node, 64 );
	}
}


shrink_goalradius_util()
{
	self endon( "death" );

	self.goalradius = 64;
}

play_bink_for_time(movie, fadeintime, playtime, fadeouttime, opacity)
{
	sound_ent = spawn ("script_origin", (0,0,0));
	playsoundatposition ("evt_shocking_2", (0,0,0));
	if (!IsDefined(opacity))
	{
		opacity = 1;
	}
	if (IsDefined(fadeintime) && fadeintime > 0)
	{
		level.fullscreen_cin_hud FadeOverTime(fadeintime);
	}
	else
		fadeintime = 0;
		
	level.fullscreen_cin_hud.alpha = opacity;
	
	sound_ent playloopsound ("evt_memory_loops");
	start3dcinematic(movie, true, true);
	wait fadeintime;
	wait playtime;
	
	if (IsDefined(fadeouttime) && fadeouttime>0)
	{
		level.fullscreen_cin_hud FadeOverTime(fadeouttime);
		level.fullscreen_cin_hud.alpha = 0;
		wait fadeouttime;
	}
	
	level.fullscreen_cin_hud.alpha = 0;
	stop3dcinematic();
	
	sound_ent delete();
}

autosave_after_delay( delay, save_name )
{
	wait(delay);
	autosave_by_name( save_name );
}

////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////
