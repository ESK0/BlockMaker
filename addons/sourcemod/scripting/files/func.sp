public void Func_SpawnBlocks()
{
    if(arBlockMakerList.Length > 0)
    {
        char szBuffer[PLATFORM_MAX_PATH];
        char szBlockType[32];
        char szBlockSize[32];
        char szBlockSizeEx[32];
        float fOrigin[3];
        float fAngles[3];
        for(int iIndex = 0; iIndex < arBlockMakerList.Length; iIndex++)
        {
            if(arBlockMakerList.Get(iIndex) != -1)
            {
                arBlockMakerData[iIndex].GetString(BlockType, szBlockType, sizeof(szBlockType));
                arBlockMakerData[iIndex].GetString(BlockSize, szBlockSize, sizeof(szBlockSize));
                Format(szBlockSizeEx, sizeof(szBlockSizeEx), "_%s", szBlockSize);
                Format(szBuffer, sizeof(szBuffer), "models/esko/blockmaker/%s%s.mdl",szBlockType, StrEqual(szBlockSize, "normal")?"":szBlockSizeEx);
                int iBlock = CreateEntityByName("prop_dynamic");
                arBlockMakerList.Set(iIndex, EntIndexToEntRef(iBlock));
                DispatchKeyValue(iBlock, "model", szBuffer);
                DispatchKeyValue(iBlock, "solid", "6");
                if(DispatchSpawn(iBlock))
                {
                    Format(szBuffer, sizeof(szBuffer), "blockmaker;%s;%s", szBlockType, szBlockSize);
                    SetEntPropString(iBlock, Prop_Data, "m_iName", szBuffer);
                    arBlockMakerData[iIndex].GetString(BlockOrigin, szBuffer, sizeof(szBuffer));
                    Func_StringToVector(szBuffer, fOrigin);
                    arBlockMakerData[iIndex].GetString(BlockAngles, szBuffer, sizeof(szBuffer));
                    Func_StringToVector(szBuffer, fAngles);
                    TeleportEntity(iBlock, fOrigin, fAngles, NULL_VECTOR);
                    SetEntProp(iBlock, Prop_Send, "m_usSolidFlags", 152);
                    SetEntProp(iBlock, Prop_Send, "m_CollisionGroup", 8);
                    SetEntityRenderMode(iBlock, RENDER_TRANSCOLOR);

                    if(StrEqual(szBlockType, "teleport"))
                    {
                        SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Teleport);
                        arBlockMakerData[iIndex].GetString(BlockOtherValue, szBuffer, sizeof(szBuffer));
                        SetEntPropString(iBlock, Prop_Data, "m_iGlobalname", szBuffer);
                    }
                    else if(StrEqual(szBlockType, "bunnyhop"))
                    {
                        SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_BunnyHop);
                        SDKHook(iBlock, SDKHook_EndTouch, EventSDK_OnEndTouch_BunnyHop);
                        SDKHook(iBlock, SDKHook_Touch, EventSDK_OnTouch_BunnyHop);
                    }
                    else if(StrEqual(szBlockType, "autobhop"))
                    {
                        SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_AutoBhop);
                    }
                    else if(StrEqual(szBlockType, "death"))
                    {
                        SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Death);
                    }
                    else if(StrEqual(szBlockType, "heal"))
                    {
                        SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Heal);
                        SDKHook(iBlock, SDKHook_EndTouch, EventSDK_OnEndTouch_Heal);
                    }
                    else if(StrEqual(szBlockType, "trampoline"))
                    {
                        SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Trampoline);
                        arBlockMakerData[iIndex].GetString(BlockOtherValue, szBuffer, sizeof(szBuffer));
                        SetEntPropString(iBlock, Prop_Data, "m_iGlobalname", szBuffer);
                    }
                }
            }
        }
    }
}

public int Func_GetFreeIndex()
{
    for(int i = 0; i < arBlockMakerList.Length; i++)
    {
        int iIndex = arBlockMakerList.Get(i);
        if(iIndex == -1)
        {
            return i;
        }
    }
    return -1;
}

