#pragma semicolon 1
#pragma newdecls required;

#include <sourcemod>
#include <vip_core>

ConVar	cv_ServerDNS;
ConVar	cv_GiveVIP;
ConVar	cv_GroupType;
ConVar	cv_ShowAds;

public Plugin myinfo =
{
	name = "[VIP] DNS",
	author = "TTony",
	version = "1.0.3"
};


public void OnPluginStart()
{
    HookEvent("round_start",			Event_RoundStart,			EventHookMode_PostNoCopy);

    cv_ServerDNS = CreateConVar("sm_vip_goldmember_serverdns", "SERVER.DNS.COM", "Server's DNS to get Free VIP", FCVAR_NOTIFY);
	cv_GiveVIP = CreateConVar("sm_vip_goldmember_givevip", "1", "Give free VIP to goldmembers? 1 = Yes, 0 = No", FCVAR_NOTIFY);
	cv_GroupType = CreateConVar("vip_goldmember_group", "VIP GROUP", "VIP Group to get", FCVAR_NOTIFY);
	cv_ShowAds = CreateConVar("sm_sm_goldmember_showads", "90.0", "Show messages about goldmember? If yes, enter a float value of how often should these ads be shown, either enter 0.0 to disable this option", FCVAR_NOTIFY);

	AutoExecConfig(true, "vip_dns", "vip");

    if(cv_ShowAds.FloatValue > 0.0)
        CreateTimer(cv_ShowAds.FloatValue, Timer_Ads, _, TIMER_REPEAT);
	
	LoadTranslations("vip_core.phrases");
}

bool HasDNS(int client)
{
    char PlayerName[32], buffer[32];
    cv_ServerDNS.GetString(buffer, sizeof(buffer));
    GetClientName(client, PlayerName, sizeof(PlayerName));

    if(StrContains(PlayerName, buffer, false) > -1)
        return true;
    else
        return false;
}

public Action Timer_Ads(Handle timer, any client)
{
    char DNSbuffer[32];
    cv_ServerDNS.GetString(DNSbuffer, sizeof(DNSbuffer));

    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && !IsFakeClient(i) && !HasDNS(i))
        {   
            PrintToChat(i, " \x10>> GOLD \x01Add \x07%s \x01to your NAME to get \x07FREE VIP", DNSbuffer);
            PrintToChat(i, " \x10>> GOLD \x01Adauga \x07%s \x01in NUMELE tau pentru a primi \x07VIP GRATUIT", DNSbuffer);     
        }
    }
}

public void Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{	
	if (cv_GiveVIP.IntValue == 1)
	{
		char buffer[32];
    	cv_GroupType.GetString(buffer, sizeof(buffer));

		for(int iClient = 1; iClient <= MaxClients; iClient++)
		{	
            char VipGroup[64];

            if(IsClientInGame(iClient) && !IsFakeClient(iClient)){

                if(VIP_IsClientVIP(iClient)){
			        VIP_GetClientVIPGroup(iClient, VipGroup, sizeof(VipGroup));
                }

                if(HasDNS(iClient) && !VIP_IsClientVIP(iClient))
			    {	
				    VIP_GiveClientVIP(0, iClient, 0, buffer, false);
			    } 

                if(VIP_IsClientVIP(iClient) && StrEqual(VipGroup, buffer) && !HasDNS(iClient))
			    {	
				    VIP_RemoveClientVIP2(0, iClient, false, false);
			    }
            }			
		}
	}
}
