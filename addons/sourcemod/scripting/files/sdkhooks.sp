public Action EventSDK_OnPreThink(int client)
{
	if(IsValidClient(client, true))
	{
		SetEntPropFloat(client, Prop_Send, "m_flStamina", 0.0);
	}
	return Plugin_Continue;
}

public Action EventSDK_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if(IsValidClient(victim))
	{
		if(damagetype & DMG_FALL)
		{
			int iEnt = GetEntPropEnt(victim, Prop_Send, "m_hGroundEntity");
			if(IsValidEntity(iEnt))
			{
				if(arBlockMakerList.FindValue(EntIndexToEntRef(iEnt)) != -1)
				{
					char szBlockType[32];
					Func_GetBlockType(iEnt, szBlockType, sizeof(szBlockType));
					if(StrEqual(szBlockType, "nofalldamage"))
					{
						return Plugin_Handled;
					}
					else if(StrEqual(szBlockType, "trampoline"))
					{
						return Plugin_Handled;
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action EventSDK_OnStartTouch_BunnyHop(int entity, int client)
{
	if(entity != client)
	{
		if(IsValidEntity(entity) && IsValidClient(client, true))
		{
			SDKUnhook(entity, SDKHook_StartTouch, EventSDK_OnStartTouch_BunnyHop);
			CreateTimer(0.4, Timer_BunnyHop_Disable, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action EventSDK_OnStartTouch_AutoBhop(int entity, int client)
{
	if(entity != client)
	{
		if(IsValidEntity(entity) && IsValidClient(client, true))
		{
			float fBlockOrigin[3];
			float fClientOrigin[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fBlockOrigin);
			GetClientAbsOrigin(client, fClientOrigin);
			if(fClientOrigin[2] >= fBlockOrigin[2])
			{
				RequestFrame(RequestFrame_AutoBhop, client);
			}
		}
	}
}

public void RequestFrame_AutoBhop(int client)
{
	if(GetClientButtons(client) & IN_JUMP)
	{
		float fVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		fVelocity[2] = 292.6;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
	}
}

public Action EventSDK_OnStartTouch_Trampoline(int entity, int client)
{
	if(entity != client)
	{
		if(IsValidEntity(entity) && IsValidClient(client, true))
		{
			float fBlockOrigin[3];
			float fClientOrigin[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fBlockOrigin);
			GetClientAbsOrigin(client, fClientOrigin);
			if(fClientOrigin[2] >= fBlockOrigin[2])
			{
				DataPack data = new DataPack();
				data.WriteCell(GetClientUserId(client));
				data.WriteCell(EntIndexToEntRef(entity));
				RequestFrame(RequestFrame_Trampoline, data);
			}
		}
	}
}

public void RequestFrame_Trampoline(DataPack data)
{
	data.Reset();
	int client = GetClientOfUserId(data.ReadCell());
	int iBlock = data.ReadCell();
	delete data;
	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	int iIndex = arBlockMakerList.FindValue(iBlock);
	if(iIndex != -1)
	{
		char szBuffer[32];
		arBlockMakerData[iIndex].GetString(BlockOtherValue, szBuffer, sizeof(szBuffer));
		float fValue = StringToFloat(szBuffer);
		fVelocity[2] = fValue;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
	}
}

public Action EventSDK_OnEndTouch_BunnyHop(int entity, int client)
{
	if(entity != client)
	{
		if(IsValidEntity(entity) && IsValidClient(client, true))
		{
			g_iBunyHopTouch[client] = -1;
		}
	}
}

public Action EventSDK_OnTouch_BunnyHop(int entity, int client)
{
	if(entity != client)
	{
		if(IsValidEntity(entity) && IsValidClient(client, true))
		{
			if(g_iBunyHopTouch[client] == -1)
			{
				g_iBunyHopTouch[client] = EntIndexToEntRef(entity);
			}
		}
	}
}

public Action EventSDK_OnStartTouch_Teleport(int entity, int client)
{
	if(entity != client)
	{
		if(IsValidEntity(entity) && IsValidClient(client, true))
		{
			char szBuffer[128];
			float fOrigin[3];
			GetEntPropString(entity, Prop_Data, "m_iGlobalname", szBuffer, sizeof(szBuffer));
			Func_StringToVector(szBuffer, fOrigin);
			if(Func_IsVectorZero(fOrigin) == false)
			{
				fOrigin[2] += 2.0;
				TeleportEntity(client, fOrigin, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}
}

public Action EventSDK_OnStartTouch_Death(int entity, int client)
{
	if(entity != client)
	{
		if(IsValidEntity(entity) && IsValidClient(client, true))
		{
			ForcePlayerSuicide(client);
		}
	}
}

public Action EventSDK_OnStartTouch_Heal(int entity, int client)
{
	if(entity != client)
	{
		if(IsValidEntity(entity) && IsValidClient(client, true))
		{
			if(g_hBlockHeal[client] == null)
			{
				int iHealth = GetClientHealth(client);
				if(iHealth < 100)
				{
					g_hBlockHeal[client] = CreateTimer(1.0, Timer_BlockHeal, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
}

public Action EventSDK_OnEndTouch_Heal(int entity, int client)
{
	if(entity != client)
	{
		if(IsValidEntity(entity) && IsValidClient(client))
		{
			if(g_hBlockHeal[client] != null)
			{
				delete g_hBlockHeal[client];
				g_hBlockHeal[client] = null;
			}
		}
	}
}
