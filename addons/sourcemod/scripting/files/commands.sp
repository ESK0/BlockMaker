public Action Command_BlockMaker(int client, int args)
{
    if(IsValidClient(client))
    {
        Menu_OpenBlockMaker(client);
    }
    return Plugin_Handled;
}
