#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;


/*
	Usage: 
		
	1. Make a critter (pig or chicken for now) as script_model. 

	2. Optional: Make the critter target a script struct, with a defined angle
				 The critter will run there once alerted

	3. Optional: Use triggers or level notifies to alert the critters

	4. In script: 

		// initialize anims.

		critters_init();

		// run this thread on each critter, ex:

		chicken thread start_critter_anims( "chicken", true, 100, "chicken_move_trigger" );
*/



#using_animtree ("critter");
critters_init()
{
	level.scr_anim["chicken"]["death1"]	 		= %a_chicken_death;
	level.scr_anim["chicken"]["death2"]	 		= %a_chicken_death_a;
	level.scr_anim["chicken"]["idle"][0]	 		= %a_chicken_idle;
	level.scr_anim["chicken"]["idle"][1]	 	= %a_chicken_idle_a;
	level.scr_anim["chicken"]["react1"]	 		= %a_chicken_react;
	level.scr_anim["chicken"]["react2"]	 		= %a_chicken_react_a;
	level.scr_anim["chicken"]["run"][0]	 		= %a_chicken_run;
	level.scr_anim["chicken"]["run_panic1"][0]	 		= %a_chicken_run_panic_a;
	level.scr_anim["chicken"]["run_panic2"][0]	 		= %a_chicken_run_panic_b;

	level.scr_anim["pig"]["death1"]	 			= %a_pig_death;
	level.scr_anim["pig"]["death2"]	 			= %a_pig_death;
	level.scr_anim["pig"]["idle"][0]	 		= %a_pig_idle;
	level.scr_anim["pig"]["idle"][1]	 		= %a_pig_idle_a;
	level.scr_anim["pig"]["idle"][2]	 		= %a_pig_idle_scratch;
	level.scr_anim["pig"]["idle"][3]	 		= %a_pig_idle_scratch_fast;
	level.scr_anim["pig"]["react1"]	 			= %a_pig_react;
	level.scr_anim["pig"]["react2"]	 			= %a_pig_react;
	level.scr_anim["pig"]["run"][0]	 			= %a_pig_run;
	level.scr_anim["pig"]["run_panic1"][0]		= %a_pig_run_fast;
	level.scr_anim["pig"]["run_panic2"][0]		= %a_pig_run_fast;
}

