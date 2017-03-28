using System;
using System.Web;
using THKH.Classes.Controller;

namespace THKH.Webpage.Staff.SMS
{
    /// <summary>
    /// Summary description for SMSManagement
    /// </summary>
    public class SMSManagementGateway : IHttpHandler
    {
        SMSManagementController smscontroller = new SMSManagementController();

        /// <summary>
        /// Picks out the action needed & calls the appropriate methods in the related controller class
        /// </summary>
        /// <param name="context"></param>
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            String successString = "";

            var requestType = context.Request.Form["requestType"];
            if (requestType == "sendSMS") {
                var numbers = context.Request.Form["numbers"];
                var message = context.Request.Form["message"];
                successString = smscontroller.sendSMS(message, numbers);
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