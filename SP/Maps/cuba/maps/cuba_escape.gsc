#include common_scripts\utility;
#include maps\_utility;
#include maps\cuba_util;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_music;
#include maps\_flyover_audio;

start()
{
	Assert( getTimeScale() == 1 );
	
	set_objective( level.OBJ_ESCAPE, get_hero_by_name( "woods" ), "follow" );
	
	level thread balcony_engagement();
	level thread squad_sprint();
	
	level thread bowman_entrance();
	level thread mansion_lobby();
	level thread mansion_building_bomb();
	level thread outside_courtyard_mortars();
	level thread squad_at_steps();
	level thread monitor_mansion_exit();
	level thread btr_collision_think();

	flag_set( "player_inside_mansion" );
	
	level.woods = get_hero_by_name( "woods" );
	level.bowman = get_hero_by_name( "bowman" );

	setup_nag_lines();
	
	trigger_wait( "start_airfield_scripts", "script_noteworthy" );

	get_players()[0] SetClientDvar("player_sprintUnlimited", 0);
	
	heroes = get_heroes_by_name("woods", "bowman");
	array_func( heroes, ::clear_run_anim ); //clears hero sprint run anim

	cleanup();

}


courtyard_baddies_logic()
{
	if( GetDifficulty() == "easy" )
	{		
		self.script_accuracy = .1;
		self.health = self.health -100;
	}	
	else
	{
		self.script_accuracy = .6;
		self.health = self.health -20;
	}		
}	

setup_nag_lines()
{
	//woods generic nag
	level.generic_nag = [];
	level.generic_nag[0] = "mason_on_me";
	level.generic_nag[1] = "escape_nag5";//mason!  come on!!!
	level.generic_nag[2] = "get_fuck_outta_here";
	level.generic_nag[3] = "cant_stay";

	level.courtyard_nag_lines = [];
	level.courtyard_nag_lines[0] = "go_outside";
	level.courtyard_nag_lines[1] = "escape_nag5";//mason!  come on!!!
	level.courtyard_nag_lines[2] = "hook_up_go";

	level.sugarcane_nag_lines = [];
	level.sugarcane_nag_lines[0] = "through_gate";
	level.sugarcane_nag_lines[1] = "dont_have_time";
	level.sugarcane_nag_lines[2] = "get_fuck_outta_here";
}



#using_animtree("vehicles");
balcony_engagement()
{
	
	level thread ambient_high_bombers( "balcony_ambient_bomber_struct_paths", "stop_balcony_bombers" );

	level thread balcony_breachers();
/*
	//roof aa gun
	level.balcony_roof_aa_gun = spawn_vehicles_from_targetname( "balcony_roof_aa_gun" )[0];
	level.balcony_roof_aa_gun veh_magic_bullet_shield( 1 );
	level.balcony_roof_aa_guy = simple_spawn_single( "balcony_roof_aa_guy" );
	level.balcony_roof_aa_guy thread init_aa_guy( level.balcony_roof_aa_gun );
	level.balcony_roof_aa_guy thread monitor_aa_guy_death( level.balcony_roof_aa_gun );
	//level.balcony_roof_aa_guy thread magic_bullet_shield();

	balcony_roof_targets = GetEntArray( "balcony_roof_targets", "targetname" );
	level.balcony_roof_aa_gun thread start_aa_gun( balcony_roof_targets , "wpn_btr_fire_loop_balc" , "wpn_btr_fire_loop_ring_npc_balc" );
*/
	//simple_spawn( "roof_enemies", ::init_roof_enemies );

	level thread escape_dialogue();
	level thread woods_shoots_balcony_door();

	trigger_wait( "start_crashing_plane" );

	//starts the flight path of the crashing plane
	level thread balcony_crashing_plane(level.balcony_roof_aa_gun,level.balcony_roof_aa_guy);
	
	exploder(430);
	wait(1.5);
	exploder(431);

	//sets up and starts threads in the mansion
	//level thread mansion_lobby();

	//vehicle convoy
	front_jeep = spawn_vehicles_from_targetname( "front_jeep" )[0];
	front_jeep thread go_path( GetVehicleNode(front_jeep.target,"targetname") );
	front_jeep veh_magic_bullet_shield( 1 );
	
	wait (RandomIntRange(3,5) );

	second_jeep = spawn_vehicles_from_targetname( "second_jeep" )[0];
	second_jeep thread go_path( GetVehicleNode(second_jeep.target,"targetname") );
	second_jeep veh_magic_bullet_shield( 1 );
	
	wait (RandomIntRange(3,5) );

	balcony_btr_1 = spawn_vehicles_from_targetname( "balcony_btr_1" )[0];
	balcony_btr_1 thread go_path( GetVehicleNode(balcony_btr_1.target,"targetname") );
	balcony_btr_1 veh_magic_bullet_shield( 1 );
	
	wait (RandomIntRange(3,5) );

	balcony_truck = spawn_vehicles_from_targetname( "balcony_truck" )[0];
	balcony_truck thread go_path( GetVehicleNode(balcony_truck.target,"targetname") );
	balcony_truck veh_magic_bullet_shield( 1 );
}

setup_balcony_aa_gun()
{
	//This gets called from cuba_aasasination.gsc
	//roof aa gun
	level.balcony_roof_aa_gun = spawn_vehicles_from_targetname( "balcony_roof_aa_gun" )[0];
	level.balcony_roof_aa_gun veh_magic_bullet_shield( 1 );
	level.balcony_roof_aa_guy = simple_spawn_single( "balcony_roof_aa_guy" );
	level.balcony_roof_aa_guy thread init_aa_guy( level.balcony_roof_aa_gun );
	level.balcony_roof_aa_guy thread monitor_aa_guy_death( level.balcony_roof_aa_gun );
	//level.balcony_roof_aa_guy thread magic_bullet_shield();

	balcony_roof_targets = GetEntArray( "balcony_roof_targets", "targetname" );
	level.balcony_roof_aa_gun thread start_aa_gun( balcony_roof_targets , "wpn_btr_fire_loop_balc" , "wpn_btr_fire_loop_ring_npc_balc" );
	
}

escape_dialogue()
{
	woods = get_hero_by_name("woods");
	carlos = get_hero_by_name( "carlos" );
	bowman = get_hero_by_name("bowman");
	anim_single(woods, "target_is_down"); //Bowman - The target is down... We're on our way.
	anim_single(bowman, "word_from_carlos"); //Word from Carlos isn't good;  They're barely holding out... They got half the Cuban army down there!
	anim_single(bowman, "aint_hitting_anything"); //And those b26's ain't hitting anything!
	anim_single(bowman, "hallway");//I'm moving to the main hallway.
	anim_single(woods, "on_our_way"); //Okay, we're on our way.
	
	level thread do_vo_nag_loop( "woods", level.generic_nag, "stop_balcony_nag", 5 );
	
	flag_wait ( "player_outside_mansion" );
	anim_single (woods, "pinned_down"); //we're pinned down here
	wait(.7);
	anim_single(bowman, "theres_too_many_of_them"); //This don't look good!  There's too many of them!
	
	wait(1.0);
	//50 cal lines if gunner is still alive
	if(IsAlive(level.courtyard_gunner))
	{
		lines = array("take_out_50cal_bowman", "take_out_50cal_woods", "50cal");
		random_50_cal_line = random(Lines);
		if (random_50_cal_line == "take_out_50cal_bowman")
		{
			anim_single(bowman, random_50_cal_line);
		}
		else
		{	
			anim_single(woods, random_50_cal_line); 
		}	
	}	
		
	wait(2);
	anim_single(bowman, "should_be_here");//Carlos' men should be here!
	
	woods thread play_anim_at_cover();
	//<woods radio VO handled by notetracks here>//
	
	flag_wait ("woods_done_radioing");
	anim_single(bowman, "east_wall");
	anim_single( carlos, "think_id_let_you_down" ); //You think I'd let you down, Woods?
	anim_single( carlos, "cover_escape"); //My men will cover your escape
	
	flag_wait ("courtyard_btr_spawned");
	wait(3);
	anim_single(woods, "btr!"); //btr!!
	
	flag_wait ("courtyard_btr_destroyed");
	
	//TUEY turning off the music here when the BTR gets owned.
	setmusicstate ("FLARE");
	
	anim_single( carlos, "now_hurry_my_friends" ); //Now... Hurry, my friends!

	anim_single( woods, "god_bless" ); //God bless you, Carlos.
	
	anim_single(bowman, "this_way_into_the_sugar_field");
	wait(2);
	level thread do_vo_nag_loop( "woods", level.sugarcane_nag_lines, "stop_sugarcane_nag_lines", 8 );
	
}

balcony_breachers()
{
	trigger_wait( "spawn_balcony_breach_guys" );
	
	flag_set( "stop_balcony_nag" );

	//4 AI
	enemy_breach_doors();

	waittill_ai_group_count( "balcony_breach_guys", 1 ); //1 guy left = move up

	autosave_by_name( "escape_1" );

	move_balcony_breach = GetEnt( "move_balcony_breach", "targetname" );
	if( IsDefined( move_balcony_breach ) ) 
	{
		move_balcony_breach Delete();
	}

	//maybe a wait here?

	move_pre_balcony_breach = GetEnt( "move_pre_balcony_breach", "targetname" );
	if( IsDefined( move_pre_balcony_breach ) ) 
	{
		trigger_use( "move_pre_balcony_breach", "targetname" );

	}
	woods = get_hero_by_name("woods");
	
	flag_set ("halt_mansion_ambiance");
	
}

magic_bullets_on_mansion_entrance()
{
	flag_wait ("actual_mansion_entrance");
	player = get_players()[0];
	targets = getstructarray ("shoot_me", "targetname");
	array_thread (targets, ::Shoot_me_when_player_looks, player);

}	

Shoot_me_when_player_looks(player)
{
	level endon ("cleaned_up_balcony");
	source = getstruct ("shooting_me", "targetname");
	num = RandomIntRange(10,15);
	guns = array("rpk_sp", "skorpion_sp", "fnfal_sp");
	
	while(1)
	{
		gun = random(guns);
		if(player is_player_looking_at(self.origin))
		{
			for (i = 0; i < num; i++ )
			{
				Maps\cuba_airfield::Shoot_magic_bullets(gun, source, self);
				wait(RandomFloatRange(.04,.3) );
			}
			//self thread Print3d_on_ent( "shot!" ); 
			break;
		}
		wait(.05);
	}
}				
	

