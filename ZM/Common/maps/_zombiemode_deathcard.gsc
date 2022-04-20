#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include animscripts\zombie_Utility;

//-----------------------------------------------------------------------------------
// setup the deathcards in the level
//-----------------------------------------------------------------------------------
init()
{
	flag_wait( "all_players_connected" );

	// create deathcard for each player
	players = get_players();

	if ( players.size > 0 )
	{
		for ( i = 0; i < players.size; i++ )
		{
			level.deathcards[i] = SpawnStruct();
		}

		//SetDvar( "player_lastStandBleedoutTime", "3" );

		// setup func pointers
		level.deathcard_laststand_func = ::deathcard_laststand;

		if ( players.size > 1 )
		{
			level.deathcard_spawn_func = ::deathcard_spawn;
		}
	}
}

//-----------------------------------------------------------------------------------
// place deathcard in level when player dies
//-----------------------------------------------------------------------------------
deathcard_spawn()
{
	dc = Spawn( "script_model", self.origin + ( 0, 0, 40 ) );
	dc.angles = self.angles;
	//deathcard SetModel( "tag_origin" );

	//playfxontag(level._effect["powercell"],dc,"tag_origin");
	dc SetModel( "zombie_revive" );

	dc.player = self;

	dc thread deathcard_timeout();
	dc thread deathcard_wobble();
	dc thread deathcard_grab();
	
	// The player gets pro tip message to pick up their death card on the next round
	self.pro_tip_death_card_round = level.round_number + 1;
}

//-----------------------------------------------------------------------------------
// save player weapon info, score, etc in the deathcard
//-----------------------------------------------------------------------------------
deathcard_laststand()
{
	players = get_players();
	
	// solo player gets everything back
	if ( players.size == 1 )
	{
		dc = level.deathcards[0];
		dc.player = self;
		dc.weapon = [];
		dc.score = self.score;

		primaries = self GetWeaponsListPrimaries();
		dc.weapon[0] = primaries[0];
		dc.current_weapon = 0;
		if ( primaries.size > 1 )
		{
			dc.weapon[1] = primaries[1];
			currentWeapon = self GetCurrentWeapon();
			if ( currentWeapon == dc.weapon[1] )
			{
				dc.current_weapon = 1;
			}
		}
		//dc.abilities = self.abilities;
		dc.curr_ability = self.curr_ability;

		if ( maps\_zombiemode_weap_cymbal_monkey::cymbal_monkey_exists() )
		{
			dc.zombie_cymbal_monkey_count = self getweaponammoclip( "zombie_cymbal_monkey" );
		}
	}
	else
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( players[i] == self )
			{
				dc = level.deathcards[i];
				dc.player = self;

				dc.weapon = [];
				dc.current_weapon = -1;

				// save 1/2 score
				dc.score = int( self.score * 0.5 );

				primaries = self GetWeaponsListPrimaries();

				// default weapon is never put in a deathcard
				if ( primaries[0] == "m1911_zm" )
				{
					dc.weapon[0] = "none";
				}
				else
				{
					// save weapons and 1/2 stock
					dc.weapon[0] = primaries[0];
					stock = self GetWeaponAmmoStock( primaries[0] );
					dc.stockCount[0] = int( stock * 0.5 );
					dc.current_weapon = 0;
				}

				if ( primaries.size > 1 )
				{
					// default weapon is never put in a deathcard
					if ( primaries[1] == "m1911_zm" )
					{
						dc.weapon[1] = "none";
					}
					else
					{
						dc.weapon[1] = primaries[1];
						stock = self GetWeaponAmmoStock( primaries[1] );
						dc.stockCount[1] = int( stock * 0.5 );

						currentWeapon = players[i] GetCurrentWeapon();
						if ( currentWeapon == dc.weapon[1] )
						{
							dc.current_weapon = 1;
						}
						else
						{
							dc.current_weapon = 0;
						}
					}
				}
				else
				{
					dc.weapon[1] = "none";
				}

				// save perks
				dc.perk = deathcard_save_perks( self );
				//dc.abilities = self.abilities;
				dc.curr_ability = self.curr_ability;

				if ( maps\_zombiemode_weap_cymbal_monkey::cymbal_monkey_exists() )
				{
					dc.zombie_cymbal_monkey_count = self getweaponammoclip( "zombie_cymbal_monkey" );
				}
			}
		}
	}
}

