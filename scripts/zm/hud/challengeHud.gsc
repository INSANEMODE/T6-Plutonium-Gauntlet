#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/_visionset_mgr;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;




init()
{
	challengeHudInit();
	level thread ChallengeHudUpdate();


}


challengeHudInit()
{
	
	green = ( 0.6, 0.9, 0.6 );
	red = ( 0.7, 0.3, 0.2 );
	yellow = ( 1, 1, 0 );
	white = ( 1, 1, 1 );
	titlesize = 1.5;
	textsize = 1;
	font = "objective";

	///title/// - used for the challenge name
	level.challengetitle = createserverfontstring( font, titlesize );
	level.challengetitle setgamemodeinfopoint();
	level.challengetitle.y -= 100;
	level.challengetitle setText(" "); // 
	level.challengetitle.glowalpha = 1;
	level.challengetitle.foreground = 1;
	level.challengetitle.color = yellow;
	level.challengetitle.alpha = 0;
	level.challengetitle.archived = 0;
	level.challengetitle.hidewheninmenu = 1;

	///subtitle/// - used for the challenge description

	level.challengesubtitle = createserverfontstring( font, textsize );
	
	level.challengesubtitle setgamemodeinfopoint();
	level.challengesubtitle.y -= 80;
	level.challengesubtitle.glowalpha = 1;
	level.challengesubtitle.alpha = 0;
	level.challengesubtitle.foreground = 0;
	level.challengesubtitle.hidewheninmenu = 1;
	level.challengesubtitle.archived = 1;
	level.challengesubtitle setText(" "); 
	level.challengesubtitle.color = white;




}

ChallengeHudUpdate()  //warning, this does not take string overflow into account caused by setText()
{
	level endon("end_game");
	level thread ChallengeHudDestruction();
	while(1)
	{
		level waittill("start_of_round");
		flag_wait("start_zombie_round_logic");
		if(isDefined(level.gauntlet_challenges[level.gauntlet_challenge_index].name) && isDefined(level.gauntlet_challenges[level.gauntlet_challenge_index].description))
		{
			level.challengetitle setText(level.gauntlet_challenges[level.gauntlet_challenge_index].name);
			level.challengetitle fadeovertime( 0.5 );
			level.challengetitle.alpha = 1;
			level.challengesubtitle setText(level.gauntlet_challenges[level.gauntlet_challenge_index].description);
			level.challengesubtitle fadeovertime( 0.5 );
			level.challengesubtitle.alpha = 1;
		}
		else
		{
			level.challengetitle setText(" ");
			level.challengesubtitle setText(" ");
		}
		level waittill("end_of_round");
		level.challengesubtitle fadeovertime( 0.5 );
		level.challengesubtitle.alpha = 0;
		level.challengetitle fadeovertime( 0.5 );
		level.challengetitle.alpha = 0;
		

	}

}

ChallengeHudDestruction()
{
	level waittill("end_game");
	level.challengesubtitle destroy();
	level.challengetitle destroy();
}

	