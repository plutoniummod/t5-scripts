#include maps\_utility;
#include common_scripts\utility; 
#include maps\rebirth_anim;
#include maps\_anim;



/*------------------------------------------------------------------------------------------------------------
																								AI In Gas
------------------------------------------------------------------------------------------------------------*/

rebirth_gas_init()
{
	// gas global variables
	level.gas_start_dist 			= 650 * 650;
	level.gas_max_dist	 			= 450 * 450;	
	level.gas_max_height 			= 156;
	
	level.gas_engagement_min_dist	= 600 * 600;
	level.gas_engagement_max_dist	= 850 * 850;

	level.player_in_gas				= false;
	
//	// gas fx
//	level._effect[ "gas_canister" ]		= LoadFX( "weapon/bio_gas_canister/fx_bio_gas_canister" ); 
//	level._effect[ "gas_grenade" ]		= LoadFX( "maps/rebirth/fx_nova6_exp_clusterbomb" );

//	trig_gas_on 	= GetEntArray( "gas_on", "targetname" );
//	array_thread( trig_gas_on, ::gas_on );

//	trig_gas_grenade = GetEntArray( "gas_grenade", "targetname" );
//	array_thread( trig_gas_grenade, ::gas_grenade );

//	gas_trigs = GetEntArray( "gas_inside", "script_noteworthy" );
//	array_thread( gas_trigs, ::gas_trigs_think );
}



/*------------------------------------
Set the fog values to the gas level
------------------------------------*/
//gas_on()
//{
//	self waittill( "trigger" );
//	
//	explode_struct = GetStructArray( self.target, "targetname" );
//
//	for (i = 0; i < explode_struct.size; i++)
//	{
//		PlayFX( level._effect[ "gas_grenade" ], explode_struct[i].origin, AnglesToUp(explode_struct[i].angles) );	
//	}
//
//	//PlayFX( level._effect[ "gas_grenade" ], explode_struct.origin, AnglesToUp(explode_struct.angles) );	
//
//	level thread maps\rebirth_gas::gas_fog_transition( explode_struct.origin );
//}



///*------------------------------------
//Set the fog values to the gas level
//------------------------------------*/
//gas_grenade()
//{
//	self waittill( "trigger" );
//	
//	explode_struct = getstruct( self.target, "targetname" );
//	PlayFX( level._effect[ "gas_grenade" ], explode_struct.origin );	
//}



/*------------------------------------

------------------------------------*/
gas_ai_think()
{
	self endon( "death" );
	self enable_cqbwalk();
	self.maxVisibleDist = level.gas_engagement_max_dist;
	// self.maxVisibleDist
	
//	while( true )
//	{
//		level waittill( "player_in_gas" );
//		self.maxsightdistsqrd = level.gas_engagement_min_dist;
//		
//		level waittill( "player_out_of_gas" );
//		self.maxsightdistsqrd = level.gas_engagement_max_dist;
//	}
}



/*------------------------------------

------------------------------------*/
//gas_trigs_think()
//{
//	while(true)
//	{	
//		self waittill("trigger", guy);
//		
//		if( guy != get_players()[0] )
//		{
//			self thread trigger_thread( guy, ::gas_ai_trig_entered, ::gas_ai_trig_left );
//		}
//		else 
//		{
//			self thread trigger_thread( guy, ::gas_player_trig_entered, ::gas_player_trig_left );
//		}
//	}	
//}



/*------------------------------------

------------------------------------*/
gas_ai_trig_entered( guy, endon_string )
{
	guy endon( "death" );
	self endon( endon_string );
	
	guy.maxsightdistsqrd = level.gas_engagement_min_dist;
	guy enable_cqbwalk();
}



/*------------------------------------

------------------------------------*/
gas_ai_trig_left( guy )
{
	// if the ai exits the gas trigger make sure the player isn't in the gas
	// before setting the sight range back
	if (!level.player_in_gas)
	{
		self.maxsightdistsqrd = level.gas_engagement_max_dist;
	}

	guy disable_cqbwalk();
}



/*------------------------------------

------------------------------------*/
gas_player_trig_entered( player, endon_string )
{
	level notify( "player_in_gas" );

	level.player_in_gas = true;
	
	// maps\createart\rebirth_art::gas_attack_enter_fog(3);
}



/*------------------------------------

------------------------------------*/
gas_player_trig_left( player )
{
	level notify( "player_out_of_gas" );

	level.player_in_gas = false;
	
	// maps\createart\rebirth_art::gas_attack_exit_fog(0.5);
}



/*------------------------------------

------------------------------------*/
//gas_explode_at_point( gas_origin, gas_angles )
//{
//	PlayFX( level._effect[ "gas_canister" ], gas_origin, AnglesToUp(gas_angles) );
//}



/*------------------------------------------------------------------------------------------------------------
																								Fog System
------------------------------------------------------------------------------------------------------------*/

/*------------------------------------
Ramps the fog up or down based on the player's
distance from the gas_point
------------------------------------*/
gas_fog_transition( gas_point )
{
	level notify( "new_gas_explosion" );
	level endon( "new_gas_explosion" );
	
	player = get_players()[0];
	
	gas_start_height = Int(gas_point[2]) - 156;	// start the gas at the point's z

	while( true )
	{		
		player_dist = Distance2DSquared( player.origin, gas_point );
		
		if( player_dist < level.gas_start_dist )  // && player_dist > level.gas_max_dist 
		{
			fog_scalar = 1 - ( ( player_dist - level.gas_max_dist ) / (level.gas_start_dist - level.gas_max_dist ) );
			if( fog_scalar > 1) 
			{
				fog_scalar = 1;
			}
			
			fog_value = gas_start_height + ( level.gas_max_height * fog_scalar );
			setVolFog( 0, 86, 32, fog_value, 0.860, 0.810, 0.316, .1 ); 
		}		
		else
		{
			setVolFog(1031, 3756, 811, 224, 1.0, 1.0, 1.0, 1);
		}
	
		wait( .1 );
	}	
}