// animal_type is the only required perameter
// self is the critter
#using_animtree ("critter");
start_critter_anims( animal_type, can_die, move_speed, react_trigger_1_name, panic, react_trigger_2_name, react_notify )
{
	self endon( "death" );

	self.reaction_override = false;
	self.cannot_die = false;

	if( animal_type == "pig" )
	{
		self.animname = "pig";
		if( !isdefined( move_speed ) )
		{
			move_speed = 200;
		}
	} 
	else if( animal_type == "chicken" )
	{
		self.animname = "chicken";
		if( !isdefined( move_speed ) )
		{
			move_speed = 100;
		}
	} 
	else
	{
		return;
	}

	// move speed should always be randomized a bit, plus or minus 30%
	variation = move_speed * 0.6;
	move_speed = ( move_speed * 0.7 ) + randomfloat( variation );

	self UseAnimTree( #animtree );

	if( isdefined( can_die ) && can_die == true )
	{
		self SetCanDamage( true ); 
		self.health = 99999;
		self thread critter_detect_death();
	}

	// find out if the critter can move
	if( isdefined( self.target ) )
	{
		destination_struct = getstruct( self.target, "targetname" );
		if( isdefined( destination_struct ) )
		{
			// the critter can move
			if( isdefined( react_trigger_1_name ) )
			{
				self thread critter_run_on_trigger( react_trigger_1_name );
			}
			if( isdefined( react_trigger_2_name ) )
			{
				self thread critter_run_on_trigger( react_trigger_2_name );
			}
			if( isdefined( react_notify ) )
			{
				self thread critter_run_on_notify( react_notify );
			}
	
			self thread critter_run( move_speed, destination_struct, panic );
		}
	}

	//self thread occational_reaction();
	// we should add a random starting delay, to make sure the chickens look unique
	self.reaction_override = true;

	self thread anim_loop( self, "idle" );
	wait( randomfloat( 4.0 ) );

	self.reaction_override = false;

	while( 1 )
	{
		self thread anim_loop( self, "idle" );
		self waittill( "resume_idle" );
	}
}

critter_detect_death()
{
	while( 1 )
	{
		self waittill( "damage" ); 
		if( self.cannot_die == false )
		{
			break;
		}
	}

	self death_notify_wrapper();
	
	if( self.animname == "chicken" )
	{
		playfxontag(level._effect["chicken_death"],self,"tag_body");
	}
	
	self unlink();

	random_num = randomint( 100 );
	if( random_num < 50 )
	{
		self anim_single( self, "death1" );
	}
	else
	{
		self anim_single( self, "death2" );
	}
}

occational_reaction()
{
	self endon( "death" );

	while( 1 )
	{
		if( self.animname == "chicken" )
		{
			wait( randomfloat( 20 ) + 20 );
		}
		else if( self.animname == "pig" )
		{
			wait( randomfloat( 20 ) + 30 );
		}
		else
		{
			return;
		}
	
		if( self.reaction_override == false )
		{
			random_num = randomint( 100 );
			if( random_num < 50 )
			{
				self anim_single( self, "react1" );
			}
			else
			{
				self anim_single( self, "react2" );
			}
			self notify( "resume_idle" );
		}
	}
}

critter_run_on_trigger( trigger_name )
{
	self endon( "death" );
	trigger = getent( trigger_name, "targetname" );
	trigger waittill( "trigger" );
	self notify( "run_time" );
}

critter_run_on_notify( notify_name )
{
	self endon( "death" );
	level waittill( notify_name );
	self notify( "run_time" );
}

critter_run( speed, destination_struct, panic)
{
	self endon( "death" );

	self waittill( "run_time" );

	self.reaction_override = true;

	// add random delay
	wait( randomfloat( 1.0 ) );

	distance_to_end = distance( self.origin, destination_struct.origin );
	time = distance_to_end / speed;

	if( isdefined( self.no_jump ) && self.no_jump == true )
	{
		//self anim_single_aligned( self, "react" );
	}
	else
	{
		self.cannot_die = true;
		random_num = randomint( 100 );
		if( random_num < 50 )
		{
			self anim_single( self, "react1" );
		}
		else
		{
			self anim_single( self, "react2" );
		}
		self.cannot_die = false;
	}

	if( isdefined( panic ) && panic == true )
	{
		self thread anim_loop( self, "run_panic1" );
	}
	else
	{
		self thread anim_loop( self, "run" );
	}

	linker = spawn( "script_model", self.origin );
	linker.angles = self.angles;
	linker setmodel( "tag_origin" );
	self linkto( linker, "tag_origin" );
	linker rotateTo( destination_struct.angles, 0.2 );
	wait( 0.2 );
	linker moveTo( destination_struct.origin, time );
	wait( time );

	// if the structs targets more structs, we need to keep looping it
	while( isdefined( destination_struct.target ) )
	{
		next_struct = getstruct( destination_struct.target, "targetname" );
		distance_to_end = distance( self.origin, next_struct.origin );
		time = distance_to_end / speed;
		self.destination_target = next_struct;
		linker rotateTo( next_struct.angles, 0.2 );
		linker moveTo( next_struct.origin, time );

		if( isdefined( destination_struct.script_noteworthy ) && destination_struct.script_noteworthy == "jump" )
		{
			self.cannot_die = true;
			self thread jump_during_running( panic );
		}
		wait( time );
		self.cannot_die = false;
		destination_struct = next_struct;
	}

	self unlink();
	linker delete();

	self notify( "stop_running" );

	self.reaction_override = false;

	self notify( "resume_idle" );
}

jump_during_running( panic )
{
	self endon( "death" );
	self endon( "stop_running" );

	self anim_single( self, "react1" );
	
	// resume run
	if( isdefined( panic ) && panic == true )
	{
		self thread anim_loop( self, "run_panic1" );
	}
	else
	{
		self thread anim_loop( self, "run" );
	}

}