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
            var xAxisHeaders = context.Request.Form["xAxis"]; //Retrieve data in this manner
            var yAxisHeaders = context.Request.Form["yAxis"];
            var chartType = context.Request.Form["chartType"];
            String successString = "{\"Result\":\"Success\",\"Path\":\"\"}";
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