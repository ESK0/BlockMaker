public void Grab_FirstTimePress(int client)
{
    g_iGrabingBlock[client] = Func_GetBlock(client);
    int iBlock = g_iGrabingBlock[client];
    if(IsValidEntity(iBlock))
    {
        g_OnceStopped[client] = true;
        float fEntOrigin[3];
        float fClientOrigin[3];
        float fAimOrigin[3];
        if(!IsValidEntity(g_iPlayerNewEntity[client]))
        {
            g_iPlayerNewEntity[client] = CreateEntityByName("prop_dynamic");
        }
        Func_GetAimOrigin(client, fAimOrigin);
        TeleportEntity(g_iPlayerNewEntity[client], fAimOrigin, NULL_VECTOR, NULL_VECTOR);
        GetEntPropVector(iBlock, Prop_Send, "m_vecOrigin", fEntOrigin);
        SetVariantString("!activator");
        AcceptEntityInput(iBlock, "SetParent", g_iPlayerNewEntity[client], iBlock, 0);
        GetClientEyePosition(client, fClientOrigin);
        g_fPlayerSelectedBlockDistance[client] = GetVectorDistance(fClientOrigin, fEntOrigin);
        if(g_fPlayerSelectedBlockDistance[client] > 250.0)
        {
            g_fPlayerSelectedBlockDistance[client] = 250.0;
        }
    }
}

public void Grab_StillPressingButton(int client, int &iButtons)
{
    int iWepapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    if(IsValidEntity(iWepapon))
    {
        SetEntPropFloat(iWepapon, Prop_Data, "m_flNextPrimaryAttack", GetGameTime()+1);
        SetEntPropFloat(iWepapon, Prop_Data, "m_flNextSecondaryAttack", GetGameTime()+1);
    }
    if(iButtons & IN_ATTACK)
    {
        g_fPlayerSelectedBlockDistance[client] += 0.3;
    }
    else if (iButtons & IN_ATTACK2)
    {
        g_fPlayerSelectedBlockDistance[client] -= 0.3;
    }
    Grab_MoveBlock(client);
}

public void Grab_MoveBlock(int client)
{
    int iBlock = g_iGrabingBlock[client];
    if(IsValidEntity(iBlock) && IsValidEntity(g_iPlayerNewEntity[client]))
    {
        float fEntOrigin[3];
        GetEntPropVector(g_iPlayerNewEntity[client], Prop_Send, "m_vecOrigin", fEntOrigin);
        float fClientOrigin[3];
        GetClientEyePosition(client, fClientOrigin);
        float fClientAngles[3];
        GetClientEyeAngles(client, fClientAngles);
        float fFinal[3];
        Grab_AddInFrontOf(fClientOrigin, fClientAngles, g_fPlayerSelectedBlockDistance[client], fFinal);
        TeleportEntity(g_iPlayerNewEntity[client], fFinal, NULL_VECTOR, NULL_VECTOR);
    }
}

public void Grab_StoppedMovingBlock(int client)
{
    int iBlock = g_iGrabingBlock[client];
    if(IsValidEntity(iBlock) && IsValidEntity(g_iPlayerNewEntity[client]))
    {
        g_OnceStopped[client] = false;
        SetVariantString("!activator");
        AcceptEntityInput(iBlock, "ClearParent");
        AcceptEntityInput(g_iPlayerNewEntity[client], "kill");
        g_iPlayerNewEntity[client] = -1;
        int iIndex = arBlockMakerList.FindValue(EntIndexToEntRef(iBlock));
        if(iIndex != -1)
        {
            char szBuffer[128];
            float fOrigin[3];
            GetEntPropVector(iBlock, Prop_Send, "m_vecOrigin", fOrigin);
            Func_VectorToString(fOrigin, szBuffer, sizeof(szBuffer));
            arBlockMakerData[iIndex].SetString(BlockOrigin, szBuffer);
            arBlockMakerData[iIndex].Set(BlockChanged, 1);
        }
    }
}

stock void Grab_AddInFrontOf(float vecOrigin[3], float vecAngle[3], float units, float output[3])
{
    float vecAngVectors[3];
    vecAngVectors = vecAngle; //Don't change input
    GetAngleVectors(vecAngVectors, vecAngVectors, NULL_VECTOR, NULL_VECTOR);
    for (int i; i < 3; i++)
    {
        output[i] = vecOrigin[i] + (vecAngVectors[i] * units);
    }
}
