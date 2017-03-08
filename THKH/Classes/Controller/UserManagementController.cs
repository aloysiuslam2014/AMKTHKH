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

        // Gets a specific row from the Staff Table
        public String getUser(String email)
        {
            String successString = "";//result and msg 
            dynamic jsonObj = new ExpandoObject();
            dynamic responseJson = new ExpandoObject();
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
                        responseJson.nationality = reader.GetString(10);
                        responseJson.dateOfBirth = reader.GetDateTime(11).ToString("dd/MM/yyyy");
                        responseJson.permissions = reader.GetInt32(14);
                        responseJson.position = reader.GetString(16);
                        responseJson.accessProfile = reader.GetString(15);

                        count++;
                    }
                }
                jsonObj.Result = responseJson;
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

        // Creates a new row in the Staff Table
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

        // Deletes a specific row in the Staff Table
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

        // Updates a specific row in the Staff Table
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
            procedureCall.addParameterWithValue("@pDateOfBirth", DateTime.ParseExact(dob, "dd/MM/yyyy", CultureInfo.InvariantCulture));
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

        public String getPermissions()
        {
            String successString = "";//result and msg 
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