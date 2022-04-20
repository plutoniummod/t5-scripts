
/*===========================================================================
RIVER VO
 functions that manage the Vo and Dialoge in the River Level
===========================================================================*/

#include common_scripts\utility; 
#include maps\_utility;
#include maps\_anim;
#include maps\_music;


//*****************************************************************************
//*****************************************************************************
setup_vo()
{
	//
	// *** BOWMAN VO ***
	//

	level.scr_sound["bowman"]["ive_seen_worse_out_here"] = "vox_riv1_s01_007A_bowm";		//
	level.scr_sound["bowman"]["mason_on_board_now"] = "vox_riv1_s01_012A_bowm";				//
	level.scr_sound["bowman"]["stop_wasting_time_mason"] = "vox_riv1_s01_013A_bowm";		//
	level.scr_sound["bowman"]["we_have_4_shots"] = "vox_riv1_s01_023A_bowm";				// IN
	level.scr_sound["bowman"]["mason_call_out_targets"] = "vox_riv1_s01_028A_bowm";			// IN
	level.scr_sound["bowman"]["where_should_i_shoot"] = "vox_riv1_s01_029A_bowm";			// IN
	level.scr_sound["bowman"]["Mason_ive_reloaded"] = "vox_riv1_s01_030A_bowm";				// IN
	level.scr_sound["bowman"]["fuck_mason, gimme_something"] = "vox_riv1_s01_031A_bowm";	// IN
	level.scr_sound["bowman"]["reloading"] = "vox_riv1_s01_037A_bowm";						// IN
	level.scr_sound["bowman"]["need_more_ammo"] = "vox_riv1_s01_038A_bowm";					// IN
	level.scr_sound["bowman"]["gotta_reload"] = "vox_riv1_s01_039A_bowm";					// IN
	level.scr_sound["bowman"]["out_reloading"] = "vox_riv1_s01_040A_bowm";					// IN
	level.scr_sound["bowman"]["out"] = "vox_riv1_s01_041A_bowm";							// IN
	level.scr_sound["bowman"]["get_us_out_of_here"] = "vox_riv1_s01_050A_bowm";				// IN
	level.scr_sound["bowman"]["there_all_over_the_place"] = "vox_riv1_s01_051A_bowm";		// IN
	level.scr_sound["bowman"]["jesus"] = "vox_riv1_s01_052A_bowm";							// IN
	level.scr_sound["bowman"]["mason_step_on_it"] = "vox_riv1_s01_053A_bowm";				// IN
	level.scr_sound["bowman"]["were_sinking"] = "vox_riv1_s01_056A_bowm";					// IN
	level.scr_sound["bowman"]["woods"] = "vox_riv1_s01_057A_bowm";							// IN
	level.scr_sound["bowman"]["watch_out_there_ours"] = "vox_riv1_s01_064A_bowm";			// IN
	level.scr_sound["bowman"]["stop_firing_mason"] = "vox_riv1_s01_065A_bowm";				// IN
	level.scr_sound["bowman"]["mason_no_there_our"] = "vox_riv1_s01_066A_bowm";				// IN
	level.scr_sound["bowman"]["cease_fire_friendlies"] = "vox_riv1_s01_067A_bowm";			// IN
	level.scr_sound["bowman"]["there_on_the_move"] = "vox_riv1_s01_075A_bowm";				// IN
	level.scr_sound["bowman"]["mortar"] = "vox_riv1_s01_079A_bowm";							// IN
	level.scr_sound["bowman"]["watch_out"] = "vox_riv1_s01_080A_bowm";						// IN
	level.scr_sound["bowman"]["heads_down"] = "vox_riv1_s01_081A_bowm";						// IN
	level.scr_sound["bowman"]["no_we_need_to_destroy"] = "vox_riv1_s01_091A_bowm";			// IN
	level.scr_sound["bowman"]["not_yet_mason_we_need"] = "vox_riv1_s01_092A_bowm";			// IN
	level.scr_sound["bowman"]["bulls_eye"] = "vox_riv1_s01_096A_bowm";						// IN
	level.scr_sound["bowman"]["sog"] = "vox_riv1_s01_100A_bowm";							// IN
	level.scr_sound["bowman"]["yeah"] = "vox_riv1_s01_104A_bowm";							// IN
	level.scr_sound["bowman"]["another_one_down"] = "vox_riv1_s01_111A_bowm";				// IN
	level.scr_sound["bowman"]["they_aint_got_shit"] = "vox_riv1_s01_117A_bowm";				// IN
	level.scr_sound["bowman"]["lights_out_mother_fucker"] = "vox_riv1_s01_126A_bowm";		// IN
	level.scr_sound["bowman"]["dont_sit_still_for"] = "vox_riv1_s01_137A_bowm";				// 
	level.scr_sound["bowman"]["we_got_him"] = "vox_riv1_s01_145A_bowm";						// IN
	level.scr_sound["bowman"]["whatever_happened"] = "vox_riv1_s02_178A_bowm";				// IN
	level.scr_sound["bowman"]["theres_nothing_here"] = "vox_riv1_s02_186A_bowm";			// IN
	level.scr_sound["bowman"]["come_again"] = "vox_riv1_s03_191A_bowm";						// IN
	level.scr_sound["bowman"]["charlies_retreating"] = "vox_riv1_s03_219A_bowm";			// IN
	level.scr_sound["bowman"]["take_it_easy_mason"] = "vox_riv1_s03_226A_bowm";				// IN
//	level.scr_sound["bowman"]["woods_look_out"] = "vox_riv1_s03_229A_bowm";					// 
	level.scr_sound["bowman"]["what_happened"] = "vox_riv1_s03_229A_bowm_m";				// IN
	level.scr_sound["bowman"]["must_be_some_kind_of_setup"] = "vox_riv1_s03_234A_bowm_m";	// 
	level.scr_sound["bowman"]["the_nova_6_is_all_gone"] = "vox_riv1_s03_235A_bowm_m";		// 
	level.scr_sound["bowman"]["okay_mason_lets_go"] = "vox_riv1_s03_238A_bowm_m";			// 
//	level.scr_sound["bowman"]["mason_use_the_grenade"] = "vox_riv1_s03_243A_bowm";			// 
//	level.scr_sound["bowman"]["its_not_getting_any"] = "vox_riv1_s03_252A_bowm";			// 
	level.scr_sound["bowman"]["you_got_it_boss"] = "vox_riv1_s03_254A_bowm";				// 
	
	// Additioal Bowman Lines
	
	level.scr_sound["bowman"]["medic"] = "dds_bow_casualty_00";								// IN
	

	

	//
	// *** WOODS VO ***
	//

	level.scr_sound["woods"]["wed_better_get"] = "vox_riv1_s01_901A_wood";					// IN
	level.scr_sound["woods"]["thats_us_lets_go"] = "vox_riv1_s01_001A_wood";				// IN
	level.scr_sound["woods"]["mason_get_on_the_boat"] = "vox_riv1_s01_010A_wood";			// 
	level.scr_sound["woods"]["we_need_to_get_moving"] = "vox_riv1_s01_011A_wood";			// 
	level.scr_sound["woods"]["they_couldnt_make_it"] = "vox_riv1_s01_015A_wood";			// 
	level.scr_sound["woods"]["Man_the_gun"] = "vox_riv1_s01_016A_wood";						// 
	level.scr_sound["woods"]["m202s_bowman_starboard_side"] = "vox_riv1_s01_017A_wood";		// 
	level.scr_sound["woods"]["what_did_you_say"] = "vox_riv1_s01_019A_wood";				// IN
	level.scr_sound["woods"]["enemy_contact_dead_ahead"] = "vox_riv1_s01_021A_wood";		// IN
	level.scr_sound["woods"]["remember_what_i_said"] = "vox_riv1_s01_022A_wood";			// IN
	level.scr_sound["woods"]["mason_call_out_targets"] = "vox_riv1_s01_024A_wood";			// IN
	level.scr_sound["woods"]["tell_me_where_to_fire"] = "vox_riv1_s01_025A_wood";			// IN
	level.scr_sound["woods"]["im_waiting_for_your_signal"] = "vox_riv1_s01_026A_wood";		// IN
	level.scr_sound["woods"]["reloaded_and_ready"] = "vox_riv1_s01_027A_wood";				// IN
	level.scr_sound["woods"]["reloading"] = "vox_riv1_s01_032A_wood";						// IN
	level.scr_sound["woods"]["reload"] = "vox_riv1_s01_033A_wood";							// IN
	level.scr_sound["woods"]["wait_reloading"] = "vox_riv1_s01_034A_wood";					// IN
	level.scr_sound["woods"]["im_out"] = "vox_riv1_s01_035A_wood";							// IN
	level.scr_sound["woods"]["out_of_ammo"] = "vox_riv1_s01_036A_wood";						// IN
	level.scr_sound["woods"]["mason_we_cant_take_much"] = "vox_riv1_s01_046A_wood";			// IN
	level.scr_sound["woods"]["take_evasive_action"] = "vox_riv1_s01_047A_wood";				// IN
	level.scr_sound["woods"]["we_almost_lost_Bowman"] = "vox_riv1_s01_048A_wood";			// IN
	level.scr_sound["woods"]["heavy_fire"] = "vox_riv1_s01_049A_wood";						// IN
	level.scr_sound["woods"]["its_all_over"] = "vox_riv1_s01_054A_wood";					// IN
	level.scr_sound["woods"]["were_going_down"] = "vox_riv1_s01_055A_wood";					// IN
	level.scr_sound["woods"]["no_mason_there_on_our_side"] = "vox_riv1_s01_060A_wood";		// IN
	level.scr_sound["woods"]["what_are_you_doing"] = "vox_riv1_s01_061A_wood";				// IN
	level.scr_sound["woods"]["mason_youre_killing"] = "vox_riv1_s01_062A_wood";				// IN
	level.scr_sound["woods"]["Friendly fire"] = "vox_riv1_s01_063A_wood";					// IN
	level.scr_sound["woods"]["heads_up_enemy_camp_ahead"] = "vox_riv1_s01_068A_wood";		// IN
	level.scr_sound["woods"]["yeah_fucking_tear_em_up"] = "vox_riv1_s01_070A_wood";			// IN
	level.scr_sound["woods"]["shes_coming_down"] = "vox_riv1_s01_073A_wood";				// IN
	level.scr_sound["woods"]["look_out_mortars"] = "vox_riv1_s01_074A_wood";				// IN
	level.scr_sound["woods"]["incoming"] = "vox_riv1_s01_076A_wood";						// IN
	level.scr_sound["woods"]["mason_evasive"] = "vox_riv1_s01_077A_wood";					// IN
	level.scr_sound["woods"]["punch_it_mason"] = "vox_riv1_s01_078A_wood";					// 
	level.scr_sound["woods"]["wrong_way_mason"] = "vox_riv1_s01_087A_wood";					// IN
	level.scr_sound["woods"]["no_mason_not_that_way"] = "vox_riv1_s01_088A_wood";			// IN
	level.scr_sound["woods"]["save_it_mason"] = "vox_riv1_s01_089A_wood";					// IN
	level.scr_sound["woods"]["no_mason_save_it"] = "vox_riv1_s01_090A_wood";				// IN
	level.scr_sound["woods"]["thats_one_of_them"] = "vox_riv1_s01_093A_wood";				// IN
	level.scr_sound["woods"]["one_down"] = "vox_riv1_s01_094A_wood";						// IN
	level.scr_sound["woods"]["thats_the_last_of_them"] = "vox_riv1_s01_099A_wood";			// IN
	level.scr_sound["woods"]["nice_one_mason_now_head"] = "vox_riv1_s01_103A_wood";			// IN
	level.scr_sound["woods"]["multiple_targets_tower_straight"] = "vox_riv1_s01_105A_wood";	// IN
	level.scr_sound["woods"]["shred_those_bastards"] = "vox_riv1_s01_107A_wood";			// IN
	level.scr_sound["woods"]["fuck_zpu_to_the_left"] = "vox_riv1_s01_112A_wood";			// IN
	level.scr_sound["woods"]["that_was_a_bitch"] = "vox_riv1_s01_114A_wood";				// IN
	level.scr_sound["woods"]["two_more_towers_dead_ahead"] = "vox_riv1_s01_115A_wood";		// IN
	level.scr_sound["woods"]["alright_watch_it"] = "vox_riv1_s01_119A_wood";				// IN
	level.scr_sound["woods"]["bridge_dead_ahead"] = "vox_riv1_s01_120A_wood";				// IN
	level.scr_sound["woods"]["sampans_dont_let_them"] = "vox_riv1_s01_122A_wood";			// IN
	level.scr_sound["woods"]["one_more"] = "vox_riv1_s01_123A_wood";						// IN
	level.scr_sound["woods"]["yeah_i_think"] = "vox_riv1_s01_124A_wood";					// IN
	level.scr_sound["woods"]["another_zpu_up_on_that_ridge"] = "vox_riv1_s01_125A_wood";	// IN
	level.scr_sound["woods"]["two_more_sampans"] = "vox_riv1_s01_127A_wood";				// IN
	level.scr_sound["woods"]["one_left"] = "vox_riv1_s01_128A_wood";						// IN
	level.scr_sound["woods"]["another_zpu_how_many_more"] = "vox_riv1_s01_130A_wood";		// IN
	level.scr_sound["woods"]["what_the_hell_is_that"] = "vox_riv1_s01_132A_wood";			// IN
	level.scr_sound["woods"]["that_was_their_stronghold"] = "vox_riv1_s01_134A_wood";		// IN
	level.scr_sound["woods"]["something_bigs_on_its_way"] = "vox_riv1_s01_135A_wood";		// IN
	level.scr_sound["woods"]["nva_pt_boat"] = "vox_riv1_s01_136A_wood";						// IN
	level.scr_sound["woods"]["hes_on_fire_keep_at_it"] = "vox_riv1_s01_138A_wood";			// IN
	level.scr_sound["woods"]["we_hit_the_engine"] = "vox_riv1_s01_139A_wood";				// IN
	level.scr_sound["woods"]["hes_spewing_oil"] = "vox_riv1_s01_140A_wood";					// IN
	level.scr_sound["woods"]["smoked_him_take_him_out"] = "vox_riv1_s01_141A_wood";			// IN
	level.scr_sound["woods"]["turn_back_mason_we_have_to"] = "vox_riv1_s01_142A_wood";		// IN
	level.scr_sound["woods"]["mason_we_cant_leave_this_area"] = "vox_riv1_s01_143A_wood";	// IN
	level.scr_sound["woods"]["charlies_gone_for_now"] = "vox_riv1_s02_171A_wood";			// IN
	level.scr_sound["woods"]["roger_that_stay_in_touch"] = "vox_riv1_s02_173A_wood";		// IN
	level.scr_sound["woods"]["dont_blink"] = "vox_riv1_s02_175A_wood";						// IN
	level.scr_sound["woods"]["nothing_so_far_wait"] = "vox_riv1_s02_177A_wood";				// IN
	level.scr_sound["woods"]["we_got_a_downed_bird"] = "vox_riv1_s02_179A_wood";			// IN
	level.scr_sound["woods"]["bullshit"] = "vox_riv1_s02_181A_wood";						// IN
	level.scr_sound["woods"]["im_not_buying_it"] = "vox_riv1_s02_184A_wood";				// IN
	level.scr_sound["woods"]["right"] = "vox_riv1_s02_187A_wood";							// IN
	level.scr_sound["woods"]["i_fucking_hope_so"] = "vox_riv1_s03_193A_wood";				// IN
	level.scr_sound["woods"]["this_is_it_remember"] = "vox_riv1_s03_197A_wood";				// IN
	level.scr_sound["woods"]["mason_head_for_the_shore"] = "vox_riv1_s03_200A_wood";		// IN
	level.scr_sound["woods"]["mason_we_dont_have_time"] = "vox_riv1_s03_201A_wood";			// 	
	level.scr_sound["woods"]["what_are_you_waiting_for"] = "vox_riv1_s03_202A_wood";		// 	
	level.scr_sound["woods"]["get_to_shore_mason"] = "vox_riv1_s03_203A_wood";				// 	
	level.scr_sound["woods"]["great_have_one_of_your_men"] = "vox_riv1_s03_206A_wood";		// IN
	level.scr_sound["woods"]["follow_me_and_stay_together"] = "vox_riv1_s03_208A_wood";		// IN
	level.scr_sound["woods"]["we_dont_see_anything"] = "vox_riv1_s03_211A_wood";			// IN
	level.scr_sound["woods"]["spetznaz"] = "vox_riv1_s03_217A_wood";						// IN
	level.scr_sound["woods"]["dont_give_up_the_hinds"] = "vox_riv1_s03_218A_wood";			// IN
	level.scr_sound["woods"]["hell_be_back"] = "vox_riv1_s03_220A_wood";					// IN
	level.scr_sound["woods"]["thats_why_the_hinds"] = "vox_riv1_s03_221A_wood";				// IN
	level.scr_sound["woods"]["thats_the_last_of_them_spetznaz"] = "vox_riv1_s03_223A_wood";	// IN
	level.scr_sound["woods"]["well_have_to_climb"] = "vox_riv1_s03_224A_wood";				// IN
	level.scr_sound["woods"]["easy_easy"] = "vox_riv1_s03_228A_wood";						// IN
	level.scr_sound["woods"]["ill_stabilize_at_this_end"] = "vox_riv1_s03_227A_wood";		// IN
	level.scr_sound["woods"]["mason"] = "vox_riv1_s03_230A_wood";							// IN
	level.scr_sound["woods"]["ok_same_drill"] = "vox_riv1_s03_231A_wood";					// 
	level.scr_sound["woods"]["the_chemical_weapon"] = "vox_riv1_s03_231A_wood_m";			// IN
	level.scr_sound["woods"]["grenade_launchers_china_lakes"] = "vox_riv1_s03_233A_wood_m";	// IN
	level.scr_sound["woods"]["look_down_there"] = "vox_riv1_s03_239A_wood";					// IN
	level.scr_sound["woods"]["bowman_sniper_rifle"] = "vox_riv1_s03_240A_wood";				// IN
	level.scr_sound["woods"]["mason_down_there"] = "vox_riv1_s03_242A_wood";				// 	
	level.scr_sound["woods"]["theyve_almost_sunk_our_boat"] = "vox_riv1_s03_244A_wood";		// 	
	level.scr_sound["woods"]["It's all over"] = "vox_riv1_s03_245A_wood";					// 	
	level.scr_sound["woods"]["fuck_the_hinds_are_back"] = "vox_riv1_s03_246A_wood";			// 	
	level.scr_sound["woods"]["fall_scream"] = "vox_riv1_s03_248A_wood";						// Arrrrrrggggghhhhhhhhhh!
	level.scr_sound["woods"]["look_out"] = "vox_riv1_s99_704A_wood";						// IN

//	level.scr_sound["woods"]["bowman_mason_we_made_it"] = "vox_riv1_s03_249A_wood";			// 	
//	level.scr_sound["woods"]["sniper_rifles_hit_the_pilot"] = "vox_riv1_s03_250A_wood";		// 	
	level.scr_sound["woods"]["great_shot_mason"] = "vox_riv1_s03_251A_wood";				// IN
//	level.scr_sound["woods"]["take_as_many"] = "vox_riv1_s03_253A_wood";					// 	
//	level.scr_sound["woods"]["what_are_we_waiting_for"] = "vox_riv1_s03_256A_wood";			// 	

	// WOODS: Addtional 

	level.scr_sound["woods"]["mason_take_out_those_snipers"] = "vox_riv1_s99_700A_wood";	// 
	level.scr_sound["woods"]["clear_move_up"] = "vox_in_1_s02_049A_wood";					//
	level.scr_sound["woods"]["push_forward"] = "vox_in_1_s04_305A_wood";					// 
	level.scr_sound["woods"]["snipers_in_the_trees"] = "vox_riv1_s99_707A_wood";			// IN
	level.scr_sound["woods"]["check_high_snipers"] = "vox_riv1_s99_708A_wood";				// IN
	level.scr_sound["woods"]["in_the_tree_sniper"] = "vox_riv1_s99_709A_wood";				// IN
	
	
	//******************
	//*** REZNOV VO: ***
	//******************

	level.scr_sound["reznov"]["ill_watch_for_snipers"] = "vox_riv1_s01_020A_rezn";			// 
	level.scr_sound["reznov"]["mason_fire_your"] = "vox_riv1_s01_069A_rezn";				// IN
	level.scr_sound["reznov"]["show_no_mercy"] = "vox_riv1_s01_071A_rezn";					// IN
	level.scr_sound["reznov"]["hard_to_starboard"] = "vox_riv1_s01_082A_rezn";				// IN
	level.scr_sound["reznov"]["obliterate_them"] = "vox_riv1_s01_083A_rezn";				// IN
	level.scr_sound["reznov"]["brace_for_impact"] = "vox_riv1_s01_084A_rezn";				// IN
	level.scr_sound["reznov"]["great_shot_one_more_left"] = "vox_riv1_s01_097A_rezn";		// IN
	level.scr_sound["reznov"]["good_work_my_friend"] = "vox_riv1_s01_101A_rezn";			// IN
	level.scr_sound["reznov"]["perfect_shot_its_collapsing"] = "vox_riv1_s01_106A_rezn";	// IN
	level.scr_sound["reznov"]["its_just_like_back_in"] = "vox_riv1_s01_109A_rezn";			// IN
	level.scr_sound["reznov"]["mason_what_are_you_waiting"] = "vox_riv1_s01_113A_rezn";		// IN
	level.scr_sound["reznov"]["blow_them_to_hell"] = "vox_riv1_s01_116A_rezn";				// IN
	level.scr_sound["reznov"]["watch_them_burn"] = "vox_riv1_s01_121A_rezn";				// IN
	level.scr_sound["reznov"]["dasvidanya"] = "vox_riv1_s01_129A_rezn";						// IN
	level.scr_sound["reznov"]["use_those_buildings"] = "vox_riv1_s01_144A_rezn";			// IN
	level.scr_sound["reznov"]["the_plane_must_be_close"] = "vox_riv1_s02_182A_rezn";		// IN
	level.scr_sound["reznov"]["i_feel_it"] = "vox_riv1_s03_190A_rezn";						// IN
	level.scr_sound["reznov"]["finally_mason_our_key"] = "vox_riv1_s03_198A_rezn";			// IN
	level.scr_sound["reznov"]["kravchenko_he_must_die"] = "vox_riv1_s03_236A_rezn";			// IN
	level.scr_sound["reznov"]["brace_yourself"] = "vox_riv1_s03_247A_rezn";					// IN
	
	
	//*****************
	//*** MASON VO: ***
	//*****************
		
	level.scr_sound["mason"]["the_cia_downed"] = "vox_riv1_s01_900a_maso";					// IN
	level.scr_sound["mason"]["right_lets_move"] = "vox_riv1_s01_902a_maso";					// IN
	level.scr_sound["mason"]["what_about_reznov"] = "vox_riv1_s01_018a_maso";				// 
	level.scr_sound["mason"]["that_was_close"] = "vox_riv1_s01_042a_maso";					// IN
	level.scr_sound["mason"]["i_need_to_get_clear"] = "vox_riv1_s01_043a_maso";				// IN
	level.scr_sound["mason"]["dam_it_there_everywhere"] = "vox_riv1_s01_044a_maso";			// IN
	level.scr_sound["mason"]["fuck_that_almost_sunk_us"] = "vox_riv1_s01_045a_maso";		// IN
	level.scr_sound["mason"]["were_burning"] = "vox_riv1_s01_058a_maso";					// IN
	level.scr_sound["mason"]["taking_water"] = "vox_riv1_s01_059a_maso";					// IN
	level.scr_sound["mason"]["tower_up_ahead"] = "vox_riv1_s01_072a_maso";					// IN
	level.scr_sound["mason"]["its_gonna_be_close"] = "vox_riv1_s01_085a_maso";				// IN
	level.scr_sound["mason"]["watch_out"] = "vox_riv1_s01_086a_maso";						// IN
	level.scr_sound["mason"]["yer_right_on_the_money"] = "vox_riv1_s01_095a_maso";			// IN
	level.scr_sound["mason"]["come_on"] = "vox_riv1_s01_098a_maso";							// IN
	level.scr_sound["mason"]["thats_gotta_be_the_last"] = "vox_riv1_s01_131a_maso";			// IN
	level.scr_sound["mason"]["give_it_all_youve_got"] = "vox_riv1_s01_133a_maso";			// IN
	level.scr_sound["mason"]["that_all_they_got"] = "vox_riv1_s01_146a_maso";				// IN
	level.scr_sound["mason"]["reznov_help_me_out"] = "vox_riv1_s02_157a_maso";				// 
	level.scr_sound["mason"]["where_the_hell_were_you"] = "vox_riv1_s02_170a_maso";			// 
	level.scr_sound["mason"]["dont_like_the_look_of_this"] = "vox_riv1_s02_174a_maso";		// IN
	level.scr_sound["mason"]["bowman_what_happened"] = "vox_riv1_s02_185a_maso";			// IN
	level.scr_sound["mason"]["kravchenko_he_must_be_near_by"] = "vox_riv1_s03_192a_maso";	// IN
	level.scr_sound["mason"]["it_must_have_been_nova_6"] = "vox_riv1_s03_222a_maso";		// IN
	level.scr_sound["mason"]["ill_go_first"] = "vox_riv1_s03_225a_maso";					// IN
	level.scr_sound["mason"]["nova_6_must_have_dispersed"] = "vox_riv1_s03_232a_maso_m";	// IN
	level.scr_sound["mason"]["he_must_die"] = "vox_riv1_s03_237a_maso_m";					// IN
	level.scr_sound["mason"]["you_got_it"] = "vox_riv1_s03_241A_maso";						// IN
	
	// MASON: Capture dialog
	level.scr_sound["kravchenko"]["its_him"] = "vox_riv1_s03_259A_krav_m";			//It's him.
	level.scr_sound["dragovich"]["its_been"] = "vox_riv1_s03_260A_drag_m";			//It's been too long Mason.
	level.scr_sound["dragovich"]["we_must"] = "vox_riv1_s03_261A_drag_m";			//We must make up for lost time.


	//
	// *** YOUNG SOLDIER ***
	//

	level.scr_sound["kid"]["we_did_it"] = "vox_riv1_s01_102A_red4";								// 
	level.scr_sound["kid"]["another_tower"] = "vox_riv1_s01_110A_red4";							// IN
	level.scr_sound["kid"]["way_to_go"] = "vox_riv1_s01_108A_red4";								// 
	level.scr_sound["kid"]["sergent_another_zpu"] = "vox_riv1_s01_118A_red4";					// IN



	//
	// *** US PILOT 1 ***
	//

	level.scr_sound["us_pilot_1"]["no_movement_anywhere"] = "vox_riv1_s02_172A_usc1_f";				// IN
	level.scr_sound["us_pilot_1"]["all_clear_here"] = "vox_riv1_s02_176A_usc1_f";					// IN
	level.scr_sound["us_pilot_1"]["theres_nothing_out_here"] = "vox_riv1_s02_180A_usc1_f";			// IN
	level.scr_sound["us_pilot_1"]["im_at_a_canyon"] = "vox_riv1_s02_183A_usc1_f";					// IN
	level.scr_sound["us_pilot_1"]["i_see_you_wolf_10"] = "vox_riv1_s03_188A_usp1_f";				// IN
	level.scr_sound["us_pilot_1"]["nothing_behind_you"] = "vox_riv1_s03_189A_usp1";					// IN
	level.scr_sound["us_pilot_1"]["theyve_found_it"] = "vox_riv1_s03_194A_usp1_f";					// IN
	level.scr_sound["us_pilot_1"]["thats_your_plane_wolf_10"] = "vox_riv1_s03_196A_usp1_f";			// IN
	level.scr_sound["us_pilot_1"]["activity"] = "vox_riv1_s03_210A_usp1_f";							// IN
	level.scr_sound["us_pilot_1"]["enemy_helicopters_incoming"] = "vox_riv1_s03_214A_usc1_f";		// IN
	level.scr_sound["us_pilot_1"]["sorry_were_late_boys"] = "vox_riv1_s03_255A_usp1_f";				// 	
	level.scr_sound["us_pilot_1"]["repeat_visual_confirmation"] = "vox_riv1_s03_195A_usp2_f";		// IN - BORROWED


	//
	// *** US PILOT 2 ***
	//

	level.scr_sound["us_pilot_2"]["repeat_visual_confirmation"] = "vox_riv1_s03_195A_usp2_f";		// SWAPPED!!!
	level.scr_sound["us_pilot_2"]["wolf_10_this_is_centurion_3"] = "vox_riv1_s03_199A_usp2_f";		// IN
	level.scr_sound["us_pilot_2"]["i_have_limited_ground_support"] = "vox_riv1_s03_204A_usp2_f";	// IN
	level.scr_sound["us_pilot_2"]["ill_stay_low_and_cover_you"] = "vox_riv1_s03_207A_usp2_f";		// IN
	level.scr_sound["us_pilot_2"]["movement_centurions_4_and_5"] = "vox_riv1_s03_209A_usp2_f";		// IN
    level.scr_sound["us_pilot_2"]["waiting_for_us"] = "vox_riv1_s03_215A_usc2_f"; 					// IN
	
	
	//
	// *** US PILOT 3 ***
	//
	
	level.scr_sound["us_pilot_3"]["centurion_4_to_base"] = "vox_riv1_s03_216A_usc3_f";				// 	IN
	
	//
	// *** BOAT DRAG EVENT ***
	//
	
	// as chinook flies in
	level.scr_sound["chinook"]["got_you_in_sight"] 		= "vox_riv1_s02_147A_chi1_f_m"; //Wolf 10, this is Rescue 1. Got you in sight. Sector is overrun, we're pulling you out.
	level.scr_sound["woods"]["roger_airlifted"] 			= "vox_riv1_s02_148A_wood_m"; //Roger. We're getting airlifted out. Mason, that's our rally point.
	level.scr_sound["chinook"]["abort_evac"] 					= "vox_riv1_s02_151A_usc1_f"; //Rescue 1, this is Centurion 5. Beaucoup movement. Abort evac, there's no time!
	level.scr_sound["chinook"]["theyd_do_for_us"] 		= "vox_riv1_s02_152A_chi1_f"; //Negative. We have SOG down there, they'd do it for us. We're going in.
	level.scr_sound["woods"]["ch47_make_it_quick"] 		= "vox_riv1_s02_153A_wood"; //CH-47. We gotta make it quick. The Chinook's gonna airlift us to LZ Delta Tango.
	// nag lines
	level.scr_sound["woods"]["head_for_rp"] 					= "vox_riv1_s02_149A_wood";	//Mason, head for the RP!
	level.scr_sound["woods"]["were_out_of_time"] 			= "vox_riv1_s02_150A_wood"; //We're out of time. Now Mason, before it's too late!	
	// chinook gets into position
	level.scr_sound["chinook"]["light_them_up"] 			= "vox_riv1_s02_155A_chi1_f"; //Wolf 10, we're in position. Centurions, light em up!
	// ai rope-tying anim (ANIM NOTETRACK)
	level.scr_sound["woods"]["i_got_the_front"] 			= "vox_riv1_s02_156A_wood"; //I got the two at the front. Mason, hook up the cable.
	level.scr_sound["mason"]["reznov_help_rope"] 			= "vox_riv1_s02_157A_maso"; //Reznov? Help me out!
	// player rope-tying anim (ANIM NOTETRACK)
	level.scr_sound["chinook"]["rescue_1_pull_out"] 	= "vox_riv1_s02_158A_usc1_f";	//Rescue 1, pull out! Pull out now. We can't hold them.
	level.scr_sound["chinook"]["i_know_out"] 					= "vox_riv1_s02_159A_chi1_f"; //I know.				
	level.scr_sound["woods"]["mason_go_go"] 					= "vox_riv1_s02_160A_wood";	//Mason!		
	level.scr_sound["woods"]["lets_go"] 							= "vox_riv1_s02_161A_wood";	//Let's go.	
	// drag anim (ANIM NOTETRACK)
	level.scr_sound["chinook"]["we_are_hit"] 					= "vox_riv1_s02_162A_chi1_f"; //We're hit, we're hit! Wolf 10, cut the cables, we're going down, we're going down. Cut the cables!
	level.scr_sound["woods"]["fuck_mason_cables"] 		= "vox_riv1_s02_163A_wood";	//Fuck. Mason, cut the cable!
	level.scr_sound["chinook"]["i_can't_hold"] 				= "vox_riv1_s02_164A_chi1_f"; //I can't hold it!
	level.scr_sound["chinook"]["brace_for_impact"] 		= "vox_riv1_s02_165A_chi1_f"; //Brace for impact!
	// drag aftermath
	level.scr_sound["pbr"]["rescue_1_is_down"] 		= "vox_riv1_s02_166A_usc1_f"; //Rescue 1 is down. Charlie's retreated to the tree line.	
	level.scr_sound["woods"]["roger_can_you"] 				= "vox_riv1_s02_167A_wood_m";	//Roger, Centurion. Can you stay with us?
	level.scr_sound["pbr"]["can_do_easy"] 				= "vox_riv1_s02_168A_usc1_f_m";	//Can do easy, Wolf 10. Proceed up river, we got your back.				
	level.scr_sound["woods"]["bowman_stay_on_point"]	= "vox_riv1_s02_169A_wood_m"; //Bowman, stay on point. Mason, take the wheel.
	level.scr_sound["mason"]["where_the_hell"] 				= "vox_riv1_s02_170A_maso_m"; //Where the hell were you?
	
	// bowman gets into the turret (ANIM NOTETRACK)
	// NOT SURE WHERE TO PUT THIS YET
	level.scr_sound["bowman"]["woods_movement"] 			= "vox_riv1_s02_154A_bowm";	//Woods, movement! East river. I got it.
	
	level.scr_sound[ "vc_ambusher_first_wave_1" ][ "vc_appear" ] = "vox_riv1_s03_212A_vic1";
	level.scr_sound[ "vc_ambusher_first_wave_2" ][ "vc_appear" ] = "vox_riv1_s03_213A_nvac";
}


