#include maps\_utility;
#include common_scripts\utility; 
#include maps\_anim; 
#include maps\underwaterbase_util;
#include maps\_music;

main()
{
	init_voice();
	ai_anims();
	player_anims();
	vehicle_anims();
	object_anims();
}


//
//	ALL VO LINES
//
//	Replace first index with character animname
//	Replace "anime" with the dialog alias you would like to use.
init_voice()
{
	level.scr_sound["weaver"]["visual_rusalka"] = "vox_und1_s01_001A_weav_f"; //Alpha - we have visual on the Rusalka.
	level.scr_sound["hudson"]["roger_yanker_one"] = "vox_und1_s01_002A_huds"; //Roger that, Yankee One.
	level.scr_sound["weaver"]["approach"] = "vox_und1_s01_003A_weav_f"; //Beginning approach.
	level.scr_sound["hudson"]["your_stick"] = "vox_und1_s01_004A_huds"; //Mason - your stick.
	level.scr_sound["weaver"]["maintain_formation"] = "vox_und1_s01_005A_weav_f"; //Maintain formation. We're approaching the numbers station.
	level.scr_sound["weaver"]["aa_fire_deck"] = "vox_und1_s01_006A_weav_f"; //SHIT! Taking triple A fire from the deck!...
	level.scr_sound["weaver"]["shit_aa_fire"] = "vox_und1_s01_006A_weav_s_f"; //Taking triple A fire from the deck!...
	level.scr_sound["hudson"]["expecting"] = "vox_und1_s01_007A_huds"; //I think they were expecting us!
	level.scr_sound["hudson"]["engage_right"] = "vox_und1_s01_008A_huds"; //Yankee team - Engage echelon right!
	level.scr_sound["weaver"]["breaking_off"] = "vox_und1_s01_009A_weav_f"; //Roger that, Alpha. Breaking off.
	level.scr_sound["hudson"]["us_around"] = "vox_und1_s01_010A_huds"; //Mason, bring us around to port!
	level.scr_sound["hudson"]["secure_lz"] = "vox_und1_s01_011A_huds"; //We need to secure the LZ!
	level.scr_sound["mason"]["on_it"] = "vox_und1_s01_012A_maso"; //On it.
	level.scr_sound["pilot"]["beginning_run"] = "vox_und1_s01_013A_usp1_f"; //One five, beginning our run.
	level.scr_sound["pilot"]["engaging_1"] = "vox_und1_s01_014A_usp1_f"; //Engaging.
	level.scr_sound["pilot"]["hit_1"] = "vox_und1_s01_015A_usp1_f"; //That's a hit.
	level.scr_sound["pilot"]["fire_from_bridge"] = "vox_und1_s01_016A_usp1_f"; //Taking fire from the bridge!
	level.scr_sound["pilot"]["pull_out"] = "vox_und1_s01_017A_usp2_f"; //Pull out of there!
	level.scr_sound["pilot"]["moving_support"] = "vox_und1_s01_018A_usp2_f"; //One niner. Moving to support.
	level.scr_sound["pilot"]["engaging_2"] = "vox_und1_s01_019A_usp2_f"; //Engaging.
	level.scr_sound["pilot"]["hit_2"] = "vox_und1_s01_020A_usp2_f"; //Target hit.
	level.scr_sound["pilot"]["infantry"] = "vox_und1_s01_021A_usp2_f"; //Infantry on deck.
	level.scr_sound["pilot"]["see_them"] = "vox_und1_s01_022A_usp1_f"; //I see them.  Moving to engage.
	level.scr_sound["pilot"]["roger_that"] = "vox_und1_s01_023A_usp2_f"; //Roger that, one five.
	level.scr_sound["pilot"]["rpgs_bridge"] = "vox_und1_s01_024A_usp2_f"; //RPGs on the bridge.
	level.scr_sound["pilot"]["destroyed"] = "vox_und1_s01_025A_usp1_f"; //Target's destroyed.
	level.scr_sound["pilot"]["good_work"] = "vox_und1_s01_026A_usp2_f"; //Good work.
	level.scr_sound["pilot"]["another_pass"] = "vox_und1_s01_027A_usp2_f"; //Making another pass.
	level.scr_sound["weaver"]["yankee_in_position"] = "vox_und1_s01_028A_weav_f"; //Yankee One in position.
	level.scr_sound["weaver"]["go_go_go"] = "vox_und1_s01_029A_weav_f"; //Go go go!
	level.scr_sound["hudson"]["rpgs_upper_deck"] = "vox_und1_s01_030A_huds"; //RPGs! Upper deck!
	level.scr_sound["pilot"]["shit_going_down"] = "vox_und1_s01_031A_usp2_f"; //Shit!!! We're going down!
	level.scr_sound["pilot"]["going_down"] = "vox_und1_s01_031A_usp2_s_f"; //We're going down!
	level.scr_sound["hudson"]["weaver?"] = "vox_und1_s01_032A_huds"; //Weaver?!
	level.scr_sound["weaver"]["yankee_team_position"] = "vox_und1_s01_033A_weav_f"; //Yankee team in position.
	level.scr_sound["pilot"]["go_go"] = "vox_und1_s01_034A_usp1_f"; //Go! Go!
	level.scr_sound["hudson"]["provide_support"] = "vox_und1_s01_035A_huds"; //Alpha, moving to provide support, over.
	//level.scr_sound["weaver"]["anime"] = "vox_und1_s01_036A_weav_f"; //Yankee two - Starboard side. Move up!
	level.scr_sound["pilot"]["roger_moving"] = "vox_und1_s01_037A_broo_f"; //Roger that, moving in.
	level.scr_sound["weaver"]["yankee_on_me"] = "vox_und1_s01_038A_weav_f"; //Yankee one - on me.
	level.scr_sound["weaver"]["go"] = "vox_und1_s01_039A_weav_f"; //Go.
	level.scr_sound["hudson"]["take_us_port"] = "vox_und1_s01_040A_huds"; //Take us around the port side.
	level.scr_sound["hudson"]["get_to_port"] = "vox_und1_s01_041A_huds"; //Get to the Port side.
	//level.scr_sound["hudson"]["anime"] = "vox_und1_s01_042A_huds"; //Take us around the starboard side.
	//level.scr_sound["hudson"]["anime"] = "vox_und1_s01_043A_huds"; //Get to the starboard side.
	level.scr_sound["hudson"]["get_closer_1"] = "vox_und1_s01_044A_huds"; //We need to get closer.
	level.scr_sound["hudson"]["get_closer_2"] = "vox_und1_s01_045A_huds"; //Get us closer!
	level.scr_sound["hudson"]["pull_back"] = "vox_und1_s01_046A_huds"; //Pull back!
	level.scr_sound["hudson"]["too_close"] = "vox_und1_s01_047A_huds"; //We're too close - Get us clear!
	//level.scr_sound["hudson"]["shit_were_hit"] = "vox_und1_s01_048A_huds"; //Shit! We're hit!
	//level.scr_sound["hudson"]["were_hit"] = "vox_und1_s01_048A_huds_s"; //We're hit!
	level.scr_sound["hudson"]["taking_fire"] = "vox_und1_s01_049A_huds"; //Taking fire!
	level.scr_sound["hudson"]["evasive_action"] = "vox_und1_s01_050A_huds"; //Evasive action!
	level.scr_sound["hudson"]["get_out"] = "vox_und1_s01_051A_huds"; //Get us out of here, Mason!
	level.scr_sound["hudson"]["pull_up"] = "vox_und1_s01_052A_huds"; //Too much heat! Pull up!
	level.scr_sound["hudson"]["nice"] = "vox_und1_s01_053A_huds"; //Nice.
	level.scr_sound["hudson"]["good_shooting"] = "vox_und1_s01_054A_huds"; //Good shooting, Mason.
	level.scr_sound["hudson"]["got_em"] = "vox_und1_s01_055A_huds"; //You got 'em.
	level.scr_sound["hudson"]["keep_it_up"] = "vox_und1_s01_056A_huds"; //Keep it up.
	level.scr_sound["hudson"]["taken_out"] = "vox_und1_s01_057A_huds"; //Taken out.
	level.scr_sound["mason"]["moving_port"] = "vox_und1_s01_058A_maso"; //Moving to port.
	//level.scr_sound["mason"]["anime"] = "vox_und1_s01_059A_maso"; //Moving to Starboard.
	//level.scr_sound["mason"]["anime"] = "vox_und1_s01_060A_maso"; //Bring us around.
	level.scr_sound["mason"]["closer"] = "vox_und1_s01_061A_maso"; //Taking us closer.
	level.scr_sound["mason"]["roger_that"] = "vox_und1_s01_062A_maso"; //Roger that.
	level.scr_sound["weaver"]["engaging"] = "vox_und1_s01_063A_weav_f"; //Engaging.
	level.scr_sound["weaver"]["hit_them"] = "vox_und1_s01_064A_weav_f"; //Hit them now!
	level.scr_sound["weaver"]["weapons_free"] = "vox_und1_s01_065A_weav_f"; //Weapons free.
	level.scr_sound["weaver"]["pinned_down"] = "vox_und1_s01_066A_weav_f"; //Yankee squad pinned down!
	level.scr_sound["weaver"]["taking_fire"] = "vox_und1_s01_067A_weav_f"; //Taking heavy fire!
	level.scr_sound["weaver"]["fire_support"] = "vox_und1_s01_068A_weav_f"; //Where's that fire support?!
	level.scr_sound["weaver"]["thanks"] = "vox_und1_s01_069A_weav_f"; //Thanks for the help, Alpha.
	level.scr_sound["weaver"]["clear_to_move"] = "vox_und1_s01_070A_weav_f"; //Yankee one, clear to move up.
	level.scr_sound["weaver"]["moving_up"] = "vox_und1_s01_071A_weav_f"; //All clear.  Moving up.
	//level.scr_sound["Brooks"]["anime"] = "vox_und1_s01_072A_broo_f"; //Engaging.
	//level.scr_sound["Brooks"]["anime"] = "vox_und1_s01_073A_broo_f"; //Open fire.
	//level.scr_sound["Brooks"]["anime"] = "vox_und1_s01_074A_broo_f"; //Engaging targets.
	//level.scr_sound["Brooks"]["anime"] = "vox_und1_s01_075A_broo_f"; //Yankee two are pinned down!
	//level.scr_sound["Brooks"]["anime"] = "vox_und1_s01_076A_broo_f"; //Yankee two under fire! I Say again - Yankee two under fire.
	//level.scr_sound["Brooks"]["anime"] = "vox_und1_s01_077A_broo_f"; //We need fire support!
	//level.scr_sound["Brooks"]["anime"] = "vox_und1_s01_078A_broo_f"; //Good job, Alpha.
	//level.scr_sound["Brooks"]["anime"] = "vox_und1_s01_079A_broo_f"; //Yankee two, move up.
	//level.scr_sound["Brooks"]["anime"] = "vox_und1_s01_080A_broo_f"; //Clear.  Moving up.
	level.scr_sound["hudson"]["roger_that"] = "vox_und1_s01_081A_huds_f"; //Roger that, Yankee.
	level.scr_sound["hudson"]["rpgs_bridge"] = "vox_und1_s01_082A_huds_f"; //RPGS on the Bridge!
	level.scr_sound["hudson"]["take_them"] = "vox_und1_s01_083A_huds_f"; //Take them out!
	level.scr_sound["hudson"]["stay_on_them"] = "vox_und1_s01_084A_huds_f"; //Stay on them!
	level.scr_sound["weaver"]["yankee_in_position"] = "vox_und1_s01_085A_weav_f"; //Yankee team in position.
	level.scr_sound["weaver"]["lower_decks"] = "vox_und1_s01_086A_weav_f"; //Moving to lower decks, over.
	level.scr_sound["hudson"]["behind_you"] = "vox_und1_s01_087A_huds"; //Roger that, Yankee.  Alpha team is right behind you.
	level.scr_sound["hudson"]["take_us_down"] = "vox_und1_s01_088A_huds"; //Mason - Take us down.
	level.scr_sound["mason"]["roger_that_2"] = "vox_und1_s01_089A_maso"; //Roger that.
	level.scr_sound["hudson"]["jump"] = "vox_und1_s01_090A_huds"; //Jump!
	level.scr_sound["hudson"]["sit_rep"] = "vox_und1_s01_091A_huds"; //Yankee team - sitrep?
	level.scr_sound["mason"]["deck_two"] = "vox_und1_s01_092A_weav_f"; //Moving through deck two... No sign of the transmitter.
	level.scr_sound["hudson"]["has_to_be"] = "vox_und1_s01_093A_huds"; //It has to be here.
	level.scr_sound["mason"]["keep_looking"] = "vox_und1_s01_094A_maso"; //I know it is.  Keep looking.
	//level.scr_sound["hudson"]["anime"] = "vox_und1_s01_095A_huds_f"; //Split up - cover both sides of the ship.
	level.scr_sound["hudson"]["go"] = "vox_und1_s01_096A_huds_f"; //Go!
	level.scr_sound["hudson"]["shit_hips"] = "vox_und1_s01_097A_huds_f"; //Shit!  Enemy HIPS!
	level.scr_sound["hudson"]["hips"] = "vox_und1_s01_097A_huds_s_f"; //Enemy HIPS!
	level.scr_sound["hudson"]["guided_missile"] = "vox_und1_s01_098A_huds_f"; //Mason!  Grab that guided missile!
	level.scr_sound["hudson"]["take_down_hips"] = "vox_und1_s01_099A_huds_f"; //Take down those HIPS!
	level.scr_sound["mason"]["need_to_see"] = "vox_und1_s01_100A_weav_f"; //Hudson - you need to see this!
	level.scr_sound["hudson"]["what_is_it"] = "vox_und1_s01_101A_huds"; //What is it?
	level.scr_sound["mason"]["shit"] = "vox_und1_s01_102A_weav_f"; //SHIT!!!
	level.scr_sound["mason"]["damn"] = "vox_und1_s01_102A_weav_s_f"; //DAMN!!!
	level.scr_sound["hudson"]["weaver!"] = "vox_und1_s01_103A_huds"; //WEAVER?!!
	level.scr_sound["mason"]["asap"] = "vox_und1_s01_104A_weav_f"; //We're pinned down in the lower deck!  Get your asses down here ASAP.
	level.scr_sound["hudson"]["on_our_way"] = "vox_und1_s01_105A_huds"; //We're on our way!
//     level.scr_sound["weaver"]["anime"] = "vox_und1_s02_106A_weav_m"; //There's more to this ship than we thought...
	level.scr_sound["mason"]["broadcast_station"]	= "vox_und1_s02_107A_maso_m"; //The broadcast station. It's beneath us.
// 	level.scr_sound["weaver"]["anime"] = "vox_und1_s02_108A_weav_m"; //Shit!!!
// 	level.scr_sound["weaver"]["anime"] = "vox_und1_s02_108A_weav_s_m"; //Damn!!!
// 	level.scr_sound["hudson"]["anime"] = "vox_und1_s02_109A_huds_m"; //Shit... Dragovich is starting the broadcast!
// 	level.scr_sound["hudson"]["anime"] = "vox_und1_s02_109A_huds_s_m"; //Dragovich is starting the broadcast!
// 	level.scr_sound["hudson"]["anime"] = "vox_und1_s02_110A_huds_m"; //Command this is Alpha one.  We have confirmed the Rusalka is the broadcast source!
// 	level.scr_sound["hudson"]["anime"] = "vox_und1_s02_111A_huds_m"; //Bring in the airstrike.  We are on our way out!
 	level.scr_sound["mason"]["not_yet"]				= "vox_und1_s02_112A_maso_m"; //Not yet.  We need to find Dragovich.
// 	level.scr_sound["hudson"]["anime"] = "vox_und1_s02_113A_huds_m"; //In less than 15 minutes, the US Navy is going to blow this place apart!
 	level.scr_sound["mason"]["confirm_kill"]		= "vox_und1_s02_114A_maso_m"; //I made the mistake of not confirming the kill five years ago at Baikonur.
// 	level.scr_sound["hudson"]["anime"] = "vox_und1_s02_115A_huds_m"; //You sure you're not still brainwashed?
 	level.scr_sound["mason"]["would_it_matter"]		= "vox_und1_s02_116A_maso_m"; //Would it matter?... The son of a bitch needs to go down - once and for all.
// 	level.scr_sound["mason"]["anime"] = "vox_und1_s02_116A_maso_s_m"; //Would it matter?... The bastard needs to go down - once and for all.
// 	level.scr_sound["hudson"]["anime"] = "vox_und1_s02_117A_huds_m"; //Get out of here, Weaver... We're going to finish this.
	level.scr_sound["mason"]["see_buoys"]			= "vox_und1_s03_118A_maso"; //Hudson... See the buoys?
	level.scr_sound["hudson"]["transmit_surface"]	= "vox_und1_s03_119A_huds_f"; //They have to transmit from the surface... That's why we could never find the broadcast source.
	level.scr_sound["hudson"]["structure_below"]	= "vox_und1_s03_120A_huds_f"; //The structure below us... It's more than a transmitter.
	level.scr_sound["mason"]["supply_station"]		= "vox_und1_s03_121A_maso"; //It's a supply station for the Soviet submarine fleet...
	level.scr_sound["mason"]["dragovichs_plan"]		= "vox_und1_s03_122A_maso"; //Part of Dragovich's plan for invasion - once the Nova 6 was released.
	level.scr_sound["hudson"]["drop_weights"]		= "vox_und1_s03_123A_huds"; //Drop your weights.
	level.scr_sound["hudson"]["this_way"]			= "vox_und1_s03_124A_huds"; //This way.
	level.scr_sound["hudson"]["mason_over_here"]	= "vox_und1_s03_300A_huds"; //Mason, over here!   There's another pool.
	level.scr_sound["hudson"]["hurry_mason"]		= "vox_und1_s03_301A_huds"; //Hurry up, Mason!  The bombs could hit at any minute!
	level.scr_sound["hudson"]["come_on_mason_hurry"]= "vox_und1_s03_302A_huds"; //Come on, Mason!   We gotta hurry!
	level.scr_sound["hudson"]["begun_attack"]		= "vox_und1_s03_125A_huds"; //They've begun the attack!
	level.scr_sound["hudson"]["weaver_what"]		= "vox_und1_s03_126A_huds"; //Weaver!  What's happening?
	level.scr_sound["hudson"]["dammit"]				= "vox_und1_s03_127A_huds"; //Dammit!
	level.scr_sound["mason"]["too_late"]			= "vox_und1_s03_128A_maso"; //Too late to back out - Slam it in!
// 	level.scr_sound["hudson"]["dead_end"] = "vox_und1_s03_129A_huds"; //Dead end!
// 	level.scr_sound["hudson"]["anime"] = "vox_und1_s03_130A_huds"; //Way forward's flooded.  We're gonna have to swim for it.
	level.scr_sound["hudson"]["find_dragovich"]		= "vox_und1_s03_303A_huds"; //We need to find Dragovich before they bring the whole place down on top of us!
//     level.scr_sound["hudson"]["anime"] = "vox_und1_s03_131A_huds"; //Ready?
//     level.scr_sound["mason"]["anime"] = "vox_und1_s03_132A_maso"; //Ready.
	level.scr_sound["hudson"]["up_ladder"]			= "vox_und1_s04_133A_huds"; //Up the ladder.
    level.scr_sound["hudson"]["stop_transmission"]	= "vox_und1_s04_200A_huds"; //* We need to stop that transmission, now!
	level.scr_sound["hudson"]["dragovich"]			= "vox_und1_s04_134A_huds"; //DRAGOVICH!!!
	level.scr_sound["mason"]["dragovich"]			= "vox_und1_s99_160A_maso"; //Dragovich!
//    level.scr_sound["hudson"]["anime"] = "vox_und1_s04_135A_huds"; //Mason!  Take the shot!
//    level.scr_sound["dragovich"]["anime"]	= "vox_und1_s04_136A_drag"; //You... can not do anything right.
//    level.scr_sound["dragovich"]["anime"]			= "vox_und1_s04_137A_drag_m"; //You should have been my finest agent... It would all have been so much simpler.
	level.scr_sound["mason"]["it_is_simple"]		= "vox_und1_s04_138A_maso"; //It IS simple.
	level.scr_sound["mason"]["kill_you"]			= "vox_und1_s04_139A_maso"; //I am going to kill you!
	level.scr_sound["mason"]["fuck_mind"]			= "vox_und1_s04_140A_maso"; //You tried to fuck with my mind... You failed!
//	level.scr_sound["mason"]["screw_mind"]			= "vox_und1_s04_140A_maso_s"; //You tried to screw with my mind... You failed!
	level.scr_sound["dragovich"]["dont_know"]		= "vox_und1_s04_141A_drag"; //You don't know..
	level.scr_sound["mason"]["turn_me"]				= "vox_und1_s04_142A_maso"; //You tried to turn me against my own!
	level.scr_sound["dragovich"]["anything"]		= "vox_und1_s04_143A_drag"; //...Anything for sure.
	level.scr_sound["mason"]["kill_president"]		= "vox_und1_s04_144A_maso"; //You tried to make me kill my own president!
	level.scr_sound["dragovich"]["tried_believe"]	= "vox_und1_s04_145A_drag"; //Tried? What makes you believe you didn't?
	level.scr_sound["hudson"]["mason_this_way"]		= "vox_und1_s04_146A_huds"; //Mason!!! This way.
	level.scr_sound["hudson"]["go_go_go"]			= "vox_und1_s04_147A_huds"; //Go! Go! Go!
	level.scr_sound["hudson"]["come_on_mason"]		= "vox_und1_s04_148A_huds"; //Come on, Mason!
	level.scr_sound["weaver"]["anime"] = "vox_und1_s04_149A_weav_m"; //Mason.
	level.scr_sound["weaver"]["anime"] = "vox_und1_s04_150A_weav_m"; //It is over... We won.
	level.scr_sound["mason"]["anime"] = "vox_und1_s04_151A_maso_m"; //For now...
    level.scr_sound["hudson"]["anime"] = "vox_und1_s04_400A_huds"; //* I knew you wouldn't let us down, Mason.
    level.scr_sound["hudson"]["anime"] = "vox_und1_s04_401A_huds"; //* Even when the rest of the Company gave up on you...
    level.scr_sound["hudson"]["anime"] = "vox_und1_s04_402A_huds"; //* I knew we could trust you.
	level.scr_sound["spetsnaz"]["intruder_alert"]	= "vox_und1_s99_304A_spz2"; //(Translated) Intruder alert!  Intruder alert!
	level.scr_sound["spetsnaz"]["sub_position"]		= "vox_und1_s99_305A_spz3"; //(Translated) Get that sub into position, quickly!
	level.scr_sound["spetsnaz"]["check_seals"]		= "vox_und1_s99_306A_spz2"; //(Translated) Team 2, check the seals!
	level.scr_sound["spetsnaz"]["prep_fuel"]		= "vox_und1_s99_307A_spz3"; //(Translated) Prep the fuel!
	level.scr_sound["dragovich"]["tried_succeed"]	= "vox_und1_s05_200A_drag"; //Tried?  How do you know we didn't succeed?
	level.scr_sound["reznov"]["mason"] = "vox_und1_s05_201A_rezn"; //Mason!
	level.scr_sound["mason"]["reznov"] = "vox_und1_s05_202A_maso"; //Reznov?  But how --?
	level.scr_sound["reznov"]["you_did_it"] = "vox_und1_s05_203A_rezn"; //You did it, Mason.  You did what I could not.  Now live.  There is so much more work to be done.
	level.scr_sound["Spetsnaz Operative"]["anime"] = "vox_und1_s99_152A_spz1"; //(Translated) Intruders pinned down - sector 3, requesting reinforcements, over.
	level.scr_sound["hudson"]["stop_broadcast"]		= "vox_und1_s99_153A_huds"; //Keep moving! We need to stop the broadcast.
    level.scr_sound["hudson"]["stop_broadcast2"]	= "vox_und1_s99_153B_huds"; //We need to stop the broadcast.
	level.scr_sound["hudson"]["shit"]				= "vox_und1_s99_154A_huds"; //Shit!
//	level.scr_sound["hudson"]["crap"]				= "vox_und1_s99_154A_huds_s"; //Crap!
	level.scr_sound["hudson"]["come_on_mason2"]		= "vox_und1_s99_155A_huds"; //Come on Mason!
	level.scr_sound["hudson"]["keep_moving"]		= "vox_und1_s99_156A_huds"; //Keep moving!
	level.scr_sound["hudson"]["on_me"]				= "vox_und1_s99_157A_huds"; //On me!
	level.scr_sound["hudson"]["stop_transition"]	= "vox_und1_s99_158A_huds"; //Mason - Stop the transmission!
	level.scr_sound["hudson"]["falling_apart"]		= "vox_und1_s99_159A_huds"; //This place is falling apart!
	level.scr_sound["hudson"]["get_up_here"]		= "vox_und1_s99_161A_huds"; //Mason - get up here.
	level.scr_sound["hudson"]["out_of_time"]		= "vox_und1_s99_162A_huds"; //We're running out of time!
	level.scr_sound["hudson"]["need_to_move_mason"] = "vox_und1_s99_163A_huds"; //We need to move Mason.
	level.scr_sound["hudson"]["jump_go"]			= "vox_und1_s99_164A_huds"; //Jump - GO!
	level.scr_sound["mason"]["DRAGOVICH_SPOT"]		= "vox_und1_s99_165A_maso"; //DRAGOVICH!
	level.scr_sound["hudson"]["locked_on"] = "vox_und1_s99_166A_huds"; //They've got a lock on us!!!
	level.scr_sound["hudson"]["shit_were_hit"] = "vox_und1_s99_167A_huds"; //SHIT!!! WE'RE HIT!!!
	level.scr_sound["hudson"]["were_hit"] = "vox_und1_s99_167A_huds_s"; //WE'RE HIT!!!
	level.scr_sound["hudson"]["jump_go_go_go"] = "vox_und1_s99_168A_huds"; //Out of the chopper! Jump! GO GO GO!
    level.scr_sound["hudson"]["visual"] = "vox_und1_s99_169A_huds"; //* Yankee team, we have visual. Moving to engage.
    level.scr_sound["hudson"]["a_hind"] = "vox_und1_s99_170A_huds"; //* A Hind! Evasive maneuvers!
    level.scr_sound["hudson"]["take_down_hind"] = "vox_und1_s99_171A_huds"; //* Take down that Hind!
    level.scr_sound["hudson"]["fire_on_hind"] = "vox_und1_s99_172A_huds"; //* Yankee two - Fire on the Hind!
    level.scr_sound["hudson"]["keep_on_em"] = "vox_und1_s99_173A_huds"; //* Keep on 'em!
    level.scr_sound["hudson"]["helipad"] = "vox_und1_s99_174A_huds"; //* We can?t take much more  - Mason get us to Helipad!
}

