
#include <sourcemod>
#include <ripext>
#include <csgo_colors>

ConVar g_cvServerID, g_cvBotToken, g_cvAdInterval;
char g_sServerID[128], g_sBotToken[128];


public Plugin myinfo = 
{
    name = "Discord Super Advertisement",
    author = "GARAYEV",
    description = "Discord advertisement in server",
    url = "www.garayev-sp.ru & Discord: GARAYEV#9999",
    version = "1.0"
}

public void OnPluginStart()
{
    LoadTranslations("discord_advertisement.phrases");
    (g_cvServerID = CreateConVar("sm_discord_ad_server_id", "", "Server ID (Guild ID) of your discord server / ID дискорд сервера")).AddChangeHook(OnAdCvarsChanged);
    (g_cvBotToken = CreateConVar("sm_discord_ad_bot_token", "", "Bot token to track info from discord server / Токен бота который будет выдать информацию от сервера")).AddChangeHook(OnAdCvarsChanged);
    (g_cvAdInterval = CreateConVar("sm_discord_ad_interval", "60.0", "How often will add show in chat (seconds) / Как часто будет показаться реклама в чате (в секундах)")).AddChangeHook(OnAdCvarsChanged);
    AutoExecConfig(true, "discord_advertisement");

    CreateTimer(GetConVarFloat(g_cvAdInterval), Timer_DisOnline, _, TIMER_REPEAT);
    CreateTimer(GetConVarFloat(g_cvAdInterval), Timer_DisMax, _, TIMER_REPEAT);
}

public void OnAdCvarsChanged(ConVar CV, const char[] oldValue, const char[] newValue)
{
    if(CV == g_cvServerID)
	{
		strcopy(g_sServerID, sizeof(g_sServerID), newValue);
	}
    else if(CV == g_cvBotToken)
    {
        strcopy(g_sBotToken, sizeof(g_sBotToken), newValue);
    }
}

public Action Timer_DisOnline(Handle hTimer)
{
    char szQuery[256];
    FormatEx(szQuery, sizeof(szQuery), "https://discord.com/api/guilds/%s/widget.json", g_sServerID);
    HTTPRequest request = new HTTPRequest(szQuery);

    request.Get(OnOnlReceived);
}

public Action Timer_DisMax(Handle hTimer)
{
    char szQuery[256];
    FormatEx(szQuery, sizeof(szQuery), "https://discord.com/api/guilds/%s/members?limit=1000", g_sServerID);
    HTTPRequest request = new HTTPRequest(szQuery);

    request.SetHeader("Authorization", "Bot %s", g_sBotToken);

    request.Get(OnMemReceived);
}

public void OnMemReceived(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        PrintToServer("UNSUCCESSFULL REQUEST");
        return;
    }

    // Indicate that the response contains a JSON array
    JSONArray datas = view_as<JSONArray>(response.Data);
    int numDatas = datas.Length;

    JSONObject data;

    for (int i = 0; i < numDatas; i++) {
        data = view_as<JSONObject>(datas.Get(i));

        delete data
    } 
    CGOPrintToChatAll("%t", "DisMax", numDatas);
}

public void OnOnlReceived(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        PrintToServer("UNSUCCESSFULL REQUEST");
        return;
    }

    JSONObject data = view_as<JSONObject>(response.Data);

    char invite[128];
    data.GetString("instant_invite", invite, sizeof(invite));

    CGOPrintToChatAll("%t", "DisOnline", data.GetInt("presence_count"), invite);
}