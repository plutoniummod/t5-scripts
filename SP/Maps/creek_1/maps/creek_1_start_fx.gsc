#include maps\_utility; 
#include common_scripts\utility;
#include maps\_anim;

// fx used by util scripts
precache_util_fx()
{
	
}

// Scripted effects
precache_scripted_fx()
{
	// effects inside heli 
	
	// lower panel
	level._effect["huey_tag_lower_panel"]		= LoadFX("maps/creek/fx_sparks_heli_lwr_pnl_fxr");

	// mid panel
	level._effect["huey_tag_mid_panel"]			= LoadFX("maps/creek/fx_sparks_heli_mid_pnl_fxr");
	
	// upper panel
	level._effect["huey_tag_upper_panel"]		= LoadFX("maps/creek/fx_sparks_heli_upper_pnl_fxr");
	
	// door right
	level._effect["huey_tag_side_door"]			= LoadFX("maps/creek/fx_water_heli_spill_sm");

	// door left
	level._effect["huey_tag_side_door_left"]	= LoadFX("maps/creek/fx_water_heli_spill_sm");

	// copilot shot
	level._effect["copoilot_shot"]			    = LoadFX("maps/creek/fx_impact_heli_pilot");

	// copilot blood cloud
	level._effect["copoilot_shot_cloud"]		= LoadFX("bio/blood/fx_blood_cloud_uw");

	// door open
	level._effect["door_open"]			   		= LoadFX("maps/creek/fx_water_heli_door_open");

	// sampan
	level._effect["sampan_large"]			   	= LoadFX("maps/creek/fx_water_wake_sanpan_xlg");

	// barnes
	level._effect["water_wake"]			   	    = LoadFX("bio/player/fx_player_water_waist_ripple");

	// player
	level._effect["player_face_water"]			= LoadFX("bio/player/fx_player_water_heli_submerge");
	
	// player sticks hand in water
	level._effect["player_hand_water"]			= LoadFX("bio/player/fx_player_water_knee_ripple");

	// dangling wire
	level._effect["dangling_wire"]				= LoadFX("maps/creek/fx_sparks_heli_wire_sm");

	// dangling wire main
	level._effect["dangling_wire_main"]			= LoadFX("maps/creek/fx_sparks_heli_wire_lg");

	// vc bloodcloud
	level._effect["vc_blood_cloud"]				= LoadFX("bio/blood/fx_blood_cloud_uw_surface");
}


main()
{
	precache_util_fx();
	precache_scripted_fx();

	setup_fx_anims();
}

