// _waw_zombiemode_ai_japanese.gsc

init()
{
	init_japanese_anims();
}

#using_animtree( "generic_human" );
init_japanese_anims()
{
	/*level.scr_anim["zombie"]["walk1"] 	= %ai_zombie_jap_walk_A;
	level.scr_anim["zombie"]["walk2"] 	= %ai_zombie_jap_walk_B;*/

	level._zombie_melee["zombie"][0] 				= %ai_zombie_jap_attack_v6; 
	level._zombie_melee["zombie"][1] 				= %ai_zombie_jap_attack_v5; 
	level._zombie_melee["zombie"][2] 				= %ai_zombie_jap_attack_v1; 
	level._zombie_melee["zombie"][3] 				= %ai_zombie_jap_attack_v2;	
	level._zombie_melee["zombie"][4]				= %ai_zombie_jap_attack_v3;
	level._zombie_melee["zombie"][5]				= %ai_zombie_jap_attack_v4;

	level._zombie_run_melee["zombie"][0]				=	%ai_zombie_jap_run_attack_v1;
	level._zombie_run_melee["zombie"][1]				=	%ai_zombie_jap_run_attack_v2;

	/*level.scr_anim["zombie"]["run1"] 	= %ai_zombie_jap_run_v1;
	level.scr_anim["zombie"]["run2"] 	= %ai_zombie_jap_run_v2;
	level.scr_anim["zombie"]["run3"] 	= %ai_zombie_jap_run_v4;*/
	level.scr_anim["zombie"]["run4"] 	= %ai_zombie_jap_run_v1;
	level.scr_anim["zombie"]["run5"] 	= %ai_zombie_jap_run_v2;
	level.scr_anim["zombie"]["run6"] 	= %ai_zombie_jap_run_v5;

	level.scr_anim["zombie"]["walk5"] 	= %ai_zombie_jap_walk_v1;
	level.scr_anim["zombie"]["walk6"] 	= %ai_zombie_jap_walk_v2;
	level.scr_anim["zombie"]["walk7"] 	= %ai_zombie_jap_walk_v3;
	level.scr_anim["zombie"]["walk8"] 	= %ai_zombie_jap_walk_v4;

	level.scr_anim["zombie"]["sprint3"] = %ai_zombie_jap_run_v3;
	level.scr_anim["zombie"]["sprint4"] = %ai_zombie_jap_run_v6;
}