using System;
using System.Collections;
using System.Data;
using System.Dynamic;
using System.Globalization;
using THKH.Classes.DAO;
using THKH.Classes.Entity;
namespace THKH.Classes.Controller
{
    public class UserManagementController
    {
        GenericProcedureDAO procedureCall;

        /// <summary>
        /// Returns a string of user profile names
        /// </summary>
        /// <returns>JSON String</returns>
        public String loadUsers()
        {
            dynamic jsonObj = new ExpandoObject();
            dynamic responseJson = new ExpandoObject();
            ArrayList contentOf = new ArrayList();
           procedureCall = new GenericProcedureDAO("GET_STAFFS", false, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                DataTableReader reader = responseOutput.getDataTable().CreateDataReader();
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
                reader.Close();
            }
            catch (Exception ex)
            {
                jsonObj.Msg = "Failed";
                jsonObj.Result = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(jsonObj); ;
        }

        /// <summary>
        /// Gets a specific row from the Staff Table
        /// </summary>
        /// <param name="email"></param>
        /// <returns>JSON String</returns>
        public String getUser(String email)
        {
            String successString = "";
            dynamic jsonObj = new ExpandoObject();
            ArrayList contentOf = new ArrayList();
           procedureCall = new GenericProcedureDAO("GET_SELECTED_STAFF", true, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pStaff_Email", email);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                DataTableReader reader = responseOutput.getDataTable().CreateDataReader();
                int count = 1;
                jsonObj.Msg = "Success";
                if (reader.HasRows)
                {

                    while (reader.Read())
                    {
                        StaffUser stf = new StaffUser(reader.GetString(1), reader.GetString(2), reader.GetString(3), reader.GetString(9), reader.GetString(10), reader.GetDateTime(11).ToString("dd/MM/yyyy"),
                            reader.GetString(8), reader.GetString(4), reader.GetInt32(5), reader.GetString(0), reader.GetString(6), reader.GetString(7), reader.GetInt32(14),
                            reader.GetString(15), reader.GetString(16));
                        contentOf.Add(stf.toJsonObject());
                        count++;
                    }
                }
                jsonObj.Result = contentOf;
                reader.Close();
            }
            catch (Exception ex)
            {
                jsonObj.Msg = "Failed";
                jsonObj.Result = ex.Message;
                successString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonObj); ;
            }
            successString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonObj);
            return successString;
        }

        /// <summary>
        /// Creates a new row in the Staff Table
        /// </summary>
        /// <param name="fname"></param>
        /// <param name="lname"></param>
        /// <param name="snric"></param>
        /// <param name="email"></param>
        /// <param name="address"></param>
        /// <param name="postal"></param>
        /// <param name="mobtel"></param>
        /// <param name="hometel"></param>
        /// <param name="alttel"></param>
        /// <param name="sex"></param>
        /// <param name="nationality"></param>
        /// <param name="dob"></param>
        /// <param name="title"></param>
        /// <param name="permissions"></param>
        /// <param name="password"></param>
        /// <param name="staffUser"></param>
        /// <param name="accessProfile"></param>
        /// <returns>JSON String</returns>
        public String addUser(String fname, String lname, String snric, String email, String address, String postal, String mobtel, String hometel, String alttel, String sex,
            String nationality, String dob, String title, int permissions, String password, String staffUser, String accessProfile)
        {
            dynamic responseJson = new ExpandoObject();
            responseJson.Result = "Success";
            int pos = 0;
            if (postal != "")
            {
                pos = Int32.Parse(postal);
            }
           procedureCall = new GenericProcedureDAO("CREATE_STAFF", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.NVarChar, 250);
            procedureCall.addParameterWithValue("@pEmail", email);
            procedureCall.addParameterWithValue("@pPassword", password);
            procedureCall.addParameterWithValue("@pFirstName", fname);
            procedureCall.addParameterWithValue("@pLastName", lname);
            procedureCall.addParameterWithValue("@pNric", snric);
            procedureCall.addParameterWithValue("@pAddress", address);
            procedureCall.addParameterWithValue("@pPostal", pos);
            procedureCall.addParameterWithValue("@pHomeTel", hometel);
            procedureCall.addParameterWithValue("@pAltTel", alttel);
            procedureCall.addParameterWithValue("@pMobileTel", mobtel);
            procedureCall.addParameterWithValue("@pSex", sex);
            procedureCall.addParameterWithValue("@pNationality", nationality);
            procedureCall.addParameterWithValue("@pDOB", DateTime.ParseExact(dob, "dd-MM-yyyy", CultureInfo.InvariantCulture));
            procedureCall.addParameterWithValue("@pPermission", permissions);
            procedureCall.addParameterWithValue("@pAccessProfile", accessProfile);
            procedureCall.addParameterWithValue("@pPostion", title);
            procedureCall.addParameterWithValue("@pCreatedBy", staffUser);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                responseJson.Msg = responseOutput.getSqlParameterValue("@responseMessage").ToString();
                if (responseJson.Msg.Contains("PRIMARY KEY"))
                {
                    responseJson.Result = "Failure";
                }
            }
            catch (Exception ex)
            {
                responseJson.Result = "Failure";
                responseJson.Msg = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(responseJson);
        }

