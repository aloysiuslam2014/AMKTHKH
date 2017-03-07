using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Dynamic;
using System.Collections;
using THKH.Classes.DAO;
using THKH.Classes.Entity;

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
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("ADD_BLANK_QUESTIONNARIE_LIST", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pQ_QuestionListID", qName);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                var results = Int32.Parse(responseOutput.getSqlParameterValue("@responseMessage").ToString());
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
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // Update questionnaire with new question order
        private String updateQuestionnaire(String qnaire, String order)
        {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("UPDATE_QUESTIONNARIE_LIST", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pQ_QuestionList_ID", qnaire);
            procedureCall.addParameterWithValue("@pQ_Order", order);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                result.Msg = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // Sets the selected questionnaire as active & deactivates the rest
        private String setActiveQuestionnaire(String qName)
        {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("ACTIVATE_QUESTIONNARIE_LIST", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pQ_QuestionList_ID", qName);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                result.Msg = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // removes questionnaire
        private String deleteQuestionnaire()
        {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("DELETE_QUESTIONNARIE_LIST", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);

            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                result.Msg = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // Adds new question
        private String addQuestion(String qn, String qnType, String qnValues)
        {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("ADD_QUESTION", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pQuestion", qn);
            procedureCall.addParameterWithValue("@pQnsType", qnType);
            procedureCall.addParameterWithValue("@pQnsValue", qnValues);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                result.Msg = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // Updates a question
        private String updateQuestion(String qnId, String qn, String qnType, String qnValues)
        {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("UPDATE_QUESTION", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pQQ_ID", Int32.Parse(qnId));
            procedureCall.addParameterWithValue("@pQuestion", qn);
            procedureCall.addParameterWithValue("@pQnsType", qnType);
            procedureCall.addParameterWithValue("@pQnsValue", qnValues);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                result.Msg = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // Delete question
        private String deleteQuestion()
        {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("DELETE_QUESTION", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                result.Msg = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(result);
        }

        // retrieves all the questionnaires from the DB
        private void retrieveQuestionnaires(dynamic toSend)
        {
            ArrayList questionaires = new ArrayList();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_ALL_QUESTIONNAIRE_LIST", false, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                DataTableReader reader = responseOutput.getDataTable().CreateDataReader();

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

        }

        // retrieves all the questions in the SELECTED questionnaire
        private void retrieveQuestionnaireQuestions(string idList, dynamic toSend)
        {
            ArrayList qnsQns = new ArrayList();
            List<String> qids = new List<string>();
            List<String> questions = new List<string>();
            List<String> qnTypes = new List<string>();
            List<String> qnValues = new List<string>();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_SELECTED_QUESTIONNARIE", true, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pQ_QuestionList_ID", idList);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                DataTableReader reader = responseOutput.getDataTable().CreateDataReader();
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
                var response = responseOutput.getSqlParameterValue("@responseMessage").ToString();
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
            }
            catch (Exception ex)
            {
                toSend.Result = "Failure";
                toSend.Msg = ex.Message;
                return;
            }
            procedureCall = new GenericProcedureDAO("GET_SELECTED_QUESTIONNARIE_ORDER", true, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pQ_QuestionList_ID", idList);
            String order = "";
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                DataTableReader reader = responseOutput.getDataTable().CreateDataReader();
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
            ArrayList qns = new ArrayList();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_QUESTIONS", true, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                DataTableReader reader = responseOutput.getDataTable().CreateDataReader();
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
           
        }

        private String addQuestionToQuestionnaire(String qnaireId, String qns)
        {
            dynamic result = new ExpandoObject();
            result.Result = "Success";
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("UPDATE_QUESTIONNARIE_LIST", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pQ_QuestionList_ID", qnaireId);
            procedureCall.addParameterWithValue("@pQ_Order", qns);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                result.Msg = responseOutput.getSqlParameterValue("@responseMessage").ToString();
            }
            catch (Exception ex)
            {
                result.Result = "Failure";
                result.Msg = ex.Message;
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