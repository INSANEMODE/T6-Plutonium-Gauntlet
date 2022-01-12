#include common_scripts/utility;
#include maps/mp/_demo;
#include maps/mp/_utility;
#include maps/mp/_visionset_mgr;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;


main()
{
    replacements();

}

init()
{
	level thread pregame_hud();
    initPlayerConnectionArrays();
    onplayerconnect_callback(::onPlayerConnect());

}


replacements()
{
    // replacefunc(maps/mp/zombies/_zm::onallplayersready, ::onallplayersready);
	// replacefunc(maps/mp/zombies/_zm::start_zombie_logic_in_x_sec, ::start_zombie_logic_in_x_sec);



}
onPlayerConnect()
{
    self firstconnect_stats();
    if(level.players.size > 1)
    self.sessionstate = "spectator";
    self is_first_spawn();
    self thread onPlayerSpawned();
    self spawnIfRoundOne();

}

onPlayerSpawned()
{
    level endon("end_game");
    self endon("disconnect");
    while(1)
    {
        self waittill( "spawned_player" );
        if(is_true(self.firstspawn))
        {
            self thread Lategamekick();

        }
        self.firstspawn = 0;

    }

}



initPlayerConnectionArrays()
{
    level.firstspawn = [];
	level.firstconnect_stats = [];
}

firstconnect_stats()
{
	player = spawnstruct();
	player.guid = self.guid;
	player.connecttime = gettime();
	player.name = self.name;
	player.round_start = level.round_number;
	player.connectcount = 1;
	if(!isdefined(level.firstconnect_stats[self.guid]))
	{
		level.firstconnect_stats[self.guid] = player;
	}
	else if(isdefined(level.firstconnect_stats[self.guid]))
	{
		level.firstconnect_stats[self.guid].connectcount++;
	}
}

is_first_spawn()
{

	if(!isinarray(level.firstspawn, self.guid))
	{
		arrayinsert(level.firstspawn, self.guid, level.firstspawn.size);
		self.firstspawn = 1;
	}
	else if(isinarray(level.firstspawn, self.guid))
	{

		self iPrintLn("Please wait for next round to respawn.");

	}
}



LateGameKick()
{

	if(!level.intermission)
	{
		if(!isDefined(self))
		{
			return;
		}

		if(isdefined(level.firstconnect_stats[self.guid]))
		{
			if(level.firstconnect_stats[self.guid].round_start == 1)
			{
                return;
			}
			else
			{
				kick(self getentitynumber());
			}

		}


	
	}
}

spawnIfRoundOne() //spawn player
{
	level endon( "end_game" );
	self endon( "disconnect" );

	if ( self.sessionstate != "playing" && self.firstspawn == 1)
	{
		wait 1;
		self tell("Get ready to be spawned!");

	}


	wait 5;
	if ( self.sessionstate != "playing" && self.firstspawn == 1) 
	{
		self tell("spawning!");
		self [[ level.spawnplayer ]]();
		if ( level.script != "zm_tomb" || level.script != "zm_prison" || !is_classic() )
			thread maps\mp\zombies\_zm::refresh_player_navcard_hud();
		
	}

}



pregame_hud() //checked matches bo3 _globallogic.gsc within reason
{
	flag_wait( "initial_blackscreen_passed" );
	visionSetNaked( "mpIntro" );
	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -40 );
	matchStartText.sort = 1001;
	matchStartText.label = &"Waiting for 4 Players to Begin";
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = true;
	matchStartText.alpha = 1;
	flag_wait( "player_quota" );
	matchStartText.label = game[ "strings" ][ "match_starting_in" ];
	matchStartTimer = createServerFontString( "objective", 2.2 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	matchStartTimer.sort = 1001;
	matchStartTimer.color = ( 1, 1, 0 );
	matchStartTimer.foreground = false;
	matchStartTimer.hidewheninmenu = true;
	matchStartTimer maps\mp\gametypes_zm\_hud::fontPulseInit();
	countTime = 5;
	if ( countTime >= 2 )
	{
		while ( countTime > 0 )
		{
			matchStartTimer setValue( countTime );
			matchStartTimer thread maps\mp\gametypes_zm\_hud::fontPulse( level );
			if ( countTime == 2 )
			{
				visionSetNaked( GetDvar( "mapname" ), 3.0 );
			}
			countTime--;
			wait 1;
		}
	}
	else
	{
		visionSetNaked( GetDvar( "mapname" ), 1.0 );
	}
	matchStartTimer destroyElem();
	matchStartText destroyElem();
}







//////////Replaced functions start//////////




//////////Replaced functions end//////////