public void Func_CreateBlock(int client, const char[] szType)
{
    char szBuffer[PLATFORM_MAX_PATH];
    Format(szBuffer, sizeof(szBuffer), "models/esko/blockmaker/%s.mdl", szType);
    int iBlock = CreateEntityByName("prop_dynamic");
    DispatchKeyValue(iBlock, "model", szBuffer);
    DispatchKeyValue(iBlock, "solid", "6");
    if(DispatchSpawn(iBlock))
    {
        float fOrigin[3];
        Func_GetAimOrigin(client, fOrigin);
        fOrigin[2] += 20.0;
        Format(szBuffer, sizeof(szBuffer), "blockmaker;%s;normal",szType);
        SetEntPropString(iBlock, Prop_Data, "m_iName", szBuffer);
        TeleportEntity(iBlock, fOrigin, NULL_VECTOR, NULL_VECTOR);
        SetEntProp(iBlock, Prop_Send, "m_usSolidFlags", 152);
        SetEntProp(iBlock, Prop_Send, "m_CollisionGroup", 8);
        SetEntityRenderMode(iBlock, RENDER_TRANSCOLOR);
        int iIndex = Func_GetFreeIndex();
        arBlockMakerList.Set(iIndex, EntIndexToEntRef(iBlock));
        arBlockMakerData[iIndex].Clear();
        arBlockMakerData[iIndex].Push(0);
        arBlockMakerData[iIndex].Push(0);
        arBlockMakerData[iIndex].PushString(szType);
        arBlockMakerData[iIndex].PushString("normal");
        Func_VectorToString(fOrigin, szBuffer, sizeof(szBuffer));
        arBlockMakerData[iIndex].PushString(szBuffer);
        float fAngles[3];
        GetEntPropVector(iBlock, Prop_Send, "m_angRotation", fAngles);
        Func_VectorToString(fAngles, szBuffer, sizeof(szBuffer));
        arBlockMakerData[iIndex].PushString(szBuffer);
        if(StrEqual(szType, "teleport"))
        {
            SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Teleport);
            arBlockMakerData[iIndex].PushString("0.0;0.0;0.0");
        }
        else if(StrEqual(szType, "bunnyhop"))
        {
            SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_BunnyHop);
            SDKHook(iBlock, SDKHook_EndTouch, EventSDK_OnEndTouch_BunnyHop);
            SDKHook(iBlock, SDKHook_Touch, EventSDK_OnTouch_BunnyHop);
        }
        else if(StrEqual(szType, "autobhop"))
        {
            SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_AutoBhop);
        }
        else if(StrEqual(szType, "death"))
        {
            SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Death);
        }
        else if(StrEqual(szType, "heal"))
        {
            SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Heal);
            SDKHook(iBlock, SDKHook_EndTouch, EventSDK_OnEndTouch_Heal);
        }
        else if(StrEqual(szType, "trampoline"))
        {
            SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Trampoline);
            arBlockMakerData[iIndex].PushString("250");
            SetEntPropString(iBlock, Prop_Data, "m_iGlobalname", "250");
        }
    }
}

