using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Webpage.Staff
{
    /// <summary>
    /// Summary description for masterConfig
    /// </summary>
    public class masterConfig : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            String successString = "";

            var requestType = context.Request.Form["requestType"];
            updateTempRange();
            updateVisitTimeRange();
        }

        private String updateTempRange() {
            return "";
        }

        private String updateVisitTimeRange() {
            return "";
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