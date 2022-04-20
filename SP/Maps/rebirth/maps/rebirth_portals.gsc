#include common_scripts\utility; 
#include maps\_utility;



rb_portals_level_start()
{
	
	// IPrintLn( "rb_portal: level start" );
	//SetCellInvisibleAtPos( (11268, 9412, 772) );
	SetCellInvisibleAtPos( (9956, 9220, 772) );
	SetCellInvisibleAtPos( (11524, 10196, 1548) );

	SetCellInvisibleAtPos( (9364, 6772, 788) );
	SetCellInvisibleAtPos( (9188, 8308, 788) );
	SetCellInvisibleAtPos( (8468, 9396, 788) );
	SetCellInvisibleAtPos( (7940, 8244, 788) );
	SetCellInvisibleAtPos( (7828, 9668, 868) );
	SetCellInvisibleAtPos( (7540, 9508, 868) );
	SetCellInvisibleAtPos( (7540, 9508, 740) );
}

rb_portals_btr_rail()
{
	// IPrintLn( "rb_portal: btr rail" );
	SetCellVisibleAtPos( (11268, 9412, 772) );
	SetCellVisibleAtPos( (9956, 9220, 772) );
	SetCellVisibleAtPos( (11524, 10196, 1548) );

	SetCellVisibleAtPos( (9364, 6772, 788) );
	SetCellVisibleAtPos( (9188, 8308, 788) );
	SetCellVisibleAtPos( (8468, 9396, 788) );
	SetCellVisibleAtPos( (7940, 8244, 788) );
	SetCellVisibleAtPos( (7828, 9668, 868) );
	SetCellVisibleAtPos( (7540, 9508, 868) );
	SetCellVisibleAtPos( (7540, 9508, 740) );

	SetCellInvisibleAtPos( (13252, 12100, 324) );
	SetCellInvisibleAtPos( (15044, 13892, 676) );
	SetCellInvisibleAtPos( (18724, 13316, 132) );
	SetCellInvisibleAtPos( (11660, 10276, 1548) );
}

rb_portals_strela()
{
	// IPrintLn( "rb_portal: strela event" );
	SetCellVisibleAtPos( (13252, 12100, 324) );
	SetCellVisibleAtPos( (15044, 13892, 676) );
	SetCellVisibleAtPos( (18724, 13316, 132) );
	SetCellVisibleAtPos( (11660, 10276, 1548) );
}