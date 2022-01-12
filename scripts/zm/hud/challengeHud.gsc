#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/_visionset_mgr;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;




init()
{

}


challengeHud_Init()
{
	

	level.challengehud = createserverfontstring( "objective", 1.4 );
	level.challengehud setgamemodeinfopoint();
	level.challengehud.x = 5;
	level.challengehud.y = 100;
	level.challengehud.label = &"";
	level.challengehud.font = "small";
	level.challengehud.alpha = 0;
	level.challengehud.archived = 0;
	level.challengehud.hidewheninmenu = 1;
	level.challengehud.hidewheninkillcam = 1;
	level.challengehud.showplayerteamhudelemtospectator = 1;
}


	
