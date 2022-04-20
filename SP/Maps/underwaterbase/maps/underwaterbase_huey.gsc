/*
//-- Level: Underwater Base Huey
//-- Level Designer: Gavin Goslin
//-- Scripter: Alfeche/Vento
*/

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\_anim;
#include maps\underwaterbase_util;
#include maps\_vehicle_turret_ai;
#include maps\_vehicle;
#include maps\_music;


#using_animtree ("player");
start( heli_start_angles )
{	
	flag_wait( "all_players_connected" );
	
	SetSavedDvar("sv_maxPhysExplosionSpheres", 15);	// Limit max number of ET_PHYS_EXPLOSION_SPHERES concurrently active to 15.  Should help to stop us running out of ents.  DSL
		
	level.huey = spawn_vehicle_from_targetname("flyable_huey");
	AssertEx( IsDefined(level.huey), "THE HUEY IS NOT DEFINED AND THE LEVEL JUST BROKE!");
		
	if(isDefined(heli_start_angles))
	{
		level.huey.angles = heli_start_angles;	
	}
	
	player = get_player();
	level.huey usevehicle(player, 0);
	level.huey MakeVehicleUnusable();

	// initialize player settings while in the Huey
	level thread init_player();

	// init huey
	level.huey init_huey();

	// init huey flight dvars and settings
	level.huey init_huey_flight_dvars_flying();	
	
	// allows height adjustments based on heli patch
	level.huey.lockheliheight = true;
	level.huey.player_controlled_heli = true;
	
	//level.huey.tut_hud["gun_controls"] = true;

	level.huey thread start_hands_flightstick();
	
	wait(0.05);
	level clientNotify ("in_chopper");
	
	//TUEY set music to INTRO_CHOPPER_FIGHT
	setmusicstate ("INTRO_CHOPPER_FIGHT");
}

init_player()
{
	flag_wait("starting final intro screen fadeout");

	player = get_player();
	
	// hide player hud elements
	player SetClientDvar( "compass", "0" );
	player SetClientDvar( "hud_showstance", "0" );
	player SetClientDvar( "actionSlotsHide", "1" );
	player SetClientDvar( "ammoCounterHide", "1" );
	
	// take away player control to start with
//	player FreezeControls(true);
	player DisableWeapons();
	player AllowADS(false);
}

init_huey()	//-- self == huey helicopter
{	
	//-- huey setup		
	self heli_toggle_rotor_fx(1); //-- turn the rotor back on, takes about 8 seconds.

//	self MakeVehicleUnusable(); //-- made usable once the Spetsnaz have been killed
	
//	self thread create_sam_target();

	self.missiles_incoming = [];
		
	self init_huey_player_dvars();
	//self maps\_huey_player::disable_driver_weapons();

	player = get_players()[0];
	player.flying_huey = true;
	OnSaveRestored_Callback( ::huey_save_restore );
	self thread huey_damage_think();
	
	target_point = self getgunnertargetvec( 0 );
	self setgunnertargetvec( target_point, 1 );

	// disable the player from firing miniguns at start (get re-enabled in introigc)
	self DisableGunnerFiring(0, true);	// disable the right mini gun from firing
	self DisableGunnerFiring(1, true);	// disable the left mini gun from firing

	self.damage_mod = GetEnt("fxanim_gp_huey_int_dmg_mod", "targetname");
	self.damage_mod.origin = self GetTagOrigin("tag_body");
	self.damage_mod.angles = self GetTagAngles("tag_body");
	self.damage_mod LinkTo(self, "tag_body");
	self.damage_mod DisableClientLinkTo();
	self.damage_mod thread maps\underwaterbase_fx::huey_int();

	self.necklace_mod = GetEnt("fxanim_gp_huey_uwb_necklace_mod", "targetname");
	self.necklace_mod.origin = self GetTagOrigin("tag_body");
	self.necklace_mod.angles = self GetTagAngles("tag_body");
	self.necklace_mod LinkTo(self, "tag_body");
	self.necklace_mod DisableClientLinkTo();
	self.necklace_mod thread maps\underwaterbase_fx::huey_int_necklace();

	self thread huey_do_very_damaged_feedback();
}

huey_save_restore()
{
	player = get_players()[0];
	
	if( IsDefined(player.flying_huey) && player.flying_huey )
	{
		player EnableInvulnerability();
		level.huey.current_damage = 0;
		level.huey.health = 99999;

		//// test save restore
		//start_node = GetVehicleNode("player_airsupport_deck_restore", "targetname");
		//level.huey thread go_path(start_node);
		//player SetPlayerAngles(level.huey GetTagAngles("tag_driver"));
		//level.huey waittill("reached_end_node");
		//level.huey unlink();
		//level.huey ReturnPlayerControl();	

		if (IsDefined(level.deck_support) && level.deck_support)
		{
			SetHeliHeightPatchEnabled("airsupport_clip_deck", 1);
			SetHeliHeightPatchEnabled("default_heli_clip", 0);
		}

		// hack of the year...
		angles = level.huey.angles;
		level thread slam_player_after_restart(angles);
	}
}

