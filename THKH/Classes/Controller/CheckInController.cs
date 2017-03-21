using System;
using System.Globalization;
using System.Collections;
using System.Data;
using System.Dynamic;
using Newtonsoft.Json;
using THKH.Classes.DAO;
using THKH.Classes.Entity;

namespace THKH.Classes.Controller
{
    public class CheckInController
    {
        private GenericProcedureDAO procedureCall;

        public String getFacilities()
        {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            String fac = "";

           procedureCall = new GenericProcedureDAO("GET_ALL_FACILITIES", false, true, true);
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

        public string searchAutoComplete(string isNameSearch, string searchData)
        {
            dynamic result = new ExpandoObject();
            result.Msg = "Success";
            ArrayList output = new ArrayList();
            procedureCall = new GenericProcedureDAO("AUTOCOMPLETE_PATIENT_NAME", true, true, true);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            procedureCall.addParameterWithValue("@isNameSearch", Int32.Parse(isNameSearch));
            procedureCall.addParameterWithValue("@pSearchTerm", searchData);
            try
            {
                ProcedureResponse resultss = procedureCall.runProcedure();
                DataTable response = resultss.getDataTable();
                DataTableReader reader = response.CreateDataReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        output.Add(reader.GetString(0)+","+ reader.GetInt32(1));
                    }
                    
                }
                result.Result = output;
                reader.Close();
            }
            catch (Exception ex)
            {
                result.Msg = "Failure";
                result.Facilities = ex.Message;
                return Newtonsoft.Json.JsonConvert.SerializeObject(result);
            }

            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
             
        }

