using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Dynamic;
using System.Globalization;
using System.Linq;
using System.Web;

namespace THKH.Webpage.Staff.UserManagement
{
    /// <summary>
    /// Summary description for Handler1
    /// </summary>
    public class Handler1 : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {     
            context.Response.ContentType = "text/plain";
            String successString = "";

            var requestType = context.Request.Form["requestType"];

            if (requestType == "loadUsers") {
                successString = loadUsers();
            }
            if (requestType == "getUser")
            {
                var email = context.Request.Form["email"];
                successString = getUser(email);
            }
            if (requestType == "updateUser") {
                var staffUser = context.Request.Form["username"].ToString();
                var fname = context.Request.Form["fname"];
                var lname = context.Request.Form["lname"];
                var snric = context.Request.Form["snric"];
                var email = context.Request.Form["email"];
                var address = context.Request.Form["address"];
                int postal = Int32.Parse(context.Request.Form["postal"]);
                var mobtel = context.Request.Form["mobtel"];
                var hometel = context.Request.Form["hometel"];
                var alttel = context.Request.Form["alttel"];
                var sex = context.Request.Form["sex"];
                var nationality = context.Request.Form["nationality"];
                var dob = context.Request.Form["dob"];
                var race = context.Request.Form["race"];
                int age = Int32.Parse(context.Request.Form["age"]);
                var title = context.Request.Form["title"];
                int permissions = Int32.Parse(context.Request.Form["permissions"]);
                var password = context.Request.Form["staffPwd"]; // If blank, dont change password
                successString = updateUser(fname, lname, snric, email, address, postal, mobtel, hometel, alttel, sex, nationality, dob, race, age, title, permissions, password, staffUser);
            }
            if (requestType == "deleteUser") {
                var snric = context.Request.Form["snric"];
                var email = context.Request.Form["email"];
                successString = deleteUser(snric, email);
            }
            if (requestType == "addUser") {
                var staffUser = context.Request.Form["username"].ToString();
                var fname = context.Request.Form["fname"];
                var lname = context.Request.Form["lname"];
                var snric = context.Request.Form["snric"];
                var email = context.Request.Form["email"];
                var address = context.Request.Form["address"];
                int postal = Int32.Parse(context.Request.Form["postal"]);
                var mobtel = context.Request.Form["mobtel"];
                var hometel = context.Request.Form["hometel"];
                var alttel = context.Request.Form["alttel"];
                var sex = context.Request.Form["sex"];
                var nationality = context.Request.Form["nationality"];
                var dob = context.Request.Form["dob"];
                var race = context.Request.Form["race"];
                int age = Int32.Parse(context.Request.Form["age"]);
                var title = context.Request.Form["title"];
                int permissions = Int32.Parse(context.Request.Form["permissions"]);
                var password = context.Request.Form["staffPwd"];
                successString = addUser(fname,lname,snric,email,address,postal,mobtel,hometel,alttel,sex,nationality,dob,race,age,title,permissions, password, staffUser);
            }
            if (requestType == "getPermissions") {
                successString = getPermissions();
            }
            context.Response.Write(successString);
        }

        private String loadUsers() {
            SqlConnection cnn;
            String successString = "";//result and msg 
            dynamic jsonObj = new ExpandoObject();
            dynamic responseJson = new ExpandoObject();
            ArrayList contentOf = new ArrayList();
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_STAFFS]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                //command.Parameters.AddWithValue('@pNric', nric);
                command.Parameters.Add(respon);
                cnn.Open();

