#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;

// ------------------------------------------------------------------------------------------------
// Zombie sliding in cave setup
// DCS: 02/22/11
// ------------------------------------------------------------------------------------------------
zombie_cave_slide_init()
{
	flag_init( "slide_anim_change_allowed" );
	level.zombies_slide_anim_change = []; // array needed for anim change throttling 
	level thread slide_anim_change_throttle(); // throttling function
	flag_set( "slide_anim_change_allowed" );

	slide_trigs = GetEntArray("zombie_cave_slide","targetname");
	array_thread(slide_trigs,::slide_trig_watch);
	
	level thread slide_force_stand();

}
// DCS 030211: adding backup trigger.
slide_trig_watch()
{
	slide_node = GetNode(self.target, "targetname");

	if(!IsDefined(slide_node))
	{
		return;
	}	
		
	while(true)
	{
		self waittill("trigger", who);
		if(who.animname == "zombie")
		{
			if(IsDefined(who.sliding) && who.sliding == true)
			{
				continue;
			}
			else
			{
				who thread zombie_sliding(slide_node);
			}	
		}
		else if ( isDefined( who.zombie_sliding ) )
		{
			who thread [[ who.zombie_sliding ]]( slide_node );
		}

		wait_network_frame();
	}	
}	
// ------------------------------------------------------------------------------------------------
#using_animtree( "generic_human" );
cave_slide_anim_init()
{	
	//level.scr_anim["zombie"]["fast_pull_1"] 	= %ai_zombie_blackhole_walk_fast_v1;
	//level.scr_anim["zombie"]["fast_pull_2"] 	= %ai_zombie_blackhole_walk_fast_v2;
	//level.scr_anim["zombie"]["fast_pull_3"] 	= %ai_zombie_blackhole_walk_fast_v3;
	level.scr_anim["zombie"]["fast_pull_4"] 	= %ai_zombie_caveslide_traverse;
	
	level.scr_anim[ "zombie" ][ "attracted_death_1" ] = %ai_zombie_blackhole_death_preburst_v1;
	level.scr_anim[ "zombie" ][ "attracted_death_2" ] = %ai_zombie_blackhole_death_preburst_v2;
	level.scr_anim[ "zombie" ][ "attracted_death_3" ] = %ai_zombie_blackhole_death_preburst_v3;
	level.scr_anim[ "zombie" ][ "attracted_death_4" ] = %ai_zombie_blackhole_death_preburst_v4;

	//level.scr_anim["zombie"]["crawler_fast_pull_1"] 	= %ai_zombie_blackhole_crawl_fast_v1;
	//level.scr_anim["zombie"]["crawler_fast_pull_2"] 	= %ai_zombie_blackhole_crawl_fast_v2;
	//level.scr_anim["zombie"]["crawler_fast_pull_3"] 	= %ai_zombie_blackhole_crawl_fast_v3;

}

// ------------------------------------------------------------------------------------------------
zombie_sliding(slide_node)
{
	self endon( "death" );
	level endon( "intermission" );

	if( !IsDefined( self.cave_slide_flag_init ) )
	{
		self ent_flag_init( "slide_anim_change" ); // have i been told to change my movement anim?
		self.cave_slide_flag_init = 1;
	}

	self.is_traversing = true;
	self notify("zombie_start_traverse");
	
	self thread play_zombie_slide_looper();
	
	self.sliding = true;
	self.ignoreall = true;
	
	// adding check to see if gibbed during slide
	self thread gibbed_while_sliding();
	
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	
	self thread set_zombie_slide_anim();
	
	self SetGoalNode(slide_node);
	while(Distance(self.origin, slide_node.origin) > self.goalradius)
	{
		wait(0.01);
	}			
	//self waittill("goal");

	self thread reset_zombie_anim();
	
	self.sliding = false;
	self.is_traversing = false;
	self notify("zombie_end_traverse");
	self.ignoreall = false;
	self thread maps\_zombiemode_spawner::find_flesh();	
}

play_zombie_slide_looper()
{
	self endon( "death" );
	level endon( "intermission" );
		
    self PlayLoopSound( "fly_dtp_slide_loop_npc_snow", .5 );
    
    self waittill_any( "zombie_end_traverse", "death" );
    
    self StopLoopSound( .5 );
}


