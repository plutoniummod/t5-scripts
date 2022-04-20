// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
/*QUAKED actor_enemy_dog_sp (1.0 0.25 0.0) (-16 -16 0) (16 16 72) SPAWNER MAKEROOM UNDELETABLE ENEMYINFO SCRIPT_FORCESPAWN SM_PRIORITY
defaultmdl="german_sheperd_dog"
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
	self.animTree = "dog.atr";
	self.team = "axis";
	self.type = "dog";
	self.accuracy = 1;
	self.health = 200;
	self.weapon = "dog_bite_sp";
	self.secondaryweapon = "";
	self.sidearm = "";
	self.grenadeWeapon = "dog_bite_sp";
	self.grenadeAmmo = 0;
	self.csvInclude = "";

	self setEngagementMinDist( 0.000000, 0.000000 );
	self setEngagementMaxDist( 100.000000, 300.000000 );

	character\character_sp_german_sheperd_dog::main();
}

spawner()
{
	self setspawnerteam("axis");
}

precache()
{
	character\character_sp_german_sheperd_dog::precache();

	precacheItem("dog_bite_sp");
	precacheItem("dog_bite_sp");
}