        /// <summary>
        /// Deletes a specific row in the Staff Table
        /// </summary>
        /// <param name="snric"></param>
        /// <param name="email"></param>
        /// <returns>JSON String</returns>
        public String deleteUser(String snric, String email)
        {
            dynamic responseJson = new ExpandoObject();
            responseJson.Result = "Success";
           procedureCall = new GenericProcedureDAO("DELETE_STAFF", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pNric", snric);
            procedureCall.addParameterWithValue("@pEmail", email);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                responseJson.Msg = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                responseJson.Result = "Failure";
                responseJson.Msg = ex.Message;
            }

            return Newtonsoft.Json.JsonConvert.SerializeObject(responseJson);
        }

        /// <summary>
        /// Updates a specific row in the Staff Table
        /// </summary>
        /// <param name="fname"></param>
        /// <param name="lname"></param>
        /// <param name="snric"></param>
        /// <param name="email"></param>
        /// <param name="address"></param>
        /// <param name="postal"></param>
        /// <param name="mobtel"></param>
        /// <param name="hometel"></param>
        /// <param name="alttel"></param>
        /// <param name="sex"></param>
        /// <param name="nationality"></param>
        /// <param name="dob"></param>
        /// <param name="title"></param>
        /// <param name="permissions"></param>
        /// <param name="password"></param>
        /// <param name="staffUser"></param>
        /// <param name="accessProfile"></param>
        /// <returns>JSON String</returns>
        public String updateUser(String fname, String lname, String snric, String email, String address, String postal, String mobtel, String hometel, String alttel, String sex,
            String nationality, String dob, String title, int permissions, String password, String staffUser, String accessProfile)
        {
            dynamic responseJson = new ExpandoObject();
            responseJson.Result = "Success";
            int pos = 0;
            if (postal != "")
            {
                pos = Int32.Parse(postal);
            }
           procedureCall = new GenericProcedureDAO("UPDATE_STAFF", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pEmail", email);
            procedureCall.addParameterWithValue("@pPassword", password);
            procedureCall.addParameterWithValue("@pFirstName", fname);
            procedureCall.addParameterWithValue("@pLastName", lname);
            procedureCall.addParameterWithValue("@pNric", snric);
            procedureCall.addParameterWithValue("@pAddress", address);
            procedureCall.addParameterWithValue("@pPostalCode", pos);
            procedureCall.addParameterWithValue("@pHomeTel", hometel);
            procedureCall.addParameterWithValue("@pAltTel", alttel);
            procedureCall.addParameterWithValue("@pMobileTel", mobtel);
            procedureCall.addParameterWithValue("@pSex", sex);
            procedureCall.addParameterWithValue("@pNationality", nationality);
            procedureCall.addParameterWithValue("@pDateOfBirth", DateTime.ParseExact(dob, "dd-MM-yyyy", CultureInfo.InvariantCulture));
            procedureCall.addParameterWithValue("@pPermission", permissions);
            procedureCall.addParameterWithValue("@pAccessProfile", accessProfile);
            procedureCall.addParameterWithValue("@pPosition", title);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                responseJson.Msg = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                responseJson.Result = "Failure";
                responseJson.Msg = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(responseJson);
        }

        /// <summary>
        /// Returns a string of the available user permissions
        /// </summary>
        /// <returns>JSON String</returns>
        public String getPermissions()
        {
            String successString = "";
            dynamic jsonObj = new ExpandoObject();
            dynamic responseJson = new ExpandoObject();
            ArrayList contentOf = new ArrayList();
           procedureCall = new GenericProcedureDAO("GET_USER_PERMISSIONS", false, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                DataTableReader reader = responseOutput.getDataTable().CreateDataReader();
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
            }
            successString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonObj); ;
            return successString;
        }


    }
}