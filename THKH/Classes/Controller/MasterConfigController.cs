using System;
using System.Collections.Generic;
using System.Data;
using System.Dynamic;
using THKH.Classes.DAO;
using THKH.Classes.Entity;
namespace THKH.Classes.Controller
{
    public class MasterConfigController
    {
        GenericProcedureDAO procedureCall;

        /// <summary>
        /// Returns a string of all the access profiles available
        /// </summary>
        /// <returns>JSON String</returns>
        public String getAccessProfile()
        {
            dynamic json = new ExpandoObject();
            procedureCall = new GenericProcedureDAO("GET_ACCESS_PROFILES", true, true, true);
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

        /// <summary>
        /// Updates the registration configuration
        /// </summary>
        /// <param name="lowTemp"></param>
        /// <param name="highTemp"></param>
        /// <param name="warnTemp"></param>
        /// <param name="lowTime"></param>
        /// <param name="highTime"></param>
        /// <param name="staffUser"></param>
        /// <param name="visLim"></param>
        /// <returns>JSON String</returns>
        public String updateTempTime(String lowTemp, String highTemp, String warnTemp, String lowTime, String highTime, String staffUser, String visLim)
        {

            dynamic json = new ExpandoObject();
            json.Result = "Success";
            procedureCall = new GenericProcedureDAO("UPDATE_CONFIG", true, true, false);
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

        /// <summary>
        /// Gets the registration configuration
        /// </summary>
        /// <returns>JSON String</returns>
        public String getConfig()
        {
            dynamic json = new ExpandoObject();
            json.Result = "Success";
            String successString = "";
            procedureCall = new GenericProcedureDAO("GET_CONFIG", false, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.VarChar, 500);
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

        /// <summary>
        /// Updates the Selected User Access Profile
        /// </summary>
        /// <param name="name"></param>
        /// <param name="permissions"></param>
        /// <param name="username"></param>
        /// <returns>JSON String</returns>
        public String updateAccessProfile(String name, String permissions, String username)
        {
            dynamic json = new ExpandoObject();
            json.Result = "Success";
            procedureCall = new GenericProcedureDAO("UPDATE_ACCESS_PROFILE", true, true, false);
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

        /// <summary>
        /// Deletes Selected User Access Profile & returns a JSON String
        /// </summary>
        /// <param name="name"></param>
        /// <returns>JSON String</returns>
        public String deleteAccessProfile(String name)
        {
            dynamic json = new ExpandoObject();
            json.Result = "Success";
            procedureCall = new GenericProcedureDAO("DELETE_ACCESS_PROFILE", true, true, false);
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

        /// <summary>
        /// Gets Selected User Access Profile
        /// </summary>
        /// <param name="name"></param>
        /// <returns>JSON String</returns>
        public String getSelectedProfile(String name)
        {
            dynamic json = new ExpandoObject();
            procedureCall = new GenericProcedureDAO("GET_SELECTED_PROFILE", true, true, true);
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
                    innerJson.Permissions = itemArr[1];
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
    }
}