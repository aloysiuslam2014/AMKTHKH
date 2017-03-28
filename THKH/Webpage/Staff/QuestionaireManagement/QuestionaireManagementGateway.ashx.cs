using System;
using System.Web;
using System.Dynamic;
using THKH.Classes.Controller;

namespace THKH.Webpage.Staff.QuestionaireManagement
{
    /// <summary>
    /// Summary description for questionaireManagement
    /// </summary>
    public class QuestionaireManagementGateway : IHttpHandler
    {
        QuestionaireManagementController questionaireManagementController = new QuestionaireManagementController();

        /// <summary>
        /// Picks out the action needed & calls the appropriate methods in the related controller class
        /// </summary>
        /// <param name="context"></param>
        public void ProcessRequest(HttpContext context)
        {

            context.Response.ContentType = "text/plain";
            String successString = "";

            var typeOfRequest = context.Request.Form["requestType"];

            if (typeOfRequest == "initialize")
            {
                dynamic formsInit = new ExpandoObject();
                formsInit.Result = "Success";
                questionaireManagementController.retrieveQuestionnaires(formsInit);
                questionaireManagementController.retrieveQuestions(formsInit);//retrieveQuestionnaireQuestions
                successString = Newtonsoft.Json.JsonConvert.SerializeObject(formsInit);
            }
            if (typeOfRequest == "getQuestionaireFromList")
            {
                var idList = context.Request.Form["ListID"];
                dynamic getQns = new ExpandoObject();
                getQns.Result = "Success";
                questionaireManagementController.retrieveQuestionnaireQuestions(idList, getQns);
                successString = Newtonsoft.Json.JsonConvert.SerializeObject(getQns);


            }
            if (typeOfRequest == "addQuestion")
            {
                var qn = context.Request.Form["question"];
                var qnType = context.Request.Form["questionType"];
                var qnVals = context.Request.Form["questionValues"];
                successString = questionaireManagementController.addQuestion(qn, qnType, qnVals);
            }
            if (typeOfRequest == "updateQuestion")
            {
                var qnId = context.Request.Form["qnId"];
                var qn = context.Request.Form["question"];
                var qnType = context.Request.Form["questionType"];
                var qnVals = context.Request.Form["questionValues"];
                successString = questionaireManagementController.updateQuestion(qnId, qn, qnType, qnVals);
            }
            if (typeOfRequest == "deleteQuestion")
            {
                successString = questionaireManagementController.deleteQuestion();
            }
            if (typeOfRequest == "deleteQuestionFromQuestionnaire")
            {
                successString = questionaireManagementController.deleteQuestion();
            }
            if (typeOfRequest == "addQuestionToQuestionnaire")
            {
                successString = questionaireManagementController.deleteQuestion();
            }
            if (typeOfRequest == "addQuestionnaire")
            {
                var qName = context.Request.Form["qName"];
                successString = questionaireManagementController.addQuestionnaire(qName);
            }
            if (typeOfRequest == "deleteQuestionnaire")
            {
                successString = questionaireManagementController.deleteQuestionnaire();
            }
            if (typeOfRequest == "update")
            {
                var qName = context.Request.Form["qnaireId"];
                var order = context.Request.Form["qnQns"];
                successString = questionaireManagementController.updateQuestionnaire(qName, order);
            }
            if (typeOfRequest == "active")
            {
                var qnaireId = context.Request.Form["qnaireId"];
                successString = questionaireManagementController.setActiveQuestionnaire(qnaireId);
            }
            context.Response.Write(successString);
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