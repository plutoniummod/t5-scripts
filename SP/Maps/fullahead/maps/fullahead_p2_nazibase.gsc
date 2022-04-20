/*
//-- Level: Full Ahead
//-- Level Designer: Christian Easterly
//-- Scripter: Jeremy Statz
*/

#include maps\_utility;
#include common_scripts\utility;
#include maps\_utility_code;
#include maps\fullahead_util;
#include maps\fullahead_anim;
#include maps\fullahead_drones;
#include maps\_anim;
#include maps\_music;

// The level-skip shortcuts go here, the main level flow goes straight to run()
run_skipto()
{
	maps\fullahead_p2_dogsled::cleanup();
	
	// misc setup necessary to make the skipto work goes here
	level thread objectives(0);
	run();
}

run_skipto_hangar()
{
	// misc setup necessary to make the skipto work goes here
	level thread objectives(0);

	level.nazibase_hangar_start = true;

	player = get_player();
	player_to_struct( "playerstart_hangar" );
	player enableweapons();
	player giveweapon( "m8_orange_smoke_sp" );
	//level thread check_smoke_grenades();

	patrenko_spawn( "patrenko_hangar" );

	triggers_in_sequence( "group5" );

	level thread patrenko_hangar_door();

	level thread run();

	// this satisfies the objectives thread
	level waittill( "fade_in_complete" );

	flag_set( "P2NAZIBASE_FIRSTBUILDING_START" );
	flag_set( "P2NAZIBASE_FIRSTBUILDING_CLEAR" );
	flag_set( "P2NAZIBASE_FIRSTBUILDING_HOLDOUTS_CLEAR" );
	flag_set( "P2NAZIBASE_FIRSTBUILDING_COMPLETE" );
	flag_set( "P2NAZIBASE_GET_GRENADES" );
	flag_set( "P2NAZIBASE_BARRICADE_DESTROYED" );
}

run_skipto_end()
{
	// misc setup necessary to make the skipto work goes here
	level thread objectives(0);

	level.nazibase_end_start = true;

	player_to_struct( "playerstart_steiner" );
	get_player() enableweapons();

	patrenko_spawn( "patrenko_steiner" );
	run();
}

run()
{
	init_event();
	containment_trigger_startup("nazi_base_containment");
	level.gibDelay = 100;
	p = get_players()[0];
	p thread player_wait_on_mortar_death();
	p DisableWeapons();
	wait(0.05);

	if( !isdefined(level.nazibase_hangar_start) && !isdefined(level.nazibase_end_start) )
	{
		level thread nazibase_firsthill_vips();
		level thread spawn_manager_enable( "p2nazibase_squad_spawnmanager_01" );
		level thread nazibase_mortarcycle( "stop_mortarcycle_1", "mortar1_point" );
		level thread nazibase_stopmortar1_checkpoint();
		//simple_spawn( "p2nazibase_startersquad" );

		// the sniper dude who climbs onto the roof
		guy = simple_spawn_single( "p2nazibase_startsniper_1" );
		node = getnode( "nazibase_startsniper_prone", "targetname" );
		guy setgoalnode( node );
		guy.goalradius = 32;

		// the sniper who stands in the trench
		guy = simple_spawn_single( "p2nazibase_startsniper_2" );
		node = getnode( "nazibase_startsniper_trench", "targetname" );
		guy setgoalnode( node );
		guy.goalradius = 32;
	
		// Guy manning the mg42
		guy = simple_spawn_single( "p2nazibase_gunner" );
		node = getnode( "mg_turret_1_node", "targetname" );
		turret = getent( "mg_turret_1", "targetname" );
		guy thread goto_turret( turret, node );
	}

	fade_in( 2, "white", undefined, undefined, true );
	hud_utility_hide("white");
	wait(1.5); // allow the player to move after keeping them still for a bit.

	// Make mortar teams invulnerable and punish the player for attacking them
	ai = getaiarray( "allies" );
	for( i=0; i<ai.size; i++ )
	{
		if( isdefined( ai[i].script_noteworthy ) && ai[i].script_noteworthy == "mortar_team" )
		{
			ai[i] magic_bullet_shield();
			ai[i] hidepart("tag_weapon");
		}
	}

	p = get_player();
 	p thread gradiate_move_speed( 1.0, 0.05 );
	wait(1.5);

	mortarpos = getstruct( "p2nazibase_first_mortar", "targetname" );
	mortarpos maps\_mortar::activate_mortar( 256, 400, 165, undefined, undefined, undefined , true);
	battlechatter_on();

	level thread intro_melee_fights();
	
	
	level thread mortar_and_smoke_grenade();

	trig = getent( "p2nazibase_outro", "targetname" );
	//trig trigger_use_button( &"FULLAHEAD_USE_OPEN" );
	trig waittill("trigger");
	exploder(295);


	start_intro_steiner();
	
	trigger_wait("start_steiner_player_animation");
	level thread nazibase_outrocinema();
	
	

	flag_wait( "P2NAZIBASE_OUTRO_FADE" );
	//TUEY Set Music State to NARRATION_POST_DOGSLED
	setmusicstate ("NARRATION_POST_DOGSLED");
	
	p thread snowy_enter_vignette();
	level waittill( "reznov_cutscene_snow_to_fade" );

	
	
	level fade_out( 1.8, "white", 0.66 );
	
	flag_set( "P2NAZIBASE_EXIT" );
	cleanup();
	maps\fullahead_p2_shiparrival::run();
}
mortar_and_smoke_grenade()
{
	trigger_wait("p2nazibase_breadcrumb3C");	//make player go to backroom
	//flag_wait( "P2NAZIBASE_FIRSTBUILDING_COMPLETE" );

	player = get_players()[0];
	level thread check_smoke_grenades();
	level thread watch_smoke_grenade_pickup_trigger();
	player thread pickup_smoke_grenades_thread();


}
#using_animtree ("generic_human");
start_intro_steiner()
{	
	struct = getstruct( "nazibase_outro_centerpoint", "targetname" );
	level thread outro_deadguys( struct );
	wait(0.5);	

	//start streaming texture for reznov.
	level.streamHintEnt = createStreamerHint((-1160, -1152, -152), 1.0 );
	
	
	steiner = simple_spawn_single( "nazibase_steiner" );
	steiner thread dont_shoot_steiner();
	steiner.name = "Steiner";
	steiner.animname = "steiner";
	level.steiner_nazibase = steiner;

	chair = spawn( "script_model", struct.origin );
	chair setmodel( "p_ger_steiner_chair" );
	chair.origin = steiner GetTagOrigin( "tag_weapon_left" );
	chair.angles = steiner GetTagAngles( "tag_weapon_left" );
	chair linkto( steiner, "tag_weapon_left" );

	cigarette = spawn( "script_model", struct.origin );
	cigarette setmodel( "p_glo_cigarette" );
	cigarette.origin = steiner GetTagOrigin( "tag_inhand" );
	cigarette.angles = steiner GetTagAngles( "tag_inhand" );
	cigarette linkto( steiner, "tag_inhand" );
	level.cigarette = cigarette;
	PlayFXOnTag(level._effect["cig_smoke"], cigarette, "tag_cigarglow");

	level thread play_steiner_idle(struct);
	door = getent( "steiner_room_door", "targetname" );
	door rotateto( (0,90,0), 0.5 );

	guy = simple_spawn_single("nazibase_outro_deadguy");
	guy.ignoreme = true;
	//guy thread magic_bullet_Shield();
	guy.animname = "soldier4";
	struct anim_single_aligned(guy, "steinercin");
	clip = GetEnt("steiner_door_clip", "targetname");
	clip delete();

	//guy StartRagdoll();
}
dont_shoot_steiner()
{

	level endon("P2NAZIBASE_OUTRO_FADE");

	player = get_players()[0];

	while(1)
	{
		self waittill("damage", dmg_amount, attacker );
			
		if(attacker == player)
		{
			//SetDvar( "ui_deadquote", &"FULLAHEAD_SHOOT_STEINER_FAIL");
			missionFailedWrapper(&"FULLAHEAD_SHOOT_STEINER_FAIL");
		}
	}
	




}

play_steiner_idle(struct)
{
	level endon("start_steinercin_end");

	while(1)
	{ 
		struct anim_single_aligned( level.steiner_nazibase, "steinercin_idle");
	}
	
}


init_event()
{
	fa_print( "init p2 nazibase\n" );
	
	get_player() SetClientDvar( "sm_sunSampleSizeNear", 0.5 );

	spawn_manager_set_global_active_count( 20 );

	base_fog();

	/#
	level thread ai_sanity_check();
	#/

	fa_visionset_nazibase();

	// relocate player to correct position, arm them
	if( !isdefined(level.nazibase_hangar_start) && !isdefined(level.nazibase_end_start) )
	{
		player_to_struct( "p2nazibase_playerstart" );
		get_player() enableweapons();
		get_player() set_move_speed( 0.00 );

		disable_triggers_with_targetname( "p2nazibase_building2_followup" );
		disable_triggers_with_targetname( "patrenko_hangar_kick" );

		level thread patrenko_spawn( undefined );
	}

	setup_explosions();
	setup_banzai_triggers();
	setup_drone_triggers();
	setup_drone_delete_triggers();
	setup_sm_handoff_triggers();
//	setup_sm_progresstriggers();
	setup_surrender_triggers();
	setup_retreat_triggers();
	patrenko_setup_checks();
	setup_weather_devices();
	level thread setup_bridge_clip();

	level thread setup_bridge_explosion();
	level thread custom_execution_thread();
	setup_barricade();
	
	//hide ship card
	if( level.ps3 )
	{
		card = GetEnt( "ship_card", "targetname" );
		card Hide();
	}
	
	autosave_by_name( "fullahead" );
}
setup_bridge_clip()
{
	clip = GetEntArray("radarbuilding_bridge_clipping_dest", "targetname");
	for(i = 0; i < clip.size; i++)
	{
		clip[i] trigger_off();
		clip[i] connectpaths();
	}

}
setup_bridge_explosion()
{

	trigger_wait("bridge_explosion_trigger");
	level notify("bridge_start");
	clip = GetEntArray("radarbuilding_bridge_clipping","targetname");
	for(i = 0; i < clip.size; i++)
	{
		clip[i] delete();
	}

	clip = GetEntArray("radarbuilding_bridge_clipping_dest", "targetname");
	for(i = 0; i < clip.size; i++)
	{
		clip[i] trigger_on();
		clip[i] DisconnectPaths();
	}


	bridge_parts = GetEntArray("bridge_models", "targetname");
	for(i = 0; i < bridge_parts.size; i ++)
	{
		bridge_parts[i] delete();
	}

	// Set up mg42 gunner in the trench
	/*mg42 = getent( "mg_turret_2b", "targetname" );
	mg42 hide();*/
	mg42 = getent( "mg_turret_2", "targetname" );
	mg42 hide();

	ai = GetAIArray("axis");
	trigger = GetEnt("bridge_explosion_trigger", "targetname");

	for(i = 0; i < ai.size; i++ )
	{

		if(IsDefined(trigger))
		{
			if( ai[i] IsTouching(trigger) )
			{
				ai[i] DoDamage( 500, (0, 0, 0) );
			}
		}
		
	}


}

patrenko_spawn( teleport_struct_targetname )
{
	patrenko_spawner = getent( "p2nazibase_patrenko_spawn", "targetname" );
	pat = patrenko_spawner stalingradspawn();
	pat.targetname = "patrenko";
	pat.animname = "generic";
	pat.name = "Petrenko";
	level.patrenko = pat;

	wait(0.05); // give him time to finished spawning

	pat make_hero();

	if( isdefined(teleport_struct_targetname) )
	{
		struct = getstruct( teleport_struct_targetname, "targetname" );
		level.patrenko forceteleport( struct.origin, struct.angles );
		return;
	}

	// if he didn't teleport, then do his start of the level animation
	pat disable_ai_color();
	level anim_single( pat, "vista2" );
	pat enable_ai_color();
}

// gets run through at start of level
init_flags()
{
	flag_init( "DK_LEAVE" );

	flag_init( "P2NAZIBASE_FIRSTBUILDING_START" );
	flag_init( "P2NAZIBASE_FIRSTBUILDING_CLEAR" );
	flag_init( "P2NAZIBASE_FIRSTBUILDING_HOLDOUTS_CLEAR" );
	flag_init( "P2NAZIBASE_FIRSTBUILDING_PLAYER_ARRIVED" );
	flag_init( "P2NAZIBASE_FIRSTBUILDING_COMPLETE" );
	flag_init( "P2NAZIBASE_REZNOV_EXITED_LAUNCH_BUILDING" );
	flag_init( "P2NAZIBASE_GET_GRENADES" );
	flag_init( "P2NAZIBASE_SMOKE_GRENADES_FOUND" );
	flag_init( "P2NAZIBASE_MARK_BARRICADE" );
	flag_init( "P2NAZIBASE_BARRICADE_DESTROYED" );
	flag_init( "P2NAZIBASE_MG42_2_OVERRUN" );
	flag_init( "P2NAZIBASE_MG42_3_OVERRUN" );
	flag_init( "P2NAZIBASE_MG42_4_OVERRUN" );

	flag_init( "P2NAZIBASE_HANGAR_DOOR_KICKED" );

	flag_init( "P2NAZIBASE_OUTROBUILDING" );

// 	flag_init( "P2NAZIBASE_OUTROSTART" );
	flag_init( "P2NAZIBASE_OUTRO_FADE" );
	flag_init( "P2NAZIBASE_EXIT" );
	maps\fullahead_p2_shiparrival::init_flags();
}

cleanup()
{
	fa_print( "cleanup p2 nazibase\n" );
	containment_trigger_shutdown("nazi_base_containment");
	// aggressively remove anybody in the area
	ai = getaiarray( "axis", "allies", "neutral" );
	for( i=0; i<ai.size; i++ )
	{
		if( isdefined(ai[i]) )
		{
			if( ai[i].origin[0] < 0 || ai[i].origin[1] > 0 )
			{
				ai[i] delete();
			}
		}
	}

	delete_outside_ship_quadrant( "script_model" );
	delete_outside_ship_quadrant( "script_brushmodel" );
	//delete_outside_ship_quadrant( "script_origin" );
	delete_outside_ship_quadrant( "dyn_model" );
	delete_outside_ship_quadrant( "dyn_brushmodel" );
	delete_outside_ship_quadrant( "trigger_multiple" );
	delete_outside_ship_quadrant( "trigger_radius" );
	
	// mg42s
	delete_outside_ship_quadrant( "misc_turret" );
	
	// weapon caches
	delete_outside_ship_quadrant( "weapon_panzerschreck_player_sp" );
	delete_outside_ship_quadrant( "weapon_mp40_sp" );
	delete_outside_ship_quadrant( "weapon_stg44_sp" );
	
	// don't need these anymore!
	delete_outside_ship_quadrant( "spawn_manager" );
}

