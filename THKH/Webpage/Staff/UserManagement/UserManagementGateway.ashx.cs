using System;
using System.Web;
using THKH.Classes.Controller;

namespace THKH.Webpage.Staff.UserManagement
{
    /// <summary>
    /// CRUD Actions for Hospital Staff
    /// </summary>
    public class UserManagementGateway : IHttpHandler
    {
        UserManagementController userManagementController = new UserManagementController();

        /// <summary>
        /// Picks out the action needed & calls the appropriate methods in the related controller class
        /// </summary>
        /// <param name="context"></param>
        public void ProcessRequest(HttpContext context)
        {     
            context.Response.ContentType = "text/plain";
            String successString = ""; 

            var requestType = context.Request.Form["requestType"];

            if (requestType == "loadUsers") {
                successString = userManagementController.loadUsers();
            }
            if (requestType == "getUser")
            {
                var email = context.Request.Form["email"];
                successString = userManagementController.getUser(email);
            }
            if (requestType == "updateUser") {
                var staffUser = context.Request.Form["username"].ToString();
                var fname = context.Request.Form["fname"];
                var lname = context.Request.Form["lname"];
                var snric = context.Request.Form["snric"];
                var email = context.Request.Form["email"];
                var address = context.Request.Form["address"];
                var postal = context.Request.Form["postal"].ToString();
                var mobtel = context.Request.Form["mobtel"];
                var hometel = context.Request.Form["hometel"];
                var alttel = context.Request.Form["alttel"];
                var sex = context.Request.Form["sex"];
                var nationality = context.Request.Form["nationality"];
                var dob = context.Request.Form["dob"];
                var title = context.Request.Form["title"];
                int permissions = Int32.Parse(context.Request.Form["permissions"]);
                var accessProfile = context.Request.Form["accessProfile"];
                var password = context.Request.Form["staffPwd"]; // If blank, dont change password
                successString = userManagementController.updateUser(fname, lname, snric, email, address, postal, mobtel, hometel, alttel, sex, nationality, dob, title, permissions, password, staffUser, accessProfile);
            }
            if (requestType == "deleteUser") {
                var snric = context.Request.Form["snric"];
                var email = context.Request.Form["email"];
                successString = userManagementController.deleteUser(snric, email);
            }
            if (requestType == "addUser") {
                var staffUser = context.Request.Form["username"].ToString();
                var fname = context.Request.Form["fname"];
                var lname = context.Request.Form["lname"];
                var snric = context.Request.Form["snric"];
                var email = context.Request.Form["email"];
                var address = context.Request.Form["address"];
                var postal = context.Request.Form["postal"].ToString();
                var mobtel = context.Request.Form["mobtel"];
                var hometel = context.Request.Form["hometel"];
                var alttel = context.Request.Form["alttel"];
                var sex = context.Request.Form["sex"];
                var nationality = context.Request.Form["nationality"];
                var dob = context.Request.Form["dob"];
                var title = context.Request.Form["title"];
                int permissions = Int32.Parse(context.Request.Form["permissions"]);
                var accessProfile = context.Request.Form["accessProfile"];
                var password = context.Request.Form["staffPwd"];
                successString = userManagementController.addUser(fname,lname,snric,email,address,postal,mobtel,hometel,alttel,sex,nationality,dob,title,permissions, password, staffUser, accessProfile);
            }
            if (requestType == "getPermissions") {
                successString = userManagementController.getPermissions();
            }
            context.Response.Write(successString);
        }

        // Gets a List in String form from the Staff Table
        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}