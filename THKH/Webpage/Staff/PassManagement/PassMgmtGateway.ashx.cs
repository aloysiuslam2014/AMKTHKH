using System;
using System.Web;
using System.Dynamic;
using THKH.Classes.Controller;

namespace THKH.Webpage.Staff.PassManagement
{
    /// <summary>
    /// Summary description for passMgmt
    /// </summary>
    public class PassMgmtGateway : IHttpHandler
    {
        PassManagementController passController = new PassManagementController();

        /// <summary>
        /// Picks out the action needed & calls the appropriate methods in the related controller class
        /// </summary>
        /// <param name="context"></param>
        public void ProcessRequest(HttpContext context)
        {
            dynamic returnMe = new ExpandoObject();
            dynamic result = new ExpandoObject();
            string returnString = "";
            var requestType = context.Request.Form["requestType"];
            if (requestType.Equals("generateBar"))
            {
                var textToEnc = context.Request.Form["textEnc"];
                result = passController.generateBarcode(textToEnc);
                returnMe.Result = result.Result;
                returnMe.Msg = result.data;
            }
            if (requestType.Equals("savePassState"))
            {
                var passState = context.Request.Unvalidated.Form["passState"] ;
                var elementsPosition = context.Request.Form["positioning"];
                returnMe.Result = passController.setPassState(passState,elementsPosition);
            }
            if (requestType.Equals("getPassState"))
            {
                result = passController.getPassState();
                returnMe.Result = result.Result;
                returnMe.Msg = result.Msg;//Json object contains: divState(div object holding pass contents) and positions(position offsets of elements within div)
                //
            }
            context.Response.ContentType = "text/plain";
           // If this result has more that success means there is data
            if(returnMe.Result.Equals("Success"))
            {
               
            }else
            {
                returnMe.Msg = returnMe.Result;
            }
            returnString = Newtonsoft.Json.JsonConvert.SerializeObject(returnMe);
            context.Response.Write(returnString);
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