//This script is for both events 5 and 6!!

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_music;
#include maps\vorkuta_util;
#include maps\vorkuta;


#using_animtree("generic_human");
minigun_alley_main()
{
	level.player_minigun_max_damage = 10;
	level.player_minigun_invulnurablility_interval = 6 * 1000;
	level.gas_attack_audio = false;
	
	player = get_players()[0];
	player thread player_minigun_proximity_watch();
	player thread turn_off_thread_for_minigun_player_damage_override();
	player.overridePlayerDamage = ::minigun_player_override;
	
	level thread reznov_flags();
	level thread alley_spawn_functions();
	level thread alley_window_explosion();
	//level thread alley_rooftop_guards();

	level thread alley_gas_attack();
	
	flag_wait("player_in_warehouse");

	level thread before_bike_clean_up();
}

before_bike_clean_up()
{
	ai_array = GetAIArray("axis","allies");
	ai_array = array_exclude(ai_array, level.reznov);
	for(j = 0; j < ai_array.size; j++)
	{
		ai_array[j] bloody_death();
		wait(0.1);
	}
}


reznov_flags()
{
	trigger_wait("triggercolor_startinto_alley");
	
	level.reznov thread reznov_runoff();
	
	flag_set("into_alley");
	
	trigger_wait("triggercolor_to_lsection");
	
	flag_set("lsection");
	
	trigger_wait("triggercolor_turn_corner");
	
	flag_set("turn_corner");
	
	trigger_wait("triggercolor_across_road");
	
	flag_set("across_road");
	
	trigger_wait("trigger_last_guy");
	
	flag_set("last_guy");
	
	trigger_wait("triggercolor_end_alley");
	
	flag_set("end_alley");
}


reznov_runoff()
{
	self.grenadeAmmo = 0;
	
	self.ignoreall = true;
	self waittill("goal");
	self.ignoreall = false;
	
	flag_wait("lsection");
	
	self.ignoreall = true;
	self waittill("goal");
	self.ignoreall = false;
	
	flag_wait("turn_corner");
	
	self.ignoreall = true;
	self waittill("goal");
	self.ignoreall = false;
	
	flag_wait("across_road");
	
	self.ignoreall = true;
	self waittill("goal");
	self.ignoreall = false;
	
	flag_wait("last_guy");
	
	self.ignoreall = true;
	self waittill("goal");
	self.ignoreall = false;
	
	flag_wait("end_alley");
	
	self.ignoreall = true;
	self waittill("goal");
	self.ignoreall = false;
	
	flag_wait("gas_attack");

	self.ignoreall = false;
}


// player invulnerablility handler for minigun
turn_off_thread_for_minigun_player_damage_override() // self = player
{
	flag_wait("gas_attack");
	
	self.overridePlayerDamage = undefined;
	self notify("player_minigun_proximity_damage");
	self.disable_invulnerability_thread_running = undefined;
}


minigun_player_override( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
		if( Isdefined( self.player_minigun_proximity_damage ) && self.player_minigun_proximity_damage )
		{
			self.minigun_last_damage_time = GetTime();
			return iDamage;
		}
			
				
		// take damage only if damage has never been taken before, or not taken for a while
		if( !IsDefined( self.minigun_last_damage_time ) 	|| 
		  ( IsDefined( self.minigun_last_damage_time ) && ( GetTime() > self.minigun_last_damage_time + level.player_minigun_invulnurablility_interval ) ) 
		  )
		  {
		  		// if player has enough health to take max damage
		  		if( self.health > level.player_minigun_max_damage )
		  		{
		  			self.minigun_last_damage_time = GetTime();
		  		  					  			
		  			// lower the damage if greater than max damage
		  			if( iDamage > level.player_minigun_max_damage )
		  				return level.player_minigun_max_damage;
		  			else
		  				return iDamage;
		  		}
		  }
		  
		  // if it gets here, then no damage
		  self EnableInvulnerability();
		  self thread disable_invulnerability_over_time( level.player_minigun_invulnurablility_interval / 1000 );
		  return 0;
}

disable_invulnerability_over_time( time ) // self = player
{
	self endon( "player_minigun_proximity_damage" );
	
	if( IsDefined( self.disable_invulnerability_thread_running ) )
		return;

	self.disable_invulnerability_thread_running = 1;
			
	wait( time );
		
	self DisableInvulnerability();
	self.disable_invulnerability_thread_running = undefined;
}

