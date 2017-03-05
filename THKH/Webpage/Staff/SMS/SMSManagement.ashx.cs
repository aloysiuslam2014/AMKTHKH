using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Twilio.Types;

namespace THKH.Webpage.Staff.SMS
{
    /// <summary>
    /// Summary description for SMSManagement
    /// </summary>
    public class SMSManagement : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            String successString = "";

            var requestType = context.Request.Form["requestType"];
            if (requestType == "sendSMS") {
                var numbers = context.Request.Form["numbers"];
                var message = context.Request.Form["message"];
                successString = sendSMS(message, numbers);
            }

            context.Response.Write(successString);
        }

        private String sendSMS(String message, String numbers) {
            List<String> responses = new List<String>();
            string AccountSid = "AC9a49d86e66165ef9470571e0be7c892c";
            string AuthToken = "a750950b96a75c3ab36d4508bfd1db31";
            TwilioClient.Init(AccountSid, AuthToken);
            String[] numArr = numbers.Split(',');
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            for (int i = 0; i < numArr.Length; i++)
            {
                String number = numArr[i];
            var to = new PhoneNumber("+65" + number);
                try
                {
                    var msg = MessageResource.Create(
                        to,
                        from: new PhoneNumber("+18324632876"),
                        body: message);
                    SqlCommand command = new SqlCommand("[dbo].[RECORD_SMS]", cnn);
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@pSID", msg.Sid);
                    command.Parameters.AddWithValue("@pContact", number);
                    command.Parameters.AddWithValue("@pMessage", message);
                    command.Parameters.Add(respon);
                    cnn.Open();

                    command.ExecuteNonQuery();
                    if (respon.Value.ToString() == "0") {
                        responses.Add(msg.Sid);
                    } 
                }
                catch (Exception ex) {
                    responses.Add(ex.Message);
                }
        }
            if (responses.Count() > 1) {
                return String.Join(",", responses);
            }
            return "Success";
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