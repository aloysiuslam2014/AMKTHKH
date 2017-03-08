using System;
using System.Web;
using THKH.Classes.Controller;

namespace THKH.Webpage.Staff.CheckInOut
{
    /// <summary>
    /// Summary description for checkIn
    /// </summary>
    public class CheckInGateway : IHttpHandler,System.Web.SessionState.IRequiresSessionState
    {
        private CheckInController checkInController = new CheckInController();

        public void ProcessRequest(HttpContext context)
        {   
            context.Response.ContentType = "text/plain";
            String successString = "";

            var typeOfRequest = context.Request.Form["requestType"];
            if (typeOfRequest == "getdetails") {
                var nric = context.Request.Form["nric"].ToString();
                successString = checkInController.getVisitorDetails(nric);
            }
            if (typeOfRequest == "form") {
                successString = checkInController.loadForm();
            }
            if (typeOfRequest == "pName")
            {
                var bedNo = context.Request.Form["bedNo"];
                successString = checkInController.getPatientNames(bedNo);
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
                successString = checkInController.selfReg(nric, fname, address, postal, mobtel,
            sex, nationality, dob, purpose,  otherPurpose, bedno, appTime,
            visitLocation, qListID, qAns, qaid, amend);
        }
        if (typeOfRequest == "patient") {
                var pName = context.Request.Form["pName"];
                var bedno = context.Request.Form["bedno"];
                successString = checkInController.checkPatient(pName, bedno);
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

                successString = checkInController.AssistReg(staffUser,nric, age, fname, address, postal, mobtel, alttel, hometel,
            sex, nationality, dob, race, email, purpose, pName, pNric, otherPurpose, bedno, appTime,
            fever, symptoms, influenza, countriesTravelled, remarks, visitLocation, temperature, qListID, qAns, qAnsId, visLim);
            }
            if (typeOfRequest == "facilities") {
                successString = checkInController.getFacilities();
            }
            context.Response.Write(successString);// String to return to front-end
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