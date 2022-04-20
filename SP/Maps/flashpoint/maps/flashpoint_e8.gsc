////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL SCRIPTS
//
//
// Script for event 8 - this covers the following scenes from the design:
//		Slides 43-48
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_vehicle;
#include maps\_anim;
#include maps\flashpoint_util;
#include maps\_music;


////////////////////////////////////////////////////////////////////////////////////////////
// EVENT8 FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////



explosive_trigger_hint_press()
{
	level endon( "explosive_set" );
	use_trigger = getent( "b2_satchel_set", "targetname" );
	level thread explosive_trigger_press( use_trigger );

	while( 1 )
	{
		while( 1 )
		{
			if( level.player istouching( use_trigger ) )
			{
				break;
			}
			wait( 0.05 );
		}	
		level.player SetScriptHintString( &"FLASHPOINT_HINT_PLANT_CHARGE"  );
		//screen_message_create( &"FLASHPOINT_HINT_PLANT_CHARGE" );
		while( 1 )
		{
			if( level.player istouching( use_trigger ) == false )
			{
				break;
			}
			wait( 0.05 );
		}	
		level.player SetScriptHintString("");
		//screen_message_delete();
	}
}

plant_sound()
{
	wait (1.2);
	playsoundatposition ( "evt_bomb_plant", (0, 0, 0) );
}

explosive_trigger_press( trigger )
{
	wait( 0.5 );
	while( 1 )
	{
		while( level.player UseButtonPressed() == false )
		{
			wait( 0.05 );
		}
		if( level.player istouching( trigger ) && (level.player use_button_held()) )
		{
			level notify( "explosive_set" );
			
			c4_area_blocker = getent( "c4_area_blocker", "targetname" );
			c4_area_blocker Solid();
	
			level thread plant_sound();
			trigger delete();
			//screen_message_delete();
			level.player SetScriptHintString("");
			return;
		}
		wait( 0.05 );
	}
}

play_player_setting_bomb_anim( explosive_charge )
{
	level.player DisableWeapons();
	level.player Hide();
	wait( 0.05 );
//	anim_node = spawn( "script_origin", ( -27015, 37002.3, -236.5 ) );
//	anim_node.angles = ( 0, 289.1, 0 );
	
	anim_node_plant_bomb = get_anim_struct( "c4_bomb" );
	anim_node = spawn( "script_origin", anim_node_plant_bomb.origin );
	anim_node.angles = anim_node_plant_bomb.angles;
	
	level thread play_player_hands_anim_simple( anim_node, "bomb_plant", 0.6 );
	
	explosive_charge.origin = level.player.anim_hands GetTagOrigin( "tag_weapon" );
	explosive_charge.angles = level.player.anim_hands GetTagAngles( "tag_weapon" );
	explosive_charge LinkTo( level.player.anim_hands, "tag_weapon" );
	explosive_charge show();
	level.player.explosive_charge_model = explosive_charge;
	
	level.player waittill( "anim_complete" );
	level.player EnableWeapons();
	level.player Show();
}

plant_bomb_detach( guy )
{
	//level.player.explosive_charge_model unlink();
}


bunker_scientist_takes_damage()
{
	self endon("death");
	
	//Not very strong......
	self waittill( "damage" );
	self Die();
}

setup_bunker_scientist()
{
	self endon("death");

	self.deathfunction = animscripts\utility::do_ragdoll_death;

	self.goalradius = 32;
	self.ignoreall = true;
	self.dropweapon = false;
	self.animname = "scientist";
	self.allowdeath = true;
	self.team = "axis";
	
	self thread bunker_scientist_takes_damage();
	self thread anim_loop( self, "cower" );
}


rocket_clamps()
{
	clamp1 = getent( "rocket_clamp_1", "targetname" );
	clamp2 = getent( "rocket_clamp_2", "targetname" );	
	clamp3 = getent( "rocket_clamp_3", "targetname" );	
	clamp4 = getent( "rocket_clamp_4", "targetname" );	
	
	clamp1 BypassSledgehammer();
	clamp2 BypassSledgehammer();
	clamp3 BypassSledgehammer();
	clamp4 BypassSledgehammer();
	
	clamp1 rotateroll( -50, 2.0, 0.1, 0.3 );
	clamp2 rotateroll( -50, 2.0, 0.1, 0.3 );
	clamp3 rotateroll( -50, 2.0, 0.1, 0.3 );
	clamp4 rotateroll( -50, 2.0, 0.1, 0.3 );
}

// check_for_damage() 
// { 
// 	self waittill( "damage" ); 
// 	flag_set( "ROCKET_DESTROYED" ); 
// 	playVO( "You got it!!!! Nice one", "Woods" ); 
// } 
 
 
 
cleanup_rocket_takedown()
{
	self endon( "delete" );
	flag_wait( "ROCKET_DESTROYED" );
	self destroy();
	self notify ( "removed" );
}
 
startFINALCountDownTimer()
{
	elem = NewHudElem();
	elem.hidewheninmenu = true;
	elem.horzAlign = "center";
	elem.vertAlign = "top";
	elem.alignX = "center";
	elem.alignY = "middle";
	elem.x = 0;
	elem.y = 0;
	elem.foreground = true;
	elem.font = "default";
	elem.fontScale = 4.0;
	elem.color = ( 1.0, 1.0, 1.0 );        
	elem.alpha = 1.0;
	elem SetTimer( 20 );
	
	//elem thread flash_when_low();
	elem thread cleanup_rocket_takedown();
}


check_for_tow_being_fired()
{
	level endon( "TOW_FIRED" );
	while( 1 )
	{
		self waittill_any( "weapon_fired", "grenade_fire", "missile_fire" );
		
		//Check to see which weapon we are currently holding
		activeWeapon = level.player GetCurrentWeapon();
	
		if( activeWeapon == "flashpoint_m220_tow_sp" )
		{
			//Ok disable FINAL rocket timer, let a miss of timeout on the rocket fail us
			level.player thread check_for_tow_manual_destruction();
			flag_set( "TOW_FIRED" );
		}
	}
}

check_for_tow_manual_destruction()
{
	level endon("ROCKET_DESTROYED");
	level endon( "rocket_is_destroyed_by_crossbow" );
	level.player waittill("guided_missile_exploded_manually");

  	wait( 1.0 );
  	self FreezeControls( true );
  	maps\_utility::missionFailedWrapper(&"FLASHPOINT_DEAD_MISSED_THE_ROCKET");
}


fade_to_white_on_death( )
{
	self endon("disconnect");
	level endon( "rocket_is_destroyed_by_crossbow" );
	self waittill( "guided_missile_exploded" );
	waittillframeend;
	self.guided_missile_lost_signal.alpha = 1.0;
	wait( 1.0 );

	self FreezeControls( true );
	maps\_utility::missionFailedWrapper(&"FLASHPOINT_DEAD_MISSED_THE_ROCKET");
 	
	//if( isDefined( self.guided_missile_lost_signal ) )
	//	self.guided_missile_lost_signal Destroy();
}


