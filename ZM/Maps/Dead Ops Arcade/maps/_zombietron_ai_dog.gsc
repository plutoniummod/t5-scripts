#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombietron_utility; 

precache_dog_fx()
{
	level._effect[ "lightning_dog_spawn" ]	= Loadfx( "maps/zombie/fx_zombie_dog_lightning_buildup" );
	level._effect[ "dog_eye_glow" ]			= Loadfx( "maps/zombie/fx_zombie_dog_eyes" );
	level._effect[ "dog_gib" ]				= Loadfx( "maps/zombie/fx_zombie_dog_explosion" );
	level._effect[ "dog_trail_fire" ]		= Loadfx( "maps/zombie/fx_zombie_dog_fire_trail" );
	level._effect[ "dog_trail_ash" ]		= Loadfx( "maps/zombie/fx_zombie_dog_ash_trail" );
}

#using_animtree( "dog" );
dog_prespawn()
{
	self.targetname = "zombie_dog";
	self.script_noteworthy = undefined;
	self.animname 	= "zombie_dog"; 		
	self.allowdeath = true; 			// allows death during animscripted calls
	self.allowpain 	= false;
	self.force_gib 	= true; 		// needed to make sure this guy does gibs
	self.is_zombie 	= true; 			// needed for melee.gsc in the animscripts
	self.has_legs 	= true; 			// Sumeet - This tells the zombie that he is allowed to stand anymore or not, gibbing can take 
	self.is_dog	 	= true; 
	// out both legs and then the only allowed stance should be prone.
	self.gibbed 		= false; 
	self.head_gibbed= false;
	animscripts\zombie_dog_init::change_anim_set( GetDvar( #"zombie_dog_animset" ) );
	
	self.grenadeawareness = 0;
	self.badplaceawareness = 0;

	self.ignoreSuppression = true; 	
	self.suppressionThreshold = 1; 
	self.noDodgeMove = true; 
	self.dontShootWhileMoving = true;
	self.pathenemylookahead = 0;

	self.badplaceawareness = 0;
	self.chatInitialized = false;
	self setTeamForEntity( "axis" );

	self dog_fx_eye_glow();
	self dog_fx_trail();
	self thread dog_death();
	self thread dog_move_audio();

	self.a.disablePain = true;
	self disable_react(); // SUMEET - zombies dont use react feature.
	self ClearEnemy();
	self ClearGoalVolume();
	self.flame_damage_time = 0;
	
	self notify( "zombie_init_done" );
}

dog_fx_eye_glow()
{
	self.fx_dog_eye = Spawn( "script_model", self GetTagOrigin( "J_EyeBall_LE" ) );
	assert( IsDefined( self.fx_dog_eye ) );

	self.fx_dog_eye.angles = self GetTagAngles( "J_EyeBall_LE" );
	self.fx_dog_eye SetModel( "tag_origin" );
	self.fx_dog_eye LinkTo( self, "J_EyeBall_LE" );
}


dog_fx_trail()
{
	if( randomint( 100 ) > level.zombie_vars["dog_fire_trail_percent"] )
	{
		self.fx_dog_trail_type = level._effect[ "dog_trail_ash" ];
		self.fx_dog_trail_sound = "dog_trail_fire_breath";
	}
	else
	{
		//fire dogs will explode during death	
		self.a.nodeath = true;

		self.fx_dog_trail_type = level._effect[ "dog_trail_fire" ];
		self.fx_dog_trail_sound = "dog_trail_fire";
	}

	self.fx_dog_trail = Spawn( "script_model", self GetTagOrigin( "tag_origin" ) );
	assert( IsDefined( self.fx_dog_trail ) );

	self.fx_dog_trail.angles = self GetTagAngles( "tag_origin" );
	self.fx_dog_trail SetModel( "tag_origin" );
	self.fx_dog_trail LinkTo( self, "tag_origin" );
}


dog_death()
{
	self waittill( "death" );

	if ( !IsDefined(self) )
		return;
    
    self PlaySound( "zmb_hellhound_vox_death" );
    
	// switch to inflictor when SP DoDamage supports it
	if( isdefined( self.attacker ) && isai( self.attacker ) )
	{
		self.attacker notify( "killed", self );
	}

	// fx
	assert( IsDefined( self.fx_dog_eye ) );
	self.fx_dog_eye delete();

	assert( IsDefined( self.fx_dog_trail ) );
	self.fx_dog_trail delete();

	if ( IsDefined( self.a.nodeath ) )
	{
		level thread dog_explode_fx( self.origin );
		self delete();
	}
}
dog_explode_fx( origin )
{
	if( !IsDefined( origin ) )
	{
		return;
	}

	fx = spawn("script_model", origin );

	fx SetModel( "tag_origin" );
	PlayFxOnTag( level._effect["dog_gib"], fx, "tag_origin" );
	fx playsound( "zmb_hellhound_explode" );
	wait( 5 );
	fx delete();
}

dog_player_damage()
{
	if ( isDefined(self.tank) || isDefined(self.heli) )
	{
		return;
	}
	// play effect here
	self DoDamage( 100, self.origin );
	//println("Health: " + self.health);
}

dog_move_audio()
{
    self endon( "death" );
    
    level.doggy_movement_vox = 0;
    level.doggy_attack_vox = 0;
    self.playing_attack_vox = false;
    self.playing_movement_vox = false;
    
    wait(RandomFloatRange(.25,1));
    
    while( 1 )
    {
        players = get_players();
        
        for( i=0; i<players.size; i++ )
        {
            if( (DistanceSquared( self.origin, players[i].origin ) < 50 * 50) && (level.doggy_attack_vox <=3) && !self.playing_attack_vox )
            {
                level.doggy_attack_vox++;
                self.playing_attack_vox = true;
                self thread vox_timer( "attack" );
                self PlaySound( "zmb_hellhound_vox_attack" );
            }
        }
        
        if( !self.playing_movement_vox && !self.playing_attack_vox && (level.doggy_movement_vox <= 8) )
        {
            level.doggy_movement_vox++;
            self.playing_movement_vox = true;
            self thread vox_timer( "movement" );
            self PlaySound( "zmb_hellhound_vox_move" );
        }
        
        wait(.1);
    }
}

vox_timer( type )
{
    self endon( "death" );
    
    switch( type )
	{
	    case "attack":
	        wait(RandomFloatRange(1.5,2.5) );
	        self.playing_attack_vox = false;
	        if( level.doggy_attack_vox > 0 )
	        {
	            level.doggy_attack_vox--;
	        }
			break;
		case "movement":
		    wait(RandomFloatRange(3,5) );
		    self.playing_movement_vox = false;
		    if( level.doggy_movement_vox > 0 )
		    {
	            level.doggy_movement_vox--;
	        }
	        break;
	}
}