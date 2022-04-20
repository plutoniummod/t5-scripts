#include common_scripts\utility; 
#include maps\_utility;
#include maps\creek_1_util;
#include maps\_anim;

#using_animtree ("generic_human");
main()
{
// BEAT 2

	// enemies for initial stealth run through

	array_thread( getentarray( "b2_vc_stealth_kill_vc_1", "targetname" ), ::add_spawn_function,::stealth_kill_ai_generic_spawn );
	//array_thread( getentarray( "b2_vc_stealth_kill_vc_1", "targetname" ), ::add_spawn_function,::use_patrol_anim );

	array_thread( getentarray( "b2_vc_stealth_kill_vc_2", "targetname" ), ::add_spawn_function,::stealth_kill_ai_generic_spawn );
	//array_thread( getentarray( "b2_vc_stealth_kill_vc_2", "targetname" ), ::add_spawn_function,::use_patrol_anim );

	array_thread( getentarray( "b2_vc_stealth_kill_vc_3", "targetname" ), ::add_spawn_function,::stealth_kill_ai_generic_spawn );
	array_thread( getentarray( "b2_vc_stealth_kill_vc_3", "targetname" ), ::add_spawn_function,::use_patrol_anim );
	array_thread( getentarray( "b2_vc_stealth_kill_vc_3", "targetname" ), ::add_spawn_function,::b2_patrol_standing_idle );

	array_thread( getentarray( "b2_vc_stealth_kill_vc_4", "targetname" ), ::add_spawn_function,::stealth_kill_ai_generic_spawn );
	array_thread( getentarray( "b2_vc_stealth_kill_vc_4", "targetname" ), ::add_spawn_function,::use_patrol_anim );
	array_thread( getentarray( "b2_vc_stealth_kill_vc_4", "targetname" ), ::add_spawn_function,::b2_patrol_standing_idle );

	array_thread( getentarray( "b2_vc_stealth_kill_vc_5", "targetname" ), ::add_spawn_function,::stealth_kill_ai_generic_spawn );
	array_thread( getentarray( "b2_vc_stealth_kill_vc_5", "targetname" ), ::add_spawn_function,::use_patrol_anim );
	array_thread( getentarray( "b2_vc_stealth_kill_vc_5", "targetname" ), ::add_spawn_function,::b2_patrol_standing_smoke );

	array_thread( getentarray( "b2_vc_stealth_kill_vc_6", "targetname" ), ::add_spawn_function,::stealth_kill_ai_generic_spawn );
	array_thread( getentarray( "b2_vc_stealth_kill_vc_6", "targetname" ), ::add_spawn_function,::use_patrol_anim );

	array_thread( getentarray( "b2_vc_stealth_kill_vc_7", "targetname" ), ::add_spawn_function,::stealth_kill_ai_generic_spawn );
	array_thread( getentarray( "b2_vc_stealth_kill_vc_7", "targetname" ), ::add_spawn_function,::use_patrol_anim );

	array_thread( getentarray( "b2_vc_stealth_kill_vc_dead", "targetname" ), ::add_spawn_function,::stealth_kill_ai_generic_spawn );
	array_thread( getentarray( "b2_vc_stealth_kill_vc_dead", "targetname" ), ::add_spawn_function,::use_patrol_anim );
	array_thread( getentarray( "b2_vc_stealth_kill_vc_dead", "targetname" ), ::add_spawn_function,::b2_patrol_standing_idle );

	array_thread( getentarray( "b2_village_enemies", "script_noteworthy" ), ::add_spawn_function,::reset_radius_at_goal );
	array_thread( getentarray( "b2_village_enemies", "script_noteworthy" ), ::add_spawn_function,::no_grenade );
	array_thread( getentarray( "b2_village_enemies", "script_noteworthy" ), ::add_spawn_function,::no_long_death );

	array_thread( getentarray( "b2_village_rushers", "script_noteworthy" ), ::add_spawn_function,::b2_rushers );
	array_thread( getentarray( "b2_village_rushers_2", "script_noteworthy" ), ::add_spawn_function,::b2_rushers_2 );
// beat 3
	array_thread( getentarray( "b3_enemies_group1", "targetname" ), ::add_spawn_function,::use_low_goalradius );

	array_thread( getentarray( "b3_temp_dragged_ai_1", "targetname" ), ::add_spawn_function,::hold_fire );
	array_thread( getentarray( "b3_temp_dragged_ai_2", "targetname" ), ::add_spawn_function,::hold_fire );
	array_thread( getentarray( "b3_temp_dragged_ai_3", "targetname" ), ::add_spawn_function,::hold_fire );

	array_thread( getentarray( "b2_unarmed_enemy", "script_noteworthy" ), ::add_spawn_function,::hold_fire );
	array_thread( getentarray( "b2_unarmed_enemy", "script_noteworthy" ), ::add_spawn_function,::use_low_goalradius );
	array_thread( getentarray( "b2_unarmed_enemy", "script_noteworthy" ), ::add_spawn_function,::getting_killed_quickly );
}	

// applicable to most stealth enemies
stealth_kill_ai_generic_spawn()
{
	// don't fire
	self hold_fire();
	
	// don't drop weapon
	self.dropWeapon = false;

	// low goal radius
	self.goalradius = 4;

	// one hit kill
	self.health = 1;

	// no grenade
	self.grenadeammo = 0; 

	// no long death
	self.a.disableLongDeath = true;

	// no firing death
	self.dofiringdeath = false;
}


b2_patrol_standing_idle()
{
	/*
	self waittill( "goal" );
	self.animname = "generic";
	self SetCanDamage( true ); 
	self thread anim_loop( self, "idle_stand" );
	self waittill( "damage" );
	iprintlnbold( "damage" );
	self notify( "stop_loop" );
	*/
}

b2_patrol_standing_smoke()
{
	/*
	self waittill( "goal" );
	self.animname = "generic";
	self SetCanDamage( true ); 
	self thread anim_loop( self, "idle_smoke" );
	self waittill( "damage" );
	self notify( "stop_loop" );
	*/
}

getting_killed_quickly()
{
	self endon( "death" );
	self.animname = "generic";
	self.health = 1;
	self set_run_anim( "unarmed_run" );
	self gun_remove();

	wait( 3 + randomfloat( 2 ) );

	PlayFxOnTag( level._effect["flesh_hit"], self, "J_Head" );  
	self dodamage( self.health + 100, ( -18753, 37987, 248.3 ), level.barnes );
}

