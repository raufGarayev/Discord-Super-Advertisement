
#include <sourcemod>
#include <ripext>
#include <csgo_colors>

ConVar g_cvInvite, g_cvAdInterval;
char g_sInvite[128];
Handle g_Timer;

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
    g_cvInvite = CreateConVar("sm_discord_ad_invite_code", "N4frZV8PRP", "Server invite code / Код приглашения на сервер");
    GetConVarString(g_cvInvite, g_sInvite, sizeof(g_sInvite));
    g_cvAdInterval = CreateConVar("sm_discord_ad_interval", "10.0", "How often will add show in chat (seconds) / Как часто будет показаться реклама в чате (в секундах)")
    AutoExecConfig(true, "discord_advertisement");
    
    HookConVarChange(g_cvInvite, OnSettingChanged);
    HookConVarChange(g_cvAdInterval, OnSettingChanged);

    g_Timer = CreateTimer(GetConVarFloat(g_cvAdInterval), Timer_DisOnline, _, TIMER_REPEAT);
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == g_cvAdInterval)
	{
		if (g_Timer != null)
			KillTimer(g_Timer);
		g_Timer = CreateTimer(GetConVarFloat(g_cvAdInterval), Timer_DisOnline, _, TIMER_REPEAT);
	}
	else if (convar == g_cvInvite)
		strcopy(g_sInvite, sizeof(g_sInvite), newValue);
}

public Action Timer_DisOnline(Handle hTimer)
{
    char szQuery[256];
    FormatEx(szQuery, sizeof(szQuery), "https://discord.com/api/v9/invites/%s?with_counts=true&with_expiration=true", g_sInvite);
    HTTPRequest request = new HTTPRequest(szQuery);

    request.Get(OnOnlReceived);
}

public void OnOnlReceived(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        PrintToServer("UNSUCCESSFULL REQUEST");
        return;
    }

    JSONObject data = view_as<JSONObject>(response.Data);

    CGOPrintToChatAll("%t", "DisAdv", data.GetInt("approximate_presence_count"), data.GetInt("approximate_member_count"), g_sInvite);
}
