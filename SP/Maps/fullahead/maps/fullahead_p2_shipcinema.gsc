/*
//-- Level: Full Ahead
//-- Level Designer: Christian Easterly
//-- Scripter: Jeremy Statz
*/

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;
#include maps\fullahead_util;
#include maps\_anim;
#include maps\fullahead_drones;
#include maps\fullahead_anim;
#include maps\_music;

// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	add_global_spawn_function( "axis", ::spawnfunc_ikpriority ); // happens in shiparrival
	add_global_spawn_function( "allies", ::spawnfunc_ikpriority );
	
	level fade_out( 0.25, "black" ); // should be black from the end of shipcargo
	
	level ship_door_setup( "black" ); // would've happened back in shiparrival
	level thread ship_door_open( "black" ); // would've happened back in shiparrival
	
	// would've happened way back in shipcargo
	ship_door_setup( "cargo" );
	
	maps\fullahead_p2_nazibase::cleanup();
	
	default_fog();
		
	// relocate player to correct position
	player_to_struct( "p2shipcinema_playerstart" );
	
	// would've gone away when we used it earlier
	trig = getent( "p2shipcargo_outro", "targetname" );
	trig delete();
	
	fa_visionset_bright();
	
	// would've happened in shipcargo
	explosives_in_place();

	objective_add( 0, "done", &"FULLAHEAD_OBJ_NAZIBASE_STEINER" );
	objective_add( 1, "done", &"FULLAHEAD_OBJ_SECURE_WEAPON" );
	level thread objectives(2);
	

	run();
}

run()
{
	init_event();
	
	p = get_player();
	//p freezecontrols( true );
	p fa_show_hud( false );
	
	level thread fade_in( 4, "black", 2 ); //hide camera move before 1st scene - jc
	level thread shipcinema_playback();
	level thread narration();

	flag_wait( "P2SHIPCINEMA_COMPLETE" );
	//flag_wait( "P2SHIPCINEMA_NARRATION_COMPLETE" );
	
	// unfreezing of controls happens in shipfirefight now
	
	cleanup();
	maps\fullahead_p2_shipfirefight::run();
}

init_event()
{
	fa_print( "init p2 shipcinema\n" );
	
	//for performance
	get_player() SetClientDvar( "sm_sunSampleSizeNear", 0.5 );
	
	level ship_door_setup( "gas" );
	level thread ship_door_open( "gas" );
	level ship_door_setup( "escape", "anim_rus_shipdoor_pi" );
	level thread ship_door_open( "escape" );
	
	ship_door_setup( "stein" );
	
	//VisionSetNaked( "ab_comp1", 0 );
	
	p = get_player();
	p fa_take_weapons();
	
	align_struct = getstruct( "dragovich_leaves_anim_origin", "targetname" ); // same one in both scenes

	list = [];
	
	level.cin_dragovich = fa_drone_spawn( align_struct, "dragovich" );
	level.cin_dragovich.animname = "dragovich";
	list[list.size] = level.cin_dragovich;
	
	level.cin_steiner = fa_drone_spawn( align_struct, "steiner" );
	level.cin_steiner.animname = "steiner";
	list[list.size] = level.cin_steiner;
	
	level.cin_petrenko = fa_drone_spawn( align_struct, "patrenko" );
	level.cin_petrenko.animname = "petrenko"; // inconsistant yay
	level.cin_petrenko.name = "Petrenko";
	list[list.size] = level.cin_petrenko;
	
	level.cin_kravchenko = fa_drone_spawn( align_struct, "kravchenko" );
	level.cin_kravchenko.animname = "kravchenko";
	list[list.size] = level.cin_kravchenko;
	
	level.cin_reznov = fa_drone_spawn( align_struct, "reznov" );
	level.cin_reznov.animname = "reznov";
	list[list.size] = level.cin_reznov;
	
	level.cin_guy1 = fa_drone_spawn( align_struct, "alliesofficer" );
	level.cin_guy1.animname = "guy1";
	list[list.size] = level.cin_guy1;
	
	level.cin_guy2 = fa_drone_spawn( align_struct, "alliesofficer" );
	level.cin_guy2.animname = "guy2";
	list[list.size] = level.cin_guy2;
	
	level.cin_guy3 = fa_drone_spawn( align_struct, "alliesofficer" );
	level.cin_guy3.animname = "guy3";
	list[list.size] = level.cin_guy3;
	
	level.cin_guy4 = fa_drone_spawn( align_struct, "alliesofficer" );
	level.cin_guy4.animname = "guy4";
	list[list.size] = level.cin_guy4;
	
	level.cin_tvelin = fa_drone_spawn( align_struct, "alliesofficer" );
	level.cin_tvelin.animname = "tvelin";
	level.cin_tvelin.name = "Tvelin";
	list[list.size] = level.cin_tvelin;
	
	level.cin_belov = fa_drone_spawn( align_struct, "gasguy" );
	level.cin_belov.animname = "belov";
	level.cin_tvelin.name = "Belov";
	list[list.size] = level.cin_belov;
	
	level.cin_vikharev = fa_drone_spawn( align_struct, "alliesofficer" );
	level.cin_vikharev.animname = "vikharev";
	level.cin_tvelin.name = "Vikharev";
	list[list.size] = level.cin_vikharev;
	
	level.cin_nevski = fa_drone_spawn( align_struct, "alliesofficer" );
	level.cin_nevski.animname = "nevski";
	level.cin_tvelin.name = "Nevski";
	list[list.size] = level.cin_nevski;
	
	level.cin_brit1 = fa_drone_spawn( align_struct, "britishhigh" );
	level.cin_brit1.animname = "brit1";
	list[list.size] = level.cin_brit1;
	
	level.cin_brit2 = fa_drone_spawn( align_struct, "britishhigh" );
	level.cin_brit2.animname = "brit2";
	list[list.size] = level.cin_brit2;
	
	level.cin_brit3 = fa_drone_spawn( align_struct, "britishhigh" );
	level.cin_brit3.animname = "brit3";
	list[list.size] = level.cin_brit3;
	
	level.cin_everybody = list;
}

