/*
	
	rebirth_utility.gsc - 
	
	Common functions for the level, "Rebirth Island."

*/

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_anim;



////////////////////////////////////////////////////
// rebirth objectives
////////////////////////////////////////////////////
rb_objective_breadcrumb( obj_index, first_trig_name )
{
	trigger_wait( first_trig_name );
	
	curr_trig 	= GetEnt( first_trig_name, "targetname" );
	objective_set3d( obj_index, true );
	
	while( true )
	{
		next_trig 	= GetEnt( curr_trig.target, "targetname" );
		
		curr_struct = getstruct( curr_trig.target, "targetname" );
		
		Objective_Position( obj_index, curr_struct.origin );
				
		next_trig waittill( "trigger" );
		
		if( !IsDefined( next_trig.target ) )	// Once there are no more triggers, stop looping
		{
			break;
		}		
		
		curr_trig = next_trig;
	}
	
	objective_set3d( obj_index, false );
}


//rebirth_objective_on_actor( obj_actor )
//{
//	Objective_Add( level.obj_iterator, "current", obj_string, obj_pos );
//	
//	if( make3d )
//	{
//		objective_Set3d( level.obj_iterator, true );
//	}
//	
//	autosave_by_name( "rebirth" );	// Save whenever objective is updated
//}



//	objective_state( level.obj_iterator, "done" );
//	level.obj_iterator++;

//	if( IsDefined( obj_struct_name ) )
//	{
//		obj_pos = getstruct( obj_struct_name, "targetname" );
//		objective_add( level.obj_iterator, "current", obj_string, obj_pos.origin );
//	}

////////////////////////////////////////////////////
// RB_HELICOPTER
////////////////////////////////////////////////////

show_sl_pos( heli )
{
	heli endon( "death" );
	
	while( true )
	{
		Line( self.origin, heli.origin, (0, 0, 1), 2 );
		wait( 0.05 );
	}
}

show_goal_pos()
{
	if( IsDefined( self.goalpos ) )
	{
		Line( self.origin, self.goalpos, (1, 0, 0), 2 );
		wait( 0.05 );
	}
}

rb_heli_adjust_goaldist()
{
	self endon( "death" );
	
	while( true )
	{
		if( IsDefined( self.heli_speed ) )
		{
			self SetNearGoalNotifyDist( self.heli_speed * 4 );
		}
		wait( 0.05 );
	}
}

rb_heli_init()
{
	self.spotlight_target = Spawn( "script_model", self GetTagOrigin( "tag_flash_gunner3" ) );
	self.spotlight_target SetModel( "tag_origin" );
	spotlight_pos = self GetTagOrigin( "tag_flash_gunner3" );
	spotlight_angles = self GetTagAngles( "tag_flash_gunner3" );
	spotlight_angles = ( spotlight_angles[0]-35, spotlight_angles[1], spotlight_angles[2] );
	spotlight_forward = VectorNormalize( AnglesToForward( spotlight_angles ) ) * 10;
	
	self.spotlight_target.origin = spotlight_pos + spotlight_forward;
	self.spotlight_target_basepos = spotlight_forward;
	self.spotlight_target LinkTo( self );
	
	//self.spotlight_target thread show_sl_pos( self );
	//self thread show_goal_pos();
	self thread rb_heli_adjust_goaldist();
	
	self SetGunnerTargetEnt( self.spotlight_target, (0, 0, 0), 2 );
}

rb_heli_delete()
{
	if( IsDefined( self.spotlight ) )
	{
		self.spotlight Delete();
	}
	if( IsDefined( self.spotlight_sc ) )
	{
		self.spotlight_sc Delete();
	}
	if( IsDefined( self.spotlight_circle ) )
	{
		self.spotlight_circle Delete();
	}
	self Delete();
}

update_ground_targ_pos()
{
	self notify( "update_ground_targ_pos" );
	self endon( "death" );
	self endon( "update_ground_targ_pos" );
	
	while( true )
	{
		spot_angles = self GetTagAngles( "tag_flash_gunner3" );
		spot_forward = VectorNormalize( AnglesToForward( spot_angles ) ) * 10000; 
		spot_org = self GetTagOrigin( "tag_flash_gunner3" );
		spot_targ = spot_org + spot_forward;
		trace = BulletTrace( spot_org, spot_targ, false, self, false, true );
		
		self.ground_pos = trace["position"];
		if( trace["fraction"] == 1.0 )
		{
			self.ground_pos = self.origin - (0, 0, 10000);
		}
		
		wait( 0.05 );
	}
}

