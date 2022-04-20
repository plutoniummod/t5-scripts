#include common_scripts\utility;
#include maps\_utility;
#include maps\cuba_util;
#include maps\cuba_anim;
#include maps\_anim;
#include maps\_music;

#using_animtree ("generic_human");
start()
{
	// get heros
	level.bowman  = get_hero_by_name( "bowman" );
	level.woods   = get_hero_by_name( "woods" );
	level.friendlies = array( level.bowman, level.woods );
	
	get_players()[0].animname = "mason";

	// no random heat anims for woods and bowman	
	level.woods disable_heat();
	level.bowman disable_heat();

	level.woods.noHeatAnims  = 1;
	level.bowman.noHeatAnims = 1;

	// SUMEET_TODO - add dynamic speed logic
	array_func( level.friendlies, ::enable_cqbwalk );
	
	// timescale values
	level.ASSASIN_FAST_TIMESCALE = 1.7;
	level.ASSASIN_SLOW_TIMESCALE = 0.05;

	event_thread( "mansion", ::big_room_door_breach );

	flag_wait("big_room_door_breach_finished");

	event_thread( "mansion", ::assasination_main );

	flag_wait( "assasin:castro_assasinated" );

	// re-enable colors for escape
	level.woods  enable_ai_color();
	level.bowman enable_ai_color();

	autosave_by_name("castro_assasinated");
}


setup_assasination_flags()
{
	//flag_init("start_big_room_door_breach");		// set when its time to start the big room door breach
	//flag_init("big_room_woods_in_position");		// set when woods is in position for the big room door breach
	flag_init("big_room_player_ready");				// set when player is in position for the big room door breach
	flag_init("big_room_start_slowmo");				// set when we need to switch to slowmo
	flag_init("big_room_stop_slowmo");				// set when we need to switch from slowmo to regular timescale
	flag_init("big_room_mortor_hit");				// set when the morot is hit in big room breach
	flag_init("big_room_door_breach_finished");		
	flag_init ("big_room_player_really_ready");
	flag_init ("player_has_shotgun_on_breach");

	//flag_init( "assasin:woods_in_position" );		 	// set when woods is in stack up position
	flag_init( "player_stacked_up_for_assasination" );  // set when player gets into the trigger to stack up for castro assasination
	flag_init( "assasin:player_in_position" );		 // set when player gets into stack up position
	flag_init( "assasin:scenario_decided" );		 // set when one of the two assasination outcomes are decided
	flag_init( "player_took_invalid_shot" );		 // set when player shoots at invalid position on castro or woman
	flag_init( "assasin:woman_dead" );			 	 // set when woman with castro is dead
	flag_init( "assasin:castro_assasinated" );		 // set when castro is dead
	flag_init( "assasin:player_weapon_switched" );	 // set when player switches to ASP and lowready is set
	flag_init( "assasin:door_opened" );				 // set after assasination is done and woods shoots through the door
	flag_init ( "player_shot_twice" );           // set when player has shot 2 bullets in Castro room
}


// --------------------------------------------------------------------------------
// ---- assasination first door breach ----
// --------------------------------------------------------------------------------
big_room_door_breach()
{
	// this flag will either be set by woods as he gets near this room, or by the player
	flag_wait( "start_big_room_door_breach" );

	// make a save game
	autosave_by_name( "big_room_door_breach" );

	// SUMEET_TODO - tell darwin to modify this exploder
	//exploder( 650 );

	// get the door brech node
	door_breach_node = getstruct( "big_room_door_node", "targetname" );
	
	// timescale thinking
	level thread big_room_timescale();

	// big room ambience effects etc
	level thread big_room_breach_ambience();

	// enemies in the big room
	level thread big_room_brech_enemies_think();

	// door breach on woods
	level.woods thread big_room_door_breach_woods( door_breach_node );

	// door breach on player
	get_players()[0] thread big_room_door_breach_player( door_breach_node );
}

mansion_portals_show()
{
	flag_wait("start_big_room_door_breach");
	SetCellVisibleAtPos( (-512, 2272, 580) ); //breach room
	SetCellVisibleAtPos( (14, 2272, 574) ); // Castro room
	
}	


big_room_door_breach_woods( door_breach_node ) // self = woods
{
	// stop follwing friendly chains
	level.woods stop_following_nodes();
	
	// woods is super accurate for this breach, we want to make this one quick
	level.woods.perfectAim = 1;
	level.woods disable_react();
	level.woods disable_pain();

	// anim reach woods to the door for stacking up
	door_breach_node anim_reach_aligned( level.woods, "door_breach_big_room_wait" );
	
	// start playing the looping animation until player shows up
	door_breach_node thread anim_loop_aligned( level.woods, "door_breach_big_room_wait" );

	flag_set( "big_room_woods_in_position" );
	
	// Drawing cells that are turned off at level load
	level thread mansion_portals_show();
	
	//Turning off BC for the breaches
	battlechatter_off("allies");

	level.woods play_vo("stack_up");	// okay - stack up
	
	// nag loop to tell the player to get in position
	door_nag_array = create_woods_nag_array( "pre_assasination" );
	level.woods thread do_vo_nag_loop( "woods", door_nag_array, "big_room_player_ready", 4 );

	// objective on woods to stack-up
	set_objective( level.OBJ_COMPOUND, level.woods, "breach" );

	// wait for the player to get in position
	flag_wait( "big_room_player_really_ready" );

	set_objective(level.OBJ_COMPOUND);

	// play the animation
	level.woods anim_set_blend_out_time(.2);
	level.woods anim_set_blend_in_time(.2);
	door_breach_node anim_single_aligned( level.woods, "door_breach_big_room" );
	
	level.woods thread follow_path( "big_room_friendly_node" );

	// waittill breach is finished
	flag_wait("big_room_door_breach_finished");
	
	// objective back to follow
	set_objective( level.OBJ_COMPOUND, level.woods, "follow" );

	level.woods.perfectAim = 0;
	level.woods enable_react();
	level.woods enable_pain();
// 	level.woods anim_set_blend_out_time(undefined);
// 	level.woods anim_set_blend_in_time(undefined);
}

