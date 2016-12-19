using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Webpage.Staff.QuestionaireManagement
{
    /// <summary>
    /// Summary description for questionaireManagement
    /// </summary>
    public class questionaireManagement : IHttpHandler
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