update_spotlight_circle()
{
	self notify( "kill_spotlight_circle" );
	self endon( "death" );
	self endon( "kill_spotlight_circle" );
	
	while( true ) 
	{
		self.spotlight_circle.origin = groundpos(self.spotlight_target.origin);//self.ground_pos;
		wait( 0.05 );
	}
}

update_spotlight_sc()
{
	self notify( "kill_spotlight_sc" );
	self endon( "death" );
	self endon( "kill_spotlight_sc" );
}

// Enables spotlight with shadowcasting
rb_heli_spotlight_circle_enable( should_enable )
{
	if( IsDefined( self.spotlight_circle ) && !should_enable )
	{
		self notify( "kill_spotlight_circle" );
		self.spotlight_circle Delete();
		return;
	}
	else if( IsDefined( self.spotlight_circle ) )
	{
		return;
	}
	
	self thread update_ground_targ_pos();
	
	self.spotlight_circle = Spawn( "script_model", self.ground_pos );
	self.spotlight_circle SetModel( "tag_origin" );
	self.spotlight_circle.angles = ( -90, 0, 0 );
	
	PlayFXOnTag( level._effect["spotlight_circle"], self.spotlight_circle, "tag_origin" );
	
	self thread update_spotlight_circle();
}

/*
rb_heli_spotlight_shadow_enable( should_enable )
{
	if( IsDefined( self.spotlight_sc ) && !should_enable )
	{
		self notify( "kill_spotlight_sc" );
		self.spotlight_sc Delete();
		return;
	}
	else if( IsDefined( self.spotlight_circle ) )
	{
		return;
	}
	
	self thread update_ground_targ_pos();
	
	spot_angles = self GetTagAngles( "tag_flash_gunner3" );
	spot_forward = VectorNormalize( AnglesToForward( spot_angles ) ) * 10000; 
	spot_org = self GetTagOrigin( "tag_flash_gunner3" );
	spot_targ = spot_org + spot_forward;
	trace = BulletTrace( spot_org, spot_targ, false, self, true, true );
	
	spawn_org = trace["position"];
	if( trace["fraction"] == 1.0 )
	{
		spawn_org = self.origin - (0, 0, 10000);
	}
	self.spotlight_sc = Spawn( "script_model", spawn_org );
	self.spotlight_sc SetModel( "tag_origin" );
	
	PlayFXOnTag( level._effect["spotlight_sc"], self.spotlight_sc, "tag_origin" );
}
*/

// Enables spotlight without shadowcasting
rb_heli_spotlight_enable( should_enable )
{
	if( IsDefined( self.spotlight ) && !should_enable )
	{
		self.spotlight Delete();
		return;
	}
	else if( IsDefined( self.spotlight ) )
	{
		return;
	}
	
	self.spotlight = Spawn( "script_model", self GetTagOrigin( "tag_flash_gunner3" ) );
	self.spotlight SetModel( "tag_origin" );
	self.spotlight.angles = self GetTagAngles( "tag_flash_gunner3" );
	
	self.spotlight LinkTo( self, "tag_flash_gunner3" );
	PlayFXOnTag( level._effect["spotlight"], self.spotlight, "tag_origin" );
	
	self thread rb_heli_spotlight_delete_on_death( self.spotlight );
}

// Disables spotlight
rb_heli_spotlight_disable()
{
	self.spotlight Delete();
}

rb_heli_spotlight_delete_on_death( spotlight )
{
	self waittill( "death" );
	
	if( IsDefined( spotlight ) )
	{
		spotlight  Delete();
	}
}

move_points_sequentially( move_points, should_face_struct, do_loop )
{
	self notify( "new_heli_moveto" );
	
	self endon( "new_heli_behavior" );
	self endon( "new_heli_moveto" );
	self endon( "death" );
	
	for( i = 0; i < move_points.size; i++ )
	{
		should_stop = true;
		if( !IsDefined( move_points[i].script_float ) || move_points[i].script_float == 0 )
		{
			should_stop = false;
		}
		if( (i + 1) == move_points.size )
		{
			should_stop = true;
		}
		
		self SetVehGoalPos( move_points[i].origin, should_stop );
		self.goalpos = move_points[i].origin;
		if( should_face_struct )
		{
			if( IsDefined( move_points[i].angles ) )
			{
				self SetTargetYaw( move_points[i].angles[1] );
			}
			else
			{
				self ClearTargetYaw();
			}
		}
		self waittill_either( "near_goal", "goal" );
		if( should_stop )
		{
			if( IsDefined( move_points[i].script_float ) )
			{
				wait( move_points[i].script_float );
			}
		}
		if( IsDefined( move_points[i].script_int ) )
		{
			self rb_heli_set_speed( move_points[i].script_int );
		}
		if( IsDefined( move_points[i].script_string ) )
		{
			level notify( move_points[i].script_string );
		}
	}
	
	self notify( "path_complete" );
	
	if( do_loop )
	{
		self thread move_points_sequentially( move_points, should_face_struct, do_loop );
	}
}

