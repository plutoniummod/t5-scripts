// Test clientside script for so_interrogationtest_frontend

#include clientscripts\_utility;

main()
{

	// _load!
	clientscripts\_load::main();

	//thread clientscripts\_fx::fx_init(0);
	thread clientscripts\_audio::audio_init(0);
	thread clientscripts\outro_amb::main();

	// This needs to be called after all systems have been registered.
	thread waitforclient(0);
}

