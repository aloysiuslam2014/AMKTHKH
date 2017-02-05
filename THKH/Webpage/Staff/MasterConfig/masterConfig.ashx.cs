using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Dynamic;
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
                var warnTemp = context.Request.Form["warnTemp"];
                var lowTime = context.Request.Form["lowTime"];
                var highTime = context.Request.Form["highTime"];
                successString = updateTempTime(lowTemp, highTemp, warnTemp, lowTime, highTime, staffUser);
            }
            else if (requestType.ToString() == "getConfig")
            {
                successString = getConfig();
            }
            else if (requestType.ToString() == "updateProfile")
            {
                var name = context.Request.Form["profileName"];
                var username = context.Request.Form["userName"];
                var permissions = context.Request.Form["permissions"];
                successString = updateAccessProfile(name, permissions, username);
            }
            else if (requestType.ToString() == "deleteProfile")
            {
                var name = context.Request.Form["profileName"];
                successString = deleteAccessProfile(name);
            }else if (requestType.ToString() == "getProfiles")
            {
                successString = getAccessProfile();
            }
            else if (requestType.ToString() == "getSelectedProfile")
            {
                var name = context.Request.Form["profileName"];
                successString = getSelectedProfile(name);
            }
            context.Response.Write(successString);
        }

        //
        private String getAccessProfile() {
            dynamic json = new ExpandoObject();
            SqlConnection cnn;
            //String successString = "{\"Result\":\"Success\",\"Msg\":\"";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            DataTable dt = new DataTable();
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_ACCESS_PROFILES]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                
                command.Parameters.Add(respon);
                cnn.Open();

                dt.Load(command.ExecuteReader());
                List<Object> jsonArray = new List<Object>();
                foreach (DataRow row in dt.Rows)
                {
                    dynamic innerJson = new ExpandoObject();
                    var itemArr = row.ItemArray;
                    innerJson.AccessProfile = itemArr[0];
                    innerJson.permissions = itemArr[1];
                    //innerJson.dateUpdated = itemArr[2];
                    //innerJson.updatedBy = itemArr[3];

                    // Add to JSON Array
                    jsonArray.Add(innerJson);
                }
                json.Msg = jsonArray;
                json.Result = "Success";
                //successString += respon.Value;
            }
            catch (Exception ex)
            {
                json.Msg = ex.Message.ToString();
                json.Result = "Failure";
                //successString.Replace("Success", "Failure");
                //successString += ex.Message;
                //successString += "\"}";
                return Newtonsoft.Json.JsonConvert.SerializeObject(json);
                //return successString;
            }
            finally
            {
                cnn.Close();
            }
            //successString += "\"}";
            return Newtonsoft.Json.JsonConvert.SerializeObject(json);
            //return successString;
        }

        //
        private String updateTempTime(String lowTemp, String highTemp, String warnTemp, String lowTime, String highTime, String staffUser) {
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
                command.Parameters.AddWithValue("@pWarnTemp", warnTemp);
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

        //
        private String getConfig()
        {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":\"";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.VarChar, 500);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_CONFIG]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.Add(respon);
                cnn.Open();

                SqlDataReader reader = command.ExecuteReader();
                int count = 1;
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        if (count > 1)
                        {
                            successString += ",";
                        }
                        successString += reader.GetString(0) + "," + reader.GetString(1) + "," + reader.GetString(2) + "," + reader.GetString(3) + "," + reader.GetString(4);
                        count++;
                    }
                }
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
            successString += "\"}";
            return successString;
        }

        //
        private String updateAccessProfile(String name, String permissions, String username) {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":\"";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE_ACCESS_PROFILE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pProfileName", name);
                command.Parameters.AddWithValue("@pAccessRights", permissions); 
                command.Parameters.AddWithValue("@pUpdatedBy", username);
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

        //
        private String deleteAccessProfile(String name) {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":\"";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[DELETE_ACCESS_PROFILE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pProfileName", name);
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

        private String getSelectedProfile(String name) {
            dynamic json = new ExpandoObject();
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            DataTable dt = new DataTable();
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_SELECTED_PROFILE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pProfileName", name);
                command.Parameters.Add(respon);
                cnn.Open();

                dt.Load(command.ExecuteReader());
                List<Object> jsonArray = new List<Object>();
                foreach (DataRow row in dt.Rows)
                {
                    dynamic innerJson = new ExpandoObject();
                    var itemArr = row.ItemArray;
                    //innerJson.ProfileName = itemArr[0];
                    innerJson.Permissions = itemArr[1];
                    //innerJson.dateUpdated = itemArr[2];
                    //innerJson.updatedBy = itemArr[3];

                    // Add to JSON Array
                    jsonArray.Add(innerJson);
                }
                json.Msg = jsonArray;
                json.Result = "Success";
                //successString += respon.Value;
            }
            catch (Exception ex)
            {
                json.Msg = ex.Message.ToString();
                json.Result = "Failure";
                //successString.Replace("Success", "Failure");
                //successString += ex.Message;
                //successString += "\"}";
                return Newtonsoft.Json.JsonConvert.SerializeObject(json);
                //return successString;
            }
            finally
            {
                cnn.Close();
            }
            //successString += "\"}";
            return Newtonsoft.Json.JsonConvert.SerializeObject(json);
            //return successString;
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