tow_failed_screen()
{
	//Fade to white when exploded or leaving map bounds
	self.guided_missile_lost_signal = newclienthudelem( self );
	self.guided_missile_lost_signal.x = 0;
	self.guided_missile_lost_signal.y = 0; 
	self.guided_missile_lost_signal.horzAlign = "fullscreen";
	self.guided_missile_lost_signal.vertAlign = "fullscreen";
	self.guided_missile_lost_signal.foreground = false;
	self.guided_missile_lost_signal.hidewhendead = false;
	self.guided_missile_lost_signal.hidewheninmenu = true;
	self.guided_missile_lost_signal.sort = 50; 
	self.guided_missile_lost_signal SetShader( "tow_filter_overlay_no_signal", 640, 480 ); 
	self.guided_missile_lost_signal.alpha = 0;
	self thread fade_to_white_on_death();
	
//	self thread destroy_overlay_on_missile_done(guided_missile_overlay ,guided_missile_grain );
}

rocket_aiming_at_target( target )
{
	rocket_pos = self.origin;
	target_pos = target.origin + ( 0.0, 0.0, 1400.0);

	//Check distance first
	my_dist = Distance( rocket_pos, target_pos );
	//println( "Enemy is " + my_dist + " distance from target." );
	if( my_dist < ( 2000 ) )
	{
		//println( "Enemy is " + my_dist + " distance from target." );
		return true;
	}

	//Figure out which way the player is facing
	playerAngles = self.angles;
	playerForwardVec = AnglesToForward( playerAngles );
	playerUnitForwardVec = VectorNormalize( playerForwardVec );
		
	enemyPos = target_pos;//zipline_endpoint_struct.origin;
	playerPos = rocket_pos;
	playerPos = playerPos + (0.0,0.0,60.0);
	playerToEnemyVec = enemyPos - playerPos;
	playerToEnemyUnitVec = VectorNormalize( playerToEnemyVec );
	
	forwardDotBanzai = VectorDot( playerUnitForwardVec, playerToEnemyUnitVec );
	angleFromCenter = ACos( forwardDotBanzai ); 
		
	//println( "Enemy is " + angleFromCenter + " degrees from straight ahead." );
	max_angle = 60.0;
	min_angle = 30.0;
	playerCanSeeMe = ( angleFromCenter <= max_angle );
	
	//Adjust lost signal overlay based on the fraction to the fail value
	if( angleFromCenter < min_angle )
	{
		//Full alpha
		level.player.guided_missile_lost_signal.alpha = 0.0;
	}
	else
	{
		//Alpha blend
		frac = (angleFromCenter - min_angle) / (max_angle - min_angle );
		level.player.guided_missile_lost_signal.alpha = frac;
	}
	
	
	return playerCanSeeMe;
}

check_for_tow_missing_rocket()
{
	level endon("ROCKET_DESTROYED");
	level.player endon("guided_missile_exploded");
	level endon( "rocket_is_destroyed_by_crossbow" );
	
	//miss_rocket_trig = getent( "miss_rocket_trig", "targetname" );
	
	//Track the missile
	self waittill ( "missile_fire", missile, weapon_name );
	
	//Waittill we go into ADS mode
	activeWeapon = level.player GetCurrentWeapon();
	while( isdefined(missile) && (activeWeapon == "flashpoint_m220_tow_sp" ) )
	{
		//Get the missile position - make sure we are always heading towards the rocket
		fxanim_flash_rocket_mod = getent( "fxanim_flash_rocket_mod", "targetname" );
		
		if( missile rocket_aiming_at_target( fxanim_flash_rocket_mod ) )
		{
			//Good keep going
		}
		else
		{
			//Else abort missile.......
			missile ResetMissileDetonationTime( 0 );
            self notify( "guided_missile_exploded" );
            //wait( 1.0 );
            //SetDvar( "ui_deadquote", &"FLASHPOINT_DEAD_MISSED_THE_ROCKET" ); 
 			//MissionFailed();
		}
		wait( 0.05 );
	}
    self notify( "guided_missile_exploded_manually" );
}

check_rocket( ent ) 
{ 
	//18 sec to destory the rocket 
	//startFINALCountDownTimer();
	level.player thread tow_failed_screen();
	level.player thread check_for_tow_being_fired();
	level.player thread check_for_tow_missing_rocket();
	//level.player thread check_for_tow_manual_destruction();
	wait( 20.0 ); 
	
	//If we are here then give the player 10 more sec - just in case
	//A miss of timeout on the rocket will fail us
	if( flag("TOW_FIRED") )
	{
		//playVO( "USING TOW - 10 MORE SEC", "Woods" ); 
		wait( 10.0 );
	}
 
	if( !flag("ROCKET_DESTROYED") ) 
	{ 
		maps\_utility::missionFailedWrapper(&"FLASHPOINT_DEAD_ROCKET_GOT_AWAY");
	} 
}


/*
•	“rocket_exp_1” – this is the first, smaller explosion when the player hits the Soyuz rocket with the Strela rocket.  It attaches to btm_rocket_jnt.  This should play at the same time the rocket parts separate.  It has a built in fire trail.  Kill it when “rocket_exp_2” is triggered.
•	“rocket_top_trail” – a fiery trail that attaches to top_rocket_jnt.  It should continue to play until the rocket top crashes to the ground.
•	“rocket_exp_2” – this is the second, larger explosion.  It also attaches to btm_rocket_jnt.  I’m sure there’s a notetrack for this, but you’ll have to ask Jess Feidt what that is.
•	“rocket_launch_base_dist” – should not be used.  This effect is setup as exploder 110 for the distant rocket launch only.  This reference can be removed.
•	"rocket_explosion" – should not be used.  This reference can be deleted.
•	exploders 300 and 301 – I have no idea what effects these used to trigger, but there aren’t any exploders using these IDs anymore.
•	exploder 808 – trigger this when the rocket bottom impacts the ground.
•	exploder 810 – trigger this when the rocket top impacts the ground.
*/


top_rocket_piece_hits_ground()
{
	self endon( "delete" );
	level endon( "top_rocket_end" );
	
	while( isdefined( self ) )
	{
		top_tag_origin = self GetTagOrigin( "top_rocket_jnt" );

		if( top_tag_origin[2] < 0.0 )
		{
			//hits ground
			//playVO( "Rocket hits the ground! = top_tag_origin", "Woods" );
			
			earthquake( 0.5, 2.0, top_tag_origin, 500 );
			level.player PlayRumbleOnEntity( "explosion_generic" );
			exploder( 810 );
			playsoundatposition ("evt_rocket_top_crash", self.origin);
			wait( 5.0 );
			flag_set( "ROCKET_HITS_GROUND" );			
			wait(1.0);
			level notify( "top_rocket_end" );
		}
		wait( 0.1 );
	}
}


