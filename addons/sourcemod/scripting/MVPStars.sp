#pragma newdecls required

#include <sourcemod>
#include <cstrike>
#include <zombiereloaded>

bool 	
	G_bIsHuman[MAXPLAYERS + 1],
 	G_bIsZombie[MAXPLAYERS + 1];

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public Plugin myinfo =
{
	name        = "MVP Stars",
	author      = "zaCade",
	description = "Adds a star in the scoreboard to the humans that won the round",
	version     = "1.1",
	url         = ""
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void ZR_OnClientInfected(int client, int attacker, bool motherinfect, bool respawnoverride, bool respawn)
{
	G_bIsHuman[client] = false;
	G_bIsZombie[client] = true;
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void ZR_OnClientHumanPost(int client, bool respawn, bool protect)
{
	G_bIsHuman[client] = true;
	G_bIsZombie[client] = false;
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		G_bIsHuman[client] = true;
		G_bIsZombie[client] = false;
	}
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if(event.GetInt("winner") == CS_TEAM_CT)
		CreateTimer(0.2, OnHumansWin, _, TIMER_FLAG_NO_MAPCHANGE);
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public Action OnHumansWin(Handle timer)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsClientObserver(client) && !IsFakeClient(client))
		{
			if (G_bIsHuman[client] && !G_bIsZombie[client])
			{
				CS_SetMVPCount(client, CS_GetMVPCount(client) + 1);
			}
		}
	}
	
	return Plugin_Continue;
}
