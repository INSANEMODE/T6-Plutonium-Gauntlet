#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;

init()
{
	level.no_end_game_check = true;
	level._game_module_game_end_check = ::prevent_end_game;
	level.callbackplayerdamage = ::callback_playerdamage;
}

prevent_end_game()
{
	return false;
}

callback_playerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked changed to match cerberus output //checked against bo3 _zm matches within reason
{
	if ( isDefined( eattacker ) && isplayer( eattacker ) && eattacker.sessionteam == self.sessionteam && !eattacker hasperk( "specialty_noname" ) && isDefined( self.is_zombie ) && !self.is_zombie )
	{
		self process_friendly_fire_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
		if ( self != eattacker )
		{
			return;
		}
		else if ( smeansofdeath != "MOD_GRENADE_SPLASH" && smeansofdeath != "MOD_GRENADE" && smeansofdeath != "MOD_EXPLOSIVE" && smeansofdeath != "MOD_PROJECTILE" && smeansofdeath != "MOD_PROJECTILE_SPLASH" && smeansofdeath != "MOD_BURNED" && smeansofdeath != "MOD_SUICIDE" )
		{
			return;
		}
	}
	if ( is_true( level.pers_upgrade_insta_kill ) )
	{
		self maps/mp/zombies/_zm_pers_upgrades_functions::pers_insta_kill_melee_swipe( smeansofdeath, eattacker );
	}
	if ( isDefined( self.overrideplayerdamage ) )
	{
		idamage = self [[ self.overrideplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	}
	else if ( isDefined( level.overrideplayerdamage ) )
	{
		idamage = self [[ level.overrideplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	}
	if ( is_true( level.gauntlet_double_trouble ) )
	{
		if ( is_true( eattacker.is_zombie ) )
		{
			idamage *= 2;
		}
	}
	if ( is_true( self.magic_bullet_shield ) )
	{
		maxhealth = self.maxhealth;
		self.health += idamage;
		self.maxhealth = maxhealth;
	}
	if ( isDefined( self.divetoprone ) && self.divetoprone == 1 )
	{
		if ( smeansofdeath == "MOD_GRENADE_SPLASH" )
		{
			dist = distance2d( vpoint, self.origin );
			if ( dist > 32 )
			{
				dot_product = vectordot( anglesToForward( self.angles ), vdir );
				if ( dot_product > 0 )
				{
					idamage = int( idamage * 0.5 );
				}
			}
		}
	}
	if ( isDefined( level.prevent_player_damage ) )
	{
		if ( self [[ level.prevent_player_damage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime ) )
		{
			return;
		}
	}
	idflags |= level.idflags_no_knockback;
	if ( idamage > 0 && shitloc == "riotshield" )
	{
		shitloc = "torso_upper";
	}
	self finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
}