balcony_crashing_plane(gun, gunner)
{
	start_node = GetVehicleNode( "balcony_plane_start", "targetname" );	
	plane = SpawnVehicle("t5_veh_air_c130", "balcony_plane", "plane_hercules", start_node.origin, start_node.angles);
	plane veh_magic_bullet_shield( 1 );
	maps\_vehicle::vehicle_init(plane);
	plane thread go_path(start_node);
	plane thread init_balcony_plane();
	//plane thread Print3d_on_ent ("PLANE!");

	//kevin adding plane flyby
	plane playsound( "evt_balcony_plane_flyby_2" );
	
	gun endon ("driver_death");
	gun thread burst_fire( "wpn_btr_fire_loop_balc" , "wpn_btr_fire_loop_ring_npc_balc" );
	while( !flag( "plane_passed_by" ) )
	{
		gun SetTurretTargetEnt( plane );
		wait( 0.05 );
	}

	gun notify( "balcony_plane_gone" );
	
	if(IsAlive(gunner))
	{
		balcony_roof_targets = GetEntArray( "balcony_roof_targets", "targetname" );
		gun thread start_aa_gun( balcony_roof_targets , "wpn_btr_fire_loop_balc" , "wpn_btr_fire_loop_ring_npc_balc" );
	}

	//level.balcony_roof_aa_guy stop_magic_bullet_shield();
	//level.balcony_roof_aa_guy monitor_aa_guy_death( level.balcony_roof_aa_gun );
}

mansion_lobby()
{
	//hurt trigger for fire at front door once player is outside
	trig = GetEnt ("courtyard_door_hurt", "targetname");
	trig trigger_off();
	
	
	//sugarcane color chain
	sugarcane_color_chain = GetEnt( "sugarcane_color_chain", "script_noteworthy" );
	sugarcane_color_chain trigger_off();

	//clip for when mansion blocker is triggered
	player_mansion_clip = GetEnt( "player_mansion_clip", "targetname" );
	player_mansion_clip Hide();
	player_mansion_clip	NotSolid();
	player_mansion_clip ConnectPaths();		

	blocker_rubble = GetEntArray( "mansion_wood_blocker", "targetname" );
	array_func( blocker_rubble, ::hide_me_make_me_notsolid );

	//big hit that takes out ceiling
	
	//-- Trigger Radius w/ script_flag
	trigger_wait( "move_pre_balcony_breach" );
	
	woods = get_hero_by_name("woods");
	bowman = get_hero_by_name("bowman");
	
	anim_single(woods, "move_up2");
	wait(1);
	anim_single(level.woods, "bowman_take_the_right"); 
	anim_single(bowman, "roger_that");
	

	flag_set( "stop_balcony_mansion_nag" );
	level.woods thread force_goal();
	

	//parked_courtyard_sedans = spawn_vehicles_from_targetname( "parked_courtyard_sedans" );
	//array_func( parked_courtyard_sedans, ::setup_parked_vehicles );

	//aa guns out in the courtyard
	//spawn_vehicles_from_targetname( "courtyard_aa_gun_1" );
	//spawn_vehicles_from_targetname( "courtyard_aa_gun_2" );
	//spawn_vehicles_from_targetname( "courtyard_aa_gun_3" );
	
	level thread background_flak_fire();


	level thread setup_building_hits();

	//enemies that breach far door in the back
	level thread hallway_breach_guys();


	level thread Spawn_bookshelf_guy();

	simple_spawn( "mansion_front_enemies" );
	level thread mansion_front_cleared();
	level thread squad_auto_move();

	spawn_manager_enable( "lobby_sm_1" );
	
	level thread magic_bullets_on_mansion_entrance();

	trigger_wait( "spawn_exit_enemies", "script_noteworthy" );
	
	//stops balcony bombers
	flag_set( "stop_balcony_bombers" );

	//ai or player triggers a low health AI
	level thread front_door_freebie();

	//high flying c-130's
	//level thread spawn_bombers( "courtyard_ambient_bomber_paths", "stop_courtyard_bombers" );

	level thread ambient_high_bombers( "courtyard_ambient_bomber_struct_paths", "stop_courtyard_bombers" );

	//low flying b-26's
	level thread spawn_courtyard_planes();

	//kills color chain check
	flag_set( "stop_mid_color_chain" );

	front_door_enemies_1 = simple_spawn( "front_door_enemies_1" );
	level thread front_door_enemies_cleared();

	//wait trig kicks off courtyard event
	courtyard();
}

background_flak_fire()
{
	array = getstructarray("courtyard_aa_fire","targetname");
	
	for(i=0;i<array.size;i++)
	{
		array[i].fx_ent = Spawn ("script_origin", array[i].origin);
		//array[i].fx_ent.angles = array[i].angles;			
		playfx(level._effect["fx_ks_ambient_aa_flak"],array[i].fx_ent.origin);	
	}	
			
	flag_wait ("stop_sugarcane_nag_lines");

	for (i = 0; i < array.size; i++ )
	{
		if(IsDefined(array[i].fx_ent))
		{
			array[i].fx_ent Delete();
		}	
	}	

}	




Spawn_bookshelf_guy()
{
	node = GetNode ("crouch_guy", "targetname");
	//turn off his crouch node (other ai were taking it)
	SetEnableNode (node, false);
	trigger_wait ("bookshelf_guy_trig");
	//guy runs to shelf, knocks it over using it as cover
	simple_spawn_single( "bookshelf_guy", ::init_bookshelf_guy, node);
	
}	

setup_parked_vehicles()
{
	self thread go_path( GetVehicleNode(self.target,"targetname") );
}

courtyard()
{
	courtyard_btr_failsafe_trig = GetEnt( "courtyard_btr_failsafe_trig", "script_noteworthy" );
	courtyard_btr_failsafe_trig trigger_off();

	btr_force_death_trig = GetEnt( "btr_force_death_trig", "targetname" );
	btr_force_death_trig trigger_off();

	flag_wait( "player_approaching_mansion_exit" ); 
	
	//kills woods yelling at the player to go outside
	flag_set( "stop_go_outside_nag" );

	autosave_by_name( "escape_2" );

	//turning off battlechatter for rest of level 
	battlechatter_off();	

	//2 AI
	simple_spawn( "mansion_exit_guys" );
	
	trigger_use ("courtyard_filler_spawner"); //replenieshes AI from outside gate

	//trucks that drive in
	truck = spawn_vehicles_from_targetname( "courtyard_truck" )[0];
	wait(.3);
	courtyard_uaz = spawn_vehicles_from_targetname( "courtyard_uaz" )[0];
	wait(.3);
	gunner_truck = spawn_vehicles_from_targetname( "gunner_truck" )[0];
	

	wait( 0.05 );

	//courtyard_uaz.overrideVehicleDamage = ::courtyard_uaz_damage_override;
	truck thread init_courtyard_trucks();
	wait(1.5);
	courtyard_uaz thread init_courtyard_trucks();
	wait(2);
	level thread init_courtyard_gunner_truck( gunner_truck );

	level thread courtyard_timed_beats();
	level thread courtyard_btr();

	flag_wait( "spawn_courtyard_rebels" );
	/*
	courtyard_aa_gun_1 = GetEnt( "courtyard_aa_gun_1", "targetname" );
	courtyard_aa_gun_2 = GetEnt( "courtyard_aa_gun_2", "targetname" );
	courtyard_aa_gun_3 = GetEnt( "courtyard_aa_gun_3", "targetname" );

	//destroy aa guns
	courtyard_aa_gun_1 notify( "death" );
	wait( RandomIntRange(1,3) );
	courtyard_aa_gun_2 notify( "death" );
	wait( RandomIntRange(1,3) );
	courtyard_aa_gun_3 notify( "death" );
	*/
	aa_gun_targets = GetEntArray( "aa_gun_targets", "script_noteworthy" );
	array_func( aa_gun_targets, ::self_delete );
}

hallway_breach_guys()
{
	trigger_wait( "spawn_hallway_breach" );
		
	flag_set( "cleaned_up_balcony" );

	//cleanup first balcony guys
	balcony_enemies = get_ai_group_ai( "balcony_enemies" );
	array_func( balcony_enemies, ::self_delete );

	balcony_roof_aa_gun = GetEnt( "balcony_roof_aa_gun", "targetname" );
	balcony_roof_aa_gun notify( "death" );

	simple_spawn( "hallway_breachers" );
	simple_spawn( "back_hallway_breachers", ::init_back_hallway_breachers );

	hallway_breach_kick_fx = getstruct( "hallway_breach_kick_fx", "targetname" );
	PlayFX( level._effect["fx_door_breach_kick"], hallway_breach_kick_fx.origin );

	hallway_right_door = GetEnt( "hallway_right_door", "targetname" );
	hallway_right_door RotateYaw( 120, 0.2, 0, 0 );
	hallway_right_door playsound ("amb_door_open_wood");
	hallway_right_door ConnectPaths();

	hallway_left_door = GetEnt( "hallway_left_door", "targetname" );
	hallway_left_door playsound ("amb_door_open_wood");
	hallway_left_door RotateYaw( -150, 0.2, 0, 0 );
	hallway_left_door ConnectPaths();
	level thread hallway_breach_closet_monitor();
}

hallway_breach_closet_monitor()
{
	trig = GetEnt ("inside_closet", "targetname");
	
	while(1)
	{	
		touching = 0;
		guys1 = GetEntArray("hallway_breachers_ai", "targetname");
		guys2 = GetEntArray("back_hallway_breachers_ai", "targetname");
		
		guys = array_combine(guys1, guys2);
		for (i = 0; i < guys.size; i++ ) 
		{
			if(guys[i] IsTouching(trig))
			{
				touching = 1;
				continue;
			}
		}
		if(touching )			
		{
			wait(1);
		}
		else
		{		
			break;
		}
		wait(.05);	
	}	
	
	//IPrintLnBold("CLOSET EMPTY");
}	
	

init_back_hallway_breachers()
{
	self endon( "death" );
	self thread force_goal();
	self.ignoreme = true;
	self.ignoreall = true;
	self.ignoresuppression = 1;

	self waittill( "goal" );

	self.goalradius = 2048;
	self.ignoreme = false;
	self.ignoreall = false;
	self.ignoresuppression = 0;
}

