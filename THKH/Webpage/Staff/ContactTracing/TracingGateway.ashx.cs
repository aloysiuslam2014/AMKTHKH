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

        /// <summary>
        /// Picks out the action needed & calls the appropriate methods in the related controller class
        /// </summary>
        /// <param name="context"></param>
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            var action = context.Request.Form["action"];
            var returnoutput = "";
            if (action.Equals("unifiedTrace"))
            {
                var query = context.Request.Form["queries"];
                returnoutput = traceController.unifiedTrace(query);
            }
            if (action.Equals("fillDashboard"))
            {
                var query = context.Request.Form["queries"];
                returnoutput = traceController.fillDashboard(query);
            }
            if (action.Equals("expressTrace")) {
                var query = context.Request.Form["queries"];
                returnoutput = traceController.expressTrace(query);
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