bottom_rocket_piece_hits_ground()
{
	self endon( "delete" );
	level endon( "bottom_rocket_end" );
	
	while( isdefined( self ) )
	{
		bottom_tag_origin = self GetTagOrigin( "btm_rocket_jnt" );
		
		if( bottom_tag_origin[2] < 0.0 )
		{
			//hits ground
			//playVO( "Rocket hits the ground - bottom_tag_origin!", "Woods" );
			
			earthquake( 0.5, 2.0, bottom_tag_origin, 500 );
			level.player PlayRumbleOnEntity( "explosion_generic" );
			
			exploder( 808 );
			playsoundatposition ("evt_rocket_bottom_crash", self.origin);
			wait( 5.0 );
			level thread maps\flashpoint_amb::chemical_alarm(1000);
			level thread maps\flashpoint_amb::bell_alarm();
			flag_set( "ROCKET_HITS_GROUND" );
			
			wait(1);
			self Delete();
			level notify( "bottom_rocket_end" );
		}
		wait( 0.1 );
	}
}


rocket_exp2()
{
	
	//This is the effect that should be used for the nearby rocket launch.  
	//It attaches to btm_rocket_jnt.  It should play until the bottom rocket crashes back to the ground.
	playfxontag(level._effect["rocket_exp_1"], self, "btm_rocket_jnt");
	self playsound ("evt_rocket_stage_1_exp");
	
	wait( 2.0 );
	
	//This is the effect that should be used for the nearby rocket launch.  
	//It attaches to btm_rocket_jnt.  It should play until the bottom rocket crashes back to the ground.
	playfxontag(level._effect["rocket_exp_2"], self, "btm_rocket_jnt");
	self playsound ("evt_rocket_stage_2_exp");
	
	//Stop rocket_exp_1 now.
}


rocket_is_destroyed_by_crossbow()
{
	level endon( "ROCKET_HITS_GROUND" );
	
	level waittill( "rocket_is_destroyed_by_crossbow" );
	//level.woods thread playVO_proper( "rambo", 2.0 );	//Rambo would be proud!
}

nextEventInxSec( x_sec )
{
// 	self.body = spawn_anim_model( "player_body", self.origin );
// 	self.body Hide();
// 	self StartCameraTween(.2);
// 	self PlayerLinkToDelta(self.body, "tag_player", 1, 90, 90, 90, 30, false);
	
	wait( x_sec );
	flag_set( "ROCKET_HITS_GROUND" );
	
// 	self FreezeControls( false );
// 	self Unlink();
// 	self.body Unlink();
// 	self.body Delete();
}


rocket_rumble()
{
	while( !flag("ROCKET_DESTROYED") )
	{
		level.player PlayRumbleOnEntity( "tank_rumble" );
		wait(0.2);
	}
}

rocket_takeoff( rocket_can_be_destroyed )
{
	exploder( 801 );
	earthquake( 0.2, 10.0, level.player.origin, 500 );
	level thread rocket_rumble();
	stop_exploder( 201 );
	
	level thread rocket_is_destroyed_by_crossbow();
	
	rocket_top = getentarray( "stationary_rocket_top", "targetname" );
	rocket_bottom = getentarray( "stationary_rocket_bottom", "targetname" );
	
	rocket_dyn_top = getent( "rocket_top_piece", "targetname" );
	rocket_dyn_bottom = getent( "rocket_bottom_piece", "targetname" );
	
	rocket_dyn_top_orig = getent( "rocket_top_piece_orig", "targetname" );
	rocket_dyn_bottom_orig = getent( "rocket_bottom_piece_orig", "targetname" );

	fxanim_flash_rocket_mod = getent( "fxanim_flash_rocket_mod", "targetname" );
	
	top_tag_origin = fxanim_flash_rocket_mod GetTagOrigin( "top_rocket_jnt" );
	bottom_tag_origin = fxanim_flash_rocket_mod GetTagOrigin( "btm_rocket_jnt" );
	
	for( i=0; i<rocket_top.size; i++ )
	{
		rocket_top[i] Hide();
	}
	
	for( i=0; i<rocket_bottom.size; i++ )
	{
		rocket_bottom[i] Hide();
	}
	
	if( isdefined(rocket_dyn_top) )
	{
		rocket_dyn_top Hide();
	}
	
	if( isdefined(rocket_dyn_bottom) )
	{
		rocket_dyn_bottom Hide();
	}
	
	if( isdefined(rocket_dyn_top_orig) )
	{
		rocket_dyn_top_orig show();
	}
	
	if( isdefined(rocket_dyn_bottom_orig) )
	{
		rocket_dyn_bottom_orig show();
	}
	
	offset_origin = rocket_dyn_top.origin - top_tag_origin;
	rocket_dyn_top linkto (fxanim_flash_rocket_mod, "top_rocket_jnt", offset_origin, (0.0,0.0,0.0) );
	rocket_dyn_top_orig linkto (fxanim_flash_rocket_mod, "top_rocket_jnt", offset_origin, (0.0,0.0,0.0) );
	
	offset_origin = rocket_dyn_bottom.origin - bottom_tag_origin;
	rocket_dyn_bottom linkto (fxanim_flash_rocket_mod, "btm_rocket_jnt", offset_origin, (0.0,0.0,0.0) );
	rocket_dyn_bottom_orig linkto (fxanim_flash_rocket_mod, "btm_rocket_jnt", offset_origin, (0.0,0.0,0.0) );
	
	
	/*
	for( i=0; i<rocket_top.size; i++ )
	{
		rocket_top[i] BypassSledgehammer();
		offset_origin = top_tag_origin - rocket_top[i].origin;
		offset_angle = rocket_top[i].angle;
		if( !isdefined(offset_angle) )
		{
			offset_angle = (0.0,0.0,0.0);
		}
		rocket_top[i] linkto (fxanim_flash_rocket_mod, "top_rocket_jnt", offset_origin, offset_angle );
		
		//rocket_top[i] linkto (fxanim_flash_rocket_mod, "top_rocket_jnt", (0,0,0), (0,0,0) );
	}
	
	for( i=0; i<rocket_bottom.size; i++ )
	{
		rocket_bottom[i] BypassSledgehammer();
		offset_origin = bottom_tag_origin - rocket_bottom[i].origin;
		offset_angle = rocket_bottom[i].angle;
		if( !isdefined(offset_angle) )
		{
			offset_angle = (0.0,0.0,0.0);
		}
		rocket_bottom[i] linkto (fxanim_flash_rocket_mod, "btm_rocket_jnt", offset_origin, offset_angle );
		
		//rocket_bottom[i] linkto (fxanim_flash_rocket_mod, "btm_rocket_jnt", (0,0,0), (0,0,0) );
	}
	*/
	
	level notify( "rocket_launch_start" );
	
	//TUEY set music state to KILL ROCKET
	setmusicstate ("KILL_ROCKET");
	
	fxanim_flash_rocket_mod thread top_rocket_piece_hits_ground();
	fxanim_flash_rocket_mod thread bottom_rocket_piece_hits_ground();
	
		
	//rocket_blast – This is the effect that should be used for the nearby rocket launch.  
	//It attaches to btm_rocket_jnt.  It should play until the bottom rocket crashes back to the ground.
	playfxontag(level._effect["rocket_blast"], fxanim_flash_rocket_mod, "btm_rocket_jnt");

	Target_Set( fxanim_flash_rocket_mod, ( 0, 0, 300 ) );

	level notify( "rocket_launch_start" );
	level thread rocket_clamps();
	
	if( rocket_can_be_destroyed )
	{
		level thread check_rocket( fxanim_flash_rocket_mod );

		//self waittill( "destroyed" );
		level waittill( "rocket_is_destroyed" );
		
		//TUEY set music state to ROCKET_DESTROYED
		setmusicstate ("ROCKET_DESTROYED");
		
		clientNotify ("rocket_destroyed");
		
		level thread play_rocket_fires();
		
		flag_set( "ROCKET_DESTROYED" );
		flag_set( "STOP_COUNTDOWN" );
		
		earthquake( 0.6, 1, level.player.origin,  2000 );
		level.player PlayRumbleOnEntity( "damage_heavy");
		
		if( isdefined(rocket_dyn_top) )
		{
			rocket_dyn_top Show();
		}
		
		if( isdefined(rocket_dyn_bottom) )
		{
			rocket_dyn_bottom Show();
		}
		
		if( isdefined(rocket_dyn_top_orig) )
		{
			rocket_dyn_top_orig Hide();
		}
		
		if( isdefined(rocket_dyn_bottom_orig) )
		{
			rocket_dyn_bottom_orig Hide();
		}
	
	
	//	level.player freezecontrols( true );
		level.player.guided_missile_lost_signal Destroy();
		level.player TakeWeapon( "flashpoint_m220_tow_sp" );
		level.player SwitchToWeapon( level.player.lastActiveWeapon );
		
		level.woods thread playVO_proper( "holyshit", 1.0 );		//Holy shit!
		level.player thread playVO_proper( "prototype", 3.0 );		//Hell of a way to test a prototype!
		level.woods thread playVO_proper( "fucken_a", 5.0 );		//Fucken - A!
		
		level.player thread nextEventInxSec( 6.0 );
    
		set_level_objective( 1, "done" );
		set_event_objective( 7, "done" );
		
		playsoundatposition ("evt_rocket_destroyed", (0,0,0));
		earthquake( 0.5, 2.0, top_tag_origin, 500 );
		level.player PlayRumbleOnEntity( "explosion_generic" );
		
		
		Objective_State( level.obj_num, "done" );
		Objective_Set3D( level.obj_num, false );
		level.obj_num++;
			
		//addNotetrack_customFunction( "fxanim_props", "notetrack_to_wait_for", rocket_exp2 );
		
		
		fxanim_flash_rocket_mod thread rocket_exp2();
		
		
		//This is the effect that should be used for the nearby rocket launch.  
		//It attaches to btm_rocket_jnt.  It should play until the bottom rocket crashes back to the ground.
		//playfxontag(level._effect["rocket_exp_1"], fxanim_flash_rocket_mod, "btm_rocket_jnt");
		
		//A fiery trail that attaches to top_rocket_jnt.  It should continue to play until the rocket top crashes to the ground.
		playfxontag(level._effect["rocket_top_trail"], fxanim_flash_rocket_mod, "top_rocket_jnt");

		wait( 0.5 );

		earthquake( 0.5, 2.0, level.player.origin, 500 );
		level.player PlayRumbleOnEntity( "explosion_generic" );
	}
}
play_rocket_fires()
{
	fires = getentarray ("amb_fire_debris_rocket", "targetname");	
	for(i=0;i<fires.size;i++)
	{
		fires[i] thread play_fire_rocket_loop();		
	}	
	
}
play_fire_rocket_loop()
{
	self playloopsound (self.script_sound);	
}
rocket_takeoff_VO()
{
	// Hopefully this puts the VO somewhere over by the rocket
	fxanim_flash_rocket_mod = getent( "fxanim_flash_rocket_mod", "targetname" );
	top_tag_origin = fxanim_flash_rocket_mod GetTagOrigin( "top_rocket_jnt" );
	
	rocket_vo_obj = Spawn("script_model", (0,0,0));
	rocket_vo_obj SetModel("tag_origin");
	rocket_vo_obj.origin = top_tag_origin;
	rocket_vo_obj.animname = "ruld";
		
	//level.player waittill( "detonate" );
	flag_wait( "C4_DETONATED" );
	
	level anim_single( rocket_vo_obj, "20sec" );
	wait(3);
	level anim_single( rocket_vo_obj, "15sec" );
	wait(3);
	level anim_single( rocket_vo_obj, "5sec" );
	wait(3);
	level anim_single( rocket_vo_obj, "2sec" );

	flag_wait( "TAKE_ROCKET" );
		
	level anim_single( rocket_vo_obj, "liftoff" );
	
	rocket_vo_obj Delete();
}