        public String loadForm()
        {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            ArrayList questionItems = new ArrayList();

           procedureCall = new GenericProcedureDAO("RETRIEVE_ACTIVE_QUESTIONNARIE", false, true, true);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            try
            {
                ProcedureResponse responses = procedureCall.runProcedure();
                DataTableReader reader = responses.getDataTable().CreateDataReader();
                if (reader.HasRows)
                {

                    while (reader.Read())
                    {
                        //dynamic questionO = new ExpandoObject();
                        //questionO.QuestionNumber = reader.GetInt32(1);
                        //questionO.QuestionList = reader.GetString(0);
                        //questionO.Question = reader.GetString(2);
                        //questionO.QuestionType = reader.GetString(3);
                        //questionO.QuestionAnswers = reader.GetString(4);
                        Question qn = new Question(reader.GetInt32(1).ToString(),
                            reader.GetString(2), reader.GetString(3), reader.GetString(4), reader.GetString(0));
                        questionItems.Add(qn);
                        // New Solution Here
                        
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
        public String checkPatient(String pName, String bedno)
        {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
           procedureCall = new GenericProcedureDAO("CONFIRM_PATIENT", true, true, false);
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

        public String getVisitorDetails(String nric)
        {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            try
            {

               procedureCall = new GenericProcedureDAO("GET_VISITOR", true, true, false);
                procedureCall.addParameter("@responseMessage", SqlDbType.Int);
                procedureCall.addParameter("@returnValue", SqlDbType.VarChar, -1);
                procedureCall.addParameterWithValue("@pNRIC", nric);
                ProcedureResponse res = procedureCall.runProcedure();
                String response = res.getResponses()["@returnValue"].ToString();

                if (!response.Contains("Visitor not found"))
                {
                    //msg += response;
                    //result.Visitor = response;
                    var arr = response.Split(',');
                    Visitor vistr = new Visitor(arr[1], arr[0], arr[2].Trim(), arr[3], arr[4], arr[5], arr[6], arr[7]);
                    result.Visitor = vistr.toJsonObject(); ;
                }
                else
                {

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
                Visit visit = getVisitDetails(nric);
                if (visit != null)
                {

                    result.Visit = visit.toJsonObject();
                    //var arr = tempMsg.Split(',');
                    //var qAID = arr[arr.Length - 3];
                    String qAID = result.Visit.qAid.Value;

                    QuestionnaireAnswer qA = new QuestionnaireAnswer(getSubmittedQuestionnaireResponse(qAID));
                    //result.Questionnaire = JsonConvert.DeserializeObject(getSubmittedQuestionnaireResponse(qAID));
                    result.Questionnaire = qA.toJsonObject();
                }
                else
                {

                    return JsonConvert.SerializeObject(result);
                }
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Visitor = ex.Message;

            }

            return JsonConvert.SerializeObject(result);
        }

        public Visit getVisitDetails(String nric)
        {
            //dynamic result = new ExpandoObject();
           procedureCall = new GenericProcedureDAO("GET_VISIT_DETAILS", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.VarChar, -1);
            procedureCall.addParameterWithValue("@pNric", nric);
            Visit vis = null;
            try
            {
                ProcedureResponse resultdata = procedureCall.runProcedure();


                String response = resultdata.getSqlParameterValue("@responseMessage").ToString();
                if (response.Length > 4)
                {
                    //result.Visit = response;
                    var resArr = response.Split(',');
                    vis = new Visit(resArr[0], resArr[1], resArr[2], resArr[3], resArr[4], resArr[5], resArr[6], resArr[7]);
                }
                //else
                //{
                //    result.Visit = "none";
                //    return result;
                //}
            }
            catch (Exception ex)
            {
                throw ex;
            }


            //return result;
            return vis;
        }

        public String getSubmittedQuestionnaireResponse(String qAID)
        {
            String successString = "";
           procedureCall = new GenericProcedureDAO("GET_QUESTIONNARIE_RESPONSE", true, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int, -1);
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
                else
                {
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
        public String selfReg(String nric, String fname, String address, String postal, String mobtel,
            String sex, String nationality, String dob, String purpose, String otherPurpose, String bedno, String appTime,
            String visitLocation, String qListID, String qAns, String qaid, String amend)
        {
           procedureCall = new GenericProcedureDAO("CREATE_VISITOR_PROFILE", true, true, false);
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
                if (respon != null)
                {
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

           procedureCall = new GenericProcedureDAO("GET_PATIENT_NAME", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameter("@pPatient_Name", SqlDbType.VarChar, 1000);
            procedureCall.addParameterWithValue("@pBed_No", beds);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                toSend.name = responseOutput.getSqlParameterValue("@pPatient_Name").ToString();
            }
            catch (Exception e)
            {
                toSend.error = e.Message.ToString();
                successString = JsonConvert.SerializeObject(toSend);
                return successString;
            }

            successString = JsonConvert.SerializeObject(toSend);
            return successString;
        }


        // Write to Visitor, Visit & Confirmation Table
        public String AssistReg(String staffuser, String nric, String fname, String address, String postal, String mobtel,
            String sex, String nationality, String dob, String purpose, String pName, String pNric, String otherPurpose, String bedno, String appTime,
            String remarks, String visitLocation, String temperature, String qListID, String qAns, String qaid, String visLim)
        {

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
            catch (Exception ex)
            {
            }
            //update visitor profile
           procedureCall = new GenericProcedureDAO("UPDATE_VISITOR_PROFILE", true, true, false);
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
            else
            {
                try
                {
                    checkin = CheckIn(staffuser, nric, temperature);
                }
                catch (Exception ex)
                {
                    result.Result = "Failure";
                    result.Visitor = ex.Message;
                    return JsonConvert.SerializeObject(result);
                }
            }

            result.Visitor = visitor;
            result.Visit = visit;
            result.Questionnaire = questionnaire;
            result.CheckIn = checkin;
            return JsonConvert.SerializeObject(result);
        }

        // Write to Visitor, Visit & Confirmation Table for Express Reg
        public String ExpReg(String staffuser, String nric, String fname, String address, String postal, String mobtel,
            String sex, String nationality, String dob, String purpose, String pName, String pNric, String otherPurpose, String bedno, String appTime,
            String remarks, String visitLocation, String qListID, String qAns, String qaid)
        {

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
            catch (Exception ex)
            {}
            //update visitor profile
            procedureCall = new GenericProcedureDAO("UPDATE_VISITOR_PROFILE", true, true, false);
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

            // Update visit details with blank fields
            procedureCall = new GenericProcedureDAO("UPDATE_VISIT", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pVisitRequestTime", DateTime.UtcNow.AddHours(8));
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

            // Check in visitor with no check on visitor limit
            try
            {
                checkin = CheckIn(staffuser, nric, "0");
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Visitor = ex.Message;
                return JsonConvert.SerializeObject(result);
            }

            result.Visitor = visitor;
            result.Visit = visit;
            result.Questionnaire = questionnaire;
            result.CheckIn = checkin;
            return JsonConvert.SerializeObject(result);
        }

        // Write the form responses to db
        public String writeQuestionnaireResponse(String qaid, String qListID, String qAns)
        {
            String result = "";
           procedureCall = new GenericProcedureDAO("INSERT_QUESTIONNARIE_RESPONSE", true, true, false);
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

        public String updateQuestionnaireResponse(String qaid, String qListID, String qAns)
        {

            String result = "";
           procedureCall = new GenericProcedureDAO("UPDATE_QUESTIONNARIE_RESPONSE", true, true, false);
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

        public dynamic checkNumCheckedIn(string bedno, int limit)
        {
            DataTable dataTable = new DataTable();
            dynamic result = new ExpandoObject();

            try
            {
                string[] beds = bedno.Split('|');
                foreach (string bed in beds)
                {
                   procedureCall = new GenericProcedureDAO("CHECK_NUM_VISITORS", true, true, false);
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

        public String CheckIn(String staffuser, String nric, String temp)
        {

            String result = "";
           procedureCall = new GenericProcedureDAO("CONFIRM_CHECK_IN", true, true, false);
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
    }
}