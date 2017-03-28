using System;
using System.Web;
using THKH.Classes.Controller;

namespace THKH.Webpage.Staff.TerminalCalls
{
    /// <summary>
    /// Summary description for TerminalCheck
    /// </summary>
    public class TerminalCheckGateway : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        private TerminalManagementController terminalController = new TerminalManagementController();

        /// <summary>
        /// Picks out the action needed & calls the appropriate methods in the related controller class
        /// </summary>
        /// <param name="context"></param>
        public void ProcessRequest(HttpContext context)
        {
            var success = "false";
            var action = context.Request.Form["action"];
            var msgg = context.Request.Form["id"];
            if (action.Equals("activate"))
            {
                success = terminalController.activateTerminal(msgg);
            }
            else if (action.Equals("checkIn"))
            {
                var userNric = context.Request.Form["user"];
                success = terminalController.checkInUser(msgg, userNric);
            }
            else if (action.Equals("verify"))
            {
                var userNric = context.Request.Form["user"];
                success = terminalController.verify(userNric);

            }
            else if (action.Equals("addTerminal"))
            {
                var bedNoList = context.Request.Form["bedList"];
                var infectious = context.Request.Form["isInfectious"];

                success = terminalController.addTerminal(msgg,bedNoList, infectious);

            }
           
            else if (action.Equals("getAllTerminals"))
            {

                success = terminalController.getAllTerminals();

            }
            else if (action.Equals("deleteTerminals"))
            {

                success = terminalController.deleteTerminal(msgg);

            }
            else if (action.Equals("deactivateAllTerminals"))
            {

                success = terminalController.deactivateAllTerminal(msgg);

            }
            else if (action.Equals("deleteAllTerminals"))
            {

                success = terminalController.deleteAllTerminals(msgg);

            }
            else { 
                success = terminalController.deactivateTerminal(msgg);
            }
            context.Response.ContentType = "text/plain";
            if (!success.Equals("false"))
            {
                if (!success.Equals("true"))
                {
                    context.Response.Write(success);
                   
                }
                else
                {
                    context.Response.Write("success");
                }
                
            }
            else{
                context.Response.Write("failed");
            }

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