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
    initPlayerConnectionTracker();
    onplayerconnect_callback(::player_connected());
}


replacements()
{
    replacefunc(maps/mp/zombies/_zm::onallplayersready, ::onallplayersready);

}
onPlayerConnect()
{
    self firstconnect_stats();
    if(level.players.size > 1)
    self.sessionstate = "spectator";
    self is_first_spawn();
    self spawnIfRoundOne();
    self thread onPlayerSpawned();
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

onallplayersready() //checked changed to match cerberus output
{
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
	players = get_players();
	if ( players.size == 1 && getDvarInt( "scr_zm_enable_bots" ) == 1 )
	{
		level thread add_bots();
		flag_set( "initial_players_connected" );
	}
	else
	{
		players = get_players();
		if ( players.size == 1 )
		{
			flag_set( "solo_game" );
			level.solo_lives_given = 0;
			foreach ( player in players )
			{
				player.lives = 0;
			}
			level set_default_laststand_pistol( 1 );
		}
		flag_set( "initial_players_connected" );
		while ( !aretexturesloaded() )
		{
			wait 0.05;
		}
		thread start_zombie_logic_in_x_sec( 3 );
	}
	fade_out_intro_screen_zm( 5, 1.5, 1 );
}


playerConnectionTracker()
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
			if((level.firstconnect_stats[self.guid].round_start == 1)
			{
                return;
			}
			else
			{
				kick(self getentitynumber())
			}

		}


	
	}
}

spawnIfRoundOne() //spawn player
{
	level endon( "end_game" );
	self endon( "disconnect" );
	print("entered spawnIfRoundOne()");
	print(self.name + " firstspawn == " + self.firstspawn);
	print("sessionstate: " + self.sessionstate);
	if ( self.sessionstate != "playing" && self.firstspawn == 1)
	{
		wait 1;
		self tell("Get ready to be spawned!");

	}
	else
	{
		print("spawnifroundone() else 1: sessionstate: " + self.sessionstate);
	}

	wait 5;
	if ( self.sessionstate != "playing" && self.firstspawn == 1) //level.round_number == 1 )
	{
		self tell("spawning!");
		self [[ level.spawnplayer ]]();
		if ( level.script != "zm_tomb" || level.script != "zm_prison" || !is_classic() )
			thread maps\mp\zombies\_zm::refresh_player_navcard_hud();
		
	}
	else
	{
		print("spawnifroundone() else 2: sessionstate: " + self.sessionstate);
	}
}