sugarcane_run()
{
	self endon( "death" );
	self.ignoreme = true;	
	self.pacifist = true;	
	//self.ignoreall = true;
	self.ignoresuppression = true;
}

sugarcane_event()
{
	sugarcane_color_chain = GetEnt( "sugarcane_color_chain", "script_noteworthy" );
	sugarcane_color_chain trigger_on();

	trigger_wait( "sugarcane_color_chain", "script_noteworthy" );

	level thread do_sugarcane_sprint_unlimited();

	flag_set( "stop_sugarcane_nag_lines" );
	
	Maps\cuba_airfield::sugar_field_planes(); //flyovers during sugarfield run

	move_btr_cleared = GetEnt( "move_btr_cleared", "script_noteworthy" );
	if( IsDefined( move_btr_cleared ) )
	{
		move_btr_cleared Delete();
	}

	//2 planes that do a low fly by ( no bomb drops)
	low_flyby_path_1 = GetVehicleNode("low_flyby_path_1","targetname");
	low_flyby_path_2 = GetVehicleNode("low_flyby_path_2","targetname");

	plane = SpawnVehicle("t5_veh_jet_mig17_gear", "low_flyby_plane_1", "plane_mig17_gear", low_flyby_path_1.origin, low_flyby_path_1.angles);

	maps\_vehicle::vehicle_init(plane);
	plane thread go_path(low_flyby_path_1);
	plane thread monitor_plane_flyby();

	wait( RandomIntRange(1,2) );

	plane = SpawnVehicle("t5_veh_jet_mig17_gear", "low_flyby_plane_2", "plane_mig17_gear", low_flyby_path_2.origin, low_flyby_path_2.angles);

	maps\_vehicle::vehicle_init(plane);
	plane thread go_path(low_flyby_path_2);
	plane thread monitor_plane_flyby();

	trigger_wait( "trigger_second_flyby" );

	//stops c-130's and b26's
	flag_set( "stop_courtyard_bombers" );

	plane = SpawnVehicle("t5_veh_jet_mig17_gear", "low_flyby_plane_3", "plane_mig17_gear", low_flyby_path_1.origin, low_flyby_path_1.angles);

	maps\_vehicle::vehicle_init(plane);
	plane thread go_path(low_flyby_path_1);
	plane thread monitor_plane_flyby();

	wait( RandomIntRange(1,2) );

	plane = SpawnVehicle("t5_veh_jet_mig17_gear", "low_flyby_plane_4", "plane_mig17_gear", low_flyby_path_2.origin, low_flyby_path_2.angles);

	maps\_vehicle::vehicle_init(plane);
	plane thread go_path(low_flyby_path_2);
	plane thread monitor_plane_flyby();
}

do_sugarcane_sprint_unlimited()
{
	//give unlimited sprint 
	get_players()[0] SetClientDvar("player_sprintUnlimited", 1);
	
	heroes = get_heroes_by_name("woods", "bowman");
	array_func( heroes, ::sc_set_hero_run_anim ); //this is moving into util, so remove before checking in
}

sc_set_hero_run_anim()
{
	if(self.animname == "woods")
	{	
		self set_generic_run_anim( "sprint_patrol_1"); //reducing to 1 anim for better arrival transition
	}
	else if(self.animname == "bowman")
	{
		if(RandomInt(100)>50)
		{
			self set_generic_run_anim( "sprint_patrol_3");
		}
		else
		{
			self set_generic_run_anim( "sprint_patrol_4");
		}
	}	
}

cleanup()
{
	//kill spawn managers
	spawn_manager_kill( "cuban_rebel_right_rs" );

	kill_aigroup( "courtyard_enemies" );
	kill_aigroup( "courtyard_btr_soldiers" );
	kill_aigroup( "courtyard_rebel_spawner" );
	kill_aigroup( "rebel_rpg_guys" );

	courtyard_vehicles = GetEntArray( "courtyard_vehicles", "script_noteworthy" );
	array_func( courtyard_vehicles, ::self_delete );

	parked_courtyard_sedans = GetEntArray( "parked_courtyard_sedans", "targetname" );
	array_func( parked_courtyard_sedans, ::self_delete );

	zpu_aa_gun = GetEntArray( "zpu_aa_gun", "script_noteworthy" );
	array_func( zpu_aa_gun, ::self_delete );

	//failsafe, get rid of later
	axis = GetAIArray( "axis" );
	for( i = 0; i < axis.size; i++ )
	{
		if( IsDefined( axis[i] ) )
		{
			axis[i] die();
		}
	}
}

front_door_freebie()
{
	trigger_wait( "spawn_freebie_trig" );
	simple_spawn_single( "front_door_freebie" );	
	
	simple_spawn( "tower_guys" );
}

monitor_mansion_exit()
{
	//flag set from "move_heroes_cover" trig
	flag_wait("player_approaching_mansion_exit");
	
	player = get_players()[0];

	woods_cover_node = GetNode( "woods_cover_node", "targetname" );
	bowman_cover_node = GetNode( "bowman_cover_node", "targetname" );

	woods = get_hero_by_name( "woods" );
	bowman = get_hero_by_name( "bowman" );

	woods.goalradius = 16;
	bowman.goalradius = 16;
	
	heroes = get_heroes_by_name("woods", "bowman");
	
	array_thread( heroes, ::disable_ai_color);
	
	woods SetGoalNode( woods_cover_node );
	bowman SetGoalNode( bowman_cover_node );
	array_thread( heroes, ::force_goal);
	array_wait( heroes, "goal" );
	
	//IPrintLn( "Heroes at goal" );
	
	courtyard_volume = GetEnt( "hero_courtyard_volume", "targetname" );

	flag_wait( "player_in_courtyard" );
	
		//TUEY - cY fight
	level thread maps\_audio::switch_music_wait ("COURTYARD_FIGHT", 2);
	
	//IPrintLn( "mansion blocked" );
	
	heroes_are_outside = false;
	player_is_outside = false;
	while( !heroes_are_outside )
	{
		if( woods IsTouching( courtyard_volume ) && bowman IsTouching( courtyard_volume ) )
		{
			heroes_are_outside = true;
		}
		wait(.05);
	}
	
	while(!player_is_outside)
	{
		//player is inside
		if( player IsTouching( courtyard_volume )  )
		{
			player_is_outside = true;
		}
		wait(.05);
	}	
		
	level thread tower_rpgs();
	
	//player is outside
	player_mansion_clip = GetEnt( "player_mansion_clip", "targetname" );
	player_mansion_clip Show();
	player_mansion_clip	Solid();
	player_mansion_clip DisconnectPaths();		

	blocker_rubble = GetEntArray( "mansion_wood_blocker", "targetname" );
	array_func( blocker_rubble, ::show_me_make_me_solid );

	mansion_exit_falling_fire = getstruct( "mansion_exit_falling_fire", "targetname" );
	PlayFX( level._effect["fallingboards_fire"], mansion_exit_falling_fire.origin );
	
	//pain trig at front door
	trig = GetEnt ("courtyard_door_hurt", "targetname");
	trig trigger_on();

	player = get_players()[0];
	if( DistanceSquared( player.origin, mansion_exit_falling_fire.origin ) < 600 * 600 )
	{
		Earthquake( 0.5, 1, player.origin, 512 );
		player PlayRumbleOnEntity( "damage_heavy" );
	}	
	mansion_exit_fire = getstructarray( "mansion_exit_fire", "targetname" );
	array_func( mansion_exit_fire, ::play_fire_fx );
	flag_set( "player_outside_mansion" );
	
	level thread kill_inside_guys(); //kills all inside mansion

}

kill_inside_guys()
{
	
kill_ai_array_by_targetname ("back_hallway_breachers_ai");
kill_ai_array_by_targetname ("front_door_enemies_1_ai");
kill_ai_array_by_targetname ("downstair_runners_ai");
kill_ai_array_by_targetname ("mansion_front_enemies_ai");

/*	
back_hallway_breachers_ai
front_door_enemies_1_ai
downstair_runners_ai
mansion_front_enemies_ai
*/

}	


kill_ai_array_by_targetname(targetname)
{
	//deletes guys in array defined by targetname of AI
	guys = GetEntArray (targetname, "targetname");
	
	if(guys.size > 0)
	{
		for (i = 0; i < guys.size; i++ )
		{
			if(IsDefined(guys[i]) )
			{
				guys[i] Delete();
			}
		}
	}	

}

tower_rpgs()
{
	flag_wait ("player_in_courtyard");
	wait (RandomIntRange(1,2));
	guys = GetEntArray("tower_guys_ai", "targetname");
	player = get_players()[0];	
	above_player = AnglesToUp ( player.angles ) * 170;	
		
	if(guys.size > 0)
	{
		guy = random (guys);
		spot = guy GetTagOrigin("tag_flash");
		MagicBullet( "rpg_magic_bullet_sp", spot, above_player);
	}	

}

hide_me()
{
	self Hide();
}

show_me()
{
	self Show();

}

hide_me_make_me_notsolid()
{
	self Hide();
	self NotSolid();
	self ConnectPaths();
}

show_me_make_me_solid()
{
	self Show();
	self Solid();
	self DisconnectPaths();	
	
}

play_fire_fx()
{
	PlayFX( level._effect["fire_med"], self.origin );
}

init_courtyard_gunner_truck( truck )
{
	
	
	truck thread go_path( GetVehicleNode(truck.target,"targetname") );
	truck veh_magic_bullet_shield( 1 );

	//truck_driver = simple_spawn_single ("truck_driver", ::init_truck_driver, self );
	level.courtyard_gunner = simple_spawn_single ("courtyard_gunner", ::courtyard_gunner_think, truck);
	level.courtyard_gunner thread monitor_gunner_death( truck );

	gunner_start_firing_node = GetVehicleNode( "gunner_start_firing_node", "script_noteworthy" ); 
	gunner_start_firing_node waittill( "trigger" );

	truck waittill( "reached_end_node" );
	flag_set( "start_gunner_fire" );

	truck veh_magic_bullet_shield( 0 );
	truck.overrideVehicleDamage = ::courtyard_50cal_damage_override;
	level.killed_50cal = undefined;
}

