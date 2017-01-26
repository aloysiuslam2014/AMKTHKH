using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;

namespace THKH.Webpage.Staff
{
    /// <summary>
    /// Summary description for masterConfig
    /// </summary>
    public class masterConfig : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            String successString = "";

            var requestType = context.Request.Form["requestType"];
            if (requestType.ToString() == "updateSettings") {
                var staffUser = context.Request.Form["staffUser"].ToString();
                var lowTemp = context.Request.Form["lowTemp"];
                var highTemp = context.Request.Form["highTemp"];
                var lowTime = context.Request.Form["lowTime"];
                var highTime = context.Request.Form["highTime"];
                successString = updateTempTime(lowTemp, highTemp, lowTime, highTime, staffUser);
            }
            context.Response.Write(successString);
        }

        private String updateTempTime(String lowTemp, String highTemp, String lowTime, String highTime, String staffUser) {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":\"";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE_CONFIG]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pLowTemp", lowTemp);
                command.Parameters.AddWithValue("@pHighTemp", highTemp);
                command.Parameters.AddWithValue("@pLowTime", lowTime);
                command.Parameters.AddWithValue("@pHighTime", highTime);
                command.Parameters.AddWithValue("@pUpdatedBy", staffUser);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                successString += respon.Value;
            }
            catch (Exception ex)
            {
                successString.Replace("Success", "Failure");
                successString += ex.Message;
                successString += "\"}";
                return successString;
            }
            finally
            {
                cnn.Close();
            }
            successString += "\"}";
            return successString;
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