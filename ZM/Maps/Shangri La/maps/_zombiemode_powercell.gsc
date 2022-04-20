#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include animscripts\zombie_Utility;

//-----------------------------------------------------------------------------------
// setup the powercells in the level
//-----------------------------------------------------------------------------------
init()
{
	level.powercells = GetEntArray( "powercell_pickup", "targetname" );

	if ( level.powercells.size == 0 )
	{
		/#
			iprintln( "No powercells found" );
		#/
		return;
	}
	else
	{
		for ( i = 0; i < level.powercells.size; i++ )
		{
			level.powercells[i] thread powercell_init();
		}
	}

	level thread powercell_init_hud();
	level thread powercell_init_dropoff();
	level thread test();

	if ( IsDefined( level.powercell_init_func ) )
	{
		[[ level.powercell_init_func ]]();
	}
}

test()
{
}

//-----------------------------------------------------------------------------------
// precache models, materials, etc
//-----------------------------------------------------------------------------------
powercell_precache()
{
	PrecacheShader( "zom_pack_a_punch_battery_icon" );
}

//-----------------------------------------------------------------------------------
// setup trigger to pick up a powercell
//-----------------------------------------------------------------------------------
powercell_init()
{
	self.trigger = GetEnt( self.target, "targetname" );

	if ( !IsDefined( self.trigger ) )
	{
		/#
			iprintln( "No trigger associated with powercell" );
		#/
		return;
	}

	self.trigger SetHintString( &"ZOMBIE_POWERCELL_PICKUP" );
	self.trigger SetCursorHint( "HINT_NOICON" );

	self thread powercell_wait();
}

//-----------------------------------------------------------------------------------
// waits for a powercell to be picked up by a player
//-----------------------------------------------------------------------------------
powercell_wait()
{
	// start the fx
	self thread powercell_fx();

	self.trigger UseTriggerRequireLookAt();

	for ( ;; )
	{
		self.trigger waittill( "trigger", user );

		if ( !user.powercellEquipped )
		{
			self.trigger trigger_off();
			self hide();
			
			self thread play_sound_on_entity( "zmb_power_cell_pickup" );
			
			user powercell_pickup( self );
			break;
		}
		else
		{
			play_sound_on_ent( "no_purchase" );
		}
	}
}

//-----------------------------------------------------------------------------------
// glow to help players find the powercell
//-----------------------------------------------------------------------------------
powercell_fx()
{
	self.fx = Spawn( "script_model", self.origin );
	self.fx.angles = self.angles;
	self.fx SetModel( "tag_origin" );

	playfxontag(level._effect["powercell"],self.fx,"tag_origin");

	self waittill( "powercell_picked_up" );
	self.fx delete();
}

//-----------------------------------------------------------------------------------
// puts powercell model and trigger back in the level 
//-----------------------------------------------------------------------------------
powercell_replace()
{
	self.trigger trigger_on();
	self show();

	self thread powercell_wait();
}

//-----------------------------------------------------------------------------------
// setup trigger to drop off a powercell
//-----------------------------------------------------------------------------------
powercell_init_dropoff()
{
	dropoff_trigger = GetEnt( "powercell_dropoff", "targetname" );

	if ( !IsDefined( dropoff_trigger ) )
	{
		/#
			iprintln( "No dropoff trigger found for powercell" );
		#/
		return;
	}

	dropoff_trigger thread powercell_dropoff();
}

//-----------------------------------------------------------------------------------
// setup hud elements for all players
//-----------------------------------------------------------------------------------
powercell_init_hud()
{
	flag_wait( "all_players_connected" );

	players = GetPlayers();

	for ( i = 0; i < players.size; i++ )
	{
		players[i].powercellHud = create_simple_hud( players[i] );

		players[i].powercellHud.foreground = true;
		players[i].powercellHud.sort = 2;
		players[i].powercellHud.hidewheninmenu = false;
		players[i].powercellHud.alignX = "center";
		players[i].powercellHud.alignY = "bottom";
		players[i].powercellHud.horzAlign = "user_center";
		players[i].powercellHud.vertAlign = "user_bottom";
		players[i].powercellHud.x = 256;
		players[i].powercellHud.y = 0;
		players[i].powercellHud.alpha = 0.8;

		players[i].powercellEquipped = false;
	}
}

//-----------------------------------------------------------------------------------
// adds powercell to player
//-----------------------------------------------------------------------------------
powercell_pickup( powercell )
{
	self endon( "death" );

	self.powercellEquipped = true;

	self.powercellHud.alpha = 1;
	self.powercellHud setshader( "zom_pack_a_punch_battery_icon", 32, 32 );

	self.powercell = powercell;

	self thread powercell_check_for_loss();

	powercell notify( "powercell_picked_up" );
}

//-----------------------------------------------------------------------------------
// player loses power cell if downed
//-----------------------------------------------------------------------------------
powercell_check_for_loss()
{
	self endon( "powercell_dropoff" );

	self waittill_any( "fake_death", "death", "player_downed" );

	if ( self.powercellEquipped )
	{
		self powercell_lost();
	}
}

//-----------------------------------------------------------------------------------
// removes powercell from player and calls level dropoff func
//-----------------------------------------------------------------------------------
powercell_dropoff()
{
	self UseTriggerRequireLookAt();
	self SetHintString( &"ZOMBIE_POWERCELL_DROPOFF" );
	self SetCursorHint( "HINT_NOICON" );

	self thread powercell_dropoff_done();

	for ( ;; )
	{
		self waittill( "trigger", user );

		if ( user.powercellEquipped )
		{
			user.powercellEquipped = false;
			user.powercellHud.alpha = 0;
			
			self thread play_sound_on_entity( "zmb_power_cell_insert" );

			user notify( "powercell_dropoff" );

			if ( IsDefined( level.powercell_dropoff_func ) )
			{
				[[ level.powercell_dropoff_func ]]();
			}
			user maps\_zombiemode_rank::giveRankXP( "powercell" );
		}
		else
		{
			play_sound_on_ent( "no_purchase" );
		}
	}
}

//-----------------------------------------------------------------------------------
// get rid of powercell trigger
//-----------------------------------------------------------------------------------
powercell_dropoff_done()
{
	level waittill( "powercell_done" );
	self delete();
}

//-----------------------------------------------------------------------------------
// puts the powercell back in the level when the player goes down
//-----------------------------------------------------------------------------------
powercell_lost()
{
	self.powercellEquipped = false;
	self.powercellHud.alpha = 0;

	if ( IsDefined( self.powercell ) )
	{
		self.powercell powercell_replace();
		self.powercell = undefined;
	}
}


