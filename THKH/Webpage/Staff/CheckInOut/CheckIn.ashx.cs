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
            String successString = "";
            var nric = context.Request.Form["nric"].ToString();
            var temperature = context.Request.Form["temperature"];
            var age = context.Request.Form["AGE"];
            var fname = context.Request.Form["firstName"];
            var lname = context.Request.Form["lastName"];
            var address = context.Request.Form["ADDRESS"];
            var postal = context.Request.Form["POSTAL"];
            var mobtel = context.Request.Form["MobTel"];
            var alttel = context.Request.Form["AltTel"];
            var hometel = context.Request.Form["HomeTel"];
            var sex = context.Request.Form["SEX"];
            var nationality = context.Request.Form["Natl"];
            var dob = context.Request.Form["DOB"];
            var race = context.Request.Form["RACE"];
            var email = context.Request.Form["email"];

            if (temperature != null)
            {
                successString = CheckIn(nric, temperature);
            }
            else if (age != null) {
                successString = AssistReg(nric, age, fname, lname, address, postal, mobtel, alttel, hometel, sex, nationality, dob, race, email);
            }
            else{
                // Get NRIC & Call Procedure
                string connectionString = null;
                SqlConnection cnn;
                int row = 0;
                connectionString = "Data Source=ALOYSIUS;Initial Catalog=stepwise;Integrated Security=SSPI;";
                cnn = new SqlConnection(connectionString);
                successString = "{\"Result\":\"Success\",\"Msg\":\"NRIC:" + nric + "";
                try
                {
                    // Find Visitor Details
                    SqlCommand command = new SqlCommand("[dbo].[SELECT FROM - VisitorDetails]", cnn);
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@pNRIC", nric);
                    command.Parameters.Add("@responseMessage", SqlDbType.NVarChar, 250).Direction = ParameterDirection.Output;
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
                    String[] cols = { "First Name", "Last Name", "Mobile Number" };
                    foreach (object value in test)
                    {
                        successString = successString + "," + cols[count] + ":" + value.ToString();
                        count++;
                    }
                    successString = successString + "\"}";
                    test = new Object[0];
                    // Get NRIC-Done, Name, Mobile Number

                }
                catch (Exception ex)
                {
                }
            }
            context.Response.Write(successString);// Json Format
        }


        private String AssistReg(String nric, String age, String fname, String lname, String address, String postal, String mobtel, String alttel, String hometel, String sex, String nationality, String dob, String race, String email) {
            string connectionString = null;
            SqlConnection cnn;
            int row = 0;
            connectionString = "Data Source=ALOYSIUS;Initial Catalog=stepwise;Integrated Security=SSPI;";
            cnn = new SqlConnection(connectionString);
            String successString = "{\"Result\":\"Success\",\"Msg\":\""; // Reflect Time Checked in - TO BE AMENDED
            try
            {
                // Find Visitor Details
                SqlCommand command = new SqlCommand("[dbo].[INSERT INTO  - Registration]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pFirstName", fname);
                command.Parameters.AddWithValue("@pLastName", lname);
                command.Parameters.AddWithValue("@pNric", nric);
                command.Parameters.AddWithValue("@pAddress", address);
                command.Parameters.AddWithValue("@pPostal", postal);
                command.Parameters.AddWithValue("@pHomeTel", hometel);
                command.Parameters.AddWithValue("@pAltTel", alttel);
                command.Parameters.AddWithValue("@pMobTel", mobtel);
                command.Parameters.AddWithValue("@pEmail", email);
                command.Parameters.AddWithValue("@pSex", sex);
                command.Parameters.AddWithValue("@pNationality", nationality); // Signed in staff_id - TO BE AMENDED
                command.Parameters.AddWithValue("@pDOB", dob); // Visitor's ID - TO BE AMENDED
                command.Parameters.AddWithValue("@pAge", age); //Location ID of terminal - TO BE AMENDED
                command.Parameters.AddWithValue("@prace", race);
                command.Parameters.Add("@pResponseMessage", SqlDbType.NVarChar, 250).Direction = ParameterDirection.Output;
                cnn.Open();
                Object[] test;

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    test = new Object[reader.FieldCount];
                    while (reader.Read())
                    {

                        row++;
                        // Get back all the data from Stored Procedure
                    }
                }
                cnn.Close();
                successString += nric + " Successfully Added as a new Visitor " + DateTime.Now;
                successString += "\"}";

            }
            catch (Exception ex)
            {
                successString += ex.Message;
                successString += "\"}";
            }
            return successString;// Json Format
        }

        private String CheckIn(String nric, String temp) {
            string connectionString = null;
            SqlConnection cnn;
            int row = 0;
            connectionString = "Data Source=ALOYSIUS;Initial Catalog=stepwise;Integrated Security=SSPI;";
            cnn = new SqlConnection(connectionString);
            String successString = "{\"Result\":\"Success\",\"Msg\":\""; // Reflect Time Checked in - TO BE AMENDED
            try
            {
                // Find Visitor Details
                SqlCommand command = new SqlCommand("[dbo].[INSERT INTO  - First_Check_In]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNric", nric);
                command.Parameters.AddWithValue("@pTemperature", temp);
                command.Parameters.AddWithValue("@pStaff_id", 1); // Signed in staff_id - TO BE AMENDED
                command.Parameters.AddWithValue("@pVisit_id", 1); // Visitor's ID - TO BE AMENDED
                command.Parameters.AddWithValue("@pCheckinlid", 0); //Location ID of terminal - TO BE AMENDED
                command.Parameters.Add("@pResponseMessage", SqlDbType.NVarChar, 250).Direction = ParameterDirection.Output;
                cnn.Open();
                Object[] test;

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    test = new Object[reader.FieldCount];
                    while (reader.Read())
                    {

                        row++;
                        // Get back all the data from Stored Procedure
                    }
                }
                cnn.Close();
                successString += nric + " Checked In at " + DateTime.Now;
                successString += "\"}";

            }
            catch (Exception ex)
            {
                successString += ex.Message;
                successString += "\"}";
            }
            return successString;// Json Format
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