slam_player_after_restart(angles)
{
	player = get_players()[0];
	for (i = 0; i < 10; i++)
	{
		player SetPlayerAngles(angles);
		wait(0.05);
	}
}

init_huey_weapons()
{
	self DisableGunnerFiring(0, false);	// enable the right mini gun from firing
	self DisableGunnerFiring(1, false);	// enable the left mini gun from firing

	// setup huey miniguns
	self thread player_heli_fire();
	self thread huey_rocket_launcher();
	
	// setup miniguns overheating thread
	self thread miniguns_overheating();

	player = get_players()[0];
	player thread huey_ads_toggle();
}

init_huey_player_dvars()
{
	flag_wait("starting final intro screen fadeout");

	//-- generic dvars that always apply to the helicopter
	player = get_player();
	
	player SetClientDvar("vehHelicopterMaxSpeedVertical", 100);
		
	//-- this is for the intial takeoff (change the vars once we have it setup for the clearing old value was 75)
	player SetClientDvar("vehHelicopterMaxAccelVertical", 50); 
	player SetClientDvar("cg_tracerSpeed", 20000);

	player SetPlayerAngles(self GetTagAngles("tag_driver"));
		
	//-- huey Control Tweaks	
	SetDvar("vehHelicopterTiltFromFwdandYaw", 3);
	SetDvar("vehHelicopterDefaultPitch", 2);
//	player SetClientDvar("vehHelicopterTiltFromViewangles", 5);

//	self SetDefaultPitch(10);

	//-- Physics Vehicle Dvar
	player SetClientDvar("dynEnt_bulletForce", 400);
	
	//-- Idle Hover
	self SetJitterParams( (5,0,5), 0.5, 1.0 );

	// draw vertical heat
	SetSavedDvar("cg_drawWeaponHeatVertical", true);
}

heli_pitch_align(node, min_pitch, max_pitch, min_height, max_height)
{
	self endon("stop_pitch_align");

	align_node = undefined;
	if (IsString(node))
	{
		align_node = GetStruct(node, "targetname");
	}
	else
	{
		align_node = node;
	}

	while (true)
	{
		delta = self.origin - align_node.origin;

		pitch = linear_map(delta[2], min_height, max_height, min_pitch, max_pitch);

//		IPrintLnBold("Pitch: " + pitch + "Delta: " + delta[2]);

		self SetDefaultPitch(pitch);

		wait(0.05);
	}
}

player_heli_fire()
{
	self endon("death");
	self endon("disconnect");
	self endon("end_player_heli");
	self thread player_turret_audio();
	
	player = get_player();
	while( true )
	{
		weapon_overheating = player isWeaponOverheating();
		if (!weapon_overheating && player AttackButtonPressed())
		{
			self FireGunnerWeapon( 1 );
		}
		
		target_point = self getgunnertargetvec( 0 );
		self setgunnertargetvec( target_point, 1 );

		wait( 0.05 );
	}	
}
player_turret_audio()
{
	level endon( "stop_turret_audio" );
	player = get_player();
	self thread turret_audio_failsafe( player );
	
	while( true )
	{
		weapon_overheating = player isWeaponOverheating();
		while(weapon_overheating || !player AttackButtonPressed())
		{
			weapon_overheating = player isWeaponOverheating();
			wait( 0.05 );
		}
		if( player AttackButtonPressed() )
		{
			player playsound( "wpn_huey_pilot_start_plr" );
		}
		while(!weapon_overheating && player AttackButtonPressed())
		{
			weapon_overheating = player isWeaponOverheating();
			player playloopsound( "wpn_huey_pilot_fire_loop_plr" );
			wait( 0.05 );
		}
		player stoploopsound();
		player playsound( "wpn_huey_pilot_stop_plr" );
	}
	
}
turret_audio_failsafe( player )
{
	self waittill_any( "death" , "disconnect" , "end_player_heli" );
	level notify( "stop_turret_audio" );
	if( player AttackButtonPressed() )
	{
		player stoploopsound();
		player playsound( "wpn_huey_pilot_stop_plr" );
		
	}
}

