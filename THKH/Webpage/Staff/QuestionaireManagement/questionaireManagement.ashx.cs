using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

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
            String successString = "{\"Result\":\"Success\",";
            var typeOfRequest = context.Request.Form["requestType"];

            if (typeOfRequest == "initialize") {
                successString += retrieveQuestionnaires();
                successString += ",";
                successString += retrieveQuestions();//retrieveQuestionnaireQuestions
            }
            if (typeOfRequest == "getQuestionaireFromList")
            {
                var idList = context.Request.Form["ListID"];
                successString += retrieveQuestionnaireQuestions(idList);
               // successString += "}";
            }
            if (typeOfRequest == "addQuestion")
            {
                successString = addQuestion();
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
        private String generateJSONFromData() {
            String successString = "";
            return successString;
        }

        // Add new questionnaire to DB
        private String addQuestionnaire(String qName)
        {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":";
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
                var result = Int32.Parse(respon.Value.ToString());
                if (result == 1)
                {
                    successString += "\"" + result.ToString();
                }
                else {
                    successString.Replace("Success", "Failure");
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
            successString += "\"}";
            return successString;
        }

        // Update questionnaire with new question order
        private String updateQuestionnaire(String qnaire, String order)
        {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":";
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
                successString += respon.Value;
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

        // Sets the selected questionnaire as active & deactivates the rest
        private String setActiveQuestionnaire(String qName)
        {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":\"";
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
                successString += respon.Value;
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
            successString += "\"}";
            return successString;
        }

        // removes questionnaire
        private String deleteQuestionnaire()
        {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":";
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
                successString += respon.Value;
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

        // Adds new question
        private String addQuestion()
        {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[ADD_QUESTION]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                // Add params Question, Question Type, Question Values
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
                return successString;
            }
            finally
            {
                cnn.Close();
            }
            successString += "}";
            return successString;
        }

        // Delete question
        private String deleteQuestion()
        {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":";
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
                successString += respon.Value;
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

        // retrieves all the questionnaires from the DB
        private String retrieveQuestionnaires()
        {
            SqlConnection cnn;
            String successString = "\"Qnaires\":";
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
                int count = 1;
                if (reader.HasRows)
                {
                    successString += "[";
                    while (reader.Read())
                    {
                        if (count > 1)
                        {
                            successString += ",";
                        }
                        successString += "{\"ListName\":\"" + reader.GetString(0) + "\",\"Active\":\""
                            + reader.GetInt32(2);
                        successString += "\"}";
                        count++;
                    }
                    successString += "]";
                }
                successString += respon.Value;
                reader.Close();
            }
            catch (Exception ex)
            {
                successString.Replace("Success", "Failure");
                successString += "\"" + ex.Message;
                successString += "\"}";
                return successString;
            }
            finally
            {
                cnn.Close();
            }
            return successString;
        }

        // retrieves all the questions in the SELECTED questionnaire
        private String retrieveQuestionnaireQuestions(string idList)
        {
            SqlConnection cnn;
            String successString = "\"qnQns\":";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
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
                    successString += "[";
                    while (reader.Read())
                    {
                        if (count > 1)
                        {
                            successString += ",";
                        }
                        successString += "{";
                        // Get Question ID
                        successString += "\"qid\":\""+reader.GetInt32(0)+"\",";
                        // Get Question
                        successString += "\"question\":\"" + reader.GetString(1) + "\",";
                        // Get Question Type
                        successString += "\"type\":\"" + reader.GetString(2) + "\",";
                        // Get Question Value
                        successString += "\"val\":\"" + reader.GetString(3)  + "\"";
                        successString += "}";
                        count++;
                    }
                    successString += "]";
                }
                successString += respon.Value;
                reader.Close();
            }
            catch (Exception ex)
            {
                successString.Replace("Success", "Failure");
                successString += "\"" + ex.Message;
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

        // Retrieves all the questions from the DB
        private String retrieveQuestions()
        {
            SqlConnection cnn;
            String successString = "\"Qns\":";
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
                int count = 1;
                if (reader.HasRows)
                {
                    successString += "[";
                    while (reader.Read())
                    {
                        if (count > 1)
                        {
                            successString += ",";
                        }
                        successString += "{\"qId\":\"" + reader.GetInt32(0) + "\",\"question\":\"" 
                            + reader.GetString(1) + "\",\"qnType\":\"" + reader.GetString(2) + "\",\"values\":\"" 
                            + reader.GetString(3);
                        successString += "\"}";
                        count++;
                    }
                    successString += "]";
                }
                successString += respon.Value;
                reader.Close();
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

        private String addQuestionToQuestionnaire(String qnaireId, String qns) {
            SqlConnection cnn;
            String successString = "{\"Result\":\"Success\",\"Msg\":";
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
                successString += respon.Value;
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

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}