big_room_door_breach_player( door_breach_node ) // self = player
{
	// wait for woods to get in position
	flag_wait( "big_room_woods_in_position" );

	player = get_players()[0];

	// value, key, fov, ender, massage_string, flag, delete_trigger, button_press_required
	player look_at_and_use( "big_room_breach_trigger", "targetname", Cos( 60 ), undefined, undefined, "big_room_player_ready", true, false );


	// switch to asp and other player setup stuff
	player big_room_player_setup();

	// spawn the player model
	level.player_model = spawn_anim_model("player_hands");
	level.player_model.animname = "player_hands";	
	level.player_model Hide();
	
	// put the model in the first frame
	door_breach_node anim_first_frame( level.player_model, "door_breach_big_room" );
	wait(0.05);

	LERP_TIME = .8;

	// lerp player fov
	self thread lerp_fov_overtime( LERP_TIME, 45, true );

	//wait LERP_TIME;
	SetSavedDvar( "cg_cameraUseTagCamera", 0 );	
	player PlayerLinkTo( level.player_model, "tag_player", 0, 108, 15, 40, 5, 1 );

	wait .4;
	level.player_model Show();
	
	flag_set ("big_room_player_really_ready");

	door_breach_node anim_single_aligned( level.player_model, "door_breach_big_room" );
	//door_breach_node waittill("door_breach_big_room");

	// unlink the player
	player Unlink();

	self thread lerp_fov_overtime( 0.5, 65 );

	level.player_model Delete(); 

	// waittill ai in this room are dead
	waittill_ai_group_cleared( "big_room_enemies_group" );

	setsaveddvar( "cg_cameraUseTagCamera", 1 );

	// reset the player
	player big_room_player_reset();		

	// breach is finished
	flag_set("big_room_door_breach_finished");
}


big_room_brech_enemies_think()
{
	// get the door brech node
	door_breach_node = getstruct( "big_room_door_node", "targetname" );

	simple_spawn( "big_room_enemies", ::big_room_brech_enemies_think_internal, door_breach_node );
}

big_room_brech_enemies_think_internal( door_breach_node ) // self = enemy AI
{
	self endon("death");

	self DisableAimAssist();
	
	self thread magic_bullet_shield(); //SHolmes: So they cant take damage through the wall before the breach
		
	// allowed to kill these guys anytime
	self.allowDeath = 1;

	// guard that goes over the sofa, will only ragdoll if shot at, so he has a death function
	// its safe to do it here as there are max 3 actors who can get into ragdoll
	// all the other guards will play regular death
	if( self.animname == "big_room_guard3" )
		self.deathFunction = ::sofa_guard_ragdoll_death;
	
	// keep looping until door is opened
	door_breach_node thread anim_loop_aligned( self, "idle" );

	// wait until the door breach starts, then stop ignoring and run to a cover node
	flag_wait( "big_room_player_ready" );
	
	wait(4.6);//Sholmes tweak for new anim?
	
	// stop ignoring everyone and me
	self thread stop_magic_bullet_shield(); //god mode OFF
	self set_ignoreme( false );
	self set_ignoreall( false );
	door_breach_node anim_single_aligned( self, "attack" );
}

sofa_guard_ragdoll_death() // self = guard that goes over sofa
{
	self StartRagdoll(); 
	return true;
}

big_room_player_setup() // self = player
{
	self AllowStand( true );
	self AllowCrouch( false );
	self AllowProne( false );
	self AllowJump( false );
	self AllowMelee( false );
	self SetStance( "stand" );
	//self SetLowReady( true );
	self DisableWeapons();
	self DisableOffhandWeapons();
	
	// no weapon cycling until the breach is over
	self DisableWeaponCycling();

	// set depth of field settings on the player
	maps\createart\cuba_art::set_cuba_dof( "pre_assasination" );

	// save players current weapon, we will give this weapon back to the player once assasination is done
	weapon = self GetCurrentWeapon();
	
	size = WeaponClipSize( weapon );
	self SetWeaponAmmoClip( weapon, size );
	
	if(weapon == "ks23_sp")
	{
		flag_set ("player_has_shotgun_on_breach");
	}
	
}

big_room_player_reset() // self = player
{
	// reset DOF
	maps\createart\cuba_art::reset_cuba_dof();

	self AllowStand( true );
	self AllowCrouch( true );
	self AllowProne( true );
	self AllowJump( true );
	self AllowMelee( true );

	self EnableWeaponCycling();
}

big_room_lowready_off( guy )//player notetrack
{	
	player = get_players()[0];
	
	//wait (.35);

	//player SetLowReady( false );
	player EnableWeapons();
}