//
//	Play a Mason line on the player
player_vo( line_alias )
{
	player = get_players()[0];
	player anim_single( player, line_alias );
}


#using_animtree ("generic_human");
//
//	AI ANIMATIONS
//
ai_anims()
{
	// huey pilot idle
	level.scr_anim["pilot"]["idle"][0] = %ai_huey_pilot1_idle_loop1;
	level.scr_anim["copilot"]["idle"][0] = %ai_huey_pilot2_idle_loop1;

	level.scr_anim["hudson"]["pilot_idle"][0] = %ch_under_b01_Huey_Hudson_loop;
	//level.scr_anim["hudson"]["pilot_idle_2"][0] = %ch_under_b01_Huey_Hudson_loop_02;
    
//    level.scr_anim["diver"]["diver_death"][0] = %ai_flame_death_h;  	// temp for divers
 	       
// HUDSON
	level.scr_anim["hudson"]["heli_crash"]		= %ch_under_b01_playerheli_crash_hudson;
	level.scr_anim["hudson"]["station_below"]	= %ch_under_b04_numbers_station_below_hudson;
	addNotetrack_customFunction("hudson", "play_anim_redshirt04", ::rendezvous_ally4_start, "station_below");
	addNotetrack_customFunction("hudson", "play_anim_redshirt03", ::rendezvous_ally3_start, "station_below");
	addNotetrack_customFunction("hudson", "play_anim_redshirt02", ::rendezvous_ally2_start, "station_below");
	addNotetrack_customFunction("hudson", "play_anim_redshirt01", ::rendezvous_ally1_start, "station_below");
	addNotetrack_customFunction("hudson", "trigger_noise_for_react", ::rendezvous_stop_machines, "station_below");
	addNotetrack_customFunction("hudson", "mason_vo_vox_und1_s02_107A_maso_m", ::rendezvous_mason_107a, "station_below");
	addNotetrack_customFunction("hudson", "mason_vo_vox_und1_s02_112A_maso_m", ::rendezvous_mason_112a, "station_below");
	addNotetrack_customFunction("hudson", "mason_vo_vox_und1_s02_114A_maso_m", ::rendezvous_mason_114a, "station_below");
	addNotetrack_customFunction("hudson", "mason_vo_vox_und1_s02_116A_maso_m", ::rendezvous_mason_116a, "station_below");
	level.scr_anim["hudson"]["dive"]			= %ch_uwb_b04_hudson_dive;
	addNotetrack_customFunction("hudson", "hudson_land", ::play_land_fx, "dive");
	level.scr_anim["hudson"]["enter_subpen"]	= %ch_under_b05_moon_pool_door_entry;
	addNotetrack_customFunction("hudson", "Door_at_ninety", ::enter_subpen_door_open, "enter_subpen");
	level.scr_anim["hudson"]["flood_swim"]		= %ch_uwb_b06_hudson_swim;
	level.scr_anim["hudson"]["knocked_out"]		= %ai_pow_meatshield_hostage_dead_drop;
	level.scr_anim["hudson"]["fight_intro"]		= %ch_uwb_b08_drago_fight_hudson;		// Hudson comes to players aid and shoots drago
	level.scr_anim["hudson"]["escape"]			= %ch_under_b08_hudson_stumbling;		// Hudson runs out of the base
								// NOTE: XANIM_EXPORT is ch_under_b09_hudson_stumbling
	level.scr_anim["hudson"]["ascend"][0]		= %ch_uwb_b09_hudson_surfaces_swimCycle;
	level.scr_anim["hudson"]["finale"]			= %ch_uwb_b09_hero_boat_hudson;

//	WEAVER
	level.scr_anim["weaver"]["station_below"]	= %ch_under_b04_numbers_station_below_weaver;
	level.scr_anim["weaver"]["finale"]			= %ch_uwb_b09_hero_boat_weaver;

    
// DRAGOVICH
	level.scr_anim["dragovich"]["finest_agent"]		= %ch_uwb_b08_finest_agent_drago;						// Dragovich?s intro animation; pairs with players animation
	level.scr_anim["dragovich"]["fight_intro"]		= %ch_uwb_b08_drago_fight_dragovich_enter;				// start of the fight sequence for drago
	addNotetrack_customFunction("dragovich", "drago_shot",			::end_fight_drago_shot,			"fight_intro");
	addNotetrack_customFunction("dragovich", "fire",				::end_fight_drago_fire,			"fight_intro");

	level.scr_anim["dragovich"]["grab_pause"][0]	= %ch_uwb_b08_drago_fight_dragovich_grab_pause;			// loop for drago for grab prompt
	level.scr_anim["dragovich"]["kill_player"]		= %ch_uwb_b08_drago_fight_dragovich_kill_player;		// drago turns and kills player if he doesn?t hit prompt in time
	//		kill_shot - notetrack for when drago kills player

	level.scr_anim["dragovich"]["grab_dragovich" ]	= %ch_uwb_b08_drago_fight_dragovich_fall;				//	success animation for dragovich when player grabs. 
	addNotetrack_customFunction("dragovich", "bubble_fx",		::drago_bubbles,		"grab_dragovich");
	addNotetrack_customFunction("dragovich", "body_splash",		::drago_landing,		"grab_dragovich");
	addNotetrack_customFunction("dragovich", "head_splash",		::drago_head_splash,	"grab_dragovich");
	addNotetrack_customFunction("dragovich", "spit_fx",			::drago_spit,			"grab_dragovich");

	level.scr_anim["dragovich"]["choke_loop" ][0]	= %ch_uwb_b08_drago_fight_dragovich_choke_pause;	// drago loop, waiting for player to choke him
	addNotetrack_customFunction("dragovich", "bubble_fx",		::drago_bubbles,		"choke_loop");

	level.scr_anim["dragovich"]["kill_dragovich" ]	= %ch_uwb_b08_drago_fight_dragovich_death;				// Drago dead.
	addNotetrack_customFunction("dragovich", "bubble_fx",		::drago_bubbles,		"kill_dragovich");
	addNotetrack_customFunction("dragovich", "drago_dead",	::end_fight_drago_dead, "kill_dragovich");	// kicks him into ragdoll when player isn?t looking.

// OTHERS
	// Umbilical room - NOTE: anim indices are switched with the ally numbers.
	level.scr_anim["ally0"]["station_below"]	= %ch_under_b04_numbers_station_below_redshirt_02;
	level.scr_anim["ally1"]["station_below"]	= %ch_under_b04_numbers_station_below_redshirt_01;
	level.scr_anim["ally2"]["station_below"]	= %ch_under_b04_numbers_station_below_redshirt_04;
	level.scr_anim["ally3"]["station_below"]	= %ch_under_b04_numbers_station_below_redshirt_03;

	// Dive
	level.scr_anim["ally0"]["dive"]					= %ch_uwb_b04_solder1_dive;
	addNotetrack_customFunction("ally0", "soldier1_land", ::play_land_fx, "dive");
	level.scr_anim["ally0"]["tread_loop"]			= %ch_uwb_b04_solder1_treadloop;

	level.scr_anim["ally1"]["dive"]					= %ch_uwb_b04_solder2_dive;
	addNotetrack_customFunction("ally1", "soldier2_land", ::play_land_fx, "dive");
	level.scr_anim["ally1"]["tread_loop"]			= %ch_uwb_b04_solder2_treadloop;

	level.scr_anim["ally2"]["dive"]					= %ch_uwb_b04_solder3_dive;
	addNotetrack_customFunction("ally2", "soldier3_land", ::play_land_fx, "dive");
	level.scr_anim["ally2"]["tread_loop"]			= %ch_uwb_b04_solder3_treadloop;

	// Enter base
	level.scr_anim["ally0"]["moon_pool_entry"]		= %ch_under_b05_moon_pool_door_entry_soldier;

	// Control panel anims - 
	//	NOTE the numbers don't match up.
	level.scr_anim["engineer1"]["console_loop"]		= %ch_under_b07_frantic_engineer_03;
	level.scr_anim["engineer2"]["console_loop"]		= %ch_under_b07_frantic_engineer_02;
	level.scr_anim["engineer3"]["console_loop"]		= %ch_under_b07_frantic_engineer_01;

	// Finale
	level.scr_anim["diver"]["dive_entrance1"] = %ch_uwb_b09_diver_entries_diver1;
	level.scr_anim["diver"]["dive_entrance2"] = %ch_uwb_b09_diver_entries_diver2;
	level.scr_anim["diver"]["dive_entrance3"] = %ch_uwb_b09_diver_entries_diver3;
	level.scr_anim["diver"]["dive_entrance4"] = %ch_uwb_b09_diver_entries_diver4;
	level.scr_anim["diver"]["dive_entrance5"] = %ch_uwb_b09_diver_entries_diver5;
	level.scr_anim["diver"]["dive_entrance6"] = %ch_uwb_b09_diver_entries_diver6;

	level.scr_anim["hero_redshirt1"]["finale"] = %ch_uwb_b09_hero_boat_redshirt1;
	level.scr_anim["hero_redshirt2"]["finale"] = %ch_uwb_b09_hero_boat_redshirt2;

	level.scr_anim["generic"]["gather_rope"][0] = %ch_uwb_b09_boat_activity_gatherRope_loop;

	level.scr_anim["boat_guy1"]["boat_activity1"][0] = %ch_uwb_b09_boat_activity_guy1_loop1;
	level.scr_anim["boat_guy1"]["boat_activity2"][0] = %ch_uwb_b09_boat_activity_guy1_loop2;
	level.scr_anim["boat_guy1"]["boat_activity3"][0] = %ch_uwb_b09_boat_activity_guy1_loop3;
	level.scr_anim["boat_guy1"]["boat_activity4"][0] = %ch_uwb_b09_boat_activity_guy1_loop4;
	level.scr_anim["boat_guy2"]["boat_activity1"][0] = %ch_uwb_b09_boat_activity_guy2_loop1;
	level.scr_anim["boat_guy2"]["boat_activity2"][0] = %ch_uwb_b09_boat_activity_guy2_loop2;
	level.scr_anim["boat_guy2"]["boat_activity3"][0] = %ch_uwb_b09_boat_activity_guy2_loop3;

	level.scr_anim["generic"]["megaphone1"][0] = %ch_uwb_b09_boat_activity_megaphone_loop1;
	level.scr_anim["generic"]["megaphone2"][0] = %ch_uwb_b09_boat_activity_megaphone_loop2;
	level.scr_anim["generic"]["megaphone3"][0] = %ch_uwb_b09_boat_activity_megaphone_loop3;
	level.scr_anim["generic"]["swab_deck"][0] = %ch_uwb_b09_boat_activity_swabDeck_loop;

	level.scr_anim["boat_guy1"]["point_loop"][0] = %ch_uwb_b09_pointing_guns_redshirt1_loop;
	level.scr_anim["boat_guy2"]["point_loop"][0] = %ch_uwb_b09_pointing_guns_redshirt2_loop;
	level.scr_anim["boat_guy3"]["point_loop"][0] = %ch_uwb_b09_pointing_guns_redshirt3_loop;

	// Tow missile guy
	level.scr_anim["generic"]["tow_fire"] = %ch_under_b02_portable_tow_soldier;

	// huey riders...
	level.scr_anim["generic"]["tag_passenger2"][0] = %ai_huey_passenger_f_lt;
	level.scr_anim["generic"]["tag_passenger3"][0] = %ai_huey_passenger_f_rt;
	level.scr_anim["generic"]["tag_passenger4"][0] = %ai_huey_passenger_b_lt;
	level.scr_anim["generic"]["tag_passenger5"][0] = %ai_huey_passenger_b_rt;
}



