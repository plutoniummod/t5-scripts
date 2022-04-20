// Destructible initialization script
#include maps\_waw_destructible;
#using_animtree( "waw_vehicles" );

init_blitz()
{
	set_function_pointer( "explosion_anim", "dest_opel_blitz", ::get_explosion_animation );
	set_function_pointer( "flattire_anim", "dest_opel_blitz", ::get_flattire_animation );

	build_destructible_radiusdamage( "dest_opel_blitz", undefined, 260, 240, 40, true );
	build_destructible_deathquake( "dest_opel_blitz", 0.6, 1.0, 600 );

	set_pre_explosion( "dest_opel_blitz", "destructibles/fx_dest_fire_car_fade_40" );


	//hide all the broken pieces in the map
	blitzes = GetEntArray("broken_blitz", "script_noteworthy");
	for(i = 0; i < blitzes.size; i++)
	{
//		blitzes[i] hide();
	}

// 	blitzes = GetDynModels();
// 	for(i = 0; i < blitzes.size; i++)
// 	{
// 		if(blitzes[i].script_noteworthy == "broken_blitz")
// 		{
// 			origin = blitzes[i].origin;
// 			blitzes[i] MoveTo(origin - (0,0,1000));
// 			//blitzes[i] hide();
// 		}
// 	}


}

//set_pre_explosion( def, fx )
//{
//	level._effect[def + "_preexplode"] = LoadFx( fx );
//}
//
//build_destructible_deathquake( destructible_def, scale, duration, radius )
//{
//	
//	if( !isdefined( level.vehicle_death_earthquake ) )
//	{
//		level.vehicle_death_earthquake = []; 	
//	}
//	
//	level.vehicle_death_earthquake[ destructible_def ] = spawnstruct();
//	
//	level.vehicle_death_earthquake[ destructible_def ].scale = scale; 
//	level.vehicle_death_earthquake[ destructible_def ].duration = duration; 
//	level.vehicle_death_earthquake[ destructible_def ].radius = radius; 
//	
//}
//
//build_destructible_radiusdamage( destructibledef, offset, range, maxdamage, mindamage, bKillplayer )
//{
//	if( !isdefined( level.destructible_death_radiusdamage ) )
//		level.destructible_death_radiusdamage = []; 
//	if( !isdefined( bKillplayer ) )
//		bKillplayer = false; 
//	if( !isdefined( offset ) )
//		offset = ( 0, 0, 0 );
//	struct = spawnstruct();
//	struct.offset = offset; 
//	struct.range = range; 
//	struct.maxdamage = maxdamage; 
//	struct.mindamage = mindamage; 
//	struct.bKillplayer = bKillplayer; 
//	level.destructible_death_radiusdamage[ destructibledef ] = struct; 
//}
//
//set_function_pointer( type, def, func )
//{
//	if( !IsDefined( level.destructible_pointers ) )
//	{
//		level.destructible_pointers = [];
//	}
//
///#
//	if( !IsDefined( level.destructible_pointers_inited ) )
//	{
//		level.destructible_pointers_inited = [];
//	}	
//
//	if( !IsDefined( level.destructible_pointers_inited[def] ) )
//	{
//		level.destructible_pointers_inited[def] = true;
//	}
//#/
//
//	level.destructible_pointers[type + "_" + def] = func;
//}
//
get_explosion_animation()
{
	return %v_opelblitz_explode;
}

get_flattire_animation( broken_notify )
{
	if( broken_notify == "flat_tire_left_rear" )
	{
		return %v_opelblitz_flattire_lb;
	}
	else if( broken_notify == "flat_tire_right_rear" )
	{
		return %v_opelblitz_flattire_rb;
	}
	else if( broken_notify == "flat_tire_left_front" )
	{
		return %v_opelblitz_flattire_lf;		
	}
	else if( broken_notify == "flat_tire_right_front" )
	{
		return %v_opelblitz_flattire_rf;
	}
}
//
//empty()
//{
//}