public void Func_CopyBlock(int iCopy)
{
    char szBuffer[PLATFORM_MAX_PATH];
    char szBlockType[32];
    char szBlockSize[32];
    char szBlockSizeEx[32];
    int iBlock = CreateEntityByName("prop_dynamic");
    Func_GetBlockSize(iCopy, szBlockSize, sizeof(szBlockSize));
    Func_GetBlockType(iCopy, szBlockType, sizeof(szBlockType));
    Format(szBlockSizeEx, sizeof(szBlockSizeEx), "_%s", szBlockSize);
    Format(szBuffer, sizeof(szBuffer), "models/esko/blockmaker/%s%s.mdl",szBlockType, StrEqual(szBlockSize, "normal")?"":szBlockSizeEx);
    DispatchKeyValue(iBlock, "model", szBuffer);
    DispatchKeyValue(iBlock, "solid", "6");
    if(DispatchSpawn(iBlock))
    {
        float fAngles[3];
        float fOrigin[3];
        GetEntPropVector(iCopy, Prop_Send, "m_angRotation", fAngles);
        GetEntPropVector(iCopy, Prop_Send, "m_vecOrigin", fOrigin);
        fOrigin[2] += 20;
        Format(szBuffer, sizeof(szBuffer), "blockmaker;%s;%s", szBlockType, szBlockSize);
        SetEntPropString(iBlock, Prop_Data, "m_iName", szBuffer);
        TeleportEntity(iBlock, fOrigin, fAngles, NULL_VECTOR);
        SetEntProp(iBlock, Prop_Send, "m_usSolidFlags", 152);
        SetEntProp(iBlock, Prop_Send, "m_CollisionGroup", 8);
        SetEntityRenderMode(iBlock, RENDER_TRANSCOLOR);
        int iIndex = Func_GetFreeIndex();
        arBlockMakerList.Set(iIndex, EntIndexToEntRef(iBlock));
        arBlockMakerData[iIndex].Clear();
        arBlockMakerData[iIndex].Push(0);
        arBlockMakerData[iIndex].Push(0);
        arBlockMakerData[iIndex].PushString(szBlockType);
        arBlockMakerData[iIndex].PushString(szBlockSize);
        Func_VectorToString(fOrigin, szBuffer, sizeof(szBuffer));
        arBlockMakerData[iIndex].PushString(szBuffer);
        Func_VectorToString(fAngles, szBuffer, sizeof(szBuffer));
        arBlockMakerData[iIndex].PushString(szBuffer);
        if(StrEqual(szBlockType, "teleport"))
        {
            SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Teleport);
            GetEntPropString(iCopy, Prop_Data, "m_iGlobalname", szBuffer, sizeof(szBuffer));
            SetEntPropString(iBlock, Prop_Data, "m_iGlobalname", szBuffer);
            arBlockMakerData[iIndex].PushString(szBuffer);
        }
        else if(StrEqual(szBlockType, "bunnyhop"))
        {
            SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_BunnyHop);
            SDKHook(iBlock, SDKHook_EndTouch, EventSDK_OnEndTouch_BunnyHop);
            SDKHook(iBlock, SDKHook_Touch, EventSDK_OnTouch_BunnyHop);
        }
        else if(StrEqual(szBlockType, "autobhop"))
        {
            SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_AutoBhop);
        }
        else if(StrEqual(szBlockType, "death"))
        {
            SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Death);
        }
        else if(StrEqual(szBlockType, "heal"))
        {
            SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Heal);
            SDKHook(iBlock, SDKHook_EndTouch, EventSDK_OnEndTouch_Heal);
        }
        else if(StrEqual(szBlockType, "trampoline"))
        {
            SDKHook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Trampoline);
            GetEntPropString(iCopy, Prop_Data, "m_iGlobalname", szBuffer, sizeof(szBuffer));
            SetEntPropString(iBlock, Prop_Data, "m_iGlobalname", szBuffer);
            arBlockMakerData[iIndex].PushString(szBuffer);
        }
    }
}

