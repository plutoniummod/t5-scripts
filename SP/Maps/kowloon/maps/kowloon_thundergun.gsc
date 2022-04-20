#include maps\_utility; 
#include common_scripts\utility; 
//#include maps\_zombiemode_utility;
#include maps\_zombiemode_net;

#using_animtree( "generic_human" );

init()
{
// 	if( !thundergun_exists() )
// 	{
// 		return;
// 	}

	// precache the clientside effects
	level._effect["thundergun_viewmodel_power_cell1"] = loadfx("weapon/thunder_gun/fx_thundergun_power_cell_view1");
	level._effect["thundergun_viewmodel_power_cell2"] = loadfx("weapon/thunder_gun/fx_thundergun_power_cell_view2");
	level._effect["thundergun_viewmodel_power_cell3"] = loadfx("weapon/thunder_gun/fx_thundergun_power_cell_view3");
	level._effect["thundergun_viewmodel_steam"] = loadfx("weapon/thunder_gun/fx_thundergun_steam_view");

	level._effect["thundergun_viewmodel_power_cell1_upgraded"] = loadfx("weapon/thunder_gun/fx_thundergun_power_cell_view1");
	level._effect["thundergun_viewmodel_power_cell2_upgraded"] = loadfx("weapon/thunder_gun/fx_thundergun_power_cell_view2");
	level._effect["thundergun_viewmodel_power_cell3_upgraded"] = loadfx("weapon/thunder_gun/fx_thundergun_power_cell_view3");
	level._effect["thundergun_viewmodel_steam_upgraded"] = loadfx("weapon/thunder_gun/fx_thundergun_steam_view");


	level._effect["thundergun_knockdown_ground"]	= loadfx( "weapon/thunder_gun/fx_thundergun_knockback_ground" );
	level._effect["thundergun_smoke_cloud"]			= loadfx( "weapon/thunder_gun/fx_thundergun_smoke_cloud" );

	set_zombie_var( "thundergun_cylinder_radius",		60 );
	set_zombie_var( "thundergun_fling_range",			360 ); // 30 feet
	set_zombie_var( "thundergun_gib_range",				540 ); // 45 feet
	set_zombie_var( "thundergun_gib_damage",			75 );
	set_zombie_var( "thundergun_knockdown_range",		720 ); // 60 feet
	set_zombie_var( "thundergun_knockdown_damage",		15 );

	level.thundergun_gib_refs = [];
	level.thundergun_gib_refs[level.thundergun_gib_refs.size] = "right_arm"; 
	level.thundergun_gib_refs[level.thundergun_gib_refs.size] = "left_arm"; 
	level.thundergun_gib_refs[level.thundergun_gib_refs.size] = "right_leg"; 
	level.thundergun_gib_refs[level.thundergun_gib_refs.size] = "left_leg"; 
	level.thundergun_gib_refs[level.thundergun_gib_refs.size] = "no_legs"; 

	level thread thundergun_on_player_connect(); 
}


thundergun_on_player_connect()
{
	for( ;; )
	{
		level waittill( "connecting", player ); 
		player thread wait_for_thundergun_fired(); 
	}
}


wait_for_thundergun_fired()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" ); 

	for( ;; )
	{
		self waittill( "weapon_fired" ); 
		currentweapon = self GetCurrentWeapon(); 
		if( ( currentweapon == "thundergun_zm" ) || ( currentweapon == "thundergun_upgraded_zm" ) )
		{
			self thread thundergun_fired(); 

			view_pos = self.origin;
			view_angles = self GetPlayerAngles();
// 			view_pos = self GetTagOrigin( "tag_flash" );
// 			view_angles = self GetTagAngles( "tag_flash" );
			playfx( level._effect["thundergun_smoke_cloud"], view_pos, AnglesToForward( view_angles ), AnglesToUp( view_angles ) );
		}
	}
}


thundergun_fired()
{
	if ( !IsDefined( level.thundergun_knockdown_enemies ) )
	{
		level.thundergun_knockdown_enemies = [];
		level.thundergun_knockdown_gib = [];
		level.thundergun_fling_enemies = [];
		level.thundergun_fling_vecs = [];
	}

	self thundergun_get_enemies_in_range();

	//iprintlnbold( "flg: " + level.thundergun_fling_enemies.size + " gib: " + level.thundergun_gib_enemies.size + " kno: " + level.thundergun_knockdown_enemies.size );

	for ( i = 0; i < level.thundergun_fling_enemies.size; i++ )
	{
		level.thundergun_fling_enemies[i] thread thundergun_fling_zombie( self, level.thundergun_fling_vecs[i] );
	}

	for ( i = 0; i < level.thundergun_knockdown_enemies.size; i++ )
	{
		level.thundergun_knockdown_enemies[i] thread thundergun_knockdown_zombie( self, level.thundergun_knockdown_gib[i] );
	}

	level.thundergun_knockdown_enemies = [];
	level.thundergun_knockdown_gib = [];
	level.thundergun_fling_enemies = [];
	level.thundergun_fling_vecs = [];
}


