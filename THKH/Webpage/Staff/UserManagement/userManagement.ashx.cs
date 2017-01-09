using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Dynamic;
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

            }
            if (requestType == "deleteUser") {

            }
            if (requestType == "addUser") {

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

        private String addUser() {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[RETRIEVE_ACTIVE_QUESTIONNARIE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.Add(respon);
                cnn.Open();

                SqlDataReader reader = command.ExecuteReader();
                int count = 1;
                if (reader.HasRows)
                {
                    successString += "[";
                    while (reader.Read())
                    {
                        if (count > 1)
                        {
                            successString += ",";
                        }
                        successString += "{\"QuestionNumber\":\"";
                        successString += reader.GetInt32(1) + "\",\"QuestionList\":\"" + reader.GetString(0) + "\",\"Question\":\"" + reader.GetString(2) + "\",\"QuestionType\":\"" + reader.GetString(3) + "\",\"QuestionAnswers\":\"" + reader.GetString(4);
                        successString += "\"}";
                        count++;
                    }
                    successString += "]";
                }
                successString += respon.Value;
                reader.Close();
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

        private String deleteUser() {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[RETRIEVE_ACTIVE_QUESTIONNARIE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.Add(respon);
                cnn.Open();

                SqlDataReader reader = command.ExecuteReader();
                int count = 1;
                if (reader.HasRows)
                {
                    successString += "[";
                    while (reader.Read())
                    {
                        if (count > 1)
                        {
                            successString += ",";
                        }
                        successString += "{\"QuestionNumber\":\"";
                        successString += reader.GetInt32(1) + "\",\"QuestionList\":\"" + reader.GetString(0) + "\",\"Question\":\"" + reader.GetString(2) + "\",\"QuestionType\":\"" + reader.GetString(3) + "\",\"QuestionAnswers\":\"" + reader.GetString(4);
                        successString += "\"}";
                        count++;
                    }
                    successString += "]";
                }
                successString += respon.Value;
                reader.Close();
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

        private String updateUser() {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[RETRIEVE_ACTIVE_QUESTIONNARIE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.Add(respon);
                cnn.Open();

                SqlDataReader reader = command.ExecuteReader();
                int count = 1;
                if (reader.HasRows)
                {
                    successString += "[";
                    while (reader.Read())
                    {
                        if (count > 1)
                        {
                            successString += ",";
                        }
                        successString += "{\"QuestionNumber\":\"";
                        successString += reader.GetInt32(1) + "\",\"QuestionList\":\"" + reader.GetString(0) + "\",\"Question\":\"" + reader.GetString(2) + "\",\"QuestionType\":\"" + reader.GetString(3) + "\",\"QuestionAnswers\":\"" + reader.GetString(4);
                        successString += "\"}";
                        count++;
                    }
                    successString += "]";
                }
                successString += respon.Value;
                reader.Close();
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

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}