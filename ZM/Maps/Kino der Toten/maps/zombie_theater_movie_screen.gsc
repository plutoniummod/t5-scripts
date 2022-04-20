#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;

initMovieScreen()
{
	//level thread set_up_images();
	//level thread lower_movie_screen();
	level thread setupCurtains();
	
	level thread movie_reels_init();
}

set_up_images()
{
	level.images = [];
	level.images = getentarray("screen_image", "targetname");
	level.images = mergeSort(level.images);
	for (x = 0; x < level.images.size; x++)
		level.images[x] hide();
}

//merge sort for speed and sexiness
mergeSort(current_list)
{
	if (current_list.size <= 1)
		return current_list;
		
	left = [];
	right = [];
	
	middle = current_list.size / 2;
	for (x = 0; x < middle; x++)
		left = add_to_array(left, current_list[x]);
	for (; x < current_list.size; x++)
		right = add_to_array(right, current_list[x]);
	
	left = mergeSort(left);
	right = mergeSort(right);
	
	if (left[left.size - 1].script_int > right[right.size - 1].script_int)
		result = merge(left, right);
	else
		result = append(left, right);
	return result;	
}

//merge the two arrays
merge(left, right)
{
	result = [];
	
	while (left.size > 0 && right.size > 0)
	{
		if (left[0] <= right[0])
		{
			result = add_to_array(result, left[0]);
			left = array_remove_index(left, 0);
		}
		else
		{
			result = add_to_array(result, right[0]);
			right = array_remove_index(right, 0);
		}
	}
	while (left.size > 0)
		result = append(result, left);
	while (right.size > 0)
		result = append(result, right);
		
	return result;
}

//simple add right array to the end of left array
append(left, right)
{
	for (x = 0; x < right.size; x++)
		left = add_to_array(left, right[x]);
	return left;
}

setupCurtains()
{
	flag_wait( "power_on" );
	//wait(2);
	//level thread moveCurtains("left_curtain");
	//level thread moveCurtains("right_curtain");
	
	curtains = getent("theater_curtains", "targetname");
	curtains_clip = getent("theater_curtains_clip", "targetname");
	
	curtains_clip notsolid();
	curtains_clip connectpaths();
	curtains maps\zombie_theater::theater_playanim("curtains_move" );
	
	curtains waittill ("curtains_move_done");

	flag_set( "curtains_done" );
	
	level thread lower_movie_screen();
	
}

moveCurtains(curtent)
{
	curtain = getent( curtent, "targetname");
	curtorg = curtain.origin;
	time = 2; 	

	curtain thread monitorCurtain(curtorg);
	curtain connectpaths();
	curtain MoveTo( curtain.origin + curtain.script_vector, time, time * 0.25, time * 0.25 );
	curtain playsound( "curtain_open" );
}

monitorCurtain(curtorg)
{
	clip = getent(self.target, "targetname");
	
	while (IsDefined(clip))
	{
		if ((abs(curtorg[0] - self.origin[0])) >= 38 ) 
		{		
			clip connectpaths();
			clip NotSolid();
			if (IsDefined(clip.target))
				clip = getent(clip.target, "targetname");
			else
				clip = undefined;
		}
		
		wait (0.1);
	}
}
	
open_left_curtain()
{
	flag_wait( "power_on" );
	curtain = GetEnt("left_curtain", "targetname");
	
	if(isDefined(curtain))
	{
		wait(2);
		//curtain waittill("movedone");	
		curtain_clip = getentarray("left_curtain_clip", "targetname");
		for (i = 0; i < curtain_clip.size; i++)
		{
			curtain_clip[i] connectpaths();
			curtain_clip[i] notsolid();
		}		
		curtain connectpaths();
		curtain movex(-300, 2);
	}	
}

open_right_curtain()
{
	flag_wait( "power_on" );
	curtain = GetEnt("right_curtain", "targetname");
	
	if(isDefined(curtain))
	{
		wait(2);	
		//curtain waittill("movedone");
		curtain_clip = getentarray("right_curtain_clip", "targetname");
		for (i = 0; i < curtain_clip.size; i++)
		{
			curtain_clip[i] connectpaths();
			curtain_clip[i] notsolid();
		}			
		curtain connectpaths();
		curtain movex(300, 2);	
	}	
}