//*****************************************************************************
// self = entity to play aound alias on
//*****************************************************************************

playVO_proper( sound_alias, delay )
{    
	self endon( "death" );

	if( isdefined(delay) )
	{
		wait( delay );
	}
	
	// Maybe the guy died while waiting?
	if( !isdefined( self ) )
	{
		return;
	}
	
	if( !isdefined( self.health ) )
	{
		return;
	}

	
	if( self.health <= 0 )
	{
		return;
	}
	
	self anim_single( self, sound_alias );
	level.vo_last_time = gettime();
}


//*****************************************************************************
// Play VO on a misc entity via targetname
//
// <optional> animname: Do we wan to force the animname of the entity?
//*****************************************************************************

vo_targatname( targetname, sound_alias, delay, animname )
{
	ent = GetEnt( targetname, "targetname" );
	if( isdefined(ent) )
	{
		if( isdefined(animname) )
		{
			ent.animname = animname;
		}
		
		ent playVO_proper( sound_alias, delay );
	}
}


//*****************************************************************************
// self = boat
//
// Covers:-
//	- The players boat taking damage
//*****************************************************************************

vo_boat_misc_features()
{
	// make sure there's only one instance of this running
	self notify( "stop_misc_features_vo" );
	
	self endon( "stop_misc_features_vo" );
	self endon( "death" );

	// Setup taking damage speech
	vo_boat_damage_woods = [];
	vo_boat_damage_woods[ vo_boat_damage_woods.size ] = "mason_we_cant_take_much";
	vo_boat_damage_woods[ vo_boat_damage_woods.size ] = "take_evasive_action";
	vo_boat_damage_woods[ vo_boat_damage_woods.size ] = "we_almost_lost_Bowman";
	vo_boat_damage_woods[ vo_boat_damage_woods.size ] = "heavy_fire";
	
	vo_boat_damage_bowman = [];
	vo_boat_damage_bowman[ vo_boat_damage_bowman.size ] = "get_us_out_of_here";
	vo_boat_damage_bowman[ vo_boat_damage_bowman.size ] = "there_all_over_the_place";
	vo_boat_damage_bowman[ vo_boat_damage_bowman.size ] = "jesus";
	vo_boat_damage_bowman[ vo_boat_damage_bowman.size ] = "mason_step_on_it";
	
	vo_boat_damage_mason = [];
	vo_boat_damage_mason[ vo_boat_damage_mason.size ] = "that_was_close";
	vo_boat_damage_mason[ vo_boat_damage_mason.size ] = "i_need_to_get_clear";
	vo_boat_damage_mason[ vo_boat_damage_mason.size ] = "dam_it_there_everywhere";
	vo_boat_damage_mason[ vo_boat_damage_mason.size ] = "fuck_that_almost_sunk_us";


	woods_index = randomint( vo_boat_damage_woods.size );
	bowman_index = randomint( vo_boat_damage_bowman.size );
	mason_index = randomint( vo_boat_damage_mason.size );

	
	//************
	//*** LOOP ***
	//************

	last_heavy_damage_time = 0;
	last_health = self.boat_health;

	boat_damage_active = 1;
	
	while( 1 )
	{
		time = GetTime();

		// Once we reach the Boss Boat, stop giving boat damage messages
		if( flag("boss_boat_started") == true )
		{
			boat_damage_active = 0;
		}

	
		/******************************/
		/* Check for player damage VO */
		/******************************/

		if( boat_damage_active )
		{
			// Player suddenly taking a lot of damege
			dt = (time - last_heavy_damage_time) / 1000;
			if( dt > 6 )
			{
				health_drop = last_health - self.boat_health;
				health_frac = self.boat_health / level._player_boat_health;

				//IPrintLnBold( "FRAC: " + health_frac );
			
				if( (health_frac < 0.6) && (health_drop > 50) )
				{
					rval = randomint( 100 );
					if( rval > 66 )
					{
						level.woods thread maps\river_vo::playVO_proper( vo_boat_damage_woods[woods_index], 0 );
						woods_index++;
						if( woods_index >= vo_boat_damage_woods.size )
						{
							woods_index = 0;
						}
					}
					else if (rval > 33 )
					{
						level.bowman thread maps\river_vo::playVO_proper( vo_boat_damage_bowman[bowman_index], 0 );
						bowman_index++;
						if( bowman_index >= vo_boat_damage_bowman.size )
						{
							bowman_index = 0;
						}
					}
					else
					{
						level.mason thread maps\river_vo::playVO_proper( vo_boat_damage_mason[mason_index], 0 );
						mason_index++;
						if( mason_index >= vo_boat_damage_mason.size )
						{
							mason_index = 0;
						}
					}
					
					last_heavy_damage_time = time;
				}
			}
		}


		/*******************************************************/
		/* Check for player recovering from significant damage */
		/*******************************************************/
		
		last_health = self.boat_health;
		
		wait( 0.5 );
	}
}