// gets run through at start of level
init_flags()
{
	flag_init( "P2SHIPCINEMA_COMPLETE" );
	flag_init( "P2SHIPCINEMA_NARRATION_COMPLETE" );
	maps\fullahead_p2_shipfirefight::init_flags();
}

cleanup()
{
	fa_print( "cleanup p2 shipcinema\n" );
	
	for( i=0; i<level.cin_everybody.size; i++ )
	{
		level.cin_everybody[i] delete();	
	}
	
	level.cin_everybody = undefined;

}

objectives( starting_obj_num )
{
	flag_wait( "P2SHIPCINEMA_COMPLETE" );
	maps\fullahead_p2_shipfirefight::objectives( starting_obj_num );
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

shipcinema_playback()
{
	
	//set vision set for betrayal
	VisionSetNaked( "fullahead_betrayal", 3 );
	level.last_visionset = "betrayal";
	
	fadeout_duration = 1.0;
	old_fov = GetDvarFloat( #"cg_fov" );
	p = get_player();
	align_struct = getstruct( "dragovich_leaves_anim_origin", "targetname" ); // same one in both scenes
	
	exploder( 396 ); // dust and stuff in the betrayal room
	
	SetTimeScale( 0.66 );
	
	//p thread shipcinema_dof();	//removed per jason
	
	mult = 1.1; // Cody says the game FOV doesn't quite match the MotionBuilder FOV.  Here's a knob we can tweak.
	
	//p SetClientDvar( "cg_fov", 40 * mult );
	//level thread fade_in( fadeout_duration, "black", 1 );
	list = build_visible_list( level.cin_dragovich, level.cin_steiner, level.cin_kravchenko, level.cin_petrenko, level.cin_reznov, level.cin_guy1, level.cin_guy2 );
	level thread fade_for_anim( fadeout_duration, "playerbody", "bet_s1" );
	align_struct thread anim_first_frame( list, "bet_s1" );
	align_struct play_player_anim( align_struct, "bet_s1", "playerbody", false, true );
	

	//p SetClientDvar( "cg_fov", 40 * mult );
	level thread fade_in( fadeout_duration, "black", 0.7);
	list = build_visible_list( level.cin_dragovich, level.cin_steiner, level.cin_kravchenko, level.cin_petrenko, level.cin_reznov, level.cin_guy1 );
	level thread fade_for_anim( fadeout_duration, "playerbody", "bet_s2" );
	align_struct thread anim_first_frame( list, "bet_s2" );
	align_struct play_player_anim( align_struct, "bet_s2", "playerbody", false, true );
	
	//p SetClientDvar( "cg_fov", 65 * mult );
	level thread fade_in( fadeout_duration, "black", 0.7 );
	list = build_visible_list( undefined ); // tankshot is player only
	level thread fade_for_anim( fadeout_duration, "playerbody", "bet_tank" );
	align_struct play_player_anim( align_struct, "bet_tank", "playerbody", false, true );
	
	//p SetClientDvar( "cg_fov", 40 * mult );
	level thread fade_in( fadeout_duration, "black", 0.7 );
	list = build_visible_list( level.cin_dragovich, level.cin_kravchenko, level.cin_petrenko, level.cin_reznov, level.cin_guy1, level.cin_guy2 );
	level thread fade_for_anim( fadeout_duration, "playerbody", "bet_s3" );
	align_struct thread anim_first_frame( list, "bet_s3" );
	align_struct play_player_anim( align_struct, "bet_s3", "playerbody", false, true );
	
	//p SetClientDvar( "cg_fov", 58.91 * mult );
	level thread fade_in( fadeout_duration, "black", 0.7 );
	list = build_visible_list( level.cin_petrenko, level.cin_reznov, level.cin_guy1, level.cin_guy2, level.cin_guy3, level.cin_guy4 );
	level thread fade_for_anim( fadeout_duration, "playerbody", "bet_s4" );
	align_struct thread anim_first_frame( list, "bet_s4" );
	align_struct play_player_anim( align_struct, "bet_s4", "playerbody", false, true );
	
	//p SetClientDvar( "cg_fov", 40 * mult );
	level thread fade_in( fadeout_duration, "black", 0.7 );
	list = build_visible_list( level.cin_petrenko, level.cin_reznov, level.cin_guy1, level.cin_guy2, level.cin_guy3 );
	level thread fade_for_anim( fadeout_duration, "playerbody", "bet_s5" );
	align_struct thread anim_first_frame( list, "bet_s5" );
	align_struct play_player_anim( align_struct, "bet_s5", "playerbody", false, true );
	
	//p SetClientDvar( "cg_fov", 65 * mult );
	level thread fade_in( fadeout_duration, "black", 0.7 );
	list = build_visible_list( level.cin_dragovich, level.cin_steiner, level.cin_kravchenko );
	level thread fade_for_anim( fadeout_duration, "playerbody", "bet_s6" );
	align_struct thread anim_first_frame( list, "bet_s6" );
	align_struct play_player_anim( align_struct, "bet_s6", "playerbody", false, true );
	
	SetTimeScale( 1.0 );
	
	level thread door_close_thread();
	level thread gas_release_thread();
	
	VisionSetNaked( "fullahead_nova6", 3 );
	level.last_visionset = "nova6";
	
	stop_exploder( 396 ); // dust and stuff in the betrayal room

	p SetClientDvar( "cg_fov", old_fov ); // because we're back in player mode now, sort of
	level thread fade_in( fadeout_duration, "black", 0.7 );
	list = build_visible_list( level.cin_petrenko, level.cin_guy1, level.cin_guy2, level.cin_guy3, level.cin_tvelin, level.cin_belov, level.cin_vikharev, level.cin_nevski ); // watching petrenko melt
	level thread fade_for_anim( fadeout_duration, "playerbody", "bet_s7" );
	align_struct thread anim_single_aligned( list, "bet_s7" );
	align_struct play_player_anim( align_struct, "bet_s7", "playerbody", false, true );
	//stop_exploder( 397 ); // gas

	//british are coming
	fa_visionset_shipstart();
	align_struct = getstruct( "british_coming_anim_origin", "targetname" ); 
	
	//p SetClientDvar( "cg_fov", 60 * mult );
	level thread fade_in( fadeout_duration, "black", 0.7 );	//hide camera lerp? -jc
	list = build_visible_list( level.cin_brit1, level.cin_brit2,level.cin_brit3 );
	level thread fade_for_anim( fadeout_duration, "playerbody", "bet_s8" );
	align_struct thread anim_first_frame( list, "bet_s8" );
	SetTimeScale( 0.66 );
	align_struct play_player_anim( align_struct, "bet_s8", "playerbody", false, true );
	
	SetTimeScale( 1.0 );
	p SetClientDvar( "cg_fov", old_fov ); 

	flag_set( "P2SHIPCINEMA_COMPLETE" );
	

}

shipcinema_dof()
{
	wait 3;	//need to wait before setting -jc
	
	NearStart = 0;
	NearEnd = 0;
	FarStart = 143;
	FarEnd = 668;
	NearBlur = 6;
	FarBlur = 1.8;
		
	self SetDepthOfField( NearStart, NearEnd, FarStart, FarEnd, NearBlur, FarBlur);	

	flag_wait( "P2SHIPCINEMA_COMPLETE" );

	//reset dof
	self maps\_art::setdefaultdepthoffield();

}

#using_animtree( "fullahead" );
door_close_thread()
{
	
//	wait 5.5;
//	//anim on door -jc
	door = GetEnt( "ship_doorescape", "targetname" );
	door useAnimTree( #animtree ); 
	door.animname = "object";
	align_struct = getstruct( "dragovich_leaves_anim_origin", "targetname" ); // same one in both scenes
	align_struct thread anim_single_aligned( door, "door_close" );

	wait(5.5);
	//level thread ship_door_close( "escape" );
	wait(2);
	level thread ship_door_close( "gas" );
}

gas_release_thread()
{
	wait(11);
	exploder(  397 ); // gas in the gas chamber
	
	//fx on patrenko here
	wait 5;
	if(is_mature())
	{
		level.cin_petrenko SetClientFlag(0);
		level.cin_belov SetClientFlag(0);

	}
	
	//vomit
	wait 14;// temp till notetrack/waittill
	
	//puss
	wait 4;// temp till notetrack/waittill
	if(is_mature())
	{
		PlayFXOnTag( level._effect["gas_puss"], level.cin_petrenko, "j_head" );
	}
	
}

fade_for_anim( duration, key1, key2 )
{
	anim_length = GetAnimLength( level.scr_anim[key1][key2] );
	wait( anim_length - duration );
	fade_out( duration, "black" );
}


build_visible_list( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 )
{
	list = [];
	
	if( isdefined(arg1) )
		list[list.size] = arg1;
	if( isdefined(arg2) )
		list[list.size] = arg2;
	if( isdefined(arg3) )
		list[list.size] = arg3;
	if( isdefined(arg4) )
		list[list.size] = arg4;
	if( isdefined(arg5) )
		list[list.size] = arg5;
	if( isdefined(arg6) )
		list[list.size] = arg6;
	if( isdefined(arg7) )
		list[list.size] = arg7;
	if( isdefined(arg8) )
		list[list.size] = arg8;
	if( isdefined(arg9) )
		list[list.size] = arg9;
		
	toggle_visibility( list ); // hide/show participants based on whether they're in the new list
		
	return list;
}

toggle_visibility( list )
{
	for( i=0; i<level.cin_everybody.size; i++ )
	{
		level.cin_everybody[i] hide();
		
		for( ii=0; ii<list.size; ii++ )
		{
			if( level.cin_everybody[i] == list[ii] )
				level.cin_everybody[i] show();
		}
	}
}


narration()
{
//     level.scr_sound["Reznov"]["bet1"] = "vox_ful1_s05_100A_rezn"; //We had found what we were looking for... Nova 6.  The German weapon of mass destruction now belonged to Mother Russia.
//     level.scr_sound["Reznov"]["bet2"] = "vox_ful1_s05_101A_rezn"; //Or so it seemed.  Our victory was to be short lived.
//     level.scr_sound["Reznov"]["bet3"] = "vox_ful1_s05_102A_rezn"; //Dragovich wanted to see the effects of the poison first hand.
//     level.scr_sound["Reznov"]["bet4"] = "vox_ful1_s05_103A_rezn"; //It was also an opportunity to remove a thorn in his side.
//     level.scr_sound["Reznov"]["bet5"] = "vox_ful1_s05_104A_rezn"; //I had long known of their distrust.
//     level.scr_sound["Reznov"]["bet6"] = "vox_ful1_s05_105A_rezn"; //What kind of men they were.
//     level.scr_sound["Reznov"]["bet7"] = "vox_ful1_s05_106A_rezn"; //It was a betrayal I should have forseen.
//     level.scr_sound["Reznov"]["bet8"] = "vox_ful1_s05_107A_rezn"; //Dimitri Petrenko was a hero...
//     level.scr_sound["Reznov"]["bet9"] = "vox_ful1_s05_108A_rezn"; //He deserved a hero's death.
//     level.scr_sound["Reznov"]["bet10"] = "vox_ful1_s05_109A_rezn"; //Instead of giving his life for the glory of the motherland, he died for nothing... like an animal.
//     level.scr_sound["Reznov"]["bet11"] = "vox_ful1_s05_110A_rezn"; //He should have died in Berlin...

	p = get_player();

	wait(2);
	p anim_single( p, "bet1", "Reznov" );
	p anim_single( p, "bet2", "Reznov" );
	p anim_single( p, "bet3", "Reznov" );
	p anim_single( p, "bet4", "Reznov" );
	p anim_single( p, "bet5", "Reznov" );
	p anim_single( p, "bet6", "Reznov" );
	wait 1;
	p anim_single( p, "bet7", "Reznov" );
	wait(9);
	p anim_single( p, "bet8", "Reznov" );
	p anim_single( p, "bet9", "Reznov" );
	wait(4);
	p anim_single( p, "bet10", "Reznov" );
	wait(7.5);
	p anim_single( p, "bet11", "Reznov" );
	
	wait(5);
	//     level.scr_sound["Reznov"]["watcheddie"] = "vox_ful1_s05_111A_rezn"; // As I watched my closest friend die, it soon became clear that we were not the only ones seeking the German weapons... The western allies circled like vultures...
	p thread anim_single( p, "watcheddie", "Reznov" ); // overlap this into the next event
	wait(2);
	
	flag_set( "P2SHIPCINEMA_NARRATION_COMPLETE" );
	
}