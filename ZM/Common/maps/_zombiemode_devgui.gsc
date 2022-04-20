#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;


/#

init()
{
	SetDvar( "zombie_devgui", "" );
	SetDvar( "scr_force_weapon", "" );
	SetDvar( "scr_zombie_round", "1" );
	SetDvar( "scr_zombie_dogs", "1" );
	SetDvar( "scr_spawn_tesla", "" );
	SetDvar( "scr_force_quantum_bomb_result", "" );

	level thread zombie_devgui_think();
	level thread zombie_devgui_tesla_think();
	level thread zombie_devgui_thundergun_think();
	level thread zombie_devgui_freezegun_think();
}


zombie_devgui_think()
{
	for ( ;; )
	{
		cmd = GetDvar( #"zombie_devgui" );

		switch ( cmd )
		{
		case "money":
			players = get_players();
			array_thread( players, ::zombie_devgui_give_money );
			if ( players.size > 1 )
			{
				for ( i=0; i<level.team_pool.size; i++ )
				{
					level.team_pool[i].score += 100000;
					level.team_pool[i].old_score += 100000;
					level.team_pool[i] maps\_zombiemode_score::set_team_score_hud(); 
				}
			}
			break;

		case "health":
			//iprintln( "Mega Health for all players" );
			array_thread( get_players(), ::zombie_devgui_give_health );	
			break;

		case "specialty_armorvest":
		case "specialty_quickrevive":
		case "specialty_fastreload":
		case "specialty_rof":
		case "specialty_longersprint":
		case "specialty_flakjacket":
		case "specialty_deadshot":
		case "specialty_additionalprimaryweapon":
			zombie_devgui_give_perk( cmd );
			break;

		case "nuke":
		case "insta_kill":
		case "double_points":
		case "full_ammo":
		case "carpenter":
		case "fire_sale":
		case "bonfire_sale":
		case "minigun":
		case "free_perk":
		case "monkey_swarm":
		case "tesla":
		case "random_weapon":
		case "bonus_points_player":
		case "bonus_points_team":
		case "lose_points_team":
		case "lose_perk":
		case "empty_clip":
			zombie_devgui_give_powerup( cmd );
			break;

		case "round":
			zombie_devgui_goto_round( GetDvarInt( #"scr_zombie_round" ) );
			break;
		case "round_next":
			zombie_devgui_goto_round( level.round_number + 1 );
			break;
		case "round_prev":
			zombie_devgui_goto_round( level.round_number - 1 );
			break;

		case "chest_move":
			if ( IsDefined( level.chest_accessed ) )
			{
				//iprintln( "Teddy bear will spawn on next open" );
				level notify( "devgui_chest_end_monitor" );
				level.chest_accessed = 100;
			}
			break;

		case "chest_never_move":
			if ( IsDefined( level.chest_accessed ) )
			{
				//iprintln( "Setting chest to never move" );
				level thread zombie_devgui_chest_never_move();
			}
			break;

		case "chest":
			if( IsDefined( level.zombie_weapons[ GetDvar( #"scr_force_weapon" ) ] ) )
			{
				//iprintln( GetDvar( #"scr_force_weapon" ) + " will spawn on next open" );
			}
			break;

		case "quantum_bomb_random_result":
			// clears the dvar so that we'll go back to getting random results
			SetDvar( "scr_force_quantum_bomb_result", "" );
			break;

		case "give_gasmask":
			array_thread( get_players(), ::zombie_devgui_equipment_give, "equip_gasmask_zm" );
			break;

		case "give_hacker":
			array_thread( get_players(), ::zombie_devgui_equipment_give, "equip_hacker_zm" );
			break;

		case "give_monkey":
			array_thread( get_players(), ::zombie_devgui_give_monkey );
			break;

		case "give_black_hole_bomb":
			array_thread( get_players(), ::zombie_devgui_give_black_hole_bomb );
			break;

		case "give_dolls":
			array_thread( get_players(), ::zombie_devgui_give_dolls );
			break;

		case "give_quantum_bomb":
			array_thread( get_players(), ::zombie_devgui_give_quantum_bomb );
			break;

		case "monkey_round":
			zombie_devgui_monkey_round();
			break;

		case "thief_round":
			zombie_devgui_thief_round();
			break;

		case "dog_round":
			zombie_devgui_dog_round( GetDvarInt( #"scr_zombie_dogs" ) );
			break;

		case "dog_round_skip":
			zombie_devgui_dog_round_skip();
			break;

		case "print_variables":
			zombie_devgui_dump_zombie_vars();
			break;

		case "revive_all":
			zombie_devgui_revive_all();
			break;
			
		case "pack_current_weapon":
			zombie_devgui_pack_current_weapon();
			break;

		case "power_on":
			flag_set( "power_on" );
			Objective_State(8,"done");
			break;

		case "director_easy":
			zombie_devgui_director_easy();
			break;
			
		case "open_sesame":
			zombie_devgui_open_sesame();
			break;

		case "disable_kill_thread_toggle":
			zombie_devgui_disable_kill_thread_toggle();
			break;

		case "check_kill_thread_every_frame_toggle":
			zombie_devgui_check_kill_thread_every_frame_toggle();
			break;

		//case "zombie_airstrike":
		//	array_thread( get_players(), ::zombie_devgui_give_ability, cmd );
		//	break;
		//	
		//case "zombie_artillery":
		//	array_thread( get_players(), ::zombie_devgui_give_ability, cmd );
		//	break;
		//	
		//case "zombie_napalm":
		//	array_thread( get_players(), ::zombie_devgui_give_ability, cmd );
		//	break;
		//	
		//case "zombie_helicopter":
		//	array_thread( get_players(), ::zombie_devgui_give_ability, cmd );
		//	break;
		//	
		//case "zombie_turret":
		//	array_thread( get_players(), ::zombie_devgui_give_ability, cmd );
		//	break;
		//	
		//case "zombie_portal":
		//	array_thread( get_players(), ::zombie_devgui_give_ability, cmd );
		//	break;
		//	
		//case "zombie_dogs":
		//	array_thread( get_players(), ::zombie_devgui_give_ability, cmd );
		//	break;
		//	
		//case "zombie_rcbomb":
		//	array_thread( get_players(), ::zombie_devgui_give_ability, cmd );
		//	break;
		//	
		//case "zombie_cloak":
		//	array_thread( get_players(), ::zombie_devgui_give_ability, cmd );
		//	break;
		//	
		//case "zombie_endurance":
		//	array_thread( get_players(), ::zombie_devgui_give_ability, cmd );
		//	break;
			
		case "":
			break;

		default:
			if ( IsDefined( level.custom_devgui ) )
			{
				[[level.custom_devgui]]( cmd );
			}
			else
			{
				//iprintln( "Unknown devgui command: '" + cmd + "'" );
			}
			break;
		}
	
		SetDvar( "zombie_devgui", "" );
		wait( 0.5 );
	}
}


zombie_devgui_open_sesame()
{
	setdvar("zombie_unlock_all",1);
	
	//turn on the power first
	flag_set( "power_on" );
	
	//give everyone money
	players = get_players();
	array_thread( players, ::zombie_devgui_give_money );
	
	//get all the door triggers and trigger them
	// DOORS ----------------------------------------------------------------------------- //
	zombie_doors = GetEntArray( "zombie_door", "targetname" ); 

	for( i = 0; i < zombie_doors.size; i++ )
	{
		zombie_doors[i] notify("trigger",players[0]);
		wait(.05);
	}

	// AIRLOCK DOORS ----------------------------------------------------------------------------- //
	zombie_airlock_doors = GetEntArray( "zombie_airlock_buy", "targetname" ); 

	for( i = 0; i < zombie_airlock_doors.size; i++ )
	{
		zombie_airlock_doors[i] notify("trigger",players[0]);
		wait(.05);
	}

	// DEBRIS ---------------------------------------------------------------------------- //
	zombie_debris = GetEntArray( "zombie_debris", "targetname" ); 

	for( i = 0; i < zombie_debris.size; i++ )
	{
		zombie_debris[i] notify("trigger",players[0]); 
		wait(.05);
	}

	wait( 1 );			
	setdvar( "zombie_unlock_all", 0 );
}


zombie_devgui_tesla_think()
{
	if ( !maps\_zombiemode_weapons::is_weapon_included( "tesla_gun_zm" ) )
	{
		return;
	}

	SetDvar( "scr_tesla_max_arcs", level.zombie_vars["tesla_max_arcs"] ); 
	SetDvar( "scr_tesla_max_enemies", level.zombie_vars["tesla_max_enemies_killed"] ); 
	SetDvar( "scr_tesla_radius_start", level.zombie_vars["tesla_radius_start"] );
	SetDvar( "scr_tesla_radius_decay", level.zombie_vars["tesla_radius_decay"] );
	SetDvar( "scr_tesla_head_gib_chance", level.zombie_vars["tesla_head_gib_chance"] );
	SetDvar( "scr_tesla_arc_travel_time", level.zombie_vars["tesla_arc_travel_time"] );

	for ( ;; )
	{
		level.zombie_vars["tesla_max_arcs"]				= GetDvarInt( #"scr_tesla_max_arcs" );
		level.zombie_vars["tesla_max_enemies_killed"]	= GetDvarInt( #"scr_tesla_max_enemies" );
		level.zombie_vars["tesla_radius_start"]			= GetDvarInt( #"scr_tesla_radius_start" );
		level.zombie_vars["tesla_radius_decay"]			= GetDvarInt( #"scr_tesla_radius_decay" );
		level.zombie_vars["tesla_head_gib_chance"]		= GetDvarInt( #"scr_tesla_head_gib_chance" );
		level.zombie_vars["tesla_arc_travel_time"]		= GetDvarFloat( #"scr_tesla_arc_travel_time" );

		wait( 0.5 );
	}
}


zombie_devgui_thundergun_think()
{
	if ( !maps\_zombiemode_weapons::is_weapon_included( "thundergun_zm" ) )
	{
		return;
	}

	SetDvar( "scr_thundergun_cylinder_radius", level.zombie_vars["thundergun_cylinder_radius"] );
	SetDvar( "scr_thundergun_fling_range", level.zombie_vars["thundergun_fling_range"] );
	SetDvar( "scr_thundergun_gib_range", level.zombie_vars["thundergun_gib_range"] );
	SetDvar( "scr_thundergun_gib_damage", level.zombie_vars["thundergun_gib_damage"] );
	SetDvar( "scr_thundergun_knockdown_range", level.zombie_vars["thundergun_knockdown_range"] );
	SetDvar( "scr_thundergun_knockdown_damage", level.zombie_vars["thundergun_knockdown_damage"] );

	for ( ;; )
	{
		level.zombie_vars["thundergun_cylinder_radius"]		= GetDvarInt( #"scr_thundergun_cylinder_radius" );
		level.zombie_vars["thundergun_fling_range"]			= GetDvarInt( #"scr_thundergun_fling_range" );
		level.zombie_vars["thundergun_gib_range"]			= GetDvarInt( #"scr_thundergun_gib_range" );
		level.zombie_vars["thundergun_gib_damage"]			= GetDvarInt( #"scr_thundergun_gib_damage" );
		level.zombie_vars["thundergun_knockdown_range"] 	= GetDvarInt( #"scr_thundergun_knockdown_range" );
		level.zombie_vars["thundergun_knockdown_damage"]	= GetDvarInt( #"scr_thundergun_knockdown_damage" );

		wait( 0.5 );
	}
}


zombie_devgui_freezegun_think()
{
	if ( !maps\_zombiemode_weapons::is_weapon_included( "freezegun_zm" ) )
	{
		return;
	}

	SetDvar( "scr_freezegun_cylinder_radius",				level.zombie_vars["freezegun_cylinder_radius"] );
	SetDvar( "scr_freezegun_inner_range",					level.zombie_vars["freezegun_inner_range"] );
	SetDvar( "scr_freezegun_outer_range",					level.zombie_vars["freezegun_outer_range"] );
	SetDvar( "scr_freezegun_inner_damage",					level.zombie_vars["freezegun_inner_damage"] );
	SetDvar( "scr_freezegun_outer_damage",					level.zombie_vars["freezegun_outer_damage"] );
	SetDvar( "scr_freezegun_shatter_range",					level.zombie_vars["freezegun_shatter_range"] );
	SetDvar( "scr_freezegun_shatter_inner_damage",			level.zombie_vars["freezegun_shatter_inner_damage"] );
	SetDvar( "scr_freezegun_shatter_outer_damage",			level.zombie_vars["freezegun_shatter_outer_damage"] );
	SetDvar( "scr_freezegun_cylinder_radius_upgraded",		level.zombie_vars["freezegun_cylinder_radius_upgraded"] );
	SetDvar( "scr_freezegun_inner_range_upgraded",			level.zombie_vars["freezegun_inner_range_upgraded"] );
	SetDvar( "scr_freezegun_outer_range_upgraded",			level.zombie_vars["freezegun_outer_range_upgraded"] );
	SetDvar( "scr_freezegun_inner_damage_upgraded",			level.zombie_vars["freezegun_inner_damage_upgraded"] );
	SetDvar( "scr_freezegun_outer_damage_upgraded",			level.zombie_vars["freezegun_outer_damage_upgraded"] );
	SetDvar( "scr_freezegun_shatter_range_upgraded",		level.zombie_vars["freezegun_shatter_range_upgraded"] );
	SetDvar( "scr_freezegun_shatter_inner_damage_upgraded",	level.zombie_vars["freezegun_shatter_inner_damage_upgraded"] );
	SetDvar( "scr_freezegun_shatter_outer_damage_upgraded",	level.zombie_vars["freezegun_shatter_outer_damage_upgraded"] );

	for ( ;; )
	{
		level.zombie_vars["freezegun_cylinder_radius"]					= GetDvarInt( #"scr_freezegun_cylinder_radius" );
		level.zombie_vars["freezegun_inner_range"]						= GetDvarInt( #"scr_freezegun_inner_range" );
		level.zombie_vars["freezegun_outer_range"]						= GetDvarInt( #"scr_freezegun_outer_range" );
		level.zombie_vars["freezegun_inner_damage"]						= GetDvarInt( #"scr_freezegun_inner_damage" );
		level.zombie_vars["freezegun_outer_damage"]						= GetDvarInt( #"scr_freezegun_outer_damage" );
		level.zombie_vars["freezegun_shatter_range"]					= GetDvarInt( #"scr_freezegun_shatter_range" );
		level.zombie_vars["freezegun_shatter_inner_damage"]				= GetDvarInt( #"scr_freezegun_shatter_inner_damage" );
		level.zombie_vars["freezegun_shatter_outer_damage"]				= GetDvarInt( #"scr_freezegun_shatter_outer_damage" );
		level.zombie_vars["freezegun_cylinder_radius_upgraded"]			= GetDvarInt( #"scr_freezegun_cylinder_radius_upgraded" );
		level.zombie_vars["freezegun_inner_range_upgraded"]				= GetDvarInt( #"scr_freezegun_inner_range_upgraded" );
		level.zombie_vars["freezegun_outer_range_upgraded"]				= GetDvarInt( #"scr_freezegun_outer_range_upgraded" );
		level.zombie_vars["freezegun_inner_damage_upgraded"]			= GetDvarInt( #"scr_freezegun_inner_damage_upgraded" );
		level.zombie_vars["freezegun_outer_damage_upgraded"]			= GetDvarInt( #"scr_freezegun_outer_damage_upgraded" );
		level.zombie_vars["freezegun_shatter_range_upgraded"]			= GetDvarInt( #"scr_freezegun_shatter_range_upgraded" );
		level.zombie_vars["freezegun_shatter_inner_damage_upgraded"]	= GetDvarInt( #"scr_freezegun_shatter_inner_damage_upgraded" );
		level.zombie_vars["freezegun_shatter_outer_damage_upgraded"]	= GetDvarInt( #"scr_freezegun_shatter_outer_damage_upgraded" );

		wait( 0.5 );
	}
}


zombie_devgui_give_money()
{
	assert( IsDefined( self ) );
	assert( IsPlayer( self ) );
	assert( IsAlive( self ) );
	
	level.devcheater = 1;
	
	self maps\_zombiemode_score::add_to_player_score( 100000 );
}


zombie_devgui_equipment_give( equipment )
{
	assert( IsDefined( self ) );
	assert( IsPlayer( self ) );
	assert( IsAlive( self ) );

	level.devcheater = 1;
	
	self maps\_zombiemode_equipment::equipment_give( equipment );
}


zombie_devgui_give_monkey()
{
	self notify( "give_tactical_granade_thread" );
	self endon( "give_tactical_granade_thread" );
	
	assert( IsDefined( self ) );
	assert( IsPlayer( self ) );
	assert( IsAlive( self ) );
	
	level.devcheater = 1;

	if ( isdefined( self get_player_tactical_grenade() ) )
	{
		self TakeWeapon( self get_player_tactical_grenade() );
	}

	self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
	while( true )
	{
		self GiveMaxAmmo( "zombie_cymbal_monkey" );
		wait( 1 );
	}
}

zombie_devgui_give_black_hole_bomb()
{
	self notify( "give_tactical_granade_thread" );
	self endon( "give_tactical_granade_thread" );
	
	assert( IsDefined( self ) );
	assert( IsPlayer( self ) );
	assert( IsAlive( self ) );
	
	level.devcheater = 1;

	if ( isdefined( self get_player_tactical_grenade() ) )
	{
		self TakeWeapon( self get_player_tactical_grenade() );
	}

	if ( IsDefined( level.zombiemode_devgui_black_hole_bomb_give ) )
	{
		self [[ level.zombiemode_devgui_black_hole_bomb_give ]]();
		while( true )
		{
			self GiveMaxAmmo( "zombie_black_hole_bomb" );
			wait( 1 );
		}
	}
}

zombie_devgui_give_dolls()
{
	self notify( "give_tactical_granade_thread" );
	self endon( "give_tactical_granade_thread" );
	
	assert( IsDefined( self ) );
	assert( IsPlayer( self ) );
	assert( IsAlive( self ) );
	
	level.devcheater = 1;

	if ( isdefined( self get_player_tactical_grenade() ) )
	{
		self TakeWeapon( self get_player_tactical_grenade() );
	}

	if ( IsDefined( level.zombiemode_devgui_nesting_dolls_give ) )
	{
		self [[ level.zombiemode_devgui_nesting_dolls_give ]]();
		while( true )
		{
			self GiveMaxAmmo( "zombie_nesting_dolls" );
			wait( 1 );
		}
	}
}

zombie_devgui_give_quantum_bomb()
{
	self notify( "give_tactical_granade_thread" );
	self endon( "give_tactical_granade_thread" );
	
	assert( IsDefined( self ) );
	assert( IsPlayer( self ) );
	assert( IsAlive( self ) );
	
	level.devcheater = 1;

	if ( isdefined( self get_player_tactical_grenade() ) )
	{
		self TakeWeapon( self get_player_tactical_grenade() );
	}

	if ( IsDefined( level.zombiemode_devgui_quantum_bomb_give ) )
	{
		self [[ level.zombiemode_devgui_quantum_bomb_give ]]();
		while( true )
		{
			self GiveMaxAmmo( "zombie_quantum_bomb" );
			wait( 1 );
		}
	}
}

zombie_devgui_give_health()
{
	assert( IsDefined( self ) );
	assert( IsPlayer( self ) );
	assert( IsAlive( self ) );

	self notify( "devgui_health" );
	self endon( "devgui_health" );
	self endon( "disconnect" );
	self endon( "death" );
		
	level.devcheater = 1;

	while ( 1 )
	{
		self.maxhealth = 100000;
		self.health = 100000;

		self waittill_any( "player_revived", "perk_used", "spawned_player" );	
		wait( 2 );
	}
}


zombie_devgui_give_perk( perk )
{
	vending_triggers = GetEntArray( "zombie_vending", "targetname" );
	player = get_players()[0];
		
	level.devcheater = 1;

	if ( vending_triggers.size < 1 )
	{
		//iprintln( "Map does not contain any perks machines" );
		return;
	}

	for ( i = 0; i < vending_triggers.size; i++ )
	{
		if ( vending_triggers[i].script_noteworthy == perk )
		{
			vending_triggers[i] notify( "trigger", player );
			return;
		}
	}

	//iprintln( "Map does not contain perks machine with perk: " + perk );
}


//zombie_devgui_give_ability( ability )
//{
//	self maps\_zombiemode_ability::give_ability_now( ability );
//}


zombie_devgui_give_powerup( powerup_name )
{
	player = get_players()[0];
	found = false;
		
	level.devcheater = 1;

	for ( i = 0; i < level.zombie_powerup_array.size; i++ )
	{
		if ( level.zombie_powerup_array[i] == powerup_name )
		{
			level.zombie_powerup_index = i;
			found = true;
			break;
		}
	}

	if ( !found )
	{
		//iprintln( "Powerup not found: " + powerup_name );
		return;
	}

	// Trace to where the player is looking
	direction = player GetPlayerAngles();
	direction_vec = AnglesToForward( direction );
	eye = player GetEye();

	scale = 8000;
	direction_vec = (direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale);

	// offset 2 units on the Z to fix the bug where it would drop through the ground sometimes
	trace = bullettrace( eye, eye + direction_vec, 0, undefined );
	level.zombie_devgui_power = 1;
	level.zombie_vars["zombie_drop_item"] = 1;
	level.powerup_drop_count = 0;
	level thread maps\_zombiemode_powerups::powerup_drop( trace["position"] );

	
}


zombie_devgui_goto_round( target_round )
{
	player = get_players()[0];

	if ( target_round < 1 )
	{
		target_round = 1;
	}
	
	level.devcheater = 1;

	level.zombie_total = 0;
	maps\_zombiemode::ai_calculate_health( target_round );
	level.round_number = target_round - 1;

	level notify( "kill_round" );

	// fix up the hud
// 	if( IsDefined( level.chalk_hud2 ) )
// 	{
// 		level.chalk_hud2 maps\_zombiemode_utility::destroy_hud();
// 
// 		if ( level.round_number < 11 )
// 		{
// 			level.chalk_hud2 = maps\_zombiemode::create_chalk_hud( 64 );
// 		}
// 	}
// 
// 	if ( IsDefined( level.chalk_hud1 ) ) 
// 	{
// 		level.chalk_hud1 maps\_zombiemode_utility::destroy_hud();
// 		level.chalk_hud1 = maps\_zombiemode::create_chalk_hud();
// 
// 		switch( level.round_number )
// 		{
// 		case 0:
// 		case 1:
// 			level.chalk_hud1 SetShader( "hud_chalk_1", 64, 64 );
// 			break;
// 		case 2:
// 			level.chalk_hud1 SetShader( "hud_chalk_2", 64, 64 );
// 			break;
// 		case 3:
// 			level.chalk_hud1 SetShader( "hud_chalk_3", 64, 64 );
// 			break;
// 		case 4:
// 			level.chalk_hud1 SetShader( "hud_chalk_4", 64, 64 );
// 			break;
// 		default:
// 			level.chalk_hud1 SetShader( "hud_chalk_5", 64, 64 );
// 			break;
// 		}
// 	}
	
	//iprintln( "Jumping to round: " + target_round );
	wait( 1 );
	
	// kill all active zombies
	zombies = GetAiSpeciesArray( "axis", "all" );

	if ( IsDefined( zombies ) )
	{
		for (i = 0; i < zombies.size; i++)
		{
			if ( is_true( zombies[i].ignore_devgui_death ) )
			{
				continue;
			}
			zombies[i] dodamage(zombies[i].health + 666, zombies[i].origin);
		}
	}
}


zombie_devgui_monkey_round()
{
	if ( IsDefined( level.next_monkey_round ) )
	{
		zombie_devgui_goto_round( level.next_monkey_round );
	}
}

zombie_devgui_thief_round()
{
	if ( IsDefined( level.next_thief_round ) )
	{
		zombie_devgui_goto_round( level.next_thief_round );
	}
}

zombie_devgui_dog_round( num_dogs )
{
	if( !IsDefined( level.dogs_enabled ) || !level.dogs_enabled )
	{
		//iprintln( "Dogs not enabled in this map" );
		return;
	}

	if( !IsDefined( level.dog_rounds_enabled ) || !level.dog_rounds_enabled )
	{
		//iprintln( "Dog rounds not enabled in this map" );
		return;
	}

	if( !IsDefined( level.enemy_dog_spawns ) || level.enemy_dog_spawns.size < 1 )
	{
		//iprintln( "Dog spawners not found in this map" );
		return;
	}
	
	if ( !flag( "dog_round" ) )
	{
		//iprintln( "Spawning " + num_dogs + " dogs" );
		SetDvar( "force_dogs", num_dogs );
	}
	else
	{
		//iprintln( "Removing dogs" );
	}

	zombie_devgui_goto_round( level.round_number + 1 );
}

zombie_devgui_dog_round_skip()
{
	if ( IsDefined( level.next_dog_round ) )
	{
		zombie_devgui_goto_round( level.next_dog_round );
	}
}


zombie_devgui_dump_zombie_vars()
{
	if ( !IsDefined( level.zombie_vars ) )
	{
		return;
	}
		

	if( level.zombie_vars.size > 0 )
	{
		//iprintln( "Zombie Variables Sent to Console" );
		println( "##### Zombie Variables #####");
	}
	else
	{
		return;
	}
	
	var_names = GetArrayKeys( level.zombie_vars );
	
	for( i = 0; i < level.zombie_vars.size; i++ )
	{
		key = var_names[i];
		println( key + ":     " + level.zombie_vars[key] );
	}

	println( "##### End Zombie Variables #####");
}


zombie_devgui_revive_all()
{
	players = get_players();
	reviver = players[0];

	for ( i = 0; i < players.size; i++ )
	{
		if ( !players[i] maps\_laststand::player_is_in_laststand() )
		{
			reviver = players[i];
			break;
		}
	}

	for ( i = 0; i < players.size; i++ )
	{
		if ( players[i] maps\_laststand::player_is_in_laststand() )
		{
			players[i] maps\_laststand::revive_force_revive( reviver );
			players[i] notify ( "zombified" );
		}
	}
}

zombie_devgui_pack_current_weapon()
{
	players = get_players();
	reviver = players[0];

	level.devcheater = 1;

	for ( i = 0; i < players.size; i++ )
	{
		if ( !players[i] maps\_laststand::player_is_in_laststand() )
		{
			weap = players[i] getcurrentweapon();
			if(!players[i] maps\_zombiemode_weapons::has_upgrade( weap ) )
			{
				weapon = get_upgrade( weap );
				if(isDefined(weapon))
				{
					players[i] GiveWeapon( weapon, 0, players[i] maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( weapon ) );
					players[i] GiveStartAmmo( weapon );
					players[i] SwitchToWeapon( weapon );	
				}
			}
			
		}
	}
}

get_upgrade( weaponname )
{

	if( IsDefined(level.zombie_weapons[weaponname]) && IsDefined(level.zombie_weapons[weaponname].upgrade_name) )
	{
		return level.zombie_weapons[weaponname].upgrade_name ;

	}
	else
	{
		return undefined;
	}
}

zombie_devgui_director_easy()
{
	if ( IsDefined( level.director_devgui_health ) )
	{
		[[ level.director_devgui_health ]]();
	}
}


zombie_devgui_chest_never_move()
{
	level notify( "devgui_chest_end_monitor" );
	level endon( "devgui_chest_end_monitor" );

	for ( ;; )
	{
		level.chest_accessed = 0;
		wait( 5 );
	}
}


zombie_devgui_disable_kill_thread_toggle()
{
	if ( !is_true( level.disable_kill_thread ) )
	{
		level.disable_kill_thread = true;
	}
	else
	{
		level.disable_kill_thread = false;
	}
}


zombie_devgui_check_kill_thread_every_frame_toggle()
{
	if ( !is_true( level.check_kill_thread_every_frame ) )
	{
		level.check_kill_thread_every_frame = true;
	}
	else
	{
		level.check_kill_thread_every_frame = false;
	}
}


#/
