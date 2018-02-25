#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>

#pragma newdecls required
#pragma semicolon 1

#include "files/globals.sp"
#include "files/client.sp"
#include "files/event.sp"
#include "files/grab.sp"
#include "files/menu.sp"
#include "files/menu_callback.sp"
#include "files/sdkhooks.sp"
#include "files/func.sp"
#include "files/commands.sp"
#include "files/database.sp"

public Plugin myinfo =
{
    name = "E' BlockMaker",
    author = "ESK0",
    version = "1.0",
    description = "",
    url = "www.github.com/ESK0"
};

public void OnPluginStart()
{
    RegAdminCmd("sm_bm", Command_BlockMaker, ADMFLAG_ROOT);
    HookEvent("player_spawn", Event_OnPlayerSpawn);
    HookEvent("player_death", Event_OnPlayerDeath);
    HookEvent("round_end", Event_OnRoundEnd);
    HookEvent("round_start", Event_OnRoundStart);

    Database.Connect(Database_Connect, "blockmaker");

    BuildPath(Path_SM, sDownloadFilePath, sizeof(sDownloadFilePath), "configs/BlockMaker_DownloadList.txt");

    arBlockMakerList = new ArrayList(32);
    arBlockRemoved = new ArrayList(16);
    for(int i = 0; i < 1000; i++)
    {
        arBlockMakerData[i] = new ArrayList(64);
    }

    Func_SetCvar("sv_enablebunnyhopping", "1");
}

public void OnMapStart()
{
    g_bDataLoaded = false;
    GetCurrentMap(szCurrentMap, sizeof(szCurrentMap));
    Func_PrecacheAndDownloadModels();
    Database_LoadData();
}

public void OnClientPutInServer(int client)
{
    if(g_bDataLoaded == false)
    {
        Database_LoadData();
    }
    g_iPlayerNewEntity[client] = -1;
    g_iGrabingBlock[client] = -1;
    g_bBlockGrab[client] = false;
    g_hBlockHeal[client] = null;
    SDKHook(client, SDKHook_OnTakeDamage, EventSDK_OnTakeDamage);
    if(!g_bCSGO)
    {
        SDKHook(client, SDKHook_PreThink, EventSDK_OnPreThink);
    }
}

public Action OnPlayerRunCmd(int client, int &iButtons, int &iImpulse, float fVelocity[3], float fAngles[3], int &iWeapon)
{
    if(IsValidClient(client))
    {
        if(g_bBlockGrab[client])
        {
            if(!(g_iPlayerPrevButtons[client] & IN_USE) && iButtons & IN_USE)
            {
                Grab_FirstTimePress(client);
            }
            else if (iButtons & IN_USE)
            {
                Grab_StillPressingButton(client, iButtons);
            }
            else if(g_OnceStopped[client])
            {
                Grab_StoppedMovingBlock(client);
            }
            g_iPlayerPrevButtons[client] = iButtons;
        }
    }
    return Plugin_Continue;
}

public Action Timer_BunnyHop_Disable(Handle timer, int entref)
{
    int entity = EntRefToEntIndex(entref);
    if(IsValidEntity(entity))
    {
        SetEntityRenderColor(entity, 255, 255, 255, 50);
        SetEntProp(entity, Prop_Send, "m_CollisionGroup", 1);
        CreateTimer(2.0, Timer_BunnyHop_Enable, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
    }
    return Plugin_Stop;
}

public Action Timer_BunnyHop_Enable(Handle timer, int entref)
{
    int entity = EntRefToEntIndex(entref);
    if(IsValidEntity(entity))
    {
        for(int i = 0; i <= MaxClients; i++)
        {
            if(g_iBunyHopTouch[i] == entref)
            {
                CreateTimer(1.0, Timer_BunnyHop_Enable, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
                return Plugin_Stop;
            }
        }
        SetEntityRenderColor(entity, 255, 255, 255, 255);
        SetEntProp(entity, Prop_Send, "m_CollisionGroup", 8);
        SDKHook(entity, SDKHook_StartTouch, EventSDK_OnStartTouch_BunnyHop);
    }
    return Plugin_Stop;
}

public Action Timer_BlockHeal(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if(IsValidClient(client, true))
    {
        if(g_hBlockHeal[client] != null)
        {
            int iHealth = GetClientHealth(client) + 1;
            SetEntityHealth(client, iHealth);
            if(iHealth >= 100)
            {
                SetEntityHealth(client, 100);
                g_hBlockHeal[client] = null;
                return Plugin_Stop;
            }
            else
            {
                SetEntityHealth(client, iHealth);
            }
        }
    }
    else
    {
        g_hBlockHeal[client] = null;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}
