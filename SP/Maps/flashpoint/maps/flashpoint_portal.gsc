////////////////////////////////////////////////////////////////////////////////////////////
// FLASHPOINT LEVEL UTILITY SCRIPTS
// PJL 04/21/10
//
// Utility Scripts for use in Flashpoint
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
////////////////////////////////////////////////////////////////////////////////////////////
#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;


main()
{
	//Portal Location def:
	level.loc_compound = ( -320, -320, 288 );
	level.loc_comm = ( -1404, 196, 388 );
	level.loc_weaver = ( -4860, -316, 388 );
	level.loc_gantry = ( -6716, 4292, 516 );
	level.loc_c4 = ( -9980, 3012, 452 );
	level.loc_facility = ( -6524, 7940, 900 );

	level thread set_portal_override_start();
	level thread set_portal_override_migsoverhead();
	level thread set_portal_override_woods_door_kick();
	level thread set_portal_override_comms_roof();
	level thread set_portal_override_flame_trench();
	level thread set_portal_override_gantry_battle();
	level thread set_portal_override_missioncontrol_exit();
}

set_portal_override_start()
{
	level waittill( "set_portal_override_start" );
	
	//At level start
	SetCellInvisibleAtPos( level.loc_compound ); 
	SetCellInvisibleAtPos( level.loc_comm );
	SetCellInvisibleAtPos( level.loc_weaver );
	SetCellInvisibleAtPos( level.loc_gantry );
	SetCellInvisibleAtPos( level.loc_c4 );
	//SetCellInvisibleAtPos( level.loc_facility );
}

set_portal_override_event2_jumpto()
{
	wait( 1.0 );
	SetCellInvisibleAtPos( level.loc_compound ); 
	SetCellInvisibleAtPos( level.loc_comm );
	SetCellInvisibleAtPos( level.loc_weaver );
	SetCellInvisibleAtPos( level.loc_gantry );
	SetCellInvisibleAtPos( level.loc_c4 );
	//SetCellInvisibleAtPos( level.loc_facility );
}

set_portal_override_event3_jumpto()
{
	wait( 1.0 );
	SetCellInvisibleAtPos( level.loc_compound ); 
	SetCellInvisibleAtPos( level.loc_comm );
	SetCellInvisibleAtPos( level.loc_weaver );
	SetCellInvisibleAtPos( level.loc_gantry );
	SetCellInvisibleAtPos( level.loc_c4 );
	//SetCellInvisibleAtPos( level.loc_facility );
}

set_portal_override_event4_jumpto()
{
	wait( 1.0 );
	SetCellVisibleAtPos( level.loc_compound ); 
	SetCellInvisibleAtPos( level.loc_comm );
	SetCellInvisibleAtPos( level.loc_weaver );
	SetCellInvisibleAtPos( level.loc_gantry );
	SetCellInvisibleAtPos( level.loc_c4 );
	//SetCellInvisibleAtPos( level.loc_facility );
}

set_portal_override_event5_jumpto()
{
	wait( 1.0 );
	SetCellVisibleAtPos( level.loc_compound ); 
	SetCellVisibleAtPos( level.loc_comm );
	SetCellInvisibleAtPos( level.loc_weaver );
	SetCellInvisibleAtPos( level.loc_gantry );
	SetCellInvisibleAtPos( level.loc_c4 );
	//SetCellInvisibleAtPos( level.loc_facility );
}

set_portal_override_event6_jumpto()
{
	wait( 1.0 );
	SetCellVisibleAtPos( level.loc_compound ); 
	SetCellVisibleAtPos( level.loc_comm );
	SetCellVisibleAtPos( level.loc_weaver );
	SetCellVisibleAtPos( level.loc_gantry );
	SetCellInvisibleAtPos( level.loc_c4 );
	//SetCellInvisibleAtPos( level.loc_facility );
}

set_portal_override_event7_jumpto()
{
	wait( 1.0 );
	SetCellVisibleAtPos( level.loc_compound ); 
	SetCellVisibleAtPos( level.loc_comm );
	SetCellVisibleAtPos( level.loc_weaver );
	SetCellVisibleAtPos( level.loc_gantry );
	SetCellInvisibleAtPos( level.loc_c4 );
	//SetCellInvisibleAtPos( level.loc_facility );
}

set_portal_override_event8_jumpto()
{
	wait( 1.0 );
	SetCellInvisibleAtPos( level.loc_compound ); 
	SetCellVisibleAtPos( level.loc_comm );
	SetCellVisibleAtPos( level.loc_weaver );
	SetCellVisibleAtPos( level.loc_gantry );
	SetCellVisibleAtPos( level.loc_c4 );
	//SetCellInvisibleAtPos( level.loc_facility );
}

set_portal_override_event9_jumpto()
{
	wait( 1.0 );
	SetCellVisibleAtPos( level.loc_compound ); 
	SetCellVisibleAtPos( level.loc_comm );
	SetCellVisibleAtPos( level.loc_weaver );
	SetCellVisibleAtPos( level.loc_gantry );
	SetCellVisibleAtPos( level.loc_c4 );
	//SetCellVisibleAtPos( level.loc_facility );
}