//
//	All Player animations
#using_animtree ("player");
player_anims()
{
	level.scr_animtree["player_body"] = #animtree;
	level.scr_model["player_body"] = "viewmodel_usa_ubase_fullbody";

	// Dive to Base
	level.scr_anim["player_body"]["dive"]					= %ch_uwb_b04_player_dive;
	addNotetrack_customFunction("player_body", "player_land", ::play_land_fx, "dive");

	// E6 Big flood
	level.scr_anim["player_body"]["water_knock_out"]		= %int_uwb_b06_player_knock_out;	// player knocked out by the flood blast
//	addNotetrack_customFunction("player_body", "water_impact",	::, "water_knock_out");
	addNotetrack_customFunction("player_body", "wall_impact",	maps\underwaterbase_bigflood::start_flood, "water_knock_out");		// Water starts rising
// 	addNotetrack_customFunction("player_body", "fade_start",	::, "water_knock_out");
// 	addNotetrack_customFunction("player_body", "ground_impact", ::, "water_knock_out");
// 	addNotetrack_customFunction("player_body", "fade_end",		::, "water_knock_out");
    addNotetrack_customFunction("player_body", "water_impact", ::audio_water_impact, "water_knock_out");
    addNotetrack_customFunction("player_body", "wall_impact", ::audio_wall_impact, "water_knock_out");

	// E9 Dragovich Fight
	level.scr_anim["player_body"]["console_explosion"]	= %int_uwb_b08_react_explosion;	// player looks down at the console, but as he?s about to interact? explosion knocks him back and he ends up hanging off the edge.
	addNotetrack_customFunction("player_body", "missle_impact", ::console_explosion, "console_explosion");
	level.scr_anim["player_body"]["finest_agent"]		= %int_uwb_b08_finest_agent_player;	// players animation; just him idling and looking at dragovich as he?s walking over giving his speech
	level.scr_anim["player_body"]["fight_intro"]		= %int_uwb_b08_drago_fight_player_enter; //start of the fight sequence
	level.scr_anim["player_body"]["grab_pause"]			= %int_uwb_b08_drago_fight_player_grab_pause;	// loop for player prompt to grab drago
	level.scr_anim["player_body"]["kill_player"]		= %int_uwb_b08_drago_fight_player_fail_grab;	// fail animation for when the player doesn?t hit prompt in time
	addNotetrack_customFunction("player_body", "player_death", ::end_fight_lose, "kill_player");
	level.scr_anim["player_body"]["grab_dragovich"]		= %int_uwb_b08_drago_fight_player_fall;			// success animation: player grabs drago and they fall together. Player lands on him and slams him around.. punches him, etc then waits for prompt
	level.scr_anim["player_body"]["choke_loop"][0]			= %int_uwb_b08_drago_fight_player_choke_pause;	// player loop, waiting for player to hit the shoulder buttons to kill drago
	level.scr_anim["player_body"]["kill_dragovich"]		= %int_uwb_b08_drago_fight_player_kill_drago;	// final kill animation: drowns drago then gets up and gives control back to player
	//		enable_player - notetrack for going back to player control


	// Finale
	level.scr_anim["player_body"]["finale"] = %int_uwb_b09_hero_boat_player;
	level.scr_anim["player_body"]["ascend"][0] = %int_uwb_b09_player_ascends_swimCycle;

	init_helicopter_player_anims();
}