lower_movie_screen()
{
	//	flag_wait( "power_on" );
	screen = GetEnt("movie_screen", "targetname");
	
	if(isDefined(screen))
	{
		screen movez(-466, 6);
		screen playsound( "evt_screen_lower" );	
	}
	//for (x = 0; x < level.images.size; x++)
	//	level.images[x] movez(-466, 6);
	//wait (4);
	screen waittill ("movedone");
	
	wait (2);
	
	// level notify( "sip" ); 
	clientnotify( "sip" );		// ww: notify talks to zombie_theater_fx.csc to start the projector fxs
	// exploder(314);				// projection light on	
	//level thread play_images();
}

play_images()
{
	x = 0;
	while (1)
	{
		if (x > level.images.size - 1)
			x = 0;
		level.images[x] show();
		wait(0.1);
		level.images[x] hide();
		x++;
	}
}

// Init the reel triggers
movie_reels_init()
{
	// active reel array
	
	// each room will have three places the reel could go
	clean_bedroom_reels = GetEntArray( "trigger_movie_reel_clean_bedroom", "targetname" );
	bear_bedroom_reels = GetEntArray( "trigger_movie_reel_bear_bedroom", "targetname" );
	interrogation_reels = GetEntArray( "trigger_movie_reel_interrogation", "targetname" );
	pentagon_reels = GetEntArray( "trigger_movie_reel_pentagon", "targetname" );
	
	// put all the arrays in to a master array
	level.reel_trigger_array = [];
	level.reel_trigger_array = add_to_array( level.reel_trigger_array, clean_bedroom_reels, false );
	level.reel_trigger_array = add_to_array( level.reel_trigger_array, bear_bedroom_reels, false );
	level.reel_trigger_array = add_to_array( level.reel_trigger_array, interrogation_reels, false );
	level.reel_trigger_array = add_to_array( level.reel_trigger_array, pentagon_reels, false );
	
	// randomize the master array. the first three arrays will be chosen for reel placement
	level.reel_trigger_array = array_randomize( level.reel_trigger_array );
	
	// now pick one reel out of each of the first three arrays
	reel_0 = movie_reels_random( level.reel_trigger_array[0], "ps1" );
	reel_1 = movie_reels_random( level.reel_trigger_array[1], "ps2" );
	reel_2 = movie_reels_random( level.reel_trigger_array[2], "ps3" );
	
	// combine all the individual reels in to one array 
	temp_reels_0 = array_merge( clean_bedroom_reels, bear_bedroom_reels );
	temp_reels_1 = array_merge( interrogation_reels, pentagon_reels );
	all_reels = array_merge( temp_reels_0, temp_reels_1 );
	
	// thread off the movie reel func on all reels. func will hide reels that were not chosen for display
	array_thread( all_reels, ::movie_reels );
	
	level thread movie_projector_reel_change();
}

// Randomly choose one of the reels in a reel array for display
movie_reels_random( array_reel_triggers, str_reel )
{
	if( !IsDefined( array_reel_triggers ) )
	{
		return;
	}
	else if( array_reel_triggers.size <= 0 )
	{
		return;
	}
	else if( !IsDefined( str_reel ) )
	{
		return;
	}
	
	random_reels = array_randomize( array_reel_triggers );
	
	// grab the first one out of teh random array
	random_reels[0].script_string = str_reel; // TODO: THIS WILL HAVE TO BE MADE INTO A SIDE FUNCTION IF WE GET 20-24 VIDEOS
	random_reels[0].reel_active = true;
	return random_reels[0]; // return the first reel in the array as the one to display

}

