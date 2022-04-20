#include maps\_utility;
#include common_scripts\utility; 
#include maps\_music;


main()
{
	maps\_load::main();

	maps\outro_fx::main();
	maps\outro_amb::main();
	maps\outro_anim::main();

	level.onMenuMessage = ::menu_message;

	wait(3);

	SetDvar( "zombiefive_discovered", 1 );
	UpdateGamerProfile(); 

	level thread lock_player_controls();
	level thread play_credits_music();	
	level thread skip_interstitial();
}

lock_player_controls()
{
	wait_for_all_players();
	player = get_players()[0];
	//player FreezeControls(true);
	
	lock_ent = Spawn( "script_model", player.origin );
	lock_ent SetModel("tag_origin");
	player LinkTo(lock_ent);
}

skip_interstitial()
{
	wait 3;
	SetDvar("ui_show_skip",1);
	while (!get_players()[0] jumpbuttonpressed() && !get_players()[0] buttonPressed("mouse1") )
	{
		wait 0.05;
	}

	SetDvar( "zombiefive_norandomchar", 1 );
	ChangeLevel("zombie_pentagon",false,0);
}

menu_message(state, item)
{
	if (state=="credits")
	{
		if (item=="start")
		{
			//TUEY CREDITS HERE
		}
		//close the credits menu
		if (item=="done")
		{
			//TUEY CREDITS HERE
			level thread set_music_state_to_silence();

			SetDvar( "zombiefive_norandomchar", 1 );
			ChangeLevel("zombie_pentagon",false,0);
		}
	}
}
play_credits_music()
{
    level endon( "end_credits_music" );
    level endon( "menu_resetstate" );
    
    if(GetDvar( #"language" ) != "german" )
    {
    	level play_credit_song( "CREDIT_ZERO", 360 );
    }    
    if( is_mature() == true) 
    {
        level play_credit_song( "CREDIT_ONE", 264 );
    }
    
    level play_credit_song( "CREDIT_TWO", 186 );
    level play_credit_song( "CREDIT_THREE", 106 );
    level play_credit_song( "CREDIT_FOUR", 136 );
    level play_credit_song( "CREDIT_FIVE", 82 );
    level play_credit_song( "CREDIT_SIX", 130 );
    level play_credit_song( "CREDIT_SEVEN", 182 );
}
play_credit_song( music_state, waittime )
{
    level endon( "end_credits_music" );
    level endon( "menu_resetstate" );
    
    setmusicstate( music_state );
    wait( waittime );
}
set_music_state_to_silence()
{
    setmusicstate( "SILENT" );
}