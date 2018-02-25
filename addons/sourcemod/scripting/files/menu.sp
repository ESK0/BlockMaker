public void Menu_OpenBlockMaker(int client)
{
  Menu menu = new Menu(m_OpenBlockMaker);
  menu.SetTitle("E' BlockMaker");
  menu.AddItem("addnew", "Create new block");
  menu.AddItem("edit", "Edit block");
  menu.AddItem("del", "Remove block");
  menu.AddItem("save", "Save Data !! Careful");
  menu.ExitButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void Menu_EditBlock(int client)
{
  char szBuffer[32];
  char szBlockType[32];
  int iBlock = Func_GetBlock(client);
  Func_GetBlockType(iBlock, szBlockType, sizeof(szBlockType));
  Menu menu = new Menu(m_EditBlock);
  menu.SetTitle("E' BlockMaker: Edit");

  menu.AddItem("copy", "Copy Block");
  menu.AddItem("size", "Change size");
  Format(szBuffer, sizeof(szBuffer), "Grab block [%s]", g_bBlockGrab[client]?"ENABLED":"DISABLED");
  menu.AddItem("grab", szBuffer);
  if(strcmp(szBlockType, "teleport") == 0)
  {
    menu.AddItem("settel", "Set teleport destination");
  }
  else if(strcmp(szBlockType, "trampoline") == 0)
  {
    menu.AddItem("trppower", "Trampoline power");
  }
  menu.AddItem("rot", "Rotate block");
  menu.AddItem("mov", "Move block");
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void Menu_RotateBlock(int client)
{
  Menu menu = new Menu(m_RotateBlock);
  menu.SetTitle("E' BlockMaker: Rotate");
  menu.AddItem("rotx", "Rotate: X");
  menu.AddItem("roty", "Rotate: Y");
  menu.AddItem("rotz", "Rotate: Z");
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void Menu_SetTeleportDestination(int client)
{
  Menu menu = new Menu(m_SetTeleportDestination);
  menu.SetTitle("E' BlockMaker: Teleport Destination");
  menu.AddItem("set", "Set teleport");
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void Menu_SetTrampolinePower(int client)
{
  Menu menu = new Menu(m_SetTrampolinePower);
  menu.SetTitle("E' BlockMaker: Trampoline power");
  menu.AddItem("300", "300");
  menu.AddItem("325", "325");
  menu.AddItem("350", "350");
  menu.AddItem("400", "400");
  menu.AddItem("500", "500");
  menu.AddItem("800", "800");
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void Menu_MoveBlock(int client)
{
  Menu menu = new Menu(m_MoveBlock);
  menu.SetTitle("E' BlockMaker: Move");
  menu.AddItem("movx+", "Move: X+");
  menu.AddItem("movx-", "Move: X-");
  menu.AddItem("movy+", "Move: Y+");
  menu.AddItem("movy-", "Move: Y-");
  menu.AddItem("movz+", "Move: Z+");
  menu.AddItem("movz-", "Move: Z-");
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void Menu_CreateNewBlock(int client)
{
  Menu menu = new Menu(m_CreateNewBlock);
  menu.SetTitle("E' BlockMaker: Create new block");
  menu.AddItem("normal", "Normal");
  menu.AddItem("bunnyhop", "Bunny Hop");
  menu.AddItem("autobhop", "Auto Bhop");
  menu.AddItem("teleport", "Teleport");
  menu.AddItem("heal", "Heal");
  menu.AddItem("death", "Death");
  menu.AddItem("nofalldamage", "No Fall Damage");
  menu.AddItem("trampoline", "Trampoline");
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void Menu_ChangeBlockSize(int client, int iBlock)
{
  char szModelSize[32];
  Func_GetBlockSize(iBlock, szModelSize, sizeof(szModelSize));
  Menu menu = new Menu(m_ChangeBlockSize);
  menu.SetTitle("E' BlockMaker: Change size");
  menu.AddItem("normal", "Normal", strcmp(szModelSize, "normal") == 0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
  menu.AddItem("small", "Small", strcmp(szModelSize, "small") == 0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
  menu.AddItem("ultrasmall", "Ultra small", strcmp(szModelSize, "ultrasmall") == 0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