miniguns_overheating() // sets up the weapon and ads/zoom hud along with weapon overheating
{
	self endon( "death" );
	self endon( "end_player_heli" );

	self thread miniguns_cleanup();

	player = get_player();

	gun_align_X = "right";
	gun_horizAlign = "user_right";
	gun_icon_x = -36;
	gun_icon_y = -36;
	gun_btn_x = -58;
	gun_btn_y = -16;
	gun_text_x = -14;
	gun_text_y = -16;

	rocket_align_x = "left";
	rocket_horizAlign = "user_leftt";
	rocket_icon_x = 15;
	rocket_icon_y = -8;
	rocket_btn_x = 13;
	rocket_btn_y = -14;
	rocket_text_x = 52;
	rocket_text_y = -14;
	
	if(level.console) 
	{		
		if(level.PS3) 
		{
			gun_btn_y += 10;
			gun_text_x -= 2;
			gun_text_y -= 2;
			rocket_btn_x -= 2;
			rocket_btn_y += 7;
			rocket_text_x -= 2;
			rocket_text_y -= 5;
		}
	}
	else
	{
		gun_btn_x = -210;
		gun_btn_y = -10;
		gun_text_x = -193;
		gun_text_y = -25;
		gun_align_x = "center";
		gun_horizAlign = "user_right";
	
		rocket_btn_x = -130;
		rocket_btn_y = -10;
		rocket_text_x = -118;
		rocket_text_y = -25;
		rocket_icon_x = -130;
		rocket_icon_y = -23;
		rocket_align_x = "center";
		rocket_horizAlign = "user_right";
	}	

	// gun icon
	//self.weapon_icon = maps\underwaterbase_util::create_hud_elem( player, gun_icon_x, gun_icon_y, "hud_hind_minigun", 1.0, 64, 64 );

	// gun button
	self.weapon_button = maps\underwaterbase_util::create_hud_elem( player, gun_btn_x, gun_btn_y, undefined, undefined, undefined, undefined, gun_align_x, "bottom", gun_horizAlign, "user_bottom" );
	self.weapon_button SetText("^3[{+attack}]^7");
	if( level.ps3 )
	{
		self.weapon_button.fontScale = 2.5;
	}
	
	// gun text
	self.weapon_number = maps\underwaterbase_util::create_hud_elem( player, gun_text_x, gun_text_y, undefined, undefined, undefined, undefined, gun_align_x, "bottom", gun_horizAlign, "user_bottom");
	self.weapon_number SetText("x 2");

	// Rocket icon
	self.rocket_icon = maps\underwaterbase_util::create_hud_elem( player, rocket_icon_x, rocket_icon_y, "hud_hind_rocket", 1.0, 48, 48, rocket_align_x, "bottom", rocket_horizAlign, "user_bottom" );

	// Rocket Button
	self.rocket_button = maps\underwaterbase_util::create_hud_elem( player, rocket_btn_x, rocket_btn_y, undefined, undefined, undefined, undefined, rocket_align_x, "bottom", rocket_horizAlign, "user_bottom" );
	self.rocket_button SetText("^3[{+speed_throw}]^7");
	if( level.ps3 )
	{
		self.rocket_button.fontScale = 2.5;
	}

	// Rocket Number
	self.rocket_number = maps\underwaterbase_util::create_hud_elem( player, rocket_text_x, rocket_text_y, undefined, undefined, undefined, undefined, rocket_align_x, "bottom", rocket_horizAlign, "user_bottom" );
	self.rocket_number SetText("x 2");

	while ( 1 )
	{
		player = get_player();

		weapon_overheating = player isWeaponOverheating();
		
//		if( player attackbuttonPressed() )
//		{
//			if( !weapon_overheating )
//			{
//				Earthquake( 0.15, 0.2, player.origin, (42*2)*10 );
//			}
//		}
		
		// Get the over heat value (0 to 100)
		overheat_val = player isWeaponOverheating(1);
		if( overheat_val < 0 )
		{
			overheat_val = 0;
		}
		else if ( overheat_val > 100 )
		{
			overheat_val = 100;
		}

		self SetHealthPercent(overheat_val / 100);
		
		wait( 0.05 );
	}
}

miniguns_cleanup()
{
	level waittill("end_player_heli");

	// remove hud elements
	//self.weapon_icon maps\underwaterbase_util::destroy_hud_elem();
	self.weapon_button maps\underwaterbase_util::destroy_hud_elem();
	self.weapon_number maps\underwaterbase_util::destroy_hud_elem();
	self.rocket_icon maps\underwaterbase_util::destroy_hud_elem();
	self.rocket_button maps\underwaterbase_util::destroy_hud_elem();
	self.rocket_number maps\underwaterbase_util::destroy_hud_elem();
	//self.overheat_bar maps\underwaterbase_util::destroy_hud_elem();
}

huey_rocket_launcher()
{
	self endon("death");
	self endon("disconnect");
	self endon("end_player_heli");

	fire_timer = 0.0;

	player = get_players()[0];
	while (true)
	{
		if (player throwButtonPressed() && fire_timer <= 0.0)
		{
			EarthQuake(0.25, 1.0, self.origin, 512);
			player PlayRumbleOnEntity( "damage_heavy" );

//			rocket_r_pos = self GetGunnerTargetVec(0);
//			rocket_l_pos = self GetGunnerTargetVec(1);

			tag_rocket_r = self GetTagOrigin("tag_rocket_right") - (0,0,64);
			tag_rocket_l = self GetTagOrigin("tag_rocket_left") - (0,0,64);

			angles = player GetPlayerAngles();
			pitch = angles[0];

			if (pitch > 300)
			{
				pitch -= 360;
			}

//			Iprintln("pitch: " + pitch);

			if (pitch < -25)
			{
				angles = (-25, angles[1], angles[2]);
			}
			else if (pitch > 35)
			{
				angles = (35, angles[1], angles[2]);
			}

			dir = AnglesToForward(angles);
			aim_pos = get_player_aim_pos(20000);

			rocket_r_pos = tag_rocket_r + dir * 10000;
			rocket_l_pos = tag_rocket_l + dir * 10000;

			rocket1 = MagicBullet("hind_rockets_sp_player_uwb", tag_rocket_r, aim_pos);
			rocket2 = MagicBullet("hind_rockets_sp_player_uwb", tag_rocket_l, aim_pos);

			rocket1 thread rocket_kills();
			rocket2 thread rocket_kills();

			fire_timer = 1.0;
		}

		fire_timer -= 0.05;
		if (fire_timer < 0.0)
		{
			fire_timer = 0.0;
		}
		//IPrintLnBold("Fire Timer: " + fire_timer);

		wait(0.05);
	}
}

