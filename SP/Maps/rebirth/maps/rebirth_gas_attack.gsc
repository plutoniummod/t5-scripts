/*
	Rebirth: Gas Attack Event - 
		
	Gas is used in the streets and village area.  The player must move up through it and destroy the 
	attacking helicopters.
*/

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_vehicle;
#include maps\rebirth_anim;
#include maps\rebirth_utility;
#include maps\_rusher;
#include maps\_anim;
#include maps\_music;



/*------------------------------------------------------------------------------------------------------------
																								Event:  Gas Attack
------------------------------------------------------------------------------------------------------------*/

//------------------------------------
// Main event thread.  Controls the flow of the event.  
// Waits for the proper flag to be set to move on.
event_gas_attack()
{
	btr_rail_crash();

	// put player in the hazmat suit
	level thread hazmat_init_on_players();
	
	// objectives
	level thread gas_attack_objectives();

	// dialogue
	level thread gas_attack_dialogue();

	// vignettes
	level thread gas_attack_vignettes();
	
	// fog
//	level thread maps\createart\rebirth_art::gas_attack_enter_fog(3);

	// set up weaver's BTR
	level thread weaver_btr_disabled_setup();

	// IR effects 
	// level thread ir_heat_shimmer();

	// event functions
	level thread gas_attack_seagulls();
	level thread helicopter_strafe_to_tower();
	level thread heli_rappelers_to_ground();
	level thread streets_helis_init();
	player_off_the_streets();
	level thread disable_weavers_btr();
	level thread destroy_heli_by_friendly();
	level thread player_at_strela();
	level thread strela_helis_init();
	strela_wait_for_pickup();
	// level thread restore_fog();
	
	flag_wait( "event_destroy_copter_done" );
}

gas_attack_seagulls()
{
	flag_wait( "gas_attack_attack_heli_move" );
	level notify( "seagull_fall_04_start" );
}

//------------------------------------
// Run the hazmat functions on the player
hazmat_init_on_players()
{
	player = get_players()[0];
	player.health = player.maxhealth;
	wait(.1);
	player thread hazmat_health_init();

	flag_set("event_gas_attack_start");
}



//------------------------------------
// waits for the player to get off the streets to continue
player_off_the_streets()
{
	trigger_wait( "off_street" );
	flag_set( "event_btr_disabled_done" );
	
	level thread hazmat_window_mantle();
}

hazmat_window_mantle()
{
	trigger_wait( "gas_attack_color_r9" );
	
	guys = GetEntArray( "hudson_btr_hero", "script_noteworthy" );
	for( i = 0; i < guys.size; i++ )
	{
		if( IsDefined( guys[i].script_forcecolor ) && guys[i].script_forcecolor == "r" )
		{
			guys[i] thread friendly_mantle_through_window();
		}
	}
	
	waittill_ai_group_cleared( "enemy_roof_hopper" );
	wait(1);
	trigger_use( "move_red_after_mantle" );	
}

friendly_mantle_through_window()
{	
	self waittill( "goal" );
	
	waittill_ai_group_cleared( "enemy_roof_hopper" );
		
	self anim_single( self, "crouch_window_mantle" );
}




//------------------------------------
// take the helicopter that shot the BTR and have
// it pass over and fly to the end of the event
helicopter_strafe_to_tower()
{
	veh_heli1		= GetEnt( "btr_rail_enemy_heli1", "targetname" );
	node_heli1	= GetVehicleNode( "street_battle_heli_start", "targetname" );
	player 			= get_players()[0];
	
	veh_heli1 SetLookAtEnt( player );
	veh_heli1 thread go_path( node_heli1 );
	veh_heli1 rb_heli_spotlight_enable( true );
	
	// veh_heli1 waittill_either( "goal", "near_goal" );
	wait( 20 );
	veh_heli1 rb_heli_spotlight_disable();
	veh_heli1 Delete();
}