monitor_gunner_death( truck )
{
	self.truck = truck;
	self waittill( "death" );

	self.truck ClearGunnerTarget();
	self.truck notify("gunner_dead");
}

courtyard_gunner_think( truck )
{
	self endon( "death" );

	self gun_remove();
	self.ignoreme = true;
	self.ignoreall = true;
	self.animname = "generic";
	self.truck = truck;
	//self thread Print3d_on_ent("aiming at player");
	self maps\_vehicle_aianim::vehicle_enter(truck, "tag_gunner1" );

	player = get_players()[0];
	self.truck SetGunnerTargetEnt(player, (RandomIntRange(-50, 50), RandomIntRange(-50, 50), RandomIntRange(-50, 50)));

	flag_wait( "start_gunner_fire" );

	self.truck ClearTurretTarget(); 		
	self.truck thread gunner_direct_fire_at_player();
}

gunner_direct_fire_at_player()
{
	self endon("death");
	self endon("gunner_dead");
	
	if( GetDifficulty() == "easy" )	//shoot less with longer waits if on easy
	{
		clip = (RandomIntRange(5,8));
		wait_time = 5;
	}
	else
	{				
		clip = 30;
		wait_time = (RandomFloatRange(2.5, 3.0));
	}	
	
	self SetGunnerTurretOnTargetRange( 0, 50 );

	sound_ent = Spawn( "script_origin", self.origin );
	sound_ent LinkTo( self, "rear_hatch_jnt" );
	self thread delete_gunner_sound_ent( sound_ent );
	
	player = get_players()[0];
	
	while(IsDefined(player))
	{
		for(i=0; i<clip; i++)
		{
			if (IsDefined(player))
			{
				self SetGunnerTargetEnt(player, (RandomIntRange(-50, 50), RandomIntRange(-50, 50), RandomIntRange(-50, 50)));
				self waittill_notify_or_timeout("gunner_turret_on_target", 0.25);
				self fireGunnerWeapon();
				sound_ent PlayLoopSound( "wpn_50cal_fire_loop_npc" );
				wait(0.1);
			}
		}
		sound_ent StopLoopSound( .1 );
		self PlaySound( "wpn_50cal_fire_loop_ring_npc" );
		wait(wait_time);
	}
}

get_easy_numbers()
{
	
	
	
}


Print3d_on_ent( msg ) 
 { 
 /# 
	self endon( "death" );  
	self notify( "stop_print3d_on_ent" );  
	self endon( "stop_print3d_on_ent" );  

	while( 1 ) 
	{ 
		print3d( self.origin + ( 0, 0, 0 ), msg );  
		wait( 0.05 );  
	} 
 #/ 
 }

delete_gunner_sound_ent( ent )
{
    self waittill_any( "death", "gunner_dead" );
    ent Delete();
}

init_courtyard_trucks()
{
	self endon( "death" );
	self veh_magic_bullet_shield( 1 );
	self thread go_path( GetVehicleNode(self.target,"targetname") );

	self waittill( "reached_end_node" );
	self.health = 800;

	
	if( self.targetname == "courtyard_trucks_3" )
	{
		flag_set( "spawn_courtyard_blocker" );
	}
	else
	{
			self veh_magic_bullet_shield( 0 );
	}		

}

courtyard_blocker()
{
	flag_wait( "spawn_courtyard_blocker" );

	courtyard_blocker_truck = spawn_vehicles_from_targetname( "courtyard_blocker_truck" )[0];
	courtyard_blocker_truck thread init_courtyard_trucks();
}

btr_collision_think()
{
	
	btr_player_collision = GetEnt ("btr_player_collision", "targetname");
	btr_player_collision NotSolid();
	
	flag_wait ("courtyard_btr_spawned");
	
	
	btr_player_collision Solid();
	
}	

courtyard_btr()
{
	trigger_wait( "spawn_courtyard_btr" );

	axis = GetAIArray( "axis" );
	for( i=0; i < axis.size; i++ )
	{
		if( IsDefined( axis[i] ) && IsAlive( axis[i] ) )
		{
			axis[i] set_spawner_targets( "btr_nodes" );
		}
	}

	flag_set( "courtyard_btr_spawned" );

	spawn_manager_enable( "btr_soldiers_sm" );

	courtyard_left_gate_door = GetEnt( "courtyard_left_gate_door", "targetname" );
	courtyard_left_gate_door playsound ("amb_door_open_wood");
	courtyard_left_gate_door RotateYaw( -90, 0.2, 0, 0 );
	courtyard_left_gate_door playsound ("amb_door_open_wood");
	courtyard_left_gate_door ConnectPaths();

	courtyard_right_gate_door = GetEnt( "courtyard_right_gate_door", "targetname" );
	courtyard_right_gate_door playsound ("amb_door_open_wood");
	courtyard_right_gate_door RotateYaw( 90, 0.2, 0, 0 );
	courtyard_right_gate_door playsound ("amb_door_open_wood");
	courtyard_right_gate_door ConnectPaths();
	
	courtyard_left_gate_door Hide();
	courtyard_right_gate_door Hide();

	//delete wall and play fx
	btr_courtyard_wall = GetEnt( "btr_courtyard_wall", "targetname" );
	PlayFX( level._effect[ "wallbreach" ], btr_courtyard_wall.origin );
	playsoundatposition( "exp_guard_tower_l" , btr_courtyard_wall.origin );
	
	btr_courtyard_wall ConnectPaths();
	btr_courtyard_wall Delete();

	//temp wood particle fx
	btr_wood_fx = getstructarray( "btr_wood_fx", "targetname" );
	array_func( btr_wood_fx, ::play_concrete_fx );
	playsoundatposition ("evt_btr_intro", (0,0,0));
	
	rumble_screen_shake_player();

	simple_spawn( "courtyard_btr_soldiers" );

	courtyard_btr = spawn_vehicles_from_targetname( "courtyard_btr" )[0];
	courtyard_btr veh_magic_bullet_shield( 1 );

	courtyard_btr thread go_path( GetVehicleNode(courtyard_btr.target,"targetname") );
	courtyard_btr waittill( "reached_end_node" );

	courtyard_btr thread btr_direct_fire_at_player();
	level thread waitill_fire_at_rebels();

	courtyard_btr veh_magic_bullet_shield( 0 );
	courtyard_btr.health = 400;

	btr_force_death_trig = GetEnt( "btr_force_death_trig", "targetname" );
	btr_force_death_trig trigger_on();
	level thread kill_player_on_touch( btr_force_death_trig, "courtyard_btr_destroyed" );
	
	courtyard_btr thread btr_timeout_death();
	courtyard_btr waittill( "death" );
	courtyard_btr play_fire_fx();
	
	level thread kill_ai_close_to_btr(btr_force_death_trig);
	
	//maps\cuba_airfield::Spawn_vehicle_gibs(courtyard_btr);

	//kills btr player death trig
	flag_set( "courtyard_btr_destroyed" );

	autosave_by_name( "escape_4" );

	level thread sugarcane_event();

	waittill_ai_group_amount_killed( "courtyard_btr_soldiers", 5 );
	spawn_manager_kill( "btr_soldiers_sm" );

	trigger_use ("gate_straggler_spawner");

	bowman = get_hero_by_name( "bowman" );

	set_objective( level.OBJ_ESCAPE, get_hero_by_name( "woods" ), "follow" );

	move_btr_cleared = GetEnt( "move_btr_cleared", "script_noteworthy" );
	if( IsDefined( move_btr_cleared ) )
	{
		trigger_use( "move_btr_cleared", "script_noteworthy" );
	}

	heroes = get_heroes_by_name("woods", "bowman");
	array_func(heroes, ::sugarcane_run );
}


kill_ai_close_to_btr(trig)
{
	//kill baddies close to BTR when it dies
	guys = GetAIArray("axis");
	close_guys = get_array_of_closest( trig.origin, guys, undefined, 550 );
	for (i = 0; i < close_guys.size; i++ )
	{
		close_guys[i] thread Maps\cuba_airfield::burning_death();
		wait(.03);	
	}		
}	

btr_timeout_death()
{
	self endon( "death" );
	wait( 15 );
	//PlayFX( level._effect[ "veh_exp" ], self.origin );
	exploder(850);
	self notify( "death" );
}

kill_player_on_touch( death_trig, ender )
{
	if( !IsDefined( ender ) )
	{
		ender = "kill_death_trigs";
	}
		
	level endon( ender );
	
	death_trig waittill( "trigger", player );
	PlayFX( level._effect[ "airfield_ambient_mortar" ], player.origin );
	wait( 0.10 );
	player Suicide();
}

rumble_screen_shake_player()
{
	player = get_players()[0];
	Earthquake( 0.5, 1, player.origin, 512 );
	player PlayRumbleOnEntity( "damage_heavy" );
}

//temp fx
play_concrete_fx()
{
	vFwd = AnglesToForward( self.angles );
	PlayFX( level._effect[ "bow_effect_on_sampan_death" ], self.origin, vFwd );
}

play_anim_at_cover()
{
	self endon( "death" );
	
	self.ignoresuppression = 1;
	self.goalradius = 32;
	self.ignoreme = true;
	self disable_ai_color();

	//changed from struct to node_concealment_crouch for better transition anim
	//woods_radio_node = getstruct( "woods_radio_node", "targetname" );
	woods_radio_node = GetNode( "new_woods_radio_node", "targetname");
	//woods_radio_node.angles = (0,0,0);
	woods_radio_node anim_reach_aligned( self, "radio_carlos" ); 
	woods_radio_node anim_single_aligned( self, "radio_carlos" ); 

	self.goalradius = 2048;
	self.ignoreme = false;
	self enable_ai_color();
	self.ignoresuppression = 0;

	trigger_use( "cover_after_radio", "targetname" );

	flag_set( "woods_done_radioing" );
}

front_door_enemies_cleared()
{
	waittill_ai_group_count( "front_door_enemies", 1);
	trigger_use ("squad_downstairs");

	move_downstairs = GetEnt( "move_downstairs", "script_noteworthy" );
	if( IsDefined( move_downstairs ) )
	{
		woods = get_hero_by_name("woods");
		
		trigger_use( "move_downstairs", "script_noteworthy" );
		woods waittill ("goal");
		level thread do_vo_nag_loop( "woods", level.courtyard_nag_lines, "stop_go_outside_nag", 5 );
	}

}