big_room_open_door( guy )//woods notetrack 
{	
	door = GetEnt( "guard_room_left", "targetname" );
	door playsound ("amb_wood_door_open_00");
	door RotateYaw( 120, 1 );
	//door ConnectPaths();

	door = GetEnt( "guard_room_right", "targetname" );
	door playsound ("amb_wood_door_open_01");
	door RotateYaw( -120, 1 );
	//door ConnectPaths();
}


big_room_start_slowmo( guy )//notetrack from enemy inside
{
	flag_set( "big_room_start_slowmo" );
}

big_room_timescale()
{
	flag_wait( "big_room_player_ready" );
	
	player = get_players()[0];
	
	//if player has a shottie, do alt timescale
	if(flag("player_has_shotgun_on_breach"))
	{
		clientNotify ("slow_down_nt");
		//IPrintLnBold("using alt timescale");
			// fast timescale while breaching in 
		timescale_tween( 1, 1.3, 0.2 );
	
		flag_wait( "big_room_mortor_hit" );
		
		//wait (.4);//SHolmes tweaking slowmo start for new anims. 
		
		timescale_tween( 1.3, 0.1, 0.1 );	
	
		// waittill until player shoots someone or some time
		player waittill_player_shoots();
		
		// stop slowmo
		flag_set( "big_room_stop_slowmo" );
		timescale_tween( 0.1, 1, 0.5 );
		return; 
	
	}	

	clientNotify ("slow_down_nt");
	// fast timescale while breaching in 
	timescale_tween( 1, 1.3, 0.2 );

	flag_wait( "big_room_mortor_hit" );

	//wait (.2);//SHolmes tweaking slowmo start for new anims. 
	
	timescale_tween( 1.3, 0.1, 0.1 );	

	// waittill until player shoots someone or some time
	level waittill_notify_or_timeout( "big_room_guard_shot", .85 );
	
	// stop slowmo
	flag_set( "big_room_stop_slowmo" );
	timescale_tween( 0.1, 1, 0.5 );
	clientNotify ("slow_down_stp");
}

// ambiance while the breach is going on
big_room_breach_ambience()
{
	// wait until the big room breach needs to start
	flag_wait("big_room_player_ready");

	// this will halt generic ambiant syst
	flag_set( "halt_mansion_ambiance" );

	// mortor hit explosion and plan whiz by
	mortor_point = getstruct( "big_room_breach_mortor", "script_noteworthy" );
	mortor_point thread big_room_plane_whizby();

	flag_wait( "big_room_mortor_hit" );

	// player effects
	level thread big_room_player_screen_shake_rumble();

	// custom ambience in the big room	
	big_room_breach_ambient_internal();
	
	// this will start ambiance thread in the mansion back up again
	flag_clear( "halt_mansion_ambiance" );
}

big_room_player_screen_shake_rumble()
{
	flag_wait( "big_room_mortor_hit" );

	player = get_players()[0];

	player PlayRumbleOnEntity( "damage_heavy" );

	Earthquake( 0.2, 2.5, player.origin, 100 );	
}

big_room_breach_ambient_internal()
{
	// get the windows to break at the same time
	glass_structs = getstructarray( "big_room_glass_structs", "targetname" );
	
	count = 0;
		
	// chandelier pulse point
	chandelier_pulse = getstruct( "big_room_breach_chandelier_point", "script_noteworthy" );
	
	// dust points
	dust_structs = 	getstructarray( "big_room_dust_point", "script_noteworthy" );
	
	// generic pulses
	generic_pulses = getstructarray( "big_room_pulse_points", "script_noteworthy" );
	
	while(count < 3)
	{		
		count++;
			
		flag_wait( "big_room_mortor_hit" );

		// chandelier special pulse
		chandelier_pulse thread big_room_chandelier_pulse();

		// electric pulses
		level thread big_room_ambient_electric_pulse();
	
		array_thread( glass_structs, ::play_glass_break_effect );

		// dust effects
		array_thread( dust_structs, ::big_room_dust_spill );
		
		// pulse
		array_thread( generic_pulses, ::big_room_generic_pulse );

		wait(1);
	}
	
}		

big_room_plane_whizby()
{
	// TUEYS SOUND MAGIC
	sound_ent_jet = spawn ("script_origin", self.origin);
	sound_ent_jet MoveTo((2776, 5896, -816), 1.5);	
	sound_ent_jet PlaySound ("evt_f4_short_apex", "sound_done");	
	
	flag_wait("big_room_start_slowmo");
	
	sound_ent_jet.origin = self.origin;
	sound_ent_jet PlaySound( "prj_mortar_incoming", "sounddone" ); 

	playsoundatposition ("exp_mortar_mansion", sound_ent_jet.origin);
	
	// notifying this to play the rattle sounds
	level notify ("mansion_exp_hit");	

	flag_set( "big_room_mortor_hit" );

	sound_ent_jet Delete();
}


big_room_chandelier_pulse()
{
	PhysicsExplosionCylinder( self.origin, 100, 50, 1.5 );	
}

big_room_ambient_electric_pulse()
{
	if( IsDefined( level.big_room_electric_pulse_started ) )
		return;

	level.big_room_electric_pulse_started = true;
		
	point = getstruct( "big_room_electric_points_start", "targetname" );

	while(1)
	{
		RadiusDamage( point.origin, 100, 100, 50, get_players()[0], "MOD_RIFLE_BULLET", "m16_sp" );

		if( !IsDefined( point.target ) )
			break;
		else
			point = getstruct( point.target, "targetname" );

		wait(0.05);
	}
}


