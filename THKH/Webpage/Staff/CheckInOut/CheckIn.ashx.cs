using Newtonsoft.Json;
using System;
using System.Collections;
using System.Data;
using System.Dynamic;
using System.Globalization;
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
            String fac = "";

            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_ALL_FACILITIES", false, true, true);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            try
            {
                ProcedureResponse resultss = procedureCall.runProcedure();
                DataTable response = resultss.getDataTable();
                DataTableReader reader = response.CreateDataReader();
                int count = 1;
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        if (count > 1)
                        {
                            fac += ",";
                        }
                        fac += reader.GetString(1);
                        count++;
                    }
                }
                reader.Close();
                result.Facilities = fac;
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Facilities = ex.Message;
                return Newtonsoft.Json.JsonConvert.SerializeObject(result);
            }
            
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        private String loadForm() {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            ArrayList questionItems = new ArrayList();

            GenericProcedureDAO procedureCall = new GenericProcedureDAO("RETRIEVE_ACTIVE_QUESTIONNARIE", false, true, true);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            try
            {
                ProcedureResponse responses = procedureCall.runProcedure();
                DataTableReader reader = responses.getDataTable().CreateDataReader();
                if (reader.HasRows)
                {
                     
                    while (reader.Read())
                    {
                        dynamic questionO = new ExpandoObject();
                        questionO.QuestionNumber = reader.GetInt32(1);
                        questionO.QuestionList = reader.GetString(1);
                        questionO.Question = reader.GetString(2);
                        questionO.QuestionType = reader.GetString(3);
                        questionO.QuestionAnswers = reader.GetString(4);
                        questionItems.Add(questionO);
                    }
                     
                }
                
                reader.Close();
                result.Msg = questionItems;
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
               
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // Check if patient exists in the Patient Database
        private String checkPatient(String pName, String bedno) {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("CONFIRM_PATIENT", true, true, false);
            procedureCall.addParameter("@responseMessage", SqlDbType.VarChar, 500);
            procedureCall.addParameterWithValue("@pBedNo", bedno);
            procedureCall.addParameterWithValue("@pPatientFullName", pName);
            try
            {
                ProcedureResponse resultss = procedureCall.runProcedure();
                result.Msg = resultss.getSqlParameterValue("@responseMessage");
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        private String getVisitorDetails(String nric) {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            String visJson = "";
            try
            {
          
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
                  
                    result.Visitor = "new";
                    return JsonConvert.SerializeObject(result);
                }   
            }
            catch (Exception ex)
            {
              
                result.Result = "Failure";
                result.Visitor = ex.Message;
                return JsonConvert.SerializeObject(result);
            }
            
            try
            {
                dynamic tempMsg = getVisitDetails(nric);
                if (tempMsg.Visit != "none")
                {
                   
                    result.Visit = tempMsg.Visit;
                    var arr = tempMsg.Split(',');
                    var qAID = arr[arr.Length - 3];
                   
                    result.Questionnaire = JsonConvert.DeserializeObject(getSubmittedQuestionnaireResponse(qAID));
                }
                else {
                  
                    return JsonConvert.SerializeObject(result);
                }
            }
            catch (Exception ex) {
                result.Result = "Failure";
                result.Visitor = ex.Message;
              
            }
        
            return JsonConvert.SerializeObject(result);
        }

        private dynamic getVisitDetails(String nric)
        {
            dynamic result = new ExpandoObject();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_VISIT_DETAILS", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.VarChar, -1);
            procedureCall.addParameterWithValue("@pNric", nric);
            try
            {
                ProcedureResponse resultdata =  procedureCall.runProcedure();


                String response = resultdata.getSqlParameterValue("@responseMessage").ToString();
                if (response.Length > 4)
                {
                    result.Visit = response;
                }
                else
                {
                    result.Visit = "none";
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            
            
            return result;
        }

        private String getSubmittedQuestionnaireResponse(String qAID) {
            String successString = "";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_QUESTIONNARIE_RESPONSE", true, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.VarChar, -1);
            procedureCall.addParameterWithValue("@pQA_ID", qAID);
            
            try
            {
                ProcedureResponse responseResult = procedureCall.runProcedure();
                DataTableReader reader = responseResult.getDataTable().CreateDataReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        successString += reader.GetString(0);
                    }
                }
                else {
                    successString += "none";
                }
                successString.Replace("{", String.Empty);
                successString.Replace("}", String.Empty);
            }
            catch (Exception ex)
            {
                throw ex;
            }
           
            return successString;
        }

        // Write to Visitor & Visit Table
        private String selfReg(String nric, String fname, String address, String postal, String mobtel,
            String sex, String nationality, String dob, String purpose, String otherPurpose, String bedno, String appTime,
            String visitLocation, String qListID, String qAns, String qaid, String amend) {
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("CREATE_VISITOR_PROFILE", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pNRIC", nric.ToUpper());
            procedureCall.addParameterWithValue("@pFullName", fname);
            procedureCall.addParameterWithValue("@pGender", sex);
            procedureCall.addParameterWithValue("@pNationality", nationality);
            procedureCall.addParameterWithValue("@pDateOfBirth", DateTime.ParseExact(dob, "dd-MM-yyyy", CultureInfo.InvariantCulture));
            procedureCall.addParameterWithValue("@pMobileTel", mobtel);
            procedureCall.addParameterWithValue("@pHomeAddress", address);
            procedureCall.addParameterWithValue("@pPostalCode", postal);
            procedureCall.addParameterWithValue("@pAmend", Int32.Parse(amend));
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            var visitor = "";
            var visit = "";
            var questionnaire = "";
            if (amend == "1")
            {
                try
                {
                    ProcedureResponse outputdata = procedureCall.runProcedure();
                    visitor = outputdata.getSqlParameterValue("@responseMessage").ToString();
                }
                catch (Exception ex)
                {
                    result.Result = "Failure";
                    result.Visitor = ex.Message;
                    return JsonConvert.SerializeObject(result);
                }
               
            }
            try
            {
                //msg += writeQuestionnaireResponse(qaid, qListID, qAns);
                questionnaire = writeQuestionnaireResponse(qaid, qListID, qAns);
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Visitor = ex.Message;
                return JsonConvert.SerializeObject(result);
            }
            procedureCall = new GenericProcedureDAO("CREATE_VISIT", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pVisitRequestTime", DateTime.Parse(appTime));
            procedureCall.addParameterWithValue("@pVisitorNRIC", nric.ToUpper());
            procedureCall.addParameterWithValue("@pPurpose", purpose);
            procedureCall.addParameterWithValue("@pReason", otherPurpose);
            procedureCall.addParameterWithValue("@pVisitLocation", visitLocation);
            procedureCall.addParameterWithValue("@pBedNo", bedno);
            procedureCall.addParameterWithValue("@pQaID", qaid);
            procedureCall.addParameterWithValue("@pRemarks", "");
            try
            {
                ProcedureResponse responsedata = procedureCall.runProcedure();
                string respon = responsedata.getSqlParameterValue("@responseMessage").ToString();
                //msg += ",\"Visit\":\"" + respon.Value + "\"";
                if (respon != null) {
                    visit = respon;
                }
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Visit = ex.Message;
                return JsonConvert.SerializeObject(result);
            }
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
            
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_PATIENT_NAME", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameter("@pPatient_Name", SqlDbType.VarChar,1000);
            procedureCall.addParameterWithValue("@pBed_No", beds); 
            try
            {
                ProcedureResponse responseOutput =  procedureCall.runProcedure();
                toSend.name = responseOutput.getSqlParameterValue("@pPatient_Name").ToString();
            }
            catch(Exception e)
            {
                toSend.error = e.Message.ToString();
                successString = JsonConvert.SerializeObject(toSend);
                return successString;
            }
            
            successString = JsonConvert.SerializeObject(toSend);
            return successString;
        }


        // Write to Visitor, Visit & Confirmation Table
        private String AssistReg(String staffuser, String nric, String age, String fname, String address, String postal, String mobtel, String alttel, String hometel,
            String sex, String nationality, String dob, String race, String email, String purpose, String pName, String pNric, String otherPurpose, String bedno, String appTime,
            String fever, String symptoms, String influenza, String countriesTravelled, String remarks, String visitLocation, String temperature, String qListID, String qAns, String qaid, String visLim) {
            
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            String visitor = "";
            String visit = "";
            String questionnaire = "";
            String checkin = "";
            string qAid = qaid;
            int pos = 0;
            try
            {
                pos = Int32.Parse(postal);
            }
            catch (Exception ex) {
            }
            //update visitor profile
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("UPDATE_VISITOR_PROFILE", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pNRIC", nric.ToUpper());
            procedureCall.addParameterWithValue("@pFullName", fname);
            procedureCall.addParameterWithValue("@pGender", sex);
            procedureCall.addParameterWithValue("@pNationality", nationality);
            procedureCall.addParameterWithValue("@pDateOfBirth", DateTime.ParseExact(dob, "dd-MM-yyyy", CultureInfo.InvariantCulture));
            procedureCall.addParameterWithValue("@pMobileTel", mobtel);
            procedureCall.addParameterWithValue("@pHomeAddress", address);
            procedureCall.addParameterWithValue("@pPostalCode", pos);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                visitor = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Visitor = ex.Message;
                return JsonConvert.SerializeObject(result);
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
                    questionnaire = writeQuestionnaireResponse(qAid, qListID, qAns);

                }
                else
                {
                    questionnaire = updateQuestionnaireResponse(qAid, qListID, qAns);
                }
            }
            catch (Exception ex)
            {
              
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
                        result.Result = "Failure";
                        result.Visitor = "Limit of " + visLim + " per bed has been reached.";
                        return JsonConvert.SerializeObject(result);
                    }
                }
                catch (Exception ex)
                {
                    result.Result = "Failure";
                    result.Visitor = ex.Message;
                    return JsonConvert.SerializeObject(result);
                }
            }
            else {
                try
                {
                    checkin = CheckIn(staffuser, nric, temperature);
                }
                catch (Exception ex) {
                    result.Result = "Failure";
                    result.Visitor = ex.Message;
                    return JsonConvert.SerializeObject(result);
                }
            }

            procedureCall = new GenericProcedureDAO("UPDATE_VISIT", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pVisitRequestTime", DateTime.Parse(appTime));
            procedureCall.addParameterWithValue("@pVisitorNRIC", nric.ToUpper()); 
            procedureCall.addParameterWithValue("@pPurpose", purpose); 
            procedureCall.addParameterWithValue("@pReason", otherPurpose); 
            procedureCall.addParameterWithValue("@pVisitLocation", visitLocation); 
            procedureCall.addParameterWithValue("@pBedNo", bedno); 
            procedureCall.addParameterWithValue("@pQaID", qAid); 
            procedureCall.addParameterWithValue("@pRemarks", remarks);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                visit = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Visit = ex.Message;
                return JsonConvert.SerializeObject(result);
            }
            result.Visitor = visitor;
            result.Visit = visit;
            result.Questionnaire = questionnaire;
            result.CheckIn = checkin;
            return JsonConvert.SerializeObject(result);
        }

        
        private String writeQuestionnaireResponse(String qaid, String qListID, String qAns) {
          
            String result = "";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("INSERT_QUESTIONNARIE_RESPONSE", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pQA_ID", qaid);
            procedureCall.addParameterWithValue("@pQ_QuestionListID", qListID);
            procedureCall.addParameterWithValue("@pQA_JSON", qAns);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                result += responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                throw ex;
            }
           
            return result;
        }

        private String updateQuestionnaireResponse(String qaid, String qListID, String qAns)
        {
           
            String result = "";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("UPDATE_QUESTIONNARIE_RESPONSE", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pQA_ID", qaid);
            procedureCall.addParameterWithValue("@pQA_JSON", qAns);
            try
            {
                ProcedureResponse dataResponse = procedureCall.runProcedure();
                result = dataResponse.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        private dynamic checkNumCheckedIn(string bedno, int limit) {
            DataTable dataTable = new DataTable();
            dynamic result = new ExpandoObject();
           
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
            
            return result;
        }

        private String CheckIn(String staffuser,String nric, String temp) {
            
            String result = "";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("CONFIRM_CHECK_IN", true, true, false);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            procedureCall.addParameterWithValue("@pNric", nric.ToUpper());
            procedureCall.addParameterWithValue("@pStaffEmail", staffuser);
            procedureCall.addParameterWithValue("@pTemperature", temp);
            try
            {
                ProcedureResponse dataResponse = procedureCall.runProcedure();
                result = dataResponse.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                throw ex;
            }
          
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