init_courtyard_rpg_rebels( target, target_2 )
{
	self endon( "death" );

	self magic_bullet_shield();
	self.goalradius = 64;
	self.a.rockets = 50;
	self.ignoreme = true;
	self disable_pain();
	self disable_react();
	self.dropweapon = 0;

	self waittill( "goal" );

	self.cansee_override = true;
	
	temp_target = Spawn ("script_origin", target.origin);
	temp_target2 = Spawn ("script_origin", target_2.origin);

	self shoot_at_target( temp_target, undefined, undefined, 0.15 );
	self shoot_at_target( temp_target2, undefined, undefined, 0.15 );
	
	temp_target Delete();
	temp_target2 Delete();
	
}

waitill_fire_at_rebels()
{
	wait( 7 );

	flag_set( "btr_entrance_fire" );
}

btr_direct_fire_at_player() //self = btr
{
	self endon( "death" );
	self endon( "stop_firing" );
	
	sound_ent = Spawn( "script_origin", self.origin );
	sound_ent LinkTo( self, "tag_gunner_turret1" );
	self thread delete_gunner_sound_ent( sound_ent );

	player = get_players()[0];
	self ClearTurretTarget(); 		

	self SetGunnerTurretOnTargetRange( 0, 400 );

	clip = RandomIntRange(4,6);

	//for about 5 seconds the btr fires at player
	while( !flag( "btr_entrance_fire" ) )
	{
		while(IsDefined(player))
		{
			for( i=0; i < clip; i++ )
			{
				if( IsDefined( player ) )
				{
					y_offset = RandomIntRange( 100,150 );	

					if( cointoss() )
					{
						x_offset = RandomIntRange( 150, 200 );
					}
					else
					{
						x_offset = RandomIntRange( -200, -150 );
					}
					
					self SetGunnerTargetEnt( player, ( x_offset,y_offset,0) );
					self waittill_notify_or_timeout("gunner_turret_on_target", 2);
					self fireGunnerWeapon();
					sound_ent PlayLoopSound( "wpn_btr_fire_loop_npc" );
					wait(0.3);
				}
			}
			sound_ent StopLoopSound( .1 );
			self PlaySound( "wpn_btr_fire_loop_ring_npc" );
			wait(RandomFloatRange(2,3) );
		}
	}

	//TODO::right now it only fires at the player, BTR might not have to target ai at all
	//after firing on the player, it starts to target ai
	while( 1 )
	{
		wait_time = RandomFloatRange( 0.25, 0.75);
		bullet_count = RandomInt( 10, 20 );
	
		if( DistanceSquared( self.origin, player.origin ) < 800 * 800    )
		{
			self notify("stop_firing_at_targets");

			self setGunnerTargetVec( player.origin + (0,0,30 ) );

			for(i = 0; i < bullet_count; i++)
			{
				self waittill_notify_or_timeout("gunner_turret_on_target", 2);
				self fireGunnerWeapon();
				wait (0.2);
			}
		}
		else
		{

			woods = get_hero_by_name("woods");
			bowman = get_hero_by_name( "bowman" );
					
			trgts = GetAIArray("allies");
	
			//remove ghe
			trgts = array_exclude(trgts, woods );
			trgts = array_exclude(trgts, bowman );
	
			if (trgts.size > 0)
			{
			
				trgt = trgts[RandomIntRange(0, trgts.size)];
			
				while(isdefined(trgt))
				{
					for(i=0; i<clip; i++)
					{
						if (isdefined(trgt))
						{
							self SetGunnerTargetEnt(trgt);
							self fireGunnerWeapon();
//							sound_ent PlayLoopSound( "wpn_gaz_quad50_turret_loop_npc", .25 );
							wait(0.1);
						}
					}
//					sound_ent StopLoopSound( .25 );
					self PlaySound( "wpn_gaz_quad50_flux_npc_l" );
					wait(RandomFloatRange(2.5, 3.0));
				}
			}
		}
		wait( wait_time );
	}
}

btr_can_see_player( player ) //self = btr
{
	success = BulletTracePassed( self GetTagOrigin( "tag_flash_gunner1" ) , player GetTagOrigin( "tag_eye" ) , false, undefined );
	return success;	
}

fire_at_targets( targets ) //self == btr
{
	self notify("stop_firing_at_targets");
	self endon( "stop_firing_at_targets" );
	self endon( "death" );

	wait_time = RandomIntRange( 1, 2);
	bullet_count = RandomInt( 10, 20 );

	for( i=0; i < targets.size; i++ )
	{
		current_target = targets[RandomInt(targets.size)];

		self setGunnerTargetVec( current_target.origin );

		for(i = 0; i < bullet_count; i++)
		{
			self waittill_notify_or_timeout("gunner_turret_on_target", 2 );
			self fireGunnerWeapon();
			wait (0.2);
		}
		wait( wait_time );
	}
}

courtyard_timed_beats()
{
	woods = get_hero_by_name( "woods" );

	
	//wait( RandomFloatRange(2,3) );
	bowman = get_hero_by_name("bowman");
	

	woods = get_hero_by_name("woods");
	

	//wait( 2 );

	//anim_single(woods, "carlos_question"); //Carlos?!!

	courtyard_trucks_2 = spawn_vehicles_from_targetname( "courtyard_trucks_2" )[0];
	wait(1.5);
	courtyard_trucks_2 thread init_courtyard_trucks();

	//truck pulls up by driveway entrance and blocks it.
	level thread courtyard_blocker();	

	courtyard_trucks_3 = spawn_vehicles_from_targetname( "courtyard_trucks_3" )[0];
	wait(1.5);
	courtyard_trucks_3 thread init_courtyard_trucks();

	flag_wait( "woods_done_radioing" );

	//spawn cuban rebels
	flag_set( "spawn_courtyard_rebels" );
	thread rebel_charge_audio();
	
	//a lot of rpg trails
	level thread courtyard_magic_rpgs();

	spawn_manager_enable( "cuban_rebel_right_rs" );
	
	spawn_manager_kill ("courtyard_filler_spawner");

	//3 ally ai spawn in and take fire 2 rounds of RPg's
	courtyard_right_target = getstruct( "courtyard_right_target", "targetname" );
	courtyard_right_target_2 = getstruct( "courtyard_right_target_2", "targetname" );
	simple_spawn_single( "courtyard_rpg_rebel_right", ::init_courtyard_rpg_rebels, courtyard_right_target, courtyard_right_target_2 );

	courtyard_center_target = getstruct( "courtyard_center_target", "targetname" );
	right_tower_target = getstruct( "right_tower_target", "targetname" );
	simple_spawn_single( "courtyard_rpg_rebel_center", ::init_courtyard_rpg_rebels, courtyard_center_target, right_tower_target );

	courtyard_tower_target = getstruct( "courtyard_tower_target", "targetname" );
	courtyard_tower_target_2 = getstruct( "courtyard_tower_target_2", "targetname" );
	simple_spawn_single( "courtyard_rpg_rebel_tower", ::init_courtyard_rpg_rebels, courtyard_tower_target, courtyard_tower_target_2 );

	//force kill tower guys
	kill_aigroup( "tower_guys" );

	// start flare
	level thread start_rebel_flare();

	wait( 5 );

	tower_guys = GetEntArray( "tower_guys_ai", "targetname" );
	for( i=0; i < tower_guys.size; i++ )
	{
		if( IsDefined( tower_guys[i] ) && IsAlive( tower_guys[i] ) )
		{
			tower_guys[i] die();
		}
	}

	axis = GetAIArray( "axis" );
	while( axis.size > 5)
	{
		wait( 1 );
		axis = GetAIArray( "axis" );
	}

	bowman enable_ai_color();
	woods enable_ai_color();
	
	//color chain up to road
	trigger_use( "move_btr_position", "targetname" );
	
	//woods_play_moveup_line();

	//wait( 2 );

	//autosave_by_name( "escape_3" );

	//force spawns courtyard event in 5 second
	level thread btr_spawn_timeout();

	//enables lookat trig
	flag_set( "spawn_courtyard_btr" );

	courtyard_btr_failsafe_trig = GetEnt( "courtyard_btr_failsafe_trig", "script_noteworthy" );
	courtyard_btr_failsafe_trig trigger_on();
}

//kevin adding sound call for rebel charge
rebel_charge_audio()
{
	ent = spawn( "script_origin" , (3510.5, 251, 584));
	ent playloopsound( "amb_walla_distant_loop_1" );
	wait 10;
	ent stoploopsound(1);
	wait 1;
	ent delete();
}