// ------------------------------------------------------------------------------------------------
set_zombie_slide_anim()
{
	self endon( "death" );
	
	rand = RandomIntRange( 1, 4 );

	// permission for adding to the array
	//flag_wait( "slide_anim_change_allowed" );  
	level.zombies_slide_anim_change = add_to_array( level.zombies_slide_anim_change, self, false ); // no dupes allowed

	// wait for permission to change anim
	self ent_flag_wait( "slide_anim_change" );

	self clear_run_anim();

	if( self.has_legs )
	{
		//rand = RandomIntRange( 1, 5 );
		self._had_legs = true;
		
		self.preslide_death = self.deathanim;
		self.deathanim = death_while_sliding();

		// just to test the new anim.
		self set_run_anim( "fast_pull_4");		
		self.run_combatanim = level.scr_anim["zombie"]["fast_pull_4"];
		self.crouchRunAnim = level.scr_anim["zombie"]["fast_pull_4"];
		self.crouchrun_combatanim = level.scr_anim["zombie"]["fast_pull_4"];

		//self set_run_anim( "fast_pull_" + rand );		
		//self.run_combatanim = level.scr_anim["zombie"]["fast_pull_" + rand];
		//self.crouchRunAnim = level.scr_anim["zombie"]["fast_pull_" + rand];
		//self.crouchrun_combatanim = level.scr_anim["zombie"]["fast_pull_" + rand];
		
		self.needs_run_update = true;
	}
	else
	{
		self._had_legs = false;
		
		// just to test the new anim.
		self set_run_anim( "fast_pull_4");		
		self.run_combatanim = level.scr_anim["zombie"]["fast_pull_4"];
		self.crouchRunAnim = level.scr_anim["zombie"]["fast_pull_4"];
		self.crouchrun_combatanim = level.scr_anim["zombie"]["fast_pull_4"];


		//self set_run_anim( "crawler_fast_pull_" + rand );		
		//self.run_combatanim = level.scr_anim["zombie"]["crawler_fast_pull_" + rand];
		//self.crouchRunAnim = level.scr_anim["zombie"]["crawler_fast_pull_" + rand];
		//self.crouchrun_combatanim = level.scr_anim["zombie"]["crawler_fast_pull_" + rand];
		
		self.needs_run_update = true;
	}
	
}

// ------------------------------------------------------------------------------------------------
reset_zombie_anim()
{
	self endon( "death" );
	
	// permission for adding to the array
	//flag_wait( "slide_anim_change_allowed" );  
	level.zombies_slide_anim_change = add_to_array( level.zombies_slide_anim_change, self, false ); // no dupes allowed
	
	// wait for permission to change anim
	self ent_flag_wait( "slide_anim_change" );

	//IPrintLnBold("zombie speed is ", self.zombie_move_speed);
	
	theanim = undefined;
	if( self.has_legs )
	{
		if(IsDefined(self.preslide_death))
		{
			self.deathanim = self.preslide_death;
		}	
		switch(self.zombie_move_speed)
		{
			case "walk":
				theanim = "walk" + randomintrange(1, 8);  
				break;
			case "run":                                
				theanim = "run" + randomintrange(1, 6);  
				break;
			case "sprint":                             
				theanim = "sprint" + randomintrange(1, 4);  
				break;
		}
	}
	else
	{
		// walk - there are four legless walk animations 
		legless_walk_anims = [];
		legless_walk_anims = add_to_array( legless_walk_anims, "crawl1", false );
		legless_walk_anims = add_to_array( legless_walk_anims, "crawl5", false );
		legless_walk_anims = add_to_array( legless_walk_anims, "crawl_hand_1", false );
		legless_walk_anims = add_to_array( legless_walk_anims, "crawl_hand_2", false );
		rand_walk_anim = RandomInt( legless_walk_anims.size );
		
		// run
		// there is only one legless run animations, so there is no point in randomizing an array
		
		// sprint
		// there are three legless sprint animations
		legless_sprint_anims = [];
		legless_sprint_anims = add_to_array( legless_sprint_anims, "crawl2", false );
		legless_sprint_anims = add_to_array( legless_sprint_anims, "crawl3", false );
		legless_sprint_anims = add_to_array( legless_sprint_anims, "crawl_sprint1", false );
		rand_sprint_anim = RandomInt( legless_sprint_anims.size );		
		
		switch(self.zombie_move_speed)
		{
			case "walk":
				theanim = legless_walk_anims[ rand_walk_anim ];  
				break;
			case "run":                                
				theanim = "crawl4";  
				break;
			case "sprint":                             
				theanim = legless_sprint_anims[ rand_sprint_anim ];  
				break;
			default:                             
				theanim = "crawl4";  
				break;				
				
		}
	}		

	if ( isDefined(level.scr_anim[self.animname][theanim]) )
	{
		self clear_run_anim();
		wait_network_frame();
				
		self set_run_anim( theanim );                         
		self.run_combatanim = level.scr_anim[self.animname][theanim];
		self.walk_combatanim = level.scr_anim[self.animname][theanim];
		self.crouchRunAnim = level.scr_anim[self.animname][theanim];
		self.crouchrun_combatanim = level.scr_anim[self.animname][theanim];
		self.needs_run_update = true;
		return;
	}
	else
	{
		//try again.
		self thread reset_zombie_anim();
	}	
}