//------------------------------------
// Helicopter takes out BTR, player gets up,
// gas attack happens
#using_animtree("generic_human");
btr_rail_crash()
{	
	// Set the player up for the animation
	player = get_players()[0];
	player DisableWeapons();
	player_body = spawn_anim_model( "player_body_hazmat", player.origin, player GetPlayerAngles() );	
	player PlayerLinktoAbsolute( player_body, "tag_player");

	// Set the troops up for the animation
	trigger_use( "hudson_btr_riders" );
	wait(.1);
	btr_guys = get_ai_array( "hudson_btr_hero", "script_noteworthy" );
	btr_guys[0].animname = "crash_guy0";

	// spawn in the gassed hero character
	gas_hero = rb_spawn_character("redshirt_hazmat_gas", (0,0,0), (0,0,0), "crash_guy1");
	gas_hero MakeFakeAI();
	gas_hero.team = "allies";
	gas_hero setlookattext( "Pvt. Fulsang", &"" ); 
	gas_hero UseAnimTree(#animtree);
	gas_hero thread gas_shader_on();
	gas_hero thread gas_hero_cleanup();

	// Set the helicopters up for the animation
	trigger_use( "helicopter_reinforcements" );

	// FIXME: start the gas...we need to tie this in with the football...
	// I'm moving this here for now as we want the gas going while the BTR crash 
	// guy is dying
	//level thread explode_gas_in_streets();

	// play the BTR animation
	level thread btr_crash_anim();	

	// start the football chopper
	level thread football_fire_pos();

	// Animate!
	anim_ents = [];
	anim_ents2= [];
	anim_ents[ anim_ents.size ] = player_body;
	anim_ents[ anim_ents.size ] = btr_guys[0];
	anim_ents2[ anim_ents2.size ] = gas_hero;
	
	//SOUND - Shawn J
	//iprintlnbold ("nova_6");
	clientnotify ("nova_seis");
	
	gas_struct = getstruct( "anim_struct_btr_crash_gasguy" );
	anim_struct = getstruct( "anim_struct_btr_crash" );
	gas_struct thread anim_single_aligned( anim_ents2, "btr_crash" );
	anim_struct anim_single_aligned( anim_ents, "btr_crash" );		
	
	level notify( "seagull_fall_01_start" );
	
	player Unlink();
	player_body Delete();
	
	gas_civs = simple_spawn("btr_crash_gassed_civ", ::btr_crash_civs);
	
	player thread gas_mask_weapon_raise();
	exploder(399);
	flag_set( "event_btr_rail_done" );
	
	level.is_btr_rail = false;
	level.callbackVehicleDamage = ::rebirth_reset_vehicle_damage;
	level.overrideVehicleDamage = maps\rebirth_gas_attack::vehicle_override_strela_only;
	
	wait( 5 );
	level notify( "seagull_fall_02_start" );
}

gas_hero_cleanup()
{
	trigger_wait( "off_street" );
	self Delete();
}

football_fire_pos()
{
	trigger_use("gas_attack_football_chopper");
	wait(.85);
	heli = GetEnt( "football_heli", "script_noteworthy" );
	heli rb_heli_spotlight_enable();
	fire_node = GetVehicleNode( "print_pos_angles", "script_noteworthy" );
	
	fire_node waittill( "trigger" );
	
	// wait(.75);
	
	// IPrintLn( "gas fire" );
	level notify("gascan_start");
	PlayFXOnTag( level._effect[ "rocket_muzzleflash" ], heli, "tag_rocket_left" );
	wait(.5);
	PlayFXOnTag( level._effect[ "rocket_muzzleflash" ], heli, "tag_rocket_right" );
	
	// IPrintLn( "gas land" );
}



//------------------------------------
// Play crash animation for the BTR
btr_crash_anim()
{
	//TUEY set music state to BTR_OWNED
	setmusicstate("BTR_OWNED");
	// spawn in the btr
	btr = spawn_anim_model("crash_btr", (0,0,0), (0,0,0));

	model_name = btr.model;
	model_btr = Spawn( "script_model", btr.origin );
	model_btr.angles = btr.angles;
	model_btr SetModel( model_name );
	model_btr UseAnimTree( level.scr_animtree["crash_btr"] );
	model_btr.animname = "crash_btr";
	btr Delete();

	anim_struct = getstruct( "anim_struct_btr_crash" );
	anim_struct anim_single_aligned( model_btr, "btr_crash" );		
}

//------------------------------------
// Turn on gas shader
gas_shader_on()
{
	wait(8.0);
	PlayFXOnTag(level._effect["gas_death_fumes"], self, "J_Head");
	if( is_mature() )
	{
		self SetClientFlag(0);
	}
}

//------------------------------------
// Put on gasmask
gas_mask_weapon_raise()
{
	// Setup gasmask weapon
	self GiveWeapon( "gasmask_sp" );
	self SwitchToWeapon( "gasmask_sp" );
	self EnableWeapons();
	//SOUND - Shawn J
	self playsound ("fly_hazmask_on");
	wait(2.1);
	
	SetCullDist( 3500 );
	
	self HideViewModel();
	self maps\_gasmask::gasmask_put_on();
	maps\createart\rebirth_art::gas_attack_enter_fog(1);
	
	//SOUND - Shawn J
	//iprintlnbold ("gasmask on");	
	clientnotify( "mask_on_snapshot" );
	setsaveddvar("snd_futz_force", 1.0);
	
	self TakeWeapon( "gasmask_sp" );
	self SwitchToWeapon( "enfield_ir_mk_sp" );
	self ShowViewModel();
	

	
	
}

//------------------------------------
// Take off gas mask
gas_mask_weapon_lower()
{
	player = get_players()[0];
	previous_weapon = player GetCurrentWeapon();
	
	did_player_die = GetPersistentProfileVar( 2, 0 );
	if( did_player_die == 1 )
	{
		player giveachievement_wrapper( "SP_LVL_REBIRTH_NOLEAKS" );
	}
	
	self GiveWeapon( "gasmask_sp" );
	self SwitchToWeapon( "gasmask_sp" );
	
	wait(0.6);

	self HideViewModel();
	// maps\createart\rebirth_art::gas_attack_exit_fog(1.5);
	wait(1.5);
	level thread maps\createart\rebirth_art::lab_exterior_fog(0);
	
	level thread maps\rebirth_gas_attack::hazmat_health_turn_off();	
	self maps\_gasmask::gasmask_remove();
	
	//SOUND - Shawn J
	//iprintlnbold ("gasmask off");
	clientnotify( "mos" );
	
	self playsound ("fly_hazmask_off");
	setsaveddvar("snd_futz_force", 0.0);
	
	self SwitchToWeapon( previous_weapon );
	self ShowViewModel();
}

//------------------------------------
// Play the gas fx for a gas bomb exploding
explode_gas_in_streets(ent)
{
	node_start_gas		= GetVehicleNode( "drop_gas", "script_noteworthy" );
	gas_explode_point	= getstruct( "gas_explode_1", "targetname" );
	gas_emitter 		= GetEntArray( "gas_emitter_1", "targetname" );
	
	gas_trig_init();
	
//	level thread maps\rebirth_gas::gas_fog_transition( gas_explode_point.origin );
	wait(2.5);
	PlayFX( level._effect[ "gas_bomb_outside" ], gas_explode_point.origin + (0, 0, 50), AnglesToUp(gas_explode_point.angles) );

	// Exploder(400);

	flag_wait("gas_attack_player_in_house_1");

	indoor_canister_1 = GetStruct("gas_attack_indoor_canister_1", "targetname");
	PlayFX( level._effect[ "gas_bomb_inside" ], indoor_canister_1.origin, AnglesToUp(indoor_canister_1.angles) );

//	Exploder(420);
//
//	trigger_wait("off_street");
//
//	Exploder(410);
//
	trigger_wait( "gas_attack_explode_alley_building" );
	
	playsoundatposition( "evt_big_explof_gas" , (0,0,0) );
	//iprintlnbold ("BOOM");

	exploder(370);
//
	trigger_wait("gas_attack_color_r10");
//
//	Exploder(430);
//
	trigger_wait("gas_attack_color_r11");
	
	playsoundatposition( "evt_small_canister" , (0,0,0) );
	exploder(450);

	trigger_wait("event_gas_attack_breadcrumb_5");
	
	playsoundatposition( "evt_small_canister" , (0,0,0) );
	exploder(440);
}


gas_trig_init()
{
	gas_trigs = GetEntArray( "gas_attack_gas_trig", "targetname" );
	array_thread( gas_trigs, ::gas_trig_think );
}
	
	
gas_trig_think()
{
	level endon( "gas_attack_done" );
	player = get_players()[0];
	
	flag_wait( "turn_on_gas_exploders" );
	
	while( true )
	{
		self waittill( "trigger" );
		
		exploder( self.script_int );
		
		while( player IsTouching( self ) )
		{
			wait(.1);
		}
		
		stop_exploder( self.script_int );
	}
}

//------------------------------------
// Set up Weaver's BTR in it's disabled state and place
disable_weavers_btr()
{
	trigger_wait("gas_attack_spawn_weaver_btr");

	wait(0.05);

	gas_attack_weaver_btr = GetEnt( "gas_attack_weaver_btr", "targetname" );
	gas_attack_weaver_btr veh_magic_bullet_shield(1);

	trigger_wait( "warp_weaver" );
	
	trigger_use( "weaver_btr_riders" );
	wait(.1);
	
	weaver 				= level.heroes[ "weaver" ];
	btr_riders 		= get_ai_array( "weaver_btr_guys", "script_noteworthy" );
	warpto_spots 	= getstructarray( "weaver_warp_to_btr", "targetname" );
	
	friendlies = array_add( btr_riders, weaver );
	
	for( i = 0; i < friendlies.size; i++ )
	{
		friend_origin = Spawn( "script_model", friendlies[i].origin );
		friend_origin SetModel( "tag_origin" );
	
		friendlies[i] LinkTo( friend_origin );
		friend_origin moveto( warpto_spots[i].origin, .1 );
		friend_origin waittill( "movedone" );
	
		friendlies[i] Unlink();
		friend_origin Delete();
	}
	
	trigger_use( "weaver_btr_take_cover" );
}



//------------------------------------
// Friendly AI shoots down heli with a strela,
// then is killed himself
destroy_heli_by_friendly()
{
	trigger_wait( "event_gas_attack_breadcrumb_5" );
	
	waittill_ai_group_count( "strela_flanked_ai", 1 );
	
	strela_friendly = GetEnt("strela_friendly", "targetname");
	strela_friendly_ai = strela_friendly StalingradSpawn();
	strela_friendly_ai magic_bullet_shield();
	strela_friendly_ai gun_switchto("strela_sp", "right");
	strela_friendly_ai.sprint = true;
	strela_friendly_ai.script_forcegoal = true;

	trigger_use( "spawn_heli_strela_target" );
	wait(.2);

	heli = GetEnt( "heli_strela_ai_target", "script_noteworthy" );
	Target_Set( heli, ( 0, 0, -20 ) );
	heli SetLookAtEnt( strela_friendly_ai );
	heli SetGunnerTargetEnt( strela_friendly_ai, (0,0,32), 0 );
	heli.drivepath = 1;
	heli rb_heli_init();
	heli thread rb_heli_path( "heli_target_path", 25 );

	strela_friendly thread strela_event_failsafe();

	strela_friendly_ai waittill_either( "goal", "strela_failsafe" );

	wait(2.0);
	ready_to_fire = false;
	
	while( !ready_to_fire )
	{
		forward_angles = VectorNormalize( strela_friendly_ai GetTagAngles(	"tag_flash" ) );
		start_origin = strela_friendly_ai GetTagOrigin("tag_flash");
		origin_norm = VectorNormalize( start_origin );
		gun_to_heli = VectorNormalize(heli.origin - origin_norm);
		dot = VectorDot( forward_angles, gun_to_heli );
		
		//IPrintLn( dot );
		if( dot > .7 )
		{
			trace = BulletTrace( start_origin, heli.origin, true, heli );
			if( trace["position"] == heli.origin )
			{
				ready_to_fire = true;
			}
		}
		wait(.1);
	}

	friendly_origin = strela_friendly_ai GetTagOrigin("tag_flash");
	start_pos = friendly_origin;
	end_pos = heli.origin + (0, 0, -20);
	
	MagicBullet("strela_sp", start_pos, end_pos, undefined, heli, (0, 0, -20) );
	heli veh_magic_bullet_shield( false );
	
	heli thread destroy_friendly_by_heli( strela_friendly_ai );
	
	heli waittill("damage");
	//RadiusDamage( heli.origin, 256, heli.health + 100, heli.health + 100);
	strela_friendly_ai stop_magic_bullet_shield();
	strela_friendly_ai DoDamage(strela_friendly_ai.health * 2, heli.origin);
	heli thread heli_going_down( 90 );
	
	//wait( 1 );
	
//	rebirth_dialogue( "weaver_take_strela" );

	level.heroes[ "weaver" ] anim_single(level.heroes[ "weaver" ], "use_strela");
	
	flag_set( "event_gas_attack_get_strela" );
	
	//TUEY set music state to STRELLA_LOOP
	setmusicstate("STRELLA_LOOP");
	
}

destroy_friendly_by_heli( strela_friendly_ai )
{
	self endon( "death" );

	for( i = 0; i < 25; i++ )
	{	
		self SetGunnerTargetEnt( strela_friendly_ai, (0,0,32), 0 );
		self FireGunnerWeapon( 0 );
		wait(.1);
	}
}

strela_event_failsafe()
{	
	self endon( "death" );
	
	wait( 10 );
	self notify("strela_failsafe");
}

//------------------------------------
// Makes a cool crashing animation for going down helicopters
heli_going_down( crash_angles )
{
	self endon("helicopter_crashed");
	
	aligned_anim = Spawn("script_model", self.origin);
	aligned_anim SetModel("tag_origin");
	
	if( !IsDefined( crash_angles ) )
	{
		if( RandomInt(2) % 2 )
		{
			aligned_anim.angles = self.angles + (0, 90, 0); 
		}
		else
		{
			aligned_anim.angles = self.angles - (0, 90, 0); 
		}
	}
	else
	{
		aligned_anim.angles = self.angles + (0, crash_angles, 0);
	}
	
	heli_to_crash = spawn_anim_model("rebirth_heli", self.origin);
	heli_to_crash.angles = self.angles;
	self rb_heli_spotlight_enable( false );
	
	self Delete();
	heli_to_crash Attach("t5_veh_helo_mi8_att_dualguns", "body_animate_jnt");
	heli_to_crash Attach("t5_veh_helo_mi8_att_spotlight", "body_animate_jnt");
	heli_to_crash UseAnimTree( level.scr_animtree[ "rebirth_heli" ] );
	
	sound_ent = Spawn( "script_origin", heli_to_crash.origin );
	sound_ent LinkTo( heli_to_crash, "body_animate_jnt" );
	self thread delete_sound_ent(sound_ent);
	
	PlayFXOnTag(level._effect["hip_crash_exp_impact"], heli_to_crash, "tag_origin");
	PlayFXOnTag(level._effect["heli_rotors"], heli_to_crash, "main_rotor_jnt");
	PlayFXOnTag(level._effect["hip_crash_gas_attack"], heli_to_crash, "tag_origin");
	
	sound_ent playsound( "evt_heli_hit" );

	start_pos = GetStartOrigin( aligned_anim.origin, aligned_anim.angles, level.scr_anim["rebirth_heli"]["heli_crash"] );
	start_angles = GetStartAngles( aligned_anim.origin, aligned_anim.angles, level.scr_anim["rebirth_heli"]["heli_crash"] );
	
	sound_ent playloopsound( "evt_helicopter_spin_loop" );

	// start_angles += ( -45, 0, 0 );
	heli_to_crash moveto( start_pos, .25 );
	heli_to_crash RotateTo( start_angles, .25 );
	heli_to_crash waittill( "rotatedone" );

	aligned_anim anim_single_aligned(heli_to_crash, "heli_crash");
	aligned_anim Delete();
	sound_ent stoploopsound(.05);
	playsoundatposition( "evt_heli_hit_ground" , heli_to_crash.origin );
	heli_to_crash Delete();
	self notify("helicopter_crashed");
}

delete_sound_ent(sound_ent)
{
	self waittill("helicopter_crashed");
	sound_ent Delete();
}

//------------------------------------
// Wait for the player to reach the strela
player_at_strela()
{
	trigger_wait( "trig_at_strela" );
	
	flag_set( "event_gas_attack_done" );
}



//------------------------------------
// Wait for the player to find and pick up the Strela
strela_wait_for_pickup()
{
	player = get_players()[0];
	player endon( "disconnect" );
	player endon( "death" );

	flag_wait( "event_gas_attack_get_strela" );

	maps\rebirth_portals::rb_portals_strela();

	// create glow object
	//strela = GetEnt("gas_attack_strela", "targetname");

	//level.player_got_strela_first = false;
	player_has_strela = false;
	
	player thread player_needs_to_get_strela();
	player thread strela_nag_lines();
	
	weapons = player GetWeaponsList();
	while(!player_has_strela)
	{
		weapons = player GetWeaponsList();
		
		for(i = 0; i < weapons.size; i++)
		{
			if(weapons[i] == "strela_sp")
			{
				flag_set("strela_found");
				player_has_strela = true;
				
				if( IsDefined(level.objective_model) )
				{
					level.objective_model delete();
				}
			}
		}
		
		wait(0.05);
	}
	
	player GiveMaxAmmo("strela_sp");
	player anim_single(player, "got_it_2");

	flag_set( "event_gas_attack_got_strela" );
	
	level thread Destroy_helicopter_markers( "event_destroy_copter_done");		
}

player_needs_to_get_strela()
{
	level endon("strela_found");
	self endon( "hazmat_suit_destroyed" );
	
	autosave_by_name( "rebirth_pickup_strela" );
	
	array_of_items = GetItemArray();
	level.strela = array_of_items[0];
	found_strela = false;
	
	while(!found_strela)
	{
		array_of_items = GetItemArray();
		
		for(i = 0; i < array_of_items.size; i++)
		{
			if(array_of_items[i].classname == "weapon_strela_sp")
			{
				level.strela = array_of_items[i];
				found_strela = true;
			}
		}
		
		wait(1.0);
	}

	level.objective_model = spawn("script_model", level.strela.origin);
	level.objective_model SetModel("t5_weapon_strela_world_obj");
	level.objective_model.angles = level.strela.angles;
	
	//obj_strela = getstruct("obj_find_sam", "targetname");
	//obj_strela.origin = strela.origin;

	/*
	while( player GetCurrentWeapon() != "strela_sp" )
	{
		wait( .1 );
	}
	*/
}

weapons_on_player()
{
	weapons = get_players()[0] GetWeaponsList();
	
	while(!level.found_strela)
	{
		for(i = 0; i < weapons.size; i++)
		{
			if(weapons[i] == "streala_sp")
			{
				level.player_got_strela_first = true;
				level.found_strela = true;
			}
		}
	}
}

//------------------------------------
// Pick up strela nag lines (self == player)
strela_nag_lines()
{
	self endon("disconnect");
	self endon("death");

	lines = array("take_out_choppers", "cant_move", "use_strela");
	current_line = 0;

	while( 1 )
	{
		wait (RandomFloatRange(6, 7));

		if (self GetCurrentWeapon() != "strela_sp")
		{
			level.heroes["weaver"] anim_single(level.heroes["weaver"], lines[current_line]);
			current_line++;
			if (current_line > 2)
			{
				current_line = 0;
			}
		}
		else
		{
			return;
		}	
	}
}


//------------------------------------
// Puts 3d markers on helicopters that player must Destroy
// Stolen from pow_utility.gsc
destroy_helicopter_markers( flag_to_set )
{
	targets			= [];
	targets[0]	= GetEnt( "gas_attack_strela_heli_1", "script_noteworthy" );
	targets[0] veh_magic_bullet_shield( false );
	targets[0] SetForceNoCull();
	targets[1]	= GetEnt( "gas_attack_strela_heli_2", "script_noteworthy" );	
	targets[1] veh_magic_bullet_shield( false );
	targets[1] SetForceNoCull();
	obj_number	= level.obj_iterator;
	
	targets = array_removedead(targets);
	
	array_thread(targets, ::update_position_on_death, flag_to_set);
	//targets = array_combine( zsus, triggers );
	
	while( targets.size > 0)
	{
		i = 0;
		
		for( ; i < 8 && i < targets.size; i++) //-- 8 is the limit for Objective_AdditionalPosition
		{
			if( targets[i].classname == "trigger_multiple" )
			{
				temp_ent = GetEnt(targets[i].target, "targetname");
				Objective_AdditionalPosition( obj_number, i, temp_ent.origin );
			}
			else
			{
				Objective_AdditionalPosition( obj_number, i, targets[i] );
			}
		}
		
		for( ; i < 8; i++ )
		{
			Objective_AdditionalPosition( obj_number, i, (0,0,0) );
		}
		
		level waittill(flag_to_set);

		targets = array_removedead(targets);
	}
	
	flag_set(flag_to_set);	
	
	//TUEY set music state to STRELLA_LOOP
	setmusicstate("CHOPPERS_DEFEATED");
}



//------------------------------------
// send update_msg as a notify when this heli is destroyed
update_position_on_death( update_msg ) 
{	
	while( IsDefined(self) && !self maps\_vehicle::is_corpse()) //TODO: check to see if this is a hack
	{	
		wait(0.1);
	}
	
	/*
	while( IsDefined(self) )
	{
		self waittill("damage");
		if( self.health < 0 )
		{
			self rb_heli_spotlight_enable(false);	
		}
	}
	*/
	
	level notify( update_msg );
}



//------------------------------------
// If the player moves too far forward without killing
// the helicopters, remind him to do so.
remind_destroy_helicopters()
{
	trigger_wait( "kill_helis_vo" );
	
	for( i = 0; i < level.village_helis.size; i++ )
	{
		if( IsDefined( level.village_helis[i] ) && IsAlive( level.village_helis[i] ) )
		{
			level.heroes["weaver"] anim_single(level.heroes["weaver"], "cant_move");
			break;
		}
	}		
}



//------------------------------------
// spawn in the helicopters with rappelers 
// have them drop to the ground
heli_rappelers_to_ground()
{
	level thread heli_rappel_ai( "heli_with_troops_1", "heli_rappelers_1", undefined, 436, "helicopter_disappear_point" );
	level thread heli_rappel_ai( "heli_with_troops_2", "heli_rappelers_2", "rappel_cover_nodes_2", 436, "helicopter_disappear_point" );
	
	trigger_wait( "gas_rappelers_1" );
	wait(.1);		// Helicopter spawning in
	level thread heli_rappel_ai( "heli_with_troops_3", "heli_rappelers_3", "rappel_cover_nodes_3", 336, "helicopter_disappear_point_3" );
}



//------------------------------------
// Rappel AI down from a Helicopter
//	heli_name				=	script_noteworthy of helicopter to rappel guys from
// 	rappelers_name	=	targetname of AI to drop from the helicopter
//	cover_name			=	targetname of nodes for AI to run to after rappeling
heli_rappel_ai( heli_name, rappelers_name, cover_name, drop_dist, disappear_point )
{	
	ent_heli 					= GetEnt( heli_name, "script_noteworthy" );
	struct_heli_goto	= getstruct( disappear_point, "targetname" );
	nodes_cover = [];
	if(IsDefined( cover_name ) )
	{
		nodes_cover				= GetNodeArray( cover_name, "targetname" );
	}	
	
	// Turn on spotlights
	ent_heli rb_heli_spotlight_enable( true );

	// make sure the vehiclenode where the AI rappel on has the script_flag_wait of "heli_rappel"
	ent_heli vehicle_flag_arrived( "heli_rappel" );	

	// spawn rappel structs
	rappel_struct_left = SpawnStruct();
	rappel_struct_left.origin = ent_heli GetTagOrigin("tag_rocket_left");
	rappel_struct_left.angles = ent_heli GetTagAngles("tag_rocket_left");
	rappel_struct_left.targetname = heli_name + "rappel_left";

	rappel_struct_right = SpawnStruct();
	rappel_struct_right.origin = ent_heli GetTagOrigin("tag_rocket_right");
	rappel_struct_right.angles = ent_heli GetTagAngles("tag_rocket_right");
	rappel_struct_right.targetname = heli_name + "rappel_right";

	rappeller_spawner = GetEnt( rappelers_name, "targetname" );
	ent_ai = [];
	// spawn rappellers
	while( rappeller_spawner.count )
	{
		ent_ai = array_add( ent_ai, simple_spawn_single( rappelers_name ) );
	}
	
	array_thread( ent_ai, ::enable_cqbwalk );
	
	// Rappel down
	for (i = 0; i < ent_ai.size; i++)
	{
		rappel_struct = undefined;

		// switch sides every other guy		
		if( i % 2 )	
		{
			rappel_struct = rappel_struct_left;
		}
		else 
		{
			rappel_struct = rappel_struct_right;
		}		

		// set the ai's target to be the targetname of the struct...ai rappel systems uses this
		// to know where to rappel from
		ent_ai[i].target = rappel_struct.targetname;

		// do the rappel 
		ent_ai[i] thread maps\_ai_rappel::start_ai_rappel(2, rappel_struct, false, false);
		ent_ai[i] thread rappel_ai_temp_ignore();
		// set his goal node
		if( IsDefined( nodes_cover ) && IsDefined( nodes_cover[i] ) )
		{
			ent_ai[i] SetGoalNode( nodes_cover[i] );
		}	
		else 
		{
			ent_ai[i].goalradius = 32;
			ent_ai[i] SetGoalPos( get_players()[0].origin );
		}

		wait(0.5);
	}
	
	wait( 2 );		// hardcoded wait just to ensure all AI are off ropes
	
	ent_heli ClearLookAtEnt() ;
	ent_heli SetSpeed( 35, 10 );
	ent_heli SetVehGoalPos( struct_heli_goto.origin );
	ent_heli.drivePath = true;
	
	ent_heli waittill( "goal" );
	ent_heli Delete();	
}

rappel_ai_temp_ignore()
{
	self endon( "death" );
	
	self set_ignoreme( true );
	self set_pacifist( true );
	
	self waittill("rappel_done");
	wait( 3 );
	
	self set_ignoreme( false );
	self set_pacifist( false );	
}

//------------------------------------
// move an AI down from the helicopter and send to a cover node
//	goto_node	=	the node the AI will run to
rappel_down( goto_node, drop_dist )
{	
	self endon( "death" );
	
	self.org Unlink(); 	
	self.org MoveZ( (0 - drop_dist), 2, .5, .5 );		
	
	self.org waittill( "movedone" );
	
	self Unlink();
	self.org Delete();	
	
	if( IsDefined( goto_node ) )
	{
		self SetGoalNode( goto_node );
	}		
	
	self set_ignoreall( false );
	self enable_cqbwalk();
}



/*------------------------------------------------------------------------------------------------------------
																								Helicopter Movement
------------------------------------------------------------------------------------------------------------*/

//------------------------------------
//
helicopter_watch_damage( )
{
	self endon( "death" );
	
	while( true )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type, modelName, tagName );
	
		if( type == "MOD_PROJECTILE" )
		{
			//RadiusDamage( self.origin, 256, self.health + 100, self.health + 100);
			self thread heli_going_down( undefined );
		}
	}
}