//*****************************************************************************
//*****************************************************************************

vo_initial_island()
{
/*
	all_trees = getentarray( "fxanim_tree", "targetname" );
	
	// Find the tree on the 1st island
	pos = ( -20176, -60688, 90 );
	closest = 9999999.0;
	tree = undefined;
	for ( i=0; i<all_trees.size; i++ )
	{
		dist = Distance( all_trees[i].origin, pos );
		if( dist < closest )
		{
			closest = dist;
			tree = all_trees[i];
		}
	}
	
	// Wait for the tree to get blown up
	while( 1 )
	{
		//IPrintLnBold( "TREE HEALTH: " + tree.health );
		wait( 0.2 );
	}
*/
}


//*****************************************************************************
// VO: Mortar Attack Event
//*****************************************************************************

vo_mortar_attack_trucks()
{
	// Wait for the mortar vehicles to be destroyed
	
	vo_delay = 0.3;
	
	num_killed = 0;
	while( num_killed < 3 )
	{
		level waittill( "mortar_gun_destroyed" );
		num_killed++;
		
		// 1st Kill
		if( num_killed == 1 )
		{
			rval = randomint(100);
			if( rval > 66 )
			{
				level.woods thread maps\river_vo::playVO_proper( "one_down", vo_delay );
			}
			else if( rval > 33 )
			{
				level.woods thread maps\river_vo::playVO_proper( "thats_one_of_them", vo_delay );
			}
			else
			{
				level.mason thread maps\river_vo::playVO_proper( "yer_right_on_the_money", vo_delay );
			}
		}
		
		// 2nd Kill
		else if( num_killed == 2 )
		{
			rval = randomint( 100 );
			if( rval > 66 )
			{
				level.bowman thread maps\river_vo::playVO_proper( "bulls_eye", vo_delay );
			}
			else if( rval > 33 )
			{
				level.reznov thread maps\river_vo::playVO_proper( "great_shot_one_more_left", vo_delay );
			}
			else
			{
				level.mason thread maps\river_vo::playVO_proper( "come_on", vo_delay );
			}
		}
		
		// 3rd Kill
		else
		{
			rval = randomint( 100 );
			if( rval > 66 )
			{
				level.bowman thread maps\river_vo::playVO_proper( "sog", vo_delay );
			}
			else if( rval > 33 )
			{
				level.woods thread maps\river_vo::playVO_proper( "thats_the_last_of_them", vo_delay );
			}
			else
			{
				level.reznov thread maps\river_vo::playVO_proper( "good_work_my_friend", vo_delay );
			}
		}
	}
	
	
	// VO for the Hueys attacking the bridge
	wait( 4 );
	level.woods thread maps\river_vo::playVO_proper( "nice_one_mason_now_head", 0 );
	
	
	// When the player boats passes the debris of the blown bridge
	multiple_targets_pos = ( -14230, -56825, 22 );
	while( 1 )
	{
		dist = Distance( level.player.origin, multiple_targets_pos );
		if( dist < 1300 )
		{
			break;
		}
		wait( 0.1 );
	}
	level.woods thread maps\river_vo::playVO_proper( "multiple_targets_tower_straight", 0 );
	
	
}