play_glass_break_effect( total_count )
{	
	if( !IsDefined( total_count ) )
		total_count = 2;

	count = 0;

	while( count < total_count )
	{	
		count++;

		PlayFX( level._effect["breach_glass_window"], self.origin, self.angles );	
		playsoundatposition ("evt_shutter_slam", self.origin);	
		playsoundatposition ("dst_generic_glass_med", self.origin);
		
		wait(0.1);
	}
}

big_room_dust_spill()
{
	PlayFX( level._effect[ "dust_heavy" ], self.origin, ( 90, 0, 0 ) );
	Playsoundatposition("dst_dust_debris", self.origin);
}

big_room_generic_pulse()
{
	inner_radius = 10;
	outer_radius = 50;
	inner_damage = 100;
	outer_damage = 70;

	
	if( IsDefined( self.script_string ) && self.script_string == "cylinder" )	
	{
		PhysicsExplosionCylinder( self.origin, outer_radius, inner_radius, self.script_int );
	}

	PhysicsExplosionSphere( self.origin, outer_radius, inner_radius, 2, outer_damage, inner_damage );
}

// --------------------------------------------------------------------------------
// ---- Castro assasination main function ----
// --------------------------------------------------------------------------------
assasination_main() // self = woods
{

	// dialogue before the assasination starts
	//SHolmes - Dont want woods standing still during this VO per notes. 
	level thread assasination_dialogue();

	//deletes script_brushmodel weaponclip in front of castro when player gets in position	
	level thread castro_bullet_shield();

	// get the animation reference node for assasination
	assasin_anim_node = getstruct( "castro_node", "targetname" );
	
	// timescale changes
	level thread assasination_time_scale();

	// assasination ambiance
	level thread assasination_ambience();

	// door guards
	level thread assasination_door_guards( assasin_anim_node );
	
	// woods 
	level.woods thread assasination_woods( assasin_anim_node );
		
	// wait for woods to get into position
	flag_wait( "assasin:woods_in_position" );

	// start animating player
	get_players()[0] thread assasination_player( assasin_anim_node );

	// spawn in Castro and woman
	level.castro 	   = simple_spawn_single( "castro" );
	level.castro_woman = simple_spawn_single( "castro_woman" );
			
	// start animating castro and woman
	level.castro thread assasination_castro( assasin_anim_node );
	level.castro_woman thread assasination_woman( assasin_anim_node );
	
	stream_helper = createStreamerHint (level.castro_woman.origin, 1.0);
	
	// wait until castro is assasinated
	flag_wait( "assasin:castro_assasinated" );
	
	stream_helper Delete();

	// turn on battlechatter
	battlechatter_on();
	
	setsaveddvar( "cg_cameraUseTagCamera", 1 );
}

assasination_dialogue()
{
	wait(2);
	
	level.woods play_vo( "nest_empty" ); 			 //Bowman - Nest is empty. We're moving on.
	level.bowman play_vo( "bettermake_it_fast" ); 	 //Better make it fast. B26's are about to begin their bombing run.
	level.woods play_vo( "target_should_be_ahead" ); //Target should be up ahead
	get_players()[0] play_vo( "roger" ); 			 //Roger.
	
	
	level.woods play_vo("movement_inside"); 		//Movement inside. Get in position.
	level.woods play_vo("get_in_position"); 	
}

// --------------------------------------------------------------------------------
// ---- Castro assasination additional functions ----
// --------------------------------------------------------------------------------

assasination_time_scale()
{
	flag_wait( "assasin:player_in_position" );
		
	//TUEY Set music to CASTRO_ASSASSINATION
	setmusicstate ("CASTRO_ASSASSINATION");
	
	level.castro_woman playsound("evt_hooker_scream");
	
	clientNotify( "slow_down" );//kevin adding notifies for time scale
	timescale_tween( 1, level.ASSASIN_FAST_TIMESCALE, 0.2 );
	
	flag_wait( "assasin:scenario_decided" );
	
	if( !is_true( level.castro.in_bulletcam ) )
		timescale_tween( level.ASSASIN_SLOW_TIMESCALE, 1, 0.1 );
	//clientnotify("blt_imp");// bullet cam will take care of this
}

assasination_ambience()
{
	flag_wait( "assasin:player_in_position" );

	wait(0.8);

	// electric pulses
	electric_pulse = getstruct( "castro_room_electric_point", "script_noteworthy" );
	RadiusDamage( electric_pulse.origin, 100, 100, 50, get_players()[0], "MOD_RIFLE_BULLET", "m16_sp" );

	// dust effects
	dust_structs = 	getstructarray( "castro_room_dust_point", "script_noteworthy" );
	array_thread( dust_structs, ::big_room_dust_spill );	
	
	//generic pulses
	generic_pulses = getstructarray( "castro_room_dust_point", "script_noteworthy" );
	array_thread( generic_pulses, ::big_room_generic_pulse );
	
	wait(1);

	chandelier_pulse = getstruct( "castro_room_chandelier_point", "script_noteworthy" );

	// TUEYS SOUND MAGIC
	sound_ent_jet = spawn ("script_origin", chandelier_pulse.origin);
	sound_ent_jet MoveTo((2776, 5896, -816), 1.5);	
	sound_ent_jet PlaySound ("evt_f4_short_apex", "sound_done");	
		
	sound_ent_jet.origin = chandelier_pulse.origin;
	sound_ent_jet PlaySound( "prj_mortar_incoming", "sounddone" ); 

	playsoundatposition ("exp_mortar_mansion", sound_ent_jet.origin);
	
	// notifying this to play the rattle sounds
	level notify ("mansion_exp_hit");	

	sound_ent_jet Delete();

	// chandelier special pulse
	chandelier_pulse thread big_room_chandelier_pulse();
		
	wait(0.2);

	// get the windows to break at the same time
	glass_structs = getstructarray( "castro_room_glass_structs", "targetname" );
	array_thread( glass_structs, ::play_glass_break_effect, 2 );

}
	

