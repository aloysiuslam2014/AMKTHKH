using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;

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
            }

            context.Response.Write(successString);
        }

        private String sendSMS(String message, String numbers) {
            HttpWebRequest req = (HttpWebRequest)WebRequest.Create("https://api.whispir.com/messages?apikey=");
            req.Headers.Add("Authorization", "Basic ");
            req.Headers.Add("Content-Type", "application/vnd.whispir.message-v1+json");
            req.Headers.Add("Accept", "application/vnd.whispir.message-v1+json");
            String[] numArr = numbers.Split(',');
            for (int i = 0; i < numArr.Length; i++) {
                String json = "{\"to\":" + numArr[i] + ", \"subject\":\"***Ang Mo Kio Thye Hua Kwan Hospital***\", \"body\":" + message + "}";
                var streamWriter = new StreamWriter(req.GetRequestStream());
                streamWriter.Write(json);
                streamWriter.Flush();
                streamWriter.Close();
                var httpResponse = (HttpWebResponse)req.GetResponse();
                using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
                {
                    var result = streamReader.ReadToEnd();
                }
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