/*------------------------------------------------------------------------------------------------------------
																					Helicopter Movement / Attacking
------------------------------------------------------------------------------------------------------------*/

/*------------------------------------

self = heli 
------------------------------------*/
helicopter_sweep_init()
{	
	trigger_wait( "spawn_mesh_helis", "script_noteworthy" );
	wait(1);
	
	// start player breadcrumb System
	players = get_players();
	array_thread( players, ::helicopter_sweep_player_breadcrumb );
	
	dyn_heli 		= GetEnt( "dynamic_heli", "targetname" );
	script_heli = GetEnt( "scripted_heli", "targetname" );
	
	dyn_heli.sweep_dist = 2048;
	script_heli.sweep_dist = 2248;
	
	dyn_heli thread helicopter_sweep_select_pattern();	
	script_heli thread helicopter_scripted_init();	
	
	level.village_helis = [];
	level.village_helis[0] = dyn_heli;
	level.village_helis[1] = script_heli;	
	
	// TEMP - until hip has a spotlight gunner added
	for( i = 0; i < level.village_helis.size; i++ )
	{
		spotlight	= GetEnt( level.village_helis[i].script_noteworthy, "targetname" );
		spotlight LinkTo( level.village_helis[i] );
		
		PlayFXOnTag( level._effect["spotlight"], spotlight, "tag_origin" );
		
		level.village_helis[i] thread heli_light_delete_on_death( spotlight );
	}
}



