#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_zombiemode_utility;
#include maps\_zombiemode_utility_raven;



//-----------------------------------------------
// name: 	init_electric_switch
// self: 	level
// return:	nothing
// desc:	sets up the electricity switch
//------------------------------------------------
init_electric_switch()
{
	flag_wait( "all_players_connected" );
	
	// sets up blockers that get removed when the power turns on
	level.power_blockers = GetEntArray ("temple_power_door", "targetname");
	
	// setup flags used by the power switches
	flag_init( "left_switch_pulled" );
	flag_init( "right_switch_pulled" );
	flag_init( "left_switch_done" );
	flag_init( "right_switch_done" );
	
	water_wheel_init();
	left_power_switch_model = getEnt("elec_switch_left", "targetname");
	right_power_switch_model = getEnt("elec_switch_right", "targetname");
	level thread power_switch("power_trigger_left", "left_switch_pulled");
	level thread power_switch("power_trigger_right", "right_switch_pulled");
	left_power_switch_model thread wait_for_power_switch("left_switch_pulled", "left_switch_done");
	right_power_switch_model thread wait_for_power_switch("right_switch_pulled", "right_switch_done");
	level thread wait_for_power();
	level thread on_power_on();
}


//-------------------------------------
// name: 	water_wheel_init
// self: 	level
// return:	nothing
// desc:	sets up the water wheel
//--------------------------------------
water_wheel_init()
{
	//water_wheel_left = GetEnt( "water_wheel_left", "targetname" );
	//water_wheel_right = GetEnt( "water_wheel_right", "targetname" );

	// starts the water fx when the power is on
	level thread water_start("left_switch_done", 48, 25, false, "evt_waterwheel02");
	level thread water_start("right_switch_done", 49, 26, true, "evt_waterwheel01");
	
	level thread water_sounds_left();
	level thread water_sounds_right();
}

//-------------------------------------------
// name: 	power_switch
// self: 	level
// return:	nothing
// desc:	handles the power switch trigger being used
//--------------------------------------------
power_switch(trigger_name, switch_flag)
{
	switch_trigger = getEnt( trigger_name, "targetname" );
	switch_trigger setHintString( &"ZOMBIE_TEMPLE_RELEASE_WATER" );
	switch_trigger SetCursorHint( "HINT_NOICON" );
	while( true )
	{
		switch_trigger waittill( "trigger", player );
		
		if( IsPlayer( player ) )
		{
			flag_set( switch_flag );
			break;
		}
	}
	switch_trigger delete();
	
	level thread play_poweron_vox( player );
}

play_poweron_vox( player )
{
	level notify( "end_duplicate_poweron_vox" );
	level endon( "end_duplicate_poweron_vox" );
	
	wait(5);
	
	if( isdefined( player ) && flag("power_on") )
	{
		player thread maps\_zombiemode_audio::create_and_play_dialog( "general", "poweron" );
	}
}

//-------------------------------------------
// name: 	wait_for_power_switch
// self: 	power switch model
// return:	nothing
// desc:	waits for water wheel to turn on
//--------------------------------------------
wait_for_power_switch(switch_flag, switch_done_flag)
{
	flag_wait( switch_flag );

	// flip the power switch
	master_switch = self;	
	master_switch notsolid();
	master_switch rotateroll(-90,.5);
	master_switch playsound("zmb_switch_flip");
	
	master_switch waittill("rotatedone");
	
	master_switch playsound("zmb_turn_on");
	
	flag_set( switch_done_flag );	
}


//-------------------------------------------
// name: 	wait_for_power
// self: 	level
// return:	nothing
// desc:	turns on objects that need power
//--------------------------------------------
wait_for_power()
{
	flag_wait("left_switch_done");
	flag_wait("right_switch_done");
	wait(1.0);
	flag_set("power_on");
}

//-------------------------------------------
// name: 	on_power_on
// self: 	level
// return:	nothing
// desc:	actions to start when power is on
//--------------------------------------------
on_power_on()
{
	flag_wait("power_on");
	
	//Set flags in case this was turned on by the debug menu
	flag_set("left_switch_pulled");
	flag_set("right_switch_pulled");
	
	// Set Perk Machine Notifys
	level thread activate_perk_machines();
	
    clientnotify( "ZPO" );	

	for(i=0; i<level.power_blockers.size; i++)
	{
		level.power_blockers[i] ConnectPaths();
	}
	array_delete (level.power_blockers);
	
	//Sounds!
	playsoundatposition("zmb_poweron_front", (0,0,0));
	playsoundatposition("zmb_poweron_rear", (0,0,0));

	//maps\zombie_temple_elevators::raise_pack_a_punch_elevator_gate();
	// Model swap on client side waits 4.5 seconds before "turning on". The corona activation should happen around the same time.
	realwait( 4.5 );
	Exploder(15);
}