// --------------------------------------------------------------------------------
// ---- effects controlled per event basis ----
// --------------------------------------------------------------------------------
handle_effects() // self = level
{
	flag_wait("heli_in_place");			// set when heli is ready to animate
	
	Assert( IsDefined( level.intro_huey ) );

	// save huey for reference
	huey = level.intro_huey;

	// setup tags
	huey.effect_tags = [];
	huey.effect_tags[huey.effect_tags.size] = "tag_lower_panel";
	huey.effect_tags[huey.effect_tags.size] = "tag_mid_panel";
	huey.effect_tags[huey.effect_tags.size] = "tag_upper_panel";
	huey.effect_tags[huey.effect_tags.size] = "tag_side_door";
	huey.effect_tags[huey.effect_tags.size] = "tag_side_door_left";

	huey.effect_tag_origin["tag_lower_panel"] 	 = Spawn( "script_model", huey GetTagOrigin( "tag_lower_panel" ) );
	huey.effect_tag_origin["tag_lower_panel"] SetModel("tag_origin");

	huey.effect_tag_origin["tag_mid_panel"]   	 = Spawn( "script_model", huey GetTagOrigin( "tag_mid_panel" ) );
	huey.effect_tag_origin["tag_mid_panel"] SetModel("tag_origin");

	huey.effect_tag_origin["tag_upper_panel"] 	 = Spawn( "script_model", huey GetTagOrigin( "tag_upper_panel" ) );
	huey.effect_tag_origin["tag_upper_panel"] SetModel("tag_origin");

	huey.effect_tag_origin["tag_side_door"]   	 = Spawn( "script_model", huey GetTagOrigin( "tag_side_door" ) );
	huey.effect_tag_origin["tag_side_door"] SetModel("tag_origin");

	huey.effect_tag_origin["tag_side_door_left"] = Spawn( "script_model", huey GetTagOrigin( "tag_side_door_left" ) );
	huey.effect_tag_origin["tag_side_door_left"] SetModel("tag_origin");

	//--- Following flags wait until perticular event is done in the script ----//
	//--- Just up stuff you need after the flag_wait of every event ------------//

	// event 1
	flag_wait("heli_in_place");			  // set when heli is ready to animate

	// one off effects at the start, now handleed in exploder
	//level thread event1_play_right_off_effects( huey );

	// effects for door open
	level thread event1_door_open();

	// pilot blood
	level thread event1_copilot_shot_cloud();

	// sampan wakes
	level thread event1_sampan_wakes_think();

	// heli ambiance
	level thread event1_heli_ambiance();

	// barnes
	level thread event1_barnes_effects();

	// player
	level thread event1_player_water_in_face();

	// helicopter inside Damage
	level thread event1_helicopter_internal_damage();

	// main wire
	level thread event1_main_wire();

	// whizbie
	level thread event2_fake_bullet_whizbies();

	flag_wait("player_woke_up");		  // player recovered from crash
	flag_wait("heli_crash_scene_done");   // player is out of the huey
	flag_wait("vcs_killed"); 			  // player killed VC's on sampans
		
	flag_wait("open_huey_door_button_pressed");    // set when player hits x to open the door
	flag_wait("open_huey_door");          // set when the player animation really starts opening the door
	flag_wait("start_fall" );			  // set when huey should fall/sink.
	flag_wait("player_below_water");	  // set when player camera goes completely under that water when player falls	
	flag_wait("reznov_open_door");		  // set when reznov opens the door with player

	// event 2
	flag_wait("player_meatshield_ready");     	// set when player interacts with sampan1 for meatshield
	flag_wait("meatshield_alerted"); 			// player is ready for meatshield
	flag_wait("meatshield_finished");			// set when meatshiled is completed
}

// right off effects
event1_play_right_off_effects( huey )
{
	// start effects
	for( i = 0; i < huey.effect_tags.size; i++ )
	{
		if( IsDefined( level._effect["huey_" + huey.effect_tags[i] ] ) )
		{
			// grab the fake origin
			huey.effect_tag_origin[ huey.effect_tags[i] ] LinkTo( huey, huey.effect_tags[i] );
			huey.effect_tag_origin[ huey.effect_tags[i] ].origin = huey GetTagOrigin( huey.effect_tags[i] );
			huey.effect_tag_origin[ huey.effect_tags[i] ].angles = huey GetTagAngles( huey.effect_tags[i] );

			PlayFXOnTag( level._effect["huey_" + huey.effect_tags[i] ], huey.effect_tag_origin[ huey.effect_tags[i] ], "tag_origin" );
		}
	}

	// wait until player is about to fall and then set the visionset to default
	flag_wait("player_below_water");

	// delete effects
	for( i = 0; i < huey.effect_tags.size; i++ )
	{
		if( IsDefined( level._effect["huey_" + huey.effect_tags[i] ] ) )
		{
			// grab the fake origin
			huey.effect_tag_origin[ huey.effect_tags[i] ] Delete();
		}
	}
	
}

// copilot shot
event1_copilot_shot( guy )
{
	// event 1
	flag_wait("heli_in_place");			  // set when heli is ready to animate
	
	// copilot is hit
	PlayFXOnTag( level._effect["copoilot_shot"], level.pilots[1], "J_spine4" );
	clientNotify( "cop_sht" );
	guy PlaySound( "vox_copilot_death_gurgle" );
}


// pilot shot
event1_copilot_shot_cloud()
{
	// wait until player is about to fall and then set the visionset to default
	flag_wait("player_below_water");		  
	
	// copilot is hit
	PlayFXOnTag( level._effect["copoilot_shot_cloud"], level.pilots[1], "J_spine4" );
}

// door open effects
event1_door_open()
{
	// event 1
	flag_wait( "reznov_open_door" ); // set when heli is ready to animates

	// water open door
	PlayFXOnTag( level._effect["door_open"], level.intro_huey, "tag_side_door" );
}

