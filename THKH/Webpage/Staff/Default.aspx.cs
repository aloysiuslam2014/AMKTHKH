using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace THKH.Webpage.Staff
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void logout_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Response.Redirect("logon.aspx", true);
        }

        protected void SubmitNewReg(object sender, EventArgs e)
        {
            string connectionString = null;
            int rows = 0;

            SqlConnection cnn;
            connectionString = "Data Source=ALOYSIUS;Initial Catalog=stepwise;Integrated Security=SSPI;";
            //connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=stepwise;Integrated Security=SSPI;";
            cnn = new SqlConnection(connectionString);
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[INSERT INTO  - Registration]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pFirstName", namesInput.Value.ToString());
                command.Parameters.AddWithValue("@pLastName", namesInput.Value.ToString());
                command.Parameters.AddWithValue("@pNric", namesInput.Value.ToString());
                command.Parameters.AddWithValue("@pAddress", addresssInput.Value.ToString());
                command.Parameters.AddWithValue("@pPostal", postalsInput.Value.ToString());
                command.Parameters.AddWithValue("@pMobTel", mobilesInput.Value.ToString());
                command.Parameters.AddWithValue("@pSex", "M");
                command.Parameters.AddWithValue("@pNationality", nationalsInput.Value.ToString());
                command.Parameters.AddWithValue("@pDOB", datesRange.Value.ToString());
                command.Parameters.AddWithValue("@pAltTel", "654");
                command.Parameters.AddWithValue("@prace", "Chinese");
                command.Parameters.AddWithValue("@pHomeTel", "872");
                command.Parameters.AddWithValue("@pAge", 23);
                command.Parameters.Add("@pResponseMessage", SqlDbType.NVarChar, 250).Direction = ParameterDirection.Output;

                cnn.Open();
                Object[] test;

                //rows = command.ExecuteNonQuery();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    test = new Object[reader.FieldCount];
                    while (reader.Read())
                    {

                        reader.GetValues(test);
                        rows++;
                    }
                }


                if (!test[0].Equals("0"))
                {
                    //send registration to database
                }
                else
                {
                    //errorMsg.InnerText = "This NRIC has not registered before, please register as a new visitor.";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            finally
            {
                cnn.Close();
            }
        }
    }
}