public void Func_RemoveBlock(int client)
{
    int iBlock = Func_GetBlock(client);
    if(IsValidEntity(iBlock))
    {
        char szBlockType[32];
        Func_GetBlockType(iBlock, szBlockType, sizeof(szBlockType));
        if(StrEqual(szBlockType, "bunnyhop"))
        {
            SDKUnhook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_BunnyHop);
            SDKUnhook(iBlock, SDKHook_EndTouch, EventSDK_OnEndTouch_BunnyHop);
            SDKUnhook(iBlock, SDKHook_Touch, EventSDK_OnTouch_BunnyHop);
        }
        else if(StrEqual(szBlockType, "teleport"))
        {
            SDKUnhook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Teleport);
        }
        else if(StrEqual(szBlockType, "death"))
        {
            SDKUnhook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Death);
        }
        else if(StrEqual(szBlockType, "trampoline"))
        {
            SDKUnhook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Trampoline);
        }
        else if(StrEqual(szBlockType, "autobhpo"))
        {
            SDKUnhook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_AutoBhop);
        }
        else if(StrEqual(szBlockType, "heal"))
        {
            SDKUnhook(iBlock, SDKHook_StartTouch, EventSDK_OnStartTouch_Heal);
            SDKUnhook(iBlock, SDKHook_EndTouch, EventSDK_OnEndTouch_Heal);
            for(int i = 0; i <= MaxClients; i++)
            {
                if(IsValidClient(i))
                {
                    if(g_hBlockHeal[i] != null)
                    {
                        delete g_hBlockHeal[i];
                        g_hBlockHeal[i] = null;
                    }
                }
            }
        }
        int iIndex = arBlockMakerList.FindValue(EntIndexToEntRef(iBlock));
        if(iIndex != -1)
        {
            arBlockMakerList.Set(iIndex, -1);
            int iDBId = arBlockMakerData[iIndex].Get(BlockDBId);
            if(iDBId > 0)
            {
                arBlockRemoved.Push(iDBId);
            }
            arBlockMakerData[iIndex].Clear();
        }
        AcceptEntityInput(iBlock, "Kill");
    }
}

stock int Func_WaterLevel(int client)
{
    return GetEntProp(client, Prop_Data, "m_nWaterLevel");
}

stock void Func_MoveBlock(int client, const int array, int plus = 0)
{
    int iBlock = Func_GetBlock(client);
    if(IsValidEntity(iBlock))
    {
        float fOrigin[3];
        GetEntPropVector(iBlock, Prop_Send, "m_vecOrigin", fOrigin);
        switch(plus)
        {
            case 0:
            {
                fOrigin[array] -= 0.1;
            }
            case 1:
            {
                fOrigin[array] += 0.1;
            }
        }
        TeleportEntity(iBlock, fOrigin, NULL_VECTOR, NULL_VECTOR);
        int iIndex = arBlockMakerList.FindValue(EntIndexToEntRef(iBlock));
        if(iIndex != -1)
        {
            char szBuffer[128];
            Func_VectorToString(fOrigin, szBuffer, sizeof(szBuffer));
            arBlockMakerData[iIndex].SetString(BlockOrigin, szBuffer);
            arBlockMakerData[iIndex].Set(BlockChanged, 1);
        }
    }
}

stock void Func_SetCvar(const char[] szCvar, const char[] szValue)
{
    ConVar cvar = FindConVar(szCvar);
    if(cvar != null)
    {
        SetConVarString(cvar, szValue, true);
    }
}

public void Func_RotateBlock(int client, const int array)
{
    int iBlock = Func_GetBlock(client);
    if(IsValidEntity(iBlock))
    {
        float fAngles[3];
        GetEntPropVector(iBlock, Prop_Send, "m_angRotation", fAngles);
        if((fAngles[array] + 90.0) == 360.0)
        {
            fAngles[array] = 0.0;
        }
        else
        {
            fAngles[array] += 90.0;
        }
        TeleportEntity(iBlock, NULL_VECTOR, fAngles, NULL_VECTOR);
        int iIndex = arBlockMakerList.FindValue(EntIndexToEntRef(iBlock));
        if(iIndex != -1)
        {
            char szBuffer[128];
            Func_VectorToString(fAngles, szBuffer, sizeof(szBuffer));
            arBlockMakerData[iIndex].SetString(BlockAngles, szBuffer);
            arBlockMakerData[iIndex].Set(BlockChanged, 1);
        }
    }
}

stock void Func_StringToVector(char[] szSource, float fVector[3])
{
    char szSourceEx[3][64];
    ExplodeString(szSource, ";", szSourceEx, sizeof(szSourceEx), sizeof(szSourceEx[]));
    fVector[0] = StringToFloat(szSourceEx[0]);
    fVector[1] = StringToFloat(szSourceEx[1]);
    fVector[2] = StringToFloat(szSourceEx[2]);
}