assasination_open_door( guy )
{	
	flag_set( "assasin:player_in_position" );

	door = GetEnt( "castro_bedroom_door", "targetname" );
	door RotateYaw( 130, .8 );
	door playsound ("amb_door_open_wood");
	door waittill( "rotatedone" );
	//door ConnectPaths();
}


post_assasination_open_door( guy )
{
	right_door = GetEnt( "woods_door_balcony", "targetname" );
	right_door playsound ("amb_door_open_wood_00");
	right_door RotateYaw( 140, 4, 1.5, 1 );
	//right_door ConnectPaths();

	left_door = GetEnt( "woods_left_door_balcony", "targetname" );
	left_door playsound ("amb_door_open_wood_01");
	left_door RotateYaw( -140, 4, 1.3, 1 );
	//left_door ConnectPaths();
	
	flag_set( "assasin:door_opened" );	
}

monitor_assasination_scenario( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime ) // self = castro / woman
{
	if( IsPlayer( eAttacker ) && !flag( "assasin:scenario_decided" ) )
	{
		//IPrintLnBold( "Damage " + self.targetname + " " + sHitLoc );
	
		// check if this was a valid shot
		if( !self is_valid_hitloc( sHitLoc ) )
		{
			//IPrintLnBold( sHitLoc + " Invalid hitloc" );
			flag_set( "player_took_invalid_shot" );
			return 0;
		}

		// check if this was a bulletcam shot
		force_bullet_cam_on_castro = is_bulletcam_hitloc( sHitLoc );
		//clientNotify( "blt_st" );	// bullet cam will take care of this
		if( self == level.castro )	
		{
			if( force_bullet_cam_on_castro )
			{
				//IPrintLnBold( "Damage " + self.targetname + " " + sHitLoc );
				//IPrintLnBold( "enabling bulletcam" );
				setsaveddvar( "cg_cameraUseTagCamera", 1 );
				get_players()[0] SetClientDvar( "cg_fov", 65 );
				
				// unlink the player
				get_players()[0] Unlink();
		
				self maps\_bulletcam::enable( true );
			}
			else
			{
				//IPrintLnBold( "Damage " + self.targetname + " " + sHitLoc );
				//IPrintLnBold( "waiting" );
				waittillframeend;
			}	
			
			if( !flag( "assasin:scenario_decided" )  )
			{
				//IPrintLnBold( "Setting" );	
				self.assasin_damaged_by_player = true;
				flag_set( "assasin:scenario_decided" );
			}
		}
		
		if( self == level.castro_woman )
		{		
			//IPrintLnBold( "Damage " + self.targetname + " " + sHitLoc );
	
			if( force_bullet_cam_on_castro )
			{
				//IPrintLnBold( "enabling bulletcam" );
				setsaveddvar( "cg_cameraUseTagCamera", 1 );
				get_players()[0] SetClientDvar( "cg_fov", 65 );

				// unlink the player
				get_players()[0] Unlink();

				level.castro maps\_bulletcam::enable( true );
				level.castro.assasin_damaged_by_player = true;	
			}
			else
			{
				self.assasin_damaged_by_player = true;
			}

			flag_set( "assasin:scenario_decided" );

		}
		else
		{
			//IPrintLnBold( "Setting" );	
			
			flag_set( "assasin:scenario_decided" );
		}
	}

	return iDamage;
}


is_valid_hitloc( sHitLoc ) // self = castro/woman
{
	//IPrintLnBold( "Checking validity " + sHitLoc );

	// woman was hit
	if( self == level.castro_woman )
	{
		if( sHitLoc == "left_arm_upper" ||
			sHitLoc == "left_arm_lower" ||
			sHitLoc == "left_hand"		||
			sHitLoc == "head"			||
			sHitLoc == "helmet"
		  )
		  return false;	
	}
		
	if( sHitLoc != "left_leg_upper" 	&& 
		sHitLoc != "left_leg_lower" 	&& 
		sHitLoc != "left_foot" 			&&
		sHitLoc != "right_leg_upper" 	&&
		sHitLoc != "right_leg_lower" 	&&	
		sHitLoc != "right_foot"
	  )
      return true;

	return false;	
}

is_bulletcam_hitloc( sHitLoc ) // self = castro/woman
{
	if( self == level.castro ) 
	{
		// castro was hit	
		if( sHitLoc == "helmet" || 
			sHitLoc == "head" || 
			sHitLoc == "neck"|| 
			sHitLoc == "right_arm_upper" 
		  )
		  return true;
	}
	else
	{
		// woman was hit
		if( sHitLoc == "neck"|| 
			sHitLoc == "right_arm_upper"
		  )
           return true;
	}
	
	//IPrintLnBold( sHitLoc + " Invalid bulletcam hitloc" );

	return false;
}

// --------------------------------------------------------------------------------
// ---- Assasination - Player ----
// --------------------------------------------------------------------------------