init_helicopter_player_anims()
{
	//-- player flightstick animations	
	level.scr_anim["player_body"]["flightstick_left"]	= %int_pow_b03_cockpit_hand_left;
	level.scr_anim["player_body"]["flightstick_right"] = %int_pow_b03_cockpit_hand_right;
	level.scr_anim["player_body"]["flightstick_away"] = 	%int_pow_b03_cockpit_hand_down;
	level.scr_anim["player_body"]["flightstick_towards"] = %int_pow_b03_cockpit_hand_up;
	level.scr_anim["player_body"]["flightstick_neutral"] = %int_pow_b03_cockpit_hand_neutral;
	level.scr_anim["player_body"]["flightstick_handsoff"] = %int_pow_b03_cockpit_handsoff;
//	level.scr_anim["player_hands"]["takeoff"] = %int_pow_b03_cockpit_takeoff;
//	level.scr_anim["player_hands"]["playable_hind_climbout"] = %int_pow_b03_cockpit_exit;
	
	level.scr_anim["player_body"]["crash"] = %int_pow_b03_cockpit_crash;
	level.scr_anim["player_body"]["crash_loop"][0] = %int_pow_b03_cockpit_crash;

	level.scr_anim["player_body"]["heli_crash"] = %int_under_b01_playerheli_crash;
}

