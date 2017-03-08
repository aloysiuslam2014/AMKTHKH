using System.Web;
using THKH.Classes.Controller;

namespace THKH.Webpage.Staff.ContactTracing
{
    /// <summary>
    /// Summary description for tracing
    /// </summary>
    public class TracingGateway : IHttpHandler
    {
        private TracingController traceController = new TracingController();

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            var action = context.Request.Form["action"];
            var returnoutput = "";
            if (action.Equals("getValidTerminals"))
            {
                var query = context.Request.Form["queries"];
                returnoutput = traceController.getValidTerminals(query);
            }
            if (action.Equals("traceByReg"))
            {
                var query = context.Request.Form["queries"];
                returnoutput = traceController.traceByReg(query);
            }
            if (action.Equals("unifiedTrace"))
            {
                var query = context.Request.Form["queries"];
                returnoutput = traceController.unifiedTrace(query);
            }
            context.Response.Write(returnoutput);
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