                SqlDataReader reader = command.ExecuteReader();
                int count = 1;
                jsonObj.Msg = "Success";
                if (reader.HasRows)
                {
                   
                    while (reader.Read())
                    {
                        responseJson = new ExpandoObject();
                        responseJson.email = reader.GetString(0);
                        responseJson.firstName = reader.GetString(1);
                        responseJson.lastName = reader.GetString(2);
                        responseJson.permission = reader.GetInt32(3);
                        contentOf.Add(responseJson);
                          count++;
                    }
                  
                }
                jsonObj.Result = contentOf;
               // successString += respon.Value;
                reader.Close();
            }
            catch (Exception ex)
            {
                jsonObj.Msg = "Failed";
                jsonObj.Result = ex.Message;
                successString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonObj); 
                return successString;
            }
            finally
            {
                cnn.Close();
            }
            successString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonObj); ;
            return successString;
        }

        private String getUser(String email)
        {
            SqlConnection cnn;
            String successString = "";//result and msg 
            dynamic jsonObj = new ExpandoObject();
            dynamic responseJson = new ExpandoObject();
            ArrayList contentOf = new ArrayList();
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_SELECTED_STAFF]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pStaff_Email", email);
                command.Parameters.Add(respon);
                cnn.Open();

                SqlDataReader reader = command.ExecuteReader();
                int count = 1;
                jsonObj.Msg = "Success";
                if (reader.HasRows)
                {

                    while (reader.Read())
                    {
                        responseJson.email = reader.GetString(0);
                        responseJson.firstName = reader.GetString(1);
                        responseJson.lastName = reader.GetString(2);
                        responseJson.nric = reader.GetString(3);
                        responseJson.address = reader.GetString(4);
                        responseJson.postalCode = reader.GetInt32(5);
                        responseJson.homeTel = reader.GetString(6);
                        responseJson.altTel = reader.GetString(7);
                        responseJson.mobTel = reader.GetString(8);
                        responseJson.sex = reader.GetString(9);
                        responseJson.nationality  = reader.GetString(10);
                        responseJson.dateOfBirth = reader.GetDateTime(11).ToString("dd/MM/yyyy");
                        responseJson.age = reader.GetInt32(12);
                        responseJson.race = reader.GetString(13);
                        responseJson.permissions = reader.GetInt32(16);
                        responseJson.position = reader.GetString(17);

                        count++;
                    }

                }
                jsonObj.Result = responseJson;
                // successString += respon.Value;
                reader.Close();
            }
            catch (Exception ex)
            {
                jsonObj.Msg = "Failed";
                jsonObj.Result = ex.Message;
                successString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonObj); ;
                return successString;
            }
            finally
            {
                cnn.Close();
            }
            successString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonObj); ;
            return successString;
        }

        private String addUser(String fname, String lname, String snric, String email, String address, int postal, String mobtel, String hometel, String alttel, String sex,
            String nationality, String dob, String race, int age, String title, int permissions, String password, String staffUser) {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":\"";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.NVarChar, 250);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[CREATE_STAFF]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.Add(respon);
                command.Parameters.AddWithValue("@pEmail",email);
                command.Parameters.AddWithValue("@pPassword", password);
                command.Parameters.AddWithValue("@pFirstName",fname);
                command.Parameters.AddWithValue("@pLastName", lname);
                command.Parameters.AddWithValue("@pNric", snric);
                command.Parameters.AddWithValue("@pAddress",address);
                command.Parameters.AddWithValue("@pPostal", postal);
                command.Parameters.AddWithValue("@pHomeTel", hometel);
                command.Parameters.AddWithValue("@pAltTel", alttel);
                command.Parameters.AddWithValue("@pMobileTel", mobtel);
                command.Parameters.AddWithValue("@pSex", sex);
                command.Parameters.AddWithValue("@pNationality", nationality);
                command.Parameters.AddWithValue("@pDOB", DateTime.ParseExact(dob, "dd-MM-yyyy", CultureInfo.InvariantCulture));
                command.Parameters.AddWithValue("@pAge", age);
                command.Parameters.AddWithValue("@pRace", race);
                command.Parameters.AddWithValue("@pPermission", permissions);
                command.Parameters.AddWithValue("@pPostion", title);
                command.Parameters.AddWithValue("@pCreatedBy", staffUser);
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

        private String deleteUser(String snric, String email) {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[DELETE_STAFF]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNric", snric);
                command.Parameters.AddWithValue("@pEmail", email);
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
            successString += "}";
            return successString;
        }

        private String updateUser(String fname, String lname, String snric, String email, String address, int postal, String mobtel, String hometel, String alttel, String sex,
            String nationality, String dob, String race, int age, String title, int permissions, String password, String staffUser) {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":\"";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE_STAFF]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.Add(respon);
                command.Parameters.AddWithValue("@pEmail", email);
                command.Parameters.AddWithValue("@pPassword", password);
                command.Parameters.AddWithValue("@pFirstName", fname);
                command.Parameters.AddWithValue("@pLastName", lname);
                command.Parameters.AddWithValue("@pNric", snric);
                command.Parameters.AddWithValue("@pAddress", address);
                command.Parameters.AddWithValue("@pPostalCode", postal);
                command.Parameters.AddWithValue("@pHomeTel", hometel);
                command.Parameters.AddWithValue("@pAltTel", alttel);
                command.Parameters.AddWithValue("@pMobileTel", mobtel);
                command.Parameters.AddWithValue("@pSex", sex);
                command.Parameters.AddWithValue("@pNationality", nationality);
                command.Parameters.AddWithValue("@pDateOfBirth", DateTime.ParseExact(dob, "dd/MM/yyyy", CultureInfo.InvariantCulture));
                command.Parameters.AddWithValue("@pAge", age);
                command.Parameters.AddWithValue("@pRace", race);
                command.Parameters.AddWithValue("@pPermission", permissions);
                command.Parameters.AddWithValue("@pPosition", title);
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

        private String getPermissions()
        {
            SqlConnection cnn;
            String successString = "";//result and msg 
            dynamic jsonObj = new ExpandoObject();
            dynamic responseJson = new ExpandoObject();
            ArrayList contentOf = new ArrayList();
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_USER_PERMISSIONS]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                //command.Parameters.AddWithValue('@pNric', nric);
                command.Parameters.Add(respon);
                cnn.Open();

                SqlDataReader reader = command.ExecuteReader();
                jsonObj.Msg = "Success";
                if (reader.HasRows)
                {

                    while (reader.Read())
                    {
                        responseJson = new ExpandoObject();
                        responseJson.accessID = reader.GetInt32(0);
                        responseJson.accessName = reader.GetString(1);
                        contentOf.Add(responseJson);
                    }

                }
                jsonObj.Result = contentOf;
                reader.Close();
            }
            catch (Exception ex)
            {
                jsonObj.Msg = "Failure";
                jsonObj.Result = ex.Message;
                successString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonObj);
                return successString;
            }
            finally
            {
                cnn.Close();
            }
            successString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonObj); ;
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