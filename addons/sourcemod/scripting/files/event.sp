public Action Event_OnPlayerSpawn(Event event, const char[] name,  bool dontBroadcast)
{
  int client = GetClientOfUserId(event.GetInt("userid"));
  if(IsValidClient(client))
  {
    g_iPlayerNewEntity[client] = -1;
    g_iGrabingBlock[client] = -1;
    g_iStoredBlock[client] = -1;
    g_iBunyHopTouch[client] = -1;
    if(g_hBlockHeal[client] != null)
    {
      delete g_hBlockHeal[client];
      g_hBlockHeal[client] = null;
    }
  }
  return Plugin_Continue;
}
public Action Event_OnPlayerDeath(Event event, const char[] name,  bool dontBroadcast)
{
  int client = GetClientOfUserId(event.GetInt("userid"));
  if(IsValidClient(client))
  {
    g_iGrabingBlock[client] = -1;
    g_iStoredBlock[client] = -1;
    g_iBunyHopTouch[client] = -1;
    g_bBlockGrab[client] = false;
  }
  return Plugin_Continue;
}
public Action Event_OnRoundEnd(Event event, const char[] name,  bool dontBroadcast)
{
  for(int client = 0; client <= MaxClients; client++)
  {
    if(IsValidClient(client))
    {
      g_iGrabingBlock[client] = -1;
      g_bBlockGrab[client] = false;
      g_iStoredBlock[client] = -1;
      g_iBunyHopTouch[client] = -1;
      if(g_hBlockHeal[client] != null)
      {
        delete g_hBlockHeal[client];
        g_hBlockHeal[client] = null;
      }
    }
  }
  return Plugin_Continue;
}
public Action Event_OnRoundStart(Event event, const char[] name,  bool dontBroadcast)
{
  Func_SpawnBlocks();
  return Plugin_Continue;
}
