using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Dynamic;
using System.Collections;

namespace THKH.Webpage.Staff.QuestionaireManagement
{
    /// <summary>
    /// Summary description for questionaireManagement
    /// </summary>
    public class questionaireManagement : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {

            context.Response.ContentType = "text/plain";
            String successString = "";

            var typeOfRequest = context.Request.Form["requestType"];

            if (typeOfRequest == "initialize")
            {
                dynamic formsInit = new ExpandoObject();
                formsInit.Result = "Success";
                retrieveQuestionnaires(formsInit);
                retrieveQuestions(formsInit);//retrieveQuestionnaireQuestions
                successString = Newtonsoft.Json.JsonConvert.SerializeObject(formsInit);
            }
            if (typeOfRequest == "getQuestionaireFromList")
            {
                var idList = context.Request.Form["ListID"];
                dynamic getQns = new ExpandoObject();
                getQns.Result = "Success";
                retrieveQuestionnaireQuestions(idList, getQns);
                successString = Newtonsoft.Json.JsonConvert.SerializeObject(getQns); ;


            }
            if (typeOfRequest == "addQuestion")
            {
                var qn = context.Request.Form["question"];
                var qnType = context.Request.Form["questionType"];
                var qnVals = context.Request.Form["questionValues"];
                successString = addQuestion(qn, qnType, qnVals);
            }
            if (typeOfRequest == "updateQuestion")
            {
                var qnId = context.Request.Form["qnId"];
                var qn = context.Request.Form["question"];
                var qnType = context.Request.Form["questionType"];
                var qnVals = context.Request.Form["questionValues"];
                successString = updateQuestion(qnId, qn, qnType, qnVals);
            }
            if (typeOfRequest == "deleteQuestion")
            {
                successString = deleteQuestion();
            }
            if (typeOfRequest == "deleteQuestionFromQuestionnaire")
            {
                successString = deleteQuestion();
            }
            if (typeOfRequest == "addQuestionToQuestionnaire")
            {
                successString = deleteQuestion();
            }
            if (typeOfRequest == "addQuestionnaire")
            {
                var qName = context.Request.Form["qName"];
                successString = addQuestionnaire(qName);
            }
            if (typeOfRequest == "deleteQuestionnaire")
            {
                successString = deleteQuestionnaire();
            }
            if (typeOfRequest == "update")
            {
                var qName = context.Request.Form["qnaireId"];
                var order = context.Request.Form["qnQns"];
                successString = updateQuestionnaire(qName, order);
            }
            if (typeOfRequest == "active")
            {
                var qnaireId = context.Request.Form["qnaireId"];
                successString = setActiveQuestionnaire(qnaireId);
            }
            context.Response.Write(successString);
        }

        // Generate JSON String for Questionnaire & Questions - Initial Page Load
        private String generateJSONFromData()
        {
            String successString = "";
            return successString;
        }