rocket_kills()
{
	KILL_DIST_SQ = 300 * 300;

	self waittill("death");
	if (IsDefined(self) && IsDefined(self.origin))
	{
		impact_origin = self.origin;

		axis = GetAIArray("axis");
		for (i = 0; i < axis.size; i++)
		{
			if (IsAlive(axis[i]))
			{
				if ((DistanceSquared(axis[i].origin, impact_origin) <= KILL_DIST_SQ)
					&& abs(axis[i].origin[2] - impact_origin[2]) < 150)
				{
					axis[i] DoDamage(10000, impact_origin, get_players()[0], -1, "explosive");
				}
			}
		}
	}
}

invincible_huey() // we never want the huey itself to die
{	
	self endon("end_player_heli");
	
	while(IsAlive(self))
	{
		self waittill("damage", amount);
		self.health += amount;		
	}
	
	AssertEx( true, "Something broke and the invincible huey died");
}

init_huey_flight_dvars_flying() //-- self == huey helicopter
{
	players = get_players();
	for( i=0; i < players.size; i++ )
	{
		//--  huey Movement Tweaks
		players[i] SetClientDvar("vehHelicopterMaxSpeedVertical", 30);
		players[i] SetClientDvar("vehHelicopterMaxAccelVertical", 60); //-- this is for the intial takeoff (change the vars once we have it setup for the clearing old value was 75)
	}
	
	//-- huey Control Tweaks	
	SetDvar("vehHelicopterTiltFromFwdandYaw", 3);
	SetDvar("vehHelicopterDefaultPitch", 2);
	
	//-- Idle Hover
	self SetJitterParams( (5,0,5), 0.5, 1.0 );
}

huey_damage_think() //-- self == player huey
{
	self SetCanDamage(true);

	self thread huey_damage_player();
	//self thread huey_damage_cockpit_swap();	// JMA TODO - find huey equivalent
	self thread huey_damage_health_watch();	// JMA TODO - find huey equivalent

	player = get_players()[0];
	player.overridePlayerDamage = ::huey_health_take_damage;
}

//-- damages the player based on the damage that the huey itself has recieved
huey_damage_player() //self == player huey
{	
	level.disable_damage_overlay_in_vehicle = true; //-- gets rid of the blood fx on the screen
	level thread reset_disable_damage_overlay_on_notify( "player_lands_huey" );
	
	self endon("death");
	level endon("player_lands_huey");
	level endon("enemy_hind_dead");
	
	bullet_hits = 0;
		
	// hits per damage done and damage values against player
	enemy_hind_ratio = 1;
	enemy_hind_damage = 100;
	enemy_hip_ratio = 1;
	enemy_hip_damage = 5;
	enemy_zpu_ratio = 2;
	enemy_zpu_damage = 5;
	enemy_sam_samage = 10;
	enemy_sam_ratio = 1;
	enemy_ai_ratio = 2;
	enemy_ai_damage = 5;
	
	//TODO: this is temp until we figure out exactly what is going on here
	player = get_players()[0];
	player EnableInvulnerability();
	
	//demo
	
	/*
	if(IsDefined(level.pow_demo) && level.pow_demo)
	{
		return;
	}
	*/
	
	while(1)
	{
		//-- TODO: track damage types because eventually that will be important	
		self waittill("damage", dmg_amount, attacker, dir, pos, type);
		
		do_player_damage = false;
		
		if(IsDefined(attacker))
		{
			player = get_players()[0];
			
			if(attacker.classname == "script_vehicle")
			{
				bullet_hit_mod = 999999;
				vehicle_damage = 0;
				
				if(attacker.vehicletype == "heli_hind" || attacker.vehicletype == "heli_hind_doublesize" || attacker.vehicletype == "heli_hind_doublesize_uwb")
				{
					bullet_hit_mod = enemy_hind_ratio;
					vehicle_damage = enemy_hind_damage;
				}
				if(attacker.vehicletype == "heli_hip" || attacker.vehicletype == "heli_hip_sidegun")
				{
					bullet_hit_mod = enemy_hip_ratio;
					vehicle_damage = enemy_hip_damage;
				}
				else if(attacker.vehicletype == "wpn_zpu_antiair")
				{
					bullet_hit_mod = enemy_zpu_ratio;
					vehicle_damage = enemy_zpu_damage;
				}
				if(bullet_hits % bullet_hit_mod == 0)
				{
					//player DoDamage( vehicle_damage, attacker.origin, self ); 
					bullet_hits = 0;
					do_player_damage = true;
				}
			}
			else if((bullet_hits % enemy_ai_ratio == 0) || type == "MOD_PROJECTILE") // - attacker is an AI
			{
				bullet_hits = 0;
				do_player_damage = true;
			}
			
			if( do_player_damage )
			{
				player DisableInvulnerability();
				player.health = player.maxHealth;
				player DoDamage( enemy_ai_damage, attacker.origin, self );
				bullet_hits = 0;
				self notify("player_damage_through_huey");
				wait(0.05);
				player EnableInvulnerability();

				level thread play_player_damaged_vo();
			}
			wait(0.05);
		}
		
		bullet_hits++;
	}
}

