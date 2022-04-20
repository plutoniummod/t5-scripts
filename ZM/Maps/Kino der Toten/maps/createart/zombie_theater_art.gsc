//_createart generated.  modify at your own risk. Changing values should be fine.

main()
{

	level.tweakfile = true;

	VisionSetNaked( "zombie_theater", 0 );
	SetSavedDvar( "sm_sunSampleSizeNear", "0.93" );
	// SetSavedDvar( "r_skyTransition", "1" );
	///////////New Hero Lighting///////////////
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.45 );
	SetSavedDvar( "r_lightGridContrast", 0.15 );
	
	//SetSavedDvar( "r_skyColorTemp", 5000.0 );
	SetSavedDvar("r_lightTweakSunLight", 22);
	//SetSunLight(0.661, 0.6228, 0.727);
	
}

