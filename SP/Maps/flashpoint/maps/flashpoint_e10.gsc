////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL SCRIPTS
// PJL 04/21/10
//
// Script for event 10 - this covers the following scenes from the design:
//		Slides 59-66
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;
#include maps\flashpoint_util;


////////////////////////////////////////////////////////////////////////////////////////////
// EVENT10 FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////
// 
// weaver_anims( anim_node )
// {
// 	weaver_mask_ent = getent( "weaver_mask", "targetname" );
// 	weaver_mask_ent.animname = "weavergasmask";
// 	weaver_mask_ent useAnimTree( level.scr_animtree[ "weavergasmask" ] ); 
// 	weaver_mask_ent Show();
// 	
// 	anim_node thread anim_single_aligned( self, "gastrap_A" );
// 	anim_node thread anim_single_aligned( weaver_mask_ent, "gastrap_A" );
// 	anim_node waittill("gastrap_A");
// 	
// 	//-- replace weaver's head with the gasmask one
// 	self.oldheadmodel = self.headmodel;
//  	self Detach(self.headmodel, "");
//  	self.headmodel = "c_usa_blackops_weaver_disguise_headm";
//  	self Attach(self.headmodel, "", true);
//  	
// 	anim_node thread anim_loop_aligned( self, "gastrap_idle_A" );
// 	//anim_node thread anim_loop_aligned( weaver_mask_ent, "gastrap_idle_A" );
// 	flag_wait( "PLAYER_MOVES_FWD" );
// 	
// 	anim_node thread anim_single_aligned( self, "gastrap_B" );
// 	//anim_node thread anim_single_aligned( weaver_mask_ent, "gastrap_B" );
// 	anim_node waittill("gastrap_B");
// 	anim_node thread anim_loop_aligned( self, "gastrap_idle_B" );
// 	//anim_node thread anim_loop_aligned( weaver_mask_ent, "gastrap_idle_B" );
// 	flag_wait( "PLAYER_THROUGH_WND" );
// 	
// 	anim_node thread anim_single_aligned( self, "gastrap_mantle" );
// 	//anim_node thread anim_single_aligned( weaver_mask_ent, "gastrap_mantle" );
// 	anim_node waittill("gastrap_mantle");
// }
// 
// weaver_vomit_anims( anim_node )
// {	
// 	//-- replace weaver's head with the bandaged one
// 	self Detach(self.headmodel, "");
// 	self.headmodel = self.oldheadmodel;
// 	self Attach(self.headmodel, "", true);
// 	
// 	weaver_mask_ent = getent( "weaver_mask", "targetname" );
// 	weaver_mask_ent.animname = "weavergasmask";
// 	weaver_mask_ent useAnimTree( level.scr_animtree[ "weavergasmask" ] ); 
// 	weaver_mask_ent Show();
// 
// 	anim_node thread anim_single_aligned( self, "vomit" );
// 	anim_node thread anim_single_aligned( weaver_mask_ent, "vomit" );
// 	anim_node waittill("vomit");
// }
// 
// woods_anims( anim_node )
// {
// 	woods_mask_ent = getent( "woods_mask", "targetname" );
// 	woods_mask_ent.animname = "woodsgasmask";
// 	woods_mask_ent useAnimTree( level.scr_animtree[ "woodsgasmask" ] ); 
// 	woods_mask_ent Show();
// 	
// 	anim_node thread anim_single_aligned( self, "gastrap_A_woods" );
// 	anim_node thread anim_single_aligned( woods_mask_ent, "gastrap_A_woods" );
// 	anim_node waittill("gastrap_A_woods");
// 		
//  	//-- replace woods's head with the gasmask one
// 	self.oldheadmodel = self.headmodel;
//  	self Detach(self.headmodel, "");
//  	self.headmodel = "c_usa_jungmar_barnes_disguise_headm";
//  	self Attach(self.headmodel, "", true);
//  	woods_mask_ent Hide();
// 
// 	anim_node thread anim_loop_aligned( self, "gastrap_idle_A_woods" );
// 	//anim_node thread anim_loop_aligned( woods_mask_ent, "gastrap_idle_A_woods" );
// 	flag_wait( "PLAYER_MOVES_FWD" );
// 	
// 	anim_node thread anim_single_aligned( self, "gastrap_B_woods" );
// 	//anim_node thread anim_single_aligned( woods_mask_ent, "gastrap_B_woods" );
// 	anim_node waittill("gastrap_B_woods");
// 	flag_set( "WOODS_AT_WND" );
// 	anim_node thread anim_loop_aligned( self, "gastrap_idle_B_woods" );
// 	//anim_node thread anim_loop_aligned( woods_mask_ent, "gastrap_idle_B_woods" );
// 	flag_wait( "PLAYER_THROUGH_WND" );
// 	
// 	self thread playVO_proper( "seeshit" ); //Can't see shit... Bastards think they got the advantage... Let's prove 'em wrong.
// 	
// 	anim_node thread anim_single_aligned( self, "gastrap_mantle_woods" );
// 	//anim_node thread anim_single_aligned( woods_mask_ent, "gastrap_mantle_woods" );
// 	anim_node waittill("gastrap_mantle_woods");
// }
// 
// woods_vomit_anims( anim_node )
// {	
// 	//self Detach( "anim_rus_gasmask", "tag_head" );
// 	
// 	//-- replace weaver's head with the bandaged one
// 	self Detach(self.headmodel, "");
// 	self.headmodel = self.oldheadmodel;
// 	self Attach(self.headmodel, "", true);
// 	
// 	woods_mask_ent = getent( "woods_mask", "targetname" );
// 	woods_mask_ent.animname = "woodsgasmask";
// 	woods_mask_ent useAnimTree( level.scr_animtree[ "woodsgasmask" ] ); 
// 	woods_mask_ent Show();
// 	
// 	anim_node thread anim_single_aligned( self, "vomit_woods" );
// 	anim_node thread anim_single_aligned( woods_mask_ent, "vomit_woods" );
// 	anim_node waittill("vomit_woods");
// }
// 
// player_gasmask_anim( anim_node, anim_name )
// {
// 	player_mask_ent = getent( "player_mask", "targetname" );
// 	player_mask_ent.animname = "playergasmask";
// 	player_mask_ent useAnimTree( level.scr_animtree[ "playergasmask" ] );
// 	player_mask_ent Show(); 
// 	anim_node thread anim_single_aligned( player_mask_ent, anim_name );
// 	//anim_node waittill( anim_name );
// 	
// 	level waittill( "gastrap_mask_off" );
// 	level.player maps\_gasmask::gasmask_put_on();
// 	level notify("set_tunnels_gas_on_fog");
// 	player_mask_ent Hide();
// }
// 
// // weaver_gasmask_anim( anim_node, anim_name )
// // {
// // 	weaver_mask_ent = getent( "weaver_mask", "targetname" );
// // 	weaver_mask_ent.animname = "weavergasmask";
// // 	weaver_mask_ent useAnimTree( level.scr_animtree[ "weavergasmask" ] ); 
// // 	weaver_mask_ent Show();
// // 	anim_node thread anim_single_aligned( weaver_mask_ent, anim_name );
// // 	anim_node waittill( anim_name );
// // 	weaver_mask_ent Hide();
// // }
// 
// // woods_gasmask_anim( anim_node, anim_name )
// // {
// // 	woods_mask_ent = getent( "woods_mask", "targetname" );
// // 	woods_mask_ent.animname = "woodsgasmask";
// // 	woods_mask_ent useAnimTree( level.scr_animtree[ "woodsgasmask" ] ); 
// // 	woods_mask_ent Show();
// // 	anim_node thread anim_single_aligned( woods_mask_ent, anim_name );
// // 	anim_node waittill( anim_name );
// // 	woods_mask_ent Hide();
// // }
// 
// 	
// #using_animtree("flashpoint");
// player_anims( anim_node )
// {
// 	self Hide();
// 	self DisableWeapons();
// 	self FreezeControls( true );
// 	self SetLowReady(true);
// 	self AllowJump(false);
// 	self AllowSprint( false );
// 	self AllowMelee( false );
// 
// 	//spawn the player body
// 	self.body = spawn_anim_model( "player_body", anim_node.origin );
// 	
// 	//self StartCameraTween(.2);
// 	self PlayerLinktoAbsolute(self.body, "tag_player");
// 	self thread player_gasmask_anim( anim_node, "gastrap" );
// 	anim_node thread anim_single_aligned( self.body, "gastrap" );
// 	anim_node waittill("gastrap");
// 	
// 	flag_set( "PLAYER_MOVES_FWD" );
// 	
// 	//GAS ON
// 	//level notify("set_tunnels_gas_on_fog");
// 	//level.player maps\_gasmask::gasmask_put_on();
// 	
// //	level notify( "gastrap_mask_off" );
// 	
// 	exploder( 400 );
// 	
// 	self Unlink();
// 	self.body Unlink();
// 	self.body Delete();
// 	
// 	self Show();
// 	self thread waitThenGiveControlToPlayer( 0.5 );
// 	
// 	flag_wait( "WOODS_AT_WND" );
// 	
// 	self SetLowReady( false );
// 	self AllowJump( true );
// 	self AllowSprint( true );
// 	self AllowMelee( true );
// 	Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_ENTER_WINDOW", (-12098.2, -1665.85, -71.0813) );
// 	Objective_Set3D( level.obj_num, true, "default", "Enter" );
// 	level.glow_window show();
// }
// 
// player_vomit_anims( anim_node )
// {
// 	self Hide();
// 	self DisableWeapons();
// 	self FreezeControls( true );
// 	self SetLowReady(true);
// 	self AllowSprint( false );
// 	self AllowMelee( false );
// 
// 	//spawn the player body
// 	self.body = spawn_anim_model( "player_body", anim_node.origin );
// 
// 	
// 	//self StartCameraTween(.2);
// 	self PlayerLinktoAbsolute(self.body, "tag_player");
// 	self thread player_gasmask_anim( anim_node, "vomit_player" );
// 	anim_node thread anim_single_aligned( self.body, "vomit_player" );
// 	anim_node waittill("vomit_player");
// 	
// 	//GAS ON
// // 	level notify("set_tunnels_gas_on_fog");
// // 	level.player maps\_gasmask::gasmask_put_on();
// // 	exploder( 400 );
// 	
// 	self Unlink();
// 	self.body Unlink();
// 	self.body Delete();
// 	
// 	self Show();
// 	self thread waitThenGiveControlToPlayer( 0.5 );
// 	
// // 	flag_wait( "WOODS_AT_WND" );
// // 	
//  	self SetLowReady( false );
//  	self AllowSprint( true );
//  	self AllowMelee( true );
// // 	Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_ENTER_WINDOW", (-12098.2, -1665.85, -71.0813) );
// // 	Objective_Set3D( level.obj_num, true, "default", "Enter" );
// }
// 
// 
// dragons_breath_shotgun_behavior()
// {
// 	//Give him a dragons breath shotgun
// 	self.rusher = true;
// 	self.weapon = "spas_db_sp";
// 	self set_drop_weapon( "spas_sog_sp" );
// 	//self.bulletsInClip = 1;
// }
// 
// event_dialog()
// {
// 	level.woods thread playVO_proper( "holdit", 3.0 ); //Hold it...
// 	level.weaver thread playVO_proper( "teargas", 5.0 ); //Tear gas!!!
// 	level.woods thread playVO_proper( "maskon", 7.0 ); //Get you mask on! Go, go, go!
//     
// 	start_battle_trig = getent( "start_battle", "targetname" );
// 	start_battle_trig waittill( "trigger" );
// 	
// 	level.woods thread playVO_proper( "rushus", 1.0 ); //They are tryin' to rush us!!!
// 	level.woods thread playVO_proper( "openup", 3.0 ); //Open up!!!
// 	
// 	level.woods thread playVO_proper( "dammit", 7.0 ); //Dammit!!!
// 	
// 	level.woods thread playVO_proper( "moreofem", 15.0 ); //More of 'em!
// 	level.woods thread playVO_proper( "diesob", 20.0 ); //Die you son of a bitch!
// }
// 
// delayDestroy( duration )
// {
// 	wait duration;
// 	self destroy();
// }
// 
// show_final_time( final_time )
// {
// 	heading = "Clear";
// 	textscale = 1.0;
// 	
// 	final_time_sec = final_time / 1000.0;
// 	
// 	
// 	minutes = int(final_time_sec  / 60);
// 	seconds = int(final_time_sec ) % 60;
// 	
// 	
// 	
// 
// 	temp = newHudElem();
// 	temp setText( "Total Time = " + minutes + ":" + seconds );
// 	temp.horzAlign = "center";
// 	temp.vertAlign = "top";
// 	temp.alignX = "center";
// 	temp.alignY = "middle";
// 	temp.x = 0;
// 	temp.y = 200;
// 	temp.font = "small";
// 	temp.fontScale = textscale;
// 	temp.sort = 2;
// 	temp.glowColor = ( 0.3, 0.6, 0.3 );
// 	temp.glowAlpha = 1;
// 
// 	temp thread delayDestroy( 16.5 );
// 	temp moveOverTime( 6.5 );
// 	temp.y = 0;
// }
// 
// gas_room_timer()
// {
// 	flag_wait( "PLAYER_THROUGH_WND" );
// 	autosave_by_name("flashpoint_e10b");
// 	
// 	start_time = GetTime();
// 	gasRoomTimerElem = NewHudElem();
// 	gasRoomTimerElem.hidewheninmenu = true;
// 	gasRoomTimerElem.horzAlign = "center";
// 	gasRoomTimerElem.vertAlign = "top";
// 	gasRoomTimerElem.alignX = "center";
// 	gasRoomTimerElem.alignY = "middle";
// 	gasRoomTimerElem.x = 0;
// 	gasRoomTimerElem.y = 0;
// 	gasRoomTimerElem.foreground = true;
// 	gasRoomTimerElem.font = "default";
// 	gasRoomTimerElem.fontScale = 1.0;
// 	gasRoomTimerElem.color = ( 1.0, 1.0, 1.0 );        
// 	gasRoomTimerElem.alpha = 1.0;
// 	
// 	gasRoomTimerElem.sort = 2;
// 	gasRoomTimerElem.glowColor = ( 0.3, 0.6, 0.3 );
// 	gasRoomTimerElem.glowAlpha = 1;
// 	
// 	gasRoomTimerElem SetTimerUp( 0 );
// 	
// 	flag_wait( "PLAYER_EXIT_GAS_ROOM" );
// 	gasRoomTimerElem Destroy();
// 	end_time = GetTime();
// 	final_time = end_time - start_time;
// 	
// 	self thread show_final_time( final_time );
// }
// 
// 
// //shows screen message until player switched to dragons_breath
// player_switch_dragons_breath()
// {
// 	level endon( "dragons_breath_selected" );
// 	level endon( "PLAYER_EXIT_GAS_ROOM" ); 
// 	
// 	while(1)
// 	{
// 		if( level.player GetCurrentWeapon() == "spas_sog_sp" )
// 		{
// 			//we picked up the spas - now show the dragons breath message
// 			break;
// 		}
// 		wait(0.1);
// 	}
// 	
// 	
// 	screen_message_create(&"FLASHPOINT_SPAS_SWITCH");
// 	level.dragonsbreath_bolts_msg = 1;
// 
// 	//now wait until player presses this button or the first encounter is done
// 	while(1)
// 	{
// 		//Keep checking to see if the player switched to explosive bolts
// 		if( level.player GetCurrentWeapon() == "spas_db_sp" )
// 		{
// 			screen_message_delete();
// 			level.dragonsbreath_bolts_msg = 0;
// 			level notify( "dragons_breath_selected" );
// 			break;		
// 		}
// 		wait(0.1);
// 	}
// }
// 
// /*
// 
// gasroom_dooropen( anim_node )
// {
// 		anim_node = get_anim_struct( "9" );
// 	comms_door_ent = getent( "comms_door", "targetname" );
// 	comms_door_ent.animname = "door";
// 	comms_door_ent useAnimTree( #animtree ); 
// 	
// 	anim_node thread anim_loop_aligned( comms_door_ent, "comms_start" );
// 	
// 	anim_node thread anim_single_aligned( comms_left door_ent, "comms_open" );
// 	//anim_node waittill( "comms_open" );
// 
// }
// */
// 
// #using_animtree("animated_props");
// door_open_anim( anim_node )
// {
// 	self useAnimTree( #animtree ); 
// 	
// 	level waittill( "gastrap_door_kick" );
// 	anim_node thread anim_single_aligned( self, "open" );
// }
// vomit_door_open_anim( anim_node )
// {
// 	self useAnimTree( #animtree ); 
// 	anim_node thread anim_single_aligned( self, "open" );
// }
// 
// 
// wait_for_window_to_be_broken()
// {
// 	level endon( "PLAYER_THROUGH_WND" );
// 
// 	while( 1 )
// 	{
// 		//Wait for glass smash
// 		level waittill( "glass_smash", origin );
// 		
// 		//make sure its close to the window we want to break!
// 		if(DistanceSquared(level.glow_window.origin, origin) < (256*256))
// 		{
// 			level.glow_window hide();
// 		}
// 	}
// }
// 
// 
// event10_TearGasRoom()
// {
// /*
//  As the Player enters, 3 tear gas shells are fired into the room through the doorway highlighted in 
//  red – this door is then slammed shut, there are no Spetznaz in this room
//  Player must don his gas mask – ART NOTE: the gas mask needs to be a 3d model rather than a 2d overlay
//  EFFECTS NOTE: Get Michael Barnes to concept an animatic of all these gas mask slides
//  Door is locked shut, squad (or Player) must shoot through the window highlighted in white to progress
//  NOTE: Player’s view in next few rooms is severely compromised due to clouds of dense white gas (will 
//  need to do more “thunk thunk” grenades if necessary in subsequent rooms)
// */
// 
// 	autosave_by_name("flashpoint_e10");
// 	
// 	dragons_breath_shotgun_spawners = GetEntArray("dragons_breath_shotgun", "script_noteworthy" );
// 	array_thread( dragons_breath_shotgun_spawners, ::add_spawn_function, ::dragons_breath_shotgun_behavior );
// 	
// 	level.player thread gas_room_timer();
// 	level.player thread player_switch_dragons_breath();
// 	
// 	Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_ENTER_DOOR", (-12802.0, -1065.72, -77.7034) );
// 	Objective_Set3D( level.obj_num, true, "default", "Enter" );
// 
// 	//Open door trigger and the doors to open
// 	gas_start_door_trig = getent( "gas_start_door_trig", "targetname" );
// 	gas_start_door_r = getent( "gas_start_door_r", "targetname" );
// 	gas_start_door_l = getent( "gas_start_door_l", "targetname" );
// 	gas_start_door_l.animname = "gasdoorleft";
// 	gas_start_door_r.animname = "gasdoorright";
// 	gas_start_door_trig sethintstring("Press X to Open the door");
// 	gas_start_door_trig waittill( "trigger" );
// 	gas_start_door_trig Delete();
// 	
// 	battlechatter_off( "axis" );
// 	
// 	anim_node = get_anim_struct( "20" );
// 	gas_start_door_r thread door_open_anim( anim_node );
// 	gas_start_door_l thread door_open_anim( anim_node );
// 	start_gas_door_blocker = getent( "start_gas_door_blocker", "targetname" );
// 	start_gas_door_blocker NotSolid();
// 	
// //	level notify( "gastrap_door_kick" );
// 	
// 	Objective_State( level.obj_num, "done" );
// 	Objective_Set3D( level.obj_num, false );
// 	
// 	
// 	level.player thread event_dialog();
// 	
// 	//Sync node "20"	
// 	//anim_node anim_reach_aligned( self, "weaver_breach" );
// 	
// 	level.weaver thread weaver_anims( anim_node );
// 	level.woods thread woods_anims( anim_node );
// 	level.player thread player_anims( anim_node );
// 
// 	//start_gas_trig = getent( "start_gas", "targetname" );
// 	//start_gas_trig waittill( "trigger" );
// 	flag_set( "PLAYER_MOVES_FWD" );
// 	
// // 	//GAS ON
// // 	level notify("set_tunnels_gas_on_fog");
// // 	level.player maps\_gasmask::gasmask_put_on();
// // 	exploder( 400 );
// 
// 	//Wait for glass smash
// 	level thread wait_for_window_to_be_broken();
// 
// 	start_gas_player_mantle_trig = getent( "start_gas_player_mantle", "targetname" );
// 	start_gas_player_mantle_trig waittill( "trigger" );
// 	flag_set( "PLAYER_THROUGH_WND" );
// 	
// 	//level.glow_window hide();
// 	
// 	
// 	Objective_Add( level.obj_num, "current", &"FLASHPOINT_OBJ_EXIT_GASROOMS", (-10400.5, -3108.68, -78.9305) );
// 	Objective_Set3D( level.obj_num, true, "default", "Exit" );
// 	
// 	
// 	//autosave_by_name("flashpoint_e10b");
// 	
// 	level.woods enable_cqbwalk();
// 	level.weaver enable_cqbwalk();
// 	
// 	event10_DenseTearGasFadeAway();
// }
// 
// event10_DenseTearGasFadeAway()
// {
// /*
//  The gas has almost faded away now, and we have a brief moment of respite as the squad regroups
//  However, the cocktail combo of tear gas and excruciating eye pain is too much for Weaver – he vomits 
//  all over the floor – he then makes up for it by saying something cool to show he can continue on without assistance
//  The squad heads up the stairs
// */
// 
// 	//Open door trigger and the doors to open
// 	gas_end_door_trig = getent( "gas_end_door_trig", "targetname" );
// 	gas_end_door_r = getent( "gas_end_door_r", "targetname" );
// 	gas_end_door_l = getent( "gas_end_door_l", "targetname" );
// 	gas_end_door_l.animname = "vomitdoorleft";
// 	gas_end_door_r.animname = "vomitdoorright";
// 	gas_end_door_trig sethintstring("Press X to Open the door");
// 	gas_end_door_trig waittill( "trigger" );
// 	gas_end_door_trig Delete();
// 	
// 	flag_set( "PLAYER_EXIT_GAS_ROOM" );
// 	
// 	
// 	if( isdefined(level.dragonsbreath_bolts_msg) && (level.dragonsbreath_bolts_msg==1) )
// 	{
// 		screen_message_delete();
// 		level.dragonsbreath_bolts_msg = 0;
// 	}	
// 	
// 	battlechatter_on( "axis" );
// 	
// 	//Clean up all enemies
// 	ai_array = GetAIArray( "axis" );
// 	for(i = ai_array.size - 1; i >= 0; i-- )
// 	{
// 		ai_array[i] Delete();
// 	}
// 	
// 	anim_node = get_anim_struct( "23" );
// 	level.weaver thread weaver_vomit_anims( anim_node );
// 	level.woods thread woods_vomit_anims( anim_node );
// 	level.player thread player_vomit_anims( anim_node );
// 
// 	
// 	Objective_State( level.obj_num, "done" );
// 	Objective_Set3D( level.obj_num, false );
// 	gas_end_door_r thread vomit_door_open_anim( anim_node );
// 	gas_end_door_l thread vomit_door_open_anim( anim_node );
// 	
// 	end_gas_door_blocker = getent( "end_gas_door_blocker", "targetname" );
// 	end_gas_door_blocker NotSolid();
// 
// 	//stop_gas_trig = getent( "stop_gas", "targetname" );
// 	//stop_gas_trig waittill( "trigger" );
// 	
// 	//GAS OFF
// 	level notify("set_tunnels_gas_off_fog");
// 	level.player maps\_gasmask::gasmask_remove();
// 	
// 	level.woods disable_cqbwalk();
// 	level.weaver disable_cqbwalk();
// 	
// 	wait( 7.0 );
// 	
// //TILL I GET JUMP WORKING
// // 	level.player FreezeControls( true );
//  //	level thread gameover_screen();
//  	
//  	// end the level
// //	nextmission();
// 	
// 	
// 	
// 	//Need a wait to make sure that the gas mask if full off before we proceed
// // 	next_event_after_gas_trig = getent( "next_event_after_gas", "targetname" );
// // 	next_event_after_gas_trig waittill( "trigger" );
// 
// 	level.player FreezeControls(true);
// 	level thread fade_in_black( 2, 2, true, true );
// 	
// 	wait( 2.0 );
// 	
// 	level.woods StopAnimScripted();
// 	level.weaver StopAnimScripted();
//  
//  	//Goto next event
//  	flag_set("BEGIN_EVENT13");
// }

event10_TearGasRoom()
{
 	//Goto next event
 	flag_set("BEGIN_EVENT13");
}


////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////