huey_health_take_damage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	if (IsDefined(self.flying_huey) && self.flying_huey)
	{
		if (sWeapon == "hind_rockets_sp_uwb" || sWeapon == "huey_side_minigun_uwb" || sWeapon == "hind_minigun_enemy_pilot")
		{
			iDamage = 0;
		}
	}

	return iDamage;
}

//-- Watches the health of the hind and sends out notifies to the other parts of the system
//-- TODO: This also needs to play the damage fx
huey_damage_health_watch() //-- self == player huey
{
	self endon("death");

	self.base_dmg_thresholds = array( 250, 500, 750, 1000);
	self.dmg_thresholds = array( 250, 500, 750, 1000);
	self.dmg_taken_max = 1000;

	scale = 1.0;
	skill = GetDifficulty();
	if (skill == "hard")
	{
		scale = 0.75;
	}
	else if (skill == "fu")
	{
		scale = 0.65;
	}

	for (i = 0; i < self.dmg_thresholds.size; i++)
	{
		self.dmg_thresholds[i] *= scale;
	}

	self.dmg_taken_max *= scale;

	self.current_damage = 0;
	self.alarm_sound_threshhold = self.dmg_taken_max / 2;

	self.playing_alarm_loop = false;
	self.alarm_snd_ent = Spawn( "script_origin", self.origin );
	self.alarm_snd_ent LinkTo( self );

	max_dmg_states = 4;
	
	total_dmg_taken = 0;
	current_threshold = 0;
	
	self.enemy_hind_damage = 25;
	self.enemy_hip_damage = 100;
	self.enemy_zpu_damage = 10;
	self.enemy_sam_damage = 10;
	self.enemy_ai_damage = 1;
	self.enemy_rocket_damage = 10;

	if (skill == "hard")
	{
		self.enemy_ai_damage = 5;
		self.enemy_rocket_damage = 25;
	}
	else if (skill == "fu")
	{
		self.enemy_ai_damage = 10;
		self.enemy_rocket_damage = 50;
	}

	self thread huey_difficulty_watcher();
	
//	flag_wait("heavy_resistance_encountered");

	self thread huey_cockpit_interior_damage();
	self thread huey_damage_cockpit_fx_based_on_health();

	//TODO: take this out eventually
	player = get_players()[0];

	while(IsAlive(self))
	{
		self waittill("damage", amount, attacker, dir, pos, type);
		self.health += amount;
		//IPrintLn("Health: " + self.health);
	
		if( IsGodMode( player ) )
		{
			continue;
		}
		
		total_dmg_taken = self.current_damage;

		if(IsDefined(attacker) && IsDefined(attacker.classname) && attacker.classname == "script_vehicle")
		{
			if(attacker.vehicletype == "heli_hind" || attacker.vehicletype == "heli_hind_doublesize" || attacker.vehicletype == "heli_hind_doublesize_uwb")
			{
				total_dmg_taken += self.enemy_hind_damage;
			}
			else if(attacker.vehicletype == "heli_hip" || attacker.vehicletype == "heli_hip_sidegun")
			{
				total_dmg_taken += self.enemy_hip_damage;
			}
			else if(attacker.vehicletype == "wpn_zpu_antiair")
			{
				total_dmg_taken += self.enemy_zpu_damage;
			}
			else if(attacker.vehicletype == "wpn_bm21_sam_launcher")
			{
				total_dmg_taken += self.enemy_sam_damage;
			}
		}
		else
		{
			if (type == "MOD_PROJECTILE" || type == "MOD_EXPLOSIVE")
			{
				total_dmg_taken += self.enemy_rocket_damage;
			}
			else
			{
				total_dmg_taken += self.enemy_ai_damage;
			}
		}
		
		if(total_dmg_taken > self.dmg_thresholds[current_threshold])
		{
			current_threshold++;
			if(current_threshold >= max_dmg_states || total_dmg_taken > self.dmg_taken_max) //-- 2nd check is for SAM missiles
			{
				self.current_damage = total_dmg_taken; //-- so we can make sure that the damage states update
				break;
			}

			self notify("damage_state");
			self notify("next_dmg_fx");
		}
		if( !self.playing_alarm_loop && total_dmg_taken > self.alarm_sound_threshhold )
		{
			self.playing_alarm_loop = true;
			self.alarm_snd_ent PlayLoopSound( "veh_hind_alarm_damage_high_loop" );
		}
		else if( self.playing_alarm_loop && self.current_damage < self.alarm_sound_threshhold )
		{
			self.playing_alarm_loop = false;
			self.alarm_snd_ent StopLoopSound();
		}

		self.current_damage = total_dmg_taken;
		//IprintLn("Damage: " + self.current_damage);
		self thread huey_regen_health();
	}
	
	/*
	if(IsDefined(level.pow_demo) && level.pow_demo)
	{
		return;
	}
	*/
	
//	while(self maps\_hind_player::next_cockpit_damage_state()) //-- make sure we are on the last damage state
//	{
//		wait(0.05);
//	}
	
	self notify("end_player_heli");
	level notify("end_player_heli");

	level thread fade_out(3.0, "black");
	self thread player_helicopter_crashing_anims();
	player = get_players()[0];
	PlayFX(level._effect["player_explo"], player.origin);
	level thread flame_overlay();
	missionFailedWrapper();
}