// ------------------------------------------------------------------------------------------------
death_while_sliding()
{
	self endon( "death" );
	
	death_animation = undefined;
	
	rand = RandomIntRange( 1, 5 );
	
	if( self.has_legs )
	{
		death_animation = level.scr_anim[ self.animname ][ "attracted_death_" + rand ];
	}
	
	return death_animation;
}

gibbed_while_sliding()
{
	self endon("death");
	
	// not needed, already a crawler.
	if(!self.has_legs)
	{
		return;
	}
		
	while(self.sliding)
	{
		if( !self.has_legs && self._had_legs == true)
		{
			self thread set_zombie_slide_anim();
			return;
		}
		wait(0.1);	
	}		 
}		
// ------------------------------------------------------------------------------------------------
//		Stolen from 
// -- black hole bomb anim change throttling
// ------------------------------------------------------------------------------------------------
slide_anim_change_throttle()
{
	if( !IsDefined( level.zombies_slide_anim_change ) )
	{
		level.zombies_slide_anim_change = [];
	}
	
	int_max_num_zombies_per_frame = 7; // how many guys it can allow at a time
	array_zombies_allowed_to_switch = [];
	
	// loop through the array
	while( IsDefined( level.zombies_slide_anim_change ) )
	{
		if( level.zombies_slide_anim_change.size == 0 )
		{
			wait( 0.1 );
			continue;
		}
		
		array_zombies_allowed_to_switch = level.zombies_slide_anim_change;
		
		for( i = 0; i < array_zombies_allowed_to_switch.size; i++  )
		{
			if( IsDefined( array_zombies_allowed_to_switch[i] ) &&
					IsAlive( array_zombies_allowed_to_switch[i] ) )
					{
						array_zombies_allowed_to_switch[i] ent_flag_set( "slide_anim_change" );
					}
					
			if( i >= int_max_num_zombies_per_frame )
			{
				break; // no more zombies should be allowed to change until the next server frame
			}
		}
		
		flag_clear( "slide_anim_change_allowed" );
		
		// now clean out those that were allowed to change
		for( i = 0; i < array_zombies_allowed_to_switch.size; i++ )
		{
			if( array_zombies_allowed_to_switch[i] ent_flag( "slide_anim_change" ) )
			{
				// remove this one from the level array
				level.zombies_slide_anim_change = array_remove( level.zombies_slide_anim_change, array_zombies_allowed_to_switch[i] );
			}
		}
		
		// clean any dead or undefined from the main array
		level.zombies_slide_anim_change = array_removedead( level.zombies_slide_anim_change );
		level.zombies_slide_anim_change = array_removeundefined( level.zombies_slide_anim_change );
		
		flag_set( "slide_anim_change_allowed" );
		
		wait_network_frame();
		wait( 0.1 );
		
	}

}	

slide_force_stand()
{
	trig = GetEnt("cave_slide_force_stand", "targetname");
	
	while(true)
	{
		trig waittill("trigger", who);
		if(is_player_valid(who) && who GetStance() != "stand")
		{
			who SetStance("stand");
		}	
		wait_network_frame();
	}	
}	