stock void Func_VectorToString(float fVector[3], char[] szOutput, int len)
{
    Format(szOutput, len, "%f;%f;%f", fVector[0], fVector[1], fVector[2]);
}

stock bool Func_IsVectorZero(float fl[3])
{
    if(fl[0] == 0.0 && fl[1] == 0.0 && fl[2] == 0.0)
    {
        return true;
    }
    return false;
}

stock void Func_GetBlockType(int iBlock, char[] szBlockType, int len)
{
    if(IsValidEntity(iBlock))
    {
        char szBuffer[32];
        char szBufferEx[3][32];
        GetEntPropString(iBlock, Prop_Data, "m_iName", szBuffer, sizeof(szBuffer));
        ExplodeString(szBuffer, ";", szBufferEx, sizeof(szBufferEx), sizeof(szBufferEx[]));
        strcopy(szBlockType, len, szBufferEx[1]);
    }
}

stock void Func_GetBlockSize(int iBlock, char[] szBlockSize, int len)
{
    if(IsValidEntity(iBlock))
    {
        char szBuffer[32];
        char szBufferEx[3][32];
        GetEntPropString(iBlock, Prop_Data, "m_iName", szBuffer, sizeof(szBuffer));
        ExplodeString(szBuffer, ";", szBufferEx, sizeof(szBufferEx), sizeof(szBufferEx[]));
        strcopy(szBlockSize, len, szBufferEx[2]);
    }
}

stock int Func_GetBlock(int client)
{
    int iBlock = GetClientAimTarget(client, false);
    if(IsValidEntity(iBlock))
    {
        char szBuffer[32];
        char szBufferEx[3][32];
        GetEntPropString(iBlock, Prop_Data, "m_iName", szBuffer, sizeof(szBuffer));
        ExplodeString(szBuffer, ";", szBufferEx, sizeof(szBufferEx), sizeof(szBufferEx[]));
        if(strcmp(szBufferEx[0], "blockmaker") == 0)
        {
            return iBlock;
        }
    }
    return -1;
}

stock int Func_GetAimOrigin(int client, float hOrigin[3])
{
    float vAngles[3];
    float fOrigin[3];
    GetClientEyePosition(client,fOrigin);
    GetClientEyeAngles(client, vAngles);
    Handle trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
    if(TR_DidHit(trace))
    {
        TR_GetEndPosition(hOrigin, trace);
        CloseHandle(trace);
        return 1;
    }
    delete trace;
    return 0;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
  return entity > GetMaxClients();
}

public void Func_PrecacheAndDownloadModels()
{
    if(FileExists(sDownloadFilePath) == false)
    {
        SetFailState("%s Unable to find BlockMaker_DownloadList.txt in %s",TAG, sDownloadFilePath);
        return;
    }

    File hDownloadFile = OpenFile(sDownloadFilePath, "r");
    char sDownloadFile[PLATFORM_MAX_PATH];
    int iLen;
    while(hDownloadFile.ReadLine(sDownloadFile, sizeof(sDownloadFile)))
    {
        iLen = strlen(sDownloadFile);
        if(sDownloadFile[iLen-1] == '\n')
        {
            sDownloadFile[--iLen] = '\0';
        }
        TrimString(sDownloadFile);
        if(FileExists(sDownloadFile) == true)
        {
            int iNamelen = strlen(sDownloadFile) - 4;
            if(StrContains(sDownloadFile,".mdl",false) == iNamelen)
            {
                PrecacheModel(sDownloadFile, true);
            }
            AddFileToDownloadsTable(sDownloadFile);
        }
        if(hDownloadFile.EndOfFile())
        {
            break;
        }
    }
    delete hDownloadFile;
}

public void Func_SaveDataToDB()
{
    if(Database_RemoveData())
    {
        if(Database_UpdateData())
        {
            Database_InsertData();
            CPrintToChatAll("%s Data saved", TAG);
        }
    }
}