move_points_randomly( move_points, should_face_struct )
{
	self notify( "new_heli_moveto" );
	
	self endon( "new_heli_behavior" );
	self endon( "new_heli_moveto" );
	self endon( "death" );
	
	curr_point = 0;
	
	self ClearTargetYaw();
	
	if( move_points.size == 1 )
	{
		self SetVehGoalPos( move_points[0].origin, true );
		self SetGoalYaw( move_points[0].angles[1] );
		
		return;
	}
	
	while( true )
	{
		old_curr_point = curr_point;
		while( old_curr_point == curr_point )
		{
			curr_point = RandomInt( move_points.size );
		}
		
		self SetVehGoalPos( move_points[curr_point].origin, true );
		self.goalpos = move_points[curr_point].origin;
		
		if( should_face_struct )
		{
			self SetTargetYaw( move_points[curr_point].angles[1] );
		}
		self waittill_either( "near_goal", "goal" );
		if( IsDefined( move_points[curr_point].script_float ) )
		{
			wait( move_points[curr_point].script_float );
		}
		if( IsDefined( move_points[curr_point].script_int ) )
		{
			self rb_heli_set_speed( move_points[curr_point].script_int );
		}
		if( IsDefined( move_points[curr_point].script_string ) )
		{
			level notify( move_points[curr_point].script_string );
		}
	}
}

scan_points_sequentially( scan_points, do_loop )
{
	self notify( "new_heli_scan" );
	
	self endon( "new_heli_behavior" );
	self endon( "new_heli_scan" );
	self endon( "death" );
	
	if( !IsDefined( scan_points ) || scan_points.size == 0 )
	{
		self rb_heli_spotlight_static_angles();
		return;
	}
	
	for( i = 0; i < scan_points.size; i++ )
	{
		self rb_heli_spotlight_target_point( scan_points[i].origin, scan_points[i].script_int );
		
		if( IsDefined( scan_points[i].script_string ) )
		{
			level notify( scan_points[i].script_string );
		}
		
		if( IsDefined( scan_points[i].script_float ) )
		{
			wait( scan_points[i].script_float );
		}
		else
		{
			wait( 0.05 );
		}
	}
	
	if( do_loop )
	{
		self thread scan_points_sequentially( scan_points, do_loop );
	}
}

scan_points_randomly( scan_points )
{
	self notify( "new_heli_scan" );
	
	self endon( "new_heli_behavior" );
	self endon( "new_heli_scan" );
	self endon( "death" );
	
	if( !IsDefined( scan_points ) || scan_points.size == 0 )
	{
		self rb_heli_spotlight_static_angles();
		return;
	}
	else if( scan_points.size == 1 )
	{
		self rb_heli_spotlight_target_point( scan_points[0].origin, scan_points[0].script_int );
		return;
	}
	
	curr_point = 0;
	
	while( true )
	{
		old_curr_point = curr_point;
		while( old_curr_point == curr_point )
		{
			curr_point = RandomInt( scan_points.size );
		}
		self rb_heli_spotlight_target_point( scan_points[curr_point].origin, scan_points[curr_point].script_int );
		
		if( IsDefined( scan_points[curr_point].script_string ) )
		{
			level notify( scan_points[curr_point].script_string );
		}
		if( scan_points[curr_point].script_float )
		{
			wait( scan_points[curr_point].script_float );
		}
		else
		{
			wait( 0.05 );
		}
	}
}