//*****************************************************************************
// self = vehicle that fired
//*****************************************************************************

vo_mortar_fired_at_player()
{
	if( !isdefined( level.mortar_vo_index ) )
	{
		level.mortar_vo_index = randomint( 4 );
	}


	//************************
	// As the missile is fired
	//************************

	if( level.mortar_vo_index == 0 )
	{
		ai = "woods";
	}
	else if( level.mortar_vo_index == 1 )
	{
		ai = "bowman";
	}
	else if( level.mortar_vo_index == 2 )
	{
		ai = "mason";
	}
	else
	{
		ai = "reznov";
	}
	
	level.mortar_vo_index++;
	if( level.mortar_vo_index > 3 )
	{
		level.mortar_vo_index = 0;
	}
	
	switch( ai )
	{
		case "woods":
			rval = randomint( 100 );
			if( rval > 66 )
			{
				level.woods thread maps\river_vo::playVO_proper( "incoming", 0.5 );
			}
			else if( rval > 33 )
			{
				level.woods thread maps\river_vo::playVO_proper( "mason_evasive", 0.5 );
			}
			else
			{
				level.woods thread maps\river_vo::playVO_proper( "punch_it_mason", 0.5 );
			}
		break;

		case "bowman":
			rval = randomint( 100 );
			if( rval > 66 )
			{
				level.bowman thread maps\river_vo::playVO_proper( "mortar", 0.5 );
			}
			else if( rval > 33 )
			{
				level.bowman thread maps\river_vo::playVO_proper( "watch_out", 0.5 );
			}
			else
			{
				level.bowman thread maps\river_vo::playVO_proper( "heads_down", 0.5 );
			}
		break;
		
		case "mason":
			rval = randomint( 100 );
			if( rval > 50 )
			{
				level.mason thread maps\river_vo::playVO_proper( "its_gonna_be_close", 0.5 );
			}
			else
			{
				level.mason thread maps\river_vo::playVO_proper( "watch_out", 0.5 );
			}
		break;
		
		case "reznov":
			rval = randomint( 100 );
			if( rval > 66 )
			{
				level.reznov thread maps\river_vo::playVO_proper( "hard_to_starboard", 0.5 );
			}
			else if( rval > 33 )
			{
				level.reznov thread maps\river_vo::playVO_proper( "obliterate_them", 0.5 );
			}
			else
			{
				level.reznov thread maps\river_vo::playVO_proper( "brace_for_impact", 0.5 );
			}
		break;
	}
		
	//*******************************
	// As the missile is about to hit
	//*******************************
}


