/*
//-- Level: Full Ahead
//-- Level Designer: Christian Easterly
//-- Scripter: Jeremy Statz
*/

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\fullahead_util;
#include maps\fullahead_drones;
#include maps\_anim;
#include maps\_music;

// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	// relocate player to correct position
	player_to_struct( "p2wrapup_playerstart" );
	
	add_global_spawn_function( "axis", ::spawnfunc_ikpriority ); // happens in shiparrival
	add_global_spawn_function( "allies", ::spawnfunc_ikpriority );
	
	maps\fullahead_p2_nazibase::cleanup();
	
	default_fog();
	
	player = get_player();
	
	trig = getent( "deck_sas_start_trigger", "targetname" );
	trig useby(player);
	
	fa_visionset_bright();
	
	friend = simple_spawn_single( "p2shipfirefight_ally" );
	friend.script_noteworthy = "p2firefight_player_friendly"; // used for the team switching stuff
	friend thread magic_bullet_shield();
	friend.name = "Nevski";
	level.nevski = friend;
	
	level.nevski teleport_ai_to_node( "p2wrapup_nevski_start", "targetname" );
	
	objective_add( 0, "done", &"FULLAHEAD_OBJ_NAZIBASE_STEINER" );
	objective_add( 1, "done", &"FULLAHEAD_OBJ_SECURE_WEAPON" );
	objective_add( 2, "active", &"FULLAHEAD_OBJ_ESCAPE_SHIP_DETONATE" );
	level thread objectives(2);
	run();
}

run()
{
	init_event();
	level.streamHintEnt = createStreamerHint((-1160, -1152, -152), 1.0 );
	level thread wrapup_gameplay();
		
	//flag_wait( "P2WRAPUP_EXIT" );
	trigger_wait( "wrapup_shipexplode_trigger" );	//end earlier
	wait 2;
	outro_narration();
	cleanup();
	nextmission();
}

init_event()
{
	fa_print( "init p2 wrapup\n" );
	
	//level.nevski maps\_prisoners::make_prisoner();
	level.nevski.disableArrivals = true;
	level.nevski.disableExits = true;

	//level.nevski.animname = "generic";
	level.nevski.ignoreall = true;
	level.nevski.ignoreme  = true;
	level.nevski set_run_anim( "end_run" );
	level.nevski gun_remove();	//sometimes he won't use prisoner run so just use combat run -jc

	level.percent_chance_ragdoll_drone_spawned = 35;
	get_player() enableweapons();
	autosave_by_name( "fullahead" );
}

// gets run through at start of level
init_flags()
{
	fa_print( "all p2 flags initialized\n" );
	flag_init( "P2WRAPUP_EXIT" );
	flag_init( "P2WRAPUP_SHIP_EXPLODED" );
	flag_init( "P2WRAPUP_NARRATION_FINISHED" );
}

cleanup()
{
	level.streamHintEnt delete();
	fa_print( "cleanup p2 wrapup\n" );
}

objectives( curr_obj_num )
{
	level endon( "remove_3D_objective" );

	struct = getstruct( "p2wrapup_objective", "targetname" );
	objective_position( curr_obj_num, level.nevski );
	objective_set3d( curr_obj_num, true, "default", &"FULLAHEAD_MARKER_FOLLOW" );
	flag_wait( "P2WRAPUP_SHIP_EXPLODED" );
	
	objective_state( curr_obj_num, "done" );
	curr_obj_num++;

//	level thread objective_shutdown_thread( curr_obj_num );
//	objective_add( curr_obj_num, "active" );
//	objective_position( curr_obj_num, level.nevksi );
//	objective_set3d( curr_obj_num, true, "default", &"FULLAHEAD_MARKER_FOLLOW" );
}