rb_heli_idle( position_name, fixed_move_order, fixed_scan_order, do_loop )
{
	self notify( "new_heli_behavior" );
	self endon( "new_heli_behavior" );
	self endon( "heli_stop_patterns" );
	self endon( "death" );
	
	if( IsDefined( level.scan_tuning_funcs ) && IsDefined( level.scan_tuning_funcs[position_name] ) )
	{
		[[ level.scan_tuning_funcs[position_name] ]]();
	}
	
	if( fixed_move_order )
	{
		idle_points = [];
		i = 1;
		while( true )
		{
			temp_struct = getstruct( position_name+"_pos_"+i, "targetname" );
			if( IsDefined( temp_struct ) )
			{
				idle_points = array_add( idle_points, temp_struct );
			}
			else
			{
				break;
			}
			i++;
		}
	}
	else
	{
		idle_points = getstructarray( position_name+"_pos", "targetname" );
	}
	
	if( fixed_scan_order )
	{
		scan_points = [];
		i = 1;
		while( true )
		{
			temp_struct = getstruct( position_name+"_scan_"+i, "targetname" );
			if( IsDefined( temp_struct ) )
			{
				scan_points = array_add( scan_points, temp_struct );
			}
			else
			{
				break;
			}
			i++;
		}
	}
	else
	{
		scan_points = getstructarray( position_name+"_scan", "targetname" );
	}
	
	if( !IsDefined( idle_points ) || idle_points.size == 0 )
	{
		PrintLn( "ERROR: No idle points specifed for position "+position_name );
		return;
	}
	
	self SetVehGoalPos( idle_points[0].origin, true );
	self waittill_either( "near_goal", "goal" );
	
	if( fixed_move_order )
	{
		self thread move_points_sequentially( idle_points, true, do_loop );
	}
	else
	{
		self thread move_points_randomly( idle_points, true );
	}
	
	if( fixed_scan_order )
	{
		self thread scan_points_sequentially( scan_points, do_loop );
	}
	else
	{
		self thread scan_points_randomly( scan_points );
	}
	
	if( !do_loop && fixed_move_order )
	{
		self waittill( "path_complete" );
	}
}

rb_heli_path( path_name, speed )
{
	self notify( "new_heli_behavior" );
	self endon( "new_heli_behavior" );
	self endon( "heli_stop_patterns" );
	self endon( "death" );
	
	self ClearTargetYaw();
	
	if( IsDefined( level.scan_tuning_funcs ) && IsDefined( level.scan_tuning_funcs[path_name] ) )
	{
		[[ level.scan_tuning_funcs[path_name] ]]();
	}
	
	path_points = [];
	i = 1;
	while( true )
	{
		temp_struct = getstruct( path_name+"_pos_"+i );
		if( IsDefined( temp_struct ) )
		{
			path_points = array_add( path_points, temp_struct );
		}
		else
		{
			break;
		}
		i++;
	}
	
	scan_points = [];
	i = 1;
	while( true )
	{
		temp_struct = getstruct( path_name+"_scan_"+i );
		if( IsDefined( temp_struct ) )
		{
			scan_points = array_add( scan_points, temp_struct );
		}
		else
		{
			break;
		}
		i++;
	}
	
	self rb_heli_set_speed( speed );
	self thread move_points_sequentially( path_points, false, false );
	self thread scan_points_sequentially( scan_points, false );
	
	self waittill( "path_complete" );
}

firing_solution_watcher( target )
{
	self endon( "new_heli_behavior" );
	self endon( "death" );
	
	while( true )
	{
		view_pos = self GetTagOrigin( "tag_flash_gunner3" );
		trace = BulletTrace( view_pos, target.origin+(0, 0, 40), false, self, true, true );
		
		if( trace["fraction"] < 1.0 )
		{
			self.need_new_solution = true;
			return;
		}
		
		wait( 1 );
	}
}

rb_heli_engage( target, engage_dist, height )
{
	self endon( "death" );
	self endon( "heli_stop_patterns" );
	
	self rb_heli_set_speed( 40, 20, 20 );
	
	double_dist = engage_dist*2;
	double_distsq = double_dist*double_dist;
	
	self.need_new_solution = false;
	curr_angle = RandomInt( 360 );
	forward = VectorNormalize( AnglesToForward( (0, curr_angle, 0) ) ) * engage_dist;
	
	while( true )
	{
		if( self.need_new_solution )
		{
			curr_angle = (curr_angle + 45) % 360;
			forward = VectorNormalize( AnglesToForward( (0, curr_angle, 0) ) ) * engage_dist;
		}
		
		target_point = target.origin + forward;
		target_point = ( target_point[0], target_point[1], target_point[2]+height );
	
		self SetVehGoalPos( target_point, true );	
		
		if( DistanceSquared( (self.origin[0], self.origin[1], target.origin[2]), target.origin ) < double_distsq )
		{
			self SetLookAtEnt( target );
		}
		
		dot = VectorDot( VectorNormalize( (self.origin[0], self.origin[1], target.origin[2]) - target.origin ), 
										 VectorNormalize( (target_point[0], target_point[1], target.origin[2]) - target.origin ) );
		if( ACos( dot ) < 35 )
		{
			self thread firing_solution_watcher( target );
		}
		
		wait( 1.0 );
	}
}

