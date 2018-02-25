public int m_OpenBlockMaker(Menu menu, MenuAction action, int client, int index)
{
  if(action == MenuAction_Select)
  {
    char szItem[16];
    menu.GetItem(index, szItem, sizeof(szItem));
    if(StrEqual(szItem, "addnew", false))
    {
      Menu_CreateNewBlock(client);
    }
    else if(StrEqual(szItem, "edit", false))
    {
      Menu_EditBlock(client);
    }
    else if(StrEqual(szItem, "del", false))
    {
      Func_RemoveBlock(client);
      Menu_OpenBlockMaker(client);
    }
    else if(StrEqual(szItem, "save", false))
    {
      Func_SaveDataToDB();
    }
  }
  else if(action == MenuAction_End)
  {
    delete menu;
  }
}

public int m_CreateNewBlock(Menu menu, MenuAction action, int client, int index)
{
  if(action == MenuAction_Select)
  {
    char szItem[16];
    menu.GetItem(index, szItem, sizeof(szItem));
    float fOrigin[3];
    float fClientOrigin[3];
    Func_GetAimOrigin(client, fOrigin);
    GetClientEyePosition(client, fClientOrigin);
    if(GetVectorDistance(fClientOrigin, fOrigin) < 500)
    {
      if(Func_GetFreeIndex() != -1)
      {
        Func_CreateBlock(client, szItem);
        Menu_EditBlock(client);
      }
      else
      {
        CPrintToChat(client, "%s Block limit is exhausted", TAG);
      }
    }
    else
    {
      CPrintToChat(client, "%s You are looking to far away!", TAG);
      Menu_CreateNewBlock(client);
    }
  }
  else if(action == MenuAction_End)
  {
    delete menu;
  }
  else if(action == MenuAction_Cancel)
  {
    if(index == MenuCancel_ExitBack)
    {
      Menu_OpenBlockMaker(client);
    }
  }
}
public int m_ChangeBlockSize(Menu menu, MenuAction action, int client, int index)
{
  if(action == MenuAction_Select)
  {
    char szBlockSize[32];
    menu.GetItem(index, szBlockSize, sizeof(szBlockSize));
    int iBlock = Func_GetBlock(client);
    if(IsValidEntity(iBlock))
    {
      char szBuffer[PLATFORM_MAX_PATH];
      char szBlockType[32];
      char szBlockSizeEx[32];
      Format(szBlockSizeEx, sizeof(szBlockSizeEx), "_%s", szBlockSize);
      Func_GetBlockType(iBlock, szBlockType, sizeof(szBlockType));
      Format(szBuffer, sizeof(szBuffer), "models/esko/blockmaker/%s%s.mdl",szBlockType, StrEqual(szBlockSize, "normal")?"":szBlockSizeEx);
      SetEntityModel(iBlock, szBuffer);
      Format(szBuffer, sizeof(szBuffer), "blockmaker;%s;%s", szBlockType, szBlockSize);
      SetEntPropString(iBlock, Prop_Data, "m_iName", szBuffer);

      int iIndex = arBlockMakerList.FindValue(EntIndexToEntRef(iBlock));
      if(iIndex != -1)
      {
        arBlockMakerData[iIndex].SetString(BlockSize, szBlockSize);
        arBlockMakerData[iIndex].Set(BlockChanged, 1);
      }
    }
    else
    {
      CPrintToChat(client, "%s This block was not created by BlockMaker!", TAG);
    }
    Menu_ChangeBlockSize(client, iBlock);
  }
  else if(action == MenuAction_End)
  {
    delete menu;
  }
  else if(action == MenuAction_Cancel)
  {
    if(index == MenuCancel_ExitBack)
    {
      Menu_EditBlock(client);
    }
  }
}
public int m_EditBlock(Menu menu, MenuAction action, int client, int index)
{
  if(action == MenuAction_Select)
  {
    int iBlock = Func_GetBlock(client);
    if(IsValidEntity(iBlock))
    {
      char szItem[16];
      menu.GetItem(index, szItem, sizeof(szItem));
      if(StrEqual(szItem, "copy", false))
      {
        Func_CopyBlock(iBlock);
        Menu_EditBlock(client);
      }
      else if(StrEqual(szItem, "size", false))
      {
        Menu_ChangeBlockSize(client, iBlock);
      }
      else if(StrEqual(szItem, "grab", false))
      {
        g_bBlockGrab[client] = !g_bBlockGrab[client];
        Menu_EditBlock(client);
      }
      else if(StrEqual(szItem, "rot", false))
      {
        Menu_RotateBlock(client);
      }
      else if(StrEqual(szItem, "settel", false))
      {
        g_iStoredBlock[client] = EntIndexToEntRef(iBlock);
        Menu_SetTeleportDestination(client);
      }
      else if(StrEqual(szItem, "trppower", false))
      {
        g_iStoredBlock[client] = EntIndexToEntRef(iBlock);
        Menu_SetTrampolinePower(client);
      }
      else if(StrEqual(szItem, "mov", false))
      {
        Menu_MoveBlock(client);
      }
    }
    else
    {
      CPrintToChat(client, "%s This block was not created by BlockMaker!", TAG);
    }
  }
  else if(action == MenuAction_End)
  {
    delete menu;
  }
  else if(action == MenuAction_Cancel)
  {
    if(index == MenuCancel_ExitBack)
    {
      Menu_OpenBlockMaker(client);
    }
  }
}
public int m_SetTeleportDestination(Menu menu, MenuAction action, int client, int index)
{
  if(action == MenuAction_Select)
  {
    int iBlock = EntRefToEntIndex(g_iStoredBlock[client]);
    if(IsValidEntity(iBlock))
    {
      char szItem[16];
      menu.GetItem(index, szItem, sizeof(szItem));
      if(StrEqual(szItem, "set", false))
      {
        int iIndex = arBlockMakerList.FindValue(EntIndexToEntRef(iBlock));
        if(iIndex != -1)
        {
          char szBuffer[128];
          float fOrigin[3];
          GetClientAbsOrigin(client, fOrigin);
          Func_VectorToString(fOrigin, szBuffer, sizeof(szBuffer));
          SetEntPropString(iBlock, Prop_Data, "m_iGlobalname", szBuffer);
          arBlockMakerData[iIndex].SetString(BlockOtherValue, szBuffer);
          arBlockMakerData[iIndex].Set(BlockChanged, 1);
        }
      }
    }
    else
    {
      CPrintToChat(client, "%s This block was not created by BlockMaker!", TAG);
    }
  }
  else if(action == MenuAction_End)
  {
    delete menu;
  }
  else if(action == MenuAction_Cancel)
  {
    if(index == MenuCancel_ExitBack)
    {
      Menu_EditBlock(client);
    }
  }
}
public int m_SetTrampolinePower(Menu menu, MenuAction action, int client, int index)
{
  if(action == MenuAction_Select)
  {
    int iBlock = EntRefToEntIndex(g_iStoredBlock[client]);
    if(IsValidEntity(iBlock))
    {
      char szValue[16];
      menu.GetItem(index, szValue, sizeof(szValue));
      int iIndex = arBlockMakerList.FindValue(EntIndexToEntRef(iBlock));
      if(iIndex != -1)
      {
        SetEntPropString(iBlock, Prop_Data, "m_iGlobalname", szValue);
        arBlockMakerData[iIndex].SetString(BlockOtherValue, szValue);
        arBlockMakerData[iIndex].Set(BlockChanged, 1);
      }
    }
    else
    {
      CPrintToChat(client, "%s This block was not created by BlockMaker!", TAG);
    }
  }
  else if(action == MenuAction_End)
  {
    delete menu;
  }
  else if(action == MenuAction_Cancel)
  {
    if(index == MenuCancel_ExitBack)
    {
      Menu_EditBlock(client);
    }
  }
}
public int m_MoveBlock(Menu menu, MenuAction action, int client, int index)
{
  if(action == MenuAction_Select)
  {
    int iBlock = Func_GetBlock(client);
    if(IsValidEntity(iBlock))
    {
      char szItem[16];
      menu.GetItem(index, szItem, sizeof(szItem));
      if(StrEqual(szItem, "movx+", false))
      {
        Func_MoveBlock(client, 0, 1);
      }
      else if(StrEqual(szItem, "movx-", false))
      {
        Func_MoveBlock(client, 0);
      }
      else if(StrEqual(szItem, "movy+", false))
      {
        Func_MoveBlock(client, 1, 1);
      }
      else if(StrEqual(szItem, "movy-", false))
      {
        Func_MoveBlock(client, 1);
      }
      else if(StrEqual(szItem, "movz+", false))
      {
        Func_MoveBlock(client, 2, 1);
      }
      else if(StrEqual(szItem, "movz-", false))
      {
        Func_MoveBlock(client, 2);
      }
      Menu_MoveBlock(client);
    }
    else
    {
      CPrintToChat(client, "%s This block was not created by BlockMaker!", TAG);
    }
  }
  else if(action == MenuAction_End)
  {
    delete menu;
  }
  else if(action == MenuAction_Cancel)
  {
    if(index == MenuCancel_ExitBack)
    {
      Menu_EditBlock(client);
    }
  }
}

public int m_RotateBlock(Menu menu, MenuAction action, int client, int index)
{
  if(action == MenuAction_Select)
  {
    int iBlock = Func_GetBlock(client);
    if(IsValidEntity(iBlock))
    {
      char szItem[16];
      menu.GetItem(index, szItem, sizeof(szItem));
      if(StrEqual(szItem, "rotx", false))
      {
        Func_RotateBlock(client, 0);
      }
      else if(StrEqual(szItem, "roty", false))
      {
        Func_RotateBlock(client, 1);
      }
      else if(StrEqual(szItem, "rotz", false))
      {
        Func_RotateBlock(client, 2);
      }
      Menu_RotateBlock(client);
    }
    else
    {
      CPrintToChat(client, "%s This block was not created by BlockMaker!", TAG);
    }
  }
  else if(action == MenuAction_End)
  {
    delete menu;
  }
  else if(action == MenuAction_Cancel)
  {
    if(index == MenuCancel_ExitBack)
    {
      Menu_EditBlock(client);
    }
  }
}