//------------------------------------
// If the player enters the killzone, tell the 
// helicopters to fire on him
start_helicopter_killzone()
{	
	trigger_wait( "helicopter_killzone" );
	
	for( i = 0; i < level.village_helis.size; i++ )
	{
		if( IsDefined( level.village_helis[i] ) && IsAlive( level.village_helis[i] ) )
		{
			flag_clear( "can_save" );
			level.village_helis[i] thread helicopter_killzone_fire();
		}
	}
}



//------------------------------------
// have the helicopter fire
helicopter_killzone_fire()
{
	self endon( "death" );
	
	self notify( "heli_stop_patterns" );
	
	player = get_players()[0];
	
	self SetGunnerTargetEnt( player, (0,0,32), 0 );
	
	pos = ( player.origin[0], player.origin[1], self.origin[2] );
	self SetVehGoalPos( pos, false );	
	
	while( true )
	{	
		for( i = 0; i < 25; i++ )
		{	
			self SetGunnerTargetEnt( player, (0,0,32), 0 );
			self FireGunnerWeapon( 0 );
			wait(.1);
		}
		
		wait( .5 );
		pos = ( player.origin[0], player.origin[1], self.origin[2] );
		self SetVehGoalPos( pos, false );	
	}	
	
}



//------------------------------------
// when the helicopter dies, delete the spotlight
heli_light_delete_on_death( spotlight )
{
	self waittill( "death" );	
	spotlight Delete();	
}



