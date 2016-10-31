using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace THKH.Webpage.Staff.TerminalCalls
{
    /// <summary>
    /// Summary description for TerminalCheck
    /// </summary>
    public class TerminalCheck : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {

        public void ProcessRequest(HttpContext context)
        {
            var action = context.Request.Form["action"];
            var msgg = context.Request.Form["id"];
            if (action.Equals("activate"))
            {
                activateTerminal(msgg);
            }
            else if(action.Equals("checkIn"))
            {
                var userNric = context.Request.Form["user"];
                checkInUser(msgg, userNric);
            }
            else  
            {
                deactivateTerminal(msgg);
            }
            context.Response.ContentType = "text/plain";
            context.Response.Write("success");

        }

        public void activateTerminal(String id)
        {
            string connectionString = null;
            int locationId=Convert.ToInt32(id);
            SqlConnection cnn;
            connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=stepwise;Integrated Security=SSPI;";
            //connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=stepwise;Integrated Security=SSPI;";
            cnn = new SqlConnection(connectionString);
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE FROM - Locations]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@ID", locationId);
                cnn.Open();

                command.ExecuteNonQuery();
                 
                //rows = command.ExecuteNonQuery();


                cnn.Close();

            }
            catch (Exception ex)
            {

            }
        }

        public void checkInUser(String locationId, String userId)
        {
            string connectionString = null;
            int id = Convert.ToInt32(locationId);
            SqlConnection cnn;
            connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=stepwise;Integrated Security=SSPI;";
            //connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=stepwise;Integrated Security=SSPI;";
            cnn = new SqlConnection(connectionString);
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE FROM - Locations]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@locationId", locationId);
                command.Parameters.AddWithValue("@Nric", locationId);
                cnn.Open();

                command.ExecuteNonQuery();

                //rows = command.ExecuteNonQuery();


                cnn.Close();

            }
            catch (Exception ex)
            {

            }
        }

        public void deactivateTerminal(String id)
        {
           int d =  Convert.ToInt32(id);
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