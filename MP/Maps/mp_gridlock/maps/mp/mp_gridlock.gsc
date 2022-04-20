#include common_scripts\utility;

main()
{
	//needs to be first for create fx
	maps\mp\mp_gridlock_fx::main();
	
	precachemodel("collision_geo_32x32x32");	
	precachemodel("collision_geo_64x64x64");	

	maps\mp\_load::main();

//	maps\mp\_compass::setupMiniMap("compass_map_mp_convoy"); 
	if ( GetDvarInt( #"xblive_wagermatch" ) == 1 )
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_convoy_wager");
	}
	else
	{
		maps\mp\_compass::setupMiniMap("compass_map_mp_convoy");
	}	
	
	maps\mp\mp_gridlock_amb::main();

	// If the team nationalites change in this file, you must also update the level's csc file,
	// the level's csv file, and the share/raw/mp/mapsTable.csv
	maps\mp\gametypes\_teamset_urbanspecops::level_init();

	// Set up the default range of the compass
	setdvar("compassmaxrange","2100");

	// Set up some generic War Flag Names.
	// Example from COD5: CALLSIGN_SEELOW_A is the name of the 1st flag in Selow whose string is "Cottage" 
	// The string must have MPUI_CALLSIGN_ and _A. Replace Mapname with the name of your map/bsp and in the 
	// actual string enter a keyword that names the location (Roundhouse, Missle Silo, Launchpad, Guard Tower, etc)

	game["strings"]["war_callsign_a"] = &"MPUI_CALLSIGN_MAPNAME_A";
	game["strings"]["war_callsign_b"] = &"MPUI_CALLSIGN_MAPNAME_B";
	game["strings"]["war_callsign_c"] = &"MPUI_CALLSIGN_MAPNAME_C";
	game["strings"]["war_callsign_d"] = &"MPUI_CALLSIGN_MAPNAME_D";
	game["strings"]["war_callsign_e"] = &"MPUI_CALLSIGN_MAPNAME_E";

	game["strings_menu"]["war_callsign_a"] = "@MPUI_CALLSIGN_MAPNAME_A";
	game["strings_menu"]["war_callsign_b"] = "@MPUI_CALLSIGN_MAPNAME_B";
	game["strings_menu"]["war_callsign_c"] = "@MPUI_CALLSIGN_MAPNAME_C";
	game["strings_menu"]["war_callsign_d"] = "@MPUI_CALLSIGN_MAPNAME_D";
	game["strings_menu"]["war_callsign_e"] = "@MPUI_CALLSIGN_MAPNAME_E";

	// spawn collision to stop players from hiding in a chunk of rubble under the overpass
	spawncollision("collision_geo_32x32x32","collider",(-234, 278, -107), (0, 0, 0));
	spawncollision("collision_geo_32x32x32","collider",(-234, 310, -108), (0, 0, 0));
	
	// spawn collision to stop players from exploiting missile trailer hitch
	spawncollision("collision_geo_64x64x64","collider",(809, 131, 134), (0, 0, 0));
	
	// enable new spawning system
	maps\mp\gametypes\_spawning::level_use_unified_spawning(true);

	//spawn light bar for hanging freeway sign
	
	signbase1 = Spawn("script_model", (37, 528.5, 24) );
	if ( IsDefined(signbase1) )
	{
		signbase1.angles = (0, 180, 0);
		signbase1 SetModel("p_con_hwy_sign_base");
	}

	maps\mp\_clientflags::init();

	//Air pumps play a sound when players step on them.
	thread air_pump_trigger_init();

	//Manages lights on police car (Also see client scripts)
	thread police_car_light_init();

	//Handles path nodes that exists next to 'Domination' 'B' flag
	node_manager();
}

//Handles extra path nodes needed for 'Domination
node_manager()
{
	node_catcher = GetEnt( "node_catcher", "targetname" );
	AssertEx( IsDefined( node_catcher ), "Script brush model with targetname 'node_catcher' is missing" );

	node_catcher Delete();

	path_breaker = GetEnt( "path_breaker", "targetname" );
	AssertEx( IsDefined( path_breaker ), "Script brush model with targetname 'path_breaker' is missing" );

	if( IsDefined( level.gametype ) && level.gametype == "dom" )
	{
		path_breaker Delete();
	}
	else
	{
		path_breaker DisconnectPaths();

	}
}

air_pump_trigger_init()
{
	air_pump_trigs = GetEntArray ( "air_pump_trigger", "targetname" );

	if ( air_pump_trigs.size > 0)
	{
		array_thread( air_pump_trigs, ::air_pump_think );
	}
}

//self is the air pump trigger
air_pump_think()
{
	self.sound_spot = getstruct( self.target, "targetname" );
	AssertEx( IsDefined( self.sound_spot ),"An air pump trigger is missing a script_struct to target. Ent at " + self.origin );
	
	self.ents_on_me = 0;

	while ( 1 )
	{
		self waittill ( "trigger", player );
		self thread trigger_thread( player, ::air_pump_trig_on, ::air_pump_trig_off );

		//Cooldown between sounds
		wait .5;
	}
}

//self is the air pump trigger
air_pump_trig_on( player, endon_string )
{
	self thread air_pump_watcher( player );

	if ( self.ents_on_me == 0 )
	{
		PlaySoundAtPosition( "amb_air_pump", self.sound_spot.origin );
	}

	self.ents_on_me++;
}

//self is the air pump trigger
air_pump_trig_off( player )
{ 
	player notify( "air_pump_trig_off" );

	self.ents_on_me--;
}

//self is the air pump trigger
air_pump_watcher( player )
{ 	
	player endon( "air_pump_trig_off" );

	player waittill_any( "death", "disconnect" );
	self.ents_on_me--;
}

police_car_light_init()
{
	police_cars = GetEntArray( "police_car", "script_noteworthy" );
	
	/#
		PrintLn( "Police cars in map: " + police_cars.size );
	#/

	array_thread( police_cars, ::police_car_think );
}

police_car_think()
{
	self SetClientFlag( level.const_flag_police_car );

	self waittill( "death" );

	self ClearClientFlag( level.const_flag_police_car );
}

add_trigger_to_ent(ent) // Self == The trigger volume
{
	if(!IsDefined(ent._triggers))
	{
		ent._triggers = [];
	}
	
	ent._triggers[self GetEntityNumber()] = 1;
}

remove_trigger_from_ent(ent)	// Self == The trigger volume.
{
	if(!IsDefined(ent))
		return;

	if(!IsDefined(ent._triggers))
		return;
		
	if(!IsDefined(ent._triggers[self GetEntityNumber()]))
		return;
		
	ent._triggers[self GetEntityNumber()] = 0;
}

ent_already_in_trigger(trig)	// Self == The entity in the trigger volume.
{
	if(!IsDefined(self._triggers))
		return false;
		
	if(!IsDefined(self._triggers[trig GetEntityNumber()]))
		return false;
		
	if(!self._triggers[trig GetEntityNumber()])
		return false;
		
	return true;	// We're already in this trigger volume.
}

trigger_thread_death_monitor(ent, ender)
{
	ent waittill("death");
	self endon(ender);
	self remove_trigger_from_ent(ent);
}

trigger_thread(ent, on_enter_payload, on_exit_payload)	// Self == The trigger.
{
	ent endon("entityshutdown");
	ent endon("death");
	
	if(ent ent_already_in_trigger(self))
		return;
		
	self add_trigger_to_ent(ent);
	
	ender = "end_trig_death_monitor" + self GetEntityNumber() + " " + ent GetEntityNumber();
	self thread trigger_thread_death_monitor(ent, ender);  // If ent dies in trigger, clear trigger off of ent.

//	iprintlnbold("Trigger " + self.targetname + " hit by ent " + ent getentitynumber());
	
	endon_condition = "leave_trigger_" + self GetEntityNumber();
	
	if(IsDefined(on_enter_payload))
	{
		self thread [[on_enter_payload]](ent, endon_condition);
	}
	
	while(IsDefined(ent) && ent IsTouching(self))
	{
		wait(0.01);
	}

	ent notify(endon_condition);

//	iprintlnbold(ent getentitynumber() + " leaves trigger " + self.targetname + ".");

	if(IsDefined(ent) && IsDefined(on_exit_payload))
	{
		self thread [[on_exit_payload]](ent);
	}

	if(IsDefined(ent))
	{
		self remove_trigger_from_ent(ent);
	}

	self notify(ender);	// Get rid of the death monitor thread.

}