//------------------------------------
// Messy:  selects start and end points for a helicopter
// to fly between when circling the player
helicopter_sweep_select_pattern()
{	
	self endon( "death" );
	self endon( "heli_stop_patterns" );
	
	player = get_players()[0];
	
	self.lockheliheight = true;
	Target_Set( self, ( 0, 0, -20 ) );
	// self.drivePath = true;
	
	
	self setgunnertargetent( player, (0, 0, -256), 0 );
	self thread helicopter_watch_damage();
	
	start_point = (0, 0, 0);
	end_point 	= (0, 0, 0);

	while( true )
	{		
		player_angles = player GetPlayerAngles();
		player_forward = VectorNormalize( AnglesToForward( player_angles ) );
		player_right = VectorNormalize( AnglesToRight( player_angles ) );
		
		choice = RandomInt( 5 );
			
		switch( choice )
		{
			case 0:	// -.-
				start_point = player.origin + ( player_forward * self.sweep_dist ) + ( player_right * self.sweep_dist );			
				end_point = player.origin + ( player_forward * self.sweep_dist ) - ( player_right * self.sweep_dist );
				break;
				
			case 1:	// /.
				start_point = player.origin + ( player_forward * ( self.sweep_dist * 2 ) );			
				end_point = player.origin  - ( player_right * self.sweep_dist );
				break;
				
			case 2:	// |.
				start_point = player.origin + ( player_forward * self.sweep_dist ) - ( player_right * self.sweep_dist );			
				end_point = player.origin - ( player_forward * self.sweep_dist ) - ( player_right * self.sweep_dist );
				break;
				
			case 3:	// .\
				start_point = player.origin + ( player_right * ( self.sweep_dist * 2 ) );			
				end_point = player.origin + ( player_forward * ( self.sweep_dist * 2 ) );			
				break;
				
			case 4: // .|
				start_point = player.origin - ( player_forward * self.sweep_dist ) + ( player_right * self.sweep_dist );			
				end_point = player.origin + ( player_forward * self.sweep_dist ) + ( player_right * self.sweep_dist );
				break;
		}
		
		self SetVehGoalPos( start_point, false );
		self SetNearGoalNotifyDist( 712 );
		
		
		// self thread helicopter_sweep_draw_debug( start_point, end_point );
		
		self waittill_either( "goal", "near_goal" );
		// IPrintLn( "At START" );
		
		self thread helicopter_sweep_shoot();
		
		// Check to see if both points are behind the player.  If so, pick a new start spot
		player_angles = player GetPlayerAngles();
		player_forward = VectorNormalize( AnglesToForward( player_angles ) );	
		player_to_start = VectorNormalize( start_point - player.origin );
		player_to_end = VectorNormalize( end_point - player.origin );

		start_dot = VectorDot( player_forward, player_to_start );
		end_dot = VectorDot( player_forward, player_to_end );

		// IPrintLn( "Start: " + start_dot + ", End: " + end_dot );

		if( start_dot > 0 || end_dot > 0 )
		{
			self SetVehGoalPos( end_point, false );
			
			self waittill_either( "goal", "near_goal" );
			// IPrintLn( "At END" );
		}
	}
}



//------------------------------------
// debug lines, shows the helicopter start and end points
helicopter_sweep_draw_debug(start_point, end_point)
{
	self notify( "heli_sweep_new_debug" );
	self endon( "heli_sweep_new_debug" );
	self endon( "death" );
	
	line_start = ( start_point[0], start_point[1], self.origin[2] );
	line_end = ( end_point[0], end_point[1], self.origin[2] );
	
	while( true )
	{
		Print3d( line_start, "START", (0, 1, 0), 1, 4, 1 );
		Print3d( line_end, "END", (1, 0, 0), 1, 4, 1 );
		Line( line_start, line_end, (0, 1, 0), 1, false, 1 );
		wait( .05 );
	}
}



//------------------------------------
// Have the helicopter fire at it's target point
helicopter_sweep_shoot()
{
	self notify( "new_shoot_target" );
	self endon( "new_shoot_target" );
	self endon( "death" );
	
	wait( 4 );
	
	player = get_players()[0];
	
	specific_target = self heli_sweep_player_in_target_trig();

	if( IsDefined(specific_target) )
	{
		self setgunnertargetvec( specific_target, 0 );
	}
	
	else
	{	
		target_pos = player helicopter_find_best_breadcrumb();
		self setgunnertargetvec( target_pos, 0 );
	}
	
	for( i = 0; i < 20; i++ )
	{
		self FireGunnerWeapon( 0 );
		wait(.1);
	}
}



//------------------------------------
// Wait for the player to be in a trigger to have
// the helicopter fire at a specific spot
heli_sweep_player_in_target_trig()
{
	trigs = GetEntArray( "heli_specific_target", "targetname" );
	player = get_players()[0];
	
	for( i = 0; i < trigs.size; i++ )
	{
		if( player IsTouching( trigs[i] ) )
		{
			trig_target = getstruct( trigs[i].target, "targetname" );
			trace = BulletTrace( trig_target.origin, self.origin, false, self );
			
			if( trace["position"] == self.origin )
			{
				if( !IsDefined( trigs[i].script_noteworthy ) )
				{
					trigs[i] Delete();
				}
				return( trig_target.origin );
			}
		}
	}
	
	return( undefined );
}



/*------------------------------------
			-- copied from zombies --
breadcrumb system, used to find a safe
	place to drop the briefcase		
 	
self = the player storing crumbs		
------------------------------------*/
helicopter_sweep_player_breadcrumb()
{
	self endon( "disconnect" ); 

	min_dist = 64 * 64; 
	crumb_offset = ( 0, 0, 72 );
	total_crumbs = 5;
	index = 0;
	
	self.heli_breadcrumbs = []; 
	self.heli_breadcrumbs[0] = self.origin; 

	while( true )
	{
		store_crumb = true; 
		crumb = self.origin + crumb_offset;
		wait_time = .5;

		if ( !self IsOnGround() )
		{
			trace = bullettrace(self.origin + (0,0,20),self.origin + (0,0,-500),0,undefined);
			crumb = trace["position"] + crumb_offset;
			wait_time = 0.05;

			store_crumb = false;
		}

		for( i = 0; i < self.heli_breadcrumbs.size; i++ )
		{
			if( IsDefined(self.heli_breadcrumbs[i]) && 
				DistanceSquared( crumb, self.heli_breadcrumbs[i], min_dist ) < min_dist )
			{
				store_crumb = false; 
			}
		}

		if( store_crumb )
		{
			if ( index >= total_crumbs )
			{
				index = 0;
			}
			
			self.heli_breadcrumbs[index] = crumb;
			index++;
		}

		wait( wait_time ); 
	}
}



//------------------------------------
// Find the best breadcrumb for the heli to shoot at
// self = the player who has the crumbs
helicopter_find_best_breadcrumb()
{
	best_crumb = undefined;
	for(i = 0; i < self.heli_breadcrumbs.size; i++)
	{
		if( !isdefined(best_crumb) )
		{
			best_crumb = self.heli_breadcrumbs[i];
		}
		else if( IsDefined(self.heli_breadcrumbs[i]) && 
			distance(self.origin, self.heli_breadcrumbs[i]) > distance(self.origin, best_crumb) )
		{			
			best_crumb = self.heli_breadcrumbs[i];
		}
	}
	
	if( IsDefined( best_crumb ) )
	{
		self.heli_breadcrumbs = array_remove( self.heli_breadcrumbs, best_crumb );
	}
	else
	{
		best_crumb = get_players()[0].origin;
	}
	
	return( best_crumb );
}



//------------------------------------
// Sets up the helicopter to do specific, scripted
// actions instead of dynamic paths.
// self = the helicopter
helicopter_scripted_init()
{
	Target_Set( self, ( 0, 0, -20 ) );
	
	self thread helicopter_watch_damage();	
	
	scripted_trigs = GetEntArray( "heli_strafe", "targetname" );
	array_thread( scripted_trigs, ::helicopter_scripted_strafe, self );
	
	trigger_wait( "heli_strafe_to_dyn" );
	self notify( "stop_scripted_strafe" );
	self thread helicopter_sweep_select_pattern();
}



helicopter_scripted_strafe( heli )
{
	heli endon( "death" );
	heli endon( "stop_scripted_strafe" );
	heli endon( "heli_stop_patterns" );
	self waittill( "trigger" );
	
	start_node = GetVehicleNode( self.script_noteworthy, "targetname" );
	targ_point = getstruct( self.script_noteworthy, "targetname" );
	
	heli thread go_path( start_node );
	
	targ = spawn( "script_model", targ_point.origin );
	targ setmodel( "tag_origin" );	
	targ LinkTo( heli );	
	
	heli setgunnertargetent( targ, (0, 0, 0), 0 );
	
	while( true )
	{
		if( IsDefined( heli.currentNode.script_noteworthy ) && heli.currentNode.script_noteworthy == "start_firing" )
		{
			while( heli.currentNode.script_noteworthy != "stop_firing" )
			{
				heli FireGunnerWeapon( 0 );
				wait(.1);
			}
		}
		else if( IsDefined( heli.currentNode.script_noteworthy ) && heli.currentNode.script_noteworthy == "stop_firing" )
		{
			break;
		}
		
		wait(.1);
	}
}


