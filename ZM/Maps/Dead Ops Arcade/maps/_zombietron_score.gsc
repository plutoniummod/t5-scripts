#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombietron_utility;

player_add_points( points )
{
	// Add the points
	
	self add_to_player_score( points );
	
	self.stats["score"] = self.score;
}

//
//	Add points to the player's score
//	self is a player
//
add_to_player_score( points )
{
	lowMask 	= 15;

	curScore = self getscoremultiplier();
	actual_multiplier = (curScore & lowMask)+1;
	points *= actual_multiplier;

	self.score += points; 

	if (self.score >= self.next_extra_life)
	{
		self.next_extra_life += level.zombie_vars["extra_life_at_every"];
		//give the player a life
		maps\_zombietron_pickups::directed_pickup_award_to(self,"extra_life_directed",level.extra_life_model);
	}


	// also set the score onscreen
	self set_player_score_hud(); 
}


update_hud()
{
	// currently re-use these fields because they are sent across the network and not used in this game mode
	self.revives = self.lives;
	self.assists = self.bombs;
	self.downs	 = self.boosters;
	
}

update_multiplier_bar( increment )
{
	lowMask 	= 15;
	curScore 	= self getscoremultiplier();
	actual_multiplier = (curScore & lowMask)+1;
	actual_increment  = curScore>>4;
	increment = int(increment);
	if ( increment == 0 )
	{
		if ( isDefined(self.fate_fortune) )
		{
			actual_multiplier --;//fated guys start out with 2x.  Decrement here to avoid casting out gems associated with the free multiplier.
		}
		
	
		if ( actual_multiplier > 1 )
		{
			level thread maps\_zombietron_pickups::spawn_uber_prizes( RandomFloatRange(0.3,0.5)*(actual_multiplier*level.zombie_vars["max_prize_inc_range"]), self.origin, true );
		}

		actual_increment 	= 0;
		actual_multiplier = 1;
		self.pointBarInc = level.zombie_vars["prize_increment"];
		
		if ( isDefined(self.fate_fortune) )
		{
			self maps\_zombietron_score::update_multiplier_bar( level.zombie_vars["max_prize_inc_range"]+1 );//fated players start with 2x
			actual_multiplier = 2;
		}
	}
	else
	{
		actual_increment += increment;
		if (actual_increment>level.zombie_vars["max_prize_inc_range"])
		{
			self.pointBarInc = int( (self.pointBarInc *0.65)+0.69);
			if (self.pointBarInc < 1 )
			{
				self.pointBarInc = 1;
			}
			
			actual_increment -= level.zombie_vars["max_prize_inc_range"];
			actual_multiplier ++;
			if ( actual_multiplier > level.zombie_vars["max_multiplier"] )
			{//all full
				actual_multiplier = level.zombie_vars["max_multiplier"];
				actual_increment  = level.zombie_vars["max_prize_inc_range"];
			}
		}
	}
	
	//repack
	curScore = ( actual_increment << 4 ) + (actual_multiplier-1);
	self setScoreMultiplier(curScore);
}

//
// SCORING HUD --------------------------------------------------------------------- //
//

//
//	Sets the point values of a score hud
//	self will be the player getting the score adjusted
//
set_player_score_hud( init )
{
	num = self.entity_num; 

	score_diff = self.score - self.old_score;

	if( IsDefined( init ) && init )
	{
		return; 
	}

	self.old_score = self.score; 
}