thundergun_get_enemies_in_range()
{
	view_pos = self GetWeaponMuzzlePoint();
	zombies = get_array_of_closest( view_pos, GetAiSpeciesArray( "axis", "all" ), undefined, undefined, level.zombie_vars["thundergun_knockdown_range"] );
	if ( !isDefined( zombies ) )
	{
		return;
	}

	knockdown_range_squared = level.zombie_vars["thundergun_knockdown_range"] * level.zombie_vars["thundergun_knockdown_range"];
	gib_range_squared = level.zombie_vars["thundergun_gib_range"] * level.zombie_vars["thundergun_gib_range"];
	fling_range_squared = level.zombie_vars["thundergun_fling_range"] * level.zombie_vars["thundergun_fling_range"];
	cylinder_radius_squared = level.zombie_vars["thundergun_cylinder_radius"] * level.zombie_vars["thundergun_cylinder_radius"];

	forward_view_angles = self GetWeaponForwardDir();
	end_pos = view_pos + vector_scale( forward_view_angles, level.zombie_vars["thundergun_knockdown_range"] );

	for ( i = 0; i < zombies.size; i++ )
	{
		if ( !IsDefined( zombies[i] ) || !IsAlive( zombies[i] ) )
		{
			// guy died on us
			continue;
		}

		test_origin = zombies[i] getcentroid();
		test_range_squared = DistanceSquared( view_pos, test_origin );
		if ( test_range_squared > knockdown_range_squared )
		{
			return; // everything else in the list will be out of range
		}

		normal = VectorNormalize( test_origin - view_pos );
		dot = VectorDot( forward_view_angles, normal );
		if ( 0 > dot )
		{
			// guy's behind us
			// iprintlnbold( "dot" );
			continue;
		}
		
		radial_origin = PointOnSegmentNearestToPoint( view_pos, end_pos, test_origin );
		if ( DistanceSquared( test_origin, radial_origin ) > cylinder_radius_squared )
		{
			// guy's outside the range of the cylinder of effect
			// iprintlnbold( "clyinder" );
			continue;
		}

		if ( 0 == zombies[i] DamageConeTrace( view_pos, self ) )
		{
			// guy can't actually be hit from where we are
			// iprintlnbold( "cone" );
			continue;
		}

		if ( test_range_squared < fling_range_squared )
		{
			level.thundergun_fling_enemies[level.thundergun_fling_enemies.size] = zombies[i];

			// the closer they are, the harder they get flung
			dist_mult = (fling_range_squared - test_range_squared) / fling_range_squared;
			fling_vec = VectorNormalize( test_origin - view_pos );

			// within 6 feet, just push them straight away from the player, ignoring radial motion
			if ( 5000 < test_range_squared )
			{
				fling_vec = fling_vec + VectorNormalize( test_origin - radial_origin );
			}
			fling_vec = (fling_vec[0], fling_vec[1], abs( fling_vec[2] ));
			fling_vec = vector_scale( fling_vec, 100 + 100 * dist_mult );
			level.thundergun_fling_vecs[level.thundergun_fling_vecs.size] = fling_vec;

//			zombies[i] thread setup_thundergun_vox( self, true, false, false );
		}
		else if ( test_range_squared < gib_range_squared )
		{
			level.thundergun_knockdown_enemies[level.thundergun_knockdown_enemies.size] = zombies[i];
			level.thundergun_knockdown_gib[level.thundergun_knockdown_gib.size] = true;

//			zombies[i] thread setup_thundergun_vox( self, false, true, false );
		}
		else
		{
			level.thundergun_knockdown_enemies[level.thundergun_knockdown_enemies.size] = zombies[i];
			level.thundergun_knockdown_gib[level.thundergun_knockdown_gib.size] = false;

//			zombies[i] thread setup_thundergun_vox( self, false, false, true );
		}
	}
}