//------------------------------------
// Wait for the player to be in a trigger to have
// the fog set back to normal
restore_fog()
{
	trigger_wait("gas_attack_end_fog");

 	// level thread maps\createart\rebirth_art::gas_attack_exit_fog(3);
}


//------------------------------------
// Wait for the player to be in a trigger to have
// the fog set back to normal
gas_attack_dialogue()
{
	player = get_players()[0];

	wait(1.0);

	// a bit hackish...sorry!
	redshirts = get_ai_array( "hudson_btr_hero", "script_noteworthy" );
	redshirts[0].animname = "hazmat_redshirt_1";
	redshirts[1].animname = "hazmat_redshirt_2";

	weaver = level.heroes["weaver"];

	player anim_single(player, "protect_suit_1");
	player anim_single(player, "protect_suit_2");

//	redshirts[0] anim_single(redshirts[0], "suit_tight");

	redshirts[0] anim_single(redshirts[0], "speztnaz");
	redshirts[1] anim_single(redshirts[1], "copy_that");

	trigger_wait("gas_attack_color_r2");

	redshirts[0] anim_single(redshirts[0], "check_six");
	redshirts[1] anim_single(redshirts[1], "got_it");

	trigger_wait("gas_attack_color_r3");

	redshirts[0] anim_single(redshirts[0], "off_streets");

	trigger_wait("off_street");

	weaver anim_single(weaver, "moving_north");
	redshirts[0] anim_single(redshirts[0], "moving_west");

	trigger_wait("gas_attack_color_r9");

	player anim_single(player, "keep_north");
	weaver anim_single(weaver, "heavy_fire");
	player anim_single(player, "half_click");

	trigger_wait("gas_attack_color_r11");

	weaver anim_single(weaver, "request_backup");
	player anim_single(player, "almost_there");
	weaver anim_single(weaver, "get_out");
	player anim_single(player, "calls_weaver");

	wait(3.0);

	weaver anim_single(weaver, "were_alive");
	player anim_single(player, "got_it_1");
}

//------------------------------------
// Start behaviors for helis at end of street
streets_helis_init()
{
	trigger_wait("gas_attack_color_r3");

	wait(0.05);

	attack_heli = GetEnt("gas_attack_end_street_heli_3", "script_noteworthy");
	attack_heli thread streets_attack_heli_think();

	weaver_heli = GetEnt("gas_attack_end_street_heli_1", "script_noteworthy");
	weaver_heli thread streets_weaver_attack_heli_think();
}

//------------------------------------
// End street Heli think
streets_attack_heli_think()
{
	self endon( "death" );
	
	self rb_heli_spotlight_enable( true );

	flag_wait("end_street_heli_fire_start");

	player = get_players()[0];

	self SetGunnerTargetEnt( player, (0,0,0), 0 );
	
	while( !flag("end_street_heli_fire_end") )
	{	
		self FireGunnerWeapon( 0 );
		wait(.1);
	}
}

streets_weaver_attack_heli_think()
{
	self endon("death");

	self rb_heli_spotlight_enable( true );

	flag_wait("gas_attack_attack_heli_move");

	shoot_ent = GetStruct("strafe_house1", "targetname");

	self SetGunnerTargetVec( shoot_ent.origin, 0 );

	while (!flag("gas_attack_player_in_alley"))
	{
		num_shots = RandomIntRange(25, 30);

		for (i = 0; i < num_shots; i++)
		{
			self FireGunnerWeapon( 0 );
			wait(.1);	
		}

		wait (RandomFloatRange(1.0, 2.5));
	}

	trigger_wait("gas_attack_spawn_weaver_btr");

	left_spawner = GetEnt( "gas_attack_weaver_squad_left", "script_noteworthy" );
	right_spawner = GetEnt( "gas_attack_weaver_squad_right", "script_noteworthy" );	
	weaver_guys_left = [];
	weaver_guys_right = [];

	while( left_spawner.count )
	{
		weaver_guys_left = array_add( weaver_guys_left, simple_spawn_single( left_spawner ) );
		weaver_guys_right = array_add( weaver_guys_right, simple_spawn_single( right_spawner ) );
	}

	wait(0.05);

//	weaver_guys_left = get_ai_array("gas_attack_weaver_squad_left", "script_noteworthy");
//	weaver_guys_right = get_ai_array("gas_attack_weaver_squad_right", "script_noteworthy");

	weaver_guys = array_merge(weaver_guys_left, weaver_guys_right);

	// wow...sorry for this!
	for (i = 0; i < weaver_guys.size; i++)
	{
		if (IsAlive(weaver_guys[i]))
		{
			self SetGunnerTargetEnt(weaver_guys[i], (0, 0, 32));
			for (j = 0; j < 10; j++)
			{
				self FireGunnerWeapon( 0 );
				wait(.1);			
			}

			wait(0.5);
		}
	}
}

//------------------------------------
// Strela Helis
strela_helis_init()
{
	trigger_wait("event_gas_attack_breadcrumb_5");

	wait(0.05);

	level.strela_heli_firing = false;

	strela_heli_1 = GetEnt("gas_attack_strela_heli_1", "script_noteworthy");
	strela_heli_1 veh_magic_bullet_shield( true );
	strela_heli_1 thread strela_heli_think(1, 2000, 1000);

	strela_heli_2 = GetEnt("gas_attack_strela_heli_2", "script_noteworthy");
	strela_heli_2 veh_magic_bullet_shield( true );
	strela_heli_2 thread strela_heli_think(2, 2500, 1250);
	
	level.village_helis = [];
	level.village_helis[0] = strela_heli_1;
	level.village_helis[1] = strela_heli_2;	
	
	// If player moves into killzone, allow helicopters to kill player
	level thread remind_destroy_helicopters();
	level thread start_helicopter_killzone();
}

strela_heli_think(id, enagage_dist, engage_height)
{
	self endon("death");
	self endon( "heli_stop_patterns" );

	Target_Set( self, ( 0, 0, -20 ) );
	self thread helicopter_watch_lockon( get_players()[0], 2000 );

	self rb_heli_init();
	self rb_heli_spotlight_enable( true );
	self thread helicopter_watch_damage();

	flag_wait("strela_heli_" + id +"_start_fire");

	player = get_players()[0];
	while (!flag("strela_heli_" + id + "_end_fire"))
	{
		self SetGunnerTargetEnt(player, (0, 0, 32));
		self FireGunnerWeapon( 0 );
		wait(0.1);
	}

	self waittill("reached_end_node");

	self thread rb_heli_engage2(level.gas_disable_btr, enagage_dist, engage_height, 7, 8);
	
	self thread strela_heli_shoot(level.gas_disable_btr, RandomFloatRange(0.4, 1.1));
	
	flag_wait("strela_found");
	
	level notify("start_shooting_player");
	
	self thread rb_heli_engage2(player, enagage_dist, engage_height, 7, 8);
	
	self thread strela_heli_shoot(player, RandomFloatRange(0.4, 1.1));

	player = get_players()[0];
	while (true)
	{
		self thread heli_move_after_set_time( 15, 20 );
		
		self waittill_either( "goal", "heli_move" );
		wait( RandomFloatRange(0, 4) );		// hover

		pos = player.origin;
		forward = VectorNormalize( AnglesToForward( player GetPlayerAngles() ) );
		angle_change = RandomFloatRange( -90, 90 );
		newangles = forward;
		// math or something
		newx = newangles[0] * Cos(angle_change) - newangles[1] * Sin(angle_change);
		newy = newangles[0] * Sin(angle_change) + newangles[1] * Cos(angle_change);
		newangles = ( newx, newy, pos[2] );
		newangles = vector_scale( newangles, enagage_dist );
		newpos = pos + newangles;
		// newpos += (0, 0, engage_height);
		
		self SetVehGoalPos( (newpos[0], newpos[1], self.origin[2]), false );	
		// IPrintLn( id + ": " + newpos );
		// self rb_heli_path("strela_heli_retreat_1", 45);
	}
}

heli_move_after_set_time( min, max )
{
	self endon( "goal" );
	self endon( "heli_move" );
	wait( RandomFloatRange(min, max) );
	self notify( "heli_move" );
}

//------------------------------------
// Strela Helis deciding when to shoot
strela_heli_shoot( target, burst_time )
{
	self endon("death");
	self endon("stop_firing");
	level endon("start_shooting_player");
	self endon( "heli_stop_patterns" );
	
	player = get_players()[0];

	while (true)
	{
		wait(RandomFloatRange(3, 7));
		start_pos = self GetTagOrigin( "tag_flash_gunner1" );
		end_pos = player get_eye();
		
		if( target == level.gas_disable_btr)
		{
			self rb_heli_fire_side_gun( target, burst_time );
		}
		else if( BulletTracePassed( start_pos, end_pos, false, self ) )
		{
			self rb_heli_fire_side_gun( target, burst_time );
		}
	}
}