//*****************************************************************************
// VO: AA Guns
//*****************************************************************************

vo_aa_guns()
{
	// AA GUN 1
	quad50_1 = GetEnt( "boat_drive_left_path_quad50", "targetname" );
	while( quad50_1.health > 0 )
	{
		wait( 0.1 );
	}
	level.woods thread maps\river_vo::playVO_proper( "that_was_a_bitch", 0.2 );
	level.woods thread maps\river_vo::playVO_proper( "two_more_towers_dead_ahead", 3.5 );
	quad50_1.left_light delete();
	quad50_1.right_light delete();

	
	// AA GUN 2
	quad50_2 = GetEnt( "quad50_2", "targetname" );
	quad50_2 waittill( "death" );
	level.woods thread maps\river_vo::playVO_proper( "alright_watch_it", 0.2 );
	level.woods thread maps\river_vo::playVO_proper( "bridge_dead_ahead", 3.5 );
	quad50_2.left_light delete();
	quad50_2.right_light delete();

	
	// AA GUN 3
	quad50_3 = GetEnt( "quad50_3", "targetname" );
	quad50_3 waittill( "death" );
	level.bowman thread maps\river_vo::playVO_proper( "lights_out_mother_fucker", 0.2 );
	quad50_3.left_light delete();
	quad50_3.right_light delete();

}


