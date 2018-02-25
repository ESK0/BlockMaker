public void Database_Connect(Database db, const char[] error, any data)
{
  if (db == null)
  {
  	LogError("Database failure: %s", error);
  }
  else
  {
    g_hDatabase = db;
    Database_CreateTables();
  }
}
public void Database_CreateTables()
{
  if(g_hDatabase != null)
  {
    char szBuffer[2048];
    Format(szBuffer, sizeof(szBuffer), "CREATE TABLE IF NOT EXISTS `blockmaker_blocks` ( `id` INT UNSIGNED NOT NULL AUTO_INCREMENT , `mapname` VARCHAR(255) NOT NULL , `type` VARCHAR(64) NOT NULL DEFAULT 'normal' , `size` ENUM('normal','small','ultrasmall','') NOT NULL DEFAULT 'normal' , `pos_x` FLOAT NULL DEFAULT '0' , `pos_y` FLOAT NULL DEFAULT '0' , `pos_z` FLOAT NULL DEFAULT '0' , `angle_x` FLOAT NULL DEFAULT '0' , `angle_y` FLOAT NULL DEFAULT '0' , `angle_z` FLOAT NULL DEFAULT '0' , `extra_param` VARCHAR(255) NULL DEFAULT NULL , PRIMARY KEY (`id`)) ENGINE = InnoDB;");
    g_hDatabase.Query(Database_OnCreatedTables, szBuffer);
  }
}

public void Database_OnCreatedTables(Database db, DBResultSet results, const char[] error, any data)
{
  if(results == null)
  {
    LogError("[1] Query failed! %s", error);
  }
}
public void Database_LoadData()
{
  arBlockMakerList.Clear();
  arBlockRemoved.Clear();
  for(int i = 0; i < 1000; i++)
  {
    arBlockMakerList.Push(-1);
    arBlockMakerData[i].Clear();
  }
  if(g_hDatabase != null)
  {
    char szBuffer[128];
    Format(szBuffer, sizeof(szBuffer), "SELECT * FROM `blockmaker_blocks` WHERE mapname = '%s'", szCurrentMap);
    g_hDatabase.Query(Database_OnLoadData, szBuffer);
  }
}
/*
BlockDBId = 0,
BlockChanged,
BlockType,
BlockSize,
BlockOrigin,
BlockAngles,
BlockOtherValue
*/