weaver_btr_disabled_setup()
{
	btr_struct = getstruct( "weaver_btr_disabled_spot", "targetname" );
	
	level.gas_disable_btr = Spawn( "script_model", btr_struct.origin );
	level.gas_disable_btr.angles = btr_struct.angles;
	level.gas_disable_btr SetModel( "t5_veh_apc_btr60" );
}



clean_up_gas_attack()
{
	guys = GetEntArray( "hazmat_spetsnaz", "script_noteworthy" );
	for( i = 0; i < guys.size; i++ )
	{
		guys[i] Delete();
	}
}

/*------------------------------------------------------------------------------------------------------------
																								HazMat Health
------------------------------------------------------------------------------------------------------------*/

/*------------------------------------

self = the player this system is running on
------------------------------------*/
hazmat_health_init()
{
	level.hazmat_health_max = 100;
	
	self.hazmat_on = true;
	self.hazmat_health = level.hazmat_health_max;
	// self hazmat_health_create_hudelem();
	self thread hazmat_watch_sprint();
	
	self.overridePlayerDamage = ::hazmat_health_take_damage;
	OnSaveRestored_Callback( ::hazmat_health_save_restore );
	level.onPlayerKilled = ::hazmat_set_death_dvar;
	
	//SetDvar( "player_killed_in_hazmat", "0" );
	SetPersistentProfileVar( 2, 1 ); //-- used for tracking achievement of whether or not the player dies in gas attack section
	wait(0.5);
	autosave_by_name("rebirth_gas_event_is_started");
}



/*------------------------------------
***/
hazmat_health_turn_off()
{
	player = get_players()[0];
	
	player.hazmat_on = false;
	player notify( "hazmat_off" );
	
	if( IsDefined( player.hazmat_hudelem ) )
	{
		player.hazmat_hudelem SetText( "" );
	}
}



/*------------------------------------
***/
hazmat_watch_sprint()
{
	self endon( "hazmat_off" );
	
	while( true )
	{
		if( self IsSprinting() )
		{			
			while( self isSprinting() )
			{
				wait( .5 );
			}
		}
		
		wait( 1 );
	}	
}



/*------------------------------------
***/
hazmat_health_take_damage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	if( self.hazmat_on )
	{
		// haxxxorrrrd...feel free to adjust!
		//if ( sWeapon == "hip_minigun_gunner" )
		if ( sWeapon == "rebirth_hip_minigun_gunner" )
		{
			iDamage = 7;
		}

		if( (!IsGodMode( self )) && self.hazmat_health > 0 )
		{
			self.hazmat_health -= ( iDamage / 3 );
			
			if( self.hazmat_health <= 1 )
			{
				hazmat_health_suit_destroyed();
			}
		}
		
		// Update the hudelem
		// hudelem_string = "Hazmat: " + Int(self.hazmat_health);
		// self.hazmat_hudelem SetText( hudelem_string );	
	
		if( !IsDefined( self.hazmat_cracked ) )
		{
			self.hazmat_cracked = 0;
		}
	
		if( self.hazmat_health < 25 && self.hazmat_cracked < 3 )
		{
			clientnotify( "_gasmask_on_cracked_3" );
			playsoundatposition ("evt_hazmat_suit_cracked_3", (0,0,0));
			self.hazmat_cracked = 3;
		}		
		else if( self.hazmat_health < 50 && self.hazmat_cracked < 2 )
		{
			clientnotify( "_gasmask_on_cracked_2" );
			playsoundatposition ("evt_hazmat_suit_cracked_2", (0,0,0));
			self.hazmat_cracked = 2;
		}
		else if( self.hazmat_health < 75 && self.hazmat_cracked < 1 )
		{
			clientnotify( "_gasmask_on_cracked_1" );
			playsoundatposition ("evt_hazmat_suit_cracked_1", (0,0,0));
			self.hazmat_cracked = 1;
		}		
		
		iDamage = 0;
	}

	return iDamage;		// Player takes no damage
}



/*------------------------------------
***/
hazmat_health_display()
{
	self endon( "hazmat_suit_destroyed" );
	
	while(true)
	{
		IPrintLn( self.hazmat_health );
		wait(.5);
	}
}



/*------------------------------------
***/
hazmat_health_suit_destroyed()
{
	self notify( "hazmat_suit_destroyed" );
	self endon( "death" );	
	
	if( !flag( "hazmat_destroyed" ) )
	{
		flag_set( "hazmat_destroyed" );
		
		self DisableWeapons();
		self StartPoisoning();
		
		//Sound - Shawn J
		playsoundatposition("evt_gas_poison_mask", (0,0,0));
		playsoundatposition ("evt_hazmat_suit_cracked_1", (0,0,0));
	
		wait(0.6);
	
		player_hands = spawn_anim_model("player_hands_hazmat", self.origin, self.angles);
		self PlayerLinkToAbsolute(player_hands, "tag_player");
	
		player_hands anim_single(player_hands, "gas_death");
		
		//Sound - Shawn J
		//iprintlnbold ("hazmask death");
		playsoundatposition( "evt_gas_death_mask", (0,0,0));
	
		//SetDvar( "ui_deadquote", &"REBIRTH_HAZMAT_PUNCTURED" );
		//self thread maps\_load_common::special_death_indicator_hudelement( "hud_obit_nova_gas", 96, 96 );
		//MissionFailed();
		
		SetPersistentProfileVar( 2, 2 );

		missionfailedwrapper( &"REBIRTH_HAZMAT_PUNCTURED", "hud_obit_nova_gas", 64, 64, undefined, 0, 15 );
	}
}



/*------------------------------------
***/
hazmat_health_save_restore()
{
	wait_for_first_player();
	
	player = get_players()[0];
		
	if( player.hazmat_on )
	{
		player.hazmat_health = level.hazmat_health_max;
		
		player.hazmat_cracked = 0;
		clientnotify( "_gasmask_on_pristine" );
	}
	
	if(GetDvarInt("player_killed_in_hazmat") == 1)
	{
		player.hazmat_died = true;
		level thread special_autosave_null_achievement();
	}
}

hazmat_set_death_dvar( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	player = get_players()[0];
	
	died_in_gas_event = GetPersistentProfileVar( 2, 0 );
	
	if(died_in_gas_event == 1)
	{
		SetPersistentProfileVar( 2, 2 );
	}
	
}

special_autosave_null_achievement()
{
	wait(1);
	autosave_by_name("rebirth_leak_fail");
}

/*------------------------------------

self = the player in the hazmat suit
------------------------------------*/
hazmat_health_create_hudelem()
{
	self.hazmat_hudelem = NewClientHudElem( self ); 
	self.hazmat_hudelem.alignX = "left";
	self.hazmat_hudelem.alignY = "top";	
	self.hazmat_hudelem.horzAlign = "left";
	self.hazmat_hudelem.vertAlign = "top";
	self.hazmat_hudelem.x = 475;
	self.hazmat_hudelem.y = 337;
	self.hazmat_hudelem.foreground = true;
	self.hazmat_hudelem.alpha = 1;
	self.hazmat_hudelem.fontscale = 2;

	hudelem_string = "Hazmat: " + Int(self.hazmat_health);

	self.hazmat_hudelem SetText( hudelem_string );
}



ir_heat_shimmer()
{
	player = get_players()[0];
	
	player thread ir_watch_scope_use();
}

ir_watch_scope_use()
{
	while(true)
	{
		while( self PlayerAds() < 0.8 || self GetCurrentWeapon() != "enfield_mk_ir_sp" )
		{
			wait(0.5);
		}
		
		level thread ir_start_heat_shimmer();
		
		while( self PlayerAds() > 0.8 && self GetCurrentWeapon() == "enfield_mk_ir_sp" )
		{
			wait(0.5);
		}
		
		level thread ir_stop_heat_shimmer();
	}
}

ir_start_heat_shimmer()
{
	level endon( "stop_heat_shimmer" );
	ai = GetAIArray("axis", "allies");
	
	for( i = 0; i < ai.size; i++ )
	{
		ai[i].shimmer = Spawn("script_model", ai[i] GetTagOrigin( "J_SpineLower" ) );
		ai[i].shimmer.angles = ai[i] GetTagAngles( "J_SpineLower" );
		ai[i].shimmer SetModel("tag_origin");
		ai[i].shimmer LinkTo( ai[i] );
		PlayFXOnTag( level._effect["heat_shimmer"], ai[i].shimmer, "tag_origin" );
		ai[i].shimmer thread ir_stop_heat_shimmer_on_death( ai[i] );
	}
}