scientist_c4_anim( animname )
{
	self endon( "death" );
	
	anim_node = get_anim_struct( "c4" );
	
	self.animname = animname;
	self.allowdeath = true;

 	//Play start loop until c4 detonates, then each play “explodereact”, followed by “cowerloop”.  
 	anim_node thread anim_loop_aligned( self, "c4_start" );
 	
	//level.player waittill( "detonate" );
	flag_wait( "C4_DETONATED" );
	anim_node thread anim_single_aligned( self, "c4_react" );
	anim_node waittill( "c4_react" );
	self setgoalpos( self.origin );
	
 	anim_node thread anim_loop_aligned( self, "c4_cower" );
}

c4_building_anim_woods()
{
	anim_node = get_anim_struct( "c4" );
	
	//Wait till the AI gets to its goal before playing
	//self waittill( "goal" );
	self disable_cqbwalk();
	self disable_ai_color();

//	anim_node anim_reach_aligned( self, "c4_start" );
// 	anim_node thread anim_single_aligned( self, "c4_start" );
// 	anim_node waittill( "c4_start" );
// 	self setgoalpos( self.origin );
// 	anim_node thread anim_loop_aligned( self, "c4_wait" );
	
	//shabs
	goal_node = GetNode( "woods_c4_node", "targetname" );
	self thread force_goal( goal_node, 64 );

 	//anim_node waittill( "c4_start" );

 	flag_wait( "C4_DETONATED" );
 	
	self enable_ai_color();

 	//Wait till they are all dead
// 	while( any_alive()==true )
// 	{
// 		wait( 0.05 );
// 	}
// 	
// 	anim_node thread anim_single_aligned( self, "planb" );		//notetrack that triggers weaver 'start_weaver_computer_work'
// 	anim_node waittill( "planb" );
// 	anim_node thread anim_loop_aligned( self, "planb_wait" );
 	
 	//WAIT FOR TAKE ROCKET
 	flag_wait( "TAKE_ROCKET" );
	
	goal_node = GetNode( "woods_after_rocket_grab", "targetname" );
	self thread force_goal( goal_node, 64 );
 	//anim_node thread anim_loop_aligned( self, "rocket_explode_wait" );

 	//AFTER ROCKET EXPLODES
 	//Watching rocket explode
 	//anim_node thread anim_single_aligned( self, "rocket_explode" );
 	//anim_node waittill( "rocket_explode" );
}

