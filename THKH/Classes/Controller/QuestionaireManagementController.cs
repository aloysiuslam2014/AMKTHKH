using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Dynamic;
using System.Collections;
using THKH.Classes.DAO;
using THKH.Classes.Entity;

namespace THKH.Classes.Controller
{
    public class QuestionaireManagementController
    {

        /// <summary>
        /// Add new questionnaire to DB
        /// </summary>
        /// <param name="qName"></param>
        /// <returns>JSON String</returns>
        public String addQuestionnaire(String qName)
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

        /// <summary>
        /// Update questionnaire with new question order
        /// </summary>
        /// <param name="qnaire"></param>
        /// <param name="order"></param>
        /// <returns>JSON String</returns>
        public String updateQuestionnaire(String qnaire, String order)
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

        /// <summary>
        /// Sets the selected questionnaire as active & deactivates the rest
        /// </summary>
        /// <param name="qName"></param>
        /// <returns>JSON String</returns>
        public String setActiveQuestionnaire(String qName)
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

        /// <summary>
        /// Removes questionnaire
        /// </summary>
        /// <returns>JSON String</returns>
        public String deleteQuestionnaire()
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

        /// <summary>
        /// Adds new question
        /// </summary>
        /// <param name="qn"></param>
        /// <param name="qnType"></param>
        /// <param name="qnValues"></param>
        /// <returns>JSON String</returns>
        public String addQuestion(String qn, String qnType, String qnValues)
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

        /// <summary>
        /// Updates a question
        /// </summary>
        /// <param name="qnId"></param>
        /// <param name="qn"></param>
        /// <param name="qnType"></param>
        /// <param name="qnValues"></param>
        /// <returns>JSON String</returns>
        public String updateQuestion(String qnId, String qn, String qnType, String qnValues)
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

        /// <summary>
        /// Deletes a selected question
        /// </summary>
        /// <returns>JSON String</returns>
        public String deleteQuestion()
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

        /// <summary>
        /// Retrieves all the questionnaires from the DB
        /// </summary>
        /// <param name="toSend"></param>
        public void retrieveQuestionnaires(dynamic toSend)
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

        /// <summary>
        /// Retrieves all the questions in the SELECTED questionnaire
        /// </summary>
        /// <param name="idList"></param>
        /// <param name="toSend"></param>
        public void retrieveQuestionnaireQuestions(string idList, dynamic toSend)
        {
            ArrayList qnsQns = new ArrayList();
            //List<String> qids = new List<string>();
            //List<String> questions = new List<string>();
            //List<String> qnTypes = new List<string>();
            //List<String> qnValues = new List<string>();
            ArrayList qnList = new ArrayList();
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
                        //qids.Add(reader.GetInt32(0).ToString());
                        //// Get Question
                        //questions.Add(reader.GetString(1));
                        //// Get Question Type
                        //qnTypes.Add(reader.GetString(2));
                        //// Get Question Value
                        //qnValues.Add(reader.GetString(3));
                        Question qn = new Question(reader.GetInt32(0).ToString(), reader.GetString(1), reader.GetString(2), reader.GetString(3), "");
                        qnList.Add(qn.toJsonObject());
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
                for (int i = 0; i < qnList.Count; i++)
                {
                    //dynamic qnObj = new ExpandoObject();
                    //String listQid = qids[i];
                    //if (thisQid == listQid)
                    //{

                    //    qnObj.qId = listQid;
                    //    qnObj.question = questions[i];
                    //    qnObj.qnType = qnTypes[i];
                    //    qnObj.values = qnValues[i];
                    //    qnsQns.Add(qnObj);
                    //}
                    dynamic thisQuestion = qnList[i];
                    if (thisQuestion.qnid == thisQid) {
                        qnsQns.Add(thisQuestion);
                    }
                }
            }
            toSend.qnQns = qnsQns;
        }

        /// <summary>
        /// Retrieves all the questions from the DB
        /// </summary>
        /// <param name="toSend"></param>
        public void retrieveQuestions(dynamic toSend)
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
                        //dynamic question = new ExpandoObject();
                        //question.qId = reader.GetInt32(0);
                        //question.question = reader.GetString(1);
                        //question.qnType = reader.GetString(2);
                        //question.values = reader.GetString(3);
                        Question qn = new Question(reader.GetInt32(0).ToString(), reader.GetString(1), reader.GetString(2), reader.GetString(3), "");
                        qns.Add(qn.toJsonObject());
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

        /// <summary>
        /// Updates the Questionnaire_List Table with the question IDs assigned to it
        /// </summary>
        /// <param name="qnaireId"></param>
        /// <param name="qns"></param>
        /// <returns></returns>
        public String addQuestionToQuestionnaire(String qnaireId, String qns)
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
    }
}