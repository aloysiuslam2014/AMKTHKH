using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Text;

namespace THKH.Webpage.SelfReg
{
    public partial class SelfRegister : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            staticinfocontainer.Visible = false;
            newusercontent.Visible = false;
            existingusercontent.Visible = false;
            submitNew.Visible = false;
            submitExist.Visible = false;
        }

        protected void LinkButton1_Click(object sender, EventArgs e)
        {
            PopulateNewUserForm();
            staticinfocontainer.Visible = true;
            newusercontent.Visible = true;
            submitNew.Visible = true;
        }

        protected void LinkButton2_Click(object sender, EventArgs e)
        {
            staticinfocontainer.Visible = true;
            existingusercontent.Visible = true;
            submitExist.Visible = true;
        }

        protected void PopulateNewUserForm()
        {
            //lblname = "Shahid;
        }

        protected void SubmitExistNRIC(object sender, EventArgs e)
        {
            if (isNew.Value.Equals("0")){
                //Create sql connection and try to log in
                //Assume for now the user and pass checks out. Create the cookie
                string connectionString = null;
                int rows = 0;

                SqlConnection cnn;
                connectionString = "Data Source=ALOYSIUS;Initial Catalog=stepwise;Integrated Security=SSPI;";
                //connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=stepwise;Integrated Security=SSPI;";
                cnn = new SqlConnection(connectionString);
                try
                {
                    SqlCommand command = new SqlCommand("[dbo].[SELECT FROM - FindVisitor]", cnn);
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@pNric", existnric.ToString());
                        
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
                    else {
                        errorMsg.InnerText = "This NRIC has not registered before, please register as a new visitor.";
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
            else {
                errorMsg.InnerText = "Invalid Username/Password. Please try again.";
            }
        }

        protected void SubmitNewReg(object sender, EventArgs e)
        {

        }
    }
}