courtyard_magic_rpgs()
{
	wait(RandomFloatRange(0.50,1.0));

	magic_rpg_truck_start = getstruct( "magic_rpg_truck_start", "targetname" );
	magic_rpg_truck_end = getstruct(magic_rpg_truck_start.target,"targetname");
	MagicBullet( "rpg_magic_bullet_sp", magic_rpg_truck_start.origin, magic_rpg_truck_end.origin );
	
	wait(RandomFloatRange(0.20,1.0));

	magic_rpg_2 = getstruct( "magic_rpg_2", "targetname" );
	magic_rpg_2_end = getstruct(magic_rpg_2.target,"targetname");
	MagicBullet( "rpg_magic_bullet_sp", magic_rpg_2.origin, magic_rpg_2_end.origin );

	wait(RandomFloatRange(0.20,1.0));

	magic_rpg_3 = getstruct( "magic_rpg_3", "targetname" );
	magic_rpg_3_end = getstruct(magic_rpg_3.target,"targetname" );
	MagicBullet( "rpg_magic_bullet_sp", magic_rpg_3.origin, magic_rpg_3_end.origin );

	wait(RandomFloatRange(0.20,1.0));

	magic_rpg_4 = getstruct( "magic_rpg_4", "targetname" );
	magic_rpg_4_end = getstruct(magic_rpg_4.target,"targetname");
	MagicBullet( "rpg_magic_bullet_sp", magic_rpg_4.origin, magic_rpg_4_end.origin );

	wait(RandomFloatRange(0.20,1.0));

	magic_rpg_5 = getstruct( "magic_rpg_5", "targetname" );
	magic_rpg_5_end = getstruct(magic_rpg_5.target,"targetname");
	MagicBullet( "rpg_magic_bullet_sp", magic_rpg_5.origin, magic_rpg_5_end.origin );

	wait(RandomFloatRange(0.20,1.0));

	magic_rpg_6 = getstruct( "magic_rpg_6", "targetname" );
	magic_rpg_6_end = getstruct(magic_rpg_6.target,"targetname");
	MagicBullet( "rpg_magic_bullet_sp", magic_rpg_6.origin, magic_rpg_6_end.origin );

	wait(RandomFloatRange(0.20,1.0));

	magic_rpg_7 = getstruct( "magic_rpg_7", "targetname" );
	magic_rpg_7_end = getstruct(magic_rpg_7.target,"targetname");
	MagicBullet( "rpg_magic_bullet_sp", magic_rpg_7.origin, magic_rpg_7_end.origin );

	wait(RandomFloatRange(0.20,1.0));

	magic_rpg_8 = getstruct( "magic_rpg_8", "targetname" );
	magic_rpg_8_end = getstruct(magic_rpg_8.target,"targetname");
	MagicBullet( "rpg_magic_bullet_sp", magic_rpg_8.origin, magic_rpg_8_end.origin );

	wait(RandomFloatRange(0.20,1.0));

	magic_rpg_9 = getstruct( "magic_rpg_9", "targetname" );
	magic_rpg_9_end = getstruct(magic_rpg_9.target,"targetname");
	MagicBullet( "rpg_magic_bullet_sp", magic_rpg_9.origin, magic_rpg_9_end.origin );


	wait(RandomFloatRange(0.20,2.0));
	MagicBullet( "rpg_magic_bullet_sp", magic_rpg_2.origin, magic_rpg_2_end.origin );
	wait(RandomFloatRange(0.20,1.0));
	MagicBullet( "rpg_magic_bullet_sp", magic_rpg_3.origin, magic_rpg_3_end.origin );
	wait(RandomFloatRange(0.20,1.0));
	MagicBullet( "rpg_magic_bullet_sp", magic_rpg_4.origin, magic_rpg_4_end.origin );
}

// flare
start_rebel_flare()
{
	level.FLARE_HEIGHT = 4000;
	level.FLARE_BURSTDIST = 1000;	
		
	// get start position of the flare
	flare_starts = getstructarray( "flare_starts", "targetname" );
	array_thread( flare_starts, ::courtyard_fire_flare );
}

courtyard_fire_flare()
{
	flare_ent = Spawn( "script_model", self.origin );
	flare_ent SetModel( "tag_origin" );

	// get the up vector for flare
	up_vec = AnglesToUp( self.angles );
	up_vec = vector_scale( up_vec, level.FLARE_HEIGHT );

	// end position is where we swap to the burst effect
	end_pos = flare_ent.origin + up_vec;

	flare_ent thread invasion_flare_swap_burst_test( end_pos );

	// move the flare entity up in the sky and play the trail
	PlayFXOnTag( level._effect["flare_trail"], flare_ent, "tag_origin" );
	flare_ent MoveTo( end_pos, 3, 0.5, 1.2 );
	flare_ent waittill( "movedone" );

	wait(4);
	
	flare_ent MoveTo( self.origin, 6, 3 );
	flare_ent waittill( "movedone" );

	// delete flare ent
	flare_ent Delete();
}

invasion_flare_swap_burst_test( end_pos ) // flare ent
{
	// wait until flare is almost halfway in the sky 
	while( IsDefined( self ) && DistanceSquared( self.origin, end_pos ) > level.FLARE_BURSTDIST * level.FLARE_BURSTDIST )
	{
		wait(0.05);
	}

	// move this entity downwards and play the effect
	if( IsDefined( self ) )
	{
		PlayFXOnTag( level._effect["flare_burst"], self, "tag_origin" );
	}
}

btr_spawn_timeout()
{
	level endon( "courtyard_btr_spawned" );

	wait( 5 );
	trigger_use( "spawn_courtyard_btr", "targetname" );
}

setup_building_hits()
{
	//grabs all debris trigs and inits their falling pieces
	trigs = GetEntArray( "falling_debris_trigs", "script_noteworthy" );
	ASSERTEX( IsDefined( trigs ) && trigs.size > 0, "Can't find any falling debris triggers!" );
	
	array_thread( trigs, ::fallingdebris_think );

	//FIRST HIT
	trig = trigger_wait( "first_hit_trig" );

	simple_spawn( "downstair_runners" ); //run and delete guys

	//rumble_screen_shake_player();
	trig PlaySound("phy_impact_glass_glass");

	flag_set( "mansion_small_boom" );

	//SECOND HIT
	trig = trigger_wait( "second_hit_trig" );

	rumble_screen_shake_player();
	trig PlaySound("phy_impact_glass_glass");
}

fallingdebris_think()
{
	ASSERTEX( IsDefined( self.target ), "falling debris target not found for trigger at origin " + self.origin );
	debrisGroup = GetEntArray( self.target, "targetname" );
	
	if( !IsDefined( debrisGroup ) || debrisGroup.size <= 0 )
	{
		ASSERTMSG( "falling debris not found for trigger at origin " + self.origin );
		return;
	}
	
	self waittill( "trigger" );

	array_thread( debrisGroup, ::fallingdebris_drop );
}

mansion_front_cleared()
{
	level endon( "stop_mid_color_chain" );
	
	waittill_ai_group_amount_killed( "mansion_front_enemies", 3 );
	move_mid_lobby = GetEnt( "move_mid_lobby", "targetname" );
	if( IsDefined( move_mid_lobby ) )
	{
		//add_dialogue_line( "Woods", "Move up!" );
		woods = get_hero_by_name("woods");
	
		woods_play_moveup_line();
		trigger_use( "move_mid_lobby", "targetname" );
	}
}






#using_animtree ("generic_human");
mansion_building_bomb()
{
	
	trigger_wait( "bowman_entrance_trig" );
	
	mansion_ceiling_broken = GetEntArray ("mansion_ceiling_broken", "targetname");
	array_thread (mansion_ceiling_broken, ::hide_me);
	
	chandelier = GetEnt ("fxanim_cuba_chandelier_mod", "targetname");
	
	chandelier thread Maps\cuba_airfield::Spawn_fx_on_temp_ent("fx_flame_jnt", "chandelier_on");

	//trig is here for debris (trig.target)
	trigger_wait( "start_mansion_bomb" );
	
	
	//MORTAR SOUND
	chandelier PlaySound ("prj_mortar_incoming", "sound_done");
	chandelier waittill ("sound_done");
	chandelier PlaySound ("exp_mortar_mansion");

	//CEILING COMES DOWN
	mansion_ceiling = GetEntArray( "mansion_ceiling", "targetname" );
	array_func( mansion_ceiling, ::self_delete );
	
	//WOOD COMES CRASHING DOWN
	trigger_use( "mansion_bomb_debris_trig", "targetname" );
	
	//GLASS COMES DOWN
	
	//plays a temp glass effect on nearby structs
	/*
	glass_fx_angle = getstruct( "glass_fx_angle", "script_noteworthy" );
	vFwd = AnglesToForward( glass_fx_angle.angles );
	
	glass_fx = getstructarray( "glass_fx", "targetname" );
	for( i=0; i < glass_fx.size; i++ )
	{
		PlayFX( level._effect["fx_glass_heli_break"], glass_fx[i].origin, vFwd ); 
	}
	*/
	//DOWNSTAIRS FX
	downstairs_blocked_path_fx = getstruct( "downstairs_blocked_path_fx", "targetname" );
	PlayFX( level._effect["fallingboards_fire"], downstairs_blocked_path_fx.origin );
	downstairs_fire = getstructarray( "downstairs_fire", "targetname" );
	array_func( downstairs_fire, ::play_fire_fx );
	
	array_thread (mansion_ceiling_broken, ::show_me);

	//STOP PLAYING CANDLE FX
	chandelier.fx_ent Delete();

	//SHAKE PLAYER
	player = get_players()[0];
	Earthquake( 0.5, .7, player.origin, 512 );
	player PlayRumbleOnEntity( "damage_heavy" );
	player SetBlur( 2, .2 );
	player PlaySound("phy_impact_glass_glass");
	player SetBlur( 0, 1 );
	
	wait(.7);

	//SOUND here please!
	
	//celing collapse
	exploder(750);
	//chandelier crashes here
	level notify ("chandelier_start");

	//close axis play flash/dazed animation
	axis = GetAIArray( "axis" );
	ent = getstruct ("crash_spot", "targetname");//script_origin where chandelier crashes
	
	close_axis = get_array_of_closest( ent.origin, axis, undefined, 500 );
	
	for (i = 0; i < close_axis.size; i++ )
	{
		close_axis[i] thread fake_flash_me();
	}		

	woods = get_hero_by_name("woods");
	anim_single(woods, "dammit"); //DAMMIT!!!
	anim_single(woods, "lets_get_the_fuck_out"); //Let's get the fuck out of here before those damn planes blow us to pieces!
}

fake_flash_me()
{
	self endon( "death" );
	
	if (self.a.pose == "stand")
	{
		//level thread anim_generic( self, "flash_death" );
		self AnimCustom(::building_hit_anim);
	}

	enable_pain();
	enable_react();
}

building_hit_anim() //self = ai
{
	disable_pain();
	disable_react();

	animation = random(level.scr_anim["generic"]["flash_death"]);

	self SetFlaggedAnimKnobAll("flash_death", animation, %root, 1, .2, 1);
	self do_notetracks("flash_death");
}

bowman_entrance()
{
	trigger_wait( "bowman_entrance_trig" );
	
	bowman_post_entrance_node = GetNode( "bowman_post_entrance_node", "targetname" );

	set_objective( level.OBJ_ESCAPE, get_hero_by_name( "woods" ), "support" );

	bowman_entrance_start = getstruct( "bowman_entrance_start", "targetname" );

	bowman = get_hero_by_name("bowman");
	bowman.goalradius = 32;
	bowman.ignoreme = true;
	bowman.ignoreall = true;	
	
	bowman_victim = simple_spawn_single( "bowman_victim", ::setup_bowman_victim );

	bowman_execution_start = getstruct( "bowman_execution_start", "targetname" );

	guys = [];
	guys[0] = bowman;
	guys[1] = bowman_victim;
	
	bowman animscripts\shared::placeWeaponOn( bowman.sidearm, "right" );
	
	level thread victim_blood_fx(bowman_victim);
	
	bowman_entrance_start anim_single_aligned( guys, "showdown" ); 
	
	//TUEY - BOWMAN_TAKEDOWN
	setmusicstate ("BOWMAN_TAKEDOWN");

	bowman SetGoalNode( bowman_post_entrance_node );

	bowman enable_cqbwalk();
	bowman.goalradius = 2048;
	bowman.ignoreme = false;
	bowman.ignoreall = false;

	flag_clear ("halt_mansion_ambiance");

	
	
}