huey_difficulty_watcher()
{
	self endon("death");

	start_skill = GetDifficulty();

	while (1)
	{
		current_skill = GetDifficulty();

		if (start_skill != current_skill)
		{
			self.dmg_thresholds = array( 250, 500, 750, 1000);
			self.dmg_taken_max = 1000;

			scale = 1.0;
			if (current_skill == "hard")
			{
				scale = 0.75;
			}
			else if (current_skill == "fu")
			{
				scale = 0.65;
			}

			for (i = 0; i < self.dmg_thresholds.size; i++)
			{
				self.dmg_thresholds[i] *= scale;
			}

			self.dmg_taken_max *= scale;

			self.enemy_hind_damage = 25;
			self.enemy_hip_damage = 100;
			self.enemy_zpu_damage = 10;
			self.enemy_sam_damage = 10;
			self.enemy_ai_damage = 1;
			self.enemy_rocket_damage = 10;

			if (current_skill == "hard")
			{
				self.enemy_ai_damage = 5;
				self.enemy_rocket_damage = 25;
			}
			else if (current_skill == "fu")
			{
				self.enemy_ai_damage = 10;
				self.enemy_rocket_damage = 50;
			}

			start_skill = current_skill;
		}

		wait(0.05);
	}
}

flame_overlay()
{
	player = get_players()[0];
	player SetBurn(3);
}

//TODO: this is going to need a lot of tuning
huey_regen_health() // self == hind
{
	self endon("damage");
	self endon("death");
	
	wait(3); //-- wait for 3 seconds before regen starts
	
	while(1)
	{
		self.current_damage = self.current_damage - 3;
		wait(0.1);
		
		if(self.current_damage < 0)
		{
			self.current_damage = 0;
			return;
		}
	}
}

start_hands_flightstick() //-- self = hind
{		
	self endon( "death" );
		
	self.player_body = spawn_anim_model("player_body", (0,0,0), (0,0,0));
	self.player_body.animname = "player_body";
	
	player = get_players()[0];
	
//	origin_offset = ( 157, -1, -172 );
	origin_offset = ( 10, 0, -10 );
//	link_loc = self.origin + origin_offset;
	self.player_body LinkTo( self, "tag_driver", origin_offset, ( 0, 0, 0 ) );	
	self.player_body Attach( "t5_veh_helo_hind_cockpit_control", "tag_weapon" );
	
//	self UseBy(player);
//	player SetClientDvar( "cg_crosshairAlpha", 0.7 );
	
	self.player_body thread hands_flightstick_animator_think( self );
	self waittill("stop_flightstick");
	self.player_body thread stop_flightstick_animator();
}

stop_flightstick_animator()
{
	self clear_flightstick_animations();
	//self SetAnim(level.scr_anim["player_body"]["flightstick_handsoff"], 0.15);
}

clear_flightstick_animations()
{
	self ClearAnim(level.scr_anim["player_body"]["flightstick_right"], 0.15);
	self ClearAnim(level.scr_anim["player_body"]["flightstick_left"], 0.15);
	self ClearAnim(level.scr_anim["player_body"]["flightstick_away"], 0.15);
	self ClearAnim(level.scr_anim["player_body"]["flightstick_towards"], 0.15);
	self ClearAnim(level.scr_anim["player_body"]["flightstick_neutral"], 0.15);
}

hands_flightstick_animator_think( helicopter )
{
	player = get_players()[0];
	helicopter endon("stop_flightstick");
	
	while(1)
	{		
		player_leftstick_x = player GetNormalizedMovement()[1];
		player_leftstick_y = player GetNormalizedMovement()[0];

		self hands_flightstick_animator( player_leftstick_x, player_leftstick_y );

		wait(0.05);
	}	
}


hands_flightstick_animator( player_leftstick_x, player_leftstick_y )
{
	player_leftstick = [];
	player_leftstick[0] = player_leftstick_x;
	player_leftstick[1] = player_leftstick_y;
	
	weights = set_flightstick_weights( player_leftstick_x, player_leftstick_y );
			
	self SetAnim(level.scr_anim["player_body"]["flightstick_right"], weights[0], 0.25, 1 );
	self SetAnim(level.scr_anim["player_body"]["flightstick_left"], weights[1], 0.25, 1 );
	self SetAnim(level.scr_anim["player_body"]["flightstick_away"], weights[2], 0.25, 1 );
	self SetAnim(level.scr_anim["player_body"]["flightstick_towards"], weights[3], 0.25, 1 );
	self SetAnim(level.scr_anim["player_body"]["flightstick_neutral"], weights[4], 0.35, 1 );
}

