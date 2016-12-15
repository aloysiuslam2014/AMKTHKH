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
                success = deactivateTerminal(msgg);
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
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            Object[] test;
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[VERIFY_STAFF]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pEmail", id);
                
                command.Parameters.Add(respon);
                cnn.Open();
                command.ExecuteNonQuery();


                //rows = command.ExecuteNonQuery();


                cnn.Close();

            }
            catch (Exception ex)
            {
                var d = ex;//to read any errors
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
          //string connectionString = null;
            bool success = false;
            int locationId=Convert.ToInt32(id);
            SqlConnection cnn;
           // connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            //connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[ACTIVATE_TERMINAL]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pTerminal_Id", locationId);
                command.Parameters.Add(respon);
                cnn.Open();

                
                using (SqlDataReader reader = command.ExecuteReader())
                {
                   
                    while (reader.Read())
                    {

                        
                        //Get txtPwd with Salt using SHA2-512 & compare hash values
                    }
                }
                //rows = command.ExecuteNonQuery();


                cnn.Close();

            }
            catch (Exception ex)
            {
                var a= ex;
            }
         

            success = respon.Value.ToString().Equals("1") ? true : false;

            return success;
        }

        public bool deactivateTerminal(String id)
        {
            //string connectionString = null;
            bool success = false;
            int locationId = Convert.ToInt32(id);
            SqlConnection cnn;
            // connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            //connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[DEACTIVATE_TERMINAL]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pTerminal_Id", locationId);
                command.Parameters.Add(respon);
                cnn.Open();


                using (SqlDataReader reader = command.ExecuteReader())
                {
                    
                    while (reader.Read())
                    {

                        
                        //Get txtPwd with Salt using SHA2-512 & compare hash values
                    }
                }
                //rows = command.ExecuteNonQuery();


                cnn.Close();

            }
            catch (Exception ex)
            {

            }


            success = respon.Value.ToString().Equals("1") ? true : false;

            return success;

        }

        public bool checkInUser(String locationId, String userId)
        {
          //  string connectionString = null;
            bool success = false;
            int id = Convert.ToInt32(locationId);
            SqlConnection cnn;
           // connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            //connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[CREATE_MOVEMENT]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pLocationId", locationId);
                command.Parameters.AddWithValue("@pNRIC", locationId);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();

                //rows = command.ExecuteNonQuery();


                cnn.Close();

            }
            catch (Exception ex)
            {

            }

            success = respon.Value.ToString().Equals("1") ? true : false;

            return success;
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