objective_shutdown_thread( curr_obj_num )
{
	level waittill( "remove_3D_objective" );
	objective_delete( curr_obj_num );
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

wrapup_gameplay()
{
	level thread explosion_thread();
	level thread explosion_failsafe();
	
	//level.nevski thread wait_for_player_thread( node );
	
	wait(0.5);
	
	//     level.scr_sound["Nevski"]["gogo"] = "vox_ful1_s06_132A_nevs"; //Go, Reznov!  Go!!!
	level.nevski headtracking_start( get_player() );
	//level.nevski anim_single( level.nevski, "gogo", "Nevski" );
	level.nevski headtracking_stop();
	
//	trigger_wait( "p2wrapup_exit", "targetname" );
//	flag_set( "P2WRAPUP_EXIT" );
}

//if player doesn't move, trigger anim -jc
explosion_failsafe()
{
	level endon("ship_explode");

	node = getnode( "p2wrapup_nevski_destination", "targetname" );
	level.nevski setgoalnode( node );
//	level.nevski waittill( "goal" );
	wait 7;
	trigger_use( "wrapup_shipexplode_trigger" );
		
}
// self is Nevski
//wait_for_player_thread( node )
//{
//	level endon( "P2WRAPUP_NARRATION_FINISHED" );
//	
//	p = get_player();
//	
//	while( true )
//	{
//		wait( 0.8 );
//		
//		dist_from_player = distance( self.origin, p.origin );
//		if( dist_from_player > 256 )
//		{
//			self setgoalpos( self.origin );
//			//self orientMode( "face point", p.origin );
//			level.nevski headtracking_start( p );
//		}
//		else
//		{
//			level.nevski headtracking_stop();
//			self setgoalnode( node );
//		}
//	}
//}

explosion_thread()
{
	lookmodel = getent( "wrapup_lookat", "targetname" );
	if( !isdefined(lookmodel) )
	{
		lookstruct = getstruct( "wrapup_lookat", "targetname" );
		lookmodel = spawn( "script_model", lookstruct.origin );
		lookmodel SetModel("tag_origin");
	}
	
	trigger_wait( "wrapup_shipexplode_trigger" );
	level notify("ship_explode");
	
	
	//TUEY Set music state to IT IS OVER
	setmusicstate ("IT_IS_OVER");
		
	p = get_player();
	p shellshock( "default", 3 );
	earthquake( 1.0, 2, p.origin, 200, p );
	p PlayRumbleOnEntity( "artillery_rumble" );

	//SOUND - Shawn J - ship explo & sink	
	playsoundatposition ("exp_ship_final_explo", (14530, 13655, 324) );
	level thread ship_sinking_sound();
	  
	level.nevski thread anim_single_aligned( level.nevski, "explosion_react", undefined, "nevski" );
	level.nevski AnimMode( "gravity" );

	p setstance( "prone" );
	p AllowCrouch( false );
	p AllowStand( false );
	p AllowJump( false );
	
	p look_at( level.nevski.origin, 0.8 );
	p setViewLockEnt( level.nevski );
	wait( 0.5 );
	p = get_player();
	p clearViewLockEnt();
	
	level thread ship_explosion();
	
	p look_at( lookmodel.origin, 0.4 );
	p setViewLockEnt( lookmodel );
	wait( 1.5 );
	p = get_player();
	p clearViewLockEnt();

//	org = Spawn( "script_origin", p.origin );
//	p PlayerLinkToDelta( org, undefined, 0, 60, 60 );

	
	flag_set( "P2WRAPUP_SHIP_EXPLODED" );
}

ship_explosion()
{
	//SOUND - Shawn J - ship explo & sink
	playsoundatposition ("exp_ship_final_explo", (14530, 13655, 324) );

	//fx of ship exploding
	exploder(545);
	p = get_player();
	Earthquake( 1.0, 5, p.origin, 200, p );
	p PlayRumbleOnEntity( "artillery_rumble" );

	//start fx anim
	level notify("ship_debris_start");
		
	// temp!  Grab a bunch of entities and explode them all
	ents = getstructarray( "wrapup_explosion_struct", "targetname" );
	
	wait 3;
		
	front = getentarray( "wrapup_fakeship_front", "targetname" );
	back = getentarray( "wrapup_fakeship_rear", "targetname" );
	
	for( i=0; i<front.size; i++ )
	{
		front[i] moveto( front[i].origin + (0,64,-512), 20 );
		//front[i] rotateto( (6,6,6), 20 );
	}
	
	for( i=0; i<back.size; i++ )
	{
		back[i] moveto( back[i].origin + (0,-64,-512), 20 );
		//back[i] rotateto( (6,6,6), 20 );
	}
	
	//fx of ice cracking and bubbling
	exploder(550);
	
	player = get_player();
	
	strength = 500;
	
	for( ii=0; ii<3; ii++ )
	{
		for( i=0; i<ents.size; i++ )
		{
//			num = (i%4)+1;
//			exp_key = "explosion_" + num;
//			playfx( level._effect[exp_key], ents[i].origin );
//			playsoundatposition ("exp_ship_final_explo", ents[i].origin );
//			wait(0.5);
//				
//			earthquake( 0.4, 0.75, player.origin, strength );
//			strength *= 0.9;
			
			// toss ragdoll drones around
			if( isdefined(ents[i].script_noteworthy ) )
			{
				// passing in target
				level thread get_ragdoll_drones( ents[i].target );
			}
		}
	}	
}

get_ragdoll_drones( start_struct_name )
{
	// grab all the struct with this name
	ents = GetStructArray( start_struct_name, "targetname" );
	
	// cycle thru drone starting points
	for( i=0; i<ents.size; i++ )
	{
		randomize = RandomInt(100);
		
		if( randomize < level.percent_chance_ragdoll_drone_spawned )
		{
			ents[i] thread toss_ragdoll_drones();
		}
	}
}

toss_ragdoll_drones()
{
	wait(RandomFloat(1.5));
	
	drone = fa_drone_spawn( self, "axis" );
	drone HidePart("tag_weapon");
	
	assert(isdefined(self.target));
	node_dest = GetStruct( self.target, "targetname" );

	// kill them and toss them toward the player
	drone StartRagDoll();
	
	dir = Vector_Multiply( VectorNormalize( node_dest.origin - self.origin ), RandomIntRange(35,65));
	dir = dir + ( RandomIntRange(-50, 50), RandomIntRange(-50, 50), RandomInt(50));
	drone DoDamage(drone.health*2, drone.origin);
	wait(.05);
	
	drone LaunchRagDoll( dir, drone.origin );			
}

outro_narration_callback( camera_ent )
{

	player = get_players()[0];
	player DisableClientLinkTo();
	player DisableWeapons();
	assertex(!isdefined(level.current_hands_ent), "Player body already exists when it shouldn't.");
	level.current_hands_ent = spawn_anim_model( "playerbody" );	
	level.current_hands_ent.animname = "playerbody";
	level.current_hands_ent.origin = self.origin;
	level.current_hands_ent.angles = self.angles;
	self thread anim_single( self, "narr_4" );

	self anim_first_frame( level.current_hands_ent, "narr_4", undefined, "playerbody" );	
	player PlayerLinkToAbsolute( level.current_hands_ent, "tag_player");
	self thread anim_single_aligned( level.current_hands_ent, "narr_4", undefined, "playerbody" );
	hud_utility_hide("white");

	level waittill("start_fade_out");
	flag_set( "reznov_cutscene_startfade" );
	//self anim_single( self, "out11", "Reznov" );
	
	//SOUND - Shawn J - snow gusts & snapshot notify
	playsoundatposition("evt_blizzard_gust",(0,0,0));

	wait( 5.0 ); // added wait time for snowy fade out effect
	flag_set( "reznov_cutscene_done" );
	level.current_hands_ent delete();
	player unlink();
	player EnableWeapons();


}

outro_narration()
{
//     level.scr_sound["Reznov"]["out1"] = "vox_ful1_s06_133A_rezn"; //NARRATION I escaped the ship, but I could not run forever... Eventually I was captured, and sent to Vorkuta...
//     level.scr_sound["Reznov"]["out2"] = "vox_ful1_s06_134A_rezn"; //NARRATION Mason, listen to me...

	p = get_player();
	
	p anim_single( p, "out1", "Reznov" );
	//p thread anim_single( p, "out2", "Reznov" );
	flag_wait( "P2WRAPUP_SHIP_EXPLODED" );
	
	level notify( "remove_3D_objective" );
	
	player = get_players()[0];
	
	player freezecontrols(true);
	
	//SOUND - Shawn J - snow gusts & snapshot notify
	playsoundatposition("evt_blizzard_gust",(0,0,0));
	
	player snowy_enter_vignette();
	
	fade_out( 1.8, "white" );
	
	do_reznov_cutscene( ::outro_narration_callback );
	flag_set( "P2WRAPUP_NARRATION_FINISHED" );
	p fa_show_hud( false );	//turn off compass bc end of level -jc
}

ship_sinking_sound()
{
	sound_ent_sink = spawn( "script_origin" , (14530, 13655, 324));	
	sound_ent_sink playloopsound ("evt_ship_sink", 1);	
	realwait( 13 );
	sound_ent_sink stoploopsound( 4 );			
	realwait (5);
	sound_ent_sink delete();			
}