rb_heli_engage2( target, engage_dist, height, min_recalc_pos_time, max_recalc_pos_time )
{
	self endon("death");
	self endon( "heli_stop_patterns" );
	level endon("start_shooting_player");

	self rb_heli_set_speed( 40, 20, 20 );
	
	double_dist = engage_dist*2;
	double_distsq = double_dist*double_dist;

	curr_angle = RandomInt( 360 );

	while( true )
	{
		angle_offset = RandomIntRange(45, 90);
		if (RandomIntRange(0, 100) < 50)
		{
			angle_offset = angle_offset * -1;
		}
		curr_angle = (curr_angle + angle_offset) % 360;
		forward = VectorNormalize( AnglesToForward( (0, curr_angle, 0) ) ) * engage_dist;

		target_point = target.origin + forward;
		target_point = ( target_point[0], target_point[1], target_point[2]+height );
	
		self SetVehGoalPos( target_point, true );	
		
		if( DistanceSquared( (self.origin[0], self.origin[1], target.origin[2]), target.origin ) < double_distsq )
		{
			self SetLookAtEnt( target );
		}
		
		wait( RandomFloatRange( min_recalc_pos_time, max_recalc_pos_time ) );
	}
}

// Sets a target point for a helicopter. It will reach this point in translate_time
rb_heli_spotlight_target_point( point, translate_time )
{
	self.spotlight_target Unlink();
	
	if( !IsDefined( translate_time ) )
	{
		translate_time = 4;
	}
	
	self.spotlight_target MoveTo( point, translate_time );
	
	self.spotlight_target waittill( "movedone" );
}

// Sets an object for the helicopter spotlight to target. lag_time indicates how responsive it should be to
// changes of position
rb_heli_spotlight_target_object( object )
{
	self notify( "new_heli_behavior" );
	
	self.spotlight_target Unlink();
	self.spotlight_target.origin = object.origin;
	self.spotlight_target LinkTo( object );
}

// Sets a static angle to set the spotlight to, it will not shift as the helicopter moves
rb_heli_spotlight_static_angles( target_angles )
{
	self notify( "new_heli_behavior" );
	
	if( !IsDefined( target_angles ) )
	{
		target_angles = (-35, 0, 0 );
	}
	
	self.spotlight_target Unlink();
	final_angles = target_angles + self.angles;
	tag_pos = self GetTagOrigin( "tag_flash_gunner3" );
	forward = VectorNormalize( AnglesToForward( final_angles ) ) * 10;
	
	self.spotlight_target.origin = tag_pos + forward;
	
	self.spotlight_target LinkTo( self, "tag_flash_gunner3" );
}

// Gives a object for the helicopter to point at
rb_heli_face_object( object )
{
	self notify( "new_facing_cmd" );
	
	self SetLookAtEnt( object );
}

// Gives a point for the helicopter to point at
rb_heli_face_point( point )
{
	if( !IsDefined( self.face_struct ) )
	{
		self.face_struct = SpawnStruct();
	}
	self.face_struct.origin = point;
	
	self SetLookAtEnt( self.face_struct );
}

// Sets the current speed of a helicopter
rb_heli_set_speed( speed, accel, decel )
{
	if( !IsDefined( accel ) )
	{
		accel = speed/2;
	}
	if( !IsDefined( decel ) )
	{
		decel = speed/2;
	}
	self.heli_speed = speed;
	self SetSpeed( speed, accel, decel );
}

// Fire side gun at target point
rb_heli_fire_side_gun( target, burst_time )
{
	self endon("death");
	self endon("stop_firing");
	self endon( "heli_stop_patterns" );
	
	//Kevin adding audio ent
	//ent = spawn( "script_origin" , (0,0,0));
	//self thread audio_ent_fakelink( ent );
	//ent thread audio_ent_fakelink_delete();
	
	//self SetTurretTargetEnt( target );
	self SetGunnerTargetEnt( target );
	
	time_fired = 0;
	
	while( IsAlive(self) && time_fired < burst_time )
	{
		//ent playloopsound( "wpn_huey_toda_minigun_fire_npc_loop2" );
		self FireGunnerWeapon( 0 );
		wait(0.05);
		time_fired += 0.05;
	}
	//ent stoploopsound(.048);
}