// sampan wakes main
event1_sampan_wakes_think()
{
	// event 1
	flag_wait("heli_in_place");			  // set when heli is ready to animate
	
	array_thread( GetEntArray( "boats", "targetname" ), ::event1_sampan_wakes_internal );
	
	// sampan
	sampan6 = GetEnt( "sampan6", "targetname" );
	sampan6 thread event1_sampan_wakes_internal();
}

//sampan wakes
event1_sampan_wakes_internal() // self = boat
{
	self waittill("start_search_loop");	// sent by the main script when these boats are in place.

	while(1)
	{
		pos = self GetTagOrigin( "tag_origin" );
		angles = self GetTagAngles( "tag_origin" );

		water_height = GetWaterHeight( pos );
		ripple_pos = ( pos[0], pos[1], water_height );

		model = Spawn( "script_model", ripple_pos  );
		model SetModel( "tag_origin" );
		model.angles =  angles;

		PlayFXOnTag( level._effect["sampan_large"], model, "tag_origin" );
		model thread delete_after_3_sec();

		wait(1);
	}

}


delete_after_3_sec() // self = model
{
	wait(3);
	
	self Delete();
}

// heli ambiance
event1_heli_ambiance()
{
	// event 1
	flag_wait("heli_in_place");	  // set when heli is ready to animate
	
	exploder( 1001 );

	// wait until player is about to fall and then set the visionset to default
	flag_wait("player_below_water");
	
	stop_exploder( 1001 );	

	exploder( 1002 );
}

// barnes
event1_barnes_effects()
{
	// event 1
	flag_wait("heli_in_place");			  // set when heli is ready to animate
	
	// In wake up loop for the player we only need pilots in place, everything else needs to animate later on.
	flag_wait( "player_woke_up" );

	water_height = GetWaterHeight( level.barnes.origin );
		
	while( !flag( "player_below_water" ) )
	{
		ripple_pos = ( level.barnes.origin[0], level.barnes.origin[1], water_height );
		PlayFX( level._effect["water_wake"], ripple_pos );
		wait( 0.6 );
	}
}

event1_player_water_in_face()
{
	// event 1
	flag_wait("heli_in_place");			  // set when heli is ready to animate
		
	flag_wait("player_below_water" );

	PlayFXOnTag( level._effect["player_face_water"], level.event1_player_model, "tag_camera" );
}


event1_player_hand_touch_water( guy )
{
	// event 1
	flag_wait("heli_in_place");			  // set when heli is ready to animate
	
	exploder( 1003 );

	position = level.event1_player_model GetTagOrigin( "tag_player" );

	water_height = GetWaterHeight( position );

	ripple_pos = ( position[0], position[1], water_height );

	PlayFX( level._effect["player_hand_water"], ripple_pos );
}

//set off exploder
event1_player_hand_fire_into_huey( guy )
{
	exploder(1004);
}


event1_helicopter_internal_damage()
{
	// event 1
	flag_wait("heli_in_place");			  // set when heli is ready to animate

	damage_model = GetEnt("fxanim_creek_hueydamage_mod", "targetname");
	damage_model LinkTo( level.intro_huey, "body_animate_jnt", (0,0,0), (0,0,0) );
	
	spark_fx = Spawn( "script_model", damage_model.origin );
	spark_fx SetModel("tag_origin");
	spark_fx LinkTo( damage_model, "chair_wires_03_jnt", (0,0,0), (0,0,0) );

	// play effects on side wire, dangling wire
	PlayFXOnTag( level._effect["dangling_wire"], spark_fx, "tag_origin" );
	
	//deletes it when player opens door.
	flag_wait("open_huey_door_button_pressed");
	
	spark_fx Delete();
}