ignore_bowmans_big_rocket()
{
	level endon( "NOSYMPATHY_SCENE_WOODS_AT_GOAL" );
	level waittill( "rocket_is_destroyed_by_crossbow" );
	flag_set( "TAKE_ROCKET" );
	
		
	//Swap weapon for glow gold version
	hidden_tow = getent( "hidden_tow", "targetname" );
	hidden_tow show();
	hidden_tow_gold = getent( "hidden_tow_gold", "targetname" );
	hidden_tow_gold hide();
	
	
// 	if( level.bowman.strela_is_attached )
// 	{
// 		level.bowman Detach( "t5_weapon_strela_stow", "TAG_WEAPON_RIGHT" );
// 		level.bowman.strela_is_attached = 0;
// 	}
		

// 	anim_node = get_anim_struct( "c4" );
// 	anim_node thread anim_single_aligned( self, "planb4" );
//  anim_node waittill( "planb4" );
//  anim_node thread anim_loop_aligned( self, "planb5" );	
}

c4_building_anim_bowman()
{
	level endon( "rocket_is_destroyed_by_crossbow" );
	
	anim_node = get_anim_struct( "c4" );
	
	//Wait till the AI gets to its goal before playing
	//self waittill( "goal" );
 	anim_node thread anim_loop_aligned( self, "c4_wait" );
 	self setgoalpos( self.origin );
 	
 	
 	flag_wait( "C4_DETONATED" );
 	//self stopanimscripted();
 	
 	//Run up bowman up to targetnode - find location
 //	self stopanimscripted();
 //	bowman_c4_B_node = getnode( "bowman_c4_B", "targetname" );
 //	self setgoalnode( bowman_c4_B_node );
 //	self waittill( "goal" );
	
	
 //	anim_node thread anim_loop_aligned( self, "planb1" );
 	
 //	level.bowman Attach( "t5_weapon_strela_stow", "tag_stowed_back" );
 	
 	
 	//Wait till they are all dead
 	/*
 	while( any_alive()==true )
 	{
 		wait( 0.05 );
	}
	*/
	
	
	
//	level.bowman Attach( "t5_weapon_strela_stow", "TAG_WEAPON_RIGHT" );
 	
//  	level.woods SetAnimRateComplete(3.0);
//  	anim_node thread anim_single_aligned( self, "planb2" );
//  	anim_node waittill( "planb2" );
//  	level.woods SetAnimRateComplete(1.0);
 
 
 //maps\_anim::addNotetrack_attach( "woods", "binoc_attach", "viewmodel_binoculars", "TAG_WEAPON_LEFT", "binocular_give" );
 
 	
 	flag_wait( "TAKE_WEAPON_FROM_BOWMAN" );
 	
 //	level.bowman Detach( "t5_weapon_strela_stow", "tag_stowed_back" );
 //	level.bowman Attach( "t5_weapon_strela_stow", "TAG_WEAPON_RIGHT" );
 //	level.bowman.strela_is_attached = 1;
//	anim_node thread anim_loop_aligned( self, "planb3" );
 //	println( "BOWMAN = " + self.origin );
	
	//PLAYER TAKES WEAPON
	//radius = 120;
	//spawn_position = (-9972.0, 2698.5, 458.5);
	
	
	//Swap weapon for glow gold version
	hidden_tow = getent( "hidden_tow", "targetname" );
	hidden_tow hide();
	hidden_tow_gold = getent( "hidden_tow_gold", "targetname" );
	hidden_tow_gold show();
	
	spawn_position = hidden_tow_gold.origin;//(-9972.0, 2698.5, 458.5);
	radius = 60;

	Objective_Add( level.obj_num, "current",  &"FLASHPOINT_OBJ_DESTROY_ROCKET" );
	Objective_Set3D( level.obj_num, true );
	Objective_Position( level.obj_num, spawn_position );
	
	
	level.takerocket = spawn( "trigger_radius", spawn_position, 0, radius, radius );
	level.takerocket waittill( "trigger" );
 	level.takerocket Delete();
 	
 	//Then hide it when you take it
 	hidden_tow_gold = getent( "hidden_tow_gold", "targetname" );
	hidden_tow_gold hide();
 	
	level.player.lastActiveWeapon = level.player GetCurrentWeapon();
	
	weaponOptions = level.player calcweaponoptions( 6 );
 	level.player GiveWeapon( "flashpoint_m220_tow_sp", 0, weaponOptions );
	level.player SwitchToWeapon( "flashpoint_m220_tow_sp" );
	level.player SetWeaponAmmoClip("flashpoint_m220_tow_sp", 1);
	level.player SetWeaponAmmoStock("flashpoint_m220_tow_sp", 0);
	
	flag_set( "TAKE_ROCKET" );
//	level.bowman Detach( "t5_weapon_strela_stow", "TAG_WEAPON_RIGHT" );
//	level.bowman.strela_is_attached = 0;
	//Objective_State( level.obj_num, "done" );
	
	
	
// 	    level.scr_sound["woods"]["fucken_a"] = "vox_fla1_s08_157A_wood_m"; //Fucken - A!
//     level.scr_sound["mason"]["prototype"] = "vox_fla1_s08_158A_maso"; //Hell of a way to test a prototype!
//     level.scr_sound["weaver"]["blowit"] = "vox_fla1_s08_159A_weav"; //Blow it, Mason! NOW!
//     level.scr_sound["woods"]["fireit"] = "vox_fla1_s08_160A_wood_m"; //Fire It!
//     level.scr_sound["woods"]["holyshit"] = "vox_fla1_s08_161A_wood_m"; //Holy shit!
    
    
    
    level.weaver thread playVO_proper( "blowit");	//Blow it, Mason! NOW!
	
	
	//Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_FIRE_AT_ROCKET" );
	
	fxanim_flash_rocket_mod = getent( "fxanim_flash_rocket_mod", "targetname" );
	//top_tag_origin = fxanim_flash_rocket_mod GetTagOrigin( "top_rocket_jnt" );
	
	//Objective_Add( level.obj_num, "current",  &"FLASHPOINT_OBJ_DESTROY_ROCKET", fxanim_flash_rocket_mod );
	Objective_Position( level.obj_num, fxanim_flash_rocket_mod );
	Objective_Set3D( level.obj_num, true );

	
	//screen_message_create(&"TVMISSILE_CONTROLS");

//	anim_node thread anim_single_aligned( self, "planb4" );
 //	anim_node waittill( "planb4" );
 //	anim_node thread anim_loop_aligned( self, "planb5" );
}




c4_building_anim_brooks()
{
	anim_node = get_anim_struct( "c4" );
	
	//Wait till the AI gets to its goal before playing
	//self waittill( "goal" );
  	anim_node thread anim_loop_aligned( self, "c4_wait" );
  	self setgoalpos( self.origin );
}