// Sets the blend weights for the hand flightstick anims based on joystick input.
set_flightstick_weights( player_leftstick_x, player_leftstick_y )
{	
	weights = [];
	movement_floor = 0.015;
	// Set the goal weights
	for( i = 0; i < 5; i++ )
	{
		weights[i] = 0;
	}
	
	if( player_leftstick_x < movement_floor && player_leftstick_x > (-1 * movement_floor) 
		&& player_leftstick_y < movement_floor && player_leftstick_y > (-1 * movement_floor) )
	{
		weights[4] = 1;	
		return weights;
	}	
	
	if( player_leftstick_x >= movement_floor )
	{
		weights[0] = player_leftstick_x;
		weights[1] = 0;
	}
	else
	{
		weights[0] = 0;
		weights[1] = abs(player_leftstick_x);
	}
	
	if( player_leftstick_y >= movement_floor )
	{
		weights[2] = player_leftstick_y;
		weights[3] = 0;
	}
	else
	{
		weights[2] = 0;
		weights[3] = abs(player_leftstick_y);
	}	
		
	return weights;	
}

#using_animtree ("generic_human");

player_helicopter_crashing_anims() //-- self == the player's hind
{
	//-- animate Woods crash
//	level.barnes notify("barnes_change_behavior");
//	level.barnes barnes_clear_all_anims( 0.15);
//	level.barnes SetAnim( level.scr_anim["barnes"]["crash"], 1 );
	
	self thread player_helicopter_player_crashing_anims();
}

#using_animtree ("player");

player_helicopter_player_crashing_anims()
{
	self notify("stop_flightstick");
	self.player_body clear_flightstick_animations();
	self.player_body SetAnim( level.scr_anim["player_body"]["crash"], 1 );

}

heli_attack_drone_targets( current_array, enemy_team_name )
{	
	if(isDefined(level.drones))
	{
		if(isDefined(level.drones[enemy_team_name].array) && level.drones[enemy_team_name].array.size > 0 )
		{
			for(i=0; i<level.drones[enemy_team_name].array.size; i++)
			{
				current_array = array_add(current_array, level.drones[enemy_team_name].array[i]);
			}
		}
	}
	
	return current_array;
}

reset_disable_damage_overlay_on_notify( notify_msg )
{
	level waittill(notify_msg);
	level.disable_damage_overlay_in_vehicle = undefined;	
}

huey_death_fade_out( time )
{
	if( !isdefined( level.fade_out_overlay ) )
	{
		level.fade_out_overlay = NewHudElem();
		level.fade_out_overlay.x = 0;
		level.fade_out_overlay.y = 0;
		level.fade_out_overlay.horzAlign = "fullscreen";
		level.fade_out_overlay.vertAlign = "fullscreen";
		level.fade_out_overlay.foreground = false;  // arcademode compatible
		level.fade_out_overlay.sort = 50;  // arcademode compatible
		level.fade_out_overlay SetShader( "white", 640, 480 );
	}

	// start off invisible
	level.fade_out_overlay.alpha = 0;

	level.fade_out_overlay fadeOverTime( time );
	level.fade_out_overlay.alpha = 1;
	wait( time );
}


huey_damage_cockpit_fx_based_on_health()
{
	self endon("death");

	while( self.current_damage / self.dmg_taken_max < .25 )
	{
		wait(0.05);
	}
	
	self thread huey_ramp_dmg_fx_up_and_down( "tag_spark_l", self.dmg_taken_max * .25, self.dmg_taken_max * .6 );
	
	while( self.current_damage < self.dmg_taken_max * .4 )
	{
		wait(0.05);
	}
	
	self thread huey_ramp_dmg_fx_up_and_down( "tag_spark_r", self.dmg_taken_max * .45, self.dmg_taken_max * .8 );

}

huey_ramp_dmg_fx_up_and_down( tag_name, spark_threshold, fire_threshold )
{
	//"panel_dmg_sm", "panel_dmg_md"
	
	self endon("death");
	while(1)
	{
		temp_model = create_temp_model_and_linkto_tag(tag_name);
		PlayFXOnTag( level._effect["panel_dmg_sm"], temp_model, "tag_origin" );
		
		while(self.current_damage < fire_threshold)
		{
			wait(0.1);
		}
		
		temp_model Delete();
		temp_model = create_temp_model_and_linkto_tag(tag_name);
		PlayFXOnTag( level._effect["panel_dmg_md"], temp_model, "tag_origin" );
		
		while(self.current_damage > spark_threshold)
		{
			wait(0.1);
		}
		
		temp_model Delete();	
	}
}

create_temp_model_and_linkto_tag( tag_name )
{
	temp_model = Spawn("script_model", (0,0,0));
	temp_model SetModel("tag_origin");
	temp_model.origin = self GetTagOrigin(tag_name);
	temp_model.angles = self GetTagAngles(tag_name);
	temp_model LinkTo(self);
	
	return temp_model;
}