//-----------------------------------------------------------------------------------
// 
//-----------------------------------------------------------------------------------
deathcard_save_perks( ent )
{
	idx = 0;
	perk_array = undefined;
	if ( ent HasPerk( "specialty_armorvest" ) )
	{
		perk_array[idx] = "specialty_armorvest";
		idx++;
	}
	else if ( ent HasPerk( "specialty_armorvest_upgrade" ) )
	{
		perk_array[idx] = "specialty_armorvest_upgrade";
		idx++;
	}
	if ( ent HasPerk( "specialty_quickrevive" ) )
	{
		perk_array[idx] = "specialty_quickrevive";
		idx++;
	}
	else if ( ent HasPerk( "specialty_quickrevive_upgrade" ) )
	{
		perk_array[idx] = "specialty_quickrevive_upgrade";
		idx++;
	}
	if ( ent HasPerk( "specialty_fastreload" ) )
	{
		perk_array[idx] = "specialty_fastreload";
		idx++;
	}
	else if ( ent HasPerk( "specialty_fastreload_upgrade" ) )
	{
		perk_array[idx] = "specialty_fastreload_upgrade";
		idx++;
	}
	//if ( ent HasPerk( "specialty_rof" ) )
	//{
	//	perk_array[idx] = "specialty_rof";
	//	idx++;
	//}
	return( perk_array );
}

//-----------------------------------------------------------------------------------
// wait for player to get deathcard
//-----------------------------------------------------------------------------------
deathcard_grab()
{
	self endon( "deatchcard_timedout" );

	wait( 1 );

	while ( isdefined( self ) )
	{
		players = get_players();

		for ( i = 0; i < players.size; i++ )
		{
			if ( players[i].is_zombie )
			{
				continue;
			}

			if ( players[i] == self.player )
			{
				dist = distance( players[i].origin, self.origin );
				if ( dist < 64 )
				{
					playfx( level._effect["powerup_grabbed"], self.origin );
					playfx( level._effect["powerup_grabbed_wave"], self.origin );

					players[i] deathcard_give( i );

					wait( 0.1 );

					playsoundatposition("zmb_powerup_grabbed_3p", self.origin);
					self stoploopsound();

					self delete();
					self notify( "deathcard_grabbed" );
					players[i] clientnotify( "dc0" );	// play death card sound				
				}
			}
		}

		wait_network_frame();
	}
}

//-----------------------------------------------------------------------------------
// give back weapons, perks, money, etc...
//-----------------------------------------------------------------------------------
deathcard_give( index )
{
	dc = level.deathcards[index];

	if ( dc.current_weapon >= 0 )
	{
		weapon = undefined;
		stock = 0;
		needSwitch = false;

		// try to give back the weapon player was holding 
		if ( dc.weapon[dc.current_weapon] != "none" && !self HasWeapon( dc.weapon[dc.current_weapon] ) )
		{
			weapon = dc.weapon[dc.current_weapon];
			stock = dc.stockCount[dc.current_weapon];
			needSwitch = true;
		}
		else
		{
			for ( i = 0; i < 2; i++ )
			{
				if ( dc.current_weapon == i || dc.weapon[i] == "none" )
				{
					continue;
				}

				if ( !self HasWeapon( dc.weapon[i] ) )
				{
					weapon = dc.weapon[i];
					stock = dc.stockCount[i];
				}
			}
		}

		// actually have something to give
		if ( IsDefined( weapon ) )
		{
			primaries = self GetWeaponsListPrimaries();
			if ( primaries.size >= 2 )
			{
				takeWeapon = undefined;

				// always take default if the player has it and another
				if ( primaries[0] == "m1911_zm" || primaries[1] == "m1911_zm" )
				{
					takeWeapon = "m1911_zm";
				}
				else
				{
					takeWeapon = self GetCurrentWeapon();
				}

				self TakeWeapon( takeWeapon );
			}

			self GiveWeapon( weapon, 0 );

			self SetWeaponAmmoClip( weapon, WeaponClipSize( weapon ) );
			self SetWeaponAmmoStock( weapon, stock );

			if ( needSwitch )
			{
				self SwitchToWeapon( weapon, 0 );
			}
		}
	}
	// don't give points back
	// score
	//self.old_score += dc.score; 
	//self.score += dc.score;

	// perks
	if ( IsDefined( dc.perk ) )
	{
		oldPerks = dc.perk.size;
		if ( oldPerks >= 2 )
		{
			newPerks = int( oldPerks * 0.5 );

			for ( i = 0; i < dc.perk.size; i++ )
			{
				if ( self HasPerk( dc.perk[i] ) )
				{
					continue;
				}

				remaining = dc.perk.size - i;
				if ( remaining <= newPerks || RandomInt( 100 ) > 50 )
				{
					maps\_zombiemode_perks::give_perk( dc.perk[i] );
					newPerks--;
				}

				if ( newPerks == 0 )
				{
					break;
				}
			}
		}
	}

	// abilities
	//if ( IsDefined( dc.curr_ability ) )
	//{
	//	self maps\_zombiemode_ability::giveAbility( dc.curr_ability );
	//	self maps\_zombiemode_ability::update_player_ability_status();
	//}

	if ( maps\_zombiemode_weap_cymbal_monkey::cymbal_monkey_exists() )
	{
		if ( dc.zombie_cymbal_monkey_count )
		{
			self giveweapon( "zombie_cymbal_monkey" );
			self setweaponammoclip( "zombie_cymbal_monkey", dc.zombie_cymbal_monkey_count );
		}
	}
}

