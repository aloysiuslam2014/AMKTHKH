using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace THKH.Webpage.Staff.CheckInOut
{
    /// <summary>
    /// Summary description for checkIn
    /// </summary>
    public class checkIn : IHttpHandler,System.Web.SessionState.IRequiresSessionState
    {

        public void ProcessRequest(HttpContext context)
        {   
            context.Response.ContentType = "text/plain";
         
            var msgg = context.Request.Form["nric"].ToString();

            // Get NRIC & Call Procedure
            string connectionString = null;
            SqlConnection cnn;
            int row = 0;
            connectionString = "Data Source=ALOYSIUS;Initial Catalog=stepwise;Integrated Security=SSPI;";
            cnn = new SqlConnection(connectionString);
            String successString = "{\"Result\":\"Success\",\"Msg\":\""+ msgg +",";
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[SELECT FROM - FindVisitor]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNRIC", msgg);
                command.Parameters.Add("@responseMessage",SqlDbType.NVarChar,250).Direction= ParameterDirection.Output;
                cnn.Open();
                Object[] test;
                
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    test = new Object[reader.FieldCount];
                    while (reader.Read())
                    {

                        reader.GetValues(test);
                        row++;
                        // Get back all the data from Stored Procedure
                    }
                }
                cnn.Close();
                int count = 0;
                foreach (object value in test) {
                    if (count != 0) {
                        successString = successString + ",";
                    }
                    successString = successString + value.ToString();
                    count++;
                }
                successString = successString + "\"}";
                test = new Object[0];
                // Get NRIC-Done, Name, Mobile Number

            }
            catch (Exception ex)
            {
            }
            context.Response.Write(successString);// Json Format
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