#define TAG "[{Lime}Block{grey}-Maker{default}]"

char sDownloadFilePath[PLATFORM_MAX_PATH];

bool g_bDataLoaded = false;
bool g_bCSGO = false;

bool g_OnceStopped[MAXPLAYERS+1];
int g_iGrabingBlock[MAXPLAYERS+1] = {-1,...};
bool g_bBlockGrab[MAXPLAYERS+1] = {false,...};
int g_iPlayerNewEntity[MAXPLAYERS+1];
float g_fPlayerSelectedBlockDistance[MAXPLAYERS+1];
int g_iPlayerPrevButtons[MAXPLAYERS+1];

int g_iStoredBlock[MAXPLAYERS+1] = {-1,...};
int g_iBunyHopTouch[MAXPLAYERS+1] = {-1,...};

Handle g_hBlockHeal[MAXPLAYERS+1] = {null,...};

ArrayList arBlockMakerList = null;
ArrayList arBlockMakerData[1024] = {null,...};

ArrayList arBlockRemoved = null;

Database g_hDatabase = null;

char szCurrentMap[64];


enum
{
    BlockDBId = 0,
    BlockChanged,
    BlockType,
    BlockSize,
    BlockOrigin,
    BlockAngles,
    BlockOtherValue
};

enum
{
    Db_Id = 0,
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
};