c4_building_anim_weaver()
{
	anim_node = get_anim_struct( "c4" );
	
	//Wait till the AI gets to it  goal before playing
	//self waittill( "goal" );
	
	self disable_cqbwalk();
	self disable_ai_color();
//	anim_node anim_reach_aligned( self, "c4_start" );

//	flag_set( "BOMB_PLANT_READY" );
	
// 	anim_node thread anim_single_aligned( self, "c4_start" );
// 	anim_node waittill( "c4_start" );
// 	self setgoalpos( self.origin );
// 	anim_node thread anim_loop_aligned( self, "c4_wait" );
 	
	//shabs
//	goal_node = GetNode( "weaver_c4_node", "targetname" );
//	self thread force_goal( goal_node, 64 );

	self waittill( "goal" );
 	self setgoalpos( self.origin );

	flag_set( "BOMB_PLANT_READY" );

	level waittill( "explosive_set" );

 	//self setgoalpos( self.origin );
 	anim_node thread anim_loop_aligned( self, "c4_wait" );

 	flag_wait( "C4_DETONATED" );
 	
 
 	wait( 2.0 );
 	
 	level.weaver thread playVO_proper( "destroyrocket", 4.0 );	//We have to destroy the rocket - no matter what!
	level thread rocket_takeoff_start( 10.0 );
	level.weaver thread playVO_proper( "toolate2", 10.0 );	//It's too late! I can't stop it!
	
	level.woods thread playVO_proper( "setitup", 16.0 );	//It's too late! I can't stop it!

 	anim_node thread anim_single_aligned( self, "planb_enterc4" );
 	anim_node waittill( "planb_enterc4" );
 	self setgoalpos( self.origin );
	self enable_ai_color();

 	
// 	in_bunker_B_node = getnode( "in_bunker_B", "targetname" );
//  	level.weaver setgoalnode( in_bunker_B_node );
//  	level.weaver waittill( "goal" );
	
	/*
	if( any_alive() )
	{
		playVO( "Please don't kill us....", "SCIENTISTS" );
		wait( 2.0 );
	}
	*/
	/*if( any_alive() )
	{
		level.player thread playVO_proper( "killthem");	//Kill them where they stand.
		//wait( 1.0 );
	}*/
	
	//level.player thread playVO_proper( "killthem");	//Kill them where they stand.

 	//level.weaver thread kill_them_all();
 	
 	//Wait till they are all dead
 	/*while( any_alive()==true )
 	{
 		wait( 0.05 );
 	}*/
 	//Objective_State( level.obj_num, "done" );
 	
 
  	/*
 	level.scr_sound["woods"]["moveit"] = "vox_fla1_s07_147A_wood"; //Move it!
    level.scr_sound["weaver"]["destroyrocket"] = "vox_fla1_s08_148A_weav_m"; //We have to destroy the rocket - no matter what!
    level.scr_sound["woods"]["holeinwall"] = "vox_fla1_s08_149A_wood_m"; //Mason, put a hole in that fuckin' wall!
    level.scr_sound["mason"]["ready"] = "vox_fla1_s08_150A_maso"; //Ready.
    level.scr_sound["woods"]["killall"] = "vox_fla1_s08_151A_wood"; //Kill 'em all!
    level.scr_sound["woods"]["move"] = "vox_fla1_s08_152A_wood_m"; //Move.
    level.scr_sound["woods"]["comeon"] = "vox_fla1_s08_153A_wood_m"; //Come on... Come on!
    */

//     level.weaver thread playVO_proper( "destroyrocket" );	//We have to destroy the rocket - no matter what!
// 	level thread rocket_takeoff_start( 0.0 );
   
   // level.weaver thread playVO_proper( "toolate2", 5.0 );	//It's too late! I can't stop it!
 	//level.woods thread playVO_proper( "setitup", 7.0 );	//Plan B, Bowman - Set it up!
 	//level.bowman thread playVO_proper( "thisdoit", .0 ); //This'll do it!
 	
//     anim_node thread anim_single_aligned( self, "planb_computer" );
//  	anim_node waittill( "planb_computer" );
//     self setgoalpos( self.origin );
    
    //anim_node thread anim_single_aligned( self, "planb_exitc4" );
 	//anim_node waittill( "planb_exitc4" );
	self setgoalpos( self.origin );

 //   anim_node thread anim_loop_aligned( self, "planb_wait" );
   
 	flag_set( "TAKE_WEAPON_FROM_BOWMAN" );
 	level.bowman thread playVO_proper( "thisdoit" ); //This'll do it!
 	
 	//level thread rocket_takeoff_start( 0.0 );

 //	anim_node thread anim_loop_aligned( self, "planb_wait" );
 	
 	//FLASHPOINT_OBJ_DESTROY_ROCKET
	set_event_objective( 7, "active" );
}

rocket_takeoff_start( waittime )
{
	wait( waittime );
	level thread rocket_takeoff( true );	
}


teleport_bowman_and_brooks()
{
	teleport_bowman_c4_node = getnode( "control_room_C", "targetname" );
	teleport_brooks_c4_node = getnode( "control_room_D", "targetname" );

	if( isdefined( teleport_bowman_c4_node ) )
	{
		level.bowman forceTeleport( teleport_bowman_c4_node.origin );
		level.bowman SetGoalPos( teleport_bowman_c4_node.origin );
	}
	
	if( isdefined( teleport_brooks_c4_node ) )
	{
		level.brooks forceTeleport( teleport_brooks_c4_node.origin );
		level.brooks SetGoalPos( teleport_brooks_c4_node.origin );
	}
	
	level.bowman thread c4_building_anim_bowman();
	level.bowman thread ignore_bowmans_big_rocket();
	level.brooks thread c4_building_anim_brooks();
}


delete_axis_ai_during_c4_scene()
{
	ai_array = GetAIArray( "axis" );
	
	for(i = ai_array.size - 1; i >= 0; i-- )
	{
		//if( IsDefined(ai_array[i].targetname) && !IsSubStr( ai_array[i].targetname, "zipline_room_guard" ) )
		//{
			ai_array[i] Die();
		//}
	}
}



