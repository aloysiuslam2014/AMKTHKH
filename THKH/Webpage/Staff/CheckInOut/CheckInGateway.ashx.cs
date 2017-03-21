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
            if (typeOfRequest == "searchName")
            {
                var searchData = context.Request.Form["searchData"];
                var isNameSearch = context.Request.Form["isNameSearch"];
                successString = checkInController.searchAutoComplete(isNameSearch,searchData);
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
                var qAnsId = context.Request.Form["qaid"];
                var visLim = context.Request.Form["visLim"];

                successString = checkInController.AssistReg(staffUser, nric, fname, address, postal, mobtel,
            sex, nationality, dob, purpose, pName, pNric, otherPurpose, bedno, appTime,
            remarks, visitLocation, temperature, qListID, qAns, qAnsId, visLim);
            }
            if (typeOfRequest == "express")
            {
                // Write to Visitor_Profile, Visit, Confirmed & CheckInCheckOut Tables
                var staffUser = context.Request.Form["staffUser"].ToString();
                var nric = context.Request.Form["nric"].ToString();
                var fname = context.Request.Form["fullName"];
                var address = context.Request.Form["ADDRESS"];
                var postal = context.Request.Form["POSTAL"];
                var mobtel = context.Request.Form["MobTel"];
                var sex = context.Request.Form["SEX"];
                var nationality = context.Request.Form["Natl"];
                var dob = context.Request.Form["DOB"];
                var purpose = "";
                var pName = "";
                var pNric = "";
                var otherPurpose = "";
                var bedno = "";
                var appTime = "";
                var remarks = context.Request.Form["remarks"];
                var visitLocation = "";
                var qListID = context.Request.Form["qListID"];
                var qAns = context.Request.Form["qAnswers"];
                var qAnsId = context.Request.Form["qaid"];

                successString = checkInController.ExpReg(staffUser, nric, fname, address, postal, mobtel,
            sex, nationality, dob, purpose, pName, pNric, otherPurpose, bedno, appTime,
            remarks, visitLocation, qListID, qAns, qAnsId);
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