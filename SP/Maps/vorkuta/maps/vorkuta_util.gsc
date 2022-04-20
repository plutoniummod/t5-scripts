#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;

//MikeD Steez
Print3d_on_ent( msg ) 
 { 
 /# 
	self endon( "death" );  
	self notify( "stop_print3d_on_ent" );  
	self endon( "stop_print3d_on_ent" );  

	while( 1 ) 
	{ 
		print3d( self.origin + ( 0, 0, 0 ), msg );  
		wait( 0.05 );  
	} 
 #/ 
 }
 
player_can_see_me( player )
{
	playerAngles = player getplayerangles();
	playerForwardVec = AnglesToForward( playerAngles );
	playerUnitForwardVec = VectorNormalize( playerForwardVec );

	banzaiPos = self GetOrigin();
	playerPos = player GetOrigin();
	playerToBanzaiVec = banzaiPos - playerPos;
	playerToBanzaiUnitVec = VectorNormalize( playerToBanzaiVec );

	forwardDotBanzai = VectorDot( playerUnitForwardVec, playerToBanzaiUnitVec );
	angleFromCenter = ACos( forwardDotBanzai ); 

	playerFOV = GetDvarFloat( #"cg_fov" );
	banzaiVsPlayerFOVBuffer = GetDvarFloat( #"g_banzai_player_fov_buffer" );	
	if ( banzaiVsPlayerFOVBuffer <= 0 )
	{
		banzaiVsPlayerFOVBuffer = 0.2;
	}

	playerCanSeeMe = ( angleFromCenter <= ( playerFOV * 0.5 * ( 1 - banzaiVsPlayerFOVBuffer ) ) );

	return playerCanSeeMe;
}
 
 
Delete_me()	
{
	self Delete();
}	 

kill_all_enemies()
{
	while( 1 )
	{
		enemies = getaiarray( "axis" );
		if( enemies.size == 0 )
		{
			return;
		}	
		enemies[0] dodamage( enemies[0].health + 100, (0,0,0), enemies[0] );
		wait( 0.05 );
	}
}

fade_out( time )
{
	if( !isdefined( level.fade_out_overlay ) )
	{
		level.fade_out_overlay = NewHudElem();
		level.fade_out_overlay.x = 0;
		level.fade_out_overlay.y = 0;
		level.fade_out_overlay.horzAlign = "fullscreen";
		level.fade_out_overlay.vertAlign = "fullscreen";
		level.fade_out_overlay.foreground = false;  // arcademode compatible
		level.fade_out_overlay.sort = -1;  // arcademode compatible
		level.fade_out_overlay SetShader( "black", 640, 480 );
	}

	// start off invisible
	level.fade_out_overlay.alpha = 0;

	level.fade_out_overlay fadeOverTime( time );
	level.fade_out_overlay.alpha = 1;
	wait( time );
}


fade_in( time, delay_time )
{
	if( isdefined( delay_time ) )
	{
		wait( delay_time );
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
		level.fade_out_overlay SetShader( "black", 640, 480 );
	}

	level.fade_out_overlay.alpha = 1;

	level.fade_out_overlay fadeOverTime( time );
	level.fade_out_overlay.alpha = 0;
	wait( time );
}



force_move_guy( guy, final_pos, final_angle, duration, lock_in_place )
{
	guy.mover = spawn( "script_origin", guy.origin );
	guy.mover.angles = guy.angles;
	guy linkto( guy.mover );
	
	guy.mover moveto( final_pos, duration, 0.1, 0.1 );
	guy.mover rotateto( final_angle, duration, 0.1, 0.1 );
	wait( duration );
	
	if( isdefined( lock_in_place ) && lock_in_place == true )
	{
		return;
	}
	
	guy unlink();
	guy.mover delete();
}

/////////////////////
//Flamer Util Stuff//
/////////////////////

spawn_a_model(model, myorigin, myangles)
{
	spot = spawn ("script_model", myorigin);
	if (isdefined(myangles))
	{
		spot.angles = myangles;
	}
	spot setmodel(model);
	return spot;
}

wait_for_attack_button()
{
	breakme = 0;
	while(breakme == 0)
	{
		players = get_players();
		for (i=0; i < players.size; i++)
		{
			if (players[i] AttackButtonPressed() )
			{
				breakme = 1;
			}
		}
		wait 0.05;
	}
}

wait_for_gas_button()
{
	breakme = 0;
	while(breakme == 0)
	{
		players = get_players();
		for (i=0; i < players.size; i++)
		{
			if (players[i] GasButtonPressed() )
			{
				breakme = 1;
			}
		}
		wait 0.05;
	}
}

wait_for_ADS()
{
	breakme = 0;
	while(breakme == 0)
	{
		players = get_players();
		for (i=0; i < players.size; i++)
		{
			if (players[i] ThrowButtonPressed() )
			{
				breakme = 1;
				level notify ("player_did_ADS");
			}
		}
		wait 0.05;
	}
}

wait_for_attack()
{
	breakme = 0;
	while(breakme == 0)
	{
		players = get_players();
		for (i=0; i < players.size; i++)
		{
			if (players[i] AttackButtonPressed() )
			{
				breakme = 1;
				level notify ("player_did_attack");
			}
		}
		wait 0.05;
	}
}

wait_for_attack_button_or_timeout(time)
{
	level endon ("player_did_attack");
	self thread wait_for_attack();
	wait (time);
	return;
}	

wait_for_ADS_or_timeout(time)
{
	level endon ("player_did_ADS");
	self thread wait_for_ADS();
	wait (time);
	return;
}	

ignore_on(paci)
{
	self.ignoreme = true;
	self.ignoreall = true;
	if (isdefined(paci))
	{
		self.pacifist = true;
	}
}

ignore_off()
{
	self.ignoreme = false;
	self.ignoreall = false;
	self.pacifist = false;
}
	
go_no_matter_what()
{
	//this is the same as rush_to but does not specify a goal
	//self = AI that is rushing
	self endon ("death");
	self.dropweapon = 0;
	self disable_pain();
	self disable_react();
	self.ignoresuppression=1;
	self.old_goalradius = self.goalradius;
	self.goalradius =20;
	self.old_pathenemyFightdist = self.pathenemyFightdist;
	self.pathenemyFightdist=64;
	self waittill ("goal");
	
	self.pathenemyFightdist = self.old_pathenemyFightdist;
	self.goalradius = self.old_goalradius;
	self.ignoresuppression=0;
	self enable_pain();
	self enable_react();
}	

do_nag_vo(character, scene_name, ender_flag, repeat_interval)
{
	//does VO line until specified flag
	character anim_single( character, scene_name );
	level endon (ender_flag);
	x = 0;
	while(!flag(ender_flag))
	{
		wait 1;
		x++;
		if(x == repeat_interval)
		{
			character anim_single( character, scene_name );
			x = 0;
		}
	}
	
	return;	
}	

AB_nag_vo(character, scene_name1, scene_name2, ender_flag, repeat_interval)
{
	//alternates between two VO lines until specified flag
 character anim_single( character, scene_name2 );	
	x = 0;
	did_scene1 = false;
	level endon (ender_flag);
	while(!flag(ender_flag))
	{		
		wait 1;
		x++;
		if(x == repeat_interval)
		{
			if(did_scene1 == false)
			{
				character anim_single( character, scene_name1 );
				did_scene1 = true;
				x = 0;
			}
			else
			{
				character anim_single( character, scene_name2 );
				did_scene1 = false;
				x = 0;
			}
		}
	}
	//return;	
}	
	
//play_line_now - toggle whether or not the nag plays immediately or waits the repeat_interval time
do_nag_vo_array(character, scene_name, ender_flag, repeat_interval, play_line_now)
{
	level endon (ender_flag);

	Assert(scene_name.size > 1, "VO array is empty");

	vo_array = array_randomize(scene_name);
	vo_index = 0;

	//does VO line until specified flag
	if( IsDefined(play_line_now) && play_line_now )
	{
		character anim_single( character, vo_array[vo_index] );
		vo_index++;
		if(vo_index == vo_array.size)
		{
			vo_index = 0;
		}		
	}

	while(!flag(ender_flag))
	{
		wait(repeat_interval);

		character anim_single( character, vo_array[vo_index] );
		vo_index++;
		if(vo_index == vo_array.size)
		{
			vo_index = 0;
		}	
	}
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

fake_physicslaunch( target_pos, power )
{
	start_pos = self.origin; 
	
	///////// Math Section
	// Reverse the gravity so it's negative, you could change the gravity
	// by just putting a number in there, but if you keep the dvar, then the
	// user will see it change.
	gravity = getDvarInt( #"bg_gravity" ) * -1; 

	dist = Distance( start_pos, target_pos ); 
	
	time = dist / power; 
	delta = target_pos - start_pos; 
	drop = 0.5 * gravity *( time * time ); 
	
	velocity = ( ( delta[0] / time ), ( delta[1] / time ), ( delta[2] - drop ) / time ); 
	///////// End Math Section

	//level thread draw_line_ent_to_pos( self, target_pos );
	self MoveGravity( velocity, time );
	return time;
}

launch_ragdoll_on_death (x,y,z)
{
	//self = ai getting launched
	self endon("death");

	self waittill ("damage");
	self ragdoll_death();
	self LaunchRagdoll( (x,y,z) );	

}	

//from Shabs/Khe Sahn
burn_me()
{
	//self = ai on fire
  self endon( "death" );
  
  self random_burn_anim();

  self.ignoreme = true;
  self.ignoreall = true;

  self thread animscripts\death::flame_death_fx();
  anim_single( self, "burning_fate" );

  self Die();
}


random_burn_anim()
{
  anims = array("on_fire_1","on_fire_2","on_fire_3","on_fire_4");
  self.animname = anims[RandomInt(anims.size)];
  
}


/////////////////
//VEHICLE STUFF//
/////////////////


btr_fire_at(ent, bullets_min, bullets_max)
{
	//self = btr
	self endon ("death");
	
	times = RandomFloatRange (bullets_min, bullets_max);
	

	for (i = 0; i < times; i++ )
	{
		x = RandomIntRange (50,80);		
		self setGunnerTargetVec (ent.origin + (x,x,x) );
		self fireGunnerWeapon();
		wait RandomFloatRange (.10, .30);
	}	
	
	self clearGunnerTarget();
	self notify ("done_firing");
	
}	
	
gunner_shoot_burts(bullet_count)
{		
	//this is for a vehicle with a gunner weapon that is already aiming at its target by other means
	self endon ("death");	
	//C. Ayers: Taking control of gunner audio out of the GDT
	self thread play_gunner_audio();
	for(i = 0; i < bullet_count; i++)
	{
		self fireGunnerWeapon();
		wait (RandomFloatRange(.3, .6));
	}
	self notify( "stop_fake_gunfire_loop" );	
}	

play_gunner_audio()
{
    self notify( "force_stop_old_thread" );
    origin = self GetTagOrigin( "tag_gunner1" );
    sound_ent = Spawn( "script_origin", origin );
    sound_ent LinkTo( self, "tag_gunner1" );
    sound_ent PlayLoopSound( "wpn_gaz_quad50_turret_loop_npc", .25 );
    self waittill_any( "death", "stop_fake_gunfire_loop", "force_stop_old_thread" );
    sound_ent Delete();
}
	
// Fake death
// self = the guy getting worked
bloody_death( die, delay )
{
	self endon( "death" );

	if( !isdefined( die ) )
	{
		die = true;	
	}

	if( IsDefined( self.bloody_death ) && self.bloody_death )
	{
		return;
	}

	if( !IsDefined(self) )
	{
		return;
	}

	self.bloody_death = true;

	if( IsDefined( delay ) )
	{
		wait( RandomFloat( delay ) );
	}

	if( !IsDefined( self ) )
	{
		return;	
	}

	tags = [];
	tags[0] = "j_hip_le";
	tags[1] = "j_hip_ri";
	tags[2] = "j_head";
	tags[3] = "j_spine4";
	tags[4] = "j_elbow_le";
	tags[5] = "j_elbow_ri";
	tags[6] = "j_clavicle_le";
	tags[7] = "j_clavicle_ri";
	
	for( i = 0; i < 3; i++ )
	{
		if( IsAlive(self) )
		{
			random = RandomInt(tags.size);
			if( is_mature() )
			{
				self thread bloody_death_fx( tags[random], undefined );
			}
			self PlaySound ("prj_bullet_impact_large_flesh");
		}
		wait( RandomFloat( 0.1 ) );
	}

	if( die && IsDefined(self) && IsAlive(self) )
	{
		self DoDamage( self.health + 100, self.origin);
	}
}	

// self = the AI on which we're playing fx
bloody_death_fx( tag, fxName ) 
{ 
	if( !IsDefined( fxName ) )
	{
		fxName = level._effect["bloody_death"][ RandomInt(level._effect["bloody_death"].size) ];
	}

	PlayFxOnTag( fxName, self, tag );
}

create_prisoner_model(animname, origin, angles)
{
	model = spawn_anim_model("prisoner_model");
	model character\c_rus_prisoner::main();
	
	if(IsDefined(animname))
	{
		model.animname = animname;
	}
	else
	{
		model.animname = "generic";
	}	

	if(IsDefined(origin))
	{
		model.origin = origin;
	}

	if(IsDefined(angles))
	{
		model.angles = angles;
	}

	//assign the models a team and name
	model MakeFakeAI(); 
	model.team = "allies"; 
	model setlookattext( maps\vorkuta::vorkuta_custom_names(), &"" ); 

	return model;
}

create_guard_model(animname, origin, angles)
{
	model = spawn_anim_model("guard_model");
	model character\c_rus_prison_guard::main();
	
	if(IsDefined(animname))
	{
		model.animname = animname;
	}
	else
	{
		model.animname = "generic";
	}	

	if(IsDefined(origin))
	{
		model.origin = origin;
	}

	if(IsDefined(angles))
	{
		model.angles = angles;
	}

	return model;
}

//written for audio to find closest 3 allies to the player within a distance
get_closest_prisoners()
{
	player_org = get_players()[0].origin;
	prisoners = GetAIArray("allies");
	excluders[0] = level.reznov;
	array_size = 3;
	max_distance = 1028;

	//grab array of up to 3 closest prisoners that are not reznov
	closest = get_array_of_closest( player_org, prisoners, excluders, array_size, max_distance );

	return closest;
}

play_prisoner_crowd_vox( alias1, alias2, alias3 )
{
	if( IsDefined(level.gas_attack_audio) && level.gas_attack_audio )
	{
		return;
	}

	prisoners = get_closest_prisoners();

	if( IsDefined( prisoners[0] ) )
		prisoners[0] PlaySound( alias1 );

	if( IsDefined( prisoners[1] ) )
		prisoners[1] PlaySound( alias2 );   

	if( IsDefined( prisoners[2] ) )
		prisoners[2] PlaySound( alias3 );     
}

//in an attempt to reduce script variable count, this should be called on drone triggers that are no longer needed
remove_drone_structs(trigger)
{
	wait(20);

	path_starts = GetStructArray(trigger.target, "targetname");

	paths = [];
	for(i = 0; i < path_starts.size; i++)
	{
		j = 0;
		while(IsDefined(path_starts[i]) && IsDefined(path_starts[i].target))
		{
			paths[i][j] = path_starts[i];
			path_starts[i] = GetStruct(path_starts[i].target,"targetname");
			j++;
		}
	}

	for(i = 0; i < paths.size; i++)
	{
		for(j = 0; j < paths[i].size; j++)
		{
			remove_drone_struct(paths[i][j]);
		}
	}

	trigger Delete();
}

remove_drone_struct(struct)
{
	if ( IsDefined( struct.targetname ) )
	{
		if ( IsDefined( level.struct_class_names[ "targetname" ][ struct.targetname ] ) )
		{
			level.struct_class_names[ "targetname" ][ struct.targetname ] = undefined;
		}
	}
	if ( IsDefined( struct.target ) )
	{
		if ( IsDefined( level.struct_class_names[ "target" ][ struct.target ] ) )
		{
			level.struct_class_names[ "target" ][ struct.target ] = undefined;
		}
	}
	if ( IsDefined( struct.script_noteworthy ) )
	{
		if ( IsDefined( level.struct_class_names[ "script_noteworthy" ][ struct.script_noteworthy ] ) )
		{
			level.struct_class_names[ "script_noteworthy" ][ struct.script_noteworthy ] = undefined;
		}
	}
}

//self = player
trace_adjust()
{
	trace_start = self.origin + (0,0,100);
	trace_end = self.origin + (0,0,-100);
	player_trace = BulletTrace(trace_start, trace_end, false, undefined);

	link = Spawn("script_origin", self.origin);
	self PlayerLinkTo(link);

	link moveto(player_trace["position"],0.05);

	link waittill("movedone");

	link Delete();
}

// Enables spotlight without shadowcasting
heli_spotlight_enable( should_enable )
{
	if( IsDefined( self.spotlight ) && !should_enable )
	{
		self.spotlight Delete();
		return;
	}
	else if( IsDefined( self.spotlight ) )
	{
		return;
	}

	self.spotlight = Spawn( "script_model", self GetTagOrigin( "tag_flash_gunner3" ) );
	self.spotlight SetModel( "tag_origin" );
	self.spotlight.angles = self GetTagAngles( "tag_flash_gunner3" );

	self.spotlight LinkTo( self, "tag_flash_gunner3" );
	PlayFXOnTag( level._effect["spotlight"], self.spotlight, "tag_origin" );
}

truck_monitor()
{
	self.health = 20000;

	while( self.health > 18000)
	{
		wait(0.05);
	}

	fire = spawn_a_model("tag_origin", self GetTagOrigin("tag_fx_cab") );
	fire LinkTo(self);

	//start warning fire
	PlayFXOnTag(level._effect["warning_fire"], fire, "tag_origin");

	//start damaging self
	self thread truck_monitor_damage();

	while( self.health > 15000)
	{
		wait(0.05);
	}

	fire Delete();

	playfx(	level._effect["truck_explosion"], self.origin);
	PlayFXOnTag (level._effect["truck_explosion_linked"], self, "tag_origin");
	Earthquake(0.5, 1.5, self.origin, 512);
	PlayRumbleOnPosition("grenade_rumble", self.origin);
	self PlaySound( "evt_truck_explo" );
	level thread play_prisoner_crowd_vox( "vox_vor1_s99_324a_rrd5", "vox_vor1_s99_325a_rrd6", "vox_vor1_s99_326a_rrd7" );
	self notify("death");
}

truck_monitor_damage()
{
	self endon("death");

	while(1)
	{
		wait(1.0);

		self.health -= 200;
	}
}