//*****************************************************************************
// VO: 1st wave of sampans
//*****************************************************************************

vo_first_turn_sampans()
{
	level.woods thread maps\river_vo::playVO_proper( "sampans_dont_let_them", 3.5 );
	level.woods thread maps\river_vo::playVO_proper( "another_zpu_up_on_that_ridge", 6.5 );
	
	sampans = [];
	sampans[ sampans.size ] = GetEnt( "first_turn_2_sampan_1", "targetname" );
	sampans[ sampans.size ] = GetEnt( "first_turn_2_sampan_2", "targetname" );

	num_killed = 0;
	start_time = GetTime();
	finish_time = start_time + (20*1000);
	
	time = 0;

	while( finish_time > time )
	{
		for( i=0; i<sampans.size; i++ )
		{
			if( sampans[i].health <= 0 )
			{
				if( num_killed == 0 )
				{
					level.woods thread maps\river_vo::playVO_proper( "one_more", 0.2 );
				}
				else
				{
					level.woods thread maps\river_vo::playVO_proper( "yeah_i_think", 0.2 );
				}
				
				sampans = array_remove( sampans, sampans[i] );
				
				num_killed++;
				break;
			}
		}

		// Have we finished with the sampans?
		if( sampans.size <= 0 )
		{
			break;
		}
		
		wait( 0.1 );
		time = GetTime();
	}
}


