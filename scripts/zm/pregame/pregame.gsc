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
	flag_init( "player_quota" );
	level thread pregame_hud();
    initPlayerConnectionArrays();
    onplayerconnect_callback(::onPlayerConnect());

}


replacements()
{
    replacefunc(maps/mp/zombies/_zm::onallplayersready, ::onallplayersready);
	replacefunc(maps/mp/zombies/_zm::start_zombie_logic_in_x_sec, ::start_zombie_logic_in_x_sec);



}
onPlayerConnect()
{
    self firstconnect_stats();
    if(level.players.size > 1)
    self.sessionstate = "spectator";
    self is_first_spawn();
    self thread onPlayerSpawned();
    self spawnIfRoundOne();
	self thread Lategamekick();

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
	self endon("disconnect");

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
	self endon("disconnect");
	

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
				wait 5;
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
	level endon("end_game");

	flag_wait( "initial_blackscreen_passed" );
	visionSetNaked( "mpIntro" );
	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -40 );
	matchStartText.sort = 1001;
	matchStartText setText(&"MP_WAITING_FOR_X_PLAYERS");
	//matchStartText.label = &"Waiting for 4 Players to Begin";
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = true;
	matchStartText.alpha = 1;

	pregameplayercount = createserverfontstring( "objective", 2.2 );
	//level.pregameplayercount setparent(matchStartText);
	pregameplayercount setPoint( "CENTER", "CENTER", -7, -40 );
	pregameplayercount.sort = 1001;
	pregameplayercount.foreground = 0;
	pregameplayercount.hidewheninmenu = 1;
	pregameplayercount.archived = 1;
	pregameplayercount.alpha = 1;
	pregameplayercount.color = ( 1, 1, 0 );
	pregameplayercount maps\mp\gametypes_zm\_hud::fontpulseinit();
	oldcount = -1;
	minplayers = 4;
	//while(is_false(quota) || !isDefined(quota))
	while(is_false(flag( "player_quota" )))
	{
		//quota = ;
		wait( 1 );
		
		cur_playercount = getPlayers().size;
		amount_needed = minplayers - cur_playercount;
		if ( amount_needed <= 0 )
		{
			break;
		}

		if ( oldcount != amount_needed )
		{
			pregamePlayerCount setValue( amount_needed );
			pregamePlayerCount thread maps\mp\gametypes_zm\_hud::fontPulse( level );
			oldcount = amount_needed;
		}
	}
	pregameplayercount settext( "" );
	//flag_wait( "player_quota" );
	matchStartText settext( game[ "strings" ][ "match_starting_in" ]);
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
	pregameplayercount destroyElem();
}







//////////Replaced functions start//////////

onallplayersready() //checked changed to match cerberus output
{
	level endon("end_game");
	players = get_players();
	while ( players.size == 0 )
	{
		players = get_players();
		wait 0.1;
	}

    player_count_actual = 0;
    while ( getnumconnectedplayers() < getnumexpectedplayers() || player_count_actual != getnumexpectedplayers() )
    {
        players = get_players();
        player_count_actual = 0;
        i = 0;
        while ( i < players.size )
        {
            players[ i ] freezecontrols( 1 );
            if ( players[ i ].sessionstate == "playing" )
            {
                player_count_actual++;
            }
            i++;
        }   
        wait 0.1;
    }
	setinitialplayersconnected(); 
	flag_set( "initial_players_connected" );
	while ( !aretexturesloaded() )
	{
		wait 0.05;
	}

	thread start_zombie_logic_in_x_sec(5);

	fade_out_intro_screen_zm( 5, 1.5, 1 );
}
start_zombie_logic_in_x_sec( seconds ) //checked matches cerberus output
{
	level endon("end_game");
	flag_clear( "spawn_zombies" );
	//iprintln("Starting Zombie Logic in " + seconds + " seconds");

	timeout = 0;
	players = get_players();
	while(timeout < 30)
	{
		players = get_players();
		if(players.size == 4)
		{
			break;
		}
		wait 1;
		timeout++;

	}
	flag_set( "player_quota" );
	wait seconds;
	flag_set( "start_zombie_round_logic" );
	flag_set( "spawn_zombies" );
}


//////////Replaced functions end//////////