﻿using System;
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
            var fname = context.Request.Form["firstName"];// Full name
            //var lname = context.Request.Form["lastName"];
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
            var purpose = context.Request.Form["PURPOSE"];
            var pName = context.Request.Form["pName"];
            var pNric = context.Request.Form["pNric"];
            var otherPurpose = context.Request.Form["otherPurpose"];
            var bedno = context.Request.Form["bedno"];
            var appTime = context.Request.Form["appTime"];
            var fever = context.Request.Form["fever"];
            var symptoms = context.Request.Form["symptoms"];
            var influenza = context.Request.Form["influenza"];
            var countriesTravelled = context.Request.Form["countriesTravelled"];
            var remarks = context.Request.Form["remarks"];
            var visitLocation = context.Request.Form["visitLocation"];
            var typeOfRequest = context.Request.Form["requestType"];
            if (typeOfRequest == "getdetails") {
                successString = getVisitorDetails(nric);
            }
            if (typeOfRequest == "self")
            {
                // Write to Visitor_Profile & Visit Table
                successString = selfReg(nric, age, fname, address, postal, mobtel, alttel, hometel,
            sex, nationality, dob, race, email, purpose, pName, pNric, otherPurpose, bedno, appTime,
            fever, symptoms, influenza, countriesTravelled, remarks, visitLocation);
            }
        if (typeOfRequest == "confirmation") {
                // Write to Visitor_Profile, Visit, Confirmed & CheckInCheckOut Tables
                successString = AssistReg(nric, age, fname, address, postal, mobtel, alttel, hometel,
            sex, nationality, dob, race, email, purpose, pName, pNric, otherPurpose, bedno, appTime,
            fever, symptoms, influenza, countriesTravelled, remarks, visitLocation, temperature);
            }
            context.Response.Write(successString);// String to return to front-end
        }

        private String getVisitorDetails(String nric) {
            String connectionString = null;
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":\"";
            connectionString = "Data Source=ALOYSIUS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            //cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["onlineConnection"].ConnectionString);
            cnn = new SqlConnection(connectionString);
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[SELECT FROM - GET_VISITOR]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNRIC", nric);
                command.Parameters.Add("@responseMessage", SqlDbType.Int).Direction = ParameterDirection.Output;
                command.Parameters.Add("@returnValue", SqlDbType.VarChar, -1).Direction = ParameterDirection.Output;
                cnn.Open();

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    bool fields = reader.HasRows; // Rows Returned
                    while (reader.Read())
                    {
                        // Get result string in the following format "header:value"
                        // Append each headername:value to success string
                        String resultString = reader["@returnValue"].ToString();
                    }
                }
                successString += "\"}";

            }
            catch (Exception ex)
            {
                successString += ex.Message;
                successString += "\"}";
            }
            finally
            {
                cnn.Close();
            }
            return successString;
        }

        // Write to Visitor & Visit Table
        private String selfReg(String nric, String age, String fname, String address, String postal, String mobtel, String alttel, String hometel,
            String sex, String nationality, String dob, String race, String email, String purpose, String pName, String pNric, String otherPurpose, String bedno, String appTime,
            String fever, String symptoms, String influenza, String countriesTravelled, String remarks, String visitLocation) {
            String connectionString = null;
            SqlConnection cnn;
            int row = 0;
            connectionString = "Data Source=ALOYSIUS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["onlineConnection"].ConnectionString);
            String successString = "{\"Result\":\"Success\",\"Msg\":\"";
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[INSERT INTO-CREATE_VISITOR_PROFILE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNric", nric);
                command.Parameters.AddWithValue("@pFullName", fname);
                command.Parameters.AddWithValue("@pGender", sex);
                command.Parameters.AddWithValue("@pNationality", nationality);
                command.Parameters.AddWithValue("@pDateOfBirth", dob);
                command.Parameters.AddWithValue("@pRace", race);
                command.Parameters.AddWithValue("@pMobileTel", mobtel);
                command.Parameters.AddWithValue("@pHomeTel", hometel);
                command.Parameters.AddWithValue("@pAltTel", alttel);
                command.Parameters.AddWithValue("@pEmail", email);
                command.Parameters.AddWithValue("@pHomeAddress", address);
                command.Parameters.AddWithValue("@pPostalCode", postal);
                command.Parameters.AddWithValue("@pTimestamp", DateTime.Now);
                command.Parameters.Add("@responseMessage", SqlDbType.Int).Direction = ParameterDirection.Output;
                cnn.Open();

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        successString += reader["@responseMessage"].ToString();
                    }
                }
                successString += "\"}";

            }
            catch (Exception ex)
            {
                successString += ex.Message;
                successString += "\"}";
                return successString;
            }
            finally
            {
                cnn.Close();
            }
            //try
            //{
            //    SqlCommand command = new SqlCommand("[dbo].[INSERT INTO-CREATE_VISITOR_PROFILE]", cnn);// Change procedure to create VISIT
            //    command.CommandType = System.Data.CommandType.StoredProcedure;
            //    command.Parameters.AddWithValue("@pNric", nric); // Add fields
            //    command.Parameters.Add("@pResponseMessage", SqlDbType.NVarChar, 250).Direction = ParameterDirection.Output;
            //    cnn.Open();
            //    Object[] test;

            //    using (SqlDataReader reader = command.ExecuteReader())
            //    {
            //        int counter = 0;
            //        test = new Object[reader.FieldCount];
            //        while (reader.Read())
            //        {
            //            counter++; // 1 for Success, 0 for Failure
            //        }
            //    }
            //    successString += "\"}";

            //}
            //catch (Exception ex)
            //{
            //    successString += ex.Message;
            //    successString += "\"}";
            //}
            //finally
            //{
            //    cnn.Close();
            //}
            return successString;
        }

        // Write to Visitor, Visit & Confirmation Table
        private String AssistReg(String nric, String age, String fname, String address, String postal, String mobtel, String alttel, String hometel,
            String sex, String nationality, String dob, String race, String email, String purpose, String pName, String pNric, String otherPurpose, String bedno, String appTime,
            String fever, String symptoms, String influenza, String countriesTravelled, String remarks, String visitLocation, String temperature) {
            string connectionString = null;
            SqlConnection cnn;
            int row = 0;
            connectionString = "Data Source=ALOYSIUS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["onlineConnection"].ConnectionString);
            String successString = "{\"Result\":\"Success\",\"Msg\":\"";
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[INSERT INTO-CREATE_VISITOR_PROFILE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNric", nric);
                command.Parameters.AddWithValue("@pFullName", fname);
                command.Parameters.AddWithValue("@pGender", sex);
                command.Parameters.AddWithValue("@pNationality", nationality);
                command.Parameters.AddWithValue("@pDateOfBirth", dob);
                command.Parameters.AddWithValue("@pRace", race);
                command.Parameters.AddWithValue("@pMobileTel", mobtel);
                command.Parameters.AddWithValue("@pHomeTel", hometel);
                command.Parameters.AddWithValue("@pAltTel", alttel);
                command.Parameters.AddWithValue("@pEmail", email);
                command.Parameters.AddWithValue("@pHomeAddress", address);
                command.Parameters.AddWithValue("@pPostalCode", postal);
                command.Parameters.AddWithValue("@pTimestamp", DateTime.Now);
                command.Parameters.Add("@responseMessage", SqlDbType.Int).Direction = ParameterDirection.Output;
                cnn.Open();

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        successString += reader["@responseMessage"].ToString();
                    }
                }
                successString += "\"}";

            }
            catch (Exception ex)
            {
                successString += ex.Message;
                successString += "\"}";
                return successString;
            }
            finally
            {
                cnn.Close();
            }
            //try
            //{
            //    SqlCommand command = new SqlCommand("[dbo].[INSERT INTO-CREATE_VISITOR_PROFILE]", cnn);// Change procedure to write to VISIT
            //    command.CommandType = System.Data.CommandType.StoredProcedure;
            //    command.Parameters.AddWithValue("@pFirstName", fname);// Fullname
            //    command.Parameters.AddWithValue("@pNric", nric);
            //    command.Parameters.AddWithValue("@pAddress", address);
            //    command.Parameters.AddWithValue("@pPostal", postal);
            //    command.Parameters.AddWithValue("@pHomeTel", hometel);
            //    command.Parameters.AddWithValue("@pAltTel", alttel);
            //    command.Parameters.AddWithValue("@pMobTel", mobtel);
            //    command.Parameters.AddWithValue("@pEmail", email);
            //    command.Parameters.AddWithValue("@pSex", sex);
            //    command.Parameters.AddWithValue("@pNationality", nationality);
            //    command.Parameters.AddWithValue("@pDOB", dob);
            //    command.Parameters.AddWithValue("@pPurpose", purpose);
            //    command.Parameters.AddWithValue("@pAge", age);
            //    command.Parameters.AddWithValue("@prace", race);
            //    command.Parameters.AddWithValue("@pVisitTime", appTime);
            //    command.Parameters.AddWithValue("@pWingNo", bedno);
            //    command.Parameters.AddWithValue("@pWardNo", bedno);
            //    command.Parameters.AddWithValue("@pCubicleNo", bedno);
            //    command.Parameters.AddWithValue("@pBedNo", bedno);
            //    command.Parameters.AddWithValue("@pPatientName", pName);
            //    command.Parameters.AddWithValue("@pPatientNric", pNric);
            //    command.Parameters.AddWithValue("@visitLocation", visitLocation);
            //    command.Parameters.AddWithValue("@visitPurpose", otherPurpose);
            //    command.Parameters.Add("@pResponseMessage", SqlDbType.NVarChar, 250).Direction = ParameterDirection.Output;
            //    cnn.Open();
            //    Object[] test;

            //    using (SqlDataReader reader = command.ExecuteReader())
            //    {
            //        test = new Object[reader.FieldCount];
            //        while (reader.Read())
            //        {
            //            row++;
            //        }
            //    }
            //    successString += "\"}";

            //}
            //catch (Exception ex)
            //{
            //    successString += ex.Message;
            //    successString += "\"}";
            //    return successString;
            //}
            //finally
            //{
            //    cnn.Close();
            //}
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[SELECT FROM - CONFIRM_CHECK_IN]", cnn);// Change procedure to write to CONFIRMAtiON
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNRIC", nric);
                //command.Parameters.AddWithValue("@staffID", Session);
                command.Parameters.Add("@pResponseMessage", SqlDbType.NVarChar, 250).Direction = ParameterDirection.Output;
                cnn.Open();
                Object[] test;

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    test = new Object[reader.FieldCount];
                    while (reader.Read())
                    {
                        row++;
                    }
                }
                successString += nric + " Successfully Added as a new Visitor, Visit Details & Confirmation Recorded at " + DateTime.Now;
                successString += "\"}";

            }
            catch (Exception ex)
            {
                successString += ex.Message;
                successString += "\"}";
            }
            finally
            {
                cnn.Close();
            }
            CheckIn(nric, temperature);
            return successString;
        }

        private String CheckIn(String nric, String temp) {
            string connectionString = null;
            SqlConnection cnn;
            int row = 0;
            connectionString = "Data Source=ALOYSIUS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["onlineConnection"].ConnectionString);
            String successString = "{\"Result\":\"Success\",\"Msg\":\""; // Reflect Time Checked in - TO BE AMENDED
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[SELECT FROM  - Validate_Check_In]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pPatient_id", nric);
                command.Parameters.AddWithValue("@pBed_no", temp);
                command.Parameters.Add("@pResponseMessage", SqlDbType.NVarChar, 250).Direction = ParameterDirection.Output;
                cnn.Open();

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        row++;
                    }
                }
            }
            catch (Exception ex)
            {

            }
            finally {
                cnn.Close();
            }
            if (row < 3) // If not more than 3 visitors are checked in, check in visitor
            {
                row = 0;
                try
                {
                    // Find Visitor Details
                    SqlCommand command = new SqlCommand("[dbo].[INSERT INTO  - First_Check_In_Out]", cnn);
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
                    successString += nric + " Checked In at " + DateTime.Now + ". " + (3 - 1 - row) + " visitors are allowed to see this patient";
                    successString += "\"}";

                }
                catch (Exception ex)
                {
                    successString += ex.Message;
                    successString += "\"}";
                }
                finally {
                    cnn.Close();
                }
            }
            else {
                successString += row + " Visitors are Checked-In at the Moment, Please try Again Later.";
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