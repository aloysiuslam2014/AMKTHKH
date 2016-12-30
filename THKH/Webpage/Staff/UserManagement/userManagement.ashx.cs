using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
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