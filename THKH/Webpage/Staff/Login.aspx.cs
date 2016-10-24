using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace THKH.Webpage.Staff
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void loginSubmit_Click(object sender, EventArgs e)
        {
            if (ValidateUser(txtUserName.Value.ToString(), txtUserPass.Value.ToString()))
            {
                FormsAuthenticationTicket tkt;
                string cookiestr;
                HttpCookie ck;
                tkt = new FormsAuthenticationTicket(1, txtUserName.Value.ToString(), DateTime.Now,
                 DateTime.Now.AddMinutes(40), true,"Data that can be sent to the cookie to be stored" );
                cookiestr = FormsAuthentication.Encrypt(tkt);
                ck = new HttpCookie(FormsAuthentication.FormsCookieName, cookiestr);
                
                    ck.Expires = tkt.Expiration;
                ck.Path = FormsAuthentication.FormsCookiePath;
                Response.Cookies.Add(ck);

                Response.Redirect("Default.aspx",true);

           
            }
            else
            {
                errorMsg.InnerText = "Invalid Username/Password. Please try again.";
            }
                
        }

        private bool ValidateUser(string user, string pass)
        {
            //Create sql connection and try to log in
            //Assume for now the user and pass checks out. Create the cookie

            return true;
        }
    }
}