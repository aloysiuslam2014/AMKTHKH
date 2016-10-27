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
            string connectionString = null;
            int rows = 0;
            SqlConnection cnn;
            connectionString = "Data Source=WARSHOCK\\SQLEXPRESS;Initial Catalog=stepwise;Integrated Security=SSPI;";
            cnn = new SqlConnection(connectionString);
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[SELECT FROM - login]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pNric", txtUserName.Value.ToString());
                command.Parameters.AddWithValue("@pPassword", ComputeHash(txtUserPass.Value.ToString()));
                cnn.Open();
                //rows = command.ExecuteNonQuery();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        rows++;
                        //Get Salt Hash txtPwd with Salt using SHA2-512 & compare hash values
                    }
                }
                cnn.Close();
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

        private string ComputeHash(string plainText)
        {
            string hash = "";
            SHA512 alg = SHA512.Create();
            byte[] result = alg.ComputeHash(Encoding.UTF8.GetBytes(plainText));
            hash = HexStringFromBytes(result);

            return "0x"+hash.ToUpper();
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
    }
}