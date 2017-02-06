using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;

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
                Session["username"] = txtUserName.Value.ToString();
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
            int rows = 0;
            Object[] userInfo;
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            try {
                SqlCommand command = new SqlCommand("[dbo].[LOGIN]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pEmail", txtUserName.Value.ToString());
                command.Parameters.AddWithValue("@pPassword", ComputeHash(txtUserPass.Value.ToString()));

                cnn.Open();

                using (SqlDataReader reader = command.ExecuteReader())
            {
                    userInfo = new Object[reader.FieldCount];
                while (reader.Read())
                {
                    reader.GetValues(userInfo);
                    rows++;
                }
            }
            cnn.Close();
                // Assign user access rights string to session
                Session["accessRights"] = userInfo[14];
            }
            catch (Exception ex)
            {
                return false;
            }

            if (rows != 1) {
                return false;
            }
            return true;
        }

        private byte[] ComputeHash(string plainText)
        {
            string hash = "";
            SHA512 alg = SHA512.Create();
            byte[] result = alg.ComputeHash(Encoding.UTF8.GetBytes(plainText));
            
            return result;
        }

        public string HexStringFromBytes(byte[] bytes)
        {
            var sb = new StringBuilder();
            foreach (byte b in bytes)
            {
                var hex = b.ToString("x2");
                sb.Append(hex);
            }
            return sb.ToString();
        }

        protected void checkInTerminal_Click(object sender, EventArgs e)
        {
            Response.Redirect("./TerminalCheckIn.aspx");
        }
    }
}