#using_animtree("vehicles");
//	All Vehicle anims
vehicle_anims()
{
	level.scr_animtree["helicopter"] = #animtree;
	level.scr_anim["helicopter"][ "hip_left" ] = %v_pow_b03_hip_crash_left;
	level.scr_anim["helicopter"][ "hip_right" ] = %v_pow_b03_hip_crash_right;
	level.scr_anim["helicopter"][ "hind_left1" ] = %v_pow_b03_hind_crash_left1;
	level.scr_anim["helicopter"][ "hind_left2" ] = %v_pow_b03_hind_crash_left2;
	level.scr_anim["helicopter"][ "hind_right1" ] = %v_pow_b03_hind_crash_right1;
	level.scr_anim["helicopter"][ "hind_right2" ] = %v_pow_b03_hind_crash_right2;

	level.scr_anim["helicopter"]["heli_crash"] = %v_under_b01_playerheli_crash_huey;
	level.scr_anim["helicopter"]["heli_crash_1"] = %v_uwb_b01_weavers_heli_crash;

	level.scr_anim["helicopter"]["heli_crash_missile_01"] = %v_uwb_b01_huey_01_hit_by_missle;
	level.scr_anim["helicopter"]["heli_crash_missile_02"] = %v_uwb_b01_huey_02_hit_by_missle;
	level.scr_anim["helicopter"]["heli_crash_missile_03"] = %v_under_b02_huey_hit_by_hind;

	level.scr_anim["helicopter"]["heli_crash_spin_left"] = %v_uwb_b01_huey_crash_spin_left_loop;
	level.scr_anim["helicopter"]["heli_crash_spin_right"] = %v_uwb_b01_huey_crash_spin_right_loop;

	level.scr_model["phantom"] = "t5_veh_jet_f4_gearup";
	level.scr_animtree["phantom"] = #animtree;
	level.scr_anim["phantom_1"][ "flyby" ] = %v_under_b09_F4_flyby_jet01;
	level.scr_anim["phantom_2"][ "flyby" ] = %v_under_b09_F4_flyby_jet02;
	level.scr_anim["phantom_3"][ "flyby" ] = %v_under_b09_F4_flyby_jet03;
	level.scr_anim["phantom_4"][ "flyby" ] = %v_under_b09_F4_flyby_jet04;
	level.scr_anim["phantom_5"][ "flyby" ] = %v_under_b09_F4_flyby_jet05;
	level.scr_anim["phantom_6"][ "flyby" ] = %v_under_b09_F4_flyby_jet06;

	level.scr_animtree["boat"] = #animtree;
	level.scr_anim["boat"]["idle"][0] = %v_under_b09_p_am_rescue_boat_loop;

	level.scr_model["heli_rotor"] = "t5_veh_helo_huey_damaged_rotor_tip";
	level.scr_animtree["heli_rotor"] = #animtree;
	level.scr_anim["heli_rotor"]["crash"] = %v_under_b01_playerheli_crash_huey_rotor_blade;

	level.scr_model["heli_hub"] = "t5_veh_helo_huey_damaged_rotor";
	level.scr_animtree["heli_hub"] = #animtree;
	level.scr_anim["heli_hub"]["crash"] = %v_under_b01_playerheli_crash_huey_rotor_hub;

	level.scr_model["heli_door"] = "t5_veh_helo_huey_damaged_door_front";
	level.scr_animtree["heli_door"] = #animtree;
	level.scr_anim["heli_door"]["crash"] = %v_under_b01_playerheli_crash_huey_door;
}


//
//	PROP ANIMS
//
#using_animtree ("animated_props");
object_anims()
{
	level.scr_anim["door"]["enter_subpen"]	= %o_under_b05_moon_pool_door_entry_airlock_door;
}