//-----------------------------------------------------------------------------------
// solo player gets both weapons back and only loses 1 perk
//-----------------------------------------------------------------------------------
deathcard_give_solo()
{
	dc = level.deathcards[0];

	// perks
	self maps\_zombiemode::laststand_giveback_player_perks();

	take = true;
	startWeapon = dc.weapon[dc.current_weapon];
	if ( startWeapon == "m1911_zm" )
	{
		take = false;
	}

	currentWeapon = self GetCurrentWeapon();
	if ( currentWeapon != "none" && take )
	{
		self TakeWeapon( currentWeapon );
	}

	for ( i = 0; i < 2; i++ )
	{
		if ( IsDefined( dc.weapon[i] ) )
		{
			weapon = dc.weapon[i];
			if ( weapon != "m1911_zm" || take )
			{
				self GiveWeapon( weapon, 0 );
				self SetWeaponAmmoClip( weapon, WeaponClipSize( weapon ) );

				self GiveStartAmmo( weapon );
			}
		}
	}

	if ( dc.current_weapon >= 0 && take )
	{
		self SwitchToWeapon( dc.weapon[dc.current_weapon], 0 );
	}

	// score
	//self.old_score += dc.score;
	//self.score += dc.score;

	// abilities
	//if ( IsDefined( dc.curr_ability ) )
	//{
	//	self maps\_zombiemode_ability::giveAbility( dc.curr_ability );
	//	self maps\_zombiemode_ability::update_player_ability_status();
	//}

	if ( maps\_zombiemode_weap_cymbal_monkey::cymbal_monkey_exists() )
	{
		if ( dc.zombie_cymbal_monkey_count )
		{
			self giveweapon( "zombie_cymbal_monkey" );
			self setweaponammoclip( "zombie_cymbal_monkey", dc.zombie_cymbal_monkey_count );
		}
	}
}

//-----------------------------------------------------------------------------------
// bounce the deathcard around
//-----------------------------------------------------------------------------------
deathcard_wobble()
{
	self endon ("deathcard_grabbed");
	self endon ("deathcard_timedout");

	if (isdefined(self))
	{
		playfxontag (level._effect["powerup_on"], self, "tag_origin");
		self playsound("zmb_spawn_powerup");
		self playloopsound("evt_death_card_loop");
	}

	while (isdefined(self))
	{
		self rotateyaw( 360, 3, 3, 0 );
		wait( 3 );
	}
}

//-----------------------------------------------------------------------------------
// time out after end of round
//-----------------------------------------------------------------------------------
deathcard_timeout()
{
	self endon ("deathcard_grabbed");

	level waittill( "between_round_over" );
	wait( 1 );
	level waittill( "between_round_over" );

	//wait 75;
	self hide();

	/*
	for (i = 0; i < 40; i++)
	{
		// hide and show
		if (i % 2)
		{
			self hide();
		}
		else
		{
			self show();
		}

		if (i < 15)
		{
			wait 0.5;
		}
		else if (i < 25)
		{
			wait 0.25;
		}
		else
		{
			wait 0.1;
		}
	}
	*/

	self notify ("deathcard_timedout");
	self delete();
}