event8_ControlRoomBunkerBreach()
{
/*
 Squad arrives at control room bunker
 Woods VO: The door’s ultra reinforced steel – we’re going in through the wall instead
 NOTE: Rocket is visibly preparing for launch
 Woods: We need to eliminate the (evil Nazi) Ascension Group scientists in here and stop the rocket
 Player sets and blows the charges creating an opening

solution as discussed with Dom & Adam - 

Woods should be AI the entire time. His line can be VO as he makes his way up the stairs. 

Weaver should also be AI, and walk to his c4 building start position at the top of the stairs in AI. 
He transitions to his vignette just as the player blows the c4 and plays out as is implemented currently 
*/
	autosave_by_name("flashpoint_e8");
	maps\flashpoint::event9_triggers( false );
	
	flag_set( "STOP_COUNTDOWN" );
	delete_axis_ai_during_c4_scene();
	
	battlechatter_off( "axis" );
	battlechatter_off( "allies" );
	
	
	//Play pre c4 building anims
	level.weaver thread c4_building_anim_weaver();
	level.woods thread c4_building_anim_woods();
	//level.bowman thread c4_building_anim_bowman();
	//level.brooks thread c4_building_anim_brooks();
	
	level thread rocket_takeoff_VO(); // The part of the countdown right before the rocket launches
	
	//Spawn scientists inside bunker
	level.bunker_scientist[0] = simple_spawn_single( "bunker_scientist_01", ::setup_bunker_scientist );
	level.bunker_scientist[1] = simple_spawn_single( "bunker_scientist_02", ::setup_bunker_scientist );
	level.bunker_scientist[2] = simple_spawn_single( "bunker_scientist_03", ::setup_bunker_scientist );
	level.bunker_scientist[3] = simple_spawn_single( "bunker_scientist_04", ::setup_bunker_scientist );
	level.bunker_scientist[0] thread scientist_c4_anim( "scientist1" );
	level.bunker_scientist[1] thread scientist_c4_anim( "scientist2" );
	level.bunker_scientist[2] thread scientist_c4_anim( "scientist3" );
	level.bunker_scientist[3] thread scientist_c4_anim( "scientist4" );
	
	//-- disable alternate detonation
	player = get_players()[0];
	player notify("no_alt_detonate");
	
	
	flag_wait( "BOMB_PLANT_READY" );
	level.woods thread playVO_proper( "holeinwall" );		//Mason, put a hole in that fuckin' wall!
	wait( 1.0 );

// 	level.player thread playVO_proper( "ready" );		//Ready.
// 
// 
// level.scr_sound["mason"]["ready"] = "vox_fla1_s08_150A_maso"; //Ready.
// 
// 
// 	level thread playVO( "We need to take out the (evil Nazi) Ascension group scientists and stop the launch", "Woods" );
// 	level thread playVO( "The door is re-enforced – we'll go through the wall", "Woods", 1.0 );
	
	
	 
  	/*
 	level.scr_sound["woods"]["moveit"] = "vox_fla1_s07_147A_wood"; //Move it!
    level.scr_sound["weaver"]["destroyrocket"] = "vox_fla1_s08_148A_weav_m"; //We have to destroy the rocket - no matter what!
    level.scr_sound["woods"]["holeinwall"] = "vox_fla1_s08_149A_wood_m"; //Mason, put a hole in that fuckin' wall!
    level.scr_sound["mason"]["ready"] = "vox_fla1_s08_150A_maso"; //Ready.
    level.scr_sound["woods"]["killall"] = "vox_fla1_s08_151A_wood"; //Kill 'em all!
    level.scr_sound["woods"]["move"] = "vox_fla1_s08_152A_wood_m"; //Move.
    level.scr_sound["woods"]["comeon"] = "vox_fla1_s08_153A_wood_m"; //Come on... Come on!
    */
    
    
    
 //	level.weaver thread playVO_proper( "toolate" );	//It's too late! I can't stop it!
 	
 	
 	
	
	//Now player needs to set explosive charge
	explosive_charge = getent( "b2_satchel", "targetname" );
	explosive_charge_flashy = getent( "b2_satchel_old", "targetname" );
	//Objective_Add( level.obj_num, "current",  &"FLASHPOINT_OBJ_PLANT_EXPLOSIVE", explosive_charge.origin + ( 0, 0, 15 ) );
	Objective_Set3D( level.obj_num, true, "yellow", &"FLASHPOINT_OBJ_PLANT_C4" );
	explosive_charge_flashy show();
	
	level thread explosive_trigger_hint_press();
	level waittill( "explosive_set" );
	
	//Objective_State( level.obj_num, "done" );
	Objective_Set3D( level.obj_num, false );  //clear c4 plant position
	
	
	//level.player thread playVO_proper( "ready" );		//Ready.
		
	//Objective_State(level.obj_num,"done");
	
	//Teleport bowman and brooks to run up to the c4 building
	level thread teleport_bowman_and_brooks();
	
	level.player.lastActiveWeapon = level.player GetCurrentWeapon();

	explosive_charge_flashy delete();
	
	play_player_setting_bomb_anim( explosive_charge );
	explosive_charge Show();

	level.player GiveWeapon( "satchel_charge_sp" );
	
	level.player SetWeaponAmmoClip("satchel_charge_sp", 0);
	level.player SetWeaponAmmoStock("satchel_charge_sp", 0);
	level.player DisableWeaponCycling();
	level.player DisableOffhandWeapons();
	
	//level.player SetActionSlot( 4, "weapon", "satchel_charge_sp" );
	level.player SetActionSlot( 3, "" );
	level.player SwitchToWeapon( "satchel_charge_sp" );

	level.player thread event8_c4_tutorial_message();
	level.player thread playVO_proper( "ready" );		//Ready.
	level.player waittill_any( "detonate", "alt_detonate" );
	flag_set( "C4_DETONATED" );
	
	level.player SetActionSlot( 3, "altMode" );	// toggles between attached grenade launcher
	
	
	//Destory the terminals
	struct_bunker_damage1 = getstruct( "struct_bunker_damage1", "targetname" );
	struct_bunker_damage2 = getstruct( "struct_bunker_damage2", "targetname" );
	struct_bunker_damage3 = getstruct( "struct_bunker_damage3", "targetname" );
	struct_bunker_damage4 = getstruct( "struct_bunker_damage4", "targetname" );
	struct_bunker_damage5 = getstruct( "struct_bunker_damage5", "targetname" );
	radiusDamage(struct_bunker_damage1.origin, 128, 100, 50);
	radiusDamage(struct_bunker_damage2.origin, 512, 100, 50);
	radiusDamage(struct_bunker_damage3.origin, 128, 100, 50);
	radiusDamage(struct_bunker_damage4.origin, 128, 100, 50);
	radiusDamage(struct_bunker_damage5.origin, 128, 100, 50);
	
	//Show hide the tow and panel
	tow_hide = getent( "tow_hide", "targetname" );
	tow_hide hide();
	tow_hide_damaged = getent( "tow_hide_damaged", "targetname" );
	tow_hide_damaged show();
	hidden_tow_gold = getent( "hidden_tow_gold", "targetname" );
	hidden_tow_gold hide();
	
	earthquake( 0.6, 1, level.player.origin,  500 );
	level.player PlayRumbleOnEntity( "damage_heavy");
	
	 //All scientists must die
 	for( i=0; i<4; i++ )
 	{
 		if( isAlive( level.bunker_scientist[i]) )
 		{
 			level.bunker_scientist[i] Die();
 		}
 	}
 	
	
	//Kevin adding adudio notify to start launch sequence loop
	explosive_charge playsound( "evt_c4_det" );
	level notify( "start_rocket_loop" );
	
	exploder( 800 );
	level notify( "c4_bunker_start" );
		
	//Explosion! - C4 Building Wall piece:
	explosive_charge delete();
	
	c4holePiece = getentarray( "c4hole", "targetname" );
	c4holePieceOrigin = c4holePiece[0].origin;
	for (i = 0; i < c4holePiece.size; i++)
	{
		c4holePiece[i] ConnectPaths();
		c4holePiece[i] Delete();
	}
	
	//Damaged c4 building hole
	c4_d = getentarray( "c4_d", "targetname" );
	for (i = 0; i < c4_d.size; i++)
	{
		c4_d[i] show();
	}
	
	level.player TakeWeapon( "satchel_charge_sp" );
	level.player EnableWeaponCycling();
	level.player enableoffhandweapons();
	level.player SwitchToWeapon( level.player.lastActiveWeapon );
	
	wait( 0.1 );
	RadiusDamage( c4holePieceOrigin, 128, 450, 70, level.player );
	
	//Objective_State( level.obj_num, "done" );
	//Objective_Set3D( level.obj_num, false );
	
	wait( 1.0 );
	event8_ControlRoomBunkerKillEveryone();
}