activate_perk_machines()
{
	level notify("juggernog_on");
	wait_network_frame();
	level notify("sleight_on");
	wait_network_frame();
	level notify("revive_on");
	wait_network_frame();
	level notify("marathon_on");
	wait_network_frame();
	level notify("divetonuke_on");
	wait_network_frame();
	level notify("deadshot_on");
	wait_network_frame();
	level notify("doubletap_on");
	wait_network_frame();
	level notify("Pack_A_Punch_on" );
}



//------------------------------------------------
// name: 	move_water_covers
// self: 	level
// return:	nothing
// desc:	moves the covers that block the water from flowing
//-------------------------------------------------
move_water_covers(name_of_water_covers)
{
	water_covers = GetEntArray( name_of_water_covers, "targetname" );
	for ( i = 0; i < water_covers.size; i++ )
	{
		water_covers[i] thread _moveZ(-180, 4.0, .25, .25);
	}
}


//------------------------------------------------
// name: 	_moveZ
// self: 	none
// return:	nothing
// desc:	wrapper function to thread a move
//-------------------------------------------------
_moveZ(z_value, time, acceleration_time, deceleration_time)
{
	self moveZ( z_value, time, acceleration_time, deceleration_time );
}


//----------------------------------------------------------------------
// name: 	water_start
// self: 	wheel mover
// return:	nothing
// desc:	keeps track of the players entering and leaving the trigger
//-----------------------------------------------------------------------
water_start(switch_done_flag, water_exploder, spark_exploder, isRight,sound)
{
	flag_wait( switch_done_flag );
	wait(3.5);
	exploder(water_exploder);
	stop_exploder(spark_exploder);
	//wheel_water_origin = GetEnt( water_fx_ent_name, "targetname" );
	//playFxOnTag(level._effect["waterfall_trap"], wheel_water_origin, "tag_origin");
	wait(1.2);
	
	soundEnt = GetEnt(sound + "_origin", "targetname");
	if(isDefined(soundEnt))
	{
		soundEnt playloopsound(sound, 1);
	}
		
	water_wheel_rotate_constant(isRight);
}

water_sounds_left()
{
	flag_wait( "left_switch_done" );
	wait(3.5);
	
	// Play the wind-up sound
	start_struct = getstruct( "water_spout_01", "targetname" );
	if( IsDefined( start_struct ) )
	{
		level thread play_sound_in_space( "evt_water_spout01", start_struct.origin );
	}
	
	wait( 1.0 );
	
	// Play the looping sound
	loop_struct = getstruct( "water_pour_01", "targetname" );
	if( IsDefined( loop_struct ) )
	{
		sound_entity = Spawn( "script_origin", ( 0, 0, 1 ) );
		sound_entity.origin = loop_struct.origin;
		sound_entity thread play_loop_sound_on_entity( "evt_water_pour01" );
	}
}

water_sounds_right()
{
	flag_wait( "right_switch_done" );
	wait(3.5);
	
	// Play the wind-up sound
	start_struct = getstruct( "water_spout_02", "targetname" );
	if( IsDefined( start_struct ) )
	{
		level thread play_sound_in_space( "evt_water_spout02", start_struct.origin );
	}
	
	wait( 1.0 );
	
	// Play the looping sound
	loop_struct = getstruct( "water_pour_02", "targetname" );
	if( IsDefined( loop_struct ) )
	{
		sound_entity = Spawn( "script_origin", ( 0, 0, 1 ) );
		sound_entity.origin = loop_struct.origin;
		sound_entity thread play_loop_sound_on_entity( "evt_water_pour02" );
	}
}	

//-------------------------------------------------
// name: 	water_wheel_rotate_constant
// self: 	wheel mover
// return:	nothing
// desc:	the water wheel will rotate forever
//--------------------------------------------------
water_wheel_rotate_constant(isRight)
{
	if ( isRight )
	{
		clientNotify("wwr");
	}
	else
	{
		clientNotify("wwl");
	}

	//rotate = 120;
	//if ( invertRotation )
	//{
	//	rotate = 0 - rotate;
	//}
	//while( true )
	//{
	//	self RotatePitch(rotate, 2, 0, 0);
	//	wait( 2 );
	//}
}