thundergun_fling_zombie( player, fling_vec )
{
	if( !IsDefined( self ) || !IsAlive( self ) )
	{
		// guy died on us 
		return;
	}

	if ( IsDefined( self.thundergun_fling_func ) )
	{
		self [[ self.thundergun_fling_func ]]( player );
		return;
	}
	
	self DoDamage( self.health + 666, player.origin, player );

	if ( self.health <= 0 )
	{
//		player maps\_zombiemode_score::player_add_points( "death", "", "", self.isdog );
		
		self StartRagdoll();
		self LaunchRagdoll( fling_vec );

		self.thundergun_death = true;
	}
}


thundergun_knockdown_zombie( player, gib )
{
	self endon( "death" );
	playsoundatposition ("vox_thundergun_forcehit", self.origin);

	if( !IsDefined( self ) || !IsAlive( self ) )
	{
		// guy died on us 
		return;
	}

	if ( IsDefined( self.thundergun_knockdown_func ) )
	{
		self [[ self.thundergun_knockdown_func ]]( player, gib );
	}
	else
	{
		self DoDamage( level.zombie_vars["thundergun_knockdown_damage"], player.origin, player );
	}

	if ( gib )
	{
		self.a.gib_ref = random( level.thundergun_gib_refs );
//		self thread animscripts\death::do_gib();
		// Kill yourself
		if ( IsAlive(self) )
		{
			self DoDamage( self.health, player.origin, player );
		}
	}

//	self playsound( "thundergun_impact" );
// 	self.thundergun_handle_pain_notetracks = ::handle_thundergun_pain_notetracks;
// 	self DoDamage( level.zombie_vars["thundergun_knockdown_damage"], player.origin, player );

}


handle_thundergun_pain_notetracks( note )
{
	if ( note == "zombie_knockdown_ground_impact" )
	{
		playfx( level._effect["thundergun_knockdown_ground"], self.origin, AnglesToForward( self.angles ), AnglesToUp( self.angles ) );
		self playsound( "fly_thundergun_forcehit" );
	}
}


thundergun_exists()
{
	return IsDefined( level.zombie_weapons["thundergun_zm"] );
}


is_thundergun_damage()
{
	return IsDefined( self.damageweapon ) && (self.damageweapon == "thundergun_zm" || self.damageweapon == "thundergun_upgraded_zm");
}


enemy_killed_by_thundergun()
{
	return ( IsDefined( self.thundergun_death ) && self.thundergun_death == true ); 
}


thundergun_sound_thread()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" ); 


	for( ;; )
	{
		result = self waittill_any_return( "grenade_fire", "death", "player_downed", "weapon_change", "grenade_pullback" );		

		if ( !IsDefined( result ) )
		{
			continue;
		}

		if( ( result == "weapon_change" || result == "grenade_fire" ) && self GetCurrentWeapon() == "thundergun_zm" )
		{
			self PlayLoopSound( "tesla_idle", 0.25 );

		}
		else
		{
			self notify ("weap_away");
			self StopLoopSound(0.25);


		}
	}
}

//SELF = Zombie Being Hit With Thundergun
// setup_thundergun_vox( player, fling, gib, knockdown )
// {
// 	if( !IsDefined( self ) || !IsAlive( self ) )
// 	{
// 		return;
// 	}
// 	
// 	if( !fling && ( gib || knockdown ) )
// 	{
// 		if( 25 > RandomIntRange( 1, 100 ) )
// 		{
// 			//IPrintLnBold( "HAHA, You Knocked Down Some Zombies!" );
//			player maps\_zombiemode_audio::create_and_play_dialog( level.plr_vox["kill"]["thundergun_knockdown"], .25, level.plr_vox["kill"]["thundergun_knockdown_response"] );
// 		}
// 	}
// 		 
// 	if( fling )
// 	{
// 		if( 30 > RandomIntRange( 1, 100 ) )
// 		{
// 			//IPrintLnBold( "WAY TO DISINTEGRATE THEM!!" );
// //			player maps\_zombiemode_audio::create_and_play_dialog( level.plr_vox["kill"]["thundergun"], .25, level.plr_vox["kill"]["thundergun_response"] );
// 		}
// 	}
// }


//	Read a value from a table and set the related level.zombie_var
//
set_zombie_var( var, value, is_float, column )
{
	if ( !IsDefined( is_float ) )
	{
		is_float = false;
	}
	if ( !IsDefined(column) )
	{
		column = 1;
	}

	// First look it up in the table
	table = "mp/zombiemode.csv";
	table_value = TableLookUp( table, 0, var, column );

	if ( IsDefined( table_value ) && table_value != "" )
	{
		if( is_float )
		{
			value = float( table_value );
		}
		else
		{
			value = int( table_value );
		}
	}

	level.zombie_vars[var] = value;
	return value;
}