//*****************************************************************************
// VO: 2nd wave of sampans
//*****************************************************************************

vo_second_sampans_wave()
{
	level.woods thread maps\river_vo::playVO_proper( "two_more_sampans", 2 );
	level.woods thread maps\river_vo::playVO_proper( "another_zpu_how_many_more", 8 );
	
	sampans = [];
	sampans[ sampans.size ] = GetEnt( "s_turn_bend_2_sampan_1", "targetname" );
	sampans[ sampans.size ] = GetEnt( "s_turn_bend_2_sampan_2", "targetname" );

	num_killed = 0;
	start_time = GetTime();
	finish_time = start_time + (20*1000);
	
	time = 0;

	while( finish_time > time )
	{
		for( i=0; i<sampans.size; i++ )
		{
			if( sampans[i].health <= 0 )
			{
				if( num_killed == 0 )
				{
					level.woods thread maps\river_vo::playVO_proper( "one_left", 0.2 );
				}
				else
				{
					level.reznov thread maps\river_vo::playVO_proper( "dasvidanya", 0.2 );
				}
				
				sampans = array_remove( sampans, sampans[i] );
				
				num_killed++;
				break;
			}
		}

		// Have we finished with the sampans?
		if( sampans.size <= 0 )
		{
			break;
		}
		
		wait( 0.1 );
		time = GetTime();
	}
}