assasination_player( assasin_anim_node ) // self = player
{
	player = get_players()[0];

	// value, key, fov, ender, massage_string, flag, delete_trigger, button_press_required
	player look_at_and_use( "assasination_trigger", "targetname", Cos( 60 ), undefined, undefined, "player_stacked_up_for_assasination", true, false );

	// this will halt ambiance thread in the mansion during the assasination
	flag_set( "halt_mansion_ambiance" );

	// save the game here
	//autosave_by_name( "assasination_start" ); //Sholmes:Removing
	
	player Assasination_Player_Setup();

	player SetClientDvar("sv_clientSideBullets", 0);
			
	//flag_set( "assasin:player_weapon_switched" );
	
	setsaveddvar( "cg_cameraUseTagCamera", 0 );
	player StartCameraTween( .4 );
	setdvar( "bg_gunXOffset", 100 );
	wait .05;

	// spawn the player model
	level.player_model = spawn_anim_model("player_hands");
	level.player_model.animname = "player_hands";	
	level.player_model Hide();
	
	
	
	// put the model in first frame
	assasin_anim_node anim_first_frame( level.player_model, "assasination_part1" );

	// lerp the player to the position
	//player lerp_player_view_to_position( level.player_model GetTagOrigin( "tag_player" ), level.player_model GetTagAngles( "tag_player" ), 0.5 );

	player thread assasination_player_fov();

	wait .6;
	
	player PlayerLinkTo( level.player_model, "tag_player", 0, 20, 20, 20, 20, 0 );
	level.player_model Show();	

	target_struct = getstruct( "assasination_target_pos", "targetname" );
	player SetPlayerAngles( flat_angle( VectorToAngles( target_struct.origin - level.woods.origin ) ) );
	
	// set depth of field settings on the player
	maps\createart\cuba_art::set_cuba_dof( "assasination" );

	// fov changes for assasination
	//player thread assasination_player_fov();
	
	flag_set( "assasin:player_weapon_switched" );
	
	wait(.05);
	
	assasin_anim_node thread anim_single_aligned( level.player_model, "assasination_part1" );
	
	self thread monitor_player_bullets();//SHolmes tracking for achievment logic

	// wait until the assasination scenario is decided	
	flag_wait( "assasin:scenario_decided" );	

	// reset DOF
	maps\createart\cuba_art::reset_cuba_dof();
	
	setdvar( "bg_gunXOffset", 0 );

	// delete the player model
	level.player_model Hide();
	
	// if its the bulletcam then wait for it to finish
	if( is_true( level.castro.in_bulletcam ) && !flag("player_shot_twice") )  
	{
		get_players()[0] ent_flag_wait("_bulletcam:end");
		
		// if player didnt take a invalid shot then give an achievement
		if( !flag( "player_took_invalid_shot" ) )
			player giveachievement_wrapper( "SP_LVL_CUBA_CASTRO_ONESHOT" );
	}
	
	player SetClientDvar("sv_clientSideBullets", 1);
	
	// unlink the player
	player Unlink();
	
	// clearing this flag will re-start the ambiance in the mansion
	flag_clear( "halt_mansion_ambiance" );

	player assasination_player_reset();
	
	// delete the player model
	if( IsDefined( level.player_model ) )
	{
		level.player_model Delete();
	}
	
	
}

castro_bullet_shield()
{
	wall = GetEnt ("castro_bullet_wall", "targetname");
	flag_wait ("player_stacked_up_for_assasination");
	wall Delete();

}	


monitor_player_bullets()
{
	//self = player
	//sets a flag when player shoots 2 times during castro 
	full_count = self GetCurrentWeaponClipAmmo();
	shot_twice = full_count -2;
	level endon ("assasin:door_opened");
	while(1)
	{
		self waittill_player_shoots("any", "assasin:door_opened");
		current_count = self GetCurrentWeaponClipAmmo();
		if(current_count == shot_twice)
		{
			flag_set ("player_shot_twice");
		}	
	}	
	
}	

assasination_player_setup() // self = player
{
	self EnableInvulnerability();

	self AllowStand( true );
	self AllowCrouch( false );
	self AllowProne( false );
	self AllowJump( false );
	self AllowMelee( false );
	self SetStance( "stand" );
	
	// save the current weapon so that we can switch back to it
	self.assasination_last_weapon = self GetCurrentWeapon();

	// give special castro assasination weapon
	self GiveWeapon( "asp_sp_castro" );
	self SwitchToWeapon( "asp_sp_castro" );
	self DisableWeaponCycling();
	self SetLowReady( true );
	self AllowAds( false );
	
}

assasination_player_reset() // self = player
{
	self AllowStand( true );
	self AllowCrouch( true );
	self AllowProne( true );
	self AllowJump( true );
	self AllowMelee( true );
	self EnableOffhandWeapons();

	self EnableWeaponCycling();
	self SwitchToWeapon( self.assasination_last_weapon );

	// take the special assasination weapon back
	self TakeWeapon( "asp_sp_castro" );

	self DisableInvulnerability();
}

assasin_lowready_off( guy )
{	
	player = get_players()[0];

	// set lowready off	
	player SetLowReady( false );
	
	wait(.10);
	
	player AllowAds( true );
}

