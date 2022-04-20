#include maps\_utility;
#include common_scripts\utility;
#include maps\_utility_code;
#include maps\_anim;
#include maps\fullahead_util;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// DRONES AND SO ON
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

fa_start_drone_path( tn, team, hide_weapon )
{
	structs = getstructarray( tn, "targetname" );
	for( i=0; i<structs.size; i++ )
	{
		struct = structs[i];
		drone = fa_drone_spawn( struct, team );
		if( isdefined( hide_weapon ) && hide_weapon == true )
		{
			drone HidePart("tag_weapon");	
		}
		
		drone thread fa_drone_move( struct );
	}
}

// This, also, was originally stolen from Pentagon
#using_animtree( "generic_human" );
fa_drone_spawn( drone_struct, team, hide_weapon )
{
	if( !isDefined( drone_struct ) )
	{
		return undefined;
	}

	//Spawn the drone.
	drone					= spawn( "script_model", drone_struct.origin );
	drone.animname			= "generic";
	drone.spawner			 = drone_struct;

	if( isdefined(drone_struct.angles) )
		drone.angles = drone_struct.angles;

	drone model_by_team( team );
	drone useAnimTree( #animtree );	//Let the engine know this is a human.

	//drone.targetname = drone_struct.targetname + "_drone";
	drone.targetname = "drone";
	drone makefakeai();
	drone thread fa_drone_death();
	drone.team = team;

	if( isdefined(hide_weapon) && hide_weapon == true )
	{
		drone HidePart("tag_weapon");	
	}
	
	return drone;
}

model_by_team( team )
{
	if( isdefined(team) )
	{
		if( team == "axis" )
		{
			self [[ level.drone_spawnFunction["axis"] ]]();
			weaponModel = GetWeaponModel( level.drone_weaponlist_axis[0] ); 
			self Attach( weaponModel, "tag_weapon_right" ); 
		}
		else if( team == "axis_nogear" )
		{
			self [[ level.drone_spawnFunction["axis_nogear"] ]]();
		}		
		else if( team == "allies" )
		{
			self [[ level.drone_spawnFunction["allies"] ]]();
			weaponModel = GetWeaponModel( level.drone_weaponlist_allies[0] ); 
			self Attach( weaponModel, "tag_weapon_right" ); 
		}
		else if( team == "allieshigh" )
		{
			self [[ level.allieshigh_spawnFunction ]]();
			weaponModel = GetWeaponModel( level.drone_weaponlist_allies[0] ); 
			self Attach( weaponModel, "tag_weapon_right" ); 
		}
		else if( team == "alliesofficer" )
		{
			self [[ level.alliesofficer_spawnFunction ]]();
			weaponModel = GetWeaponModel( level.drone_weaponlist_allies[0] ); 
			self Attach( weaponModel, "tag_weapon_right" ); 
		}
		else if( team == "britishhigh" )
		{
			self [[ level.britishHigh_spawnFunction ]]();
			weaponModel = GetWeaponModel( "sten_sp" ); 
			self Attach( weaponModel, "tag_weapon_right" ); 
		}
		else if( team == "officer_frozen" )
		{
			self [[ level.officerFrozen_spawnFunction ]]();
		}
		else if( team == "infantry_frozen" )
		{
			self [[ level.infantryFrozen_spawnFunction ]]();
		}
		else if( team == "axis_hung" ) // added proper model setup for hanging Germans PI - DMM
		{
			self [[ level.infantryHung_spawnFunction ]]();
		}
		else if( team == "reznov" )
		{
			self [[ level.reznov_spawnFunction ]]();
		}
		else if( team == "reznovtalky" )
		{
			self [[ level.reznovTalky_spawnFunction ]]();
		}
		else if( team == "dragovich" )
		{
			self [[ level.dragovich_spawnFunction ]]();
		}
		else if( team == "steiner" )
		{
			self [[ level.steiner_spawnFunction ]]();
		}
		else if( team == "patrenko" )
		{
			self [[ level.patrenko_spawnFunction ]]();
		}
		else if( team == "gasguy" )
		{
			self [[ level.gasguy_spawnFunction ]]();
		}
		else if( team == "kravchenko" )
		{
			self [[ level.kravchenko_spawnFunction ]]();
		}
	}
}

fa_drone_death()
{
	self endon( "stop_death_thread" );
	
	self setcandamage( true );
	self waittill( "death" );

	if( isdefined(self) ) // could've been a deletion
	{
		self startragdoll();
	}
}

// started out stolen from Pentagon
fa_drone_move( structstart ) //self == an entity
{
	self endon( "death" );

	if( !isdefined( structstart ) )
	{
		return;
	}

	self.move_speed = 33.0;
	self.move_anim_string = "patrol_walk";

	if( isdefined(structstart.script_parameters) )
	{
		self parse_script_parameters( structstart.script_parameters );
	}


	self endon( "death" );
	self endon( "stop_drone_move" );

	structnext = structstart;

	if( distance(self.origin,structnext.origin) < 8.0 && isdefined(structnext.target) )
	{
		structnext = getstruct( structnext.target, "targetname" );
	}


	while( true )
	{
		//Calculate the distance between this entity and the next struct.
		dist = distance( self.origin, structnext.origin );

		time = dist / self.move_speed;

		if( time == 0.0 )
		{
			time = 0.1;
		}

		self setanim( level.scr_anim[ "generic" ][ self.move_anim_string ] );

		accel_time = 0.0;
		decel_time = 0.0;

		//Move this entity to the origin, rotate it to the angles.
		self moveto( structnext.origin, time, accel_time, decel_time );

		angles = generate_next_struct_angles( self.origin, structnext.origin );

//		self rotateto( angles, time, time/3.0, time/3.0 );
//		self waittill_multiple( "movedone", "rotatedone" );

		self rotateto( angles, time/9, time/18, time/18 ); // this turns the guys quite a bit faster than above, but it's not too sharp as long as your nodes aren't 
															// at large angles AND very close to each other.
		self waittill( "movedone" );
		
		// drone is now actually located at structnext

		if( isdefined(structnext.script_parameters) )
		{
			self parse_script_parameters( structnext.script_parameters );
		}

		if( isdefined(structnext.script_noteworthy) )
		{
			// otherwise, fall back to an animation
			// quickly rotate to the specified angle, since the animation probably wants it
			if( isdefined(structnext.angles) )
			{
				self rotateto( structnext.angles, 0.5, 0.25, 0.25 );
			}
			self drone_action( structnext.script_noteworthy );
		}

		//Try moving onto the next struct in the path, if any.
		if( isDefined( structnext.target ) )
		{
			structnext = getStruct( structnext.target, "targetname" );
			if( !isdefined(structnext) )
			{
				break;
			}
		}
		else
		{
			break;
		}
	}

	//No structs left in the path, notify the entity.
	self notify( "path_end_reached" );
}

// self should be the drone in question
parse_script_parameters( parameters )
{
	segs = strtok( parameters, ";" );

	if( segs.size >= 1 )
	{
		self.move_anim_string = segs[0];
		self ClearAnim(%body, 0.3);
	}

	if( segs.size >= 2 )
	{
		self.move_speed = float( segs[1] );
	}
}

drone_action( action_string )
{
	self endon( "death" );

	if( issubstr( action_string, ";" ) )
	{
		segs = strtok( action_string, ";" );
		for( i=0; i<segs.size; i++ )
		{
			drone_singleaction( segs[i] );
		}
	}
	else
	{
		drone_singleaction( action_string );
	}
}

drone_singleaction( action_string )
{
	if( action_string == "*delete" )
	{
		self delete();
	}
	else if( action_string == "*shootme" ) // find a nearby AI character, and command them to kill this drone
	{
		self endon( "death" );
		otherteam = get_other_team( self.team );

		while( true )
		{
			ai = getaiarray( otherteam );

			nearest_dist = 512;
			nearest_ai = undefined;

			for( i=0; i<ai.size; i++ )
			{
				dist = distance(self.origin, ai[i].origin);
				if( dist < nearest_dist )
				{
					nearest_dist = dist;
					nearest_ai = ai[i];
				}
			}

			if( isdefined(nearest_ai) )
			{
				//nearest_ai fa_speak( "DRONE SHOOT ME: " + nearest_ai.targetname );
				nearest_ai shoot_at_target( self, undefined, undefined, -1 );
			}

			wait(0.5);
		}
	}
	else if( action_string == "*die" ) // kill this drone
	{
		self DoDamage( self.health + 150, self.origin );
	}
	else if( action_string == "*idle" ) // idle
	{
		AssertEX( IsDefined(level.droneidleanims) && level.droneidleanims.size > 0, "No drone idle anims setup for the level" );
		random_index = RandomInt(level.droneidleanims.size);
		self ClearAnim( %body, 0 );
		self SetAnim(level.droneidleanims[random_index], 1, 0.05);
		level waittill("alert_all_drones");
		self ClearAnim( level.droneidleanims[random_index], 0);
		wait(RandomFloatRange(0.1, 0.5));
//		self.idletextprint = "idle guy got to his next node";
		//-- Reset run cycle if they were walking first
//		self.drone_run_cycle = drone_pick_run_anim();
//		self.running = undefined; //-- I was just idling so its safe to assume that I'm not running			
	}
	else
	{
 		sub_anim = undefined;
 		if( isarray(level.scr_anim["generic"][action_string]) ) // if you've got a set of anims, do this
 			sub_anim = randomint( level.scr_anim["generic"][action_string].size );
			
		self ClearAnim(%body, 0.3);
		
		if( isdefined(sub_anim) )
			self SetFlaggedAnimKnobRestart( "drone_custom_anim", level.scr_anim[ "generic" ][ action_string ][ sub_anim ] );
		else
			self SetFlaggedAnimKnobRestart( "drone_custom_anim", level.scr_anim[ "generic" ][ action_string ] );
			
		self waittillmatch( "drone_custom_anim", "end" );
	}
}

// returns an angles based on what this struct is pointing at
generate_next_struct_angles( cur_origin, next_origin )
{
	assert( isdefined(next_origin) );

	direction = ( next_origin[0] - cur_origin[0], next_origin[1] - cur_origin[1], 0 );
	angles = vectortoangles( direction );
	return angles;

}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


spawn_hanging_guys( use_targetname )
{
	structs = getstructarray( "hanging_guy_german", "targetname" );
	for( i=0; i<structs.size; i++ )
	{
		create_hanging_guy( structs[i], "axis_hung", use_targetname );
	}
}

#using_animtree( "generic_human" );
create_hanging_guy( struct, team, use_targetname )
{
	guy = spawn( "script_model", struct.origin + (0,0,-64) );
	guy.animname = "generic";
	guy.targetname = use_targetname;
	guy model_by_team( team );
	//guy hidepart("tag_weapon"); // new hanging model does not have a tag_weapon, commenting this out PI - DMM


	if( isdefined(guy) && isdefined(struct) )
	{
		guy makeFakeAI();
		guy useAnimTree(#animtree);
		guy setAnim( %crouch2stand, 1.0, 1.0, 1.0 );
		wait( 0.4 );
		guy startragdoll();

		joint = "j_neck";
		if( isdefined(struct.script_noteworthy) )
		{
			if( struct.script_noteworthy == "neck" )
				joint = "j_neck";
			if( struct.script_noteworthy == "ankle" )
				joint = "j_ankle_ri";
			if( struct.script_noteworthy == "wrist" )
				joint = "j_wrist_le";
		}

		createrope( struct.origin, (0,0,0), 40, guy, joint, 1 );
	}
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

spawn_frozen_guys( use_targetname )
{
	structs = getstructarray( use_targetname, "targetname" );
	for( i=0; i<structs.size; i++ )
	{
		type = "infantry";
		posenum = "1";
		
		if( isdefined(structs[i].script_parameters) )
		{
			segs = strtok( structs[i].script_parameters, ";" );

			if( segs.size >= 1 )
				type = segs[0]; // "officer" and "infantry" are both valid here
		
			if( segs.size >= 2 )
				posenum = segs[1]; // 1 through 6
		}
			
		create_frozen_guy( structs[i], type, posenum, use_targetname );
	}
}

#using_animtree( "generic_human" );
create_frozen_guy( struct, team, posenum, use_targetname )
{
	guy = spawn( "script_model", struct.origin );
	guy.angles = struct.angles;
	guy useAnimTree(#animtree);
	guy.animname = "generic";
	guy.targetname = use_targetname;
	
	guy model_by_team( team+"_frozen" );

	if( isdefined(guy) && isdefined(struct) )
	{
		pose = "frozen" + posenum;
		fa_print( "frozen guy at " + guy.origin + " using pose " + pose );
		struct thread anim_first_frame( guy, pose );
	}
}