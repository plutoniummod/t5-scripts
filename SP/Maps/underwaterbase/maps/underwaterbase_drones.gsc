/*
//-- Level: Underwater Base
//-- Level Designer: Gavin Goslin
//-- Scripter: Alfeche/Vento
*/


#include maps\_utility;
#include common_scripts\utility; 
#include maps\_utility_code;

init_drones()
{	
	//level.drone_spawnFunction["axis"] = character\c_rus_spetznaz_assault::main;
	//level.drone_spawnFunction["allies"] = character\c_vtn_vc2_drone::main;	
	//level.drone_rpg = "rpg_player_sp";

	//level.max_drones = [];
	//level.max_drones["axis"] = 100; 
	//level.max_drones["allies"] = 32; 
	//
	//maps\_drones::init();
}

precache_drones()
{
//	character\c_vtn_vc2_drone::precache();
//	character\c_rus_spetznaz_assault::precache();	
}

start_drone_spawning_area( trigger_area_target )
{
	triggers = GetEntArray( trigger_area_target, "target");
	for(i=0; i<triggers.size; i++)
	{
		triggers[i] UseBy(get_players()[0]);			
	}	
}

stop_drone_spawning_area( trigger_area_target )
{
	drone_trigs = getentarray( trigger_area_target, "target" );
	for(i=0; i<drone_trigs.size; i++)
	{
		drone_trigs[i] notify( "stop_drone_loop" );
	}
}

send_drones_notify( team, notify_msg )
{
	for(i=0; i< level.drones[team].array.size; i++)
	{
		level.drones[team].array[i] notify(notify_msg);	
	}	
}