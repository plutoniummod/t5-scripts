#include animscripts\combat_utility;
#include animscripts\anims;
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;

//---------------------------------------------------------------------------

// UTILITY FUNCTIONS

#using_animtree ("vehicles");
play_vehicle_anim_single_solo( vehicle, vehicle_animname, anim_node, animation )
{
	vehicle.animname = vehicle_animname;
	vehicle UseAnimTree( #animtree );
	
	// handle aligned and unaligned anims
	if( isdefined( anim_node ) )
	{
		anim_node anim_Single_aligned( vehicle, animation );
	}
	else
	{
		vehicle anim_Single( vehicle, animation );
	}
}

#using_animtree ( "player" );
play_player_anim_on_vehicle( vehicle, animation, tag, no_unlink )
{
	player = get_players()[0];
	player DisableWeapons();
	player Unlink();

	hands = spawn_anim_model( "player_hands" );
	hands.animname = "player_hands";

	player.anim_hands = hands;
	
	hands.origin = vehicle GetTagOrigin( tag );
	hands.angles = vehicle GetTagAngles( tag );
	hands Linkto( vehicle, tag );

	// link player to hand
	player PlayerLinkToAbsolute( hands, "tag_player" );

	// animate hand
	hands anim_single( hands, animation ); 

	if( !isdefined( no_unlink ) || no_unlink == false )
	{
		player Unlink();
		hands Unlink();
		hands Delete();
	
		player EnableWeapons();
	}
}

play_player_body_anim_on_vehicle( vehicle, animation, tag, no_unlink )
{
	player = get_players()[0];
	player DisableWeapons();
	player Unlink();

	hands = spawn_anim_model( "player_body" );
	hands.animname = "player_body";

	player.anim_hands = hands;
	
	hands.origin = vehicle GetTagOrigin( tag );
	hands.angles = vehicle GetTagAngles( tag );
	hands Linkto( vehicle, tag );

	// link player to hand
	player PlayerLinkToAbsolute( hands, "tag_player" );

	// animate hand
	hands anim_single( hands, animation ); 

	if( !isdefined( no_unlink ) || no_unlink == false )
	{
		player Unlink();
		hands Unlink();
		hands Delete();
	
		player EnableWeapons();
	}
}

// why this function is not in _utility is beyond me
take_player_weapons()
{
	self.weaponInventory = self GetWeaponsList();
	self.lastActiveWeapon = self GetCurrentWeapon();

	self.weaponAmmo = [];
	
	for( i = 0; i < self.weaponInventory.size; i++ )
	{
		weapon = self.weaponInventory[i];
		
		self.weaponAmmo[weapon]["clip"] = self GetWeaponAmmoClip( weapon );
		self.weaponAmmo[weapon]["stock"] = self GetWeaponAmmoStock( weapon );
	}
	
	self TakeAllWeapons();
}

giveback_player_weapons()
{
	ASSERTEX( IsDefined( self.weaponInventory ), "player.weaponInventory is not defined - did you run take_player_weapons() first?" );
	
	for( i = 0; i < self.weaponInventory.size; i++ )
	{
		weapon = self.weaponInventory[i];
		
		self GiveWeapon( weapon );
		self SetWeaponAmmoClip( weapon, self.weaponAmmo[weapon]["clip"] );
		self SetWeaponAmmoStock( weapon, self.weaponAmmo[weapon]["stock"] );
	}
	
	// if we can't figure out what the last active weapon was, try to switch a primary weapon
	if( self.lastActiveWeapon != "none" )
	{
		self SwitchToWeapon( self.lastActiveWeapon );
	}
	else
	{
		primaryWeapons = self GetWeaponsListPrimaries();
		if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
		{
			self SwitchToWeapon( primaryWeapons[0] );
		}
	}
}

// display an on screen message whenever (and only if) the player is inside a trigger
display_trigger_touch_message( trigger, display_text, end_msg_1, end_msg_2 )
{
	level endon( end_msg_1 );
	level endon( end_msg_2 );
	
	level thread delete_trigger_touch_message_on_notify( end_msg_1 );
	level thread delete_trigger_touch_message_on_notify( end_msg_2 );
	
	message_displayed = false;
	player = get_players()[0];
	while( 1 )
	{
		if( player istouching( trigger ) == true && message_displayed == false )
		{
			screen_message_create( display_text );
			message_displayed = true;
		}
		else if( player istouching( trigger ) == false && message_displayed == true )
		{
			screen_message_delete();
			message_displayed = false;
		}
		wait( 0.05 );
	}
}
	
delete_trigger_touch_message_on_notify( end_msg )
{
	level waittill( end_msg );
	screen_message_delete();
}

safe_delete_ent( entity )
{
	if( isdefined( entity ) )
	{
		entity delete();
	}
}

delete_all_enemies()
{
	enemies = getaiarray( "axis" );
	for( i = 0; i < enemies.size; i++ )
	{
		enemies[i] delete();
	}
}

drag_fade_to_black(fade_out_time, fade_in_time)
{
  black_bg = NewHudElem(); 
  black_bg.x = 0; 
  black_bg.y = 0; 
  black_bg.alpha = 0; 
  black_bg.horzAlign = "fullscreen"; 
  black_bg.vertAlign = "fullscreen"; 
  black_bg SetShader( "black", 640, 480 ); 

  // Fade in
  black_bg FadeOverTime(fade_out_time); 
  black_bg.alpha = 1;

 	wait(5);
	// Fade out
	black_bg FadeOverTime( fade_in_time ); 
	black_bg.alpha = 0; 
}