//self is the player
event8_c4_tutorial_message()
{
	screen_message_create(&"FLASHPOINT_C4_INSTRUCT"); //right trigger accelerate
	level.player waittill_any_or_timeout(5.0, "detonate", "alt_detonate" );
	screen_message_delete();
}

shoot_and_kill( enemy )
{
	self endon( "death" );
	//enemy endon( "death" );

	self.perfectAim = true;
	//enemy.health = 1;
	while( IsAlive(enemy) )
	{
		self shoot_at_target( enemy,"J_head" );
		wait(0.05);
	}

	self.perfectAim = false;
	self notify( "enemy_killed" );
}

kill_them_all()
{
 	for( i=0; i<4; i++ )
 	{
 		if( isAlive( level.bunker_scientist[i]) )
 		{
 			self shoot_and_kill( level.bunker_scientist[i] );
 		}
 		wait( 0.2 );
 	}
}

any_alive()
{
 	for( i=0; i<4; i++ )
 	{
 		if( isAlive( level.bunker_scientist[i]) )
 		{
 			return true;
 		}
 	}
 	return false;
}

kill_everyone_obj()
{
	level endon( "TAKE_ROCKET" );
	
	player_in_c4bunker = getent( "player_in_c4bunker", "targetname" );
	player_in_c4bunker waittill( "trigger" );
	
	//Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_KILL_EVERYONE" );
	
	level notify( "ceiling_light_fall_start" );
}

//tutorial messages for the tv guided missile, self is the player
tv_missile_controls()
{
	//wait until the player obtained the weapon
	while( self GetCurrentWeapon() != "flashpoint_m220_tow_sp" )
	{
		wait(0.05);
	}

	//display how to aim tutorial
	screen_message_delete();
	self thread tv_missile_controls_message(&"FLASHPOINT_TVMISSILE_CONTROLS");
	
	//wait until the player enters ADS
	while( !isADS(self) )
	{
		wait( 0.05 );
	}

	//display how to steer the rocket in air
	screen_message_delete();
	wait(0.5);
	self thread tv_missile_controls_message(&"PLATFORM_TVMISSILE_CONTROLS_2");
}

tv_missile_controls_message(message)
{
	screen_message_create(message);
	wait(5);
	screen_message_delete();
}

event8_ControlRoomBunkerKillEveryone()
{
/*
 Woods identifies them as Ascension group members
 The evil scientists are begging for their lives
 Woods VO: “Take em out”
 Once done, squad shoots all the consoles around the room, but the rocket still continues to launch
 Player is given (Woods throws?) a Black Ops style TV-Guided Missile Launcher
 Woods VO: “This is our first field test of this weapon – and we only have one missile - make it count”
 Player is instructed to take down the rocket as it’s launching
*/

	level thread kill_everyone_obj();
	
 	flag_wait( "TAKE_ROCKET" );
 	level.player thread tv_missile_controls();
	event8_DestroyRocket();
	
}

event8_DestroyRocket()
{
/*
 Rocket is launching
 Player must launch TV guided missile into rocket to blow it up
 If Player misses, it’s game over
 If Player hits, rewarded with spectacular destruction and pieces of rubble starting to rain down all around Player
 Woods VO: We need to get moving and find the rest of those Ascension scientists
*/

	////level.player GiveWeapon( "flashpoint_strela_sp" );
	///level.player SwitchToWeapon( "flashpoint_strela_sp" );
	//level notify( "rocket_launch_start" );
	
	//level thread rocket_takeoff();
	
//	fxanim_flash_rocket_mod = getent( "fxanim_flash_rocket_mod", "targetname" );
	
	

// 	Level Notify:  rocket_launch_start
// 	Targetname for the model:   fxanim_flash_rocket_mod
// 	Link the top part of the rocket to this bone:  top_rocket_jnt
// 	Link the bottom part of the rocket to this bone:  btm_rocket_jnt
// 
// 	After sending the notify, the rocket will take off and then look to take damage.  When it does, it should play its exploding animation.
// 
// 	Without being able to see the rocket linked to these bones in-game, I wasn’t able to verify this working, so let me know if you run into any issues.  Thanks Peter.  


	
	//wait( 1.0 );
	//playVO( "This is the first field test of this weapon - , don't miss", "Woods" );
	
	//Wait for weapon to be fired - hit or miss
	
	
	event8_RocketAftermath();
}

event8_RocketAftermath()
{
/*
 The aftermath of the explosion is raining down on the squad
 Huge chunks (dangerous looking) fall in front of the Player
 A piece of the fence is blown apart and blocks the way ahead, forcing the squad to slide beneath it (and Player to move and duck)

 This fiery chunk falls right in front of the Player and he must leap over it or be burned as he touches it

 Squad needs to enter building into which the workers are fleeing
 GEO NOTE: On the MS#6 build, the entrance used is the one on the other side of the building. The geo inside the entrance there (below) will have to be moved to here
*/	

	//level thread playVO( "We need to get the hell out of here", "Woods", 5.0 );
	maps\flashpoint::event8_triggers( false );
	maps\flashpoint::event9_triggers( true );	
	
	flag_wait( "ROCKET_DESTROYED" );
	
	c4_area_blocker = getent( "c4_area_blocker", "targetname" );
	c4_area_blocker NotSolid();
			
	level.woods StopAnimScripted();
 	level.weaver StopAnimScripted();
 	level.bowman StopAnimScripted();
 	level.brooks StopAnimScripted();
 	
 	level.weaver thread disable_cqbwalk();
 	level.woods thread disable_cqbwalk();
 	level.bowman thread disable_cqbwalk();
 	level.brooks thread disable_cqbwalk();
	
	//flag_wait( "ROCKET_HITS_GROUND" );
	//level.player freezecontrols( false );
	//flag_wait( "ROCKET_DESTROYED" );
	
	//level.woods thread playVO_proper( "stayinopen", 1.0 );		//Dammit... Can't stay in the open.
	//level.woods thread playVO_proper( "gettotunnel", 3.0 );		//Get to the tunnels!
	
	//level.player TakeWeapon( "flashpoint_m220_tow_sp" );
	
	
	//FLASHPOINT_OBJ_ESCAPE_BASE
	set_level_objective( 2, "active" );
	set_event_objective( 8, "active" );
	
	//level thread playVO( "We need to get the hell out of here", "Woods", 2.0 );
	
// 	level.woods StopAnimScripted();
// 	level.weaver StopAnimScripted();
// 	level.bowman StopAnimScripted();
// 	level.brooks StopAnimScripted();
// 	
// 	level.weaver thread disable_cqbwalk();
// 	level.woods thread disable_cqbwalk();
// 	level.bowman thread disable_cqbwalk();
// 	level.brooks thread disable_cqbwalk();
	
	//Goto next event
	flag_set("BEGIN_EVENT9");
}


////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////