/*
Db_Id,
Db_Mapname,
Db_Type,
Db_Size,
Db_PosX,
Db_PosY,
Db_PosZ,
Db_AngleX,
Db_AngleY,
Db_AngleZ,
Db_Extra,
*/
public void Database_InsertData()
{
  if(g_hDatabase != null)
  {
    char szBuffer[200];
    Format(szBuffer, sizeof(szBuffer), "SELECT `AUTO_INCREMENT` FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'blockmaker_blocks'");
    g_hDatabase.Query(Database_OnInsertDataF, szBuffer);
  }
}
public void Database_OnInsertDataF(Database db, DBResultSet results, const char[] error, any data)
{
  if(results == null)
  {
    LogError("[2] Query failed! %s", error);
  }
  else
  {
    if(results.FetchRow())
    {
      char szBuffer[2048];
      char szBlockType[32];
      char szBlockSize[32];
      char szBlockOrigin[255];
      char szBlockAngle[255];
      char szBlockOtherValue[255];
      float fOrigin[3];
      float fAngle[3];
      int iLastId = results.FetchInt(0);
      for(int i = 0; i < arBlockMakerList.Length; i++)
      {
        if(arBlockMakerList.Get(i) != -1)
        {
          if(arBlockMakerData[i].Get(BlockDBId) == 0)
          {
            arBlockMakerData[i].Set(BlockDBId, iLastId++);
            arBlockMakerData[i].Set(BlockChanged, 0);
            arBlockMakerData[i].GetString(BlockType, szBlockType, sizeof(szBlockType));
            arBlockMakerData[i].GetString(BlockSize, szBlockSize, sizeof(szBlockSize));
            arBlockMakerData[i].GetString(BlockOrigin, szBlockOrigin, sizeof(szBlockOrigin));
            arBlockMakerData[i].GetString(BlockAngles, szBlockAngle, sizeof(szBlockAngle));
            if(StrEqual(szBlockType, "teleport") || StrEqual(szBlockType, "trampoline"))
            {
              arBlockMakerData[i].GetString(BlockOtherValue, szBlockOtherValue, sizeof(szBlockOtherValue));
            }
            else
            {
              Format(szBlockOtherValue, sizeof(szBlockOtherValue), "");
            }
            Func_StringToVector(szBlockOrigin, fOrigin);
            Func_StringToVector(szBlockAngle, fAngle);
            Format(szBuffer, sizeof(szBuffer), "INSERT INTO `blockmaker_blocks` (`mapname`, `type`, `size`, `pos_x`, `pos_y`, `pos_z`, `angle_x`, `angle_y`, `angle_z`, `extra_param`) VALUES ('%s', '%s', '%s', '%f', '%f', '%f', '%f', '%f', '%f', '%s')", szCurrentMap, szBlockType, szBlockSize, fOrigin[0], fOrigin[1], fOrigin[2], fAngle[0], fAngle[1], fAngle[2], szBlockOtherValue);
            g_hDatabase.Query(Database_OnInsertDataS, szBuffer);
          }
        }
      }
    }
  }
}
public void Database_OnInsertDataS(Database db, DBResultSet results, const char[] error, any data)
{
  if(results == null)
  {
    LogError("[3] Query failed! %s", error);
  }
}
public void Database_OnLoadData(Database db, DBResultSet results, const char[] error, any data)
{
  if(results == null)
  {
    LogError("[4] Query failed! %s", error);
  }
  else
  {
    char szBuffer[255];
    float fVector[3];
    while(results.FetchRow())
    {
      int iIndex = Func_GetFreeIndex();
      arBlockMakerList.Set(iIndex, 0);
      int iDbId = results.FetchInt(Db_Id);
      arBlockMakerData[iIndex].Push(iDbId);
      arBlockMakerData[iIndex].Push(0);

      results.FetchString(Db_Type, szBuffer, sizeof(szBuffer));
      arBlockMakerData[iIndex].PushString(szBuffer);

      results.FetchString(Db_Size, szBuffer, sizeof(szBuffer));
      arBlockMakerData[iIndex].PushString(szBuffer);

      fVector[0] = results.FetchFloat(Db_PosX);
      fVector[1] = results.FetchFloat(Db_PosY);
      fVector[2] = results.FetchFloat(Db_PosZ);
      Func_VectorToString(fVector, szBuffer, sizeof(szBuffer));
      arBlockMakerData[iIndex].PushString(szBuffer);

      fVector[0] = results.FetchFloat(Db_AngleX);
      fVector[1] = results.FetchFloat(Db_AngleY);
      fVector[2] = results.FetchFloat(Db_AngleZ);
      Func_VectorToString(fVector, szBuffer, sizeof(szBuffer));
      arBlockMakerData[iIndex].PushString(szBuffer);

      results.FetchString(Db_Extra, szBuffer, sizeof(szBuffer));
      arBlockMakerData[iIndex].PushString(szBuffer);
    }
    g_bDataLoaded = true;
  }
}
public bool Database_RemoveData()
{
  if(g_hDatabase != null)
  {
    for(int i = 0; i < arBlockRemoved.Length; i++)
    {
      char szBuffer[128];
      Format(szBuffer, sizeof(szBuffer), "DELETE FROM `blockmaker_blocks` WHERE id = '%i' AND mapname = '%s'", arBlockRemoved.Get(i), szCurrentMap);
      g_hDatabase.Query(Database_OnDataRemoved, szBuffer);
    }
    arBlockRemoved.Clear();
    return true;
  }
  return false;
}
public void Database_OnDataRemoved(Database db, DBResultSet results, const char[] error, any data)
{
  if(results == null)
  {
    LogError("[5] Query failed! %s", error);
  }
}
public bool Database_UpdateData()
{
  if(g_hDatabase != null)
  {
    char szBuffer[4096];
    char szBlockType[32];
    char szBlockSize[32];
    char szBlockOrigin[255];
    char szBlockAngle[255];
    char szBlockOtherValue[255];
    float fOrigin[3];
    float fAngle[3];
    int iDbId;
    for(int i = 0; i < arBlockMakerList.Length; i++)
    {
      if(arBlockMakerList.Get(i) != -1)
      {
        if(arBlockMakerData[i].Get(BlockChanged) == 1 && arBlockMakerData[i].Get(BlockDBId) != 0)
        {
          iDbId = arBlockMakerData[i].Get(BlockDBId);
          arBlockMakerData[i].Set(BlockChanged, 0);
          arBlockMakerData[i].GetString(BlockType, szBlockType, sizeof(szBlockType));
          arBlockMakerData[i].GetString(BlockSize, szBlockSize, sizeof(szBlockSize));
          arBlockMakerData[i].GetString(BlockOrigin, szBlockOrigin, sizeof(szBlockOrigin));
          arBlockMakerData[i].GetString(BlockAngles, szBlockAngle, sizeof(szBlockAngle));
          if(StrEqual(szBlockType, "teleport") || StrEqual(szBlockType, "trampoline"))
          {
            arBlockMakerData[i].GetString(BlockOtherValue, szBlockOtherValue, sizeof(szBlockOtherValue));
          }
          else
          {
            Format(szBlockOtherValue, sizeof(szBlockOtherValue), "");
          }
          Func_StringToVector(szBlockOrigin, fOrigin);
          Func_StringToVector(szBlockAngle, fAngle);
          Format(szBuffer, sizeof(szBuffer), "UPDATE `blockmaker_blocks` SET `type`='%s',`size`='%s',`pos_x`='%f',`pos_y`='%f',`pos_z`='%f',`angle_x`='%f',`angle_y`='%f',`angle_z`='%f',`extra_param`='%s' WHERE `id` = %i AND `mapname` = '%s'", szBlockType, szBlockSize, fOrigin[0], fOrigin[1], fOrigin[2], fAngle[0], fAngle[1], fAngle[2], szBlockOtherValue, iDbId, szCurrentMap);
          g_hDatabase.Query(Database_OnUpdateData, szBuffer);
        }
      }
    }
    return true;
  }
  return false;
}
public void Database_OnUpdateData(Database db, DBResultSet results, const char[] error, any data)
{
  if(results == null)
  {
    LogError("[6] Query failed! %s", error);
  }
}
