using System;
using System.Web;
using THKH.Classes.Controller;

namespace THKH.Webpage.Staff
{
    /// <summary>
    /// Summary description for masterConfig
    /// </summary>
    public class MasterConfigGateway : IHttpHandler
    {
        MasterConfigController masterConfigController = new MasterConfigController();
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            String successString = "";

            var requestType = context.Request.Form["requestType"];
            if (requestType.ToString() == "updateSettings") {
                var staffUser = context.Request.Form["staffUser"].ToString();
                var lowTemp = context.Request.Form["lowTemp"];
                var highTemp = context.Request.Form["highTemp"];
                var warnTemp = context.Request.Form["warnTemp"];
                var lowTime = context.Request.Form["lowTime"];
                var highTime = context.Request.Form["highTime"];
                var visLim = context.Request.Form["visLim"];
                successString = masterConfigController.updateTempTime(lowTemp, highTemp, warnTemp, lowTime, highTime, staffUser, visLim);
            }
            else if (requestType.ToString() == "getConfig")
            {
                successString = masterConfigController.getConfig();
            }
            else if (requestType.ToString() == "updateProfile")
            {
                var name = context.Request.Form["profileName"];
                var username = context.Request.Form["userName"];
                var permissions = context.Request.Form["permissions"];
                successString = masterConfigController.updateAccessProfile(name, permissions, username);
            }
            else if (requestType.ToString() == "deleteProfile")
            {
                var name = context.Request.Form["profileName"];
                successString = masterConfigController.deleteAccessProfile(name);
            }else if (requestType.ToString() == "getProfiles")
            {
                successString = masterConfigController.getAccessProfile();
            }
            else if (requestType.ToString() == "getSelectedProfile")
            {
                var name = context.Request.Form["profileName"];
                successString = masterConfigController.getSelectedProfile(name);
            }
            context.Response.Write(successString);
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}