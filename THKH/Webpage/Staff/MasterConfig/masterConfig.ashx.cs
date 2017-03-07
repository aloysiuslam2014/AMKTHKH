using System;
using System.Collections.Generic;
using System.Data;
using System.Dynamic;
using System.Web;
using THKH.Classes.DAO;
using THKH.Classes.Entity;

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
                var visLim = context.Request.Form["visLim"];
                successString = updateTempTime(lowTemp, highTemp, warnTemp, lowTime, highTime, staffUser, visLim);
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

        // Gets all the User Access Profile names & returns a JSON String
        private String getAccessProfile() {
            dynamic json = new ExpandoObject();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_ACCESS_PROFILES", true, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            DataTable dt = new DataTable();
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                dt = responseOutput.getDataTable();
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
            }
            catch (Exception ex)
            {
                json.Msg = ex.Message.ToString();
                json.Result = "Failure";
            }
            
            return Newtonsoft.Json.JsonConvert.SerializeObject(json);
        }

        // updates the registration configuration & returns a JSON String
        private String updateTempTime(String lowTemp, String highTemp, String warnTemp, String lowTime, String highTime, String staffUser, String visLim) {
            
            dynamic json = new ExpandoObject();
            json.Result = "Success";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("UPDATE_CONFIG", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pLowTemp", lowTemp);
            procedureCall.addParameterWithValue("@pHighTemp", highTemp);
            procedureCall.addParameterWithValue("@pWarnTemp", warnTemp);
            procedureCall.addParameterWithValue("@pLowTime", lowTime);
            procedureCall.addParameterWithValue("@pHighTime", highTime);
            procedureCall.addParameterWithValue("@pUpdatedBy", staffUser);
            procedureCall.addParameterWithValue("@pVisLim", Int32.Parse(visLim));
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                json.Msg = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                json.Result = "Failure";
                json.Msg = ex.Message;
                return Newtonsoft.Json.JsonConvert.SerializeObject(json);
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(json);
        }

        // Gets the registration configuration & returns a JSON String
        private String getConfig()
        {
            dynamic json = new ExpandoObject();
            json.Result = "Success";
            String successString = "";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_CONFIG", false, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.VarChar,500);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();

                DataTableReader reader = responseOutput.getDataTable().CreateDataReader();
                int count = 1;
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        if (count > 1)
                        {
                            successString += ",";
                        }
                        successString += reader.GetString(0) + "," + reader.GetString(1) + "," + reader.GetString(2) + "," + reader.GetString(3) + "," + reader.GetString(4) + "," + reader.GetInt32(5);
                        count++;
                    }
                }
                reader.Close();
                json.Msg = successString;
            }
            catch (Exception ex)
            {
                json.Result = "Failure";
                json.Msg = ex.Message;
                return Newtonsoft.Json.JsonConvert.SerializeObject(json);
            }
           
            return Newtonsoft.Json.JsonConvert.SerializeObject(json);
        }

        // Updates the Selected User Access Profile & returns a JSON String
        private String updateAccessProfile(String name, String permissions, String username) {
            dynamic json = new ExpandoObject();
            json.Result = "Success";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("UPDATE_ACCESS_PROFILE", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pProfileName", name);
            procedureCall.addParameterWithValue("@pAccessRights", permissions); 
            procedureCall.addParameterWithValue("@pUpdatedBy", username);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                json.Msg = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                json.Result = "Failure";
                json.Msg = ex.Message;
                return Newtonsoft.Json.JsonConvert.SerializeObject(json);
            }
         
            return Newtonsoft.Json.JsonConvert.SerializeObject(json);
        }

        // Deletes Selected User Access Profile & returns a JSON String
        private String deleteAccessProfile(String name) {
            dynamic json = new ExpandoObject();
            json.Result = "Success";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("DELETE_ACCESS_PROFILE", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pProfileName", name);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                json.Msg = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                json.Result = "Failure";
                json.Msg = ex.Message;
            }
           
            return Newtonsoft.Json.JsonConvert.SerializeObject(json);
        }

        // Gets Selected User Access Profile & returns a JSON String
        private String getSelectedProfile(String name) {
            dynamic json = new ExpandoObject();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_SELECTED_PROFILE", true, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pProfileName", name);
            DataTable dt = new DataTable();
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                dt = responseOutput.getDataTable();
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
            }
            catch (Exception ex)
            {
                json.Msg = ex.Message.ToString();
                json.Result = "Failure";
                return Newtonsoft.Json.JsonConvert.SerializeObject(json);
            }
           
            return Newtonsoft.Json.JsonConvert.SerializeObject(json);
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