delete_outside_ship_quadrant( classname )
{
	array = getentarray( classname, "classname" );
	for( i=0; i<array.size; i++ )
	{
		if( isdefined(array[i]) )
		{
			if( array[i].origin[0] < 0 )
			{
				array[i] delete();
			}
		}
	}
}

objectives( curr_obj_num )
{
//	level.scr_sound["Reznov"]["becareful"] = "vox_ful1_s03_305A_rezn"; //Be careful, there may be more of them.
//	level.scr_sound["Petrenko"]["checkupstairs"] = "vox_ful1_s03_309A_dimi"; //Check upstairs.
//	level.scr_sound["Reznov"]["spreadout"] = "vox_ful1_s03_330A_rezn"; //Spread out - Search every building!
//	level.scr_sound["Reznov"]["findsteiner"] = "vox_ful1_s03_331A_rezn"; //Find Steiner!!

//	level.scr_sound["Reznov"]["thiswayupthestairs"] = "vox_ful1_s03_342A_rezn"; //This way, up the stairs.
//	level.scr_sound["Reznov"]["ready"] = "vox_ful1_s03_343A_rezn"; //Ready?

   	// let this stomp over the previous objective

   	player = get_player();

	level waittill( "fade_in_complete" );
	objective_add( curr_obj_num, "active", &"FULLAHEAD_OBJ_NAZIBASE_STEINER", ent_origin("p2nazibase_breadcrumb0") );
	objective_position( curr_obj_num, ent_origin("p2nazibase_breadcrumb0") );
	objective_set3d( curr_obj_num, true );
	Objective_Current(curr_obj_num);
	//TUEY Set music to FIRST_FIGHT
	setmusicstate ("FIRST_FIGHT");

	trigger_wait( "p2nazibase_breadcrumb0", "targetname" );
	objective_position( curr_obj_num, ent_origin("p2nazibase_breadcrumb1") );
	objective_set3d( curr_obj_num, true );
	//Objective_Current(curr_obj_num);
	trigger_wait( "p2nazibase_breadcrumb1", "targetname" );
	objective_position( curr_obj_num, ent_origin("p2nazibase_breadcrumb2") );
	objective_set3d( curr_obj_num, true );
	//Objective_Current(curr_obj_num);
	level thread surrender_dialog();

	flag_wait( "P2NAZIBASE_FIRSTBUILDING_START" );
	objective_position( curr_obj_num, ent_origin("p2nazibase_breadcrumb3A") );
	objective_set3d( curr_obj_num, true );
	//Objective_Current(curr_obj_num);
	trigger_wait( "p2nazibase_breadcrumb3A", "targetname" );

	//wait( 4 );
	level.patrenko anim_single( level.patrenko, "checkupstairs", "Petrenko" );
	player thread anim_single( player, "becareful", "Reznov" );

	objective_position( curr_obj_num, ent_origin("p2nazibase_breadcrumb3B") );
	objective_set3d( curr_obj_num, true );
	//Objective_Current(curr_obj_num);
	trigger_wait( "p2nazibase_breadcrumb3B", "targetname" );
	objective_position( curr_obj_num, ent_origin("p2nazibase_breadcrumb3C") );
	objective_set3d( curr_obj_num, true );
	//Objective_Current(curr_obj_num);
	// Once the holdouts are clear and the player has arrived, follow Petrenko outside to call in artillery on the barricade
	flag_wait( "P2NAZIBASE_FIRSTBUILDING_COMPLETE" );
	curr_obj_num++;


	objective_delete( curr_obj_num );
	curr_obj_num--;
	objective_position( curr_obj_num, ent_origin("p2nazibase_breadcrumb4") );
	objective_set3d( curr_obj_num, true );
	//Objective_Current(curr_obj_num);
	//wait( 1.5 );
	//use trigger
	trigger_wait( "smoke_grenade_trigger", "targetname" );
	player anim_single( player, "spreadout", "Reznov" );
	level thread remind_player_to_use_smoke_grenades( 3 );
	
	//TUEY set music to MORTARS
	setmusicstate ("MORTARS");
	


	trigger_wait( "p2nazibase_breadcrumb4", "targetname" );
	objective_position( curr_obj_num, ent_origin("p2nazibase_breadcrumb5") );
	objective_set3d( curr_obj_num, true );
	//Objective_Current(curr_obj_num);
	player thread anim_single( player, "findsteiner", "Reznov" );


	flag_wait( "P2NAZIBASE_HANGAR_DOOR_KICKED" );
	autosave_by_name( "fullahead" );
	objective_position( curr_obj_num, ent_origin("steiner_1st_floor") );
	objective_set3d( curr_obj_num, true );
	//Objective_Current(curr_obj_num);
	trigger_wait( "steiner_1st_floor", "targetname" );
	objective_position( curr_obj_num, ent_origin("p2nazibase_steiner_stairs") );
	objective_set3d( curr_obj_num, true );
	autosave_by_name( "fullahead" );
	//Objective_Current(curr_obj_num);
	// Breadcrumb at the base of the stairs leading up to Steiner's office
	trigger_wait( "p2nazibase_steiner_stairs", "targetname" );
	objective_position( curr_obj_num, ent_origin("p2nazibase_outro") );
	objective_set3d( curr_obj_num, true );
	player anim_single( player, "thiswayupthestairs", "Reznov" );
	//Objective_Current(curr_obj_num);
	level waittill( "start_steinercin_end" );
	objective_state( curr_obj_num, "done" );

	curr_obj_num++;
	maps\fullahead_p2_shiparrival::objectives( curr_obj_num );
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

setup_sm_handoff_triggers()
{
	trigs = getentarray( "sm_allies_handoff", "targetname" );
	for( i=0; i<trigs.size; i++ )
	{
		active_count = 3;
		if( isDefined( trigs[i].script_parameters ) )
		{
			active_count = Int( trigs[i].script_parameters );
		}
		trigs[i] thread sm_handoff_thread( "allies", active_count );
	}

	trigs = getentarray( "sm_axis_handoff", "targetname" );
	for( i=0; i<trigs.size; i++ )
	{
		active_count = 4;
		if( isDefined( trigs[i].script_parameters ) )
		{
			active_count = Int( trigs[i].script_parameters );
		}
		trigs[i] thread sm_handoff_thread( "axis", active_count );
	}
}

sm_handoff_thread( team, active_count )
{
	level endon( "P2NAZIBASE_EXIT" );
	
	fa_print( "sm_handoff_thread starting:" );
	fa_print( "  - targetname: " + self.script_noteworthy );
	fa_print( "  - count: " + active_count );

	sm_targetname = self.script_noteworthy;

	self waittill( "trigger" );

	// if there was a previous thread waiting to handoff, kill it in favor of this one
	level notify( "sm_handoff_triggered_" + team );
	level endon( "sm_handoff_triggered_" + team );
	
	enough_metered_allies = true;
	while( enough_metered_allies )
	{
		// count only the allied troops brought in by metered spawn managers
		members = getAiArray(team);
		metered_allies = 0;
		for( i=0; i<members.size; i++ )
		{
			if( isDefined( members[i].script_noteworthy ) && members[i].script_noteworthy == "metered_spawner" )
			{
				metered_allies++;
			}
		}

		if( metered_allies - active_count > 0 )
		{
			enough_metered_allies = true;
			fa_print( "sm_handoff_thread ("+team+")detects team.size > active_count, waiting..." );
		}
		else
		{
			enough_metered_allies = false;
		}
		wait( 1.25 );
	}

	fa_print( "sm_handoff_thread starting spawn manager" + sm_targetname );
	spawn_manager_enable( sm_targetname );
	self delete();
}

// fence_climber()
// {
// 	trig = getent( "fence_climber_trigger", "targetname" );
// 	trig waittill( "trigger" );
//
// 	fa_print( "Spawning fence climber" );
//
// 	guy = simple_spawn_single( "fence_climber" );
// 	node = getnode( "fence_climber_dest_1", "targetname" );
//
// 	guy force_goal( node );
// 	guy waittill( "goal" );
// 	guy delete();
//
// }

setup_drone_triggers()
{
	trigs = getentarray( "fa_drone_trigger", "targetname" );
	for( i=0; i<trigs.size; i++ )
	{
		trigs[i] thread drone_trigger_thread();
	}
}

drone_trigger_thread()
{
	assert( isdefined(self.target) );
	target_structs = getstructarray( self.target, "targetname" );
	assert( isdefined(target_structs) );

	faction = "axis";
	if( isdefined( self.script_noteworthy ) )
	{
		faction = self.script_noteworthy;
	}

	self waittill( "trigger" );
	fa_start_drone_path( self.target, faction );
}

setup_drone_delete_triggers()
{
	trigs = getentarray( "delete_drones", "targetname" );
	for( i=0; i<trigs.size; i++ )
	{
		trigs[i] thread drone_delete_thread();
	}
}

drone_delete_thread()
{
	assert( isdefined(self.script_noteworthy) );

	self waittill( "trigger" );

	fa_print( "drone_delete_thread deleting " + self.script_noteworthy );
	drones = getentarray( self.script_noteworthy, "script_noteworthy" );
	for( i=0; i<drones.size; i++ )
	{
		if( drones[i] != self )
		{
			drones[i] delete();
		}
	}
}

intro_melee_fights()
{
	trigger_wait( "p2nazibase_intro_fight_trigger" );

	ref_node = getstruct( "p2nazibase_intro_fight_point", "targetname" );
	
	level.melee_russ = [];
	level.melee_ger = [];
	level.russ_melee_spawner = [];
	
	for( i=1; i<=5; i++ )
	{
		level.russ_melee_spawner[i] = "p2nazibase_intro_fight" + i + "_russian";
	}
	
	/*fight_index = 1;
	num_loops = 2;
	level init_fight( fight_index, ref_node, num_loops );
	wait(0.2);*/

	fight_index = 2;
	num_loops = 2;
	level init_fight( fight_index, ref_node, num_loops );
	wait(0.3);

	/*fight_index = 3;
	num_loops = 2;
	level init_fight( fight_index, ref_node, num_loops );
	wait(0.2);*/

	fight_index = 4;
	num_loops = 2;
	level init_fight( fight_index, ref_node, num_loops );
	wait(0.3);

	fight_index = 5;
	num_loops = 3;
	level init_fight( fight_index, ref_node, num_loops );

}

init_fight( fight_index, ref_node, num_loops )
{
	level.melee_russ[fight_index] = simple_spawn_single( level.russ_melee_spawner[fight_index] );
	level.melee_ger[fight_index] = fa_drone_spawn( ref_node, "axis" );
	level.melee_ger[fight_index].health = 10;
	level.melee_russ[fight_index] thread do_melee_fight( ref_node, fight_index, num_loops );
	level.melee_ger[fight_index] thread do_melee_fight( ref_node, fight_index, num_loops );
}

// Self is a guy - either a Russian or a German. The anim string reference is hard coded, and the Russian has
// an early exit whereas the German does not. The Russian is invulnerable until the fight ends, and the German
// can be killed early by the player. If that happens, the Russian is notified and shifts to an early ending anim.
do_melee_fight( ref_node, anim_num, num_melee_loops, index_num )
{
	self endon( "death" );
	self endon( "melee_early_end" );
	
	self.animname = "generic";
	
	if( !isdefined(index_num) )
		index_num = anim_num;

	if( self.team == "allies" )
	{
		self disable_ai_color();
		self.ignoreme = true;
		self magic_bullet_shield();

		anim_name = "hand2hand_"+anim_num+"_loop_russian";
		for( i=0; i<num_melee_loops; i++ )
		{
			ref_node anim_single_aligned( self, anim_name );
		}
		
		// Finished the loop portion - end the fight normally
		anim_name = "hand2hand_"+anim_num+"_russian";
		ref_node anim_single_aligned( self, anim_name );

		self resume_combat();
		
		self thread death_timer();
	}
	else
	{
		// Start a thread that watches for an early death
		ref_node thread detect_early_death( self, anim_num, index_num );
		
		anim_name ="hand2hand_"+anim_num+"_loop_german";
		for( i=0; i<num_melee_loops; i++ )
		{
			ref_node anim_single_aligned( self, anim_name );
		}

		// Tell the level that the fight's over so it can kill the "detect_early_death" thread
		melee_normal_end = "melee_normal_end" + index_num;
		level notify( melee_normal_end );

		clip = GetEnt( "p2nazibase_intro_fight" + index_num + "_clip", "targetname");
		if(IsDefined(clip))
		{
			clip delete();
		}
		
		// Finished the loop portion - end the fight normally
		anim_name = "hand2hand_"+anim_num+"_german";
		ref_node anim_single_aligned( self, anim_name );
		
		self die();
	}
}

// Self is the level. This thread watches for the passed-in German's death and if it happens while the thread
// is alive, it triggers a message to the associated Russian (indexed by anim_num). That message tells the Russian
// that his melee opponent is dead and sends him into an early transition out of melee.
detect_early_death( german, anim_num, index_num )
{
	melee_normal_end = "melee_normal_end" + index_num;
	level endon( melee_normal_end );
		
	while( isAlive( german ) )
	{
		wait( 0.5 );
	}

	// The german died before the "melee_normal_end" notify - Tell the Russian we're fighting to go on about his business
	russian = level.melee_russ[index_num];
	
	if( isDefined( russian ) && isAlive( russian ) )
	{
		russian notify( "melee_early_end" );



		clip = GetEnt( "p2nazibase_intro_fight" + index_num + "_clip", "targetname");
		if(IsDefined(clip))
		{
			clip delete();
		}
		//ref_node = getstruct( "p2nazibase_intro_fight_point", "targetname" ); // replaced by 'self'
		anim_name = "hand2hand_"+anim_num+"_end_russian";
		self anim_single_aligned( russian, anim_name );
	
		russian resume_combat();
	}
}

// Self is a guy who is transitioning out of scripted melee combat
resume_combat()
{
	self.ignoreme = false;
	self enable_ai_color();
	self stop_magic_bullet_shield();
}

// Self is a russian melee combatant who is taking up too much space and needs to be culled
death_timer()
{
	self endon( "death" );
	wait( randomFloatRange( 3.0, 12.0 ) );
	
	fxTag = "j_neck";
	PlayFxOnTag( level._effect["bloodspurt"], self, fxTag );

	self ragdoll_death();
}

// The sniper and mortar guys are probably the only guys here by the time this is called
mortar_sniper_cleanup()
{
	ai = get_ai_touching_volume( "allies", "nazibase_mortar_sniper_cleanup" );
	for( i=0; i<ai.size; i++ )
	{
		ai[i] stop_magic_bullet_shield();
		ai[i] die();
	}
}

patrenko_setup_checks()
{
	disable_trigger_with_targetname( "patrenko_check_3" );

//	disable_trigger_with_targetname( "p2nazibase_breadcrumb1" );

	trig = getent( "patrenko_check_1", "targetname" );
	trig thread patrenko_check_thread_1();
	trig = getent( "patrenko_check_3", "targetname" );
	trig thread patrenko_check_thread_3( 3 );
	trig = getent( "p2nazibase_breadcrumb3C", "targetname" );
	trig thread player_arrived_upstairs_thread();
}

// self is the trigger
patrenko_check_thread_1()
{
    // lines for the patrenko building
//    level.scr_sound["Petrenko"]["checkbuilding"] = "vox_ful1_s03_044A_dimi"; //Check the launch control building!
//    level.scr_sound["Reznov"]["pushonmyfriends"] = "vox_ful1_s03_306A_rezn"; //Push on my friends, clear the next area.
//    level.scr_sound["Reznov"]["crushall"] = "vox_ful1_s03_307A_rezn"; //Crush all who stand in our way!
//    level.scr_sound["Petrenko"]["nothere"] = "vox_ful1_s03_045A_dimi"; //He is not here...
//    level.scr_sound["Reznov"]["nearship"] = "vox_ful1_s03_046A_rezn"; //He must be nearer the ship.

//    level.scr_sound["Petrenko"]["fremind3"] = "vox_ful1_s04_081A_dimi"; //Stay with me.

	player = get_player();

    waitnode = getnode( "patrenko_waitforclear_node_3", "targetname" );
	waitplayernode = getnode( "patrenko_check_waitplayer_1", "targetname" );
//	checknode = getnode( "destnode_3", "targetname" );

	roomclear = getent( "firstbuilding_holdout_cleartrig", "targetname" );

	assert( isdefined(waitnode) );
	assert( isdefined(waitplayernode) );
//	assert( isdefined(checknode) );

	assert( isdefined(roomclear) );

	level thread patrenko_building_1_holdouts();

	trigger_wait( "patrenko_check_1" ); // trigger in the level that starts all this moving

	autosave_by_name( "fullahead" );//moved here, safer -jc

	level.patrenko anim_single( level.patrenko, "checkbuilding", "Petrenko" );
	player anim_single( player, "pushonmyfriends", "Reznov" );
	wait 0.5;
	player thread anim_single( player, "crushall", "Reznov" );

	enable_trigger_with_targetname( "p2nazibase_breadcrumb3A" );
	flag_set( "P2NAZIBASE_FIRSTBUILDING_START" );
	kill_spawnernum( 1 ); // remove the spawners in that particular building
	level.patrenko disable_ai_color();
	level.patrenko setgoalnode( waitnode );

	simple_spawn( "firstbuilding_moreguys" ); // just to bolster the ranks a bit

	level thread firstbuilding_check_for_clear();
	level thread firstbuilding_breach();
//	level thread firstbuilding_breach_automatic_thread();

	//level.patrenko waittill( "goal" ); //can break script -jc
//	level.patrenko thread patrenko_reminder_thread( "We've got to clear this place out, captain!" );

	//flag_wait( "P2NAZIBASE_FIRSTBUILDING_CLEAR" );
	level.patrenko notify( "patrenko_reminder_finish" );
	activate_triggers( "patrenko_building_nextcolor_1", "targetname" );

	// send patrenko to the cover node, wait for the player there, fight if necessary
//	level.patrenko setgoalnode( waitplayernode );
//	level.patrenko.goalradius = 32;

	// wait until the room's clear...
	level.patrenko thread anim_single( level.patrenko, "fremind3", "Petrenko" );//thread bc could miss next goal msg -jc

	// Wait until Petrenko AND the player get here to progress objectives further
	//level.patrenko waittill( "goal" );	//too easy to miss, replace with trig -jc
	trigger_wait("p2nazibase_breadcrumb3C");	//make player go to backroom 

	//flag_wait( "P2NAZIBASE_FIRSTBUILDING_HOLDOUTS_CLEAR" );	//plyr can not do this and break script-jc
//	flag_wait( "P2NAZIBASE_FIRSTBUILDING_PLAYER_ARRIVED" );
	level.patrenko notify( "patrenko_reminder_finish" );
		
	flag_set( "P2NAZIBASE_FIRSTBUILDING_COMPLETE" );
	reznov = get_player();
	level.patrenko anim_single( level.patrenko, "nothere", "Petrenko" );
	reznov thread anim_single( reznov, "nearship", "Reznov" );
	
	//TUEY Set music to NOT_HERE	
	setmusicstate ("NOT_HERE");
		

	// Destroy the barricade that prevents progress down the street
	checknode = getnode( "destnode_smoke", "targetname" );
	level.patrenko setgoalnode( checknode ); // walk here, then talk
	level.patrenko.goalradius = 32;
	
	
	//level destroy_barricade_thread();
	flag_wait("P2NAZIBASE_BARRICADE_DESTROYED");
	level.patrenko enable_ai_color();

	// so the player can get into the hangar combat
	enable_triggers_with_targetname( "p2nazibase_building2_followup" );
	enable_triggers_with_targetname( "patrenko_hangar_kick" );
	level thread trigger_surrender_thread( "nazibase_hangar_surrender_trigger", 5 );

	autosave_by_name( "fullahead" );
	

}


firstbuilding_breach()
{
//    level.scr_sound["Reznov"]["clearthebuilding"] = "vox_ful1_s03_308A_rezn"; //Clear the building.  Leave no stone unturned!

	level endon( "P2NAZIBASE_FIRSTBUILDING_CLEAR" );

	b0node = getnode( "firstbuilding_breach_0_patrenko", "targetname" );
	b1node = getnode( "firstbuilding_breach_1_patrenko", "targetname" );
	b2node = getnode( "firstbuilding_breach_2_patrenko", "targetname" );
	b3node = getnode( "patrenko_check_waitplayer_1", "targetname" );

	assert( isdefined(b0node) );
	assert( isdefined(b1node) );
	assert( isdefined(b2node) );
	assert( isdefined(b3node) );



	trig = getent( "firstbuilding_breach_0", "targetname" );
	if(IsDefined(trig))
	{
		trigger_wait( "firstbuilding_breach_0" );
	}
//	player = get_player();
//	player anim_single( player, "clearthebuilding", "Reznov" );

	fa_print( "BREACH 0" );
	level.patrenko setgoalnode( b0node );
	level.patrenko.goalradius = 32;


	trig = getent( "firstbuilding_breach_1", "targetname" );
	if(IsDefined(trig))
	{
		trigger_wait( "firstbuilding_breach_1" );
	}
	
	fa_print( "BREACH 1" );
	level.patrenko setgoalnode( b1node );
	level.patrenko.goalradius = 32;


	trig = getent( "firstbuilding_breach_2", "targetname" );
	if(IsDefined(trig))
	{
		trigger_wait( "firstbuilding_breach_2" );
	}


	fa_print( "BREACH 2" );
	level.patrenko setgoalnode( b2node );
	level.patrenko.goalradius = 32;

	trigger_wait( "firstbuilding_holdout_spawntrig" );
	fa_print( "BREACH 3" );
	level.patrenko setgoalnode( b3node );
	level.patrenko.goalradius = 32;
}

// will progress Patrenko through the first building on his own, if the player doesn't do it
firstbuilding_breach_automatic_thread()
{
	wait(15);
	trig = getent( "firstbuilding_breach_0", "targetname" );
	trig notify( "trigger" );

	wait(15);
	trig = getent( "firstbuilding_breach_1", "targetname" );
	if( isdefined(trig) )
		trig notify( "trigger" );

	wait(15);
	trig = getent( "firstbuilding_breach_2", "targetname" );
	if( isdefined(trig) )
		trig notify( "trigger" );
}

firstbuilding_check_for_clear()
{
	// wait for the building to be empty
	wait_for_trigger_clear_of_ai( "axis", "patrenko_building_secure_1" );
	flag_set( "P2NAZIBASE_FIRSTBUILDING_CLEAR" );
}

patrenko_building_1_holdouts()
{
	trigger_wait( "firstbuilding_holdout_spawntrig" );
	simple_spawn( "firstbuilding_holdout_spawn" );

	// open the door
	door = getent( "kick_door_check1", "targetname" );
	if( isdefined(door) )
	{
	
		// SOUND - Shawn J
		//iprintlnbold ("door_kick_3p");
	
		door rotateyaw(135, 0.5);
		door connectpaths();
	}

	// wait for the room to be cleared
	wait_for_trigger_clear_of_ai( "axis", "firstbuilding_holdout_cleartrig" );

	trig = getent( "firstbuilding_holdout_cleartrig", "targetname" );
	trig delete();

	flag_set( "P2NAZIBASE_FIRSTBUILDING_HOLDOUTS_CLEAR" );
}

player_arrived_upstairs_thread()
{
	// Set flag when player has arrived upstairs at the Patrenko building
	self waittill( "trigger" );
	flag_set( "P2NAZIBASE_FIRSTBUILDING_PLAYER_ARRIVED" );
	place_smoke_grenades();
}


// self is the trigger
// patrenko_check_thread_2()
// {
// 	waitclearnode = getnode( "patrenko_waitforclear_node_2", "targetname" );
// 	waitplayernode = getnode( "patrenko_check_waitplayer_2", "targetname" );
// 	kicknode = getnode( "patrenko_check_kicknode_2", "targetname" );
// 	checknode = getnode( "patrenko_check_destnode_2", "targetname" );
//
// 	assert( isdefined(waitclearnode) );
// 	assert( isdefined(waitplayernode) );
// 	assert( isdefined(kicknode) );
// 	assert( isdefined(checknode) );
//
//
//
// 	level thread patrenko_building_2_holdouts(); // the melee dude down in the basement
//
// 	trigger_wait( "patrenko_check_2" );
//
// 	level.patrenko thread fa_speak( "The radar building, clear it out!" );
// 	flag_set( "P2NAZIBASE_SECONDBUILDING_START" );
// 	kill_spawnernum( 2 ); // remove the spawners in that particular building
// 	level.patrenko disable_ai_color();
// 	level.patrenko setgoalnode( waitclearnode );
//
// 	simple_spawn( "secondbuilding_moreguys" ); // just to bolster the ranks a bit
//
// 	level thread secondbuilding_check_for_clear();
// 	level thread secondbuilding_breach();
//
// 	level.patrenko waittill( "goal" );
// 	level.patrenko thread patrenko_reminder_thread( "Need to get this place cleared out!" );
//
// 	flag_wait( "P2NAZIBASE_SECONDBUILDING_CLEAR" );
// 	level.patrenko notify( "patrenko_reminder_finish" );
// 	activate_triggers( "patrenko_building_nextcolor_2", "targetname" );
//
//
// 	level.patrenko setgoalnode( waitplayernode );
// 	level.patrenko.goalradius = 32;
//
// 	// wait until we're sure the room's clear...
// 	level.patrenko thread patrenko_reminder_thread( "Follow me, Captain!" );
// 	flag_wait( "P2NAZIBASE_SECONDBUILDING_HOLDOUTS_CLEAR" );
//
// 	// ...AND we're sure the player's nearby
// 	enable_trigger_with_targetname( "p2nazibase_breadcrumb2" );
// 	trigger_wait( "p2nazibase_breadcrumb2" );
// 	level.patrenko notify( "patrenko_reminder_finish" );
// 	level.patrenko door_kick( "patrenko_check_kicknode_2", "kick_door_check2" );
//
// 	level.patrenko setgoalnode( checknode ); // walk here, then talk
// 	level.patrenko.goalradius = 96;
//
// 	level.patrenko waittill( "goal" );
// 	level.patrenko fa_speak( "Just more notes and diagrams." );
// 	level.patrenko fa_speak( "Down to the big one, I guess.  Follow me!" );
//
// 	flag_set( "P2NAZIBASE_SECONDBUILDING_COMPLETE" );
// 	level.patrenko enable_ai_color();
// 	enable_trigger_with_targetname( "patrenko_check_3" );
//
// 	// enable the color and spawner triggers past this building,
// 	// and remove the progression blocker
//
//
//
// 	level thread sm_progresstrigger_thread( "p2nazibase_sm07", "group5", "P2NAZIBASE_SECONDBUILDING_COMPLETE" );
//
// 	patrenko_hangar_door();
// }
//
// secondbuilding_check_for_clear()
// {
// 	// wait for the building to be empty
// 	wait_for_trigger_clear_of_ai( "axis", "patrenko_building_secure_2" );
// 	level.patrenko thread fa_speak( "It's clear, let's go!" );
// 	flag_set( "P2NAZIBASE_SECONDBUILDING_CLEAR" );
// }
//
// secondbuilding_breach()
// {
// 	level endon( "P2NAZIBASE_SECONDBUILDING_CLEAR" );
//
// 	b1node = getnode( "secondbuilding_breach_1_patrenko", "targetname" );
// 	b2node = getnode( "secondbuilding_breach_2_patrenko", "targetname" );
// 	b3node = getnode( "patrenko_check_waitplayer_2", "targetname" );
//
// 	assert( isdefined(b1node) );
// 	assert( isdefined(b2node) );
// 	assert( isdefined(b3node) );
//
// 	trigger_wait( "secondbuilding_breach_1" );
// 	fa_print( "BREACH 1" );
// 	level.patrenko setgoalnode( b1node );
// 	level.patrenko.goalradius = 32;
//
// 	trigger_wait( "secondbuilding_breach_2" );
// 	fa_print( "BREACH 2" );
// 	level.patrenko setgoalnode( b2node );
// 	level.patrenko.goalradius = 32;
//
// 	trigger_wait( "secondbuilding_holdout_spawntrig" );
// 	fa_print( "BREACH 3" );
// 	level.patrenko setgoalnode( b3node );
// 	level.patrenko.goalradius = 32;
// }
//
// patrenko_building_2_holdouts()
// {
// 	trig = getent( "secondbuilding_holdout_spawntrig", "targetname" );
// 	trig waittill( "trigger" );
//
// 	guy = simple_spawn_single( trig.target );
// 	guy thread maps\_rusher::rush();
//
// 	// wait for the room to be cleared
// 	wait_for_trigger_clear_of_ai( "axis", "secondbuilding_holdout_cleartrig" );
//
// 	trig = getent( "secondbuilding_holdout_cleartrig", "targetname" );
// 	trig delete();
//
// 	flag_set( "P2NAZIBASE_SECONDBUILDING_HOLDOUTS_CLEAR" );
// }

patrenko_hangar_door()
{
//	level.scr_sound["Petrenko"]["wemustbegettingclose"] = "vox_ful1_s03_337A_dimi"; //We must getting close to Steiner.
//	level.scr_sound["Petrenko"]["afterthismission"] = "vox_ful1_s03_338A_dimi"; //After this mission... do you think we will go home?
//	level.scr_sound["Reznov"]["ihopeso"] = "vox_ful1_s03_339A_rezn"; //I hope so, Dimitri... I hope so.
//	level.scr_sound["Petrenko"]["therearefewleft"] = "vox_ful1_s03_340A_dimi"; //There are few of them left... Still no sign of Steiner.
//	level.scr_sound["Reznov"]["hewillbewhere"] = "vox_ful1_s03_341A_rezn"; //He will be where all cowards reside... As far from the battlefield as possible.

	petrenko = level.patrenko;
	player = get_player();

	destnode = getnode( "patrenko_hangar_door_node", "targetname" );
	assert( isdefined(destnode) );
	
	petrenko disable_ai_color();
	petrenko setgoalnode( destnode );

	petrenko waittill( "goal" );
	
	level notify( "stop_smoke_reminder");	//so reminder doesn't interfere with dialog -jc
	
	//TUEY set music to MORTARS
	setmusicstate ("POST_MORTARS");
	
	destnode = getnode( "patrenko_hangar_dest_node", "targetname" );
	assert( isdefined(destnode) );
	
	trigger_wait( "patrenko_hangar_kick" );
	
	//show ship card
	card = GetEnt( "ship_card", "targetname" );
	card Show();
	//petrenko headtracking_start( player );
	
	petrenko anim_single( petrenko, "wemustbegettingclose", "Petrenko" );
	player anim_single( player, "hewillbewhere", "Reznov" );

	//petrenko headtracking_stop();
	petrenko door_kick( "patrenko_hangar_door_node", "kick_door_hangar" );
	flag_set( "P2NAZIBASE_HANGAR_DOOR_KICKED" );
	petrenko enable_ai_color();
	petrenko setgoalnode( destnode );

	
	petrenko anim_single( petrenko, "afterthismission", "Petrenko" );
	player thread anim_single( player, "ihopeso", "Reznov" );

	enable_trigger_with_targetname( "patrenko_check_3" );
	
	//petrenko anim_single( petrenko, "therearefewleft", "Petrenko" );
	
	
	
	//TUEY Set music to PRE STEINER
	setmusicstate ("PRE_STEINER");


	// Set up mg42 gunner in the trench
	mg42 = getent( "mg_turret_3", "targetname" );
	mg42 setup_mg42();
	turret_node = getent( "mg_turret_3_node", "targetname" );
	gunner_spawner = getent( "mg42_gunner_spawn_3",  "targetname" );
	strTrig = "mg42_3_overrun";
	strFlag = "P2NAZIBASE_MG42_3_OVERRUN";
	level thread set_flag_when_triggered( strTrig, strFlag );
	mg42 thread man_mg42( turret_node, gunner_spawner, strFlag );

	// Set up mg42 gunner at last building
	mg42 = getent( "mg_turret_4", "targetname" );
	mg42 setup_mg42();
	turret_node = getent( "mg_turret_4_node", "targetname" );
	gunner_spawner = getent( "mg42_gunner_spawn_4",  "targetname" );
	strTrig = "mg42_4_overrun";
	strFlag = "P2NAZIBASE_MG42_4_OVERRUN";
	level thread set_flag_when_triggered( strTrig, strFlag );
	mg42 thread man_mg42( turret_node, gunner_spawner, strFlag );

	trig = getent( "mg42_3_overrun", "targetname" );
	trig thread trench_mg42_overrun();
	
	level thread ready_dialog();
}

// self should be the guy doing the kicking
door_kick( nodename, animname )
{
	node = getnode( nodename, "targetname" );

	node anim_reach( self, animname );
	
	//SOUND - Shawn J - adding door kick sound ONLY to Petrenko kick
	if (animname == "kick_door_hangar")
		{
			self playsound ("evt_petrenko_kick");
		}
		
	node thread anim_single_aligned( self, animname );
	node waittill( animname );
}

// self is the trigger
patrenko_check_thread_3( checknum )
{
	trigger_wait( "patrenko_check_" + checknum );
	flag_set( "P2NAZIBASE_OUTROBUILDING" );
}

// self is patrenko
patrenko_reminder_thread( remind_string )
{
	self endon( "patrenko_reminder_finish" );

	while( true )
	{
		wait(8);
		self thread fa_speak( remind_string );
	}
}


setup_explosions()
{
	level thread firebuilding1_thread();
	level thread firebuilding2_thread();
	level thread radar_building_mortar_hits_thread();
	
	// Set up threads that trigger drone-pwning mortar explosions
	max_drone_mortars = 10;
	for( i=1; i<=max_drone_mortars; i++ )
	{
		trig_name = ( "mortar_pwn_" + i + "_trigger" );
		trig = getent( trig_name, "targetname" );
		if( isDefined( trig ) )
		{
			trig thread mortar_pwn_thread( i );
		}
	}
}

// self should be a trigger, targetted at a struct that becomes the explosion's centerpoint
explosion_trigger_thread()
{
	assert( isdefined(self.target) );
	self waittill( "trigger" );

	center = getstruct( self.target, "targetname" );

	//play explosion
	center maps\_mortar::activate_mortar( 256, 400, 165, undefined, undefined, undefined , true);

	wait(0.1);

	if( isdefined(self.script_noteworthy) )
	{
		fa_start_drone_path( self.script_noteworthy, "axis" );
	}
}

firebuilding1_thread()
{
	points = getstructarray( "nazibase_firebuilding1_exp", "targetname" );
//	masts = getentarray( "nazibase_firebuilding1_mast", "targetname" );
//	guywires = getent( "nazibase_firebuilding1_guywires", "targetname" );

	player = get_player(); // define player variable - DMM

	assert( isdefined(points) && isarray(points) );
//	assert( isdefined(masts) && isarray(masts) );
//	assert( isdefined(guywires) );

	building01_keep_out_clip = GetEnt("building01_keep_out_clip", "targetname");
	building01_keep_out_clip notsolid();
	building01_keep_out_clip connectpaths();

	trigger_wait( "nazibase_firebuilding1_trigger" );
	// get the pass-through guys ready to go
	level thread passthrough_surrender_thread();

	level notify( "firebuilding1_explode" ); // triggers fullahead_fx::firebuilding1_explosion() to play fx and swap models
	level notify( "warehouse01_start" );
	exploder(101); // resulting fires and smoke due to mortar hit - DELETE ME when all are combined in one exploder

	// screen shake and rumble for when the building gets hit and explodes - DMM
	//p shellshock( "explosion", 5 );
	earthquake( 0.5, 2, player.origin, 200, player );
	player PlayRumbleOnEntity("artillery_rumble");

//	guywires delete();

//	wait(0.05);

//	for( i=0; i<masts.size; i++ )
//	{
//		masts[i] physicslaunch( masts[i].origin + (0,0,64), (250,0,0) );
//	}

	wait(0.25);

	ai = getaiarray( "allies", "axis" );
	for( i=0; i<ai.size; i++ )
	{
		if( isdefined(level.patrenko) && ai[i] == level.patrenko )
		{
			continue;
		}

		withinRange = false;
		delta = ( 0, 0, 0 );
		minDist = 100000000;

		for( ii=0; ii<points.size; ii++ )
		{
			dist = distance( ai[i].origin, points[ii].origin );
			if( (dist < 256) && (dist < minDist) )
			{
				withinRange = true;
				minDist = dist;
				delta = 100 * ( ai[i].origin - points[ii].origin ) / dist;
			}
		}

		if( withinRange )
		{
			verticalVel = 150;
			upwards = ( delta[0], delta[1], verticalVel );
			ai[i] thread burning_ragdoll( upwards );
		}
	}

	for( i=1; i<=3; i++)
	{
		burning_guy = simple_spawn_single( "building01_burning_man" + i );
		if( isDefined( burning_guy ) )
		{
			// Light 'em up
			PlayFxOnTag(level._effect["enemy_on_fire"], burning_guy, "J_SpineLower");
			burning_guy starttanning();

			burning_guy.animname = "generic";
//			burning_guy set_run_anim( "flame_death_run" );
//			runnodename = "building01_burning_man_dest_" + i;
//			node = getnode( runnodename, "targetname" );
//			if( isdefined( node ) )
//			{
//				burning_guy thread force_goal( node, 4, false );
//			}

//			burning_guy thread burn_and_die_thread();
//			wait( randomFloatRange( 0.5, 1.0 ) );

			// Replacement custom anims
			ref_node = getstruct( "onfire_a_ref", "targetname" );
	
			anim_name = ( "onfire_a_" + i );
			burning_guy thread burn_and_die_thread( ref_node, anim_name );
			burning_guy SetClientFlag(level.ACTOR_CHARRING);
			//burning_guy StartTanning(); 
			wait( RandomFloatRange( 0.5, 1.0 ) );
//			burning_guy ragdoll_death();
		}
	}
	
	wait( 3 );
	building01_keep_out_clip solid();
	building01_keep_out_clip disconnectpaths();

}

firebuilding2_thread()
{
	points = getstructarray( "nazibase_firebuilding2_exp", "targetname" );
	assert( isdefined(points) );

	player = get_player(); // define player variable - DMM

	building02_keep_out_clip = GetEnt("building02_keep_out_clip", "targetname");
	building02_keep_out_clip notsolid();
	building02_keep_out_clip connectpaths();

	officer_roof_destroyed = GetEnt("officer_roof_destroyed", "targetname");
	officer_roof_intact = GetEnt("officer_roof", "targetname");
	officer_roof_intact Show();
	officer_roof_destroyed Hide();

	trigger_wait( "nazibase_firebuilding2_trigger" );

	tossGuy1 = simple_spawn_single( "officer_explosion_toss_guy1" );
 	wait( 1.0 );   // wait for guy to spawn and exit

	level notify( "firebuilding2_explode" ); // triggers fullahead_fx::firebuilding1_explosion() to play fx and swap models
	exploder(111); // resulting fires and smoke due to mortar hit - DELETE ME when all are combined in one exploder

	// screen shake and rumble for when the building gets hit and explodes - DMM
	//p shellshock( "explosion", 5 );
	earthquake( 0.5, 2, player.origin, 200, player );
	player PlayRumbleOnEntity("artillery_rumble");

	wait(0.25);

	ai = getaiarray( "allies", "axis" );
	for( i=0; i<ai.size; i++ )
	{
		if( isdefined(level.patrenko) && ai[i] == level.patrenko )
		{
			continue;
		}

		withinRange = false;
		delta = ( 0, 0, 0 );
		minDist = 100000000;

		for( ii=0; ii<points.size; ii++ )
		{
			dist = distance( ai[i].origin, points[ii].origin );
			if( (dist < 256) && (dist < minDist) )
			{
				withinRange = true;
				minDist = dist;
				delta = 100 * ( ai[i].origin - points[ii].origin ) / dist;
			}
		}

		if( withinRange )
		{
			verticalVel = 150;
			upwards = ( delta[0], delta[1], verticalVel );
			ai[i] thread burning_ragdoll( upwards );
		}
	}

//	for( i=1; i<=2; i++)
	i=1;
	{
		burning_guy = simple_spawn_single( "officer_burning_man" + i );
		if( isDefined( burning_guy ) )
		{
			// Light 'em up
			PlayFxOnTag(level._effect["enemy_on_fire"], burning_guy, "J_SpineLower");
			burning_guy starttanning();

			burning_guy.animname = "generic";
//			burning_guy set_run_anim( "flame_death_run" );
//			runnodename = "officer_burning_man_dest_" + i;
//			node = getnode( runnodename, "targetname" );
//			if( isdefined( node ) )
//			{
//				burning_guy thread force_goal( node, 4, false );
//			}
			
//			burning_guy thread burn_and_die_thread();
//			wait( randomFloatRange( 0.5, 1.0 ) );
			
			// Replacement custom anims
			ref_node = getstruct( "onfire_b_ref", "targetname" );
	
			anim_name = ( "onfire_b_" + i );
			burning_guy thread burn_and_die_thread( ref_node, anim_name );
			
			wait( RandomFloatRange( 0.5, 1.0 ) );
//			burning_guy ragdoll_death();
		}
	}
	
//	wait( 3 );
//	building02_keep_out_clip solid();
//	building02_keep_out_clip disconnectpaths();

	kill_spawnernum( 3 ); // remove the spawners in that particular building
}

passthrough_surrender_thread()
{
	simple_spawn( "nazibase_passthrough_surrender_guy" );
	
	trigger_wait( "passthrough_surrender_spawn" );
	simple_spawn( "nazibase_passthrough_surrender_guy_2" );
	level thread trigger_surrender_thread( "nazibase_passthrough_surrender_trigger" );
}

destroy_barricade_thread()
{
//    level.scr_sound["Petrenko"]["weneedtobreak"] = "vox_ful1_s03_310A_dimi"; //Reznov! We need to break this barricade!
//    level.scr_sound["Petrenko"]["grabthesmokegrenades1"] = "vox_ful1_s03_311A_dimi"; //Grab the Smoke grenades... Use them to mark the target for our mortar teams.

    // When both Petrenko and the player are in position, call in the mortars
//	player = get_player();
//	petrenko = level.patrenko;
//
//	// Watch for the player to exit the launch building
//	level thread watch_reznov_exit_launch_bldg_trigger();
//	
//	petrenko waittill( "goal" );
//	flag_wait( "P2NAZIBASE_REZNOV_EXITED_LAUNCH_BUILDING" );
//	flag_set( "P2NAZIBASE_GET_GRENADES" );
//	//petrenko headtracking_start( player );
//	petrenko anim_single( petrenko, "weneedtobreak", "Petrenko" );
//	petrenko anim_single( petrenko, "grabthesmokegrenades1", "Petrenko" );
//
//	petrenko disable_ai_color();
//	node = getnode( "dest_petrenko_barricade", "targetname" );
// 	petrenko thread force_goal( node, 4, false );
//
//	petrenko thread help_player_blow_barricade();
//
//	level thread get_smoke_grenades();
}

hide_smoke_grenades()
{
	smoke_grenades = getentarray("smoke_grenade", "targetname");
	for( i=0; i<smoke_grenades.size; i++ )
	{
		smoke_grenades[i] hide();
	}
}

show_smoke_grenades()
{
	smoke_grenades = getentarray("smoke_grenade", "targetname");
	for( i=0; i<smoke_grenades.size; i++ )
	{
		smoke_grenades[i] show();
	}
}

watch_smoke_grenade_pickup_trigger()
{
 	trigger_wait( "smoke_grenade_trigger", "targetname" );
	level thread smoke_grenade_hint();
  flag_set( "P2NAZIBASE_SMOKE_GRENADES_FOUND" );
	trigger_wait("trigger_mortar_strike_block");
	destroy_barricade();

}
	
watch_reznov_exit_launch_bldg_trigger()
{
   	trigger_wait( "reznov_exiting_launch_bldg", "targetname" );
   	flag_set( "P2NAZIBASE_REZNOV_EXITED_LAUNCH_BUILDING" );
}

get_smoke_grenades()
{
//    level.scr_sound["Petrenko"]["grabthesmokegrenades2"] = "vox_ful1_s03_312A_dimi"; //Reznov - Grab the smoke Grenades!
//    level.scr_sound["Petrenko"]["grabthesmokegrenades3"] = "vox_ful1_s03_313A_dimi"; //We need the smoke grenades, Reznov!
//    level.scr_sound["Petrenko"]["throwoneatbarricade"] = "vox_ful1_s03_314A_dimi"; //Throw one at the base of the barricade!

	petrenko = level.patrenko;
	player = get_player();

	seconds_waited = 0;
	time_increment = 0.5;
   	while( !flag( "P2NAZIBASE_SMOKE_GRENADES_FOUND" ) )
   	{
	   	if( seconds_waited > 6 )
	   	{
			//petrenko headtracking_start( player );
		   	phrase = randomInt(2);
		   	if( phrase == 0 )
		   	{
				petrenko anim_single( petrenko, "grabthesmokegrenades2", "Petrenko" );
		   	}
		   	else if( phrase == 1 )
		   	{
				petrenko anim_single( petrenko, "grabthesmokegrenades3", "Petrenko" );
		   	}
		   	seconds_waited = 0;
	   	}
	   	wait( time_increment );
 	   	seconds_waited += time_increment;
  	}
	
	wait(1);
	//petrenko headtracking_start( player );
	//petrenko anim_single( petrenko, "throwoneatbarricade", "Petrenko" );
	//flag_set( "P2NAZIBASE_MARK_BARRICADE" );
	level thread check_smoke_grenades();
	//
	wait(2);
	
	level thread smoke_grenade_hint();
	player thread pickup_smoke_grenades_thread();
	
	//destroy_barricade();
	petrenko enable_ai_color();
	
	
}
	
	
// Self is Level
pickup_smoke_grenades_thread()
{
	player = get_player();
	while( true )
	{
		num_smoke_grenades = player GetAmmoCount( "m8_orange_smoke_sp" );
		num_grenades_acquired = 0;
		smoke_grenades = getentarray( "smoke_grenade", "targetname" );
		
		if( (num_smoke_grenades < 4) && (smoke_grenades.size > 0) )
		{
			// Do a close radius search and if a grenade shows up in the search, start over with a wide radius search
			// This should allow the player to grab all he has room for in a given spot with a single pick-up event.
			inner_range = 64;
			outer_range = 128;
			check_range = inner_range;
			for( i=0; i<smoke_grenades.size; ) // Manage the iterator in the loop - not here
			{
				if( check_range == inner_range )
				{
					dist = distance( player.origin, smoke_grenades[i].origin );
					if( dist < check_range )
					{
						if( num_smoke_grenades == 0 )
						{
							player GiveWeapon( "m8_orange_smoke_sp" );
							player SetWeaponAmmoStock( "m8_orange_smoke_sp", 0 );
						}
						check_range = outer_range;
						i = 0; // Found one in the short range search - start over with the long range search
					}
					else
					{
						i++; // next
					}
				}
				else
				{
					dist = distance( player.origin, smoke_grenades[i].origin );
					if( dist < check_range )
					{
						player SetWeaponAmmoStock( "m8_orange_smoke_sp", num_smoke_grenades+1 );
						smoke_grenades[i] delete();
						num_smoke_grenades++;
						num_grenades_acquired++;
						
						if( num_smoke_grenades >= 4 )
						{
							break;
						}
					}
					i++; // next
				}
			}
		}
		
		if( num_grenades_acquired == 1 )
		{
			//iprintln( &"FULLAHEAD_ACQUIRED_1_SMOKE" );
		}
		else if( num_grenades_acquired == 2 )
		{
			//iprintln( &"FULLAHEAD_ACQUIRED_2_SMOKE" );
		}
		else if( num_grenades_acquired == 3 )
		{
			//iprintln( &"FULLAHEAD_ACQUIRED_3_SMOKE" );
		}
		else if( num_grenades_acquired == 4 )
		{
			//iprintln( &"FULLAHEAD_ACQUIRED_4_SMOKE" );
		}
		wait( 0.6 );
	}
}

smoke_grenade_hint()
{

	level endon("message_delete");
	screen_message_create( &"FULLAHEAD_MORTAR_PROMPT" );
	
	p = get_player();
	p thread delete_message_after_a_while();
	while( true )
	{
		p waittill("grenade_fire", smoke, weapname);
		if( weapname == "m8_orange_smoke_sp" )
		{
			screen_message_delete();
			level notify("message_delete");
			return;
		}
	}
}
delete_message_after_a_while()
{
	level endon("message_delete");
	wait(5);
	screen_message_delete();
	level notify("message_delete");

}

place_smoke_grenades()
{
	show_smoke_grenades();

	//guy = simple_spawn_single( "smoke_grenade_deadguy" );
	//guy die();
	//guy startragdoll(); // don't drop weapons in the way

}

check_smoke_grenades()
{
	while( 1 )
	{
		get_player() waittill("grenade_fire", smoke, weapname);
		if( weapname == "m8_orange_smoke_sp" )
		{
			level thread handle_thrown_smoke_grenade( smoke );
		}
	}
}

handle_thrown_smoke_grenade( smoke )
{
//	level.scr_sound["Petrenko"]["spotterswillneversee"] = "vox_ful1_s03_319A_dimi"; //The spotters will never see that smoke!
//	level.scr_sound["Petrenko"]["throwitoutside"] = "vox_ful1_s03_320A_dimi"; //Throw it outside!
//	level.scr_sound["Petrenko"]["outside"] = "vox_ful1_s03_321A_dimi"; //Outside, Reznov!
//	level.scr_sound["Russian Soldier"]["wehavetarget"] = "vox_ful1_s03_322A_rrd9_f"; //We have your target.
//	level.scr_sound["Russian Soldier"]["standby"] = "vox_ful1_s03_323A_rrd9_f"; //Stand by for mortars.
//	level.scr_sound["Russian Soldier"]["firing1"] = "vox_ful1_s03_324A_rrd9_f"; //Firing mortars.
//	level.scr_sound["Russian Soldier"]["firing2"] = "vox_ful1_s03_325A_rrd9_f"; //Firing - Stand by.
//	level.scr_sound["Russian Soldier"]["firing3"] = "vox_ful1_s03_326A_rrd9_f"; //Mortars inbound.
//	level.scr_sound["Russian Soldier"]["noclearshot"] = "vox_ful1_s03_327A_rrd9_f"; //We don't have a clear shot!

    player = get_player();
	petrenko = level.patrenko;

	smokestruct = spawn( "script_origin", smoke.origin );
	smoke thread update_smoke_position( smokestruct );
	
	smoke waittill( "explode");

	created_player_smoke_struct = false;
	if( isDefined( player.smokestruct ) )
	{
		player.smokestruct.origin = smokestruct.origin;
	}
	else
	{
		player.smokestruct = spawn( "script_origin", smokestruct.origin );
		created_player_smoke_struct = true;
	}

	// Choose 3 spots close to the smoke for mortars to hit
	mortar_spot1 = spawn( "script_origin", smokestruct.origin );
	mortar_spot2 = spawn( "script_origin", smokestruct.origin );
	mortar_spot3 = spawn( "script_origin", smokestruct.origin );
	
	blowing_barricade = false;
	
	//if( !flag( "P2NAZIBASE_BARRICADE_DESTROYED" ) )
	//{
	//	barricade_mortar1 = getstruct( "barricade_mortar1", "targetname" );
	//	miss_dist = distance( smokestruct.origin, barricade_mortar1.origin );
	//	if( miss_dist <= 512 )
	//	{
	//		blowing_barricade = true;
	//		barricade_mortar2 = getstruct( "barricade_mortar2", "targetname" );
	//		barricade_mortar3 = getstruct( "barricade_mortar3", "targetname" );
	//		
	//		mortar_spot1.origin = barricade_mortar1.origin;
	//		mortar_spot2.origin = barricade_mortar2.origin;
	//		mortar_spot3.origin = barricade_mortar3.origin;
	//	}
	//}

	if( !blowing_barricade )
	{		
		// Always put one mortar directly on the smoke - The other two will hit close by.
		// Then - Offset up and trace downward to get a mortar collision point
		on_target_mortar = randomInt(3) + 1;
		if( on_target_mortar != 1 )
		{
			x_dist = RandomIntRange( -150, 150 );
			y_dist = RandomIntRange( -150, 150 );
			mortar_spot1.origin += ( x_dist, y_dist, 0 );
			trace = bullettrace( mortar_spot1.origin + (0,0,1000), mortar_spot1.origin + (0,0,-2000), false, undefined );
			if( isDefined( trace ) )
			{
				mortar_spot1.origin = trace["position"];
			}
		}
		if( on_target_mortar != 2 )
		{
			x_dist = RandomIntRange( -150, 150 );
			y_dist = RandomIntRange( -150, 150 );
			mortar_spot2.origin += ( x_dist, y_dist, 0 );
			trace = bullettrace( mortar_spot2.origin + (0,0,1000), mortar_spot2.origin + (0,0,-2000), false, undefined );
			if( isDefined( trace ) )
			{
				mortar_spot2.origin = trace["position"];
			}
		}
		if( on_target_mortar != 3 )
		{
			x_dist = RandomIntRange( -150, 150 );
			y_dist = RandomIntRange( -150, 150 );
			mortar_spot3.origin += ( x_dist, y_dist, 0 );
			trace = bullettrace( mortar_spot3.origin + (0,0,1000), mortar_spot3.origin + (0,0,-2000), false, undefined );
			if( isDefined( trace ) )
			{
				mortar_spot3.origin = trace["position"];
			}
		}
		
		// Let the allies know that the smoke marks a Bad Place to be...
		BadPlace_Cylinder( "incoming", 6.3, smokestruct.origin, 550, 300, "allies" );
	}

	// If the smoke is inside - don't fire mortars
	smoke_is_inside = false;
	interior = getentarray("building_interior", "targetname");
	for( i=0; i<interior.size; i++ )
	{
		if( smokestruct isTouching( interior[i] ) )
		{
			smoke_is_inside = true;
			break;
		}
	}


	if(!IsDefined(petrenko.gave_smoke_hint))
	{
		petrenko.gave_smoke_hint = false;
	}

	if( smoke_is_inside )
	{
		PlayFx( level._effect["orange_smoke_int"], smokestruct.origin );
		wait( 1 );

		wait( 2 );
		if( petrenko.gave_smoke_hint )
		{
			petrenko_vo_line = randomInt(2);
			if( petrenko_vo_line == 0 )
			{
				petrenko anim_single( petrenko, "throwitoutside", "Petrenko" );
			}
			else if( petrenko_vo_line == 1 )
			{
				petrenko anim_single( petrenko, "outside", "Petrenko" );
			}
		}
		else
		{
			petrenko anim_single( petrenko, "spotterswillneversee", "Petrenko" );
			petrenko anim_single( petrenko, "throwitoutside", "Petrenko" );
			petrenko.gave_smoke_hint = true;
		}
		wait(2);
		player anim_single( player, "noclearshot", "Russian Soldier" );

		return;
	}
	else
	{
		PlayFx( level._effect["orange_smoke"], smokestruct.origin );
		wait( 1 );
	}
	
	// Mortar Spotter confirmation	
	mortar_vo_line = player GetAmmoCount( "m8_orange_smoke_sp" );
	if( flag( "P2NAZIBASE_BARRICADE_DESTROYED" ) )
	{
		mortar_vo_line = randomInt(3);
	}
	
	if( mortar_vo_line == 0 )
	{
		player anim_single( player, "firing3", "Russian Soldier" );
	}
	else if( mortar_vo_line == 1 )
	{
		player anim_single( player, "firing2", "Russian Soldier" );
	}
	else if( mortar_vo_line == 2 )
	{
		player anim_single( player, "firing1", "Russian Soldier" );
	}
	else
	{
		player anim_single( player, "wehavetarget", "Russian Soldier" );
		player anim_single( player, "standby", "Russian Soldier" );
	}

	wait(1);

	kill_radius = 200;
	mortar_spot1 thread maps\_mortar::activate_mortar( kill_radius, 400, 165, undefined, undefined, undefined, true);
	level thread kill_guys_in_local_column( mortar_spot1, kill_radius );
	wait( RandomFloatRange( 0.25, 0.65) );
	
	mortar_spot2 thread maps\_mortar::activate_mortar( kill_radius, 400, 165, undefined, undefined, undefined, true);
	level thread kill_guys_in_local_column( mortar_spot2, kill_radius );
	wait( RandomFloatRange( 0.25, 0.65) );
	
	mortar_spot3 thread maps\_mortar::activate_mortar( kill_radius, 400, 165, undefined, undefined, undefined, true);
	level thread kill_guys_in_local_column( mortar_spot3, kill_radius );
	


	wait(15); // Till _mortar::activate_mortar() is no longer using the script_origins 
	
	smokestruct delete();
	if( created_player_smoke_struct )
	{
		player.smokestruct delete();
	}
	
	mortar_spot1 delete();
	mortar_spot2 delete();
	mortar_spot3 delete();
}

// Kill and throw guys in the vertical vicinity of the explosion (handles the case of the bridge in the middle of the base)
kill_guys_in_local_column( mortar_spot, kill_radius )
{
	guys = getaiarray( "axis", "allies", "neutral" );

	// wait till the mortar actually goes off
	mortar_spot waittill( "mortar" );

	for( i=0; i<guys.size; i++ )
	{		
		if(( guys[i] == level.Patrenko )
		|| ( guys[i] == get_player() )
		|| ( !isAlive( guys[i] ) ))
		{
			continue;
		}

		guy = guys[i];
		// Check 2D range
		spot = ( mortar_spot.origin[0], mortar_spot.origin[1], guy.origin[2] );
		if( distance( guy.origin, spot ) < kill_radius )
		{
			// turn off regular death anims so the guy goes flying even if explosive death anim can't be played
			guy.skipDeathAnim = true;

			guy DoDamage( guy.health + 10, mortar_spot.origin, undefined, undefined, "explosive" );
		}
	}
}

// self is the smoke (grenade)
update_smoke_position( smokestruct )
{
	self endon( "death" );
	
	while( isDefined( smokestruct ) )
	{
		smokestruct.origin = self.origin;
		wait( 0.1 );
	}
}

destroy_barricade()
{
	spawn_manager_enable( "p2nazibase_sm05" );
	spawn_manager_enable( "p2nazibase_sm_bridge" );
	
	autosave_by_name( "fullahead" );

	mg42 = getent( "mg_turret_2", "targetname" );
	mg42 setup_mg42();
	turret_node = getent( "mg_turret_2_node", "targetname" );
	gunner_spawner = getent( "mg42_gunner_spawn_2",  "targetname" );
	strTrig = "mg42_2_overrun";
	strFlag = "P2NAZIBASE_MG42_2_OVERRUN";
	level thread set_flag_when_triggered( strTrig, strFlag );
	mg42 thread man_mg42( turret_node, gunner_spawner, strFlag );

	exploder( 220 ); // Explosion FX for barricade
	level notify( "barrier_start" ); // Go Go "hero" chunks...
	
	// swap out intact street barricade with blasted open path
	street_barricade_models = getentarray("street_barricade_models", "targetname");
	for( i=0; i<street_barricade_models.size; i++ )
	{
		street_barricade_models[i] delete();
	}

	gate_long_barricade1a = GetEnt("gate_long_barricade1a", "targetname");
	gate_long_barricade2a = GetEnt("gate_long_barricade2a", "targetname");
	gate_long_barricade1b = GetEnt("gate_long_barricade1b", "targetname");
	gate_long_barricade2b = GetEnt("gate_long_barricade2b", "targetname");
	
	gate_long_barricade1a Hide();
	gate_long_barricade2a Hide();
	gate_long_barricade1b Show();
	gate_long_barricade2b Show();

    gate_long_barricade1b PlaySound( "exp_mortar_dirt" );
    gate_long_barricade2b PlaySound( "exp_veh_large" );

	street_barricade_clip = GetEnt("street_barricade_clip", "targetname");
	street_barricade_clip connectpaths();
	street_barricade_clip delete();
	
	flag_set( "P2NAZIBASE_BARRICADE_DESTROYED" );
	activate_triggers( "into_the_breach", "targetname" );
	//level.patrenko headtracking_stop();
	
	wait(3);
	
	mg42 = getent( "mg_turret_2", "targetname" );
	mg42 setup_mg42();
	turret_node = getent( "mg_turret_2_node", "targetname" );
	gunner_spawner = getent( "mg42_gunner_spawn_2",  "targetname" );
	strTrig = "mg42_2_overrun";
	strFlag = "P2NAZIBASE_MG42_2_OVERRUN";
	level thread set_flag_when_triggered( strTrig, strFlag );
	mg42 thread man_mg42( turret_node, gunner_spawner, strFlag );
}

// Provide helpful dialogue and do it yourself if the player fails completely (self is Petrenko)
help_player_blow_barricade()
{
//	level.scr_sound["Petrenko"]["throwoneatbarricade"] = "vox_ful1_s03_314A_dimi"; //Throw one at the base of the barricade!
//	level.scr_sound["Petrenko"]["markthebarricade"] = "vox_ful1_s03_315A_dimi"; //Mark the barricade for the mortars!
//	level.scr_sound["Petrenko"]["closertothebarricade"] = "vox_ful1_s03_316A_dimi"; //Closer to the barricade, Viktor!
//	level.scr_sound["Petrenko"]["areyoudrunk"] = "vox_ful1_s03_317A_dimi"; //Are you drunk, Viktor? Throw it at the barricade!
//	level.scr_sound["Petrenko"]["illmarkitmyself"] = "vox_ful1_s03_318A_dimi"; //I'll mark it myself, Reznov. Stand back!
//	level.scr_sound["Russian Soldier"]["wehavetarget"] = "vox_ful1_s03_322A_rrd9_f"; //We have your target.
//	level.scr_sound["Russian Soldier"]["standby"] = "vox_ful1_s03_323A_rrd9_f"; //Stand by for mortars.
//	level.scr_sound["Russian Soldier"]["firing3"] = "vox_ful1_s03_326A_rrd9_f"; //Mortars inbound.

	player = get_player();
	
	self.gave_smoke_hint = false;
	
	level thread watch_smoke_grenade_pickup_trigger();
	
	flag_wait( "P2NAZIBASE_MARK_BARRICADE" );
	
	while( player GetAmmoCount( "m8_orange_smoke_sp" ) <= 0 )
	{
		wait( 0.2 );
	}

	num_smoke_grenades_at_last_comment = player GetAmmoCount( "m8_orange_smoke_sp" );
	already_said_closer = false;
	already_said_are_you_drunk = false;
	
	seconds_waited = 0;
	time_increment = 0.5;
	phrase = 1;

	while( player GetAmmoCount( "m8_orange_smoke_sp" ) > 0 )
	{
		// Coax the player to throw a smoke grenade
	   	if( seconds_waited > 5 )
	   	{
			self headtracking_start( player );
		   	if( phrase == 1 )
		   	{
				self anim_single( self, "throwoneatbarricade", "Petrenko" );
				phrase = 2;
		   	}
		   	else if( phrase == 2 )
		   	{
				self anim_single( self, "markthebarricade", "Petrenko" );
				phrase = 1;
		   	}
		   	seconds_waited = 0;
	   	}
	   	wait( time_increment );
 	   	seconds_waited += time_increment;
	
		
		level endon( "P2NAZIBASE_BARRICADE_DESTROYED" );
		if( player GetAmmoCount( "m8_orange_smoke_sp" ) < num_smoke_grenades_at_last_comment )
		{
			num_smoke_grenades_at_last_comment = player GetAmmoCount( "m8_orange_smoke_sp" );
			seconds_waited = 0;

			while( !isDefined( player.smokestruct ) )
			{
				wait( 0.2 );
			}
			barricade_mortar1 = getstruct( "barricade_mortar1", "targetname" );
			miss_dist = distance( player.smokestruct.origin, barricade_mortar1.origin );
			wait( 1 );
			if( miss_dist > 512 )
			{
				if( !already_said_closer && (miss_dist < 1000) )
				{
					self anim_single( self, "closertothebarricade", "Petrenko" );
					already_said_closer = true;
				}
				else if( !already_said_are_you_drunk )
				{
					self anim_single( self, "areyoudrunk", "Petrenko" );
					already_said_are_you_drunk = true;
				}
			}
		}
		
		wait( 1 );
	}

	wait( 10 );
	
	self headtracking_stop();
	level endon( "P2NAZIBASE_BARRICADE_DESTROYED" );
	self anim_single( self, "illmarkitmyself", "Petrenko" );
	
	mortar_spot1 = getstruct( "barricade_mortar1", "targetname" );
	mortar_spot2 = getstruct( "barricade_mortar2", "targetname" );
	mortar_spot3 = getstruct( "barricade_mortar3", "targetname" );

	self maps\_grenade_toss::force_grenade_toss( mortar_spot1.origin, "m8_orange_smoke_sp", 3.0, undefined, undefined );
	 	
	wait( 1 );
	PlayFx( level._effect["orange_smoke"], mortar_spot1.origin );
	wait( 1 );

	player anim_single( player, "firing3", "Russian Soldier" );
	wait(1);

	kill_radius = 350;
	mortar_spot1 thread maps\_mortar::activate_mortar( kill_radius, 400, 165, undefined, undefined, undefined, true);
	wait( RandomFloatRange( 0.25, 0.65) );
	
	mortar_spot2 thread maps\_mortar::activate_mortar( kill_radius, 400, 165, undefined, undefined, undefined, true);
	wait( RandomFloatRange( 0.25, 0.65) );
	
	mortar_spot3 thread maps\_mortar::activate_mortar( kill_radius, 400, 165, undefined, undefined, undefined, true);

	
	self enable_ai_color();
}

remind_player_to_use_smoke_grenades( phrase )
{
//	level.scr_sound["Petrenko"]["usesmokegrenades1"] = "vox_ful1_s03_334A_dimi"; //Reznov - if  you have any more smoke grenades - Use them now!
//	level.scr_sound["Petrenko"]["usesmokegrenades2"] = "vox_ful1_s03_335A_dimi"; //Use your smoke grenades!
//	level.scr_sound["Petrenko"]["usesmokegrenades3"] = "vox_ful1_s03_336A_dimi"; //Use your smoke to mark targets for our mortars!

	level endon( "stop_smoke_reminder" );
	
	player = get_player();
	petrenko = level.patrenko;

	total_seconds_waited = 0;
	seconds_waited = 0;
	time_increment = 0.5;
	delay_time = 10;

	while( total_seconds_waited <= ( 3 * delay_time ) )
	{
	   	if( seconds_waited > delay_time )
	   	{
			//petrenko headtracking_start( player );
		   	if( phrase == 1 )
		   	{
				petrenko anim_single( petrenko, "usesmokegrenades1", "Petrenko" );
		   	}
		   	else if( phrase == 2 )
		   	{
				petrenko anim_single( petrenko, "usesmokegrenades2", "Petrenko" );
		   	}
		   	else if( phrase == 3 )
		   	{
				petrenko anim_single( petrenko, "usesmokegrenades3", "Petrenko" );
		   	}
		   	seconds_waited = 0;
		   	phrase++;
		   	if( phrase > 3 )
		   	{
			   	phrase = 1;
		   	}
	   	}
	   	wait( time_increment );
 	   	seconds_waited += time_increment;
 	   	total_seconds_waited += time_increment;
	}
}

burn_and_die_thread( ref_node, anim_name )
{
   	self endon( "death" );
	self.ignoreall = true;
	
	self playsound ("vox_fire_scream");

	ref_node anim_teleport( self, anim_name );
	ref_node thread anim_single_aligned( self, anim_name );
  	
	// TODO: Find out how to do this as a death animation. For now fake it by ragdolling and dieing just befor the animation finishes
	anim_length = GetAnimLength( level.scr_anim["generic"][anim_name] );
	wait( anim_length - 0.1 );

  	self startragdoll();
  	self die();
}

radar_building_mortar_hits_thread()
{
	mortar_hit1_point = getstruct( "radar_mortar1_point", "targetname" );
	mortar_hit2_point = getstruct( "radar_mortar2_point", "targetname" );

	assert( isdefined(mortar_hit1_point) );
	assert( isdefined(mortar_hit2_point) );

	trigger_wait( "radar_building_mortar_hits_trigger" );

	mortar_hit1_point maps\_mortar::activate_mortar( 256, 400, 165, undefined, undefined, undefined, true);

	wait( 0.25 );
	mortar_hit2_point maps\_mortar::activate_mortar( 256, 400, 165, undefined, undefined, undefined, true);
}

mortar_pwn_thread( index )
{
	self waittill( "trigger" );
	wait( 2 );
	point = ( "mortar_pwn_" + index );
	mortar_hit_point = getstruct( point, "targetname" );
	
	mortar_hit_point maps\_mortar::activate_mortar( 256, 400, 165, undefined, undefined, undefined, true);
}

nazibase_firsthill_vips()
{
	// lines at the very start of the base by the dogsleds
//    level.scr_sound["Dragovich"]["getsteiner"] = "vox_ful1_s03_039A_drag"; //The German must not be harmed - We need Steiner alive... Now move - both of you!
//    level.scr_sound["Petrenko"]["letsgo"] = "vox_ful1_s03_040A_dimi"; //Let's go.


	destnode1 = getnode( "p2nazibase_vip_removal1", "targetname" );
	destnode2 = getnode( "p2nazibase_vip_removal2", "targetname" );
	assert( isdefined(destnode1) );
	assert( isdefined(destnode2) );


	petrenko = level.patrenko;
	
	drag = simple_spawn_single( "p2nazibase_vip1_spawn" );
	drag.name = "Dragovich";
	drag make_hero();
	//drag hidepart("tag_weapon");
	drag.goalradius = 32;
	drag.ignoreall = true;



	krav = simple_spawn_single( "p2nazibase_vip2_spawn" );
	krav.name = "Kravchenko";
	krav make_hero();
	//krav hidepart("tag_weapon");
	krav.goalradius = 32;
	krav.ignoreall = true;

	struct = getstruct( "p2nazibase_find_steiner", "targetname" );
	assert( isdefined(struct) );

	struct thread play_player_anim( struct, "find_steiner", "playerbody" );
	
	struct thread anim_single_aligned( petrenko, "find_steiner", undefined, "petrenko" );
	struct thread anim_single_aligned( drag, "find_steiner", undefined, "dragovich" );
	struct thread anim_single_aligned( krav, "find_steiner", undefined, "kravchenko" );

// DELETE ME: temp script to allow for quick testing of mortar behavior
//	player = get_player();
//	player giveweapon( "m8_orange_smoke_sp" );
//	level thread check_smoke_grenades();

	level thread up_the_hill_dialog();
	level thread dk_leave_thread();
	
	struct waittill( "find_steiner" );
	////struct thread anim_loop_aligned( drag, "find_steiner_idle", undefined, "stop_steiner_idle", "dragovich" );
	////struct thread anim_loop_aligned( krav, "find_steiner_idle", undefined, "stop_steiner_idle", "kravchenko" );

	//flag_wait( "DK_LEAVE" );
	
	//struct notify( "stop_steiner_idle" );

	drag setgoalnode( destnode1 );
	krav setgoalnode( destnode2 );

	drag waittill( "goal" );

	drag delete();
	krav delete();
}

dk_leave_thread()
{
	trigger_wait( "nazibase_dk_leave" );
	flag_set( "DK_LEAVE" );
}

up_the_hill_dialog()
{
    // VO lines as Petrenko and Reznov move up the hill to engage
//    level.scr_sound["Petrenko"]["itisgoodtofight"] = "vox_ful1_s03_300A_dimi"; //It is good to fight by your side once more.
//    level.scr_sound["Reznov"]["yesmyfriend"] = "vox_ful1_s03_301A_rezn"; //Yes, my friend... One final victory.
//    level.scr_sound["Reznov"]["searcheverycorner"] = "vox_ful1_s03_302A_rezn"; //Search every corner of this camp!  Only Steiner is to be spared.

//    level.scr_sound["Reznov"]["reznovcheer"] = "vox_ful1_s03_328A_rezn"; //URA!!!

	wait( 9 );
	
	player = get_player();
	petrenko = level.patrenko;
	
//	petrenko_wp = getnode( "petrenko_wp_1", "targetname" );
//	petrenko disable_ai_color();
//	petrenko thread force_goal( petrenko_wp, 4, false );

//	petrenko waittill( "goal" );
	petrenko LookAtEntity( player );

	petrenko anim_single( petrenko, "itisgoodtofight", "Petrenko" );
	
	petrenko enable_ai_color();
	petrenko LookAtEntity();

	player anim_single( player, "yesmyfriend", "Reznov" );
	player anim_single( player, "searcheverycorner", "Reznov" );
	
	player anim_single( player, "reznovcheer", "Reznov" );
	allies = GetAIArray("allies");
	//C. Ayers: Cheers should be called from scripted lines if they exist
    //array_thread( allies, ::play_cheer_vox );
}

play_cheer_vox()
{
//    level.scr_sound["Crowd"]["crowdcheer"] = "vox_ful1_s03_329A_crow"; //URA!!!

	self endon( "death" );
	level endon( "stop_cheer_vox" );
    
	while( 1 )
	{
		self PlaySound( "crowdcheer", "sounddone" );
		self waittill( "sounddone" );
		wait( RandomFloatRange(1,4) );
	}
}

fuel_area_dialog()
{
//    level.scr_sound["Petrenko"]["notgivingup"] = "vox_ful1_s03_303A_dimi"; //They are not giving up without a fight!
//    level.scr_sound["Reznov"]["menwithnothing"] = "vox_ful1_s03_304A_rezn"; //Men with nothing to lose make for a dangerous enemy, Dimitri.
	
	player = get_player();
	petrenko = level.patrenko;

	petrenko disable_ai_color();
	petrenko LookAtEntity( player );

	//petrenko anim_single( petrenko, "notgivingup", "Petrenko" );
	//player anim_single( player, "menwithnothing", "Reznov" );

	petrenko enable_ai_color();
	petrenko LookAtEntity();
}

ready_dialog()
{
	player = get_player();

	trigger_wait( "ready_trigger" );
	player anim_single( player, "ready", "Reznov" );
}

// self should be level
trigger_surrender_thread( triggername, spawnernum )
{
//    level.scr_sound["Reznov"]["thiswaydimitri"] = "vox_ful1_s03_332A_rezn"; //This way, Dimitri!

   	wait( 1.0 );
	
	trigger_wait( triggername );
	
	if( triggername == "nazibase_hangar_surrender_trigger" )
	{
		player = get_player();
		player anim_single( player, "thiswaydimitri", "Reznov" );
		level thread patrenko_hangar_door();
	}

	guys = get_ai_touching_volume( "axis", triggername );

	p = get_player();
	// get whoever's still alive -- if they are
	// ...and make sure they can see me.
	for( i=0; i<guys.size; i++ )
	{
		guy = guys[i];
//		player_in_view = guy ai_can_see_player( p );
//		if( isalive(guy) && player_in_view )
		if( isalive(guy) )
		{			
			if (guy.a.pose == "crouch")
			{
		 		guy thread guy_surrender_thread( randomint(2) + 4 );
	 		}
	 		else
	 		{
		 		guy thread guy_surrender_thread( randomint(3) + 1 );
	 		}

			wait( RandomFloatRange( 0.2, 0.5 ) );
		}
	}

	if( isdefined(spawnernum) )
	{
		kill_spawnernum( spawnernum ); // remove the spawners in that particular building
	}
}

// self should be the guy surrendering
guy_surrender_thread( animnum )
{
//	level.scr_sound["German Soldier"]["pleasedontkillme"] = "vox_ful1_s99_721A_ger1"; //(Translated) Please, don't kill me!
//	level.scr_sound["German Soldier"]["igiveup"] = "vox_ful1_s99_722A_ger1"; //(Translated) I give up!

	self.surrender_animnum = animnum;
	self AnimCustom( ::guy_surrender_anim_custom );
}

guy_surrender_anim_custom()
{
   	self endon( "death" );
	self endon( "pain_death" );
	self.ignoreall = true;

	// Turn to face the player
	self orientMode( "face point", get_player().origin );
	wait( 1.0 ); // Give them time to turn

	fa_print( "Surrendering guy playing surrender" + self.surrender_animnum + " at position " + self.origin );
	self thread surrender_ragdoll_thread();

	// get the animation
	animation = level.scr_anim[ "generic" ]["surrender" + self.surrender_animnum];
	
	// play the fist animation
	anim_length = GetAnimLength( animation );
	self SetFlaggedAnimKnobAllRestart( "surrender_anim", animation, %body, 1, .1, 1 );
	animscripts\shared::DoNoteTracksForTime( anim_length - 0.1, "surrender_anim" );	
	
	fa_print( "Surrendering guy playing surrender" + self.surrender_animnum + "_loop at position " + self.origin );
	self thread anim_generic_loop( self, "surrender" + self.surrender_animnum + "_loop", "surrender_end" );
	
	// dialogue
	phrase = randomInt(3);
	if( phrase == 0 )
	{
		self anim_single( self, "pleasedontkillme", "German Soldier" );
	}
	else if( phrase == 1 )
	{
		self anim_single( self, "igiveup", "German Soldier" );
	}
	
	// After a delay, kill this guy when out of sight
	wait( 10 );
	while( self ai_can_see_player(get_player()) )
	{
		wait(1.7);
	}
	
	self ragdoll_death();
}

surrender_ragdoll_thread()
{
   	self endon( "death" );
	
	self waittill( "damage" );
	self notify( "surrender_end" );
	self ragdoll_death();
}

surrender_dialog()
{
    // VO lines the first time you see surrendering guys
//    level.scr_sound["Soldier"]["surrender"] = "vox_ful1_s03_041A_rrd8"; //They are trying to surrender!
//    level.scr_sound["Reznov"]["theyhavetried"] = "vox_ful1_s03_042A_rezn"; //They have tried before...
//    level.scr_sound["Reznov"]["donotlet"] = "vox_ful1_s03_043A_rezn"; //Do not let them.

   	while( true )
	{
		soldier_is_near = false;
		guys = get_ai_touching_volume( "allies", "p2nazibase_breadcrumb1" );
		for( i=0; i<guys.size; i++ )
		{
			guy = guys[i];
			if( isalive(guy) && (guy != level.patrenko) )
			{
				guy anim_single( guy, "surrender", "Soldier" );
				soldier_is_near = true;
				break;
			}
		}
		if( soldier_is_near )
		{
			break;
		}
		else
		{
			wait(0.2);
		}
	}

	player = get_player();
	player anim_single( player, "theyhavetried", "Reznov" );
	player anim_single( player, "donotlet", "Reznov" );
}

trench_mg42_overrun()
{
//	level.scr_sound["Reznov"]["diefascistrats"] = "vox_ful1_s03_333A_rezn"; //Die! You fascist rats!!

	self waittill( "trigger" );
	
	player = get_player();
	player anim_single( player, "diefascistrats", "Reznov" );
}

setup_banzai_triggers()
{
	trigs = getentarray( "banzai_trigger", "targetname" );
	for( i=0; i<trigs.size; i++ )
	{
		trigs[i] thread banzai_thread();
	}
}

nazibase_outrocinema()
{
//	level.scr_sound["Reznov"]["friedrichsteiner"] = "vox_ful1_s03_344A_rezn"; //Friedrich Steiner...

    // Locating Steiner at end of base

	fa_print( "playing nazibase outro cinema" );

	//TUEY set music state to STIENER
	setmusicstate ("STIENER");

	struct = getstruct( "nazibase_outro_centerpoint", "targetname" );
	assert( isdefined(struct) );
	level notify("start_steinercin_end");
	// setup the guys in place, ready for animation
	steiner = level.steiner_nazibase;
	steiner.ignoreall = true;
	struct thread anim_first_frame( steiner, "steinercin", undefined, "steiner" );

	plyr = get_player();
	battlechatter_off();
	
	enemies = GetAISpeciesArray( "axis", "all" );
	for(i = 0; i < enemies.size; i ++)
	{
		if(enemies[i].targetname != "nazibase_outro_deadguy_ai")
			enemies[i] delete();
	}

	plyr fa_show_hud( false ); // the reznov cutscene will turn it back on for us
	
	//door = getent( "steiner_room_door", "targetname" );d
	//door rotateto( (0,90,0), 0.5 );
	
	current_weapon = plyr getCurrentWeapon();
	if( current_weapon == "tokarevtt30_sp" || current_weapon == "waltherp38_sp" || current_weapon == "panzerschreck_player_sp" )
		current_weapon = "ppsh_sp";
	level.nazibase_outro_weapon_model = GetWeaponModel( current_weapon );

	plyr fa_take_weapons();

	struct thread play_player_anim( struct, "steinercin", "playerhands", undefined, true, undefined, ::outro_hands_callback );
	struct thread anim_single_aligned( steiner, "steinercin", undefined, "steiner" );
	
	wait(1);
	plyr thread anim_single( plyr, "friedrichsteiner", "Reznov" );
	
	anim_length = GetAnimLength( level.scr_anim["steiner"]["steinercin"] );
	
	//SOUND - Shawn J - snow gusts & snapshot notify - calling snapshot early to shut off 2d snow
	clientnotify( "snapshot_flashback_3" );
	
	wait( anim_length - 5.85 ); // so the fadeout/cleanup will start a bit before we're done
	
	//SOUND - Shawn J - snow gusts & snapshot notify
	playsoundatposition("evt_blizzard_gust",(0,0,0));	
	//clientnotify( "snapshot_flashback_3" );
	

	plyr thread anim_single( plyr, "narsteiner1", "Reznov" );

	flag_set( "P2NAZIBASE_OUTRO_FADE" );
	show_friendly_names( 0 );
}

// self will be the player hands model
outro_hands_callback()
{
	fa_print( "outro_hands_callback setting player weapon model!" );
	
	tagname = "tag_weapon";
	
	org = self GetTagOrigin( tagname );
 	weap = spawn( "script_model", org );
 	weap setmodel( level.nazibase_outro_weapon_model );
 	weap.angles = self GetTagAngles( tagname );
 	weap linkto( self, tagname );
}

outro_deadguys( struct )
{
	guy1 = simple_spawn_single( "nazibase_outro_deadguy" );
	guy2 = simple_spawn_single( "nazibase_outro_deadguy" );
	guy3 = simple_spawn_single( "nazibase_outro_deadguy" );
	
	// Don't let them drop weapons (so the player doesn't get a weapon pick-up prompt)
	guy1.dropweapon = false;
	guy2.dropweapon = false;
	guy3.dropweapon = false;
	
	struct thread anim_first_frame( guy1, "steinercin", undefined, "soldier1" );
	struct thread anim_first_frame( guy2, "steinercin", undefined, "soldier2" );
	struct thread anim_first_frame( guy3, "steinercin", undefined, "soldier3" );

	flag_wait( "P2NAZIBASE_EXIT" );
}


// ~~~~~~~~~~~~~~~~~~~~~
// ~~~~~ Surrender Triggers ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~

// hooks a thread on each surrender trigger -- these cause fleeing guys to surrender sometimes
setup_surrender_triggers()
{
	trigs = [];
	trigs = array_combine( trigs,  GetEntArray( "trigger_multiple", "classname" ) );
	trigs = array_combine( trigs,  GetEntArray( "trigger_radius", "classname" ) );
	trigs = array_combine( trigs,  GetEntArray( "trigger_once", "classname" ) );

	for( i=0; i<trigs.size; i++ )
	{
		if( isdefined(trigs[i].script_parameters) && trigs[i].script_parameters == "nazibase_surrender" )
		{
			trigs[i] thread nazibase_surrender_thread();
		}
	}
}

// picks guys near the player, makes them surrender
nazibase_surrender_thread()
{
	self waittill( "trigger" );

	color = self.script_color_axis[0]; // get just the one-character color code
	guys = getaiarray( "axis" );
	p = get_player();
	diminishing_probability = 100.0;

	for( i=0; i<guys.size; i++ )
	{
		if( !isalive(guys[i]) ) // hopefully means we don't get guys who're in last stand
		{
			continue;
		}
		
		if( !( guys[i] ai_can_see_player( p ) ) ) // If you can't see me, don't surrender
		{
			continue;
		}

		guy = guys[i];
		
		if( isdefined(guy.script_forcecolor) && guy.script_forcecolor == color )
		{
			if( distance(guy.origin,p.origin) < 500 && randomint(100) <= diminishing_probability  )
			{
				guy thread guy_surrender_thread( (i%4) + 1 );
				
				if (guy.a.pose == "crouch")
				{
			 		guy thread guy_surrender_thread( randomint(2) + 4 );
		 		}
		 		else
		 		{
			 		guy thread guy_surrender_thread( randomint(3) + 1 );
		 		}

				if( (i > 2) &&( diminishing_probability > 0.25 ) )
				{
					diminishing_probability -= 0.25;
				}
			}
		}
		wait( RandomFloatRange( 0.5, 1.0 ) );
	}
}

setup_retreat_triggers()
{
	trig = getent( "retreat1_trigger", "targetname" );
	trig thread nazibase_retreat1_thread();

	trig = getent( "retreat2_trigger", "targetname" );
	trig thread nazibase_retreat2_thread();
	
	// custom retreat animations
	guy1 = simple_spawn_single( "retreating_guy_01" );
	guy2 = simple_spawn_single( "retreating_guy_02" );
	guy1.animname = "generic";
	guy2.animname = "generic";

	// Put these guys in position and make them invulnerable until time to retreat
	ref_node = getstruct( "custom_retreating_guys1_ref", "targetname" );

	ref_node thread anim_first_frame( guy1, "retreating_guy01" );
		
	trig = getent( "p2nazibase_intro_fight_trigger", "targetname" );
	trig thread custom_retreating_guys1_thread( guy1, 1 );
	trig thread custom_retreating_guys1_thread( guy2, 2 );
	
	// Set up snow drift death threads
	trig = getent( "snow_drift_death_1_trigger", "targetname" );
	trig thread snow_drift_death( 1 );
	
	trig = getent( "snow_drift_death_2_trigger", "targetname" );
	trig thread snow_drift_death( 2 );
	
	trig = getent( "snow_drift_death_3_trigger", "targetname" );
	trig thread snow_drift_death( 3 );
}

custom_execution_thread()
{
	// Wait until the Launch building search is complete and the player is coming back down the stairs
	flag_wait( "P2NAZIBASE_FIRSTBUILDING_HOLDOUTS_CLEAR" );
	trigger_wait( "firstbuilding_holdout_spawntrig", "targetname" );

	level thread custom_execution_germ_thread();
	level thread custom_execution_russ_thread();
}

custom_execution_germ_thread()
{
	guy = simple_spawn_single( "wounded_germ_spawn" );
	guy.animname = "generic";
	guy.ignoreme = true;

	ref_node = getstruct( "germans_wounded_ref", "targetname" );
	
	ref_node anim_teleport( guy, "germans_wounded_germ" );
	ref_node anim_single_aligned( guy, "germans_wounded_germ" );
	
	guy ragdoll_death();
}

custom_execution_russ_thread()
{
	guy = simple_spawn_single( "wounded_russ_spawn" );
	guy.animname = "generic";

	ref_node = getstruct( "germans_wounded_ref", "targetname" );
	
	ref_node anim_teleport( guy, "germans_wounded_russ" );
	ref_node anim_single_aligned( guy, "germans_wounded_russ" );
	
	node = getnode( "dest_russian_1", "targetname" );
	guy thread force_goal( node, 4, false );
}


nazibase_retreat1_thread()
{
	self waittill( "trigger" );

	//level thread fuel_area_dialog();
	
	for( i=1; i<=5; i++)
	{
		guyname = "retreat_nazi_" + i;
		guy = simple_spawn_single( guyname );
		if( isdefined( guy ) )
		{
			guy thread nazibase_retreat_guy_thread( i );
		}
	}
	
	wait( 10 );
	
	// Advance the allies to the next line
	trig = getent( "advance_to_launch_bldg_trig", "targetname" );
	if( isDefined( trig ) )
	{
		trig useby( get_player() );
	}
}

nazibase_retreat2_thread()
{
	self waittill( "trigger" );

	guy10 = simple_spawn_single( "retreat_nazi_10" );
	node = getnode( "retreat_cover_10", "targetname" );
 	guy10 thread force_goal( node, 4, false );


	guy11 = simple_spawn_single( "retreat_nazi_11" );
	node = getnode( "retreat_cover_11", "targetname" );
 	guy11 thread force_goal( node, 4, false );


	guy12 = simple_spawn_single( "retreat_nazi_12" );
	node = getnode( "retreat_cover_12", "targetname" );
 	guy12 thread force_goal( node, 4, false );

 	trigger_wait( "trench_surrender_trig" );

  	if( isalive( guy11 ) )
 	{
		if (guy11.a.pose == "crouch")
		{
	 		guy11 thread guy_surrender_thread( randomint(2) + 4 );
 		}
 		else
 		{
	 		guy11 thread guy_surrender_thread( randomint(3) + 1 );
 		}
	}
}

nazibase_retreat_guy_thread( i )
{
	self endon( "death" );
	
	self disable_ai_color();
	initnodename = "init_retreat_" + i;
	node = getnode( initnodename, "targetname" );
	if( isdefined( node ) )
	{
 		force_goal( node, 16, true );
	}

	self waittill("goal");
	retreatnodename = "retreat_cover_" + i;
	node = getnode( retreatnodename, "targetname" );
	if( isdefined( node ) )
	{
		shoot = false;
		if( i%2 == 0 )
		{
			shoot = true;
		}
 		force_goal( node, 16, shoot );
	}
	
	if( isdefined( node.script_noteworthy ) )
	{
		if( node.script_noteworthy == "surrender")
		{
			wait( 2 );
			self thread guy_surrender_thread( (i%3) + 1 );
		}
	}
	
	self waittill("goal");
	self enable_ai_color();
}

custom_retreating_guys1_thread( guy, guy_num )
{
	if( isDefined(guy) )
	{
		guy endon( "death" );
		guy.ignoreall = true;
		//guy magic_bullet_shield();
		self waittill( "trigger" );
		
		wait( 5 );
		//guy stop_magic_bullet_shield();
		struct = getstruct( "custom_retreating_guys1_ref", "targetname" );
		anim_name = "retreating_guy0" + guy_num;
	
		if( guy_num == 1 )
		{
			guy.health = 1;
			guy.allowDeath = true;
			struct anim_single_aligned( guy, anim_name );
		}
		else if( guy_num == 2 )
		{
			struct anim_reach_aligned( guy, anim_name );
			guy.health = 1;
			guy.allowDeath = true;
			struct anim_single_aligned( guy, anim_name );
		}
		
		guy startragdoll();
		guy die();
	}
}


snow_drift_death( event_num )
{
	self waittill( "trigger" );
	
	level thread snow_drift_death_guy( event_num, 1 );
	level thread snow_drift_death_guy( event_num, 2 );
	
	if( event_num == 3 ) //  3rd event has three guys in it
	{
		level thread snow_drift_death_guy( event_num, 3 );
	}
}

snow_drift_death_guy( event_num, guy_num )
{	
	anim_name = "snow_drift_death_" + event_num + "_guy" + guy_num;
	guy = simple_spawn_single( anim_name + "spawn" );
	if( isDefined(guy) )
	{
		guy.animname = "generic";
		guy.ignoreall = true;
		guy.allowDeath = true;
		guy.health = 1;

		guy endon( "death" );
		
		struct = getstruct( "snow_drift_death_" + event_num + "_ref", "targetname" );
		struct anim_reach( guy, anim_name );
		struct anim_single_aligned( guy, anim_name );
		
		guy startragdoll();
		guy die();
	}
}


// ~~~~~~~~~~~~~~~~~~~~~
// ~~~~~ Mortar stuff ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~

// loops through a series of structs, playing mortar explosions on them with a random delay in-between
// self should be level
nazibase_mortarcycle( stopstring, struct_targetnames )
{
	level endon( stopstring );

	mortar_structs = getstructarray( struct_targetnames, "targetname" );

	i = 0;
	while(true)
	{
		if( i >= mortar_structs.size )
		{
			i = 0;
		}

		wait( 1 + randomfloat(3) );
		// If the player is too close - don't asplode here.
		dist = distance( get_player().origin, mortar_structs[i].origin );
		kill_radius = 256;
		if( dist > (3 * kill_radius) )
		{
			mortar_structs[i] maps\_mortar::activate_mortar( kill_radius, 400, 165, undefined, undefined, undefined, true);
		}
		i++;
	}
}

// self should be level
nazibase_stopmortar1_checkpoint()
{
	trigger_wait( "p2nazibase_stopmortar1_checkpoint", "targetname" );
	level notify( "stop_mortarcycle_1" );
	autosave_by_name( "fullahead" );

	mortar_sniper_cleanup();

//	level thread nazibase_mortarcycle( "stop_mortarcycle_2", "mortar2_point" );
//	level thread nazibase_stopmortar2();
}

// self should be level
nazibase_stopmortar2()
{
	trigger_wait( "p2nazibase_stopmortar2", "targetname" );
	level notify( "stop_mortarcycle_2" );
}



// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~ Used to auto-progress the fight when spawners run out ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

setup_sm_progresstriggers()
{
	// should be an array of script_origins
	ents = getentarray( "sm_progresstriggers", "targetname" );
	for( i=0; i<ents.size; i++ )
	{
		assertex( isdefined(ents[i].target), "sm_progresstrigger at " + ents[i].origin[0] + ", " + ents[i].origin[1] + " is missing target!" );
		assertex( isdefined(ents[i].script_parameters), "sm_progresstrigger at " + ents[i].origin[0] + ", " + ents[i].origin[1] + " is missing script_parameters!" );

		ents[i] thread sm_progresstrigger_thread( ents[i].target, ents[i].script_parameters );
	}
}

sm_progresstrigger_thread( sm_targetname, group, flagname )
{
	self waittill_spawn_manager_ai_remaining( sm_targetname, 3 );

	if( !is_spawn_manager_complete(sm_targetname) ) // did it get killed instead of completing?
	{
		fa_print( "sm_progresstrigger_thread aborting, spawn manager was killed" );
		return; // do nothing, player is pushing ahead
	}

	if( isdefined(flagname) )
	{
		flag_wait( flagname );
	}

	// otherwise, start activating our specified triggers in sequence
	triggers_in_sequence( group );

}

triggers_in_sequence( group )
{
	p = get_player();

	i=1;
	trig = getent( group + "_" + i, "script_noteworthy" );
	while( isdefined(trig) || i < 12 )
	{
		if( isdefined(trig) )
		{
			fa_print( "sm_progresstrigger_thread using " + trig.script_noteworthy );
			trig useby( p );

			wait(1);
		}

		i++;
		trig = getent( group + "_" + i, "script_noteworthy" );
	}
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~ Prints error if AI has falling through the ground ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// self should be level
ai_sanity_check()
{
	level endon( "P2NAZIBASE_EXIT" );

	while( true )
	{
		ai = getaiarray( "axis", "allies", "neutral" );
		for( i=0; i<ai.size; i++ )
		{
			if( ai[i].origin[2] < -2500 )
			{
				fa_print( "ERROR: AI below world!" );
				fa_print( "      - targetname: " + ai[i].targetname );
				fa_print( "      - position: " + ai[i].origin );

			}
		}

		wait(0.5);
	}
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~ Weather Devices ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

setup_weather_devices()
{
	level thread weather_rotate_thread();
	level thread anemometer_thread();
}

setup_barricade()
{
	hide_smoke_grenades();
	
	gate_long_barricade1a = GetEnt("gate_long_barricade1a", "targetname");
	gate_long_barricade2a = GetEnt("gate_long_barricade2a", "targetname");
	gate_long_barricade1b = GetEnt("gate_long_barricade1b", "targetname");
	gate_long_barricade2b = GetEnt("gate_long_barricade2b", "targetname");
	
	gate_long_barricade1a Show();
	gate_long_barricade2a Show();
	gate_long_barricade1b Hide();
	gate_long_barricade2b Hide();
}

// stolen from WMD
weather_rotate_thread()
{
	level endon("P2NAZIBASE_EXIT");

	spinner = getentarray("weather_meter_spinner", "targetname");
	while (1)
	{
		for(i=0; i<spinner.size; i++)
		{
			spinner[i] rotateyaw(-180, 0.5);
		}
		wait(0.5);
	}
}

// also stolen from WMD
anemometer_thread()
{
	level endon("P2NAZIBASE_EXIT");

	meter = getentarray( "weather_meter_pointer", "targetname" );

	while( 1 )
	{
		for(i=0; i < meter.size; i++)
		{
			time = RandomFloatRange( 0.5, 2.0 );

			if( meter[i].angles[1] > 0 )
			{
				meter[i] rotateyaw( -15, time );
			}
			else
			{
				meter[i] rotateyaw( 15, time );
			}

		}

		wait(0.25);
	}
}

weather_device_cleanup()
{
	spinner = getentarray("weather_meter_spinner", "targetname");

	for(i=0; i<spinner.size; i++)
	{
		spinner[i] delete();
	}

	meter2 = getentarray( "weather_meter_pointer", "targetname" );
	for(i=0; i < meter2.size; i++)
	{
		meter2[i] delete();
	}
}

ai_can_see_player( player ) //self = ai
{
	if( !isAlive(self) )
	{
		return( false );
	}
	
	success = BulletTracePassed(self GetTagOrigin( "tag_eye" ) , player get_eye() , false, self );
	return success;	
}

goto_turret( turret, turret_node )
{
	self endon("death");
	self endon("bad_path");	
	
	//make sure he gets close enough to make the warping less noticable when he uses the turret
	get_there(turret_node);
	self waittill("goal");
	self.ignoresuppression = 1;
	self.ignoreall = 0;
	
//	if(isDefined(turret))
//	{
		//use the turret
//		self maps\_spawner::use_a_turret(turret);
//	}
	
	while( isDefined(turret) )
	{
		self useTurret( turret );
		aim_struct = getstruct( "mg42_1_target_1", "targetname" );
//		self AimAtPos( aim_struct.origin );
		self shoot( 0.5, aim_struct.origin - self.origin );
		wait( 3 );
	}
}

// self is the mg42 turret
man_mg42( turret_node, gunner_spawner, kill_flag )
{	
	max_gunners = 4;
	num_gunners = 0;
	while( (num_gunners < max_gunners) && !flag( kill_flag ) )
	{
		guy = simple_spawn_single( gunner_spawner );
		wait(0.1);
		if( isDefined( guy ) )
		{
			num_gunners++;
			guy force_goal( turret_node );
		 	guy waittill( "goal" );
			guy useTurret( self );
			player = get_player();			
			self SetTargetEntity( player );
			self setturretignoregoals(true);
			guy thread maps\_mgturret::burst_fire( self );
		 	
			while( isalive( guy ) )
			{
				guy useTurret( self );
				self setturretignoregoals(true);
				wait(10);
			}
			wait( randomFloatRange( 3.0, 4.0 ) );
		}
	}
}

set_flag_when_triggered( strTrig, strFlag )
{
	if( !level.flag[ strFlag ] )
	{
		trigger_wait( strTrig, "targetname" );
		flag_set( strFlag ); 
	}
}

setup_mg42()	// self = mg42
{
	self.script_delay_min	= 2;
	self.script_delay_max	= 5;
	self.script_burst_min	= 3;
	self.script_burst_max	= 5;
	
	//lower the mg after barricade per JB -jc
	if( self.targetname == "mg_turret_2" )
	{
		self.accuracy = .02;	//default is .38
	}
	
}