//acb 03.27.10 -update to call on one person or wait until underwater.
//This is bad because this has been written specifically for the current state of meatshield. 
event2_vc_death_blood_cloud( single_play ) // self = vc
{
	if(IsDefined(single_play))
	{
		if(is_true(single_play))
		{
			if( is_mature() )
			{
				//this is for the woods vignette vc
				PlayFXOnTag( level._effect["vc_blood_cloud"], self, "J_spine4" );	
			}
		}
		else if(!is_true(single_play))
		{
			//This logic is specifically for the meatshield grab guy
			array = [];
			x = 5;
			
			while(1)
			{
				//grab a corpse within 100 units of the player.
				array = entsearch(level.CONTENTS_CORPSE, get_players()[0].origin, 200);
				if(array.size > 0)
				{
					break;
				}
				
				if(x <= 0)
				{
					break;
				}
				
				wait 1;
				x--;
			}
			
			for(i = 0; i < array.size; i++)
			{
				if( isdefined( array[i] ) && isdefined( array[i].script_noteworthy ) )
				{
					if(array[i].script_noteworthy == "meatshield_vc")
					{
						if( is_mature() )
						{
							PlayFXOnTag( level._effect["vc_blood_cloud"], array[i], "J_spine4" );	
						}
					}
				}
			}			
		}
	}
	else
	{
		//this case handles any other sampan vc and is threaded on each guy in event2_vc_death
		// wait until player is about to fall and then set the visionset to default
		flag_wait("player_below_water");		  
		
		//ACB hack for blood. awkward settup with meatshield guys dying custom deaths.
		if(self.animname != "vc5" ) //vc5 is the first boat, that guy never falls in the water. 
		{
			if( is_mature() )
			{
				PlayFXOnTag( level._effect["vc_blood_cloud"], self, "J_spine4" );
			}
		}
	}
}

event2_fake_bullet_whizbies()
{
	level endon( "meatshield_alerted" );	

	// wait until player is about come out of the door
	flag_wait("heli_crash_scene_done");

	// now have fake whizbies in front of the player
	// get a random vc and use his tag_flash as a starting point of the bullet
	ai = GetEntArray( "ai_meatshield_ai", "targetname" );
	
	while( 1 )
	{
/#
//		PrintLn("Whizbies***************************************");		
#/		
		index = RandomIntRange( 0, ai.size );
		random_ai = ai[index];
		start = random_ai GetTagOrigin("tag_flash");

		player = get_players()[0];
		direction = AnglesToForward( player GetPlayerAngles() );
		pos = player get_eye();
		end =  pos + vector_scale( direction, RandomIntRange( 20, 50 ) );

		bullet_dir = start - end;
		end = end + vector_scale( VectorNormalize( bullet_dir ), 100 );

		MagicBullet( random_ai.weapon, start, end, random_ai );

		wait( 0.1 );
	}	
}

#using_animtree("fxanim_props");
event1_main_wire()
{
	flag_wait( "heli_in_place" ); // set when heli is ready to animate
	
	level.intro_huey.wire_model = GetEnt( "fxanim_creek_hueywire_mod", "targetname" );

	level.intro_huey.wire_model LinkTo( level.intro_huey, "body_animate_jnt", (0,0,0), (0,0,0) );

	wait(4);

	// playing the looping animation
	level.intro_huey.wire_model UseAnimTree(#animtree);
	level.intro_huey.wire_model.animname = "fxanim_props";
	level.intro_huey anim_loop_aligned( level.intro_huey.wire_model, "a_hueywire", "body_animate_jnt", "nothing" );
}

// --------------------------------------------------------------------------------
// ---- Jess - Special section for effects animations ----
// --------------------------------------------------------------------------------

setup_fx_anims()
{
	level.scr_anim["fxanim_props"]["a_hueywire"][0] = %fxanim_creek_hueywire_anim;
	addNotetrack_customFunction( "fxanim_props", "thick_sparks", maps\creek_1_start_fx::event1_hueywire_spark, "a_hueywire" );
}

event1_hueywire_spark( guy )
{
	if( IsDefined( level.intro_huey ) && IsDefined( level.intro_huey.wire_model ) && !flag( "player_below_water" ) )
	{
		// play effects on side wire, dangling wire
		PlayFXOnTag( level._effect["dangling_wire_main"], level.intro_huey.wire_model, "thick_06_jnt" );
		tag_org = level.intro_huey.wire_model GetTagOrigin( "thick_06_jnt" );
		playsoundatposition( "amb_spark_special", tag_org );
	}
}

