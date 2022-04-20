// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
/*QUAKED actor_Civilian_Pentagon_Hudson (0.5 0.5 0.5) (-16 -16 0) (16 16 72) SPAWNER MAKEROOM UNDELETABLE ENEMYINFO SCRIPT_FORCESPAWN SM_PRIORITY
defaultmdl="c_usa_pentagon_hudson_fb"
"count" -- max AI to ever spawn from this spawner
SPAWNER -- makes this a spawner instead of a guy
MAKEROOM -- will try to delete an AI if spawning fails from too many AI
UNDELETABLE -- this AI (or AI spawned from here) cannot be deleted to make room for MAKEROOM guys
ENEMYINFO -- this AI when spawned will get a snapshot of perfect info about all enemies
SCRIPT_FORCESPAWN -- this AI will spawned even if players can see him spawning.
SM_PRIORITY -- Make the Spawn Manager spawn from this spawner before other spawners.
*/
main()
{
	self.animTree = "generic_human.atr";
	self.team = "neutral";
	self.type = "human";
	self.accuracy = 0.2;
	self.health = 100;
	self.weapon = "ak47_sp";
	self.secondaryweapon = "";
	self.sidearm = "m1911_sp";
	self.grenadeWeapon = "frag_grenade_sp";
	self.grenadeAmmo = 0;
	self.csvInclude = "";

	self setEngagementMinDist( 256.000000, 0.000000 );
	self setEngagementMaxDist( 768.000000, 1024.000000 );

	character\c_usa_pent_hudson::main();
}

spawner()
{
	self setspawnerteam("neutral");
}

precache()
{
	character\c_usa_pent_hudson::precache();

	precacheItem("ak47_sp");
	precacheItem("m1911_sp");
	precacheItem("frag_grenade_sp");
}