victim_blood_fx(guy)
{
	wait (1.5);
	PlayFXOnTag (level._effect["blood"], guy, "j_spinelower" );
	wait(.2);
	PlayFXOnTag (level._effect["blood"], guy, "j_spinelower" );
	wait(.3);
	PlayFXOnTag (level._effect["blood"], guy, "j_spinelower" );

}	

setup_bowman_victim()
{
	self endon( "death" );

	self.animname = "bowman_victim";
	self.goalradius = 32;
	self.ignoreme = true;
	self.ignoreall = true;
	self.activatecrosshair = false;
}


enemy_breach_doors()
{	
	guy = simple_spawn_single ("door_kick_guy", ::door_kick_guy_logic);
	simple_spawn( "balcony_breachers" ); //2 AI

}


door_kick_guy_logic()
{
	self.animname = "generic";
	self thread magic_bullet_shield(); //god mode to make sure he opens the door 
	node = GetNode ("door_kick_align", "targetname");
	node anim_reach_aligned( self, "door_kick" ); 
	node anim_single_aligned( self, "door_kick" ); 
	self thread stop_magic_bullet_shield(); //door is opened - god mode off
	level simple_spawn_single ("balcony_rambo");

}
	
Kick_door_open(guy)
{
	//notetrack on kick door impact
	ai_breach_kick_fx = getstruct( "ai_breach_kick_fx", "targetname" );
	PlayFX( level._effect["fx_door_breach_kick"], ai_breach_kick_fx.origin );

	left_door_balcony = GetEnt( "left_door_balcony", "targetname" );
	right_door_balcony = GetEnt( "right_door_balcony", "targetname" );

	left_door_balcony thread open_left_door();
	right_door_balcony thread open_right_door(); 
}

open_left_door()
{
	self RotateYaw( -135, 0.4, .3, .1 );
	self ConnectPaths();
}

open_right_door()
{
	self RotateYaw( 135, 0.1, 0, 0 );
	self ConnectPaths();
}

woods_shoots_balcony_door()
{
	woods = get_hero_by_name("woods");

	simple_spawn( "balcony_frontline" );

	woods_postkick_node = GetNode( "woods_postkick_node", "targetname" );
	woods.goalradius = 32;
	woods SetGoalNode( woods_postkick_node );
	woods waittill( "goal" );
	woods.goalradius = 2048;

	move_balcony_breach = GetEnt( "move_balcony_breach", "targetname" );
	if( IsDefined( move_balcony_breach ) ) 
	{
		trigger_use( "move_balcony_breach", "targetname" ); //woods moves to half way point of balcony here
		woods thread force_goal();
	}
	
	
	
}

move_to_struct()
{
	door_target_end = getstruct( "door_target_end", "targetname" );

	self moveto( door_target_end.origin, 3, 1, 2 );
	self waittill( "movedone" );
	flag_set( "woods_stop_shooting" );
	wait( 0.10 );
	self Delete();
}

init_aa_guy( aa_gun ) //self is aa gunner
{
	self endon( "death" );

	self.animname = "aa_gunner_fire";
	self.ignoreall = true;
	self.ignoreme = true;
	self.health = 10;

	driver_seat = aa_gun GetTagOrigin("tag_driver");
	driver_seat_angle = aa_gun GetTagAngles("tag_driver");

	self LinkTo(aa_gun, "tag_driver", (0,0,0 ) );
	aa_gun thread anim_loop_aligned( self, "fire", "tag_driver");
	self.allowdeath = true;
}

monitor_aa_guy_death( aa_gun )
{
	self endon( "cleaned_up_balcony" );

	self waittill("death");
	aa_gun notify("driver_death");
}

// self = a piece of debris
fallingdebris_drop()
{
	if( IsDefined( self.script_delay ) && self.script_delay >= 0 )
	{
		wait( self.script_delay );
	}
	else
	{
		wait( RandomFloatRange( 0.10, 0.20 ) );
	}
	
	PlayFX( level._effect["fallingboards_fire"], self.origin );

	//kevin adding debris audio
	self thread falling_boards_audio();
	
	// turn off collision so we don't damage AIs
	self NotSolid();
	
	self PhysicsLaunch( ( RandomInt( 50 ), RandomInt( 50 ), RandomInt( 50 ) ), ( 0, 0, -15 ) );
}

//kevin boards audio function
falling_boards_audio()
{
	wait( 1 );
	playsoundatposition( "evt_roof_boards" , self.origin );
}

spawn_bombers( node_array, ender )
{
	level endon( ender );
		
	nodes = GetVehicleNodeArray( node_array,"targetname");
	
	while(1)
	{
		node = random(nodes);	
		plane = SpawnVehicle("t5_veh_air_c130", "airfield_bomber", "plane_hercules", node.origin, node.angles);
		maps\_vehicle::vehicle_init(plane);
		plane thread go_path(node);
		plane SetSpeedImmediate( randomintrange(110,150), 100 * .25,100 * .25);
		nodes = array_remove(nodes,node);
		if(nodes.size == 0)
		{
			nodes = GetVehicleNodeArray( node_array,"targetname");
			wait(RandomIntRange(15,20));
		}
		else
		{
			wait(RandomFloatRange(5,10));
		}
	}
}

ambient_high_bombers( struct_array, ender )
{
	level endon( ender );

	while( 1 )
	{
	
		if( GetEntArray( "ambient_2d_bomber", "targetname" ).size < 7 )
		{
			level thread ambient_high_bomber_path( struct_array );
			wait(RandomIntRange(5,10));
		}
		else
		{
			wait(RandomIntRange(1,2));
		}

	}
}

ambient_high_bomber_path( struct_starts )
{
	struct_array = getstructarray( struct_starts, "targetname" );	
	start_point = random( struct_array );

	ambient_bomber = Spawn( "script_model", start_point.origin );
	ambient_bomber SetModel( "p_cub_vista_bomber" );
	ambient_bomber.angles = start_point.angles;
	ambient_bomber.targetname = "ambient_2d_bomber";	

	speed = RandomFloatRange( 40.0, 50.0 );
	end_spot = getstruct( start_point.target, "targetname" );
	ambient_bomber moveto( end_spot.origin, speed );
	
	ambient_bomber waittill( "movedone" );
	ambient_bomber Delete();
}

downstair_ground_ambient_ai()
{
	self endon( "death" );

	self thread monitor_player_damage();

	self.goalradius = 32;
	self.ignoreme = 1;
	self.ignoreall = 1;
	self.ignoresuppression = 1;
	self.a.disablePain = 1;
	self.grenadeawareness = 0;	
	self.movePlaybackRate = 1.5;
//	self disable_pain();
//	self disable_react();

	delete_node = GetNode( "downstair_runners_delete_node", "targetname" );

	self SetGoalNode( delete_node );
	self waittill( "goal" );

	player = get_players()[0];

	if( self ai_can_see_player( player ) )
	{
		self thread make_me_active();
	}
	else
	{
		self Delete();
	}
}

ai_can_see_player( player ) //self = ai
{
	success = BulletTracePassed(self GetTagOrigin( "tag_eye" ) , player get_eye() , false, self );
	return success;	
}

monitor_player_damage()
{
	self waittill( "damage", amount, inflictor);
	if( IsPlayer( inflictor ) )
	{			
		self thread make_me_active();
	}
}

make_me_active()
{
	self endon( "death" );
	
	self.ignoreme = 0;
	self.ignoreall = 0;	
	self.ignoresuppression = 0;
	self.a.disablePain = 0;
	self.grenadeawareness = 1;
	self.goalradius = 2048;
//	self enable_pain();
//	self enable_react();
	self set_spawner_targets( "top_level_lobby_nodes" );
}

give_me_rockets()
{
	self endon( "death" );

	self.a.rockets = 10;
}

init_balcony_plane() //self = plane
{
	self endon( "death" );

	self thread monitor_plane_flyby();

	self veh_magic_bullet_shield( 1 );
	PlayFXOnTag( level._effect["chopper_burning"], self, "tag_origin" );

	balcony_plane_gone = GetVehicleNode( "balcony_plane_gone", "script_noteworthy" );
	balcony_plane_gone waittill( "trigger" );

	flag_set( "plane_passed_by" );
	exploder(432);
	
	player = get_players()[0];
	//Earthquake( 0.3, 1, player.origin, 512 );
	//player PlayRumbleOnEntity( "damage_heavy" );
	playsoundatposition( "evt_balcony_plane_crash", self.origin);

	balcony_lights = GetEntArray( "balcony_lights", "script_noteworthy" );
	array_func( balcony_lights, ::physics_launch_me );

	balcony_physics_structs = getstructarray( "balcony_physics_structs", "targetname" );
	for( i = 0; i < balcony_physics_structs.size; i++ )
	{
		PhysicsExplosionSphere( balcony_physics_structs[i].origin, 64, 64, 0.5 );
	}

	self waittill( "reached_end_node" );
	//C. Ayers: Currently, this doesn't sync up with the rumble fx, so I'm moving this temporarily
	//self playsound( "evt_balcony_plane_crash" );
	PlayFX( level._effect[ "darwins_vehicle_explosion" ], self.origin );
	self veh_magic_bullet_shield( 0 );
	self Delete();
}