huey_do_very_damaged_feedback()
{
	self endon("death");
	self endon("end_player_heli");
	level waittill("huey_int_dmg_start");

	self thread huey_cockpit_interior_damage_all();

	self.supportsAnimScripted = true;
	self.animname = "helicopter";
	self UseAnimTree(level.scr_animtree["helicopter"]);

	PlayFXOnTag( level._effect["huey_fire"], self, "tag_origin" );	
	PlayFXOnTag( level._effect["panel_dmg_md"], self, "tag_spark_l" );
	PlayFXOnTag( level._effect["panel_dmg_md"], self, "tag_spark_r" );

//	self SetAnim(level.scr_anim["helicopter"]["heli_crash_spin_right"], 1, 0.1, 0.1);

	player = get_players()[0];

	vel = 0;
	max_vel = 30.0;

	spin = false;
	spin_time = 4.0;

	self SetViewClamp(player, 0, 0, 15, 20);

	while (1)
	{
		r_stick = player GetNormalizedCameraMovement();
		//IPrintLn("Stick: " + r_stick[1]);

		if (spin)
		{
			spin_time -= 0.05;
			if (spin_time < 2.0 && spin_time > 0.0)
			{
				if (r_stick[1] < 0.0)
				{
					spin = false;
				}
			}
			else if (spin_time <= 0.0)
			{
				spin = false;
			}
		}
		else
		{
			desired_vel = max_vel * r_stick[1];
			vel = lag(desired_vel, vel, 0.5, 0.05);
		}

		angular_vel = self GetAngularVelocity();
		angular_vel = (angular_vel[0], angular_vel[1] - vel, angular_vel[2]);
		self SetAngularVelocity(angular_vel);

		player PlayRumbleOnEntity("damage_heavy");
		Earthquake(0.25, 1, self.origin, 512);

		wait(0.05);
	}
}

lag(desired, curr, k, dt)
{
    r = 0.0;

    if (((k * dt) >= 1.0) || (k <= 0.0))
    {
        r = desired;
    }
    else
    {
        err = desired - curr;
        r = curr + k * err * dt;
    }

    return r;
}

huey_cockpit_interior_damage()
{
	self endon("death");
	level endon("enemy_hind_dead");
	self endon("end_player_heli");

	level.current_damage_state = 0;
	level.num_int_damage_states = 4;

	level.cockpit_decals = [];
	level.cockpit_decals[0] = "t5_veh_helo_huey_att_uwb_dmg_scorch";
	level.cockpit_decals[1] = "t5_veh_helo_huey_att_uwb_dmg_dials";
	level.cockpit_decals[2] = "t5_veh_helo_huey_att_uwb_dmg_blood";
	level.cockpit_decals[3] = "t5_veh_helo_huey_att_uwb_dmg_glass";

	while (1)
	{
		// waittill notify
		self waittill("damage_state");

		if (level.current_damage_state < level.num_int_damage_states)
		{
			// Attach the current state
			self Attach(level.cockpit_decals[level.current_damage_state], "tag_origin");

			// special case for front glass
			if (level.current_damage_state == level.num_int_damage_states - 1)
			{
				self HidePart("tag_front_glass");
			}

			level.current_damage_state++;
		}
	}
}

huey_cockpit_interior_damage_all(i_mean_it)
{
	if (IsDefined(i_mean_it) && i_mean_it)
	{
		level.current_damage_state = 0;
	}

	for (i = level.current_damage_state; i < level.num_int_damage_states; i++)
	{
		// Attach the decal
		self Attach(level.cockpit_decals[i], "tag_origin");

		// special case for front glass
		if (i == level.num_int_damage_states - 1)
		{
			self HidePart("tag_front_glass");
		}	
	}
}

huey_simple_control()
{
	level endon("start_heavy_resistance");

	player = get_players()[0];
	while (1)
	{
		l_stick = player GetNormalizedMovement();

		velocity = self.velocity;
		stick_vel = 5000 * l_stick[0];
		acc = stick_vel * AnglesToRight(self.angles);
		velocity = velocity + acc;

		self SetVehVelocity(velocity);

		wait(0.05);
	}
}

huey_ads_toggle()
{
	self endon("death");
	level endon("end_player_heli");

	ads_active = false;

	//0 == down; 1 == up; 2 == pressed; 3 == released (doing this to avoid more script strings)  
	button_state = 1; 

	while (1)
	{
		if(self MeleeButtonPressed())
		{
			// makes sure fast presses are counted.
			if(button_state == 1 || button_state == 3)	//if "up" or "released"
			{
				button_state = 2;	//set to "pressed"
			}
			else if(button_state == 2)	//if still "pressed"
			{
				button_state = 0;	//set to down  
			}
		}
		else
		{
			//make sure fast releases are counted
			if(button_state == 0 || button_state == 2)	//if "down" or "pressed"
			{
				button_state = 3;	//set to "released" 
			}
			else if(button_state == 3 )	//if still "released"
			{
				button_state = 1;	//set to "up" 
			}
		}

		// if the button was "pressed" 
		if(button_state == 2 ) 
		{
			// handle toggle
			if (!ads_active)
			{
				// do ads
				ads_active = true;

				// zoom fov
				self SetClientDvar( "cg_fov", level.huey_zoom_fov );
			}
			else 
			{
				// disable ads
				ads_active = false;

				// normal fov
				self SetClientDvar( "cg_fov", level.huey_fov );
			}
		}

		wait(0.05);
	}
}





