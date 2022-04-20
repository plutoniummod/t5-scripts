#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\_zombiemode_utility_raven;

main()
{		
	/#
	//level thread init_save_game();
	#/
	
	/#
	execdevgui( "devgui_zombie_temple" );
	level.custom_devgui = ::zombie_temple_devgui;
	
	level thread show_zombie_health();
	#/
}

/#
init_save_game()
{
	if( GetDvar( #"createfx" ) != "" )
	{
		return;
	}
	
	level.saveGameRoundStart = false;
	level thread save_game_round_start();
		
	level.saveGameVersion = 10;
 	level.saveGameFile = "zombiesavegame.txt";
	level.saveGameHeaderSize = 5;
	level.saveGamePerkOrder = array("specialty_armorvest","specialty_quickrevive","specialty_fastreload","specialty_rof","specialty_longersprint","specialty_flakjacket","specialty_deadshot");
	flag_wait( "all_players_connected" );
	
	wait 1;
	
	//Read in existing save game
	level.saveGames = [];
	file = openfile(level.saveGameFile, "read");
	if(file>=0)
	{
		lineNum = 1;
		args = freadln(file);
		while(args>1) //Need at least 2 args for valid save game
		{
			sg = spawnStruct();
			sg.version = fgetarg(file,0);
			sg.date = fgetarg(file,1);
			sg.mapname = fgetarg(file,2);
			sg.round = int(fgetarg(file,3));
			sg.numPlayers = int(fgetarg(file,4));
			sg.line = lineNum;
			sg.data = [];	//No need to parse this till we know we are loading a save game

			//Only display valid save games
			if(sg.numPlayers == get_players().size && int(sg.version) == level.saveGameVersion && sg.mapname == GetDvar("mapname"))
			{
				level.saveGames[level.saveGames.size] = sg;
			}
			
			lineNum++;
			args = freadln(file);
		}
		closefile(file);
	}
	
	player0 = get_players()[0];

	//have user select save game
	if(level.saveGames.size>0)
	{
		saveGameHud1 = maps\_hud_util::createFontString( "Objective", 2.0 );
		saveGameHud1.y = -20;
		saveGameHud1.alignX = "center";
		saveGameHud1.alignY = "middle";
		saveGameHud1.horzAlign = "center";
		saveGameHud1.vertAlign = "middle";
				
		saveGameHud2 = maps\_hud_util::createFontString( "Objective", 2.0 );
		saveGameHud2.y = 0;
		saveGameHud2.alignX = "center";
		saveGameHud2.alignY = "middle";
		saveGameHud2.horzAlign = "center";
		saveGameHud2.vertAlign = "middle";
	
		saveGameHud1 settext("Use D-PAD to select save game (Host Only)");
		saveGameHud2 setText("A: Select B: Cancel");
		
		
		//Wait for player input
		player0 freezecontrols( true );
		saveSlot = undefined;
		while(1)
		{
			buttonPressed = undefined;
			if(player0 buttonPressed( "BUTTON_A" ))
			{
				//load save game
				buttonPressed = "BUTTON_A";
				if(isDefined(saveSlot))
				{
					if(!level.saveGameRoundStart)
					{
						savegameHud2 setText("Loading...");
						while(!level.saveGameRoundStart)
						{
							wait .1;
						}		
					}
					load_save_game(saveSlot);
					break;
				}
			}
			else if(player0 buttonPressed( "BUTTON_B" ))
			{
				buttonPressed = "BUTTON_B";
				break;
			}
			else if(player0 ButtonPressed( "DPAD_UP" ))
			{	
				buttonPressed = "DPAD_UP";
				if(!isDefined(saveSlot))
				{
					saveSlot = level.saveGames.size-1;
				}
				else
				{
					saveSlot--;
					if(saveSlot<0)
					{
						saveSlot = level.saveGames.size-1;
					}
				}
				
				saveGameHud1 set_save_game_text(saveSlot);
				
			}
			else if(player0 ButtonPressed( "DPAD_DOWN" ))
			{
				buttonPressed = "DPAD_DOWN";
				if(!isDefined(saveSlot))
				{
					saveSlot = 0;
				}
				else
				{
					saveSlot++;
					if(saveSlot>=level.saveGames.size)
					{
						saveSlot = 0;
					}
				}
				
				saveGameHud1 set_save_game_text(saveSlot);
			}
			
			//wait for button to not be pressed
			if(isdefined(buttonPressed))
			{
				while(player0 ButtonPressed( buttonPressed ))
				{
					wait .05;
				}
			}
			wait .05;
		}
		
		player0 freezecontrols( false );
		savegameHud1 Destroy();
		savegameHud2 Destroy();
	}
	
	
	
	
	//Watch for new rounds so a new save game can be written out
	level thread save_game_at_round_start();
}

save_game_round_start()
{
	level waittill("start_of_round");
	level.saveGameRoundStart = true;
}

save_game_get_doors()
{
	zombie_doors = GetEntArray( "zombie_door", "targetname" ); 
	
	return zombie_doors;
}
save_game_get_debris()
{
	zombie_debris = GetEntArray( "zombie_debris", "targetname" );
	
	return zombie_debris;
}

set_save_game_text(slot)
{
	sg = level.saveGames[slot];
	self setText(string(slot+1) + ") " + sg.date + " - Round " + (sg.round+1) + " - Players " + sg.numPlayers);
}
load_game_read_data()
{
	dataRead = false;
	file = openfile(level.saveGameFile, "read");
	if(file>=0)
	{
		lineNum = 1;
		args = freadln(file);
		while(args>1) //Need at least 2 args for valid save game
		{
			if(self.line == lineNum)
			{
				for(i=level.saveGameHeaderSize;i<args;i++)
				{
					self.data[self.data.size] = fgetarg(file,i);
				}
				dataRead = true;
				break;
			}
			
			lineNum++;
			args = freadln(file);
		}
		closefile(file);
	}
	return dataRead;
}

load_save_game(slot)
{
	sg = level.saveGames[slot];
	
	//Read in the rest of the save game;
	if(sg.data.size == 0)
	{
		if(!sg load_game_read_data())
		{
			return;
		}
	}

	//Set Round Num
	thread save_game_set_round(sg.round);
	
	//Set players origin,angles
	players = get_players();
	offset = 0;
	for(i=0;i<sg.numPlayers;i++)
	{
		p = players[i];
		
		//Restore origin and angles
		origin = (float(sg.data[offset+0]),float(sg.data[offset+1]),float(sg.data[offset+2]));
		angles = (float(sg.data[offset+3]), float(sg.data[offset+4]), float(sg.data[offset+5]));
		
		if(i<players.size)
		{
			p SetOrigin( origin );
			p SetPlayerAngles( angles );
		}
		offset += 6;
		
		//Restore all weapons
		p TakeAllWeapons();
		
		weaponCount = int(sg.data[offset]);
		offset += 1;
		for(j=0;j<weaponCount;j++)
		{
			weapon = sg.data[offset];
			p giveweapon(weapon, 0, p maps\_zombiemode_weapons::get_pack_a_punch_weapon_options( weapon ));
			p SetWeaponAmmoClip(weapon, int(sg.data[offset+1]));
			p SetWeaponAmmoStock(weapon, int(sg.data[offset+2]));
			
			isBowie = weapon == "bowie_knife_zm";
			if(isBowie || weapon == "knife_zm")
			{
				p set_player_melee_weapon( weapon );
				if(isBowie)
				{
					p._bowie_zm_equipped = 1;
				}
				else
				{
					p._bowie_zm_equipped = undefined;
				}
			}
			
			if(weapon == "zombie_cymbal_monkey")
			{
				p set_player_tactical_grenade( weapon );
				p thread maps\_zombiemode_weap_cymbal_monkey::player_handle_cymbal_monkey();
			}
			
			if(weapon == "spikemore_zm")
			{
				p thread maps\_zombiemode_spikemore::spikemore_setup();
			}
			
			offset += 3;
		}
		
		//Set weapon selection
		currentWeapon = sg.data[offset];
		offset += 1;
		p SwitchToWeapon( currentWeapon );
		
		//Restore Perks
		for(j=0;j<level.saveGamePerkOrder.size;j++)
		{
			if(int(sg.data[offset]))
			{	
				p maps\_zombiemode_perks::give_perk(level.saveGamePerkOrder[j]);
			}
			offset += 1;
		}
		
		//Restore score
		p.score = int(sg.data[offset]);
		offset += 1;
		
		//Restore stats
		p.kill_tracker = int(sg.data[offset+0]);
		p.kills = p.kill_tracker;
		p.stats["kills"] = p.kill_tracker;
		p.score_total = int(sg.data[offset+1]);
		p.stats["score"] = p.score_total;
		p.downs = int(sg.data[offset+2]);
		p.stats["downs"] = p.downs;
		p.revives = int(sg.data[offset+3]);
		p.stats["revives"] = p.revives;
		p.stats["perks"] = int(sg.data[offset+4]);
		p.headshot_count = int(sg.data[offset+5]);
		p.headshots = p.headshot_count;
		p.stats["headshots"] = p.headshot_count;
		p.stats["zombie_gibs"] = int(sg.data[offset+6]);
		p.stats["damage_taken"] = int(sg.data[offset+7]);
		p.stats["distance_traveled"] = int(sg.data[offset+8]);
		offset+=9;
	}
	
	//Turn on if needed;
	powerOn = int(sg.data[offset]);
	offset += 1;
	if(powerOn>0)
	{
		flag_set("power_on");
	}
	
	//Restor Door states
	doors = save_game_get_doors();
	numDoors = int(sg.data[offset]);
	offset += 1;
	
	for(i=0;i<numDoors;i++)
	{
		if(int(sg.data[offset]))
		{
			doors[i] thread save_game_open_door();
		}
		offset += 1;
	}
	
	//Restore debris - Needs to be done different then doors because debris deletes triggers
	debris = save_game_get_debris();
	numDebris = int(sg.data[offset]);
	offset += 1;
	
	//List of all door flags that were not set when the game saved
	debrisFlags = [];
	for(i=0;i<numDebris;i++)
	{
		debrisFlags[debrisFlags.size] = sg.data[offset];
		offset += 1;
	}
	
	//Check un set flags vs all debris in the level.
	for(i=0;i<debris.size;i++)
	{
		debrisFlag = debris[i].script_flag;
		if(!isdefined(debrisFlag))
		{
			continue;
		}
		
		openDebris = true;
		for(j=0;j<debrisFlags.size;j++)
		{
			if(debrisFlag == debrisFlags[j])
			{
				openDebris = false;
				break;
			}
		}
		//If the flag was not if the save game the door must be open
		if(openDebris)
		{
			debris[i] thread save_game_open_debris();
		}
	}
	
	//Set Magic Box location
	chest_index = int(sg.data[offset]);
	offset += 1;
	
	chests = GetEntArray( "treasure_chest_use", "targetname" );
	for(i=0;i<level.chests.size;i++)
	{
		if(chests[chest_index] == level.chests[i])
		{
			save_game_move_chest(i);
			break;
		}
	}
	
	//Init level vars
	level.chest_moves = int(sg.data[offset]);
	offset+=1;
	
	level.nextSonicSpawnRound = int(sg.data[offset]);
	offset+=1;
	
	level.nextNapalmSpawnRound = int(sg.data[offset]);
	offset+=1;
	
	level.zombie_vars["zombie_powerup_drop_increment"] = float(sg.data[offset]);
	offset+=1;
}
save_game_move_chest(new_location)
{
	level.chests[level.chest_index] setvisibletoall();
	level.chests[level.chest_index] maps\_zombiemode_weapons::hide_chest();

	level.chest_index = new_location;
	level.chests[level.chest_index] maps\_zombiemode_weapons::show_chest();
	level.chests[level.chest_index] maps\_zombiemode_weapons::hide_rubble();
}
save_game_open_door()
{
	// Set any flags called
	if( IsDefined( self.script_flag ) )
	{
		tokens = Strtok( self.script_flag, "," );
		for ( i=0; i<tokens.size; i++ )
		{
			flag_set( tokens[i] );
		}
	}

	// Door has been activated, make it do its thing
	for(i=0;i<self.doors.size;i++)
	{
		// Don't thread this so the doors don't move at once
		self.doors[i] maps\_zombiemode_blockers::door_activate();
	}

	// get all trigs for the door, we might want a trigger on both sides
	// of some junk sometimes
	all_trigs = getentarray( self.target, "target" ); 
	for( i = 0; i < all_trigs.size; i++ )
	{
		all_trigs[i] trigger_off(); 
	}
}
save_game_open_debris()
{
	// delete the stuff
	junk = getentarray( self.target, "targetname" ); 

	// Set any flags called
	if( IsDefined( self.script_flag ) )
	{
		tokens = Strtok( self.script_flag, "," );
		for ( i=0; i<tokens.size; i++ )
		{
			flag_set( tokens[i] );
		}
	}

	move_ent = undefined;
	clip = undefined;
	for( i = 0; i < junk.size; i++ )
	{	
		junk[i] connectpaths();

		if( IsDefined( junk[i].script_noteworthy ) )
		{
			if( junk[i].script_noteworthy == "clip" )
			{
				clip = junk[i];
				continue;
			}
		}

		struct = undefined;
		if( IsDefined( junk[i].script_linkTo ) )
		{
			struct = getstruct( junk[i].script_linkTo, "script_linkname" );
			if( IsDefined( struct ) )
			{
				move_ent = junk[i];
				junk[i] thread maps\_zombiemode_blockers::debris_move( struct );
			}
			else
			{
				junk[i] Delete();
			}
		}
		else
		{
			junk[i] Delete();
		}
	}
	
	// get all trigs, we might want a trigger on both sides
	// of some junk sometimes
	all_trigs = getentarray( self.target, "target" ); 
	for( i = 0; i < all_trigs.size; i++ )
	{
		all_trigs[i] delete(); 
	}

	if( IsDefined( clip ) )
	{
		if( IsDefined( move_ent ) )
		{
			move_ent waittill( "movedone" );
		}

		clip Delete();
	}
}
save_game_set_round(round)
{
	player = get_players()[0];

	level.zombie_total = 0;
	maps\_zombiemode::ai_calculate_health( round );
	level.round_number = round;

	level notify( "kill_round" );
	
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

save_game_at_round_start()
{
	while(1)
	{
		level waittill( "end_of_round" );
		file = openfile(level.saveGameFile, "append");
		if(file>=0)
		{
			//Save game version number
			header = string(level.saveGameVersion) + ",";
				
			//write out date
			header += GetDate() + ",";
			
			//map name
			header += GetDvar("mapname") + ",";
			
			//Round
			header += level.round_number + ",";
			
			//Number of players;
			players = get_players();
			header += string(players.size); //Last part of a chunk shouldn't have a comma
			
			//Write out each players info
			pSave = [];
			for(i=0;i<players.size;i++)
			{
				p = players[i];
				
				//Write out origin
				origin = p getorigin();
				pSave[i] = "" + origin[0] + "," + origin[1] + "," + origin[2] + ",";
				
				//Write out Angles
				angles = p.angles;
				pSave[i] += "" + angles[0] + "," + angles[1] + "," + angles[2] + ",";
				
				//write out weapons and ammo
				weapons = p GetWeaponsList();
				pSave[i] += string(weapons.size) + ",";
				
				for(j=0;j<weapons.size;j++)
				{
					pSave[i] += weapons[j] + ",";
					pSave[i] += p GetWeaponAmmoClip(weapons[j]) + ",";
					pSave[i] += p GetWeaponAmmoStock(weapons[j]) + ",";
				}
				
				//Save curret weapon selection
				pSave[i] += p GetCurrentWeapon()+ ",";
				
				//save out perks
				for(j=0;j<level.saveGamePerkOrder.size;j++)
				{
					pSave[i] += p HasPerk(level.saveGamePerkOrder[j])+ ",";
				}
				
				//write out score
				pSave[i] += string(p.score) + ",";
				
				//Write out stats
				pSave[i] += string(p.stats["kills"]) + ",";
				pSave[i] += string(p.stats["score"]) + ",";
				pSave[i] += string(p.stats["downs"]) + ",";
				pSave[i] += string(p.stats["revives"]) + ",";
				pSave[i] += string(p.stats["perks"]) + ",";
				pSave[i] += string(p.stats["headshots"]) + ",";
				pSave[i] += string(p.stats["zombie_gibs"]) + ",";
				pSave[i] += string(p.stats["damage_taken"]) + ",";
				pSave[i] += string(p.stats["distance_traveled"]); //Last part of a chunk shouldn't have a comma
			}
			
			//Write out power
			lSave = string(flag("power_on")) + ",";
			
			//Write out doors
			doors = save_game_get_doors();
			lSave += string(doors.size) + ",";
			
			for(i=0;i<doors.size;i++)
			{
				if(isDefined(doors[i].script_flag))
				{
					lSave += string(flag(doors[i].script_flag)) + ",";
				}
				else
				{
					lSave += ",";
				}
			}
			
			//Write out debris - Debris works diffrent then doors because debris deletes the trigger :(
			debris = save_game_get_debris();
			
			debrisFlags = [];
			
	
			for(i=0;i<debris.size;i++)
			{
				//TODO: Handle multiple flags
				flag = debris[i].script_flag;
				if(isDefined(flag) && !is_in_array(debrisFlags,flag) )
				{
					debrisFlags[debrisFlags.size] = flag;
				}
			}
			lSave += string(debrisFlags.size) + ",";
			for(i=0;i<debrisFlags.size;i++)
			{
				lSave += debrisFlags[i] + ",";
			}
			
			//Write out chest location
			chests = GetEntArray( "treasure_chest_use", "targetname" );
			for(i=0;i<chests.size;i++)
			{
				if(chests[i] == level.chests[level.chest_index])
				{
					lSave += string(i) + ",";
					break;
				}
			}
			
			//Number of chest moves
			lSave += string(level.chest_moves) + ",";
			
			//Special AI
			lSave += string(level.nextSonicSpawnRound) + ",";
			lSave += string(level.nextNapalmSpawnRound) + ",";
			
			//
			lSave += string(level.zombie_vars["zombie_powerup_drop_increment"]); //Last part of a chunk shouldn't have a comma
			
			if(pSave.size == 4)
			{
				fprintfields(file, header, pSave[0], pSave[1], pSave[2], pSave[3], lSave);
			}
			else if (pSave.size == 3)
			{
				fprintfields(file, header, pSave[0], pSave[1], pSave[2], lSave);
			}
			else if (pSave.size == 2)
			{
				fprintfields(file, header, pSave[0], pSave[1], lSave);
			}
			else // if (pSave.size == 1)
			{
				fprintfields(file, header, pSave[0], lSave);
			}
				
			closefile(file);
		}
	}
}
#/

//Dev gui
zombie_temple_devgui( cmd )
{
/#
	cmd_strings = strTok(cmd, " ");
	switch( cmd_strings[0] )
	{
		case "spawn":
			player = get_players()[0];
			spawnerClass = cmd_strings[1];

			//Spawn AI
			//--------
			spawners = getEntArray(spawnerClass, "classname");
			if(!isDefined(spawners) || spawners.size == 0 )
			{
				return;
			}
			
			//Need to make sure we grabbed a spawner and not a live ai
			spawnerNum=0;
			while(spawners[spawnerNum].spawnflags%2 == 0)
			{
				spawnerNum++;
			}
			//Didn't find a valid spawner
			if(spawnerNum>=spawners.size)
			{
				return;
			}
			
			spawner = spawners[spawnerNum];
			
			guy = spawner CodespawnerForceSpawn();
			guy.favoriteEnemy = player;
			guy.script_string = "zombie_chaser";
			guy.target = "";
			spawner.count++;
			
			//Trace to find where the player is looking
			//-----------------------------------------
			direction = player GetPlayerAngles();
			direction_vec = AnglesToForward( direction );
			eye = player GetEye();

			scale = 8000;
			direction_vec = (direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale);
			trace = bullettrace( eye, eye + direction_vec, 0, undefined );
			
			originOffset = (0,0,0);
//			if(spawnerClass=="actor_zombie_napalm" || spawnerClass=="actor_zombie_sonic")
//			{
//				originOffset = (0,0,-32);
//			}

			//Teleport to where the player is looking
			//---------------------------------------
			if(isdefined(guy))
			{
				teleportOrigin = trace["position"] + originOffset;
				guy forceteleport(teleportOrigin, player.angles + (0,180,0));	
				guy thread _zombie_DelaySetHealth(0.5);
			}
			
			break;
			
		case "openDoors":
			level thread open_all_doors();
			break;
		case "removeBoards":
			level thread remove_all_boards();
			break;
		default:
			break;

	}
#/
}

/#
show_zombie_health()
{
	rightscale = 30;
	while(1)
	{
		dvar_value = getDebugDvarInt( "show_zombie_health" );
		if(dvar_value == 0)
		{
			level notify("stop_zombie_show_health");
			wait .25;
			continue;
		}
		
		zombies = GetAIArray( "axis" );
		for(i=0;i<zombies.size;i++)
		{
			zombie = zombies[i];
			
			zombie thread zombie_record_damage_history();
			
			text = "" + zombie.health + "/" + zombie.maxhealth;
			
			right = anglestoright(zombie.angles);
			right = vector_scale(right, (text.size / 2) * 2.6); //Roughly center text
			up = (0,0,70);
			
			color = (0,1,0); //Green
			historySize = zombie.damageHistory.size;
			if(historySize>0 && zombie.damageHistory[historySize-1].time+1000>GetTime())
			{
				color = (1,0,0); //red
			}
			
			print3d( zombie.origin+right+up, text, color, 1, .25 );
			
			//Print damage history
			k=0;
			for(j=zombie.damageHistory.size-1; j>=0 && k<dvar_value-1; j--)
			{
				up = up + (0,0,-4);
				print3d( zombie.origin+right+up, zombie.damageHistory[j].text, color, 1, .25 );
				k++;
			}
		
			
		}
		wait( 0.05 );
	}
}

zombie_record_damage_history()
{
	level endon("stop_zombie_show_health");
	self endon("death");
	
	if(is_true(self.record_damage_time_active))
	{
		return;
	}
	
	self.damageHistory = [];
	self.record_damage_time_active = true;
	while(1)
	{
		self waittill("damage", damage, attacker, direction, point, type );
		
		s 			= spawnStruct();
		s.time 		= GetTime();
		s.damage 	= damage;
		s.attacker	= attacker;
		s.type		= type;
		s.loc		= self.damageLocation;
		s.text		= "-" + damage + " " + self.damageLocation + " " + type;
		
		self.damageHistory[self.damageHistory.size] = s;
	}
}
#/

_zombie_DelaySetHealth(delay)
{
	self endon("death");
	if ( !IsDefined(delay) )
	{
		delay = 0.5;
	}

	wait(delay);
	health = 2000;
	self.maxhealth = health; 
	self.health = health;
}

/#
open_all_doors()
{
	doorTriggers = getEntArray("zombie_door", "targetname");
	

	for(i=0;i<doorTriggers.size;i++)
	{
		trigger = doorTriggers[i];
		if(!isdefined(trigger.doors))
		{
			continue;
		}
		
		for(j=0;j<trigger.doors.size;j++)
		{
			
			trigger.doors[j] maps\_zombiemode_blockers::door_activate();
		}
	}	
}

remove_all_boards()
{
	for( i = 0; i < level.exterior_goals.size; i++ )
	{
		goal = level.exterior_goals[i];
		
		if(!isDefined(goal.barrier_chunks))
		{
			continue;
		}
		
		for(j=0; j<goal.barrier_chunks.size;j++)
		{
			chunk = goal.barrier_chunks[j];
			
			chunk maps\_zombiemode_blockers::update_states("destroyed");
			chunk.destroyed = true;
			chunk Hide();
			chunk notSolid();
			chunk notify("destroyed");
		}
		wait .1; //so we don't overload the snapshot
	}
}
#/
/////////////////////////////////////////////////////////////////////////////////////////////