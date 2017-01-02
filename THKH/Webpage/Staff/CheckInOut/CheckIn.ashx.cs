using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;

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
            if (typeOfRequest == "self")
            {
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
                long ticks = DateTime.Now.Ticks;
                byte[] bytes = BitConverter.GetBytes(ticks);
                string qaid = Convert.ToBase64String(bytes)
                                        .Replace('+', '_')
                                        .Replace('/', '-')
                                        .TrimEnd('=');

                // Write to Visitor_Profile & Visit Table
                successString = selfReg(nric, age, fname, address, postal, mobtel, alttel, hometel,
            sex, nationality, dob, race, email, purpose, pName, pNric, otherPurpose, bedno, appTime,
            fever, symptoms, influenza, countriesTravelled, remarks, visitLocation, qListID, qAns, qaid);
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
                long ticks = DateTime.Now.Ticks;
                byte[] bytes = BitConverter.GetBytes(ticks);
                string qaid = Convert.ToBase64String(bytes) // Find a way to generate UNIQUE numbers!!!
                                        .Replace('+', '_')
                                        .Replace('/', '-')
                                        .TrimEnd('=');

                successString = AssistReg(staffUser,nric, age, fname, address, postal, mobtel, alttel, hometel,
            sex, nationality, dob, race, email, purpose, pName, pNric, otherPurpose, bedno, appTime,
            fever, symptoms, influenza, countriesTravelled, remarks, visitLocation, temperature, qListID, qAns, qaid);
            }
            context.Response.Write(successString);// String to return to front-end
        }

        private String loadForm() {
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

                //command.ExecuteNonQuery();
                SqlDataReader reader = command.ExecuteReader();
                int count = 1;
                if (reader.HasRows)
                {
                    successString += "[";
                    while (reader.Read())
                    {
                        if (count > 1) {
                            successString += ",";
                        }
                        successString += "{\"QuestionNumber\":\"";
                        successString += reader.GetInt32(1) + "\",\"QuestionList\":\"" + reader.GetString(0) +"\",\"Question\":\"" + reader.GetString(2) + "\",\"QuestionType\":\"" + reader.GetString(3) + "\",\"QuestionAnswers\":\"" + reader.GetString(4);
                        successString += "\"}";
                        count++;
                    }
                    successString += "]";
                }
                successString += respon.Value;
                reader.Close();
                //successString += "\"}";
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

        // Check if patient exists in the Patient Database
        private String checkPatient(String pName, String bedno) {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":\"";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.VarChar, -1);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[CONFIRM_PATIENT]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pBedNo", bedno);
                command.Parameters.AddWithValue("@pPatientFullName", pName);
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
            }
            finally
            {
                cnn.Close();
            }
            successString += "\"}";
            return successString;
        }

        private String getVisitorDetails(String nric) {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Visitor\":\"";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@returnValue", SqlDbType.VarChar, -1);
            respon.Direction = ParameterDirection.Output;
            String msg = "";
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_VISITOR]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNRIC", nric);
                command.Parameters.Add("@responseMessage", SqlDbType.Int).Direction = ParameterDirection.Output;
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                String response = respon.Value.ToString();
                if (response.Length > 4)
                {
                    msg += response;
                }
                else {
                    successString += "new";
                    successString += "\"}";
                    return successString;
                }   
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
            try
            {
                var tempMsg = getVisitDetails(nric);
                msg += "\"," + tempMsg;
                var arr = tempMsg.Split(',');
                var qAID = arr[arr.Length - 2];
                msg += "\"," + getSubmittedQuestionnaireResponse(qAID);
            }
            catch (Exception ex) {
                successString.Replace("Success", "Failure");
                msg = ex.Message;
                successString += "\"}";
                return successString;
            }
            successString += msg;
            successString += "}";
            return successString;
        }

        private String getVisitDetails(String nric)
        {
            SqlConnection cnn;
            String successString = "\"Visit\":\"";
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
                successString += respon.Value;
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
        }

        private String getSubmittedQuestionnaireResponse(String qAID) {
            SqlConnection cnn;
            String successString = "\"Questionnaire\":";
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
            finally
            {
                cnn.Close();
            }
            return successString;
        }

        // Write to Visitor & Visit Table
        private String selfReg(String nric, String age, String fname, String address, String postal, String mobtel, String alttel, String hometel,
            String sex, String nationality, String dob, String race, String email, String purpose, String pName, String pNric, String otherPurpose, String bedno, String appTime,
            String fever, String symptoms, String influenza, String countriesTravelled, String remarks, String visitLocation, String qListID, String qAns, String qaid) {
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            String successString = "{\"Result\":\"Success\",\"Msg\":\"";
            String msg = "";
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[CREATE_VISITOR_PROFILE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNRIC", nric);
                command.Parameters.AddWithValue("@pFullName", fname);
                command.Parameters.AddWithValue("@pGender", sex);
                command.Parameters.AddWithValue("@pNationality", nationality);
                command.Parameters.AddWithValue("@pDateOfBirth", DateTime.ParseExact(dob, "dd-MM-yyyy", CultureInfo.InvariantCulture));
                command.Parameters.AddWithValue("@pRace", race);
                command.Parameters.AddWithValue("@pMobileTel", mobtel);
                command.Parameters.AddWithValue("@pHomeTel", hometel);
                command.Parameters.AddWithValue("@pAltTel", alttel);
                command.Parameters.AddWithValue("@pEmail", email);
                command.Parameters.AddWithValue("@pHomeAddress", address);
                command.Parameters.AddWithValue("@pPostalCode", postal);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                msg += respon.Value;
            }
            catch (Exception ex)
            {
                successString.Replace("Success", "Failure");
                msg = ex.Message;
                successString += msg;
                successString += "\"}";
                return successString;
            }
            finally
            {
                cnn.Close();
            }
            try
            {
                msg += writeQuestionnaireResponse(qaid, qListID, qAns);
            }
            catch (Exception ex)
            {
                successString.Replace("Success", "Failure");
                msg = ex.Message;
                successString += msg;
                successString += "\"}";
                return successString;
            }
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[CREATE_VISIT]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pVisitRequestTime", DateTime.Parse(appTime));
                command.Parameters.AddWithValue("@pPatientNRIC", pNric);
                command.Parameters.AddWithValue("@pVisitorNRIC", nric);
                command.Parameters.AddWithValue("@pPatientFullName", pName);
                command.Parameters.AddWithValue("@pPurpose", purpose);
                command.Parameters.AddWithValue("@pReason", otherPurpose);
                command.Parameters.AddWithValue("@pVisitLocation", visitLocation);
                command.Parameters.AddWithValue("@pBedNo", bedno);
                command.Parameters.AddWithValue("@pQaID", qaid);
                command.Parameters.Add("@responseMessage", SqlDbType.Int).Direction = ParameterDirection.Output;
                cnn.Open();

                command.ExecuteNonQuery();
                msg += respon.Value;
            }
            catch (Exception ex)
            {
                successString.Replace("Success", "Failure");
                msg = ex.Message;
            }
            finally
            {
                cnn.Close();
            }
            successString += msg;
            successString += "\"}";
            return successString;
        }


        // Write to Visitor, Visit & Confirmation Table
        private String AssistReg(String staffuser, String nric, String age, String fname, String address, String postal, String mobtel, String alttel, String hometel,
            String sex, String nationality, String dob, String race, String email, String purpose, String pName, String pNric, String otherPurpose, String bedno, String appTime,
            String fever, String symptoms, String influenza, String countriesTravelled, String remarks, String visitLocation, String temperature, String qListID, String qAns, String qaid) {
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            String successString = "{\"Result\":\"Success\",\"Visitor\":\"";
            String msg = "";
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE_VISITOR_PROFILE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNRIC", nric);
                command.Parameters.AddWithValue("@pFullName", fname);
                command.Parameters.AddWithValue("@pGender", sex);
                command.Parameters.AddWithValue("@pNationality", nationality);
                command.Parameters.AddWithValue("@pDateOfBirth", DateTime.ParseExact(dob, "dd-MM-yyyy", CultureInfo.InvariantCulture));
                command.Parameters.AddWithValue("@pRace", race);
                command.Parameters.AddWithValue("@pMobileTel", mobtel);
                command.Parameters.AddWithValue("@pHomeTel", hometel);
                command.Parameters.AddWithValue("@pAltTel", alttel);
                command.Parameters.AddWithValue("@pEmail", email);
                command.Parameters.AddWithValue("@pHomeAddress", address);
                command.Parameters.AddWithValue("@pPostalCode", postal);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                msg += respon.Value + "\"";
            }
            catch (Exception ex)
            {
                successString.Replace("Success", "Failure");
                msg = ex.Message;
                successString += msg;
                successString += "\"}";
                return successString;
            }
            finally
            {
                cnn.Close();
            }
            try
            {
                msg += writeQuestionnaireResponse(qaid, qListID, qAns);
            }
            catch (Exception ex)
            {
                successString.Replace("Success", "Failure");
                msg = ex.Message;
                successString += msg;
                successString += "\"}";
                return successString;
            }
            respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE_VISIT]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pVisitRequestTime", DateTime.Now);
                command.Parameters.AddWithValue("@pPatientNRIC", pNric);
                command.Parameters.AddWithValue("@pVisitorNRIC", nric);
                command.Parameters.AddWithValue("@pPatientFullName", pName);
                command.Parameters.AddWithValue("@pPurpose", purpose);
                command.Parameters.AddWithValue("@pReason", otherPurpose);
                command.Parameters.AddWithValue("@pVisitLocation", visitLocation);
                command.Parameters.AddWithValue("@pBedNo", bedno);
                command.Parameters.AddWithValue("@pQaID", qaid);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                msg += ",\"Visit\":\"" + respon.Value + "\"";
            }
            catch (Exception ex)
            {
                successString.Replace("Success", "Failure");
                msg = ex.Message;
                successString += msg;
                successString += "\"}";
                return successString;
            }
            finally
            {
                cnn.Close();
            }
            try
            {
                msg += CheckIn(staffuser, nric, temperature);
            }
            catch (Exception ex) {
                successString.Replace("Success", "Failure");
                msg = ex.Message;
            }
            successString += msg;
            successString += "}";
            return successString;
        }

        
        private String writeQuestionnaireResponse(String qaid, String qListID, String qAns) {
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            String successString = ",\"Questionnaire\":\"";
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
                successString += respon.Value +"\"";
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
        }

        private String CheckIn(String staffuser,String nric, String temp) {
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            String successString = ",\"CheckIn\":\""; 
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[CONFIRM_CHECK_IN]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNric", nric);
                command.Parameters.AddWithValue("@pActualTimeVisit", DateTime.Now); // Take from DB side
                command.Parameters.AddWithValue("@pStaffEmail", staffuser);
                command.Parameters.AddWithValue("@pTemperature", temp);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                successString += respon.Value + "\"";
            }
            catch (Exception ex)
            {
                throw ex;
                //successString += ex.Message;
                //return successString;
            }
            finally
            {
                cnn.Close();
            }
            // Need some logic to check whether there are already 3 visitors
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