using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Webpage.Staff.CheckInOut
{
    /// <summary>
    /// Summary description for CheckIn
    /// </summary>
    public class CheckIn : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("Hello World");
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