// if player is very close to any enemey then full damage is needed
player_minigun_proximity_watch() // self = player
{
	self endon("death");
		
	self.player_minigun_proximity_damage = false;
	
	while(!flag("gas_attack"))
	{
		 ai = get_closest_ai( self.origin, "axis" );
		 
		 if( IsDefined(ai) && DistanceSquared( ai.origin, self.origin ) < 256 * 256 )
		 {
		 	 self notify("player_minigun_proximity_damage");
		 	 self DisableInvulnerability();
		 	 self.disable_invulnerability_thread_running = undefined;
			 self.player_minigun_proximity_damage = true;
		 }
		 else
		 {
		 	self.player_minigun_proximity_damage = false;
		 }
		 
		 wait(0.5);
	 }
}

alley_window_explosion()
{
	trigger_wait("manager_upper_level");
	
	simple_spawn("window_blowout");
	
	level thread alley_window_blowout();
}


alley_window_blowout()
{
	explosive = getent("explosive_clip", "targetname");
	
	explosive waittill("trigger");
	
	clip = getent("clip_window_blowout", "targetname");
	clip delete();
	
	playsoundatposition( "exp_omaha_window_explode", explosive.origin );
	playfx(	level._effect["truck_explosion"], explosive.origin);
		
	guys = getentarray("window_blowout_ai", "targetname");
	
	for(i=0; i<guys.size; i++)
	{
		if (isdefined(guys[i]))
		{
			guys[i] StartRagdoll(); 
			guys[i] LaunchRagdoll((0, RandomIntRange(-50, 0), RandomIntRange(15, 35)));
		}
	}
	
	level thread play_prisoner_crowd_vox( "vox_vor1_s99_321a_rrd5", "vox_vor1_s99_322a_rrd6", "vox_vor1_s99_323a_rrd7" );
}

alley_spawn_functions()
{
	array_thread( GetEntArray("rpg_bridge", "targetname"), ::add_spawn_function, ::setup_rpg_bridge);
	array_thread( GetEntArray("lower_right_guard", "targetname"), ::add_spawn_function, ::auto_kill);
	array_thread( GetEntArray("alley_building", "targetname"), ::add_spawn_function, ::auto_kill);
	array_thread( GetEntArray("upper_level", "targetname"), ::add_spawn_function, ::auto_kill);
	array_thread( GetEntArray("left_building", "targetname"), ::add_spawn_function, ::auto_kill);
		
	add_spawn_function_veh("alley_truck", ::truck_monitor);
	add_spawn_function_veh("guntruck", ::truck_monitor);
	add_spawn_function_veh("station_alley_truck", ::truck_monitor);
}

setup_rpg_bridge()
{
	self endon("death");
	
	self thread auto_kill();
	
	self.goalradius = 16;
	self.ignoresuppression = true;	
}

alley_rooftop_guards()
{
	trigger_wait("final_pos_trigger");
	
	spawn_manager_enable("manager_last_guy");
	
	flag_wait("gas_attack");
	
	spawn_manager_kill("manager_last_guy");
}