//
//	Hudson opens the door to the sub pen area
enter_subpen_door()
{
	door = GetEnt( "moonpool_transition_door", "targetname" );
	door.animname = "door";
	door useanimtree(#animtree);

	self anim_first_frame( door, "enter_subpen" );	// move it into the exact anim position
	flag_wait("moonpool_open_door");

	door_clip = GetEnt( "clip_moonpool_transition_door", "targetname" );
	door_clip LinkTo( door, "tag_origin_animate" );

	self thread anim_single_aligned(door, "enter_subpen");
}

//
//	SCENES / CHARACTER ANIMS
//
#using_animtree("generic_human");

//
//	Rendevous "Numbers Station" scene
rendezvous()
{
	flag_set( "numbers_scene_prep" );

	//TUEY maybe add a music transition here...

	sync_node = GetStruct( "sync_big_igc", "targetname" );

	level.heroes[ "hudson" ] thread rendezvous_heroes( sync_node );
	level.heroes[ "weaver" ] thread rendezvous_heroes( sync_node );
	for (i=0; i<level.allies.size; i++)
	{
		if ( IsAlive(level.allies[i]) )
		{
			level.allies[i] thread rendezvous_ally( sync_node, (i+1) );
		}
	}
	level.heroes[ "hudson" ] ent_flag_wait( "numbers_scene_ready" );
	level.heroes[ "weaver" ] ent_flag_wait( "numbers_scene_ready" );
	trig = GetEnt( "trig_numbers_igc", "targetname" );
	trig waittill( "trigger" );

	trig Delete();
	flag_set( "numbers_scene_start" );

	//TUEy set music to BROADCAST
	setmusicstate ("BROADCAST");

	player = get_players()[0];
	player SetClientDvar( "cg_drawFriendlyNames", 0 );	// turn back on after dive is done
	player SetMoveSpeedScale( 0.35 );
	flag_wait( "numbers_scene_done" );

	player SetMoveSpeedScale( 1.0 );
}
//
//
rendezvous_heroes( sync_node )
{
	ent_flag_init( "numbers_scene_ready" );

	self disable_ai_color();
	if ( self == level.heroes[ "hudson" ] )
	{
		wait_node = GetNode( "n_numbers_wait_" + self.animname, "targetname" );
		self SetGoalNode( wait_node );
		self waittill( "goal" );
		wait(1.0);
	}
	else if ( self == level.heroes[ "weaver" ] )
	{
		flag_wait( "allies_out" );
		level.heroes[ "hudson" ] ent_flag_wait( "numbers_scene_ready" );

		sync_node anim_reach_aligned( self, "station_below" );
	}

	ent_flag_set( "numbers_scene_ready" );
	flag_wait( "numbers_scene_start" );

	anim_time = GetAnimLength(level.scr_anim[ "hudson" ]["station_below"]);
	sync_node thread anim_single_aligned( self, "station_below" );
	if ( self == level.heroes[ "hudson" ] )
	{
		wait( anim_time - 3.0 );

		flag_set( "numbers_scene_done" );
	}

	end_node = GetNode( "n_numbers_end_" + self.animname, "targetname" );
	if ( IsDefined( end_node ) )
	{
		self SetGoalNode( end_node );
	}
}


//
//
rendezvous_ally( sync_node, index )
{
	self disable_ai_color();
	ent_flag_init( "start_numbers_scene" );

	wait_node = undefined;

	switch( index )
	{
	case 1:	// behind Hudson close
	case 2:	// behind Hudson far
	case 3:	// behind weaver
 		wait_node = GetNode( "n_numbers_end_" + index, "targetname" );
		break;
	default:
		wait_node = GetNode( "n_numbers_wait_" + index, "targetname" );
	}
	if ( IsDefined( wait_node ) )
	{
		self SetGoalNode( wait_node );
		self waittill( "goal" );
	}
// 	end_node = GetNode( "n_numbers_end_" + index, "targetname" );
// 	if ( IsDefined( end_node ) )
// 	{
// 		self SetGoalNode( end_node );
// 	}
	flag_wait( "numbers_scene_start" );

//	sync_node anim_reach_aligned( self, "station_below" );

	ent_flag_wait( "start_numbers_scene" );
	sync_node anim_single( self, "station_below" );

	end_node = GetNode( "n_numbers_end_" + index, "targetname" );
	if ( IsDefined( end_node ) )
	{
		self SetGoalNode( end_node );
	}
}


//
//	Staggered anim starts  =p
//	NOTE: the function number corresponds to the animation number.
//		but you need to check the "station_below" anims to match the correct ally number
//	guy = hudson
rendezvous_ally1_start( guy )
{
	rendezvous_ally_start( 1 );
}
rendezvous_ally2_start( guy )
{
	rendezvous_ally_start( 0 );
}
rendezvous_ally3_start( guy )
{
	rendezvous_ally_start( 3 );
}
rendezvous_ally4_start( guy )
{
	rendezvous_ally_start( 2 );
}
rendezvous_ally_start( index )
{
	for ( i=0; i<level.allies.size; i++ )
	{
		if ( level.allies[i].animname == "ally"+index )
		{
			level.allies[i] ent_flag_set( "start_numbers_scene" );
		}
	}
}


//
//	Umbilical room machines stop with a loud screech.
rendezvous_stop_machines( guy )
{
	flag_set( "wires_slack_start" );
	//SOUND - Shawn J
	clientnotify( "spools_stopping" );	
	clientnotify( "broadcast" );
	wait( 0.05 );	// wait a frame to let endon threads die

	wires1 = GetEnt( "umbilical_room_wires_1", "targetname" );
	wires2 = GetEnt( "umbilical_room_wires_2", "targetname" );

	wires1 MoveZ( -5, 1.0 );
	wires2 MoveZ( -5, 1.0 );
}


//
//	Play player VO lines
rendezvous_mason_107a( guy )
{
	player_vo( "broadcast_station" );	//The broadcast station. It's beneath us.
}
rendezvous_mason_112a( guy )
{
	player_vo( "not_yet" );				//Not yet.  We need to find Dragovich.
}
rendezvous_mason_114a( guy )
{
	player_vo( "confirm_kill" );		//I made the mistake of not confirming the kill five years ago at Baikonur.
}
rendezvous_mason_116a( guy )
{
	player_vo( "would_it_matter" );		//Would it matter?... The son of a bitch needs to go down - once and for all.
}

//
// a single dive anim processor for a single character
dive_anim_ai( sync_node )
{
	self endon( "death" );
	self endon( "squad_enter_moonpool" );  	

	sync_node anim_single_aligned( self, "dive" );
	self notify( "diver_waiting" );

 	if ( self == level.heroes[ "hudson" ] )
	{
		sync_node = GetStruct( "moonpool_enter", "targetname" );
		sync_node thread anim_reach_aligned( level.heroes[ "hudson" ], "enter_subpen" );
	}
	else
	{
		while ( 1 )
		{
			sync_node anim_single_aligned( self, "tread_loop" );
		}
	}
}


//
//	PlayFx
play_land_fx( guy )
{
	PlayFxOnTag( level._effect["landing_fx"], guy, "J_Ankle_LE" );
	PlayFxOnTag( level._effect["landing_fx"], guy, "J_Ankle_RI" );
	wait( 1.0 );

	level.heroes["hudson"] anim_single( level.heroes["hudson"], "drop_weights" );
}


//
//	Enter Base
//
enter_subpen()
{
	sync_node = GetStruct( "moonpool_enter", "targetname" );

	sync_node thread enter_subpen_door();
	sync_node thread anim_single_aligned( level.allies[0],			"moon_pool_entry" );
//	sync_node anim_reach_aligned( level.heroes[ "hudson" ], "enter_subpen" );
	wait( 0.2 );	// let threads execute before starting.
	flag_set("moonpool_open_door");
	sync_node anim_single_aligned( level.heroes[ "hudson" ], "enter_subpen" );
}

//
//	The door is open enough to pass through
enter_subpen_door_open( guy )
{
	flag_set( "squad_enter_moonpool" );

	door = GetEnt( "moonpool_transition_door", "targetname" );
	door ConnectPaths();
	door_clip = GetEnt( "clip_moonpool_transition_door", "targetname" );
	door_clip DisconnectPaths();

	ai = GetAIArray( "allies" );
	for ( i=0; i<ai.size; i++ )
	{
		ai[i] enable_ai_color();
		wait( 0.5 );
	}
}


//
//	Big Flood scene
//
//	Player is slammed by wall of water, hits head on the rear bulkhead
big_flood()
{
	sync_node = GetStruct( "sync_flood_room", "targetname" );

	player = get_players()[0];
	player SetClientDvar( "compass", "0" );	// disable compass HUD
	// Spawn the fullbody for cinematic and link the player to it for animation
	player_body = spawn_anim_model( "player_body", player.origin, player.angles );	
	player PlayerlinktoAbsolute(player_body, "tag_origin");
//	player HideViewModel();

	player_body big_flood_player_knock_out( sync_node );	// blocking call

	player Unlink();
	player_body Delete();
//	player ShowViewModel();

	player SetClientDvar( "compass", "1" );	// re-enable crosshairs HUD
}


big_flood_hudson()
{
	level.heroes[ "hudson" ] ent_flag_init( "flood_swim_done" );
	sync_node = GetStruct( "sync_flood_room", "targetname" );
	sync_node anim_single_aligned( level.heroes[ "hudson" ], "flood_swim" );

	level.heroes[ "hudson" ] ent_flag_set( "flood_swim_done" );
}

//
// self is the array of engineers
frantic_engineers()
{
	for ( i=1; i<=3; i++ )
	{
		sync_node = GetStruct( "sync_frantic_engineer_0"+i, "targetname" );
		self[i-1].animname = "engineer"+i;
		self[i-1] thread loop_anim_control( sync_node, "console_loop", "end_loop" );
	}
}
// Controls when to stop the anim
loop_anim_control(sync_node, animation, endon_notify)
{
	self thread loop_idle_animation(sync_node, animation, endon_notify);
	self self_preservation( endon_notify );	// blocking function call

	self notify( endon_notify );
	self anim_stopanimscripted(0.2);
}
//
//	Keep looping until we're told to end
loop_idle_animation(sync_node, animation, endon_notify)
{
	self endon( "damage" );
	self endon( "death" );
	self endon(endon_notify);

	self.allowdeath = true;
	while(1)
	{
		sync_node anim_single_aligned(self, animation);
	}
}


//	Stop if any of these conditions are met
self_preservation( endon_notify )
{
	self endon( "damage" );
	self endon( "death" );

	player = get_players()[0];

	// check to see if someone's too close
	while (1)
	{
		height_diff = self.origin[2] - player.origin[2];
		if ( Abs(height_diff) < 20 )
		{
			if ( Distance2D( self.origin, player.origin ) < 250 )
			{
				return;
			}
		}
		wait(0.1);
	}
}


//
//	Dragovich fight scene
//
#using_animtree("generic_human");
end_fight()
{
	sync_node = GetStruct( "sync_drago_fight", "targetname" );
	player = get_players()[0];

	player SetClientDvar( "compass", "0" );	// disable compass HUD
	player SetClientDvar( "cg_drawFriendlyNames", 0 );
	// Spawn the fullbody for cinematic and link the player to it for animation
	player_body = spawn_anim_model( "player_body", player.origin, player.angles );	
	player PlayerLinkToAbsolute(player_body, "tag_player");
	player HideViewModel();
	player DisableWeapons();
	
	ai = GetAIArray( "axis" );
	for ( i=0; i<ai.size; i++ )
	{
		ai[i] DoDamage( 1000, ai[i].origin );
	}
	level.heroes[ "hudson" ].ignoreall = true;

	// manipulate console then get blasted
	maps\underwaterbase::set_base_impact_state( "wait", 0 );	// reactivate after pulldown
	player_body end_fight_console_player( sync_node );

	// Intro dragovich
	level.dragovich = simple_spawn_single( "dragovich" );
	level.dragovich.animname = "dragovich";
	level.dragovich.ignoreme = 1;
	level.dragovich thread end_fight_intro_dragovich( sync_node );
	sync_node thread anim_single_aligned( level.heroes[ "hudson" ], "fight_intro" );
	player_body end_fight_intro_player( sync_node );	// blocking call
	// When this ends, check to see if the player succeeded the QTE
	if ( flag("dragovich_fight_pull_down") )
	{
		//TUEY set music to GRAB_DRAGOVICH
		setmusicstate ("GRAB_DRAGOVICH");
		
		thread maps\underwaterbase::set_base_impact_state( "medium" );	// deactivated at start of scene
		flag_set( "dragovich_fight_choking" );
		level.dragovich	thread end_fight_win_dragovich( sync_node );
		player_body	end_fight_win_player( sync_node );
		level notify( "exp_escape" );			// activate exploder escape hall
		clientnotify( "upfxsn" );
	}
	else
	{
		level.dragovich	thread end_fight_lose_dragovich( sync_node );
		player_body	end_fight_lose_player( sync_node );
	}

	player Unlink();
	player_body Delete();
	player ShowViewModel();
	player SetClientDvar( "cg_drawFriendlyNames", 1 );

	// Turn to the exit
	escape_struct = GetStruct( "sync_escape", "targetname" );
	vector = escape_struct.origin - player.origin;
	angles = VectorToAngles( vector );
}


// Player gets shot by Dragovich
end_fight_lose( player_body )
{
	player = get_players()[0];
	player DisableInvulnerability();
	player PlayRumbleOnEntity( "damage_heavy" );
	player DoDamage( player.health+100, level.dragovich.origin );
	MissionFailed();
	wait(0.1);
	maps\underwaterbase_util::fade_out( 0.05, "black" );
}


//
//	Notetrack callback
//	Console explodes due to impact
#using_animtree("generic_human");
console_explosion( player_body )
{
	player = get_players()[0];	
	earthquake( 1.0, 1, player.origin,  500 );
	player PlayRumbleOnEntity( "artillery_rumble" );
	playsoundatposition( "evt_chamber1_explo", (0,0,0) );
	playsoundatposition( "evt_uwb_explosion", (0,0,0) );
	Exploder( 805 );
	clientnotify( "exsnp" );

	// These should probably end up as a swapped model
	rail1 = GetEnt( "br_rail_01", "targetname" );
	rail1 Delete();
	rail2 = GetEnt( "br_rail_02", "targetname" );
	rail2 Delete();
	clip = GetEnt( "clip_br_rail", "targetname" );
	clip Delete();

	// set water volume to moonpool height
//	maps\underwaterbase_util::set_water_height( "water_volume_escape_height" );
	maps\underwaterbase_util::set_water_height( "water_volume_broadcast_height", false );
	// Hide the texture used for the Dragovich fight
	water_texture = GetEnt( "dragovich_water_texture", "targetname" );
	water_texture trigger_on();

	ClientNotify( "light_torp03" );
	VisionSetNaked( "UWB_DragoFight", 2.0 );
	wait( 0.2 );	// wait so the shellshock doesn't just show us a big console

	player ShellShock( "explosion", 0.5 );
}

//	DRAGOVICH ANIMS
//
#using_animtree("generic_human");
//
// The Dragovich's anims for the end fight
end_fight_intro_dragovich( sync_node )
{
	level endon( "dragovich_fight_pull_down" );

	thread end_fight_intro_dragovich_slowmo();
	sync_node anim_single_aligned( self, "finest_agent" );
	sync_node anim_single_aligned( self, "fight_intro" );
}


//
//	Slowdown for Dragovich reveal
end_fight_intro_dragovich_slowmo()
{
	wait( 2.5 );	// wait for you to pull yourself up over the lip to see Dragovich

	// Slow mo!
//	thread maps\underwaterbase_util::dof_transition( 1.0, 0.5, 0, undefined, undefined, undefined, 4, 2.5 );
	thread maps\underwaterbase_util::dof_transition( 1.0, 0.5, 0, 30, 600, 700, 4, 2.5 );
	level timescale_tween( 1.0, 0.1, 0.8 );

	thread player_vo( "DRAGOVICH_SPOT" );
	wait( 0.05 );	// get a good look at him

	// back to normal...this has to end before Drago's VO plays so the lip syncs
	level timescale_tween( 0.1, 1.0, 0.6 );
}


//
// Dragovich gets pulled down to the ground and choked
//	self is Dragovich
end_fight_win_dragovich( sync_node )
{
	sync_node anim_single_aligned( self, "grab_dragovich" );

	// turn off blasts...the rumble interferes with the pulse rumble
	maps\underwaterbase::set_base_impact_state( "wait", 0 );

	// This will get cleared in choke_dragovich
	sync_node thread anim_loop_aligned( self, "choke_loop" );
	self  playloopsound( "evt_dragovich_drown_loop" );	//	ends in end_fight_win_player

	player = get_players()[0];
	player playloopsound( "vox_mason_choke_drag" );	// ends in end_fight_win_player

	while ( flag("dragovich_fight_choking") )
	{
		wait( 0.05 );
	}
	
	level.heroes["hudson"] thread anim_single( level.heroes["hudson"], "come_on_mason" );
	self thread do_dragovich_death(sync_node);
	flag_clear("dof_transition");	// return from dof_transition after hudson shot

	wait( 3.0 );	// dramatic pause

	player = get_players()[0];
	Earthquake( 1.5, 1.0, player.origin, 500 );
	playsoundatposition( "evt_uwb_explosion", (0,0,0) );
	player PlayRumbleOnEntity( "artillery_rumble" );

	wait( 0.3 );	// let the earthquake start shaking to help hide the swap
	// Turn the real water back on
	maps\underwaterbase_util::set_water_height( "water_volume_escape_height", true );
	// Hide the texture used for the Dragovich fight
	water_texture = GetEnt( "dragovich_water_texture", "targetname" );
	water_texture trigger_off();
}

do_dragovich_death(sync_node)
{
	sync_node anim_single_aligned( self, "kill_dragovich" );
	
	self.takedamage = false;
	self disable_pain();
	self disable_react();

	self AnimCustom(::dragovich_death_pose);
}

dragovich_death_pose()
{
	self SetAnimKnobAll(get_anim("kill_dragovich"), self.root_anim, 1, 0, 0);
	self SetAnimTime(get_anim("kill_dragovich"), 1);
	self SetClientFlag(1);

	self notify("death");
	level waittill("forever");
}


//
// Dragovich kills player
end_fight_lose_dragovich( sync_node )
{
	sync_node anim_single_aligned( self, "kill_player" );
}

//
//	"drago_shot" Notetrack callback
//	Hudson shoots Dragovich
end_fight_drago_shot( drago )
{
	if ( is_mature() )
	{
		fx = PlayFxOnTag( level._effect["dragovich_hit"], drago, "J_Clavicle_RI" );
// 		fx = PlayFxOnTag( level._effect["dragovich_hit"], drago, "J_Hip_RI" );
	}

	level timescale_tween( 1.0, 0.3, 0.1 );
	wait( 0.3 );

	level timescale_tween( 0.3, 1.0, 0.5 );

	level.heroes["hudson"] thread anim_single( level.heroes["hudson"], "dragovich" );
	flag_clear("dof_transition");	// return from intro_dragovich_slowmo

	wait( 0.1 );
	player = get_players()[0];
	level.old_fov  = GetDvarFloat( #"cg_fov" );
	player lerp_fov_overtime( 0.5, 45, true );	// reset in end_fight_drago_fire
}
//
//	"fire" Notetrack callback 
//	Dragovich shoots Hudson
end_fight_drago_fire( drago )
{
	if ( is_mature() )
	{
		fx = PlayFxOnTag( level._effect["dragovich_hit"], level.heroes[ "hudson" ], "J_Hip_LE" );
	}

	// Only do this on the first fire notetrack
	if ( !IsDefined( level.dragovich_fired ) )
	{
		level.dragovich_fired = 1;
		wait( 0.5 );	// wait until we start to return to Dragovich

		thread maps\underwaterbase_util::dof_transition( 1.0, 2.0, 0, 10, 30, 110, 4, 3.5 );

		player = get_players()[0];
		player thread lerp_fov_overtime( 0.5, level.old_fov, true );	// from end_fight_drago_shot
	}
}


//
//	"bubble_fx" Notetrack callback 
//	Air escapes Dragovich's mouth
drago_bubbles( drago )
{
	player = get_players()[0];
	player SetWaterSheeting( true, 10 );
    playsoundatposition( "evt_blorp", (0,0,0) );

	for ( i=0; i<5; i++)
	{
		PlayFxOnTag( level._effect["dragovich_bubbles"], drago, "J_Mouth_LE" );
		wait( 0.1 );
	}
}


//
//	Dragovich spits out water
drago_spit( drago )
{
	PlayFxOnTag( level._effect["dragovich_spit"], drago, "J_Mouth_LE" );
}


//
//  Player and Dragovich land in the water
drago_landing( drago )
{
	Exploder( 806 );

	player = get_players()[0];
	player ShellShock( "default", 4.0 );
	player SetWaterSheeting( true, 5 );
}


//
//  Dragovich splashes in the water
drago_head_splash( drago )
{
	Exploder( 807 );
	player = get_players()[0];
	player SetWaterSheeting( true, 4 );
}


//
//
end_fight_drago_dead( drago )
{
	flag_set( "dragovich_fight_end" );

	VisionSetNaked( "UWB_Escape", 2.0 );
}


//
//	Escape
escape( fade_time )
{
	sync_node = GetStruct( "sync_escape", "targetname" );

	sync_node anim_reach_aligned( level.heroes[ "hudson" ], "escape" );

	// wait until the fight anim is done
	flag_wait( "dragovich_fight_end" );	

	level.seaent thread maps\underwaterbase_escape::rock_the_base();
	sync_node thread anim_single_aligned( level.heroes[ "hudson" ], "escape" );
	anim_time = GetAnimLength(level.scr_anim[ "hudson" ]["escape"]);
	thread escape_nag();

	wait( anim_time - fade_time );
}


//
//	Keep the player moving
escape_nag()
{
	level.heroes[ "hudson" ] anim_single( level.heroes[ "hudson" ], "mason_this_way" );
	wait( 5 );

	lines[0] = "go_go_go";
	lines[1] = "come_on_mason";
	lines[2] = "keep_moving";
	lines[3] = "falling_apart";
	lines[4] = "need_to_move_mason";
	lines[5] = "mason_this_way";
	thread nag_dialog( level.heroes[ "hudson" ], lines, 5, "reached_escape_corridor" );

}


/////////////////////////////////////////
//	PLAYER ANIMS
/////////////////////////////////////////
#using_animtree("player");

//
// DIVE
//	a single dive anim processor for a single character
dive_anim_player( sync_node )
{
	player = get_players()[0];
	// Spawn the fullbody for cinematic and link the player to it for animation
	player_body = spawn_anim_model( "player_body", player.origin, player.angles );
	player_body Hide();	// Hiding player body per CJ's request
	player PlayerLinkTo(player_body, "tag_player", 0, 180, 180, 90, 80);
	player SetClientDvar( "cg_drawFriendlyNames", 0 );

	// Don't let stick input make arms move
	ClientNotify( "swim_move_stop" );

	sync_node anim_single_aligned( player_body, "dive" );

	player Unlink();
	player_body Delete();
	ClientNotify( "swim_move_start" );
	player SetClientDvar( "cg_drawFriendlyNames", 1 );

	flag_set( "player_dive_done" );

	player SetClientDvar( "compass", "1" );	// re-enable crosshairs HUD
}


//
//	BIG FLOOD
big_flood_player_knock_out( sync_node )
{
	sync_node anim_single_aligned( self, "water_knock_out" );
}

//
//	END FIGHT
//
//	Player attempts to stop the transmission
end_fight_console_player( sync_node )
{
	sync_node anim_single_aligned( self, "console_explosion" );
}

//
// The player's anims for the end fight
end_fight_intro_player( sync_node )
{
	sync_node anim_single_aligned( self, "finest_agent" );
 	anim_time = GetAnimLength(level.scr_anim["player_body"]["fight_intro"]);
	sync_node thread anim_single_aligned( self, "fight_intro" );
	// input_timeout is how long the player has to hit the prompt
	input_timeout = 2.0;
	wait( anim_time - input_timeout );

	flag_set( "dragovich_fight_wait_for_input" );
	level thread wait_for_grab_input();
	wait( input_timeout );

	flag_clear( "dragovich_fight_wait_for_input" );
}
//
// Wait for the player to hit the prompt or timeout
//	Using flags instead of GetTime because timescale messes up that method.
wait_for_grab_input( timeout )
{
	player = get_players()[0];
	screen_message_create(&"UNDERWATERBASE_PROMPT_GRAB");

	while ( flag( "dragovich_fight_wait_for_input" ) )
	{
		if( player AttackButtonPressed() )
		{
			flag_set("dragovich_fight_pull_down");
			break;
		}
		wait( 0.05 );
	}
	screen_message_delete();
}


//
// Player pulls Dragovich down to the ground and chokes him
end_fight_win_player( sync_node )
{
	sync_node anim_single_aligned( self, "grab_dragovich" );

	thread choke_dragovich( 30 );
	sync_node thread anim_loop_aligned( self, "choke_loop" );

	while ( flag("dragovich_fight_choking") )
	{
		wait( 0.05 );
	}

	player = get_players()[0];
	player stoploopsound(1);	//	stop vox_mason_choke_drag
	level.dragovich stoploopsound(2);	//	stop evt_dragovich_drown_loop

	sync_node anim_single_aligned( self, "kill_dragovich" );
}

//
//	Choke him out
choke_dragovich( timeout )
{
	player = get_players()[0];
	screen_message_create(&"UNDERWATERBASE_PROMPT_CHOKE");

	current_time = GetTime();
	end_time = current_time + timeout * 1000;
	half_time = current_time + timeout * 500;
	melee_hits_half = 20;	// half the number of hits we need
	sprint_hits_half = 20;	//
	melee_hits = 0;
	sprint_hits = 50;		// temp boost since SprintButtonPressed doesn't work in this situation
	melee_pressed = false;
	sprint_pressed = false;
	player thread play_heartbeat();
	while ( current_time < end_time )
	{
		if( player MeleeButtonPressed() )
		{
			if ( !melee_pressed )
			{
				melee_pressed = true;
				melee_hits++;
			}
		}
		else
		{
			melee_pressed = false;
		}

		if( player SprintButtonPressed() )
		{
			if ( !sprint_pressed )
			{
				sprint_pressed = true;
				sprint_hits++;
			}
		}
		else
		{
			sprint_pressed = false;
		}

		if ( !flag( "dragovich_fight_halfway_done" ) &&
			 ( (melee_hits > melee_hits_half && sprint_hits > sprint_hits_half) ||
			   current_time > half_time ) )
		{
			flag_set( "dragovich_fight_halfway_done" );
		}
		if ( melee_hits > melee_hits_half*2 && sprint_hits > sprint_hits_half )
		{
			break;
		}

		wait( 0.05 );

		current_time = GetTime();
	}
	screen_message_delete();

	// count how many hits you got if you want to determine "success" or "failure"
	flag_clear( "dragovich_fight_choking" );
}

//
//	Simulate a heartbeat.
play_heartbeat()	// self = player
{
	current_time = GetTime();
	heartbeat_interval = 0.2;
	next_heartbeat = current_time + heartbeat_interval;
	while (	flag( "dragovich_fight_choking" ) )
	{
		if ( !flag( "dragovich_fight_halfway_done" ) )
		{
			self PlayRumbleOnEntity( "damage_heavy" );
			wait( heartbeat_interval );

			self PlayRumbleOnEntity( "damage_heavy" );
			wait( heartbeat_interval );
		}
		else
		{
			self PlayRumbleOnEntity( "damage_heavy" );
			wait( heartbeat_interval );

			self PlayRumbleOnEntity( "damage_heavy" );
			wait( heartbeat_interval );
			heartbeat_interval += 0.2;
		}
		// heartbeat pause
		wait( heartbeat_interval );
	}
	StopAllRumbles();
}


//
// Player gets shot by Dragovich
end_fight_lose_player( sync_node )
{
	sync_node anim_single_aligned( self, "kill_player" );
}

audio_water_impact( player )
{
    playsoundatposition( "evt_bigflood_water_impact", (0,0,0) );
}

audio_wall_impact( player )
{
    playsoundatposition( "evt_bigflood_wall_impact", (0,0,0) );
}