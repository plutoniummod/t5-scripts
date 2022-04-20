//
// file: so_outro_frontend_amb.csc
// description: clientside ambient script for so_outro_frontend: setup ambient sounds, etc.
// scripter: 		(initial clientside work - laufer)
//

#include clientscripts\_utility; 
#include clientscripts\_ambientpackage;
#include clientscripts\_music;

main()
{
	//************************************************************************************************
	//                                              Ambient Packages
	//************************************************************************************************

	//declare an ambientpackage, and populate it with elements
	//mandatory parameters are <package name>, <alias name>, <spawnMin>, <spawnMax>
	//followed by optional parameters <distMin>, <distMax>, <angleMin>, <angleMax>
	
	
	//************************************************************************************************
	//                                       ROOMS
	//************************************************************************************************

	//explicitly activate the base ambientpackage, which is used when not touching any ambientPackageTriggers
	//the other trigger based packages will be activated automatically when the player is touching them
	//the same pattern is followed for setting up ambientRooms
	
	//************************************************************************************************
	//                                      ACTIVATE DEFAULT AMBIENT SETTINGS
	//************************************************************************************************

//		activateAmbientPackage( 0, "_pkg", 0 );
//		activateAmbientRoom( 0, "_room", 0 );		


		
	    //CREDITS
	    declareMusicState("CREDIT_ZERO"); 
			musicAliasloop("mus_devil", 2, 2);    
	    
	    declareMusicState("CREDIT_ONE"); 
			musicAliasloop("mus_eminem_backdown", 2, 2);
			
		declareMusicState("CREDIT_TWO"); 
			musicAliasloop("mus_in_chopper_loop", 2, 2);	
			
		declareMusicState("CREDIT_THREE"); 
			musicAliasloop("mus_credits", 2, 2);	
		
		declareMusicState("CREDIT_FOUR"); 
			musicAliasloop("mus_panthers_boat_arrive", 2, 2);
			
		declareMusicState("CREDIT_FIVE"); 
			musicAliasloop("mus_redglare_post_rocket", 2, 2);
			
		declareMusicState("CREDIT_SIX"); 
			musicAliasloop("mus_zombietron_zt_demo", 2, 2);
			
		declareMusicState("CREDIT_SEVEN"); 
			musicAliasloop("mus_zombietron_abra_macabre", 2, 2);		
	
		declareMusicState("SILENT");
			musicAliasloop("null",0,1);							
			
}			