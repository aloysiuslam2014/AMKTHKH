using System;
using System.Collections.Generic;
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
                List<String> sendStatus = sendSMS(message, numbers);
                successString = String.Join(",", sendStatus);
            }

            context.Response.Write(successString);
        }

        private List<String> sendSMS(String message, String numbers) {
            //HttpWebRequest req = (HttpWebRequest)WebRequest.Create("https://api.whispir.com/messages?apikey=");
            //req.Headers.Add("Authorization", "Basic ");
            //req.Headers.Add("Content-Type", "application/vnd.whispir.message-v1+json");
            //req.Headers.Add("Accept", "application/vnd.whispir.message-v1+json");
            //String[] numArr = numbers.Split(',');
            //for (int i = 0; i < numArr.Length; i++) {
            //    String json = "{\"to\":" + numArr[i] + ", \"subject\":\"***Ang Mo Kio Thye Hua Kwan Hospital***\", \"body\":" + message + "}";
            //    var streamWriter = new StreamWriter(req.GetRequestStream());
            //    streamWriter.Write(json);
            //    streamWriter.Flush();
            //    streamWriter.Close();
            //    var httpResponse = (HttpWebResponse)req.GetResponse();
            //    using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
            //    {
            //        var result = streamReader.ReadToEnd();
            //    }
            //}        
            List<String> responses = new List<String>();
            string AccountSid = "AC9a49d86e66165ef9470571e0be7c892c";
            string AuthToken = "a750950b96a75c3ab36d4508bfd1db31";
            //HttpWebRequest req = (HttpWebRequest)WebRequest.Create("https://" + AccountSid + ":" + AuthToken + "@api.twilio.com/2010-04-01/Accounts");
            TwilioClient.Init(AccountSid, AuthToken);
            String[] numArr = numbers.Split(',');
            for (int i = 0; i < numArr.Length; i++)
            {
            var to = new PhoneNumber("+65" + numArr[i]);
                try
                {
                    var msg = MessageResource.Create(
                        to,
                        from: new PhoneNumber("+18324632876"),
                        body: message);
                    responses.Add(msg.Sid);
                }
                catch (Exception ex) {
                    responses.Add(ex.Message);
                }
        }
            if (responses.Count() == 0) {
                responses.Add("Failure");
            }
            return responses;
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