init_vehicle_lights()
{
	if( self.vehicletype == "t5_veh_apc_btr60" )
	{
		//head-lights
		PlayFXOnTag(level._effect["btr_headlight_fx"], self, "tag_headlight_left" );
		PlayFXOnTag(level._effect["btr_headlight_fx"], self, "tag_headlight_right" );
	
		//tail-lights
		PlayFXOnTag(level._effect["btr_taillight"], self, "tag_tail_light_left" );
		PlayFXOnTag(level._effect["btr_taillight"], self, "tag_tail_light_right" );
	}
	else if( self.vehicletype == "jeep_uaz_closetop_physics" )
	{
		//head-lights
		PlayFXOnTag(level._effect["uaz_headlight"], self, "tag_headlight_left" );
		PlayFXOnTag(level._effect["uaz_headlight"], self, "tag_headlight_right" );

		//tail-lights
		PlayFXOnTag(level._effect["btr_taillight"], self, "tag_tail_light_left" );
		PlayFXOnTag(level._effect["btr_taillight"], self, "tag_tail_light_right" );
	}
	else if( self.vehicletype == "truck_gaz63_canvas" )
	{
		//head-lights
		PlayFXOnTag(level._effect["uaz_headlight"], self, "tag_headlight_left" );
		PlayFXOnTag(level._effect["uaz_headlight"], self, "tag_headlight_right" );

		//tail-lights
		PlayFXOnTag(level._effect["btr_taillight"], self, "tag_tail_light_left" );
		PlayFXOnTag(level._effect["btr_taillight"], self, "tag_tail_light_right" );
	}
	else if( self.vehicletype == "truck_gaz63_troops" )
	{
		//head-lights
		PlayFXOnTag(level._effect["uaz_headlight"], self, "tag_headlight_left" );
		PlayFXOnTag(level._effect["uaz_headlight"], self, "tag_headlight_right" );

		//tail-lights
		PlayFXOnTag(level._effect["btr_taillight"], self, "tag_tail_light_left" );
		PlayFXOnTag(level._effect["btr_taillight"], self, "tag_tail_light_right" );
	}
}

physics_launch_me()
{
	self PhysicsLaunch( self.origin, (0, 0, 0) );
}

monitor_plane_flyby() //self == plane
{
	self endon("death");

	player = get_players()[0];

	plane_close = false;
	while( !plane_close )
	{
		if( DistanceSquared( player.origin, self.origin ) < ( 1500 * 1500 ) )
		{
			self thread plane_position_updater (3200, "evt_f4_short_wash", "null"); 
			Earthquake( 0.3, 1, player.origin, 512 );
			player PlayRumbleOnEntity( "damage_heavy" );
			plane_close = true;
			
		}
		else
		{
			wait(0.1);
		}
	}
}

spawn_courtyard_planes()
{
	level endon("stop_low_bombers");
			
	nodes = GetVehicleNodeArray("courtyard_bombing_paths","targetname");
	maps\_plane_weapons::build_bombs( "plane_mig17_gear", "aircraft_bomb", "explosions/fx_mortarExp_dirt", "artillery_explosion" );
	maps\_plane_weapons::build_bomb_explosions( "plane_mig17_gear", 0.5, 2.0, 1024, 768, 400, 25 );	

	while(1)
	{
		node = random(nodes);	
		plane = SpawnVehicle("t5_veh_jet_mig17_gear", "airfield_bomb", "plane_mig17_gear", node.origin, node.angles);
		
		plane.script_numbombs =  2;
		maps\_vehicle::vehicle_init(plane);
		plane thread go_path(node);
		wait(RandomIntRange(5,10));
	}
}

init_bookshelf_guy(node)
{
	//ai that knocks bookshelf down 
	collision = GetEnt ("bookshelf_player_collision", "targetname");
	collision NotSolid();
	
	self endon( "death" );
	level endon ("bookshelf_guy_dead");

	//node = GetNode (self.target, "targetname");
	self.animname = "guy";
	self.goalradius = 32;
	self.ignoreme = true;
	self.ignoreall = true;	
	self.ignoresuppression = 1;	
	self.allowdeath = 1;
	self.DeathFunction = ::bookshelfguy_death;

	bookshelf = GetEnt( "bookshelf", "targetname" );
	bookshelf.animname = "cabinet";
	bookshelf UseAnimTree( level.scr_animtree["cabinet"] );
	ents = array(bookshelf,self);
	
	bookshelf_align_struct = getstruct( "bookshelf_align_struct", "targetname" );
	bookshelf_align_struct anim_reach_aligned( self, "make_cover_left" ); 

	//TUEY BOOKSHELF FALLDUDE guy knocking bookshelf over here
	bookshelf_align_struct anim_single_aligned( ents, "make_cover_left" ); 
	flag_set ("bookshelf_guy_done");
	collision Solid();
	
	//enable his crouch node 
	SetEnableNode (node, true);
	
	self AllowedStances ("crouch");
	self SetGoalNode (node);
	//self SetGoalPos (self.origin)	;
	self.ignoreme = false;
	self.ignoreall = false;	
	self.ignoresuppression = 0;
	
	wait(5);
	
	self.goalradius = 2048;
	self AllowedStances ("stand", "crouch");

}

bookshelfguy_death()
{
	self ragdoll_death();
	level notify ("bookshelf_guy_dead");
	
	if(!flag("bookshelf_guy_done"))
	{
		flag_set("bookshelf_guy_done");
	}
		
}

#using_animtree ("generic_human");
//monitor_bookshelf_interuption()
//{
//	self waittill_any( "damage", "bookshelf_dropped" );
//
//	self.goalradius = 2048;
//	self.ignoreme = false;
//	self.ignoreall = false;	
//	self.ignoresuppression = 0;
//}

init_roof_enemies()
{
	self endon( "death" );

	self.ignoreme = true;
	self.pacifist = true;
	self.goalradius = 16;
	self.ignoreall = true;

	flag_wait( "woods_stop_shooting" );

 	self waittill_any("damage", "explode", "bulletwhizby", "enemy", "player_engaged" );

	level notify( "player_engaged" );

	self set_spawner_targets( "ambient_balcony_nodes" );
	self.pacifist = false;
	self.goalradius = 2048;
	//self.ignoreme = false;
	self.ignoreall = false;
	self enable_cqbwalk();
}

woods_play_moveup_line()
{
	//self = level

	//establish the array of lines to use
	if(!IsDefined(level.moveup_lines))
	{
		level.moveup_lines = [];
		level.moveup_lines[level.moveup_lines.size] ="keep_moving_woods";
		level.moveup_lines[level.moveup_lines.size] ="move_up";
		level.moveup_lines[level.moveup_lines.size] ="push_fwd";
		level.moveup_lines[level.moveup_lines.size] ="move_quickly";
	}
	
	//and the used_lines array as well
	if(!IsDefined(level.used_moveup_lines))
	{
		level.used_moveup_lines = [];
	}	
	
	//mix up the array and pick a random one
	mixed_lines = array_randomize( level.moveup_lines );
	random_line = random (mixed_lines);
	
	//have woods say random line	
	level.woods thread maps\_anim::anim_single_queue( level.woods, random_line );
	
	//do the "on me" handsignal if woods is not moving and is standing
	if ( (level.woods.a.movement == "stop") && (level.woods.a.pose == "stand") )
	{ 
		level.woods thread handsignal ("onme");
	}	
		
	//add that line to the used array
	level.used_moveup_lines = add_to_array (level.used_moveup_lines, random_line );
	
	//remove the line from the lines array
	level.moveup_lines = array_remove (level.moveup_lines, random_line);
	
	//IPrintLn ("moveup lines remaining: " +level.moveup_lines.size);
	
	//if we've used all the lines
	if(level.moveup_lines.size == 0)
	{
		//reset the array 
		level.moveup_lines = level.used_moveup_lines;
		
		//empty the used lines array
		level.used_moveup_lines = [];
		//IPrintLn ("replenished moveup lines array");
	}	

}	

squad_sprint()
{
	
	trigger_wait ("move_mid_lobby");
	heroes = get_heroes_by_name("woods", "bowman");
	for (i = 0; i < heroes.size; i++ )
	{
		heroes[i].sprint = 1;
	}

}	

courtyard_50cal_damage_override(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName)
{	
	//waittillframeend;
	if(self.health >= 950)
	{
		return iDamage;
	}
	//health less than 900 and has not blown up yet
	else if( (self.health <= 950)&&(!IsDefined(level.killed_50cal)) )
	{
		//Faux death (no deathmodel)
		PlayFX (level._effect["darwins_vehicle_explosion"], self.origin);
		PlaySoundatposition( "exp_veh_large", self.origin );
		Earthquake( .30, .50, get_players()[0].origin, 100 );
		get_players()[0] PlayRumbleOnEntity("damage_heavy");

		level.killed_50cal = 1;		
		iDamage = 0;
		return iDamage;		
	}
	else
	{
		iDamage = 0;
		return iDamage;
	}	

}	

outside_courtyard_mortars()
{
	flag_wait ("player_outside_mansion");
	
	spots = getstructarray ("courtyard_mortar", "targetname");
	player = get_players()[0];
	
	while(!flag("stop_sugarcane_nag_lines"))
	{
		spot = random(spots);
		level thread do_a_mortar(spot, player);
		wait(RandomIntRange(8,15));
	}	
	
	trigger_wait ("player_on_road");
	spot = getstruct ("sugarfield_crater1", "targetname");
	wait(1.5);
	level thread do_a_mortar(spot, player);
	wait(RandomFloatRange(2.5, 3.2));
	spot = getstruct ("sugarfield_crater2", "targetname");
	level thread do_a_mortar(spot, player);

}	

do_a_mortar(spot, player)
{
	radius = 2048;
	ent = spawn("script_origin",spot.origin);
	playfx(level._effect["airfield_ambient_mortar"],spot.origin);
	Earthquake( .5, .7, player.origin, radius ); 
	ent playsound("exp_mortar_dirt","sounddone");	
	level thread maps\_mortar::mortar_rumble_on_all_players("damage_light","damage_heavy", player.origin, radius * 0.75, radius * 1.25);
	ent waittill("sounddone");
	ent delete();		
}			

squad_at_steps()
{
	//to prevent color chain backtracking
	flag_wait ("player_at_stairs"); //brush trig by stairs
	if(!flag("squad_downstairs"))
	{
		trigger_use ("squad_to_stairs"); //trig_radius floating. Sends squad to steps
	}	
	
}	


squad_auto_move()
{
	//if player hangs back, squad moves up anyways
	waittill_ai_group_cleared ("mansion_front_enemies");
	if(!flag("player_at_stairs"))
	{
		trigger_use ("chandelier_brush_trig", "script_noteworthy");
	}
}	