// watch the reel to get picked up. the trigger should be targetting a script model
// SELF == TRIGGER
movie_reels()
{
	if( !IsDefined( self.target ) )
	{
		/#
		AssertEx( IsDefined( self.target ), "one of the reel triggers missing target" );
		#/
		return;
	}
	
	// define the model being used for the reel
	self.reel_model = GetEnt( self.target, "targetname" );
	
	if( !IsDefined( self.reel_active ) )
	{
		self.reel_active = false;
	}
	
	if( IsDefined( self.reel_active ) && self.reel_active == false )
	{
		// turn off the trigger and hide the model
		self.reel_model Hide();
		self SetCursorHint( "HINT_NOICON" );
		self SetHintString( "" );
		self trigger_off();
		
		// end the function
		return;
	}
	else if ( IsDefined( self.reel_active ) && self.reel_active == true )
	{
		// set the reel model
		self.reel_model SetModel( "zombie_theater_reelcase_obj" ); // TODO: SPECIAL MODELS WILL NEED TO BE INPUT AT SOME POINT
		
		// set hint string and cursor image
		self SetCursorHint( "HINT_NOICON" );
		// self SetHintString( &"ZOMBIE_THEATER_FILM_REEL" ); // ww:removing hing strings
	}
	
	// wait for power
	flag_wait( "power_on" );
	
	while( self.reel_active == true )
	{
		self waittill( "trigger", who );
		
		// make sure that the player doesn't already have a reel
		if( is_true( who._has_reel ) )
		{
			continue; // the player doesn't get the reel since they have one already
		}
		else
		{
			who PlaySound( "zmb_reel_pickup" );
			
			self.reel_model Hide();
			self trigger_off();
			
			// put the reel string on the player that hit the trigger
			who.reel = self.script_string;
			who._has_reel = true;
			self.reel_active = false;
			
			who thread theater_movie_reel_hud();
		}
		
	}
}

// Projector trigger watching for a player with a reel
movie_projector_reel_change()
{
	screen_struct = getstruct( "struct_theater_screen", "targetname" );
	projector_trigger = GetEnt( "trigger_change_projector_reels", "targetname" );
	
	projector_trigger SetCursorHint( "HINT_NOICON" );
	//projector_trigger SetHintString( &"ZOMBIE_THEATER_REEL_PROJECTOR" ); // ww:removing hing strings
	
	// just in case the struct is missing the beginning string
	if( !IsDefined( screen_struct.script_string ) )
	{
		screen_struct.script_string = "ps0";
	}
	
	while( true )
	{
		projector_trigger waittill( "trigger", who );
		
		if( IsDefined( who.reel ) && IsString( who.reel ) )
		{
			clientnotify( who.reel ); // ww: this should be a three digit notify that is set on the reels above
			
			who notify( "reel_set" );
			
			who thread theater_remove_reel_hud();
			who thread maps\zombie_theater_amb::play_radio_egg( 2 );
			who PlaySound( "zmb_reel_place" );
			
			who.reel = undefined;
			wait( 3 );
		}
		else
		{
			wait( 0.1 );
		}
		
		wait( 0.1 );
	
	}
	
}

// WW:add the hud element for the reel so a player knows they have it
theater_movie_reel_hud()
{
	self.reelHud = create_simple_hud( self );

	self.reelHud.foreground = true;
	self.reelHud.sort = 2;
	self.reelHud.hidewheninmenu = false;
	self.reelHud.alignX = "center";
	self.reelHud.alignY = "bottom";
	self.reelHud.horzAlign = "user_right";
	self.reelHud.vertAlign = "user_bottom";
	self.reelHud.x = -200;
	self.reelHud.y = 0;

	self.reelHud.alpha = 1;
	self.reelHud setshader( "zom_icon_theater_reel", 32, 32 );
	
	self thread	theater_remove_reel_on_death();

}

// WW: remove the battery hud element
theater_remove_reel_hud()
{
	if( IsDefined( self.reelHud ) )
	{
		self.reelHud Destroy();
	}
	
	self._has_reel = false;
}

// WW: removes hud element if player dies
theater_remove_reel_on_death()
{
	self endon( "reel_set" );
	
	self waittill_either( "death", "_zombie_game_over" );
	
	self thread theater_remove_reel_hud();

}