        // Add new questionnaire to DB
        private String addQuestionnaire(String qName)
        {
            SqlConnection cnn;
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[ADD_BLANK_QUESTIONNARIE_LIST]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pQ_QuestionListID", qName);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                var results = Int32.Parse(respon.Value.ToString());
                if (results == 1 || results == 0)
                {
                    result.Msg = "" + results.ToString();
                }
                else
                {
                    result.Result = "Failure";
                }
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            finally
            {
                cnn.Close();
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // Update questionnaire with new question order
        private String updateQuestionnaire(String qnaire, String order)
        {
            SqlConnection cnn;
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE_QUESTIONNARIE_LIST]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pQ_QuestionList_ID", qnaire);
                command.Parameters.AddWithValue("@pQ_Order", order);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                result.Msg = respon.Value;
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            finally
            {
                cnn.Close();
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // Sets the selected questionnaire as active & deactivates the rest
        private String setActiveQuestionnaire(String qName)
        {
            SqlConnection cnn;
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[ACTIVATE_QUESTIONNARIE_LIST]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pQ_QuestionList_ID", qName);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                result.Msg = respon.Value;
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            finally
            {
                cnn.Close();
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // removes questionnaire
        private String deleteQuestionnaire()
        {
            SqlConnection cnn;
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[DELETE_QUESTIONNARIE_LIST]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                // Add params Questionnaire ID
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                result.Msg = respon.Value;
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            finally
            {
                cnn.Close();
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // Adds new question
        private String addQuestion(String qn, String qnType, String qnValues)
        {
            SqlConnection cnn;
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[ADD_QUESTION]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                // Add params Question, Question Type, Question Values
                command.Parameters.AddWithValue("@pQuestion", qn);
                command.Parameters.AddWithValue("@pQnsType", qnType);
                command.Parameters.AddWithValue("@pQnsValue", qnValues);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                result.Msg = respon.Value;
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            finally
            {
                cnn.Close();
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // Updates a question
        private String updateQuestion(String qnId, String qn, String qnType, String qnValues)
        {
            SqlConnection cnn;
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE_QUESTION]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                // Add params Question, Question Type, Question Values
                command.Parameters.AddWithValue("@pQQ_ID", Int32.Parse(qnId));
                command.Parameters.AddWithValue("@pQuestion", qn);
                command.Parameters.AddWithValue("@pQnsType", qnType);
                command.Parameters.AddWithValue("@pQnsValue", qnValues);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                result.Msg = respon.Value;
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            finally
            {
                cnn.Close();
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // Delete question
        private String deleteQuestion()
        {
            SqlConnection cnn;
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[DELETE_QUESTION]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                // Add params Question_ID
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                result.Msg = respon.Value;
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            finally
            {
                cnn.Close();
            }

            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // retrieves all the questionnaires from the DB
        private void retrieveQuestionnaires(dynamic toSend)
        {
            SqlConnection cnn;

            ArrayList questionaires = new ArrayList();
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_ALL_QUESTIONNAIRE_LIST]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.Add(respon);
                cnn.Open();

                SqlDataReader reader = command.ExecuteReader();

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        dynamic qnItems = new ExpandoObject();
                        qnItems.ListName = reader.GetString(0);
                        qnItems.Active = reader.GetInt32(2);
                        questionaires.Add(qnItems);
                    }

                    toSend.Qnaires = questionaires;
                }
                reader.Close();
            }
            catch (Exception ex)
            {
                toSend.Result = "Failure";
                toSend.Msg = ex.Message;

            }
            finally
            {
                cnn.Close();
            }

        }

        // retrieves all the questions in the SELECTED questionnaire
        private void retrieveQuestionnaireQuestions(string idList, dynamic toSend)
        {
            SqlConnection cnn;
            ArrayList qnsQns = new ArrayList();
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            List<String> qids = new List<string>();
            List<String> questions = new List<string>();
            List<String> qnTypes = new List<string>();
            List<String> qnValues = new List<string>();
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_SELECTED_QUESTIONNARIE]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                // Add params
                command.Parameters.AddWithValue("@pQ_QuestionList_ID", idList);
                command.Parameters.Add(respon);
                cnn.Open();

                SqlDataReader reader = command.ExecuteReader();
                int count = 1;
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        // Get Question ID
                        qids.Add(reader.GetInt32(0).ToString());
                        // Get Question
                        questions.Add(reader.GetString(1));
                        // Get Question Type
                        qnTypes.Add(reader.GetString(2));
                        // Get Question Value
                        qnValues.Add(reader.GetString(3));
                        count++;
                    }
                }
                var response = respon.Value;
                if (response != null && response.ToString() == "0")
                {
                    dynamic noQns = new ExpandoObject();
                    noQns.question = 0;
                    ArrayList temp = new ArrayList();
                    temp.Add(noQns);
                    toSend.qnQns = temp;

                    return;
                }
                reader.Close();
                cnn.Close();
            }
            catch (Exception ex)
            {
                toSend.Result = "Failure";
                toSend.Msg = ex.Message;
                return;
            }
            respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            String order = "";
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_SELECTED_QUESTIONNARIE_ORDER]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                // Add params
                command.Parameters.AddWithValue("@pQ_QuestionList_ID", idList);
                command.Parameters.Add(respon);
                cnn.Open();
                SqlDataReader reader = command.ExecuteReader();
                int count = 1;
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        order += reader.GetString(0);
                        count++;
                    }
                }
                reader.Close();
            }
            catch (Exception ex)
            {
                toSend.Result = "Failure";
                toSend.Msg = ex.Message;
                return;
            }
            finally
            {
                cnn.Close();
            }
            String[] orderArr = order.Split(',');

            for (int j = 0; j < orderArr.Length; j++)
            {
                String thisQid = orderArr[j];
                for (int i = 0; i < questions.Count(); i++)
                {
                    dynamic qnObj = new ExpandoObject();
                    String listQid = qids[i];
                    if (thisQid == listQid)
                    {

                        qnObj.qId = listQid;
                        qnObj.question = questions[i];
                        qnObj.qnType = qnTypes[i];
                        qnObj.values = qnValues[i];
                        qnsQns.Add(qnObj);
                    }
                }
            }
            toSend.qnQns = qnsQns;
        }

        // Retrieves all the questions from the DB
        private void retrieveQuestions(dynamic toSend)
        {
            SqlConnection cnn;
            ArrayList qns = new ArrayList();
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_QUESTIONS]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.Add(respon);
                cnn.Open();

                SqlDataReader reader = command.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        dynamic question = new ExpandoObject();
                        question.qId = reader.GetInt32(0);
                        question.question = reader.GetString(1);
                        question.qnType = reader.GetString(2);
                        question.values = reader.GetString(3);
                        qns.Add(question);
                    }
                    toSend.Qns = qns;
                }

                reader.Close();
            }
            catch (Exception ex)
            {
                toSend.Result = "Failure";
                toSend.Msg = ex.Message;

            }
            finally
            {
                cnn.Close();
            }

        }

        private String addQuestionToQuestionnaire(String qnaireId, String qns)
        {
            SqlConnection cnn;
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[UPDATE_QUESTIONNARIE_LIST]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pQ_QuestionList_ID", qnaireId);
                command.Parameters.AddWithValue("@pQ_Order", qns);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                result.Msg += respon.Value;
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            finally
            {
                cnn.Close();
            }

            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
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