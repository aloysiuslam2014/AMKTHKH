using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Dynamic;
using System.Globalization;
using System.Linq;
using System.Web;
using THKH.Classes.DAO;
using THKH.Classes.Entity;

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

            var typeOfRequest = context.Request.Form["requestType"];
            if (typeOfRequest == "getdetails") {
                var nric = context.Request.Form["nric"].ToString();
                successString = getVisitorDetails(nric);
            }
            if (typeOfRequest == "form") {
                successString = loadForm();
            }
            if (typeOfRequest == "pName")
            {
                var bedNo = context.Request.Form["bedNo"];
                successString = getPatientNames(bedNo);
            }
            if (typeOfRequest == "self")
            {
                var nric = context.Request.Form["nric"].ToString();
                var fname = context.Request.Form["fullName"];
                var address = context.Request.Form["ADDRESS"];
                var postal = context.Request.Form["POSTAL"];
                var mobtel = context.Request.Form["MobTel"];
                var sex = context.Request.Form["SEX"];
                var nationality = context.Request.Form["Natl"];
                var dob = context.Request.Form["DOB"];
                var purpose = context.Request.Form["PURPOSE"];
                var pName = context.Request.Form["pName"];
                var pNric = context.Request.Form["pNric"];
                var otherPurpose = context.Request.Form["otherPurpose"];
                var bedno = context.Request.Form["bedno"];
                var appTime = context.Request.Form["appTime"];
                var remarks = context.Request.Form["remarks"];
                var visitLocation = context.Request.Form["visitLocation"];
                var qListID = context.Request.Form["qListID"];
                var qAns = context.Request.Form["qAnswers"];
                long ticks = DateTime.Now.Ticks;
                byte[] bytes = BitConverter.GetBytes(ticks);
                string qaid = Convert.ToBase64String(bytes)
                                        .Replace('+', '_')
                                        .Replace('/', '-')
                                        .TrimEnd('=');
                var amend = context.Request.Form["amend"];

                // Write to Visitor_Profile & Visit Table
                successString = selfReg(nric, fname, address, postal, mobtel,
            sex, nationality, dob, purpose,  otherPurpose, bedno, appTime,
            visitLocation, qListID, qAns, qaid, amend);
        }
        if (typeOfRequest == "patient") {
                var pName = context.Request.Form["pName"];
                var bedno = context.Request.Form["bedno"];
                successString = checkPatient(pName, bedno);
        }
        if (typeOfRequest == "confirmation") {
                // Write to Visitor_Profile, Visit, Confirmed & CheckInCheckOut Tables
                var staffUser = context.Request.Form["staffUser"].ToString();
                var nric = context.Request.Form["nric"].ToString();
                var temperature = context.Request.Form["temperature"];
                var age = context.Request.Form["AGE"];
                var fname = context.Request.Form["fullName"];
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
                var qListID = context.Request.Form["qListID"];
                var qAns = context.Request.Form["qAnswers"];
                var qAnsId = context.Request.Form["qaid"];
                var visLim = context.Request.Form["visLim"];

                successString = AssistReg(staffUser,nric, age, fname, address, postal, mobtel, alttel, hometel,
            sex, nationality, dob, race, email, purpose, pName, pNric, otherPurpose, bedno, appTime,
            fever, symptoms, influenza, countriesTravelled, remarks, visitLocation, temperature, qListID, qAns, qAnsId, visLim);
            }
            if (typeOfRequest == "facilities") {
                successString = getFacilities();
            }
            context.Response.Write(successString);// String to return to front-end
        }

        private String getFacilities() {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            SqlConnection cnn;
            String fac = "";
            //String successString = "{\"Result\":\"Success\",\"Facilities\":\"";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_ALL_FACILITIES]", cnn);
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
                            fac += ",";
                            //successString += ",";
                        }
                        fac += reader.GetString(1);
                        //successString += reader.GetString(1);
                        count++;
                    }
                }
                reader.Close();
                result.Facilities = fac;
            }
            catch (Exception ex)
            {
                //successString.Replace("Success", "Failure");
                result.Result = "Failure";
                result.Facilities = ex.Message;
                return Newtonsoft.Json.JsonConvert.SerializeObject(result);
                //successString += ex.Message;
                //successString += "\"}";
                //return successString;
            }
            finally
            {
                cnn.Close();
            }
            //successString += "\"}";
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        private String loadForm() {
            SqlConnection cnn;
            //String successString = "{\"Result\":\"Success\",\"Msg\":";
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[RETRIEVE_ACTIVE_QUESTIONNARIE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.Add(respon);
                cnn.Open();

                //command.ExecuteNonQuery();
                SqlDataReader reader = command.ExecuteReader();
                List<ExpandoObject> list = new List<ExpandoObject>();
                int count = 1;
                if (reader.HasRows)
                {
                    //successString += "[";
                    while (reader.Read())
                    {
                        dynamic row = new ExpandoObject();
                        row.QuestionNumber = reader.GetInt32(1);
                        row.QuestionList = reader.GetString(0);
                        row.Question = reader.GetString(2);
                        row.QuestionType = reader.GetString(3);
                        row.QuestionAnswers = reader.GetString(4);
                        //if (count > 1) {
                        //successString += ",";
                        //}
                        //successString += "{\"QuestionNumber\":\"";
                        //successString += reader.GetInt32(1) + "\",\"QuestionList\":\"" + reader.GetString(0) +"\",\"Question\":\"" + reader.GetString(2) + "\",\"QuestionType\":\"" + reader.GetString(3) + "\",\"QuestionAnswers\":\"" + reader.GetString(4);
                        //successString += "\"}";
                        list.Add(row);
                        count++;
                    }
                    //successString += "]";
                }
                //successString += respon.Value;
                reader.Close();
                result.Msg = list;
                //successString += "\"}";
            }
            catch (Exception ex)
            {
                //successString.Replace("Success", "Failure");
                //successString += ex.Message;
                //successString += "\"}";
                //return successString;
                result.Result = "Failure";
                result.Msg = ex.Message;
                return Newtonsoft.Json.JsonConvert.SerializeObject(result);
            }
            finally
            {
                cnn.Close();
            }
            //successString += "}";
            //return successString;
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // Check if patient exists in the Patient Database
        private String checkPatient(String pName, String bedno) {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            SqlConnection cnn;
            //String successString = "{\"Result\":\"Success\",\"Msg\":\"";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.VarChar, 500);
            respon.Direction = ParameterDirection.Output;
            try
            {
                //SqlCommand command = new SqlCommand("[dbo].[CONFIRM_HOSPITAL_PATIENT]", cnn);
                SqlCommand command = new SqlCommand("[dbo].[CONFIRM_PATIENT]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pBedNo", bedno);
                command.Parameters.AddWithValue("@pPatientFullName", pName);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                result.Msg = respon.Value;
                //successString += respon.Value;
            }
            catch (Exception ex)
            {
                //successString.Replace("Success", "Failure");
                //successString += ex.Message;
                //successString += "\"}";
                result.Result = "Failure";
                result.Msg = ex.Message;
                return Newtonsoft.Json.JsonConvert.SerializeObject(result);
            }
            finally
            {
                cnn.Close();
            }
            //successString += "\"}";
            //return successString;
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        private String getVisitorDetails(String nric) {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            SqlConnection cnn;
            //String successString = "{\"Result\":\"Success\",\"Visitor\":\"";
            //cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            //SqlParameter respon = new SqlParameter("@returnValue", SqlDbType.VarChar, -1);
            
            //respon.Direction = ParameterDirection.Output;
            String msg = "";
            String visJson = "";
            try
            {
                //SqlCommand command = new SqlCommand("[dbo].[GET_VISITOR]", cnn);
                //command.CommandType = System.Data.CommandType.StoredProcedure;
                //command.Parameters.AddWithValue("@pNRIC", nric);
                //command.Parameters.Add("@responseMessage", SqlDbType.Int).Direction = ParameterDirection.Output;
                //command.Parameters.Add(respon);
                //cnn.Open();

                //command.ExecuteNonQuery();
                //String response = respon.Value.ToString();
                GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_VISITOR", true, true, false);
                procedureCall.addParameter("@responseMessage", SqlDbType.Int);
                procedureCall.addParameter("@returnValue", SqlDbType.VarChar);
                procedureCall.addParameterWithValue("@pNRIC", nric);
                ProcedureResponse res = procedureCall.runProcedure();
                String response = res.getResponses()["@returnValue"].ToString();

                if (!response.Contains("Visitor not found"))
                {
                    //msg += response;
                    result.Visitor = response;
                    var arr = response.Split(',');
                    Visitor vistr = new Visitor(arr[1], arr[0], arr[2].Trim(), arr[3], arr[4], arr[5], arr[6], arr[7]);
                    visJson = vistr.toJson();
                }
                else {
                    //successString += "new";
                    //successString += "\"}";
                    //return successString;
                    result.Visitor = "new";
                    return JsonConvert.SerializeObject(result);
                }   
            }
            catch (Exception ex)
            {
                //successString.Replace("Success", "Failure");
                //successString += ex.Message;
                //successString += "\"}";
                //return successString;
                result.Result = "Failure";
                result.Visitor = ex.Message;
                return JsonConvert.SerializeObject(result);
            }
            finally
            {
                //cnn.Close();
            }
            try
            {
                var tempMsg = getVisitDetails(nric);
                if (tempMsg != "none")
                {
                    //msg += "\"," + tempMsg;
                    result.Visit = tempMsg;
                    var arr = tempMsg.Split(',');
                    var qAID = arr[arr.Length - 3];
                    //msg += "\"," + getSubmittedQuestionnaireResponse(qAID);
                    result.Questionnaire = JsonConvert.DeserializeObject(getSubmittedQuestionnaireResponse(qAID));
                }
                else {
                    //successString += msg;
                    //successString += "\"}";
                    //return successString;
                    return JsonConvert.SerializeObject(result);
                }
            }
            catch (Exception ex) {
                //successString.Replace("Success", "Failure");
                result.Result = "Failure";
                result.Visitor = ex.Message;
                //msg = ex.Message;
                //successString += "\"}";
                //return successString;
                return JsonConvert.SerializeObject(result);
            }
            //successString += msg;
            //successString += "}";
            //return successString;
            return JsonConvert.SerializeObject(result);
        }

        private String getVisitDetails(String nric)
        {
            dynamic result = new ExpandoObject();
            SqlConnection cnn;
            String successString = "";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.VarChar, -1);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_VISIT_DETAILS]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNric", nric);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                String response = respon.Value.ToString();
                if (response.Length > 4)
                {
                    successString += response;
                    //result.Visit = response;
                }
                else
                {
                    successString += "none";
                    //successtring += "\"}";
                    return successString;
                    //result.Visit = "none";
                    //return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                cnn.Close();
            }
            return successString;
            //return result;
        }

        private String getSubmittedQuestionnaireResponse(String qAID) {
            SqlConnection cnn;
            //dynamic result = new ExpandoObject();
            //String successString = "\"QAID\":\"" + qAID + "\",\"Questionnaire\":";
            //String successString = "\"Questionnaire\":";
            String successString = "";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.VarChar, -1);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_QUESTIONNARIE_RESPONSE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pQA_ID", qAID);
                command.Parameters.Add(respon);
                cnn.Open();


                SqlDataReader reader = command.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        successString += reader.GetString(0);
                        //result.Questionnaire = reader.GetString(0);
                    }
                }
                else {
                    successString += "none";
                    //result.Questionnaire = "none";
                }
                successString.Replace("{", String.Empty);
                successString.Replace("}", String.Empty);
                //result.Questionnaire = successString;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                cnn.Close();
            }
            return successString;
            //return result;
        }

        // Write to Visitor & Visit Table
        private String selfReg(String nric, String fname, String address, String postal, String mobtel,
            String sex, String nationality, String dob, String purpose, String otherPurpose, String bedno, String appTime,
            String visitLocation, String qListID, String qAns, String qaid, String amend) {
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            var visitor = "";
            var visit = "";
            var questionnaire = "";
            //String successString = "{\"Result\":\"Success\"";
            //String msg = "";
            if (amend == "1")
            {
                try
                {
                    SqlCommand command = new SqlCommand("[dbo].[CREATE_VISITOR_PROFILE]", cnn);
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@pNRIC", nric.ToUpper());
                    command.Parameters.AddWithValue("@pFullName", fname);
                    command.Parameters.AddWithValue("@pGender", sex);
                    command.Parameters.AddWithValue("@pNationality", nationality);
                    command.Parameters.AddWithValue("@pDateOfBirth", DateTime.ParseExact(dob, "dd-MM-yyyy", CultureInfo.InvariantCulture));
                    command.Parameters.AddWithValue("@pMobileTel", mobtel);
                    command.Parameters.AddWithValue("@pHomeAddress", address);
                    command.Parameters.AddWithValue("@pPostalCode", postal);
                    command.Parameters.AddWithValue("@pAmend", Int32.Parse(amend));
                    command.Parameters.Add(respon);
                    cnn.Open();

                    command.ExecuteNonQuery();
                    //msg += ",\"Visitor\":\""+ respon.Value + "\"";
                    visitor = respon.Value.ToString();
                }
                catch (Exception ex)
                {
                    //successString = successString.Replace("Success", "Failure");
                    //msg = ex.Message;
                    //successString += ",\"Visitor\":\"" + msg;
                    //successString += "\"}";
                    //return successString;
                    result.Result = "Failure";
                    result.Visitor = ex.Message;
                    return JsonConvert.SerializeObject(result);
                }
                finally
                {
                    cnn.Close();
                }
            }
            try
            {
                //msg += writeQuestionnaireResponse(qaid, qListID, qAns);
                questionnaire = writeQuestionnaireResponse(qaid, qListID, qAns);
            }
            catch (Exception ex)
            {
                //successString = successString.Replace("Success", "Failure");
                //msg = "\"" + ex.Message;
                //successString += msg;
                //successString += "\"}";
                //return successString;
                result.Result = "Failure";
                result.Visitor = ex.Message;
                return JsonConvert.SerializeObject(result);
            }
            respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[CREATE_VISIT]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pVisitRequestTime", DateTime.Parse(appTime));
                command.Parameters.AddWithValue("@pVisitorNRIC", nric.ToUpper());
                command.Parameters.AddWithValue("@pPurpose", purpose);
                command.Parameters.AddWithValue("@pReason", otherPurpose);
                command.Parameters.AddWithValue("@pVisitLocation", visitLocation);
                command.Parameters.AddWithValue("@pBedNo", bedno);
                command.Parameters.AddWithValue("@pQaID", qaid);
                command.Parameters.AddWithValue("@pRemarks", "");
                command.Parameters.Add("@responseMessage", SqlDbType.Int).Direction = ParameterDirection.Output;
                cnn.Open();

                command.ExecuteNonQuery();
                //msg += ",\"Visit\":\"" + respon.Value + "\"";
                if (respon.Value != null) { 
                    visit = respon.Value.ToString();
                }
            }
            catch (Exception ex)
            {
                //successString = successString.Replace("Success", "Failure");
                //msg = ",\"Visit\":\"" + ex.Message + "\"";
                result.Result = "Failure";
                result.Visit = ex.Message;
                return JsonConvert.SerializeObject(result);
            }
            finally
            {
                cnn.Close();
            }
            //successString += msg;
            //successString += "}";
            //return successString;
            result.Visitor = visitor;
            result.Visit = visit;
            result.Questionnaire = questionnaire;
            return JsonConvert.SerializeObject(result);
        }

        //Gets patient name from db 
        public string getPatientNames(string beds)
        {
            string successString = "";
            dynamic toSend = new ExpandoObject();
            SqlConnection cnn;

            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            SqlParameter patientName = new SqlParameter("@pPatient_Name", SqlDbType.VarChar);
            respon.Direction = ParameterDirection.Output;
            patientName.Direction = ParameterDirection.Output;
            patientName.Size = 1000;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_PATIENT_NAME]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pBed_No", beds);
                command.Parameters.Add(respon);
                command.Parameters.Add(patientName);
                cnn.Open();
                command.ExecuteNonQuery();
                cnn.Close(); 

            }
            catch(Exception e)
            {
                toSend.error = e.Message.ToString();
                successString = JsonConvert.SerializeObject(toSend);
                return successString;
            }
            toSend.name = patientName.Value.ToString();
            successString = JsonConvert.SerializeObject(toSend);
            return successString;
        }


        // Write to Visitor, Visit & Confirmation Table
        private String AssistReg(String staffuser, String nric, String age, String fname, String address, String postal, String mobtel, String alttel, String hometel,
            String sex, String nationality, String dob, String race, String email, String purpose, String pName, String pNric, String otherPurpose, String bedno, String appTime,
            String fever, String symptoms, String influenza, String countriesTravelled, String remarks, String visitLocation, String temperature, String qListID, String qAns, String qaid, String visLim) {
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            String visitor = "";
            String visit = "";
            String questionnaire = "";
            String checkin = "";
            //String successString = "{\"Result\":\"Success\",\"Visitor\":";
            //String msg = "\"";
            string qAid = qaid;
            int pos = 0;
            try
            {
                pos = Int32.Parse(postal);
            }
            catch (Exception ex) {
            }
            //update visitor profile
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE_VISITOR_PROFILE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNRIC", nric.ToUpper());
                command.Parameters.AddWithValue("@pFullName", fname);
                command.Parameters.AddWithValue("@pGender", sex);
                command.Parameters.AddWithValue("@pNationality", nationality);
                command.Parameters.AddWithValue("@pDateOfBirth", DateTime.ParseExact(dob, "dd-MM-yyyy", CultureInfo.InvariantCulture));
                command.Parameters.AddWithValue("@pMobileTel", mobtel);
                command.Parameters.AddWithValue("@pHomeAddress", address);
                command.Parameters.AddWithValue("@pPostalCode", pos);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                //msg += respon.Value + "\"";
                visitor = respon.Value.ToString();
            }
            catch (Exception ex)
            {
                //successString = successString.Replace("Success", "Failure");
                //msg = ex.Message;
                //successString += "\"" + msg;
                //successString += "\"}";
                //return successString;
                result.Result = "Failure";
                result.Visitor = ex.Message;
                return JsonConvert.SerializeObject(result);
            }
            finally
            {
                cnn.Close();
            }

            //update or add questionaire ans
            try
            {
                if (qAid == "")
                {
                    long ticks = DateTime.Now.Ticks;
                    byte[] bytes = BitConverter.GetBytes(ticks);
                    qAid = Convert.ToBase64String(bytes) // Find a way to generate UNIQUE numbers!!!
                                            .Replace('+', '_')
                                            .Replace('/', '-')
                                            .TrimEnd('=');
                    //msg += writeQuestionnaireResponse(qAid, qListID, qAns);
                    questionnaire = writeQuestionnaireResponse(qAid, qListID, qAns);

                }
                else
                {
                    //msg += updateQuestionnaireResponse(qAid, qListID, qAns);
                    questionnaire = updateQuestionnaireResponse(qAid, qListID, qAns);
                }
            }
            catch (Exception ex)
            {
                //successString = successString.Replace("Success", "Failure");
                //msg = ex.Message;
                //successString += "\"" + msg;
                //successString += "\"}";
                //return successString;
                result.Result = "Failure";
                result.Visitor = ex.Message;
                return JsonConvert.SerializeObject(result);
            }
            //check number of visitors currently with patient
            if (purpose == "Visit Patient")
            {
                try
                {
                    int limit = Int32.Parse(visLim);
                    var bedArr = bedno.Split('|');
                    Boolean valid = true;
                    for (int i = 0; i < bedArr.Length; i++)
                    {
                        dynamic num = checkNumCheckedIn(bedArr[i], limit);
                        if (num.visitors >= limit) // May need to change to DB side
                        {
                            valid = false;
                        }
                    }
                    if (valid) // May need to change to DB side
                    {
                        //msg += CheckIn(staffuser, nric, temperature);
                        checkin = CheckIn(staffuser, nric, temperature);
                    }
                    else
                    {
                        //successString = successString.Replace("Success", "Failure");
                        //successString += "\"Limit of " + visLim + " per bed has been reached.";
                        
                        //successString += "\"}";
                        //return successString;
                        result.Result = "Failure";
                        result.Visitor = "Limit of " + visLim + " per bed has been reached.";
                        return JsonConvert.SerializeObject(result);
                    }
                }
                catch (Exception ex)
                {
                    //successString = successString.Replace("Success", "Failure");
                    //msg = "\"" + ex.Message;
                    //successString += "\"}";
                    //return successString;
                    result.Result = "Failure";
                    result.Visitor = ex.Message;
                    return JsonConvert.SerializeObject(result);
                }
            }
            else {
                try
                {
                    //msg += CheckIn(staffuser, nric, temperature);
                    checkin = CheckIn(staffuser, nric, temperature);
                }
                catch (Exception ex) {
                    //successString = successString.Replace("Success", "Failure");
                    //msg = "\"" + ex.Message;
                    //successString += "\"}";
                    //return successString;
                    result.Result = "Failure";
                    result.Visitor = ex.Message;
                    return JsonConvert.SerializeObject(result);
                }
            }

            respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE_VISIT]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pVisitRequestTime", DateTime.Parse(appTime));
                command.Parameters.AddWithValue("@pVisitorNRIC", nric.ToUpper());
                command.Parameters.AddWithValue("@pPurpose", purpose);
                command.Parameters.AddWithValue("@pReason", otherPurpose);
                command.Parameters.AddWithValue("@pVisitLocation", visitLocation);
                command.Parameters.AddWithValue("@pBedNo", bedno);
                command.Parameters.AddWithValue("@pQaID", qAid);
                command.Parameters.AddWithValue("@pRemarks", remarks);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                //msg += ",\"Visit\":\"" + respon.Value + "\"";
                visit = respon.Value.ToString();
            }
            catch (Exception ex)
            {
                //successString = successString.Replace("Success", "Failure");
                //successString += msg;
                //msg = ",\"Visit\":\"" + ex.Message;
                //successString += msg;
                //successString += "\"}";
                //return successString;
                result.Result = "Failure";
                result.Visit = ex.Message;
                return JsonConvert.SerializeObject(result);
            }
            finally
            {
                cnn.Close();
            }


            //successString += msg;
            //successString += "}";
            //return successString;
            result.Visitor = visitor;
            result.Visit = visit;
            result.Questionnaire = questionnaire;
            result.CheckIn = checkin;
            return JsonConvert.SerializeObject(result);
        }

        
        private String writeQuestionnaireResponse(String qaid, String qListID, String qAns) {
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            String result = "";
            //String successString = ",\"Questionnaire\":\"";
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[INSERT_QUESTIONNARIE_RESPONSE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pQA_ID", qaid);
                command.Parameters.AddWithValue("@pQ_QuestionListID", qListID);
                command.Parameters.AddWithValue("@pQA_JSON", qAns);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                //successString += respon.Value +"\"";
                result += respon.Value.ToString();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                cnn.Close();
            }
            return result;
            //return successString;
        }

        private String updateQuestionnaireResponse(String qaid, String qListID, String qAns)
        {
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            String result = "";
            //String successString = ",\"Questionnaire\":\"";
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE_QUESTIONNARIE_RESPONSE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pQA_ID", qaid);
                command.Parameters.AddWithValue("@pQA_JSON", qAns);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                //successString += respon.Value + "\"";
                result = respon.Value.ToString();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                cnn.Close();
            }
            //return successString;
            return result;
        }

        private dynamic checkNumCheckedIn(string bedno, int limit) {
            DataTable dataTable = new DataTable();
            dynamic result = new ExpandoObject();
            
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
           
           
            try
            {
                string[] beds = bedno.Split('|');
                foreach(string bed in beds)
                {
                    GenericProcedureDAO procedureCall = new GenericProcedureDAO("CHECK_NUM_VISITORS", true, true, false);
                    procedureCall.addParameter("@responseMessage", SqlDbType.Int);
                    procedureCall.addParameterWithValue("@pBedNo", bed);
                    procedureCall.addParameterWithValue("@pLimit", limit.ToString());
                    ProcedureResponse res = procedureCall.runProcedure();
                    result.visitors = res.getResponses()["@responseMessage"];
                    //SqlCommand command = new SqlCommand("[dbo].[CHECK_NUM_VISITORS]", cnn);
                    //command.CommandType = System.Data.CommandType.StoredProcedure;
                    //command.Parameters.AddWithValue("@pBedNo", bed);
                    //command.Parameters.AddWithValue("@pLimit", limit);
                    //SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
                    //respon.Direction = ParameterDirection.Output;
                    //command.Parameters.Add(respon);
                    //cnn.Open();

                    //command.ExecuteNonQuery();
                    //cnn.Close();
                    //result.visitors = respon.Value;
                    if (result.visitors >= limit)
                    {
                        result.bedno = bed;
                        break;
                    }

                }
               
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if(cnn.State.ToString() == "open")
                cnn.Close();
            }
            return result;
        }

        private String CheckIn(String staffuser,String nric, String temp) {
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            //String successString = ",\"CheckIn\":\""; 
            String result = "";
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[CONFIRM_CHECK_IN]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNric", nric.ToUpper());
                command.Parameters.AddWithValue("@pStaffEmail", staffuser);
                command.Parameters.AddWithValue("@pTemperature", temp);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                //successString += respon.Value + "\"";
                result = respon.Value.ToString();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                cnn.Close();
            }
            //return successString;
            return result;
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