// Fires the rocket pod at a location
rb_heli_fire_rockets( target, time_between_rockets )
{
	self endon("fire_rockets");
	self endon("death");
	self endon( "heli_stop_patterns" );
	
	rocket_weapon = "rpg_magic_bullet_sp";
	rocket_tag_left = "tag_rocket_left";
	rocket_tag_right= "tag_rocket_right";
	wait_min = 2;
	wait_max = 3.5;
		
	while(true)
	{
		forward = AnglesToForward(self.angles);
		start_point_left = self GetTagOrigin(rocket_tag_left) + (60 * forward);
		start_point_right = self GetTagOrigin(rocket_tag_right) + (60 * forward);
		player = get_players()[0];
		rocket = MagicBullet( rocket_weapon, start_point_left, target.origin, self, target );
		rocket2 = MagicBullet( rocket_weapon, start_point_right, target.origin, self, target );
		
		rand_wait = RandomFloatRange(wait_min, wait_max);
		if(IsDefined(time_between_rockets))
			wait(time_between_rockets);
		else	
			wait(rand_wait);	
	}
}

/***************************************************************/
//	rb_spawn_character
//
//	spawns a script model and assigns it the models of a character
/***************************************************************/
rb_spawn_character(character_type, origin, angles, anim_name)
{
	Assert(IsDefined(level.character[character_type]), "No entry for character type: " + character_type + " defined in character array.");

	model = spawn("script_model", origin);

	if (IsDefined(angles))
	{
		model.angles = angles;
	}

	model [[level.character[character_type]]]();

	if (IsDefined(anim_name))
	{
		model.animname = anim_name;
	}
	
	model NotSolid(); //-- Seemed to be leaving collision boxes around
	return model;
}

/***************************************************************/
//	vignette
//
//	Util for playing a vignette involving multiple actors...
//
//	params: 
//	node - name of or ent to play off of
//	actors - a list of spawner names, 
//	scene_name - name of the scene...(level.scr_anim[scene_name])
//	loop - looped or single
//	thread_type - see thread types
//	group_name - if specified actors will be saved in the level array vignette_group with this index (ie. level.vignette_group[group_name])
//	auto_delete - flag for auto deleting the actor group after the animation has completed...only works if the 
//	remove_weapons - set to true to remove weapons on spawned actors
//
//	thread types
//	{
//		0 = not threaded (will all be played together)
//		1 = thread_together (will all be played together on a thread)
//		2 = thread_individually (will be played individually on threads)
//	}
//
/***************************************************************/
vignette(node, actors, scene_name, loop, thread_type, group_name, auto_delete /* only works for non threaded */, remove_weapons, spawn_function, spawn_function_arg)
{
	// Step 1: get the alignment node

	// if a string was passed then assume we want the ent that has this target name
	if (IsString(node))
	{
		align_node = GetEnt(node, "targetname");

		// if we failed to get the "ent" try grabbing the struct with this target name
		if (!IsDefined(align_node))
		{
			align_node = GetStruct(node, "targetname");
		}
	}
	else
	{
		// assume we were passed an ent or struct
		align_node = node;
	}

	// Step 2: create actors
	names = build_ent_array(actors);
	actor_array = [];
	for (i = 0; i < names.size; i++)
	{
		// If this element was passed as a string assume we want to spawn an actor using the spawner
		// with this target name
		if (IsString(names[i]) || names[i] is_spawner())
		{
			actor_array[i] = simple_spawn_single(names[i], spawn_function, spawn_function_arg);

			// if we are a spawner
			if (names[i] is_spawner())
			{
				// check to see if animname has been set
				if (IsDefined(names[i].animname))
				{
					actor_array[i].animname = names[i].animname;
				}
			}
			else
			{
				// else set animname to targetname by default
				actor_array[i].animname = names[i];
			}

			if (IsDefined(remove_weapons) && remove_weapons)
			{
				actor_array[i] gun_remove();
			}
		}
		else
		{
			actor_array[i] = names[i];
		}
	}

	// Step 2a: create a group if specified
	if (IsDefined(group_name))
	{
		if (IsDefined(level.vignette_group) && IsDefined(level.vignette_group[group_name]))
		{
			level.vignette_group[group_name] = array_combine(level.vignette_group[group_name], actor_array);
		}
		else
		{
			level.vignette_group[group_name] = actor_array;
		}
	}

	// Step 3: play animation
	switch(thread_type)
	{
		// 0 = not threaded (will all be played together)
		case 0:
		{
			// play anim
			if (loop)
			{
				align_node anim_loop_aligned(actor_array, scene_name);
			}
			else
			{
				align_node anim_single_aligned(actor_array, scene_name);
			}

			// check for auto delete
			if (IsDefined(auto_delete) && auto_delete)
			{
				array_delete(actor_array);
			}

			break;
		}

		// 1 = thread_together (will all be played together on a thread)
		case 1:
		{
			// play anim
			if (loop)
			{
				align_node thread anim_loop_aligned(actor_array, scene_name);
			}
			else
			{
				align_node thread anim_single_aligned(actor_array, scene_name);
			}

			break;
		}

		// 2 = thread_individually (will be played individually on threads)
		case 2:
		{
			// loop the actors and spin indiviual threads
			for (i = 0; i < actor_array.size; i++)
			{
				if (loop)
				{
					align_node thread anim_loop_aligned(actor_array[i], scene_name);
				}
				else
				{
					align_node thread anim_single_aligned(actor_array[i], scene_name);
				}
			}

			break;
		}

		default: break;
	}	
}

