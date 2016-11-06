using System;
using System.Collections.Generic;
using System.Data;
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
            var success = false;
            var action = context.Request.Form["action"];
            var msgg = context.Request.Form["id"];
            if (action.Equals("activate"))
            {
                success = activateTerminal(msgg);
            }
            else if(action.Equals("checkIn"))
            {
                var userNric = context.Request.Form["user"];
                success = checkInUser(msgg, userNric);
            }
            else if (action.Equals("verify"))
            {
                var userNric = context.Request.Form["user"];
                success = verify(userNric);

            }else{
                deactivateTerminal(msgg);
            }
            context.Response.ContentType = "text/plain";
            if (success)
            {
                context.Response.Write("success");
            }
            else{
                context.Response.Write("failed");
            }
            

        }

        public bool verify(String id)
        {
            string connectionString = null;
            bool success = false;
           
            SqlConnection cnn;
            connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            //connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["onlineConnection"].ConnectionString);
            Object[] test;
            SqlParameter respon = new SqlParameter("@resp", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[Find Staff]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@id", id);
                
                command.Parameters.Add(respon);
                cnn.Open();
                command.ExecuteNonQuery();


                //rows = command.ExecuteNonQuery();


                cnn.Close();

            }
            catch (Exception ex)
            {

            }

            if (respon.Value.ToString().Equals("1"))
            {
                success = true;
            }
            else
            {
                success = false;
            }

            return success;
        }

        public bool activateTerminal(String id)
        {
            string connectionString = null;
            bool success = false;
            int locationId=Convert.ToInt32(id);
            SqlConnection cnn;
            connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            //connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["onlineConnection"].ConnectionString);
            Object[] test =new Object[1];
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE FROM - Locations]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@ID", locationId);
                cnn.Open();

                
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    test = new Object[reader.FieldCount];
                    while (reader.Read())
                    {

                        reader.GetValues(test);
                        
                        //Get txtPwd with Salt using SHA2-512 & compare hash values
                    }
                }
                //rows = command.ExecuteNonQuery();


                cnn.Close();

            }
            catch (Exception ex)
            {

            }
            var terminalActivated = Convert.ToInt32(test[0]);

            success = terminalActivated == 1 ? true : false;

            return success;
        }

        public bool checkInUser(String locationId, String userId)
        {
            string connectionString = null;
            bool success = false;
            int id = Convert.ToInt32(locationId);
            SqlConnection cnn;
            connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            //connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["onlineConnection"].ConnectionString);
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
            return success;
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