ir_stop_heat_shimmer()
{
	level notify( "stop_heat_shimmer" );
	ai = GetAIArray("axis", "allies");
	
	for( i = 0; i < ai.size; i++ )
	{
		if( IsDefined( ai[i] ) && IsDefined( ai[i].shimmer ) )
		{
			ai[i].shimmer Delete();
		}
	}	
}

ir_stop_heat_shimmer_on_death( ai )
{
	level endon( "stop_heat_shimmer" );
	
	ai waittill( "death" );
	
	self Delete();
}



/*------------------------------------------------------------------------------------------------------------
																								Helicopter Stuffs
------------------------------------------------------------------------------------------------------------*/

helicopter_watch_lockon( player, dist )
{	
	while( true )
	{
		if( IsDefined(player.stingerTarget) && self == player.stingerTarget )
		{					
			angles_up = (0, 0, 1);
			player_to_heli = VectorNormalize( self.origin - player.origin );	
			player_heli_cross = VectorCross( angles_up, player_to_heli );
			
			if ( RandomInt(2) % 2 )
			{
				goal_point = self.origin + ( player_heli_cross * dist );
				self SetVehGoalPos( goal_point, true );	
			}
			else
			{
				goal_point = self.origin - ( player_heli_cross * dist );
				self SetVehGoalPos( goal_point, true );				
			}
			
			self waittill( "goal" );
		}
		wait(.1);
	}
}


rebirth_reset_vehicle_damage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName)
{
	if( sMeansOfDeath != "MOD_PROJECTILE" && sMeansOfDeath != "MOD_PROJECTILE_SPLASH" )
	{
		iDamage = 0;
	}
	
	self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName, false);
}

vehicle_override_strela_only( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, damageFromUnderneath, modelIndex, partName )
{
	if( !level.is_btr_rail )
	{
		if( sMeansOfDeath != "MOD_PROJECTILE" && sMeansOfDeath != "MOD_PROJECTILE_SPLASH" )
		{
			iDamage = 0;
		}
	}
	
	// IPrintLn( sMeansOfDeath );
	return iDamage;
}



/*------------------------------------------------------------------------------------------------------------
																								Objectives
------------------------------------------------------------------------------------------------------------*/

//------------------------------------
// Update objectives and objective markers
gas_attack_objectives()
{
	flag_wait("event_gas_attack_start");

	level thread rb_objective_breadcrumb(level.obj_iterator, "event_gas_attack_breadcrumb_start");

	trigger_use("event_gas_attack_breadcrumb_start");

	flag_wait("event_gas_attack_get_strela");

	level.obj_iterator++;
	Objective_Add(level.obj_iterator, "active", &"REBIRTH_OBJECTIVE_3A");
	Objective_Set3D(level.obj_iterator, true);
	Objective_State(level.obj_iterator, "current");
	
	strela_struct = GetStruct("obj_find_sam", "targetname"); //GetEnt("trig_at_strela", "targetname");
	
	if(level.strela.classname == "weapon_strela_sp")	// In case it doesn't find the strela fast enough
	{
		strela_struct.origin = level.strela.origin;
	}

	Objective_Position(level.obj_iterator, strela_struct.origin);

	// wait till first heli is shot down
	level waittill("event_destroy_copter_done");

	// new string
	Objective_String(level.obj_iterator, &"REBIRTH_OBJECTIVE_3B");

	// weaver the cheerleader
	level.heroes[ "weaver" ] thread anim_single(level.heroes[ "weaver" ], "one_more");

	// wait till next chopper down
	level waittill("event_destroy_copter_done");

	SetCullDist( 0 );

	Objective_State(level.obj_iterator, "done");
	Objective_State(level.obj_iterator, "invisible");

	level.obj_iterator--;
	Objective_State(level.obj_iterator, "current");
}



/*------------------------------------------------------------------------------------------------------------
																								Spawn Functions
------------------------------------------------------------------------------------------------------------*/

//------------------------------------
// have the AI rush the player
gas_rusher_spawnfunc()
{
	self rush();
}

gas_hazmat_allies_spawnfunc(dist)
{
	// self.maxsightdistsqrd = dist * dist;
	self.maxVisibleDist = dist * dist;
	
	level waittill( "something" );
	
	self.maxVisibleDist = 8000*8000;
}

gas_weaver_squad_spawnfunc(goal_pos)
{
	self endon("death");

	self.goalradius = 32;
	self enable_cqbwalk();
	self SetGoalPos(goal_pos);

	self waittill("goal");
	self delete();
}

//#using_animtree("generic_human");
btr_crash_civs()
{
	//self UseAnimTree(#animtree);	
	self.team = "axis";
	self.animname = "generic";
	align_nodes = getstruct(self.target);
	death_anim = "gas_death_" + align_nodes.script_int;
	if( align_nodes.script_int == 2 )
	{
		death_anim = "gas_death_" + 1;
	}
	
	align_nodes anim_reach(self, death_anim);
	align_nodes thread anim_single_aligned(self, death_anim);
	// PlayFXOnTag(level._effect["gas_death_fumes"], self, "J_Head");
	if( is_mature() )
	{
		self SetClientFlag(0);
	}
	//level thread vignette(align_nodes, self, death_anim, false, 1, align_nodes.script_noteworthy);	
}

/*------------------------------------------------------------------------------------------------------------
																								Vignettes
------------------------------------------------------------------------------------------------------------*/

gas_attack_vignettes()
{
	level thread gas_attack_gas_house_death();	

	// spin off the gassed_civ watchers
	gas_death_trigs = GetEntArray("gassed_civ", "targetname");
	array_thread(gas_death_trigs, ::gas_attack_gas_death);
}

//--------------------------------------------
// Two guys walk into a house...and die... :(
#using_animtree("generic_human");
gas_attack_gas_house_death()
{
	trigger_wait("gas_attack_house_vignette");
	
	autosave_by_name( "rebirth_gas_house" );
//
//	align_node = GetStruct("gas_attack_gas_worker_death", "targetname");
//
//	gas_workers = [];
//	gas_workers[0] = rb_spawn_character("engineer_gas_yellow", align_node.origin, align_node.angles, "gas_worker_1");
//	gas_workers[0] UseAnimTree(#animtree);
//
//	gas_workers[1] = rb_spawn_character("engineer_gas_blue", align_node.origin, align_node.angles, "gas_worker_2");
//	gas_workers[1] UseAnimTree(#animtree);
//
//	vignette(align_node, gas_workers, "gas_death", false, 1, "house_gas_workers");
//	
//	trigger_wait( "gas_attack_spawn_weaver_btr" );
//	
//	gas_workers[0] Delete();
//	gas_workers[1] Delete();
}

gas_attack_gas_death()
{
	self waittill("trigger");

	// grab the align node which should be the target of this trigger
	align_nodes = GetStructArray(self.target, "targetname");
	death_guys = [];

	for (i = 0; i < align_nodes.size; i++)
	{
		// spawn the specified guy
		death_guys[i] = rb_spawn_character("engineer_gas_orange"/*align_nodes[i].script_string*/, align_nodes[i].origin, align_nodes[i].angles, "generic");
		death_guys[i] Detach( death_guys[i].hatmodel, "" );
		death_guys[i] Detach( death_guys[i].gearmodel, "" );
		// death_guys[i] Detach( death_guys[i].headmodel, "" );
		death_guys[i].hatmodel = undefined;
		death_guys[i].gearmodel = undefined;
		death_guys[i].headModel = "c_rus_engineer_head1_gas";
		death_guys[i] UseAnimTree(#animtree);

		death_anim = "gas_death_" + align_nodes[i].script_int;
		if( align_nodes[i].script_int == 2 )
		{
			death_anim = "gas_death_" + 1;
		}

		level thread vignette(align_nodes[i], death_guys[i], death_anim, false, 1, align_nodes[i].script_noteworthy);
		// PlayFXOnTag(level._effect["gas_death_fumes"], death_guys[i], "J_Head");
		if( is_mature() )
		{
			death_guys[i] SetClientFlag(0);
		}
	}
	
	delete_trig = GetEnt( self.script_string, "script_noteworthy" );
	delete_trig waittill( "trigger" );
	
	for( i = 0; i < death_guys.size; i++ )
	{
		death_guys[i] Delete();
	}
}

hazmat_guys_spawnfunc()
{
	if( !RandomInt(4) )
	{
		self.a.forcegasdeath = 1;
	}
	
	while( 1 )
	{
		self waittill( "damage", amount, attacker, dir, org, mod );
		if( mod == "MOD_MELEE" && isplayer( attacker ) )
		{
			self.a.forcegasdeath = 0;
			if( RandomInt(2) % 2 )
			{
				self.deathanim = %ai_deadly_wounded_gassedA_hit;
			}
			else
			{
				self.deathanim = %ai_deadly_wounded_gassedB_hit;
			}
		}
	}	
}