/*
rebirth_flag_init( flag_name, order )
{
	if( !IsDefined( level.last_flag_set ) )
	{
		level.last_flag_set = "none";	
	}
	
	if( !IsDefined( level.rebirth_flag_array ) )
	{
		level.rebirth_flag_array = [];
	}
	
	Assert( !IsDefined( level.rebirth_flag_array[order] ) );
	
	for( i = 0; i < 
	level.rebirth_flag_array[order] = [];
	level.rebirth_flag_array[order]["flag"] = flag_name;
	level.rebirth_flag_array[order]["set"] = false;
}

rebirth_flag_debug_print()
{
	flag_hudelem = NewHudElem();
	flag_hudelem.alignX = "left";
	flag_hudelem.alignY = "top";
	flag_hudelem.horzAlign = "fullscreen";
	flag_hudelem.vertAlign = "fullscreen";
	
	keys = GetArrayKeys();
	
	i = 0;
	
	while( true )
	{
		curr_idx = keys[i];
		curr_flag = 
		flag_hudelem SetText( keys[i] );
	}
}
*/

//------------------------------------
// Can the player see me? <-- is what the AI wonders
player_can_see_me( player )
{
	playerAngles = player getplayerangles();
	playerForwardVec = AnglesToForward( playerAngles );
	playerUnitForwardVec = VectorNormalize( playerForwardVec );

	banzaiPos = self.origin;
	playerPos = player GetOrigin();
	playerToBanzaiVec = banzaiPos - playerPos;
	playerToBanzaiUnitVec = VectorNormalize( playerToBanzaiVec );

	forwardDotBanzai = VectorDot( playerUnitForwardVec, playerToBanzaiUnitVec );
	angleFromCenter = ACos( forwardDotBanzai ); 

	playerFOV = GetDvarFloat( #"cg_fov" );
	
	/*
	banzaiVsPlayerFOVBuffer = GetDvarFloat( #"g_banzai_player_fov_buffer" );	
	if ( banzaiVsPlayerFOVBuffer <= 0 )
	{
		banzaiVsPlayerFOVBuffer = 0.2;
	}

	playerCanSeeMe = ( angleFromCenter <= ( playerFOV * 0.5 * ( 1 - banzaiVsPlayerFOVBuffer ) ) );
	*/
	
	playerCanSeeMe = ( angleFromCenter <= ( playerFOV * 0.5 ) );

	return playerCanSeeMe;
}

delete_when_noone_looking()
{
	self endon( "death" );
	
	player = get_players()[0];
	
	while( true )
	{
		if( !self player_can_see_me( player ) )
		{
			self Delete();
			return;
		}
		wait( 0.05 );
	}
}

create_hud_elem( client, xpos, ypos, shader, width, height )
{
	if( IsDefined( client ) )
	{
		hud = NewClientHudElem( client ); 
	}
	else
	{
		hud = NewHudElem(); 
	}

	hud.x = xpos;
	hud.y = ypos;

//	hud.sort = 1;
	hud.hidewheninmenu = true;

	hud.alignX = "center";
	hud.alignY = "middle";
	hud.horzAlign = "center";
	hud.vertAlign = "middle";
	hud.foreground = true;

	hud.alpha = 1.0;
	hud.color = ( 1.0, 1.0, 1.0 );
	
	if( isdefined(shader) )
	{
		hud setshader( shader, width, height );
	}
		
	return hud; 
}

create_hud_bar( xpos, ypos, width, height, shader )
{
	barElem = newClientHudElem(	self );
	barElem.x = xpos;
	barElem.y = ypos;
	barElem.width = width;
	barElem.height = height;
	barElem.frac = 0;
	barElem.color = ( 1.0, 1.0, 1.0 );
	barElem.sort = -2;
	
	barElem.alignX = "left";
	barElem.alignY = "middle";
	barElem.horzAlign = "center";
	barElem.vertAlign = "middle";
	
	barElem.shader = shader;
	barElem setShader( shader, width, height );
	//barElem.hidden = false;

//	if ( isDefined( flashFrac ) )
//	{
//		barElem.flashFrac = flashFrac;
//	}
	
	return( barElem );
}

turn_on_uaz_lights()
{
	wait(.07);
	playfxontag(level._effect["uaz_headlight"], self, "tag_headlight_left" );
	playfxontag(level._effect["uaz_headlight"], self, "tag_headlight_right" );
	//playfxontag(level._effect["uaz_taillight"], self, "tag_tail_light_left" );
	//playfxontag(level._effect["uaz_taillight"], self, "tag_tail_light_right" );	
}



heli_avoidance( heli_to_avoid )
{
  self endon("done_avoiding");
  self endon("death");
  self endon("landing");

	max_push_dist = 0;
  max_push_vel = 0;
  min_height_diff = 0;
  max_push_side_vel = 0;
  collision_avoid_time = 0;
  
  switch(self.vehicletype)
  {
	  case "heli_hind_doublesize":
	  case "heli_hind":
	    max_push_dist = 2500;
	    max_push_vel = 60;
	    max_push_side_vel = 100;
	    min_height_diff = 550;
	    collision_avoid_time = 3;
	  break;
	  
	  case "heli_hip":
		  max_push_dist = 1500;
		  max_push_vel = 40;
		  max_push_side_vel = 40;
		  min_height_diff = 360;
		  collision_avoid_time = 2;
	  break;
  }
  
  avoiding = false;
  while (1)
  {
		//-- General Check to make sure that things are kosher
    if (IsDefined(self.velocity))
    {
      // get current velocity
      velocity = self.velocity;

      // first avoid the player
      dist = Distance2D(heli_to_avoid.origin, self.origin);
      //IPrintLn("Dist: " + dist);

      // if we are within the bounds 
      still_avoiding = false;
      if (dist < max_push_dist || heli_on_collision_course( self, heli_to_avoid, collision_avoid_time ))
      {
	      // Check the Z Height as well
	      height_diff = self.origin[2] - heli_to_avoid.origin[2];
	      
	      if(height_diff < min_height_diff)
	      {      
	        // find out how far in we are
	        //normalized_dist = dist / max_push_dist;
	        normalized_dist = 1;
	
	        // push above player
	        dir = (0,0,1);
	        push_vel = dir * (max_push_vel * normalized_dist);
	        velocity = (velocity[0] * 0.75, velocity[1] * 0.75, velocity[2]);
	        velocity = velocity + push_vel;
	                      
          // push them to the side as well
          dir_to_right = AnglesToRight(self.angles);
          side_push_vel = dir_to_right * (max_push_side_vel * normalized_dist);
          if( VectorDot(dir_to_right, VectorNormalize(heli_to_avoid.velocity)) < 0)
          {
	          //-- fly to my right
	          side_push_vel = (side_push_vel[0], side_push_vel[1], 0);
          }
          else
          {
		        //-- fly to my left
		        side_push_vel = -1 * (side_push_vel[0], side_push_vel[1], 0);
          }
          
          //-- if the helicopter is already moving a different direction, don't push it
          if( VectorDot(VectorNormalize(side_push_vel), VectorNormalize(self.velocity)) >= 0 )
          {
          	velocity = velocity + side_push_vel;
          }
	                                                                      
	      	avoiding = true;
	      }
	            
				still_avoiding = true;
      }
      
      if(!still_avoiding)
      {
        if (avoiding)
        {
        	velocity = (velocity[0], velocity[1], 0.0);
        }
        avoiding = false;
      }

      self SetVehVelocity(velocity);
    }

  	wait(0.05);
	}
}

heli_on_collision_course( target_ent, incoming_ent, time_to_collision )
{
	collision_dir = VectorNormalize(target_ent.origin - incoming_ent.origin);
	incoming_velocity = VectorNormalize(incoming_ent.velocity);
	
	target_ent.collision_dot = VectorDot( collision_dir, incoming_velocity );
	if( target_ent.collision_dot > .8 ) // then player is on collision course
	{
	  coll_vector_length = Length(target_ent.origin - incoming_ent.origin);
	  target_ent.time_left_to_collision =  coll_vector_length / VectorDot(collision_dir, incoming_ent.velocity);
	  if(target_ent.time_left_to_collision < time_to_collision)
	  {
			return true;
	  }
	}
	
	//not on a collision course
	return false;
}

autosave_after_delay( delay, save_name )
{
	wait(delay);
	autosave_by_name( save_name );
}