set_portal_override_event10_jumpto()
{
	wait( 1.0 );
	SetCellVisibleAtPos( level.loc_compound ); 
	SetCellVisibleAtPos( level.loc_comm );
	SetCellVisibleAtPos( level.loc_weaver );
	SetCellVisibleAtPos( level.loc_gantry );
	SetCellVisibleAtPos( level.loc_c4 );
	//SetCellVisibleAtPos( level.loc_facility );
}

set_portal_override_event11_jumpto()
{
	wait( 1.0 );
	SetCellVisibleAtPos( level.loc_compound ); 
	SetCellVisibleAtPos( level.loc_comm );
	SetCellVisibleAtPos( level.loc_weaver );
	SetCellVisibleAtPos( level.loc_gantry );
	SetCellVisibleAtPos( level.loc_c4 );
	//SetCellVisibleAtPos( level.loc_facility );
}

set_portal_override_event12_jumpto()
{
	wait( 1.0 );
	SetCellVisibleAtPos( level.loc_compound ); 
	SetCellVisibleAtPos( level.loc_comm );
	SetCellVisibleAtPos( level.loc_weaver );
	SetCellVisibleAtPos( level.loc_gantry );
	SetCellVisibleAtPos( level.loc_c4 );
	//SetCellVisibleAtPos( level.loc_facility );
}

set_portal_override_event13_jumpto()
{
	wait( 1.0 );
	SetCellVisibleAtPos( level.loc_compound ); 
	SetCellVisibleAtPos( level.loc_comm );
	SetCellVisibleAtPos( level.loc_weaver );
	SetCellVisibleAtPos( level.loc_gantry );
	SetCellVisibleAtPos( level.loc_c4 );
	//SetCellVisibleAtPos( level.loc_facility );
}

set_portal_override_event14_jumpto()
{
	wait( 1.0 );
	SetCellVisibleAtPos( level.loc_compound ); 
	SetCellVisibleAtPos( level.loc_comm );
	SetCellVisibleAtPos( level.loc_weaver );
	SetCellVisibleAtPos( level.loc_gantry );
	SetCellVisibleAtPos( level.loc_c4 );
	//SetCellVisibleAtPos( level.loc_facility );
}

set_portal_override_event15_jumpto()
{
	wait( 1.0 );
	SetCellVisibleAtPos( level.loc_compound ); 
	SetCellVisibleAtPos( level.loc_comm );
	SetCellVisibleAtPos( level.loc_weaver );
	SetCellVisibleAtPos( level.loc_gantry );
	SetCellVisibleAtPos( level.loc_c4 );
	//SetCellVisibleAtPos( level.loc_facility );
}

set_portal_override_event16_jumpto()
{
	wait( 1.0 );
	SetCellVisibleAtPos( level.loc_compound ); 
	SetCellVisibleAtPos( level.loc_comm );
	SetCellVisibleAtPos( level.loc_weaver );
	SetCellVisibleAtPos( level.loc_gantry );
	SetCellVisibleAtPos( level.loc_c4 );
	//SetCellVisibleAtPos( level.loc_facility );
}

set_portal_override_event17_jumpto()
{
	wait( 1.0 );
	SetCellVisibleAtPos( level.loc_compound ); 
	SetCellVisibleAtPos( level.loc_comm );
	SetCellVisibleAtPos( level.loc_weaver );
	SetCellVisibleAtPos( level.loc_gantry );
	SetCellVisibleAtPos( level.loc_c4 );
	//SetCellVisibleAtPos( level.loc_facility );
}

set_portal_override_migsoverhead()
{
	level waittill( "set_portal_override_migsoverhead" );
	
	//At about -316 -4156 324 :  - MIGS FLY OVER
	SetCellVisibleAtPos( level.loc_compound ); 
}

set_portal_override_woods_door_kick()
{
	level waittill( "set_portal_override_woods_door_kick" );
	
	//At Woods kick comm. door open:
	SetCellVisibleAtPos( level.loc_comm );
}

set_portal_override_comms_roof()
{
	level waittill( "set_portal_override_comms_roof" );
	
	//At player reaching roof of comm.:
	SetCellVisibleAtPos( level.loc_weaver );
	SetCellVisibleAtPos( level.loc_gantry );
}


set_portal_override_flame_trench()
{
	level waittill( "set_portal_override_flame_trench" );
	
	//At flame trench scientist start:
	SetCellInvisibleAtPos( level.loc_weaver );
	SetCellInvisibleAtPos( level.loc_compound ); 
}

set_portal_override_gantry_battle()
{
	level waittill( "set_portal_override_gantry_battle" );
	
	//At end of gantry battle:
	SetCellVisibleAtPos( level.loc_c4 );
}

set_portal_override_missioncontrol_exit()
{
	level waittill( "set_portal_override_missioncontrol_exit" );	//not done
	
	//At exit of mission control:
	//SetCellVisibleAtPos( level.loc_facility );
}


////////////////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////////////////