alley_gas_attack()
{
	//player at end of road with tank
	trigger_wait ("final_pos_trigger");

	player = get_players()[0];

	//don't start the animation if the player is already dead
	if(!IsAlive(player))
	{
		return;
	}

	flag_set("gas_attack");

	player EnableInvulnerability();

	//turn off friendly fire for the rest of the level for 
	level.friendlyFireDisabled = 1;
	player SetClientDvar("cg_drawfriendlynames", 0);
	
	start_movie_scene();
	add_scene_line(&"vorkuta_vox_vor1_s1_903A_maso", 2.5, 4.5);			//They used tear gas. I couldn't breathe.
	add_scene_line(&"vorkuta_vox_vor1_s1_904A_inte", 7, 2.5);		//Was Reznov still with you?
	add_scene_line(&"vorkuta_vox_vor1_s1_906A_maso", 10, 2);		//He never left me.

	level.movie_trans_in = "black";
	level.movie_trans_out = "black";
	level thread play_movie("mid_vorkuta_2", false, false, "start_movie", true, "end_movie", .5);

	level.gas_attack_audio = true;

	gas1 = getent("pos_gas1", "targetname");
	gas2 = getent("pos_gas2", "targetname");

	gas1 MagicGrenadeType("willy_pete_sp", GetEnt("final_pos_trigger","targetname").origin, (0, 0, 0), 1.0);
	gas1 PlaySound( "wpn_smoke_grenade_explode" );
	wait(0.2);
	gas1 PlaySound( "wpn_smoke_grenade_explode" );
	gas1 MagicGrenadeType("willy_pete_sp", gas1.origin, (-475, 320, 160), 1.0);
	wait(0.4);
	gas2 PlaySound( "wpn_smoke_grenade_explode" );
	gas2 MagicGrenadeType("willy_pete_sp", gas2.origin, (-525, -50, 160), 1.0);
		
	//TUEY Set music state to TEAR GAS
	setmusicstate("TEAR_GAS");
	
	level thread gas_attack_audio();

	wait(1);
	
	//-- GLocke: Set Dvar used during movie playback
	SetSavedDvar("r_streamFreezeState", 1);
	
	player ShellShock("vorkuta_gas", 18);
	player SetClientDvar( "compass", 0 );
	Earthquake(0.5, 3, player.origin, 100);
	player PlayRumbleOnEntity("grenade_rumble");

	location = GetStruct("player_gassed_origin", "targetname");

	angle_curr = AbsAngleClamp180(player.angles[1]);
	move_time = linear_map(angle_curr, 0, 180, 0.05, 1.0);

	level thread alley_prisoner_gas_attack(player);

	player lerp_player_view_to_position(location.origin, location.angles, move_time, 1.0);
	player DisableWeapons();
	player FreezeControls(true);
	
	player_body = spawn_anim_model( "player_body" );
	player_body Hide();
	player_body.angles = player GetPlayerAngles();
	player_body.origin = player.origin;

	player PlayerLinkToAbsolute(player_body,"tag_player");
	
	actors[0] = level.reznov;
	actors[1] = player_body;

	player thread anim_single_aligned(actors, "player_gassed");
	wait(0.5);
	player_body Show();

	//set on a notetrack in the player animation
	flag_wait("flag_player_gas_fade");

	////////////
	//MOVIE//
	///////////

	level notify("start_movie");
	wait(2);

	player Unlink();
	player_body Delete();

	//turn off minigun FX and turn on warehouse
	stop_exploder(1900);
	exploder(2000);

	//move player into warehouse
	location = GetEnt ("player_in_warehouse", "targetname");
	player lerp_player_view_to_position(location.origin, location.angles, .2, 1);

	level waittill("end_movie");
	
	//-- GLocke: Reset Dvar used during movie playback
	SetSavedDvar("r_streamFreezeState", 0);

	flag_set ("player_in_warehouse");
	level clientnotify( "ead" );
	
	////////////
	//WAREHOUSE//
	////////////
		
	//autosave_by_name ("bike_start");
		
	player FreezeControls(false);
	player DisableInvulnerability();
}

alley_prisoner_gas_attack(player)
{
	choke_ai = get_array_of_closest(player.origin, GetAIArray("allies"));
	
	for(i = 0; i < choke_ai.size; i++)
	{
		if(choke_ai[i] != level.reznov)
		{	
			choke_ai[i] thread alley_prisoner_choke();
		}	
	}
}

alley_prisoner_choke()
{
	self endon("death");

	wait( RandomFloatRange(1.0,3.0) );
	self anim_generic(self, "gas_choke");
	self ragdoll_death();
}

//self = enemy ai
auto_kill()
{
	self endon("death");

	player = get_players()[0];

	//stay alive as long as the enemy is further ahead than the player
	while(self.origin[0] > player.origin[0] + RandomIntRange(200,300) )
	{
		wait(0.05);
	}

	self bloody_death();
}

gas_attack_audio()
{
    player = get_players()[0];
    
    wait(2);
    
    clientnotify( "gas" );
    player PlayLoopSound( "vox_mason_coughing_loop" );
    flag_wait( "flag_player_gas_fade" );
    player StopLoopSound( 1 );
    wait(1.25);
    player PlaySound( "vox_mason_gas_recover" );
    flag_wait( "player_in_warehouse" );
    clientnotify( "egs" );
}

play_truck_driving_audio()
{
    self endon( "death" );
    self endon( "alley_truck_destroyed" );
    self endon( "guntruck_destroyed" );
    
    front = self GetTagOrigin( "tag_engine_left" );
    sound_ent = Spawn( "script_origin", front );
    sound_ent LinkTo( self, "tag_engine_left" );
    sound_ent PlayLoopSound( "veh_truck_front_courtyard_special" );
    self thread delete_truck_sound_ent( sound_ent );
    self waittill( "truck_stopped" );
    sound_ent StopLoopSound( .25 );
    playsoundatposition( "veh_truck_stop", sound_ent.origin );
    wait(3);
    sound_ent Delete();
}

delete_truck_sound_ent( ent )
{
    self endon( "truck_stopped" );
    
    self waittill_any( "death", "alley_truck_destroyed", "guntruck_destroyed" );
    ent Delete();
}