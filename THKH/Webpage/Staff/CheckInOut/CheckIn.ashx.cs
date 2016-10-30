using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Webpage.Staff.CheckInOut
{
    /// <summary>
    /// Summary description for checkIn
    /// </summary>
    public class checkIn : IHttpHandler,System.Web.SessionState.IRequiresSessionState
    {

        public void ProcessRequest(HttpContext context)
        {   
            context.Response.ContentType = "text/plain";
         
            var msgg = context.Request.Form["messages"];
            String successString = "{\"Result\":\"Success\",\"Msg\":\""+ msgg + "\"}";
            context.Response.Write(successString);//Json Format
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