//*****************************************************************************
// self = tower
//*****************************************************************************

vo_guard_tower()
{
	first_tower = 1;
	first_tower_pos = ( -16911, -63335, 0 );
	
	first_island_1 = 1;
	first_island_1_pos = ( -14047, -52240, 0 );

	first_island_2 = 1;
	first_island_2_pos = ( -13587, -49312, 0 );
	
	aa_gun_tower_1 = 1;
	aa_gun_tower_1_pos = ( -7197, -42596, 0 );
	
	aa_gun_tower_2 = 1;
	aa_gun_tower_2_pos = ( -7337, -40186, 0 );

	in_range = 1000;
	tower_pos = ( self.origin[0], self.origin[1], 0 );


	//*****************
	// Check 1st Island
	//*****************
	if( first_tower == 1 )
	{
		dist = Distance( tower_pos, first_tower_pos ); 
		if( dist < in_range )
		{
			level.woods thread maps\river_vo::playVO_proper( "shes_coming_down", 0.3 );
			first_tower = 0;
			return;
		}
	}
	
	//*******************
	// Check 1st island_1
	//*******************
	if( first_island_1 == 1 )
	{
		dist = Distance( tower_pos, first_island_1_pos ); 
		if( dist < in_range )
		{
			level.reznov thread maps\river_vo::playVO_proper( "perfect_shot_its_collapsing", 0.3 );
			first_island_1 = 0;
			return;
		}
	}

	//*******************
	// Check 1st island_2
	//*******************
	if( first_island_2 == 1 )
	{
		dist = Distance( tower_pos, first_island_2_pos ); 
		if( dist < in_range )
		{
			level.bowman thread maps\river_vo::playVO_proper( "another_one_down", 0.3 );
			first_island_2 = 0;
			return;
		}
	}


	//*********************
	// Check aa gun tower 1
	//*********************
	if( aa_gun_tower_1 == 1 )
	{
		dist = Distance( tower_pos, aa_gun_tower_1_pos ); 
		if( dist < in_range )
		{
			level.reznov thread maps\river_vo::playVO_proper( "blow_them_to_hell", 0.3 );
			aa_gun_tower_1 = 0;
			return;
		}
	}

	//*********************
	// Check aa gun tower 2
	//*********************
	if( aa_gun_tower_2 == 1 )
	{
		dist = Distance( tower_pos, aa_gun_tower_2_pos ); 
		if( dist < in_range )
		{
			level.bowman thread maps\river_vo::playVO_proper( "they_aint_got_shit", 0.3 );
			aa_gun_tower_2 = 0;
			return;
		}
	}
}