assasination_player_fov() // self = player
{
	basefov = GetDvarFloat( #"cg_fov" );

	// lerp players FOV closer to Castro
	self thread lerp_fov_overtime( 1, 45, true );

	// wait until assasination scenario is decided
	flag_wait( "assasin:scenario_decided" );

	//level notify("stop_lerping_thread");
	self thread lerp_fov_overtime( 0.5, basefov );
}

post_assasination_player_response( guy )
{
	get_players()[0] play_VO( "supporters_fanatics" );
}

// --------------------------------------------------------------------------------
// ---- Assasination - Woods ----
// --------------------------------------------------------------------------------

assasination_woods( assasin_anim_node ) // self = woods
{
	wait(2);
	
	self LookAtEntity();
	
	// anim reach woods to the door for stacking up
	assasin_anim_node thread anim_reach_aligned( level.woods, "assasination_wait" );
	//assasination_arrival assasination_wait
	
	// woods goes towards the door while saying this
	//level thread assasination_woods_door_dialogue();
	
	level.woods waittill ("goal");

	// objective on woods to stack-up
	set_objective( level.OBJ_COMPOUND, level.woods, "breach" );
			
	flag_set( "assasin:woods_in_position" );
	
	level thread castro_nag_loop_delay(); //SHolmes: delaying VO Nag to prevent VO overlaps here
	

	//assasin_anim_node anim_single_aligned( level.woods, "assasination_arrival"); //SHolmes new arrival anim 
	assasin_anim_node thread anim_loop_aligned( level.woods, "assasination_wait" );
	
	flag_wait( "assasin:player_weapon_switched" );
	
	self DisableClientLinkto();//Fix for odd anim stutter issue
	
	//remove 3d objective until breach is done
	set_objective( level.OBJ_COMPOUND );

	level.woods anim_set_blend_out_time(.2);
	level.woods anim_set_blend_in_time(.2);
	
	assasin_anim_node thread anim_single_aligned( level.woods, "assasination_part1" );
	
	flag_wait( "assasin:scenario_decided" );		

	if( IsDefined( level.castro.assasin_damaged_by_player ) && level.castro.assasin_damaged_by_player )
	{
		// castro was shot
		assasin_anim_node anim_single_aligned( level.woods, "assasination_part2b" );
	}
	else if( IsDefined( level.castro_woman.assasin_damaged_by_player ) && level.castro_woman.assasin_damaged_by_player )
	{
		// woman was shot
		assasin_anim_node anim_single_aligned( level.woods, "assasination_part2a" );
	}
	else
	{
		// player was shot, mission fail
	}
		
	flag_set( "assasin:castro_assasinated" );
	
	self EnableClientLinkto();
	level.woods anim_set_blend_out_time(undefined);
	level.woods anim_set_blend_in_time(undefined);
}

castro_nag_loop_delay()
{
	
	wait(6);
	
	if(!flag("assasin:player_weapon_switched")) //If player is not in position
	{
		// nag loop to tell the player to get in position
		castro_nag_array = create_woods_nag_array( "assasination" );
		level.woods thread do_vo_nag_loop( "woods", castro_nag_array, "player_stacked_up_for_assasination", 7 );
	}
	
}		
	

/* SHolmes combining this with previous VO for eay timing
assasination_woods_door_dialogue()
{
	wait(2);

	level.woods play_vo("movement_inside"); 		//Movement inside. Get in position.
	level.woods play_vo("get_in_position"); 		//mason - get in position.		
}
*/

// --------------------------------------------------------------------------------
// ---- Assasination - Castro ----
// --------------------------------------------------------------------------------

assasination_castro( assasin_anim_node ) // self = castro
{	
	// not fully killable until shot	
	self magic_bullet_shield();

	// disable aim assist on castro
	self DisableAimAssist();

	self.ignoreme = true;
	self.ignoreall = true;

	// blends for scripted animations
	self anim_set_blend_in_time(0.2);
	self anim_set_blend_out_time(0.2);

	// setup bulletcam for a successful castro kill
	self setup_bulletcam();

	self.deathfunction = ::emtpy_castro_kill;
	
	self.a.disableLongDeath = true;

	flag_wait( "assasin:player_weapon_switched" );

	// function to track damage
	self.overrideActorDamage	= ::monitor_assasination_scenario;	//SHolmes moving this  to after the above flag to prevent early Castro deaths

	// part 1 animation - grabbing the girl
	assasin_anim_node thread anim_single_aligned( self, "assasination_part1" );
		
	flag_wait( "assasin:scenario_decided" );
		
	if( IsDefined( self.assasin_damaged_by_player ) && self.assasin_damaged_by_player )
	{
		// castro is shot
		wait(0.3);
		self stop_magic_bullet_shield();
		assasin_anim_node anim_single_aligned( self, "assasination_part2b" );	
	}
	else
	{
		self stop_magic_bullet_shield();
		assasin_anim_node anim_single_aligned( self, "assasination_part2a" );	
	}

	// keep playing death loop
	assasin_anim_node thread anim_loop_aligned( self, "death_loop" );
	

	// wait for player to go out in the courtyard
	flag_wait( "player_in_courtyard" );

	// now kill castro
	if( IsDefined( self ) && IsAlive( self ) )
	{	
		self maps\_bulletcam::enable( false );
		self.allowdeath = true;
		self StartRagdoll();
		self DoDamage( self.health + 100, self.origin );
	}
}

#using_animtree ("animated_props");
setup_bulletcam()
{
	// setup bulletcam on castro
	level.BULLET_ANIM_CAM = %prop_meatshield_bullet_tip_cam_cuba;
	self maps\_bulletcam::set_end_distance_from_target( 10 );
	self maps\_bulletcam::set_hold_distance_on_target_death( 7 );	
	
	self.bulletcam_nodeath = 1;
}
	
#using_animtree ("generic_human");
emtpy_castro_kill()
{
	
}

// castro misses first three shots on the player
castro_miss_player( castro )
{
	// if player took a invalid shot then kill player instantly
	if( flag( "player_took_invalid_shot" ) )
	{
		castro_kill_player( level.castro );
		return;
	}
		
	start_origin = castro GetTagOrigin( "tag_flash" );
	
	miss_pos = getstructarray( "castros_bullet_pos", "targetname" );
	end_origin = miss_pos[RandomIntRange( 0, miss_pos.size )].origin;

	BulletTracer( start_origin, end_origin, 1 );
	MagicBullet( castro.weapon, start_origin, end_origin );

	// slow to the timescale
	if( !IsDefined( level.timescale_changed ) )
	{
		level.timescale_changed = true;	
		thread timescale_tween( level.ASSASIN_FAST_TIMESCALE, level.ASSASIN_SLOW_TIMESCALE, 0.2 );
	}
}


// castro kills the player with last shot
castro_kill_player( castro )
{
	// we dont want to kill player if the scenario is decided
	if( flag( "assasin:scenario_decided" ) )
		return;
	
	player = get_players()[0];
	player DisableInvulnerability();
	player DisableWeapons();

	start_origin = castro GetTagOrigin( "tag_flash" );
	start_angles = castro GetTagAngles( "tag_flash" );
	end_origin = start_origin + vector_scale( AnglesToForward( start_angles ), 100 );
	SetTimeScale( 0.2 );
	
	BulletTracer( start_origin, end_origin, 1 );
	MagicBullet( castro.weapon, start_origin, end_origin );

	player DoDamage( player.health + 100, castro.origin );
		
	//SHolmes removing death quote per notes	
	mission_failed();
}

// feathers on the bed when castro is shot again by woods
castro_bed_feathers( guy )
{
	exploder( 680 );
}

// --------------------------------------------------------------------------------
// ---- Assasination - Woman ----
// --------------------------------------------------------------------------------
assasination_woman( assasin_anim_node ) // self = woman
{
	// not fully killable until shot	
	self magic_bullet_shield();

	// disable aim assist on woman
	self DisableAimAssist();

	self.ignoreme = true;
	self.ignoreall = true;

	// remove gun, she will pick up if needed
	self gun_remove();
	self thread woman_setup_gun( assasin_anim_node );

	// blends for scripted animations
	self anim_set_blend_in_time(0.2);
	self anim_set_blend_out_time(0.2);

	// function to track damage
	self.overrideActorDamage	= ::monitor_assasination_scenario;	

	self.a.disableLongDeath = true;

	flag_wait( "assasin:player_weapon_switched" );

	// part 1 animation - grabbing the girl
	assasin_anim_node thread anim_single_aligned( self, "assasination_part1" );
		
	flag_wait( "assasin:scenario_decided" );

	if( IsDefined( self.assasin_damaged_by_player ) && self.assasin_damaged_by_player )
	{
		// woman is shot - kill her
		self stop_magic_bullet_shield();
		assasin_anim_node anim_single_aligned( self, "assasination_part2a" );
	}
	else
	{
		// castro was shot -  woman grabs the gun	
		self.overrideActorDamage	= undefined;
		self.allowdeath = true;
		self stop_magic_bullet_shield();
		assasin_anim_node anim_single_aligned( self, "assasination_part2b" );
	}
	
	flag_set( "assasin:woman_dead" );	
}

#using_animtree( "cuba" );
woman_setup_gun( assasin_anim_node ) // self = woods/bowman
{
	woman_gun = Spawn( "script_model", ( 0,0,0 ) );
	woman_gun SetModel( "t5_weapon_ks23_world" );

	// spawn a special model that will animate the crossbow and put it in right place
	woman_gun_anim_model = spawn_anim_model( "woman_gun" );
	woman_gun_anim_model.animname = "woman_gun";

	woman_gun LinkTo( woman_gun_anim_model, "origin_animate_jnt", (0,0,0), (0,0,0) );
	
	assasin_anim_node thread anim_loop_aligned( woman_gun_anim_model, "setup" );

	// this notify is sent by anim gun hand notetrack
	self waittill( "placed_weapon_on_right" );

	woman_gun Delete();
	woman_gun_anim_model Delete();	
}

// --------------------------------------------------------------------------------
// ---- Assasination - Door guards ----
// --------------------------------------------------------------------------------
#using_animtree( "generic_human" );
assasination_door_guards( assasin_anim_node )
{
	// spawn guards at the door
	assasin_anim_node = getstruct( "castro_node", "targetname" );	
	assasin_door_guards = simple_spawn( "assasin_door_guards" );

	array_func( assasin_door_guards , ::magic_bullet_shield );

	flag_wait( "assasin:scenario_decided" );
	
	//SHolmes delaying to increase likelihood of player spotting them 
	wait(5);
	
	// send guys to door
	// SOUND Theyre supposed to be yelling and banging here plz
	level thread banging_on_door_audio();
	assasin_anim_node thread anim_reach_aligned( assasin_door_guards, "door_death" );
	
	//spawn AA gun outside
	level thread maps\cuba_escape::setup_balcony_aa_gun();
	
	flag_wait( "assasin:door_opened" );

	array_func( assasin_door_guards , ::stop_magic_bullet_shield );

	// now play death animations
	assasin_anim_node anim_single_aligned( assasin_door_guards, "door_death" );
}

banging_on_door_audio()
{
	
	door = getent( "woods_left_door_balcony" , "targetname" );
	wait 4;
	door playsound( "evt_door_knock" );
}
	